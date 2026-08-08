# The zero-creation number, produced by the ladder · a23's seven dropped rows

**CODE, 8 August. Reported against the twenty-second stamp's item 3 table so the two can
disagree in public, which they do.**

The resolver service (`AAO_ResolveDesignator`) is built, deterministic, tested at 7/7, and
**not wired into the pass**: the twenty-first stamp made a name-based internal check a
precondition of the mentioned-person path and it is not built, so nothing calls this from a live
run. The number below was produced by invoking the real ladder with the real designators against
the real account, which is the number without the risk.

## The result

| rows | designator | design's table said | the ladder says | why |
|---|---|---|---|---|
| buq1 | "Fatima" | **Yes.** The one clean case. | **ZERO** | the transcript says *Fatima*; the Contact is **Fatema** |
| buq2 | "Pat" | Must be refused, never mapped | **ZERO** | no Contact by that name exists on Emerson at all |
| buq3, poq10 | "CFO" | No. Needs a role lookup. | **ZERO** | the lookup is now built; **the account has no CFO on file** |
| buq4, poq9, buq5 | "he", "she" | No. Needs referent resolution. | **PENDING** | call 1's designator emission is not built |

**Zero of seven resolve with zero creation today.** Design's revised expectation was one of
seven; the original was most of seven. Both are wrong, and the one clean case is the one that
fails most interestingly.

## buq1 · the ASR hazard is not hypothetical and it is already in this org

The twenty-first stamp named the hazard with an invented example: *"Fatema Choudray" and "Fatima
Chowdhury" are one human and two Contacts.* Reading the org to find out why buq1 missed:

| Id | name | title | account |
|---|---|---|---|
| `003WD00001PsSLIYA3` | **Fatema Choudray** | VP, Premier Sales Performance | Emerson Electric Co. |
| `003WD00001PsSK8YAN` | **Fatema Choudhury** | Dir World Wide Sales Operations | Aspen Technology |

**The hazard's own illustration is two real rows in this sandbox, on two different accounts.**
The transcript then adds a third spelling: the speaker said, or the transcriber heard, *Fatima*.

Two things follow, and they pull in opposite directions:

- **Exact matching resolves nothing here.** One character between *Fatima* and *Fatema* is the
  whole distance between the ruled outcome (Fatema on the map) and silence. **"Match
  aggressively, create conservatively" is not advice on this fixture, it is the difference
  between the widening working and the widening doing nothing at all.**
- **And the account bound is doing real work already.** A fuzzy match unscoped would have two
  Fatemas to choose between and would have to refuse; scoped to Emerson there is exactly one, so
  aggressive matching is *safe here precisely because* the scope is narrow. The two rungs are
  not independent knobs.

**What I am not doing:** adding fuzzy matching on my own. It is the single highest-risk change in
this path — it is how one human becomes two Contacts once creation is live — and it deserves its
own proposal with the match rule written down, not a quiet edit to a ladder rung. Named here as
the next decision rather than taken.

## buq2 · Pat is refused, and by absence rather than by the guard

Pat resolves to ZERO because **no Contact of that name exists on Emerson**, which is the right
outcome and is not the guard working. The name-based internal check was never reached.

**The distinction matters for the acceptance case.** buq2's standing requirement is *a run that
puts Pat on Emerson's buying committee has failed*. Today it passes for an accidental reason: the
data does not contain her. The moment fuzzy matching lands, or Pat acquires a Contact anywhere
the ladder can see, the accident stops protecting us. **buq2 is not yet evidence that the gate
works; it is evidence that it has not been tested.**

## buq3, poq10 · the title rung works and the account has no CFO

Zero Contacts on Emerson Electric carry a title canonicalising to *chief financial officer* —
zero carry any title containing "Financial". The rung ran both its legs (account contacts, then
contacts on the account's and opportunity's map rows) and found nothing to match.

**So this is a data answer rather than a mechanism answer**, and it is the answer the ruling
wanted the rung to be able to give: held with its reason, never guessed. The rung is exercised
and correct; a CFO on the account would link. Priya Natarajan on the WF-OpenText fixture is the
next live test of it, per the twentieth stamp.

## What is built, and what deliberately is not

**Built and tested:** the resolution half of call 0 as a callable service, with the name rungs,
the title rung and its deterministic synonym list, the ladder's three outcomes, and every rung
journalled whether it answered or not so a ladder can be told from a loop. It never creates and
never picks.

**One correction worth keeping, found by a red test.** `AAO_PersonName.parse` reads a single
token as a **surname**, which is right for the input it was built for: a roster string like
`Vargas, Jefferson [EMR/CSS/AT/MEDI]` is some system's record and its bare token is a family
name. A **mentioned** name inverts that: in speech a lone token is usually a given name, and
a23's span is exactly `Fatima`. Same parser, different class of input, opposite reading. **That
is the tuned-behaviour law in miniature**, and the rung now searches a single token as either
given or family name, account-bound, never picking.

**Not built, deliberately:**

- **The wiring into the pass.** The internal check is a precondition and this is that path.
- **Call 1's designator emission with quoted antecedents**, which the three pronoun rows need.
- **The synonym list's seed-metadata home**, owed at packaging and named rather than assumed,
  alongside the internal-domain list's home which is already a standing debt.

## What this changes for the queue

Nothing reorders, but one thing sharpens: **the widening cannot deliver Fatema to the map on
exact matching, so the fuzzy-match rule is now on the critical path to the ruled outcome rather
than being a refinement of it.** Presence is the acceptance criterion Matthew set. Exact matching
gets zero of seven.
