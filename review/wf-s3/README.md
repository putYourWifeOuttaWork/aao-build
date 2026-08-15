# Wells Fargo session 3 · the measurement run

**One run. No rehearsal. No tuning. Nothing re-run to get a better number.**

| | |
|---|---|
| **Tree** | `/Users/thefinalmachine/Downloads/claude`, branch `main`, project `aao-build` |
| **Org** | `00DWD00000DV7iT2AT` — sandbox `aossb2` |
| **Opportunity** | `006WD00000TWvH0YAL` — Wells Fargo CIB, Aviator, Pilot to Enterprise |
| **Source** | `SRC-00000045` (`a1XWD0000083v0L2AQ`), occurred **2026-08-05T18:00:00Z**, sha `52f04e67…` |
| **Run key** | `wf-s3` |
| **Ran** | 2026-08-15, 19:13:43Z → 19:21:23Z |

**Sequenced by `AAO_Evidence_Occurred__c`, never by name.** Verified before spending anything:
`SRC-00000045` is the *earliest* call at 2026-08-05 despite carrying the *highest* number;
`SRC-00000039` is 19 August and `SRC-00000040` is 25 September. **The other two were not run.**

**Prior state, measured before the run:** 0 claims, 0 answers, 0 pairs, 0 flags, 0 map rows,
0 cards on the deal; 0 shadow persons org-wide. 23 participants from ingest. Nothing had ever
been run against this opportunity.

## THE THREE THINGS DESIGN ASKED FOR EXPLICITLY

### 1 · Which terminal each unresolved mention landed in

**ZERO went to AMBIGUOUS. One designator went ladder-zero to the model leg.**

The deterministic leg produced **no ambiguous terminal at all** and raised **no flag**. It left a
remainder of two refs, `r1q26` and `r1q27`, both carrying the designator **"Priya Natarajan"**.
The model leg then returned one typed request:

```
kind = named-off-artifact   designator = "Priya Natarajan"   candidate = NONE
basis = "she is our CIO for the corporate and investment bank" - spoken by buyer-side
        Katherine Villanueva about her own organisation
```

Both pairs disposed **`Held`**, and `AAO_Pass.raiseHeld` raised **one** Identification flag:

```
Identity_Unresolved / Standing / Identify "Priya Natarajan"
raised_at = 2026-08-05T18:00:00Z   (the evidence clock, not the run clock)
bound key = ident|006WD00000TWvH0YAL|priya natarajan
```

**So on this transcript the flag fires only AFTER a callout.** The deterministic path contributed
nothing to it. That is the design working as stated — ladder-zero defers to the model leg rather
than crying wolf — and it means **S4-09's liveness on this corpus depends on the model leg
running**, not on the deterministic stage alone. Design should read that before grading S4-08.

A third Priya pair, `r2q6` from read 2, **merged** into `r1q26` rather than holding separately,
so three located pairs about one unidentified person produced one flag. The bound key did its job
on real data.

### 2 · Did `AAO_Shadow_Person__c` write its first row ever

**Yes. `SP-00000000`.** The object had never held a row in its life; it holds one now.

| Field | Value |
|---|---|
| `Name` | `SP-00000000` |
| `AAO_Designator__c` | `Priya Natarajan` |
| **`AAO_Shadow_Key__c`** | **`001WD00000uYd9xYAC\|mention:priya natarajan`** |
| `AAO_Identity_Provenance__c` | `Utterance` |
| `AAO_Anchor_Count__c` | **2** |
| `AAO_Utterance_Start__c` / `End` | 21061 / 21198 |
| `AAO_Reason__c` | `Unresolvable` |

**The shadow key is the third branch** — account id plus `mention:` plus the normalised
designator — which is the shape the eighty-seventh stamp ruled and wrote into the field's own
description. **The provenance boundary held:** provenance reads `Utterance` and the identity
columns are empty, so no identity fact was minted from verbatim.

Two anchors on one designator, from two mentions in one call.

### 3 · Which `AAO_Pair__c` refusal branches fired

**Two, and both are first walks on real data.**

| Disposition | Count | Status before this run |
|---|---|---|
| `Identified` | 52 | the happy path |
| **`Merged`** | **24** | **never seen on the driven path** |
| **`Held`** | **2** | **never seen anywhere; the value was added 15 August** |
| `Ambiguous` | 0 | — |
| `None` | 0 | — |

**`Merged` at 24 is the larger result.** The eighty-first stamp measured **0 of 67** pairs
corroborated across the Emerson stacked run and diagnosed the cause: `AAO_Resolve` had zero
production callers, so the twenty-seventh stamp's two-read merge was dead code that read as live.
**It is live now: 24 of 78 pairs merged**, each with its reason on the row — *"same contract,
overlapping bytes, same voiced meaning, same subject. The receipt stands here; the establishment
rides the canonical."* That is the byte-intersection merge key working on real speech for the
first time.

**Per the ninety-fourth stamp's item 4, grade any divergence in these two branches as a first
walk, never as a regression.** There is no prior state to regress from.

## The ledger arithmetic

```
located    78        (read 1: 42 COLD   read 2: 36 WARM)
identified 78        52 Identified + 24 Merged + 2 Held
verified   52        31 upheld, 21 refused
claims     31
answers    26
criteria    5
shadows     1        SP-00000000, the first ever
```

**78 located, 78 disposed. One for one, for one. HELD.**

## Stage timings · from the run receipt, journalled, not recomputed

`RCPT-00000004` — 7 stages, 4 callouts, total wall **174,172 ms**, cache WARM,
normalizer `NF1+out:52f04e67`, split events 0.

