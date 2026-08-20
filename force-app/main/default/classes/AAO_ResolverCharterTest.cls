/**
 * CALL 0, THE SCOPE READ. Charters v3.4, the two one-way halves.
 *
 * **This class did not exist before 6 August, and that is the finding it opens with.** The
 * scope read had failed twice on one fixture, earned two structural changes, and carried zero
 * unit tests through both of them - so a 355-test suite going green said nothing whatever
 * about it. The capability law names this exactly: a claim about our own code is unverified
 * until it is tried from the calling runtime.
 *
 * These are pure-function tests on the parse and the derivation, which is what the split made
 * possible: the verdict used to be a string the model wrote, and there was nothing to assert
 * about it that was not really an assertion about the model.
 */
@IsTest
private class AAO_ResolverCharterTest {
    // ==================================================================== the derivation

    @IsTest
    static void dualIsArithmeticAndNothingWeighsTheSidesAgainstEachOther() {
        System.assertEquals(
            AAO_ResolverCharter.DUAL,
            AAO_ResolverCharter.deriveScope(true, true),
            'Both sides yes is DUAL, computed rather than chosen.'
        );
        System.assertEquals(
            AAO_ResolverCharter.OPPORTUNITY,
            AAO_ResolverCharter.deriveScope(true, false)
        );
        System.assertEquals(
            AAO_ResolverCharter.ACCOUNT,
            AAO_ResolverCharter.deriveScope(false, true)
        );
    }

    @IsTest
    static void bothSidesNoIsItsOwnStateAndIsNotCoercedIntoAScope() {
        // The two-sided question could not express this: it offered three answers and every
        // one of them asserted content. The split makes it sayable, so it is surfaced.
        System.assertEquals(
            AAO_ResolverCharter.NEITHER,
            AAO_ResolverCharter.deriveScope(false, false)
        );
    }

    @IsTest
    static void aMinorityAccountStretchStillReachesDualTheDefectThisSplitExistsFor() {
        // The Emerson 17 June shape, twice: a call that is overwhelmingly purchase mechanics
        // and carries two real stretches of account content (enterprise AI strategy, and
        // account-level business-case control). Under one two-sided question that read
        // OPPORTUNITY twice, because a question offering "opportunity, account, or both"
        // invites a reader to weigh the sides and weighing produces a majority.
        //
        // **The assertion is that no proportion is an input here at all.** The account answer
        // is a yes on its own merits and the derivation cannot see how big it was.
        System.assertEquals(
            AAO_ResolverCharter.DUAL,
            AAO_ResolverCharter.deriveScope(true, true),
            'A minority side that answered yes is a yes. There is no majority anywhere in ' +
            'this function, which is the whole repair.'
        );
    }

    // ========================================================================= the schema

    @IsTest
    static void theTwoSidedQuestionIsStructurallyGoneFromTheSchema() {
        Map<String, Object> sch = AAO_ResolverCharter.schema(new List<String>{ 'd1' });
        Map<String, Object> props = (Map<String, Object>) sch.get('properties');

        System.assertEquals(
            false,
            props.containsKey('scope'),
            'The model must have no field in which to express a weighed scope verdict. ' +
            'Retiring the wording while leaving the field would be the third wording fix.'
        );
        System.assertEquals(false, props.containsKey('scope_because'));
        // THE BOOLEANS ARE GONE ON PURPOSE, hundred-forty-first stamp. A boolean beside a
        // string is how a yes without words gets said: an empty string satisfies
        // `type: string`, so `true` beside `""` was fully schema-valid, and the endpoint
        // refuses the conditional that would have forbidden it. The quote IS the answer.
        System.assertEquals(
            false,
            props.containsKey('carries_opportunity_content'),
            'A boolean beside the quote is a second way to say yes, and the second way is ' +
            'the one that can say it without words.'
        );
        System.assertEquals(false, props.containsKey('carries_account_content'));

        List<Object> required = (List<Object>) sch.get('required');
        Set<String> req = new Set<String>();
        for (Object o : required) {
            req.add(String.valueOf(o));
        }
        System.assert(
            req.contains('opportunity_content_quote') &&
                req.contains('account_content_quote'),
            'BOTH sides are required. An optional side is a side that can go unanswered, ' +
            'and an unanswered account question is the exact failure being repaired.'
        );
        System.assertEquals(
            false,
            req.contains('carries_opportunity_content') ||
                req.contains('carries_account_content'),
            'A retired field must leave the required list with the property, or the wire ' +
            'schema and this class disagree about what call 0 was asked.'
        );
    }

