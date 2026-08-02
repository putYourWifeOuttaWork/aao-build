# AAO Charters

> **The version lives on the stamp line below and nowhere else.**

**v2.0 · 2 August 2026 · Formed in the consolidation: charter design v1.8, the scope resolver v0.4, the account ontology captures v0.2, and the People harness brief v0.2 merged into one document, plus the Process charter section written at last. Each absorbed part keeps its own stamped headings below; where parts state the same rule, the later stamp wins.**

> **Authoritative for:** the AI — every charter, the shared output envelope, the recovered and authored ontologies, the scope resolver, and the harness briefs. **Defers to:** Glossary for vocabulary, Architecture for placement, Model & Flow for entities and fields.

**Reading order for a single-purpose session:** the Board first, then this document's section for your focus: §P1 People, §P2 Problems, §P3 Politics (open), §P4 Process, §P5 Scope Resolver, §P6 Account-level ontology, §P7 Harness briefs.

---

## §P4 · The Process charter · charters v2.0 · RULED, written here for the first time

**One charter over one merged corpus** of assessment questions and sales-process qualifiers. The charter never sees a module: its handed unit is the Evidence Contract, and extraction 1.1.0 proved the shape by running the mini-rubric with no module identity. Licensing gates discovery (what contracts exist) and projection (what is written), never the charter — the capability matrix stays in the projection layer. **Configuration is segmented by module regardless:** four surfaces, relationship map, insight map, sales process, assessment, each its own custom settings, none an open prompt template; the charter is the unit of injection, the module the unit of configuration, and they meet at the contract. **Graceful refusal:** a read-permission failure on an unlicensed module's tables is absence, a configuration note, never an error.

**The proposition is the pair.** Criterion Text plus Long Question where the latter is populated, Criterion Text alone where not — it is the required half. Both byte-exact, neither paraphrased into the other; the content hash covers both. Help, Tip, and the per-question Yes and No labels (assessment side only, forty characters, no Unknown label) are authored rubric text read into the contract as qualifying-evidence guidance.

**Stage scoping.** Reading is never stage-gated: every pass listens against the deal's whole rubric, including standing Yes answers, because a Yes can be undone and no model ever selects attention. Writing is gated at or behind the open stage; ordinary writes only where the answer is not Yes; a standing Yes moves only by demotion (machine) or contention (human). Evidence for a future-stage qualifier is claimed the day it is heard; stage advance triggers a deterministic projection sweep from our own answers, never a re-read. The open stage is a field read on the Altify Opportunity.

**The qualifier surface.** Projection targets `ALTF__Qualifier_Answer__c`: composite-key upsert, Comment 32,768 for citations, status No / In progress / Yes with no Unknown slot — **In progress carries UNVERIFIED**, null stays never-asked, and a seller's In progress is human-authored forever. The assessment surface targets `ALTF__Assessment_Answer__c`: Unknown default, Note 2,048. Quantifier, compound and readability rulings for the corpus live in Architecture's Computable Share section.

**Owed:** the five-part projection test recorded in the Board's sequence, after the People harness chain.

---

*The absorbed documents follow, stamps intact.*



---

# PART I · Charter Design (absorbed; stamps intact)

# AAO Charter Design

> **The version lives on the stamp line below and nowhere else.**

**v1.8 · 2 August 2026 · The real ontology, enumerated from labels. v1.7's Support and Political sets are SUPERSEDED — they were a walk presented as the ontology.**

**Changed in v1.8.** The wizard questions are **custom labels in `ExternalString`**, not UI-only text, so the ontology is a query rather than a manual walk — which is what makes *discovered rather than paraphrased* true in a customer org rather than only in this file. 35 labels read by exact name, none missing, localization overlay queried and **empty in this org** (all 56 overrides are account-manager UI rebranding), and **the overlay must still be applied in code, because empty here proves nothing about a customer**.

**Support is nine, not five, and its structure is symmetric rather than a tree** — matched pairs pointing opposite ways, with the negative half authored explicitly. **Political is seven, not three**, and two of the seven are not about authority at all, so the walked version collapsed political standing into hierarchy. **Coverage is three and was complete**, because it is the only dense family, which is exactly why a partial read felt like a whole one.

**Also from the enumeration:** the insight admission tests split by map unevenly, with Goal, Pressure and Initiative carrying six each and Obstacle three; `PRESSURE_HELP_TEXT_3` requires knowing which Goal a pressure blocks, **an edge the schema cannot hold**; and **proposition text is stored byte-exact**, because a normalised quote is a paraphrase.

**v1.7 · 2 August 2026 · The Problems charter CLOSED. Solution's admission test recovered. Machine confirmation ruled an autonomy level. Flags age from when the question became askable. The cited-type enum ruled**

**Changed in v1.7 — three laws, two of them found by the build refusing a design.**

**Flags age from when the question became askable, not from when the answer last turned bad · LAW.** CODE wrote a reopen path that restarted a flag's clock and **the deploy refused it**, because `AAO_Raised_At__c` is immutable and is what age is measured from. The refusal is right and it generalises past this flag. A missing-relation flag is one standing question about a deal — *does this deal have solutions with no stated problem* — and that question has been askable since the deal existed. **A gap reappearing is the same question answering yes again, not a new question.** Restarting the clock would let a deal launder itself by closing and reopening and come back looking freshly imperfect, which is exactly the optimistic drift this build exists to refuse. **The field enforced this before either party reasoned to it**, which is the argument for putting laws in the schema rather than in the code that uses it.

**The after-insert exposure · LAW, stated generally.** Anything hung off an after-insert trigger can turn our defect into the customer's lost evidence, because a throw there rolls back the row that caused it — **so a failure in derived, secondary work destroys the primary fact we were given.** `AAO_Ingest` already ruled it for the enqueue path; the participant writer was the second instance rather than a special case, and every future after-insert consumer inherits it. **The safe direction is always to lose the derived thing rather than the evidence.**

**One flag per deal per relation kind is held by the database, not by convention.** `AAO_Relation_Key__c` is unique, so two passes cannot raise two flags and make the count a lie — the same discipline as the scope key. **`AAO_MissingRelation` is built general and does not know what a Solution or a Pressure is**; it takes a kind and a list of members, and whoever knows the relation computes them. All three kinds are in the enum. **The count is the headline and the members are the work**, because a rolled-up flag carrying only a number tells a seller there is a problem without telling them where.

**The cited-type enum · RULED.** It grows typed rather than generic, with a test: a type earns a lookup when we will compare its live state against the frozen snapshot, which is the whole reason the object is half frozen and half live. **Only `OpportunityLineItem` is added, not `Product2`** — the product is reachable by traversal from the line item, so citing it separately would cite a classification rather than a fact about this deal.

**Reserved-word collisions now six:** `commit`, `json`, `system`, `merge`, `any`, `when` (from `switch`). Four refuse loudly, two resolve silently (`json`, `system`), and the silent two are the dangerous ones.

**Build state: 153 tests green (was 146).**

**Changed in v1.6.**

**The Solution admission test is recovered and it has four questions, not three.** Three of them ask about links to Obstacles, Pressures and Goals. **Altify's own definition of a Solution is what it connects to**, which means the unlinked-Solution flag ruled in v1.4 is not our invention — a Solution card with no edges fails the vendor's published test. That is the sentence to use when explaining the flag to anyone at Altify. The fourth question, *would a key player be able to articulate your unique business value from this Solution*, is **the strongest evidence proposition on the map**: everything else records what the seller believes or was told, and this one is checkable from a transcript because it asks whether the buyer said the value back in their own words, from a subject set that is already closed and queryable. Solution's terminal state is **Implemented**, the fifth distinct one; no two card types share a lifecycle.

**Machine confirmation · RULED as an autonomy level**, resolving the v0.5 tension by making it configurable rather than choosing among its three options. Whether a card moving to Confirmed raises a yellow flag first or is written directly is a per-customer setting, the same shape autonomy has everywhere: it governs who approves, never what is checked. The evidence rules are unchanged, with **a decision maker's statement confirming on its own**, which is the speaker-rank law applied rather than a new principle. **The tension lost most of its force to evidence:** Confirmed already does not mean a named human vouched, since five cards written inside twenty seconds all carry it true with a named confirmer who could not have read them.

**Recorded, not ruled: the enablement sections.** An `ALTF__Solution__c` carries `ALTF__Solution_Section__c` children — Key Messages, Sales Tools, Case Studies, Competitive Positioning — so where a Solution card points at a real solution record, **authored enablement content is one join from the flag that needs it.** That is what a separate enablement tool delivers, arriving inside the same application and driven by evidence rather than by a content recommender. Not this wave; recorded because guidance should be designed for it rather than discover it later.

**The Problems charter is CLOSED.** Parked and not blocking: quick-links from insights to qualifiers.

**Changed in v1.5.**

**The missing-relation flag is keyed on deal plus relation kind**, rolling up the specific cards inside it and naming them rather than only counting. Neither per-card (eight flags on an eight-line-item deal) nor per-deal (a blended count nobody can act on). **The deciding reason is that the action differs per relation kind** — solutions with no stated problem, pressures with no linked goal, and people with no influence edges are three different conversations. Clears when the count reaches zero; the count is the progress indicator.

**Built and deployed since v1.1, from CODE, 146 tests green (was 139).** The **participant junction** `AAO_Participant__c` writes in the Source's after-insert, synchronously and outside the adjudication path, because participation is a fact about evidence arriving rather than a product of judging it — a deal that never runs a pass still knows who was on its calls. **It counts distinct artifact hashes rather than Source rows**, reusing the same source-event definition the sentiment counter uses, so a ninety-minute call arriving as three rows reads as one occasion. `AAO_Substantive__c` is deliberately **the weakest possible test** — any content past the small-talk boundary, with missing boundary data counting as substantive — so coverage **understates rather than overstates**, and no threshold is asserted because none is measured. **`Source` is a cited type** with its lookup, and a Coverage claim cites the Sources it counted rather than carrying a Source lookup, since the latter would make a state claim look like a transcript claim to the family check. **`Subject_Person`** is in the speaker-requirement enum and **refuses when no subject is supplied**, on the principle that a check which cannot run has not been met.

**A near-miss worth generalising, found and fixed by CODE.** Because the junction writes in after-insert, a roster it could not parse would have failed the **Source insert itself** — a defect of ours becoming lost evidence. Fixed so a parse failure records no participants and the artifact still lands, matching the ruling `AAO_Ingest` already makes about a failed enqueue. **This should be stated generally in the field tables rather than as one fix:** anything hung off after-insert carries the same exposure, and it is the no-triggers-on-objects-we-do-not-own law reproduced one layer in, on our own object.

**`when` is a sixth Apex reserved-word collision** (from `switch`), after `commit`, `json`, `system`, `merge`, `any`. Owed to the field tables at the next bump.

**Changed in v1.4.** **Solutions are derivable from line items and their edges are not.** The join exists end to end — the Altify package puts a Solution lookup on standard `Product2`, and Solution insight cards point at the same records — so a Solution card asserting *this product is on this deal* is route P, basis `State`, citing the line item, with **no ratification needed because there is no judgment in it.** The projection toggle still applies. **The edge is the opposite:** asserting that a product addresses a given Obstacle cannot come from a line item, which records what is sold and never which problem it solves, so the edge requires spans or a human. Line items give the card; calls give the edge.

**The first missing-relation flag · required, yellow.** A Solution card with no edge to any Pressure or Obstacle raises it. The value is the absence, not the card: *you are selling this and nobody has told you what problem it solves.* Fires from the start, cleared only by the edge existing, no dismissal. **Every existing flag fires on an unmet proposition; this one fires on a missing relation**, and the Politics charter and the Pressure-to-Goal hole need the same shape, so it is built as a kind rather than a one-off. **Volume shape is open and recommended as one flag per deal rather than one per card.**

**Changed in v1.3 — Matthew's finding, confirmed against the schema.** The insight methodology distinguishes **four** relations between a person and a card and the object stores **two**. Goal asks who is *responsible for* it, Initiative asks who is *responsible for its success or failure*, Pressure and Obstacle ask who is *impacted by* it, and every type separately asks who *told you*. `ALTF__Insight_Card_Contact__c.ALTF__Type__c` offers only `Informer` and `Owner`, so **impacted-by and responsible-for are the same row.** That distinction is what makes guidance addressable: *this takes that pressure off your shoulders* versus *you own this obstacle*, which means nothing to the person hearing it. **Ruled: derive on read for existing human cards, record explicitly on our own claims**, because the buckets are noisy and a mistyped card would derive the wrong relation.

**Also found: the causal chain is taught but not stored.** Pressure-to-Goal linkage is free text on a field that doubles as desired-outcome for Initiatives. The only structural card-to-card edge points at Solutions. **Altify's own guidance calls Pressures → Goals → Initiatives → Solutions the healthy pattern while the schema cannot answer whether it holds.** Recorded as Politics charter territory and a larger opening than the person mapping.

**Changed in v1.2.** Matthew's governing principle, and it decides the last open question in this charter: **the ability to infer binary is superior to feeling out scores — ontology where ontology is feasible, inference wherever it is not.**

All four map dimensions are ontology-backed, three from Altify's own recovered question sets and one authored by us. So **the tree owns the rung on every one of them and no dimension uses a score.**

**Withdrawn for ontology-backed dimensions: the one-per-source law and the minus-three-to-plus-three clamp, both ruled in v0.8.** Marked withdrawn rather than deleted, because they were ruled and built against. The reason they go is that they guarded against a single call's *feel* teleporting someone, and movement is no longer a feel — it is five propositions with byte-verified spans. **CODE's teleport objection is answered by dissolving its premise.** The counter itself survives as the **inference fallback** for any dimension with no ontology; that is none of the four today, and it should not be thrown away.

**What survives intact:** one FALSE on the mentoring question still drops a Mentor to Supporter immediately, and Mentor still costs two establishments to enter and one to lose, because it sits two conditions above Supporter in the tree. **The v0.8 asymmetry is structural now rather than arithmetic.** The trend line is the count of conditions met, zero through five, every step naming its condition and quoting its words.

