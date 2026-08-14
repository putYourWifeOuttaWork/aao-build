# AAO · Level of Relationship (LOR) in the Politics charter · design draft v1.0 · 13 August 2026

**Satellite. Drafted at Matthew's direction ("we need to get LOR into politics as an output and tracking mechanism... valid up and across the organization and over time") from the seventy-eighth stamp's discovery and options and his rulings recorded at the seventy-ninth, which are its authorizing sources. This draft becomes buildable law on Matthew's plain-word yes in conversation, recorded in the ledger; until then CODE builds nothing from it. Charter absorption happens at the next design fold; this file is what it absorbs.**

## The rulings this draft is built from

The measure is evidence-established levels with a deterministic floor (Matthew, 13 August: "sounds good, simple ontology, should be simple enough to identify and provide evidence"). The target is human-owned and the machine ignores it completely (his words). The seller's own account of the relationship establishes nothing: SELF-PRAISE IS NOT STANDING. Arithmetic cannot claim depth (the In-depth precedent), so occasion counting supports only the bottom rung. Pair attribution binds a specific seller only where the words bind one; an unbindable establishment is HELD, never guessed. Production is read-only unconditionally; rows we did not write are never modified or deleted; human edits beat the machine forever.

## The vendor surface, read from both orgs (seventy-eighth stamp)

`ALTF__LOR_Relationship__c`: one row per seller (`ALTF__User__c`, nullable) times customer person (`ALTF__Contact__c`, required), deal-agnostic, no note field, no watermark surface, no per-dimension modstamp. `ALTF__CurrentLOR__c` stored values: `Unknown, Vendor, Credible Source, Problem Solver, Trusted Advisor`, display labels carrying ranks 0 through 4. `ALTF__DesiredLOR__c` is the target and is not ours. The rank-in-label shape means the LOR ranks and label map ship as `AAO_Map_Value__mdt` rows, org-overridable, keyed to stored values, the seventy-seventh stamp's machinery extended unchanged. The uniqueness key of the junction (whether one row per Contact-User pair is enforced) is a capability fact and verifies from the runtime before the create leg ships.

## The contracts · three model questions, one deterministic floor

Family: `LOR`. Codes `AAO_LOR_CS`, `AAO_LOR_PS`, `AAO_LOR_TA`. All three ride the same two comprehensive reads as questions, verify in a family-homogeneous batch, and land at the join per the one-pass law. The subject of every pair is the CUSTOMER PERSON; the establishment carries the SELLER it binds to, making these the first pair-keyed establishments in the system. Only the customer's words and enacted in-call behavior establish; the seller's words about the relationship establish nothing for any rung.

**VENDOR, the floor, no model call.** Co-presence of a seller and a customer person on an admitted external conversation establishes at least `Vendor` for that pair, derived from the roster exactly as coverage derives from occasions. Arithmetic claims only what arithmetic can: that they met as vendor and buyer.

**CREDIBLE SOURCE (`AAO_LOR_CS`)** · Did this person, in their own words, seek or accept the seller's perspective as credible on the person's own problem space, beyond the seller's product? Elements: the ask or acceptance is theirs and directed at the seller side; the subject is their own business, industry, or problem, not the vendor's product, demo, or price. Guidance for the verifier: product and price questions are vendor-level duty and establish nothing here; a courtesy compliment is not credibility; answering the seller's question is not asking one.

**PROBLEM SOLVER (`AAO_LOR_PS`)** · Did this person, in their own words, bring a problem of theirs to the seller and work it with them in the conversation? Elements: the problem is theirs and they voice it to the seller side; their words engage the seller in shaping the approach for their case (testing how it would work for them, volunteering constraints so the answer fits, asking the seller to help think it through). Guidance: answering discovery questions is participation, not bringing a problem; ENGAGEMENT IS NOT RELATIONSHIP; a required product evaluation is duty, and AN EVALUATION IS NOT A CONSULTATION.

**TRUSTED ADVISOR (`AAO_LOR_TA`)** · Did this person, in their own words, seek the seller's counsel beyond the current purchase, act on the seller's guidance inside their own organization, or deliberately share strategic or internal context so the seller can advise them? Guidance: mentor-grade proof standard; the deal's own mechanics never qualify; access, enthusiasm, and warmth are not trust; each element must be carried by the quoted words or nothing is established.

