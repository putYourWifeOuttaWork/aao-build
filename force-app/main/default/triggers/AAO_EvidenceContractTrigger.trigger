/**
 * The frozen contract-key composer, the immutability of authored text, and the delete law.
 */
trigger AAO_EvidenceContractTrigger on AAO_Evidence_Contract__c(
    before insert,
    before update,
    before delete
) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AAO_EvidenceContractTriggerHandler.beforeInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        AAO_EvidenceContractTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isBefore && Trigger.isDelete) {
        AAO_EvidenceContractTriggerHandler.beforeDelete(Trigger.old);
    }
}
