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
        try {
            Set<String> internalDomains = internalDomains();
            for (Id sourceId : sourceIds) {
                try {
                    AAO_Pipeline.Outcome o = AAO_Pipeline.runForSource(sourceId, internalDomains);
                    System.debug(LoggingLevel.INFO, 'AAO_INGEST ' + o);
                } catch (Exception e) {
                    // Deliberately swallowed per Source. The artifact is already stored and
                    // immutable; losing the adjudication is recoverable by running the
                    // pipeline again, losing the transaction would not be.
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
