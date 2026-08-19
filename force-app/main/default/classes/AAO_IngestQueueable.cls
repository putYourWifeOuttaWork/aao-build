/**
 * Runs the pipeline for Sources that have just landed.
 *
 * One Source per pipeline call, and a failure on one must not take down the others: the
 * whole point of adjudicating asynchronously is that the evidence is already safe. A
 * source that throws is recorded on its own candidate row by the pipeline where it can be,
 * and logged here where it cannot.
 *
 * It does not chain. AAO_Ingest.RUNNING is set for the duration, so a Source inserted
 * downstream of a commit cannot enqueue another job and start a loop.
 */
public class AAO_IngestQueueable implements Queueable {
    private final List<Id> sourceIds;
    private final Boolean mark;

    public AAO_IngestQueueable(List<Id> sourceIds, Boolean mark) {
        this.sourceIds = sourceIds;
        this.mark = mark;
    }

    public void execute(QueueableContext ctx) {
        AAO_Ingest.RUNNING = true;
        Boolean priorMark = AAO_Synthetic.MARK;
        AAO_Synthetic.MARK = this.mark;
        // R3's cover for this queueable too. The per-Source catch below reaches everything a
        // catch can reach; a governor `LimitException` kills the loop outright and reaches none
        // of it, and a batch that dies that way would leave no trace of having been attempted.
        // Filed against the FIRST Source of the batch, which is honest rather than exact: the
        // dead transaction cannot say which Source it was on, and inventing one would be worse
        // than naming the batch it belonged to.
        System.attachFinalizer(
            new AAO_RunFinalizer(
                ingestRunKey(sourceIds.isEmpty() ? null : sourceIds[0]),
                sourceIds.isEmpty() ? null : sourceIds[0],
                AAO_Receipt.STAGE_INGEST
            )
        );
        Map<Id, String> failures = new Map<Id, String>();
        try {
            Set<String> internalDomains = internalDomains();
            for (Id sourceId : sourceIds) {
                try {
                    AAO_Pipeline.Outcome o = AAO_Pipeline.runForSource(sourceId, internalDomains);
                    System.debug(LoggingLevel.INFO, 'AAO_INGEST ' + o);
                } catch (Exception e) {
                    // Still swallowed per Source, and for the reason it always was: the artifact
                    // is already stored and immutable, losing one adjudication is recoverable by
                    // running the pipeline again, and losing the transaction would take the
                    // other Sources with it.
                    //
                    // **WHAT CHANGES IS THAT IT NO LONGER VANISHES.** R4, ordered at the
                    // hundred-tenth stamp: record, never rethrow, and failed Sources become
                    // queryable rows. A debug line is visible for as long as somebody is
                    // watching a log, which on the async path is never.
                    failures.put(
                        sourceId,
                        e.getTypeName() + ': ' + e.getMessage()
                    );
                    System.debug(
                        LoggingLevel.ERROR,
                        'AAO_INGEST FAILED source=' +
                        sourceId +
                        ' ' +
                        e.getTypeName() +
                        ': ' +
                        e.getMessage() +
                        '\n' +
                        e.getStackTraceString()
                    );
                }
            }
        } finally {
            AAO_Synthetic.MARK = priorMark;
            AAO_Ingest.RUNNING = false;
        }

        // ===== WRITTEN AFTER THE LOOP, AND THAT ORDERING IS LOAD BEARING.
        //
        // `AAO_Pipeline` documents its own callout-before-DML ordering as load bearing, and a
        // receipt leg is DML. Writing one inside the catch would put DML in front of the NEXT
        // Source's callouts and turn one Source's failure into every later Source's failure -
        // the reporter breaking the thing it reports on, which this project has already paid
        // for once at the failure leg and once at the join.
        for (Id failed : failures.keySet()) {
            AAO_Receipt.recordFailure(
                ingestRunKey(failed),
                failed,
                AAO_Receipt.STAGE_INGEST,
                failures.get(failed)
            );
        }
    }

    /**
     * Ingest has no run key of the pass's shape, so the Source is the run. One row per Source,
     * merged across attempts, which is what makes a repeated failure legible as repeated.
     */
    @TestVisible
    private static String ingestRunKey(Id sourceId) {
        return 'ingest|' + sourceId;
    }

    /**
     * Public since v1.1: the participant writer needs the same answer this does, and two
     * derivations of which side someone is on is one too many.
     */
    public static Set<String> internalDomains() {
        Set<String> out = new Set<String>();
        Map<String, Object> fixture = AAO_Seed.fixture();
        for (Object d : (List<Object>) fixture.get('internalDomains')) {
            out.add(((String) d).toLowerCase());
        }
        return out;
    }
}