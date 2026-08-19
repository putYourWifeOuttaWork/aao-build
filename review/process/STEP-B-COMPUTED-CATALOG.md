# Process step (b) · the computed catalog's first arithmetic

**Tree** `/Users/thefinalmachine/Downloads/claude` (`main`) · **Org** `00DWD00000DV7iT2AT`, sandbox `aossb2` · authorized by the hundred-twenty-sixth stamp's item 3(b) and the hundred-twenty-eighth's item 10. Rows in `review/process/step-b/`.

> *"(b) The computed catalog's first arithmetic. Decision-maker-identified, committee gap, criteria coverage, insight completeness - deterministic rows off our own ledger at the join, zero callouts, per §2 of the proposal."*

## 1 · What was built

`AAO_ProcessCompute`, its own pass stage between the join and projection. **Zero callouts, and it says so by never touching `AAO_Extract`.** Measured on the proof run: 1,136 ms, 0 callouts, 27 SOQL of 100, 12 DML of 150. The read half alone is **8 SOQL, flat** - it was not, at first: the identifying answer was fetched inside the loop over decision makers, which is a query in a loop, unbounded by anything in the code, and the ninety-sixth stamp's own lesson about a cost that hides one frame down. Hoisted into the single answer query that was already running, keyed person-plus-code; behaviour identical, cost now independent of headcount.

The plane is a second **proposer**, never a second writer. It builds candidates at basis `State` and hands them to `AAO_Commit`, which already carries the human-precedence read, the merge path, the reinforcement rule and - ratified at the forty-eighth stamp and never once exercised - the `State` branch of the speaker gate. That is why the class is short: almost everything under it was already built and waiting.

**Three mechanisms this project declared and never made now exist as rows:**

| | before | now |
|---|---|---|
| a claim at basis `State` | none, ever | 4 (2 live, 2 lawfully retired) |
| a populated `AAO_Claim_Basis__c` | none, ever | 4, each with its frozen snapshot |
| an answer at basis `Both` | none, ever | 2 |

The 47th stamp's own header names this build's first computation as the case it was written for: *"One decision maker is named on the relationship map rests on a record, not on bytes."* Four months later it does.

## 2 · THE FINDING: two of fifteen, and it is a property of the questions

The computed plane can answer **exactly two** of the fifteen BANT questions, and that is readable in their own element text rather than in my code. Thirteen name the customer's mouth as a conjunct - *"the customer states"*, *"it is the customer who voices it"*, *"per the customer's words"* - and no record can stand in for a mouth.

The two that do not are both Authority:

- **A1 · the decision maker is identified.** Elements: *a person is identified as making the final call*; *the identification rests on their own or a colleague's words.* The first is a ledger fact. **The second is satisfied by CITING the answer that carries it**, whose own basis is Transcript - which is precisely what a cited row of type `Answer` is for.
- **A2 · the decision maker is engaged.** Elements: *the decision maker participated directly*; *the participation was in a conversation with us.* Both are the participant row, whole. Nothing inferred, no words needed.

**A2 is the specimen worth keeping.** Step (a) reported A2 REFUSED at the evidence plane, on our own seller, because a seller cannot establish that a decision maker is engaged. That refusal was right, and it left the question unanswered on a deal where the answer sat in a participant row the whole time. The evidence plane is right to refuse; the computed plane is right to answer; they do not conflict because the hundred-twentieth stamp already ruled they are **one fact read by two planes, never two facts**.

## 3 · Measured across the whole org: zero, and it is corpus not grammar

Run against every deal that carries answers: **no deal in this sandbox has a decision maker established.** Org-wide there is not one live TRUE `AAO_BR_DM`, and the single `AAO_BR_SIG` is the Fatima twin at UNVERIFIED - the eightieth stamp's own defect specimen, correctly not true. The rehearsal deal reads `roles={Evaluator=2}`.

So the first arithmetic computed **zero facts everywhere**, which is the same shape as (a)'s Budget and Timeline zero. Unlike (a)'s, this one separates, because the predicate is deterministic: **a targeted fixture with a voiced decision maker proves the mechanism, and it did.** See `DENIED-PROOF.md`; both proofs rode one run.

Reading from the proof deal, where the words do carry it:

```
F DECISION_MAKER_IDENTIFIED | AAO_BANT_A1 | Gwen Arkwright | cite=Answer
F DECISION_MAKER_ENGAGED    | AAO_BANT_A2 | Gwen Arkwright | cite=Participant
```