    // ========================================================================== the parse

    private static final String ARTIFACT =
        'Renee: So on pricing, we can do 25 percent at that volume and 35 if you commit ' +
        'to the three year term, and legal has the MSA now. ' +
        'Neeraja: Separately, the enterprise AI strategy for next year is something I own, ' +
        'and I want to make sure whatever we do here fits under it. ' +
        'Ryan: Understood.';

    private static final String OPP_WORDS =
        'we can do 25 percent at that volume and 35 if you commit to the three year term';
    private static final String ACCT_WORDS =
        'the enterprise AI strategy for next year is something I own';

    private static String payload(
        Boolean oppYes, String oppQuote, Boolean acctYes, String acctQuote
    ) {
        return JSON.serialize(
            new Map<String, Object>{
                'opportunity_content_quote' => oppQuote,
                'opportunity_content_because' => oppYes
                    ? 'Discounting tiers and MSA review are the mechanics of a purchase.'
                    : '',
                'account_content_quote' => acctQuote,
                'account_content_because' => acctYes
                    ? 'Ownership of a standing enterprise strategy is account-grain work.'
                    : '',
                'opportunity' => 'd1',
                'opportunity_because' => 'The pricing discussion names this deal\'s terms.',
                'mentions' => new List<Object>()
            }
        );
    }

    private static List<String> handles() {
        return new List<String>{ 'd1' };
    }

    @IsTest
    static void bothSidesAnsweredYesParsesToDualAndBothQuotesLocate() {
        AAO_ResolverCharter.Result r = AAO_ResolverCharter.parse(
            payload(true, OPP_WORDS, true, ACCT_WORDS), handles()
        );
        System.assertEquals(AAO_ResolverCharter.DUAL, r.scope);

        AAO_ResolverCharter.locate(r, ARTIFACT);
        System.assert(r.opportunitySide.located(), 'Opportunity words must byte-locate.');
        System.assert(r.accountSide.located(), 'Account words must byte-locate.');
        System.assertEquals(
            ARTIFACT.indexOf(ACCT_WORDS),
            r.accountSide.offset,
            'The offset is the real one, not a flag that something was found.'
        );
    }

    @IsTest
    static void theComposedReasonNamesBothSidesIncludingTheOneThatSaidNo() {
        AAO_ResolverCharter.Result r = AAO_ResolverCharter.parse(
            payload(true, OPP_WORDS, false, ''), handles()
        );
        System.assertEquals(AAO_ResolverCharter.OPPORTUNITY, r.scope);
        System.assert(
            r.scopeBecause.contains('ACCOUNT content: no'),
            'A run report must be able to show that the account question was asked and ' +
            'answered no, which is a different fact from it never having been asked. Got: ' +
            r.scopeBecause
        );
        System.assert(r.scopeBecause.contains('OPPORTUNITY content: YES'), r.scopeBecause);
    }

    @IsTest
    static void aYesWithNoWordsIsNotRefusedBecauseItCannotBeSaid() {
        // THE REPAIR OF THE HUNDRED-FORTY-FIRST. This used to throw 'quoted nothing', which
        // meant the violation was expressible and caught afterwards, on a run that had
        // already stopped. There is no boolean to say yes with any more, so an empty quote
        // is simply a no. The law is not enforced here; it is unexpressible upstream.
        AAO_ResolverCharter.Result r =
            AAO_ResolverCharter.parse(payload(true, '', false, ''), handles());
        System.assertEquals(
            false,
            r.opportunitySide.carries,
            'Words are the yes. No words is a no, and there is no third thing to be.'
        );
        System.assertEquals(true, r.carriesNothing());
    }

