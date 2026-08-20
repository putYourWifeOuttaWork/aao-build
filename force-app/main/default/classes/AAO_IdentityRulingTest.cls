/**
 * The hundred-twenty-fourth's derived-entity identity ruling, in the writers. Process step (e).
 *
 * The honest limit, stated because it is the shape of every test class here: these make no
 * callouts, so they prove the plumbing around the judgment and never the judgment itself. What
 * the model decides when it is handed a closed list is measured on a run, not asserted here.
 */
@IsTest
private class AAO_IdentityRulingTest {
    // ================================================================ the card lifecycle

    /**
     * **THE TWO CONDITIONS COLLAPSE TO ONE, and this pins the reading.** The ruling says
     * CONFIRMED needs more than one person AND more than one mention; two distinct people each
     * saying it once is already two mentions, so the second condition is entailed whenever the
     * first holds. What it really guards is one person saying a thing twice, and that fails the
     * first condition anyway.
     */
    @IsTest
    static void oneVOICEISUNCONFIRMEDANDTWOARECONFIRMED() {
        System.assertEquals('UNCONFIRMED', AAO_Cards.lifecycleOf(0), 'No voice at all.');
        System.assertEquals(
            'UNCONFIRMED', AAO_Cards.lifecycleOf(1),
            'One person saying it, however many times, is not confirmation.'
        );
        System.assertEquals(
            'CONFIRMED', AAO_Cards.lifecycleOf(2),
            'A second mouth is what confirms it, and two mouths are two mentions.'
        );
        System.assertEquals('CONFIRMED', AAO_Cards.lifecycleOf(5));
    }

    @IsTest
    static void theLIFECYCLEISCOMPUTEDFROMTHECARDSOWNLINKS() {
        Fixture f = fixture();
        ALTF__Insight_Card__c one = card(f, 'Obstacle', 'Sign-off chase');
        ALTF__Insight_Card__c two = card(f, 'Goal', 'Two large accounts per rep');
        link(f, one, f.contactA);
        link(f, two, f.contactA);
        link(f, two, f.contactB);

        Map<Id, String> states = AAO_Cards.lifecycleOn(f.oppId);

        System.assertEquals('UNCONFIRMED', states.get(one.Id), 'One voice.');
        System.assertEquals('CONFIRMED', states.get(two.Id), 'Two distinct voices.');
    }

    /**
     * A card nobody has linked yet is UNCONFIRMED rather than absent. Born at first
     * establishment, which is what "the field exists from birth" means when the field is a
     * computation.
     */
    @IsTest
    static void aCARDWITHNOLINKSISBORNUNCONFIRMED() {
        Fixture f = fixture();
        ALTF__Insight_Card__c c = card(f, 'Pressure', 'Board asking weekly');
        System.assertEquals('UNCONFIRMED', AAO_Cards.lifecycleOn(f.oppId).get(c.Id));
    }

    // ============================================================== the criterion match

    /**
     * **SAME MOUTH IS IGNORED**, and the match carries the mouth so the join does not have to
     * re-derive it. Three of the four duplicate criteria on the graded Wells Fargo deal are this
     * shape, so it is the common case rather than the edge.
     */
    @IsTest
    static void theSAMEMOUTHRESTATINGISMARKEDANDWRITESNOTHING() {
        Fixture f = fixture();
        AAO_Criterion__c standing = criterion(f, 'Closed model risk approval', f.participantA);
        AAO_Pair__c naming = namingPair(f, 'Model risk approval closed, not pending', f.participantA);

        AAO_CriterionMatch.stubbed = new Map<Id, Id>{ naming.Id => standing.Id };
        AAO_CriterionMatch.Outcome o = AAO_CriterionMatch.run(f.runKey);

        System.assertEquals(1, o.matched, 'Matched: ' + o);
        System.assertEquals(1, o.sameMouth, 'And the same person voiced both: ' + o);
        AAO_Pair__c after = [
            SELECT AAO_Criterion_Match__c, AAO_Criterion_Match_Same_Mouth__c
            FROM AAO_Pair__c WHERE Id = :naming.Id
        ];
        System.assertEquals(standing.Id, after.AAO_Criterion_Match__c);
        System.assertEquals(true, after.AAO_Criterion_Match_Same_Mouth__c);
    }

