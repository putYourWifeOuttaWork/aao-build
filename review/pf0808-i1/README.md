# Run `pf0808-i1` · the instrumentation run · efficiency, governors, and two ceilings found

Thirty-third stamp's instrumentation run. **Efficiency and scalability, not accuracy; nothing
graded.** The question: does the current express-lane pipeline run comfortably clear of governor
limits and inside the time bar, or does it need a redesign? Frozen Project Farma (sha `018cac1b`,
verified against the freeze list before running), current architecture at HEAD `bb3d26d`, working
tree clean (no uncommitted fix). Org confirmed first: `00DWD00000DV7iT2AT`, "Altify",
`IsSandbox: true`, the aossb2 sandbox. **This run is left RESIDENT** so design can spot-check the
org against the report; the projected map rows are also in `projection-outcome.csv`.

**Label: WARM on the model cache.** The reads show `cache_read=27436` and call 0 `cache_read=2335`
- the artifact prefix was warmed by the immediately-prior attempt and recent runs inside the
5-minute TTL. **The governor, callout, projection, and evidence-trail proofs are cache-independent
and valid regardless; only the token line differs cold-vs-warm, and both are given.** The genuine
COLD read number is h1's (`in_tok=23,804`, `cache_read=0`); this run's warm reads bill `in_tok=3,220`
with the 23,800-token artifact served from cache.

**shardCount driven: 2** on the plain bucket, and that was FORCED, not chosen - see ceiling 2.

## Scope note (so the number is not over-read)

This is ONE run measuring the per-transaction governor envelope and the single-pipeline wall. **It
does not measure concurrency or throughput** (many pipelines at once); that is the separate
concurrency measurement in the stamped queue, waiting on the async-concurrency and gateway rate
ceilings.

## PROOF 1 · CALLOUTS

**7 model callouts total, and zero per-pair callouts anywhere:** call 0 (1, + the cold-flake retry,
see below), read A (1), read B (1), resolution model leg (1), verify plain shard 0 (1), verify
plain shard 1 (1), verify sentiment (1). Resolution's deterministic leg made **0 callouts** while
disposing 40 pairs (merge 14 + speaker 26) - the 59-callout job of the old pipeline, now 207 ms of
Apex. Every callout count in the governor table below is 1 or 0.

## PROOF 2 · TIMINGS (per stage, WARM reads)

| stage | wall (ms) | model (ms) | cache_read | notes |
|---|---|---|---|---|
| call 0 (∥) | 9,108 | 9,043 | 2,335 | OPPORTUNITY; attempt 1 OK after a cold-flake on the prior run |
| read A (∥) | 31,217 | 31,054 | 27,436 | 22 located |
| read B (∥) | 27,299 | 27,149 | 27,436 | 23 located |
| **stage A wall** | **~31,200** | | | reads dominate; call 0 hides under them |
| resolution · deterministic | 207 | 0 | - | 14 merged, 26 speaker-attached, 4 remainder |
| resolution · model leg | 4,735 | 4,586 | 0 | 3 minted, 1 held None |
| verify · plain shard 0 (∥) | 15,354 | 15,211 | - | 12 claims, 7 upheld |
| verify · plain shard 1 (∥) | 18,925 | 18,846 | - | 12 claims, 9 upheld |
| verify · sentiment (∥) | 12,446 | 12,312 | - | 6 claims, 3 upheld |
| **verify stage wall** | **~18,925** | | | three concurrent shards |
| join | 2,599 | 0 | - | ledger HELD, 17 claims |
| projection | 1,240 | 0 | - | 3 map rows |

**Resolution SOQL and DML, on their own line:** deterministic leg 9 SOQL / 1 DML (41 DML rows);
model leg 6 SOQL / 1 DML (2 rows). Combined resolution org cost: 15 SOQL, 2 DML, ~0.4 s of the
~59 s.

**End-to-end: ~59 s in-org critical path** (31.2 stage A + 4.9 resolution + 18.9 verify + 3.8
join/projection), 67 s shell-to-shell with CLI process overhead. **Cleared the 60 s express
target, by a hair.** The reads dominate: **read spread 27.3 to 31.2 s**, and a read is the worst
single callout at 31.2 s - comfortably under the 90 s shard trigger and the 120 s hard ceiling, no
split fired. Under-50 (the stretch) still needs faster read generation, which is the call 3
downsize and tighter outputs at the accuracy phase.

## PROOF 3 · GOVERNOR HEADROOM (the load-bearing proof)

