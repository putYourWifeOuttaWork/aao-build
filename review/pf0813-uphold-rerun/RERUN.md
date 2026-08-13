# The rerun completed · call 2 converted to the keyed shape · 13 August 2026

**Authorizing bytes: Matthew, 13 August — "go with (a), convert call 2 to the keyed shape."**

Run key `pf0813-uphold`. Project Farma is rebuilt: **3 map rows, 13 cards, 13 placements, 14 card
contacts, 3 decision criteria**, and **zero answers reading anything but TRUE**.

Suite **470 + 7 new = 477 assertions across 470 tests, 469 pass**; the lone failure is the standing
org-resident non-AAO `ConvertToOpportunityTest`.

## 1 · The conversion

`AAO_IdentifyCharter.schema` is now KEYED: one property per pair ref, every ref in `required`,
`additionalProperties: false`. A short return, a repeat and an invented ref are all **inexpressible**
rather than merely forbidden. This is the shape call 3 and the card face have always used, and it is
why neither has ever had this failure.

`VERSION` bumped `identify-1.0.0` → `identify-2.0.0`, so a run's rows name which shape produced them.
`AAO_Pass.identify`'s default batch changed from 1000 to `MAX_UNITS_PER_KEYED_CALL` — a keyed schema
with 67 required properties would 400 at the gateway, so the safe thing is now the easy thing.

**It worked first try and every time after: 15, 15, 15, 15, 7 — every batch returned exactly what it
was handed.** Seven new tests pin the shape, including one asserting the schema is *not* an array
again, because reverting is a one-line temptation and prose in a description is a request rather
than a constraint.

**The one-for-one guard was kept, not retired.** The schema is the gateway's promise; the guard is
our own check of it, and the day a promise stops being kept is exactly the day nobody is watching.

## 2 · A second wall, hit on the way through · THE CALLER-SIDE JOIN SPLIT

The join threw `Too many SOQL queries: 101`. That is the sixteenth stamp's join wall, met by
ordinary use for the second time — the forty-eighth stamp met it at 34 upheld and bulkified
`readExisting`; `pf0811-goal` then joined 24 inside the ceiling; this run produced 39 upheld and
went over. **The bulkification bought roughly ten more pairs and a ceiling is still a ceiling.**

Built rather than parked, because it is already ruled and the bytes are quotable — sixteenth stamp:
*"The caller-side join split moves AHEAD of the production-transcript runs"*; forty-eighth: *"its
mitigations (caller-side join split, bulkified single projection) are already ruled."* It was ruled
and never built.

`AAO_PairCommit.run(runKey, domains, maxPairs)` bounds one transaction; the caller loops until
`pairsEligible` reaches zero. Safe by construction, because the pair watermark already makes the
join resumable. Measured at a batch of 12: **SOQL 40, 37, 35, 15 of 100** and **DML 51, 47, 46, 18
of 150** — comfortable, where one transaction had been over.

One implementation note worth keeping: the first version named its local `batch`, and **Apex is
case-insensitive**, so it silently shadowed the static `BATCH` and the comparison became Integer
against List. It failed to compile, which is the good version of that mistake.

## 3 · The run, off its own receipt · 21 stages, 15 model calls

```
21 stages · 331.433 s serial · 15 model calls · worst callout 40.676 s of the 120 s ceiling · WARM
```

| stage | wall | calls | SOQL | DML | cache | produced |
|---|---|---|---|---|---|---|
| call 0 resolve | 11.596 s | 1 | 5/100 | 0/150 | COLD | scope OPPORTUNITY |
| call 1 locate read 1 | 40.676 s | 1 | 2/100 | 1/150 | COLD | 32 located |
| call 1 locate read 2 | 40.387 s | 1 | 2/100 | 1/150 | **WARM** | 35 located |
| resolution ×5 | 26.7 / 18.5 / 21.9 / 26.1 / 20.6 s | 5 | 5/100 | 1/150 | mixed | 15,15,15,15,7 |
| call 3 verify ×7 | 17.3 / 15.2 / 12.5 / 10.9 / 10.4 / 10.3 / 9.6 s | 7 | 2–5/100 | 1/150 | COLD | 67 judged |
| join ×4 | 2.6 / 2.3 / 2.4 / 1.0 s | 0 | **40, 37, 35, 15** /100 | **51, 47, 46, 18** /150 | n/a | 38 claims |
| projection | 3.529 s | 0 | 18/100 | 10/150 | n/a | 6 |
| cards | 26.862 s | 0 | 10/100 | 8/150 | n/a | 17 |

**Every number above came off the receipt rather than out of a log.** This is the sixty-seventh
stamp's object doing the job it was built for, on a complete pass, for the first time.

## 4 · What the deal reads now

| person | support | political | buyer role | coverage |
|---|---|---|---|---|
| Adam Pfeiffer | Supporter | Political Structure | — | Brief contact |
| Dan Lewis | — | — | Evaluator | Brief contact |
| Kayla Stanley | — | — | — | Brief contact |

39 upheld, 28 refused. **13 cards created, 0 new sections** — the writer reused the existing
"30 July 2026: Discovery Call" section by date prefix, which is the human-title-survives fix working,
and Matthew's empty "Enter title" column is untouched.

**THE UPHOLD-GOVERNS RULING IS LIVE ON THE MAP.** Zero answers read anything but TRUE, including the
two that motivated the whole stretch:

```
Adam Pfeiffer / AAO_DC_N    = TRUE   (was UNVERIFIED)
Adam Pfeiffer / AAO_PB_OBST = TRUE
Dan Lewis     / AAO_PB_OBST = TRUE   (was UNVERIFIED)
```

The Inspector reads it: 4 people, 39 upheld, 28 refused, 0 defects, and **`perfJournalled=true` with
21 performance lines** — the panel that reported a gap two sessions ago now shows real numbers.

## 5 · retryNotes, in full

- **One resolution invocation of six produced no output and was not diagnosed.** The next proceeded
  normally and the batch counts reconcile exactly (15+15+15+15+7 = 67), so nothing was lost, but I
  did not capture its cause and will not claim one.
- **Verify needed re-driving.** The shard driver assumes shards run CONCURRENTLY: each slices the
  currently-unverified set, so run serially, shard 1 slices an already-smaller set and leaves a
  remainder. 18 pairs were left after the first pass and drained in two more rounds. Not a pipeline
  defect — the express lane fires them together — but a real caveat for any serial driver, and it
  cost 2 extra calls.
- **The join threw once at SOQL 101** before the split existed, rolled back whole, and re-ran clean.
- Call 0 did not flake this run.
- Four calls were spent on the call-2 block and its diagnosis in the prior session, plus one
  capability probe; they are counted in that session's report, not this one.

## 6 · Named, not acted on

- **`plannedVerifyShards` is correct only for concurrent execution.** A serial driver needs to
  recompute and re-drive, which is what this run did by hand. Worth a driver-side helper or a note
  in the method's own comment.
- **The join's batch size of 12 was chosen, not derived.** SOQL landed at 40 of 100 on the first
  batch, so there is headroom; a measured cap keyed to pairs-per-transaction would be the same shape
  as `MAX_UNITS_PER_KEYED_CALL` and does not exist yet.
