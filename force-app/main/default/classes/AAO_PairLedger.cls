/**
 * ONE FOR ONE, FOR ONE, as a count-match. The half the unique index cannot see.
 *
 * `AAO_Pair_Key__c` carries the stage, so a second identification of the same located pair
 * collides on the database's own unique index. Matthew ratified that mechanism on 5 August
 * and named its limit in the same breath: **the index refuses more than one; it cannot
 * detect zero.** A located pair call 2 silently never disposes of violates the law just as
 * surely as a duplicate, and no insert ever collides to reveal it.
 *
 * "Exactly one" is two assertions. The index kills duplication at the database; this class
 * kills omission at the end of the pass. The index narrows what is left to catch down to
 * omission alone, which is why the check below is a count comparison rather than a per-row
 * walk.
 *
 * NOTHING HERE WRITES A ROW. The counts are the proof (§P8.0), and a mismatch throws: it is
 * always our bug, never a model behaviour, per the parse law.
 */
public with sharing class AAO_PairLedger {
    public class ArithmeticException extends Exception {
    }

    /** HELD, INCOMPLETE, or BROKEN. Three states, because two would have to lie about one. */
    public static final String HELD = 'HELD';
    public static final String INCOMPLETE = 'INCOMPLETE';
    public static final String BROKEN = 'BROKEN';

    /**
     * What one run of the pass did, in counts that each name their unit.
     *
     * `identified` is the disposition, not the outcome: a `None` and an `Ambiguous` are both
     * dispositions call 2 made and both satisfy one-for-one. Counting only the named ones
     * would make a correct refusal look like an omission, which is the exact confusion the
     * abstention rows used to create.
     */
    public class Counts {
        public String runKey;
        /**
         * Set by `assertOneForOne`. INCOMPLETE where the verify stage has claims left to
         * verify — a legitimate mid-pass state that is INDISTINGUISHABLE from the omission
         * this class exists to catch.
         */
        public String outcome = HELD;
        public Integer located = 0;
        public Integer disposed = 0;
        public Integer identifiedToAPerson = 0;
        public Integer identificationsRefused = 0;
        public Integer verified = 0;
        public Integer verificationsUpheld = 0;
        public Integer verificationsRefused = 0;

        public override String toString() {
            return String.join(
                new List<String>{
                    'pairs located            ' + located + ' (unit: pairs)',
                    'dispositions made        ' + disposed + ' (unit: pairs)',
                    '  to a person            ' + identifiedToAPerson + ' (unit: pairs)',
                    '  None or Ambiguous      ' + identificationsRefused + ' (unit: pairs)',
                    'verdicts returned        ' + verified + ' (unit: claims)',
                    '  upheld                 ' + verificationsUpheld + ' (unit: claims)',
                    '  refused                ' + verificationsRefused + ' (unit: claims)',
                    'outcome                  ' + outcome +
                        (outcome != INCOMPLETE
                            ? ''
                            : ' (' + (identifiedToAPerson - verified) +
                              ' claims awaiting a verdict; a stopped pass and a dropped ' +
                              'claim look identical here, and the run receipt that would ' +
                              'separate them is owed by section P8.0)')
                },
                '\n'
            );
        }
    }

    public static Counts counts(String runKey) {
        Counts c = new Counts();
        c.runKey = runKey;
        for (AggregateResult ar : [
            SELECT AAO_Stage__c stage, AAO_Disposition__c disp, AAO_Verification__c ver,
                COUNT(Id) n
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey
            GROUP BY AAO_Stage__c, AAO_Disposition__c, AAO_Verification__c
        ]) {
            Integer n = (Integer) ar.get('n');
            String stage = (String) ar.get('stage');
            String disp = (String) ar.get('disp');
            String ver = (String) ar.get('ver');

            if (stage == AAO_PairKey.LOCATED) {
                c.located += n;
                continue;
            }
            c.disposed += n;
            if (disp == 'Identified') {
                c.identifiedToAPerson += n;
            } else {
                c.identificationsRefused += n;
            }
            if (ver == 'Upheld') {
                c.verificationsUpheld += n;
                c.verified += n;
            } else if (ver == 'Refused') {
                c.verificationsRefused += n;
                c.verified += n;
            }
        }
        return c;
    }

    /**
     * The end-of-pass assertion. Call it after call 2, and again after call 3.
     *
     * `afterVerify` is a separate argument rather than inferred from whether any verdict
     * exists, for the reason the pair's own stage is an explicit picklist: a state read off
     * the shape of the data is a state with two shapes. Called after call 2, a pass with no
     * verdicts yet is correct; called after call 3, the same data is an omission.
     */
    public static Counts assertOneForOne(String runKey, Boolean afterVerify) {
        Counts c = counts(runKey);

        if (c.located != c.disposed) {
            c.outcome = BROKEN;
            throw new ArithmeticException(
                'One for one is broken on run ' + runKey + ': ' + c.located +
                ' pairs located, ' + c.disposed + ' dispositions (unit: pairs). ' +
                (c.disposed < c.located
                    ? 'Call 2 was handed a pair it never disposed of. The unique index ' +
                      'cannot see this: it refuses a second disposition and has nothing to ' +
                      'refuse when there is none.'
                    : 'There are more dispositions than pairs, which the unique index ' +
                      'should have refused. Something wrote past the trigger.') +
                ' This is our bug, never a model behaviour, per the parse law.'
            );
        }

        // THE BATCHED-VERIFY HAZARD, named 5 August. Call 3 runs one claim per callout and
        // forty claims is ~172 s against a 120-second per-transaction ceiling, so a pass is
        // driven in batches by its caller. **A pass that stops between batches leaves claims
        // with a disposition and no verdict — which is byte-for-byte what a dropped claim
        // looks like.** Throwing there fails a healthy run; suppressing it there blinds the
        // check on an unhealthy one.
        //
        // So there is a third state rather than a binary that has to lie about one of the two
        // cases, the same shape as `CHANGED, undiagnosed` and the `UNREACHABLE` line.
        // INCOMPLETE is reported with its counts and scored as neither held nor broken.
        //
        // **What makes INCOMPLETE distinguishable from BROKEN is the run receipt, and the
        // receipt does not exist.** §P8.0 owes it — one row per Source per pass, carrying
        // which stages completed — and until it does, this class can say a pass is unfinished
        // but not whether it was ABANDONED unfinished. Recorded as the gap rather than papered
        // over by a caller-supplied flag, which would be the caller asserting its own health.
        if (afterVerify && c.verified < c.identifiedToAPerson) {
            c.outcome = INCOMPLETE;
            return c;
        }
        if (afterVerify && c.verified != c.identifiedToAPerson) {
            c.outcome = BROKEN;
            throw new ArithmeticException(
                'For one is broken on run ' + runKey + ': ' + c.identifiedToAPerson +
                ' pairs identified to a person, ' + c.verified + ' verdicts returned ' +
                '(unit: claims). Every identified claim goes in front of the blind reader ' +
                'and exactly one verdict comes back. None and Ambiguous rows are not ' +
                'counted here and are not missing verdicts; there is no claim in front of ' +
                'the reader on those.'
            );
        }
        return c;
    }
}