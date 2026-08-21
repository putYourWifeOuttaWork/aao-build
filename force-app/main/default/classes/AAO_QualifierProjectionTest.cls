@IsTest
private class AAO_QualifierProjectionTest {

    @IsTest
    static void aDEALWITHNOORDINALWRITESNOTHINGANDSAYSWHY() {
        // The by-stage plane's honest fallback. A deal outside the org's open stages has no
        // ordinal, so no qualifier is at or behind it - which is the whole four-call rehearsal's
        // master finding, and it must read as a stated absence rather than a silent zero.
        Id oppId = deal('Qualify');
        // WITH a wrapper, so the ordinal is the reason reached rather than the wrapper's
        // absence. The two refusals are ordered, and this test is about the second one.
        insert new ALTF__Opportunity__c(ALTF__Opportunity__c = oppId);

        Test.startTest();
        AAO_QualifierProjection.Outcome o = AAO_QualifierProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(0, o.created);
        System.assert(
            String.join(o.notes, ' ').contains('no ordinal'),
            'Absence with its reason, never a silent zero. Got: ' + o.notes
        );
    }

    @IsTest
    static void aDEALWITHNOWRAPPERWRITESNOTHINGANDNAMESWHY() {
        Id oppId = deal('Stage 2');

        Test.startTest();
        AAO_QualifierProjection.Outcome o = AAO_QualifierProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(0, o.created);
        System.assert(
            String.join(o.notes, ' ').contains('No Altify Opportunity'),
            'A wrapper is its own decision, never a side effect of projecting. Got: ' + o.notes
        );
    }

    @IsTest
    static void theBINDINGISCONFIGURATIONANDCARRIESITSDISJUNCTION() {
        // LAW #1: the binding is metadata because a customer org carries its own rubric and its
        // own qualifier text. And FUNDS binds TWO contracts because its own seeded question
        // reads "the funds OR the person who owns them" - the binding follows the words.
        Map<String, AAO_Qualifier_Binding__mdt> byCode =
            new Map<String, AAO_Qualifier_Binding__mdt>();
        for (AAO_Qualifier_Binding__mdt b : [
            SELECT AAO_Qualifier_Code__c, AAO_Contract_Codes__c, AAO_Plane__c
            FROM AAO_Qualifier_Binding__mdt
        ]) {
            byCode.put(b.AAO_Qualifier_Code__c, b);
        }
        System.assertEquals('AAO_BANT_N1', byCode.get('PROBLEM').AAO_Contract_Codes__c);
        System.assertEquals('AAO_BANT_T4', byCode.get('ENDORSED').AAO_Contract_Codes__c);
        System.assert(
            byCode.get('FUNDS').AAO_Contract_Codes__c.contains(';'),
            'FUNDS is a disjunction because its own text is one. Got: ' +
            byCode.get('FUNDS').AAO_Contract_Codes__c
        );
        for (AAO_Qualifier_Binding__mdt b : byCode.values()) {
            System.assertEquals('EVIDENCE', b.AAO_Plane__c,
                'Only the evidence plane is bound so far; the computed six wire to ' +
                'AAO_ProcessCompute and are not pretended to exist here.');
        }
    }

    @IsTest
    static void theRECOGNITIONPREDICATEISSHAREDNOTCOPIED() {
        // The 159th's Recognition audit. The qualifier surface must not carry its own opinion
        // about whose sentence a comment holds, or the two surfaces drift and tonight's rows
        // freeze as somebody else's.
        System.assertEquals(false, AAO_AnswerProjection.heldByHuman(
            'Dana Okafor · Brightwell, call 1 · SRC-00000065 @230-380\n"we run QBRs off spreadsheets."'
        ));
        System.assertEquals(false, AAO_AnswerProjection.heldByHuman('Marcus Reyes: "nine hours."'));
        System.assertEquals(true, AAO_AnswerProjection.heldByHuman('I spoke to Dana on Friday.'));
        System.assertEquals(false, AAO_AnswerProjection.heldByHuman((String) null));
    }

    private static Id deal(String stage) {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Qualifier Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Qualifier Deal', AccountId = a.Id,
            StageName = stage, CloseDate = Date.today().addDays(30)
        );
        insert o;
        AAO_Synthetic.MARK = false;
        return o.Id;
    }
}
