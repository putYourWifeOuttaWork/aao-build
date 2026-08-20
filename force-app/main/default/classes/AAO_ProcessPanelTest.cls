/**
 * The Process panel, step (f). What is worth asserting is what a seller would misread if it were
 * wrong: that every declared question gets a row whatever its state, that a voiced no never reads
 * as a false, that an affirmed row carries the words behind it, and that the panel writes nothing.
 */
@IsTest
private class AAO_ProcessPanelTest {
    /**
     * **`Established_False` NEVER REACHES A SCREEN.** The hundred-thirtieth named the residue and
     * this is the assertion that keeps it fixed: the panel's own vocabulary says what the cause
     * MEANS, and a system with no FALSE never shows the word.
     */
    @IsTest
    static void aVOICEDNONEVERREADSASAFALSE() {
        Fixture f = fixture();
        establish(f, 'AAO_PANEL_ONE', 'DENIED');

        AAO_ProcessPanel.ProcessView v = AAO_ProcessPanel.read(f.oppId);
        String voiced = rowFor(v, 'AAO_PANEL_ONE').display;

        System.assertEquals(
            'Voiced no', voiced,
            'The cause stores Established_False and the seller reads a voiced no.'
        );
        System.assert(
            !voiced.toLowerCase().contains('false'),
            'And the word FALSE appears nowhere in it: ' + voiced
        );
        // Every other row on the same reading is unestablished, and none of them says FALSE
        // either - the mapping has no path to the word at all.
        for (AAO_ProcessPanel.AssessmentRow r : v.assessment) {
            String shown = (r.display == null ? '' : r.display) +
                ' ' + (r.because == null ? '' : r.because);
            System.assert(
                !shown.toLowerCase().contains('false'),
                r.code + ' shows the word FALSE: ' + shown
            );
        }
    }

    /**
     * EVERY DECLARED QUESTION GETS A ROW, including the ones with nothing on them. A panel that
     * showed only what fired could not show a quiet blank, and a quiet blank is one of the three
     * states the hundred-twentieth ruled.
     */
    @IsTest
    static void everyDECLAREDQUESTIONGETSAROWWHATEVERITSSTATE() {
        Fixture f = fixture();
        AAO_ProcessPanel.ProcessView v = AAO_ProcessPanel.read(f.oppId);

        System.assertEquals(
            3, v.assessment.size(),
            'Three declared, three rows, none of them established: ' + v.notes
        );
        for (AAO_ProcessPanel.AssessmentRow r : v.assessment) {
            System.assertEquals('BLANK', r.state, r.code + ' has nothing on it.');
            System.assertEquals(null, r.display, 'A quiet blank displays nothing.');
            System.assertNotEquals(null, r.because, 'And still says why it is quiet.');
        }
    }

    /** An affirmed row carries the words behind it. A tick with no citation is the card-face
     *  failure wearing a different shape. */
    @IsTest
    static void anAFFIRMEDROWCARRIESITSWORDS() {
        Fixture f = fixture();
        establish(f, 'AAO_PANEL_ONE', 'AFFIRMED');

        AAO_ProcessPanel.ProcessView v = AAO_ProcessPanel.read(f.oppId);

        AAO_ProcessPanel.AssessmentRow row = rowFor(v, 'AAO_PANEL_ONE');
        System.assertEquals('AFFIRMED', row.state);
        System.assertEquals('Yes', row.display);
        System.assertNotEquals(null, row.citation, 'The words are on the row.');
        System.assert(
            row.citation.contains('nine hours a week'),
            'And they are the buyer\'s own: ' + row.citation
        );
    }

    /** A voiced no is an establishment and reads as one, never as a blank. */
    @IsTest
    static void aDENIEDROWISNOTABLANK() {
        Fixture f = fixture();
        establish(f, 'AAO_PANEL_ONE', 'DENIED');

        AAO_ProcessPanel.AssessmentRow row =
            rowFor(AAO_ProcessPanel.read(f.oppId), 'AAO_PANEL_ONE');

        System.assertEquals('DENIED', row.state, 'Established, and established as a no.');
        System.assertEquals('Voiced no', row.display);
        System.assertNotEquals(null, row.citation, 'Cited to the words that voiced it.');
    }

    /** Several mouths, one row: a voiced no outranks an affirmed, the same tiebreak the flag
     *  path applies, so the panel and the flags can never disagree. */
    @IsTest
    static void aDENIEDOUTRANKSANAFFIRMEDONTHESAMEROW() {
        Fixture f = fixture();
        establish(f, 'AAO_PANEL_ONE', 'AFFIRMED');
        establishFor(f, 'AAO_PANEL_ONE', 'DENIED', f.contactB);

        System.assertEquals(
            'DENIED',
            rowFor(AAO_ProcessPanel.read(f.oppId), 'AAO_PANEL_ONE').state,
            'One person\'s yes does not undo another\'s no.'
        );
    }

