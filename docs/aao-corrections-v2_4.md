# AAO Corrections and Change Record, v2.2

**v2.4 · 2 August 2026 · Adds scope, licensing and partial product ownership as a build phase of its own (§4c), and the Politics sequencing ruling (§4d).**

**Changed in v2.4.** **Three scoping filters become global rules**: licensed sellers only, opportunity types excluded by configuration, and **module ownership**, which is new and is not graceful absence — the objects exist because the package is installed and the customer is not licensed, so a write fails on permission rather than on absence. The shape uses a property already ruled: claims land on our objects and projection is what varies, so **a customer with relationship map only still gets the whole evidence engine.** The **admin error log** is the first admin-facing surface and needs expected-unavailable treated as configuration rather than error. **None of this is testable in Altify's own org**, which holds every module, so the harness is permission sets rather than a differently-licensed org. Also clarified: Opportunity and Account are never written and that is absolute, while **Contact remains toggleable exactly as originally designed** — toggle on, we write it and its children; toggle off, shadow persons persist and cannot reach the Altify map, because the map row's Contact lookup is required. **Politics opens on influence and conflict**, because that half needs only the relationship map.

**Changed in v2.3.** **Flags get no charter** — existence and clearance stay deterministic, and the nuance Matthew was reaching for lives in guidance, where it is already named as owed. **Contention splits three ways**, and the configurable part is authored at setup and frozen rather than run by a model each night, because Calculated Insights are immutable once shipped. **Persona goes in the People charter as a fourth emission**, additive only, which dissolves the cross-deal collision the schema would otherwise create.

---

**v2.2 · 2 August 2026 · The reconciliation. Everything from the 2 August ontology session, checked line by line against Architecture v2.9, Glossary v2.0, Data Flow v2.3 and this record's own v2.1 — sorted into what it confirms, what it corrects, and what it breaks.**

**Changed in v2.2.** A full session of design ran against a stale reading of the corporate record: project-knowledge retrieval served **Glossary v1.9 while v2.0 was current**, which is the retrieval hazard those documents warn about, working exactly as documented. The four current documents have now been opened directly rather than searched. **The session's work survives the check, with one apology, three corrections to the corporate record, and four things it broke that must reopen.** The corrections are the valuable half: one of them raises the standard for an entire class of proposition.

**Who this is for.** Same as v2.1: the corporate project's agent, carrying results back into the canonical documents. Stamped corporate documents as of this writing: **Architecture v2.9, Glossary v2.0, Object Model v2.0, Data Flow v2.3**, Theory v1.3, Computable Share v1.5. This record supersedes them where they disagree. Charter detail lives in `aao-charter-design` (now v1.7), field detail in `aao-field-tables` (v0.13).

---

## 0 · The apology, recorded because the lesson is the point

**Matthew said solution cards from line items were something we had already agreed to do. He was right and I told him it was parked.** Glossary Section J has carried it as settled: *Solution Card — two kinds. **Linked**, established by an opportunity line item through `Product2.ALTF__Solution__c`, cited by the line item record, free, state-established, no model.* Plus **Solution Coverage**: the set difference computed in Apex, missing cards **created silently and not flagged**, on observed data 3 of 94 line-item pairs had a card.

I checked charter design v0.5, found *quick-links from insights to solution cards* parked as guidance enrichment, and reported that as the answer. **They are different items.** The link from an insight to a solution card is guidance enrichment and is still parked. The creation of a solution card from a line item was ruled long ago. **The lesson is the one this record already contains twice: open the document, do not search it, and do not answer from the nearest-looking passage.**

**What survives from 2 August on solutions:** the card / edge distinction, which the glossary does not state — the card is state and the edge is evidence, and an edge asserting that a product addresses an obstacle can never come from a line item. And the unlinked-Solution flag, which is a **different gap** from the one the glossary declines to flag. The glossary refuses to flag *a line item with no card*, correctly, because the system just closed that gap itself. **Ours flags a card with no edge**, which nothing closes and nobody sees.

