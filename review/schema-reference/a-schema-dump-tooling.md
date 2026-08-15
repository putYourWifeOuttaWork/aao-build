# The FLS-blind schema dump · all 17 AAO entities, every field, every picklist value

**Deliverable (a) of the ninety-third stamp's item 3.** The counterpart to design's
`aao-org-field-inventory-2026-08-15.md`, read through a different API on purpose.

## Provenance, per the tree-and-org hazard

| | |
|---|---|
| **Tree** | `/Users/thefinalmachine/Downloads/claude`, branch `main`, project `aao-build` |
| **Org** | `00DWD00000DV7iT2AT` — sandbox `aossb2`, instance `USA758S`, Enterprise Edition |
| **User** | `matt.weisberg@altify.com.aossb2` (System Administrator) |
| **Instrument** | **Tooling API** `FieldDefinition` and `CustomField.Metadata`, via `sf data query -t -o aossb2` |
| **Read** | 2026-08-15 |

**Why the Tooling API.** It does not enforce field-level security. The ninetieth stamp's
law: *existence and visibility are two facts and are measured separately.* Design's
inventory is the visibility read and can establish presence but never absence; this is the
existence read and can establish both. That distinction cost a day on 15 August, when eight
fields present in the org since `12:42:24Z` read as absent through three FLS-aware
instruments at once.

**Inactive picklist values are included.** `FieldDefinition` alone would not show them;
these come from `CustomField.Metadata.valueSet.valueSetDefinition`, which carries every
value with its `isActive` flag.

## THE DIFF AGAINST DESIGN'S INVENTORY: NO FLS GAPS

**317 fields FLS-blind. 317 fields FLS-aware. Every per-entity count identical.**

| Entity | Tooling (FLS-blind) | Design (standard API) | Δ | Records |
|---|---|---|---|---|
| `AAO_Answer__c` | 26 | 26 | — | 43 |
| `AAO_Candidate__c` | 25 | 25 | — | 225 |
| `AAO_Claim__c` | 32 | 32 | — | 100 |
| `AAO_Claim_Basis__c` | 11 | 11 | — | 0 |
| `AAO_Created_Row__c` | 9 | 9 | — | 22 |
| `AAO_Criterion__c` | 14 | 14 | — | 15 |
| `AAO_Evidence_Contract__c` | 28 | 28 | — | 84 |
| `AAO_Flag__c` | 28 | 28 | — | 13 |
| `AAO_Pair__c` | 29 | 29 | — | 371 |
| `AAO_Participant__c` | 15 | 15 | — | 53 |
| `AAO_Run_Receipt__c` | 16 | 16 | — | 3 |
| `AAO_Shadow_Person__c` | 21 | 21 | — | 0 |
| `AAO_Source__c` | 22 | 22 | — | 21 |
| `AAO_Map_Value__mdt` | 4 | 4 | — | 10 |
| `AAO_Model_Config__mdt` | 29 | 29 | — | 1 |
| `AAO_People_Question__mdt` | 5 | 5 | — | 56 |
| `AAO_Setting__mdt` | 3 | 3 | — | 1 |
| **total** | **317** | **317** | **—** | |

**Nothing to grant.** The only FLS gap this org had was the eight anchor fields on
`AAO_Shadow_Person__c`, and it was closed earlier today by adding their `fieldPermissions`
to `AAO_Admin` (job `0AfWD00000FuquX0AR`). Design's inventory reads 21 fields on that
object and so does the Tooling API, which is that grant verified from the other side.

**What this does and does not prove.** It proves no field is hidden from design's
connection *today*. It does not make design's instrument capable of establishing absence
tomorrow: a field deployed through the Metadata API grants FLS to nobody, System
Administrator included, so the next new field will be invisible to design the moment it
lands and until its permission does. **The check is repeatable, not permanent.**

## Reading the tables

Only `AAO_` custom fields are listed; the standard set is on design's inventory and is not
repeated. `Nillable` false means required at the database. Types and lengths are the org's
own, not the repo's.

## `AAO_Answer__c`

