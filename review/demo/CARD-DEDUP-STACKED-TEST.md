# The stacked-write card-dedup test · it ran, and layer 2 did not fire

Owed since the hundred-fifth stamp, offered opportunistically by the hundred-seventh's item 4.
Run on the demo harness deal — **never on Wells Fargo** — through the on-record surface, which is
the first time the harness has paid for itself.

## The test

The empty-board rebuild could not measure this: every card met an empty board, so layer 2 had
nothing to compare against. **This is the shape that measures it** — a second call whose cards
meet a STANDING board, carrying one restatement and one genuinely new insight as its control.

**Board before:** one card, `[Obstacle] 6 hrs/week chasing prior approvals`, from call 1's
*"our team loses about six hours a week chasing down prior approvals"*.

**Call 2 said, in deliberately different words:** *"The sign-off chase is still swallowing the best
part of a working day every single week for my people."* Same person, same type, same problem, no
shared phrasing. Plus a genuine new one: a four-week security review.

## The result · NEGATIVE, and the control passed

```
[Obstacle] 6 hrs/week chasing prior approvals          created 12:51:23   (call 1)
[Obstacle] Sign-off chase: ~1 day/week, no change      created 13:31:14   ← DUPLICATE
[Obstacle] Security review: 4 weeks for customer data  created 13:31:14   ← correct, new
```

**The restatement created a second card rather than reinforcing the first.** No count was prepended
to the parent, which is what a reinforcement would have written. **The control worked**: the
genuinely new obstacle created correctly, so the writer is discriminating rather than blindly
creating.

## THE CAUSE IS NOT A BUG, AND THE CODE SAYS SO ITSELF

`AAO_Cards.meaningKey` is **type plus the normalised face string** — case and inner spacing
normalised, nothing else. Its own comment states the choice and the reason:

> *"Completely different language is a different insight" was ruled, so this deliberately does NOT
> try to detect paraphrase: a writer that guessed at sameness would silently merge two things a
> person said.*

So **layer 2 catches an IDENTICAL face and nothing else.** Two faces carrying one meaning in
different words produce different keys and can never collapse.

**And that leaves the ratified Problems draft's own law unimplemented:** *"the same problem
restated in new words is reinforcement, not a new card."* The implementation refuses exactly the
detection that law requires, for a reason that is itself sound.

**This is a law-versus-implementation divergence of the class the eighty-first stamp named** —
after the coverage-Internal flag, the model-separation guard and `AAO_Resolve`. It differs from
those in one respect worth crediting: **it is not silent.** The code documents the narrowing at the
point of the decision. But the draft's prose and the writer's behaviour still say different things,
and the eighty-first's rule stands: **the path comes back to the law or the law is re-ruled in the
open.**

## Options, with costs · NONE CHOSEN, NOTHING BUILT

Design's ruling, not mine. Each is a change to what a seller sees on a board.

**(a) Rule the current behaviour correct and amend the draft.** Zero build. The board carries one
card per distinct phrasing, and a person who says the same thing on three calls gets three cards.
Cost: the reinforcement mechanic stays unexercised on restatements, which is most of what
reinforcement was for, and the count a seller reads understates nothing but the board grows with
repetition.

**(b) Compare meanings with a model call at write time.** The card writer already makes one
(`AAO_CardFace`), so the shape exists and the marginal cost is a field on that call rather than a
new callout. Cost: it is exactly the guessed sameness the current comment refuses, and a wrong
merge destroys one of two things a person actually said — irreversibly, on a customer's board.
Mitigation available: merge only where the model asserts sameness AND the two cards share a
subject and type, with the refusal reported rather than silent.

**(c) Deterministic near-match on the face** (shared significant terms above a threshold). No
callout, cheap, and it would have caught this specimen (`chase`, `week`). Cost: a threshold is a
tuning knob on a customer-visible surface, and the eightieth stamp already refused arithmetic
standing in for judgement once.

**Design's own precedent leans against (c) and toward a guarded (b):** the sixty-first stamp built
layer 1 *beneath* layer 2 precisely so the meaning layer would survive, and called replacing it
with byte identity a silent retirement of the reinforcement mechanic. Layer 2 as string equality is
that retirement arriving by a different route.

## What the harness proved beside the test

**This ran entirely through the on-record demo surface** — two pastes, no shell driving, no CODE in
the loop. The second run journalled 8 stages and finished; the ledger read located 7, identified 7,
upheld 3, refused 2, claims 5, answers 3.

**Nothing tuned. Nothing graded by CODE. Wells Fargo untouched.**
