# Run `pf0808-tg1` · the rebuilt pipeline's first pass, and the timing gate's report

The twenty-seventh stamp's rebuild, run end to end on frozen Project Farma after the
twenty-eighth stamp's purge, graded against the twenty-ninth stamp's targets. **TIME ONLY; no
accuracy claims. [timings.md](timings.md) is the gate report.** The headline: **~105 s in-org
COLD, 6 model calls, worst callout 31.8 s, the deterministic resolution at 234 ms replacing
what was 59 callouts.** Under the 120-second fail line, above the 60-90 acceptable band, and
the single largest remaining cost (52 s of sequential verify batches) parallelizes the same way
the reads already do.

## What was built, in the order the stamps ruled it

1. **THE CRITERIA FIX (first).** Call 1 emits `criterion_name` (the condition that must be true
   for the positive decision, "Annual total cost" the specimen shape); minting keys on
   opportunity plus name; the vendor Subject displays the name; criterion claims carry the
   voicer's Subject Contact so they are reachable from the person's evidence list (the
   null-Subject defect); the collapsed CR rows retired with reasons, never deleted, and a
   retired criterion can neither re-mint nor project. **Live proof on the map this run:
   "Competitive pricing within budget".**
2. **CALL 1 = TWO COMPREHENSIVE READS** (`AAO_Pass.locateRead`, refs `r1*`/`r2*`), all declared
   families in one prompt, run in parallel (31 s + 32 s = 33 s wall). The designator rides the
   read: `about` + `about_quote` (required, empty-string default per the coverage lesson), the
   introducing quote byte-checked at location, dropped with a note where it fails. The
   blank-retry guard is retired at this shape per the twenty-eighth stamp.
3. **CALL 2 = THE RESOLUTION STAGE** (`AAO_Resolve`), identification deleted as a model job:
   - the merge: contract + byte-range intersection + same meaning (+ agreeing designators,
     design's recorded addition), absorbed rows take a `Merged` disposition, canonicals mark
     `Corroborated`, the conservative-coverage row is the canonical so no located row is edited.
     This run: 14 of 44 merged.
   - speaker attach as a byte lookup: 28 pairs, 0 model calls, 234 ms.
   - designators: roster first, then the deterministic ladder (title rung included; kind
     detection fixed en route - `canonicalTitle` normalizes anything, so a real `isKnownTitle`
     predicate now decides TITLE vs NAME). LINKED mints a mention Participant (`mention:` roster
     key, excluded from coverage: presence establishes coverage and a mention is not presence).
   - **the model leg** (`AAO_ResolveRequestCharter`): one bounded call for the remainder, TYPED
     RESOLUTION REQUESTS only, Apex composes every query. Completeness is structural: the
     requests come back keyed by designator handle with every handle a REQUIRED property, so an
     omission fails schema validation instead of parsing short. This run: 2 designators, 5.5 s -
     Rich minted toward creation, one held None.
   - **creation never happens at resolution.** The creating leg stays at projection, behind
     call 3's verify, the toggle, and now the create-leg record - which is also what keeps the
     demo-narration trap's fictional people structurally off the Contact table.
4. **CALL 3 KEYED BATCHES** (`schemaKeyed`): verdicts as an object whose required properties are
   the claim refs - omission and mis-referencing unexpressible at any batch size, the structural
   completeness `minItems` could not provide. 29 claims in 2 calls where the old shape needed 29.
5. **THE CREATE-LEG RECORD** (`AAO_Created_Row__c` + `AAO_CreatedRows`), wired into
   `AAO_Identity`'s creating rung. Dan Lewis back-filled as MK-00000000; his re-creation this
   run was caught live as MK-00000001. A machine-created row we cannot enumerate is a row we can
   never disown, and the enumeration now exists and works.
6. **THE PURGE PROTOCOL** (`AAO_Purge`, twenty-eighth stamp): deletes only what is enumerable as
   ours, behind a human-watermark guard that aborts whole on any map value our watermarks do not
   claim. First use: 3 map rows, 1 Contact (Dan, via the record), 15 claims, 15 candidates, 12
   answers, 118 pairs, 3 coverage watermarks cleared; the retired criterion, the Source, its
   participants, every seed, and the record itself kept.
7. **CALL 0 SLIMMED** (twenty-eighth stamp): the mentions emission cut from schema, prompt, and
   parse; `resolve-1.1.0`.

## The run, stage by stage

| stage | result |
|---|---|
| purge | 3 map rows, 1 contact, 15+15+12 claim-chain rows, 118 pairs; guard passed |
| call 0 | attempt 1 (COLD) REFUSED by the quote law - yes with no quote; attempt 2: OPPORTUNITY → the PF deal, 6.7 s |
| read A / read B | 20 + 24 pairs located, 0 discards, parallel, 33 s wall |
| resolution | 44 read: 14 merged, 28 speaker-attached, 2 remainder; 234 ms, zero model calls |
| model leg | 2 designators typed: Rich → subject minted (no Contact), 1 held None; 5.5 s |
| verify | 29 claims, 2 keyed batches, 17 upheld / 12 refused, 52 s |
| ledger | 44 located / 44 disposed / 29 verdicts - **HELD** |
| join | 17 claims, 17 answers, 2 counters, **2 named criteria minted**, 0 trapped, 0 seller-subject |
| projection | 3 map rows, 1 criterion projected BY NAME, 1 held Partial, Dan re-created and recorded, Rich correctly nothing |

**Bytes: 44/44 exact; designator quotes 3/3. Demo-narration trap: 0 fictional designators, 0
fictional map rows.** Regression: all N/A (Emerson/BV-keyed seed), reports-only under the freeze.

## Named findings, for the record

1. **Call 0's cold attempt failed the quote law** (yes with no words) and the charter threw
   rather than accept it - honest, but it cost a retry and it is the first observed instance on
   the slimmed schema. Watch: if it repeats, it is a behaviour of the slim, not chance.
2. **The two-read shape located 44 pairs where the sweep located 59.** Fourteen corroborated,
   thirty single-read. Whether the missing 15 are sweep over-reads or two-read misses is
   precisely the accuracy rerun's question; the gate does not answer it and does not pretend to.
3. **Merged dispositions count in the ledger's "None or Ambiguous" bucket.** The arithmetic
   holds (44 = 44) but the label under-describes; a `merged` line in `AAO_PairLedger.Counts` is
   a small honest improvement, deferred under the freeze.
4. **The verify batches are the remaining cost** (52 of ~105 s) and they are embarrassingly
   parallel, exactly like the reads. ~79 s end-to-end is one mechanical change away; under 60
   plausibly needs the two reads' prompt caching (cache_read was 0 - the prefix reorder is
   still queued) or a smaller verify prompt.
5. **Eyeball differences from pf0808-p1** (not graded, recorded for the accuracy rerun): Adam
   Evaluator here vs Decision Maker there; Dan Supporter here vs Non-Supporter there; Adam
   gains Political Structure. Same fixture, different read shapes, different maps - this is
   what the accuracy rerun exists to adjudicate.

## Files

| file | rows |
|---|---|
| `pairs-located.csv` | 44 |
| `pairs-dispositions.csv` | 44 |
| `claims.csv` | 17 |
| `answers.csv` | 13 |
| `projection.csv` | 3 |
| `timings.md` | the gate report |
