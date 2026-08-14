# AAO · What is not yet decided · the open-questions register · updated 13 August 2026 (first written 12 August)

**Update, 13 August.** New since first writing: **LOR (Level of Relationship) is ruled INTO the Politics scope** by Matthew, the junction between sellers and the customer's mapped people, target versus actual, and it is the last addition before People, Problems and Politics close together; its design is entirely open (how actual is measured, who sets target, how it increments, how human override rides a vendor junction with no watermark field) and is the next session's whole mission, seeded in `aao-seed-execution-2026-08-13-LOR.md`. Also new: the never-blank projection rule, the five-value buyer-role ladder keyed to stored values, and the org label-to-value map as People-charter configuration are all RULED (stamps seventy-five through seventy-seven), with CODE's build report expected; item 1 below (card versus roll-up answer) remains open; the second Farma call has no transcript (ECI will not produce one) and waits on Matthew's enterprise-Whisper transcription; the machine-versus-human comparison satellite is queued with its predates-the-call caveat. The seventy-fourth stamp's caution stands: the 331-second serial-driver wall is NOT comparable to the ratified ~59-second concurrent measurement and may not be cited against it.

**Written at Matthew's direction, 12 August: it is fine for the scope to carry parts that are temporary or undecided, provided they are named in one place rather than scattered, so the whole can be hypothesized against and taken apart deliberately. This is that place, in plain English, for humans.**

**How to read it.** Everything here is either not decided, decided provisionally, or decided but unbuilt. Nothing here is a defect in the sense of something broken and unknown; every line is known, deliberate, and parked. The ledger (`CODE-INBOX.md`) remains the authority on what is actually ruled; where this page and the ledger disagree, the ledger is right and this page is stale. Items are grouped by how much they could change the shape of the thing.

---

## A · Could change the architecture

**1 · Does a card need its rolled-up answer verified, or is its own quote enough?** Cards are written from individual verified quotes. Separately, the system keeps a rolled-up answer per person per question type, and that roll-up can read "unverified" while a card built from a verified quote stands on the board. The card's own evidence is sound and walks back to real words. The question nobody has ruled: should a card be held back when its roll-up disagrees? Design's lean is no, since the card is one insight from one piece of evidence. Open.

**2 · Run-to-run variance is accepted, not solved.** The same transcript run twice does not produce an identical map. It was measured (roughly four of seven load-bearing values stable across three runs), the cheap remedy turned out to be unavailable, and the expensive one (running the verifier several times and voting) was ruled out on cost. Matthew accepted the variance to close People, on the reasoning that real maps accrue across many calls and human edits win forever. This is a deliberate accepted risk, not a fixed problem, and it is the single most likely thing a pilot customer notices.

**3 · Everything measured so far comes from one company's org.** Altify's own Salesforce carries a decade of methodology data, its own package, and native call capture. Roughly eighty percent of installs will have none of that. Every finding to date carries the unstated question: does this survive in an org with no Altify history? Pilots answer it; nothing else can.

**4 · The small verifier's judgment has been graded on very little.** The verifier moved to a faster, cheaper model, which is also a genuine downsize. One transcript has been read since. Its judgment quality rests on a handful of graded cards rather than a body of evidence.

**5 · The Surface — the seller briefing and leadership roll-up — is scoped but deliberately unstarted.** It waits on Flags, because a briefing without "what needs attention" has no spine. Design's recommendation: build it after Flags, as one object with two projections.

**6 · Flags themselves are not in scope yet.** The product's stated purpose includes raising a flag where a necessary condition is unmet and time is running out, with no dismiss button anywhere. None of that is built.

---

## B · Decided provisionally, and could be revisited

**7 · Completeness now accumulates across conversations (new, 12 August).** If words in March satisfy part of a question and different words in June satisfy the rest, the requirement counts as complete. The union is deterministic arithmetic at the join; no model is told what March established, so the verifier stays blind. Every element keeps its own quote, speaker, and date, and an assembled establishment is never displayed as one continuous sentence. New this week and unexercised: no genuinely partial establishment exists on the current fixture.

**8 · The word "coverage" is being renamed to "completeness" on our side.** Altify already uses "coverage" on the relationship map for how well a person is known. Ours meant something different, which is a collision on the surface sellers actually read. The rename is ruled; the documents follow at the next fold.

**9 · Insight cards are identified by the evidence they came from, not their headline.** This stopped the board inflating on every rerun. Underneath it, the original rule stands: a later call restating the same problem in different words reinforces the existing card rather than creating a new one. That reinforcement path has never actually fired, because no fixture has yet repeated an insight.

**10 · Who gets linked to a card is derived from established roles.** Evaluators and above are treated as responsible for initiatives; users and the affected function as impacted by obstacles and pressures; goals link only to decision makers or explicitly stated metric owners. The functional-team half (matching "SalesOps" to a sales-process obstacle by title) is specified but not built, and it involves a judgment call rather than pure data.

