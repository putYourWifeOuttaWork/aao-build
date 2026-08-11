# The thirty-eighth stamp's queue · items (a) through (d) · rows, evidence, and three parks

Every item below carries its authorizing bytes. Analysis ran under a four-workstream fan-out with
an independent adversarial verifier per workstream; every number here was recomputed by the
verifier from the underlying file or org row, and the corrections it found are folded in and
attributed. Measured, never asserted. Item (e), the temperature-0 probe, has its own report at
`review/pf0811-t0/README.md`: **it cannot run, the knob is deprecated on the model call 3 uses.**

---

## (a) The tg1-versus-Pass-1 grades, folded into the regression set

Authorizing bytes, item 5(a): *"fold the new grades into the regression set per the standing
sixth-check law, new graded PASSes as assertions keyed contract plus byte range, the OVER rows as
traps, the MIS specimen riding with its pair refs."*

**The GRADE column carries exactly two values**, True (34) and False (49). PASS, OVER, MIS and
INTERNAL are all DERIVED by crossing the grade with the runs' call-3 verdicts, so the partition is
computed rather than read off a label. Recomputed independently and it is total:

| bucket | rows | disposition |
|---|---|---|
| internal (our own seller) | 5 | excluded from precision by construction |
| **PASS** (True, upheld by a run) | **22** | **shipped as MUST_APPEAR** |
| **OVER** (False, upheld by a run) | **5** (13, 20, 37, 63, 64) | **shipped as MUST_NOT_APPEAR** |
| wrongly refused (True, refused by every run) | 7 (1, 2, 16, 18, 38, 61, 72) | **PARKED, see below** |
| True, no call-3 verdict (merged or dropped) | 5 | not assertable |
| correct refusals (False, refused) | 36 | nothing to assert |
| False, no call-3 verdict | 3 (9, 31, 83) | not assertable |

5 + 22 + 5 + 7 + 5 + 36 + 3 = 83.

**Shipped: 27 entries on a new `FARMA` fixture constant** (`018cac1b…`, the first real production
speech in the seed). **All 27 quotes byte-locate in the artifact**, verified from the calling
runtime: `farma assertions located=27 NOT_LOCATED=0`. Full suite 426 tests, every AAO test green.

**Keys carry a `pf-` prefix and their graded row number, and that is not decoration.** The `key`
namespace is global across the seed rather than scoped by fixture, and Project Farma's Pass-1 run
reuses the Emerson sweep's pair-ref naming: `buq2, buq3, buq5, buq6, buq7, buq8, deq2, deq6, poq1,
seq2, seq6` are all live Emerson keys already. Bare pair-ref naming would have put two assertions on
two different fixtures behind one disposition line. (The verifier corrected the collision count from
10 to 11; `buq2` was missing from the first list.)

### PARKED · the 7 wrongly-refused rows, and why they are not built

These are graded True and refused by every run that verified them, so they are the most valuable
regression content in the sheet: each is an establishment the machine lost. **They are not built,
under the receipt rule.** Item 5(a) names three things to fold, "graded PASSes", "the OVER rows",
and "the MIS specimen", and a wrongly-refused row is none of the three. The precedent for carrying
them exists in this very class (`poq7` and `seq2` ride as MUST_APPEAR with expectedVerdict Upheld
for exactly this reason), so this is **one ruling away from shipping**, and it is design's ruling,
not CODE's. Rows named in the code so the next stamp can say yes in one line.

### PARKED · the trap the record names that the export contradicts

The grading record's fold section names "row 31's inner-circle upheld" as an OVER. **Row 31 is not
an OVER.** Measured independently, twice: row 31 is False with NO call-3 verdict in either run, so
no run upheld it. Trapping it would manufacture a false positive against a correct refusal. Parked,
and the record's line is sent back for correction rather than silently followed.

### The MIS specimen, rows 61 and 62, riding with its refs and NOT as a trap

The first graded MIS on the two-read shape, and it is an ATTRIBUTION error, not a location one.
Both rows carry **the same words and the same contract**:

> quote `I was just kind of curious on how much of A lift it's going to be for Kayla to get approval from Perkerwicz and Elmer`
> code `AAO_POL_PS2` · refs `tg1 61110-61227 · p1 61110-61260`
> row 61 graded **TRUE**, Matthew: *"True for KAYLA not for Dan."* · row 62 graded **FALSE**,
> Matthew: *"False for dan"*

