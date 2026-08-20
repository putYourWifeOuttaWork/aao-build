# Fix two's diagnosis: the answer key omits the opportunity

CODE, 20 August. The 153rd asked two questions before anything is built. Both answered from the
org and the executable text. **The hypothesis is refuted and the real cause is worse.**

## The hypothesis is impossible, and one date settles it

The 153rd's leading hypothesis: a stray 14:59 run read deal 1's source while TARGETING deal 2,
so the claim writer stamped from the source and the answer writer from the run target, and they
split. That cannot have happened:

```
DEAL 2 created                              = 15:17:30
ANS-00000855 created 14:59:09, lastModified = 19:41:25
deal2 answers created BEFORE deal2 existed  = 13
```

**Deal 2 did not exist at 14:59.** No run could have targeted it. All thirteen answers were
created eighteen minutes before their current parent existed, and were last modified at 19:41,
inside the 19:40 rehearsal run's window.

So the rows were never WRITTEN split. They were written whole on deal 1, and later **re-parented
onto deal 2**, leaving their claims behind. That is the same visible symptom with the opposite
mechanism, and the hash-collision question is moot: the source resolver never chose anything.

For completeness, the resolver was read anyway. `d2` in that run's ladder is
`AAO DEMO REHEARSAL DEAL` (deal 1), the source's own deal, because handles are ordered by
`CreatedDate` and deal 2 is `d6`. Call 0 resolved correctly.

## What re-parents an answer: the key

`AAO_AnswerKey.compose`, quoted whole:

```apex
return VERSION + SEP + subjectType + SEP + String.valueOf(subjectId) + SEP +
    String.valueOf(contractId);
```

**There is no opportunity in it.** For `subjectType = 'Opportunity'` the subject IS the deal, so
the key is deal-scoped by accident of its subject. For every PERSON subject it is not, and the
subject resolved is not even the participant row:

```
ANS key = A2|Participant|003WD00001Rkp7wYAB|a1WWD000002p26v2AA
```

That `003` is a **Contact**. The participant row for the same person is `a1ZWD000002bnBv2AI`.
So a `Participant` answer keys on the CONTACT, which is account-level and shared by every deal
on the account.

**The collision therefore does not duplicate, it TAKES OVER.** The key is unique, so a second
deal's run composing the same key finds deal 1's existing row and UPDATES it: the answer's
`AAO_Opportunity__c` moves to deal 2, and the claim that established it stays on deal 1, because
claims are not keyed this way. Every one of the thirteen is subject type `Participant`; so are
the four answers genuinely born on deal 2.

Traced end to end on one row: the participant behind `ANS-00000855` is **Raj Patel, belonging to
deal 1 and source SRC-00000057**, while the answer now sits on deal 2.

## Why this is worse than a stray run, stated plainly

A stray run is a sandbox accident. This is a rule of the ledger's identity. **Two open deals on
one account, a contact who appears on both, and the same contract, cannot hold separate answers
at all** - the second deal's establishment silently steals the first deal's row rather than
recording its own. The first deal keeps its claim and loses its answer, which is exactly the
state the 153rd found and correctly called nonsensical.

That is a data-loss defect in the core ledger, and it does not need two rehearsal deals to
appear. It needs one account with two live deals and one shared person, which is the ordinary
shape of enterprise selling and the exact shape this product exists for.

## What I did NOT do

**Nothing is built.** The 153rd said the fix waits on this read, and the read changes what the
fix has to be: not a run-integrity guard refusing a mismatched source, but a change to the
ANSWER KEY itself, which is the ledger's identity and carries 129 live keys in this org alone.
Adding the opportunity to the key changes every existing key's value; migrating or versioning
them is a decision about the ledger's history, not a bug fix, and it is design's to rule.

Two shapes for the ruling, costed rather than chosen:

**Scope the key by opportunity for person subjects.** Correct, and it makes the two deals
independent as the methodology assumes. Every existing person-subject key changes value, so
either the `VERSION` prefix moves and old rows are migrated, or old and new coexist and the
first run after the change re-establishes rather than updates.

**Or scope by opportunity for ALL subjects**, accepting that the Opportunity-subject case is
already deal-scoped and would simply become explicit rather than incidental. Fewer special
cases, same migration question.

The purge's fix one already tolerates the damaged state, so nothing is blocked while this is
ruled.

---

# Addendum: what version-forward actually costs, measured

The 155th ruled the fix shape (opportunity in the key, all subjects) and put the HISTORY to
Matthew, leaning version-forward. Two measurements bear on that ruling, and the second is not in
the stamp.

## The stated cost of version-forward is smaller than feared

Design's named cost for (a) is a live deal losing continuity of reinforcement counts. Measured
across the whole org:

```
keyed answers in the whole org                = 129
of those, answers carrying reinforcement (>1) =   2
  Project Farma - Enterprise - 46 Seats | count=2 | subject=Participant
  Emerson/Aspen Tech Insights 500 Full Insight | count=2 | subject=Participant
```

**Two rows, each a count of two**, and both sit on frozen specimens rather than deals anybody is
selling. On that measure alone (a) is nearly free.

## The unstated cost is larger, and it is the one worth ruling on

**Supersession is keyed.** `AAO_Commit` reads what it might update or supersede with:

```apex
WHERE AAO_Answer_Key__c IN :answerKeys AND AAO_Superseded_By__c = null
```

So a version-forward key does not merely fail to UPDATE the old row - it fails to FIND it, which
means the old row is not superseded either. **It stays Live beside the new one**, and two Live
answers for one question on one deal is a state the readers were never built for:
`AAO_ProcessPanel.readingsFor` and `AAO_Flags` both read Live rows, and under the
DENIED-outranks-AFFIRMED tiebreak a stale pre-change denial would outrank a fresh affirmation
forever.

Design's lean already contains the protection without naming it as a condition: re-run deals get
fresh keys "for free on purge" - true, because the purge deletes the old rows before the new
ones are written. **The gap is a deal carried across the change WITHOUT a purge.** Measured:

```
keyed answers marked synthetic (purge-and-rerun) =   7
keyed answers on deals the purge will not clear  = 122
```

Those 122 are safe only while nothing re-establishes on them, which is exactly true of the
frozen measurement deals and exactly untrue of any deal someone later decides to run again.

## What this does to the ruling, offered rather than assumed

It does not overturn (a). It bounds it: **version-forward is correct with a rule attached - a
deal carried across the change is purged before its next run, or it is never run again.** Stated
that way (a) keeps its advantages and the duplicate-live-answer state becomes unreachable rather
than merely unlikely.

If design would rather not carry a standing rule of that kind, (b) migrate-in-place buys its
removal, and the measured price of the backfill is 129 rows touched once.

**Nothing is built.** This is the read the 155th's item 5 turns on, and the ruling is Matthew's.