    /** An org declaring no Process questions gets graceful absence, never an empty screen with
     *  no explanation. */
    @IsTest
    static void anORGWITHNOPROCESSQUESTIONSISTOLDSO() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Panel Bare');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Panel Bare Deal', AccountId = a.Id,
            StageName = 'Stage 1', CloseDate = Date.today().addDays(20)
        );
        insert o;
        AAO_Synthetic.MARK = false;

        AAO_ProcessPanel.ProcessView v = AAO_ProcessPanel.read(o.Id);

        System.assertEquals(0, v.assessment.size());
        System.assert(
            String.join(v.notes, ' ').contains('Graceful absence'),
            'And it says why rather than showing nothing: ' + v.notes
        );
    }

    /**
     * **READ-ONLY, ASSERTED RATHER THAN PROMISED.** The Run Inspector's own guard at the
     * sixty-third: a surface named "panel" that could write is a surface a later session will
     * make write.
     */
    @IsTest
    static void thePANELWRITESNOTHINGEVER() {
        String body = [
            SELECT Body FROM ApexClass WHERE Name = 'AAO_ProcessPanel' LIMIT 1
        ].Body;
        for (String verb : new List<String>{
            'insert ', 'update ', 'upsert ', 'delete ', 'undelete ', 'Database.'
        }) {
            System.assert(
                !body.contains(verb),
                'The panel must never write, and it contains "' + verb + '".'
            );
        }
    }

    // ========================================================================= helpers

    private static AAO_ProcessPanel.AssessmentRow rowFor(
        AAO_ProcessPanel.ProcessView v, String code
    ) {
        for (AAO_ProcessPanel.AssessmentRow r : v.assessment) {
            if (r.code == code) {
                return r;
            }
        }
        System.assert(false, 'No row for ' + code);
        return null;
    }

    private class Fixture {
        Id oppId;
        Id acctId;
        Id contactA;
        Id contactB;
        Id sourceId;
        Map<String, Id> contracts = new Map<String, Id>();
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Panel Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Panel Deal', AccountId = a.Id,
            StageName = 'Stage 2', CloseDate = Date.today().addDays(30)
        );
        insert o;
        List<Contact> cs = new List<Contact>{
            new Contact(FirstName = 'Ivan', LastName = 'Petrov', AccountId = a.Id),
            new Contact(FirstName = 'Gwen', LastName = 'Arkwright', AccountId = a.Id)
        };
        insert cs;

        Fixture f = new Fixture();
        f.oppId = o.Id;
        f.acctId = a.Id;
        f.contactA = cs[0].Id;
        f.contactB = cs[1].Id;

        // A REAL SOURCE. The hundred-fifty-sixth made the citation require a source reference
        // and a locator, so an answer whose span names no call now yields NO citation at all -
        // correctly, because that was the quotation the stamp refused. This fixture used to
        // assert a citation on spans with no sourceId, which is a shape the product no longer
        // produces; the fixture moves rather than the law.
        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = o.Id, AAO_Account__c = a.Id, AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c =
                '00000000000000000000000000000000000000000000000000000000000000ef',
            AAO_Part_Index__c = 1, AAO_Part_Count__c = 1,
            AAO_Diarization__c = 'Attributed',
            AAO_Meeting_Title__c = 'Panel fixture, call 1',
            AAO_Normalized_Text__c = 'ivan\tRoughly nine hours a week across the team.',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 8, 20, 15, 0, 0),
            AAO_Synthetic__c = true
        );
        insert src;
        f.sourceId = src.Id;

        List<AAO_Evidence_Contract__c> ecs = new List<AAO_Evidence_Contract__c>();
        Integer n = 1;
        for (String code : new List<String>{ 'AAO_PANEL_ONE', 'AAO_PANEL_TWO', 'AAO_PANEL_THREE' }) {
            ecs.add(new AAO_Evidence_Contract__c(
                AAO_Question_Record_Id__c = ('a0aPANELTEST0000' + n).left(18),
                AAO_Proposition_Code__c = code,
                AAO_Proposition_Short__c = 'The question ' + code + ' asks',
                AAO_Proposition_Text__c = 'Does ' + code + ' hold?',
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
                    '000000000000000000000000000000000000000000000000000000000000000' + n
            ));
            n++;
        }
        insert ecs;
        for (AAO_Evidence_Contract__c ec : ecs) {
            f.contracts.put(ec.AAO_Proposition_Code__c, ec.Id);
        }
        AAO_Synthetic.MARK = false;
        return f;
    }

    private static void establish(Fixture f, String code, String interpretation) {
        establishFor(f, code, interpretation, f.contactA);
    }

    private static void establishFor(
        Fixture f, String code, String interpretation, Id contactId
    ) {
        AAO_Synthetic.MARK = true;
        insert new AAO_Answer__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Evidence_Contract__c = f.contracts.get(code),
            AAO_Subject_Type__c = 'Contact',
            AAO_Subject_Contact__c = contactId,
            AAO_Verdict__c = 'TRUE',
            AAO_Interpretation__c = interpretation,
            AAO_Established_By__c = 'MACHINE',
            AAO_Basis__c = 'State',
            AAO_Publication_State__c = 'Live',
            AAO_Spans__c = JSON.serialize(new Map<String, Object>{
                'v' => 1,
                'spans' => new List<Object>{
                    new Map<String, Object>{
                        'sourceId' => f.sourceId,
                        'startOffset' => 5,
                        'endOffset' => 46,
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
