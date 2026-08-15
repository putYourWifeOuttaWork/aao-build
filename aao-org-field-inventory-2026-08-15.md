# AAO org field inventory

**Org.** Altify — org id `00DWD00000DV7iT2AT`, `IsSandbox = true`, instance `USA758S`, Enterprise Edition.
Verified in this run with `SELECT Id, Name, IsSandbox FROM Organization LIMIT 1`.

**Date of read.** 2026-08-15.

**Instrument.** The `AOSSB2` MCP connection, reading through the standard Salesforce API (v64.0) as the connected user, via `getObjectSchema` (describe), `EntityParticle`, and SOQL.

**Limitation of the instrument — read this before using the inventory as a completeness check.**
This connection reads through the standard API, which enforces field-level security. It can establish that a field **is** present. It **cannot** establish that a field is absent — only that this user cannot see it. Every "field count" below is therefore a count of fields *visible through the standard API on this connection*, not a count of fields defined in the org. Anything you expected to find and do not find here is **not visible through the standard API on this connection**; that is the only claim this document makes about it. A definitive absence check requires a Tooling API or Metadata API read under a profile with full field visibility.

Two further limits of the same kind:
- **Picklist definitions.** The value lists reproduced below come from the describe, so they are the values *exposed to this user on this record type*. Inactive values and values hidden by record-type or FLS restriction would not appear. Full picklist definitions require a Tooling read.
- **External Id.** The describe does not expose the external-id flag. Where a field is marked Unique below, that comes from `EntityParticle.IsUnique`; `IsIdLookup = true` on the same rows means the field is addressable as an id lookup, which is the shape a unique/external-id key takes. The document does not assert the external-id checkbox state.

**Scope of this inventory.** 13 custom objects and 4 custom metadata types.

**Total custom `AAO_` fields visible: 317** — 276 across the 13 objects, 41 across the 4 metadata types.

**Standard field set.** Every one of the 13 custom objects carries the standard set: `Id`, `Name` (**Auto Number** — verified via `EntityParticle.IsAutonumber = true` on all 13), `OwnerId`, `IsDeleted`, `CurrencyIsoCode` (multi-currency org; 12 currencies, default USD), `CreatedById`/`CreatedDate`, `LastModifiedById`/`LastModifiedDate`, `SystemModstamp`, and on most objects `LastViewedDate`/`LastReferencedDate`. The one exception is noted in its own section. Standard fields are not repeated in the tables below; only `AAO_` custom fields are listed.

**Per-object summary.**

| Object | Custom AAO_ fields | Records |
|---|---|---|
| AAO_Answer__c | 26 | 43 |
| AAO_Candidate__c | 25 | 225 |
| AAO_Claim__c | 32 | 100 |
| AAO_Claim_Basis__c | 11 | 0 |
| AAO_Created_Row__c | 9 | 22 |
| AAO_Criterion__c | 14 | 15 |
| AAO_Evidence_Contract__c | 28 | 84 |
| AAO_Flag__c | 28 | 13 |
| AAO_Pair__c | 29 | 371 |
| AAO_Participant__c | 15 | 53 |
| AAO_Run_Receipt__c | 16 | 3 |
| AAO_Shadow_Person__c | 21 | 0 |
| AAO_Source__c | 22 | 21 |
| **Objects total** | **276** | |
| AAO_Map_Value__mdt | 4 | 10 |
| AAO_Model_Config__mdt | 29 | 1 |
| AAO_People_Question__mdt | 5 | 56 |
| AAO_Setting__mdt | 3 | 1 |
| **Metadata total** | **41** | |
| **Grand total** | **317** | |

---

## AAO_Answer__c

AAO Answer. 26 custom fields. **43 records.**
Standard set present, including `LastViewedDate`/`LastReferencedDate`.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Account__c | Lookup (18) | Yes | — | → Account (`AAO_Account__r`) |
| AAO_Answer_Key__c | Text (120) | No | **Unique**, IdLookup | |
| AAO_Basis__c | Picklist (255) | No | — | State; Transcript; Both |
| AAO_Charter_Version__c | Text (20) | No | — | |
| AAO_Criterion__c | Lookup (18) | No | — | → AAO_Criterion__c (`AAO_Criterion__r`) |
| AAO_Element_Completeness__c | Long Text Area (32768) | No | — | |
| AAO_Element_Coverage__c | Long Text Area (32768) | No | — | |
| AAO_Established_By__c | Picklist (255) | Yes | — | MACHINE; HUMAN |
| AAO_Evidence_Contract__c | Lookup (18) | Yes | — | → AAO_Evidence_Contract__c (`AAO_Evidence_Contract__r`) |
| AAO_Evidence_Occurred__c | Date/Time | No | — | |
| AAO_Interpretation__c | Long Text Area (32768) | No | — | |
| AAO_Last_Claim__c | Lookup (18) | No | — | → AAO_Claim__c (`AAO_Last_Claim__r`) |
| AAO_Opportunity__c | Lookup (18) | Yes | — | → Opportunity (`AAO_Opportunity__r`) |
| AAO_Participant__c | Lookup (18) | No | — | → AAO_Participant__c (`AAO_Participant__r`) |
| AAO_Projected_Modstamp__c | Date/Time | No | — | |
| AAO_Projected_Value__c | Text (255) | No | — | |
| AAO_Publication_State__c | Picklist (255) | Yes | — | Live; Held; Declined |
| AAO_Question_Fingerprint__c | Text (64) | No | — | |
| AAO_Rubric_Version__c | Text (20) | No | — | |
| AAO_Shadow_Person__c | Lookup (18) | No | — | → AAO_Shadow_Person__c (`AAO_Shadow_Person__r`) |
| AAO_Spans__c | Long Text Area (32768) | No | — | |
| AAO_Subject_Contact__c | Lookup (18) | No | — | → Contact (`AAO_Subject_Contact__r`) |
| AAO_Subject_Type__c | Picklist (255) | Yes | — | Opportunity; Contact; Participant; Shadow_Person; Insight_Card; Qualifier; Decision_Criterion |
| AAO_Support_Counter__c | Number (2, 0) | No | — | |
| AAO_Synthetic__c | Checkbox | No | — | |
| AAO_Verdict__c | Picklist (255) | Yes | — | TRUE; FALSE; UNVERIFIED |

