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
    public static Map<Id, Integer> occasionsByPerson(Id opportunityId) {
        Map<Id, Set<String>> hashes = new Map<Id, Set<String>>();
        for (AAO_Participant__c p : [
            SELECT Id, AAO_Artifact_SHA256__c, AAO_Roster_Key__c, AAO_Contact__c
            FROM AAO_Participant__c
            WHERE AAO_Opportunity__c = :opportunityId
        ]) {
            if (!hashes.containsKey(p.Id)) {
                hashes.put(p.Id, new Set<String>());
            }
            hashes.get(p.Id).add(
                String.isBlank(p.AAO_Artifact_SHA256__c)
                    ? 'no-hash:' + p.Id
                    : p.AAO_Artifact_SHA256__c
            );
        }

        // ONE PERSON ACROSS SOURCES IS ONE PERSON. Participation is per Source, so a person on
        // three calls has three participant rows on this deal; the occasions belong to the
        // PERSON, so they are regrouped by identity before being counted. Grouping by the
        // participant row would give everybody exactly one occasion and the dimension would
        // measure nothing.
        Map<String, Set<String>> byIdentity = new Map<String, Set<String>>();
        Map<String, List<Id>> rowsByIdentity = new Map<String, List<Id>>();
        for (AAO_Participant__c p : [
            SELECT Id, AAO_Artifact_SHA256__c, AAO_Roster_Key__c, AAO_Contact__c
            FROM AAO_Participant__c
            WHERE AAO_Opportunity__c = :opportunityId
        ]) {
            String identity = p.AAO_Contact__c != null
                ? 'c:' + p.AAO_Contact__c
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
