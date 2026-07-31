/**
 * The per-source pipeline body. One implementation, two entries.
 *
 *   synchronous  — AAO_Demo calls it directly, in order, for the deterministic rehearsal
 *   asynchronous — AAO_Source__c after-insert enqueues AAO_IngestQueueable, which calls it
 *
 * The two entries are deliberately the same function and not two functions that agree.
 * Anything else and the live path would be a demonstration of a second implementation.
 *
 * WHAT THIS IS NOT. The stage that reads a transcript and proposes a verdict with quotes
 * is a charter, and no charter runs here. Proposals are **staged in the fixture and looked
 * up by artifact hash**: given a Source, this finds the proposal that was authored for that
 * exact artifact and feeds it into the real adjudication. So the extraction stage is
 * simulated and everything downstream of it is executed. See BUILD_JOURNAL session 4 for
 * the stage-by-stage inventory, which is the honest version of this paragraph.
 *
 * Keying on the artifact hash rather than on a fixture code is what makes the async entry
 * possible at all: a trigger has a Source and nothing else, so the proposal has to be
 * findable from the artifact itself.
 */
public class AAO_Pipeline {
    public class PipelineException extends Exception {
    }

    public static final String CHARTER = 'AAO_Extract_Evidence';
    public static final String CHARTER_VERSION = '0.1.0';

    public class Outcome {
        public Id sourceId;
        public String sourceRef;
        /** staged | no_staged_proposal | already_committed */
        public String status;
        public String verdict;
        public Id answerId;
        public Id claimId;
        public String claimOutcome;
        public Id internalPerson;
        public Integer abstentions = 0;
        public String note;

        public override String toString() {
            return status +
                ' src=' +
                sourceRef +
                ' verdict=' +
                verdict +
                ' claim=' +
                claimOutcome +
                ' key4=' +
                internalPerson +
                ' abstentions=' +
                abstentions +
                (String.isBlank(note) ? '' : ' note=' + note);
        }
    }

    // ==================================================================== the entry

    public static Outcome runForSource(Id sourceId, Set<String> internalDomains) {
        AAO_Source__c src = [
            SELECT
                Id,
                AAO_Opportunity__c,
                AAO_Account__c,
                AAO_Artifact_SHA256__c,
                AAO_Source_Ref__c,
                AAO_Normalized_Text__c,
                AAO_Diarization__c,
                AAO_Synthetic__c
            FROM AAO_Source__c
            WHERE Id = :sourceId
        ];

        Outcome o = new Outcome();
        o.sourceId = src.Id;
        o.sourceRef = src.AAO_Source_Ref__c;

        // Idempotent, and the safety net if both entries ever fire for one Source: the
        // synchronous caller commits inside its transaction, so a Queueable enqueued by
        // the same insert arrives afterwards and finds the work already done.
        if ([SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Source__c = :src.Id] > 0) {
            o.status = 'already_committed';
            o.note = 'A claim already rests on this Source. Nothing written.';
            return o;
        }

        Map<String, Object> fixture = AAO_Seed.fixture();
        List<Object> staged = stagedFor(fixture, src.AAO_Artifact_SHA256__c);
        if (staged.isEmpty()) {
            // A real Source with no extraction behind it. This is the honest outcome and
            // not an error: nothing has proposed anything about this artifact yet.
            o.status = 'no_staged_proposal';
            o.note =
                'No proposal is staged for artifact ' +
                src.AAO_Artifact_SHA256__c.substring(0, 12) +
                '. Nothing written. Until a charter runs, a Source only becomes a claim if ' +
                'a proposal was authored for it.';
            return o;
        }

        Boolean mark = src.AAO_Synthetic__c == true;
        Boolean priorMark = AAO_Synthetic.MARK;
        AAO_Synthetic.MARK = mark;
        try {
            Map<String, AAO_Evidence_Contract__c> contracts = AAO_Seed.ensureContracts(fixture);

            for (Object so : staged) {
                Map<String, Object> spec = (Map<String, Object>) so;
                AAO_Candidate__c cand = buildCandidate(spec, src, contracts, mark);
                AAO_Commit.Result r = AAO_Commit.commitCandidate(cand.Id, internalDomains);

                o.status = 'staged';
                o.verdict = r.answer == null ? null : r.answer.AAO_Verdict__c;
                o.answerId = r.answer == null ? null : r.answer.Id;
                o.claimId = r.claim == null ? null : r.claim.Id;
                o.claimOutcome = r.claim == null ? 'none' : r.claim.AAO_Outcome__c;
                o.internalPerson = r.claim == null ? null : r.claim.AAO_Internal_Person__c;
                if (String.isNotBlank(r.note)) {
                    o.note = r.note;
                }
            }

            o.abstentions = logAbstentions(src, contracts, mark).size();
        } finally {
            AAO_Synthetic.MARK = priorMark;
        }
        return o;
    }

    // ================================================= the staged proposals, by hash

