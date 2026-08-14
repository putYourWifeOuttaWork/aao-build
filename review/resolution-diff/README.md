# The per-leg resolution diff · REPORT ONLY, NO BUILD

**Authorizing bytes, eighty-first stamp item 3(i), quoted verbatim per the receipt rule:** *"A per-leg diff report first: what `AAO_Pass.identify` actually does today, leg by leg, against the twenty-seventh stamp's text and against `AAO_Resolve`, because the gate-era evidence (234 ms deterministic, one model leg on the remainder) and today's measurement (a model call over every located pair) cannot both describe the current pass and the diff says which era drifted."* Re-ordered as item (b) of the eighty-sixth stamp's queue. Nothing here is built, wired, or proposed as a build; the wiring proposal is the separate next item.

**Method.** Read from the post-loss re-baseline source tree retrieved from aossb2 on 14 August, `force-app/main/default/classes`, at commit `2c9d6f8`. Every count below is a grep or a line-range read against those bytes, stated so design can reproduce it. No run was made and no org row was read for this report.

---

## 0 · The headline, and it answers the stamp's question

**Neither measurement is wrong, and neither era drifted in the sense the stamp anticipated.** The gate-era evidence (deterministic legs, one model leg on the remainder) describes `AAO_Resolve`. Today's measurement (a model call over every located pair) describes `AAO_Pass.identify`. **Both classes exist in the tree right now, both are complete, and they are two different implementations of the same stage.** The pass drives `identify`; `AAO_Resolve` was built to the twenty-seventh stamp's design and never wired in.

**And the sharpest fact for the wiring proposal: `identify` is not a stale leftover.** Its charter is `identify-2.0.0`, and its own header comment cites Matthew's 13 August keyed-schema ruling and the Project Farma 59-pair failure by name — so it was actively maintained *after* `AAO_Resolve` existed. This is not neglect of an old path. It is two maintained implementations, one driven and one dark.

---

## 1 · `AAO_Resolve` has zero non-test callers · REPRODUCED

The eightieth stamp's finding holds on the retrieved source. One precision note, because the obvious grep gives a false positive: `AAO_Resolve` shares a prefix with `AAO_ResolverCharter`, `AAO_ResolveDesignator` and `AAO_ResolveRequestCharter`, all of which ARE live. Matching the class proper (`AAO_Resolve.`) and excluding those:

- **Non-test classes referencing `AAO_Resolve.`: NONE.**
- The only file referencing it at all is `AAO_ResolveTest.cls`.
- `AAO_Pass.cls` does reference `AAO_ResolverCharter` fourteen times — that is **call 0's charter**, not this stage.

`AAO_Pass.identify` likewise has no in-repo caller; it is driven externally, which matches the run reports' external-driver shape.

---

## 2 · Leg by leg

| Leg, per the 27th stamp | `AAO_Resolve` (dark) | `AAO_Pass.identify` (driven) |
|---|---|---|
| **Merge** — contract + byte intersection + same voiced meaning; corroboration marked | `mergePlan`, leg 1. Absorbed rows written `MERGED` with a reason naming the canonical; canonical marked corroborated | **Absent.** No merge, no `MERGED` disposition |
| **Byte lookup** — offset → containing turn → speaker key → roster → Id, zero model | Leg 2. `roster.get(speakerKey)`; unknown key **throws** as an ingest defect rather than becoming a quiet `None` | **Absent.** Speaker attribution is asked of the model |
| **Designator ladder** — closed candidate set, title rung, exactly one match links, >1 AMBIGUOUS, 0 falls through | Leg 3. Roster match first, then `AAO_ResolveDesignator.resolve` with TITLE/NAME kind scoped to account and opportunity; links, holds AMBIGUOUS, or falls to remainder | **Absent.** No ladder is called |
| **Model leg on the REMAINDER ONLY**, typed requests, Apex composes queries | `requests()`, a separate method. **`run()` contains 0 `callStage` calls; `requests()` contains exactly 1** | **The only leg.** 1 `callStage` per batch, over *every* located pair |
| **Mentioned people** | Mints mention `AAO_Participant__c` rows from ladder-linked Contacts | **Structurally excluded.** Its own header comment: the candidate list is narrowed to the Source's participants because a mentioned person has no Participant row, and the shadow path *"is the gates' work and is not built"* |
| **Batching** | Whole located set in one deterministic pass | `LIMIT maxPairs`, default `MAX_UNITS_PER_KEYED_CALL` = 15; caller loops |

