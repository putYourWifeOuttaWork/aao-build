# The mini-rubric

Six propositions of our own, spanning all three routes. Deliberately **not** Altify's
production rubric.

A Developer sandbox copies metadata, not data, so the org's rubric tables are empty. That
is the feature: day one becomes a per-org discovery test against a rubric that is not
Altify's — the standing hazard, rehearsed.

Authored in `force-app/main/default/staticresources/AAO_Seed.json`.

| Code | Short | Route | Elements | Basis | Speaker requirement | Gating | In the set to exercise |
|---|---|---|---|---|---|---|---|
| `AAO_T1` | Budget Confirmed | E | 3 | Authored | Decision_Maker_Or_Influencer | yes | The main path, and the exit test runs on it |
| `AAO_T2` | Decision Team Identified | P | 1 | Authored | Any_Participant | yes | A predicate over map state, no model |
| `AAO_T3` | Competitive Position Understood | C | 2 | Authored | Buyer_Side | no | A charter reading transcript plus committed state |
| `AAO_T4` | Success Criteria Per Decision Maker | C | 2 | Authored | Decision_Maker_Or_Influencer | no | `Per_Person_Source` populated: the per-person count and the empty-set guard |
| `AAO_T5` | Implementation Timeline Agreed | E | 2 | **Inferred_Pending** | Any_Participant | no | The ratification path |
| `AAO_T6` | Reference Customer Discussed | E | 2 | Authored | Any_Participant | **no** | Non-gating, so day-one red is not the only behaviour tested |

## Why `AAO_T1` is the one the exit test runs on

Its guidance text names its own parts:

> Budget is confirmed when a decision maker states that **funds are approved**, that they
> are **allocated to this initiative specifically**, and that they are **available in the
> current fiscal year**.

So element resolution is a read rather than an inference, and `Elements_Basis` is
`Authored`. That is the path we want to be the main path.

## What this does not yet do, and it is the gap

The build brief asks for these propositions to be authored **into the org's own rubric
records**, so discovery walks its real path. `AAO_Seed` writes
`AAO_Evidence_Contract__c` rows directly, which **skips discovery entirely**.

Closing that needs the Altify rubric object API names, and those have to be read from
`altify--aossb2` rather than guessed. See `BUILD_JOURNAL.md`, session 1, Owed.
