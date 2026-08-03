# AAO Board

> **The version lives on the stamp line below and nowhere else. Read this document first in every session and update it last.**

**v1.2 · 3 August 2026 · The build-day rewrite, end of the People harness construction session. The harness is built through step 2 of §P7.2 and proved at 204 tests; steps 3 onward (ingest, pass, invoker, assertions) are the live work. The command center LWC ships on both Opportunity and Account pages. Fixture and transcript are loaded and verified in the sandbox. Four rulings closed and folded (writer shape, two-sided guard, declared applicable set, membership never routes); the ingest-time reconciler becomes the umbrella open item. Four new hazards recorded. Companion stamps after this fold: Charters v2.3, Architecture v3.2, Model & Flow v1.1, Glossary v2.3.**

**What this is.** The one document a session opens first: current state, the law list, the open items with owners, and the next steps. When this document and a companion disagree, the companion's stamped body wins on substance and this board is corrected; the board wins only on what is open versus closed.

---

## 1 · The five documents

| Document | Authoritative for |
|---|---|
| **Board** (`aao-board.md`) | State, open/locked ledger, sequence, seeds |
| **Glossary** (`aao-glossary.md`) | Vocabulary. Every term, defined once |
| **Architecture** (`aao-architecture.md`) | The inventory: where things live, every ruling, placement. Theory and Computable Share as stamped sections. Both applicable-set laws |
| **Model & Flow** (`aao-model-and-flow.md`) | Entities, keys, field tables, and what happens to one piece of evidence. Field Tables win on fields |
| **Charters** (`aao-charters.md`) | The AI: every charter, the scope resolver, the account ontology, the harness briefs §P7.2 and §P7.2.1 |

**Paths are per environment:** project root on the design side, `docs/` in CODE's repo. Open by exact path, never search. Read the stamp inside, never the filename. Chunks without stamps are untrusted. One live copy per document, full changelog inside. **When a zip is amended mid-carry, the CODE inbox is re-stamped last, same as this board**, because two documents in one zip disagreeing cost a real detour on 2 August.

**Satellites, outside the audit chain:** competitive rebuttals, proof register, plan to QBR, demo run sheet, sandbox build sheet, Gate 1 fixtures, corrections archive, `applicable_set.json`. Numbers come from CODE's BUILD_JOURNAL, never from here. **Demo run sheet: v1.3 in CODE's docs, v1.2 in the project; never regress; carry v1.3 back at a clean moment.**

## 2 · Current state · 3 August 2026

**Org:** sandbox `altify--aossb2`. Production read-only unconditionally; `altify-pbo` never read. **Build, per BUILD_JOURNAL verified against the working tree: 204 tests, 204 passing.** In the org: the B&V fixture (3 accounts, 46 contacts, 6 opportunities, 125 contact roles, counts read back, ID map tracked), the Casey transcript verified by SHA-256 (occurred clock 24 June 2026 07:01, roster of four, given deal B&V Community Licenses-150), 125 map skeleton rows built by Altify's contact-role sync, 48 People contracts stamped and roster-resolvable, the writer `AAO_Project` proved at 18 tests including the create leg, the command center LWC live on Opportunity and Account pages with links, lineage, real projection panel, all six flag types, both clocks labelled, Held rendered dead.

**Measured this session and now law-grade facts:** Altify creates nothing on API-inserted Opportunities across all 82 ALTF objects; it builds map skeletons on OpportunityContactRole insert, and that sync is a customer configuration that can be off; `Is_Key_Player`, `Squares`, `Color`, `ConcatenatedFields` are formulas, so the passing assertion is per-dimension stamp isolation, not exclusion; the package maintains per-dimension `_Last_Modified` stamps on API writes natively, which is the watermark substrate.

**Charter ledger:** People closed except persona emission. Problems closed. Politics open, next after the People harness. Process ruled; its per-deal binding persistence owed. Scope resolver ruled and design-frozen; the sided vocabulary CLOSED at Charters v2.1; membership-never-routes added at v2.3.

**Harness state: steps 0, 1, 2 done. Steps 3+ (Source ingest, model pass, `AAO_TEMP_` invoker, mechanical assertions) are the next CODE work. Then Matthew adjudicates against the recording.**

## 3 · Locked · not open to relitigating

- **LAW #1.** No ALTF package-version dependency, ever. Feature detection, never version checks. Ontology ships as our seed metadata, org-overridable.
- **No metadata, triggers, or logic on any ALTF or native object.** Reading stable ALTF API names is permitted; data rows on managed objects are the product's output surface. **Opportunity and Account never written by the product runtime; Contact toggleable; the fixture seeder is scaffolding, distinguished in §P7.2.**
- **Production read-only unconditionally.** Evidence over inference, including about our own schema; a capability claim is unverified until tried from the calling runtime.
- **The scope stamp law** and **the scope resolver** (two-key lock; traversal interprets; curated over membership; dual-write when both scopes resolve; flag target one in a hundred). **Membership never routes (new, v2.3):** at most one deal and one account per Source; affirmatively named stretches route per content; ambiguity abstains, nothing writes.
- **The two layers law:** the sided vocabulary routes and never gates a write; establishment writes and never routes. Seed vocabulary is a floor, org-extensible as additive natural language.
- **The declared applicable set (new):** a pass names its charters; contracts carry their designation; resolution runs per charter (assessment per deal, People per roster); nothing unresolved reaches a model. Contracts are frozen identity under a live read; reconciliation happens at ingest, not by redeploy.
- **Rung derivations:** Support ladder with recency arbitration and opposite-polarity contention flags; **Political ceiling** (one establishment suffices everywhere, lesser properties never downgrade, exit only when words flip a two-sided question, Q9 places nobody, no contention flags, silent re-derivation). **TRUE-strong / FALSE-weak with the affirmative-weak-side guard; UNVERIFIED places nobody. Unset writes null, never `Unknown`.**
- **Flag volume is a budget**, spent only on what changes seller behavior.
- **The writer:** query-then-branch on the pair, never platform upsert; populate only moved dimensions; create with rest-null where absent; two rows for one pair is a flag, never a pick; create leg is mandatory product behavior.
- **Citations:** quotes on Answer rows only; Option C note, overwritten freely, evidence untouched. **Held is live for nothing.** Day-one red; no dismiss on assessment reds (the three-class dismissal design is open, below).
- **Corrections into documents, never chat. Wrong text marked wrong, never deleted. One structural decision at a time; Matthew's calls stay open until he rules. Agentforce is not part of this build.**

