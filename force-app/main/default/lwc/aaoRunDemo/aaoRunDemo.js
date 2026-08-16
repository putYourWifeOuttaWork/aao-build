import { LightningElement, api, track } from 'lwc';
import startRun from '@salesforce/apex/AAO_DemoController.startRun';
import progress from '@salesforce/apex/AAO_DemoController.progress';

/**
 * THE ON-RECORD DEMO. Paste evidence, run the pass, watch it happen.
 *
 * REAL RECEIPTS ONLY, which is the hundred-fourth stamp's own condition and the whole integrity
 * of this surface. Every stage drawn below is a leg the pass journalled on `AAO_Run_Receipt__c`.
 * Nothing here interpolates, estimates, or advances a bar because time passed. A stage that has
 * not journalled is drawn as WAITING, and a stage that failed is drawn with its reason.
 *
 * The two pieces are deliberately separable, per the stamp: the paste panel and the run view are
 * distinct blocks over one controller that knows nothing about Lightning, so both lift out into
 * the standalone application without being rewritten.
 */
const POLL_MS = 3000;
// The pass's stages in the order the driver runs them, so a stage can be drawn as WAITING before
// it has journalled anything. Kept in step with AAO_PassQueueable.ORDER.
const PIPELINE = [
    'call 0 resolve',
    'call 1 locate',
    'resolution',
    'resolution model leg',
    'call 3 verify',
    'join',
    'projection',
    'cards'
];

export default class AaoRunDemo extends LightningElement {
    @api recordId;

    @track text = '';
    @track label = '';
    @track roster = '';
    @track runKey;
    @track view;
    @track error;
    @track busy = false;

    pollId;

    disconnectedCallback() {
        this.stopPolling();
    }

    handleText(e) {
        this.text = e.target.value;
    }

    handleLabel(e) {
        this.label = e.target.value;
    }

    handleRoster(e) {
        this.roster = e.target.value;
    }

    get canRun() {
        // The roster is required, not optional: the side split comes from attendee metadata
        // and never from the transcript, so a run without it would be refused downstream
        // anyway - better to say so on the button than to spend three callouts finding out.
        return (
            !this.busy &&
            this.text &&
            this.text.trim().length > 0 &&
            this.roster &&
            this.roster.trim().length > 0
        );
    }

    /**
     * THE TEMPLATE CANNOT SAY `!canRun`, and that is why this getter exists rather than being
     * inlined. LWC markup has no negation operator, so an inverted condition has to be exposed
     * as its own name - and the first draft bound `disabled={canRun}`, which disabled the
     * button exactly when the run WAS possible and enabled it when it was not.
     *
     * Found by opening the page, which is the sixty-fifth stamp's whole point: the suite was
     * green, the controller was proved end to end from the runtime, and the one thing neither
     * could see was the button.
     */
    get cannotRun() {
        return !this.canRun;
    }

    get running() {
        return !!this.runKey && !(this.view && this.view.finished);
    }

    async handleRun() {
        this.error = undefined;
        this.view = undefined;
        this.busy = true;
        try {
            const started = await startRun({
                opportunityId: this.recordId,
                text: this.text,
                label: this.label,
                roster: this.roster
            });
            this.runKey = started.runKey;
            this.startPolling();
        } catch (e) {
            this.error = (e && e.body && e.body.message) || 'Could not start the run.';
        } finally {
            this.busy = false;
        }
    }

    startPolling() {
        this.stopPolling();
        this.poll();
        this.pollId = setInterval(() => this.poll(), POLL_MS);
    }

    stopPolling() {
        if (this.pollId) {
            clearInterval(this.pollId);
            this.pollId = undefined;
        }
    }

    async poll() {
        try {
            const v = await progress({ opportunityId: this.recordId, runKey: this.runKey });
            this.view = v;
            if (v && v.finished) {
                this.stopPolling();
            }
        } catch (e) {
            this.error = (e && e.body && e.body.message) || 'Lost contact with the run.';
            this.stopPolling();
        }
    }

    /**
     * The pipeline drawn from what was journalled, never from what was expected.
     *
     * A stage the receipt has a leg for is DONE (or FAILED, where the leg carries an error);
     * every stage after the last journalled one is WAITING. `call 1 locate` merges its two reads
     * because the receipt merges legs per stage, which is the receipt's own shape and not a
     * simplification made here.
     */
    get stageRows() {
        const legs = (this.view && this.view.stages) || [];
        const byStage = new Map();
        legs.forEach((l) => byStage.set(l.stage, l));
        let reachedEnd = false;
        return PIPELINE.map((name) => {
            const leg = byStage.get(name);
            if (leg && leg.error) {
                reachedEnd = true;
                return {
                    name,
                    state: 'FAILED',
                    detail: leg.error,
                    css: 'stage stage-failed',
                    key: name
                };
            }
            if (leg) {
                const bits = [];
                if (leg.wallMs) bits.push(`${(leg.wallMs / 1000).toFixed(1)}s`);
                if (leg.callouts) bits.push(`${leg.callouts} callout${leg.callouts > 1 ? 's' : ''}`);
                if (leg.produced !== undefined && leg.produced !== null) {
                    bits.push(`${leg.produced} produced`);
                }
                if (leg.cache) bits.push(leg.cache);
                return {
                    name,
                    state: 'DONE',
                    detail: bits.join(' · '),
                    css: 'stage stage-done',
                    key: name
                };
            }
            const waiting = reachedEnd ? 'SKIPPED' : 'WAITING';
            return { name, state: waiting, detail: '', css: 'stage stage-waiting', key: name };
        });
    }

    get ledgerRows() {
        const v = this.view;
        if (!v) return [];
        return [
            { key: 'located', label: 'words located', value: v.located },
            { key: 'identified', label: 'people identified', value: v.identified },
            { key: 'upheld', label: 'upheld by the blind verifier', value: v.upheld },
            { key: 'refused', label: 'refused, with reasons', value: v.refused },
            { key: 'claims', label: 'claims on the deal', value: v.claims },
            { key: 'answers', label: 'answers on the deal', value: v.answers },
            { key: 'cards', label: 'cards on the board', value: v.cards }
        ];
    }

    get wallSeconds() {
        return this.view && this.view.totalWallMs
            ? (this.view.totalWallMs / 1000).toFixed(1)
            : '0.0';
    }

    /** The 120,000 ms callout ceiling, shown as what it is: a wall the run is measured against. */
    get worstCalloutLine() {
        const w = this.view && this.view.worstCalloutMs;
        if (!w) return null;
        return `${(w / 1000).toFixed(1)}s worst callout · ${Math.round((w / 120000) * 100)}% of the 120s ceiling`;
    }
}
