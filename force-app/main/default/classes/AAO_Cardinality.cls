/**
 * INVARIANT 9. Every creation path carries an upper bound and abstains and flags past it.
 *
 * THIS WAS OWED AND MISSED, and the miss is worth stating because it was not an oversight of
 * detail. The People handed unit is a person crossed with a dimension, so nine people against
 * six dimensions is fifty-four findings in one pass. That number was written down, the
 * sixteen-thousand-token output ceiling was named beside it, and neither was connected to the
 * law that already governed both.
 *
 * A CEILING THAT IS ONLY DISCUSSED IS NOT A CEILING. Without the guard the run does not
 * refuse at a stated number — it discovers the number by failing against the model's own
 * limit, mid-pass, having already paid for the call. And a truncated response is worse than a
 * refused one: the parse law says a derived fact may never be derivable from a parse failure,
 * and a response cut off at the token ceiling produces exactly that, a findings array missing
 * its tail which the comparator would read as `not_returned` for every unit past the cut.
 * **The guard is what keeps the abstention rate measuring evidence rather than arithmetic.**
 *
 * SO IT ABSTAINS RATHER THAN TRUNCATES. Refusing the whole pass and saying so is honest;
 * running the first forty and silently dropping fourteen would put fourteen fabricated
 * `not_returned` rows in the ledger and leave nobody able to tell them from real ones.
 *
 * General on purpose, like the missing-relation flag. The People pass is what surfaced it,
 * but every path that turns one input into many rows wants this, and the ones that do not
 * exist yet want it most, because they are the ones nobody has counted.
 */
public class AAO_Cardinality {
    public static final String TYPE = 'Cardinality';
    public static final String CAUSE = 'Cardinality_Exceeded';

    /** Named paths, so a flag says which thing refused rather than that something did. */
    public static final String PEOPLE_PASS = 'People pass: person x dimension';
    public static final String EXTRACTION_PASS = 'Extraction pass: propositions';

    /**
     * The bound in force. From Model Config, which is where a person pins limits and where
     * the token ceiling it exists to protect already lives.
     *
     * A null or absent config is NOT treated as unbounded. An unbounded creation path is the
     * exact condition invariant 9 forbids, so a missing bound falls back to a conservative
     * one rather than to infinity: forgetting to configure must never be the same as
     * choosing no limit.
     */
    public static final Integer FALLBACK_CEILING = 50;

    public static Integer ceiling() {
        List<AAO_Model_Config__mdt> rows = [
            SELECT AAO_Max_Findings_Per_Pass__c
            FROM AAO_Model_Config__mdt
            WHERE DeveloperName = 'Default'
            LIMIT 1
        ];
        if (rows.isEmpty() || rows[0].AAO_Max_Findings_Per_Pass__c == null) {
            return FALLBACK_CEILING;
        }
        return (Integer) rows[0].AAO_Max_Findings_Per_Pass__c;
    }

    public class Verdict {
        public Boolean withinBound;
        public Integer proposed;
        public Integer ceiling;
        public String reason;
    }

    public static String key(Id opportunityId, String path) {
        return String.valueOf(opportunityId) + '|' + path;
    }

    /**
     * Ask before creating. PURE — no DML, on purpose and not by accident.
     *
     * `AAO_Pipeline` carries an ordering law in its own comments: everything before the
     * callout is SOQL, because Apex forbids a callout after DML in the same transaction and
     * a single row written above that line fails the model call with an error that reads
     * like a platform problem rather than an ordering one. A guard that wrote a flag on the
     * way past would have broken exactly that, and broken it only on the passes that were
     * WITHIN their bound — the ones nobody would think to test.
     *
     * So the check is split from the writing. This decides; `refuse` writes only when we are
     * abstaining, where no callout follows and DML is safe; `clearIfStanding` runs after the
     * pass, where DML is safe again.
     */
    public static Verdict check(Integer proposed) {
        Integer bound = ceiling();
        Verdict v = new Verdict();
        v.proposed = proposed;
        v.ceiling = bound;
        v.withinBound = proposed <= bound;
        v.reason = v.withinBound
            ? proposed + ' of a permitted ' + bound + '.'
            : 'This pass would create ' +
              proposed +
              ' findings against a bound of ' +
              bound +
              '. It abstained rather than truncating: a response cut off at the ceiling ' +
              'would leave the tail of the ledger reading as never-returned, which is a ' +
              'fact about arithmetic wearing the clothes of a fact about evidence.';
        return v;
    }

