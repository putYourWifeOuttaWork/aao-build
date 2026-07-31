# AAO Field Tables

**v0.8 · 31 July 2026 · Source, Evidence Contract, Candidate, Answer, Claim, Claim Basis CLOSED · Flag outstanding**

Companion to: Architecture, Object Model, Glossary, Data Flow. Every heading stamped `fields v0.8`. This file is the packet Claude Code builds from: one section per object, each field naming its type, constraints, the process that writes it and the process that reads it. A field that cannot name both is invented and does not ship (standing rule).

**Changed in v0.10 — three ratifications from the build, 31 July.** **`AAO_Synthetic__c` is ratified as a permanent field on every AAO object.** Checkbox, default false, written only by seeders. Two readers: purge, which requires the purge context AND the marker so a real row cannot die even with the flag set; and **every aggregating, streaming or projecting reader, as an exclusion** — synthetic rows never stream to memory, never project, and never count in a roll-up. That makes it the third universal filter, after publication state and current-deal exclusion, and it is recorded here so the cost is stated rather than discovered. **The internal-person resolution rule is ratified as CODE built it:** the internal participant who actually spoke in the cited spans, falling back to an internal participant present on the call, **never the deal owner** — ownership is an assignment, not presence, and key four exists to record who was in the room. **The Claim Basis parent contradiction is already resolved** — the corrected flags document rules that Flag carries its own snapshot fields because a contention flag's basis is a computed aggregate with no core row for a typed lookup to hold; master-detail from Claim Basis to Claim stands. The contradiction only appears live to a reader holding the stale flags copy.

**Changed in v0.9 — one correction from the org, 31 July.** **The platform refuses `caseSensitive` on a text field that is not also unique**, which invalidated the marking on five fields here. Corrected below, and the reason it was wrong is worth more than the fix: case sensitivity was only ever protecting the **uniqueness guarantee**, so applying it to non-unique hash fields was cargo-culted from the two keys that genuinely need it. The two real keys keep platform case sensitivity. Everywhere else the producer enforces lowercase hex, which is the correct place for it — a frozen composer that emits one form is a stronger guarantee than a storage flag.

**Changed in v0.8. The largest change in this file so far, and it is a correction rather than an addition.** The word *Claim* was attached to the upserted current-state row, which put the sentence *a claim is overwritten* into our own design. That sentence is wrong in plain English and Matthew rejected it on sight. **The current-state row is now the Answer. A Claim is one establishment from one piece of evidence and is never edited.** With the rename, the reason Journal Event existed as a separate object disappears — it existed only because Claim was busy being the mirror — so **Journal Event collapses into Claim**, which carries the four keys, the two clocks and the before-and-after values it was holding. **No claim-to-claim parentage:** claims relate by sharing an answer, which is a subquery. **A new junction, Claim Basis, carries the state rows a claim rests on, with their values frozen at claim time**, which was already required by a standing rule that never named a home. Entity count moves from fourteen to fifteen.

**Target org:** `altify--aossb2`. **Prefix:** `AAO_` on every API name; ALTF-namespace 2GP is the recorded endgame.

**Owed to the project documents.** This version invalidates vocabulary and entity statements in Architecture, Glossary, Object Model and Data Flow. A correction record goes to the project alongside this file; full version bumps follow once Flag closes, so they are done once rather than twice.

---

## Findings owed to other documents · fields v0.8

**A seventh memory table for the decision log.** The six specified are the journal (now Claim), fulfilment, surfacing, roll-up, and the two snapshots. The decision log is designated for the library and has no table among them. Complete candidate logging was ruled conditional on retrospectives reading it. Engagement category, evidence-occurred clock. **A stream's category and clock lock at creation**, so this is decided rather than discovered.

**Reinforcement receipts: two live documents disagree and the replay test runs through it.** The same evidence arriving twice produces nothing, because the watermark stops it being read again. **New** evidence confirming something already standing does write a claim, and it must, because guidance orders a person's criteria by what they have pressed most recently and most often, which is a count of exactly these rows.

**Pre-production audit, named by Matthew.** Whether objects at this field count are analysable in practice. For scale: Altify's own opportunity object carries a hundred and nine fields and their map row thirty-eight.

