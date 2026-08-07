/**
 * COVERAGE. Computed, never extracted; presence establishes it; no model call anywhere.
 *
 * Ratified 6 August exactly as proposed. Three things in it are deliberate refusals, and each
 * one is the safe direction for a dimension that feeds a flag.
 *
 * **DISTINCT ARTIFACT HASHES, NEVER ROWS.** A ninety-minute call arrives as two or three
 * Source rows because the ingest gate splits on duration, so counting participation rows would
 * count one conversation twice. This is the same source-event definition the sentiment counter
 * uses, for the same reason.
 *
 * **`In-depth` IS DELIBERATELY UNDERIVABLE.** Coverage's third guided question asks about
 * MEANINGFUL and HIGH QUALITY contact, and those are not counts. The material to separate a
 * real conversation from a calendar collision exists on Source - `AAO_Substantive_Offset__c`
 * from the small-talk boundary, and `AAO_Duration_Seconds__c` - but the threshold is a
 * measurement and no document carries one. Writing `In-depth` off a count would be inference
 * wearing arithmetic's clothes, upstream of every rule built to prevent exactly that. So the
 * ladder tops out one rung below its own ceiling until the threshold is measured, and coverage
 * UNDERSTATES rather than overstates.
 *
 * **ZERO OCCASIONS WRITES NOTHING.** `No Contact` is a claim, and we have no evidence for it: a
 * person may have been met on a call nobody recorded. The silence law is the ruling's own
 * ground - the system journals what happened, never what did not - and an assertion from
 * absence is the thing nobody may make. The gap surfaces as guidance instead.
 */
