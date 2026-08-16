// READ ONLY. Which claims on Emerson would the eightieth stamp's rule have called Corroborated?
// Replay order: evidence-occurred, then created, which is the order the join wrote them in.
Id opp = '006WD00000TJmJZYA1';
Map<Id, List<AAO_Claim__c>> byAnswer = new Map<Id, List<AAO_Claim__c>>();
Map<Id, String> label = new Map<Id, String>();
for (AAO_Claim__c c : [SELECT Id, Name, AAO_Answer__c, AAO_Spans__c, AAO_Outcome__c,
        AAO_Retired__c, AAO_Source__c, AAO_Evidence_Occurred__c,
        AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
        AAO_Participant__r.AAO_Display_Name__c
    FROM AAO_Claim__c WHERE AAO_Opportunity__c = :opp AND AAO_Answer__c != null
        AND AAO_Retired__c = false
    ORDER BY AAO_Evidence_Occurred__c ASC, CreatedDate ASC, Id ASC]) {
    if (!byAnswer.containsKey(c.AAO_Answer__c)) {
        byAnswer.put(c.AAO_Answer__c, new List<AAO_Claim__c>());
        label.put(c.AAO_Answer__c, c.AAO_Participant__r.AAO_Display_Name__c + ' / ' +
            c.AAO_Evidence_Contract__r.AAO_Proposition_Code__c);
    }
    byAnswer.get(c.AAO_Answer__c).add(c);
}
Integer inflated = 0, reinforcedTotal = 0, establishedTotal = 0;
List<String> ids = new List<String>();
for (Id a : byAnswer.keySet()) {
    String standing = null;
    for (AAO_Claim__c c : byAnswer.get(a)) {
        if (c.AAO_Outcome__c == 'Reinforced') { reinforcedTotal++; }
        if (c.AAO_Outcome__c == 'Established') { establishedTotal++; }
        Boolean hits = standing != null && AAO_Accumulate.intersectsStanding(standing, c.AAO_Spans__c);
        if (hits && c.AAO_Outcome__c == 'Reinforced') {
            inflated++;
            ids.add(c.Id);
            System.debug(LoggingLevel.ERROR, 'INFLATED ' + c.Name + ' ' + c.Id + ' :: ' +
                label.get(a) + ' :: ' + c.AAO_Spans__c.abbreviate(160));
        } else if (hits) {
            System.debug(LoggingLevel.ERROR, 'overlaps but outcome=' + c.AAO_Outcome__c +
                ' :: ' + label.get(a));
        }
        standing = AAO_Model.serializeSpans(AAO_Accumulate.mergeSpans(standing, c.AAO_Spans__c));
    }
}
System.debug(LoggingLevel.ERROR, 'answers=' + byAnswer.size() + ' established=' + establishedTotal +
    ' reinforced=' + reinforcedTotal + ' INFLATED=' + inflated);
System.debug(LoggingLevel.ERROR, 'ids=' + String.join(ids, ','));
