// S5-18, measured on data that already exists rather than predicted. Do internal people ever
// produce AAO_Shadow_Person__c rows today?
Set<Id> internalParticipants = new Set<Id>();
Map<Id,String> whoInternal = new Map<Id,String>();
for (AAO_Participant__c p : [SELECT Id, AAO_Display_Name__c FROM AAO_Participant__c
        WHERE AAO_Internal__c = true]) {
    internalParticipants.add(p.Id); whoInternal.put(p.Id, p.AAO_Display_Name__c);
}
System.debug(LoggingLevel.ERROR, 'internal participants in the org: ' + internalParticipants.size());

Integer shadows = 0, shadowsForInternal = 0;
List<String> hits = new List<String>();
for (AAO_Shadow_Person__c s : [SELECT Id, AAO_Display_Name__c, AAO_Participant__c, AAO_Reason__c
        FROM AAO_Shadow_Person__c]) {
    shadows++;
    if (s.AAO_Participant__c != null && internalParticipants.contains(s.AAO_Participant__c)) {
        shadowsForInternal++;
        hits.add(s.AAO_Display_Name__c + ' (' + s.AAO_Reason__c + ')');
    }
}
System.debug(LoggingLevel.ERROR, 'shadow rows total: ' + shadows +
    '   for an INTERNAL participant: ' + shadowsForInternal + ' ' + hits);

// And the structural reason, measured: can an internal person even have an answer to project from?
Integer internalSubjectAnswers = [SELECT COUNT() FROM AAO_Answer__c
    WHERE AAO_Participant__c IN :internalParticipants];
System.debug(LoggingLevel.ERROR, 'answers whose subject is an internal participant: ' +
    internalSubjectAnswers + '  (the join gate refuses these, so the projection leg is never reached)');
