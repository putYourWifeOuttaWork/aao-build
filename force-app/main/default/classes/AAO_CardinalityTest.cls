/**
 * Invariant 9. The behaviours worth holding: that a pass over its bound refuses BEFORE the
 * work rather than failing during it, that the refusal is recorded with the numbers frozen,
 * that a missing configuration is not read as no limit, and that the check does no DML —
 * which is the one that would have broken the model call on every passing run.
 */
@IsTest
private class AAO_CardinalityTest {
    private static AAO_Demo.Ctx setUp() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        return AAO_Demo.scaffold();
    }

    /**
     * THE ONE THAT MATTERS MOST, and it is about ordering rather than counting.
     *
     * AAO_Pipeline forbids DML before the callout. A guard that wrote a flag on the way past
     * would break the model call on every pass that was WITHIN its bound — the passes nobody
     * would think to test, because they are the ones that work.
     */
    @IsTest
    static void theCheckDoesNoDmlSoItCannotBreakTheCalloutOrdering() {
        setUp();
        Integer before = Limits.getDmlStatements();

        Test.startTest();
        AAO_Cardinality.Verdict v = AAO_Cardinality.check(3);
        Test.stopTest();

        System.assertEquals(true, v.withinBound);
        System.assertEquals(
            before,
            Limits.getDmlStatements(),
            'Not one statement. A callout after DML fails with an error that reads like a ' +
            'platform problem rather than an ordering one.'
        );
    }

    /** Over the bound abstains and says so with the numbers. */
    @IsTest
    static void overTheBoundRefusesAndRecordsBothNumbers() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        Integer bound = AAO_Cardinality.ceiling();

        Test.startTest();
        AAO_Cardinality.Verdict v = AAO_Cardinality.check(bound + 10);
        AAO_Cardinality.refuse(oppId, c.acct.Id, AAO_Cardinality.PEOPLE_PASS, v);
        Test.stopTest();

        System.assertEquals(false, v.withinBound);
        List<AAO_Flag__c> flags = AAO_Cardinality.standing(oppId);
        System.assertEquals(1, flags.size());
        System.assertEquals(AAO_Cardinality.PEOPLE_PASS, flags[0].AAO_Bounded_Path__c);
        System.assertEquals(bound + 10, flags[0].AAO_Proposed_Count__c);
        System.assertEquals(
            bound,
            flags[0].AAO_Ceiling__c,
            'The bound in force is frozen on the flag, so raising it later cannot rewrite ' +
            'why an older run abstained.'
        );
        System.assert(
            flags[0].AAO_Acknowledgement_Text__c.contains('rather than truncating'),
            'And it says why abstaining beats truncating. Got: ' +
            flags[0].AAO_Acknowledgement_Text__c
        );
    }

    /** Repeated refusals update one flag rather than raising one per attempt. */
    @IsTest
    static void refusingTwiceKeepsOneFlag() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        Integer bound = AAO_Cardinality.ceiling();
        AAO_Cardinality.refuse(
            oppId, c.acct.Id, AAO_Cardinality.PEOPLE_PASS, AAO_Cardinality.check(bound + 1)
        );

        Test.startTest();
        AAO_Cardinality.refuse(
            oppId, c.acct.Id, AAO_Cardinality.PEOPLE_PASS, AAO_Cardinality.check(bound + 5)
        );
        Test.stopTest();

        List<AAO_Flag__c> flags = AAO_Cardinality.standing(oppId);
        System.assertEquals(1, flags.size(), 'One flag, updated.');
        System.assertEquals(bound + 5, flags[0].AAO_Proposed_Count__c);
    }

    /** Back under the bound clears it, because its cause is gone. */
    @IsTest
    static void backUnderTheBoundClearsIt() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_Cardinality.refuse(
            oppId,
            c.acct.Id,
            AAO_Cardinality.PEOPLE_PASS,
            AAO_Cardinality.check(AAO_Cardinality.ceiling() + 1)
        );
        System.assertEquals(1, AAO_Cardinality.standing(oppId).size());

        Test.startTest();
        AAO_Cardinality.clearIfStanding(oppId, AAO_Cardinality.PEOPLE_PASS);
        Test.stopTest();

        System.assertEquals(0, AAO_Cardinality.standing(oppId).size());
    }

    /**
     * Forgetting to configure must never be the same as choosing no limit. An unbounded
     * creation path is the exact condition invariant 9 forbids.
     */
    @IsTest
    static void aMissingBoundFallsBackRatherThanGoingUnbounded() {
        Test.startTest();
        Integer bound = AAO_Cardinality.ceiling();
        Test.stopTest();
        System.assert(bound > 0, 'There is always a number.');
        System.assert(
            AAO_Cardinality.FALLBACK_CEILING > 0,
            'And the fallback is finite, never infinity.'
        );
    }

    /** The live extraction pass is inside its bound, so the guard is silent in practice. */
    @IsTest
    static void theLiveExtractionPassIsWellInsideItsBound() {
        setUp();
        Integer contracts = AAO_Rubric.contracts(true).size();

        Test.startTest();
        AAO_Cardinality.Verdict v = AAO_Cardinality.check(contracts);
        Test.stopTest();

        System.assertEquals(
            true,
            v.withinBound,
            'A guard that fired on the rehearsal would be a bound set wrong, not a bound ' +
            'doing its job. Got: ' + v.reason
        );
    }
}
