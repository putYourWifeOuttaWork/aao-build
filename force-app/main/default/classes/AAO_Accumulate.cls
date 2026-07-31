/**
 * How a claim moves an answer. Commit calls this going forwards; Replay calls this
 * rebuilding from history. One function, deliberately, because two implementations of
 * accumulation would be two accounts of one fact with no mechanism to say which had
 * drifted, and the replay test would then be testing itself.
 */
public class AAO_Accumulate {
    /**
     * The fields replay is answerable for. Anything not on this list is either derived
     * elsewhere or cannot be reconstructed at all, and asserting on it would make the
     * replay test fail for reasons that are not replay's business.
     *
     * Deliberately excluded:
     *   AAO_Projected_Value__c / AAO_Projected_Modstamp__c — outbound, captured at the
     *     instant of our write. The field table says in terms: cannot be reconstructed
     *     later. A timestamp that moved while the value did not is a human confirmation
     *     and the only evidence of one that exists.
     *   AAO_Publication_State__c — ratification writes it, not evidence.
     *   AAO_Question_Fingerprint__c — compared on read, not established by a claim.
     */
    public static final List<String> REPLAY_GOVERNED = new List<String>{
        'AAO_Verdict__c',
        'AAO_Spans__c',
        'AAO_Element_Coverage__c',
        'AAO_Interpretation__c',
        'AAO_Established_By__c',
        'AAO_Charter_Version__c',
        'AAO_Rubric_Version__c',
        'AAO_Evidence_Occurred__c',
        'AAO_Subject_Type__c',
        'AAO_Evidence_Contract__c',
        'AAO_Opportunity__c',
        'AAO_Account__c',
        'AAO_Subject_Contact__c'
    };

    /**
     * Apply one claim to an answer, in place. The answer may be a fresh unsaved row.
     *
     * A Reinforced claim accumulates its quotes and moves no verdict, which is what
     * makes how often has this been pressed countable without corrupting what stands.
     */
    public static void apply(AAO_Answer__c answer, AAO_Claim__c claim) {
        answer.AAO_Subject_Type__c = claim.AAO_Subject_Type__c;
        answer.AAO_Subject_Contact__c = claim.AAO_Subject_Contact__c;
        answer.AAO_Evidence_Contract__c = claim.AAO_Evidence_Contract__c;
        answer.AAO_Opportunity__c = claim.AAO_Opportunity__c;
        answer.AAO_Account__c = claim.AAO_Account__c;

        answer.AAO_Spans__c = AAO_Model.serializeSpans(
            mergeSpans(answer.AAO_Spans__c, claim.AAO_Spans__c)
        );
        answer.AAO_Element_Coverage__c = AAO_Model.serializeCoverage(
            mergeCoverage(answer.AAO_Element_Coverage__c, claim.AAO_Element_Coverage__c)
        );

        if (claim.AAO_Outcome__c != 'Reinforced') {
            answer.AAO_Verdict__c = claim.AAO_Verdict_After__c;
            answer.AAO_Interpretation__c = claim.AAO_Interpretation__c;
            answer.AAO_Established_By__c = claim.AAO_Actor__c;
            answer.AAO_Charter_Version__c = claim.AAO_Charter_Version__c;
            answer.AAO_Rubric_Version__c = claim.AAO_Rubric_Version__c;
        }

        // The occurred clock only ever moves forwards, so a backfilled 2024 transcript
        // arriving today does not drag the answer's clock backwards past what already
        // stands on it.
        if (
            answer.AAO_Evidence_Occurred__c == null ||
            (claim.AAO_Evidence_Occurred__c != null &&
            claim.AAO_Evidence_Occurred__c > answer.AAO_Evidence_Occurred__c)
        ) {
            answer.AAO_Evidence_Occurred__c = claim.AAO_Evidence_Occurred__c;
        }
    }

    /**
     * Union by (source, offsets), keeping the first occurrence. Order is by source then
     * start offset, so the accumulated set reads in document order within an artifact
     * and is stable across a rebuild.
     */
    public static List<AAO_Model.Span> mergeSpans(String existingJson, String incomingJson) {
        Map<String, AAO_Model.Span> byFingerprint = new Map<String, AAO_Model.Span>();
        for (AAO_Model.Span sp : AAO_Model.parseSpans(existingJson).spans) {
            byFingerprint.put(sp.fingerprint(), sp);
        }
        for (AAO_Model.Span sp : AAO_Model.parseSpans(incomingJson).spans) {
            if (!byFingerprint.containsKey(sp.fingerprint())) {
                byFingerprint.put(sp.fingerprint(), sp);
            }
        }
        List<String> keys = new List<String>(byFingerprint.keySet());
        keys.sort();
        List<AAO_Model.Span> out = new List<AAO_Model.Span>();
        for (String k : keys) {
            out.add(byFingerprint.get(k));
        }
        return out;
    }

    /**
     * Covered is a union. Missing is what was missing before, less whatever this claim
     * covered — never the incoming claim's missing list, because a claim only knows what
     * it looked at and the answer knows what has accumulated.
     */
    public static AAO_Model.Coverage mergeCoverage(String existingJson, String incomingJson) {
        AAO_Model.Coverage existing = AAO_Model.parseCoverage(existingJson);
        AAO_Model.Coverage incoming = AAO_Model.parseCoverage(incomingJson);

        Set<String> covered = new Set<String>(existing.covered);
        covered.addAll(incoming.covered);

        Set<String> missing = new Set<String>(existing.missing);
        missing.addAll(incoming.missing);
        missing.removeAll(covered);

        List<String> coveredList = new List<String>(covered);
        coveredList.sort();
        List<String> missingList = new List<String>(missing);
        missingList.sort();

        return AAO_Model.newCoverage(coveredList, missingList);
    }

    /**
     * The routing law on Candidate.AAO_Element_Coverage__c: full coverage writes the
     * proposed verdict, partial writes UNVERIFIED with the spans that exist, none writes
     * nothing. Returns null where nothing should be written.
     *
     * Coverage here is the ACCUMULATED coverage at the answer, not this pass's alone.
     * That is what lets call two say there was already partial evidence and now it is
     * sufficient.
     *
     * contractElements is the authority on what full means. Before session 11 this read
     * the proposal's own missing list, so a proposal could declare itself complete by
     * sending an empty missing list and the verdict went through unchallenged.
     */
    public static String verdictFor(
        AAO_Model.Coverage accumulated,
        String proposedVerdict,
        List<String> contractElements
    ) {
        if (accumulated.isNone()) {
            return null;
        }
        if (accumulated.isFull(contractElements)) {
            return proposedVerdict;
        }
        return 'UNVERIFIED';
    }
}
