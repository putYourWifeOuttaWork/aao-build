# The card-face shard, and the metric-oriented face · v0.1 item 3(b)

The hundred-fourth stamp's item 3(b). Tree `/Users/thefinalmachine/Downloads/claude` on `main`,
org `00DWD00000DV7iT2AT`.

## What was built

**`keyedShardCount` now drives the card-face call**, at the ratified cap of 15 units. It was the
last keyed strict schema still handing the gateway everything at once, which is what the
thirty-fifth stamp already ruled against on the reasoning that the grammar ceiling belongs to
*every* keyed schema, not to verify.

**A shard that fails now loses only its own faces and names its index.** All-or-nothing was the
previous behaviour and it is strictly worse: twenty-nine cards went blunt because one call was too
large.

**Rule 3b, the metric-oriented face**, and **rule 3c**, which the first pass proved necessary.
`VERSION` moved `cardface-1.0.0` → `1.1.0` → `1.1.1`; sharding alone would not have moved it, the
guidance change is what does.

## The result · no 400, and the numbers are on the faces

```
cards: 29 created, 0 reinforced, 0 unchanged, 0 contradictions flagged
links: 29 written, 0 held · owner links 30 · duplicates retired 0
```

**No `Card faces not inferred` warning on any shard.** The grammar 400 is gone.

**17 of 29 faces carry a measurable**, against a handful before:

| | |
|---|---|
| Goal | `Solve 9 hrs/week prior work search` · `3 associates on camera: precedent in 90 sec` · `Design around chokepoint now, not in 18 months` |
| Pressure | `$95k credits year 1 only if convert by Jan 28` · `$740/year vs existing tool in budget` |
| Initiative | `150 seats live, 2 coverage groups` · `6-week time & motion study, 2 groups` · `Sampled 40 deals vs library holdings` |
| Obstacle | `9 hrs/week hunting prior work` · `Enterprise agreement: 4-6 weeks risk review` · `Release notes 10 days late` · `~20% archive outside Documentum, skews recent` |

Against the fallback verbatim these replaced — *"Three years ago we put in a platform that could
not produce a chain of custody when compliance came asking, and I spent a quarter of my year on
it."* — that is the ninety-ninth stamp's grade answered on the surface it was made about.

## MY OWN DEFECT, IN THE FIRST PASS, AND ITS REPAIR

**1.1.0 said the number should be "spelled as they said it". On its first real board that spent
twenty of the sixty characters on "ninety five thousand", and FIVE OF TWENTY-NINE FACES CAME BACK
CUT MID-THOUGHT**, ending on "for", "by", "does not", "plus":

```
CUT(59): Named executive per model, quarterly attestation; Priya for
CUT(59): Nine hours a week hunting prior work; search layer does not
CUT(56): Ninety five thousand credits year one only if convert by
CUT(56): Measured spring: two groups, six weeks, self-report plus
CUT(55): Fifth of archive in departmental store; largest drag on
```

**That is the unreadable-title class Matthew graded, reintroduced by the rule written to cure it.**

The repair, 1.1.1: **write the number as DIGITS** — `$95k` spends four characters where `ninety
five thousand` spends twenty, and the verbatim on the card already carries how they said it, so
nothing is lost. Digits are a shorter spelling of their number, never a different one, and rule 2
still forbids deriving, rounding, converting or totalling. Plus **3c**, which states the failure
directly: the face ends on a whole thought.

**Re-measured after: 0 cut mid-thought, and measurables rose 15 → 17.** One correction, one rerun.

## WHAT I CANNOT REPORT AS VERIFIED · the dedup half

The stamp says the shard restores inferred faces **and card dedup's reach**. **The first half is
measured. The second is not, and this rebuild structurally could not measure it.**

`AAO_Cards.run` scopes its pair query by **opportunity**, not by run key — the same fact that
caused the duplicate-ref 400. So the first invocation wrote all 29 cards and the s4 and s5 calls
found nothing new (`0 created, 29 unchanged`). **Every card was compared against an empty board,
so layer 2 had nothing to dedup against and could not fire.** Card counts before and after are
both 29, and that equality is an artifact of the method, not evidence either way.

**And the board visibly carries same-meaning pairs that layer 2 would be expected to catch:**

```
[Obstacle] 9 hrs/week hunting prior work persists
[Obstacle] 9 hrs/week hunting prior work

[Obstacle] 1/5 of archive in unowned departmental store
[Obstacle] ~20% archive outside Documentum, skews recent

[Obstacle] Final deck version lost as attachment
[Obstacle] Final client versions never return to library
```

Plus one cross-type pair, `$740/year vs existing tool in budget` standing as both an Obstacle and
a Pressure — which is the eightieth stamp's cross-type calibration class, Matthew's to grade and
not a duplicate by construction.

**Whether layer 2 works on restored faces is now testable and untested.** It needs a stacked write
where a later call's cards meet an earlier call's standing board, which the opportunity-scoped
query prevents a rebuild from producing. **Named, not guessed, and not claimed.**

This also touches the ninety-ninth stamp's open grading item — whether s5's card count is lawful —
because at least three of the pairs above are candidates for the excess it asks about. **Design's
row pass against the authored expectations, not mine.**

## Suite

**516, 515 AAO passing**, the only failure the standing non-AAO `ConvertToOpportunityTest`.

**Nothing tuned toward any expectation table. The guidance was calibrated on what the run
produced, and the one change made after seeing output was the repair of a defect my own wording
introduced.**
