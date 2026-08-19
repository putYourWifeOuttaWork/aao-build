# The Process seed surface · what the sandbox will actually accept · discovery, not build

The hundred-nineteenth stamp's item 5(a) and the hundred-twentieth's item 6. **The seeds are
gated and this is not them** - the stamp says *"then seeds per the proposal once Matthew grades
it"*, and the proposal is design's. What follows is the org read that a spec has to be written
against, delivered now so the build is one step when the gate opens rather than two.

| | |
|---|---|
| **Tree / org** | `/Users/thefinalmachine/Downloads/claude` on `main` · `00DWD00000DV7iT2AT` |
| **Method** | describes and row counts from the runtime. **Read only; nothing was written.** |
| **Prod capture** | `aao-projection-surface-spm-om-v0_1.md`, read from disk, chain confirmed verbatim |

## 1 · THE CHAIN EXISTS IN THE SANDBOX, EMPTY, AND EVERY LINK IS CREATEABLE

```
ALTF__Sales_Process__c                  rows=0   createable
ALTF__Stage__c                          rows=0   createable
ALTF__Sales_Process_Stage__c            rows=0   createable
ALTF__Sales_Process_Qualifier__c        rows=0   createable      <- the global qualifier library
ALTF__Sales_Process_Stage_Qualifier__c  rows=0   createable      <- the junction
ALTF__Qualifier_Answer__c               rows=0   createable      <- the answer plane
```

The 119th's premise holds: no production connection is needed, the capture is the source, and
rubric discovery would then read OUR sandbox records exactly as it would a customer's.

## 2 · WHAT EACH LINK REQUIRES, and the answer is mostly forecasting machinery

Booleans are listed apart from required fields on purpose: **a checkbox is never nillable, so
`isNillable()` cannot tell "required" from "checkbox"** and reporting them together would
manufacture eleven requirements out of seven. The instrument's reach, named before its output is
used.

```
ALTF__Sales_Process__c        REQUIRED(8): Closure_Duration, Final_Stage_Probability,
                                           Pebble_Percentage, Pebble_Value, Rock_Percentage,
                                           Rock_Value, Threshold, Version
                              checkbox:    Default_Process, Disabled, IsActive, Multiple_Buyers

ALTF__Stage__c                REQUIRED(1): SortOrder

ALTF__Sales_Process_Stage__c  REQUIRED(6): Amber, Green, Qualification, Duration, SortOrder,
                                           Sales_Process
ALTF__Sales_Process_Qualifier__c REQUIRED(0)                     <- the 203 are cheap to seed
ALTF__Sales_Process_Stage_Qualifier__c REQUIRED(2): Sales_Process_Stage, Sort_Order
                              checkbox:    Mandatory
```

**None of the eight required fields on a Sales Process is methodology.** They are forecasting and
probability machinery, and a seed that omits any of them is refused outright. **They should come
from the prod capture verbatim rather than be invented**, which is the same discipline the 119th
already applied to the qualifiers themselves.

`ALTF__Sales_Process_Stage__c.ALTF__Qualification__c` is the stage's own qualification threshold,
and the vendor's help text says what it does: *"highest importance qualifiers must be completed to
move the opp. to the next stage."* **That is the vendor's existing stage gate, and the
hundred-twentieth stamp's BY-STAGE marker is a second, parallel one** - worth design deciding
deliberately whether ours rides theirs or stands beside it, rather than discovering the overlap
after both exist.

## 3 · THE ANSWER PLANE IS KEYED TO THE VENDOR'S OPPORTUNITY WRAPPER, NOT TO THE OPPORTUNITY

```
ALTF__Qualifier_Answer__c.ALTF__Opportunity__c   REQUIRED -> ALTF__Opportunity__c
ALTF__Opportunity__c.ALTF__Opportunity__c        REQUIRED -> Opportunity
ALTF__Opportunity__c.ALTF__Sales_Process__c               -> ALTF__Sales_Process__c
```

So a qualifier answer hangs off `ALTF__Opportunity__c`, a 1:1 wrapper on the standard
Opportunity - and **that wrapper is not universal:**

```
9 of 25 opportunities in this org carry one.

HAS  ALTF opp : DEMO REHEARSAL (Brightwell), WELLS FARGO, PROJECT FARMA, EMERSON, DEMO HARNESS
NONE          : STAGE A, STAGE B, STAGE C
```

The pattern is legible: deals that have been WORKED IN ALTIFY have a wrapper; the STAGE deals,
created through the API for proving, do not. **A deal with no wrapper cannot carry a qualifier
answer at all**, so the Process write plane simply has no landing surface on three of design's own
proving deals.

**And zero of the nine wrappers is bound to a sales process** (`ALTF__Sales_Process__c` null on
all nine), which is consistent with there being no process to bind to yet.

`ALTF__Sales_Process_Mapping__c` (0 rows) maps a RECORD TYPE string to a Sales Process, which
appears to be the vendor's default-assignment path.

### The question this raises, and it is design's rather than mine

Binding a deal to a process means either writing `ALTF__Opportunity__c.ALTF__Sales_Process__c` or
seeding a record-type mapping. **Where no wrapper exists, it means CREATING a vendor row that the
vendor's own UI normally creates**, which is inside the org-ownership rails as data rather than
metadata, but is exactly the class of write that carries vendor-side automation we have not read.
Named, not attempted. The alternative that costs nothing is to seed and prove Process on the deals
that already carry a wrapper.

## 4 · WHAT I COULD NOT READ, so nothing leans on it

**`aao-process-charter-proposal-v0_1.md` at v0.2 is not reachable from this tree or from any
context drop on disk.** The 120th names it as the companion and makes its §4 - the sixteen
questions and the BY-STAGE mapping - the grading surface. I have read neither, so nothing here
anticipates or second-guesses their content, and **the sixteen BANT questions are not mine to
draft**: the 119th assigns that to design ("design drafts four per element in the proposal").

This is the satellite half of the carry gap the thirty-seventh stamp closed for the ledger. The
ledger itself syncs to this tree and is current through the hundred-twentieth; its companions do
not travel with it.

**Design's production connection being lost (120th, item 5) does not touch any of the above**: every
number here is from the sandbox, and the prod capture was read from disk as a frozen 2 August
artifact, which is exactly the standing it was given.