public with sharing class AAO_Coverage {
    /**
     * The vendor's own values, READ FROM THE ORG on 6 August rather than assumed:
     * `ALTF__Contact_Map_Details__c.ALTF__Coverage__c` is a picklist of exactly five -
     * In-depth, Multiple contacts, Brief contact, No Contact, Unknown.
     */
    public static final String BRIEF = 'Brief contact';
    public static final String MULTIPLE = 'Multiple contacts';

    /**
     * Occasions to a vendor value, or null for leave-alone.
     *
     * Null covers two cases and both are correct: zero occasions, which is the silence law,
     * and a negative that cannot happen but would be a defect rather than a value.
     */
    public static String valueFor(Integer occasions) {
        if (occasions == null || occasions < 1) {
            return null;
        }
        return occasions == 1 ? BRIEF : MULTIPLE;
    }

    /**
     * Distinct artifact hashes per person on this deal.
     *
     * Keyed by participant id, because that is the identity the pass and the map both resolve
     * through. A participant row with no hash still counts as one occasion: the row exists
     * because a Source arrived, and losing that would make coverage understate for a reason
     * that has nothing to do with the person.
     */

    /**
     * ONE CONVERSATION, ONE KEY. Source-system reference plus occurred time, deterministic and
     * never derived from our own bytes.
     *
     * **The fallback is named rather than silent.** Rows ingested before `AAO_System_Ref__c`
     * existed carry no system reference, so they key on account plus occurred time, which
     * separates the 17 June call from the 29 July one and joins the two 29 July normalizations
     * exactly as the ruling requires. It is a weaker key than the real one: two genuinely
     * different calls on one account starting in the same second would collide, which no
     * calendar produces and which the system reference removes the moment ingest writes it.
     * The prefix says which key answered, so a reader can tell them apart.
     */

    /**
     * THE ALIAS. Ruled 7 August: one human, one participant, summed once the ladder resolves
     * them to the same person.
     *
     * Jefferson is two participation identities on this deal - `Jefferson Vargas` unlinked and
     * `Vargas, Jefferson [EMR/SYSS/AT/MEDI]` linked to the Contact the create leg made from
     * that same parsed name. One human, occasions split rather than summed.
     *
     * **It aliases and never merges, and the reason is the retirement law's reason.** Claims
     * key the Participant, so merging rows rewrites what claims point at, which is a deletion
     * wearing a merge's clothes. Both rows stay readable; only the derivation changes.
     *
     * **READ ONLY.** This runs inside a coverage read, so it must not link back, must not
     * create, and must not take the ladder's writing rungs. It takes the two cheap read rungs,
     * email and name-within-the-account, and NEVER PICKS: two matches resolve to neither.
     *
     * **The honest gap, named.** Two UNRESOLVED rows for one human still read as two people,
     * because joining them would mean guessing that two spellings are one person, which is
     * exactly what never-pick forbids. That case stays split and stays visible.
     */
    private static Map<Id, Id> aliasByRow(List<AAO_Participant__c> people) {
        Map<Id, Id> out = new Map<Id, Id>();
        Set<String> emails = new Set<String>();
        Set<String> lastNames = new Set<String>();
        Set<Id> accounts = new Set<Id>();
        List<AAO_Participant__c> unlinked = new List<AAO_Participant__c>();
        for (AAO_Participant__c p : people) {
            if (p.AAO_Contact__c != null) {
                continue;
            }
            unlinked.add(p);
            if (String.isNotBlank(p.AAO_Email__c)) {
                emails.add(p.AAO_Email__c.toLowerCase());
            }
            AAO_PersonName.Parsed n = AAO_PersonName.parse(
                String.isBlank(p.AAO_Display_Name__c) ? p.AAO_Roster_Key__c : p.AAO_Display_Name__c
            );
            if (n.ok() && String.isNotBlank(n.last)) {
                lastNames.add(n.last);
            }
            if (p.AAO_Source__r != null && p.AAO_Source__r.AAO_Account__c != null) {
                accounts.add(p.AAO_Source__r.AAO_Account__c);
            }
        }
        if (unlinked.isEmpty()) {
            return out;
        }

        Map<String, List<Id>> byEmail = new Map<String, List<Id>>();
        Map<String, List<Id>> byName = new Map<String, List<Id>>();
        for (Contact c : [
            SELECT Id, Email, FirstName, LastName, AccountId
            FROM Contact
            WHERE (Email IN :emails)
               OR (AccountId IN :accounts AND LastName IN :lastNames)
        ]) {
            if (String.isNotBlank(c.Email)) {
                String k = c.Email.toLowerCase();
                if (!byEmail.containsKey(k)) {
                    byEmail.put(k, new List<Id>());
                }
                byEmail.get(k).add(c.Id);
            }
            String nk = c.AccountId + '|' + c.LastName + '|' + c.FirstName;
            if (!byName.containsKey(nk)) {
                byName.put(nk, new List<Id>());
            }
            byName.get(nk).add(c.Id);
        }

        for (AAO_Participant__c p : unlinked) {
            if (String.isNotBlank(p.AAO_Email__c)) {
                List<Id> hit = byEmail.get(p.AAO_Email__c.toLowerCase());
                if (hit != null && hit.size() == 1) {
                    out.put(p.Id, hit[0]);
                    continue;
                }
            }
            AAO_PersonName.Parsed n = AAO_PersonName.parse(
                String.isBlank(p.AAO_Display_Name__c) ? p.AAO_Roster_Key__c : p.AAO_Display_Name__c
            );
            Id acct = p.AAO_Source__r == null ? null : p.AAO_Source__r.AAO_Account__c;
            if (!n.ok() || acct == null) {
                continue;
            }
            List<Id> hit = byName.get(acct + '|' + n.last + '|' + n.first);
            if (hit != null && hit.size() == 1) {
                out.put(p.Id, hit[0]);
            }
        }
        return out;
    }

    @TestVisible
    private static String occasionKey(AAO_Participant__c p) {
        AAO_Source__c src = p.AAO_Source__r;
        if (src == null) {
            return 'no-source:' + p.Id;
        }
        if (String.isNotBlank(src.AAO_System_Ref__c)) {
            return 'sys:' + src.AAO_System_Ref__c;
        }
        if (src.AAO_Evidence_Occurred__c == null) {
            return 'no-occurred:' + p.Id;
        }
        return 'acct:' + src.AAO_Account__c + '@' + src.AAO_Evidence_Occurred__c.getTime();
    }

    public static Map<Id, Integer> occasionsByPerson(Id opportunityId) {
        // **TWO KEYS FOR TWO JOBS.** Ruled 7 August. The artifact hash stays the byte-provenance
        // key that spans are checked against, untouched. OCCASION IDENTITY IS THE CONVERSATION,
        // and it is NOT the normalized bytes: the 29 July call was seeded twice, raw and NF1,
        // same conversation and same occurred-time to the second, and the two normalizations
        // carry two different hashes. Counting hashes made one call read as two occasions, so
        // the dedup failed precisely where it was designed to work.
        Map<Id, Set<String>> hashes = new Map<Id, Set<String>>();
        for (AAO_Participant__c p : [
            SELECT Id, AAO_Roster_Key__c, AAO_Contact__c,
                AAO_Source__r.AAO_System_Ref__c,
                AAO_Source__r.AAO_Evidence_Occurred__c,
                AAO_Source__r.AAO_Account__c
            FROM AAO_Participant__c
            WHERE AAO_Opportunity__c = :opportunityId
        ]) {
            if (!hashes.containsKey(p.Id)) {
                hashes.put(p.Id, new Set<String>());
            }
            hashes.get(p.Id).add(occasionKey(p));
        }

        // ONE PERSON ACROSS SOURCES IS ONE PERSON. Participation is per Source, so a person on
        // three calls has three participant rows on this deal; the occasions belong to the
        // PERSON, so they are regrouped by identity before being counted. Grouping by the
        // participant row would give everybody exactly one occasion and the dimension would
        // measure nothing.
        Map<String, Set<String>> byIdentity = new Map<String, Set<String>>();
        Map<String, List<Id>> rowsByIdentity = new Map<String, List<Id>>();
        List<AAO_Participant__c> people = [
            SELECT Id, AAO_Roster_Key__c, AAO_Contact__c, AAO_Display_Name__c, AAO_Email__c,
                AAO_Source__r.AAO_Account__c
            FROM AAO_Participant__c
            WHERE AAO_Opportunity__c = :opportunityId
        ];
        Map<Id, Id> alias = aliasByRow(people);
        for (AAO_Participant__c p : people) {
            Id resolved = p.AAO_Contact__c != null ? p.AAO_Contact__c : alias.get(p.Id);
            String identity = resolved != null
                ? 'c:' + resolved
                : 'r:' + p.AAO_Roster_Key__c;
            if (!byIdentity.containsKey(identity)) {
                byIdentity.put(identity, new Set<String>());
                rowsByIdentity.put(identity, new List<Id>());
            }
            byIdentity.get(identity).addAll(hashes.get(p.Id));
            rowsByIdentity.get(identity).add(p.Id);
        }

        Map<Id, Integer> out = new Map<Id, Integer>();
        for (String identity : byIdentity.keySet()) {
            Integer occasions = byIdentity.get(identity).size();
            for (Id rowId : rowsByIdentity.get(identity)) {
                out.put(rowId, occasions);
            }
        }
        return out;
    }
}
