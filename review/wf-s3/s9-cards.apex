Id OPP = '006WD00000TWvH0YAL';
Long t0 = System.currentTimeMillis();
AAO_Cards.Outcome r = AAO_Cards.run(OPP, 'wf-s3');
System.debug('STAGE cards wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('CARDS ' + r);
