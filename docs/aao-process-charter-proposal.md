# AAO Process Charter Proposal · v0.5 · 19 August 2026 · §4 GRADED (the set is FIFTEEN, T3 moves to the sales process) · THE DERIVED-ENTITY IDENTITY RULING FOLDED (§2a) — the insight lifecycle and criterion matching are law, the computed counts' caveat lifts when the writers enforce it

**Satellite, proposal-first, outside the audit chain until Matthew grades it. Companion: the hundred-nineteenth inbox stamp. Nothing here builds until graded; the BANT set and the persona mechanics in particular are methodology and are his.**

**What this document is:** the design brief for the Process build — the charter's shape under existing law, the computed-state catalog, the persona-injection mechanics as proposed, the BANT assessment set as drafted, and the sandbox seed spec. Sources: the thirty-first stamp (charters share the pass), the 2 August Process ruling (one charter, merged corpus, module-segmented config, graceful absence), the glossary's Live Set and rubric-discovery entries, the 116th (read-before-write), and the prod capture in `aao-projection-surface-spm-om-v0_1.md`.

---

## 1 · What Process is, under law already ruled

One charter over one merged corpus: sales-process qualifiers and assessment questions are the same contract shape, discovered from org records (record-sourced, per rubric discovery — the package ships no question text). It adds its questions to the two comprehensive reads and its claims to the existing verify batches — never a new read. Its derivations run at the join, after persons, cards, and edges, **off our own ledger**. Stage scoping reads wide, writes gated. Unlicensed modules get graceful absence, and a read-permission failure is treated as absence with a configuration note, never an error.

**The two planes (the frame Matthew confirmed 19 August):**
- **Evidence plane** — what was *said* about process on the call: a date voiced, an approval described, a budget named, a step committed to. Rides the shared reads as pairs, verified blind by call 3, lands as claims with citations. Model cost: incremental questions on calls already made.
- **Computed plane** — what the *state of the deal* implies: derived arithmetic over rows we already wrote. Zero model calls, zero inference, exactly Coverage's law ("computed, never extracted"). Roll-ups per the glossary: deterministic, no citation, never an establishment.

The reads stay state-blind; the writers stay state-aware (116th). Nothing about Process changes either.

## 2 · The computed-state catalog · v0.1

Every Process-relevant dimension, classified. The rule of the catalog: **computed wherever computable; evidence only where words are the only source; honestly blank where neither** (no dismiss, no guess, UNVERIFIED is a lawful state).

**COMPUTED FROM THE LEDGER (no model, no callout):**
- Decision-maker identified on the map — yes/no from map rows carrying the role.
- Key players covered — count and share of map rows at each coverage band.
- Support distribution — counts by standing voiced state (ontology-direct, 101st); "do we have support from key people" is arithmetic over it.
- Buying committee shape — persons identified vs personas expected (the persona plane, §3): expected minus matched = the gap list.
- Insight completeness — obstacles/goals/pressures present per person and per deal, counts off the board. ~~GATED on the derived-entity identity ruling~~ **RULED 19 August (§2a): the lifecycle and match-forward law make these counts trustworthy arithmetic once the writers enforce it; until the writers land, the caveat stands as an implementation gap, not an open ruling.**
- Criteria coverage — criteria identified, formal vs informal, required-still-open, off `AAO_Criterion__c`.
- Stage-qualifier satisfiability of the computed kind — any qualifier whose truth is a map/board/criteria fact ("decision maker's goals known" = decision-maker row exists AND carries a goal card link) computes; the mapping from qualifier text to computable predicate is CONFIGURATION, seeded by us, org-overridable, never model-inferred at runtime.
- Recency/activity — trailing-window conversation facts, per the coverage law.

**EVIDENCE-ESTABLISHED (rides the shared reads):**
- Timeline and compelling event voiced (dates, deadlines, "must convert by Jan 28").
- Budget facts voiced (amount, holder, approval path as described).
- Need/problem confirmation in the buyer's words (already Problems' harvest; Process cites, never re-reads).
- Authority statements voiced ("I sign", "it goes to the council").
- Process steps committed aloud ("security review opens Monday").

**HONESTLY UNANSWERABLE (stays blank):**
- Anything the org's qualifier text demands that neither words nor ledger carry. Blank with reason, per the never-blank-where-evidence-establishes law's converse: never filled where nothing establishes.

**Where one qualifier needs BOTH planes** (e.g., "budget confirmed AND approver identified"): the conjunction computes over one evidence fact and one ledger fact; the conjunction itself is arithmetic.

## 2a · The derived-entity identity ruling · RULED (Matthew, 19 August, folded from the hundred-twenty-fourth stamp)

The open item that gated the board counts is closed. The law, in four lines:

- **Every insight card carries a lifecycle state: UNCONFIRMED → CONFIRMED → COMPLETED.** Born UNCONFIRMED at first establishment. CONFIRMED when it has come from **more than one person AND been mentioned more than once** — both conditions, computed from the card's own reinforcement trail, never model-judged. COMPLETED is the resolution state, a later surface's concern; the field exists from birth so the ledger never migrates.
- **Never duplicate cards.** A restatement — same insight, another mouth or another call — takes the STANDING card forward: reinforcement row, new citation, possible advance to CONFIRMED. Genuinely NEW substance mints a new card (the ruling's own example: a reiteration carrying new pilot details is a new insight; a bare restatement from a second mouth is the same card confirmed). The writer matches against the CLOSED LIST of the deal's standing cards at write time — read-before-write (116th) wearing its card coat; the match/new judgment is the model's at the write step with the standing faces in hand, never a blind mint. Wrong merges and wrong splits are cured by human edit, which beats the machine forever.
- **Criteria, same rule sharper:** a criterion voiced by a DIFFERENT mouth is the SAME criterion reinforced — match-not-mint against the deal's standing criterion list, name variance resolved at write time (this is F3's cure, and F3's open status retires). The SAME mouth restating the SAME criterion is IGNORED — no row.
- **Sequencing:** CODE implements the matching at the card and criterion writers when Process builds, behind the two-clean-runs gate — not before.

## 3 · Persona injection · proposed mechanics (Matthew's direction, 19 August)

**The law it extends:** read-before-write, one plane up — the map writer reads PROCESS state before writing people.

- **Definition source — ANSWERED by discovery (CODE, 19 August, `review/process/PERSONA-DISCOVERY.md`):** the vendor surface carries `ALTF__Relationship_Map_Persona__c` (Account required, NO Contact) with 12 org-configured persona values — **but nothing anywhere links a persona to a stage or process; the vendor cannot express "this stage expects these personas."** So the persona-to-stage EXPECTATION MAPPING is OURS, shipped as seed metadata, org-overridable, the already-ruled LAW #1 path — with the vendor persona values as the vocabulary it maps onto. **Keyed to stored values, never labels** (one org value is literally "Altify Program Owner" — the 76th stamp's label hazard on a new object).
- **Ghosts:** an expected-but-unmatched persona stands as an injected GHOST row. If the vendor map requires a Contact (it does: `ALTF__Contact__c` nillable=false), a ghost can never be a vendor map row — it is OURS, shadow-person-adjacent, surfaced as guidance ("your stage expects an Economic Buyer; none identified"). This also means ghosts are enumerable and purgeable by construction.
- **Per-run reconciliation, both directions:** (a) a newly identified person whose evidence matches a standing persona ghost ELIMINATES the ghost (match rules proposed at build: role establishment first, never title alone — titles resolve identity, never establish roles, standing law); (b) a process-state change (stage moved, qualifier unchecked) re-derives the expected set and may INJECT new ghosts. Reconciliation is computed — the expected set and the match are both ledger facts.
- **Persona-marking:** a map person matched to a persona carries the mark; a person on the map filling a persona without the mark is the reconciliation's own defect signal (Matthew's point, kept as the acceptance test's shape).

## 4 · The BANT assessment set · GRADED (Matthew, 19 August): FIFTEEN questions — four each for B/A/N, three for T — every one an INVERSION LAW

**Matthew's ruling:** each assessment question is a deal-killer test — the affirmative is what the deal needs, and NO deserves a RED FLAG. Sixteen was the conventional target; the graded set is FIFTEEN, because T3 failed the deal-killer bar and was moved rather than kept for symmetry — the inversion law grading its own instrument.

**The two lawful shapes of "no", under TRUE-or-nothing (no FALSE exists in this system):**
- **VOICED NO** — the customer affirmatively established the negative ("there is no budget this year"). That is an establishment in its own right, cited to the words: **hard red flag**, immediately, at any stage.
- **NEVER ESTABLISHED** — nothing voiced either way. Absence is not evidence, so it flags **only when process state says it should be known by now**: each question carries a BY-STAGE marker (seeded, org-overridable), and an unestablished deal-killer past its stage raises the red flag with the reason "unknown past <stage>". Before its stage, blank is lawful and quiet.

**Red flags are the flag taxonomy's first populated family** (Matthew's original item 5): `AAO_Flag__c` grows a Red/Deal-Killer type at the Process build, clearing the standing way — by evidence that establishes the affirmative, or by human override (absolute, as always). No dismiss.

**The persona coupling:** A1 (decision maker identified) is simultaneously an Authority assessment question and a persona-injection trigger — one computed fact, read by two planes. The Authority element generally is where assessment and the persona plane meet.

Straight methodology, one-way phrasing (TRUE-or-nothing: each asks for the affirmative establishment; absence stays blank). Criterion text + long question, the record-sourced pair.

