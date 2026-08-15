// WELLS FARGO SESSION 3 · SRC-00000045 · occurred 2026-08-05T18:00:00Z · THE MEASUREMENT RUN.
// One run. No rehearsal. No tuning. Stage 1: call 0, the scope resolver.
Id SRC = 'a1XWD0000083v0L2AQ';
Long t0 = System.currentTimeMillis();
AAO_Pass.ResolveRun r = AAO_Pass.resolve(SRC, 'wf-s3');
System.debug('STAGE call0 wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('CALL0 ' + r);
