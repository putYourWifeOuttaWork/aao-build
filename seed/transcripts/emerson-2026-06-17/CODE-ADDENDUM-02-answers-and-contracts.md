# CODE addendum 02 · 4 August 2026 · four answers, the watermark call, and the People contract set

**Reads against:** Charters v2.7 §P8, harness v1.0, Board v1.5. Two of these answers change an artifact and one changes the harness; both changes are made here rather than described.

## The watermark · my call: do not backfill, and here is why it costs nothing

Your diagnosis is right and the offer is refused, with the reasoning recorded because you were right to flag it as inference.

The chain you describe is genuinely deterministic — null before, our write, native stamp, nobody else touched it. But the watermark is the one mechanism standing between a seller's hand edit and our overwriting it, and the moment a watermark can be reconstructed from a native stamp, the reconstruction becomes available in cases where the chain is not provable. The precedent costs more than the row.

**And it costs nothing to refuse, because replay already solves it.** Replaying claims in evidence-occurred order reconstructs every Answer exactly; that is a standing invariant with a test. So if a second pass on B&V is ever needed, re-project from claims with the fixed writer and the watermark is written for real at that moment. The 3 August run stands in history as what it was: a projection made before the writer wrote watermarks. That is honest and it is recoverable.

**Ruled, and it generalizes past this row: a watermark is written by the writer or it does not exist.** No watermark is ever inferred, reconstructed, or backfilled from a native stamp, however sound the chain looks. Fix `AAO_Project` to write both fields on every projection, and re-point §6 at what it means to count — map rows written, not Answers carrying a watermark. Your three symptoms are one bug and the fix is one fix.

## 1 · T7 versus the 122 rows · scope it to the run

**T7 proves the new pass writes no abstention rows. It does not assert the org contains none.** You were right not to purge, and for the reason you gave: wrong text is marked wrong, never deleted. The 122 `Abstained` Candidates are recorded history of the retired shape, and they are also the decision log, which exists precisely so retrospectives can read what the machine believed and refused. Purging them would destroy the dataset that makes the shape change auditable.

**T7 as amended:** zero abstention rows exist whose provenance is this run — filtered on the run receipt, or on the charter versions the pass stamps, whichever your build makes cleanest. Pre-existing rows are excluded by provenance, never by date, and the harness prints the excluded count so the exclusion is visible rather than silent.

Same treatment for the legacy `nobody_said` values already recorded: they stand, they read as legacy, and nothing writes another.

## 2 · T0's hash · the stored form is canonical, and the artifact is reissued

You found a real defect in the harness and the fix is to remove the ambiguity rather than document it. **Spans are byte-verified against the stored artifact, so the stored bytes are the artifact.** Anything else is a transport artifact with no standing.

The normalizer now emits no trailing newline, so the file and the stored form are byte-identical and there is exactly one number, forever:

**`ec8e7170…` · 42,784 bytes · 415 lines · 415 tabs · 0 no-tab lines.**

Your computed value confirms it independently. **The reissued artifact and normalizer are attached; re-sync `emerson-2026-06-17-nf1.txt` and `normalize_eci_paste.py`.** T0 asserts `ec8e7170` and the earlier `c6d056ba` is retired, not corrected in place, because it named a file that no longer exists.

**The law this earns, and it is the third bite so it goes in as law:** a normalizer's output contract is the stored form. Any transform the platform applies on save — trailing whitespace, encoding, rich text — is applied by the normalizer first, so that what we hash, what we store, and what we verify against are one thing and never three.

## 3 · The pair ledger · your mechanism is ratified, new object, two refinements

**New object, not `AAO_Candidate__c`**, and your reason is right but there is a stronger one. Candidate is defined as a proposed *claim* with per-row verification state, and it retires into the decision log. A call-1 pair is not a proposed claim: it has no subject, no person, and no verdict — it is an observation about the transcript. Different kind of fact, different lifecycle: the unowned rows must persist as the byte-verification and recall-gate record long after Candidate rows retire. The precedent is already in the envelope law, where handed and discovered findings get different containers for exactly this reason.

`AAO_Pair__c` with the self-lookup, as you describe. Two refinements:

**Make the stage an explicit field, not an inference from whether the parent lookup is null.** We already carry a scar from a state with two physical shapes (the unanswered answer row), and inferring stage from a null lookup rebuilds it. One picklist: `Located` / `Identified`. Cheap now, unpayable later.

**Carry an occurrence ordinal on the located row.** The rule is that a verbatim string matching more than once anchors every occurrence, so a pair needs to say which one it is, or the sidecar's timestamp lookup and any per-turn context window become ambiguous. On this fixture it will almost always be 1; that is not an argument for leaving it off.

Everything else stands as you wrote it: one-for-one-for-one is arithmetic over row counts per link, call 3 stamps the child, and no row is ever written for silence. Entity ruling to Model & Flow once you have built it.

## 4 · Contracts · mint new, supersede the 48, and here is the whole set

**Yes: mint new, supersede the 48, delete nothing.** The 48 are the person-crossed shape (16 × 3), which is exactly what ruling 2 retires; they are superseded by version, which is the mechanism already in the applicable-set law.

**The new set is 17 propositions, asked once per transcript.** On this fixture's five-person roster the old shape would have produced 80 contract-questions. That is the scaling law in one number.

