# The UNVERIFIED-answer diagnosis, and the run receipt built · 12 August 2026

**Authorizing bytes, quoted per the receipt rule.** Sixty-seventh stamp item 5: *"CODE's queue: (a)
diagnose the UNVERIFIED answer by rows per item 4(b), report only, no build; (b) the run receipt
object per item 3 and the twenty-ninth stamp's specification, filling the performance toggle."* And
item 3: *"THE RUN RECEIPT OBJECT WAS RULED AND CONFIRMED AT THE TWENTY-NINTH STAMP... It is owed
work, not a new decision."*

Suite **469 tests, 468 pass**; the lone failure is the standing org-resident non-AAO
`ConvertToOpportunityTest`. Every AAO test green, including eight new ones on the receipt.

---

# Part A · The diagnosis, by rows · report only, nothing built

## A1 · The stamp's hypothesis is WRONG, and the rows say so in one query

The stamp's item 4(b) supposed *"a sibling pair that never received a verdict... the catch-up-pass
shape CODE fixed once at the join"*. **There is no sibling.** Dan Lewis's Obstacle answer has
**exactly one claim behind it**, and that claim was born UNVERIFIED:

| claim | contract | outcome | verdict before | verdict after | element coverage |
|---|---|---|---|---|---|
| `a1VWD000008fqRQ2AY` | `AAO_PB_OBST` | Established | null | **UNVERIFIED** | `{"missing":[],"covered":["e1"]}` |

No monotonicity violation, no clobber, no accumulation error. **The answer machinery is correct
throughout and is not where this comes from.**

Also measured and not previously known: there are **two** UNVERIFIED answers on Project Farma, not
one. The second is Adam Pfeiffer's `AAO_DC_N` criterion, the same shape.

## A2 · The cause, traced to a single line

`AAO_Accumulate.verdictFor` returns the CANDIDATE'S PROPOSED VERDICT when element coverage is full.
Coverage was full. So the answer is UNVERIFIED because the candidate proposed UNVERIFIED:

| candidate | person | contract | proposed verdict | call 3 outcome |
|---|---|---|---|---|
| `a1TWD0000025VdS2AU` | Dan Lewis | `AAO_PB_OBST` | **UNVERIFIED** | Upheld |
| `a1TWD0000025VdK2AU` | Adam Pfeiffer | `AAO_PB_OBST` | **UNVERIFIED** | Upheld |
| `a1TWD0000025VdR2AU` | Adam Pfeiffer | `AAO_DC_N` | **UNVERIFIED** | Upheld |
| *(20 others)* | | | TRUE | Upheld / Reinforced |

And the proposed verdict comes from `AAO_PairCommit.cls:524`:

```apex
proposed = located.AAO_Coverage__c == 'Full' ? 'TRUE' : 'UNVERIFIED';
```

`AAO_Coverage__c` is the READ's own coverage label, written by call 1. For those three pairs it says
`Partial`. **So a read-side hedge from call 1 downgrades an establishment that the blind verifier
then upheld, and the uphold does not overturn it.**

## A3 · The sharp part: `Partial` on a ONE-ELEMENT contract cannot mean anything

Measured across the whole `pf0811-goal` run, 60 located pairs:

| coverage label | contract elements | pairs |
|---|---|---|
| Full | 1 | 43 |
| **Partial** | **1** | **8** |
| null (sentiment, correctly takes no coverage) | 1 | 6 |
| Partial | 3 | 2 |
| Full | 3 | 1 |

`AAO_PB_OBST` declares exactly **one** element. On a one-element question either the element is
covered or there is no pair; there is no "some of it". The charter's own prompt says *"PARTIAL IS
THE DEFAULT UNDER DOUBT"*, and its comment beside it — *"Full requires all of them and Partial is
the honest answer"* — is plainly written for multi-element contracts. **8 of the 51 coverage-taking
pairs on single-element contracts came back Partial: a hedge the schema invites and the join reads
as a downgrade.**

