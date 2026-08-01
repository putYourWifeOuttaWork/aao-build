# AAO Corrections and Change Record, v2.0

**v2.0 · 1 August 2026 · The comprehensive record: everything ruled, built, and proven since the four corporate documents were last stamped. Authoritative over them until each is bumped.**

**Who this is for.** The corporate project's agent, carrying the sprint's results back into the canonical documents. The stamped corporate documents as of this writing: Architecture v2.9, Glossary v1.9, Object Model v2.0, Data Flow v2.3, Theory v1.3, Computable Share v1.5. All predate the build sprint of 30 July through 1 August. This record supersedes them wherever they disagree, exactly as corrections v1.0 did for the Answer and Claim rename. Corrections v1.0 remains true; this absorbs and extends it.

**How to use this.** Work one document at a time. For each item below, the corporate document is bumped to say the new law, and where the old text was wrong rather than merely incomplete, the old text is marked wrong, not deleted. Full field-level detail lives in `aao-field-tables-v0_12` and full charter detail in `aao-charter-design-v0_5`, both in project knowledge; this record states the law and points there rather than duplicating tables.

---

## 1 · The object model: what exists now

**Fifteen entities.** The current-state row is the **Answer** (upserted, one per question per subject). A **Claim** is one immutable establishment from one piece of evidence, carrying four keys (opportunity, account, external person, internal person) and two clocks (evidence occurred, recorded at). Journal Event is retired into Claim. **Claim Basis** is a junction under Claim (master-detail): what a claim rested on, six typed lookups (map row, insight card, decision criterion, answer, qualifier status, shadow person), each row carrying a frozen JSON snapshot of the cited values plus the live lookup, and naming which element of the proposition it covers. It records what was cited, never what was available. No claim-to-claim parentage; claims relate by sharing an answer.

**The evidence-family law.** Every Candidate and Claim carries a basis: Transcript, State, or Both. Transcript requires a Source with byte-verified spans. State requires the Source lookup be null and at least one Claim Basis row. Both requires both. Enforced in triggers, not by field-level required flags, because a required flag strands pre-existing rows and cannot express a conditional law. Answer carries basis too, with union semantics: established from a call and later reinforced from state reads Both.

**Deployed and proven in the sandbox** (altify--aossb2, production read-only unconditionally): eight objects live, trigger laws enforced, over one hundred tests green. Replay is proven: delete all answers, replay claims in evidence-occurred order, reconstruct every answer exactly, on every demo deal. Async arrival survives adjudication failure. Identical bytes ingested twice produce nothing. A seller's own words land downgraded structurally. Every proposition considered writes a candidate row including nobody-said, so the consideration ledger is complete.

**Five Apex reserved-word collisions, permanent:** commit, json, system, merge, any. Each broke a deploy. Our vocabulary is full of exactly these words; they are fine as picklist data, never as identifiers.

**AAO_Model_Config__mdt** exists (custom metadata pinning model, endpoint, charter versions, cache parameters). Thirteen fields, enumeration being absorbed into field tables v0.13. The API secret is not in it; the secret lives in a Named Credential write-only slot, merged into the request after Apex builds it, unreadable from code and absent from logs.

## 2 · The model layer: built and measured, no longer design

**Two model calls, both live.** Call one, extraction: reads the transcript plus the questions, proposes candidates with quotes, writes nothing else. Apex byte-verifies every quote. Call two, the blind reader: sees only the question, its elements, the interpretation, and the verified spans, never the first verdict; judges whether the spans establish the proposition element by element. Everything between and after the calls is deterministic Apex. A model never touches a record.