**26 custom fields · 43 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Account__c` | Lookup(Account) | 18 | **yes** | `Account` |
| `AAO_Answer_Key__c` | Text(120)  (External ID) (Unique Case Sensitive) | 120 |  |  |
| `AAO_Basis__c` | Picklist | 255 |  |  |
| `AAO_Charter_Version__c` | Text(20) | 20 |  |  |
| `AAO_Criterion__c` | Lookup(AAO Criterion) | 18 |  | `AAO_Criterion__c` |
| `AAO_Element_Completeness__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Element_Coverage__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Established_By__c` | Picklist | 255 | **yes** |  |
| `AAO_Evidence_Contract__c` | Lookup(AAO Evidence Contract) | 18 | **yes** | `AAO_Evidence_Contract__c` |
| `AAO_Evidence_Occurred__c` | Date/Time |  |  |  |
| `AAO_Interpretation__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Last_Claim__c` | Lookup(AAO Claim) | 18 |  | `AAO_Claim__c` |
| `AAO_Opportunity__c` | Lookup(Opportunity) | 18 | **yes** | `Opportunity` |
| `AAO_Participant__c` | Lookup(AAO Participant) | 18 |  | `AAO_Participant__c` |
| `AAO_Projected_Modstamp__c` | Date/Time |  |  |  |
| `AAO_Projected_Value__c` | Text(255) | 255 |  |  |
| `AAO_Publication_State__c` | Picklist | 255 | **yes** |  |
| `AAO_Question_Fingerprint__c` | Text(64) | 64 |  |  |
| `AAO_Rubric_Version__c` | Text(20) | 20 |  |  |
| `AAO_Shadow_Person__c` | Lookup(AAO Shadow Person) | 18 |  | `AAO_Shadow_Person__c` |
| `AAO_Spans__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Subject_Contact__c` | Lookup(Contact) | 18 |  | `Contact` |
| `AAO_Subject_Type__c` | Picklist | 255 | **yes** |  |
| `AAO_Support_Counter__c` | Number(2, 0) | 2,0 |  |  |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |
| `AAO_Verdict__c` | Picklist | 255 | **yes** |  |

**Picklists, full value sets:**

- `AAO_Basis__c` — 3 values: `None`, `None`, `None`
- `AAO_Established_By__c` — 2 values: `None`, `None`
- `AAO_Publication_State__c` — 3 values: `None`, `None`, `None`
- `AAO_Subject_Type__c` — 7 values: `None`, `None`, `None`, `None`, `None`, `None`, `None`
- `AAO_Verdict__c` — 3 values: `None`, `None`, `None`

## `AAO_Candidate__c`

**25 custom fields · 225 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Abstention_Reason__c` | Picklist | 255 |  |  |
| `AAO_Account__c` | Lookup(Account) | 18 | **yes** | `Account` |
| `AAO_Basis__c` | Picklist | 255 |  |  |
| `AAO_Blind_Charter__c` | Text(80) | 80 |  |  |
| `AAO_Blind_Charter_Version__c` | Text(20) | 20 |  |  |
| `AAO_Charter__c` | Text(80) | 80 | **yes** |  |
| `AAO_Charter_Version__c` | Text(20) | 20 | **yes** |  |
| `AAO_Claim__c` | Lookup(AAO Claim) | 18 |  | `AAO_Claim__c` |
| `AAO_Criterion__c` | Lookup(AAO Criterion) | 18 |  | `AAO_Criterion__c` |
| `AAO_Element_Completeness__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Element_Coverage__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Evidence_Contract__c` | Lookup(AAO Evidence Contract) | 18 | **yes** | `AAO_Evidence_Contract__c` |
| `AAO_Interpretation__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Opportunity__c` | Lookup(Opportunity) | 18 | **yes** | `Opportunity` |
| `AAO_Outcome__c` | Picklist | 255 | **yes** |  |
| `AAO_Participant__c` | Lookup(AAO Participant) | 18 |  | `AAO_Participant__c` |
| `AAO_Proposed_Verdict__c` | Picklist | 255 |  |  |
| `AAO_Publication_State__c` | Picklist | 255 |  |  |
| `AAO_Shadow_Person__c` | Lookup(AAO Shadow Person) | 18 |  | `AAO_Shadow_Person__c` |
| `AAO_Source__c` | Lookup(AAO Source) | 18 |  | `AAO_Source__c` |
| `AAO_Spans__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Stage__c` | Picklist | 255 | **yes** |  |
| `AAO_Subject_Contact__c` | Lookup(Contact) | 18 |  | `Contact` |
| `AAO_Subject_Type__c` | Picklist | 255 | **yes** |  |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |

**Picklists, full value sets:**