A second contradiction sits inside the same row. `AAO_PairCommit` builds the candidate's element
coverage as `covered = [every element the contract declares], missing = []`, unconditionally. So the
candidate says **fully covered** in one field and **UNVERIFIED** in another, sourced from a
different field, with nothing reconciling them.

## A4 · Why it looked arbitrary, which is the part worth Matthew's eye

Adam voiced four Obstacles: three proposed TRUE, one proposed UNVERIFIED. His answer accrues and
reads **TRUE**. Dan voiced one Obstacle, it proposed UNVERIFIED, and his answer reads
**UNVERIFIED** — *with its card standing either way*, because the card writer reads upheld pairs.

**Two identically-shaped establishments land differently purely because one person happened to say
more things.** That is not a rule anybody wrote.

## A5 · What this does NOT dissolve, stated precisely

The stamp hoped (b) might dissolve (a). **It does not.** The card-versus-answer grain question
stands exactly as design framed it, because the card's own evidence is verified either way and the
walk-back proves the words. What (b) changes is the second question's answer: the UNVERIFIED state
is **not** a catch-up-pass defect and **not** the accumulation misbehaving. It is a read-side
coverage hedge on a question that has no partial state, surviving a blind uphold.

Options with costs, none chosen and nothing built (this belongs to design):

- **(i) A one-element contract cannot be Partial.** Where a contract declares one element, treat any
  located pair as Full. Deterministic, no model change, and it makes the schema's own default
  harmless. Cost: it removes the read's ability to hedge at all on 15 of 17 live contracts, which
  may be a hedge worth keeping for a reason not visible in this fixture.
- **(ii) A blind uphold outranks a read-side hedge.** Where call 3 upheld, propose TRUE regardless
  of the read's coverage label. Cost: it retires coverage as a verdict input on the upheld path
  entirely, which is a larger change than it looks and touches the multi-element criteria case too.
- **(iii) Reconcile the two coverage fields.** Stop stamping `covered = all elements` in
  `AAO_PairCommit` and carry the read's actual coverage into element coverage, so one row stops
  saying both things. Cost: it makes MORE things UNVERIFIED, not fewer, and is the opposite remedy
  to (i) and (ii) — it is the honest-bookkeeping option, not the fix-the-outcome option.
- **(iv) Leave it.** Cost: the arbitrariness in A4 stays, and it will read as a bug to anyone who
  meets it on a map.

Design's attention is owed to the wording of `AAO_LocateCharter`'s coverage instruction either way,
since that is where "Partial under doubt" is authored.

---

# Part B · The run receipt, built

## B1 · What exists now

**`AAO_Run_Receipt__c`**, one thin object, one row per Source per pass, keyed
`AAO_Receipt_Key__c = runKey|sourceId`. Sixteen fields, all described in their own metadata. It
justifies itself against the enterprise install budget the twenty-ninth stamp made law: one object,
bounded row count, retiring to Data 360 with the claims chain.

**`AAO_Receipt`**, the writer. Each stage merges its leg into the same row across the pass's several
transactions. Three design decisions carry their reasons in the code:

1. **TELEMETRY, NEVER EVIDENCE.** Nothing in the pipeline reads a receipt to decide anything, so a
   receipt that cannot be written must never be the reason a pass dies. Every entry point swallows
   its own failures and logs them. **A lost timing is a small loss; a lost run that made seven model
   calls is not.**
2. **Limits are read on the method's FIRST line**, before the receipt spends any of its own, so a
   leg carries the STAGE's consumption rather than the receipt's. A test asserts this.
3. **WARM anywhere makes the whole pass WARM**, taking the weaker claim, because the twenty-eighth
   stamp's rule is that a warm rerun is never reported as cold performance.

**Wired into**: call 0 (via a new `resolve(sourceId, runKey)` overload), both call-1 reads, the
resolution stage, call 3 (per bucket and shard), the join, and projection (via a new
`run(opportunityId, runKey)` overload). Existing signatures are untouched — every current driver and
test calls the old ones and loses nothing.

**The purge takes the receipt with the run.** Leaving it would leave telemetry claiming a pass whose
every row is gone, which is the opposite of the did-we-read-it record's job.

## B2 · The did-we-read-it record, which is the half nobody was asking for

