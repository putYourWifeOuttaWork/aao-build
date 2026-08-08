# Run `pf0808-p1` · PROJECT FARMA · the first positive foreign measurement, on the live map

Fixture `projectfarma/2026-07-30-nf1`, Source `a1XWD0000082Z1t2AE`, artifact sha
`018cac1bb5a3425190678af890e7fc4a8794579353498c6ea67b18fd6690f7b6`, raw sha `75917ba2…`
verified on receipt (bytes, lines, hash exact). Stamp `NF1+raw:75917ba2`. Real Altify sales
speech, Jennae demoing Account Manager to Project Farma, 73 minutes, MS Teams via ECI, Stage 1.
Projected to the live map on opportunity `006WD00000TWzu5YAD`.

**Counts fully under the inverted method.** This is the run Matthew grades on the map surface.

| file | rows | |
|---|---|---|
| `pairs.csv` | 59 | every identified pair, offset/length verifiable |
| `claims.csv` | 15 | claims on the deal |
| `answers.csv` | 12 | standing answers |
| `coverage.csv` | 5 | derivation |
| `regression-dispositions.txt` | 40 | all N/A (seed keyed to Emerson/BV) |
| `timings.md` | - | stages, governors, the call-2 finding |

## The run

| stage | result |
|---|---|
| call 0 | **OPPORTUNITY**, deal resolved, quote byte-located at 49882 (it captured "Rich" the approver and the ASR spelling "Perkerwicz and Elmer" verbatim) |
| call 1 | **59 located**: Sentiment 11, Political 21, Buyer Role 18, Criteria 9; 2 byte-discards; zero blank retries |
| call 2 | **57 to a person, 1 None, 1 Ambiguous** - but see the ceiling finding below |
| call 3 | **15 upheld, 42 refused** |
| ledger | 59 / 59 / 57 - HELD |
| join | 15 claims, 12 answers (**4 established TRUE**), 1 criterion minted, **0 seller-subject**, 0 trapped |
| projection | **3 contact rows on the live Project Farma map, 1 Contact created (Dan Lewis); the 1 criterion correctly held OFF the map** |

**Provenance verified in-org: 59 of 59 verbatim byte-exact at offset, each unique.** On a
hand-carried capture, the byte layer held; ASR spellings ("Perkerwicz and Elmer", "Shanaya") are
preserved verbatim per the evidence law.

## What is on the live map, and it is the right three

| person | support | role | coverage | how |
|---|---|---|---|---|
| **Adam Pfeiffer** (SVP, Commercial Excellence) | Supporter | Decision Maker | Brief | "It's going to be us, our recommendation, and it'll go to our president, Rich" |
| **Dan Lewis** (no production Contact - **created**) | Non-Supporter | Evaluator | Brief | "we'll be looking at other options"; pricing/feature evaluation |
| **Kayla Stanley** (Sales Ops) | - | - | Brief | coverage only |

Adam leads the recommendation and likes what he saw; Dan is the skeptic pushing on price and
alternatives; Kayla is present. **Every upheld establishment cites a real participant and a real
quote.** The map reads like the call.

## 1 · THE DEMO-NARRATION TRAP HELD - the fixture's headline test

Roughly half the transcript is Jennae narrating a fictional demo org: Clara Wilson, Beth Angel,
Charles Underwood, the accounts 3M, Granfis, Republic Services. **The stamp's acceptance
criterion: "a run that puts Clara Wilson on Project Farma's map has failed no matter what else it
did."**

**Nothing fictional reached the map.** All 3 created rows and all 15 upheld claims are real
participants on real quotes. Not one cites Clara Wilson, Beth Angel, 3M, or any demo-org content.

**How it held, mechanism by mechanism, because the how matters more than the pass:**
- **The demo-org people are not on the roster**, so call 2's closed candidate list cannot name
  them. A quote about Clara Wilson, spoken by Jennae, either identifies to Jennae (the speaker)
  or returns None - it can never identify to "Clara Wilson," because she is not a candidate.
- **Jennae is marked internal (seller)**, so any claim that did identify to her refuses at the
  join's subject gate. The join reports **0 seller-subject refusals**, meaning call 2/call 3
  already declined to attribute demo content to her as a buyer - the gate was a backstop it did
  not need this run.
- **The never-invented law**: call 2 cannot mint a candidate, so a fictional name has nowhere to
  land. This is the closed-candidate-list safety mechanism doing exactly its job on the hardest
  natural test in the corpus.

This is the strongest single result of the run: **on real speech deliberately shaped like
establishable content, the pipeline established nothing false.**

## 2 · THE CEILING THIS RUN DISCOVERED · call 2 does not scale, and the schema cannot force it

The sweep located 59 pairs on 73 minutes of speech. **Call 2 - the one stage handed every located
pair in a single call - returned ONE disposition and stopped at `end_turn`.** Not truncation (63
output tokens against a 12,000 budget): the model produced a one-element array and considered
itself done. It repeated at batch 15, 6, and 3. Only **batch=1** returned reliably.

