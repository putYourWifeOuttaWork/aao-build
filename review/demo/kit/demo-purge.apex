// AAO DEMO — purge the harness deal back to an empty board (between and after runs).
// Lawful under the 28th stamp's purge-and-rerun protocol: the sandbox harness deleting its own
// enumerable output, NOT the never-delete product law.
// Run it in Dev Console > Debug > Open Execute Anonymous Window, or:
//     sf apex run -f demo-purge.apex -o aossb2
//
// Clears: cards (card-first so junctions cascade), then map rows / claims / answers / candidates
// / pairs / receipts / machine-created Contacts (via AAO_Purge, by run key).
// KEEPS by design: the Source rows — their scope keys survive — so ALWAYS demo with FRESH bytes;
// the idempotence guard correctly refuses a re-paste of identical text.
// If you hand-edited a map value, AAO_Purge aborts on the human-watermark guard. That is correct:
// re-run on an untouched board.

Id OPP = '006WD00000Tn91RYAR';   // AAO DEMO HARNESS DEAL — never a live opportunity

Set<String> keys = new Set<String>();
for (AAO_Run_Receipt__c r : [SELECT AAO_Run_Key__c FROM AAO_Run_Receipt__c WHERE AAO_Opportunity__c = :OPP])
    if (r.AAO_Run_Key__c != null) keys.add(r.AAO_Run_Key__c);
for (AAO_Pair__c p : [SELECT AAO_Run_Key__c FROM AAO_Pair__c WHERE AAO_Source__r.AAO_Opportunity__c = :OPP])
    if (p.AAO_Run_Key__c != null) keys.add(p.AAO_Run_Key__c);

System.debug('BEFORE cards=' + [SELECT COUNT() FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = :OPP]
    + ' claims=' + [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c = :OPP]
    + ' answers=' + [SELECT COUNT() FROM AAO_Answer__c WHERE AAO_Opportunity__c = :OPP]
    + ' maprows=' + [SELECT COUNT() FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c = :OPP]
    + ' runKeys=' + keys);

delete [SELECT Id FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = :OPP];   // card-first

if (!keys.isEmpty()) System.debug('PURGE\n' + AAO_Purge.run(keys, OPP));

System.debug('AFTER  cards=' + [SELECT COUNT() FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = :OPP]
    + ' claims=' + [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c = :OPP]
    + ' answers=' + [SELECT COUNT() FROM AAO_Answer__c WHERE AAO_Opportunity__c = :OPP]
    + ' maprows=' + [SELECT COUNT() FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c = :OPP]
    + ' shadows(org)=' + [SELECT COUNT() FROM AAO_Shadow_Person__c]
    + ' flags=' + [SELECT COUNT() FROM AAO_Flag__c WHERE AAO_Opportunity__c = :OPP]);
