/**
 * The criteria path, end to end: the criterion as the subject, the byte-range join between the
 * three contracts, and the projection that only whole criteria reach.
 */
@IsTest
private class AAO_CriteriaTest {
    private static final String RUN = 'critrun0001';

    // ============================================================ the key and the join

    @IsTest
    static void theSameCriterionVoicedTwiceIsOneCriterion() {
        Id opp = AAO_FakeId.of(Opportunity.SObjectType);
        System.assertEquals(
            AAO_Criteria.key(opp, 'Must pass InfoSec'),
            AAO_Criteria.key(opp, '  must   pass infosec '),
            'Case and whitespace only. A spelling difference must not do the work of a ' +
            'distinction, and that is what makes reinforcement countable.'
        );
        System.assertNotEquals(
            AAO_Criteria.key(opp, 'Must pass InfoSec'),
            AAO_Criteria.key(opp, 'Must pass legal review'),
            'And normalizing further would start deciding two criteria are one, which is a ' +
            'judgment rather than a key.'
        );
        System.assertNotEquals(
            AAO_Criteria.key(opp, 'Must pass InfoSec'),
            AAO_Criteria.key(AAO_FakeId.of(Opportunity.SObjectType), 'Must pass InfoSec'),
            'A criterion is a deal artifact, so the key is scoped to the deal.'
        );
    }

    @IsTest
    static void aTypingClauseBelongsToTheNamingItsSpanOverlaps() {
        Id src = AAO_FakeId.of(AAO_Source__c.SObjectType);
        List<AAO_Criteria.Span> namings = new List<AAO_Criteria.Span>{
            new AAO_Criteria.Span(src, 100, 200),
            new AAO_Criteria.Span(src, 400, 500)
        };
        System.assertEquals(
            0,
            AAO_Criteria.namingFor(new AAO_Criteria.Span(src, 120, 160), namings),
            'Contained: a typing clause sits inside the sentence that named the criterion.'
        );
        System.assertEquals(
            1,
            AAO_Criteria.namingFor(new AAO_Criteria.Span(src, 450, 600), namings),
            'Partial overlap is the same evidence.'
        );
        System.assertEquals(
            null,
            AAO_Criteria.namingFor(new AAO_Criteria.Span(src, 250, 300), namings),
            'And a typing that overlaps nothing types nothing, which is counted rather than ' +
            'attached to whichever criterion was nearest.'
        );
        System.assertEquals(
            null,
            AAO_Criteria.namingFor(
                new AAO_Criteria.Span(AAO_FakeId.of(AAO_Source__c.SObjectType), 120, 160),
                namings
            ),
            'Byte ranges only compare within one artifact.'
        );
    }

    @IsTest
    static void aCriterionTooLongForTheVendorFieldRefusesRatherThanTruncating() {
        Id opp = AAO_FakeId.of(Opportunity.SObjectType);
        try {
            AAO_Criteria.mint('x'.repeat(300), opp, null, null, null, null);
            System.assert(false, 'Expected a refusal.');
        } catch (AAO_Criteria.CriteriaException e) {
            System.assert(
                e.getMessage().contains('the buyer did not say'),
                'Truncating would publish a sentence the buyer did not say under their ' +
                'name, which is the edge of the paraphrase law. Got: ' + e.getMessage()
            );
        }
    }

    // ========================================== three criteria from one person, at last