tg1 attributed to Dan Lewis what Pass 1 attributed to Kayla Stanley.

**STRUCTURAL GAP, reported not papered over: `Assertion` keys on fixture, contract code and byte
range, and carries NO SUBJECT.** A MUST_NOT_APPEAR on these bytes would fire on the CORRECT Kayla
reading exactly as hard as on the wrong Dan one, because nothing in the match can tell them apart.
So the specimen rides with its refs, as the stamp words it, and the gap goes to design: the
regression set cannot currently express a per-person grade.

---

## (b) The a23 graded comparison · RUN, and it reproduces the published aggregate exactly

Authorizing bytes, item 5(b): *"the a23 graded comparison, derivation rule at the thirty-seventh
stamp's item 5, carried verbatim in the grading record on disk."*

**Source note, because the last session's finding was adjudicated:** the Downloads copy of
`aao-adjudication-sheet.md` is still the stale 8 August file, mtime `Aug 8 14:50`, sections
1, 2, 3, 3a, 3b, 4, 5, 6, 8, 10, 9, 7 and **no section 11**. Matthew's ten-second re-download has
not landed. The comparison therefore ran **from the derivation rule carried verbatim in the grading
record**, exactly as item 5(b) provides for, and not from the sheet.

**The rule reconciles, and the arithmetic is explicit.** Applying it to `em0808-a23/pairs.csv`
(35 rows, a clean partition of 18 Refused / 10 Upheld / 7 dropped):

- 18 refused-TRUE + 7 dropped-TRUE + 7 upheld-TRUE = **32 of 35 TRUE**, matching the published figure
- upheld arm 7 TRUE / 2 FALSE / 1 INTERNAL = **7 of 10 = 70.0 percent**, matching
- all 18 refused rows graded TRUE, so **0 of 18 correct refusals**, matching

An honest limit on that reconciliation, raised by the verifier and accepted: once the arm counts are
18/10/7, the three aggregates follow **by construction** from a rule that names its exceptions by
ref. The genuinely independent content is narrower than "it reconciles" suggests. One real external
corroboration exists and is not circular: the ledger independently records that exactly two a23 rows
are Upheld and Full, `buq8` (TRUE) and `deq2` (FALSE), and computing Upheld-and-Full from pairs.csv
returns exactly `{buq8, deq2}` with matching polarity.

### The two-read run against that truth, merge key = contract equality AND byte intersection

Of 37 located rows, 26 carry a verdict and are gradeable; 29 of 37 intersect a truth row.

| | matched | correct | incorrect | unmatched |
|---|---|---|---|---|
| **12 upheld** | 10 | **8** | 2 | 2 |
| **14 refused** | 8 | **0** | 8 | 6 |

**The sharpest finding: the two-read run reproduces BOTH of a23's known false upholds on
byte-identical ranges.** `r1q19` AAO_DC_N 5236-5378 lands on `deq1`, `r1q18` AAO_DC_R 5236-5378
lands on `deq2`. Those are the only two rows §11 graded FALSE. **The defect §11 caught is still
there.**

**Movement the first pass understated, surfaced by the verifier:** of a23's 18 wrongly-refused rows,
9 were revisited by the two-read run, and **3 of those 9 flipped to a correct uphold** (`poq1` via
r2q4, `poq2` via r2q3, `poq6` via r1q12). "The 0-of-18 pattern persists" is true as arithmetic on
the matched subset and misleading as narrative; the measured movement is 3 of 9.

### What this does NOT establish, stated plainly

- **80.0 percent versus a23's 70.0 percent is NOT like-for-like.** Both denominators are 10 but they
  are not the same 10 rows, and the matched subset was selected by which rows the two-read run
  happened to re-locate.
- **The two-read run failed to locate 4 of a23's 7 correctly-upheld rows**, all Decision Criteria.
  Higher precision on a smaller located set is not an improvement on its own.
- The refusal result covers only 9 of 18 wrongly-refused rows, so it is a partial view.
- 6 of the 8 unmatched gradeable rows are refusals, so the run's refusal behaviour is
  disproportionately concentrated in territory §11 cannot grade.
