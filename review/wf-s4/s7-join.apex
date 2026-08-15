Long t0 = System.currentTimeMillis();
Integer dmlBefore = Limits.getDmlStatements();
AAO_PairCommit.Outcome r = AAO_PairCommit.run('wf-s4', AAO_IngestQueueable.internalDomains());
Integer dmlAfter = Limits.getDmlStatements();
System.debug('STAGE join wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('JOIN ' + r);
System.debug('=== DML STATEMENTS SPENT BY THE JOIN = ' + (dmlAfter - dmlBefore)
    + ' of ' + Limits.getLimitDmlStatements());
System.debug('=== SOQL = ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
