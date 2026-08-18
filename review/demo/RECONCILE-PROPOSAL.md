# Proposal · the Class-A cure · one live answer chain per person and contract

The hundred-fifteenth stamp's item 2, **proposal first, before a line is written**, under the
hundred-sixteenth's read-before-write ruling. **Nothing here is built.**

## 1 · THE MECHANISM IS DECIDED BY THE ORG, NOT BY PREFERENCE

The stamp names two candidates — **re-parent the claims** or **read both chains** — and says the
second wins by default if the first cannot honour claim immutability. **It cannot.** Probed from
the runtime rather than reasoned about, on a real claim:

```
AAO_Claim__c is insert only apart from retirement, and this update moves aao_answer__c.
A claim is one establishment from one piece of evidence, and it is never edited.
If the answer moved, write another claim; that is what makes the movement visible.
```

**Mechanism (a) is structurally refused by `AAO_ClaimTriggerHandler`, and the guard's own last
sentence names the alternative it prefers: write another claim.** That is rejected here with its
reason: a second claim for evidence already claimed **inflates the count guidance orders by**,
which is the eightieth stamp's whole reinforcement finding arriving from the other direction. The
guard is protecting the ledger from exactly the repair it suggests.

**So the proposal is (b), and it is (b) on evidence rather than on taste.**

## 2 · THE PROPOSAL · SUPERSESSION, WITH THE CHAIN READ THROUGH

**One field.** `AAO_Answer__c.AAO_Superseded_By__c`, Lookup to `AAO_Answer__c`, shipping its
`fieldPermissions` in the same deploy per the ninety-fourth stamp's rule.

**At promotion, projection reconciles:**
- the **Contact-keyed** row is canonical — it is what every downstream surface reads and what the
  person's identity now points at;
- the participant-keyed orphan for the same person and contract gets `AAO_Superseded_By__c` set to
  the canonical row and leaves `Live`, so it stops projecting;
- **no claim is touched.** Not its answer, not its evidence, not its verdict, not its watermark.
  Nothing is deleted.

**`AAO_Accumulate` replays the canonical row from its own claims PLUS every superseded row's
claims, in evidence-occurred order.** The chain is merged at READ time, which is the only place it
can be merged without editing a claim.

**Why this is the honest shape and not a workaround:** the two rows were always one answer. They
exist as two only because the person had no Contact when the earlier call ran. Supersession says
that in the data instead of hiding it, and the orphan remains fully auditable — its claims, its
citations and its own history stay exactly where they were written.

## 3 · AND THE COLLISION MUST STOP HAPPENING AT ALL · the hundred-sixteenth's law

Reconciliation is a **repair path, not a routine one.** Under read-before-write, projection reads
the standing keyed rows for its key set **before composing any stamp**, and branches then: absent →
stamp; occupied by this person's canonical row → reconcile; identical → reuse. **A
`DUPLICATE_VALUE` on our own key becomes an alarm that never fires, journalled as an error leg
naming the writer that failed to read.**

That demotes the containment shipped at `1a24f6a` to backstop behaviour, exactly as the stamp
directs. **The skip stays in the code as the thing that must never fire, not as the thing that
handles this.**

**The read costs one SOQL per projection over the deal's Contact-keyed answers, keyed by contract.
It is priced into the `SOQL ≈ 2.33·C + 9` model at proposal time rather than discovered at a
governor** — which is the sixteenth stamp's own complaint about ceilings, answered before the fact.

## 4 · THE ACCEPTANCE BAR IS THE REPLAY LAW ITSELF

**Replay of the merged chain reproduces the standing state byte-exactly**, proven on the frozen
Brightwell stack. That is the stamp's bar and I am not proposing a softer one.

Two sub-conditions I would hold myself to, both falsifiable:
1. **The superseded row's own replay is unchanged.** Reading it alone still reproduces what it said
   before reconciliation — supersession must not rewrite history, only route around it.
2. **Reconciling twice is identical to reconciling once.** The pass re-runs; an idempotent repair is
   the only kind safe to put on a driven path.

## 5 · THE COST, STATED

- One field, one lookup, on an object the mirror already carries. Passes the object-budget law: no
  new object, and the field exists so two rows that are one answer can say so.
- Replay reads more rows: canonical plus superseded. Bounded by how many calls a person appeared on
  before gaining a Contact, which is small and does not grow with the corpus.
- **The `Live` state of the orphan changes**, which is a mirror write. It is not a deletion and not
  an edit to evidence, and `AAO_Publication_State__c` is what projection already reads.

## 6 · WHAT THIS DOES NOT SETTLE, EXPLICITLY

**Not the derived-entity-identity question.** That is whether two INSIGHTS or two CRITERIA are the
same thing, which is a meaning judgment and still Matthew's. **This proposal touches one person, one
contract, one key migration** — where existing law already says what the end state is, and the only
open question was the mechanism.

The hundred-sixteenth's boundary is respected exactly: read-before-write decides
establish/reinforce/reconcile **deterministically on keys and bytes**, and where sameness is a
meaning judgment the read supplies a closed candidate list and nothing more.

## 7 · WHAT I WOULD BUILD, IN ORDER, ON RATIFICATION

1. The field plus its FLS, deployed together.
2. Read-before-write in projection's contact-stamping path, with the collision made impossible.
3. Reconciliation at promotion for rows that diverged before the law landed.
4. Replay through the superseded chain in `AAO_Accumulate`.
5. The byte-equality replay proof on frozen Brightwell — which is R6's test, half-built by this.
6. The `DUPLICATE_VALUE` sweep across join, projection and cards.

**Nothing starts until this is ratified or amended.**
