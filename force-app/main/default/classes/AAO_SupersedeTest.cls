/**
 * THE SUPERSESSION MECHANISM, and the backstop that must never fire.
 *
 * The hundred-seventeenth stamp's two blocking amendments live here: superseded means invisible
 * everywhere rather than only at replay, and **the backstop gets a test that proves it fires** -
 * because a backstop that never fires is only a fact if firing is provable, and otherwise it is
 * the green-suite hazard wearing a safety label.
 */
@IsTest
private class AAO_SupersedeTest {
    /**
     * AMENDMENT TWO · THE ALARM FIRES, PROVED.
     *
     * Two answers are forced onto one key by writing the same key twice. The unique index is the
     * integrity backstop under the hundred-sixteenth's ruling, and this asserts it actually
     * refuses - so "a duplicate is structurally impossible" is a measured property of the org and
     * not a belief about our own writers.
     */
    @IsTest
    static void theUniqueKeyBackstopActuallyRefusesADuplicate() {
        Fixture f = fixture();
        AAO_Answer__c first = answer(f);
        insert first;

        AAO_Answer__c second = answer(f);
        Boolean refused = false;
        String because;
        Test.startTest();
        try {
            insert second;
        } catch (DmlException e) {
            refused = true;
            because = e.getMessage();
        }
        Test.stopTest();

        System.assert(
            refused,
            'The unique key on AAO_Answer_Key__c did NOT refuse a second row carrying the same ' +
            'key. The backstop the hundred-sixteenth stamp relies on is not there, and every ' +
            'claim that a duplicate is structurally impossible rests on it.'
        );
        System.assert(
            because != null && because.contains('DUPLICATE_VALUE'),
            'Refused, but not as a duplicate: ' + because
        );
    }

    /**
     * AMENDMENT ONE · A SUPERSEDED ROW COUNTS NOWHERE.
     *
     * The tile is the surface that would have turned the fragmentation into inflated numbers, so
     * it is the one asserted here by name.
     */
    @IsTest
    static void aSupersededRowIsNotCounted() {
        Fixture f = fixture();
        AAO_Answer__c canonical = answer(f);
        insert canonical;

        AAO_Answer__c orphan = answer(f);
        orphan.AAO_Participant__c = f.otherParticipantId;
        // NO CONTACT, which is the whole shape of the defect: an earlier call wrote this before
        // the org had ever heard of the person, so A2 keyed it on the per-Source participant.
        orphan.AAO_Subject_Contact__c = null;
        insert orphan;

        Integer before = countAnswers(f.oppId);

        Test.startTest();
        orphan.AAO_Superseded_By__c = canonical.Id;
        update orphan;
        Test.stopTest();

        System.assertEquals(
            before - 1,
            countAnswers(f.oppId),
            'A superseded row still counted. The hundred-seventeenth stamp\'s first amendment ' +
            'exists because an uncounted double is quieter and worse than a collision.'
        );
    }

    /**
     * ACCEPTANCE · THE SUPERSEDED ROW\'S OWN REPLAY IS UNCHANGED.
     *
     * Supersession routes around history; it never rewrites it. The orphan keeps its pointer to
     * every claim it was written with, so reading it alone still reproduces what it said.
     */
    @IsTest
    static void supersessionDoesNotRewriteTheRowItRoutesAround() {
        Fixture f = fixture();
        AAO_Answer__c canonical = answer(f);
        insert canonical;
        AAO_Answer__c orphan = answer(f);
        orphan.AAO_Participant__c = f.otherParticipantId;
        // NO CONTACT, which is the whole shape of the defect: an earlier call wrote this before
        // the org had ever heard of the person, so A2 keyed it on the per-Source participant.
        orphan.AAO_Subject_Contact__c = null;
        insert orphan;

        String keyBefore = [
            SELECT AAO_Answer_Key__c FROM AAO_Answer__c WHERE Id = :orphan.Id
        ].AAO_Answer_Key__c;

        Test.startTest();
        orphan.AAO_Superseded_By__c = canonical.Id;
        update orphan;
        Test.stopTest();

        AAO_Answer__c after = [
            SELECT AAO_Answer_Key__c, AAO_Verdict__c, AAO_Superseded_By__c
            FROM AAO_Answer__c WHERE Id = :orphan.Id
        ];
        System.assertEquals(keyBefore, after.AAO_Answer_Key__c, 'the key must not move');
        System.assertEquals('TRUE', after.AAO_Verdict__c, 'the verdict must not move');
        System.assertEquals(canonical.Id, after.AAO_Superseded_By__c, 'the pointer is the marker');
    }

