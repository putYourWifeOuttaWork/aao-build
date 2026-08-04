# Emerson 17 June · the family sweep · run facts

| | |
|---|---|
| Run key | `emerson-sweep-s1` |
| Source | `SRC-00000035` · `emerson/aspentech-2026-06-17-nf1` |
| Artifact sha256 | `ec8e717045f8701534963576ded2a736df5a27b5314721f20b6aa004d5f25a5f` |
| Call 1 | `AAO_LocateCharter` @ `locate-3.0.0+d314a73c` — **one read per family, four reads** |
| Call 2 | `AAO_IdentifyCharter` @ `identify-1.0.0` |
| Call 3 | `AAO_VerifyPairsCharter` @ `verify-pairs-1.0.0`, one claim per call |

## Per call

| stage | wall ms | out tokens |
|---|---|---|
| 1 · sweep, Buyer Role | 18,170 | 1,326 |
| 1 · sweep, Decision criteria | 13,441 | 711 |
| 1 · sweep, Political Status | 16,602 | 1,061 |
| 1 · sweep, Sentiment | 14,866 | 931 |
| **1 · total, serial** | **63,079** | **4,029** |
| 2 · identify | 25,833 | 2,373 |
| 3 · verify, 40 claims over 3 transactions | 172,419 | 4,940 |

**Call 3 no longer fits in one transaction.** At one claim per call, forty claims is ~172 s
against a 120-second per-transaction ceiling that is law-grade. It is driven in batches of 14.
A consequence of the sweep doubling the harvest, recorded rather than discovered by a timeout.

Concurrency was considered and is unavailable: Apex cannot issue concurrent callouts from one
transaction. The serial number is the only number, and call 1's four reads fit inside the
ceiling with room.

## Arithmetic

```
pairs located            40 (unit: pairs)
dispositions made        40 (unit: pairs)
  to a person            40 · None or Ambiguous 0
verdicts returned        40 (unit: claims)
  upheld                 17 · refused 23
```

Zero byte-match discards. Zero coverage defaults.

## Per family

| family | contracts | pairs |
|---|---|---|
| Sentiment | 1 | 11 |
| Political Status | 8 | 9 |
| Buyer Role | 5 | 14 |
| Criteria | 3 | 6 |

**Sentiment holds one contract and produced 11 pairs, against 2 under the single read.**
It cannot have been capacity-bound by how many propositions it held. The scarce resource is
attention, not prompt size.

## Multi-establishment

**7 quotes carry more than one establishment**, against 1 of 17 under the single read.
The worked example was deleted from the prompt at `locate-3.0.0`; the partition taught what two
rewordings could not.

## The regression set

| run | regressions | detail |
|---|---|---|
| `emerson-sweep-s1` | **1** | `emerson-q9` — Matthew's *Flexibility of Services Hours* criterion |
| `emerson-sweep-s2` | **0** | HELD |

**Named by ref, as asked: the one lost graded PASS is `emerson-q9`, and it is the same one
that has been lost on every run since the grading.** It is not a new breakage introduced by the
sweep; it is a standing one the sweep did not repair.

`emerson-q13` moved on both runs and is reported `CHANGED, undiagnosed` rather than as a loss,
per the ruling: a correct refusal that stops appearing is a read that stopped making a mistake.

Zero traps reproduced. Both sweep runs recovered a Matthew UNDER that no earlier run had found
(`under-1` on s1, `under-5` on s2).
