// THE LAWFUL CORRECTION of the inflated reinforcement counts on Emerson, eightieth stamp item 4.
//
// RETIRE AND RE-DERIVE, NEVER DELETE, NEVER EDIT IN PLACE. A claim is insert-only apart from
// retirement, so the mis-labelled row cannot be edited to say Corroborated. And the ruling says
// in terms that "both claims stand as evidence with their own spans", so retiring alone would
// destroy exactly what it protects. The lawful path is therefore both halves, in this order:
// WRITE THE REPLACEMENT FIRST, carrying the same evidence under the corrected outcome, THEN
// retire the original with its reason. The trigger's own words allow it: "the evidence still
// exists and can be read again into a new claim that says so on its own row."
Id opp = '006WD00000TJmJZYA1';

// ---- 1 · recompute, in replay order, so the correction is derived rather than typed
Map<Id, List<AAO_Claim__c>> byAnswer = new Map<Id, List<AAO_Claim__c>>();
List<String> fields = new List<String>();
for (String f : AAO_Claim__c.SObjectType.getDescribe().fields.getMap().keySet()) {
    fields.add(f);
}
String q = 'SELECT ' + String.join(fields, ',') +
    ' FROM AAO_Claim__c WHERE AAO_Opportunity__c = :opp AND AAO_Answer__c != null' +
    ' AND AAO_Retired__c = false ORDER BY AAO_Evidence_Occurred__c ASC, CreatedDate ASC, Id ASC';
for (AAO_Claim__c c : (List<AAO_Claim__c>) Database.query(q)) {
    if (!byAnswer.containsKey(c.AAO_Answer__c)) {
        byAnswer.put(c.AAO_Answer__c, new List<AAO_Claim__c>());
    }
    byAnswer.get(c.AAO_Answer__c).add(c);
}
List<AAO_Claim__c> wrong = new List<AAO_Claim__c>();
for (Id a : byAnswer.keySet()) {
    String standing = null;
    for (AAO_Claim__c c : byAnswer.get(a)) {
        if (standing != null && c.AAO_Outcome__c == 'Reinforced' &&
            AAO_Accumulate.intersectsStanding(standing, c.AAO_Spans__c)) {
            wrong.add(c);
        }
        standing = AAO_Model.serializeSpans(AAO_Accumulate.mergeSpans(standing, c.AAO_Spans__c));
    }
}
System.debug(LoggingLevel.ERROR, 'to correct: ' + wrong.size());
if (wrong.isEmpty()) { return; }

// ---- 2 · the replacements, same evidence, corrected outcome
Map<String, Schema.SObjectField> fmap = AAO_Claim__c.SObjectType.getDescribe().fields.getMap();
List<AAO_Claim__c> replacements = new List<AAO_Claim__c>();
Map<Integer, Id> originalByIndex = new Map<Integer, Id>();
for (AAO_Claim__c c : wrong) {
    AAO_Claim__c fresh = new AAO_Claim__c();
    for (String f : fmap.keySet()) {
        Schema.DescribeFieldResult d = fmap.get(f).getDescribe();
        if (!d.isCreateable() || d.isAutoNumber()) { continue; }
        Object v = c.get(f);
        if (v != null) { fresh.put(f, v); }
    }
    fresh.AAO_Outcome__c = AAO_Accumulate.CORROBORATED;
    fresh.AAO_Retired__c = false;
    fresh.AAO_Retired_Because__c = null;
    fresh.AAO_Retired_At__c = null;
    fresh.AAO_Recorded_At__c = System.now();
    originalByIndex.put(replacements.size(), c.Id);
    replacements.add(fresh);
}
AAO_Synthetic.MARK = false;
insert replacements;
for (Integer i = 0; i < replacements.size(); i++) {
    System.debug(LoggingLevel.ERROR, 'REPLACED ' + originalByIndex.get(i) + ' -> ' +
        replacements[i].Id + ' outcome=Corroborated');
}

// ---- 3 · retire the originals, with the reason a later reader needs
Set<Id> ids = new Set<Id>();
for (AAO_Claim__c c : wrong) { ids.add(c.Id); }
AAO_Retire.Outcome o = AAO_Retire.byIds(
    ids,
    'Retired 13 August 2026 under the eightieth stamp: this claim was written Reinforced, ' +
    'and its spans intersect evidence already standing on the same answer within the same ' +
    'Source. Two comprehensive reads found one utterance twice; that is corroboration, not ' +
    'the buyer pressing the point again, and reinforcement is a count guidance orders by. ' +
    'The evidence is not withdrawn: a replacement claim carrying the same spans stands ' +
    'beside this row under outcome Corroborated.'
);
System.debug(LoggingLevel.ERROR, o.toString());
