// THE LAWFUL CORRECTION of the duplicate person, eightieth stamp item 5.
// Marked and disowned, claims retired with their reason, and the created row NEVER deleted by
// us: it stays enumerable through the create-leg record, which is what makes a sandbox purge
// able to reach it at all.
String because =
    'Disowned 13 August 2026 under the eightieth stamp. This Contact is a DUPLICATE of the ' +
    'seeded 003WD00001PsSLIYA3, Fatema Choudray, VP Premier Sales Performance, on the same ' +
    'account: the transcript said "Fatima" and the ladder minted a person from a transcriber\'s ' +
    'spelling. Two mechanisms failed and both are now closed - the create ladder gained a ' +
    'given-name rung, and a single-token designator can link but can never create. Not deleted ' +
    'by us as product law; enumerable from this row for a sandbox purge.';
update new AAO_Created_Row__c(
    Id = 'a1dWD000009HHwvYAG', AAO_Disowned__c = true, AAO_Disowned_Because__c = because
);
System.debug(LoggingLevel.ERROR, 'create-leg row MK-00000022 marked disowned.');

AAO_Retire.Outcome o = AAO_Retire.byIds(
    new Set<Id>{ 'a1VWD000008jAgC2AU', 'a1VWD000008jEiI2AU' },
    'Retired 13 August 2026 under the eightieth stamp. The WORDS are sound - Ryan Couture said ' +
    '"I believe Fatima will be the one signing it, yes" and call 3 upheld it - and the SUBJECT ' +
    'is wrong: the establishment was attached to a Contact minted from the transcriber\'s ' +
    'spelling rather than to the human it names, and it wrote Signature Approver, rank 5, onto ' +
    'a customer-named relationship map. This establishment should not have moved anything. The ' +
    'evidence stands on its pairs and re-attaches only if the rebuilt ladder links the real ' +
    'person, which on these bytes it does not.'
);
System.debug(LoggingLevel.ERROR, o.toString());
