/**
 * The per-source pipeline body. One implementation, three entries.
 *
 *   synchronous  — AAO_Demo calls it directly, in order, for the deterministic rehearsal
 *   asynchronous — AAO_Source__c after-insert enqueues AAO_IngestQueueable, which calls it
 *   model        — AAO_Gate1 calls it with proposalSource = model
 *
 * The entries are deliberately the same function and not functions that agree.
 *
 * WHERE PROPOSALS COME FROM, which is the only thing that differs between them.
 *
 *   fixture  proposals were authored by hand and are looked up by artifact hash. Charter
 *            version 0.1.0. Nothing read the transcript; the quotes were written by a
 *            person who had already read it.
 *   model    proposals come from AAO_Extract, which sends the rubric and the artifact to
 *            the model named in AAO_Model_Config__mdt and gets findings back. Charter
 *            version comes from that record.
 *
 * Downstream of the Proposal struct the two are byte-identical: the same builder writes the
 * Candidate, AAO_Commit runs the same six ordered steps, the same span verification, the
 * same speaker rule, the same human precedence, the same merge. Nothing the model produces
 * is trusted; it is judged by machinery that does not know a model was involved.
 *
 * THE ONE PLACE THEY MUST NOT SHARE CODE. AAO_Seed.resolve throws when a quote is not in
 * the transcript, which is correct for a fixture: ground truth by construction only works
 * if the construction is right, and a bad fixture quote is a defect to fix. It is wrong for
 * a model. A quote that is not in the transcript is the thing byte verification exists to
 * catch, and the correct response is to drop that span, count it, and carry on, not to
 * abort the run. locate() below is the model's resolver and it returns null where the
 * fixture's throws.
 */
public class AAO_Pipeline {
    public class PipelineException extends Exception {
    }

    public static final String CHARTER = 'AAO_Extract_Evidence';
    /** The fixture's version. The model path takes its version from custom metadata. */
    public static final String CHARTER_VERSION = '0.1.0';

    public static final String FROM_FIXTURE = 'fixture';
    public static final String FROM_MODEL = 'model';

    // ======================================================================== proposal

    /**
     * What a reader proposes about one proposition, after quotes have been located in the
     * artifact. The fixture and the model both produce these and nothing downstream can
     * tell which made a given one.
     */
    public class Proposal {
        public String contractCode;
        public String subjectType = 'Opportunity';
        public String proposedVerdict;
        public List<AAO_Model.Span> spans = new List<AAO_Model.Span>();
        public List<String> covered = new List<String>();
        public List<String> missing = new List<String>();
        public String interpretation;
    }

    /** A quote the model offered that is not in the artifact, or is in it twice. */
    public class SpanDrop {
        public String contractCode;
        public String reason;
        public String quote;

        public override String toString() {
            return contractCode + ' ' + reason + ' "' + quote.abbreviate(60) + '"';
        }
    }

    // ========================================================================= outcome

    public class Outcome {
        public Id sourceId;
        public String sourceRef;
        /** staged | no_staged_proposal | already_committed */
        public String status;
        public String proposalSource;
        public String charter;
        public String charterVersion;
        public String verdict;
        public Id answerId;
        public Id claimId;
        public String claimOutcome;
        public Id internalPerson;
        public Integer abstentions = 0;
        public Integer nobodySaid = 0;
        public Integer modelMissed = 0;
        public List<SpanDrop> spanDrops = new List<SpanDrop>();
        /** Populated only on the model path. */
        public AAO_Extract.Result extraction;
        public String note;

        public override String toString() {
            return status +
                ' src=' +
                sourceRef +
                ' from=' +
                proposalSource +
                ' charter=' +
                charterVersion +
                ' verdict=' +
                verdict +
                ' claim=' +
                claimOutcome +
                ' key4=' +
                internalPerson +
                ' abstentions=' +
                abstentions +
                ' (nobody_said=' +
                nobodySaid +
                ' model_missed=' +
                modelMissed +
                ')' +
                ' spansDropped=' +
                spanDrops.size() +
                (extraction == null ? '' : ' | ' + extraction) +
                (String.isBlank(note) ? '' : ' note=' + note);
        }
    }

