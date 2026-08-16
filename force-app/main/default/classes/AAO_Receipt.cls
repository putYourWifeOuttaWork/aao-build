/**
 * THE RUN RECEIPT'S WRITER. One row per Source per pass, merged a stage at a time.
 *
 * Confirmed at the twenty-ninth stamp and built at the sixty-seventh, and its authorising bytes are
 * that stamp's own: *"per-stage wall milliseconds (call 0, read A, read B, resolution model and
 * SOQL/DML separately, call 3 batches, join, projection), calls made, split events, cold or warm,
 * charter and normalizer versions"*, doing two jobs nothing else can — the did-we-read-it record,
 * and the permanent telemetry home.
 *
 * **TELEMETRY, NEVER EVIDENCE, and the distinction is load-bearing rather than decorative.**
 * Nothing in the pipeline reads a receipt to decide anything. So a receipt that cannot be written
 * must never be the reason a pass dies: every entry point here swallows its own failures and says
 * so in the debug log, because losing a timing is a small loss and losing a run that made seven
 * model calls is not. That asymmetry is the whole of this class's error policy.
 *
 * **EVERY NUMBER IS READ IN THE SAME TRANSACTION AS THE WORK IT DESCRIBES.** `AAO_RunExport`'s
 * governor helper already carries the reason in its own comment: a limit reading taken from another
 * transaction is a reading of nothing. So `record` reads `Limits` on its FIRST line, before its own
 * query and its own DML, and what it stores is the stage's consumption rather than its own.
 *
 * **THE PASS IS SEVERAL TRANSACTIONS, so the receipt merges rather than replaces.** Each stage
 * upserts on `AAO_Receipt_Key__c` (run key plus Source id), appending its leg to the array and
 * moving the roll-ups. A stage that never ran leaves no leg, which is how a pass that stopped early
 * is visible without anybody having to reconstruct it.
 */
