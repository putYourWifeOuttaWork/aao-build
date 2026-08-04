/**
 * THE RECALL GATE (§P8.0). Before anything downstream is trusted, call 1 runs against the
 * 24 June B&V fixture and has to find the words Matthew's grading says are there.
 *
 * The gate exists because the shape that failed before was a whole-transcript read, and
 * call 1 is a whole-transcript read. It is load-bearing, not a formality.
 *
 * WHY IT IS AIMED AT RECALL AND NOT PRECISION. An over-read is caught: call 3 rejects it and
 * the rejection is counted and reported. An under-read is caught by nothing — it leaves no
 * row, no counter and no trace, and becomes silence that looks like an answer. The gate is
 * the only instrument this build has that points at the invisible failure.
 *
 * ------------------------------------------------------------------------------------
 * A FINDING THAT CAME OUT OF BUILDING IT, and it changes the target set §P8.0 specifies.
 *
 * §P8.0 says "a pair must exist for the words behind each graded PASS". Mapping the four
 * graded PASS answers onto the seventeen §P8 contracts:
 *
 *   PS7/Adam   "collect and provide information to people of power and influence"
 *                                                    -> survives as AAO_POL_OPS1, verbatim
 *   PO9/Ashley "Is this person aware of the politics in the organisation?"  -> NO HOME
 *   PO9/Adam   same question                                                -> NO HOME
 *   one of the three S1 rows                          -> sentiment, AAO_PS_1, WHICH IS OWED
 *
 * **Two of the four graded PASS spans are on the one question §P8 deliberately does not
 * declare.** PO9 is the political-awareness question, retired for placing nobody and being
 * true of everyone worth mapping — the same two faults that retired S1. So the gate cannot
 * require a pair for those words, and their absence is the design working rather than a
 * recall failure.
 *
 * That is worth more than a note. The findings=1 structural explanation was "the read
 * establishes gate questions that place nobody and misses placement questions", and here it
 * is again from the other side: **half the graded PASSES were on a question that places
 * nobody.** The gate's own target set is evidence for the retirement.
 * ------------------------------------------------------------------------------------
 *
 * THE THREE ASKS, ANSWERED FROM THE ADJUDICATION SHEET (CODE addendum 07, 5 August). They
 * were carried here as OWED rather than left out, because a gate that silently omits the
 * targets it does not know about reports a clean pass over a smaller test.
 *
 * - **The fourth PASS is Adam's S1** (CLM-34), span *"what I'm trying to do is just
 *   eliminate clicks"*. That is the SAME SPAN as the canonical criterion target, and
 *   Matthew's 4 August ruling makes it the decision criterion Adam should carry. So the
 *   answer MERGES into an existing target rather than adding one, and the answerable count
 *   does not grow. Recorded because a resolved ask that quietly changes no number looks
 *   like an omission otherwise.
 * - **The two OVERs are Ashley's (CLM-31) and Robbin's (CLM-35)**, both `wrong-scope`: a
 *   process description and an implementation instruction, neither carrying preference.
 *   They are must-not-reproduce targets now, so the reported zero stops being vacuous.
 * - **The S2/Adam words do not exist anywhere.** The sheet recorded that UNDER with NO
 *   SPAN, from deal knowledge rather than a graded quote. Ruled: a gate target must be
 *   transcript-grounded, and a read cannot be failed for missing what the frozen bytes do
 *   not carry. The target is WITHDRAWN, kept visible with its reason, pending Matthew
 *   locating the words or ruling them absent.
 *
 * PO9 IS EXCLUDED BY RULING NOW, not by my inference. Two of the four graded PASSES sit on
 * the political-awareness question v2.8 deliberately does not declare; their absence is the
 * design working, the gate cannot require them, and the finding is further evidence for the
 * retirement.
 */
