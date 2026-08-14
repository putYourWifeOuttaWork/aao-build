/**
 * THE INVOKER, AND IT IS CONDEMNED IN ITS OWN NAME.
 *
 * `TEMP` is in the class name deliberately, the same way `AAO_TEMP_` was promised in
 * BUILD_JOURNAL session 71, so that this cannot quietly become architecture. It exists to get
 * the §P7.3 pass run end to end and measured. **The shipping invoker is the ruled batch layer,
 * which does not exist yet.** Anything this class decides about scheduling, retry, or
 * observability is a stand-in and none of it is design.
 *
 * WHY BATCH AND NOT A QUEUEABLE CHAIN. Both give one callout per transaction. Only Batch
 * answers the question that is still unmeasured: **chained-Queueable stack depth in `aossb2`
 * is capped at 5 in Developer Edition and Trial orgs, and whether that cap binds a Developer
 * sandbox of an Enterprise org was never measured** (measurement 2, owed since session 71).
 * A B&V pass is about six transactions and an Emerson pass is more, so a chain would be
 * running straight at an unmeasured cap. Batch with scope size 1 has no depth question at all:
 * per-transaction limits reset per execute, which is the property the whole pass shape needs.
 * **This is not a claim that the Queueable cap does not bind — it is a decision not to depend
 * on the answer.** The measurement is still owed and still design's to want.
 *
 * HOW IT WORKS, and the one ugly part, stated rather than hidden. Batch decides its work at
 * `start()`, and this pass does not know how many callouts it needs until stage 1 has run. So
 * the iterable is a list of SLOTS — an upper bound on transactions — and a slot whose work is
 * already done is a no-op that returns immediately. **A no-op execute is a real transaction
 * with a real cost**, which is why the bound is computed from the declared set rather than set
 * to a comfortable large number.
 */
public class AAO_EBV_TEMP_Batch implements Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful {
    public class BatchException extends Exception {
    }

    /** The pass state, carried across executes. Stateful is what makes that legal. */
    public AAO_EBV.State state;
    public Set<String> internalDomains;
    private Integer slots;

    public AAO_EBV_TEMP_Batch(
        Id sourceId,
        Set<String> charters,
        Set<String> internalDomains,
        Integer slots
    ) {
        this.state = AAO_EBV.begin(sourceId, charters);
        this.internalDomains = internalDomains == null ? new Set<String>() : internalDomains;
        // One for the read, one for stage 4, and the rest for the two grouped stages. The
        // caller computes it because the caller knows the declared set size; a default here
        // would be the guess this class is trying not to make.
        //
        // ONE SLOT IS LEGAL, and it is not a degenerate case to guard against: Apex refuses
        // more than one `executeBatch` per test method and requires the iterable to match the
        // batch size, so a test of this class can only ever drive a single execute. The floor
        // used to be three, which made the class untestable while looking careful.
        this.slots = slots == null || slots < 1 ? 12 : slots;
    }

    public Iterable<Object> start(Database.BatchableContext ctx) {
        List<Object> out = new List<Object>();
        for (Integer i = 0; i < slots; i++) {
            out.add((Object) String.valueOf(i));
        }
        return out;
    }

    /**
     * One slot, one transaction, at most one callout.
     *
     * An exception here is caught and recorded rather than thrown, because a batch that dies
     * mid-pass loses the telemetry of every stage that already succeeded — and the telemetry
     * is what the run is for. The pass stops advancing and `finish` reports where it stopped.
     */
    public void execute(Database.BatchableContext ctx, List<Object> scope) {
        if (AAO_EBV.finished(state)) {
            return;
        }
        try {
            state = AAO_EBV.advance(state, internalDomains);
        } catch (Exception e) {
            state.drops.add(
                'FAILED at stage ' + state.stage + ': ' +
                e.getTypeName() + ' ' + e.getMessage()
            );
            state.stage = 'failed';
        }
    }

    /**
     * The report goes to the debug log, which is where every measurement in BUILD_JOURNAL has
     * come from. **That is the stand-in part**: a shipping invoker records a run as queryable
     * rows, and the open design question about whether a void pass can be marked void in the
     * org is the same question wearing different clothes.
     */
    public void finish(Database.BatchableContext ctx) {
        System.debug(LoggingLevel.ERROR, AAO_EBV.report(state));
        if (state.stage != 'done') {
            System.debug(
                LoggingLevel.ERROR,
                'EBV DID NOT COMPLETE. Stopped at stage ' + state.stage + ' after ' +
                slots + ' slots. Nothing here is a baseline.'
            );
        }
    }

    /**
     * The one-line entry, with the slot bound derived rather than picked.
     *
     * The bound is deliberately generous on the grouped stages and honest about why: bindings
     * per pass is not knowable before the read, so the worst case is every declared contract
     * binding at least once.
     */
    public static Id run(Id sourceId, Set<String> charters, Set<String> internalDomains) {
        AAO_Source__c src = [
            SELECT Id, AAO_Opportunity__c, AAO_Account__c, AAO_Synthetic__c
            FROM AAO_Source__c
            WHERE Id = :sourceId
        ];
        AAO_ApplicableSet.Resolved resolved = AAO_ApplicableSet.resolve(charters, src);
        AAO_Extract.Config cfg = AAO_Extract.config();
        Integer declared = resolved.contracts.size();
        Integer bindSlots = cfg.bindGroupSize == null
            ? 1
            : (Integer) Math.ceil(Decimal.valueOf(declared) / cfg.bindGroupSize) + 1;
        Integer verifySlots = cfg.verifyGroupSize == null
            ? 1
            : (Integer) Math.ceil(Decimal.valueOf(declared) / cfg.verifyGroupSize) + 1;
        Integer slots = 1 + bindSlots + verifySlots + 1;

        return Database.executeBatch(
            new AAO_EBV_TEMP_Batch(sourceId, charters, internalDomains, slots),
            1
        );
    }
}