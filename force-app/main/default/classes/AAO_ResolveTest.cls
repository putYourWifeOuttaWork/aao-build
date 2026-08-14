/**
 * The resolution stage: the merge key, the byte-lookup speaker attach, the designator legs,
 * and the arithmetic holding across all of it with zero model calls on the clean path.
 */
@IsTest
private class AAO_ResolveTest {
    private static final String RUN = 'resolverun01';

    private static final String TEXT =
        'kayla\tI think the price is too high for what we get. Adam should decide this.\n' +
        'adam\tOur CFO Rich Meyer signs anything over a million. I like the product.';

    // ============================================================== the merge

    @IsTest
    static void bothReadsFindingOneEstablishmentMergeOnBytesNeverStrings() {
        Fixture f = fixture();
        // Read 1 quotes the longer span Full; read 2 quotes a shorter overlapping span
        // Partial. Same contract, same meaning, intersecting bytes, different strings.
        located(f, 'r1q1', 'AAO_BR_EVAL', 'EVALUATOR',
            'I think the price is too high for what we get.', 'Full', null, null);
        located(f, 'r2q1', 'AAO_BR_EVAL', 'EVALUATOR',
            'the price is too high', 'Partial', null, null);

        Test.startTest();
        AAO_Resolve.Outcome o = AAO_Resolve.run(f.sourceId, RUN);
        Test.stopTest();

        System.assertEquals(2, o.pairsRead, o.toString());
        System.assertEquals(1, o.merged, 'One row absorbed.');
        System.assertEquals(1, o.speakerAttached, 'One establishment rides.');
        System.assertEquals(0, o.remainder.size(), 'Nothing for the model leg.');

        List<AAO_Pair__c> disposed = [
            SELECT AAO_Pair_Ref__c, AAO_Disposition__c, AAO_Corroborated__c,
                AAO_Located_Pair__r.AAO_Coverage__c, AAO_Identification_Basis__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :RUN AND AAO_Stage__c = 'Identified'
            ORDER BY AAO_Pair_Ref__c
        ];
        System.assertEquals(2, disposed.size(), 'One for one: every located pair disposed.');
        for (AAO_Pair__c p : disposed) {
            if (p.AAO_Disposition__c == AAO_Resolve.MERGED) {
                System.assertEquals(
                    'Full', p.AAO_Located_Pair__r.AAO_Coverage__c,
                    'THE CANONICAL IS THE CONSERVATIVE ROW: where the reads disagree, the ' +
                    'Partial row rides and the Full row is absorbed, so "partial unless ' +
                    'both say full" holds without editing any located row.'
                );
            } else {
                System.assertEquals('Partial', p.AAO_Located_Pair__r.AAO_Coverage__c);
                System.assertEquals(
                    true, p.AAO_Corroborated__c,
                    'Both reads found it, and the marker says so. A marker, never a gate.'
                );
            }
        }
        AAO_PairLedger.Counts c = AAO_PairLedger.assertOneForOne(RUN, false);
        System.assertEquals(AAO_PairLedger.HELD, c.outcome, c.toString());
    }

    @IsTest
    static void aPairOnlyOneReadFoundStandsAndIsNotCorroborated() {
        Fixture f = fixture();
        located(f, 'r1q1', 'AAO_BR_EVAL', 'EVALUATOR',
            'I think the price is too high for what we get.', 'Full', null, null);

        Test.startTest();
        AAO_Resolve.Outcome o = AAO_Resolve.run(f.sourceId, RUN);
        Test.stopTest();

        System.assertEquals(0, o.merged, 'The union is the point.');
        AAO_Pair__c p = [
            SELECT AAO_Corroborated__c, AAO_Disposition__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :RUN AND AAO_Stage__c = 'Identified'
        ];
        System.assertEquals('Identified', p.AAO_Disposition__c);
        System.assertEquals(false, p.AAO_Corroborated__c);
    }

    @IsTest
    static void sameBytesDifferentMeaningsBothRideToTheBlindReader() {
        Fixture f = fixture();
        located(f, 'r1q1', 'AAO_PS_1', 'NON_SUPPORTER',
            'I think the price is too high for what we get.', null, null, null);
        located(f, 'r2q1', 'AAO_PS_1', 'SUPPORTER',
            'I think the price is too high for what we get.', null, null, null);

        Test.startTest();
        AAO_Resolve.Outcome o = AAO_Resolve.run(f.sourceId, RUN);
        Test.stopTest();

        System.assertEquals(0, o.merged, 'Different meanings are different establishments.');
        System.assertEquals(2, o.speakerAttached, 'Both ride, and the mixed-evidence law ' +
            'prices the survivors after call 3.');
    }

    // ====================================================== the deterministic attach

