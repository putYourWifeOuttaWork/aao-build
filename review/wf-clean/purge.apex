// LAWFUL PURGE under the twenty-eighth stamp's protocol: run-keyed AAO rows for the three WF
// runs, their projected values, and machine-created Contacts via the create-leg record.
// Seeds stay. Human-watermarked rows stay. THE THREE SOURCES STAY - they are the frozen fixtures.
Id OPP = '006WD00000TWvH0YAL';
System.debug('BEFORE claims=' + [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c=:OPP]
  + ' answers=' + [SELECT COUNT() FROM AAO_Answer__c WHERE AAO_Opportunity__c=:OPP]
  + ' pairs=' + [SELECT COUNT() FROM AAO_Pair__c WHERE AAO_Source__r.AAO_Opportunity__c=:OPP]
  + ' cards=' + [SELECT COUNT() FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c=:OPP]
  + ' maprows=' + [SELECT COUNT() FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c=:OPP]
  + ' shadows=' + [SELECT COUNT() FROM AAO_Shadow_Person__c]
  + ' flags=' + [SELECT COUNT() FROM AAO_Flag__c WHERE AAO_Opportunity__c=:OPP]);
AAO_Purge.Outcome o = AAO_Purge.run(new Set<String>{'wf-s3','wf-s4','wf-s5'}, OPP);
System.debug('PURGE ' + o);
System.debug('AFTER claims=' + [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c=:OPP]
  + ' answers=' + [SELECT COUNT() FROM AAO_Answer__c WHERE AAO_Opportunity__c=:OPP]
  + ' pairs=' + [SELECT COUNT() FROM AAO_Pair__c WHERE AAO_Source__r.AAO_Opportunity__c=:OPP]
  + ' cards=' + [SELECT COUNT() FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c=:OPP]
  + ' maprows=' + [SELECT COUNT() FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c=:OPP]
  + ' shadows=' + [SELECT COUNT() FROM AAO_Shadow_Person__c]
  + ' flags=' + [SELECT COUNT() FROM AAO_Flag__c WHERE AAO_Opportunity__c=:OPP]
  + ' SOURCES=' + [SELECT COUNT() FROM AAO_Source__c WHERE AAO_Opportunity__c=:OPP]);
