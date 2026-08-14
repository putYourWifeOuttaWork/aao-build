/**
 * Byte location: what becomes a pair, what is counted and discarded, and what the ordinal
 * is actually for.
 */
@isTest
private class AAO_LocateTest {
    private static final String RUN = 'run-locate-test';

    @isTest
    static void wordsThatAreNotInTheArtifactAreCountedAndNeverWritten() {
        // §P8.0: zero matches discards the pair and increments a counter (unit: pairs). It
        // does NOT write a row saying the words were not found, and it does not silently
        // vanish either: the note names the question and the quote.
        AAO_Locate.Located l = AAO_Locate.locate(
            src(), new List<AAO_LocateCharter.Pair>{
                pair('q1', 'AAO_POL_IC2', 'a sentence nobody in this call said', 'INNER_CIRCLE')
            },
            RUN, 'locate-2.0.0', new Map<String, Id>()
        );
        System.assertEquals(0, l.rows.size(), 'unit: pairs');
        System.assertEquals(1, l.discardedNoMatch, 'unit: pairs');
        System.assert(
            l.discardNotes[0].contains('no byte match'),
            'A discard keeps its reason. Got: ' + l.discardNotes[0]
        );
    }

    @isTest
    static void wordsSaidTwiceProduceTwoRowsEachSayingWhichOneItIs() {
        // This is what the occurrence ordinal is FOR. All occurrences stand, because the
        // words really were said more than once, and call 2 may identify them to different
        // people.
        AAO_Locate.Located l = AAO_Locate.locate(
            src(), new List<AAO_LocateCharter.Pair>{
                pair('q1', 'AAO_PS_1', 'we are aligned', 'SUPPORTER')
            },
            RUN, 'locate-2.0.0', new Map<String, Id>()
        );
        System.assertEquals(2, l.rows.size(), 'unit: pairs');
        System.assertEquals(1, l.rows[0].AAO_Occurrence__c);
        System.assertEquals(2, l.rows[1].AAO_Occurrence__c);
        System.assertEquals(2, l.rows[0].AAO_Occurrence_Count__c, 'Both know there were two.');
        System.assertEquals(
            'dana',
            l.rows[0].AAO_Speaker_Key__c,
            'The speaker is computed from the offsets, never asked of the model.'
        );
        System.assertEquals('sam', l.rows[1].AAO_Speaker_Key__c, 'Two people said it.');
        System.assertNotEquals(
            l.rows[0].AAO_Pair_Ref__c,
            l.rows[1].AAO_Pair_Ref__c,
            'Two rows in one run need two refs, or the second collides on the pair key.'
        );
    }

    @isTest
    static void aSingleMatchKeepsTheModelsOwnPlainRef() {
        AAO_Locate.Located l = AAO_Locate.locate(
            src(), new List<AAO_LocateCharter.Pair>{
                pair('q7', 'AAO_POL_IC3', 'I control that budget', 'INNER_CIRCLE')
            },
            RUN, 'locate-2.0.0', new Map<String, Id>()
        );
        System.assertEquals(1, l.rows.size());
        System.assertEquals(
            'q7',
            l.rows[0].AAO_Pair_Ref__c,
            'The common case reads as the model\'s own handle; only a repeat is suffixed.'
        );
        System.assertEquals(1, l.rows[0].AAO_Occurrence_Count__c);
    }

    @isTest
    static void aQuoteThatStraddlesTwoTurnsIsDiscardedRatherThanAttributed() {
        // Partly two people's words are nobody's. The old span layer caught this as a
        // contiguity failure; here it is caught before a row exists at all.
        AAO_Locate.Located l = AAO_Locate.locate(
            src(), new List<AAO_LocateCharter.Pair>{
                pair('q1', 'AAO_PS_1', 'we are aligned\nsam\twe are aligned', 'SUPPORTER')
            },
            RUN, 'locate-2.0.0', new Map<String, Id>()
        );
        System.assertEquals(0, l.rows.size());
        System.assertEquals(1, l.discardedCrossesTurns, 'unit: pairs');
        System.assert(l.discardNotes[0].contains('inside one turn'), l.discardNotes[0]);
    }

    @isTest
    static void theOffsetsAreExactAndTheRowsSurviveTheLedgersOwnLaws() {
        AAO_Source__c s = src();
        AAO_Locate.Located l = AAO_Locate.locate(
            s, new List<AAO_LocateCharter.Pair>{
                pair('q7', 'AAO_POL_IC3', 'I control that budget', 'INNER_CIRCLE')
            },
            RUN, 'locate-2.0.0', new Map<String, Id>()
        );
        AAO_Pair__c r = l.rows[0];
        System.assertEquals(
            'I control that budget',
            s.AAO_Normalized_Text__c.substring(
                r.AAO_Start_Offset__c.intValue(), r.AAO_End_Offset__c.intValue()
            ),
            'End-exclusive, matching AAO_Model.Span, or the two locators drift apart.'
        );

        // The trigger is the real proof the shape is right: it refuses anything call 1 has
        // no business writing, so a clean insert means the row is a genuine Located row.
        AAO_Locate.write(l);
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Pair__c WHERE AAO_Run_Key__c = :RUN],
            'unit: pairs'
        );
    }

    @isTest
    static void anOverlappingMatchIsNotCountedTwice() {
        // Counting one occurrence twice would make the ordinal lie about how often the
        // words were said, which is the one thing it exists to say.
        AAO_Locate.Located l = AAO_Locate.locate(
            srcOf('dana\taaaa'),
            new List<AAO_LocateCharter.Pair>{ pair('q1', 'AAO_PS_1', 'aaa', 'SUPPORTER') },
            RUN, 'locate-2.0.0', new Map<String, Id>()
        );
        System.assertEquals(1, l.rows.size(), 'Two overlapping reads of "aaa" are one saying.');
    }

    // ------------------------------------------------------------------- fixtures

    private static AAO_LocateCharter.Pair pair(
        String ref, String code, String words, String meaning
    ) {
        AAO_LocateCharter.Pair p = new AAO_LocateCharter.Pair();
        p.ref = ref;
        p.questionCode = code;
        p.answerText = words;
        p.meaning = meaning;
        return p;
    }

    private static AAO_Source__c src() {
        return srcOf(
            'dana\twe are aligned\n' +
            'sam\twe are aligned\n' +
            'dana\tI control that budget'
        );
    }

    private static AAO_Source__c srcOf(String text) {
        return new AAO_Source__c(
            AAO_Normalized_Text__c = text,
            AAO_Diarization__c = 'Attributed',
            AAO_SHA256__c = AAO_NormalForm.sha256(text)
        );
    }
}