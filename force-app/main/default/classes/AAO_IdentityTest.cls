/**
 * The create leg, the name parse, and the toggle.
 *
 * The parse tests are pure functions and are asserted as such. The ladder tests use real
 * records, because every rung of it is a query-then-branch decision and there is nothing
 * honest to assert about one in memory.
 */
@IsTest
private class AAO_IdentityTest {
    // ================================================================== the name parse

    @IsTest
    static void theEciShapeParsesAndTheOrgPathIsNotPartOfAnybodysName() {
        // The 17 June fixture's own specimen, and the requirement that travelled with the
        // ruling: Contact creation never writes the mangled roster string as the name.
        AAO_PersonName.Parsed p = AAO_PersonName.parse('Vargas, Jefferson [EMR/SYSS/AT/MEDI]');
        System.assertEquals(true, p.ok(), 'refused: ' + p.refusedBecause);
        System.assertEquals('Jefferson', p.first);
        System.assertEquals('Vargas', p.last);
        System.assertEquals('Jefferson Vargas', p.display);
        System.assertEquals('Last, First', p.shape);
        System.assert(
            !p.display.contains('EMR') && !p.display.contains('['),
            'An internal routing code is not a name and must never reach a customer record. ' +
            'Got: ' + p.display
        );
    }

    @IsTest
    static void theOrdinaryShapesParse() {
        System.assertEquals('Chimata', AAO_PersonName.parse('Neeraja Chimata').last);
        System.assertEquals('Neeraja', AAO_PersonName.parse('Neeraja Chimata').first);
        System.assertEquals(
            'First Middle Last',
            AAO_PersonName.parse('Mary Jane Watson').shape
        );
        System.assertEquals('Jane', AAO_PersonName.parse('Mary Jane Watson').first.right(4));
        System.assertEquals(
            'Prince',
            AAO_PersonName.parse('Prince').last,
            'A surname alone is a real thing a roster carries, and Contact needs only a ' +
            'LastName, so it is a name rather than a refusal.'
        );
    }

    @IsTest
    static void titlesAndSuffixesAreNotNames() {
        AAO_PersonName.Parsed p = AAO_PersonName.parse('Dr. Ryan Couture Jr.');
        System.assertEquals('Couture', p.last);
        System.assertEquals('Ryan', p.first);
    }

    @IsTest
    static void anUnparseableStringRefusesRatherThanGuessing() {
        AAO_PersonName.Parsed p = AAO_PersonName.parse('[EMR/SYSS/AT/MEDI]');
        System.assertEquals(false, p.ok());
        System.assert(p.refusedBecause.contains('bracketed org path'), p.refusedBecause);

        AAO_PersonName.Parsed blank = AAO_PersonName.parse('   ');
        System.assertEquals(false, blank.ok());
        System.assert(
            blank.refusedBecause != null,
            'A refusal carries its reason, because a refusal is what holds somebody at ' +
            'shadow stage and an admin has to be able to read why.'
        );
    }

    @IsTest
    static void theParseIsDeterministic() {
        // The whole licence for parsing a person's name in code rather than asking a model:
        // the same string always parses the same way, so it is replayable by anyone holding
        // the source form.
        String raw = 'Vargas, Jefferson [EMR/SYSS/AT/MEDI]';
        String first = AAO_PersonName.parse(raw).display;
        for (Integer i = 0; i < 5; i++) {
            System.assertEquals(first, AAO_PersonName.parse(raw).display);
        }
    }

    // ======================================================================= the toggle

    @IsTest
    static void theToggleShipsOnAndAnUntouchedOrgGetsTheDefault() {
        // Matthew's ruling, 5 August. Design recommended OFF; both are recorded in the class.
        System.assertEquals(
            true,
            AAO_Settings.mayCreateContacts(),
            'Contact creation is allowed by default on an unconfigured org.'
        );
    }

    @IsTest
    static void anAbsentSettingReadsOffBecauseAbsenceIsNotPermission() {
        System.assertEquals(
            false,
            AAO_Settings.isOn('A_Setting_That_Does_Not_Exist'),
            'Anything governing a write into a customer\'s own records must never read a ' +
            'missing row as permission.'
        );
    }