    // =========================================================================== entry

    public static Outcome runForSource(Id sourceId, Set<String> internalDomains) {
        return runForSource(sourceId, internalDomains, FROM_FIXTURE);
    }

    public static Outcome runForSource(
        Id sourceId,
        Set<String> internalDomains,
        String proposalSource
    ) {
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
        o.proposalSource = proposalSource;
        o.charter = CHARTER;
        o.charterVersion = CHARTER_VERSION;

        // Idempotent, and the safety net if both entries ever fire for one Source: the
        // synchronous caller commits inside its transaction, so a Queueable enqueued by
        // the same insert arrives afterwards and finds the work already done.
        if ([SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Source__c = :src.Id] > 0) {
            o.status = 'already_committed';
            o.note = 'A claim already rests on this Source. Nothing written.';
            return o;
        }

        Map<String, AAO_Evidence_Contract__c> contracts;
        List<Proposal> proposals;
        // Keyed by contract Id rather than proposition code. The fixture path loads
        // contracts through AAO_Seed.ensureContracts, which does not query the code
        // field, so keying on code makes the abstention ledger depend on a field one
        // of its two callers has not selected.
        Map<Id, String> abstentionByContract = new Map<Id, String>();

        if (proposalSource == FROM_MODEL) {
            // ORDER MATTERS AND IS LOAD BEARING. Everything before the callout is SOQL.
            // Apex forbids a callout after DML in the same transaction, so if a single
            // row were written above this line the model call would fail at runtime with
            // an error that reads like a platform problem rather than an ordering one.
            contracts = liveContracts();
            if (contracts.isEmpty()) {
                o.status = 'no_staged_proposal';
                o.note = 'No evidence contracts exist in this org, so there is nothing to ask.';
                return o;
            }

            AAO_Extract.Result ex = AAO_Extract.run(src.Id);
            o.extraction = ex;
            o.charter = ex.charter;
            o.charterVersion = ex.charterVersion;

            proposals = fromModel(ex, src, contracts, o, abstentionByContract);
        } else {
            Map<String, Object> fixture = AAO_Seed.fixture();
            List<Object> staged = stagedFor(fixture, src.AAO_Artifact_SHA256__c);
            if (staged.isEmpty()) {
                // A real Source with no extraction behind it. This is the honest outcome
                // and not an error: nothing has proposed anything about this artifact yet.
                o.status = 'no_staged_proposal';
                o.note =
                    'No proposal is staged for artifact ' +
                    src.AAO_Artifact_SHA256__c.substring(0, 12) +
                    '. Nothing written. Until a charter runs, a Source only becomes a claim ' +
                    'if a proposal was authored for it.';
                return o;
            }
            contracts = AAO_Seed.ensureContracts(fixture);
            proposals = fromFixture(staged, src);
        }

        Boolean mark = src.AAO_Synthetic__c == true;
        Boolean priorMark = AAO_Synthetic.MARK;
        AAO_Synthetic.MARK = mark;
        try {
            for (Proposal p : proposals) {
                AAO_Candidate__c cand = buildCandidate(p, src, contracts, mark, o);
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
            if (o.status == null) {
                o.status = 'staged';
            }

            List<AAO_Candidate__c> abstained = logAbstentions(
                src,
                contracts,
                mark,
                o.charter,
                o.charterVersion,
                abstentionByContract
            );
            o.abstentions = abstained.size();
            for (AAO_Candidate__c a : abstained) {
                if (a.AAO_Abstention_Reason__c == 'model_missed') {
                    o.modelMissed++;
                } else {
                    o.nobodySaid++;
                }
            }
        } finally {
            AAO_Synthetic.MARK = priorMark;
        }
        return o;
    }

    // ============================================================ proposals, two sources

    private static List<Proposal> fromFixture(List<Object> staged, AAO_Source__c src) {
        List<Proposal> out = new List<Proposal>();
        for (Object so : staged) {
            Map<String, Object> spec = (Map<String, Object>) so;
            Proposal p = new Proposal();
            p.contractCode = (String) spec.get('contractCode');
            p.subjectType = (String) spec.get('subjectType');
            p.proposedVerdict = (String) spec.get('proposedVerdict');
            p.covered = AAO_Seed.strings((List<Object>) spec.get('covered'));
            p.missing = AAO_Seed.strings((List<Object>) spec.get('missing'));
            for (Object sp : (List<Object>) spec.get('spans')) {
                Map<String, Object> s = (Map<String, Object>) sp;
                // Resolved against THIS Source's own text. The staged proposal carries
                // quotes, never offsets, so a proposal cannot point at bytes that are not
                // there. This throws on a miss, which is right for a fixture.
                p.spans.add(
                    AAO_Seed.resolve(
                        src,
                        (String) s.get('quote'),
                        (String) s.get('speaker'),
                        (String) s.get('element')
                    )
                );
            }
            out.add(p);
        }
        return out;
    }

    /**
     * Model findings become proposals. Three things happen here and each is a decision.
     *
     * Quotes are located, not trusted. A quote that is not in the artifact, or occurs in it
     * twice, is dropped and recorded on the Outcome. Twice is a drop rather than a guess
     * because the speaker rule is evaluated against the turn a span lies in, and two
     * candidate turns means we do not know who said it.
     *
     * Coverage is computed, not accepted. covered is the set of elements that ended up with
     * at least one located span; missing is the contract's element list minus that. The
     * model is never asked what it covered, because a reader grading its own coverage is
     * the fixture's weakness, not a fix for it.
     *
     * not_addressed and abstained stay distinct. They become nobody_said and model_missed
     * on the abstention ledger. Collapsing them would make the abstention rate measure
     * nothing, which is the whole reason the enum has two values.
     */
    private static List<Proposal> fromModel(
        AAO_Extract.Result ex,
        AAO_Source__c src,
        Map<String, AAO_Evidence_Contract__c> contracts,
        Outcome o,
        Map<Id, String> abstentionByContract
    ) {
        List<Proposal> out = new List<Proposal>();

        for (String code : contracts.keySet()) {
            AAO_ExtractCharter.Finding f = ex.findings.get(code);
            if (f == null) {
                // Asked and not answered. Treated as an abstention the model owes us
                // rather than silently skipped.
                abstentionByContract.put(contracts.get(code).Id, 'model_missed');
                continue;
            }
            if (f.status == 'not_addressed') {
                abstentionByContract.put(contracts.get(code).Id, 'nobody_said');
                continue;
            }
            if (f.status == 'abstained') {
                abstentionByContract.put(contracts.get(code).Id, 'model_missed');
                continue;
            }

            Proposal p = new Proposal();
            p.contractCode = code;
            p.subjectType = 'Opportunity';
            p.proposedVerdict = f.proposedVerdict == 'NONE' ? null : f.proposedVerdict;
            p.interpretation = String.isBlank(f.interpretation) ? null : f.interpretation;

            Set<String> coveredIds = new Set<String>();
            for (AAO_ExtractCharter.QuotedSpan q : f.spans) {
                AAO_Model.Span located = locate(src, q, o, code);
                if (located == null) {
                    continue;
                }
                p.spans.add(located);
                if (String.isNotBlank(q.element)) {
                    coveredIds.add(q.element);
                }
            }

            for (String id : AAO_ExtractCharter.elementIds(contracts.get(code))) {
                if (coveredIds.contains(id)) {
                    p.covered.add(id);
                } else {
                    p.missing.add(id);
                }
            }
            out.add(p);
        }
        return out;
    }

    /**
     * The model's resolver. Returns null where AAO_Seed.resolve throws, because a quote
     * that is not there is a finding about the model and not a defect in the run.
     */
    private static AAO_Model.Span locate(
        AAO_Source__c src,
        AAO_ExtractCharter.QuotedSpan q,
        Outcome o,
        String code
    ) {
        String text = src.AAO_Normalized_Text__c;
        Integer at = text.indexOf(q.quote);
        if (at < 0) {
            o.spanDrops.add(drop(code, 'not_in_artifact', q.quote));
            return null;
        }
        if (text.indexOf(q.quote, at + 1) >= 0) {
            o.spanDrops.add(drop(code, 'occurs_more_than_once', q.quote));
            return null;
        }
        AAO_Model.Span sp = new AAO_Model.Span();
        sp.sourceId = String.valueOf(src.Id);
        sp.partIndex = 1;
        sp.startOffset = at;
        sp.endOffset = at + q.quote.length();
        sp.quote = q.quote;
        sp.speaker = q.speaker;
        sp.element = q.element;
        return sp;
    }

    private static SpanDrop drop(String code, String reason, String quote) {
        SpanDrop d = new SpanDrop();
        d.contractCode = code;
        d.reason = reason;
        d.quote = quote;
        return d;
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

    /** The rubric as the org actually holds it. Read only, so it is callout safe. */
    public static Map<String, AAO_Evidence_Contract__c> liveContracts() {
        Map<String, AAO_Evidence_Contract__c> byCode = new Map<String, AAO_Evidence_Contract__c>();
        for (AAO_Evidence_Contract__c ec : [
            SELECT Id, AAO_Proposition_Code__c, AAO_Elements__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Contract_State__c != 'Superseded'
            ORDER BY AAO_Proposition_Code__c
        ]) {
            byCode.put(ec.AAO_Proposition_Code__c, ec);
        }
        return byCode;
    }

    // ====================================================================== internals

    private static AAO_Candidate__c buildCandidate(
        Proposal p,
        AAO_Source__c src,
        Map<String, AAO_Evidence_Contract__c> contracts,
        Boolean mark,
        Outcome o
    ) {
        AAO_Evidence_Contract__c ec = contracts.get(p.contractCode);
        if (ec == null) {
            throw new PipelineException(
                'The proposal names contract "' +
                p.contractCode +
                '", which is not in the rubric.'
            );
        }

        AAO_Candidate__c cand = new AAO_Candidate__c(
            AAO_Evidence_Contract__c = ec.Id,
            AAO_Source__c = src.Id,
            AAO_Opportunity__c = src.AAO_Opportunity__c,
            AAO_Account__c = src.AAO_Account__c,
            AAO_Subject_Type__c = p.subjectType,
            AAO_Proposed_Verdict__c = p.proposedVerdict,
            AAO_Spans__c = AAO_Model.serializeSpans(p.spans),
            AAO_Element_Coverage__c = AAO_Model.serializeCoverage(
                AAO_Model.newCoverage(p.covered, p.missing)
            ),
            AAO_Interpretation__c = p.interpretation,
            AAO_Stage__c = 'Adjudicated',
            AAO_Outcome__c = 'Pending',
            AAO_Charter__c = o.charter,
            AAO_Charter_Version__c = o.charterVersion,
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
     *
     * reasonByContract is empty on the fixture path, where nobody_said is asserted rather than
     * determined, and populated on the model path, where something actually read the
     * transcript and can tell the two apart.
     */
    private static List<AAO_Candidate__c> logAbstentions(
        AAO_Source__c src,
        Map<String, AAO_Evidence_Contract__c> contracts,
        Boolean mark,
        String charter,
        String charterVersion,
        Map<Id, String> reasonByContract
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
            String reason = reasonByContract.get(ec.Id);
            rows.add(
                new AAO_Candidate__c(
                    AAO_Evidence_Contract__c = ec.Id,
                    AAO_Source__c = src.Id,
                    AAO_Opportunity__c = src.AAO_Opportunity__c,
                    AAO_Account__c = src.AAO_Account__c,
                    AAO_Subject_Type__c = 'Opportunity',
                    AAO_Stage__c = 'Adjudicated',
                    AAO_Outcome__c = 'Abstained',
                    // On the fixture path this is asserted, not determined: only something
                    // that actually read the transcript can tell nobody_said from
                    // model_missed, and until session 7 nothing did.
                    AAO_Abstention_Reason__c = reason == null ? 'nobody_said' : reason,
                    AAO_Charter__c = charter,
                    AAO_Charter_Version__c = charterVersion,
                    AAO_Publication_State__c = 'Live',
                    AAO_Synthetic__c = mark
                )
            );
        }
        insert rows;
        return rows;
    }
}
