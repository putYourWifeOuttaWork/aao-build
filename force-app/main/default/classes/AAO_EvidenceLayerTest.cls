/**
 * The evidence layer, tested without DML: normal form segmentation, byte verification,
 * contiguity, and the speaker rule.
 *
 * These are the checks that decide whether a quote counts. They are worth testing on
 * their own, because in the accumulation test they only ever see fixtures built to pass.
 */
@IsTest
private class AAO_EvidenceLayerTest {
    private static final String TEXT = AAO_NormalForm.compose(
        new List<String>{ 'priya', 'dana' },
        new List<String>{
            'Where does budget stand?',
            'The funding is approved. Timing is still open.'
        }
    );

    private static AAO_Source__c attributed() {
        AAO_Source__c s = new AAO_Source__c(
            AAO_Normalized_Text__c = TEXT,
            AAO_Diarization__c = 'Attributed'
        );
        s.Id = AAO_FakeId.of(AAO_Source__c.SObjectType);
        return s;
    }

    private static AAO_Model.Span span(Id sourceId, Integer startOffset, Integer endOffset, String speaker) {
        AAO_Model.Span sp = new AAO_Model.Span();
        sp.sourceId = String.valueOf(sourceId);
        sp.partIndex = 1;
        sp.startOffset = startOffset;
        sp.endOffset = endOffset;
        sp.quote = TEXT.substring(startOffset, endOffset);
        sp.speaker = speaker;
        sp.element = 'e1';
        return sp;
    }

    private static Map<Id, AAO_Source__c> only(AAO_Source__c s) {
        return new Map<Id, AAO_Source__c>{ s.Id => s };
    }

    // ----------------------------------------------------------------- normal form

    @IsTest
    static void turnsCarryTheirOwnUtteranceRegion() {
        List<AAO_NormalForm.Turn> turns = AAO_NormalForm.turns(TEXT, 'Attributed');
        System.assertEquals(2, turns.size());
        System.assertEquals('priya', turns[0].speakerKey);
        System.assertEquals('Where does budget stand?', turns[0].utterance);
        System.assertEquals('dana', turns[1].speakerKey);
        System.assertEquals(
            turns[1].utterance,
            TEXT.substring(turns[1].utteranceStart, turns[1].utteranceEnd),
            'The utterance region must be the arithmetic, not a second copy of the words.'
        );
    }

    @IsTest
    static void anUnsegmentedDocumentIsOneRegionWithNoSpeaker() {
        String doc = 'Budget: approved.\nTiming: unknown.';
        List<AAO_NormalForm.Turn> turns = AAO_NormalForm.turns(doc, 'Unsegmented');
        System.assertEquals(1, turns.size());
        System.assertEquals(null, turns[0].speakerKey);
        System.assertEquals(0, turns[0].utteranceStart);
        System.assertEquals(doc.length(), turns[0].utteranceEnd);
    }

    // ---------------------------------------------------------- byte verification

    @IsTest
    static void aCorrectSpanVerifies() {
        AAO_Source__c s = attributed();
        List<AAO_NormalForm.Turn> turns = AAO_NormalForm.turns(TEXT, 'Attributed');
        Integer st = TEXT.indexOf('The funding is approved.');
        AAO_SpanVerifier.Result r = AAO_SpanVerifier.verify(
            new List<AAO_Model.Span>{ span(s.Id, st, st + 24, 'dana') },
            only(s)
        );
        System.assert(r.isOk(), r.describe());
        System.assertEquals('dana', r.speakerByIndex.get(0));
    }

    @IsTest
    static void aQuoteThatDoesNotMatchTheOffsetsFails() {
        AAO_Source__c s = attributed();
        AAO_Model.Span sp = span(s.Id, 0, 5, 'priya');
        sp.quote = 'Something else';
        AAO_SpanVerifier.Result r = AAO_SpanVerifier.verify(
            new List<AAO_Model.Span>{ sp },
            only(s)
        );
        System.assert(!r.isOk());
        System.assert(
            r.describe().contains('quote does not match'),
            'The failure must say what the offsets actually say. Got: ' + r.describe()
        );
    }

    @IsTest
    static void aSpanCrossingTwoTurnsFailsContiguity() {
        AAO_Source__c s = attributed();
        Integer st = TEXT.indexOf('budget stand?');
        Integer en = TEXT.indexOf('The funding') + 11;
        AAO_SpanVerifier.Result r = AAO_SpanVerifier.verify(
            new List<AAO_Model.Span>{ span(s.Id, st, en, null) },
            only(s)
        );
        System.assert(!r.isOk(), 'A span may not stitch two speakers into one assertion.');
        System.assert(r.describe().contains('contiguous'), r.describe());
    }