---

## 1 · What the session CONFIRMS

**The loop order is an invariant and the session respected it.** Loop one is Relationship, Insight and Link, committing maps to the standard Opportunity (`006`). Loop two is Assessment, reading the transcript **and the maps loop one just committed**, writing to the Altify Opportunity (`a0y`). Our People, Problems and Politics are exactly loop one's three charters under different names. **Consequence worth stating plainly: Politics is not "after" Problems, it is the third peer in the same loop, and loop one is incomplete until it exists.** Every assessment verdict computed today reads a map with no influence or conflict edges in it.

**Reconciliation's outcome routing matches what the session ruled independently.** Data Flow §1a: same verdict standing → reinforcement appends a receipt and the mirror is untouched; contradicting human-authored value → contention flag, never a write; partial element coverage → `UNVERIFIED` carrying the spans that exist. Those are the Problems charter's reinforcement rule and the annotation law, arrived at from the other direction.

**Coverage as state, not judgment, is consistent with the speaker-gate ruling already in v2.1** — a record has no utterer, so for basis State the gate records not-applicable and names the cited row rather than skipping.

**Buyer Role as assertion propositions is already the glossary's shape.** Section I: categorical dimensions are *assertion propositions — is X the Decision Maker, TRUE / FALSE / UNVERIFIED, with a span*. The session's ruling that we author Buyer Role's questions ourselves is the missing half, not a divergence.

**The three items v2.1 named as deliberately unsettled: two are now closed.** Charter output schemas for People and Problems are written. The machine-confirmation projection question is ruled as an autonomy level. **The Politics charter remains open and is now the only one of the three still standing.**

---

## 2 · What the session CORRECTS in the corporate record

### 2.1 · Glossary Section B is wrong, and this is the most consequential finding of the session

The glossary states, of schema-sourced propositions: *the field label plus the value set is the rubric. **Nothing else. There is no sentence to find, because Altify never wrote one.***

**Altify wrote one. Several, per dimension.** Recovered verbatim from production on 2 August by walking the *Help me select* wizard read-only:

- **Support · five questions.** Has this person expressed a preference for a specific solution? · Has this person told you they prefer your solution over all other alternatives? · Is this person willing to provide you helpful information when asked? · Does this person believe your solution is critical to their success and do they sell internally for you in your absence? · Is this person mentoring you by providing guidance, political insight, or competitive information?
- **Political Status · three questions, three-way options.** Does this person approve and sponsor initiatives, or do they execute projects after they are approved? [Approves/Sponsors · Executes · Not sure] · Do others seek this person out for advice and direction? [Yes · No · Not sure] · Does this person control the outcomes or are they called on to make it happen? [Controls · Implements · Not sure]
- **Coverage · three questions.** Have you or a team member met with this person? · Have you or a team member recently had multiple meaningful conversations with this person? · Do you or a team member regularly and routinely have high quality conversations with this person?
- **Buyer Role · no wizard.** Manual pick with a definition per value. The one dimension where we author.

**The glossary is right about the answer path and righter than it knew.** `_Answer__c` holding `Yes;Yes;Yes;Yes;No` is the wizard, not the question, and must never be read as proposition text. Production confirms it harder: a live row whose answer path resolves to **Supporter** under the recovered tree carries a stored value of **Mentor**, because the wizard has a *Select manually* toggle and a later manual pick leaves the old path behind. **The questions are the asset; the answers are exhaust.**

**Why this raises a standard rather than adding a fact.** Schema-sourced propositions have been running on a field label where record-sourced propositions run on verbatim authored text. That asymmetry is now closed. **Every dimension gets proposition text from the customer's own methodology**, discovered rather than paraphrased, which is the same law that governs the assessment side.

**Retrieval note for whoever bumps the glossary: the text is in the managed package UI, not in any queryable table.** `ALTF__Translation__c` is empty; the platform `Translation` object holds only language enablement. Whether the strings are custom labels reachable through the Tooling API is an open read.

