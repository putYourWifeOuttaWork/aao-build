# Run `em0807-a22` · gate 1

Source `a1XWD0000081W9J2AU`, 17 June Emerson/AspenTech NF1, sha
`ec8e717045f8701534963576ded2a736df5a27b5314721f20b6aa004d5f25a5f`, frozen.
Projected to `006WD00000TJmJZYA1`.

| file | rows | what it is |
|---|---|---|
| `pairs.csv` | 44 | every identified pair, `start_offset` and `length` verifiable |
| `claims.csv` | 56 | every claim on the deal, cumulative, retired rows included |
| `answers.csv` | 11 | standing answers with counter and projection watermark |
| `coverage.csv` | 6 | **the coverage derivation, gate 2**: person, distinct artifact hashes, value derived, value on map |
| `regression-dispositions.txt` | 34 | every assertion, one line |
| `timings.md` | — | per-callout wall and **governors per stage** |

## The run

| | a21 | a22 |
|---|---|---|
| located | 36 | **44** |
| upheld | 17 | **18** |
| held assertions | 19 | **23** |
| regressions | 5 | **3** |
| **traps reproduced** | 1 | **0** |
| criteria minted | 3 | **5** |
| criteria projected to the vendor | 0 | **1** |

- **call 0: DUAL**, both sides byte-located. First time the gate's verdict is reached.
- **sweep**: 9 / 12 / 12 / 11, four transactions, blank retries 0.
- **identify**: 44 to a person, 0 None, 0 Ambiguous.
- **verify**: 18 upheld, 26 refused, conjunct live, homogeneous batches.
- **ledger**: 44 / 44 / 44, HELD.
- **join**: 18 claims, 5 criteria minted, 0 trapped, 0 verdicts rebuilt.

## What to read first

**`coverage.csv`**, because it is new and ungraded, and because it carries a finding: Jefferson
appears as TWO identities (`Jefferson Vargas` unlinked at 2 occasions, and
`Vargas, Jefferson [EMR/SYSS/AT/MEDI]` at 1), so one human's occasions are split rather than
summed. The map shows only the linked one.

**And the call 0 verdict is right on the wrong evidence.** See the report: DUAL was reached by
naming the rollout/enablement/CSM stretch, which Matthew ruled is in-deal, not the two
account-grain stretches the gate names.
