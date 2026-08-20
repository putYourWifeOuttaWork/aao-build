# The applicable set becomes a per-deal fact

**Tree** `/Users/thefinalmachine/Downloads/claude` (`main`) · **Org** `00DWD00000DV7iT2AT`, sandbox `aossb2` · authorized by the hundred-thirty-third stamp, queued first by the hundred-thirty-fifth's item 6.

> *"The chain is right; the entry point is wrong. The applicable set is a PER-DEAL fact and the code resolves it per ORG."*

## 1 · The chain, measured from the org rather than assumed

| link | measured |
|---|---|
| `ALTF__Opportunity_Manager_Settings__c.ALTF__Opportunity_Plan_Type__c` | one row, and it names the field **`Type`** |
| `Opportunity.Type` | the standard picklist, on the deal |
| `ALTF__Opportunity_Plan_Type_List__c.Name` | **eleven rows**, nine of them the org's own real ones |
| `ALTF__AssessmentQuestionIds__c` | comma-delimited codes, joined on `ALTF__AltifyId__c` |

**The pointer names a FIELD, so the field is read by name at runtime and never hardcoded.** A customer can point it at a custom field, and a build that assumed `Type` would be right in this org and wrong in the next one. The name is validated against the `Opportunity` describe before it reaches a query: it comes from a settings record rather than from a user, and a name concatenated into SOQL unchecked is an injection surface whatever its provenance.

**The package's own default semantics, mirrored: empty, null and unmapped all resolve to EVERY ACTIVE QUESTION.** Not to nothing. An org that has not configured a plan type is asking every question it authored, and returning an empty set there would be us inventing a restriction the package does not apply.

## 2 · The gap, proven both ways at the runtime

```
AAO DEMO REHEARSAL DEAL           Type=null                  applicable=21
AAO PROOF - denied and computed   Type=null                  applicable=21
Wells Fargo CIB                   Type=null                  applicable=21
(probe deal)                      Type=Renewal               applicable=0
(probe deal)                      Type=AAO BANT (Sandbox)    applicable=15
```

**Before this fix all five of those read 15**, because the walk was pinned to a constant naming our seeded plan type. Now the deal's own value selects, and the three outcomes the ruling names are each visible: unmapped resolves to everything active, a mapped plan type restricts, and our seeded one still returns its fifteen.

`Renewal` resolving to **zero** is itself worth recording rather than smoothing over: that plan type lists thirteen vendor codes (`RC_1`…`RC_13`) and this org holds no active question records for any of them. So a renewal deal here has no assessment questions, which is honest graceful absence and is exactly what the unmapped-and-empty semantics are for.

## 3 · A CORRECTION TO THE STAMP, measured

The hundred-thirty-third reads: *"The gap blocks nothing current: every demo deal sits on the seeded plan type."*

**No demo deal sits on the seeded plan type. Every AAO deal in this org carries `Type = null`.** They were reaching the fifteen only because the constant took them there. Under the fix they resolve to all twenty-one active questions instead, and that is what surfaced the collision below. The stamp's conclusion still holds - the demo is unaffected in the end - but it holds for a different reason than the one given, and the difference is what the guard exists for.

## 4 · THE COLLISION THIS FIX MADE REACHABLE, and the guard that holds it

This org holds **21 active assessment questions: our fifteen BANT, and the six `AAO_T*` of the 31 July experiment.** The hundred-twenty-ninth retired those six contracts in place as *"an experiment's output, kept as the record of the first discovered mint and never live in a pass."*

The mint's read-before-write asks for **LIVE** contracts, so a retired one is invisible to it. And item (iii) of the instruction says a question a new plan type introduces mints on first encounter. Put together: **the first run of the fixed path would have created six fresh contracts for the six retired questions and silently undone a deliberate retirement.** The correction-that-disables-what-it-corrects shape, arriving one ruling later.

`AAO_Criteria.mint` already refuses an upsert onto a retired row for the identical reason and in almost these words, so the rule existed - it was the contract mint that had never needed it. Now it does:

```
M PROCESS CONTRACTS
N AAO_T1: a RETIRED contract stands for this question and no live one does, so nothing is minted...
N AAO_T2 ... AAO_T6 (six in all)
C contracts before=99 after=99
```

**Ninety-nine before, ninety-nine after.** Six declined by name, fifteen reused.

**It SKIPS where the criteria path THROWS, and the difference is deliberate.** A criterion mint is one row in one run; throwing here would make an entire class of deals unrunnable for a reason that is ours rather than the org's. The question stays active in their rubric, we decline to carry it, and the note says so rather than either side happening silently.

**One tension for design, named rather than resolved:** a retired contract now means the org asks a question we refuse to carry. On these six that is exactly right - they are our own experiment's leftovers. On a question a CUSTOMER retires and then re-activates, the same guard would keep declining it, and re-activating is a human decision about a retired row rather than a mint. That is `AAO_Criteria.mint`'s own wording and it is the same call; it just has no consumer yet.

## 5 · Contracts stay plan-type-agnostic

Identity is still question record id plus content hash, exactly as minted before. **One question shared by two plan types is ONE contract, and the deal's applicable set decides which contracts ride that deal's reads: selection at dispatch, never a second mint.** Nothing about the key moved, so nothing already standing was touched.

## 6 · THE WRAPPER PROBE (hundred-thirty-third, item 4)

> *"whether the generation is not firing or firing lazily on first UI touch stays UNVERIFIED and goes to CODE as a one-probe question."*

Probed. All nine wrappers in the org:

| wrapper's deal | plan type | shells |
|---|---|---|
| Emerson/Aspen Tech Insights | **Proof of Concept** | **3** |
| AAO Demo - Live111 | New Customer | 0 |
| B&V Community Licenses-150 | Expansion | 0 |
| Emerson Electric Co. - Renewal | Renewal | 0 |
| the other five | null | 0 |

**Generation does not fire on an API-created wrapper, and plan type is not what decides it.** Three wrappers carry real, mapped plan types and hold zero shells. So the "not firing" half is measured on eight of nine.

And the one that does carry shells sharpens it further: **its deal's type is `Proof of Concept`, which is not in the Plan Type List at all.** Its three shells therefore did not come from the plan-type chain, which leaves first-UI-touch as the only standing explanation for them - still **UNVERIFIED**, because nothing in this session can touch the vendor's UI, and the capability law owns that boundary.

**What does not wait on the answer, and is now measured rather than argued: the chain walk has to be the primary read.** Shells are absent on eight of nine wrappers here and on every one this build created, so a design that read shells would read nothing on almost every deal in the org that authored them.

## 7 · Tests

**Full suite 607, 606 passing**, the one failure the standing org-resident `ConvertToOpportunityTest`.

`AAO_ProcessContractsTest` **5 of 5**, new: an unmapped plan type resolves to every active question; an inactive question is never applicable whatever a plan type lists; no deal resolves gracefully; **a retired contract is declined and never re-minted**, asserted by counting that the retired question still has exactly one contract afterwards; and minting twice writes once.
