/**
 * The pair ledger's laws, each asserted as the thing it prevents rather than as a rule.
 *
 * These are the two refinements Matthew ruled (stage explicit, occurrence carried) plus
 * the shape laws that make the two rows worth having: the prohibition law as a field the
 * database refuses, one-for-one-for-one as a unique index, and the anchor as immutable.
 */
@isTest
private class AAO_PairLedgerTest {
    private static final String RUN = 'run-2026-08-04-a';

    @isTest
    static void call1CannotNameAPersonEvenIfItTries() {
        // The prohibition law. In the charter it is an instruction to a model, which is a
        // request. Here it is a refusal.
        AAO_Pair__c p = located('p1');
        p.AAO_Disposition__c = 'Identified';
        Boolean refused = false;
        try {
            insert p;
        } catch (DmlException e) {
            refused = true;
            System.assert(
                e.getMessage().contains('not call 1\'s to write'),
                'The message must name whose job it is. Got: ' + e.getMessage()
            );
        }
        System.assert(refused, 'A Located row carrying an identification must be refused.');
    }

    @isTest
    static void call2CannotFindNewEvidenceEvenIfItTries() {
        // The reverse direction, because a rule enforced one way gets around itself.
        insert located('p2');
        AAO_Pair__c ident = identified('p2', 'Identified');
        ident.AAO_Answer_Text__c = 'words call 2 was never handed';
        Boolean refused = false;
        try {
            insert ident;
        } catch (DmlException e) {
            refused = true;
            System.assert(
                e.getMessage().contains('not call 2\'s to write'),
                'Got: ' + e.getMessage()
            );
        }
        System.assert(refused, 'An Identified row carrying evidence must be refused.');
    }

    @isTest
    static void theStageIsExplicitAndNotReadOffTheParentLookup() {
        // Matthew's first refinement. The scar being avoided is the unanswered answer row:
        // one state with two physical shapes. A Located row with a parent, and an
        // Identified row without one, are both refused, so the picklist and the lookup can
        // never disagree about which row this is.
        AAO_Pair__c parent = located('p3');
        insert parent;

        AAO_Pair__c strayParent = located('p3b');
        strayParent.AAO_Located_Pair__c = parent.Id;
        System.assertNotEquals(null, dmlError(strayParent), 'A Located row has no parent.');

        AAO_Pair__c orphan = identified('p3', 'None');
        orphan.AAO_Located_Pair__c = null;
        String err = dmlError(orphan);
        System.assertNotEquals(null, err, 'An Identified row must point at its Located row.');
        System.assert(err.contains('one-for-one-for-one'), 'Got: ' + err);
    }

    @isTest
    static void theOccurrenceIsRequiredAndMustExist() {
        // Matthew's second refinement. On this fixture it is almost always 1; that is not
        // an argument for leaving it off.
        AAO_Pair__c none = located('p4');
        none.AAO_Occurrence__c = null;
        System.assert(
            dmlError(none).contains('which occurrence'),
            'A Located pair must say which match it is.'
        );

        AAO_Pair__c past = located('p4b');
        past.AAO_Occurrence__c = 3;
        past.AAO_Occurrence_Count__c = 2;
        System.assert(
            dmlError(past).contains('does not exist'),
            'Occurrence 3 of 2 must be refused.'
        );

        // The case the field exists for: the words were said more than once.
        AAO_Pair__c second = located('p4c');
        second.AAO_Occurrence__c = 2;
        second.AAO_Occurrence_Count__c = 2;
        insert second;
        System.assertEquals(
            2,
            [SELECT AAO_Occurrence__c FROM AAO_Pair__c WHERE Id = :second.Id]
                .AAO_Occurrence__c,
            'All occurrences stand; the row says which one it is.'
        );
    }

    @isTest
    static void zeroMatchesNeverWritesARow() {
        AAO_Pair__c p = located('p5');
        p.AAO_Occurrence_Count__c = 0;
        System.assert(
            dmlError(p).contains('discards the pair'),
            'Zero matches increments a counter (unit: pairs) and writes nothing.'
        );
    }

