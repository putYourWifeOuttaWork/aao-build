@IsTest
private class AAO_AnswerProjectionTest {

    @IsTest
    static void anAffirmedEstablishmentBecomesAYesCARRYINGTHEWORDS() {
        Fixture f = fixture(true);
        establish(f, 'AAO_PROJ_ONE', 'AFFIRMED');

        Test.startTest();
        AAO_AnswerProjection.Outcome o = AAO_AnswerProjection.run(f.oppId);
        Test.stopTest();

        System.assertEquals(1, o.created, String.valueOf(o));
        ALTF__Assessment_Answer__c row = [
            SELECT Name, ALTF__Answer__c, ALTF__Note__c, ALTF__NoteEntered__c, ALTF__AltifyId__c
            FROM ALTF__Assessment_Answer__c WHERE ALTF__Opportunity__c = :f.wrapperId LIMIT 1
        ];
        System.assertEquals('Yes', row.ALTF__Answer__c);
        System.assert(
            row.ALTF__Note__c.contains('nine hours a week'),
            'A row saying Yes with nothing quoted is the same failure wearing a tick. Got: ' +
            row.ALTF__Note__c
        );
        System.assertEquals(true, row.ALTF__NoteEntered__c,
            'The vendor hides a note whose entered flag is false, so the citation would be ' +
            'written and invisible, which is worse than not written.');
        System.assertEquals(String.valueOf(row.Id).substring(0, 15), row.Name,
            'Their own rows name themselves by their fifteen character Id; a row named ' +
            'otherwise renders wrong in their UI.');
        System.assert(row.ALTF__AltifyId__c.endsWith(String.valueOf(row.Id)), row.ALTF__AltifyId__c);
    }

    @IsTest
    static void aVoicedNoBECOMESANOBECAUSEDENIEDISNOTUNKNOWN() {
        // The inversion law reaching this surface: DENIED is a TRUE verdict whose reading is a
        // denial, and on the assessment screen that is precisely the No the methodology wants.
        Fixture f = fixture(true);
        establish(f, 'AAO_PROJ_ONE', 'DENIED');

        Test.startTest();
        AAO_AnswerProjection.run(f.oppId);
        Test.stopTest();

        System.assertEquals('No', [
            SELECT ALTF__Answer__c FROM ALTF__Assessment_Answer__c
            WHERE ALTF__Opportunity__c = :f.wrapperId LIMIT 1
        ].ALTF__Answer__c);
    }

    @IsTest
    static void anythingThatIsNotAFFIRMEDORDENIEDWRITESNOTHINGATALL() {
        Fixture f = fixture(true);
        establish(f, 'AAO_PROJ_ONE', 'CRITERION');

        Test.startTest();
        AAO_AnswerProjection.Outcome o = AAO_AnswerProjection.run(f.oppId);
        Test.stopTest();

        System.assertEquals(0, o.created,
            'Unknown is what an untouched row already says. Writing it would turn "we have ' +
            'established nothing" into a machine assertion.');
        System.assertEquals(0, [
            SELECT COUNT() FROM ALTF__Assessment_Answer__c WHERE ALTF__Opportunity__c = :f.wrapperId
        ]);
    }

    @IsTest
    static void theSECONDRUNWRITESNOTHINGANDSAYSSO() {
        Fixture f = fixture(true);
        establish(f, 'AAO_PROJ_ONE', 'AFFIRMED');

        Test.startTest();
        AAO_AnswerProjection.run(f.oppId);
        AAO_AnswerProjection.Outcome second = AAO_AnswerProjection.run(f.oppId);
        Test.stopTest();

        System.assertEquals(0, second.created);
        System.assertEquals(0, second.updated);
        System.assertEquals(1, second.unchanged, String.valueOf(second));
        System.assertEquals(1, [
            SELECT COUNT() FROM ALTF__Assessment_Answer__c WHERE ALTF__Opportunity__c = :f.wrapperId
        ], 'A second pass must not double the deal\'s assessment.');
    }

    @IsTest
    static void aHUMANSPROSEHOLDSTHEWHOLEROWANSWERINCLUDED() {
        // The Note Payload law. Half-writing a row a human owns is worse than leaving it alone,
        // so the answer beside their prose is held too.
        Fixture f = fixture(true);
        establish(f, 'AAO_PROJ_ONE', 'AFFIRMED');
        AAO_AnswerProjection.run(f.oppId);
        ALTF__Assessment_Answer__c row = [
            SELECT Id FROM ALTF__Assessment_Answer__c
            WHERE ALTF__Opportunity__c = :f.wrapperId LIMIT 1
        ];
        update new ALTF__Assessment_Answer__c(
            Id = row.Id,
            ALTF__Answer__c = 'No',
            ALTF__Note__c = 'Spoke to Dana on Friday, she walked this back.'
        );

        Test.startTest();
        AAO_AnswerProjection.Outcome o = AAO_AnswerProjection.run(f.oppId);
        Test.stopTest();

        System.assertEquals(1, o.humanHeld, String.valueOf(o));
        ALTF__Assessment_Answer__c after = [
            SELECT ALTF__Answer__c, ALTF__Note__c FROM ALTF__Assessment_Answer__c
            WHERE Id = :row.Id
        ];
        System.assertEquals('Spoke to Dana on Friday, she walked this back.', after.ALTF__Note__c,
            'Human edits beat the machine forever.');
        System.assertEquals('No', after.ALTF__Answer__c,
            'The answer beside a human note is theirs too, and is not quietly corrected.');
    }

