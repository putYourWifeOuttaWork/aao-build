# The purge ran. The rerun is BLOCKED at call 2, and Project Farma is currently bare · 13 August 2026

**Read this first: Project Farma has no map rows and no cards right now.** The purge did exactly
what it is built to do and the rerun stopped four stages in, so the deal sits between the two. It
cannot be restored by hand — the harvest it would be restored from is what the purge removed — so it
stays bare until call 2 is fixed and the pass finishes. That is a worse state than before the purge,
and it is stated first because it is the thing that matters most.

Run key `pf0813-uphold`. **The located pairs are banked (67), so calls 0 and 1 are already paid for
and a resumed run starts at stage 4.**

---

## 1 · What ran, and what it cost

| stage | wall | calls | SOQL | DML | cache | produced |
|---|---|---|---|---|---|---|
| call 0 resolve | 11.596 s | 1 | 5/100 | 0/150 | COLD | scope OPPORTUNITY, deal d1 |
| call 1 locate read 1 | 40.676 s | 1 | 2/100 | 1/150 | COLD | 32 located |
| call 1 locate read 2 | 40.387 s | 1 | 2/100 | 1/150 | **WARM** | 35 located |
| resolution | — | 4 spent, 0 kept | — | — | — | **BLOCKED** |

**Call 0 cleared first try** — no cold-flake this run, the fourth instance being absent.
**Read 2 came back WARM with 27,534 cache-read tokens**, which is the cache prefix reorder doing
exactly what the eighteenth stamp approved it for: read 2 reuses the artifact prefix read 1 paid for.
67 located across both reads, 2 discarded as no-match, 0 crossing turns, 0 coverage defaulted.

**THE FIRST GENUINE RUN RECEIPT EXISTS**, written by the pass itself rather than seeded by hand:

```
stages=3  wall=92,659 ms serial  callouts=3  worst=40,676 ms  cache=WARM
normalizer=NF1+raw:75917ba2
```

That is the sixty-seventh stamp's build proving itself on real traffic. Every number above came off
that receipt rather than out of a log.

## 2 · The purge, verified

Card-first, then the harvest. **Reach checked before anything was deleted**, per the standing rule:

- `ALTF__Insight_Card__c` carries **70 child relationships**. Deleting the 12 cards took their 12
  section placements and 21 contact links **by cascade** — the fifty-second stamp's lesson applied
  in the correct direction, having once been paid for in the wrong one.
- **Both sections survive**, including Matthew's empty "Enter title" column and the machine's
  "30 July 2026: Discovery Call". The card writer matches on the date prefix, so the dated section is
  reused rather than twinned when the run finishes.
- `AAO_Purge` then took 292 pairs, 23 claims, 23 candidates, 13 answers, 3 map rows across the three
  historic run keys. The human-watermark guard passed. Three retired criteria were **kept and
  reported**, as the lawful correction's own evidence.
- **Seeds intact**: 1 Source, 6 participants, 84 contracts. **Emerson and the other 126 map rows on
  other deals untouched.**

## 3 · THE BLOCK, diagnosed to the wire

Call 2 was handed 67 pairs and disposed **1**. `AAO_PairLedger.assertOneForOne` threw, which is the
guard doing its job — 66 dispositions did not vanish silently.

**It is not a batch-size problem.** Driven at 15 (the measured keyed-call cap) and at 5, both
returned 1.

**It is not truncation.** Measured on the wire: `stop=end_turn`, `out=324`, `thinking=100`. The model
finished of its own accord.

**It is the generation degenerating into duplicates.** Handed 3 refs, it returned 4 entries covering
fewer distinct refs, with one ref repeated and a blank basis on the first:

```json
{"dispositions":[
  {"basis":"","person":"AMBIGUOUS","pair_ref":"r1q20"},
  {"basis":"Speaker refers to \"Dan and I\", so not Dan; ...","person":"AMBIGUOUS","pair_ref":"r1q20"},
  {"basis":"No surrounding context identifies who states ...","person":"AMBIGUOUS","pair_ref":"r1q1"},
  {"basis":"No surrounding context identifies who states ...","person":"AMBIGUOUS","pair_ref":"r2q1"}
]}
```

