# The never-blank procedure, and the ranks moved into configuration · 13 August 2026

**Authorizing bytes, seventy-seventh stamp:** *"If the set is EMPTY: write nothing... If the set has
ONE value: WRITE IT. No hold, no note-instead-of-value, no exception. If the set has MORE THAN ONE:
WRITE THE HIGHEST-RANKED... if the established set contains only unranked values, write the FIRST BY
THE VENDOR PICKLIST ORDER. An unranked value never causes a blank."*

Suite **488 tests, 487 pass**; the lone failure is the standing org-resident non-AAO
`ConvertToOpportunityTest`. Eleven of the new assertions are the procedure's own.

## ACCEPTANCE, met on the board

> *"Adam Pfeiffer's Buyer Role reads `Approver` with Evaluator cited in his note, and no person on
> the deal carries a blank dimension where evidence exists."*

```
Adam Pfeiffer  | support=Supporter | political=Political Structure | ROLE=Approver | Brief contact
  NOTE: Support: Supporter - Adam Pfeiffer, 30 July 2026
        Political: Political Structure - Adam Pfeiffer, 30 July 2026
        Buyer Role: Approver - Adam Pfeiffer, 30 July 2026
        Also established, outranked by Approver: Evaluator - Adam Pfeiffer, 30 July 2026
Dan Lewis      | ROLE=Evaluator | Brief contact
Kayla Stanley  | Brief contact
```

**Both halves.** Adam had `AAO_BR_EVAL` and `AAO_BR_APP` both established; Approver ranks 3,
Evaluator 2, so Approver is written and Evaluator rides the note with its citation. Kayla's blanks
are correct and are the ruling's one unwritten path: she has **no** buyer-role or political answers
at all, so the set is empty and silence stays silence.

**Re-projection alone was enough** — no fresh pass needed. `projection: 0 created, 1 populated,
2 unchanged`.

## What was built

**`AAO_MapValues`** owns the procedure, every branch in one place, and returns null only for an
empty set. That negative property is what the class exists for, so it is walked branch by branch in
tests rather than asserted once.

**`AAO_Map_Value__mdt`** carries the ranks and the label map, ten seeded rows. Matthew's ruling: an
org may relabel a slot — production displays the stored `Signature Approver` as "Decision Maker and
Approver" — so an org whose words differ can state what its words mean rather than have our ranking
silently mean something else on its map. **The code reads and writes STORED VALUES only**; a test
greps the class body for every value string to prove no label is hardcoded in logic.

**The unranked tiebreak reads the vendor's own picklist by describe**, not from configuration. A
customer's picklist order is a fact about their org, and asking the schema is the only way to know it
that cannot drift. Measured here: `Approver, Decision Maker, Evaluator, User, Signature Approver,
Unknown`.

`AAO_P8Codes.buyerRoleCeiling` and `politicalCeiling` now delegate; the old three-rung ladder stays
in the file as the documented seed default with Matthew's reasoning attached (*"almost all evaluators
are also users"* — the ladder is about which role SUBSUMES the other).

## The hold branch is unreachable, and left standing anyway

`AAO_Project`'s collision branch can no longer be entered, because the only null comes from an empty
set and the caller never calls with nothing. It is kept rather than deleted: if the procedure ever
regains a way to answer nothing, that records it happened instead of writing a silent blank nobody
can trace.

## Two tests corrected in place, none deleted

- `aCollisionTOUCHINGanUnrankedRoleSTILLREFUSES` **was literally this acceptance case**, asserting
  the hold on Evaluator-plus-Approver. It is now
  `aPREVIOUSLYUNRANKEDROLEISNOWWRITTENANDNOTHINGISHELD`, and what the old test protected is not
  lost: nothing established is discarded, and the surface still says so — asserted on the outranked
  list rather than on a refusal line.
- A new sibling pins the one blank that survives: no evidence, no value, and not reported as a
  collision either.

## One thing I got wrong on the way, and it was my reading

I reported the note as missing its Buyer Role line and was about to call it a defect. **The note is
multi-line and my grep was showing only its first line.** Reading it properly showed all four lines
present and correct. Nothing was wrong with the note; the tooling between me and the row was.

## Rows, timings, governors, retryNotes

No model calls. **retryNotes: none.** Projection: 1 transaction, SOQL 18/100, DML 10/150. Two deploy
failures on the way, both mine and both mechanical: an empty custom-metadata string value is
invalid, and a record file missing `xmlns:xsd` fails with a bare `UNKNOWN_EXCEPTION` that names
nothing — found by diffing against a working record rather than by guessing.

## Named, not acted on

- The seventy-seventh stamp holds everything else behind it: the no-element contract guard, the
  serial-driver caveat, the machine-versus-human satellite, the second call, the Emerson stacked
  run. None are cancelled.
- **Support and sentiment are deliberately outside this**, keeping their counter arithmetic with a
  net zero reading Neutral. A test asserts they carry no rank, so nobody adds one later thinking it
  was an oversight.
