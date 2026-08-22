# The rubric chain, confirmed against every consumer

CODE, 22 August. The 182nd's item 3. Design said belief is not the standard; here is the reading.

## The chain, as ruled

1. read the POINTER — the OM Settings field naming which Opportunity field drives plan-type
   resolution, never `Type` hardcoded;
2. read the deal's value in that field;
3. match it to the plan-type row and parse its question-id list;
4. resolve each entry against the question records' `AltifyId` and use THOSE RECORDS.

## Consumer by consumer

**`AAO_ProcessContracts.discoverQuestions` — implements the chain whole.** It reads
`ALTF__Opportunity_Manager_Settings__c.ALTF__Opportunity_Plan_Type__c`, validates the named field
against the describe before it reaches a query (a settings row is org configuration, not user
input, and is still checked), reads the deal's value, matches the plan-type row, splits its
`ALTF__AssessmentQuestionIds__c`, and joins on `ALTF__AltifyId__c` to the live records, active
only. No step shortcut.

**Contract minting — correct, and by reuse rather than resemblance.** It calls
`discoverQuestions` and reads `ALTF__Long_Question__c` off the returned records, so a question an
admin reworded mints against the NEW text.

**`AAO_ColdStart` — SHORTCUT STEP 1, and the shortcut was mine.** It read `deal.Type` directly:

```apex
WHERE ALTF__Record_Type__c = :deal.Type
```

In an org whose pointer names a different field, this module would have read the wrong field and
planted the wrong plan, silently, on every cold start. **Fixed** — it now calls
`AAO_ProcessContracts.planTypeOf`, the same method, made public rather than copied: a second
implementation of the architecture's central chain is a second thing to drift, which is the shape
that has cost this project nine specimens.

**Writer (a) — shortcuts steps 1 to 3, and I am naming it rather than changing it.** It resolves
questions by the AltifyId codes of what we ESTABLISHED, not through the plan-type list:

```apex
SELECT Id, ALTF__AltifyId__c FROM ALTF__Assessment_Question__c
WHERE ALTF__AltifyId__c IN :readings.keySet()
```

Step 4 is honoured — it uses the live records. Steps 1 to 3 are satisfied UPSTREAM, because the
establishments themselves came from contracts `discoverQuestions` scoped. **The consequence is
narrow and real:** if an admin removes a question from the plan type mid-deal while we still hold
an older establishment for it, writer (a) would project an answer for a question the plan no
longer asks. Whether that is wrong is a judgment — the establishment is true, and the surface may
no longer want it — so it is design's, not mine to decide inside a confirm.

## No cache, no memo, no stored list

Searched the three classes: **nothing holds a question list between runs.** `discoverQuestions`
queries the settings row, the plan-type row and the question records on every call.

The single cache in the file is `requirementCache`, and it is not a rubric memo: it holds
speaker-requirement STRINGS keyed by code, within one transaction, and is rebuilt from
`speakerRequirements()` each time the class is loaded. It caches a per-question setting, not the
set of questions.

## What the confirm cost, stated plainly

One real defect, in my own module, found only because design refused to accept belief as the
standard. **The cold start would have worked forever in this org** — its pointer names `Type` —
and failed silently in the first customer org that pointed elsewhere. That is precisely the
class LAW #1 exists to prevent, and it was sitting inside the module built to honour it.
