# AAO Board

> **The version lives on the stamp line below and nowhere else. Read this document first in every session and update it last.**

**v1.0 · 2 August 2026 · Created in the consolidation. Absorbs the seed's job and the corrections record's ledger job. The corrections record itself is archived, fully absorbed as of this stamp.**

**What this is.** The one document a session opens first: current state, the law list, the open items with owners, and the next steps. When this document and a companion disagree, the companion's stamped body wins on substance and this board is corrected; the board wins only on what is open versus closed.

---

## 1 · The five documents

| Document | Path | Authoritative for |
|---|---|---|
| **Board** | `claude/aao-board.md` | State, open/locked ledger, sequence, seeds |
| **Glossary** | `claude/aao-glossary.md` | Vocabulary. Every term, defined once |
| **Architecture** | `claude/aao-architecture.md` | The inventory: where things live, every ruling, placement. Carries Theory and Computable Share as stamped sections |
| **Model & Flow** | `claude/aao-model-and-flow.md` | Entities, keys, field tables, and what happens to one piece of evidence |
| **Charters** | `claude/aao-charters.md` | The AI: People, Problems, Politics, Process, the scope resolver, the account ontology, harness briefs |

**Satellites, outside the audit chain:** competitive rebuttals, proof register, plan to QBR, demo run sheet, sandbox build sheet, Gate 1 fixtures, the archived corrections record. **CODE's repo carries BUILD_JOURNAL.md; numbers come from there, never from here.**

**Rules of reading.** Open by exact path with project_read, never search. Read the stamp inside, never the filename. Chunks without stamps are untrusted. One live copy per document; superseded copies are deleted, and every live document carries its full changelog.

## 2 · Current state · 2 August 2026

**Org:** sandbox `altify--aossb2`, `00DWD00000DV7iT2AT`, IsSandbox true. Production is read-only unconditionally; MCP reads permitted. **Build:** 171 tests, 171 passing, per BUILD_JOURNAL (session 48, verified against the org). Eight objects with trigger laws plus Model Config. Proven in the org: replay rebuilds every answer from claims; dedup on bytes; async arrival survives adjudication; two clocks; speaker rank downgrades structurally; complete candidate ledger; day-one red with no dismiss. Gate 1 round two: outcomes 12/12, proposals 11/12, zero hallucinated spans ever. **The ontology seed is live:** 35 opportunity-side records as custom metadata, two-field shape, reader repointed, LAW #1 checkable by test. **Models:** extraction 1.1.0 and blind reader 1.0.0, pinned in Model Config.

**Charter ledger:** People closed except the persona emission. Problems closed. **Politics open, next after the People harness.** Process ruled (one charter, merged corpus) with its Charters section newly written. Scope resolver ruled through v0.4 and design-frozen.

## 3 · Locked · not open to relitigating

- **LAW #1.** No dependency on any ALTF package version, ever. The system runs with Altify absent and on any version. Feature detection, never version checks. The ontology ships as our seed metadata, org-overridable.
- **No metadata on any ALTF object; no triggers, metadata or logic on anything native.** Reading stable ALTF API names is permitted and necessary; it is not a version dependency.
- **Opportunity and Account are never written. Contact stays toggleable.**
- **Evidence over inference, including about our own schema, demo and documents.** A capability claim is unverified until tried from the runtime that will make the call.
- **The scope stamp law.** Every machine-written row carries exactly one scope, deal or account, from the evidence's own resolved scope. Deal evidence never writes account maps.
- **The scope resolver.** Two-key lock (owner-role map, setup-ratified, plus the content read), neither resolves alone; traversal interprets; curated rows outweigh membership; dual-write when both scopes resolve; net-new participants join both maps, dimensions establishment-gated per scope; flag target one in a hundred.
- **Stage scoping.** Read wide, never stage-gated, no model chooses attention; write gated at or behind the open stage; projection catches up from our own answers on stage advance.
- **The proposition is the pair:** Criterion Text plus Long Question; the content hash covers both.
- **In progress carries UNVERIFIED** on qualifier answers; null stays never-asked.
- **The rung derivation.** The authored tables convert established propositions to map values; **recency owns the rung** when sides conflict; the displaced side raises the opposite-polarity contention flag; Neutral is never a computed balance.
- **Citations:** quotes live on Answer rows only, nothing duplicates them; the map note is a current-state composite, overwritten freely, evidence untouched.
- **Corrections go into documents, never chat. Wrong text is marked wrong, never deleted. One structural decision at a time; Matthew's calls stay open until he rules.**
- **Agentforce is not part of this build.** An agent runtime is a consumer, never substrate. Depend on the Trust Layer gateway and Data 360; neither is Agentforce.

