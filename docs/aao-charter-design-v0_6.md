# AAO Charter Design

**v0.6 · 2 August 2026 · Shared output envelope RATIFIED, as-deployed schemas recorded verbatim; People output schema lands (People charter CLOSED except one gate parameter); Problems output schema drafted (charter still OPEN on tension a); no-channel-recognition ruling recorded**

**Changed in v0.6.** The shared output envelope is ratified: every charter emits the extraction charter's envelope with a charter-specific body, model proposes and cites, every rule lives in the gates. The reference schemas below are CODE's dump **read out of `aossb2` by anonymous Apex, not transcribed from source** — the enums are closed at runtime from org data, so source transcription would have shown the shape and none of the values. The envelope law preserves the one thing CODE flagged that a naive design would flatten: the model's three-way `status` and the stored four-way abstention enum are different triples, and `not_returned` is derived by the comparator, never emitted — the model cannot report a finding it failed to return. Two schema facts promoted to law: `interpretation` is required with empty string as the good case (optional would lose the under-specified-question signal), and `spans` is required-and-empty rather than absent (which is what makes "exactly one entry per handed unit, never omit one" checkable). Also recorded: the **no-channel-recognition ruling** (§0), the People finding body (closing that charter except one named gate parameter), and the Problems finding body (the charter itself stays open on tension a).

**Changed in v0.5.** Problems charter opened on production evidence (the Tungsten insight-card read: 349 cards across 5 deals, human cards with real fingerprints and zero provenance, Max-generated boilerplate with three contradictory NRR targets coexisting, ~20% confirmed; the won-deal outlier at 44/66 confirmed with zero generated cards). Matthew's rulings recorded: admission for every genuine insight, keep-parent dedup with the count prepended and the reiteration date appended, citations as short plain sentences (date plus speaker, no URLs, no IDs, no hyperlinks), confirmation driven by evidence patterns not gestures, drag-a-card never load-bearing. Quick-links from insights to solution cards and qualifiers parked as guidance enrichment. Two tensions flagged, not settled — they are Matthew's. *(Tension b was ratified 1 Aug; tension a remains open.)*

**Changed in v0.2.** Self-report ruled: sentiment moves one rung conservatively; terminal rungs (Mentor, Enemy) are earned across multiple separate sources and lost the same way; no behavioral-pattern inference for support — stated sentiment and human input only; a human write watermarks the dimension forever (existing precedence law). The Identification flag is RATIFIED as the fifth type, its own thing: not Ratification (which asks permission for a known write), linked to whatever red its resolution would release. New surfacing law from Matthew: a red that is one answer away from clearing is surfaced proactively regardless of tier or value. *(The Source-optional ruling this changelog once marked PENDING was subsequently ratified and built as the evidence-family law; see field tables v0.11+.)*

Companion to the AAO Field Tables (objects) and the four project documents. This file does for the charters what the field tables did for the objects: one section per charter, every emission naming what may produce it and what checks it, rulings marked as rulings. The extraction (assessment/evidence) charter is live at 1.1.0 and its lessons feed this design.

