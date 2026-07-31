# AAO Corrections — the Answer / Claim correction

**v1.0 · 31 July 2026 · Matthew Weisberg**
**Status:** ruled in session, 30–31 July. **Authoritative until absorbed** into Architecture, Glossary, Object Model and Data Flow at their next version bumps.

> **Why this file exists rather than four version bumps tonight.** The rulings below invalidate vocabulary and entity statements in all four documents, and Flag is still open. Bumping four documents now and again tomorrow would do the work twice and produce two rounds of stale cross-references. This record is versioned, states what changed, and marks what was wrong as wrong, which is what the standing rule requires. **Where this file and any of the four disagree, this file wins until they are bumped.**

---

## 1 · The naming defect, and what was wrong

**The word *Claim* was attached to the upserted current-state row.** That put the sentence *a claim is overwritten* into the design. It is wrong in plain English — a claim is one assertion, made once, by someone, on the strength of something — and it was rejected on sight by the person who designed the system.

The documents recorded this as a naming gap and said the two records were "correct, because they are different rows serving opposite questions." **That was too generous.** A word that makes a correct architecture sound broken to its own author is a defective word, and the defect had a cost: it hid the fact that Journal Event existed only because Claim was busy doing the mirror's job.

**Corrected:**

| Was | Is | What it is |
|---|---|---|
| Claim (the mirror row) | **Answer** | Current state. Upserted. One per question per subject |
| Journal Event | **Claim** | One establishment, from one piece of evidence, never edited |
| *(no home)* | **Claim Basis** | The state rows a claim rests on, with their values frozen at claim time |

**Journal Event is retired as an entity.** Its four keys, two clocks, subject identity and before-and-after values move onto Claim unchanged. Nothing it carried is lost. What disappears is a second immutable row recording the same event, which was two accounts of one fact with no mechanism to say which had drifted — the same defect the proposition snapshot is explicitly forbidden from creating.

**Entity count: fourteen becomes fifteen.** Journal Event removed; Answer and Claim Basis added.

---

## 2 · The three layers, stated once

Confusion here caused the defect, so it is written plainly.

**Candidate — the proposal.** *I claim this, because of that.* One row per proposition considered per pass, carrying the proposed verdict, the spans, the interpretation used, how far it got, and what happened to it. Rejected, abstained and declined rows are the decision log. **A decline lives here and nowhere else**, because a decline establishes nothing and writes no claim.

**Claim — what was accepted.** Immutable. Carries what the answer was before and what it became, the quotes, the coverage, the actor, the charter and rubric version, and both clocks. **Replaying claims in evidence-occurred order must reconstruct every answer exactly.** That is the exit test.

**Answer — what is true now.** Upserted, uniquely keyed, the target of human precedence and the source of every projection. Carries the accumulated quotes, so reconciliation months later reads a hot row with the words on it rather than replaying history.

**Progress is visible because claims never move.** Claim one says the answer went to `UNVERIFIED` and says that forever. Claim two says it went to `TRUE`. The answer says `TRUE`. All three are readable at once, and the delta between claims is what a brief or a retrospective reads.

---

## 3 · No claim-to-claim parentage

**Ruled.** Claims do not have parent claims. Claims that bear on the same question relate by sharing an answer, which is a subquery, not a hierarchy. A first-claim-as-parent structure was considered and rejected: it adds a traversal that the shared key already provides, and it invites a tree where there is only a sequence.

---

## 4 · Claim Basis, and why it is not a plain junction

**A claim resting on state must name the row and quote its value.** That rule already existed, on the grounds that a cited row will be edited afterwards and a citation that only points is a citation that rots. **It had no home.** Claim Basis is the home.

**Half frozen, half live.** The snapshot of what the row said sits in immutable fields on the junction. The live record comes through the lookup. One subquery returns both, so a claim can show that a qualifier read *unknown* when the claim was written and reads *known* today.

**What it may point at, and this is the part that makes cross-referencing real:** map rows, insight cards, decision criteria, **other answers**, **qualifier statuses**, and shadow people. A single question can therefore rest on several people, several cards, another methodological answer and a sales-process qualifier at once, each with its own frozen value.

**Each row names which part of the proposition it covers.** That is what makes partial coverage queryable rather than buried in JSON, and it is what a flag reads to say *here is what already stands, and here is the piece still missing*.

> **The discipline this object needs, recorded now because it will decide whether the object stays useful.** **It records what was cited, not what was available.** A junction pointing at six types and freezing state is exactly the object that becomes a general-purpose context dump, and a claim listing everything on the deal reads as far better supported than it was. **If a row cannot name which part of the proposition it covers, it does not belong on the claim.** Reconciliation's reads stay bounded to the proposition at hand; this junction records what was cited and does not authorise scanning the deal.

---

## 5 · What each document owes

**Glossary.** *Claim*, *Mirror*, *Journal*, *Receipt* and *Journal Event* all need rewriting, and *Answer* needs adding as a term of ours distinct from Altify's assessment answer. The retired-terms table gains: *Claim, meaning the current-state row → Answer*. The vocabulary-mapping table's Journal Event row becomes Claim.

**Object Model.** Section 4 is titled and argued around *Claim's key*; **that key is now Answer's key** and every word of the reasoning holds unchanged — typed lookups plus discriminator plus one derived unique text field, null-and-flag on delete, `DUPLICATE_VALUE` as a merge path, the composer frozen, versioned and single-writer. Section 3's merge list gains Journal Event's absorption into Claim, with its condition for being wrong: if a non-establishment change ever needs an append-only home that Candidate cannot serve. Section 7 gains the seventh memory table.

**Architecture.** The entity inventory: Journal Event out, Answer and Claim Basis in, fourteen to fifteen. *Claim is a mirror row, a receipt is a journal row* is superseded — they are Answer and Claim, and the naming gap it described is now closed rather than tolerated. The replay invariant is restated as *replaying claims must reconstruct the answers exactly*. The memory section adds the decision-log table.

**Data Flow.** All three diagrams: the *Journal* box becomes *Claim*, and *Commit* forks into a claim written and an answer upserted. Invariant 3 and the reconciliation outcomes need the new nouns. Reconciliation's *reinforcement appends a receipt* is correct and needs the clarification below.

---

## 6 · Two corrections carried from the same session

**Reinforcement receipts — two documents disagreed and both were right about different cases.** Data Flow said a verdict matching what already stands appends a receipt; Architecture's deduplication passage said a second identical arrival produces no receipt. **The same evidence arriving twice produces nothing**, because the evidence watermark stops it being read again. **New evidence confirming something already standing writes a claim with outcome `Reinforced`**, moving no answer value, and it must, because guidance orders a person's criteria by what they have pressed most recently and most often — a count of exactly these rows. Neither document said which case it meant.

**A seventh memory table.** The six specified are the journal (now Claim), fulfilment, surfacing, roll-up, and the two snapshots. **The decision log is designated for the library and has no table among them.** Complete candidate logging was ruled conditional on retrospectives being able to read it after retirement. Engagement category, evidence-occurred clock. **A stream's category and clock lock at creation**, so this is decided rather than discovered.

---

## 7 · Name collision to watch

Altify's assessment answer field is `ALTF__Answer__c`. Ours is `AAO_Answer__c` and the records are distinct, but the word is overloaded in conversation. In writing or speaking to Toby, Bill or David: *our answer row*, or *the assessment answer*. Never bare *answer*.

---

*End v1.0. Field-level detail for all six objects named here is in the AAO Field Tables, which is the build packet. Flag is the only Wave 1 object still open, and it is not in the replay path.*
