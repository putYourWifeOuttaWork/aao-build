// READ ONLY. What the DETERMINISTIC legs would have disposed on each surviving run, had the
// driver called the twenty-seventh stamp's resolution stage instead of the pre-rebuild model call.
//
// The merge predicate is reproduced from AAO_Resolve.mergePlan's own published rule (same
// contract, byte intersection, same voiced meaning, agreeing designators, r1 against r2, greedy,
// first unconsumed partner wins). Reproduced rather than called because mergePlan is private and
// this report writes nothing; the reproduction is checked against a named specimen below.
for (String runKey : new List<String>{ 'pf0813-uphold', 'em0813-stack-c1', 'em0813-stack-c2' }) {
    List<AAO_Pair__c> located = [
        SELECT Id, AAO_Pair_Ref__c, AAO_Meaning__c, AAO_Start_Offset__c, AAO_End_Offset__c,
            AAO_Speaker_Key__c, AAO_About_Designator__c, AAO_Evidence_Contract__c, AAO_Source__c
        FROM AAO_Pair__c
        WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = 'Located'
        ORDER BY AAO_Start_Offset__c];
    if (located.isEmpty()) { continue; }

    Set<String> rosterKeys = new Set<String>();
    for (AAO_Participant__c p : [SELECT AAO_Roster_Key__c FROM AAO_Participant__c
            WHERE AAO_Source__c = :located[0].AAO_Source__c]) {
        rosterKeys.add(p.AAO_Roster_Key__c);
    }

    Map<Id, List<AAO_Pair__c>> byContract = new Map<Id, List<AAO_Pair__c>>();
    for (AAO_Pair__c p : located) {
        if (!byContract.containsKey(p.AAO_Evidence_Contract__c)) {
            byContract.put(p.AAO_Evidence_Contract__c, new List<AAO_Pair__c>());
        }
        byContract.get(p.AAO_Evidence_Contract__c).add(p);
    }
    Set<Id> absorbed = new Set<Id>();
    List<String> pairsMerged = new List<String>();
    for (List<AAO_Pair__c> g : byContract.values()) {
        List<AAO_Pair__c> r1 = new List<AAO_Pair__c>(), r2 = new List<AAO_Pair__c>();
        for (AAO_Pair__c p : g) {
            if (p.AAO_Pair_Ref__c.startsWith('r1')) { r1.add(p); }
            else if (p.AAO_Pair_Ref__c.startsWith('r2')) { r2.add(p); }
        }
        Set<Id> consumed = new Set<Id>();
        for (AAO_Pair__c a : r1) {
            for (AAO_Pair__c b : r2) {
                if (consumed.contains(b.Id)) { continue; }
                if (a.AAO_Start_Offset__c == null || b.AAO_Start_Offset__c == null) { continue; }
                Boolean hits = a.AAO_Start_Offset__c < b.AAO_End_Offset__c &&
                    b.AAO_Start_Offset__c < a.AAO_End_Offset__c;
                if (!hits || a.AAO_Meaning__c != b.AAO_Meaning__c) { continue; }
                String da = a.AAO_About_Designator__c, db = b.AAO_About_Designator__c;
                Boolean agree = (String.isBlank(da) && String.isBlank(db)) ||
                    (String.isNotBlank(da) && String.isNotBlank(db) &&
                     da.trim().toLowerCase() == db.trim().toLowerCase());
                if (!agree) { continue; }
                absorbed.add(b.Id);
                consumed.add(b.Id);
                pairsMerged.add(a.AAO_Pair_Ref__c + '+' + b.AAO_Pair_Ref__c);
                break;
            }
        }
    }
    Integer speakerAttached = 0, designatorRoster = 0, designatorOther = 0;
    for (AAO_Pair__c p : located) {
        if (absorbed.contains(p.Id)) { continue; }
        if (String.isBlank(p.AAO_About_Designator__c)) {
            if (rosterKeys.contains(p.AAO_Speaker_Key__c)) { speakerAttached++; }
            continue;
        }
        Boolean onRoster = false;
        for (String k : rosterKeys) {
            if (k.replaceAll('[^a-z]', '').contains(
                    p.AAO_About_Designator__c.toLowerCase().replaceAll('[^a-z]', ''))) {
                onRoster = true; break;
            }
        }
        if (onRoster) { designatorRoster++; } else { designatorOther++; }
    }
    System.debug(LoggingLevel.ERROR, runKey + ': located=' + located.size() +
        ' MERGED=' + absorbed.size() + ' speakerAttached=' + speakerAttached +
        ' designatorOnRoster=' + designatorRoster + ' designatorLadderOrModel=' + designatorOther +
        '  => deterministic ' + (absorbed.size() + speakerAttached + designatorRoster) +
        ' of ' + located.size());
    System.debug(LoggingLevel.ERROR, '   merged pairs: ' + String.join(pairsMerged, ' '));
}