**Changed in v0.1.** People charter opened. The person-row boundary ruled, the identity-resolution ladder ruled, the shadow scope widened, the promotion path settled (closing the object model's named open item), the CRM-write toggle recognized as the existing projection-pattern law, and one new flag type proposed: Identification, the help flag.

---

## 0 · Ruled this session, cross-charter

**The recipe ruling (state-based questions).** A model may write the query, once, at setup; the query is frozen on the contract and executed by Apex every pass. Interpretation by the model, completeness by the database (only a query can prove what is NOT there), determinism by freezing. The question-changed hash sends the model back to re-derive. Guardrails in Apex regardless of what the model wrote: deal-scoped, read-only. **The human surface is sentences, never code:** the admin sees their question, the machine's reading of it in plain words, and Approve / Revise; Revise is typed natural language round-tripped through the same model until the sentence sounds right. Default path requires zero customer-admin action — the classifier proposes from discovery; whoever deploys glances once. Runtime model-reading-of-state (the C route) is the universal floor and always works; frozen queries are the earned upgrade for pure counts.

**No rubric binding on deals** (re-confirmed): a deal always answers the org's current active questions; version is attribution on receipts, never routing.

**No channel recognition · RULED 2 Aug.** Two authorship classes only: MACHINE with a charter stamp, HUMAN otherwise. **No mechanism anywhere — charter, gate, or product — attempts to recognize whether an unstamped write came from a person's judgment or from an agent a person rubber-stamped.** The risk that agent-written content wears a human mark is accepted and named: once the product is in an org, the incentive to paste transcripts into a headless assistant collapses, because the fields are already full and outside agents become retrievers of our receipts rather than writers of their own inferences. Our writes are distinguishable **by citation, not by classification** — they carry who said it, when, in their own words; status-quo writes carry nothing. The existing laws already contain the edge this ruling leaves open: an agent-written card reads as human, so under the annotation law the machine never edits it; matching evidence lands as a Claim with outcome Reinforced beside it, receipts intact, card untouched. No third authorship class exists and none is planned. Rationale recorded with the ruling: over-strictness here makes the product abstain itself into infeasibility, and the abstention budget is spent on evidence quality, never channel forensics.

---

## 0.5 · The shared output envelope · **RATIFIED 2 Aug** · the cross-charter emission law

**The law.** Every charter emits one envelope: a `findings` array with **exactly one entry per unit of work handed to it, in the order handed, never omitting one**, each entry carrying `ref` (which unit), three-way `status`, `proposed_verdict`, `interpretation`, `spans`, and a charter-specific `body`. The model proposes and cites; every rule lives in the gates. Charter-specific vocabulary never changes the envelope; it lives in the body and in runtime-closed enums.

### The reference instance — `AAO_Extract_Evidence` 1.1.0 as deployed

Dumped from the org against the six live mini-rubric contracts (the extraction charter predates the generic `ref`/`body` naming; its `proposition_code` is the `ref` and its body fields sit inline — the writer's parser treats them identically):

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
          "proposition_code": {
            "type": "string",
            "enum": ["AAO_T1", "AAO_T2", "AAO_T3", "AAO_T4", "AAO_T5", "AAO_T6"]
          },
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
                "quote": {
                  "type": "string",
                  "description": "Verbatim, character for character, from the transcript. It is checked byte for byte against the stored artifact and a span that does not match exactly is discarded."
                },
                "speaker": {
                  "type": "string",
                  "enum": ["dana", "sam"],
                  "description": "The roster key of the person whose turn this quote lies in."
                },
                "element": {
                  "type": "string",
                  "enum": ["e1", "e2", "e3"],
                  "description": "Which element of this proposition the quote is offered for."
                }
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
          "proposition_code": {
            "type": "string",
            "enum": ["AAO_T1", "AAO_T2", "AAO_T3", "AAO_T4", "AAO_T5", "AAO_T6"]
          },
          "elements": {
            "type": "array",
            "description": "One entry for every element of this proposition, including the ones no quote was offered for.",
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": ["element", "established", "reason"],
              "properties": {
                "element": { "type": "string", "enum": ["e1", "e2", "e3"] },
                "established": {
                  "type": "boolean",
                  "description": "true only if the quotes given assert this element. false if they merely mention it, discuss it, decline to confirm it, or deny it."
                },
                "reason": {
                  "type": "string",
                  "description": "One sentence. On a false, name what is missing or what the quote actually says instead."
                }
              }
            }
          }
        }
      }
    }
  }
}
```

**Blindness is structural, visible in the schema's absences:** no verdict field, no span field, no transcript reference — `Review(contract, interpretation, spans)` is the entire input signature. This pattern is available to any charter that needs a second reader.

### The status mapping · LAW — the thing a shared envelope must never flatten

The model's three-way `status` and the stored abstention enum are different triples, and the mapping is not identity:

| Model emits `status` | Stored `AAO_Abstention_Reason__c` | Stored `AAO_Outcome__c` |
|---|---|---|
| `addressed` | — | as adjudicated |
| `not_addressed` | `nobody_said` | `Abstained` |
| `abstained` | `model_declined` | `Abstained` |
| *(nothing emitted for that ref)* | `not_returned` | `Not_Returned` |

**The model cannot emit `not_returned` by construction.** It is the record of a unit the reader never reported, so the only thing that can observe it is the comparator noticing a handed unit with no finding against it. Every charter keeps exactly this shape: the charter declares `addressed` / `not_addressed` / `abstained`, and the fourth fact is derived by whatever compares the emission against the rubric it was handed. This is why the picklist carries four values plus `model_missed` retired-valid while the schema carries three.

### Handed units and discovery findings · the generalization

Extraction's units are handed in full (the propositions). People and Problems also **discover** — a new person, a new insight — and a discovered thing cannot appear on a handed list. The law extends rather than bends:

- **Handed units:** exactly one finding each, in order, never omitted. The comparator derives `not_returned` over these and only these.
- **Discovery findings:** appended after the handed set, `ref` = `"NEW"`, marked by the body they carry. A discovery finding structurally cannot be `not_returned` — there is no ground truth of what should have been found.

**The riskiest unvalidated assumption in this design, named:** that ledger completeness survives the discovery half — `not_returned` covers handed units, but "did it even look for the new person / the new insight" has no comparator. What to measure first: Gate-1-style staged-truth runs per charter — transcripts with known planted people and insights, recall measured against the plant. Until those runs exist, discovery recall is stated only as by-construction (admission rules, no caps), never as a number.

### Envelope constants across charters

`proposed_verdict` is meaningful only where the finding proposes a propositional verdict; charters whose findings carry their proposal in the body emit `NONE` and the gates read the body. One parser either way. `interpretation` and `spans` keep extraction's exact semantics everywhere: interpretation required with empty as the good case; spans required-and-empty unless the finding cites, byte-verified, `MAX_SPANS = 5`, each span tagged with what it is offered for (extraction: the element; People: the emission id; Problems: the insight). The writer decomposes findings into Candidates at the one-candidate-per-claim grain; decomposition is writer-side and never the model's job.

---

## 1 · The People charter

Reads evidence; may speak only about human beings on this deal. Three kinds of emission, all Candidates, all through the ordinary gates:

1. **Existence** — this person is on this deal (participant, or referenced as mattering).
2. **Movement** — a cited nudge of one rung on an ordinal dimension (Support, Political, Coverage), from current state, never a teleport.
3. **Assertion** — this person IS something (Decision Maker, Approver), TRUE / FALSE / UNVERIFIED with a span, like any claim.

### The person-row boundary · RULED

**A person earns a row when a claim needs them.** Speakers earn rows because their words create claims. A referenced-but-absent person earns a row only when the mention is load-bearing — a stated holder, a stated gate, a stated role ("my boss John won't take a call until he sees ROI"). A name dropped in chatter creates no claim and therefore no row. This is the cardinality law for people: rows follow evidence-need. A twenty-name war story creates nothing.

### The identity-resolution ladder · RULED

For any person the charter wants to speak about, in order:

1. **Roster** — were they on the call? Deterministic, from the Source.
2. **CRM** — a Contact at this account matching the name. One query.
3. **Memory** — the account's history (prior deals, prior appearances). One keyed lookup.

Outcomes: **exactly one match** → link, machine-attributed, contestable like any claim. **Zero matches** → Shadow Contact. **Multiple matches** → Shadow Contact + Identification flag (below). Disambiguation may use stated context (title, role, relationship to speaker) but a link under ambiguity is never guessed.

### Shadow Contact, widened · RULED

Two origins now: (a) a call participant who is not a Contact (the original definition), and (b) a person referenced as mattering who was never present. Both are honest half-identities on our object. **A Contact without a last name cannot exist** — Salesforce enforces LastName, so partial identities structurally cannot leak into the CRM. Inference may enrich a shadow (proposed title, employer) as clearly-marked machine enrichment, never as establishment.

### The promotion path · RULED (closes Object Model §8's open item)

Shadow → real Contact → map row. Promotion happens when identity completes: a human confirms (via the Identification flag's answer, or by creating the Contact themselves), or evidence completes it. Contact creation into the customer's CRM is governed by the projection-pattern law: **any write to a native object we do not own ships only toggleable per customer.** Toggle off: shadows persist until a human creates the person; the map row lands only when a real Contact exists. Toggle on: creation still requires full identity and passes the ordinary checks.

### The Identification flag · RATIFIED 1 Aug

Fifth flag type, confirmed. Not Ratification (permission for a known write); this is missing knowledge. Carries: the citation (source, turn, the sentence or two of context), the candidates found (zero, or the ambiguous set), what is needed (a last name; which John), and where to answer. **Clearance needs no new rule: the answer re-enters as evidence** — the human's reply comes through the ordinary door, resolves the identity, and the flag clears because its cause is gone. Never dismissible. Surfaces on rollups as blocking the relationship map. Where its answer would clear a red, the two are linked and **the red is surfaced proactively regardless of tier or value** — Matthew's nearly-clearable law: the cheapest red to clear is the one one answer away. First concrete priority rule the surfacing design owns.

**Autonomy-independence, stated as principle:** autonomy levels govern permission; this flag exists because of missing knowledge. It fires identically at level 3.

### Standing laws that bind this charter (from the existing corpus)

Attendance is not evidence of position — a silent attendee establishes at most coverage. Roles are never inferred from job titles. Movement is ±1 from current state with a span; structural inference may exceed one rung only where structure compels it. Absence never establishes. Per-charter admission gates: on a town-hall call this charter abstains while insight proceeds. Cardinality guards on every creation path.

### Self-report and the sentiment ladder · RULED 1 Aug

The way a human would do it. **Clear, sustained sentiment on a call moves a person one rung, conservatively, never more than one per source-event** (the ±1 law already held). **Terminal rungs are sticky:** nobody reaches Mentor or Enemy on one call — entering an extreme requires the same signal across multiple separate sources, and leaving one requires the same. **No behavioral-pattern inference** ("how they behaved as a call-closure piece") to derive support — too much reading between lines; the inputs are stated sentiment on calls and human judgment, nothing else. A human setting the dimension **watermarks it forever**; the machine stops writing that field (existing precedence law, applied).

### Inferred attribution · RULED 1 Aug, gated on measurement

Ratified by Matthew with a condition that is a gate, not a sentiment: best-known mechanisms, and tested hard before anything leans on it. **The gate:** a strip-and-restore harness — take Attributed transcripts, strip the speaker labels, run the attributor on naked text, compare against the stripped truth. Ground truth by construction; every attributed transcript from any org is a free test case forever. Three metrics: side-tier accuracy, identity-tier accuracy, and **anchored-identity precision** (when it says "Dana said this, cue attached," how often is that right) — the number dispositional claims stand on. Thresholds are measured, never guessed; no document carries one until the harness produces it. **Until the bar is met, Inferred sources run at Any_Participant power only.**

Matthew's constraint: orgs with unstructured transcripts are unstructured forever (tech-stack fact), so never-moving-dials on those orgs is unaffordable. Research grounding: LLM post-processing corrects who-said-what from text alone with 45-55% relative error reduction (DiarizationLM, Google 2024; generalized 2025); side-level (buyer/seller) classification from lexical cues is industry-standard and highly reliable; named-identity attribution is recoverable when anchored to cues (self-introductions, vocatives, first-person commitments) against a closed candidate set.

**The design:**
- **Fourth diarization class: `Inferred`**, between Attributed and Unsegmented. Normalization runs an attribution pass on unsegmented sources: model proposes turn boundaries + per-turn speaker at two tiers — side (buyer/seller) and identity (named person). The same pass upgrades Segmented sources (mapping "Speaker 1" to names).
- **Every attribution carries its own cue as a citation** (the "this is Dana" span). Attribution with receipts, contestable like any machine judgment.
- **Closed candidate set:** roster, calendar, CRM, existing map. Assign from the list or say unknown; never invent.
- **Annotation layer, not evidence mutation:** attribution lives beside the frozen bytes like the small-talk boundary — mutable, versioned, re-markable corpus-wide with no re-ingestion.
- **Degradation is automatic via the existing speaker requirement:** Any_Participant propositions flow at full power (nothing given up). Buyer_Side satisfied by side-tier inference. Dispositional claims require identity-tier attribution anchored to a cited cue in the same source; unanchored → UNVERIFIED with receipts, held for accumulation, never lost. Sentiment moves on anchored identity; terminal-rung stickiness protects the extremes.
- The speaker gate records which attribution source it relied on (map / roster / inferred+cue), extending session 18's reason-naming.

**Honest cost:** on text-only stacks, unanchored dispositional claims wait instead of landing, and attribution is machine judgment, weaker than a native roster, contestable, never silently trusted.

### The People output schema · v0.6 · the finding body

**Handed units: one per known person** — roster keys of the artifact, current map members, and existing shadows, the closed set assembled by Apex before the call. One finding per person, in order; the comparator derives `not_returned` per person. **Discovery findings** (`ref: "NEW"`) propose a person the ladder must then resolve.

```json
"body": {
  "type": "object",
  "additionalProperties": false,
  "required": ["emissions"],
  "properties": {
    "emissions": {
      "type": "array",
      "description": "Empty when status is not addressed. Each entry is one proposed claim about this person; the writer decomposes one per Candidate.",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["emission_id", "kind", "dimension_or_assertion", "proposal"],
        "properties": {
          "emission_id":            { "type": "string", "description": "Local id (m1, m2…). Spans at the finding level tag this id in their element field — which quote backs which emission." },
          "kind":                   { "type": "string", "enum": ["existence", "movement", "assertion"] },
          "dimension_or_assertion": { "type": "string", "description": "Runtime-closed enum: the ordinal dimensions (movement) or the assertion codes from the contracts in the pass (assertion). For existence: the stated reason the mention is load-bearing." },
          "proposal":               { "type": "string", "enum": ["TRUE", "FALSE", "UNVERIFIED", "UP_ONE", "DOWN_ONE"], "description": "Assertions propose verdicts. Movement proposes exactly one rung from the current state it was handed — a teleport is unexpressible in this enum, which is the point." }
        }
      }
    }
  }
}
```

A discovery finding's body additionally carries the ladder input, never the ladder's answer: `{"mentioned_as": "<the name as spoken>", "match": "<candidate ref from the closed set, or NONE, or AMBIGUOUS>", "cue_span": "<emission_id of the load-bearing mention>"}` — the model matches against the closed candidate set it was handed and may say `NONE` or `AMBIGUOUS`; linking, shadow creation, and the Identification flag are the gates' work, per the ladder, never the model's.

Envelope `proposed_verdict` is `NONE` on every People finding; proposals live per-emission. Self-report rungs, terminal stickiness, human watermarks, and the ±1 law are all gate-enforced; the schema deliberately cannot express a teleport, and everything else it can express the gates may still refuse.

**People charter: CLOSED**, with one named gate parameter still Matthew's, not blocking build: the counting rule for "multiple separate sources" on terminal rungs — distinct Source rows, or distinct days. The schema is identical either way; the gate reads the parameter.

---

## 2 · The Problems charter (insights + criteria) · **OPEN — core rulings landed 1 Aug; output schema drafted v0.6; tension (a) still Matthew's**

### What the map is for · RULED

**Call prep: who has what problem, why it matters, in their own words.** The production read proved the failure mode this charter exists to prevent: cards generated from public filings read as research notes, carry no provenance, contradict each other, and sit unconfirmed forever. A card earns its place when a person said the thing, and the card can say who and when. The moat, confirmed by the won-deal outlier: citations plus dedup plus a section the seller owns.

### Admission · RULED

**Every genuine insight caught goes on the map.** No materiality threshold, no cap. The filter is genuineness (a person expressed a problem or criterion), never importance — importance is what confirmation counts measure over time. Duplication is handled at write time, not by refusing admission: **the machine must infer duplicated meaning**, because the same problem restated in new words is reinforcement, not a new card.

### Dedup and reinforcement · RULED

**Keep the parent card. Never write a sibling.** When an insight already on the map is expressed again: prepend the count to the card text ("2x", then "3x"), append the reiteration in plain words ("reiterated again on June eighth"). A different person expressing the same insight appends "said by John on June eighth" without restating the insight. **Completely different language is a different insight** — the boundary between reinforcement and novelty is meaning, and the model judges it (this is the inference the admission ruling requires). Underneath the card text, every reinforcement is a Claim with outcome Reinforced, so the count on the card is always reconstructible from receipts.

### Citations on cards · RULED

**Extremely short, plain text, human-readable.** Date plus speaker: "on a demo call June eighth." **No URLs, no record IDs, no hyperlinks** — these are plain text fields in Altify panels and a citation that looks like plumbing poisons the card. The full receipt (span, source, locator) lives on the Claim; the card carries only the sentence a seller would say out loud.

### Confirmation · RULED

Evidence patterns drive it, never gestures:
- Expressed **twice in one call** → confirmed.
- Expressed **once** → on the map, unconfirmed.
- **Re-mentioned in a later call** → note the date, confirm.
- **Different person, same insight** → attribution note appended, confirmation follows the same counting.

**Humans will never drag cards. Never assume a gesture** — ruled by Matthew, consistent with the collapse-data-entry-to-zero premise. A drag, where it happens, is human input and wins like any human input; the design leans on none of it.

### Annotation law · RATIFIED 1 Aug

Prepending "2x" onto a card a human wrote would be a machine edit to a human's words, the exact thing the write law forbids. Ruled: **the machine annotates only machine-authored cards; reinforcement of a human card is recorded as a Claim with outcome Reinforced and surfaces beside the card, never inside its text.** Under the no-channel-recognition ruling (§0) this covers agent-written cards too: they read as human, so they are never edited, and our evidence lands beside them with receipts.

### The Problems output schema · v0.6 · the finding body

**Handed units: the existing cards on this deal's map** — the closed set of card refs assembled by Apex, machine-authored and human-authored alike. Per card, the three statuses do exact work: `addressed` = this evidence bears on the card and the body proposes a reinforcement; `not_addressed` = nothing in this evidence touches it; `abstained` = something touches it but the meaning-match cannot be called — **the meaning-match uncertainty gets the abstention channel instead of a forced guess**, and its rate is measurable per the envelope law. **Discovery findings** (`ref: "NEW"`) propose new insights.

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
    "statement":        { "type": "string", "description": "The insight in the speaker's own words, drawn from the cited spans. The card text is composed by the writer from this plus claim data; the model never writes card furniture." },
    "nearest_existing": { "type": "string", "description": "Runtime-closed enum: the card ref this most resembles and was judged different from, or NONE. The audit surface for the novelty judgment — every new card names the card it refused to be." }
  }
}
```