### What this predicts, and it matches the measurement already on the record

`AAO_Corroborated__c` is written by exactly two non-test classes: `AAO_Resolve` and `AAO_PairTriggerHandler`. **`identify` never writes it** — confirmed by reading its row constructor, which sets stage, run key, ref, charter, located parent, source, artifact hash, contract, disposition, person and basis, and no corroboration field. That is the mechanical cause of the eightieth stamp's *"0 of 67 identified pairs carry `AAO_Corroborated__c = true`"*: not a low rate, a field the driven path has no code to set.

The same explains `r1q10`/`r2q7`: identical bytes, identical meaning, same contract, both surviving as separate pairs. `mergePlan` would have collapsed them; the driven path has no merge.

---

## 3 · Against the twenty-seventh stamp, clause by clause

| Stamp clause | `AAO_Resolve` | `identify` |
|---|---|---|
| "Deterministic legs, Apex, zero model calls" | **Met** — 0 callouts in `run()` | **Not met** — model call is the whole stage |
| "The model leg… fired ONLY when the deterministic legs leave a remainder" | **Met** — `requests()` is separate and takes `o.remainder` | **Not met** — fired on all pairs |
| "Output: TYPED RESOLUTION REQUESTS, never query text, never SOQL" | **Met** — `AAO_ResolveRequestCharter` v`resolve-requests-1.0.0` | N/A — no request shape |
| "Resolution attaches SUBJECTS, never speakers" | **Met** — designator legs attach the subject | Partially — dispositions attach a person, but self-subject is a model judgment rather than a byte fact |
| "Creation… behind the create-leg record" | Mints participants; `AAO_Created_Row__c` exists in the tree | Not reached |

**One divergence that belongs to neither class, flagged for design rather than diagnosed here.** The stamp says a quote landing inside more than one speaker's turns *"routes to the model leg instead of being guessed."* Neither implementation does that, because the case is disposed earlier: `AAO_LocateTest.aQuoteThatStraddlesTwoTurnsIsDiscardedRatherThanAttributed` shows straddling quotes are **discarded at locate**. Discarding is safe and is not guessing, but it is not what the stamp says, and it silently costs recall on exactly the stitched-across-turns evidence the span-set ruling exists to capture. **Reported, not touched** — it sits upstream of this stage and is design's to rule.

---

## 4 · What this means for the wiring proposal, stated as inputs and not as a proposal

1. **Wiring is not a swap of like for like.** `AAO_Resolve` disposes pairs the driven path cannot express (`MERGED`) and writes a field it never sets (corroboration). Ledger arithmetic changes shape, which is exactly why the eighty-first stamp's condition 3(iv) requires located/merged/disposed to reconcile across the merge.
2. **The pair volume reaching any model leg should fall sharply**, since the deterministic legs take self-subject pairs — the common case — for free. Condition 3(iii)'s re-measure of call 2's batch arithmetic and grammar cap is therefore not a formality: the cap was measured on a stage handed every pair.
3. **`identify`'s maintained-ness is a cost the proposal must price.** Retiring a path that received the keyed-schema conversion on 13 August means retiring work that is newer than the design it is being replaced by. The twenty-eighth stamp's "one implementation survives" still governs; this report only notes that the survivor inherits the keyed-schema lesson, which `AAO_Resolve.requests()` should be checked against before wiring.
4. **The mentioned-person gap is the real functional delta.** `identify` cannot see anyone who was not on the call, by its own comment. Every mentioned-person specimen the ledger carries — Fatima, Rich, Priya, Pat — is unreachable on the driven path and ~~reachable on the dark one~~. **THE STRUCK PHRASE IS TRUE IN ITS CONCLUSION AND WRONG IN WHAT IT IMPLIES ABOUT THE MECHANISM. Corrected in place per the corrections law, never deleted; the mechanism and its consequence for the wiring question are §6 below.**

