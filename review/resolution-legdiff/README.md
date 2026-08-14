# The resolution stage, leg by leg · which era drifted

**Eighty-first stamp item 6(a), item 3(i): *"A per-leg diff report first: what `AAO_Pass.identify`
actually does today, leg by leg, against the twenty-seventh stamp's text and against
`AAO_Resolve`, because the gate-era evidence (234 ms deterministic, one model leg on the
remainder) and today's measurement (a model call over every located pair) cannot both describe
the current pass and the diff says which era drifted."*** **REPORT ONLY. Nothing was built,
nothing was wired, no charter text was touched.**

Org confirmed: aossb2 `00DWD00000DV7iT2AT`, IsSandbox true. Production untouched.

---

## THE ANSWER, first, because it is short and it is not the flattering one

**Neither era drifted. The lawful stage was built, ran, and was then stopped being called — by
CODE's own driver, on 13 August.** Both figures in the stamp are true measurements of different
runs, and the reason they disagree is not a change to the pipeline but a change to what a
hand-written driver invoked.

| | | |
|---|---|---|
| `AAO_Resolve` first exists | `64a2605`, Session 78 | the twenty-seventh stamp's rebuild |
| `AAO_Pass.identify` first exists | `4fb23db`, Session 76 | **two sessions EARLIER**, the pre-rebuild model call |
| commits ever referencing `AAO_Resolve.run` | `64a2605` only | the one that created it |
| last run on the lawful shape | `pf0811-fresh`, 11 August | *"resolution (deterministic) 291 ms · resolution model leg 17,300 ms (3 designator units)"* |
| first run on the drifted shape | `pf0813-uphold`, 13 August | 5 resolution stages, 5 callouts, 113,705 ms |

**The rebuild built the new stage and never deleted the old one, and a driver written later found
the old one first.** `AAO_Pass.identify` is a public method on the class every driver already
imports; `AAO_Resolve` is a separate class with two entry points that must be called in order
(`run()` then `requests()` only if a remainder survives). When I wrote the 13 August drivers after
the purge, I reached for the discoverable method. **That is a CODE driver error, not a pipeline
defect and not a design drift**, and it is the third time in this project that a stage's law and
its driven path have separated (the coverage-Internal flag, the model-separation guard, now this).

The stamp's condition (ii), *"ONE implementation survives"*, is precisely the fix for the cause:
while two entry points exist and only one is discoverable from `AAO_Pass`, the next driver will
make the same mistake, and no amount of care about it will be as reliable as deleting the choice.

---

## The leg-by-leg diff

The twenty-seventh stamp's text is quoted; `AAO_Resolve` is what was built to it; `identify` is
what actually ran on 13 August.

| leg | 27th stamp's words | `AAO_Resolve` (built, zero production callers) | `AAO_Pass.identify` (driven) |
|---|---|---|---|
| **the two-read merge** | *"Merge on contract/question plus byte-range INTERSECTION plus same voiced meaning: one establishment, both receipts kept, marked corroborated"* | `mergePlan`, greedy r1-against-r2 within a contract, absorbed row takes a `Merged` disposition, canonical marked `AAO_Corroborated__c` | **ABSENT.** Both reads' rows ride forward as two independent pairs. |
| **speaker attach** | *"Every pair's byte offset locates its containing turn; the turn's speaker key resolves through call 0's roster to an ID. Self-subject pairs, the default case, are done right there"* | leg 2, `roster.get(p.AAO_Speaker_Key__c)`, zero model calls, and it **throws** on a key not on the roster because that is an ingest defect and *"never a quiet None"* | **The model is asked who every pair is about**, self-subject pairs included. |
| **designator, roster first** | *"match it against the closed candidate set (roster, map rows, Contacts, shadows)"* | leg 3, `rosterMatch` before anything else | folded into the same one model call |
| **designator, the ladder** | *"through the existing ladder including the title rung; exactly one match attaches"* | `AAO_ResolveDesignator`: name, single-token given-or-family, title, map rows; LINKED / AMBIGUOUS / ZERO | **ABSENT.** No ladder runs on this path. |
| **mentioned people** | *"Creation ships WITH this rebuild... behind the create-leg record"* | `mentionFor` mints `mention:` participants on a LINKED ladder outcome | **ABSENT**, and its own header says so: *"a mentioned person has no Participant row, so a disposition naming one could not be written."* |
| **the model leg** | *"ONE bounded call, fired ONLY when the deterministic legs leave a remainder... Output: TYPED RESOLUTION REQUESTS, never query text"* | `requests()` + `AAO_ResolveRequestCharter`, typed requests, Apex composes every query | the model returns **dispositions directly** (a person handle plus a basis), for every pair, always |
| **the sharding unit** | *"The count follows unresolved people, never pairs and never headcount"* | one call for the remainder; `keyedShardCount` over designator units | `LIMIT :maxPairs`, **pairs**, defaulting to `MAX_UNITS_PER_KEYED_CALL` = 15 |
| **ambiguity** | *"AMBIGUOUS stays honest; AMBIGUOUS is the Identification flag, pair held, never a pick"* | `settle()` returns AMBIGUOUS from a counted candidate set | the model may *say* AMBIGUOUS; nothing counts candidates to establish that it is |

