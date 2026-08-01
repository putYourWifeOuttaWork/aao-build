/**
 * The Solution route. The behaviours worth holding are the discipline rather than the
 * plumbing: that a solution is derived only where a line item actually carries one, that the
 * route refuses a contract the org never asked for rather than choosing one, that a changed
 * line item refuses the claim, and above all that the route NEVER proposes the edge from a
 * solution to a problem.
 */
@IsTest
private class AAO_SolutionRouteTest {
    private static AAO_Demo.Ctx setUp() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        return AAO_Demo.scaffold();
    }

    /**
     * A deal with no line items derives nothing, and that is the honest answer rather than
     * an empty judgment. The absence of a purchase is not a claim about solutions.
     */
    @IsTest
    static void adealWithNoLineItemsDerivesNothing() {
        AAO_Demo.Ctx c = setUp();
        Test.startTest();
        List<AAO_SolutionRoute.Bought> b = AAO_SolutionRoute.bought(
            c.oppByDeal.get(AAO_Demo.OPP_LIVE)
        );
        Test.stopTest();
        System.assertEquals(0, b.size());
    }

    /**
     * THE REFUSAL THAT MATTERS. There is no Solution proposition in the rubric, so the route
     * will not pick one. Choosing a question the org never asked is the same mistake as
     * manufacturing a Source, and it is refused by name.
     */
    @IsTest
    static void theRouteRefusesAContractTheOrgNeverAsked() {
        AAO_Demo.Ctx c = setUp();
        String err;
        Test.startTest();
        try {
            AAO_SolutionRoute.run(
                c.oppByDeal.get(AAO_Demo.OPP_LIVE),
                c.acct.Id,
                'AAO_SOLUTION_NOT_A_REAL_CODE',
                c.internalDomains,
                true
            );
        } catch (AAO_SolutionRoute.SolutionRouteException e) {
            err = e.getMessage();
        }
        Test.stopTest();
        System.assertNotEquals(null, err, 'It must refuse rather than choose.');
        System.assert(
            err.contains('never asked'),
            'And say why, not merely that a lookup failed. Got: ' + err
        );
    }

    /** The snapshot freezes what was cited, and only what was cited. */
    @IsTest
    static void theSnapshotFreezesTheCitedFieldsOnly() {
        OpportunityLineItem oli = new OpportunityLineItem(Quantity = 3);
        AAO_SolutionRoute.Bought b = new AAO_SolutionRoute.Bought(null, oli);
        Test.startTest();
        Map<String, Object> snap = (Map<String, Object>) JSON.deserializeUntyped(
            AAO_SolutionRoute.snapshot(b)
        );
        Test.stopTest();
        System.assertEquals(1, snap.get('v'));
        System.assert(snap.containsKey('citedLineItemId'), 'It names the row it read.');
        System.assert(snap.containsKey('quantity'), 'And what that row said.');
        System.assertEquals(
            5,
            snap.size(),
            'What was cited, never what was available. Got: ' + snap.keySet()
        );
    }

    /**
     * THE DISCIPLINE OF THE ROUTE. A deal can have bought a solution and still have no idea
     * which problem it answers, and the route must leave that gap open rather than close it
     * with a guess. The flag is Altify's own admission test, not our invention.
     */
    @IsTest
    static void theRouteNeverProposesTheEdgeAndFlagsTheGapInstead() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);

        insert new ALTF__Insight_Card__c(
            Name = 'Consolidate reporting',
            ALTF__Opportunity__c = oppId,
            ALTF__Account__c = c.acct.Id,
            ALTF__Type__c = 'Solution'
        );

        Test.startTest();
        List<AAO_MissingRelation.Member> unlinked = AAO_SolutionRoute.unlinkedSolutions(oppId);
        AAO_SolutionRoute.reconcileFlag(oppId, c.acct.Id);
        Test.stopTest();

        System.assertEquals(1, unlinked.size(), 'A Solution card with no edge to anything.');
        System.assertEquals('Consolidate reporting', unlinked[0].label, 'Named, not counted.');

        Map<String, AAO_Flag__c> standing = AAO_MissingRelation.standing(oppId);
        AAO_Flag__c f = standing.get(AAO_MissingRelation.SOLUTION_WITHOUT_PROBLEM);
        System.assertNotEquals(null, f, 'The gap is flagged.');
        System.assertEquals(1, f.AAO_Missing_Count__c);

        System.assertEquals(
            0,
            [SELECT COUNT() FROM ALTF__Insight_Card_Edge__c],
            'And the route wrote no edge. What was bought cannot say what it answers, and ' +
            'inferring it would manufacture a causal claim from a purchase order.'
        );
    }

    /** An edge existing is the only thing that clears it. */
    @IsTest
    static void anEdgeClearsTheFlagAndNothingElseDoes() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);

        ALTF__Insight_Card__c solution = new ALTF__Insight_Card__c(
            Name = 'Consolidate reporting',
            ALTF__Opportunity__c = oppId,
            ALTF__Account__c = c.acct.Id,
            ALTF__Type__c = 'Solution'
        );
        ALTF__Insight_Card__c obstacle = new ALTF__Insight_Card__c(
            Name = 'Reporting is manual',
            ALTF__Opportunity__c = oppId,
            ALTF__Account__c = c.acct.Id,
            ALTF__Type__c = 'Obstacle'
        );
        insert new List<ALTF__Insight_Card__c>{ solution, obstacle };
        AAO_SolutionRoute.reconcileFlag(oppId, c.acct.Id);
        System.assertEquals(1, AAO_MissingRelation.standing(oppId).size());

        Test.startTest();
        // A person, or a span, established the link. Never this route.
        insert new ALTF__Insight_Card_Edge__c(
            ALTF__Solution_Insight_Card__c = solution.Id,
            ALTF__Insight_Card__c = obstacle.Id
        );
        AAO_SolutionRoute.reconcileFlag(oppId, c.acct.Id);
        Test.stopTest();

        System.assertEquals(
            0,
            AAO_MissingRelation.standing(oppId).size(),
            'Cleared, and only because the edge now exists.'
        );
    }
}
