# The three owed items, the LOR write probe, and a premise worth checking before the Emerson run
## 13 August 2026

**Authorizing bytes, seventy-eighth stamp item 2:** *"The three small owed items (the no-element
contract guard, the serial-driver caveat, the machine-versus-human satellite with its caveat) stand
unchanged ahead of it in CODE's queue."* And item 6: *"whether the runtime can create and update
junction rows lawfully under FLS; CODE tries it in the sandbox behind the create-leg record before
the charter draft asserts it."*

Suite **490 tests, 489 pass**; the lone failure is the standing org-resident non-AAO
`ConvertToOpportunityTest`.

## (a) A contract that declares no elements cannot mint

Ruled at the seventy-first stamp on a defect I surfaced at the seventieth. The guard refuses at
mint, names the contract, and defaults nothing.

**The wrong place for it is the instructive part.** Before the uphold-governs ruling a zero-element
contract was caught BY ACCIDENT: `isFull` returned false on an empty element list, so every
establishment made against such a contract quietly read UNVERIFIED forever. That looked like a guard
and was not one — it raised no error, named no contract, and punished the EVIDENCE for a defect in
the QUESTION. When completeness stopped gating the verdict the accident stopped, and the real gap
showed. Two tests: one asserts every shipped contract satisfies it, one asserts the refusal names
the contract and says nothing was minted.

## (b) The serial-driver caveat, written where a driver will read it

Into `AAO_Pass.plannedVerifyShards`'s own header, not a report nobody reruns. Measured on
`pf0813-uphold`: fired together the four slices partition one set exactly; fired one after another,
shard 0 commits and shard 1 slices an already-smaller set — **15, 11, 8, 6 where four equal slices
were planned, leaving 18 of 67 unverified with no error anywhere.** The comment now states the loop
that is correct under both shapes: recompute, take shard 0, repeat while it returns anything.

## (c) The machine-versus-human satellite

`review/comparison/README.md`, with the seventy-second stamp's caveat printed above the table and
nothing derived from it that a caveat cannot carry. One thing it now says that it could not before:
**the machine moved toward the human on Adam without anybody tuning toward her.** It read Evaluator
against her Decision Maker in July; it now reads **Approver**, one rung below rather than two,
because the never-blank procedure writes the highest-ranked established value and `AAO_BR_APP` was
already upheld. The ranking changed; the evidence was there all along.

It still declines Decision Maker on both men, which is correct: nobody in that room said they
decide.

## (d) The LOR junction write, TRIED rather than described

`ALTF__LOR_Relationship__c` in the sandbox. Describe first — accessible, createable, updateable,
deletable, and every field of interest createable and updateable. **Then the actual write, because a
describe is not a try**: validation rules, triggers and managed-package guards all live past the
describe, which is where the pf0811 and a17 lessons were learned.

```
CREATED a0sWD00000d4ujVYAQ        (Contact + User + CurrentLOR = Vendor)
UPDATED to Credible Source
```

**Both work.** Recorded behind the create-leg record as the stamp requires, and the object carries
**64 child relationships**, which any future delete must check.

**THEN I REMOVED THE ROW.** It carried no evidence and no establishment, and leaving it would have
put a fabricated Level of Relationship on a real person's Contact — the same error as the
hand-seeded receipt, and the same discipline removes it. The create-leg record STAYS, marked
disowned with its reason: the enumeration outlives the row it enumerates.

---

# THE PREMISE UNDER THE EMERSON STACKED RUN DOES NOT HOLD, and it is cheaper to say so now

The stamp: *"THE EMERSON STACKED RUN LEADS the test queue: **three frozen graded calls on one clean
deal**."*

**Measured against the freeze list and the org, there are two calls on that deal, and one of them is
the training set.**

| ref | sha | status |
|---|---|---|
| `emerson/aspentech-2026-06-17-nf1` | `ec8e7170…` | **THE TRAINING SET** — *"everything was calibrated against it; its precision no longer predicts anything"* |
| `emerson/aspentech-2026-07-29-nf1` | `9e974006…` | frozen fixture 1, unseen |

The third frozen fixture is `bv/biweekly-2026-06-24-nf1` — **Black & Veatch, a different account and
a different deal**, so it cannot stack onto Emerson. Project Farma is the fourth and is its own deal.

The org also carries a second, undated-differently 29 July row and a `diag/immutability-probe`
source on the same deal; the freeze list exists precisely because the two 29 July rows are
*"permanently indistinguishable by stamp"* and a query picks the wrong one half the time.

**What this changes, and what it does not.** It does not kill the run: two calls on one deal is
enough to exercise everything the stamp actually wants tested — accumulation across utterances,
the reinforcement counter, per-call board sections, and whether a map firms up over calls. Those
are MECHANICAL properties and the training-set status does not touch them.

**What it does kill is any accuracy reading.** Half the evidence would come from the fixture
everything was tuned against, so nothing about precision or recall may be reported from this run,
and the maps-firm-up thesis would be demonstrated on one unseen call rather than two.

**The deal is also not clean:** 743 pairs, 66 claims, 17 answers standing from historic runs, 0 map
rows and 0 cards (purged at the forty-first stamp at Matthew's direction). A stacked run wants a
purge first, and purging that deal removes the harvest behind those 66 claims.

**Not started, and that is the choice being reported.** Beginning a roughly thirty-call run and a
purge on a premise I had just measured as wrong would produce a report whose headline is false. The
run is ready; what it needs is a word on whether two calls with one training-set half is the test
design intended, or whether the third call should come from somewhere else.

## Rows, timings, governors, retryNotes

No pipeline model calls. **retryNotes: none.** The LOR probe cost zero model calls and 2 DML. Two
compile fixes on the way, both mine: `AAO_PassContracts.Spec` has no no-argument constructor, and
`AAO_Created_Row__c` carries no `AAO_Synthetic__c`.