**Child relationships (AAO objects):** AAO_Claim_Basis__c.AAO_Cited_Answer__c, AAO_Claim__c.AAO_Answer__c, AAO_Flag__c.AAO_Answer__c.

### OBSERVED VALUES IN DATA — AAO_Answer__c (43 records)
Not the picklist definition. These are the distinct combinations actually present, via GROUP BY.

| Verdict | Established By | Publication State | Subject Type | Basis | n |
|---|---|---|---|---|---|
| TRUE | MACHINE | Live | Participant | Transcript | 27 |
| TRUE | MACHINE | Live | Contact | Transcript | 6 |
| TRUE | MACHINE | Live | Decision_Criterion | Transcript | 4 |
| TRUE | MACHINE | Live | Opportunity | (null) | 4 |
| UNVERIFIED | MACHINE | Live | Opportunity | (null) | 1 |
| UNVERIFIED | MACHINE | Live | Participant | Transcript | 1 |

Values defined but not present in data: Verdict FALSE; Established_By HUMAN; Publication_State Held and Declined; Subject_Type Shadow_Person, Insight_Card, Qualifier; Basis State and Both.

---

## AAO_Candidate__c

AAO Candidate. 25 custom fields. **225 records.**
Standard set present, including `LastViewedDate`/`LastReferencedDate`.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Abstention_Reason__c | Picklist (255) | No | — | nobody_said; model_declined; not_returned; model_missed (labelled "model_missed (retired)") |
| AAO_Account__c | Lookup (18) | Yes | — | → Account (`AAO_Account__r`) |
| AAO_Basis__c | Picklist (255) | No | — | State; Transcript; Both |
| AAO_Blind_Charter__c | Text (80) | No | — | Help text: written by the pipeline on every row a model pass produces, when the second reader ran; names the reader that ADJUDICATED COVERAGE (AAO_Charter__c names the reader that PROPOSED). Null means no second reader ran. |
| AAO_Blind_Charter_Version__c | Text (20) | No | — | Help text: written by the pipeline alongside AAO_Blind_Charter__c; attributes a coverage decision to a second reader. |
| AAO_Charter__c | Text (80) | Yes | — | |
| AAO_Charter_Version__c | Text (20) | Yes | — | |
| AAO_Claim__c | Lookup (18) | No | — | → AAO_Claim__c (`AAO_Claim__r`) |
| AAO_Criterion__c | Lookup (18) | No | — | → AAO_Criterion__c (`AAO_Criterion__r`) |
| AAO_Element_Completeness__c | Long Text Area (32768) | No | — | |
| AAO_Element_Coverage__c | Long Text Area (32768) | No | — | |
| AAO_Evidence_Contract__c | Lookup (18) | Yes | — | → AAO_Evidence_Contract__c (`AAO_Evidence_Contract__r`) |
| AAO_Interpretation__c | Long Text Area (32768) | No | — | |
| AAO_Opportunity__c | Lookup (18) | Yes | — | → Opportunity (`AAO_Opportunity__r`) |
| AAO_Outcome__c | Picklist (255) | Yes | — | Pending; Span_Failed; Upheld; Partial; Rejected; Downgraded_Speaker_Rank; Reinforced; Corroborated; Contention_Raised; Superseded_By_Human; Abstained; Not_Returned |
| AAO_Participant__c | Lookup (18) | No | — | → AAO_Participant__c (`AAO_Participant__r`) |
| AAO_Proposed_Verdict__c | Picklist (255) | No | — | TRUE; FALSE; UNVERIFIED |
| AAO_Publication_State__c | Picklist (255) | No | — | Live; Held; Declined |
| AAO_Shadow_Person__c | Lookup (18) | No | — | → AAO_Shadow_Person__c (`AAO_Shadow_Person__r`) |
| AAO_Source__c | Lookup (18) | No | — | → AAO_Source__c (`AAO_Source__r`) |
| AAO_Spans__c | Long Text Area (32768) | No | — | |
| AAO_Stage__c | Picklist (255) | Yes | — | Proposed; Span_Checked; Adjudicated; Reconciled; Committed |
| AAO_Subject_Contact__c | Lookup (18) | No | — | → Contact (`AAO_Subject_Contact__r`) |
| AAO_Subject_Type__c | Picklist (255) | Yes | — | Opportunity; Contact; Participant; Shadow_Person; Insight_Card; Qualifier; Decision_Criterion |
| AAO_Synthetic__c | Checkbox | No | — | |

No unique fields visible on this object.

**Child relationships (AAO objects):** AAO_Claim__c.AAO_Candidate__c, AAO_Flag__c.AAO_Candidate__c.

---

## AAO_Claim__c

