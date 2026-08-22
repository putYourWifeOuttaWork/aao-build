# The full-horizon cast, and the grain the vendor refused

CODE, 21 August. The 170th's ruling, its item 7 sweep, and one ratified design overturned by the
platform.

## The persona surface onto the ownership ledger, first

The 170th moved this AHEAD of the cast, and it was right to. This surface decided "ours" by the
SHAPE of `ALTF__AltifyId__c`. The cast takes it from one row per deal to a dozen values, and a
wrong ownership call at that volume is a different kind of accident. **Ownership is now the
watermark; the key is only a query filter.** A row wearing our key shape that we never recorded
making is held and NAMED, not withdrawn on a resemblance.

## The cast stands from call one

```
AAO DEMO REHEARSAL DEAL 2 | ordinal=2 | ghosts=(Executive Sponsor (due at 4),
                                                Procurement Lead (due at 5))
AAO DEMO STAGE B          | ordinal=1 | WRITE created 2
```

Both stand on a deal at ordinal 2 though neither is due until 4 and 5. **The by-stage plane
still governs flags and only flags.** A persona required at Commit is a relationship that must
START at Qualify, because influence cannot be manufactured on the due date - so the ordinal
gate came out of the ghost computation and the due ordinal rides the row instead, which is what
lets a map order the cast as a path rather than a pile.

## THE GRAIN WAS WRONG, AND THE PLATFORM IS WHAT SAID SO

The 152nd ratified **one row per persona**, reasoning that ghosts must graduate independently -
a contact matching Executive Sponsor must not clear a standing Procurement Lead. The reasoning
is right. The grain was not available, and nobody could have known from reading: this org held
exactly ONE persona row in its history, so the constraint had never been touched.

Measured by being refused:

```
FIRST ROW accepted
SECOND ROW, different persona, same map: REFUSED
ONE ROW carrying three personas: ACCEPTED
```

`Cannot insert duplicate Relationship Map Personas` is the vendor holding **one persona row per
map**, which is what its multipicklist was always for - and which also explains the 159th's
measurement that ghosts render PER VALUE from a single multi-value row. Both facts were in front
of us and pointed at this the whole time.

**Independence survives the change.** Adding a ghost adds a value; graduating one removes that
value and leaves the rest standing. It is a field edit rather than a row delete, and the 154th's
withdrawal rule reads identically. A test pins it: graduate Executive Sponsor and Procurement
Lead is still there.

**One consequence is worse and is design's to rule.** The vendor allows exactly one persona row
per map, so when that row belongs to somebody else we cannot put ours beside it. The writer
holds their row whole and NAMES the ghost it could not raise:

```
Ghost Procurement Lead is owed but the map's only persona row was written by somebody else,
and the vendor allows just one. Held whole rather than edited, and said out loud.
```

That is the honest behaviour and it is also a real gap: on any deal where a human has already
created the persona row, our cast cannot appear at all. Deal 2 is in exactly that state today.
**Editing a human's row to add our ghosts would break the one law that does not bend**, so the
choice is design's, not this writer's.

## What was checked and did not change

The account-scoping hypothesis was wrong and is recorded as such. The first probe suggested
uniqueness was per ACCOUNT, because a sibling deal on the same account appeared to block the
insert. Testing it properly showed the real rule is per MAP - the earlier probe had itself
created the blocking row one statement before. **A probe that changes the state it measures is
the instrument reading its own fingerprints**, and it cost one wrong conclusion before the
cleaner experiment replaced it.

---

# The value grain, the Placeholder, and where the second projection already is

## Ownership at the value grain, built to the 175th's item 3

Deal 2's single persona row is a human's. Under row-grain ownership our cast could never appear
there - and the 175th named the cost correctly: that is most real deals in most real orgs, the
flagship People feature silently absent exactly where sellers work.

Proven on that row:

```
BEFORE (theirs): "Executive Sponsor;Sales Leader"
RUN 1: created 1 | Sales Leader stands on this map and no ledger entry of ours claims it,
                   so it is left exactly where it is.
AFTER:           "Executive Sponsor;Procurement Lead;Sales Leader"
RUN 2:           created 0, unchanged 3     (idempotent)
ledger:          persona-ghost:Procurement Lead
```

**The ledger entry names the VALUE**, because the value is the unit the vendor left us to own.
Withdrawal is exact for the same reason: a test graduates our ghost and the human's `CEO`
survives on the same row. And `Executive Sponsor` was WANTED and already standing as theirs - so
it is counted unchanged rather than claimed, because a value a human put there is not ours
however much we also want it.

## The Placeholder, adopted rather than invented

`ALTF__Functional_Role__c` holds exactly one value. Rows we create now carry it, and the vendor
accepts it. **Whether it renders differently is UNVERIFIED and is Matthew's to see** - the probe
proves the write, never the screen, exactly as (c)'s render was owed at the 154th.

**One limitation the value grain creates, named because it undercuts the 175th's own mitigation:**
`Functional_Role` is a field on the ROW, and on a human's row we do not touch their fields. So on
any map where a human owns the row, our ghost values sit there **without** the Placeholder marking
them - the visual separation the 175th counted on as the cost mitigation is exactly the thing
value-grain ownership cannot deliver. Deal 2 is in that state now. Not a defect and not fixable
by writing harder; it is the shape of sharing a row.

## The second projection is already in the order

Checked from the executable text rather than assumed:

```
... S_JOIN, S_COMPUTE, S_PROJECT, S_PROMOTION, S_CARDS,
    S_ASSESSMENT, S_GHOSTS, S_QUALIFIERS, S_DONE
```

`AAO_QualifierCompute` reads `ALTF__Contact_Map_Details__c` and `ALTF__Insight_Card_Contact__c` -
**the projected records**, written by `S_PROJECT` and `S_CARDS` earlier in the same run. So
Process grades what actually LANDED rather than our in-memory intent, and its own results project
in a second phase, which is the 168th's item 1(iii) shape.

**One difference from the specification, stated rather than smoothed:** design described it as ONE
additional stage; it is three, because Process projects to three surfaces. The shape is the same
and the cost is three queueable hops rather than one. **Whether that satisfies "the second
projection stage" as written is design's to confirm - I am not declaring the acceptance bar met
on my own reading of it.**
