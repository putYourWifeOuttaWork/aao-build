@IsTest
private class AAO_GhostProjectionTest {

    @IsTest
    static void theCASTSTANDSFROMCALLONENOTFROMITSDUESTAGE() {
        // Matthew's ruling at the hundred-seventieth, and it redefines what a ghost IS: a
        // persona required at Commit is a relationship that must START at Qualify, because
        // influence cannot be manufactured on the due date. A ghost is a LEAD-TIME NODE, not a
        // flag with an early start date - so the deal's own ordinal must not gate it.
        Id oppId = deal('Stage 1');
        stub(new Map<String, Decimal>{ 'Executive Sponsor' => 4, 'Procurement Lead' => 5 });

        Test.startTest();
        AAO_Personas.Reading r = AAO_Personas.ghostsOn(oppId);
        AAO_GhostProjection.Outcome o = AAO_GhostProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(2, r.ghosts.size(),
            'Both stand at ordinal 1 though neither is due until 4 and 5. The by-stage plane ' +
            'governs FLAGS and the ghost was never a flag.');
        System.assertEquals(2, o.created, String.valueOf(o));
    }

    @IsTest
    static void theVENDORHOLDSONEROWPERMAPANDTHEGRAINFOLLOWSIT() {
        // The hundred-fifty-second ratified one row per persona so ghosts could graduate
        // independently. The reasoning was right; the grain was not available. The vendor
        // refuses a second persona row on a map - "Cannot insert duplicate Relationship Map
        // Personas" - and its multipicklist is what it always intended instead.
        Id oppId = deal('Stage 1');
        stub(new Map<String, Decimal>{ 'Executive Sponsor' => 4, 'Procurement Lead' => 5 });

        Test.startTest();
        AAO_GhostProjection.run(oppId);
        Test.stopTest();

        List<ALTF__Relationship_Map_Persona__c> rows = [
            SELECT ALTF__Persona__c FROM ALTF__Relationship_Map_Persona__c
            WHERE ALTF__Opportunity__c = :oppId
        ];
        System.assertEquals(1, rows.size(), 'One row per map, whatever the cast size.');
        Set<String> values = new Set<String>(rows[0].ALTF__Persona__c.split(';'));
        System.assertEquals(2, values.size(), rows[0].ALTF__Persona__c);
        System.assert(values.contains('Executive Sponsor') && values.contains('Procurement Lead'),
            rows[0].ALTF__Persona__c);
    }

    @IsTest
    static void AGHOSTGRADUATESALONEANDLEAVESTHERESTSTANDING() {
        // Independence survives the grain change: graduating one persona removes ONE VALUE and
        // the others are untouched. A contact matching Executive Sponsor must not clear a
        // standing Procurement Lead.
        Id oppId = deal('Stage 1');
        stub(new Map<String, Decimal>{ 'Executive Sponsor' => 4, 'Procurement Lead' => 5 });
        AAO_GhostProjection.run(oppId);

        Test.startTest();
        stub(new Map<String, Decimal>{ 'Procurement Lead' => 5 });
        AAO_GhostProjection.Outcome o = AAO_GhostProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(1, o.withdrawn, String.valueOf(o));
        ALTF__Relationship_Map_Persona__c row = [
            SELECT ALTF__Persona__c FROM ALTF__Relationship_Map_Persona__c
            WHERE ALTF__Opportunity__c = :oppId
        ];
        System.assertEquals('Procurement Lead', row.ALTF__Persona__c,
            'The graduated ghost goes and the standing one stays. A ghost beside the person ' +
            'who fills it is a lie the map tells forever.');
    }

    @IsTest
    static void SOMEBODYELSESROWISHELDWHOLEANDTHEGAPISSAIDOUTLOUD() {
        // Ownership is a record of having acted, not a key that looks like ours. And because
        // the vendor allows only ONE row, a ghost we owe cannot be put beside theirs - so the
        // honest move is to hold their row and NAME what is missing.
        Id oppId = deal('Stage 1');
        stub(new Map<String, Decimal>{ 'Procurement Lead' => 5 });
        Id acctId = [SELECT AccountId FROM Opportunity WHERE Id = :oppId].AccountId;
        insert new ALTF__Relationship_Map_Persona__c(
            ALTF__Account__c = acctId, ALTF__Opportunity__c = oppId,
            ALTF__Persona__c = 'CEO', ALTF__AltifyId__c = 'SOMEBODY-ELSES-ROW'
        );

        Test.startTest();
        AAO_GhostProjection.Outcome o = AAO_GhostProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(0, o.created);
        System.assertEquals(0, o.withdrawn, 'Their row is never edited or removed.');
        System.assertEquals('CEO', [
            SELECT ALTF__Persona__c FROM ALTF__Relationship_Map_Persona__c
            WHERE ALTF__Opportunity__c = :oppId
        ].ALTF__Persona__c);
        System.assert(
            String.join(o.notes, ' ').contains('Procurement Lead'),
            'The owed ghost is named rather than silently dropped. Got: ' + o.notes
        );
    }

    @IsTest
    static void EVERYCASTWEWRITEISENUMERATED() {
        Id oppId = deal('Stage 1');
        stub(new Map<String, Decimal>{ 'Executive Sponsor' => 4 });

        Test.startTest();
        AAO_GhostProjection.run(oppId);
        Test.stopTest();

        System.assertEquals(1, [
            SELECT COUNT() FROM AAO_Created_Row__c
            WHERE AAO_Target_Object__c = 'ALTF__Relationship_Map_Persona__c'
        ], 'A machine-created row we cannot enumerate is a row we can never disown.');
    }

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
