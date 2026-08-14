# Run Inspector v2 · UX spec · design draft · 12 August 2026

**Satellite, drafted at Matthew's direction from his read of the rendered v1 ("detail under the selected row; refusals hidden until unhidden; visualize what happened in what order; row titles in words, not codes"). Buildable on his yes. Nothing here changes what the Inspector reads, only how it reads out; the controller stays read-only and the 45-of-45 offset proof stands.**

## 1 · Row titles carry words, and the words already exist

No invention and no new field: every contract carries `AAO_Proposition_Short__c` in plain language, verified in the sandbox this session. The row title becomes the person plus that short name plus the established value where there is one.

**Matthew's ruling, 12 August: FAMILY PLUS ESTABLISHED VALUE in the title, the full proposition name on hover and in the opened detail.** Compact enough to scan, and it reads the way the map reads.

| today | v2 title | on hover / in detail |
|---|---|---|
| `Adam Pfeiffer · AAO_PB_INIT` | **Adam Pfeiffer · Initiative** | Problems · Initiative |
| `Kayla Stanley · AAO_POL_PS2` | **Kayla Stanley · Political Status: Political Structure** | Political · Structure · called on to make it happen |
| `Adam Pfeiffer · AAO_PS_1` | **Adam Pfeiffer · Support: Supporter** | Sentiment · How does this person stand toward us? |
| `Dan Lewis · AAO_BR_EVAL` | **Dan Lewis · Buyer Role: Evaluator** | Buyer Role · Evaluator |

A refused row carries the family and the value that was PROPOSED and declined, so the title still says what was at stake. The code stays available on the detail panel for engineering, never in the title. Where a contract has no short name the code shows and that is a defect to report, not a silent fallback.

## 1b · Rows group by person · Matthew's ruling

Establishments group under the person they are about (Adam, then Dan, then Kayla, then anyone else), each person a collapsible group carrying their count. This reads like the relationship map and answers "what do we know about this person, and how do we know it" in one place. Within a person, order by family, then by byte order so the call's sequence survives inside the group. A person with only refusals still appears, with their refusals collapsed per section 3.

## 2 · The detail opens inline, under the row that was clicked

The walk-back moves from the bottom of the component to an expanding panel directly beneath its own row, pushing the rows below it down. One open at a time; clicking another row closes the first; clicking the open row closes it. The reader never loses the place they clicked from.

## 3 · Refusals are collapsed until asked for

The refused column does not render its rows by default. It shows its count as a control: **"21 refused — show"**, which expands in place and collapses again. Two laws ride, both from the sixty-third stamp and neither weakened: the refused COUNT is always visible, because a surface that hides how much was declined stops earning trust; and the stage keeps its meaning line ("this is where trust is earned"). Hidden by default, never hidden absolutely.

## 4 · The order is drawn, not implied

Two levels of the same picture.

**Run level, above the columns:** a horizontal stepper in the pipeline's real order, each step carrying its count and its plain-language name.

`Source read → Words located (60) → People identified (60) → Verified (24 upheld / 21 refused) → Claims written → Answers ledgered → Projected (3 map rows, 12 cards)`

**Counts by default; performance behind a toggle · Matthew's ruling.** A "show performance" control reveals, per stage, wall time and governor consumption (SOQL, DML, callouts, heap) with the COLD or WARM label, so the Inspector can stand in for the run report during testing without cluttering the default read. The numbers shown are the ones the run actually journalled; nothing is recomputed or estimated on the page.

**Establishment level, inside the open detail:** the same chain shown as the numbered path THIS value actually took, one line per hop, each saying what was done in words rather than naming an object:

1. **Read the call** — `projectfarma/2026-07-30-nf1`, 30 July 2026
2. **Found the words** — bytes 8938-9007, quoted verbatim
3. **Identified the speaker** — Adam Pfeiffer, deterministic (their own turn) or resolved, with which
4. **Asked the question** — the contract's proposition text in full
5. **Verified blind** — Upheld, with the verifier's reason
6. **Wrote the claim** — claim id, outcome (Established / Reinforced / Retired)
7. **Ledgered the answer** — the answer id and its verdict
8. **Projected** — what landed where (map row field, or card), or why it did not

Steps that did not happen render greyed with their reason ("no claim: refused at verify"), so a refusal's path is as legible as an uphold's. This is the verification sheet's walk, drawn.

## 5 · Internal speakers are marked

Per the sixty-fifth stamp's owed item: an internal person's row carries a marker and the reason no card or map row followed. Shown, not hidden, and never mistakable for a customer establishment.

## 6 · Out of scope for v2, named

No writes, ever, from this surface. No transcript viewer (the quote plus byte range is the receipt; a full transcript pane is its own build). No filtering or search beyond the run picker and the refused toggle. No Flags — the Surface waits on them per the fifty-seventh stamp.

## Acceptance

Matthew opens the Project Farma Opportunity, sees stage counts in order, reads row titles in English, clicks one row, and reads the numbered path from call to projected value beneath it without scrolling away from where he clicked; refusals appear only when he asks and their count is visible before he does.
