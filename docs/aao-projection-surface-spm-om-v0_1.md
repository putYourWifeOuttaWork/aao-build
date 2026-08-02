# AAO Projection Surface — SPM + OM — RAW schema pull

Source: Altify sandbox org via SFDC MCP (read-only), API v64.0. Pulled 2026-08-02 with `getObjectSchema` and `soqlQuery`. Nothing below is editorialized; field lists, picklist values, descriptions and inline help are verbatim as returned by the API. HTML entities (`&amp;`, `&#39;`, `&quot;`, `&gt;`) appear exactly as the API returned them. Some inlineHelpText values are truncated by the API mid-sentence; they are recorded as returned.

Row counts are `SELECT COUNT() FROM <object>`, same session.

---

# SPM chain

## ALTF__Sales_Process__c (label: Altify Sales Process)

Row count: **5**

Package child relationships (ALTF-only): ALTF__Opportunity__c via ALTF__Qualification_Sales_Process_Type_Stamp__c (ALTF__Altify_Opportunities1__r); ALTF__Opportunity__c via ALTF__Sales_Process__c (ALTF__Altify_Opportunities__r); ALTF__Sales_Process_Mapping__c via ALTF__Sales_Process__c (ALTF__DM_Sales_Process_Maps__r); ALTF__Sales_Process_Stage__c via ALTF__Sales_Process__c (ALTF__DM_Sales_Process_Stages__r).

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| OwnerId | Owner ID | reference(18) | no | | Group, User | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Sales Process Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| LastViewedDate | Last Viewed Date | datetime | no | | | |
| LastReferencedDate | Last Referenced Date | datetime | no | | | |
| ALTF__Industry_Vertical__c | Industry Vertical | picklist(255) | no | High Technology; Professional Services; Energy &amp; Power; Financial Services; Healthcare; Industrials; Materials; Telecommunications; Other; Build My Own | | inlineHelpText: "The industry that is relevant for your Sales Process." |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |
| ALTF__Average_Deal_Size__c | Average Deal Size | currency | no | | | inlineHelpText: "Enter the size of a typical or average sales opportunity." |
| ALTF__Closure_Duration__c | Closure Duration (Days) | double | no | | | inlineHelpText: "Enter the number of days typically taken to close an opportunity after all steps have been completed.  This can be zero." |
| ALTF__ComparisionJSONFileName__c | ComparisionJSONFileName | string(255) | no | | | |
| ALTF__Default_Process__c | Default Process | boolean | no | | | |
| ALTF__Description__c | Description | textarea(32768) | no | | | inlineHelpText: "Enter a description for the Sales Process that conveys sufficient information when you are subsequently viewing or editing the process." |
| ALTF__Disabled__c | Disabled Process | boolean | no | | | |
| ALTF__Final_Stage_Probability__c | Final Stage Probability % | percent | no | | | inlineHelpText: "This is the probability of the opportunity closing after all steps have been completed.  This is usually 100%" |
| ALTF__IsActive__c | Active | boolean | no | | | inlineHelpText: "Not in use" |
| ALTF__Multiple_Buyers__c | Multiple Buyers | boolean | no | | | inlineHelpText: "Do you usually sell to a single individual or are there many people involved in the buying process? Select Multiple or Single buyer." |
| ALTF__Order__c | Order Number | double | no | | | inlineHelpText: "Not in use" |
| ALTF__Pebble_Percentage__c | Pebble Percentage | percent | no | | | |
| ALTF__Pebble_Value__c | Pebble Value | currency | no | | | |
| ALTF__Rock_Percentage__c | Rock Percentage | percent | no | | | |
| ALTF__Rock_Value__c | Rock Value | currency | no | | | |
| ALTF__Sales_Cycle_Duration__c | Sales Cycle Duration (Days) | double | no | | | inlineHelpText: "Enter the number of days that it usually takes to close a sales opportunity from the time when it first became an opportunity to when you close the deal" |
| ALTF__Template_Stage_List__c | Genius Stage List | textarea(1000) | no | | | |
| ALTF__Threshold__c | Projected Threshold | percent | no | | | inlineHelpText: "Used for Forecasting. \n\nAn opportunity must achieve the threshold percentage (and be within the forecasting close date) in order to be deemed &quot;Projected&quot; in the Forecast Analysis for Altify." |
| ALTF__Version__c | Version | double | no | | | inlineHelpText: "A version number for the sales process. Auto-incremented. DO NOT UPDATE MANUALLY.\n\nOn change of a sales process, existing opportunities will be associated with the &quot;old&quot; version id. Altify can then identify any opps that need to be &quot;reset&quot;." |
| ALTF__Total_Sales_Cycle_Duration__c | Total Sales Cycle Duration | double | no | | | |
| ALTF__Sum_Of_Stages_Duration__c | Sum Of Stages Duration | double | no | | | |

---

## ALTF__Sales_Process_Stage__c (label: Altify Sales Process Stage)

Row count: **20**

Package child relationships: ALTF__Opportunity__c via ALTF__Sales_Process_Stage__c (ALTF__Altify_Opportunities__r); ALTF__Sales_Process_Stage_Qualifier__c via ALTF__Sales_Process_Stage__c (ALTF__DM_Sales_Process_Stage_Qualifiers__r).

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Sales Process Stage Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| ALTF__Sales_Process__c | Sales Process | reference(18) | **yes** | | ALTF__Sales_Process__c | |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |
| ALTF__Amber__c | Amber | percent | no | | | inlineHelpText: "Percentage completion (calculated as percent of achieved score on the stage) of the stage before the UI will display as amber/yellow for that stage.\n\nEnter a value from 0 - 100. The recommended default is 50 (%)." |
| ALTF__Duration__c | Duration | double | no | | | inlineHelpText: "Length of time (in weeks) an opportunity typically takes to be worked through the stage.\n\nNote that Altify will track the length of time actually taken, so that you can see how you&#39;re tracking against expectations over time." |
| ALTF__Green__c | Green | percent | no | | | inlineHelpText: "Percentage completion (calculated as percent of achieved score on the stage) on the stage before the UI will display as green for that stage.\n\nEnter a value from 0 - 100. The recommended default is 80 (%)." |
| ALTF__Qualification__c | Qualification Threshold | percent | no | | | inlineHelpText: "The percentage score that must be achieved on the stage before the opportunity can move to the next stage. \n\nNote that all &quot;mandatory&quot; qualifiers must also be achieved before the opportunity can move." |
| ALTF__SortOrder__c | Sort Order | double | **yes** | | | inlineHelpText: "Order of the stage within the sales process pipeline" |
| ALTF__Stage__c | Stage Name | reference(18) | no | | ALTF__Stage__c | inlineHelpText: "One of the pipeline stages associated with this Sales Process. Each process contains the Stages an Opportunity follows through its sales cycle." |

