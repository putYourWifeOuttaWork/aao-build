# AAO Board

> **The version lives on the stamp line below and nowhere else. Read this document first in every session and update it last.**

**v2.2 · 8 August 2026 · THREE RULINGS AT THE CLOSE, Matthew's, and the session ends here by his direction with the next session seeded below. (1) COVERAGE IS A TRAILING-90-DAY CONVERSATION COUNT, simple arithmetic, no ontology: how many conversations with this person in the last three months; a first call brings a person to one; the count maps to the vendor values as built. GATE 2 CLOSES on this ruling, because the current derivation already matches it exactly (Neeraja 1, Ryan 2, Jefferson 2, all occasions inside the window). Consequence, proposal-first for CODE: a windowed count must RE-DERIVE as calls age out, not only when new evidence arrives. (2) THE HOT/COLD SPLIT IS RULED DESIGN DIRECTION: the claims chain (claims, claim bases, the volume-heavy history) streams to Data 360 after roughly 30 days; Salesforce holds the hot window; D360 is the memory plane as the architecture already carries. Two consequences recorded so they are designed rather than discovered: the replay law (counters, verdicts, retirement) must work across the split, reading D360 past the hot window; and the 90-day coverage window is the archive's first consumer, since it looks back further than the hot store. Proposal-first, never ordinary work; the D360 platform facts and the one unverified ConnectApi item apply. (3) THE FOREIGN FIXTURE: the next session carries a research task to obtain an enterprise-grade 30-to-45-minute B2B sales-call transcript. PREFER FOUND REAL SPEECH from the web; an authored-realistic transcript is the fallback and tests intake and format only, NEVER counting toward precision or recall, because grading our own authorship is the training-set problem again; Matthew may override in session. Design writes the sandbox account, contacts, and opportunity for whichever fixture lands. Matthew's production transcripts remain wanted in addition, not instead. THE SESSION ENDS HERE; the seed below is the next session's first read.**