- `AAO_Abstention_Reason__c` — 4 values: `None`, `None`, `None`, `None`
- `AAO_Basis__c` — 3 values: `None`, `None`, `None`
- `AAO_Outcome__c` — 12 values: `None`, `None`, `None`, `None`, `None`, `None`, `None`, `None`, `None`, `None`, `None`, `None`
- `AAO_Proposed_Verdict__c` — 3 values: `None`, `None`, `None`
- `AAO_Publication_State__c` — 3 values: `None`, `None`, `None`
- `AAO_Stage__c` — 5 values: `None`, `None`, `None`, `None`, `None`
- `AAO_Subject_Type__c` — 7 values: `None`, `None`, `None`, `None`, `None`, `None`, `None`

## `AAO_Claim__c`

**32 custom fields · 100 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Account__c` | Lookup(Account) | 18 | **yes** | `Account` |
| `AAO_Actor__c` | Picklist | 255 | **yes** |  |
| `AAO_Answer__c` | Lookup(AAO Answer) | 18 | **yes** | `AAO_Answer__c` |
| `AAO_Basis__c` | Picklist | 255 | **yes** |  |
| `AAO_Candidate__c` | Lookup(AAO Candidate) | 18 | **yes** | `AAO_Candidate__c` |
| `AAO_Charter__c` | Text(80) | 80 |  |  |
| `AAO_Charter_Version__c` | Text(20) | 20 |  |  |
| `AAO_Criterion__c` | Lookup(AAO Criterion) | 18 |  | `AAO_Criterion__c` |
| `AAO_Element_Completeness__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Element_Coverage__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Evidence_Contract__c` | Lookup(AAO Evidence Contract) | 18 | **yes** | `AAO_Evidence_Contract__c` |
| `AAO_Evidence_Occurred__c` | Date/Time |  | **yes** |  |
| `AAO_External_Person__c` | Lookup(Contact) | 18 |  | `Contact` |
| `AAO_Internal_Person__c` | Lookup(User) | 18 |  | `User` |
| `AAO_Interpretation__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Opportunity__c` | Lookup(Opportunity) | 18 | **yes** | `Opportunity` |
| `AAO_Outcome__c` | Picklist | 255 | **yes** |  |
| `AAO_Participant__c` | Lookup(AAO Participant) | 18 |  | `AAO_Participant__c` |
| `AAO_Recorded_At__c` | Date/Time |  | **yes** |  |
| `AAO_Retired__c` | Checkbox |  | **yes** |  |
| `AAO_Retired_At__c` | Date/Time |  |  |  |
| `AAO_Retired_Because__c` | Long Text Area(4096) | 4096 |  |  |
| `AAO_Retrospective__c` | Checkbox |  | **yes** |  |
| `AAO_Rubric_Version__c` | Text(20) | 20 |  |  |
| `AAO_Shadow_Person__c` | Lookup(AAO Shadow Person) | 18 |  | `AAO_Shadow_Person__c` |
| `AAO_Source__c` | Lookup(AAO Source) | 18 |  | `AAO_Source__c` |
| `AAO_Spans__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Subject_Contact__c` | Lookup(Contact) | 18 |  | `Contact` |
| `AAO_Subject_Type__c` | Picklist | 255 | **yes** |  |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |
| `AAO_Verdict_After__c` | Picklist | 255 | **yes** |  |
| `AAO_Verdict_Before__c` | Picklist | 255 |  |  |

**Picklists, full value sets:**

- `AAO_Actor__c` — 2 values: `None`, `None`
- `AAO_Basis__c` — 3 values: `None`, `None`, `None`
- `AAO_Outcome__c` — 5 values: `None`, `None`, `None`, `None`, `None`
- `AAO_Subject_Type__c` — 7 values: `None`, `None`, `None`, `None`, `None`, `None`, `None`
- `AAO_Verdict_After__c` — 3 values: `None`, `None`, `None`
- `AAO_Verdict_Before__c` — 3 values: `None`, `None`, `None`

## `AAO_Claim_Basis__c`

**11 custom fields · 0 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Cited_Answer__c` | Lookup(AAO Answer) | 18 |  | `AAO_Answer__c` |
| `AAO_Cited_Line_Item__c` | Lookup(Opportunity Product) | 18 |  | `OpportunityLineItem` |
| `AAO_Cited_Map_Row__c` | Lookup(Altify Contact Map Details) | 18 |  | `ALTF__Contact_Map_Details__c` |
| `AAO_Cited_Row_Deleted__c` | Checkbox |  | **yes** |  |
| `AAO_Cited_Source__c` | Lookup(AAO Source) | 18 |  | `AAO_Source__c` |
| `AAO_Cited_Type__c` | Picklist | 255 | **yes** |  |
| `AAO_Claim__c` | Master-Detail(AAO Claim) | 18 | **yes** | `AAO_Claim__c` |
| `AAO_Covers_Element__c` | Text(40) | 40 |  |  |
| `AAO_Snapshot__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Snapshot_Taken__c` | Date/Time |  |  |  |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |

