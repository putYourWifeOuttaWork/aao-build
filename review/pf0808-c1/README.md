# Run `pf0808-c1` · the two-read measurement against the graded sets · s1 and a23

Thirty-sixth stamp item 3, the measurement-only shape. Authorizing bytes: twenty-seventh stamp
item 6, *"Two comprehensive reads against the graded sets (s1, a23 ...) measures what the second
read recovers ... and whether the merged output holds the graded assertions."* **Reads to
resolution to verify, run-keyed, NO join, NO projection, no Emerson map touch.** Nothing is tuned
against this output; measured, never asserted. The tuned-behaviour law (s1 is the training set, its
numbers predict nothing) and the stage caveat (a23 is one late-stage contracting call, an unknown
share of any refusal number is stage not generalisation) ride every finding.

**retryNotes: N/A** — call 0 is not part of the ratified measurement shape, so no call 0 ran and no
quote-law retry could fire. Run-keyed pairs are left resident (no map, no claims — harmless).

## The two-read recovery, the measurement's point

| | s1 (training) | a23 (unseen) |
|---|---|---|
| located · read A / read B | 16 / 15 | 19 / 18 |
| total located | 31 | 37 |
| corroborated (both reads found it) | 11 | 10 (8 carry the flag†) |
| survivors (distinct establishments) | 20 | 27 |
| **single-read survivors** | **9 (45%)** | **17 (63%)** |
| designators · ladder / model-leg remainder | 0 / 0 | 2 / 7 (6 minted, 1 held None) |
| upheld / refused | 15 / 5 | 12 / 14 |

**On unseen speech (a23) a MAJORITY of establishments — 17 of 27 — come from only one read.** A
single read would lose them; the second read is the recall hedge, and it earns its keep most exactly
where it matters (unseen). On the training set (s1) the split is 9 of 20. Ledger consistent both
runs: located = merged + survivors (s1 31 = 11 + 20; a23 37 = 10 + 27), corroborated + single-read =
survivors.

† a23's 10 both-reads agreements are the 10 merges, but only 8 canonicals carry
`AAO_Corroborated__c=true`: r1q7 (BR_SIG @8322, Refused) and r1q8 (BR_SIG @13107, None) located on
both reads but the survivor was Refused/dropped, so the flag did not propagate. Detailed under the
graded comparison below.

## Timings, labeled honestly