AAO Claim. 32 custom fields. **100 records.**
Standard set present, including `LastViewedDate`/`LastReferencedDate`.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Account__c | Lookup (18) | Yes | — | → Account (`AAO_Account__r`) |
| AAO_Actor__c | Picklist (255) | Yes | — | MACHINE; HUMAN |
| AAO_Answer__c | Lookup (18) | Yes | — | → AAO_Answer__c (`AAO_Answer__r`) |
| AAO_Basis__c | Picklist (255) | Yes | — | State; Transcript; Both |
| AAO_Candidate__c | Lookup (18) | Yes | — | → AAO_Candidate__c (`AAO_Candidate__r`) |
| AAO_Charter__c | Text (80) | No | — | |
| AAO_Charter_Version__c | Text (20) | No | — | |
| AAO_Criterion__c | Lookup (18) | No | — | → AAO_Criterion__c (`AAO_Criterion__r`) |
| AAO_Element_Completeness__c | Long Text Area (32768) | No | — | |
| AAO_Element_Coverage__c | Long Text Area (32768) | No | — | |
| AAO_Evidence_Contract__c | Lookup (18) | Yes | — | → AAO_Evidence_Contract__c (`AAO_Evidence_Contract__r`) |
| AAO_Evidence_Occurred__c | Date/Time | Yes | — | |
| AAO_External_Person__c | Lookup (18) | No | — | → Contact (`AAO_External_Person__r`) |
| AAO_Internal_Person__c | Lookup (18) | No | — | → User (`AAO_Internal_Person__r`) |
| AAO_Interpretation__c | Long Text Area (32768) | No | — | |
| AAO_Opportunity__c | Lookup (18) | Yes | — | → Opportunity (`AAO_Opportunity__r`) |
| AAO_Outcome__c | Picklist (255) | Yes | — | Established; Reinforced; Corroborated; Downgraded; Demoted |
| AAO_Participant__c | Lookup (18) | No | — | → AAO_Participant__c (`AAO_Participant__r`) |
| AAO_Recorded_At__c | Date/Time | Yes | — | |
| AAO_Retired__c | Checkbox | No | — | |
| AAO_Retired_At__c | Date/Time | No | — | |
| AAO_Retired_Because__c | Long Text Area (4096) | No | — | |
| AAO_Retrospective__c | Checkbox | No | — | |
| AAO_Rubric_Version__c | Text (20) | No | — | |
| AAO_Shadow_Person__c | Lookup (18) | No | — | → AAO_Shadow_Person__c (`AAO_Shadow_Person__r`) |
| AAO_Source__c | Lookup (18) | No | — | → AAO_Source__c (`AAO_Source__r`) |
| AAO_Spans__c | Long Text Area (32768) | No | — | |
| AAO_Subject_Contact__c | Lookup (18) | No | — | → Contact (`AAO_Subject_Contact__r`) |
| AAO_Subject_Type__c | Picklist (255) | Yes | — | Opportunity; Contact; Participant; Shadow_Person; Insight_Card; Qualifier; Decision_Criterion |
| AAO_Synthetic__c | Checkbox | No | — | |
| AAO_Verdict_After__c | Picklist (255) | Yes | — | TRUE; FALSE; UNVERIFIED |
| AAO_Verdict_Before__c | Picklist (255) | No | — | TRUE; FALSE; UNVERIFIED |

No unique fields visible on this object.

**Child relationships (AAO objects):** AAO_Answer__c.AAO_Last_Claim__c, AAO_Candidate__c.AAO_Claim__c, AAO_Claim_Basis__c.AAO_Claim__c, AAO_Pair__c.AAO_Claim__c.

### OBSERVED VALUES IN DATA — AAO_Claim__c (100 records)
Not the picklist definition. Distinct combinations actually present, via GROUP BY.

| Outcome | Actor | Basis | Subject Type | Verdict Before | Verdict After | n |
|---|---|---|---|---|---|---|
| Reinforced | MACHINE | Transcript | Participant | TRUE | TRUE | 42 |
| Established | MACHINE | Transcript | Participant | (null) | TRUE | 28 |
| Corroborated | MACHINE | Transcript | Participant | TRUE | TRUE | 9 |
| Established | MACHINE | Transcript | Contact | (null) | TRUE | 6 |
| Established | MACHINE | Transcript | Decision_Criterion | (null) | TRUE | 4 |
| Established | MACHINE | Transcript | Opportunity | (null) | UNVERIFIED | 3 |
| Established | MACHINE | Transcript | Opportunity | UNVERIFIED | TRUE | 3 |
| Reinforced | MACHINE | Transcript | Decision_Criterion | TRUE | TRUE | 1 |
| Corroborated | MACHINE | Transcript | Decision_Criterion | TRUE | TRUE | 1 |
| Downgraded | MACHINE | Transcript | Opportunity | (null) | UNVERIFIED | 1 |
| Established | MACHINE | Transcript | Opportunity | FALSE | TRUE | 1 |
| Established | MACHINE | Transcript | Opportunity | (null) | FALSE | 1 |

Values defined but not present in data: Outcome Demoted; Actor HUMAN; Basis State and Both; Subject_Type Shadow_Person, Insight_Card, Qualifier.

---

## AAO_Claim_Basis__c

AAO Claim Basis. 11 custom fields. **0 records.**

**Standard set differs on this object.** The describe returns `Id`, `IsDeleted`, `Name` (Auto Number), `CurrencyIsoCode`, `CreatedById`/`CreatedDate`, `LastModifiedById`/`LastModifiedDate`, `SystemModstamp` — and no `OwnerId`, no `LastViewedDate`/`LastReferencedDate`, and no `AAO_Claim_Basis__Share` child relationship. `AAO_Claim__c` is a required reference. That is the shape of a master-detail child of AAO_Claim__c.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Cited_Answer__c | Lookup (18) | No | — | → AAO_Answer__c (`AAO_Cited_Answer__r`) |
| AAO_Cited_Line_Item__c | Lookup (18) | No | — | → OpportunityLineItem (`AAO_Cited_Line_Item__r`) |
| AAO_Cited_Map_Row__c | Lookup (18) | No | — | → **ALTF__Contact_Map_Details__c** (`AAO_Cited_Map_Row__r`) — reference to a managed Altify object |
| AAO_Cited_Row_Deleted__c | Checkbox | No | — | |
| AAO_Cited_Source__c | Lookup (18) | No | — | → AAO_Source__c (`AAO_Cited_Source__r`) |
| AAO_Cited_Type__c | Picklist (255) | Yes | — | Line_Item (label "Line Item"); Source; Map_Row; Insight_Card; Decision_Criterion; Answer; Qualifier_Status; Shadow_Person |
| AAO_Claim__c | Master-Detail / required reference (18) | Yes | — | → AAO_Claim__c (`AAO_Claim__r`) |
| AAO_Covers_Element__c | Text (40) | No | — | |
| AAO_Snapshot__c | Long Text Area (32768) | No | — | |
| AAO_Snapshot_Taken__c | Date/Time | No | — | |
| AAO_Synthetic__c | Checkbox | No | — | |