    /**
     * Every proposal authored for this artifact. Keyed by the hash of the artifact rather
     * than by a fixture code, because the async entry has a Source and nothing else.
     */
    public static List<Object> stagedFor(Map<String, Object> fixture, String artifactSha) {
        Map<String, String> shaBySourceCode = new Map<String, String>();
        for (Object o : (List<Object>) fixture.get('sources')) {
            Map<String, Object> s = (Map<String, Object>) o;
            shaBySourceCode.put(
                (String) s.get('code'),
                AAO_NormalForm.sha256((String) s.get('sourceRef'))
            );
        }

        List<Object> out = new List<Object>();
        for (Object o : (List<Object>) fixture.get('candidates')) {
            Map<String, Object> c = (Map<String, Object>) o;
            if (shaBySourceCode.get((String) c.get('sourceCode')) == artifactSha) {
                out.add(c);
            }
        }
        return out;
    }

    // ====================================================================== internals

    private static AAO_Candidate__c buildCandidate(
        Map<String, Object> spec,
        AAO_Source__c src,
        Map<String, AAO_Evidence_Contract__c> contracts,
        Boolean mark
    ) {
        List<AAO_Model.Span> spans = new List<AAO_Model.Span>();
        for (Object so : (List<Object>) spec.get('spans')) {
            Map<String, Object> sp = (Map<String, Object>) so;
            // Resolved against THIS Source's own text. The staged proposal carries quotes,
            // never offsets, so a proposal cannot point at bytes that are not there.
            spans.add(
                AAO_Seed.resolve(
                    src,
                    (String) sp.get('quote'),
                    (String) sp.get('speaker'),
                    (String) sp.get('element')
                )
            );
        }

        AAO_Evidence_Contract__c ec = contracts.get((String) spec.get('contractCode'));
        if (ec == null) {
            throw new PipelineException(
                'The staged proposal names contract "' +
                spec.get('contractCode') +
                '", which is not in the rubric.'
            );
        }

        AAO_Candidate__c cand = new AAO_Candidate__c(
            AAO_Evidence_Contract__c = ec.Id,
            AAO_Source__c = src.Id,
            AAO_Opportunity__c = src.AAO_Opportunity__c,
            AAO_Account__c = src.AAO_Account__c,
            AAO_Subject_Type__c = (String) spec.get('subjectType'),
            AAO_Proposed_Verdict__c = (String) spec.get('proposedVerdict'),
            AAO_Spans__c = AAO_Model.serializeSpans(spans),
            AAO_Element_Coverage__c = AAO_Model.serializeCoverage(
                AAO_Model.newCoverage(
                    AAO_Seed.strings((List<Object>) spec.get('covered')),
                    AAO_Seed.strings((List<Object>) spec.get('missing'))
                )
            ),
            AAO_Stage__c = 'Adjudicated',
            AAO_Outcome__c = 'Pending',
            AAO_Charter__c = CHARTER,
            AAO_Charter_Version__c = CHARTER_VERSION,
            AAO_Publication_State__c = 'Live',
            AAO_Synthetic__c = mark
        );
        insert cand;
        return cand;
    }

    /**
     * The complete ledger: a row for every proposition considered on this pass, including
     * the ones nothing was said about, so the abstention rate is a direct query and "did it
     * even look" is answerable.
     */
    private static List<AAO_Candidate__c> logAbstentions(
        AAO_Source__c src,
        Map<String, AAO_Evidence_Contract__c> contracts,
        Boolean mark
    ) {
        Set<Id> proposedFor = new Set<Id>();
        for (AAO_Candidate__c cd : [
            SELECT AAO_Evidence_Contract__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :src.Id
        ]) {
            proposedFor.add(cd.AAO_Evidence_Contract__c);
        }

        List<AAO_Candidate__c> rows = new List<AAO_Candidate__c>();
        for (AAO_Evidence_Contract__c ec : contracts.values()) {
            if (proposedFor.contains(ec.Id)) {
                continue;
            }
            rows.add(
                new AAO_Candidate__c(
                    AAO_Evidence_Contract__c = ec.Id,
                    AAO_Source__c = src.Id,
                    AAO_Opportunity__c = src.AAO_Opportunity__c,
                    AAO_Account__c = src.AAO_Account__c,
                    AAO_Subject_Type__c = 'Opportunity',
                    AAO_Stage__c = 'Adjudicated',
                    AAO_Outcome__c = 'Abstained',
                    // Asserted by the fixture, not determined by a reader. A real
                    // abstention has to distinguish nobody_said from model_missed, and
                    // only something that actually read the transcript can do that.
                    AAO_Abstention_Reason__c = 'nobody_said',
                    AAO_Charter__c = CHARTER,
                    AAO_Charter_Version__c = CHARTER_VERSION,
                    AAO_Publication_State__c = 'Live',
                    AAO_Synthetic__c = mark
                )
            );
        }
        insert rows;
        return rows;
    }
}
