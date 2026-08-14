# The resolution wiring · PROPOSAL ONLY, NO BUILD · v3

**Supersession history, stated rather than silent; every prior version stands in git, deleted nowhere.**

- **v1** (`28014d2`) held open a two-representation question, mention-Participant versus Shadow Person as the subject carrier. **Matthew ruled and the question was the wrong one:** the shadow person is a HOLDING PEN, not a destination, and the design is a RESOLUTION LADDER.
- **v2** (`ab6b4cc`) was written against the ladder but kept the two-object framing in §4 and **scored both sides wrongly** — it invented a Pat regression that the schema disproves, and asserted a field collision that the field's own description disproves. Both are corrected in place at §3 and §4 rather than quietly rewritten.
- **v3, this version.** §4 retires the two-object framing entirely on design's superseding finding, and holds open only what Matthew still owes.

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

**The risk, named precisely and separately from the object choice, as instructed.** `AAO_Participant__c` means *was on the call*. Resolution writing rows into it means **a read-shaped stage mutates the roster**, and the roster is the deterministic substrate that coverage, the internal check, and participant placement all read. Three non-test classes already carry the compensating filter — `AAO_Coverage`, `AAO_Identity`, `AAO_Resolve` — and **coverage's form of it is a string prefix**: `AND (NOT AAO_Roster_Key__c LIKE 'mention:%')`, written twice in two separate queries in that one file. A prefix convention is not a constraint; any future query that forgets it counts a mention as presence.

**CORRECTION, this document's own, marked in place per the corrections law.** v2 of this section claimed `AAO_Substantive__c` was a *"second, parallel mechanism"* meaning the same thing as the `mention:` prefix, and called it the one-flag-two-meanings hazard. ~~That claim is wrong and is withdrawn.~~ The field's own description says it is *"written by the participant writer, from the Source's substantive offset and duration"* and read by *"Coverage questions two and three, which say MEANINGFUL and HIGH QUALITY rather than merely counting occasions."* **That is present-but-barely-spoke. The `mention:` prefix is wasn't-there. Different concepts, no collision, no hazard.** The error was asserting a field's meaning from its name and its value rather than opening its description — the state-claim law, failed by this document one section after invoking it.

**The write does not go away by switching objects, and §4 now explains why that is the smaller half of the problem.**

### ADOPTED AS A WIRING CONSTRAINT, not a note

`run()` does DML and `requests()` makes a callout, and `requests()` **re-queries the org rather than taking `run()`'s in-memory output**, so the two are designed as **separate transactions** — the class says so at line 241: *"this pair stays undisposed in this transaction and the caller decides whether to fire the leg."*

**The wiring makes that boundary explicit AT THE CALL SITE**, not in a comment and not in a driver's habits. A driver calling both in one transaction hits DML-before-callout. **The precedent is cited there because it already cost us once: the eightieth stamp's verify-bucket error, where both verify buckets ran in one transaction and the callout followed the DML.** The run report shows the two legs as separate stages with their own timings.

---

## 4 · THE PEN · A AND B ARE ONE MISTAKE IN TWO SHAPES · v2's framing superseded

**v2 of this document framed §4 as a choice between two objects and scored the choice wrongly on both sides. Both errors are corrected here in place, and then the framing itself is retired.**

### Two corrections to v2, verified from the schema

1. ~~"A shadow row carries `AAO_Source_Name__c`, not a roster email… under Option A the internal-domain gate needs its own answer or the Pat case silently regresses. This is the sharpest cost on either side."~~ **WRONG.** `AAO_Shadow_Person__c.AAO_Email__c` exists as a first-class `Email` field, described as *"Written by: the create leg, where the roster carried one. Null is ordinary and is exactly why some people never resolve."* **The internal-domain gate's input is native on the shadow row, not a join away.** The Pat regression collapses to populating an existing field inside a create leg that is being written anyway. It was scored as the decisive cost and it is not a cost at all. The field was in this document's own earlier field listing and was not read — the same failure as the `AAO_Substantive__c` error in §3.
2. The `AAO_Substantive__c` collision claim is withdrawn; see §3.

### The finding that supersedes the framing

**`AAO_Shadow_Person__c` is not unbuilt. It is built for the OPPOSITE DIRECTION.** Its `AAO_Participant__c` lookup is ruled by its own description: *"the participation row this shadow was made from. Restrict on delete: participation is the evidence that this person exists at all, and a shadow whose participant vanished is a person nothing accounts for."* It exists for a Contact-less **ATTENDEE** — the case `AAO_Pair__c.AAO_Person__c`'s own description names: *"the 17 June fixture carries two participants with no Contact link, and a Contact lookup would silently drop them."*