    // ======================================================================== the ladder

    @IsTest
    static void anAlreadyLinkedPersonResolvesWithoutTouchingTheOrg() {
        Fixture f = fixture();
        AAO_Participant__c p = participant(f, 'linked', 'Mapped Buyer', 'buyer@customer.example');
        update new AAO_Participant__c(Id = p.Id, AAO_Contact__c = f.contactId);
        p = reread(p.Id);

        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId);
        System.assertEquals('resolved', r.action);
        System.assertEquals(f.contactId, r.contactId);
        System.assertEquals('the participation row', r.rung);
    }

    @IsTest
    static void emailResolvesAndTheAnswerIsWrittenBackOntoParticipation() {
        Fixture f = fixture();
        AAO_Participant__c p = participant(f, 'byemail', 'Mapped Buyer', 'buyer@customer.example');
        // Ingest already resolved this one by email, which is rung two doing its job one
        // stage earlier. Unlink it so the ladder is exercised rather than short-circuited at
        // rung one, which is exactly the state a person ingested before the Contact existed
        // is in.
        update new AAO_Participant__c(Id = p.Id, AAO_Contact__c = null);
        p = reread(p.Id);
        System.assertEquals(null, p.AAO_Contact__c, 'Not linked at the start.');

        Test.startTest();
        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId);
        Test.stopTest();

        System.assertEquals('resolved', r.action);
        System.assertEquals(f.contactId, r.contactId);
        System.assertEquals('email', r.rung);
        System.assertEquals(
            f.contactId,
            reread(p.Id).AAO_Contact__c,
            'Written back, so the next pass starts at rung one. Resolution is not a fact ' +
            'that stays true, and re-running the cheap legs is how a duplicate is avoided.'
        );
    }

    @IsTest
    static void nameResolvesWithinTheAccountOnly() {
        Fixture f = fixture();
        AAO_Participant__c p = participant(f, 'byname', 'Mapped Buyer', null);

        Test.startTest();
        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId);
        Test.stopTest();

        System.assertEquals('resolved', r.action);
        System.assertEquals(f.contactId, r.contactId);
        System.assertEquals('name, within the account', r.rung);
    }

    @IsTest
    static void twoContactsWithOneNameRefuseRatherThanPick() {
        Fixture f = fixture();
        insert new Contact(FirstName = 'Mapped', LastName = 'Buyer', AccountId = f.acctId);
        AAO_Participant__c p = participant(f, 'ambiguous', 'Mapped Buyer', null);

        Test.startTest();
        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId);
        Test.stopTest();

        System.assertNotEquals(
            'resolved',
            r.action,
            'Never pick. Picking would attach a call\'s worth of evidence to whichever row ' +
            'sorted first.'
        );
    }

    // ======================================================================= the create

    @IsTest
    static void theCreateLegMakesTheContactAndNeverWritesTheMangledString() {
        // Jefferson Vargas, the first live case.
        Fixture f = fixture();
        AAO_Settings.overrideForTest.put(AAO_Settings.CONTACT_CREATION, true);
        AAO_Participant__c p = participant(
            f, 'jefferson', 'Vargas, Jefferson [EMR/SYSS/AT/MEDI]', null
        );

        Test.startTest();
        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId);
        Test.stopTest();

        System.assertEquals('created', r.action, r.toString());
        System.assertEquals(true, r.reachesTheMap());
        Contact made = [
            SELECT FirstName, LastName, AccountId FROM Contact WHERE Id = :r.contactId
        ];
        System.assertEquals('Jefferson', made.FirstName);
        System.assertEquals('Vargas', made.LastName);
        System.assertEquals(f.acctId, made.AccountId);
        System.assert(
            !made.LastName.contains('[') && !made.LastName.contains('EMR'),
            'The requirement travelling with the ruling. Got: ' + made.LastName
        );
        System.assert(
            r.reason.contains('Vargas, Jefferson [EMR'),
            'And the source form is named in the reason, so the parse is auditable from the ' +
            'row it produced. Got: ' + r.reason
        );
    }

    @IsTest
    static void theToggleOffHoldsThePersonAtShadowStageWithTheSourceFormKept() {
        Fixture f = fixture();
        AAO_Settings.overrideForTest.put(AAO_Settings.CONTACT_CREATION, false);
        AAO_Participant__c p = participant(
            f, 'jefferson', 'Vargas, Jefferson [EMR/SYSS/AT/MEDI]', null
        );

        Test.startTest();
        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId);
        Test.stopTest();

        System.assertEquals('shadowed', r.action, r.toString());
        System.assertEquals(false, r.reachesTheMap());
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Contact WHERE AccountId = :f.acctId AND LastName = 'Vargas'],
            'Toggle off means no Contact is created, full stop.'
        );

        AAO_Shadow_Person__c sp = [
            SELECT AAO_Reason__c, AAO_Display_Name__c, AAO_Source_Name__c,
                AAO_First_Name__c, AAO_Last_Name__c, AAO_Shadow_Key__c
            FROM AAO_Shadow_Person__c
            WHERE Id = :r.shadowPersonId
        ];
        System.assertEquals('Toggle_Off', sp.AAO_Reason__c);
        System.assertEquals('Jefferson Vargas', sp.AAO_Display_Name__c);
        System.assertEquals(
            'Vargas, Jefferson [EMR/SYSS/AT/MEDI]',
            sp.AAO_Source_Name__c,
            'THE STORED-FORM LAW. Wrong text is marked wrong, never deleted - and re-deriving ' +
            'a name is only possible while what it was derived from still exists.'
        );
        System.assert(
            r.reason.contains('configuration rather than a failure'),
            'Expected-unavailable is configuration, not an error. Got: ' + r.reason
        );
    }

    @IsTest
    static void anUnparseableNameHoldsAtShadowRatherThanInventingAPerson() {
        Fixture f = fixture();
        AAO_Settings.overrideForTest.put(AAO_Settings.CONTACT_CREATION, true);
        AAO_Participant__c p = participant(f, 'orgpath', '[EMR/SYSS/AT/MEDI]', null);

        Test.startTest();
        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId);
        Test.stopTest();

        System.assertEquals('shadowed', r.action, r.toString());
        System.assertEquals(
            'Unresolvable',
            [SELECT AAO_Reason__c FROM AAO_Shadow_Person__c WHERE Id = :r.shadowPersonId]
                .AAO_Reason__c,
            'The toggle allowed a create and the parse refused one. A person with no ' +
            'recoverable name is not a person to invent.'
        );
    }

    @IsTest
    static void oneShadowPerPersonPerAccountHoweverManyRunsSeeThem() {
        Fixture f = fixture();
        AAO_Settings.overrideForTest.put(AAO_Settings.CONTACT_CREATION, false);
        AAO_Participant__c p = participant(
            f, 'jefferson', 'Vargas, Jefferson [EMR/SYSS/AT/MEDI]', null
        );

        Test.startTest();
        AAO_Identity.Resolution one = AAO_Identity.resolve(p, f.acctId);
        AAO_Identity.Resolution two = AAO_Identity.resolve(p, f.acctId);
        Test.stopTest();

        System.assertEquals(one.shadowPersonId, two.shadowPersonId);
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Shadow_Person__c WHERE AAO_Account__c = :f.acctId],
            'Keyed per account rather than per participation, because a participant row is ' +
            'per SOURCE and keying on it would make one person a new shadow on every call.'
        );
    }

    // ============================== match aggressively, create conservatively (80th stamp)

    /**
     * THE GIVEN-NAME RUNG. Speech is full of lone first names; a roster string's lone token is a
     * surname. Same parser, opposite reading, so this rung searches BOTH and the ladder stops
     * depending on which class of input happened to arrive.
     */
    @IsTest
    static void aSingleSpokenTokenLinksToAGivenNameOnTheAccount() {
        Fixture f = fixture();
        AAO_Settings.overrideForTest.put(AAO_Settings.CONTACT_CREATION, true);
        // "Mapped Buyer" is seeded on the account. The transcript said only "Mapped".
        AAO_Participant__c p = participant(f, 'mention:mapped', 'Mapped', null);

        Test.startTest();
        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId, f.oppId);
        Test.stopTest();

        System.assertEquals('resolved', r.action, r.toString());
        System.assertEquals(
            f.contactId, r.contactId,
            'It linked the person who already exists rather than minting a second one. Before ' +
            'this rung, rung 3 searched LastName only and this created.'
        );
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Contact WHERE AccountId = :f.acctId],
            'And nothing was created.'
        );
    }

    /**
     * A SINGLE TOKEN CAN LINK AND CAN NEVER CREATE, with the toggle ON, which is the whole
     * point: this is a bar rather than a configuration.
     *
     * The measured case, eightieth stamp: Contact `003WD00001RCfLzYAL`, LastName "Fatima", no
     * first name, no email, no title, created onto Emerson Electric Co. and then writing
     * `Signature Approver` at rank 5 onto a relationship map a seller reads. Fatema Choudray,
     * VP Premier Sales Performance, was already on that account and is the same human.
     */
    @IsTest
    static void aSingleTokenNEVERCREATESEVENWITHTHETOGGLEON() {
        Fixture f = fixture();
        AAO_Settings.overrideForTest.put(AAO_Settings.CONTACT_CREATION, true);
        AAO_Participant__c p = participant(f, 'mention:jacob', 'Jacob', null);

        Test.startTest();
        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId, f.oppId);
        Test.stopTest();

        System.assertEquals('shadowed', r.action, r.toString());
        System.assertEquals(
            'Single_Token',
            [SELECT AAO_Reason__c FROM AAO_Shadow_Person__c WHERE Id = :r.shadowPersonId]
                .AAO_Reason__c
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Contact WHERE LastName = 'Jacob'],
            'ONE WORD NEVER MINTS A PERSON. The twenty-fourth stamp believed the LastName ' +
            'requirement guaranteed this; it never did, because one token satisfies the schema.'
        );
    }

    /**
     * FATEMA IS THE ACCEPTANCE CASE, and this test records the honest limit rather than a
     * flattering one.
     *
     * The rung matches EXACTLY, as every rung on this ladder always has. The ASR heard "Fatima"
     * and the CRM carries "Fatema", one character apart, so the rung returns zero and does NOT
     * link them. Fuzzy matching is not ruled and is not invented here: a resolver that guesses
     * at near-spellings attaches a call's worth of evidence to whoever sorted closest. What
     * protects this row is the creation bar, and the assertion that matters is that no twin
     * exists afterwards.
     */
    @IsTest
    static void theMISHEARDSPELLINGDOESNOTLINKANDCRUCIALLYDOESNOTCREATE() {
        Fixture f = fixture();
        AAO_Settings.overrideForTest.put(AAO_Settings.CONTACT_CREATION, true);
        insert new Contact(
            FirstName = 'Fatema', LastName = 'Choudray', AccountId = f.acctId,
            Title = 'VP, Premier Sales Performance'
        );
        AAO_Participant__c p = participant(f, 'mention:fatima', 'Fatima', null);

        Test.startTest();
        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId, f.oppId);
        Test.stopTest();

        System.assertEquals(
            'shadowed', r.action,
            'One character apart is not a match, and this ladder does not guess. ' + r.toString()
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Contact WHERE LastName = 'Fatima'],
            'AND THE DEFECT IS CLOSED WHERE IT ACTUALLY BIT: no twin is minted. Fatema keeps ' +
            'being the only Fatema on the account.'
        );
        System.assert(
            r.reason.contains('Fatema'),
            'The reason names the measured case so the next reader knows why the bar exists. ' +
            'Got: ' + r.reason
        );
    }

    @IsTest
    static void twoPeopleAnsweringToOneSpokenWordHOLDANDARENEVERPICKED() {
        Fixture f = fixture();
        AAO_Settings.overrideForTest.put(AAO_Settings.CONTACT_CREATION, true);
        // One carries it as a given name, one as a family name. Both answer to the word.
        insert new List<Contact>{
            new Contact(FirstName = 'Sam', LastName = 'Ladva', AccountId = f.acctId),
            new Contact(FirstName = 'Rita', LastName = 'Sam', AccountId = f.acctId)
        };
        AAO_Participant__c p = participant(f, 'mention:sam', 'Sam', null);

        Test.startTest();
        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId, f.oppId);
        Test.stopTest();

        System.assertEquals('shadowed', r.action, r.toString());
        System.assertEquals(
            'Ambiguous',
            [SELECT AAO_Reason__c FROM AAO_Shadow_Person__c WHERE Id = :r.shadowPersonId]
                .AAO_Reason__c,
            'More than one is AMBIGUOUS and holds. Never pick.'
        );
    }

    /**
     * A REAL FULL NAME STILL CREATES. The bar is on one token, not on creation, and a test
     * that only proved things stopped happening would not notice if it had stopped them all.
     */
    @IsTest
    static void theCREATELEGSTILLRUNSFORAWHOLENAME() {
        Fixture f = fixture();
        AAO_Settings.overrideForTest.put(AAO_Settings.CONTACT_CREATION, true);
        AAO_Participant__c p = participant(f, 'dan', 'Lewis, Dan', null);

        Test.startTest();
        AAO_Identity.Resolution r = AAO_Identity.resolve(p, f.acctId, f.oppId);
        Test.stopTest();

        System.assertEquals('created', r.action, r.toString());
        Contact made = [SELECT FirstName, LastName FROM Contact WHERE Id = :r.contactId];
        System.assertEquals('Dan', made.FirstName);
        System.assertEquals('Lewis', made.LastName);
    }

    // ---------------------------------------------------------------------- fixtures

    private class Fixture {
        Id acctId;
        Id oppId;
        Id contactId;
        Id sourceId;
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        Fixture f = new Fixture();
        Account a = new Account(Name = 'AAO Identity Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Identity Test Deal',
            AccountId = a.Id,
            StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        Contact c = new Contact(
            FirstName = 'Mapped', LastName = 'Buyer', AccountId = a.Id,
            Email = 'buyer@customer.example'
        );
        insert c;
        f.acctId = a.Id;
        f.oppId = o.Id;
        f.contactId = c.Id;
        return f;
    }

    /**
     * Participation is written by the Source after-insert and never by hand, so the fixture
     * builds a Source carrying the roster and reads the row back.
     */
    private static Integer artifact = 0;

    private static AAO_Participant__c participant(
        Fixture f,
        String rosterKey,
        String display,
        String email
    ) {
        artifact++;
        AAO_Synthetic.MARK = true;
        Map<String, Object> speaker = new Map<String, Object>{
            'key' => rosterKey,
            'display' => display
        };
        if (email != null) {
            speaker.put('email', email);
        }
        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c =
                '00000000000000000000000000000000000000000000000000000000000000'.right(62) +
                (artifact < 10 ? '0' + artifact : String.valueOf(artifact)),
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = rosterKey + '\tSomething was said.',
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 6, 17, 15, 0, 0),
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{ 'speakers' => new List<Object>{ speaker } }
            ),
            AAO_Synthetic__c = true
        );
        insert src;
        AAO_Synthetic.MARK = false;
        f.sourceId = src.Id;
        return [
            SELECT Id, AAO_Contact__c, AAO_Email__c, AAO_Roster_Key__c, AAO_Display_Name__c,
                AAO_Source__c
            FROM AAO_Participant__c
            WHERE AAO_Source__c = :src.Id AND AAO_Roster_Key__c = :rosterKey
            LIMIT 1
        ];
    }

    private static AAO_Participant__c reread(Id id) {
        return [
            SELECT Id, AAO_Contact__c, AAO_Email__c, AAO_Roster_Key__c, AAO_Display_Name__c,
                AAO_Source__c
            FROM AAO_Participant__c
            WHERE Id = :id
        ];
    }
}