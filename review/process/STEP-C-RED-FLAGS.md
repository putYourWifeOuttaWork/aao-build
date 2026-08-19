# Process step (c) · the red-flag family, first populated

**Tree** `/Users/thefinalmachine/Downloads/claude` (`main`) · **Org** `00DWD00000DV7iT2AT`, sandbox `aossb2` · authorized by the hundred-twenty-sixth stamp's item 3(c) and the hundred-twenty-ninth's item 9, answering the hundred-twenty-eighth's item 7.

> *"(c) The red-flag family, first populated. VOICED NO flags immediately at any stage; NEVER-ESTABLISHED flags only past its BY-STAGE marker (null marker never flags); cleared by evidence establishing the affirmative or human override; no dismiss exists."*

## 1 · THE TWO FIELD QUESTIONS, answered from the org before anything was populated

### `AAO_Gating__c` · which field drives the red-flag family

**Both do, and they drive different halves. `AAO_Gating__c` was FALSE on all fifteen, that value was mine, and it was wrong.**

The red-flag family is not new. `AAO_Flags` has existed since session 2: it raises a Methodological red for every contract carrying `AAO_Gating__c = true`, stamps `AAO_Raised_At__c` at DEAL CREATION so age means *how long has this deal stood without an answer*, clears on an established TRUE, and worsens the cause to `Established_False` where evidence establishes the negative. It is wired: `AAO_Commit` calls `reconcile` on every commit, `AAO_Demo` and `AAO_Discovery` call `raiseFor`.

So the family already carries the exact cause vocabulary the hundred-twentieth ruled: `Established_False` is VOICED NO, `Gating_Unmet` is NEVER ESTABLISHED, cleared is AFFIRMED. **What it lacked is the clock**, and that is what the by-stage marker supplies.

The answer, then: **`AAO_Gating__c` says THIS QUESTION IS A DEAL-KILLER TEST AT ALL**, which is what raises the standing flag at deal creation. **The BY-STAGE marker says WHEN AN UNANSWERED ONE READS RED.** One fact about the question, one about the clock, neither doing the other's work. That is the hundred-twenty-second's two-gates-two-jobs shape one level in, and it is why the design has room for both without one being a second representation of the other.

**And my `false` answered the wrong question.** The comment I left at (a) reasoned about the vendor's `Mandatory` (which gates stage movement, and is theirs) and concluded ours should be false to avoid copying theirs. But `AAO_Gating__c` is not the vendor's field wearing our name. Setting it false meant **fifteen deal-killer questions raised no deal-killer flags at all.** The inversion law settles it in one line: an assessment question IS a deal-killer test. All fifteen, by construction. Corrected in the seed and on the standing rows.

Neither field is in the contract's FROZEN set, so this is an update in place rather than a supersession: **the question's WORDS did not change, only the gates we apply to it.**

### `AAO_Speaker_Requirement__c` · which mechanism refuses a seller-voiced Process claim

**None does. Design's item 7 named the join's internal-domain gate; the gate cannot reach a single one of the fifteen, and the refusal design attributed to it came from somewhere else.** Both halves measured rather than reasoned.

The 128th wrote: *"the A2 refusal on Sam Ruiz came from the internal-domain gate at the join rather than from the speaker requirement. That proves the gate reached that one row; it does not prove it reaches all fifteen."* Read from the org, the pair says otherwise:

```
r1q19  Identified  AAO_BANT_A2  Sam Ruiz  sam.ruiz@altify.com  Refused
  "The words reference Dana pulling someone together but do not establish that the
   decision maker participated directly in a conversation with us."
```

That is **call 3 refusing on the words**, on content, not the join refusing on a domain. And the gate design believed reached it cannot reach it at all:

```apex
if (!PERSON_SUBJECT_DIMENSIONS.contains(AAO_P8Codes.dimensionOf(code)) || ...)
```

`PERSON_SUBJECT_DIMENSIONS` holds Support, Political and Buyer Role. Tried from the runtime: `dimensionOf('AAO_BANT_A2')` returns **null**. A Process code is in no §P8 dimension, so the test fails, the pair survives, and **the internal-subject gate reaches none of the fifteen.**

