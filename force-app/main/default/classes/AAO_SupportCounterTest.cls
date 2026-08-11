/**
 * The sentiment counter, against §P8.4's arithmetic as Matthew ruled it.
 *
 * Every assertion below is a sentence from the charter turned into a number. Where the charter
 * gives a worked example, the example is the test - the specimen at the end is the first
 * fixture's own grading, and it is here because the arithmetic's whole claim is that Matthew's
 * grades through it produce Matthew's answer.
 */
@IsTest
private class AAO_SupportCounterTest {
    private static List<String> reads(String state, Integer howMany) {
        List<String> out = new List<String>();
        for (Integer i = 0; i < howMany; i++) {
            out.add(state);
        }
        return out;
    }

    // ============================================================================ the rungs

    @IsTest
    static void theRungsSitAtTheirRuledPositionsAndACountedZeroIsNeutral() {
        System.assertEquals('Mentor', AAO_SupportCounter.rungFor(3));
        System.assertEquals('Supporter', AAO_SupportCounter.rungFor(2));
        System.assertEquals('Supporter', AAO_SupportCounter.rungFor(1));
        System.assertEquals('Non-Supporter', AAO_SupportCounter.rungFor(-1));
        System.assertEquals('Non-Supporter', AAO_SupportCounter.rungFor(-2));
        System.assertEquals('Enemy', AAO_SupportCounter.rungFor(-3));

        // MATTHEW'S RULING, forty-fourth stamp item 2, REVERSING what this test used to
        // assert. It read: "Neutral stays derived, never written. Zero is the absence of a
        // placement, and writing Neutral would be the map asserting a balance nobody voiced."
        // The specimen that overturned it: Adam Pfeiffer in run `pf0811-live`, one supportive
        // establishment and one hedge upheld as non-support, netting zero and leaving Status
        // BLANK on a person whose enthusiasm is in the transcript. Zero was not the absence of
        // a placement there; it was two placements cancelling, which is a measurement.
        System.assertEquals(
            'Neutral',
            AAO_SupportCounter.rungFor(0),
            'A COUNTED zero is Neutral: the machine weighed support and counter-support and ' +
            'they balance, and the map says so with the evidence behind it.'
        );
        System.assertEquals(
            null,
            AAO_SupportCounter.rungFor(null),
            'And BLANK IS RESERVED FOR NEVER-MEASURED. The whole distinction rides on null ' +
            'versus zero, so this assertion is the other half of the one above.'
        );
    }

    // ================================================================== each read moves one

    @IsTest
    static void oneWarmQuoteIsPlusOne() {
        AAO_SupportCounter.Movement m = AAO_SupportCounter.apply(
            0,
            reads(AAO_SupportCounter.SUPPORTER, 1),
            null
        );
        System.assertEquals(1, m.result);
        System.assertEquals('Supporter', AAO_SupportCounter.rungFor(m.result));
    }

    @IsTest
    static void aCallStackedWithSupporterGradeEvidenceIsPlusTwoAndStops() {
        // "supporter-grade words top out at +2 however many there are"
        AAO_SupportCounter.Movement m = AAO_SupportCounter.apply(
            0,
            reads(AAO_SupportCounter.SUPPORTER, 5),
            null
        );
        System.assertEquals(5, m.positiveReads, 'unit: establishments');
        System.assertEquals(5, m.net, 'The net is what the reads add up to, uncapped.');
        System.assertEquals(
            2,
            m.result,
            'The reach cap is the second of the two caps: evidence never carries anyone past ' +
            'the strongest state it actually voices.'
        );
    }

    @IsTest
    static void furtherSupporterGradeEvidenceAtPlusTwoDoesNothing() {
        AAO_SupportCounter.Movement m = AAO_SupportCounter.apply(
            2,
            reads(AAO_SupportCounter.SUPPORTER, 3),
            null
        );
        System.assertEquals(2, m.result, 'Supporter\'s ceiling IS +2.');
        System.assertEquals(0, m.moved(), 'unit: counter steps');
    }