No unique fields visible on this object.

---

## AAO_Created_Row__c

AAO Created Row. 9 custom fields. **22 records.**
Standard set present. `LastViewedDate`/`LastReferencedDate` are not returned by the describe for this object.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Disowned__c | Checkbox | No | — | |
| AAO_Disowned_Because__c | Long Text Area (4096) | No | — | |
| AAO_Leg__c | Text (80) | Yes | — | |
| AAO_Reason__c | Long Text Area (4096) | No | — | |
| AAO_Run_Key__c | Text (64) | No | — | |
| AAO_Source__c | Lookup (18) | No | — | → AAO_Source__c (`AAO_Source__r`, child relationship `Created_Rows__r`) |
| AAO_Source_Form__c | Text (255) | No | — | |
| AAO_Target_Id__c | Text (18) | Yes | — | Text, not a reference — holds a record id as a string |
| AAO_Target_Object__c | Text (80) | Yes | — | |

No unique fields visible on this object.

---

## AAO_Criterion__c

AAO Criterion. 14 custom fields. **15 records.**
Standard set present. `LastViewedDate`/`LastReferencedDate` are not returned by the describe for this object.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Account__c | Lookup (18) | No | — | → Account (`AAO_Account__r`) |
| AAO_Criterion_Key__c | Text (80) | Yes | **Unique**, IdLookup | |
| AAO_Evidence_Occurred__c | Date/Time | No | — | |
| AAO_Opportunity__c | Lookup (18) | No | — | → Opportunity (`AAO_Opportunity__r`) |
| AAO_Projected_Criterion_Id__c | Text (18) | No | — | Text, not a reference |
| AAO_Projected_Modstamp__c | Date/Time | No | — | |
| AAO_Required__c | Checkbox | No | — | |
| AAO_Retired__c | Checkbox | No | — | |
| AAO_Retired_Because__c | Long Text Area (4096) | No | — | |
| AAO_Source__c | Lookup (18) | No | — | → AAO_Source__c (`AAO_Source__r`) |
| AAO_Subject__c | Text (255) | Yes | — | |
| AAO_Synthetic__c | Checkbox | No | — | |
| AAO_Type__c | Picklist (255) | No | — | Formal; **Informal (default)** |
| AAO_Voiced_By__c | Lookup (18) | No | — | → AAO_Participant__c (`AAO_Voiced_By__r`) |

**Child relationships (AAO objects):** AAO_Answer__c.AAO_Criterion__c, AAO_Candidate__c.AAO_Criterion__c, AAO_Claim__c.AAO_Criterion__c.

---

## AAO_Evidence_Contract__c

AAO Evidence Contract. 28 custom fields. **84 records.**
Standard set present. `LastViewedDate`/`LastReferencedDate` are not returned by the describe for this object.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Charter_Designation__c | Picklist (255) | No | — | People; Problems; Politics; Process |
| AAO_Content_Hash__c | Text (64) | Yes | — | |
| AAO_Contract_Key__c | Text (83) | No | **Unique**, IdLookup | |
| AAO_Contract_State__c | Picklist (255) | Yes | — | Derived; Awaiting_Ratification; Ratified; Superseded |
| AAO_Decay_Class__c | Picklist (255) | Yes | — | Event; Standing; Decaying |
| AAO_Element_Count__c | Number (2, 0) | Yes | — | |
| AAO_Elements__c | Long Text Area (32768) | No | — | |
| AAO_Elements_Basis__c | Picklist (255) | Yes | — | Authored; Inferred_Ratified; Inferred_Pending |
| AAO_Escalation_Threshold__c | Percent (5, 2) | No | — | |
| AAO_Family__c | Text (80) | No | — | Help text: which family this contract is read under (e.g. Buyer Role, Political Status, Decision criteria, Sentiment); blank falls back to the legacy code-prefix mapping. |
| AAO_Gating__c | Checkbox | No | — | |
| AAO_Guidance_Text__c | Long Text Area (32768) | No | — | |
| AAO_Per_Person_Source__c | Text (80) | No | — | |
| AAO_Prerequisites__c | Long Text Area (32768) | No | — | |
| AAO_Proposition_Code__c | Text (40) | No | — | |
| AAO_Proposition_Short__c | Text (255) | No | — | |
| AAO_Proposition_Text__c | Long Text Area (32768) | No | — | |
| AAO_Question_Record_Id__c | Text (18) | Yes | — | Text, not a reference |
| AAO_Ratified_By__c | Lookup (18) | No | — | → User (`AAO_Ratified_By__r`) |
| AAO_Ratified_On__c | Date/Time | No | — | |
| AAO_Required_Map_Role__c | Text (255) | No | — | |
| AAO_Requires_Ratification__c | Checkbox | No | — | |
| AAO_Route__c | Picklist (255) | Yes | — | P; C; E |
| AAO_Rubric_Version__c | Text (20) | Yes | — | |
| AAO_Solicit__c | Checkbox | No | — | |
| AAO_Speaker_Requirement__c | Picklist (255) | Yes | — | Seller; Any_Participant; Buyer_Side; Subject_Person (label "Subject Person"); Decision_Maker_Or_Influencer |
| AAO_Superseded_By__c | Lookup (18) | No | — | → AAO_Evidence_Contract__c, self-reference (`AAO_Superseded_By__r`; inverse `AAO_Supersedes__r`) |
| AAO_Synthetic__c | Checkbox | No | — | |