### 2.2 · The insight ontology is authored too, and Solution's definition changes a ruling

Each insight type carries an authored admission test behind its *What is a…* link, with an examples list beside it. Goal, Pressure, Initiative and Obstacle carry three questions each. **Solution carries four, and three of them are about links to other cards** — how does your Solution address the Obstacles for your customer's initiative, what Pressures will it have the most impact on, how does it contribute to achieving their Goals, and **would a key player be able to articulate your unique business value from this Solution.**

**So a Solution card with no edges fails Altify's own published definition**, which is a far stronger basis for the unlinked-Solution flag than the one it was ruled on. And the fourth question is the strongest evidence proposition on the insight map, because it asks whether the buyer said the value back in their own words — checkable from a transcript, from a subject set (`ALTF__Is_Key_Player__c`) that is already closed and derived.

**Terminal states are per type and no two share a lifecycle:** Goal → Achieved, Pressure → Resolved, Initiative → Completed, Obstacle → Overcome, Solution → Implemented.

**These tests are guidance, not admission gates. RULED.** They are discovery-completeness prompts wearing the clothes of definitions — *do you know how the decision maker is measured* tests the seller, not the card. Admission stays on genuineness. **The authored text must stay out of the reader's input**, or the model treats it as criteria whatever the charter says.

### 2.3 · The person-to-card relation: four questions, two stored values

The methodology asks **who is responsible for** a Goal and an Initiative, **who is impacted by** a Pressure and an Obstacle, and separately **who told you** about any of them. `ALTF__Insight_Card_Contact__c.ALTF__Type__c` carries only `Informer` and `Owner`, so **impacted-by and responsible-for are the same row.** That distinction is what makes guidance addressable: *this takes that pressure off your shoulders* versus *you own this obstacle*, which means nothing to the person hearing it. **Ruled: derive from card type when reading existing human rows, record explicitly on our own claims**, because the buckets are demonstrably noisy.

**And the causal chain is taught but not stored.** Pressure-to-Goal linkage is free text on `ALTF__Impact__c`, a field doing double duty as desired-outcome for Initiatives. Glossary Section J is right that `ALTF__Insight_Card_Edge__c` runs the full chain in principle, but the schema carries **one** typed target, `ALTF__Solution_Insight_Card__c`. Altify's own MCP server calls *Pressures → Goals → Initiatives → Solutions* the healthy pattern while nothing can query whether it holds. **This is Politics charter territory and it is larger than the person mapping.**

### 2.4 · Smaller corrections to v2.1's own numbers

**Nine objects live, not eight** — `AAO_Participant__c` added. **153 tests green, not 139.** **Reserved-word collisions are six, not five:** `commit`, `json`, `system`, `merge`, `any`, **`when`** (from `switch`). Four refuse loudly; `json` and `system` resolve silently and are the dangerous pair.

**Claim Basis declares eight cited types and has built two.** v2.1 records six typed lookups; the org has lookups for `Answer` and `Map_Row` only. `Source` is added (a Coverage claim cites the Sources it counted) and `OpportunityLineItem` is added. **`Product2` is deliberately not added** — reachable by traversal from the line item, so citing it separately would cite a classification rather than a fact about this deal. **The rule for what earns a lookup: a cited type gets one when we will compare its live state against the frozen snapshot.** That is the whole reason the object is half frozen and half live, and a text Id cannot do it.

**Two laws the build taught us, both from the deploy refusing a design.** `AAO_Raised_At__c` is immutable, so a reopened flag cannot restart its clock — **a flag ages from when its question became askable, not from when the answer last turned bad**, or a deal launders itself by closing and reopening. And **anything hung off an after-insert trigger can turn our defect into the customer's lost evidence**, because a throw there rolls back the row that caused it; the safe direction is always to lose the derived thing rather than the evidence.

---

## 3 · What the session BREAKS and must reopen