    @IsTest
    static void terminalsAreProofGatedAndNeverTimeGated() {
        // "Mentor is reachable in a single call over multiple extreme-grade establishments,
        // because time was never the gate, proof is."
        AAO_SupportCounter.Movement m = AAO_SupportCounter.apply(
            0,
            reads(AAO_SupportCounter.MENTOR, 3),
            null
        );
        System.assertEquals(3, m.result, 'One call, three mentor-grade establishments.');
        System.assertEquals('Mentor', AAO_SupportCounter.rungFor(m.result));

        AAO_SupportCounter.Movement enemy = AAO_SupportCounter.apply(
            0,
            reads(AAO_SupportCounter.ENEMY, 4),
            null
        );
        System.assertEquals(-3, enemy.result, 'Symmetric, and clamped at -3.');
        System.assertEquals('Enemy', AAO_SupportCounter.rungFor(enemy.result));
    }

    @IsTest
    static void onlyMentorGradeWordsCrossFromSupporterToMentor() {
        System.assertEquals(
            2,
            AAO_SupportCounter.apply(2, reads(AAO_SupportCounter.SUPPORTER, 9), null).result,
            'Nine supporter-grade quotes do not make a Mentor. A cheap MENTOR makes terminals ' +
            'cheap, which is why the label meanings are pinned as law.'
        );
        System.assertEquals(
            3,
            AAO_SupportCounter.apply(2, reads(AAO_SupportCounter.MENTOR, 1), null).result
        );
    }

    // ===================================================================== mixed evidence

    @IsTest
    static void mixedEvidenceNetsAndNothingAverages() {
        // The charter's own worked example: "+2 positive and -1 negative is +1".
        List<String> mixed = new List<String>{
            AAO_SupportCounter.SUPPORTER,
            AAO_SupportCounter.SUPPORTER,
            AAO_SupportCounter.NON_SUPPORTER
        };
        AAO_SupportCounter.Movement m = AAO_SupportCounter.apply(0, mixed, null);
        System.assertEquals(2, m.positiveReads);
        System.assertEquals(1, m.negativeReads);
        System.assertEquals(1, m.result);
        System.assertEquals('Supporter', AAO_SupportCounter.rungFor(m.result));
    }

    @IsTest
    static void evenlyMixedEvidenceMovesNothingAndBothSidesStayOnTheRecord() {
        AAO_SupportCounter.Movement m = AAO_SupportCounter.apply(
            1,
            new List<String>{ AAO_SupportCounter.SUPPORTER, AAO_SupportCounter.NON_SUPPORTER },
            null
        );
        System.assertEquals(0, m.net);
        System.assertEquals(1, m.result, 'No move.');
        System.assertEquals(1, m.positiveReads, 'Every quote journals on its own side.');
        System.assertEquals(1, m.negativeReads);
    }

    @IsTest
    static void oneNegativePullsAMentorOffTheTopBecausePeopleAreFickle() {
        // "It takes more to earn an extreme than to lose it."
        AAO_SupportCounter.Movement m = AAO_SupportCounter.apply(
            3,
            reads(AAO_SupportCounter.NON_SUPPORTER, 1),
            null
        );
        System.assertEquals(2, m.result);
        System.assertEquals(
            'Supporter',
            AAO_SupportCounter.rungFor(m.result),
            'Three establishments to enter Mentor, one to leave it.'
        );
    }

    @IsTest
    static void theReachCapNeverPullsAnybodyDown() {
        // A person at +3 meeting a call of supporter-grade words: supporter's reach is +2, and
        // reading the cap as a target rather than a ceiling would demote them for being liked.
        AAO_SupportCounter.Movement m = AAO_SupportCounter.apply(
            3,
            reads(AAO_SupportCounter.SUPPORTER, 2),
            null
        );
        System.assertEquals(3, m.result, 'The cap bounds upward movement; it is not a target.');
        System.assertEquals(
            -3,
            AAO_SupportCounter.apply(-3, reads(AAO_SupportCounter.NON_SUPPORTER, 2), null).result,
            'Symmetric on the negative side.'
        );
    }

    // ======================================================================== the clamp

