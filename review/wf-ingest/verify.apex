Id opp = '006WD00000TWvH0YAL';
for (AAO_Source__c s : [SELECT Id, AAO_Source_Ref__c, AAO_Evidence_Occurred__c
        FROM AAO_Source__c WHERE AAO_Opportunity__c = :opp
        ORDER BY AAO_Evidence_Occurred__c ASC]) {
    List<String> ext = new List<String>(), intl = new List<String>(), noId = new List<String>();
    for (AAO_Participant__c p : [SELECT AAO_Display_Name__c, AAO_Internal__c, AAO_Contact__c,
            AAO_Email__c FROM AAO_Participant__c WHERE AAO_Source__c = :s.Id
            ORDER BY AAO_Display_Name__c]) {
        if (p.AAO_Internal__c) { intl.add(p.AAO_Display_Name__c); } else { ext.add(p.AAO_Display_Name__c); }
        if (p.AAO_Contact__c == null) {
            noId.add(p.AAO_Display_Name__c + (p.AAO_Email__c == null ? ' (no email)' : ' (email)'));
        }
    }
    System.debug(LoggingLevel.ERROR, s.AAO_Source_Ref__c + '  ' +
        s.AAO_Evidence_Occurred__c.formatGmt('yyyy-MM-dd HH:mm') + 'Z');
    System.debug(LoggingLevel.ERROR, '   INTERNAL (' + intl.size() + '): ' + intl);
    System.debug(LoggingLevel.ERROR, '   external (' + ext.size() + '): ' + ext);
    System.debug(LoggingLevel.ERROR, '   no Contact link: ' + noId);
}
System.debug(LoggingLevel.ERROR, 'Bettina anywhere? ' +
    [SELECT COUNT() FROM AAO_Participant__c
     WHERE AAO_Source__r.AAO_Opportunity__c = :opp AND AAO_Display_Name__c LIKE '%Bettina%']);
