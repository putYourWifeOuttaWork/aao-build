/**
 * Claim is insert only. Block every update and every delete.
 *
 * This is what makes progress visible. Claim one says the answer went to UNVERIFIED on
 * this evidence and stays saying that forever; claim two says it went to TRUE. The delta
 * between them is what a brief or a retrospective reads, and it only exists because
 * nothing ever edits the first one.
 *
 * Claims leave by retirement, confirm-then-purge, library acknowledgement first.
 */
public class AAO_ClaimTriggerHandler {
    public static void beforeInsert(List<AAO_Claim__c> rows) {
        for (AAO_Claim__c c : rows) {
            if (c.AAO_Recorded_At__c == null) {
                c.AAO_Recorded_At__c = System.now();
            }
            // Machine only with a charter stamp. Everything else is HUMAN, because
            // misreading a machine write as human costs one overwrite and misreading a
            // human write as machine destroys a person's judgment.
            if (c.AAO_Actor__c == 'MACHINE' && String.isBlank(c.AAO_Charter__c)) {
                c.addError(
                    'A claim with actor MACHINE must carry a charter stamp. Without one it ' +
                    'is a human establishment and must say so.'
                );
                continue;
            }
            // An establishment requires a citation. A basis of state alone still requires
            // the row be named and its value quoted, which lives on AAO_Claim_Basis__c and
            // cannot be checked here because the junction is inserted after the parent.
            if (c.AAO_Basis__c != 'State' && String.isBlank(c.AAO_Spans__c)) {
                c.addError(
                    'A claim with basis ' +
                    c.AAO_Basis__c +
                    ' must carry the quotes it rests on. An establishment requires a citation.'
                );
            }
        }
    }

    public static void beforeUpdate(List<AAO_Claim__c> rows) {
        for (AAO_Claim__c c : rows) {
            c.addError(
                'AAO_Claim__c is insert only. A claim is one establishment from one piece ' +
                'of evidence, and it is never edited. If the answer moved, write another ' +
                'claim; that is what makes the movement visible.'
            );
        }
    }

    public static void beforeDelete(List<AAO_Claim__c> rows) {
        for (AAO_Claim__c c : rows) {
            c.addError(
                'AAO_Claim__c is not deletable. Claims leave by retirement, ' +
                'confirm-then-purge, library acknowledgement first.'
            );
        }
    }
}
