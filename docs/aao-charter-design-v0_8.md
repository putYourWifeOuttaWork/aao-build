# AAO Charter Design

**v0.8 · 2 August 2026 · The sentiment counter ruled (clamped integer, minus three to plus three); human override ruled absolute; backdated evidence ruled; no decay mechanism; neutral ruled as disposition, never a quota**

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

### Owed by the next version

**Where People Evidence Contracts come from.** `AAO_Candidate__c.AAO_Evidence_Contract__c` is required, so every People emission needs a contract, and dimensions are not in Altify's rubric tables the way propositions are. Discovery has no answer for them yet. One org fact settles part of it and CODE is asked for it: whether single-element contracts carry `AAO_Element_Count__c` of one, or whether zero appears anywhere.

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
