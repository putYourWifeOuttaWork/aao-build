/**
 * Claim is insert only. Block every update and every delete.
 */
trigger AAO_ClaimTrigger on AAO_Claim__c(before insert, before update, before delete) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AAO_ClaimTriggerHandler.beforeInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        AAO_ClaimTriggerHandler.beforeUpdate(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isDelete) {
        AAO_ClaimTriggerHandler.beforeDelete(Trigger.old);
    }
}