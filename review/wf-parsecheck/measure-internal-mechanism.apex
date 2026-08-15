Set<String> d = AAO_IngestQueueable.internalDomains();
System.debug(LoggingLevel.ERROR, 'RUNTIME internal domains: ' + d);
System.debug(LoggingLevel.ERROR, 'opentext.com internal? ' + d.contains('opentext.com'));
AAO_Model.Speaker sp = new AAO_Model.Speaker();
sp.email = 'dana.whitfield@opentext.com';
System.debug(LoggingLevel.ERROR, 'isInternal(dana@opentext.com) = ' +
    AAO_SpeakerRule.isInternal(sp, d));
AAO_Model.Speaker u = new AAO_Model.Speaker();
u.userId = '005Hn00000JHb1eIAD';
System.debug(LoggingLevel.ERROR, 'isInternal(userId only, no email) = ' +
    AAO_SpeakerRule.isInternal(u, d));