**11 · The vendor's link records cannot record who wrote them.** There is no field to mark a link as machine-created, so our protection is that nothing existing is ever modified or deleted. Acceptable now; worth revisiting before a customer install.

**12 · Section titles fall back to the date.** Each call's insights get their own board section titled by date and meeting title, but nothing in the current data carries a meeting title, so sections currently read as dates alone. It fills when a Teams or Gong connector lands.

---

## C · Ruled but not built

**13 · The seven "wrongly refused" rows** — establishments Matthew graded true that the machine refused — are the most valuable regression material available and are one ruling away from being used. They were deliberately not folded in, because the original instruction named three things to fold and this was not one of them.

**14 · The regression set cannot express a per-person grade.** A test assertion keys on the words and the question but carries no subject, so "true for Kayla, false for Dan" on the same sentence cannot be encoded. The first attribution error is on file and cannot be trapped.

**15 · Span sets are ruled with their limits set, but not built.** A single establishment will eventually be allowed to cite up to three separate spans of speech rather than one.

**16 · Decision Orientation** has been asked for three times during grading and remains undeclared as a question family.

**17 · Solutions** — the fifth insight lane on Altify's board — has no questions and no cards.

**18 · Influence and conflict edges are deferred by ruling**, in favor of connecting people to insights first.

**19 · Account-level insights** exist in Altify's model (goals, pressures and initiatives live at account level too; obstacles do not). We build at deal grain only.

**20 · Split events and card-writer timings** are recorded as zero because nothing reports them yet.

---

## D · Known imperfections we are living with

**21 · Something upstream damages a word at a seam.** Two verification notes out of 344 contain a stray character mid-sentence with letters dropped around it, suggesting a text assembly step is joining fragments badly. The export fix makes them ship cleanly, which hides the symptom. Not investigated.

**22 · The internal-person guard filters rows, not identities.** If one person's records were somehow marked internal in some places and not others, part of their data would slip through. No such person exists today.

**23 · One export is permanently unrecoverable.** A CSV corrupted before the fix was found, and its underlying records no longer exist in the org, so it stays corrupt.

**24 · Two false upholds from an old contracting call reproduce in the current pipeline** on byte-identical ranges. Known, reproducible, unfixed.

**25 · Concurrency and throughput have never been measured.** Single-run speed is proven (about a minute per transcript, well clear of platform limits). Running many at once, which is what ten thousand a day requires, is unmeasured.

**26 · Whether the product can fetch its own transcripts from Apex is unverified.** Call metadata and participants are readable; the transcript body is not, and the one remaining candidate interface has never been tried from the runtime. This is the difference between capture-at-source and hand-carry.


---

**Update, 13 August, evening (appended; everything above stands).** The seventy-seventh stamp's build is ratified, acceptance verified in-org on both halves: Adam reads Approver with Evaluator cited in his note, and blanks survive only where nothing is established. Matthew has answered on the second Farma call: NO Whisper transcript is coming, the call parks until a transcript exists by any lawful path, and the Emerson stacked run now leads the test queue. LOR discovery ran against both orgs (seventy-eighth stamp): the vendor junction is seller-to-contact, deal-agnostic, the rank lives in the display labels, no watermark surface exists on it, the sandbox carries zero rows, and production carries 213 of which 104 have no seller. One item newly open:

**27 · What moves CurrentLOR is not ruled.** Deterministic occasion-counting can honestly support only the bottom rung, per the In-depth precedent that arithmetic cannot claim depth. Evidence-established levels need new question families and a self-praise guard, because a seller's own words about the relationship establish nothing. The counter mechanics are the proven carrier for a laddered state over time. Options and costs are at the seventy-eighth stamp; design's lean is evidence plus counter with a deterministic floor; the target (DesiredLOR) stays human-only on design's default. Matthew rules.


---

**Update, 13 August, night (appended; everything above stands).** Item 27 is RULED (seventy-ninth stamp): evidence-established levels with a deterministic floor, highest upheld rung standing, no machine down-moves in v1.0, target human-owned and ignored completely. The LOR charter draft (`aao-politics-lor-draft-v1_0.md`) awaits Matthew's plain-word yes; the read-only measurement run is approved behind it. The Wells Fargo stacked authored corpus is directed (two to three stage transcripts, five to six people, mechanism only, never counting), deliberately carrying the never-exercised paths: reinforcement, cross-call accumulation, LOR movement with a control pair. The config inventory ships as `aao-config-inventory-v0_1.md`. Three items newly open or moved:

**28 · Whether the full deal demonstrates without Process is Matthew's open question.** People, Problems, Politics and LOR may be sufficiently powerful for the Dreamforce story on their own; Process is scoped but nothing is built. The demo runsheet inherits this decision.

**29 · The D360 connection is now a POC gate** (Matthew, 13 August). The hot/cold split proposal moves from queued to load-bearing. Every Data 360 capability fact is unverified until tried from the runtime; nothing about streams, retention, or query-back is asserted yet.

