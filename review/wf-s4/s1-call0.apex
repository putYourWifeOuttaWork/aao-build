// WELLS FARGO SESSION 4 · SRC-00000039 · occurred 2026-08-19T14:00:00Z · STACKED ON s3, NO PURGE.
Id SRC = 'a1XWD0000083uvV2AQ';
Long t0 = System.currentTimeMillis();
AAO_Pass.ResolveRun r = AAO_Pass.resolve(SRC, 'wf-s4');
System.debug('STAGE call0 wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('CALL0 scope=' + r.verdict.scope + ' opp=' + r.verdict.opportunity);