**Case sensitivity, corrected from the org 31 July.** `CaseSensitive can only be set for fields with unique also set` — verbatim from the compiler. **Affected and now false:** `AAO_SHA256__c`, `AAO_Artifact_SHA256__c`, `AAO_Content_Hash__c`, `AAO_Question_Record_Id__c`, `AAO_Question_Fingerprint__c`. **Unaffected and keeping it:** `AAO_Scope_Key__c`, `AAO_Contract_Key__c`, `AAO_Answer_Key__c`, all three unique. The intent survives in Apex: the key composers reject anything that is not lowercase hex rather than folding case silently. Each affected field carries the reason in its org description so nobody re-adds the flag.

**Five Apex reserved-word collisions, recorded because they are permanent.** Extended 1 Aug 2026 per ruling 48. The count was previously two; this is the full list the build has actually hit, and they come in two kinds. The second kind is the dangerous one.

**Refused loudly, with the identifier named.** `commit`, because our vocabulary uses *commit* as a pipeline stage — fine as data on a picklist, never as an identifier. `any`, which is on nobody's list and took down the first deploy of the pipeline view controller. `merge`, which is a DML statement, so `AAO_EvidenceFamily.merge(String, String)` failed to parse at the declaration itself and was renamed `combine`.

**Resolved silently, with the error surfacing somewhere else entirely.** A parameter named `json` shadows the `JSON` system class, and a local named `system` shadows `System`. Both compile without complaint, because Apex is case-insensitive, and the failure appears later as a missing method on `String`. These are the two worth teaching, precisely because the compiler will not teach them.

Every one is a naming hazard specific to this domain: the words that collide are the words an evidence ledger most wants to use.

**Name collision to watch.** Altify's assessment answer field is `ALTF__Answer__c`. Ours is `AAO_Answer__c` and they are distinct records, but the word is overloaded in conversation. When speaking to Toby or Bill, say *our answer row* or *the assessment answer*, never bare *answer*.

---

## 1 · AAO_Source__c · fields v0.8 · **CLOSED**

Evidence normalised to one shape, versioned, immutable, resident on core regardless of which plane it arrived on. What every span is byte-verified against.

| Field | Type | Constraints | Written by | Read by |
|---|---|---|---|---|
| `AAO_Opportunity__c` | Lookup(Opportunity) | Required | Locate; ambiguity = skip and dead-letter | Deal scoping; the scope-key composer |
| `AAO_Account__c` | Lookup(Account) | Required | Locate, from the opportunity | Account-grain retrieval and later account orchestration |
| `AAO_Normalized_Text__c` | Long Text (131,072) | Immutable | Normalisation, once, frozen normal form | Span verification; extraction; library copy |
| `AAO_Diarization__c` | Picklist: `Attributed`/`Segmented`/`Unsegmented` | Restricted, required | Normalisation | Which contiguity rule binds; speaker-requirement reach; admission gate |
| `AAO_Speaker_Roster__c` | Long Text, JSON | Nullable | Normalisation | Admission gate; who-said-it; rank check; shadow-person detection |
| `AAO_Substantive_Offset__c` | Number(9,0) | Nullable, **mutable** | Small-talk boundary detector | Charter input assembly. Never read by span verification |
| `AAO_Boundary_Basis__c` | Text(40) | Nullable | Boundary detector | The labelling exercise; audit |
| `AAO_Duration_Seconds__c` | Number(9,0) | Nullable | Collector | The ninety-minute ceiling |
| `AAO_SHA256__c` / `AAO_Artifact_SHA256__c` | Text(64) | **Not case-sensitive — the platform refuses it on non-unique fields.** Lowercase hex enforced by the composer | Normalisation | Integrity; idempotent re-delivery; the scope-key composer |
| `AAO_Scope_Key__c` | Text(101) | **Unique, External ID** | Trigger, frozen composer: `ScopeId · ArtifactSHA · PartIndex` | Dedup target. `DUPLICATE_VALUE` is a merge path |
| `AAO_Part_Index__c` / `AAO_Part_Count__c` | Number(3,0) | Required, default 1 | Normalisation | Locator resolution; input order; completeness |
| `AAO_Source_Ref__c` | Text(255) | — | Collector | Provenance; re-normalisation lineage |
| `AAO_Origin__c` | Picklist: `ECI`/`ingest`/`note` | Restricted | Collector | Channel routing; gate variant |
| `AAO_Evidence_Occurred__c` | Datetime | Immutable | Normalisation | The occurred clock. The accumulation test asserts on it |
| `AAO_Normalizer_Version__c` | Text(20) | — | Normalisation | Determinism audit |
| `AAO_Trim_Manifest__c` | Long Text, JSON | Nullable | Normalisation | Audit. A removal that cannot name its rule is a defect |

