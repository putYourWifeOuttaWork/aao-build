/**
 * Source immutability and the frozen scope-key composer. Logic lives in the handler.
 */
trigger AAO_SourceTrigger on AAO_Source__c(before insert, before update, before delete) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AAO_SourceTriggerHandler.beforeInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        AAO_SourceTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isBefore && Trigger.isDelete) {
        AAO_SourceTriggerHandler.beforeDelete(Trigger.old);
    }
}
