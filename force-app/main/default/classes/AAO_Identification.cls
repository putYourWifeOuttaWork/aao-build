/**
 * THE IDENTIFICATION FLAG, as a mechanism rather than a picklist value.
 *
 * The ninetieth stamp's item 10, verbatim on what this owes: "the Identification flag as a
 * BUILT MECHANISM - `AAO_Flag__c.AAO_Type__c` still has no `Identification` value, and a
 * picklist value is not the mechanism: type, raise at both held sites, bound key,
 * clear-by-identification-only, test."
 *
 * WHAT IT IS FOR. The resolver has two terminals where it knows a real person is in the
 * evidence and refuses to guess which one: AMBIGUOUS (more than one candidate matches and
 * context cannot separate them) and the model leg's HELD (a real person of this deal with no
 * match in the org at all). Both are correct refusals. Both are also invisible: the pair
 * carries its disposition and nothing tells a seller there is a human here waiting to be
 * named. This is that surface.
 *
 * THE RENDER RULING (eighty-eighth stamp item 2) is what makes the flag load-bearing rather
 * than decorative: an unresolved mention appears on the map carrying its resolution state,
 * held, N anchors, flag open, "and clears by identification only". A flag nobody can see is
 * not a flag, and a flag that clears for any reason other than the work being done is worse
 * than none, because it teaches the reader that red means nothing.
 *
 * WHY ONE FLAG PER DESIGNATOR PER DEAL, not one per pair. Priya mentioned in session 3 and
 * again in session 4 is ONE unidentified person, not two problems. The bound key normalises
 * the designator and scopes it to the opportunity, so every later mention of the same person
 * updates the standing flag instead of minting another. That is the cardinality guard's own
 * pattern (`AAO_Cardinality` writes `AAO_Bound_Key__c` for exactly this reason) reused rather
 * than reinvented.
 *
 * CLEAR BY IDENTIFICATION ONLY, AND MEASURED, NEVER ASSERTED. `reconcile` re-reads the org
 * and asks one question: is this designator now bound to a Contact? It does not accept a
 * caller's word for it, it does not clear on acknowledgement, it does not clear because a
 * later run stopped mentioning the person, and it does not clear on age. That mirrors
 * `AAO_Flags.reconcile`, which re-reads the answer row rather than trusting a passed verdict,
 * and it is the same reasoning: one place decides, and it decides from evidence.
 *
 * THE HONEST LIMIT, named here rather than discovered later. Two bindings can identify a
 * designator, and only one of them can happen today:
 *
 *   (a) THE LADDER BINDS IT. A pair carrying this designator comes back `Identified` with
 *       `AAO_Person__c` set to a Participant that carries a Contact. This fires whenever a
 *       human adds the missing Contact and the deal is read again, which is the ordinary way
 *       this work gets done. LIVE.
 *   (b) THE SHADOW IS PROMOTED. The shadow person carrying this designator gains
 *       `AAO_Promoted_Contact__c`. NOTHING WRITES THAT FIELD TODAY - the eighty-eighth
 *       stamp's item 2 names promotion as the debt whose build comes first after the read.
 *       It is read here deliberately, so that wiring promotion clears these flags with no
 *       further change, and so the field stops being a plan and gains its first reader.
 *
 * That second path is a reader waiting on a writer, which is the exact inverse of the
 * field-with-no-readers law and is disclosed rather than sold as working.
 */
public class AAO_Identification {
    public static final String TYPE = 'Identification';
    /** More than one candidate matched and context could not separate them. */
    public static final String CAUSE_AMBIGUOUS = 'Identity_Ambiguous';
    /** A real person of this deal with no match in the org at all. */
    public static final String CAUSE_UNRESOLVED = 'Identity_Unresolved';

    private static final Integer KEY_MAX = 120;

    /** One held mention, as the resolver saw it. */
    public class Held {
        public Id opportunityId;
        public Id accountId;
        public String designator;
        /** CAUSE_AMBIGUOUS or CAUSE_UNRESOLVED. */
        public String cause;
        /** The resolver's own words for why it refused. Never a judgement of the person. */
        public String basis;
        /** The shadow standing on the utterance, where one was written. May be null. */
        public Id shadowPersonId;
        /** When the words were spoken, so the flag ages from the evidence, not from now. */
        public Datetime occurred;
    }

    // ============================================================================= key

    /**
     * Stable across runs and across sessions, so the same person raises one flag forever.
     * Normalised because "Priya" and " priya " are one human and two strings.
     */
    @TestVisible
    private static String boundKey(Id opportunityId, String designator) {
        String d = designator == null ? '' : designator.trim().toLowerCase();
        d = d.replaceAll('\\s+', ' ');
        String k = 'ident|' + opportunityId + '|' + d;
        return k.length() > KEY_MAX ? k.substring(0, KEY_MAX) : k;
    }

