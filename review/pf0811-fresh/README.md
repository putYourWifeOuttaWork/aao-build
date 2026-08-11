# The forty-fourth stamp's queue · Matthew's three map defects, fixed and evidenced

All four items shipped and a fresh full-pipeline run stands on a purged Project Farma. Full suite
437 tests, every AAO test green (the lone failure, `ConvertToOpportunityTest`, is not an AAO class,
is not in this repo's source, and fails on an org validation rule about `AE_Summary__c`).

**One scope note first, because it changes what item (b) could deliver.** Matthew asked for Project
Farma to be purged before this run. That purge removed `pf0811-live`'s rows (map 3, claims 13,
answers 8, pairs 90), which are the exact rows item (b)'s one-time backfill was written for. **The
backfill leg is therefore moot rather than skipped**, and the fresh run supersedes it: Dan's answers
now carry their link from the moment they exist. The BUILD half of (b) shipped in full and is
evidenced below.

---

## (a) Deterministic participant placement · presence no longer rides read variance

Authorizing bytes, item 1: *"every resolved external participant receives a map row with derived
Coverage, deterministically, before and independent of any model output; claims then enrich rows
that already exist."*

A person earned a map row only by having CLAIMS, and claims come from the model, so Kayla Stanley
fell off the map in two of three identical probe runs. The roster does not come from the model: it
is deterministic data on the Source, and roster-to-Contact resolution is code.

**The roster placement leg** now walks every participant coverage counts, and places each resolved
one with its derived Coverage. It runs AFTER the evidence-driven loop, deliberately: that loop can
CREATE a Contact through the identity ladder, and a person resolved during the run should be placed
in the same run rather than waiting for the next.

Three things it does not do, each on purpose:
- **Internal-true participants are never placed.** The exclusion lives in `AAO_Coverage` (37th stamp
  item 4), so the leg cannot reach them by construction, and a test asserts it rather than trusting
  it. Placing our own sellers on a customer's map by a new route would have undone that guard.
- **A participant with no Contact is not placed.** `ALTF__Contact_Map_Details__c.ALTF__Contact__c`
  is required and no Contact is ever faked; the create leg stays evidence-driven, which is where
  the ruling leaves it.
- **A roster row asserts attendance and nothing else.** Status, Political and Buyer Role stay null.
  Filling the row out to look complete is the defect, not the feature.

**HONESTLY REPORTED: this leg placed nobody on the fresh run** (`placedFromRoster=0`), because all
three resolved participants happened to have answers. An in-org run only exercises it when a
resolved participant has none, so the claim rests on tests instead:
`aParticipantOnTheCallIsPLACEDEvenWhenTheModelEstablishedNothing` (asserts the row appears with
Coverage and with every judgment dimension still null) and
`anInternalParticipantIsNeverPlacedByTheRosterEither`. Both pass. The one participant this would
have placed, John Van Schaick, has no Contact in the org, so he is correctly still absent.

---

## (b) The subject-contact link · PROVEN, 10 of 10

Authorizing bytes, item 3: *"stamp `AAO_Subject_Contact__c` whenever the participant's contact is
known, including contacts created by the run itself, and backfill the link at projection so the
evidence trail is walkable from the contact page in both directions."*

The defect exactly: the join stamps the link from the participant's Contact, and a person whose
Contact is CREATED BY THE RUN had none at join time, so the link stayed null forever and the trail
walked only one way. Dan Lewis is that person, and his contact page showed zero answers while his
answers existed and were Live.

The backfill now runs at the moment the identity ladder resolves a Contact, which is the earliest
moment the link is true. Measured after the fresh run:

| | before | after |
|---|---|---|
| answers on the deal | 10 | 10 |
| **carrying a subject-contact link** | Dan's were null | **10, zero unlinked** |
| Dan Lewis's participant | `AAO_Contact__c` null | `003WD00001QuqoFYAR`, written back by the ladder |

### A real law found by running it, and honored rather than worked around

The first cut of the backfill also stamped CLAIMS. The org refused it mid-projection:

> *"AAO_Claim__c is insert only apart from retirement, and this update moves
> aao_subject_contact__c. A claim is one establishment from one piece of evidence, and it is never
> edited. If the answer moved, write another claim; that is what makes the movement visible."*

