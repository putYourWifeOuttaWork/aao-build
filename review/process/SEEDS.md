# The Process seeds · built, run, verified · 123rd stamp item 2

*"SEEDS UNGATED - CODE builds now, per the proposal v0.4 with the 122nd's two rulings."*

| | |
|---|---|
| **Tree / org** | `/Users/thefinalmachine/Downloads/claude` on `main` · `00DWD00000DV7iT2AT` |
| **Spec** | `docs/aao-process-charter-proposal.md` v0.4 §4 and §5, read from the tree |
| **Graded run** | **NONE.** Seeds are org configuration, not a pass, so no row export or stage timings are owed. |

## What stands in the org, read back rather than reported from the return value

```
assessment questions   15        sales process        1
by-stage markers       15        stages               5
                                 process stages       5
                                 global qualifiers   14
                                 stage junctions     15
plan-type code string  179 of the 255-character ceiling
```

**Untouched, checked because a seed that quietly edits an org is not a seed:** the 10 plan types
already configured, the 6 assessment questions `AAO_Discovery` authored, every other sales process
(there are none), and Wells Fargo at 90 claims.

**Idempotent, proved by running it three times:** the second and third runs insert nothing and
re-author fifteen in place. It is idempotent **by read-before-write** - it queries the standing
rows for its key set and branches before composing any DML - rather than by catching a duplicate,
which is the hundred-sixteenth stamp's law and not a convenience.

## THE SET IS FIFTEEN, AND T3'S SUBSTANCE IS A QUALIFIER ON TWO LATE STAGES

The grading is built as ruled: N2 reworded and opened to the human-established path, N4 reworded
to alignment confirmed by the customer, T3 dropped and moved. **T3 is ONE global qualifier linked
to TWO stages** - `Mutual close planning on Propose + Commit`, read back from the org - because
"the late stages" is plural and the junction is what that plural is for. Two copies of the
qualifier would have been the duplicate-identity defect on a new object.

**Every question carries elements, and that is a requirement rather than a nicety.** The eightieth
stamp refuses a zero-element contract AT MINT, so a question seeded without them would be written
into the org and then lawfully refused - a seed that quietly does not work. Help is the only field
on the vendor's question that can hold them.

## THE ONE INSTRUCTION I COULD NOT CARRY OUT

The hundred-twenty-second ruled the eight required forecasting fields **"COPY VERBATIM FROM THE
PROD CAPTURE"**, reasoning that inventing them would be tuning a surface we do not understand and
that *"the capture already carries working values."*

**It does not.** `aao-projection-surface-spm-om-v0_1.md` carries field definitions, help text, the
five process names with version numbers, and **exactly one sample row** - the stage-qualifier
junction. No forecasting value appears anywhere in it. **The same is true of the stage structure**
the spec says to adapt from "New Business (Direct)": the capture names the process and its version
and carries none of its stages. And design's production connection is lost (120th, item 5), so
neither can be fetched now.

**So every number is sourced or flagged, at the line that uses it:**

| field | value | source |
|---|---|---|
| `Final_Stage_Probability` | 100 | vendor help text, captured: *"This is usually 100%"* |
| `Closure_Duration` | 0 | vendor help text: *"This can be zero."* |
| `Pebble_Value` | 25,000 | vendor help text: *"one quarter of the average deal size"* |
| `Rock_Value` | 400,000 | vendor help text: *"four times the average deal size"* |
| `Average_Deal_Size` | 100,000 | ours, and the only input the two above derive from |
| `Pebble_Percentage` / `Rock_Percentage` | 75 / 75 | **NO GUIDANCE.** See below. |
| `Threshold` | 75 | **NO GUIDANCE** beyond what it is for |
| stage `Amber` / `Green` | half the bar / the bar | **NO GUIDANCE** for the RAG thresholds |

