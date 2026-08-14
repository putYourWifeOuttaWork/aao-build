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

    /**
     * PROJECT FARMA, 30 July NF1, and the first REAL PRODUCTION SPEECH in this seed. The
     * fixture is named by sha the way EMERSON is, because both check() and trapped() accept
     * either a sha or a Source_Ref and the sha is the thing the exports carry.
     */
    public static final String FARMA =
        '018cac1bb5a3425190678af890e7fc4a8794579353498c6ea67b18fd6690f7b6';

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

        // ---- 7 AUGUST · THE MAP READ GRADES ------------------------------------------
        //
        // Matthew read the map as a user and graded four things. Three of them are PASSes and
        // enter the standing set by the set's own law: every establishment he has graded PASS
        // is asserted on every run.
        //
        // **These are the first assertions seeded from a map read rather than from a review
        // CSV**, and they are worth more per row than the sweep grades: he graded the value he
        // would act on, at the surface he would act on it, after the writer had composed it.
        // Anything that moves them has changed what a seller sees.
        //
        // JEFFERSON AT MENTOR IS TRUE, so the over-read flag CODE raised on 6 August closes.
        // The +3 was the flag's whole worry - mentor-grade evidence crossing to the terminal
        // rung on one call - and his grade settles it: these are mentoring, and the counter's
        // arithmetic over them produces exactly his answer. Two quotes carry it.
        out.add(a(EMERSON, MUST_APPEAR, 'map-jefferson-mentor-approvers', 'AAO_PS_1',
            'I want to make sure that we\'re presenting a compelling story to those approvers.',
            null,
            'Graded MENTOR by Matthew at the map read, 7 August. Coaching us through his own ' +
            'organization\'s approval process, which is §P8.4\'s mentoring line exactly.'));
        out.add(a(EMERSON, MUST_APPEAR, 'map-jefferson-mentor-material', 'AAO_PS_1',
            'honestly, it\'s helpful for you to send that material anyways, because it might help to, you know, answer some of those questions before they\'re asked.',
            null,
            'Graded MENTOR by Matthew at the map read, 7 August. Telling us what his ' +
            'approvers need to see before they ask for it.'));

        // JEFFERSON'S POLITICAL STRUCTURE IS TRUE, and it SUPERSEDES the earlier agreement
        // specimen. §P8.9 recorded Jefferson at Outside Political Structure as a point of
        // agreement between design's read and Matthew's; the map read moves him inside it.
        // The earlier specimen is history rather than a standing assertion, so nothing is
        // retracted here - what changes is which reading the set now defends.
        //
        // Keyed on the bytes and NOT on the pair ref: `poq5` names Jefferson's PS2 on a20 and
        // Neeraja's OPS1 on a21, because refs are per-run and the set keys on contract plus
        // byte-range intersection for exactly this reason.
        out.add(a(EMERSON, MUST_APPEAR, 'map-jefferson-ps2-forward', 'AAO_POL_PS2',
            'So as long as I have the person, I\'ll make sure they have that and then they can forward that on.',
            null,
            'Graded True by Matthew at the map read, 7 August (a20 poq5, offset 7903). ' +
            'Brokering to the compliance team is Political Structure, and this supersedes ' +
            'the Outside Political Structure agreement specimen recorded at §P8.9.'));

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

        // ================================================ PROJECT FARMA · tg1 versus Pass 1
        //
        // THE THIRTY-EIGHTH STAMP'S FOLD, item 5(a): "fold the new grades into the regression
        // set per the standing sixth-check law, new graded PASSes as assertions keyed contract
        // plus byte range, the OVER rows as traps, the MIS specimen riding with its pair refs."
        //
        // Matthew graded all 83 establishment rows on 9 August against stored spans. The GRADE
        // column carries exactly two values, True (34) and False (49); PASS, OVER, MIS and
        // INTERNAL are all DERIVED by crossing the grade with the runs' call-3 verdicts, so the
        // partition is computed rather than read off a label. It is total and exhaustive:
        //   5 internal (our own seller, excluded from precision by construction)
        //  22 PASS            True and upheld by at least one run   -> MUST_APPEAR, below
        //   5 OVER            False and upheld by a run             -> MUST_NOT_APPEAR, below
        //   7 wrongly refused True but refused by every run         -> PARKED, see the note
        //   5 True, no call-3 verdict (merged or dropped)           -> not assertable
        //  36 correct refusals False and refused                    -> nothing to assert
        //   3 False, no call-3 verdict                              -> not assertable
        // 5+22+5+7+5+36+3 = 83.
        //
        // KEYS CARRY A pf- PREFIX AND THEIR GRADED ROW NUMBER, and that is not decoration. The
        // `key` namespace is global across the seed rather than scoped by fixture, and Project
        // Farma's Pass-1 run reuses the Emerson sweep's pair-ref naming: buq2, buq3, buq5, buq6,
        // buq7, buq8, deq2, deq6, poq1, seq2 and seq6 are all live Emerson keys already. Naming
        // these by bare pair ref would put two assertions on two different fixtures behind one
        // disposition line.

        out.add(a(FARMA, MUST_APPEAR, 'pf-r3-adam-pfeiffer-br_eval', 'AAO_BR_EVAL',
            'Just out of curiosity, the columns there, those are obviously ' +
            'configurable. Where do we pull those? Because we have basically 8 ' +
            'practice areas that are products within Salesforce.',
            'Upheld',
            'Graded PASS, row 3. Adam Pfeiffer, AAO_BR_EVAL, upheld by tg1 and ' +
            'graded True by Matthew. Offsets tg1 26297-26476. Matthew: "Evaluator ' +
            'should be overwriting user in this case. Not because it is later, but ' +
            'because almost all evaluators are also users."'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r4-adam-pfeiffer-br_eval', 'AAO_BR_EVAL',
            'how would your kind of, you know, over the top layering of Altify into' +
            ' our Salesforce instance, knowing that it\'s like broader than just ' +
            'Project Pharma?',
            'Upheld',
            'Graded PASS, row 4. Adam Pfeiffer, AAO_BR_EVAL, upheld by p1 and ' +
            'graded True by Matthew. Offsets p1 46193-46345.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r6-adam-pfeiffer-br_dm', 'AAO_BR_DM',
            'It\'s going to be us, our recommendation, and really just, it\'ll go to ' +
            'our president, Rich, and then ultimately there\'s going to be some sort' +
            ' of a approval required from the Perkerwicz and Elmer.',
            'Upheld',
            'Graded PASS, row 6. Adam Pfeiffer, AAO_BR_DM, upheld by p1 and graded ' +
            'True by Matthew. Offsets tg1 49882-50076 · p1 49882-50076.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r7-adam-pfeiffer-br_dm', 'AAO_BR_DM',
            'It\'s going to be us, our recommendation, and really just, it\'ll go to ' +
            'our president, Rich, and then ultimately there\'s going to be some sort' +
            ' of a approval required from the Perkerwicz and Elmer.',
            'Upheld',
            'Graded PASS, row 7. Adam Pfeiffer, AAO_BR_DM, upheld by tg1 and graded' +
            ' True by Matthew. Offsets tg1 49882-50076.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r12-adam-pfeiffer-br_eval', 'AAO_BR_EVAL',
            'how user-friendly is it for, you know, anybody of any computer skill ' +
            'level to go in and just sort of understand how that map gets built?',
            'Upheld',
            'Graded PASS, row 12. Adam Pfeiffer, AAO_BR_EVAL, upheld by tg1 and ' +
            'graded True by Matthew. Offsets tg1 52379-52515.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r24-adam-pfeiffer-dc_n', 'AAO_DC_N',
            'as long as it\'s bilateral, we can review it on our legal side and ' +
            'that\'s fine if you want to share yours.',
            'Upheld',
            'Graded PASS, row 24. Adam Pfeiffer, AAO_DC_N, upheld by p1 and graded ' +
            'True by Matthew. Offsets p1 63284-63389. Matthew: "Bilateral (what?)"'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r25-adam-pfeiffer-dc_n', 'AAO_DC_N',
            'if we were going to jump today, like you\'re the leader in the ' +
            'clubhouse for sure. But there\'s also pricing and other things that ' +
            'kind of make that contingent.',
            'Upheld',
            'Graded PASS, row 25. Adam Pfeiffer, AAO_DC_N, upheld by p1 and graded ' +
            'True by Matthew. Offsets tg1 65233-65391 · p1 65228-65391.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r26-adam-pfeiffer-dc_n', 'AAO_DC_N',
            'if we were going to jump today, like you\'re the leader in the ' +
            'clubhouse for sure. But there\'s also pricing and other things that ' +
            'kind of make that contingent.',
            'Upheld',
            'Graded PASS, row 26. Adam Pfeiffer, AAO_DC_N, upheld by tg1 and graded' +
            ' True by Matthew. Offsets tg1 65233-65391. Matthew: "But duplicating ' +
            'the “competitive pricing” so this criteria should be effected, “Budget' +
            ' Limits Held” or something."'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r34-adam-pfeiffer-pol_ps1', 'AAO_POL_PS1',
            'If, if, if we get there, I think this is this is our implementation ' +
            'team right here between Kalia and Dan and myself.',
            'Upheld',
            'Graded PASS, row 34. Adam Pfeiffer, AAO_POL_PS1, upheld by p1 and ' +
            'graded True by Matthew. Offsets tg1 49256-49373 · p1 49256-49466.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r35-adam-pfeiffer-pol_ps2', 'AAO_POL_PS2',
            'If, if, if we get there, I think this is this is our implementation ' +
            'team right here between Kalia and Dan and myself.',
            'Upheld',
            'Graded PASS, row 35. Adam Pfeiffer, AAO_POL_PS2, upheld by tg1 and ' +
            'graded True by Matthew. Offsets tg1 49256-49373 · p1 49256-49466.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r36-adam-pfeiffer-pol_ps1', 'AAO_POL_PS1',
            'If, if, if we get there, I think this is this is our implementation ' +
            'team right here between Kalia and Dan and myself.',
            'Upheld',
            'Graded PASS, row 36. Adam Pfeiffer, AAO_POL_PS1, upheld by tg1 and ' +
            'graded True by Matthew. Offsets tg1 49256-49373. Matthew: "Hate seeing' +
            ' 3…"'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r41-adam-pfeiffer-ps_1', 'AAO_PS_1',
            'So... I like that. So far, I mean, honestly, I like everything we\'ve ' +
            'seen so far.',
            'Upheld',
            'Graded PASS, row 41. Adam Pfeiffer, AAO_PS_1, upheld by tg1 and graded' +
            ' True by Matthew. Offsets tg1 45098-45179 · p1 45098-45179.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r47-adam-pfeiffer-ps_1', 'AAO_PS_1',
            'full transparency, like if we were going to jump today, like you\'re ' +
            'the leader in the clubhouse for sure. But there\'s also pricing and ' +
            'other things that kind of make that contingent.',
            'Upheld',
            'Graded PASS, row 47. Adam Pfeiffer, AAO_PS_1, upheld by tg1 and graded' +
            ' True by Matthew. Offsets tg1 65209-65391 · p1 65191-65314.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r50-dan-lewis-br_eval', 'AAO_BR_EVAL',
            'Would we have to have Agent Force enabled for this to work, or is this' +
            ' a separate add-on as well for your guys\' AI?',
            'Upheld',
            'Graded PASS, row 50. Dan Lewis, AAO_BR_EVAL, upheld by tg1 and graded ' +
            'True by Matthew. Offsets tg1 17299-17414.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r51-dan-lewis-br_eval', 'AAO_BR_EVAL',
            'Okay, is it an extra add-on to have the max AI ability or is that just' +
            ' included?',
            'Upheld',
            'Graded PASS, row 51. Dan Lewis, AAO_BR_EVAL, upheld by p1 and graded ' +
            'True by Matthew. Offsets tg1 19348-19428 · p1 19348-19428.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r52-dan-lewis-br_eval', 'AAO_BR_EVAL',
            'Okay, is it an extra add-on to have the max AI ability or is that just' +
            ' included?',
            'Upheld',
            'Graded PASS, row 52. Dan Lewis, AAO_BR_EVAL, upheld by tg1 and graded ' +
            'True by Matthew. Offsets tg1 19348-19428.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r53-dan-lewis-br_eval', 'AAO_BR_EVAL',
            'Okay, and the features are basically one-to-one, like whether you go ' +
            'with Max AI Agent Force or use our own Cloud API.',
            'Upheld',
            'Graded PASS, row 53. Dan Lewis, AAO_BR_EVAL, upheld by p1 and graded ' +
            'True by Matthew. Offsets p1 19613-19731. Matthew: "This is probably ' +
            'partial…but I accept"'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r55-dan-lewis-br_eval', 'AAO_BR_EVAL',
            'over the next couple of weeks and comparing what you guys offer to ' +
            'them and especially the pricing. I know we haven\'t got to that point, ' +
            'but I think it would be good to kind of go over the pricing model',
            'Upheld',
            'Graded PASS, row 55. Dan Lewis, AAO_BR_EVAL, upheld by tg1 and graded ' +
            'True by Matthew. Offsets tg1 51165-51367.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r71-kayla-stanley-br_eval', 'AAO_BR_EVAL',
            'A',
            'Upheld',
            'Graded PASS, row 71. Kayla Stanley, AAO_BR_EVAL, upheld by p1 and ' +
            'graded True by Matthew. Offsets p1 34110-34316.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r73-kayla-stanley-br_eval', 'AAO_BR_EVAL',
            'And these insight maps are visible to multiple users. It\'s not just ' +
            'like user specific.',
            'Upheld',
            'Graded PASS, row 73. Kayla Stanley, AAO_BR_EVAL, upheld by tg1 and ' +
            'graded True by Matthew. Offsets tg1 39512-39599.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r77-kayla-stanley-pol_ps2', 'AAO_POL_PS2',
            'I\'m sure we can get that turned on on our Salesforce side for tasks.',
            'Upheld',
            'Graded PASS, row 77. Kayla Stanley, AAO_POL_PS2, upheld by tg1 and ' +
            'graded True by Matthew. Offsets tg1 44575-44643 · p1 44571-44643.'));
        out.add(a(FARMA, MUST_APPEAR, 'pf-r82-rich-br_app', 'AAO_BR_APP',
            'ultimately upon the recommendation from us and Rich, like that\'s kind ' +
            'of just a formality, right?',
            'Upheld',
            'Graded PASS, row 82. Rich, AAO_BR_APP, upheld by tg1 and graded True ' +
            'by Matthew. Offsets tg1 50222-50319.'));


        out.add(a(FARMA, MUST_NOT_APPEAR, 'pf-trap-r13-adam-pfeiffer-br_app', 'AAO_BR_APP',
            'as long as it\'s bilateral, we can review it on our legal side and ' +
            'that\'s fine if you want to share yours.',
            null,
            'OVER, row 13. Adam Pfeiffer, AAO_BR_APP: a run upheld this and Matthew' +
            ' graded it False. Offsets tg1 63284-63389. Matthew: "Informing of a ' +
            'process, not claiming approval rights."'));
        out.add(a(FARMA, MUST_NOT_APPEAR, 'pf-trap-r20-adam-pfeiffer-dc_f', 'AAO_DC_F',
            'there\'s going to be some sort of a approval required from the ' +
            'Perkerwicz and Elmer. There\'s an advisory committee for kind of new ' +
            'platforms, especially those that leverage AI.',
            null,
            'OVER, row 20. Adam Pfeiffer, AAO_DC_F: a run upheld this and Matthew ' +
            'graded it False. Offsets p1 49993-50168. Matthew: "No criteria ' +
            'mentioned…"'));
        out.add(a(FARMA, MUST_NOT_APPEAR, 'pf-trap-r37-adam-pfeiffer-pol_ic3', 'AAO_POL_IC3',
            'It\'s going to be us, our recommendation, and really just, it\'ll go to ' +
            'our president, Rich, and then ultimately there\'s going to be some sort' +
            ' of a approval required from the Perkerwicz and Elmer.',
            null,
            'OVER, row 37. Adam Pfeiffer, AAO_POL_IC3: a run upheld this and ' +
            'Matthew graded it False. Offsets p1 49882-50076. Matthew: "Just ' +
            'because he knows the process doesn’t put in circle."'));
        out.add(a(FARMA, MUST_NOT_APPEAR, 'pf-trap-r63-dan-lewis-ps_1', 'AAO_PS_1',
            'So, so far, the feedback\'s been, from what I\'ve seen, has been pretty ' +
            'good. And so, yeah, we\'re starting, I guess, with the best from the ' +
            'rankings.',
            null,
            'OVER, row 63. Dan Lewis, AAO_PS_1: a run upheld this and Matthew ' +
            'graded it False. Offsets tg1 50944-51091 · p1 50917-51019. Matthew: ' +
            '"This is what feedback is, not his support."'));
        out.add(a(FARMA, MUST_NOT_APPEAR, 'pf-trap-r64-dan-lewis-ps_1', 'AAO_PS_1',
            'we\'ll be looking at other options',
            null,
            'OVER, row 64. Dan Lewis, AAO_PS_1: a run upheld this and Matthew ' +
            'graded it False. Offsets p1 51100-51133. Matthew: "This is actually a ' +
            'supportive motion, telling us what we need to know to win, not telling' +
            ' us he prefers other solutions…"'));

        // ---- PARKED, not built: the 7 wrongly-refused rows (1, 2, 16, 18, 38, 61, 72) -------
        //
        // These are graded True and refused by every run that verified them, so they are the
        // most valuable regression content here: each one is an establishment the machine lost.
        // They are NOT built, and the reason is the receipt rule. Item 5(a) names three things
        // to fold, "graded PASSes", "the OVER rows", and "the MIS specimen", and a wrongly
        // refused row is none of the three. The precedent for carrying them exists in this very
        // class (poq7 and seq2 ride as MUST_APPEAR with expectedVerdict 'Upheld' for exactly
        // this reason), so this is one ruling away from shipping, and it is design's ruling and
        // not CODE's. Named here with their rows so the next stamp can say yes in one line.

        // ---- THE MIS SPECIMEN, rows 61 and 62, riding with its pair refs -------------------
        //
        // THE FIRST GRADED MIS ON THE TWO-READ SHAPE, and it is an ATTRIBUTION error, not a
        // location error. Both rows carry THE SAME WORDS and THE SAME CONTRACT:
        //   quote  "I was just kind of curious on how much of A lift it's going to be for
        //           Kayla to get approval from Perkerwicz and Elmer"
        //   code   AAO_POL_PS2
        //   refs   tg1 61110-61227 · p1 61110-61260
        //   row 61 graded TRUE,  Matthew: "True for KAYLA not for Dan."
        //   row 62 graded FALSE, Matthew: "False for dan"
        // tg1 attributed to Dan Lewis what Pass 1 attributed to Kayla Stanley.
        //
        // IT IS DELIBERATELY NOT ENCODED AS AN ASSERTION, and the reason is a real limit worth
        // recording: `Assertion` keys on fixture, contract code and byte range, and carries NO
        // SUBJECT. A MUST_NOT_APPEAR on these bytes would fire on the CORRECT Kayla reading just
        // as hard as on the wrong Dan one, because nothing in the match can tell them apart. So
        // the specimen rides here with its refs, as the stamp words it, and the structural gap
        // (the regression set cannot express a per-person grade) is reported for design rather
        // than papered over with a trap that would manufacture false positives.

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
                // THE LINE THIS BRANCH ALWAYS OWED AND NEVER WROTE, found by the first run
                // against a fixture the seed does not cover. The comment above already said
                // not-applicable is its own disposition; the counter was written and the
                // disposition line was not, so a run outside the seed's fixtures produced a
                // universe of 39 and a disposition list of ZERO. Every other run to date hid
                // it, because every other run was against a fixture the seed does cover.
                //
                // An empty list is unfalsifiable in the direction that matters: it reads the
                // same whether the harness accounted for every assertion or skipped them all.
                // The line names the fixture the assertion is keyed to, so a reader can see
                // WHY it is out of the denominator rather than trusting that it should be.
                rep.dispositions.add(
                    'N/A        ' + x.key + ' [' + x.kind + '] keyed to ' +
                    (x.fixture.length() == 64 ? x.fixture.substring(0, 8) : x.fixture) +
                    ', not this artifact'
                );
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