**These are real and none was noticed while ruling, because the memory plane was not in view.**

### 3.1 · Cold seeding is broken by the tree ruling · MUST REOPEN

The session ruled that **ontology owns the rung**: a person's Support is what Altify's tree computes from five propositions, and the ±1 delta law and the −3…+3 clamp were withdrawn for ontology-backed dimensions.

**Data Flow draws cold seed as a boundary crossing** — Data 360 to core, once per opportunity — and the glossary defines **Prior** and **Attenuation**: a historical Mentor seeds at Supporter, paying a rung for having been earned somewhere else, and a seeded value is a prior rather than an establishment because citations do not cross deals.

**Under the tree there is no ladder to seed a position on.** The rung is derived from five propositions that are per-deal by construction, so a new opportunity starts with all five null and a person with a decade of history reads at the floor. **Either cold seed writes a rung directly, which gives the rung two producers and breaks the derivation, or cold seeding dies.** Neither is acceptable as it stands. **Matthew's, and it is the largest thing this reconciliation found.**

### 3.2 · Coverage has no home for its window · MUST REOPEN

Coverage's third question asks whether you *regularly and routinely* have high quality conversations — a window far longer than the warm window. **Sources retire from core after thirty days**, and `AAO_Participant__c` is **not among the seven memory tables** (Claim, Fulfilment, Surfacing, Roll-Up, proposition-state snapshot, rubric snapshot, decision log). So Coverage cannot be a core count at the grain it actually needs. **Either participation streams as an eighth memory table, or the counts roll up before their Sources retire.** Not designed either way.

### 3.3 · The People fan-out has no cardinality guard · MUST REOPEN

Invariant 9: every creation path carries an upper bound, and exceeding it means abstain and flag. The People handed unit is **person crossed with dimension**, so nine people against six dimensions is fifty-four findings in one pass. The session named the output-token ceiling and **never applied the cardinality guard**, which is the law that already exists for exactly this.

### 3.4 · Delta reconstruction needs restating, not repairing

The glossary says *state is reconstructible from the journal by summing deltas.* Under the tree it is reconstructible from the five contract answers instead. **Same guarantee, different mechanism** — replay still works and the exit test is unaffected — but the sentence in the glossary becomes wrong for ontology-backed dimensions and must be restated rather than left standing.

**Historical contention survives.** Ordinal contention is integer subtraction across rungs, and the rung is still an ordinal label however it was derived. Supporter today against Enemy historically is still three rungs. No change needed.

---

## 4b · Persona · RULED 2 Aug · the People charter's fourth emission

**Persona goes in the People charter, not Politics.** Three reasons. The glossary's own reason for Link existing is that it emits claims about **pairs**, and *Dana is an IT Leader* is a single-entity claim. The **same sentence** establishes existence and persona, so splitting them means two charters firing on one utterance with nothing to arbitrate, which is the argument already used to keep criteria inside the Insight charter. And it costs nothing, because the pass is already reading about that person for five other dimensions.

**Additive only, and the machine never removes a persona.** `ALTF__Contact__c.ALTF__Altify_Personas__c` is a **multipicklist** carrying the same twelve values as the persona record, and it is **account-durable — one set per person across every opportunity**, which is architecture we inherited rather than chose. Additive semantics dissolve the problem: deal A establishes IT Leader, deal B establishes Sales Leader, and both are true. No overwrite, no cross-deal collision on a field that outlives the deal, no contention on it, and human precedence holds trivially because nothing is ever taken away. **Removal stays a human act forever.**

**The identifiers are simpler than they look.** Contact is the hub — both `ALTF__Contact_Map_Details__c` and `ALTF__Contact__c` carry a required lookup to it. Our Claim already carries the Contact as key three, so the Altify Contact is reachable by traversal and needs no new key. Subject type is `Contact`, which already exists. The only addition is a cited type if the Altify Contact's state is to be frozen at claim time.

