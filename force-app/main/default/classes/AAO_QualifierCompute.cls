/**
 * THE COMPUTED SIX. Arithmetic over rows this product already wrote, with no model call and no
 * contract, exactly as each qualifier's own seeded tip declares its plane.
 *
 * ===== EVERY VOCABULARY HERE WAS READ FROM THE ORG, NEVER ASSUMED.
 *
 * "Supporter or better" is `{Mentor, Supporter}` because the stored status set is
 * `Mentor, Supporter, Neutral, Non-Supporter, Enemy, Unknown` and those are the two above the
 * line. A key player is `ALTF__Is_Key_Player__c`, a stored fact rather than something derived
 * here. "A goal or pressure" is `{Goal, Pressure}` from the card type set. Buyer roles come from
 * the stored set with `Unknown` treated as unfilled, because a row that says Unknown has not
 * answered the question the qualifier asks.
 *
 * ===== AND CRITERIA IS NOT A MAP QUESTION, which is the one design flagged.
 *
 * Its text reads *"Decision criteria are recorded and no required criterion is still open"* and
 * it measures `AAO_Criterion__c` - a third surface. Folding it into the map join would have
 * produced an answer that looks computed and measures the wrong rows.
 *
 * ===== ONE INTERPRETATION IS NAMED RATHER THAN BURIED.
 *
 * The criterion object carries no open/closed field. **"Still open" is read here as: a required,
 * un-retired criterion with no live answer against it.** That is grounded in the schema - answers
 * do point at criteria, twenty-one of them on this org today - but it IS a reading, and if design
 * means something else the change is this one method.
 */
