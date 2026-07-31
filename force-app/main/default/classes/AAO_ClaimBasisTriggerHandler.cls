/**
 * The reverse half of the evidence-family law.
 *
 * The forward direction — a State claim must HAVE cited rows — cannot be held by a trigger,
 * because the junction does not exist until the claim has an Id. This direction can be held
 * absolutely, and it is the one an accident is likelier to take: a claim carrying receipts
 * it never declared is a claim whose receipts do not match its story. Anyone reading it
 * would see rows cited under a Transcript basis and have no way to know whether the answer
 * was read from the artifact or from the records.
 */
public class AAO_ClaimBasisTriggerHandler {
    public static void beforeInsert(List<AAO_Claim_Basis__c> rows) {
        Set<Id> claimIds = new Set<Id>();
        for (AAO_Claim_Basis__c b : rows) {
            if (b.AAO_Claim__c != null) {
                claimIds.add(b.AAO_Claim__c);
            }
        }
        Map<Id, AAO_Claim__c> claims = new Map<Id, AAO_Claim__c>(
            [SELECT Id, AAO_Basis__c FROM AAO_Claim__c WHERE Id IN :claimIds]
        );

        for (AAO_Claim_Basis__c b : rows) {
            // The junction inherits the population of the run that wrote it, the same way
            // every other row does. Nothing else in this table sets it.
            b.AAO_Synthetic__c = AAO_Synthetic.MARK;

            AAO_Claim__c c = claims.get(b.AAO_Claim__c);
            if (c == null) {
                b.addError('A cited row must name the claim it supports.');
                continue;
            }
            if (!AAO_EvidenceFamily.needsCitedRows(c.AAO_Basis__c)) {
                b.addError(
                    'This cited row hangs off a claim with basis ' +
                    c.AAO_Basis__c +
                    ', which declared it rests on an artifact. A claim that cites records ' +
                    'has to say so: basis State, or Both.'
                );
            }
        }
    }
}
