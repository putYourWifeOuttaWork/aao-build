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
     * ITEM 46 b AND c, unblocked by 47. The route writes a candidate with NO SOURCE,
     * commits it through the same door route E uses, and the claim carries cited rows with
     * the values frozen at claim time.
     */
    @IsTest
    static void theRouteWritesAStateClaimWithNoSourceAndCitesTheRowsItCounted() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_MapRoute.seedMapRows(oppId, c.acct.Id, danaId(c));

        Test.startTest();
        AAO_MapRoute.Outcome o = AAO_MapRoute.run(oppId, c.internalDomains, true);
        Test.stopTest();

        System.assertNotEquals(null, o.claimId, 'A claim, from state alone. ' + o.note);
        System.assertEquals('TRUE', o.verdict, o.note);
        System.assertEquals(1, o.basisRows, 'One row counted, one row cited.');

        AAO_Claim__c claim = [
            SELECT AAO_Basis__c, AAO_Source__c, AAO_Spans__c, AAO_Charter__c
            FROM AAO_Claim__c
            WHERE Id = :o.claimId
        ];
        System.assertEquals(AAO_EvidenceFamily.STATE, claim.AAO_Basis__c);
        System.assertEquals(
            null,
            claim.AAO_Source__c,
            'The whole point of 47. Its evidence is a record, and there is no artifact to ' +
            'name.'
        );
        System.assertEquals(null, claim.AAO_Spans__c, 'And nothing to quote.');
        System.assertEquals(
            AAO_MapRoute.READER,
            claim.AAO_Charter__c,
            'Not a charter, but still attribution: which reader, which version.'
        );

        AAO_Claim_Basis__c b = [
            SELECT AAO_Cited_Map_Row__c, AAO_Covers_Element__c, AAO_Snapshot__c
            FROM AAO_Claim_Basis__c
            WHERE AAO_Claim__c = :o.claimId
        ];
        System.assertNotEquals(null, b.AAO_Cited_Map_Row__c, 'It names the row.');
        System.assertEquals(AAO_MapRoute.ELEMENT, b.AAO_Covers_Element__c);
        System.assert(
            b.AAO_Snapshot__c.contains(AAO_MapRoute.ROLE_DECISION_MAKER),
            'And freezes what the row said. Got: ' + b.AAO_Snapshot__c
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

    /**
     * ITEM 46f, THE EXIT CHECK, against a claim the route produced rather than one built
     * by hand. The sentence it exists to make true: editing the cited row afterwards
     * changes nothing about the claim, while the live lookup shows the new value.
     *
     * This is why the frozen half exists at all. Without it, anyone editing a map row would
     * silently rewrite the evidence under every claim that ever rested on it, and the claim
     * would go on asserting something no record had ever said.
     */
    @IsTest
    static void editingACitedRowMovesTheLiveValueAndNothingElse() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_MapRoute.seedMapRows(oppId, c.acct.Id, danaId(c));
        AAO_MapRoute.Outcome o = AAO_MapRoute.run(oppId, c.internalDomains, true);
        System.assertNotEquals(null, o.claimId, o.note);

        AAO_Claim_Basis__c before = [
            SELECT AAO_Snapshot__c, AAO_Cited_Map_Row__c
            FROM AAO_Claim_Basis__c
            WHERE AAO_Claim__c = :o.claimId
        ];
        String frozen = before.AAO_Snapshot__c;

        // Somebody changes Dana's role next Tuesday, with no idea a claim rests on it.
        Test.startTest();
        update new ALTF__Contact_Map_Details__c(
            Id = before.AAO_Cited_Map_Row__c,
            ALTF__Buyer_Role__c = 'Evaluator'
        );
        Test.stopTest();

        AAO_Claim_Basis__c after = [
            SELECT AAO_Snapshot__c, AAO_Cited_Map_Row__r.ALTF__Buyer_Role__c
            FROM AAO_Claim_Basis__c
            WHERE AAO_Claim__c = :o.claimId
        ];
        System.assertEquals(
            frozen,
            after.AAO_Snapshot__c,
            'THEN is unchanged. The claim still says what the row said when it was cited.'
        );
        System.assert(
            after.AAO_Snapshot__c.contains(AAO_MapRoute.ROLE_DECISION_MAKER),
            'And what it said was Decision Maker.'
        );
        System.assertEquals(
            'Evaluator',
            after.AAO_Cited_Map_Row__r.ALTF__Buyer_Role__c,
            'NOW has moved, one traversal away, in the same subquery.'
        );

        String report = AAO_MapRoute.thenAndNow(oppId);
        System.assert(
            report.contains(AAO_MapRoute.ROLE_DECISION_MAKER) &&
            report.contains('Evaluator'),
            'And the report shows both halves together, which is the point. Got: ' + report
        );
    }

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