**Rulings.** Ninety-minute ceiling at the gate. Deterministic format trim only. Small talk marked, never cut, boundary mutable so a better detector re-marks with no re-ingestion. Summarised text is never a Source. Splicing detection is a named residual on `Unsegmented`. Uniqueness is deal plus fingerprint.

---

## 2 · AAO_Evidence_Contract__c · fields v0.8 · **CLOSED**

Per proposition, per version of its text. Rule data, derived at runtime from the customer's methodology, versioned, never deleted.

| Field | Type | Constraints | Written by | Read by |
|---|---|---|---|---|
| `AAO_Question_Record_Id__c` | Text(18) | Required | Rubric discovery | Identity |
| `AAO_Content_Hash__c` | Text(64) | Required | Rubric discovery: proposition plus guidance | Identity; the only detector of an in-place edit |
| `AAO_Contract_Key__c` | Text(83) | Unique, External ID | Trigger, frozen composer | Upsert target for discovery |
| `AAO_Proposition_Code__c` | Text(40) | — | Rubric discovery | Display only. **Never identity** |
| `AAO_Proposition_Short__c` | Text(255) | Immutable | Rubric discovery | Display. Never read as the proposition |
| `AAO_Proposition_Text__c` | Long Text | Immutable | Rubric discovery, verbatim | The charter's question. Never rewritten |
| `AAO_Guidance_Text__c` | Long Text | Immutable | Rubric discovery, verbatim Help and Tip | **The primary source of the parts** |
| `AAO_Elements__c` | Long Text, JSON | — | Read from guidance where named; model-proposed where not | Coverage adjudication; handed to the blind reader |
| `AAO_Elements_Basis__c` | Picklist: `Authored`/`Inferred_Ratified`/`Inferred_Pending` | Restricted, required | Element resolution | Whether a human is owed a look; the under-specified-question list |
| `AAO_Element_Count__c` | Number(2,0) | Required | Element resolution | Coverage arithmetic; cardinality bound |
| `AAO_Per_Person_Source__c` | Text(80) | Nullable | Element resolution | Where the set of people comes from. Resolves in Apex, making the count deterministic and the empty-set guard free |
| `AAO_Route__c` | Picklist: `P`/`C`/`E` | Restricted, required | Computability classifier, ratified | Routing only. A question computable in principle whose field the org leaves blank routes to guidance, never to counting blanks as absences |
| `AAO_Speaker_Requirement__c` | Picklist: `Seller`/`Any_Participant`/`Buyer_Side`/`Decision_Maker_Or_Influencer` | Restricted, required | Element resolution | **Who must be the source of the span carrying the assertion.** Not who may appear in the set |
| `AAO_Required_Map_Role__c` | Text(255) | Nullable | Role charter, ratified | Which person must *exist on the map*. Seeds the ghost |
| `AAO_Solicit__c` / `AAO_Gating__c` | Checkbox | — | Classifier / discovery | Asks rather than waits; day-one red |
| `AAO_Decay_Class__c` | Picklist: `Event`/`Standing`/`Decaying` | Restricted, required | Defaulted by source, overridable | Whether an establishment can lose standing. Cached, not derived |
| `AAO_Escalation_Threshold__c` | Percent | Nullable | Ratification | When a standing red surfaces and ages. Null inherits |
| `AAO_Requires_Ratification__c` | Checkbox | — | Ratification | Per-proposition override |
| `AAO_Prerequisites__c` | Long Text, JSON | — | Element resolution | Live-set filtering. Promotable to a junction |
| `AAO_Rubric_Version__c` | Text(20) | Required | Rubric discovery | Stamped onto every claim under this contract |
| `AAO_Contract_State__c` | Picklist: `Derived`/`Awaiting_Ratification`/`Ratified`/`Superseded` | Restricted, required | Discovery and ratification | Which contract extraction consults. Superseded stays readable |
| `AAO_Superseded_By__c` | Lookup(self) | Nullable | Discovery, on hash change | Lineage. Never deleted |
| `AAO_Ratified_By__c` / `AAO_Ratified_On__c` | Lookup(User) / Datetime | Nullable | Ratification surface | Audit |

