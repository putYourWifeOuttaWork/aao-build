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

    // ============================================================================ report

    public class Report {
        public String runKey;
        public Integer checked = 0;
        public Integer held = 0;
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
            for (String r : regressions) { o.add('  LOST      ' + r); }
            for (String r : trapsFired) { o.add('  TRAP      ' + r); }
            for (String r : verdictChanged) { o.add('  VERDICT   ' + r); }
            for (String r : missesNowFound) { o.add('  RECOVERED ' + r); }
            for (String r : missesStillMissed) { o.add('  still missed ' + r); }
            for (String r : changedUndiagnosed) { o.add('  CHANGED, undiagnosed  ' + r); }
            for (String r : unreachable) { o.add('  unreachable  ' + r); }
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
            if (x.fixture != sha && x.fixture != ref) {
                continue;
            }
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
                if (!found) {
                    rep.changedUndiagnosed.add(
                        x.key + ' [' + x.contractCode + '] no longer emitted. Not a loss: ' +
                        'the read stopped making a mistake. Undiagnosed because nothing here ' +
                        'distinguishes that from having stopped looking.'
                    );
                }
                continue;
            }
            if (x.kind == UNREACHABLE) {
                rep.unreachable.add(x.key + ' [' + x.contractCode + '] ' + x.why);
                continue;
            }
            rep.checked++;
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
                if (hit == null) { rep.held++; } else { rep.trapsFired.add(x.key + ': ' + x.why); }
                continue;
            }
            if (x.kind == GRADED_MISS) {
                if (hit == null) {
                    rep.missesStillMissed.add(x.key + ' [' + x.contractCode + ']');
                } else {
                    rep.held++;
                    rep.missesNowFound.add(x.key + ' [' + x.contractCode + ']');
                }
                continue;
            }
            // MUST_APPEAR
            if (hit == null) {
                rep.regressions.add(x.key + ' [' + x.contractCode + '] ' + x.why);
                continue;
            }
            if (String.isNotBlank(x.expectedVerdict) &&
                String.isNotBlank(hit.AAO_Verification__c) &&
                hit.AAO_Verification__c != x.expectedVerdict) {
                rep.verdictChanged.add(
                    x.key + ': graded ' + x.expectedVerdict + ', this run ' +
                    hit.AAO_Verification__c
                );
                continue;
            }
            rep.held++;
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
