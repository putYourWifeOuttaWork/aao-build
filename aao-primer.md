# AAO Primer · the one document to read before any other · 8 August 2026

**Who this is for.** Any agent or person arriving with zero context, inside or outside the original project. Reading this, then the documents it names in the order it names them, is sufficient to operate. Nothing load-bearing lives in any chat history; if a chat and a document disagree, the document wins.

## What AAO is

Altify Always On: a Salesforce-native layer that reads sales conversations and verifies, per opportunity, which necessary conditions of the Altify methodology are true, binding every establishment to the verbatim words that produced it. It verifies; it never predicts. No dismiss button exists anywhere. Human edits outrank the machine forever. The build lives in the Developer sandbox `altify--aossb2`; production (`altify.my.salesforce.com`) is read-only unconditionally; `altify-pbo` is never read. Hard deadline Dreamforce, September 2026, and by standing ruling DREAMFORCE IS NEVER A DECISION FACTOR in design choices.

## What happens to one transcript

A call arrives as a Source, is normalized to NF1 (the stored form, hash-frozen, spans verify against its exact bytes), and then:

1. **Call 0, the resolver:** one model read plus a deterministic Apex ladder. Answers two one-way questions with byte-located quotes (opportunity content? account content?), resolves which deal (candidate, NONE, or AMBIGUOUS) and the people roster. A side-yes with deal-NONE routes but does not dispatch. The account grain is currently backburnered: detected, journalled, never extracted.
2. **Call 1, the family sweep:** one bounded model read per declared family (Sentiment, Political, Buyer Role, Decision Criteria), whole artifact each, one transaction each. Emits question-answer pairs: verbatim words, byte offset, voiced meaning, no person. A blank read matching the cheap-blank signature is retried once.
3. **Call 2, identify:** attaches each pair's person from the closed candidate list, or NONE/AMBIGUOUS.
4. **Call 3, verify:** a blind reader sees one claim and its quote, nothing else, batched homogeneously by family. Sentiment verifies a target conjunct: stance must be toward us or our solution, never the meeting.
5. **The join:** upheld pairs become claims (keyed on our Participant, never Contact); claims accrue to answers; the counter arithmetic runs; traps refuse at the claim; partial evidence accrues and displaces nothing.
6. **Projection:** answers write the Altify relationship map through one writer, watermarked per dimension; retraction clears what an emptied derivation carried; coverage is computed from occasions, never extracted. Claims retire in place when wrong; nothing is ever deleted.

Every run ships a row export, stage timings, governor consumption, and the full regression disposition, or it does not count as a report.

## The documents and the reading order

All live in one place (the project, or wherever this corpus is carried), one live copy each, version on the stamp line inside, changelog heads accumulate newest-first. Open by exact path; never trust a search chunk.

1. **`aao-board.md`** (v2.0 at this writing) — READ FIRST. State, the locked ledger, open items with owners, next steps, and the session seed. Wins on open-versus-closed; companions win on substance.
2. **`CODE-INBOX.md`** — the standing channel to the builder session ("CODE"). Its top stamp is the builder's current instruction.
3. **`aao-charters.md`** (v3.4) — the AI: every model call's charter, the contracts, the resolver (Part II), the recovered vendor ontologies (Part III).
4. **`aao-architecture.md`** (v4.12) — every ruling with its reasoning, newest heads first; the v4.2 through v4.12 heads are the complete recent record.
5. **`aao-model-and-flow.md`** (v1.5) — entities, keys, fields as built.
6. **`aao-glossary.md`** (v2.6) — every term, defined once.
7. **`aao-adjudication-sheet.md`** — the human gradings; §10 is the live map read.

Satellites (fixtures, research, demo materials) are named inside the Board. Numbers come from CODE's BUILD_JOURNAL, never from documents.

## The laws that bend everything else

No dependency on any Altify package version, ever; the system runs with Altify absent. Nothing of ours lands on objects we don't own; Opportunity and Account are never written. Evidence over inference: a capability claim is unverified until tried from the calling runtime, including claims about our own code. Corrections go into documents, wrong text marked wrong in place, never deleted. Where an instruction has failed twice, change the structure so the wrong answer cannot be expressed. True-or-nothing; no abstention rows; declined-to-run and ran-and-found-nothing are different facts. The failure direction is silence, never spray. One structural decision at a time, options with costs, Matthew's calls left open.

## How the humans work

**Matthew** rules methodology and grades output (inverted: output first, row by row, blank rows the only channel for misses). **Design** (the session this primer hands to) argues structural decisions before writing, defaults technical calls with both positions recorded, folds every ruling into the documents, verifies every run's export mechanically, and re-stamps the inbox last. **CODE** builds, runs, exports, and reports through the inbox; fresh CODE sessions start by reading the inbox top stamp.

## Where it stands and what is next

People (the relationship-map families) is HELD OPEN behind three gates, in order: the 29 July extraction run (the first measurement on speech nothing was tuned against; fixture taken from the freeze list, never the org), Matthew's coverage grade, and multi-transcript validation needing his production transcripts as files. The scope split has corrected under-calls on both fixtures it has seen. After the gates: People closes and PROBLEMS opens (the insight families: Goal, Pressure, Obstacle, Initiative), charter work design-side first. The Board's seed carries the precise first action at any moment; trust it over this paragraph, which does not update.
