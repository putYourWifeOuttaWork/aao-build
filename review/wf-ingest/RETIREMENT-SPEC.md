# The mention-Participant retirement · build spec, and two gaps that block it

**Not built.** Scoped from the code with the sites enumerated, and stopped at two holes that are
design's to close, because hitting either at site four would leave the resolution stage
half-applied — a state in which the WF read cannot run at all, which is strictly worse than not
starting.

## GAP 1 · there is no `Held` disposition, and the honest ones are taken

`AAO_Pair__c.AAO_Disposition__c` carries exactly: `Identified`, `None`, `Ambiguous`, `Merged`.

v3 §4's target sentence is *"the pair is **held** with its verbatim anchor"*, and none of the four
says that. `None` is wrong and specifically wrong: it means we looked and there is nobody, whereas
a held mention means **we found a person and cannot bind them yet**. Collapsing those two would
make the export unable to distinguish "no such person" from "person known, unbindable", which is
the distinction the whole retirement exists to create.

**The fix is one restricted picklist value on our own object**, `Held`, with its description
carrying the difference from `None`. Additive, no count moves on existing rows. It is listed as a
gap rather than just done because adding a disposition value changes what a run can say, and
DELTA-1 grades dispositions.

## GAP 2 · promotion is unwired, so a LINKED mention has nothing to bind to

This is the blocking one.

`AAO_Pair__c.AAO_Person__c` is `referenceTo AAO_Participant__c`. v3 §4 keeps it that way
deliberately — *"`AAO_Pair__c.AAO_Person__c` stays a Participant lookup, unchanged, and **IT BINDS
ON PROMOTION**"*.

Measured: **`AAO_Promoted_Contact__c` and `AAO_Promoted_At__c` have ZERO readers in non-test
code.** Promotion is a documented field pair and nothing anywhere consults it.

So after the retirement, a designator that **rung 1 successfully links to a real Contact** has:

- no Participant row to point at, because minting one is the thing being retired, and
- no promotion mechanism to bind it later, because promotion is not wired.

Today that case works — `mentionFor` mints a Participant carrying the linked Contact and the pair
reads `Identified`. **The retirement as specified would take a currently-working path and leave it
held forever**, with no route out. That is a regression for every genuinely-linkable mentioned
person, and it is not what v3 intends; v3 assumes a promotion path that its own measurements did
not check for.

**This needs a ruling before the build, and there are three shapes:**

1. **Wire promotion pair-side.** On promotion, the shadow's `AAO_Promoted_Contact__c` resolves to
   a Participant on the relevant Source and held pairs bind. Most faithful to v3; the largest
   build; needs its own spec.
2. **Rung 1 keeps minting a Participant, only ladder-zero and AMBIGUOUS hold.** Smallest change,
   preserves today's working path, and retires the fabrication only where it was actually
   fabricating — but it does not fully retire the `mention:` prefix, so the three filters stay.
3. **Let the pair carry a shadow subject.** v3 §4 explicitly retires this ("the pair does NOT need
   to express a shadow subject") and costed it; reopening it means reopening that.

**CODE's recommendation: (2) for the read, (1) after it.** It is the only one of the three that
leaves the corpus runnable this weekend without changing what a linked mention counts as, and it
confines the movement to exactly the pairs DELTA-1 predicts must move.

## The sites, enumerated, for whichever shape is ruled

**`AAO_Resolve`** — six: the leg-3 mint declarations (`mentionsToInsert`, `mentionByKey`, ~162);
the `mentionFor` call on a LINKED ladder outcome (~217); the insert and the pending-row
back-assignment of `AAO_Person__c` (~246-251); the `mention:` skip in `rosterByKey`'s candidate
build (~336); the model leg's own mint (~422, 455, 482); and `mentionKey`'s prefix builder (~639),
plus `rosterMatch`'s `startsWith('mention:')` skip (~615).

**The three filters**, dead only under shape (1) or (3): `AAO_Coverage` ×2 (`AND (NOT
AAO_Roster_Key__c LIKE 'mention:%')`, two separate queries in one file) and `AAO_Identity` ~239
(create-leg classification).

## DELTA-1, restated as the set it is

- **MUST move Identified → Held:** Priya's mentions in s3 and s4; Bettina's in s4 and s5.
- **MUST NOT move:** any pair whose subject is a rostered participant. A moved pair about
  Katherine, Rohan, Tom, Meredith, Alison or Jared is a **finding**, not a delta.
- Under shape (2) this holds exactly. Under shape (1) it holds only once promotion binds;
  until then every rung-1 link also moves, which would read as a DELTA-1 violation and is not one.

## The pattern, named because it is now four

A ruling's proxy reader turning out unwired: the coverage-Internal flag, the model-separation
guard, the resolution stage itself, and now promotion. Each was documented, each read as live, and
none was called. **A field with no readers is a plan, not a mechanism**, and the cheap check is
`grep` for readers before a ruling rests on one.
