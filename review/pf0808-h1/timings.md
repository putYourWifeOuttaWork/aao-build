# Run `pf0808-h1` · THE HALVING · verify parallelized, the cache reorder built, ~57 s in-org

Fixture `projectfarma/2026-07-30-nf1`, sha `018cac1b`, purged and rerun on the thirtieth stamp's
build. **Run label: COLD** on the reordered/parallel-verify code; `cache_read=0` on the parallel
trio for the mechanical reason below, and the cache win measured separately in a sequential
probe. **Target ≤60 s (stretch 50). Result: ~57 s in-org critical path, ~66 s shell-to-shell.**

## The concurrency graph and the walls

```
{ call 0  ∥  read A  ∥  read B }  →  resolution (+model leg)  →  { verify plain ∥ verify sentiment }  →  join → project
```

| stage | in-txn wall | model ms | SOQL | DML | cache_read | in_tok | out_tok |
|---|---|---|---|---|---|---|---|
| call 0 (∥) | 4,771 | 4,674 | 5 | 0 | 0 | 24,057 | 232 |
| read A (∥) | 27,001 | 26,821 | 2 | 1 | **0** | **3,220** | 2,439 |
| read B (∥) | 26,915 | 26,715 | 2 | 1 | **0** | **3,220** | 2,556 |
| **stage A wall (max)** | **~27,000** | | | | | | |
| resolution · deterministic | 283 | 0 | 8 | 1 | - | - | - |
| resolution · model leg | 3,916 | 3,758 | 6 | 1 | 0 | 2 | 124 |
| verify · plain (∥, 22 claims) | 20,828 | 20,708 | 1 | 1 | 0 | - | - |
| verify · sentiment (∥, 6 claims) | 11,590 | 11,475 | 1 | 1 | 0 | - | - |
| **verify stage wall (max)** | **~20,828** | | | | | | |
| join | 2,859 | 0 | 59 | 68 | - | - | - |
| projection | 1,669 | 0 | 12 | 9 | - | - | - |

**In-org critical path: ~27.0 (stage A) + ~4.2 (resolution) + ~20.8 (verify) + ~4.5 (join+project)
= ~56.5 s.** Shell-to-shell 66.2 s carries ~9 s of CLI process spin-up across the orchestration
points that a production queueable chain does not pay.

## The two halving moves, measured

**1 · Verify parallelized: 52.5 s → 20.8 s.** The two conjunct buckets now run in concurrent
transactions (plain 20.8 s ∥ sentiment 11.6 s), where tg1 ran them sequentially and summed.
**The stamp's question answered: the split is CONJUNCT-HOMOGENEITY, not size.** The target field
binds sentiment and nothing else, so a sentiment claim and a Buyer Role claim can never share one
schema; the multi-batch shape is permanent whenever a run carries both kinds, and parallelism is
the whole fix. `AAO_Pass.verify(runKey, bucket, shardCount, shardIndex)` also shards a bucket
further, so a bucket that would cross the 90-second trigger drives as concurrent shards.

**2 · call 0 hidden under the reads.** The reads do not consume call 0's scope verdict, so call 0
(4.7 s) runs concurrently with them and costs nothing on the critical path. tg1 paid it serially.

## The cache reorder: measured, and the finding reported rather than buried

The transcript now LEADS every read, carrying the cache breakpoint, so the ~23,800-token artifact
is the cached prefix instead of the ~2,000-token rubric that led before. **The evidence it works:
`in_tok` on both reads dropped from 23,804 (tg1) to 3,220 - the artifact moved into the cache
segment, and only the uncached rubric is billed as fresh input.**

**But `cache_read=0` on the parallel reads, and that is mechanical, not a failure:** prompt caching
matches the whole prefix INCLUDING the system message, so only two reads (same system, same
rubric, same artifact) can share a prefix - and running them in parallel, neither finishes writing
the cache before the other starts, so neither reads it. Call 0 and verify carry different system
prompts and cannot share the reads' prefix at all.

**The token win is real and here it is, from a sequential control** (`cache_probe`, two identical
artifact-first reads back to back, no DML):

```
PROBE call A   in_tok=3220   cache_read=27436   ms=24955
PROBE call B   in_tok=3220   cache_read=27436   ms=27199
```

**27,436 cached tokens per reusing call - ~88% of a read's input at ~10% of the price.** (Call A
already read 27,436 because the halving run's reads had written that exact prefix inside the
5-minute TTL.) The wall benefit is small (reads are output-bound, ~2,500 tokens), so the reorder
is a TOKEN lever, which is exactly the "token halving that protects 10k/day." **The honest caveat:
under perfectly-simultaneous parallel reads the win is not captured within a run and each read
pays cache-creation once (1.25x) for a prefix it does not read; it pays under any serialization
(production concurrency-limited) and under any stagger, and the probe shows the artifact stays
warm across the run.**

## Against tonight's targets

- **≤60 s target: MET** at ~57 s in-org. **50 s stretch: one lever away** - sharding the 22-claim
  plain bucket into two concurrent shards (`shardCount=2`) takes verify from ~21 s to ~11 s, which
  is ~47 s critical path. The shard mechanism is built and deployed; not driven this run to keep
  the run a clean two-move comparison.
- **Model calls: 6** (call 0, read A, read B, one resolution leg, two verify buckets), no retry
  this run. Worst callout 27.0 s (read A) against the 90 s ceiling.
- **Negative obligations held**: no per-pair callouts, no batch=1, blank-retry guard retired,
  verify batched. No stage crossed the 90 s split trigger.

## The looks-right standard (thirtieth stamp item 3) and the free traps

- **Bytes 41/41 exact; designator introducing quotes 4/4.**
- **Demo-narration trap HELD: 0 fictional designators, 0 fictional map rows.**
- **The Buyer Role note fix is live**: Dan's note now reads "Buyer Role: Evaluator - Dan Lewis,
  30 July 2026" - every dimension line carries its citation. Adam's multi-role collision renders
  its refusal note correctly.
- Named criteria projected by name persist ("Competitive pricing within budget"); ledger 41/41/28
  HELD; regression N/A under the freeze.

## The standing caveat, one line (thirtieth stamp item 3)

The three runs disagree on identical bytes - Adam reads Supporter/Inner Circle/no-role here,
Supporter/Political-Structure/Evaluator on tg1, Supporter/Decision-Maker on p1; Dan is Supporter
here and on tg1, Non-Supporter on p1. At most one map is right. That adjudication is the accuracy
rerun's (Matthew grades tg1 against Pass 1), and it does not block the halving work.
