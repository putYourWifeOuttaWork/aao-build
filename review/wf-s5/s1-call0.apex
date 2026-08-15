Id SRC = 'a1XWD0000083uvW2AQ';
Long t0 = System.currentTimeMillis();
AAO_Pass.ResolveRun r = AAO_Pass.resolve(SRC, 'wf-s5');
System.debug('STAGE call0 wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('CALL0 scope=' + r.verdict.scope + ' opp=' + r.verdict.opportunity);
