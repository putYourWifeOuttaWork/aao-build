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
    /**
     * MATCH BEFORE MINT. Its own stage because the answer is a model judgment and the join, which
     * mints, cannot call out after DML. One callout on runs that name criteria, none on runs that
     * do not, and none on a deal with no standing criteria to match against.
     */
    public static final String S_CRITERION_MATCH = 'criterion match';
    public static final String S_JOIN = 'join';
    /**
     * THE COMPUTED PLANE, and it is its own stage rather than a tail on the join.
     *
     * Two reasons, both measured rather than tidy. The join is the SOQL-bound stage - the
     * hundred-fifth stamp fitted it at `2.33*C + 9` against a ceiling of 100, which is where the
     * s5 join died - and hanging a second reader off it would spend the one budget the pass has
     * least of. And a stage that leaves no receipt leg cannot be measured, so a computed plane
     * folded into the join would be arithmetic nobody can price. It makes ZERO callouts, so its
     * own transaction costs a queueable hop and nothing else.
     */
    public static final String S_COMPUTE = 'computed catalog';
    public static final String S_PROJECT = 'projection';
    public static final String S_PROMOTION = 'promotion';
    public static final String S_CARDS = 'cards';
    /**
     * THE ASSESSMENT SURFACE, LAST, and last on purpose.
     *
     * It reads what the deal ESTABLISHED, so it must run after the join has written this run's
     * answers and after promotion has had its say about them. Putting it earlier would project
     * the deal as it stood mid-pass, which is the same mistake the computed catalog's placement
     * comment already argues against one stage up. It makes ZERO callouts.
     */
    public static final String S_ASSESSMENT = 'assessment projection';
    /** The ghosts, beside the assessment surface and for the same reason: both read what the
     *  deal has established, so both belong after everything that establishes. */
    public static final String S_GHOSTS = 'ghost projection';
    /** The sales-process qualifiers, beside the other two read-what-was-established stages. */
    public static final String S_QUALIFIERS = 'qualifier projection';
    public static final String S_DONE = 'done';

    private static final List<String> ORDER = new List<String>{
        S_RESOLVE, S_READ1, S_READ2, S_DETERMINISTIC, S_MODEL_LEG,
        S_VERIFY, S_CRITERION_MATCH, S_JOIN, S_COMPUTE, S_PROJECT, S_PROMOTION, S_CARDS,
        S_ASSESSMENT, S_GHOSTS, S_QUALIFIERS, S_DONE
    };

    private final Id sourceId;
    private final String runKey;
    private final String stage;
    /** How many times this stage has re-enqueued itself, so a loop cannot run away. */
    private final Integer pass;
    /**
     * TRUE WHERE THIS TRANSACTION IS THE CHAIN ENTERING, false where it is the chain continuing.
     *
     * The deal's lease is taken ONCE per chain and held across every stage, so only an entry asks
     * for it. A continuation asking again would cost a query and a write on every stage - and the
     * join is the stage that cannot spare a query, since SOQL is the binding governor there at
     * `2.33 * C + 9`. A resume is an entry: it re-enters mid-chain after a stage died, and the
     * lease it once held was given back by that death's own finalizer.
     */
    private final Boolean isEntry;
    /**
     * TRUE once this chain has spent a transaction letting concurrent arrivals enrol.
     *
     * The hundred-twenty-fifth's wording is "**re-enqueue, not proceed**", and the re-enqueue is
     * the load-bearing half. The first cut read the waiting set straight after acquiring and
     * yielded to nobody, because the losers had not committed their WAIT rows yet - proved on the
     * first targeted run, where call 3 still went first. A settle costs one transaction and no
     * callout, and it is what turns a read of the waiting set into a read of a set that exists.
     */
    private final Boolean settled;

    private static final Integer MAX_PASSES_PER_STAGE = 12;

    public AAO_PassQueueable(Id sourceId, String runKey) {
        this(sourceId, runKey, S_RESOLVE, 0, true, false);
    }

    /**
     * RESUME AT A NAMED STAGE, so a stage that died does not cost the whole run.
     *
     * A model callout can time out - `System.CalloutException: Read timed out` killed call 3 on a
     * live demo run with twenty-seven identified pairs already waiting - and the work in front of
     * it is banked. **Re-running from the start would re-locate and duplicate pairs**, so a
     * resume enters at the stage that failed and the pass's own watermarks make everything after
     * it idempotent: verify skips what is verified, the join skips what carries a claim.
     *
     * This is the ninety-second stamp's split rule reaching failure as well as size - complete
     * the remaining work in a continuation, never redo.
     */
    public static void resumeAt(Id sourceId, String runKey, String stage) {
        System.enqueueJob(new AAO_PassQueueable(sourceId, runKey, stage, 0, true, false));
    }

    /**
     * THE STAGE TO RESUME AT IS THE ONE THAT FAILED, not the first one with no leg.
     *
     * The first version looked for the first unjournalled stage, and that is wrong for a reason
     * this pass has by design: **stages that legitimately do nothing journal nothing.** The
     * deterministic leg never writes a leg of its own, and the model leg writes none when the
     * deterministic pass leaves no remainder - so "first stage with no leg" resolved to a stage
     * near the FRONT of a run that had failed at the END, and the resume marched forward through
     * work already done until it hit `AAO_Pass.verify` on a fully verified run and threw.
     *
     * A failed leg names the stage exactly. Resume there, and nowhere else.
     */
    public static String stageForReceiptName(String receiptName) {
        for (String st : ORDER) {
            if (receiptNameOf(st) == receiptName) {
                return st;
            }
        }
        return null;
    }

    /** This driver's stage names against the names the receipt actually writes. */
    private static String receiptNameOf(String stage) {
        if (stage == S_READ1) {
            return 'call 1 locate read 1';
        }
        if (stage == S_READ2) {
            return 'call 1 locate read 2';
        }
        if (stage == S_DETERMINISTIC) {
            // Journals no leg of its own; treated as done once the model leg or verify has run.
            return 'resolution model leg';
        }
        if (stage == S_MODEL_LEG) {
            return 'resolution model leg';
        }
        if (stage == S_PROMOTION) {
            return 'projection';
        }
        return stage;
    }

    private AAO_PassQueueable(
        Id sourceId,
        String runKey,
        String stage,
        Integer pass,
        Boolean isEntry,
        Boolean settled
    ) {
        this.sourceId = sourceId;
        this.runKey = runKey;
        this.stage = stage;
        this.pass = pass;
        this.isEntry = isEntry;
        this.settled = settled;
    }

    public void execute(QueueableContext ctx) {
        if (stage == S_DONE) {
            // Unreachable on the chain, which returns before it can enqueue this - but the drain
            // wakes a run at whatever stage its waiting row recorded, and a stale one landing
            // here would hold the deal's lease forever with nothing running. A wedge is the one
            // failure the lease exists to prevent, so it does not get a back door.
            AAO_RunLease.releaseAndDrain(opportunityIdOrNull(), runKey);
            return;
        }
        Id oppId = opportunityIdOrNull();

        // ===== THE FINALIZER GOES ON FIRST, before any line that could be the last one.
        //
        // R3. `AAO_PassQueueable` already catches `Exception` and journals a failure leg, and
        // that reaches everything a catch can reach. **It cannot reach a governor
        // `LimitException`** - the platform kills the transaction and the catch below never
        // runs - so a stage that hits the SOQL ceiling leaves no leg at all, which is
        // byte-for-byte the shape that let `Too many SOQL queries: 101` read as quiet on
        // 16 August while 39 upheld pairs produced no claims. The finalizer runs in its own
        // transaction afterwards either way, and writes the leg the dead transaction could not.
        System.attachFinalizer(new AAO_RunFinalizer(runKey, sourceId, receiptNameOf(stage), oppId));

        // ===== THE DEAL IS TAKEN, OR THIS RUN QUEUES BEHIND WHOEVER HAS IT.
        //
        // R5. Returning on contention is not a failure and journals nothing: the run is enrolled,
        // and the holder's release will wake it in evidence-occurred order. Marking a failure leg
        // for a lawful wait would put a red stage on the process bar for a run doing exactly what
        // it should, so the surface asks the lease instead of reading the receipt.
        //
        // **THE ACQUIRE GETS A TRANSACTION OF ITS OWN, AND THAT IS NOT TIDINESS.** Taking the
        // lease is DML, and every stage behind it makes a callout - and Apex forbids a callout
        // after DML in the same transaction. The first gate run found this on its first attempt,
        // on all three calls at once:
        //
        //     System.CalloutException: You have uncommitted work pending.
        //     Please commit or rollback before calling out
        //
        // R5 was built, tested and ratified without ever standing in front of a callout, because
        // a unit test does not make one. So the entry transaction takes the lease and does
        // nothing else; the stage itself runs in the next one, clean. That is the same
        // one-thing-per-transaction shape the whole chain already has, extended by one link.
        if (isEntry == true) {
            if (!AAO_RunLease.acquire(oppId, sourceId, runKey, stage)) {
                return;
            }
            if (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() < 1) {
                AAO_Receipt.recordFailure(
                    runKey, sourceId, receiptNameOf(stage),
                    'The deal lease was taken but no queueable slot was left to start the stage.'
                );
                AAO_RunLease.releaseAndDrain(oppId, runKey);
                return;
            }
            System.enqueueJob(
                new AAO_PassQueueable(sourceId, runKey, stage, pass, false, settled)
            );
            return;
        }

        // ===== BEFORE ANY WORK IS DONE, SETTLE, THEN GIVE WAY TO AN EARLIER CONVERSATION.
        //
        // The hundred-twenty-fifth's item 3, in its own words: "at acquisition on an idle deal,
        // the winner reads the enrolled-waiting set and YIELDS to any earlier-occurred
        // conversation - **re-enqueue, not proceed**".
        //
        // **THE RE-ENQUEUE COMES FIRST AND IT IS NOT CEREMONY.** Three calls arriving together
        // enter in three concurrent transactions; the winner's acquire commits before the losers'
        // WAIT rows do, so a winner that reads the waiting set immediately reads an empty one and
        // yields to nobody. That is not a hypothesis - it is what the first targeted run did, with
        // call 3 going first exactly as before the fix. So the winner spends one transaction
        // doing nothing at all, which costs no callout and no model tokens, and asks afterwards.
        //
        // Only at the chain's very start: nothing has been spent yet, so yielding is free, and a
        // resume entering mid-chain is continuing banked work that must never be handed away.
        if (stage == S_RESOLVE && pass == 0) {
            if (settled != true) {
                if (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() >= 1) {
                    System.enqueueJob(
                        new AAO_PassQueueable(sourceId, runKey, stage, pass, false, true)
                    );
                    return;
                }
                // No slot to settle with. Proceeding unordered beats not running at all, and the
                // ledger's replay is order-independent even when the board's write order is not.
            } else if (AAO_RunLease.yieldToEarlier(oppId, sourceId, runKey, stage)) {
                return;
            }
        }

        Boolean again = false;
        try {
            again = runStage();
        } catch (Exception e) {
            // THE CHAIN STOPS AND SAYS WHY. Never re-thrown: a thrown queueable is retried by
            // the platform and would repeat the failing stage against half-written state.
            // Recorded under the RECEIPT'S name for the stage, not the driver's, so the
            // surface can mark the right step failed. The driver calls it "call 2b model leg";
            // the receipt writes "resolution model leg", and a failure filed under a name no
            // reader knows is a failure nobody can place.
            AAO_Receipt.recordFailure(
                runKey, sourceId, receiptNameOf(stage),
                e.getTypeName() + ': ' + e.getMessage()
            );
            // The chain stops here, so the deal goes back. A stage that STOPS holds no more
            // claim on the opportunity than one that died; the difference is only that this one
            // survived to say so itself.
            AAO_RunLease.releaseAndDrain(oppId, runKey);
            return;
        }

        if (again && pass + 1 >= MAX_PASSES_PER_STAGE) {
            AAO_Receipt.recordFailure(
                runKey, sourceId, stage,
                'Stage asked to continue for a ' + MAX_PASSES_PER_STAGE + 'th transaction. ' +
                'Stopping rather than looping: a stage that never converges is a defect, and a ' +
                'runaway chain would burn callouts reporting nothing.'
            );
            AAO_RunLease.releaseAndDrain(oppId, runKey);
            return;
        }

        String next = again ? stage : ORDER[ORDER.indexOf(stage) + 1];
        Integer nextPass = again ? pass + 1 : 0;
        if (next == S_DONE) {
            // The pass finished. This is the ordinary release, and it is what makes the queue
            // behind this deal move.
            AAO_RunLease.releaseAndDrain(oppId, runKey);
            return;
        }
        // A queueable may enqueue one child. Where the org refuses (depth or limits), the chain
        // stops with a journalled reason rather than silently ending mid-pass.
        if (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() < 1) {
            AAO_Receipt.recordFailure(
                runKey, sourceId, stage,
                'No queueable slot left to continue the chain at stage "' + next + '".'
            );
            AAO_RunLease.releaseAndDrain(oppId, runKey);
            return;
        }
        System.enqueueJob(
            new AAO_PassQueueable(sourceId, runKey, next, nextPass, false, true)
        );
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
            // GUARDED LIKE THE MODEL LEG, and for the identical reason. `AAO_Pass.verify` throws
            // "No unverified identified claims" when there is nothing to do - correct for a stage
            // that should never be called pointlessly, and fatal for a DRIVER that calls it on a
            // resume after verify already finished. The stage asks a fair question; asking it at
            // the wrong moment is the driver's fault, not the pass's.
            if (unverifiedCount() == 0) {
                return false;
            }
            AAO_Pass.verify(runKey);
            return unverifiedCount() > 0;
        }
        if (stage == S_CRITERION_MATCH) {
            AAO_CriterionMatch.Outcome cm = AAO_CriterionMatch.run(runKey);
            System.debug(LoggingLevel.INFO, 'criterion match: ' + cm);
            return false;
        }
        if (stage == S_JOIN) {
            AAO_PairCommit.Outcome o = AAO_PairCommit.run(
                runKey, AAO_IngestQueueable.internalDomains()
            );
            return o.pairsRemaining > 0;
        }
        if (stage == S_COMPUTE) {
            // AFTER the join, BEFORE projection, and both halves of that are load bearing. The
            // join is what writes this run's answers, and the computed plane reads them; running
            // first would compute against the deal as it stood before the call. Projection is
            // what carries the result to the map, and a computed establishment that arrived
            // after it would sit in our ledger unprojected until the next run.
            AAO_ProcessCompute.Outcome co = AAO_ProcessCompute.run(opportunityId(), runKey);
            System.debug(LoggingLevel.INFO, 'computed catalog: ' + co);
            return false;
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
        if (stage == S_ASSESSMENT) {
            AAO_AnswerProjection.Outcome ao =
                AAO_AnswerProjection.run(opportunityId(), runKey);
            System.debug(LoggingLevel.INFO, String.valueOf(ao));
            return false;
        }
        if (stage == S_GHOSTS) {
            AAO_GhostProjection.Outcome go =
                AAO_GhostProjection.run(opportunityId(), runKey);
            System.debug(LoggingLevel.INFO, String.valueOf(go));
            return false;
        }
        if (stage == S_QUALIFIERS) {
            AAO_QualifierProjection.Outcome qo =
                AAO_QualifierProjection.run(opportunityId(), runKey);
            System.debug(LoggingLevel.INFO, String.valueOf(qo));
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

    /**
     * UNDISPOSED pairs - the only thing the model leg exists to work on.
     *
     * The first version counted LOCATED pairs carrying a designator, which is always above zero
     * after the reads because the located rows are the PARENTS and they stay. So the guard never
     * skipped, the model leg fired on a run the deterministic pass had fully disposed, and
     * `AAO_Resolve` refused it correctly: *"No undisposed pairs. The model leg fires only when
     * the deterministic legs leave a remainder."* The pass was right; the driver's question was
     * the wrong one.
     *
     * A pair is disposed when an Identified row points back at it, so undisposed is exactly the
     * located rows with no such child - which is the same set `AAO_Resolve` itself works from.
     */
    private Integer remainingUnresolved() {
        // Counted in Apex rather than by a semi-join: SOQL refuses an inner and outer select on
        // the SAME object, and located and identified rows are both AAO_Pair__c. The org said so
        // on the first deploy, which is the schema teaching the query again.
        Set<Id> disposed = new Set<Id>();
        for (AAO_Pair__c p : [
            SELECT AAO_Located_Pair__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey
              AND AAO_Stage__c = :AAO_PairKey.IDENTIFIED
              AND AAO_Located_Pair__c != null
        ]) {
            disposed.add(p.AAO_Located_Pair__c);
        }
        Integer undisposed = 0;
        for (AAO_Pair__c p : [
            SELECT Id
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.LOCATED
        ]) {
            if (!disposed.contains(p.Id)) {
                undisposed++;
            }
        }
        return undisposed;
    }

    private Id opportunityId() {
        return [
            SELECT AAO_Opportunity__c FROM AAO_Source__c WHERE Id = :sourceId LIMIT 1
        ].AAO_Opportunity__c;
    }

    /**
     * The same lookup, refusing to throw. The lease and the finalizer are both infrastructure
     * around the pass rather than part of it, and neither may be the thing that kills a run: a
     * Source that cannot be read is a real failure, and it should be reported by the stage that
     * needs it rather than by the bookkeeping that wrapped it.
     */
    private Id opportunityIdOrNull() {
        for (AAO_Source__c s : [
            SELECT AAO_Opportunity__c FROM AAO_Source__c WHERE Id = :sourceId LIMIT 1
        ]) {
            return s.AAO_Opportunity__c;
        }
        return null;
    }
}
