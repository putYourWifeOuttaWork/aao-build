# Wiring the resolution stage · proposal, nothing built

**Eighty-first stamp item 3, option (a), *"PROPOSAL BEFORE WIRING"*, conditions 3(ii) through
3(v). This document is the proposal. No code was changed, no charter text was touched, and the
wiring does not start until this is ratified.** The diff report it rests on is
[README.md](README.md) beside it.

---

## 1 · The shape, and one deliberate choice about naming

One stage, deterministic legs in front, the model leg on the remainder only, per condition (ii).

```
AAO_Pass.identify(sourceId, runKey)
  ├─ AAO_Resolve.run(sourceId, runKey)          the merge, the byte lookup, the ladder
  │                                              → merged / identified / ambiguous / remainder
  └─ if remainder is non-empty:
     AAO_Resolve.requests(sourceId, runKey)     ONE bounded call, typed requests, Apex queries
     └─ shard only if the remainder exceeds the measured cap for THAT schema
```

**The method keeps the name `identify`, and its body is replaced.** This is the part I would
argue for hardest, because it fixes the cause rather than the instance. The drift happened
because `AAO_Pass.identify` is a public method on the class every driver already imports while
`AAO_Resolve` is a separate class with two entry points that must be called in order. A driver
written from `AAO_Pass` finds the unlawful stage first, and will again. Renaming the lawful thing
into the discoverable slot means the next driver written from memory lands on the law. **Deleting
the choice beats remembering to make it correctly.**

`AAO_Resolve` stays where it is as the implementation; what disappears is the *second* way to
start the stage.

## 2 · What retires, and one item of it is design's call, not mine

**Retiring with the wiring:** the model-over-every-pair body of `identify` — the closed-list
prompt, `excerptBlock`, the disposition loop — because it is the stage the twenty-seventh stamp
deleted as a model job and it has no remaining caller once the deterministic legs are in front.

**And with it, `AAO_IdentifyCharter`, which is the seventy-third stamp's ratified keyed
conversion.** I am flagging this rather than doing it. That conversion was ruled, built, tested
with seven tests including one asserting *"it is not an array again"*, and ratified at the
seventy-fourth stamp on evidence (`batches returned 15, 15, 15, 15, 7`). Wiring the lawful stage
makes the call it converted stop existing.

Two things are worth separating so the decision is clean:

- **The LAW survives untouched.** *"Keyed grain needs a keyed schema. Prose is not enforcement"*
  is general and already governs the model leg: `AAO_ResolveRequestCharter` is keyed by designator
  handle with every handle a required property, which is how the gate-era run reported it
  (*"an omission fails schema validation instead of parsing short"*).
- **The ARTIFACT becomes unreachable.** That is what needs a ruling.

Options, none chosen: **(a)** retire `AAO_IdentifyCharter` in place with its reason, keep the
class and its tests as the record of the law that produced it, never delete — my recommendation,
and it matches how this project has retired everything else; **(b)** delete it, cheapest to read
and it destroys the evidence of a ruling that was correct; **(c)** keep it wired as a fallback,
which means keeping two ways to dispose a pair, which is the thing this whole wiring exists to
end.

## 3 · Condition (iii) · the cap re-measures, and it cannot be measured to its ceiling on this corpus

The sharding unit changes from PAIRS to DESIGNATORS, which is the twenty-seventh stamp's own
arithmetic: *"The count follows unresolved people, never pairs and never headcount."*

The honest position on the number, stated rather than implied: **no fixture in the corpus carries
enough distinct unresolved designators to reach any ceiling.** Measured — `pf0808-tg1` 2,
`pf0811-fresh` 3, and the three surviving runs would leave 4, 0 and 0. A cap measured against
loads of two to four is not a measurement of a cap.

So the proposal is deliberately conservative: **inherit `MAX_UNITS_PER_KEYED_CALL` for the
request schema, keep the 400-despite-cap loud stop permanently, and record in the journal that the
request schema's own ceiling is UNMEASURED and why.** The thirty-fifth stamp's condition is that
the cap is keyed to the schema shape and re-measures; what it cannot require is a measurement the
corpus cannot produce. A fixture that would exercise it is a call naming fifteen-plus people who
are not on the roster, and the Wells Fargo authored corpus could carry one deliberately if design
wants the number.

## 4 · Condition (iv) · the ledger arithmetic, and the one line that is actually wrong

