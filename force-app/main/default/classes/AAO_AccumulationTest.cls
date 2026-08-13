/**
 * The exit test, exactly as the build brief specifies it.
 *
 *   1. Two claims exist, ordered by AAO_Evidence_Occurred__c, eleven days apart. Not by
 *      processing time.
 *   2. The first claim still reads UNVERIFIED. Nothing edited it. This is what makes
 *      progress visible.
 *   3. The answer reads TRUE and its accumulated spans include quotes from both sources.
 *   4. Every span byte-verifies against its own Source's normalized text, and every span
 *      is contiguous inside a single speaker turn.
 *   5. Replaying claims in evidence-occurred order reconstructs the answer exactly.
 *      Rebuild from an empty mirror; the result must be identical field for field.
 *   6. The candidate ledger is complete.
 *
 * Passing this demonstrates incrementalism in an org rather than in an argument.
 */
@IsTest
private class AAO_AccumulationTest {
    private static AAO_Seed.Loaded seed;

    private static AAO_Seed.Loaded load() {
        if (seed == null) {
            seed = AAO_Seed.load();
        }
        return seed;
    }

    /** Transcript one, then transcript two, in that order. Returns the main deal's id. */
    private static Id runTheTwoPasses(AAO_Seed.Loaded s) {
        AAO_Commit.commitCandidate(s.candidateByCode.get('C1').Id, s.internalDomains);
        AAO_Seed.logAbstentions(s, 'main', 'T1SRC', 'AAO_Extract_Evidence', '0.1.0');

        AAO_Commit.commitCandidate(s.candidateByCode.get('C2').Id, s.internalDomains);
        AAO_Seed.logAbstentions(s, 'main', 'T2SRC', 'AAO_Extract_Evidence', '0.1.0');

        return s.opportunityByDeal.get('main');
    }

    // ================================================================ the exit test

