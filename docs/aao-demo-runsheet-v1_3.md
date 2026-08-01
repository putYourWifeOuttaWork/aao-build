# AAO Demo Run Sheet — live run first

> **The version lives on the stamp line below and nowhere else.**

**v1.3 · 2 August 2026 · org `altify--aossb2` · audience: Toby · the say-unprompted section is corrected, and three of its five lines were false**

**Changed in v1.3. Recovered rather than rewritten.** This document was listed as live from seed v3.0 onward, was not found in project knowledge at any version, and was struck in seed v5.1 as possibly never having existed. **It exists.** CODE holds it at `docs/aao-demo-runsheet-v1_2.md`, 58 lines, committed at `c4d1ba2` in session 16, unmodified since. **It was in the repo and never in the project**, which is a one-way drift the handoff loop is supposed to make impossible, and it is recorded in corrections rather than passed over.

**What changed in the text: three of the five say-unprompted lines were true on 1 August and are false now**, and a demo sheet whose honest-disclosure section understates what has been built is a worse defect than one that overstates it, because it is the section the audience trusts most. **The model slots are no longer stubbed** — Gate 1 round two ran and extraction 1.1.0 and the blind reader 1.0.0 are live. **Discovery is wired** — contracts derive from the ALTF rubric tables with supersede on hash change. **The rubric tables are no longer empty** — they were authored and read from in session 12.

**One disclosure is added and it replaces what those three were doing.** A say-unprompted section exists to put the real current limitation in front of Toby before he finds it, so removing three stale limitations without naming the live one would leave the section performing honesty rather than doing it. The live one is that **the guided-question labels are unreachable from Apex.** That fact holds whichever way the sourcing decision goes, so it is safe to state now; **what we do about it is open and the line says so.**

**The demo's spine is untouched and was all still accurate:** day-one red, two transactions, the negative deal, replay.

**Changed in v1.2.** Day-one red is live, so the demo opens on a deal that is empty AND owes answers: two reds standing before any evidence, the count dropping only when TRUE is established, and the seller-said-it deal holding both reds at full coverage. The empty-Flag-tab line is retired; flags-do-not-age-yet takes its slot.

**Changed in v1.1.** The demo now opens live: evidence ingested on screen, adjudicated asynchronously by the trigger-fired Queueable, the answer flipping in front of him. The pre-seeded deals become the deep-dive and the backup. One trap and one gift added: the live deal must be reset before the meeting, and the async wait is a talking point, not dead air.

## Before the meeting, ten minutes

- **Reset the live deal.** It already ran once, so it currently shows TRUE. Have CODE purge and reseed, then confirm status reads: Tungsten Rehearsal TRUE, seller-said-it UNVERIFIED, **AAO Demo - Live empty**.
- Stage the two ingest one-liners in a terminal so each pass is a single keystroke in the meeting.
- Open the org on the AAO Demo - Live Opportunity, logged in as yourself, and confirm the AAO related lists are visible.
- Keep this sheet open beside the browser.

**The frame, 20 seconds.** A verification layer that reads evidence and maintains, per deal, which necessary conditions are actually true. It never predicts and never scores. Everything it writes traces to words a specific person said, and the current truth is rebuildable from receipts alone.

## Act one — the live run

**1 · The "empty" deal that already owes answers.** AAO Demo - Live: no sources, no claims, no answers — **and two red flags standing.**
*Say:* nobody raised these. They were never down. Every do-or-die question stands red from the day a deal opens, because a necessary condition that hasn't been met is not met. The ceiling is set on day one and the only direction is down. And note Raised-At: it's the deal's creation date, so a flag's age means how long the deal has stood unanswered, not how long since the software noticed.

**2 · Fire ingest one.** The transcript row appears immediately; the verdict does not.
*Say, while the job runs:* the arrival and the adjudication are deliberately two transactions. The artifact lands first and is judged second, so no governor limit, no defect of ours, can ever roll back the arrival of evidence. The status line reads PENDING while sources outnumber claims; wait for Completed before the next pass.

**3 · Refresh.** Answer: UNVERIFIED. One claim, null to UNVERIFIED, with its quotes. **Both reds still standing.**
*Say:* the first call partly answered the question, and that partial truth was recorded honestly with its receipts. Two of three parts covered; the missing part is named. And the flag count didn't move, because partial evidence establishes nothing. Work happened, truth accumulated, and the deal is still not safe. Those are different facts and the system refuses to blur them.

