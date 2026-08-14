# a23 · the refusal diagnosis · all eighteen, read from the org

**v1.0 · 8 August 2026 · Satellite, outside the audit chain. Companion to the adjudication sheet's §11, which carries the grading this document explains. Produced design-side by reading `AAO_Verification_Note__c` on the eighteen refused Identified pairs of run `em0808-a23` directly from sandbox `altify--aossb2` (org `00DWD00000DV7iT2AT`, IsSandbox true, confirmed before the query). Read-only. Nothing here is built.**

---

## Why this document exists, and what it corrects

Matthew's grading of a23 returned **0 of 18 refusals correct**, against 21 of 23 on the training set. Design's first reading of that number, stated to Matthew in session and **marked wrong here rather than deleted**, was: ~~call 3's restraint was never a principle, it was a tuning artifact, and on foreign speech it refuses nearly everything.~~

**That reading was wrong about the location of the defect and right about its nature.** Reading the eighteen stored reasons settles it in one pass:

> **Call 3 is not broken. Every one of the eighteen notes is coherent, specific, and faithful to a contract's own text. Not one is erratic. The tuning is real, and it lives in the CONTRACT PROPOSITIONS, not in the verifier that applies them.**

The correction matters because it changes the repair completely. A verifier that had collapsed would be reworded. A contract set written against speech that happened to match it is a different problem with a different fix, and rewording call 3 on top of it would have replaced a tuned defect with a tuned fix, which is exactly the failure the diagnose-before-rewording rule exists to prevent.

**The field this rests on:** `AAO_Verification_Note__c`, whose own schema description reads *"Written by: call 3. Read by: the refusal grading, which is how a call-3 charter earns a change. The reader's reason in its own words."* The field was built for this. Its predecessor, `AAO_Interpretation__c`, held only the last refusal per pair and lost two of nine on 3 August; the per-row replacement is what made this diagnosis possible at all, and it is the D1 lesson paying for the second time.

---

## The eighteen, grouped by mechanism

| Mechanism | Rows | Count | Matthew |
|---|---|---|---|
| **Political · "not the one called on to make it happen"** | poq1, poq2, poq3, poq6, poq11, poq12 | **6** | all TRUE |
| **Sentiment · the wrong-scope guard, "no stance toward us or our solution"** | seq1, seq2, seq3, seq4, seq6 | **5** | all TRUE |
| Political · "carries out projects once they are approved" | poq7, poq8 | 2 | both TRUE |
| Political · "collects and provides information to people of power" | poq4, poq5 | 2 | both TRUE |
| Buyer Role · EVALUATOR, the narrow evaluation reading | buq6 | 1 | TRUE |
| Buyer Role · USER, explicit product-use required | buq9 | 1 | TRUE |
| Criteria · condition not tied to evaluating or choosing | deq3 | 1 | TRUE |
| | | **18** | |

**Thirteen of eighteen are two mechanisms.** Both are single clauses in single propositions.

---

## 1 · The six · Political Structure is written as an authority test

Every one of the six notes turns on the same phrase. Verbatim, from the org:

- **poq1** · *"The quote only describes them forwarding the MSA to legal for updating; it does not assert that they are the one required or called upon to make the thing happen."*
- **poq2** · *"The speaker asks others to expedite and expects an update from them, indicating the person referenced is not the one called on to make it happen, the words point to a third party owing an update."*
- **poq3** · *"The words describe a generic process (documents will need to be uploaded and forwarded through approvers) without assigning the action to this person."*
- **poq6** · *"The words show the speaker volunteering to raise something with Neeraja; they do not indicate anyone tasking or calling on this person to make it happen."*
- **poq11** · *"The speaker explicitly disclaims being the approver, which answers the question in the negative rather than affirming they are called on to make it happen."*
- **poq12** · *"The words disclaim authority, I can only ask the question, they show the speaker relaying a request to others, not that they are the one called on to make it happen."*

**The finding: the proposition asks who is called on to make it happen, which is a test of authority. Matthew is grading membership in the structure.** Jefferson routing the MSA to legal, chasing the expedite, describing the Coupa chain and its approver ladder, and saying outright that he is not the one who approves, are in Matthew's reading a man operating inside his organisation's political structure. In the contract's reading none of them qualify, because none of them make him the decider.

**poq11 and poq12 are the sharpest, and they name the gap precisely.** The verifier read *"I'm not the one who gives that approval"* as answering the question in the negative. Under TRUE-OR-NOTHING a negative state establishes from its own affirmative words, and the affirmative content of that same sentence is a political-structure fact: he knows the ladder, he knows where it goes, he is inside it without holding the pen. **The contract set has no proposition for "describes the approval structure without holding authority in it."**

**So the repair class is ADDITIVE first, not corrective.** These six are not a contract that is worded wrongly. They are a proposition the set does not carry.

## 2 · The five · MENTOR's two words are pulling against each other