    /** A DIFFERENT mouth is the same criterion REINFORCED, which is F3's own cure. */
    @IsTest
    static void aDIFFERENTMOUTHREINFORCESRATHERTHANTWINNING() {
        Fixture f = fixture();
        AAO_Criterion__c standing = criterion(f, 'Pilot evidence measures', f.participantA);
        AAO_Pair__c naming = namingPair(f, 'Pilot evidence on three measures', f.participantB);

        AAO_CriterionMatch.stubbed = new Map<Id, Id>{ naming.Id => standing.Id };
        AAO_CriterionMatch.Outcome o = AAO_CriterionMatch.run(f.runKey);

        System.assertEquals(1, o.matched, 'Matched: ' + o);
        System.assertEquals(0, o.sameMouth, 'A different mouth: ' + o);
        System.assertEquals(
            false,
            [SELECT AAO_Criterion_Match_Same_Mouth__c FROM AAO_Pair__c WHERE Id = :naming.Id]
                .AAO_Criterion_Match_Same_Mouth__c,
            'So the join reinforces rather than ignoring.'
        );
    }

    /** No match is a new criterion, and the row says so by carrying nothing. */
    @IsTest
    static void noMATCHLEAVESTHEPAIRCLEANANDITMINTS() {
        Fixture f = fixture();
        criterion(f, 'Closed model risk approval', f.participantA);
        AAO_Pair__c naming = namingPair(f, 'Entity name alignment across documents', f.participantB);

        AAO_CriterionMatch.stubbed = new Map<Id, Id>();
        AAO_CriterionMatch.Outcome o = AAO_CriterionMatch.run(f.runKey);

        System.assertEquals(0, o.matched, 'Nothing matched: ' + o);
        System.assertEquals(1, o.fresh, 'One genuinely new condition: ' + o);
        System.assertEquals(
            null,
            [SELECT AAO_Criterion_Match__c FROM AAO_Pair__c WHERE Id = :naming.Id]
                .AAO_Criterion_Match__c
        );
    }

    /**
     * **A DEAL WITH NO STANDING CRITERIA SPENDS NO CALLOUT.** A closed list with nothing in it is
     * not a question, and asking it anyway would be a call bought for a foregone answer.
     */
    @IsTest
    static void anEMPTYBOARDASKSNOTHING() {
        Fixture f = fixture();
        namingPair(f, 'Entity name alignment across documents', f.participantA);

        AAO_CriterionMatch.Outcome o = AAO_CriterionMatch.run(f.runKey);

        System.assertEquals(1, o.fresh, 'New by construction: ' + o);
        System.assertEquals(0, Limits.getCallouts(), 'And nothing was spent finding that out.');
        System.assert(
            !o.notes.isEmpty() && o.notes[0].contains('no standing criteria'),
            'And it says why: ' + o.notes
        );
    }

    @IsTest
    static void aRUNTHATNAMESNOCRITERIONDOESNOTHINGATALL() {
        Fixture f = fixture();
        AAO_CriterionMatch.Outcome o = AAO_CriterionMatch.run('a-run-with-no-namings');
        System.assertEquals(0, o.considered, 'Nothing to consider: ' + o);
        System.assertEquals(0, Limits.getCallouts());
    }

    // ========================================================================= fixture