    @IsTest
    static void whoSpokeAPairIsAByteLookupNotAJudgment() {
        Fixture f = fixture();
        located(f, 'r1q1', 'AAO_BR_EVAL', 'EVALUATOR',
            'I think the price is too high for what we get.', 'Full', null, null);
        located(f, 'r1q2', 'AAO_PS_1', 'SUPPORTER', 'I like the product.', null, null, null);

        Test.startTest();
        AAO_Resolve.Outcome o = AAO_Resolve.run(f.sourceId, RUN);
        Test.stopTest();

        System.assertEquals(2, o.speakerAttached);
        Map<String, Id> personByRef = new Map<String, Id>();
        for (AAO_Pair__c p : [
            SELECT AAO_Pair_Ref__c, AAO_Person__c FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :RUN AND AAO_Stage__c = 'Identified'
        ]) {
            personByRef.put(p.AAO_Pair_Ref__c, p.AAO_Person__c);
        }
        System.assertEquals(f.kayla, personByRef.get('r1q1'), 'Kayla\'s turn, Kayla\'s pair.');
        System.assertEquals(f.adam, personByRef.get('r1q2'), 'Adam\'s turn, Adam\'s pair.');
    }

    @IsTest
    static void aDesignatorNamingAnotherParticipantAttachesThroughTheRoster() {
        Fixture f = fixture();
        // Kayla's words, about Adam: the designator resolves on the roster, no ladder.
        located(f, 'r1q1', 'AAO_BR_DM', 'DECISION_MAKER',
            'Adam should decide this.', 'Full', 'Adam', 'Adam should decide this.');

        Test.startTest();
        AAO_Resolve.Outcome o = AAO_Resolve.run(f.sourceId, RUN);
        Test.stopTest();

        System.assertEquals(1, o.designatorRoster, o.toString());
        AAO_Pair__c p = [
            SELECT AAO_Person__c FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :RUN AND AAO_Stage__c = 'Identified'
        ];
        System.assertEquals(
            f.adam, p.AAO_Person__c,
            'RESOLUTION ATTACHES SUBJECTS, NEVER SPEAKERS: Kayla spoke, Adam is the subject.'
        );
    }

    @IsTest
    static void aMentionedContactLinksThroughTheLadderAndNeverCountsCoverage() {
        Fixture f = fixture();
        AAO_Synthetic.MARK = true;
        insert new Contact(
            FirstName = 'Rich', LastName = 'Meyer', AccountId = f.acctId,
            Email = 'rich.meyer@customer.example'
        );
        AAO_Synthetic.MARK = false;
        located(f, 'r1q1', 'AAO_BR_SIG', 'SIGNATURE_APPROVER',
            'Our CFO Rich Meyer signs anything over a million.', 'Full',
            'Rich Meyer', 'Our CFO Rich Meyer signs anything over a million.');

        Test.startTest();
        AAO_Resolve.Outcome o = AAO_Resolve.run(f.sourceId, RUN);
        Test.stopTest();

        System.assertEquals(1, o.designatorLinked, o.toString());
        System.assertEquals(1, o.mentionParticipants, 'The subject carrier is minted.');
        AAO_Participant__c mention = [
            SELECT AAO_Roster_Key__c, AAO_Contact__c, AAO_Display_Name__c
            FROM AAO_Participant__c
            WHERE AAO_Source__c = :f.sourceId
                AND AAO_Roster_Key__c LIKE 'mention:%'
        ];
        System.assertNotEquals(null, mention.AAO_Contact__c, 'Linked, not created.');
        System.assertEquals(
            'Rich Meyer', mention.AAO_Display_Name__c,
            'The display is the designator VERBATIM (the ASR-name law); the Contact ' +
            'carries the resolved identity.'
        );
        System.assertEquals(
            null,
            AAO_Coverage.occasionsByPerson(f.oppId).get(mention.Id),
            'A mention is not presence, and presence establishes coverage.'
        );
    }

    @IsTest
    static void anUnresolvableDesignatorIsTheModelLegsRemainderNeverAGuess() {
        Fixture f = fixture();
        located(f, 'r1q1', 'AAO_BR_SIG', 'SIGNATURE_APPROVER',
            'Our CFO Rich Meyer signs anything over a million.', 'Full',
            'Rich Meyer', 'Our CFO Rich Meyer signs anything over a million.');

        Test.startTest();
        AAO_Resolve.Outcome o = AAO_Resolve.run(f.sourceId, RUN);
        Test.stopTest();

        // No Contact named Rich Meyer exists, no roster match: the ladder returns ZERO and
        // the pair stays undisposed for the model leg rather than being guessed or dropped.
        System.assertEquals(1, o.remainder.size(), o.toString());
        System.assertEquals('r1q1', o.remainder[0]);
        System.assertEquals(
            0,
            [
                SELECT COUNT() FROM AAO_Pair__c
                WHERE AAO_Run_Key__c = :RUN AND AAO_Stage__c = 'Identified'
            ],
            'Undisposed is honest; the ledger stays INCOMPLETE until the leg runs.'
        );
    }

