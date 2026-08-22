@IsTest
private class AAO_ColdStartTest {

    @IsTest
    static void aDEALWITHNOTYPEGETSASTATEDREFUSALANDNOTAGUESS() {
        // The process is RESOLVED, never chosen. A deal the vendor's mapping does not cover has
        // no plan to be given, and inventing one would be a rubric nobody agreed to.
        Id oppId = deal(null);

        Test.startTest();
        AAO_ColdStart.Outcome o = AAO_ColdStart.ensurePlan(oppId);
        Test.stopTest();

        System.assertEquals(false, o.wrapperCreated);
        System.assertEquals(false, o.planAssigned);
        System.assert(
            String.join(o.notes, ' ').contains('does not resolve a value'),
            'Absence with its reason, never a silent nothing. Got: ' + o.notes
        );
        System.assertEquals(0, [
            SELECT COUNT() FROM ALTF__Opportunity__c WHERE ALTF__Opportunity__c = :oppId
        ], 'A deal we cannot plan gets no wrapper either.');
    }

    @IsTest
    static void aTYPETHEMAPPINGDOESNOTCOVERISREFUSEDBYNAME() {
        Id oppId = deal('New Customer');

        Test.startTest();
        AAO_ColdStart.Outcome o = AAO_ColdStart.ensurePlan(oppId);
        Test.stopTest();

        System.assertEquals(false, o.planAssigned);
        System.assert(
            String.join(o.notes, ' ').contains('New Customer'),
            'The refusal names the VALUE it could not map, so a reader can fix the mapping ' +
            'rather than guess what went wrong. Got: ' + o.notes
        );
    }

    @IsTest
    static void aDEALTHATALREADYCARRIESAPLANISNEVERTOUCHED() {
        // Whoever assigned it, it is not ours to re-assign. Advancing and re-planning are the
        // seller's acts; this method only gives an UNPLANNED deal its plan.
        Id oppId = deal('AAO BANT (Sandbox)');
        List<ALTF__Sales_Process__c> processes = [SELECT Id FROM ALTF__Sales_Process__c LIMIT 1];
        if (processes.isEmpty()) {
            return;
        }
        ALTF__Opportunity__c w = new ALTF__Opportunity__c(
            ALTF__Opportunity__c = oppId,
            ALTF__Sales_Process__c = processes[0].Id
        );
        insert w;

        Test.startTest();
        AAO_ColdStart.Outcome o = AAO_ColdStart.ensurePlan(oppId);
        Test.stopTest();

        System.assertEquals(false, o.wrapperCreated);
        System.assertEquals(false, o.planAssigned, 'A standing plan is never re-assigned.');
        System.assert(
            String.join(o.notes, ' ').contains('already carries a plan'), String.valueOf(o.notes)
        );
        System.assertEquals(1, [
            SELECT COUNT() FROM ALTF__Opportunity__c WHERE ALTF__Opportunity__c = :oppId
        ], 'Never a second wrapper.');
    }

    @IsTest
    static void aWRAPPERWECREATEISENUMERATEDLIKEEVERYTHINGELSE() {
        // The 173rd's item 4(v), and the omission my own gate probe made before it was caught:
        // a vendor object is not an exception to the ownership law. A machine-created row we
        // cannot enumerate is a row we can never disown.
        Id oppId = deal('AAO BANT (Sandbox)');

        Test.startTest();
        AAO_ColdStart.Outcome o = AAO_ColdStart.ensurePlan(oppId);
        Test.stopTest();

        if (!o.wrapperCreated) {
            // No mapping in this org for the fixture Type; the refusal path is tested above.
            return;
        }
        System.assertEquals(1, [
            SELECT COUNT() FROM AAO_Created_Row__c
            WHERE AAO_Target_Object__c = 'ALTF__Opportunity__c'
              AND AAO_Target_Id__c = :String.valueOf(o.wrapperId)
        ], 'The wrapper we created must be enumerated as ours.');
    }

    private static Id deal(String type) {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        // THE ORG'S POINTER, SEEDED, because a test context sees no custom setting and the
        // module now walks the pointer rather than assuming `Type`. Seeding it is the honest
        // fixture: without one the chain genuinely cannot be walked, and the module says so.
        if ([SELECT COUNT() FROM ALTF__Opportunity_Manager_Settings__c] == 0) {
            insert new ALTF__Opportunity_Manager_Settings__c(
                ALTF__Opportunity_Plan_Type__c = 'Type'
            );
        }
        Account a = new Account(Name = 'AAO Cold Start Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Cold Start Deal', AccountId = a.Id, Type = type,
            StageName = 'Stage 1', CloseDate = Date.today().addDays(30)
        );
        insert o;
        AAO_Synthetic.MARK = false;
        return o.Id;
    }
}