**Correction to the persona vocabulary claim.** The glossary calls the value set *almost entirely job titles and being used as one*. Read from production: **CEO, CRO, Executive Sponsor, Sales Leader, RevOps Leader, Enablement Leader, IT Leader, Procurement Lead, Altify Program Owner, Consultant, Legal, Partner.** Exactly **two job titles and ten personifications**. And the glossary's proposed fix — adding Approver and Decision Maker to the persona set — is **rejected**: persona says what kind of person, Buyer Role says their role in this purchase, Support says where they stand. *A supportive IT leader who is also a decision maker* is three existing dimensions composed. Collapsing them into one list destroys the composition the rubric needs.

**Also corrected: Decision Orientation and Adaptability are two different fields, not one field with two labels.** Decision Orientation is on the map row, deal-scoped, Financial / Technical / Relationship / Business, 3% filled. **Adaptability is on the Altify Contact**, person-durable, Innovator / Visionary / Pragmatist / Conservative / Laggard. **Adaptability is out of scope by ruling — it cannot be inferred.** The person-durable tier carries Persona and Adaptability; the deal tier carries Support, Political, Coverage, Buyer Role and Decision Orientation. **Only the deal tier has been designed for.**

**Owed, and the halves must land in order.** Persona *identification* works on any pass once the People charter carries it, including deals in flight. **Ghost *injection* on deals already in flight is undesigned** — the cold-start path fires at opportunity creation only, so a hundred open deals have no ghosts to graduate, and a rubric change that adds a persona requirement reaches nothing already running. **Identification without injection graduates nothing.** Injection first.

**And the Role charter is the persona derivation wearing a name that hides it.** It writes exactly one field, `AAO_Required_Map_Role__c` on the Evidence Contract, whose sole reader is *which person must exist on the map — seeds the ghost*, answering from the persona vocabulary. It is not Buyer Role and not Decision Orientation. **The name collides with Buyer Role and should be retired for persona derivation.** Its classification as a charter stands, on Matthew's ruling that the charter is the unit of per-org configuration and injection, which is a better definition than one based on what a thing reads.

---

## 4c · Scope, licensing and partial ownership · RULED 2 Aug · a build phase of its own

### What may be written where

| Target | Rule |
|---|---|
| **Opportunity, Account** | **Never written. Absolute.** |
| **Contact** | **Toggleable**, and always was — toggle on, we write the Contact and its children; toggle off, a human creates it and shadow persons persist |
| **Any native object** | **No metadata added, no triggers, no logic. Absolute.** |
| **Altify managed objects and fields** | Written, toggleable per target. This is the project |

**The consequence of the Contact toggle, stated because it changes what shadow objects are.** `ALTF__Contact_Map_Details__c.ALTF__Contact__c` is a **required** lookup to the standard Contact, so a map row cannot exist without one. With the toggle off, **a shadow person can never appear on the Altify map** until a human creates the Contact. Shadow objects are transitional for toggle-on customers and **permanent for toggle-off customers**, and they carry a whole class of people for the life of the deal on our surfaces alone. That architecture needs settling before shadow work starts.

### Three scoping filters, all new as global rules

**Licensed sellers only.** Only opportunities owned by a licensed seller enter the pipeline. The filter existed for the note poll and is now global. **Its source of truth is a read, not an assumption** — Altify's `sfLma__License__c` is the ISV's own licence management and is about their customers rather than about who holds a seat in the customer's org.

**Opportunity types out of scope.** Some types are excluded by configuration, the same shape as the applicable-set chain.

**Module ownership, and this one is genuinely new.** Customers hold different combinations: relationship map only, plus insight map, plus assessment, or all four. **This is not graceful absence.** Graceful absence covers an object or rubric record that is not there. Here the objects exist because the package is installed and the customer is not licensed for the module, so **a write fails on permission rather than on absence**, and nothing in the record handles that.

### The shape, and it uses a property already ruled