    @IsTest
    static void theRequestChartersCompletenessIsStructuralNotProse() {
        Map<String, Object> schema = AAO_ResolveRequestCharter.schema(
            new List<String>{ 'd1', 'd2' }, new List<String>{ 'kayla', 'adam' }
        );
        Map<String, Object> requests =
            (Map<String, Object>) ((Map<String, Object>) schema.get('properties'))
                .get('requests');
        System.assertEquals(
            new List<String>{ 'd1', 'd2' },
            (List<String>) requests.get('required'),
            'Every designator handle is a REQUIRED property, so an omission fails schema ' +
            'validation at the API instead of parsing short - the structural fix the ' +
            'under-return defect needed and minItems could not provide.'
        );

        try {
            AAO_ResolveRequestCharter.parse(
                '{"requests":{"d1":{"kind":"title-only","candidate":"NONE",' +
                '"side":"unclear","basis":"x"}}}',
                new Map<String, String>{ 'd1' => 'CFO', 'd2' => 'Rich' }
            );
            System.assert(false, 'Expected a throw on the omitted handle.');
        } catch (AAO_ResolveRequestCharter.CharterException e) {
            System.assert(e.getMessage().contains('d2'), e.getMessage());
        }
    }

    // ---------------------------------------------------------------------- fixture

    private class Fixture {
        Id oppId;
        Id acctId;
        Id sourceId;
        Id kayla;
        Id adam;
        Map<String, Id> contracts = new Map<String, Id>();
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Fixture f = new Fixture();
        Account a = new Account(Name = 'AAO Resolve Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Resolve Test Deal', AccountId = a.Id, StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        f.acctId = a.Id;
        f.oppId = o.Id;

        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = o.Id,
            AAO_Account__c = a.Id,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c =
                '00000000000000000000000000000000000000000000000000000000000000dd',
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = TEXT,
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 7, 30, 15, 0, 0),
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{
                    'speakers' => new List<Object>{
                        new Map<String, Object>{
                            'key' => 'kayla', 'display' => 'Kayla Stanley',
                            'email' => 'kayla@customer.example'
                        },
                        new Map<String, Object>{
                            'key' => 'adam', 'display' => 'Adam Pfeiffer',
                            'email' => 'adam@customer.example'
                        }
                    }
                }
            ),
            AAO_Synthetic__c = true
        );
        insert src;
        f.sourceId = src.Id;
        for (AAO_Participant__c p : [
            SELECT Id, AAO_Roster_Key__c FROM AAO_Participant__c
            WHERE AAO_Source__c = :src.Id
        ]) {
            if (p.AAO_Roster_Key__c == 'kayla') {
                f.kayla = p.Id;
            } else if (p.AAO_Roster_Key__c == 'adam') {
                f.adam = p.Id;
            }
        }

        AAO_PassContracts.mint();
        for (AAO_Evidence_Contract__c ec : [
            SELECT Id, AAO_Proposition_Code__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Rubric_Version__c = :AAO_PassContracts.RUBRIC_VERSION
                AND AAO_Contract_State__c != 'Superseded'
        ]) {
            f.contracts.put(ec.AAO_Proposition_Code__c, ec.Id);
        }
        AAO_Synthetic.MARK = false;
        return f;
    }

    private static void located(
        Fixture f, String ref, String code, String meaning, String quote,
        String coverage, String designator, String aboutQuote
    ) {
        AAO_Synthetic.MARK = true;
        Integer start = TEXT.indexOf(quote);
        System.assert(start >= 0, 'Fixture quote must byte-match: ' + quote);
        insert new AAO_Pair__c(
            AAO_Run_Key__c = RUN,
            AAO_Pair_Ref__c = ref,
            AAO_Stage__c = 'Located',
            AAO_Charter__c = 'AAO_LocateCharter',
            AAO_Charter_Version__c = 'locate-4.0.0',
            AAO_Source__c = f.sourceId,
            AAO_Evidence_Contract__c = f.contracts.get(code),
            AAO_Answer_Text__c = quote,
            AAO_Meaning__c = meaning,
            AAO_Coverage__c = coverage,
            AAO_About_Designator__c = designator,
            AAO_About_Quote__c = aboutQuote,
            AAO_Start_Offset__c = start,
            AAO_End_Offset__c = start + quote.length(),
            AAO_Speaker_Key__c = start >= TEXT.indexOf('adam\t') ? 'adam' : 'kayla',
            AAO_Occurrence__c = 1,
            AAO_Occurrence_Count__c = 1,
            AAO_Pair_Key__c = AAO_PairKey.compose(RUN, ref, 'Located'),
            AAO_Synthetic__c = true
        );
        AAO_Synthetic.MARK = false;
    }
}