---

## ALTF__Sales_Process_Stage_Qualifier__c (label: Altify Sales Process Stage Qualifier)

Row count: **122**

Package child relationships: none (leaf junction; only standard SF child relationships).

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Sales Process Stage Qualifier Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| ALTF__Sales_Process_Stage__c | Sales Process Stage | reference(18) | **yes** | | ALTF__Sales_Process_Stage__c | |
| ALTF__Importance__c | Importance | picklist(255) | no | Nice to have (default); Important; Very important; Essential | | inlineHelpText: "Relative importance of this qualifier in the sales process.\n\nNote that the importance level provided will impact:\n- Closure Probability \n- Close Date\n- Stage (highest importance qualifiers must be completed to move the opp. to the next stage)" |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |
| ALTF__Mandatory__c | Mandatory | boolean | no | | | inlineHelpText: "Mandatory qualifiers must be completed before the opportunity can move to a future stage in the sales process, regardless of whether or not the overall qualification threshold of the stage has been reached." |
| ALTF__Sales_Process_Qualifier__c | Qualifier | reference(18) | no | | ALTF__Sales_Process_Qualifier__c | inlineHelpText: "Select the global qualifier to link to this sales process stage" |
| ALTF__Sort_Order__c | Sort Order | double | no | | | inlineHelpText: "The order in which this qualifier is displayed relative to the other qualifiers in the stage.\n\nYou should make the order value unique for each qualifier in the stage, to guarantee the same order display each time." |

### Sample row (junction shape confirmation) — verbatim

```json
{
  "Id": "a19Hn00000HFzeZIAT",
  "Name": "Why Act: We are aware of the decision maker's goal(s) and pressure(s) driving th",
  "ALTF__Sales_Process_Stage__c": "a1AHn000007QfWwMAK",
  "ALTF__Sales_Process_Qualifier__c": "a17Hn00000GemHKIAZ",
  "ALTF__Importance__c": "Very important",
  "ALTF__Mandatory__c": true,
  "ALTF__Sort_Order__c": 1,
  "ALTF__AltifyId__c": "00DHn000006jYatMAE-a19Hn00000HFzeZIAT",
  "CurrencyIsoCode": "USD"
}
```

---

## ALTF__Sales_Process_Qualifier__c (label: Altify Sales Process Qualifier)

Row count: **203**

Package child relationships: ALTF__Qualifier_Answer__c via ALTF__Sales_Process_Qualifier__c (ALTF__DM_Qualifier_Answers__r); ALTF__Qualifier_Quicklink__c via ALTF__Sales_Process_Qualifier__c (ALTF__DM_Qualifier_Quicklinks__r); ALTF__Sales_Process_Stage_Qualifier__c via ALTF__Sales_Process_Qualifier__c (ALTF__DM_Sales_Process_Stage_Qualifiers__r); ALTF__Translation__c via ALTF__Qualifier__c (ALTF__Content_Translations__r).

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| OwnerId | Owner ID | reference(18) | no | | Group, User | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Qualifier Shortname | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| LastViewedDate | Last Viewed Date | datetime | no | | | |
| LastReferencedDate | Last Referenced Date | datetime | no | | | |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |
| ALTF__Question__c | Question | textarea(1024) | no | | | inlineHelpText (truncated as returned by API): "The text for the qualifier / verifiable outcome, displayed to the user on the &quot;Sales Process&quot; tab in Altify.\n\nTo progress an opportunity through the pipeline, the user sets the status on the qualifiers associated with each stage in the sales pr" |
| ALTF__Tip__c | Tip | textarea(32768) | no | | | inlineHelpText (truncated as returned by API): "The help text associated with the qualifier / verifiable outcome. \n\nUse this section to provide instructions to the user on what the question is asking them to focus on, what steps they should take and/or what details they should provide in the co" |
| ALTF__UI_Readonly__c | Smart Qualifier | boolean | no | | | inlineHelpText: "A Smart Qualifier cannot be set by a user on the playbook UI screen. \nIt is anticipated that these qualifiers will be set by other means (triggers etc)" |

---

## ALTF__Qualifier_Answer__c (label: Altify Qualifier Answer)

Row count: **3024**

Package child relationships: none.

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Qualifier Answer Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| ALTF__Opportunity__c | Altify Opportunity | reference(18) | **yes** | | ALTF__Opportunity__c | |
| ALTF__Status__c | Status | picklist(255) | no | No; In progress; Yes (no default flagged) | | |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |
| ALTF__Comment__c | Comment | textarea(32768) | no | | | |
| ALTF__Completion__c | Completion | date | no | | | |
| ALTF__CompositeKey__c | Composite Key | string(100) | no | | | |
| ALTF__Sales_Process_Qualifier__c | DM Qualifier | reference(18) | no | | ALTF__Sales_Process_Qualifier__c | |

### Status values actually in use — verbatim query result

`SELECT ALTF__Status__c, COUNT(Id) FROM ALTF__Qualifier_Answer__c GROUP BY ALTF__Status__c`

| ALTF__Status__c | COUNT(Id) |
|---|---|
| null | 76 |
| In progress | 648 |
| No | 428 |
| Yes | 1872 |

---

## ALTF__Stage__c (label: Altify Stage)

Row count: **4**

Package child relationships: ALTF__Opportunity__c via ALTF__Qualification_Stage__c (ALTF__Altify_Opportunities__r); ALTF__Sales_Process_Stage__c via ALTF__Stage__c (ALTF__DM_Sales_Process_Stages__r).

Note the Name label as returned: "DM Stage Extra Name".

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| OwnerId | Owner ID | reference(18) | no | | Group, User | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | DM Stage Extra Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| LastViewedDate | Last Viewed Date | datetime | no | | | |
| LastReferencedDate | Last Referenced Date | datetime | no | | | |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |
| ALTF__SortOrder__c | SortOrder | double | **yes** | | | |

---

## ALTF__Template_Qualifier__c (label: Altify Template Qualifier)

Row count: **155**

Package child relationships: ALTF__Template_Qualifier_Details__c via ALTF__Template_Qualifier__c (ALTF__Template_Qualifier__r).

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| OwnerId | Owner ID | reference(18) | no | | Group, User | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Qualifier Shortname | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |
| ALTF__Question__c | Qualifier Longname | string(255) | **yes** | | | |
| ALTF__Template_Qualifier_ID__c | DMGQualifierID | string(100) | **yes** | | | |
| ALTF__Tip__c | Tip | textarea(32768) | no | | | |

---

## ALTF__Template_Qualifier_Details__c (label: Altify Template Qualifier Detail)

