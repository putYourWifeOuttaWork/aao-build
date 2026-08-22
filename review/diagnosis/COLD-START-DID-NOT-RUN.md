# Why the cold start did not run, and the drift that hid it

CODE, 21 August. The 177th's one question, answered from the executable text and the deploy
record. All three hypotheses resolved: **(i) confirmed and actual, (ii) refuted, (iii) refuted.**

## The cause

`AAO_PassQueueable`'s public entry point named its own starting stage:

```apex
public AAO_PassQueueable(Id sourceId, String runKey) {
    this(sourceId, runKey, S_RESOLVE, 0, true, false);
}
```

`S_COLD_START` was added to `ORDER` as the new head. **The ORDER knew and the DOOR did not.** The
run began at call 0, executed eleven lawful stages, and never planned the deal - which is why the
wrapper appeared 82 seconds later, empty, when a human opened the UI.

**Nothing errored, and nothing could have.** Every stage that ran was correct; the one that would
have made them meaningful was never reached. That is the recognition pattern on the stage plane,
and it is the fifth surface it has appeared on: a format and its predicate, a vocabulary and its
classifier, a note shape and its ownership test, a comment shape and `ours()`, and now **a stage
list and the door that opens it.**

## The other two, refuted rather than set aside

**(ii) Deploy timing.** Deploys succeeded at 22:25, 22:35 and 22:37; the run began at 23:19:17.
The wiring was live. This is refuted by the record, not merely made unnecessary by (i).

**(iii) A silent skip.** The dispatch calls `AAO_Receipt.record` unconditionally - a cold start
that plans nothing still prints its leg saying so. The receipt discipline held; there was simply
no stage to print one.

## The fix is at the mechanism, not the instance

```apex
public AAO_PassQueueable(Id sourceId, String runKey) {
    this(sourceId, runKey, ORDER[0], 0, true, false);
}
```

**The door now asks the order where it begins.** There is no second place to forget, so the drift
is unexpressible rather than caught - which is the same direction every repair in this project
has gone when the choice was available: the schema that made the unquoted yes impossible rather
than detected, the enumeration that made ownership a record rather than a resemblance.

## The test that would have caught it

Two, and they assert the INVARIANT rather than the symptom:

- the entry point begins at `ORDER[0]` - holding the door against the order, which nothing could
  do before because nothing exposed where a run starts;
- `ORDER[0]` is the cold start - stated separately because the reason is load-bearing: every
  stage after it presumes a rubric exists.

A test that only checked "a cold-start leg appears on a plan-less deal" would have passed the
moment someone reordered the list wrongly in the other direction. These cannot.

## What I did NOT do

**Deal 3's process is not assigned by hand.** The 177th is right that hiding the defect would be
worse than the defect, and a rehearsal that works because I reached into the org proves nothing.
It stays unplanned until a re-run plans it the way the product will.

## What the rehearsal proved anyway, which the finding should not swallow

Cold deal, one paste, no hands: sources, claims, 17 answers, 8 cards, and the full-horizon cast
standing with due ordinals and per-value enumeration - the 170th's ruling proven on a genuinely
cold deal. 26,492 in / 7,059 out, worst callout 36.2s of the 120s ceiling. **Everything that did
not require a plan worked**, and the two writers that did require one refused honestly rather
than failing: both answer objects are master-detail to a wrapper that did not exist, and
`produced 0` is the correct thing to print when the surface you write to is absent.