That is the immutability law doing its job, and the backfill now touches answers only. It costs
nothing: **the contact page reads answers**, which is the surface Matthew found empty, and a claim's
link repairs itself for future runs because the ladder writes the resolved Contact back onto the
participant, so the next join stamps it from a participant that has one.

---

## (c) The sentiment hedge specimen · RECORDED, not tuned

Authorizing bytes, item 4(c): *"the sentiment specimen recorded in the calibration set with its pair
refs, no guidance edit (that is the fold's)."*

The calibration set is opened at [`review/calibration/README.md`](../calibration/README.md) with this
as specimen 1, carrying both pair refs and both verifier reasons verbatim from the wire
(recovered from the run logs, since the pairs themselves were purged):

- `r1q1` upheld supportive, correct: *"'I like that' and 'I like everything we've seen so far'
  clearly voice support."*
- `r1q22` **the misread**: *"reluctance or deferral ... indicating non-support or at least
  conditional/delayed support."*

The verifier's own words are the useful part: *"or at least conditional/delayed support"* is the
model reporting its uncertainty and then resolving it toward non-support anyway, on words that are
about WHEN a piece of scope happens rather than whether the speaker backs the deal.

**No guidance text was edited, no prompt changed, no example added, no threshold moved.** The file
states its own rule: it records cases, never guidance, so no single case gets fitted individually.

---

## (d) A counted net-zero support counter projects Neutral

Authorizing bytes, item 2: *"if +1/-1 nets to 0, that is NEUTRAL, not null ... Blank is reserved for
never-measured."*

`AAO_SupportCounter.rungFor(0)` now returns `Neutral`; `rungFor(null)` still returns null. The whole
distinction rides on null versus zero, which the caller already has: `supportCounter` stays null
until a sentiment answer sets it. `Neutral` is a real value on the vendor picklist (Mentor,
Supporter, **Neutral**, Non-Supporter, Enemy, Unknown), verified by describe before writing it.

**This reverses a standing law, and two tests encoded the old one.** Both are corrected in place
rather than deleted, each carrying the superseded text and the specimen that overturned it:
`theRungsSitAtTheirRuledPositionsAndZeroIsNotOne` became
`theRungsSitAtTheirRuledPositionsAndACountedZeroIsNeutral`, and `neutralIsDerivedAndNeverWritten`
became `aCountedZeroIsNeutralAndNeverMeasuredStaysBlank`. The half of the old law that survives is
asserted alongside: nothing established still stays blank.

**Not exercised on this run**, and said plainly: Adam netted +1 here, not 0, so no Neutral was
written. The behaviour rests on the two tests.

---

## The fresh map, `pf0811-fresh`

| person | Status | Political | Buyer Role | Coverage |
|---|---|---|---|---|
| Adam Pfeiffer | **Supporter** | Political Structure | | Brief contact |
| Dan Lewis | | | Evaluator | Brief contact |
| Kayla Stanley | | | Evaluator | Brief contact |

Adam reads **Supporter** this run where the previous run left him blank. Read that against the
flicker finding rather than as a fix: this is a different run of a shape whose verdicts still vary,
and the specimen in (c) is exactly why his Status was fragile.

### Timings, governors, retryNotes · label COLD

| stage | wall (ms) |
|---|---|
| call 0 · resolve | 7,931 |
| read A ∥ read B | 26,912 / 26,653 |
| resolution (deterministic) | 291 |
| resolution model leg | 17,300 (3 designator units) |
| verify plain shard 0 / shard 1 | 16,141 / 16,681 |
| verify sentiment | 8,649 |
| join | 3,182 (40 pairs) |
| projection | 3,180 (3 created) |

Governors clear: projection SOQL 14/100, DML 15/150, heap 14 KB of 6 MB; the heaviest stage remains
the join. **retryNotes:** call 0 resolved on its first attempt, no quote-law failure, no shard died,
zero claims left unverified. One stage error occurred and is reported rather than hidden: the first
projection attempt threw on the claim-immutability rule described in (b), the backfill was corrected
to answers only, and projection was re-run to completion. Projection is idempotent, so the re-run
wrote the same rows it would have written the first time.
