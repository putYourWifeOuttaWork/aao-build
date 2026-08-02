# RAW: Relationship Map / Insight Map projection surface — org schema and scope evidence

Pulled 2026-08-02 from Altify production org via SFDC MCP (read-only). Source of truth: `mcp__SFDC_MCP__getObjectSchema` + SOQL. All picklist values, descriptions, and inlineHelpText verbatim from describe. The describe output carried NO `description` values for any field on these objects; only `inlineHelpText` where noted. Where neither is listed, both were absent.

Row counts as of pull:

| Object | Rows |
|---|---|
| ALTF__Contact_Map_Details__c | 40,350 |
| ALTF__Contact__c | 10,369 |
| ALTF__Contact_Influence__c | 1,949 |
| ALTF__Relationship_Map_Persona__c | 63 |
| ALTF__LOR_Relationship__c | 213 |
| ALTF__Insight_Card__c | 65,632 |
| ALTF__Insight_Card_Contact__c | 9,944 |
| ALTF__Insight_Card_Edge__c | 11,708 |
| ALTF__Insight_Section__c | 4,288 |
| ALTF__Insight_Card_Section__c | 66,526 |
| ALTF__Decision_Criteria__c | 404 |
| ALTF__Object_Relationship__c | 3 |

Standard system fields (Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate) are present on every object and omitted from the per-object tables below except where the Name label is informative. CurrencyIsoCode picklist on every object: AUD, GBP, CAD, EUR, ILS, JPY, MYR, NZD, ZAR, CHF, TRY, USD (default).

---

## ALTF__Contact_Map_Details__c — "Altify Contact Map Details" — 40,350 rows

Record Name label: "Altify Contact Detail Name" (string 80, autonumber-like legacy ids in data, e.g. `a3v60000000L4Ly`).

| API name | Label | Type (len) | Req | Picklist values (verbatim label=value) | referenceTo | Help text |
|---|---|---|---|---|---|---|
| ALTF__Account__c | Account | reference (18) | yes | — | Account | — |
| ALTF__Contact__c | Contact | reference (18) | yes | — | Contact | — |
| ALTF__Opportunity__c | Opportunity | reference (18) | no | — | Opportunity | — |
| ALTF__User__c | User | reference (18) | no | — | User | — |
| ALTF__Status__c | Support | picklist (255) | no | Mentor=Mentor; Supporter=Supporter; Neutral=Neutral; Non-Supporter=Non-Supporter; Enemy=Enemy; Unknown=Unknown | — | — |
| ALTF__Status_Answer__c | Status Answer | string (255) | no | — | — | — |
| ALTF__Status_Last_Modified__c | Status Last Modified | datetime | no | — | — | — |
| ALTF__Political__c | Political Status | picklist (255) | no | Inner Circle=Inner Circle; Political Structure=Political Structure; Outside Political Structure=Outside Political Structure; Unknown=Unknown | — | — |
| ALTF__Political_Answer__c | Political Answer | string (255) | no | — | — | — |
| ALTF__Political_Last_Modified__c | Political Last Modified | datetime | no | — | — | — |
| ALTF__Coverage__c | Coverage | picklist (255) | no | In-depth=In-depth; Multiple contacts=Multiple contacts; Brief contact=Brief contact; No Contact=No Contact; Unknown=Unknown | — | — |
| ALTF__Coverage_Answer__c | Coverage Answer | string (255) | no | — | — | — |
| ALTF__Coverage_Last_Modified__c | Coverage Last Modified | datetime | no | — | — | — |
| ALTF__Buyer_Role__c | Buyer Role | picklist (255) | no | Approver=Approver; Decision Maker=Decision Maker; Evaluator=Evaluator; User=User; Signature Approver=Signature Approver; Unknown=Unknown | — | — |
| ALTF__Buyer_Role_Answer__c | Buyer Role Answer | string (255) | no | — | — | — |
| ALTF__Buyer_Role_Last_Modified__c | Buyer Role Last Modified | datetime | no | — | — | — |
| ALTF__Decision_Orientation__c | Decision Orientation | picklist (255) | no | Financial=Financial; Technical=Technical; Relationship=Relationship; Business=Business; Unknown=Unknown | — | — |
| ALTF__Decision_Orientation_Last_Modified__c | Decision Orientation Last Modified | datetime | no | — | — | — |
| ALTF__Account_Relationship__c | Internal Flag | picklist (255) | no | **No=Internal; Yes=External** (label and value inverted-looking; verbatim) | — | — |
| ALTF__Account_Relationship_Last_Modified__c | Internal Flag Last Modified | datetime | no | — | — | — |
| ALTF__Is_Key_Player__c | Is Key Player | boolean | no | — | — | — |
| ALTF__Note__c | Note | textarea (1024) | no | — | — | — |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |
| ALTF__Sibling_Sort_Order__c | Sibling Sort Order | double | no | — | — | — |
| ALTF__Division__c | DEPRECATED Division | reference (18) | no | — | ALTF__Account_Division__c | — |
| ALTF__Is_Favourite__c | Is Favourite (Deprecated) | boolean | no | — | — | inlineHelpText: "This field is deprecated and no longer used." |
| ALTF__Squares__c | Squares (Deprecated) | double | no | — | — | inlineHelpText: "This field is deprecated and no longer used." |
| ALTF__Color__c | Color | string (1300, formula-length) | no | — | — | — |
| ALTF__ConcatenatedFields__c | ConcatenatedFields | string (1300) | no | — | — | — |