**Child relationships (AAO objects):** AAO_Answer__c, AAO_Candidate__c, AAO_Claim__c, AAO_Flag__c, AAO_Pair__c — each via their `AAO_Evidence_Contract__c`; plus the self-reference above.

---

## AAO_Flag__c

AAO Flag. 28 custom fields. **13 records.**
Standard set present, including `LastViewedDate`/`LastReferencedDate`.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Account__c | Lookup (18) | Yes | — | → Account (`AAO_Account__r`) |
| AAO_Acknowledged_At__c | Date/Time | No | — | |
| AAO_Acknowledged_By__c | Lookup (18) | No | — | → User (`AAO_Acknowledged_By__r`) |
| AAO_Acknowledgement_Text__c | Long Text Area (32768) | No | — | |
| AAO_Answer__c | Lookup (18) | No | — | → AAO_Answer__c (`AAO_Answer__r`) |
| AAO_Answer_Here__c | Text (255) | No | — | |
| AAO_Bound_Key__c | Text (120) | No | **Unique**, IdLookup | |
| AAO_Bounded_Path__c | Text (80) | No | — | |
| AAO_Candidate__c | Lookup (18) | No | — | → AAO_Candidate__c (`AAO_Candidate__r`) |
| AAO_Cause__c | Picklist (255) | Yes | — | Cardinality_Exceeded; Relation_Missing; Gating_Unmet; Established_False; History_Contradicts; History_Better; Awaiting_Ratification; Identity_Ambiguous; Identity_Unresolved |
| AAO_Ceiling__c | Number (9, 0) | No | — | |
| AAO_Cleared_At__c | Date/Time | No | — | |
| AAO_Coverage_Gap__c | Long Text Area (32768) | No | — | |
| AAO_Escalated_At__c | Date/Time | No | — | |
| AAO_Evidence_Contract__c | Lookup (18) | No | — | → AAO_Evidence_Contract__c (`AAO_Evidence_Contract__r`) |
| AAO_Evidence_Watermark__c | Text (255) | No | — | |
| AAO_Last_Evidence_Considered__c | Date/Time | No | — | |
| AAO_Missing_Count__c | Number (9, 0) | No | — | |
| AAO_Missing_Members__c | Long Text Area (32768) | No | — | |
| AAO_Opportunity__c | Lookup (18) | Yes | — | → Opportunity (`AAO_Opportunity__r`) |
| AAO_Proposed_Count__c | Number (9, 0) | No | — | |
| AAO_Raised_At__c | Date/Time | No | — | |
| AAO_Relation_Key__c | Text (80) | No | **Unique**, IdLookup | |
| AAO_Relation_Kind__c | Picklist (255) | No | — | Solution_Without_Problem ("Solution without a stated problem"); Pressure_Without_Goal ("Pressure with no linked goal"); Person_Without_Influence_Edge ("Person with no influence edges") |
| AAO_State__c | Picklist (255) | Yes | — | Standing; Escalated; Cleared |
| AAO_Subject_Contact__c | Lookup (18) | No | — | → Contact (`AAO_Subject_Contact__r`) |
| AAO_Synthetic__c | Checkbox | No | — | |
| AAO_Type__c | Picklist (255) | Yes | — | Methodological; Contention_Negative; Contention_Positive; Cardinality; Missing_Relation; Ratification; Identification |

No dismiss/dismissed field is visible through the standard API on this connection.

### OBSERVED VALUES IN DATA — AAO_Flag__c (13 records)
Not the picklist definition. Distinct combinations actually present, via GROUP BY.

| Type | Cause | State | Relation Kind | n |
|---|---|---|---|---|
| Methodological | Gating_Unmet | Standing | (null) | 8 |
| Methodological | Gating_Unmet | Cleared | (null) | 4 |
| Identification | Identity_Ambiguous | Standing | (null) | 1 |

Values defined but not present in data: Type Contention_Negative, Contention_Positive, Cardinality, Missing_Relation, Ratification; Cause Cardinality_Exceeded, Relation_Missing, Established_False, History_Contradicts, History_Better, Awaiting_Ratification, Identity_Unresolved; State Escalated; all three Relation_Kind values.

---

## AAO_Pair__c

AAO Pair. 29 custom fields. **371 records.**
Standard set present. `LastViewedDate`/`LastReferencedDate` are not returned by the describe for this object.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_About_Designator__c | Text (255) | No | — | Label "About (Designator)" |
| AAO_About_Quote__c | Long Text Area (4096) | No | — | Label "About (Introducing Quote)" |
| AAO_Answer_Text__c | Long Text Area (32768) | No | — | |
| AAO_Artifact_SHA256__c | Text (64) | No | — | |
| AAO_Charter__c | Text (80) | Yes | — | |
| AAO_Charter_Version__c | Text (40) | Yes | — | |
| AAO_Claim__c | Lookup (18) | No | — | → AAO_Claim__c (`AAO_Claim__r`) |
| AAO_Corroborated__c | Checkbox | No | — | |
| AAO_Coverage__c | Picklist (255) | No | — | Full; Partial |
| AAO_Criterion_Name__c | Text (255) | No | — | |
| AAO_Disposition__c | Picklist (255) | No | — | Identified; None; Held; Ambiguous; Merged |
| AAO_End_Offset__c | Number (9, 0) | No | — | |
| AAO_Evidence_Contract__c | Lookup (18) | No | — | → AAO_Evidence_Contract__c (`AAO_Evidence_Contract__r`) |
| AAO_Identification_Basis__c | Text (255) | No | — | |
| AAO_Located_Pair__c | Lookup (18) | No | — | → AAO_Pair__c, self-reference (`AAO_Located_Pair__r`; inverse `AAO_Identifications__r`) |
| AAO_Meaning__c | Text (128) | No | — | |
| AAO_Occurrence__c | Number (4, 0) | No | — | |
| AAO_Occurrence_Count__c | Number (4, 0) | No | — | |
| AAO_Pair_Key__c | Text (67) | No | **Unique**, IdLookup | |
| AAO_Pair_Ref__c | Text (32) | Yes | — | |
| AAO_Person__c | Lookup (18) | No | — | → AAO_Participant__c (`AAO_Person__r`) |
| AAO_Run_Key__c | Text (32) | Yes | — | |
| AAO_Source__c | Lookup (18) | No | — | → AAO_Source__c (`AAO_Source__r`) |
| AAO_Speaker_Key__c | Text (64) | No | — | |
| AAO_Stage__c | Picklist (255) | Yes | — | Located; Identified |
| AAO_Start_Offset__c | Number (9, 0) | No | — | |
| AAO_Synthetic__c | Checkbox | No | — | |
| AAO_Verification__c | Picklist (255) | No | — | Upheld; Refused |
| AAO_Verification_Note__c | Long Text Area (32768) | No | — | |