public with sharing class AAO_RecallGate {
    public class GateException extends Exception {
    }

    /** The 24 June B&V fixture, NF1 form. */
    public static final String FIXTURE_REF = 'bv/biweekly-2026-06-24-nf1';

    /**
     * One thing the read must find, or must not.
     *
     * `quote` is the words as they stand in the artifact. `questionCode` is where they
     * should land under the §P8 set. A target with a null quote is OWED: declared, named,
     * and not yet answerable.
     */
    public class Target {
        public String key;
        public String questionCode;
        public String quote;
        public String why;
        /** True where a pair reproducing this is the failure, rather than its absence. */
        public Boolean mustNotReproduce = false;
        /**
         * Declared, kept visible, and not scored. A withdrawn target is one the grading
         * cannot ground in the artifact, which is a fact about the target rather than about
         * the read. Deleting it would erase the reason it was ever expected.
         */
        public Boolean withdrawn = false;

        public Boolean isOwed() {
            return !withdrawn && String.isBlank(quote);
        }
    }

    public static List<Target> targets() {
        List<Target> out = new List<Target>();

        out.add(t(
            'PS7-broker',
            'AAO_POL_OPS1',
            'That needs to go to Scott and Matt and Brian. Like that\'s Matt, that was a ' +
            'very specific ask from Matt last week. So I just want to make sure we keep ' +
            'that moving.',
            'Graded PASS on the old PS7 (CLM-33, Adam), whose text survives byte-exact as ' +
            'AAO_POL_OPS1. The clearest surviving PASS-to-contract mapping in the set.'
        ));

        out.add(t(
            'canonical-criterion',
            'AAO_DC_N',
            'what I\'m trying to do is just eliminate clicks',
            'TWO GRADES LAND ON THIS ONE SPAN. It is the canonical informal criterion named ' +
            'in charters v2.5 as the case this build produced and missed by declaration, AND ' +
            'it is CLM-34, Adam\'s S1, the fourth graded PASS — the one that passed where ' +
            'design predicted failure. The distinction Matthew\'s grades drew is the durable ' +
            'one: a person stating what he himself wants establishes; describing a process ' +
            'or directing an implementation does not. Under §P8 it is a criterion naming, ' +
            'per his 4 August ruling, so both grades score as one target.'
        ));

        // ---- MUST NOT REPRODUCE. Both graded OVER, both wrong-scope. -------------------
        //
        // Scored against AAO_PS_1 because S1 is retired from extraction and sentiment is
        // where a preference claim would now land. Where these words come back under some
        // OTHER contract the run reports it as an observation rather than a failure: "use
        // your components" may honestly be evaluating behaviour, and calling that a
        // reproduction would punish the read for a reading the grading never judged.
        out.add(over(
            'S1-over-ashley',
            'we look at as many use cases as we can take on that are going to add value',
            'CLM-31, Ashley Stroud, graded OVER, wrong-scope: a process description that ' +
            'carries no preference for any solution.'
        ));
        out.add(over(
            'S1-over-robbin',
            'use your components that you guys to Altify design components',
            'CLM-35, Robbin Jones, graded OVER, wrong-scope: an implementation instruction ' +
            'that carries no preference for any solution.'
        ));


        // ---- THE SECOND JOINT GRADING'S TRAPS (CODE addendum 08, 5 August). ------------
        //
        // The 24 June gate's own three MENTOR reads, all graded **Neutral — no pair**. They
        // join the two S1 over-reads, so five rows the re-run must not reproduce.
        //
        // THE CORRECT OUTPUT FOR ALL THREE IS ABSENCE. That is worth saying plainly, because
        // every other entry in this list is scored on presence and the asymmetry is the whole
        // point of §P8.4's new sentence: emitting no pair on a warm sentence is CORRECT
        // BEHAVIOUR, not under-reading. These are the specimens that make it checkable.
        out.add(over(
            'MENTOR-trap-adam',
            'Yeah, I think this is a key step. Yeah, I think this is a key step, right, of ' +
            'like, we have to understand what the MCP does with the newest upgrade',
            'Graded Neutral by Matthew: "not guiding or providing sentiment but noting the ' +
            'need for understanding what the new MCP does." The canonical "key step" case ' +
            '§P8.4 now names by hand.'
        ));
        out.add(over(
            'MENTOR-trap-robbin',
            'I just have one question, Renee. Have you guys shared like any potential ' +
            'business cases, knowing BV that maybe we haven\'t thought of, that might be a ' +
            'good option to add onto the list for the stakeholders to kind of review',
            'Graded Neutral by Matthew: "asking a question which could lead to better ' +
            'success... not without further coexistent context." A question is engagement, ' +
            'and engagement is not stance.'
        ));
        out.add(over(
            'MENTOR-trap-ashley',
            'Yeah, and I think I hear you. I think we can do both. You know, I think I think ' +
            'we have to do we have to do a tier one scorecard, but we also can use we can use ' +
            'MCP to accelerate inputs.',
            'Graded Neutral by Matthew: "stating what can happen in a neutral way." Sits ' +
            'beside CLM-31, the S1 over-read on the same speaker, with the same objection.'
        ));

        // ---- WITHDRAWN. Kept visible; the reason is the point. ------------------------
        Target s2 = t(
            'S2-adam-placement',
            'AAO_PS_1',
            null,
            'WITHDRAWN 5 August. The first recorded UNDER, S2 for Adam Meloan, was recorded ' +
            'in the sheet WITH NO SPAN: it came from Matthew\'s read of the output against ' +
            'his knowledge of the call, which is deal knowledge rather than a graded quote. ' +
            'Nobody has ever named Adam\'s supporter words in the 24 June transcript and it ' +
            'is possible none exist. A gate target must be transcript-grounded, and a read ' +
            'cannot be failed for missing what the frozen bytes do not carry. Reinstated at ' +
            'AAO_PS_1/SUPPORTER if the words are located; if ruled absent, the UNDER ' +
            're-classifies from model_missed to out-of-set deal knowledge and this target ' +
            'stays here as the record of why it was ever expected.'
        );
        s2.withdrawn = true;
        out.add(s2);

        return out;
    }

    private static Target t(String key, String code, String quote, String why) {
        Target x = new Target();
        x.key = key;
        x.questionCode = code;
        x.quote = quote;
        x.why = why;
        return x;
    }

    private static Target over(String key, String quote, String why) {
        Target x = t(key, 'AAO_PS_1', quote, why);
        x.mustNotReproduce = true;
        return x;
    }

    private static Target owed(String key, String code, String why) {
        Target x = new Target();
        x.key = key;
        x.questionCode = code;
        x.why = why;
        return x;
    }

    // ============================================================================ result

    public class Coverage {
        public Integer targetsDeclared = 0;
        /** Targets that must be FOUND. Must-not-reproduce targets are counted separately
         * below, because a coverage ratio that mixes them can never reach one and would
         * report a permanent failure that means nothing. */
        public Integer targetsAnswerable = 0;
        public Integer exclusionsChecked = 0;
        public Integer targetsCovered = 0;
        public Integer targetsOwed = 0;
        /** Missed because the words are nowhere in the pairs. A recall failure. */
        public Integer notFound = 0;
        /** Missed because the words landed on a different contract. A routing failure. */
        public Integer routedElsewhere = 0;
        /** Declared, not scored, kept visible. Never counted as covered or missed. */
        public Integer targetsWithdrawn = 0;
        public List<String> covered = new List<String>();
        public List<String> missed = new List<String>();
        public List<String> owed = new List<String>();
        public List<String> reproduced = new List<String>();
        /**
         * An over-read's words coming back under a DIFFERENT contract. Reported, never
         * failed: the grading judged those words against one proposition and said nothing
         * about any other, so calling this a reproduction would punish a reading nobody
         * graded. It is the line to put in front of Matthew, not a verdict.
         */
        public List<String> overReadWordsElsewhere = new List<String>();
        public List<String> withdrawn = new List<String>();

        /**
         * A gate that passes while a target is owed is a gate over a smaller test. There is
         * no argument that gets around this and it is deliberately not overridable.
         */
        public Boolean passed() {
            return targetsOwed == 0 &&
                targetsCovered == targetsAnswerable &&
                reproduced.isEmpty();
        }

        public override String toString() {
            List<String> out = new List<String>{
                'targets covered          ' + targetsCovered + '/' + targetsAnswerable +
                    ' (unit: targets)',
                'targets owed             ' + targetsOwed + ' (unit: targets)',
                '  missed, not found      ' + notFound + ' (unit: targets)',
                '  missed, routed away    ' + routedElsewhere + ' (unit: targets)',
                'exclusions checked       ' + exclusionsChecked + ' (unit: targets)',
                'over-reads reproduced    ' + reproduced.size() + ' (unit: targets)',
                'over-read words elsewhere ' + overReadWordsElsewhere.size() +
                    ' (unit: targets, reported not failed)',
                'targets withdrawn        ' + targetsWithdrawn + ' (unit: targets)',
                'GATE                     ' + (passed() ? 'PASSED' : 'NOT PASSED')
            };
            for (String c : covered) {
                out.add('  covered  ' + c);
            }
            for (String m : missed) {
                out.add('  MISSED   ' + m);
            }
            for (String o : owed) {
                out.add('  OWED     ' + o);
            }
            for (String r : reproduced) {
                out.add('  REPRODUCED ' + r);
            }
            for (String e : overReadWordsElsewhere) {
                out.add('  NOTE     ' + e);
            }
            for (String w : withdrawn) {
                out.add('  WITHDRAWN ' + w);
            }
            return String.join(out, '\n');
        }
    }

    /**
     * Score a set of located pairs against the targets.
     *
     * MATCHING IS BYTE-RANGE OVERLAP IN THE ARTIFACT, not string comparison. Call 1 chooses
     * its own coextensive boundary and a target quote taken from a graded answer will
     * rarely share it, so equality is far too strict. String containment is too strict too,
     * and this gate proved it on its own first run: the target quote and the located quote
     * shared thirty-nine characters of the same sentence, neither contained the other, and
     * the report said NOT FOUND AT ALL about words the read had plainly found. That is a
     * gate lying in the direction of alarm, which is still a gate lying.
     *
     * Both quotes are located in the frozen artifact and the ranges are intersected. It is
     * the same byte truth every other layer here uses, and it has no opinion about where a
     * sentence ends.
     *
     * The question code MUST match. A target found under the wrong contract is not found:
     * "eliminate clicks" landing on sentiment instead of criteria is exactly the miss the
     * criteria family was declared to fix.
     */
    public static Coverage score(List<AAO_Pair__c> located) {
        return score(located, fixture().AAO_Normalized_Text__c);
    }

    public static Coverage score(List<AAO_Pair__c> located, String artifact) {
        Coverage c = new Coverage();
        for (Target tg : targets()) {
            c.targetsDeclared++;
            if (tg.withdrawn) {
                c.targetsWithdrawn++;
                c.withdrawn.add(tg.key + ' [' + tg.questionCode + '] ' + tg.why);
                continue;
            }
            if (tg.isOwed()) {
                c.targetsOwed++;
                c.owed.add(tg.key + ' [' + tg.questionCode + '] ' + tg.why);
                continue;
            }
            if (tg.mustNotReproduce) {
                c.exclusionsChecked++;
            } else {
                c.targetsAnswerable++;
            }

            List<Integer> want = ranges(artifact, tg.quote);
            Boolean hit = false;
            for (AAO_Pair__c p : located) {
                if (p.AAO_Evidence_Contract__r == null ||
                    p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c != tg.questionCode) {
                    continue;
                }
                if (overlaps(artifact, want, p.AAO_Answer_Text__c)) {
                    hit = true;
                    break;
                }
            }

            if (tg.mustNotReproduce) {
                if (hit) {
                    c.reproduced.add(tg.key + ' as ' + tg.questionCode + ': ' +
                        tg.quote.abbreviate(60));
                    continue;
                }
                for (AAO_Pair__c p : located) {
                    if (p.AAO_Evidence_Contract__r != null &&
                        overlaps(artifact, want, p.AAO_Answer_Text__c)) {
                        c.overReadWordsElsewhere.add(
                            tg.key + ' came back as ' +
                            p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c +
                            ' (graded OVER on the old S1, ungraded here): "' +
                            tg.quote.abbreviate(50) + '"'
                        );
                        break;
                    }
                }
                continue;
            }
            if (hit) {
                c.targetsCovered++;
                c.covered.add(tg.key + ' [' + tg.questionCode + ']');
                continue;
            }

            // A MISS IS TWO DIFFERENT FAILURES AND THE GATE MUST SAY WHICH.
            //
            // Not found at all is a recall failure, which is what this gate exists to
            // catch. Found under a different contract is a ROUTING disagreement: the read
            // saw the words and answered a different one-way question with them. Both fail
            // the target, and they call for opposite fixes — the first is a coverage
            // problem in call 1, the second is a wording problem in two contracts that
            // compete for the same sentence. Reporting them as one number would send the
            // next session to the wrong repair.
            String elsewhere = null;
            for (AAO_Pair__c p : located) {
                if (p.AAO_Evidence_Contract__r != null &&
                    overlaps(artifact, want, p.AAO_Answer_Text__c)) {
                    elsewhere = p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
                    break;
                }
            }
            if (elsewhere == null) {
                c.notFound++;
                c.missed.add(
                    tg.key + ' [' + tg.questionCode + '] NOT FOUND AT ALL "' +
                    tg.quote.abbreviate(60) + '"'
                );
            } else {
                c.routedElsewhere++;
                c.missed.add(
                    tg.key + ' [' + tg.questionCode + '] FOUND, FILED UNDER ' + elsewhere +
                    ' "' + tg.quote.abbreviate(60) + '"'
                );
            }
        }
        return c;
    }

    /** Start and end offsets of every occurrence of `quote`, flattened as [s,e,s,e,...]. */
    public static List<Integer> ranges(String artifact, String quote) {
        List<Integer> out = new List<Integer>();
        if (String.isBlank(artifact) || String.isBlank(quote)) {
            return out;
        }
        Integer at = artifact.indexOf(quote);
        while (at >= 0) {
            out.add(at);
            out.add(at + quote.length());
            at = artifact.indexOf(quote, at + quote.length());
        }
        return out;
    }

    /**
     * True where the found quote's range intersects any of the target's ranges.
     *
     * A target quote that is nowhere in the artifact intersects nothing and reports as not
     * found, which is correct and is also a signal about the TARGET rather than the read.
     */
    public static Boolean overlaps(String artifact, List<Integer> want, String found) {
        if (want.isEmpty() || String.isBlank(found)) {
            return false;
        }
        List<Integer> got = ranges(artifact, found);
        for (Integer i = 0; i < want.size(); i += 2) {
            for (Integer j = 0; j < got.size(); j += 2) {
                if (want[i] < got[j + 1] && got[j] < want[i + 1]) {
                    return true;
                }
            }
        }
        return false;
    }

    // =============================================================================== run

    public class RunResult {
        public AAO_Extract.StageResult call;
        public AAO_LocateCharter.Result parsed;
        public AAO_Locate.Located located;
        public Coverage coverage;
        public String runKey;
    }

    /**
     * One call 1 against the fixture, byte-located, scored. Writes the pairs, because the
     * gate is a real run of the real path and a gate over a mock proves nothing about the
     * path that ships.
     */
    public static RunResult run(String runKey) {
        AAO_Source__c src = fixture();
        List<AAO_Evidence_Contract__c> declared = declaredSet();
        List<String> codes = new List<String>();
        Map<String, Id> idByCode = new Map<String, Id>();
        for (AAO_Evidence_Contract__c ec : declared) {
            codes.add(ec.AAO_Proposition_Code__c);
            idByCode.put(ec.AAO_Proposition_Code__c, ec.Id);
        }

        AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
        spec.stage = 'call1_locate';
        spec.charter = 'AAO_LocateCharter';
        spec.charterVersion = AAO_LocateCharter.effectiveVersion(declared);

        RunResult r = new RunResult();
        r.runKey = runKey;
        r.call = AAO_Extract.callStage(
            spec,
            AAO_LocateCharter.systemPrompt(),
            new List<String>{
                AAO_LocateCharter.rubricBlock(declared),
                '# The transcript\n\n' + src.AAO_Normalized_Text__c
            },
            AAO_LocateCharter.schema(codes)
        );
        r.parsed = AAO_LocateCharter.parse(r.call.rawText, codes);
        r.located = AAO_Locate.locate(
            src, r.parsed.pairs, runKey, spec.charterVersion, idByCode
        );
        AAO_Locate.write(r.located);

        r.coverage = score(
            [
            SELECT Id, AAO_Answer_Text__c, AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.LOCATED
            ],
            src.AAO_Normalized_Text__c
        );
        return r;
    }

    public static AAO_Source__c fixture() {
        List<AAO_Source__c> rows = [
            SELECT Id, AAO_Normalized_Text__c, AAO_Diarization__c, AAO_SHA256__c,
                AAO_Source_Ref__c
            FROM AAO_Source__c
            WHERE AAO_Source_Ref__c = :FIXTURE_REF
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (rows.isEmpty()) {
            throw new GateException(
                'The recall-gate fixture ' + FIXTURE_REF + ' is not in this org. The gate ' +
                'runs against the 24 June B&V artifact and nothing else: it is scored ' +
                'against grades that were given on that call.'
            );
        }
        return rows[0];
    }

    public static List<AAO_Evidence_Contract__c> declaredSet() {
        List<AAO_Evidence_Contract__c> rows = [
            SELECT Id, AAO_Proposition_Code__c, AAO_Proposition_Text__c,
                AAO_Guidance_Text__c, AAO_Element_Count__c, AAO_Contract_Key__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Rubric_Version__c = :AAO_PassContracts.RUBRIC_VERSION
                AND AAO_Contract_State__c != 'Superseded'
        ];
        if (rows.isEmpty()) {
            throw new GateException(
                'No live contracts on ' + AAO_PassContracts.RUBRIC_VERSION +
                '. Mint them before running the gate; a read against an empty declared set ' +
                'measures nothing.'
            );
        }
        return rows;
    }
}
