# The three projection writers

CODE, 20 August. Matthew ruled the sequence: build the writers, then rehearse. Writers (a) and
(c) are built, tested and deployed. Writer (b) is held at the mechanism per the 152nd, awaiting
four judgments.

## (a) Assessment Answer projection

**Mechanism shape: our reading, upserted per question, with the words that made it in the note.**

Our answers become `ALTF__Assessment_Answer__c` rows on the deal's Altify wrapper. Proven live:

```
AAO_BANT_N1 = Yes | Marcus Reyes: "The Henderson deal was commit for two straight
                     quarters and then vanished in a week."
AAO_BANT_N2 = Yes | Marcus Reyes: "My best rep spends nine hours a week on admin."
```

**The reuse is the load-bearing part.** It calls `AAO_ProcessPanel.readingsFor`, extracted from
the panel for this purpose, so the Altify Assessment screen and our own Process panel read the
same establishment and print the same citation. Two surfaces disagreeing about one question is
the worst defect available here, because both of them look authoritative and neither says which
to believe.

Four refusals, each a measured constraint rather than caution:

**It never writes `Unknown`.** That is what an untouched row already says; writing it would turn
"we established nothing" into a machine assertion.

**It never creates the wrapper.** `ALTF__Assessment_Answer__c.ALTF__Opportunity__c` points at
`ALTF__Opportunity__c`, not the standard Opportunity. A deal with no wrapper gets a note and no
rows, because wrapper creation is its own decision and not a side effect of projecting.

**It never overwrites a human's note, and holds the answer beside it.** The Note Payload law
allows exactly two occupants: a machine citation and human prose. Anything that is not blank and
does not carry this writer's shape is treated as a human's, and the whole row is held, because
half-writing a row a human owns is worse than skipping it.

**It copies the vendor's conventions rather than guessing them**, read off the three rows
standing in this org since 6 August: `Name` is the record's own fifteen-character Id, `AltifyId`
is org plus record, `CompositeKey` stays null. A row named otherwise renders wrong in their UI,
which the criteria write already documents. `NoteEntered` is set true, because their UI hides a
note whose flag is false and a citation written invisibly is worse than one not written.

Seven tests. Idempotent on a second pass. Every created row enumerated in `AAO_Created_Row__c`,
so it can be disowned. Wired as its own receipt-bearing stage, last in the order, because it
reads what the deal ESTABLISHED and must run after everything that establishes.

## (c) Persona ghosts

**Mechanism shape: one row per expected-but-unfilled persona, keyed so it can be withdrawn.**

**It corrected a standing refusal that reasoned about the wrong object.**
`AAO_Personas` said ghosts can never stand on the map because
`ALTF__Contact_Map_Details__c.ALTF__Contact__c` is `nillable = false`. That is true and
measured. But **`ALTF__Relationship_Map_Persona__c` has no Contact field at all** - measured
here - which is precisely why a ghost fits on it and not on the other. The stale sentence stays
quoted in place in `AAO_Personas` with the 151st as its author, rather than deleted.

**The grain had no worked example and is named rather than buried.** `ALTF__Persona__c` is a
multipicklist and the org holds zero rows, so there was nothing to copy. One row per persona is
written, for two reasons design has since ratified: it is the grain
`AAO_Persona_Expectation__mdt` already states, and it is the only grain under which ghosts can
graduate INDEPENDENTLY - a contact matching Executive Sponsor must not clear a standing
Procurement Lead.

A graduated ghost is **withdrawn**, not left standing, because a ghost beside the person who
fills it is a lie the map tells forever. Only rows carrying our own key are ever withdrawn: the
key is the enumeration, and a row somebody else made is not ours to touch. Five tests, including
that one.

**Its live render is UNPROVEN and I cannot prove it.** Whether the vendor UI draws one ghost per
row or groups the multipicklist can only be seen on screen. Every demo deal sits at Stage 1 with
ordinal 1, and the two seeded personas are expected from stages 3 and 4, so nothing is overdue
and no ghost computes anywhere:

```
AAO DEMO REHEARSAL DEAL 2 | stage=Qualify | ordinal=null | ghosts=()
  note: Persona Executive Sponsor is expected from stage 3, and this deal's stage could not be
  ordered against the org's open stages, so nothing can be compared. No ghost.
```

