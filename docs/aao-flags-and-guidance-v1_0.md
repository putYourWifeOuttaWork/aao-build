# AAO Flags and Guidance — topology and fields

**v1.0 · 31 July 2026**
Companion to AAO Field Tables, which closes Source, Evidence Contract, Candidate, Answer, Claim and Claim Basis. **This file closes Flag and settles Guidance's topology.** Surfacing is deliberately last, per Matthew's ordering: objects and fields, then topology, then the read surface, then delivery, tracking, dismissal and efficacy.

---

## 1 · AAO_Flag__c · **CLOSED 31 July 2026**

**Type is set at birth and never changes.** It determines two independent things: how the flag can be cleared, and how it is measured. Nothing downstream reconstructs a flag's origin to know how to treat it. **Colour is display, derived from type. Nothing reasons about colour.**

| Field | Type | Constraints | Written by | Read by |
|---|---|---|---|---|
| `AAO_Type__c` | Picklist: `Methodological`/`Contention_Negative`/`Contention_Positive`/`Ratification` | Restricted, required, **immutable** | Raise | Clearance rule, measurement, surfacing tier |
| `AAO_Opportunity__c` / `AAO_Account__c` | Lookup | Required | Raise | Scoping, roll-up counts |
| `AAO_Evidence_Contract__c` | Lookup | Nullable | Raise | The proposition. Null on a ratification flag, which is about a pending write rather than a condition |
| `AAO_Answer__c` | Lookup | Nullable | Raise | The unmet condition. **One hop to what is wrong** |
| `AAO_Candidate__c` | Lookup | Nullable | Raise | Ratification flags only: the held write awaiting a human |
| `AAO_Subject_Contact__c` / `AAO_Subject_Shadow_Person__c` | Lookup | Nullable | Raise | Contention's subject. **The flag still belongs to the deal, never to a person** |
| `AAO_Cause__c` | Picklist | Restricted, required | Raise | Why it fired: `Gating_Unmet`, `Established_False`, `History_Contradicts`, `History_Better`, `Awaiting_Ratification` |
| `AAO_State__c` | Picklist: `Standing`/`Escalated`/`Cleared` | Restricted, required | Raise, escalation sweep, clearance | Whether it surfaces and whether it is ageing |
| `AAO_Raised_At__c` | Datetime | Immutable | Raise. **On a gating proposition this is opportunity creation** | Age. Day-one red means nothing raises it; it was never down |
| `AAO_Escalated_At__c` | Datetime | Nullable | Escalation sweep, when elapsed runway passes the threshold | When it entered the brief and started counting against the deal |
| `AAO_Cleared_At__c` | Datetime | Nullable | Clearance | Time-to-clear on methodological; not a measure on contention |
| `AAO_Last_Evidence_Considered__c` | Datetime | Nullable | Every pass that read evidence against this proposition | **What the flag owes the seller.** Distinguishes *we read it and it did not establish this* from *nothing has been read*. A timestamp, never a critique |
| `AAO_Evidence_Watermark__c` | Text(255) | Nullable | Every pass | Stops the same evidence raising the same flag twice. **Never stops the question being asked again** |
| `AAO_Answer_Here__c` | Text(255) | — | Raise | Where to write a response so it gets the express lane. A seller who does the work in a place we do not read must learn that from the flag, not from its persistence |
| `AAO_Acknowledged_By__c` / `AAO_Acknowledged_At__c` | Lookup(User) / Datetime | Nullable | Acknowledgement | Contention only. **Captured at the instant it happens** — the correlation to deal outcome is permanently lost otherwise |
| `AAO_Acknowledgement_Text__c` | Long Text | Nullable | Acknowledgement | Contention only. Written, because the risk transfers to the person who accepted it and that is only legitimate because it is recorded |
| `AAO_Coverage_Gap__c` | Long Text, JSON | Nullable | Raise, from the answer's coverage | **Flag content forks on coverage.** Over nothing: *not started, here is what to get*. Over partial: *here is what stands, with its receipts, and here is the piece missing* |

**Trigger law (`AAO_FlagTrigger`).** Type is immutable after insert. No delete on the live path. **A deletion of a subject never clears a flag** — it empties the answer's subject, the condition reverts to `UNVERIFIED`, and the ordinary machinery raises the ordinary flag. No gesture on any rendering clears anything.

**Clearance, by type.** Methodological clears on evidence only, never on acknowledgement, and can be raised again unless what established it cannot un-happen. Contention clears on written acknowledgement and is measured by deal outcome afterwards, never by time-to-clear, because clearing it is a click and a click measures nothing. Ratification clears on approval or decline, and **a decline leaves the condition `UNVERIFIED` with the clock still running**.

### Contention's basis is frozen, via Claim Basis · v1.0

**Ruled 31 July, and it is the finding that justified doing Flag tonight.** A contention flag's cause is not a row on core. It is a comparison against history on the memory plane, which will have changed by the time anyone opens the flag. **So the historical basis is frozen at the instant the flag is raised.**

**It uses Claim Basis rather than fields on Flag**, which makes that junction's parent polymorphic — a basis row hangs off a claim or off a flag. One mechanism, one place to look when anyone asks what this rested on. Fields on Flag would have given us two snapshot mechanisms doing one job, and the first question anyone asks would have two answers.

