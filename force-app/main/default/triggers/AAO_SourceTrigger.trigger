/**
 * Source immutability and the frozen scope-key composer, plus the live ingestion entry.
 * Logic lives in the handler.
 *
 * AAO_Source__c is ours, so a trigger on it is allowed. Nothing here touches an object we
 * do not own; change detection on customer objects is polling by SystemModstamp against a
 * stored watermark, which is a different mechanism and not this one.
 */
trigger AAO_SourceTrigger on AAO_Source__c(
    before insert,
    after insert,
    before update,
    before delete
) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AAO_SourceTriggerHandler.beforeInsert(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        AAO_SourceTriggerHandler.afterInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        AAO_SourceTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isBefore && Trigger.isDelete) {
        AAO_SourceTriggerHandler.beforeDelete(Trigger.old);
    }
}
