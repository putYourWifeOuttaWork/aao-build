# The clean re-run · results against predictions recorded before the purge

Predictions committed at `b2a2514`, **before a single row was deleted.** Scored honestly below,
including the three that failed.

| | |
|---|---|
| **Tree / org** | `/Users/thefinalmachine/Downloads/claude` on `main` · `00DWD00000DV7iT2AT` |
| **Runs** | `wf-s3` → `wf-s4` → `wf-s5`, occurred order, one purge before |

## THE HEADLINE · the key fix worked, and it was not sufficient

**A2 is live and every answer on the deal is keyed on the Contact:**

```
A2|Participant|003WD00001QZAwJYAX|<contract>   Tom Brzezinski   counter −1   ONE row
A2|Participant|003WD00001QZr0LYAT|<contract>   Katherine        counter  1
A2|Participant|003WD00001QZiGRYA1|<contract>   Rohan            counter  1
A2|Participant|003WD00001QZVZNYA5|<contract>   Meredith         counter  1
```

**Answers fell from 70 to 34. Every key is A2. Tom is one row, not two.** The per-call
fragmentation is gone.

**And the counter still did not accumulate.** Tom carries **three** sentiment claims on that one
row and reads **−1**.

```
SRC-00000045  2026-08-05  outcome = Established
SRC-00000039  2026-08-19  outcome = Reinforced
SRC-00000039  2026-08-19  outcome = Reinforced
```

**There is a SECOND, INDEPENDENT mechanism blocking accumulation, and the key fix could never
have reached it.** A claim confirming something already standing is written `Reinforced`, and
`AAO_Accumulate.movesTheAnswer` returns false for `Reinforced`, so it moves no counter. That is
the seventy-first stamp's ruled behaviour working exactly as written.

**This answers the ninety-fifth stamp's open question, and the answer is decisive rather than
encouraging: the counter cannot accumulate across calls, and fixing the key did not change that.**
A person who says a non-supportive thing on three separate calls scores −1, because calls two and
three are classified as confirming what already stands.

Worth noting against the eightieth stamp's own reasoning, which said the opposite would happen:
*"byte offsets are per-artifact, so claims from different calls never intersect and always
count."* They did not count. The intersection test is not what decided it — the
already-standing-verdict test was, and the two were never reconciled.

## THE SECOND FINDING · Priya produced 9 upheld pairs and ZERO claims

```
Priya's participant row      contact = null
pairs identified to her      16      (Upheld 9, Refused 7)
claims on the deal for her   0
Contacts named Natarajan     0
```

**Nine upheld establishments about a rostered person produced no claims at all**, so nothing
projected, so no Contact was created, so promotion had no target, so her flags stayed standing.
The whole chain failed at its first link and every downstream symptom follows from it.

**This is not promotion failing. Promotion was never reached.** I am not going to guess the cause
at the end of a long session; it is measured, named, and it is the first thing to diagnose next.

## SCORING THE PREDICTIONS

| # | Prediction | Result |
|---|---|---|
| 1 | Priya ends with ONE answer chain | **FAILED** — she has none. 9 upheld pairs, 0 claims |
| 2 | Her flags CLEARED by identification | **FAILED** — all three still Standing |
| 3 | Both shadows promoted | **FAILED** — 0 promoted; no Contact existed to promote to |
| 4 | Tom at −2 on ONE row | **HALF** — **one row, confirmed**; value is −1, not −2 |
| 5 | The accumulation question gets its evidence | **MET, and the evidence is negative** |
| 6 | Card faces inferred, no 400 | **HALF — and the half that moved is the important one** |
| 7 | Answers fall to 45–55 | **BEAT — 34.** Larger collapse than predicted |
| 8 | Rohan or Alison exceeds +1 | **FAILED** — both unchanged, and finding 1 explains why |
| 9 | Bettina's flag stays Standing | **MET** — promotion correctly left her alone |
| 10 | Join inside `C + 9`, SOQL under 100 | **MET** — 39/31/? DML, SOQL 78 / 62 |

**Three failed, and all three trace to the single unexplained defect above.** I am reporting that
rather than presenting seven-of-ten as a pass.

### On prediction 6, precisely

The duplicate-ref 400 is **gone** — the root cause was real and the fix removed it. s5 now fails
with a **different** error:

```
400 — The compiled grammar is too large, which would cause performance issues.
      Simplify your tool schemas or reduce the number of strict tools.
request_id req_011Ce5Dd9Vo7oWMk269xo4A1
```

**That is the thirty-fourth stamp's known keyed-grammar ceiling**, and the card-face call is the
one keyed call that never got a shard cap. It was invisible while the duplicate-ref error fired
first. **The fix was correct and revealed the constraint underneath it** — s3 and s4 inferred
their faces cleanly, and only s5's larger set crosses the grammar limit.

**The remedy already exists and is ruled:** `keyedShardCount`, which the thirty-fifth stamp
extended to every keyed strict schema for exactly this reason. The card-face call needs the same
treatment. **Not built — it is a new build and this run is the verification, not the place for it.**

## THE RUN

| | s3 | s4 | s5 |
|---|---|---|---|
| call 0 | 10,179 ms DUAL | 12,662 ms DUAL | 6,121 ms DUAL |
| reads | 37,824 / 65,498 | 35,325 / 43,227 | 51,187 / 44,985 |
| call 2a | 356 ms, remainder 2 | 369 ms, remainder 3 | 289 ms, **remainder 0** |
| call 2b | 1 request | 2 requests | not fired |
| call 3 | 66,443 ms · 29 upheld / 21 refused | 79,062 ms · 23 / 24 | 82,566 ms · 39 / 29 |
| **join DML** | **39 / 150** | **31 / 150** | — |
| join SOQL | 78 / 100 | 62 / 100 | — |
| projection | 6 created | 1 populated | 16 unchanged |
| cards | 6 created | 10 created, 6 unchanged | 13 created, 16 unchanged |

**Worst callout 82,566 ms against the 120,000 ceiling — 69%.** Deal totals: **51 claims,
34 answers, 29 cards, 6 map rows, all keys A2.**

**Coverage held**: five people at `Multiple contacts`, Jared at `Brief contact`. **Cards deduped
across calls** — 6 unchanged at s4, 16 at s5 — so the dedup discipline survived the key change.

## A PROTOCOL GAP, found while purging

**`AAO_Purge` covers pairs, claims, answers, candidates, receipts, map rows and Contacts — but
not cards, not shadows, not flags.** 28 cards, 3 shadows and 3 flags survived a full purge.

Cards were then deleted by hand, card-first so the junctions cascaded, per the fifty-second
stamp's incident and the seventy-third's precedent — a standing card reports `unchanged` and
would have hidden the card-face fix entirely.

**Shadows and flags were deliberately left standing, and that was the better choice**: they are
the exact rows that failed to promote and failed to clear on the first stack, so the re-run tested
promotion against the real specimens rather than fresh ones. A non-synthetic flag is undeletable
by law in any case.

**The protocol should name all three. Reported, not changed.**

## retryNotes

Call 0 succeeded first try on all three sessions — no flake this run, the first time that has
happened across six sessions. Call 3 took one invocation on each. Nothing was re-run to get a
better number, and no number here was tuned toward any expectation.
