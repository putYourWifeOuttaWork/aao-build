AAO_Run_Receipt__c r = [SELECT Name, AAO_Stage_Count__c, AAO_Total_Wall_Ms__c, AAO_Callouts__c,
    AAO_Worst_Callout_Ms__c, AAO_Cache_State__c, AAO_Split_Events__c, AAO_Stages__c,
    AAO_Normalizer_Version__c, AAO_First_Stage_At__c, AAO_Last_Stage_At__c
    FROM AAO_Run_Receipt__c WHERE AAO_Run_Key__c = 'wf-s3' LIMIT 1];
System.debug('RECEIPT ' + r.Name + ' stages=' + r.AAO_Stage_Count__c
    + ' wall_ms=' + r.AAO_Total_Wall_Ms__c + ' callouts=' + r.AAO_Callouts__c
    + ' worst_callout_ms=' + r.AAO_Worst_Callout_Ms__c + ' cache=' + r.AAO_Cache_State__c
    + ' splits=' + r.AAO_Split_Events__c + ' normalizer=' + r.AAO_Normalizer_Version__c);
System.debug('window ' + r.AAO_First_Stage_At__c + ' -> ' + r.AAO_Last_Stage_At__c);
System.debug('STAGES:');
for (String line : r.AAO_Stages__c.split('\n')) { System.debug('  ' + line); }
