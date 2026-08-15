Id SRC = 'a1XWD0000083uvV2AQ';
Id OPP = '006WD00000TWvH0YAL';
Integer shadowsBefore = [SELECT COUNT() FROM AAO_Shadow_Person__c];
Long t0 = System.currentTimeMillis();
AAO_Pass.DeterministicRun r = AAO_Pass.identifyDeterministic(SRC, 'wf-s4');
System.debug('STAGE call2a wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('DETERMINISTIC ' + r);
System.debug('hasRemainder=' + r.hasRemainder + ' remainder=' + r.outcome.remainder);
System.debug('shadows before=' + shadowsBefore + ' after=' + [SELECT COUNT() FROM AAO_Shadow_Person__c]);
Map<String,Integer> d = new Map<String,Integer>();
for (AAO_Pair__c p : [SELECT AAO_Disposition__c FROM AAO_Pair__c
                      WHERE AAO_Run_Key__c='wf-s4' AND AAO_Stage__c='Identified']) {
    d.put(p.AAO_Disposition__c,(d.get(p.AAO_Disposition__c)==null?0:d.get(p.AAO_Disposition__c))+1);
}
System.debug('DISPOSITIONS ' + d);