- Recall is not measured anywhere here, and the a23 sheet says so itself.
- **The stage caveat rides every number:** a23 is one late-stage contracting call.

Two verifier corrections folded in: `poq9`'s range is 16124-16205, not 16544-16625; and the
near-miss row the merge key correctly separates is `buq5` (BR_APP, dropped-TRUE), not `poq9`.
Neither moves any count.

---

## (c) Coverage excludes Internal-true participants · SHIPPED

Authorizing bytes, thirty-seventh stamp item 4: *"'coverage reads Internal for you or a team
member' is written law the code diverges from (CODE confirmed `AAO_Coverage` never reads the flag);
coverage derivation excludes Internal-true participants, small, evidenced with rows."*

**The divergence, confirmed:** `grep -c "AAO_Internal__c"` in `AAO_Coverage.cls` returned **0**, and
`grep -in "internal"` returned nothing at all. The class never mentioned the field. The written law
is `aao-charters.md` lines 604-610: every guided question reads *"Have you or a team member met with
this person"*, making a team member the ACTOR and never the subject. Scoring one answers "have you
met yourself", which no question asks.

**The change:** one conjunct, `AND AAO_Internal__c = false`, on **both** participant queries in
`occasionsByPerson`. Both or neither, and that is not stylistic: filter only the grouping query and
internal rows leave orphan hashes; filter only the hash query and `hashes.get(p.Id)` returns null
and the `addAll` dereferences it. The class already states the rule for the mention exclusion, "the
two row sets must be one set". `= false` rather than `!= true` because the field is a Checkbox with
`defaultValue false`, so it is never null.

**Rows: FIVE participants carry `AAO_Internal__c = true` org-wide, all on altify.com** (Jennae
Jizdeortega; Renee Martin; Wendy Higley x3). **Not one carries a coverage watermark.** Wendy's three
rows are 3 of 3 Internal true, so the twenty-second stamp's item 9 is provably repaired in the data.

**Row delta today: NONE, and that is the honest headline.** The four coverage-carrying map rows are
all on the Emerson deal; three belong to Internal-false participants the guard never sees, and the
fourth is Wendy, whose unwatermarked value projection already holds back lawfully. Renee and Jennae
reach no map row at all. **The org cannot demonstrate this guard working**, so correctness is shown
by a purpose-built test instead: `AAO_CoverageTest` is new (coverage had no test class and no test
anywhere asserted a coverage-derived value), and its three tests pass.

**A latent hazard the guard removes, worth more than the null delta:** today an Internal-true
participant with no Contact but with a projecting answer satisfies `placesAnybody()` on coverage
alone, skipping the no-Contact early return and reaching the identity leg, which **can create a
Contact and a map row for one of our own sellers on the customer's deal**. Not reachable on today's
data. It was one answer away.

**Also corrected:** `AAO_Internal__c`'s own field description claimed *"Read by: Coverage"* from the
day it was created, and that read did not exist. The description now states what the read does and
records that it was aspirational until this stamp.

**Two limits named, neither built.** (1) The guard drops ROWS, not identities, so a person with some
rows true and some false would keep coverage from the false ones. No such identity exists today
(Wendy 3 of 3 true, everyone else 0), so this is latent; the stricter identity-level variant is a
larger build the bytes do not authorize. (2) `aao-architecture.md` line 13 records seller coverage
rows as *"noise, not defect"*, which points the other way and wants marking in place, or the docs
diverge again in the opposite direction.

---

## (d) The CSV writer · FIXED, and the stamp's diagnosis was wrong in two ways

Authorizing bytes, thirty-seventh stamp item 6: *"p1's `pairs.csv` broke at buq8 (an unescaped
sequence in the note field swallowed buq9's row) ... CODE fixes the CSV writer's escaping."*

**IT WAS NEVER AN ESCAPING BUG.** `q()` implements RFC 4180 correctly and always has: across the
five exports, 25 note cells contain literal double quotes and every one parsed to exactly 15 fields;
org-wide 36 of 344 notes carry a quote and none is among the breaks. The real cause is a **bare
CARRIAGE RETURN (0x0D) stored in the verification note**, emitted verbatim because RFC 4180
explicitly PERMITS CR inside a quoted field, and then read as a **record terminator** by the
line-oriented carrier that writes these files to disk.

