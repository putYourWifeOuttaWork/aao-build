# The stage axis re-point, and what the rehearsal deal did while I was doing it

CODE, 21 August. The 165th's items 5 and 6.

## The re-point

`AAO_Flags.stageOrdinalOf` now reads the vendor's axis first and the org picklist only as the
LAW #1 fallback. Measured immediately after:

| deal | picklist | ordinal | path |
|---|---|---|---|
| AAO DEMO REHEARSAL DEAL | Qualify | **1** | vendor axis |
| AAO DEMO REHEARSAL DEAL 2 | Discover | **2** | vendor axis |
| AAO DEMO STAGE C | Stage 4 | **4** | org picklist, no wrapper stage |

Deals that read NULL for a week now read a real ordinal, with nothing activated, created, or
retired on any picklist.

## The correction I had to make within minutes, because the deal moved under me

The 165th's item 6 instructed the predicate as `ALTF__Sales_Process_Stage__c != null`. **It is
not durable, and the proof arrived by itself.**

Writer (b) projected `PROBLEM = Yes` onto deal 2 at 15:51:48. The vendor recomputed, the deal
satisfied Qualify's mandatory gate, and **advanced itself to Discover** at 15:53:00. On that
advance the vendor **nulled `ALTF__Sales_Process_Stage__c`** and left only
`ALTF__Sales_Process_Stage_Name__c` reading `Discover`:

```
deal2 picklist stage = Discover
WRAPPER stagePtr=null  name=null  sortOrder=null  stageNameField=Discover  modified=15:53:00
stageOrdinalOf NOW = null
```

A predicate resting on the lookup reports NO AXIS on exactly the deals that are moving through
the process, which is the worst possible moment to lose it. The name field survives the advance,
so the name is read first and the lookup second; both resolve through the same stage rows.

**This is the eight-wrappers observation completed rather than contradicted.** Design measured
that only deals 1 and 2 carried the pointer and concluded the pointer was the predicate. True at
rest. The missing case was a deal in motion, and there was no deal in motion to observe until
writer (b) put one there.

## The rest of item 5's re-point

**Markers need no change.** They already read four questions at ordinal 2, ten at 3, one at 4 -
exactly the 130th's semantics, now landing on Discover, Validate and Propose instead of on
placeholder names. The numbers were always right; only the axis under them was wrong.

**The two persona expectations moved**, as instructed: Executive Sponsor 3 to **4** (Propose),
Procurement Lead 4 to **5** (Commit). Verified from the org after deploy.

## The (b) residence confirm, and a correction to my own writer

**Confirmed: it DID residence-filter, and design's lean is right that it should not.** It refused
any qualifier resident ahead of the deal's stage, and refused the whole deal when the ordinal was
null. Both are now gone. Evidence is recorded wherever the call put it: FUNDS is resident at
Discover, but a customer who names their budget during the Qualify call has named it, and
discarding that until the deal advances would be forgetting something true because of where the
calendar is. The ordinal governs flags and expectations, which is what compares against it.

With the filter gone, (b) fired on deal 2 and the surface filled - seven qualifiers, every one
carrying a full canonical citation.

## The law I broke, and the row I put back

`updated 1` in that first run was **Matthew's WHEN1 tick**, and I should not have touched it.

The hold predicate reads the COMMENT. He created that row by clicking Yes and left the comment
blank, and a blank comment reads as "nobody's, ours to fill" - true of a blank comment on OUR
row, false of a blank comment on HIS. So this writer wrote a citation onto a row a human made.
The status agreed by luck; the comment did not.

**Restored by hand**: his row reads `status=Yes, comment=null`, as he left it. And the rule is
fixed at the mechanism rather than at the instance: on this surface ownership is **enumeration**,
not shape. A row this writer did not create is held whole, whatever its comment says or does not
say, and the re-run says so by name:

```
RE-RUN ... unchanged 6, held for a human 1
  Held on WHEN1: this writer did not create that row, so it is somebody else's whole.
```

The comment predicate stays as a second gate for rows that ARE ours, because a human can still
write prose onto one of them afterwards. **This is the Recognition pattern's fourth specimen and
the first one that cost a real row rather than being caught by a test.**

## What this means for the demo

Deal 2 advanced because our projection satisfied the vendor's own gate. Calls landed, evidence
established, answers projected, and the stage unlocked - the 165th's item 7 not as a plan but as
something that already happened once, by accident, while the re-point was being built.