    @IsTest
    static void theAccumulationTest() {
        AAO_Seed.Loaded s = load();

        Test.startTest();
        Id oppId = runTheTwoPasses(s);
        Test.stopTest();

        // ---- 1. two claims, on the occurred clock, eleven days apart
        List<AAO_Claim__c> claims = [
            SELECT
                Id,
                AAO_Verdict_Before__c,
                AAO_Verdict_After__c,
                AAO_Source__c,
                AAO_Outcome__c,
                AAO_Actor__c,
                AAO_Basis__c,
                AAO_Spans__c,
                AAO_Evidence_Occurred__c,
                AAO_Recorded_At__c,
                AAO_Internal_Person__c,
                AAO_External_Person__c
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :oppId
            ORDER BY AAO_Evidence_Occurred__c ASC
        ];
        System.assertEquals(2, claims.size(), 'Expected exactly two claims.');

        Long deltaMs =
            claims[1].AAO_Evidence_Occurred__c.getTime() -
            claims[0].AAO_Evidence_Occurred__c.getTime();
        System.assertEquals(
            11L * 24 * 60 * 60 * 1000,
            deltaMs,
            'The claims must be eleven days apart on the evidence-occurred clock, not on ' +
            'processing time. Both were processed inside one transaction.'
        );

        // ---- 2. the first claim stands on its own uphold, and nothing edited it
        //
        // CORRECTED IN PLACE, seventieth stamp. This assertion used to read UNVERIFIED, on the
        // brief's original rule that partial coverage writes UNVERIFIED. Matthew ruled at the
        // sixty-ninth that THE UPHOLD GOVERNS and completeness is data rather than a gate, so
        // the first claim now reads TRUE on the strength of the verifier that upheld it. What
        // the original point protected — that progress is VISIBLE and nothing edits a standing
        // claim — is unchanged and asserted below: the claim is immutable, and the thing that
        // visibly progresses is COMPLETENESS, which is what item 3 now measures.
        System.assertEquals(
            null,
            claims[0].AAO_Verdict_Before__c,
            'The first claim created the answer, so there was nothing before it.'
        );
        System.assertEquals(
            'TRUE',
            claims[0].AAO_Verdict_After__c,
            'The verifier upheld these words, so the claim stands TRUE with the spans it has.'
        );
        System.assertEquals('MACHINE', claims[0].AAO_Actor__c);
        System.assertEquals('Transcript', claims[0].AAO_Basis__c);
        System.assertEquals('Established', claims[0].AAO_Outcome__c);

        // CORRECTED IN PLACE with the assertion above, and for the same reason: the answer the
        // second claim arrived at already stood TRUE on the first claim's uphold. The POINT of
        // this assertion is untouched — a claim records the state it found, so the ledger can be
        // replayed and audited — and that is what still fails if the before-state stops being
        // written at all.
        System.assertEquals(
            'TRUE',
            claims[1].AAO_Verdict_Before__c,
            'The second claim records what the answer was when it arrived.'
        );
        System.assertEquals('TRUE', claims[1].AAO_Verdict_After__c);
        System.assertEquals(
            s.sourceByCode.get('T1SRC').Id,
            claims[0].AAO_Source__c,
            'One claim rests on one Source. The lookup is singular and correct.'
        );
        System.assertEquals(s.sourceByCode.get('T2SRC').Id, claims[1].AAO_Source__c);

        // ---- key four of four is populated, not dead
        for (AAO_Claim__c c : claims) {
            System.assertEquals(
                UserInfo.getUserId(),
                c.AAO_Internal_Person__c,
                'AAO_Internal_Person__c opens the seller-to-buyer grain, which is where ' +
                'relationship standing lives. A grain not recorded cannot be declared ' +
                'later without reprocessing the corpus. It is resolved from the roster ' +
                'participants, never assumed from the deal owner.'
            );
        }

        // ---- 3. the answer reads TRUE, with quotes from both sources
        List<AAO_Answer__c> answers = [
            SELECT
                Id,
                AAO_Answer_Key__c,
                AAO_Verdict__c,
                AAO_Spans__c,
                AAO_Element_Completeness__c,
                AAO_Established_By__c,
                AAO_Last_Claim__c,
                AAO_Evidence_Occurred__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :oppId
        ];
        System.assertEquals(1, answers.size(), 'One answer per question per subject.');
        AAO_Answer__c answer = answers[0];
        System.assertEquals('TRUE', answer.AAO_Verdict__c);
        System.assertEquals('MACHINE', answer.AAO_Established_By__c);
        System.assertEquals(
            claims[1].Id,
            answer.AAO_Last_Claim__c,
            'The frozen row beside the live one.'
        );

        Set<Id> sourcesQuoted = new Set<Id>();
        List<AAO_Model.Span> accumulated = AAO_Model.parseSpans(answer.AAO_Spans__c).spans;
        for (AAO_Model.Span sp : accumulated) {
            sourcesQuoted.add(Id.valueOf(sp.sourceId));
        }
        System.assertEquals(
            2,
            sourcesQuoted.size(),
            'The accumulated spans must include quotes from both sources. This is what ' +
            'lets call two say there was already partial evidence and now it is ' +
            'sufficient. Got quotes from ' + sourcesQuoted.size() + ' source(s).'
        );
        System.assertEquals(
            5,
            accumulated.size(),
            'Two spans from transcript one plus three from transcript two.'
        );

        AAO_Model.Coverage cov = AAO_Model.parseCoverage(answer.AAO_Element_Completeness__c);
        System.assert(
            cov.isFull(new List<String>{ 'e1', 'e2', 'e3' }),
            'Coverage completed; missing was ' + cov.missing
        );
        System.assertEquals(3, cov.covered.size());

        // ---- 4. every span byte-verifies, and is contiguous inside one turn
        Map<Id, AAO_Source__c> sourceById = new Map<Id, AAO_Source__c>(
            [
                SELECT Id, AAO_Normalized_Text__c, AAO_Diarization__c
                FROM AAO_Source__c
                WHERE Id IN :sourcesQuoted
            ]
        );
        AAO_SpanVerifier.Result sv = AAO_SpanVerifier.verify(accumulated, sourceById);
        System.assert(
            sv.isOk(),
            'Every accumulated span must byte-verify against its own Source: ' + sv.describe()
        );
        System.assertEquals(
            accumulated.size(),
            sv.speakerByIndex.size(),
            'Every span resolved to exactly one speaker turn.'
        );

        // ---- 5. replay reconstructs the answer exactly, from an empty mirror
        Map<String, AAO_Answer__c> rebuilt = AAO_Replay.rebuild(oppId);
        System.assertEquals(
            1,
            rebuilt.size(),
            'Replay produced ' + rebuilt.size() + ' answers from two claims.'
        );
        List<String> differences = AAO_Replay.diff(rebuilt, AAO_Replay.liveAnswers(oppId));
        System.assert(
            differences.isEmpty(),
            'Replaying claims in evidence-occurred order must reconstruct the answer ' +
            'exactly, field for field. Differences: ' + String.join(differences, ' | ')
        );

        // ---- 6. the candidate ledger is complete
        List<AggregateResult> byOutcome = [
            SELECT AAO_Outcome__c o, COUNT(Id) n
            FROM AAO_Candidate__c
            WHERE AAO_Opportunity__c = :oppId
            GROUP BY AAO_Outcome__c
        ];
        Map<String, Integer> counts = new Map<String, Integer>();
        Integer total = 0;
        for (AggregateResult ar : byOutcome) {
            Integer n = (Integer) ar.get('n');
            counts.put((String) ar.get('o'), n);
            total += n;
        }
        System.assertEquals(
            12,
            total,
            'Six propositions considered on each of two passes. Every proposition ' +
            'considered writes a row, so the abstention rate is a direct query and "did ' +
            'it even look" is answerable. Got: ' + counts
        );
        System.assertEquals(
            10,
            counts.get('Abstained'),
            'Five propositions nothing was said about, on each of two passes. Got: ' + counts
        );
        System.assertEquals(2, counts.get('Upheld'), 'Got: ' + counts);

        Integer nobodySaid = [
            SELECT COUNT()
            FROM AAO_Candidate__c
            WHERE
                AAO_Opportunity__c = :oppId
                AND AAO_Abstention_Reason__c = 'nobody_said'
        ];
        System.assertEquals(
            10,
            nobodySaid,
            'The ones nothing was said about carry nobody_said, not model_missed.'
        );
    }

