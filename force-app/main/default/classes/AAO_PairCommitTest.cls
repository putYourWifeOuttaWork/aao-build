/**
 * The pairs-to-writer join.
 *
 * These are write-leg tests all the way down, because the whole class is a join between two
 * real ledgers and there is nothing pure to assert in memory. The fixture builds the pass's
 * own output shape - a Source, the declared contracts, a located pair and its identified row -
 * and then asks whether a claim and an answer exist on the other side.
 */
@IsTest
public class AAO_PairCommitTest {
    // PUBLIC so `AAO_RetireTest` can build a claim the pass actually produced rather than a
    // row shaped like one. A hand-built fixture is a row the product never emits, and that
    // mistake has already been made twice on this build - duplicating this one to keep the
    // class private would be making it a third time on purpose.
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

    /**
     * THE a23 DEFECT, as a law. `buq7` upheld a Buyer Role EVALUATOR on our own seller and
     * projection created her a Contact on the customer's account. a22 met the same shape and
     * call 3 happened to refuse it, which is luck rather than a rule.
     *
     * Asserted with the verdict UPHELD deliberately: the point is that the reader's answer
     * is not consulted. A seller is not a member of the buying committee by construction.
     */
    @IsTest
    static void aClaimAboutASellerIsRefusedEvenWhenTheVerifierUpheldIt() {
        Fixture f = fixture();
        pair(f, 'p1', 'AAO_BR_EVAL', 'EVALUATOR', 'Full', 'Identified', 'Upheld', f.sellerId);

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>{ 'seller.example' });
        Test.stopTest();

