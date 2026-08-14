# The resolution wiring · PROPOSAL ONLY, NO BUILD · v2, written against Matthew's ruled ladder

**Supersession, stated rather than silent.** v1 of this document (git `28014d2`) held open a two-representation question — mention-Participant versus Shadow Person as the subject carrier. **Matthew has ruled and the question was the wrong one.** The shadow person is a HOLDING PEN, not a destination, and the design is a RESOLUTION LADDER. v1's §2 is superseded whole; v1's measurements survive and are carried forward here. The prior text stands in git history, not deleted.

**Authorizing bytes.** Eighty-sixth stamp queue item (c). Built to the eighty-first stamp's conditions 3(ii) through 3(v). **Nothing here is built.** Measurements are from the re-baselined tree at `28014d2`.

---

## 1 · THE RULED SHAPE · a three-rung ladder, each rung terminating correctly

A designator that names someone not on the roster enters a ladder. **Every rung terminates correctly on its own**, including the rung that finds nothing, and the ladder never ends in a guess.

### Rung 1 · INTERNAL

Match the designator against Contacts already on the account — **title, first name, or both**. A unique match binds. **AMBIGUOUS NEVER BINDS.**

This rung largely exists. `AAO_ResolveDesignator` carries the title rung and the given-name rung scoped to account and opportunity, and **`AAO_Resolve.cls:233` already refuses when context cannot separate candidates**, writing `Ambiguous` with its reason and the Identification flag's wording: *"matches more than one candidate and context cannot separate them here. The Identification flag's case; never a pick."* **That refusal is law and survives the wiring byte-for-byte.** The wiring must not "improve" it into a best-guess under any pressure to reduce rung-3 volume.

One correction the wiring owes this rung, carried from the eightieth stamp: the given-name rung matches EXACTLY, so `Fatima` does not link to `Fatema`. Rung 1 binding is exact-match binding. Fuzzy matching is not ruled and is not proposed here.

### Rung 2 · ENRICHMENT

A partner — ZoomInfo or another the org chooses — returns true last name, email, and title.

**FEATURE-DETECTED AND OPTIONAL, NEVER REQUIRED.** The same shape as LAW #1's discipline even though LAW #1 does not name enrichment: detect the capability from the runtime, ride it only where present, omit it otherwise. **Eighty percent of installs will have no partner configured and the ladder must terminate correctly with zero.** Concretely, and this is the acceptance criterion for the rung: with no partner configured, rung 2 is a no-op that costs nothing, logs nothing anyone must read, and passes the designator to rung 3 unchanged.

**ABSENCE IS NOT AN ERROR AND NEVER A FLAG.** No flag is raised because enrichment is unconfigured, unavailable, or returns nothing. A flag means a human must do something; an unconfigured partner is not a human's task. This is the silence law at a new surface.

Where the partner is configured and returns, what it returns is **sourced identity** and is governed by §2 below.

### Rung 3 · THE SELLER

A **yellow flag** naming the person **as heard** and asking who they are.

**Cleared by naming them, never by dismissal. No dismiss button exists anywhere in this product and none is added here.** The flag persists until a human supplies the identity, at which point the establishment re-attaches through the lawful path. A flag that can be cleared without answering it is a flag that teaches people to clear flags.

The person as heard is rendered verbatim as the designator was spoken — the ASR-name law, unchanged: what was said is the source form, and we never correct a transcript's spelling into what we think was meant.

---

## 2 · THE PROVENANCE BOUNDARY · new law this proposal honors

**The ESTABLISHMENT is evidence-bound. The IDENTITY is not.**

What was said by or about the person keeps its verbatim anchor forever: byte offsets against the frozen artifact, the quote, the speaker, the date. Nothing in this wiring touches that.

**Last name, email and title arriving from rung 1 or rung 2 are SOURCED FACTS carrying their own provenance.** They are:

- **never rendered as verbatim**
- **never blended into a quote**
- **never citable as speech**

**Two claims, two provenances**, and the word *verbatim* stays reserved for words spoken on a call. A run report, a card, a map note, or an Inspector walk-back that renders an enriched last name inside a quotation is a defect of the first order, because the receipt would then assert that someone said something they did not say — the exact fabrication the byte-offset discipline exists to prevent.

**Build consequence, concrete:** sourced identity fields never land on `AAO_Pair__c`'s evidence fields (`AAO_Answer_Text__c`, `AAO_About_Quote__c`, the offsets). They land on the identity record with their own source stamp. **The pen already supports this**: `AAO_Shadow_Person__c` carries `AAO_Source_Name__c`, whose own documentation in `AAO_PersonName` reads *"THE SOURCE STRING IS KEPT"* — the as-heard form and the resolved identity are already separate columns. A test asserts the boundary: an enriched surname must never appear inside any field the Inspector renders as a quote.

