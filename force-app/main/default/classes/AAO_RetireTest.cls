/**
 * CLAIMS RETIRE, NEVER DELETE. Ruled 6 August 2026.
 *
 * Write-leg tests throughout, for `AAO_PairCommitTest`'s reason: retirement is a change to one
 * real ledger that has to show up in another, and there is nothing honest to assert about that
 * in memory. The fixture reuses the join's own, so what is retired here is a claim the pass
 * actually produced rather than a row shaped like one.
 *
 * **Written the same day as the thing it tests**, which is the standing lesson from
 * `AAO_ResolverCharter` carrying zero tests through two structural changes: a suite that cannot
 * see a component is green about nothing.
 */
@IsTest
private class AAO_RetireTest {
    private static final String RUN = 'testrun0001';
    private static final String WHY =
        'Retired in test: this establishment reproduced a standing graded trap.';

    // ================================================================== the ledger's law

    @IsTest
    static void aClaimIsStillNotEditableAndStillNotDeletable() {
        AAO_Claim__c c = oneClaim();

        try {
            update new AAO_Claim__c(Id = c.Id, AAO_Verdict_After__c = 'UNVERIFIED');
            System.assert(false, 'A claim\'s establishment is never edited in place.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('insert only apart from retirement'),
                e.getMessage()
            );
        }

        try {
            delete c;
            System.assert(false, 'A claim is never deleted.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('not deletable'), e.getMessage());
        }
    }

    @IsTest
    static void retirementIsTheOneAllowedUpdateAndItCarriesItsReason() {
        AAO_Claim__c c = oneClaim();

        Test.startTest();
        AAO_Retire.Outcome o = AAO_Retire.byIds(new Set<Id>{ c.Id }, WHY);
        Test.stopTest();

        System.assertEquals(1, o.retired, o.toString());
        AAO_Claim__c after = [
            SELECT AAO_Retired__c, AAO_Retired_Because__c, AAO_Retired_At__c,
                AAO_Verdict_After__c, AAO_Spans__c
            FROM AAO_Claim__c
            WHERE Id = :c.Id
        ];
        System.assertEquals(true, after.AAO_Retired__c);
        System.assertEquals(WHY, after.AAO_Retired_Because__c);
        System.assertNotEquals(null, after.AAO_Retired_At__c);
        System.assertEquals(
            c.AAO_Verdict_After__c,
            after.AAO_Verdict_After__c,
            'THE ESTABLISHMENT ITSELF IS UNTOUCHED. Retirement says this should not have ' +
            'moved anything; it does not say the words were misquoted or the verdict ' +
            'misrecorded, and rewriting either would destroy the record of what we did.'
        );
        System.assertEquals(c.AAO_Spans__c, after.AAO_Spans__c, 'The receipts survive.');
    }

    @IsTest
    static void aRetirementWithNoRealReasonIsRefused() {
        AAO_Claim__c c = oneClaim();
        try {
            AAO_Retire.byIds(new Set<Id>{ c.Id }, 'wrong');
            System.assert(false, 'A one-word reason is not a reason.');
        } catch (AAO_Retire.RetireException e) {
            System.assert(e.getMessage().contains('carries its reason'), e.getMessage());
        }
        System.assertEquals(
            false,
            [SELECT AAO_Retired__c FROM AAO_Claim__c WHERE Id = :c.Id].AAO_Retired__c,
            'The refusal must leave the claim alone rather than half-retire it.'
        );
    }

    @IsTest
    static void aRetiredClaimIsNeverUnRetired() {
        AAO_Claim__c c = oneClaim();
        AAO_Retire.byIds(new Set<Id>{ c.Id }, WHY);

        try {
            update new AAO_Claim__c(Id = c.Id, AAO_Retired__c = false);
            System.assert(false, 'Retirement is one-way.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('never un-retired'),
                'A ledger that can be edited back into a state it was never in is not a ' +
                'ledger. Got: ' + e.getMessage()
            );
        }
    }

    @IsTest
    static void retiringIsIdempotent() {
        // A correction path whose safe response to an uncertain state is "do not run it" is
        // not a correction path.
        AAO_Claim__c c = oneClaim();
        AAO_Retire.byIds(new Set<Id>{ c.Id }, WHY);

        Test.startTest();
        AAO_Retire.Outcome again = AAO_Retire.byIds(new Set<Id>{ c.Id }, WHY);
        Test.stopTest();

        System.assertEquals(0, again.retired, again.toString());
        System.assertEquals(1, again.alreadyRetired, again.toString());
    }

    // ============================================================== what the replay does

    @IsTest
    static void anAnswerWhoseEveryClaimIsRetiredStopsEstablishing() {
        // The state that was unreachable before retirement existed, and the reason the
        // `verdictFromClaims` null guard had to be split: zero LIVE claims is a real answer to
        // a question we asked, not the silence of never having asked it.
        AAO_Claim__c c = oneClaim();
        AAO_Answer__c before = [
            SELECT Id, AAO_Verdict__c, AAO_Support_Counter__c
            FROM AAO_Answer__c
            WHERE Id = :c.AAO_Answer__c
        ];
        System.assertEquals('TRUE', before.AAO_Verdict__c);
        System.assertEquals(1, before.AAO_Support_Counter__c);

        Test.startTest();
        AAO_Retire.Outcome o = AAO_Retire.byIds(new Set<Id>{ c.Id }, WHY);
        Test.stopTest();

        AAO_Answer__c after = [
            SELECT AAO_Verdict__c, AAO_Support_Counter__c
            FROM AAO_Answer__c
            WHERE Id = :before.Id
        ];
        System.assertEquals(
            'UNVERIFIED',
            after.AAO_Verdict__c,
            'It lands UNVERIFIED rather than TRUE or null: the proposition WAS addressed, the ' +
            'retired receipts are still readable, and UNVERIFIED is the state that places ' +
            'nobody - so projection retracts, which is what makes this a lawful correction ' +
            'rather than a delete.'
        );
        System.assertEquals(
            0,
            after.AAO_Support_Counter__c,
            'A retired claim moves the counter by nothing.'
        );
        System.assertEquals(1, o.verdictsRebuilt, o.toString());
    }

    @IsTest
    static void retirementReconcilesInItsOwnTransaction() {
        // Marking the claim is half the ruling. Nothing else in the system would ever run the
        // replay after a retirement - the join reaches its rebuilds only on its own runs, and
        // a retirement joins no pairs - so an unreconciled retirement would be only a label.
        AAO_Claim__c c = oneClaim();

        Test.startTest();
        AAO_Retire.Outcome o = AAO_Retire.byIds(new Set<Id>{ c.Id }, WHY);
        Test.stopTest();

        System.assert(
            o.verdictsRebuilt > 0 || o.countersRebuilt > 0,
            'Retirement reconciles the ledger or it is only a label. Got: ' + o
        );
    }

    // ===================================================================== the fixture

    private static AAO_Claim__c oneClaim() {
        AAO_PairCommitTest.Fixture f = AAO_PairCommitTest.fixture();
        AAO_PairCommitTest.pair(
            f, 'p1', AAO_P8Codes.SENTIMENT, 'SUPPORTER', 'Full', 'Identified', 'Upheld',
            f.participantId
        );
        AAO_PairCommit.run(RUN, new Set<String>{ 'seller.example' });
        return [
            SELECT Id, AAO_Answer__c, AAO_Verdict_After__c, AAO_Spans__c
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :f.oppId
            LIMIT 1
        ];
    }
}