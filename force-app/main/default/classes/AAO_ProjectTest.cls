/**
 * The People projection writer, against `people-p8-v1`.
 *
 * The derivation tests build answers in memory through JSON so the relationship field is
 * populated without a DML round trip. That is not a shortcut for its own sake: the derivation
 * tables are pure functions of standing verdicts, and testing them as pure functions is what
 * makes a table row fail loudly rather than fail somewhere inside a write.
 *
 * The write-leg tests use real records, because query-then-branch is exactly the part that
 * cannot be tested in memory.
 *
 * **THIS FILE WAS REWRITTEN AT THE RE-AIM, and the reason is the point.** Its previous
 * eighteen tests all passed, all of them against `people-om-v1` codes (`S2#003WD...`), while
 * the class they tested could not place a single one of the seventeen codes the pass actually
 * emits. A suite can be green and irrelevant at the same time. The tests below use the codes
 * the declared set really mints, and `theWriterPlacesEveryCodeTheDeclaredSetMints` is the one
 * that would have caught it: it holds the placement map against `AAO_PassContracts.specs()`
 * rather than against a hand-written list, so drift fails a build instead of a run.
 */
@IsTest
private class AAO_ProjectTest {
    /** An answer with only what the derivation reads: a code, a verdict, an occurred stamp. */
    private static AAO_Answer__c ans(String code, Id contactId, String verdict, Integer dayOfJune) {
        return ans(code, contactId, verdict, dayOfJune, null, null);
    }