**Picklists, full value sets:**

- `AAO_Cited_Type__c` — 8 values: `None`, `None`, `None`, `None`, `None`, `None`, `None`, `None`

## `AAO_Created_Row__c`

**9 custom fields · 22 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Disowned__c` | Checkbox |  | **yes** |  |
| `AAO_Disowned_Because__c` | Long Text Area(4096) | 4096 |  |  |
| `AAO_Leg__c` | Text(80) | 80 | **yes** |  |
| `AAO_Reason__c` | Long Text Area(4096) | 4096 |  |  |
| `AAO_Run_Key__c` | Text(64) | 64 |  |  |
| `AAO_Source__c` | Lookup(AAO Source) | 18 |  | `AAO_Source__c` |
| `AAO_Source_Form__c` | Text(255) | 255 |  |  |
| `AAO_Target_Id__c` | Text(18)  (External ID) | 18 | **yes** |  |
| `AAO_Target_Object__c` | Text(80) | 80 | **yes** |  |

## `AAO_Criterion__c`

**14 custom fields · 15 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Account__c` | Lookup(Account) | 18 |  | `Account` |
| `AAO_Criterion_Key__c` | Text(80)  (External ID) (Unique Case Insensitive) | 80 | **yes** |  |
| `AAO_Evidence_Occurred__c` | Date/Time |  |  |  |
| `AAO_Opportunity__c` | Lookup(Opportunity) | 18 |  | `Opportunity` |
| `AAO_Projected_Criterion_Id__c` | Text(18) | 18 |  |  |
| `AAO_Projected_Modstamp__c` | Date/Time |  |  |  |
| `AAO_Required__c` | Checkbox |  | **yes** |  |
| `AAO_Retired__c` | Checkbox |  | **yes** |  |
| `AAO_Retired_Because__c` | Long Text Area(4096) | 4096 |  |  |
| `AAO_Source__c` | Lookup(AAO Source) | 18 |  | `AAO_Source__c` |
| `AAO_Subject__c` | Text(255) | 255 | **yes** |  |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |
| `AAO_Type__c` | Picklist | 255 |  |  |
| `AAO_Voiced_By__c` | Lookup(AAO Participant) | 18 |  | `AAO_Participant__c` |

**Picklists, full value sets:**

- `AAO_Type__c` — 2 values: `None`, `None` **(default)**

## `AAO_Evidence_Contract__c`

