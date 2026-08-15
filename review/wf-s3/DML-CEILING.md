# The static DML count · the join's ceiling, and why s4 does not run yet

**The ninety-fifth stamp's item 6.** A read of the code, not a run.

| | |
|---|---|
| **Tree** | `/Users/thefinalmachine/Downloads/claude`, branch `main`, project `aao-build` |
| **Org the measurement came from** | `00DWD00000DV7iT2AT` — sandbox `aossb2` |
| **Measured against** | run `wf-s3`, join stage: **DML 133 of 150**, 196 rows, SOQL 83 of 100 |

## THE ANSWER TO THE QUESTION ASKED: ZERO

**Not one DML statement on the pass path is conditional on prior state existing.**

There is exactly one prior-state branch in the whole join, `AAO_Commit.persist`:

```apex
if (answer.Id != null) {
    update answer;        // prior state exists
    return answer;
}
Database.SaveResult sr = Database.insert(answer, false);   // nothing to update
```

**One DML either way.** The update leg *replaces* the insert; it does not add to it. Every other
statement on the path fires identically whether or not s3 ran first: `insert claim`,
`update answer` for the last-claim pointer, `update cand` in `stampCandidate`, the criterion
upsert, and the five bulk statements in `AAO_PairCommit`.

**So the premise behind the question is wrong, and wrong in the safe direction.** Stacking s4 on
s3 adds no update legs. There is no patch-leg growth vector.

The only prior-state branch that *could* add one is the `DUPLICATE_VALUE` collision path
(`update colliding`, +1). It fires when an insert loses a race — which is the branch prior state
makes *less* likely, not more, because an answer with an Id never reaches the insert.

## BUT THE CEILING IS STILL BREACHED, FOR A DIFFERENT REASON

**The stamp's second premise is also wrong, and this one is not safe: there IS DML inside a
loop.** Two of them.

`AAO_PairCommit.run` line 324:

```apex
for (Integer i = 0; i < candidates.size(); i++) {
    AAO_Commit.Result r = AAO_Commit.commitCandidate(candidates[i].Id, internalDomains);
```

and `commitCandidate` performs **four DML statements per call**:

| # | Statement | Where | Conditional? |
|---|---|---|---|
| 1 | `update answer` **or** `Database.insert(answer)` | `persist`, 662 / 666 | prior state picks the branch, **count unchanged** |
| 2 | `insert claim` | 486 | never conditional |
| 3 | `update answer` (last-claim pointer) | 489 | never conditional |
| 4 | `update cand` | `stampCandidate`, 735 | never conditional |
| +1 | `update colliding` | 690 | only on `DUPLICATE_VALUE` |

And `AAO_Criteria.mint` line 124 does a **single-row upsert**, called once per criteria pair
inside `AAO_PairCommit`'s own loop:

```apex
Database.upsert(row, AAO_Criterion__c.AAO_Criterion_Key__c, true);
```

The five statements in `AAO_PairCommit` itself are genuinely bulk and `isEmpty`-guarded — at most
one each: `insert candidates`, `update committed`, `update typed.values()`, and the two
`update moved` in `rebuildVerdicts` and `rebuildCounters`.

## THE MODEL, AND IT REPRODUCES THE MEASUREMENT EXACTLY

```
DML  =  4·C  +  M  +  B

  C = candidates committed        (4 statements each, in the loop)
  M = criteria minted             (1 single-row upsert each, in the loop)
  B = bulk statements that fired  (0 to 5, one each)
```

**Checked against `wf-s3`:** C = 31, M = 5, B = 4 → **4(31) + 5 + 4 = 133.** The measured join
DML was **133**. The model is exact, not approximate.

## THE CEILING

```
4·C + M + B  ≤  150
```

Worst case for the constants (M = 5, B = 5): **4C ≤ 140, so C ≤ 35.**

| Candidates | DML | |
|---|---|---|
| 31 (s3's actual) | 133 | what we measured |
| 35 | 149 | **the last value that fits** |
| 36 | 153 | **over** |
| 40 | 169 | over |

**The headroom is four candidates.**

## THE VERDICT: IT DOES NOT CLEAR, AND s4 DOES NOT RUN

**Nothing in the code caps C.** The join processes every eligible candidate for its run key in one
transaction; there is no batch, no split, no guard. So the worst case is not 150-bounded at all —
it is unbounded, and it crosses 150 at 36 candidates.

The expected case is more comfortable and I will not hide it: the join is **keyed by run key**, so
s4's join commits s4's candidates only, not the cumulative set. s4's transcript is 25,779 bytes
against s3's 25,598 — near-identical density — so s4 will probably produce roughly 31 candidates
again and land near 133.

**"Probably" is not a ceiling, and this is the measurement instrument.** Four candidates of
margin on a run that cannot be rehearsed, where a breach rolls the whole join back, is not a
margin. **Stopping, per the stamp's own instruction.**

## THE PROPOSED RULE · a DML split trigger, mirroring the 90-second wall

The stamp is right that the lawful shape already exists and that DML has no equivalent. Proposed,
not built, and deliberately the same shape as the twenty-ninth stamp's trigger so it reads as one
rule with two units rather than two rules:

> **THE DML SPLIT TRIGGER.** Any stage whose DML statement count crosses **112 (75% of the 150
> ceiling)** inside one transaction **completes its remaining work in a continuation call in the
> next transaction: never redo, never retry-by-growing.**
>
> **Split units per stage**, the same discipline the other three already have: the join splits by
> **candidate batch**; projection by **map-row batch**; the card writer by **card batch**.
>
> **Every split event journals.** `AAO_Run_Receipt__c.AAO_Split_Events__c` exists and read **0**
> on this run; it becomes the count that makes a near-ceiling visible before it is a failure.

**75% is taken from the existing trigger rather than invented.** At 112 statements the join has
committed roughly 27 candidates and can still finish any single candidate's four-statement group
inside the remaining 38, which is what makes the threshold safe rather than merely early.

## AND A CHEAPER FIX THAT SHOULD LAND FIRST

The split trigger makes the ceiling survivable. **Bulkification makes it distant**, and three of
the four per-candidate statements are avoidable with no semantic change:

| Statement | Today | Bulkified |
|---|---|---|
| `insert claim` | per candidate | collect, one insert |
| `update answer` (last-claim pointer) | per candidate | collect, one update |
| `update cand` (`stampCandidate`) | per candidate | collect, one update |
| `Database.upsert` criterion | per criterion | collect, one upsert |

**`persist` must stay per-candidate and that is deliberate**, not an oversight: it reads standing
state, branches on it, and handles `DUPLICATE_VALUE` per row. The forty-eighth stamp's
read-then-branch semantics have to stay byte-identical, and the comment at line 490 explains why
the answer key is invalidated after each write rather than re-primed. **Bulkifying that one would
be the clobber defect returning.**

The arithmetic after bulkification: **C + ~9** instead of **4C + 9**. At s3's 31 candidates that
is **40 statements instead of 133**, and the ceiling moves from 35 candidates to roughly 140.

**Recommended order: bulkify the three, then add the split trigger as the backstop.** The
bulkification is the same move the forty-eighth stamp made for the join's SOQL when it hit 101,
applied to the other governor, and the split trigger is what makes any future ceiling survivable
rather than fatal.

## What this does not touch

s3's rows are unchanged and nothing was re-run. No tuning. The measurement instrument still
carries exactly one graded run.
