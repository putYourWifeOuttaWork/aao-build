# The 141st's two riders

CODE, 20 August. Both built, both proven at the runtime, mechanism shape named.

## Rider (ii): the error path drops the telemetry

**Mechanism shape: usage banks transaction-scoped the moment a response is read, so a stage that
throws still prices what it spent.**

The success path prices a stage from the `StageResult`s it hands back. A stage that throws hands
back nothing, and its usage dies in its own frame. That is the same hole the 127th stamp found
in the callout count and closed with `Limits.getCallouts()`; usage has no platform counter, so
`AAO_Extract` becomes the counter:

```apex
readUsage(c.usage, (Map<String, Object>) root.get('usage'));
bank(c.usage);
```

Banked **before** any reason `send` might throw, so a refusal, a `max_tokens` truncation, a
missing text block, and every failure further up the stack are all billed. `recordFailure` reads
it into the leg; `record` clears it the instant a leg carries the numbers away, so the two paths
cannot double-count. Written by `bank`, read by the receipt, **branched on by nothing** - the
telemetry inertness law holds.

Proven on a real paid callout forced to truncate:

```
E   The response hit max_tokens and the JSON is truncated ...
BANKED  in=944 out=24 cacheRead=2330 cacheWrite=0 thinking=0
FAILURE LEG ON RECEIPT RCPT-00000057: callouts=1 in=944 out=24 think=0 cacheRead=2330 cacheWrite=0
ACCUMULATOR AFTER = in=0 out=0 cacheRead=0 cacheWrite=0 thinking=0
```

Before this, RCPT-00000055 carried `callouts: 2` on each of two stage rows with **every token
field null**: four paid calls billed as zero, on the run that most needed pricing.

## Rider (i): the resume lies by silence

**Mechanism shape: the attempt count and the clock ride with the reason, so two failures of one
stage cannot render identically.**

The panel was not frozen and the resume was not dead. `progress` already took the LAST leg per
stage, so the second failure did reach the surface. What it could not do was **look different**:
`stoppedBecause` was `stage + ' — ' + error`, and neither half changes between two failures of
the same stage. A second failure that renders identically to the first IS silence, whatever the
receipt holds, and Matthew's only honest conclusion from an unchanged surface was the wrong one.

`RunView` gains `stoppedAt` and `stoppedAttempts`, counted across every error leg rather than
only the surviving one, and the reason carries them:

```
call 0 resolve (attempt 1, 08:14:46) — The response hit max_tokens and the JSON is
truncated, so it cannot be parsed. Raise AAO_Max_Output_Tokens__c on the config record.
```

Had this existed at 14:25, the rehearsal's resume would have read `attempt 2, 14:25:18` beside a
different scope in the message, and the surface would have told the truth it already held.

## What happened while these were being built, reported exactly

A full rehearsal pass ran at 14:57:25 and **succeeded end to end**: call 0 resolve, two locate
reads, call 3 verify, criterion match, join, computed catalog, projection, cards. Six cards.
Five callouts. No errors on any leg.

**It ran on the OLD charter and is not evidence for the fix.** The leg says so in its own bytes:

```
CALL 0 charters=AAO_ResolverCharter@resolve-1.1.0+c13597d2 cache=WARM wallMs=6543
CLASS SAYS resolve-1.2.0+7342add8
```

`resolve-1.1.0` fails roughly one time in five at the effort call 0 runs; this run drew a good
one. The fix removes that draw, and this pass does not demonstrate it.

**What the pass DOES demonstrate is the 139th's telemetry on a full real run**, which is the
first end-to-end token bill this project has ever printed:

| stage | callouts | in | out |
|---|---|---|---|
| call 0 resolve | 1 | 1,387 | 237 |
| call 1 locate read 1 | 1 | 8,000 | 2,670 |
| call 1 locate read 2 | 1 | 8,000 | 2,927 |
| call 3 verify | 1 | 8,108 | 1,207 |
| criterion match | 1 | 1,846 | 34 |
| join / computed catalog / projection / cards | 0 | 0 | 0 |
| **run total** | **5** | **27,341** | **7,075** |

Cache read 7,228, cache write 4,869. **Part 3's cost section now has a whole transcript's bill
rather than an estimate**, and design's ~85k-per-transcript figure can be checked against a
measured 27.3k input on this one, with the caveat that this transcript is 2,770 characters and a
real call is far longer.

**One thing I reported as a mystery and then found the answer to, recorded in both halves
because the first half was my error.** RCPT-00000055 no longer exists: read in this session,
absent now, with 54, 56 and 57 present. I wrote that receipts are not in the purge's object
list. That was wrong, and it was wrong because I read `AAO_Demo.purge()` and stopped there.
Receipts are taken by a different class, `AAO_Purge`, which deletes them by run key, and
`AAO_ReceiptTest.aPURGETAKESTHERECEIPTWITHTHERUN` has been asserting exactly that the whole
time. The test name is what corrected me.

So RCPT-00000055 was removed by the purge, which is Matthew's opening move under v0_3 and the
system working as designed. **The finding is not the missing receipt; it is that I declared a
mystery from a partial read of one class when a test name held the answer** - the same
wrong-address shape the 142nd made law, committed while writing about it.