## 4 · Open · with owners

**Matthew's rulings:**
- The Political Status derivation table (seven questions to three values) — draft owed from design first.
- The scope ontology's sided vocabulary — draft in Charters, owed his correction.
- Seller scope in an org with no Altify licence to read (LAW #1 deleted the old filter's answer), and the **seat-gaming** hazard: owner-licensed scoping lets one licensed owner run the whole org.
- Model-role naming (glossary names vs People/Problems/Politics/Process) — glossary open term 13.
- Corporate-namespace deletions (this consolidation executes them).

**Design (this side):**
- Politics charter, opening after the People harness.
- The Surface entity, proposed seventeenth, for Model & Flow: the per-opportunity focus digest, rebuild-on-change, Roll-Up's class; whether it hosts the reconciliation destination; tiered flag surfacing lands here.
- Stand-in (shadow) field table sketch: per-scope grain, values cached, never quote text.
- Per-claim scope (dual-scope residue). D360 match-rule ruling (exact-email, slow lane only). The two-sided summary's schema.

**CODE:**
- Account-side seed records (AM labels from session 42 plus Decision Orientation's five) — in flight.
- Journal Current state rewrite. MANIFEST repoint. Shadow object build (Wave 2). The People harness once briefed.

**Structurally unanswerable here, parked:** module-licence detection (probe, don't count) and package-upgrade behavior of subscriber edits — both need orgs that do not exist yet.

## 5 · Next steps, in order

1. Political Status table drafted → Matthew corrects both tables and the scope vocabulary.
2. CODE harness brief: People, opportunity-level, RM-only shape — projection writer with watermark and exclusion-list experiment, note composite, rung derivation, live contention leg only (no D360; historical leg written, skipped as graceful absence).
3. People + Problems + Politics harness (opportunity level) after Politics is written.
4. Account-level RM/IM harness (scope resolver build, Source scope nullable, account engagement category).
5. OM/SPM comprehensive harness (back burner, five-part test recorded in Charters).

## 6 · Standing hazards

The only queryable orgs are Altify's own; ~80% of installs have no methodology history, no native call capture, no package — every production finding carries *does this survive in a bare org*. Retrieval returns chunks from retired versions: open by path, demand stamps. ECI's related-record stamp is inference and unstable; never trust derived platform classifications. Sweep wider than the question, read the list, filter after — sparse numbering under-collects, family patterns over-collect, misspelled names (`CONFCLIT`) defeat targeted greps, and a non-empty result missing one row looks exactly like success. Vocabulary: our answer row, never bare answer; verified, never scored; receipts, never confidence; Agentforce-ready, never Agentforce-dependent. No em dashes in written output.

## 7 · The session seed

```
Seed - AAO single-purpose session. Focus: [ONE of: People / Problems / Process /
Politics / Contention & D360 / Projection & Flags]. Cowork session attached to
the Altify Agency project.

Open by exact path, never search: claude/aao-board.md first, then the Charters
section named above; other documents only as the Board points. Read the stamp
inside, never the filename. Numbers come from CODE's BUILD_JOURNAL.md.

Rules: one structural decision at a time, options with costs, Matthew's calls
left open. Evidence over inference, including about our own schema. A
capability claim is unverified until tried from the runtime that makes the
call. Nothing outside today's focus is opened or ruled on.

At session end, when Matthew confirms it is over: fold every ruling and finding
into the five documents where they belong, bump their stamps, mark wrong text
wrong, update the Board's ledger and next steps, refresh aao-context.zip for
CODE with an exact copy-paste block, and write the next seed naming one focus.
Nothing may reference a retired version.
```

---

*End v1.0. This document is rewritten at every session end; everything below its stamp is current or it is a defect.*
