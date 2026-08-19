# The acquisition door · first acquisition obeys the same law as the drain

The hundred-twenty-fifth's item 3, ruled after the gate and before Process's card writer:
*"at acquisition on an idle deal, the winner reads the enrolled-waiting set and YIELDS to any
earlier-occurred conversation - **re-enqueue, not proceed** - so first acquisition obeys the same
law as the drain."*

| | |
|---|---|
| **Tree / org** | `/Users/thefinalmachine/Downloads/claude` on `main` · `00DWD00000DV7iT2AT` |
| **Vehicle** | the rehearsal deal, three Brightwell calls, enqueued NEWEST-FIRST every time |

## The specimen the gate produced

Two runs of one spine, identical bytes and identical code, disagreeing about who went first:

```
RUN A   enqueued c3, c2, c1   ->   ran c3 first    (arbitrary winner)
RUN B   enqueued c3, c2, c1   ->   ran c1 first    (arbitrary winner, landed right)
```

**The queue was always ordered; the first acquisition never was.** Answers are safe regardless -
replay orders claims by evidence-occurred, so standing state is order-independent - and the
confirmation counts stay right, being arithmetic over the trail. What changed at the
hundred-twenty-fourth is that **the STANDING CARD became the match target**, so write order now
decides which establishment is the ORIGINAL and which the reinforcement, and a later call writing
first misorders provenance in a way no arithmetic repairs.

## MY FIRST FIX FAILED ITS OWN PROOF, and the failure is the useful part

I implemented the rule as written minus one word: the winner read the enrolled-waiting set and
yielded to any earlier conversation. Then I ran the targeted proof - three sources, newest first,
idle deal - and got:

```
receipts in first-stage order:  yield-c3 -> yield-c1 -> yield-c2
```

**Call 3 went first, exactly as before the fix.** Three calls arriving together enter in three
CONCURRENT transactions; the winner's acquire commits before the losers' WAIT rows do, so a winner
that reads the waiting set immediately reads an EMPTY one and yields to nobody.

The word I skipped was design's own: **"re-enqueue, not proceed."** The re-enqueue is the
load-bearing half. The winner now spends one transaction doing nothing at all - no callout, no
model tokens, no DML - purely so concurrent arrivals have a transaction in which to enrol, and
asks afterwards.

Note the shape of that run's order, because it is the whole diagnosis in one line: `c3` first
(unordered acquisition), then `c1` before `c2` (correctly ordered drain). The two halves of the
mechanism, one working and one not, in the same run.

## The proof, after the settle · PASSED

Same launch, same newest-first order, on the fixed code, run end to end:

```
enqueued:  yield2-c3 (19:32), yield2-c2 (19:09), yield2-c1 (18:24)
first holder: yield2-c1     <- the EARLIEST conversation, with no receipt yet:
                               the yield happened before anything was spent
final order:  yield2-c1 -> yield2-c2 -> yield2-c3
lease rows after drain: 0
```

**Enqueued newest-first, ran oldest-first, and the winner gave way before it made a single
callout.** That is the ordering law reaching the one door it did not cover, and both halves of the
hundred-twenty-sixth's acceptance - earliest-occurred runs first, zero residue - are met.

### The run carried one error leg, and it is not this fix

`yield2-c3` stopped at its first stage:

```
AAO_Pass.PassException: Call 0 failed the quote law twice ... One retry is the policy
(thirty-fourth stamp); a second failure stops the run rather than routing on an unchecked scope.
Last: Call 0 answered yes to OPPORTUNITY content and quoted nothing.
```

**That is the known call-0 cold-flake**, and the pass refusing to route on an unchecked scope is
the thirty-fourth stamp's retry policy behaving exactly as ruled - the same class the eightieth
stamp recorded stopping a run. It is reported rather than filed away, because a proof run that
carried an error leg has to say so even when the leg belongs to another class.

**And it proved something the two clean gate runs could not.** A genuine mid-run stop exercised the
release path for the first time: the failure was journalled to the receipt AND the lease was
handed back, leaving zero residue. R3 and R5 doing their jobs on a real failure rather than on a
probe - which is the one thing a clean run can never demonstrate.

## WHAT THIS IS NOT, stated so nobody reads it as more than it is

**It is ordering, not a lock.** Two runs entering the exact same instant can still land
arbitrarily; the settle narrows that window by a full transaction rather than sealing it. Sealing
it needs `FOR UPDATE`, which the hundred-twenty-fourth refused in plain words - *"row lock errors
are serious problems"* - so best-effort ordering with no lock is the ruled shape and not a
shortfall. The honest guarantee is: **arrivals separated by more than one transaction are ordered;
truly simultaneous arrivals are narrowed, not eliminated.** Real ingest arrives seconds to hours
apart, and the burst is the artificial case this proof deliberately manufactures.

And a bounded escape hatch is kept deliberately: if no queueable slot exists to settle with, the
run proceeds unordered rather than not running at all. A deal that stops adjudicating is worse
than a board whose write order is imperfect, and the ledger's replay is order-independent either
way.

## One operational fact the org taught

**A queueable class cannot be redeployed while its own jobs are in flight.** The settle fix was
refused mid-run:

```
This Apex class has asynchronous Apex jobs pending or in progress; AsyncApexJob ID(s): 707WD0000A9SI1f
```

So a fix to the driver waits for the chain to drain. Worth knowing before a production incident
makes it a surprise.
