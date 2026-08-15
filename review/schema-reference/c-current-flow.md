# The current flow · one transcript from admission to projection, with the object written at each stage

**Deliverable (c) of the ninety-third stamp's item 3.** This replaces Part II's loop one and
loop two, which are **retired, marked in place in `aao-model-and-flow.md`, and never deleted.**

| | |
|---|---|
| **Tree** | `/Users/thefinalmachine/Downloads/claude`, branch `main`, project `aao-build` |
| **Org** | `00DWD00000DV7iT2AT` — sandbox `aossb2` |
| **Read from** | the classes in the tree and the row counts in the org, 2026-08-15 |

## Why loop one and loop two are retired rather than amended

Part II describes propose-on-loop-one, adjudicate-on-loop-two, span check, blind re-check per
loop. **That pipeline does not run.** The twenty-seventh stamp replaced it on 8 August: the
family sweep became two comprehensive reads, identification stopped being a model job, and the
stages became call 0 / call 1 / call 2 / call 3 / join / projection. Nothing since has restored
the loops.

The loops are kept in place, struck, because the ledger's own convention is that a superseded
statement is marked where it stands with a pointer forward. Deleting them would destroy the
record of what the system used to believe, which is the only way to read the stamps that changed
it.

## The stage table · what runs, in order, and what it writes

**Every row names the object written. A stage that writes nothing says so — that is not a gap,
it is the design.**

| # | Stage | Class | Model call | Object WRITTEN |
|---|---|---|---|---|
| 0 | **Admission** | *(ruled, not built)* | none | **nothing** — a refused call gets no fetch, no Source, no row |
| 1 | **Intake / normalize** | `AAO_IntakeVTT`, `AAO_IntakeECI`, `AAO_NormalForm` | none | nothing yet; produces NF1 bytes |
| 2 | **Source insert** | `AAO_Ingest` → `AAO_SourceTrigger` | none | **`AAO_Source__c`** (immutable; scope key composed in the trigger) |
| 3 | **Participation** | `AAO_Participants`, in the Source after-insert | none | **`AAO_Participant__c`** — one row per Source per person, from the roster |
| 4 | **Call 0 · scope + roster** | `AAO_ResolverCharter` via `AAO_Pass.resolve` | **1** | **nothing.** The verdict is returned, not persisted — the receipt's known gap |
| 5 | **Call 1 · two comprehensive reads** | `AAO_LocateCharter` via `AAO_Pass.locate` → `AAO_Locate` | **2** | **`AAO_Pair__c`** stage `Located` |
| 6 | **Byte verification** | `AAO_SpanVerifier` | none | nothing; a span that does not match its Source's bytes is discarded and counted |
| 7 | **Call 2a · deterministic resolution** | `AAO_Resolve.run` via `AAO_Pass.identifyDeterministic` | **0** | **`AAO_Pair__c`** stage `Identified`; **`AAO_Participant__c`** (mention rows); **`AAO_Flag__c`** type `Identification` |
| 8 | **Call 2b · model leg, remainder only** | `AAO_ResolveRequestCharter` via `AAO_Resolve.requests` | **1, only if a remainder exists** | **`AAO_Pair__c`** `Identified`; **`AAO_Shadow_Person__c`** on a held mention |
| 9 | **Call 3 · blind verify, bucketed** | `AAO_VerifyPairsCharter` via `AAO_Pass.verify` | **1 per bucket** | **`AAO_Pair__c`** verdict fields on the Identified rows |
| 10 | **Join** | `AAO_PairCommit` → `AAO_Commit` → `AAO_Accumulate` | none | **`AAO_Claim__c`** (insert-only), **`AAO_Candidate__c`**, **`AAO_Answer__c`** (upsert), **`AAO_Criterion__c`** |
| 11 | **Create leg** | `AAO_Identity` → `AAO_CreatedRows` | none | `Contact` (behind the toggle and the bar); **`AAO_Created_Row__c`** |
| 12 | **Flags** | `AAO_Flags`, `AAO_Cardinality`, `AAO_MissingRelation`, `AAO_Identification` | none | **`AAO_Flag__c`** |
| 13 | **Projection** | `AAO_Project` | none | **`ALTF__Contact_Map_Details__c`**, **`ALTF__Decision_Criteria__c`** — see deliverable (d) |
| 14 | **Cards** | `AAO_Cards`, face by `AAO_CardFace` | **1 for the face** | **`ALTF__Insight_Card__c`**, `ALTF__Insight_Card_Section__c`, `ALTF__Insight_Card_Contact__c` |
| — | **Telemetry, every stage** | `AAO_Receipt` | none | **`AAO_Run_Receipt__c`** — one row per Source per pass, merged a stage at a time |

**The model-call arithmetic on a clean transcript: call 0, two reads, zero resolution calls,
one or two verify buckets, one card face. Four to six calls.** The count follows unresolved
people, never pairs and never headcount — the twenty-seventh stamp's own prediction, and the
deterministic stage wired on 15 August is what finally makes the zero reachable.

## The three findings, answered

### 1 · `AAO_Pair__c` — 371 records, 29 fields, and the reason it is the least documented object

It is the atomic unit and it carries **two physical shapes in one table**, which is why one
paragraph could never describe it. Measured in the org today:

```
PAIRS BY STAGE:        {Located = 236, Identified = 135}
PAIRS BY DISPOSITION:  {Identified = 134, Ambiguous = 1}
```

**A `Located` pair is call 1's proposal.** It carries the verbatim (`AAO_Answer_Text__c`), the
byte range (`AAO_Start_Offset__c` / `AAO_End_Offset__c`), the occurrence index, the voiced
meaning, the coverage label, the speaker key, and — where the subject is not the speaker — the
designator and its introducing quote. **It is forbidden the person.**

**An `Identified` pair is call 2's disposition.** It points back at its parent through
`AAO_Located_Pair__c`, carries exactly one `AAO_Disposition__c`, and carries `AAO_Person__c`
if and only if that disposition is `Identified`. **It is forbidden the located-only fields.**

The prohibition runs both ways and is enforced by 17 `addError` guards in
`AAO_PairTriggerHandler` — more than any other object in the system. `AAO_Disposition__c`'s
five values are `Identified`, `None`, `Ambiguous`, `Merged`, `Held`.

**The one `Ambiguous` row in the org is mine**, from the 15 August wiring proof on a throwaway
account. It is the only disposition other than `Identified` this org has ever produced, which
is itself a finding: **134 of 135 dispositions are the happy path, so every refusal branch is
essentially unexercised on real data.**

### 2 · `AAO_Shadow_Person__c` — 21 fields, 0 records, and the Wells Fargo read is its first exercise ever

**Confirmed: zero rows.** Not zero recently — zero ever. The object carries the participation
proof's admissible sibling: designator as heard, Source, offsets, quote, identity provenance,
anchors, anchor count, and the three-branch shadow key.

This compounds a disclosure already on the record at the eighty-eighth stamp's item 4: **no
fixture in the suite exercises the model leg's mention branch.** So the branch has zero test
coverage *and* zero production rows, and DELTA-1 does double duty — it grades the retirement and
is simultaneously the retirement's only test.

**What follows for the read, stated so it is not discovered mid-run:** the first row this object
ever holds will be written during a graded run. If it comes back wrong, the divergence is a
finding about a path nothing has ever walked, not a regression from a known-good state. There
is no known-good state to regress from.

### 3 · `AAO_Claim_Basis__c` — 0 rows against 100 claims. **The chain is not a link short; the link moved.**

Measured, and this is the whole answer:

```
CLAIMS BY BASIS:        {Transcript = 100}
claims carrying spans:  100 / 100
claims carrying source: 100 / 100
claim_basis rows:       0
```

**Every claim in this org is `Basis = Transcript`, and a transcript-basis claim records its
basis on itself**: `AAO_Spans__c` (byte-located verbatim), `AAO_Source__c`, and
`AAO_Evidence_Contract__c`. Nothing is missing. The receipt is complete and walkable — the Run
Inspector proves it end to end, 45 of 45 offsets resolving exactly.

**`AAO_Claim_Basis__c` exists for the other basis kind.** Its columns are `AAO_Cited_Map_Row__c`,
`AAO_Cited_Answer__c`, `AAO_Cited_Line_Item__c`, `AAO_Cited_Source__c`, `AAO_Cited_Row_Deleted__c`
and `AAO_Snapshot__c` — it cites **pre-existing org rows** and tombstones them if they are later
deleted. That is `Basis = State`, and **zero of one hundred claims are State or Both.**

**And the §P8 pipeline does not reference it at all.** Grepped across
`AAO_Pass`, `AAO_Resolve`, `AAO_PairCommit`, `AAO_Commit`, `AAO_Accumulate`, `AAO_Project`,
`AAO_Cards`: **zero occurrences in all seven.** Its writers are `AAO_Gate1`, `AAO_Discovery`,
`AAO_Demo` and `AAO_PipelineViewController` — the gate-1 and EBV era, plus a UI controller.

**So the honest verdict is neither of the two design offered.** Claims do not record their basis
"another way" as a substitute, and the chain is not short. **The junction serves a basis kind
the current corpus has never produced, and the current pipeline has no writer for it.**

**The latent gap, named because it will bite exactly once:** the first `State`-basis claim on
the §P8 path would have nowhere to record what it cited or whether that row still exists. The
route classes that write State claims (`AAO_SolutionRoute`, `AAO_MapRoute`) are not on the §P8
path either, so nothing is broken today — but "nothing is broken today" is the same sentence
that preceded the anchor-field day, and it is written down here rather than rediscovered.

## What no stage writes, and why that is deliberate

- **Call 0 persists nothing.** Its verdict belongs to a run, not a Source, and the receipt is
  its home. Recorded as a gap at the twenty-ninth stamp and still open.
- **Abstention writes nothing.** A proposition the evidence does not bear on produces no row.
  This is why the Run Receipt exists at all: with no abstention rows, a transcript with zero
  claims is otherwise indistinguishable between never-read and read-and-nothing-established.
- **A refused admission writes nothing.** No fetch, no Source, no normalization.
- **Silence stays silence at projection.** An empty established set writes no value and keeps
  its refusal note.

## Retirement marker

`aao-model-and-flow.md` Part II now carries a retirement block at the head of §1, pointing here.
Loop one, loop two, the seventeen-stage write path and both diagrams stand where they are,
unedited, marked superseded. The fold into Model & Flow proper is design's, per the ninety-third
stamp's item 4.
