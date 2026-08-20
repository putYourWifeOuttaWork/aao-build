# Process step (f) · the minimal Process panel

**Tree** `/Users/thefinalmachine/Downloads/claude` (`main`) · **Org** `00DWD00000DV7iT2AT`, sandbox `aossb2` · authorized by the hundred-twenty-sixth's item 3(f) and the hundred-thirty-second's item 8, with the hundred-thirty-fourth's item 4 rail built alongside. Rows in `review/process/step-f/`.

> *"(f), the minimal Process panel on the existing run page: the fifteen assessment rows (TRUE with citation, quiet blank, RED with its reason), the ghost list, qualifier state, counts through `AAO_ProcessCompute.read()`, and the cause-display vocabulary priced in its report."*

## 1 · What it shows, measured on the proof deal

All fifteen rows, and the three states the hundred-twentieth ruled are visibly different:

```
AFFIRMED  AAO_BANT_A1  Yes         Gwen Arkwright: "That is me. I sign off on operations spend..."
RED       AAO_BANT_A3  Voiced no   Gwen Arkwright: "there is nobody above me on it..."
RED       AAO_BANT_B1  Voiced no   Gwen Arkwright: "No. There is no budget allocated for this..."
BLANK     AAO_BANT_B2  (nothing)   Nothing established, and no deal-killer flag stands on it.
AFFIRMED  AAO_BANT_N2  Yes         Ivan Petrov: "Roughly nine hours a week across the team..."
RED       AAO_BANT_T1  Not established   Unknown past stage 2.
```

Across the two deals: **10 AFFIRMED, 3 RED, 17 BLANK.** Every affirmed and every voiced-no row carries the words behind it; a quiet blank carries its reason instead. The panel makes one query set and writes nothing.

**A row is drawn for every declared question, including the ones with nothing on them.** A panel that showed only what fired could not show a quiet blank, and a quiet blank is one of the three ruled states rather than an absence of one.

## 2 · THE CAUSE VOCABULARY, priced as instructed

The residue the hundred-thirtieth named: the standing cause vocabulary writes `Established_False` beside answers reading verdict TRUE with interpretation DENIED. **The label says FALSE in a system that has no FALSE.**

Three options, and the first two are not alternatives:

- **(a) A DISPLAY MAPPING in the panel.** One method, one place, and nothing outside it decides what a cause is called. `Established_False` reads **"Voiced no"**; `Gating_Unmet` reads **"Not established"**. Cost: nothing, and it only fixes OUR surface. **BUILT.**
- **(b) THE PICKLIST LABEL, API name untouched.** `<label>` on the value becomes `Voiced no` while `<fullName>` stays `Established_False`. Cost: **no row moves, no code changes, no history is rewritten**, because the stored value is the API name. What it buys is every NATIVE surface - a report, a list view, a Setup page - showing the honest word to anyone who looks past our panel. **BUILT**, with the reasoning in the field's own XML so nobody later reads the mismatch as an oversight.
- **(c) RENAMING THE API VALUE. REFUSED, and named so it is not proposed again.** It would rewrite what every standing flag row stores in order to correct a word, which is the cosmetic-change-that-rewrites-provenance shape the hundred-twenty-eighth ruled out for `people-p8-v1`. The same law, one object over.

Asserted rather than promised: a test walks every row of a full reading and fails if the word FALSE appears in any displayed string at all.

## 3 · The other three planes

**Ghosts.** The list renders from `AAO_Personas.ghostsOn()`. It is empty on every deal today and says so in words, because all twelve persona expectations ship blank - the hundred-thirty-first's item 6 one-liner, still Matthew's. **The panel is therefore the surface that makes that one-liner visible: as configured, the persona plane shows a sentence explaining why it is empty rather than a gap.**

**Qualifiers.** All fifteen render with their plane (computed or evidence) and their state, and **the state is `not established` on every one, because qualifiers carry no contracts** - that build is the (b) ruling's parked eventual home. Showing them anyway is deliberate: a seller can see what the stage asks of them before anything can answer it, and a panel that hid the plane until it worked would hide the fact that it does not.

**Counts.** Straight from `AAO_ProcessCompute.read()`. Nothing is re-derived on the way to the screen, because a surface that recomputes is a second implementation of somebody else's rule.

## 4 · THE MODULE FACADE (hundred-thirty-fourth, item 4)

`AAO_Modules` is the one place that answers *"is this module present for this deal"*. It answers TRUE for everything, and that is the point: detection is parked as unbuildable in this sandbox, so **the value is entirely that the hardcoding is in one place.** Four named modules, an unknown one throws rather than resolving to a silent true, and the rung reads 0 through 4 for a receipt to say what it saw.

Two shapes built in from the start rather than retrofitted: it takes the **opportunity** even though nothing reads it yet, because Matthew ruled the reference is the people on the deal and a signature that could not carry that would have to change at every call site on the day detection lands; and **assessment and sales process are two constants, never one**, because they are separately licensed and nothing may ask about them together.

