# AAO Verification Sheet · v1.0 · 8 August 2026

**Design's per-run verification, written as the procedure it always was. Every run export is checked against exactly this list; a check nobody wrote down is a check nobody can know is complete. Satellite, outside the audit chain; the Board names it. The map read sheet is its companion for Matthew's human read.**

## Inputs

The run's export (pairs, claims, answers, coverage lines, regression dispositions, timings with governors, README), delivered through Matthew or the project. The frozen artifact named by the run, taken from the freeze list (`review/gate3/frozen-fixtures.md` in CODE's repo), never queried from the org. The regression seed and graded CSVs in the project.

## The checks, in order

**1 · Provenance.** The export's artifact sha256 matches the freeze list's entry for the named fixture. Every pair's verbatim string occurs in the frozen artifact byte-exact at its stated offset and length. Every quote locates exactly once (multiple matches are reported, not failed). A yes from call 0 carries a quote that locates the same way.

**2 · Arithmetic.** Located = sum of per-family counts. Located = identified = verdicts (one-for-one-for-one). Upheld count = claims written this run; every upheld pair carries a claim id; no refused pair carries one. Answer counts reconcile between report prose, README, and rows, in one unit each. Regression dispositions sum to the full universe, every assertion on its own line (HELD, LOST, RECOVERED, STILL MISSED, UNREACHABLE, CHANGED); categories that do not sum to the universe are a defect in the harness, not a rounding note.

**3 · Law compliance.** No trap in the graded set appears as an upheld projected claim; a fired trap is refused at the claim and reported. Partial-coverage pairs accrue and displace nothing (no TRUE downgraded by a later partial). No account-grain read dispatched while the grain is backburnered; routed-not-dispatched lines carry their yes-quotes. Retired claims remain present with reasons; nothing deleted. Watermarks present on every projected value including retractions; no machine write over a human-claimed value. Coverage derivation counts conversations (occasion identity), never artifact hashes or rows.

**4 · Ceilings.** Worst single callout and worst transaction printed and under the 120,000 ms law. Governor consumption printed per stage; anything past 80% flagged. Blank-retry invocations journalled where they fired.

**5 · Report honesty.** Timings, governors, and the full disposition list shipped, or the report does not count. Declined-to-run ships no rows and says why with quotes; ran-and-found-nothing ships its zeros. Every count names its unit. Every "built/verified/fixed" claim in the report is evidenced by a named run, query, or row visible in the export; anything evidenced only by a green suite is listed for the capability-law follow-up.

**6 · Regression consequences.** New graded PASSes from any human grading since the last run are present as assertions (keyed on contract plus byte-range, never refs, which are per-run). LOST assertions are named to Matthew for re-grade or retirement; CHANGED lines stay undiagnosed rather than scored.

## Output

A verdict per lens (clean, or findings with severity), folded into the Architecture head for the run and the inbox stamp. Findings CODE must answer travel with the next build items. Anything Matthew must grade goes to him as its own short list with quotes.