    /**
     * Record the refusal. Only ever called on the abstaining branch, so no callout follows
     * it and the ordering law is intact.
     */
    public static void refuse(
        Id opportunityId,
        Id accountId,
        String path,
        Verdict v
    ) {
        raise(opportunityId, accountId, path, v.proposed, v.ceiling, v.reason);
    }

    /**
     * Back under the bound clears it, the same way every other flag clears: its cause is
     * gone. A deal that shed people, or a ceiling deliberately raised, should not carry a
     * red about a pass that would now run. Called AFTER the pass, never before it.
     */
    public static void clearIfStanding(Id opportunityId, String path) {
        clear(opportunityId, path);
    }

    private static void raise(
        Id opportunityId,
        Id accountId,
        String path,
        Integer proposed,
        Integer bound,
        String reason
    ) {
        String k = key(opportunityId, path);
        List<AAO_Flag__c> found = [
            SELECT Id, AAO_State__c, AAO_Proposed_Count__c
            FROM AAO_Flag__c
            WHERE AAO_Bound_Key__c = :k
            LIMIT 1
        ];
        if (found.isEmpty()) {
            insert new AAO_Flag__c(
                AAO_Opportunity__c = opportunityId,
                AAO_Account__c = accountId,
                AAO_Type__c = TYPE,
                AAO_Cause__c = CAUSE,
                AAO_State__c = 'Standing',
                AAO_Bounded_Path__c = path,
                AAO_Bound_Key__c = k,
                AAO_Proposed_Count__c = proposed,
                // FROZEN AT THE TIME. Raising the ceiling later must not silently rewrite
                // why an older run abstained.
                AAO_Ceiling__c = bound,
                AAO_Acknowledgement_Text__c = reason,
                AAO_Raised_At__c = raisedAt(opportunityId)
            );
            return;
        }
        AAO_Flag__c f = found[0];
        f.AAO_Proposed_Count__c = proposed;
        if (f.AAO_State__c == 'Cleared') {
            // The clock does not restart, per the general law: a flag ages from when the
            // question became askable, not from when the answer last turned bad.
            f.AAO_State__c = 'Standing';
            f.AAO_Cleared_At__c = null;
        }
        update f;
    }

    private static void clear(Id opportunityId, String path) {
        String k = key(opportunityId, path);
        List<AAO_Flag__c> found = [
            SELECT Id, AAO_State__c
            FROM AAO_Flag__c
            WHERE AAO_Bound_Key__c = :k AND AAO_State__c != 'Cleared'
            LIMIT 1
        ];
        if (found.isEmpty()) {
            return;
        }
        found[0].AAO_State__c = 'Cleared';
        found[0].AAO_Cleared_At__c = System.now();
        update found[0];
    }

    private static Datetime raisedAt(Id opportunityId) {
        List<Opportunity> o = [
            SELECT CreatedDate FROM Opportunity WHERE Id = :opportunityId LIMIT 1
        ];
        return o.isEmpty() ? System.now() : o[0].CreatedDate;
    }

    public static List<AAO_Flag__c> standing(Id opportunityId) {
        return [
            SELECT
                Id,
                AAO_Bounded_Path__c,
                AAO_Proposed_Count__c,
                AAO_Ceiling__c,
                AAO_Acknowledgement_Text__c
            FROM AAO_Flag__c
            WHERE
                AAO_Opportunity__c = :opportunityId
                AND AAO_Type__c = :TYPE
                AND AAO_State__c != 'Cleared'
        ];
    }
}