    @IsTest
    static void theCounterIsClampedAtThreeInBothDirections() {
        System.assertEquals(3, AAO_SupportCounter.apply(2, reads(AAO_SupportCounter.MENTOR, 8), null).result);
        System.assertEquals(-3, AAO_SupportCounter.apply(-2, reads(AAO_SupportCounter.ENEMY, 8), null).result);
        System.assertEquals(3, AAO_SupportCounter.clamp(99));
        System.assertEquals(-3, AAO_SupportCounter.clamp(-99));
        System.assertEquals(0, AAO_SupportCounter.clamp(null));
    }

    // ==================================================================== the jump rule

    @IsTest
    static void anExplicitDeclarationSetsThePositionOutrightRegardlessOfCount() {
        AAO_SupportCounter.Movement m = AAO_SupportCounter.apply(
            2,
            new List<String>(),
            AAO_SupportCounter.ENEMY
        );
        System.assertEquals(true, m.jumped);
        System.assertEquals(-3, m.result, 'Declared outright, so the count does not govern.');
        System.assertEquals(
            true,
            m.reversedPolarity,
            'Movement reversed standing polarity, so a contention flag carries the whole ' +
            'sequence with its quotes.'
        );
    }

    @IsTest
    static void movingOffZeroReversesNothingAndRaisesNoFlag() {
        AAO_SupportCounter.Movement m = AAO_SupportCounter.apply(
            0,
            reads(AAO_SupportCounter.NON_SUPPORTER, 1),
            null
        );
        System.assertEquals(-1, m.result);
        System.assertEquals(
            false,
            m.reversedPolarity,
            'Zero is not a polarity. A first establishment must not raise contention against ' +
            'a position nobody held.'
        );
    }

    @IsTest
    static void aLabelTheCounterDoesNotKnowThrowsRatherThanGuessing() {
        try {
            AAO_SupportCounter.apply(0, new List<String>{ 'NEUTRAL' }, null);
            System.assert(false, 'There is no neutral label and no partial.');
        } catch (AAO_SupportCounter.CounterException e) {
            System.assert(e.getMessage().contains('no neutral label'), e.getMessage());
        }
        try {
            AAO_SupportCounter.apply(0, new List<String>(), 'WARM');
            System.assert(false, 'A declared state must be one of the four.');
        } catch (AAO_SupportCounter.CounterException e) {
            System.assert(e.getMessage().contains('not one of the four'), e.getMessage());
        }
    }

    // ========================================================================== replay

    @IsTest
    static void replayInEvidenceOccurredOrderReconstructsTheCounterExactly() {
        // Determinism holds because the counter is a clamped sum over receipts. Built out of
        // order deliberately: if the rebuild trusted list order rather than the clock, this
        // would land somewhere else.
        List<AAO_Claim__c> claims = new List<AAO_Claim__c>{
            claim(AAO_SupportCounter.MENTOR, Datetime.newInstanceGmt(2026, 7, 1, 9, 0, 0), 'b'),
            claim(AAO_SupportCounter.SUPPORTER, Datetime.newInstanceGmt(2026, 6, 17, 9, 0, 0), 'a'),
            claim(AAO_SupportCounter.SUPPORTER, Datetime.newInstanceGmt(2026, 6, 17, 9, 0, 0), 'a')
        };
        // 17 June: two supporter-grade reads, net +2, reach +2 -> 2.
        // 1 July: one mentor-grade read, net +1, reach +3 -> 3.
        System.assertEquals(3, AAO_SupportCounter.rebuild(claims));
        System.assertEquals(
            3,
            AAO_SupportCounter.rebuild(reversed(claims)),
            'Order of the list is irrelevant; order of the clock is everything.'
        );
        System.assertEquals(0, AAO_SupportCounter.rebuild(null));
        System.assertEquals(0, AAO_SupportCounter.rebuild(new List<AAO_Claim__c>()));
    }