Note the label/value disagreement on ALTF__Account_Relationship__c: label "Internal Flag", picklist entries are label "No" → value "Internal", label "Yes" → value "External". Stored data uses value "Internal".

No _Answer__c field exists for Decision Orientation or for the Internal Flag; the five Answer/Last_Modified pairs cover Status, Political, Coverage, Buyer Role, plus Decision Orientation and Account Relationship have Last_Modified only.

## ALTF__Contact__c — "Altify Contact" — 10,369 rows

| API name | Label | Type (len) | Req | Picklist values | referenceTo | Help |
|---|---|---|---|---|---|---|
| ALTF__Contact__c | Contact | reference (18) | yes | — | Contact | — |
| ALTF__Adaptability__c | Adaptability | picklist (255) | no | Innovator; Visionary; Pragmatist; Conservative; Laggard; Unknown (labels=values) | — | — |
| ALTF__Adaptability_Last_Modified__c | Adaptability Last Modified | datetime | no | — | — | — |
| ALTF__Altify_Personas__c | Altify Personas | multipicklist (4099) | no | CEO; CRO; Executive Sponsor; Sales Leader; RevOps Leader; Enablement Leader; IT Leader; Procurement Lead; Altify Program Owner; Consultant; Legal; Partner (labels=values) | — | — |
| ALTF__Owner__c | Owner | reference (18) | no | — | User | — |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |

Adaptability lives here (per-person, account/opportunity-agnostic), NOT on Contact_Map_Details. No opportunity or account lookup on this object.

## ALTF__Contact_Influence__c — "Altify Contact Influence" — 1,949 rows

Record Name label: "RelationshipMap_Influence Name".

| API name | Label | Type (len) | Req | Picklist values | referenceTo | Help |
|---|---|---|---|---|---|---|
| ALTF__Influenced_Contact__c | Influenced Contact | reference (18) | yes | — | Contact | — |
| ALTF__Influencing_Contact__c | Influencing Contact | reference (18) | no | — | Contact | — |
| ALTF__Type__c | Type | picklist (255) | yes | Conflict=Conflict; Influence=Influence | — | — |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |
| ALTF__ConcatenatedFields__c | ConcatenatedFields | string (1300) | no | — | — | — |

No account or opportunity lookup — influence edges are global per contact pair, not scoped per map.

## ALTF__Relationship_Map_Persona__c — "Altify Relationship Map Persona" — 63 rows