**30 · Machine down-moves on LOR are deferred by design, not ruled out.** Relationships sour in ways absence cannot evidence; in v1.0 only a human lowers a level and human edits win forever. If down-moves are ever wanted, the sentiment counter's machinery is where they land.


---

**Update, 13 August, late (appended; everything above stands).** The Emerson stacked run ran as TWO calls, not three: design's "three frozen graded calls" claim was wrong and is marked wrong in place at the eightieth stamp. It proves mechanism only, never accuracy, because one of the two calls is the training set. What it did prove on real speech: per-call sections, coverage firming across calls, the creation leg firing, human precedence holding, and DUAL on the fixture gate assertion 1 has wanted since the tenth stamp. Two rulings and one grading question came out of it. Changes to items above: item 9 (cards identified by evidence) and the reinforcement counter now key on byte INTERSECTION, not identity, at both grains; item 20 stands. Newly open or newly known:

**31 · The same utterance found twice by the two reads was inflating counts and duplicating cards.** Ruled at the eightieth stamp: reinforcement counts distinct utterances, tested by byte intersection within a Source, both claims still standing as evidence and only the counter changing. Built next; the seven inflated Emerson counts and one duplicated card pair correct through the lawful path.

**32 · A duplicate person was created on a live map and landed at the top of the buyer-role ladder.** "Fatima" was minted as a new Contact while the seeded Fatema Choudray, the same human, sat on the same account, and her row wrote Signature Approver. The ladder had no rung for a bare given name, and the guard believed to stop this ("a Contact needs a last name") never covered a single-token first name. Ruled at the eightieth stamp: a given-name rung scoped to the account links, and a single-token designator can never create. Until built, machine-created contacts on any run deserve a human glance.

**33 · One utterance produced both a Goal card and an Obstacle card with identical text.** The first cross-type calibration specimen on real speech, and Matthew's grade to make; design does not grade it. His ruling becomes the type-matching regression assertion.


---

**Update, 13 August, later still (appended; everything above stands).** The eightieth stamp's queue is built and ratified (eighty-first): the counter reads Established 20, Reinforced 7, Corroborated 10 with ten corrections run lawfully both-halves, the duplicate CFO card collapsed through the writer's own mechanism, and the Fatima map row retracted with its reason. Two corrections to item 32: what closed the duplicate-person defect is the CREATION BAR, not the matching rung (the rung matches exactly and cannot link Fatima to Fatema, and while the twin stands it matches the twin); and disowning the twin EXCLUDES it from the purge by the twenty-first stamp's own semantics, so its deletion is Matthew's by hand or it stands. Item 31 is built and closed. Newly open or moved:

**34 · The ruled resolution stage is not on the driven path.** The deterministic merge, designator ladder and corroboration marker (`AAO_Resolve`) have zero production callers; the pass models every located pair instead, and zero of 67 stacked-run pairs carry corroboration. Ruled at the eighty-first stamp: the divergence closes to the twenty-seventh stamp's shape, proposal-first, one implementation surviving, ahead of the Wells Fargo and LOR runs. This is the third written-law-versus-driven-path divergence found by measurement; the class is now worth a standing audit line whenever the machine read sheet regenerates.

**35 · Feature detection is temperature-specific, not general.** The forty-third stamp recorded it as generalized to every model knob; the repo says only temperature carries the detect-and-retry shape today. Corrected in place there. The BYO-LLM law stands; the generalization is owed. Also confirmed: no lane flag exists anywhere, so batch versus express is currently a driver behavior, not configuration.

**36 · The signer's evidence is held on a retired subject.** Fatema Choudray's Signature Approver establishment stands retired with sound words and a wrong subject. The lawful door to land it is a human ALIAS from "Fatima" to her Contact plus a rerun; no fuzzy matching is ruled and none is proposed.


---

**Update, 14 August (appended; everything above stands).** The development laptop was lost 13 August; nothing was lost with it. Every document survived in the project mirror, the build survived in the sandbox (126 classes, verified by live query), and the whole corpus is back on disk on the new machine as of today, with every fixture hash-verified byte-exact. LOR is now RATIFIED WHOLE AND BUILDABLE (eighty-fourth stamp, Matthew's plain-word yes); the read-only measurement run is CODE's next build after the re-baseline completes, and item 27's whole chain is closed. Item 31 (reinforcement by byte intersection) is built and verified in-org: Emerson stands at Established 20, Reinforced 7, Corroborated 10. Item 34 (the resolution divergence) is ruled closed to the twenty-seventh stamp's shape, proposal-first; the per-leg diff report is queued. Still open and unchanged: items 1 through 26, 28, 29, 30, 32 (the twin's deletion is Matthew's by hand), 33 (the cross-type card pair awaits his grade), 35, 36. Newly recorded, transient rather than structural, carried in the eighty-fifth stamp rather than as a numbered item: the new build repository's GitHub remote is publicly readable and must be flipped private before anything is pushed; and Matthew's Time Machine answer is still owed before the metadata retrieve.