**Gate 1 round two, receipted.** Graded on adjudicated answers: 12 of 12 against staged ground truth. Graded on raw proposals: 11 of 12, and the one miss was fully diagnosed by the interpretation field (the model used the seller's own question as coverage and read an unanswered question as FALSE). Zero hallucinated spans across all passes. The blind reader's value was predicted in writing before the run and the prediction held: it refused a byte-verified span that did not establish its element, which is the one judgment no deterministic check can make.

**Prompt caching, measured.** With the rubric prefix cached, paid input fell from 3,137 tokens to 175, roughly 95 percent. The cache lives about five minutes, so the discount belongs to clustered nightly sweeps, not to trickle processing. Batch scheduling is therefore an economic decision, measured not assumed.

**The three-way abstention enum.** nobody_said (the evidence does not bear on the question), model_declined (it bears, the model would not commit; the only true abstention), not_returned (the model never reported the proposition at all; a charter-quality signal, never counted as abstention). The old model_missed is retired but kept valid on historical rows. Outcome gains Not_Returned. Both readers, extraction and blind, are named with versions on every candidate row, so every outcome is attributable to the rules that produced it.

**Language guardrail, standing.** Model calls today go directly to the Anthropic API via Named Credential. The Einstein Trust Layer is the packaged target, drawn on the target diagram as such. Never say the Trust Layer is already in the path.

## 3 · Rules and discovery: the works-anywhere receipt

**Discovery reads the rubric from the org.** Evidence Contracts are derived from Altify's own assessment question tables, reading the long question text as the proposition and falling back to criterion text, recording which was used. Contracts supersede rather than delete; delete is blocked outside the purge context. A filter fault is loud: an empty table is a cold start, but a populated table returning zero matches is declared as a DISCOVERY FILTER FAULT, never a silent empty result.

**No rubric binding on deals.** A deal always answers the org's current active questions. Rubric version is attribution stamped on receipts, never routing. A proposed binding field was considered and rejected by Matthew on the grounds that nothing breaks without it; the two-rubrics scenario that motivated it was an artifact of the test org. This is a standing example of the generalization hazard: the only org we can query is unlike the orgs this ships into.

**The recipe ruling for state-based questions.** A model may write the query once at setup; the query is frozen on the contract and executed by Apex every pass thereafter. Interpretation belongs to the model, completeness to the database (only a query can prove what is not there), determinism to the freeze. The admin surface is sentences, never code: the admin sees their question, the machine's plain-words reading of it, and Approve or Revise, with Revise being typed natural language round-tripped through the same model. Runtime model reading of state remains the universal floor; frozen queries are the earned upgrade.

**Day-one red is live.** A gating proposition is red from the moment the opportunity is created. TRUE clears it. There is no dismiss anywhere in the system; flags clear when the cause goes.

## 4 · The charters: People closed, Problems open

**The People charter is closed except its output schema.** A person earns a row when a claim needs them. Identity resolves down a ladder: roster, then CRM, then memory; one match links, zero creates a shadow person, many creates a shadow plus an Identification flag. Shadow persons cover anyone referenced but absent. The platform requires a last name to write a Contact, so partial identities stay shadows; writing CRM contacts is a projection-pattern toggle. Self-reported sentiment moves one rung conservatively; terminal rungs (Mentor, Enemy) are earned and lost only across multiple separate sources; no behavioral-pattern inference; a human write watermarks the dimension forever.

**The Identification flag is the fifth flag type.** It asks for missing knowledge, not permission. Its answer re-enters the pipeline as evidence. It fires at every autonomy level, and where resolving it would clear a red, the red is surfaced proactively: the nearly-clearable law, the cheapest red to clear is the one that is one answer away.

**Inferred attribution is ruled, gated on measurement.** A fourth diarization class between Attributed and Unsegmented: on text-only sources a model proposes turn boundaries and speakers at two tiers, side (buyer or seller) and named identity, every attribution citing its own cue against a closed candidate set, stored as an annotation beside the frozen bytes, never mutating them. The gate is a strip-and-restore harness: strip labels from attributed transcripts, re-attribute, compare. Until anchored-identity precision meets a measured bar, inferred sources run at any-participant power only. This exists because some orgs are unstructured forever and can never afford a system that never moves their dials.

**The Problems charter is open, core rulings landed.** The map exists for call prep: who has what problem, why it matters, in their own words. Every genuine insight goes on the map; the model infers duplicated meaning. Dedup keeps the parent card and never writes a sibling: the count is prepended (2x, 3x) and the reiteration date appended in plain words. Citations on cards are extremely short plain text, date plus speaker, no URLs, no IDs, no hyperlinks; the full receipt lives on the Claim. Confirmation is evidence-driven: twice in one call confirms; once is unconfirmed; a later re-mention notes the date and confirms; a different person is an attribution note. Completely different language is a different insight. Humans never drag cards; no gesture is ever load-bearing. **Ratified 1 Aug: the machine annotates only machine-authored cards; reinforcement of a human-authored card is recorded as a Claim with outcome Reinforced and surfaces beside the card, never inside its text.** One open ruling remains: whether a projected machine confirmation is visually distinct from Altify's human Confirmed.

**Production evidence behind the Problems rulings.** Read directly from Altify's production org, read-only, 1 August: five deals, 349 insight cards. Human cards show real conversational fingerprints but zero provenance. Generated cards are public-filing boilerplate, including three contradictory NRR targets coexisting on one map. Roughly one card in five is confirmed. The exception proves the direction: the one won deal in the sample carries two-thirds of its cards confirmed and zero generated. Citations plus dedup plus a seller-owned confirmed section is the moat.

## 5 · Flags and the surface

**Flag is closed with five types**, Identification the fifth. A flag has a cause and clears only when the cause goes; there is no dismissal path anywhere.

**The surface is one thing, not two.** The read surface and the reconciliation destination are unified: one snapshot per opportunity per seller, with response fields on it. It supersedes on change rather than editing in place. A seller's gesture on the surface becomes evidence entering the pipeline; it never clears anything directly.

## 6 · Proven claims for external use

The proof register (`aao-proof-register-v0_1` in project knowledge, now 28 rows) is the discipline: PROVEN rows carry receipts and may be stated flat; NEEDS MEASUREMENT rows name their test and are stated only as design properties; UNVERIFIED rows are never repeated externally. Headline proven rows: replay exactness, dedup on identical bytes, structural speaker-rank downgrade, zero dependency on Altify records, 12 of 12 model outcomes against truth with zero hallucinated spans, the 95 percent cached-input reduction with its five-minute caveat, and the cost row: seed document to model-verified pipeline in about 48 hours, one architect plus AI tooling, zero new infrastructure, token spend under a dollar. Corrected and recorded: there is no native Gong connector in Data 360; the real answer is the CRM connector, cloud storage, or the Ingestion API, one payload contract for every source.

## 7 · What is deliberately not settled

Charter output schemas (People and Problems). The Politics charter, not yet opened. Wave 2 field tables (Note Evidence, guidance fields). The machine-confirmation projection question above. Per-org charter overlay. Surface delivery mechanics. Each is named open on purpose; none blocks the build.

---

*End v2.0. Bump each corporate document against this record one at a time, mark superseded text as wrong rather than deleting it, and version every heading touched. When all six are bumped past this record's content, this record is historical.*