**What freezes:** the aggregate that fired, the count behind it, and the rung distribution, all as they read at raise time, with the same discipline as everywhere else — **what was cited, not what was available.**

### What is not a flag · v1.0

**Persona fit is guidance, not a green flag.** *This person at the account looks like they could fill that empty role* asks nobody to do anything and marks nothing as wrong. Give it a flag record and it inherits raised, aged and escalated, and then it nags about an opportunity rather than a defect. **Positive contention stays a green flag** — someone sitting neutral today who was supportive across prior deals is a real finding about a person on the map.

**No flag parentage.** Correlated flags correlate because they share a cause, and the shared cause is already queryable through the answers. Two propositions unmet because nobody has identified a decision maker are two flags over one gap, visible without a hierarchy.

**Tiered surfacing stays open and is Matthew's.** Surface the highest tier first and release lower tiers as it completes; the tension is that an unresolvable top-tier item holds everything beneath it invisible while those clocks keep running. **The fork: is the tier gate absolute, or does an item surface when its tier opens or its own threshold hits, whichever comes first.**

---

## 2 · Guidance — topology ruled, fields pending

**Guidance is its own object and does not fit the flag topology.** A flag is a demand: it counts, it ages, it wants clearing, it comes looking for you. Guidance is an offer, assembled and never pushed. The flag lifecycle is precisely the machinery that nags, so importing it would break the one property guidance has.

### The hole this session found · v1.0

**Guidance is specified as derived, holding no state, recomputed at each ritual. Guidance is also permitted to infer. Those two together are a defect nobody caught:** a seller opens a brief at nine and again at eleven, nothing has changed, and the advice is different. Inference is not stable across runs, so recomputation without a hold makes guidance shimmer.

**The fix, ruled 31 July: compute on change, hold until the next change.** A guidance set is computed when something on the opportunity moves or a time gate passes, and it is stable until the next such event. **Determinism of the record is achievable even though inference in the selection is unavoidable**, and that is the whole point of holding it.

### Three exits, not four types · v1.0

Matthew proposed four types — dismissible, acknowledgeable, both, neither. **They collapse into two optional exits plus one that is always available**, which composes better than a picklist and does not multiply when a fifth case arrives.

| Exit | What it means | Always available? |
|---|---|---|
| **Evidence** | The underlying condition moved, so the item stops being computed | **Yes, on every item.** Not a clearance gesture — guidance is derived, so it simply stops being produced |
| **Suppress** | *Not relevant.* Recorded so it is not re-offered | Per item, by flag |
| **Accept** | The item proposed a concrete write and the seller took it | Only where the item carries a proposed write |

**Suppression changes no state, and that is what makes it safe.** Dismissing *here is who might fill that persona* leaves the ghost empty, the gap visible and every flag exactly where it was. **A suppression must never satisfy a condition or clear a flag**, or it becomes the dismiss button in its sixth costume, after the Task checkbox, the note field, deleting the subject, pushing the close date and completing a rendering.

**Accepting is a human establishment and needs no new machinery.** A seller accepting *assign this persona to this person* has made a human judgment, so it writes a claim with actor `HUMAN`, carries human precedence, and is never overwritten. It goes through the ordinary write path.

**Suppression scope is per item per deal, and it lifts when the underlying state changes.** A suggestion declined today should not be silenced forever if the situation that produced it changes.

### Deterministic set, contextual selection · v1.0

**The computed set is deterministic and the selection from it is not, and that is the correct split.** Fifteen guidance items in a morning brief is a failure. Selection may use inference — who is on today's call, what the meeting is named, what stage the deal is in — because guidance establishes nothing, writes no value, and carries no citation of its own. **What must not vary is the set it selects from**, or the same brief run twice disagrees with itself.

**Persona-fit guidance exists from cold start onward.** The moment a persona ghost is seeded, the account's own contacts can be examined for who might fill it. That is a lookup against history and the CRM, not an establishment.

---

## 3 · Surfacing — deliberately last

Matthew's ordering: objects and fields, then topology, then the read surface, then delivery, tracking, dismissal and efficacy. **Surfacing is not designed here.** Two things are ruled now because they constrain it and would otherwise be discovered late.

**One read surface per opportunity per seller is the right target.** A headless assistant, a React client, a morning brief and a call preparation must not each assemble their own view from six objects, because they will diverge and the divergence will be invisible. One comprehensive current-state record is the goal.

**It inherits the roll-up's law: derived, outside the write law, no citation, no actor, no precedence.** Rebuilding it from the answers, claims and flags must always produce the same values. **If a field cannot be rebuilt, it belongs somewhere else.**

> **What is frozen and what is live are not the same question, and fusing them would be the mistake.** **Freeze the guidance set**, because it is inference-derived and shimmer is the failure. **Do not freeze flags**, because they are deterministic, cheap to read live, and a red flag that cleared an hour ago must never still be showing. Stale advice is annoying; stale risk is dangerous. The read surface holds a frozen guidance set alongside live flag state, and the reason for the asymmetry is written here so nobody unifies them for tidiness.

---

*End v1.0. Flag is closed. Guidance's topology is settled and its field table is Wave 2. Surfacing, delivery, dismissal mechanics and efficacy measurement are named and deliberately after.*
