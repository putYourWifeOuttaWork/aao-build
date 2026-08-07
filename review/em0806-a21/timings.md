# em0806-a21 · stage timings

Unit: milliseconds, wall per callout. **The sweep is split caller-side now**, one family read
per transaction, so the binding number moved.

| stage | transaction | callouts | cumulative | worst single |
|---|---|---|---|---|
| call 0 · resolve | 1 | 1 | 11,719 | 11,719 |
| call 1 · Sentiment | 2 | 1 | 14,223 | 14,223 |
| call 1 · Political Status | 3 | 1 | 16,134 | 16,134 |
| call 1 · Buyer Role | 4 | 1 | **16,626** | **16,626** |
| call 1 · Decision criteria | 5 | 1 | 13,091 | 13,091 |
| call 2 · identify | 6 | 1 | 15,877 | 15,877 |
| call 3 · verify, batch 1 | 7 | 12 | ~50,000 | caller-driven |
| call 3 · verify, batch 2 | 8 | 12 | ~49,000 | caller-driven |
| call 3 · verify, batch 3 | 9 | 12 | ~70,000 | caller-driven |
| join | 10 | 0 | no callouts | — |
| projection | 11 | 0 | no callouts | — |

**WORST SINGLE CALLOUT: 16,626 ms** (call 1, Buyer Role) — 14% of the 120,000 ms ceiling.

**WORST TRANSACTION: 16,626 ms** — the same number, and that is the point of the split.

## What the split bought

| | a20, one transaction | a21, split |
|---|---|---|
| call 1 worst transaction | **57,054 ms · 48%** | **16,626 ms · 14%** |
| headroom for a fifth family | none | unchanged |

The ceiling is cumulative per transaction, unraiseable, and shared across certified managed
namespaces. Before the split, twice this transcript or a fifth family breached it. After it,
the binding number is the worst single read and **the account grain's future families cost no
ceiling anxiety** — which is exactly what the ruling predicted.

**Call 3 is now the widest transaction** at roughly 70 s for a twelve-claim batch, and it is
already caller-driven so the batch size is the lever. Its per-callout figures are shell
wall-clock rather than measured per call, because `AAO_Pass.verify` keeps only the last
`StageResult`; the run receipt (§P8.0) is what would carry them and is still owed.

## A limit that is not the callout ceiling

**The join finished at SOQL 100 of 100.** It reads per pair by design — each is a
read-then-branch against standing state — and seventeen eligible pairs consumed the whole
governor. **This breaks before the callout ceiling does** on a denser transcript, and it is a
different ceiling with a different fix (bulkify the join's reads, or split it caller-side the
way call 1 and call 3 already are). Named rather than discovered at twenty-five pairs.