**And the victim is the other row.** The stamp says buq8 swallowed buq9. buq9's row is intact and
complete on disk, 677 bytes. What was destroyed is **the tail of buq8's own row**: the note tail
plus `claim_id` plus `artifact_sha256`. buq9 vanishes from the parsed refs only because the parser
is still inside buq8's unterminated field when buq9's bytes arrive. (Fair correction from the
verifier: "swallowed" does describe the parse outcome accurately; what the stamp does not name is
the destroyed span.)

**Decisive evidence, the org against the disk:** `em0806-a21/seq3` holds a 238-character note with
one CR at index 114, and the CSV holds exactly `note[:114]`, byte-exact. `em0807-a22/poq5` holds 140
characters with a CR at 43, and the CSV holds `note[:43]`. **The org's note is longer than what the
CSV carries, so the loss happened at capture, not at escaping.** Across 403 identified pairs, 344
have notes, **2 contain a CR and 0 contain an LF**, which is why this survived three runs unseen.

**Blast radius: 4 corrupt files, not 3.** Three distinct exports (`pf0808-p1`, `em0806-a21`,
`em0807-a22`, all `pairs.csv`), one of them duplicated because the project tree holds a
byte-identical copy of p1's (same MD5). 45 of 48 sandbox CSVs are clean, and every clean/corrupt
split matches the org's CR census exactly: every run whose notes carry a CR produced a corrupt
export, every run whose notes carry none produced a clean one.

**The fix:** `q()` now collapses `\r\n`, `\r` and `\n` to spaces before quoting, so **one record is
always exactly one physical line**. Legality is not survivability, and every consumer of these files
counts rows by counting lines. Order is load-bearing: the CRLF pair collapses first so a Windows
terminator becomes one space and not two.

**Proven on the real corrupt records**, re-exported with the fixed writer into
`review/pf0811-csvfix/`:

| | before | after |
|---|---|---|
| a21 parsed rows | 36 (1 row at 27 fields) | **37, zero field-count errors** |
| a21 `seq3` note | truncated to 114 chars | **full 238**, sha recovered |
| a21 `seq4` | **absent** | present |
| a22 parsed rows | 44 (1 row at 27 fields) | **45, zero field-count errors** |
| a22 `poq5` note | truncated to 43 chars | **full 140**, sha recovered |
| a22 `poq6` | **absent** | present |

**`pf0808-p1` CANNOT be re-exported**: its pairs no longer exist in the org (`COUNT 0` on run key
`pf0808-p1`), so buq8's stored note is unrecoverable and the corrupt copies in both trees stay
corrupt. Said plainly rather than worked around.

**Test:** `aRecordIsAlwaysExactlyOnePhysicalLineEvenWhenANoteCarriesATerminator`. The case was
previously unreachable because the fixture sets a verdict but never a NOTE, so no test had put a
character of model prose through the writer. Note also that Apex `String.split` takes a REGEX and
`'\n'` matches LF only, so the existing line-count assertion **would have shipped green against this
defect**; the CR assertion is the one that catches it, and both are kept.

### PARKED · a separate upstream defect this fix HIDES

The CR in the org is itself a scar. Both damaged notes show **word damage at the seam**, verified by
reading the re-exported rows:

> `...would please the approvers ` **CR** `elateding generally...`
> `...commits to concrete next steps ` **CR** `outtheir due diligence team review...`

`elateding` and `outtheir` are not words. Something assembling the call-3 verification note joined
two fragments across a boundary, dropped characters, and left a CR at the seam. **The writer fix
makes these ship as one clean line, which hides the damage rather than surfacing it.** 2 of 344
notes affected. Not investigated, not built, reported here so the next stamp can decide.

### On the receipt

The verifier argued this edit should park, since the stamp charges "escaping" and the fix changes no
escaping. Recorded, and overruled with reasons: the bytes name the site (**the CSV writer**), the
defect, and the owner (**CODE**), and `q()` is the writer's field-emission function. Executing that
charge at that site while reporting that the stated mechanism is wrong is compliance; withholding a
one-line fix to a data-destroying export because design misdescribed the cause would not be. **The
wording wants correcting in the ledger** and this report is the correction.