    /** Reconciling twice equals reconciling once: the repair sits on a driven path. */
    @IsTest
    static void reconcilingTwiceIsReconcilingOnce() {
        Fixture f = fixture();
        AAO_Answer__c canonical = answer(f);
        insert canonical;
        AAO_Answer__c orphan = answer(f);
        orphan.AAO_Participant__c = f.otherParticipantId;
        // NO CONTACT, which is the whole shape of the defect: an earlier call wrote this before
        // the org had ever heard of the person, so A2 keyed it on the per-Source participant.
        orphan.AAO_Subject_Contact__c = null;
        insert orphan;

        Test.startTest();
        orphan.AAO_Superseded_By__c = canonical.Id;
        update orphan;
        update orphan;
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Answer__c WHERE AAO_Superseded_By__c = :canonical.Id],
            'a second reconcile must change nothing'
        );
    }

    // ------------------------------------------------------------------------ the fixture

    private class Fixture {
        Id oppId;
        Id accountId;
        Id participantId;
        Id otherParticipantId;
        Id contractId;
        Id contactId;
    }

    private static Integer countAnswers(Id oppId) {
        return [
            SELECT COUNT() FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :oppId AND AAO_Superseded_By__c = null
        ];
    }

    private static AAO_Answer__c answer(Fixture f) {
        return new AAO_Answer__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.accountId,
            AAO_Publication_State__c = 'Live',
            AAO_Participant__c = f.participantId,
            AAO_Subject_Contact__c = f.contactId,
            AAO_Subject_Type__c = 'Participant',
            AAO_Evidence_Contract__c = f.contractId,
            AAO_Verdict__c = 'TRUE',
            // HUMAN-established on purpose. The write law requires a MACHINE establishment from
            // an artifact to carry byte-verified spans, and this fixture is testing supersession
            // bookkeeping rather than the citation law - inventing spans to get past a guard
            // would be testing around it.
            AAO_Established_By__c = 'HUMAN',
            AAO_Basis__c = 'Transcript',
            AAO_Spans__c = '[]'
        );
    }

    private static Fixture fixture() {
        Fixture f = new Fixture();
        Account a = new Account(Name = 'Supersede Test');
        insert a;
        Contact c = new Contact(FirstName = 'Kit', LastName = 'Aldana', AccountId = a.Id);
        insert c;
        Opportunity o = new Opportunity(
            Name = 'Supersede Test Deal', AccountId = a.Id,
            StageName = 'Stage 1', CloseDate = Date.today().addDays(30)
        );
        insert o;
        AAO_Source__c s = new AAO_Source__c(
            AAO_Opportunity__c = o.Id, AAO_Account__c = a.Id, AAO_Origin__c = 'ingest',
            AAO_Normalized_Text__c = 'kit\tWe need this.',
            AAO_Diarization__c = 'Attributed', AAO_Evidence_Occurred__c = System.now(),
            AAO_Artifact_SHA256__c = '11'.repeat(32), AAO_Part_Index__c = 1, AAO_Part_Count__c = 1
        );
        insert s;
        List<AAO_Participant__c> ps = new List<AAO_Participant__c>{
            // Both keys are required by the org - the participant key is one row per Source per
            // person, which is the very grain that made this whole defect possible.
            new AAO_Participant__c(AAO_Opportunity__c = o.Id, AAO_Source__c = s.Id,
                AAO_Display_Name__c = 'Kit Aldana', AAO_Contact__c = c.Id,
                AAO_Participant_Key__c = s.Id + '|kit aldana',
                AAO_Roster_Key__c = 'kit'),
            new AAO_Participant__c(AAO_Opportunity__c = o.Id, AAO_Source__c = s.Id,
                AAO_Display_Name__c = 'Kit Aldana (earlier call)',
                AAO_Participant_Key__c = s.Id + '|kit aldana earlier',
                AAO_Roster_Key__c = 'kit-earlier')
        };
        insert ps;
        f.oppId = o.Id;
        f.accountId = a.Id;
        f.contactId = c.Id;
        f.participantId = ps[0].Id;
        f.otherParticipantId = ps[1].Id;
        // Minted here rather than read from the org: a test that depends on org data is a test
        // that passes or fails on somebody else's seed.
        AAO_Evidence_Contract__c ec = new AAO_Evidence_Contract__c(
            AAO_Question_Record_Id__c = 'SUPERSEDE_Q1',
            AAO_Proposition_Code__c = 'SUPERSEDE_1',
            AAO_Proposition_Short__c = 'A question for the supersession fixture',
            AAO_Proposition_Text__c = 'Something this person said that establishes a value.',
            AAO_Guidance_Text__c = 'Guidance.',
            AAO_Elements__c = '[{"id":"e1","text":"the only part"}]',
            AAO_Element_Count__c = 1,
            AAO_Elements_Basis__c = 'Authored',
            AAO_Route__c = 'E',
            AAO_Speaker_Requirement__c = 'Any_Participant',
            AAO_Decay_Class__c = 'Standing',
            AAO_Gating__c = true,
            AAO_Contract_State__c = 'Ratified',
            AAO_Rubric_Version__c = 'supersede-v1'
        );
        insert ec;
        f.contractId = ec.Id;
        return f;
    }
}
