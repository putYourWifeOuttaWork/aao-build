/**
 * The evidence-family law on the proposing side. Ruled 47: a candidate declares which
 * family of evidence it rests on, and the declaration decides what shape it has to be.
 *
 * Insert AND update, because a candidate is updated after adjudication (stage, outcome,
 * claim) and nothing should be able to change its family out from under a claim that
 * already cited it.
 */
trigger AAO_CandidateTrigger on AAO_Candidate__c(before insert, before update) {
    AAO_CandidateTriggerHandler.enforceFamily(Trigger.new, Trigger.oldMap);
}
