/**
 * The live ingestion path. A Source arriving is the event; everything else follows from it.
 *
 * After-insert on AAO_Source__c, which is ours, so a trigger on it is allowed. Nothing here
 * ever touches an object we do not own — change detection on customer objects stays polling
 * by SystemModstamp against a stored watermark, which is a separate thing and not this.
 *
 * Why after-insert and a Queueable rather than doing the work inline. The pipeline queries
 * a static resource, resolves spans, commits an answer and inserts a claim. Doing that in
 * the same transaction as the insert would put the whole adjudication inside whatever
 * transaction happened to deliver the evidence — a bulk load, an integration user, a future
 * ECI callback — and a governor limit hit there would roll back the *ingestion* and lose the
 * artifact. Async means the artifact lands first and is adjudicated second, which is the
 * right order for something whose whole point is that evidence is durable.
 *
 * AUTO is the switch. AAO_Demo turns it off around its own inserts so the deterministic
 * rehearsal stays synchronous and ordered; the live path leaves it on.
 */
public class AAO_Ingest {
    /** Whether an inserted Source should be adjudicated asynchronously. */
    public static Boolean AUTO = true;

    /** Set by the Queueable so a Source inserted downstream cannot chain another job. */
    public static Boolean RUNNING = false;

    public static void onSourceInserted(List<AAO_Source__c> rows) {
        if (!AUTO || RUNNING) {
            return;
        }
        // Async contexts cannot always enqueue, and a job enqueued from a batch or a future
        // is a different reliability story than one enqueued from a user transaction. Skip
        // rather than throw: a failed enqueue must never roll back the arrival of evidence.
        if (System.isBatch() || System.isFuture() || System.isQueueable()) {
            return;
        }
        if (Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs()) {
            return;
        }

        List<Id> ids = new List<Id>();
        for (AAO_Source__c s : rows) {
            ids.add(s.Id);
        }
        if (ids.isEmpty()) {
            return;
        }
        System.enqueueJob(new AAO_IngestQueueable(ids, AAO_Synthetic.MARK));
    }
}