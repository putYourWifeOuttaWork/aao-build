/**
 * Day-one red. The behaviours worth asserting are the ones that make the count mean
 * something: that a red exists before any evidence does, that its age is measured from the
 * deal and not from us, that only establishment clears it, and that a deal is red against
 * the rubric it is adjudicated under rather than against every rubric in the org.
 */
@IsTest
private class AAO_FlagsTest {
    private static AAO_Demo.Ctx scaffold() {
        AAO_Ingest.AUTO = false;
        return AAO_Demo.scaffold();
    }

    /**
     * The point of the whole feature. A deal with no evidence on it is not neutral, it is
     * red, and it was red from the moment it existed.
     */
    @IsTest
    static void everyGatingPropositionStandsRedOnADealWithNoEvidence() {
        AAO_Demo.Ctx c = scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);

        Integer gating = [
            SELECT COUNT()
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Gating__c = TRUE AND AAO_Rubric_Version__c = :AAO_Seed.RUBRIC_VERSION
        ];
        System.assert(gating > 0, 'The fixture rubric has gating propositions.');

        System.assertEquals(
            gating,
            AAO_Flags.standing(oppId),
            'An empty deal stands red on every gating proposition. Nothing raised them; ' +
            'they were never down.'
        );

        for (AAO_Flag__c f : [
            SELECT AAO_Type__c, AAO_State__c, AAO_Cause__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :oppId
        ]) {
            System.assertEquals('Methodological', f.AAO_Type__c);
            System.assertEquals('Standing', f.AAO_State__c);
            System.assertEquals(AAO_Flags.CAUSE_UNMET, f.AAO_Cause__c);
        }
    }

    /** Age is how long the DEAL has stood unanswered, not how long since we looked. */
    @IsTest
    static void raisedAtIsDealCreationAndNotTheMomentTheCodeRan() {
        AAO_Demo.Ctx c = scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        Opportunity o = [SELECT CreatedDate FROM Opportunity WHERE Id = :oppId];

        for (AAO_Flag__c f : [
            SELECT AAO_Raised_At__c FROM AAO_Flag__c WHERE AAO_Opportunity__c = :oppId
        ]) {
            System.assertEquals(
                o.CreatedDate,
                f.AAO_Raised_At__c,
                'The trigger stamps now() when this is null, which would make every red ' +
                'look as young as the code that noticed it.'
            );
        }
    }

    /** Calling it again raises nothing. Deal setup is allowed to be re-run. */
    @IsTest
    static void raisingTwiceRaisesNothingTwice() {
        AAO_Demo.Ctx c = scaffold();
        Set<Id> opps = new Set<Id>{ c.oppByDeal.get(AAO_Demo.OPP_LIVE) };
        Integer before = AAO_Flags.standing(c.oppByDeal.get(AAO_Demo.OPP_LIVE));

        Test.startTest();
        Integer raised = AAO_Flags.raiseFor(opps, true);
        Test.stopTest();

        System.assertEquals(0, raised);
        System.assertEquals(before, AAO_Flags.standing(c.oppByDeal.get(AAO_Demo.OPP_LIVE)));
    }

    /**
     * Establishment clears it, and only establishment. This runs the rehearsal, which
     * establishes AAO_T1 TRUE across two passes.
     */
    @IsTest
    static void establishingTrueClearsTheRedAndNothingElseDoes() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1].Id;
        Id contractId = [
            SELECT Id
            FROM AAO_Evidence_Contract__c
            WHERE
                AAO_Proposition_Code__c = 'AAO_T1'
                AND AAO_Rubric_Version__c = :AAO_Seed.RUBRIC_VERSION
            LIMIT 1
        ]
        .Id;

        // CORRECTED IN PLACE, seventieth stamp. This asserted the red still STANDING after pass
        // one, on the retired rule that partial coverage writes UNVERIFIED and so establishes
        // nothing. Matthew ruled THE UPHOLD GOVERNS at the sixty-ninth: pass one's words were
        // upheld, so they establish, and an establishment is what clears a red. THE LAW THE
        // ASSERTION PROTECTED IS UNCHANGED and is still asserted here — only an ESTABLISHMENT
        // clears a red, and nothing else does — which is why the assertion moves rather than goes.
        AAO_Flag__c f = [
            SELECT AAO_State__c, AAO_Cause__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :oppId AND AAO_Evidence_Contract__c = :contractId
            LIMIT 1
        ];
        System.assertEquals(
            'Cleared',
            f.AAO_State__c,
            'An upheld establishment clears the red, and only an establishment does.'
        );

        Test.startTest();
        AAO_Demo.passTwo();
        Test.stopTest();

        f = [
            SELECT AAO_State__c, AAO_Cleared_At__c, AAO_Answer__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :oppId AND AAO_Evidence_Contract__c = :contractId
            LIMIT 1
        ];
        System.assertEquals('Cleared', f.AAO_State__c, 'TRUE clears it.');
        System.assertNotEquals(null, f.AAO_Cleared_At__c, 'Time to clear is measurable.');
        System.assertNotEquals(
            null,
            f.AAO_Answer__c,
            'And the flag names what cleared it, so the clearance is traceable.'
        );
    }

    /**
     * The seller-said-it case, which is the one worth showing. Full element coverage, and
     * the red still stands, because the speaker rule refused to establish it.
     */
    @IsTest
    static void aDowngradedDealKeepsItsRedDespiteFullCoverage() {
        AAO_Ingest.AUTO = false;
        Test.startTest();
        AAO_Demo.passNegative();
        Test.stopTest();

        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_NEGATIVE LIMIT 1].Id;
        AAO_Answer__c a = [
            SELECT AAO_Verdict__c, AAO_Element_Completeness__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :oppId
            LIMIT 1
        ];
        System.assertEquals('UNVERIFIED', a.AAO_Verdict__c);
        System.assertEquals(
            true,
            AAO_Model.parseCoverage(a.AAO_Element_Completeness__c)
                .isFull(new List<String>{ 'e1', 'e2', 'e3' }),
            'Every element was covered.'
        );
        System.assert(
            AAO_Flags.standing(oppId) > 0,
            'And the gating red still stands, because who said it decides whether it ' +
            'establishes, and nothing was established.'
        );
    }

    /**
     * The product path cannot see the fixture. Session 17: a deal answers the org's current
     * active questions, and the seeded rubric is marked synthetic precisely so it is not
     * one of them. Before the rule, an org holding both gave every deal four reds where
     * two were its own.
     */
    @IsTest
    static void seededContractsAreInvisibleToTheProductPath() {
        AAO_Demo.Ctx c = scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        Integer fromFixture = AAO_Flags.standing(oppId);
        System.assert(fromFixture > 0, 'The rehearsal raised its own reds.');

        System.assertEquals(
            0,
            AAO_Rubric.inventory().size(),
            'Nothing unmarked exists yet, so the product set is empty. An empty product ' +
            'set is the cold-start condition, not a view of the fixture.'
        );
        System.assertEquals(
            fromFixture,
            AAO_Flags.standing(oppId),
            'And asking the product set raised nothing new.'
        );

        // A real question, unmarked, the way discovery writes one.
        AAO_Synthetic.MARK = false;
        insert new AAO_Evidence_Contract__c(
            AAO_Question_Record_Id__c = 'PRODUCT_Q1',
            AAO_Proposition_Code__c = 'PRODUCT_1',
            AAO_Proposition_Short__c = 'A real question',
            AAO_Proposition_Text__c = 'A gating proposition the org actually asks.',
            AAO_Guidance_Text__c = 'Real guidance.',
            AAO_Elements__c = '[{"id":"e1","text":"the only part"}]',
            AAO_Element_Count__c = 1,
            AAO_Elements_Basis__c = 'Authored',
            AAO_Route__c = 'E',
            AAO_Speaker_Requirement__c = 'Any_Participant',
            AAO_Decay_Class__c = 'Standing',
            AAO_Gating__c = true,
            AAO_Contract_State__c = 'Ratified',
            AAO_Rubric_Version__c = 'discovered-v1'
        );

        Test.startTest();
        Integer raised = AAO_Flags.raiseFor(new Set<Id>{ oppId });
        Test.stopTest();

        System.assertEquals(1, raised, 'The product set has exactly one gating question.');
        System.assertEquals(
            1,
            AAO_Rubric.inventory().size(),
            'And the fixture is still invisible to it.'
        );
        System.assertEquals(
            fromFixture + 1,
            AAO_Flags.standing(oppId),
            'Both populations can stand on one deal in a test org. Neither can see the ' +
            'other, which is the whole rule.'
        );
    }

    /** The default is the safe one: forgetting the argument gets the product set. */
    @IsTest
    static void theDefaultReadIsTheProductSetNotTheFixture() {
        scaffold();
        System.assert(
            AAO_Rubric.inventory(true).size() > 0,
            'The fixture exists and has to be asked for by name.'
        );
        System.assertEquals(
            0,
            AAO_Rubric.inventory().size(),
            'A reader that forgets the distinction gets the product questions and never ' +
            'the fixture, which is the direction an accident should fail in.'
        );
    }

    // ================================================ (c) · the red-flag family, by stage

    /**
     * **THE ONE THAT MATTERS MOST, and it is the defect (c) closed rather than a new feature.**
     *
     * Under the inversion law a DENIED answer stands at verdict TRUE: the establishment is real
     * and cited to the customer's own affirmative words about the negative. This path used to
     * read the verdict alone, so a customer saying *"there is no budget allocated for this"*
     * would have CLEARED the budget deal-killer, on a TRUE, and the one condition the flag
     * exists to surface would have vanished at the moment it was proven.
     */
    @IsTest
    static void aVoicedNoDOESNOTCLEARTHEFLAGITPROVES() {
        Fixture f = processFixture('AAO_BANT_B1', 'Stage 1');
        answerOn(f, 'TRUE', 'DENIED');

        AAO_Flags.reconcile(f.oppId, f.contractId);

        AAO_Flag__c flag = [
            SELECT AAO_State__c, AAO_Cause__c FROM AAO_Flag__c WHERE Id = :f.flagId
        ];
        System.assertEquals(
            'Standing', flag.AAO_State__c,
            'A voiced no is an establishment, and it establishes the deal-killer rather than ' +
            'answering it away.'
        );
        System.assertEquals(
            AAO_Flags.CAUSE_FALSE, flag.AAO_Cause__c,
            'And it stands for the worse reason: established false, not merely unmet.'
        );
    }

    /** The other half, or the test above passes for a build that never clears anything. */
    @IsTest
    static void anAFFIRMEDANSWERSTILLCLEARS() {
        Fixture f = processFixture('AAO_BANT_B1', 'Stage 1');
        answerOn(f, 'TRUE', 'AFFIRMED');

        AAO_Flags.reconcile(f.oppId, f.contractId);

        System.assertEquals(
            'Cleared',
            [SELECT AAO_State__c FROM AAO_Flag__c WHERE Id = :f.flagId].AAO_State__c,
            'Evidence establishing the affirmative clears it, which is the only way it clears.'
        );
    }

    /**
     * A deal-level flag now faces MANY answers, because Process keys one per person. The
     * hundred-twentieth ruled the tiebreak before the case existed: a voiced no reds at any
     * stage, so one person's yes does not undo another's no.
     */
    @IsTest
    static void aDENIEDANYWHEREOUTRANKSANAFFIRMEDELSEWHERE() {
        Fixture f = processFixture('AAO_BANT_B1', 'Stage 1');
        answerOn(f, 'TRUE', 'AFFIRMED');
        answerFor(f, 'TRUE', 'DENIED', secondPerson(f));

        AAO_Flags.reconcile(f.oppId, f.contractId);

        AAO_Flag__c flag = [
            SELECT AAO_State__c, AAO_Cause__c FROM AAO_Flag__c WHERE Id = :f.flagId
        ];
        System.assertEquals('Standing', flag.AAO_State__c, 'The red stands.');
        System.assertEquals(AAO_Flags.CAUSE_FALSE, flag.AAO_Cause__c, 'And for the worse reason.');
    }

    /** A voiced no reds at any stage, including one long before its own marker. */
    @IsTest
    static void aVOICEDNOREDSATANYSTAGE() {
        Fixture f = processFixture('AAO_BANT_T4', 'Stage 1');
        answerOn(f, 'TRUE', 'DENIED');
        AAO_Flags.reconcile(f.oppId, f.contractId);

        AAO_Flags.Red r = onlyRed(f.oppId);
        System.assertEquals(true, r.isRed, 'Stage 1 against a marker of 4, and still red: ' + r.because);
        System.assertEquals(AAO_Flags.CAUSE_FALSE, r.cause);
    }

    /** Absence is not evidence. Unknown before the marker is quiet and lawful. */
    @IsTest
    static void NEVERESTABLISHEDISQUIETBEFOREITSMARKER() {
        Fixture f = processFixture('AAO_BANT_T4', 'Stage 1');

        AAO_Flags.Red r = onlyRed(f.oppId);
        System.assertEquals(false, r.isRed, 'Quiet at stage 1 against a marker of 4: ' + r.because);
        System.assertEquals(AAO_Flags.CAUSE_UNMET, r.cause);
        System.assert(r.because.contains('stage'), 'And it says why: ' + r.because);
    }

    /** And past it, the same silence becomes the deal-killer it always was. */
    @IsTest
    static void NEVERESTABLISHEDREDSPASTITSMARKER() {
        Fixture f = processFixture('AAO_BANT_B1', 'Stage 3');

        AAO_Flags.Red r = onlyRed(f.oppId);
        System.assertEquals(
            true, r.isRed,
            'Stage 3 is past a marker of 2, so unknown budget is now a deal-killer: ' + r.because
        );
        System.assert(
            r.because.contains('Unknown past stage'),
            'With the reason the hundred-twentieth named: ' + r.because
        );
    }

    /**
     * **NULL IS NEVER STAGE ZERO** - the hundred-twenty-fifth's ratified semantics. A question
     * with no marker carries no rule about when not knowing becomes fatal, and a rule nobody
     * wrote does not get invented at read time.
     */
    @IsTest
    static void ANULLMARKERNEVERFLAGS() {
        Fixture f = processFixture('AAO_NO_MARKER_HERE', 'Stage 4');

        AAO_Flags.Red r = onlyRed(f.oppId);
        System.assertEquals(false, r.isRed, 'Last open stage, and still quiet: ' + r.because);
        System.assertEquals(null, r.marker, 'Because nothing states a marker for it.');
    }

    /**
     * The ordinal is read from the ORG's own stages rather than parsed out of a name. A customer
     * org calls its stages anything; the third open one is still the third.
     */
    @IsTest
    static void theSTAGEORDINALCOMESFROMTHEORGNOTFROMANAME() {
        Fixture f = processFixture('AAO_BANT_B1', 'Stage 3');
        Integer ordinal = AAO_Flags.stageOrdinalOf(f.oppId);
        System.assertNotEquals(null, ordinal, 'The deal sits somewhere among the open stages.');
        System.assert(ordinal > 0, 'And the position is one-based: ' + ordinal);
    }


    /**
     * **THE HUMAN OVERRIDE, which is the other lawful way a red goes down** and the only one
     * besides evidence. A human establishment travels the same answer path a machine one does,
     * so nothing special clears it - `reconcile` reads the row rather than who wrote it, which
     * is what makes "human edits beat the machine forever" hold here without a second path.
     *
     * A human TRUE carrying no interpretation reads as affirmed, deliberately: the inversion
     * law's DENIED is a thing the WORDS voice, and a person setting a value is not voicing a
     * customer's negative. Where a human means the negative, they say so in the interpretation.
     */
    @IsTest
    static void aHUMANESTABLISHMENTCLEARSITTOO() {
        Fixture f = processFixture('AAO_BANT_B1', 'Stage 3');
        AAO_Synthetic.MARK = true;
        insert new AAO_Answer__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Evidence_Contract__c = f.contractId,
            AAO_Subject_Type__c = 'Contact',
            AAO_Subject_Contact__c = f.contactId,
            AAO_Verdict__c = 'TRUE',
            AAO_Established_By__c = 'HUMAN',
            AAO_Basis__c = 'State',
            AAO_Publication_State__c = 'Live',
            AAO_Evidence_Occurred__c = System.now()
        );
        AAO_Synthetic.MARK = false;

        AAO_Flags.reconcile(f.oppId, f.contractId);

        System.assertEquals(
            'Cleared',
            [SELECT AAO_State__c FROM AAO_Flag__c WHERE Id = :f.flagId].AAO_State__c,
            'A person establishing the affirmative clears it exactly as evidence does.'
        );
        System.assertEquals(
            0, AAO_Flags.redCount(f.oppId),
            'And at stage 3 against a marker of 2, which would otherwise have been red.'
        );
    }

    /**
     * **NO DISMISS EXISTS**, and this asserts the structure rather than the manners: nothing in
     * the flag path reads the acknowledgement fields, so there is no gesture anywhere that can
     * take a red down. A future session adding one has to break this test to do it.
     */
    @IsTest
    static void ACKNOWLEDGEMENTCLEARSNOTHING() {
        Fixture f = processFixture('AAO_BANT_B1', 'Stage 3');
        System.assertEquals(1, AAO_Flags.redCount(f.oppId), 'Red at stage 3 against a marker of 2.');

        AAO_Synthetic.MARK = true;
        update new AAO_Flag__c(
            Id = f.flagId,
            AAO_Acknowledged_At__c = System.now(),
            AAO_Acknowledged_By__c = UserInfo.getUserId(),
            AAO_Acknowledgement_Text__c = 'Seen it, chasing the CFO this week.'
        );
        AAO_Synthetic.MARK = false;

        AAO_Flags.reconcile(f.oppId, f.contractId);

        System.assertEquals(
            'Standing',
            [SELECT AAO_State__c FROM AAO_Flag__c WHERE Id = :f.flagId].AAO_State__c,
            'Acknowledged and still standing. Nothing here accepts a gesture.'
        );
        System.assertEquals(1, AAO_Flags.redCount(f.oppId), 'And still red.');
    }

    // ------------------------------------------------------------------ fixture for (c)

    private class Fixture {
        Id oppId;
        Id acctId;
        Id contractId;
        Id flagId;
        Id contactId;
    }

    /** One gating contract, one deal at a named stage, and the day-one red already standing. */
    private static Fixture processFixture(String code, String stageName) {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Flags (c) Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Flags (c) Deal',
            AccountId = a.Id,
            StageName = stageName,
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        Contact c = new Contact(FirstName = 'Gwen', LastName = 'Arkwright', AccountId = a.Id);
        insert c;

        AAO_Evidence_Contract__c ec = new AAO_Evidence_Contract__c(
            AAO_Question_Record_Id__c = ('a0aFLAGTEST00000' + code.right(2)).left(18),
            AAO_Proposition_Code__c = code,
            AAO_Proposition_Short__c = code + ' short',
            AAO_Proposition_Text__c = 'The question ' + code + ' asks.',
            AAO_Elements__c = JSON.serialize(
                new List<Object>{ new Map<String, Object>{ 'id' => 'e1', 'text' => 'the whole of it' } }
            ),
            AAO_Element_Count__c = 1,
            AAO_Elements_Basis__c = 'Authored',
            AAO_Contract_State__c = 'Derived',
            AAO_Decay_Class__c = 'Standing',
            AAO_Family__c = AAO_ApplicableSet.PROCESS,
            AAO_Charter_Designation__c = AAO_ApplicableSet.PROCESS,
            AAO_Route__c = 'E',
            AAO_Speaker_Requirement__c = 'Buyer_Side',
            AAO_Gating__c = true,
            AAO_Rubric_Version__c = AAO_PassContracts.RUBRIC_VERSION,
            AAO_Content_Hash__c =
                '0000000000000000000000000000000000000000000000000000000000000042'
        );
        insert ec;

        AAO_Flag__c flag = new AAO_Flag__c(
            AAO_Opportunity__c = o.Id,
            AAO_Account__c = a.Id,
            AAO_Evidence_Contract__c = ec.Id,
            AAO_Type__c = 'Methodological',
            AAO_State__c = 'Standing',
            AAO_Cause__c = AAO_Flags.CAUSE_UNMET,
            AAO_Raised_At__c = System.now()
        );
        insert flag;
        AAO_Synthetic.MARK = false;

        Fixture f = new Fixture();
        f.oppId = o.Id;
        f.acctId = a.Id;
        f.contractId = ec.Id;
        f.flagId = flag.Id;
        f.contactId = c.Id;
        return f;
    }

    private static Id secondPerson(Fixture f) {
        AAO_Synthetic.MARK = true;
        Contact c = new Contact(FirstName = 'Ivan', LastName = 'Petrov', AccountId = f.acctId);
        insert c;
        AAO_Synthetic.MARK = false;
        return c.Id;
    }

    private static void answerOn(Fixture f, String verdict, String interpretation) {
        answerFor(f, verdict, interpretation, f.contactId);
    }

    private static void answerFor(
        Fixture f, String verdict, String interpretation, Id contactId
    ) {
        AAO_Synthetic.MARK = true;
        insert new AAO_Answer__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Evidence_Contract__c = f.contractId,
            AAO_Subject_Type__c = 'Contact',
            AAO_Subject_Contact__c = contactId,
            AAO_Verdict__c = verdict,
            AAO_Interpretation__c = interpretation,
            AAO_Established_By__c = 'MACHINE',
            AAO_Basis__c = 'State',
            AAO_Publication_State__c = 'Live',
            AAO_Evidence_Occurred__c = System.now()
        );
        AAO_Synthetic.MARK = false;
    }

    private static AAO_Flags.Red onlyRed(Id oppId) {
        List<AAO_Flags.Red> reds = AAO_Flags.redsOn(oppId);
        System.assertEquals(1, reds.size(), 'One standing flag on this fixture: ' + reds.size());
        return reds[0];
    }
}