and after the write, from the org:

```
AAO_BANT_A1,State,TRUE,Participant,Gwen Arkwright,(no source),(no spans),AAO_ProcessCompute,compute-1.0.0
AAO_BANT_A2,State,TRUE,Participant,Gwen Arkwright,(no source),(no spans),AAO_ProcessCompute,compute-1.0.0
```

with their citations frozen:

```
A1  Answer      {"basis":"Transcript","verdict":"TRUE","buyer_role":"Signature Approver",
                 "proposition_code":"AAO_BR_SIG","person":"Gwen Arkwright", ...}
A2  Participant {"display_name":"Gwen Arkwright","internal":false,"buyer_role":"Signature Approver", ...}
```

and both answers now read **`Basis = Both`**, `Verdict = TRUE`, `Interpretation = AFFIRMED`.

## 4 · Four decisions inside the build, each with its reason

**(a) The subject is the PERSON, not the deal.** Step (a)'s Process answers key on Participant, and a computed claim keyed on Opportunity would put one contract's answers at two grains - one fact with two representations, the shape the hundred-twenty-eighth's item 7 just named for `AAO_Gating__c`. The deal-level roll-up ("is A1 satisfied on this deal?") is arithmetic over the answers and needs no second representation to stand on.

**(b) The binding is CONFIGURATION, because the code is the customer's.** A predicate is ours; a question code is not. Nothing in the class names `AAO_BANT_A1`. `AAO_Assessment_Stage__mdt.AAO_Computed_Predicate__c` binds predicate to question code, seeded against our own BANT set, org-overridable - the shape §2 of the proposal already ruled for computed qualifier predicates. **This is the hundred-twenty-eighth's ratified `MEANINGS` finding one layer up**, and it was avoidable only because that finding was made first.

**(c) A re-run counts unchanged, never reinforced.** A state claim has no spans, so nothing about the row would stop the same fact being re-asserted every pass until the reinforcement count read like somebody pressing a point ten times. The citation is the read-before-write: a fact whose cited row already stands behind a claim on this contract is the same observation and is skipped. Proven: second run wrote 0, reported 2 already standing.

**(d) A RECORD IS NOT AN UTTERANCE - and this was a defect the build found in the shared writer.** The first computed claim landed as `Reinforced`, because `AAO_Commit`'s branch tests byte intersection and a state claim has no bytes to intersect, so it fell through to the default. The eightieth stamp ruled that reinforcement counts DISTINCT UTTERANCES; a ledger read of a fact the words established is not a second time anybody said it. `CORROBORATED` is the exact word and was already in the vocabulary. Fixed in the one branch, with the same reasoning the speaker gate already applies one line up (*"Nobody said this; the record says it"*). Both outcomes already return false from `movesTheAnswer`, so no reader changes and no verdict moves; what changes is which count it lands in. Proven by retiring the two claims through the lawful path and re-observing:

```
AAO_BANT_A1  Transcript  Established   live
AAO_BANT_A1  State       Reinforced    RETIRED   <- the first observation, kept
AAO_BANT_A1  State       Corroborated  live
```

**(e) Corroboration is only reachable once completeness has nothing left to advance** - found by the test, not designed. The first attempt at the corroboration case asserted against a standing answer that was only partly covered, and the computed claim came back `Established` rather than `Corroborated`, correctly: a claim carrying a previously-missing element ADVANCES the requirement, and the sixty-ninth stamp's three axes run in priority order (completeness, then corroboration, then reinforcement) in `AAO_Commit` already. The fixture was wrong, not the code. Recorded because it means a computed fact landing on a half-covered answer will read as an establishment, which is right and is not obvious.

## 5 · What computes and writes nothing, and the question that goes with it

Committee coverage, criteria coverage and insight completeness compute exactly as the stamp asks. From the rehearsal deal:

```
people=11 external=8 coverage={(none)=7, Brief contact=1, Multiple contacts=3} roles={Evaluator=2}
criteria=32 formal=0 informal=32 required=5
cards=5 byType={Goal=2, Obstacle=3} withInsight=3 without=5
```

**They answer no declared proposition.** There is no contract for *"eleven of fourteen criteria are formal"*, so there is no answer for it to accrue onto and no claim it could lawfully be. Minting contracts to give them somewhere to land is authoring a rubric nobody graded, which is design's and not mine. They are returned on the reading and journalled on the leg; the landing surface is **parked with its options below**, because a row nothing reads is the shape this project has named five times.

