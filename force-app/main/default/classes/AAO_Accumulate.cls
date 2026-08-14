/**
 * How a claim moves an answer. Commit calls this going forwards; Replay calls this
 * rebuilding from history. One function, deliberately, because two implementations of
 * accumulation would be two accounts of one fact with no mechanism to say which had
 * drifted, and the replay test would then be testing itself.
 */
public class AAO_Accumulate {
    /**
     * The claim outcome for evidence that overlaps what already stands on the answer. Named
     * here rather than typed as a literal at each site, because it has to agree with the
     * restricted picklist on `AAO_Claim__c.AAO_Outcome__c` and a typo would be a runtime
     * failure at the join rather than a compile failure here.
     */
    public static final String CORROBORATED = 'Corroborated';

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
        'AAO_Element_Completeness__c',
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
        answer.AAO_Element_Completeness__c = AAO_Model.serializeCoverage(
            mergeCoverage(answer.AAO_Element_Completeness__c, claim.AAO_Element_Completeness__c)
        );

        // THE VERDICT IS MONOTONE OVER EVIDENCE STRENGTH, never last-write-wins. Ruled
        // 6 August from the a20 rows, and the defect it closes is precise: `buq4` arrived
        // Partial and Upheld after `buq1` had established Jefferson's Evaluator answer TRUE
        // from Full evidence, and this line wrote TRUE back down to UNVERIFIED. `poq5` did
        // the same to his Political Structure half, and that demotion flowed through the
        // ceiling and changed his placement on the map.
        //
        // **Partial accrues, places nobody, and DISPLACES NOTHING.** The accrual is not
        // discarded: its spans and its coverage merge above, its claim is written, and it is
        // on the record as evidence considered. What it may not do is take a standing
        // establishment down with it.
        if (movesTheAnswer(claim) && !weakens(answer, claim)) {
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
     * Whether this claim is allowed to move what the answer says, as opposed to only adding
     * itself to the evidence behind it.
     *
     * Two outcomes accrue without moving anything, and they are different facts wearing the
     * same shape: REINFORCED is the person saying it again, CORROBORATED is a second read
     * finding the same utterance. Both write their claim, both merge their spans, neither
     * touches the verdict or the interpretation. The sixty-ninth stamp's law that the three
     * axes never collapse is why they are two values rather than one.
     */
    @TestVisible
    private static Boolean movesTheAnswer(AAO_Claim__c claim) {
        return claim.AAO_Outcome__c != 'Reinforced' && claim.AAO_Outcome__c != CORROBORATED;
    }

    /**
     * DOES THIS CLAIM'S EVIDENCE OVERLAP EVIDENCE ALREADY STANDING ON THE ANSWER?
     *
     * The eightieth stamp's ruling, and it is the twenty-seventh stamp's merge key pointed at
     * the join: **a claim reinforces only where its spans intersect NO span already standing on
     * the answer, compared within the same Source. Any intersection, not only identity, and not
     * only containment.**
     *
     * WHY THE RULE WAS NEEDED, measured on Emerson: seven answers carried two claims quoting
     * IDENTICAL byte ranges, because the two comprehensive reads found one utterance twice and
     * read a different voiced meaning off it. The twenty-seventh stamp deliberately lets those
     * both ride to call 3 blind, which is right at verify; nobody priced the JOIN, where the
     * answer key is subject plus contract and the two meanings collapse onto one answer. The
     * second claim then read as the buyer pressing the point again, and the reinforcement count
     * is a number guidance ORDERS BY.
     *
     * **CROSS-SOURCE NEEDS NO SPECIAL CASE and that is not an accident of the implementation.**
     * Byte offsets are per-artifact, so a March claim and a June claim can carry the same
     * numbers and mean different words. Comparing only within a Source therefore delivers the
     * rejected option (b), a different occasion, for free — while keeping what (b) would have
     * destroyed: a person who presses the same point three times in one call did press it three
     * times, at three different offsets, and every one of them still counts.
     *
     * Half-open ranges, the same arithmetic the resolution stage's own merge uses, so the two
     * places that test overlap cannot drift into disagreeing about what overlap means.
     */
    public static Boolean intersectsStanding(String standingSpansJson, String incomingSpansJson) {
        List<AAO_Model.Span> standing = AAO_Model.parseSpans(standingSpansJson).spans;
        if (standing.isEmpty()) {
            return false;
        }
        for (AAO_Model.Span incoming : AAO_Model.parseSpans(incomingSpansJson).spans) {
            for (AAO_Model.Span held : standing) {
                if (overlaps(held, incoming)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Two spans overlap where they name the same artifact and their ranges touch.
     *
     * A null offset is NOT an overlap. A span that cannot say where it is cannot be shown to
     * be the same words as another, and the safe direction on an unknown is to let the claim
     * count: undercounting reinforcement hides a real press, and this rule exists to stop
     * OVERcounting, so its own uncertainty resolves the other way.
     */
    private static Boolean overlaps(AAO_Model.Span a, AAO_Model.Span b) {
        if (a.sourceId == null || b.sourceId == null || a.sourceId != b.sourceId) {
            return false;
        }
        if (a.startOffset == null || a.endOffset == null ||
            b.startOffset == null || b.endOffset == null) {
            return false;
        }
        return a.startOffset < b.endOffset && b.startOffset < a.endOffset;
    }

    /**
     * THE STRENGTH ORDER, and it is deliberately short. `TRUE` is an establishment; anything
     * else is not. Nothing here ranks UNVERIFIED against null, because a claim always carries
     * a verdict and the empty state writes no claim at all.
     *
     * **This is not "newer never wins".** An establishment REPLACING an establishment is
     * ordinary and must still happen - reinforcement, supersession, a later call moving a
     * value. What is forbidden is an accrual pulling an establishment down, which is a
     * different thing wearing the same shape.
     *
     * **Human precedence sits above this and is enforced earlier**, in Commit's own read: a
     * human-established answer is never reached by a machine claim at all. So this rule only
     * ever arbitrates between two machine claims about one proposition.
     */
    @TestVisible
    private static Boolean weakens(AAO_Answer__c answer, AAO_Claim__c claim) {
        return answer.AAO_Verdict__c == 'TRUE' && claim.AAO_Verdict_After__c != 'TRUE';
    }

    /**
     * REBUILD AN ANSWER'S VERDICT FROM ITS CLAIMS, the counter's own pattern, ruled 6 August.
     *
     * The guard above stops the clobber at write time; this proves it afterwards, and the two
     * are not redundant. The guard depends on the order claims arrive in; the rebuild does
     * not, so a run that committed its pairs in a different order lands on the same verdict.
     * That is the replay invariant made executable for the verdict rather than only asserted:
     * **replaying claims in evidence-occurred order must reconstruct every answer exactly.**
     *
     * Monotone over strength: an establishment anywhere in the ledger is an establishment.
     * Returns null where the claims carry nothing, which the caller reads as leave-alone.
     */
    public static String verdictFromClaims(List<AAO_Claim__c> claims) {
        if (claims == null || claims.isEmpty()) {
            return null;
        }
        String strongest;
        for (AAO_Claim__c c : claims) {
            if (c.AAO_Verdict_After__c == 'TRUE') {
                return 'TRUE';
            }
            if (strongest == null) {
                strongest = c.AAO_Verdict_After__c;
            }
        }
        return strongest;
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
     * The routing law on Candidate.AAO_Element_Completeness__c: full coverage writes the
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
            // Nothing was said about this proposition, so nothing is written. Silence stays
            // silence; this is the one thing completeness still decides.
            return null;
        }
        // COMPLETENESS IS DATA, NEVER A GATE. Matthew's ruling at the sixty-ninth stamp: the
        // blind verifier decides truth and element completeness is recorded beside it. The
        // retired branch returned UNVERIFIED for incomplete coverage, which let a read-side
        // judgment override the checker; the layering the architecture rests on is call 1
        // finds, call 3 judges, and no read-side hedge outranks the verifier.
        //
        // What completeness still does, and it is not nothing: it rides on the answer as a
        // QUALITY reading, it is what the join-side union accumulates across utterances, and
        // it is what the Inspector can show a reader. It simply stops deciding.
        //
        // `contractElements` stays in the signature deliberately. It is what `isFull` needs to
        // compute completeness for the row, and removing the parameter would make a later
        // session reintroduce the gate by rebuilding the lookup rather than finding it here.
        return proposedVerdict;
    }
}