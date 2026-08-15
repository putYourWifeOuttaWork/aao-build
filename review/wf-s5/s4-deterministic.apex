Id SRC = 'a1XWD0000083uvW2AQ';
Id OPP = '006WD00000TWvH0YAL';
System.debug('BEFORE: standing flags = ' + AAO_Identification.standing(OPP)
  + ' shadows = ' + [SELECT COUNT() FROM AAO_Shadow_Person__c]);
Long t0 = System.currentTimeMillis();
AAO_Pass.DeterministicRun r = AAO_Pass.identifyDeterministic(SRC, 'wf-s5');
System.debug('STAGE call2a wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('DETERMINISTIC ' + r);
System.debug('flagsRaised=' + r.flagsRaised + ' flagsCleared=' + r.flagsCleared);
System.debug('remainder=' + r.outcome.remainder);
System.debug('AFTER: standing flags = ' + AAO_Identification.standing(OPP));
for (AAO_Flag__c f : [SELECT AAO_State__c, AAO_Answer_Here__c, AAO_Bound_Key__c,
        AAO_Cleared_At__c, AAO_Subject_Contact__r.Name FROM AAO_Flag__c
        WHERE AAO_Opportunity__c=:OPP AND AAO_Type__c='Identification' ORDER BY AAO_Raised_At__c]) {
    System.debug('  FLAG ' + f.AAO_State__c + ' ' + f.AAO_Answer_Here__c
      + ' cleared=' + f.AAO_Cleared_At__c + ' by=' + f.AAO_Subject_Contact__r.Name);
}
Map<String,Integer> d = new Map<String,Integer>();
for (AAO_Pair__c p : [SELECT AAO_Disposition__c FROM AAO_Pair__c
                      WHERE AAO_Run_Key__c='wf-s5' AND AAO_Stage__c='Identified']) {
    d.put(p.AAO_Disposition__c,(d.get(p.AAO_Disposition__c)==null?0:d.get(p.AAO_Disposition__c))+1);
}
System.debug('DISPOSITIONS ' + d);
