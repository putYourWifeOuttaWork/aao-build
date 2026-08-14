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

    /**
     * Insert only, with ONE narrow exception: retirement.
     *
     * **CLAIMS RETIRE, NEVER DELETE**, ruled 6 August, the locked record law reaching this
     * ledger. A claim that should never have established anything cannot be deleted (evidence
     * of our own mistake is exactly the thing worth keeping) and cannot be corrected in place
     * (that is editing history). So it is marked retired, the replay skips it, and retraction
     * clears the map value it carried.
     *
     * **The exception is as narrow as the ruling.** Only the three retirement fields may move;
     * every other field is as immutable as it was before. And it is ONE-WAY: a retired claim
     * is never un-retired, because a ledger that can be edited back into a state it was never
     * in is not a ledger.
     */
    public static void beforeUpdate(List<AAO_Claim__c> rows) {
        // Outside trigger context there is no prior row to compare against, so nothing can be
        // shown to be only-a-retirement. Block, which is the behaviour that held before the
        // exception existed: the safe direction is refusing an edit we cannot prove is narrow.
        Map<Id, AAO_Claim__c> before = Trigger.old == null
            ? new Map<Id, AAO_Claim__c>()
            : new Map<Id, AAO_Claim__c>((List<AAO_Claim__c>) Trigger.old);
        for (AAO_Claim__c c : rows) {
            AAO_Claim__c was = before.get(c.Id);
            if (was == null) {
                c.addError(
                    'AAO_Claim__c is insert only apart from retirement, and this update ' +
                    'cannot be checked against the row it replaces.'
                );
                continue;
            }
            if (was.AAO_Retired__c == true && c.AAO_Retired__c != true) {
                c.addError(
                    'A retired claim is never un-retired. Retirement records that we decided ' +
                    'this establishment was wrong; reversing it in place would edit the ' +
                    'ledger into a state it was never in. If the establishment is right ' +
                    'after all, the evidence still exists and can be read again into a new ' +
                    'claim that says so on its own row.'
                );
                continue;
            }
            String moved = fieldMovedOutsideRetirement(was, c);
            if (moved != null) {
                c.addError(
                    'AAO_Claim__c is insert only apart from retirement, and this update ' +
                    'moves ' + moved + '. A claim is one establishment from one piece of ' +
                    'evidence, and it is never edited. If the answer moved, write another ' +
                    'claim; that is what makes the movement visible.'
                );
                continue;
            }
            if (c.AAO_Retired__c == true && String.isBlank(c.AAO_Retired_Because__c)) {
                c.addError(
                    'A retirement carries its reason. A retired claim with no stated reason ' +
                    'is indistinguishable from a deletion that happened to leave a row ' +
                    'behind, and reading what we got wrong is the whole point of retiring ' +
                    'rather than deleting.'
                );
            }
        }
    }

    /**
     * The first field that changed and is not one of the three retirement fields, or null.
     * Described by the describe rather than by a hand-kept list, so a field added to this
     * object next month is immutable by default instead of by somebody remembering.
     */
    private static String fieldMovedOutsideRetirement(AAO_Claim__c was, AAO_Claim__c now) {
        Set<String> allowed = new Set<String>{
            'aao_retired__c', 'aao_retired_because__c', 'aao_retired_at__c'
        };
        for (String f : AAO_Claim__c.SObjectType.getDescribe().fields.getMap().keySet()) {
            if (allowed.contains(f.toLowerCase())) {
                continue;
            }
            Object a = was.get(f);
            Object b = now.get(f);
            if (a == null ? b != null : !a.equals(b)) {
                return f;
            }
        }
        return null;
    }

    public static void beforeDelete(List<AAO_Claim__c> rows) {
        for (AAO_Claim__c c : rows) {
            if (AAO_Synthetic.deletable(c.AAO_Synthetic__c)) {
                continue;
            }
            // The purge door, twenty-eighth stamp: open only inside AAO_Purge.run's own
            // transaction, only for the enumerated fixture opportunity.
            if (AAO_Purge.allowsClaim(c)) {
                continue;
            }
            c.addError(
                'AAO_Claim__c is not deletable. Claims leave by retirement, ' +
                'confirm-then-purge, library acknowledgement first.'
            );
        }
    }
}