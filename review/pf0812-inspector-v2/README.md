# Run Inspector v2 · the sixty-sixth stamp's queue · 12 August 2026

**Authorizing bytes, quoted per the receipt rule, from the sixty-sixth stamp:** *"The spec ships
beside this ledger as `aao-inspector-v2-spec-draft.md`, with his three answers folded in; it is
BUILDABLE LAW by this stamp, not a draft awaiting a yes."* And its item 7's standing law: *"the
stretch does not report done until the component has been OPENED ON THE PAGE and what was seen is
reported."*

Suite **461 tests, 460 pass**; the single failure is the standing org-resident non-AAO
`ConvertToOpportunityTest`. Every AAO test green. Twelve of those are this component's own, up from
three.

---

## 1 · What was built, item by item against the stamp

| Stamp item | Built | Where |
|---|---|---|
| 1 · Row titles carry words, family plus established value | yes | `AAO_RunInspector.titleFor` |
| 1 · Full proposition name on hover and in the detail | yes | row `title=` attribute, `aaoTraceDetail` |
| 1 · Refused row names the value proposed and declined | yes | `AAO_RunInspector.establishedValue` |
| 1 · No short name means the code shows AND is reported | yes | `RunView.defects` |
| 2 · Rows group by person, collapsible, with counts | yes | `PersonGroup`, `sortedGroups` |
| 3 · Detail opens inline under its own row, one at a time | yes | `aaoTraceDetail`, `selectedId` |
| 4 · Refusals collapsed, count always visible | yes | `refusedLabel`, `refusedTotal`, the stepper |
| 5 · Run-level stepper in pipeline order with counts | yes | `drawPipeline` |
| 5 · Performance behind a toggle | **built, and it reports there is nothing to show** | see §4 |
| 5 · Establishment-level numbered path, dead steps greyed with reasons | yes | `walk`, `PathStep` |
| 6 · Internal speakers marked with the reason nothing followed | yes | `INTERNAL_REASON` |
| 7 · No writes, no transcript viewer, no search, no Flags | held | read-only asserted by test |

**The 45-of-45 offset proof stands on the new surface**, re-measured this session against every
trace the page renders: `substring(startOffset, endOffset)` on the frozen transcript equals the
quote carried, 45 of 45, 0 mismatches.

---

## 2 · What the browser showed

Opened on the Project Farma Opportunity page, run `pf0811-goal` default-selected. **Zero console
errors on a clean load**, and the console capture was itself proven live (a deliberate
`console.error` was emitted and read back), so the zero is a measurement rather than a silence.

**The stepper, drawn left to right:**

```
1 call ›  60 ›  60 ›  24 upheld / 21 refused ›  23 ›  13 ›  3 map rows, 12 cards
Source    Words People       Verified            Claims  Answers   Projected
read      located identified                     written ledgered
```

The Verified step's meaning line reads *"What the blind verifier let stand, beside what it
declined. The refusals are where trust is earned."* — the sixty-third stamp's wording survives the
default-to-hidden, on the surface a reader sees before expanding anything, and a test asserts it.

**Five person groups, in order, externals first and our own seller last:**

| Person | Count | Marked |
|---|---|---|
| Adam Pfeiffer | 16 established, 9 refused | |
| Dan Lewis | 5 established, 3 refused | |
| Kayla Stanley | 1 established, 5 refused | |
| Rich | 0 established, 1 refused | *(appears on refusals alone, as ruled)* |
| Jennae Jizdeortega | 2 established, 3 refused | **internal** |

24 rows visible, 21 refusals collapsed behind five controls reading `9 refused — show`,
`3 refused — show`, `5 refused — show`, `1 refused — show`, `3 refused — show`.

**Titles, read off the rendered page** — no contract code reaches a title, and the defect channel
is empty because every live contract carries a plain-language short name:

```
Adam Pfeiffer · Buyer Role: Evaluator
Adam Pfeiffer · Support: Supporter
Adam Pfeiffer · Criterion: Bilateral NDA before sharing
Adam Pfeiffer · Obstacle
Kayla Stanley · Political Status: Political Structure   (refused)
```

**Interactions exercised by clicking the real DOM, not by setting state:** opening a second row
closes the first (one detail node in the tree, never two); clicking an open row closes it (zero);
collapsing a person hides their rows while the header keeps its count; the refused control expands
in place and its label flips to `— hide`.

---

## 3 · The walk-back, opened on screen

Dan Lewis · Obstacle, opened under its own row:

> **Problems · Obstacle** · `AAO_PB_OBST`
> *"No, I think that's a big one is just being like an orchestration and being organized, streamline of information so we know what's going on."*
> bytes 5473-5612 · `projectfarma/2026-07-30-nf1`
> **VERIFIER** The words describe orchestration and organization of information as something needed, framing it as a task or situation that stands in the way of knowing what is going on.

