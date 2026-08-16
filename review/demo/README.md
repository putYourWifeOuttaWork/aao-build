# 3(c) · the on-record demo · built, driven, and proved end to end

The hundred-fourth stamp's item 1 and the hundred-sixth's item 4. Tree
`/Users/thefinalmachine/Downloads/claude` on `main`, org `00DWD00000DV7iT2AT`.

**Not run against Wells Fargo.** That deal is the measurement instrument and gets no rehearsal,
ever, so the proof ran on a throwaway account and opportunity created for it.

## What was built

| | |
|---|---|
| `AAO_Receipt.STAGE_IDENTIFY_MODEL` + `Leg.error` + `recordFailure` | the model leg's receipt gap, and a way to journal a stage that died |
| `AAO_PassQueueable` | **the pass driver that did not exist** — one stage per transaction, chained |
| `AAO_DemoController` | `startRun` / `progress`, plain DTOs, no Lightning knowledge |
| `lwc/aaoRunDemo` | paste surface + run view, separable blocks over one controller |

**The receipt gap closed first**, as the stamp required: the demo cannot visualize a callout the
receipt never journals, and `AAO_Resolve` made a callout and journalled nothing. Named as debt at
the eighty-first stamp.

**There was no async pass driver.** The only Queueable in the tree was for ingest; every graded run
in this project was driven by CODE from a shell, one stage per `sf apex run`. That is why "takes
CODE out of the test loop" is a product goal rather than a convenience, and it is the substance of
this item.

**One stage per transaction, because three laws each independently force it**: callout-after-DML is
fatal (and `AAO_Resolve` enforces that at its own call site), the 120-second callout ceiling is per
transaction, and the governors are per transaction. Stages that loop re-enqueue themselves —
verify until nothing is unverified, join until `pairsRemaining` is zero — which is the split rule
as code: complete the remaining work in a continuation, never redo.

## The proof · end to end, from the record, in 38 seconds

```
finished=true  stages=8  wall=37,955ms  callouts=4  cache=WARM
  call 0 resolve          4,961ms  1 callout
  call 1 locate read 1    7,376ms  1 callout   4 produced
  call 1 locate read 2    6,902ms  1 callout   5 produced
  resolution model leg    5,148ms              1 produced
  call 3 verify           6,980ms  1 callout   3 produced
  join                    1,004ms              2 produced
  projection              1,436ms              2 produced
  cards                   4,148ms              1 produced

LEDGER  located 9 · identified 9 · upheld 2 · refused 1 · claims 2 · answers 2 · cards 1
```

**Nine located, nine identified — one for one.** Every stage journalled a real leg; nothing on
that surface is estimated or interpolated.

## FOUR DEFECTS THE PROOF FOUND, all four mine

**1 · The failure reporter was itself broken, in exactly the way it exists to prevent.**
`recordFailure` built a `Leg` with null numerics; `mergeLeg` dereferenced them while moving its
roll-ups; the throw was eaten by `recordFailure`'s own swallow. **A stage that died left no trace
at all.** Found by probing whether the leg landed rather than trusting that it had — the first
demo run stalled after read 2 with four jobs `Completed`, zero errors, and no explanation
anywhere. Fixed by zero-filling every numeric.

**2 · The pass refused the first run, LAWFULLY, and that refusal is the finding.**

```
AAO_Resolve.ResolveException: Source a1XWD00000842TI2AY has no participants.
Participation is written at ingest; a Source with none is an ingest defect.
```

A pasted transcript carries no roster, and **the eighty-eighth stamp is explicit that the side
split never comes from the transcript body** — it comes from `AAO_Speaker_Roster__c`, structured
attendee metadata supplied at ingest. So the paste surface now ASKS: `key, Display Name, email`
per line, which is what a Teams or Gong connector would supply. **The pass stopped rather than
inventing a speaker, which is the system behaving correctly on a surface that was wrong.**

**3 · `AAO_Origin__c` is a restricted picklist carrying exactly {ECI, ingest}**, and refused
`demo-paste`. Corrected to `ingest` rather than by adding a value: inventing an origin to make a
demo look distinct would put a word in the provenance column no connector ever wrote.

**4 · The model leg journalled its wall and read ZERO callouts**, because the milliseconds
overload records time and not calls — understating the one number the gap was named for. Caught on
the live run (`5148ms, 0 callouts`) and switched to the StageResult overload.

## One more thing the run proved, unplanned

Re-running the identical text against the same deal was refused: `DUPLICATE_VALUE ...
AAO_Scope_Key__c`. **The same bytes cannot be ingested twice against one opportunity**, so a demo
cannot accidentally double-count a transcript. Not built for this; observed working.

## THE HONEST LIMIT · rendered is not proved

**The component deploys and its controller is proved end to end from the runtime. It has NOT been
opened on a Lightning page.** The sixty-fifth stamp's law is exact about what that is worth:
**CONTROLLER-PROVEN IS NOT RENDERED-PROVEN**, and no LWC stretch reports done until it has been
opened on the page it ships to. Layout, the polling loop under a real render cycle, and the
disabled-button logic are unproven.

**Placing `aaoRunDemo` on an Opportunity page in Lightning App Builder and looking is the
remaining step**, and it is Matthew's five minutes exactly as the Inspector's was.

**Suite 516, 515 AAO passing. Nothing tuned. Wells Fargo untouched.**