| API name | Label | Type (len) | Req | Picklist values | referenceTo | Help |
|---|---|---|---|---|---|---|
| ALTF__Account__c | Account | reference (18) | yes | — | Account | — |
| ALTF__Opportunity__c | Opportunity | reference (18) | no | — | Opportunity | — |
| ALTF__Persona__c | Persona | multipicklist (4099) | no | CEO; CRO; Executive Sponsor; Sales Leader; RevOps Leader; Enablement Leader; IT Leader; Procurement Lead; Altify Program Owner; Consultant; Legal; Partner | — | — |
| ALTF__Functional_Role__c | Functional Role | multipicklist (4099) | no | Placeholder=Placeholder (sole value) | — | — |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |
| ALTF__ConcatenatedFields__c | ConcatenatedFields | string (1300) | no | — | — | — |

Carries both account (required) and opportunity (optional) lookups — same dual-scope pattern as Contact_Map_Details.

## ALTF__LOR_Relationship__c — "Altify LOR Relationship" — 213 rows

Record Name label: "Altify Contact User Name".

| API name | Label | Type (len) | Req | Picklist values | referenceTo | Help |
|---|---|---|---|---|---|---|
| ALTF__Contact__c | Contact | reference (18) | yes | — | Contact | — |
| ALTF__User__c | User | reference (18) | no | — | User | — |
| ALTF__CurrentLOR__c | CurrentLOR | picklist (255) | no | 0. Unknown=Unknown; 1. Vendor=Vendor; 2. Credible Source=Credible Source; 3. Problem Solver=Problem Solver; 4. Trusted Advisor=Trusted Advisor | — | — |
| ALTF__DesiredLOR__c | DesiredLOR | picklist (255) | no | 0. Unknown=Unknown; 1. Vendor=Vendor; 2. Credible Source=Credible Source; 3. Problem Solver=Problem Solver; 4. Trusted Advisor=Trusted Advisor; None=None | — | — |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |
| ALTF__ConcatenatedFields__c | ConcatenatedFields | string (1300) | no | — | — | — |

Note DesiredLOR carries an extra value "None" that CurrentLOR lacks; labels carry ordinal prefixes ("1. Vendor") while stored values do not ("Vendor"). NO account or opportunity lookup — LOR is keyed contact+user, so it cannot be scope-split; it is scope-agnostic by construction. Only 213 rows against 10,369 Altify Contacts.

## ALTF__Insight_Card__c — "Altify Insight Card" — 65,632 rows

Record Name label: "Insight Node Name". Child relationships include ALTF__Insight_Node_Contacts__r, ALTF__Insight_Node_Edges__r (twice: via ALTF__Insight_Card__c and via ALTF__Solution_Insight_Card__c), ALTF__Insight_Node_Topics__r (Insight_Card_Section), ALTF__Decision_Criteria_Obstacles__r (Decision_Criteria_Insight_Card), ALTF__Altify_Object_Relationships__r.

| API name | Label | Type (len) | Req | Picklist values | referenceTo | Help |
|---|---|---|---|---|---|---|
| ALTF__Account__c | Account | reference (18) | yes | — | Account | — |
| ALTF__Opportunity__c | Opportunity | reference (18) | no | — | Opportunity | — |
| ALTF__Type__c | Type | picklist (255) | no | Goal=Goal; Pressure=Pressure; Initiative=Initiative; Obstacle=Obstacle; Solution=Solution | — | — |
| ALTF__Pressure_Type__c | Pressure Type | multipicklist (4099) | no | Operational; Financial; Competitive; Supplier; Market; Partner; Technology; Customer | — | — |
| ALTF__Priority__c | Priority | picklist (255) | no | Low=Low; Medium=Medium; High=High | — | — |
| ALTF__Short_Description__c | Short Description | string (255) | no | — | — | — |
| ALTF__Long_Description__c | Long Description | textarea (1024) | no | — | — | — |
| ALTF__Impact__c | Impact | textarea (2000) | no | — | — | — |
| ALTF__Solution__c | Altify Solution | reference (18) | no | — | ALTF__Solution__c | — |
| ALTF__Confirmed__c | Confirmed | boolean | no | — | — | — |
| ALTF__ConfirmedBy__c | ConfirmedBy | reference (18) | no | — | User | — |
| ALTF__ConfirmedOn__c | ConfirmedOn | datetime | no | — | — | — |
| ALTF__Completed__c | Completed | boolean | no | — | — | — |
| ALTF__CompletedBy__c | CompletedBy | reference (18) | no | — | User | — |
| ALTF__CompletedOn__c | CompletedOn | datetime | no | — | — | — |
| ALTF__Private__c | Private | boolean | no | — | — | — |
| ALTF__Generated_By_Max__c | Insight Generated By Max | boolean | no | — | — | — |
| ALTF__Last_Modified__c | Last Modified | datetime | no | — | — | — |
| ALTF__Insight_Card_Contact_Last_Mod__c | Insight Node Contact Last Mod | datetime | no | — | — | — |
| ALTF__Insight_Card_Edge_Last_Mod__c | Insight Node Edge Last Mod | datetime | no | — | — | — |
| ALTF__Note__c | Note (Deprecated) | string (255) | no | — | — | inlineHelpText: "This field is deprecated and no longer used." |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |

Label drift: object label "Insight Card", record-name label "Insight Node Name", child relationship names use both "Insight_Node_*" and "Insight_Card_*".

## ALTF__Insight_Card_Contact__c — "Altify Insight Card Contact" — 9,944 rows

| API name | Label | Type (len) | Req | Picklist values | referenceTo | Help |
|---|---|---|---|---|---|---|
| ALTF__Contact__c | Contact | reference (18) | yes | — | Contact | — |
| ALTF__Insight_Card__c | Insight Node | reference (18) | yes | — | ALTF__Insight_Card__c | — |
| ALTF__Type__c | Type | picklist (255) | **yes** | Informer=Informer; Owner=Owner | — | — |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |
| ALTF__ConcatenatedFields__c | ConcatenatedFields | string (1300) | no | — | — | — |

## ALTF__Insight_Card_Edge__c — "Altify Insight Card Edge" — 11,708 rows

| API name | Label | Type (len) | Req | Picklist values | referenceTo | Help |
|---|---|---|---|---|---|---|
| ALTF__Insight_Card__c | Insight Card | reference (18) | yes | — | ALTF__Insight_Card__c | — |
| ALTF__Solution_Insight_Card__c | Solution Insight Node | reference (18) | no | — | ALTF__Insight_Card__c | — |
| ALTF__Insight_Section__c | Altify Topic | reference (18) | no | — | ALTF__Insight_Section__c | — |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |

Edge target is either another card (Solution_Insight_Card) or a section ("Altify Topic") — both optional, source card required.

## ALTF__Insight_Section__c — "Altify Insight Section" — 4,288 rows

Record Name label: "Altify Topic Name".

| API name | Label | Type (len) | Req | Picklist values | referenceTo | Help |
|---|---|---|---|---|---|---|
| ALTF__Account__c | Account | reference (18) | yes | — | Account | — |
| ALTF__Opportunity__c | Opportunity | reference (18) | no | — | Opportunity | — |
| ALTF__Division__c | Division | reference (18) | no | — | ALTF__Account_Division__c | — |
| ALTF__Short_Description__c | Short Description | string (255) | no | — | — | — |
| ALTF__X_Coordinate__c | X Coordinate | double | **yes** | — | — | — |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |

Yes: carries BOTH account (required) and opportunity (optional) lookups. X coordinate only — sections are columns.

## ALTF__Insight_Card_Section__c — "Altify Insight Card Section" — 66,526 rows

Record Name label: "Insight Node Topic Name".

| API name | Label | Type (len) | Req | Picklist values | referenceTo | Help |
|---|---|---|---|---|---|---|
| ALTF__Insight_Card__c | Insight Card | reference (18) | yes | — | ALTF__Insight_Card__c | — |
| ALTF__Insight_Section__c | Insight Section | reference (18) | no | — | ALTF__Insight_Section__c | — |
| ALTF__X_Coordinate__c | X Coordinate | double | **yes** | — | — | — |
| ALTF__Y_Coordinate__c | Y Coordinate | double | **yes** | — | — | — |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |
| ALTF__ConcatenatedFields__c | ConcatenatedFields | string (1300) | no | — | — | — |

Card placement on the map: one row per card per (map) placement, section optional. 66,526 rows ≈ 65,632 cards, i.e. ~1 placement per card.

