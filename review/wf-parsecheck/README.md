# WF s4 / s5 · parse check · PARSE ONLY, no pass run, no grading

Scratch deal, deliberately **not** the Wells Fargo seed: the WF deal is the measurement
instrument and nothing touches it before the read. Account `001WD00000v1RofYAE`, Opportunity
`006WD00000TlJPtYAN` — the same scratch deal that becomes the demo deal later.

## The body parses clean

| | s4 (19 Aug) | s5 (25 Sep) |
|---|---|---|
| cues read | 139 | 139 |
| turns after merge | 111 | 97 |
| distinct speakers | 7 | 8 |
| NF1 bytes | 19,858 | 20,102 |
| diarization | Attributed | Attributed |
| markup left in body | none | none |

First and last turns resolve to real text at their own offsets on both files. No `<v …>` tag and
no `-->` survives into the normalized body. **The 139-cue form the parser had never seen holds.**

## FINDING 1, HIGH · the NOTE roster does not parse, so nobody is marked internal

`AAO_IntakeVTT.roster()` returns **0 entries** on both files. Returning empty rather than
fabricating is the ruled behaviour (twenty-sixth stamp) and is not a crash — but the consequence
matters for step 4 and is not visible in the counts above.

The header carries the side split in prose:

> `Attendees: Katherine Villanueva, … (Wells Fargo); Dana Whitfield, Marcus Oyelaran (OpenText)`

With zero roster entries, participants come from voice tags alone: no email, no title, and
**nothing marking Dana Whitfield and Marcus Oyelaran as the SELLER side.** Every speaker would
read buyer-side, so seller words could establish buyer facts — which is the a23 Wendy failure
in a new coat, and the internal check exists to make it impossible.

Not fixed here. It is an intake change, and changing intake alters what a run counts, which is
the one thing that must not move between the regression read and the WF read.

## FINDING 2 · `utteranceEnd` is end-EXCLUSIVE, and one reader treats it as inclusive

Measured: the last turn's `utteranceEnd` equals the body length exactly on both files
(19,858 and 20,102), so the bound is exclusive. `AAO_Pass.indexOfTurn` resolves an offset to a
turn with `offset >= start && offset <= utteranceEnd`, which is the inclusive reading. At an
exact turn boundary that matches two turns and takes the first.

Pre-existing, and the whole graded corpus already ran through it, so it is **reported and not
touched**: changing offset-to-turn resolution before the regression read would move numbers the
read exists to check.

## Process note

Two description caps found the hard way in one session — 1000 chars on a custom field, 255 on a
static resource. Both caught by the deploy rather than by a doc.
