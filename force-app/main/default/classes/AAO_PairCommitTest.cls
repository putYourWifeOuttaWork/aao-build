/**
 * The pairs-to-writer join.
 *
 * These are write-leg tests all the way down, because the whole class is a join between two
 * real ledgers and there is nothing pure to assert in memory. The fixture builds the pass's
 * own output shape - a Source, the declared contracts, a located pair and its identified row -
 * and then asks whether a claim and an answer exist on the other side.
 */
@IsTest
private class AAO_PairCommitTest {
    private static final String RUN = 'testrun0001';

    // ============================================================== what crosses, and what does not

    @IsTest
    static void anUpheldIdentifiedPairBecomesAClaimAndAnAnswer() {
        Fixture f = fixture();
        pair(f, 'p1', AAO_P8Codes.SENTIMENT, 'SUPPORTER', 'Full', 'Identified', 'Upheld', f.participantId);

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>{ 'seller.example' });
        Test.stopTest();

        System.assertEquals(1, o.pairsEligible, o.toString());
        System.assertEquals(1, o.claimsWritten, o.toString());
        System.assertEquals(1, o.answersWritten, o.toString());
        System.assertEquals(false, o.committedNothing(), o.toString());

        AAO_Answer__c a = [
            SELECT
                AAO_Subject_Type__c,
                AAO_Participant__c,
                AAO_Subject_Contact__c,
                AAO_Verdict__c,
                AAO_Support_Counter__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :f.oppId
        ];
        System.assertEquals(
            'Participant',
            a.AAO_Subject_Type__c,
            'Claims key the Participant, and the answer keys what its claims key.'
        );
        System.assertEquals(f.participantId, a.AAO_Participant__c);
        System.assertEquals(
            f.contactId,
            a.AAO_Subject_Contact__c,
            'The resolved Contact rides beside the key rather than standing in for it.'
        );
        System.assertEquals('TRUE', a.AAO_Verdict__c);
        System.assertEquals(
            1,
            a.AAO_Support_Counter__c,
            'One supporter-grade establishment is one step. unit: counter steps'
        );