**28 custom fields · 84 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Charter_Designation__c` | Picklist | 255 |  |  |
| `AAO_Content_Hash__c` | Text(64) | 64 | **yes** |  |
| `AAO_Contract_Key__c` | Text(83)  (External ID) (Unique Case Sensitive) | 83 |  |  |
| `AAO_Contract_State__c` | Picklist | 255 | **yes** |  |
| `AAO_Decay_Class__c` | Picklist | 255 | **yes** |  |
| `AAO_Element_Count__c` | Number(2, 0) | 2,0 | **yes** |  |
| `AAO_Elements__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Elements_Basis__c` | Picklist | 255 | **yes** |  |
| `AAO_Escalation_Threshold__c` | Percent(3, 2) | 5,2 |  |  |
| `AAO_Family__c` | Text(80) | 80 |  |  |
| `AAO_Gating__c` | Checkbox |  | **yes** |  |
| `AAO_Guidance_Text__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Per_Person_Source__c` | Text(80) | 80 |  |  |
| `AAO_Prerequisites__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Proposition_Code__c` | Text(40) | 40 |  |  |
| `AAO_Proposition_Short__c` | Text(255) | 255 |  |  |
| `AAO_Proposition_Text__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Question_Record_Id__c` | Text(18) | 18 | **yes** |  |
| `AAO_Ratified_By__c` | Lookup(User) | 18 |  | `User` |
| `AAO_Ratified_On__c` | Date/Time |  |  |  |
| `AAO_Required_Map_Role__c` | Text(255) | 255 |  |  |
| `AAO_Requires_Ratification__c` | Checkbox |  | **yes** |  |
| `AAO_Route__c` | Picklist | 255 | **yes** |  |
| `AAO_Rubric_Version__c` | Text(20) | 20 | **yes** |  |
| `AAO_Solicit__c` | Checkbox |  | **yes** |  |
| `AAO_Speaker_Requirement__c` | Picklist | 255 | **yes** |  |
| `AAO_Superseded_By__c` | Lookup(AAO Evidence Contract) | 18 |  | `AAO_Evidence_Contract__c` |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |

**Picklists, full value sets:**

- `AAO_Charter_Designation__c` — 4 values: `None`, `None`, `None`, `None`
- `AAO_Contract_State__c` — 4 values: `None`, `None`, `None`, `None`
- `AAO_Decay_Class__c` — 3 values: `None`, `None`, `None`
- `AAO_Elements_Basis__c` — 3 values: `None`, `None`, `None`
- `AAO_Route__c` — 3 values: `None`, `None`, `None`
- `AAO_Speaker_Requirement__c` — 5 values: `None`, `None`, `None`, `None`, `None`

## `AAO_Flag__c`

**28 custom fields · 13 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Account__c` | Lookup(Account) | 18 | **yes** | `Account` |
| `AAO_Acknowledged_At__c` | Date/Time |  |  |  |
| `AAO_Acknowledged_By__c` | Lookup(User) | 18 |  | `User` |
| `AAO_Acknowledgement_Text__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Answer__c` | Lookup(AAO Answer) | 18 |  | `AAO_Answer__c` |
| `AAO_Answer_Here__c` | Text(255) | 255 |  |  |
| `AAO_Bound_Key__c` | Text(120)  (External ID) (Unique Case Insensitive) | 120 |  |  |
| `AAO_Bounded_Path__c` | Text(80) | 80 |  |  |
| `AAO_Candidate__c` | Lookup(AAO Candidate) | 18 |  | `AAO_Candidate__c` |
| `AAO_Cause__c` | Picklist | 255 | **yes** |  |
| `AAO_Ceiling__c` | Number(9, 0) | 9,0 |  |  |
| `AAO_Cleared_At__c` | Date/Time |  |  |  |
| `AAO_Coverage_Gap__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Escalated_At__c` | Date/Time |  |  |  |
| `AAO_Evidence_Contract__c` | Lookup(AAO Evidence Contract) | 18 |  | `AAO_Evidence_Contract__c` |
| `AAO_Evidence_Watermark__c` | Text(255) | 255 |  |  |
| `AAO_Last_Evidence_Considered__c` | Date/Time |  |  |  |
| `AAO_Missing_Count__c` | Number(9, 0) | 9,0 |  |  |
| `AAO_Missing_Members__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Opportunity__c` | Lookup(Opportunity) | 18 | **yes** | `Opportunity` |
| `AAO_Proposed_Count__c` | Number(9, 0) | 9,0 |  |  |
| `AAO_Raised_At__c` | Date/Time |  |  |  |
| `AAO_Relation_Key__c` | Text(80)  (External ID) (Unique Case Insensitive) | 80 |  |  |
| `AAO_Relation_Kind__c` | Picklist | 255 |  |  |
| `AAO_State__c` | Picklist | 255 | **yes** |  |
| `AAO_Subject_Contact__c` | Lookup(Contact) | 18 |  | `Contact` |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |
| `AAO_Type__c` | Picklist | 255 | **yes** |  |

**Picklists, full value sets:**

- `AAO_Cause__c` — 9 values: `None`, `None`, `None`, `None`, `None`, `None`, `None`, `None`, `None`
- `AAO_Relation_Kind__c` — 3 values: `None`, `None`, `None`
- `AAO_State__c` — 3 values: `None`, `None`, `None`
- `AAO_Type__c` — 7 values: `None`, `None`, `None`, `None`, `None`, `None`, `None`

## `AAO_Pair__c`

