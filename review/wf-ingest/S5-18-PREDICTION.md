# S5-18, measured before the read · and the test as designed cannot separate its hypotheses

**Prediction under test (design's, explicitly not a ruling):** internal people should not produce
`AAO_Shadow_Person__c` rows.

## What is measured today

| | |
|---|---|
| internal participants in the org | 11 |
| shadow rows, total | **0** |
| shadow rows for an internal participant | 0 |
| answers whose subject is an internal participant | **0** |

**The shadow count is vacuous and must not be read as support.** Zero shadows for internal people
is not evidence when there are zero shadows for anybody. The one measured leg that does carry
weight is the last row: across the org's whole history, no answer has ever had an internal subject,
because the join's internal-subject gate refuses them (proven at the forty-eighth stamp on
Jennae's GOAL and INIT establishments).

## The structural reading, from the code rather than from the outcome

`AAO_Identity.resolve` — the only leg that creates a shadow — has exactly one caller,
`AAO_Project.cls:773`, reachable by two paths:

1. **The roster-placement leg** queries `WHERE Id IN :occasions.keySet() AND AAO_Contact__c != null`.
   Its input comes from coverage, which already excludes internal participants (thirty-eighth
   stamp, item c).
2. **The evidence-driven leg** needs an answer to project from, and an internal person has none.

So three independent mechanisms would each stop an internal person reaching the shadow leg.

## THE PROBLEM WITH THE TEST, and it is why this is filed before the run

**Dana and Marcus carry no `contactId`**, so the roster leg's `AAO_Contact__c != null` filter
excludes them **before internality is ever consulted**. If the WF run produces no shadow rows for
them, that outcome is equally consistent with:

- internal people are excluded (the hypothesis), and
- Contact-less people are excluded (a different rule that happens to catch them).

**S5-18 as designed cannot distinguish these.** A clean test needs an internal participant who
DOES carry a contactId — then the Contact filter passes and only internality can explain the
result. No such person exists on the WF deal; Jennae Jizdeortega on Project Farma is that shape
(internal, with a userId and an altify.com email) and would be the right specimen.

Reported rather than resolved: design said not to build to its guess, and choosing a different
specimen is design's call, not CODE's.