The speaker comes from the spans (roster keys, runtime-closed); the date comes from the Source's evidence-occurred clock; **neither is ever model-emitted**, so a card can never carry a spoken date that drifts from its receipt. Counts ("2x"), reiteration sentences, attribution notes, and the short plain citation are all composed by the writer from claim rows — reconstructible, deterministic, never prose the model wrote. Envelope `proposed_verdict` is `NONE` on every Problems finding.

**Recorded as NEEDS MEASUREMENT:** the meaning-match is machine judgment with no byte-verifiable gate — `same_meaning_because` and `nearest_existing` make it auditable, not proven. Whether it warrants a second blind reader (a meaning adjudicator given only card text and quote, never the first reader's call) is decided by measuring disagreement on staged truth, not by ruling now. The schema is identical either way.

### Parked

**Quick-links from insight cards to solution cards and qualifiers** — guidance enrichment, valuable, not this wave.

### Open — Matthew's, one at a time

**(a) Machine-confirm versus Altify's Confirmed semantics.** In ALTF panels today, Confirmed has meant a named human vouched. If projection writes machine-confirmed cards into those panels, the word silently changes meaning for every existing user, and a human's Confirmed and ours become indistinguishable. Options: project confirmation with a visible machine watermark; hold machine confirmation on our side and project only the card; or let projection stay off until this is ruled. Costs differ; the ruling is yours. *(Not urgent; blocks projection of confirmations only, nothing in the build path.)*

---

## 3 · The Politics charter (links, influence, conflict) — not yet opened

*One charter at a time, same as the objects: present, close, move on.*