**Claims land on our objects first; Altify's fields receive a projection.** So a projection that cannot land does not touch the claim. **The capability matrix lives entirely in the projection layer and no charter knows about it.** A customer with relationship map only still gets the whole evidence engine and simply sees less of it in Altify's panels, which is the same property as running in an org that never had Altify, now earning its keep for a case nobody designed it for.

**Projection probes before it writes**, records what it found, and a failure to project never affects the claim, the flag, or the roll-up.

**The admin error log is the first admin-facing surface in the design, and it needs one distinction built in from the start: expected-unavailable is configuration, not an error.** A log filling nightly with *projection failed, module not licensed* trains an admin to ignore it, and then the one real failure arrives in a stream nobody reads. It carries a named contact or set of contacts at the org.

### The testing problem, and it is the standing hazard again

**None of this can be tested in Altify's own org, which is fully licensed with every module.** The harness is therefore **permission sets rather than a differently-licensed org**: strip a test user of access to the insight card object, run the pipeline, and confirm it degrades correctly rather than failing. That is buildable in the sandbox today and it is the only way to see the behaviour at all.

**This is a build phase of its own** — licence detection, type scoping, the capability matrix, projection probing, the error log, the Contact toggle, and a permission-restricted test harness for all of it.

---

## 4d · Politics sequencing · RULED 2 Aug

**Influence and conflict first; person-to-card links second.** Person-to-card links need the insight map, so they only work for customers licensed for it. **Influence and conflict need only the relationship map, which is the smallest footprint any customer has.** So the half that works for everyone is the half with no authored ontology behind it, and it is also the half that makes the map political rather than a list. The person-to-card half is more valuable for call prep, but it already has most of its design from the four-questions-two-values finding and can wait.

**Politics has no authored ontology.** Confirmed by Matthew from the UI: influence and conflict carry no wizard and no help text. So Politics is the charter where **we author the propositions**, the same position Buyer Role is in, with the same consequence — contracts land at `Inferred_Pending` until a human ratifies them.

**And it narrows further. The informer is deterministic from the participant roster**, so who said it is free and never reaches a model. What Politics must establish is who owns or is impacted by a card **where that differs from who said it**, plus influence, plus conflict. Three things, all pairs, all authored by us.

---

## 4 · The charter inventory, reconciled

**Six charters are named. At least eight model roles exist.** Glossary Section E's table plus two roles defined elsewhere in the same document:

| Charter | Loop / trigger | Our name |
|---|---|---|
| **Relationship** | Loop one | **People** |
| **Insight** | Loop one | **Problems** |
| **Link** | Loop one | **Politics** — the only loop-one charter not yet opened |
| **Assessment** | Loop two, after maps commit | **Extraction** (live, 1.1.0) |
| **Role** | Setup time, per sales process | — |
| **Re-adjudication** | Per candidate, blind | **The blind reader** (1.0.0) |
| **Insight Contention** | Scheduled, after the write | **not in the table, and it needs a model** |
| **Rule Discovery** | Weekly, over the decision log | **not in the table, and it needs a model** |

**Matthew's two proposed charters, resolved.**

**The process charter already exists as route C.** Glossary added Resolution Route in v1.8: **P** is deterministic Apex with no model, **E** is evidence only, and **C** is *a charter with state — loop two reading the transcript and our committed rows together, citing rows when it cites state*. That is qualifiers reading the political situation after it has been written, and Proposition Kind backs it: state-established is an Apex predicate **or a model where judgment is required**. **It is the Assessment charter's second job, not a seventh charter**, and the ordering Matthew insisted on is the loop invariant.

**The contention charter is real and unhoused.** Glossary defines **Insight Contention** as contention over unstructured content with no ladder to subtract, *so this requires a model*, running on a schedule. It is one of the four checks. It has no charter. **Matthew is right.**

**And the count is unsettled by the glossary's own admission**, which says of setup-time inference that whether it is one charter with four output schemas or four charters sharing one lifecycle *is an implementation call and is not settled here.* Two of those four instances — qualifier-to-condition and criterion-to-question — are open.