    private static AAO_Answer__c ans(
        String code,
        Id contactId,
        String verdict,
        Integer dayOfJune,
        Integer counter,
        String interpretation
    ) {
        Map<String, Object> contract = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'AAO_Evidence_Contract__c' },
            'AAO_Proposition_Code__c' => code
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
        if (counter != null) {
            row.put('AAO_Support_Counter__c', counter);
        }
        if (interpretation != null) {
            row.put('AAO_Interpretation__c', interpretation);
        }
        return (AAO_Answer__c) JSON.deserialize(JSON.serialize(row), AAO_Answer__c.class);
    }

    private static Id someone() {
        return AAO_FakeId.of(Contact.SObjectType);
    }

    // ============================================== the guard the re-aim exists to install

    @IsTest
    static void theWriterPlacesEveryCodeTheDeclaredSetMints() {
        // THE TEST THAT WOULD HAVE CAUGHT v3.9's DEFECT. Held against the declared set itself
        // rather than a list somebody remembered to update, and symmetric: a contract with no
        // placement is an answer the writer skips in silence, and a placement with no contract
        // is a rule for a question nobody asks.
        AAO_P8Codes.assertCovers(AAO_PassContracts.specs());
    }

    @IsTest
    static void anUnplaceableCodeIsCountedAndNamedRatherThanSkipped() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(
            new List<AAO_Answer__c>{
                ans('S2#' + p, p, 'TRUE', 10), // the retired person-crossed shape
                ans('AAO_POL_IC1', p, 'TRUE', 11)
            }
        );
        System.assertEquals(1, d.unplaced, 'unit: answers');
        System.assert(d.unplacedCodes.contains('S2#' + p), d.unplacedCodes + '');
        System.assertEquals(
            'Inner Circle',
            d.political,
            'The placeable answer still places. An unrecognised code costs its own answer ' +
            'and never the whole derivation.'
        );

        AAO_Project.Outcome o = new AAO_Project.Outcome();
        o.answersRead = 2;
        o.answersUnplaced = 1;
        o.unplacedCodes.add('S2#' + p);
        String s = o.toString();
        System.assert(s.contains('answers unplaced         1'), 'Got: ' + s);
        System.assert(
            s.contains('UNPLACED CODES'),
            'A code the writer cannot place is named in the run report, because that is the ' +
            'exact state that reported success while writing nothing. Got: ' + s
        );
    }

    // ==================================================== Support · the counter owns the rung

    @IsTest
    static void theRungComesOffTheCounterAndNotOffAQuiz() {
        Id p = someone();
        Map<Integer, String> ruled = new Map<Integer, String>{
            3 => 'Mentor',
            2 => 'Supporter',
            1 => 'Supporter',
            -1 => 'Non-Supporter',
            -2 => 'Non-Supporter',
            -3 => 'Enemy'
        };
        for (Integer at : ruled.keySet()) {
            AAO_Project.Derivation d = AAO_Project.derive(
                new List<AAO_Answer__c>{ ans(AAO_P8Codes.SENTIMENT, p, 'TRUE', 10, at, 'SUPPORTER') }
            );
            System.assertEquals(ruled.get(at), d.support, 'counter ' + at);
            System.assertEquals(at, d.supportCounter, 'The standing value travels with the rung.');
        }
    }

    @IsTest
    static void neutralIsDerivedAndNeverWritten() {
        Id p = someone();
        System.assertEquals(
            null,
            AAO_Project.derive(new List<AAO_Answer__c>{}).support,
            'Nothing established is a state of not knowing. Writing "Neutral" here would be ' +
            'the map asserting a balance nobody voiced.'
        );
        System.assertEquals(
            null,
            AAO_Project.derive(
                    new List<AAO_Answer__c>{ ans(AAO_P8Codes.SENTIMENT, p, 'TRUE', 10, 0, 'SUPPORTER') }
                )
                .support,
            'A counter resting at zero is Neutral, and Neutral is the derived reading rather ' +
            'than a value: the field is left alone.'
        );
        System.assertEquals(
            null,
            AAO_Project.derive(
                    new List<AAO_Answer__c>{ ans(AAO_P8Codes.SENTIMENT, p, 'UNVERIFIED', 10, 2, 'SUPPORTER') }
                )
                .support,
            'An UNVERIFIED establishes nothing, so its counter places nobody either.'
        );
    }

    // ====================================================== Political · the ceiling model

    @IsTest
    static void eachOneWayHalfPlacesExactlyWhereItsContractSays() {
        Id p = someone();
        Map<String, String> ruled = new Map<String, String>{
            'AAO_POL_IC1' => 'Inner Circle',
            'AAO_POL_IC2' => 'Inner Circle',
            'AAO_POL_IC3' => 'Inner Circle',
            'AAO_POL_PS1' => 'Political Structure',
            'AAO_POL_PS2' => 'Political Structure',
            'AAO_POL_PS3' => 'Political Structure',
            'AAO_POL_PS4' => 'Political Structure',
            'AAO_POL_OPS1' => 'Outside Political Structure'
        };
        for (String code : ruled.keySet()) {
            System.assertEquals(
                ruled.get(code),
                AAO_Project.derive(new List<AAO_Answer__c>{ ans(code, p, 'TRUE', 10) }).political,
                code + ': one establishment suffices at every level.'
            );
        }
    }

    @IsTest
    static void theWeakSidesAreTheirOwnContractsSoNoVerdictIsReadForItsFalseness() {
        Id p = someone();
        // THE GUARD, RETIRED RATHER THAN RELAXED. Under the retired two-sided shape the weak
        // side had to be read off a FALSE, with a standing rule that a FALSE places somebody
        // only where words affirmatively support the weak side. PS1 and PS2 are now those
        // words' own contracts, so the thing the guard protected against cannot be expressed:
        // nothing on this dimension is read for its falseness anywhere.
        System.assertEquals(
            null,
            AAO_Project.derive(new List<AAO_Answer__c>{ ans('AAO_POL_IC2', p, 'FALSE', 10) }).political,
            'Not approving initiatives is not a placement. The words that ARE a placement ' +
            'answer AAO_POL_PS1, which points one way and carries its own quote.'
        );
        System.assertEquals(
            null,
            AAO_Project.derive(new List<AAO_Answer__c>{ ans('AAO_POL_IC3', p, 'UNVERIFIED', 10) }).political,
            'An UNVERIFIED places nobody. Reading it as the weak side would manufacture a ' +
            'placement out of not knowing.'
        );
    }

    @IsTest
    static void aLesserPropertyNeverDowngrades() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(
            new List<AAO_Answer__c>{
                ans('AAO_POL_IC1', p, 'TRUE', 10), // defines the goals: Inner Circle
                ans('AAO_POL_PS3', p, 'TRUE', 20), // later, sought out for advice: lesser
                ans('AAO_POL_OPS1', p, 'TRUE', 21) // later still, brokers information: lesser
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
    static void unsetLeavesTheFieldAloneRatherThanWritingUnknown() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(
            new List<AAO_Answer__c>{ ans(AAO_P8Codes.SENTIMENT, p, 'TRUE', 10, 2, 'SUPPORTER') }
        );
        System.assertEquals(
            null,
            d.political,
            'Nobody is placed outside the structure by absence of evidence. The picklist has ' +
            'an "Unknown" value and writing it would be a claim; null is the absence of one.'
        );
    }

    // ======================================================================== Buyer Role

    @IsTest
    static void eachRoleContractEstablishesItsOwnVendorValue() {
        Id p = someone();
        Map<String, String> ruled = new Map<String, String>{
            'AAO_BR_APP' => 'Approver',
            'AAO_BR_DM' => 'Decision Maker',
            'AAO_BR_EVAL' => 'Evaluator',
            'AAO_BR_USER' => 'User',
            'AAO_BR_SIG' => 'Signature Approver'
        };
        for (String code : ruled.keySet()) {
            System.assertEquals(
                ruled.get(code),
                AAO_Project.derive(new List<AAO_Answer__c>{ ans(code, p, 'TRUE', 10) }).buyerRole,
                code + ' writes the vendor picklist value byte-exact.'
            );
        }
    }

    @IsTest
    static void severalRolesRefuseToChooseRatherThanRankingWhatNobodyRanked() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(
            new List<AAO_Answer__c>{
                ans('AAO_BR_EVAL', p, 'TRUE', 10),
                ans('AAO_BR_USER', p, 'TRUE', 11)
            }
        );
        System.assertEquals(
            null,
            d.buyerRole,
            'The field holds one value and the evidence establishes two. There is no authored ' +
            'ordering among the five, so picking would be the machine deciding what outranks ' +
            'what - the same line that keeps a discovered criterion from raising a flag.'
        );
        System.assertEquals(new List<String>{ 'Evaluator', 'User' }, d.buyerRoleCollision);
        System.assert(
            d.note != null && d.note.contains('Evaluator, User'),
            'The refusal says so on the surface the seller reads. A blank field beside two ' +
            'established roles is exactly the silence this design exists to end. Got: ' + d.note
        );
    }

    // ========================================================================== criteria

    @IsTest
    static void criteriaAreDerivedTypedByProvenanceAndDoNotReachTheMapRow() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(
            new List<AAO_Answer__c>{
                ans(AAO_P8Codes.CRITERION_NAMING, p, 'TRUE', 10, null, 'Must integrate with SAP'),
                ans(AAO_P8Codes.CRITERION_FORMAL, p, 'TRUE', 10)
            }
        );
        System.assertEquals(1, d.criteria.size(), 'unit: criteria');
        System.assertEquals('Must integrate with SAP', d.criteria[0].subject);
        System.assertEquals(
            'Formal',
            d.criteria[0].criterionType,
            'Typing is by provenance: organizational standing spoken makes it Formal.'
        );
        System.assertEquals(false, d.criteria[0].required, 'The gate defaults unchecked.');
        System.assertEquals(
            false,
            d.placesAnybody(),
            'Criteria are records with holder junctions, not map-row dimensions. A person who ' +
            'named a criterion and nothing else moves no dimension on the map.'
        );
        System.assert(
            d.valuesDerived().contains(AAO_P8Codes.DIM_CRITERIA),
            'They are still counted, or a criteria-only read would report as derived nothing.'
        );
    }

    @IsTest
    static void aNamingWithNoAttributionDefaultsInformalAndIsNotAFailure() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(
            new List<AAO_Answer__c>{
                ans(AAO_P8Codes.CRITERION_NAMING, p, 'TRUE', 10, null, 'Onboarding inside 30 days'),
                ans(AAO_P8Codes.CRITERION_REQUIRED, p, 'TRUE', 10)
            }
        );
        System.assertEquals('Informal', d.criteria[0].criterionType);
        System.assertEquals(true, d.criteria[0].required, 'Gate language was spoken.');
    }

    // ------------------------------------------------------------------ the note, Option C

    @IsTest
    static void theNoteExplainsTheValueShowingAndCarriesNoRecordId() {
        Id p = someone();
        AAO_Project.Derivation d = AAO_Project.derive(
            new List<AAO_Answer__c>{
                ans(AAO_P8Codes.SENTIMENT, p, 'TRUE', 10, 2, 'SUPPORTER'),
                ans('AAO_POL_IC1', p, 'TRUE', 11),
                ans('AAO_BR_DM', p, 'TRUE', 11)
            }
        );
        System.assert(d.note.contains('Support: Supporter'), d.note);
        System.assert(d.note.contains('Political: Inner Circle'), d.note);
        System.assert(d.note.contains('Buyer Role: Decision Maker'), d.note);
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
        establish(f, AAO_P8Codes.SENTIMENT, 'TRUE', 2);

        Test.startTest();
        AAO_Project.Outcome o = AAO_Project.run(f.oppId);
        Test.stopTest();

        System.assertEquals(1, o.created, o.toString());
        AAO_Project.PersonResult r = o.people[0];
        System.assertEquals('created', r.action);
        System.assertEquals('Supporter', r.support);
        System.assertEquals(
            1,
            o.writesByDimension.get(AAO_P8Codes.DIM_SUPPORT),
            'The stage arithmetic counts the value out. unit: values'
        );
        System.assertEquals(false, o.derivedNothing(), o.toString());
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
        establish(f, AAO_P8Codes.SENTIMENT, 'TRUE', 2);

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
        establish(f, AAO_P8Codes.SENTIMENT, 'TRUE', 2);

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
        AAO_Answer__c a = establish(f, AAO_P8Codes.SENTIMENT, 'TRUE', 2);
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

    @IsTest
    static void anIdentifiedPersonWithNoContactIsReportedUnresolvedAndNeverAsSilence() {
        // Jefferson Vargas, the standing specimen: identified on the 17 June fixture, no
        // Contact record at all. The derivation succeeds and the write cannot land, because
        // ALTF__Contact_Map_Details__c.ALTF__Contact__c is required. That is a different fact
        // from the evidence establishing nothing, and folding the two together is how a
        // person disappears out of a run that reports success.
        Fixture f = fixture();
        AAO_Participant__c unlinked = participantWithNoContact(f);
        establishFor(f, AAO_P8Codes.SENTIMENT, 'TRUE', 2, unlinked.Id);

        Test.startTest();
        AAO_Project.Outcome o = AAO_Project.run(f.oppId);
        Test.stopTest();

        System.assertEquals(1, o.unresolved, o.toString());
        System.assertEquals(0, o.created);
        AAO_Project.PersonResult r = o.people[0];
        System.assertEquals('unresolved', r.action);
        System.assertEquals('Supporter', r.support, 'The derivation stands on our own rows.');
        System.assert(r.reason.contains('no map row can be reached'), r.reason);
        System.assertEquals(
            1,
            o.writesByDimension.get(AAO_P8Codes.DIM_SUPPORT),
            'The value was derived. What failed is the projection, not the read.'
        );
    }

    // ---------------------------------------------------------------------- the fixture

    private class Fixture {
        Id oppId;
        Id acctId;
        Id contactId;
        Id sourceId;
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
        AAO_PassContracts.mint();
        for (AAO_Evidence_Contract__c ec : [
            SELECT Id, AAO_Proposition_Code__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Rubric_Version__c = :AAO_PassContracts.RUBRIC_VERSION
                AND AAO_Contract_State__c != 'Superseded'
        ]) {
            f.contracts.put(ec.AAO_Proposition_Code__c, ec);
        }
        AAO_Synthetic.MARK = false;
        return f;
    }

    /**
     * A participant with no Contact. Participation is only ever written by
     * `AAO_Participants.record` on Source insert, so this builds the Source rather than
     * hand-inserting the junction - the same mistake was made twice before it was journalled.
     */
    private static AAO_Participant__c participantWithNoContact(Fixture f) {
        AAO_Synthetic.MARK = true;
        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c = '0000000000000000000000000000000000000000000000000000000000000017',
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = 'jefferson\tNo contact exists for this person.',
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 6, 17, 15, 0, 0),
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{
                    'speakers' => new List<Object>{
                        new Map<String, Object>{
                            'key' => 'jefferson',
                            'display' => 'Jefferson Vargas',
                            'email' => 'jvargas@example.invalid'
                        }
                    }
                }
            ),
            AAO_Synthetic__c = true
        );
        insert src;
        AAO_Synthetic.MARK = false;
        f.sourceId = src.Id;
        List<AAO_Participant__c> found = [
            SELECT Id, AAO_Contact__c
            FROM AAO_Participant__c
            WHERE AAO_Source__c = :src.Id AND AAO_Contact__c = NULL
            LIMIT 1
        ];
        System.assertEquals(
            1,
            found.size(),
            'The fixture needs a participant with no Contact, and participation is written ' +
            'by the Source after-insert rather than by hand.'
        );
        return found[0];
    }

    private static AAO_Answer__c establish(
        Fixture f,
        String code,
        String verdict,
        Integer counter
    ) {
        return establishRow(f, code, verdict, counter, f.contactId, null, 'Contact');
    }

    private static AAO_Answer__c establishFor(
        Fixture f,
        String code,
        String verdict,
        Integer counter,
        Id participantId
    ) {
        return establishRow(f, code, verdict, counter, null, participantId, 'Participant');
    }

    /** A standing establishment on one §P8 proposition for the fixture's person. */
    private static AAO_Answer__c establishRow(
        Fixture f,
        String code,
        String verdict,
        Integer counter,
        Id contactId,
        Id participantId,
        String subjectType
    ) {
        AAO_Evidence_Contract__c ec = f.contracts.get(code);
        System.assertNotEquals(null, ec, 'No contract for ' + code);
        AAO_Synthetic.MARK = true;
        AAO_Answer__c a = new AAO_Answer__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Evidence_Contract__c = ec.Id,
            AAO_Subject_Type__c = subjectType,
            AAO_Subject_Contact__c = contactId,
            AAO_Participant__c = participantId,
            AAO_Verdict__c = verdict,
            AAO_Support_Counter__c = counter,
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

    // ------------------------------------------------- the stage arithmetic, v3.9's guard

    @isTest
    static void anEmptyDerivationIsAReportedZeroAndNeverASuccess() {
        // Architecture v3.9's guard, from the defect that produced it: derive() was proven
        // against the retired EBV path, skipped every P8-coded answer, and projection wrote
        // nothing while reporting success. The counters make that state unexpressible as
        // success - answers in and dimension-writes out, both printed.
        AAO_Project.Outcome o = new AAO_Project.Outcome();
        o.answersRead = 40;
        System.assertEquals(0, o.dimensionWrites(), 'unit: values');
        System.assert(
            o.derivedNothing(),
            'Forty answers producing no value is the writer failing, not the read finding nothing.'
        );
        String s = o.toString();
        System.assert(s.contains('answers read             40'), 'Got: ' + s);
        System.assert(s.contains('DERIVED NOTHING'), 'And it says so in words. Got: ' + s);
        System.assert(
            s.contains('writer defect, not a recall result'),
            'The report names which kind of failure it is, because a blank map reads as the ' +
            'other one. Got: ' + s
        );
    }

    @isTest
    static void aRunThatWroteNothingBecauseItReadNothingIsNotADefect() {
        // Zero answers is a pass that found nothing, which is an ordinary and correct
        // outcome. The alarm fires on answers-in-with-no-values-out, never on an empty read.
        AAO_Project.Outcome o = new AAO_Project.Outcome();
        System.assertEquals(0, o.answersRead);
        System.assertEquals(
            false,
            o.derivedNothing(),
            'Nothing in and nothing out is silence, not a silent failure.'
        );
        System.assert(!o.toString().contains('DERIVED NOTHING'));
    }

    @isTest
    static void everyDimensionIsCountedSeparatelyAndNamesItsUnit() {
        AAO_Project.Outcome o = new AAO_Project.Outcome();
        o.answersRead = 4;
        for (String d : AAO_P8Codes.dimensions()) {
            o.writesByDimension.put(d, 1);
        }
        System.assertEquals(4, o.dimensionWrites(), 'unit: values');
        String s = o.toString();
        for (String d : AAO_P8Codes.dimensions()) {
            System.assert(s.contains(d), 'Every dimension prints its own line. Got: ' + s);
        }
        System.assert(!s.contains('DERIVED NOTHING'));
    }
}