**s1: COLD** (`cache_read=0` on both reads — the Emerson 17 June artifact had not been read this
window). **a23: WARM on the shared prefix** — read A showed `cache_read=12,514` (the system+rubric
prefix that s1's reads had just written; the artifact itself was cold). Reported per the label
discipline; a warm read is never reported as cold.

| stage | s1 wall (ms) | a23 wall (ms) | model (ms) | callouts |
|---|---|---|---|---|
| read A ∥ | 36,696 | 32,650 | 36,450 / 32,443 | 1 |
| read B ∥ | 34,932 | 24,749 | 34,592 / 24,611 | 1 |
| resolution (deterministic) | 194 | 428 | 0 | 0 |
| resolution model leg | — (rem=0) | 9,736 | — / 9,480 | 0 / 1 |
| verify plain (internal sub-batch at cap 15) | 40,088 | 44,566 | 39,912 / 44,376 | 2 |
| verify sentiment | 9,007 | 27,433 | 8,877 / 27,319 | 1 |
| **end to end (shell)** | **81,331** | **94,518** | | **~5 / ~6** |

The grammar budget held: verify plain sub-batched internally at the cap (batches=2 on both), so no
keyed call crossed the gateway grammar ceiling. This is the measurement shape (no join, no
projection), so the ~80-95 s is not comparable to the express-lane ≤60 s target; it is reads + verify
run serially through the CLI.

## Governor headroom (used / limit, per stage, synchronous)

Nothing near any ceiling on either fixture. The heaviest single readings: a23 resolution SOQL 16/100
(the designator ladder's queries), a23 verify_plain DML rows 21/10,000, heap peaks ~11 KB of 6 MB
across the reads. Every stage sits under ~16% of every governor. Full per-stage lines are in the run
logs; no join ran, so the join's DML wall is not exercised here.

## The graded comparison (adversarially verified)

A graded-comparison workflow read the two Identified CSVs against the grades in
`docs/aao-adjudication-sheet.md`, with a separate adversarial verifier recomputing every count from
the CSVs. Its decisive result is a correction to this run's own premise, reported here first because
it changes what can honestly be claimed.

### a23 has no graded rows in this repo, so no row-level a23 quality number exists

The grade home this measurement expected, "adjudication sheet section 11 (a23)", is not in
`docs/aao-adjudication-sheet.md`. The section list is 1, 2, 3, 3a, 3b, 4, 5, 6, 8, 10, 9, 7; there
is no section 11. The only offset-bearing Emerson grades in the sheet are §8 and §9, and both are
the **17 June fixture** (artifact `ec8e7170`, the sweep run s1) living in a **different byte space**
(offsets to 35,552; §8 carries no offsets at all), whereas a23's located pairs span offsets 135 to
18,976. a23 is a distinct 29 July fixture. The verifier confirmed this independently and ruled the
correct action was to refuse a match, not borrow §8/§9.

Consequence, stated plainly: **a23's two-read run cannot be graded row-by-row from this repo.** The
only authoritative a23 grade is the aggregate carried in from the earlier single-read graded run: 32
of 35 located pairs graded TRUE, upheld precision 70% (7 of 10), refusals 0 of 18 correct. That
aggregate is a **single-read, single late-stage call** number: the two-read run surfaced 12 upheld,
two beyond the graded denominator of 10, so no two-read upheld precision was computed and none is
asserted. The stage caveat rides the 0-of-18: an unknown share of it is stage, not model behaviour,
so it is not a generalisable refusal-failure rate.

### s1's grades are present (§9), so its comparison is genuine but cross-run

s1 was graded whole by Matthew in §9 (`aao-sweep-s1-graded.csv`), so the 15 upheld survivors match
by contract+offset against real graded rows. Best estimate **12 of 15 upheld = 80%** (floor 10/15 =
66.7% counting only clean matches, ceiling 13/15 if the one uncertain supporter is true; denominator
15, valid). Three upheld land on bytes the sweep refused or graded FALSE and read as over-reads
(POL_OPS1 @31449, Ryan POL_PS2 @35552, Neeraja SUPPORTER @38811). Of 5 refused: 3 rightly, 1 a
**known wrong refusal** (r1q10 Neeraja POL_PS3 @10348 = poq7, graded True), 1 uncertain, and both
refusal errors concentrate at **offset 10348 / Neeraja, exactly where the sweep's own two wrong
refusals live**. This 80% sits below the sweep's own 94.1% (16/17), but the comparison is cross-run
(a two-read merge against the single-pass sweep harvest), several matches rest on person+contract
proxy because §9 publishes offsets for only four rows, and by the tuned-behaviour law s1's numbers
are training-set figures that predict nothing about unseen speech.

### The corroboration flag: 10 both-reads agreements, 8 flagged canonicals (a23)

Verified row-for-row: a23's org `corroborated=10` equals the 10 merges, but only **8** canonicals
carry `AAO_Corroborated__c=true` in the Identified CSV. The two that received a merge partner yet
lack the flag are **r1q7 (BR_SIG @8322, Refused)** and **r1q8 (BR_SIG @13107, None-disposition)**:
both reads located those bytes, but the surviving disposition was Refused or dropped, so the
corroboration flag did not propagate. Both-reads agreement at the located level is 10;
corroborated-and-surviving-flagged is 8. Reported as a data nuance, not asserted as a defect.

### The adversarial verdict

The verifier recomputed every count from the two Identified CSVs and **CONFIRMED the arithmetic
exact on both fixtures** (s1: 31 = 11 merged + 20 survivors, 11 corroborated + 9 single-read = 20;
a23: 37 = 10 merged + 27 survivors, 10 + 17 = 27; every upheld/refused count matches the org). It
confirmed the second-read recovery is computed offset-for-offset (a23 +8 of 27 from read B, s1 +4 of
20), that the a23 restraint (refusing a precision it cannot ground) is correct, that no rate rests on
a denominator below 3, and that neither fixture's non-generalizable rates are used predictively. It
found **one minor, non-material defect**: this run's prose that s1's merged partner is always the r2
side is wrong for 2 of 11 pairs (r1q3 @14363 DC_F and r1q12 @23678 BR_EVAL carry Merged on the
read-A side); it changes no count and the upheld section already treats the r2 rows as canonical.
Net verdict: **recall arithmetic solid; precision/refusal quality either unavailable (a23) or
non-generalizable (s1).**

## What this measurement does and does not establish

It establishes, mechanically: how much the second read recovers over a single read (a lot, most on
unseen speech), and how the two-read located/upheld output lines up against the human grades. It
does NOT establish accuracy of the current pipeline as shipped (s1 is tuned; a23 is one stage), it
does not measure the express-lane wall (no join/projection ran), and nothing here is tuned against.
Rows: `pf-c1-{s1,a23}-located.csv`, `pf-c1-{s1,a23}-identified.csv`.