**Rulings.** Parts come from authored text where it names them, inferred only where it does not. Counting people needs a pointer, not a structure. The number of parts is never unknown. Compound questions discouraged in authoring, bounded in decomposition. Seller speech is admissible in a citation set; one assent cannot carry three parts.

---

## 3 · AAO_Candidate__c · fields v0.8 · **CLOSED**

**The proposal, and everything that happened to it.** One row per proposition considered per pass. Rejected and abstained rows are the decision log.

| Field | Type | Constraints | Written by | Read by |
|---|---|---|---|---|
| `AAO_Evidence_Contract__c` | Lookup | Required | Extraction | Which question |
| `AAO_Source__c` | Lookup | **Nullable since 47** | Extraction | Which evidence, when the evidence is an artifact. Null on a state-derived row, and the evidence-family law requires it to be null there |
| `AAO_Basis__c` | Picklist: `State`/`Transcript`/`Both` | Restricted, nullable | Whoever proposes | **Ruled 47.** Which family of evidence this rests on, and therefore what shape it must have. Not required at field level so pre-47 rows stay updatable; enforced on insert by the trigger, which can say why |
| `AAO_Opportunity__c` / `AAO_Account__c` | Lookup | Required | Extraction | Scoping; the per-opportunity lease |
| `AAO_Subject_Type__c` | Picklist | Restricted, required | Extraction | Mirrors Answer's discriminator |
| `AAO_Subject_Contact__c`, `_Shadow_Person__c`, `_Insight_Card__c`, `_Qualifier__c`, `_Decision_Criterion__c` | Lookup | One populated | Extraction | The subject. Same typed shape as Answer, which forces one row per person on a per-person question |
| `AAO_Proposed_Verdict__c` | Picklist: `TRUE`/`FALSE`/`UNVERIFIED` | Nullable | Extraction | What was proposed. Null on abstention |
| `AAO_Spans__c` | Long Text, JSON | Nullable | Extraction: up to five spans with source ref, part index, locator | Span verification; the blind reader |
| `AAO_Element_Coverage__c` | Long Text, JSON | Nullable | The blind reader, element by element | Routes the outcome: full writes the verdict, partial writes `UNVERIFIED` with the spans that exist, none writes nothing |
| `AAO_Interpretation__c` | Long Text | **Nullable, null is the good case** | Extraction, where the question needed reading beyond its own text | Handed to the blind reader; carried to Claim. Populated rows counted per question are the under-specified-question list |
| `AAO_Stage__c` | Picklist: `Proposed`/`Span_Checked`/`Adjudicated`/`Reconciled`/`Committed` | Restricted, required | Each step | **How far it got.** Resume-from-survivors reads this |
| `AAO_Outcome__c` | Picklist: `Pending`/`Span_Failed`/`Upheld`/`Partial`/`Rejected`/`Downgraded_Speaker_Rank`/`Reinforced`/`Contention_Raised`/`Superseded_By_Human`/`Abstained` | Restricted, required | Whichever step ended it | **What happened there** |
| `AAO_Abstention_Reason__c` | Picklist: `model_missed`/`nobody_said` | Nullable | Extraction | The abstention-rate detector |
| `AAO_Charter__c` / `AAO_Charter_Version__c` | Text | Required | Extraction | The grain abstention analysis groups by |
| `AAO_Run__c` | Lookup | Required | Dispatcher | Bookmarks, retries, dead letters, the lease |
| `AAO_Claim__c` | Lookup | Nullable | Commit | Which claim this became. Null on every row that did not write |
| `AAO_Publication_State__c` | Picklist: `Live`/`Held`/`Declined` | Restricted | Ratification | Held candidates stay here and never queue on the mirror. **A decline lives here and nowhere else**, since a decline establishes nothing and writes no claim |

