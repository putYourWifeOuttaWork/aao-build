# em0806-a20 · stage timings

Per Addendum 20 and the 6 August inbox. Unit: milliseconds, wall per callout.

| stage | callouts | cumulative | worst single | each |
|---|---|---|---|---|
| call 0 · resolve | 1 | 7,434 | 7,434 | 7434 |
| call 1 · sweep (one transaction) | 4 | **57,054** | 15,580 | 14036, 14886, 15580, 12552 |
| call 2 · identify | 1 | 14,975 | 14,975 | 14975 |
| call 3 · verify, batch 1 | 12 | ~66,000 | — | caller-driven, 12 callouts |
| call 3 · verify, batch 2 | 12 | ~65,000 | — | caller-driven, 12 callouts |
| call 3 · verify, batch 3 | 9 | ~49,000 | — | caller-driven, 9 callouts |
| join | 0 | — | — | no callouts, DML only |
| projection | 0 | — | — | no callouts, DML only |

**WORST SINGLE CALLOUT: 15,580 ms** (call 1, Political Status) — 13% of the 120,000 ms
ceiling. Comfortable, and it is not the number that binds.

**WORST TRANSACTION: 57,054 ms** (call 1's sweep, four callouts in one transaction) — **48% of
the ceiling.** The ceiling is cumulative per transaction, unraiseable by Support, and shared
across certified managed namespaces like CPU and heap. That is the number to watch.

**What breaks it first.** The sweep is four reads of the whole artifact in one transaction, so
its cumulative wall scales with transcript length and with the number of declared families. A
transcript twice this one's length, or a fifth family, puts it at or past the ceiling. Call 3
is already caller-driven for exactly this reason and stays inside by construction; call 1 is
not split and would have to be.

**Call 3's batch figures are wall-clock from the driving shell, not per-callout**, and are
marked approximate rather than presented as measured. The per-callout numbers for call 3 exist
inside the transaction and are not returned by `AAO_Pass.verify`, which keeps only the last
`StageResult`. Naming it rather than rounding it: the run receipt (§P8.0) is what would carry
per-callout timings across transactions, and it is still owed.
