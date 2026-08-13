import { LightningElement, api } from 'lwc';

/**
 * THE WALK-BACK, opened inline under the row it belongs to.
 *
 * It is its own component for one reason: the same detail has to open under an upheld row and
 * under a refused one, and duplicating it in the parent template would be two copies of the one
 * thing a reviewer reads most closely. Two copies drift.
 *
 * The numbered path renders EVERY step, including the ones that did not happen. A step that did
 * not happen greys and carries its reason, so a refusal's path is exactly as legible as an
 * uphold's. Dropping the dead steps would make every trace look like a success that ended early.
 */
export default class AaoTraceDetail extends LightningElement {
    @api trace;

    get steps() {
        const path = (this.trace && this.trace.path) || [];
        return path.map((s) => ({
            key: s.n,
            n: s.n,
            label: s.label,
            text: s.happened ? s.detail : s.reason,
            css: s.happened ? 'path-step' : 'path-step path-step_skipped'
        }));
    }

    get hasQuote() {
        return !!(this.trace && this.trace.quote);
    }

    get hasWhy() {
        return !!(this.trace && this.trace.refusalNote);
    }

    get internalMark() {
        if (!this.trace || !this.trace.personInternal) {
            return null;
        }
        return `Internal speaker: ${this.trace.internalReason}`;
    }
}
