# Wells Fargo session 4 · stacked on s3 · and the stack found what it exists to find

**One run, no purge, no tuning, no second attempt.**

| | |
|---|---|
| **Tree** | `/Users/thefinalmachine/Downloads/claude`, `main`, project `aao-build` |
| **Org** | `00DWD00000DV7iT2AT` — sandbox `aossb2` |
| **Source** | `SRC-00000039` (`a1XWD0000083uvV2AQ`), occurred **2026-08-19T14:00:00Z** |
| **Run key** | `wf-s4`, stacked on `wf-s3` |
| **Writer** | bulkified join, commit `bd4987a` |

## FIRST · the DML re-measurement, confirmed against the org

**Predicted `C + 9`. Measured 35 of 150, against s3's 133.**

| | s3 | s4 |
|---|---|---|
| join DML | **133 / 150** | **35 / 150** |
| join SOQL | 83 / 100 | 69 / 100 |
| candidates | 31 | 25 upheld |
| join wall | 4,186 ms | **2,148 ms** |

25 + 9 = 34 against a measured 35, the one extra being a bulk statement that fired on s4 and not
on s3. **The ceiling moves from 35 candidates to roughly 140.** Confirmed by measurement, not by
arithmetic, exactly as the 133 was.

## THE THREE ANSWERS · two are negative and one of those is the finding of the read

### A · Did Rohan's and Alison's counters increment off s3? **NO. THEY DID NOT.**

Neither moved. Rohan 1, Alison 1, Katherine 1 — all identical to s3. **And the reason is
structural, not evidential.**

```
sentiment claims, in occurred order
  SRC-00000045  2026-08-05  Alison Reyes         Established
  SRC-00000045  2026-08-05  Katherine Villanueva Established
  SRC-00000045  2026-08-05  Rohan Deshpande      Established
  SRC-00000045  2026-08-05  Tom Brzezinski       Established
  SRC-00000039  2026-08-19  Tom Brzezinski       Established
```

Only Tom got a second sentiment establishment. **And it did not accumulate onto his standing
value — it created a second answer row.**

```
key = A1|Participant|a1ZWD000002bZnI2AU|<contract>   counter = -1     (s3)
key = A1|Participant|a1ZWD000002bZs82AE|<contract>   counter = -1     (s4)
```

**The answer key is scoped to `AAO_Participant__c`, and a Participant is one row per Source per
person.** Measured, three rows for Tom, one per call, all pointing at the same Contact:

```
a1ZWD000002bZs82AE  Tom Brzezinski  SRC-00000045  contact 003WD00001QZAwJYAX
a1ZWD000002bZnI2AU  Tom Brzezinski  SRC-00000039  contact 003WD00001QZAwJYAX
a1ZWD000002bZnP2AU  Tom Brzezinski  SRC-00000040  contact 003WD00001QZAwJYAX
```

**So a person on two calls has two answer keys, and cross-call accumulation cannot happen for any
dimension keyed this way.** Tom is at −1 twice rather than −2 once.

**This is a ruled design, not a slip, and `AAO_AnswerKey`'s own header says why:** the key moved to
Participant at addendum 18 because *"an answer keyed on a Contact cannot be reconstructed from
claims keyed on a person who has no Contact"* — the replay invariant. The consequence on a stacked
read was never priced.

**What it costs, stated plainly:** the ninety-fifth stamp left open whether the counter's
arithmetic earns its place, to be settled by whether accumulation across three calls produces
bands the ontology would not name alone. **On this evidence the counter cannot accumulate across
calls at all**, so that experiment cannot run as designed. The thesis People closed on — that maps
firm up over calls — is carried today by **Coverage**, which derives from distinct occasion counts
and did move (five people now `Multiple contacts`), and not by the counters.

**Not fixed. Not tuned. This is design's to rule**, and it lands directly on the open question.

### B · Did Priya's flag stay open, and was her shadow reused? **FLAG YES. SHADOW NO.**

The s3 flag is **still Standing**, never reopened, never cleared — correct.

**But s4 minted a second shadow and a second flag for the same human:**

```
SP-00000000  "Priya Natarajan"  anchors 2  created 19:16:32   ← s3
SP-00000002  "Priya"            anchors 2  created 20:06:03   ← s4, NEW
SP-00000001  "Bettina Marchetti" anchors 2 created 20:06:03   ← s4, genuinely new person

flags, all Standing:
  ident|006WD00000TWvH0YAL|priya natarajan     raised 2026-08-05
  ident|006WD00000TWvH0YAL|priya               raised 2026-08-19   ← the duplicate
  ident|006WD00000TWvH0YAL|bettina marchetti   raised 2026-08-19
```