public with sharing class AAO_QualifierCompute {

    public static final String EXTERNAL_ON_MAP = 'EXTERNAL_ON_MAP';
    public static final String SPEAKERS_MAPPED_WITH_ROLE = 'SPEAKERS_MAPPED_WITH_ROLE';
    public static final String KEY_PLAYERS_SUPPORTIVE = 'KEY_PLAYERS_SUPPORTIVE';
    public static final String REQUIRED_CRITERIA_CLOSED = 'REQUIRED_CRITERIA_CLOSED';
    public static final String APPROVERS_ON_MAP = 'APPROVERS_ON_MAP';
    public static final String DECISION_MAKER_HAS_INSIGHT = 'DECISION_MAKER_HAS_INSIGHT';

    private static final Set<String> SUPPORTIVE = new Set<String>{ 'Mentor', 'Supporter' };
    private static final Set<String> GOAL_OR_PRESSURE = new Set<String>{ 'Goal', 'Pressure' };
    private static final String UNKNOWN = 'Unknown';

    /**
     * A COMPUTED ANSWER AND THE ROWS THAT MADE IT. `because` is the state citation: a computed
     * establishment cites the rows that satisfied it, never a quote, because nobody said it.
     */
    public class Verdict {
        public String status;
        public String because;
        public Verdict(String status, String because) {
            this.status = status;
            this.because = because;
        }
    }

    /**
     * Every computed predicate for one deal, in a bounded number of queries.
     *
     * A predicate with NOTHING TO MEASURE returns null rather than No. Silence is not a No: a
     * deal with no calls yet has not failed MAPPED, it has not been asked. Only the predicates
     * that can actually see something answer.
     */
    public static Map<String, Verdict> evaluate(Id opportunityId) {
        Map<String, Verdict> out = new Map<String, Verdict>();
        if (opportunityId == null) {
            return out;
        }

        // ---- the map, once
        Map<Id, ALTF__Contact_Map_Details__c> mapByContact =
            new Map<Id, ALTF__Contact_Map_Details__c>();
        for (ALTF__Contact_Map_Details__c m : [
            SELECT ALTF__Contact__c, ALTF__Buyer_Role__c, ALTF__Status__c, ALTF__Is_Key_Player__c
            FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c = :opportunityId
        ]) {
            if (m.ALTF__Contact__c != null) {
                mapByContact.put(m.ALTF__Contact__c, m);
            }
        }

        // ---- the people who actually spoke, external only
        Map<Id, String> externalSpeakers = new Map<Id, String>();
        for (AAO_Participant__c p : [
            SELECT AAO_Contact__c, AAO_Display_Name__c, AAO_Internal__c
            FROM AAO_Participant__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Contact__c != null
        ]) {
            if (p.AAO_Internal__c != true) {
                externalSpeakers.put(p.AAO_Contact__c, p.AAO_Display_Name__c);
            }
        }

        out.put(EXTERNAL_ON_MAP, externalOnMap(mapByContact, externalSpeakers));
        out.put(SPEAKERS_MAPPED_WITH_ROLE, speakersMapped(mapByContact, externalSpeakers));
        out.put(KEY_PLAYERS_SUPPORTIVE, keyPlayersSupportive(mapByContact));
        out.put(REQUIRED_CRITERIA_CLOSED, requiredCriteriaClosed(opportunityId));
        out.put(APPROVERS_ON_MAP, approversOnMap(opportunityId, mapByContact));
        out.put(DECISION_MAKER_HAS_INSIGHT, dmHasInsight(opportunityId));

        for (String k : new List<String>(out.keySet())) {
            if (out.get(k) == null) {
                out.remove(k);
            }
        }
        return out;
    }

    // ------------------------------------------------------------------ the six

    private static Verdict externalOnMap(
        Map<Id, ALTF__Contact_Map_Details__c> onMap, Map<Id, String> speakers
    ) {
        // Membership of the map is the question; having spoken is not required by the
        // qualifier's own text, which reads "at least one external participant is identified
        // on the relationship map". Existential, so an empty map is a real No rather than a
        // vacuous anything.
        Integer n = onMap.size();
        if (onMap.isEmpty()) {
            return new Verdict('No', 'No external participant stands on the relationship map.');
        }
        return new Verdict('Yes', n + ' contacts stand on the relationship map.');
    }

    private static Verdict speakersMapped(
        Map<Id, ALTF__Contact_Map_Details__c> onMap, Map<Id, String> speakers
    ) {
        if (speakers.isEmpty()) {
            // Nobody has spoken yet. Not a failure - a question not yet askable.
            return null;
        }
        List<String> missing = new List<String>();
        for (Id c : speakers.keySet()) {
            ALTF__Contact_Map_Details__c m = onMap.get(c);
            if (m == null || String.isBlank(m.ALTF__Buyer_Role__c) ||
                    m.ALTF__Buyer_Role__c == UNKNOWN) {
                missing.add(speakers.get(c));
            }
        }
        if (missing.isEmpty()) {
            return new Verdict(
                'Yes',
                'All ' + speakers.size() + ' external speakers stand on the map with a buyer role.'
            );
        }
        return new Verdict(
            'No',
            missing.size() + ' of ' + speakers.size() + ' external speakers carry no buyer role ' +
            'on the map: ' + String.join(missing, ', ')
        );
    }

    private static Verdict keyPlayersSupportive(Map<Id, ALTF__Contact_Map_Details__c> onMap) {
        Integer keyPlayers = 0;
        Integer below = 0;
        for (ALTF__Contact_Map_Details__c m : onMap.values()) {
            if (m.ALTF__Is_Key_Player__c != true) {
                continue;
            }
            keyPlayers++;
            if (!SUPPORTIVE.contains(m.ALTF__Status__c)) {
                below++;
            }
        }
        if (keyPlayers == 0) {
            // No key player is marked, so there is nothing to measure. Not a No.
            return null;
        }
        if (below == 0) {
            return new Verdict(
                'Yes', 'All ' + keyPlayers + ' key players stand at Supporter or better.'
            );
        }
        return new Verdict(
            'No', below + ' of ' + keyPlayers + ' key players stand below Supporter.'
        );
    }

    private static Verdict requiredCriteriaClosed(Id opportunityId) {
        List<AAO_Criterion__c> criteria = [
            SELECT Id, AAO_Subject__c, AAO_Required__c
            FROM AAO_Criterion__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Retired__c = false
        ];
        if (criteria.isEmpty()) {
            return new Verdict('No', 'No decision criteria are recorded on this deal.');
        }
        Set<Id> answered = new Set<Id>();
        for (AAO_Answer__c a : [
            SELECT AAO_Criterion__c FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Criterion__c != null
              AND AAO_Publication_State__c = 'Live' AND AAO_Superseded_By__c = null
        ]) {
            answered.add(a.AAO_Criterion__c);
        }
        List<String> stillOpen = new List<String>();
        Integer required = 0;
        for (AAO_Criterion__c c : criteria) {
            if (c.AAO_Required__c != true) {
                continue;
            }
            required++;
            if (!answered.contains(c.Id)) {
                stillOpen.add(c.AAO_Subject__c);
            }
        }
        if (stillOpen.isEmpty()) {
            // THE ONE GENUINELY VACUOUS CASE IN THE SIX, and it is disclosed rather than
            // smoothed over. The question is a CONJUNCTION - "criteria are recorded AND no
            // required criterion is still open" - so with criteria recorded the first clause
            // carries real substance and a Yes is honest. But if NONE was marked required the
            // second clause is true of an empty set, and a reader deserves to see that shape
            // rather than a bare Yes. Whether "recorded but none required" should be a Yes at
            // all is a methodology question and it is design's, not this method's.
            return new Verdict(
                'Yes',
                required == 0
                    ? criteria.size() + ' criteria recorded, though none is marked required, ' +
                      'so nothing was outstanding to close.'
                    : criteria.size() + ' criteria recorded, and all ' + required +
                      ' required ones are answered.'
            );
        }
        return new Verdict(
            'No',
            stillOpen.size() + ' required criteria are still open: ' +
            String.join(stillOpen, ', ')
        );
    }

    /**
     * CHAIN's identity join. The approvers are the SUBJECTS of live answers on the approval-chain
     * proposition; being named in that evidence is what makes someone an approver, and the join
     * is to our own ledger rather than to a parsed sentence.
     */
    private static Verdict approversOnMap(
        Id opportunityId, Map<Id, ALTF__Contact_Map_Details__c> onMap
    ) {
        Map<Id, String> approvers = subjectsOf(opportunityId, 'AAO_BANT_A3');
        if (approvers.isEmpty()) {
            return null;
        }
        List<String> missing = new List<String>();
        for (Id c : approvers.keySet()) {
            if (!onMap.containsKey(c)) {
                missing.add(approvers.get(c));
            }
        }
        if (missing.isEmpty()) {
            return new Verdict(
                'Yes', 'All ' + approvers.size() + ' named approvers stand on the map.'
            );
        }
        return new Verdict(
            'No', missing.size() + ' named approvers are absent from the map: ' +
            String.join(missing, ', ')
        );
    }

    /** DMINSIGHT's identity join: the decision maker is the subject of a live A1 answer. */
    private static Verdict dmHasInsight(Id opportunityId) {
        Map<Id, String> dms = subjectsOf(opportunityId, 'AAO_BANT_A1');
        if (dms.isEmpty()) {
            return null;
        }
        Set<Id> withInsight = new Set<Id>();
        for (ALTF__Insight_Card_Contact__c link : [
            SELECT ALTF__Contact__c, ALTF__Insight_Card__r.ALTF__Type__c
            FROM ALTF__Insight_Card_Contact__c
            WHERE ALTF__Contact__c IN :dms.keySet()
              AND ALTF__Insight_Card__r.ALTF__Opportunity__c = :opportunityId
        ]) {
            if (GOAL_OR_PRESSURE.contains(link.ALTF__Insight_Card__r.ALTF__Type__c)) {
                withInsight.add(link.ALTF__Contact__c);
            }
        }
        List<String> bare = new List<String>();
        for (Id c : dms.keySet()) {
            if (!withInsight.contains(c)) {
                bare.add(dms.get(c));
            }
        }
        if (bare.isEmpty()) {
            return new Verdict(
                'Yes', 'The decision maker carries a goal or pressure on the insight board.'
            );
        }
        return new Verdict(
            'No', 'No goal or pressure stands on the board for ' + String.join(bare, ', ') + '.'
        );
    }

    // ------------------------------------------------------------------ internals

    /** The people a proposition's live answers are ABOUT, by contact. */
    private static Map<Id, String> subjectsOf(Id opportunityId, String code) {
        Map<Id, String> out = new Map<Id, String>();
        for (AAO_Answer__c a : [
            SELECT AAO_Subject_Contact__c, AAO_Subject_Contact__r.Name, AAO_Interpretation__c,
                   AAO_Participant__r.AAO_Display_Name__c, AAO_Participant__r.AAO_Contact__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :opportunityId
              AND AAO_Publication_State__c = 'Live'
              AND AAO_Superseded_By__c = null
              AND AAO_Verdict__c = 'TRUE'
              AND AAO_Evidence_Contract__r.AAO_Proposition_Code__c = :code
        ]) {
            // AAO_Interpretation__c is a long text area and cannot be filtered in SOQL, so the
            // AFFIRMED test happens here rather than in the WHERE. The address law: the field's
            // own type decides where the filter can live, not what reads tidiest.
            if (a.AAO_Interpretation__c != 'AFFIRMED') {
                continue;
            }
            Id c = a.AAO_Subject_Contact__c != null
                ? a.AAO_Subject_Contact__c
                : (a.AAO_Participant__r == null ? null : a.AAO_Participant__r.AAO_Contact__c);
            if (c == null) {
                continue;
            }
            String name = a.AAO_Subject_Contact__r != null
                ? a.AAO_Subject_Contact__r.Name
                : (a.AAO_Participant__r == null ? 'a participant'
                    : a.AAO_Participant__r.AAO_Display_Name__c);
            out.put(c, name);
        }
        return out;
    }
}