    // ============================================== progress is visible, restated

    /**
     * COMPLETENESS ACCUMULATES ACROSS UTTERANCES, and this is the specimen.
     *
     * Matthew's ruling at the seventieth stamp: *"If March's words satisfy one element and
     * June's different-but-related words satisfy the missing one, the requirement is complete
     * and the value reads complete."* This fixture is exactly that shape — two transcripts
     * eleven days apart, the first covering one element and the second the other — so the union
     * is provable on a fixture that already existed rather than on one written to pass.
     *
     * **THE UNION IS DETERMINISTIC AND HAPPENS AT THE JOIN.** No model reads state, call 3
     * stays blind, and the accumulation is set arithmetic on element ids in
     * `AAO_Accumulate.mergeCoverage`. This test pins that it happens ACROSS CLAIMS, which is
     * the same thing as across utterances, and only within one answer, which is by construction
     * one subject against one contract.
     *
     * CORRECTED IN PLACE, seventieth stamp: this was `replayingOnlyTheFirstClaimGivesUnverified`
     * and asserted the VERDICT moving UNVERIFIED to TRUE. Under the uphold-governs ruling the
     * verdict no longer moves, so what it measures now is the thing that actually accumulates.
     */
    @IsTest
    static void completenessACCUMULATESACROSSUTTERANCESANDTHEVERDICTSTANDSONITSUPHOLD() {
        AAO_Seed.Loaded s = load();

        Test.startTest();
        AAO_Commit.commitCandidate(s.candidateByCode.get('C1').Id, s.internalDomains);
        Map<String, AAO_Answer__c> afterOne = AAO_Replay.rebuild(
            s.opportunityByDeal.get('main')
        );

        AAO_Commit.commitCandidate(s.candidateByCode.get('C2').Id, s.internalDomains);
        Map<String, AAO_Answer__c> afterTwo = AAO_Replay.rebuild(
            s.opportunityByDeal.get('main')
        );
        Test.stopTest();

        AAO_Answer__c one = afterOne.values()[0];
        AAO_Answer__c two = afterTwo.values()[0];

        System.assertEquals(
            'TRUE', one.AAO_Verdict__c,
            'One transcript in, the verifier had already upheld it, so it stands TRUE.'
        );
        System.assertEquals('TRUE', two.AAO_Verdict__c, 'And it still does.');

        AAO_Model.Coverage first = AAO_Model.parseCoverage(one.AAO_Element_Completeness__c);
        AAO_Model.Coverage both = AAO_Model.parseCoverage(two.AAO_Element_Completeness__c);
        System.assert(
            both.covered.size() > first.covered.size(),
            'THE UNION IS THE THING THAT MOVES: the second utterance adds the missing element. ' +
            'Got ' + first.covered + ' then ' + both.covered
        );
        for (String e : first.covered) {
            System.assert(
                both.covered.contains(e),
                'A union never loses what it had. Missing ' + e + ' from ' + both.covered
            );
        }

        // THE INTEGRITY CONDITION. An accumulated establishment is never one merged quote: every
        // element keeps its own span, and a reader must be able to see it was assembled and when.
        List<AAO_Model.Span> spans = AAO_Model.parseSpans(two.AAO_Spans__c).spans;
        System.assert(
            spans.size() >= 2,
            'Both utterances keep their own span rather than being stitched into one. Got ' +
            spans.size()
        );
        Set<String> sources = new Set<String>();
        for (AAO_Model.Span sp : spans) {
            sources.add(sp.sourceId);
            System.assert(
                String.isNotBlank(sp.quote), 'Every span carries its own words.'
            );
            System.assertNotEquals(
                null, sp.startOffset, 'And its own offsets, so its date is resolvable from it.'
            );
        }
        System.assert(
            sources.size() >= 2,
            'Cross-source accumulation is expected; the spans name their own Sources. Got ' +
            sources
        );
    }

