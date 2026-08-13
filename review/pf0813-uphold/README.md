# The uphold governs, completeness accumulates, and the word is renamed · 13 August 2026

**Authorizing bytes, per the receipt rule.** Seventieth stamp item 6: *"implement the join-side union
per items 3 and 4 — union covered element ids on the standing answer, retain every element's own
dated span, never merge spans into one quote, same subject and contract only; report by rows what
changes on the current fixture... Everything else in that queue stands: derive-from-elements, the
rename to completeness, the card-writer receipt leg."* And item 3: *"THE UNION IS DETERMINISTIC AND
HAPPENS AT THE JOIN, NOT IN A MODEL."*

Suite **470 tests, 469 pass**; the lone failure is the standing org-resident non-AAO
`ConvertToOpportunityTest`.

---

## 1 · The union was already built, and the fixture that proves it already existed

`AAO_Accumulate.mergeCoverage` has unioned covered element ids across claims since accumulation was
written: covered is a union, missing is what was missing less whatever this claim covered. Because
the merge happens per ANSWER, and an answer is keyed subject-plus-contract, the union is
same-subject-same-contract **by construction** rather than by a check that could be forgotten.

The seed's two-transcript fixture is exactly Matthew's shape — one element in transcript one, the
missing one eleven days later — so the ruling is provable on a fixture written long before it. Two
tests now pin it, both corrected in place from tests that asserted the retired law:

- the union moves and never loses what it had;
- **the spans are not merged**: two spans, two Sources, each keeping its own quote and offsets, so a
  reader can see the establishment was assembled and when.

**No model reads state and call 3's blindness is untouched.** Set arithmetic in Apex, at the join.

## 2 · The citation was NOT honouring the integrity condition, and that was a real defect

Found by reading `AAO_Project.citation` against the ruling. It took `spans[0].speaker` and paired it
with **the answer's** `AAO_Evidence_Occurred__c` — a clock that only ever moves forwards. So an
establishment carrying March's words and June's words credited **March's speaker with June's date**:
a citation for a moment that never happened, assembled out of two that did.

Harmless on today's fixture because every span shares one source, which is exactly why it survived.
Matthew's ruling makes accumulation law, so it becomes wrong the first time a second call lands.

Now each span carries **the date it was said**, resolved from its own Source, deduped and
date-ordered. The single-source case renders exactly as before (`Dan Lewis, 30 July 2026`); the
accumulated case renders as what it is (`Adam Pfeiffer, 3 March 2026; Adam Pfeiffer, 12 June 2026`).

A regression I introduced doing it, caught by the note test and fixed: an answer with **no** spans
lost its date entirely. Losing a date is a smaller error than attaching the wrong one, and still an
error.

## 3 · The uphold governs · 4 of 22 proposals change

`AAO_PairCommit` no longer reads call 1's voiced coverage label to propose a verdict. Only upheld
pairs reach the candidate builder, so the proposal is TRUE and completeness travels as data.
`AAO_Accumulate.verdictFor` no longer routes on completeness at all.

Measured on `pf0811-goal`, by rows:

| pair | contract | elements | voiced | old → new |
|---|---|---|---|---|
| `r2q6` | `AAO_PB_OBST` | 1 | Partial | UNVERIFIED → TRUE |
| `r1q9` | `AAO_PB_OBST` | 1 | Partial | UNVERIFIED → TRUE |
| `r2q33` | `AAO_DC_F` | 1 | Partial | UNVERIFIED → TRUE |
| `r2q32` | `AAO_DC_N` | 3 | Partial | UNVERIFIED → TRUE |

**4 of 22 upheld coverage-taking pairs.** Three are single-element contracts where "Partial" was
never expressible at all.

## 4 · TWO CONSEQUENCES THE STAMP DID NOT NAME, and both needed deciding rather than absorbing

### (a) A completing utterance was being counted as REINFORCEMENT

`AAO_Commit` marks a claim Reinforced when its verdict equals the standing one. While the first
claim read UNVERIFIED the verdicts differed, so this branch **never fired on a completing
utterance** and the conflation was unreachable. The moment both read TRUE, the accumulation fixture
came back `{Reinforced=1, Upheld=1}` where it had been two establishments.

That collapses two of the three axes the sixty-ninth stamp named apart and forbade collapsing:
completeness is which parts of the question these words answer; reinforcement is how many times a
person said it. **Reinforcement is a count guidance ORDERS BY**, so inflating it with completions is
a lie about how often somebody pressed something — the same lie the pair watermark exists to
prevent, arriving through a different door.

Fixed deterministically: a claim that carries an element the standing answer did not have
**advanced** the requirement and is Established, not Reinforced. Pinned by its own test.

### (b) The ruling was about to reverse a HELD decision on a customer-visible vendor object