**Rulings.** The ledger is complete: every proposition considered writes a row, so the abstention rate is a direct query and *did it even look* is answerable. One candidate per claim, so a per-person question on a nine-person deal writes nine rows. Build the heavier shape, measure in testing, lighten the write path later — too many rows is storage, too few loses per-row verification state that cannot be reconstructed.

---

## 4 · AAO_Answer__c · fields v0.8 · **CLOSED** — *was called Claim*

**The current-state row. Upserted. One per question per subject.** What a seller reads, what projection projects, and what human precedence is enforced against. It carries the accumulated quotes, so reconciliation months later reads a hot row with the words on it rather than replaying history.

| Field | Type | Constraints | Written by | Read by |
|---|---|---|---|---|
| `AAO_Evidence_Contract__c` | Lookup | Required | Commit | Which question this answers |
| `AAO_Opportunity__c` / `AAO_Account__c` | Lookup | Required | Commit | Scoping; roll-up; the live set |
| `AAO_Subject_Type__c` | Picklist: `Opportunity`/`Contact`/`Shadow_Person`/`Insight_Card`/`Qualifier`/`Decision_Criterion` | Restricted, required | Commit | **The discriminator.** `Opportunity` added 31 July from the build: an assessment answer's natural key is opportunity plus proposition, with no person and no card, and the five typed lookups gave it no composable subject at all. **No new lookup** — the opportunity lookup already on the row is what the composer reads for this value. Without it, opportunity-plus-proposition and opportunity-plus-contact-plus-dimension rows are indistinguishable to any query that does not already know what it is hunting |
| `AAO_Subject_Contact__c`, `_Shadow_Person__c`, `_Insight_Card__c`, `_Qualifier__c`, `_Decision_Criterion__c` | Lookup | One populated | Commit | Traversal, reporting by related record, lookup filters. **Null-and-flag on subject delete** |
| `AAO_Answer_Key__c` | Text(120) | **Unique, External ID, case-sensitive** | Trigger, frozen composer over subject type plus the populated lookup plus the contract | **The failure detector for the read-before-write that human precedence depends on.** `DUPLICATE_VALUE` is a merge path, never an error path: catch, re-read the colliding row, apply precedence, proceed |
| `AAO_Verdict__c` | Picklist: `TRUE`/`FALSE`/`UNVERIFIED` | Restricted, required | Commit | The answer. Abstention and not-addressed never reach here |
| `AAO_Basis__c` | Picklist: `State`/`Transcript`/`Both` | Restricted, nullable | Commit | **Ratified 48.** THE UNION OF THE CLAIMS THAT BUILT IT: established from a call and later reinforced by a state read reads `Both`, which is what `Both` has always meant. Decides what counts as this answer's citation — spans for `Transcript`, the claim's cited rows for `State`. Pre-48 rows are READ as `Transcript`, never backfilled |
| `AAO_Spans__c` | Long Text, JSON | — | Commit, **accumulating across claims** | The current evidence set. This is what lets call two say there was already partial evidence and now it is sufficient |
| `AAO_Element_Coverage__c` | Long Text, JSON | — | Commit | What is covered and what is missing. **The flag over partial coverage reads this** to say here is what stands and here is the piece still needed |
| `AAO_Interpretation__c` | Long Text | Nullable | Commit | The interpretation behind the current verdict |
| `AAO_Established_By__c` | Picklist: `MACHINE`/`HUMAN` | Restricted, required | Commit | **A write is MACHINE only if it carries a charter stamp. Everything else is HUMAN**, because misreading a machine write as human costs one overwrite and misreading a human write as machine destroys a person's judgment |
| `AAO_Charter_Version__c` / `AAO_Rubric_Version__c` | Text(20) | — | Commit | Which rules produced this. Rubric version is an attribute, never identity |
| `AAO_Question_Fingerprint__c` | Text(64) | Nullable | Commit | Compared on read. A mismatch reads as the answer not counting, which is the failure direction we accept |
| `AAO_Publication_State__c` | Picklist: `Live`/`Held`/`Declined` | Restricted, required | Ratification | **Held is live for nothing** — not projection, not condition satisfaction, not a predicate's count, not contention's aggregate, not the roll-up, not guidance. One filter every reader applies |
| `AAO_Projected_Value__c` | Text(255) | Nullable | Projection, outbound | Half of the compare-and-swap watermark |
| `AAO_Projected_Modstamp__c` | Datetime | Nullable | Projection, outbound, **captured at the instant of our write** | The other half. A timestamp that moved while the value did not is a human confirmation, and it is the only evidence of one that exists. **Cannot be reconstructed later** |
| `AAO_Last_Claim__c` | Lookup(Claim) | Nullable | Commit | The claim that most recently moved this. The frozen row beside the live one |
| `AAO_Evidence_Occurred__c` | Datetime | — | Commit | When the establishing evidence happened, not when we processed it |

