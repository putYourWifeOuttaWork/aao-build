# AAO Machine Read Sheet · v1.1 · 9 August 2026

**v1.1, regenerated at the halving fold per this sheet's own law (shape changed: the rebuild is built and gated, the lanes are ruled). If you graded v1.0, re-grade only the lines marked CHANGED or NEW; section 9's suspect list turned over whole, five answered, five new.**

**What this is.** The machine as it stands today, stated as bare assertions with the arguments stripped off, so Matthew can audit the design against his intent without reading the corpus. Grade it the way you grade a map: **TRUE** if the line matches what you want built, **FALSE** if it does not, **?** if it surprises you. Every FALSE or ? is a finding; hand the line numbers back and design chases each to its stamp, and either the machine gets fixed or this sheet does. The documents carry every ruling WITH its persuasion, which is right for provenance and wrong for auditing intent; this sheet exists because a rule you would reverse at leisure can survive forever inside its own argument.

**The tags.** [code] means deterministic Apex, no model, no judgment. [model] means a model call. [human] means Matthew or a seller. Both defects caught this week were the same class: a model standing where determinism belongs. The tag per line is how the next one of that class gets caught without knowing where to look.

**Status.** Satellite, outside the audit chain. Reflects the twenty-seventh inbox stamp and Board v2.7, meaning the RULED machine including the rebuild now in front of CODE, not the code as it ran this morning. Regenerated whenever the machine's shape changes; on a regeneration you re-grade only the changed lines.

---

## 1 · Intake and normalization

1.1 [code] Every transcript, whatever its raw shape (WebVTT, ECI viewer paste, future formats), is converted by deterministic code into one normalized text form with speaker headers, and that exact byte form is frozen with a hash.
1.2 [code] Every quote the system ever stores must match those frozen bytes exactly at a stated offset, or the pair is discarded and counted as discarded.
1.3 [code] Transcription mistakes are preserved verbatim ("Kalia" for Kayla); the normalizer never corrects them, because a corrected quote is a paraphrase.
1.4 Raw transcripts carrying customer speech are never committed to the code repository and never stored as org static resources; only the normalized fixture and derived rows persist.
1.5 [code] One conversation arriving as several rows or files counts as ONE conversation everywhere that counts conversations.

## 2 · Call 0 · the router · one model call per transcript

2.1 [code] Before any model runs, code determines: who organized the call and whether their role is sales-side or account-side, from an admin-ratified role map.
2.2 [code] Code builds the deal candidate list from opportunities open AT THE TIME THE CALL HAPPENED, never at the run date.
2.3 [code] Code matches participants' emails against contacts and map rows, and classifies internal versus external by email domain.
2.4 [model] One model call reads the whole transcript and answers two independent yes-or-no questions, each with a quote: does this call carry opportunity content; does it carry account content. Both yes means dual.
2.5 [model] The same call picks which opportunity from the closed candidate list, or says NONE or AMBIGUOUS, and returns the people roster with IDs attached, including load-bearing mentioned people.
2.6 [code] A call resolving to no deal dispatches nothing and logs why with its quote. Nothing is written from it.
2.7 [code] Only the opportunity side dispatches today; account verdicts log and park (the account grain is deliberately backburnered, not forgotten).
2.8 Call 0 routes and resolves people. It never establishes anything, and nothing downstream can re-open its scope decision mid-pass. Its resolution half is a callable service that call 2 reuses.

## 3 · Call 1 · the reader · two model calls per transcript

