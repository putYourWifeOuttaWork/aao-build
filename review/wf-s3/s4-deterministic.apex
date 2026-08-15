Id SRC = 'a1XWD0000083v0L2AQ';
Id OPP = '006WD00000TWvH0YAL';
Long t0 = System.currentTimeMillis();
AAO_Pass.DeterministicRun r = AAO_Pass.identifyDeterministic(SRC, 'wf-s3');
System.debug('STAGE call2a wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('DETERMINISTIC ' + r);
System.debug('hasRemainder=' + r.hasRemainder + ' remainderRefs=' + r.outcome.remainder);
System.debug('=== IDENTIFICATION FLAGS AFTER THE DETERMINISTIC LEG ===');
for (AAO_Flag__c f : [SELECT AAO_Cause__c, AAO_State__c, AAO_Bound_Key__c, AAO_Answer_Here__c,
                             AAO_Missing_Members__c
                      FROM AAO_Flag__c WHERE AAO_Opportunity__c = :OPP
                        AND AAO_Type__c = 'Identification']) {
    System.debug('  FLAG ' + f.AAO_Cause__c + ' / ' + f.AAO_State__c + ' / '
        + f.AAO_Answer_Here__c + ' | ' + (f.AAO_Missing_Members__c == null ? '' :
           f.AAO_Missing_Members__c.abbreviate(160)));
}
System.debug('=== DISPOSITIONS ===');
Map<String,Integer> byDisp = new Map<String,Integer>();
for (AAO_Pair__c p : [SELECT AAO_Disposition__c FROM AAO_Pair__c
                      WHERE AAO_Run_Key__c='wf-s3' AND AAO_Stage__c='Identified']) {
    byDisp.put(p.AAO_Disposition__c, (byDisp.get(p.AAO_Disposition__c)==null?0:byDisp.get(p.AAO_Disposition__c))+1);
}
System.debug('  ' + byDisp);
System.debug('=== SHADOW PERSONS ORG-WIDE = ' + [SELECT COUNT() FROM AAO_Shadow_Person__c]);