- **seq1** · *"…internal approval routing and past roadblocks at the CFO level, not any warmth or advocacy stance toward us or our solution."*
- **seq2** · *"…concern that their own internal message be socialized to a colleague, saying nothing about their stance toward us or our solution."*
- **seq3** · *"The quote merely reports that they asked to expedite the process, voicing no attitude or warmth toward us or our solution."*
- **seq4** · *"…a logistical statement about raising something with a colleague and voices no stance toward us or our solution."*
- **seq6** · *"…describes their internal document and approval process, voicing no stance toward us or our solution."*

**This is the wrong-scope guard §P8.3 adds for sentiment, doing exactly what it was built to do, on five rows instead of the one it did it on at v0.7.** Nothing has drifted. The guard is correct code executing a rule that is now in tension with the label it guards.

**The question underneath is METHODOLOGY AND MATTHEW'S, not a defect and not design's to default.** The locked ledger says **MENTOR is conjunctive and org-directed.** Those two properties are now pulling in opposite directions on real speech: Jefferson pushing his own legal team to expedite our paperwork is org-directed action that advances us materially and voices nothing whatsoever about us. Either advancing us inside their org establishes mentorship without a voiced stance, or it does not and these five refusals are right and Matthew's TRUE grades are the thing to revisit. **Design has no standing to pick, and the rows stay as standing assertions that currently fail until he rules.**

Recorded so the history is not lost: this is the third time this guard has surfaced. It was one of the two wrong refusals on s1 (§9 finding 3), it was examined by CODE at v0.7 and left standing under the failed-twice law, and it now has five more specimens on unseen speech. **Under the failed-twice law it has earned structure. It has not earned it from design; it has earned Matthew's ruling.**

## 3 · The remaining seven, one line each

- **poq7, poq8** · the proposition asks whether the person *carries out projects once they are approved*. Ryan saying he gets to start this one, and that he looks forward to getting into the sandbox and building it out, is a person describing exactly that and never in those terms. Same shape as group 1: the words carry the fact, the proposition asks for a declaration.
- **poq4, poq5** · the proposition asks whether the person *collects and provides information to people of power and influence*, the Outside-Political-Structure route. Jefferson wanting his message socialised to Jacob, and Ryan intending to raise something with Neeraja, are single instances rather than a practice. **This is the instance-for-pattern boundary and the verifier is on the defensible side of it.** These two are the weakest of Matthew's eighteen TRUE grades and design says so plainly.
- **buq6** · EVALUATOR refused because the words are *"about correcting a customer's name for document consistency, not evaluating options, capability, price, terms, or fit."* **This is §8 defect 2 returning.** That defect was recorded as repaired at v0.6 on the training set; it was verified only there, and the tuned-behaviour law predicted exactly this.
- **buq9** · USER refused because the words say *"nothing about using any purchased product or service."* Ryan saying Jefferson goes to the next adventure and he starts this one is a handover, and the contract wants product-use language. Note that **buq8, USER, on adjacent bytes, was upheld and graded TRUE**, so the contract is not uniformly too narrow; it is sensitive to whether the sentence names the thing.
- **deq3** · CRITERION refused: *"reports legal's general preference and a pending confirmation, but does not tie a condition to evaluating, choosing or proceeding with a solution."* **Its own FORMAL half, deq4, was upheld on identical bytes.** The row-dependency blind spot, with its verbatim proof.

---

## The caveat design owes before anything changes

**Some unknown share of 0-of-18 is STAGE, not generalisation, and one call cannot separate them.**

a23 is a late-stage contracting call. The speech is procedural: routing paperwork, chasing legal, naming approval ladders, disclaiming authority, handing over. Propositions written for discovery-stage speech, where people declare preferences, voice stances and describe what they are looking for, have very little to bite on in that register. A discovery call from a different account might score far better on the same contracts without a single line changing.

**This is the training-set hazard's second face and it has no cheap answer. The instrument that separates stage from generalisation is Matthew's production transcripts at mixed stages, and this finding moves them from wanted to load-bearing.** Until they exist, every repair proposed against these eighteen carries an unmeasured risk of being a repair against one call's register.

---

## What follows, and what does not

**Does not follow: reword call 3.** The verifier is applying its contracts faithfully and there is nothing in these eighteen notes that a call-3 change would improve. Design withdraws the suggestion that it might, made in the CODE inbox's twenty-second stamp before this diagnosis existed, and corrects it at the twenty-third.

**Follows, for CODE, and it is a read and a report before it is a build:** put the eighteen notes beside the declared contract texts and report, per row, **absent versus present-and-too-narrow.** Those are different repairs. An absent proposition is additive and cannot break what already passes. A narrowed proposition is a wording change on a live contract and every existing standing assertion is exposed to it.

**Follows, for Matthew, and design will not default it:** the MENTOR question in section 2. Conjunctive and org-directed are in tension and only he can say which wins.

**Follows, for design:** the adjudication sheet's §11 finding 2 is amended by this document; the Board's tuned-behaviour law is amended to place the tuning in the contract set rather than in call 3. Both corrections go in place, marked, never deleted.

---

*End v1.0. The eighteen notes are quoted from the org and are the evidence; everything else here is reading, and is marked as reading.*