- **a23 (35 pairs, short turns) returned 33 and hid this.** The schema's `dispositions` array
  only *described* "exactly N entries"; a23 complied with the prose, Project Farma did not. **The
  tuned-behaviour law reaching the schema:** a completeness that was only ever prose held on the
  fixture it was written against and failed on the first denser one.
- **The structural fix is unavailable.** `minItems`/`maxItems` would force the count, but
  Anthropic structured outputs reject an array `minItems` other than 0 or 1 (a 400, verified from
  the runtime). So the schema cannot make the model return N.

**What I built:** call 2 now splits by pair batch (`AAO_Pass.identify(src, run, maxPairs)`), the
same caller-driven pattern call 1 (by family) and call 3 (by claim) already have, and the
one-for-one guard throws on any short return rather than letting pairs vanish. **What I could not
do:** make a batch larger than 1 return completely. This run reached its map by driving call 2 at
**batch=1, one identify per transaction, 59 transactions** - honest and correct (one pair in, one
disposition out), but a workaround, not the fix.

**Owed as a proposal, not built:** the real fix is to make call 2 reliably return N per batch.
Candidates, none obvious: a prompt restructure (the model treats the batch as "identify the
salient one"); or accept batch=1 as the identify contract and price it (59 small calls is cheap
in tokens but is 59 transactions). This is call 2's version of the caller-side split finding, and
it is now the load-bearing scaling limit, ahead of the join's DML wall which did not bind here.

## 3 · DAN LEWIS WAS CREATED - the create leg fired ahead of the create-leg record

Projection created a Contact for **Dan Lewis** (`003WD00001QZzh3YAD`) on Project Farma's account:
*"No Contact existed for this person. Created as 'Dan Lewis' from the source form 'Dan Lewis'."*

Dan is exactly the corpus record's "creation path's first real specimen": a present participant
who speaks throughout and has no production Contact. **But this is the OLD roster-participant
create leg** (`AAO_Identity`, Addendum 19), not the ruled mentioned-person path - Dan is on the
roster, so he never needed resolution. The old leg creates any roster participant with no Contact
when the toggle is on.

**The finding: creation fired without the create-leg record the twenty-first/twenty-sixth stamps
require to ship first.** "A machine-created row we cannot enumerate is a row we can never disown"
 - and Dan is now a Contact on a customer account with nothing systematically recording that we
made it. The old create leg predates that ruling and is still live. **Named for a ruling:** does
the create-leg-record precondition apply to the existing roster-participant create leg too, or
only to the new mentioned-person creation? On the current default it applies to neither, and Dan
is the live proof.

His establishments are otherwise sound (Non-Supporter, Evaluator, real quotes), and by the
presence-is-acceptance ruling a real participant belongs on the map - the question is the
enumerate-before-create discipline, not whether Dan should be there.

## 3b · THE ONE CRITERION WAS HELD OFF THE MAP - the whole-only naming gate working

The join minted exactly one criterion (`AAO_Criterion__c` CR-00000001, type Informal). **It did
NOT reach the Altify map**, and that is correct: its subject text is the placeholder `CRITERION`,
its criterion-naming answer (`AAO_DC_N`) carries verdict `UNVERIFIED`, and projection's whole-only
gate ships a criterion to the customer's `ALTF__Decision_Criteria__c` only when that naming verdict
is `TRUE` (`AAO_Project.projectCriteria`, the `criteriaHeldPartial` branch). So the org shows one
criterion held on our object and **zero rows on the vendor criteria object** - an un-named
criterion was kept off the map rather than rendered as the literal word "CRITERION." This is the
criterion-name design doing its job on real speech: the deal had criteria-shaped talk (9 pairs
located) but nothing that named a whole, verifiable criterion, so nothing false was written. It
also means the earlier note that a criteria pair "types no criterion" was imprecise - one was
typed, and then correctly withheld.

## 4 · What did not reach the map, correctly

- **Rich, the president** - mentioned by Adam as where the recommendation goes ("it'll go to our
  president, Rich"), no Contact, not on the roster. Dropped at call 2 (not a candidate). He is the
  mentioned-approver specimen and waits on the designator path (Pass 2).
- **The PerkinElmer advisory committee** ("Perkerwicz and Elmer") - an approval body, not a
  person. Cited in a criteria pair but it places nobody on the map, and the one criterion the
  join did mint was held off the map unnamed (section 3b).
- **John Van Schaick** - on the call, coverage only, no establishment. Correct.

## The ledger and the guards

59 located / 59 disposed / 57 verdicts, HELD. 42 refusals (unread this run; the refusal-quality
question is a23's, and these will be graded against the same lens). The subject gate saw zero
seller-subject claims. Zero trapped. The N/A regression fix produced 40 lines against an
all-out-of-fixture seed.

## What this run did not measure

Refusal correctness and the recall UNDER channel are Matthew's on the map. The 42 refusals are
not yet read; if they carry the a23 contract gaps (political membership-without-authority, the
sentiment guard), that is expected and is pass-2-era contract work. Capture is hand-carried, so a
disputed quote spot-verifies against ECI before a FAB or intake-failure grade.
