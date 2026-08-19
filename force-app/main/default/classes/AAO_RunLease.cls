/**
 * ONE PASS AT A TIME PER DEAL, AND THE QUEUE BEHIND IT DRAINS BY THE CONVERSATION'S OWN CLOCK.
 *
 * R5, accepted with design's correction at the hundred-tenth stamp and pulled forward by the
 * hundred-nineteenth as a **Process prerequisite rather than hygiene**: Process READS written
 * state, so a Process pass racing a People pass reads a half-written map.
 *
 * It is also the hundred-sixteenth stamp's own precondition, stated there in as many words:
 * *"read-first is only sound if no concurrent writer moves the state between read and write on
 * one deal."* Read-before-write makes a duplicate structurally impossible against a STANDING
 * state; it says nothing about a state that moves underneath the reader. This is what stops it
 * moving.
 *
 * **THE INDEX IS THE LOCK, and that is not an implementation detail.** Two passes racing for one
 * deal both insert `HOLD|<opportunity>`; the unique index refuses the loser; exactly one wins. An
 * acquire that READ first and then branched would hand the deal to both, because both readers see
 * an empty table before either has committed - the one shape where read-before-write cannot be
 * the answer, because there is no atomic read.
 *
 * **SO DUPLICATE_VALUE IS LAWFUL HERE, and only here.** The hundred-sixteenth stamp rules it an
 * alarm that never fires and never a control-flow branch, and that ruling governs ACCRUAL state -
 * answers, claims, criteria, cards - where occupancy at insert time means a writer skipped a read
 * it could have made. A lease accrues nothing and has no read it could have made. The distinction
 * is kept narrow on purpose: this class owns the only `DUPLICATE_VALUE` branch in the system, it
 * covers exactly one insert of exactly one row, and anything else that meets that error is still
 * the alarm.
 *
 * **THE DRAIN ORDERS ON EVIDENCE-OCCURRED, NEVER ARRIVAL.** Design's correction to R5, and the
 * reason it is a correction: a lease SERIALIZES, it does not ORDER, and a late-delivered older
 * call admitted after a newer one reads the deal's history backwards. Two calls landing at lunch
 * is the hundred-fifteenth stamp's Class A concurrent cousin; two calls landing at lunch OUT OF
 * ORDER is a worse bug wearing the fix's clothes.
 *
 * **A LEASE IS A LOCK AND NEVER EVIDENCE**, which is why a released row is deleted. The
 * never-delete law protects the record of what was established; what a lease records is that
 * something was briefly in progress, and the run receipt is where that history lives.
 */
public class AAO_RunLease {
    public static final String HOLDER = 'Holder';
    public static final String WAITING = 'Waiting';

    /** Kept off the wire in tests that are measuring something else. */
    @TestVisible
    private static Boolean ENABLED = true;

    public class LeaseException extends Exception {}

    private static String holdKey(Id opportunityId) {
        return 'HOLD|' + opportunityId;
    }

    private static String waitKey(Id opportunityId, Id sourceId) {
        return 'WAIT|' + opportunityId + '|' + sourceId;
    }