### Provenance, stated because it varies by family

The vendor's verbatim text stays recorded byte-exact wherever it exists. Where a vendor question was two-sided, our one-way halves are **authored by us**, derived from it, and land `Inferred_Pending` until ratified — the same status Buyer Role already carries. The vendor's original is the source and stays in the record; the split halves are ours and are marked as ours. No paraphrase is ever presented as recovered text.

### Sentiment · 1 proposition · route E

| Code | Proposition | Meaning enum |
|---|---|---|
| `AAO_PS_1` | Do this person's own words voice how they stand toward us and our solution? | `MENTOR` / `SUPPORTER` / `NON_SUPPORTER` / `ENEMY` |

**Neutral is not emittable and that is deliberate.** Neutral is the derived reading when nothing stands, per §P8.4; a neutral pair would move the counter zero and write a row about nothing, which is the abstention we just retired wearing a different hat. Words that voice no stance produce no pair.

One-line label meanings, carried in the contract as the model's whole guidance, drawn from Altify's own value descriptions:

- **Mentor** — guides you with insight, and advocates for you inside their organization when you are not in the room.
- **Supporter** — prefers you and says so.
- **Non-supporter** — prefers an alternative, including doing nothing.
- **Enemy** — works against you, or believes your success harms them.

### Political Status · 8 propositions · route E · each points at exactly one placement

| Code | Proposition | Places | Source |
|---|---|---|---|
| `AAO_POL_IC1` | Does this person define the company's goals and objectives? | Inner Circle | authored half of `OM_..._QUESTION_1` |
| `AAO_POL_IC2` | Does this person approve and sponsor initiatives? | Inner Circle | authored half of `OM_..._QUESTION_2` |
| `AAO_POL_IC3` | Does this person control the outcomes? | Inner Circle | authored half of `AM_OM_..._QUESTION_4` |
| `AAO_POL_PS1` | Does this person execute projects after they are approved? | Political Structure | authored half of `OM_..._QUESTION_2` |
| `AAO_POL_PS2` | Is this person called on to make it happen? | Political Structure | authored half of `AM_OM_..._QUESTION_4` |
| `AAO_POL_PS3` | Do others seek this person out for advice and direction? | Political Structure | `AM_OM_..._QUESTION_3`, verbatim |
| `AAO_POL_PS4` | Does this person have a track record of success in implementing projects that deliver value? | Political Structure | `AM_OM_..._QUESTION_6`, verbatim |
| `AAO_POL_OPS1` | Does this person collect and provide information to people of power and influence? | Outside Political Structure | `AM_OM_..._QUESTION_7`, verbatim |

**Two of the vendor's seven are not declared, by the S1 precedent.** Q9 (political awareness) places nobody by the ceiling derivation and is true of everyone worth mapping — the same two faults that retired S1. The weak half of Q1 (merely understanding the goals) places nobody either: it is absent from the Political Structure list in the derivation, and a proposition that cannot move a value does not earn claim-path budget. Both stay recorded in the ontology, both undeclared. **This follows the S1 reasoning rather than extending it, and it is correctable if Matthew reads it differently.**

The ceiling derivation is unchanged: any Inner Circle establishment standing places Inner Circle; failing that, any Political Structure establishment places Political Structure; failing that, brokering alone places Outside; nothing standing leaves it unset, and nobody is placed outside the structure by absence of evidence.

### Buyer Role · 5 propositions · route E · all `Inferred_Pending`

| Code | Proposition |
|---|---|
| `AAO_BR_APP` | Does this person retain the right to review, approve or veto the decision, or to release the funds? |
| `AAO_BR_DM` | Does this person make the commitment to a vendor or a strategic direction? |
| `AAO_BR_EVAL` | Is this person responsible for analysing proposed solutions against defined criteria? |
| `AAO_BR_USER` | Does this person use, or will they use, the products or services being bought? |
| `AAO_BR_SIG` | Is this person the one who signs? |

Authored from the vendor's definition text, which is all that exists for this dimension.

### Decision criteria · 3 propositions · route E · per §P8.5

| Code | Proposition | Notes |
|---|---|---|
| `AAO_DC_N` | Did this person, in their own words, state a condition, capability or outcome and tie it to evaluating, choosing or proceeding with a solution? | Elements: identifiable condition, stance, decision linkage. Full or partial |
| `AAO_DC_F` | Did this person attribute the criterion to an organizational evaluation standard — a document, process, scorecard, committee or mandate? | Establishes Formal; a naming with no such attribution defaults Informal |
| `AAO_DC_R` | Did this person state that failing this condition blocks or ends the purchase? | Gate language only. Default unchecked |

The negative rules from the research satellite bind call 1 on this family: seller words never name a buyer criterion; a buyer's question is not a naming; a stated goal does not create a criterion; description of the current state carries no stance.

### Coverage · 0 propositions

Computed from participation, never extracted. No contract, no pair, no model.

## What this changes in your work list

Nothing in items 2 and 3 — take D1/D2, the unit-law fix, and the cheap count as planned; they were correctly identified as independent. The watermark fix joins them as part of the same one-bug repair. Contract minting and the pair ledger are unblocked by this note. Re-sync the two fixture files before T0 runs against anything.
