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
 * WHAT IS OWED, AND WHY THIS GATE CANNOT REPORT A PASS UNTIL IT ARRIVES. Two targets and
 * both over-read exclusions depend on grades that live in the adjudication sheet rather
 * than in this repo. They are declared here UNRESOLVED. A gate that silently omitted the
 * targets it did not know about would report a clean pass over a smaller test, which is the
 * precise shape of the mistake this whole build exists to refuse.
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

        public Boolean isOwed() {
            return String.isBlank(quote);
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
            'Graded PASS on the old PS7, whose text survives byte-exact as AAO_POL_OPS1. ' +
            'The clearest surviving PASS-to-contract mapping in the set.'
        ));

        out.add(t(
            'canonical-criterion',
            'AAO_DC_N',
            'what I\'m trying to do is just eliminate clicks',
            'THE canonical informal criterion, named in charters v2.5 as the case this build ' +
            'produced and missed by declaration. The old run extracted it as S1, a support ' +
            'question; under §P8 it is a criterion naming. If call 1 files it as sentiment ' +
            'again, the criteria family is still invisible.'
        ));

        // ---- OWED. Declared unresolved rather than quietly left out. ------------------
        out.add(owed(
            'S2-adam-placement',
            'AAO_PS_1',
            'THE FIRST RECORDED UNDER: S2 for Adam Meloan, the only Support question with ' +
            'placement power, never surfaced by the read. Because it was never surfaced, ' +
            'the words are nowhere in this org — only Matthew\'s grading names them. Needed: ' +
            'the verbatim words he would point at. Expected meaning SUPPORTER.'
        ));
        out.add(owed(
            'S1-fourth-pass',
            'AAO_PS_1',
            'Three S1 answers exist and the sheet grades two of them OVER, so one is the ' +
            'fourth PASS. Needed: which of the three, by person (Ashley, Adam or Robbin).'
        ));

        Target over = owed(
            'S1-over-reads',
            'AAO_PS_1',
            'The two graded OVER answers, both wrong-scope, both S1. The same run must ' +
            'assert no pair reproduces them. Needed: which two of the three S1 rows.'
        );
        over.mustNotReproduce = true;
        out.add(over);

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
        public Integer targetsAnswerable = 0;
        public Integer targetsCovered = 0;
        public Integer targetsOwed = 0;
        /** Missed because the words are nowhere in the pairs. A recall failure. */
        public Integer notFound = 0;
        /** Missed because the words landed on a different contract. A routing failure. */
        public Integer routedElsewhere = 0;
        public List<String> covered = new List<String>();
        public List<String> missed = new List<String>();
        public List<String> owed = new List<String>();
        public List<String> reproduced = new List<String>();

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
                'over-reads reproduced    ' + reproduced.size() + ' (unit: pairs)',
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
            if (tg.isOwed()) {
                c.targetsOwed++;
                c.owed.add(tg.key + ' [' + tg.questionCode + '] ' + tg.why);
                continue;
            }
            c.targetsAnswerable++;

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
                    c.reproduced.add(tg.key + ': ' + tg.quote.abbreviate(60));
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
    private static List<Integer> ranges(String artifact, String quote) {
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
    private static Boolean overlaps(String artifact, List<Integer> want, String found) {
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
        spec.charterVersion = AAO_LocateCharter.VERSION;

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
            src, r.parsed.pairs, runKey, AAO_LocateCharter.VERSION, idByCode
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
                AAO_Guidance_Text__c, AAO_Element_Count__c
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