    @IsTest
    static void aDEALWITHNOWRAPPERWRITESNOTHINGANDNAMESWHY() {
        Fixture f = fixture(false);
        establish(f, 'AAO_PROJ_ONE', 'AFFIRMED');

        Test.startTest();
        AAO_AnswerProjection.Outcome o = AAO_AnswerProjection.run(f.oppId);
        Test.stopTest();

        System.assertEquals(0, o.created);
        System.assert(
            String.join(o.notes, ' ').contains('No Altify Opportunity'),
            'Absence with its reason, never a silent zero and never a wrapper invented as a ' +
            'side effect. Got: ' + o.notes
        );
    }

    @IsTest
    static void EVERYCREATEDROWISENUMERATEDSOITCANBEDISOWNED() {
        Fixture f = fixture(true);
        establish(f, 'AAO_PROJ_ONE', 'AFFIRMED');

        Test.startTest();
        AAO_AnswerProjection.run(f.oppId, 'projtest-run');
        Test.stopTest();

        System.assertEquals(1, [
            SELECT COUNT() FROM AAO_Created_Row__c
            WHERE AAO_Target_Object__c = 'ALTF__Assessment_Answer__c'
        ], 'A machine-created row we cannot enumerate is a row we can never disown.');
    }

    // ------------------------------------------------------------------------ helpers

    private class Fixture {
        Id oppId;
        Id acctId;
        Id contactA;
        Id wrapperId;
        Map<String, Id> contracts = new Map<String, Id>();
    }

    private static Fixture fixture(Boolean withWrapper) {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Projection Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Projection Deal', AccountId = a.Id,
            StageName = 'Stage 2', CloseDate = Date.today().addDays(30)
        );
        insert o;
        Contact c = new Contact(FirstName = 'Marcus', LastName = 'Reyes', AccountId = a.Id);
        insert c;

        Fixture f = new Fixture();
        f.oppId = o.Id;
        f.acctId = a.Id;
        f.contactA = c.Id;

        AAO_Evidence_Contract__c ec = new AAO_Evidence_Contract__c(
            AAO_Question_Record_Id__c = 'a0aPROJTEST0000001',
            AAO_Proposition_Code__c = 'AAO_PROJ_ONE',
            AAO_Proposition_Short__c = 'The question AAO_PROJ_ONE asks',
            AAO_Proposition_Text__c = 'Does AAO_PROJ_ONE hold?',
            AAO_Elements__c = JSON.serialize(new List<Object>{
                new Map<String, Object>{ 'id' => 'e1', 'text' => 'the whole of it' }
            }),
            AAO_Element_Count__c = 1,
            AAO_Elements_Basis__c = 'Authored',
            AAO_Contract_State__c = AAO_ContractState.DERIVED,
            AAO_Decay_Class__c = 'Standing',
            AAO_Family__c = AAO_ApplicableSet.PROCESS,
            AAO_Charter_Designation__c = AAO_ApplicableSet.PROCESS,
            AAO_Route__c = 'E',
            AAO_Speaker_Requirement__c = 'Buyer_Side',
            AAO_Rubric_Version__c = AAO_PassContracts.RUBRIC_VERSION,
            AAO_Content_Hash__c =
                '0000000000000000000000000000000000000000000000000000000000000009'
        );
        insert ec;
        f.contracts.put('AAO_PROJ_ONE', ec.Id);

        insert new ALTF__Assessment_Question__c(
            ALTF__AltifyId__c = 'AAO_PROJ_ONE',
            ALTF__Question__c = 'Does AAO_PROJ_ONE hold?',
            // The org's own law, learned from it rather than assumed: an assessment question
            // requires its criterion text as well as its question and order number.
            ALTF__Criterion_Text__c = 'Evidence that AAO_PROJ_ONE holds.',
            ALTF__Order_Number__c = 1,
            ALTF__Active__c = true
        );

        if (withWrapper) {
            ALTF__Opportunity__c w = new ALTF__Opportunity__c(ALTF__Opportunity__c = o.Id);
            insert w;
            f.wrapperId = w.Id;
        }
        AAO_Synthetic.MARK = false;
        return f;
    }

    private static void establish(Fixture f, String code, String interpretation) {
        AAO_Synthetic.MARK = true;
        insert new AAO_Answer__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Evidence_Contract__c = f.contracts.get(code),
            AAO_Subject_Type__c = 'Contact',
            AAO_Subject_Contact__c = f.contactA,
            AAO_Verdict__c = 'TRUE',
            AAO_Interpretation__c = interpretation,
            AAO_Established_By__c = 'MACHINE',
            AAO_Basis__c = 'State',
            AAO_Publication_State__c = 'Live',
            AAO_Spans__c = JSON.serialize(new Map<String, Object>{
                'v' => 1,
                'spans' => new List<Object>{
                    new Map<String, Object>{
                        'quote' => 'Roughly nine hours a week across the team.',
                        'element' => 'e1'
                    }
                }
            }),
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 8, 20, 15, 0, 0)
        );
        AAO_Synthetic.MARK = false;
    }
}