    @IsTest
    static void onePersonNamingThreeCriteriaProducesThree() {
        // THE DEFECT THIS RULING CLOSES. The answer key is subject plus contract, so with the
        // person as subject a buyer naming three criteria produced ONE answer on AAO_DC_N and
        // two of the three vanished with nothing reporting it.
        Fixture f = fixture();
        pair(f, 'de1', AAO_P8Codes.CRITERION_NAMING, 'Must pass InfoSec', 0);
        pair(f, 'de2', AAO_P8Codes.CRITERION_NAMING, 'Must integrate with SAP', 1);
        pair(f, 'de3', AAO_P8Codes.CRITERION_NAMING, 'Onboarding inside 30 days', 2);

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        System.assertEquals(3, o.criteriaMinted, o.toString());
        System.assertEquals(
            3,
            [SELECT COUNT() FROM AAO_Criterion__c WHERE AAO_Opportunity__c = :f.oppId]
        );
        System.assertEquals(
            3,
            [
                SELECT COUNT()
                FROM AAO_Answer__c
                WHERE AAO_Opportunity__c = :f.oppId
                    AND AAO_Subject_Type__c = 'Decision_Criterion'
            ],
            'One answer row per criterion, which is the ruling.'
        );
        for (AAO_Answer__c a : [
            SELECT AAO_Criterion__c, AAO_Participant__c, AAO_Answer_Key__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :f.oppId AND AAO_Subject_Type__c = 'Decision_Criterion'
        ]) {
            System.assertNotEquals(null, a.AAO_Criterion__c, 'The criterion is the subject.');
            System.assertEquals(
                f.participantId,
                a.AAO_Participant__c,
                'And the person stays on the row as OWNER, never as key - without them a ' +
                'criterion loses the one thing that makes it actionable.'
            );
            System.assert(
                a.AAO_Answer_Key__c.contains('Decision_Criterion'),
                'Got: ' + a.AAO_Answer_Key__c
            );
        }
    }

    @IsTest
    static void typingAndGatingLandOnTheCriterionTheyOverlap() {
        Fixture f = fixture();
        pair(f, 'de1', AAO_P8Codes.CRITERION_NAMING, 'Must pass InfoSec', 0);
        // Same span as the naming: one quote, two contracts, which is the a17 grading's own
        // specimen (deq1 and deq2 at offset 14315).
        pair(f, 'de2', AAO_P8Codes.CRITERION_FORMAL, 'FORMAL', 0);
        pair(f, 'de3', AAO_P8Codes.CRITERION_REQUIRED, 'REQUIRED', 0);

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        System.assertEquals(1, o.criteriaMinted, o.toString());
        System.assertEquals(0, o.criteriaUnattached, o.toString());
        AAO_Criterion__c c = [
            SELECT AAO_Type__c, AAO_Required__c, AAO_Subject__c
            FROM AAO_Criterion__c
            WHERE AAO_Opportunity__c = :f.oppId
        ];
        System.assertEquals('Formal', c.AAO_Type__c, 'Typed by provenance.');
        System.assertEquals(true, c.AAO_Required__c, 'Gate language was spoken.');
    }

    @IsTest
    static void aTypingWithNoNamingIsCountedRatherThanSwallowed() {
        Fixture f = fixture();
        pair(f, 'de1', AAO_P8Codes.CRITERION_FORMAL, 'FORMAL', 0);

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        System.assertEquals(0, o.criteriaMinted);
        System.assertEquals(1, o.criteriaUnattached, o.toString());
        System.assert(
            o.toString().contains('types no criterion'),
            'Two stages disagreeing about one sentence is a thing a count should surface. ' +
            'Got: ' + o.toString()
        );
    }

    // ========================================================== the projection

