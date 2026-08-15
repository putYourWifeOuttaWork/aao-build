Id SRC = 'a1XWD0000083v0L2AQ';
Long t0 = System.currentTimeMillis();
AAO_Pass.SweepRun r = AAO_Pass.locateRead(SRC, 'wf-s3', 1);
System.debug('STAGE read1 wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('READ1 ' + r);