`AAO_Project.projectCriteria` gated the `ALTF__Decision_Criteria__c` write on the naming answer's
VERDICT — which worked only because a partial used to write UNVERIFIED. Under the ruling an upheld
partial reads TRUE, so **partial criteria would have started reaching the vendor object**, silently
reversing the standing partial law (*"whole criteria only; partials' fate is Matthew's after the
measurement, held"*). Neither the sixty-ninth nor the seventieth stamp mentions criteria; nothing
ruled that reversal.

The gate now reads **completeness** rather than the verdict, which is what it always meant and which
the same ruling makes the proper home for. Both conditions stand explicitly: the verifier must have
upheld it AND the elements must be whole, so a refusal still never reaches a customer row either.
`AAO_CriteriaTest.onlyWholeCriteriaReachTheVendorObject` passes unchanged, which is the point.

**This forced the other half of the sixty-eighth stamp's self-contradiction to be closed too.** The
join stamped `covered = every declared element, missing = []` UNCONDITIONALLY, so completeness was
always "complete" and the criteria gate would have been useless. It now records what the read
actually found: one element on a one-element contract; every element where the read said Full; and
on a multi-element contract where the read hedged, **only the element the span is offered for**,
with the rest missing. It invents no split and claims no more than it has.

## 5 · The rename

`AAO_Element_Coverage__c` → `AAO_Element_Completeness__c` on `AAO_Answer__c`, `AAO_Claim__c` and
`AAO_Candidate__c`. **19 Apex classes**, every reference switched; zero remain.

- **The old field is RETIRED IN PLACE, not deleted**, because deleting a field destroys its data and
  this one holds the completeness record of every establishment made before the rename. Its
  description now says so and points at the successor.
- **Backfilled: 41 answers, 128 candidates. 104 claims were NOT backfilled**, and that is the law
  rather than an omission: `AAO_Claim__c` is insert-only apart from retirement. Claims are immutable
  evidence, so their history stays exactly where it was written — on the retired field, which is why
  retiring in place rather than deleting matters. New claims write the new field.
- Two mechanical facts worth recording: a **long text area cannot be filtered in SOQL**, so the
  backfill reads whole and skips in Apex; and a **universally-required field cannot appear in a
  permission set's field permissions**, which failed the first deploy of the receipt FLS.

Documents are design's, per the stamp: *"reported before any document edit so the Glossary fold
absorbs one consistent change."* This is that report.

## 6 · The card writer's receipt leg

`AAO_Cards.run(opportunityId, runKey)`, the same overload shape projection took. The last stage of
the pass to get one. `AAO_Receipt.STAGE_CARDS` is no longer declared-and-unwired.

## 7 · Nine tests corrected in place, none deleted

Every one asserted the retired gating law. Each carries a comment naming the ruling, what the
assertion used to protect, and where that protection now lives. Three are worth naming:

- **`AAO_TriggerLawTest.claimsCannotBeEdited`** looked alarming and was not. It set a claim's verdict
  to TRUE and expected a throw; the claim now already reads TRUE, so the update moved no field and
  the handler correctly allowed a no-op. **Claim immutability is intact** — the test's setup went
  stale, and it now mutates to a value that genuinely differs.
- **`AAO_FlagsTest`** asserted a red still Standing after pass one. Pass one's words were upheld, so
  they establish, and an establishment clears a red. The law it protected — only an establishment
  clears a red, nothing else — is unchanged and still asserted.
- **`AAO_EvidenceLayerTest.verdictRoutesOnCoverage`** guarded *"an empty missing list is a claim by
  the proposer, not a fact."* That guard is not lost; it **moved upstream and got stricter**. The old
  version let a wrong record stand and corrected for it at read time; §4(b) makes the record right at
  write time instead.

## 8 · WHAT HAS NOT CHANGED, and nobody should read this report as saying it has

**The two UNVERIFIED answers on Project Farma still read UNVERIFIED.** Measured after the fix:

```
STILL UNVERIFIED: Adam Pfeiffer / AAO_DC_N   completeness {"missing":[],"covered":["e1","e2","e3"]}
STILL UNVERIFIED: Dan Lewis   / AAO_PB_OBST  completeness {"missing":[],"covered":["e1"]}
```

Their claims were born UNVERIFIED under the old rule, **claims are insert-only**, and a replay
rebuilds from those same claims. The committed pairs are watermarked so a rerun skips them. So the
ruling governs **from the next pass**, and correcting the standing rows needs a purge and rerun,
which is Matthew's call and costs model calls nobody has authorized. The fix is proven by 470 tests
and by the row-level measurement in §3; it is not proven on this deal's live map, and this report
does not claim it is.

The Inspector reads clean after the rename: 5 people, 24 upheld, 21 refused, 0 defects, and the
performance panel still honestly reports that this run journalled nothing.

## 9 · Rows, timings, governors, retryNotes

No model calls this session. **retryNotes: none.** `AAO_Project.derive` gains **1 SOQL** for the
per-span occurred clock, resolved once per projection rather than per citation.
`AAO_Project.projectCriteria` gains **1 SOQL** for the naming contract's element ids. Backfill: 3
queries, 3 DML, 169 rows.

## 10 · Named for design, not acted on

- **A contract declaring no elements now establishes on an uphold** where it previously unverified by
  construction. That was never a completeness question; it is a **mint-time data defect**, and
  catching it by quietly unverifying every establishment made against it was the wrong place. It has
  no guard today.
- **Split events remain zero** on every receipt: the field and roll-up exist, and no caller reports a
  split yet.
