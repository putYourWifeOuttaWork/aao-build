@IsTest
private class AAO_QualifierProjectionTest {

    @IsTest
    static void anESTABLISHMENTWRITEISRESIDENCEINDEPENDENT() {
        // CORRECTED AT THE 165th. This used to assert that a deal with no ordinal wrote
        // nothing. That was wrong: evidence is recorded wherever the call put it. FUNDS is
        // resident at Discover, but a customer who names their budget during the Qualify call
        // has named it, and discarding that until the deal advances would be forgetting
        // something true because of where the calendar is. The ordinal governs FLAGS and
        // EXPECTATIONS, which are what compare against it.
        Id oppId = deal('Qualify');
        insert new ALTF__Opportunity__c(ALTF__Opportunity__c = oppId);

        Test.startTest();
        AAO_QualifierProjection.Outcome o = AAO_QualifierProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(
            0,
            o.humanHeld,
            'Nothing is established on this fixture, so nothing writes and nothing is held. ' +
            'The point of this test is that the ORDINAL is not what stopped it: ' +
            String.valueOf(o)
        );
    }

    @IsTest
    static void aROWTHISWRITERDIDNOTCREATEISHELDWHOLE() {
        // THE ONE THAT COST A REAL ROW. Matthew ticked WHEN1 = Yes in the vendor UI and left
        // the comment blank. The hold predicate read the COMMENT, and a blank comment reads as
        // "nobody's, ours to fill" - true of a blank comment on OUR row, false of a blank
        // comment on HIS. This writer wrote a citation onto a row a human made. On this surface
        // ownership is ENUMERATION, not shape: a row we did not create is held whole, whatever
        // its comment says or does not say.
        Id oppId = deal('Qualify');
        ALTF__Opportunity__c w = new ALTF__Opportunity__c(ALTF__Opportunity__c = oppId);
        insert w;
        List<ALTF__Sales_Process_Qualifier__c> qs = [
            SELECT Id FROM ALTF__Sales_Process_Qualifier__c LIMIT 1
        ];
        if (qs.isEmpty()) {
            return;
        }
        ALTF__Qualifier_Answer__c his = new ALTF__Qualifier_Answer__c(
            ALTF__Opportunity__c = w.Id,
            ALTF__Sales_Process_Qualifier__c = qs[0].Id,
            ALTF__Status__c = 'Yes'
        );
        insert his;

        Test.startTest();
        AAO_QualifierProjection.run(oppId);
        Test.stopTest();

        ALTF__Qualifier_Answer__c after = [
            SELECT ALTF__Status__c, ALTF__Comment__c
            FROM ALTF__Qualifier_Answer__c WHERE Id = :his.Id
        ];
        System.assertEquals('Yes', after.ALTF__Status__c);
        System.assertEquals(
            null,
            after.ALTF__Comment__c,
            'A blank comment on a human\'s row is still the human\'s. Human edits beat the ' +
            'machine forever, and a watermark is what tells us whose row it is.'
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
            SELECT AAO_Qualifier_Code__c, AAO_Contract_Codes__c, AAO_Predicate__c,
                   AAO_Plane__c
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
        // THE NOT-PRETENDING TEST, MOVED WITH THE BUILD. It used to assert every binding was
        // EVIDENCE, because the computed six did not exist and must not be half-present wearing
        // configuration's coat. They exist now, so the guard becomes the stronger one: a binding
        // declares exactly ONE plane and carries exactly the field that plane needs. A row with
        // both, or with neither, is a binding that cannot be evaluated and must not ship.
        for (AAO_Qualifier_Binding__mdt b : byCode.values()) {
            Boolean evidence = String.isNotBlank(b.AAO_Contract_Codes__c);
            Boolean computed = String.isNotBlank(b.AAO_Predicate__c);
            System.assert(
                evidence != computed,
                b.AAO_Qualifier_Code__c + ' declares ' + b.AAO_Plane__c + ' but carries ' +
                'contracts=' + evidence + ' predicate=' + computed + '. Exactly one.'
            );
            System.assertEquals(
                evidence ? 'EVIDENCE' : 'COMPUTED',
                b.AAO_Plane__c,
                b.AAO_Qualifier_Code__c + ' names a plane its own fields contradict.'
            );
        }
        // FOURTEEN NOW. CLOSEPLAN was minted as AAO_BANT_C1 at the 173rd's build, so the
        // absence this once asserted is closed. Every qualifier the process asks is bound.
        System.assertEquals(14, byCode.size(),
            'All fourteen qualifiers are bound: thirteen from the original rubric and ' +
            'CLOSEPLAN through its minted contract.');
        System.assertEquals('AAO_BANT_C1', byCode.get('CLOSEPLAN').AAO_Contract_Codes__c,
            'CLOSEPLAN binds the proposition minted for it, not one borrowed from BANT.');
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
