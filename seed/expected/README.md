# Expected outcomes — ground truth by construction

Asserted by `AAO_AccumulationTest`. This file is the prose; the test is the authority.

## After transcript one

- Coverage: `e1` and `e2` covered, `e3` not.
- Partial coverage, so the answer is written **`UNVERIFIED`**, carrying the spans that exist.
- One claim. Verdict before `null`, verdict after `UNVERIFIED`, basis `Transcript`, actor
  `MACHINE`, outcome `Established`.
- Dana is the mapped decision maker, so the speaker requirement is satisfied. **The same
  words from Priya would have failed it** — see the negative case.

## After transcript two

- `e3` now covered, so coverage is complete and the answer flips to **`TRUE`**, carrying
  spans from **both** sources.
- A second claim. Verdict before `UNVERIFIED`, verdict after `TRUE`, its own singular
  `AAO_Source__c` lookup pointing at transcript two.
- **The first claim still reads `UNVERIFIED` and is untouched.**

## The exit test, precisely

1. Two claims exist, ordered by `AAO_Evidence_Occurred__c`, eleven days apart. **Not by
   processing time** — both are committed inside one transaction, so a test that passed on
   processing order would pass for the wrong reason.
2. The first claim still reads `UNVERIFIED`. Nothing edited it. This is what makes progress
   visible.
3. The answer reads `TRUE` and its accumulated spans include quotes from both sources
   (five spans: two from transcript one, three from transcript two).
4. Every span byte-verifies against its own Source's normalized text, and every span is
   contiguous inside a single speaker turn.
5. Replaying claims in evidence-occurred order reconstructs the answer exactly. Rebuilt
   from an empty in-memory mirror, compared field for field on
   `AAO_Accumulate.REPLAY_GOVERNED`.
6. The candidate ledger is complete: twelve rows, six propositions on each of two passes,
   ten of them `Abstained` carrying `nobody_said`.

Passing this demonstrates incrementalism in an org rather than in an argument.

### What replay is deliberately not answerable for

`AAO_Projected_Value__c` and `AAO_Projected_Modstamp__c` are excluded from the comparison.
The field table says in terms that the modstamp is captured at the instant of our write and
**cannot be reconstructed later**: a timestamp that moved while the value did not is a
human confirmation, and it is the only evidence of one that exists. `AAO_Publication_State__c`
is excluded because ratification writes it, not evidence.

## Also run, cheaply

**The negative case.** The same words as transcript two, spoken by Priya instead of Dana.
The speaker requirement fails, so it writes `UNVERIFIED` **with receipts** rather than
`TRUE` — three spans are carried, because what failed is who said the words, not whether
they were said. Claim outcome `Downgraded`; candidate outcome `Downgraded_Speaker_Rank`.
This is the ruling that regraded Gate 1 run two.

**The unsegmented artifact.** Stored with `Diarization = Unsegmented` and no roster. Its
span verifies as a contiguous substring of the whole document, and it cannot satisfy the
speaker requirement on `AAO_T1` at all, so it writes `UNVERIFIED`. Otherwise we only ever
prove the easy class.

## Status

**Observed.** Every expectation above has been run against `altify--aossb2` and holds.
Superseded: this section previously read *"Authored, not observed — nothing in this file has
been run against `altify--aossb2`"*, which was true when written on 30 July and stopped
being true on 31 July. See `BUILD_JOURNAL.md` sessions 2 and 3 for the org output, quoted.

---

## The live path — same pipeline, different entry

`AAO Demo - Live` is seeded empty. Evidence arrives on it one artifact at a time, and
nothing else is done by hand:

```
AAO_Live.ingestOne();   // insert transcript one, and stop
AAO_Live.status();      // a moment later
AAO_Live.ingestTwo();
```

`AAO_Live.ingest` inserts an `AAO_Source__c` and returns. The after-insert trigger enqueues
`AAO_IngestQueueable`, which calls **the same `AAO_Pipeline.runForSource`** the durable
rehearsal calls. The rehearsal runs it inline and in order because a demonstration of
accumulation has to be deterministic about which transcript landed first; the live deal runs
it asynchronously because that is what happens when evidence actually arrives.

**Expected:** transcript one lands `UNVERIFIED` with `missing:["e3"]`, asynchronously.
Transcript two flips it to `TRUE`. The first claim is untouched. Replay is still exact.

**The assertion that matters** is in `AAO_LiveIngestTest`, before `Test.stopTest()`: zero
claims exist in the transaction that inserted the Source. Without that assertion the tests
would pass identically if the pipeline ran inline, and the claim about the live path would be
unproven.

**What a Source with nothing staged for it does:** nothing, and it says so
(`status = 'no_staged_proposal'`). Until a charter runs, an artifact only becomes a claim if
a proposal was authored for it. That is the honest shape of the gap, not an error.

## What executed and what was fixture-supplied

The stage-by-stage inventory is in `BUILD_JOURNAL.md`, session 4. Read it before describing
this build to anyone. The short version: everything deterministic ran, and everything a model
would have written was authored in `AAO_Seed.json` and looked up by artifact hash.