    @isTest
    static void oneForOneForOneIsAUniqueIndexRatherThanACountQuery() {
        insert located('p6');
        insert identified('p6', 'Identified');
        String err = dmlError(identified('p6', 'None'));
        System.assertNotEquals(
            null,
            err,
            'A second disposition for the same pair must be refused by the database.'
        );
        System.assert(
            err.contains('DUPLICATE_VALUE') || err.contains('duplicate value'),
            'It must be the unique index, not a count query, so it cannot race. Got: ' + err
        );
    }

    @isTest
    static void aDispositionSaysWhoOrSaysItCannot_NeverBoth_NeverNeither() {
        insert located('p7');

        AAO_Pair__c namedNobody = identified('p7', 'Identified');
        namedNobody.AAO_Person__c = null;
        System.assert(
            dmlError(namedNobody).contains('unanswered answer row'),
            'Identified with no person is one state in two shapes.'
        );

        AAO_Pair__c bothWays = identified('p7', 'Ambiguous');
        bothWays.AAO_Person__c = participant().Id;
        System.assert(
            dmlError(bothWays).contains('carries no person'),
            'Ambiguous with a person is call 2 doing both.'
        );

        // None and Ambiguous are not abstention rows and are perfectly legal.
        insert identified('p7', 'Ambiguous');
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Pair__c WHERE AAO_Disposition__c = 'Ambiguous'],
            'A pair that exists gets a disposition. Nothing here asserts silence.'
        );
    }

    @isTest
    static void theBlindReaderHasNothingToVerifyOnAnUnidentifiedRow() {
        insert located('p8');
        AAO_Pair__c p = identified('p8', 'None');
        p.AAO_Verification__c = 'Upheld';
        System.assert(
            dmlError(p).contains('no claim in front of it'),
            'Call 3 sees an identified claim or it sees nothing.'
        );
    }

    @isTest
    static void theAnchorIsImmutableAndThePairIsUndeletable() {
        AAO_Pair__c p = located('p9');
        insert p;

        p.AAO_Answer_Text__c = 'quietly different words';
        System.assert(
            dmlError(p, true).contains('immutable'),
            'Editing the anchor moves it out from under any claim that cites it.'
        );

        AAO_Pair__c fresh = [
            SELECT Id, AAO_Answer_Text__c, AAO_Synthetic__c FROM AAO_Pair__c WHERE Id = :p.Id
        ];
        Boolean refused = false;
        try {
            delete fresh;
        } catch (DmlException e) {
            refused = true;
            System.assert(
                e.getMessage().contains('record that a stage ran at all'),
                'Got: ' + e.getMessage()
            );
        }
        System.assert(refused, 'A pair is the proof a stage ran and does not leave.');
    }

    @isTest
    static void theLedgerIsTwoRowsDeepAndNeverAChain() {
        insert located('p10');
        AAO_Pair__c first = identified('p10', 'None');
        insert first;

        AAO_Pair__c chained = identified('p10-again', 'None');
        chained.AAO_Located_Pair__c = first.Id;
        System.assert(
            dmlError(chained).contains('would make the ledger a chain'),
            'An identification of an identification makes counting a tree walk.'
        );
    }

    @isTest
    static void theKeyCarriesTheRunBecauseTheArithmeticIsPerRun() {
        String a = AAO_PairKey.compose('run-a', 'p1', AAO_PairKey.LOCATED);
        String b = AAO_PairKey.compose('run-b', 'p1', AAO_PairKey.LOCATED);
        System.assertNotEquals(
            a,
            b,
            'Two runs over the same artifact emit the same refs and mean different things.'
        );
        System.assertNotEquals(
            a,
            AAO_PairKey.compose('run-a', 'p1', AAO_PairKey.IDENTIFIED),
            'The stage is in the key; that is what makes one-for-one an index.'
        );
        System.assert(a.length() <= 67, 'The field length is the arithmetic. Got: ' + a.length());

        try {
            AAO_PairKey.compose('run|a', 'p1', AAO_PairKey.LOCATED);
            System.assert(false, 'A separator inside a part lets two pairs share a key.');
        } catch (AAO_PairKey.KeyException e) {
            System.assert(e.getMessage().contains('same key'), e.getMessage());
        }
    }

    @isTest
    static void aByteLocationIsARangeOrItIsNothing() {
        AAO_Pair__c half = located('p11');
        half.AAO_Start_Offset__c = 100;
        half.AAO_End_Offset__c = null;
        System.assert(dmlError(half).contains('range or it is nothing'), 'One offset locates nothing.');

        AAO_Pair__c empty = located('p11b');
        empty.AAO_Start_Offset__c = 100;
        empty.AAO_End_Offset__c = 100;
        System.assert(
            dmlError(empty).contains('strictly greater'),
            'The end offset is exclusive, matching AAO_Model.Span.'
        );
    }

    // ============================ the half the unique index cannot see (ruling 1) ===

    @isTest
    static void theIndexRefusesMoreThanOne_TheAssertionCatchesZero() {
        // Matthew, 5 August: the index refuses more than one and cannot detect zero. A
        // located pair call 2 silently never disposes of breaks one-for-one just as surely
        // as a duplicate, and no insert ever collides to reveal it.
        insert located('a1');
        insert located('a2');
        insert identified('a1', 'Identified');

        Boolean threw = false;
        try {
            AAO_PairLedger.assertOneForOne(RUN, false);
        } catch (AAO_PairLedger.ArithmeticException e) {
            threw = true;
            System.assert(
                e.getMessage().contains('never disposed of'),
                'The message must name the omission, since the index cannot. Got: ' +
                e.getMessage()
            );
            System.assert(
                e.getMessage().contains('our bug'),
                'A mismatch is always our bug, never a model behaviour, per the parse law.'
            );
        }
        System.assert(threw, 'An undisposed pair must throw loudly.');
    }

    @isTest
    static void aRefusedIdentificationIsADispositionAndSatisfiesTheLaw() {
        // Counting only the named ones would make a correct refusal look like an omission,
        // which is exactly the confusion the abstention rows used to create.
        insert located('b1');
        insert located('b2');
        insert identified('b1', 'None');
        insert identified('b2', 'Ambiguous');

        AAO_PairLedger.Counts c = AAO_PairLedger.assertOneForOne(RUN, false);
        System.assertEquals(2, c.located, 'unit: pairs');
        System.assertEquals(2, c.disposed, 'unit: pairs');
        System.assertEquals(0, c.identifiedToAPerson, 'unit: pairs');
        System.assertEquals(2, c.identificationsRefused, 'unit: pairs');
        System.assert(c.toString().contains('(unit: pairs)'), 'Every counter names its unit.');
    }

    @isTest
    static void theForOneHalfCountsOnlyWhatWentInFrontOfTheReader() {
        insert located('c1');
        insert located('c2');
        AAO_Pair__c named = identified('c1', 'Identified');
        insert named;
        insert identified('c2', 'None');

        // Before call 3 the same data is correct, and after call 3 it is an omission. That
        // is why afterVerify is an argument rather than something read off the rows: a state
        // inferred from the shape of the data is a state with two shapes.
        AAO_PairLedger.assertOneForOne(RUN, false);

        // CHANGED 5 August, and the change is the batched-verify hazard. One identified
        // claim with no verdict is INCOMPLETE, not BROKEN: call 3 runs one claim per callout
        // against a 120-second ceiling, so a pass in progress looks exactly like a pass that
        // dropped a claim. Throwing here would fail every healthy mid-pass run.
        AAO_PairLedger.Counts mid = AAO_PairLedger.assertOneForOne(RUN, true);
        System.assertEquals(
            AAO_PairLedger.INCOMPLETE,
            mid.outcome,
            'A claim still awaiting a verdict is an unfinished pass, not a broken one.'
        );
        System.assert(
            mid.toString().contains('run receipt'),
            'And the report names the thing that would tell the two apart, which is owed.'
        );

        named.AAO_Verification__c = 'Upheld';
        update named;
        AAO_PairLedger.Counts c = AAO_PairLedger.assertOneForOne(RUN, true);
        System.assertEquals(AAO_PairLedger.HELD, c.outcome, 'Now it is finished.');
        System.assertEquals(1, c.verified, 'unit: claims');
        System.assertEquals(1, c.verificationsUpheld, 'unit: claims');
    }

    @isTest
    static void theArithmeticIsPerRunAndDoesNotBleedAcrossRuns() {
        insert located('d1');
        AAO_Pair__c otherRun = located('d1');
        otherRun.AAO_Run_Key__c = 'run-2026-08-04-b';
        insert otherRun;

        System.assertEquals(
            1,
            AAO_PairLedger.counts(RUN).located,
            'Two runs over the same artifact emit the same refs and mean different things.'
        );
    }

    // ------------------------------------------------------------------- fixtures

    private static AAO_Participant__c cachedParticipant;

    /**
     * The participant comes from a Source insert rather than from a hand-built row,
     * because AAO_Participants.record writes participation on arrival and that is the
     * only path that exists. A stand-in participant would be a shape this org never
     * produces, and the three refusals the contract minting collected last were all
     * exactly that mistake.
     */
    private static AAO_Participant__c participant() {
        if (cachedParticipant != null) {
            return cachedParticipant;
        }
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;

        Account a = new Account(Name = 'AAO Pair Ledger Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Pair Ledger Deal',
            AccountId = a.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert o;

        insert new AAO_Source__c(
            AAO_Account__c = a.Id,
            AAO_Opportunity__c = o.Id,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c = '0'.repeat(64),
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 6, 17, 15, 0, 0),
            AAO_Diarization__c = 'Attributed',
            AAO_Normalized_Text__c = 'test_person\twe already decided that internally',
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{ 'speakers' => new List<Object>{
                    new Map<String, Object>{
                        'key' => 'test_person',
                        'display' => 'Test Person',
                        'email' => 'test.person@buyer.example'
                    }
                } }
            )
        );
        cachedParticipant = [SELECT Id FROM AAO_Participant__c LIMIT 1];
        return cachedParticipant;
    }

    private static AAO_Pair__c located(String ref) {
        return new AAO_Pair__c(
            AAO_Stage__c = AAO_PairKey.LOCATED,
            AAO_Run_Key__c = RUN,
            AAO_Pair_Ref__c = ref,
            AAO_Charter__c = 'People',
            AAO_Charter_Version__c = 'p8-1.0.0',
            AAO_Answer_Text__c = 'we already decided that internally',
            AAO_Meaning__c = 'Inner_Circle',
            AAO_Coverage__c = 'Full',
            AAO_Occurrence__c = 1,
            AAO_Occurrence_Count__c = 1
        );
    }

    private static AAO_Pair__c identified(String ref, String disposition) {
        AAO_Pair__c p = new AAO_Pair__c(
            AAO_Stage__c = AAO_PairKey.IDENTIFIED,
            AAO_Run_Key__c = RUN,
            AAO_Pair_Ref__c = ref,
            AAO_Charter__c = 'People',
            AAO_Charter_Version__c = 'p8-1.0.0',
            AAO_Disposition__c = disposition,
            AAO_Identification_Basis__c = 'spoken by them'
        );
        List<AAO_Pair__c> parent = [
            SELECT Id
            FROM AAO_Pair__c
            WHERE AAO_Pair_Ref__c = :ref AND AAO_Stage__c = :AAO_PairKey.LOCATED
            LIMIT 1
        ];
        if (!parent.isEmpty()) {
            p.AAO_Located_Pair__c = parent[0].Id;
        }
        if (disposition == 'Identified') {
            p.AAO_Person__c = participant().Id;
        }
        return p;
    }

    private static String dmlError(AAO_Pair__c p) {
        return dmlError(p, false);
    }

    private static String dmlError(AAO_Pair__c p, Boolean isUpdate) {
        try {
            if (isUpdate) {
                update p;
            } else {
                insert p;
            }
        } catch (DmlException e) {
            return e.getMessage();
        }
        return null;
    }
}