Two of these are worth separating from the rest, because they are not "the same job done a
different way":

**The merge is not slower on the driven path, it is absent.** Corroboration is a field nothing
writes. Measured: **0 of 134 identified pairs** across the three surviving runs carry
`AAO_Corroborated__c = true`.

**The ladder is not weaker on the driven path, it is absent.** A mentioned person is reachable
only if a *previous* run already minted them, because `candidates(sourceId)` reads participants
and nothing else. Fatima was pickable on 13 August solely because the lawful 10 August run had
minted her participant row. On a genuinely fresh source, `identify` cannot name a mentioned
person at all — which matters because **notes and emails carry no roster, and the designator path
is the only path there.**

---

## What the deterministic legs would have disposed, measured on the surviving runs

Read-only. The merge predicate is reproduced from `mergePlan`'s published rule (same contract,
byte intersection, same voiced meaning, agreeing designators, r1 against r2, greedy, first
unconsumed partner wins) because `mergePlan` is private and this report writes nothing. The
reproduction is checked against the eighty-first stamp's own named specimen: **`r1q10+r2q7`
appears in the merged list for `em0813-stack-c2`**, which is the identical-bytes pair the stamp
says should have merged.

| run | located | would merge | speaker-attached | designator via roster | **left for the model** |
|---|---|---|---|---|---|
| `pf0813-uphold` | 67 | 19 | 43 | 1 | **4** |
| `em0813-stack-c1` | 42 | 10 | 32 | 0 | **0** |
| `em0813-stack-c2` | 25 | 7 | 14 | 4 | **0** |

And what those runs actually spent, off the run receipts rather than off a log:

| run | resolution stages | callouts | model wall on this stage | lawful shape |
|---|---|---|---|---|
| `pf0813-uphold` | 5 | 5 | **113,705 ms** | 1 call on 4 designators |
| `em0813-stack-c1` | 3 | 3 | **42,455 ms** | **0 calls** |
| `em0813-stack-c2` | 2 | 2 | **42,237 ms** | **0 calls** |

**Both Emerson stacked calls needed no resolution model call at all** and paid five between them.
Against the gate-era deterministic measurement (234 ms at `pf0808-tg1`, 291 ms at `pf0811-fresh`),
the drifted path spent about **198 seconds of model time on three runs to do a job measured in
hundreds of milliseconds**, and did it less completely.

### The consequence that reaches a ratified ruling

**The seventy-third stamp's incident was created by this drift.** That stamp records call 2 being
handed 67 pairs and disposing one, and rules the keyed-object conversion on the strength of it.
The conversion is a good fix and this report does not reopen it — *"keyed grain needs a keyed
schema, prose is not enforcement"* is right and general. But **the premise that call 2 had to take
67 pairs was never the law.** Under the twenty-seventh stamp the deterministic legs would have
disposed 63 of those 67 and handed **four designators** to one bounded call. The degeneration was
real; the load that produced it should not have existed.

Recorded plainly rather than softened: the run that produced that finding was mine, and so was the
driver that caused it.

---

## What this report does NOT claim

- **It does not claim `AAO_Resolve` will reproduce these numbers when wired.** The table above is
  what its published rules imply on rows that already exist. Condition 3(v) requires the
  before-and-after measured on the frozen fixtures, and that measurement has not been taken.
- **It does not claim the drifted runs' outputs were wrong.** The model disposed pairs and the
  join accepted them; what was lost is the merge, the ladder, the corroboration marker, and about
  198 seconds of model time — not, as far as this report can show, correctness of attribution.
  Whether the two shapes agree on *who* each pair is about is a separate comparison and belongs in
  the before-and-after, not here.
- **The `em0813-stack-c2` "designator via roster = 4" is flattering** and is named as such: those
  four attach only because the mention participants minted by the lawful 10 August run still
  stand on that Source. On a fresh source they would fall to the ladder, which is where they
  belong.

## Next, per the stamp's order

Item 6(b): the wiring proposal, then the wiring on its ratification, under conditions 3(ii)
through 3(v). Nothing builds until that proposal is ratified.
