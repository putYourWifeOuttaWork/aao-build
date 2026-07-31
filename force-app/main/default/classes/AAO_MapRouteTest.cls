/**
 * The P route. The behaviours worth asserting are the ones that make a frozen basis mean
 * something: that a claim rests on named rows, that a row which stopped saying what it was
 * cited for stops the claim being written, and that editing a cited row afterwards changes
 * nothing about the claim while the live lookup moves.
 */
@IsTest
private class AAO_MapRouteTest {
    private static AAO_Demo.Ctx setUp() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        return c;
    }

    private static Id danaId(AAO_Demo.Ctx c) {
        return c.contactByKey.get('dana').Id;
    }

    /**
     * THE BLOCK, pinned as a test so it cannot be forgotten or quietly worked around.
     *
     * Everything the P route needs is built and verified: the map rows, the deterministic
     * count, state verification, the snapshot shape, the then-and-now lookup. What stops it
     * is the schema: AAO_Candidate__c.AAO_Source__c is required and a state-derived
     * candidate has no Source, because its evidence is a record rather than an artifact.
     *
     * This test exists so that whichever way that is ruled, the ruling is deliberate.
     */
    @IsTest
    static void thePRouteRefusesToInventASourceAndSaysWhy() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_MapRoute.seedMapRows(oppId, c.acct.Id, danaId(c));

        Boolean threw = false;
        String message;
        Test.startTest();
        try {
            AAO_MapRoute.run(oppId, c.internalDomains, true);
        } catch (AAO_MapRoute.MapRouteException e) {
            threw = true;
            message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'It must refuse rather than manufacture a Source.');
        System.assert(message.contains('AAO_Source__c is '), 'Got: ' + message);
        System.assert(
            message.contains('state verification passed'),
            'And it must say how far it got, so the block is separable from a failure. ' +
            'Got: ' + message
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Claim_Basis__c WHERE AAO_Synthetic__c = TRUE],
            'Nothing written.'
        );
    }

    /** An empty map is the absence of a record, not a record that there is nobody. */
    @IsTest
    static void anEmptyRelationshipMapIsUnverifiedAndWritesNothing() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);

        Test.startTest();
        AAO_MapRoute.Outcome o = AAO_MapRoute.run(oppId, c.internalDomains, true);
        Test.stopTest();

        System.assertEquals('UNVERIFIED', o.verdict);
        System.assertEquals(null, o.claimId, 'Nothing established, so nothing written.');
        System.assertEquals(0, o.basisRows);
        System.assert(o.note.contains('no claim written'), o.note);
    }

    /**
     * State verification, the twin of the byte check. A row that no longer says what it is
     * about to be cited for stops the claim, rather than weakening it.
     */
    @IsTest
    static void aRowThatStoppedSayingItRefusesTheClaim() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_MapRoute.seedMapRows(oppId, c.acct.Id, danaId(c));

        ALTF__Contact_Map_Details__c row = [
            SELECT Id, ALTF__Buyer_Role__c
            FROM ALTF__Contact_Map_Details__c
            WHERE ALTF__Opportunity__c = :oppId
            LIMIT 1
        ];
        List<ALTF__Contact_Map_Details__c> cited =
            new List<ALTF__Contact_Map_Details__c>{ row };

        // Somebody edits it between the read and the commit, which is the whole hazard.
        row.ALTF__Buyer_Role__c = 'Evaluator';
        update row;

        Test.startTest();
        AAO_MapRoute.Verification v = AAO_MapRoute.verifyState(cited);
        Test.stopTest();

        System.assertEquals(false, v.passed);
        System.assertEquals(1, v.failures.size());
        System.assert(
            v.failures[0].contains('now reads "Evaluator"'),
            'The failure has to name what the row actually says. Got: ' + v.failures[0]
        );
    }

    // ITEM 46f, THE EXIT CHECK, cannot run yet. It needs a claim to exist, and the P
    // route cannot write one until AAO_Candidate__c.AAO_Source__c is ruled on. The
    // machinery it would exercise is built: AAO_Claim_Basis__c.AAO_Cited_Map_Row__c is the
    // live half, AAO_Snapshot__c is the frozen half, and AAO_MapRoute.thenAndNow returns
    // both from one subquery. Deliberately not asserted against a hand-made claim, because
    // a test that builds its own claim would prove the query works and nothing about
    // whether the route produces one.

    /**
     * Item 46e. The map row wins over the roster, and the verdict says which it used, so a
     * standing decision can never be traced to a source nobody can identify.
     */
    @IsTest
    static void theMapRowIsPreferredOverTheRosterAndTheReasonSaysSo() {
        AAO_Demo.Ctx c = setUp();
        Contact dana = c.contactByKey.get('dana');

        AAO_Model.Speaker sp = new AAO_Model.Speaker();
        sp.display = 'Dana Ruiz';
        sp.email = 'dana.ruiz@northwind.example';
        sp.contactId = dana.Id;
        // The roster says something weaker than the map does.
        sp.mapRole = 'User';

        Test.startTest();
        AAO_SpeakerRule.Verdict fromRoster = AAO_SpeakerRule.evaluate(
            'Decision_Maker_Or_Influencer',
            sp,
            c.internalDomains,
            null
        );
        AAO_SpeakerRule.Verdict fromMap = AAO_SpeakerRule.evaluate(
            'Decision_Maker_Or_Influencer',
            sp,
            c.internalDomains,
            new Map<Id, String>{ dana.Id => AAO_MapRoute.ROLE_DECISION_MAKER }
        );
        Test.stopTest();

        System.assertEquals(false, fromRoster.satisfied, 'The roster says User.');
        System.assert(
            fromRoster.reason.contains('the artifact roster'),
            'Got: ' + fromRoster.reason
        );

        System.assertEquals(
            true,
            fromMap.satisfied,
            'The map says Decision Maker, and standing is not something a transcript gets ' +
            'to declare.'
        );
        System.assert(
            fromMap.reason.contains('the relationship map'),
            'The reason must name the source it used. Got: ' + fromMap.reason
        );
    }
}
