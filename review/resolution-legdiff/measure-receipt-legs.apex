for (AAO_Run_Receipt__c r : [SELECT AAO_Receipt_Key__c, AAO_Stages__c FROM AAO_Run_Receipt__c]) {
    Integer n = 0; Long wall = 0;
    for (Object o : (List<Object>) JSON.deserializeUntyped(r.AAO_Stages__c)) {
        Map<String, Object> s = (Map<String, Object>) o;
        if (((String) s.get('stage')) == 'resolution') {
            n++; wall += (Long) ((Integer) s.get('wallMs'));
        }
    }
    System.debug(LoggingLevel.ERROR, r.AAO_Receipt_Key__c + ': resolution stages=' + n +
        ' model wall=' + wall + ' ms');
}
