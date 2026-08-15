Long t0 = System.currentTimeMillis();
AAO_Pass.VerifyRun r = AAO_Pass.verify('wf-s3');
System.debug('STAGE call3 wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('VERIFY ' + r);