**Trigger law (`AAO_AnswerTrigger`).** Compose the key (frozen, versioned, single writer, case-sensitive, never a formula field because a formula recomputes on read and would silently change meaning under a schema change). Enforce the write law: an establishment requires a citation, spans are byte-verified, human-authored values are never overwritten or demoted, emitted values fall inside the discovered vocabulary. Catch `DUPLICATE_VALUE` as merge, per `SaveResult` under partial-success DML.

---

## 5 · AAO_Claim__c · fields v0.8 · **CLOSED** — *absorbs Journal Event*

**One establishment, from one piece of evidence, never edited.** This is the receipt. Claim one says the answer went to `UNVERIFIED` on this evidence and stays saying that forever; claim two says it went to `TRUE`. Replaying claims in evidence-occurred order must reconstruct every answer exactly — that is the exit test.

**One claim rests on one Source, which dissolves a question this file carried for three versions.** Under the old shape a single row accumulated quotes from several transcripts and a singular source lookup had to arbitrarily pick one. One claim per evidence item makes the lookup exactly right with nothing to choose.

| Field | Type | Constraints | Written by | Read by |
|---|---|---|---|---|
| `AAO_Answer__c` | Lookup | Required | Commit | Which answer this moved. Claims relate to each other by sharing this. **No claim-to-claim parentage** |
| `AAO_Candidate__c` | Lookup | Required | Commit | The proposal this came from, with its stage, outcome and reasons |
| `AAO_Source__c` | Lookup | **Nullable since 47** | Commit | The evidence, when the evidence is an artifact. Singular and correct. Null on a state claim, which cites rows instead |
| `AAO_Evidence_Contract__c` | Lookup | Required | Commit | Which question, at which version |
| `AAO_Opportunity__c` | Lookup | Required | Commit | **Key one of four** |
| `AAO_Account__c` | Lookup | Required | Commit | **Key two.** Opens every account-grain question |
| `AAO_External_Person__c` | Lookup(Contact) | Nullable | Commit | **Key three** |
| `AAO_Internal_Person__c` | Lookup(User) | Nullable | Commit, resolved from participants rather than assumed from the deal owner | **Key four.** Opens the seller-to-buyer grain, which is where relationship standing lives. **A grain not recorded cannot be declared later without reprocessing the corpus, which means re-paying every model call** |
| `AAO_Subject_Type__c` + typed subject lookups | Picklist + Lookup | Same form as Answer | Commit | Subject identity, composed by the same frozen function. **Without it replay cannot reconstruct the mirror** |
| `AAO_Verdict_Before__c` | Picklist | Nullable | Commit | What the answer was. Null where this claim created it |
| `AAO_Verdict_After__c` | Picklist: `TRUE`/`FALSE`/`UNVERIFIED` | Required | Commit | What it became. **The two together are the change the journal always carried** |
| `AAO_Spans__c` | Long Text, JSON | Nullable | Commit | This claim's quotes, each with source ref, part index and locator. Frozen |
| `AAO_Element_Coverage__c` | Long Text, JSON | Nullable | Commit | What this claim covered, as adjudicated. Frozen |
| `AAO_Interpretation__c` | Long Text | Nullable | Commit | The interpretation used, frozen at the moment it was used |
| `AAO_Basis__c` | Picklist: `State`/`Transcript`/`Both` | Restricted, required | Commit | Where the support came from. **A basis of state alone still requires the row be named and its value quoted** — see Claim Basis |
| `AAO_Outcome__c` | Picklist: `Established`/`Reinforced`/`Downgraded`/`Demoted` | Restricted, required | Commit | Reinforcement writes a claim without moving the answer, which is what makes *how often has this been pressed* countable |
| `AAO_Actor__c` | Picklist: `MACHINE`/`HUMAN` | Restricted, required | Commit | Machine only with a charter stamp |
| `AAO_Charter__c` / `AAO_Charter_Version__c` / `AAO_Rubric_Version__c` | Text | — | Commit | Which rules produced it |
| `AAO_Evidence_Occurred__c` | Datetime | Required, immutable | Commit, from the Source | **Clock one.** Replay orders on this. Without it a backfilled 2024 transcript collapses onto today and the trend is worthless |
| `AAO_Recorded_At__c` | Datetime | Required, immutable | Commit | **Clock two.** When we processed it |
| `AAO_Retrospective__c` | Checkbox | — | Commit | Marks a record constructed from history, so nothing downstream reads a map built last Tuesday as evidence of what a seller knew in 2024 |

