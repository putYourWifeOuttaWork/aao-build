# The ALTF projection map, at field level

**Deliverable (d) of the ninety-third stamp's item 3.** From `AAO_P8Codes`, `AAO_Project`,
`AAO_SupportCounter` and `AAO_Coverage` — the code, not the prose.

| | |
|---|---|
| **Tree** | `/Users/thefinalmachine/Downloads/claude`, branch `main`, project `aao-build` |
| **Org** | `00DWD00000DV7iT2AT` — sandbox `aossb2` |
| **Read from** | the classes named above, 2026-08-15 |

## The rails, restated because they bound everything below

- **We write DATA ROWS on vendor objects. We never write vendor METADATA.** No field is added
  to an `ALTF__` object, ever, and no picklist value either.
- **A human-set value is never overwritten.** Every dimension carries its own watermark, and a
  non-blank value our watermark does not claim was put there by a person.
- **Silence stays silence.** An empty established set writes no value and keeps its refusal note.

## 1 · `ALTF__Contact_Map_Details__c` — the relationship map row

One row per Contact per Opportunity. Keyed on `ALTF__Contact__c` + `ALTF__Opportunity__c`;
`ALTF__Contact__c` is **`nillable = false`**, which is why a shadow person can never reach this
surface and why a map row proves a Contact exists.

| Dimension | Source in our ledger | ALTF field written | Watermark field |
|---|---|---|---|
| **Support / sentiment** | `AAO_Answer__c.AAO_Support_Counter__c` → band | `ALTF__Status__c` | `ALTF__Status_Last_Modified__c` |
| **Political** | contract code → placement | `ALTF__Political__c` | `ALTF__Political_Last_Modified__c` |
| **Buyer role** | contract code → role | `ALTF__Buyer_Role__c` | `ALTF__Buyer_Role_Last_Modified__c` |
| **Coverage** | distinct occasion count | `ALTF__Coverage__c` | `ALTF__Coverage_Last_Modified__c` |
| **Citations, all dimensions** | the Option C note | `ALTF__Note__c` | *(none — the note is not a dimension)* |

### 1.1 · Support · counter to band

`AAO_SupportCounter`. The counter is an integer clamped to a voiced-state ceiling; the band is
derived from it, never written directly.

| Counter | `ALTF__Status__c` |
|---|---|
| `+3` | `Mentor` *(proof-gated terminal)* |
| `+2` | `Supporter` *(ceiling of supporter-grade words, however many times said)* |
| `0` | `Neutral` — **a counted zero, never blank** |
| `-2` | `Non-Supporter` |
| `-3` | `Enemy` *(proof-gated terminal)* |