**So both objects make "was on the call" the proof that a person exists, and a mentioned person violates that by definition.** `AAO_Resolve` does not solve this. It **fabricates participation to route around it**, and the `mention:` filter now spreading through three classes is that fabrication leaking outward. **Option A fabricates the same thing one object down**, because a shadow needs a participation row under Restrict. **A and B are one mistake in two shapes**, and choosing between them chooses which object carries the lie.

### DESIGN'S RECOMMENDATION, for Matthew · a second admissible existence proof

`AAO_Shadow_Person__c` gains an **utterance anchor** — designator, offset, Source — admissible **alongside** the participation row rather than instead of it. **A mention's proof of existence is that someone said the name, verbatim-anchored, which is the same evidence class everything else in this system stands on.** No new object.

Measured support for this shape, from the object as deployed:

- **The lookup is already nullable.** `AAO_Shadow_Person__c.AAO_Participant__c` carries `<required>false</required>`; the Restrict constraint governs *deleting* a participant, not whether one must exist. **The object has no validation rules at all.** So the second proof needs no relaxation of a required field — the existence rule lives in the create leg's code, which is where it will be extended.
- **The reason vocabulary already covers mentions.** `AAO_Reason__c` carries `Single_Token`, described as *"all we have is one spoken word: it may link and it may never create, because one token satisfies the LastName schema without being anybody's full name (eightieth stamp),"* beside `Unresolvable` and `Ambiguous`, *"which is the Identification flag's case."* The ladder's three outcomes already have their words on this object.
- **The promotion vocabulary already carries the ladder's result.** `AAO_Promoted_Contact__c` is *"THE PROMOTION PATH… The shadow row is never deleted on promotion: it is what the claims written before the promotion were keyed against, and deleting it would break the trail that says who they were when we only knew them from a call."* That sentence is this design already written down.
- **One concrete schema item the anchor needs, named so it is not discovered late.** `AAO_Shadow_Key__c` is *"Account id plus the lowercased email, or the account id plus the roster key where no email exists,"* unique per account. A mention has neither an email nor a roster key, so **the key needs a third branch** — account plus designator — and its uniqueness semantics decide whether two mentions of the same name on one account are one person. That is a design question inside the recommendation, not an objection to it.

### What this retires, and what it leaves open

**It retires v2's pair-lookup cost entirely. The pair does NOT need to express a shadow subject.** `AAO_Pair__c.AAO_Person__c` stays a Participant lookup, unchanged, and **IT BINDS ON PROMOTION**. Until the ladder resolves the mention, the pair is held with its verbatim anchor and **rung 3's flag is the surface a human works**. No reader audit, no discriminator, no migration of `AAO_Commit`, the join, the export or the Inspector walk-back. v2's §4 costed a change this design does not make.

**STILL OPEN, Matthew's, and it is the only thing this section holds open:** does an unresolved mention **RENDER on the map with its resolution state**, or stay **invisible until identified**?

- **Rendering it** makes the flag's subject visible where the seller already works and shows the machine's honesty about what it heard and could not place. It also puts an unidentified name on a customer-named relationship map, which is the surface the demo-narration trap exists to protect.
- **Keeping it invisible** guarantees nothing unresolved reaches the map, and makes rung 3's flag the only surface. It also means evidence exists that a seller cannot see until someone answers a flag.

Nothing is built on either answer. The ladder, the provenance boundary, and the existence-proof design above are unaffected by it.
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
3. **The roster side-effect** per §3, which the §4 design removes at its root rather than compensating for: a mention proved by its own utterance needs no fabricated participation, so no `mention:` filter is owed anywhere. **The transaction boundary** is no longer a risk but an adopted wiring constraint, per §3.
4. **This document has now been wrong twice by asserting a schema fact without opening the field description**, once on `AAO_Substantive__c` and once on the shadow email. Both were caught by design, not by this document. **Every schema claim in a future stretch is quoted from the field's own description or it is not made.**
5. **The straddle divergence stays untouched**, design's, per instruction.

## 7 · What this proposal does NOT do

No build, no wiring, no deletion of `identify`, and no answer to §4's open question. It **names** the schema work the recommended design implies — an utterance anchor on `AAO_Shadow_Person__c` and a third branch on `AAO_Shadow_Key__c` — and **builds none of it**. It does not touch the join-side backstop, call 3's blindness, the counting laws, the merge key at verify, or `AAO_Resolve.cls:233`'s refusal, which survives intact and unimprovable.
