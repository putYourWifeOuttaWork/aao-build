# AAO Demo Run Sheet — live run first

**v1.1 · 31 July 2026 · org `altify--aossb2` · audience: Toby**

**Changed in v1.1.** The demo now opens live: evidence ingested on screen, adjudicated asynchronously by the trigger-fired Queueable, the answer flipping in front of him. The pre-seeded deals become the deep-dive and the backup. One trap and one gift added: the live deal must be reset before the meeting, and the async wait is a talking point, not dead air.

## Before the meeting, ten minutes

- **Reset the live deal.** It already ran once, so it currently shows TRUE. Have CODE purge and reseed, then confirm status reads: Tungsten Rehearsal TRUE, seller-said-it UNVERIFIED, **AAO Demo - Live empty**.
- Stage the two ingest one-liners in a terminal so each pass is a single keystroke in the meeting.
- Open the org on the AAO Demo - Live Opportunity, logged in as yourself, and confirm the AAO related lists are visible.
- Keep this sheet open beside the browser.

**The frame, 20 seconds.** A verification layer that reads evidence and maintains, per deal, which necessary conditions are actually true. It never predicts and never scores. Everything it writes traces to words a specific person said, and the current truth is rebuildable from receipts alone.

## Act one — the live run

**1 · The empty deal.** AAO Demo - Live: no answers, no claims, no sources.
*Say:* a bare standard Opportunity. Nothing here touches an Altify object or a customer save path.

**2 · Fire ingest one.** The transcript row appears immediately; the verdict does not.
*Say, while the job runs:* the arrival and the adjudication are deliberately two transactions. The artifact lands first and is judged second, so no governor limit, no defect of ours, can ever roll back the arrival of evidence. The status line reads PENDING while sources outnumber claims; wait for Completed before the next pass.

**3 · Refresh.** Answer: UNVERIFIED. One claim, null to UNVERIFIED, with its quotes.
*Say:* the first call partly answered the question, and that partial truth was recorded honestly with its receipts. Two of three parts covered; the missing part is named in the coverage field.

**4 · Fire ingest two, refresh.** Answer: TRUE. Second claim, UNVERIFIED to TRUE. The first claim untouched.
*Say:* incrementalism, live. Nothing was overwritten; progress is visible instead of destroyed. And the two clocks: recorded-at is a minute apart because you just watched it, evidence-occurred is eleven days apart because the transcripts say so. The truth remembers when things were said, not when we read them, which is what makes backfilling history possible without collapsing it onto today.

## Act two — the deep dive, on any of the three deals

**5 · A claim's spans, then the Source.** Verbatim quotes, byte-checked against the frozen transcript.
*Say:* checked byte for byte. A buyer's yes carries the seller's question that produced it, because the yes means nothing alone. Machine annotations were stripped before storage and the strip is recorded.

**6 · The Candidate ledger.** Every proposition considered got a row, including nothing-said rows.
*Say:* it logs what it looked at, not just what it found. Abstention is measurable, and did it even look is answerable.

**7 · The negative deal.** Same budget words, full coverage, spoken by the seller: UNVERIFIED, outcome Downgraded.
*Say:* all three parts were said and it still does not establish, because the seller said them. Who may establish what is enforced by the schema, not by prompt discipline.

**R · The closer, replay.** All three deals: replaying the claims in evidence order rebuilds every answer exactly, checked in the org.
*Say:* the current truth is derived from receipts, never typed in. That is the property everything else is built on, and it is in git.

## Say unprompted, before he asks

- **The model slots are stubbed.** The extraction proposals were authored and staged by artifact hash; no model has read anything. Everything you just watched, the trigger, the queue, verification, commit, accumulation, replay, is the shipping code path those model outputs will land on. Charters stay behind Gate 1's bar until round two clears.
- **Discovery is not wired yet.** The six questions were seeded into our contract object. Altify's own rubric tables exist in this sandbox and are empty, which is exactly the customer condition, and reading from them is next.
- **Projection into Altify's objects is a later phase.** Their tables are untouched.
- **If he clicks the Flag tab, it is empty:** nothing raises flags yet. When the raise machinery lands, every gating proposition stands red from the day the deal opens and evidence is the only thing that lowers the count.
- **The sandbox handed us a specimen:** its own pre-existing test fails on a customer validation rule, the write-blocking-constraint problem already on our list, alive in the target org.

**Plan B.** If the live job queues slowly, do not wait on stage: switch to Tungsten Rehearsal, which shows the identical result already landed, and let the live deal complete in the background.

## One sentence to leave with

You just watched evidence arrive and truth accumulate, asynchronously, on the platform's own machinery, with every word traceable and the whole state rebuildable from receipts.