    @IsTest
    static void aSpanReachingIntoTheSpeakerPrefixFailsContiguity() {
        AAO_Source__c s = attributed();
        Integer st = TEXT.indexOf('dana');
        AAO_SpanVerifier.Result r = AAO_SpanVerifier.verify(
            new List<AAO_Model.Span>{ span(s.Id, st, st + 20, 'dana') },
            only(s)
        );
        System.assert(!r.isOk(), 'The speaker label is not part of what anybody said.');
    }

    @IsTest
    static void misattributingASpanFails() {
        AAO_Source__c s = attributed();
        Integer st = TEXT.indexOf('The funding is approved.');
        AAO_SpanVerifier.Result r = AAO_SpanVerifier.verify(
            new List<AAO_Model.Span>{ span(s.Id, st, st + 24, 'priya') },
            only(s)
        );
        System.assert(!r.isOk(), 'Claiming the wrong speaker said it must fail.');
        System.assert(r.describe().contains('attributes this to'), r.describe());
    }

    @IsTest
    static void offsetsPastTheEndFail() {
        AAO_Source__c s = attributed();
        AAO_Model.Span sp = new AAO_Model.Span();
        sp.sourceId = String.valueOf(s.Id);
        sp.startOffset = 0;
        sp.endOffset = TEXT.length() + 50;
        sp.quote = 'anything';
        AAO_SpanVerifier.Result r = AAO_SpanVerifier.verify(
            new List<AAO_Model.Span>{ sp },
            only(s)
        );
        System.assert(!r.isOk());
        System.assert(r.describe().contains('runs past the end'), r.describe());
    }

    @IsTest
    static void everyFailureIsReportedNotJustTheFirst() {
        AAO_Source__c s = attributed();
        AAO_Model.Span bad1 = span(s.Id, 0, 5, 'priya');
        bad1.quote = 'wrong';
        AAO_Model.Span bad2 = new AAO_Model.Span();
        bad2.sourceId = null;
        AAO_SpanVerifier.Result r = AAO_SpanVerifier.verify(
            new List<AAO_Model.Span>{ bad1, bad2 },
            only(s)
        );
        System.assertEquals(
            2,
            r.failures.size(),
            'A span set that fails in two ways is two findings. Got: ' + r.describe()
        );
    }

    // -------------------------------------------------------------- speaker rule

    private static AAO_Model.Speaker person(String display, String email, String mapRole) {
        AAO_Model.Speaker sp = new AAO_Model.Speaker();
        sp.key = display.toLowerCase().substringBefore(' ');
        sp.display = display;
        sp.email = email;
        sp.mapRole = mapRole;
        return sp;
    }

    private static final Set<String> INTERNAL = new Set<String>{ 'altify.example' };

    @IsTest
    static void theMappedDecisionMakerSatisfiesIt() {
        AAO_SpeakerRule.Verdict v = AAO_SpeakerRule.evaluate(
            'Decision_Maker_Or_Influencer',
            person('Dana Ruiz', 'dana.ruiz@northwind.example', 'Decision Maker'),
            INTERNAL
        );
        System.assert(v.satisfied, v.reason);
    }

    @IsTest
    static void theSellerDoesNotSatisfyABuyerSideRequirement() {
        AAO_SpeakerRule.Verdict v = AAO_SpeakerRule.evaluate(
            'Decision_Maker_Or_Influencer',
            person('Priya Shah', 'priya.shah@altify.example', null),
            INTERNAL
        );
        System.assert(!v.satisfied);
        System.assert(v.reason.contains('selling side'), v.reason);
    }

    @IsTest
    static void anUnmappedBuyerDoesNotSatisfyIt() {
        AAO_SpeakerRule.Verdict v = AAO_SpeakerRule.evaluate(
            'Decision_Maker_Or_Influencer',
            person('Sam Okafor', 'sam@northwind.example', null),
            INTERNAL
        );
        System.assert(!v.satisfied);
        System.assert(v.reason.contains('no buying role'), v.reason);
    }

    @IsTest
    static void theWrongBuyingRoleDoesNotSatisfyIt() {
        AAO_SpeakerRule.Verdict v = AAO_SpeakerRule.evaluate(
            'Decision_Maker_Or_Influencer',
            person('Sam Okafor', 'sam@northwind.example', 'Gatekeeper'),
            INTERNAL
        );
        System.assert(!v.satisfied);
        System.assert(v.reason.contains('Gatekeeper'), v.reason);
    }

