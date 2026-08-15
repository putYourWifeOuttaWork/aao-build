# Wells Fargo session 5 · the stack completes · and the reconciliation did not happen

**One run, stacked on s3 and s4, no purge, current code, no tuning.**

| | |
|---|---|
| **Tree** | `/Users/thefinalmachine/Downloads/claude`, `main`, project `aao-build` |
| **Org** | `00DWD00000DV7iT2AT` — sandbox `aossb2` |
| **Source** | `SRC-00000040` (`a1XWD0000083uvW2AQ`), occurred **2026-09-25T19:00:00Z** |
| **Run key** | `wf-s5` |

## 1 · HOW PRIYA RESOLVED · she became a real person, and NEITHER FLAG CLEARED

**Reported as it happened, not as it should have.**

**She is on the s5 roster with a display name and NO EMAIL and NO contactId** — the eighty-eighth
stamp's distinguishing mark exactly. Her Participant row was written at ingest carrying no Contact.

**What the run did:**

- **The mention resolved.** One s5 pair is about her — `r2q3`, designator `"Priya"`, disposition
  **`Identified`**, person `Priya Natarajan`. She stopped being a mention and became a speaker.
- **Zero remainder, zero Held on s5.** No model leg fired at all.
- **A Contact was created for her**, `003WD00001RRgsrYAD`, and she now carries a map row:
  `Approver`, `Brief contact`.
- **`flagsRaised = 0`, `flagsCleared = 0`.**
- **All three Identification flags are still `Standing`. Neither Priya flag cleared. Both shadows
  stand unpromoted.**

```
Standing  Identify "Priya Natarajan"    cleared = null
Standing  Identify "Priya"              cleared = null
Standing  Identify "Bettina Marchetti"  cleared = null

SP-00000000 "Priya Natarajan"  anchors 2  promoted = null
SP-00000002 "Priya"            anchors 2  promoted = null
SP-00000001 "Bettina Marchetti" anchors 2 promoted = null
```

### Why, and it is a sequencing defect rather than a judgement

`AAO_Identification.reconcile` clears a flag only when its designator is bound to a **Contact**. It
runs inside `AAO_Pass.identifyDeterministic` — **call 2a**. The Contact for Priya is created by the
**create leg at projection**, six stages later.

**So reconcile asked "is Priya bound to a Contact?" at a moment when the answer was still no, and
the Contact that would have answered yes was written by the same run minutes afterwards.** The
flags would clear on a *subsequent* run, and there is no subsequent run.

Two separable things, both real, and design should not read them as one:

- **The reconcile is ordered before the binding it tests for.** That is a wiring fault with an
  obvious shape and I am not fixing it mid-read.
- **Even correctly ordered, only ONE of Priya's two flags could ever clear this way.** The bound
  keys are `…|priya natarajan` and `…|priya`; the s5 pair carries designator `"Priya"`, so only
  the second matches. **The first would stay open forever** — the eighty-seventh stamp's
  key-collapse ruling, arriving at its final cost: one human, two shadows, two flags, and the
  reconciliation path can only ever reach one of them.

**S5-01's expectation — the held identity reconciles with the roster row into one person — did not
happen.** She reconciled as a *speaker*; her held identities did not.

## 2 · THE RETIREMENT DELTA · it fired on s3 and s4, and Jared stayed put

| Run | Identified | Merged | **Held** |
|---|---|---|---|
| `wf-s3` | 52 | 24 | **2** |
| `wf-s4` | 48 | 20 | **6** |
| `wf-s5` | 64 | 19 | **0** |

**The delta fired.** Priya's s3 pairs and Priya's and Bettina's s4 pairs came back `Held` rather
than `Identified` — 8 held pairs across the two calls, which is DELTA-1's predicted movement set
arriving. **s5 has zero Held because Priya is on the roster and Bettina is not mentioned**, which
is the correct reason for a zero rather than a failure to fire.

**Jared's rung-1 link stayed put.** One pair, `wf-s4 r1q35`, disposition `Identified`, unmoved.
It did not drift to `Held`, which is the MUST-NOT-MOVE half of DELTA-1.

## 3 · CARDS AND COVERAGE

**One card was reinforced rather than duplicated — on s4, not s5.**

