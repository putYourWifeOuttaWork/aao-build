/**
 * Answer's frozen key composer, and the write law.
 *
 * The write law, stated in the field table and enforced here:
 *   - an establishment requires a citation
 *   - spans are byte-verified
 *   - human-authored values are never overwritten or demoted
 *   - emitted values fall inside the discovered vocabulary
 *
 * DUPLICATE_VALUE on AAO_Answer_Key__c is not handled here. It is a merge path and it
 * belongs to the caller, which must catch it, re-read the colliding row, apply precedence
 * and proceed. See AAO_Commit. A trigger cannot do that: by the time the unique index
 * rejects the row the transaction is already the caller's problem.
 */
public class AAO_AnswerTriggerHandler {
    private static final Set<String> VERDICTS = new Set<String>{
        'TRUE',
        'FALSE',
        'UNVERIFIED'
    };

    public static void beforeInsert(List<AAO_Answer__c> rows) {
        for (AAO_Answer__c a : rows) {
            a.AAO_Synthetic__c = AAO_Synthetic.MARK;
            a.AAO_Answer_Key__c = AAO_AnswerKey.compose(a);
        }
        enforce(rows, null);
    }

    public static void beforeUpdate(List<AAO_Answer__c> rows, Map<Id, AAO_Answer__c> oldById) {
        for (AAO_Answer__c a : rows) {
            String recomposed = AAO_AnswerKey.compose(a);
            AAO_Answer__c old = oldById.get(a.Id);
            if (
                old.AAO_Answer_Key__c != null &&
                old.AAO_Answer_Key__c != recomposed &&
                !isOwnContactPromotion(old.AAO_Answer_Key__c, recomposed, a)
            ) {
                a.addError(
                    'The answer key would change from "' +
                    old.AAO_Answer_Key__c +
                    '" to "' +
                    recomposed +
                    '". Identity does not move. This row is an answer to a different ' +
                    'question or about a different subject, which is a different row.'
                );
                continue;
            }
            a.AAO_Answer_Key__c = recomposed;
        }
        enforce(rows, oldById);
    }

    /**
     * THE ONE KEY TRANSITION THAT IS NOT AN IDENTITY MOVE · participant to that participant's
     * OWN Contact, under the A2 person-durable key.
     *
     * The guard above exists because a key change usually means the row became an answer about
     * somebody else, and it has been right every time until now. A2 introduced the one case where
     * it is wrong: a person can be keyed on their per-Source participant row because the org had
     * no Contact for them, and then **the create leg lands their Contact later in the same run**.
     * Priya Natarajan is the live specimen - held across two calls, rostered on the third, a
     * Contact created for her at projection.
     *
     * That is not a different subject. `AAO_AnswerKey`'s own header already says so in as many
     * words: a Contact beside a Participant is *"a resolution outcome of that person, not a
     * second subject"*. So this permits exactly that transition and nothing else:
     *
     *   - the old key must be Participant-resolved and the new key Contact-resolved;
     *   - the contract half of both keys must be identical;
     *   - and **the participant named in the old key must itself carry the Contact named in the
     *     new one**, read from the org rather than assumed.
     *
     * Any other change still throws, including a Contact moving to a different Contact.
     */
    private static Boolean isOwnContactPromotion(
        String oldKey,
        String newKey,
        AAO_Answer__c a
    ) {
        if (a.AAO_Subject_Type__c != 'Participant' || a.AAO_Subject_Contact__c == null) {
            return false;
        }
        List<String> was = oldKey.split('\\|');
        List<String> now = newKey.split('\\|');
        if (was.size() != 4 || now.size() != 4) {
            return false;
        }
        // Same version, same subject type, same contract; only the resolved identity differs.
        if (was[0] != now[0] || was[1] != now[1] || was[3] != now[3]) {
            return false;
        }
        if (now[2] != String.valueOf(a.AAO_Subject_Contact__c)) {
            return false;
        }
        // MEASURED, NOT ASSUMED: the participant the row used to key on must be the very person
        // whose Contact it now keys on.
        Id wasParticipant;
        try {
            wasParticipant = (Id) was[2];
        } catch (Exception e) {
            return false;
        }
        List<AAO_Participant__c> p = [
            SELECT AAO_Contact__c FROM AAO_Participant__c WHERE Id = :wasParticipant LIMIT 1
        ];
        return !p.isEmpty() && p[0].AAO_Contact__c == a.AAO_Subject_Contact__c;
    }

