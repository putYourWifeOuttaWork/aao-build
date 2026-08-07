/**
 * EVERY GRADED FINDING BECOMES A STANDING ASSERTION ON EVERY LATER RUN.
 *
 * The reason this exists is one line from the first Emerson grading: **a Matthew-graded PASS
 * disappeared between two runs of the same artifact and nothing in the system noticed.**
 * *"Flexibility of Services Hours"* — the one criterion he affirmatively named as real — was
 * simply absent from the re-run, and the report said a bigger number and nothing else.
 * Nothing in the system COULD have noticed, and that is the gap this closes.
 *
 * **The traps and the passes are the same mechanism from opposite ends.** A trap must not
 * appear; a pass must appear. One assertion set, one report line each, and neither costs a
 * model call — it is set membership over bytes already recorded.
 *
 * MATCHING IS BYTE-RANGE OVERLAP IN THE FROZEN ARTIFACT, the same rule `AAO_RecallGate` uses
 * and for the same reason: call 1 picks its own coextensive boundary, so a target quote taken
 * from a graded row will rarely share it, and string equality would report a miss for a
 * disagreement about where a sentence ends.
 */
public with sharing class AAO_Regression {
    public class RegressionException extends Exception {
    }

    public static final String MUST_APPEAR = 'MUST_APPEAR';
    public static final String MUST_NOT_APPEAR = 'MUST_NOT_APPEAR';
    /** Graded by Matthew as something the read MISSED. Not a regression; a recall target. */
    public static final String GRADED_MISS = 'GRADED_MISS';
    /** A graded finding whose family is not declared, so no run can produce it. */
    public static final String UNREACHABLE = 'UNREACHABLE';
    /**
     * Graded a CORRECT REFUSAL. Reported, never scored.
     *
     * `emerson-q13` was a MUST_APPEAR until Matthew's ruling of 5 August, and the ruling is
     * right: **asserting that a correct refusal must keep appearing asserts that call 1 must
     * keep making a mistake call 3 can catch.** Finding it and refusing it is acceptable;
     * not finding it at all is better. The assertion's own words — *a run that stops finding
     * it has not got better, it has stopped looking* — are true of a graded PASS and false
     * here, and that difference belongs in the code rather than in a comment.
     */
    public static final String CORRECT_REFUSAL = 'CORRECT_REFUSAL';

    public static final String EMERSON = 'ec8e717045f8701534963576ded2a736df5a27b5314721f20b6aa004d5f25a5f';
    public static final String BV = 'bv/biweekly-2026-06-24-nf1';

    public class Assertion {
        public String key;
        /** Artifact this was graded on. An assertion never travels between fixtures. */
        public String fixture;
        public String kind;
        /** Contract code, or a prefix ending in `*` where the grade named a family. */
        public String contractCode;
        public String quote;
        /** Upheld or Refused where the grading also settled call 3's verdict. */
        public String expectedVerdict;
        public String why;
    }

    public static List<Assertion> assertions() {
        List<Assertion> out = new List<Assertion>();

        // ---- EMERSON · the three graded rows that must survive every run -------------
        out.add(a(EMERSON, MUST_APPEAR, 'emerson-q1', 'AAO_PS_1',
            'I want to make sure that we\'re presenting a compelling story to those approvers',
            'Upheld',
            'Graded PASS. Jefferson, MENTOR, upheld by call 3 and by Matthew.'));
        out.add(a(EMERSON, MUST_APPEAR, 'emerson-q9', 'AAO_DC_N',
            'I want to make sure we have flexibility of using those hours at any point of time to cater to business',
            'Upheld',
            'Graded PASS: "This should be a real criteria, Flexibility of Services Hours." ' +
            '**THIS IS THE ONE THAT VANISHED** on the re-run of the same artifact, which is ' +
            'why this class exists.'));
        out.add(a(EMERSON, CORRECT_REFUSAL, 'emerson-q13', 'AAO_BR_USER',
            'we want to get ahead of the relationship map gap that we have for sales',
            'Refused',
            'Graded a CORRECT REFUSAL: "False outright, she is speaking to a company goal, ' +
            'not a user statement." Reported, never scored: a run that stops emitting it has ' +
            'stopped making a mistake, which is an improvement rather than a loss.'));

        // ---- EMERSON · Matthew's added rows, byte-located by design in ec8e7170 -------
        //
        // These are UNDERs rather than regressions: things the read should have found and did
        // not. They are recall targets and are reported separately, because a run that fails
        // one has not lost anything it once had.
        out.add(a(EMERSON, GRADED_MISS, 'under-1-neeraja-supporter', 'AAO_PS_1',
            'So I just want to make sure that I\'m available to support.', null,
            'Matthew: Clearly Supportive.'));
        out.add(a(EMERSON, GRADED_MISS, 'under-2-neeraja-political', 'AAO_POL_PS*',
            'So the second question I have answered. Yes.', null,
            'Matthew: Political Structure, full.'));
        out.add(a(EMERSON, GRADED_MISS, 'under-3-neeraja-approver', 'AAO_BR_APP',
            'the user training, the two SKUs on the bottom that says the relationship map user training and the insight user training',
            null,
            'Matthew: Approver. NOTE, and it is a real limit rather than a bad paste: his read ' +
            'is of a thought CONTINUED ACROSS AN INTERRUPTION. 248 of his 512 characters ' +
            'locate here; the resumed clause is a second span at offset 23,530, and three ' +
            'other speakers\' turns sit between them. **One establishment, two spans, and the ' +
            'one-span-per-pair model cannot express it.** Recorded before anything is built ' +
            'that assumes contiguity.'));
        out.add(a(EMERSON, GRADED_MISS, 'under-5-neeraja-political', 'AAO_POL_PS*',
            'I don\'t think there is an enterprise plan of integrating an AI into our transactional systems',
            null, 'Matthew: Political Status, Political Structure.'));
        out.add(a(EMERSON, GRADED_MISS, 'under-6-neeraja-supporter', 'AAO_PS_1',
            'I think it\'s great that I did see this capability when I was understanding', null,
            'Matthew: Sentiment, Supporter.'));
        out.add(a(EMERSON, GRADED_MISS, 'under-8-jefferson-supporter', 'AAO_PS_1',
            'the annual total is going to be the thing that gets the most amount of scrutiny when it comes to the approvals',
            null,
            'Matthew: Sentiment, Supporter, on the SAME bytes he also read as Decision ' +
            'Orientation. A multi-establishment specimen.'));

        // ---- EMERSON · graded, and structurally unreachable --------------------------
        //
        // Reported as their own line so they never inflate a recall failure. Decision
        // Orientation is an UNDECLARED FAMILY: no contract exists, so no prompt, no read and
        // no repair could produce these. They are the account-charter's evidence, waiting.
        out.add(a(EMERSON, UNREACHABLE, 'under-4-neeraja-orientation', 'DECISION_ORIENTATION',
            'I want to make sure we have flexibility of using those hours', null,
            'Matthew: Decision Orientation, Business. Undeclared family.'));
        out.add(a(EMERSON, UNREACHABLE, 'under-7-neeraja-orientation', 'DECISION_ORIENTATION',
            'we would have CSM, we would have support as part of the regular licensing', null,
            'Matthew: Decision Orientation, Business. Undeclared family, and account grain.'));
        out.add(a(EMERSON, UNREACHABLE, 'under-8-jefferson-orientation', 'DECISION_ORIENTATION',
            'the total cost, the annual total is going to be the thing that gets the most amount of scrutiny',
            null, 'Matthew: Decision Orientation, Financial. Undeclared family.'));


        // ---- EMERSON · the sweep s1 grading, 5 August · 18 standing assertions ---------
        //
        // Every establishment Matthew graded True in the s1 file. **Keyed on contract plus
        // byte-range intersection, never the stored string**, and the spans below are the
        // STORED ones rather than the review CSV's, per the ruling.
        //
        // The 21 rightly-refused rows are deliberately neither asserted nor trapped: a
        // correct refusal is not a property worth defending, per the 5 August law.
        out.add(a(EMERSON, MUST_APPEAR, 'poq1', 'AAO_POL_PS2',
            'Yeah, I think it will help to have the latest quote that I can include with legal. And then when it comes to InfoSec, there\'s a bit of a separate track there where we go to our compliance team where they will send out some',
            null,
            's1 graded True by Matthew, 5 August. Vargas, Jefferson [EMR/SYSS/AT/MEDI], offset 5634.'));
        out.add(a(EMERSON, MUST_APPEAR, 'seq6', 'AAO_PS_1',
            'it\'s helpful for you to send that material anyways, because it might help to, you know, answer some of those questions before they\'re asked',
            null,
            's1 graded True by Matthew, 5 August. Vargas, Jefferson [EMR/SYSS/AT/MEDI], offset 7071.'));
        out.add(a(EMERSON, MUST_APPEAR, 'poq7', 'AAO_POL_PS3',
            'I just want to make sure that if anything, I help support, right, Jeff, I work with on this one, Ryan, this is his first. So I just want to make sure that I\'m available to support.',
            null,
            's1 graded True by Matthew, 5 August. Neeraja Chimata, offset 10348. **STANDING ASSERTION THAT CURRENTLY FAILS AT VERIFICATION**: graded True and refused by call 3. Carried deliberately so the disagreement is a reported number rather than a memory. No wording change until the shape fails twice.'));
        out.add(a(EMERSON, MUST_APPEAR, 'seq2', 'AAO_PS_1',
            'I just want to make sure that if anything, I help support, right, Jeff, I work with on this one, Ryan, this is his first. So I just want to make sure that I\'m available to support.',
            null,
            's1 graded True by Matthew, 5 August. Neeraja Chimata, offset 10348. **STANDING ASSERTION THAT CURRENTLY FAILS AT VERIFICATION**: graded True and refused by call 3. Carried deliberately so the disagreement is a reported number rather than a memory. No wording change until the shape fails twice.'));
        out.add(a(EMERSON, MUST_APPEAR, 'buq3', 'AAO_BR_EVAL',
            'Is that tiers, tier priced? Wendy, is this the tier of like 0 to 600 and 600 and above?',
            null,
            's1 graded True by Matthew, 5 August. Neeraja Chimata, offset 13593.'));
        out.add(a(EMERSON, MUST_APPEAR, 'buq4', 'AAO_BR_EVAL',
            'the reason why I\'m asking is if we, let\'s say, go above 600, will that get us into a higher tier?',
            null,
            's1 graded True by Matthew, 5 August. Neeraja Chimata, offset 13768.'));
        out.add(a(EMERSON, MUST_APPEAR, 'deq1', 'AAO_DC_N',
            'And I think that the, you know, the total cost, the annual total is going to be the thing that gets the most amount of scrutiny when it comes to the approvals. And so I know that our internal approvers would be looking to see, you know, something that was',
            null,
            's1 graded True by Matthew, 5 August. Vargas, Jefferson [EMR/SYSS/AT/MEDI], offset 14315.'));
        out.add(a(EMERSON, MUST_APPEAR, 'deq2', 'AAO_DC_F',
            'And I think that the, you know, the total cost, the annual total is going to be the thing that gets the most amount of scrutiny when it comes to the approvals. And so I know that our internal approvers would be looking to see, you know, something that was',
            null,
            's1 graded True by Matthew, 5 August. Vargas, Jefferson [EMR/SYSS/AT/MEDI], offset 14315.'));
        out.add(a(EMERSON, MUST_APPEAR, 'buq2', 'AAO_BR_EVAL',
            'Is there anywhere else to go with this as far as the per user rate? Like, I mean, I appreciate the flexibility of the up to 600, but if we were to list it at 500, where would that put us?',
            null,
            's1 graded True by Matthew, 5 August. Vargas, Jefferson [EMR/SYSS/AT/MEDI], offset 14670.'));
        out.add(a(EMERSON, MUST_APPEAR, 'buq5', 'AAO_BR_EVAL',
            'Wendy is that when you say 10, is that 10 days worth like an 80 hours thing?',
            null,
            's1 graded True by Matthew, 5 August. Ryan Couture, offset 21368.'));
        out.add(a(EMERSON, MUST_APPEAR, 'buq6', 'AAO_BR_EVAL',
            'Yeah, okay, so that\'s 20 hours of that assistance. And then is there an option to do like a train the trainer type deal?',
            null,
            's1 graded True by Matthew, 5 August. Ryan Couture, offset 21812.'));
        out.add(a(EMERSON, MUST_APPEAR, 'buq8', 'AAO_BR_EVAL',
            'Is there like an end date for this? Or the reason why I\'m asking is, is there like an end date for the insight user, like training, for example, we get the 10 hours, but is there like an end date for that within like 3 months or six months or a year or?',
            null,
            's1 graded True by Matthew, 5 August. Neeraja Chimata, offset 24975.'));
        out.add(a(EMERSON, MUST_APPEAR, 'deq6', 'AAO_DC_N',
            'No, I don\'t. I feel like we got to be flexible about starting that at a later point, because from a change management perspective, the relationship map user training has to happen first',
            null,
            's1 graded True by Matthew, 5 August. Neeraja Chimata, offset 25394. Partial: accrues UNVERIFIED with receipts, places nobody, and projects nothing until later evidence completes the elements.'));
        out.add(a(EMERSON, MUST_APPEAR, 'buq7', 'AAO_BR_EVAL',
            'Can you kind of, you touched on it earlier. Can you give me a little bit more context on the reoccurring cost than the managed services one at the bottom?',
            null,
            's1 graded True by Matthew, 5 August. Vargas, Jefferson [EMR/SYSS/AT/MEDI], offset 29704.'));
        out.add(a(EMERSON, MUST_APPEAR, 'seq4', 'AAO_PS_1',
            'I want to make sure that we\'re presenting a compelling story to those approvers. You know, I\'m going to need the, you mentioned an SOW, would you be able to provide a draft SOW with all those line items?',
            null,
            's1 graded True by Matthew, 5 August. Vargas, Jefferson [EMR/SYSS/AT/MEDI], offset 31871.'));
        out.add(a(EMERSON, MUST_APPEAR, 'deq4', 'AAO_DC_F',
            'I\'ll take that on to the Emerson due diligence team just to see if they can take a look at those line items and see if they jive with what they would expect',
            null,
            's1 graded True by Matthew, 5 August. Vargas, Jefferson [EMR/SYSS/AT/MEDI], offset 32187. Partial: accrues UNVERIFIED with receipts, places nobody, and projects nothing until later evidence completes the elements.'));
        out.add(a(EMERSON, MUST_APPEAR, 'deq3', 'AAO_DC_N',
            'I\'ll take that on to the Emerson due diligence team just to see if they can take a look at those line items and see if they jive with what they would expect',
            null,
            's1 graded True by Matthew, 5 August. Vargas, Jefferson [EMR/SYSS/AT/MEDI], offset 32187. Partial: accrues UNVERIFIED with receipts, places nobody, and projects nothing until later evidence completes the elements.'));
        out.add(a(EMERSON, MUST_APPEAR, 'deq5', 'AAO_DC_N',
            'I don\'t want to introduce anything, especially on the Salesforce layer at this point of time without going through.',
            null,
            's1 graded True by Matthew, 5 August. Neeraja Chimata, offset 34748. Partial: accrues UNVERIFIED with receipts, places nobody, and projects nothing until later evidence completes the elements.'));

        // seq11 · the first courtesy read to survive v2.9's label fix. Ryan Couture,
        // "Looking forward to it." **Courtesy is not stance**, and §P8.4 already says so:
        // ENGAGEMENT IS NOT STANCE, and a warm sentence producing no pair is correct
        // behaviour. Matthew's ruling is that this must not reappear as an upheld
        // establishment; the charter does not move until the shape fails twice.
        out.add(a(EMERSON, MUST_NOT_APPEAR, 'trap-seq11-courtesy', 'AAO_PS_1',
            'I think we\'ll be working, we\'ll be working with, or together through this for the next couple of weeks or whatever through procurement. Looking forward to it.',
            null,
            'Graded a trap 5 August: courtesy is not stance. Call 3 UPHELD it, which is ' +
            'the serious half: the blind reader read positive anticipation as a supportive ' +
            'stance toward us and our solution.'));

        // ---- 24 JUNE · the five graded traps ----------------------------------------
        out.add(a(BV, MUST_NOT_APPEAR, 'trap-s1-over-ashley', 'AAO_PS_1',
            'we look at as many use cases as we can take on that are going to add value', null,
            'CLM-31, graded OVER, wrong-scope.'));
        out.add(a(BV, MUST_NOT_APPEAR, 'trap-s1-over-robbin', 'AAO_PS_1',
            'use your components that you guys to Altify design components', null,
            'CLM-35, graded OVER, wrong-scope.'));
        out.add(a(BV, MUST_NOT_APPEAR, 'trap-mentor-adam', 'AAO_PS_1',
            'I think this is a key step', null, 'Graded Neutral, no pair.'));
        out.add(a(BV, MUST_NOT_APPEAR, 'trap-mentor-robbin', 'AAO_PS_1',
            'Have you guys shared like any potential business cases', null,
            'Graded Neutral, no pair.'));
        out.add(a(BV, MUST_NOT_APPEAR, 'trap-mentor-ashley', 'AAO_PS_1',
            'I think we can do both', null, 'Graded Neutral, no pair.'));
        return out;
    }

    private static Assertion a(
        String fixture, String kind, String key, String code, String quote,
        String verdict, String why
    ) {
        Assertion x = new Assertion();
        x.fixture = fixture;
        x.kind = kind;
        x.key = key;
        x.contractCode = code;
        x.quote = quote;
        x.expectedVerdict = verdict;
        x.why = why;
        return x;
    }

    // ====================================================== the never-projected rule

    /**
     * WHICH OF THESE PAIRS REPRODUCE A GRADED TRAP, keyed pair id to trap key.
     *
     * **Addendum 17: a trap that reappears is REPORTED AND NEVER PROJECTED, and until now
     * only the first half was built.** The a21 run is the proof: `trap-seq11-courtesy` fired,
     * call 3 upheld it, the join wrote it as an ordinary `AAO_PS_1` claim, the counter moved
     * Ryan Couture to +1 and projection wrote Supporter onto his map row. The regression
     * report said the trap fired in the same run that put it on the map, which is a report
     * that watches a thing happen and calls it a finding.
     *
     * **The refusal lives at the join rather than at projection**, one stage earlier than the
     * word "projected" suggests, and deliberately: a claim is what moves the counter, and a
     * counter rebuilt from claims would reintroduce the trap on the next replay no matter
     * what projection refused. Refusing the claim is what makes the rule hold under replay.
     *
     * The pair still exists, still carries its call 3 verdict, and is still counted and
     * reported. **Nothing is deleted and no silence is written**: the ledger records that the
     * pass found this and that a standing grading refused it.
     */
    public static Map<Id, String> trapped(
        List<AAO_Pair__c> pairs, String artifact, String sha, String ref
    ) {
        Map<Id, String> out = new Map<Id, String>();
        if (pairs == null || pairs.isEmpty() || String.isBlank(artifact)) {
            return out;
        }
        for (Assertion x : assertions()) {
            if (x.kind != MUST_NOT_APPEAR || (x.fixture != sha && x.fixture != ref)) {
                continue;
            }
            List<Integer> want = AAO_RecallGate.ranges(artifact, x.quote);
            if (want.isEmpty()) {
                continue;
            }
            for (AAO_Pair__c p : pairs) {
                String code = p.AAO_Evidence_Contract__r == null
                    ? null
                    : p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
                if (!codeMatches(x.contractCode, code)) {
                    continue;
                }
                String words = p.AAO_Located_Pair__r == null
                    ? p.AAO_Answer_Text__c
                    : p.AAO_Located_Pair__r.AAO_Answer_Text__c;
                if (AAO_RecallGate.overlaps(artifact, want, words)) {
                    out.put(p.Id, x.key);
                }
            }
        }
        return out;
    }

    // ============================================================================ report

    public class Report {
        public String runKey;
        public Integer checked = 0;
        public Integer held = 0;
        /**
         * EVERY ASSERTION'S DISPOSITION, one line each. Owed twice and now built, because a
         * harness whose categories do not sum to its universe can silently drop assertions
         * and nobody reading the totals would know. The a20 report accounted 16 held plus 8
         * regressed of 27, which is three short even counting q13's CHANGED line.
         */
        public List<String> dispositions = new List<String>();
        /** Seeded against a different fixture, so outside this run's universe entirely. */
        public Integer notApplicable = 0;
        /** A graded PASS that this run lost. The line this class exists to print. */
        public List<String> regressions = new List<String>();
        /** A trap this run reproduced. */
        public List<String> trapsFired = new List<String>();
        /** A graded PASS found, but with a different call-3 verdict than the grading. */
        public List<String> verdictChanged = new List<String>();
        public List<String> missesStillMissed = new List<String>();
        public List<String> missesNowFound = new List<String>();
        public List<String> unreachable = new List<String>();
        /** Correct refusals whose status moved. Diagnostic only; never a pass or a fail. */
        public List<String> changedUndiagnosed = new List<String>();

        public Boolean clean() {
            return regressions.isEmpty() && trapsFired.isEmpty() && verdictChanged.isEmpty();
        }

        public override String toString() {
            List<String> o = new List<String>{
                'assertions in the seed   ' + (checked + notApplicable) + ' (unit: assertions)',
                '  other fixture, skipped ' + notApplicable + ' (unit: assertions)',
                'assertions checked       ' + checked + ' (unit: assertions)',
                '  held                   ' + held + ' (unit: assertions)',
                'REGRESSIONS              ' + regressions.size() + ' (unit: graded findings)',
                'traps reproduced         ' + trapsFired.size() + ' (unit: graded findings)',
                'verdicts changed         ' + verdictChanged.size() + ' (unit: graded findings)',
                'graded misses now found  ' + missesNowFound.size() + ' (unit: targets)',
                'graded misses still open ' + missesStillMissed.size() + ' (unit: targets)',
                'unreachable, undeclared  ' + unreachable.size() + ' (unit: targets)',
                'correct refusals moved   ' + changedUndiagnosed.size() +
                    ' (unit: findings, diagnostic only)',
                'REGRESSION SET           ' + (clean() ? 'HELD' : 'BROKEN')
            };
            // THE UNIVERSE CHECK, printed rather than assumed. If these disagree, an
            // assertion fell through every branch and the totals above are a lie of omission.
            o.add(
                'dispositions listed      ' + dispositions.size() + ' of ' + checked +
                ' (unit: assertions)' +
                (dispositions.size() == checked
                    ? ''
                    : '  ** UNACCOUNTED: ' + (checked - dispositions.size()) +
                      ' assertion(s) fell through every branch **')
            );
            for (String r : regressions) { o.add('  LOST      ' + r); }
            for (String r : trapsFired) { o.add('  TRAP      ' + r); }
            for (String r : verdictChanged) { o.add('  VERDICT   ' + r); }
            for (String r : missesNowFound) { o.add('  RECOVERED ' + r); }
            for (String r : missesStillMissed) { o.add('  still missed ' + r); }
            for (String r : changedUndiagnosed) { o.add('  CHANGED, undiagnosed  ' + r); }
            for (String r : unreachable) { o.add('  unreachable  ' + r); }
            o.add('');
            o.add('--- every assertion, one line ---');
            List<String> lines = new List<String>(dispositions);
            lines.sort();
            o.addAll(lines);
            return String.join(o, '\n');
        }
    }

    /**
     * Score one run. No model call, no callout: the spans are already recorded, and checking
     * them is arithmetic over bytes.
     */
    public static Report check(String runKey) {
        List<AAO_Pair__c> rows = [
            SELECT AAO_Answer_Text__c, AAO_Verification__c, AAO_Stage__c,
                AAO_Located_Pair__r.AAO_Answer_Text__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Source__r.AAO_SHA256__c, AAO_Source__r.AAO_Source_Ref__c,
                AAO_Source__r.AAO_Normalized_Text__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey
        ];
        if (rows.isEmpty()) {
            throw new RegressionException(
                'No pairs on run ' + runKey + '. There is nothing to check, which is not the ' +
                'same as nothing being wrong.'
            );
        }
        String sha = rows[0].AAO_Source__r.AAO_SHA256__c;
        String ref = rows[0].AAO_Source__r.AAO_Source_Ref__c;
        String artifact = rows[0].AAO_Source__r.AAO_Normalized_Text__c;

        Report rep = new Report();
        rep.runKey = runKey;
        for (Assertion x : assertions()) {
            // THE UNIVERSE IS EVERY ASSERTION, counted here rather than three branches down.
            // This is the accounting hole design's audit found: `checked` used to increment
            // only after the correct-refusal and unreachable branches had already `continue`d,
            // so a20's 27 assertions reported as 24 checked, and 16 held plus 8 regressed
            // summed correctly against a denominator nobody could see. The three that looked
            // unaccounted were the three unreachable ones, outside the count by construction.
            // NOT APPLICABLE TO THIS ARTIFACT IS ITS OWN DISPOSITION, and it is outside the
            // denominator rather than inside it. The seed spans two fixtures; a run against
            // one of them cannot hold or lose the other's assertions, and counting them would
            // make the universe a number that means nothing. Reported so the total is still
            // reconcilable to the seed's own size.
            if (x.fixture != sha && x.fixture != ref) {
                rep.notApplicable++;
                continue;
            }
            rep.checked++;
            if (x.kind == CORRECT_REFUSAL) {
                List<Integer> w = AAO_RecallGate.ranges(artifact, x.quote);
                Boolean found = false;
                for (AAO_Pair__c p : rows) {
                    String c = p.AAO_Evidence_Contract__r == null
                        ? null : p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
                    String words = p.AAO_Stage__c == AAO_PairKey.LOCATED
                        ? p.AAO_Answer_Text__c
                        : (p.AAO_Located_Pair__r == null ? null : p.AAO_Located_Pair__r.AAO_Answer_Text__c);
                    if (codeMatches(x.contractCode, c) &&
                        AAO_RecallGate.overlaps(artifact, w, words)) {
                        found = true;
                        break;
                    }
                }
                if (found) {
                    rep.dispositions.add(
                        'HELD       ' + x.key + ' [' + x.kind + '] refusal still made'
                    );
                } else {
                    rep.changedUndiagnosed.add(
                        x.key + ' [' + x.contractCode + '] no longer emitted. Not a loss: ' +
                        'the read stopped making a mistake. Undiagnosed because nothing here ' +
                        'distinguishes that from having stopped looking.'
                    );
                    rep.dispositions.add(
                        'CHANGED    ' + x.key + ' [' + x.kind + '] refusal no longer emitted'
                    );
                }
                continue;
            }
            if (x.kind == UNREACHABLE) {
                rep.unreachable.add(x.key + ' [' + x.contractCode + '] ' + x.why);
                rep.dispositions.add(
                    'UNREACHABLE ' + x.key + ' [' + x.kind + '] undeclared family'
                );
                continue;
            }
            List<Integer> want = AAO_RecallGate.ranges(artifact, x.quote);
            if (want.isEmpty()) {
                throw new RegressionException(
                    'Assertion ' + x.key + ' names words that are not in the artifact it is ' +
                    'keyed to. A target that cannot be located is a defect in the target.'
                );
            }
            AAO_Pair__c hit = null;
            for (AAO_Pair__c p : rows) {
                String code = p.AAO_Evidence_Contract__r == null
                    ? null
                    : p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
                if (!codeMatches(x.contractCode, code)) {
                    continue;
                }
                String words = p.AAO_Stage__c == AAO_PairKey.LOCATED
                    ? p.AAO_Answer_Text__c
                    : (p.AAO_Located_Pair__r == null ? null : p.AAO_Located_Pair__r.AAO_Answer_Text__c);
                if (AAO_RecallGate.overlaps(artifact, want, words)) {
                    hit = p;
                    if (p.AAO_Stage__c != AAO_PairKey.LOCATED) {
                        break;
                    }
                }
            }

            if (x.kind == MUST_NOT_APPEAR) {
                if (hit == null) {
                    rep.held++;
                    rep.dispositions.add('HELD       ' + x.key + ' [' + x.kind + '] trap absent');
                } else {
                    rep.trapsFired.add(x.key + ': ' + x.why);
                    rep.dispositions.add('TRAP       ' + x.key + ' [' + x.kind + '] reproduced');
                }
                continue;
            }
            if (x.kind == GRADED_MISS) {
                if (hit == null) {
                    rep.missesStillMissed.add(x.key + ' [' + x.contractCode + ']');
                    rep.dispositions.add(
                        'STILL MISSED ' + x.key + ' [' + x.kind + '] never found'
                    );
                } else {
                    rep.held++;
                    rep.missesNowFound.add(x.key + ' [' + x.contractCode + ']');
                    rep.dispositions.add(
                        'RECOVERED  ' + x.key + ' [' + x.kind + '] graded miss now found'
                    );
                }
                continue;
            }
            // MUST_APPEAR
            if (hit == null) {
                rep.regressions.add(x.key + ' [' + x.contractCode + '] ' + x.why);
                rep.dispositions.add('LOST       ' + x.key + ' [' + x.kind + '] not found');
                continue;
            }
            if (String.isNotBlank(x.expectedVerdict) &&
                String.isNotBlank(hit.AAO_Verification__c) &&
                hit.AAO_Verification__c != x.expectedVerdict) {
                rep.verdictChanged.add(
                    x.key + ': graded ' + x.expectedVerdict + ', this run ' +
                    hit.AAO_Verification__c
                );
                rep.dispositions.add(
                    'VERDICT    ' + x.key + ' [' + x.kind + '] ' + x.expectedVerdict +
                    ' -> ' + hit.AAO_Verification__c
                );
                continue;
            }
            rep.held++;
            rep.dispositions.add('HELD       ' + x.key + ' [' + x.kind + '] found as graded');
        }
        return rep;
    }

    private static Boolean codeMatches(String pattern, String code) {
        if (String.isBlank(code)) {
            return false;
        }
        return pattern.endsWith('*')
            ? code.startsWith(pattern.removeEnd('*'))
            : code == pattern;
    }
}
