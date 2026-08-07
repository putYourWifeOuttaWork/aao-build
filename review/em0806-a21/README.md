# Run `em0806-a21` · row export, dispositions and timings

Source `a1XWD0000081W9J2AU`, 17 June Emerson/AspenTech NF1, sha
`ec8e717045f8701534963576ded2a736df5a27b5314721f20b6aa004d5f25a5f`, frozen.
Projected to `006WD00000TJmJZYA1`.

| file | rows | what it is |
|---|---|---|
| `pairs.csv` | 36 | every identified pair with its located half; `start_offset` and `length` are the verifiable columns |
| `claims.csv` | 38 | every claim on the deal, cumulative across a20 and a21 |
| `answers.csv` | 11 | the standing answers with support counter and projection watermark |
| `regression-dispositions.txt` | 31 | **every assertion, one line**, as ruled |
| `timings.md` | — | per-callout wall, worst single and worst transaction against the ceiling |

## The run

- **call 0**: OPPORTUNITY, d1, with a real `scope_because` (the placeholder defect is fixed at
  the parse). **Scope is still OPPORTUNITY, second occurrence** — see the report.
- **sweep, split**: four transactions, all four families answered, 36 located. Guard live, no fire.
- **identify**: 36 to a person, 0 None, 0 Ambiguous.
- **verify**: 36 verdicts, **17 upheld, 19 refused** (a20: 11 upheld).
- **ledger**: 36 / 36 / 36, HELD.
- **regression**: 31 checked, 16 held, **5 regressions** (a20: 8), **1 trap reproduced**,
  1 recovered, 5 still missed, 3 unreachable, 1 changed. `31 of 31` dispositions listed.
- **join**: 17 claims, 17 answers, **3 criteria minted**, 0 typings unattached,
  **0 verdicts rebuilt** — the write-time clobber guard held, so the replay found nothing to correct.
- **projection**: 3 populated, **10 dimension values** (a20: 5), 0 retracted.

## The map now

| person | Support | Political | Buyer Role | Coverage |
|---|---|---|---|---|
| Neeraja Chimata | Supporter (+1) | — | Evaluator | written |
| Ryan Couture | **none, retracted** | — | Evaluator | written |
| Vargas, Jefferson | **Mentor (+3)** | Political Structure | Evaluator | written |

## The correction, 6 August evening

**Ryan's Supporter came from the trap and is gone**, through the lawful path rather than a
delete. Claim `CLM-00000073` (pair `seq9`, `AAO_PS_1`) is marked **retired** with its reason and
is still in `claims.csv`, still carrying its quote and its call 3 verdict. The replay skipped
it, his answer fell to UNVERIFIED with counter 0, and projection **retracted** the map value.

**The rows to read for it**: `claims.csv` carries the retired claim; `answers.csv` shows the
`AAO_PS_1` row for Ryan at UNVERIFIED / 0 with an empty projected value.

**One thing left to grade**: Jefferson's +3.