        AAO_Claim__c c = [
            SELECT AAO_Participant__c, AAO_Verdict_After__c, AAO_Interpretation__c
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :f.oppId
        ];
        System.assertEquals(f.participantId, c.AAO_Participant__c);
        System.assertEquals('SUPPORTER', c.AAO_Interpretation__c);
    }

    @IsTest
    static void aRefusedVerificationIsCountedAndWritesNothing() {
        Fixture f = fixture();
        pair(f, 'p1', 'AAO_POL_IC1', 'Inner Circle', 'Full', 'Identified', 'Refused', f.participantId);

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        System.assertEquals(1, o.pairsRead);
        System.assertEquals(0, o.pairsEligible);
        System.assertEquals(1, o.pairsNotUpheld, o.toString());
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c = :f.oppId],
            'The blind reader refused it. A refusal is a disposition the pass made, not an error.'
        );
        System.assertEquals(
            false,
            o.committedNothing(),
            'Nothing was eligible, so nothing failing to commit is not a defect.'
        );
    }

    @IsTest
    static void anUnidentifiedPairIsCountedAndWritesNothing() {
        Fixture f = fixture();
        // No verification either: the ledger's own law refuses one on an Ambiguous row,
        // because the blind reader verifies an identified claim and there is no claim in
        // front of it here.
        pair(f, 'p1', 'AAO_BR_DM', 'Decision Maker', 'Full', 'Ambiguous', null, null);

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        System.assertEquals(1, o.pairsNotIdentified, o.toString());
        System.assertEquals(0, [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c = :f.oppId]);
    }

    @IsTest
    static void aPartialPairProposesUnverifiedSoItAccruesAndPlacesNobody() {
        Fixture f = fixture();
        pair(f, 'p1', 'AAO_POL_IC1', 'Inner Circle', 'Partial', 'Identified', 'Upheld', f.participantId);

        Test.startTest();
        AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        AAO_Answer__c a = [
            SELECT AAO_Verdict__c, AAO_Spans__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :f.oppId
        ];
        System.assertEquals(
            'UNVERIFIED',
            a.AAO_Verdict__c,
            'Partial is the instructed default under doubt, and a partial accrues safely and ' +
            'places nobody.'
        );
        System.assert(
            a.AAO_Spans__c != null && a.AAO_Spans__c.contains('escalate'),
            'It carries its receipts. Got: ' + a.AAO_Spans__c
        );
        System.assertEquals(
            null,
            AAO_Project.run(f.oppId).people[0].political,
            'And the writer places nobody on it: derive() places only on TRUE.'
        );
    }

    // ================================================== a person with no Contact still lands

    @IsTest
    static void aPersonWithNoContactStillGetsAClaimAndAnAnswer() {
        // The ruling's own specimen. Under the retired Contact key this person was
        // unclaimable: the answer key threw on a null subject, so the evidence had nowhere to
        // go and the run simply lost them. Jefferson Vargas is identified on the 17 June
        // fixture and has no Contact record at all.
        Fixture f = fixture();
        pair(f, 'p1', AAO_P8Codes.SENTIMENT, 'SUPPORTER', 'Full', 'Identified', 'Upheld', f.unlinkedId);

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        System.assertEquals(1, o.claimsWritten, o.toString());
        AAO_Answer__c a = [
            SELECT AAO_Participant__c, AAO_Subject_Contact__c, AAO_Answer_Key__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :f.oppId
        ];
        System.assertEquals(f.unlinkedId, a.AAO_Participant__c);
        System.assertEquals(null, a.AAO_Subject_Contact__c, 'No Contact resolved, and none invented.');
        System.assert(
            a.AAO_Answer_Key__c.contains('Participant'),
            'The key names the identity, not the resolution outcome. Got: ' + a.AAO_Answer_Key__c
        );
    }

    // ============================================================ the counter, end to end

    @IsTest
    static void theCounterIsRebuiltFromTheClaimsRatherThanIncremented() {
        Fixture f = fixture();
        pair(f, 'p1', AAO_P8Codes.SENTIMENT, 'SUPPORTER', 'Full', 'Identified', 'Upheld', f.participantId);

        Test.startTest();
        AAO_PairCommit.run(RUN, new Set<String>());
        // Running the same run again must not move the counter. Two mechanisms make that
        // true and both are load-bearing: the pair-grain watermark stops the same words
        // being read twice, and rebuild-from-claims means the counter is a replay rather
        // than an increment, so it could not drift even if something did read twice.
        AAO_PairCommit.Outcome again = AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        System.assertEquals(1, again.pairsAlreadyCommitted, again.toString());
        System.assertEquals(0, again.claimsWritten, 'The same evidence is never read twice.');
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c = :f.oppId],
            'One pair, one claim. A second Reinforced claim from the same words would ' +
            'inflate a count guidance orders by.'
        );
        AAO_Answer__c a = [
            SELECT AAO_Support_Counter__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :f.oppId
        ];
        System.assertEquals(
            1,
            a.AAO_Support_Counter__c,
            'One occasion, one supporter-grade establishment, one step - however many times ' +
            'the join runs over it. unit: counter steps'
        );
    }

    @IsTest
    static void theJoinReportsCommittingNothingRatherThanReportingSuccess() {
        AAO_PairCommit.Outcome o = new AAO_PairCommit.Outcome();
        o.pairsRead = 12;
        o.pairsEligible = 12;
        System.assert(
            o.committedNothing(),
            'Twelve upheld identified pairs producing no claim is the join failing, not the ' +
            'pass finding nothing.'
        );
        String s = o.toString();
        System.assert(s.contains('COMMITTED NOTHING'), 'Got: ' + s);
        System.assert(s.contains('(unit: pairs)'), 'Every counter names its unit. Got: ' + s);
        System.assert(s.contains('(unit: claims)'), 'Got: ' + s);
    }

    @IsTest
    static void anEmptyRunIsSilenceRatherThanASilentFailure() {
        AAO_PairCommit.Outcome o = AAO_PairCommit.run('emptyrun01', new Set<String>());
        System.assertEquals(0, o.pairsRead);
        System.assertEquals(false, o.committedNothing());
        System.assert(!o.toString().contains('COMMITTED NOTHING'));
    }

    @IsTest
    static void aJoinWithNoRunKeyRefusesRatherThanReadingEverything() {
        try {
            AAO_PairCommit.run(null, new Set<String>());
            System.assert(false, 'The arithmetic is per run and meaningless across runs.');
        } catch (AAO_PairCommit.JoinException e) {
            System.assert(e.getMessage().contains('no run key'), e.getMessage());
        }
    }

    // ------------------------------------------------------------------------ fixture

    private static final String QUOTE = 'We would need this to escalate cleanly.';
    private static final String TEXT = 'buyer\t' + QUOTE;

    private class Fixture {
        Id oppId;
        Id acctId;
        Id contactId;
        Id sourceId;
        Id participantId;
        Id unlinkedId;
        Map<String, Id> contracts = new Map<String, Id>();
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Fixture f = new Fixture();

        Account acct = new Account(Name = 'AAO Join Test');
        insert acct;
        Opportunity opp = new Opportunity(
            Name = 'AAO Join Test Deal',
            AccountId = acct.Id,
            StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        Contact c = new Contact(FirstName = 'Mapped', LastName = 'Buyer', AccountId = acct.Id,
            Email = 'buyer@customer.example');
        insert c;
        f.acctId = acct.Id;
        f.oppId = opp.Id;
        f.contactId = c.Id;

        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = opp.Id,
            AAO_Account__c = acct.Id,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c =
                '00000000000000000000000000000000000000000000000000000000000000aa',
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
                            'email' => 'buyer@customer.example',
                            'contactId' => c.Id
                        },
                        new Map<String, Object>{
                            'key' => 'jefferson',
                            'display' => 'Jefferson Vargas',
                            'email' => 'jvargas@customer.example'
                        }
                    }
                }
            ),
            AAO_Synthetic__c = true
        );
        insert src;
        f.sourceId = src.Id;

        // Participation is only ever written by the Source after-insert. Reading the rows back
        // rather than hand-building them is the whole point: a hand-built participant is a row
        // the product never produces, and that mistake has been made twice on this build.
        for (AAO_Participant__c p : [
            SELECT Id, AAO_Contact__c
            FROM AAO_Participant__c
            WHERE AAO_Source__c = :src.Id
        ]) {
            if (p.AAO_Contact__c == null) {
                f.unlinkedId = p.Id;
            } else {
                f.participantId = p.Id;
            }
        }
        System.assertNotEquals(null, f.participantId, 'A participant resolved to the Contact.');
        System.assertNotEquals(null, f.unlinkedId, 'And one with no Contact at all.');

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

    /** The pass's own output shape: a located row, and the identified row that binds to it. */
    private static void pair(
        Fixture f,
        String ref,
        String code,
        String meaning,
        String coverage,
        String disposition,
        String verification,
        Id personId
    ) {
        AAO_Synthetic.MARK = true;
        Integer start = TEXT.indexOf(QUOTE);
        AAO_Pair__c located = new AAO_Pair__c(
            AAO_Run_Key__c = RUN,
            AAO_Pair_Ref__c = ref,
            AAO_Stage__c = 'Located',
            AAO_Charter__c = 'AAO_LocateCharter',
            AAO_Charter_Version__c = 'locate-3.0.0',
            AAO_Source__c = f.sourceId,
            AAO_Evidence_Contract__c = f.contracts.get(code),
            AAO_Answer_Text__c = QUOTE,
            AAO_Meaning__c = meaning,
            AAO_Coverage__c = coverage,
            AAO_Start_Offset__c = start,
            AAO_End_Offset__c = start + QUOTE.length(),
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
            AAO_Disposition__c = disposition,
            AAO_Person__c = personId,
            AAO_Verification__c = verification,
            AAO_Pair_Key__c = AAO_PairKey.compose(RUN, ref, 'Identified'),
            AAO_Synthetic__c = true
        );
        AAO_Synthetic.MARK = false;
    }
}
