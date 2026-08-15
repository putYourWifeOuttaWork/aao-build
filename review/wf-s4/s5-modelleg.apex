Id SRC = 'a1XWD0000083uvV2AQ';
Id OPP = '006WD00000TWvH0YAL';
Integer shadowsBefore = [SELECT COUNT() FROM AAO_Shadow_Person__c];
Long t0 = System.currentTimeMillis();
AAO_Resolve.RequestRun r = AAO_Resolve.requests(SRC, 'wf-s4');
System.debug('STAGE call2b wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('MODEL LEG ' + r);
for (AAO_ResolveRequestCharter.Request q : (r.requests==null? new List<AAO_ResolveRequestCharter.Request>() : r.requests)) {
    System.debug('  REQ kind=' + q.kind + ' designator="' + q.designator + '" candidate=' + q.candidate);
}
System.debug('FLAGS RAISED = ' + AAO_Pass.raiseHeld(r));
System.debug('shadows before=' + shadowsBefore + ' after=' + [SELECT COUNT() FROM AAO_Shadow_Person__c]);
for (AAO_Shadow_Person__c s : [SELECT Name, AAO_Designator__c, AAO_Shadow_Key__c,
        AAO_Anchor_Count__c, CreatedDate, LastModifiedDate FROM AAO_Shadow_Person__c]) {
    System.debug('  SHADOW ' + s.Name + ' "' + s.AAO_Designator__c + '" anchors='
      + s.AAO_Anchor_Count__c + ' created=' + s.CreatedDate + ' modified=' + s.LastModifiedDate);
}