**Manufacturing the proof would mean advancing a deal's stage, and `Opportunity` is exactly what
the never-write law forbids.** The stage advance is Matthew's click, the vendor-native act the
product never performs. The Executive Sponsor ghost appears when the deal reaches Stage 3, which
is already v0_3's choreography. That render is (c)'s proof and it is his to produce.

## (b) Qualifier Answer projection, held at the mechanism

Design corrected my report and the correction is accepted: I said the binding was fourteen
invented judgments. **The qualifiers already carry their plane in the seed's tip text**, which I
read and did not mine. Six are computed from the ledger, six of the eight evidence qualifiers
are near-verbatim restatements of contracts we already hold, and the real judgment is four rows.

On the one call design left open, bind versus mint, my view since costs were asked for rather
than a settled answer: **bind.** Minting twin contracts would put two near-identical
propositions through the reads on every pass, doubling token cost on the surface where the first
measured bill just came in at half the estimate, and producing two answers that can drift. Two
answers that can drift is the same failure the shared `readingsFor` helper was introduced to
prevent one layer up. Binding gives one establishment lighting both screens.

Nothing on (b) is built. It waits on the four judgments.

---

# The purge, fixed and completed (the 153rd's fix one, the 154th's gap)

## Fix one: a claim cannot outlive the answer it establishes

**Mechanism shape: the answers are identified first, the claims are scoped by stamp OR by
reference, and the trigger door widens with the scope.**

Order is the fix. The old sequence deleted claims scoped to the deal's own stamp, then deleted
answers. A claim stamped on deal 1 that references a deal-2 answer was in neither scope, so it
survived, and the platform then refused the answer's delete to protect the reference it points
at. Now the answer ids are gathered before any delete, and:

```apex
List<AAO_Claim__c> claims = [
    SELECT Id, AAO_Opportunity__c FROM AAO_Claim__c
    WHERE AAO_Opportunity__c = :opportunityId OR AAO_Answer__c IN :answerIds
];
```

**The door had to widen with it or the delete is refused at the trigger.** `allowsClaim` keys on
`OPPORTUNITIES.contains(c.AAO_Opportunity__c)`, and a claim admitted BY REFERENCE fails that
test by definition. It now also admits ids named into `REFERENCING_CLAIMS`, populated in the same
loop that finds them, cleared in the same `finally` as the rest of the switch. Each one is
recorded in `Outcome.kept` with its reason, because a purge deleting a row on a deal it was not
asked about should say so rather than do it quietly.

**Proven read-only against the blocked deal**, without purging it, since the purge is Matthew's
move and design verifies it from the org:

```
deal2 answers                              = 17
claims in OLD scope (stamp only)           = 19
claims in NEW scope (stamp OR reference)   = 32
the split-brain claims the old scope missed = 13   (stamped on deal 1, 006WD00000TrFg9YAF)
```

Thirteen, exactly the shape the 153rd measured, reached independently from the executable scope.

## The 154th's completeness gap, confirmed from the text and closed

**The confirm, plainly: no. The purge did NOT retract either new surface.** Design allowed that
a careful builder may have added it with the writers. I did not, and the gap was real: a
re-rehearsal would have left yesterday's assessment answers and yesterday's ghosts standing
beside today's run, on the two screens whose whole job is to be current.

Both are retracted now, and each ownership test is the one its surface can actually support:

**Assessment answers go by ENUMERATION, not by location.** "On this deal" is not ownership - a
human who answers a question on that screen owns their row however much it resembles ours. So
only rows recorded in `AAO_Created_Row__c` are withdrawn. And a row whose note a human has since
written is held whole, using `AAO_AnswerProjection.heldByHuman` - **the same predicate the writer
refuses to overwrite with**, made public for exactly this reason, so the write side and the
unwrite side cannot drift into disagreeing about whose row it is.

**Ghosts go by our key**, because the persona object carries no note for a human to occupy and
no Contact to identify one. The key is the whole ownership test, which is why the writer puts
one there.

## What is owed and named rather than quietly skipped

**A split-brain regression test.** The read-only proof above shows the widened scope reaches the
thirteen, and the existing suite covers the purge's happy path, but nothing yet reproduces a
claim and its answer on different deals and asserts the purge completes. The fixture is heavy (a
claim needs a candidate, a source, and a contract) and the rehearsal is blocked, so the unblock
shipped first. **The test is owed, not skipped**, and this line is the record of that choice.
