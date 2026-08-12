/**
 * THE RUN INSPECTOR. What happened on this deal, and how do I get from a value back to the words.
 *
 * Matthew's primary use, ruled at the fifty-seventh stamp: *"see and reverse-engineer what happened
 * on an opportunity back to source"*. This is the verification sheet's walk, done by the machine
 * instead of by hand: **value to answer to claim to pair to byte-located quote to source.**
 *
 * **THE REFUSALS RIDE BESIDE THE UPHELD VALUES, and that is the point rather than a nicety.** A
 * surface that shows only what stood tells you what the machine believes; the refusals are where
 * trust is earned, because they are where you can see it declining to assert something it could
 * have asserted. A reviewer who cannot see the refusals cannot tell a careful machine from a lucky
 * one.
 *
 * READ-ONLY, STRUCTURALLY. There is no DML anywhere in this class and no method that could be
 * mistaken for one. An inspector that could change what it inspects is not an inspector.
 */
public with sharing class AAO_RunInspector {
    // ------------------------------------------------------------------------ the shapes

    public class RunOption {
        @AuraEnabled public String runKey;
        @AuraEnabled public String label;
        @AuraEnabled public Datetime latestActivity;
        @AuraEnabled public Integer pairCount;
    }

    public class StageCount {
        @AuraEnabled public String stage;
        @AuraEnabled public Integer count;
        @AuraEnabled public String meaning;
        public StageCount(String stage, Integer count, String meaning) {
            this.stage = stage;
            this.count = count;
            this.meaning = meaning;
        }
    }

    /** One thing the run put in front of a human, with everything behind it. */
    public class Trace {
        @AuraEnabled public String id;
        @AuraEnabled public String surface;
        @AuraEnabled public String person;
        @AuraEnabled public String dimension;
        @AuraEnabled public String value;
        @AuraEnabled public String verdict;
        @AuraEnabled public String contractCode;
        @AuraEnabled public String question;
        @AuraEnabled public String quote;
        @AuraEnabled public Integer startOffset;
        @AuraEnabled public Integer endOffset;
        @AuraEnabled public String sourceRef;
        @AuraEnabled public Datetime occurred;
        @AuraEnabled public String refusalNote;
        @AuraEnabled public Boolean upheld;
    }

    public class RunView {
        @AuraEnabled public String runKey;
        @AuraEnabled public List<StageCount> stages = new List<StageCount>();
        @AuraEnabled public List<Trace> upheld = new List<Trace>();
        @AuraEnabled public List<Trace> refused = new List<Trace>();
        @AuraEnabled public String note;
    }

    // ------------------------------------------------------------------------ the reads

    /**
     * The runs that touched this deal, newest first. The picker's contents.
     *
     * Grouped in Apex rather than SOQL because the run key is a text field and the vendor-quirk
     * lesson from the board work applies generally: an aggregate that throws at runtime rather
     * than compile time is a worse trade than a loop over a bounded set.
     */
    @AuraEnabled(cacheable=true)
    public static List<RunOption> runsFor(Id opportunityId) {
        Map<String, RunOption> byKey = new Map<String, RunOption>();
        for (AAO_Pair__c p : [
            SELECT AAO_Run_Key__c, CreatedDate
            FROM AAO_Pair__c
            WHERE AAO_Source__r.AAO_Opportunity__c = :opportunityId
                AND AAO_Run_Key__c != null
            ORDER BY CreatedDate DESC
            LIMIT 5000
        ]) {
            RunOption o = byKey.get(p.AAO_Run_Key__c);
            if (o == null) {
                o = new RunOption();
                o.runKey = p.AAO_Run_Key__c;
                o.label = p.AAO_Run_Key__c;
                o.latestActivity = p.CreatedDate;
                o.pairCount = 0;
                byKey.put(o.runKey, o);
            }
            o.pairCount++;
        }
        List<RunOption> out = byKey.values();
        // Newest first: the default pick is the latest run, which is what a tester wants.
        for (Integer i = 0; i < out.size(); i++) {
            for (Integer j = i + 1; j < out.size(); j++) {
                if (out[j].latestActivity > out[i].latestActivity) {
                    RunOption t = out[i];
                    out[i] = out[j];
                    out[j] = t;
                }
            }
        }
        return out;
    }

    /**
     * One run, its stage counts, and every trace behind them.
     *
     * The counts are the pipeline's own vocabulary rather than invented labels, because a tester
     * comparing this against a run report must see the same words in both places.
     */
    @AuraEnabled(cacheable=true)
    public static RunView inspect(Id opportunityId, String runKey) {
        RunView v = new RunView();
        v.runKey = runKey;
        if (String.isBlank(runKey)) {
            v.note = 'No run selected.';
            return v;
        }

        Integer located = [
            SELECT COUNT() FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.LOCATED
        ];
        List<AAO_Pair__c> identified = [
            SELECT Id, AAO_Pair_Ref__c, AAO_Disposition__c, AAO_Verification__c,
                AAO_Verification_Note__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Text__c,
                AAO_Person__r.AAO_Display_Name__c,
                AAO_Source__r.AAO_Source_Ref__c, AAO_Source__r.AAO_Evidence_Occurred__c,
                AAO_Located_Pair__r.AAO_Answer_Text__c,
                AAO_Located_Pair__r.AAO_Start_Offset__c,
                AAO_Located_Pair__r.AAO_End_Offset__c,
                AAO_Located_Pair__r.AAO_Meaning__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.IDENTIFIED
            ORDER BY AAO_Evidence_Contract__r.AAO_Proposition_Code__c, AAO_Pair_Ref__c
        ];

        Integer upheldCount = 0;
        Integer refusedCount = 0;
        for (AAO_Pair__c p : identified) {
            Trace t = traceOf(p);
            if (t.upheld == true) {
                upheldCount++;
                v.upheld.add(t);
            } else if (p.AAO_Verification__c == 'Refused') {
                refusedCount++;
                v.refused.add(t);
            }
        }

        Integer projected = [
            SELECT COUNT() FROM ALTF__Contact_Map_Details__c
            WHERE ALTF__Opportunity__c = :opportunityId
        ];
        Integer cards = [
            SELECT COUNT() FROM ALTF__Insight_Card__c
            WHERE ALTF__Opportunity__c = :opportunityId
        ];

        v.stages.add(new StageCount('Located', located,
            'Words the reads found and byte-located against the frozen transcript.'));
        v.stages.add(new StageCount('Identified', identified.size(),
            'Located pairs the resolution stage kept, merged and attached to a speaker.'));
        v.stages.add(new StageCount('Upheld', upheldCount,
            'Establishments the blind verifier let stand.'));
        v.stages.add(new StageCount('Refused', refusedCount,
            'Establishments the verifier declined. This is where trust is earned.'));
        v.stages.add(new StageCount('Map rows', projected,
            'People placed on the relationship map for this deal, all runs.'));
        v.stages.add(new StageCount('Cards', cards,
            'Insight cards standing on this deal, all runs.'));

        if (identified.isEmpty()) {
            v.note = 'This run located ' + located + ' pairs and identified none. ' +
                'A run with locations and no identifications stopped at resolution.';
        }
        return v;
    }

    /**
     * THE WALK-BACK, one row: value to answer to claim to pair to quote to source.
     *
     * The offsets travel with the quote because they are what makes the claim checkable: a reader
     * can go to those bytes in the transcript and read the words for themselves, which is the
     * whole difference between a citation and an assertion.
     */
    private static Trace traceOf(AAO_Pair__c p) {
        Trace t = new Trace();
        t.id = p.Id;
        t.surface = 'pair ' + p.AAO_Pair_Ref__c;
        t.person = p.AAO_Person__r == null ? null : p.AAO_Person__r.AAO_Display_Name__c;
        t.contractCode = p.AAO_Evidence_Contract__r == null
            ? null
            : p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
        t.question = p.AAO_Evidence_Contract__r == null
            ? null
            : p.AAO_Evidence_Contract__r.AAO_Proposition_Text__c;
        t.dimension = AAO_P8Codes.dimensionOf(t.contractCode);
        t.value = p.AAO_Located_Pair__r == null ? null : p.AAO_Located_Pair__r.AAO_Meaning__c;
        t.verdict = p.AAO_Verification__c;
        t.upheld = p.AAO_Verification__c == 'Upheld';
        t.refusalNote = p.AAO_Verification_Note__c;
        if (p.AAO_Located_Pair__r != null) {
            t.quote = p.AAO_Located_Pair__r.AAO_Answer_Text__c;
            t.startOffset = p.AAO_Located_Pair__r.AAO_Start_Offset__c == null
                ? null
                : Integer.valueOf(p.AAO_Located_Pair__r.AAO_Start_Offset__c);
            t.endOffset = p.AAO_Located_Pair__r.AAO_End_Offset__c == null
                ? null
                : Integer.valueOf(p.AAO_Located_Pair__r.AAO_End_Offset__c);
        }
        if (p.AAO_Source__r != null) {
            t.sourceRef = p.AAO_Source__r.AAO_Source_Ref__c;
            t.occurred = p.AAO_Source__r.AAO_Evidence_Occurred__c;
        }
        return t;
    }
}