## ALTF__Decision_Criteria__c — "Altify Decision Criteria" — 404 rows

Children: ALTF__Decision_Criterion_Contacts__r, ALTF__Decision_Criteria_Obstacles__r (join to Insight Card), ALTF__Decision_Criteria_Positions__r.

| API name | Label | Type (len) | Req | Picklist values | referenceTo | Help |
|---|---|---|---|---|---|---|
| ALTF__Account__c | Account | reference (18) | yes | — | Account | — |
| ALTF__Opportunity__c | Opportunity | reference (18) | no | — | Opportunity | — |
| ALTF__Type__c | Type | picklist (255) | no | Formal=Formal; Informal=Informal | — | — |
| ALTF__Subject__c | Subject | textarea (255) | no | — | — | — |
| ALTF__Milestone__c | Milestone | string (80) | no | — | — | — |
| ALTF__Required__c | Required | boolean | no | — | — | — |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |

## ALTF__Object_Relationship__c — "Altify Object Relationship" — 3 rows

Has OwnerId (own sharing model; ALTF__Object_Relationship__Share child).

| API name | Label | Type (len) | Req | Picklist values | referenceTo | Help |
|---|---|---|---|---|---|---|
| ALTF__Insight_Card__c | Altify Insight Card | reference (18) | no | — | ALTF__Insight_Card__c | inlineHelpText: "A lookup to an associated Insight Card." |
| ALTF__Objective__c | Altify Objective | reference (18) | no | — | ALTF__Account_Objective__c | inlineHelpText: "A lookup to an associated Objective." |
| ALTF__Opportunity__c | Opportunity | reference (18) | no | — | Opportunity | inlineHelpText: "A lookup to an associated opportunity." |
| ALTF__AltifyId__c | AltifyId | string (100) | no | — | — | — |

Only object in the set with inlineHelpText on its lookups; all three lookups optional; effectively unused (3 rows).

---

# Account vs Opportunity scope

Scope discriminator on all dual-scope objects: `ALTF__Opportunity__c` (null = account-level map, populated = opportunity-level map). `ALTF__Account__c` is required on all of them, so opp-scoped rows also carry the account.

## 1. Scope split

Queries:
```
SELECT COUNT(Id) FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c = null
SELECT COUNT(Id) FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c != null
SELECT COUNT(Id) FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = null
SELECT COUNT(Id) FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c != null
SELECT COUNT(Id) FROM ALTF__Insight_Section__c WHERE ALTF__Opportunity__c = null
SELECT COUNT(Id) FROM ALTF__Insight_Section__c WHERE ALTF__Opportunity__c != null
```

| Object | Account-level (opp null) | Opp-level (opp not null) | Total |
|---|---|---|---|
| ALTF__Contact_Map_Details__c | 21,734 (53.9%) | 18,616 (46.1%) | 40,350 |
| ALTF__Insight_Card__c | 34,067 (51.9%) | 31,565 (48.1%) | 65,632 |
| ALTF__Insight_Section__c | 2,217 (51.7%) | 2,071 (48.3%) | 4,288 |

## 2. Account rich in both scopes

```
SELECT ALTF__Account__c, ALTF__Account__r.Name, COUNT(Id) c FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c = null GROUP BY ALTF__Account__c, ALTF__Account__r.Name ORDER BY COUNT(Id) DESC LIMIT 10
```

Top account-level accounts: HPE 234, Verisign 189, Altify Inc 154, Orange-France Telecom 133, Salesforce UK Partner 129, Xerox 128, Akamai 120, T-Mobile USA 103, British Telecom 87, T-Mobile (Parent) 86.

```
SELECT ALTF__Account__c, COUNT(Id) c FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c != null AND ALTF__Account__c IN ('001Hn00002CXGarIAH','001Hn00002CXEMPIA5','001Hn00002CXEAsIAP','001Hn00002CXGr3IAH','001Hn00002CXH9nIAH') GROUP BY ALTF__Account__c ORDER BY COUNT(Id) DESC
```