---

## 3 · MEASURED, as instructed · resolution mutates the roster as a side effect

**Yes. `AAO_Resolve.run()` performs two `insert` statements, and one of them writes `AAO_Participant__c` rows.**

- `insert mentionsToInsert` — mention-minted Participants, one per distinct designator that rung 1 links
- `insert rows` — the pair dispositions, which is the stage's own output and is expected

**What the minted row claims.** `AAO_Roster_Key__c = 'mention:<designator>'`, display name the designator verbatim, `AAO_Contact__c` the linked Contact, email carried from that Contact, `AAO_Internal__c = false`, `AAO_Substantive__c = false`, key `sourceId|mention:<designator>`.

**Idempotence: present.** `mentionFor()` dedupes within the transaction and queries `AAO_Participant_Key__c` before minting, so reruns on the same Source do not accumulate duplicates. This is a real mitigation and it is measured, not assumed.

**The risk, named precisely and separately from the object choice, as instructed.** `AAO_Participant__c` means *was on the call*. Resolution writing rows into it means **a read-shaped stage mutates the roster**, and the roster is the deterministic substrate that coverage, the internal check, and participant placement all read. Three non-test classes already carry the compensating filter — `AAO_Coverage`, `AAO_Identity`, `AAO_Resolve` — and **coverage's form of it is a string prefix**: `AND (NOT AAO_Roster_Key__c LIKE 'mention:%')`, written twice in two separate queries in that one file. A prefix convention is not a constraint; any future query that forgets it counts a mention as presence. There is also a **second, parallel mechanism** — `AAO_Substantive__c = false`, read by `AAO_Participants` — so today two different fields both mean "not really present," which is itself the one-flag-two-meanings hazard the eighty-first stamp named on disowning.

**This does not go away by switching objects, and that is the point of reporting it separately.** Under a shadow pen, resolution still writes; it writes `AAO_Shadow_Person__c` instead. What changes is not whether there is a write but **whether the written object's semantics claim something false**. A shadow row does not assert presence, so no compensating filter is owed and no future query can silently miscount. The write remains and must still be journalled.

**One adjacent finding, from the same read.** `run()` does DML and `requests()` makes a callout. `requests()` re-queries the org rather than taking `run()`'s in-memory output, so the two are designed as **separate transactions** — the class says so at line 241, *"this pair stays undisposed in this transaction and the caller decides whether to fire the leg."* **A driver that calls both in one transaction hits DML-before-callout**, which is precisely the driver error the eightieth stamp already recorded once on the verify buckets. The wiring must make the transaction boundary explicit at the call site, and the run report must show the two legs as separate stages.

---

## 4 · STILL OPEN, Matthew's · WHICH OBJECT IS THE PEN · held both ways, not settled

The ladder above is ruled and does not change under either answer. What changes is where a rung-1 or rung-2 resolution, and a rung-3 held identity, are parked.

### Option A · `AAO_Shadow_Person__c` as the pen · design's recommendation

- **Deployed already**, and named in the locked toggle-off rail.
- **First-class downstream**: `AAO_AnswerKey` carries `Shadow_Person` as a subject type; `AAO_Candidate__c` and `AAO_Claim__c` both carry the shadow lookup plus `AAO_Subject_Type__c`; `AAO_Commit` and `AAO_Replay` carry it through.
- **The provenance boundary is structural, not conventional**: `AAO_Source_Name__c` holds the as-heard form, `AAO_Promoted_Contact__c` and `AAO_Promoted_At__c` hold the resolved identity and when it resolved. §2 is enforced by the schema rather than by discipline.
- **No compensating filter is owed anywhere**, so coverage's two `LIKE 'mention:%'` clauses and the `AAO_Substantive__c` parallel mechanism can eventually retire.
- **`AAO_Resolve`'s ladder and its ambiguity refusal are RETARGETED onto it, not discarded.** The valuable parts of that file are the ladder and the refusal at line 233; the object it writes to is incidental to both.
- **Cost, measured and specific: `AAO_Pair__c.AAO_Person__c` is a lookup to `AAO_Participant__c` only.** The pair is the one stage in the chain that cannot express a shadow subject. Option A therefore needs `AAO_Pair__c` to gain a shadow lookup and a subject-type discriminator, mirroring `AAO_Candidate__c`, and every reader of `AAO_Person__c` must learn the discriminator — `AAO_Commit`, the join, the export, and the Inspector's walk-back, which renders a person from that single lookup.
- **The one thing Option A must not lose:** the mention-Participant carries an email from the linked Contact, and that is what lets the join's internal-domain gate catch a mentioned seller. A shadow row carries `AAO_Source_Name__c`, not a roster email. **Under Option A the internal-domain gate needs its own answer for mentioned people, or the twenty-second stamp's Pat case silently regresses.** This is the sharpest cost on either side and it is not hypothetical: Pat is a graded specimen.

