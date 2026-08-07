# `bv/biweekly-2026-06-24-nf1` · gate 3, fixture 1 · the resolver's run

Artifact `2bed419d1079cdde1cbe0881e03ba40466f6466156596a980b80a842b76f25f9`, frozen, NF1.
Black & Veatch, 24 June, 2,435 s, 4 speakers, Stage 1.

## The run, and why it has no rows

**Call 0 returned DUAL. The deal resolved to NONE. Nothing dispatched.**

| | |
|---|---|
| call 0 wall | 16,081 ms (13% of the ceiling) |
| SOQL / DML | 6/100, 0/150 |
| opportunity side | **yes**, byte-located at 20759 |
| account side | **yes**, byte-located at 36834 |
| deal | **NONE** |
| dispatched grains | **none** |
| establishments | **0, and the zero is the output** |

**There is no pairs/claims/answers export because nothing was extracted.** That is the ruling
working rather than a run that failed: a side-yes with deal-NONE does not dispatch, so no family
read ran, no pair located, and nothing wrote. Shipping empty CSVs would suggest a pipeline that
ran and found nothing, which is a different fact.

## The two byte-located quotes

**Opportunity content**, offset 20759:

> in order to have the technical conversation, the business conversation, outline the use cases
> so that we can actually, you know, do pricing and do a timeline.

*Reader's reason: scoping, level-of-effort estimate, pricing and timeline for the MCP project,
plus technical/security review as a gate.*

**Account content**, offset 36834:

> But yeah, I think there's a definite need of adoption, ongoing adoption and utilization. And
> we've talked about it several times of like, accounts are being used, but you know,
> opportunity plans are not.

*Reader's reason: sustained discussion of adoption and utilization of the Altify product they
already own, upgrade/testing, training and enablement.*

## What this fixture tested and what it did not

**Tested, and passed: the resolver's generalization.** Gate assertion 2 is re-adjudicated to
DUAL, and this is the split's second earned save on its second live fixture. The prior ACCOUNT
pass under the retired two-sided question was the majority eating the minority, mirroring the
Emerson failure in the opposite direction.

**Not tested: extraction.** No family read ran, so this fixture says nothing about recall or
precision on unseen speech. **The 29 July fixture is the extraction test**, and gate 3's real
numbers come from it.
