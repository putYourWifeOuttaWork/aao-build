/**
 * THE NEVER-BLANK DECISION PROCEDURE, and the label-to-value map it reads.
 *
 * Matthew's ruling, seventy-seventh stamp, quoted because it is the whole specification and it
 * closes every branch: *"If the set is EMPTY: write nothing... If the set has ONE value: WRITE IT.
 * No hold, no note-instead-of-value, no exception. If the set has MORE THAN ONE: WRITE THE
 * HIGHEST-RANKED... If a value carries NO RANK in the seed: it sorts BELOW every ranked value but
 * remains eligible; if the established set contains only unranked values, write the FIRST BY THE
 * VENDOR PICKLIST ORDER. An unranked value never causes a blank."*
 *
 * **THE ONLY PATH THAT LEAVES A FIELD UNWRITTEN IS AN EMPTY SET.** That is the property this class
 * exists to guarantee, and it is asserted rather than described: a set with anything in it always
 * yields a value. The previous ladder returned null on any set touching an unranked role, which is
 * why Adam Pfeiffer's Buyer Role sat blank on a live map while two roles stood established behind
 * it — a refusal that was right while nothing ranked those roles and wrong the moment something did.
 *
 * **THE RANKS ARE CONFIGURATION, NOT CONSTANTS**, on `AAO_Map_Value__mdt`. An org may relabel a
 * slot (production displays the stored `Signature Approver` as "Decision Maker and Approver"), so
 * an org whose words differ can state what its words mean rather than have our ranking silently
 * mean something else on its map. **The code reads and writes STORED VALUES only**; the displayed
 * label is carried so humans can reconcile the two, and no label string is ever hardcoded in logic.
 *
 * **THE UNRANKED TIEBREAK READS THE VENDOR'S OWN PICKLIST**, by describe, at run time. It is not
 * configured and not guessed: the order a customer's picklist is in IS the order, and asking the
 * schema is the only way to know it that cannot drift.
 */
