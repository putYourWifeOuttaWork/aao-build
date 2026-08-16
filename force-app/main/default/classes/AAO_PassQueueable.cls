/**
 * THE PASS DRIVER · one stage per transaction, chained, journalling every step.
 *
 * The hundred-fourth stamp's item 1 and the hundred-sixth's item 4. Until now the pipeline's
 * stages all existed and **nothing drove them**: every graded run in this project was driven by
 * CODE from a shell, one `sf apex run` per stage, and that is why "takes CODE out of the test
 * loop" is listed as a product goal rather than a convenience. This is that driver.
 *
 * **WHY A CHAIN AND NOT A LOOP.** Three separate laws each independently force one stage per
 * transaction, and any one of them alone would be enough:
 *   - **Callout after DML is fatal.** `AAO_Resolve.requests` enforces this at its own call site
 *     rather than trusting a comment, because the eightieth stamp's run had to be rebuilt after
 *     two verify buckets shared a transaction.
 *   - **The 120-second callout ceiling** is per transaction, and call 3 alone has measured 87 s.
 *   - **The governors are per transaction**, which is the whole reason the join splits.
 *
 * **STAGES THAT LOOP DO SO BY RE-ENQUEUEING THEMSELVES**, never by growing: verify runs until no
 * upheld-eligible pair is unverified, and the join runs until `pairsRemaining` reaches zero. That
 * is the ninety-second stamp's split rule stated as code - a stage crossing its wall completes
 * its remaining work in a continuation and never redoes.
 *
 * **EVERY FAILURE IS JOURNALLED, and that is not decoration.** A stage that throws leaves no leg,
 * so a failed pass and an unfinished pass look identical - which is exactly how a
 * `LimitException` read as quiet on 16 August while 39 upheld pairs produced no claims. This
 * catches, records the reason on the receipt, and STOPS the chain. **A demo that cannot show a
 * failure is a demo that lies by omission.**
 *
 * NOTHING HERE CHANGES A STAGE. Every call below is the same method the graded runs used, with
 * the same arguments, so a run driven from the record is the run design has been grading.
 */
public class AAO_PassQueueable implements Queueable, Database.AllowsCallouts {
    // The stages, in the order the pass runs them. Named rather than numbered so a receipt and
    // a surface can both say what is happening in words.
    public static final String S_RESOLVE = 'call 0 resolve';
    public static final String S_READ1 = 'call 1 read 1';
    public static final String S_READ2 = 'call 1 read 2';
    public static final String S_DETERMINISTIC = 'call 2a deterministic';
    public static final String S_MODEL_LEG = 'call 2b model leg';
    public static final String S_VERIFY = 'call 3 verify';
    public static final String S_JOIN = 'join';
    public static final String S_PROJECT = 'projection';
    public static final String S_PROMOTION = 'promotion';
    public static final String S_CARDS = 'cards';
    public static final String S_DONE = 'done';

    private static final List<String> ORDER = new List<String>{
        S_RESOLVE, S_READ1, S_READ2, S_DETERMINISTIC, S_MODEL_LEG,
        S_VERIFY, S_JOIN, S_PROJECT, S_PROMOTION, S_CARDS, S_DONE
    };

    private final Id sourceId;
    private final String runKey;
    private final String stage;
    /** How many times this stage has re-enqueued itself, so a loop cannot run away. */
    private final Integer pass;

    private static final Integer MAX_PASSES_PER_STAGE = 12;

    public AAO_PassQueueable(Id sourceId, String runKey) {
        this(sourceId, runKey, S_RESOLVE, 0);
    }

    private AAO_PassQueueable(Id sourceId, String runKey, String stage, Integer pass) {
        this.sourceId = sourceId;
        this.runKey = runKey;
        this.stage = stage;
        this.pass = pass;
    }

