# Process step (e) · the identity ruling lands in the writers

**Tree** `/Users/thefinalmachine/Downloads/claude` (`main`) · **Org** `00DWD00000DV7iT2AT`, sandbox `aossb2` · authorized by the hundred-twenty-sixth's item 3(e) and the hundred-thirty-first's item 7, building the hundred-twenty-fourth's §2.

## 1 · The card match becomes a judgment against a closed list

The hundred-twenty-fourth ruled it and the hundred-eighth measured why no string rule can do it. The two duplicate faces on the harness deal were *"6 hrs/week chasing prior approvals"* and *"Sign-off chase: ~1 day/week, no change"* - **one insight, sharing almost no tokens.** A threshold loose enough to catch them is loose enough to merge strangers.

So the face call, which already fires at card-write, now also receives the standing board as a **closed candidate list** and returns match-or-`NONE`. **No second callout**: same call, one more property per unit.

Three decisions inside it:

- **The candidate list is scoped to the unit's own TYPE.** An Obstacle is never a Goal, and Matthew's own cross-type pair on Emerson (identical faces, one Goal and one Obstacle) is the specimen of why those must stay two rows and go to him as a grade rather than be collapsed by a matcher. It also keeps the enum narrow: `keyedShardCount` bounds unit COUNT and nothing bounds candidate count, so scoping by type keeps the thirty-fourth stamp's grammar ceiling out of reach on a deal with a large board.
- **The string key stays underneath as the deterministic fallback**, not as the rule. A failed call leaves a blunt dedup, exactly as it already leaves a blunt face - a worse board than this one and a far better board than a wrong one.
- **The prompt's matching rules lean to NONE.** *"Two cards a person can merge by eye cost far less than one card that silently swallowed something nobody can now see."* Wrong splits are visible and cheap; wrong merges are invisible.

`AAO_CardFace` moves to `cardface-1.2.0`, because the prompt and the schema both changed and a version string covers every input that can change the output it stamps.

## 2 · THE LIFECYCLE, and the trail it computes from did not exist

**The two conditions collapse to one, and reading them so is arithmetic rather than a change to the ruling.** CONFIRMED needs *"more than one person AND mentioned more than once"* - but two distinct people each saying it once is already two mentions, so the second condition is entailed whenever the first holds. What the second really guards is one person saying a thing twice, which fails the first anyway. The computable form is **more than one distinct voice.**

**But the trail was not queryable.** Reinforcement patched a note and wrote no link, so a second mouth voicing an insight left the fact **only in prose**. Two things were being lost:

- the thin Politics slice is who-said-what, and it was silently dropping every voice after the first;
- the ruling computes from *"the card's own reinforcement trail"*, and that trail did not exist in any queryable form.

So **reinforcement now writes the reiterating person's Informer link.** That is correct on its own terms and makes the ruling computable as a side effect, which is the right order for those two.

**Computed, not stored, and COMPLETED is why that is a report rather than a decision.** The ruling says the field exists from birth so the ledger never migrates - written when adding a field looked possible. It is not: the card is a VENDOR object and the standing rail is data rows yes, metadata never.

**And the vendor's own field is not the home either, for a reason worth keeping.** `ALTF__Insight_Card__c` carries `ALTF__Confirmed__c`, `ALTF__ConfirmedBy__c` and `ALTF__ConfirmedOn__c` - which looks exactly like the right place and is not. It is a **BOOLEAN**, so it cannot hold three states; and `ConfirmedBy` is a **USER**, so it is a seller's own act of confirming. Writing our arithmetic over voices into it would put two meanings in one field and overwrite a person's judgment with a count.

So UNCONFIRMED and CONFIRMED compute. **COMPLETED - the resolution state, which no trail can derive because it is a fact about the world rather than about the evidence - has no home, and this build does not choose one.** Parked below.

## 3 · The criterion half, and why it needed its own stage

Measured on the graded Wells Fargo deal: **four of fifteen standing criteria are duplicates**, and the pairs defeat every string rule there is.

| | |
|---|---|
| "Closed model risk approval" | "Model risk approval closed, not pending" |
| "Per-question citation status" | "Per-question citation traceability" |
| "Model risk documentation set" | "Model risk documentation set per version" |
| "Pilot evidence measures" | "Pilot evidence on three measures" |

The last is F3's own specimen and the only cross-mouth one. **Three of the four are the same person saying it twice** - the half the ruling says must write nothing at all, so it is the common case rather than the edge.

The match is therefore a meaning judgment, and it **cannot ride the join**: the join mints the criteria and a callout after DML is fatal on this platform. It cannot ride call 3 either, because the verifier is blind by law and handing it a standing list would end that. So `AAO_CriterionMatch` is **its own stage between verify and the join**, spending one callout on runs that name criteria, none on runs that do not, and none on a deal with no standing criteria to match against - a closed list with nothing in it is not a question.