**`Neutral` at zero is a ruling, not a default** (forty-fourth stamp, Matthew's): a measured zero
means support and counter-support were weighed and balance. **Blank is reserved for
never-measured**, and the two must never collapse.

Live specimens, read from the org: Adam Pfeiffer at `+2` → `Supporter`; Neeraja Chimata at `+2`
→ `Supporter`.

### 1.2 · Political · contract code to placement

`AAO_P8Codes.POLITICAL_PLACEMENT`. Eight codes, three stored values.

| Contract code | `ALTF__Political__c` |
|---|---|
| `AAO_POL_IC1`, `AAO_POL_IC2`, `AAO_POL_IC3` | `Inner Circle` |
| `AAO_POL_PS1`, `AAO_POL_PS2`, `AAO_POL_PS3`, `AAO_POL_PS4` | `Political Structure` |
| `AAO_POL_OPS1` | `Outside Political Structure` |

### 1.3 · Buyer role · contract code to role

`AAO_P8Codes.BUYER_ROLE`. Five codes, five stored values, one to one.

| Contract code | `ALTF__Buyer_Role__c` | Rank |
|---|---|---|
| `AAO_BR_SIG` | `Signature Approver` | 5 |
| `AAO_BR_DM` | `Decision Maker` | 4 |
| `AAO_BR_APP` | `Approver` | 3 |
| `AAO_BR_EVAL` | `Evaluator` | 2 |
| `AAO_BR_USER` | `User` | 1 |
| *(none established)* | `Unknown` | 0 |

**Ranks are seed metadata, not code.** They live as `AAO_Map_Value__mdt` rows keyed to STORED
values and are org-overridable, because production displays `Signature Approver` as "Decision
Maker and Approver" and those are not synonyms. **No label string appears in ranking logic, and
a test asserts it.**

**The never-blank procedure** (seventy-seventh stamp): empty set writes nothing and keeps the
refusal note; one value writes it; more than one writes the highest-ranked with every unwritten
established value riding the note with its citation.

### 1.4 · Coverage · occasions to value

`AAO_Coverage`. Derived from **distinct artifact hashes**, never from row counts, and no model
call anywhere.

| Distinct occasions | `ALTF__Coverage__c` |
|---|---|
| 1 | `Brief contact` |
| 2 or more | `Multiple contacts` |
| 0 | **nothing written** |

**`In-depth` is deliberately underivable.** Arithmetic cannot claim depth; the vendor's third
guided question asks about knowing someone *regularly and routinely*, and no count answers it.
**`No Contact` is never written either** — it is an assertion from absence, and nobody may make
one. Internal-true participants are excluded from the derivation.

## 2 · `ALTF__Decision_Criteria__c` — the criteria surface

Keyed opportunity plus criterion name. Written only for **whole** criteria; partials are held,
and that hold is Matthew's and untouched.

| Our field | ALTF field |
|---|---|
| `AAO_Criterion__c.AAO_Subject__c` (the criterion's NAME) | `ALTF__Subject__c` |
| `AAO_Criterion__c.AAO_Type__c`, defaulting to `Informal` when blank | `ALTF__Type__c` |
| `AAO_Criterion__c.AAO_Required__c` | `ALTF__Required__c` |
| the deal | `ALTF__Opportunity__c`, `ALTF__Account__c` |
| the holder, where one is established | `ALTF__Decision_Criteria_Contact__c` |
| our external key | `ALTF__AltifyId__c` |

Contract codes: `AAO_DC_N` naming, `AAO_DC_F` formal, `AAO_DC_R` required.

## 3 · `ALTF__Insight_Card__c` and its junctions — Problems

`AAO_P8Codes.PROBLEM_TYPE`, written by `AAO_Cards`.

| Contract code | `ALTF__Type__c` |
|---|---|
| `AAO_PB_GOAL` | `Goal` |
| `AAO_PB_PRESS` | `Pressure` |
| `AAO_PB_INIT` | `Initiative` |
| `AAO_PB_OBST` | `Obstacle` |

Also written: `ALTF__Short_Description__c` (the inferred one-line face, capped),
`ALTF__Note__c` (citation line plus verbatim), `ALTF__Insight_Card_Section__c` (board placement,
3-wide grid), and `ALTF__Insight_Card_Contact__c` with type `Informer` or `Owner`.

**`Owner` is the vendor's own word for impacted and/or responsible**, quoted from that field's
own description in the org. There is no `Responsible` and no `Impacted` value, and we never add
one.

## 4 · WHAT WE READ AND NEVER WRITE, by API name

Read for context, ontology, or routing. **Nothing in this list is ever written by any AAO class.**

`ALTF__Account_Relationship__c` · `ALTF__Active__c` · `ALTF__AssessmentQuestionIds__c` ·
`ALTF__Assessment_Answer__c` · `ALTF__Assessment_Question__c` · `ALTF__Criterion_Text__c` ·
`ALTF__Help__c` · `ALTF__Insight_Card_Edge__c` · `ALTF__Long_Question__c` ·
`ALTF__Mandatory__c` · `ALTF__No_Label__c` · `ALTF__Opportunity_Plan_Type_List__c` ·
`ALTF__Order_Number__c` · `ALTF__Question__c` · `ALTF__Show_Assessment__c` ·
`ALTF__Solution_Insight_Card__c` · `ALTF__Solution__c` · `ALTF__Yes_Label__c`

### The two that are read-only by RULING rather than by circumstance

- **`ALTF__DesiredLOR__c`** — never written, never read, never derived from. Matthew's 13 August
  ruling: the target is human-owned and ignored completely.
- **`ALTF__CurrentLOR__c`** on `ALTF__LOR_Relationship__c` — ratified as writable at the
  eighty-fourth stamp, capability proven from the runtime at the eightieth. **The contracts are
  not built, so nothing writes it today.** Rows with no seller are never ours to touch, and the
  sandbox carries zero LOR rows against production's 213.

## 5 · The one thing this map cannot tell you

**Which of these writes actually fired on a given run.** The map is the contract; the run's own
row export is the evidence. A dimension absent from a map row means one of three different
things — never established, established and held by the never-blank procedure's empty branch, or
established and refused by human precedence — and only the Answer ledger and the Option C note
distinguish them.
