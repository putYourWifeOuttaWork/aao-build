# The two-clean-runs gate · v0.1's definition of done

Authorized by the hundred-twenty-fourth stamp, item 1: *"purge the demo deal, run the three
Brightwell calls end-to-end unattended, twice, zero error legs - the whole spine (R3 finalizers,
R5 lease, R1 caps, supersession, read-before-write) on one live chain for the first time."*

| | |
|---|---|
| **Tree / org** | `/Users/thefinalmachine/Downloads/claude` on `main` · `00DWD00000DV7iT2AT` |
| **Vehicle** | `AAO DEMO REHEARSAL DEAL` `006WD00000TrFg9YAF`, the Brightwell three. Wells Fargo never touched. |
| **Driver** | `AAO_PassQueueable`, unattended. All three calls enqueued at once; nothing hand-driven. |
| **Config** | `AAO_Timeout_Ms__c` set to 95,000 at this stamp's nod, from 120,000. |
| **Rows** | `runA-pairs.csv` · `runA-claims.csv` · `runA-answers.csv` · `runA-projection.csv` · `runA-timings.txt` (same for B) |

---

## THE FAILED ATTEMPT, FIRST, because a gate that only reports its successes is not a gate

The first launch died on all three calls at once, at `call 0 resolve`:

```
System.CalloutException: You have uncommitted work pending.
Please commit or rollback before calling out
```

**R5's lease does DML, and every stage behind it makes a callout.** Apex forbids that ordering,
and R5 was built, tested and ratified without ever standing in front of a callout - **because a
unit test never makes one.** That is the capability law turned on our own code: a mechanism is
unverified until tried from the runtime that will exercise it, and the unit suite is not that
runtime when the runtime's constraint IS the callout.

Fixed by giving the acquire a transaction of its own: the entry transaction takes the lease and
does nothing else; the stage runs in the next one, clean. That is the same one-thing-per-
transaction shape the chain already had, extended by one link. **The failed attempt was purged and
does not count as a run**, which is the 124th's prescribed shape: error leg, failed run, class
fixed, retry.

**The gate found this on its first contact with a live chain, which is exactly what it is for.**

---

## RUN A · three calls, unattended, zero error legs

```
gateA-c3   8 stages   113,644 ms wall   worst callout 36,650 ms   5 callouts   WARM
gateA-c1   8 stages   118,904 ms wall   worst callout 34,036 ms   5 callouts   WARM
gateA-c2   7 stages   143,421 ms wall   worst callout 36,035 ms   4 callouts   WARM
```

`gateA-c2` shows seven stages rather than eight because **the model leg legitimately did not
fire** - the deterministic resolution pass left no remainder, and a stage that lawfully does
nothing journals nothing. That is the driver's guard behaving as built, not a missing stage.

### Acceptance, every bar the stamp set

```
error legs                          0     (bar: 0)
self-marked callouts past budget    0
lease rows anywhere in the org      0     (bar: 0 - no wedge, no residue)
ingest failure receipts             0
one-for-one                      HELD    for c1, c2 and c3 independently
```

### The one-for-one story in full, because "HELD" alone is not an account

```
121 identified pairs
 74 carrying disposition Identified   ->  all 74 verified, none left behind
 47 unverified  =  45 Merged (the two-read merge collapsing duplicates)
                 +  2 Held  (identity unresolved, the lawful hold)
 53 upheld  ->  52 claims written
  1 upheld with NO claim: gateA-c1 r1q12 AAO_POL_PS2, subject Sam Ruiz
```

Sam Ruiz is `sam.ruiz@altify.com`, `AAO_Internal__c = true`. **That is the internal-subject gate
refusing our own seller at the join** - the forty-eighth stamp's ruling, doing its job on a live
run. A seller cannot be a member of the buying committee by construction, and the refusal is why
53 upheld and 52 claims is the correct pair of numbers rather than a discrepancy.

### The map accrued, which is the thesis rather than a statistic

```
52 claims · 43 answers (41 live, 2 superseded) · 16 cards · 6 map rows

Karen Lindqvist  Decision Maker · Inner Circle        · Supporter · Multiple contacts
Raj Patel        Evaluator      · Political Structure · Supporter · Multiple contacts
Marcus Reyes     Evaluator                            · Supporter · Multiple contacts
Dana Okafor                                           · Supporter · Multiple contacts
Tomas Reyes      Approver                             · Supporter · Brief contact
Priya Nair       Evaluator                            · Supporter · Brief contact
```

Coverage discriminates: `Multiple contacts` for the people who appear on more than one call,
`Brief contact` for those who appear on one. **That is the accrual the product is sold on,
measured rather than asserted.**

**AND THE CLASS-A CURE FIRED ON A LIVE RUN FOR THE FIRST TIME.** Two answers carry
`AAO_Superseded_By__c`, both participant-keyed rows pointing at their Contact-keyed canonical:

```
ANS-00000711  A2|Participant|a1ZWD000002bnYY2AY|...  ->  a1SWD000005uLof2AE
ANS-00000713  A2|Participant|a1ZWD000002bnYY2AY|...  ->  a1SWD000005uLod2AE
```