3.1 [model] TWO comprehensive reads of the whole transcript, each carrying EVERY declared question family in one prompt. Not one read, not one per family.
3.2 Each read pulls question-answer pairs: the question, the exact words, the meaning those words voice, and, where the words are about someone other than the speaker, the name or title as spoken plus the sentence that introduced that person. No org identity is attached to anything.
3.3 Two reads because inference drops things; the second read exists to catch what the first missed, and their differences add rather than argue.
3.4 [code] The two reads' outputs are unioned by code: same question, overlapping bytes, same meaning is one establishment carrying both receipts. Quotes are never string-compared, because the two reads will quote the same moment with different boundaries.
3.5 A pair only one read found still stands. Corroboration is a confidence marker, never a gate.
3.6 Demo narration, war stories, and pleasantries produce nothing. The correct output on a stretch that establishes nothing is nothing.
3.7 A criteria pair carries the criterion's NAME: a descriptive word or words stating the condition that must be true for them to make the positive decision, taken from their words.
3.8 [code] The read count never depends on how many people were on the call. The reads may run in parallel.

## 4 · Call 2 · the resolution stage · zero to two model calls per transcript

4.1 [code] Who SPOKE each pair is attached by code, free: the quote's byte position names the turn, the turn names the speaker, and call 0 already resolved that speaker to an ID. No model touches this.
4.2 [code] A pair about its own speaker (the default case) is fully resolved at 4.1.
4.3 [code] A pair naming someone else ("Jefferson will sign") is matched by code against the roster, the map, and existing contacts, including a title lookup through a fixed synonym list. Exactly one match links.
4.4 [model] Only the leftovers reach a model: people mentioned who are not on the call, titles with no name, speakers with no contact record, antecedents code cannot place. One bounded call describes each unresolved person in TYPED FIELDS: what kind of gap, the words as written, the introducing quote, the org side. It never writes query text.
4.5 [code] Code composes and runs every query from those typed fields. The model never queries anything.
4.6 [model] One more bounded call is permitted only to separate multiple returned candidates using context. NONE and AMBIGUOUS stay honest answers.
4.7 Nothing is ever guessed: zero matches is held with its evidence and a flag, two matches is held and flagged, and a title can link a person but can never create one.
4.8 [code] Creating a contact happens only when no match exists anywhere, and every machine-created contact lands in a ledger, so "what did the machine put in this org" is always answerable. Dan Lewis is that ledger's first entry, back-filled.
4.9 Resolution attaches SUBJECTS, never speakers: on a note, the author stays the only speaker forever, and a resolved mention becomes what the pair is about, priced by the same speaker rules as always.
4.10 On notes and emails this stage becomes the main path (nearly every named person needs it); on transcripts it usually does almost nothing.

## 5 · Call 3 · the checker · one to two batched model calls per transcript

5.1 [model] A separate model sees ONE claim and its quote, nothing else: not who said it, not the map, not what any other call concluded. It says whether the words carry the claim.
5.2 CHANGED [model] It runs on every surviving pair in CONJUNCT-HOMOGENEOUS buckets (sentiment claims carry the target conjunct and batch alone; everything else batches together), the buckets run in PARALLEL, and a bucket that would cross 90 seconds drives as concurrent shards. Proven at h1: 52.5 s sequential became 20.8 s parallel.
5.3 A sentiment claim must aim at us or our solution; warmth about the meeting or the occasion is refused by construction, not by judgment.
5.4 Call 3 never attributes, never sees placements, never reads the transcript.
5.5 NEW (ruled, builds at the accuracy phase) A pair's evidence becomes a SPAN SET: one to three verbatim byte-located spans stitched across adjacent turns, the eliciting question included and marked, entering as CITED EVIDENCE never invisible context, so call 3 stops judging fragments and the receipt never lies to an auditor.

## 6 · After the models · all code

6.1 [code] Speaker-rank rules price the evidence: a seller's words never establish what only a buyer can confirm.
6.2 [code] The internal gate: our own people can never land on a customer's buying committee, by construction.
6.3 [code] Criteria project only when whole; partial evidence accrues with receipts, places nobody, and never displaces anything stronger.
6.4 [code] Claims are never edited or deleted. A wrong claim retires in place with its reason; retiring it retracts whatever map value it carried.
6.5 [code] Replaying the claims in evidence order reconstructs every answer exactly. That is the standing correctness test.
6.6 [code] Every graded trap (courtesy as support, the demo-narration people) is a standing assertion checked on every run.

