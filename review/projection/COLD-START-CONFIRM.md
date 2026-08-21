# The cold-start path, confirmed from Apex

CODE, 21 August. The 168th's item 3: design proved the data path from an API/MCP context and
refused to claim it for the runtime. Confirmed here from Apex, on `AAO DEMO STAGE C` - a
disposable fixture with no wrapper at all, which also settles the half design marked untested.

## Both halves

**A wrapper CAN be created from Apex where none exists.** Untested until now, because the harness
deal design probed already had one.

```
deal AAO DEMO STAGE C type=AAO BANT (Sandbox)
resolved process = AAO New Business (Sandbox)      <- through the VENDOR'S OWN MAPPING
first stage = Qualify sortOrder=1
WRAPPER CREATED FROM APEX: a0yWD000001ehwvYAA
```

**And two fields produce the vendor's whole furniture from Apex**, identical to what design saw
from MCP and to what the two human-initialized wrappers carry:

```
process=AAO New Business (Sandbox)  stage=Qualify  stageName=Qualify
qualStage=a1FWD000001AgYT2A0  progress=00000
typeStamp=a1BWD0000044q2Y2AQ  verStamp=1  weeks=11.00
isAltifyOpp=false  workedIn=false
ORDINAL NOW = 1
```

**A deal went from no wrapper and no axis to a live rubric axis in one Apex transaction.** That
is the cold start, and it is the assumption the 168th correctly called the riskiest unvalidated
one in the arc.

`ALTF__Is_Altify_Opp__c` and `ALTF__Worked_In_Altify__c` stayed false here too, exactly as design
measured. **The data path is confirmed; the SCREEN is still not, and I do not claim it** - those
two flags are the plausible render condition and only a human opening the panel settles it.

## The rail held

The process was **resolved from the deal's Type through the vendor's own mapping**, never chosen:
`ALTF__Sales_Process_Mapping__c.ALTF__Record_Type__c = 'AAO BANT (Sandbox)'` returns
`AAO New Business (Sandbox)`, and the first stage came from that process's own rows ordered by
`ALTF__SortOrder__c`. A deal whose type has no mapping gets a stated refusal rather than a
guessed process - the probe returns early and says so, which is the shape the writer will carry.

## CRITERIA's true source, named from the org rather than assumed into the map join

Design flagged that `CRITERIA` probably is not a map question. **It is not.** From the org:

```
CRITERIA question: Decision criteria are recorded and no required criterion is still open.
AAO_Criterion__c rows = 70
```

It reads **Decision Criteria records** - `AAO_Criterion__c`, a third surface - and its own tip
confirms the plane: *"COMPUTED PLANE: this is arithmetic over rows AAO already wrote."* So the
computed six are not one join: five are map-state questions and CRITERIA is criterion-state, and
building it into the map join would have produced an answer that looks computed and is measuring
the wrong rows.

## The gate, measured

Twenty-five open opportunities, eleven wrappers, and **three** with a sales process: Matthew's
two, plus design's harness probe. Eight remain shells, and every one of them belongs to a real
specimen (Wells Fargo, Emerson, Project Farma, B&V) rather than a disposable - which is why this
probe created a fresh wrapper on a demo fixture instead of assigning a process to somebody's
actual deal.