**Guards, named:** SELF-PRAISE IS NOT STANDING (either direction: the seller praising the relationship, or the customer praising the seller as courtesy). ENGAGEMENT IS NOT RELATIONSHIP (attending, answering, and cooperating with a sales process establishes nothing above the floor). The demo-narration trap applies whole: narrated fictional relationships establish nothing. The courtesy conjunct's logic extends: the behavior must point at the seller as counsel, never at the meeting or the occasion.

## Pair attribution

The establishment binds the seller the words address or name; where only one internal participant is on the call, the binding is deterministic from the roster. Where the behavior addresses the vendor team collectively and more than one seller is present, the establishment is HELD with its evidence, the identification-flag pattern, never split, never guessed, never written to a team-level row. Internal people appear here lawfully for the first time as the seller key of a pair, never as subjects on the buying side; the internal-domain gate is untouched.

## The standing value · v1.0 mechanics, deliberately simple

The standing value per pair is THE HIGHEST RUNG WITH AN UPHELD ESTABLISHMENT, floor included, rebuildable from claims in evidence-occurred order like every answer in the system. Rungs never sum: three Credible Source establishments never make a Problem Solver; REPETITION IS NOT ELEVATION (repetition is reinforcement, the card counter's word, and stays out of this family). Trusted Advisor is proof-gated: only an upheld `AAO_LOR_TA` establishment reaches it. THE MACHINE NEVER LOWERS A LEVEL in v1.0: relationships sour in ways absence cannot evidence, so down-moves are the human's, and a human edit wins forever. The sentiment counter's full machinery (netting, clamps, voiced-state ceilings) is deliberately not imported; it is where down-moves would land if ever ruled.

## Projection

The machine writes `ALTF__CurrentLOR__c` only, stored values only, ranks and label map from the `AAO_Map_Value__mdt` LOR rows. The map-dimension pattern applies whole: our watermark lives on our side; a non-blank value our watermark does not claim was put there by a human and is never touched; a blank field on an existing pair row may be populated under our watermark and is retractable; where no row exists for the pair, creation goes behind the create-leg record. `ALTF__DesiredLOR__c` is never written, never read, never derived from. Rows with no seller (`ALTF__User__c` null, 104 of production's 213) are never ours to touch. Never-blank applies within this family exactly as ruled: where evidence establishes at least one rung, the standing value writes; silence stays silence.

## The measurement-first run (approved, Matthew, 13 August)

Before anything projects, the three questions run READ-ONLY over the frozen graded corpus (the three Emerson calls and Project Farma), no projection, no junction writes, reporting establishments per rung per call with quotes. The riskiest unvalidated assumption is that real calls carry level-grade evidence at a usable rate; sentiment's low yield on a23's register is the warning, and this run measures it before any build asserts it. It shares the Emerson stacked vehicle opportunistically, never as a dependency. Counting statuses stand: Emerson and Farma are real speech and count under the inverted method when Matthew grades; the Wells Fargo corpus is authored and counts toward nothing, mechanism only.

## What is deliberately not in this draft

DesiredLOR in any form. Machine down-moves. Account-level roll-up (the Claim's four keys already record account grain; the roll-up is grouping, later, with the Account Manager product). The team-connection surface (who on our team holds the relationship; recorded as a Surface-era read of the pair grain, it costs nothing now and is named so the Surface fold finds it). Org-level relationship rows. LOR flags (the target-versus-actual gap is a flags-fold consumer and nothing more today).

## Acceptance

Mechanism, on the Wells Fargo stacked corpus: a chosen pair's CurrentLOR moves Vendor to Credible Source to Problem Solver across authored stages, every move walking back to verbatim words in the Inspector, while a control pair stays at the floor; no seller self-praise moves anything. Measurement, on real speech: the read-only run's per-rung counts, graded by Matthew on the surface once projection is authorized.

## Cost

Three questions added to the same two reads, one family-homogeneous verify batch, a deterministic floor in code, join increments. The cost model prices the family before it declares, per the standing sixteenth-stamp obligation.