**29 custom fields · 371 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_About_Designator__c` | Text(255) | 255 |  |  |
| `AAO_About_Quote__c` | Long Text Area(4096) | 4096 |  |  |
| `AAO_Answer_Text__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Artifact_SHA256__c` | Text(64) | 64 |  |  |
| `AAO_Charter__c` | Text(80) | 80 | **yes** |  |
| `AAO_Charter_Version__c` | Text(40) | 40 | **yes** |  |
| `AAO_Claim__c` | Lookup(AAO Claim) | 18 |  | `AAO_Claim__c` |
| `AAO_Corroborated__c` | Checkbox |  | **yes** |  |
| `AAO_Coverage__c` | Picklist | 255 |  |  |
| `AAO_Criterion_Name__c` | Text(255) | 255 |  |  |
| `AAO_Disposition__c` | Picklist | 255 |  |  |
| `AAO_End_Offset__c` | Number(9, 0) | 9,0 |  |  |
| `AAO_Evidence_Contract__c` | Lookup(AAO Evidence Contract) | 18 |  | `AAO_Evidence_Contract__c` |
| `AAO_Identification_Basis__c` | Text(255) | 255 |  |  |
| `AAO_Located_Pair__c` | Lookup(AAO Pair) | 18 |  | `AAO_Pair__c` |
| `AAO_Meaning__c` | Text(128) | 128 |  |  |
| `AAO_Occurrence__c` | Number(4, 0) | 4,0 |  |  |
| `AAO_Occurrence_Count__c` | Number(4, 0) | 4,0 |  |  |
| `AAO_Pair_Key__c` | Text(67)  (External ID) (Unique Case Sensitive) | 67 |  |  |
| `AAO_Pair_Ref__c` | Text(32) | 32 | **yes** |  |
| `AAO_Person__c` | Lookup(AAO Participant) | 18 |  | `AAO_Participant__c` |
| `AAO_Run_Key__c` | Text(32) | 32 | **yes** |  |
| `AAO_Source__c` | Lookup(AAO Source) | 18 |  | `AAO_Source__c` |
| `AAO_Speaker_Key__c` | Text(64) | 64 |  |  |
| `AAO_Stage__c` | Picklist | 255 | **yes** |  |
| `AAO_Start_Offset__c` | Number(9, 0) | 9,0 |  |  |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |
| `AAO_Verification__c` | Picklist | 255 |  |  |
| `AAO_Verification_Note__c` | Long Text Area(32768) | 32768 |  |  |

**Picklists, full value sets:**

- `AAO_Coverage__c` — 2 values: `None`, `None`
- `AAO_Disposition__c` — 5 values: `None`, `None`, `None`, `None`, `None`
- `AAO_Stage__c` — 2 values: `None`, `None`
- `AAO_Verification__c` — 2 values: `None`, `None`

## `AAO_Participant__c`

**15 custom fields · 53 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Account__c` | Lookup(Account) | 18 |  | `Account` |
| `AAO_Artifact_SHA256__c` | Text(64) | 64 |  |  |
| `AAO_Contact__c` | Lookup(Contact) | 18 |  | `Contact` |
| `AAO_Coverage_Projected_Modstamp__c` | Date/Time |  |  |  |
| `AAO_Coverage_Projected_Value__c` | Text(40) | 40 |  |  |
| `AAO_Display_Name__c` | Text(255) | 255 |  |  |
| `AAO_Email__c` | Email | 80 |  |  |
| `AAO_Evidence_Occurred__c` | Date/Time |  |  |  |
| `AAO_Internal__c` | Checkbox |  | **yes** |  |
| `AAO_Opportunity__c` | Lookup(Opportunity) | 18 |  | `Opportunity` |
| `AAO_Participant_Key__c` | Text(120)  (External ID) (Unique Case Insensitive) | 120 | **yes** |  |
| `AAO_Roster_Key__c` | Text(80) | 80 | **yes** |  |
| `AAO_Source__c` | Lookup(AAO Source) | 18 | **yes** | `AAO_Source__c` |
| `AAO_Substantive__c` | Checkbox |  | **yes** |  |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |

## `AAO_Run_Receipt__c`

**16 custom fields · 3 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Cache_State__c` | Text(8) | 8 |  |  |
| `AAO_Callouts__c` | Number(6, 0) | 6,0 |  |  |
| `AAO_Charter_Versions__c` | Long Text Area(4096) | 4096 |  |  |
| `AAO_First_Stage_At__c` | Date/Time |  |  |  |
| `AAO_Last_Stage_At__c` | Date/Time |  |  |  |
| `AAO_Normalizer_Version__c` | Text(64) | 64 |  |  |
| `AAO_Opportunity__c` | Lookup(Opportunity) | 18 |  | `Opportunity` |
| `AAO_Receipt_Key__c` | Text(80)  (External ID) (Unique Case Insensitive) | 80 | **yes** |  |
| `AAO_Run_Key__c` | Text(32) | 32 | **yes** |  |
| `AAO_Source__c` | Lookup(AAO Source) | 18 |  | `AAO_Source__c` |
| `AAO_Split_Events__c` | Number(6, 0) | 6,0 |  |  |
| `AAO_Stage_Count__c` | Number(4, 0) | 4,0 |  |  |
| `AAO_Stages__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |
| `AAO_Total_Wall_Ms__c` | Number(12, 0) | 12,0 |  |  |
| `AAO_Worst_Callout_Ms__c` | Number(12, 0) | 12,0 |  |  |

