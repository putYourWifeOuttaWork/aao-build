/**
 * The reverse half of the evidence-family law, and the half a trigger can hold absolutely:
 * a cited row may only hang off a claim that declared it rests on state.
 */
trigger AAO_ClaimBasisTrigger on AAO_Claim_Basis__c(before insert) {
    AAO_ClaimBasisTriggerHandler.beforeInsert(Trigger.new);
}