# The verifier calibration set · specimens, not tuning

**This file records CASES, never guidance.** A specimen lands here when a human reads a verdict on
the live map and says it is wrong. Nothing here edits a charter, a contract's guidance text, or a
prompt: those changes happen at a design fold, deliberately and all at once, so that no single case
gets fitted individually and the tuned-behaviour law is not quietly broken one specimen at a time.

The set opens with the switch to Haiku on call 3 (forty-first stamp, ruling 1). The thirty-seventh
stamp warned that a small verifier's judgments would need adjudication before its rejections were
believed: *"Gated, not trusted: one adjudicated comparison against the strong model is owed before
its rejections are believed."* The forty-first stamp replaced that owed comparison with Matthew's
in-Salesforce review. This file is where that review's findings accumulate.

---

## Specimen 1 · the sentiment hedge read as non-support

**Recorded by:** the forty-fourth stamp, item 2. Matthew's first in-Salesforce review, 11 August.
**Run:** `pf0811-live`, Project Farma, artifact `018cac1b`. **Verifier:** `claude-haiku-4-5-20251001`
at temperature 0. **Person:** Adam Pfeiffer. **Status:** recorded, NOT tuned.

Two sentiment pairs were upheld for one person in one run, in opposite directions.

**Pair `r1q1` · upheld, supportive · correct.**

> reason, verbatim from the wire: *"The words directly assert the speaker's positive stance: 'I like
> that' and 'I like everything we've seen so far' clearly voice support."*
> `carries=true`, `target=US_OR_OUR_SOLUTION`

**Pair `r1q22` · upheld as non-support · THE MISREAD.**

> reason, verbatim from the wire: *"The words express reluctance or deferral ('maybe not reluctant,
> but maybe something we would do in a later implementation'), indicating non-support or at least
> conditional/delayed support."*
> `carries=true`, `target=US_OR_OUR_SOLUTION`

The counter netted +1 and -1 to zero, and Status came out blank on a person whose enthusiasm is on
the record. **Matthew's law, restated for this set: SUPPORT STANDS UNLESS SOMETHING UNSUPPORTIVE IS
SAID, and deferral about implementation scope or timing is not unsupport of the deal.**

Read the verifier's own reason closely, because it is the useful part: it says *"non-support or at
least conditional/delayed support"*, which is the model reporting its own uncertainty and then
resolving it toward non-support anyway. The words it quotes are about WHEN a piece of scope happens,
not about whether the speaker backs the deal. The contract's guidance does not currently tell it that
timing talk is out of scope for this question. **That is the gap, and closing it is the design
fold's, not this file's.**

### What was fixed now, and what deliberately was not

**Fixed, because it is a projection law and not a judgment:** a counted net-zero support counter now
projects **Neutral** rather than blank (Matthew's ruling in the same item; see
`AAO_SupportCounter.rungFor`). Blank is reserved for never-measured. That does not make `r1q22`
right; it makes the map legible when two readings cancel, and it carries both citations.

**Not fixed, on purpose:** the sentiment contract's guidance text. No prompt was edited, no example
added, no threshold moved. The specimen rides to the fold.

### The related non-defect, recorded so it is not rediscovered as one

Matthew's blank Status looked like erasure of a value a previous run had written. It was not. The
projection-side law already holds: nothing overwrites a value with a blank, and a purged surface
recomputes from scratch rather than overwriting. The blank was a fresh computation on a clean
surface, which is why it looked like loss and was not.
