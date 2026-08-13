/**
 * One call, one snapshot, for the AAO Pipeline command center.
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
 * and there is exactly one place where a verdict becomes a colour. The component adds
 * navigation URLs from the ids returned here and does nothing else.
 *
 * Spec v1.0 (command center). Items A-H and J are built. Item I is built except for the
 * account-scope grouping, which is structurally impossible in the schema as deployed:
 * `AAO_Opportunity__c` is `required=true` on all five row objects, so no row can carry
 * account grain. See the ACCOUNT CONTEXT note on `buildAccount`.
 */
public with sharing class AAO_PipelineViewController {
    private static final Integer SNIPPET = 90;
    private static final Integer PAGE = 200;

    /**
     * Claims per source, for the Sources panel's pending test. A transaction-scoped static
     * rather than a member of Snapshot, because Snapshot is serialized to the component and
     * this is scaffolding the component has no use for.
     */
    private static Map<Id, Integer> CLAIMS_BY_SOURCE = new Map<Id, Integer>();

    @AuraEnabled
    public static Snapshot getSnapshot(Id recordId) {
        // A missing record id means the component is misconfigured, not that the record is
        // empty. Returning an empty snapshot here would dress a wiring fault up as a true
        // statement about the record, which is the exact confusion the empty state exists
        // to prevent.
        if (recordId == null) {
            throw new AuraHandledException(
                'SERVER: getSnapshot was called with no record id. The component is ' +
                'supposed to make this impossible, so if this text is on screen the ' +
                'component-side guard has failed, which is a different defect from the ' +
                'page never supplying an id.'
            );
        }
        try {
            String prefix = String.valueOf(recordId).substring(0, 3);
            if (prefix == Opportunity.SObjectType.getDescribe().getKeyPrefix()) {
                return buildOpportunity(recordId);
            }
            if (prefix == Account.SObjectType.getDescribe().getKeyPrefix()) {
                return buildAccount(recordId);
            }
            throw new AuraHandledException(
                'This view runs on Opportunity and Account record pages. It was given a ' +
                recordId.getSObjectType() + ' id, which it has no scope rule for.'
            );
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            // A view that fails silently is worse than one that says why.
            throw new AuraHandledException(e.getTypeName() + ': ' + e.getMessage());
        }
    }

    // ==================================================================== the shape

    public class Snapshot {
        @AuraEnabled
        public String context; // 'Opportunity' | 'Account'
        @AuraEnabled
        public Id contextId;
        @AuraEnabled
        public String contextName;
        @AuraEnabled
        public String generatedAt;
        @AuraEnabled
        public Banner banner = new Banner();
        @AuraEnabled
        public List<SourceRow> sources = new List<SourceRow>();
        @AuraEnabled
        public Tally sourcePage = new Tally();
        @AuraEnabled
        public Integer pendingCount = 0;
        @AuraEnabled
        public Boolean hasPending = false;
        @AuraEnabled
        public CandidateBlock candidates = new CandidateBlock();
        @AuraEnabled
        public List<ClaimRow> claims = new List<ClaimRow>();
        @AuraEnabled
        public Tally claimPage = new Tally();
        @AuraEnabled
        public List<PersonGroup> people = new List<PersonGroup>();
        @AuraEnabled
        public Tally answerPage = new Tally();
        @AuraEnabled
        public Integer liveCount = 0;
        @AuraEnabled
        public Integer heldCount = 0;
        @AuraEnabled
        public String publicationLine;
        @AuraEnabled
        public FlagBlock flags = new FlagBlock();
        @AuraEnabled
        public ProjectionBlock projection = new ProjectionBlock();
        @AuraEnabled
        public Boolean isEmpty = false;
        @AuraEnabled
        public String emptyText;
        /** Account context only: the deals these rows belong to, for the grouping headers. */
        @AuraEnabled
        public List<DealHeader> deals = new List<DealHeader>();
        @AuraEnabled
        public Boolean showScope = false;
        @AuraEnabled
        public String scopeNote;
    }

    /** "showing 200 of N" honesty. A silent cap reads exactly like completeness. */
    public class Tally {
        @AuraEnabled
        public Integer shown = 0;
        @AuraEnabled
        public Integer total = 0;
        @AuraEnabled
        public Boolean capped = false;
        @AuraEnabled
        public String line;

        public void seal(Integer shownIn, Integer totalIn) {
            this.shown = shownIn;
            this.total = totalIn;
            this.capped = totalIn > shownIn;
            this.line = this.capped
                ? 'showing ' + shownIn + ' of ' + totalIn
                : String.valueOf(totalIn);
        }
    }

    public class Banner {
        @AuraEnabled
        public Boolean active = false;
        @AuraEnabled
        public Id sourceId;
        @AuraEnabled
        public String sourceRef;
        @AuraEnabled
        public String stage; // arrived | adjudicating | committed
        @AuraEnabled
        public String sentence;
        @AuraEnabled
        public String lastRefreshed;
    }

    public class DealHeader {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String stage;
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
        @AuraEnabled
        public String scope;
        @AuraEnabled
        public Id dealId;
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
        public Id latestPassId;
        @AuraEnabled
        public List<OutcomeCount> latest = new List<OutcomeCount>();
        @AuraEnabled
        public Integer latestTotal = 0;
        @AuraEnabled
        public List<OutcomeCount> total = new List<OutcomeCount>();
        @AuraEnabled
        public Integer grandTotal = 0;
    }

    /** One citation on a claim: what it read, and which element it covers. */
    public class BasisRow {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String citedType;
        @AuraEnabled
        public Id citedId;
        @AuraEnabled
        public String citedLabel;
        @AuraEnabled
        public String coversElement;
        @AuraEnabled
        public Boolean deleted;
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
        /** Two clocks, both labelled, both with a time. */
        @AuraEnabled
        public String occurred;
        @AuraEnabled
        public String recorded;
        @AuraEnabled
        public String snippet;
        @AuraEnabled
        public Id sourceId;
        @AuraEnabled
        public String sourceRef;
        @AuraEnabled
        public String actor;
        @AuraEnabled
        public String theme;
        @AuraEnabled
        public String scope;
        @AuraEnabled
        public Id dealId;
        // ---- depth-one lineage
        @AuraEnabled
        public Id candidateId;
        @AuraEnabled
        public String candidateLabel;
        @AuraEnabled
        public Id answerId;
        @AuraEnabled
        public String answerLabel;
        @AuraEnabled
        public List<BasisRow> bases = new List<BasisRow>();
        @AuraEnabled
        public Boolean hasLineage = false;
    }

    /** One claim as it appears underneath the answer it moved. */
    public class AnswerClaimRow {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String before;
        @AuraEnabled
        public String after;
        @AuraEnabled
        public String occurred;
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
        @AuraEnabled
        public Boolean held;
        @AuraEnabled
        public String rowClass;
        @AuraEnabled
        public String dimension;
        @AuraEnabled
        public String rung;
        @AuraEnabled
        public Boolean projected = false;
        @AuraEnabled
        public String projectedValue;
        @AuraEnabled
        public String projectedAt;
        @AuraEnabled
        public String scope;
        @AuraEnabled
        public Id dealId;
        @AuraEnabled
        public List<AnswerClaimRow> claims = new List<AnswerClaimRow>();
        @AuraEnabled
        public Boolean hasLineage = false;
    }

    /** Answers grouped by the person they are about. This is the adjudication surface. */
    public class PersonGroup {
        @AuraEnabled
        public Id contactId;
        @AuraEnabled
        public String personName;
        @AuraEnabled
        public String subtitle;
        @AuraEnabled
        public Boolean isPerson = false;
        @AuraEnabled
        public List<AnswerRow> answers = new List<AnswerRow>();
    }

    public class FlagRow {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String typeTheme;
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String stateTheme;
        @AuraEnabled
        public Id subjectId;
        @AuraEnabled
        public String subjectName;
        @AuraEnabled
        public String created;
        @AuraEnabled
        public String scope;
        @AuraEnabled
        public Id dealId;
    }

    public class FlagBlock {
        @AuraEnabled
        public Integer count = 0;
        @AuraEnabled
        public Integer standingCount = 0;
        @AuraEnabled
        public Integer clearedCount = 0;
        @AuraEnabled
        public Boolean hasAny = false;
        @AuraEnabled
        public String sentence;
        @AuraEnabled
        public List<FlagRow> rows = new List<FlagRow>();
        @AuraEnabled
        public Tally page = new Tally();
    }

    public class ProjectionRow {
        @AuraEnabled
        public Id answerId;
        @AuraEnabled
        public String answerName;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String dimension;
        @AuraEnabled
        public String modstamp;
        @AuraEnabled
        public Id subjectId;
        @AuraEnabled
        public String subjectName;
        @AuraEnabled
        public Id mapRowId;
        @AuraEnabled
        public String mapRowLabel;
        @AuraEnabled
        public String scope;
        @AuraEnabled
        public Id dealId;
    }

    public class ProjectionBlock {
        @AuraEnabled
        public String label = 'off';
        @AuraEnabled
        public Boolean isOn = false;
        @AuraEnabled
        public String sentence;
        @AuraEnabled
        public List<ProjectionRow> rows = new List<ProjectionRow>();
        /**
         * TWO NUMBERS, SIDE BY SIDE, ruled 4 August. Projected and protected are different
         * facts and collapsing them into one indicator is what produced the `off` confusion:
         * the panel read `off` while a map row was populated, because it counted answers
         * carrying a watermark and the writer never wrote one.
         *
         * Units in the names, per the unit law.
         */
        @AuraEnabled
        public Integer mapRowsWritten = 0;
        /** Rows our values sit on whose backing answers carry no watermark. Any nonzero is an alarm. */
        @AuraEnabled
        public Integer rowsProjectedWithNoWatermark = 0;
        @AuraEnabled
        public Tally page = new Tally();
    }

    // ================================================================ context entry

    private static Snapshot buildOpportunity(Id oppId) {
        Snapshot s = new Snapshot();
        s.context = 'Opportunity';
        s.contextId = oppId;
        s.showScope = false;
        List<Opportunity> opps = [
            SELECT Id, Name, StageName FROM Opportunity WHERE Id = :oppId LIMIT 1
        ];
        s.contextName = opps.isEmpty() ? '' : opps[0].Name;
        s.emptyText =
            'Nothing has arrived on this opportunity yet. No sources, no candidates, no ' +
            'claims, no answers. That is a true statement about the deal, not a loading state.';
        return fill(s, 'AAO_Opportunity__c', oppId);
    }

    /**
     * ACCOUNT CONTEXT, and the one part of spec item I that is not built.
     *
     * The account filter itself is honest and live: every row object carries
     * `AAO_Account__c`, so an Account page shows every row belonging to that account's deals,
     * grouped under per-opportunity headers.
     *
     * **What is deliberately absent is the account-SCOPE group.** The spec asks for
     * account-scope rows first, then deal-scope rows. There is no such thing as an
     * account-scope row in the schema as deployed: `AAO_Opportunity__c` carries
     * `<required>true</required>` on Source, Candidate, Claim, Answer and Flag alike, and
     * `AAO_ScopeKey.compose` throws on a null scope and composes from the opportunity id
     * only. Every row that exists is therefore deal-grain by construction, and an
     * account-scope group would render empty on every account forever.
     *
     * Making the lookup nullable is a schema change, which this spec forbids, so the group is
     * reported rather than guessed at. `scopeNote` says so on the screen instead of a silent
     * empty box implying the query found nothing.
     */
    private static Snapshot buildAccount(Id acctId) {
        Snapshot s = new Snapshot();
        s.context = 'Account';
        s.contextId = acctId;
        s.showScope = true;
        List<Account> accts = [SELECT Id, Name FROM Account WHERE Id = :acctId LIMIT 1];
        s.contextName = accts.isEmpty() ? '' : accts[0].Name;
        s.emptyText =
            'Nothing has arrived on any opportunity for this account yet. No sources, no ' +
            'candidates, no claims, no answers. That is a true statement about the account, ' +
            'not a loading state.';
        s.scopeNote =
            'Every row below is deal grain. Account-grain rows cannot exist yet: the ' +
            'opportunity lookup is required on all five row objects, so there is no ' +
            'account-scope group to show rather than an empty one to imply.';
        for (Opportunity o : [
            SELECT Id, Name, StageName
            FROM Opportunity
            WHERE AccountId = :acctId
            ORDER BY Name ASC
            LIMIT 200
        ]) {
            DealHeader d = new DealHeader();
            d.id = o.Id;
            d.name = o.Name;
            d.stage = o.StageName;
            s.deals.add(d);
        }
        return fill(s, 'AAO_Account__c', acctId);
    }

    // ===================================================================== the build

    private static Snapshot fill(Snapshot s, String scopeField, Id scopeId) {
        s.generatedAt =
            'snapshot ' +
            System.now().format('HH:mm:ss') +
            ' (local) · ' +
            System.now().format('d MMM yyyy');
        s.banner.lastRefreshed = s.generatedAt;
        CLAIMS_BY_SOURCE = new Map<Id, Integer>();

        buildClaims(s, scopeField, scopeId);
        buildSources(s, scopeField, scopeId);
        buildCandidates(s, scopeField, scopeId);
        buildAnswers(s, scopeField, scopeId);
        buildFlags(s, scopeField, scopeId);
        buildProjection(s, scopeField, scopeId);
        buildBanner(s);

        s.isEmpty = s.sources.isEmpty() && s.claims.isEmpty() && s.people.isEmpty();
        return s;
    }

    // ------------------------------------------------------------------- 3 · claims

    private static void buildClaims(Snapshot s, String scopeField, Id scopeId) {
        Integer total = countOf('AAO_Claim__c', scopeField, scopeId);

        String soql =
            'SELECT Id, Name, AAO_Source__c, AAO_Verdict_Before__c, AAO_Verdict_After__c, ' +
            'AAO_Outcome__c, AAO_Actor__c, AAO_Spans__c, AAO_Evidence_Occurred__c, ' +
            'AAO_Recorded_At__c, AAO_Opportunity__c, AAO_Candidate__c, AAO_Answer__c, ' +
            'AAO_Source__r.AAO_Source_Ref__c, AAO_Answer__r.Name, ' +
            'AAO_Candidate__r.Name, AAO_Candidate__r.AAO_Proposed_Verdict__c, ' +
            'AAO_Candidate__r.AAO_Outcome__c ' +
            'FROM AAO_Claim__c WHERE ' + scopeField + ' = :scopeId ' +
            'ORDER BY AAO_Evidence_Occurred__c ASC, AAO_Recorded_At__c ASC, Id ASC ' +
            'LIMIT ' + PAGE;

        Map<Id, ClaimRow> byId = new Map<Id, ClaimRow>();
        for (AAO_Claim__c c : (List<AAO_Claim__c>) Database.query(soql)) {
            if (c.AAO_Source__c != null) {
                Integer prior = CLAIMS_BY_SOURCE.get(c.AAO_Source__c);
                CLAIMS_BY_SOURCE.put(c.AAO_Source__c, prior == null ? 1 : prior + 1);
            }

            ClaimRow r = new ClaimRow();
            r.id = c.Id;
            r.name = c.Name;
            r.before = c.AAO_Verdict_Before__c == null ? '—' : c.AAO_Verdict_Before__c;
            r.after = c.AAO_Verdict_After__c;
            r.outcome = c.AAO_Outcome__c;
            r.actor = c.AAO_Actor__c;
            r.occurred = stamp(c.AAO_Evidence_Occurred__c);
            r.recorded = stamp(c.AAO_Recorded_At__c);
            r.sourceId = c.AAO_Source__c;
            r.sourceRef = c.AAO_Source__r == null ? '' : c.AAO_Source__r.AAO_Source_Ref__c;
            r.snippet = firstSpan(c.AAO_Spans__c);
            r.theme = theme(c.AAO_Verdict_After__c);
            r.dealId = c.AAO_Opportunity__c;
            r.scope = 'Deal';
            r.candidateId = c.AAO_Candidate__c;
            r.candidateLabel = c.AAO_Candidate__r == null
                ? null
                : c.AAO_Candidate__r.Name +
                  ' · proposed ' + blank(c.AAO_Candidate__r.AAO_Proposed_Verdict__c) +
                  ' · ' + blank(c.AAO_Candidate__r.AAO_Outcome__c);
            r.answerId = c.AAO_Answer__c;
            r.answerLabel = c.AAO_Answer__r == null ? null : c.AAO_Answer__r.Name;
            byId.put(r.id, r);
            s.claims.add(r);
        }
        s.claimPage.seal(s.claims.size(), total);

        if (byId.isEmpty()) {
            return;
        }
        // Depth-one: the citations each shown claim rests on.
        Set<Id> claimIds = byId.keySet();
        for (AAO_Claim_Basis__c b : [
            SELECT
                Id,
                AAO_Claim__c,
                AAO_Cited_Type__c,
                AAO_Covers_Element__c,
                AAO_Cited_Row_Deleted__c,
                AAO_Cited_Answer__c,
                AAO_Cited_Source__c,
                AAO_Cited_Map_Row__c,
                AAO_Cited_Line_Item__c,
                AAO_Cited_Source__r.AAO_Source_Ref__c,
                AAO_Cited_Answer__r.Name
            FROM AAO_Claim_Basis__c
            WHERE AAO_Claim__c IN :claimIds
            ORDER BY AAO_Cited_Type__c ASC, Id ASC
        ]) {
            ClaimRow parent = byId.get(b.AAO_Claim__c);
            if (parent == null) {
                continue;
            }
            BasisRow br = new BasisRow();
            br.id = b.Id;
            br.citedType = b.AAO_Cited_Type__c;
            br.coversElement = blank(b.AAO_Covers_Element__c);
            br.deleted = b.AAO_Cited_Row_Deleted__c;
            if (b.AAO_Cited_Source__c != null) {
                br.citedId = b.AAO_Cited_Source__c;
                br.citedLabel = b.AAO_Cited_Source__r == null
                    ? 'Source'
                    : b.AAO_Cited_Source__r.AAO_Source_Ref__c;
            } else if (b.AAO_Cited_Answer__c != null) {
                br.citedId = b.AAO_Cited_Answer__c;
                br.citedLabel = b.AAO_Cited_Answer__r == null
                    ? 'Answer'
                    : b.AAO_Cited_Answer__r.Name;
            } else if (b.AAO_Cited_Map_Row__c != null) {
                br.citedId = b.AAO_Cited_Map_Row__c;
                br.citedLabel = 'Contact Map Details row';
            } else if (b.AAO_Cited_Line_Item__c != null) {
                br.citedId = b.AAO_Cited_Line_Item__c;
                br.citedLabel = 'Opportunity line item';
            } else {
                br.citedLabel = blank(b.AAO_Cited_Type__c);
            }
            parent.bases.add(br);
            parent.hasLineage = true;
        }
        for (ClaimRow r : byId.values()) {
            if (r.candidateId != null || r.answerId != null) {
                r.hasLineage = true;
            }
        }
    }

    // ------------------------------------------------------------------ 1 · sources

    private static void buildSources(Snapshot s, String scopeField, Id scopeId) {
        Integer total = countOf('AAO_Source__c', scopeField, scopeId);
        String soql =
            'SELECT Id, Name, AAO_Source_Ref__c, AAO_Origin__c, AAO_Diarization__c, ' +
            'AAO_Evidence_Occurred__c, AAO_Opportunity__c ' +
            'FROM AAO_Source__c WHERE ' + scopeField + ' = :scopeId ' +
            'ORDER BY AAO_Evidence_Occurred__c ASC, CreatedDate ASC LIMIT ' + PAGE;

        for (AAO_Source__c src : (List<AAO_Source__c>) Database.query(soql)) {
            SourceRow r = new SourceRow();
            r.id = src.Id;
            r.name = src.Name;
            r.sourceRef = src.AAO_Source_Ref__c;
            r.origin = src.AAO_Origin__c;
            r.diarization = src.AAO_Diarization__c;
            r.occurred = stamp(src.AAO_Evidence_Occurred__c);
            r.dealId = src.AAO_Opportunity__c;
            r.scope = 'Deal';
            Integer cc = CLAIMS_BY_SOURCE.get(src.Id);
            r.claimCount = cc == null ? 0 : cc;
            // Pending means the artifact is stored and adjudication has not landed. It is
            // the state the whole async path exists to make visible.
            r.pending = r.claimCount == 0;
            r.status = r.pending ? 'PENDING' : 'Adjudicated';
            if (r.pending) {
                s.pendingCount++;
            }
            s.sources.add(r);
        }
        s.sourcePage.seal(s.sources.size(), total);
        s.hasPending = s.pendingCount > 0;
    }

    // --------------------------------------------------------------- 2 · candidates

    private static void buildCandidates(Snapshot s, String scopeField, Id scopeId) {
        String agg =
            'SELECT AAO_Outcome__c o, COUNT(Id) n FROM AAO_Candidate__c WHERE ' +
            scopeField + ' = :scopeId GROUP BY AAO_Outcome__c ORDER BY COUNT(Id) DESC';
        for (AggregateResult ar : (List<AggregateResult>) Database.query(agg)) {
            Integer n = (Integer) ar.get('n');
            s.candidates.total.add(new OutcomeCount((String) ar.get('o'), n));
            s.candidates.grandTotal += n;
        }
        // The latest pass is the latest artifact, which is the last source in occurred order.
        if (s.sources.isEmpty()) {
            s.candidates.latestPassLabel = '—';
            return;
        }
        SourceRow last = s.sources[s.sources.size() - 1];
        s.candidates.latestPassLabel = last.sourceRef;
        s.candidates.latestPassId = last.id;
        Id latestSourceId = last.id;
        for (AggregateResult ar : [
            SELECT AAO_Outcome__c o, COUNT(Id) n
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :latestSourceId
            GROUP BY AAO_Outcome__c
            ORDER BY COUNT(Id) DESC
        ]) {
            Integer n = (Integer) ar.get('n');
            s.candidates.latest.add(new OutcomeCount((String) ar.get('o'), n));
            s.candidates.latestTotal += n;
        }
    }

    // ------------------------------------------------------------------ 4 · answers

    private static void buildAnswers(Snapshot s, String scopeField, Id scopeId) {
        Integer total = countOf('AAO_Answer__c', scopeField, scopeId);
        String soql =
            'SELECT Id, Name, AAO_Verdict__c, AAO_Element_Completeness__c, AAO_Established_By__c, ' +
            'AAO_Publication_State__c, AAO_Subject_Contact__c, AAO_Subject_Type__c, ' +
            'AAO_Projected_Value__c, AAO_Projected_Modstamp__c, AAO_Opportunity__c, ' +
            'AAO_Subject_Contact__r.Name, AAO_Subject_Contact__r.Title, ' +
            'AAO_Evidence_Contract__r.AAO_Proposition_Code__c, ' +
            'AAO_Evidence_Contract__r.AAO_Proposition_Short__c, ' +
            'AAO_Evidence_Contract__r.AAO_Elements__c ' +
            'FROM AAO_Answer__c WHERE ' + scopeField + ' = :scopeId ' +
            'ORDER BY AAO_Subject_Contact__r.Name NULLS LAST, Name ASC LIMIT ' + PAGE;

        Map<Id, AnswerRow> byId = new Map<Id, AnswerRow>();
        // LinkedHashMap behaviour: Apex Map preserves insertion order for String keys.
        Map<String, PersonGroup> groups = new Map<String, PersonGroup>();

        for (AAO_Answer__c a : (List<AAO_Answer__c>) Database.query(soql)) {
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
            r.held = a.AAO_Publication_State__c == 'Held';
            r.rowClass = r.held ? 'aao-held' : '';
            r.dealId = a.AAO_Opportunity__c;
            r.scope = 'Deal';

            // The dimension is the ontology's, derived from the proposition code. A
            // non-People contract returns null and renders as nothing, which is correct.
            r.dimension = String.isBlank(r.code)
                ? null
                : AAO_PeopleOntology.dimension(r.code);

            r.projectedValue = a.AAO_Projected_Value__c;
            r.projected = String.isNotBlank(a.AAO_Projected_Value__c);
            r.projectedAt = stamp(a.AAO_Projected_Modstamp__c);
            // The rung IS the projected value on a People dimension. Nothing derives a rung
            // for display: showing a value the projection writer has not written would be
            // this screen inventing an answer.
            r.rung = (r.dimension != null && r.projected) ? a.AAO_Projected_Value__c : null;

            AAO_Model.Coverage cov = AAO_Model.parseCoverage(a.AAO_Element_Completeness__c);
            r.covered = cov.covered.isEmpty() ? '—' : String.join(cov.covered, ', ');
            r.missing = cov.missing.isEmpty() ? '—' : String.join(cov.missing, ', ');
            r.complete = cov.isFull(
                AAO_ExtractCharter.elementIds(a.AAO_Evidence_Contract__r)
            );

            if (r.held) {
                s.heldCount++;
            } else {
                s.liveCount++;
            }

            String key = a.AAO_Subject_Contact__c == null
                ? 'ZZZ_nonperson'
                : String.valueOf(a.AAO_Subject_Contact__c);
            PersonGroup g = groups.get(key);
            if (g == null) {
                g = new PersonGroup();
                if (a.AAO_Subject_Contact__c == null) {
                    g.isPerson = false;
                    g.personName = 'Not about a person';
                    g.subtitle = 'Answers whose subject is the deal itself, or a card, ' +
                        'qualifier or criterion rather than someone in the buying group.';
                } else {
                    g.isPerson = true;
                    g.contactId = a.AAO_Subject_Contact__c;
                    g.personName = a.AAO_Subject_Contact__r.Name;
                    g.subtitle = blank(a.AAO_Subject_Contact__r.Title);
                }
                groups.put(key, g);
            }
            g.answers.add(r);
            byId.put(r.id, r);
        }
        s.answerPage.seal(byId.size(), total);
        s.publicationLine = s.liveCount + ' live · ' + s.heldCount + ' held';

        // People first, the non-person bucket last, because this screen exists to be read
        // person by person during adjudication.
        for (PersonGroup g : groups.values()) {
            if (g.isPerson) {
                s.people.add(g);
            }
        }
        for (PersonGroup g : groups.values()) {
            if (!g.isPerson) {
                s.people.add(g);
            }
        }

        if (byId.isEmpty()) {
            return;
        }
        // Depth-one: every claim behind each shown answer, in occurred order.
        Set<Id> answerIds = byId.keySet();
        Integer lineageCap = PAGE * 5;
        for (AAO_Claim__c c : [
            SELECT
                Id,
                Name,
                AAO_Answer__c,
                AAO_Verdict_Before__c,
                AAO_Verdict_After__c,
                AAO_Evidence_Occurred__c
            FROM AAO_Claim__c
            WHERE AAO_Answer__c IN :answerIds
            ORDER BY AAO_Evidence_Occurred__c ASC, AAO_Recorded_At__c ASC, Id ASC
            LIMIT :lineageCap
        ]) {
            AnswerRow parent = byId.get(c.AAO_Answer__c);
            if (parent == null) {
                continue;
            }
            AnswerClaimRow ac = new AnswerClaimRow();
            ac.id = c.Id;
            ac.name = c.Name;
            ac.before = c.AAO_Verdict_Before__c == null ? '—' : c.AAO_Verdict_Before__c;
            ac.after = c.AAO_Verdict_After__c;
            ac.occurred = stamp(c.AAO_Evidence_Occurred__c);
            ac.theme = theme(c.AAO_Verdict_After__c);
            parent.claims.add(ac);
            parent.hasLineage = true;
        }
    }

    // -------------------------------------------------------------------- 5 · flags

    private static void buildFlags(Snapshot s, String scopeField, Id scopeId) {
        Integer total = countOf('AAO_Flag__c', scopeField, scopeId);
        // Standing first, then escalated, then cleared. The order is the order that matters
        // to somebody reading the screen during a run.
        String soql =
            'SELECT Id, Name, AAO_Type__c, AAO_State__c, AAO_Subject_Contact__c, ' +
            'AAO_Subject_Contact__r.Name, AAO_Raised_At__c, CreatedDate, AAO_Opportunity__c ' +
            'FROM AAO_Flag__c WHERE ' + scopeField + ' = :scopeId ' +
            'ORDER BY AAO_State__c ASC, AAO_Type__c ASC, CreatedDate DESC LIMIT ' + PAGE;

        List<FlagRow> standing = new List<FlagRow>();
        List<FlagRow> escalated = new List<FlagRow>();
        List<FlagRow> cleared = new List<FlagRow>();

        for (AAO_Flag__c f : (List<AAO_Flag__c>) Database.query(soql)) {
            FlagRow r = new FlagRow();
            r.id = f.Id;
            r.name = f.Name;
            r.type = f.AAO_Type__c;
            r.typeTheme = flagTypeTheme(f.AAO_Type__c);
            r.state = f.AAO_State__c;
            r.stateTheme = flagStateTheme(f.AAO_State__c);
            r.subjectId = f.AAO_Subject_Contact__c;
            r.subjectName = f.AAO_Subject_Contact__r == null
                ? null
                : f.AAO_Subject_Contact__r.Name;
            r.created = stamp(f.AAO_Raised_At__c == null ? f.CreatedDate : f.AAO_Raised_At__c);
            r.dealId = f.AAO_Opportunity__c;
            r.scope = 'Deal';
            if (f.AAO_State__c == 'Standing') {
                standing.add(r);
            } else if (f.AAO_State__c == 'Escalated') {
                escalated.add(r);
            } else {
                cleared.add(r);
            }
        }
        s.flags.rows.addAll(standing);
        s.flags.rows.addAll(escalated);
        s.flags.rows.addAll(cleared);
        s.flags.standingCount = standing.size() + escalated.size();
        s.flags.clearedCount = cleared.size();
        s.flags.count = s.flags.standingCount;
        s.flags.hasAny = !s.flags.rows.isEmpty();
        s.flags.page.seal(s.flags.rows.size(), total);

        Integer st = s.flags.standingCount;
        Integer cl = s.flags.clearedCount;
        if (st > 0) {
            s.flags.sentence =
                st + (st == 1 ? ' flag stands' : ' flags stand') + ' on this record' +
                (cl > 0 ? ', ' + cl + ' already cleared by evidence' : '') +
                '. A gating red is raised at deal creation, not when something goes wrong, ' +
                'and only establishment clears it.';
        } else if (cl > 0) {
            s.flags.sentence =
                'No flag stands. All ' + cl + ' were cleared by evidence, which is the only ' +
                'thing that clears one.';
        } else {
            s.flags.sentence =
                'No flags of any type on this record. All six types are counted here, so ' +
                'this is a statement about the record rather than about what the panel looks at.';
        }
    }

    // --------------------------------------------------------------- 6 · projection

    private static void buildProjection(Snapshot s, String scopeField, Id scopeId) {
        String soql =
            'SELECT Id, Name, AAO_Projected_Value__c, AAO_Projected_Modstamp__c, ' +
            'AAO_Subject_Contact__c, AAO_Subject_Contact__r.Name, AAO_Opportunity__c, ' +
            'AAO_Evidence_Contract__r.AAO_Proposition_Code__c ' +
            'FROM AAO_Answer__c WHERE ' + scopeField + ' = :scopeId ' +
            // The watermark filter is GONE. It was `AND AAO_Projected_Value__c != null`, which
            // made this panel a report on a field nothing wrote rather than on what reached
            // the customer's map. What counts as projected is now the map row, below.
            'ORDER BY AAO_Projected_Modstamp__c DESC NULLS LAST LIMIT ' + PAGE;

        List<AAO_Answer__c> rows = (List<AAO_Answer__c>) Database.query(soql);

        // Resolve the target map row by subject contact plus opportunity, which is the pair
        // the map row is keyed on. Read only; nothing here writes to Altify.
        Set<Id> contactIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        for (AAO_Answer__c a : rows) {
            if (a.AAO_Subject_Contact__c != null) {
                contactIds.add(a.AAO_Subject_Contact__c);
            }
            if (a.AAO_Opportunity__c != null) {
                oppIds.add(a.AAO_Opportunity__c);
            }
        }
        Map<String, ALTF__Contact_Map_Details__c> mapRows =
            new Map<String, ALTF__Contact_Map_Details__c>();
        Set<Id> carriesValue = new Set<Id>();
        if (!contactIds.isEmpty() && !oppIds.isEmpty()) {
            for (ALTF__Contact_Map_Details__c m : [
                SELECT Id, Name, ALTF__Contact__c, ALTF__Opportunity__c, ALTF__Status__c,
                       ALTF__Political__c
                FROM ALTF__Contact_Map_Details__c
                WHERE ALTF__Contact__c IN :contactIds AND ALTF__Opportunity__c IN :oppIds
                LIMIT 2000
            ]) {
                mapRows.put(
                    String.valueOf(m.ALTF__Contact__c) + '|' + String.valueOf(m.ALTF__Opportunity__c),
                    m
                );
                if (String.isNotBlank(m.ALTF__Status__c) ||
                    String.isNotBlank(m.ALTF__Political__c)) {
                    carriesValue.add(m.Id);
                }
            }
        }

        for (AAO_Answer__c a : rows) {
            ProjectionRow p = new ProjectionRow();
            p.answerId = a.Id;
            p.answerName = a.Name;
            p.value = a.AAO_Projected_Value__c;
            p.modstamp = stamp(a.AAO_Projected_Modstamp__c);
            p.subjectId = a.AAO_Subject_Contact__c;
            p.subjectName = a.AAO_Subject_Contact__r == null
                ? null
                : a.AAO_Subject_Contact__r.Name;
            p.dealId = a.AAO_Opportunity__c;
            p.scope = 'Deal';
            String code = a.AAO_Evidence_Contract__r == null
                ? null
                : a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
            p.dimension = String.isBlank(code) ? null : AAO_PeopleOntology.dimension(code);
            ALTF__Contact_Map_Details__c m = mapRows.get(
                String.valueOf(a.AAO_Subject_Contact__c) + '|' + String.valueOf(a.AAO_Opportunity__c)
            );
            if (m != null) {
                p.mapRowId = m.Id;
                p.mapRowLabel = m.Name +
                    (String.isBlank(m.ALTF__Status__c) ? '' : ' · ' + m.ALTF__Status__c);
            }
            // THE LIST IS WHAT REACHED THE MAP, not every answer and not every watermark.
            // Dropping the watermark filter from the query was necessary (it made the panel
            // blind to a real projection) but it must not turn this into a list of all
            // answers: a row belongs here when our value is standing on Altify's record.
            if (p.mapRowId != null && carriesValue.contains(p.mapRowId)) {
                s.projection.rows.add(p);
            }
        }

        s.projection.page.seal(s.projection.rows.size(), s.projection.rows.size());

        // WHAT IS PROJECTED IS WHAT REACHED THE MAP. Counted from Altify's own rows rather
        // than from our watermark, so a writer that forgets to stamp can no longer make the
        // panel claim nothing happened.
        Set<Id> written = new Set<Id>();
        Set<Id> watermarked = new Set<Id>();
        for (ProjectionRow p : s.projection.rows) {
            if (p.mapRowId == null || !carriesValue.contains(p.mapRowId)) {
                // An empty skeleton from contact-role sync is a row we have NOT written.
                // Counting it would report the customer's configuration as our output, which
                // is the first thing this counter was rebuilt to stop doing.
                continue;
            }
            written.add(p.mapRowId);
            if (String.isNotBlank(p.modstamp)) {
                watermarked.add(p.mapRowId);
            }
        }
        s.projection.mapRowsWritten = written.size();
        Set<Id> unstamped = new Set<Id>(written);
        unstamped.removeAll(watermarked);
        s.projection.rowsProjectedWithNoWatermark = unstamped.size();

        s.projection.isOn = s.projection.mapRowsWritten > 0;
        s.projection.label = s.projection.isOn ? 'live' : 'off';
        s.projection.sentence = !s.projection.isOn
            ? 'No projections yet on this record.'
            : s.projection.mapRowsWritten +
              (s.projection.mapRowsWritten == 1 ? ' map row (unit: rows) carries' : ' map rows (unit: rows) carry') +
              ' values we wrote onto Altify\'s own record. Every value traces to the answer ' +
              'that wrote it and the claims behind that answer.' +
              (s.projection.rowsProjectedWithNoWatermark == 0
                  ? ''
                  : ' ' + s.projection.rowsProjectedWithNoWatermark +
                    ' (unit: rows) carry no watermark, which means a human edit there would ' +
                    'not be protected. Any number above zero is an alarm.');
    }

    // ---------------------------------------------------------------- J · run banner

    private static void buildBanner(Snapshot s) {
        // The interesting row is the one still moving: the newest pending source if there is
        // one, otherwise the newest source at all.
        SourceRow chosen;
        for (SourceRow r : s.sources) {
            if (r.pending) {
                chosen = r;
            }
        }
        if (chosen == null && !s.sources.isEmpty()) {
            chosen = s.sources[s.sources.size() - 1];
        }
        if (chosen == null) {
            s.banner.active = false;
            s.banner.stage = 'idle';
            s.banner.sentence = 'No evidence has arrived on this record.';
            return;
        }
        s.banner.active = chosen.pending;
        s.banner.sourceId = chosen.id;
        s.banner.sourceRef = chosen.sourceRef;
        if (chosen.pending) {
            s.banner.stage = 'adjudicating';
            s.banner.sentence =
                'The artifact is stored and adjudication has not landed yet.';
        } else if (s.projection.isOn) {
            s.banner.stage = 'committed';
            s.banner.sentence =
                'Adjudicated and projected. ' + chosen.claimCount +
                (chosen.claimCount == 1 ? ' claim' : ' claims') + ' from this artifact.';
        } else {
            s.banner.stage = 'arrived';
            s.banner.sentence =
                'Adjudicated, not projected. ' + chosen.claimCount +
                (chosen.claimCount == 1 ? ' claim' : ' claims') + ' from this artifact.';
        }
    }

    // ------------------------------------------------------------------- internals

    private static Integer countOf(String obj, String scopeField, Id scopeId) {
        return Database.countQuery(
            'SELECT COUNT() FROM ' + obj + ' WHERE ' + scopeField + ' = :scopeId'
        );
    }

    /**
     * Both clocks render the same way and both carry a time. A call at 07:01 that renders as
     * a bare date has thrown away the half of the timestamp the occurred clock exists for.
     */
    private static String stamp(Datetime d) {
        return d == null ? '' : d.formatGmt('d MMM yyyy HH:mm') + ' GMT';
    }

    private static String blank(String v) {
        return v == null ? '' : v;
    }

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

    private static String flagTypeTheme(String type) {
        if (type == 'Contention_Negative' || type == 'Methodological') {
            return 'slds-badge slds-theme_error';
        }
        if (type == 'Contention_Positive') {
            return 'slds-badge slds-theme_success';
        }
        return 'slds-badge slds-theme_warning';
    }

    private static String flagStateTheme(String state) {
        if (state == 'Cleared') {
            return 'slds-badge';
        }
        if (state == 'Escalated') {
            return 'slds-badge slds-theme_error';
        }
        return 'slds-badge slds-theme_warning';
    }
}
