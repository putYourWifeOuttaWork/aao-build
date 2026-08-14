import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getSnapshot from '@salesforce/apex/AAO_PipelineViewController.getSnapshot';

/**
 * AAO Pipeline command center.
 *
 * Read-only. It writes nothing and it holds no state the org does not already hold: every
 * poll rebuilds the whole snapshot from the rows, so the view cannot drift from the org the
 * way a cached projection would.
 *
 * Two cadences, on purpose. While an artifact has landed and nothing has adjudicated it,
 * the interesting thing is about to happen and the view polls every two seconds with a
 * spinner on that row. Once everything is adjudicated there is nothing to wait for and it
 * drops to ten, because a demo screen that hammers an org is its own kind of statement.
 *
 * The only thing this component computes is navigation URLs. Apex returns ids; this walks
 * the snapshot, generates one URL per DISTINCT id, and writes `<field>Url` beside each. Every
 * link opens in a new tab so the command center never navigates away mid-run.
 */
const FAST_MS = 2000;
const SLOW_MS = 10000;

/** 15 or 18 character Salesforce id. */
const ID_RE = /^[a-zA-Z0-9]{15}(?:[a-zA-Z0-9]{3})?$/;

export default class AaoPipelineView extends NavigationMixin(LightningElement) {
    /**
     * The record id is taken through a setter rather than a bare `@api` field, and the first
     * Apex call is fired from here rather than from `connectedCallback`.
     *
     * **Why, from a real defect.** This component sits in the body facet of the fifth tab of
     * the Opportunity page's tabset, which is not the default tab, so the framework
     * constructs it lazily. In that path `connectedCallback` can run before the framework has
     * assigned `recordId`, and the old code called Apex from `connectedCallback`
     * unconditionally. Apex received null, raised its configuration guard, and the
     * self-rescheduling poll re-raised it every ten seconds forever. The Account placement
     * never showed it because a component in a top-level region gets its id before connect.
     *
     * **The race is older than the command-center rework** — the previous version called Apex
     * from `connectedCallback` in exactly the same way. The rework did not move the call; it
     * made a latent race visible.
     *
     * Whichever happens last, the id arriving or the element connecting, starts the load.
     * Apex is never called without an id, and a record swap under a console tab reloads
     * cleanly instead of showing the previous record's snapshot.
     */
    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        const previous = this._recordId;
        this._recordId = value;
        if (this._started && value && value !== previous) {
            this.restart();
            return;
        }
        this.maybeStart();
    }

    snapshot;
    error;
    loading = true;

    _recordId;
    _connected = false;
    _started = false;
    _configChecked = false;
    _timer;
    _stopped = false;
    /** id -> url, kept across polls because a record's URL does not change. */
    _urlCache = new Map();
    /**
     * Which lineage rows are open. Held here rather than on the payload because the payload
     * is replaced every two seconds; without this, a poll would close whatever was being read.
     */
    _expanded = new Set();

    connectedCallback() {
        this._connected = true;
        this.maybeStart();
    }

    /**
     * If the id genuinely never arrives the component must say so rather than spin. A
     * permanent spinner is the same lie as an empty state: it implies the system is working
     * on something. By first render the framework has assigned every `@api` value it is going
     * to assign, so a missing id here is a real configuration fault.
     */
    renderedCallback() {
        if (this._started || this._configChecked) {
            return;
        }
        this._configChecked = true;
        if (!this._recordId) {
            this.loading = false;
            // Deliberately worded so it cannot be confused with the Apex guard. If this text
            // appears, the framework never handed the component an id and the fault is in the
            // placement. If the Apex text appears instead, something called the server without
            // an id and this guard failed. They are different defects and must read differently.
            this.error =
                'COMPONENT: no record id was ever handed to this component by the page. ' +
                'It is bound to an Opportunity or Account record page; this is a placement ' +
                'fault, not an empty record.';
        }
    }

    disconnectedCallback() {
        this._stopped = true;
        clearTimeout(this._timer);
    }

    /** Start once, and only once an id exists. */
    maybeStart() {
        if (this._started || !this._connected || !this._recordId) {
            return;
        }
        this._started = true;
        this.error = undefined;
        this.loading = true;
        this.load();
    }

    /** The host swapped records under us. Nothing from the old record survives. */
    restart() {
        clearTimeout(this._timer);
        this._expanded.clear();
        this.snapshot = undefined;
        this.error = undefined;
        this.loading = true;
        this.load();
    }

    async load() {
        // Belt and braces: nothing calls Apex without an id, and if something ever does it
        // stops here rather than teaching the poll to raise the same error forever.
        if (!this._recordId) {
            this.loading = false;
            return;
        }
        try {
            const raw = await getSnapshot({ recordId: this._recordId });
            this.snapshot = await this.withUrls(raw);
            this.error = undefined;
        } catch (e) {
            this.error =
                (e && e.body && e.body.message) ||
                (e && e.message) ||
                'Could not read the pipeline.';
        } finally {
            this.loading = false;
            this.schedule();
        }
    }

    // ------------------------------------------------------------------ links (A)

    /**
     * Deep-clone the Apex payload (it arrives frozen), collect every id, resolve one URL per
     * distinct id, then decorate. Cloning is required rather than tidy: LWC freezes wire and
     * imperative Apex results, so the decoration cannot be written in place.
     */
    async withUrls(raw) {
        const snap = JSON.parse(JSON.stringify(raw));
        const ids = new Set();
        this.collectIds(snap, ids);

        const unresolved = [...ids].filter((id) => !this._urlCache.has(id));
        await Promise.all(
            unresolved.map(async (id) => {
                try {
                    const url = await this[NavigationMixin.GenerateUrl]({
                        type: 'standard__recordPage',
                        attributes: { recordId: id, actionName: 'view' }
                    });
                    this._urlCache.set(id, url);
                } catch (e) {
                    // A URL that will not generate is not worth failing a whole snapshot for.
                    // The row still renders; it renders as text, which is what it did before.
                    this._urlCache.set(id, null);
                }
            })
        );

        this.decorate(snap);
        this.applyExpansion(snap);
        return snap;
    }

    /** Depth-one only. Claims expand, answers expand, and nothing inside them expands. */
    applyExpansion(snap) {
        (snap.claims || []).forEach((c) => {
            c.expanded = this._expanded.has(c.id);
            c.toggleLabel = c.expanded ? 'Hide lineage' : 'Show lineage';
        });
        (snap.people || []).forEach((g) => {
            (g.answers || []).forEach((a) => {
                a.expanded = this._expanded.has(a.id);
                a.toggleLabel = a.expanded ? 'Hide claims' : 'Show claims';
            });
        });
    }

    handleToggle(event) {
        const id = event.currentTarget.dataset.id;
        if (!id) {
            return;
        }
        if (this._expanded.has(id)) {
            this._expanded.delete(id);
        } else {
            this._expanded.add(id);
        }
        // Re-apply against the live object and reassign so the template re-renders.
        const snap = JSON.parse(JSON.stringify(this.snapshot));
        this.applyExpansion(snap);
        this.snapshot = snap;
    }

    collectIds(node, out) {
        if (Array.isArray(node)) {
            node.forEach((n) => this.collectIds(n, out));
            return;
        }
        if (!node || typeof node !== 'object') {
            return;
        }
        for (const [key, value] of Object.entries(node)) {
            if (typeof value === 'string' && this.isIdField(key) && ID_RE.test(value)) {
                out.add(value);
            } else if (value && typeof value === 'object') {
                this.collectIds(value, out);
            }
        }
    }

    isIdField(key) {
        return key === 'id' || key.endsWith('Id');
    }

    decorate(node) {
        if (Array.isArray(node)) {
            node.forEach((n) => this.decorate(n));
            return;
        }
        if (!node || typeof node !== 'object') {
            return;
        }
        for (const [key, value] of Object.entries(node)) {
            if (typeof value === 'string' && this.isIdField(key) && ID_RE.test(value)) {
                const url = this._urlCache.get(value);
                node[key === 'id' ? 'url' : `${key}Url`] = url || null;
                node[key === 'id' ? 'hasUrl' : `has${key}Url`] = !!url;
            } else if (value && typeof value === 'object') {
                this.decorate(value);
            }
        }
    }

    // ---------------------------------------------------------------------- polling

    schedule() {
        // No id means no work to poll for. A poll that only re-raises a configuration error
        // every ten seconds is noise dressed as diligence.
        if (this._stopped || !this._recordId) {
            return;
        }
        clearTimeout(this._timer);
        this._timer = setTimeout(() => this.load(), this.intervalMs);
    }

    get intervalMs() {
        return this.snapshot && this.snapshot.hasPending ? FAST_MS : SLOW_MS;
    }

    get cadence() {
        if (!this.snapshot) {
            return '';
        }
        return this.snapshot.hasPending
            ? 'Adjudication pending — refreshing every 2s'
            : 'Refreshing every 10s';
    }

    // ----------------------------------------------------------------------- getters

    get hasSnapshot() {
        return !!this.snapshot;
    }

    get showEmpty() {
        return !!this.snapshot && this.snapshot.isEmpty;
    }

    get showBody() {
        return !!this.snapshot && !this.snapshot.isEmpty;
    }

    get isAccount() {
        return !!this.snapshot && this.snapshot.context === 'Account';
    }

    get headerTitle() {
        if (!this.snapshot) {
            return 'AAO Pipeline';
        }
        return `AAO Pipeline · ${this.snapshot.contextName || this.snapshot.context}`;
    }

    get bannerClass() {
        const base = 'slds-box slds-box_x-small slds-m-bottom_small aao-banner';
        if (!this.snapshot || !this.snapshot.banner) {
            return base;
        }
        return this.snapshot.banner.active ? `${base} aao-banner_active` : base;
    }

    get projectionPanelClass() {
        const base = 'slds-box slds-box_x-small aao-panel';
        return this.snapshot && this.snapshot.projection && this.snapshot.projection.isOn
            ? base
            : `${base} aao-off`;
    }

    handleRefresh() {
        this.loading = true;
        this.load();
    }
}