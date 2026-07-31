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
            c.AAO_Synthetic__c = AAO_Synthetic.MARK;
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
            // THE EVIDENCE-FAMILY LAW, ruled 47. This replaced `required` on
            // AAO_Source__c, and it is strictly stronger: required only ever asserted that
            // a lookup was populated and said nothing about whether the row's evidence
            // matched its declared shape. See AAO_EvidenceFamily for the table and for why
            // the "at least one cited row" half is enforced elsewhere.
            String bad = AAO_EvidenceFamily.violation(
                'AAO_Claim__c',
                c.AAO_Basis__c,
                c.AAO_Source__c,
                c.AAO_Spans__c,
                true
            );
            if (bad != null) {
                c.addError(bad);
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
            if (AAO_Synthetic.deletable(c.AAO_Synthetic__c)) {
                continue;
            }
            c.addError(
                'AAO_Claim__c is not deletable. Claims leave by retirement, ' +
                'confirm-then-purge, library acknowledgement first.'
            );
        }
    }
}