Row count: **449**

Package child relationships: none.

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| OwnerId | Owner ID | reference(18) | no | | Group, User | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Template Qualifier Config Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| ALTF__Template_Type__c | Template Type | picklist(255) | no | High Technology; Professional Services; Energy &amp; Power; Financial Services; Healthcare; Industrials; Materials; Telecommunications; Other | | |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |
| ALTF__Buyer_Type__c | Buyer Type | multipicklist(4099) | no | Single; Multiple | | |
| ALTF__Deal_Size__c | Deal Size | multipicklist(4099) | no | Small; Medium; Large | | |
| ALTF__Importance__c | Importance | double | **yes** | | | |
| ALTF__Sales_Cycle_Length__c | Sales Cycle Length | multipicklist(4099) | no | Short; Medium; Long | | |
| ALTF__Sequence_Number__c | Sequence Number | double | **yes** | | | |
| ALTF__Stage_Number__c | Stage Number | double | **yes** | | | |
| ALTF__Template_Qualifier_ID__c | DMGQualifierID | string(100) | **yes** | | | |
| ALTF__Template_Qualifier__c | Template Qualifier | reference(18) | no | | ALTF__Template_Qualifier__c | |

---

## ALTF__Qualifier_Quicklink__c (label: Altify Qualifier Quicklink)

Row count: **4**

Package child relationships: none.

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Qualifier Quicklink Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| LastViewedDate | Last Viewed Date | datetime | no | | | |
| LastReferencedDate | Last Referenced Date | datetime | no | | | |
| ALTF__Sales_Process_Qualifier__c | Qualifier | reference(18) | **yes** | | ALTF__Sales_Process_Qualifier__c | inlineHelpText: "The qualifier that the quicklink should be displayed beside." |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |
| ALTF__Quicklink__c | Quicklink | reference(18) | no | | ALTF__Quicklink__c | inlineHelpText: "The quicklink that should be made available for the associated qualifier. Selected from the defined list of quicklinks." |
| ALTF__SortOrder__c | SortOrder | double | no | | | inlineHelpText: "Order in which the quicklink is displayed if there is more than one quicklink associated with this qualifier." |

---

## ALTF__Sales_Process_Settings__c (label: Altify Sales Process Settings — custom setting, has SetupOwnerId)

Row count: **1**

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| SetupOwnerId | Location | reference(18) | no | | Organization, Profile, User | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| ALTF__Allow_Sales_Process_Popup__c | Allow Sales Process Popup | boolean | no | | | inlineHelpText: "Enable Sales Process to be selected/changed on the page" |
| ALTF__Disable_Sales_Process_Overview__c | Disable Sales Process Overview | boolean | no | | | inlineHelpText: "Disable the Sales Process overview panel on the OM Sales Process tab." |
| ALTF__Mock_Opp_Created_Date_Field__c | Mock Opp Created Date Field | string(200) | no | | | |
| ALTF__Mock_Opp_Health_Field__c | Mock DM Opp Health Field | string(200) | no | | | |
| ALTF__Opp_Amount_Field__c | Opp Amount Field | string(255) | no | | | inlineHelpText: "Leave blank to have Sales Process and Team View use the standard opportunity amount field. Set this to the API name of a custom opportunity field to have Sales Process and Team View refer to a custom amount field." |
| ALTF__Process_Selection_Field__c | Process Selection Field | string(200) | no | | | inlineHelpText: "This value allows an administrator to control which opportunity field to reference to determine which sales process will be selected." |
| ALTF__Revenue_Goal_Field__c | Revenue Goal Field | string(255) | no | | | inlineHelpText: "If set then Team View will display the appropriate &quot;pro rata&quot; value for the quota beside the user and may provide some visual feedback as to how user is performing against quota." |
| ALTF__Template_Company_Name__c | Genius Company Name | string(100) | no | | | inlineHelpText: "This stores the chosen value for the Company Name that is used when generating the Qualifiers. This is set the first time Genius is run and should not be subsequently updated." |
| ALTF__Template_Customer_Reference__c | Genius Customer Reference | string(100) | no | | | inlineHelpText: "This stores the chosen value for the Customer Reference that is used when generating the Qualifiers. This is set the first time Genius is run and should not be subsequently updated." |
| ALTF__Update_Opportunity_Close_Date__c | Update Opportunity Close Date | boolean | no | | | inlineHelpText: "This field allows an administrator to control whether or Altify will write back the calculated close date to the Opportunity Close Date field" |
| ALTF__Update_Opportunity_Probability__c | Update Opportunity Probability | boolean | no | | | inlineHelpText: "This field allows an administrator to control whether or not Altify will write back the calculated probability to the Opportunity probability field" |
| ALTF__Update_Opportunity_Stage__c | Update Opportunity Stage | boolean | no | | | inlineHelpText: "This field allows an administrator to control whether or Altify will write back the calculated Stage to the Opportunity Stage field" |
| ALTF__Use_Sales_Process_Map__c | Use Sales Process Map | boolean | no | | | inlineHelpText: "This field allows an administrator to enable Altify to use the Sales Process Mapping custom object to map opportunities to particular sales proceses" |

---

# OM chain

## ALTF__Assessment_Answer__c (label: Altify Assessment Answer)

Row count: **18365**

Package child relationships: ALTF__Assessment_Competitor_Answer__c via ALTF__Assessment_Answer__c (ALTF__DM_TAS_Criterion_Competitor_Answers__r).

Note the Name label as returned: "Assessment Criterion Answer Name".

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Assessment Criterion Answer Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| ALTF__Opportunity__c | Altify Opportunities | reference(18) | **yes** | | ALTF__Opportunity__c | |
| ALTF__Answer__c | Answer | picklist(255) | no | Unknown (default); Yes; No | | |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |
| ALTF__Assessment_Question__c | Assessment Questions | reference(18) | **yes** | | ALTF__Assessment_Question__c | |
| ALTF__CompositeKey__c | Composite Key | string(100) | no | | | |
| ALTF__NoteEntered__c | NoteEntered | boolean | no | | | |
| ALTF__Note__c | Note | textarea(2048) | no | | | |

### Answer values actually in use — verbatim query result

`SELECT ALTF__Answer__c, COUNT(Id) FROM ALTF__Assessment_Answer__c GROUP BY ALTF__Answer__c`

| ALTF__Answer__c | COUNT(Id) |
|---|---|
| null | 46 |
| Yes | 11416 |
| Unknown | 4834 |
| No | 2069 |

---

## ALTF__Assessment_Competitor_Answer__c (label: Altify Assessment Competitor Answer)

Row count: **8110**

Package child relationships: none.

