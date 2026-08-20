@IsTest
private class AAO_GhostProjectionTest {

    @IsTest
    static void anEXPECTEDPERSONANOBODYFILLSSTANDSASAGHOST() {
        Id oppId = deal('Stage 3');
        stub(new Map<String, Decimal>{ 'Executive Sponsor' => 1 });

        Test.startTest();
        AAO_GhostProjection.Outcome o = AAO_GhostProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(1, o.created, String.valueOf(o));
        ALTF__Relationship_Map_Persona__c row = [
            SELECT ALTF__Persona__c, ALTF__AltifyId__c, ALTF__Account__c, ALTF__Opportunity__c
            FROM ALTF__Relationship_Map_Persona__c WHERE ALTF__Opportunity__c = :oppId
        ];
        System.assertEquals('Executive Sponsor', row.ALTF__Persona__c);
        System.assertNotEquals(null, row.ALTF__Account__c,
            'The Account lookup is nillable=false on this object, measured.');
        System.assert(row.ALTF__AltifyId__c.startsWith('AAO|RMP|'),
            'The key is the enumeration: a row we cannot recognise is one we can never ' +
            'withdraw. Got: ' + row.ALTF__AltifyId__c);
    }

    @IsTest
    static void theSECONDRUNADDSNOTHING() {
        Id oppId = deal('Stage 3');
        stub(new Map<String, Decimal>{ 'Executive Sponsor' => 1 });

        Test.startTest();
        AAO_GhostProjection.run(oppId);
        AAO_GhostProjection.Outcome second = AAO_GhostProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(0, second.created);
        System.assertEquals(1, second.unchanged, String.valueOf(second));
        System.assertEquals(1, [
            SELECT COUNT() FROM ALTF__Relationship_Map_Persona__c WHERE ALTF__Opportunity__c = :oppId
        ], 'Every pass would otherwise crowd the map with duplicate ghosts.');
    }

    @IsTest
    static void aGHOSTTHATNOLONGERAPPLIESISWITHDRAWN() {
        // A ghost beside the person who fills it is a lie the map would tell forever.
        Id oppId = deal('Stage 3');
        stub(new Map<String, Decimal>{ 'Executive Sponsor' => 1 });
        AAO_GhostProjection.run(oppId);

        Test.startTest();
        stub(new Map<String, Decimal>());
        AAO_GhostProjection.Outcome o = AAO_GhostProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(1, o.withdrawn, String.valueOf(o));
        System.assertEquals(0, [
            SELECT COUNT() FROM ALTF__Relationship_Map_Persona__c WHERE ALTF__Opportunity__c = :oppId
        ]);
    }

    @IsTest
    static void aROWSOMEBODYELSEMADEISNEVERWITHDRAWN() {
        Id oppId = deal('Stage 3');
        stub(new Map<String, Decimal>());
        Id acctId = [SELECT AccountId FROM Opportunity WHERE Id = :oppId].AccountId;
        insert new ALTF__Relationship_Map_Persona__c(
            ALTF__Account__c = acctId,
            ALTF__Opportunity__c = oppId,
            ALTF__Persona__c = 'CEO',
            ALTF__AltifyId__c = 'SOMEBODY-ELSES-ROW'
        );

        Test.startTest();
        AAO_GhostProjection.Outcome o = AAO_GhostProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(0, o.withdrawn,
            'The key is the enumeration, and a row somebody else made is not ours to withdraw.');
        System.assertEquals(1, [
            SELECT COUNT() FROM ALTF__Relationship_Map_Persona__c WHERE ALTF__Opportunity__c = :oppId
        ]);
    }

    @IsTest
    static void EVERYGHOSTISENUMERATEDSOITCANBEDISOWNED() {
        Id oppId = deal('Stage 3');
        stub(new Map<String, Decimal>{ 'Executive Sponsor' => 1 });

        Test.startTest();
        AAO_GhostProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(1, [
            SELECT COUNT() FROM AAO_Created_Row__c
            WHERE AAO_Target_Object__c = 'ALTF__Relationship_Map_Persona__c'
        ]);
    }

    // ------------------------------------------------------------------------ helpers

    private static Id deal(String stage) {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Ghost Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Ghost Deal', AccountId = a.Id,
            StageName = stage, CloseDate = Date.today().addDays(30)
        );
        insert o;
        AAO_Synthetic.MARK = false;
        return o.Id;
    }

    /** Expectations are custom metadata, so the seam the ghost path already carries is used. */
    private static void stub(Map<String, Decimal> personaToStage) {
        List<AAO_Persona_Expectation__mdt> rows = new List<AAO_Persona_Expectation__mdt>();
        for (String persona : personaToStage.keySet()) {
            rows.add(new AAO_Persona_Expectation__mdt(
                AAO_Persona__c = persona,
                AAO_Expected_From_Stage__c = personaToStage.get(persona),
                AAO_Title_Patterns__c = 'nothing-matches-this-title'
            ));
        }
        AAO_Personas.stubbed = rows;
    }
}
