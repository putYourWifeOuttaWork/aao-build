# AAO Board

> **The version lives on the stamp line below and nowhere else. Read this document first in every session and update it last.**

**v1.3 · 3 August 2026 · The redesign rewrite, end of the second build-day session. The per-person pass shape is retired by Matthew's ruling and §P7.3 (Extract-Bind-Verify) is the pass: one read per Source to an inventory, binding promotes Candidates to Claims, separate small-model verification before any Claim writes. The B&V baseline on the old shape is abandoned, not deferred; the new baseline is B&V on §P7.3. The Emerson fixture is seeded and final. The 120-second cumulative-per-transaction callout ceiling is law-grade and unraiseable; the Trust Layer is recorded for posterity as the model path that always was, the direct Named Credential a dev-org stand-in. Companion stamps after this fold: Charters v2.4, Architecture v3.3, Model & Flow v1.2, Glossary v2.4.**

**What this is.** The one document a session opens first: current state, the law list, the open items with owners, and the next steps. When this document and a companion disagree, the companion's stamped body wins on substance and this board is corrected; the board wins only on what is open versus closed.

---

## 1 · The five documents

| Document | Authoritative for |
|---|---|
| **Board** (`aao-board.md`) | State, open/locked ledger, sequence, seeds |
| **Glossary** (`aao-glossary.md`) | Vocabulary. Every term, defined once |
| **Architecture** (`aao-architecture.md`) | The inventory: where things live, every ruling, placement. The platform-ceiling and model-path laws at the v3.3 head |
| **Model & Flow** (`aao-model-and-flow.md`) | Entities, keys, field tables, and what happens to one piece of evidence. Field Tables win on fields |
| **Charters** (`aao-charters.md`) | The AI: every charter, the scope resolver, the account ontology, the harness briefs, **§P7.3 the pass** |

**Paths are per environment:** project root on the design side, `docs/` in CODE's repo. Open by exact path, never search. Read the stamp inside, never the filename. One live copy per document. **When a zip is amended mid-carry, the CODE inbox is re-stamped last, same as this board.** CODE's `docs/aao-P7.3-extract-bind-verify.md` standalone is superseded by Charters v2.4 §P7.3 and should be marked so in the repo.

**Satellites, outside the audit chain:** competitive rebuttals, proof register, plan to QBR, demo run sheet, sandbox build sheet, Gate 1 fixtures, corrections archive, `applicable_set.json`, the Emerson extract (v3 zip). Numbers come from CODE's BUILD_JOURNAL, never from here. Demo run sheet: v1.3 in CODE's docs, v1.2 in the project; never regress.

## 2 · Current state · 3 August 2026, second session

**Org:** sandbox `altify--aossb2`. Production read-only unconditionally; `altify-pbo` never read.

**Build, per BUILD_JOURNAL:** extractor corrected (`contracts()` → `inventory()`, model path takes the declared set as argument, no rubric read); SHA-256 structural at insert, omission impossible by construction; artifact-first prompt ordering in, deliberately inverted with both comments kept; per-person split built, measured, and retired the same day (commits `8e3b10b`, `7f43488`, spec filed at `cbaed19`); 55 tests green on touched classes, suite last read 204/204 before the split work.