    /**
     * TAKE THE DEAL, OR ENROL BEHIND WHOEVER HAS IT. Returns true where this run may proceed.
     *
     * Re-entrant for its own holder: the pass chain crosses many transactions on one lease, and a
     * resume re-enters mid-chain, so meeting our OWN holder row is success and not contention.
     * Without that, a resumed run would queue behind itself forever, which is the wedge this
     * mechanism exists to prevent arriving through its own front door.
     */
    public static Boolean acquire(Id opportunityId, Id sourceId, String runKey, String stage) {
        if (!ENABLED || opportunityId == null) {
            return true;
        }
        AAO_Run_Lease__c row = new AAO_Run_Lease__c(
            AAO_Lease_Key__c = holdKey(opportunityId),
            AAO_Kind__c = HOLDER,
            AAO_Opportunity__c = opportunityId,
            AAO_Source__c = sourceId,
            AAO_Run_Key__c = runKey,
            AAO_Stage__c = stage,
            AAO_Acquired_At__c = System.now(),
            AAO_Synthetic__c = AAO_Synthetic.MARK
        );
        // allOrNone FALSE so a refused insert is an ANSWER rather than a dead transaction. The
        // whole pass is behind this call; letting the index's refusal kill the transaction would
        // turn "the deal is busy" into "the run vanished".
        Database.SaveResult sr = Database.insert(row, false);
        if (sr.isSuccess()) {
            return true;
        }
        Boolean duplicate = false;
        String otherErrors = '';
        for (Database.Error err : sr.getErrors()) {
            if (err.getStatusCode() == StatusCode.DUPLICATE_VALUE) {
                duplicate = true;
            } else {
                otherErrors += err.getStatusCode() + ': ' + err.getMessage() + ' ';
            }
        }
        if (!duplicate) {
            // NOT the lock, therefore a real defect, therefore loud. A lease that fails to write
            // for any other reason must never read as "the deal is busy".
            throw new LeaseException(
                'The run lease could not be written and the reason was not contention: ' +
                otherErrors
            );
        }

        for (AAO_Run_Lease__c held : [
            SELECT AAO_Run_Key__c
            FROM AAO_Run_Lease__c
            WHERE AAO_Lease_Key__c = :holdKey(opportunityId)
            LIMIT 1
        ]) {
            if (held.AAO_Run_Key__c == runKey) {
                return true;
            }
        }

        // Somebody else holds it. Enrol, idempotently: a run that meets contention twice must
        // not queue twice, and the WAIT key is what makes that a guarantee rather than a check.
        AAO_Run_Lease__c waiter = new AAO_Run_Lease__c(
            AAO_Lease_Key__c = waitKey(opportunityId, sourceId),
            AAO_Kind__c = WAITING,
            AAO_Opportunity__c = opportunityId,
            AAO_Source__c = sourceId,
            AAO_Run_Key__c = runKey,
            AAO_Stage__c = stage,
            AAO_Acquired_At__c = System.now(),
            AAO_Synthetic__c = AAO_Synthetic.MARK
        );
        upsert waiter AAO_Run_Lease__c.AAO_Lease_Key__c;
        return false;
    }

    /**
     * GIVE THE DEAL BACK AND HAND IT TO THE NEXT CALL IN THE CONVERSATION'S ORDER.
     *
     * Idempotent, because it is called from two places that can both be right: the pass releases
     * when its chain ends, and the finalizer releases when the chain DIED. Only one of those
     * happens on any given run, but neither can see which - so both call, and the second finds
     * nothing to do.
     *
     * **It never releases a lease it does not hold.** A run whose finalizer fires late, after the
     * deal has already been handed on, would otherwise evict a healthy pass mid-flight.
     *
     * Enqueues AT MOST ONE job, which is also the platform's ceiling for a finalizer, so the
     * drain is the same call in both callers rather than two shapes of it.
     */
    public static void releaseAndDrain(Id opportunityId, String runKey) {
        if (!ENABLED || opportunityId == null) {
            return;
        }
        List<AAO_Run_Lease__c> held = [
            SELECT Id, AAO_Run_Key__c
            FROM AAO_Run_Lease__c
            WHERE AAO_Lease_Key__c = :holdKey(opportunityId)
            LIMIT 1
        ];
        if (!held.isEmpty()) {
            if (held[0].AAO_Run_Key__c != runKey) {
                // Not ours. Somebody else already took the deal, which means it was released and
                // drained before we got here; there is nothing owed and nothing to disturb.
                return;
            }
            delete held;
        }

        AAO_Run_Lease__c next = nextWaiter(opportunityId);
        if (next == null) {
            return;
        }

        // Hand the lease over IN THIS TRANSACTION rather than letting the woken pass race for it.
        // If it had to acquire for itself, a third run could take the deal in the gap and the
        // occurred-order guarantee would quietly become arrival order again.
        insert new AAO_Run_Lease__c(
            AAO_Lease_Key__c = holdKey(opportunityId),
            AAO_Kind__c = HOLDER,
            AAO_Opportunity__c = opportunityId,
            AAO_Source__c = next.AAO_Source__c,
            AAO_Run_Key__c = next.AAO_Run_Key__c,
            AAO_Stage__c = next.AAO_Stage__c,
            AAO_Acquired_At__c = System.now(),
            AAO_Synthetic__c = AAO_Synthetic.MARK
        );
        delete next;

        if (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() < 1) {
            // The lease is handed over and the waiter is not woken, which is recoverable (the
            // holder row names the run and the stage) and is stated rather than left silent.
            AAO_Receipt.recordFailure(
                next.AAO_Run_Key__c,
                next.AAO_Source__c,
                next.AAO_Stage__c,
                'The deal lease was handed to this run but no queueable slot was left to wake ' +
                'it. It holds the lease and has not started.'
            );
            return;
        }
        AAO_PassQueueable.resumeAt(next.AAO_Source__c, next.AAO_Run_Key__c, next.AAO_Stage__c);
    }