That is quoting rather than inventing, and it is the closest lawful thing to the ruling's intent.
**Design should overrule any flagged line the moment real numbers exist; each is a one-word edit.**

### The org corrected my first reading, and the correction is the interesting part

The first attempt mirrored the vendor's own quarter-and-four-times language into the percent
fields as 25 and 400. The org threw:

```
FIELD_CUSTOM_VALIDATION_EXCEPTION, Only 0-100% is valid: [ALTF__Rock_Percentage__c]
```

**So they are genuine percentages, not multipliers, and the value fields' guidance does not carry
across to them** - the schema teaching us its own law again, and a reading that looked obvious
being wrong. With no guidance and a hard bound, both now sit at the process threshold, which is
the one stance a seed can defend in a sentence: **deal size introduces no differentiation.** A
seed that invented a forecasting policy it could not explain would be doing the exact thing the
122nd ruled against.

## THE TWO GATES ARE KEPT APART IN THE ROWS, NOT ONLY IN THE PROSE

The 122nd's item 2 distinguishes them and the seed builds them as two things:

- **`ALTF__Qualification__c`** on each process stage gates **stage movement** on qualifier
  completion. The vendor's own job. Seeded ascending: 20 / 40 / 60 / 75 / 90.
- **`AAO_Assessment_Stage__mdt.AAO_By_Stage__c`** gates **red-flag timing** on assessment
  questions - when *unknown* becomes a deal-killer. Ours. B1/A1/N1/T1 at stage 2, the deeper
  items at 3, and T4 - the only decision-maker-confirmed question - at 4.

And `ALTF__Mandatory__c` on the vendor question is deliberately left **false** on all fifteen:
every one is a deal-killer by Matthew's ruling, but "mandatory" there means the vendor blocks
stage movement on it, which is the other gate's job.

**A missing marker is silence, never stage zero.** `byStageFor` returns null for an unknown code,
and a null must never be read as zero - that would red every unanswered question on every deal
from stage one, which is the opposite of what absence-is-not-evidence means. Tested.

## A LESSON RE-LEARNED IN ONE RUN, WHICH IS IT BEING CHEAP THE SECOND TIME

The first test run failed three ways with one cause: `LIKE 'AAO\_SEED%'` over our own keys.
`AAO_Discovery` already paid for this and wrote it down - *"the underscore is a SOQL"* wildcard, so
a prefix full of underscores matches loosely in one direction and not at all in the other. **A key
set is exact; a LIKE over our own keys is a guess.** Every query in the seed and its tests now asks
by name, and `questionCodes()` and `seedKeys()` exist so nothing has to pattern-match for them.

## WHAT IS DELIBERATELY NOT BUILT

- **No vendor answer row is written and no wrapper is manufactured**, per the 122nd's item 3.
  Nine of twenty-five deals carry an `ALTF__Opportunity__c` wrapper and the STAGE deals do not;
  Process lands on our ledger regardless, and vendor projection is a conditional.
- **The machine-readable mapping from qualifier text to computable predicate is §2's
  configuration and belongs to the Process build**, not to the seed. Each qualifier's plane is
  written into its tip as prose for a human, and `ALTF__UI_Readonly__c` is set true on the
  computed ones because the vendor's own help text says a Smart Qualifier *"cannot be set by a
  user... it is anticipated that these qualifiers will be set by other means"* - which is exactly
  what a computed-plane qualifier is. **A tip is not a predicate**, and nothing should later read
  it as one.
- **Every stage carries at least one COMPUTED-plane and one EVIDENCE-plane qualifier**, so the
  catalog exercises both on its first run rather than proving half the design and reading as
  proving all of it. Tested per stage.
- **The seed never makes itself the org's default process.** A seed that did would change how
  every deal in the org behaves.

## Suite

**547 run, 546 passing**, the only failure the standing non-AAO `ConvertToOpportunityTest`.
Nothing tuned against any expectation table; the demo deal and Wells Fargo untouched.