**Budget:** B1 A budget exists for this purchase — *Has the customer stated that funds are allocated or available for this purchase?* · B2 The budget amount or range is known — *Has a figure or range been voiced by the customer?* · B3 The budget holder is identified — *Do we know, from the customer's words, who owns the funds?* · B4 The approval path for funds is understood — *Has the customer described how spending this budget gets approved?*

**Authority:** A1 The decision maker is identified — *Is the person who makes the final call identified on the map from their own or colleagues' words?* · A2 The decision maker is engaged — *Has the decision maker participated directly in a conversation with us?* · A3 The approval chain is understood — *Has the customer described who else must approve?* · A4 Access to the decision maker exists — *Can we reach the decision maker without a blocker, per the customer's words?*

**Need:** N1 A business problem is confirmed in the customer's words — *Has the customer stated the problem in their own words?* · **N2 (as graded) The problem is quantified — *Have the customer's problems been quantified?*** — estimates, user notes, and non-customer-mouthed impacts are ALLOWED, so N2 establishes from customer words OR from human-entered notes and estimates (the human-established path, `Established_By = HUMAN`, watermarked; the only question in the set whose affirmative does not require the customer's mouth) · N3 The consequence of inaction is stated — *Has the customer said what happens if nothing changes?* · **N4 (as graded) Does the need of the customer align? — *Has the customer confirmed that our solutions can resolve their problem?***

**Timeline:** T1 A target date exists — *Has the customer voiced a date or period for deciding or implementing?* · T2 A compelling event drives the date — *Is the date tied to something real that happens with or without us?* · **T3 DROPPED (Matthew, 19 August): buying-process steps are not a deal-killer and belong to the sales process, not the methodology** — the substance moves to the seed's qualifiers as a MUTUAL CLOSE PLANNING qualifier (§5), the separation law applied to the set's own draft · T4 The timeline is confirmed by the decision maker — *Has the decision maker, specifically, endorsed the timeline?*

Classification per §2: A1, A2, A4-partial, and the map-facts halves compute; the voiced halves are evidence; nothing here is inferable.

**Inversion reading, applied to all fifteen:** each question's red-flag pair is derived, never separately authored — B1 unmet = no budget exists (killer), N2 unmet past stage = unquantified need (killer), T2 unmet = no compelling event (killer), and so on. The BY-STAGE markers ship in the seed (proposal: B1/A1/N1/T1 by stage 2; the deeper four-per-element by stage 3; decision-maker-confirmed items by stage 4) — Matthew adjusts the mapping at grading.

## 5 · The sandbox seed spec (CODE, after R3/R5/R1, from this proposal once graded)

- **Sales process:** one process, "AAO New Business (Sandbox)", 4–5 stages adapted from the prod capture in `aao-projection-surface-spm-om-v0_1.md` (structure and shape from "New Business (Direct)"; TEXT REWRITTEN, never copied verbatim — prod's qualifier text is Altify's production methodology content and our seed is our own). Per stage: 3–5 qualifiers through the junction with Mandatory/Importance/sort set, at least one qualifier per stage deliberately COMPUTED-plane and one EVIDENCE-plane, so the catalog exercises both on the first run; **plus the MUTUAL CLOSE PLANNING qualifier carrying T3's dropped substance ("the steps between now and signature are described and shared") on the late stages — a qualifier, never an assessment question, per the grading.**
- **Assessment:** the fifteen BANT records per §4 as graded, as the org's assessment questions, discovered by rubric discovery like any customer's.
- Both are org data: watermarked as seed, survive purge (seeds stay), and rubric discovery — not the package — is what reads them, which is the whole LAW #1 point: the sandbox becomes a customer-shaped org.

## 6 · Prerequisites and order (ruled at the 119th)

CODE: R3 → R5 → R1 (with R4 riding R3) → seeds per §5 → the two-clean-runs gate (AUTHORIZED at the 124th) → Process build behind the closed gate. Design: this proposal graded by Matthew → charter fold. Matthew: ~~the derived-entity identity ruling~~ RULED (§2a), ~~the sixteen-total-vs-per-element confirmation~~ ANSWERED (fifteen as graded), §4 GRADED whole.

## 7 · Open questions, named

1. ~~Sixteen total or per element?~~ ANSWERED: sixteen total, four per element (19 August). 
2. ~~Persona definition home~~ ANSWERED: vendor persona object exists, stage linkage does not; the mapping is our seed metadata (19 August discovery).
3. Whether stage-qualifier computed-predicates ship as seed mappings only, or also as an admin-editable config surface at 3(d) — leaning both, same rows.
4. Does Process write any vendor assessment/qualifier ANSWER rows at v0.1, or project to our own surface only until the autonomy levels (3(d)) exist? Conservative default: our ledger only, vendor projection behind the same single-projection law as everything else — proposed, not assumed.