---

## 5 · Owed next, not done here

The wiring proposal per the eighty-first stamp's conditions 3(ii) through 3(v), and only on its ratification, the wiring. Before-and-after measurement on the frozen fixtures (model calls, merged count, corroborated count, wall) is condition 3(v) and belongs to that work, not to this report.

---

## 6 · CORRECTION, this report's own · what a mentioned person IS, measured rather than implied

Design's read of §4 item 4 is right that the mechanism was not named, and naming it changes the wiring question. Measured from the same tree:

**`AAO_Resolve` does NOT use `AAO_Shadow_Person__c`.** It mints an `AAO_Participant__c` with a `mention:` roster key — `mentionKey()` returns `'mention:' + designator.trim().toLowerCase()` with whitespace hyphenated, and `mentionFor()` mints the row with the designator VERBATIM as display name (the ASR-name law) and the email carried from the linked Contact so the join's internal-domain gate can still see a seller. Its own header states the intent: *"RESOLUTION ATTACHES SUBJECTS, NEVER SPEAKERS: a resolved mention becomes the pair's subject via a mention-minted Participant row (`mention:` roster key, excluded from coverage — presence establishes coverage and a mention is not presence)."* So the row is a **subject carrier**, deliberately excluded from coverage arithmetic by its key prefix.

**And a second measurement, which cuts against the framing on both sides.** `AAO_Pass.cls:1087-1091` says mentioned-person candidates need *"the shadow-creation path, which is the gates' work and is not built."* **That comment is stale.** The shadow path is built and live:

- `AAO_Shadow_Person__c` is referenced by five production classes: `AAO_AnswerKey`, `AAO_Commit`, `AAO_Identity`, `AAO_PersonName`, `AAO_Replay`.
- `AAO_AnswerKey` carries `Shadow_Person` as a first-class subject type (line 53, and branches at 180 and 198).
- `AAO_Commit` carries the shadow lookup onto candidates and claims.
- **`AAO_Identity.shadow()` mints the rows**, upserting on `AAO_Shadow_Key__c`, reachable from five return sites inside `AAO_Identity.resolve()`.
- **`AAO_Project.cls:773` calls `AAO_Identity.resolve(person, accountId, opportunityId)`**, so shadow minting runs today, at projection, on every pass.
- The object carries `AAO_Promoted_Contact__c` and `AAO_Promoted_At__c`, so the promotion path to a real Contact exists too, and `AAO_Participant__c.AAO_Contact__c`'s own field description says it is *"NULLABLE ON PURPOSE: a participant who is not a Contact is exactly the Shadow case."*

`AAO_Resolve`'s header agrees and says so deliberately (lines 44, 49, 292): **creation does not happen in resolution; it stays at projection in `AAO_Identity`, at ladder-zero, behind the create-leg record.**

### What this means for the question design put to Matthew

The two implementations do differ on mentioned people, but **not as "mints a Participant who never participated" versus "waits on a Shadow Person that was never built."** Measured, it is:

- **`AAO_Resolve`**: the mention becomes a *subject carrier* — a mention-keyed Participant, excluded from coverage — and the question of what that person IS in the CRM is deferred to `AAO_Identity` at projection, which already decides link-to-Contact, mint-a-Shadow, or hold, on the existing ladder.
- **`identify`**: the mention never enters at all, on a comment whose stated reason no longer holds.

**So the representation question is narrower and cheaper than it looked, and it is still Matthew's.** It is not "build a shadow path"; that exists and runs. It is: **does a mentioned person get a mention-keyed Participant row as their subject carrier during resolution, or should the subject carrier be a Shadow Person directly, with no Participant row minted for someone who was not present?** Both end at the same projection-time ladder. The proposal holds both open and prices them; it does not assume either.

**Standing hazard recorded from this:** the `AAO_Pass` comment was read as current by design and by this report before it was checked against the classes it names. A comment asserting the absence of a capability is a state claim, and the state-claim law binds it: unverified until the code carrying it is opened.
