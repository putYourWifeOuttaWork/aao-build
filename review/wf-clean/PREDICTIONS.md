# The clean re-run · predictions, recorded BEFORE the purge

**Written and committed before a single row was deleted, so nothing here can be a post-hoc.**
The ninety-ninth stamp's item 4(d). Tree `/Users/thefinalmachine/Downloads/claude` on `main`,
org `00DWD00000DV7iT2AT`.

## What changed since the first stack

| | |
|---|---|
| **(a) Promotion** | `AAO_Promotion.runAfterProjection` — shadows whose designator resolves to a bound Contact gain `AAO_Promoted_Contact__c`; every flag of that PERSON clears, whatever form raised it. Plus `reconcile` runs again after projection. |
| **(b) Card face** | keyed by pair **Id**, not `AAO_Pair_Ref__c`. The ref is unique per RUN and the writer reads every run on the deal, so refs collided as the stack grew. |
| **(c) Answer key** | **`A1` → `A2`.** A Participant answer resolves to its Contact where one exists, the participant row only where none does. |

## THE PREDICTIONS

Design's, from the stamp, plus mine where the stamp is silent. **Each is falsifiable and none is
hedged.**

### From the ninety-ninth stamp

1. **Priya ends with ONE answer chain**, not one per call.
2. **Her flags are CLEARED by identification**, not standing.
3. **Both her shadows are promoted** to her Contact — the one created during the run.
4. **Tom ends at −2 on ONE row**, not −1 on two.
5. **The counter-accumulation question gets its evidence** — for the first time the arithmetic
   can be judged on three calls of real accumulation.

### Mine, stated so they can be wrong

6. **Card faces are inferred on all three runs**, no 400, no `has non-unique elements`. If the
   root cause was the ref and not something else, s5's twelve faces come back as inferred
   clauses rather than raw verbatim.
7. **Answer count falls.** The first stack ended at 70 answers across 86 claims. Collapsing
   per-call rows onto per-person rows should cut that materially — I expect **roughly 45 to 55**,
   and I will report the number either way.
8. **Rohan and Alison move.** Both sat at +1 across three calls because each call wrote its own
   row. If they carry mentor-grade or supporter-grade evidence on more than one call, at least
   one should now exceed +1. **If neither moves, the evidence simply was not there** — and that
   is itself the answer to question 5, not a failure of the fix.
9. **Bettina's flag stays STANDING.** She is mentioned in s4 and never appears on a roster, so no
   Contact resolves to her and promotion must leave her alone. **If Bettina's flag clears, the
   promotion matcher is too loose and that is a defect.**
10. **The join stays inside `C + 9`** and SOQL stays under 100. SOQL was 81 on the old s5 and is
    the closer ceiling now.

### What I do NOT predict

- **Whether the counters' bands change the map.** That is the ninety-fifth stamp's open question
  and Matthew's to rule; I am producing the evidence, not the verdict.
- **The s5 card count.** Whether twelve new cards at call 3 is lawful is design's row pass
  against the s5 expectations, held open at the ninety-ninth's item 3.
- **Locate counts.** Read recall varies run to run by ruling; 78 / 74 / 83 will not reproduce
  exactly and that is not a finding.

## The purge, and its limits

`AAO_Purge` under the twenty-eighth stamp's protocol: run-keyed AAO rows for `wf-s3`, `wf-s4`,
`wf-s5`, their projected map values, and machine-created Contacts via the create-leg record.
**Seeds stay. Human-watermarked rows stay. The three Sources stay** — they are the frozen
fixtures and the re-run reads the same bytes.

**Named before it runs:** the Contact created for Priya on the first stack
(`003WD00001RRgsrYAD`) is machine-created and enumerable, so the purge may remove it and the
re-run will create its equivalent. Prediction 3 is written to accept either id.
