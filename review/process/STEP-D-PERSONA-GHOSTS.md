# Process step (d) · persona ghosts

**Tree** `/Users/thefinalmachine/Downloads/claude` (`main`) · **Org** `00DWD00000DV7iT2AT`, sandbox `aossb2` · authorized by the hundred-twenty-sixth's item 3(d) and the hundred-thirtieth's item 8. Rows in `review/process/step-d/`.

> *"(d) persona ghosts per the 126th and proposal §3: expectation mapping as seed metadata keyed to stored values, ghosts injected where the stage expects an unmatched persona, eliminated on match at the join, enumerable and purgeable, never vendor map rows; the map writer reads Process state first."*

## 1 · A ghost is COMPUTED, and every acceptance condition falls out rather than being built

A ghost is *expected at this stage* minus *matched by somebody on this deal*. Both sides are ledger facts, so the whole thing is arithmetic over rows we already hold - and the hundred-twenty-ninth ruled that exact shape for the counts, in words that apply here unchanged: *"storing them stores a cache of arithmetic and invites it to go stale."*

| the stamp asks for | what it costs, computed |
|---|---|
| **injected** where the stage expects an unmatched persona | the stage moves, the expected set widens, the ghost is simply there on the next read. Nothing writes it |
| **eliminated** on match | a person is identified who matches, and it is gone on the next read. No row to retire, and no argument with the never-delete law about what eliminating one means |
| **purgeable** by construction | there is nothing to purge. **The strongest form of purgeable is nothing to purge** |
| **enumerable** by construction | `AAO_Personas.ghostsOn` is the enumeration |

The cost is carried rather than hidden: **no history.** Nobody can ask when a ghost first appeared or how long it stood. That question belongs to the D360 plane when it stands up, which is exactly where the 129th put the same question for the counts.

## 2 · Never a vendor row, and THE MAP WRITER NEEDS NO CHANGE

`ALTF__Contact_Map_Details__c.ALTF__Contact__c` is `nillable = false`, measured a third time here, so an expected-but-unidentified persona can never stand on the relationship map. The hundred-nineteenth asked for *"the map writer reads PROCESS state before writing people"* so that it could inject ghosts as it wrote.

**With ghosts computed and off-map there is nothing to inject, so the map writer is untouched.** That is the measured constraint simplifying the design, not a phrase left unhonoured - and reporting it is better than making a change to satisfy a sentence. Nothing is written to `ALTF__Relationship_Map_Persona__c` either: manufacturing vendor rows is refused as default (122nd), and a row on their object would carry their automation and our meaning at once.

## 3 · THE FINDING: the vendor's personas are JOB-SHAPED, and the proposal's match rule is wrong for them

Read from the org, the twelve active stored values are:

> CEO · CRO · Executive Sponsor · Sales Leader · RevOps Leader · Enablement Leader · IT Leader · Procurement Lead · **Altify Program Owner** · Consultant · Legal · Partner

**Not one is a methodology role.** They are job categories, and they are this org's own: RevOps Leader, Enablement Leader and Altify Program Owner describe who Altify sells to. The proposal's worked example - *"your stage expects an Economic Buyer; none identified"* - names a value that is not in this vocabulary and would not be in a customer's unless they configured it.

That matters because proposal §3 proposes the match rule as *"role establishment first, never title alone - titles resolve identity, never establish roles, standing law."* **That rule is right, and it is right about a different axis.** *"Is this person the RevOps Leader"* is a question about WHO THEY ARE, not about what authority they hold, and a title resolving identity is the standing law's own permitted use of a title rather than a breach of it.

So the match is by title, deterministically, from a configured synonym list, never a model - the twenty-fourth stamp's ruling on title normalisation. **Establishing a buyer role from a title stays forbidden; nothing here does that, and a persona match writes no role, moves no answer, and touches no map value.** And the ladder's discipline holds on ambiguity: exactly one persona matches, more than one is AMBIGUOUS and matches NOTHING, reported rather than picked.

**`Altify Program Owner` is the seventy-sixth stamp's label hazard sitting live in the vocabulary** - a value naming a vendor product. Keyed to stored values throughout, so it can never be read as a methodology role.

## 4 · THE DEFECT RUNNING FOUND AND READING NEVER WOULD

The first draft matched with `title.contains(pattern)`. The first real title off a real deal, *"Director, Revenue Operations"*, came back **AMBIGUOUS between RevOps Leader and IT Leader.**

**`cto` is a substring of `dire`cto`r`.**