public with sharing class AAO_Receipt {
    /**
     * One stage's leg. Serialised into `AAO_Stages__c` rather than given its own object, because
     * the twenty-ninth stamp made object count an adoption cost and a child object per stage would
     * multiply row volume by the number of stages for data nothing joins on.
     */
    public class Leg {
        public String stage;
        public Long wallMs;
        public Integer callouts;
        public Long worstCalloutMs;
        public Integer soql;
        public Integer soqlLimit;
        public Integer dml;
        public Integer dmlLimit;
        public Integer dmlRows;
        public Integer cpuMs;
        public Integer cpuLimit;
        public Integer heap;
        public Integer heapLimit;
        /** COLD, WARM, or n/a where the stage made no model call at all. */
        public String cache;
        public Integer splits;
        /** What the stage produced, where it has a number worth carrying. */
        public Integer produced;
        public String charters;
        public Datetime at;
        /**
         * **WHAT WENT WRONG, where something did.** Null on every healthy leg.
         *
         * A stage that throws leaves NO leg at all, which is correct for a receipt that says
         * what happened rather than what was attempted - but it makes a failed pass and an
         * unfinished pass identical to any reader, and that is exactly the shape that let a
         * `LimitException` read as quiet on 16 August. A driver that catches its own stage
         * failure records it here so a surface can draw a stopped pass as STOPPED.
         *
         * It costs no schema: legs serialise into `AAO_Stages__c`, so a new field on this class
         * is a new key in a JSON blob, nothing to deploy and nothing to grant.
         */
        public String error;
    }

    /**
     * Off switch for the harness, never for production. A suite that wrote a receipt on every
     * pipeline test would leave telemetry rows a report could mistake for real passes; the
     * synthetic mark covers that, and this covers the tests that assert on DML counts.
     */
    @TestVisible
    public static Boolean ENABLED = true;

    /** Stage names, fixed here so the receipt and a run report use one vocabulary. */
    public static final String STAGE_RESOLVE = 'call 0 resolve';
    public static final String STAGE_LOCATE = 'call 1 locate';
    public static final String STAGE_IDENTIFY = 'resolution';
    /**
     * **THE MODEL LEG'S OWN STAGE, added 16 August, because it made a callout and journalled
     * nothing.** `STAGE_IDENTIFY` covers the deterministic resolution stage; the model leg on
     * the remainder is a SECOND callout in a SEPARATE transaction (`AAO_Resolve.requests`
     * enforces that boundary itself), so folding it into the same stage would merge two
     * callouts into one line and lose the one that costs money.
     *
     * It is its own stage rather than a merged leg for a product reason as well: the
     * hundred-fourth stamp's demo visualizes the pipeline by polling this object, and **a
     * surface cannot draw a callout the receipt never journals.** The gap was named as debt at
     * the eighty-first stamp and closes here.
     */
    public static final String STAGE_IDENTIFY_MODEL = 'resolution model leg';
    public static final String STAGE_VERIFY = 'call 3 verify';
    public static final String STAGE_JOIN = 'join';
    public static final String STAGE_PROJECT = 'projection';
    public static final String STAGE_CARDS = 'cards';

    /**
     * Record one stage against this pass's receipt, creating the receipt if this is its first.
     *
     * Returns the row for a caller that wants it and null on any failure, INCLUDING a failure that
     * would otherwise have thrown. Callers are not expected to check.
     */
    /**
     * A STAGE THAT FAILED, journalled as a leg carrying its reason.
     *
     * Deliberately separate from `record`: a failure has no limits worth reporting, and
     * conflating the two would let a healthy-looking leg carry an error nobody reads. Swallows
     * its own failure for the standing reason telemetry always does - a driver that dies trying
     * to report a death is worse than one that dies quietly.
     */
    public static void recordFailure(String runKey, Id sourceId, String stage, String message) {
        if (!ENABLED) {
            return;
        }
        try {
            // EVERY NUMERIC IS ZERO-FILLED, and this is not defensive padding.
            //
            // The first draft set only `stage`, `at`, `wallMs` and `error`, and `mergeLeg`
            // dereferenced the nulls while moving its roll-ups: the failure reporter threw,
            // its own swallow ate the throw, and a stage that died left NO trace at all. **The
            // reporter failed in exactly the way it exists to prevent**, and it was found by
            // probing whether the leg landed rather than by trusting that it had.
            Leg leg = new Leg();
            leg.stage = stage;
            leg.at = System.now();
            leg.wallMs = 0;
            leg.callouts = 0;
            leg.worstCalloutMs = 0;
            leg.splits = 0;
            leg.produced = 0;
            leg.soql = Limits.getQueries();
            leg.soqlLimit = Limits.getLimitQueries();
            leg.dml = Limits.getDmlStatements();
            leg.dmlLimit = Limits.getLimitDmlStatements();
            leg.dmlRows = Limits.getDmlRows();
            leg.cpuMs = Limits.getCpuTime();
            leg.cpuLimit = Limits.getLimitCpuTime();
            leg.heap = Limits.getHeapSize();
            leg.heapLimit = Limits.getLimitHeapSize();
            leg.error = message == null ? 'unknown' : message.abbreviate(500);
            mergeLeg(runKey, sourceId, leg);
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Failure leg not journalled: ' + e.getMessage());
        }
    }

    public static AAO_Run_Receipt__c record(
        String runKey,
        Id sourceId,
        String stage,
        List<AAO_Extract.StageResult> calls,
        Integer produced,
        Integer splits
    ) {
        // LIMITS FIRST, BEFORE THIS CLASS SPENDS ANY OF ITS OWN. Everything below this line is
        // the receipt's own cost and must not appear in the stage's numbers.
        Leg leg = new Leg();
        leg.soql = Limits.getQueries();
        leg.soqlLimit = Limits.getLimitQueries();
        leg.dml = Limits.getDmlStatements();
        leg.dmlLimit = Limits.getLimitDmlStatements();
        leg.dmlRows = Limits.getDmlRows();
        leg.cpuMs = Limits.getCpuTime();
        leg.cpuLimit = Limits.getLimitCpuTime();
        leg.heap = Limits.getHeapSize();
        leg.heapLimit = Limits.getLimitHeapSize();

        if (!ENABLED || String.isBlank(runKey) || sourceId == null || String.isBlank(stage)) {
            return null;
        }

        try {
            leg.stage = stage;
            leg.at = Datetime.now();
            leg.splits = splits == null ? 0 : splits;
            leg.produced = produced;
            summarise(leg, calls);
            return mergeLeg(runKey, sourceId, leg);
        } catch (Exception e) {
            // A LOST TIMING IS A SMALL LOSS; A LOST RUN IS NOT. Loud in the log, silent to the
            // caller, and deliberately never rethrown.
            System.debug(
                LoggingLevel.WARN,
                'Run receipt not written for ' + runKey + '/' + stage + ': ' + e.getMessage()
            );
            return null;
        }
    }

    /** The common case: a stage with one model call and nothing to count. */
    public static AAO_Run_Receipt__c record(
        String runKey, Id sourceId, String stage, AAO_Extract.StageResult call
    ) {
        return record(
            runKey,
            sourceId,
            stage,
            call == null
                ? new List<AAO_Extract.StageResult>()
                : new List<AAO_Extract.StageResult>{ call },
            null,
            0
        );
    }

    /** A code-only stage: the join, the projection, the card writer. No calls, still measured. */
    public static AAO_Run_Receipt__c record(
        String runKey, Id sourceId, String stage, Long wallMs, Integer produced
    ) {
        AAO_Run_Receipt__c row = record(
            runKey, sourceId, stage, new List<AAO_Extract.StageResult>(), produced, 0
        );
        if (row != null && wallMs != null) {
            patchWall(row, stage, wallMs);
        }
        return row;
    }

    /**
     * The Source this run read, found from its own pairs.
     *
     * The later stages are keyed on the run rather than on the artifact — the join and the
     * verifier take a run key and nothing else — so rather than widen four signatures to carry a
     * Source they already have downstream, the receipt finds it the same way anything else on the
     * run would. Returns null on a run with no pairs, which correctly writes no leg: a stage that
     * had nothing to work on has no artifact to attribute its time to.
     */
    public static Id sourceForRun(String runKey) {
        if (String.isBlank(runKey)) {
            return null;
        }
        for (AAO_Pair__c p : [
            SELECT AAO_Source__c FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Source__c != null
            LIMIT 1
        ]) {
            return p.AAO_Source__c;
        }
        return null;
    }

    // ------------------------------------------------------------------------ the reads

    /** This pass's receipt, or null where the pass predates the object or never wrote one. */
    public static AAO_Run_Receipt__c forRun(Id opportunityId, String runKey) {
        if (opportunityId == null || String.isBlank(runKey)) {
            return null;
        }
        List<AAO_Run_Receipt__c> found = [
            SELECT Id, AAO_Run_Key__c, AAO_Stages__c, AAO_Stage_Count__c, AAO_Total_Wall_Ms__c,
                AAO_Worst_Callout_Ms__c, AAO_Callouts__c, AAO_Cache_State__c,
                AAO_Split_Events__c, AAO_Charter_Versions__c, AAO_Normalizer_Version__c,
                AAO_First_Stage_At__c, AAO_Last_Stage_At__c
            FROM AAO_Run_Receipt__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Run_Key__c = :runKey
            ORDER BY AAO_Last_Stage_At__c DESC NULLS LAST
            LIMIT 1
        ];
        return found.isEmpty() ? null : found[0];
    }

    /** The legs back out, in the order they were recorded. Empty where nothing was journalled. */
    public static List<Leg> legsOf(AAO_Run_Receipt__c row) {
        if (row == null || String.isBlank(row.AAO_Stages__c)) {
            return new List<Leg>();
        }
        try {
            return (List<Leg>) JSON.deserialize(row.AAO_Stages__c, List<Leg>.class);
        } catch (Exception e) {
            return new List<Leg>();
        }
    }

    // ------------------------------------------------------------------------ internals

    /**
     * Fold the stage's model calls into the leg.
     *
     * COLD versus WARM is derived from cache-read tokens rather than declared by the caller,
     * because a caller declaring it is a caller who can be wrong about it. A stage with no calls
     * reports `n/a` rather than COLD, since a code-only stage has no cache to be cold.
     */
    private static void summarise(Leg leg, List<AAO_Extract.StageResult> calls) {
        leg.callouts = 0;
        leg.wallMs = 0;
        leg.worstCalloutMs = 0;
        if (calls == null || calls.isEmpty()) {
            leg.cache = 'n/a';
            return;
        }
        Boolean warm = false;
        Set<String> charters = new Set<String>();
        for (AAO_Extract.StageResult c : calls) {
            if (c == null) {
                continue;
            }
            leg.callouts++;
            if (c.elapsedMs != null) {
                leg.wallMs += c.elapsedMs;
                if (c.elapsedMs > leg.worstCalloutMs) {
                    leg.worstCalloutMs = c.elapsedMs;
                }
            }
            if (c.usage != null && c.usage.cacheReadTokens != null && c.usage.cacheReadTokens > 0) {
                warm = true;
            }
            if (String.isNotBlank(c.charter)) {
                charters.add(c.charter + '@' + c.charterVersion);
            }
        }
        leg.cache = leg.callouts == 0 ? 'n/a' : (warm ? 'WARM' : 'COLD');
        List<String> sorted = new List<String>(charters);
        sorted.sort();
        leg.charters = String.join(sorted, ', ');
    }

    /** Append this leg and move the roll-ups. One query, one upsert, whatever the stage did. */
    private static AAO_Run_Receipt__c mergeLeg(String runKey, Id sourceId, Leg leg) {
        String key = runKey + '|' + sourceId;
        List<AAO_Run_Receipt__c> found = [
            // THE KEY ITSELF IS SELECTED, and leaving it out was a real defect for one build.
            // An upsert on an external id needs that field POPULATED on the sObject, so a row
            // read without it threw on the way back out — and this class's own swallow-and-log
            // policy then hid the throw, so the second stage of every pass silently replaced
            // the first instead of merging into it. The tests caught it by asserting the row's
            // contents rather than the call's return, which is the only thing that could have.
            SELECT Id, AAO_Receipt_Key__c, AAO_Stages__c, AAO_Stage_Count__c,
                AAO_Total_Wall_Ms__c, AAO_Worst_Callout_Ms__c, AAO_Callouts__c,
                AAO_Cache_State__c, AAO_Split_Events__c, AAO_Charter_Versions__c,
                AAO_First_Stage_At__c
            FROM AAO_Run_Receipt__c
            WHERE AAO_Receipt_Key__c = :key
            LIMIT 1
        ];
        AAO_Run_Receipt__c row = found.isEmpty() ? newRow(runKey, sourceId, key) : found[0];

        List<Leg> legs = legsOf(row);
        legs.add(leg);
        String encoded = JSON.serialize(legs);
        if (encoded.length() > 32000) {
            // The bound is the field's, and a receipt that silently stopped recording would be
            // worse than one that says it ran out of room.
            legs = new List<Leg>{ leg };
            legs[0].stage = leg.stage + ' (earlier legs dropped: the stage array filled)';
            encoded = JSON.serialize(legs);
        }
        row.AAO_Stages__c = encoded;
        row.AAO_Stage_Count__c = legs.size();
        row.AAO_Total_Wall_Ms__c = nz(row.AAO_Total_Wall_Ms__c) + leg.wallMs;
        row.AAO_Callouts__c = nz(row.AAO_Callouts__c) + leg.callouts;
        row.AAO_Split_Events__c = nz(row.AAO_Split_Events__c) + leg.splits;
        if (leg.worstCalloutMs > nz(row.AAO_Worst_Callout_Ms__c)) {
            row.AAO_Worst_Callout_Ms__c = leg.worstCalloutMs;
        }
        // WARM ANYWHERE MAKES THE PASS WARM. The twenty-eighth stamp's rule is that a warm rerun
        // is never reported as cold performance, so the honest roll-up takes the weaker claim.
        if (leg.cache == 'WARM') {
            row.AAO_Cache_State__c = 'WARM';
        } else if (String.isBlank(row.AAO_Cache_State__c) && leg.cache == 'COLD') {
            row.AAO_Cache_State__c = 'COLD';
        }
        if (String.isNotBlank(leg.charters)) {
            Set<String> all = new Set<String>();
            if (String.isNotBlank(row.AAO_Charter_Versions__c)) {
                all.addAll(row.AAO_Charter_Versions__c.split('\n'));
            }
            all.addAll(leg.charters.split(', '));
            List<String> sorted = new List<String>(all);
            sorted.sort();
            row.AAO_Charter_Versions__c = String.join(sorted, '\n').left(4000);
        }
        if (row.AAO_First_Stage_At__c == null) {
            row.AAO_First_Stage_At__c = leg.at;
        }
        row.AAO_Last_Stage_At__c = leg.at;

        upsert row AAO_Run_Receipt__c.AAO_Receipt_Key__c;
        return row;
    }

    private static AAO_Run_Receipt__c newRow(String runKey, Id sourceId, String key) {
        AAO_Source__c src = null;
        for (AAO_Source__c s : [
            SELECT Id, AAO_Opportunity__c, AAO_Normalizer_Version__c
            FROM AAO_Source__c
            WHERE Id = :sourceId
            LIMIT 1
        ]) {
            src = s;
        }
        return new AAO_Run_Receipt__c(
            AAO_Receipt_Key__c = key,
            AAO_Run_Key__c = runKey,
            AAO_Source__c = sourceId,
            AAO_Opportunity__c = src == null ? null : src.AAO_Opportunity__c,
            AAO_Normalizer_Version__c = src == null ? null : src.AAO_Normalizer_Version__c,
            AAO_Synthetic__c = AAO_Synthetic.MARK
        );
    }

    /**
     * A code-only stage measures its own wall clock, since there is no callout to read it off.
     * Written after the merge so the leg's own governor numbers stay the stage's rather than this
     * method's, and kept separate from `wallMs` accumulation so a caller cannot double-count.
     */
    private static void patchWall(AAO_Run_Receipt__c row, String stage, Long wallMs) {
        try {
            List<Leg> legs = legsOf(row);
            if (legs.isEmpty()) {
                return;
            }
            Leg last = legs[legs.size() - 1];
            if (last.stage != stage) {
                return;
            }
            last.wallMs = wallMs;
            row.AAO_Stages__c = JSON.serialize(legs);
            row.AAO_Total_Wall_Ms__c = nz(row.AAO_Total_Wall_Ms__c) + wallMs;
            update row;
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Receipt wall not patched: ' + e.getMessage());
        }
    }

    private static Long nz(Decimal d) {
        return d == null ? 0 : d.longValue();
    }
}