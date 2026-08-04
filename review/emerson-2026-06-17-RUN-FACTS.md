# Emerson 17 June · run facts

Carried beside the grading CSV per addendum 03, so nothing in the sheet has to be taken on trust.

| | |
|---|---|
| Run key | `emerson-0617-r1` |
| Source | `SRC-00000035` · `emerson/aspentech-2026-06-17-nf1` |
| Artifact sha256 | `ec8e717045f8701534963576ded2a736df5a27b5314721f20b6aa004d5f25a5f` |
| Occurred | 2026-06-17 20:29:36 UTC |
| Call 1 charter | `AAO_LocateCharter` @ `locate-2.0.0` |
| Call 2 charter | `AAO_IdentifyCharter` @ `identify-1.0.0` |
| Call 3 charter | `AAO_VerifyPairsCharter` @ `verify-pairs-1.0.0` |
| Contracts | `people-p8-v1`, 17 live |

## Per call

| call | wall ms | in | out | thinking | cacheRead | cacheWrite |
|---|---|---|---|---|---|---|
| 1 · locate | 17,060 | 15,330 | 1,308 | 0 | 0 | 5,956 |
| 2 · identify | 9,361 | 4,355 | 748 | 0 | 0 | 1,549 |
| 3 · verify (14 calls, one claim each) | 68,041 | — | 2,169 | 103 | 0 | 868 |
| **total** | **94,462** | | **4,225** | | | |

**Against 87,805 ms per person on the retired shape: 94.5 s for the whole call, whole roster,
all three stages.** The five-person fixture would have been about 440 s on the old shape for
one stage.

**Call 3 is now the expensive stage**, at 72% of the wall clock, because it runs one claim per
call. That is §P8.3's own sentence and it is where blindness is strongest; raising the batch
size is a measurement and it needs the mis-referencing defect fixed first.

## Arithmetic

```
pairs located            14 (unit: pairs)
dispositions made        14 (unit: pairs)
  to a person            14 (unit: pairs)
  None or Ambiguous       0 (unit: pairs)
verdicts returned        14 (unit: claims)
  upheld                  4 (unit: claims)
  refused                10 (unit: claims)
```

One-for-one-for-one asserted after call 2 and again after call 3. Zero discarded for byte
mismatch: **every one of the 14 quotes located in the frozen artifact exactly once.**

## The five graded traps from 24 June

Assertions, not rows for grading. This is a different fixture, so none of the five can appear;
recorded so the absence is not read as a pass.
