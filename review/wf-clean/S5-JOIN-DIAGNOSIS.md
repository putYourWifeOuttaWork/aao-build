# The s5 join diagnosis · no gate refused anything · the transaction died, and both alarms were unwired

The hundred-third stamp's item 1, on its corrected subject: **the whole s5 join transaction**, 39
upheld pairs across all six external people, not nine from one.

| | |
|---|---|
| **Tree / org** | `/Users/thefinalmachine/Downloads/claude` on `main` · `00DWD00000DV7iT2AT` |
| **Method** | read the org, read the code, then run the stage and capture what it throws |

## THE ANSWER · there is no refusing gate, because nothing got as far as being refused

```
System.LimitException: Too many SOQL queries: 101
```

**The join threw the SOQL governor and rolled back whole.** It is an `allOrNone` transaction, so
all 39 claims died together. That is why the number is 39-to-0 and not 30-to-9: a governor does
not discriminate between people.

Matthew's bar asks for the refusing gate to be named or it is a counting-law defect. **Neither
half fits as written, and the honest answer is the third thing:** no gate refused these pairs and
no claim-writing rule dropped them. The pairs were never even ineligible — measured before
anything was re-run:

```
S5 ELIGIBLE = 39    notIdentified = 29    notUpheld = 29    alreadyCommitted = 0
claims by source: {SRC-00000045 = 29, SRC-00000039 = 22}      SRC-00000040 = ZERO
```

**Thirty-nine pairs sat eligible, upheld, unclaimed, waiting.** The stage had not run to
completion; it had not run at all past its own governor.

## DESIGN'S HYPOTHESIS IS REFUTED, BY MEASUREMENT RATHER THAN BY ARGUMENT

The stamp's hypothesis: the change set at `b2a2514` contains the cause, and the A2 key's Contact
resolution meets its first Contact-less, email-less roster person exactly at s5.

**It does not, and the number that settles it is the SOQL slope, which did not move.**

Measured by running the join in ratified 12-pair batches:

| batch | candidates | DML | SOQL |
|---|---|---|---|
| 1 | 12 | 19 / 150 | **37 / 100** |
| 2 | 12 | 19 / 150 | **37 / 100** |
| 3 | 12 | 21 / 150 | **38 / 100** |
| 4 | 3 | 10 / 150 | **16 / 100** |

Slope `(37 − 16) / (12 − 3) = 2.33` queries per candidate, base ≈ 9:

> **SOQL ≈ 2.33 · C + 9**

- **At 39 candidates: 2.33(39) + 9 = 100.9.** The measured failure was **101**.
- **Against the PRE-change run:** dirty s5 measured **81 / 100 at 30 candidates**. The model gives
  2.33(30) + 9 = **79.9**.

**The same slope predicts both the pre-change measurement and the post-change failure**, so
`b2a2514` did not raise the per-candidate query cost. What changed was **C**: the clean run's call
3 upheld **39** where the dirty run upheld **30**, and 39 is the first value that crosses.

Priya being Contact-less and email-less is real and is not the cause. **She is downstream of it.**

**The ceiling, stated so it is not rediscovered: C ≈ 39 on SOQL, against C ≈ 140 on DML.** SOQL is
the binding governor by a factor of three and a half, exactly as the s5 report flagged when it
said SOQL "did not fall with the DML and is now the closer ceiling."

## THE SECOND EDGE · `assertOneForOne` did not report BROKEN because IT HAS NO CALLER

The stamp asks: not run, or ran and silent. **NOT RUN.**

```
production callers of AAO_PairLedger.assertOneForOne : NONE
```

Two references exist in production source and both are prose in comments — `AAO_Pass.cls:815` and
`AAO_IdentifyCharter.cls:15`. Every executing reference is in `AAO_PairLedgerTest`. **The counting
law's own alarm is not wired to the driven path.**

## AND THE SAME IS TRUE OF THE FIX

```
production callers of AAO_PairCommit.run(runKey, domains, maxPairs) : NONE
```

**The caller-side join split is built, ratified, documented — and never invoked.** Its own doc
comment, written before this run, records the identical failure:

> *"On 13 August a purged rerun produced 28 upheld and the join threw `Too many SOQL queries: 101`.
> So the bulkification bought roughly ten more pairs and the ceiling is still a ceiling, exactly as
> both stamps said it would be."*

**So the wall was known, the fix for it was built, and the two-argument overload that skips the fix
is the one every driver calls — mine included.** That is the sixteenth stamp's join wall on its
third instance.

### The finding, stated once

**Two mechanisms exist, both correct, both with zero production callers: the split that would have
prevented this, and the alarm that would have reported it.** Between them, 39 upheld pairs produced
zero claims and nothing anywhere said so. This is the same class as the eighty-first stamp's
`AAO_Resolve` finding and the field-with-no-readers law's sibling: **a mechanism with no caller is
a plan, not a mechanism.** It is now the third instance.

## MY OWN REPORTING MISS, named because it is the reason this took a stamp to surface

The clean re-run report put `—` in the s5 join DML cell and **did not name the stage as failed.**
It recorded an absence without calling it a failure, and design had to re-scope the diagnosis to
find what the report should have said.

The mechanical cause is worth keeping: **this error class prints no debug log at all.** My driver
piped every stage through `grep USER_DEBUG`, so a `LimitException` produced empty output and the
loop moved on to projection. I hit the identical thing twice more while writing this diagnosis (a
non-groupable `Name`, a non-existent field) and each time the filter showed nothing.

**A stage whose output is empty is not a stage that ran quietly. It is a stage that has to be
checked.**

## THE REPAIR, RUN, AND PROMOTION FINALLY HAS ITS SPECIMEN

The split completed the join lawfully — 12, 12, 12, 3 — and the pass was carried to its end.

```
join       39 claims, four transactions, SOQL peak 38/100
projection 1 created, 1 populated, 0 blocked, 15 unchanged
promotion  2 shadows promoted, 2 flags cleared
cards      0 created, 0 reinforced, 29 unchanged
```

**PROMOTION WORKED, AND ITS NEGATIVE CONTROL HELD.**

```
FLAGS
  Cleared   Identify "Priya Natarajan"     clearedBy = Priya Natarajan
  Cleared   Identify "Priya"               clearedBy = Priya Natarajan
  Standing  Identify "Bettina Marchetti"   clearedBy = null

SHADOWS
  SP-00000000 "Priya Natarajan"  -> Priya Natarajan
  SP-00000002 "Priya"            -> Priya Natarajan
  SP-00000001 "Bettina Marchetti" -> null
```

**Both of Priya's flags cleared, under two different bound keys, both carrying the Contact as the
receipt — N forms, N shadows, ONE Contact, N flags cleared, and the keys stayed uncollapsed.**
That is the ninety-ninth stamp's clear-by-person, working on the exact rows that failed before.

**Bettina is unpromoted and her flag still stands**, which is the control: promotion discriminates
rather than clearing whatever it finds.

**The ninety-eighth stamp's shippability failure is closed** — a flag that could not clear when the
work was done now clears.

## Deal state after the repair

```
claims 90  {SRC-00000045 = 29, SRC-00000039 = 22, SRC-00000040 = 39}
answers 51 · map rows 7 · cards 29
```

**Design's grading record was built against the pre-repair state (51 claims, s5 absent).** Six rows
it marks blocked-by-the-s5-join-defect are now unblocked, and the s5 claim column has moved from
zero to 39. **Stated plainly so the record is re-graded rather than silently invalidated.**

The card-face call still 400s on the grammar ceiling, unchanged and not touched here.

## What is owed, not built

1. **Wire the split.** Every join caller takes the three-argument overload with a batch under the
   measured ceiling. The mechanism needs no build, only a caller.
2. **Wire `assertOneForOne`.** An alarm nobody calls did not fail; it was absent.
3. **The SOQL model belongs beside the DML model** in the ceiling record: `DML ≈ C + 9`,
   **`SOQL ≈ 2.33·C + 9`**, and the second is the binding one.

**Nothing tuned. Nothing graded by CODE.**