    @IsTest
    static void noSpeakerSatisfiesOnlyAnyParticipant() {
        System.assert(
            AAO_SpeakerRule.evaluate('Any_Participant', null, INTERNAL).satisfied,
            'An unsegmented artifact can still satisfy any participant.'
        );
        System.assert(
            !AAO_SpeakerRule.evaluate('Seller', null, INTERNAL).satisfied,
            'It cannot satisfy anything that needs to know who spoke.'
        );
        System.assert(
            !AAO_SpeakerRule.evaluate('Buyer_Side', null, INTERNAL).satisfied
        );
    }

    @IsTest
    static void sellerAndBuyerSideAreDerivedByDomain() {
        System.assert(
            AAO_SpeakerRule.evaluate(
                'Seller',
                person('Priya Shah', 'priya.shah@altify.example', null),
                INTERNAL
            )
            .satisfied
        );
        System.assert(
            AAO_SpeakerRule.evaluate(
                'Buyer_Side',
                person('Dana Ruiz', 'dana.ruiz@NORTHWIND.example', 'Decision Maker'),
                INTERNAL
            )
            .satisfied,
            'Domain comparison is case-insensitive; email domains are.'
        );
    }

    // ----------------------------------------------------------- accumulation math

    @IsTest
    static void coverageMergesAsUnionAndMissingShrinks() {
        String first = AAO_Model.serializeCoverage(
            AAO_Model.newCoverage(new List<String>{ 'e1', 'e2' }, new List<String>{ 'e3' })
        );
        String second = AAO_Model.serializeCoverage(
            AAO_Model.newCoverage(new List<String>{ 'e3' }, new List<String>())
        );
        AAO_Model.Coverage merged = AAO_Accumulate.mergeCoverage(first, second);
        System.assertEquals(3, merged.covered.size());
        System.assert(merged.isFull(new List<String>{ 'e1', 'e2', 'e3' }), 'Missing was ' + merged.missing);
    }

    @IsTest
    static void theSameSpanTwiceAccumulatesOnce() {
        AAO_Source__c s = attributed();
        String one = AAO_Model.serializeSpans(
            new List<AAO_Model.Span>{ span(s.Id, 0, 5, 'priya') }
        );
        List<AAO_Model.Span> merged = AAO_Accumulate.mergeSpans(one, one);
        System.assertEquals(
            1,
            merged.size(),
            'The same evidence arriving twice produces nothing new.'
        );
    }

    @IsTest
    static void verdictRoutesOnCoverage() {
        System.assertEquals(
            null,
            AAO_Accumulate.verdictFor(
                AAO_Model.newCoverage(new List<String>(), new List<String>{ 'e1' }),
                'TRUE',
                new List<String>{ 'e1' }
            ),
            'No element covered writes nothing.'
        );
        System.assertEquals(
            'TRUE',
            AAO_Accumulate.verdictFor(
                AAO_Model.newCoverage(new List<String>{ 'e1' }, new List<String>{ 'e2' }),
                'TRUE',
                new List<String>{ 'e1', 'e2' }
            ),
            'The verifier upheld it, so it stands TRUE with the spans that exist; completeness rides beside it.'
        );
        System.assertEquals(
            'TRUE',
            AAO_Accumulate.verdictFor(
                AAO_Model.newCoverage(new List<String>{ 'e1' }, new List<String>()),
                'TRUE',
                new List<String>{ 'e1' }
            )
        );

        // CORRECTED IN PLACE, seventieth stamp. These two asserted that `verdictFor` routes an
        // incomplete proposal to UNVERIFIED. Matthew ruled at the sixty-ninth that COMPLETENESS
        // IS NOT A GATE, so it no longer routes on completeness at all and returns what the
        // verifier upheld.
        //
        // **THE DEFECT THE FIRST ONE GUARDED IS NOT LOST — IT MOVED UPSTREAM AND GOT STRICTER.**
        // "An empty missing list is a claim by the proposer, not a fact" is now enforced where
        // the record is WRITTEN rather than where it was read: `AAO_PairCommit` no longer stamps
        // every element covered by default, so a one-of-three proposal is recorded as one of
        // three with two missing. The old guard let a wrong record stand and corrected for it at
        // read time; the record is simply right now, which is the better place for it.
        System.assertEquals(
            'TRUE',
            AAO_Accumulate.verdictFor(
                AAO_Model.newCoverage(new List<String>{ 'e1' }, new List<String>()),
                'TRUE',
                new List<String>{ 'e1', 'e2', 'e3' }
            ),
            'The uphold governs; completeness rides on the answer rather than gating it.'
        );
        System.assertEquals(
            'TRUE',
            AAO_Accumulate.verdictFor(
                AAO_Model.newCoverage(new List<String>{ 'e1' }, new List<String>()),
                'TRUE',
                new List<String>()
            ),
            'And a contract naming no elements is a MINT-TIME data defect rather than something ' +
            'to catch by quietly unverifying every establishment made against it.'
        );
    }
}