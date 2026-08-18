# Brief for design · THE ANSWER KEY CANNOT SURVIVE A CONTACT ARRIVING MID-LIFE

**Matthew's read, 18 August, and he is right: "we won't always have contact records."** The
seeding I did for the demo is a CRUTCH, not a fix, and this brief exists so it is never mistaken
for one.

## 1 · THE FAILURE IS ON THE NORMAL PATH, NOT AN EDGE

A2 keys a Participant answer on the **Contact where one exists**, and on the per-Source
**Participant** where none does. That was the hundred-fourth stamp's cure for cross-call
accumulation and it works.

**But most people on a real call have no Contact.** That is the whole reason the create leg
exists. So the ordinary life of a person in this system is:

```
call 1   no Contact   →  answers keyed on Participant (per-Source, per-call)
call 2   no Contact   →  answers keyed on a DIFFERENT Participant
call 3   create leg fires, Contact arrives
         → projection stamps the Contact onto the answer
         → the key MIGRATES from Participant to Contact
```

**A Contact for a previously unknown person can only ever arrive mid-life.** So key migration is
not an exception this system must tolerate occasionally — **it is the normal case for every person
the org has never met, which is most of them.**

## 2 · WHAT BREAKS, MEASURED

Live, on the demo deal, third stacked call:

```
System.DmlException: Update failed. DUPLICATE_VALUE, duplicate value found:
AAO_Answer_Key__c duplicates value on record with id: a1SWD000005tXEz2AM
```

Two answers for **Karen Lindqvist**, same contract:

| row | created | key | contact | projected |
|---|---|---|---|---|
| `…tXEz2AM` | 13:11:55 | `A2\|Participant\|003WD…Rm0db\|<contract>` | Karen Lindqvist | Signature Approver |
| `…tXYM2A2` | 13:16:20 | `A2\|Participant\|a1ZWD…bnwh\|<contract>` | *null* | — |

Call 2 had her Contact; call 3's participant row did not. Projection stamped the Contact on call
3's answer, the key migrated to the Contact form, **and the slot was already occupied by call 2's
answer.** Projection threw, and **the whole projection transaction rolled back** — so nothing
downstream of it landed either.

**The deal carried 24 contact-keyed and 21 participant-keyed answers.** A genuinely mixed
population on one opportunity.

## 3 · THE DEFECT IS MINE AND IT IS PRECISE

`AAO_AnswerTriggerHandler.isOwnContactPromotion` — which I built at the ninety-ninth stamp — exists
so a late Contact CAN land: it permits the one key transition from a participant to that
participant's own Contact, verified from the org, and refuses every other move.

**It checks that the move is legitimate. It never checks whether the destination is occupied.**

`AAO_Commit` already has the shape this needs and says so in its own header: `DUPLICATE_VALUE` on
`AAO_Answer_Key__c` "is a merge path and it belongs to the caller, which must catch it, re-read the
colliding row, apply precedence and proceed." **Projection has no such caller.** The merge path was
built for claim-writing and the migration path was added later without one.

## 4 · A SECOND FAILURE MODE IN THE SAME FAMILY, found 16 August

`AAO_Purge` deletes machine-created Contacts via the create-leg record and **leaves answers keyed
to them.** The next projection then tries to move those answers onto a NEW Contact and the frozen
guard refuses with *"Identity does not move."*

**So the same key has two ways to break: it can collide with an occupied slot, and it can be
orphaned by a deletion that was itself lawful.** Both trace to one thing: **the key encodes an
identity that is allowed to change, and nothing owns the change.**

## 5 · WHY THIS IS SYSTEMIC AND NOT COSMETIC

The product's premise is that a deal's truth **accrues across conversations**. Accrual requires a
person to be the same person across calls. **The identity the key uses is the one thing that is
guaranteed to change** for anyone the org has not met — and it changes precisely at the moment
accrual starts mattering, which is the second or third call.

**Seeding Contacts in advance makes the problem disappear, and that is exactly why it is dangerous
as a fix.** Every graded corpus this project has run — Wells Fargo, Emerson, Project Farma — used
seeded Contacts. **The stacked demo on unseeded people is the first time this path has been walked,
and it failed on the third call.**

## 6 · OPTIONS, WITH COSTS · NONE CHOSEN, NOTHING BUILT

**(a) Merge on collision at projection.** Catch `DUPLICATE_VALUE`, re-read the standing row, apply
precedence, proceed — the shape `AAO_Commit` already uses. Cost: a merge is a real semantic
decision on the mirror. Which counter survives, which spans, which established-by? Getting it wrong
silently destroys one of two evidenced answers, and answers are what every downstream surface
reads.

**(b) Never migrate.** The key is decided at birth and frozen absolutely. Cost: forfeits the
hundred-fourth stamp's whole gain — a person's answers fragment across participant-keyed and
contact-keyed rows permanently, which is the cross-call accumulation defect A2 was built to cure.

**(c) Migrate the person atomically.** When a Contact lands, re-key EVERY answer for that person on
that deal in one transaction, merging where two rows meet. Most complete, most work, and it needs
(a)'s merge semantics anyway.

**(d) KEY ON AN IDENTITY THAT NEVER MOVES, and the ninety-seventh stamp already described it.** Its
words: *"Contact where one exists, **shadow where one does not**, per-Source Participant only as
the last fallback."* **I implemented Contact-else-Participant and skipped the shadow rung.** The
shadow is **account-scoped and durable** — `001…|mention:priya natarajan` — and promotion LINKS a
shadow to a Contact without changing the shadow's own identity. **A key on the shadow would not
migrate when the Contact arrives; promotion would simply record who the shadow turned out to be.**

Cost, stated honestly: shadows today are minted for unresolved MENTIONS, not for rostered people
who lack a Contact, so this widens what a shadow is for. And a person who is a shadow on call 1
and rostered on call 2 still needs the two to meet — which is promotion's job and is now proven to
work (both Priya flags cleared by person, 16 August).

**Design's ruling. I have built toward none of them.**

## 7 · WHAT I DID FOR THE DEMO, AND ITS EXACT SCOPE

Seeded every external speaker the demo transcripts name as a real Contact on the demo account, so
the ladder LINKS instead of creating and no key ever migrates. **That is a data workaround on one
sandbox account for one morning. It fixes nothing and it proves nothing about the field.**

I also removed two seeds that were my own over-reach — bare `Marcus` and `Priya`, single-token
designators from mentions. The eightieth stamp's rule is that a single token **links but never
creates**, and a surname-less twin makes the ladder ambiguous against the real person, which is the
failure that rule exists to prevent.

## 8 · WHAT TO WATCH, AND THE ACCEPTANCE TEST WHEN IT IS RULED

**The specimen is free and already authored:** a person who appears on two or more calls and gains
a Contact between them. The demo harness reproduces it in three pastes with **no seeded Contact for
that person**, which is the test that must pass before this is called fixed.

**And no graded corpus currently exercises it**, because all three used seeded Contacts. **That is
worth a line in the read sheet: the accumulation the product is sold on has never been measured on
a person the org did not already know.**