Every one of the 43 answers reads TRUE and MACHINE. Outside STAGE B's rehearsal, this is the
supersession mechanism's first appearance on a real accruing deal - the person gained a Contact
mid-life and the ledger reconciled around it rather than fragmenting.

### Timings and governors, per the standing obligations

Worst single callout across run A: **36,650 ms**, which is **31% of the 120,000 ms ceiling** the
obligations name, and **42% of the measured ~88,000 ms gateway wall** that R1 established as the
one that actually fails. No callout reached the 66,000 ms budget, so no leg self-marked.

Governor peaks across all 23 legs of run A:

```
SOQL   60 / 200    (join, gateA-c2)
DML    28 / 150    (join, gateA-c2)
CPU  1,177 / 60,000 (cards, gateA-c1)
```

Nothing approached 80% of any ceiling. The join's SOQL peak of 60 against the `2.33·C + 9` model
at C = 20 predicts 55.6 - close, and the split never needed to fire at this corpus size.

Per-stage walls are in `runA-timings.txt`, one line per leg with its own governor consumption.

---

## RUN B · the second consecutive, three calls, unattended, zero error legs

```
gateB-c1   7 stages   105,425 ms wall   worst callout 26,729 ms   4 callouts   WARM
gateB-c2   7 stages   112,666 ms wall   worst callout 33,506 ms   4 callouts   WARM
gateB-c3   7 stages   116,867 ms wall   worst callout 33,048 ms   4 callouts   WARM
```

All three at seven stages: the model leg did not fire on any call this time, the deterministic
resolution pass having left no remainder. Lawful, and journalled as nothing rather than as a
skipped stage.

```
error legs                          0     (bar: 0)
self-marked callouts past budget    0
lease rows anywhere in the org      0     (bar: 0)
ingest failure receipts             0
one-for-one                      HELD    for c1, c2 and c3 independently
```

```
 98 identified pairs
 69 disposition Identified  ->  all 69 verified
 29 unverified  =  29 Merged, and no Held at all this run
 50 upheld      ->  50 claims.  Nothing refused at the join, so upheld and claims are equal.
 42 answers (40 live, 2 superseded) · 14 cards · 6 map rows
```

**Run B drained in perfect occurred order — c1, then c2, then c3** — where run A's first
acquisition fell to c3. Same code, different race. That is the finding in item 3 below, visible
as the difference between two runs of one spine.

---

## THE VERDICT · TWO CONSECUTIVE CLEAN RUNS. THE GATE CLOSES.

Every bar the hundred-fifteenth set and the hundred-twenty-fourth authorized:

| bar | run A | run B |
|---|---|---|
| zero error legs | **0** | **0** |
| zero lease residue (no wedge) | **0** | **0** |
| one-for-one held at every stage | **HELD ×3** | **HELD ×3** |
| the map accrued | 6 rows, coverage discriminating | 6 rows, coverage discriminating |
| unattended, end to end through the driver | yes | yes |

**Replay byte-equality is NOT asserted here and is not claimed.** That is R6, which the
hundred-nineteenth slid behind Process; the gate's other bars stand on their own and this one is
named as absent rather than quietly dropped.

**THE WHOLE SPINE RAN TOGETHER FOR THE FIRST TIME:** R3's finalizers attached on every stage,
R5's lease serialising three calls on one deal and draining by the conversation's clock, R1's
caps holding every callout to a third of the wall that actually fails, supersession reconciling
two person-key migrations per run, and read-before-write underneath all of it.

---

## WHAT THE TWO RUNS DISAGREE ABOUT, reported rather than smoothed

Identical bytes, identical code, and the map is not identical:

```
                  RUN A                         RUN B
Karen Lindqvist   Decision Maker                Signature Approver
Marcus Reyes      Supporter                     Neutral
Raj Patel         Political Structure           (none)
Dana Okafor       (no role)                     Evaluator
claims / cards    52 / 16                       50 / 14
```

**This is the accepted flicker, not a gate failure.** Matthew closed People on exactly this at the
fifty-seventh stamp - reads carry recall variance, verify carries judgment variance, real maps
accrue over many calls, values never overwrite with blanks, and a human edit beats the machine
forever. The gate's bars are about error legs, one-for-one, residue and accrual; none of them is a
determinism claim, and the flicker measured here is the same shape the stability probe measured in
August.

Two things about it are worth carrying forward rather than filing:

- **Run B's `Dana Okafor` gained an Evaluator role that run A never wrote**, and run A's
  `Raj Patel` carried a political value run B did not. Values move in both directions across runs,
  which is what "never overwrite with a blank" is protecting against on a real accruing deal.
- **Karen moving Decision Maker to Signature Approver is a BUYER-ROLE LADDER difference**, not a
  presence one. The seventy-sixth stamp's ladder ranks Signature Approver above Decision Maker, so
  run B read her one rung higher on the same words. That is the ladder doing its job on different
  evidence, and it is the sharpest specimen the two runs produced for the CARD-1 style row pass.

---

## AND THE ONE DEFECT THE GATE FOUND, which is the gate paying for itself

Recorded at the top of this report and repeated here because it is the headline: **R5's lease did
DML in front of every callout**, and no unit test could see it. The gate found it on first contact,
the class was fixed, the failed attempt was purged, and the two runs above are on the fixed code -
one spine, twice, exactly as the hundred-twenty-fifth requires.
