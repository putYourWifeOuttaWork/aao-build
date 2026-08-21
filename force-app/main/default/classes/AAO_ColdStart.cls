/**
 * THE COLD START. A deal that has never been opened in any Altify surface gets its plan, so a
 * transcript can be read against a rubric that exists.
 *
 * ===== THE BAR THIS IS BUILT TO, from the hundred-seventy-third.
 *
 * *"A deal created minutes ago, of a Type that resolves to a plan type, never opened in ANY
 * Altify surface, receives ONE transcript, and afterwards the wrapper exists, the process and
 * stage are assigned, the rubric for THAT deal is resolved... with NO HUMAN STEP anywhere."*
 * Matthew refused a hand-assisted stand-in and was right to: a rehearsal that works because
 * somebody reached into the org by hand proves nothing about the product, and the manual step
 * would have been invisible in the result.
 *
 * ===== THE GATE THIS RESTS ON IS MEASURED, NOT ASSUMED.
 *
 * Everything here presumes a wrapper can exist without a human. That was never proven until it
 * was tested from Apex: `a0yWD000001ehwvYAA` was created by us on a deal that had none, and the
 * vendor furnished it exactly as it furnishes its own - qualification stage derived, progress
 * initialized, stamps set, weeks computed. **We can create it.** The cold start is ours end to
 * end rather than a request to a surface only a human can open.
 *
 * ===== WHAT THIS WILL NOT DO.
 *
 * **It never chooses a process.** The process is RESOLVED from the deal's Type through the
 * vendor's own mapping, read per org and per run, because an 80%-org's mapping is not ours and
 * a guessed plan is a rubric nobody agreed to. A Type with no mapping gets a stated refusal.
 *
 * **It never repairs a de-linked wrapper.** A wrapper that LOST its process on a stage advance
 * (the 166th) is a different state from one that never had a plan, and re-writing it would
 * paper over the vendor's own behaviour with our guess about what it meant.
 *
 * **It never moves a stage on a deal that has one.** Advancing is the seller's act through the
 * vendor's gate, which is the whole point of the gate. This writes the FIRST stage onto a deal
 * that has no plan at all - giving an unplanned deal its plan, which is what opening the vendor
 * UI would have done - and nothing else, ever.
 */