    /**
     * COMPLETENESS IS NOT REINFORCEMENT, and the sixty-ninth stamp forbids collapsing them.
     *
     * Its words: "COMPLETENESS is which parts of the question these words answer... REINFORCEMENT
     * is how many times a person said it (the card counter). Collapsing any of them into the
     * others is how a completeness measure silently becomes a confidence score, which nobody
     * ruled and nobody could audit."
     *
     * A later utterance carrying a MISSING element advanced the requirement; it did not press the
     * same point again. Reinforcement is a count guidance ORDERS BY, so inflating it with
     * completions is a lie about how often somebody pressed something — the same lie the pair
     * watermark exists to prevent, arriving through a different door.
     *
     * This was unreachable until the uphold-governs ruling: while the first claim read UNVERIFIED
     * the two verdicts differed, so the reinforcement branch never fired on a completing
     * utterance at all.
     */
    @IsTest
    static void aCOMPLETINGUTTERANCEISESTABLISHEDANDNEVERREINFORCEMENT() {
        AAO_Seed.Loaded s = load();

        Test.startTest();
        Id oppId = runTheTwoPasses(s);
        Test.stopTest();

        List<AAO_Claim__c> claims = [
            SELECT AAO_Outcome__c, AAO_Element_Completeness__c
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :oppId
            ORDER BY AAO_Evidence_Occurred__c ASC
        ];
        System.assertEquals(2, claims.size());
        System.assertEquals(
            'Established',
            claims[1].AAO_Outcome__c,
            'The second utterance carried the missing element, so it ESTABLISHED rather than ' +
            'repeated. Reinforcement here would inflate a count guidance orders by.'
        );
        System.assert(
            AAO_Model.parseCoverage(claims[1].AAO_Element_Completeness__c).covered.size() >
                AAO_Model.parseCoverage(claims[0].AAO_Element_Completeness__c).covered.size(),
            'And the reason it is not reinforcement is visible in the row: it added an element.'
        );
    }