        System.assertEquals(1, o.pairsInternalSubject, o.toString());
        System.assertEquals(0, o.pairsEligible, o.toString());
        System.assertEquals(0, o.claimsWritten, o.toString());
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Answer__c WHERE AAO_Opportunity__c = :f.oppId],
            'No answer may exist about a seller.'
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Participant__c = :f.sellerId],
            'And no claim.'
        );
    }

    /**
     * The gate is targeted, not blanket: the same run still commits the buyer-side pair. A
     * guard that also silenced buyers would trade one silent defect for a louder one.
     */
    @IsTest
    static void theSellerGateDoesNotTouchBuyerSideClaims() {
        Fixture f = fixture();
        pair(f, 'p1', 'AAO_BR_EVAL', 'EVALUATOR', 'Full', 'Identified', 'Upheld', f.sellerId);
        pair(f, 'p2', AAO_P8Codes.SENTIMENT, 'SUPPORTER', 'Full', 'Identified', 'Upheld', f.participantId);

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>{ 'seller.example' });
        Test.stopTest();

        System.assertEquals(1, o.pairsInternalSubject, o.toString());
        System.assertEquals(1, o.pairsEligible, o.toString());
        System.assertEquals(1, o.claimsWritten, o.toString());
        System.assertEquals(
            f.participantId,
            [
                SELECT AAO_Participant__c
                FROM AAO_Claim__c
                WHERE AAO_Opportunity__c = :f.oppId
            ].AAO_Participant__c,
            'The one claim written is the buyer\'s.'
        );
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
    static void aVOICEDHEDGENOLONGEROVERRIDESTHEBLINDUPHOLD() {
        // CORRECTED IN PLACE, seventieth stamp, and the correction is the ruling rather than a
        // repair. This test used to assert that a Partial coverage label proposes UNVERIFIED —
        // `aPartialPairProposesUnverifiedSoItAccruesAndPlacesNobody`, encoding "Partial is the
        // instructed default under doubt". Matthew ruled at the sixty-ninth stamp that THE
        // UPHOLD GOVERNS: the blind verifier decides truth and element completeness is recorded
        // as data, never as a verdict gate. A read-side hedge outranking the checker inverted
        // the layering the architecture rests on, and on the twelve single-element contracts
        // "Partial" was not even expressible.
        //
        // What the old test protected is NOT lost and is asserted below: the accrual still
        // carries its receipts, and the writer still places nobody except on TRUE.
        Fixture f = fixture();
        pair(f, 'p1', 'AAO_POL_IC1', 'Inner Circle', 'Partial', 'Identified', 'Upheld', f.participantId);

        Test.startTest();
        AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        AAO_Answer__c a = [
            SELECT AAO_Verdict__c, AAO_Spans__c, AAO_Element_Completeness__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :f.oppId
        ];
        System.assertEquals(
            'TRUE',
            a.AAO_Verdict__c,
            'The verifier upheld these words, so the answer reads TRUE whatever the read voiced.'
        );
        System.assert(
            a.AAO_Spans__c != null && a.AAO_Spans__c.contains('escalate'),
            'It still carries its receipts. Got: ' + a.AAO_Spans__c
        );
        System.assert(
            String.isNotBlank(a.AAO_Element_Completeness__c),
            'And completeness is still RECORDED, which is the half that survives the ruling. ' +
            'Got: ' + a.AAO_Element_Completeness__c
        );
        System.assertEquals(
            'Inner Circle',
            AAO_Project.run(f.oppId).people[0].political,
            'An upheld establishment now places, which is the visible consequence of the ruling.'
        );
    }

    @IsTest
    static void sentimentIsWholeByConstructionAndNeverGradedPartial() {
        // Addendum 19's first ruling, and the defect behind it was MINE rather than the
        // charter's: the sentiment family read's schema carries no `coverage` property at
        // all, so the a17 pairs came back with coverage null exactly as they should, and
        // this class read null as "not Full" and downgraded every sentiment establishment to
        // UNVERIFIED. The counter then stood at zero for everyone and the map carried no
        // Support value at all.
        Fixture f = fixture();
        pair(f, 'p1', AAO_P8Codes.SENTIMENT, 'SUPPORTER', null, 'Identified', 'Upheld', f.participantId);

        Test.startTest();
        AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        AAO_Answer__c a = [
            SELECT AAO_Verdict__c, AAO_Support_Counter__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :f.oppId
        ];
        System.assertEquals(
            'TRUE',
            a.AAO_Verdict__c,
            'A sentiment read is whole: the words voice one of four states or they produce ' +
            'no pair. There is no partial supportiveness to grade.'
        );
        System.assertEquals(1, a.AAO_Support_Counter__c, 'unit: counter steps');
        System.assertEquals(
            false,
            AAO_LocateCharter.takesCoverage(AAO_P8Codes.SENTIMENT),
            'And the one place that knows which questions take coverage says so, rather ' +
            'than this rule being written out twice and drifting.'
        );
    }

    @IsTest
    static void aPartialNeverDisplacesAnEstablishmentItArrivesAfter() {
        // THE a20 DEFECT, from the rows. `buq4` arrived Partial and Upheld after `buq1` had
        // established Jefferson's Evaluator answer TRUE from Full evidence, and the answer
        // went TRUE to UNVERIFIED. `poq5` did the same to his Political Structure half, and
        // that demotion flowed through the ceiling and changed his placement on the map.
        Fixture f = fixture();
        pair(f, 'p1', 'AAO_BR_EVAL', 'EVALUATOR', 'Full', 'Identified', 'Upheld', f.participantId);
        pair(f, 'p2', 'AAO_BR_EVAL', 'EVALUATOR', 'Partial', 'Identified', 'Upheld', f.participantId);

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        System.assertEquals(2, o.claimsWritten, o.toString());
        AAO_Answer__c a = [
            SELECT AAO_Verdict__c, AAO_Spans__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :f.oppId
        ];
        System.assertEquals(
            'TRUE',
            a.AAO_Verdict__c,
            'Partial accrues, places nobody, and DISPLACES NOTHING. An answer verdict is ' +
            'monotone over evidence strength, never last-write-wins.'
        );
        System.assertEquals(
            2,
            [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c = :f.oppId],
            'And the accrual is not discarded: it writes its claim and merges its spans. ' +
            'What it may not do is take a standing establishment down with it.'
        );
    }

    @IsTest
    static void theReplayLandsOnTheSameVerdictWhicheverOrderThePairsCommittedIn() {
        // The write-time guard depends on arrival order; the replay does not. Both exist so
        // that a run committing its pairs in any sequence lands on the same verdict, which is
        // the replay invariant made executable rather than asserted.
        Fixture f = fixture();
        pair(f, 'p1', 'AAO_BR_EVAL', 'EVALUATOR', 'Partial', 'Identified', 'Upheld', f.participantId);
        pair(f, 'p2', 'AAO_BR_EVAL', 'EVALUATOR', 'Full', 'Identified', 'Upheld', f.participantId);

        Test.startTest();
        AAO_PairCommit.Outcome o = AAO_PairCommit.run(RUN, new Set<String>());
        Test.stopTest();

        System.assertEquals(
            'TRUE',
            [SELECT AAO_Verdict__c FROM AAO_Answer__c WHERE AAO_Opportunity__c = :f.oppId]
                .AAO_Verdict__c,
            'Partial first, Full second: the establishment stands either way.'
        );
        System.assert(
            o.toString().contains('verdicts rebuilt'),
            'And the replay reports what it corrected, on its own line. Got: ' + o.toString()
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

    public class Fixture {
        public Id oppId;
        public Id acctId;
        public Id contactId;
        public Id sourceId;
        public Id participantId;
        public Id unlinkedId;
        /** The selling-side participant. Claims about this person must never write. */
        public Id sellerId;
        public Map<String, Id> contracts = new Map<String, Id>();
    }

    public static Fixture fixture() {
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
                        },
                        // The seller in the room. Every real call has one, and until the
                        // 8 August ruling nothing stopped a claim being made ABOUT them.
                        new Map<String, Object>{
                            'key' => 'seller',
                            'display' => 'Wendy Seller',
                            'email' => 'wendy@seller.example'
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
            SELECT Id, AAO_Contact__c, AAO_Email__c
            FROM AAO_Participant__c
            WHERE AAO_Source__c = :src.Id
        ]) {
            // Keyed on email rather than on contact-null, because the seller row is also
            // contact-null and last-wins between two of them would make the fixture lie.
            if (p.AAO_Email__c == 'wendy@seller.example') {
                f.sellerId = p.Id;
            } else if (p.AAO_Contact__c == null) {
                f.unlinkedId = p.Id;
            } else {
                f.participantId = p.Id;
            }
        }
        System.assertNotEquals(null, f.sellerId, 'And the seller who was in the room.');
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
    public static void pair(
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