The twenty-ninth stamp's first job, now real: with no abstention rows anywhere, a transcript with
zero claims is otherwise **indistinguishable between never-read and read-and-nothing-established**.
The receipt row existing is what tells them apart, and a test asserts exactly that — a pass with
zero claims still has a receipt, and a run that never happened has none.

## B3 · Verified on the page, in BOTH states

Opened on the Project Farma Opportunity. **Zero console errors.** The panel was exercised against a
receipt written by the real writer across four separate transactions:

```
4 stages · 60.200 s serial · 3 model calls · worst callout 31.200 s of the 120 s ceiling · WARM

Stage                 Wall      Callouts           SOQL       DML        CPU            Cache  Produced
call 0 resolve        9.200 s   1, worst 9.200 s   1 of 100   0 of 150   9 of 10000 ms  COLD
call 1 locate read 1  31.200 s  1, worst 31.200 s  0 of 100   0 of 150   2 of 10000 ms  WARM
call 3 verify plain   15.100 s  1, worst 15.100 s  0 of 100   0 of 150   2 of 10000 ms  COLD
join                  4.700 s   none               0 of 100   0 of 150   2 of 10000 ms  n/a    23
```

Roll-ups reconcile: 9200 + 31200 + 15100 + 4700 = 60200; three callouts; worst 31200; WARM because
one call reported cache reads; all three charter versions accumulated one per line; the normalizer
stamp `NF1+raw:75917ba2` copied off the Source.

**THEN I REMOVED IT, AND THAT IS THE HONEST PART.** `pf0811-goal` ran BEFORE the writer existed, so
those wall times were ones I typed, not ones the pass journalled. Leaving them would have put a
fabricated measurement on a real run key, in the org, where a later session would read it as real —
the exact thing this object exists to prevent. Delete reach checked first per the standing rule: the
object has no child relationships of its own, so nothing cascaded.

The page was then reloaded and shows the other state correctly:

> *"This run journalled no per-stage performance. The run receipt object was built at the
> sixty-seventh stamp, so passes from that point carry their own wall time and governor consumption;
> earlier passes measured nothing... Deriving them here from record timestamps would be a number
> recomputed on the page, which is not what this panel is for."*

**So: the writer is proven by eight tests and by a live in-org exercise; the panel is proven on
screen in both the has-numbers and the has-nothing state; and NO REAL PASS HAS WRITTEN A RECEIPT
YET, because none has run since the build. The first genuine one arrives with the next pass.**

## B4 · A defect the tests caught that my own error policy had hidden

The merge query did not select `AAO_Receipt_Key__c`. An upsert on an external id needs that field
populated on the sObject, so the write threw on the way back out — **and this class's own
swallow-and-log policy then hid the throw**, so the second stage of every pass silently REPLACED the
first instead of merging into it.

The symptom was three failing tests with three different-looking messages (stage count 1 not 3,
cache stuck COLD, governors reading zero). Only the tests that assert on the ROW'S CONTENTS rather
than on the call's return value could have caught it, because the call returns null by design.
Recorded because the trade is real and I would make it again: swallowing is right for production and
it costs debuggability, so the tests have to compensate, and here they did.

## B5 · Rows, timings, governors, retryNotes

No model calls this session; the receipt is a schema and a writer and needs no pass. **retryNotes:
none.** `AAO_Receipt.record` costs **1 SOQL and 1 DML** per stage (2 SOQL on the stage that creates
the row, which also reads the Source), against a 100/150 ceiling that the join's own leg now prints.
`AAO_RunInspector.inspect` gains **1 SOQL** for the receipt read, taking it from 5 to 6.

---

## Owed, and named rather than left implicit

- **The card writer's leg is unwired.** `AAO_Receipt.STAGE_CARDS` is declared and `AAO_Cards.run`
  takes an opportunity with no run key, the same shape projection had. It wants the same overload
  and did not get one this session.
- **Split events are always zero** because nothing currently reports a split to the receipt. The
  field and the roll-up exist; the callers that split (call 1 by artifact partition, call 3 by claim
  batch) pass 0 today.