    @IsTest
    static void aBooleanComingBackMeansTheWireSchemaIsNotThisClass() {
        // The stray guard. If a model answers a question this charter stopped asking, the
        // schema on the wire is not the schema in this class, and that is our bug rather
        // than the model's - exactly the direction the parse law points.
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(
            payload(true, OPP_WORDS, false, '')
        );
        body.put('carries_opportunity_content', true);
        try {
            AAO_ResolverCharter.parse(JSON.serialize(body), handles());
            System.assert(false, 'A retired field coming back must not pass silently.');
        } catch (AAO_ResolverCharter.CharterException e) {
            System.assert(
                e.getMessage().contains('no longer asks for'),
                e.getMessage()
            );
        }
    }

    @IsTest
    static void aYesOnWordsThatAreNotInTheArtifactIsRefused() {
        // Strictly worse than a no: it routes family reads at content nobody said.
        AAO_ResolverCharter.Result r = AAO_ResolverCharter.parse(
            payload(true, OPP_WORDS, true, 'we should talk about the QBR next quarter'),
            handles()
        );
        try {
            AAO_ResolverCharter.locate(r, ARTIFACT);
            System.assert(false, 'An unlocatable quote must not survive.');
        } catch (AAO_ResolverCharter.CharterException e) {
            System.assert(e.getMessage().contains('not in the artifact'), e.getMessage());
        }
    }

    @IsTest
    static void aMissingSideIsOurBugAndIsNeverReadAsANo() {
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(
            payload(true, OPP_WORDS, false, '')
        );
        body.remove('account_content_quote');
        try {
            AAO_ResolverCharter.parse(JSON.serialize(body), handles());
            System.assert(false, 'A missing side must throw rather than default.');
        } catch (AAO_ResolverCharter.CharterException e) {
            System.assert(
                e.getMessage().contains('never got asked'),
                'Absence of an answer is not an answer, and reading it as a no would ' +
                'silently reproduce the exact under-call this split repairs. Got: ' +
                e.getMessage()
            );
        }
    }

    @IsTest
    static void theReasonGuardReachesTheSideReasonsToo() {
        // The `placeholder` defect, fixed at the parse on 6 August, must hold on the new
        // fields rather than only on the retired one.
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(
            payload(true, OPP_WORDS, false, '')
        );
        body.put('opportunity_content_because', 'placeholder');
        try {
            AAO_ResolverCharter.parse(JSON.serialize(body), handles());
            System.assert(false, 'A non-reason must not satisfy a required reason field.');
        } catch (AAO_ResolverCharter.CharterException e) {
            System.assert(e.getMessage().contains('non-reason'), e.getMessage());
        }
    }

    @IsTest
    static void aNoNeedsNoEvidenceBecauseItAssertsNothing() {
        AAO_ResolverCharter.Result r = AAO_ResolverCharter.parse(
            payload(false, '', false, ''), handles()
        );
        System.assertEquals(AAO_ResolverCharter.NEITHER, r.scope);
        System.assertEquals(true, r.carriesNothing());
        // And locating is a no-op rather than a failure: there is nothing to find.
        AAO_ResolverCharter.locate(r, ARTIFACT);
        System.assertEquals(null, r.accountSide.offset);
    }

    @IsTest
    static void thePromptNeverAsksWhichSideWins() {
        String p = AAO_ResolverCharter.systemPrompt();
        System.assert(
            p.contains('DO NOT COMPETE') || p.contains('do not compete') ||
                p.contains('as if the other had not been asked'),
            'The instruction that the two answers are independent is the charter half of ' +
            'this repair and must actually be in the prompt.'
        );
        System.assert(
            !p.contains('Answer DUAL when'),
            'The retired instruction to pick DUAL must be gone: there is no DUAL field to ' +
            'answer any more, so an instruction about answering it is stale text that ' +
            'contradicts the schema.'
        );
    }
}