Already routed through it: the panel's qualifier read, which is the first module-conditional read the ladder actually gates.

## 5 · THE 134th's QUESTION, INSPECTED · **STATE 1 WOULD THROW**

> *"do the built discovery and read paths actually CATCH that failure as absence, or would state 1 throw?"*

**They would throw. Nothing anywhere catches it.** Counted across every non-test class: **zero** occurrences of `QueryException`, `NoAccessException`, `isAccessible()` or `isQueryable()`. The vendor reads sit bare:

| class | `ALTF__` references | try-blocks |
|---|---|---|
| `AAO_Cards` | 157 | 0 |
| `AAO_Project` | 90 | 0 |
| `AAO_ProcessContracts` | 28 | 0 |
| `AAO_ProcessPanel` | 13 | 1, and it is the span parse, not a vendor read |
| `AAO_ProcessCompute` | 11 | 0 |
| `AAO_Personas` | 2 | 0 |

So §P4's graceful-refusal law is **written law and unimplemented code** - the sixth instance of the law-versus-path divergence class this project keeps finding, and the first one found before it cost a run rather than after.

**And there is a harder half the question did not ask about.** Every one of those classes references `ALTF__` types STATICALLY, so each carries a compile-time dependency on the managed package. **Rung 0 - no Altify at all, LAW #1's founding case - is not a runtime behaviour to catch; it is a deployment that would not compile.** Stated as inspection and not as measurement, per the capability law: nothing in this sandbox can uninstall the package, so this is read from the source rather than tried.

Not fixed, because the stamp asked for the answer and not the build (*"the catch is inspected rather than exercised"*), and because no sandbox state can verify a fix. What the facade buys is that when it does build, it has one home.

## 6 · The honest limit · CONTROLLER-PROVEN IS NOT RENDERED-PROVEN

The sixty-fifth stamp's law, and this build does not get to skip it. **The panel has never been opened in a browser.** The Apex is proven from the calling runtime and the rows above are real; layout, the `if:true` guards under a real render cycle, and whether the three states read distinctly at a glance are unproven until someone looks.

One render-class defect was found by reading rather than by rendering and is already fixed: the notes list was keyed on its own text, and two planes can honestly say the same sentence, so a repeated note would have been a duplicate `for:each` key - a render defect, in the same component family as the sixty-fourth stamp's. Notes now carry an index key.

**Matthew's five minutes closes it:** open the run page on a deal and look. The proof deal shows three reds, ten affirmations with citations and seventeen quiet blanks; the rehearsal deal shows the by-stage plane going quiet because its stage sits outside the open stages, which is the demo fact from the hundred-thirtieth's item 7 visible on screen.

## 7 · COMPLETED's home, priced against design's lean (hundred-thirty-second, item 5)

Design's lean: the lifecycle looks like the **Answer row's** job - `AAO_Answer__c` already declares `Insight_Card` as a subject type, it is the upserted current-state row per subject, and human precedence, the watermark and the projection machinery are all already built there.

**Priced, and the pricing does not surprise: the lean is right and it costs less than the alternatives.** What it needs:

- **One field** on an object we own, born with the row, never migrating - which is the hundred-twenty-fourth's own requirement met literally rather than by analogy.
- **A subject wiring** for `Insight_Card`, which `AAO_AnswerKey` declares and deliberately leaves unwired: *"Insight Card and Qualifier are managed objects whose API names have not been read from altify--aossb2. Guessing them would violate evidence over inference about schema, so they throw by name instead."* **That objection is now spent** - this build has read the card object from the runtime, so the API name is measured rather than guessed. It is a wiring, not a discovery.
- **Nothing else.** The watermark, the human-precedence read and the retraction path are the same ones every other answer uses, which is exactly why the human-override half needed no new ruling: Coverage already answered it, and a computed dimension a human sets is his forever.

The one cost worth naming: an answer row per card is row volume against the object-budget law, bounded by cards-per-deal. **Recommended as design leans**, and not built here - it belongs with the surface that first needs COMPLETED, which does not exist yet.

## 8 · Tests

`AAO_ProcessPanelTest` **7 of 7**: a voiced no never reads as a false and no displayed string on a full reading contains the word; every declared question gets a row whatever its state; an affirmed row carries its words; a denied row is not a blank; a denied outranks an affirmed on the same row, so the panel and the flags can never disagree; an org with no Process questions is told so; and **the panel writes nothing, asserted by grepping its own body for every DML verb.**

`AAO_ModulesTest` **5 of 5**: every module present until detection exists; an unknown module throws rather than resolving true; the rungs read as the ladder ruled them; assessment and sales process are asked separately; a run can say what it saw.

**Full suite 602, 601 passing**, the one failure the standing org-resident `ConvertToOpportunityTest`.
