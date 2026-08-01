# AAO Charter Design

**v1.3 · 2 August 2026 · The People charter CLOSED. Ontology owns every rung. The person-to-card relation recovered: four questions, two stored values**

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

#### Support · verbatim · five propositions

1. Has this person expressed a preference for a specific solution?
2. Has this person told you they prefer your solution over all other alternatives?
3. Is this person willing to provide you helpful information when asked?
4. Does this person believe your solution is critical to their success and do they sell internally for you in your absence?
5. Is this person mentoring you by providing guidance, political insight, or competitive information?

**The tree.** Q1 No ends at Neutral. Q1 Yes goes to Q2. Q2 Yes goes to Q3; Q3 No ends at **Unknown**; Q3 Yes goes to Q4; Q4 No ends at Supporter; Q4 Yes goes to Q5; Q5 Yes gives **Mentor**, Q5 No gives **Supporter**. Q2 No goes to a second branch: *has this person told you they prefer an alternate solution, including an internal solution or do nothing at all* — No ends at Neutral, Yes goes to *is this person mentoring your competition and working to help them win* (Yes / No / **Not sure**), Yes giving **Enemy** and No giving **Non-Supporter**.

**Q4 is compound** (believes it is critical, and sells internally) and **Q5 is a three-way or** (guidance, political insight, competitive information), which is exactly the element structure Evidence Contracts already carry. **Q2 and Q4's "told you" fixes a speaker requirement**: the person themselves, to the seller.

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

#### Political Status · verbatim · not binary

1. Does this person approve and sponsor initiatives, or do they execute projects after they are approved? · **Approves/Sponsors · Executes · Not sure**
2. Do others seek this person out for advice and direction? · **Yes · No · Not sure**
3. Does this person control the outcomes or are they called on to make it happen? · **Controls · Implements · Not sure**

Values, verbatim: **Inner Circle** "Decides what will be prioritized and controls the outcomes." **Political Structure** "Trusted by the Inner Circle to make things happen." **Outside Political Structure** "Has little to no political power, but is called upon by key players to provide evaluations and information." The Inner Circle outcome panel adds: "This person is a key player. They initiate or sponsor initiatives, and define how success is measured… The customer buying team may have 1 to 3 people in the Inner Circle."

**Two things worth naming.** The options are semantic rather than yes-or-no, so the shared envelope's proposal enum for this dimension is runtime-closed from the wizard's options rather than from a verdict picklist. And **Not sure is a first-class answer in Altify's own methodology**, which is abstention built into the vendor's design and an argument we can use directly.

**Owed:** only the Approves/Sponsors · Yes · Controls path was walked, which terminates at Inner Circle. The mapping of the remaining combinations to Political Structure and Outside Political Structure is **not yet read and is not guessed here.** One more pass through the wizard closes it.

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

**Terminal states differ per type** and are not a shared lifecycle: Goal runs Unconfirmed → Confirmed → **Achieved**, Pressure → **Resolved**, Initiative → **Completed**, Obstacle → **Overcome**.

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

### Parked

Quick-links from insight cards to solution cards and qualifiers: guidance enrichment, not this wave.

### Open — Matthew's

**(a) Machine-confirm versus Altify's Confirmed semantics.** In ALTF panels today, Confirmed has meant a named human vouched. If projection writes machine-confirmed cards into those panels, the word silently changes meaning for every existing user. Options: project confirmation with a visible machine watermark; hold machine confirmation on our side and project only the card; or leave projection off until this is ruled. Not urgent; blocks projection of confirmations only.

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
