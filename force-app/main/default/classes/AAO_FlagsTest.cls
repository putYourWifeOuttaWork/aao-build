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
        Integer raised = AAO_Flags.raiseFor(opps, AAO_Seed.RUBRIC_VERSION);
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

        // After pass one the answer is UNVERIFIED. Partial evidence is not establishment.
        AAO_Flag__c f = [
            SELECT AAO_State__c, AAO_Cause__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :oppId AND AAO_Evidence_Contract__c = :contractId
            LIMIT 1
        ];
        System.assertEquals(
            'Standing',
            f.AAO_State__c,
            'UNVERIFIED holds the red. Evidence that does not establish does not clear.'
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
            SELECT AAO_Verdict__c, AAO_Element_Coverage__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :oppId
            LIMIT 1
        ];
        System.assertEquals('UNVERIFIED', a.AAO_Verdict__c);
        System.assertEquals(
            true,
            AAO_Model.parseCoverage(a.AAO_Element_Coverage__c)
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
     * A deal is red against the rubric it is adjudicated under. Once discovery has run an
     * org holds more than one rubric, and the first version of this flagged every deal
     * against every rubric in the org.
     */
    @IsTest
    static void aDealIsRedOnlyAgainstItsOwnRubric() {
        AAO_Demo.Ctx c = scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        Integer own = AAO_Flags.standing(oppId);

        // A second rubric in the same org, gating, and nothing to do with this deal.
        AAO_Evidence_Contract__c other = new AAO_Evidence_Contract__c(
            AAO_Question_Record_Id__c = 'OTHER_RUBRIC_Q1',
            AAO_Proposition_Code__c = 'OTHER_1',
            AAO_Proposition_Short__c = 'Somebody else rubric',
            AAO_Proposition_Text__c = 'A gating proposition from another rubric entirely.',
            AAO_Guidance_Text__c = 'Not this deal business.',
            AAO_Elements__c = '[{"id":"e1","text":"the only part"}]',
            AAO_Element_Count__c = 1,
            AAO_Elements_Basis__c = 'Authored',
            AAO_Route__c = 'E',
            AAO_Speaker_Requirement__c = 'Any_Participant',
            AAO_Decay_Class__c = 'Standing',
            AAO_Gating__c = true,
            AAO_Contract_State__c = 'Ratified',
            AAO_Rubric_Version__c = 'some-other-rubric'
        );
        insert other;

        Test.startTest();
        Integer raised = AAO_Flags.raiseFor(
            new Set<Id>{ oppId },
            AAO_Seed.RUBRIC_VERSION
        );
        Test.stopTest();

        System.assertEquals(0, raised);
        System.assertEquals(
            own,
            AAO_Flags.standing(oppId),
            'The other rubric gating proposition must not appear on this deal.'
        );
    }
}