Note the Name label as returned (truncated at 40 chars by the platform): "Assessment Criterion Competitor Answer N".

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Assessment Criterion Competitor Answer N | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| ALTF__Assessment_Answer__c | Assessment Answer | reference(18) | **yes** | | ALTF__Assessment_Answer__c | |
| ALTF__Opportunity_Competitor__c | Opportunity Competitor | reference(18) | **yes** | | ALTF__Opportunity_Competitor__c | |
| ALTF__Answer__c | Answer | picklist(255) | no | Unknown (default); Yes; No | | |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |

---

## ALTF__Opportunity__c (label: Altify Opportunity)

Row count: **2554**

Package child relationships: ALTF__Assessment_Answer__c via ALTF__Opportunity__c (ALTF__DM_TAS_Criterion_Answers__r); ALTF__Opportunity_Competitor__c via ALTF__Opportunity__c (ALTF__DM_Opportunity_Competitor_Extras__r); ALTF__Opportunity__History via ParentId (Histories); ALTF__Qualifier_Answer__c via ALTF__Opportunity__c (ALTF__DM_Qualifier_Answers__r); ALTF__Test_And_Improve__c via ALTF__Altify_Opportunity__c (ALTF__Deal_Reviews__r); **Opportunity via ALTF__Altify_Opportunity__c (ALTF__Opportunities__r)** — i.e. standard Opportunity carries a lookup back to this object.