## `AAO_Shadow_Person__c`

**21 custom fields · 0 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Account__c` | Lookup(Account) | 18 |  | `Account` |
| `AAO_Anchor_Count__c` | Number(9, 0) | 9,0 |  |  |
| `AAO_Anchors__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Designator__c` | Text(255) | 255 |  |  |
| `AAO_Display_Name__c` | Text(255) | 255 |  |  |
| `AAO_Email__c` | Email | 80 |  |  |
| `AAO_First_Name__c` | Text(80) | 80 |  |  |
| `AAO_Identity_Provenance__c` | Picklist | 255 |  |  |
| `AAO_Last_Name__c` | Text(80) | 80 |  |  |
| `AAO_Participant__c` | Lookup(AAO Participant) | 18 |  | `AAO_Participant__c` |
| `AAO_Promoted_At__c` | Date/Time |  |  |  |
| `AAO_Promoted_Contact__c` | Lookup(Contact) | 18 |  | `Contact` |
| `AAO_Reason__c` | Picklist | 255 | **yes** |  |
| `AAO_Reason_Detail__c` | Long Text Area(1024) | 1024 |  |  |
| `AAO_Shadow_Key__c` | Text(180)  (External ID) (Unique Case Insensitive) | 180 | **yes** |  |
| `AAO_Source_Name__c` | Text(255) | 255 |  |  |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |
| `AAO_Utterance_End__c` | Number(18, 0) | 18,0 |  |  |
| `AAO_Utterance_Quote__c` | Long Text Area(4096) | 4096 |  |  |
| `AAO_Utterance_Source__c` | Lookup(AAO Source) | 18 |  | `AAO_Source__c` |
| `AAO_Utterance_Start__c` | Number(18, 0) | 18,0 |  |  |

**Picklists, full value sets:**

- `AAO_Identity_Provenance__c` — 5 values: `None`, `None`, `None`, `None`, `None`
- `AAO_Reason__c` — 5 values: `None`, `None`, `None`, `None`, `None`

## `AAO_Source__c`

**22 custom fields · 21 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Account__c` | Lookup(Account) | 18 | **yes** | `Account` |
| `AAO_Artifact_SHA256__c` | Text(64) | 64 |  |  |
| `AAO_Boundary_Basis__c` | Text(40) | 40 |  |  |
| `AAO_Diarization__c` | Picklist | 255 | **yes** |  |
| `AAO_Duration_Seconds__c` | Number(9, 0) | 9,0 |  |  |
| `AAO_Evidence_Occurred__c` | Date/Time |  |  |  |
| `AAO_Meeting_Title__c` | Text(255) | 255 |  |  |
| `AAO_Normalized_Text__c` | Long Text Area(131072) | 131072 |  |  |
| `AAO_Normalizer_Version__c` | Text(20) | 20 |  |  |
| `AAO_Opportunity__c` | Lookup(Opportunity) | 18 | **yes** | `Opportunity` |
| `AAO_Origin__c` | Picklist | 255 |  |  |
| `AAO_Part_Count__c` | Number(3, 0) | 3,0 | **yes** |  |
| `AAO_Part_Index__c` | Number(3, 0) | 3,0 | **yes** |  |
| `AAO_Raw_SHA256__c` | Text(64) | 64 |  |  |
| `AAO_Scope_Key__c` | Text(101)  (External ID) (Unique Case Sensitive) | 101 |  |  |
| `AAO_SHA256__c` | Text(64) | 64 |  |  |
| `AAO_Source_Ref__c` | Text(255) | 255 |  |  |
| `AAO_Speaker_Roster__c` | Long Text Area(32768) | 32768 |  |  |
| `AAO_Substantive_Offset__c` | Number(9, 0) | 9,0 |  |  |
| `AAO_Synthetic__c` | Checkbox |  | **yes** |  |
| `AAO_System_Ref__c` | Text(255) | 255 |  |  |
| `AAO_Trim_Manifest__c` | Long Text Area(32768) | 32768 |  |  |