**v2.1 · 8 August 2026 · THE VALIDATED FOLD. A three-agent audit (cold read by a stranger, final coherence, feasibility) ran over the whole document set before this rewrite, and this stamp carries its verdict and its consequences. THE VERDICT: the architecture is sound to keep building on; nothing in the evidence core is structurally broken; the defect-finding loop demonstrably catches its own errors, including its own celebrated successes, and that is the property that compounds. The precision half of the promise is solved and machine-checked per run. The parked risks are scale-plane, not People-semantics: enterprise orchestration undesigned (the run receipt is the oldest debt), cost per pass unmeasured, recall's within-read mode mitigated only by instruments, and the org-agnostic claim carrying three unclosed holes (the empty-license gate, the per-org classifier, zero foreign transcripts through intake). THE SEQUENCE ADJUSTS on the audit's three cheapest de-riskers, now standing in the inbox: the caller-side join split lands BEFORE the production fixtures run (the DML wall at ~33 pairs sits where dense calls land); a COST-PER-PASS MODEL is journalled from existing timings and put in front of Matthew BEFORE Problems adds families; and one of Matthew's production transcripts should be as foreign as possible, the cheapest test of the 80% no-Altify case. DOCUMENTATION DEFECTS FOUND AND FIXED AT THIS FOLD: this Board now carries the locked ledger and hazards IN FULL, never as deltas to superseded versions; the inbox header names no versions (the documents' own stamps are the authority); the courtesy conjunct is folded into Charters (v3.5) where it was ruled and built but never folded, the held-for-veto clause superseded in place; the adjudication sheet's stamp caught up with its content (v0.9); the Glossary gained the abbreviations and named laws a stranger meets undefined (v2.7); Model & Flow carries the loop era's fields (v1.5); the VERIFICATION SHEET exists (design's per-run checks as a written procedure); and the PRIMER exists (`aao-primer.md`, the one document a stranger reads first). PEOPLE REMAINS HELD OPEN BEHIND ITS THREE GATES, unchanged: the 29 July extraction run in a fresh CODE session (fixture from the freeze list, never the org), Matthew's three-line coverage grade, and multi-transcript validation awaiting his production pull. MATTHEW'S FIRST PRINCIPLE, recorded at this fold in his words' substance: People is 60 to 80 percent of the project; everything else in this operating system feeds off People exactly as everything in enterprise sales feeds off people; get this right and everything else becomes easy, get it wrong and we fail. The gates exist because of that principle and close only on graded evidence. Companion stamps, written after the bumps landed as the update-last law requires: Primer, Charters v3.5, Architecture v4.12, Model & Flow v1.5, Glossary v2.7, adjudication sheet v0.9, verification sheet v1.0, map read sheet v0.3, CODE inbox sixteenth stamp. Numbers from BUILD_JOURNAL: 383 tests, 382 AAO pass, one named org-resident failure.**

**What this is.** The one document a session opens first: current state, the complete law list, the open items with owners, and the next steps. When this document and a companion disagree, the companion's stamped body wins on substance and this board is corrected; the board wins only on what is open versus closed. Prior board versions do not exist; everything a reader needs is in this one.

---

## 1 · The documents, the actors, the locations

| Document | Authoritative for |
|---|---|
| **Primer** (`aao-primer.md`) | A stranger's first read; orientation and reading order |
| **Board** (`aao-board.md`) | State, the complete locked ledger, sequence, seeds |
| **Glossary** (`aao-glossary.md`, v2.7) | Vocabulary, abbreviations, the named laws |
| **Architecture** (`aao-architecture.md`, v4.12) | Every ruling with its reasoning; the loop era is the v4.2 through v4.12 heads |
| **Model & Flow** (`aao-model-and-flow.md`, v1.5) | Entities, keys, fields as built |
| **Charters** (`aao-charters.md`, v3.5) | The AI: every model call, the contracts, the resolver, the recovered ontologies |
| **Adjudication sheet** (`aao-adjudication-sheet.md`, v0.9) | Every human grading; §10 is the map read |
| **Verification sheet** (`aao-verification-sheet.md`) | Design's per-run checks, the written procedure |
| **Map read sheet** (`aao-map-read-sheet-v0_3.md`) | Matthew's read procedure on the product surface |

**The actors.** MATTHEW rules methodology and grades output, inverted. DESIGN (the session holding this document set) argues structural decisions before writing, defaults technical calls with both positions recorded, folds rulings, verifies every export per the verification sheet, re-stamps the inbox last. CODE is the builder: a Claude Code agent operating a git repository with the sandbox connection and NO production connection; a fresh CODE session's entire seed is "read the inbox top stamp."

**The locations.** These documents live in the claude.ai project (design's side) and as `docs/` in CODE's repository, carried between them by Matthew or the project. CODE's repository also holds: `BUILD_JOURNAL` (the only numeric record), `review/<run-id>/` (every run's export), `review/gate3/frozen-fixtures.md` (the freeze list, which disambiguates what stamps cannot), and the regression set. Exports reach design as files through Matthew. The CODE inbox (`CODE-INBOX.md`) is the standing channel; its top stamp is CODE's current instruction.

## 2 · Current state · 8 August 2026

**Org:** sandbox `altify--aossb2`. Production (`altify.my.salesforce.com`, org `00DHn000006jYatMAE`) read-only unconditionally; `altify-pbo` never read.

**The pipeline is whole and self-honest**, artifact to live vendor map: call 0 (one-way scope halves with byte-located evidence; the deterministic ladder as its input; NONE does not dispatch), the family sweep (one bounded read per family per transaction, blank-retry guard), identify from the closed roster, blind verify (courtesy conjunct structural, homogeneous batches), the join through the single writer (claims key the Participant; retire never delete; partial displaces nothing; traps refuse at the claim), projection (per-dimension watermarks, human edits absolute including on rows we never touched, retraction that stamps), coverage computed on conversation-keyed occasions, composed normalizer stamps going forward. Every run ships export, timings, governors, and the full regression disposition or it does not count. Regression set at 39 assertions, byte-keyed.

**People held open behind three gates:** (1) resolution: the split has corrected under-calls on both live fixtures (Emerson a17; B&V re-adjudicated DUAL); caveat failure count at one, the caveat gate named-not-built; (2) coverage: numbers honest after occasion identity and the alias; Matthew's three-line grade owed; (3) multi-transcript: corpus frozen NF1-only, training set named and excluded, B&V done (zero establishments correct: dual, deal NONE, nothing dispatched), the 29 July extraction run next in a fresh CODE session, production transcripts owed from Matthew.

## 3 · Locked · the complete ledger, not open to relitigating

- **LAW #1.** No ALTF package-version dependency, ever. Feature detection, never version checks. The system runs with Altify absent; the ontology ships as our seed metadata, org-overridable.
- **No metadata, triggers, or logic on any ALTF or native object.** Opportunity and Account never written by the product runtime; Contact toggleable (the toggle defaults ON, Matthew's, design's OFF recorded; overrides are picklists because a checkbox cannot express untouched); shadow persons permanent for toggle-off customers and never on the vendor map (`ALTF__Contact__c` is `nillable=false`, verified from the runtime).
- **Production read-only unconditionally. Evidence over inference. A capability claim is unverified until tried from the calling runtime, including claims about our own code.**
- **THE PASS IS PAIRS; CALL 1 IS A FAMILY SWEEP** (once per declared family, whole artifact, one transaction each; the call count never a function of participant count; questions once per transcript; cost scales with transcript length, never roster size). Call 2 identifies only, from the closed candidate list, NONE and AMBIGUOUS honest. Call 3 verifies the proposition blind and nothing else; the placement never reaches the reader; the courtesy conjunct is part of the sentiment proposition (stance toward us or our solution, never the meeting or the occasion).
- **CALL 0, ALWAYS:** the resolver's read on every Source before the sweep; deterministic ladder in Apex first, outputs as evidence; resolution consolidated into it; family reads are pure pair emitters; call 0 routes and resolves and never establishes. **THE SCOPE READ IS TWO ONE-WAY QUESTIONS**, each yes carrying a byte-locating quote; DUAL is both yes; NEITHER is sayable; a missing side throws. **SIDE-YES WITH DEAL-NONE DOES NOT DISPATCH** (routed-not-dispatched, journalled with the yes-quote; yes-with-NONE is the expansion-detection specimen at the Flags fold). **A PAIR'S SCOPE IS ITS READ'S DECLARED GRAIN.** The stretch-stamp law decides which deal, never which grain. Membership never routes.
- **THE OCCURRED-TIME CANDIDATE WINDOW:** candidates are open plus recently closed as of the evidence-occurred clock, never the run date. (Unverifiable in this sandbox; verifies at pilot.)
- **TRUE-OR-NOTHING:** every question points one way; no FALSE, no inversion; negative states establish from their own affirmative words; two-sided questions split into one-way halves (the scope read included, by the same law).
- **NO ABSTENTION ROWS, at any grain, ever.** The run receipt (owed, oldest debt) is the did-we-read-it record; one-for-one-for-one arithmetic between stage row sets; `assertOneForOne` returns HELD / INCOMPLETE / BROKEN. **DECLINED-TO-RUN AND RAN-AND-FOUND-NOTHING ARE DIFFERENT FACTS; neither ships the other's export.**
- **THE SENTIMENT COUNTER is Support's mechanism:** one move per distinct verified establishment toward the voiced state, never past it; net per call; clamp ±3; voiced-state ceiling (supporter-grade tops +2, mentor-grade reaches +3); terminals proof-gated, never time-gated; the standing value on the Support Answer row, rebuildable from claims in evidence-occurred order. **The label meanings are §P8.4's law: MENTOR is conjunctive and org-directed; ENGAGEMENT IS NOT STANCE; COURTESY IS NOT STANCE.**
- **CLAIMS KEY THE PARTICIPANT** (a Contact is a resolution outcome of a person, never their identity). **CLAIMS RETIRE, NEVER DELETE**; replays exclude retired claims; retraction clears what they carried and stamps its watermark like any write. **PARTIAL ACCRUES, PLACES NOBODY, AND DISPLACES NOTHING**; answer verdicts are monotone over evidence strength; zero live claims is UNVERIFIED, distinct from never-asked. **A TRAP THAT FIRES IS REFUSED AT THE CLAIM.**
- **DECISION CRITERIA JOIN PEOPLE; `AAO_Criterion__c` IS OURS** (the fifth subject type; the vendor row is its projection; contracts join by byte-range overlap); DC-F types by provenance; criteria are sparse by nature; buying-process mechanics and approval coaching are never criteria; **partial criteria project nothing until elements complete** (whether partials survive at all is Matthew's, held).
- **COVERAGE IS COMPUTED, NEVER EXTRACTED**, from distinct conversations (occasion identity: system ref plus occurred time; **TWO KEYS FOR TWO JOBS**, the artifact hash staying byte provenance); `In-depth` deliberately underivable; zero occasions writes nothing. **THE ALIAS, NEVER THE MERGE** (a merge rewrites what claims point at); unresolved-unresolved stays visibly split, never-pick.
- **THE NORMALIZER STAMP COMPOSES** (`NF1+raw:`); pre-composition rows keep uncomposed stamps permanently, because **provenance a later process can rewrite is not provenance**; the freeze list carries the disambiguation explicitly. **A normalizer's output contract is the stored form; NF1 is the fixture form; fixtures are taken from the freeze list, never the org.** **THE TRAINING SET IS NAMED so it can never be counted as unseen; authored fixtures never substitute for customer speech.**
- **A VERSION STRING COVERS EVERY INPUT THAT CAN CHANGE THE OUTPUT IT STAMPS** (charter prose plus contracts, composed per family read; normalizer version plus raw hash). **A WATERMARK IS WRITTEN BY THE WRITER OR IT DOES NOT EXIST**; the one lawful repair class is a named repair whose value is known, which refuses itself where preconditions fail. **A non-blank value our watermark does not claim was put there by a human.**
- **WHERE AN INSTRUCTION HAS FAILED TWICE, CHANGE THE STRUCTURE SO THE WRONG ANSWER CANNOT BE EXPRESSED.** **THE REFUSAL DOCTRINE:** a law that only permits corrections it can prove safe will sometimes refuse one that is safe, and paying that cost is what makes the law worth having.
- **THE ITERATION LOOP** (Matthew, 6 August): the inbox is the channel; row export, timings, governors, full-universe regression disposition with every run or it does not count; design verifies per the verification sheet; Matthew grades judgment, inverted (**THE BLIND KEY IS RETIRED**; output first; blank rows the only miss channel; findings state their nature, never a percentage); design defaults technical calls with both positions recorded. **Rulings travel through the inbox and as files; corrections into documents, never chat; wrong text marked wrong in place, never deleted; one structural decision at a time, options with costs, Matthew's calls left open.**
- **CEILINGS ARE PRINTED OR THEY ARE DISCOVERED IN PRODUCTION:** the 120-second cumulative transaction law (one bounded callout per transaction; caller-driven splits for calls 1 and 3); governor consumption per stage with an 80% marker; **a suite that cannot see a component is green about nothing; a required reason field satisfied by a non-reason fails loudly, never fills.**
- **THE OPPORTUNITY GRAIN LEADS; PRECISION BEFORE COVERAGE, per grain.** **THE ACCOUNT GRAIN IS BACKBURNERED, NEVER FORGOTTEN** (detection live; nothing account-side extracted, written, or authored; the five-row fixture and key attached; the family delta is small: Buyer Role out, Decision Orientation in). **DREAMFORCE IS NEVER A DECISION FACTOR.** **Agentforce is not part of this build.** No leads. Behaviour establishes, titles never matter in either direction; one quote, several establishments; advocacy is never discounted for coming from a professional; the families are not equally heavy. **NF1 is written law. Byte-exact propositions and spans. Citations on Answer rows only. No dismiss anywhere. Human override absolute. No decay. No em dashes in written output.**

## 4 · Open · with owners

**Matthew:** the gate 2 three-line coverage grade (Neeraja Brief 1, Ryan Multiple 2, Jefferson Multiple 2: True, or name the wrong one); the production transcripts as files, three or more, mixed shapes, one as foreign as possible; the empty-license gate ruling (what an org with no Altify license rows resolves to; currently the pipeline sees nothing there); poq7/seq2 standing; the Adam Meloan re-read; the Toby deck (deferred by his word, another conversation).

**CODE (fresh session; seed = read the inbox):** run 29 July from the freeze list, full standing obligations; then the sixteenth stamp's items: the caller-side join split BEFORE the production fixtures, the cost-per-pass journal, the ConnectApi verification, the foreign transcript through intake when it arrives. Standing debts: the run receipt object (oldest), regression temporal validity, the domain list's seed-metadata home at packaging.

**Design:** verify the 29 July export per the verification sheet; prepare Matthew's inverted grading sheet; present the cost-per-pass number when CODE journals it; the Flags and Guidance fold (two specimens: retraction, expansion-detection); the Problems charter after the gates; the ratification opens sequence before any pilot date; Dreamforce demo surface; persona emission.

**Parked, structurally unanswerable here:** module-licence detection; package-upgrade behavior of subscriber edits; provider batch endpoints (incompatible with trust mode today, never sold); the occurred-window and role-map verification (pilot).

## 5 · Next steps, in order

1. **The 29 July extraction run** (fresh CODE session), design verifies, Matthew grades inverted. The first numbers nothing was tuned against.
2. **The join split**, then **Matthew's transcripts** normalize, freeze, and run, each verified and graded. His gate 2 grade lands any time.
3. **The cost-per-pass number in front of Matthew** before any new family is declared.
4. If the caveat shape fails a second time in the corpus, the caveat gate is built as named.
5. Gates pass; **People closes; PROBLEMS opens** (Goal, Pressure, Obstacle, Initiative; charter design-side first; one structural decision at a time), with the cost model in hand.

## 6 · Standing hazards · the complete list

The only queryable orgs are Altify's own; ~80% of installs have none of its history (**the hazard stands until pilots answer it**). **THE TRAINING-SET HAZARD:** a calibration fixture's precision predicts nothing; unseen speech is the only real number. **THE ATTENTION HAZARD**, two named modes: the cheap whole-family blank (guarded, journalled) and the within-read miss (q9's mode; partitioning is the named unbuilt lever). **THE SILENT-SUCCESS HAZARD**, extended three times: a stage reporting success while writing nothing; a rule with a reporting half and no enforcement half; a write that skips its own watermark; the guard is arithmetic at every stage boundary, projection included. **THE GREEN-SUITE HAZARD:** a component with no tests, an unnamed failing test waved through, a suite proving a retired rubric. **THE KNOWN-RULE-UNAPPLIED shape:** a reader that paraphrases a caveat back and ignores it; wording has nothing to grip; structure is the only lever. **THE STAMP-LEDGER SPLIT:** pre-composition rows are permanently ambiguous by stamp; explicit lists carry that weight. **THE CORRECTION THAT DISABLES WHAT IT CORRECTS:** any correction path whose safe response to uncertainty is not-running, or that cannot stamp its consequence. **THE RATE HAZARD:** never gate on a ratio whose denominator is the thing being improved. **THE THIRD-STATE HAZARD:** a binary verdict on an incomplete pass must lie; name the state. **THE SPAN-BOUNDARY HAZARD:** one establishment across an interruption; two specimens; open. **THE BYTE-CHECK BLIND SPOT:** invented words are caught, shortened ones are not. Retrieval returns chunks from retired versions: open by path, demand stamps. ECI's related-record stamp is inference, misfiring both directions. Vocabulary: our answer row; verified, never scored; receipts, never confidence; Agentforce-ready, never Agentforce-dependent. `CreatedBy` cannot separate CODE from Matthew. FLS is a second fact beside deploy success. Lightning caches hard. A run that succeeds only on a cache hit is not a run that works. The unit, display, off-badge, run-date, decision-slot, and intake hazards. **The scale plane is honestly parked, not solved:** enterprise orchestration, cost per pass, per-org calibration shipping without a Matthew; the feasibility audit's findings stand in Architecture and the inbox until each is closed.

## 7 · The session seed

```
Seed - AAO single-purpose session. Focus: THE UNSEEN CORPUS.
Cowork session attached to the Altify Agency project.

Read first: aao-primer.md if you are new, then aao-board.md (v2.2),
then CODE-INBOX.md top stamp, then Charters and Architecture heads
newest-first. Open by exact path, never search. Numbers from CODE's
BUILD_JOURNAL only.

State on pickup: People is held open behind three gates and gate 2
(coverage) is CLOSED by Matthew's trailing-90-day ruling. Gate 1
needs the one-way scope halves to pass on live evidence (the caveat
gate is named and waiting on a second failure). Gate 3 needs the
29 July extraction run plus the corpus: Matthew's production
transcripts and one foreign fixture.

ACTIONS, in order:
1. Check whether the 29 July run's report and export landed. If
yes: verify per aao-verification-sheet.md, prepare Matthew's
inverted grading sheet. If no: CODE's fresh session runs it first;
its entire seed is "read the inbox."
2. RESEARCH TASK: obtain an enterprise-grade B2B sales-call
transcript, 30 to 45 minutes. Prefer found REAL speech from the
web; authored-realistic is fallback and tests intake and format
only, never counting toward precision or recall (Matthew may
override). Design the sandbox seed for it: account, contacts,
opportunity. Normalize through the ruled intake, freeze with
hashes, add to the freeze list.
3. Fold Matthew's production transcripts into the corpus as they
arrive; run, verify, and grade each fixture inverted.
4. CODE's queue rides the inbox: the 90-day coverage window with
re-derivation, the hot/cold D360 split proposal, the caller-side
join split BEFORE dense fixtures, the cost-per-pass journal before
Problems declares families.

Matthew's first principle, standing: People is 60 to 80 percent of
the project; get it right and the rest becomes easy, get it wrong
and we fail. The gates close only on graded evidence.

Rules unchanged: the iteration loop; one structural decision at a
time; design defaults technical calls, both positions recorded;
Matthew rules methodology and grades inverted; corrections into
documents, never chat; wrong text marked wrong, never deleted; the
account grain backburnered, never forgotten; Dreamforce never a
decision factor; no em dashes in written output.

At session end, when Matthew confirms: fold every ruling into the
documents, bump stamps, rewrite this board CARRYING THE FULL LEDGER
(never deltas), re-stamp the inbox last, write the next seed naming
one focus.
```

---

*End v2.2. This document is rewritten at every session end and carries everything; prior versions do not exist.*