ALL fields as returned, in API return order:

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText (verbatim) |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Altify Opportunity Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| ALTF__Opportunity__c | Opportunity | reference(18) | **yes** | | Opportunity | description: "Id of the associated opportunity." |
| ALTF__Assessment_Status__c | Assessment Status | picklist(255) | no | Red; Amber; Green | | description: "Red/amber/green value based on assessment completeness score." |
| ALTF__Decision_Criteria_Status__c | Decision Criteria Status | picklist(255) | no | Red; Amber; Green | | description: "Red/amber/green value based on decision criteria score." |
| ALTF__FSM1__c | PlanSignal Oppty | picklist(255) | no | Blank (default); Unknown; No; Yes | | description: "TeamView plan status opportunity signal: indicates if there is a valid opportunity based on assessment answers." / inlineHelpText: "Access to Funds and Compelling Event status" — **DISAGREE (see notes)** |
| ALTF__FSM2__c | PlanSignal Problems | picklist(255) | no | Blank (default); Unknown; No; Yes | | description: "TeamView plan status problems signal: indicates if business problems are validated and unique value confirmed, based on assessment answers and insight map status." / inlineHelpText: "Confirmed Insight Map and UBV status" — **DISAGREE (see notes)** |
| ALTF__FSM3__c | PlanSignal People | picklist(255) | no | Blank (default); Unknown; No; Yes | | description: "TeamView plan status people signal: indicates if you have support and alignment from the key people, based on assessment answers and relationship map status." / inlineHelpText: "Key Player and Decision Maker Support status" — **DISAGREE (see notes)** |
| ALTF__FSM5__c | PlanSignal T&amp;I | picklist(255) | no | Blank (default); Unknown; No; Yes | | description: "TeamView plan status T&amp;I signal: indicates whether you are reviewing deals using test &amp; improve sessions." / inlineHelpText: "Plan Test &amp; Improve status" |
| ALTF__Insights_Status__c | Insights Status | picklist(255) | no | Red; Amber; Green | | description: "Red/amber/green value based on insights score." |
| ALTF__Opportunity_Status__c | Opportunity Status | picklist(255) | no | Red; Amber; Green | | description: "Red/amber/green value based on overall opportunity completeness score." |
| ALTF__PRIME_Status__c | PRIME Status | picklist(255) | no | Red; Amber; Green | | description: "Red/amber/green value based on PRIME actions score." |
| ALTF__Recommended_Strategy__c | Recommended Strategy | picklist(255) | no | Frontal; Flanking; Fragment; Defend; Develop; Disengage | | description: "Competitive strategy recommended by Altify for this opportunity, based on answers to guideline questions." |
| ALTF__Relationships_Status__c | Relationships Status | picklist(255) | no | Red; Amber; Green | | description: "Red/amber/green value based on relationships score." |
| ALTF__Strategy_Status__c | Strategy Status | picklist(255) | no | Red; Amber; Green | | description: "Red/amber/green value based on strategy score." |
| ALTF__User_Defined_Strategy__c | User Defined Strategy | picklist(255) | no | Frontal; Flanking; Fragment; Defend; Develop; Disengage | | description: "Competitive strategy that is selected when the recommended strategy is not in use." |
| ALTF__Active_Test_and_Improve__c | Active Test And Improve | reference(18) | no | | ALTF__Test_And_Improve__c | description: "Most recently created Test &amp; Improve for this opportunity." |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | description: "An external ID used for Altify." |
| ALTF__Altify_Insight_Tags_Text__c | Altify Insight Tags Text | string(255) | no | | | |
| ALTF__Altify_Insight_Tags__c | Altify Insight Tags | multipicklist(4099) | no | Account Manager; Opportunity Manager; Sales Process Manager; Software and IT Services; Telecommunications; Altify; Manufacturing; Media; Utilities | | description: "Tags applied to the opportunity&#39;s insight map to make it more searchable." |
| ALTF__Amount__c | Amount | currency | no | | | description: "Opportunity amount (populated if a non-default amount field is configured in Altify Sales Process settings)." |
| ALTF__Assessment_Answer_Count__c | Assessment Answer Count | double | no | | | description: "Number of assessment questions that have a definitive Yes/No answer." |
| ALTF__Assessment_Answer_Last_Updated__c | Assessment Answer Last Updated | datetime | no | | | description: "Date on which assessment answers were last updated." |
| ALTF__Assessment_Competitor_Anwser_Count__c | Assessment Competitor Answer Count | double | no | | | description: "Number of competitor answers. Note that once an assessment question is answered, from your perspective or a competitor&#39;s, a placeholder answer is created for that question for each competitor." (Note: API name contains the typo "Anwser".) |
| ALTF__Assessment_Competitor_Count__c | Assessment Competitor Count | double | no | | | description: "Number of competitors defined for this opportunity." |
| ALTF__Assessment_Last_Chatted_By__c | Assessment Last Chatted By | reference(18) | no | | User | description: "User who last contributed to the assessment chatter (if Salesforce Chatter is enabled for Altify)." |
| ALTF__Assessment_Last_Chatted_Time__c | Assessment Last Chatted Time | datetime | no | | | description: "Date of most recent assessment chatter message (if Salesforce Chatter is enabled for Altify)." |
| ALTF__Assessment_Score__c | Assessment Score | percent | no | | | description: "Score from 0-100 for opportunity assessment answers, including competitor answers." |
| ALTF__Completeness_Calc_Time__c | Completeness Calc Time | datetime | no | | | description: "Date and time at which the Opportunity Completeness Batch Job last updated this opportunity&#39;s score and status fields." |
| ALTF__Decision_Criteria_Last_Updated__c | Decision Criteria Last Updated | datetime | no | | | description: "Date on which decision criteria were last updated." |
| ALTF__Decision_Criteria_Score__c | Decision Criteria Score | percent | no | | | description: "Score from 0-100 for decision criteria." |
| ALTF__Formal_Decision_Criteria_Contact_Count__c | Formal Decision Criteria Contact Count | double | no | | | description: "Number of contacts associated with formal decision criteria." |
| ALTF__Formal_Decision_Criteria_Count__c | Formal Decision Criteria Count | double | no | | | description: "Number of formal decision criteria identified." |
| ALTF__Informal_Decision_Criteria_Contact_Count__c | Informal Decision Criteria Contact Count | double | no | | | description: "Number of contacts associated with informal decision criteria." |
| ALTF__Informal_Decision_Criteria_Count__c | Informal Decision Criteria Count | double | no | | | description: "Number of informal decision criteria identified." |
| ALTF__Insight_Card_Count__c | Insight Map Card Count | double | no | | | description: "Number of insights on the insight map for this opportunity." |
| ALTF__Insight_Cards_Owned_And_Validated__c | Insight Cards Owned and Validated | double | no | | | description: "Number of confirmed insights with designated owners for this opportunity." |
| ALTF__Insight_Map_Last_Updated__c | Insight Map Last Updated | datetime | no | | | description: "Date on which the insight map was last updated." |
| ALTF__Insight_Published__c | Insight Published | boolean | no | | | |
| ALTF__Insight_Section_Count__c | Insight Map Section Count | double | no | | | description: "Number of insight map sections for this opportunity." |
| ALTF__Insights_Last_Chatted_By__c | Insights Last Chatted By | reference(18) | no | | User | |
| ALTF__Insights_Last_Chatted_Time__c | Insights Last Chatted Time | datetime | no | | | |
| ALTF__Insights_Score__c | Insights Score | percent | no | | | description: "Score from 0-100 for insight map." |
| ALTF__Is_Actions_Ever_Planned__c | Has PRIME Actions | boolean | no | | | description: "Indicates that PRIME actions were created for this opportunity." |
| ALTF__Is_Altify_Opp__c | Is Altify Opp | boolean | no | | | |
| ALTF__MAN1Comment__c | Mgmt KeyDeal Comment | textarea(32768) | no | | | description: "Notes associated with this opportunity&#39;s Mgmt KeyDeal flag in TeamView." |
| ALTF__MAN1LastUpdatedBy__c | Mgmt KeyDeal Last Updated By | reference(18) | no | | User | description: "User who last updated this opportunity&#39;s Mgmt KeyDeal flag in TeamView." |
| ALTF__MAN1LastUpdated__c | Mgmt KeyDeal Last Updated | datetime | no | | | description: "Date of last update to this opportunity&#39;s Mgmt KeyDeal flag in TeamView." |
| ALTF__MAN1__c | Mgmt KeyDeal | boolean | no | | | description: "Indicates that this opportunity has been flagged as a key deal in TeamView." |
| ALTF__MAN2Comment__c | Mgmt Attn Comment | textarea(32768) | no | | | description: "Notes associated with this opportunity&#39;s Mgmt Attn flag in TeamView." |
| ALTF__MAN2LastUpdatedBy__c | Mgmt Attn Last Updated By | reference(18) | no | | User | description: "User who last updated this opportunity&#39;s Mgmt Attn flag in TeamView." |
| ALTF__MAN2LastUpdated__c | Mgmt Attn Last Updated | datetime | no | | | description: "Date of last update to this opportunity&#39;s Mgmt Attn flag in TeamView." |
| ALTF__MAN2__c | Mgmt Attn | boolean | no | | | description: "Indicates that this opportunity has been flagged as needing attention in TeamView." |
| ALTF__MAN3Comment__c | Mgmt T&amp;I Comment | textarea(32768) | no | | | description: "Notes associated with this opportunity&#39;s Mgmt T&amp;I flag in TeamView." |
| ALTF__MAN3LastUpdatedBy__c | Mgmt T&amp;I Last Updated By | reference(18) | no | | User | description: "User who last updated this opportunity&#39;s Mgmt T&amp;I flag in TeamView." |
| ALTF__MAN3LastUpdated__c | Mgmt T&amp;I Last Updated | datetime | no | | | description: "Date of last update to this opportunity&#39;s Mgmt T&amp;I flag in TeamView." |
| ALTF__MAN3__c | Mgmt T&amp;I | boolean | no | | | description: "Indicates that this opportunity has been flagged for a T&amp;I in TeamView." |
| ALTF__Max_Due_Date_All_Tasks__c | Max Due Date All Tasks | date | no | | | description: "Latest due date associated with any of this opportunity&#39;s open PRIME actions." |
| ALTF__Min_Due_Date_All_Tasks__c | Min Due Date All Tasks | date | no | | | description: "Earliest due date associated with any of this opportunity&#39;s open PRIME actions" |
| ALTF__Opportunity_Completeness__c | Opportunity Completeness | percent | no | | | description: "Overall score from 0-100 for this opportunity plan based on scores for assessment, actions, decision criteria, relationships, insights and strategy." |
| ALTF__PRIME_Action_Closed_Count__c | PRIME Action Closed Count | double | no | | | description: "Number of closed PRIME actions for this opportunity." |
| ALTF__PRIME_Action_Open_Count__c | PRIME Action Open Count | double | no | | | description: "A count of all open PRIME actions for this opportunity" |
| ALTF__PRIME_Action_Overdue_Count__c | PRIME Action Overdue Count | double | no | | | description: "A count of all overdue PRIME actions for this opportunity" |
| ALTF__PRIME_Actions_Last_Updated__c | PRIME Actions Last Updated | datetime | no | | | description: "Date on which PRIME actions were last updated." |
| ALTF__PRIME_Last_Chatted_By__c | PRIME Last Chatted By | reference(18) | no | | User | description: "User who last contributed to the PRIME actions chatter (if Salesforce Chatter is enabled for Altify)." |
| ALTF__PRIME_Last_Chatted_Time__c | PRIME Last Chatted Time | datetime | no | | | description: "Date of the most recent PRIME actions chatter message (if Salesforce Chatter is enabled for Altify)." |
| ALTF__PRIME_Score__c | PRIME Score | percent | no | | | description: "Score from 0-100 for PRIME actions." |
| ALTF__Pause_Date__c | Qualification Pause Date | date | no | | | description: "Pause date for this opportunity&#39;s sales process." |
| ALTF__Probability__c | Qualification  Probability | percent | no | | | description: "Probability of closure for this opportunity based on the Altify Sales Process in use. For closed opportunities, this indicates the probability at the time of closure." (Label contains double space, verbatim.) |
| ALTF__Qualification_Last_Chatted_By__c | Qualification Last Chatted By | reference(18) | no | | User | description: "User who last contributed to the qualifier chatter (if Salesforce Chatter is enabled for Altify)." |
| ALTF__Qualification_Last_Chatted_Time__c | Qualification Last Chatted Time | datetime | no | | | description: "Date of the most recent qualifier chatter message (if Salesforce Chatter is enabled for Altify)." |
| ALTF__Qualification_Progress__c | Qualification Progress | string(100) | no | | | description: "Progression confidence level (from 0-3) for each sales process stage." |
| ALTF__Qualification_Sales_Process_Type_Stamp__c | Qualification Sales Process Type Stamp | reference(18) | no | | ALTF__Sales_Process__c | description: "Sales process type in use when qualification was calculated." |
| ALTF__Qualification_Sales_Process_Ver_Stamp__c | Qualification Sales Process Ver Stamp | double | no | | | description: "Sales process version in use when qualification was calculated." |
| ALTF__Qualification_Stage__c | Qualification Stage | reference(18) | no | | ALTF__Stage__c | description: "Qualification stage as calculated based on qualifier answers ." |
| ALTF__Rel_Map_Key_Roles_Uncovered_Count__c | Rel Map Key Roles Uncovered Count | double | no | | | description: "Number of relationship map contacts with key buying roles (i.e. decision maker or approver) identified for this opportunity." |
| ALTF__Rel_Map_Supportive_Key_Player_Count__c | Rel Map Supportive Key Player Count | double | no | | | description: "Number of relationship map contacts who are both a key player (i.e. tagged as inner circle or political structure) and a supporter or mentor" |
| ALTF__Relationship_Map_Contact_Count__c | Relationship Map Contact Count | double | no | | | description: "Number of contacts on this opportunity&#39;s relationship map." |
| ALTF__Relationship_Map_Key_Player_Count__c | Relationship Map Key Player Count | double | no | | | description: "Number of key players for this opportunity (contacts on the relationship map tagged as inner circle or political structure)." |
| ALTF__Relationship_Map_Last_Updated__c | Relationship Map Last Updated | datetime | no | | | description: "Date on which this opportunity&#39;s relationship map was last updated." |
| ALTF__Relationships_Last_Chatted_By__c | Relationships Last Chatted By | reference(18) | no | | User | description: "User that last chatted about relationships for this opportunity." |
| ALTF__Relationships_Last_Chatted_Time__c | Relationship Map Last Chatted Time | datetime | no | | | |
| ALTF__Relationships_Score__c | Relationships Score | percent | no | | | description: "Score from 0-100 for relationship map." |
| ALTF__Sales_Process_Name__c | Qualification Sales Process Name | string(80) | no | | | description: "Name of an Altify Sales Process in use for this opportunity." / inlineHelpText: "Qualification Sales Process Name" |
| ALTF__Sales_Process_Stage_Name__c | Qualification Sales Process Stage Name | string(80) | no | | | description: "For open opportunities, this is the name of the current Altify Sales Process Stage, if any. For closed opportunities, this is the Altify Stage at time of closure." / inlineHelpText: "Qualification Sales Process Stage N" |
| ALTF__Sales_Process_Stage__c | Qualification Sales Process Stage | reference(18) | no | | ALTF__Sales_Process_Stage__c | description: "Altify Sales Process Stage for this opportunity." |
| ALTF__Sales_Process__c | Qualification Sales Process | reference(18) | no | | ALTF__Sales_Process__c | description: "Altify Sales Process in use for this opportunity." |
| ALTF__Strategy_Last_Chatted_By__c | Strategy Last Chatted By | reference(18) | no | | User | |
| ALTF__Strategy_Last_Chatted_Time__c | Strategy Last Chatted Time | datetime | no | | | |
| ALTF__Strategy_Score__c | Strategy Score | percent | no | | | description: "Score from 0-100 for competitive strategy." |
| ALTF__Use_Recommended__c | Use Recommended | boolean | no | | | description: "Indicates that this opportunity is using Altify&#39;s recommended competitive strategy  (as opposed to a manually selected strategy)." |
| ALTF__Weeks_To_Close__c | Qualification Weeks To Close | double | no | | | description: "Number of weeks to close, based on the Altify calculated close date (when sales process is in use)." |
| ALTF__Worked_in_OM__c | Worked in OM | boolean | no | | | description: "Indicates that this opportunity was worked in Opportunity Manager, based on having a non-zero opportunity completeness score." |
| ALTF__Calculated_Close_Date__c | Qualification Calculated Close Date | date | no | | | description: "Projected close date for the opportunity based on qualifier answers and the pause date (if sales process is in use)." |
| ALTF__FSM4__c | PlanSignal Actions | string(1300) | no | | | description: "TeamView plan status actions signal: indicates whether you have actions in place that are either completed or open and not significantly overdue." / inlineHelpText: "Planned Actions status" — NOTE: unlike FSM1/2/3/5 this is a string (formula-backed), not a picklist. |
| ALTF__Mix__c | Mix | double | no | | | description: "Classification of opportunities based on deal size using thresholds set for large and small deals by the sales process (if sales process is in use)." |
| ALTF__Opportunity_Amount__c | Opportunity Amount | currency | no | | | description: "Opportunity amount based on the amount field configured in Altify Sales Process settings." |
| ALTF__Qualification_Dirty__c | Qualification_Dirty | double | no | | | description: "Formula to flag changes to the opportunity&#39;s sales process that may require a recalculation." |
| ALTF__Worked_In_Altify__c | Worked In Altify | boolean | no | | | description: "Indicates that this opportunity was worked in either Opportunity Manager or Sales Process Manager." |
| ALTF__Worked_In_Playbook__c | Worked In Playbook | boolean | no | | | description: "Indicates that this opportunity was worked in Sales Process Manager, based on having a non-zero qualification probability." |
| ALTF__UniqueKey__c | Unique Key | string(18) | no | | | description: "An external key to ensure data integrity." |

