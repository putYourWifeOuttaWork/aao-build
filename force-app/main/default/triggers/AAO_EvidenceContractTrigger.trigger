/**
 * The frozen contract-key composer and the immutability of authored text.
 */
trigger AAO_EvidenceContractTrigger on AAO_Evidence_Contract__c(before insert, before update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AAO_EvidenceContractTriggerHandler.beforeInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        AAO_EvidenceContractTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
}