**Two things fell out of the counts that are findings in their own right, measured not guessed:**

- **Coverage first read `(none)` for all eleven, and that was MY defect, not projection's.** Projection writes the band to ONE of a person's participant rows and leaves the others blank; a fold that kept whichever row came last read blank for everyone, on a deal whose map plainly shows Brief contact and Multiple contacts. Marcus Reyes has three rows and exactly one carries `Multiple contacts`. Fixed by taking the band from whichever row carries it, and re-measured above. **Reported as a defect I made and found rather than as a finding about the projector, because for an hour it looked like the second thing.**
- **The people count's honest limit.** A person with a Contact folds to one. A person WITHOUT one folds per name form, so "Priya" and "Priya Nair" count twice - the eighty-seventh stamp's key-collapse ruling behaving exactly as ruled, since different designator forms are never collapsed at the key. So `people=11` is **people as the ledger knows them**, which is the only count makeable without guessing, and it reads high wherever identities are unresolved. Named rather than silently deduplicated.
- **32 criteria, every one informal.** `AAO_Criterion__c.AAO_Type__c` never reads `Formal` on that deal. The criteria typing contract (`AAO_DC_F`) exists; whether it never upheld on this corpus or never reaches the criterion row is a separate question and it is (c)'s neighbour, not (b)'s.

## 5b · Two schema additions, and one misleading name I created

**`AAO_Claim_Basis__c.AAO_Cited_Participant__c` plus a `Participant` cited type.** There was no way to cite a participant row, and A2's fact IS the participant row. The alternative was citing the `Source`, which says the conversation happened without saying who was in it - and who was in it is the fact under test. FLS shipped in the same deploy, per the ninety-fourth stamp's rule.

**`AAO_Assessment_Stage__mdt.AAO_Computed_Predicate__c`.** No new type: this one is already "our configuration about a discovered assessment question, keyed by its code, org-overridable", which is exactly the grain a predicate binding needs. **But its NAME now says less than it carries**, which is the hundred-twenty-eighth's item 2 residue in miniature, created by me and recorded so nobody later reads the label as a scope claim. It does not rename on its own: renaming a custom metadata type moves all fifteen record files to record a word. **It rides the next change that already forces those files to move.**

One thing deliberately NOT read: `AAO_Org_Override__c` on that type is a NUMBER and belongs to the by-stage marker. Reading it as a code override would have been one field with two meanings on a config surface - the shape item 7 is asking about elsewhere.

## 6 · The hundred-twenty-eighth's three questions, answered

**The mute guard: does it THROW or does it COUNT?** It counted. **Now it throws**, and the count moved into the code rather than staying a number in a report. `AAO_LocateCharter.requireMeanings` runs inside `registerFamilies`, so a fourth call site cannot forget it, and a declared contract whose family has no meaning vocabulary is refused by name before a single callout is spent. Keyed on FAMILY, never on code, per the hundred-twenty-eighth's substitution. Tested in both directions - a mute contract refused by name, and a real declared set passing - because a guard that refuses everything passes a one-sided test.

**`AAO_Gating__c` and `AAO_Speaker_Requirement__c`** are (c)'s to answer in (c)'s report, as the stamp directs. One thing (b) can already contribute to the second: **the computed plane is structurally incapable of establishing anything from a seller's words, because it reads no words at all.** That is not the gate the stamp is asking about, and it does not answer the question; it narrows it to the evidence plane, where it belongs.

**Item 9, the qualifiers' evidence halves.** Checked, and design is right: `AAO_Discovery.parseElements` already returns the proposition itself as a single element where Help carries no elements block, basis `Inferred_Pending`, and the mint law's zero-element refusal is satisfied by that fallback. **The elements half is closed and this is a discovery-source question, not a schema one.**

**And my own prior finding on the same item is corrected.** I reported an "18-character proposition-code ceiling" that would stop a discovered qualifier reusing its `ALTF__AltifyId__c`. There is no such ceiling. The 18 is a Salesforce record id's length: `AAO_ContractKey.compose` takes a **question record id** as its left half, and `AAO_Discovery` has always passed `q.Id`. **`AAO_ProcessContracts` was passing the CODE**, which worked only because the fifteen BANT codes are ours and short - and would have thrown at compose in any org whose rubric identifiers run longer. Same shape as the meaning map, one more layer along. Fixed to `q.Id`; the fifteen already standing keep their code-shaped keys, because read-before-write reuses them on code plus hash and re-minting fifteen live contracts to restyle a key nobody reads would supersede them to record a cosmetic change - which the hundred-twenty-eighth's item 2 rules out. **The corrected shape rides the next real content change, exactly as the rename does.**

