/**
 * Answer's frozen key composer and the write law. DUPLICATE_VALUE is the caller's merge
 * path, not this trigger's error path -- see AAO_Commit.
 */
trigger AAO_AnswerTrigger on AAO_Answer__c(before insert, before update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AAO_AnswerTriggerHandler.beforeInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        AAO_AnswerTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
}