public with sharing class AAO_ColdStart {
    public class ColdStartException extends Exception {
    }

    public static final String WRITER = 'AAO_Cold_Start';
    public static final String WRITER_VERSION = '1.0.0';

    public class Outcome {
        public Boolean wrapperCreated = false;
        public Boolean planAssigned = false;
        public Id wrapperId;
        public String processName;
        public String stageName;
        public Integer ordinal;
        /** The rubric resolved FOR THIS DEAL, read rather than written. */
        public Integer assessmentQuestions = 0;
        public Integer qualifiers = 0;
        public List<String> notes = new List<String>();

        public override String toString() {
            return 'cold start: wrapperCreated=' + wrapperCreated +
                ' planAssigned=' + planAssigned +
                ' process=' + processName + ' stage=' + stageName + ' ordinal=' + ordinal +
                ' rubric=' + assessmentQuestions + ' questions/' + qualifiers + ' qualifiers' +
                (notes.isEmpty() ? '' : ' | ' + String.join(notes, ' | '));
        }
    }

    /**
     * Give this deal its plan if it has none. Idempotent: a second run neither re-assigns nor
     * creates a second wrapper, because the write is once and the condition is "carries no
     * process" rather than "we have not run yet".
     */
    public static Outcome ensurePlan(Id opportunityId) {
        Outcome o = new Outcome();
        if (opportunityId == null) {
            return o;
        }
        Opportunity deal = [SELECT Id, Type FROM Opportunity WHERE Id = :opportunityId];

        List<ALTF__Opportunity__c> wrappers = [
            SELECT Id, ALTF__Sales_Process__c, ALTF__Sales_Process__r.Name,
                   ALTF__Sales_Process_Stage__r.Name, ALTF__Sales_Process_Stage_Name__c
            FROM ALTF__Opportunity__c
            WHERE ALTF__Opportunity__c = :opportunityId
            ORDER BY CreatedDate ASC
        ];

        for (ALTF__Opportunity__c w : wrappers) {
            if (w.ALTF__Sales_Process__c != null) {
                // ALREADY PLANNED. Not ours to touch, whoever assigned it.
                o.wrapperId = w.Id;
                o.processName = w.ALTF__Sales_Process__r.Name;
                o.stageName = w.ALTF__Sales_Process_Stage__r == null
                    ? w.ALTF__Sales_Process_Stage_Name__c
                    : w.ALTF__Sales_Process_Stage__r.Name;
                o.ordinal = AAO_Flags.stageOrdinalOf(opportunityId);
                o.notes.add('This deal already carries a plan. Nothing written.');
                readRubric(deal, o);
                return o;
            }
        }
        // A WRAPPER THAT LOST ITS PROCESS IS NOT REPAIRED HERE. If any wrapper exists at all and
        // none carries a process, we cannot tell "never planned" from "de-linked on advance"
        // without more than this method knows, and the 173rd rules the second is not ours to fix.
        if (!wrappers.isEmpty() && everAdvanced(opportunityId)) {
            o.wrapperId = wrappers[0].Id;
            o.notes.add(
                'A wrapper stands with no process on a deal that has advanced before, which is ' +
                'the de-link state rather than an unplanned deal. Not repaired here, by ruling.'
            );
            return o;
        }

        Plan plan = resolvePlan(deal, o);
        if (plan == null) {
            return o;
        }

        ALTF__Opportunity__c wrapper;
        if (wrappers.isEmpty()) {
            wrapper = new ALTF__Opportunity__c(ALTF__Opportunity__c = opportunityId);
            insert wrapper;
            o.wrapperCreated = true;
            // EVERY ROW WE MAKE IS ENUMERATED, and a vendor object is not an exception - the
            // 173rd's item 4(v), and the omission my own gate probe made before it was caught.
            AAO_CreatedRows.record(
                wrapper.Id, WRITER + '@' + WRITER_VERSION, 'altify-opportunity-wrapper',
                'Created so this deal could carry a plan; it had no Altify Opportunity at all.',
                null, null
            );
        } else {
            wrapper = wrappers[0];
        }

        update new ALTF__Opportunity__c(
            Id = wrapper.Id,
            ALTF__Sales_Process__c = plan.processId,
            ALTF__Sales_Process_Stage__c = plan.firstStageId
        );
        o.planAssigned = true;
        o.wrapperId = wrapper.Id;
        o.processName = plan.processName;
        o.stageName = plan.firstStageName;
        o.ordinal = AAO_Flags.stageOrdinalOf(opportunityId);
        readRubric(deal, o);
        return o;
    }

    // ------------------------------------------------------------------ internals

    private class Plan {
        Id processId;
        String processName;
        Id firstStageId;
        String firstStageName;
    }

    /**
     * THE PROCESS IS RESOLVED, NEVER CHOSEN. Through the vendor's own mapping, read per org and
     * per run: an 80%-org's mapping is not ours, and our seed is not an assumption anyone else
     * has to share.
     */
    private static Plan resolvePlan(Opportunity deal, Outcome o) {
        if (String.isBlank(deal.Type)) {
            o.notes.add(
                'This deal carries no Type, so no plan can be resolved through the vendor\'s ' +
                'mapping. Nothing written, and nothing guessed.'
            );
            return null;
        }
        List<ALTF__Sales_Process_Mapping__c> maps = [
            SELECT ALTF__Sales_Process__c, ALTF__Sales_Process__r.Name
            FROM ALTF__Sales_Process_Mapping__c
            WHERE ALTF__Record_Type__c = :deal.Type
            LIMIT 1
        ];
        if (maps.isEmpty()) {
            o.notes.add(
                'No sales-process mapping in this org covers the Type "' + deal.Type +
                '", so this deal has no plan to be given. A stated refusal, never a guess.'
            );
            return null;
        }
        List<ALTF__Sales_Process_Stage__c> stages = [
            SELECT Id, Name FROM ALTF__Sales_Process_Stage__c
            WHERE ALTF__Sales_Process__c = :maps[0].ALTF__Sales_Process__c
              AND ALTF__SortOrder__c != null
            ORDER BY ALTF__SortOrder__c ASC
            LIMIT 1
        ];
        if (stages.isEmpty()) {
            o.notes.add(
                'The mapped process "' + maps[0].ALTF__Sales_Process__r.Name +
                '" carries no ordered stages, so there is no first stage to open at.'
            );
            return null;
        }
        Plan p = new Plan();
        p.processId = maps[0].ALTF__Sales_Process__c;
        p.processName = maps[0].ALTF__Sales_Process__r.Name;
        p.firstStageId = stages[0].Id;
        p.firstStageName = stages[0].Name;
        return p;
    }

    /**
     * THE RUBRIC IS A READ, NOT A WRITE. What this deal's plan asks of it: its assessment
     * questions through the plan type, its qualifiers through the process's stage junctions.
     * Reported so a caller can see the rubric resolved, never materialized as rows.
     */
    private static void readRubric(Opportunity deal, Outcome o) {
        try {
            o.assessmentQuestions = AAO_ProcessContracts.discoverQuestions(deal.Id).size();
        } catch (Exception e) {
            o.notes.add('The assessment rubric could not be read: ' + e.getMessage().abbreviate(120));
        }
        // Two hops, because a semi-join cannot cross two levels of relationship. The address
        // law again: the platform's own rule decides the shape, not what reads tidiest.
        Set<Id> processes = new Set<Id>();
        for (ALTF__Opportunity__c w : [
            SELECT ALTF__Sales_Process__c FROM ALTF__Opportunity__c
            WHERE ALTF__Opportunity__c = :deal.Id AND ALTF__Sales_Process__c != null
        ]) {
            processes.add(w.ALTF__Sales_Process__c);
        }
        if (processes.isEmpty()) {
            return;
        }
        Set<Id> stageIds = new Set<Id>();
        for (ALTF__Sales_Process_Stage__c st : [
            SELECT Id FROM ALTF__Sales_Process_Stage__c
            WHERE ALTF__Sales_Process__c IN :processes
        ]) {
            stageIds.add(st.Id);
        }
        o.qualifiers = [
            SELECT COUNT() FROM ALTF__Sales_Process_Stage_Qualifier__c
            WHERE ALTF__Sales_Process_Stage__c IN :stageIds
        ];
    }

    /** Has this deal ever moved through the vendor's gate? Its history is the only witness. */
    private static Boolean everAdvanced(Id opportunityId) {
        return [
            SELECT COUNT() FROM OpportunityFieldHistory
            WHERE OpportunityId = :opportunityId AND Field = 'StageName'
        ] > 0;
    }
}