HPE 145, Orange 19, Altify Inc 16; Verisign and Salesforce UK Partner have ZERO opp-scoped rows. Chosen account: **Hewlett Packard Enterprise (HPE), 001Hn00002CXGarIAH** — 234 account-level, 145 opp-level.

## 3. HPE sample rows (10 per scope)

Queries (verbatim):
```
SELECT Id, Name, ALTF__Contact__r.Name, ALTF__Status__c, ALTF__Status_Answer__c, ALTF__Political__c, ALTF__Political_Answer__c, ALTF__Coverage__c, ALTF__Coverage_Answer__c, ALTF__Buyer_Role__c, ALTF__Buyer_Role_Answer__c, ALTF__Decision_Orientation__c, ALTF__Account_Relationship__c, ALTF__Is_Key_Player__c, ALTF__Note__c, ALTF__User__c, ALTF__Sibling_Sort_Order__c FROM ALTF__Contact_Map_Details__c WHERE ALTF__Account__c = '001Hn00002CXGarIAH' AND ALTF__Opportunity__c = null LIMIT 10
```
and the same with `!= null` plus `ALTF__Opportunity__r.Name`.

Account-level sample (HPE):

| Contact | Support | Political | Coverage | Buyer Role | Dec. Orient. | Int.Flag | KeyPlayer |
|---|---|---|---|---|---|---|---|
| Matt Cox | Mentor | Outside Political Structure | In-depth | null | Business | null | false |
| Stefan Merz | Supporter | Inner Circle | Brief contact | null | null | null | true |
| Luke Ng | null | null | null | null | null | null | false |
| Olivier Suinat | null | null | null | null | null | null | false |
| Peter Ryan | Supporter | Inner Circle | Brief contact | null | null | null | true |
| Carlo Giorgi | Supporter | Outside Political Structure | Unknown | null | null | null | false |
| Lee Chew Tan | null | null | null | null | null | null | false |
| Chuck Battipede | null | null | null | null | null | null | false |
| Ankit Shah | null | null | null | null | null | null | false |
| John Haro | Neutral | Outside Political Structure | Multiple contacts | null | null | null | false |

All 10: every *_Answer__c null; Note null; Sibling_Sort_Order null; ALTF__User__c populated (same user 005Hn00000JbyVLIAZ). Buyer_Role null on ALL account-level sample rows; Account_Relationship (Internal Flag) null on all.

Opp-level sample (HPE; opps "HPE_Dummy", "HPE_SW_500 Lic"):

| Contact | Opp | Support | Political | Coverage | Buyer Role | Dec. Orient. | Int.Flag | KeyPlayer | Note |
|---|---|---|---|---|---|---|---|---|---|
| Lauren Wingfield | HPE_Dummy | Unknown | Unknown | Brief contact | Unknown | null | null | false | `<p>Owns RO relationship.</p>` (HTML in textarea) |
| Greg Giles | HPE_SW_500 Lic | null | null | Brief contact | Evaluator | null | Internal | false | null |
| Wade Wilson | HPE_SW_500 Lic | Supporter | Political Structure | Multiple contacts | Evaluator | null | Internal | true | null |
| Barbara Way | HPE_SW_500 Lic | null | null | null | null | null | Internal | false | null |
| Akeem Mostamandy | HPE_SW_500 Lic | null | null | Multiple contacts | Evaluator | null | Internal | false | null |
| Lauree Hinkle | HPE_SW_500 Lic | null | null | null | null | null | Internal | false | null |
| Christian Pruitt | HPE_SW_500 Lic | null | null | null | null | null | Internal | false | null |
| Patrick Nalu | HPE_SW_500 Lic | null | null | null | null | null | Internal | false | null |
| Jim Webster | HPE_SW_500 Lic | null | null | null | null | null | Internal | false | null |
| Leslie Gay | HPE_SW_500 Lic | Neutral | Political Structure | Brief contact | Evaluator | Internal | true | | |

(Last row: Support=Neutral, Political=Political Structure, Coverage=Brief contact, Buyer Role=Evaluator, Dec.Orient.=null, Int.Flag=Internal, KeyPlayer=true.) All *_Answer__c null in sample; Decision_Orientation null on ALL opp-level sample rows.