    @IsTest
    static void onlyWholeCriteriaReachTheVendorObject() {
        Fixture f = fixture();
        pair(f, 'de1', AAO_P8Codes.CRITERION_NAMING, 'Must pass InfoSec', 0);
        pair(f, 'de2', AAO_P8Codes.CRITERION_NAMING, 'Might matter later', 1, 'Partial');

        Test.startTest();
        AAO_PairCommit.run(RUN, new Set<String>());
        AAO_Project.Outcome o = AAO_Project.run(f.oppId);
        Test.stopTest();

        System.assertEquals(1, o.criteriaProjected, o.toString());
        System.assertEquals(
            1,
            o.criteriaHeldPartial,
            'A partial accrues safely and PLACES NOBODY, and a vendor row is a placement. It ' +
            'stands as UNVERIFIED with its receipts on our own rows and is counted here.'
        );
        List<ALTF__Decision_Criteria__c> written = [
            SELECT Name, ALTF__Subject__c, ALTF__Type__c, ALTF__Required__c, ALTF__Opportunity__c
            FROM ALTF__Decision_Criteria__c
            WHERE ALTF__Opportunity__c = :f.oppId
        ];
        System.assertEquals(1, written.size());
        System.assertEquals('Must pass InfoSec', written[0].ALTF__Subject__c);
        System.assertEquals(
            'Informal',
            written[0].ALTF__Type__c,
            'A naming with no attribution defaults Informal and is not a failure.'
        );
        System.assertEquals(
            String.valueOf(written[0].Id).substring(0, 15),
            written[0].Name,
            'The convention that is invisible from the schema and silently breaks a record: ' +
            'Name holds the record\'s own Id.'
        );
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM ALTF__Decision_Criteria_Contact__c
                WHERE ALTF__Decision_Criteria__c = :written[0].Id
            ],
            'And the holder junction, which is attribution a recorded call hands us free.'
        );
    }

    @IsTest
    static void aSecondPassDoesNotWriteTheCriterionAgain() {
        Fixture f = fixture();
        pair(f, 'de1', AAO_P8Codes.CRITERION_NAMING, 'Must pass InfoSec', 0);

        Test.startTest();
        AAO_PairCommit.run(RUN, new Set<String>());
        AAO_Project.run(f.oppId);
        AAO_Project.Outcome again = AAO_Project.run(f.oppId);
        Test.stopTest();

        System.assertEquals(0, again.criteriaProjected);
        System.assertEquals(1, again.criteriaAlreadyProjected, again.toString());
        System.assertEquals(
            1,
            [SELECT COUNT() FROM ALTF__Decision_Criteria__c WHERE ALTF__Opportunity__c = :f.oppId],
            'The vendor object carries no external id to upsert against, so the watermark we ' +
            'wrote is the only record that we already wrote one.'
        );
    }

    // ================================================== retirement, never deletion

    @IsTest
    static void aNamelessNamingMintsNothingAndIsCounted() {
        // A naming pair from a pre-3.1.0 run carries no name. Minting the placeholder
        // again would recreate the collapsed row the twenty-seventh stamp retires, so the
        // pair mints nothing, counted, with the reason on the record.
        Fixture f = fixture();
        AAO_Synthetic.MARK = true;
        String quote = QUOTES[0];
        Integer start = TEXT.indexOf(quote);
        AAO_Pair__c located = new AAO_Pair__c(
            AAO_Run_Key__c = RUN,
            AAO_Pair_Ref__c = 'de1',
            AAO_Stage__c = 'Located',
            AAO_Charter__c = 'AAO_LocateCharter',
            AAO_Charter_Version__c = 'locate-3.0.0',
            AAO_Source__c = f.sourceId,
            AAO_Evidence_Contract__c = f.contracts.get(AAO_P8Codes.CRITERION_NAMING),
            AAO_Answer_Text__c = quote,
            AAO_Meaning__c = 'CRITERION',
            AAO_Coverage__c = 'Full',
            AAO_Start_Offset__c = start,
            AAO_End_Offset__c = start + quote.length(),
            AAO_Speaker_Key__c = 'buyer',
            AAO_Occurrence__c = 1,
            AAO_Occurrence_Count__c = 1,
            AAO_Pair_Key__c = AAO_PairKey.compose(RUN, 'de1', 'Located'),
            AAO_Synthetic__c = true
        );
        insert located;
        insert new AAO_Pair__c(
            AAO_Run_Key__c = RUN,
            AAO_Pair_Ref__c = 'de1',
            AAO_Stage__c = 'Identified',
            AAO_Charter__c = 'AAO_IdentifyCharter',
            AAO_Charter_Version__c = 'identify-1.0.0',
            AAO_Located_Pair__c = located.Id,
            AAO_Evidence_Contract__c = f.contracts.get(AAO_P8Codes.CRITERION_NAMING),
            AAO_Disposition__c = 'Identified',
            AAO_Person__c = f.participantId,
            AAO_Verification__c = 'Upheld',
            AAO_Pair_Key__c = AAO_PairKey.compose(RUN, 'de1', 'Identified'),
            AAO_Synthetic__c = true
        );
        AAO_Synthetic.MARK = false;

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        System.assertEquals(0, o.criteriaMinted, o.toString());
        System.assert(
            o.toString().contains('mints no criterion') ||
                String.join(o.refusals, ' ').contains('mints no criterion'),
            'The reason is on the record. Got: ' + o.toString()
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Criterion__c WHERE AAO_Opportunity__c = :f.oppId],
            'The placeholder is never minted again.'
        );
    }

    @IsTest
    static void aRetiredCriterionIsNeverResurrectedByAMint() {
        Fixture f = fixture();
        AAO_Synthetic.MARK = true;
        AAO_Criterion__c c = AAO_Criteria.mint(
            'Must pass InfoSec', f.oppId, f.acctId, null, null, null
        );
        update new AAO_Criterion__c(
            Id = c.Id,
            AAO_Retired__c = true,
            AAO_Retired_Because__c = 'Test retirement.'
        );

        try {
            AAO_Criteria.mint('Must pass InfoSec', f.oppId, f.acctId, null, null, null);
            System.assert(false, 'Expected a refusal.');
        } catch (AAO_Criteria.CriteriaException e) {
            System.assert(
                e.getMessage().contains('RETIRED'),
                'The upsert would silently un-retire the row. Got: ' + e.getMessage()
            );
        }
        AAO_Synthetic.MARK = false;
    }

    @IsTest
    static void aRetiredCriterionNeverProjects() {
        Fixture f = fixture();
        pair(f, 'de1', AAO_P8Codes.CRITERION_NAMING, 'Must pass InfoSec', 0);

        Test.startTest();
        AAO_PairCommit.run(RUN, new Set<String>());
        AAO_Criterion__c c = [
            SELECT Id FROM AAO_Criterion__c WHERE AAO_Opportunity__c = :f.oppId
        ];
        AAO_Synthetic.MARK = true;
        update new AAO_Criterion__c(
            Id = c.Id,
            AAO_Retired__c = true,
            AAO_Retired_Because__c = 'Test retirement before projection.'
        );
        AAO_Synthetic.MARK = false;
        AAO_Project.Outcome o = AAO_Project.run(f.oppId);
        Test.stopTest();

        System.assertEquals(0, o.criteriaProjected, o.toString());
        System.assertEquals(
            0,
            [SELECT COUNT() FROM ALTF__Decision_Criteria__c WHERE ALTF__Opportunity__c = :f.oppId],
            'Shipping a retired criterion would put the retired mistake on the customer\'s map.'
        );
    }

    // ---------------------------------------------------------------------- fixture

    private class Fixture {
        Id oppId;
        Id acctId;
        Id contactId;
        Id sourceId;
        Id participantId;
        Map<String, Id> contracts = new Map<String, Id>();
    }

    private static final String TEXT =
        'buyer\tWe must pass InfoSec. And integrate with SAP. And onboard inside thirty days.';

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Fixture f = new Fixture();
        Account a = new Account(Name = 'AAO Criteria Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Criteria Test Deal', AccountId = a.Id, StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        Contact c = new Contact(
            FirstName = 'Mapped', LastName = 'Buyer', AccountId = a.Id,
            Email = 'critbuyer@customer.example'
        );
        insert c;
        f.acctId = a.Id;
        f.oppId = o.Id;
        f.contactId = c.Id;

        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = o.Id,
            AAO_Account__c = a.Id,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c =
                '00000000000000000000000000000000000000000000000000000000000000cc',
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = TEXT,
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 6, 17, 15, 0, 0),
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{
                    'speakers' => new List<Object>{
                        new Map<String, Object>{
                            'key' => 'buyer',
                            'display' => 'Mapped Buyer',
                            'email' => 'critbuyer@customer.example',
                            'contactId' => c.Id
                        }
                    }
                }
            ),
            AAO_Synthetic__c = true
        );
        insert src;
        f.sourceId = src.Id;
        f.participantId = [
            SELECT Id FROM AAO_Participant__c WHERE AAO_Source__c = :src.Id LIMIT 1
        ].Id;

        AAO_PassContracts.mint();
        for (AAO_Evidence_Contract__c ec : [
            SELECT Id, AAO_Proposition_Code__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Rubric_Version__c = :AAO_PassContracts.RUBRIC_VERSION
                AND AAO_Contract_State__c != 'Superseded'
        ]) {
            f.contracts.put(ec.AAO_Proposition_Code__c, ec.Id);
        }
        AAO_Synthetic.MARK = false;
        return f;
    }

    /** The three quotes, at three distinct byte ranges, so the overlap join is exercised. */
    private static final List<String> QUOTES = new List<String>{
        'We must pass InfoSec.',
        'And integrate with SAP.',
        'And onboard inside thirty days.'
    };

    private static void pair(Fixture f, String ref, String code, String meaning, Integer quoteAt) {
        pair(f, ref, code, meaning, quoteAt, 'Full');
    }

    private static void pair(
        Fixture f, String ref, String code, String meaning, Integer quoteAt, String coverage
    ) {
        AAO_Synthetic.MARK = true;
        String quote = QUOTES[quoteAt];
        Integer start = TEXT.indexOf(quote);
        AAO_Pair__c located = new AAO_Pair__c(
            AAO_Run_Key__c = RUN,
            AAO_Pair_Ref__c = ref,
            AAO_Stage__c = 'Located',
            AAO_Charter__c = 'AAO_LocateCharter',
            AAO_Charter_Version__c = 'locate-3.1.0',
            AAO_Source__c = f.sourceId,
            AAO_Evidence_Contract__c = f.contracts.get(code),
            AAO_Answer_Text__c = quote,
            AAO_Meaning__c = code == AAO_P8Codes.CRITERION_NAMING ? 'CRITERION' : meaning,
            // The criterion's identity is its name (3.1.0). The fixture's old habit of
            // writing the name into Meaning is what the collapsed-row defect looked like
            // from inside a test, so the name now rides its own field.
            AAO_Criterion_Name__c =
                code == AAO_P8Codes.CRITERION_NAMING ? meaning : null,
            AAO_Coverage__c = coverage,
            AAO_Start_Offset__c = start,
            AAO_End_Offset__c = start + quote.length(),
            AAO_Speaker_Key__c = 'buyer',
            AAO_Occurrence__c = 1,
            AAO_Occurrence_Count__c = 1,
            AAO_Pair_Key__c = AAO_PairKey.compose(RUN, ref, 'Located'),
            AAO_Synthetic__c = true
        );
        insert located;
        insert new AAO_Pair__c(
            AAO_Run_Key__c = RUN,
            AAO_Pair_Ref__c = ref,
            AAO_Stage__c = 'Identified',
            AAO_Charter__c = 'AAO_IdentifyCharter',
            AAO_Charter_Version__c = 'identify-1.0.0',
            AAO_Located_Pair__c = located.Id,
            AAO_Evidence_Contract__c = f.contracts.get(code),
            AAO_Disposition__c = 'Identified',
            AAO_Person__c = f.participantId,
            AAO_Verification__c = 'Upheld',
            AAO_Pair_Key__c = AAO_PairKey.compose(RUN, ref, 'Identified'),
            AAO_Synthetic__c = true
        );
        AAO_Synthetic.MARK = false;
    }
}