---

## ALTF__Opportunity_Manager_Settings__c (label: Altify Opportunity Manager Settings — custom setting, has SetupOwnerId)

Row count: **1**

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| SetupOwnerId | Location | reference(18) | no | | Organization, Profile, User | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| ALTF__Competitor_Class_List_Provider__c | Competitor Class List Provider | string(255) | no | | | inlineHelpText: "This field allows an administrator to specify a class which will be used to retrieve a list of competitors associated with an opportunity should the customer be using a source other than the standard competitor picklist." |
| ALTF__Completeness_Batch_Size__c | Completeness Batch Size | double | no | | | |
| ALTF__Custom_Tab_One_Icon_Class__c | Tab One Icon Class | string(50) | no | | | inlineHelpText: "This is the Salesforce lightning icon that will be shown for this Custom Tab" |
| ALTF__Custom_Tab_One_Label__c | Tab One Label | string(35) | no | | | inlineHelpText: "This is the Label which will appear in your Custom Tab" |
| ALTF__Custom_Tab_One_Src__c | Tab One Src | string(255) | no | | | inlineHelpText: "The Visualforce page which your Custom Tab will show" |
| ALTF__Custom_Tab_Three_Icon_Class__c | Tab Three Icon Class | string(50) | no | | | inlineHelpText: "This is the Salesforce lightning icon that will be shown for this Custom Tab" |
| ALTF__Custom_Tab_Three_Label__c | Tab Three Label | string(35) | no | | | inlineHelpText: "This is the Label which will appear in your Custom Tab" |
| ALTF__Custom_Tab_Three_Src__c | Tab Three Src | string(255) | no | | | inlineHelpText: "The Visualforce page which your Custom Tab will show" |
| ALTF__Custom_Tab_Two_Icon_Class__c | Tab Two Icon Class | string(50) | no | | | inlineHelpText: "This is the Salesforce lightning icon that will be shown for this Custom Tab" |
| ALTF__Custom_Tab_Two_Label__c | Tab Two Label | string(35) | no | | | inlineHelpText: "This is the Label which will appear in your Custom Tab" |
| ALTF__Custom_Tab_Two_Src__c | Tab Two Src | string(255) | no | | | inlineHelpText: "The Visualforce page which your Custom Tab will show" |
| ALTF__Disable_Add_Action_button__c | Disable Add Action button | boolean | no | | | inlineHelpText: "When this checkbox is selected, the Add Action button is not shown on Process qualifiers or Assessment questions." |
| ALTF__Disable_Add_Competitor_Button__c | Disable Add Competitor | boolean | no | | | inlineHelpText: "When this checkbox is selected, the Add Competitor option is not shown on the Assessment tab." |
| ALTF__Disable_Competitor_Creation__c | Disable Competitor Creation | boolean | no | | | inlineHelpText: "If checked, prevents users from creating a new competitor. When adding a competitor to an opportunity (in the Competitive Strategy page) users will only be able to select from a pre-existing set of competitors." |
| ALTF__Disable_ContactRole_Sync_Altify_SF__c | Disable Rel Map &gt;&gt; Contact Roles Sync | boolean | no | | | inlineHelpText: "If checked, the Contact Roles section of a Salesforce Opty is not automatically updated when a contact is added/deleted on the Rel Map. Note: only the contact name is synched. The role in Altify Rel Map is independent of the contact role in Salesforce" |
| ALTF__Disable_ContactRole_Sync_SF_Altify__c | Disable Contact Roles &gt;&gt; Rel Map Sync | boolean | no | | | inlineHelpText: "If checked, the Relationship Map is not automatically updated when a Contact Role is added or deleted on the Salesforce Opportunity record. Note: only the contact name is synched. The role in Altify Rel Map is independent of the contact role in Salesforce" |
| ALTF__Disable_Decision_Criteria__c | Disable Decision Criteria | boolean | no | | | inlineHelpText: "If checked, hides decision criteria functionality." |
| ALTF__Disable_Sync_Opportunity_Contacts__c | Disable Opp Contact Sync (Deprecated) | boolean | no | | | inlineHelpText: "Disables the synchronization of relationship map contacts with Opportunity contact roles when a Altify Opportunity is inserted or updated." |
| ALTF__Enable_Actions_Spinner__c | Enable Action Spinner (DEPRECATED) | boolean | no | | | inlineHelpText: "This setting is deprecated and is no longer used." |
| ALTF__Enable_Prime_Action_Emails__c | Enable Prime Action Email Notification | boolean | no | | | inlineHelpText: "Enables automated email notification of when PRIME actions are created or updated." |
| ALTF__Hide_PRIME_Type_Column__c | Hide PRIME Type Column | boolean | no | | | inlineHelpText: "Hides the PRIME Action field in Opportunity Manager and the Action Type column on the Actions tab." |
| ALTF__Hide_Test_Improve_Roles__c | Hide Roles within T&amp;I (DEPRECATED) | boolean | no | | | inlineHelpText: "Hides the Roles tab within Opportunity Manager T&amp;I&#39;s." |
| ALTF__List_All_Actions__c | List All Actions | boolean | no | | | inlineHelpText: "If this is checked, the OM Actions tab should list all actions associated with the opportunity - not just PRIME actions. A blank value will appear for actions which don&#39;t have a PRIME type." |
| ALTF__Opportunity_Plan_Type__c | Opportunity Plan Type | string(255) | no | | | inlineHelpText: "The API name of the Opportunity custom field that defines Opportunity Plan Types. You can use these types to control which tabs and assessment questions are available to the user." |
| ALTF__Opportunity_Update_Error_Url__c | Opportunity Update Error URL | string(100) | no | | | inlineHelpText: "The URL of a custom error page that helps the user to solve opportunity update validation problems." |
| ALTF__Tab_Name_List__c | Tab Name List | string(255) | no | | | inlineHelpText: "Enter the names of the Altify Tabs in the required order as a comma separated list. The tabs are as follows: Overview, Process, Assessment, RelMap, Insight, Actions, TestImprove, CustomTab1, CustomTab2, CustomTab3" |
| ALTF__Temp1__c | Temp1 | boolean | no | | | inlineHelpText: "Temporary field that may be used in a patch scenario." |
| ALTF__Temp2__c | Temp2 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp3__c | Temp3 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp4__c | Temp4 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp5__c | Temp5 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp6__c | Temp6 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp7__c | Temp7 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp8__c | Temp8 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp9__c | Temp9 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp10__c | Temp10 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp11__c | Temp11 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp12__c | Temp12 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp13__c | Temp13 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp14__c | Temp14 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp15__c | Temp15 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp16__c | Temp16 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp17__c | Temp17 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp18__c | Temp18 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp19__c | Temp19 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__Temp20__c | Temp20 | boolean | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario." |
| ALTF__TempStr1__c | TempStr1 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr2__c | TempStr2 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr3__c | TempStr3 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr4__c | TempStr4 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr5__c | TempStr5 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr6__c | TempStr6 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr7__c | TempStr7 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr8__c | TempStr8 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr9__c | TempStr9 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr10__c | TempStr10 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr11__c | TempStr11 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr12__c | TempStr12 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr13__c | TempStr13 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr14__c | TempStr14 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr15__c | TempStr15 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr16__c | TempStr16 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr17__c | TempStr17 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr18__c | TempStr18 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr19__c | TempStr19 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__TempStr20__c | TempStr20 | string(100) | no | | | inlineHelpText: "Temporary custom config setting that may be used in a patch scenario" |
| ALTF__Test_And_Improve_Presentr_Process_ImgUrl__c | Presenter Process Image Url (Deprecated) | url(255) | no | | | inlineHelpText: "This field is deprecated and is no longer used." |
| ALTF__Test_And_Improve_Process_Image_Url__c | Deal Review Process Image Url | url(255) | no | | | inlineHelpText: "This setting holds a url to an image which defines the T&amp;I process\n\nThis image is shown on the welcome page of the T&amp;I" |
| ALTF__Test_And_Improve_Reviewer_Process_ImgUrl__c | Reviewer Process Image Url (Deprecated) | url(255) | no | | | inlineHelpText: "This field is deprecated and is no longer used." |
| ALTF__Use_Simple_Completion_Calculations__c | Use Simple Completion Calculations | boolean | no | | | inlineHelpText: "Use Simple Completion Calculations" |
| ALTF__Pebble_Value__c | Small Deal Size | currency | no | | | inlineHelpText: "This is typically set to one quarter of the average deal size, this is the value of an opportunity which you consider to be very small when compared to your average deal size. This is used to determine which deals are considered to be of low value to prioritise coaching and resource allocation appropriately. If you are using Sales Process Manager, the per-process setting for Small Deal Size is accessed instead." |
| ALTF__Rock_Value__c | Large Deal Size | currency | no | | | inlineHelpText: "This is typically set to four times the average deal size, this is the value of an opportunity which you consider to be very large when compared to your average deal size. This is used to determine which deals are considered to be of high value to prioritise coaching and resource allocation appropriately. If you are using Sales Process Manager, the per-process setting for Large Deal Size is accessed instead." |