**The People charter is CLOSED.**

**Changed in v1.1.**

**Marked wrong, from v1.0:** *Coverage is a frozen query on the P route.* **Withdrawn.** Participation is not queryable — there is no Source-to-Contact relation, and the roster lives in a JSON text blob SOQL cannot filter into. This was a claim made by reasoning about our own schema instead of reading it, which the standing rule forbids, and it is recorded as wrong rather than quietly replaced. Coverage stays deterministic and model-free; it is not a query until a **participant junction** exists, which is now ruled. Two further gaps ruled with it: **`Source` must become a cited type on Claim Basis**, or a Coverage claim is refused by our own evidence-family law, and **`Subject_Person` must become a speaker requirement**, or Support Q2 and Q4 would pass on a colleague vouching for someone else.

**The insight admission tests are guidance, not rules · RULED.** Insight cards in production are in practice notes loosely fitted into buckets, and the authored questions are discovery-completeness prompts wearing the clothes of definitions — *do you know how the decision maker is measured* tests the seller, not the card. So **admission stays exactly as v0.5 ruled it, on genuineness**, and the questions move to the guidance layer as what-to-ask-next. The v1.0 proposal to carry them as contract elements is **withdrawn**: elements drive coverage adjudication and coverage drives the verdict, so a card meeting one of three would land UNVERIFIED, which is a gate wearing a different hat. **The authored text must stay out of the reader's input entirely**, or the model will treat it as criteria whatever the charter says.

**Guidance eligibility · RULED: guide where we hold evidence.** Our own cards always qualify, since every one carries spans. A human-authored card qualifies only once one of our Claims attaches to it, because then the prompt is grounded in words we can quote. Everything else stays silent. **Origin-based eligibility was rejected on evidence:** `ALTF__Generated_By_Max__c` exists and marks cards from Altify's own AI, but a card written through MCP by an outside assistant has it false and reads as human, and `ALTF__Confirmed__c` is set by exactly those writes. Altify's own attempt at origin marking is the proof that origin marking does not hold. **Dedup goes type-blind** for the same reason the buckets are noisy: a card saying the same thing under a different type is the same insight, and a proposed type is a suggestion beside a human's card, never a correction to it.

**The ontology injection point · RULED, and it is smaller than it looked.** `ALTF__Type__c` is a restricted picklist whose API values are hardcoded, so a customer renaming Goals to KPIs changes only the **label** and our contracts key on the value. **Divergence is always detectable**, because a relabelled picklist shows label differing from value in the ordinary describe. What does not follow a rename is the meaning, which lives in package help text. So the injection point is per-org, per-type authored description, defaulting to what was recovered from the package, confirmed by the admin through the recipe pattern's sentences-not-code surface. **Detecting that we do not know is the load-bearing half**, the same shape as the discovery filter fault: when an org has diverged, hold and say so rather than read KPI cards through a Goal ontology.

**Changed in v1.0.** The insight side of the same discovery. **Each insight type carries an authored three-question admission test**, shipped behind the *What is a…* link, with an examples list beside it. Goal, Pressure, Initiative and Obstacle recovered verbatim; Solution owed. Two consequences. **Altify already has the provenance field** — every card panel carries *Who told you about this?* and it is empty on every card inspected, so our citation goes there rather than into a field we add. And **the authored tests contradict the v0.5 admission ruling**, because Altify's bar is explicitly material (an Obstacle must be *significant enough to establish substantial value*) while v0.5 ruled genuineness and never importance. Three options, one recommended, recorded in the Problems charter. Matthew's.

**Changed in v0.9.** The premise that the relationship map carries no ontological description is **wrong, and the org says so.** Altify decomposed three of its four map dimensions into authored question sets years ago and ships them in the Help me select wizard. Recovered this session by reading the org and walking the wizard in production (read-only, nothing saved): the Support tree from Matthew's click-through, the Political and Coverage trees driven directly. **The verbatim question sets are recorded below and are the People charter's ontology.** We do not paraphrase a picklist label into a proposition, for the same reason assessment propositions come from the rubric table verbatim.

**The structural finding: the four dimensions are four different kinds of thing and route four different ways.** Coverage is a count of our own activity and is a query, not a judgment. Support is five propositions about what the buyer said and did, and is transcript evidence. Political is three questions about organisational dynamics, none of them binary. Buyer Role has **no wizard at all** and is the only dimension where we author the questions ourselves, from the definition text, which is all that exists.

**Recorded as a hazard: never derive from the stored answer strings.** `ALTF__Status_Answer__c` holds the wizard path as `Yes;Yes;Yes;Yes;No` and similar. Live production rows show it disagreeing with the stored value: one contact's answer string resolves to Supporter under the tree recovered this session while her Support field reads Mentor, because the wizard has a **Select manually** toggle and a later manual pick leaves the old answer string behind. **The questions are the asset. The answers are exhaust.**

**Changed in v0.8.** The movement arithmetic is settled and it is smaller than the two versions that preceded it. **A single integer from minus three to plus three, clamped at both ends, moved by at most one per source-event, with the named rungs at fixed positions on it.** Matthew's model, and it dissolves the machinery v0.7 was reaching for.

**Marked wrong, from v0.7:** the sentence *"One rung per source governs both directions"* was imprecise and is withdrawn. It reads as uniform one-everywhere, which would have removed the two-increment cost of reaching a terminal rung. The correct statement is that a source-event moves the counter by one, and the *rungs* sit at uneven distances on that counter, which is what makes reaching mentor cost two and losing it cost one.

**Also withdrawn from v0.7:** the argument that an absolute score must not determine the rung, on the grounds that a person could bank years of positive history and never fall. That objection was against an *unbounded* accumulator. The counter is clamped at three, so one negative event always moves a mentor off the top, and the objection does not apply.

Further rulings this version: **human override is absolute** on every map dimension including coverage, with contradicting evidence still writing its claim and raising a flag; **backdated evidence re-derives** in evidence-occurred order with no age cap; **no decay mechanism is built** and staleness surfaces as a derived date; and the People charter now carries the **neutral disposition** in its text, expressed as a disposition and never as a rate.

**Changed in v0.7.** CODE's parser audit against the deployed `AAO_ExtractCharter.parse` found five things in v0.6 that would not build. All five are ruled here. The largest correction is mine: v0.6 let a People finding carry several emissions, which forced a local emission id into the span's `element` field, which broke a closed enum and would have broken coverage arithmetic. **One finding now carries exactly one proposal**, which dissolves both. Matthew's framing is the reason and it is not a new law: every claim from a piece of evidence is broken down to its most basic binary unit, because four changes to one person need four separate sets of reasoning and their evidence is spread across different calls. The claim layer was already at that grain; v0.6 let the emission layer bundle above it. Also ruled: **the source-event counting unit is the artifact, not the Source row** (parts of one long call must not increment three times); **terminal-rung exit stickiness is dropped** (people are fickle, and a map that resists moving down lies in the optimistic direction); and **current standing and relationship depth are separated** — one rung, one count, no single score carrying both.

**Changed in v0.6.** The shared output envelope ratified; both as-deployed schemas recorded verbatim from the org; the status-mapping law (`not_returned` derived by the comparator, never emitted); the no-channel-recognition ruling; People and Problems finding bodies drafted.

**Changed in v0.5.** Problems charter opened on production evidence (the Tungsten insight-card read: 349 cards across 5 deals, human cards with real fingerprints and zero provenance, Max-generated boilerplate with three contradictory NRR targets coexisting, ~20% confirmed; the won-deal outlier at 44/66 confirmed with zero generated cards). Matthew's rulings recorded: admission for every genuine insight, keep-parent dedup, plain-text citations, evidence-driven confirmation, gestures never load-bearing.

**Changed in v0.2.** Self-report ruled: sentiment moves one rung conservatively; no behavioral-pattern inference; a human write watermarks the dimension forever. The Identification flag ratified as the fifth type.

**Changed in v0.1.** People charter opened. Person-row boundary, identity-resolution ladder, shadow scope, promotion path, CRM-write toggle.

Companion to the AAO Field Tables (objects) and the four project documents. One section per charter, every emission naming what may produce it and what checks it, rulings marked as rulings.

---

## 0 · Ruled cross-charter

**The recipe ruling (state-based questions).** A model may write the query, once, at setup; the query is frozen on the contract and executed by Apex every pass. Interpretation by the model, completeness by the database, determinism by freezing. The question-changed hash sends the model back to re-derive. Guardrails in Apex regardless of what the model wrote: deal-scoped, read-only. **The human surface is sentences, never code.** Default path requires zero customer-admin action. Runtime model-reading-of-state (the C route) is the universal floor; frozen queries are the earned upgrade for pure counts.

**No rubric binding on deals:** a deal always answers the org's current active questions; version is attribution on receipts, never routing.

**No channel recognition · RULED 2 Aug.** Two authorship classes only: MACHINE with a charter stamp, HUMAN otherwise. **No mechanism anywhere attempts to recognize whether an unstamped write came from a person's judgment or from an agent a person rubber-stamped.** The risk that agent-written content wears a human mark is accepted and named: once the product is in an org, the incentive to paste transcripts into a headless assistant collapses, because the fields are already full and outside agents become retrievers of our receipts rather than writers of their own inferences. Our writes are distinguishable **by citation, not by classification**. The existing laws already cover the edge: an agent-written card reads as human, so the machine never edits it; matching evidence lands as a Claim with outcome Reinforced beside it, receipts intact, card untouched. No third authorship class exists and none is planned. Over-strictness here would make the product abstain itself into infeasibility; the abstention budget is spent on evidence quality, never channel forensics.

**The binary-unit law · RESTATED 2 Aug, not new.** Every establishment from a piece of evidence resolves to one basic yes-or-no unit with its own citation and its own reasoning. Four changes about one person are four claims, because the evidence for each is spread across different calls and each needs its own proof. This has always governed the claim layer. **As of v0.7 it governs the emission layer too:** a charter may not bundle several proposals into one finding and leave the writer to split them, because that puts the split after the model's reasoning instead of inside it.

---

## 0.5 · The shared output envelope · RATIFIED 2 Aug · the cross-charter emission law

**The law.** Every charter emits one envelope: a `findings` array with **exactly one entry per unit of work handed to it, in the order handed, never omitting one**, each entry carrying `ref`, three-way `status`, `interpretation`, `spans`, and a charter-specific `body` holding **exactly one proposal**. The model proposes and cites; every rule lives in the gates.

### The reference instance — `AAO_Extract_Evidence` 1.1.0 as deployed

Dumped from `aossb2` by anonymous Apex against the six live mini-rubric contracts, not transcribed from source: the enums are closed at runtime from org data, so source would have shown the shape and none of the values.

```json
{
  "type": "object",
  "additionalProperties": false,
  "required": ["findings"],
  "properties": {
    "findings": {
      "type": "array",
      "description": "Exactly one entry per proposition given, in the order given. Never omit one: a proposition nobody spoke to is a finding with status not_addressed, and the complete ledger is the point.",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["proposition_code", "status", "proposed_verdict", "interpretation", "spans"],
        "properties": {
          "proposition_code": { "type": "string", "enum": ["AAO_T1", "AAO_T2", "AAO_T3", "AAO_T4", "AAO_T5", "AAO_T6"] },
          "status": {
            "type": "string",
            "enum": ["addressed", "not_addressed", "abstained"],
            "description": "addressed: the transcript speaks to this proposition and you are proposing a verdict. not_addressed: nobody said anything bearing on it. abstained: it was discussed and you cannot reach a verdict. These are three different facts and collapsing the last two makes the abstention rate measure nothing."
          },
          "proposed_verdict": {
            "type": "string",
            "enum": ["TRUE", "FALSE", "UNVERIFIED", "NONE"],
            "description": "NONE unless status is addressed. Judge only whether the words establish the proposition. Do NOT lower a verdict because of who spoke; that is adjudicated after you. FALSE requires a positive assertion that the proposition does not hold. A missing confirmation, a deferral, or \"I do not know\" is UNVERIFIED, never FALSE."
          },
          "interpretation": {
            "type": "string",
            "description": "Empty string is the good case. Fill this only where you had to read the proposition beyond its own text to apply it, and say what you took it to mean. Populated rows are the under-specified-question list."
          },
          "spans": {
            "type": "array",
            "description": "Empty unless status is addressed. At most 5 are kept and the rest are dropped by the writer.",
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": ["quote", "speaker", "element"],
              "properties": {
                "quote":   { "type": "string", "description": "Verbatim, character for character, from the transcript. It is checked byte for byte against the stored artifact and a span that does not match exactly is discarded." },
                "speaker": { "type": "string", "enum": ["dana", "sam"], "description": "The roster key of the person whose turn this quote lies in." },
                "element": { "type": "string", "enum": ["e1", "e2", "e3"], "description": "Which element of this proposition the quote is offered for." }
              }
            }
          }
        }
      }
    }
  }
}
```

`MAX_SPANS = 5`, enforced by the writer. **Runtime-closed enums are law:** `proposition_code` from the contracts in the pass, `element` from each contract's element list, `speaker` from the artifact's roster keys. No identity is ever free text.

**This schema does not move in v0.7.** Extraction stays at 1.1.0 and Gate 1 does not re-run. Every v0.7 correction is contained in the parser, in the People body, and in one new nullable field.

### The second reader — `AAO_Blind_Reader` 1.0.0 as deployed

