# The 179th's item 2: where the cast comes from, and a guard that names its failure

CODE, 22 August.

## (ii) The question, answered from the executable text — and it is the first of design's two

**The cast does not come from the plan type. It comes from org-level configuration.**

```apex
FROM AAO_Persona_Expectation__mdt
WHERE AAO_Persona__c != null
```

The whole type carries four fields - `AAO_Persona__c`, `AAO_Expected_From_Stage__c`,
`AAO_Title_Patterns__c`, `AAO_Note__c` - and **none of them is a plan type.** The query is
org-wide by construction: every expectation this org states, on every deal, regardless of what
plan the deal carries or whether it carries one at all.

So the ghost writer wrote two personas on an unplanned deal because **its cast never depended on
a plan.** It checks the Relationship Map module and nothing else, and that is not an oversight
in it - there was never a plan-shaped question for it to ask.

**A phrase worth correcting while it is cheap:** the 172nd's queue and the 175th both describe
building personas on "the seeded per-plan-type cast." **That cast does not exist.** The
expectations are not seeded per plan type and cannot be, because the metadata type has no field
to scope them by. Design has been reasoning from a configuration shape the org does not have,
and every stamp since has carried the phrase forward unchallenged - including by me.

**So the two cannot refuse in the same voice today, and it is not a bug in either.** They answer
different questions: the cold start asks *"does this deal's Type map to a plan?"*, and the ghost
writer asks *"what does this org expect of anybody?"* Making them agree is a real change and it
is design's to choose:

- **scope expectations by plan type** - a new field, and the cast becomes what the documents have
  been describing all along; or
- **have the ghost writer refuse when the deal is unplanned** - no schema change, and the cast
  becomes plan-dependent by policy rather than by data.

They differ in more than effort. The first says a persona cast belongs to a methodology; the
second says it belongs to a planned deal. **I have changed neither**, because the 179th asked me
to read which it is before changing either, and the read says the premise underneath the question
needs settling first.

## (i) The instruction: the ceiling guard now says which failure it caught

*"Raise `AAO_Max_Output_Tokens__c` on the config record"* is right for a genuinely large output
and wrong for a degenerate repetition, where a raised cap buys a longer ramble at higher cost -
**the reader pays for the failure twice, once in tokens and once in the wrong fix.**

The tail is the tell, and the response body is available to look at because the keep-failed-
response rider stored it. A bounded heuristic reads the last stretch and asks whether it is one
short pattern repeated; if it is, the message becomes:

> The response hit max_tokens by REPEATING ITSELF to the ceiling, not by producing too much
> answer. Raising the cap would buy a longer loop at higher cost; this is a model failure to
> retry differently, not a configuration too small.

**It decides nothing.** The run fails either way, so a false negative costs a less precise
sentence and a false positive costs a misleading one - neither costs a row. Pinned in both
directions: a repeated tail is a loop, and ordinary long prose is not, because a guard that
cries loop at real prose sends the reader to the wrong fix in the other direction.

## (iii) The recording, confirmed from my side

The varied retry worked live - degenerate first attempt, clean second - which is the first
evidence that escalating effort changes the outcome rather than merely changing the question. It
remains a variation rather than a cure, and one live pair is not a rate.
