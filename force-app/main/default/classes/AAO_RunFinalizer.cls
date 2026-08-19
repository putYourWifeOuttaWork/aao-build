/**
 * THE COVER FOR THE DEATH NO CATCH CAN SEE · R3, ordered urgent by the hundred-thirteenth stamp
 * and led the standing phase from the hundred-fifteenth.
 *
 * A Finalizer runs in ITS OWN TRANSACTION after the queueable it is attached to, whether that
 * queueable returned or died. That is the whole reason it exists here, and it closes exactly one
 * class the failure leg cannot:
 *
 *   - `AAO_PassQueueable` catches `Exception` and journals a failure leg. That covers a
 *     `CalloutException`, a `DmlException`, a charter refusal - everything a catch can reach.
 *   - **It cannot reach a governor `LimitException`.** The platform does not let it. The
 *     transaction is killed outright, the catch never runs, and the receipt is left with a stage
 *     that simply stops - which is byte-for-byte the shape that let `Too many SOQL queries: 101`
 *     read as quiet on 16 August while 39 upheld pairs produced no claims.
 *
 * So a leg that never lands and a leg that lands saying it failed are the same fact wearing
 * opposite faces, and only this closes the difference. **The receipt law holding at the one
 * moment it cannot today**, in the hundred-tenth stamp's own words.
 *
 * NOTHING HERE IS TELEMETRY-OPTIONAL IN THE USUAL SENSE, and one thing is. It swallows its own
 * failure like every other write on the receipt path, for the standing reason: a reporter that
 * dies reporting a death is worse than one that dies quietly. But a finalizer is the LAST
 * transaction a dead run gets, so anything it does not do here is not done anywhere - which is
 * why the lease release lives here too rather than in the queueable that may not survive to run
 * it.
 */
public class AAO_RunFinalizer implements Finalizer {
    private final String runKey;
    private final Id sourceId;
    /**
     * The RECEIPT'S name for the stage, never the driver's. A failure filed under a name no
     * reader knows is a failure nobody can place - the hundred-fifth stamp's lesson, and the
     * same reason `AAO_PassQueueable.receiptNameOf` exists.
     */
    private final String receiptStage;
    /** Null where the caller holds no lease; set where it does, and then this releases it. */
    private final Id leaseOpportunityId;

    public AAO_RunFinalizer(String runKey, Id sourceId, String receiptStage) {
        this(runKey, sourceId, receiptStage, null);
    }

    public AAO_RunFinalizer(
        String runKey,
        Id sourceId,
        String receiptStage,
        Id leaseOpportunityId
    ) {
        this.runKey = runKey;
        this.sourceId = sourceId;
        this.receiptStage = receiptStage;
        this.leaseOpportunityId = leaseOpportunityId;
    }

    public void execute(FinalizerContext ctx) {
        // A null context is not a case the platform produces; it is a case a TEST produces,
        // and guarding it here keeps the guard out of the tests' way rather than out of the
        // platform's.
        Boolean died = ctx != null && ctx.getResult() == ParentJobResult.UNHANDLED_EXCEPTION;

        if (died) {
            try {
                Exception e = ctx.getException();
                String detail = e == null
                    ? 'no exception was carried on the finalizer context'
                    : e.getTypeName() + ': ' + e.getMessage();
                AAO_Receipt.recordFailure(
                    runKey,
                    sourceId,
                    receiptStage,
                    // Said in words on the row, because whoever reads this leg is reading it
                    // precisely because they could not find one anywhere else.
                    'The transaction was killed and could not journal its own failure; this ' +
                    'leg was written afterwards by the run finalizer, so ITS GOVERNOR NUMBERS ' +
                    'ARE THE FINALIZER\'S OWN TRANSACTION AND NOT THE STAGE\'S - they read near ' +
                    'zero on a leg whose stage died of a governor, which is exactly the ' +
                    'misreading this sentence exists to stop. ' + detail
                );
            } catch (Exception ignored) {
                System.debug(
                    LoggingLevel.WARN,
                    'Finalizer could not journal the failure: ' + ignored.getMessage()
                );
            }
        }

        // ===== A DEAD RUN GIVES THE DEAL BACK, and this is the only place that can happen.
        //
        // A run that dies holding the deal's lease WEDGES THE DEAL: nothing else on that
        // opportunity can ever start, and no later pass can clear it because no later pass can
        // start. The hundred-tenth stamp's correction to R5 says exactly this - "released by the
        // R3 finalizer so a dead run cannot wedge the deal" - and it is why R5 could not be built
        // before R3.
        //
        // **ONLY ON DEATH, and the reason is the chain's shape.** The pass crosses one
        // transaction per stage on ONE lease, so a finalizer firing after every stage would hand
        // the deal away mid-pass and let a second run interleave with the first - the exact race
        // the lease exists to stop, introduced by the lease's own release. A stage that returned
        // handles its own lease: it releases when the chain ends or stops, and holds when the
        // chain continues. A transaction that DIED enqueued nothing (the enqueue rolls back with
        // it), so death always means the chain is over.
        if (died && leaseOpportunityId != null) {
            try {
                AAO_RunLease.releaseAndDrain(leaseOpportunityId, runKey);
            } catch (Exception ignored) {
                System.debug(
                    LoggingLevel.WARN,
                    'Finalizer could not release the lease: ' + ignored.getMessage()
                );
            }
        }
    }
}
