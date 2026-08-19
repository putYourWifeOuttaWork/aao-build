# The twelve contracts no pass can see

**Tree** `/Users/thefinalmachine/Downloads/claude` (`main`) · **Org** `00DWD00000DV7iT2AT`, sandbox `aossb2` · authorized by the hundred-twenty-eighth stamp's item 8, which places it behind (b). Rows in `review/process/step-b/discovered-twelve.csv`.

> *"Report what those twelve rows are, then either they join a declared set at the next generation or they retire in place with their reason. A contract that looks live and no pass can see is a third state and this project does not leave those standing."*

## What they are

**Twelve rows, six propositions, two generations of one 31 July experiment.** They are `AAO_Discovery`'s own output: the cold-start build that proved rubric discovery could mint contracts from an org's assessment questions rather than from our seventeen hand-authored ones.

| code | short | route | elements | mini-0.1.0 | discovered-v1 |
|---|---|---|---|---|---|
| AAO_T1 | Budget Confirmed | E | 3 Authored | Ratified | Derived |
| AAO_T2 | Decision Team Identified | P | 1 Authored | Ratified | Derived |
| AAO_T3 | Competitive Position Understood | C | 2 Authored | Ratified | Derived |
| AAO_T4 | Success Criteria Captured Per Decision Maker | P / C | 2 Authored | Ratified | Derived |
| AAO_T5 | Implementation Timeline Agreed | 1–2 Inferred_Pending | | Awaiting_Ratification | Awaiting_Ratification |
| AAO_T6 | Reference Customer Discussed | 2 Authored | | Ratified | Derived |

The `mini-0.1.0` set was minted 31 July 13:46; `discovered-v1` seven hours later at 20:57. **They are the same six questions minted twice**, and the second generation differs in more than its version string: T4's route moved C to P and T6's moved E to C, so the two generations disagree about which route reads them.

**The vendor question records they were minted from are still in the org** (`a0aWD00000Qamju…` through `…Qamjz`, `ALTF__Assessment_Question__c`, AltifyId `AAO_T1`–`AAO_T6`), so nothing is orphaned. The contracts point at live rubric rows.

## What rests on them

**9 claims and 7 answers**, spread across six deals: `AAO Discovery - Derived Contracts`, `AAO Demo - Tungsten Rehearsal`, `AAO Demo - Tungsten Rehearsal (seller said it)`, `AAO Gate1 - Model Round Two`, `AAO Gate1 - Blind Reader`, and - the one that matters - **`AAO DEMO STAGE B`**, which carries two live TRUE answers on `AAO_T3` at `mini-0.1.0`.

STAGE B is the deal design verified in-org at the hundred-eighteenth stamp as holding the ratified supersession end state. So a retirement here is not free of consequence: it would touch a deal the record cites as a standing specimen.

## Why no pass can see them

Neither version string appears in any declared set. `AAO_RecallGate.declaredSet()` selects on `AAO_Rubric_Version__c = AAO_PassContracts.RUBRIC_VERSION` (`people-p8-v1`), and these carry `discovered-v1` and `mini-0.1.0`. **Also: every one of the twelve has `AAO_Family__c` BLANK and `AAO_Charter_Designation__c` blank**, so even if the version matched, `familyOf` would throw on `AAO_T1` - it belongs to no family the code ladder knows and declares none.

Design's reading is exact and worth restating: this is **a silent drop at the generation layer rather than at the row layer**, and it is the more dangerous of the two because nothing about it looks wrong. The rows read `Ratified` and `Derived`. Their state field says live. No query anybody would think to run says otherwise.

## The disposition, and it is design's

Design ruled the shape - *"either they join a declared set at the next generation or they retire in place with their reason"* - and left the choice. What (b) can contribute is the cost of each, measured:

- **Joining a declared set** is not a version bump alone. Each would need `AAO_Family__c` set (they declare none), the T4/T6 route disagreement resolved between the two generations, and T5's `Inferred_Pending` elements ratified or left `Awaiting_Ratification`. And the two generations would have to be reconciled to one, since minting both into a declared set would put two live contracts on one rubric question - which is the supersession machinery's job, not a widen's.
- **Retiring in place** costs the 9 claims and 7 answers their standing, including STAGE B's two live TRUE rows. Retirement is the lawful path and nothing is deleted, but it touches a deal the hundred-eighteenth stamp cites.
- **A third reading, offered because the rows argue for it:** these were an EXPERIMENT's output, not a customer's rubric. The six vendor questions behind them were seeded by us on 31 July to give discovery something to discover. If they retire, they retire as *"an experiment's output, kept as the record of the first discovered mint and never live"* - which is a truer reason than *"superseded"* and leaves the discovery-path evidence readable.

**Recorded lean, not acted on:** retire in place with the experiment's reason. Nothing built.