public with sharing class AAO_MapValues {
    public class MapValueException extends Exception {
    }

    /** Rank by stored value, per dimension. Absent key means unranked, which is not an error. */
    private static Map<String, Map<String, Integer>> rankCache;
    /** Displayed label by stored value, per dimension. */
    private static Map<String, Map<String, String>> labelCache;
    /** The vendor picklist's own order, per dimension, read by describe. */
    private static Map<String, List<String>> orderCache = new Map<String, List<String>>();

    @TestVisible
    private static List<AAO_Map_Value__mdt> stubbed;

    private static void load() {
        if (rankCache != null) {
            return;
        }
        rankCache = new Map<String, Map<String, Integer>>();
        labelCache = new Map<String, Map<String, String>>();
        List<AAO_Map_Value__mdt> rows = stubbed != null
            ? stubbed
            : [
                  SELECT AAO_Dimension__c, AAO_Stored_Value__c, AAO_Rank__c,
                      AAO_Displayed_Label__c
                  FROM AAO_Map_Value__mdt
              ];
        for (AAO_Map_Value__mdt r : rows) {
            String dim = r.AAO_Dimension__c == null ? '' : r.AAO_Dimension__c.toLowerCase();
            if (!rankCache.containsKey(dim)) {
                rankCache.put(dim, new Map<String, Integer>());
                labelCache.put(dim, new Map<String, String>());
            }
            if (r.AAO_Rank__c != null) {
                rankCache.get(dim).put(r.AAO_Stored_Value__c, Integer.valueOf(r.AAO_Rank__c));
            }
            labelCache.get(dim).put(
                r.AAO_Stored_Value__c,
                String.isBlank(r.AAO_Displayed_Label__c)
                    ? r.AAO_Stored_Value__c
                    : r.AAO_Displayed_Label__c
            );
        }
    }

    @TestVisible
    private static void reset() {
        rankCache = null;
        labelCache = null;
        orderCache = new Map<String, List<String>>();
    }

    /** This value's rank, or null where the seed does not rank it. Null is not an error. */
    public static Integer rankOf(String dimension, String storedValue) {
        load();
        Map<String, Integer> byValue = rankCache.get(
            dimension == null ? '' : dimension.toLowerCase()
        );
        return byValue == null ? null : byValue.get(storedValue);
    }

    /** What this org's map displays for a stored value. The stored value where it says nothing. */
    public static String labelOf(String dimension, String storedValue) {
        load();
        Map<String, String> byValue = labelCache.get(
            dimension == null ? '' : dimension.toLowerCase()
        );
        String label = byValue == null ? null : byValue.get(storedValue);
        return label == null ? storedValue : label;
    }

    /**
     * THE PROCEDURE. The value to write for one dimension, given everything established.
     *
     * Returns null ONLY for an empty set, which is the ruling's one unwritten path. Every other
     * input yields a value, including a set of values this seed has never heard of.
     */
    public static String decide(String dimension, Set<String> established) {
        if (established == null || established.isEmpty()) {
            // The only blank. Nothing was established, so nothing is asserted, and the refusal
            // note stays. Silence is still the law where there is no evidence.
            return null;
        }
        if (established.size() == 1) {
            // WRITE IT. No hold, no note-instead-of-value, no exception — including where the
            // seed does not rank it, because one established value has nothing to lose a
            // comparison to.
            return new List<String>(established)[0];
        }

        String best;
        Integer bestRank;
        for (String value : sorted(established)) {
            Integer rank = rankOf(dimension, value);
            if (rank == null) {
                continue;
            }
            if (bestRank == null || rank > bestRank) {
                bestRank = rank;
                best = value;
            }
        }
        if (best != null) {
            // An unranked value sorts BELOW every ranked one, so any ranked value present wins.
            return best;
        }

        // ONLY UNRANKED VALUES. The vendor's own picklist order decides, because it is the only
        // order that exists and it is the customer's rather than ours. Anything the picklist
        // does not carry falls to alphabetical, which is arbitrary and said to be arbitrary
        // rather than dressed up: what it must not do is return null.
        for (String candidate : picklistOrder(dimension)) {
            if (established.contains(candidate)) {
                return candidate;
            }
        }
        return sorted(established)[0];
    }

    /** Everything the decision did not write, in a stable order, for the note to carry. */
    public static List<String> outranked(String dimension, Set<String> established) {
        List<String> out = new List<String>();
        String chosen = decide(dimension, established);
        if (chosen == null) {
            return out;
        }
        for (String value : sorted(established)) {
            if (value != chosen) {
                out.add(value);
            }
        }
        return out;
    }

    /**
     * The vendor picklist's stored values, in the order the vendor declares them.
     *
     * By describe rather than by configuration: a customer's picklist order is a fact about
     * their org, and reading it is the only way to know it that cannot drift from what they see.
     * A dimension with no field mapped returns empty, which the caller handles.
     */
    @TestVisible
    private static List<String> picklistOrder(String dimension) {
        String dim = dimension == null ? '' : dimension.toLowerCase();
        if (orderCache.containsKey(dim)) {
            return orderCache.get(dim);
        }
        List<String> out = new List<String>();
        Schema.SObjectField f = fieldFor(dim);
        if (f != null) {
            for (Schema.PicklistEntry e : f.getDescribe().getPicklistValues()) {
                out.add(e.getValue());
            }
        }
        orderCache.put(dim, out);
        return out;
    }

    /** The vendor field each ranked dimension writes. The one place a dimension meets a field. */
    private static Schema.SObjectField fieldFor(String dimension) {
        if (dimension == AAO_P8Codes.DIM_BUYER_ROLE) {
            return ALTF__Contact_Map_Details__c.ALTF__Buyer_Role__c;
        }
        if (dimension == AAO_P8Codes.DIM_POLITICAL) {
            return ALTF__Contact_Map_Details__c.ALTF__Political__c;
        }
        return null;
    }

    private static List<String> sorted(Set<String> values) {
        List<String> out = new List<String>(values);
        out.sort();
        return out;
    }
}
