# CODE inbox · re-stamped LAST, 3 August 2026, end of the redesign session

**Read this, then `docs/aao-board.md` (v1.3). The pass is Charters v2.4 §P7.3. Numbers from your BUILD_JOURNAL.**

## One focus
Build the Extract-Bind-Verify pass per §P7.3's brief (already in your repo at commit `cbaed19`; **mark that standalone spec file superseded by Charters v2.4 §P7.3** — one live copy per truth). Then B&V on the new shape — that is the baseline — then Emerson, then the run report with receipts.

## Rulings since your last context, each one line
1. **Per-person shape retired; §P7.3 is the pass.** B&V baseline on the old shape abandoned, not deferred.
2. **Separate models for binding and verification; verification on the smallest available model through the current credential — journal which.** Gated later by design's adjudicated comparison; build now, gate before trust.
3. **Coverage is computed, never extracted** — you verified the build already satisfies this; nothing to do.
4. **Evidence budget ~90 output tokens per finding**, coextension-justified. Stored quotes stay full-fidelity.
5. **`model_missed` is a reported per-run rate** — your flag, accepted into §P7.3.
6. **One callout per transaction stands. Group sizes for stages 2–3 are measured, never assumed** — time one small call first.
7. **For posterity, journaled at Architecture v3.3:** the direct Anthropic Named Credential is a dev-org stand-in; the model path is and always was the Einstein Trust Layer. Short synchronous calls are the design target §P7.3 is built for.

## Report per stage
Elapsed ms, input/output tokens, `cacheRead`/`cacheCreate`, counts: inventory items, bindings attempted, claims established, **verification rejections** (the over-read catch rate — the blind reader earning its place), abstentions written, **`model_missed` rate** at adjudication.

## Standing, unchanged
Production read-only unconditionally. LAW #1. Nothing of ours on native or ALTF objects. Capability claims unverified until tried from the calling runtime. Expected failure mode: over-reading, never fabrication. Defects are yours to fix, design's to record. `findings=1` rides into the new shape as a named, unexplained question — report it, don't diagnose it alone.

## Sequence out
B&V baseline → Emerson run → report → Matthew adjudicates against the 29 July recording (his blind notes are frozen first, design's job) → design folds the adjudication record → resolver build (Matthew's hard law: resolver next, before Politics).