**Picklists, full value sets:**

- `AAO_Diarization__c` — 3 values: `None`, `None`, `None`
- `AAO_Origin__c` — 3 values: `None`, `None`, `None`

## `AAO_Map_Value__mdt`

**4 custom fields · 10 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Dimension__c` | Text(40) | 40 | **yes** |  |
| `AAO_Displayed_Label__c` | Text(255) | 255 |  |  |
| `AAO_Rank__c` | Number(3, 0) | 3,0 |  |  |
| `AAO_Stored_Value__c` | Text(80) | 80 | **yes** |  |

## `AAO_Model_Config__mdt`

**29 custom fields · 1 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Active__c` | Checkbox |  | **yes** |  |
| `AAO_Anthropic_Beta__c` | Text(255) | 255 |  |  |
| `AAO_Bind_Charter__c` | Text(80) | 80 |  |  |
| `AAO_Bind_Charter_Version__c` | Text(20) | 20 |  |  |
| `AAO_Bind_Group_Size__c` | Number(4, 0) | 4,0 |  |  |
| `AAO_Bind_Model__c` | Text(80) | 80 |  |  |
| `AAO_Blind_Charter__c` | Text(80) | 80 | **yes** |  |
| `AAO_Blind_Charter_Version__c` | Text(20) | 20 | **yes** |  |
| `AAO_Blind_Enabled__c` | Checkbox |  | **yes** |  |
| `AAO_Charter__c` | Text(80) | 80 | **yes** |  |
| `AAO_Charter_Version__c` | Text(20) | 20 | **yes** |  |
| `AAO_Effort__c` | Text(20) | 20 | **yes** |  |
| `AAO_Endpoint_Path__c` | Text(120) | 120 | **yes** |  |
| `AAO_Inventory_Charter__c` | Text(80) | 80 |  |  |
| `AAO_Inventory_Charter_Version__c` | Text(20) | 20 |  |  |
| `AAO_Inventory_Effort__c` | Text(20) | 20 |  |  |
| `AAO_Inventory_Max_Output_Tokens__c` | Number(6, 0) | 6,0 |  |  |
| `AAO_Inventory_Model__c` | Text(80) | 80 |  |  |
| `AAO_Max_Findings_Per_Pass__c` | Number(9, 0) | 9,0 |  |  |
| `AAO_Max_Output_Tokens__c` | Number(9, 0) | 9,0 | **yes** |  |
| `AAO_Model_Name__c` | Text(80) | 80 | **yes** |  |
| `AAO_Named_Credential__c` | Text(80) | 80 | **yes** |  |
| `AAO_Probe__c` | Text(10) | 10 |  |  |
| `AAO_Timeout_Ms__c` | Number(9, 0) | 9,0 | **yes** |  |
| `AAO_Verify_Charter__c` | Text(80) | 80 |  |  |
| `AAO_Verify_Charter_Version__c` | Text(20) | 20 |  |  |
| `AAO_Verify_Group_Size__c` | Number(4, 0) | 4,0 |  |  |
| `AAO_Verify_Model__c` | Text(80) | 80 |  |  |
| `AAO_Verify_Temperature__c` | Number(2, 2) | 4,2 |  |  |

## `AAO_People_Question__mdt`

**5 custom fields · 56 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Org_Override__c` | Long Text Area(1024) | 1024 |  |  |
| `AAO_Provenance__c` | Picklist | 255 |  |  |
| `AAO_Question_Key__c` | Text(120) | 120 | **yes** |  |
| `AAO_Sequence__c` | Number(4, 0) | 4,0 |  |  |
| `AAO_Shipped_Text__c` | Long Text Area(1024) | 1024 |  |  |

**Picklists, full value sets:**

- `AAO_Provenance__c` — 2 values: `None` **(default)**, `None`

## `AAO_Setting__mdt`

**3 custom fields · 1 records in the org.**

| Field | Type | Len/Prec | Required | Refers to |
|---|---|---|---|---|
| `AAO_Note__c` | Long Text Area(1024) | 1024 |  |  |
| `AAO_Org_Override__c` | Picklist | 255 |  |  |
| `AAO_Shipped_Default__c` | Checkbox |  | **yes** |  |

**Picklists, full value sets:**

- `AAO_Org_Override__c` — 2 values: `None`, `None`

## Picklist totals

**40 picklist fields, 163 values, 0 inactive.** A clean value space: nothing has
been retired-in-place at the picklist level, so no value in any table below is a ghost.

