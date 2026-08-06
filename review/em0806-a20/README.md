# Run `em0806-a20` · row export and timings

Source `a1XWD0000081W9J2AU`, the 17 June Emerson/AspenTech NF1 artifact,
sha `ec8e717045f8701534963576ded2a736df5a27b5314721f20b6aa004d5f25a5f`, frozen.
Projected to `006WD00000TJmJZYA1`, "Emerson/Aspen Tech Insights 500 Full Insight" — the deal
open when the words were spoken, resolved by call 0 on content.

| file | rows | what it is |
|---|---|---|
| `pairs.csv` | 33 | every identified pair with its located half. **`start_offset` and `length` are the verifiable columns** — the check is a byte-range intersection against the frozen artifact, never a comparison against our copy of the quote |
| `claims.csv` | 21 | every claim written on this deal, with subject type, verdict before and after, outcome and rubric version |
| `answers.csv` | 9 | the standing answers, with the support counter and the projection watermark |
| `timings.md` | — | per-callout wall, worst single callout and worst transaction against the 120,000 ms ceiling |

## Reading the pairs export

`call3_verdict` is the blind reader's own disposition and `verification_note` is its reason in
its own words. A `Refused` row is a disposition the pass legitimately made and not an error:
22 of 33 were refused on this run, which is the blind reader doing the job it exists for.

`contact_resolved` is populated for Jefferson Vargas because the create leg made that Contact
on the previous projection run — he arrives in the roster as
`Vargas, Jefferson [EMR/SYSS/AT/MEDI]` and no Contact existed for him at all before 5 August.

## What the run did

- call 0: OPPORTUNITY, d1, on content. Both candidates carry seed CreatedDates weeks after the
  call, so the occurred-time window cannot run here and says so rather than producing a number.
- sweep: 4 reads, **all four families answered**, 33 located. The blank-retry guard was live
  and did not fire, which is reported as a zero rather than as silence.
- identify: 33 to a person, 0 None, 0 Ambiguous.
- verify: 33 verdicts, 11 upheld, 22 refused, three caller-driven batches.
- ledger: one-for-one-for-one holds, 33 / 33 / 33.
- regression: 27 assertions, **16 held**, 8 regressions, 0 traps reproduced, 0 verdicts changed.
- join: 11 claims, 11 answers, 2 counters rebuilt, 1 criterion minted.
- projection: 2 populated, 5 dimension values, **Support written for the first time**.
