import { LightningElement, api, wire, track } from 'lwc';
import runsFor from '@salesforce/apex/AAO_RunInspector.runsFor';
import inspect from '@salesforce/apex/AAO_RunInspector.inspect';

/**
 * THE RUN INSPECTOR. Pick a run, read the stage counts, click any establishment and walk it
 * back to the exact words in the transcript, with the refusals shown alongside.
 *
 * Read-only by construction: it calls two cacheable Apex reads and holds no write path at all.
 * The refusals are a first-class panel rather than a detail view, because a surface that shows
 * only what stood tells you what the machine believes and not whether to believe it.
 */
export default class AaoRunInspector extends LightningElement {
    @api recordId;
    @track runKey;
    @track view;
    @track selected;
    runs = [];
    error;

    @wire(runsFor, { opportunityId: '$recordId' })
    wiredRuns({ data, error }) {
        if (data) {
            this.runs = data;
            // Default to the latest run: the tester almost always wants what just happened.
            if (!this.runKey && data.length) {
                this.runKey = data[0].runKey;
            }
        } else if (error) {
            this.error = this.messageOf(error);
        }
    }

    @wire(inspect, { opportunityId: '$recordId', runKey: '$runKey' })
    wiredView({ data, error }) {
        if (data) {
            this.view = data;
            this.selected = undefined;
            this.error = undefined;
        } else if (error) {
            this.error = this.messageOf(error);
        }
    }

    get runOptions() {
        return this.runs.map((r) => ({
            label: `${r.runKey}  (${r.pairCount} pairs)`,
            value: r.runKey
        }));
    }

    get hasRuns() {
        return this.runs && this.runs.length > 0;
    }

    get upheld() {
        return (this.view && this.view.upheld) || [];
    }

    get refused() {
        return (this.view && this.view.refused) || [];
    }

    get hasSelection() {
        return !!this.selected;
    }

    /** The byte range, shown because it is what makes the quote checkable rather than claimed. */
    get selectedRange() {
        if (!this.selected || this.selected.startOffset === null) {
            return null;
        }
        return `bytes ${this.selected.startOffset}-${this.selected.endOffset}`;
    }

    handleRunChange(event) {
        this.runKey = event.detail.value;
    }

    handleSelect(event) {
        const id = event.currentTarget.dataset.id;
        this.selected =
            this.upheld.find((t) => t.id === id) || this.refused.find((t) => t.id === id);
    }

    messageOf(error) {
        return (error && error.body && error.body.message) || 'Something failed to load.';
    }
}
