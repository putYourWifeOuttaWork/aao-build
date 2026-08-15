// THE PURGE PROTOCOL DOES NOT COVER CARDS, SHADOWS OR FLAGS. Recorded as a finding; handled
// here deliberately rather than silently.
//
// CARDS ARE DELETED, card-first so the 70 child relationships cascade rather than being deleted
// by hand - the fifty-second stamp's incident and the seventy-third stamp's precedent.
// A standing card would be reported "unchanged" by the re-run and the card-face fix would never
// be exercised, which is the one thing this re-run must verify on the surface Matthew graded.
//
// SHADOWS AND FLAGS ARE DELIBERATELY LEFT STANDING, and that is BETTER than clearing them:
// they are the exact rows that failed to promote and failed to clear on the first stack, so the
// re-run tests promotion against the real specimens. A non-synthetic flag is undeletable by law
// in any case - AAO_Synthetic.deletable is PURGING && synthetic - and these are not synthetic.
Id OPP = '006WD00000TWvH0YAL';
List<ALTF__Insight_Card__c> cards = [SELECT Id FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = :OPP];
System.debug('REACH: cards=' + cards.size()
  + ' sections=' + [SELECT COUNT() FROM ALTF__Insight_Card_Section__c WHERE ALTF__Insight_Card__c IN :cards]
  + ' contactLinks=' + [SELECT COUNT() FROM ALTF__Insight_Card_Contact__c WHERE ALTF__Insight_Card__c IN :cards]);
delete cards;
System.debug('AFTER cards=' + [SELECT COUNT() FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c=:OPP]
  + ' shadows=' + [SELECT COUNT() FROM AAO_Shadow_Person__c]
  + ' flags standing=' + AAO_Identification.standing(OPP)
  + ' sources=' + [SELECT COUNT() FROM AAO_Source__c WHERE AAO_Opportunity__c=:OPP]);
