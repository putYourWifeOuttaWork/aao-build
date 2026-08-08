# pf0808-p1 · Project Farma · stage timings and governors

Unit: ms wall per callout, governors per stage. Ceiling 120,000 ms cumulative per transaction.
Fixture `projectfarma/2026-07-30-nf1`, sha `018cac1b`, 70,771 chars NF1, 5 speakers, 73 minutes.
**The corpus's first long real transcript**, and the one that found call 2's ceiling.

| stage | txn | callouts | wall | % ceiling | SOQL | DML |
|---|---|---|---|---|---|---|
| call 0 · resolve | 1 | 1 | 10,510 | 9% | 5/100 | 0/150 |
| call 1 · Sentiment | 2 | 1 | 15,459 | 13% | 2/100 | 1/150 |
| call 1 · Political Status | 3 | 1 | **22,272** | **19%** | 2/100 | 1/150 |
| call 1 · Buyer Role | 4 | 1 | 20,853 | 17% | 2/100 | 1/150 |
| call 1 · Decision criteria | 5 | 1 | 13,452 | 11% | 2/100 | 1/150 |
| call 2 · identify | 6–64 | 59 | ~2–3k each | small | 3/100 | 1/150 |
| call 3 · verify batch 1 | 65 | 12 | 41,151 | 34% | 1/100 | 1/150 |
| call 3 · verify batch 2 | 66 | 12 | 54,565 | 45% | 1/100 | 1/150 |
| call 3 · verify batch 3 | 67 | 12 | **62,224** | **52%** | 1/100 | 1/150 |
| call 3 · verify batch 4 | 68 | 12 | 45,107 | 38% | 1/100 | 1/150 |
| call 3 · verify batch 5 | 69 | 9 | 31,910 | 27% | 1/100 | 1/150 |
| join | 70 | 0 | 2,826 | - | 53/100 | 65/150 |
| projection | 71 | 0 | 2,897 | - | 12/100 | 8/150 |

**WORST SINGLE CALLOUT: 22,272 ms** (call 1 Political Status) - 19% of ceiling. The family reads
scale with transcript length: 3× a23's chars gave ~1.4× the worst read, so a 73-minute call is
comfortable per-callout but the largest input the sweep has seen.

**WORST TRANSACTION: 62,224 ms** (call 3 batch 3) - 52% of ceiling. Call 3 stays inside by
construction; this is the closest any transaction has come to the wall, and a denser call would
want smaller verify batches.

## Call 2 · the ceiling this fixture discovered

**Call 2 is the one stage handed every located pair at once, and on 59 pairs of real speech it
returned ONE disposition and stopped at end_turn - twice, and again at batch 15, 6, and 3.** Only
batch=1 returned reliably. See the README; the finding is the run's headline, not the timings.
Because DML cannot precede a callout in one transaction, batch=1 means one identify per
transaction, which is why call 2 shows 59 transactions here. **This is a workaround to reach a
map, not the fix.**

## Governors · the join wall held on a dense real call

DML 65/150 at 15 eligible pairs (~4.3/pair), SOQL 53/100. The ~32-pair join wall was not
approached because only 15 pairs were eligible (42 refused, 2 unidentified). Nothing flagged 80%.

## Cost, on the first long real transcript

Call 1's four reads sent 70,771-char artifacts at ~23,800 input tokens each. Call 2 at batch=1
sent 59 small prompts. Cache read zero on every callout, unchanged: the prefix reorder is still
queued. A per-minute cost figure on real speech is now available from these timings and is owed
in the cost journal.
