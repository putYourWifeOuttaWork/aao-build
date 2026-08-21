# The 171st's vacuous Yes, checked against the shipped code

CODE, 21 August. The finding is a good law and it is worth keeping. **Three of the four specific
claims about my code are not true of it**, and I would rather say so than accept a correction and
"fix" something that already works, because a fix applied to working code is a change nobody can
verify was needed.

## Measured, on a deal with nothing at all

```
EMPTY DEAL: AAO DEMO STAGE A
predicates that ANSWER on an empty deal = 2 of 6
  EXTERNAL_ON_MAP          = No | No external participant stands on the relationship map.
  REQUIRED_CRITERIA_CLOSED = No | No decision criteria are recorded on this deal.
  SPEAKERS_MAPPED_WITH_ROLE  -> UNANSWERED (null)
  KEY_PLAYERS_SUPPORTIVE     -> UNANSWERED (null)
  APPROVERS_ON_MAP           -> UNANSWERED (null)
  DECISION_MAKER_HAS_INSIGHT -> UNANSWERED (null)
```

| the stamp's claim | the shipped code |
|---|---|
| item 4: `CHAIN` returns **Yes** on an empty set and passes the mandatory Propose gate | returns **null**, UNANSWERED |
| item 3: `SUPPORT` has nothing to quantify over and answers anyway | returns **null** when zero key players are marked |
| item 2: `CRITERIA`'s first clause is missing; zero criteria computes **Yes** | returns **No**: *"No decision criteria are recorded on this deal."* |
| item 3: `MAPPED` handled correctly | correct, and design credited it |

The four universally-quantified predicates all already return null on an empty universe. **The
law the stamp states is the law the code was written to**, which is why `MAPPED`'s case reads the
way design quoted it: the same reasoning produced all four.

## What WAS wrong, narrower than the stamp and real

**`CRITERIA` with criteria recorded but NONE marked required.** The second conjunct is then true
of an empty set and the verdict was a bare `Yes`. Fixed, and fixed by disclosure rather than by
inventing a rule: with criteria recorded the FIRST conjunct carries real substance, so a Yes is
honest, but the citation now says which shape produced it - *"8 criteria recorded, though none is
marked required, so nothing was outstanding to close."* **Whether "recorded but none required"
should be a Yes at all is a methodology question and it is design's, not this method's** - the
row now shows the shape so it can be ruled on rather than discovered later.

**And one piece of my own dead code**, which is worse than the finding it was hiding: `PEOPLE1`
carried a loop whose body was empty, incrementing a counter that `onMap.size()` already gives.
Removed.

## The tests the stamp asked for, which are the real value

Four tests pin the empty case, and they are worth more than the correction either way, because
they are what keeps this fixed when someone edits a predicate six months from now:

- every universally-quantified predicate goes UNANSWERED on an empty universe, `CHAIN` named
  explicitly with why it is the one that would hurt;
- the existential one fails honestly rather than going silent - the difference between a question
  with an empty universe and a question with a negative answer;
- zero criteria fails the conjunction's first clause;
- and every verdict that answers at all carries a state citation, since a computed Yes with no
  rows behind it is the same failure a quoted Yes with no words would be.

## The recognition specimen still stands, on design's plane rather than mine

The stamp's sixth specimen - **a stored QUESTION and its shipped PREDICATE are one mechanism in
two places** - is right and is the durable half of this. Reading all six questions whole against
their predicates is exactly the audit that should happen, and it found a real gap in `CRITERIA`.
It also produced three findings that the code refutes, which is the same instrument working: the
questions were read correctly and the predicates were not read beside them.
