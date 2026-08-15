// DOES ANY REAL SPAN START ON A TURN BOUNDARY? Positions moving is not attributions moving.
Map<Id, AAO_Source__c> srcs = new Map<Id, AAO_Source__c>([
    SELECT Id, AAO_Normalized_Text__c, AAO_Diarization__c FROM AAO_Source__c
    WHERE AAO_Diarization__c != null]);
Integer checked = 0, onBoundary = 0;
for (AAO_Pair__c p : [SELECT AAO_Source__c, AAO_Start_Offset__c FROM AAO_Pair__c
        WHERE AAO_Stage__c = 'Located' AND AAO_Start_Offset__c != null LIMIT 400]) {
    AAO_Source__c s = srcs.get(p.AAO_Source__c);
    if (s == null) { continue; }
    List<AAO_NormalForm.Turn> turns =
        AAO_NormalForm.turns(s.AAO_Normalized_Text__c, s.AAO_Diarization__c);
    Integer off = Integer.valueOf(p.AAO_Start_Offset__c);
    checked++;
    for (AAO_NormalForm.Turn t : turns) {
        if (off == t.utteranceEnd) { onBoundary++; break; }
    }
}
System.debug(LoggingLevel.ERROR, 'located spans checked: ' + checked +
    '   starting exactly on a turn end: ' + onBoundary);
