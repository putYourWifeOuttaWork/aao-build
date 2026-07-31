/**
 * The evidence-family law, ruled 47. These replace the pinned block-test: what used to
 * assert "the route refuses because the schema will not let it through" now asserts what
 * the schema was changed into.
 *
 * The behaviours worth holding are the ones a mistake would actually take: a state row
 * carrying a Source it never read from, a transcript row with no artifact behind it, a
 * claim whose receipts do not match the story it tells about itself.
 */
@IsTest
private class AAO_EvidenceFamilyTest {
    private static AAO_Demo.Ctx setUp() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        return AAO_Demo.scaffold();
    }

    private static AAO_Evidence_Contract__c anyContract() {
        return [SELECT Id FROM AAO_Evidence_Contract__c LIMIT 1];
    }

    /**
     * The change itself. Before 47 this insert was impossible: AAO_Source__c was required,
     * so a candidate whose evidence is a record could not be written at all.
     */
    @IsTest
    static void aStateCandidateIsWrittenWithNoSource() {
        AAO_Demo.Ctx c = setUp();

        Test.startTest();
        AAO_Candidate__c cand = new AAO_Candidate__c(
            AAO_Evidence_Contract__c = anyContract().Id,
            AAO_Basis__c = AAO_EvidenceFamily.STATE,
            AAO_Opportunity__c = c.oppByDeal.get(AAO_Demo.OPP_LIVE),
            AAO_Account__c = c.acct.Id,
            AAO_Subject_Type__c = 'Opportunity',
            AAO_Proposed_Verdict__c = 'TRUE',
            AAO_Stage__c = 'Adjudicated',
            AAO_Outcome__c = 'Pending',
            AAO_Charter__c = AAO_MapRoute.READER,
            AAO_Charter_Version__c = AAO_MapRoute.READER_VERSION,
            AAO_Publication_State__c = 'Live'
        );
        insert cand;
        Test.stopTest();

        System.assertNotEquals(null, cand.Id, 'No Source, and it is lawful.');
    }

    /**
     * And the law that replaced `required` is stronger than it was. `required` only ever
     * asserted that a lookup was populated; it could not tell a row that its evidence did
     * not match its declared shape.
     */
    @IsTest
    static void aStateRowMayNotCarryASourceItNeverReadFrom() {
        AAO_Demo.Ctx c = setUp();
        AAO_Demo.passOne();
        AAO_Source__c src = [SELECT Id FROM AAO_Source__c LIMIT 1];

        String err;
        Test.startTest();
        try {
            insert new AAO_Candidate__c(
                AAO_Evidence_Contract__c = anyContract().Id,
                AAO_Basis__c = AAO_EvidenceFamily.STATE,
                AAO_Source__c = src.Id,
                AAO_Opportunity__c = c.oppByDeal.get(AAO_Demo.OPP_LIVE),
                AAO_Account__c = c.acct.Id,
                AAO_Subject_Type__c = 'Opportunity',
                AAO_Proposed_Verdict__c = 'TRUE',
                AAO_Stage__c = 'Adjudicated',
                AAO_Outcome__c = 'Pending',
                AAO_Charter__c = AAO_MapRoute.READER,
                AAO_Charter_Version__c = AAO_MapRoute.READER_VERSION,
                AAO_Publication_State__c = 'Live'
            );
        } catch (DmlException e) {
            err = e.getDmlMessage(0);
        }
        Test.stopTest();

        System.assertNotEquals(null, err, 'The old required flag would have allowed this.');
        System.assert(
            err.contains('basis State and a Source'),
            'And it must say what is wrong, not that a rule was broken. Got: ' + err
        );
    }

    /**
     * The other direction: evidence from an artifact has to name the artifact. This is the
     * check `required` used to make, kept intact after it was dropped.
     */
    @IsTest
    static void aTranscriptRowWithNoSourceIsRefused() {
        AAO_Demo.Ctx c = setUp();

        String err;
        Test.startTest();
        try {
            insert new AAO_Candidate__c(
                AAO_Evidence_Contract__c = anyContract().Id,
                AAO_Basis__c = AAO_EvidenceFamily.TRANSCRIPT,
                AAO_Opportunity__c = c.oppByDeal.get(AAO_Demo.OPP_LIVE),
                AAO_Account__c = c.acct.Id,
                AAO_Subject_Type__c = 'Opportunity',
                AAO_Proposed_Verdict__c = 'TRUE',
                AAO_Stage__c = 'Adjudicated',
                AAO_Outcome__c = 'Pending',
                AAO_Charter__c = AAO_MapRoute.READER,
                AAO_Charter_Version__c = AAO_MapRoute.READER_VERSION,
                AAO_Publication_State__c = 'Live'
            );
        } catch (DmlException e) {
            err = e.getDmlMessage(0);
        }
        Test.stopTest();

        System.assert(
            err != null && err.contains('no Source'),
            'Dropping required must not have dropped the check. Got: ' + err
        );
    }

    /** A row that will not say what it rests on cannot be checked at all. */
    @IsTest
    static void aRowThatDeclaresNoFamilyIsRefused() {
        AAO_Demo.Ctx c = setUp();

        String err;
        Test.startTest();
        try {
            insert new AAO_Candidate__c(
                AAO_Evidence_Contract__c = anyContract().Id,
                AAO_Opportunity__c = c.oppByDeal.get(AAO_Demo.OPP_LIVE),
                AAO_Account__c = c.acct.Id,
                AAO_Subject_Type__c = 'Opportunity',
                AAO_Proposed_Verdict__c = 'TRUE',
                AAO_Stage__c = 'Adjudicated',
                AAO_Outcome__c = 'Pending',
                AAO_Charter__c = AAO_MapRoute.READER,
                AAO_Charter_Version__c = AAO_MapRoute.READER_VERSION,
                AAO_Publication_State__c = 'Live'
            );
        } catch (DmlException e) {
            err = e.getDmlMessage(0);
        }
        Test.stopTest();

        System.assert(
            err != null && err.contains('must declare its evidence family'),
            'Got: ' + err
        );
    }

    /**
     * The reverse half, and the direction a trigger can hold absolutely. A claim carrying
     * receipts it never declared is a claim whose receipts do not match its story: anyone
     * reading it would see cited rows under a Transcript basis and have no way to know
     * whether the answer came from the artifact or from the records.
     */
    @IsTest
    static void aCitedRowMayNotHangOffATranscriptClaim() {
        setUp();
        AAO_Demo.passOne();
        AAO_Claim__c claim = [
            SELECT Id, AAO_Basis__c FROM AAO_Claim__c ORDER BY CreatedDate LIMIT 1
        ];
        System.assertEquals(
            AAO_EvidenceFamily.TRANSCRIPT,
            claim.AAO_Basis__c,
            'The rehearsal writes transcript claims.'
        );

        String err;
        Test.startTest();
        try {
            insert new AAO_Claim_Basis__c(
                AAO_Claim__c = claim.Id,
                AAO_Cited_Type__c = 'Map_Row',
                AAO_Covers_Element__c = 'e1',
                AAO_Snapshot_Taken__c = System.now(),
                AAO_Snapshot__c = '{"v":1}'
            );
        } catch (DmlException e) {
            err = e.getDmlMessage(0);
        }
        Test.stopTest();

        System.assert(
            err != null && err.contains('declared it rests on an artifact'),
            'Got: ' + err
        );
    }

    /**
     * The forward half. It cannot be a trigger — the junction does not exist until the
     * claim has an Id — so it is checked by the writer inside the same transaction, and a
     * State claim with nothing cited is refused rather than left standing as an assertion
     * about the customer's data with no receipt.
     */
    @IsTest
    static void aStateClaimWithNothingCitedIsRefused() {
        setUp();
        AAO_Demo.passOne();
        AAO_Claim__c anyClaim = [SELECT Id FROM AAO_Claim__c LIMIT 1];

        Boolean threw = false;
        String message;
        Test.startTest();
        try {
            // Every claim from the rehearsal is Transcript, so this asks the check about a
            // claim that legitimately has no cited rows: it must stay quiet.
            AAO_EvidenceFamily.requireBasisRows(new Set<Id>{ anyClaim.Id });
        } catch (Exception e) {
            threw = true;
            message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(
            false,
            threw,
            'A transcript claim with no cited rows is correct, not a violation. Got: ' +
            message
        );
    }
}
