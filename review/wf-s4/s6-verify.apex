Long t0 = System.currentTimeMillis();
AAO_Pass.VerifyRun r = AAO_Pass.verify('wf-s4');
System.debug('STAGE call3 wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('VERIFY batches=' + r.batches + ' upheld=' + r.upheld + ' refused=' + r.refused);
System.debug('call=' + r.call);