| Run | Created | Reinforced | Unchanged |
|---|---|---|---|
| s3 | 10 | 0 | 0 |
| s4 | 6 | **1** | 10 |
| s5 | 12 | 0 | 16 |

**28 cards on the deal: Goal 6, Initiative 7, Obstacle 11, Pressure 4.** Zero duplicates retired,
zero contradictions flagged. The 16 unchanged on s5 is the dedup holding across three calls: s3's
and s4's cards were recognised and left alone rather than re-created.

**Coverage did NOT move again, and it cannot.** Everyone present on two or more calls reached
`Multiple contacts` at s4 and that is the derivable ceiling — **`In-depth` is deliberately
underivable**, because arithmetic cannot claim depth. Priya arrived at `Brief contact` on her
first appearance; Jared stayed `Brief contact` having appeared once.

**So coverage moved on s4 and saturated.** The maps-firm-up thesis is carried by a dimension with
a two-step range, and after two calls it has nothing left to say.

## 4 · THE JOIN'S DML AGAINST `C + 9`

**39 of 150. Predicted 39.** 30 upheld candidates + 9 = 39, measured **39 — exact.**

| | s3 (old writer) | s4 | s5 |
|---|---|---|---|
| join DML | **133 / 150** | 35 / 150 | **39 / 150** |
| join SOQL | 83 / 100 | 69 / 100 | 81 / 100 |
| join wall | 4,186 ms | 2,148 ms | 2,180 ms |
| candidates | 31 | 25 | 30 |

**The model has now predicted three measurements exactly**, once before the change and twice
after. **SOQL at 81 of 100 is the governor to watch next** — it did not fall with the DML and it
is closer to its ceiling than DML now is.

## The ledger

```
s5: 83 located, 83 identified — one for one, for one, HELD
    verified 64: upheld 30, refused 34
deal after three calls: 86 claims, 70 answers, 28 cards, 7 map rows
claim basis: {Transcript = 86}   — still no State, still no Both
```

## Timings · `RCPT-00000006`, 8 stages, 195,888 ms, 5 callouts, WARM

| Stage | Wall ms |
|---|---|
| call 0 | 15,926 (after one failed invocation) |
| read 1 | 39,607 |
| read 2 | 47,370 |
| call 2a deterministic | **272** |
| call 2b model leg | **not fired — zero remainder** |
| **call 3 verify** | **87,883** (5 batches) |
| join | 2,180 |
| projection | 1,979 |
| cards | 2,816 |

**WORST SINGLE CALLOUT: 87,593 ms against the 120,000 ms ceiling — 73%.** Up from s3's 46% and
s4's 60%. **Three runs, monotonically rising, and the next transcript is the one to watch.**

## TWO DEFECTS FOUND, NEITHER FIXED

### The card-face call 400s on a duplicate ref

```
400 Bad Request — output_config.format.schema: Invalid JSON Schema in output format:
['r1q1','r1q2',…,'r1q2',…] has non-unique elements
request_id req_011Ce5Ai58ejU8LLzuK12t1q
```

`r1q2` appears **twice** in the enum the card writer builds. The call was refused, the warning
`Card faces not inferred` was logged, and **the deterministic fallback wrote the faces** — which
is why 12 cards still landed. So s5's card faces are raw verbatim rather than inferred summaries,
and the fifty-fourth stamp's content spec is not met on those twelve.

**The fallback did its job**: no card was lost. But the board carries twelve faces of the wrong
kind, and that is visible to a reader.

### Call 3 needed five invocations

Four produced no output and no verification; the fifth completed all five batches. **I did not
diagnose it and I am not inventing a cause.** Counts reconcile exactly — 30 upheld + 34 refused =
64 — so nothing was lost. This is the second occurrence: s3 needed two invocations, s5 needed
five. **The trend is worth a name even without a diagnosis.**

## retryNotes

1. **Call 0, invocation 1 failed both attempts and stopped the run**; invocation 2 succeeded, DUAL.
   The error text, captured this time: *"Call 0 returned no `opportunity_content_because`. A
   verdict without a reason is a verdict nobody can check."* That is the thirty-fifth stamp's
   second named flake face, fifth instance overall.
2. **Call 3 needed five invocations**, as above, undiagnosed.

**Nothing graded by CODE. No number tuned. s3 and s4 untouched. Stopping here — the answer-key fix
scopes next, with all three runs' evidence in hand.**
