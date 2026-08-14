/**
 * THE PURGE-AND-RERUN PROTOCOL, twenty-eighth stamp item 3. Test cycles purge and re-run on
 * the same frozen fixtures freely; no new transcript needed per cycle.
 *
 * THE COMMAND'S SHAPE, proposed before first use as the stamp requires:
 * `AAO_Purge.run(runKeys, opportunityId)` deletes ONLY what is enumerable as ours -
 * run-keyed pairs, the fixture opportunity's claims, candidates, answers, its projected map
 * rows, and machine-created Contacts via the create-leg record - and reports what it
 * deleted by count and key. Everything else is refused by construction:
 *
 * - **THE HUMAN-WATERMARK GUARD RUNS FIRST AND ABORTS THE WHOLE PURGE.** Every non-null
 *   dimension value on the opportunity's map rows must be claimed by one of OUR watermarks
 *   (an answer's projected value or a participant's projected coverage). One unclaimed
 *   value means a human may have touched the map, and anything carrying a human watermark
 *   is never deleted - so the purge throws rather than proceeding around it.
 * - **Seeds stay**: Accounts, Opportunities, seeded Contacts, Sources, participants and
 *   contracts are never in scope. The Source and its participants survive so a rerun
 *   reuses them; only the participants' projected-coverage watermarks are cleared.
 * - **Machine-created Contacts leave ONLY through the create-leg record.** Dan Lewis is
 *   deletable in a sandbox purge PRECISELY because the record enumerates him; a purge
 *   without the record would be guessing, which is why the record shipped first. The
 *   record row itself STAYS - the enumeration outlives the row it enumerates.
 * - **Retired criteria stay.** The retirement of the collapsed CR rows is the lawful
 *   correction's own evidence, and deleting it would erase the history the correction
 *   exists to keep. Reported, not deleted.
 *
 * THE NEVER-DELETE LAW IS NOT TOUCHED: it remains the product-runtime law for customer
 * evidence. The sandbox harness deleting its own enumerable test output is not that law's
 * subject (Matthew, twenty-eighth stamp, verbatim), and the trigger doors below open only
 * while `ACTIVE` is true inside this class's own transaction, only for the enumerated keys.
 */
