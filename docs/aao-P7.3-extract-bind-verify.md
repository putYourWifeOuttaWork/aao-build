# §P7.3 · The Extract-Bind-Verify pass · v0.1 draft · 3 August 2026

> # SUPERSEDED · 3 August 2026
>
> **This file is SUPERSEDED by Charters v2.4 §P7.3, which is the authoritative pass shape. One live copy per truth: read `docs/aao-charters.md` §P7.3 and not this file.** It is kept, not deleted, because wrong or retired text is marked wrong and never removed — and because it is the record of what was filed at commit `cbaed19` before the fold. Nothing below this line may be cited as current. Where this text and Charters v2.4 §P7.3 differ, Charters wins on substance without argument.
>
> Marked at the direction of the CODE inbox re-stamped 3 August and Board v1.3 §1.

**Status: SUPERSEDED by Charters v2.4 §P7.3 (folded). Originally: drafted in session, to fold into Charters at its next bump as the successor to the per-person pass shape. Until folded, this file is the authoritative statement of the redesign and travels in the zip.**

## The ruling that opens this section

**The per-person pass shape is dead, ruled by Matthew, 3 August 2026.** One full transcript read per person cannot survive enterprise volume: seventeen people is seventeen reads of the same 18,700 tokens, and the measured call (16 propositions, 87,805 ms, 18,696 input / 7,339 output) showed input dominated by the artifact and output dominated by prose, both paid N times. The B&V baseline on that shape is **abandoned, not deferred** — a baseline of an untenable structure measures nothing worth keeping. Session 62 and the 3 August single-person measurement stand as history and cost data only. The harness seed's nothing-redesigned-mid-run rule is superseded by this ruling; the run it protected no longer exists.

## The pass, four stages

**Stage 1 · The read.** One call per Source. Strong model. Input: the whole normalized transcript, artifact-first. Output: an **inventory of potential claims** — for each charter-relevant statement: speaker, subject person, line anchor, minimal verbatim span, and the proposition families it plausibly touches. **No verdicts. No per-sentence quizzing.** The read is guided by the declared applicable set's proposition families, which is where the declared-set law binds first: the families in the prompt are exactly the declared charters' families, never the whole cabinet.

**Stage 2 · Binding.** Each inventory item is matched to its contracts: deterministically where the mapping is mechanical (person resolution via the identity ladder, family-to-contract fan-out), by a **small call** where judgment is needed. A binding call carries the span, the specific proposition, and nothing else — no transcript. Verdict: establishes / does not establish / insufficient. Binding is what promotes a Candidate to a Claim.

**Stage 3 · Verification.** The blind reader, **separate model, never the binder** (ruled 3 August: separate for now). Sees only the claim and its quoted evidence. Catches over-reading — the measured failure mode from Gate 1 — by coextension: subject, scope, quantity. **Runs on a significantly smaller model than stage 1** (ruled 3 August), because the judgment is low-inference: does this span carry this claim. **Quality gate attached to that ruling:** before the small model is trusted, one adjudicated comparison run against the strong model on the same claim set; if the small model passes over-reads the strong model catches, size up one notch and re-compare. The blind reader is not overhead; it is the second stage of the machine and, under the computable-first direction for Process and Assessment (T5, open), the feeder for downstream charters.

**Stage 4 · Unchanged.** Claims accumulate to Answers; projection writes; watermarks hold; the writer's query-then-branch stands; Option C notes, citation law, quotes on Answer rows only — all untouched. Nothing downstream of Claim moves.

## How this maps onto the three layers

The inventory **is** the Candidate layer doing the job its name implied: Candidate proposes, Claim records, Answer is what is true now. Binding is the promotion step. The complete ledger holds by construction: after binding, **Apex writes the abstention rows** for every proposition-person pair the inventory never touched — `nobody_said` where the read saw the person and no relevant statement, `model_missed` reserved for statements later shown to exist. Zero model cost for silence.

## The epistemics sentence, in the charter on purpose