```json
{
  "type": "object",
  "additionalProperties": false,
  "required": ["reviews"],
  "properties": {
    "reviews": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["proposition_code", "elements"],
        "properties": {
          "proposition_code": { "type": "string", "enum": ["AAO_T1", "AAO_T2", "AAO_T3", "AAO_T4", "AAO_T5", "AAO_T6"] },
          "elements": {
            "type": "array",
            "description": "One entry for every element of this proposition, including the ones no quote was offered for.",
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": ["element", "established", "reason"],
              "properties": {
                "element":     { "type": "string", "enum": ["e1", "e2", "e3"] },
                "established": { "type": "boolean", "description": "true only if the quotes given assert this element. false if they merely mention it, discuss it, decline to confirm it, or deny it." },
                "reason":      { "type": "string", "description": "One sentence. On a false, name what is missing or what the quote actually says instead." }
              }
            }
          }
        }
      }
    }
  }
}
```

**Blindness is structural, visible in the schema's absences:** no verdict field, no span field, no transcript reference. `Review(contract, interpretation, spans)` is the entire input signature. Available to any charter that needs a second reader.

### The status mapping · LAW

| Model emits `status` | Stored `AAO_Abstention_Reason__c` | Stored `AAO_Outcome__c` |
|---|---|---|
| `addressed` | — | as adjudicated |
| `not_addressed` | `nobody_said` | `Abstained` |
| `abstained` | `model_declined` | `Abstained` |
| *(nothing emitted for that ref)* | `not_returned` | `Not_Returned` |

**The model cannot emit `not_returned` by construction.** It is the record of a unit the reader never reported, so only the comparator can observe it. Every charter keeps this shape: the charter declares three, the fourth is derived.

### The parse law · RULED 2 Aug · from CODE's finding 1

**A derived fact may never be derivable from a parse failure.** `not_returned` is derived from absence, and absence has two causes: the reader did not answer, or we did not understand the answer. If those are indistinguishable, the metric reports charter quality when the fault is ours, which is worse than having no metric. The instrument would poison itself, since an unrecognised key today gives `code = null`, fails `knownCodes.contains(null)`, `continue`s silently, and writes `not_returned` for every handed unit.

Three requirements follow. **The parser throws when a non-empty `findings` array yields zero recognised refs** — that condition is always a bug and never a model behaviour. **The run records how many findings parsed and how many refs were recognised**, so any `not_returned` rate is readable against the parse that produced it. And **the dual read of `proposition_code` and `ref` is versioned, not permanent** — it exists to cross one charter bump and retires at a named version, because a permanent dual read is a permanent ambiguity about which key means what.

### The parser return shape · RULED 2 Aug · from CODE's finding 2

**The return becomes a handed-map plus a discovered-list, mirroring the envelope's own cut.** A map keyed on `ref` cannot hold discovery findings: every one carries `ref: "NEW"`, so N discovered people collapse onto one key, last write wins, silently. Both callers (`AAO_Extract`, `AAO_Pipeline.fromModel`) change with it. The rule generalizes: **the parser's return type has the same shape as the envelope's law.** Handed and discovered are different kinds of fact and get different containers.

### Handed units and discovery findings

- **Handed units:** exactly one finding each, in order, never omitted. The comparator derives `not_returned` over these and only these.
- **Discovery findings:** appended after the handed set, `ref: "NEW"`, one per proposal, marked by the body they carry. A discovery finding structurally cannot be `not_returned` — there is no ground truth of what should have been found.

**The riskiest unvalidated assumption in this design, named:** ledger completeness has no comparator on the discovery half. What to measure first: Gate-1-style staged-truth runs per charter, transcripts with known planted people and insights, recall measured against the plant. Until those runs exist, discovery recall is stated only as by-construction, never as a number.

### Envelope constants across charters

`interpretation` is **required with empty string as the good case** everywhere; optional would lose the under-specified-question signal. `spans` is **required-and-empty rather than absent** when a status is not `addressed`, which is what makes "exactly one entry per handed unit, never omit one" checkable. `MAX_SPANS = 5`. **A span's `element` field carries only what the quote establishes against the contract, and never a local identifier of any kind** — this is the v0.6 error and the reason coverage arithmetic in `AAO_Accumulate.verdictFor` stays untouched. Since one finding carries one proposal, spans back their own finding and have nothing to disambiguate.

**`NONE` is retired from the design.** It was a symptom rather than a value: one restricted picklist was being asked to carry every charter's proposal shape. Verdict-shaped proposals go in `AAO_Proposed_Verdict__c`, which is nullable and stays restricted to TRUE / FALSE / UNVERIFIED. Movement-shaped proposals go in **`AAO_Proposed_Movement__c`**, new, nullable, restricted to `UP_ONE` / `DOWN_ONE` / `NO_CHANGE`, written by the writer and read by the movement gate. A movement finding leaves verdict null rather than carrying a fake value.

---

## 1 · The People charter

Reads evidence; may speak only about human beings on this deal.

### The handed unit · RULED 2 Aug

**The handed unit is a person crossed with a dimension**, not a person. One finding carries one proposal. The closed set is assembled by Apex before the call: known people (roster keys of the artifact, current map members, existing shadows) crossed with the ordinal dimensions and assertion codes in the pass. The comparator derives `not_returned` per pair, so a skipped dimension is visible rather than hidden inside a person who was reported.

This mirrors extraction exactly, where a proposition is already a contract against a subject. **Cost, stated and to be measured rather than guessed:** nine people against six dimensions is fifty four findings in a pass, most of them `not_addressed` with empty spans. The field tables already chose the heavier shape deliberately on per-person questions, so the precedent points this way, but it presses on the sixteen-thousand-token output ceiling in Model Config. Rough arithmetic puts a `not_addressed` finding near seventy tokens; the real variable is how many carry spans. **Measure on the first live pass; no threshold enters any document until it does.**

### The three emission kinds

**Existence** belongs only to discovery findings, since a known person's existence is already established. **Movement** is a cited nudge of one rung on an ordinal dimension from current state, never a teleport. **Assertion** is this person IS something, TRUE / FALSE / UNVERIFIED with a span, like any claim. **The kind is determined by the handed dimension, not chosen by the model** — an ordinal dimension yields a movement, an assertion code yields a verdict.

### The People output schema · v0.7

Body on a handed finding, exactly one proposal:

```json
"body": {
  "type": "object",
  "additionalProperties": false,
  "required": ["proposal"],
  "properties": {
    "proposal": {
      "type": "string",
      "description": "Closed at runtime by the handed dimension's type. Ordinal dimension: UP_ONE / DOWN_ONE / NO_CHANGE. Assertion code: TRUE / FALSE / UNVERIFIED. A teleport is unexpressible, which is the point."
    }
  }
}
```

**`NO_CHANGE` earns its place.** Evidence that speaks to Sarah's support without warranting a move must not become an abstention, or the abstention rate stops measuring what it measures. `addressed` with `NO_CHANGE` is the analogue of extraction's `addressed` with `UNVERIFIED`: the reader called it, and the call was no move. **A `NO_CHANGE` that survives the gates writes a Reinforced claim**, which makes how often a person's standing has been re-confirmed countable, the same counting ruled for insight cards.

Body on a discovery finding:

```json
"body": {
  "type": "object",
  "additionalProperties": false,
  "required": ["person_handle", "mentioned_as", "match", "dimension", "proposal"],
  "properties": {
    "person_handle": { "type": "string", "description": "Local handle (p1, p2…) so several findings may speak to the same proposed person before that person has an identity. Body data only; never load-bearing in a closed enum." },
    "mentioned_as":  { "type": "string", "description": "The name as spoken." },
    "match":         { "type": "string", "description": "Runtime-closed: a candidate ref from the closed set, or NONE, or AMBIGUOUS." },
    "dimension":     { "type": "string", "description": "Runtime-closed, or EXISTENCE for the finding that proposes the person at all." },
    "proposal":      { "type": "string", "description": "As above; TRUE for an EXISTENCE finding." }
  }
}
```

The model matches against the closed candidate set it was handed and may say `NONE` or `AMBIGUOUS`. **Linking, shadow creation, and the Identification flag are the gates' work, never the model's.** The ladder resolves each handle once and applies every finding carrying it; an `AMBIGUOUS` handle holds its dimension findings behind the Identification flag.

### The identity-resolution ladder · RULED