    // =========================================================================== raise

    /**
     * Idempotent by bound key. A designator already standing gets its evidence watermark
     * moved forward and nothing else; it never mints a second flag and it never re-opens a
     * flag a human already cleared by doing the work.
     */
    public static Integer raiseFor(List<Held> helds) {
        if (helds == null || helds.isEmpty()) {
            return 0;
        }

        Map<String, Held> byKey = new Map<String, Held>();
        for (Held h : helds) {
            if (h == null || h.opportunityId == null || String.isBlank(h.designator)) {
                continue;
            }
            // Last mention of a designator in one batch wins its basis; the key collapses
            // them either way, so this only decides whose words ride the row.
            byKey.put(boundKey(h.opportunityId, h.designator), h);
        }
        if (byKey.isEmpty()) {
            return 0;
        }

        Map<String, AAO_Flag__c> standing = new Map<String, AAO_Flag__c>();
        for (AAO_Flag__c f : [
            SELECT Id, AAO_Bound_Key__c, AAO_State__c, AAO_Cause__c,
                   AAO_Last_Evidence_Considered__c
            FROM AAO_Flag__c
            WHERE AAO_Bound_Key__c IN :byKey.keySet() AND AAO_Type__c = :TYPE
        ]) {
            standing.put(f.AAO_Bound_Key__c, f);
        }

        List<AAO_Flag__c> raise = new List<AAO_Flag__c>();
        List<AAO_Flag__c> touch = new List<AAO_Flag__c>();

        for (String k : byKey.keySet()) {
            Held h = byKey.get(k);
            Datetime seen = h.occurred == null ? System.now() : h.occurred;
            AAO_Flag__c existing = standing.get(k);

            if (existing != null) {
                // A CLEARED FLAG IS NOT RE-OPENED BY A LATER MENTION. The person was
                // identified; the deal mentioning them again is not a new problem, and
                // re-opening would make the surface flicker for a reason nobody could act on.
                if (existing.AAO_State__c == 'Cleared') {
                    continue;
                }
                if (existing.AAO_Last_Evidence_Considered__c == null
                    || existing.AAO_Last_Evidence_Considered__c < seen) {
                    existing.AAO_Last_Evidence_Considered__c = seen;
                    touch.add(existing);
                }
                continue;
            }

            raise.add(
                new AAO_Flag__c(
                    AAO_Opportunity__c = h.opportunityId,
                    AAO_Account__c = h.accountId,
                    AAO_Type__c = TYPE,
                    AAO_State__c = 'Standing',
                    AAO_Cause__c = h.cause == null ? CAUSE_UNRESOLVED : h.cause,
                    AAO_Bound_Key__c = k,
                    // The flag ages from when the words were spoken, not from when this ran.
                    // AAO_Flags made the same choice for the same reason.
                    AAO_Raised_At__c = seen,
                    AAO_Last_Evidence_Considered__c = seen,
                    AAO_Answer_Here__c = abbrev('Identify "' + h.designator + '"', 255),
                    AAO_Missing_Members__c = h.basis
                )
            );
        }

        if (!touch.isEmpty()) {
            update touch;
        }
        if (!raise.isEmpty()) {
            insert raise;
        }
        return raise.size();
    }

    // =========================================================================== clear

    /**
     * CLEAR BY IDENTIFICATION ONLY. Re-reads the org for each standing flag on the deal and
     * clears exactly those whose designator is now bound to a Contact. Everything else stays
     * standing, including a designator nobody mentioned this run.
     *
     * Returns the number cleared.
     */
    public static Integer reconcile(Id opportunityId) {
        if (opportunityId == null) {
            return 0;
        }
        List<AAO_Flag__c> flags = [
            SELECT Id, AAO_Bound_Key__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :opportunityId
              AND AAO_Type__c = :TYPE
              AND AAO_State__c != 'Cleared'
        ];
        if (flags.isEmpty()) {
            return 0;
        }

        Map<String, Id> identified = identifiedDesignators(opportunityId);
        if (identified.isEmpty()) {
            return 0;
        }

        List<AAO_Flag__c> cleared = new List<AAO_Flag__c>();
        for (AAO_Flag__c f : flags) {
            // The key already carries the normalised designator, so the lookup needs no
            // second normalisation and cannot drift from the one raise used.
            String d = designatorOf(f.AAO_Bound_Key__c, opportunityId);
            if (d == null || !identified.containsKey(d)) {
                continue;
            }
            f.AAO_State__c = 'Cleared';
            f.AAO_Cleared_At__c = System.now();
            f.AAO_Subject_Contact__c = identified.get(d);
            cleared.add(f);
        }
        if (!cleared.isEmpty()) {
            update cleared;
        }
        return cleared.size();
    }

