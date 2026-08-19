/**
 * THE LEASE, HELD TO THE TWO THINGS IT PROMISES: one pass at a time on a deal, and the queue
 * behind it drains by the conversation's clock rather than by who knocked first.
 *
 * The mechanism's two halves are proved in different places on purpose, and the split is the
 * capability law rather than convenience. **The INDEX refusing a second holder is the org's
 * behaviour**, so it is proved here against the real unique key, in a real transaction, with a
 * real `DUPLICATE_VALUE` - never against a mock that would agree with whatever we believed. **The
 * finalizer surviving a governor `LimitException` is also the org's behaviour and cannot be
 * fabricated in a test transaction at all**, so it was proved from the runtime instead and the
 * quoted leg is in the report. A test that pretended to cover it would be worse than one that
 * says where the proof lives.
 */
@IsTest
private class AAO_RunLeaseTest {

    private static Opportunity opp;
    private static Account acct;

    private static void deal() {
        acct = new Account(Name = 'AAO Lease Test Account');
        insert acct;
        opp = new Opportunity(
            Name = 'AAO Lease Test Deal', AccountId = acct.Id, StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
    }

    private static Id src(String sha, Datetime occurred) {
        AAO_Source__c s = new AAO_Source__c(
            AAO_Opportunity__c = opp.Id,
            AAO_Account__c = acct.Id,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c = sha,
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = 'Kayla: We are evaluating.',
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = occurred,
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{
                    'speakers' => new List<Object>{
                        new Map<String, Object>{
                            'key' => 'kayla', 'display' => 'Kayla Stanley',
                            'email' => 'kayla@customer.example'
                        }
                    }
                }
            )
        );
        insert s;
        return s.Id;
    }