---

## ALTF__Quicklink__c (label: Altify Quicklink)

Row count: **5**

Package child relationships: ALTF__Account_Plan_Question_Quicklink__c via ALTF__Quicklink__c (ALTF__DM_Plan_Question_Quicklinks__r); ALTF__Log__c via ALTF__Quicklink__c (ALTF__Altify_Logs__r); ALTF__Qualifier_Quicklink__c via ALTF__Quicklink__c (ALTF__DM_Qualifier_Quicklinks__r); ALTF__Translation__c via ALTF__Quicklink__c (ALTF__Content_Translations__r).

| API name | Label | Type(length) | Required | Picklist values | referenceTo | Description / inlineHelpText |
|---|---|---|---|---|---|---|
| Id | Record ID | id(18) | no | | | |
| OwnerId | Owner ID | reference(18) | no | | Group, User | |
| IsDeleted | Deleted | boolean | no | | | |
| Name | Quicklink Name | string(80) | no | | | |
| CurrencyIsoCode | Currency ISO Code | picklist(3) | no | AUD; GBP; CAD; EUR; ILS; JPY; MYR; NZD; ZAR; CHF; TRY; USD (default) | | |
| CreatedDate | Created Date | datetime | no | | | |
| CreatedById | Created By ID | reference(18) | no | | User | |
| LastModifiedDate | Last Modified Date | datetime | no | | | |
| LastModifiedById | Last Modified By ID | reference(18) | no | | User | |
| SystemModstamp | System Modstamp | datetime | no | | | |
| LastViewedDate | Last Viewed Date | datetime | no | | | |
| LastReferencedDate | Last Referenced Date | datetime | no | | | |
| ALTF__RelatesTo__c | Relates To | picklist(255) | no | Contact | | |
| ALTF__Type__c | Type | picklist(255) | no | Video; Word; Excel; PPT; PDF; Image; ZIP; Web; Other; Download; Link | | |
| ALTF__AltifyId__c | AltifyId | string(100) | no | | | |
| ALTF__Assessment_Question__c | Assessment Criterion | reference(18) | no | | ALTF__Assessment_Question__c | |
| ALTF__Description__c | Description | textarea(1024) | no | | | |
| ALTF__Link__c | Link | url(255) | no | | | |