Its answer lands on the pair (`AAO_Criterion_Match__c`, and `AAO_Criterion_Match_Same_Mouth__c` beside it because one match has two dispositions), and the join reads it:

- **matched, same mouth** -> nothing written, refusal recorded with its reason. No row, no counter theatre.
- **matched, different mouth** -> the standing criterion is reused and the claim accrues onto it. **F3's cure**, and the run report gains a `criteria reinforced` line so a reuse is visible rather than looking like a silent drop.
- **no match** -> mints, exactly as before.

**Prevention, not repair** (hundred-sixteenth): the duplicate stops being minted rather than being merged afterwards on a row the customer has already read. And the failure mode is the honest one: a failed match MINTS, which is what the writer did before this stage existed. A failed match costs a duplicate a human can merge by eye; a guessed match costs a criterion nobody can find again.

## 4 · THE THIRD ENDPOINT, taught by the org rather than by a document

Writing a fixture the product had never produced, the org refused it:

> *"This contact is not on the Relationship Map. Add the contact to the Relationship Map before linking them to an Insight Card."*

**The both-endpoints law was written for two endpoints, the person and the card. There are three**, and the third is the vendor's: a person must stand on the MAP before they can stand on a card. So the hold widens rather than the law bending, and the reason names which endpoint was missing - a run that loses a link to an unmapped person should not read the same as one that loses it to an unresolved one.

This was a live exposure, not only a fixture problem: `writeLinks` inserted blindly, so a card link for anyone off the map would have thrown and taken the whole cards stage down with it.

**And `writeLinks` was not idempotent.** It only ever ran on FRESH cards, which by construction had no links, so a blind insert was safe and the idempotence was an accident of the caller rather than a property of the writer. Reinforcement now calls it on STANDING cards. Read-before-write added, within the batch as well as against the org, or the same mouth saying a thing a third time would inflate the count of distinct voices - which is the one number the lifecycle rests on. `linksWritten` also accumulates now; it used to assign, which would have made the second caller's links vanish from the report.

**A third fixture lesson, and this build has now made it three times:** a hand-built `ALTF__Contact_Map_Details__c` row makes the vendor's own BeforeInsert trigger throw a NullPointerException. Map rows are made by projection or not at all. `AAO_ProjectTest` already carries the lesson in its own words; this test now carries it too.

## 5 · Tests

`AAO_IdentityRulingTest` **8 of 8**: one voice is UNCONFIRMED and two are CONFIRMED; the lifecycle is computed from the card's own links; a card with no links is born UNCONFIRMED; the same mouth restating is marked and writes nothing; a different mouth reinforces rather than twinning; no match leaves the pair clean so it mints; a deal with no standing criteria spends no callout and says why; a run naming no criterion does nothing at all.

Regression, synchronous: `AAO_CardsTest` 12, `AAO_PairCommitTest` 14, `AAO_CriteriaTest` 11, `AAO_ProjectTest` 34, `AAO_ProcessComputeTest` 10. **Full suite 590, 589 passing**, the one failure the standing org-resident `ConvertToOpportunityTest`.

**The honest limit:** unit tests make no callouts, so they prove the plumbing around the judgment and never the judgment itself. **What the model decides when handed a closed list is unmeasured**, and it is the whole substance of the ruling. That measurement is a run on a stacked deal where a second mouth restates an insight - which is exactly the clean-stacking test the hundred-thirteenth left owed and the demo corpus is authored to produce. It should ride the first full run after this, and until it does, (e) is built and its judgment is unproven.

## 6 · PARKED, one question · WHERE DOES COMPLETED LIVE?

UNCONFIRMED and CONFIRMED compute from the trail. COMPLETED cannot: it is a fact about the world.

- **(a) Compute the two, park COMPLETED until a surface asks.** Zero rows now, and the question returns when 3(d)'s autonomy work or a later surface wants to mark a thing addressed. **Recorded lean**, on the same reasoning design ratified twice for the counts and the ghosts.
- **(b) A thin object per machine-written card.** Satisfies *"the field exists from birth"* literally and gives the human override a place to live - which is the one thing a computed state genuinely cannot do, since a person cannot correct arithmetic. Costs an object against the twenty-ninth stamp's budget, and row volume equals card volume.
- **(c) The vendor's `ALTF__Confirmed__c`.** **REFUSED**, for the reasons in section 2: a boolean cannot hold three states, and it is the seller's own act rather than our count.

The half worth design's eye is not COMPLETED itself but **the human override**: a computed lifecycle cannot be corrected by a person, and "human edits beat the machine forever" is standing law. Nobody has asked for it yet, which is why this parks rather than builds.
