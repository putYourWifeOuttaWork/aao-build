/**
 * The pair ledger's two shapes, the prohibition law made physical, and the delete law.
 */
trigger AAO_PairTrigger on AAO_Pair__c(before insert, before update, before delete) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AAO_PairTriggerHandler.beforeInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        AAO_PairTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isBefore && Trigger.isDelete) {
        AAO_PairTriggerHandler.beforeDelete(Trigger.old);
    }
}