So instrument reach was exactly the right question and the answer is worse than the question feared: not *does it reach all fifteen* but *it reaches none*, and the one refusal that looked like proof of reach was luck. **A seller saying "we have budget for this" would have established B1 with the seller as its subject** - the Wendy failure's shape on a new family.

**Do the fifteen want `Buyer_Side` on their face? Thirteen of them, and their own element text is what says so.** This is the (b) finding turned around: thirteen name the customer's mouth as a conjunct, and a question that requires the customer's words should refuse words that are not theirs at the gate rather than hope the verifier notices.

| | requirement | why |
|---|---|---|
| B1 B2 B3 B4 A1 A3 A4 N1 N3 N4 T1 T4 | `Buyer_Side` | their own elements name the customer's mouth ("the customer states", "it is the customer who voices it", "per the customer's words", "the endorsement is the decision maker's specifically") |
| A2 | `Buyer_Side` | its elements name no mouth, but the 128th's own reading does: *a seller cannot establish that a decision maker is engaged*. And the evidence plane no longer needs to, because the computed plane answers A2 from the participant row |
| **N2** | `Any_Participant` | **the 123rd's deliberate exception**: the one question whose proof does not require the customer's mouth, opened to estimates, user notes and impacts not voiced by the customer |
| **T2** | `Any_Participant` | **left open and reported rather than swept**: its text names no mouth at all ("Is the date tied to something real that happens with or without us?"), so nothing in the question says whose words answer it. Design's to rule |

**And the requirement is CONFIGURATION, not code.** Altify carries no speaker requirement anywhere, so a discovered question cannot state one and Apex cannot know it. It now sits on `AAO_Assessment_Stage__mdt.AAO_Speaker_Requirement__c` beside the by-stage marker and the computed predicate: same grain, same key, org-overridable, falling back to `Any_Participant` where an org states nothing.

**One gap named while I was in it, not fixed:** the composed rubric stamp fingerprints the declared set's contract KEYS, and a key is the question record id plus a hash of its proposition and guidance TEXT. So changing a speaker requirement or a gating flag changes what establishes and **the stamp does not move.** The two-halves law says a version string covers every input that can change the output it stamps; these two inputs are outside it. Not fixed here, because the composer is frozen by law and widening it is design's ruling, not mine.

## 2 · THE DEFECT (c) FOUND, and it would have been silent and exactly backwards

**A voiced no would have CLEARED the deal-killer it proves.**