**Naming bridge, for anyone reading both sets.** People = Relationship · Problems = Insight · Politics = Link · Extraction = Assessment · blind reader = Re-adjudication. **One vocabulary should win at the next glossary bump**, and it should be the glossary's, because the glossary is authoritative for vocabulary and the working names were never ruled.

---

## 4a · Flags and contention · RULED 2 Aug

### Flags get no charter, and the nuance lives one layer over

**Flag existence and clearance stay deterministic forever.** A flag has a cause; the cause is a proposition state, a missing relation, a pending candidate or an unanswered identity question. None of that needs judgment, and the architecture's hardest rule forbids putting one there: **nothing gates a flag being raised, and a customer cannot configure the system not to tell them something.** A model deciding whether a flag fires is the machine deciding what is do-or-die, which the criterion ruling already refuses for exactly this reason.

**What has the nuance is what a flag says and which one surfaces first, and that is guidance.** Guidance may infer because guidance establishes nothing, and both halves are already named as owed: **flag content forks on coverage** (a flag over nothing says *not started, here is what to get*; a flag over partial coverage says *here is what stands, with receipts, and here is the missing element*), and **tiered flag surfacing**, added at Matthew's direction and not yet designed, with its tension already recorded — a structurally unresolvable top-tier item holds everything beneath it invisible while their clocks keep running.

**Severity is already algorithmically configurable and needs nothing new.** It is the org's own answer scores, normalised against that org's observed maximum spread rather than an absolute cutoff, with fallback to No Score where Unknown Score is zero or null.

### Contention is three things, not one

| | Establishes by | When | Model? |
|---|---|---|---|
| **Ordinal contention** | Integer subtraction across rungs — current state minus historical aggregate against a threshold | After the write, scheduled | **No.** Free, replayable |
| **Insight contention** | Semantic comparison — a stated purchase driver against an account's historical buying pattern | Scheduled, outside the write path | **Yes, at runtime.** No ladder to subtract |
| **Pattern contention** *(new)* | Authored queries over the memory plane at grains beyond sentiment — per person, per opportunity pattern, per account | **Authored once at setup, frozen, executed by Apex every pass** | **Yes, at setup only** |

**Pattern contention is the configurable charter Matthew asked for, and its shape is the recipe ruling rather than a new mechanism.** A model writes the query once, the query freezes, Apex executes it. Interpretation from the model, completeness from the database because only a query can prove what is not there, determinism from the freeze. The admin surface is sentences and never code, with Approve or Revise, exactly as ruled for state-based questions.

**Why it must be setup-time rather than runtime, stated so nobody reopens it.** Calculated Insights are close to immutable once shipped: dimensions cannot be added later unless they are key qualifier dimensions, measures cannot be removed, and API name, data type and rollup behaviour are fixed at creation. A model inventing aggregates at runtime fights that wall every night. Frozen queries run as static SOQL against data model objects, supported from API 61.0, which is the path that does not require the insight layer to bend. **Insight contention is the exception and stays a runtime model read, because semantic comparison cannot be frozen into a query.**

**Still owed, and it is a one-way door.** The contention aggregate's grain. Aggregating over the rung is what the design assumed and is cheap. Aggregating over the five Support propositions would let contention say *across five deals this person has never once told you they prefer your solution, and they read as a Supporter today* — far more actionable, and impossible to narrow later. **Decide before the insight ships, not after.**

---

## 5 · What is still deliberately not settled

The **Politics / Link charter**, now the only unopened loop-one charter and the one carrying the missing insight-to-insight structure. **Insight Contention's charter.** **Rule Discovery's charter.** The two open setup-time inference instances. Quick-links from insights to qualifiers. Whether the wizard's help text is reachable as custom labels through the Tooling API.

---

*End v2.2. The session's design work stands. What it did not hold was the memory plane, and that is where all four breakages live — cold seeding above all, because the tree ruling is right about the present and silent about the past.*
