// Its OWN transaction: requests() throws if any DML has run, because the callout below
// would fail with uncommitted work pending.
Id SRC = 'a1XWD0000083v0L2AQ';
Id OPP = '006WD00000TWvH0YAL';
Long t0 = System.currentTimeMillis();
AAO_Resolve.RequestRun r = AAO_Resolve.requests(SRC, 'wf-s3');
System.debug('STAGE call2b wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('MODEL LEG ' + r);
System.debug('call=' + r.call);
for (AAO_ResolveRequestCharter.Request q : (r.requests == null ? new List<AAO_ResolveRequestCharter.Request>() : r.requests)) {
    System.debug('  REQ kind=' + q.kind + ' designator="' + q.designator + '" candidate=' + q.candidate
        + ' basis=' + (q.basis == null ? '' : q.basis.abbreviate(120)));
}
Integer raised = AAO_Pass.raiseHeld(r);
System.debug('FLAGS RAISED BY THE MODEL LEG = ' + raised);
