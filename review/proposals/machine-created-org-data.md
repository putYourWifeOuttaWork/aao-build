# Proposal · the disposition of org data the machine created

**Owed proposal-first per the eighteenth stamp (the a23 Contact) and required with the build per
the nineteenth (the shadow path's Contact and map-detail creation). CODE, 8 August. Nothing in
here is built.**

Three questions that looked separate and are one: **what may the machine create in the
customer's org, and what happens to it when we later judge it should not exist?**

---

## 1 · What is on the ground right now

| thing | id | state |
|---|---|---|
| Contact "Wendy Higley", `wendy.higley@altify.com`, on Emerson Electric Co. | `003WD00001QZE73YAH` | created by a23's projection, **still live** |
| Her vendor map row | `a0eWD000003nYejYAE` | `ALTF__Coverage__c = Brief contact`, stamped ours at `2026-08-08 15:01:22` |
| Her Buyer Role claim | `CLM-00000092` | **retired** under the 8 August ruling, with its reason |
| Her Buyer Role answer | `a1SWD000005mVkz2AE` | UNVERIFIED, placed nothing, so no role value ever reached the map |

The claim retired cleanly. **The Coverage value did not retract, and the reason is a defect, not
a policy.** See §3.

## 2 · The Contact itself

The narrower question first, because the ruling asked for it.

**Recommendation: leave it, and never create its like again.** Reasons, in the order I weigh
them:

- **It is the customer's org, not our ledger.** The never-delete law protects our record because
  our record is evidence. A Contact on the customer's account is not evidence of anything; it is
  a row in their CRM that we put there without being asked. The law's *reason* does not reach it,
  so "nothing is ever deleted" is not automatically the answer here.
- **But deleting it is also not ours to choose.** A Contact can acquire references the moment it
  exists (activities, campaign members, a seller's own edits), and deleting a row somebody may
  have since touched is the destructive move this build has refused three times.
- **So the honest disposition is neither: mark and report.** The Contact stays, and it appears on
  the run report as machine-created-and-disowned with the reason. Matthew or the customer's admin
  decides whether to delete it, holding facts we do not have.

**What I would build to make this decidable rather than argued:** projection already knows the
Contacts it created (the create leg counts them). It should record them, so "which rows did we
put in this org, and which do we now disown" is a query rather than an archaeology.

## 3 · DEFECT · we cannot retract a value we can prove we wrote

Found by attempting the ruled correction, which is the right way to find it.

`AAO_Project` holds a dimension back if `humanEdited(stamp, ours)` **or**
`humanAuthored(liveValue, ourValues, touched)`. For Wendy's Coverage:

- `humanEdited` says **ours** — the stamp on the row is our own write from a23.
- `humanAuthored` says **the human's** — because `touched = !ourValues.isEmpty()` and
  `ourValues` is built only from answers carrying a **projected value**. Her one answer is
  UNVERIFIED and placed nothing, so by that test we have never touched her row.

**The stamp proves the value is ours and the guard ignores the stamp.** The consequence
generalizes past Wendy: **any person we meet once, place nothing on, and write Coverage for is a
person whose Coverage we can never retract** — Coverage is computed and keeps no answer of its
own, so it can never contribute the evidence that would let us clear it.

This is the board's "correction that disables what it corrects" hazard, arriving on the exact row
a ruling asked us to correct. The session-77 repair that added `humanAuthored` was right about
Fatema — a value on a row we have genuinely never met is somebody else's — and it was written
without a case where our own stamp and our own answer-set disagree.

**Proposed repair, one line, not built:** `touched` should mean *we hold a watermark on this
row*, not *we have a placed answer for this person*. The dimension stamps
(`ALTF__*_Last_Modified__c`) are that watermark and are already read three lines above. Fatema is
unaffected: her row carries no stamp of ours and no value of ours, so both tests still hold her
back.

**Why proposal-first rather than fixed:** it is the human-override guard, which is absolute, and
the failure mode of getting it wrong is silently overwriting a human's judgment. That is worth a
ruling even when the fix looks obvious, and especially when it looks obvious.

## 4 · The boundary the shadow path needs before it builds

The nineteenth stamp puts mentioned-person resolution inside People, with creation
proposal-first. The a23 specimen is Fatema Choudray, named as the signer by a participant, on a
call she did not attend.

**Proposed boundary, in one sentence: the machine creates rows in OUR namespace freely and rows
in the customer's namespace never.**

| surface | who may create | why |
|---|---|---|
| `AAO_Shadow_Person__c` | the machine | ours, retirable, carries its own provenance, invisible to the customer |
| Claims and answers keyed to a shadow | the machine | our ledger, and already governed by retirement |
| `Contact` | **nobody, automatically** | it is the customer's CRM record of a real human; a19's describe already established that a shadow can never reach the vendor map without one |
| `ALTF__Contact_Map_Details__c` | **nobody, automatically** | it needs a Contact, so this follows from the row above |

**What the seller sees instead:** the establishment is held at the shadow surface and surfaced as
a proposal — *"this call names Fatema Choudray as the signer; add her to the map?"* — which is a
one-click human decision with our evidence attached, rather than a row that simply appears.

**This inverts what a23 actually did**, and deliberately. a23 created a Contact with no human in
the loop and the result was our own seller on the customer's buying committee. The shadow path
will meet the same shape far more often, because a mentioned person is by definition someone no
roster vouched for.

**The consequence I want ruled explicitly:** under this boundary the 7 a23 pairs still do not
reach the map. They stop being *silently dropped* and start being *held with their evidence and
offered*, which is the whole gap — but if the acceptance criterion is "Fatema appears on the
map", this boundary does not meet it and I would rather be told that now than after building.

## 5 · What I need back

1. The Contact's disposition (§2): mark and report, or delete.
2. A ruling on the retraction defect (§3), or permission to fix it as ordinary work.
3. Confirmation or correction of the creation boundary (§4), specifically whether "held and
   offered" satisfies the mentioned-person gap or whether creation is expected.

Items 1 and 3 block nothing today. **Item 2 blocks the retraction half of the Wendy correction**,
which is why her Coverage value is still on the customer's map as I write this.
