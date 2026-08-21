# The stage-sync probe, and one hazard to name before the config lands

CODE, 21 August. The 159th's item 1 and the 160th's sequence item (i): probe first, no code on a
hypothesis.

## What the config read establishes

The two vocabularies and the single shared name, from the org:

```
PROCESS "AAO New Business (Sandbox)"
   [1] Qualify   [2] Discover   [3] Validate   [4] Propose   [5] Commit
MAPPING "AAO Mapping" recordType="AAO BANT (Sandbox)" -> process "AAO New Business (Sandbox)"
```

`ALTF__Sales_Process_Stage__c.ALTF__Stage__c` is a lookup to a separate `ALTF__Stage__c` object
holding the vendor's stage vocabulary: `Commit, Discover, Propose, Qualify, Validate`. Our
`Opportunity.StageName` list is `Stage 1-4` plus inactive `Qualify`. **`Qualify` is the only
name both sides carry**, exactly as the 159th read it.

**A mechanism exists.** Three triggers are Active on Opportunity:

| trigger | namespace |
|---|---|
| `Opportunity_Trigger` | **ALTF** |
| `OpportunityTrigger` | (org-local, not ours) |
| `CeligoOpportunityUpdate` | celigo_sfnsio |

Managed source is unreadable, so the read can establish that Altify has a trigger on the object
and no more than that. Existence is not operation.

## What the replay establishes, and what it does not

On a throwaway fixture, never on deal 2 (held) or deal 1. First attempt was **not faithful** and
is recorded as such: the fixture carried `Type = null`, so the mapping that binds the process
never applied. Repeated with the Type set so the mapping is live:

```
AFTER type+stage write:                  type=AAO BANT (Sandbox)  stage=Stage 3
AFTER stage-only write with mapping live: stage=Stage 4
SEPARATE TRANSACTION:                     stage=Stage 4
```

**An API stage write HOLDS, with the mapping live, across transactions.** So `ALTF`'s Opportunity
trigger does not revert a stage on plain DML, and the hypothesis in its simplest form is
refuted: nothing reverts every stage write.

**What it does not establish.** Both observed reverts were LATE - 8:32 to 8:47 (fifteen minutes)
in the rehearsal, and 13:03 to 13:34 (thirty-one minutes) at the 140th - and both correlate with
a human in the vendor UI. A delayed check is armed on the same fixture to separate an async or
scheduled reverter from a UI-initiated one. **Until that returns, the honest statement is: the
synchronous path is clear, and the UI path is untested because I cannot drive it.** Matthew
opening the Sales Process Manager on a throwaway deal with a stage set would settle it in one
minute, and that is the only remaining instrument.

## The hazard, named before anyone runs the config

The ruled fix (option A) activates `Qualify, Discover, Validate, Propose, Commit` on
`Opportunity.StageName` and retires `Stage 1-4`. **If that is done by metadata deploy from this
tree, it is the exact shape that deactivated `AAO BANT (Sandbox)` at 4:59 AM.** I diagnosed that
one at the 146th: a manifest carrying a standard field's picklist definition deactivates every
value the manifest omits. This tree has **no** `objects/Opportunity/` directory at all and never
has, so a deploy would be authoring that field's definition from nothing.

Two further facts make it worse than a normal picklist edit. `StageName` is bound to Sales
Processes and record types, so the active set per record type is not a property of the picklist
alone. And the stage list is what `AAO_Flags.stageOrdinalOf` orders by, so a wrong active set
silently re-points every by-stage marker and every persona expectation at once.

**Recommendation, offered rather than taken:** run the stage change in Setup by hand, not as a
deploy from this tree, and re-point `AAO_Assessment_Stage__mdt` and the two persona expectations
afterwards from the measured ordinals rather than from the assumed ones. The marker re-point IS
mine and is safe; the picklist activation is the piece that has already bitten this org once.
