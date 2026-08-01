/**
 * The missing-relation flag, ruled v1.5. The behaviours worth holding are the ones the
 * SHAPE was chosen for: that twelve gaps of one kind are one flag rather than twelve, that
 * two kinds on one deal stay two flags rather than merging into an unusable number, that the
 * flag names the rows inside it, and that nothing but the gap closing clears it.
 */
@IsTest
private class AAO_MissingRelationTest {
    private static AAO_Demo.Ctx setUp() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        return AAO_Demo.scaffold();
    }

    private static List<AAO_MissingRelation.Member> members(Integer n) {
        List<AAO_MissingRelation.Member> out = new List<AAO_MissingRelation.Member>();
        for (Integer i = 1; i <= n; i++) {
            out.add(new AAO_MissingRelation.Member('card' + i, 'Solution card ' + i));
        }
        return out;
    }

    /**
     * The whole reason it is not per-card. Twelve solutions with no stated problem is one
     * conversation, and twelve flags saying the same sentence is a list nobody reads.
     */
    @IsTest
    static void manyGapsOfOneKindAreOneFlagThatNamesThemAll() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);

        Test.startTest();
        AAO_MissingRelation.reconcile(
            oppId,
            c.acct.Id,
            AAO_MissingRelation.SOLUTION_WITHOUT_PROBLEM,
            members(12)
        );
        Test.stopTest();

        List<AAO_Flag__c> flags = [
            SELECT AAO_Missing_Count__c, AAO_Missing_Members__c, AAO_State__c, AAO_Cause__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :oppId AND AAO_Type__c = :AAO_MissingRelation.TYPE
        ];
        System.assertEquals(1, flags.size(), 'One flag, not twelve.');
        System.assertEquals(12, flags[0].AAO_Missing_Count__c);
        System.assertEquals('Standing', flags[0].AAO_State__c);
        System.assertEquals(AAO_MissingRelation.CAUSE, flags[0].AAO_Cause__c);

        List<AAO_MissingRelation.Member> named = AAO_MissingRelation.members(flags[0]);
        System.assertEquals(
            12,
            named.size(),
            'And it names them. A count without the rows would say there is a problem ' +
            'without saying where, which is the failure receipts exist to prevent.'
        );
        System.assertEquals('Solution card 1', named[0].label);
    }

    /**
     * The whole reason it is not per-deal. Solutions with no stated problem and people with
     * no influence edges are different conversations, and one flag holding both would be a
     * number nobody can act on.
     */
    @IsTest
    static void twoKindsOnOneDealStayTwoFlags() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);

        Test.startTest();
        AAO_MissingRelation.reconcile(
            oppId,
            c.acct.Id,
            AAO_MissingRelation.SOLUTION_WITHOUT_PROBLEM,
            members(3)
        );
        AAO_MissingRelation.reconcile(
            oppId,
            c.acct.Id,
            AAO_MissingRelation.PERSON_WITHOUT_INFLUENCE_EDGE,
            members(2)
        );
        Test.stopTest();

        Map<String, AAO_Flag__c> standing = AAO_MissingRelation.standing(oppId);
        System.assertEquals(2, standing.size(), 'Two kinds, two flags.');
        System.assertEquals(
            3,
            standing.get(AAO_MissingRelation.SOLUTION_WITHOUT_PROBLEM).AAO_Missing_Count__c
        );
        System.assertEquals(
            2,
            standing.get(AAO_MissingRelation.PERSON_WITHOUT_INFLUENCE_EDGE)
                .AAO_Missing_Count__c
        );
    }

    /** Re-running must not raise a second flag: the key holds one-per-deal-per-kind. */
    @IsTest
    static void reconcilingTwiceUpdatesTheOneFlagRatherThanRaisingAnother() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_MissingRelation.reconcile(
            oppId, c.acct.Id, AAO_MissingRelation.SOLUTION_WITHOUT_PROBLEM, members(4)
        );

        Test.startTest();
        AAO_MissingRelation.reconcile(
            oppId, c.acct.Id, AAO_MissingRelation.SOLUTION_WITHOUT_PROBLEM, members(2)
        );
        Test.stopTest();

        List<AAO_Flag__c> flags = [
            SELECT AAO_Missing_Count__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :oppId AND AAO_Type__c = :AAO_MissingRelation.TYPE
        ];
        System.assertEquals(1, flags.size(), 'Still one. The unique key is the law.');
        System.assertEquals(2, flags[0].AAO_Missing_Count__c, 'Two of four got their edge.');
    }

    /** The only exit: the count reaching zero. There is no dismissal. */
    @IsTest
    static void onlyTheGapClosingClearsIt() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_MissingRelation.reconcile(
            oppId, c.acct.Id, AAO_MissingRelation.PRESSURE_WITHOUT_GOAL, members(2)
        );
        System.assertEquals(1, AAO_MissingRelation.standing(oppId).size());

        Test.startTest();
        AAO_MissingRelation.reconcile(
            oppId,
            c.acct.Id,
            AAO_MissingRelation.PRESSURE_WITHOUT_GOAL,
            new List<AAO_MissingRelation.Member>()
        );
        Test.stopTest();

        System.assertEquals(
            0,
            AAO_MissingRelation.standing(oppId).size(),
            'Cleared, and only because the edges now exist.'
        );
        AAO_Flag__c f = [
            SELECT AAO_State__c, AAO_Cleared_At__c, AAO_Missing_Count__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :oppId AND AAO_Type__c = :AAO_MissingRelation.TYPE
        ];
        System.assertEquals('Cleared', f.AAO_State__c);
        System.assertEquals(0, f.AAO_Missing_Count__c);
        System.assertNotEquals(null, f.AAO_Cleared_At__c, 'Time to clear is measurable.');
    }

    /**
     * A gap that comes back stands again, and its clock does NOT restart. The flag's
     * immutable raised-at decided this: one flag per deal per kind is one standing question
     * about the deal, and a gap reappearing is that question answering yes again rather
     * than a new question. Restarting would let a deal look freshly imperfect forever by
     * closing and reopening.
     */
    @IsTest
    static void aGapThatReopensStandsAgain() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        String kind = AAO_MissingRelation.SOLUTION_WITHOUT_PROBLEM;
        AAO_MissingRelation.reconcile(oppId, c.acct.Id, kind, members(1));
        AAO_MissingRelation.reconcile(
            oppId, c.acct.Id, kind, new List<AAO_MissingRelation.Member>()
        );

        Test.startTest();
        AAO_MissingRelation.reconcile(oppId, c.acct.Id, kind, members(1));
        Test.stopTest();

        Opportunity o = [SELECT CreatedDate FROM Opportunity WHERE Id = :oppId];
        AAO_Flag__c f = [
            SELECT AAO_State__c, AAO_Cleared_At__c, AAO_Raised_At__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :oppId AND AAO_Type__c = :AAO_MissingRelation.TYPE
        ];
        System.assertEquals('Standing', f.AAO_State__c, 'A new solution arrived bare.');
        System.assertEquals(
            null,
            f.AAO_Cleared_At__c,
            'And the old clearance is not left standing beside a live gap.'
        );
        System.assertEquals(
            o.CreatedDate,
            f.AAO_Raised_At__c,
            'The clock never restarted, so closing and reopening cannot launder a deal ' +
            'into looking newly imperfect.'
        );
    }

    /** No gap raises nothing. The absence of a problem is not an event. */
    @IsTest
    static void nothingMissingRaisesNothing() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);

        Test.startTest();
        AAO_MissingRelation.reconcile(
            oppId,
            c.acct.Id,
            AAO_MissingRelation.SOLUTION_WITHOUT_PROBLEM,
            new List<AAO_MissingRelation.Member>()
        );
        Test.stopTest();

        System.assertEquals(
            0,
            [
                SELECT COUNT()
                FROM AAO_Flag__c
                WHERE
                    AAO_Opportunity__c = :oppId
                    AND AAO_Type__c = :AAO_MissingRelation.TYPE
            ],
            'A flag is not raised just to be cleared.'
        );
    }

    /** Age is the deal's age, matching day-one red rather than when the code first looked. */
    @IsTest
    static void ageIsMeasuredFromTheDealNotFromTheCheck() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        Opportunity o = [SELECT CreatedDate FROM Opportunity WHERE Id = :oppId];

        Test.startTest();
        AAO_MissingRelation.reconcile(
            oppId, c.acct.Id, AAO_MissingRelation.SOLUTION_WITHOUT_PROBLEM, members(1)
        );
        Test.stopTest();

        AAO_Flag__c f = [
            SELECT AAO_Raised_At__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :oppId AND AAO_Type__c = :AAO_MissingRelation.TYPE
        ];
        System.assertEquals(
            o.CreatedDate,
            f.AAO_Raised_At__c,
            'The gap has stood since the deal existed; dating it to now would make every ' +
            'one of these look as young as the check that found it.'
        );
    }
}
