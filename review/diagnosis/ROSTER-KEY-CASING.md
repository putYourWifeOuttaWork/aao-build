# `"Sam" != "sam"` — the ninth specimen, and the answer to Matthew's resume question

CODE, 22 August. The 180th's fix.

## The mechanism, and it is the pattern's ninth appearance

Ingest writes roster keys lowercase. The reads carry the speaker label exactly as the transcript
writes it. The membership check compared them byte for byte:

```apex
Map<String, AAO_Participant__c> roster = ...   // keyed "sam"
roster.get(p.AAO_Speaker_Key__c)               // asked for "Sam"
```

**A key format and the predicate that tests membership in it are one mechanism in two places.**
Both ends of the comparison now normalise through one method, so there is no casing either side
can hold that the other does not - the drift is unexpressible rather than caught, which is the
direction every repair here has taken when the choice existed.

Trimming rides along, because a label with trailing whitespace is the same defect wearing
different bytes.

## The message was misdiagnosing itself, and that is fixed too

It read *"this is an ingest defect, never a quiet None."* **Ingest did its job** - the roster
stands whole, the internal seller correctly flagged - and the person WAS on it, under a different
casing. The refusal now prints the roster it actually holds, so the next reader sees `sam` beside
`"Sam"` and the one-character gap is the first thing visible rather than a conclusion to reach.

The refuse-loudly half was right and is untouched: a quiet None here would have dropped every
pair in those turns and the run would have "passed" thinner.

## Matthew's decision, answered rather than left to the retest

**Resume. No fresh paste.** The banked pairs need no re-keying:

```
roster keys:  sam (internal) | dana | raj | marcus
banked keys:  {Dana=19, Marcus=3, Raj=12, Sam=11}
banked "Dana"   -> resolves to Dana Okafor
banked "Marcus" -> resolves to Marcus Reyes
banked "Raj"    -> resolves to Raj Patel
banked "Sam"    -> resolves to Sam Ruiz
```

Every banked key resolves under the fix, so the 45 located pairs stand and the run continues from
where it stopped.

## One correction to the stamp's scope, small but worth the record

The 180th describes the failure through Sam. **All four keys were capitalised** - `Dana`,
`Marcus`, `Raj`, `Sam` - so the defect refused every pair on this source, not only the internal
speaker's. The run stopped at the first one it reached, which happened to be Sam's, and the
narrower reading would have suggested the bug lived somewhere near the internal-speaker wall. It
did not; it was the whole roster.

## What the raw transcript bought

Format-tolerance at ingest is now measured rather than assumed: a longer, differently-formatted,
un-normalised transcript parsed into a correct roster with the seller identified as internal, and
both reads ran full. **The failure was downstream of everything hard** - and it only existed
because every prior transcript had been pre-normalised for us. This is the class of defect that
otherwise waits for a pilot.