    private class Fixture {
        Id oppId;
        Id acctId;
        Id contactA;
        Id contactB;
        Id participantA;
        Id participantB;
        Id sourceId;
        String runKey = 'identity-ruling-test';
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Identity Ruling Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Identity Ruling Deal', AccountId = a.Id,
            StageName = 'Stage 2', CloseDate = Date.today().addDays(30)
        );
        insert o;
        List<Contact> cs = new List<Contact>{
            new Contact(FirstName = 'Katherine', LastName = 'Villanueva', AccountId = a.Id,
                Email = 'kv@buyer.example'),
            new Contact(FirstName = 'Dana', LastName = 'Whitfield', AccountId = a.Id,
                Email = 'dw@buyer.example')
        };
        insert cs;
        insert new AAO_Source__c(
            AAO_Opportunity__c = o.Id, AAO_Account__c = a.Id, AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c =
                '0000000000000000000000000000000000000000000000000000000000000088',
            AAO_Part_Index__c = 1, AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = 'kv\tWe need pilot evidence on three measures.',
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 8, 19, 15, 0, 0),
            AAO_Speaker_Roster__c = JSON.serialize(new Map<String, Object>{
                'v' => 1,
                'speakers' => new List<Object>{
                    new Map<String, Object>{ 'key' => 'kv', 'display' => 'Katherine Villanueva',
                        'email' => 'kv@buyer.example' },
                    new Map<String, Object>{ 'key' => 'dw', 'display' => 'Dana Whitfield',
                        'email' => 'dw@buyer.example' }
                }
            })
        );
        Fixture f = new Fixture();
        f.oppId = o.Id;
        f.acctId = a.Id;
        f.contactA = cs[0].Id;
        f.contactB = cs[1].Id;
        for (AAO_Participant__c p : [
            SELECT Id, AAO_Display_Name__c, AAO_Contact__c
            FROM AAO_Participant__c WHERE AAO_Opportunity__c = :o.Id
        ]) {
            if (p.AAO_Display_Name__c == 'Katherine Villanueva') {
                f.participantA = p.Id;
                update new AAO_Participant__c(Id = p.Id, AAO_Contact__c = cs[0].Id);
            } else {
                f.participantB = p.Id;
                update new AAO_Participant__c(Id = p.Id, AAO_Contact__c = cs[1].Id);
            }
        }
        f.sourceId = [SELECT Id FROM AAO_Source__c WHERE AAO_Opportunity__c = :o.Id LIMIT 1].Id;
        AAO_Synthetic.MARK = false;
        return f;
    }

    private static ALTF__Insight_Card__c card(Fixture f, String type, String face) {
        AAO_Synthetic.MARK = true;
        ALTF__Insight_Card__c c = new ALTF__Insight_Card__c(
            ALTF__Opportunity__c = f.oppId, ALTF__Account__c = f.acctId,
            ALTF__Type__c = type, ALTF__Short_Description__c = face
        );
        insert c;
        AAO_Synthetic.MARK = false;
        return c;
    }

    /**
     * The map row first, because the vendor refuses a card link to a contact who is not on the
     * relationship map. Built here rather than assumed, so the fixture is a shape the product
     * actually produces.
     */
    private static void onMap(Fixture f, Id contactId) {
        if (mapped.contains(contactId)) {
            return;
        }
        // **BUILT BY PROJECTION, NEVER BY HAND.** The vendor's own BeforeInsert trigger throws a
        // NullPointerException on a map row assembled in a test, and `AAO_ProjectTest` already
        // carries the lesson in its own words: a hand-built row is a shape the product never
        // produces, and that is the fixture mistake this build has now made three times. So the
        // person is established and projected, which is how a map row is made for real.
        AAO_Synthetic.MARK = true;
        insert new AAO_Answer__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Evidence_Contract__c = sentimentContract().Id,
            AAO_Subject_Type__c = 'Contact',
            AAO_Subject_Contact__c = contactId,
            AAO_Verdict__c = 'TRUE',
            AAO_Support_Counter__c = 2,
            AAO_Established_By__c = 'MACHINE',
            AAO_Basis__c = 'State',
            AAO_Publication_State__c = 'Live',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 8, 19, 15, 0, 0)
        );
        AAO_Synthetic.MARK = false;
        AAO_Project.run(f.oppId);
        mapped.add(contactId);
    }

    private static AAO_Evidence_Contract__c sentimentContract() {
        namingContract();
        return [
            SELECT Id FROM AAO_Evidence_Contract__c
            WHERE AAO_Proposition_Code__c = :AAO_P8Codes.SENTIMENT LIMIT 1
        ];
    }

    private static Set<Id> mapped = new Set<Id>();

    private static void link(Fixture f, ALTF__Insight_Card__c c, Id contactId) {
        onMap(f, contactId);
        AAO_Synthetic.MARK = true;
        insert new ALTF__Insight_Card_Contact__c(
            ALTF__Insight_Card__c = c.Id, ALTF__Contact__c = contactId, ALTF__Type__c = 'Informer'
        );
        AAO_Synthetic.MARK = false;
    }

    private static AAO_Criterion__c criterion(Fixture f, String subject, Id participantId) {
        AAO_Synthetic.MARK = true;
        AAO_Criterion__c c = new AAO_Criterion__c(
            AAO_Criterion_Key__c = f.oppId + '|' + subject.toLowerCase(),
            AAO_Subject__c = subject,
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Voiced_By__c = participantId,
            AAO_Source__c = f.sourceId,
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 8, 19, 15, 0, 0)
        );
        insert c;
        AAO_Synthetic.MARK = false;
        return c;
    }

    /** A located naming pair and the identified pair on top of it, the shape the pass leaves. */
    private static AAO_Pair__c namingPair(Fixture f, String name, Id participantId) {
        AAO_Evidence_Contract__c ec = namingContract();
        AAO_Synthetic.MARK = true;
        AAO_Pair__c located = new AAO_Pair__c(
            AAO_Run_Key__c = f.runKey,
            AAO_Stage__c = AAO_PairKey.LOCATED,
            AAO_Pair_Ref__c = 'r1q' + (counter++),
            AAO_Source__c = f.sourceId,
            AAO_Evidence_Contract__c = ec.Id,
            AAO_Criterion_Name__c = name,
            AAO_Answer_Text__c = 'We need ' + name + '.',
            AAO_Start_Offset__c = 3,
            AAO_End_Offset__c = 43,
            // The org's own law: "A Located pair must say which occurrence it is, one-based."
            AAO_Occurrence__c = 1,
            AAO_Occurrence_Count__c = 1,
            AAO_Speaker_Key__c = 'kv',
            AAO_Charter__c = 'test',
            AAO_Charter_Version__c = '1'
        );
        insert located;
        AAO_Pair__c identified = new AAO_Pair__c(
            AAO_Run_Key__c = f.runKey,
            AAO_Stage__c = AAO_PairKey.IDENTIFIED,
            AAO_Pair_Ref__c = located.AAO_Pair_Ref__c,
            AAO_Located_Pair__c = located.Id,
            AAO_Evidence_Contract__c = ec.Id,
            AAO_Disposition__c = 'Identified',
            AAO_Verification__c = 'Upheld',
            AAO_Person__c = participantId,
            AAO_Charter__c = 'test',
            AAO_Charter_Version__c = '1'
        );
        insert identified;
        AAO_Synthetic.MARK = false;
        return identified;
    }

    private static Integer counter = 1;

    private static AAO_Evidence_Contract__c namingContract() {
        List<AAO_Evidence_Contract__c> found = [
            SELECT Id FROM AAO_Evidence_Contract__c
            WHERE AAO_Proposition_Code__c = :AAO_P8Codes.CRITERION_NAMING LIMIT 1
        ];
        if (!found.isEmpty()) {
            return found[0];
        }
        AAO_Synthetic.MARK = true;
        AAO_PassContracts.mint();
        AAO_Synthetic.MARK = false;
        return [
            SELECT Id FROM AAO_Evidence_Contract__c
            WHERE AAO_Proposition_Code__c = :AAO_P8Codes.CRITERION_NAMING LIMIT 1
        ];
    }
}