| # | Step | What happened |
|---|---|---|
| 1 | Read the call | `projectfarma/2026-07-30-nf1`, 30 July 2026 |
| 2 | Found the words | bytes 5473-5612 of the frozen transcript, quoted verbatim |
| 3 | Identified the speaker | Dan Lewis — Deterministic: the words sit in Dan Lewis's turn and are about their own speaker. |
| 4 | Asked the question | Did this person, in their own words, describe a task, situation or process that stands in the way of something they are trying to do? |
| 5 | Verified blind | Upheld — *(the verifier's reason in full)* |
| 6 | Wrote the claim | Established as Obstacle |
| 7 | Ledgered the answer | Answer stands UNVERIFIED |
| 8 | Projected | An insight card on the board: "Need organized information flow" |

The card at step 8 is found by the **card writer's own layer-1 identity key** (type plus normalised
verbatim), so the page reads the identity the writer wrote rather than guessing at a match.

---

## 4 · The performance toggle reports a gap rather than a number

The stamp asks for per-stage wall time and governor consumption behind a toggle, *"showing only
numbers the run actually journalled, nothing recomputed on the page"*.

**Nothing in the org journals them.** The run receipt object was CONFIRMED at the twenty-ninth
stamp (*"ONE thin object, one row per Source per pass"*, carrying *"per-stage wall milliseconds…
calls made, split events, cold or warm, charter and normalizer versions"*) and was never built;
per-stage timings live only in each run's written report under `review/`.

The toggle therefore renders and says exactly that. Deriving a stage timing from record timestamps
would be a number recomputed on the page, which the stamp forbids, so it is not done. **The receipt
object is parked below with options and costs.**

---

## 5 · A defect the surface caught in its own first draft

The internal-speaker reason first read *"the join refuses them and no card or map row follows"*.
The page then rendered Jennae's GOAL establishment with its path intact:

```
6  Wrote the claim      Established as Goal
7  Ledgered the answer  Answer stands TRUE
8  Projected            Nothing projected: a seller's words never establish a buyer's condition…
```

**The join plainly wrote both the claim and the answer.** On the Problems family the internal
refusal happens at the CARD WRITER (`AAO_Cards`), downstream of both, not at the join. The reason
now names the OUTCOME, which is measured, and not the stage, which was inferred and wrong; a test
asserts the string never names the join again. This is the drawn path doing exactly the job it was
built for, against its own author, within an hour of existing.

---

## 6 · Observations for design, not claimed as defects

**(a) A card stands on an establishment whose ANSWER reads UNVERIFIED.** Dan's Obstacle above: claim
Established, answer UNVERIFIED, card on the board. That is the forty-ninth stamp's grain ruling
working as built — the card writer reads upheld PAIRS, not answers, and the cost was named then
(*"a pair is one read's proposal… the CLAIM is still the receipt"*). The Inspector now makes the
tension visible for the first time. Nothing is changed on it.

**(b) The older runs render clean and read honestly.** `pf0808-i1` (19 upheld / 11 refused) and
`pf0808-h1` (16 upheld / 12 refused) both render with every title in words and zero defects. Both
show **Claims written 0 / Answers ledgered 0**, because their claims were removed when the map was
purged at the forty-first stamp; their traces grey at step 6 with *"No claim is linked to this
pair."* That is the surface reporting the rows rather than reconstructing a history the org no
longer holds.

---

## 7 · Rows, timings, governors, retryNotes

No model calls were made this session: the Inspector is a read-only surface over standing rows and
its build needs no pass. `inspect()` runs **5 SOQL** per view (located count, identified list, card
list, map-row count, card count) regardless of how many people or traces come back, since every
claim, answer, contract and participant field travels on the identified query's relationship
traversal. `runsFor()` runs **1**. No DML anywhere, asserted by test. **retryNotes: none.**

Verified against the resident runs (`AAO_RunInspector.inspect` executed from anonymous Apex):

| Run | People | Upheld | Refused | Titles in words | Path steps | Defects |
|---|---|---|---|---|---|---|
| `pf0811-goal` | 5 | 24 | 21 | 45 / 45 | 360 | 0 |
| `pf0808-i1` | 5 | 19 | 11 | 30 / 30 | 240 | 0 |
| `pf0808-h1` | 5 | 16 | 12 | 28 / 28 | 224 | 0 |

---

## 8 · Parked for design · THE RUN RECEIPT OBJECT, now with a second consumer

The twenty-ninth stamp confirmed it and left the build timing to CODE (*"Not needed tonight… Build
it with or immediately after the rebuild, your call"*); it was never built. The sixty-sixth stamp's
performance toggle is the second thing that now wants it, beside the did-we-read-it record the
original ruling named. Options with costs, none chosen and none built:

- **(a) Build it as the twenty-ninth stamp specced it** — one thin object, one row per Source per
  pass, carrying per-stage wall milliseconds, calls made, split events, COLD/WARM, charter and
  normalizer versions. Cost: one object against the enterprise install budget the same stamp made
  law, and a write on the pass's hot path. Benefit: the toggle fills, the did-we-read-it record
  exists, and a run report stops being the only place performance lives.
- **(b) Journal per-stage numbers onto the existing `AAO_Source__c` row** — zero new objects, but the
  grain is wrong (a Source is read by many passes) and it would need a JSON blob field, which is a
  ledger nobody can query.
- **(c) Leave it unbuilt and let the toggle keep reporting the gap** — zero cost, and the Inspector
  cannot stand in for the run report during testing, which was the stated reason for the toggle.

Design's own note at the twenty-ninth stamp still applies unchanged: *"every new object justifies
itself against the enterprise install budget"*.