## 4 · Open · with owners

**Matthew:** watch the 24 June recording with a notepad before CODE's run report; adjudicate the output. Seller scope and seat-gaming, plus which opportunity types get processed. Model-role naming. Corporate-namespace deletions. PII split: ratified.

**Design (this side):**
- **The ingest-time reconciler, umbrella item, owed before any charter beyond People runs:** resolve IDs, read live rubric per declared charter per deal, reconcile contract versions by content hash, then run; includes persisting the per-deal rubric binding as a queryable fact (the Process half-measure).
- **Politics charter, next focus after the run.**
- **People persona emission**, owed before People is called fully closed.
- **The three dismissal classes** (guidance dismissible; contention acknowledgeable, timestamped, tracked against outcome; assessment reds evidence-cleared only), architecture owed its own session.
- **Account-grain enablement:** the nullable-Opportunity schema ruling on the five row objects plus the ScopeKey composer, bound to the account-level harness. The 16 shared AM_OM questions read by the opportunity pass only. The per-org charter overlay. Surface entity. Wave 2 sketches. D360 match rule. Two-sided summary schema.
- **The Toby deck:** thirty-ish slides on the evidentiary chain and its decision gates, derived from the stamped documents, owed before the QBR week of 10 August. Lands in plan-to-QBR.

**CODE:** §P7.2 steps 3+ (ingest, pass, invoker, mechanical assertions), then the run report with receipts. Adjudication record folded back afterward. Shadow objects (Wave 2). MANIFEST repoint.

**Parked, structurally unanswerable here:** module-licence detection; package-upgrade behavior of subscriber edits.

## 5 · Next steps, in order

1. CODE: steps 3+, run the Casey transcript, run report to Matthew with the command center live.
2. Matthew: adjudicate against the recording; disagreement notes to design.
3. Design: fold the adjudication record into the People charter as post-run findings; then the Toby deck outline.
4. Politics charter opens. Then People + Problems + Politics harness; account-level harness after.

## 6 · Standing hazards

The only queryable orgs are Altify's own; ~80% of installs have no methodology history, no call capture, no package. Retrieval returns chunks from retired versions: open by path, demand stamps. ECI's related-record stamp is inference; never trust derived platform classifications. Sweep wider than the question. Vocabulary: our answer row, never bare answer; verified, never scored; receipts, never confidence; Agentforce-ready, never Agentforce-dependent. No em dashes in written output.

**New this session, all measured:** In a shared org, `CreatedBy` cannot separate CODE from Matthew, who work as the same user; **attribute by what a row points at, never by who created it.** A field deploy reporting success proves Apex visibility only; **FLS is a second, separate fact**, and its absence reads exactly like a failed deploy reporting success. Lightning caches component bundles hard; **a check without a hard refresh proves nothing.** Contact-role sync builds map skeletons and **is a configuration**; never assume the skeleton exists at a customer.

## 7 · The session seed

```
Seed - AAO single-purpose session. Focus: the People harness run and
Matthew's adjudication. Cowork session attached to the Altify Agency
project.

Open by exact path, never search: aao-board.md first, then Charters
§P7.2 and §P7.2.1; other documents only as the Board points. Read the
stamp inside, never the filename. Numbers come from CODE's
BUILD_JOURNAL.md.

State on pickup: harness built through step 2, 204 tests green,
fixture and transcript loaded and verified, command center live on
both pages. CODE is building or has built steps 3+ (ingest, pass,
AAO_TEMP_ invoker, mechanical assertions). This session receives
CODE's run report, supports Matthew's adjudication against the 24
June recording, and folds the adjudication record into the People
charter as post-run findings. Expected failure mode, from Gate 1:
over-reading, never fabrication. If the run surfaces defects, they
are CODE's to fix and this side's to record; nothing is redesigned
mid-run.

Rules: one structural decision at a time, options with costs,
Matthew's calls left open. Evidence over inference. A capability
claim is unverified until tried from the calling runtime. Nothing
outside People is opened or ruled on; the Toby deck outline may be
drafted only after the adjudication record is folded.

At session end, when Matthew confirms it is over: fold every ruling
and finding into the five documents, bump stamps, mark wrong text
wrong, rewrite the Board, refresh aao-context.zip with a re-stamped
CODE inbox, and write the next seed naming one focus. Nothing may
reference a retired version.
```

---

*End v1.2. This document is rewritten at every session end; everything below its stamp is current or it is a defect.*
