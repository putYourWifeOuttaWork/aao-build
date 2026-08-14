# Proposal · the span-set caps · owed before the span-set build

**This is a PROPOSAL, not a build.** It is the pre-build artifact the twenty-ninth stamp requires
of CODE and the thirty-fifth stamp's item 7(b) names as a next move. Nothing here is implemented;
the span set builds at the accuracy phase, by a design fold, after these caps are chosen or
overruled.

**Authorizing bytes (receipt rule, thirty-fifth stamp item 4).**
- Twenty-ninth stamp, item 1: *"a pair's evidence becomes an ordered SET of one to three verbatim
  spans, each byte-located independently against the frozen artifact, stitched across adjacent
  turns where one idea spans them ... caps proposed by you before build (three spans and a
  character budget are the starting posture) so the set never becomes a context dump that makes
  weak claims look better supported than they are."*
- Thirty-fifth stamp, item 7: *"the span-set caps PROPOSAL, owed before that build by the
  twenty-ninth stamp's own text, three spans and a character budget the starting posture."*

## What the ruling fixes and what it leaves to this proposal

RULED, not open (quoted above and not re-litigated here): the evidence becomes an ORDERED SET of
verbatim spans; each span byte-locates INDEPENDENTLY against the frozen artifact; the set stitches
across adjacent turns where one idea spans them; another speaker's eliciting words may join the set
where the answer's meaning depends on them, MARKED AS ELICITATION, with the establishing speaker
still owning the establishment and the speaker gates still pricing it; call 3 stays blind and
judges exactly the cited set; the added words enter as CITED EVIDENCE, never invisible context.

OPEN, and this proposal's whole job: the two caps and the guards that keep the set the *shortest*
set that carries the idea rather than a context dump.

## Proposed caps

**Cap 1 · span count: MAX 3 spans per pair (the ruling's own starting posture).** One span is the
current shape and stays the common case; two and three exist for the concatenated-idea and the
elicitation cases. Recorded reasons to start here and not higher: the deq1/deq2 acceptance
specimen (the THIN pair graded "NOT ENOUGH CONTEXT TO UNDERSTAND THE CLAIM") needs its naming
sentence plus at most the one adjacent clause that scopes it, which is two; the elicitation case
adds at most one more, the question that makes the answer legible, which is three. A fourth span
has no named use and each additional span multiplies the ways a weak claim looks propped.

**Cap 2 · character budget: a WHOLE-SET budget of 600 characters, not a per-span budget.** The
reason it is whole-set: the hazard the ruling names is the SET becoming a context dump, and a
per-span cap of N would let three spans total 3N and dump anyway. 600 characters is proposed from
the existing single-quote budget: call 1's coextension guidance is ~90 tokens per pair
(`AAO_LocateCharter.EVIDENCE_BUDGET_TOKENS`), roughly 360 characters for one span; a set carrying
one idea across two or three spans should not need more than ~1.7x a single rich quote, because
the spans share the idea rather than adding new ones. 600 is that, rounded to a number a human
reads. A set over budget is REFUSED at the locator with its reason (the pair survives on its
strongest single span, never silently truncated), the same shape as the criterion-name refusal.

**Guard · every span load-bearing, checked mechanically where it can be.** The byte-location
already refuses a span not in the artifact. Two cheap additional guards proposed: a span that is a
substring of another span in the same set is dropped as redundant (it carries nothing the larger
span does not); and a set whose spans do not all share the same Source is refused (spans stitch
within one artifact, never across). Neither judges quality; both are arithmetic.

## The grammar-budget interaction (thirty-fifth stamp condition, load-bearing)

The thirty-fifth stamp ratified the grammar budget with the condition: *"THE CAP IS KEYED TO THE
CURRENT SCHEMA SHAPE. The span set enlarges per-claim grammar when it builds, so the cap
RE-MEASURES at the span-set build before any density conclusion carries forward."*

Concretely: today's `MAX_UNITS_PER_KEYED_CALL = 15` was measured on single-quote pairs (22 passed,
~24 400'd). The span set changes call 1's pair schema (an array of up to 3 spans plus an
elicitation flag per span) AND, downstream, call 3's per-claim input grows with it. **The 15 does
NOT carry forward.** The span-set build MUST re-measure the keyed cap on the new, larger per-claim
grammar and pin a new constant, exactly as the current cap was pinned from h1/i1. Asserting 15
against the span-set schema would be the tuned-behaviour hazard in a new coat, which is the
condition's whole point. This proposal flags it; the re-measurement is part of the span-set build,
not this document.

## What this proposal deliberately does NOT decide

Per the thirty-fifth stamp item 8, three changes to call 3's input shape converge on one surface:
the span set (this), Matthew's confidence-merge direction (same-key claims merged so the verifier
reconciles rather than judging duplicates blind), and the flicker remedy (parked at the stability
probe). The stamp rules the latter two BESIDE the span set's measured result so call 3's shape
changes once, not three times, and no piecemeal change contaminates the downsize comparison
mid-measurement. **This proposal takes no position on the confidence-merge or the flicker remedy;**
it proposes only the span-set caps, so the design fold can weigh all three together. One
interaction is flagged for that fold: a call-3 merge of same-key claims (Matthew's direction) and
a span set both enlarge the cited evidence a single call-3 verdict rests on, so their combined
effect on the whole-set character budget is a thing to measure together, not additively assume.

## Summary of what is proposed for the fold to choose or overrule

| cap / guard | proposed value | refusal behaviour |
|---|---|---|
| span count | max 3 | over-count refused; pair keeps strongest single span |
| character budget | 600, whole-set | over-budget refused; same |
| substring span | dropped as redundant | mechanical, no refusal |
| cross-Source set | refused | spans stitch within one artifact |
| keyed grammar cap | RE-MEASURE at build | today's 15 does not carry forward |