    // ================================================ also worth running, cheaply

    /**
     * The same words as transcript two, spoken by the seller instead of the mapped
     * decision maker. This is the ruling that regraded Gate 1 run two, and it should be
     * provable in the org in one run.
     */
    @IsTest
    static void theSameWordsFromTheSellerDoNotEstablishIt() {
        AAO_Seed.Loaded s = load();

        Test.startTest();
        AAO_Commit.Result r = AAO_Commit.commitCandidate(
            s.candidateByCode.get('CNEG').Id,
            s.internalDomains
        );
        Test.stopTest();

        System.assertNotEquals(null, r.claim, 'It writes a claim with receipts.');
        System.assertEquals(
            'UNVERIFIED',
            r.answer.AAO_Verdict__c,
            'The speaker requirement fails, so it writes UNVERIFIED with receipts rather ' +
            'than TRUE. Note: ' + r.note
        );
        System.assertEquals('Downgraded', r.claim.AAO_Outcome__c);
        System.assertEquals(
            'Downgraded_Speaker_Rank',
            [
                SELECT AAO_Outcome__c
                FROM AAO_Candidate__c
                WHERE Id = :s.candidateByCode.get('CNEG').Id
            ]
            .AAO_Outcome__c
        );

        List<AAO_Model.Span> spans = AAO_Model.parseSpans(r.answer.AAO_Spans__c).spans;
        System.assertEquals(
            3,
            spans.size(),
            'The receipts are carried. What failed is who said the words, not whether ' +
            'they were said.'
        );
        System.assert(
            r.note.contains('Decision_Maker_Or_Influencer'),
            'The note must name the requirement that was unmet. Got: ' + r.note
        );
    }

    /**
     * One transcript with no speaker turns at all, the Notion shape. Otherwise we only
     * ever prove the easy class.
     */
    @IsTest
    static void anUnsegmentedArtifactVerifiesButCannotSatisfyTheSpeakerRule() {
        AAO_Seed.Loaded s = load();

        AAO_Source__c src = [
            SELECT Id, AAO_Diarization__c, AAO_Normalized_Text__c, AAO_Speaker_Roster__c
            FROM AAO_Source__c
            WHERE Id = :s.sourceByCode.get('UNSEGSRC').Id
        ];
        System.assertEquals('Unsegmented', src.AAO_Diarization__c);
        System.assertEquals(
            null,
            src.AAO_Speaker_Roster__c,
            'An unsegmented artifact has no roster to carry.'
        );

        Test.startTest();
        AAO_Commit.Result r = AAO_Commit.commitCandidate(
            s.candidateByCode.get('CUNSEG').Id,
            s.internalDomains
        );
        Test.stopTest();

        System.assertNotEquals(
            null,
            r.claim,
            'The span verifies as a contiguous substring of the whole document, so there ' +
            'is something to write.'
        );
        System.assertEquals(
            'UNVERIFIED',
            r.answer.AAO_Verdict__c,
            'It cannot satisfy the speaker requirement on AAO_T1 at all. Note: ' + r.note
        );
        System.assert(
            r.note.contains('no speaker attribution'),
            'The note must say why, in terms of the artifact rather than the people. ' +
            'Got: ' + r.note
        );
    }
}