For any person the charter wants to speak about, in order: **Roster** (were they on the call, deterministic, from the Source), **CRM** (a Contact at this account matching the name, one query), **Memory** (the account's history, one keyed lookup). Outcomes: exactly one match links, machine-attributed and contestable; zero matches creates a Shadow Contact; multiple matches creates a Shadow Contact plus an Identification flag. Disambiguation may use stated context but a link under ambiguity is never guessed.

### The person-row boundary · RULED

**A person earns a row when a claim needs them.** Speakers earn rows because their words create claims. A referenced-but-absent person earns a row only when the mention is load-bearing: a stated holder, a stated gate, a stated role. A name dropped in chatter creates no claim and therefore no row. A twenty-name war story creates nothing.

### Shadow Contact, widened · RULED

Two origins: a call participant who is not a Contact, and a person referenced as mattering who was never present. **A Contact without a last name cannot exist**, since Salesforce enforces LastName, so partial identities structurally cannot leak into the CRM. Inference may enrich a shadow as clearly-marked machine enrichment, never as establishment.

### The promotion path · RULED

Shadow → real Contact → map row, when identity completes. Contact creation into the customer's CRM is governed by the projection-pattern law: **any write to a native object we do not own ships only toggleable per customer.**

### The Identification flag · RATIFIED

Fifth flag type. Not Ratification, which asks permission for a known write; this is missing knowledge. Carries the citation, the candidates found, what is needed, and where to answer. **Clearance needs no new rule: the answer re-enters as evidence.** Never dismissible. Where its answer would clear a red, the two are linked and **the red is surfaced proactively regardless of tier or value.** Autonomy levels govern permission; this flag fires identically at level 3.

### The movement laws · RULED, with two corrections in v0.7

**One rung per source-event, from current state, with a span.** Clear sustained sentiment moves a person one rung, conservatively, never more than one per source-event. No behavioral-pattern inference. A human setting a dimension **watermarks it forever** and the machine stops writing that field.

**Correction 1 — the source-event is the artifact, not the Source row.** A single call can be several Source rows: there is a ninety-minute ceiling at the gate, and part index and part count exist for exactly that reason, so a two-hour conversation arrives as two or three rows of one artifact. Counting rows would let one conversation increment a person three times. **The scope key is already scope plus artifact hash plus part index, so the occasion is scope plus artifact hash**, and parts of one call collapse to one increment by construction. Two genuinely separate calls have different artifact hashes and count as two, whether or not they fall on the same day. **Days never enter the arithmetic.** Two separate calls in one afternoon are two increments, so a supporter can reach a terminal rung that same day if the evidence carries it.

**Correction 2 — exit stickiness is dropped.** People are fickle, and a map that resists moving down lies in the optimistic direction, which is the exact failure this product exists to defeat. The protection is that evidence must still clear every gate to move anyone at all. *(The v0.7 sentence "one rung per source governs both directions" was imprecise and is withdrawn; see the counter below.)*

### The sentiment counter · RULED 2 Aug · the whole arithmetic

**One integer per person per ordinal dimension, running from minus three to plus three, clamped at both ends.** A source-event moves it by at most one. The named rungs sit at fixed positions on it, and the rung is the highest named position at or below the number:

| Counter | Rung |
|---|---|
| +3 | Mentor |
| +2 | Supporter |
| +1 | Supporter |
| 0 | Neutral |
| −1 | Non-supporter |
| −2 | Non-supporter |
| −3 | Enemy |

Everything the earlier versions were building falls out of this and needs no separate law. **Reaching mentor from supporter costs two** (one to three) and reaching enemy from non-supporter costs two the same way. **Losing mentor costs one**, because three minus one is two and two reads as supporter. **The clamp is what prevents banking:** fifty positive calls put a person at plus three and stop, so a single negative event still moves them off the top, and no accumulator can run away. From plus two, one positive event returns them to mentor while one negative event leaves them at supporter, which is the asymmetry a seller can actually see.

**The counter is standing and never depth.** It is bounded at three by construction, so it structurally cannot carry how well a person is known; that stays the claim count. Two lines read together tell the story neither tells alone: the counter moves smoothly and shows momentum, the rung moves in steps and shows standing, and they disagree in exactly the places that matter.

**Replay.** The counter is a clamped sum, so order matters only at the boundaries, which is a far smaller surface than a relative-movement ladder. Replay in evidence-occurred order is deterministic.

### Human override · RULED 2 Aug · absolute

**A human-set value on any map dimension is never overwritten by any evidence, ever.** This is the existing precedence law stated at full strength for the map. Contradicting evidence is not discarded: **it still writes its claim, with spans and receipts, and it raises a flag** so the disagreement is visible and countable. What it never does is move the value.

**Coverage is included, with no exception for decay.** If a person sets coverage to full, it stays full. A human write watermarks the dimension forever and the machine stops writing that field.

### No decay mechanism · RULED 2 Aug

**Nothing decays on a timer.** A scheduled job grinding numbers down is an Apex project wearing an AI costume, and it buys a mechanism that has not earned its place. There is no decay class behaviour to build for sentiment or coverage in this wave, nothing configurable, and no batch.

The useful half is free and already derivable. **The latest evidence date for a person is a read over her claims**, so guidance can say she has stood at supporter since April and nobody has spoken to her in four months. That is the fact a seller needs, it requires no job and no new law, and it sits beside the depth and volatility counts. **Nothing decays; the staleness is simply visible.**

### Neutral is the expected outcome · RULED 2 Aug · disposition, never a rate

Buyers conceal sentiment on opportunity calls. Professional warmth is not support, politeness is not agreement, and silence is nothing at all. **The charter text says this as a disposition, and reporting no movement is the expected result rather than a failure.**

**No rate is ever written into charter text.** A charter told that half of people should read neutral will produce that number whatever the evidence says, which is a quota and is the disease this product exists to cure. The rate is an **instrument, not a target**: a no-movement rate that comes back low is a charter defect signal, read the same way abstention rate is already read. Because engagement category locks at stream creation, **the rate is read per category and never globally** — account and service conversations, where people speak far more openly, are expected to differ from opportunity calls and must not be blended into one number.

### Standing versus depth · RULED 2 Aug · they are two facts and no single number carries both

Matthew's own case settles this: **a person at zero after fifty calls and a person at zero having never been met are completely different relationships, and a net score reports them identically.** Net sentiment is the wrong instrument for depth, because addition destroys exactly the history that makes the relationship legible.

So they separate. **Current standing is the rung**, and it is relative: mentor is two increments above supporter from anywhere, regardless of accumulated history. Absolute-score thresholds are rejected for a concrete reason — a person who accumulated a large positive history over three years could never fall below a terminal rung no matter how badly things went, because their past would hold them above the line. The rung answers where they are now.

**Depth is a count, and it needs no new field.** Claims are never edited and every movement writes one, carrying the four keys, both clocks, and the before and after values. So depth is a read over the claim ledger: how many establishing claims exist about this person, at deal grain or account grain, over any window. **The seller-to-buyer grain this requires is already recorded** — key four exists precisely so relationship standing is queryable per internal person, and the field tables state why: a grain not recorded cannot be declared later without reprocessing the corpus. Volatility is the count of direction changes across those claims in evidence-occurred order. Recency is the maximum evidence-occurred. **None of these is stored and all of them are derivable**, which is the correct place for a derived number; a maintained score is a figure that can drift from its receipts, and drift is the disease.

Where a panel needs it fast, it caches into the Roll-Up, which is already an entity and already a cache that rebuilds from claims. **Coverage behaves the same way: the rung caps, the count does not.** And the operational payoff is the case that motivated the split — a neutral person with fifty claims is well understood and genuinely neutral, while a neutral person with zero claims is an unknown who should raise a coverage flag, and the two are now distinguishable by query.

**Owed to the Glossary:** these two quantities need terms, and the Glossary defines vocabulary, not this file.

### Inferred attribution · RULED, gated on measurement

Ratified with a condition that is a gate, not a sentiment. **The gate:** a strip-and-restore harness — take Attributed transcripts, strip the speaker labels, run the attributor on naked text, compare against the stripped truth. Ground truth by construction; every attributed transcript from any org is a free test case forever. Three metrics: side-tier accuracy, identity-tier accuracy, and **anchored-identity precision**, the number dispositional claims stand on. Thresholds are measured, never guessed. **Until the bar is met, Inferred sources run at Any_Participant power only.**

The design: a fourth diarization class `Inferred`; every attribution carries its own cue as a citation; a closed candidate set of roster, calendar, CRM and existing map, assign or say unknown, never invent; an annotation layer beside the frozen bytes, re-markable corpus-wide with no re-ingestion; degradation automatic via the existing speaker requirement, so dispositional claims require identity-tier attribution anchored to a cited cue and unanchored ones land UNVERIFIED with receipts, held for accumulation, never lost.

Research grounding: LLM post-processing corrects who-said-what from text alone with 45-55% relative error reduction (DiarizationLM, Google 2024; generalized 2025); side-level classification from lexical cues is industry-standard; named-identity attribution is recoverable when anchored to cues against a closed candidate set.

**Honest cost:** on text-only stacks, unanchored dispositional claims wait instead of landing.

### Standing laws that bind this charter

Attendance is not evidence of position; a silent attendee establishes at most coverage. Roles are never inferred from job titles. Absence never establishes. Per-charter admission gates: on a town-hall call this charter abstains while insight proceeds. Cardinality guards on every creation path.

### Where People Evidence Contracts come from · RULED 2 Aug · recovered from the org

`AAO_Candidate__c.AAO_Evidence_Contract__c` is required, so every People emission needs a contract. **The contracts derive from Altify's own Help me select question sets**, recovered verbatim below, exactly as assessment contracts derive from the rubric tables. Discovery reads the wizard's questions, not the picklist labels.

**Provenance of everything in this section:** read from `altify--prod` on 2 August by walking the wizard in the relationship map (Salesforce.com October-2026 Renewal), plus the field describe on `ALTF__Contact_Map_Details__c`. Read-only throughout; every modal was cancelled and nothing was saved.

#### The four routes

| Dimension | Wizard | What it is really about | Route |
|---|---|---|---|
| **Coverage** | 3 questions, Yes / No / Not sure | **Our own activity**, not the buyer | **P — a frozen query.** No model call, no abstention |
| **Support** | 5 questions, Yes / No | What the buyer said and did | **E — transcript evidence**, spans, five contracts |
| **Political Status** | 3 questions, 3-way semantic options | Organisational dynamics and deference | **E, overlapping the Politics charter's influence edges** |
| **Buyer Role** | **none — manual pick only** | Structural role in the purchase | **Authored by us** from the definition text |

#### Coverage · verbatim · **RULED a query, not a judgment**

1. Have you or a team member met with this person?
2. Have you or a team member recently had multiple meaningful conversations with this person?
3. Do you or a team member regularly and routinely have high quality conversations with this person?

Values, verbatim from the manual list: **No Contact** "You have never met." **Brief contact** "You or a team member have met this person, but it was brief." **Multiple contacts** "You or a team member have had several substantive conversations with this person." **In-depth** "You or a team member regularly have substantive discussions with this person."

**Every question is about us**, so Coverage is answered by counting our own Sources and never by reading what a buyer said. It costs no tokens and cannot abstain.

**Corrected in v1.1, and the v1.0 text was wrong.** v1.0 called Coverage *a frozen query on the P route*. **It cannot be a frozen query, because participation is not queryable.** There is no Source-to-Contact relation in the schema. Participation lives only in `AAO_Source__c.AAO_Speaker_Roster__c`, a `LongTextArea(32768)` holding JSON, and SOQL cannot filter into a text blob. The recipe ruling does not reach this case: it presumes the question is expressible as a query, and *did this person participate* is not. This is a design claim made by reasoning about our own schema instead of reading it, which is the exact failure the standing rule forbids.

**Ruled: build the participant junction.** One row per Source per person, written at ingest, on our own object, breaking no constraint. It makes all three questions ordinary SOQL and gives the window and frequency counts somewhere to be counted. **The argument is key four's argument:** a grain not recorded cannot be declared later without reprocessing the corpus, and participation is exactly such a grain. The alternative, Apex deserialising rosters at read time, is deterministic and model-free but is not a frozen query and carries a governor ceiling the junction does not.

**One thing the junction does not solve, named rather than papered over.** Questions two and three are not pure counts: they say *meaningful* conversations and *high quality* conversations. A junction counts occasions, not substance. The material for the distinction already exists on Source — `AAO_Substantive_Offset__c` from the small-talk boundary detector, and `AAO_Duration_Seconds__c` — so a conversation with no substantive content beyond the boundary can be excluded deterministically. **The threshold is a measured number and no document carries one until it is measured.**

**This also settles decay for Coverage with no mechanism at all.** *Recently* and *regularly* are time-windowed reads, so the answer changes tomorrow because the window moved, not because a job ground a number down. Consistent with the no-decay ruling: nothing decays, the staleness is simply visible. **A human-set Coverage still wins forever** under the override ruling, window or no window.

#### Support · **nine propositions** · enumerated from labels, opportunity map

*v1.8. **The v1.7 set of five is superseded** — it was a walk of the positive spine presented as the ontology. Read from `ExternalString` by exact label, overlay queried and empty, spelling and punctuation untouched.*

| Label | Proposition |
|---|---|
| `AM_OM_SUPPORT_GUIDED_QUESTION_1` | Has this person expressed a preference for a specific solution? |
| `AM_OM_SUPPORT_GUIDED_QUESTION_2` | Has this person told you they prefer your solution over all other alternatives? |
| `AM_OM_SUPPORT_GUIDED_QUESTION_4` | Does this person believe your solution is critical to their success and do they sell internally for you in your absence? |
| `AM_OM_SUPPORT_GUIDED_QUESTION_5` | Is this person mentoring you by providing guidance, political insight, or competitive information? |
| `AM_OM_SUPPORT_GUIDED_QUESTION_6` | Has this person told you they prefer an alternate solution, including an internal solution or do nothing at all? |
| `AM_OM_SUPPORT_GUIDED_QUESTION_7` | Is this person mentoring your competition and working to help them win? |
| `AM_OM_SUPPORT_GUIDED_QUESTION_11` | Does this person prefer an alternative solution -including an internal solution or nothing at all? |
| `AM_OM_SUPPORT_GUIDED_QUESTION_14` | Is this person vocal in their support of your competition? |
| `AM_OM_SUPPORT_GUIDED_QUESTION_16` | Do you have evidence that this person believes your success will hurt their company or jeopardise their personal success? |

**The structure is symmetric rather than a tree, and that is the correction.** `_1` is a direction-neutral gate. Then **matched pairs point opposite ways**: `_2` prefers *your* solution against `_6` prefers an *alternate*; `_5` mentors *you* against `_7` mentors *your competition*. `_11`, `_14` and `_16` extend the negative side alone. **Altify authored the negative half of the ladder explicitly**, and a walk down the positive spine structurally cannot see it.

> **This strengthens the tree-owns-the-rung ruling rather than complicating it.** Enemy is not the far end of a scale reached by running out of positives. **It is a positively established state with its own evidence questions**, and `_16` says so outright by asking for *evidence that* this person believes your success will hurt them. That is **absence never establishes, honoured in the vendor's own authoring.** Nine propositions, and four of them establish the negative direction.

**Element structure.** `_4` is compound (believes it is critical **and** sells internally). `_5` is a three-way or (guidance, political insight, competitive information). `_16` is compound the same way (their company **or** their personal success). **`_6` and `_11` are near-duplicates with different wording and a stray hyphen, and they stay two propositions** — collapsing them is paraphrasing, and an authored set edited over years is supposed to look like this.

**Speaker requirement.** `_2`, `_4` and `_6` say *told you*, which fixes `Subject_Person`: this finding's own person, speaking to the seller. `_14` and `_16` do not, and `_16` asks whether **the seller** holds evidence, which makes it observational rather than reported.

**RULED 2 Aug — the tree owns the rung. Ontology where ontology is feasible, inference only where it is not.**

Matthew's principle: **the ability to infer binary is superior to feeling out scores.** Applied here, it decides every dimension we have. Support, Political and Coverage all carry authored question sets recovered from the org, and Buyer Role we author ourselves, so **all four are ontology-backed and none of them uses a score.** A person's Support rung is what Altify's tree computes from five propositions, each established with the person's own quoted words.

**The one-per-source law and the clamp are WITHDRAWN for ontology-backed dimensions**, and the reason is that the thing they guarded against no longer exists. They stopped a single call's *feel* from teleporting someone, which was correct while movement came from reading sentiment. Movement is now caused by specific propositions, byte-verified against frozen bytes. If a person said all five of those things in one conversation and we hold the spans, they are a mentor, and refusing to say so would be our arithmetic overruling both the customer's methodology and the evidence. **CODE's teleport objection is answered by dissolving its premise rather than by overriding it.**

**The counter is demoted, not deleted.** The clamped integer from minus three to plus three, one increment per source-event, remains the **inference fallback for any dimension that has no ontology.** After this recovery that is none of the four, but a bare org, a customer-invented dimension, or a future charter may need it, and it is a ruled and built mechanism that should not be thrown away.

**Two things survive intact, which is what makes this safe.** *People are fickle:* one FALSE on the mentoring question still drops a Mentor to Supporter, immediately. *It takes more to earn an extreme than to lose it:* Mentor sits behind two conditions beyond Supporter, so reaching it requires two distinct establishments while losing it requires one. **That is the plus-two-to-enter, minus-one-to-leave asymmetry ruled in v0.8, arrived at structurally instead of arithmetically.** And the trend line is better than the counter's: the count of conditions met, zero through five, where every step names which condition moved and quotes the words that moved it.

*(Superseded discussion retained below for the record.)*

**The v1.1 analysis, now resolved.** CODE's audit turned this from a preference into a fact, and the fact decided it.

**The tree and the counter cannot both own the rung.** The tree derives a rung from five booleans held *now*: five conditions landing in one call would move someone Neutral to Mentor in a single source-event, **which is exactly the teleport the one-per-source law exists to forbid.** The counter derives standing from movement over occasions. One is a state read, the other a history. If the tree owns the rung, the one-per-source law and the clamp stop meaning anything and must be **withdrawn rather than left sitting beside it.** They compose in one direction only.

**Recommended: the counter keeps the rung, and the five contracts become what generates each move.** A contract answer changing is the movement: Q4 going UNVERIFIED to TRUE proposes plus one, Q5 going TRUE to FALSE proposes minus one, and **at most one increment per source-event however many contracts moved.** That keeps every ruling intact — one per source, the clamp, terminal rungs costing two to enter and one to leave — while giving every single move a receipt that names which condition changed and quotes the words. It also preserves the two trend lines and makes them more useful, because the counter and the count-of-conditions-met can legitimately disagree: a person whose standing rose over five occasions while only two conditions are established reads as warming without commitment, which is a true and useful thing to see.

**The case against the tree owning it, beyond teleport:** the tree makes entry as easy as exit. One TRUE on Q5 would promote to Mentor instantly, which is the opposite of *it takes a lot for you to have a negative sentiment on a call* and of terminal rungs being earned.

**Matthew's, and it is the last open decision in the People charter.**

#### Political Status · **seven propositions** · enumerated from labels, opportunity map

*v1.8. **The v1.7 set of three is superseded.** Four are shared with the account map; three are opportunity-only, and the account map carries its own differently-worded `AM_` versions of those three — so **no single list is the ontology** and reading one map's for the other puts the wrong proposition on a contract.*

| Label | Proposition |
|---|---|
| `OM_POLITICAL_STATUS_GUIDED_QUESTION_1` | Does this person define the company’s goals and objectives, or do they merely have a good understanding of them? |
| `OM_POLITICAL_STATUS_GUIDED_QUESTION_2` | Does this person approve and sponsor initiatives, or do they execute projects after they are approved? |
| `AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_3` | Do others seek this person out for advice and direction? |
| `AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_4` | Does this person control the outcomes or are they called on to make it happen? |
| `AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_6` | Does this person have a track record of success in implementing projects that deliver value? |
| `AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_7` | Does this person collect and provide information to people of power and influence? |
| `OM_POLITICAL_STATUS_GUIDED_QUESTION_9` | Is this person aware of the politics in the organisation? |

**Two of the seven are not about authority at all, and the walk lost both.** `_6` is **track record** — has this person actually delivered before. `_7` is **information brokering** — the person who holds no power and is connected to those who do, and feeds them. The three walked questions were all about position, so **a seven-question ontology read as three collapsed political standing into hierarchy**, which is precisely the reading a relationship map exists to improve on.

**`_1`, `_2` and `_4` are two-sided rather than yes-or-no** (defines *or* merely understands; approves *or* executes; controls *or* is called on), which is why the wizard offers semantic options. The proposal enum for this dimension is runtime-closed from those options rather than from a verdict picklist. And **Not sure is a first-class answer in Altify's own methodology**, which is abstention built into the vendor's design and an argument usable directly.

Values, verbatim: **Inner Circle** "Decides what will be prioritized and controls the outcomes." **Political Structure** "Trusted by the Inner Circle to make things happen." **Outside Political Structure** "Has little to no political power, but is called upon by key players to provide evaluations and information." The Inner Circle panel adds that the buying team may have one to three people in it.

#### Proposition text is stored byte-exact · LAW · v1.8

**`organisation` on the opportunity map against `organization` on the account map. `jeopardise`. The stray hyphen in `_11`'s `-including`. The curly apostrophes in `company’s` and `customer’s`.** None of it is tidied on the way in.

**A normalised quote is a paraphrase.** This is the same law that makes the byte check possible on spans, applied to the proposition instead of to the evidence, and it is what lets a flag say *the qualifier says each, and here is who is missing* without having quietly rewritten the sentence first.

#### Buyer Role · verbatim · **no wizard exists**

Manual pick only, with definitions and nothing else. **Approver** "Senior level person who retains the right to review, approve or veto decisions, and typically release the funds." **Decision Maker** "Listens to recommendations, evaluates evaluation results, makes a commitment to a partner, vendor and/or strategic direction." **Evaluator** "Responsible for analysing proposed solutions against defined criteria." **User** "Uses your products/services." **Signature Approver** carries no definition. **Unknown** "Unknown buying role."

**This is the one dimension where we author the propositions**, because Altify never decomposed it and the definition text is all that exists. Contracts authored this way carry `AAO_Elements_Basis__c` of `Inferred_Pending` until ratified, which is the existing law doing exactly what it was built for. **Decision Orientation is deliberately skipped** — it was null on every live row sampled, so nobody fills it.

#### Consequences for the object model · three gaps found by CODE's audit, all ruled in v1.1

Every People contract needs `AAO_Route__c` set per the table above, and `AAO_Elements__c` from the compound questions. Three things v1.0 assumed have nowhere to land in the org as it stands.

**1 · A participant junction, per the Coverage correction above.** New object, one row per Source per person, written at ingest.

**2 · `Source` must become a cited type on Claim Basis.** Route P writes basis `State`, and the evidence-family law requires at least one Claim Basis row, with `requireBasisRows` throwing in-transaction otherwise. `AAO_Cited_Type__c` offers `Map_Row`, `Insight_Card`, `Decision_Criterion`, `Answer`, `Qualifier_Status`, `Shadow_Person` and **no `Source`** — so a Coverage claim citing the Sources it counted is refused by our own law. Add the value and an `AAO_Cited_Source__c` lookup. **Recorded alongside it, a documentation-versus-org drift worth fixing separately: only two of the six declared cited types (`Answer`, `Map_Row`) have lookup fields built. The other four are enum values pointing at nothing.**

**3 · `Subject_Person` must become a speaker requirement.** Support Q2 and Q4 say *told you*, which v1.0 read as fixing a speaker requirement. It does not, because every existing value — `Seller`, `Any_Participant`, `Buyer_Side`, `Decision_Maker_Or_Influencer` — names a **class** of speaker, and these questions name a **subject**: this finding's own person said it. Without it, Q2 and Q4 would pass on a colleague vouching for someone else's preference, which is precisely what the wizard's wording excludes. **It is cheap here and nowhere else**, because the People handed unit is person crossed with dimension, so the gate already knows who the finding is about; `evaluate` gains the subject to compare against.

**Answered, from CODE's read of the org:** `AAO_Element_Count__c` carries one for single-element contracts and zero does not appear. All twelve live contracts match their element-list length. Zero is unreachable by construction, since `AAO_Discovery.parseElements` returns the proposition itself as a single element when Help carries no `Elements:` block, and a zero would fail safe anyway because `Coverage.isFull` returns false on an empty list.

### Owed by the next version

The remaining Political Status terminals. The Problems charter's use of Altify's existing **"Who told you about this?"** field on insight cards, observed empty in production on 2 August: the provenance slot the methodology already provides and nobody fills, which is where our citation belongs rather than in a field we add.

---

## 2 · The Problems charter (insights + criteria) · **OPEN — tension (a) still Matthew's**

### What the map is for · RULED

**Call prep: who has what problem, why it matters, in their own words.** The production read proved the failure mode this charter prevents: cards generated from public filings read as research notes, carry no provenance, contradict each other, and sit unconfirmed forever. A card earns its place when a person said the thing, and the card can say who and when.

### Admission · RULED

**Every genuine insight caught goes on the map.** No materiality threshold, no cap. The filter is genuineness, never importance; importance is what confirmation counts measure over time. Duplication is handled at write time: **the machine must infer duplicated meaning**, because the same problem restated in new words is reinforcement, not a new card.

### Dedup and reinforcement · RULED

**Keep the parent card. Never write a sibling.** Prepend the count to the card text ("2x", then "3x"), append the reiteration in plain words. A different person expressing the same insight appends the attribution without restating the insight. **Completely different language is a different insight.** Every reinforcement is a Claim with outcome Reinforced, so the count on the card is always reconstructible from receipts.

### Citations on cards · RULED

**Extremely short, plain text, human-readable.** Date plus speaker: "on a demo call June eighth." **No URLs, no record IDs, no hyperlinks.** The full receipt lives on the Claim; the card carries only the sentence a seller would say out loud.

### Confirmation · RULED

Expressed twice in one call confirms. Expressed once lands unconfirmed. Re-mentioned in a later call notes the date and confirms. A different person appends attribution and the counting follows. **Humans will never drag cards. Never assume a gesture.**

### Annotation law · RATIFIED

**The machine annotates only machine-authored cards; reinforcement of a human card is a Claim with outcome Reinforced beside the card, never inside its text.** Under the no-channel-recognition ruling this covers agent-written cards too.

### The insight ontology · RECOVERED FROM THE ORG 2 Aug · and it contradicts the admission ruling

Same finding as the People charter, same place: **each insight type carries an authored three-question admission test**, shipped behind the *What is a…* link on the card panel, plus an examples list. Read from production 2 August, read-only. Four of five recovered; **Solution is owed** because that lane was empty on the map walked.

**Goal** — Is this a goal of the decision maker specifically and not a company goal? · Do you know how the decision maker is measured or compensated? · Is the anticipated result or goal quantified and within a specific time frame?

**Pressure** — Does the pressure fall into one or more of the pressure categories: Financial, Operational, Customer, Partner, Technology, Supplier, Market or Competitive? · Has the pressure caused a project to be sponsored, funded and prioritized by the decision maker? · Will this pressure prevent a goal from being achieved?

**Initiative** — Are there internal or external pressures that have caused this initiative to be Funded/Sponsored/Prioritised? · Is this initiative in place to address internal or external pressures? · Will the success of this initiative have an impact on the decision maker's goal?

**Obstacle** — Is this a task, situation or process that can be fixed with your solution? · Is this a task, situation or process significant enough to establish substantial value if you can fix it? · Is this a task, situation or process that will have negative consequences if it is not fixed?

> **v1.8, from the label enumeration. The insight tests split by map too, and unevenly.** Goal, Pressure and Initiative each carry **six** — `_1.._3` plus a separate account-map set `_AM_1.._AM_3` — while **Obstacle carries three with no account variant at all**, and Solution's four have `SOLUTION_DEF_AM` and `_OM` that are identical. That asymmetry is informative rather than accidental: **obstacles are deal-local, while goals, pressures and initiatives exist at account level too.** No walk can reveal this, because a walk sees one map at a time.
>
> **And `PRESSURE_HELP_TEXT_3` is the sharpest line in the whole enumeration.** *Will this pressure prevent a goal from being achieved?* **A Pressure cannot pass its own admission test without knowing which Goal it blocks — and the schema has no field for that relation.** `ALTF__Impact__c` is free text doing double duty as desired-outcome for Initiatives, and the only structural card-to-card edge points at Solutions. **The methodology asks about the edge its own schema cannot hold**, so every Pressure card that ever passed this test carried knowledge the record then threw away. That is the argument for the edge work, stated by the vendor.
>
> **One pattern hazard, from both directions at once.** `%HELP_TEXT%` **over-collects** — `PRESSURE_EDIT_TYPES_HELP_TEXT` and `SOLUTION_EDIT_HELP_TEXT` are edit-form guidance rather than admission tests. Sparse numbering means an iterator **under-collects**. **So an assembler reads by pattern, filters by family, and is loud when the families do not match what it expected** — the discovery-filter-fault law, pointed at labels.

**Solution** — **four questions, not three** — How does your Solution address the Obstacles for your customer's initiative? · What Pressure(s) will your Solution have the most impact? · How does your Solution contribute to achieving their Goals? · Would a key player be able to articulate your unique business value from this Solution?

**Terminal states differ per type** and no two share a lifecycle: Goal runs Unconfirmed → Confirmed → **Achieved**, Pressure → **Resolved**, Initiative → **Completed**, Obstacle → **Overcome**, Solution → **Implemented**.

**Two things about Solution's test that change other rulings.**

**Three of its four questions are about links to other cards.** Obstacles, Pressures, Goals. **Altify's own definition of a Solution is what it connects to**, which means the unlinked-Solution flag is not our invention: a Solution card with no edges fails the vendor's published test. That is a materially stronger position than the one the flag was ruled on, and it should be the sentence used when the flag is explained to anyone at Altify.

**The fourth question is the strongest evidence proposition on the whole map.** *Would a key player be able to articulate your unique business value from this Solution?* Everything else on the insight map records what the seller believes or what the seller was told. **This one is checkable from a transcript in a way almost nothing else is**, because it asks whether the buyer said the value back in their own words — a span, from a named key player, byte-verified. It also composes with the People charter, since *key player* is a defined state on the map (`ALTF__Is_Key_Player__c`, derived from political status of inner circle or political structure), so the subject set is closed and queryable.

**Examples lists exist per type** and are few-shot grounding rather than vocabulary. Initiative's twelve, verbatim: digital transformation, improve employee productivity, leverage employee strengths, improve quality processes, recruit top talent, streamline core business process and tools, improve product release cycle, technology innovation, expense control initiatives, optimise sales process, improve reporting and transparency, maintain alignment across the organization.

#### The person-to-card relation · **four questions, two stored values** · read from the org 2 Aug

**The methodology distinguishes four relations and the schema stores two.** Every card panel asks a type-specific question about the people attached to it, and they are not the same question:

| Card type | The question the panel asks | The relation |
|---|---|---|
| **Goal** | Who is the Decision Maker responsible for this Goal? | **responsible for** (one or more) |
| **Initiative** | Who is responsible for the success or failure of the Project/Initiative? | **responsible for** |
| **Pressure** | Who is impacted by this Pressure? | **impacted by** |
| **Obstacle** | Who is impacted by this Obstacle? | **impacted by** |
| *all types* | Who told you about this? | **informer** — provenance, distinct from both |

`ALTF__Insight_Card_Contact__c.ALTF__Type__c` carries exactly two values: **`Informer`** and **`Owner`**. So *impacted by* and *responsible for* are stored identically. **Being crushed by a pressure and being accountable for an initiative are the same row.**

**Why this matters more than it looks: it is the difference between guidance that lands and guidance that is nonsense.** Speaking to someone impacted by a pressure, where we hold a solution for that pressure, the sentence is *this takes that pressure off your shoulders* or *this removes that obstacle from your job.* The same row read as ownership produces *you own this obstacle*, which means nothing to the person hearing it. **The relation is what makes the guidance addressable to the human in front of you.**

**Ruled: derive on read, record on write.** For existing human-authored cards the relation is recoverable from the card type, since the type determines which question was asked, and that is all those rows carry. **We do not derive it for our own claims.** The buckets are demonstrably noisy — cards are notes loosely fitted, which is why dedup went type-blind — so a problem typed as a Goal would derive as *responsible for* when the truth is *impacted by*. Our own establishments record the relation explicitly. **Do not infer what you can record**, and this is a grain that cannot be declared later without reprocessing.

#### The causal chain is taught, not stored

Pressure cards uniquely name the **Goal(s) being impacted**, but that is `ALTF__Impact__c`, a free-text area doing double duty (*for pressures, the goals being impacted; for initiatives, the desired outcomes*). **There is no structural Pressure-to-Goal relation.** The only real card-to-card edge is `ALTF__Insight_Card_Edge__c`, whose second lookup is `ALTF__Solution_Insight_Card__c` — it links a card to a **Solution** and nothing else.

So the chain the methodology teaches, pressures driving goals driving initiatives driving solutions, **is queryable for exactly one hop.** Altify's own MCP server lists *clear linkage: Pressures → Goals → Initiatives → Solutions* as the healthy pattern while the schema cannot answer whether it holds. **This is Politics charter territory and it is a larger opening than the person mapping**, since the charter's job is mapping people into insights and the insight-to-insight structure is missing underneath it.

**Initiatives additionally carry `ALTF__Priority__c` (Low / Medium / High)**, the only insight type with a priority field. Whether we write it is open; it is a human's ranking, not an establishment.

#### The provenance field already exists · **"Who told you about this?"**

Every card panel carries a **Who told you about this?** contact field, and in production it is **empty on every card inspected.** Altify's methodology already provides the provenance slot; nobody fills it. **Our citation belongs in that field, not in a field we add.** Pressure and Obstacle additionally carry *Who is impacted by this*, Goal carries *Who is the Decision Maker responsible for this Goal*, and Pressure carries a Pressure Type checkbox set matching its admission question's categories.

#### The contradiction, and it is Matthew's

**v0.5 ruled: every genuine insight goes on the map, no materiality threshold, the filter is genuineness and never importance.** Altify's own admission test disagrees. Obstacle question two is *significant enough to establish substantial value* — that is a materiality threshold, authored by the methodology. Goal question one excludes company goals in favour of the decision maker's personal goal, which would refuse most of what a call actually surfaces. Initiative and Pressure both require a funding or sponsorship consequence.

So the two cannot both govern, and the choice is real. **Take Altify's test** and the map stays small, every card is defensible against the customer's own methodology, and we admit far less than v0.5 intends. **Keep v0.5's admission** and the map is fuller and more useful for call prep, but our cards would not pass the vendor's own published bar, which is an awkward thing to demo to Toby. **A third path exists:** admit on genuineness as ruled, and run the three authored questions as *elements* on the card's contract, so every card records which of the three it meets. Nothing is refused, and materiality becomes queryable rather than a gate.

The third path is the one that fits the rest of the build, since it is the same move as element coverage on assessment answers, but it is a ruling and it is yours.

### The Problems output schema · v0.7

**Handed units: the existing cards on this deal's map**, machine-authored and human-authored alike. Per card, `addressed` proposes a reinforcement, `not_addressed` means nothing in this evidence touches it, and `abstained` means something touches it but the meaning-match cannot be called. **The meaning-match uncertainty gets the abstention channel instead of a forced guess**, and its rate is measurable per the envelope law.

Body on a handed (reinforcement) finding:

```json
"body": {
  "type": "object",
  "additionalProperties": false,
  "required": ["same_meaning_because"],
  "properties": {
    "same_meaning_because": { "type": "string", "description": "One sentence: why these words restate this card. Empty is not valid here — a reinforcement without a stated match reason is unauditable." }
  }
}
```

Body on a discovery (new insight) finding:

```json
"body": {
  "type": "object",
  "additionalProperties": false,
  "required": ["kind", "statement", "nearest_existing"],
  "properties": {
    "kind":             { "type": "string", "enum": ["insight", "criterion"] },
    "statement":        { "type": "string", "description": "The insight in the speaker's own words, drawn from the cited spans. Card text is composed by the writer; the model never writes card furniture." },
    "nearest_existing": { "type": "string", "description": "Runtime-closed: the card ref this most resembles and was judged different from, or NONE. Every new card names the card it refused to be." }
  }
}
```

Both carry `AAO_Proposed_Verdict__c` of `TRUE` where they propose (this reinforces; this is a genuine insight). **The speaker comes from the spans and the date from the Source's evidence-occurred clock; neither is ever model-emitted**, so a card can never carry a spoken date that drifts from its receipt. Counts, reiteration sentences, attribution notes and the short plain citation are composed by the writer from claim rows.

**Recorded as NEEDS MEASUREMENT:** the meaning-match is machine judgment with no byte-verifiable gate. `same_meaning_because` and `nearest_existing` make it auditable, not proven. Whether it warrants a second blind reader is decided by measuring disagreement on staged truth, not by ruling now.

### Solutions · RULED 2 Aug · the card is state, the edge is evidence

**Moved in from parked.** v0.5 listed quick-links from insights to solution cards as guidance enrichment, not this wave. This ruling brings the solution half in; the qualifier half stays parked.

**The join exists end to end, read from the org 2 Aug.** The Altify package puts a Solution lookup on the standard **`Product2`** object, and `ALTF__Insight_Card__c.ALTF__Solution__c` points at the same `ALTF__Solution__c` records. So the chain runs **OpportunityLineItem → PricebookEntry → Product2 → ALTF__Solution__c → Solution insight card**, entirely readable, with no model anywhere in it.

**The line, and it falls between the card and the edge.**

**The card is a fact.** A Solution card derived from a line item asserts *this product is on this deal*, read from records. Route P, basis `State`, citing the line item. **No ratification**, because ratification exists to get permission for a machine judgment and there is no judgment here. **The projection toggle still applies**, because it is a write into an object we do not own.

**The edge is a claim.** An edge from a Solution card to an Obstacle or Pressure asserts *this product addresses that problem*, and a line item cannot establish that. It records what is being sold, never which of the customer's problems it solves. **Deriving the edge from the line item would be inference wearing the costume of a record**, which is the exact failure this build exists to prevent. The edge requires someone to have said it, with spans, or a human to draw it.

So the two candidate sources are not alternatives. **Line items give you the card. Calls give you the edge.**

### The unlinked-Solution flag · RULED 2 Aug · required, yellow

**A Solution card with no edge to any Pressure or Obstacle raises a required yellow flag.** The value is not the card, it is the absence: the system saying out loud that *you are selling this and nobody has told you what problem it solves*. That gap is real, it is invisible today, and the card is only the thing that makes it visible.

**Clearance is the ordinary rule and there is no dismissal**: the flag goes when the edge exists, which means when evidence establishes the link or a human draws it. **It fires from the start**, consistent with day-one red firing from opportunity CreatedDate rather than waiting for discovery to happen.

**A new kind of flag, and it should be built as a kind.** Every existing flag fires on a **proposition** being unmet. This one fires on a **missing relation**. The Politics charter will need exactly the same shape for missing influence edges, and the Pressure-to-Goal chain has the same hole, so it is worth building as a general missing-edge flag rather than a solution-specific one.

**Volume · RULED 2 Aug · one flag per deal per relation kind, rolling up the cards inside it.** Neither of the two shapes first proposed. One flag per unlinked card produces eight on a deal with eight line items, and Matthew's constraint is that guidance must be selective or it becomes noise. One flag per deal is too coarse, and the reason is the one that decides it: **the action differs per relation kind.** Clearing *solutions with no stated problem* is one conversation; clearing *pressures with no linked goal* is a different one; clearing *people with no influence edges* is a third. Blended into a single flag they produce a count nobody can act on.

So the flag is keyed on **deal plus relation kind**, and it **names the specific cards inside it** rather than only counting them, because a seller cannot act on a number. **It clears when the count reaches zero**, and the count is itself the progress indicator, which is consistent with a flag clearing only when its cause is gone and never by dismissal.

### The cited-type enum · RULED 2 Aug · it grows typed, and there is a test for what earns a lookup

**One addition, not two.** The claim is *this product is on this deal*, and the evidence for it is the **OpportunityLineItem**. Product is a field on that line item and is reachable by traversal, so citing `Product2` separately would be citing a classification rather than a fact about this deal. **`Product2` is not added.**

**The enum grows typed rather than taking a generic shape, and the test is this: a cited type earns a typed lookup when we will compare its current state against the frozen snapshot.** That comparison is the entire reason Claim Basis is half frozen and half live — one subquery returning what a row said when the claim was written beside what it says today — and a text Id with a type name cannot do it, nor support lookup filters, reporting by related record, or the orphan sweep. **Anything we would never look at again does not need a lookup**, because the snapshot alone is the whole evidence, and such a row can carry a plain reference for audit instead.

That gives a line to hold rather than a habit of adding, and it explains the existing set: `Answer`, `Map_Row`, `Insight_Card`, `Decision_Criterion`, `Qualifier_Status` and `Shadow_Person` are all things whose live value we expect to diverge from what was cited. **Four of those six still have no lookup built and remain owed.**

### Parked

Quick-links from insight cards to **qualifiers**: guidance enrichment, not this wave. *(The solution half of this item is ruled above.)*

### Machine confirmation · RULED 2 Aug · an autonomy level, not a fixed answer

**The v0.5 tension is resolved by making it configurable rather than by choosing one of its three options.** Whether a card moving to Confirmed raises a yellow flag for a human first, or is written directly, is **a per-customer autonomy setting**, the same shape autonomy already has everywhere else: it governs who approves, never what is checked. A cautious org gets a flag on every confirmation. A confident one lets the evidence rules write it.

**The evidence rules are the ones already ruled and do not change:** expressed twice in one call confirms, expressed once lands unconfirmed, re-mention in a later call notes the date and confirms, a different person appends attribution. **Added: a statement from a decision maker confirms on its own**, which is the speaker-rank law applied to confirmation rather than a new principle.

**The reason the original tension has lost most of its force is evidence, not argument.** Confirmed was supposed to mean a named human vouched. In production it does not: five cards created inside twenty seconds on 31 July all landed with `ALTF__Confirmed__c` true, `ALTF__ConfirmedBy__c` naming a person who could not have read them. **The word drifted before we touched it.** Watermarking our confirmations would distinguish ours from a corpus that is already mixed, which is worth doing for our own rows and cannot repair theirs.

### Enablement sections · a guidance surface, recorded not ruled

Where a Solution card is attached to a real `ALTF__Solution__c` record, that record carries **`ALTF__Solution_Section__c`** children, seen in production as *Key Messages, Discovery & Business Case*, *Sales Tools*, *Case Studies & Customer Success Stories*, *Competitive Positioning*. **This is authored enablement content already sitting inside the CRM, keyed to the solution being sold.**

Its significance is that guidance can reach it: when a red or a flag concerns a specific solution against a specific obstacle, the material to act on is one join away, in the customer's own words rather than a generic library. **That is the value a separate enablement or DAM tool delivers, arriving inside the same application, driven by evidence rather than by a content recommender.** Not ruled and not this wave; recorded because it changes what guidance is capable of and should be designed for rather than discovered later.

### Open — Matthew's

*(Nothing structural. The v0.5 confirmation tension is ruled above.)*

---

## 2.5 · Backdated evidence · RULED 2 Aug

**Scope first, because it is smaller than it looks.** Backdating is a notes problem, not a general one. Transcripts arrive close to when they happen; **notes are batch-entered at the end of a week, a month or a quarter**, and that is essentially the whole population of backdated evidence after an org's first fortnight.

**The ruling: re-derive.** A backdated claim settles into its true position on the occurred clock, replay runs the sequence, and the person lands where the ordered evidence puts them. **No age cap.** A cap would be an invented constant, and the only guard is a validation check, not a sentiment rule: **an evidence date preceding the opportunity's own creation is a typo, not history.**

**The condition that makes re-derive safe is that the story must be readable.** A rung that changed for reasons a seller cannot see is spooky; a rung that changed with the sequence spelled out in plain sentences is just true. So a flag raised by a re-derived change **carries the sequence, not only the new state**: she is no longer in supporter range, a note dated the first arrived on the thirtieth recording a negative call, here is the order of what happened.

**Why this is cheaper than it first appeared.** The counter is a clamped sum, so within the clamps the arithmetic commutes and order is irrelevant. Only the boundaries care about sequence, so most backdated notes change nothing about where a person stands, and the ones that do can say why.

### The narrative read · RULED 2 Aug

*Tell me about Sarah, how did we get here* is a query, not a new capability. Claims carry the contact as key three and the internal person as key four, so her history is a read filtered by her and ordered on the occurred clock. **Nothing new is stored to support it.**

**One rule keeps it honest: the narrative may state only what a claim row says, in the order the clock gives, and may not characterize or conclude.** It renders receipts; it never establishes. It inherits the citation law already ruled for cards, which is dates and speakers in plain words and **never a record ID on any surface a human reads.**

---

## 3 · The Politics charter (links, influence, conflict) — not yet opened

*One charter at a time, same as the objects: present, close, move on.*


---

# PART II · The Scope Resolver (absorbed)

# AAO Scope Resolver

> **The version lives on the stamp line below and nowhere else.**

**v0.4 · 2 August 2026 · The net-new participant rule: added to BOTH maps on a dual-scope call, because coverage is a claim and presence establishes it in both scopes. Supersedes adds-nobody and the establishment-gated proposal. Dimensional writes stay establishment-gated per scope. This closes the last open behavior of the resolver except per-claim scope.**

**v0.3 · 2 August 2026 · The B&V test ran and two rules graduate from it: the two-key lock and the dual-write rule. The which-opportunity match is no longer open — it worked on a real four-opportunity account, with one weighting correction.**

**Changed in v0.3, ruled by Matthew from the test.**

**The two-key lock · RULED.** Tests 1 and 2 both always run and **neither resolves alone.** Agreement resolves; disagreement falls to traversal. The org itself supplied the counterexample that forces this: Casey, a Customer Success Manager, owns both Black & Veatch renewal opportunities, so an account-oriented role owning deal calls is not an edge case, it is how renewals work. Role stops being a short-circuit and becomes half of a two-key lock, which also means a wrong entry in the role map can no longer misroute a call by itself.

**The dual-write rule · RULED.** When both scopes resolve, the evidence is related to **both** — the account and the specific opportunity. **ECI's failure on the B&V call was singularity, not the pick:** its one-slot stamp chose the right deal and thereby lost forty minutes of account truth. Under the dual rule, map details update in both scopes for already-mapped people, each scope's rubrics reading their own side of the two-sided summary; establishment rules are unchanged, no establishment no write, restatements land as reinforcements, and nobody new is added to either map by a dual-scope call.

**The overlap read weights curated rows, never bare membership · RULED from the clone finding.** Altify seeded the stamped deal's map by cloning all 44 account-map rows at creation; only nine were ever curated. Bare membership overlap is therefore inheritance, not signal. The discriminating read is rows a human touched — curated attributes, non-default values.

**The B&V test result, recorded:** scope read on 61% of the transcript returned account-primary with expansion seeding (Adam Meloan's *"maybe that is one of our first business cases"*), which is the dual trigger per the ontology's own caveat. Which-opportunity resolved to Community Licenses-150 by agreement of curated-overlap (3 of 3 participants curated there; 1 of 3 on the demo deal; 0 of 3 on both renewals) and content match (community licenses and MCP use-case talk; zero renewal language). Participant-to-contact proved deterministic in ECI orgs: `VideoCallParticipant.RelatedPersonId` was populated with real Contact ids on every external row.

**v0.2 · 2 August 2026 · Matthew's corrections land: the account-map check replaces the account-plan check, ownership traversal is demoted to a suggestive read, the which-opportunity match gains its method and stays OPEN pending the live test, and dual-scope gains the two-sided summary.**

**Changed in v0.2, all from Matthew.** **The account-plan check is dead.** Account plans are an Altify schema most customers will not have — half or more run relationship and insight maps only — and a plan can live in a PowerPoint no system sees, so gating anything on plan existence fails orgs for not owning a feature. **The check is whether an account MAP exists** — account-scoped map or insight rows — which is readable in every org that has the smallest footprint. **Ownership traversal is demoted from deterministic to suggestive:** with CPQ or SAP carrying the commercials, the CRM cannot prove what an account owns; closed-won history over a trailing window suggests ownership and guarantees nothing. And one floor stated: **a call in scope at all means at least one open opportunity exists**, because licensed-owner scoping is what admitted the call, so which-opportunity always has a candidate.

**What this file is.** How one piece of evidence learns which map it may speak to: an opportunity or the account itself. This decision runs before any charter and gates every write. Wrong scope on a call writes machine claims into a seven-figure deal record or pollutes a durable account map, so the resolver is held to the same bar as establishment even though it only routes.

**Why nothing platform-supplied can carry it, measured 2 August.** ECI's `RelatedRecordId` is inference and unstable inference: the same recurring meeting (Altify | T-Mobile Lion Team, one series, five instances) was stamped to the account twice and to an opportunity three times inside five weeks. A CSM's account call (Altify | Black & Veatch Bi-weekly, 24 June) was stamped to an opportunity while its transcript discusses adoption, enablement, MCP rollout and QBR prep, with not one sentence about the deal it was filed under. And roughly 75% of target customers have no ECI at all; their transcripts arrive as files with no related record. **The stamp, where present, is one input. It is never the answer.**

---

## The tests, in order · RULED

**The ladder is ordered by decisiveness, not by determinism.** That is the correction to the first draft of this design: a deterministic read whose meaning cannot be interpreted alone is not decisive. Ownership traversal is perfectly deterministic and means nothing by itself, because an account that owns product still runs new-business and expansion deals. So the cheap decisive test runs first, the near-decisive semantic test second, and the deterministic-but-ambiguous read serves as the interpreter's evidence, not as a verdict.

### Test 1 · The call owner's role · deterministic at runtime

**The owner-organizer of the call is the person whose work the call is.** An account manager organizing a call is doing account work even when she pulls in a seller to demo the product she needs demonstrated — the B&V call exactly. Speakers do not control; the organizer does.

The owner's role resolves through the **role map**: this org's role names classified account-oriented or sales-oriented, **derived once per org at setup, model-proposed, admin-ratified in one sitting, cached forever** — setup-time inference, the same mechanism as persona derivation and computability. One ratification at install. **No per-call and no per-series ratification exists anywhere in this design.**

Internal owner, mapped role → resolved. Sales-oriented → deal side, and Locate narrows to which deal (Test 3 supplies the match where no ID exists). Account-oriented → account scope, done. External or unmapped owner → fall through.

### Test 2 · What is discussed · the scope read, basic inference

A summary-level read of subject, agenda and transcript answering one authored question: **is this call about account matters or opportunity matters.** It runs second because its answer prunes everything after it: **an account verdict ends the resolver** — no traversal, no ownership check, nothing else to know.

The sided vocabulary it reads against is **ours to author, shipped as seed metadata exactly like the People ontology** (two fields, org override, LAW #1 shape). Draft below, owed correction.

This is inference and it is admitted deliberately: what a call is about is nearly always sayable from what was said, the classification **routes and never establishes**, nothing it produces is cited, and its failure mode falls through rather than deciding.

### Test 3 · Traversal · suggestive evidence for the interpreter, and the map check

Runs only when Tests 1–2 have not resolved, and always when an opportunity-side call needs its specific deal.

**The map check, deterministic and first within this test:** does an account-level map exist for this account — account-scoped Contact Map Details or insight rows, opportunity lookup null. Readable in every org with any Altify footprint. **No account map and the summary reads opportunity → opportunity call, done.** An account map exists → the account is a live mapping surface and dual scope is possible, decided by what the summary found.

**The ownership read, suggestive only · corrected in v0.2:** closed-won opportunities over a trailing window suggest the account owns something; CPQ in Salesforce or SAP means the CRM may never prove it. Owns-nothing-visible with no account map supports new business. **Ownership never decides anything alone.**

**The which-opportunity match · method ruled, mechanism OPEN pending the live test.** A global account routinely holds two, three, four open opportunities, so knowing a call is opportunity-side is half the answer. Two reads combine, one deterministic and one inferred, both against the **closed candidate set of this account's open opportunities**:

1. **Participant overlap, deterministic:** the call participants' email addresses against each candidate opportunity's Contact Map Details. The deal whose map holds the people on the call is the deal the call served.
2. **Content match, inferred:** subject, agenda and the Test 2 summary against each candidate's attributes — name, type, stage, close-date talk.

Agreement resolves. The model answers candidate, NONE, or AMBIGUOUS — the People identity-match shape reused — and AMBIGUOUS falls to the flag. **OPEN until the B&V test below is run and the method is seen to work on a real multi-opportunity account.**

### Test 4 · Speakers · tiebreak only

Who is speaking, last, weakest. This is ECI's entire method and the B&V misfile is what it produces when trusted; it enters only as a tiebreak between surviving candidates.

### Test 5 · The flag

Still unresolved → yellow flag asking where the call belongs. **Target rate: one in a hundred, not a workflow.** The evidence has already landed regardless — Sources always land; scope gates adjudication and writes, never arrival.

---

## The dual-scope call · Matthew's opening ruling, deeper design owed

The expansion case is real: managed services on an owned product is an account-level opportunity, and one call legitimately serves both scopes.

**The net-new participant rule · RULED, superseding two earlier positions.** *v0.1 ruled adds-nobody; an establishment-gated alternative was proposed in session and rejected; both are superseded by this, Matthew's ruling, and the reasoning is recorded because it corrects a miss.*

**A net-new external participant on a dual-scope call is added to BOTH maps.** The argument is the system's own law applied honestly: **coverage is a claim, and presence establishes it** — a silent attendee establishes at most coverage, which is not nothing, it is a claim, and a claim that needs a person earns the row. Coverage is scope-symmetric by construction: the occasion happened for the account and for the deal alike. So the coverage claim alone justifies the row in both scopes, and the person lands on both maps with coverage counted and **every other dimension at Unknown, which the maps natively support.**

**Why both rather than the inferred one, stated as the conservatism it is.** A wrong single-map placement by inference costs a team guidance on a person they cannot see — an account-level power hire filed only onto a deal map is invisible to account management forever. A person present on both maps with honest Unknowns costs nothing and lies about nothing. **We reduce the impact of our mistakes rather than the elegance of our placements.**

**Dimensional claims remain establishment-gated per scope, unchanged.** Decision orientation moves on the account row only from account-side words; buyer role moves on the deal row only from deal-side words; coverage moves on both from the occasion itself. Addition is by presence; every dimension beyond coverage is by establishment.

**Every existing guard binds untouched:** the admission gates and cardinality caps (a two-hundred-person webinar already fails the bounded-committee gate and adds nobody), the identity ladder and Identification flag before any row, and the Contact toggle governing whether any of it reaches Altify's own tables — shadow persons where it is off.

For **already-mapped** people the v0.1 mechanics stand: the binary rubrics run over each person **once per scope** — account questions against the account row, opportunity questions against the deal row — and each claim lands in its own scope.

**The two-sided summary · added in v0.2, Matthew's.** On a dual-scope call the scope read produces **two summaries from one pass**: the account-focused summary (maintenance, adoption, consumption of what is owned) and the opportunity-focused summary (the expansion, its future close, its decision talk), each side carrying the parts of the call the ontology assigns to it. Each summary then drives its own scope's reads, so the account rubrics see account content and the deal rubrics see deal content, from one transcript, with nothing read twice.

**The dual trigger, restated with the v0.2 corrections:** an account map exists AND the content reads both sides. Ownership is not in the trigger — an account map plus mixed content is dual even where the CRM cannot prove ownership.

**Named open, not settled here:** whether scope ultimately resolves per claim rather than per call. *(The net-new-person question is closed above in v0.4; the which-opportunity mechanism closed in v0.3 by the B&V test.)*

---

## The account/opportunity content ontology · DRAFT v0 · owed Matthew's correction

Authored by us, shipped as seed, org-overridable. Sided vocabulary, not keywords — the read is what the conversation is about, and the lists below are the meaning of each side, not strings to grep.

**Opportunity-side:** the decision process and decision criteria · a compelling event and its date · budget, funding, approval to spend · evaluation, proof, demos in an evaluation context · proposal, pricing, quote, negotiation · competition and alternatives · contract, legal, procurement, signature · timeline to a decision · who must say yes to a purchase · **renewal conversations** (renewals are opportunities in the methodology — two renewal processes exist) · ROI justification before a purchase.

**Account-side:** adoption and utilization of an owned product · onboarding, training, enablement · business reviews and QBRs · support, escalations, service delivery · managed-services execution · value realization from what is owned · roadmap and relationship cadence · account team orchestration across many deals.

**Authored caveats, in the ontology itself:** late-stage onboarding discussion inside a still-open deal reads account-shaped and is not · expansion seeding ("we could also use this for…") on an account call is the dual-scope trigger, not a scope flip · a seller demoing on an account call does not make it a deal call (the organizer test already said so).

---

## Where this sits

Before the admission gate's per-charter checks, after Locate finds the account. The account is always findable — every call resolves to an account by participants and domains, D360 match rules supplying that join for file-dump orgs on the slow lane, the deterministic email-domain join staying the hot path. **Scope selection is the resolver's job alone; D360 identity resolution answers who, never which scope.**

---

*End v0.1. The ontology draft above is the piece owed correction; the ladder is ruled. Folds into charter design at its next bump.*


---

# PART III · Account-Level Ontology Captures (absorbed)

# AAO Account-Level Ontology Captures

> **The version lives on the stamp line below and nowhere else.**

**v0.2 · 2 August 2026 · The account insight map ontology captured whole: five lane definitions, four admission tests, four example lists, and the person-to-card questions. One incident during the walk, logged in section 4.**

**What this file is.** Verbatim ontological text captured from the production UI for the account-level halves of the People and Problems charters, held here until it folds into the charter design record at its next bump. Provenance for everything below: read from the Altify production org's own UI on 2 August 2026, screenshots taken by Matthew, transcribed byte-exact. Spelling and punctuation untouched.

**Why this file exists.** The account map reopen needs ontological text for the dimensions and card types the account map actually uses. Decision Orientation is the account map's own dimension, filled on roughly 26 percent of account rows against 3 percent of opportunity rows, and it was scoped out of deal work for exactly that reason. It comes back into scope for the account-level People charter.

**What this reopens, named rather than passed over.** The Scoped-Out Dimension ruling said Decision Orientation is humans-only: no `_Answer__c` field, no wizard questions, a judgment about character rather than a report of speech. **The first half stays true and the second half is now qualified by Matthew's direction: the definitions below become the ontology, the same shape as Buyer Role** — no vendor question set exists, so we author the propositions from the definition text, contracts land `Inferred_Pending` until ratified, and establishment still requires words a person actually said, never a personality read. The scope-out survives at deal level. At account level the dimension is in scope for the charter.

---

## 1 · Decision Orientation · the five values, verbatim from the wizard

**Surface:** the Decision Orientation modal on the account relationship map, "Select manually" — there is no guided-question path, only definitions. Each value carries a card description, a "Who are they?" text, and a "What next?" text.

### Financial

**Card:** This person's primary interest is price, cost and economics.

**Who are they?** This person's primary interest is the price, cost, and economics of your solution.

**What next?** When meeting with this person, keep in mind your product must be viable while numbers and negotiations will be their priority.

### Technical

**Card:** This person's primary interest is product functionality and technical capability.

**Who are they?** This person is often analytical and detail-oriented.

Their primary interest is in your product functionality and technical capability.

**What next?** When meeting with this person, keep in mind that product demonstrations, benchmarks, and careful deliberation will be their priority.

### Relationship

**Card:** This person is looking to partner with someone.

**Who are they?** Their primary interest is the people and company that will be servicing their organization.

**What next?** When meeting with this person, keep in mind your product must be viable while overall support, trust, effort, and responsiveness will be their priority.

### Business

**Card:** This person sees the big picture and considers the overall business impact your solution will have on their company's current and future state.

**Who are they?** This person can properly balance the technical, financial, and relationship issues.

Their vision is often strategic and extends beyond their company to include their clients, their competition, and their partner community.

**What next?** When meeting with this person, industry knowledge and articulating business vs. product value will be key.

### Unknown

**Card:** Decision orientation is unknown.

---

## 2 · What the charter takes from this

**The shape is Buyer Role's shape, exactly.** Manual pick, definitions and nothing else, so we author the propositions from the definition text and a human ratifies them. Contracts land `Inferred_Pending`.

**The "Who are they?" text is the proposition source. The "What next?" text is guidance and never enters the reader's input** — it is seller coaching, the same class as the insight admission tests that were ruled guidance rather than gates.

**Establishment stays evidence-bound.** *This person's primary interest is price, cost and economics* is establishable from words the person said — pressing on price, asking for the economics, negotiating terms. It is the speech-report reading of a definition that was written as a character sketch, and the charter takes the speech reading, because behavioural-pattern inference is already forbidden. One FALSE-direction hazard to carry into authoring: these four values are not mutually exclusive by evidence — a person can press on price and ask for benchmarks in one call — so the propositions must be authored as independent assertions with the value derived from which one dominates by count of establishments, or the dimension abstains as AMBIGUOUS. **That derivation rule is not settled here.**

**The four "What next?" texts are enablement content for guidance**, the same join the Solution enablement sections ruling recorded: when guidance speaks about a person with an established orientation, the vendor's own coaching sentence is one read away.

---

## 3 · Account insight map · captured whole

**Provenance:** walked in the production UI on 2 August 2026, Account Plan for Salesforce, Inc., Insights tab, via browser. Lane tooltips read by hover; admission tests and examples read from the *What is an account X?* link on an open card panel. Byte-exact, including one shipped typo. **The Acc Solutions lane exists** — it renders only when the Acc Solutions toggle is on, which is why it is easy to believe it absent.

### 3.1 · The five lane definitions, verbatim

**Acc Goals:** An Account Goal is an end result which an Executive needs to achieve, ideally with a measurable outcome and a specified time frame.

**Acc Pressures:** An Account Pressure is an internal and/or external business issue that significantly impacts achieving the Goal(s), and serves as a driver for Initiative(s).

**Acc Initiatives:** An Account Initiative is a project created to address the Pressure(s) and achieve the Goal(s).

**Acc Obstacles:** An Account Obstacle is an internal operational problem, typically with either organization, process, culture, skills, or technology. Something that is broken, or doesnt exist, and needs to be enabled during the Initiative.

> *"doesnt" ships without an apostrophe. It stays that way here, per the byte-exactness law, and it is another `CONFCLIT`-class specimen: the package contains typos and a sweep that assumes clean text misses things.*

**Acc Solutions:** A set of capabilities, products, or services that help remove the Obstacles - enabling the success of the Initiative, relieving the Pressures, and contributing to achieving the Goals.

> **The causal chain is authored INTO these definitions.** Pressure names Goals and Initiatives; Initiative names Pressures and Goals; Obstacle names the Initiative; Solution names Obstacles, Initiative, Pressures and Goals. The vendor states the edge structure per lane on the account map, in prose, while the schema still holds one typed edge. Rebuttals-grade.

### 3.2 · The admission tests, verbatim, with the opportunity-map deltas

**Account Goal** — You should think about the following to help you determine if this is an account Goal: Is this a business goal which an executive needs to achieve? · What KPI will the executive use to measure results? · Does the result need to be achieved within a specific time frame?

> *Differs from the opportunity test on every question: deal-level asks about the decision maker's personal goal, how the decision maker is measured or compensated, and quantification. Account-level asks business goal, executive, KPI. **Personal versus business is the axis of the AM/OM split for Goal.***

**Account Pressure** — Is this pressure on the business impacting the executive's goals? *(rendered as: How is this pressure on the business impacting the executive's goals?)* · Is the pressure causing an initiative to be prioritized, sponsored, and funded by a key player? · Is the pressure connected to a compelling event?

> *Deal-level asks the pressure categories, sponsorship by the decision maker, and whether it prevents a goal. Account-level drops categories, moves sponsorship to a key player, and adds the compelling event. **The decision-maker role systematically becomes key player at account level.***

**Account Initiative** — Is the initiative in place to address internal or external pressures on the business? · Is a business pressure causing the initiative to be prioritized, sponsored, and funded by a key player? · Will success of the initiative have an impact on the executive's goals?

> *Same three-question shape as deal level with the same two substitutions: key player for decision maker, executive's goals for the decision maker's goal.*

**Account Obstacle** — identical to the opportunity test, all three questions, fixed with your solution, significant enough to establish substantial value, negative consequences if not fixed. **Consistent with the label enumeration: Obstacle has no AM variant.**

**Account Solution** — identical to the opportunity test, all four questions, ending on *Would a key player be able to articulate your unique business value from this Solution?* **Consistent with `SOLUTION_DEF_AM` and `_OM` being identical.** No examples link is offered for Solution.

### 3.3 · The example lists, verbatim

**Goals (7):** Grow revenue by 15% in next 6 quarters · Increase shareholder value by 2% in 3 years · Enter APAC market in next Financial year with new cloud product · Grow from 2k to 3k net new customers by end of this Financial year · Improve profitability margins by 3% · Expand market share by 6% · Become innovation leader

**Pressures (11), category tags theirs:** Eroding market share (competitive) · Difficult mergers or acquisitions · Slow time to market (market) · Decreasing shareholder value (financial) · Cost rising by x percent (financial) · Profits down by x percent (financial) · ROI too slow (financial) · Insufficient revenue - flat or x % up or down (financial) · High turnover (operational) · Customer satisfaction down by 10% · Lack of trust from partners (partner)

> *The parenthetical tags map examples onto the Pressure Type checkbox set, and two examples carry no tag. Authored, imperfect, kept as is.*

**Initiatives (12): identical to the opportunity map's twelve**, already recorded verbatim in charter design. One list serves both maps.

**Obstacles (9):** Managers not equipped to validate and coach · Tools and processes outdated · Low average deal size · Slipping deals · Sales cycles are too long · Can't get relationships at executive level · Not generating enough leads · Too many IT resources to meet reporting requirements · Data is in multiple systems

### 3.4 · Person-to-card on the account map, read from the panels

Goal asks **Who is the Key Player responsible for this Goal?** — where the opportunity map asks for the Decision Maker. Initiative asks **Who is responsible for the success or failure of the Project/Initiative?**, unchanged. Pressure and Obstacle ask **Who is impacted?**, unchanged. Every panel carries **Who told you about this?**, unchanged. **So the informer, impacted-by and responsible-for structure is identical across maps, and only the named role of the responsible party shifts, decision maker at deal level, key player at account level.** The four-questions-two-stored-values finding carries to the account map untouched.

Also observed: the account Solution card carries the full enablement section stack live — Key Messages Discovery and Business Case, Case Studies and Customer Success Stories, Sales Tools, Competitive Positioning, Customer Value Stack — so the enablement join recorded for deal-level solutions exists at account level too. Initiative panels carry Desired outcome free text and the Low/Med/High priority, and an inline Solutions relation. Terminal states match deal level: Achieved, Resolved, Completed, Overcome, Implemented.

---

## 4 · Incident log · one accidental write in production, reverted

During the walk, a click intended for a card's help icon landed on the small circled glyph on an unconfirmed card, **which is the confirmation control** — the unconfirmed-status marker and the confirm button are the same pixel. The card *Pressure: Customer expectations for integrated AI and data privacy compliance* on the Salesforce, Inc. account plan was **confirmed under Matt Weisberg's login and reverted to Unconfirmed within about two minutes.** No field content was changed; the LastModified trail retains both touches.

**Recorded for three reasons.** Honesty: the walk was declared read-only and one click was not. Method: card text and named help links only, never the status glyph — the glyph is a write. And evidence: **a single stray click on a suggestion card produces a Confirmed insight with a named confirmer who never read it.** This is the mechanism behind the five-cards-in-twenty-seconds finding, demonstrated accidentally by the person building the system that exists to fix it. It goes beside that finding in rebuttals.

---

*End v0.2. Everything here folds into charter design at its next bump; this file is the capture surface, not the ruling surface.*


---

# PART IV · The People Harness Brief (absorbed)

# AAO People Harness Brief

> **The version lives on the stamp line below and nowhere else.**

**v0.2 · 2 August 2026 · Both rulings closed. The citation budget is ruled, the stand-in narrows to one job, the related-list guidance is recorded, and the Surface enters as a proposed entity for Object Model. No design blockers remain on the harness.**

## 1 · The rung derivation · RULED

**The mapping table, authored by us because Altify's lives in wizard UI code no runtime can read.** From the nine Support propositions, by label number:

| Rung | Condition |
|---|---|
| **Mentor** | Q2 ∧ Q4 ∧ Q5 established TRUE — prefers ours, sells internally, mentoring us. Two establishments beyond Supporter to enter; one FALSE on Q5 drops to Supporter |
| **Supporter** | Q2 TRUE — told you they prefer your solution |
| **Neutral** | Nothing established in either direction. **A state of not knowing, never a computed balance** |
| **Non-Supporter** | Any of Q6 / Q11 / Q14 TRUE — prefers an alternative, vocal for competition |
| **Enemy** | Q7 ∨ Q16 TRUE — mentoring the competition, or evidence they believe your success hurts them. Positively established, never the far end of a scale |

Q1, the preference gate, opens the reading and places nobody. Political Status derives the same way from its seven once its table is authored; same session, second table, owed.

**When both sides stand at once · RULED by Matthew: recency owns the rung.** The side with the most recent establishment on the **evidence-occurred clock** governs the map value. Neither side dominates by polarity, and nothing averages — Neutral is never the resolution of a conflict.

**The displaced side becomes a contention flag of the opposite polarity, and both types already exist in the glossary.** Recent positive over older negative → the rung reads Supporter and a **negative contention flag** carries the June evidence, quoted: she was helping the competitor's renewal, here are the words. Recent negative over older positive → the darker rung and a **green flag**, positive contention, history better than the present, an opening to repair. The disagreement is never erased and never averaged; it is surfaced with receipts.

**The two contentions run as one motion.** First **live contention**, within this deal, claims on core in evidence-occurred order — thirty days can hold the whole story. Then **historical contention**, the memory plane, current deal excluded, where three deals over three years can say the background is overwhelmingly positive or overwhelmingly adversarial. One comprehensive read of the person; the flag narrative weighs both and characterizes neither beyond what claim rows say.

**Harness scope note, Matthew's:** Data 360 is not stood up, so **the harness exercises the first leg only** — live contention from claims on core, which needs nothing but the ledger the sandbox already has. The second leg is written into the charter and **skipped in the harness**, and skipping it is graceful absence doing its job: no memory plane means flag narratives cite in-deal history only, never an error, never a stub pretending. The one-motion composition gets its own test when the memory plane exists.

**What replay means under this rule:** the rung is derived from standing answers plus the occurred-clock ordering, both of which replay reconstructs, so determinism holds. A backdated note that changes which side is most recent re-derives the rung and the flag, with the sequence spelled out, per the backdated-evidence ruling.

## 2 · The citation budget · RULED, and three rulings that closed with it

**The note ruling.** The 1,024-character map note carries a **current-state composite**: the most recent story of why this person reads the way they do, with a couple of plain citations, overwritten as newer content arrives. Overwriting the note never touches evidence, because the note was always a projection of receipts that live on our rows. This is Option C below, ruled with the overwrite stated explicitly.

**Quotes live on Answer rows only.** Every dimension establishment already writes an Answer per person per dimension carrying the accumulated quotes, unbounded. **No other object ever duplicates quote text** — a second copy is the two-accounts-that-drift defect. The stand-in caches values; it never carries quotes.

**The stand-in narrows to one job.** It is a stand-in for a missing Contact and nothing else: identity, scope (one row per map a person would occupy, account and opportunity separately), graduation state, and the four dimension values as a rebuildable cache. Field shape mirrors Contact Map Details for both scopes. It is not a citation surface and not the roll-up's reference surface. Field table owed, Wave 2.

**The related-list guidance · admin guidance, never package metadata.** Customers who use the UI add a prefiltered related list on Contact Map Details showing our claims for that person on that map — every update that ever happened, with the words and why, reportable. It ships as a sentence in the administration guide, not as metadata on an ALTF object, which the law forbids anyway.

### The Surface · proposed seventeenth entity, recorded for Object Model

Matthew's, named in session, previously called snapshot in places (that name is taken twice in memory). **One row per opportunity answering: here is what you should care about most right now** — the prioritized digest of red flags, yellow flags, contention, guidance nodes, and where to answer — linking to the full assessment, process and map rather than replacing them. Serves the Salesforce UI and headless consumers alike: less querying, more determinism, because what should be seen, when, and why is computed once.

**The tension with the guidance ruling, resolved rather than ignored.** Guidance is derived and holds no state because persistence goes stale between writing and reading. The Surface persists **and never goes stale, because it rebuilds only when something underneath changes** — it can be a year old and correct, since what deserves focus does not change until the underlying does. That places it in the Roll-Up's class: derived, outside the write law, no citations of its own, rebuildable identically from claims and flags, pointing at rows that carry the receipts. **Open, for Object Model:** whether it absorbs the reconciliation destination (the answer-inbox is a write surface, the Surface is a read digest — one parent row could host both), and its relation to the existing Roll-Up Record, which it extends from counts to content. Tiered flag surfacing, named and undesigned since v2.5, most naturally lands here.

### The original options, retained for the record

`ALTF__Note__c` on the map row is 1,024 characters **for the whole row** — four dimensions share one field, and the machine may write citations only into it. Open term 8 since glossary v1.6. The projection writer cannot be built until this is ruled.

**Option A — allocate and truncate.** Each dimension gets ~250 characters: date, speaker, clipped quote. Self-contained on Altify's surface; loses words, and a clipped quote is at the edge of the paraphrase law.

**Option B — pointer only.** Full receipts live on our rows; the note carries one plain sentence per dimension naming date and speaker, no quote. Never truncates a quote; the Altify surface alone is thin.

**Option C — most-recent-only (recommended).** The note carries the full plain-language citation for the **most recent establishment per dimension** — "Supporter — told Renee she prefers Altify, call 24 June" — and every older receipt lives on our rows, one read away. Fits the recency ruling exactly: the note explains the value currently showing, which is the recency winner, and history lives where history lives. Degrades to Option B behavior only when even one citation cannot fit.

All three keep the citation law: dates and speakers in plain words, never a record ID on a human surface.

## 3 · What the harness asserts, once both rulings are closed

Projection writes the rung and note under the derivation above; watermark and per-dimension precedence hold against human edits; the exclusion-list experiment runs inside (project Political, let Altify recalculate, re-read — Is Key Player must move and nothing else); coverage counts from the participant junction; replay reconstructs rung and note exactly.

---

*End v0.1. Section 1 ruled; section 2 is the one open ruling. Folds into charter design at its next bump.*
