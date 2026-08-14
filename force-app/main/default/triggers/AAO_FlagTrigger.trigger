/**
 * Flag's trigger law: type is set at birth and never changes. No delete on the live path.
 */
trigger AAO_FlagTrigger on AAO_Flag__c(before insert, before update, before delete) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AAO_FlagTriggerHandler.beforeInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        AAO_FlagTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isBefore && Trigger.isDelete) {
        AAO_FlagTriggerHandler.beforeDelete(Trigger.old);
    }
}