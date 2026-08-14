/**
 * THE SENTIMENT COUNTER. Charters §P8.4, arithmetic refined at v2.8 from the first joint
 * grading.
 *
 * One integer per person per scope, minus three to plus three, clamped, with the rungs at
 * their ruled positions. Support is the one dimension with no extraction ontology - sentiment
 * is where ontology is not feasible - so the model reads a state and this class does the
 * accumulating.
 *
 * **THE FIELD IS THE STANDING VALUE ONLY** (`AAO_Answer__c.AAO_Support_Counter__c`, addendum
 * 18, placed by design under Matthew's delegation). It is a cache of an arithmetic over the
 * claims, and `rebuild` recomputes it from those claims in evidence-occurred order. **A drift
 * between the field and the ledger is a bug, never a tie-break** - nothing here ever prefers
 * the field when the two disagree, because the receipts are the record and the field is a
 * convenience.
 *
 * WHY IT LIVES ON THE ANSWER ROW. Answers are already the per-dimension state rows projection
 * reads, and the citations law already lives there, so every move derives from cited claims at
 * reconciliation. A counter on Participant would be per person GLOBAL, which is wrong the day
 * the account grain returns, because stance is per scope.
 */
public with sharing class AAO_SupportCounter {
    public class CounterException extends Exception {
    }

    // -------------------------------------------------------------------- the states

    public static final String MENTOR = 'MENTOR';
    public static final String SUPPORTER = 'SUPPORTER';
    public static final String NON_SUPPORTER = 'NON_SUPPORTER';
    public static final String ENEMY = 'ENEMY';

    public static final Integer FLOOR = -3;
    public static final Integer CEILING = 3;

    /**
     * The direction and the reach of each state's evidence.
     *
     * `reach` is the second of the two caps: **evidence never carries anyone past the
     * strongest state it actually voices.** Supporter-grade words top out at +2 however many
     * there are; only mentor-grade words cross to +3; symmetric at -2 and -3. This is what
     * makes terminals PROOF-GATED rather than time-gated - Mentor is reachable in one call
     * over multiple mentor-grade establishments, and unreachable in a hundred calls of
     * supporter-grade ones.
     */
    private static final Map<String, Integer> REACH = new Map<String, Integer>{
        MENTOR => 3,
        SUPPORTER => 2,
        NON_SUPPORTER => -2,
        ENEMY => -3
    };

    /**
     * The rungs, at their ruled positions.
     *
     * **A COUNTED ZERO IS NEUTRAL. A NULL COUNTER IS NEVER-MEASURED.** Matthew's ruling,
     * forty-fourth stamp item 2, in his words: if plus one and minus one net to zero, that is
     * NEUTRAL, not null; the machine weighed support and counter-support and they balance, so
     * the map says Neutral with the evidence behind it, and blank is reserved for
     * never-measured.
     *
     * This REVERSES this method's previous rule, which returned null at zero on the reasoning
     * that neutral "is the derived reading when nothing stands". That conflated two different
     * facts into one blank: nobody said anything about this person, and the machine read both
     * directions and they cancelled. The distinction is carried by the counter itself rather
     * than by a flag, because null and zero are already different values and the caller has
     * both: `Derivation.supportCounter` stays null until a sentiment answer sets it.
     *
     * The specimen that produced the ruling is on the record: Adam Pfeiffer, run `pf0811-live`,
     * one supportive establishment and one hedge upheld as non-support, netting zero and
     * leaving Status blank on a person whose enthusiasm is in the transcript. Neutral is at
     * least legible and carries its citations; blank read as erasure.
     */
    public static String rungFor(Integer counter) {
        if (counter == null) {
            return null;
        }
        if (counter >= 3) {
            return 'Mentor';
        }
        if (counter > 0) {
            return 'Supporter';
        }
        if (counter <= -3) {
            return 'Enemy';
        }
        if (counter < 0) {
            return 'Non-Supporter';
        }
        return 'Neutral';
    }

    public static Boolean isState(String meaning) {
        return meaning != null && REACH.containsKey(meaning.toUpperCase());
    }

    // ------------------------------------------------------------------- one movement

    /** One call's worth of sentiment reads about one person, and what they did. */
    public class Movement {
        public Integer standing = 0;
        public Integer result = 0;
        public Integer positiveReads = 0;
        public Integer negativeReads = 0;
        /** The net sum of the reads, before either cap is applied. */
        public Integer net = 0;
        /** The strongest state this call's evidence actually voiced, per direction. */
        public Integer reach = 0;
        /** True where an explicit declaration set the position outright. */
        public Boolean jumped = false;
        /** True where the movement crossed zero: standing polarity reversed. */
        public Boolean reversedPolarity = false;

        public Integer moved() {
            return result - standing;
        }

        public override String toString() {
            return 'counter ' + standing + ' -> ' + result +
                ' (unit: counter steps; ' + positiveReads + ' positive, ' +
                negativeReads + ' negative, net ' + net +
                ', reach ' + reach +
                (jumped ? ', declared outright' : '') +
                (reversedPolarity ? ', POLARITY REVERSED' : '') + ')';
        }
    }

    /**
     * Apply one call's sentiment reads to a standing counter.
     *
     * @param standing  the counter as it stands, read at reconciliation before anything
     *                  writes. Null is treated as zero, which is the unplaced start.
     * @param states    one entry per distinct verified establishment, in the call's own
     *                  order. Each moves the counter one in its direction.
     * @param declared  the state a speaker declared outright, or null. The jump rule: words
     *                  that explicitly declare a state set the counter to that state's
     *                  position regardless of count.
     */
    public static Movement apply(Integer standing, List<String> states, String declared) {
        Movement m = new Movement();
        m.standing = standing == null ? 0 : standing;
        m.result = m.standing;

        if (String.isNotBlank(declared)) {
            Integer position = REACH.get(declared.toUpperCase());
            if (position == null) {
                throw new CounterException(
                    'Declared state "' + declared + '" is not one of the four. The counter ' +
                    'will not guess a position for a label it does not know.'
                );
            }
            m.jumped = true;
            m.result = position;
            m.reach = position;
            m.reversedPolarity = crossedZero(m.standing, m.result);
            return m;
        }

        if (states == null || states.isEmpty()) {
            return m;
        }

        Integer positiveReach = 0;
        Integer negativeReach = 0;
        for (String raw : states) {
            Integer reach = raw == null ? null : REACH.get(raw.toUpperCase());
            if (reach == null) {
                throw new CounterException(
                    'Sentiment read "' + raw + '" is not one of MENTOR, SUPPORTER, ' +
                    'NON_SUPPORTER, ENEMY. There is no neutral label and no partial: words ' +
                    'that voice no stance produce no pair, so a pair carrying one is our bug.'
                );
            }
            if (reach > 0) {
                m.positiveReads++;
                positiveReach = Math.max(positiveReach, reach);
            } else {
                m.negativeReads++;
                negativeReach = Math.min(negativeReach, reach);
            }
        }

        // MIXED EVIDENCE NETS, and nothing averages. Every quote journals on its own side.
        m.net = m.positiveReads - m.negativeReads;
        if (m.net == 0) {
            // No move. Both sides are on the record; neither carried the person.
            return m;
        }

        // The two caps, and the order matters. The clamp is absolute; the reach cap is
        // directional and NEVER PULLS ANYONE DOWN - a person standing at +3 from mentor-grade
        // evidence is not dragged to +2 by a call of supporter-grade words. At +2, further
        // supporter-grade evidence does nothing, because supporter's ceiling IS +2.
        m.reach = m.net > 0 ? positiveReach : negativeReach;
        Integer proposed = clamp(m.standing + m.net);
        m.result = m.net > 0
            ? Math.max(m.standing, Math.min(proposed, m.reach))
            : Math.min(m.standing, Math.max(proposed, m.reach));
        m.reversedPolarity = crossedZero(m.standing, m.result);
        return m;
    }

    public static Integer clamp(Integer n) {
        if (n == null) {
            return 0;
        }
        return Math.min(CEILING, Math.max(FLOOR, n));
    }

    /**
     * Polarity reversal, which is what a contention flag is raised on. Zero is not a polarity
     * - moving off an unplaced start reverses nothing and must not raise a flag on every
     * first establishment.
     */
    private static Boolean crossedZero(Integer before, Integer after) {
        if (before == null || after == null || before == 0 || after == 0) {
            return false;
        }
        return (before > 0) != (after > 0);
    }

    // ---------------------------------------------------------------------- rebuild

    /**
     * REBUILD FROM THE LEDGER. The field is a cache; this is the arithmetic it caches.
     *
     * Claims in evidence-occurred order, one movement per source-event, because a call's
     * movement is the net sum of ITS establishments and grouping by anything else would let
     * two calls' evidence cancel inside one step. Determinism holds because the counter is a
     * clamped sum over receipts.
     *
     * @param claims sentiment claims for one person on one scope, any order.
     */
    public static Integer rebuild(List<AAO_Claim__c> claims) {
        if (claims == null || claims.isEmpty()) {
            return 0;
        }
        List<AAO_Claim__c> ordered = sortByOccurred(claims);

        Integer counter = 0;
        Integer i = 0;
        while (i < ordered.size()) {
            // One source-event: every claim sharing this occasion moves together.
            Id source = ordered[i].AAO_Source__c;
            Datetime occurred = ordered[i].AAO_Evidence_Occurred__c;
            List<String> states = new List<String>();
            while (
                i < ordered.size() &&
                ordered[i].AAO_Source__c == source &&
                ordered[i].AAO_Evidence_Occurred__c == occurred
            ) {
                String state = stateOf(ordered[i]);
                if (state != null) {
                    states.add(state);
                }
                i++;
            }
            counter = apply(counter, states, null).result;
        }
        return counter;
    }

    /**
     * The state a sentiment claim voiced. Read from the interpretation, which is where call
     * 1's meaning lands; a claim whose interpretation is not one of the four contributed no
     * movement and is skipped rather than guessed at.
     */
    public static String stateOf(AAO_Claim__c c) {
        String raw = c.AAO_Interpretation__c;
        if (String.isBlank(raw)) {
            return null;
        }
        String upper = raw.toUpperCase().trim();
        return REACH.containsKey(upper) ? upper : null;
    }

    /**
     * Evidence-occurred order, nulls first, Id as the tie-break so replay is total rather
     * than merely mostly-ordered. Apex has no comparator on SObject lists, so this is an
     * insertion sort over a buying group's worth of rows.
     */
    private static List<AAO_Claim__c> sortByOccurred(List<AAO_Claim__c> claims) {
        List<AAO_Claim__c> out = new List<AAO_Claim__c>();
        for (AAO_Claim__c c : claims) {
            Integer at = out.size();
            for (Integer i = 0; i < out.size(); i++) {
                if (isBefore(c, out[i])) {
                    at = i;
                    break;
                }
            }
            // `add(index, element)` refuses an index equal to the size, including 0 on an
            // empty list, so appending is its own branch rather than the general case.
            if (at == out.size()) {
                out.add(c);
            } else {
                out.add(at, c);
            }
        }
        return out;
    }

    private static Boolean isBefore(AAO_Claim__c a, AAO_Claim__c b) {
        Datetime x = a.AAO_Evidence_Occurred__c;
        Datetime y = b.AAO_Evidence_Occurred__c;
        if (x == null && y != null) {
            return true;
        }
        if (x != null && y == null) {
            return false;
        }
        if (x != null && y != null && x != y) {
            return x < y;
        }
        return String.valueOf(a.Id) < String.valueOf(b.Id);
    }
}