    // ---------------------------------------------------------------- the write law

    private static void enforce(List<AAO_Answer__c> rows, Map<Id, AAO_Answer__c> oldById) {
        List<AAO_Answer__c> needVerification = new List<AAO_Answer__c>();

        for (AAO_Answer__c a : rows) {
            if (a.hasErrors()) {
                continue;
            }

            // Emitted values fall inside the discovered vocabulary. The picklist is
            // restricted, so this only catches an Apex caller bypassing the UI.
            if (!VERDICTS.contains(a.AAO_Verdict__c)) {
                a.addError(
                    'Verdict "' +
                    a.AAO_Verdict__c +
                    '" is outside the vocabulary. The mirror holds only TRUE, FALSE and ' +
                    'UNVERIFIED; abstention and not-addressed never reach here.'
                );
                continue;
            }

            // Human-authored values are never overwritten or demoted.
            if (oldById != null) {
                AAO_Answer__c old = oldById.get(a.Id);
                if (old.AAO_Established_By__c == 'HUMAN' && a.AAO_Established_By__c == 'MACHINE') {
                    a.addError(
                        'This answer was established by a human and a machine write is ' +
                        'trying to take it. Human precedence is absolute: misreading a ' +
                        'machine write as human costs one overwrite, misreading a human ' +
                        'write as machine destroys a person\'s judgment.'
                    );
                    continue;
                }
            }

            // An establishment requires a citation.
            Boolean spansChanged =
                oldById == null || oldById.get(a.Id).AAO_Spans__c != a.AAO_Spans__c;

            // The evidence-family law, ruled 47, reaching its third table. Spans are how a
            // TRANSCRIPT answer is cited; a state answer is cited by the rows its claim
            // named and froze, and demanding a quote of it would demand a quotation from
            // an artifact that does not exist. The requirement is unchanged where it
            // applies: an establishment still requires a citation, and what counts as one
            // now depends on what kind of evidence it stands on.
            Boolean fromArtifact = AAO_EvidenceFamily.needsSource(
                AAO_EvidenceFamily.orTranscript(a.AAO_Basis__c)
            );
            if (a.AAO_Established_By__c == 'MACHINE' && fromArtifact) {
                List<AAO_Model.Span> spans = AAO_Model.parseSpans(a.AAO_Spans__c).spans;
                if (spans.isEmpty()) {
                    a.addError(
                        'A machine establishment with no spans is not an establishment. ' +
                        'An establishment requires a citation.'
                    );
                    continue;
                }
                if (spansChanged) {
                    needVerification.add(a);
                }
            }
        }

        if (!needVerification.isEmpty()) {
            verify(needVerification);
        }
    }

    /** One query for every source any span on any row in this transaction points at. */
    private static void verify(List<AAO_Answer__c> rows) {
        Map<Id, List<AAO_Model.Span>> spansByRow = new Map<Id, List<AAO_Model.Span>>();
        List<List<AAO_Model.Span>> ordered = new List<List<AAO_Model.Span>>();
        Set<Id> sourceIds = new Set<Id>();

        for (AAO_Answer__c a : rows) {
            List<AAO_Model.Span> spans = AAO_Model.parseSpans(a.AAO_Spans__c).spans;
            ordered.add(spans);
            sourceIds.addAll(AAO_SpanVerifier.sourceIds(spans));
        }

        Map<Id, AAO_Source__c> sourceById = new Map<Id, AAO_Source__c>(
            [
                SELECT Id, AAO_Normalized_Text__c, AAO_Diarization__c
                FROM AAO_Source__c
                WHERE Id IN :sourceIds
            ]
        );

        for (Integer i = 0; i < rows.size(); i++) {
            AAO_SpanVerifier.Result r = AAO_SpanVerifier.verify(ordered[i], sourceById);
            if (!r.isOk()) {
                rows[i].addError(
                    'Span verification failed, so this is not a citation: ' + r.describe()
                );
            }
        }
    }
}