public with sharing class AAO_Purge {
    public class PurgeException extends Exception {
    }

    /** Open only inside run(), only for the enumerated keys. Read by the trigger doors. */
    public static Boolean ACTIVE = false;
    public static Set<String> RUN_KEYS = new Set<String>();
    public static Set<Id> OPPORTUNITIES = new Set<Id>();

    /** The pair door: run-keyed. */
    public static Boolean allowsPair(AAO_Pair__c p) {
        return ACTIVE && RUN_KEYS.contains(p.AAO_Run_Key__c);
    }

    /** The claim door: fixture-opportunity-keyed. */
    public static Boolean allowsClaim(AAO_Claim__c c) {
        return ACTIVE && OPPORTUNITIES.contains(c.AAO_Opportunity__c);
    }

    public class Outcome {
        public Integer mapRows = 0;
        public Integer contacts = 0;
        public Integer claims = 0;
        public Integer candidates = 0;
        public Integer answers = 0;
        public Integer pairs = 0;
        /** Run receipts. Telemetry for the purged runs, and enumerable by the same keys. */
        public Integer receipts = 0;
        public Integer participantsCleared = 0;
        public List<String> kept = new List<String>();
        public List<String> keys = new List<String>();

        public override String toString() {
            List<String> o = new List<String>{
                'map rows deleted         ' + mapRows,
                'contacts deleted         ' + contacts + ' (via the create-leg record)',
                'claims deleted           ' + claims,
                'candidates deleted       ' + candidates,
                'answers deleted          ' + answers,
                'pairs deleted            ' + pairs,
                'receipts deleted         ' + receipts,
                'participants cleared     ' + participantsCleared + ' (coverage watermarks)',
                'keys: ' + String.join(keys, ', ')
            };
            for (String k : kept) {
                o.add('  kept: ' + k);
            }
            return String.join(o, '\n');
        }
    }

    public static Outcome run(Set<String> runKeys, Id opportunityId) {
        if (runKeys == null || runKeys.isEmpty() || opportunityId == null) {
            throw new PurgeException('A purge enumerates its keys or it does not run.');
        }
        Outcome o = new Outcome();
        o.keys.addAll(runKeys);
        o.keys.add(String.valueOf(opportunityId));

        // ---- the human-watermark guard, first and fatal ------------------------------
        Set<String> claimed = new Set<String>();
        for (AAO_Answer__c a : [
            SELECT AAO_Projected_Value__c, AAO_Subject_Contact__c,
                AAO_Participant__r.AAO_Contact__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :opportunityId
                AND AAO_Projected_Value__c != null
        ]) {
            Id c = a.AAO_Subject_Contact__c != null
                ? a.AAO_Subject_Contact__c
                : a.AAO_Participant__r?.AAO_Contact__c;
            if (c != null) {
                claimed.add(c + '|' + a.AAO_Projected_Value__c);
            }
        }
        for (AAO_Participant__c p : [
            SELECT AAO_Contact__c, AAO_Coverage_Projected_Value__c
            FROM AAO_Participant__c
            WHERE AAO_Opportunity__c = :opportunityId
                AND AAO_Coverage_Projected_Value__c != null
        ]) {
            if (p.AAO_Contact__c != null) {
                claimed.add(p.AAO_Contact__c + '|' + p.AAO_Coverage_Projected_Value__c);
            }
        }
        List<ALTF__Contact_Map_Details__c> mapRows = [
            SELECT Id, ALTF__Contact__c, ALTF__Status__c, ALTF__Political__c,
                ALTF__Buyer_Role__c, ALTF__Coverage__c
            FROM ALTF__Contact_Map_Details__c
            WHERE ALTF__Opportunity__c = :opportunityId
        ];
        for (ALTF__Contact_Map_Details__c m : mapRows) {
            for (String v : new List<String>{
                m.ALTF__Status__c, m.ALTF__Political__c, m.ALTF__Buyer_Role__c,
                m.ALTF__Coverage__c
            }) {
                if (v != null && !claimed.contains(m.ALTF__Contact__c + '|' + v)) {
                    throw new PurgeException(
                        'ABORTED WHOLE: map row ' + m.Id + ' carries the value "' + v +
                        '" that no watermark of ours claims. A human may have touched ' +
                        'this map, and anything carrying a human watermark is never ' +
                        'deleted. Nothing was purged.'
                    );
                }
            }
        }

        // ---- the enumerated deletions, children before parents -----------------------
        delete mapRows;
        o.mapRows = mapRows.size();

        Id fixtureAccount = [
            SELECT AccountId FROM Opportunity WHERE Id = :opportunityId
        ].AccountId;
        Set<Id> enumerated = new Set<Id>();
        for (AAO_Created_Row__c r : [
            SELECT AAO_Target_Id__c
            FROM AAO_Created_Row__c
            WHERE AAO_Target_Object__c = 'Contact' AND AAO_Disowned__c = false
        ]) {
            enumerated.add(Id.valueOf(r.AAO_Target_Id__c));
        }
        List<Contact> machineContacts = enumerated.isEmpty()
            ? new List<Contact>()
            : [
                  SELECT Id FROM Contact
                  WHERE Id IN :enumerated AND AccountId = :fixtureAccount
              ];
        delete machineContacts;
        o.contacts = machineContacts.size();

        ACTIVE = true;
        RUN_KEYS = runKeys;
        OPPORTUNITIES = new Set<Id>{ opportunityId };
        try {
            List<AAO_Claim__c> claims = [
                SELECT Id FROM AAO_Claim__c WHERE AAO_Opportunity__c = :opportunityId
            ];
            delete claims;
            o.claims = claims.size();

            List<AAO_Candidate__c> cands = [
                SELECT Id FROM AAO_Candidate__c WHERE AAO_Opportunity__c = :opportunityId
            ];
            delete cands;
            o.candidates = cands.size();

            List<AAO_Answer__c> answers = [
                SELECT Id FROM AAO_Answer__c WHERE AAO_Opportunity__c = :opportunityId
            ];
            delete answers;
            o.answers = answers.size();

            List<AAO_Pair__c> pairs = [
                SELECT Id FROM AAO_Pair__c WHERE AAO_Run_Key__c IN :runKeys
            ];
            delete pairs;
            o.pairs = pairs.size();

            // THE RECEIPT IS RUN-KEYED, SO IT IS ENUMERABLE AS OURS AND GOES WITH THE RUN.
            // Leaving it would leave telemetry claiming a pass whose every row is gone, which
            // is the opposite of the did-we-read-it record's job.
            List<AAO_Run_Receipt__c> receipts = [
                SELECT Id FROM AAO_Run_Receipt__c WHERE AAO_Run_Key__c IN :runKeys
            ];
            delete receipts;
            o.receipts = receipts.size();
        } finally {
            ACTIVE = false;
            RUN_KEYS = new Set<String>();
            OPPORTUNITIES = new Set<Id>();
        }

        List<AAO_Participant__c> toClear = new List<AAO_Participant__c>();
        for (AAO_Participant__c p : [
            SELECT Id FROM AAO_Participant__c
            WHERE AAO_Opportunity__c = :opportunityId
                AND AAO_Coverage_Projected_Value__c != null
        ]) {
            toClear.add(new AAO_Participant__c(
                Id = p.Id,
                AAO_Coverage_Projected_Value__c = null,
                AAO_Coverage_Projected_Modstamp__c = null
            ));
        }
        update toClear;
        o.participantsCleared = toClear.size();

        for (AAO_Criterion__c c : [
            SELECT Name, AAO_Retired__c FROM AAO_Criterion__c
            WHERE AAO_Opportunity__c = :opportunityId
        ]) {
            o.kept.add('criterion ' + c.Name +
                (c.AAO_Retired__c ? ' (retired; the correction is the record)' : ''));
        }
        o.kept.add('the Source, its participants, every seed row, the create-leg record');
        return o;
    }
}