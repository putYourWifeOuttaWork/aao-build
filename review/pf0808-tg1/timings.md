# Run `pf0808-tg1` · THE TIMING GATE · frozen Project Farma, source through projection, TIME ONLY

Fixture `projectfarma/2026-07-30-nf1`, sha `018cac1b` verified against the freeze list before
anything ran. Purged and rerun per the twenty-eighth stamp (the purge's counts are in the
README). **Run label: COLD** - first pass on the rebuilt pipeline, `cache_read=0` on call 0's
first attempt and on both reads, the model leg, and both verify batches. The one WARM number is
flagged where it occurs. No accuracy claims ride this run; eyeball plus the free trap assertions
only.

**WF-OpenText was not rerun, the twenty-eighth stamp's own option exercised: it is a shorter,
authored artifact through the identical pipeline stages, so it adds no timing information beyond
PF. Reported as the call, per the stamp.**

## The stages, one transaction each, reads in parallel

| stage | in-txn wall | model ms | SOQL | DML | CPU ms | cache_read | calls |
|---|---|---|---|---|---|---|---|
| call 0 · resolve (attempt 2) | 6,847* | 6,657 | 5 | 0 | 61 | **2,335 (WARM)** | 1 |
| read A (parallel) | 31,010 | 30,814 | 2 | 1 | 104 | 0 | 1 |
| read B (parallel) | 31,810 | 31,622 | 2 | 1 | 103 | 0 | 1 |
| **reads, wall together** | **33,347** | - | - | - | - | - | - |
| resolution · deterministic | **234** | **0** | 7 | 1 | 102 | - | **0** |
| resolution · model leg | 5,538 | 5,372 | 6 | 2 | 82 | 0 | 1 |
| call 3 · verify (2 keyed batches, 29 claims) | 52,487 | 52,257 | 1 | 1 | 154 | 0 | 2 |
| join | 4,747 | 0 | 63 | 73 | 1,450 | - | 0 |
| projection | 1,925 | 0 | 12 | 13 | 641 | - | 0 |

*Call 0's FIRST attempt (COLD) errored honestly: the model answered yes to opportunity content
and quoted nothing, and the charter's quote law threw rather than accept an uncheckable yes. The
second attempt resolved OPPORTUNITY → the Project Farma deal with its quote. Both attempts are
on the record; the failure is a model behaviour the parse law caught, not a pipeline defect, and
it cost one extra callout.

## The verdict against tonight's targets (twenty-ninth stamp, item 5)

- **End to end, in-org walls summed: ~105 s. Shell-to-shell including CLI process overhead:
  116 s.** Against the bands: past the acceptable 60-90, **under the 120 fail line. The gate
  PASSES the fail line and misses the acceptable band**, and the arithmetic below says exactly
  where the next 50 seconds live.
- **Model calls: 6** (call 0, read A, read B, one resolution leg, two verify batches) plus the
  one honest call-0 retry. The twenty-seventh stamp's arithmetic said five for PF's shape; the
  sixth is the verify splitting at the 30-claim keyed batch, not a per-pair loop.
- **Worst single callout: 31.8 s (read B)** against the 90-second per-call ceiling - comfortable,
  no split trigger fired.
- **Org-query and DML time, separately, the moved-cost line:** the deterministic resolution -
  the stage that replaced 59 callouts - spent **234 ms total (7 SOQL, 1 DML, 102 CPU ms)**. The
  join spent 4.7 s (63 SOQL, 73 DML), projection 1.9 s (12/13). The cost the rebuild moved into
  the org is ~7 seconds against the ~59 model seconds it deleted.
- **Negative obligations: held.** No per-pair callouts anywhere; batch=1 gone; the blank-retry
  guard retired at the rebuild; call 3 ran once, batched (two keyed batches of ≤30).

## Where the time is, so the next move is arithmetic

Verify is **52 s of the 105** - two sequential ~26 s batches. The reads proved batch-parallelism
works (31+32 ran in 33); the same parallelism on the two verify batches saves ~26 s → ~79 s. The
59-callout shape this replaced spent roughly 150+ s in call 2 alone at ~2.5 s per pair; the whole
rebuilt pipeline now costs less than the old call 2 did by itself.

## The last-run comparison, the number the diagnosis promised

| | pf0808-p1 (the 59) | pf0808-tg1 (rebuilt) |
|---|---|---|
| model callouts | 71 (1 + 4 + 59 + 5 batches + 2 retries) | **6 (+1 honest call-0 retry)** |
| identify/resolution model time | ~150 s across 59 txns | **5.5 s, one call, 2 designators** |
| deterministic resolution | - | 234 ms |
| transactions | 71 | 8 |

## The free trap assertions (twenty-eighth stamp item 5) and the byte layer

- **Demo-narration trap HELD: 0 fictional designators, 0 fictional people on the map.**
- **Bytes: 44 of 44 located quotes exact at offset; 3 of 3 designator introducing quotes
  byte-matched.**
- Regression: reports-only during the freeze; the seed is Emerson/BV-keyed, all N/A against
  this artifact, unchanged from pf0808-p1's disposition.

## Eyeball, not graded

Adam Pfeiffer (Supporter / Political Structure / Evaluator), Dan Lewis (Supporter / Evaluator,
re-created through the roster leg and this time CAUGHT by the create-leg record as MK-00000001),
Kayla Stanley (coverage), Rich correctly held off the map (his designator went through the model
leg, minted a subject, and his pairs were refused at verify). **The criterion name is live on
the vendor map: "Competitive pricing within budget" (Informal), with "Salesforce-native,
methodology-driven" held Partial and the collapsed placeholder retired.** The two-read shape
located 44 pairs where the four-family sweep found 59, with 14 merged as corroborated; what that
means for recall is the accuracy rerun's question and nobody pretends otherwise.