    /**
     * THE FIRST ACQUISITION OBEYS THE SAME LAW AS THE DRAIN · ruled at the hundred-twenty-fifth.
     *
     * **The gap the gate exposed.** The occurred-order guarantee covered the QUEUE and not the
     * first acquisition: three calls arriving at an idle deal race for the lease and the winner is
     * arbitrary. Gate run A is the specimen - enqueued newest-first, call 3 won and ran first;
     * run B, same code and same bytes, happened to fall to call 1. Two runs of one spine
     * disagreeing about order is exactly what an unguarded race looks like.
     *
     * **Why it stopped being cosmetic at the hundred-twenty-fourth.** Answers were always safe
     * (replay orders claims by evidence-occurred, so the standing state is order-independent) and
     * the confirmation counts stay right (arithmetic over the trail). But that stamp made the
     * STANDING CARD the match target, so **write order now decides which establishment is the
     * ORIGINAL and which is the reinforcement** - and a later call writing first misorders
     * provenance in a way no arithmetic repairs.
     *
     * **So the winner yields.** It reads the enrolled-waiting set, and if any waiter carries an
     * earlier conversation it enrols itself, hands the deal on, and stops. Returns true where
     * this run yielded and must not proceed.
     *
     * **CHECKED AT THE FIRST STAGE, NOT AT THE ACQUIRE**, and the window is the whole reason. The
     * acquire now runs in a transaction of its own (the callout-after-DML fix), and the losers
     * enrol during it - so by the time the chain's first stage begins, the waiting set is
     * populated. Checking inside the acquire would read a set the losers had not written yet and
     * yield to nobody. **It is ordering, not a lock**: two runs entering the exact same instant
     * can still land arbitrarily, and this narrows that window rather than sealing it. Sealing it
     * needs `FOR UPDATE`, which the hundred-twenty-fourth refused - "row lock errors are serious
     * problems" - so best-effort ordering with no lock is the ruled shape, not a shortfall.
     */
    public static Boolean yieldToEarlier(
        Id opportunityId, Id sourceId, String runKey, String stage
    ) {
        if (!ENABLED || opportunityId == null || sourceId == null) {
            return false;
        }
        if (!earlierIsWaiting(opportunityId, sourceId)) {
            return false;
        }

        // Enrol FIRST, then hand the deal on - in that order, so a failure between the two leaves
        // this run queued rather than dropped. The drain then picks the earliest waiter, which is
        // by construction not us.
        upsert new AAO_Run_Lease__c(
            AAO_Lease_Key__c = waitKey(opportunityId, sourceId),
            AAO_Kind__c = WAITING,
            AAO_Opportunity__c = opportunityId,
            AAO_Source__c = sourceId,
            AAO_Run_Key__c = runKey,
            AAO_Stage__c = stage,
            AAO_Acquired_At__c = System.now(),
            AAO_Synthetic__c = AAO_Synthetic.MARK
        ) AAO_Lease_Key__c;
        releaseAndDrain(opportunityId, runKey);
        return true;
    }

