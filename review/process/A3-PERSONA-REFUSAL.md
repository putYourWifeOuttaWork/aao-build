# The 136th's three: A3's reword, the persona seed, and graceful refusal

**Tree** `/Users/thefinalmachine/Downloads/claude` (`main`) · **Org** `00DWD00000DV7iT2AT`, sandbox `aossb2` · authorized by the hundred-thirty-sixth's items 1 and 3 and the hundred-thirty-fifth's finding one.

## 1 · A3 REWORDED, and design's instruction assumed a mechanism that did not exist

Matthew's ruling: *"who else can also be no-one and that is the best answer we can get, rare, but best."* The proposition now reads:

> **Has the customer described the approval chain for this decision? An answer that nobody else must approve IS a description of the chain, and the strongest one.**
> element: *the customer describes the approval chain, which may end with them*

**But the instruction said "the old contract superseded per the standing mechanism `AAO_ProcessContracts` already carries for an edited question" - and there was no such mechanism.** The class carried a note reading *"the previous contract stands and is superseded rather than replaced"* and **zero occurrences of the state anywhere in it.** The old contract stayed LIVE beside the new one, so an edited question would have put two live contracts on one rubric row and both would have ridden the reads.

A comment asserting a property the code does not hold, which is the green-suite hazard in miniature and the shape the hundred-thirty-second named one build ago on `writeLinks`. It was unreachable until now because **no question had ever been edited**; A3 is the first, which is exactly how it surfaced. Design reasoned from a comment to a mechanism, which is the 128th's own error class one layer along.

Built, then reworded, and measured from the org:

```
C state=Superseded  supersededBy=a1WWD000002yneD2AQ  hash=a25c878a
C state=Derived     supersededBy=null                hash=48077dbb
```

The successor is inserted **before** the predecessor stands down, so no window has a question with no live contract; the pointer is set as well as the state, because a superseded row that does not name what took over is a dead end for anyone walking the chain later; and nothing is deleted.

**The proof deal's standing A3 red is wrong by ruling and corrects when the deal re-runs under the corrected generation.** Nothing was hand-edited. The 130th's hold-A3-out-of-specimens lifts as of that run.

## 2 · THE PERSONA SEED, and a two-axis finding it forced

Authorized: Executive Sponsor from Propose, Procurement Lead from Commit. **Seeded, live, and the arc works** - Wells Fargo at Stage 3 now stands an Executive Sponsor ghost, the proof deal at Stage 2 is quiet below the marker, and the rehearsal deal is quiet because its stage cannot be ordered at all.

**But "Propose" and "Commit" are not on the axis the comparison uses, and measuring which axis is right was the real work.** There are two, and nothing links them:

| axis | what it is | where it lives |
|---|---|---|
| `OpportunityStage` | Stage 1..4, four active open here | on the DEAL, always |
| `ALTF__Stage__c` | Qualify / Discover / Validate / Propose / Commit | on the **WRAPPER**, via `ALTF__Sales_Process_Stage__c` |

**The wrapper's stage is null on every wrapper in this org, and roughly 80% of installs have no wrapper at all** - the 122nd's measured finding. So a by-stage marker reading the Altify axis could never fire on a wrapper-less deal, which is LAW #1's whole case. **`AAO_Flags.stageOrdinalOf` reading `OpportunityStage` is therefore right**, and it is right for a reason rather than by luck.

Matthew's two names are translated onto that axis and the translation is stated on the rows themselves: Propose is the fourth of the seeded process's five stages and this org has four active open opportunity stages, so **Executive Sponsor lands at ordinal 3 and Procurement Lead at 4** - the second-to-last and the last. The arc is what he described: a ghost standing where the deal will sit, and a second arriving when it advances.

**One line for design, and it is the 130th's run-sheet line:** that line says the demo deal must sit on *"an active stage of AAO New Business (Sandbox)"*, which names the Altify axis. It should name the OPPORTUNITY axis instead - an active, open `OpportunityStage`. And the rehearsal deal currently sits on **`Qualify`, which is INACTIVE here**, so as it stands **no by-stage flag and no persona ghost can fire on it at all.** That is now the single data condition standing between the rehearsal and its Process plane.

## 3 · GRACEFUL REFUSAL, the buildable half (135th, finding one)

§P4's law was written law with no code behind it. Built at the facade, as the stamp put it:

- **`AAO_Modules.present()` now asks the describe** - one representative object per module, the one whose absence IS the module's absence. The describe is asked rather than the query attempted, deliberately: `isAccessible()` costs nothing, returns a Boolean, and cannot half-succeed, whereas catching the exception means every caller wraps every read and the one that forgets throws anyway.
- **`AAO_Modules.absenceNote()`** says what is absent AND what still stands, because a customer who reads "unavailable" and nothing else concludes the product is broken.
- **The two things a module's absence removes are now routed through it.** Assessment absent removes the DISCOVERY SOURCE: `discoverQuestions` returns empty with the note, and the mint reports it. Insight Map absent removes the PROJECTION TARGET: the card writer returns with the note and draws nothing, while the harvest still lands as claims and answers on our own ledger.

**What this does not reach, and it is not this method's failure: rung 0.** Every class referencing `ALTF__` types statically carries a compile dependency on the package, so an org without it cannot deploy the code at all. That is the packaging decision the 135th put to Matthew with its two options, and no runtime check can answer it.

**Verification, with the instrument's reach named:** inspection plus unit-mocked refusal, exactly as the stamp allowed, because **no state of this sandbox can produce a mixed-license org.** The tests drive absence through the facade's own stub rather than through a real permission failure, and that is the boundary of what is proven.

## 4 · Tests

`AAO_ModulesTest` **7 of 7**, two new: an absent module removes its source and its target and nothing else, driven through both gated callers; and the absence note names what still stands.

`AAO_ProcessContractsTest` 5 of 5 unchanged, and the supersession rides the same class it already covers.

**And the suite caught two of my own standing assertions, which is the mechanism working.** `AAO_PersonasTest` asserted that EVERY persona expectation is blank - true when written, and wrong the moment Matthew authorized the demo seed. Corrected rather than weakened: the property each test protects is unchanged and now asked of the rows it is actually about. `theVOCABULARY...` asserts ten blank and two seeded by name, because what matters is that **the seed states no methodology nobody gave it** and the two that speak were spoken for. `aBLANKEXPECTATIONNEVERGHOSTS` now asks the question of the BLANK rows specifically, so it stops depending on a sheet that will keep changing as Matthew grades it. `AAO_PersonasTest` 12 of 12. **Full suite 609, 608 passing**, the one failure the standing org-resident `ConvertToOpportunityTest`.

## 5 · Rehearsal readiness, and two data conditions rather than one

The hundred-thirty-seventh's item 5 adds a run-sheet line: set the rehearsal deal's `Type` to the seeded plan type, so the resolution story on screen is exact rather than null-defaults-to-everything with six declined off camera. **There is a second condition and it is not cosmetic:** the rehearsal deal sits on `Qualify`, which is INACTIVE in this org's `OpportunityStage`, so it has no ordinal and **no by-stage flag and no persona ghost can fire on it at all.**

Both are one-field changes on a sandbox demo deal and both are set below, so the surface is ready for the run rather than ready to be prepared.