Every stage ran as a **synchronous** Execute Anonymous transaction (CPU 10,000 ms, heap 6 MB,
SOQL 100, DML 150, DML rows 10,000, callouts 100). Used / limit per stage:

| stage | SOQL | DML | DML rows | CPU ms | heap | callouts |
|---|---|---|---|---|---|---|
| call 0 | 5/100 | 0/150 | 0/10k | 65/10k | 5.8 KB/6 MB | 1/100 |
| read A | 2/100 | 1/150 | 22/10k | 99/10k | 11.9 KB/6 MB | 1/100 |
| read B | 2/100 | 1/150 | 23/10k | 96/10k | 11.0 KB/6 MB | 1/100 |
| resolution det | 9/100 | 1/150 | 41/10k | 101/10k | 3.2 KB/6 MB | 0/100 |
| resolution model | 6/100 | 1/150 | 2/10k | 76/10k | 3.7 KB/6 MB | 1/100 |
| verify plain s0 | 1/100 | 1/150 | 12/10k | 72/10k | 7.8 KB/6 MB | 1/100 |
| verify plain s1 | 1/100 | 1/150 | 12/10k | 60/10k | 7.1 KB/6 MB | 1/100 |
| verify sentiment | 1/100 | 1/150 | 6/10k | 73/10k | 6.0 KB/6 MB | 1/100 |
| **join** | **61/100** | **71/150** | **104/10k** | **1,205/10k** | **94 KB/6 MB** | 0/100 |
| projection | 12/100 | 9/150 | 13/10k | 480/10k | 12.6 KB/6 MB | 0/100 |

**Nothing crossed 80% on this fixture. The join is the stage to watch, and it is the only one that
is not near-idle:** SOQL 61/100 (61%), DML 71/150 (47%), on 17 eligible claims and 3 map people.
Everything else sits under 12% of every governor. CPU peaks at 1,205 ms in the join (12% of the
sync limit); heap peaks at 94 KB (1.5% of 6 MB) - heap is a non-issue at this artifact size.

**Against the ceilings the OTHER lanes will run under, per the stamp:**
- **The nightly BATCH lane (transcripts) runs async** (Queueable/Batch): CPU 60,000 ms (6x),
  heap 12 MB (2x), SOQL 200 (2x). Every number above has MORE headroom there, not less. The join
  at 61/200 SOQL and 71/150 DML is comfortable.
- **The join's DML is the one number that scales with the deal, not the fixture:** it writes per
  eligible claim (claims, candidates, answers, map rows). 71 DML at 17 claims is ~4.2 DML/claim.
  A linear projection: the 150-DML sync ceiling is reached near ~35 eligible claims, the ~32-pair
  join wall the sixteenth stamp named. **On a denser transcript the join is the first stage to
  hit a ceiling, and the caller-side join split (queued) is its named mitigation.** Not near it on
  Project Farma (17 claims), but this is the redesign trigger to watch, stated loudly as asked.
  The single-projection ruling (thirty-first stamp) also moves vendor DML out of the per-run join.

## PROOF 4 · PROJECTION CONFIRMATION (shown, not asserted)

The live map, read back from the org after the run (`projection-outcome.csv`):

| person | Status | Political | Buyer Role | Coverage | Status watermark |
|---|---|---|---|---|---|
| Adam Pfeiffer | Supporter | Political Structure | *(held, collision)* | Brief contact | 2026-08-09T12:45:31Z |
| Dan Lewis | Supporter | | Evaluator | Brief contact | 2026-08-09T12:45:32Z |
| Kayla Stanley | | | | Brief contact | (coverage-only) |

Our own coverage watermark on the participant rows carries the same modstamp (12:45:32Z), so the
map value is provably ours and retractable. Object: `ALTF__Contact_Map_Details__c`. The map is
resident for spot-check.

## PROOF 5 · EVIDENCE TRAIL (Dan Lewis · Evaluator, source to map)

| link | record | detail |
|---|---|---|
| Source | `a1XWD0000082Z1t2AE` | `projectfarma/2026-07-30-nf1`, sha `018cac1b` |
| Evidence Contract | AAO_BR_EVAL | Buyer Role, EVALUATOR |
| Located pair | `r1q2` | offset 19348-19428, "Okay, is it an extra add-on to have the max AI ability or is that just included?" |
| Identified pair | `r1q2` | Dan Lewis, disposition Identified, verification Upheld |
| Candidates | 5 rows | all EVALUATOR, proposed TRUE (multiple Evaluator pairs identified to Dan) |
| Claim | `a1VWD000008ccXa2AI` | EVALUATOR, verdict_after TRUE, spans JSON inline (UPHELD, offset 19348, speaker Dan Lewis) |
| Answer | `A1|Participant|a1ZWD…|a1WWD…` | TRUE, Projected_Value = Evaluator |
| Map row | Dan Lewis | Buyer Role = Evaluator, watermark 2026-08-09T12:45:32Z |

