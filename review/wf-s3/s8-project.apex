Id OPP = '006WD00000TWvH0YAL';
Long t0 = System.currentTimeMillis();
AAO_Project.Outcome r = AAO_Project.run(OPP, 'wf-s3');
System.debug('STAGE projection wall_ms=' + (System.currentTimeMillis() - t0));
System.debug('PROJECTION ' + r);
