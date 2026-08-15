// PARSE CHECK ONLY. No pass run, no grading, no scoring. A throwaway account and opportunity,
// deliberately NOT the Wells Fargo seed: the WF deal is the measurement instrument and nothing
// touches it before the read.
Account a;
List<Account> found = [SELECT Id FROM Account WHERE Name = 'AAO Scratch (parse check)' LIMIT 1];
if (found.isEmpty()) { a = new Account(Name = 'AAO Scratch (parse check)'); insert a; }
else { a = found[0]; }
Opportunity o;
List<Opportunity> fo = [SELECT Id FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
if (fo.isEmpty()) {
    o = new Opportunity(Name = 'AAO Scratch Deal', AccountId = a.Id, StageName = 'Stage 1',
        CloseDate = Date.today().addDays(60));
    insert o;
} else { o = fo[0]; }
System.debug(LoggingLevel.ERROR, 'scratch account ' + a.Id + '  opportunity ' + o.Id);

for (StaticResource sr : [SELECT Name, Body FROM StaticResource
        WHERE Name IN ('AAO_WF_S4_Raw','AAO_WF_S5_Raw') ORDER BY Name]) {
    String raw = sr.Body.toString();
    AAO_IntakeVTT.Result r = AAO_IntakeVTT.parse(raw);
    Map<String, AAO_IntakeVTT.RosterEntry> roster = AAO_IntakeVTT.roster(raw);
    System.debug(LoggingLevel.ERROR, sr.Name + ': cues=' + r.cueCount + ' turns=' + r.turnCount +
        ' speakers=' + r.speakerKeys.size() + ' diarization=' + r.diarization +
        ' nf1Bytes=' + r.normalizedText.length() + ' rosterEntries=' + roster.size());
    System.debug(LoggingLevel.ERROR, '   speakerKeys: ' + r.speakerKeys);
    // OFFSETS MEAN NOTHING UNLESS THEY RESOLVE. Take the first and last turn's text straight
    // out of the normalized body and prove the arithmetic on the artifact itself.
    List<AAO_NormalForm.Turn> turns = AAO_NormalForm.turns(r.normalizedText, r.diarization);
    AAO_NormalForm.Turn f0 = turns[0], fN = turns[turns.size()-1];
    Integer len = r.normalizedText.length();
    String a0 = r.normalizedText.substring(f0.utteranceStart, Math.min(f0.utteranceEnd + 1, len));
    String aN = r.normalizedText.substring(fN.utteranceStart, Math.min(fN.utteranceEnd + 1, len));
    System.debug(LoggingLevel.ERROR, '   tail bounds: len=' + len + ' lastEnd=' + fN.utteranceEnd +
        (fN.utteranceEnd >= len ? '  <- end is NOT inclusive here' : '  <- inclusive, in bounds'));
    System.debug(LoggingLevel.ERROR, '   turns=' + turns.size() +
        ' firstSpeaker=' + f0.speakerKey + ' first40="' + a0.abbreviate(40) + '"');
    System.debug(LoggingLevel.ERROR, '   lastSpeaker=' + fN.speakerKey +
        ' last40="' + aN.abbreviate(40) + '"');
    System.debug(LoggingLevel.ERROR, '   markup left in body: ' +
        (r.normalizedText.contains('<v ') || r.normalizedText.contains('-->') ? 'YES - DEFECT' : 'none'));
}
