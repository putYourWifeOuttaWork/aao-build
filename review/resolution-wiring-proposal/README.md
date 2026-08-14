# The resolution wiring · PROPOSAL ONLY, NO BUILD

**Authorizing bytes.** Eighty-sixth stamp queue item (c), authorized on the condition stated by design in session 2: *"Write section 4's inputs to hold BOTH representations open, and state plainly which parts of the proposal change under each."* Built to the eighty-first stamp's conditions 3(ii) through 3(v), quoted at each condition below. **Nothing here is built.** The wiring lands only on design's ratification, and the mentioned-person representation is Matthew's and is not assumed by this proposal.

**Inputs.** `review/resolution-diff/README.md`, including its §6 correction. All measurements below are from the re-baselined tree at commit `4ede29b`.

---

## 1 · The proposed shape

Per condition 3(ii) — *"ONE implementation survives… `AAO_Resolve` and `identify` reconcile into one stage with the deterministic legs in front and the model leg on the remainder only"* — the surviving stage is `AAO_Resolve`'s shape, and `AAO_Pass.identify` is retired into it rather than deleted alongside it:

1. **Leg 1, merge.** `mergePlan` collapses same-contract, byte-intersecting, same-meaning pairs; absorbed rows written `MERGED` with the canonical named; canonical marked `AAO_Corroborated__c`.
2. **Leg 2, byte lookup.** Speaker key → roster → Id. Zero model. Unknown key throws as an ingest defect.
3. **Leg 3, designator ladder.** Roster first, then `AAO_ResolveDesignator` with the title and given-name rungs, scoped to account and opportunity. One match links; more than one holds AMBIGUOUS; zero falls to the remainder.
4. **Leg 4, the model leg, on the remainder only.** `AAO_Resolve.requests()`, one bounded call, typed requests, Apex composes every query.

**What `identify` contributes to the survivor, and this is the part the diff report insisted on pricing.** `identify` is `identify-2.0.0` and carries the 13 August keyed-schema conversion; `AAO_Resolve.requests()` predates that ruling at `resolve-requests-1.0.0`. **The keyed-schema lesson migrates into `requests()` as part of this wiring, not after it**: one property per unit, every key required, `keyedShardCount` driving the sharding, the 400-despite-cap loud stop retained. The seventy-third stamp's standing law — *"KEYED GRAIN NEEDS A KEYED SCHEMA. Prose is not enforcement"* — binds the model leg regardless of which class it lives in, and the survivor must not inherit an array-shaped envelope that the retired path had already outgrown.

**The join-side backstop from the eightieth stamp stays regardless**, unchanged and unweakened, because different-meaning pairs on the same bytes are meant to survive the merge and still land on one answer.

---

## 2 · THE OPEN QUESTION, held open · what a mentioned person IS

**This proposal does not settle it and its build differs under each answer.** Measured facts that price it:

| | |
|---|---|
| `AAO_Pair__c.AAO_Person__c` | Lookup to **`AAO_Participant__c` only**. No shadow lookup, no subject-type discriminator on the pair |
| `AAO_Candidate__c` | Carries `AAO_Shadow_Person__c`, `AAO_Subject_Contact__c`, `AAO_Subject_Type__c` |
| `AAO_Claim__c` | Same three, plus internal/external person |
| `AAO_AnswerKey` | `Shadow_Person` is a first-class subject type (line 53, branches at 180 and 198) |
| `AAO_Identity.shadow()` | Mints shadow rows, upsert on `AAO_Shadow_Key__c`, reachable from five sites in `resolve()`, called live by `AAO_Project.cls:773` |

**So the shadow representation is first-class from Candidate onward and live at projection. The one stage that cannot express it is the PAIR — which is exactly where resolution writes.** `AAO_Resolve`'s mention-minted Participant is therefore not an arbitrary preference; it is the only subject carrier the pair schema can hold today. That reframes the question from "which did the two authors prefer" to "should the pair schema learn a second subject type."

### Representation A · mention-keyed Participant (what `AAO_Resolve` does today)

The subject carrier is an `AAO_Participant__c` with roster key `mention:<designator>`, display name the designator verbatim per the ASR-name law, email carried from the linked Contact, excluded from coverage by its key prefix. Creation stays at projection.

- **Schema change: none.** Pair, candidate, claim, answer key, projection all work unmodified.
- **Coverage:** protected by the `mention:` prefix — *a convention, not a constraint*.
- **Safety property gained:** the email rides from the Contact, so the join's internal-domain gate can still catch a seller who is mentioned rather than present. That is the twenty-second stamp's Pat case, and Representation A is the reason it can fire at all.
- **Cost, stated plainly:** a Participant row exists for a person who did not participate. Every consumer of `AAO_Participant__c` other than coverage must be audited for the same presence assumption, and that audit is part of the build under A.