## 7 · The 127th's item 3: the callout counter, and which it was

Not *"the counter does not increment on the failing path."* **The failure leg hard-coded zero**, in a line whose own comment explains why: every numeric was zero-filled after the reporter once died dereferencing nulls. `summarise` counts the `StageResult`s a stage HANDS BACK, and a stage that throws hands back nothing - its results die in its own frame - so the failure leg had no count to report and the zero-fill filled it with a lie while every numeric beside it read from `Limits` and told the truth.

One line: `leg.callouts = Limits.getCallouts()`. The platform's own transaction counter, sitting beside the `Limits` reads that were already there. Transaction-scoped, which is right in both directions - in `AAO_PassQueueable`'s catch it is the dead stage's own transaction and reads what it truly spent; in the R3 finalizer it is the finalizer's transaction and reads zero, which is the truth there and matches the leg's own annotation about whose numbers those are.

## 8 · The honest limit, and one error leg

The proof run carries **one error leg**, mine: the first computed candidate was refused by the org for `REQUIRED_FIELD_MISSING: [Account, Outcome]`. Fixed (`Account` from the opportunity, `Outcome = 'Pending'` because a proposer that stamped its own outcome would be grading its own proposal), and the run resumed to completion. **Under the gate law that run is a FAILED run and I am not calling it otherwise** - it is a targeted proof, not a gate run, and the leg stands on the receipt as the record of a defect found by running rather than by reading.

The failure leg is also the first one written under the fixed counter, and it reads `callouts=0` - correct, because that transaction made none.

Unit tests prove the arithmetic and the shapes. They make no callouts, so they never prove the plane fires on a real pass; that is what the targeted run is for, per the capability law as the 125th extended it.

## 9 · PARKED, one question, options and costs · WHERE DO THE COUNTS LAND?

Committee coverage, criteria coverage and insight completeness compute and have nowhere lawful to go. Design's, not mine.

- **(a) The six COMPUTED-plane qualifiers, which are already seeded and waiting.** `AAO_SEED|Q|` CHAIN, CRITERIA, DMINSIGHT, MAPPED, PEOPLE1, SUPPORT - six of the fourteen, marked COMPUTED on their face, and DMINSIGHT is literally §2's own worked example. `Qualifier` is a declared subject type and `Qualifier_Status` a declared cited type, so the schema already expects them. **Cost:** a qualifier needs a CONTRACT to be an answer, which means minting contracts from the qualifier object - a second discovery source on a different object. Item 9 closes the elements half of that (the `parseElements` fallback covers it) and §6 above closes the code-length half. What remains is a discovery-source question: qualifiers live on `ALTF__Qualifier__c`, not `ALTF__Assessment_Question__c`, and `AAO_ProcessContracts.discoverQuestions` reads the plan type's ALTIFY CODES. That is a real build, not a line.
- **(b) A computed-state row of our own.** One thin object, one row per deal per predicate. **Cost:** the twenty-ninth stamp's object-budget law, and it is the weakest option: the counts are derivable from rows we already hold, so storing them stores a cache of arithmetic and invites it to go stale.
- **(c) Compute on demand at the reader.** (c)'s red-flag family and (f)'s panel call `AAO_ProcessCompute.read()` when they need the numbers; nothing is stored. **Cost:** zero rows, zero staleness, and no history - nobody can ask what the committee gap looked like last month. **Recorded lean, not acted on:** (c) is right for now and (a) is right eventually, because a qualifier is a thing the customer authored and a count is a thing we derive, and only the first deserves a contract.

## 10 · Standing obligations

Rows in `review/process/step-b/`: `proof-pairs.csv` (82), `proof-claims.csv` (18), `proof-answers.csv` (13), `proof-cited-rows.csv` (4), `proof-receipt.csv`, `discovered-twelve.csv`.

Stage timings, from the receipt rather than from a report: call 0 8,517 ms · read 1 21,927 ms · read 2 16,905 ms · call 3 verify 26,920 ms · join 1,442 ms · **computed catalog 1,136 ms, 0 callouts** · projection 1,421 ms · cards 7,862 ms. Four callouts. **Worst single callout 26,920 ms against the 120,000 ms ceiling and the 88,000 ms measured gateway wall - 31% of the wall that actually fails.** No leg self-marked past budget.
