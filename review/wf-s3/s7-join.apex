Long t0 = System.currentTimeMillis();
AAO_PairCommit.Outcome r = AAO_PairCommit.run('wf-s3', AAO_IngestQueueable.internalDomains());
System.debug('STAGE join wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('JOIN ' + r);
System.debug('GOVERNORS ' + AAO_RunExport.governors('join'));