### OBSERVED VALUES IN DATA — AAO_Pair__c (371 records)
Not the picklist definition. Distinct combinations actually present, via GROUP BY.

| Stage | Disposition | Coverage | Verification | n |
|---|---|---|---|---|
| Located | (null) | Partial | (null) | 106 |
| Located | (null) | Full | (null) | 78 |
| Identified | Identified | (null) | Upheld | 76 |
| Identified | Identified | (null) | Refused | 58 |
| Located | (null) | (null) | (null) | 52 |
| Identified | Ambiguous | (null) | (null) | 1 |

Values defined but not present in data: Disposition None, Held, Merged.

---

## AAO_Participant__c

AAO Participant. 15 custom fields. **53 records.**
Standard set present. `LastViewedDate`/`LastReferencedDate` are not returned by the describe for this object.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Account__c | Lookup (18) | No | — | → Account (`AAO_Account__r`) |
| AAO_Artifact_SHA256__c | Text (64) | No | — | |
| AAO_Contact__c | Lookup (18) | No | — | → Contact (`AAO_Contact__r`) |
| AAO_Coverage_Projected_Modstamp__c | Date/Time | No | — | |
| AAO_Coverage_Projected_Value__c | Text (40) | No | — | |
| AAO_Display_Name__c | Text (255) | No | — | |
| AAO_Email__c | Email (80) | No | — | |
| AAO_Evidence_Occurred__c | Date/Time | No | — | |
| AAO_Internal__c | Checkbox | No | — | |
| AAO_Opportunity__c | Lookup (18) | No | — | → Opportunity (`AAO_Opportunity__r`) |
| AAO_Participant_Key__c | Text (120) | Yes | **Unique**, IdLookup | |
| AAO_Roster_Key__c | Text (80) | Yes | — | |
| AAO_Source__c | Lookup (18) | Yes | — | → AAO_Source__c (`AAO_Source__r`) |
| AAO_Substantive__c | Checkbox | No | — | |
| AAO_Synthetic__c | Checkbox | No | — | |

**Child relationships (AAO objects):** AAO_Answer__c.AAO_Participant__c, AAO_Candidate__c.AAO_Participant__c, AAO_Claim__c.AAO_Participant__c, AAO_Criterion__c.AAO_Voiced_By__c, AAO_Pair__c.AAO_Person__c, AAO_Shadow_Person__c.AAO_Participant__c.

---

## AAO_Run_Receipt__c

AAO Run Receipt. 16 custom fields. **3 records.**
Standard set present. `LastViewedDate`/`LastReferencedDate` are not returned by the describe for this object.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Cache_State__c | Text (8) | No | — | |
| AAO_Callouts__c | Number (6, 0) | No | — | |
| AAO_Charter_Versions__c | Long Text Area (4096) | No | — | |
| AAO_First_Stage_At__c | Date/Time | No | — | |
| AAO_Last_Stage_At__c | Date/Time | No | — | |
| AAO_Normalizer_Version__c | Text (64) | No | — | |
| AAO_Opportunity__c | Lookup (18) | No | — | → Opportunity (`AAO_Opportunity__r`) |
| AAO_Receipt_Key__c | Text (80) | Yes | **Unique**, IdLookup | |
| AAO_Run_Key__c | Text (32) | Yes | — | |
| AAO_Source__c | Lookup (18) | No | — | → AAO_Source__c (`AAO_Source__r`, child relationship `Run_Receipts__r`) |
| AAO_Split_Events__c | Number (6, 0) | No | — | |
| AAO_Stage_Count__c | Number (4, 0) | No | — | |
| AAO_Stages__c | Long Text Area (32768) | No | — | |
| AAO_Synthetic__c | Checkbox | No | — | |
| AAO_Total_Wall_Ms__c | Number (12, 0) | No | — | |
| AAO_Worst_Callout_Ms__c | Number (12, 0) | No | — | |

---

## AAO_Shadow_Person__c

