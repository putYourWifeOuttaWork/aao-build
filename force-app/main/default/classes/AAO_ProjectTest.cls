/**
 * The People projection writer.
 *
 * The derivation tests build answers in memory through JSON so the relationship field is
 * populated without a DML round trip. That is not a shortcut for its own sake: the derivation
 * tables are pure functions of standing verdicts, and testing them as pure functions is what
 * makes a table row fail loudly rather than fail somewhere inside a write.
 *
 * The write-leg tests use real records, because query-then-branch is exactly the part that
 * cannot be tested in memory.
 */
@IsTest
private class AAO_ProjectTest {
    /** An answer with only what the derivation reads: a code, a verdict, an occurred stamp. */
    private static AAO_Answer__c ans(String token, Id contactId, String verdict, Integer dayOfJune) {
        Map<String, Object> contract = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'AAO_Evidence_Contract__c' },
            'AAO_Proposition_Code__c' => token + AAO_PeopleContracts.SEP + contactId
        };
        Map<String, Object> row = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'AAO_Answer__c' },
            'AAO_Verdict__c' => verdict,
            'AAO_Subject_Contact__c' => contactId,
            'AAO_Publication_State__c' => 'Live',
            'AAO_Evidence_Occurred__c' => '2026-06-' +
                (dayOfJune < 10 ? '0' + dayOfJune : String.valueOf(dayOfJune)) +
                'T09:00:00.000Z',
            'AAO_Evidence_Contract__r' => contract
        };
        return (AAO_Answer__c) JSON.deserialize(JSON.serialize(row), AAO_Answer__c.class);
    }

    private static Id someone() {
        return AAO_FakeId.of(Contact.SObjectType);
    }

    // ================================================================ Support · the table

    @IsTest
    static void q2AloneMakesASupporter() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(
            new List<AAO_Answer__c>{ ans('S2', p, 'TRUE', 10) }
        );
        System.assertEquals('Supporter', d.support, 'Told you they prefer your solution.');
    }

    @IsTest
    static void mentorNeedsTwoEstablishmentsBeyondSupporter() {
        Id p = someone();
        // Q2 and Q4 without Q5 is still only a Supporter: two beyond Supporter to enter.
        System.assertEquals(
            'Supporter',
            AAO_Project.derive(
                    new List<AAO_Answer__c>{ ans('S2', p, 'TRUE', 10), ans('S4', p, 'TRUE', 11) }
                )
                .support
        );
        System.assertEquals(
            'Mentor',
            AAO_Project.derive(
                    new List<AAO_Answer__c>{
                        ans('S2', p, 'TRUE', 10),
                        ans('S4', p, 'TRUE', 11),
                        ans('S5', p, 'TRUE', 12)
                    }
                )
                .support,
            'Prefers ours, sells internally, mentoring us.'
        );
    }

    @IsTest
    static void theNegativeSideAndTheEnemySideAreSeparatePlacements() {
        Id p = someone();
        for (String q : new List<String>{ 'S6', 'S11', 'S14' }) {
            System.assertEquals(
                'Non-Supporter',
                AAO_Project.derive(new List<AAO_Answer__c>{ ans(q, p, 'TRUE', 10) }).support,
                q + ' prefers an alternative or is vocal for the competition.'
            );
        }
        for (String q : new List<String>{ 'S7', 'S16' }) {
            System.assertEquals(
                'Enemy',
                AAO_Project.derive(new List<AAO_Answer__c>{ ans(q, p, 'TRUE', 10) }).support,
                q + ' is positively established, never the far end of a scale.'
            );
        }
    }

    @IsTest
    static void q1OpensTheReadingAndPlacesNobody() {
        Id p = someone();
        System.assertEquals(
            null,
            AAO_Project.derive(new List<AAO_Answer__c>{ ans('S1', p, 'TRUE', 10) }).support,
            'The preference gate opens the reading and places nobody.'
        );
    }

    @IsTest
    static void neutralIsNeverComputed() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(new List<AAO_Answer__c>{});
        System.assertEquals(
            null,
            d.support,
            'Nothing established in either direction is a state of not knowing. Writing ' +
            '"Neutral" here would be the map asserting a balance nobody established.'
        );
        // And an UNVERIFIED establishes nothing, so it cannot place either.
        System.assertEquals(
            null,
            AAO_Project.derive(new List<AAO_Answer__c>{ ans('S2', p, 'UNVERIFIED', 10) }).support
        );
    }

    @IsTest
    static void whenBothSidesStandRecencyOwnsTheRung() {
        Id p = someone();
        // Negative in June 10, positive in June 20: the newer positive governs.
        AAO_Project.Derivation newer = AAO_Project.derive(
            new List<AAO_Answer__c>{ ans('S6', p, 'TRUE', 10), ans('S2', p, 'TRUE', 20) }
        );
        System.assertEquals('Supporter', newer.support);
        System.assertEquals(
            'negative',
            newer.displacedSide,
            'The displaced side becomes a contention flag of the opposite polarity, and the ' +
            'June evidence is never erased.'
        );

        // Reverse the clock and the darker rung governs, with a green flag owed.
        AAO_Project.Derivation older = AAO_Project.derive(
            new List<AAO_Answer__c>{ ans('S2', p, 'TRUE', 10), ans('S6', p, 'TRUE', 20) }
        );
        System.assertEquals('Non-Supporter', older.support);
        System.assertEquals('positive', older.displacedSide, 'History better than the present.');
    }

    // ====================================================== Political · the ceiling model

    @IsTest
    static void anyStrongSideAuthorityAloneReachesInnerCircle() {
        Id p = someone();
        for (String q : new List<String>{ 'PO1', 'PO2', 'PS4' }) {
            System.assertEquals(
                'Inner Circle',
                AAO_Project.derive(new List<AAO_Answer__c>{ ans(q, p, 'TRUE', 10) }).political,
                q + ': one establishment suffices. Easy in, easy out.'
            );
        }
    }

    @IsTest
    static void theWeakSideIsAffirmedByWordsAndNeverInferredFromAbsence() {
        Id p = someone();
        // A FALSE on a two-sided question is the weak side affirmatively established:
        // "he executes what others approve".
        System.assertEquals(
            'Political Structure',
            AAO_Project.derive(new List<AAO_Answer__c>{ ans('PO2', p, 'FALSE', 10) }).political,
            'Executes after approval is a placement, not a demotion.'
        );
        System.assertEquals(
            'Political Structure',
            AAO_Project.derive(new List<AAO_Answer__c>{ ans('PS4', p, 'FALSE', 10) }).political,
            'Called on to make it happen.'
        );
        // THE GUARD. Absence of strong-side evidence is UNVERIFIED, and UNVERIFIED places
        // nobody. Nothing may read a missing TRUE as a weak side.
        System.assertEquals(
            null,
            AAO_Project.derive(new List<AAO_Answer__c>{ ans('PO2', p, 'UNVERIFIED', 10) }).political,
            'An UNVERIFIED two-sided question places nobody. Reading it as the weak side ' +
            'would manufacture a placement out of not knowing.'
        );
    }

    @IsTest
    static void theOneSidedWeakQuestionsCountOnTheirTrue() {
        Id p = someone();
        for (String q : new List<String>{ 'PS3', 'PS6' }) {
            System.assertEquals(
                'Political Structure',
                AAO_Project.derive(new List<AAO_Answer__c>{ ans(q, p, 'TRUE', 10) }).political,
                q + ': sought out for advice, or a track record of delivery.'
            );
        }
    }

    @IsTest
    static void brokeringAloneIsOutsideTheStructure() {
        Id p = someone();
        System.assertEquals(
            'Outside Political Structure',
            AAO_Project.derive(new List<AAO_Answer__c>{ ans('PS7', p, 'TRUE', 10) }).political,
            'Connected to power without holding it.'
        );
    }

    @IsTest
    static void aLesserPropertyNeverDowngrades() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(
            new List<AAO_Answer__c>{
                ans('PO1', p, 'TRUE', 10), // defines the goals: Inner Circle
                ans('PS3', p, 'TRUE', 20), // later, sought out for advice: a lesser property
                ans('PS7', p, 'TRUE', 21) // later still, brokers information: lesser again
            }
        );
        System.assertEquals(
            'Inner Circle',
            d.political,
            'The ceiling is the highest placement the standing establishments support. A ' +
            'lesser property arriving later upgrades or does nothing; it never downgrades, ' +
            'and unlike Support this is not a contest and recency does not decide it.'
        );
    }

    @IsTest
    static void q9PlacesNobody() {
        Id p = someone();
        System.assertEquals(
            null,
            AAO_Project.derive(new List<AAO_Answer__c>{ ans('PO9', p, 'TRUE', 10) }).political,
            'Everyone worth mapping watches the politics. The savviness that matters shows ' +
            'up as brokering, which Q7 already catches.'
        );
    }

    @IsTest
    static void unsetLeavesTheFieldAloneRatherThanWritingUnknown() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(
            new List<AAO_Answer__c>{ ans('S2', p, 'TRUE', 10) }
        );
        System.assertEquals(
            null,
            d.political,
            'Nobody is placed outside the structure by absence of evidence. The picklist has ' +
            'an "Unknown" value and writing it would be a claim; null is the absence of one.'
        );
    }

    // ------------------------------------------------------------------ the note, Option C

    @IsTest
    static void theNoteExplainsTheValueShowingAndCarriesNoRecordId() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(
            new List<AAO_Answer__c>{ ans('S2', p, 'TRUE', 10), ans('PO1', p, 'TRUE', 11) }
        );
        System.assert(d.note.contains('Support: Supporter'), d.note);
        System.assert(d.note.contains('Political: Inner Circle'), d.note);
        System.assert(
            !d.note.contains('003') && !d.note.contains('a1S'),
            'Never a record id on a human surface. Got: ' + d.note
        );
        System.assert(d.note.contains('June 2026'), 'Plain date. Got: ' + d.note);
    }

    // ========================================================== the write, query-then-branch

    @IsTest
    static void theCreateLegBuildsTheRowWhenSyncNeverMadeOne() {
        Fixture f = fixture();
        // No map row exists. This is the leg the harness run does NOT exercise, because every
        // speaker on the Casey call holds a contact role and therefore already has a skeleton.
        // It is mandatory product behaviour all the same: contact-role sync is a customer
        // setting that can be off, and a person in the evidence must still be mapped.
        System.assertEquals(
            0,
            [
                SELECT COUNT()
                FROM ALTF__Contact_Map_Details__c
                WHERE ALTF__Contact__c = :f.contactId AND ALTF__Opportunity__c = :f.oppId
            ]
        );
        establish(f, 'S2', 'TRUE');

        Test.startTest();
        AAO_Project.Outcome o = AAO_Project.run(f.oppId);
        Test.stopTest();

        System.assertEquals(1, o.created, o.toString());
        AAO_Project.PersonResult r = o.people[0];
        System.assertEquals('created', r.action);
        System.assertEquals('Supporter', r.support);
        ALTF__Contact_Map_Details__c row = [
            SELECT ALTF__Status__c, ALTF__Political__c, ALTF__Note__c, ALTF__Buyer_Role__c
            FROM ALTF__Contact_Map_Details__c
            WHERE Id = :r.mapRowId
        ];
        System.assertEquals('Supporter', row.ALTF__Status__c);
        System.assertEquals(
            null,
            row.ALTF__Political__c,
            'Established dimensions populated, everything else null. A row filled out to ' +
            'look complete is a row claiming things nothing established.'
        );
        System.assertEquals(null, row.ALTF__Buyer_Role__c);
        System.assert(row.ALTF__Note__c.contains('Supporter'), row.ALTF__Note__c);
    }

    @IsTest
    static void thePopulateLegTouchesOnlyTheDimensionsEstablishmentMoved() {
        Fixture f = fixture();
        // The skeleton contact-role sync would have built, with a value we must not disturb.
        ALTF__Contact_Map_Details__c skeleton = new ALTF__Contact_Map_Details__c(
            ALTF__Account__c = f.acctId,
            ALTF__Opportunity__c = f.oppId,
            ALTF__Contact__c = f.contactId,
            ALTF__Buyer_Role__c = 'Decision Maker'
        );
        insert skeleton;
        establish(f, 'S2', 'TRUE');

        Test.startTest();
        AAO_Project.Outcome o = AAO_Project.run(f.oppId);
        Test.stopTest();

        System.assertEquals(1, o.populated, o.toString());
        System.assertEquals(new List<String>{ 'Support' }, o.people[0].dimensionsWritten);
        ALTF__Contact_Map_Details__c row = [
            SELECT ALTF__Status__c, ALTF__Political__c, ALTF__Buyer_Role__c
            FROM ALTF__Contact_Map_Details__c
            WHERE Id = :skeleton.Id
        ];
        System.assertEquals('Supporter', row.ALTF__Status__c);
        System.assertEquals(null, row.ALTF__Political__c, 'Nothing established it.');
        System.assertEquals(
            'Decision Maker',
            row.ALTF__Buyer_Role__c,
            'A dimension the evidence never spoke to is left exactly as it was found.'
        );
    }

    @IsTest
    static void twoRowsForOnePairBlockTheWriteAndRaiseAFlag() {
        Fixture f = fixture();
        insert new List<ALTF__Contact_Map_Details__c>{
            new ALTF__Contact_Map_Details__c(
                ALTF__Account__c = f.acctId,
                ALTF__Opportunity__c = f.oppId,
                ALTF__Contact__c = f.contactId
            ),
            new ALTF__Contact_Map_Details__c(
                ALTF__Account__c = f.acctId,
                ALTF__Opportunity__c = f.oppId,
                ALTF__Contact__c = f.contactId
            )
        };
        establish(f, 'S2', 'TRUE');

        Test.startTest();
        AAO_Project.Outcome o = AAO_Project.run(f.oppId);
        Test.stopTest();

        System.assertEquals(1, o.blocked, o.toString());
        System.assertEquals('blocked', o.people[0].action);
        System.assert(o.people[0].reason.contains('refuses to choose'), o.people[0].reason);
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM AAO_Flag__c
                WHERE AAO_Opportunity__c = :f.oppId AND AAO_Type__c = 'Cardinality'
            ],
            'Never pick. Picking one silently is how a projection starts overwriting a row ' +
            'nobody is looking at.'
        );
        for (ALTF__Contact_Map_Details__c row : [
            SELECT ALTF__Status__c FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c = :f.oppId
        ]) {
            System.assertEquals(null, row.ALTF__Status__c, 'Nothing was written to either row.');
        }
    }

    @IsTest
    static void aHeldAnswerNeverReachesACustomerRecord() {
        Fixture f = fixture();
        AAO_Answer__c a = establish(f, 'S2', 'TRUE');
        a.AAO_Publication_State__c = 'Held';
        update a;

        Test.startTest();
        AAO_Project.Outcome o = AAO_Project.run(f.oppId);
        Test.stopTest();

        System.assertEquals(0, o.created, 'Held is live for nothing.');
        System.assertEquals(0, o.populated);
        System.assertEquals(
            0,
            [SELECT COUNT() FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c = :f.oppId]
        );
    }

    // ---------------------------------------------------------------------- the fixture

    private class Fixture {
        Id oppId;
        Id acctId;
        Id contactId;
        Map<String, AAO_Evidence_Contract__c> contracts;
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Project Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Project Test Deal',
            AccountId = a.Id,
            StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        Contact c = new Contact(FirstName = 'Test', LastName = 'Person', AccountId = a.Id);
        insert c;

        Fixture f = new Fixture();
        f.oppId = o.Id;
        f.acctId = a.Id;
        f.contactId = c.Id;
        f.contracts = new Map<String, AAO_Evidence_Contract__c>();
        for (
            AAO_Evidence_Contract__c ec : AAO_PeopleContracts.build(new Set<Id>{ c.Id }).contracts
        ) {
            f.contracts.put(ec.AAO_Proposition_Code__c, ec);
        }
        AAO_Synthetic.MARK = false;
        return f;
    }

    /** A standing establishment on one People proposition for the fixture's person. */
    private static AAO_Answer__c establish(Fixture f, String token, String verdict) {
        String code = token + AAO_PeopleContracts.SEP + f.contactId;
        AAO_Evidence_Contract__c ec = f.contracts.get(code);
        System.assertNotEquals(null, ec, 'No contract for ' + code);
        AAO_Synthetic.MARK = true;
        AAO_Answer__c a = new AAO_Answer__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Evidence_Contract__c = ec.Id,
            AAO_Subject_Type__c = 'Contact',
            AAO_Subject_Contact__c = f.contactId,
            AAO_Verdict__c = verdict,
            AAO_Established_By__c = 'MACHINE',
            // State basis: a projected map value is cited by the rows its claim froze rather
            // than by a quote, which the evidence-family law exempts from the span requirement.
            AAO_Basis__c = 'State',
            AAO_Publication_State__c = 'Live',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 6, 24, 7, 1, 0)
        );
        insert a;
        AAO_Synthetic.MARK = false;
        return a;
    }
}
