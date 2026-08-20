import { LightningElement, api, track } from 'lwc';
import startRun from '@salesforce/apex/AAO_DemoController.startRun';
import progress from '@salesforce/apex/AAO_DemoController.progress';
import purgeDeal from '@salesforce/apex/AAO_DemoController.purgeDeal';
import resumeRun from '@salesforce/apex/AAO_DemoController.resumeRun';
import recentRuns from '@salesforce/apex/AAO_DemoController.recentRuns';
import processFor from '@salesforce/apex/AAO_DemoController.processFor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

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
// THE STAGES, WITH THE NAMES THE RECEIPT ACTUALLY WRITES.
//
// The first version guessed and got two wrong - `call 1 locate` and `resolution`, neither of which
// the receipt journals - so those rows sat WAITING forever no matter what the run did. Read off a
// real receipt rather than assumed, which is this project's own instrument-reach rule turned on
// its own surface. `label` is what a seller reads; `stage` is what the pass writes.
const PIPELINE = [
    { stage: 'call 0 resolve', label: 'Scope' },
    { stage: 'call 1 locate read 1', label: 'Read 1' },
    { stage: 'call 1 locate read 2', label: 'Read 2' },
    { stage: 'resolution model leg', label: 'Identify' },
    { stage: 'call 3 verify', label: 'Verify' },
    // Added with (e) and (f). A stage the pass runs and this list omits draws nothing, and a
    // stage this list names and the pass never journals sits WAITING forever - the defect the
    // comment above records. Both halves read off a real receipt.
    { stage: 'criterion match', label: 'Criteria' },
    { stage: 'join', label: 'Claims' },
    { stage: 'computed catalog', label: 'Computed' },
    { stage: 'projection', label: 'Map' },
    { stage: 'cards', label: 'Cards' }
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
    @track confirmingPurge = false;
    @track purging = false;
    @track resuming = false;
    /**
     * A resume is in flight until the receipt stops saying the run is stopped.
     *
     * THE GAP THIS CLOSES: between the click and the resumed stage journalling ANYTHING, the
     * receipt still carries only the old failure - so the very next poll reads "stopped", calls
     * the run finished, and stops polling. The chain then runs to completion behind a frozen
     * screen. That is what persisted in the room, and clearing the stale error alone did not fix
     * it, because the surface stopped looking before the new leg existed.
     */
    resumeInFlight = false;
    resumePolls = 0;
    @track past = [];
    @track showingPast = false;
    @track process;

    pollId;

    get hasReds() {
        return !!(this.process && this.process.redCount > 0);
    }

    get hasGhosts() {
        return !!(this.process && this.process.ghosts && this.process.ghosts.length);
    }

    get hasQualifiers() {
        return !!(this.process && this.process.qualifiers && this.process.qualifiers.length);
    }

    get hasProcessNotes() {
        return !!(this.process && this.process.notes && this.process.notes.length);
    }

    connectedCallback() {
        this.loadPast();
        this.loadProcess();
    }

    disconnectedCallback() {
        this.stopPolling();
    }

    /**
     * THE PROCESS PANEL, step (f). Loaded on open and again when a run finishes, because a run
     * is exactly the thing that changes what it says.
     *
     * A failure here is SWALLOWED to a note rather than raised: the run is what the room is
     * watching and a panel beside it must not take the page down. The same reasoning the receipt
     * uses for telemetry, and the opposite of what the sixty-fourth stamp's defect did.
     */
    loadProcess() {
        if (!this.recordId) {
            return;
        }
        processFor({ opportunityId: this.recordId })
            .then((v) => {
                // NOTES ARE KEYED BY INDEX, NOT BY THEIR TEXT. Two planes can say the same
                // sentence honestly - "no gap stands" reads the same for personas and for
                // qualifiers - and a repeated string as a `for:each` key is a duplicate key,
                // which is a render defect rather than a cosmetic one. The sixty-fourth stamp's
                // class, caught by reading the template rather than by the panel freezing.
                this.process = v
                    ? {
                          ...v,
                          notes: (v.notes || []).map((n, i) => ({ key: `n${i}`, text: n }))
                      }
                    : undefined;
            })
            .catch(() => {
                this.process = undefined;
            });
    }

    /**
     * PAST RUNS, loaded on every render of the form.
     *
     * A refresh wipes the component's memory of what it ran, and the work stays on the deal - so
     * before this, a run that happened became unreachable from the surface that started it. The
     * form still opens ready for a new paste, which is what a demo wants; the past is one click
     * away rather than gone.
     */
    async loadPast() {
        try {
            this.past = await recentRuns({ opportunityId: this.recordId });
        } catch (e) {
            this.past = [];
        }
    }

    get hasPast() {
        return this.past && this.past.length > 0;
    }

    get pastLabel() {
        const n = this.past ? this.past.length : 0;
        return this.showingPast
            ? 'Hide earlier runs'
            : `Earlier runs on this deal (${n})`;
    }

    get pastRows() {
        return (this.past || []).map((r, i) => ({
            runKey: r.runKey,
            when: this.stamp(r.startedAt),
            ordinal: `Call ${this.past.length - i}`,
            status: r.stopped ? 'stopped' : r.finished ? 'complete' : 'incomplete',
            css: r.stopped ? 'pastrow past-stopped' : 'pastrow'
        }));
    }

    stamp(iso) {
        if (!iso) return 'unknown time';
        const d = new Date(iso);
        return d.toLocaleString(undefined, {
            month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit'
        });
    }

    handleTogglePast() {
        this.showingPast = !this.showingPast;
        if (this.showingPast) this.loadPast();
    }

    /** Open a past run in the same process bar the live run uses. Read-only; starts nothing. */
    handleOpenPast(e) {
        this.runKey = e.currentTarget.dataset.key;
        this.showingPast = false;
        this.error = undefined;
        this.poll();
    }

    /** Back to the form, without touching anything the deal holds. */
    handleNewRun() {
        this.stopPolling();
        this.runKey = undefined;
        this.view = undefined;
        this.error = undefined;
        this.loadPast();
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

    /**
     * RESUME, offered only when the run actually stopped.
     *
     * A model callout can time out mid-pass; the work in front of it is banked and the pass's
     * watermarks make everything after it idempotent, so the recovery is to re-enter at the
     * failed stage rather than start over and re-locate every pair.
     */
    get canResume() {
        return !!(this.view && this.view.stoppedBecause) && !this.resuming;
    }

    async handleResume() {
        this.resuming = true;
        try {
            const msg = await resumeRun({ opportunityId: this.recordId, runKey: this.runKey });
            // SAY THAT IT WAS ASKED, because a resume that re-runs the same stage and fails the
            // same way looks byte-for-byte like a button that does nothing. The toast is the
            // only proof the click landed before the next leg journals.
            this.dispatchEvent(
                new ShowToastEvent({ title: 'Resuming', message: msg, variant: 'info' })
            );
            this.resumeInFlight = true;
            this.resumePolls = 0;
            this.startPolling();
        } catch (e) {
            this.error = (e && e.body && e.body.message) || 'Could not resume the run.';
        } finally {
            this.resuming = false;
        }
    }

    // ---------------------------------------------------------------- purge this deal
    //
    // Two clicks, deliberately. The confirm names the deal so a mis-drop on a record page that
    // is NOT the harness is caught by eye before anything is deleted - which is the whole reason
    // it is a dialog rather than a button that just fires.

    handlePurgeAsk() {
        this.confirmingPurge = true;
    }

    handlePurgeCancel() {
        this.confirmingPurge = false;
    }

    async handlePurgeConfirm() {
        this.purging = true;
        try {
            const summary = await purgeDeal({ opportunityId: this.recordId });
            // The component resets its OWN view rather than reloading: the run it was showing no
            // longer exists, and leaving its stages on screen would be the surface asserting
            // something the org no longer holds.
            this.stopPolling();
            this.runKey = undefined;
            this.view = undefined;
            this.error = undefined;
            this.text = '';
            this.label = '';
            // The panel showed the deal's Process state and the purge removed most of it.
            // Re-read rather than kept: a surface asserting rows the org no longer holds is the
            // same defect as leaving the stages on screen.
            this.loadProcess();
            this.dispatchEvent(
                new ShowToastEvent({ title: 'Deal purged', message: summary, variant: 'success' })
            );
        } catch (e) {
            const msg = (e && e.body && e.body.message) || 'The purge refused.';
            this.dispatchEvent(
                new ShowToastEvent({ title: 'Nothing deleted', message: msg, variant: 'warning' })
            );
        } finally {
            this.purging = false;
            this.confirmingPurge = false;
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

    // Roughly two minutes at the poll interval. A resumed stage that has journalled nothing by
    // then has almost certainly failed again the same way, and polling forever would be a
    // spinner pretending to be progress.
    static get RESUME_PATIENCE() {
        return 40;
    }

    async poll() {
        try {
            const v = await progress({ opportunityId: this.recordId, runKey: this.runKey });
            this.view = v;

            if (this.resumeInFlight) {
                // KEEP LOOKING while the resume has not yet shown up on the receipt. The stage
                // that failed appends a SECOND leg on success, and until it lands the receipt
                // legitimately still reads stopped - so "stopped" is not an answer yet.
                this.resumePolls += 1;
                if (!v || !v.stoppedBecause) {
                    this.resumeInFlight = false;
                    this.resumePolls = 0;
                } else if (this.resumePolls >= AaoRunDemo.RESUME_PATIENCE) {
                    this.resumeInFlight = false;
                    this.resumePolls = 0;
                    this.stopPolling();
                }
                return;
            }

            // A run that STOPPED is not a run that finished, and the difference matters: a
            // finished run has nothing left to watch, while a stopped one is waiting for a
            // person. Both end the poll, and only one of them is done.
            if (v && v.finished) {
                this.stopPolling();
                // A finished run is exactly what changes what the Process panel says, so it is
                // re-read once here rather than polled alongside the run. The panel is about the
                // DEAL and only a completed pass moves it.
                this.loadProcess();
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
    /**
     * THE PROCESS BAR, every state derived from journalled legs.
     *
     * DONE     the receipt carries this leg.
     * FAILED   the leg carries an error.
     * RUNNING  the first stage after the last journalled one, while the run is unfinished. This
     *          is an inference and a truthful one: the driver runs stages in order, one per
     *          transaction, so the stage after the last journalled leg is the one executing.
     *          Derived from real state, never from a timer - the bar advances when a leg lands.
     * SKIPPED  unjournalled, but a LATER stage journalled, so it did not fire. The model leg
     *          legitimately skips when the deterministic pass leaves no remainder, and drawing
     *          that as stuck would misreport the run.
     * WAITING  not reached yet.
     */
    get stageRows() {
        const legs = (this.view && this.view.stages) || [];
        const byStage = new Map();
        legs.forEach((l) => byStage.set(l.stage, l));

        let lastDone = -1;
        PIPELINE.forEach((p, i) => {
            if (byStage.has(p.stage)) lastDone = i;
        });
        const finished = !!(this.view && this.view.finished);

        return PIPELINE.map((p, i) => {
            const leg = byStage.get(p.stage);
            const row = { key: p.stage, label: p.label, num: i + 1 };
            if (leg && leg.error) {
                row.state = 'failed';
                row.detail = leg.error;
                row.css = 'step step-failed';
                return row;
            }
            if (leg) {
                const bits = [];
                if (leg.wallMs) bits.push(`${(leg.wallMs / 1000).toFixed(1)}s`);
                if (leg.produced !== null && leg.produced !== undefined) bits.push(`${leg.produced}`);
                row.state = 'done';
                row.detail = bits.join(' · ');
                row.css = 'step step-done';
                return row;
            }
            if (i < lastDone) {
                row.state = 'skipped';
                row.detail = 'not needed';
                row.css = 'step step-skipped';
                return row;
            }
            if (i === lastDone + 1 && this.runKey && !finished) {
                row.state = 'running';
                row.detail = 'working';
                row.css = 'step step-running';
                return row;
            }
            row.state = 'waiting';
            row.detail = '';
            row.css = 'step step-waiting';
            return row;
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