AAO Shadow Person. 21 custom fields. **0 records.**
Standard set present. `LastViewedDate`/`LastReferencedDate` are not returned by the describe for this object.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Account__c | Lookup (18) | No | — | → Account (`AAO_Account__r`) |
| AAO_Anchor_Count__c | Number (9, 0) | No | — | |
| AAO_Anchors__c | Long Text Area (32768) | No | — | |
| AAO_Designator__c | Text (255) | No | — | Label "Designator (as heard)" |
| AAO_Display_Name__c | Text (255) | No | — | |
| AAO_Email__c | Email (80) | No | — | |
| AAO_First_Name__c | Text (80) | No | — | |
| AAO_Identity_Provenance__c | Picklist (255) | No | — | Utterance; Roster; Account_Contact_Match; Enrichment_Partner; Human |
| AAO_Last_Name__c | Text (80) | No | — | |
| AAO_Participant__c | Lookup (18) | No | — | → AAO_Participant__c (`AAO_Participant__r`) |
| AAO_Promoted_At__c | Date/Time | No | — | |
| AAO_Promoted_Contact__c | Lookup (18) | No | — | → Contact (`AAO_Promoted_Contact__r`) |
| AAO_Reason__c | Picklist (255) | Yes | — | Toggle_Off; Create_Failed; Unresolvable; Ambiguous; Single_Token |
| AAO_Reason_Detail__c | Long Text Area (1024) | No | — | |
| AAO_Shadow_Key__c | Text (180) | Yes | **Unique**, IdLookup | |
| AAO_Source_Name__c | Text (255) | No | — | |
| AAO_Synthetic__c | Checkbox | No | — | |
| AAO_Utterance_End__c | Number (18, 0) | No | — | |
| AAO_Utterance_Quote__c | Long Text Area (4096) | No | — | |
| AAO_Utterance_Source__c | Lookup (18) | No | — | → AAO_Source__c (`AAO_Utterance_Source__r`; inverse `Shadow_People__r`) |
| AAO_Utterance_Start__c | Number (18, 0) | No | — | |

**Child relationships (AAO objects):** AAO_Answer__c, AAO_Candidate__c, AAO_Claim__c — each via their `AAO_Shadow_Person__c`.

---

## AAO_Source__c

AAO Source. 22 custom fields. **21 records.**
Standard set present, including `LastViewedDate`/`LastReferencedDate`.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Account__c | Lookup (18) | Yes | — | → Account (`AAO_Account__r`) |
| AAO_Artifact_SHA256__c | Text (64) | No | — | |
| AAO_Boundary_Basis__c | Text (40) | No | — | |
| AAO_Diarization__c | Picklist (255) | Yes | — | Attributed; Segmented; Unsegmented |
| AAO_Duration_Seconds__c | Number (9, 0) | No | — | |
| AAO_Evidence_Occurred__c | Date/Time | No | — | |
| AAO_Meeting_Title__c | Text (255) | No | — | Help text: the meeting title from the source system (Teams, Gong), carried verbatim; blank where the source carried none. |
| AAO_Normalized_Text__c | Long Text Area (131072) | No | — | Largest text field in the schema |
| AAO_Normalizer_Version__c | Text (20) | No | — | |
| AAO_Opportunity__c | Lookup (18) | Yes | — | → Opportunity (`AAO_Opportunity__r`) |
| AAO_Origin__c | Picklist (255) | No | — | ECI; ingest; note |
| AAO_Part_Count__c | Number (3, 0) | No | — | |
| AAO_Part_Index__c | Number (3, 0) | No | — | |
| AAO_Raw_SHA256__c | Text (64) | No | — | |
| AAO_SHA256__c | Text (64) | No | — | |
| AAO_Scope_Key__c | Text (101) | No | **Unique**, IdLookup | |
| AAO_Source_Ref__c | Text (255) | No | — | |
| AAO_Speaker_Roster__c | Long Text Area (32768) | No | — | |
| AAO_Substantive_Offset__c | Number (9, 0) | No | — | |
| AAO_Synthetic__c | Checkbox | No | — | |
| AAO_System_Ref__c | Text (255) | No | — | |
| AAO_Trim_Manifest__c | Long Text Area (32768) | No | — | |

**Child relationships (AAO objects):** AAO_Candidate__c, AAO_Claim__c, AAO_Criterion__c, AAO_Pair__c, AAO_Participant__c via `AAO_Source__c`; AAO_Created_Row__c (`Created_Rows__r`); AAO_Run_Receipt__c (`Run_Receipts__r`); AAO_Claim_Basis__c.AAO_Cited_Source__c; AAO_Shadow_Person__c.AAO_Utterance_Source__c (`Shadow_People__r`).

---

# Custom metadata types

All four carry the standard custom-metadata set: `Id`, `DeveloperName` (40), `MasterLabel` (40, required), `Language` (picklist, required, 18 languages), `NamespacePrefix` (15), `Label` (40), `QualifiedApiName` (70), `SystemModstamp`. Only `AAO_` fields are listed. `NamespacePrefix` is present on all four; its value per record is not read here.

Record counts come from `SELECT COUNT() FROM <type>`.

## AAO_Map_Value__mdt

AAO Map Value. 4 custom fields. **10 records.**

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Dimension__c | Text (40) | Yes | — | |
| AAO_Displayed_Label__c | Text (255) | No | — | |
| AAO_Rank__c | Number | No | — | Precision not exposed for `__mdt` fields through `EntityParticle` on this connection |
| AAO_Stored_Value__c | Text (80) | Yes | — | |

## AAO_Model_Config__mdt