Every short abbreviation in this vocabulary has the same shape - `ceo`, `cio`, `cro`, `it` will each turn up inside ordinary English words forever. And the consequence is not a wrong match, which would at least be visible: under the ladder's discipline an ambiguous title matches NOTHING, so **the persona would have been unfillable, casting a ghost that could never be eliminated by anybody.** A permanent false gap on a surface whose whole job is to say what is missing.

Fixed by matching on word boundaries: the title is punctuation-stripped to single-spaced words and padded, and a pattern must match on both edges. Still deterministic, still no model. Pinned as a regression specimen in both directions - `cto` does not match inside `director`, and it still matches when it IS the word, including inside a longer title.

## 5 · The content is NO GUIDANCE, deliberately, and it is a grading surface for Matthew

**Every one of the twelve rows ships with a blank expected-from-stage, and blank means never expected.**

WHICH personas a stage expects is a methodology statement. Nothing in the captured vendor surface states one - measured three times now: no field anywhere points at the persona object, the sales-process chain carries no persona column, and the map row has no persona field. No ruling states one either. So the seed carries the mechanism and the title patterns (which are facts about words, not methodology) and **flags NO GUIDANCE on the content rather than inventing a methodology nobody graded** - the hundred-twenty-second's ratified stance on the forecasting numbers, applied to the same kind of gap.

Blank is never read as stage zero, which is the same null semantics the by-stage marker carries and the 125th ratified.

**The grading surface, one column, twelve rows:** for each persona, the stage from which this deal's process expects it, or blank. `review/process/step-d/persona-config.csv` is the sheet.

## 6 · Both halves proved at the runtime, on a real deal, writing nothing

A mechanism is unverified until tried from the runtime that will exercise it, and for a configuration-driven read that runtime is a real deploy of real configuration. Two expectations were deployed through the ordinary path, read, and reverted to blank.

```
== Wells Fargo CIB - Aviator Content Intelligence - Pilot to Enterprise
S stage=Stage 3 ordinal=3 | ghosts=1 matched=1
FILLS Tom Brzezinski "Head of Banker Enablement" -> Enablement Leader
GHOST Executive Sponsor :: This deal is at stage 3 and the persona Executive Sponsor is
                           expected from stage 2. Nobody identified on this deal fills it.
W wrote nothing: dml=0 callouts=0 soql=4
```

**ELIMINATED** and **INJECTED**, on one read, on titles the org actually holds.

**Wells Fargo was the vehicle because the reading is pure** - `ghostsOn` contains no DML anywhere and the run proves it at `dml=0` - and because it is the only deal carrying both an orderable stage and a person whose real title fills a persona. Verified untouched afterwards: **90 claims, 51 answers**, the figures the record has carried since the hundred-fifth. The two expectations are back to blank; zero rows carry one.

## 7 · Measured across the corpus

From `persona-matches.csv`, at the seeded blank state (so zero ghosts everywhere, by construction):

| deal | stage | fills a persona | matches nothing |
|---|---|---|---|
| Wells Fargo CIB | 3 | Tom Brzezinski -> Enablement Leader | 6 |
| Project Farma | 1 | Kayla Stanley -> RevOps Leader | 1 |
| AAO DEMO REHEARSAL | `Qualify`, unorderable | Dana Okafor -> RevOps Leader; Raj Patel -> Sales Leader | 2 |
| AAO PROOF | 2 | none | 2 |
| Emerson / Aspen Tech | 3 | none | 3 |

**Four of twenty people fill a persona and sixteen do not**, and that is the honest reading rather than a coverage failure: no persona in this vocabulary covers *"VP, AI Model Risk Governance"*, *"Vendor Management Office"* or *"Chief Operating Officer"*. A person who matches no persona is just a person. **Zero ambiguous matches across all twenty**, which is the word-boundary fix holding on the whole corpus rather than only on the title that exposed it.

## 8 · A seller fills nothing

Our own account executive is not the customer's Sales Leader. Buyer-side only, the same law the internal-subject gate carries, applied where it would otherwise let our side of the call quietly satisfy the buying committee. Asserted as a test rather than assumed.

## 9 · Tests

`AAO_PersonasTest` **12 of 12**: the vocabulary is the vendor's and every seeded expectation is blank; a title resolves to exactly one persona; a title matching nothing is just a person; a title matching two matches none; a blank expectation never ghosts; an expected-and-unfilled persona stands as a ghost; a ghost is gone when somebody fills it; a ghost is quiet before the stage expects it; a seller fills nothing; an unorderable stage casts no ghost and says why; an org stating no expectations gets graceful absence; and the `cto`-inside-`director` regression in both directions.