Sample pattern: account-level rows carry Decision Orientation but never Buyer Role; opp-level rows carry Buyer Role and Internal Flag but rarely Decision Orientation. Confirmed by whole-object fill rates below.

## 4. Whole-object fill rates per scope — ALTF__Contact_Map_Details__c

Queries (verbatim; SOQL COUNT(field) counts non-null):
```
SELECT COUNT(Id) total, COUNT(ALTF__Status__c) status_f, COUNT(ALTF__Status_Answer__c) status_ans, COUNT(ALTF__Political__c) political_f, COUNT(ALTF__Political_Answer__c) political_ans, COUNT(ALTF__Coverage__c) coverage_f, COUNT(ALTF__Coverage_Answer__c) coverage_ans, COUNT(ALTF__Buyer_Role__c) buyer_f, COUNT(ALTF__Buyer_Role_Answer__c) buyer_ans, COUNT(ALTF__Decision_Orientation__c) do_f, COUNT(ALTF__Account_Relationship__c) acctrel_f, COUNT(ALTF__User__c) user_f FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c = null
```
(and `!= null` variant), plus:
```
SELECT COUNT(Id) kp FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c = null AND ALTF__Is_Key_Player__c = true
SELECT COUNT(Id) kp FROM ALTF__Contact_Map_Details__c WHERE ALTF__Opportunity__c != null AND ALTF__Is_Key_Player__c = true
```

| Field | Account-level filled / 21,734 | Opp-level filled / 18,616 |
|---|---|---|
| ALTF__Status__c (Support) | 7,283 (33.5%) | 10,206 (54.8%) |
| ALTF__Status_Answer__c | 3 (0.01%) | 21 (0.11%) |
| ALTF__Political__c | 7,602 (35.0%) | 10,689 (57.4%) |
| ALTF__Political_Answer__c | 10 (0.05%) | 36 (0.19%) |
| ALTF__Coverage__c | 8,519 (39.2%) | 11,418 (61.3%) |
| ALTF__Coverage_Answer__c | 2 (0.01%) | 13 (0.07%) |
| ALTF__Buyer_Role__c | 337 (1.6%) | 7,467 (40.1%) |
| ALTF__Buyer_Role_Answer__c | 0 (0%) | 1 (0.005%) |
| ALTF__Decision_Orientation__c | 5,596 (25.7%) | 571 (3.1%) |
| ALTF__Account_Relationship__c (Internal Flag) | 11,456 (52.7%) | 10,040 (53.9%) |
| ALTF__User__c | 17,160 (79.0%) | 15,367 (82.5%) |
| ALTF__Is_Key_Player__c = true | 3,813 (17.5%) | 6,129 (32.9%) |
| ALTF__Note__c | not countable (textarea does not support COUNT aggregate or WHERE filter) | same |

Errored queries (verbatim error): the first fill-rate attempt included `COUNT(ALTF__Note__c) note_f` and failed with
`field ALTF__Note__c does not support aggregate operator COUNT` (MALFORMED_QUERY). Rerun without Note.

LOR fields: no fill-rate split possible — ALTF__CurrentLOR__c / ALTF__DesiredLOR__c live on ALTF__LOR_Relationship__c, which has no account or opportunity lookup (keyed Contact + User). 213 rows total.

Adaptability: lives on ALTF__Contact__c (10,369 rows), also unscoped — one value per person regardless of map.

## 5. ALTF__Insight_Card__c per scope

Type breakdown:
```
SELECT ALTF__Type__c, COUNT(Id) c FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = null GROUP BY ALTF__Type__c
SELECT ALTF__Type__c, COUNT(Id) c FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c != null GROUP BY ALTF__Type__c
```

| Type | Account-level | Opp-level |
|---|---|---|
| Goal | 4,927 | 5,527 |
| Pressure | 6,554 | 5,863 |
| Initiative | 5,596 | 5,469 |
| Obstacle | 14,065 | 11,985 |
| Solution | 2,925 | 2,721 |
| Total | 34,067 | 31,565 |

All five types used in both scopes, similar mix; Obstacle dominates both (41% / 38%).