    @IsTest
    static void oneSourceEventMovesTogetherRatherThanOneStepPerClaim() {
        // A call's movement is the net sum of ITS establishments. Grouping by anything other
        // than the source-event would let two calls' evidence cancel inside one step - and
        // would also make three supporter quotes on one call reach +3, which is exactly the
        // cheap terminal the reach cap exists to prevent.
        Datetime june = Datetime.newInstanceGmt(2026, 6, 17, 9, 0, 0);
        List<AAO_Claim__c> oneCall = new List<AAO_Claim__c>{
            claim(AAO_SupportCounter.SUPPORTER, june, 'a'),
            claim(AAO_SupportCounter.SUPPORTER, june, 'a'),
            claim(AAO_SupportCounter.SUPPORTER, june, 'a')
        };
        System.assertEquals(2, AAO_SupportCounter.rebuild(oneCall), 'One occasion, capped at +2.');

        List<AAO_Claim__c> threeCalls = new List<AAO_Claim__c>{
            claim(AAO_SupportCounter.SUPPORTER, Datetime.newInstanceGmt(2026, 6, 17, 9, 0, 0), 'a'),
            claim(AAO_SupportCounter.SUPPORTER, Datetime.newInstanceGmt(2026, 6, 24, 9, 0, 0), 'b'),
            claim(AAO_SupportCounter.SUPPORTER, Datetime.newInstanceGmt(2026, 7, 1, 9, 0, 0), 'c')
        };
        System.assertEquals(
            2,
            AAO_SupportCounter.rebuild(threeCalls),
            'And three separate occasions still stop at supporter\'s ceiling, because the cap ' +
            'is on the state the evidence voices rather than on how often it is voiced.'
        );
    }

    @IsTest
    static void aClaimWhoseInterpretationIsNotAStateContributesNoMovement() {
        List<AAO_Claim__c> claims = new List<AAO_Claim__c>{
            claim(AAO_SupportCounter.SUPPORTER, Datetime.newInstanceGmt(2026, 6, 17, 9, 0, 0), 'a'),
            claim('the words carry warmth about the project', Datetime.newInstanceGmt(2026, 6, 17, 9, 0, 0), 'a')
        };
        System.assertEquals(
            1,
            AAO_SupportCounter.rebuild(claims),
            'Skipped rather than guessed at. A prose interpretation is not a sentiment read.'
        );
    }

    // -------------------------------------------------------------------- the specimen

    @IsTest
    static void matthewsGradesOnTheFirstFixtureProduceMatthewsAnswer() {
        // §P8.4's own specimen, and the reason the arithmetic is trusted rather than argued:
        // design read the 17 June quotes as mentor-grade, Matthew graded them inside
        // supporter, and his grades through this arithmetic land exactly where he put the
        // person - +2, the top of Supporter. The grading is what prices a quote; the
        // arithmetic only adds.
        Datetime june17 = Datetime.newInstanceGmt(2026, 6, 17, 15, 0, 0);
        List<AAO_Claim__c> graded = new List<AAO_Claim__c>{
            claim(AAO_SupportCounter.SUPPORTER, june17, 'emerson'),
            claim(AAO_SupportCounter.SUPPORTER, june17, 'emerson'),
            claim(AAO_SupportCounter.SUPPORTER, june17, 'emerson')
        };
        Integer standing = AAO_SupportCounter.rebuild(graded);
        System.assertEquals(2, standing);
        System.assertEquals('Supporter', AAO_SupportCounter.rungFor(standing));
    }

    // ---------------------------------------------------------------------- fixtures

    private static Integer seq = 0;

    private static AAO_Claim__c claim(String interpretation, Datetime occurred, String sourceKey) {
        seq++;
        Map<String, Object> row = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'AAO_Claim__c' },
            'Id' => AAO_FakeId.of(AAO_Claim__c.SObjectType),
            'AAO_Interpretation__c' => interpretation,
            'AAO_Evidence_Occurred__c' => occurred.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''),
            'AAO_Source__c' => sourceIdFor(sourceKey)
        };
        return (AAO_Claim__c) JSON.deserialize(JSON.serialize(row), AAO_Claim__c.class);
    }

    private static Map<String, Id> sourceIds = new Map<String, Id>();

    private static Id sourceIdFor(String key) {
        if (!sourceIds.containsKey(key)) {
            sourceIds.put(key, AAO_FakeId.of(AAO_Source__c.SObjectType));
        }
        return sourceIds.get(key);
    }

    private static List<AAO_Claim__c> reversed(List<AAO_Claim__c> in0) {
        List<AAO_Claim__c> out = new List<AAO_Claim__c>();
        for (Integer i = in0.size() - 1; i >= 0; i--) {
            out.add(in0[i]);
        }
        return out;
    }
}