Good news first: **`located == disposed` survives the merge unchanged and needs no restatement.**
A merged row is written as a real disposition row — `AAO_Stage__c = Identified`,
`AAO_Disposition__c = 'Merged'` — so every located pair still gets exactly one disposition and
`AAO_PairLedger.assertOneForOne` holds as written.

What is wrong is one bucket. `AAO_PairLedger.counts` does:

```apex
if (disp == 'Identified') { c.identifiedToAPerson += n; }
else                      { c.identificationsRefused += n; }
```

so **a merged row counts as an identification REFUSED.** It was absorbed into its partner, not
refused; its establishment rides the canonical. On the gate-era run that mislabelled 14 of 44
pairs in the ledger line a human reads.

Proposed restatement, small and additive: a `merged` counter on `Counts`, the buckets reading
**identified + merged + refused = disposed**, and the printed line naming merged on its own row.
No assertion changes; one line of arithmetic stops lying.

## 5 · Condition (v) · before and after, and the vehicle question

**"Before" is already banked** and needs no run, which is the run receipt earning its keep: 5
resolution stages / 5 callouts / 113,705 ms on `pf0813-uphold`; 3 / 3 / 42,455 ms on
`em0813-stack-c1`; 2 / 2 / 42,237 ms on `em0813-stack-c2`; and 0 corroborated across all 134
identified pairs.

"After" needs one full pass on a frozen fixture. The vehicle matters because a second run key on
a resident deal writes a second set of claims and inflates everything the eightieth stamp just
corrected.

- **(A) Project Farma, purged and re-run. RECOMMENDED.** Its "before" is the richest of the three
  (67 located, the only run with a real remainder at 4 designators), it is the ratified
  purge-and-rerun vehicle used twice already, and the deal carries no human edits. Cost: one full
  pass of model calls, and the deal is bare between purge and completion — the seventy-third
  stamp's own lesson, *"a destructive purge follows a known-good pass"*, so the purge waits until
  the wiring is green on tests.
- **(B) Emerson, purged and re-run.** Cost: it destroys the ten retirements and ten replacement
  claims written yesterday, which are the evidence of our own mistake and are exactly what the
  never-delete law protects. Rejected unless design wants it.
- **(C) Black and Veatch.** Nothing is destroyed and it closes a standing corpus item, but call 0
  reads ACCOUNT on it and a side-yes with deal-NONE does not dispatch, so it may produce zero
  pairs and measure nothing.

Reported either way: model calls, merged count, corroborated count, wall per stage, governors,
and **an attribution diff** — for every pair ref, who the drifted run attached it to against who
the lawful run attaches it to. That last one is not in the stamp's list and I would add it,
because it is the only number that says whether the two shapes ever disagreed about a person, and
this report cannot answer that from banked rows.

## 6 · Risks I would want ruled on before starting, not discovered mid-run

**The deterministic legs THROW where the drifted path answered.** `AAO_Resolve` refuses a pair
whose speaker key is not on the roster, in its own words *"this is an ingest defect, never a quiet
None"*. That guard is right and it has never run on the 29 July or 17 June sources. If either
carries such a pair, the wired stage stops the run where the model quietly disposed it. **That is
the guard working and it will look like a regression**, so it is named now: a stop there is a
finding about intake, not about this wiring.

**Attribution may move.** A model deciding who a pair is about and a byte lookup deciding it are
not guaranteed to agree, and the lawful shape also introduces merges that change which pair
carries an establishment forward. The Emerson and Farma boards may differ after the rerun. The
accepted-flicker disposition covers run-to-run variance; this is not that, and it should be read
as a shape change with its diff, never as the machine improving or degrading.

**Mention participants get minted again**, which is the ladder doing its job. Coverage already
excludes `mention:` roster keys, so presence arithmetic is safe; what is new is that the given-name
rung and the single-token creation bar built yesterday finally sit on the driven path, which is
where they were always meant to be.

## 7 · What I will not do without a further ruling

Change any charter text; change the merge key; change `AAO_ResolveRequestCharter`'s schema; touch
call 3; delete `AAO_IdentifyCharter` rather than retiring it; or run the before-and-after on a
deal design has not named. The join-side backstop from the eightieth stamp stays in place
regardless, because different-meaning pairs on one utterance are meant to survive the merge and
still land on one answer.