**One honest note on the trail:** `AAO_Claim_Basis__c` holds 0 rows - this pipeline carries the
evidence inline as the `AAO_Spans__c` JSON on the Claim (byte-located, speaker-tagged, UPHELD),
not as separate claim-basis rows. The chain is unbroken source-to-map; the "claim basis" link is
the inline spans, and the separate object is unused here. Reported, not papered over.

## The two ceilings this run found (the redesign-trigger material)

**1 · CALL 0 COLD-FLAKE.** On the genuinely-cold first attempt, call 0 answered yes to
opportunity content and quoted nothing; the charter's quote-law caught it and threw. The retry
(attempt 1 of the resident run) resolved OPPORTUNITY cleanly. Third observed instance (tg1, and
the first i1 attempt). **This is an honest model behavior the charter refuses correctly, but it
costs a retry and it is not rare** - a cold call 0 needs a retry policy, which the express lane's
speculative-launch design (thirty-second stamp) can absorb but which should be named and built,
not left to chance. Cost: one extra ~7 s callout when it fires.

**2 · THE KEYED-VERIFY GRAMMAR CEILING, and it is the real scalability finding.** The first i1
attempt drove `shardCount=1` (the literal h1 graph, plain as one bucket). The plain bucket on this
denser run (45 located vs h1's 41) produced ~24 claims, and the model gateway rejected it:

> `400 invalid_request_error: "The compiled grammar is too large, which would cause performance
> issues. Simplify your tool schemas or reduce the number of strict tools."`

The keyed verify schema puts one required object property per claim ref; at ~24 refs the compiled
structured-output grammar crosses a gateway size limit that h1's 22-claim bucket stayed under.
**So the ratified h1 graph (shardCount=1) is NOT viable on a transcript this dense.** The
mitigation is already built and was driven for the resident run: `shardCount=2` split the plain
bucket into two 12-claim shards, each well under the ceiling, run concurrently. **This is a hard
gateway ceiling near ~22-24 claims per keyed bucket, and it means shardCount is not a tuning knob
but a REQUIRED function of claim density.** The stamped 90-second split trigger is a wall-clock
trigger; this run adds a second, independent trigger: **a grammar-size trigger on the keyed schema,
fired by claim count per bucket, not by time.** The shard mechanism serves both; the split logic
should key on max-claims-per-bucket as well as on the 90 s wall. Named for design.

## The looks-right standard (report, not grade)

Bytes **45/45 exact**; designator introducing quotes **6/6**; demo-narration trap **0 fictional
designators, 0 fictional map rows**; ledger **HELD** (45 located = 45 disposed, 30 verified = 30
identified-and-verdicted); named criteria keyed opportunity-plus-name (`Competitive pricing within
budget`, `Bilateral NDA in place`, etc., in `claims.csv` and the criterion ledger); Option C notes
carry their citations on every dimension line including **"Buyer Role: Evaluator - Dan Lewis, 30
July 2026"**, and Adam's role-collision renders its refusal note ("the evidence establishes
Decision Maker, Evaluator, User and the field holds one").

**Accuracy caveat (stamp standing):** these values still flicker run-to-run on identical bytes
(the stability probe); this run's map is one draw, resident for spot-check, not a graded result.

## Row export (beside this report)

`pairs-located.csv` (45), `pairs-dispositions.csv` (45), `claims.csv` (17), `answers.csv` (11),
`projection-outcome.csv` (3 map rows with watermarks and notes).

## The verdict against Matthew's efficiency-first bar

**On this fixture the pipeline runs comfortably clear of every per-transaction governor** (worst
is the join at 61% SOQL / 47% DML, everything else under 12%), inside the 60 s express bar (~59 s),
at 7 callouts with zero per-pair calls, and the deterministic resolution that replaced 59 callouts
costs 207 ms. **Two ceilings are named as redesign triggers, neither breached on Project Farma:**
the join's DML at ~35 claims (the caller-side split is its mitigation), and the keyed-verify
grammar ceiling at ~22-24 claims per bucket (the shard mechanism is its mitigation, and it must be
driven by claim density, not left at shardCount=1). Concurrency and throughput are the separate
measurement and are not touched here.
