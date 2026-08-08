# Run `em0808-a23` · GATE 3's EXTRACTION TEST · the first unseen transcript

Fixture `emerson/aspentech-2026-07-29-nf1`, Source `a1XWD0000081H5R2AU`, sha
`9e9740060bd348a1b3f64e21c1352d19bb942a7c43f4eb083cea23354b24a26c`.
**Taken from the freeze list, never from the org**, per the ruling: the sibling row
`a1XWD0000081Gu92AE` carries `d0606eac` under the same uncomposed `NF1` stamp, and a query
sorted either way picks the wrong one half the time.

19,774 chars, 1,245 s, 3 speakers, Stage 3, same account as the training set and later in the
deal. Projected to `006WD00000TJmJZYA1`.

| file | rows | what it is |
|---|---|---|
| `pairs.csv` | 35 | every identified pair, `start_offset` and `length` verifiable |
| `claims.csv` | 66 | every claim on the deal, cumulative, retired rows included |
| `answers.csv` | 17 | standing answers with counter and projection watermark |
| `coverage.csv` | 8 | the coverage derivation: person, occasions counted, value derived, value on map |
| `regression-dispositions.txt` | 39 + summary | every assertion, one line |
| `timings.md` | — | per-callout wall, governors per stage, token usage per stage |

## The run

| stage | result |
|---|---|
| call 0 | **OPPORTUNITY**, opportunity side yes byte-located at 9775, account side no, deal `d1` named, opportunity grain dispatched |
| call 1 sweep | **35 located**: Sentiment 6, Political Status 12, Buyer Role 9, Decision criteria 8 |
| blank guard | **0 invocations** — all four families answered first look. A measured zero |
| call 2 | **28 to a person, 7 None, 0 Ambiguous** |
| call 3 | **28 verdicts, 10 upheld, 18 refused**, three batch sets |
| ledger | 35 located / 35 disposed / 28 verdicts — **HELD** |
| regression | universe 39, **checked 0, not applicable 39** (see below) |
| join | 10 claims, 10 answers, 1 counter rebuilt, 0 trapped, 0 verdicts rebuilt |
| projection | 1 Contact created, 1 populated, 4 unchanged, 0 blocked, 0 retracted |

**Provenance verified in-org against the frozen artifact: 35 of 35 verbatim strings byte-exact
at their stated offset and length, and every one locates exactly once.** Zero mismatches, zero
multiple-locates. Call 0's yes-quote locates the same way.

## What to read first, in order

### 1 · The seller is now a Contact on the customer's account

`buq7` located Wendy Higley's own words offering to pull up the terms and conditions, call 2
attributed them to her correctly, and **call 3 upheld a Buyer Role EVALUATOR claim about our own
seller.** The join wrote it and projection **created Contact `003WD00001QZE73YAH`, "Wendy
Higley", on Emerson Electric Co.**, then wrote her a Coverage value. `wendy.higley@altify.com`
is now a mapped person on the buyer's relationship map, and `answers.csv` carries her as
`AAO_BR_EVAL / UNVERIFIED / EVALUATOR`.

**Nothing in the system asks whether a claim's subject is on the buying side.** `internalDomains`
is passed into the join, but it is only used to resolve WHICH SELLER heard a claim, never to
refuse one made ABOUT a seller.

**a22 did the same thing and got away with it.** It identified `buq7` to Wendy and `buq12` to
Renee Martin, and call 3 refused both. The correct outcome on the training set was the
verifier's judgment, not a rule. This run is the same shape with the verdict flipped.

Renee Martin sits one upheld pair away from the same treatment; she is in `coverage.csv` at 1
occasion with no Contact yet.

### 2 · The vendor is displaying the word "CRITERION" as the buyer's decision criterion

`ALTF__Decision_Criteria__c` record `a0lWD00000GIbsjYAD` on this opportunity has
**`ALTF__Subject__c = "CRITERION"`**. Not a criterion, the word.

`AAO_DC_N`'s meaning enum is closed at exactly one value, the literal `'CRITERION'`, because the
proposition points one way and the enum exists so a wrong label is caught as our bug.
`AAO_PairCommit.mintCriteria` passes that meaning field to `AAO_Criteria.mint` **as the
criterion's text**, which then keys on it, stores it in `AAO_Subject__c`, and projects it.

Three consequences, all live:

- **Every criterion on an opportunity collapses onto one row**, because the key is
  `<oppId>|md5(text)` and the text is always the same word. This run "minted 2" and created
  zero new rows. `AAO_Criterion__c` holds exactly one row for the whole org.
- **Each run overwrites that row's provenance.** `CR-00000000` was created 6 August and now
  points at the 29 July Source and names Jefferson Vargas as its voicer.