AAO Model Config. 29 custom fields. **1 record.**
Most fields carry inline help text; it is reproduced because it states who writes and who reads each field.

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Active__c | Checkbox | No | — | Written by a human in this record; read by AAO_Extract, which refuses to call out when false. The switch that stops model calls without a deploy. |
| AAO_Anthropic_Beta__c | Text (255) | No | — | Sent as the `anthropic-beta` header when non-blank; blank is the normal case. |
| AAO_Bind_Charter__c | Text (80) | No | — | Stage 2 charter name, stamped on the Candidate rows binding promotes. |
| AAO_Bind_Charter_Version__c | Text (20) | No | — | Version of the stage 2 charter. |
| AAO_Bind_Group_Size__c | Number | No | — | How many bind items ride in one callout. Help text: MEASURED, never assumed (ruling 6, 3 August inbox). |
| AAO_Bind_Model__c | Text (80) | No | — | Charters v2.4 P7.3 stage 2. Must differ from AAO_Verify_Model__c; `AAO_Extract.requireSeparateModels` throws before the callout. |
| AAO_Blind_Charter__c | Text (80) | Yes | — | Read by AAO_Extract.review; separate charter from extraction, versioned independently. |
| AAO_Blind_Charter_Version__c | Text (20) | Yes | — | Bumped when the blind reader's prompt or output schema changes. Help text notes no field on AAO_Candidate__c carries this yet. |
| AAO_Blind_Enabled__c | Checkbox | No | — | Read by AAO_Pipeline. When false the second reader does not run and coverage falls back to elements with located spans. |
| AAO_Charter__c | Text (80) | Yes | — | Stamped onto AAO_Candidate__c.AAO_Charter__c. |
| AAO_Charter_Version__c | Text (20) | Yes | — | Stamped onto every Candidate; the grain abstention analysis groups by. |
| AAO_Effort__c | Text (20) | Yes | — | Sent as `output_config.effort`. |
| AAO_Endpoint_Path__c | Text (120) | Yes | — | Path appended to the named credential, normally `/v1/messages`. |
| AAO_Inventory_Charter__c | Text (80) | No | — | Stage 1 charter name, stamped on every Candidate the read produces. |
| AAO_Inventory_Charter_Version__c | Text (20) | No | — | Version of the stage 1 charter. |
| AAO_Inventory_Effort__c | Text (20) | No | — | Stage 1 only; blank falls back to Effort. |
| AAO_Inventory_Max_Output_Tokens__c | Number | No | — | Hard output bound for stage 1, derived from measured generation rate and the 120-second callout ceiling. |
| AAO_Inventory_Model__c | Text (80) | No | — | Charters v2.4 P7.3 stage 1. Blank falls back to AAO_Model_Name__c. |
| AAO_Max_Findings_Per_Pass__c | Number | No | — | |
| AAO_Max_Output_Tokens__c | Number | Yes | — | Sent as `max_tokens`. |
| AAO_Model_Name__c | Text (80) | Yes | — | Sent as the model id and stamped on every Candidate row; never hardcoded in Apex. |
| AAO_Named_Credential__c | Text (80) | Yes | — | AAO_Extract builds `callout:{this}/{endpoint path}`. Hostname and API key appear nowhere in Apex. |
| AAO_Probe__c | Text (10) | No | — | |
| AAO_Timeout_Ms__c | Number | Yes | — | Set on the HttpRequest. Apex caps this at 120000. |
| AAO_Verify_Charter__c | Text (80) | No | — | Stage 3 charter name; distinct from AAO_Blind_Charter__c. |
| AAO_Verify_Charter_Version__c | Text (20) | No | — | Version of the stage 3 charter. |
| AAO_Verify_Group_Size__c | Number | No | — | How many verify items ride in one callout; measured, never assumed. |
| AAO_Verify_Model__c | Text (80) | No | — | Charters v2.4 P7.3 stage 3, the blind reader; established by probe from the calling runtime and recorded in BUILD_JOURNAL. |
| AAO_Verify_Temperature__c | Number | No | — | Sampling temperature for stage 3 only; blank means the key is not sent at all. |

## AAO_People_Question__mdt

AAO People Question. 5 custom fields. **56 records.**

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Org_Override__c | Long Text Area (1024) | No | — | |
| AAO_Provenance__c | Picklist (255) | No | — | **Label (default)**; UI_Capture (label "UI Capture") |
| AAO_Question_Key__c | Text (120) | Yes | — | |
| AAO_Sequence__c | Number | No | — | |
| AAO_Shipped_Text__c | Long Text Area (1024) | No | — | |

## AAO_Setting__mdt

AAO Setting. 3 custom fields. **1 record.**

| Field API name | Type (length/precision) | Required | Unique / External Id | Notes |
|---|---|---|---|---|
| AAO_Note__c | Long Text Area (1024) | No | — | |
| AAO_Org_Override__c | Picklist (255) | No | — | On; Off |
| AAO_Shipped_Default__c | Checkbox | No | — | |

---

# Read method, for reproduction

1. `SELECT Id, Name, IsSandbox, InstanceName, OrganizationType FROM Organization LIMIT 1` — org identity.
2. `getObjectSchema` with comma-separated object lists, in batches of 3-4 — field name, label, type, length, required, `referenceTo`, relationship name, picklist values, inline help text, child relationships.
3. `SELECT EntityDefinition.QualifiedApiName, QualifiedApiName, IsUnique, IsIdLookup FROM EntityParticle WHERE EntityDefinition.QualifiedApiName IN (...) AND IsUnique = true` — the unique-key column. An `IN` clause combined with an equality filter works on `EntityParticle` on this org; a single-object `EntityDefinition.QualifiedApiName = 'X'` filter combined with `QualifiedApiName LIKE 'AAO_%'` also works. (The task brief notes that `FieldDefinition` errors with INVALID_OPERATION when `IN` is combined with `LIKE`; `FieldDefinition` was not needed here.)
4. Same shape filtered on `DataType IN ('double','percent','int','currency')` — numeric precision and scale, which the describe does not return.
5. Same shape filtered on `QualifiedApiName = 'Name'` selecting `IsAutonumber` — confirmed Auto Number on all 13.
6. `SELECT COUNT(Id) n FROM <object>` per object. For `__mdt` types `COUNT(Id)` is rejected with MALFORMED_QUERY ("field Id does not support aggregate operator COUNT"); `SELECT COUNT() FROM <type>` was used instead and the count read from `totalSize`.
7. GROUP BY aggregates on AAO_Pair__c, AAO_Flag__c, AAO_Answer__c and AAO_Claim__c for observed picklist values.

Every object and metadata type in scope was readable. No read failed.