An unextracted statement becomes a `model_missed` abstention rather than a directly probed answer. Extract-once trusts one family-guided pass for completeness; the residual is real and bounded, not zero. This is chosen, stated, and owned — the alternative (probing every proposition individually) is the shape this section retires.

## Rulings folding with this section, all Matthew's, 3 August

1. **Coverage is computed, never extracted.** Presence per occasion, occasion = scope + artifact hash per the movement law, counted deterministically per scope. Optional decay is config, parked, not designed. The coverage proposition family is deleted from every read.
2. **The evidence budget is ~90 tokens per finding, not ~30.** The span must stay coextensive — shortest span that still carries subject, scope, and quantity — and needs room to breathe. Quotes on Answer rows remain full-fidelity from the stored transcript; the budget governs model output, never stored evidence.
3. **Separate models for binding and verification.** Independence is the point: the checker never sees the binder's conclusion. Small model for verification per the ruling above, gated by the comparison run.
4. **For posterity: the direct Anthropic Named Credential is a dev-org stand-in** (flex credits cannot run in the dev org). The architecture's model path is and has always been the Einstein Trust Layer / Models API. Short synchronous calls are therefore the design target, and this pass shape is built for them: one bounded heavy read, then sub-second small calls.

## What is unverified, named

- Stage 1 read latency and output size at inventory grade (the read writes more than verdicts but no longer writes essays about silence) — first measurement.
- Small-model verification quality — the adjudicated comparison run.
- Net cost per Source versus the retired shape — estimate is order-of-magnitude better; the harness measures it.
- Call-two-onward cache behavior is mostly mooted (one read per Source), but stage 1 across Sources sharing a prompt prefix may still cache; report `cacheRead` anyway.

---

# CODE brief · rebuild the pass as Extract-Bind-Verify · supersedes the per-person split

**The per-person split is retired by ruling. Do not run the B&V baseline on it. Keep the code in history; nothing about it is a defect — the shape is.**

**What survives untouched:** fixtures (B&V and Emerson, as seeded), ingest, SHA-at-insert, dedup, roster resolution, the declared applicable set, `AAO_Rubric.inventory()` as inventory, the writer `AAO_Project`, the `AAO_TEMP_` invoker, the command center, byte-verification, the complete-ledger law, callout-before-DML.

**Build, in order:**
1. **Stage 1 extractor.** One call per Source, artifact-first, declared families in the tail. Output schema: array of `{speaker, subject_handle, line, span, families[]}` plus nothing else; hard `max_tokens`; JSON only. Subject handles go through the identity ladder exactly as ruled — the model matches against the closed candidate set it is handed and may say NONE or AMBIGUOUS.
2. **Binding.** Deterministic fan-out from families to the person's contracts in the declared set; one small call per candidate-contract pair needing judgment: `{span, proposition}` → `{verdict, reason}`. Terse schema, ~90-token evidence budget, no transcript.
3. **Verification.** Same call shape as binding, different model (smaller — pick the smallest available through the current credential and journal which), input is claim + span only, never the binder's verdict. Claims write only after verification passes; a verification fail writes the Candidate with its reason and no Claim.
4. **Abstention writer.** After binding, Apex writes the complete ledger's abstention rows per proposition per roster person, no model involvement.
5. **Transactions:** one callout per transaction stands. Stage 1 is one transaction per Source; stages 2–3 batch naturally many-per-transaction only if their combined time fits the 120 s cumulative budget with margin — measure one first, then choose the per-transaction group size from the measurement, not from hope.

**Measure and report, per stage:** elapsed ms, input/output tokens, `cacheRead`/`cacheCreate`, counts (inventory items, bindings attempted, claims established, verification rejections, abstentions written). The verification-rejection count is the over-read catch rate — that number is the blind reader earning its place or not.

**Then:** run B&V end to end on the new shape — that is the baseline now — then Emerson, then the run report with receipts for Matthew's adjudication against the 29 July recording.

**Open on design's side, not yours:** the small-model comparison gate (design will adjudicate); T5 computable-first Process/Assessment; the mentioned-but-absent tightening; persona cost. None of these blocks the build.
