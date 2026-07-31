/**
 * One call, one snapshot, for the AAO Pipeline (internal) view.
 *
 * **Internal.** This shows candidates, and candidates never appear on a seller surface —
 * they are the decision log, including every proposition nothing was said about. The seller
 * Surface is a later and different thing: one comprehensive current-state record per
 * opportunity per seller, derived, no citation, no actor, no precedence. Nothing here is
 * that, and nothing here should be mistaken for it.
 *
 * Read-only. It writes nothing, and it deliberately holds no state of its own — every field
 * it returns is rebuilt from the rows on each call, so the view cannot drift from the org
 * the way a cached projection would.
 *
 * Display formatting is done here rather than in the template, so the component stays dumb
 * and there is exactly one place where a verdict becomes a colour.
 */
public with sharing class AAO_PipelineViewController {
    private static final Integer SNIPPET = 90;

    @AuraEnabled
    public static Snapshot getSnapshot(Id opportunityId) {
        // A missing record id means the component is misconfigured, not that the deal is
        // empty. Returning an empty snapshot here would dress a wiring fault up as a true
        // statement about the opportunity, which is the exact confusion the empty state
        // exists to prevent.
        if (opportunityId == null) {
            throw new AuraHandledException(
                'No opportunity was supplied. This view is bound to an Opportunity record ' +
                'page; an empty record id is a configuration fault, not an empty deal.'
            );
        }
        try {
            return build(opportunityId);
        } catch (Exception e) {
            // A view that fails silently is worse than one that says why.
            throw new AuraHandledException(
                e.getTypeName() + ': ' + e.getMessage()
            );
        }
    }

    // ==================================================================== the shape

    public class Snapshot {
        @AuraEnabled
        public String opportunityName;
        @AuraEnabled
        public String generatedAt;
        @AuraEnabled
        public List<SourceRow> sources = new List<SourceRow>();
        @AuraEnabled
        public Integer pendingCount = 0;
        @AuraEnabled
        public Boolean hasPending = false;
        @AuraEnabled
        public CandidateBlock candidates = new CandidateBlock();
        @AuraEnabled
        public List<ClaimRow> claims = new List<ClaimRow>();
        @AuraEnabled
        public List<AnswerRow> answers = new List<AnswerRow>();
        @AuraEnabled
        public FlagBlock flags = new FlagBlock();
        @AuraEnabled
        public ProjectionBlock projection = new ProjectionBlock();
        @AuraEnabled
        public Boolean isEmpty = false;
    }

    public class SourceRow {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String sourceRef;
        @AuraEnabled
        public String origin;
        @AuraEnabled
        public String diarization;
        @AuraEnabled
        public String occurred;
        @AuraEnabled
        public Integer claimCount;
        /** True while the artifact has landed and nothing has adjudicated it yet. */
        @AuraEnabled
        public Boolean pending;
        @AuraEnabled
        public String status;
    }

    public class OutcomeCount {
        @AuraEnabled
        public String outcome;
        @AuraEnabled
        public Integer count;

        public OutcomeCount(String outcome, Integer count) {
            this.outcome = outcome;
            this.count = count;
        }
    }

    public class CandidateBlock {
        /** The pass is one artifact's adjudication, so the latest pass is the latest artifact. */
        @AuraEnabled
        public String latestPassLabel;
        @AuraEnabled
        public List<OutcomeCount> latest = new List<OutcomeCount>();
        @AuraEnabled
        public Integer latestTotal = 0;
        @AuraEnabled
        public List<OutcomeCount> total = new List<OutcomeCount>();
        @AuraEnabled
        public Integer grandTotal = 0;
    }

    public class ClaimRow {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String before;
        @AuraEnabled
        public String after;
        @AuraEnabled
        public String outcome;
        @AuraEnabled
        public String occurred;
        @AuraEnabled
        public String recorded;
        @AuraEnabled
        public String snippet;
        @AuraEnabled
        public String sourceRef;
        @AuraEnabled
        public String actor;
        @AuraEnabled
        public String theme;
    }

    public class AnswerRow {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String proposition;
        @AuraEnabled
        public String verdict;
        @AuraEnabled
        public String theme;
        @AuraEnabled
        public String covered;
        @AuraEnabled
        public String missing;
        @AuraEnabled
        public Boolean complete;
        @AuraEnabled
        public String establishedBy;
        @AuraEnabled
        public String publicationState;
    }

    public class FlagBlock {
        @AuraEnabled
        public Integer count = 0;
        @AuraEnabled
        public Boolean hasAny = false;
        @AuraEnabled
        public String sentence;
    }

    public class ProjectionBlock {
        @AuraEnabled
        public String label = 'off';
        @AuraEnabled
        public String sentence;
    }

    // ===================================================================== the build

    private static Snapshot build(Id opportunityId) {
        Snapshot s = new Snapshot();
        s.generatedAt = System.now().format('HH:mm:ss');

        List<Opportunity> opps = [
            SELECT Id, Name FROM Opportunity WHERE Id = :opportunityId LIMIT 1
        ];
        s.opportunityName = opps.isEmpty() ? '' : opps[0].Name;

        // ---- claims first: the sources block needs to know which artifacts produced one
        Map<Id, Integer> claimsBySource = new Map<Id, Integer>();
        for (AAO_Claim__c c : [
            SELECT
                Id,
                Name,
                AAO_Source__c,
                AAO_Verdict_Before__c,
                AAO_Verdict_After__c,
                AAO_Outcome__c,
                AAO_Actor__c,
                AAO_Spans__c,
                AAO_Evidence_Occurred__c,
                AAO_Recorded_At__c,
                AAO_Source__r.AAO_Source_Ref__c
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :opportunityId
            ORDER BY AAO_Evidence_Occurred__c ASC, AAO_Recorded_At__c ASC, Id ASC
        ]) {
            claimsBySource.put(
                c.AAO_Source__c,
                claimsBySource.containsKey(c.AAO_Source__c)
                    ? claimsBySource.get(c.AAO_Source__c) + 1
                    : 1
            );

            ClaimRow r = new ClaimRow();
            r.id = c.Id;
            r.name = c.Name;
            r.before = c.AAO_Verdict_Before__c == null ? '—' : c.AAO_Verdict_Before__c;
            r.after = c.AAO_Verdict_After__c;
            r.outcome = c.AAO_Outcome__c;
            r.actor = c.AAO_Actor__c;
            r.occurred = c.AAO_Evidence_Occurred__c == null
                ? ''
                : c.AAO_Evidence_Occurred__c.formatGmt('d MMM yyyy');
            r.recorded = c.AAO_Recorded_At__c == null
                ? ''
                : c.AAO_Recorded_At__c.format('HH:mm:ss');
            r.sourceRef = c.AAO_Source__r == null ? '' : c.AAO_Source__r.AAO_Source_Ref__c;
            r.snippet = firstSpan(c.AAO_Spans__c);
            r.theme = theme(c.AAO_Verdict_After__c);
            s.claims.add(r);
        }

        // ---- sources, in the order the evidence happened
        Id latestSourceId;
        String latestSourceRef;
        for (AAO_Source__c src : [
            SELECT
                Id,
                Name,
                AAO_Source_Ref__c,
                AAO_Origin__c,
                AAO_Diarization__c,
                AAO_Evidence_Occurred__c
            FROM AAO_Source__c
            WHERE AAO_Opportunity__c = :opportunityId
            ORDER BY AAO_Evidence_Occurred__c ASC, CreatedDate ASC
        ]) {
            SourceRow r = new SourceRow();
            r.id = src.Id;
            r.name = src.Name;
            r.sourceRef = src.AAO_Source_Ref__c;
            r.origin = src.AAO_Origin__c;
            r.diarization = src.AAO_Diarization__c;
            r.occurred = src.AAO_Evidence_Occurred__c == null
                ? ''
                : src.AAO_Evidence_Occurred__c.formatGmt('d MMM yyyy');
            r.claimCount = claimsBySource.containsKey(src.Id) ? claimsBySource.get(src.Id) : 0;
            // Pending means the artifact is stored and adjudication has not landed. It is
            // the state the whole async path exists to make visible.
            r.pending = r.claimCount == 0;
            r.status = r.pending ? 'PENDING' : 'Adjudicated';
            if (r.pending) {
                s.pendingCount++;
            }
            s.sources.add(r);
            latestSourceId = src.Id;
            latestSourceRef = src.AAO_Source_Ref__c;
        }
        s.hasPending = s.pendingCount > 0;

        // ---- candidates, latest pass and total
        s.candidates.latestPassLabel = latestSourceRef == null ? '—' : latestSourceRef;
        for (AggregateResult ar : [
            SELECT AAO_Outcome__c o, COUNT(Id) n
            FROM AAO_Candidate__c
            WHERE AAO_Opportunity__c = :opportunityId
            GROUP BY AAO_Outcome__c
            ORDER BY COUNT(Id) DESC
        ]) {
            Integer n = (Integer) ar.get('n');
            s.candidates.total.add(new OutcomeCount((String) ar.get('o'), n));
            s.candidates.grandTotal += n;
        }
        if (latestSourceId != null) {
            for (AggregateResult ar : [
                SELECT AAO_Outcome__c o, COUNT(Id) n
                FROM AAO_Candidate__c
                WHERE AAO_Opportunity__c = :opportunityId AND AAO_Source__c = :latestSourceId
                GROUP BY AAO_Outcome__c
                ORDER BY COUNT(Id) DESC
            ]) {
                Integer n = (Integer) ar.get('n');
                s.candidates.latest.add(new OutcomeCount((String) ar.get('o'), n));
                s.candidates.latestTotal += n;
            }
        }

        // ---- answers
        for (AAO_Answer__c a : [
            SELECT
                Id,
                Name,
                AAO_Verdict__c,
                AAO_Element_Coverage__c,
                AAO_Established_By__c,
                AAO_Publication_State__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Short__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :opportunityId
            ORDER BY Name ASC
        ]) {
            AnswerRow r = new AnswerRow();
            r.id = a.Id;
            r.name = a.Name;
            r.code = a.AAO_Evidence_Contract__r == null
                ? ''
                : a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
            r.proposition = a.AAO_Evidence_Contract__r == null
                ? ''
                : a.AAO_Evidence_Contract__r.AAO_Proposition_Short__c;
            r.verdict = a.AAO_Verdict__c;
            r.theme = theme(a.AAO_Verdict__c);
            r.establishedBy = a.AAO_Established_By__c;
            r.publicationState = a.AAO_Publication_State__c;

            AAO_Model.Coverage cov = AAO_Model.parseCoverage(a.AAO_Element_Coverage__c);
            r.covered = cov.covered.isEmpty() ? '—' : String.join(cov.covered, ', ');
            r.missing = cov.missing.isEmpty() ? '—' : String.join(cov.missing, ', ');
            r.complete = cov.isFull();
            s.answers.add(r);
        }

        // ---- flags
        s.flags.count = [SELECT COUNT() FROM AAO_Flag__c WHERE AAO_Opportunity__c = :opportunityId];
        s.flags.hasAny = s.flags.count > 0;
        s.flags.sentence = s.flags.hasAny
            ? 'Flags standing against this opportunity.'
            : 'No flags. Nothing raises them yet — the object and its law exist, the raise path does not. An empty list here is the honest state, not a clean bill of health.';

        // ---- projection, off
        s.projection.sentence =
            'Projection is outbound and not built. The compare-and-swap watermark fields ' +
            'exist on the answer and are null. Nothing has been written back to any ' +
            'customer record.';

        s.isEmpty = s.sources.isEmpty() && s.claims.isEmpty() && s.answers.isEmpty();
        return s;
    }

    // ------------------------------------------------------------------- internals

    /** The first quote a claim rests on, short enough to read in a row. */
    private static String firstSpan(String spansJson) {
        List<AAO_Model.Span> spans = AAO_Model.parseSpans(spansJson).spans;
        if (spans.isEmpty()) {
            return '';
        }
        String q = spans[0].quote;
        if (String.isBlank(q)) {
            return '';
        }
        return q.length() <= SNIPPET ? q : q.substring(0, SNIPPET - 1) + '…';
    }

    /**
     * The one place a verdict becomes a colour. Returns the finished class string, because
     * an LWC template cannot concatenate and a second place that decides this would be a
     * second place to get it wrong.
     */
    private static String theme(String verdict) {
        if (verdict == 'TRUE') {
            return 'slds-badge slds-theme_success';
        }
        if (verdict == 'FALSE') {
            return 'slds-badge slds-theme_error';
        }
        return 'slds-badge slds-theme_warning';
    }
}