### Option B · mention-minted `AAO_Participant__c` as the pen · what works today

- **Zero schema change.** Pair, candidate, claim, answer key and projection all work unmodified; this is the only option that can be wired without touching the object layer.
- **The internal-domain gate keeps working for mentioned people**, free, because the email rides from the Contact.
- **Cost: it obliges every consumer of `AAO_Participant__c` to filter the `mention:` prefix forever**, and that obligation is already live in three classes and duplicated twice inside one of them. The filter is a convention; nothing in the schema enforces it, and the failure mode is silent miscounting rather than an error.
- **Cost: the provenance boundary is enforced by discipline rather than structure.** A Participant row has no as-heard-versus-resolved split; the designator is the display name and any enriched surname would have to overwrite it or live elsewhere.
- **Cost: it asserts something false.** A roster row for a person who was not on the call.

### What changes in the build under each

- **Under A**: add the pair-grain shadow lookup and discriminator; audit and update the `AAO_Person__c` readers; re-answer the internal-domain gate for mentioned people; retarget `AAO_Resolve`'s leg 3 to mint shadows; retire the mention prefix filters once nothing writes mentions. §2's boundary comes free.
- **Under B**: no schema work; wire `AAO_Resolve` as it stands; **add the missing structural guard** so the prefix convention stops being load-bearing, and consolidate the two parallel "not really present" mechanisms into one; enforce §2 by test rather than by schema.

**Not settled here. Design recommends A with the ladder and the refusal retargeted; this proposal implements neither until Matthew rules.**

---

## 5 · Discharging the eighty-first stamp's conditions

**(ii) ONE implementation survives.** The survivor is the ladder above: deterministic legs in front, the model leg on the remainder only. `AAO_Pass.identify` retires into it. Because `identify` is `identify-2.0.0` and carries the 13 August keyed-schema conversion while `AAO_Resolve.requests()` is `resolve-requests-1.0.0`, **the keyed-schema lesson migrates into the surviving model leg as part of this wiring** — one property per unit, every key required, `keyedShardCount` driving sharding, the 400-despite-cap loud stop kept. The seventy-third stamp's law binds the model leg wherever it lives.

**(iii) Re-measure call 2's batch arithmetic and grammar cap.** `MAX_UNITS_PER_KEYED_CALL = 15` was measured on a stage handed every located pair. After wiring, the model leg sees only the remainder — and under the ruled ladder the remainder shrinks again, because rung 1 binds what it can and rung 3 holds the rest as flags rather than sending them to a model. Re-measure on the new shape; the old 15 does not carry forward.

**(iv) The ledger arithmetic restates.** `assertOneForOne` compares located against disposed, which a merge leg breaks. Restated: **located = merged + identified + ambiguous + none + held-for-flag + remainder**, checked at run level, every absorbed pair carrying `MERGED` and a pointer to its canonical so the sum is auditable by rows. A run whose arithmetic does not close does not count.

**(v) Measured before and after on the frozen fixtures.** Model calls, merged count, corroborated count, wall — plus, new under the ladder, **rung-1 binds, rung-2 enrichments, and rung-3 flags raised**. Expected direction, recorded so it can be shown wrong: model calls fall sharply, merged and corroborated rise from zero, wall falls, and **rung-3 flag count is a real number a human must work, so it is reported as a cost and never as a success metric.**

**Sequence:** this wiring lands **before** the Wells Fargo corpus runs and **before** the LOR read-only measurement run, per the eighty-first stamp and unchanged by the eighty-sixth.

---

## 6 · Risks

1. **`AAO_Resolve` has never run in production** — exercised only by `AAO_ResolveTest`. Its leg-2 throw on an unknown speaker key is a loud failure on imperfect ingest. **First wired run is a frozen fixture, never a customer-named deal**, and the throw is read as an ingest finding, not patched into a quiet `None`.
2. **Rung 3 volume is the honest cost of refusing to guess.** If rung 1 binds little and no partner is configured, rung 3 raises many flags. That is correct behaviour and must not be tuned down by loosening rung 1's ambiguity refusal.
3. **The roster side-effect and the transaction boundary** per §3, both of which survive the object choice.
4. **The straddle divergence stays untouched**, design's, per instruction.

## 7 · What this proposal does NOT do

No build, no wiring, no schema change, no deletion of `identify`, no answer to §4. It does not touch the join-side backstop, call 3's blindness, the counting laws, the merge key at verify, or `AAO_Resolve.cls:233`'s refusal, which survives intact under every option.