    @IsTest
    static void theINDEXrefusesASecondHolderAndTheLoserEnrolsInstead() {
        deal();
        Id a = src('a'.repeat(64), Datetime.newInstanceGmt(2026, 8, 1, 15, 0, 0));
        Id b = src('b'.repeat(64), Datetime.newInstanceGmt(2026, 8, 2, 15, 0, 0));

        Test.startTest();
        Boolean first = AAO_RunLease.acquire(opp.Id, a, 'run-a', 'call 0 resolve');
        Boolean second = AAO_RunLease.acquire(opp.Id, b, 'run-b', 'call 0 resolve');
        Test.stopTest();

        System.assertEquals(true, first, 'The first run takes the deal.');
        System.assertEquals(
            false,
            second,
            'The second is refused BY THE UNIQUE INDEX, not by a read - a read-then-branch ' +
            'acquire hands the deal to both, because both readers see an empty table before ' +
            'either has committed.'
        );
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Run_Lease__c
             WHERE AAO_Opportunity__c = :opp.Id AND AAO_Kind__c = 'Holder'],
            'Exactly one holder, ever.'
        );
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Run_Lease__c
             WHERE AAO_Opportunity__c = :opp.Id AND AAO_Kind__c = 'Waiting'],
            'And the loser is enrolled rather than dropped: a refused run that vanished would ' +
            'be a lost call, which is the opposite of what serialising is for.'
        );
    }

    @IsTest
    static void ARUNSOWNREENTRYISNOTCONTENTION() {
        deal();
        Id a = src('a'.repeat(64), Datetime.newInstanceGmt(2026, 8, 1, 15, 0, 0));

        Test.startTest();
        AAO_RunLease.acquire(opp.Id, a, 'run-a', 'call 0 resolve');
        Boolean again = AAO_RunLease.acquire(opp.Id, a, 'run-a', 'join');
        Test.stopTest();

        System.assertEquals(
            true,
            again,
            'The pass crosses one transaction per stage on ONE lease and a resume re-enters ' +
            'mid-chain. A run that queued behind itself would wedge the deal through the very ' +
            'door the lease exists to lock.'
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Run_Lease__c
             WHERE AAO_Opportunity__c = :opp.Id AND AAO_Kind__c = 'Waiting'],
            'And it does not leave a waiting row behind it.'
        );
    }

    @IsTest
    static void ENROLLINGTWICEENROLSONCE() {
        deal();
        Id a = src('a'.repeat(64), Datetime.newInstanceGmt(2026, 8, 1, 15, 0, 0));
        Id b = src('b'.repeat(64), Datetime.newInstanceGmt(2026, 8, 2, 15, 0, 0));

        Test.startTest();
        AAO_RunLease.acquire(opp.Id, a, 'run-a', 'call 0 resolve');
        AAO_RunLease.acquire(opp.Id, b, 'run-b', 'call 0 resolve');
        AAO_RunLease.acquire(opp.Id, b, 'run-b', 'call 0 resolve');
        AAO_RunLease.acquire(opp.Id, b, 'run-b', 'call 0 resolve');
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Run_Lease__c
             WHERE AAO_Opportunity__c = :opp.Id AND AAO_Kind__c = 'Waiting'],
            'The WAIT key makes idempotence a guarantee rather than a check.'
        );
    }

    @IsTest
    static void THEDRAINTAKESTHEEARLIERCONVERSATIONNOTTHEEARLIERARRIVAL() {
        deal();
        Id holderSrc = src('a'.repeat(64), Datetime.newInstanceGmt(2026, 8, 1, 15, 0, 0));
        Id later = src('b'.repeat(64), Datetime.newInstanceGmt(2026, 9, 30, 15, 0, 0));
        Id earlier = src('c'.repeat(64), Datetime.newInstanceGmt(2026, 8, 15, 15, 0, 0));

        AAO_RunLease.acquire(opp.Id, holderSrc, 'run-holder', 'call 0 resolve');
        // The LATER conversation knocks first. Arrival order would wake it.
        AAO_RunLease.acquire(opp.Id, later, 'run-later', AAO_PassQueueable.S_DONE);
        AAO_RunLease.acquire(opp.Id, earlier, 'run-earlier', AAO_PassQueueable.S_DONE);

        // ASSERTED ON `nextWaiter`, WHICH IS THE ORDERING LAW ITSELF, rather than through the
        // drain that wraps it. Not a workaround for a limit but the right subject: the drain
        // WAKES the run it picks, a woken run that finishes immediately drains the next, and a
        // queue of N therefore drains as a chain of N jobs - correct in the org, and refused
        // inside a test transaction, where a queueable may not enqueue another. The full drain
        // including the handoff and the wake was proved from the runtime on STAGE A instead,
        // and the choice it made is the one asserted here.
        AAO_Run_Lease__c handed = AAO_RunLease.nextWaiter(opp.Id);

        System.assertNotEquals(null, handed, 'The deal is handed on, not merely given up.');
        System.assertEquals(
            3,
            [SELECT COUNT() FROM AAO_Run_Lease__c WHERE AAO_Opportunity__c = :opp.Id],
            'One holder and two waiters, before anything is drained.'
        );
        System.assertEquals(
            'run-earlier',
            handed.AAO_Run_Key__c,
            'A lease SERIALISES; the law ORDERS. A late-delivered older call admitted after a ' +
            'newer one reads the deal history backwards, which is a worse bug wearing the ' +
            'fix\'s clothes.'
        );
    }

    @IsTest
    static void ARELEASEBYARUNTHATDOESNOTHOLDITMOVESNOTHING() {
        deal();
        Id a = src('a'.repeat(64), Datetime.newInstanceGmt(2026, 8, 1, 15, 0, 0));
        Id b = src('b'.repeat(64), Datetime.newInstanceGmt(2026, 8, 2, 15, 0, 0));
        AAO_RunLease.acquire(opp.Id, a, 'run-a', 'call 0 resolve');
        AAO_RunLease.acquire(opp.Id, b, 'run-b', AAO_PassQueueable.S_DONE);

        Test.startTest();
        // A finalizer firing late, after the deal has already moved on, must not evict the
        // healthy pass that holds it now.
        AAO_RunLease.releaseAndDrain(opp.Id, 'run-somebody-else');
        Test.stopTest();

        System.assertEquals(
            'run-a',
            AAO_RunLease.holderOf(opp.Id).AAO_Run_Key__c,
            'Not ours, not released.'
        );
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Run_Lease__c
             WHERE AAO_Opportunity__c = :opp.Id AND AAO_Kind__c = 'Waiting'],
            'And the queue behind it is not disturbed either.'
        );
    }

    @IsTest
    static void RELEASINGTWICEISRELEASINGONCE() {
        deal();
        Id a = src('a'.repeat(64), Datetime.newInstanceGmt(2026, 8, 1, 15, 0, 0));
        AAO_RunLease.acquire(opp.Id, a, 'run-a', 'call 0 resolve');

        Test.startTest();
        // Both callers are right and neither can see which of them is the one that matters:
        // the pass releases when its chain ends, the finalizer releases when the chain died.
        AAO_RunLease.releaseAndDrain(opp.Id, 'run-a');
        AAO_RunLease.releaseAndDrain(opp.Id, 'run-a');
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Run_Lease__c WHERE AAO_Opportunity__c = :opp.Id],
            'A released deal carries no lease rows at all: a lock is not evidence, so it ' +
            'leaves rather than being retired.'
        );
    }

    @IsTest
    static void AFINALIZERONASURVIVINGSTAGEHOLDSTHEDEAL() {
        deal();
        Id a = src('a'.repeat(64), Datetime.newInstanceGmt(2026, 8, 1, 15, 0, 0));
        AAO_RunLease.acquire(opp.Id, a, 'run-a', 'call 0 resolve');

        Test.startTest();
        // A null context stands in for "the stage returned". The pass crosses one transaction
        // per stage, so a finalizer that released on every stage would hand the deal away
        // mid-pass and let a second run interleave - the race the lease exists to stop,
        // reintroduced by the lease's own release.
        new AAO_RunFinalizer('run-a', a, 'call 0 resolve', opp.Id).execute(null);
        Test.stopTest();

        System.assertEquals(
            'run-a',
            AAO_RunLease.holderOf(opp.Id).AAO_Run_Key__c,
            'The chain continues, so the lease stays.'
        );
    }

    @IsTest
    static void ADEALWITHNOOPPORTUNITYISNEVERSERIALISED() {
        // A Source with no deal has no state a concurrent pass could corrupt, and blocking on
        // a null key would serialise every such artifact in the org against every other.
        System.assertEquals(
            true,
            AAO_RunLease.acquire(null, null, 'run-a', 'call 0 resolve'),
            'No deal, no lock.'
        );
        System.assertEquals(0, [SELECT COUNT() FROM AAO_Run_Lease__c]);
    }
}