`AAO_Flags.reconcile` read the answer's VERDICT alone. Under the inversion law a DENIED answer stands at **verdict TRUE** - the establishment is real, cited to the customer's own affirmative words about the negative, and true-or-nothing is unbreached (the 128th's item 3, and the 129th ratified it in the rows). So the moment `AAO_Gating__c` went true on the fifteen, a customer saying *"there is no budget allocated for this, not in this fiscal year"* would have cleared the budget deal-killer, on a TRUE, for a defensible reason.

**The one condition the flag exists to surface would have vanished at the moment it was proven.**

It was latent rather than live only because gating was false on all fifteen - the second wrong value covering the first. Found by reading the two mechanisms side by side before populating, which is what item 7 asked for.

Two further things fell out of the same read:

- **`reconcile` took `LIMIT 1` with no ordering.** Lawful while every gating contract had at most one answer per deal, which was true of the seventeen. **Process breaks it:** fifteen questions land one answer PER PERSON, so a deal-level flag now faces several answers about one question and an arbitrary pick would clear a deal-killer on whichever row sorted first. Now reads every standing answer.
- **The tiebreak was already ruled before the case existed.** A voiced no *"flags red immediately at any stage"*, so **DENIED outranks AFFIRMED**: one person's yes does not undo another's no. Where both stand, the red stands and the disagreement is real signal - the contention family is where that belongs and it is not built here.

## 3 · What was built

**The redness of a flag is a READ, and the row exists from day one either way.** Two reasons, and the second is load-bearing. `AAO_Raised_At__c` is deal creation, so creating rows late would destroy what age means. And **a stage can move BACKWARDS**; a design that created rows on the way past would have to delete them on the way back, and this system does not delete. So nothing is written when a stage moves, and `AAO_Flags.redsOn()` answers at the moment somebody asks - which is the 129th's item 5 ruling for the counts, applied to the flags for the same reason.

Each standing flag comes back red or quiet with its reason in plain words:

- cause `Established_False` -> **red at any stage**, *"The customer voiced the negative and it stands as an establishment in their own words."*
- cause `Gating_Unmet`, marker null -> **quiet**, *"this question carries no by-stage marker, so nothing says when not knowing becomes a deal-killer."* **Null is never stage zero**, the 125th's ratified semantics.
- cause `Gating_Unmet`, stage >= marker -> **red**, *"Unknown past stage N."*
- cause `Gating_Unmet`, stage < marker -> **quiet**, *"Unknown here is quiet and lawful."*
- stage unreadable -> **quiet**, and the reason says the failure is ours rather than the deal's. Blank beats wrong: a red raised on a stage we could not read is a red nobody can act on.

**The stage ordinal is read from the ORG, never parsed from a name.** Our marker is a number and a customer org carries stage NAMES and an order - LAW #1 at the stage plane. The ordinal is the deal's position among the org's ACTIVE OPEN stages by `SortOrder`: whatever an org calls them, the third open one is the third. Closed stages are excluded because a closed deal is not somewhere along the way; inactive ones because they are not on the path. Measured here: four active open stages, and the inactive `Qualify` with a null sort order correctly excluded.

**No dismiss exists and nothing was added that could become one.** Clearing is evidence establishing the affirmative, or a human override through the same answer path, which is the standing law rather than anything (c) invented. Acknowledgement still clears nothing.

## 4 · Item 8(iii), closed by measurement

The 129th carried forward the observation that the rehearsal deal's 32 criteria all read Informal, and asked whether `AAO_DC_F` never upheld on this corpus or never reaches the criterion row. **It reaches the row and it works.** Counted org-wide:

| deal | Formal | Informal |
|---|---|---|
| Wells Fargo CIB | **4** | 11 |
| Project Farma | **1** | 10 |
| AAO DEMO REHEARSAL DEAL | 0 | 32 |
| Emerson / Aspen Tech | 0 | 2 |

`AAO_DC_F` upholds and stamps `Formal` onto the criterion. The rehearsal deal's all-Informal reading is **a fact about what the Brightwell calls said**, not a broken path.

## 5 · A3 held out, per the 129th's item 4

B1's DENIED is unambiguous and the family is built on it. **A3's DENIED is held out of every on-screen specimen until Matthew grades the row**, exactly as ruled: if the reading is inverted, the family would paint a hard red saying *"approval chain: voiced no"* on a deal where the buyer just said the decision is hers alone. Nothing in this build treats A3 as settled, and the flag it would raise is quiet at the rehearsal deal's stage regardless.

## 6 · THE FAMILY, POPULATED AND MEASURED

Raised on the two deals under test and reconciled against everything standing. Rows in `review/process/step-c/`.

### The proof deal, Stage 2 (ordinal 2) - 8 standing, **3 RED**

| | contract | cause | marker | reason |
|---|---|---|---|---|
| **RED** | `AAO_BANT_B1` | `Established_False` | 2 | the customer voiced the negative; a voiced no reds at any stage |
| **RED** | `AAO_BANT_A3` | `Established_False` | 3 | same, **and this is the row held out of every specimen until Matthew grades it** |
| **RED** | `AAO_BANT_T1` | `Gating_Unmet` | 2 | *"Unknown past stage 2"* |
| quiet | B2 N3 N4 T2 | `Gating_Unmet` | 3 | *"stage 2 against a marker of 3. Unknown here is quiet and lawful"* |
| quiet | T4 | `Gating_Unmet` | 4 | same, further out |
| cleared | A1 A2 A4 B3 B4 N1 N2 | - | - | evidence established the affirmative |

**Both halves of the hundred-twentieth's ruling fire on one deal, in one read.** B1 is the DENIED path driving a hard red end to end: the customer said *"there is no budget allocated for this, not in this fiscal year"*, call 3 upheld it blind, it stands at verdict TRUE with interpretation DENIED, and it now reads RED at stage 2 - and would read RED at stage 1. T1 is the other half: nobody voiced a target date, the deal reached the stage by which it should have been known, and absence became a deal-killer on the clock rather than on a judgment. Seven cleared on evidence. **Seven cleared, three red, five quiet is the whole grammar in one picture.**

### The rehearsal deal, stage `Qualify` - 12 standing, **0 RED**, and the reason is a finding

Every never-established flag reads quiet with *"this deal's stage could not be ordered against the org's open stages."* **The deal sits on an INACTIVE stage value.** `Qualify` is `IsActive = false` in this org's `OpportunityStage`, so it is not on the open path and has no ordinal.

That is the honest fallback behaving as designed - blank beats wrong, and a red raised on a stage we could not read is a red nobody can act on. **But it is worth naming for the demo:** the rehearsal deal is the surface the four-plane demo runs on, and while it sits on an inactive stage **no by-stage flag can ever fire there.** Moving it onto an active stage is a one-field data change and it is not mine to make on a demo surface. A real customer org can reach this state the same way, by deactivating a stage that deals already carry.

## 7 · The twelve, retired in place, with the condition met

The hundred-twenty-ninth's item 6, executed to its scope. **Twelve contracts retired; nine claims and seven answers untouched; the STAGE B pair still standing**, verified by count before and after:

```
before: contracts=12 claims=9 answers=7
retired=12
after:  claims=9 answers=7 | STAGE B pair still standing: 2
```

They retire as *"an experiment's output, kept as the record of the first discovered mint and never live in a pass"*, with the whole reason on the row, **never as Superseded**, which would claim a succession that never happened.

**This needed a state that did not exist.** `AAO_Contract_State__c` carried Derived, Awaiting_Ratification, Ratified and Superseded, and nothing else. So: a `Retired` value, and `AAO_Retired_Because__c` to carry the reason, because a state that stops without a reason is a third state nobody can read later. FLS shipped in the same deploy.

**And it needed one place to decide what "live" means.** Nine readers across the source each spelled it `AAO_Contract_State__c != 'Superseded'`, independently, which was correct for exactly as long as Superseded was the only way to stop being live. A second dead state would have had to be learned by all nine, and a missed one reads a retired contract as live - **which is precisely the silent-drop-at-the-generation-layer defect this retirement exists to end, reintroduced by the fix for it.** So `AAO_ContractState.DEAD` is the one place, bound into every query as `NOT IN :AAO_ContractState.DEAD`, and a future dead state reaches every reader by being added there and nowhere else.

One consequence closed while it was visible: a flag whose contract is no longer live **stays on the row and stops being READ as a standing condition.** Nothing is deleted, and the record of having been raised is history; but a deal-killer test that no longer exists cannot kill a deal, and clearing it instead would claim evidence answered it, which is a different and false thing to say. Measured: the two `AAO_T*` flags dropped out of both deals' reads (14 to 12, 10 to 8) with the RED counts unchanged.

## 8 · Tests

`AAO_FlagsTest` **17 of 17**, ten of them new and each pinning a ruled behaviour: a voiced no does not clear the flag it proves; an affirmed answer still does; DENIED anywhere outranks AFFIRMED elsewhere; a voiced no reds at any stage; never-established is quiet before its marker and red past it; a null marker never flags; the stage ordinal comes from the org rather than from a name; a human establishment clears it exactly as evidence does; and **acknowledgement clears nothing** - asserted as structure rather than manners, so a future session adding a dismiss has to break a test to do it.

**Full suite: 568 tests, 567 passing**, the single failure the standing org-resident `ConvertToOpportunityTest`, non-AAO. That run predates the last two flag tests; `AAO_FlagsTest` re-run synchronously at 17 of 17 after them.

Re-verified alongside, synchronously, for the live-set sweep: `AAO_ProcessComputeTest` 10, `AAO_RecallGateTest` 6, `AAO_PassContractsTest` 10, `AAO_DiscoveryTest` 9, `AAO_ProjectTest` 34. The full suite runs at session close.