| Stage | Callout ms | Wall ms | SOQL | DML | CPU ms | Heap | Cache | Produced |
|---|---|---|---|---|---|---|---|---|
| call 0 resolve | 5,885 | 5,885 | 5/100 | 0/150 | 95 | 7 KB | WARM | — |
| call 1 read 1 | 47,592 | 47,592 | 2/100 | 1/150 | 123 | 134 KB | COLD | 42 |
| call 1 read 2 | 38,847 | 38,847 | 2/100 | 1/150 | 108 | 128 KB | WARM | 36 |
| **call 3 verify** | **55,162** | 55,162 | 2/100 | 1/150 | 239 | 65 KB | COLD | 52 |
| join | 0 | 4,186 | 83/100 | **133/150** | 1,690 | 206 KB | — | 31 |
| projection | 0 | 3,064 | 30/100 | 15/150 | 1,088 | 17 KB | — | 26 |
| cards | 0 | 19,436 | 11/100 | 10/150 | 1,101 | 13 KB | — | 10 |

**WORST SINGLE CALLOUT: 55,162 ms (call 3 verify, 4 batches) against the 120,000 ms ceiling —
46% of the limit.** Comfortable. Every callout cleared.

Driver-measured wall including CLI overhead, for the record: call 0 17.8 s, read 1 47.8 s,
read 2 39.1 s, **call 2a deterministic 0.281 s**, call 2b model leg 4.9 s, call 3 55.5 s,
join 4.3 s, projection 3.1 s, cards 19.5 s. **Roughly 192 s end to end, driven serially from an
external driver** — not comparable to the ratified ~59 s concurrent express-lane measurement, per
the seventy-fourth stamp's caution.

## FINDING · the join ran DML at 133 of 150, 89% of the ceiling

The sixteenth stamp's join wall, met again and closer than ever measured. At **31 claims** this
run consumed 133 DML statements and 196 DML rows. The caller-side split exists and was not
needed here, but **the margin is 17 statements**, and s4 and s5 stack onto existing state rather
than starting clean. **Reported, not fixed** — no tuning during the read.

## FINDING · the run receipt does not journal the model leg

The receipt records **4 callouts**; the pass made **5**. `AAO_Resolve.requests`'s call
(`call2_requests`, 4,577 ms) is absent from the stages array. The receipt's own charter says one
row per Source per pass carrying every stage's wall and calls. **The model leg has no receipt
leg wired**, the same class of gap the card writer had before the seventieth stamp closed it.
Recorded; not fixed during the read.

## LAWFUL FIX · the row export refused every Problems pair, blaming the data

The standing obligation would not run. `AAO_RunExport.pairs()` threw:

> *"Contract AAO_PB_GOAL belongs to no family the sweep knows, and it declares no
> AAO_Family__c… THE FIX IS DATA, NOT CODE."*

**The error is wrong about its own cause.** `AAO_PB_GOAL` **does** declare
`AAO_Family__c = 'Problems'`, verified by query. The export was calling `familyOf(String)` — the
prefix ladder, which knows only `AAO_PS_`, `AAO_POL_`, `AAO_BR_` and `AAO_DC_` — instead of
`familyOf(AAO_Evidence_Contract__c)`, the overload the forty-third stamp added for exactly this,
and it never selected the field at all.

**Fixed:** the query now selects `AAO_Evidence_Contract__r.AAO_Family__c` and calls the record
overload. **This is a read-only reporting path and cannot touch the run's rows** — every pair,
claim, answer and projected value in this report was written before the fix and is unchanged by
it. Deployed `-o aossb2`, export then produced 78 pairs, 31 claims, 26 answers.

**The general lesson, since this is the second instance today:** an error message that names its
own cause can be wrong, and the org's message here would have sent the next reader to edit
correct data.

## retryNotes

1. **Call 0 quote-law retry.** Attempt 1 answered yes with no quote and the charter refused it;
   attempt 2 succeeded. One retry per the thirty-fourth stamp's policy, both attempts on the
   record. This is the known cold-flake, fourth instance.
2. **Call 3 invocation 1 threw and was NOT diagnosed.** The first `AAO_Pass.verify` invocation
   failed with a runtime error; the second completed all 4 batches and verified all 52. **The
   error text was not captured and is not invented here.** Counts reconcile exactly (31 + 21 =
   52), so nothing was lost.

## The result, for grading

**The map, 6 rows:**

| Person | Buyer role | Political | Status | Coverage |
|---|---|---|---|---|
| Katherine Villanueva | Evaluator | Inner Circle | Supporter | Multiple contacts |
| Rohan Deshpande | Evaluator | Political Structure | Supporter | Multiple contacts |
| Tom Brzezinski | Evaluator | Political Structure | **Non-Supporter** | Multiple contacts |
| Alison Reyes | — | — | Supporter | Multiple contacts |
| Meredith Cho | — | — | — | Multiple contacts |
| Jared Kim | — | — | — | Brief contact |

**Cards, 10:** Goal 3, Initiative 3, Obstacle 3, Pressure 1. 10 informer links, 9 owner links,
1 new board section, 0 duplicates retired, 0 contradictions flagged.

**Projection outcome: 6 created, 0 populated, 0 blocked, 10 unchanged, 0 unresolved.**

Rows in `rows/`: `pairs.csv` (78), `claims.csv` (31), `answers.csv` (26).

**Nothing here is graded by CODE.** Design grades s3 against the `aao-wf-s3` expectations and the
liveness rule. No number in this report was tuned toward any expectation, and the run was not
repeated.
