Long t0 = System.currentTimeMillis();
Integer before = Limits.getDmlStatements();
AAO_PairCommit.Outcome r = AAO_PairCommit.run('wf-s5', AAO_IngestQueueable.internalDomains());
System.debug('STAGE join wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('JOIN ' + r);
System.debug('=== JOIN DML = ' + (Limits.getDmlStatements() - before) + ' of ' + Limits.getLimitDmlStatements()
  + ' | SOQL = ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
