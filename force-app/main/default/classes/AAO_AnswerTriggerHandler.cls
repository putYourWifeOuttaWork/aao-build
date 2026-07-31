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
            if (old.AAO_Answer_Key__c != null && old.AAO_Answer_Key__c != recomposed) {
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

            if (a.AAO_Established_By__c == 'MACHINE') {
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