### Representation B · Shadow Person as the subject carrier at resolution

The mention mints an `AAO_Shadow_Person__c` directly; no Participant row for a non-participant.

- **Schema change: required.** `AAO_Pair__c` gains a shadow lookup and a subject-type discriminator, mirroring `AAO_Candidate__c`.
- **Every reader of `AAO_Pair__c.AAO_Person__c` must learn the discriminator** — including `AAO_Commit`, the join, the export, and the Run Inspector's walk-back, which currently renders a person from that one lookup.
- **Coverage:** protected structurally rather than by prefix convention. Strictly stronger.
- **Cost:** the internal-domain gate's email path must be re-established, since a shadow row is not a Participant and carries `AAO_Source_Name__c` rather than a roster email. **Under B, the Pat case needs its own answer or it silently regresses**, and that is the sharpest risk in this whole proposal.
- **Benefit:** it stops overloading a word. The eighty-first stamp's own lesson about disowned-versus-purgeable is the same shape: one flag meaning two things is how a rule silently changes meaning.

### What changes in this proposal under each

- **Under A:** conditions 3(ii)–(v) are discharged exactly as written below. No schema work. The build is the wiring plus the keyed-schema migration of `requests()`.
- **Under B:** everything below still holds, plus a schema stretch on `AAO_Pair__c`, a reader audit across commit/join/export/Inspector, and **an explicit re-answer of the internal-domain gate for mentioned sellers**, which under A comes free. B should therefore be sequenced as its own stretch behind the wiring, not inside it — wiring first under A's mechanics, then B as a deliberate migration if Matthew rules that way, because doing both at once changes the stage and its schema in one move and no measurement could tell which caused what.

**Design's framing, corrected by measurement and recorded so the choice is made on facts:** it is not "mints a Participant who never participated" versus "waits on a Shadow Person that was never built." The shadow path is built and runs at projection today. It is: *does the pair-grain subject carrier stay a Participant with a reserved key prefix, or does the pair schema learn a second subject type?*

---

## 3 · Discharging the eighty-first stamp's conditions

**(iii) — *"Call 2's batch arithmetic and its grammar cap RE-MEASURE on the post-merge pair volume."*** The cap `MAX_UNITS_PER_KEYED_CALL = 15` was measured on a stage handed **every** located pair. After wiring, the model leg sees only the remainder, so both the volume and the schema shape change. Re-measure before the cap is trusted: hand `requests()` increasing unit counts on a frozen fixture until the gateway refuses, record the refusing count and the request id, set the cap under it, and keep the 400-despite-cap loud stop. **The old 15 does not carry forward**, per the thirty-fifth stamp's cap-keyed-to-shape condition.

**(iv) — *"The one-for-one ledger arithmetic restates across the merge: located, merged, disposed reconcile or the run does not count."*** Today `assertOneForOne` compares located against disposed. With a merge leg that identity no longer holds. The restated invariant: **located = merged + identified + ambiguous + none + remainder-held**, checked at run level, with every absorbed pair carrying its `MERGED` disposition and a pointer to its canonical so the sum is auditable by rows and not only by counters. A run whose arithmetic does not close does not count, unchanged.

**(v) — *"Measured before and after on the frozen fixtures: model calls, merged count, corroborated count, wall."*** Before-numbers are taken on the current driven path; after-numbers on the wired path; same fixtures, same run keys purged between. **Expected direction, recorded so it can be shown wrong:** model calls fall sharply (self-subject pairs are the common case and go deterministic), merged count rises from zero, corroborated count rises from zero, wall falls. **If model calls do not fall, the wiring has not done the thing it exists to do and that is a finding, not a tuning opportunity.**

**Sequence, per the eighty-first stamp:** this wiring lands **before** the Wells Fargo corpus runs and **before** the LOR read-only measurement run, so both measure the lawful shape. The eighty-sixth stamp's item 1 keeps that order intact.

---

## 4 · Risks

1. **Retiring maintained code.** `identify` is newer than the design replacing it. Mitigated by migrating the keyed-schema lesson into `requests()` in the same stretch (§1), not by keeping both.
2. **`AAO_Resolve` has never run in production.** It is exercised only by `AAO_ResolveTest`. Its deterministic legs are unproven on real bytes, and the throw-on-unknown-speaker-key in leg 2 is a loud failure mode on a fixture whose ingest is imperfect. **The first wired run should be a frozen fixture, not a customer-named deal**, and the throw should be read as an ingest finding rather than patched into a quiet `None`.
3. **The mention-Participant audit under A** is real work and is easy to skip because nothing fails loudly when it is skipped.
4. **The straddle divergence is untouched** and stays design's, per instruction.

## 5 · What this proposal does NOT do

No build, no wiring, no schema change, no deletion of `identify`, and no answer to §2. It does not touch the join-side backstop, call 3's blindness, the counting laws, or the merge key at verify.
