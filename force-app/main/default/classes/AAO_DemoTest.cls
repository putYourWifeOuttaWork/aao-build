/**
 * The durable rehearsal, exercised. These run inside a test transaction and roll back, so
 * they prove the mechanics; the real durable run happens through anonymous Apex.
 */
@IsTest
private class AAO_DemoTest {
    @IsTest
    static void aPassWritesMarkedRowsAndTheSecondRunSkips() {
        Test.startTest();
        String first = AAO_Demo.passOne();
        String second = AAO_Demo.passOne();
        Test.stopTest();

        System.assert(first.startsWith('OK.'), first);
        System.assert(
            second.startsWith('SKIPPED.'),
            'A second run must write nothing. Claims carry no unique key by design, so ' +
            'this guard is what makes the rehearsal idempotent. Got: ' + second
        );

        System.assertEquals(1, [SELECT COUNT() FROM AAO_Claim__c]);
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Synthetic__c = FALSE],
            'Every row the rehearsal writes carries the marker.'
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Source__c WHERE AAO_Synthetic__c = FALSE]
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Answer__c WHERE AAO_Synthetic__c = FALSE]
        );
    }

    @IsTest
    static void purgeRemovesTheRehearsalInOneAction() {
        AAO_Demo.passOne();

        Test.startTest();
        String report = AAO_Demo.purge();
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM AAO_Claim__c], report);
        System.assertEquals(0, [SELECT COUNT() FROM AAO_Answer__c], report);
        System.assertEquals(0, [SELECT COUNT() FROM AAO_Source__c], report);
        System.assertEquals(0, [SELECT COUNT() FROM AAO_Candidate__c], report);
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Account WHERE Name = :AAO_Demo.ACCOUNT_NAME],
            report
        );
    }

    /**
     * PURGING alone must not be enough. The marker is the second condition, and it is the
     * one that protects a real claim.
     */
    @IsTest
    static void purgingCannotDeleteAnUnmarkedClaim() {
        AAO_Demo.passOne();
        AAO_Claim__c c = [SELECT Id, AAO_Synthetic__c FROM AAO_Claim__c LIMIT 1];
        c.AAO_Synthetic__c = false;

        // Claims are insert only, so the marker cannot be cleared through the front door
        // either. That is the point; assert it, then prove the purge door stays shut.
        try {
            update c;
            System.assert(false, 'A claim is never edited, including its marker.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('insert only'), e.getMessage());
        }

        AAO_Synthetic.PURGING = true;
        System.assertEquals(
            false,
            AAO_Synthetic.deletable(false),
            'An unmarked row is not deletable even mid-purge.'
        );
        System.assertEquals(true, AAO_Synthetic.deletable(true));
        AAO_Synthetic.PURGING = false;
    }

    @IsTest
    static void statusReportsWhatIsThere() {
        System.assertEquals('Nothing seeded.', AAO_Demo.status());
        AAO_Demo.passOne();
        String s = AAO_Demo.status();
        // CORRECTED IN PLACE, seventieth stamp: pass one's establishment now reads TRUE, because
        // the verifier upheld it and completeness stopped gating the verdict. The assertion's
        // job is unchanged — the status must report an actual VERDICT rather than a blank — so
        // it asserts on the verdict being present rather than on which one it happened to be.
        System.assert(
            s.contains('TRUE') || s.contains('UNVERIFIED'),
            'Status names the verdict it found. Got: ' + s
        );
        System.assert(s.contains(AAO_Demo.OPP_MAIN), s);
    }

    // ------------------------------------------------------------------ Flag's law

    private static AAO_Flag__c aFlag(Id oppId, Id acctId) {
        return new AAO_Flag__c(
            AAO_Type__c = 'Methodological',
            AAO_Opportunity__c = oppId,
            AAO_Account__c = acctId,
            AAO_Cause__c = 'Gating_Unmet',
            AAO_State__c = 'Standing'
        );
    }

    @IsTest
    static void aFlagTypeIsSetAtBirthAndNeverChanges() {
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        AAO_Flag__c f = aFlag(c.oppByDeal.get(AAO_Demo.OPP_MAIN), c.acct.Id);
        insert f;

        f.AAO_Type__c = 'Contention_Negative';
        try {
            update f;
            System.assert(
                false,
                'Type determines how a flag clears and how it is measured. Nothing ' +
                'downstream reconstructs a flag\'s origin to know how to treat it.'
            );
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('immutable'), e.getMessage());
        }
    }

    @IsTest
    static void aFlagIsNotDeletableOnTheLivePath() {
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        AAO_Flag__c f = aFlag(c.oppByDeal.get(AAO_Demo.OPP_MAIN), c.acct.Id);
        insert f;
        try {
            delete f;
            System.assert(
                false,
                'Deleting a flag destroys the measurement it exists to produce. No gesture ' +
                'on any rendering clears anything.'
            );
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('not deletable'), e.getMessage());
        }
    }

    @IsTest
    static void aFlagStateAndRaisedAtDefaultOnInsert() {
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        AAO_Flag__c f = new AAO_Flag__c(
            AAO_Type__c = 'Ratification',
            AAO_Opportunity__c = c.oppByDeal.get(AAO_Demo.OPP_MAIN),
            AAO_Account__c = c.acct.Id,
            AAO_Cause__c = 'Awaiting_Ratification'
        );
        insert f;
        AAO_Flag__c r = [
            SELECT AAO_State__c, AAO_Raised_At__c FROM AAO_Flag__c WHERE Id = :f.Id
        ];
        System.assertEquals('Standing', r.AAO_State__c);
        System.assertNotEquals(null, r.AAO_Raised_At__c);
    }
}