Key-field fill:
```
SELECT COUNT(Id) total, COUNT(ALTF__Solution__c) sol_f, COUNT(ALTF__Priority__c) pri_f, COUNT(ALTF__Short_Description__c) short_f, COUNT(ALTF__ConfirmedBy__c) confby_f, COUNT(ALTF__CompletedBy__c) compby_f FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = null
```
(and `!= null`), plus boolean/multipicklist counts:
```
SELECT COUNT(Id) c FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = null AND ALTF__Confirmed__c = true
SELECT COUNT(Id) c FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c != null AND ALTF__Confirmed__c = true
SELECT COUNT(Id) c FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = null AND ALTF__Pressure_Type__c != null
SELECT COUNT(Id) c FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c != null AND ALTF__Pressure_Type__c != null
```

| Field | Account-level / 34,067 | Opp-level / 31,565 |
|---|---|---|
| ALTF__Short_Description__c | 34,061 (100.0%) | 31,565 (100%) |
| ALTF__Confirmed__c = true | 6,196 (18.2%) | 5,979 (18.9%) |
| ALTF__ConfirmedBy__c | 1,786 (5.2%) | 2,308 (7.3%) |
| ALTF__CompletedBy__c | 114 (0.3%) | 148 (0.5%) |
| ALTF__Solution__c (lookup) | 295 (0.9%) | 745 (2.4%) |
| ALTF__Priority__c | 156 (0.5%) | 169 (0.5%) |
| ALTF__Pressure_Type__c != null | 368 (1.1%) | 384 (1.2%) |
| ALTF__Impact__c | not countable (textarea 2000 — no COUNT, no WHERE filter) | same |

Note Confirmed=true (≈18-19%) vastly exceeds ConfirmedBy fill (5-7%): most confirmations carry no confirming user — legacy migration or API writes that set the flag without provenance.

Errored queries (verbatim error): first attempt included `COUNT(ALTF__Pressure_Type__c) ptype_f` and failed with
`field ALTF__Pressure_Type__c does not support aggregate operator COUNT` (MALFORMED_QUERY). Multipicklist counted via WHERE != null instead.

## 6. ALTF__Insight_Section__c scope

Carries both lookups: ALTF__Account__c required, ALTF__Opportunity__c optional (plus ALTF__Division__c).

```
SELECT COUNT(Id) FROM ALTF__Insight_Section__c WHERE ALTF__Opportunity__c = null    → 2,217
SELECT COUNT(Id) FROM ALTF__Insight_Section__c WHERE ALTF__Opportunity__c != null  → 2,071
```

Same ~52/48 split as cards — sections are per-map furniture, duplicated per scope.

---

## Cross-cutting observations

1. The dual-scope pattern (Account required + Opportunity optional) holds for: Contact_Map_Details, Relationship_Map_Persona, Insight_Card, Insight_Section, Decision_Criteria. It does NOT hold for: Contact (Altify Contact — person-global), Contact_Influence (pair-global), LOR_Relationship (contact+user-global), Insight_Card_Contact / Insight_Card_Edge / Insight_Card_Section (inherit scope via parent card/section).
2. The Answer-path fields (ALTF__*_Answer__c) are essentially empty at both scopes: 15 non-null of 40,350 for the three assessment answers combined at account level, 71 at opp level. The verbatim-answer channel exists in the schema and is unused in practice.
3. Buyer Role is an opportunity-scope dimension in practice (1.6% vs 40.1%). Decision Orientation is an account-scope dimension in practice (25.7% vs 3.1%). The other three assessment dimensions (Support, Political, Coverage) are used at both scopes, noticeably fuller on opp maps (+20pts each).
4. Description fields: describe returned no `description` on any field; inlineHelpText exists only on deprecated-field notices (Contact_Map_Details Is_Favourite/Squares, Insight_Card Note) and on the three Object_Relationship lookups. The only label/value disagreement of note is ALTF__Account_Relationship__c: label "Internal Flag" with picklist labels No/Yes mapped to values Internal/External.
5. Insight_Card sample note field content can contain HTML (`<p>...</p>` seen in Contact_Map_Details ALTF__Note__c).