**s3 said "Priya Natarajan"; s4 said "Priya".** Different normalised designators, therefore
different shadow keys and different bound keys, therefore a second row and a second flag for one
person.

**This is the eighty-seventh stamp's key-collapse reading behaving exactly as ruled**: identical
designators of the same form collapse; *different forms never collapse at the key, and linking
them is a ladder outcome on context.* The ruling was made knowing the cost. **This run is the
cost arriving on real data:** the seller sees two open flags for one person, and DELTA-1 grades
exactly this surface.

The bound key did work correctly *within* a form — three s3 pairs about "Priya Natarajan"
produced one flag, and s4's two "Priya" pairs produced one more, not two.

### C · Did any claim carry `Basis = State` or `Both`? **NO. Still zero.**

```
claims on the deal: {Transcript = 56}
AAO_Claim_Basis__c rows org-wide: 0
```

56 claims, all `Transcript`. The junction remains unwritten, exactly as the schema reference
predicted: the §P8 pipeline references it zero times, and no route class that writes `State`
claims is on this path. **The latent gap stays latent.**

## The ledger

```
s4 located 74, identified 74 — one for one, for one, HELD
   dispositions: Identified 48, Merged 20, Held 6
   verified 48: upheld 25, refused 23
deal totals after the stack: claims 56, answers 47, criteria 8
```

**`Held` at 6 against s3's 2**, and `Merged` at 20 against 24. Both refusal branches exercised
again on real data.

## Stage timings

| Stage | Wall ms | Note |
|---|---|---|
| call 0 | 8,128 | DUAL, routed to d1 |
| read 1 | 43,582 | |
| read 2 | 63,738 | |
| call 2a deterministic | **548** | 74 pairs, zero callouts |
| call 2b model leg | 7,788 | 2 designators returned |
| **call 3 verify** | **72,505** | 4 batches, model wall **72,230 ms** |
| join | **2,148** | **DML 35/150** |
| projection | 1,662 | 0 created, 3 populated, 14 unchanged |
| cards | 31,497 | 6 created, 1 reinforced, 10 unchanged |

**WORST SINGLE CALLOUT: 72,230 ms (call 3) against the 120,000 ms ceiling — 60%.** Up from s3's
46% and still clear. Roughly 232 s end to end, driven serially.

## The map after the stack

| Person | Buyer role | Political | Status | Coverage |
|---|---|---|---|---|
| Katherine Villanueva | Evaluator | Inner Circle | Supporter | Multiple contacts |
| Rohan Deshpande | Evaluator | Political Structure | Supporter | Multiple contacts |
| Tom Brzezinski | Evaluator | Political Structure | Non-Supporter | Multiple contacts |
| Alison Reyes | — | **Political Structure** *(new)* | Supporter | Multiple contacts |
| Meredith Cho | **Approver** *(new)* | — | — | Multiple contacts |
| Jared Kim | — | **Political Structure** *(new)* | — | Brief contact |

**Projection: 0 created, 3 populated, 0 blocked, 14 unchanged.** Three dimensions filled that were
blank after s3, nothing overwritten. **People and Problems did carry forward**, and the card
writer reinforced one card rather than duplicating it.

## The bulkification, and the byte-identical bar

**Suite 516, 515 AAO passing**, the only failure the standing non-AAO `ConvertToOpportunityTest`.

**The bar caught a real divergence and that is the bar working.** My first batch boundary put the
criteria flush after `mintCriteria`, but the typing pass *inside* `mintCriteria` updates the rows
the naming loop minted and needs their Ids. `AAO_CriteriaTest` failed `MISSING_ARGUMENT`. Boundary
moved; suite restored.

**Byte-identical on the evidence available, and no version string moves.** The replay diffs across
the frozen corpus sit in `AAO_Spans__c` and `AAO_Element_Completeness__c`, and **the diff contains
zero references to either field** — they are a pre-existing replay-versus-live serialization
property, not a commit property. Failure semantics are identical rather than merely similar: the
join is one transaction, so a throw rolls everything back either way, and both the old per-row
upsert and the new bulk one use `allOrNone = true`.

**The honest limit:** the fully decisive test — one live join producing byte-identical rows — is
not runnable, because claims are insert-only and the join cannot be re-run on the same pairs. s4
is the first live exercise of the new writer, and its ledger reconciles.

## retryNotes

None. Call 0 did not flake, call 3 completed in one invocation, no stage was re-run.

**Nothing graded by CODE. No number tuned toward any expectation. s3 untouched.**
