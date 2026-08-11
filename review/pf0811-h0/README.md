# The forty-first stamp's queue · call 3 on Haiku, the temp-0 probe, a fresh map, and the pass opened to new families

All four items shipped. **The probe's answer is the one that matters and it is not the hoped-for
one: temperature 0 on the new verifier did NOT settle the map. Three identical runs still disagree.**
Full suite 435 tests, every AAO test green (the single failure, `ConvertToOpportunityTest`, is not an
AAO class, is not in this repo's source, and fails on an org validation rule about `AE_Summary__c`).

---

## (i) Call 3 dispatches the configured verify model, and the guard now watches the right path

Authorizing bytes, ruling 1: *"The §P8 pass's call 3 stops borrowing `inventorySpec()`'s model and
takes `AAO_Verify_Model__c`."*

Done, and deliberately minimal: the spec is still SEEDED from `inventorySpec()`, because that is
where the output bound and the cache-prefix posture live and the ruling moves neither. What moves is
the model. Verified on the wire in every run since: `model=claude-haiku-4-5-20251001`.

**`requireSeparateReaderAndVerifier()` is new and runs on every call 3.** The old guard compared
BIND against VERIFY and was called only from `AAO_EBV`, a path §P8 never touches, so it was watching
a comparison the running pass did not use. The new one compares READER against VERIFIER, which on
§P8 are the two readings that must be independent, and it refuses a blank verify model rather than
falling back to the read model, since that fallback is precisely the drift being closed. Three tests
cover it, including one that reproduces the drift itself.

### A SECOND capability gap, found by running it, and the reason ruling 2 is written the way it is

The switch did not work on the first attempt. Haiku returned:

```
400: "This model does not support the effort parameter."
```

Call 3 had been inheriting `effort='low'` from the read spec, the same borrowing ruling 1 corrects
for the model. Two things were done, and both are within ruling 2's bytes:

1. **Call 3 now sets no effort at all.** `verifySpec()` has always omitted it on purpose, in its own
   words: the verifier *"is answering a low-inference question about two pieces of text, and buying
   thinking tokens for that is paying for deliberation nobody asked for."* Call 3 only ever carried
   it by accident of seeding.
2. **Feature detection is generalized from temperature to model capabilities**, exactly as ruling 2
   directs: *"LAW #1's discipline (feature detection, never version checks) extends to model
   capabilities."* On a 400 that names a knob we sent, that knob is dropped, the call is remade, and
   the fact is journalled.

The measured capability matrix is the whole argument for detecting rather than knowing:

| model | `temperature` | `effort` |
|---|---|---|
| claude-opus-5 | **refused** | accepted |
| claude-haiku-4-5 | accepted | **refused** |

**Two models, two missing knobs, in opposite directions.** Any name or version check would have been
wrong about one of them, and would be wrong again the first time a customer points this at a model
nobody here has heard of. Both models now survive with both knobs configured, proven from the
calling runtime: opus-5 returns `tempRefused=true effortRefused=false`, haiku
`tempRefused=false effortRefused=true`, and neither fails. **No model choice is restricted for a
sampling knob**, which is the BYO-LLM law's actual requirement. A run that had to drop a knob reports
`temp=REFUSED_BY_MODEL`, so it can never imply a stability property it did not get.

**N-of-M voting is removed from every parked list it rode on**, per ruling 2.

---

## (ii) The three-run temp-0 probe on the new verifier · IT IS NOT CLEAN

Authorizing bytes, item (ii): *"RUN the three-run stability probe at temperature 0 on the new
verifier ... purge between, mechanical diff on the merge key, STABLE or FLICKERING per
establishment, nothing tuned against it."*

Purged between all three. `temp=0.00` confirmed on the call-3 wire in every run. Zero claims left
unverified in any run (a catch-up pass exists precisely so a transient gateway `Overloaded` cannot
silently leave a run with fewer claims judged than its neighbours, which would compare nothing).

| person · dimension | run 1 | run 2 | run 3 | verdict |
|---|---|---|---|---|
| **Adam** · Status | Supporter | Supporter | Supporter | **STABLE 3/3** |
| **Adam** · Political | Political Structure | *(none)* | Political Structure | FLICKERING |
| **Adam** · Buyer Role | User | Evaluator | Evaluator | FLICKERING |
| **Adam** · Coverage | Brief | Brief | Brief | **STABLE 3/3** |
| **Dan** · Buyer Role | Evaluator | Evaluator | Evaluator | **STABLE 3/3** |
| **Dan** · Coverage | Brief | Brief | Brief | **STABLE 3/3** |
| **Kayla** · present? | present | **absent** | **absent** | FLICKERING |

Cells that ever fire: 7. **STABLE 3/3: 4. FLICKERING: 3.** On the load-bearing dimensions (Status,
Political, Buyer Role) 2 of 4 firing cells hold.

| run | located | upheld | refused | map rows |
|---|---|---|---|---|
| 1 | 38 | 12 | 16 | 3 |
| 2 | 50 | 14 | 20 | 2 |
| 3 | 49 | 17 | 15 | 2 |

### What moved, and the honest limit on reading it

Against the `pf0808` baseline (opus-5 verifier, no temperature): stability went from **3 of 10**
firing cells to **4 of 7**, and on load-bearing dimensions from **1 of 7** to **2 of 4**. The verdict
spread narrowed sharply: baseline upheld ran 8 to 21, a 2.6x swing; here 12 to 17, a 1.4x swing.

**But the flicker has MOVED rather than gone, and the located counts show it.** The baseline's
location was stable (42/42/43) while its verdicts nearly tripled. Here the verdicts are much tighter
and **location is what varies** (38/50/49). The reads are unchanged, same model, no temperature,
same charter, and their variance is the ruled recall hedge, so this is not a regression; it is the
instability relocating to the stage that is designed to vary.

**Two variables changed at once against the baseline** (verifier model AND temperature), so none of
the narrowing can be attributed to temperature alone. This is not a clean temperature isolation and
is not offered as one. Isolating it would need a temp-unset run on Haiku, which is one more probe.

**The gate: this probe is NOT clean.** The map still disagrees with itself across identical runs,
which per the thirty-eighth stamp's framing is the unclean case. N-of-M is dead by ruling, so the
remedy is a design call and not CODE's. Reported, not remedied, nothing tuned against it.

---

## (iii) A fresh map is projected and resident on Project Farma

Authorizing bytes, item (iii): *"PROJECT FRESH MAPS on Project Farma ... to the now-clean surfaces,
full pipeline, so Matthew experiences the product in the Salesforce UI."* Run key `pf0811-live`,
full pipeline, projected onto the surface design purged. **This is the accuracy review of record per
ruling 3; the sheets are retired.**

| person | Status | Political | Buyer Role | Coverage |
|---|---|---|---|---|
| Adam Pfeiffer | | Political Structure | Evaluator | Brief contact |
| Dan Lewis | | | Evaluator | Brief contact |
| Kayla Stanley | | Political Structure | Evaluator | Brief contact |

Every value has its evidence trail behind it. **Read the flicker finding beside it:** this is one
run's map, and a rerun would not reproduce it exactly.

**Emerson is untouched and still at 0 map rows**, per the stamp's own condition (*"and Emerson when
its transcripts rerun"*). Its surface is clean and ready; its rerun was not part of this queue and
was not assumed.

### Timings and governors, `pf0811-live`, label COLD

| stage | wall (ms) | notes |
|---|---|---|
| read A ∥ read B | 27,442 / 29,921 | opus-5, unchanged |
| resolution (deterministic) | 243 | 0 callouts |
| resolution model leg | 4,119 | 2 designator units |
| **verify plain shard 0** | **16,749** | haiku, `temp=0.00` |
| **verify plain shard 1** | **15,010** | haiku, `temp=0.00` |
| **verify sentiment** | **11,145** | haiku, `temp=0.00` |
| join | 2,879 | 45 pairs |
| projection | 2,110 | 3 created |

**Call 3 got substantially cheaper as a side effect of ruling 1**: the verify stage ran ~15 s per
shard against opus-5's 40 to 52 s on comparable batches, with no thinking tokens bought. Governors
clear everywhere; the heaviest reading is the join at SOQL 48/100 and DML 56/150, heap 92 KB of 6 MB.
**retryNotes: none.** No call-0 retry fired, no quote-law failure, no shard died in the live run.

---

## (iv) The pass is prepared to carry added families, and no charter text was touched

Authorizing bytes, item (iv): *"CODE prepares the pass to carry added families and stops short of
authoring charter text."*

**One thing stood between the pass and a new family, and it was a hard stop, not a rough edge.**
`AAO_LocateCharter.familyOf` was a hardcoded prefix ladder that THREW on any code it did not
recognise, and `families()` runs it across the whole declared set. So the first Problems or Politics
contract minted on the live rubric would not have degraded that one family: **it would have failed
call 1 outright, for every family at once, before a single read happened.**

The fix makes adding a family a DATA act:

- New field `AAO_Evidence_Contract__c.AAO_Family__c`. The contract declares the family it is read
  under; `familyOf` prefers it and falls back to the ladder when blank, so the seventeen contracts
  seeded before the field existed keep their families with nothing migrated in a hurry.
- The throw survives both paths, because a contract nobody sweeps is worse than a loud failure. Its
  message now names the remedy: set `AAO_Family__c`.
- Backfilled all 17 live contracts from the ladder, so the data records what the pass already did.
  Routing is byte-identical after: `Buyer Role 5, Decision criteria 3, Political Status 8,
  Sentiment 1`, and `sweepFamilies()` returns the same four names it did before.

**This is routing and never charter content.** It says which read a question travels in and says
nothing about what the question asks, which is the charter's to declare and design's to write. Three
tests cover it, including one that mints an `AAO_PRB_1` contract declaring family `Problems` and
shows it grouping alongside Buyer Role with no Apex change.

### What is ready and what still needs design's fold, named honestly

Ready with no further code: the two comprehensive reads carry all declared families in one prompt
already; verify sharding is derived from claim density rather than a family count; the plain and
sentiment buckets split on `takesTarget`, so a new family lands in `plain` correctly by default;
the rubric block is built generically from the declared set.

**Still design's, and not started:** the charter question declarations themselves (proposition text,
guidance, element counts) which the stamp reserves; and the **edges at the join** the thirty-first
stamp's one-pass law calls for, since Problems and Politics carry relationships between entities
rather than per-person values, and nothing in the current join or projection writes an edge. That is
the next design fold's shape, flagged here rather than guessed at.