    public void execute(QueueableContext ctx) {
        if (stage == S_DONE) {
            return;
        }
        Boolean again = false;
        try {
            again = runStage();
        } catch (Exception e) {
            // THE CHAIN STOPS AND SAYS WHY. Never re-thrown: a thrown queueable is retried by
            // the platform and would repeat the failing stage against half-written state.
            AAO_Receipt.recordFailure(
                runKey, sourceId, stage,
                e.getTypeName() + ': ' + e.getMessage()
            );
            return;
        }

        if (again && pass + 1 >= MAX_PASSES_PER_STAGE) {
            AAO_Receipt.recordFailure(
                runKey, sourceId, stage,
                'Stage asked to continue for a ' + MAX_PASSES_PER_STAGE + 'th transaction. ' +
                'Stopping rather than looping: a stage that never converges is a defect, and a ' +
                'runaway chain would burn callouts reporting nothing.'
            );
            return;
        }

        String next = again ? stage : ORDER[ORDER.indexOf(stage) + 1];
        Integer nextPass = again ? pass + 1 : 0;
        if (next == S_DONE) {
            return;
        }
        // A queueable may enqueue one child. Where the org refuses (depth or limits), the chain
        // stops with a journalled reason rather than silently ending mid-pass.
        if (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() < 1) {
            AAO_Receipt.recordFailure(
                runKey, sourceId, stage,
                'No queueable slot left to continue the chain at stage "' + next + '".'
            );
            return;
        }
        System.enqueueJob(new AAO_PassQueueable(sourceId, runKey, next, nextPass));
    }

    /** Runs one stage. Returns true where the SAME stage must run again in a new transaction. */
    private Boolean runStage() {
        if (stage == S_RESOLVE) {
            AAO_Pass.resolve(sourceId, runKey);
            return false;
        }
        if (stage == S_READ1) {
            AAO_Pass.locateRead(sourceId, runKey, 1);
            return false;
        }
        if (stage == S_READ2) {
            AAO_Pass.locateRead(sourceId, runKey, 2);
            return false;
        }
        if (stage == S_DETERMINISTIC) {
            AAO_Pass.identifyDeterministic(sourceId, runKey);
            return false;
        }
        if (stage == S_MODEL_LEG) {
            // Only where the deterministic legs left a remainder. A model call with nothing to
            // resolve is a callout spent on nothing, and the run's own numbers should show a
            // leg that did not fire rather than one that fired empty.
            if (remainingUnresolved() == 0) {
                return false;
            }
            AAO_Pass.raiseHeld(AAO_Resolve.requests(sourceId, runKey));
            return false;
        }
        if (stage == S_VERIFY) {
            AAO_Pass.verify(runKey);
            return unverifiedCount() > 0;
        }
        if (stage == S_JOIN) {
            AAO_PairCommit.Outcome o = AAO_PairCommit.run(
                runKey, AAO_IngestQueueable.internalDomains()
            );
            return o.pairsRemaining > 0;
        }
        if (stage == S_PROJECT) {
            AAO_Project.run(opportunityId(), runKey);
            return false;
        }
        if (stage == S_PROMOTION) {
            AAO_Promotion.runAfterProjection(opportunityId());
            return false;
        }
        if (stage == S_CARDS) {
            AAO_Cards.run(opportunityId(), runKey);
            return false;
        }
        return false;
    }

    // ------------------------------------------------------------------ loop conditions

    private Integer unverifiedCount() {
        return [
            SELECT COUNT()
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey
              AND AAO_Stage__c = :AAO_PairKey.IDENTIFIED
              AND AAO_Disposition__c = 'Identified'
              AND AAO_Verification__c = null
        ];
    }

    private Integer remainingUnresolved() {
        return [
            SELECT COUNT()
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey
              AND AAO_Stage__c = :AAO_PairKey.LOCATED
              AND AAO_About_Designator__c != null
        ];
    }

    private Id opportunityId() {
        return [
            SELECT AAO_Opportunity__c FROM AAO_Source__c WHERE Id = :sourceId LIMIT 1
        ].AAO_Opportunity__c;
    }
}