---

# Specific reads — verbatim results

## 3. Sales Process versions

`SELECT Id, Name, ALTF__Version__c FROM ALTF__Sales_Process__c LIMIT 10` — ALTF__Version__c exists; no fallback needed.

| Id | Name | ALTF__Version__c |
|---|---|---|
| a1BHn000007K2Q0MAK | New Business (Direct) | 196 |
| a1BHn000007K2Q5MAK | Renewal Business (=>$50,000) | 151 |
| a1BHn000007K2QyMAK | Renewal Business (< $50,000) | 19 |
| a1BHn000007K2S1MAK | Test Sales Process | 7 |
| a1BV40000096MGnMAM | New Business (Channel) | 52 |

(Row counts for queries 1, 2 and the sample junction row are recorded inline under their objects above.)

---

# Description vs inlineHelpText disagreements observed

Only ALTF__Opportunity__c fields carried both a description and inlineHelpText. The FSM plan-signal fields describe the signal differently in each place:

- **ALTF__FSM1__c** — description: "TeamView plan status opportunity signal: indicates if there is a valid opportunity based on assessment answers." vs inlineHelpText: "Access to Funds and Compelling Event status"
- **ALTF__FSM2__c** — description: "TeamView plan status problems signal: indicates if business problems are validated and unique value confirmed, based on assessment answers and insight map status." vs inlineHelpText: "Confirmed Insight Map and UBV status"
- **ALTF__FSM3__c** — description: "TeamView plan status people signal: indicates if you have support and alignment from the key people, based on assessment answers and relationship map status." vs inlineHelpText: "Key Player and Decision Maker Support status"
- ALTF__FSM4__c and ALTF__FSM5__c: the two texts differ in wording but describe the same thing (Planned Actions / Plan T&I status).
- ALTF__Sales_Process_Name__c / ALTF__Sales_Process_Stage_Name__c: inlineHelpText is a shortened/truncated repeat of the label ("Qualification Sales Process Stage N"), not a contradiction.

# API anomalies recorded

- inlineHelpText for ALTF__Sales_Process_Qualifier__c.ALTF__Question__c and .ALTF__Tip__c came back truncated mid-word ("...in the sales pr", "...in the co") — truncation is in the API response, recorded verbatim.
- ALTF__Assessment_Competitor_Anwser_Count__c: "Anwser" typo is in the shipped API name.
- No COUNT() query errored; all 15 objects returned counts.
