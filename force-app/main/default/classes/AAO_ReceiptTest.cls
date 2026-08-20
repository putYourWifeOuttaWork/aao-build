/**
 * The run receipt's laws.
 *
 * Two of these are the reason the object exists at all and neither is visible in a screenshot: a
 * receipt NEVER breaks the pass it measures, and it never invents a number it did not take. The
 * rest hold the shape the twenty-ninth stamp specified.
 */
@IsTest
private class AAO_ReceiptTest {
    @IsTest
    static void aFAILINGRECEIPTNEVERBREAKSTHERUNITMEASURES() {
        // THE LOAD-BEARING ONE. A receipt is telemetry, so losing a timing is a small loss and
        // losing a pass that made seven model calls is not. Every failure mode here has to
        // return null rather than throw, and the cheapest way to prove it is to hand it inputs
        // that cannot possibly resolve.
        Test.startTest();
        System.assertEquals(
            null, AAO_Receipt.record(null, null, 'call 1 locate', null),
            'No run key and no Source is a no-op, not an exception.'
        );
        System.assertEquals(
            null, AAO_Receipt.record('r1', null, 'call 1 locate', null),
            'A missing Source writes nothing rather than throwing into the pass.'
        );
        System.assertEquals(
            null, AAO_Receipt.record('r1', AAO_FakeId.of(AAO_Source__c.SObjectType), null, null),
            'An unnamed stage writes nothing.'
        );
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM AAO_Run_Receipt__c]);
    }

    @IsTest
    static void oneROWPERSOURCEPERPASSANDSTAGESMERGEINTOIT() {
        Fixture f = fixture();

        // The mark rides the WRITE, not the fixture, so it has to be on while the receipt is
        // written. A real pass has it off and the row is correctly unmarked.
        AAO_Synthetic.MARK = true;
        Test.startTest();
        AAO_Receipt.record(f.runKey, f.sourceId, AAO_Receipt.STAGE_LOCATE, call(31200, 0));
        AAO_Receipt.record(f.runKey, f.sourceId, AAO_Receipt.STAGE_VERIFY, call(15100, 0));
        AAO_Receipt.record(f.runKey, f.sourceId, AAO_Receipt.STAGE_JOIN, 4700L, 17);
        Test.stopTest();
        AAO_Synthetic.MARK = false;

        List<AAO_Run_Receipt__c> rows = [
            SELECT AAO_Receipt_Key__c, AAO_Stage_Count__c, AAO_Callouts__c,
                AAO_Worst_Callout_Ms__c, AAO_Total_Wall_Ms__c, AAO_Cache_State__c,
                AAO_Opportunity__c, AAO_Stages__c, AAO_Synthetic__c
            FROM AAO_Run_Receipt__c
        ];
        System.assertEquals(1, rows.size(), 'THREE STAGES, ONE ROW. That is the whole key.');
        AAO_Run_Receipt__c r = rows[0];
        System.assertEquals(f.runKey + '|' + f.sourceId, r.AAO_Receipt_Key__c);
        System.assertEquals(3, r.AAO_Stage_Count__c);
        System.assertEquals(2, r.AAO_Callouts__c, 'The join made none and is still a leg.');
        System.assertEquals(31200, r.AAO_Worst_Callout_Ms__c, 'The worst is the worst of all.');
        System.assertEquals(
            51000, r.AAO_Total_Wall_Ms__c, 'Serial wall sums the calls plus the code-only stage.'
        );
        System.assertEquals(f.opportunityId, r.AAO_Opportunity__c, 'Denormalised off the Source.');
        System.assert(r.AAO_Synthetic__c, 'Test-authored rows are marked at birth.');
    }

    @IsTest
    static void WARMANYWHEREMAKESTHEWHOLEPASSWARM() {
        // The twenty-eighth stamp: a warm rerun is never reported as cold performance. So the
        // roll-up takes the WEAKER claim, and one warm call is enough to lose the cold label.
        Fixture f = fixture();

        Test.startTest();
        AAO_Receipt.record(f.runKey, f.sourceId, AAO_Receipt.STAGE_LOCATE, call(30000, 0));
        AAO_Run_Receipt__c cold = [SELECT AAO_Cache_State__c FROM AAO_Run_Receipt__c LIMIT 1];
        System.assertEquals('COLD', cold.AAO_Cache_State__c, 'No cache reads is a cold read.');

        AAO_Receipt.record(f.runKey, f.sourceId, AAO_Receipt.STAGE_VERIFY, call(9000, 27436));
        Test.stopTest();

        AAO_Run_Receipt__c warm = [SELECT AAO_Cache_State__c FROM AAO_Run_Receipt__c LIMIT 1];
        System.assertEquals(
            'WARM', warm.AAO_Cache_State__c,
            'One warm call makes the pass warm. It never goes back the other way.'
        );
    }

    @IsTest
    static void aCODEONLYSTAGEISMEASUREDTOOANDREPORTSNOCACHE() {
        // The join has hit SOQL 101 once and DML 81 of 150 once, so it is the leg most worth
        // having on a row. It makes no model call, and reporting it COLD would be claiming a
        // cache state for a stage that has no cache.
        Fixture f = fixture();

        Test.startTest();
        AAO_Receipt.record(f.runKey, f.sourceId, AAO_Receipt.STAGE_JOIN, 4700L, 17);
        Test.stopTest();

        AAO_Run_Receipt__c row = [
            SELECT AAO_Stages__c, AAO_Callouts__c, AAO_Total_Wall_Ms__c
            FROM AAO_Run_Receipt__c LIMIT 1
        ];
        List<AAO_Receipt.Leg> legs = AAO_Receipt.legsOf(row);
        System.assertEquals(1, legs.size());
        System.assertEquals('n/a', legs[0].cache, 'No calls means no cache, not a cold one.');
        System.assertEquals(0, legs[0].callouts);
        System.assertEquals(4700, legs[0].wallMs, 'It measures its own clock.');
        System.assertEquals(17, legs[0].produced);
        System.assertNotEquals(null, legs[0].soql, 'And its governors are still on the record.');
    }

    @IsTest
    static void theGOVERNORSAREREADBEFORETHERECEIPTSPENDSANYOFITSOWN() {
        // A limit reading taken from another transaction is a reading of nothing, and a limit
        // reading taken AFTER this class runs its own query and DML is a reading of this class.
        // So the leg's SOQL count must be what the caller had spent, not what it has spent.
        Fixture f = fixture();

        Test.startTest();
        // Read INSIDE the test block, because startTest resets the governors and a count taken
        // outside it describes the fixture rather than the stage.
        Integer atCallTime = Limits.getQueries();
        AAO_Receipt.record(f.runKey, f.sourceId, AAO_Receipt.STAGE_LOCATE, call(1000, 0));
        Test.stopTest();

        AAO_Run_Receipt__c row = [SELECT AAO_Stages__c FROM AAO_Run_Receipt__c LIMIT 1];
        AAO_Receipt.Leg leg = AAO_Receipt.legsOf(row)[0];
        System.assertEquals(
            atCallTime, leg.soql,
            'The leg carries the STAGE\'S query count, not the receipt\'s own. Got ' + leg.soql +
            ' against ' + atCallTime
        );
    }

    @IsTest
    static void aRECEIPTEXISTINGISTHEDIDWEREADITRECORD() {
        // The twenty-ninth stamp's first job: with no abstention rows anywhere, a transcript
        // with zero claims is otherwise indistinguishable between never-read and
        // read-and-nothing-established. Nothing else in the system can tell them apart.
        Fixture f = fixture();

        Test.startTest();
        AAO_Receipt.record(f.runKey, f.sourceId, AAO_Receipt.STAGE_LOCATE, call(28000, 0));
        Test.stopTest();

        System.assertEquals(
            0, [SELECT COUNT() FROM AAO_Claim__c],
            'This pass established nothing at all.'
        );
        System.assertNotEquals(
            null, AAO_Receipt.forRun(f.opportunityId, f.runKey),
            'And the receipt still proves the artifact was read.'
        );
        System.assertEquals(
            null, AAO_Receipt.forRun(f.opportunityId, 'a-run-that-never-happened'),
            'While a run that never happened has no receipt, which is the other half.'
        );
    }

    @IsTest
    static void theSWITCHOFFWRITESNOTHING() {
        Fixture f = fixture();
        AAO_Receipt.ENABLED = false;

        Test.startTest();
        System.assertEquals(
            null, AAO_Receipt.record(f.runKey, f.sourceId, AAO_Receipt.STAGE_LOCATE, call(1, 0))
        );
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM AAO_Run_Receipt__c]);
        AAO_Receipt.ENABLED = true;
    }

    @IsTest
    static void aPURGETAKESTHERECEIPTWITHTHERUN() {
        // A receipt left behind would claim a pass whose every row is gone, which is the
        // opposite of the did-we-read-it record's job.
        Fixture f = fixture();
        AAO_Receipt.record(f.runKey, f.sourceId, AAO_Receipt.STAGE_LOCATE, call(1000, 0));
        System.assertEquals(1, [SELECT COUNT() FROM AAO_Run_Receipt__c]);

        Test.startTest();
        AAO_Purge.Outcome o = AAO_Purge.run(new Set<String>{ f.runKey }, f.opportunityId);
        Test.stopTest();

        System.assertEquals(1, o.receipts, 'The purge counts what it removed.');
        System.assertEquals(0, [SELECT COUNT() FROM AAO_Run_Receipt__c]);
    }

    // ============================================ the 141st's riders

    @IsTest
    static void aFailedLegPricesTheCalloutsItAlreadyPaidFor() {
        // RCPT-00000055 carried `callouts: 2` on two stage rows with every token field null:
        // four paid model calls billed as zero, on the run that most needed pricing. The
        // success path prices a stage from what it hands back; a stage that throws hands back
        // nothing, so the failure leg reads what AAO_Extract banked as each response arrived.
        Fixture f = fixture();
        AAO_Extract.clearLegObservations();
        AAO_Extract.sinceLastLeg.inputTokens = 944;
        AAO_Extract.sinceLastLeg.outputTokens = 24;
        AAO_Extract.sinceLastLeg.cacheReadTokens = 2330;
        AAO_Extract.sinceLastLeg.cacheCreationTokens = 17;
        AAO_Extract.sinceLastLeg.thinkingTokens = 5;

        Test.startTest();
        AAO_Receipt.recordFailure(f.runKey, f.sourceId, 'call 0 resolve', 'it went wrong');
        Test.stopTest();

        AAO_Run_Receipt__c row = [
            SELECT AAO_Input_Tokens__c, AAO_Output_Tokens__c, AAO_Thinking_Tokens__c,
                   AAO_Cache_Read_Tokens__c, AAO_Cache_Write_Tokens__c
            FROM AAO_Run_Receipt__c WHERE AAO_Run_Key__c = :f.runKey LIMIT 1
        ];
        System.assertEquals(944, row.AAO_Input_Tokens__c,
            'A failed leg costs real money and the receipt has to say so.');
        System.assertEquals(24, row.AAO_Output_Tokens__c);
        System.assertEquals(5, row.AAO_Thinking_Tokens__c);
        System.assertEquals(2330, row.AAO_Cache_Read_Tokens__c);
        System.assertEquals(17, row.AAO_Cache_Write_Tokens__c);
        System.assertEquals(0, AAO_Extract.sinceLastLeg.inputTokens,
            'The leg carried the numbers away, so a second failure must not bill them twice.');
    }

    @IsTest
    static void aSuccessfulLegClearsTheBankSoTheErrorPathCannotDoubleBill() {
        Fixture f = fixture();
        AAO_Extract.clearLegObservations();
        AAO_Extract.sinceLastLeg.inputTokens = 100;

        Test.startTest();
        AAO_Receipt.record(
            f.runKey, f.sourceId, 'call 1 locate read 1',
            new List<AAO_Extract.StageResult>{ call(10, 0) }, 1, 0
        );
        Test.stopTest();

        System.assertEquals(0, AAO_Extract.sinceLastLeg.inputTokens,
            'Anything banked before a successful leg is on the receipt already. What accrues ' +
            'after it belongs to whatever comes next.');
    }

    @IsTest
    static void aResumeThatFailsAgainCannotRenderIdenticallyToTheFirstStop() {
        // The rider. The resume DID reach the surface - `progress` already took the last leg
        // per stage. What it could not do was look different, and a second failure that
        // renders identically to the first is silence whatever the receipt holds.
        Fixture f = fixture();
        AAO_Receipt.recordFailure(f.runKey, f.sourceId, 'call 0 resolve', 'yes to ACCOUNT');

        Test.startTest();
        AAO_DemoController.RunView first =
            AAO_DemoController.progress(f.opportunityId, f.runKey);
        AAO_Receipt.recordFailure(f.runKey, f.sourceId, 'call 0 resolve', 'yes to OPPORTUNITY');
        AAO_DemoController.RunView second =
            AAO_DemoController.progress(f.opportunityId, f.runKey);
        Test.stopTest();

        System.assertEquals(1, first.stoppedAttempts);
        System.assertEquals(2, second.stoppedAttempts,
            'Every error leg is counted, not only the surviving one, because the count is ' +
            'the thing that changes when a resume fails again.');
        System.assertNotEquals(
            first.stoppedBecause,
            second.stoppedBecause,
            'Two failures of one stage must not read the same, or the human\'s only honest ' +
            'conclusion from an unchanged surface is that the resume did nothing.'
        );
        System.assert(second.stoppedBecause.contains('attempt 2'), second.stoppedBecause);
        System.assertNotEquals(null, second.stoppedAt, 'A repeat failure carries its clock.');
    }

    @IsTest
    static void aFailedLegKeepsTheResponseItFailedOn() {
        // The 141st cost a reproduction harness because the record kept nothing. A short
        // response is kept whole, which is the call-0 case that started this.
        Fixture f = fixture();
        AAO_Extract.clearLegObservations();
        AAO_Extract.lastResponse = '{"opportunity_content_quote":"","carries":true}';

        Test.startTest();
        AAO_Receipt.recordFailure(f.runKey, f.sourceId, 'call 0 resolve', 'quoted nothing');
        Test.stopTest();

        List<AAO_Receipt.Leg> legs = AAO_Receipt.legsOf(
            [SELECT AAO_Stages__c FROM AAO_Run_Receipt__c WHERE AAO_Run_Key__c = :f.runKey LIMIT 1]
        );
        System.assertEquals(1, legs.size());
        System.assertEquals(
            '{"opportunity_content_quote":"","carries":true}',
            legs[0].failedResponse,
            'A response that fits is kept entire, or the next diagnosis reads a fragment.'
        );
        System.assertEquals(null, AAO_Extract.lastResponse,
            'The leg carried it away, so a later failure cannot be handed this one.');
    }

    @IsTest
    static void aKeptResponseIsBoundedAndSaysSoRatherThanLookingShort() {
        // The stage array's overflow guard DROPS EARLIER LEGS to make room, so an unbounded
        // response would buy one diagnosis by destroying the history around it. And a
        // truncated response that reads as a short one is the silent-wrong-answer shape.
        Fixture f = fixture();
        AAO_Extract.clearLegObservations();
        AAO_Receipt.RESPONSE_KEPT_CHARS = 50;
        AAO_Extract.lastResponse = 'x'.repeat(400);

        Test.startTest();
        AAO_Receipt.recordFailure(f.runKey, f.sourceId, 'call 1 locate read 1', 'it broke');
        Test.stopTest();

        List<AAO_Receipt.Leg> legs = AAO_Receipt.legsOf(
            [SELECT AAO_Stages__c FROM AAO_Run_Receipt__c WHERE AAO_Run_Key__c = :f.runKey LIMIT 1]
        );
        String kept = legs[0].failedResponse;
        System.assert(kept.startsWith('x'.repeat(50)), kept);
        System.assert(
            kept.contains('truncated at 50 of 400'),
            'The cut must be visible in the text. A reader who cannot tell a truncated ' +
            'response from a short one will diagnose the wrong thing. Got: ' + kept
        );
    }

    // ------------------------------------------------------------------------ helpers

    private class Fixture {
        String runKey = 'receipt01';
        Id sourceId;
        Id opportunityId;
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Fixture f = new Fixture();
        Account a = new Account(Name = 'AAO Receipt Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Receipt Deal', AccountId = a.Id, StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        f.opportunityId = o.Id;
        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = o.Id, AAO_Account__c = a.Id, AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c =
                '00000000000000000000000000000000000000000000000000000000000000ab',
            AAO_Part_Index__c = 1, AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = 'buyer\tWe will evaluate it.',
            AAO_Diarization__c = 'Attributed',
            // The normalizer stamp is the WRITER'S, never a caller's: supplying one leaves the
            // caller holding a stale value and its next edit is refused as an immutability
            // violation. The trigger composes it, and the receipt copies whatever it composed.
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 8, 12, 15, 0, 0),
            AAO_Synthetic__c = true
        );
        insert src;
        f.sourceId = src.Id;
        AAO_Synthetic.MARK = false;
        return f;
    }

    private static AAO_Extract.StageResult call(Integer ms, Integer cacheRead) {
        AAO_Extract.StageResult r = new AAO_Extract.StageResult();
        r.elapsedMs = ms;
        r.charter = 'AAO_LocateCharter';
        r.charterVersion = 'locate-3.0.0';
        r.usage = new AAO_Extract.Usage();
        r.usage.cacheReadTokens = cacheRead;
        return r;
    }
}