**4 · Fire ingest two, refresh.** Answer: TRUE. Second claim, UNVERIFIED to TRUE. The first claim untouched. **One red clears, on screen, and the flag records what cleared it.**
*Say:* incrementalism, live. Nothing was overwritten; progress is visible instead of destroyed. Evidence is the only thing that ever lowers the count — no dismiss button exists anywhere in this system. And the two clocks: recorded-at is a minute apart because you just watched it, evidence-occurred is eleven days apart because the transcripts say so. That's what makes backfilling history possible without collapsing it onto today.

## Act two — the deep dive, on any of the three deals

**5 · A claim's spans, then the Source.** Verbatim quotes, byte-checked against the frozen transcript.
*Say:* checked byte for byte. A buyer's yes carries the seller's question that produced it, because the yes means nothing alone. Machine annotations were stripped before storage and the strip is recorded.

**6 · The Candidate ledger.** Every proposition considered got a row, including nothing-said rows.
*Say:* it logs what it looked at, not just what it found. Abstention is measurable, and did it even look is answerable.

**7 · The negative deal.** Same budget words, full coverage, spoken by the seller: UNVERIFIED, outcome Downgraded, **and both reds still standing.**
*Say:* all three parts were said, coverage is complete, and nothing was established, because the seller said them. The flags don't care how much was said; they care who established what. Who may establish what is enforced by the schema, not by prompt discipline.

**R · The closer, replay.** All three deals: replaying the claims in evidence order rebuilds every answer exactly, checked in the org.
*Say:* the current truth is derived from receipts, never typed in. That is the property everything else is built on, and it is in git.

## Say unprompted, before he asks

*Corrected in v1.3. The first three lines below replace three that were true on 1 August and false by 2 August; the fourth is new and is the live limitation.*

- **The models are live and they are held to Gate 1's bar.** Extraction 1.1.0 and the blind reader 1.0.0 both run, pinned in Model Config, and round two came back twelve of twelve on outcomes and eleven of twelve on proposals against staged truth, with **zero hallucinated spans in any run.** The span check is what makes that last number a property of the system rather than a result. *(v1.2 said the slots were stubbed and no model had read anything. True on 1 August, false now.)*
- **Discovery is wired.** Contracts derive from Altify's own rubric tables at runtime, and a question edited in place is caught by content hash and supersedes rather than overwrites. *(v1.2 said discovery was not wired and reading from the tables was next. It has since happened.)*
- **The sandbox's rubric tables were empty and are not any more** — they were authored and read from in session 12, which is what made the per-org discovery path a real test rather than a described one. *(v1.2 offered the empty tables as the customer condition. The empty state was the point and it has been exercised; say it that way round.)*
- **The guided questions are not readable from Apex, and that is the open one.** Altify decomposed the map dimensions into authored question sets years ago and ships them as custom labels — nine for Support, seven for Political Status, three for Coverage. **2,576 of the 2,930 ALTF labels are protected**, including every guided question, and `ExternalString` is a Tooling object Apex SOQL cannot see. So the ontology is real, it is enumerated, and **discovery cannot reach it at runtime from inside the org.** The assembler is built with the seam in the right place, so this is a sourcing decision rather than an architectural one, and it is **not yet ruled.** Say it before he asks; he will ask.
- **Projection into Altify's objects is a later phase.** Their tables are untouched.
- **Flags don't age yet.** Standing and clearing are live; urgency is not. The escalation threshold sits on the contract and nothing reads it, deliberately, because escalation's denominator is Altify's derived close date, which doesn't exist until Altify is configured on the deal. A red stands at the same weight however old it is, for now.
- **The sandbox handed us a specimen:** its own pre-existing test fails on a customer validation rule, the write-blocking-constraint problem already on our list, alive in the target org.

**Plan B.** If the live job queues slowly, do not wait on stage: switch to Tungsten Rehearsal, which shows the identical result already landed, and let the live deal complete in the background.

## One sentence to leave with

You just watched evidence arrive and truth accumulate, asynchronously, on the platform's own machinery, with every word traceable and the whole state rebuildable from receipts.

---

*End v1.3. The spine is unchanged from v1.2 and was accurate throughout. Only the say-unprompted section moved, and it moved because the build did.*