The pair key's unique index refuses the repeat, so duplicates collapse and the disposed count comes
out at 1. **Two independent mechanisms each caught half of it**, which is the reason both exist.

**The schema is not at fault and I verified that rather than assuming it**: the `pair_ref` enum
carries exactly the handed refs and the description states the required count.

**AND ONE CAPABILITY CLAIM WAS RE-VERIFIED RATHER THAN TRUSTED.** `AAO_IdentifyCharter`'s own comment
records that structured outputs reject an array `minItems` other than 0 or 1, measured 5 August. A
capability claim is unverified until tried from the runtime, and platform limits move, so it was
asked again today. **Still refused**, request id `req_011Cdzv8W2273F78HtUSV7i8`:

> `output_config.format.schema: For 'array' type, 'minItems' values other than 0 or 1 are not supported`

So the structural enforcement the schema would want is genuinely unavailable, exactly as recorded
eight days ago. The comment was right and is now right on a second measurement.

**Nothing this session touched call 2.** Its charter, schema and prompt are byte-identical to the
last successful pass (`pf0811-goal`, 11 August). The rename went nowhere near it.

## 4 · PARKED, not built · call 2's envelope needs the shape the other keyed calls already have

The thirty-first stamp's working mode is explicit: *"A structural question that surfaces
mid-execution is PARKED, never answered in the moment."* This is one, so it is parked with options
and costs and nothing is built on it.

The observation, offered as evidence rather than as a decision: **call 3 and the card-face call do
not have this problem, and the reason is their schema shape.** Both use a KEYED object — one property
per unit, every key in `required` — so the envelope is enforced structurally and the model cannot
return fewer. Call 2 is the one keyed-grain call still using an array with a prose description.

- **(a) Convert call 2's schema to the keyed shape**, one property per pair ref, all required. It
  enforces a law already written (§P8.2's envelope law, "EXACTLY ONE DISPOSITION PER HANDED PAIR"),
  and the infrastructure is already built and ratified: `MAX_UNITS_PER_KEYED_CALL = 15` and
  `keyedShardCount` exist precisely for keyed calls, and the thirty-fifth stamp ratified extending
  that chunking to the resolution leg on the reasoning that *"the grammar ceiling is a property of
  every keyed strict schema through the gateway"* — which anticipates this shape. Cost: it is a
  change to a model call's contract, made mid-run, and the last time an execution session did that
  class of thing it was adjudicated a breach. It also raises the call count on this stage from 1 to
  ceil(pairs/15), roughly 5 on this fixture.
- **(b) Drive call 2 at a batch of 1.** Structurally certain and 67 model calls, which is precisely
  the fifty-nine-callout disease the twenty-seventh stamp deleted. Rejected on that ruling, named so
  nobody proposes it later.
- **(c) Retry the batch on a short return.** Cheap, but it is a call retrying by growing, which the
  charter's own note forbids ("no call retries by growing; the ceiling is split, not raised").
- **(d) Dispatch call 2 on a different configured model.** BYO-LLM makes this configuration rather
  than code, and the degeneration may be model-specific. Costs an adjudicated comparison before its
  dispositions are believed, per the thirty-seventh stamp's small-model caveat.

**Design's is the choice. The deal stays bare until it is made**, and that is the honest cost of
having purged before the pass was known to complete on today's models.

## 5 · Rows, timings, governors, retryNotes

Above, and off the receipt rather than off a log. **retryNotes: none** — call 0 did not flake, and no
stage retried. Four resolution calls were spent on the block and its diagnosis (one at 1000, one at
15, one at 5, one raw probe) plus one capability probe; all are counted here rather than omitted.
Worst single callout 40,676 ms against the 120-second ceiling, well clear. No governor line exceeded
5 of 100 SOQL or 1 of 150 DML on any stage that ran.

## 6 · What I did not do

I did not convert call 2's schema, and the deal is bare because of that choice. The alternative was
to change a model call's contract mid-run on my own authority, which the working mode forbids and
which this project has already paid for once. The located pairs are banked, so whichever option is
ruled, the resumed run starts at stage 4 and does not re-pay calls 0 or 1.