    /**
     * THE DECISION HALF OF THE YIELD, ON ITS OWN, so it can be asserted without being acted on.
     *
     * `yieldToEarlier` enrols and hands the deal over, and handing over WAKES the next run - which
     * a test transaction may not do, because a queueable run by `stopTest` cannot enqueue another.
     * Splitting the question from the act is what lets the suite hold the ORDERING LAW to account
     * while the end-to-end path is proved where it belongs, at the runtime. The same shape as
     * `nextWaiter`, and for the same reason.
     */
    public static Boolean earlierIsWaiting(Id opportunityId, Id sourceId) {
        AAO_Run_Lease__c next = nextWaiter(opportunityId);
        if (next == null || next.AAO_Source__c == null || sourceId == null) {
            return false;
        }
        Map<Id, Datetime> occurred = new Map<Id, Datetime>();
        for (AAO_Source__c src : [
            SELECT Id, AAO_Evidence_Occurred__c FROM AAO_Source__c
            WHERE Id IN :(new Set<Id>{ sourceId, next.AAO_Source__c })
        ]) {
            occurred.put(src.Id, src.AAO_Evidence_Occurred__c);
        }
        Datetime mine = occurred.get(sourceId);
        Datetime theirs = occurred.get(next.AAO_Source__c);
        // NULLS FIRST, the same reading the drain uses: an artifact whose occurred time we do not
        // know is the one we can say least about, so it is adjudicated before later calls accrue
        // on top of it. A run with no time of its own never claims to be earlier than anyone.
        return (theirs == null && mine != null) ||
               (theirs != null && mine != null && theirs < mine);
    }

    /**
     * WHICH RUN GOES NEXT · THE CONVERSATION'S CLOCK, NOT THE QUEUE'S.
     *
     * Its own method because it is the ORDERING LAW and deserves to be nameable, assertable, and
     * quotable on its own - the drain around it is bookkeeping. Design's correction to R5 lives
     * entirely in this ORDER BY.
     *
     * NULLS FIRST is deliberate: a Source whose occurred time is unknown is the one we can say
     * least about, and putting it in front means it is adjudicated before later calls accrue on
     * top of it rather than after. Arrival time breaks ties and never decides one.
     */
    public static AAO_Run_Lease__c nextWaiter(Id opportunityId) {
        for (AAO_Run_Lease__c row : [
            SELECT Id, AAO_Opportunity__c, AAO_Source__c, AAO_Run_Key__c, AAO_Stage__c
            FROM AAO_Run_Lease__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Kind__c = :WAITING
            ORDER BY AAO_Source__r.AAO_Evidence_Occurred__c ASC NULLS FIRST, AAO_Acquired_At__c ASC
            LIMIT 1
        ]) {
            return row;
        }
        return null;
    }

    /**
     * WHO HOLDS THIS DEAL, for a surface that would otherwise show a run doing nothing.
     *
     * A queued pass journals no leg, because waiting is not a stage and marking it failed would
     * be a lie on the process bar. So the demo asks here instead, and a stalled-looking run can
     * say WHY it has not started - the silent-success hazard's twin, and the third demo-surface
     * instance of it.
     */
    public static AAO_Run_Lease__c holderOf(Id opportunityId) {
        if (opportunityId == null) {
            return null;
        }
        for (AAO_Run_Lease__c row : [
            SELECT Id, AAO_Run_Key__c, AAO_Stage__c, AAO_Acquired_At__c, AAO_Source__c
            FROM AAO_Run_Lease__c
            WHERE AAO_Lease_Key__c = :holdKey(opportunityId)
            LIMIT 1
        ]) {
            return row;
        }
        return null;
    }

    /** True where this run is enrolled and not yet holding. */
    public static Boolean isWaiting(Id opportunityId, String runKey) {
        if (opportunityId == null || String.isBlank(runKey)) {
            return false;
        }
        return [
            SELECT COUNT()
            FROM AAO_Run_Lease__c
            WHERE AAO_Opportunity__c = :opportunityId
              AND AAO_Kind__c = :WAITING
              AND AAO_Run_Key__c = :runKey
        ] > 0;
    }
}
