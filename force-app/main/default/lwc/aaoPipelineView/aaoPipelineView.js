import { LightningElement, api } from 'lwc';
import getSnapshot from '@salesforce/apex/AAO_PipelineViewController.getSnapshot';

/**
 * AAO Pipeline (internal).
 *
 * Read-only. It writes nothing and it holds no state the org does not already hold: every
 * poll rebuilds the whole snapshot from the rows, so the view cannot drift from the org the
 * way a cached projection would.
 *
 * Two cadences, on purpose. While an artifact has landed and nothing has adjudicated it,
 * the interesting thing is about to happen and the view polls every two seconds with a
 * spinner on that row. Once everything is adjudicated there is nothing to wait for and it
 * drops to ten, because a demo screen that hammers an org is its own kind of statement.
 */
const FAST_MS = 2000;
const SLOW_MS = 10000;

export default class AaoPipelineView extends LightningElement {
    @api recordId;

    snapshot;
    error;
    loading = true;

    _timer;
    _stopped = false;

    connectedCallback() {
        this.load();
    }

    disconnectedCallback() {
        this._stopped = true;
        clearTimeout(this._timer);
    }

    async load() {
        try {
            this.snapshot = await getSnapshot({ opportunityId: this.recordId });
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

    schedule() {
        if (this._stopped) {
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

    get hasSnapshot() {
        return !!this.snapshot;
    }

    get showEmpty() {
        return !!this.snapshot && this.snapshot.isEmpty;
    }

    get showBody() {
        return !!this.snapshot && !this.snapshot.isEmpty;
    }

    handleRefresh() {
        this.loading = true;
        this.load();
    }
}