    /**
     * The two bindings that count as identification, both measured from the org.
     * Keyed by normalised designator, valued by the Contact that identifies it.
     */
    @TestVisible
    private static Map<String, Id> identifiedDesignators(Id opportunityId) {
        Map<String, Id> out = new Map<String, Id>();

        // (a) THE LADDER BOUND IT. Live today, and the join matters: THE DESIGNATOR AND THE
        // PERSON NEVER SHARE A ROW. Call 1 writes the designator onto the Located pair and
        // is forbidden the person; call 2 writes the person onto an Identified pair and is
        // forbidden the located-only fields. `AAO_PairTriggerHandler` enforces that
        // separation with `addError`, and `AAO_Resolve.disposition()` does not copy the
        // designator forward. So identification is read through the parent link, and a
        // query asking for both columns on one row would match nothing, ever.
        for (AAO_Pair__c p : [
            SELECT AAO_Located_Pair__r.AAO_About_Designator__c, AAO_Person__r.AAO_Contact__c
            FROM AAO_Pair__c
            WHERE AAO_Source__r.AAO_Opportunity__c = :opportunityId
              AND AAO_Stage__c = 'Identified'
              AND AAO_Disposition__c = 'Identified'
              AND AAO_Person__c != null
              AND AAO_Person__r.AAO_Contact__c != null
              AND AAO_Located_Pair__r.AAO_About_Designator__c != null
        ]) {
            out.put(
                norm(p.AAO_Located_Pair__r.AAO_About_Designator__c),
                p.AAO_Person__r.AAO_Contact__c
            );
        }

        // (b) THE SHADOW WAS PROMOTED. Nothing writes this field yet - promotion is the
        // eighty-eighth stamp's named debt - so this branch is a reader waiting on its
        // writer, deliberately, so wiring promotion needs no change here.
        for (AAO_Shadow_Person__c s : [
            SELECT AAO_Designator__c, AAO_Promoted_Contact__c
            FROM AAO_Shadow_Person__c
            WHERE AAO_Account__c IN (
                    SELECT AccountId FROM Opportunity WHERE Id = :opportunityId
                )
              AND AAO_Designator__c != null
              AND AAO_Promoted_Contact__c != null
        ]) {
            out.put(norm(s.AAO_Designator__c), s.AAO_Promoted_Contact__c);
        }

        return out;
    }

    // ========================================================================= reading

    /** Standing identification flags on a deal: the count the map shows beside the mention. */
    public static Integer standing(Id opportunityId) {
        return [
            SELECT COUNT()
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :opportunityId
              AND AAO_Type__c = :TYPE
              AND AAO_State__c = 'Standing'
        ];
    }

    // ========================================================================== helpers

    /** Public so promotion normalises designators and Contact name forms the same single way. */
    public static String normalise(String s) {
        return norm(s);
    }

    /**
     * CLEAR BY PERSON, NEVER BY KEY. Every standing flag whose designator is one of this
     * person's resolved forms clears together, carrying the Contact as its receipt.
     *
     * This is the half a key-matched clear cannot do. Priya raised two flags under
     * `…|priya natarajan` and `…|priya` because the eighty-seventh stamp's ruling forbids
     * collapsing forms at the key; matching on the key would close one and strand the other
     * forever. The forms differ, the person does not, and the person is what finishes the work.
     */
    public static Integer clearForPerson(
        Id opportunityId,
        Set<String> designators,
        Id contactId
    ) {
        if (opportunityId == null || designators == null || designators.isEmpty()) {
            return 0;
        }
        List<AAO_Flag__c> flags = [
            SELECT Id, AAO_Bound_Key__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :opportunityId
              AND AAO_Type__c = :TYPE
              AND AAO_State__c != 'Cleared'
        ];
        List<AAO_Flag__c> cleared = new List<AAO_Flag__c>();
        for (AAO_Flag__c f : flags) {
            String d = designatorOf(f.AAO_Bound_Key__c, opportunityId);
            if (d == null || !designators.contains(d)) {
                continue;
            }
            f.AAO_State__c = 'Cleared';
            f.AAO_Cleared_At__c = System.now();
            f.AAO_Subject_Contact__c = contactId;
            cleared.add(f);
        }
        if (!cleared.isEmpty()) {
            update cleared;
        }
        return cleared.size();
    }

    @TestVisible
    private static String norm(String designator) {
        if (designator == null) {
            return '';
        }
        return designator.trim().toLowerCase().replaceAll('\\s+', ' ');
    }

    /** The designator half of a bound key, or null if the key is not one of ours. */
    @TestVisible
    private static String designatorOf(String boundKey, Id opportunityId) {
        String prefix = 'ident|' + opportunityId + '|';
        if (boundKey == null || !boundKey.startsWith(prefix)) {
            return null;
        }
        return boundKey.substring(prefix.length());
    }

    private static String abbrev(String s, Integer n) {
        if (s == null) {
            return null;
        }
        return s.length() > n ? s.substring(0, n) : s;
    }
}