**Trigger law (`AAO_ClaimTrigger`).** Insert only. Block every update and every delete. Claims leave by retirement, confirm-then-purge, library acknowledgement first.

**This is what streams to memory.** Engagement category, evidence-occurred clock, both locked at stream creation.

---

## 6 · AAO_Claim_Basis__c · fields v0.8 · **CLOSED** — the junction

**What a claim rests on, beyond its own quotes.** A claim citing state must name the row and quote its value, because the row will change underneath it. That rule existed and had no home. This is the home.

**Half frozen, half live, deliberately.** The snapshot sits in fields here and never changes. The live record comes through the lookup. One subquery returns both, which is how you see that a qualifier read *unknown* when the claim was written and reads *known* today.

| Field | Type | Constraints | Written by | Read by |
|---|---|---|---|---|
| `AAO_Claim__c` | Master-Detail(Claim) | Required | Commit | The claim this supports. Cascades with it at retirement |
| `AAO_Cited_Type__c` | Picklist: `Map_Row`/`Insight_Card`/`Decision_Criterion`/`Answer`/`Qualifier_Status`/`Shadow_Person` | Restricted, required | Commit | Which lookup is populated; how to read the snapshot |
| `AAO_Cited_Map_Row__c`, `_Insight_Card__c`, `_Decision_Criterion__c`, `_Answer__c`, `_Qualifier_Status__c`, `_Shadow_Person__c` | Lookup | One populated | Commit | **The live record.** Traversal, and the current-state half of the subquery |
| `AAO_Snapshot__c` | Long Text, JSON | **Immutable** | Commit: the cited fields and their values at claim time | **The frozen half.** What the row actually said when the claim was written |
| `AAO_Snapshot_Taken__c` | Datetime | Immutable | Commit | When the freeze happened |
| `AAO_Covers_Element__c` | Text(40) | Nullable | Commit, from the coverage adjudication | Which part of the proposition this row covers. **This is what makes partial coverage queryable** rather than buried in JSON |
| `AAO_Cited_Row_Deleted__c` | Checkbox | — | The orphan sweep | The live record is gone; the snapshot is all that remains. Visible to operations, never pushed at a seller |

**The discipline this object needs, and it is the thing that will decide whether it stays useful.** **It records what was cited, not what was available.** A junction that points at six types and freezes state is exactly the object that becomes a general-purpose context dump, and a claim that lists everything on the deal reads as far better supported than it was. If a row cannot name which part of the proposition it covers, it does not belong here.

**Answer-to-answer citation is permitted and unbounded reads are not.** A claim may rest on another answer's state — that is what makes one question able to reference qualifier statuses, other assessment answers, people and cards at once. Reconciliation's reads stay bounded to the proposition at hand; this junction records what was cited, it does not authorise scanning the deal.

---

## Entity count · fields v0.8

Fourteen becomes fifteen. Journal Event is removed. Answer and Claim Basis are added. Full list: Answer, Claim, Claim Basis, Candidate, Source, Note Evidence, Evidence Contract, Non-Establishment Rule, Link, Shadow Person, Fulfilment, Surfacing, Roll-Up, Flag, Run.

---

*End v0.8. Five objects closed plus the junction. Flag is the only Wave 1 object outstanding, and it is not in the replay path, so the accumulation test can run without it.*
