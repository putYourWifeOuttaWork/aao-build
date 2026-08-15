# Matthew's own grading surfaces, recovered from `~/Downloads` and preserved

**These are human artifacts, and human edits beat the machine forever.** Every file here is a
grading surface Matthew worked in by hand, or the graded output of one. They were sitting loose in
`~/Downloads` on this device, tracked by nothing, backed up by nothing.

The eighty-second stamp's item 3(b) named exactly this class as **the true archive loss if no
remote exists**: *"purged historic runs' raw exports are the true archive loss."* A remote exists
now, so they are preserved here rather than left to the next disk event.

## What is here

| file | bytes | sha256 (this device, 15 Aug) | what it is |
|---|---|---|---|
| `aao-a23-graded-v1_0.csv` | 9,262 | `f65bceb4…` | **THE a23 GRADING, 43 rows.** The unseen-speech grading, `ref,family,claimed,person,spoken_by,coverage,call3,quote,GRADE,note,offset,len` |
| `aao-grading-sheet-tg1-vs-pass1-v1_0.numbers` | 861,069 | `2790eb82…` | the tg1-versus-Pass-1 sheet, Numbers original |
| `emerson-2026-06-17-FOR-MATTHEW.numbers` | 182,101 | `ba367472…` | Emerson 17 June, the grading surface as delivered |
| `emerson-2026-06-17-review-MATTHEW-clone.numbers` | 208,946 | `b81d3593…` | the same, **carrying Matthew's own working marks** |
| `emerson-sweep-s1-FOR-MATTHEW.numbers` | 237,218 | `992966b3…` | the s1 family sweep grading surface |
| `refusals-2026-06-24-FOR-MATTHEW.numbers` | 119,967 | `04e38d7f…` | Black and Veatch 24 June, refusal grading |
| `sentiment-2026-06-24-FOR-MATTHEW.numbers` | 102,154 | `7fac5ff8…` | Black and Veatch 24 June, sentiment grading |

`aao-a23-graded-v1_0.csv` was named `aaoa23gradingsheet - aaoa23gradingsheet.csv.csv` on disk.
**Renamed for legibility, bytes untouched**, and the original name is recorded here so the carry is
reconstructible. Nothing else was renamed.

## Why the a23 CSV specifically matters

The repo already held `review/aao-grading-tg1-vs-pass1-graded.csv` and its `.xlsx`. **It held no
machine-readable a23 grading at all.** The a23 grades exist in the repo only as prose inside
`aao-adjudication-sheet.md` §11 and `aao-a23-refusal-diagnosis-v1_0.md`.

That is the grading the twenty-second stamp folded and the thirty-seventh stamp called
*"mechanically derivable"* — the derivation the a23 graded comparison runs from, and the only
row-level human grading on unseen speech this project has. **It is the source of the number that
inverted a standing assumption**: refusals 0 of 18 correct on unseen speech against 21 of 23 on the
training set. Prose is not a source for a mechanical derivation, and until now that is all there
was.

## Counting status, unchanged by preservation

Nothing here is re-graded, re-derived, or tuned against. These are the artifacts as Matthew left
them. The a23 CSV's grades stand exactly as the twenty-second stamp folded them, including the two
FALSE grades on `deq1`/`deq2` that stamp marked **provisional** pending a sheet that carries
criterion names.

## What was deliberately NOT brought in, and why

Checked by hash against the whole repo, not by name:

- **`CODE-INBOX.md`, `CODE-INBOX_1.md` through `_4.md`** — five progressive ledger snapshots from 8
  August, topping at the nineteenth, twenty-eighth, twenty-ninth, thirtieth and thirty-second
  stamps. **Sampled 38-39 of 40 long lines from each already present verbatim in the live ledger.**
  The one or two misses per file are lines later struck in place per the corrections law, which is
  the ledger working as designed. Nothing is recoverable from them that the live 435,252-byte
  ledger does not already carry.
- **The context archives** (`aao-context_1` through `_27`, `aao-bundle`, `AAO_aug2_7pm`,
  `aao-docs-2026-08-08`, `AAAO_AUG31`, the code handoffs) — every one carries law documents at a
  state the repo has since passed. `aao-docs-2026-08-08.zip` holds the adjudication sheet at 40,003
  bytes; **the repo's is 57,594 and carries §11.** Older copies of documents we hold newer are not
  provenance, they are clutter.
- **`altifyos-*`** (glossary, architecture, object model, philosophy, theory, personas, gate1
  results) — the predecessor project's documents, superseded by the AAO law documents.
- **Decks, PDFs, architecture PNGs** — communication artifacts, not build or grading inputs.
- **`aao-charter-design-v0_7` through `v1_8`, `aao-corrections-v2_4` through `v2_8`, proof
  registers, field tables, board v22** — pre-loss design lineage, all superseded by the current law
  documents, none load-bearing on any open item.

**The originals stay in `~/Downloads` untouched.** These are copies. Nothing was moved or deleted.