- The a20 "1 criterion minted", the a22 "5 criteria minted, 1 projected to the vendor" and this
  run's 2 were all the same collapsing row. The projected-to-the-vendor number was counted as
  progress.

`AAO_Criteria.mint` refuses to truncate at 255 characters, with a comment saying a clipped
criterion "would read as the buyer's words while being ours". The value it is actually guarding
is not the buyer's words at all.

**Not fixed here.** The repair needs a decision about where a criterion's short name comes from:
the verbatim span is up to 205 characters of raw speech on this transcript, and a name the
buyer would recognise has to be emitted by the charter as its own field. That is charter work,
proposal-first.

### 3 · Twenty percent of the located evidence is about people who were not on the call

All 7 None dispositions are one shape: `AAO_BR_SIG` and `AAO_BR_APP` on the CFO and the
approvers, and `AAO_POL_IC2`/`IC3` on inner-circle members. **Call 1 found them, call 2
correctly declined to attribute them to anyone present, and they were dropped**, because a
mentioned person has no Participant row and the shadow-creation path is unbuilt. `AAO_Pass`
names this in its own comment.

**The training set never showed this shape: a22 had 0 None out of 44.** This transcript is a
contracting call about getting to PO, so the people who matter most to it — the CFO who has to
approve at this dollar amount, legal — are discussed and absent. That is not an unusual
enterprise call. It is the normal one.

Seven of 35 located pairs, 20%, are buying-committee facts the system found and could not keep.

### 4 · The CFO approval threshold was found twice, upheld twice, and minted nothing

`deq7` (REQUIRED) and `deq8` (FORMAL) both anchor at offset 9783 on Jefferson saying the deal
goes to the CFO at this dollar amount. Both upheld. **Neither is a naming**, and no `AAO_DC_N`
was emitted over that span, so the join reports both as typings that "type no criterion" and
the criterion does not exist. `deq4` is a third.

3 of 8 criteria pairs typed nothing. This is the a20 entry's "two stages disagreeing about one
sentence" arriving on unseen speech, and the sentence they disagree about is the single most
consequential procurement fact on the call.

### 5 · The regression set covers none of this, and said so in zero lines until this run

Every one of the 39 assertions is keyed to the 17 June sha or the B&V ref, so on this artifact
`checked` is 0 and `notApplicable` is 39. That is lawful and correct.

**But the disposition list came back empty.** The not-applicable branch incremented its counter
and `continue`d before writing a line, so a universe of 39 produced a `regression-dispositions.txt`
of zero rows, which reads identically to a harness that skipped every assertion. Every prior run
hid it, because every prior run was against a fixture the seed covers. **Fixed in
`AAO_Regression.check` and re-run**; the file now carries 39 `N/A` lines naming the fixture each
assertion is keyed to, and the universe reconciles.

**The consequence stands regardless: this run has no regression coverage.** The courtesy
conjunct, the alias, the watermark value test and the composed normalizer stamp have still never
been graded by the set.

## Coverage

Derived from occasions (source-system ref plus occurred time), not hashes. All occasions on this
deal fall inside the trailing 90 days, so the current numbers already satisfy the seventeenth
stamp's ruling; **the windowed re-derivation as calls age out is owed as a proposal and is not
built.**

| person | occasions | derived | on map |
|---|---|---|---|
| Jefferson Vargas (linked) | 2 | Multiple contacts | Multiple contacts |
| Ryan Couture | 2 | Multiple contacts | Multiple contacts |
| Neeraja Chimata | 1 | Brief contact | Brief contact |
| **Wendy Higley** | 2 | Multiple contacts | **Brief contact** |
| Renee Martin | 1 | Brief contact | (no Contact) |

Wendy is the only row where derived and on-map disagree, and she is the row that should not
exist. She also appears under three roster keys (`Wendy Higley` twice, `wendy_higley` once); the
alias resolves by email or by name within the account, and her altify.com address is not in the
buyer's account, so the halves do not join.

## The suite

**383 tests, 2 failures.**

- `ConvertToOpportunityTest.testgetOppCreationDetails` — the standing org-resident failure,
  not ours, named since 6 August.
- **`AAO_TriggerLawTest.theSmallTalkBoundaryStaysMutable` — OURS, and new.** See BUILD_JOURNAL.
  The composed normalizer stamp landed in session 77 without a full-suite run.

## What this run did not test

Recall. There is no answer key for this transcript, so the 35 located pairs cannot be scored
against what a human would have found. **The inverted grading sheet is where that number comes
from**, and it is owed from Matthew before recall on unseen speech exists as a figure.
Precision is gradeable from these rows today.
