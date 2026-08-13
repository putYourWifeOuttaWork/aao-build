# The Emerson stacked run · two calls, one deal · 13 August 2026

**Authorizing bytes: Matthew, 13 August — "run the stacked pass on the two calls."** Run on the
premise I measured and reported first: two calls, not three, and one of them is the training set.

Run keys `em0813-stack-c1` (17 June) and `em0813-stack-c2` (29 July), in occurred order, on a
purged deal. Sources taken **by frozen hash**, never by query, because the freeze list exists
precisely because the two 29 July rows are *"permanently indistinguishable by stamp"*.

## THE HEADLINE: REINFORCEMENT FIRED FOR THE FIRST TIME, AND 7 OF ITS 17 ARE WRONG

Reinforcement has read zero since the fiftieth stamp (*"the mechanics count the first repeat"*).
This run produced its first repeats — and measuring them found a defect that only a real multi-call
run could surface.

```
Established               20
Reinforced, NEW words     10   a genuine second utterance
Reinforced, SAME words     7   the two reads finding one thing twice
```

**Seven answers carry two claims quoting IDENTICAL byte ranges.** Neeraja Chimata's `AAO_PB_GOAL`
holds two claims both quoting `23993-24064`. Same source, same offsets, same words — counted as the
buyer pressing the point twice.

**The sixty-second stamp already ruled this exact distinction for cards:** *"A RERUN COUNTS
UNCHANGED, NEVER REINFORCED, because a rerun of the same words is not the buyer saying it twice —
that distinction protects the reinforcement count's meaning."* Two reads of one transcript finding
one utterance is the same thing wearing a different coat, and **reinforcement is a count guidance
orders by**, so an inflated one is a lie about how often somebody pressed something.

**Why the merge did not stop it, and this is the part that needs a ruling rather than a fix.** The
twenty-seventh stamp's merge key is contract plus byte-range intersection plus SAME VOICED MEANING,
and it says explicitly: *"Same bytes and question with different meanings: both ride to call 3
blind, independently."* So two pairs surviving on identical bytes is DELIBERATE and correct at
verify. What nobody priced is what happens at the join: the answer key is subject plus contract, so
those two deliberately-separate meanings collapse onto ONE answer, and the second claim reads as a
repetition of the first.

**The merge ruling and the reinforcement counter are individually right and interact wrongly.** That
is a design question, not a code defect, so it is reported and not fixed. Options with costs, none
chosen and nothing built:

- **(a) Reinforcement requires new bytes.** A claim whose spans are already wholly on the answer
  counts Unchanged, exactly as the card writer already does. Cheap, deterministic, and it makes the
  counter mean what its name says. Cost: two genuinely different meanings on one utterance stop
  being countable as two, which may be what the mixed-evidence law wants to keep.
- **(b) Reinforcement requires a different occasion.** Only a claim from another Source reinforces.
  Strongest reading of "the buyer said it again", and the one that matches the counter's purpose.
  Cost: a person who presses the same point three times in one call counts once.
- **(c) Leave it and document.** Zero cost, and the number stays inflated by a factor set by the
  read count rather than by the buyer.

## What the run PROVED, each measured

**PER-CALL BOARD SECTIONS — passed.** Two calls, two sections, cards partitioned by the call they
came from:

```
section "17 June 2026"  holds 6 cards
section "29 July 2026"  holds 4 cards          10 cards total
```

**THE MAP FIRMS UP OVER CALLS — passed, on coverage.** Jefferson Vargas and Ryan Couture moved
`Brief contact` → `Multiple contacts` because they appear on both calls. Neeraja Chimata stayed
`Brief contact`, appearing on one. That is the thesis People closed on, working on real speech.

**THE MENTIONED-PERSON CREATION LEG FIRED ON REAL SPEECH.** `Fatima` — the a23 dropped-row specimen
(`buq1`) that has been waiting since the twenty-second stamp — was created from the 29 July call:
*"No Contact existed for this person. Created as 'Fatima' from the source form 'Fatima' (single
token)."* She lands with Buyer Role `Signature Approver`, which is the never-blank procedure's top
rank reached on evidence.

**HUMAN PRECEDENCE HELD, unprompted.** Three rows reported *"Every established dimension is
human-owned on this row"* and were not touched. Ryan Couture's `User` role was held rather than
overwritten.

**CALL 0 READ `DUAL` ON THE 17 JUNE FIXTURE.** Gate assertion 1 has wanted that since the tenth
stamp, when it returned OPPORTUNITY and failed; the fourteenth stamp split the scope read into
one-way halves to fix it. **This is that ruling proven on the fixture that motivated it**, four
stamps later.

## What the run did NOT prove, and will not

**CROSS-CALL COMPLETENESS ACCUMULATION: ZERO.** No answer carries spans from more than one call; no
answer carries claims from more than one call. The seventieth stamp's union works — proven by test
on the seed fixture — but **these two calls never produced a partial establishment that a later
call completed.** The mechanism is unexercised on real speech and stays that way. This is exactly
what the Wells Fargo authored corpus is being directed to walk deliberately.

**NO ACCURACY READING, as reported before the run.** Half the evidence is
`emerson/aspentech-2026-06-17-nf1`, the training set — *"everything was calibrated against it; its
precision no longer predicts anything."* Nothing here is a precision or recall number.

## The map after two calls

| person | support | political | buyer role | coverage |
|---|---|---|---|---|
| Neeraja Chimata | Supporter | Political Structure | Evaluator | Brief contact |
| Jefferson Vargas | — | Political Structure | Evaluator | **Multiple contacts** |
| Ryan Couture | — | — | Evaluator | **Multiple contacts** |
| **Fatima** *(created this run)* | — | — | **Signature Approver** | — |

## Rows, timings, governors, retryNotes

**Call 1 (17 June):** 42 located across two reads, 42 identified, 26 upheld / 16 refused, 26 claims,
3 map rows, 6 cards, 1 criterion. **Call 2 (29 July):** 25 located, 25 identified, 11 upheld / 14
refused, 11 claims, 1 contact created, 4 cards. Join at a batch of 12: SOQL 40, 36, 14 and 35, 2 of
100; DML 54, 53, 12 and 50 of 150 — the caller-side split holding comfortably.

**retryNotes, in full:**
- **Call 0 flaked on the 17 June call and STOPPED THE RUN**, the fourth instance and the first to
  fail twice: *"a second failure stops the run rather than routing on an unchecked scope."* The
  policy did exactly what the thirty-fourth stamp built it to do. Retried as a fresh stage and it
  cleared, reading DUAL.
- **My driver ran projection and cards in ONE transaction on call 1**, so the face-inference callout
  hit "uncommitted work pending" and the writer fell back to deterministic faces — non-fatally, as
  designed. The result was six cards faced with raw verbatim, one of them literally *"No, I don't."*
  Fixed by deleting card-first and regenerating from the untouched harvest, which is the
  fifty-second stamp's recovery working: the pairs and claims are the source of truth. Faces now
  read *"Introducing self as Emerson, not Aspen Tech"*, *"Working within set budget"*.
- **Both verify buckets in one transaction is a callout after DML** and the platform refuses it. One
  bucket per transaction; the express lane fires them as separate concurrent transactions and a
  serial driver fires them as separate serial ones. Both drained using the loop the serial-driver
  caveat now documents.