**Fixtures, final:** B&V (unchanged, Source loaded, session-62 fingerprint gap recorded as history) and **Emerson** — 2 Accounts (Emerson Electric Co. + Aspen Technology as second native parent), 168 Contacts (114/54, Filipe once, all 54 per Matthew's override), 2 Opportunities (given deal `006WD00000TJmJZYA1` Closed Won $275,555; Renewal Stage 2 open), 16 contact roles, `Tylor / St. Clair` corrected by read-back. The 2019 closed-lost is dropped for good under the seed-window law.

**Law-grade measurements this session:** the 120-second cumulative callout ceiling (per transaction, sync = async, unraiseable, shared across certified namespaces; Batch resets per execute; callout wait ≠ CPU) — three timeouts at the ceiling proved it; **output is near-constant against proposition count** (16 props → 7,339 out; 53 → 7,532 out; identical 18,696 in) and the artifact dominates input, which is what killed the per-person shape; prompt caching is live through the Named Credential (13,799 cached tokens read; `cacheCreate 5,500` on the cold call); ECI misfires in **both directions**, now evidenced twice (B&V: account call stamped to a deal; Emerson: late-stage deal call stamped to the account); LongTextArea strips a trailing newline; the transcript record's duration is the call's, never its own; `RelatedPersonId` coverage is not deterministic (both Emerson external rows null); the identity ladder's CRM rung is account-scoped and therefore blind to cross-account duplicates of one real-world company.

**Voided history, never baselines:** session 62 (defective extractor, 53 asked against 48 declared) and the per-person shape's measurement. `findings=1` three times running is a named charter question, unexplained, riding into the new shape as something adjudication must watch.

**Charter ledger:** People closed except persona emission; the pass is §P7.3. Problems closed. Politics open, after the resolver. Process ruled, per-deal binding persistence owed. Resolver ruled and design-frozen, v0.3 participant claim qualified in place.

## 3 · Locked · not open to relitigating

- **LAW #1.** No ALTF package-version dependency, ever. Feature detection, never version checks.
- **No metadata, triggers, or logic on any ALTF or native object.** Opportunity and Account never written by the product runtime; Contact toggleable; seeders are scaffolding.
- **Production read-only unconditionally. Evidence over inference. A capability claim is unverified until tried from the calling runtime.**
- **The pass is Extract-Bind-Verify (§P7.3).** Per-proposition-per-person and whole-set-one-call shapes are retired. Binding and verification are **separate models**; verification runs on a significantly smaller model, gated once by an adjudicated comparison.
- **Coverage is computed, never extracted.** Presence per occasion (scope + artifact hash), deterministic; decay is parked config.
- **The evidence budget is ~90 output tokens per finding**, justified by coextension; stored quotes stay full-fidelity on Answer rows.
- **The model path is the Einstein Trust Layer / Models API — always was.** The direct Anthropic Named Credential is a dev-org stand-in (flex credits unavailable in dev). Short synchronous calls are the design target. Provider batch endpoints bypass the Trust Layer and are **parked, never sold**. BYOLLM = Model Builder behind the same gateway.
- **The callout ceiling law** (Architecture v3.3 head): one bounded callout per transaction; the wait never lives in Apex.
- **Resolver-next, hard:** the resolver build is the immediate next build after People closes — before Politics, before anything. Without it no Source can route and there is no product.
- **Seed window:** open plus recently closed deals only. **Extract format ships FirstName/LastName as read.**
- **Similar names are not duplicates.** Two different strings are two people until something says otherwise; only exact-name matches raise the duplicate question (tiebreak OPEN, below).
- **The scope stamp law, the resolver two-key lock, membership never routes, the two layers law, the declared applicable set, rung derivations, TRUE-strong/FALSE-weak with UNVERIFIED placing nobody, null never `Unknown`, flag volume as budget, the writer's query-then-branch, citations on Answer rows only, Held live for nothing, day-one red, no dismiss on assessment reds** — all as at v1.2.
- **Rulings travel to CODE as one explicit line at the top of a post** — never a bracket, never bundled behind one word.
- **Corrections into documents, never chat. Wrong text marked wrong, never deleted. One structural decision at a time. Agentforce is not part of this build.**

## 4 · Open · with owners

**Matthew:**
- **Dictate the blind watch notes from the 29 July video to design BEFORE reading any run report** — the video is watched, the notes exist only in his head, and their value as an answer key collapses the moment CODE's output is seen. First act of the next session.
- **The exact-name duplicate tiebreak:** most-recent-activity always, versus tiebreak-only-where-provably-one-human with shadow-plus-flag where provably two. Open, one ruling.
- Seller scope and seat-gaming; which opportunity types get processed; model-role naming; corporate-namespace deletions.

**Design (this side):**
- The small-model verification gate: adjudicated comparison against the strong model, then the sizing ruling.
- The ingest-time reconciler, umbrella item, owed before any charter beyond People runs.
- The cross-account identity blindness (ladder's CRM rung is account-scoped) — design-owed, not improvised.
- **Experiments queue:** T1.5 terse-charter trim beyond the schema (only if stage measurements demand it); T3 lighter People ontology (`findings=1` may be phrasing); T4 small-model routing for binding; T5 computable-first Process/Assessment fed by verified claims. T2 triage is absorbed by extract-once.
- Email ingestion: v1 is transcripts and notes; **defer-don't-delete leaning recorded, unruled.** Mentioned-but-absent tightening: unruled, collides with the person-row boundary law. Persona cost / yellow-flag idea: parked to persona emission.
- Closed-deal projection (evidence occurred while open, deal now won) — open question, run proceeds and records.
- Whether a void pass can be marked void in the org (the command center renders session 62 as pending forever).
- Replay-dedupe as a later feature (safe merge execution with receipts, never detection; two unverified: claim rows surviving native merge reparenting; delete-vs-supply-evidence). Later.
- Resolver proposition list, accumulating for its build session: owner role, content summary, curated overlap, occurred-time org state, content maturity, parent/subsidiary topology (Emerson/AspenTech pair, ParentId null).
- People persona emission; the three dismissal classes; account-grain enablement bundle; **the Toby deck** before the QBR week of 10 August.

**CODE:** build §P7.3 per the brief (stage 1 extractor; binding; verification on the smallest available model, journaled; Apex abstention writer; one callout per transaction, group sizes measured not assumed); per-stage telemetry including the `model_missed` rate and verification-rejection count; **B&V on the new shape is the baseline**, then Emerson, then the run report with receipts. Mark the standalone P7.3 spec in `docs/` superseded by Charters v2.4. Shadow objects (Wave 2). MANIFEST repoint.

**Parked, structurally unanswerable here:** module-licence detection; package-upgrade behavior of subscriber edits; provider batch endpoints (trust-mode incompatible today).

## 5 · Next steps, in order

1. Matthew: blind watch notes to design (before any report is read).
2. CODE: build §P7.3, measure per stage, B&V baseline, Emerson run, report with receipts.
3. Matthew: adjudicate Emerson output against the 29 July recording; disagreement notes to design.
4. Design: fold the adjudication record into the People charter; the small-model gate; then the Toby deck outline.
5. Resolver build. Then Politics.

## 6 · Standing hazards

The only queryable orgs are Altify's own; ~80% of installs have no methodology history, no call capture, no package. Retrieval returns chunks from retired versions: open by path, demand stamps. ECI's related-record stamp is inference, misfiring in both directions, one input never the answer. Sweep wider than the question. Vocabulary: our answer row, never bare answer; verified, never scored; receipts, never confidence; Agentforce-ready, never Agentforce-dependent. No em dashes in written output. `CreatedBy` cannot separate CODE from Matthew; attribute by what a row points at. FLS is a second fact beside deploy success. Lightning caches hard; no check without a hard refresh. Contact-role sync is a configuration.

**New this session:** **The local-fix hazard** — a correct local fix is evidence the local question was asked, never evidence the structure is right; when the same defect survives three fixes, the defect is the shape (`findings=1` was the visible edge, three times). **The decision-slot hazard** — two rulings were lost in one day to brackets and bundled words in traveling documents; rulings go as one explicit line. **A run that succeeds only on a cache hit is not a run that works.** A count that passes can pass by coincidence — verify what the check counts, not that it matched.

## 7 · The session seed

```
Seed - AAO single-purpose session. Focus: capture Matthew's blind watch
notes, then receive CODE's §P7.3 build measurements and the B&V/Emerson
run reports, and support adjudication. Cowork session attached to the
Altify Agency project.

Open by exact path, never search: aao-board.md first, then Charters
§P7.3; other documents only as the Board points. Read the stamp inside,
never the filename. Numbers come from CODE's BUILD_JOURNAL.

FIRST ACT, before any run report is opened: take Matthew's dictated
notes from the 29 July Emerson video (who holds authority, who gates,
who spoke about whom, sentiment on camera versus on the page) and
freeze them as the pre-run key beside §P7.3. Their value collapses the
moment output is seen.

State on pickup: §P7.3 is the pass (Charters v2.4); Emerson fixture
seeded and final; B&V baseline on the new shape is CODE's next
deliverable; the 120-second ceiling and Trust-Layer-always laws are at
Architecture v3.3's head. Expected failure mode: over-reading, never
fabrication; watch the model_missed rate and the verification-rejection
count. findings=1 remains an unexplained named question.

Rules: one structural decision at a time, options with costs, Matthew's
calls left open; rulings to CODE as one explicit line. Evidence over
inference; a capability claim is unverified until tried from the
calling runtime. Nothing outside People opens except the resolver
proposition list may accumulate. The Toby deck outline may be drafted
only after the adjudication record is folded.

At session end, when Matthew confirms it is over: fold every ruling and
finding into the five documents, bump stamps, mark wrong text wrong,
rewrite the Board, refresh the zip with a re-stamped CODE inbox, and
write the next seed naming one focus. Nothing may reference a retired
version.
```

---

*End v1.3. This document is rewritten at every session end; everything below its stamp is current or it is a defect.*