## 7 · Projection · the map

7.1 [code] Values land on Altify's own map objects carrying our watermark per dimension.
7.2 [human] A human edit beats the machine forever on that dimension. No timer, no expiry, no exceptions.
7.3 Every value on the map walks back to a claim, its verbatim quote, and its byte offset, through the Evidence quicklink, in product.
7.4 [code] The sentiment counter moves one step per verified establishment, clamped at plus or minus three, and words can never carry someone past the strongest state they actually voice.
7.5 No dismiss button exists anywhere. Flags clear when their cause does.
7.6 [code] Nothing decays on a timer; staleness is displayed, never enforced.
7.7 [code] Coverage is a trailing 90-day count of conversations, computed, never read from words.

## 8 · The cost of one transcript, as measured

8.1 CHANGED Clean small call, everyone has a contact: FOUR model calls (call 0, two reads, one verify bucket). Project Farma's real shape ran at SIX (one resolution leg, two verify buckets). Measured, not projected.
8.2 CHANGED The measured walls on the 73-minute production transcript: ~105 s cold serial-verify (tg1), **~57 s cold with verify parallel and call 0 hidden (h1)**; the 50 s stretch is one driven shard away. Worst single callout 27 s against the 90 s ceiling.
8.3 Calls grow with unresolved people and claim volume, never with headcount.
8.4 NEW **The two lanes are dispatcher config, not design.** BATCH (nightly window): serial, call 0 gates dispatch first, reads reuse the cached artifact (~88% of read input at ~10% price); the token bill is what matters at 10k/day and the cost model prices this lane. EXPRESS (seller-facing): the parallel graph, ≤60 s; the scope verdict gates pair ADMISSION instead of read launch, and speculative read tokens are the lane's stated premium.
8.5 Notes and emails will spend their calls in resolution, not reading, and their passes run in seconds because wall scales with artifact length.
8.6 NEW Any stage crossing 90 seconds completes its REMAINING work in a continuation call, never redoes, never retries bigger. Built; never fired yet.

## 9 · Design's suspect list · v1.1, turned over whole · pre-graded questions, not findings

9.1 **THE FLICKER.** The same shape produced different maps on identical bytes across reruns: 44 pairs then 41; Adam at Political Structure plus Evaluator, then Inner Circle with a held buyer-role collision. A single run's map is one draw, not the truth, until the stability probe (three identical runs, mechanical diff) says otherwise. This is the sheet's biggest open question and the accuracy phase's first subject.
9.2 **THE BUYER-ROLE COLLISION, yours.** Two roles both verified on one person; the vendor field holds one; today the writer holds the field and writes a refusal note. Recency, an authored precedence ladder, or hold-plus-flag: a methodology call only you can make.
9.3 **The batch lane's token number is unmeasured.** The cache economics were proven in a probe, not in a full batch-lane run; the cost model re-derivation prices the real per-transcript dollar figure. Until then, 10k/day economics are arithmetic, not measurement.
9.4 **The express lane's admission-drop is ruled but unbuilt.** Until the lane flag and drop-unpersisted semantics exist, an express run on a non-deal artifact would persist pairs it should discard. Bounded today because only fixtures run; binds before any automated funnel.
9.5 **Call 3 still rides the strong model.** The downsize comparison (smallest model that passes adjudication) has not run; both the dollars and the sub-50 wall wait on it, and it is the accuracy phase's cheapest big lever.

---

**How to return this:** line numbers with FALSE or ?, in any form, voice included. Design chases each to its stamp and reports back: either the machine diverges from your intent and gets a correction routed through the stamped order, or the sheet misstated the machine and the sheet corrects. Wrong lines get marked, never deleted.
