import { LightningElement, api, wire } from 'lwc';
import runsFor from '@salesforce/apex/AAO_RunInspector.runsFor';
import inspect from '@salesforce/apex/AAO_RunInspector.inspect';

/**
 * THE RUN INSPECTOR, v2. Pick a run, read the pipeline drawn in order, open any establishment
 * under its own row and read the numbered path it took from the call to the projected value.
 *
 * Read-only by construction: it calls two cacheable Apex reads and holds no write path at all.
 *
 * WHAT THE APEX OWNS AND WHAT THIS OWNS, so the split does not drift: Apex owns the DATA and
 * every label composed out of data (titles, counts, the path's own words), because those are the
 * surface's vocabulary and a template stitching them would be inventing wording nobody ruled.
 * This file owns DISPLAY STATE only: which person is collapsed, whose refusals are showing,
 * which row is open. Wired data is frozen, so every decoration below copies rather than mutates.
 */
export default class AaoRunInspector extends LightningElement {
    @api recordId;
    runKey;
    view;
    runs = [];
    error;

    /** One open at a time, so the reader never loses the place they clicked from. */
    selectedId;
    /** Names, not booleans: the wire can replace the view and these still mean something. */
    collapsedPeople = [];
    /** REFUSALS ARE COLLAPSED BY DEFAULT, which is a default and never a hiding. */
    peopleShowingRefusals = [];
    showPerformance = false;

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
            this.selectedId = undefined;
            this.collapsedPeople = [];
            this.peopleShowingRefusals = [];
            this.error = undefined;
        } else if (error) {
            this.error = this.messageOf(error);
        }
    }

    // ------------------------------------------------------------------ what exists yet

    get runOptions() {
        return this.runs.map((r) => ({
            label: `${r.runKey}  (${r.pairCount} pairs)`,
            value: r.runKey
        }));
    }

    get hasRuns() {
        return this.runs && this.runs.length > 0;
    }

    /**
     * THE GUARD. The two wires resolve independently, so there is a moment where the run list
     * has arrived and the view has not. The template reads the view in that moment, and reading
     * off undefined threw the component error Matthew saw at the sixty-fourth stamp.
     *
     * The consequence was worse than the error: the empty-state message and the thrown error
     * appeared TOGETHER, so the surface told him there was nothing to see while simultaneously
     * failing to show what was there. A surface that does not know it is broken is the thing
     * this guard exists to prevent, so nothing view-dependent renders until the view is here.
     */
    get hasView() {
        return !!(this.view && this.view.pipeline);
    }

    get loading() {
        return this.hasRuns && !this.hasView && !this.error;
    }

    get pipeline() {
        return this.hasView ? this.view.pipeline : [];
    }

    get note() {
        return this.hasView ? this.view.note : null;
    }

    /** A contract with no plain-language name shows its code, and says so. Never silent. */
    get defects() {
        return this.hasView && this.view.defects && this.view.defects.length
            ? this.view.defects
            : null;
    }

    get performanceLabel() {
        return this.showPerformance ? 'Hide performance' : 'Show performance';
    }

    get performanceNote() {
        return this.hasView ? this.view.performanceNote : null;
    }

    get performanceSummary() {
        return this.hasView ? this.view.performanceSummary : null;
    }

    /**
     * The journalled legs, or an empty list. NOTHING HERE COMPUTES A NUMBER: every value on a
     * line was measured in the transaction that did the work, and the only thing added is the
     * class that marks a governor past 80 percent of its ceiling.
     */
    get performanceLines() {
        if (!this.hasView || !this.view.performance) {
            return [];
        }
        return this.view.performance.map((p, i) => ({
            ...p,
            key: `${i}-${p.stage}`,
            rowClass: p.nearACeiling ? 'perf-row perf-row_near' : 'perf-row'
        }));
    }

    get hasPeople() {
        return this.hasView && this.view.people && this.view.people.length > 0;
    }

    // ------------------------------------------------------------------ the decorated rows

    /**
     * Establishments grouped under the person they are about, decorated with display state.
     *
     * Rebuilt on every render rather than cached, because the inputs are a handful of arrays and
     * a stale cache on a testing surface is a worse bug than the work of rebuilding it.
     */
    get groups() {
        if (!this.hasPeople) {
            return [];
        }
        return this.view.people.map((g) => {
            const expanded = !this.collapsedPeople.includes(g.name);
            const showRefused = this.peopleShowingRefusals.includes(g.name);
            return {
                key: g.name,
                name: g.name,
                internal: g.internal,
                internalMark: g.internal ? `Internal speaker: ${g.internalReason}` : null,
                countLabel: g.countLabel,
                expanded,
                toggleIcon: expanded ? 'utility:chevrondown' : 'utility:chevronright',
                headClass: g.internal ? 'person-head person-head_internal' : 'person-head',
                hasRefused: g.refusedCount > 0,
                showRefused,
                refusedLabel: `${g.refusedLabel} — ${showRefused ? 'hide' : 'show'}`,
                rows: g.upheld.map((t) => this.decorate(t)),
                refusedRows: showRefused ? g.refused.map((t) => this.decorate(t)) : []
            };
        });
    }

    decorate(t) {
        const open = t.id === this.selectedId;
        const tone = t.upheld ? 'row row_upheld' : 'row row_refused';
        return {
            ...t,
            open,
            rowClass: open ? `${tone} row_open` : tone
        };
    }

    // ------------------------------------------------------------------ the handlers

    handleRunChange(event) {
        this.runKey = event.detail.value;
    }

    /** Clicking the open row closes it; clicking another closes the first. One open at a time. */
    handleSelect(event) {
        const id = event.currentTarget.dataset.id;
        this.selectedId = this.selectedId === id ? undefined : id;
    }

    togglePerson(event) {
        const name = event.currentTarget.dataset.name;
        this.collapsedPeople = this.collapsedPeople.includes(name)
            ? this.collapsedPeople.filter((n) => n !== name)
            : [...this.collapsedPeople, name];
    }

    toggleRefused(event) {
        const name = event.currentTarget.dataset.name;
        this.peopleShowingRefusals = this.peopleShowingRefusals.includes(name)
            ? this.peopleShowingRefusals.filter((n) => n !== name)
            : [...this.peopleShowingRefusals, name];
    }

    togglePerformance() {
        this.showPerformance = !this.showPerformance;
    }

    messageOf(error) {
        return (error && error.body && error.body.message) || 'Something failed to load.';
    }
}