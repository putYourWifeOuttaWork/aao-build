# em0808-a23 · stage timings and governors

Unit: milliseconds wall per callout, and governor consumption per stage, read at the end of the
stage in the same transaction as the work it measures. Ceiling 120,000 ms cumulative per
transaction, unraiseable, shared across certified managed namespaces.

Fixture `emerson/aspentech-2026-07-29-nf1`, sha `9e974006`, 19,774 chars, 3 speakers.

| stage | txn | callouts | wall | % of ceiling | SOQL | DML |
|---|---|---|---|---|---|---|
| call 0 · resolve | 1 | 1 | 9,600 | 8% | 5/100 | 0/150 |
| call 1 · Sentiment | 2 | 1 | 10,432 | 9% | 2/100 | 1/150 |
| call 1 · Political Status | 3 | 1 | 16,087 | 13% | 2/100 | 1/150 |
| call 1 · Buyer Role | 4 | 1 | 14,635 | 12% | 2/100 | 1/150 |
| call 1 · Decision criteria | 5 | 1 | 15,369 | 13% | 2/100 | 1/150 |
| call 2 · identify | 6 | 1 | **33,565** | **28%** | 4/100 | 1/150 |
| call 3 · verify, batch set 1 | 7 | 12 | 40,437 | 34% | 1/100 | 1/150 |
| call 3 · verify, batch set 2 | 8 | 12 | **49,852** | **42%** | 1/100 | 1/150 |
| call 3 · verify, batch set 3 | 9 | 4 | 13,739 | 11% | 1/100 | 1/150 |
| join | 10 | 0 | 3,045 (no callouts) | — | 38/100 | **46/150** |
| projection | 11 | 0 | 5,764 (no callouts) | — | 19/100 | 9/150 |

**WORST SINGLE CALLOUT: 33,565 ms** (call 2 identify) — 28% of the ceiling.
**WORST TRANSACTION: 49,852 ms** (call 3 batch set 2) — 42% of the ceiling.

The second number is the one that binds. Call 3 is caller-driven and stays inside by
construction; call 2 is a single callout and the worst single one on this run.

## Call 2 is now the worst single callout, and it was not before

| | a22 (44 pairs) | a23 (35 pairs) |
|---|---|---|
| call 2 wall | 18,627 ms | **33,565 ms** |
| pairs identified | 44 | 35 |
| output tokens | not recorded | 2,806 |

**Fewer pairs, nearly double the wall.** The measurement is one run against one run, so this is
recorded rather than explained. What is visible in the numbers: call 2's prompt carries every
located pair plus the candidate list, and this run's 35 pairs produced 2,806 output tokens
against a 12,252-token prompt. It is a single callout, so it can never be split the way call 1
and call 3 were; the only levers are batching pairs caller-side or shrinking what each pair
contributes to the prompt. **Named now because it is the one stage with no split available**,
and at 28% it is not yet a problem.

## Governors · the DML wall confirmed on a second fixture

| | a22 | a23 |
|---|---|---|
| eligible pairs | 18 | 10 |
| join SOQL | 55/100 | 38/100 |
| join DML | 81/150 | **46/150** |
| SOQL per eligible pair | ~3.1 | ~3.8 |
| DML per eligible pair | ~4.5 | **~4.6** |

**DML per eligible pair reproduces at ~4.6 on an unseen fixture**, so the ~32-pair join ceiling
is a property of the join and not of the training transcript. Nothing on this run approached it,
because this transcript is small. The caller-side join split stands as the queued lever and is
now measured twice rather than once.

Nothing on this run passed 80% of any governor. No stage flagged.

## Blank-retry guard

**Zero invocations.** All four families answered on the first look (6, 12, 9, 8). Reported as a
measured zero, not as silence.

## Token usage per stage, for the cost model

| stage | input | output | cache read | cache write | thinking |
|---|---|---|---|---|---|
| call 0 · resolve | 9,198 | 577 | **0** | 2,564 | 167 |
| call 1 · Sentiment | 8,882 | 678 | **0** | 3,093 | 89 |
| call 1 · Political Status | 8,882 | 1,368 | **0** | 3,982 | 0 |
| call 1 · Buyer Role | 8,882 | 1,201 | **0** | 3,615 | 224 |
| call 1 · Decision criteria | 8,882 | 1,279 | **0** | 3,320 | 307 |
| call 2 · identify | 12,252 | 2,806 | **0** | 1,698 | 626 |
| call 3 · verify (28 calls) | ~24 per call | ~100 per call | **0** | ~880 per call | 0 |

**CACHE READ IS ZERO ON EVERY CALLOUT AND CACHE WRITE IS NONZERO ON EVERY CALLOUT.** See the
cost-per-pass entry in BUILD_JOURNAL. The four family reads send the same 19,774-char artifact
four times, at 8,882 input tokens each, and the cache written by the first read is never read by
the second.
