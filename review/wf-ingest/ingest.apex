// COLD INGEST of the three Wells Fargo sessions, in occurred order. INGEST ONLY: AAO_Ingest.AUTO
// is off, so no pass runs and nothing is graded. The roster is SOURCE METADATA supplied here the
// way every real fixture receives it - the VTT body never carried the side split and must not.
AAO_Ingest.AUTO = false;
Id opp = '006WD00000TWvH0YAL';
Id acct = [SELECT AccountId FROM Opportunity WHERE Id = :opp].AccountId;

// The six Wells Fargo people, by contactId, with the emails the org actually holds.
Map<String, String> cid = new Map<String, String>{
    'Katherine Villanueva' => '003WD00001QZr0LYAT', 'Rohan Deshpande' => '003WD00001QZiGRYA1',
    'Meredith Cho' => '003WD00001QZVZNYA5', 'Tom Brzezinski' => '003WD00001QZAwJYAX',
    'Alison Reyes' => '003WD00001QZr1xYAD', 'Jared Kim' => '003WD00001QZBfUYAX'};
Map<String, String> mail = new Map<String, String>();
for (Contact c : [SELECT Id, Name, Email FROM Contact WHERE Id IN :cid.values()]) {
    mail.put(c.Name, c.Email);
}

// The seller side. INTERNAL BY EMAIL DOMAIN, measured: AAO_SpeakerRule.isInternal reads
// sp.domain() and nothing else, so a userId would mark nobody. opentext.com is already in the
// runtime internal set, so the OpenText framing stays intact and no code changes.
Map<String, String> sellers = new Map<String, String>{
    'Dana Whitfield' => 'dana.whitfield@opentext.com',
    'Marcus Oyelaran' => 'marcus.oyelaran@opentext.com'};

Map<String, List<String>> buyersBySession = new Map<String, List<String>>{
    's3' => new List<String>{'Katherine Villanueva','Rohan Deshpande','Meredith Cho',
                             'Tom Brzezinski','Alison Reyes','Jared Kim'},
    's4' => new List<String>{'Katherine Villanueva','Rohan Deshpande','Meredith Cho',
                             'Tom Brzezinski','Alison Reyes'},
    's5' => new List<String>{'Katherine Villanueva','Rohan Deshpande','Meredith Cho',
                             'Tom Brzezinski','Alison Reyes'}};
Map<String, String> resourceBySession = new Map<String, String>{
    's3' => 'AAO_WF_S3_Raw', 's4' => 'AAO_WF_S4_Raw', 's5' => 'AAO_WF_S5_Raw'};
Map<String, Datetime> occurred = new Map<String, Datetime>{
    's3' => Datetime.newInstanceGmt(2026, 8, 5, 18, 0, 0),
    's4' => Datetime.newInstanceGmt(2026, 8, 19, 14, 0, 0),
    's5' => Datetime.newInstanceGmt(2026, 9, 25, 19, 0, 0)};

Map<String, Blob> bodies = new Map<String, Blob>();
for (StaticResource sr : [SELECT Name, Body FROM StaticResource WHERE Name LIKE 'AAO_WF_S%_Raw']) {
    bodies.put(sr.Name, sr.Body);
}

Set<String> already = new Set<String>();
for (AAO_Source__c e : [SELECT AAO_Source_Ref__c FROM AAO_Source__c
        WHERE AAO_Opportunity__c = :opp]) { already.add(e.AAO_Source_Ref__c); }
for (String s : new List<String>{'s3','s4','s5'}) {
    String resName = resourceBySession.get(s);
    if (!bodies.containsKey(resName)) {
        System.debug(LoggingLevel.ERROR, s + ': RESOURCE MISSING ' + resName + ' - skipped');
        continue;
    }
    String ref = 'wf/opentext-' + occurred.get(s).formatGmt('yyyy-MM-dd') + '-nf1';
    if (already.contains(ref)) {
        System.debug(LoggingLevel.ERROR, s + ': already ingested as ' + ref + ' - skipped');
        continue;
    }
    String raw = bodies.get(resName).toString();
    AAO_IntakeVTT.Result r = AAO_IntakeVTT.parse(raw);

    List<Map<String, Object>> speakers = new List<Map<String, Object>>();
    for (String who : buyersBySession.get(s)) {
        speakers.add(new Map<String, Object>{
            'contactId' => cid.get(who), 'email' => mail.get(who),
            'display' => who, 'key' => who});
    }
    for (String who : sellers.keySet()) {
        speakers.add(new Map<String, Object>{
            'email' => sellers.get(who), 'display' => who, 'key' => who});
    }
    if (s == 's5') {
        // PRIYA IS DISPLAY-ONLY AND STAYS THAT WAY. No contactId, no email: she attended and the
        // org has no record of her, which is the Dan Lewis precedent exactly. Giving her an id
        // would hand-feed the reconciliation and destroy the arc's central specimen.
        speakers.add(new Map<String, Object>{
            'display' => 'Priya Natarajan', 'key' => 'Priya Natarajan'});
    }

    AAO_Source__c src = new AAO_Source__c(
        AAO_Opportunity__c = opp, AAO_Account__c = acct, AAO_Origin__c = 'ingest',
        AAO_Source_Ref__c = 'wf/opentext-' + occurred.get(s).formatGmt('yyyy-MM-dd') + '-nf1',
        AAO_Artifact_SHA256__c = EncodingUtil.convertToHex(
            Crypto.generateDigest('SHA-256', Blob.valueOf(r.normalizedText))),
        AAO_Part_Index__c = 1, AAO_Part_Count__c = 1,
        AAO_Normalized_Text__c = r.normalizedText,
        AAO_Diarization__c = r.diarization,
        AAO_Evidence_Occurred__c = occurred.get(s),
        AAO_Speaker_Roster__c = JSON.serialize(
            new Map<String, Object>{'speakers' => speakers, 'v' => 1}));
    insert src;
    System.debug(LoggingLevel.ERROR, s + ': source ' + src.Id + ' turns=' + r.turnCount +
        ' speakers=' + speakers.size() + ' sha=' + src.AAO_Artifact_SHA256__c.substring(0,12));
}
