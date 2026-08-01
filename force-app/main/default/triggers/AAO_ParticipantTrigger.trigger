/**
 * The participant junction is a record of who was on a piece of evidence, so it inherits the
 * population of the run that wrote it and it is not deletable outside a purge: deleting a
 * participant row would silently lower a coverage answer that a claim already rests on.
 */
trigger AAO_ParticipantTrigger on AAO_Participant__c(before insert, before delete) {
    if (Trigger.isInsert) {
        for (AAO_Participant__c p : Trigger.new) {
            p.AAO_Synthetic__c = AAO_Synthetic.MARK;
        }
    } else {
        for (AAO_Participant__c p : Trigger.old) {
            if (AAO_Synthetic.deletable(p.AAO_Synthetic__c)) {
                continue;
            }
            p.addError(
                'AAO_Participant__c is not deletable. It records that a person was on a ' +
                'piece of evidence, and coverage answers are counts over these rows: ' +
                'removing one silently lowers an answer that claims already rest on.'
            );
        }
    }
}
