# Build journal

Append-only. The only part ever rewritten is `## Current state`, the one block immediately
below. Everything under the session headings is permanent: wrong text is marked wrong, never
deleted.

---

## Current state

**Deployed to `altify--aossb2`, green, and clickable.** Org verified by query:
`00DWD00000DV7iT2AT`, Name `Altify`, `IsSandbox true`. Written from the org on 2 August, not
from the sessions below it — the block had gone thirty-seven sessions stale, which is the one
staleness the journal's own rules forbid.

**Eight custom objects, two custom metadata types, eight triggers, forty Apex classes, and
186 tests, 186 passing.** The objects: Source, Candidate, Claim, Claim Basis, Answer,
Evidence Contract, Flag, Participant. The types: Model Config (the model and charter pin) and
People Question (the ontology seed). Every object carries its trigger law; the metadata types
carry none because nothing machine-written ever touches them.

**The model path is live and has run on real transcripts.** The sentence this block carried
for thirty-seven sessions — *everything rests on proposals authored by hand* — is now false
and is retired. Extraction charter `AAO_Extract_Evidence` 1.1.0 and the blind reader
`AAO_Blind_Reader` 1.0.0 both run through `AAO_Extract` against the Anthropic API, and Gate 1
round two scored OUTCOMES 12/12 against staged ground truth with zero hallucinated spans.
The model name and both charter versions are pinned in the one `Default` Model Config record
(`claude-opus-5`), never hardcoded, and stamped on every row a run writes.

**What the pipeline does, all deployed and tested:** evidence arrives by an after-insert
event and is adjudicated asynchronously; spans are byte-verified against the frozen artifact;
the blind reader decides coverage independently; the speaker rule downgrades a seller's own
words; claims accumulate and replay rebuilds every answer in evidence-occurred order; the
evidence-family law (47/48) lets a claim rest on state instead of an artifact; the P route
answers from map rows and the Solution route from line items, both citing what they read and
freezing it; day-one red stands every gating proposition from deal creation; the
missing-relation and cardinality flags are general and live; the participant junction records
who was on each source so Coverage is a query.

**The People ontology is ours, seeded, and scope-aware — but no People charter is built.**
`AAO_People_Question__mdt` holds 56 seed records: the opportunity-map guided questions and
insight tests (v3.0), and as of v3.2 the account-map families and Decision Orientation.
`AAO_PeopleOntology.read(scope)` assembles them byte-exact behind a family guard that refuses
a short read per scope. **This is the ontology layer only.** The People projection writer
waits on two rulings (the rung derivation and the citation budget); Problems and Politics are
unopened; projection into Altify's own objects is a later phase and nothing touches them yet.

*Session 52, on the two sentences above.* **"Waits on two rulings" is spent and is corrected
here:** both closed, the citation budget at Charters §P7 v0.2 (Option C) and the Support rung
with it, and the Political Status derivation at Charters v2.1 under the ceiling model. The
writer waits on nothing but the build. **"Projection into Altify's own objects is a later
phase and nothing touches them yet" still stands as written and is deliberately NOT marked
superseded yet**, per the queue: it gets marked when the People harness lands, not before. It
was never a prohibition. The law forbids fields, metadata, triggers and logic on `ALTF__` and
native objects, while data rows on managed objects are the product's output surface, now
stated outright in Board v1.1 §3.

**The rehearsal is durable and is the demo spine.** `AAO Demo - Tungsten Rehearsal` carries
two claims and one answer written in separate transactions; a second deal carries the
seller-said-it downgrade; `AAO Demo - Live` starts empty with its gating reds standing. Tabs,
related lists and compact layouts are in place and `AAO_Admin` is assigned to Matt.

**Run the full suite:**

```bash
sf apex run test --target-org aossb2 --tests AAO_AccumulationTest AAO_TriggerLawTest AAO_LiveIngestTest AAO_DemoTest AAO_EvidenceLayerTest AAO_PipelineViewControllerTest AAO_AnswerKeyTest AAO_ScopeKeyTest AAO_ExtractTest AAO_DiscoveryTest AAO_FlagsTest AAO_MapRouteTest AAO_EvidenceFamilyTest AAO_ParticipantsTest AAO_MissingRelationTest AAO_SolutionRouteTest AAO_CardinalityTest AAO_PeopleOntologyTest --result-format human --wait 40
```

**The rehearsal and the live deal, from anonymous Apex** — passes are separate transactions
on purpose, and `ingestTwo` fires only once `status()` stops printing a `PENDING:` line:

`AAO_Demo.passOne()` · `AAO_Demo.passTwo()` · `AAO_Demo.passNegative()` · `AAO_Demo.status()`
· `AAO_Demo.purge()` — and `AAO_Live.ingestOne()` · `AAO_Live.ingestTwo()` ·
`AAO_Live.status()` · `AAO_Live.reset()`.

**The standing hazard, unchanged and load-bearing:** the only org we can query is Altify's
own, which holds every module and every label. Module licensing and custom-metadata upgrade
behaviour are both unverifiable here and are named as such rather than assumed.

### Carried forward from the duplicate block this replaces

Session 50 rewrote Current state but inserted the new text above the heading instead of
replacing what sat under it, so two Current state blocks stood side by side until session 52.
These facts lived only in the older one and are kept:

**The `AAO Pipeline` tab is live on the active Opportunity record page**, verified rendering
with real data, with the Altify panels and the Related tab intact. **Rollback is deploying
`ed71d06`'s copy of `Opportunity_Record_Page`.**

**Gate 1 round two runs on `AAO Gate1 - Model Round Two`**, which is isolated from the three
demo deals: `AAO_Gate1.reset()` · `AAO_Gate1.pass('T1SRC')` · `AAO_Gate1.pass('T2SRC')` ·
`AAO_Gate1.compare()`. The passes are separate commands because Apex forbids a callout after
DML in one transaction, the same reason the rehearsal's passes are separate. **Rows written
before session 7's defect was fixed are still in the org on that deal, deliberately, because
the proof register cites them.**

**Discovery has its own exit test:** `AAO_Discovery.exitTest()` passes end to end against
Evidence Contracts assembled by reading Altify's own rubric tables, with
`AAO_Question_Record_Id__c` carrying a real `ALTF__Assessment_Question__c` id. **Session 12's
entry contains the discovery spec**, every ALTF field name and behaviour read from the org
verbatim, including the two things Altify does not carry at all (speaker requirement and
route), which is why the per-org charter overlay is measured rather than predicted.

**Required reading before describing or quoting this build to anyone: sessions 4, 8, 9, 10
and 12.** Session 4 holds the stage inventory, the precise list of what executes against what
is authored in the fixture, and it is less flattering than the demo looks. Sessions 8 through
10 hold the blind reader's real behaviour and the two grades. The one sentence from that era
that is now simply false, *everything demonstrated so far rests on proposals authored by
hand*, was retired in session 50 and must not be quoted forward.

**Authored and model-written rows stay separable in the data**, because the charter version is
stamped on every row: fixture rows carry the version that authored them and model rows carry
the version on the Model Config record. The last reading recorded here put the three demo
deals at `0.1.0` (session 17 era) and that has not been re-queried since; treat the principle
as law and the value as owed a fresh read.

### Handoff — for a cold pickup in a new environment

Written 2 August 2026 (session 51) so this directory can move to another machine, another
agent, or another person and work continues without this conversation.

**What this is.** The build repo for Altify Always On: a Salesforce evidence-ledger system in
sandbox `altify--aossb2`, built solo by Matthew Weisberg with AI tooling ahead of a QBR the
week of 11 August. `force-app/` is the deployed source of truth; `docs/` is the design corpus
(read-reference — CODE never authors it, only syncs and reports); this journal is the build
record and the only narrative CODE writes.

**Read in this order.** 1) `docs/aao-board.md` — the orientation document: current state, the
locked-law list nobody relitigates, the open ledger with owners, next steps. 2) This block.
3) `docs/aao-charters.md`, the section for whatever is being built (§P7 holds the harness
briefs). Numbers always come from this journal, never from the documents; substance always
comes from the documents' stamped bodies, never from filenames. **Read the stamp inside every
file; filenames carry no version.**

**Org access, what a new machine needs.** The CLI alias is `aossb2` for
`matt.weisberg@altify.com.aossb2`; a fresh environment authenticates with
`sf org login web --alias aossb2 --instance-url https://test.salesforce.com` (needs Matthew at
the browser). `sourceApiVersion` is 66.0 against an org on 67. Standing absolutes: production
is read-only unconditionally; the `altify-pbo` org is never read; no metadata, triggers or
logic on any `ALTF__` or native object — data rows on managed objects are allowed, fields on
them are not; Opportunity and Account are never written; LAW #1 — no dependency on any ALTF
package version, ever. **The Anthropic API key exists only inside the org** (Setup → the
`AAO_Anthropic` External Credential's principal password slot). It has never entered this
repo, any chat, or any file, and must not. Model calls work in any environment once the org
is authenticated, because the key never left the org.

**Verify the build before trusting it.** Run the full-suite command above; expect **186 of
186**. `AAO_Demo.status()` from anonymous Apex shows the three demo deals; the rehearsal
commands beside it drive them. One pre-existing sandbox test (not ours) fails on a customer
validation rule.

**Journal discipline, binding on whoever continues.** Append-only; entries carry Did /
Decided-and-why / Read-from-the-org-verbatim / Assumed-not-verified / Owed; this Current
state block is the only text ever rewritten; every commit includes its journal entry; wrong
text is marked wrong, never deleted. Refusals get recorded with the platform's exact words —
the verbatim blocks are how this build catches its own assumptions.

**In flight at handoff.** Next build per the Board: the People harness (opportunity-level,
RM-only shape), whose brief — including the rung-derivation and citation-budget rulings —
now lives in `docs/aao-charters.md` §P7. Open and owed: the account reading-set composition
(how an account pass mixes shared `AM_OM_` questions with the AM-specific ones — deliberately
unguarded until ruled); Politics (opens after the People harness); the scope resolver
(design-frozen, not build-ready); Wave 2 shadow objects. Structurally unverifiable in this
org, parked, never assumed: module-licence detection, and package-upgrade behaviour of
subscriber-edited custom metadata.

---

## SUPERSEDED · the block that stood under this heading until session 52

**Do not read this as current. Every number in it is wrong.** It was written before session 17
and was superseded in full by the Current state block above, which session 50 rewrote from the
org. Session 50's rewrite was inserted above the heading instead of replacing what sat here,
so both blocks stood live at once until session 52 marked this one. **It is marked, not
deleted, per the standing law: wrong text is marked wrong, never deleted.**

**What is wrong in it, specifically:** seven objects and 136 fields (now eight objects and two
custom metadata types); five triggers (now eight); **128 tests (now 174)**; and the sentence
*everything demonstrated so far rests on proposals authored by hand*, which was true when
written and is now simply false, because the model path runs on real transcripts and Gate 1
round two scored OUTCOMES 12/12 with zero hallucinated spans. **That sentence must never be
quoted forward.** The operational facts worth keeping were carried up into the live block's
*Carried forward* section.

<details>
<summary>The superseded text, kept intact and folded shut</summary>

**Deployed to `altify--aossb2`, green, and clickable.** Org verified by query:
`00DWD00000DV7iT2AT`, Name `Altify`, `IsSandbox true`.

Wave 1 plus Flag is live: seven objects (136 fields), five triggers, three frozen key
composers, span verification, the speaker rule, commit, replay, the mini-rubric and the
dummy transcripts, plus two charters, the credential scaffolding they call through, and the
second reader that decides coverage, discovery with supersede, and day-one red.
**128 AAO tests, 128 passing.** One pre-existing sandbox
test still fails on a customer validation rule, and that failure is not ours.

**The rehearsal is durable.** `AAO Demo - Tungsten Rehearsal` carries two claims and one
answer, written in two separate transactions, and a second deal carries the seller-said-it
case. Tabs, related lists and compact layouts are in place, and `AAO_Admin` is assigned to
Matt.

```bash
sf apex run test --target-org aossb2 --tests AAO_AccumulationTest AAO_TriggerLawTest AAO_EvidenceLayerTest AAO_AnswerKeyTest AAO_ScopeKeyTest AAO_DemoTest --result-format human --wait 30
```

The rehearsal, from anonymous Apex — passes are separate transactions on purpose:

```bash
sf apex run --target-org aossb2 --file /dev/stdin <<< "System.debug(AAO_Demo.status());"
```

`AAO_Demo.passOne()` · `AAO_Demo.passTwo()` · `AAO_Demo.passNegative()` ·
`AAO_Demo.status()` · `AAO_Demo.purge()`.

The live deal, one artifact at a time — fire `ingestTwo` only once `status()` stops printing
a `PENDING:` line:

`AAO_Live.ingestOne()` · `AAO_Live.ingestTwo()` · `AAO_Live.status()` · `AAO_Live.reset()`.

**Evidence now arrives by event.** An after-insert on `AAO_Source__c` enqueues the same
pipeline the rehearsal runs. `AAO Demo - Live` was driven one artifact at a time and the
claims appeared asynchronously, without anybody asking for them.

**Before describing this build to anyone, read session 4's stage inventory.** It is the
precise list of what executes and what is authored in the fixture, and it is less flattering
than the demo looks. Session 4's one-line version was: *this is a working evidence ledger
with no reader attached, not a working extraction pipeline.*

**Session 7 changes that sentence, but only once the key is in.** A charter now exists that
reads a transcript, and it has never run. Until it does, the accurate statement is
unchanged: **everything demonstrated so far rests on proposals authored by hand.** The
distinction is visible in the data rather than a matter of trust. Fixture rows carry charter
version `0.1.0`; model rows carry the version on the config record, currently `1.0.0`. The
three demo deals are all `0.1.0`.

**The `AAO Pipeline` tab is live on the active Opportunity record page**, verified rendering
with real data, with the Altify panels and the Related tab intact. Rollback is deploying
`ed71d06`'s copy of `Opportunity_Record_Page`.

**Code freeze is lifted** as of session 7. The demo state is unchanged and was verified
after every change tonight: Tungsten Rehearsal `TRUE`, seller-said-it `UNVERIFIED`,
**AAO Demo - Live empty** and ready for a live ingest. Opportunity ids changed on the
session 6 reseed.

**The first real model call has run.** `claude-opus-5` read both dummy transcripts through
the Named Credential on 31 July, wrote Candidates only through `AAO_Pipeline`, and every
existing gate decided. Zero hallucinated spans across six citations. **99 AAO tests, 99
passing**, including eleven that exercise the model path against mocked responses.

**Session 8 added the second reader, and it works on the specimen it was built for.** The
blind reader receives the proposition, its elements and the located spans, never the
transcript and never the first verdict, and its no overrides claimed coverage. On
`AAO Gate1 - Blind Reader` it refused the element whose quote refuted it, coverage fell to
partial, and the run wrote `UNVERIFIED -> TRUE` with the first claim untouched, which is the
staged ground truth. Graded two ways, `PROPOSALS 11/12` and `OUTCOMES 12/12`: the single
proposal difference disappears at the outcome line, which is the correct reading of it. Read
sessions 8, 9 and 10 before quoting any of it.

**Session 7's defect is fixed. Rows written before it was are still in the org**, on
`AAO Gate1 - Model Round Two`, deliberately, because the proof register cites them.

The three demo deals are untouched throughout: charter version `0.1.0`, `UNVERIFIED -> TRUE`
as they always did.

Gate 1 round two, once the key is in, on `AAO Gate1 - Model Round Two`, which is isolated
from the three demo deals:

`AAO_Gate1.reset()` · `AAO_Gate1.pass('T1SRC')` · `AAO_Gate1.pass('T2SRC')` ·
`AAO_Gate1.compare()`

The passes are separate commands because Apex forbids a callout after DML in the same
transaction, which is the same reason the rehearsal's passes are separate.

**Discovery landed in session 12.** The accumulation exit test passes end to end against
Evidence Contracts assembled by reading Altify's own rubric tables, with
`AAO_Question_Record_Id__c` carrying a real `ALTF__Assessment_Question__c` id. Run it with
`AAO_Discovery.exitTest()`. **Session 12's entry contains the discovery spec**: every ALTF
field name and behaviour that had to be read from the org, verbatim, including the two things
Altify does not carry at all, speaker requirement and route, which is why the per-org charter
overlay is now measured rather than predicted.

</details>

---

## 2026-07-30 · session 1

**Did.** Created the repo at `~/Downloads/aao-sandbox` (sibling of the `aao-context`
folder the design documents were handed over in). Copied the five design documents into
`docs/`. Authored the six Wave 1 objects as metadata — `AAO_Source__c`,
`AAO_Evidence_Contract__c`, `AAO_Candidate__c`, `AAO_Answer__c`, `AAO_Claim__c`,
`AAO_Claim_Basis__c`, 110 fields — plus an `AAO_Admin` permission set. Wrote the three
frozen key composers (`AAO_ScopeKey`, `AAO_AnswerKey`, `AAO_ContractKey`), their tests
first per the brief, the four trigger laws, the normal form and span verifier, the speaker
rule, `AAO_Commit`, `AAO_Replay`, the mini-rubric and dummy transcripts as a static
resource, and the exit test. 21 Apex classes, 4 triggers.

**Decided, and why.**

- **`Opportunity` added as a sixth `AAO_Subject_Type__c` value.** The field tables give
  five typed subject lookups (Contact, Shadow Person, Insight Card, Qualifier, Decision
  Criterion) and say "one populated". `AAO_T1` — the proposition the exit test runs on — is
  deal-grain: `Per_Person_Source` is null and there is no person it is about. With only the
  five, a deal-grain answer has no composable subject at all. So `Opportunity` is a subject
  type whose subject is the row's own `AAO_Opportunity__c`. **This is an addition to a
  CLOSED table and needs ratifying.** The alternative — a nullable subject rendering as
  empty in the key — is precisely the failure the composer tests exist to prevent.

- **Four of the six subject types are unwired, and throw by name.** `AAO_Shadow_Person__c`
  is Wave 2. Insight Card, Qualifier and Decision Criterion are managed objects whose API
  names have not been read from the org. `AAO_AnswerKey` refuses to compose for them rather
  than guessing an API name — evidence over inference about schema. The error says "not
  wired", so a future session gets told rather than surprised.

- **Separator in the composed keys is `|`, not the `·` the field table uses.** The
  document's middle dot is display. ASCII, absent from Ids and hex, and asserted by test to
  appear exactly three times so the key cannot be ambiguous.

- **`AAO_ContractKey` carries no version token, and the other two do.** 18 + 1 + 64 = 83,
  which is exactly `Text(83)`. The field length *is* the arithmetic, so there is no room
  for one. That makes a shape change a field-length change, which is the right forcing
  function. `AAO_ScopeKey` (90 of 101) and `AAO_AnswerKey` (59 of 120) have room and carry
  `S1` / `A1`.

- **Uppercase hex fingerprints are rejected, not folded.** Folding would be a silent
  transform on identity; accepting both cases would let one artifact produce two Sources
  and dedup would quietly stop working.

- **Normal form v1 is frozen here** (`AAO_NormalForm`): one turn per line,
  `<speakerKey>\t<utterance>`. Something concrete had to exist for contiguity to be
  checkable at all. What is frozen is the **read** side — whatever eventually writes
  `AAO_Normalized_Text__c` must produce this shape, because every span already stored was
  verified against it. **Needs ratifying; it was invented to make the test runnable.**

- **Commit and replay share one accumulation function** (`AAO_Accumulate`). Two
  implementations would be two accounts of one fact with no mechanism to say which had
  drifted, and the replay test would then be testing itself.

- **The speaker requirement gates the verdict, not the coverage.** A failing speaker
  requirement writes `UNVERIFIED` carrying the receipts, rather than recording that nothing
  was said. The words were said; what failed is who said them. This is what makes the
  brief's negative case come out as specified.

- **Coverage is evaluated on the accumulated total, not on the single pass.** That is what
  lets call two say there was already partial evidence and now it is sufficient.

- **Transcripts live once, as a static resource, not duplicated under `seed/`.** The brief's
  layout puts them in `seed/transcripts/`; Apex must read the exact bytes a span was
  verified against, which means a deployable static resource. A second copy would be the
  two-accounts-of-one-fact pattern this project rules against everywhere else. `seed/`
  holds READMEs that say where the bytes are and why. **A deliberate deviation from the
  brief's stated layout.**

- **Spans in the fixture are authored as quotes, never offsets.** `AAO_Seed` resolves them
  against the composed text and refuses if a quote is absent or occurs twice. Hand-written
  offsets would be a second account of where the words are.

- **A test seam for the merge path.** `AAO_Commit.simulateLostRace` makes the first
  read-before-write miss, so the insert genuinely collides and the real `DUPLICATE_VALUE`
  branch runs. There is no way to stage true concurrency inside one transaction, and
  asserting only that the unique index exists would have left the merge branch untested.

- **`AAO_Admin` permission set added**, which the brief's layout does not mention.
  Metadata-API-deployed custom objects grant nobody access, including the deploying admin,
  so without it the org looks empty after a successful deploy.

- **Repo lives beside `aao-context`, not inside it.** The context folder is the input and is
  described as a running collection to be handed over; the repo is the output and has to be
  self-sufficient somewhere else.

**Read from the org.** *Nothing.* No org was queried this session, and that is the single
most important line in this entry.

`sf org list` returned two authenticated orgs and neither is the target:

> `"alias": "altify-dev"`, `"orgId": "00Dg500000B0KjZEAV"`, `"name": "GRM TEK Corp"`,
> `"isSandbox": false`, `"connectedStatus": "Connected"`

> `"alias": "ice"`, `"orgId": "00Dal00001ToGLKEA3"`, `"name": "ICE Mortgage Technology"`,
> `"isSandbox": false`,
> `"connectedStatus": "Unable to refresh session due to: Error authenticating with the
> refresh token due to: authentication failure"`

> `"sandboxes": []`

`altify--aossb2` does not appear. `sf org login web` opens a browser and requires
credentials to be typed, which is not something this session can do on Matthew's behalf.

Tooling actually observed on this machine:

> `@salesforce/cli/2.135.7 darwin-arm64 node-v22.23.1`
> (`Warning: @salesforce/cli update available from 2.135.7 to 2.145.6.`)

`sf project generate` wrote `"sourceApiVersion": "66.0"`.

**Assumed, not verified.** Everything here is a hypothesis until the deploy runs.

- **The Apex has never been compiled.** No org, no compiler. The strongest offline check
  run was a cross-reference of every `AAO_*__c` token in Apex against the generated
  metadata: all resolve except `AAO_Shadow_Person__c`, which appears only in a comment.
  That catches typos. It does not catch type errors, method signature errors, or anything
  about how the platform actually behaves.
- **API version 66.0.** The CLI's default. The two other authenticated orgs report
  `"instanceApiVersion": "67.0"`, so 66.0 should be accepted, but `altify--aossb2` has not
  been asked.
- **Circular lookups deploy in one pass.** `AAO_Answer__c.AAO_Last_Claim__c` points at
  Claim and `AAO_Claim__c.AAO_Answer__c` points back. Metadata API generally handles this
  when both objects are in one deployment. If the deploy fails on it, deploy the objects
  without those two fields first, then add them.
- **`Database.insert(record, false)` returns `StatusCode.DUPLICATE_VALUE` for a unique
  external-id collision.** The whole merge path rests on this and it has not been observed.
- **Restricted picklist values are accepted as written.** `TRUE` and `FALSE` as picklist
  API names in particular are worth watching.
- **`AAO_Seed` reads its static resource inside tests.** `StaticResource` should be visible
  without `SeeAllData`. Not confirmed.
- **The `AAO_Admin` permission set omits required and master-detail fields from
  `fieldPermissions`**, which is what the Metadata API wants. Not confirmed by a deploy.
- **Opportunity stage.** `AAO_Seed.defaultStage()` reads the first active picklist value
  rather than assuming `Qualification`, so this should be safe, but the sandbox's stage
  configuration is unknown.

**Owed.** Carried forward until done.

1. **Authenticate `altify--aossb2` and deploy.** Everything else is blocked behind this.
   Record the org id, the API version the org actually reports, and the exact CLI version
   in the next entry, quoted.
2. **Run the exit test and record what it actually says**, including failures, verbatim.
3. **Seed into the org's own rubric records.** `AAO_Seed` writes
   `AAO_Evidence_Contract__c` rows **directly, which skips discovery entirely**. The brief
   asks for the propositions to be authored into the org's own rubric records so discovery
   walks its real path — the per-org discovery test against a foreign rubric that is the
   whole reason a Developer sandbox is the right place to do this. Needs the Altify rubric
   object API names read from the org. **This is the largest gap between this repo and the
   brief.**
4. **`AAO_Claim__c.AAO_Internal_Person__c` is never populated.** Key four of four, and the
   field table warns in terms: *a grain not recorded cannot be declared later without
   reprocessing the corpus, which means re-paying every model call.* It should resolve from
   participants rather than the deal owner, and the sandbox roster has no real `User` to
   resolve to. **Decide before any volume of claims is written.**
5. **`AAO_Claim_Basis__c` is deployed and written by nothing.** Commit only produces
   `Basis = 'Transcript'` claims. Routes P and C need it, and a claim citing state must
   name the row and quote its value.
6. **Contradiction between two current documents, unresolved.** The field tables make
   `AAO_Claim_Basis__c.AAO_Claim__c` a **required Master-Detail to Claim**. The flags
   document says a basis row hangs off a claim **or off a flag**, making the junction's
   parent polymorphic, and explicitly rejects giving Flag its own snapshot mechanism. Those
   cannot both hold. Built per the field tables, because Flag is not in the replay path.
   Changing it later means demoting a master-detail to two lookups plus a parent-type
   discriminator, losing cascade delete — not free. **Matthew's call.**
7. **`AAO_Answer__c` has no subject-deleted flag.** The field table says "null-and-flag on
   subject delete" and names no flag field. `AAO_Claim_Basis__c` has
   `AAO_Cited_Row_Deleted__c` explicitly. Not added, because adding a field to a CLOSED
   table is a design change and not this build's to make.
8. **`AAO_Candidate__c.AAO_Run__c` is not built.** The field table has it as a required
   lookup to `AAO_Run__c`, which is Wave 2. Omitted rather than faked. Bookmarks, retries,
   dead letters and the lease all read it.
9. **Internal domains are a caller argument, not org configuration.** `AAO_SpeakerRule`
   takes them as a parameter. Buyer/seller derivation is rule data and belongs in org
   config; inventing a configuration object mid-build would have been improvising it.
10. **`AAO_Flag__c` is not built.** Closed in the flags document, not in the replay path,
    correctly deferred per the brief. Its trigger law (type immutable after insert) is
    therefore also not built, so only three of the brief's "four trigger laws" exist. The
    fourth built trigger is `AAO_EvidenceContractTrigger`, which the brief does not list but
    which the field table requires — `AAO_Contract_Key__c` is written by a trigger.
11. **Normal form v1 and the `Opportunity` subject type both need ratifying**, per Decided
    above.
12. **The four project documents are still behind.** Architecture, Glossary, Object Model
    and Data Flow carry the old vocabulary where Claim meant the current-state row.
    `docs/aao-corrections-v1_0.md` is authoritative until they are bumped.

---

## 2026-07-30 · session 2

**Did.** Matthew authenticated `altify--aossb2`. Deployed. The first deploy failed on
three root causes and a cloud of cascades; fixed all three, redeployed clean, ran
`RunLocalTests`. **All 67 AAO tests pass, including the exit test.** Session 1's entire
"Assumed, not verified" list is now settled — resolved below, each one.

**Decided, and why.**

- **`AAO_Commit.commit` renamed to `AAO_Commit.commitCandidate`.** `commit` is an Apex
  reserved word — the parser reads it as the DML statement, so the method declaration
  never parsed and every statement in the class became an orphan. The domain word is kept
  in the class name, where it is safe.

- **`AAO_Model`'s `String json` parameters renamed to `raw`.** Apex is case-insensitive,
  so a parameter named `json` shadowed the `JSON` system class and `JSON.deserialize`
  resolved to `String.deserialize`. Three methods, one cause, and a good example of a
  defect that no amount of reading catches and one compile finds instantly.

- **Case-sensitivity on the fingerprint fields is enforced in Apex, not by the field.**
  The platform refuses `caseSensitive` on a text field that is not also `unique`. The field
  tables mark `AAO_SHA256__c`, `AAO_Artifact_SHA256__c`, `AAO_Content_Hash__c`,
  `AAO_Question_Record_Id__c` and `AAO_Question_Fingerprint__c` case-sensitive; that
  annotation is **not implementable as a metadata flag** on any of them. Set to `false`,
  with the reason written into each field's org-visible description. The intent survives
  because `AAO_ScopeKey` and `AAO_ContractKey` reject anything that is not 64 lowercase
  hex — rejected, not folded. The two keys that *are* unique (`AAO_Scope_Key__c`,
  `AAO_Answer_Key__c`) keep real platform case sensitivity. **The field tables should be
  corrected**: case-sensitive is a property those five fields cannot have.

**Read from the org.** All verbatim.

Org identity:

> `alias aossb2`, `username matt.weisberg@altify.com.aossb2`,
> `id 00DWD00000DV7iT2AT`,
> `instanceUrl https://altify--aossb2.sandbox.my.salesforce.com`,
> `apiVersion 67.0`

> `@salesforce/cli/2.135.7 darwin-arm64 node-v22.23.1`

`sourceApiVersion` in `sfdx-project.json` is `66.0` and the org accepted it.

Deploy one, the three root-cause errors:

> `CustomField │ AAO_Source__c.AAO_SHA256__c │ CaseSensitive can only be set for fields with unique also set (188:13)`

> `ApexClass │ AAO_Commit │ Unexpected token ')'. (33:76)`

> `ApexClass │ AAO_Model │ Method does not exist or incorrect signature: void deserialize(String, System.Type) from the type String (47:36)`

and the cascade that named the reserved word plainly:

> `ApexClass │ AAO_TriggerLawTest │ Method does not exist or incorrect signature: void commit(Id, Set<String>) from the type AAO_Commit (134:20)`

Deploy two: every component `Created`, no errors.

Test run `707WD0000A4HF8Q`:

> `Tests Ran 86`, `Pass Rate 99%`, `Fail Rate 1%`, `Org Wide Coverage 86%`,
> `Org Id 00DWD00000DV7iT2AT`, `Username matt.weisberg@altify.com.aossb2`

The single failure is **pre-existing sandbox code, not ours**:

> `ConvertToOpportunityTest.testgetOppCreationDetails  Fail  System.DmlException: Insert
> failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, AE
> Summary is required when no opportunity is created. Please document your call notes
> before saving: [AE_Summary__c]`

This is worth keeping. It is a live instance of Owed item **write-blocking customer
constraints**, named in the brief's "known to be missing": a validation rule that makes a
write fail for reasons that have nothing to do with our evidence. Discovery must read
validation rules alongside the rubric, and a blocked write must record itself as blocked
with the rule named, and never throw. The sandbox has one already, uninvited.

Every AAO test passed. The four that carry the exit test:

> `AAO_AccumulationTest.theAccumulationTest  Pass  1222`
> `AAO_AccumulationTest.replayingOnlyTheFirstClaimGivesUnverified  Pass  1188`
> `AAO_AccumulationTest.theSameWordsFromTheSellerDoNotEstablishIt  Pass  815`
> `AAO_AccumulationTest.anUnsegmentedArtifactVerifiesButCannotSatisfyTheSpeakerRule  Pass  2634`

Coverage on our classes: `AAO_Accumulate 100%`, `AAO_SourceTriggerHandler 97%`,
`AAO_ScopeKey 95%`, `AAO_AnswerTriggerHandler 93%`, `AAO_Seed 93%`, `AAO_Model 91%`,
`AAO_AnswerKey 90%`, `AAO_NormalForm 90%`, `AAO_EvidenceContractTriggerHandler 84%`,
`AAO_SpanVerifier 83%`, `AAO_SpeakerRule 83%`, `AAO_Replay 82%`, `AAO_Commit 80%`,
`AAO_ClaimTriggerHandler 76%`, `AAO_ContractKey 63%`. All four triggers 100%.

**Assumed, not verified.** Session 1's list is now settled. Recording the resolutions,
because a list that only grows is not being read.

- ~~The Apex has never been compiled.~~ **Compiled and run.**
- ~~API version 66.0 may not be accepted.~~ **Accepted.** Org reports 67.0.
- ~~Circular lookups may not deploy in one pass.~~ **They do.**
  `AAO_Answer__c.AAO_Last_Claim__c` and `AAO_Claim__c.AAO_Answer__c` deployed together
  with no special handling.
- ~~`Database.insert(record, false)` returns `DUPLICATE_VALUE` on a unique external-id
  collision.~~ **It does.** `duplicateValueIsAMergePathNotAnErrorPath` passes, and it
  drives the real branch through the `simulateLostRace` seam rather than asserting the
  index exists.
- ~~`TRUE` / `FALSE` as restricted picklist API names.~~ **Accepted.**
- ~~`StaticResource` readable in tests without `SeeAllData`.~~ **It is.**
- ~~The permission set's omission of required and master-detail fields.~~ **Correct shape.**
- ~~Opportunity stage picklist.~~ `AAO_Seed.defaultStage()` reads it live and worked.

Still assumed, and new:

- **Nothing has been seeded as durable data.** Every fixture exists only inside test
  transactions, which roll back. Nobody can open the org and look at the two claims.
- **Coverage is not correctness.** `AAO_ContractKey` at 63% and `AAO_ClaimTriggerHandler`
  at 76% are mostly untaken error branches, but that is an inference and has not been
  checked line by line.
- **The exit test runs both passes inside one transaction.** The eleven-day gap is asserted
  on `AAO_Evidence_Occurred__c` precisely so processing order cannot carry the test, but a
  genuine two-transaction run has not happened.

**Owed.** Items 1 and 2 from session 1 are done. The rest carry forward, renumbered, with
two additions.

1. **Seed into the org's own rubric records.** Unchanged and still the largest gap.
   `AAO_Seed` writes `AAO_Evidence_Contract__c` directly, skipping discovery. Needs the
   Altify rubric object API names read from the org. `altify-pbo` is now authenticated and
   probably carries the ALTF package; a read-only describe against it would answer this,
   and Matthew was asked and has not yet ruled.
2. **Leave a durable seeded run in the org**, so the two claims and the answer can be
   opened and looked at rather than only asserted. This is the Toby artifact.
3. **`AAO_Claim__c.AAO_Internal_Person__c` is never populated.** Key four of four. *A grain
   not recorded cannot be declared later without reprocessing the corpus.*
4. **`AAO_Claim_Basis__c` is deployed and written by nothing.** Routes P and C need it.
5. **Claim Basis parent: field tables say required Master-Detail to Claim, flags document
   says polymorphic across claim-or-flag.** Unresolved contradiction. Matthew's call.
6. **`AAO_Answer__c` has no subject-deleted flag**, though the field table says
   "null-and-flag on subject delete".
7. **`AAO_Candidate__c.AAO_Run__c` is not built.** `AAO_Run__c` is Wave 2.
8. **Internal domains are a caller argument, not org configuration.**
9. **`AAO_Flag__c` is not built**, so its trigger law is not built either.
10. **Normal form v1 and the `Opportunity` subject type need ratifying.**
11. **NEW: the field tables mark five fields case-sensitive that cannot be.** See Decided.
12. **NEW: write-blocking customer constraints have a live example in this sandbox.**
    `ConvertToOpportunityTest`'s failure is the shape of the problem, sitting in the target
    org already.
13. **The four project documents are still behind.** `docs/aao-corrections-v1_0.md` is
    authoritative until they are bumped.

---

## 2026-07-31 · session 3

**Did.** Verified the target org by query before touching anything. Built `AAO_Flag__c`
and its trigger law. Added the synthetic marker across all seven objects. Wired key four.
Built `AAO_Demo`, the durable rehearsal, and ran it as three separate transactions. Added
tabs, compact layouts and Opportunity related lists, and assigned `AAO_Admin`. Confirmed
the ALTF rubric objects exist in this org and are empty. **74 AAO tests, 74 passing.**
Discovery was deliberately not started; it stays owed.

**Decided, and why.**

- **`AAO_Flag__c` was built, ahead of anything that raises flags.** The walkthrough asked
  for a Flag tab and a Flag related list, and both need the object. The law arrives with
  it — type immutable after insert, raised-at immutable, no delete on the live path — so
  that when a raise path is eventually written it cannot quietly introduce a mutable type.
  **The tab and the related list will be empty**, because nothing raises flags yet, and an
  empty related list is the honest state rather than a fabricated red.

- **`AAO_Synthetic__c` added to all seven objects.** Another addition to closed tables, and
  it needs ratifying alongside `Opportunity` as a subject type. It is deliberately
  *operational*: no law reads it, nothing routes on it. It exists so the rehearsal is
  removable in one action and so anyone opening this org can tell a rehearsal row from a
  real one without asking. Stamped by the before-insert triggers from a static, so the
  demo concern stays out of `AAO_Commit` entirely.

- **Purge needs two conditions, not one.** `AAO_Synthetic.PURGING` alone is not enough:
  the handlers permit a delete only when purging **and** the row carries the marker. A real
  claim cannot be deleted even with the flag on. This is a narrow synthetic-only door, not
  the retirement path — confirm-then-purge with library acknowledgement first is still owed
  and this is not it.

- **Standard objects get no marker field.** Account, Opportunity and Contact are matched by
  name in the purge instead, which is why the names are deliberately unmistakable
  (`AAO Demo - Tungsten Rehearsal`). Adding a field to a standard object for a rehearsal
  would be a permanent change to the customer's schema for a temporary purpose.

- **Key four resolves by preference, not by presence.** `AAO_Internal_Person__c` takes the
  internal participant who actually **spoke in the cited spans**, falling back to an
  internal participant merely present on the call, and never the deal owner — who may not
  have been in the room. The roster gained a `userId`, seeded with the running user.

- **The Opportunity layout was retrieved and patched, never overwritten.** This sandbox has
  real customisation on it — seventeen existing related lists, a `ConvertToOpportunity`
  flow, Celigo layouts. The four new related lists were appended after the last existing
  one so schema element order is preserved. Claims and Sources sort ascending on
  `AAO_Evidence_Occurred__c`, so the page reads as a timeline rather than as processing
  order.

- **Motifs were read from the org rather than guessed.** Retrieved the existing custom tabs
  and took five known-valid values from them. Flag gets `Custom53: Bell`, because it is the
  thing that comes looking for you.

- **Only the standard `Opportunity Layout` was patched.** The two Celigo layouts could not
  be retrieved (see the org quote below) and were left alone rather than forced.

**Read from the org.** All verbatim.

Identity, which was the first thing done and the reason to do it first:

> `Id,Name,IsSandbox,InstanceName,OrganizationType`
> `00DWD00000DV7iT2AT,Altify,true,USA758S,Enterprise Edition`

**The ALTF rubric objects exist here and every one is empty.** One describe, in
`altify--aossb2` only. Nothing was read from `altify-pbo`.

> `ALTF__Assessment_Question__c rows=0` · `ALTF__Assessment_Answer__c rows=0` ·
> `ALTF__Account_Plan_Question__c rows=0` · `ALTF__Account_Question__c rows=0` ·
> `ALTF__Account_Plan_Type_Question__c rows=0` · `ALTF__Sales_Process_Qualifier__c rows=0` ·
> `ALTF__Template_Qualifier__c rows=0` · `ALTF__Qualifier_Answer__c rows=0` ·
> `ALTF__Sales_Process__c rows=0` · `ALTF__Insight_Card__c rows=0` ·
> `ALTF__Decision_Criteria__c rows=0` · `ALTF__Relationship_Map_Persona__c rows=0` ·
> `ALTF__Contact_Map_Details__c rows=0` · `ALTF__Opportunity__c rows=0`

This is the standing hazard, confirmed rather than argued: **a Developer sandbox copies
metadata, not data.** Day one really is a per-org discovery test against empty rubric
tables.

**It also answers two of the four unwired subject types**, though nothing was wired
tonight. `ALTF__Insight_Card__c` and `ALTF__Decision_Criteria__c` exist under those exact
names. `Qualifier` has more than one candidate — `ALTF__Sales_Process_Qualifier__c`,
`ALTF__Template_Qualifier__c`, `ALTF__Qualifier_Answer__c` — so which one a qualifier
subject points at is a real decision and not a lookup. Recorded, not acted on.

Layout retrieval:

> `unpackaged/package.xml │ Entity of type 'Layout' named 'Opportunity-Celigo Opportunity Contract Layout' cannot be found`
> `unpackaged/package.xml │ Entity of type 'Layout' named 'Opportunity-Celigo Opportunity Layout' cannot be found`

Valid tab motifs, read from the org's own tabs:

> `Custom15: People` · `Custom20: Airplane` · `Custom24: Building` · `Custom53: Bell` ·
> `Custom98: Truck`

Permission set assignment:

> `matt.weisberg@altify.com.aossb2 │ AAO_Admin`

Test run: `Tests Ran 74`, `Pass Rate 100%`, `Fail Rate 0%`.

**The durable rehearsal, as it now stands in the org.** This is the QBR artifact, quoted
from `AAO_Demo.status()`:

> `--- AAO Demo - Tungsten Rehearsal (006WD00000Sj16IYAR)`
> `    answer ANS-00000000 AAO_T1 = TRUE by MACHINE coverage={"v":1,"missing":[],"covered":["e1","e2","e3"]}`
> `    claim  CLM-00000000 null -> UNVERIFIED (Established) occurred=2026-06-15 recorded=2026-07-31 12:08:05 key4=005V400000MCTUbIAP src=dummy/transcript-one`
> `    claim  CLM-00000001 UNVERIFIED -> TRUE (Established) occurred=2026-06-26 recorded=2026-07-31 12:08:07 key4=005V400000MCTUbIAP src=dummy/transcript-two`
> `    candidates=12 sources=2`
> `--- AAO Demo - Tungsten Rehearsal (seller said it) (006WD00000Sj16JYAR)`
> `    answer ANS-00000001 AAO_T1 = UNVERIFIED by MACHINE coverage={"v":1,"missing":[],"covered":["e1","e2","e3"]}`
> `    claim  CLM-00000002 null -> UNVERIFIED (Downgraded) occurred=2026-06-26 recorded=2026-07-31 12:08:10 key4=005V400000MCTUbIAP src=dummy/transcript-two-wrong-speaker`
> `    candidates=6 sources=1`

`005V400000MCTUbIAP` is `Matt Weisberg, matt.weisberg@altify.com.aossb2`. Every claim
carries it. **Key four is exercised, not dead.**

Three things in that output are worth pointing at during the walkthrough:

1. **`recorded=12:08:05` and `recorded=12:08:07`.** Two seconds apart, because they are two
   transactions. `occurred=2026-06-15` and `occurred=2026-06-26` are eleven days apart,
   because the transcripts say so. The exit test asserts the second pair and cannot produce
   the first; this run produces both. Session 2's "still assumed — the exit test runs both
   passes inside one transaction" is now settled.
2. **`CLM-00000000` still says `UNVERIFIED` and always will.** The answer says `TRUE`. Both
   are readable at once, and the delta between them is the thing a brief reads.
3. **The negative deal has full coverage and an `UNVERIFIED` answer.**
   `covered:["e1","e2","e3"]`, `missing:[]`, verdict `UNVERIFIED`, claim outcome
   `Downgraded`. All three parts were said and it still does not establish, because the
   seller said them. That is the Gate 1 run-two regrade, sitting in an org, clickable.

Marker check:

> `MARK 0 unmarked claims, 3 total`

**Assumed, not verified.**

- **The Flag tab and the Flag related list will be empty.** Correct, and stated so nobody
  reads absence as a defect — but it does mean the walkthrough shows a flag *shape*, not a
  flag.
- **The Celigo Opportunity layouts were not touched.** If Matt's profile uses one of them
  rather than the standard `Opportunity Layout`, the related lists will not appear and the
  layout will need patching by hand. Not checked, because checking it means reading profile
  layout assignments and the standard layout is the overwhelmingly likely one.
- **`AAO_Demo.purge()` has been exercised in a test transaction, never for real.** The
  order-of-deletion reasoning against the Restrict constraints is sound and tested, but the
  durable rows in the org have not been through it.
- **Compact layouts are assigned but have not been looked at in a browser.**

**Owed.** Session 2's items, renumbered, with what changed.

1. **Seed into the org's own rubric records — start discovery.** Unchanged and still the
   largest gap, but the ground is now prepared: the rubric objects are confirmed present and
   empty, and their API names are recorded above. Deliberately not started tonight.
2. **Decide which object a `Qualifier` subject points at.** Three candidates, named above.
   Wiring `Insight_Card` and `Decision_Criterion` is now a lookup rather than a guess;
   `Qualifier` is not.
3. **`AAO_Claim_Basis__c` is deployed and written by nothing.** Routes P and C need it.
4. **Claim Basis parent: field tables say required Master-Detail to Claim, flags document
   says polymorphic across claim-or-flag.** Unresolved contradiction. Matthew's call, and it
   gets sharper now that Flag actually exists.
5. **`AAO_Answer__c` has no subject-deleted flag**, though the field table says
   "null-and-flag on subject delete".
6. **`AAO_Candidate__c.AAO_Run__c` is not built.**
7. **Internal domains are still a caller argument, not org configuration.**
8. **Nothing raises flags.** The object and its law exist; the raise path does not. Day-one
   red on a gating proposition is the obvious first case and would make the Flag tab real.
9. **Three additions to CLOSED tables now need ratifying**, not two: `Opportunity` as a
   subject type, `AAO_Synthetic__c` on all seven objects, and normal form v1.
10. **The field tables mark five fields case-sensitive that cannot be.** See session 2.
11. **Write-blocking customer constraints** — `ConvertToOpportunityTest`'s failure is a live
    example sitting in this org.
12. **The four project documents are still behind.** `docs/aao-corrections-v1_0.md` is
    authoritative until they are bumped.

---

## 2026-07-31 · session 4

**Did.** Built the live ingestion path: an after-insert on `AAO_Source__c` enqueues
`AAO_IngestQueueable`, which calls the same `AAO_Pipeline.runForSource` the durable
rehearsal calls. Extracted that pipeline out of `AAO_Demo` so there is one body and two
entries. Added a third deal, `AAO Demo - Live`, seeded empty, and drove it one artifact at a
time. Then audited this whole build, adversarially, for what actually executes versus what
is authored in the fixture — the inventory below is the result and it is the most important
thing in this entry.

**Decided, and why.**

- **The pipeline body was extracted, and the copy in `AAO_Demo` deleted.** Two entries
  calling one function, not two functions that agree. The alternative would have made the
  live path a demonstration of a second implementation.

- **Proposals are staged in the fixture and found by artifact hash.** A trigger has a Source
  and nothing else, so a proposal keyed by a fixture code would be unreachable from the async
  entry. See the inventory for how little this actually proves.

- **Adjudication is asynchronous; arrival is not.** Doing the work inline would put the whole
  adjudication inside whatever transaction delivered the evidence, and a governor limit there
  would roll back the *ingestion* and lose the artifact. Async means the artifact lands first
  and is adjudicated second, which is the right order for something whose whole point is that
  evidence is durable.

- **The rehearsal keeps its synchronous entry.** `AAO_Ingest.AUTO` is off around
  `AAO_Demo`'s inserts, because a demonstration of accumulation has to be deterministic about
  which transcript landed first.

- **A source with nothing staged for it writes nothing and says so** (`no_staged_proposal`).
  Not an error. Until a charter runs, an artifact only becomes a claim if a proposal was
  authored for it, and that is the honest shape of the gap.

**Read from the org.** All verbatim.

The live deal, driven by two separate `AAO_Live.ingest` calls with nothing else done by hand:

> `--- AAO Demo - Live (006WD00000SjFfVYAV)`
> `    job 707WD0000A4PJMpYQO Completed`
> `    job 707WD0000A4PIlvYQG Completed`
> `    source SRC-00000003 dummy/transcript-one occurred=2026-06-15`
> `    source SRC-00000004 dummy/transcript-two occurred=2026-06-26`
> `    answer ANS-00000002 AAO_T1 = TRUE by MACHINE coverage={"v":1,"missing":[],"covered":["e1","e2","e3"]}`
> `    claim  CLM-00000003 null -> UNVERIFIED (Established) occurred=2026-06-15 recorded=2026-07-31 12:45:42`
> `    claim  CLM-00000004 UNVERIFIED -> TRUE (Established) occurred=2026-06-26 recorded=2026-07-31 12:46:23`
> `    candidates=12 sources=2 claims=2`

Both jobs `Completed`; the claims were written by the org's own queue, 41 seconds apart.

Replay, checked in the org across all three demo deals:

> `REPLAY AAO Demo - Live | claims=2 | exact=true`
> `REPLAY AAO Demo - Tungsten Rehearsal | claims=2 | exact=true`
> `REPLAY AAO Demo - Tungsten Rehearsal (seller said it) | claims=1 | exact=true`

Full local suite: `Tests Ran 102`, `Pass Rate 99%`, one failure and it is the pre-existing
`ConvertToOpportunityTest`. All 83 AAO tests pass.

**A defect the new trigger exposed in our own test suite, before anything else did.**
`AAO_Seed.load()` inserts the four fixture Sources. With an after-insert enqueueing
adjudication, the fixture loader began silently committing **all four artifacts** at
`Test.stopTest()` — on deals the calling test had never asked about. Two assertions in
`AAO_TriggerLawTest` failed on it:

> `AAO_TriggerLawTest.commitDoesNotOverwriteAHumanAnswer Fail System.AssertException: Assertion Failed: The second pass wrote nothing.: Expected: 1, Actual: 3`

Several other tests were passing while quietly polluted, which is worse. Fixed by making the
fixture loader stage without adjudicating, and by scoping the org-wide `COUNT()` assertions
to the deal under test. **The lesson is about after-insert triggers generally:** they change
the meaning of every transaction that touches the object, including the ones written before
the trigger existed.

---

### The stage inventory · what executed and what was fixture-supplied

**This exists so the claim made to Toby is exact.** It was produced by four independent
readers of this repo, each put through an adversarial pass instructed to refute every
"executed" claim and to default to refuting when uncertain. Where reader and refuter
disagreed, the refuter won. **I then re-verified the seven sharpest findings against the code
myself**; all seven held, and two of them corrected claims I would otherwise have made in
this journal.

| Stage | Status | What actually happened |
|---|---|---|
| Artifact collection | **Fixture-supplied** | No connector, callout, file reader or poller exists anywhere in the repo. Every Source is built in Apex from `AAO_Seed.json`: origin, ref, duration, diarization and the words are all authored |
| Delivery-as-event (async plumbing) | **Executed** | After-insert → `AAO_Ingest` → `AAO_IngestQueueable` → pipeline, with re-entrancy guards, queueable-limit checks and per-source try/catch. Real async delivery — over a payload the loader itself inserted |
| Deal / account resolution | **Fixture-supplied** | Each source names its own deal as a literal. No domain match, no calendar correlation, no ambiguity handling |
| Evidence-occurred clock | **Fixture-supplied** | ISO strings typed into the fixture. The "eleven days apart" is the difference between two literals. What *is* real is downstream: propagation, the forward-only max rule, immutability, and replay ordering on it rather than on processing time |
| Artifact hashing | **Partly executed** | SHA-256 genuinely runs and no hex appears in the fixture. But `AAO_Artifact_SHA256__c` digests the path label `dummy/transcript-one`, not artifact bytes — and `AAO_SHA256__c`, the one true digest of stored text, is read by nothing |
| Normalisation | **Fixture-supplied** | `compose()` is `speaker + tab + utterance` joined by newlines — a re-serialisation of the fixture's own turn array. No case folding, whitespace collapse, unicode normalisation or diarization inference. `AAO_NormalForm` says so in its own header |
| Speaker roster | **Fixture-supplied** | Names, emails and buying roles copied verbatim and stamped identically onto every source. `contactId` is written and never read |
| Rubric discovery (`ALTF__*`) | **Not built** | No Apex reads any `ALTF__*` object. Two field-meta files name "Rubric discovery" as their writer. It does not exist |
| Evidence-contract derivation | **Fixture-supplied** | All fifteen contract fields are direct copies out of the fixture. The only executed code is the find-or-create query and `elements.size()` |
| Element resolution | **Fixture-supplied** | Elements are hand-typed JSON. `AAO_Guidance_Text__c` is never parsed. Even `AAO_Elements_Basis__c` is itself authored |
| Element-count validation | **Partly executed** | A real before-insert guard, proven by test — but the seeder sets the count from the same list it serialises, so it is tautological on every real record |
| Extraction (verdict + quotes) | **Fixture-supplied** | Verdict, quotes, speakers and elements read verbatim. `CHARTER = 'AAO_Extract_Evidence'` is a literal stamped on rows, not an invocation. One real guarantee: `AAO_Seed.resolve` throws if an authored quote is absent from the text or ambiguous, so a fixture cannot cite words the artifact does not contain |
| Proposal lookup by artifact hash | **Partly executed** | Both sides of the comparison are SHA-256 of the same literal in the same file. It cannot miss. What genuinely executes is the already-committed idempotency check, exercised for real on the live path |
| Interpretation | **Not built** | Plumbed end to end and permanently null. The replay comparison on it is asserting `null == null` |
| Span byte-verification | **Partly executed** | The substring compare is real code against stored text, and its failure branches are proven by hand-built negatives and refused at the DML boundary. But every span in the build has offsets produced by `indexOf(quote)` against that same string, so **on every path the system actually runs, the compare cannot return false** |
| Turn contiguity + speaker attribution | **Executed** | Turn boundaries are re-derived by parsing the stored string; the offsets fed in come from `indexOf`, which knows nothing about turns. A quote straddling a newline or reaching into a speaker prefix *would* be rejected on the live path |
| Blind reader / coverage adjudication | **Fixture-supplied** | `covered`/`missing` are literals. `isFull()` is `missing.isEmpty()` and never consults the contract's element list; `Span.element` is written and read nowhere. A test asserts `covered=['e1'], missing=[]` routes TRUE on a three-element proposition |
| Coverage-to-verdict routing | **Partly executed** | The three-way route, the answer-key read-back, `verdictBefore` capture and the cross-source span union are real. But **C2 does not merge to full — it arrives full.** Across all four fixture candidates the merged verdict always equals the verdict from the incoming candidate alone. Accumulation is load-bearing for the span union, never for the verdict |
| Speaker-requirement gate | **Partly executed** | The strongest computed behaviour here: the speaker is re-derived from turn segmentation rather than trusted from the span, and the unsegmented source fails genuinely because segmentation yields no speaker. But the fact it rules on — `mapRole = 'Decision Maker'` — is a fixture literal, and NEGSRC differs only because the fixture swapped who utters the line. 2 of 5 requirement branches are reached through the pipeline |
| Scope-key composition | **Executed** | Composed in Apex at before-insert from live record values, five validated rejection paths, unique + case-sensitive + external id on the platform, real `DUPLICATE_VALUE` at runtime. Caveat: the identity it enforces is only as good as the path-label hash feeding it |
| Contract key + content hash | **Executed** | Real SHA-256 over proposition+guidance into a unique `Text(83)` external id, frozen by a real immutability guard, a value appearing nowhere in the fixture. Narrowing: it fingerprints `AAO_Seed.json`, not any org rubric row |
| Answer-key composition | **Executed** | Composed at write time from platform-assigned Ids by a single writer, identity-does-not-move guard, genuine unique index, unit-tested with no fixture involvement at all. Only 2 of 6 subject types are wired |
| Read-before-write | **Executed** | Real SOQL on the answer key finds pass one's own row during pass two, and what it finds changes what is written. The test asserts `verdictBefore='UNVERIFIED'`, a value in no fixture |
| Human precedence | **Partly executed** | Three real refusals, one at the database boundary. But no path in the repo can build a charter-less candidate, so **the gate has evaluated false on every execution the system has ever performed**; the precondition exists only because tests set it by direct DML |
| `DUPLICATE_VALUE` merge | **Partly executed** | Insert-with-partial-success, status-code inspection, re-read, precedence and accumulate-and-update are all real, and the collision comes from the real platform index. But the race is manufactured by a test seam. Nothing concurrent has ever happened here |
| Answer upsert + accumulation | **Partly executed** | Real math: span union by fingerprint with stable sort, missing shrinking against accumulated covered, a monotonic occurred clock that stops a backfill dragging the answer backwards. The inputs that decide the verdict are authored lists |
| Claim insert + immutability | **Executed** | Assembled at runtime from verdict-after, verdict-before, outcome and the resolved internal person, then inserted; the org genuinely refuses to edit or delete it, proven at DML |
| Key four (internal person) | **Partly executed** | Real resolution that intersects the roster with internal domains and with speakers appearing in verified spans, never assuming the deal owner. But there is exactly one internal person and their id is `UserInfo.getUserId()`, so the function has two possible outputs across the whole exercise |
| Candidate ledger | **Partly executed** | Completeness is genuinely computed — contracts already carrying a proposal, differenced against the full rubric — and asserted as 12 rows / 10 abstained / 2 upheld, and 6 on the async path. But the *reason* is the hardcoded literal `nobody_said`; **`model_missed` is written by no line of Apex**, and a test asserts the literal as though it were a finding |
| Replay | **Executed** | Re-queries the real claims, orders on the occurred clock with deterministic tiebreaks, folds them into a fresh in-memory map, diffs field-for-field against live rows, and flags an answer no claim produced. Nothing is read from the fixture. Caveats: it shares its accumulation function with the writer by design, and no test has ever fed it claims out of occurred order — the case it exists for |
| Flag raising | **Not built** | Nothing raises a flag. The law that is there — type and raised-at immutable, no delete — is real and tested, but only against rows a test hand-built |

### The sentence that is true

Nothing in this build reads a transcript. Every judgement a model would have to make — which
deal an artifact belongs to, what was said, which verdict the words support, which elements
are covered — is typed by hand into one fixture file and copied onto records; the six
propositions are authored too, because the org's own rubric tables have never been read.
What is genuinely built and running is the ledger machinery underneath those judgements:
keys composed at write time and enforced by real platform indexes, spans verified against
stored text and refused at the database boundary, claims the org will not let you edit or
delete, and a replay that rebuilds every answer from the claims alone and matches field for
field. **That is a working evidence ledger with no reader attached — not a working
extraction pipeline.**

### Three things a reader could wrongly conclude, and the correction

1. **"It accumulated evidence across two transcripts and upgraded its answer."** The routing
   law and the two-pass write path are real, but the second candidate does not merge to full
   coverage — it *arrives* full, because its `missing` list was authored empty. Accumulation
   is load-bearing for the **span union** (five spans from two sources on one answer, which
   is real), never for the verdict. Say *the answer went from UNVERIFIED to TRUE across two
   passes and carries quotes from both*, not *it worked out that the second call completed
   the picture*.

2. **"Integrity and de-duplication are demonstrated."** The SHA-256 is real, but the
   fingerprint anything reads hashes the string `dummy/transcript-one`, a filename we
   invented — not artifact bytes. The one hash that digests the stored text is read nowhere.
   **The test suite asserts the consequence as correct**: a Source with genuinely different
   text under the same ref is rejected as a re-delivery. Nothing about content integrity or
   content dedup has been shown.

3. **"The laws are enforcing."** Several have never fired in operation. Human precedence
   cannot trigger because no path can produce a charter-less candidate; `model_missed` is
   written by no line of code; the `Reinforced` and `no_staged_proposal` branches are
   unreachable outside unit tests. Say *these guards exist and are proven against hand-built
   inputs*, not *the pipeline enforces them*.

---

**Assumed, not verified.**

- **The audit is a reading of the code, not a proof.** Four readers plus four refuters plus
  a synthesis; I re-verified seven findings by hand and all seven held, but the rest of the
  table is their reading and not mine.
- **`AAO_Live.status()` is the only ordering guard.** Firing `ingestTwo` before `ingestOne`'s
  job completes would still produce correct claims — each carries its own occurred clock —
  but the narrative would be wrong and nothing prevents it.
- **The Celigo Opportunity layouts are still untouched**, so if Matt's profile uses one, the
  related lists will not appear.
- **`AAO_Demo.purge()` still has never been run for real.**

**Owed.** Session 3's list, plus what the audit surfaced. The new items are defects, not
absences, and they are ordered by how badly they would mislead someone.

1. **`AAO_Artifact_SHA256__c` hashes the path label, not content — and a test enshrines it.**
   `AAO_TriggerLawTest.theScopeKeyIsComposedByTheTriggerAndDedupes` inserts a Source with
   different text under the same ref and asserts `DUPLICATE_VALUE` is correct. Dedup is
   currently on the filename. Either hash the delivered payload, or keep the label hash and
   rewrite that test so it stops defending the bug. **Highest priority: a wrong test is worse
   than a missing one.**
2. **`AAO_Model.Coverage.isFull()` never consults the contract's element list.** Coverage is
   full when `missing` is empty, whoever authored `missing`. A three-element proposition with
   one covered element and an empty missing list routes to TRUE, and a test asserts it.
3. **Nothing demonstrates load-bearing accumulation.** To show it, transcript two would have
   to address *only* timing, or a third artifact would. The current pair cannot, because
   transcript two genuinely restates all three elements — which was the right call for
   fidelity to the words and the wrong one for the demonstration. Frozen fixtures, so this is
   a ruling, not an edit.
4. **`model_missed` is unreachable**, so the abstention-rate detector currently has one value.
5. **`AAO_Interpretation__c` is plumbed and permanently null.** Either something writes it or
   the replay comparison on it should say it is vacuous.
6. **Replay has never been fed claims out of occurred order** — the exact case it exists for.
7. **Start discovery.** Unchanged, still the largest absence. Ground prepared in session 3.
8. **Decide which object a `Qualifier` subject points at.** Three candidates named in session 3.
9. **`AAO_Claim_Basis__c` is deployed and written by nothing.**
10. **Claim Basis parent: field tables say required Master-Detail, flags document says
    polymorphic.** Unresolved contradiction, sharper now that Flag exists.
11. **`AAO_Answer__c` has no subject-deleted flag.**
12. **`AAO_Candidate__c.AAO_Run__c` is not built.**
13. **Internal domains are still a caller argument, not org configuration.**
14. **Nothing raises flags.**
15. **Four additions to CLOSED tables need ratifying**: `Opportunity` as a subject type,
    `AAO_Synthetic__c`, normal form v1, and now the `AAO_Ingest.AUTO` switch as a documented
    part of the write path.
16. **The field tables mark five fields case-sensitive that cannot be.**
17. **Write-blocking customer constraints** — live example still sitting in this org.
18. **The four project documents are still behind.**

---

## 2026-07-31 · session 5

**Did.** Built the AAO Pipeline (internal) view: one LWC, one Apex controller, one snapshot
per call. Deployed a standalone Opportunity record page carrying it, **assigned to nothing**.
88 AAO tests pass. **The component has not been seen rendering** — see Assumed.

**Decided, and why.**

- **One call, one snapshot, and all display formatting in Apex.** The template does no
  arithmetic and no string building; even the badge class comes down finished, so there is
  exactly one place where a verdict becomes a colour. A view that computed anything would be
  a second implementation of the thing it is meant to be showing.

- **Two cadences.** While an artifact has landed and nothing has adjudicated it, the poll is
  2s and that row carries a spinner; otherwise 10s. The fast case is the only moment
  something is about to change, and a demo screen that hammers an org at 2s forever is its
  own kind of statement.

- **The existing Opportunity record page was not touched.** `Opportunity_Record_Page` is
  98KB of customer customisation, its tabs live in a facet keyed by a GUID, and hand-patching
  it to add one tab the day before a meeting is not a trade worth making. Instead a new
  `AAO_Pipeline_Internal` record page carries the component and is **assigned to nothing**,
  so it changes no user's experience until somebody activates it. The retrieved copy of the
  customer page was deleted from the repo rather than committed, so nothing can redeploy it
  by accident.

- **A missing record id throws rather than rendering an empty snapshot.** My first test
  asserted this and failed, because the controller was returning an empty snapshot for a
  null id. The test was right about the requirement and the code was wrong: an empty
  snapshot renders as *nothing has arrived on this deal*, which is a claim about the
  customer, when the truth would have been a claim about our own wiring. Now guarded.

- **The empty states say why they are empty.** No flags reads *"nothing raises them yet — the
  object and its law exist, the raise path does not. An empty list here is the honest state,
  not a clean bill of health."* An empty deal reads *"that is a true statement about the deal,
  not a loading state."* Both are asserted by test, because the sentence is the point.

- **Projection is greyed and labelled `off`**, with the reason on it. A panel that is merely
  absent invites the assumption that it works.

- **Labelled AAO Pipeline (internal), and it says so twice.** In the card subtitle and in
  the footer: this shows candidates, and candidates never appear on a seller surface. The
  seller Surface is a later and different thing — one comprehensive current-state record per
  opportunity per seller, derived, no citation, no actor, no precedence.

**Read from the org.** All verbatim.

The controller against the three real demo deals:

> `VIEW AAO Demo - Live | sources=2 pending=0 | candidates latest=6 total=12 | claims=2 | answers=1 | flags=0 | projection=off`
> `VIEW    claim — -> UNVERIFIED (Established) 15 Jun 2026 "The funding is approved."`
> `VIEW    claim UNVERIFIED -> TRUE (Established) 26 Jun 2026 "It is in the current fiscal year, confirmed last Thursday."`
> `VIEW    answer AAO_T1 = TRUE covered=e1, e2, e3 missing=— theme=slds-badge slds-theme_success`
> `VIEW AAO Demo - Tungsten Rehearsal (seller said it) | sources=1 pending=0 | candidates latest=6 total=6 | claims=1 | answers=1 | flags=0 | projection=off`
> `VIEW    claim — -> UNVERIFIED (Downgraded) 26 Jun 2026 "It is in the current fiscal year, confirmed last Thursday."`
> `VIEW    answer AAO_T1 = UNVERIFIED covered=e1, e2, e3 missing=— theme=slds-badge slds-theme_warning`

**That last pair is the screen worth pointing at.** Coverage complete — `covered=e1, e2, e3`,
`missing=—` — and the verdict still `UNVERIFIED`, because the seller said the words. Every
part was said and it still does not establish.

First deploy of the controller failed on a reserved word, which is worth recording because it
is not in most people's list:

> `ApexClass AAO_PipelineViewController :: Identifier name is reserved: any`

And the first record page failed on a component name that does not exist at this API version:

> `We couldn't retrieve the design time component information for component flexipage:highlightsPanel`

It is `force:highlightsPanel`.

Full local suite after the view: `Tests Ran 107`, one failure, still the pre-existing
`ConvertToOpportunityTest`.

**Assumed, not verified.**

- **The component has never been seen on screen.** This is the significant one. The deploy
  compiles the LWC template and the record page validates the component reference, and the
  controller is proven against real data — but nothing has rendered. The in-app browser is
  blocked from this org's domain by policy and I did not route around it. Template-level
  runtime faults would not have been caught by anything done here.
- **Which Opportunity record page Matt's profile actually uses is still unknown.** Two exist
  plus two LinkedIn ones. This is the same unknown as session 3's related lists.
- **The 2s/10s cadence has never been observed switching**, because observing it needs the
  component on screen with a pending source.

**Owed.** Session 4's list stands unchanged; nothing on it was addressed. New items first.

1. **Put the component on a page and look at it.** Either activate `AAO_Pipeline_Internal`,
   or add `aaoPipelineView` as a new tab on whichever record page is actually in use. About
   a minute in App Builder. **Until this is done the view is deployed, not demonstrated.**
2. **Run sheet v1.1 stays Plan B, unchanged.** If the view is not solid an hour before the
   meeting, demo on the related lists — which are already in place from session 3 and are
   independent of everything built tonight — and ship the view afterwards. *Note: the run
   sheet itself is not in this repo and I have not seen it; nothing here modifies it.*
3. Everything in session 4's Owed list, unchanged and unaddressed — including the two real
   defects it found: the artifact hash on the path label with a test defending it, and
   `isFull()` never consulting the contract's element list.

---

## 2026-07-31 · session 5 addendum · seen on screen

**Corrects session 5's Assumed list, above.** That entry says *"the component has never been
seen on screen"* and *"the in-app browser is blocked from this org's domain by policy"*. Both
were true when written. Matt then opened the org in Chrome with the Claude extension, and
both are now settled. The entry above stands as written; this is the correction.

**The component renders, with real data.** Opened in Lightning App Builder against
`AAO Demo - Tungsten Rehearsal (seller said it)`. Every panel drew, in flow order, left to
right, two rows of three:

> `AAO Pipeline (internal)` · `Read-only. Shows candidates, which never appear on a seller surface.` · `Refreshing every 10s · 06:27:45`
> `SOURCES → CANDIDATES → CLAIMS → ANSWERS → FLAGS → PROJECTION`
> `1 · SOURCES  dummy/transcript-two-wrong-s… [Adjudicated]  ECI · Attributed · 26 Jun 2026`
> `2 · CANDIDATES  Latest pass · dummy/transcript-two-wrong-speaker  Abstained 5  Downgraded_Speaker_Rank 1  this pass 6  all passes 6`
> `3 · CLAIMS  — → [UNVERIFIED] Downgraded  26 Jun 2026  "It is in the current fiscal year, confirmed last Thursday."`
> `4 · ANSWERS  AAO_T1 · Budget Confirmed [UNVERIFIED]  covered e1, e2, e3 · missing — · established by MACHINE · Live`
> `5 · FLAGS  0  No flags. Nothing raises them yet — the object and its law exist, the raise path does not…`
> `6 · PROJECTION [off]` — greyed, with its reason on it

The cadence label read `Refreshing every 10s`, correctly, because nothing was pending.

**The screen worth pointing at is panel 4 beside panel 3.** `covered e1, e2, e3`,
`missing —`, and the verdict still `UNVERIFIED`. Every part of the proposition was said and
it does not establish, because the seller said it. That is the Gate 1 run-two regrade,
rendered.

**Session 3's related lists are also confirmed, and this was an open assumption too.** On
`AAO Demo - Live`, under the record page's own **Related** tab:

> `AAO Answers (1)   ANS-00000002  TRUE  MACHINE  6/26/2026, 8:00 AM`
> `AAO Claims (2)    CLM-00000003  (blank) → UNVERIFIED  Established`
> `                  CLM-00000004  UNVERIFIED → TRUE     Established`
> `AAO Sources (2)   SRC-00000003  Attributed  ECI  6/15/2026, 8:00 AM`
> `                  SRC-00000004  Attributed  ECI  6/26/2026, 8:00 AM`
> `AAO Flags (0)`

Claims and Sources are in ascending evidence-occurred order, which is the sort configured in
session 3. **Plan B is real and working**, independently of anything built tonight.

**Read from the org.** The active Opportunity record page carries a Lightning tabset —
`Details | Related | Chatter` — so a new tab is a natural fit rather than a squeeze. The
page-layout related lists surface under **Related**, not in the main body.

**Assumed, not verified.**

- **The 2s cadence and the row spinner have still not been observed.** Seeing them needs the
  component on screen at the moment a source is landed-but-unadjudicated, which is a
  ten-second window on the live deal. The 10s branch was observed; the 2s branch was not.
- **Nothing was saved in App Builder.** The page was opened, read and navigated away from.

**Owed.** Session 5's list, with item 1 narrowed.

1. **Add the tab, or activate the page.** No longer "put it on a page and look at it" —
   it has been looked at. What remains is the one change that touches the shared Opportunity
   record page, and it was deliberately not made without a word from Matt: adding an
   `AAO Pipeline` tab means a Save on a 98KB customer-customised page the day before a
   meeting. `AAO_Pipeline_Internal` is deployed and assigned to nothing as the alternative,
   and the Related tab works as the fallback.
2. Everything in session 4's Owed list, unchanged and unaddressed.

---

## 2026-07-31 · session 6 · the tab, the reset, and the freeze

**Did.** Retrieved the active Opportunity record page into git as a rollback point, added an
`AAO Pipeline` tab to it, confirmed the Altify panels and the Related tab survived, then
purged and reseeded the rehearsal leaving the live deal empty. **Code freeze from here.**

**Decided, and why.**

- **The tab went in as a metadata patch, not App Builder drag-and-drop.** It was attempted
  in App Builder first, as instructed. Adding the tab worked; **renaming it did not** — the
  Tab Label combobox would not open under automation across four different approaches, and
  on the last attempt the click fell through the closed popover onto a related list in the
  canvas, one icon away from its delete control. That is the point at which continuing to
  click on a 98KB customer-customised page stops being diligence. The App Builder change was
  **undone** — verified back to four tabs with Undo greyed out, nothing saved — and the same
  edit made precisely in XML instead. **24 insertions, 0 deletions**, purely additive: one
  `flexipage:tab` appended after `Legacy`, plus one facet holding the component.

- **The rollback point was taken before anything was touched**, as instructed, and is a
  separate commit so it can be deployed on its own:
  `git show ed71d06:force-app/main/default/flexipages/Opportunity_Record_Page.flexipage-meta.xml`

**Read from the org.** All verbatim.

Which page is actually active, from Object Manager → Lightning Record Pages:

> `AAO Pipeline (internal)` — org default: *(blank)*
> `Opportunity 2 Column (Sales Navigator)` — *(blank)*
> `Opportunity 3 Column (Sales Navigator)` — *(blank)*
> `Opportunity Record Page` — **`Desktop, Phone`**
> `Opportunity Record Page - Three Column` — *(blank)*

So `Opportunity_Record_Page` is the one, and `AAO_Pipeline_Internal` is assigned to nothing,
which is what was intended for it.

The tab, rendered on the real record page, read out of the live DOM:

> `AAO Pipeline (internal)` · `Read-only. Shows candidates, which never appear on a seller surface.` · `Refreshing every 10s`
> `1 · Sources  dummy/transcript-one Adjudicated ECI · Attributed · 15 Jun 2026 / dummy/transcript-two Adjudicated ECI · Attributed · 26 Jun 2026`
> `2 · Candidates  Latest pass · dummy/transcript-two  Abstained 5  Upheld 1  this pass 6  all passes 12`
> `3 · Claims  — → UNVERIFIED Established 15 Jun 2026 “The funding is approved.”`
> `            UNVERIFIED → TRUE Established 26 Jun 2026 “It is in the current fiscal year, confirmed last Thursday.”`
> `4 · Answers  AAO_T1 · Budget Confirmed TRUE  covered e1, e2, e3 · missing —  established by MACHINE · Live`
> `5 · Flags 0` · `6 · Projection off`

Tab bar afterwards: `Details | Related | Chatter | AAO Pipeline`. The Altify Sales Process
Manager and Opportunity Plan panels, the Related List Quick Links and the right sidebar all
still render, and the Related tab still lists its related lists.

The purge:

> `purged: claim bases 0 · claims 5 · flags 0 · candidates 30 · answers 3 · sources 5 ·`
> `contracts 6 · opportunities 3 · contacts 2 · accounts 1`

The reseed, three separate transactions:

> `OK. T1SRC committed on AAO Demo - Tungsten Rehearsal. staged verdict=UNVERIFIED claim=Established key4=005V400000MCTUbIAP abstentions=5`
> `OK. T2SRC committed on AAO Demo - Tungsten Rehearsal. staged verdict=TRUE claim=Established key4=005V400000MCTUbIAP abstentions=5`
> `OK. NEGSRC committed on AAO Demo - Tungsten Rehearsal (seller said it). staged verdict=UNVERIFIED claim=Downgraded ... note=Speaker requirement Decision_Maker_Or_Influencer unmet: Priya Shah is on the selling side`

Final state, which is the state the meeting starts from:

> `--- AAO Demo - Tungsten Rehearsal (006WD00000SjNmjYAF)`
> `    answer ANS-00000003 AAO_T1 = TRUE by MACHINE coverage={"missing":[],"covered":["e1","e2","e3"]}`
> `    claim  CLM-00000005 null -> UNVERIFIED (Established) occurred=2026-06-15 recorded=13:46:30`
> `    claim  CLM-00000006 UNVERIFIED -> TRUE (Established) occurred=2026-06-26 recorded=13:46:32`
> `    candidates=12 sources=2`
> `--- AAO Demo - Tungsten Rehearsal (seller said it) (006WD00000SjNmkYAF)`
> `    answer ANS-00000004 AAO_T1 = UNVERIFIED by MACHINE coverage={"missing":[],"covered":["e1","e2","e3"]}`
> `    claim  CLM-00000007 null -> UNVERIFIED (Downgraded) occurred=2026-06-26`
> `    candidates=6 sources=1`
> `--- AAO Demo - Live (006WD00000SjNmlYAF)`
> `    candidates=0 sources=0 claims=0`

Replay exact on all three. **Note the ids all changed** — purge deletes the opportunities and
the reseed creates new ones.

And the empty state, rendered on the live deal, which is where a live-ingest demo begins:

> `Nothing has arrived on this opportunity yet. No sources, no candidates, no claims, no`
> `answers. That is a true statement about the deal, not a loading state.`

**Assumed, not verified.**

- **The 2s cadence and the row spinner have still never been observed.** Catching them means
  having the tab open at the moment a source is landed-but-unadjudicated — a roughly
  ten-second window. It will happen naturally on the first live ingest at the meeting, and if
  it does not, nothing is broken; the 10s branch is the one that has been seen.
- **A browser tab was left open on App Builder holding unsaved changes and a stale copy of
  the page.** It predates the tab being added. **Saving it would remove the AAO Pipeline
  tab.** Close it without saving. Nothing was saved from it during this session — the Undo
  was verified.
- **The Legacy tab does not appear on the rendered record page** even though it is in the
  metadata, so it presumably carries a visibility filter. Not investigated; not ours.

**Owed. Code freeze is in force: nothing else changes before the meeting.**

1. **Nothing.** No further changes are to be made. If the tab misbehaves, the fallback is the
   **Related** tab, which is independent of everything built in sessions 5 and 6, and the
   rollback is deploying `ed71d06`'s copy of the record page.
2. After the meeting, session 4's Owed list resumes **unchanged and unaddressed**, still led
   by the two real defects: the artifact hash computed over the path label with a test
   asserting that behaviour as correct, and `AAO_Model.Coverage.isFull()` never consulting
   the contract's element list.

---

## 2026-07-31 · session 7 · the first real model call, wired but not yet fired

**Did.**

- **Synced the new context folder into `docs/`** and read the version bumps before writing
  any code, because `aao-field-tables-v0_10` supersedes the `v0_8` this entire build was
  authored from. It turns out to ratify rather than contradict. Diffed in full; the changes
  are listed under *Read from the org* below.
- **Deployed the credential scaffolding for `api.anthropic.com`**: an External Credential,
  a Named Credential, a Remote Site Setting, and a principal grant on `AAO_Admin`. The key
  itself is not set and was never handled here.
- **Added `AAO_Model_Config__mdt`** with one record, `Default`, carrying model name, charter
  version, named credential, endpoint path, effort, max output tokens, timeout, and an
  active switch. Nothing about which model ran is a literal in Apex any more.
- **Wrote extraction charter v1** as `AAO_ExtractCharter`, which assembles the prompt and
  the output schema from `AAO_Evidence_Contract__c` records at runtime, and `AAO_Extract`,
  which makes the call and returns proposals plus token usage.
- **Rewrote `AAO_Pipeline` around a typed `Proposal`** so the fixture path and the model
  path genuinely share one builder rather than being two builders that agree.
- **Wrote `AAO_Gate1`**, the round-two harness, and staged its deal.
- **Wrote `AAO_ExtractTest`**, eleven tests that exercise the model path with mocked
  responses. **99 AAO tests, 99 passing.**

**Decided, and why.**

- **The charter is told the speaker requirement and forbidden from acting on it.** The
  requirement is injected so the model can identify whose utterance carries the assertion,
  and both the prompt and the output schema say in terms that it must not lower a verdict
  because of who spoke. `AAO_SpeakerRule` still decides that at commit. Had the charter
  applied the rule itself, the seller-said-it case would come back `UNVERIFIED` already, the
  downgrade would never fire, and a law enforced by the schema would have quietly become a
  request made in a prompt.
- **The charter does not decide element coverage.** It cites spans against elements;
  coverage is computed from the spans that were actually located in the artifact. A reader
  asserting its own coverage is what the fixture did and it is the weaker half of the
  fixture, not a thing to reproduce. A side effect worth naming: because `missing` is now
  derived as *contract elements minus covered*, the `isFull()` defect cannot bite on the
  model path. It still bites on the fixture path and the fix is still owed.
- **Every vocabulary in the output schema is built from org data.** Proposition codes are
  the contracts that exist, element ids are the elements those contracts carry, speaker keys
  are the roster on that artifact. The model cannot name a proposition we do not hold or a
  person who was not on the call, because there is no string it could return that would mean
  that.
- **`not_addressed` and `abstained` are separate values** and become `nobody_said` and
  `model_missed`. Session 4 recorded `model_missed` as unreachable. It is reachable now, and
  it is the first thing in this build that only something which actually read the transcript
  could produce.
- **A quote that is not in the artifact is dropped and counted, not fatal.**
  `AAO_Seed.resolve` throws on a missing quote, which is right for a fixture, where it means
  the construction is wrong. It is wrong for a model, where it is the exact thing byte
  verification exists to catch. The model path has its own resolver that returns null and
  records the drop.
- **`AAO_Extract` has no DML in it at all.** A callout cannot follow DML in the same Apex
  transaction, so a class that both calls out and writes has to keep itself in order
  forever. A class that cannot write cannot get that wrong.
- **The protocol on the External Credential is `Basic`, and it is not being used as Basic
  auth.** See below; the org rejected the two obvious choices.
- **Gate 1 purges only its own deal.** `AAO_Demo.purge()` clears every synthetic row in the
  org and would take the three demo deals with it.

**Read from the org (verbatim).**

- `The authentication protocol "Custom" doesn't support the following external credential
  parameter type(s): CustomPrincipal, AuthParameter.` So `Custom`, which is what you reach
  for first for an API key in a header, accepts a principal and rejects everything that
  could hold a secret.
- `External Credentials don't support the "Password" authentication protocol.` It appears in
  `ExternalCredential.AuthenticationProtocol`'s picklist and is refused anyway.
- The picklist itself, by describe: `NoAuthentication, Oauth, Password, AwsSv4, Jwt,
  JwtExchange, Custom, Basic`. `Basic` is the only supported protocol with an encrypted,
  write-only secret slot, so the key goes in its Password field and the Authorization header
  it would otherwise generate is switched off.
- `Property 'principal' not valid in version 66.0` and again in 67.0. Authentication
  parameters are not bound to a principal in metadata at all.
- `The parameter type "HttpHeader" requires the following Named Credential Parameter fields:
  SequenceNumber.`
- `Identifier name is reserved: system`. A local `String system` shadowed the `System` class
  and the failure surfaced as `Method does not exist: void currentTimeMillis() from the type
  String`. **This is the third of the family** after `commit` and `json`, both of which
  v0.10 records. Worth adding to that list.
- Deploying a custom metadata type and its records in one operation fails with
  `UNKNOWN_EXCEPTION` and **zero component errors**. Split into two deploys, type first.
- `The external credential isn't fully configured.` This is the current state of the callout
  path and it is the expected one: it proves the Named Credential resolves and the principal
  grant is in place, and names the missing key as the only remaining step.
- **Field tables v0.10 ratify four things this build had recorded as owed:**
  `AAO_Synthetic__c` as a permanent field on every AAO object; the internal-person
  resolution rule *as code built it*, never the deal owner; `Opportunity` added to
  `AAO_Subject_Type__c`, explicitly credited to this build; and the five fields that cannot
  be case-sensitive, corrected in v0.9 with the reasoning this build reported.
- **The Claim Basis parent contradiction is resolved against session 3's reading.** The
  corrected flags document now rules that Flag carries its own snapshot fields and that
  master-detail from Claim Basis to Claim stands.

**Assumed, not verified.**

- **That the callout works at all.** No token has been spent. Everything up to the
  credential is proven; the request has never left the org. The first real call may fail on
  something only a live response reveals, and the two likeliest are the merge field not
  substituting into `x-api-key` under `generateAuthorizationHeader false`, and the 120 second
  Apex callout ceiling against `effort: high`.
- That `output_config.format` behaves as the schema intends for this shape. The mocked tests
  prove the parser, not the model's conformance to it.
- That one call per artifact for all six propositions is the right grain. It is one call
  because it is cheaper and the propositions share the transcript; whether per-proposition
  calls read better is unmeasured.
- That the fixture is a fair ground truth. It was authored from the transcripts by
  construction, so a disagreement means the two readers differ, not that the model is wrong.
  Where they differ the transcript is the tiebreaker and a human reads it.

**Owed.**

1. **The key, and then the run.** Items 20d and 20e are the only part of tonight not
   delivered, and both are blocked on one paste in Setup. Once it is in:
   `AAO_Gate1.pass('T1SRC')`, `AAO_Gate1.pass('T2SRC')`, `AAO_Gate1.compare()`, then the
   token numbers come here.
2. **Everything on session 4's Owed list, unchanged**, still led by the two real defects:
   the artifact hash computed over the path label with a test asserting that behaviour as
   correct, and `AAO_Model.Coverage.isFull()` never consulting the contract's element list.
3. **v0.10 ratified `AAO_Synthetic__c` with a requirement this build does not meet:** that
   every aggregating, streaming or projecting reader excludes synthetic rows. Nothing here
   excludes them, and it cannot yet, because in this org every row is synthetic and the
   exclusion would empty the demo. Recorded rather than implemented.
4. **Flag now owes snapshot fields** (the aggregate that fired, the count, the rung
   distribution, the window) per the corrected flags document. Nothing raises flags, so
   nothing is broken by their absence.
5. **The blind reader does not exist.** Coverage on the model path is computed
   deterministically from located spans, which is honest but is not the second reader the
   design calls for. Until it lands, no proposal is read twice.
6. **`AAO_Ingest`'s async path still runs the fixture.** The trigger-fired Queueable calls
   the fixture entry, not the model entry. Switching it is a one-word change and was not
   made, because it would alter what the demo does.
7. Normal form v1 and `AAO_Ingest.AUTO` are still additions to closed tables awaiting
   ratification. v0.10 ratified the other four.

---

## 2026-07-31 · session 7 addendum · the run happened, and it found a defect in the run

**Did.** Synced `aao-context 4`. Thirteen of its fifteen files are byte-identical to what
session 7 already carried; two are new: `aao-proof-register-v0_1.md` and
`aao-competitive-rebuttals-v0_1.md`. Neither is listed in `MANIFEST.md`.

The register records a live model pass that this session had left blocked on the key. It
happened, and it is real. **Verified against the org rather than taken from the document.**

**Read from the org (verbatim).** Both artifacts on `AAO Gate1 - Model Round Two`, charter
version `1.0.0`, created `2026-07-31 18:48:31` and `19:00:51` UTC:

```
transcript-one AAO_T1 verdict=FALSE outcome=Upheld cov={"missing":[],"covered":["e1","e2","e3"]}
transcript-two AAO_T1 verdict=TRUE  outcome=Upheld cov={"missing":[],"covered":["e1","e2","e3"]}
ten abstentions, all nobody_said, model_missed=0, spansDropped=0
CLM-00000014 null  -> FALSE (Established)
CLM-00000015 FALSE -> TRUE  (Established)
answer AAO_T1 = TRUE
```

The spans the model cited on transcript one:

```
[e1] dana: "The funding is approved."
[e2] dana: "It came out of the operations modernisation pot, so it is earmarked for this
           project specifically, not a general pool."
[e3] dana: "That I cannot tell you yet. Finance is still working through the calendar."
```

**The defect, and it is mine, introduced tonight.** The e3 span is verbatim, is genuinely the
passage that bears on e3, and **refutes it**. Dana says she cannot confirm the fiscal year.
`AAO_Pipeline.fromModel` counts every located span's element as covered, so coverage read
full. Coverage is what routes the outcome: full writes the verdict, partial writes
`UNVERIFIED` with the spans that exist. Full coverage therefore wrote `FALSE` as an
established claim.

**With coverage computed correctly this run would have produced the right answer without any
model improvement at all.** e1 and e2 supported, e3 refuted and so not covered, coverage
partial, and the partial route writes `UNVERIFIED` with its receipts, which is exactly the
staged ground truth. The gate that would have caught the model was disabled by my
derivation, not absent from the design.

Session 7 claimed coverage was "computed, not accepted". That was half right and the half it
got wrong is the half that mattered: the span's **existence** is verified, the span's
**element label** is still taken on trust, and nothing checks whether the quote supports or
refutes what it is filed under. Verbatim is not the same as supporting.

**The model's verdict was also wrong, separately.** "That I cannot tell you yet" is the
absence of a confirmation, not a denial, so `UNVERIFIED` is correct and `FALSE`
over-commits. Two independent errors landed on the same row and neither caught the other.

**Decided, and why.** Nothing in the pipeline was changed on discovering this. The register
now cites this run as a receipt, the demo state references it, and silently altering the
behaviour that produced a cited number would leave the register describing a run that can no
longer happen. The fix is specified below and is owed, not applied.

**Corrections to the register, offered rather than made.**

- **Row 12 is right about the mechanism and generous about the outcome.** The comparison
  caught the wrong verdict; the *gates* did not, and `outcome=Upheld` is what they recorded.
  It is evidence that the four checks are non-substitutable, which is what the row says. It
  is also evidence that one of the four was miscomputed, which the row does not say.
- **Row 11's "zero hallucinated spans" is accurate and is a real result.** Three of three
  quotes on each artifact were verbatim and located. Worth keeping.
- **The model path demonstrates correction, not accumulation.** `FALSE -> TRUE` is a
  different story from the fixture path's `UNVERIFIED -> TRUE`. The incrementalism claim at
  QBR rests on the demo deals, which are unaffected and still read `UNVERIFIED -> TRUE`.

**Assumed, not verified.** That the fixture is right and the model wrong about e3 coverage.
The transcript is the tiebreaker and a human should read it: the fixture treated e3 as
unaddressed, the model treated it as addressed and denied. The model's reading is arguably
the better one, which is precisely why the support-or-refute distinction has to be recorded
rather than inferred from whether a span exists.

**Owed, added to session 4's list.**

1. **Coverage must count supporting spans only.** Minimal fix that keeps the judgement out of
   trust: add a closed `stance` field to each span in the output schema, `supports` or
   `refutes`, and count only `supports` toward covered. The gate still computes coverage; the
   model only reports which way its own citation points. Re-run Gate 1 after.
2. **Tighten the charter wording.** "Offer each span against the specific element it
   evidences" reads as *bears on* and was followed as such. It should say what it means.
3. **Token counts are not persisted anywhere.** They come back on the Outcome and are printed
   to a terminal. The register's numbers for this run cannot be re-derived from the org.
   `AAO_Candidate__c.AAO_Run__c` is still not built and this is what it is for.

---

## 2026-07-31 · session 8 · the second reader, and the specimen it was built for

**Did.** Items 23 to 27. Model call 2 exists, the FALSE bar is explicit, the rubric prefix is
cached, and Gate 1 was re-run on a **new deal**, `AAO Gate1 - Blind Reader`, so the run the
proof register already cites is still in the org rather than purged by its successor.
**105 AAO tests, 105 passing**, seventeen of them on the model path.

**The prediction in item 24 held, and it is worth stating exactly.** Expected: the blind
reader refuses element three, coverage drops to partial, the verdict lands `UNVERIFIED`
rather than `FALSE`, matching ground truth. All three happened.

```
AAO_T1 v1.1.0 verdict=UNVERIFIED outcome=Upheld cov={"missing":["e3"],"covered":["e1","e2"]}
   [e1] dana: "The funding is approved."
   [e2] dana: "It came out of the operations modernisation pot, so it is earmarked for
              this project specifically, not a general pool."
   [e3] dana: "That I cannot tell you yet. Finance is still working through the calendar."
CLM-00000016 null        -> UNVERIFIED (Established) v1.1.0  src=dummy/transcript-one
CLM-00000017 UNVERIFIED  -> TRUE       (Established) v1.1.0  src=dummy/transcript-two
answer AAO_T1 = TRUE  covered=e1,e2,e3
```

**The blind reader is provably load-bearing here, independently of the charter change.**
Three spans are stored on that candidate and their element labels are e1, e2 and e3. Under
session 7's rule, three located spans meant three covered elements and coverage full. The
stored coverage says `missing:["e3"]`. Only the override produces that combination, so the
receipt is in the row and does not rest on reading a log.

**The model path now reproduces the demo narrative.** `UNVERIFIED` with receipts, then
`TRUE`, first claim untouched. That is the same shape the fixture deals show, produced by a
model reading a transcript.

**Decided, and why.**

- **Blindness is structural, not promised.** `AAO_Extract.review` takes reviews and nothing
  else, and `AAO_BlindCharter.content` is given a contract, an interpretation and a list of
  spans. There is no parameter through which a transcript or an earlier verdict could
  arrive. A test asserts it from the other side: a phrase that is in transcript one and in no
  cited span must not appear in the second request, and `proposed_verdict` must not appear
  either.
- **The second reader does not get the speaker rule.** Item 25 was explicit and it is also
  the right call: keeping it at `AAO_SpeakerRule` is what lets us keep watching the downgrade
  fire on the seller-said-it deal.
- **A missing verdict from the second reader is not a yes.** Coverage requires an affirmative
  yes per element. If the second reader says nothing about an element, that element is not
  covered and the fact is recorded on the Outcome rather than defaulted away.
- **The blind-off path was kept**, so the two behaviours can be compared. Off is the unsafe
  setting and its config field says so.
- **A deal per round.** `reset()` purges, and purging the deal a receipt points at would
  leave the register describing a run that no longer exists.

**Read from the org (verbatim).**

- **Prompt caching works and the delta is large.** Extraction on pass two:
  `in=175 out=892 cacheRead=3187 cacheWrite=0 ms=10928`. Session 7's uncached pass one was
  `in=3137`. The rubric prefix is now read from cache and only 175 input tokens are paid
  fresh. A later diagnostic call on transcript one read the same 3,187.
- **The second reader costs a second call**: `in=1283 out=591 ms=9177`, prompt 2,232 chars.
  That is the price of the check and it should be quoted alongside the benefit.
- **Charter 1.1.0 fixes the FALSE by itself, separately from the blind reader.** A read-only
  extraction call on transcript one, writing nothing, now returns
  `AAO_T1 -> addressed/UNVERIFIED spans=3` where 1.0.0 returned FALSE. Two independent
  corrections landed on the same specimen, which is why the pass-one result cannot be
  attributed to either alone.
- **`AGREE 11  DIFFER 1`** against staged ground truth.

**Assumed, not verified.**

- **The single DIFFER is a comparison artifact, not a model error.** Staged proposes `TRUE`
  with `cov=e1,e2` and leans on the coverage gate to downgrade it; the model proposes
  `UNVERIFIED` with the same coverage. Both adjudicate to the same answer. `compare()` grades
  proposals, not outcomes, so two readers that agree on the answer can read as disagreeing.
- **Pass one recorded five `model_missed` where pass two recorded five `nobody_said`.** A
  later call on the same artifact returned all six findings with five `not_addressed`, so
  this is run-to-run variance rather than a regression. It cannot be pinned down after the
  fact, and that is a defect of mine: `fromModel` writes `model_missed` both when the model
  omits a proposition and when it abstains on one, so the row cannot say which happened.
  Debug logs are not retained in this org.
- That the second reader is right about e3. It agrees with the fixture and with a plain
  reading of the transcript, which is as far as this goes.

**Owed.**

1. **`model_missed` conflates two facts.** An omitted proposition is a schema-compliance
   failure by the model; an abstention is a considered judgement. Same value today. This is
   the same shape of error as session 7's coverage defect: two different things written into
   one slot.
2. **`compare()` grades proposals only.** It should also compare the adjudicated answer, and
   it should not treat two abstentions as matching when their reasons differ.
3. **No field carries the blind charter version.** `AAO_Candidate__c` has one charter and one
   charter version and they belong to extraction. The second reader's version reaches the
   journal and not the row, which means a row cannot be attributed to the reader that set its
   coverage. Adding a field to a CLOSED table needs ratification, so it is recorded here.
4. **Item 26 is built and untested against real data.** `AAO_Interpretation__c` came back
   empty on every finding in every run so far, so the untruncated print has never had
   anything to print. Null is the good case, so this may stay untested for a while.
5. Everything on session 4's list, unchanged, still led by the artifact hash over the path
   label and `isFull()` never consulting the element list.

**Offered to the proof register.**

- **Row 12 is now superseded rather than wrong.** It recorded that the comparison caught a
  verdict the gates upheld, and named the absent blind reader as the reason. The blind reader
  exists, and on the same specimen the gates now catch it without the comparison. The row
  should be marked superseded and a new row should carry the receipt above.
- **Row 19, blind reader catch rate, has its first data point.** One specimen, caught.
- **Row 14 has its caching measurement**: 3,137 input tokens to 175, with 3,187 read from
  cache, on the second artifact of a pass.

---

## 2026-07-31 · session 9 · three reasons, two named readers, two grades

**Did.** Items 28 to 31. **109 AAO tests, 109 passing.**

**28. The abstention enum is three values.** `nobody_said` and `model_declined` are judgments
about evidence. `not_returned` is not a judgment about anything: the reader never reported
the proposition, and it is a charter-quality signal. It is counted separately and excluded
from `abstentions` on the Outcome, because a rate that includes it measures how well a
charter follows its own output schema and then calls that number an abstention rate.

`model_missed` is retired and left in the picklist so that rows written before the split stay
valid. Nothing writes it. Backfilled nothing, as ruled.

**KNOWN GAP, recorded rather than worked around.** `AAO_Outcome__c` has no value meaning "the
reader did not report this", so a `not_returned` row still carries `Outcome = Abstained`. Any
query that counts abstentions by outcome therefore overcounts, and the correct query filters
on the reason field. Adding a value to that picklist changes a CLOSED table and needs
ratifying. This is the second time a value has had to live somewhere that does not quite fit
it, and both times the cost was a number that reads plausibly and means something else.

**29. Candidate names both readers, on every row a model pass writes.**
`AAO_Blind_Charter__c` and `AAO_Blind_Charter_Version__c`, ratified. `AAO_Charter__c` names
the reader that **proposed**; the new pair names the reader that **adjudicated coverage**.
One field could not carry both: they are separate charters versioned independently, coverage
routes the verdict, and a coverage decision nobody can attribute is an answer nobody can
attribute. Null on the blind fields means no second reader ran, which for a model row means
coverage fell back to counting located spans. Abstention rows carry the pair too, because it
is the pass that was adjudicated under those charters.

**30. `compare()` grades both, and reports two lines.** On the last run, unchanged data:

```
PROPOSALS  11/12   what each reader put forward
OUTCOMES   12/12   what the gates established, which is the number that matters
```

The expected outcome is derived from the staged coverage rather than asserted: missing empty
means the staged verdict, anything missing means `UNVERIFIED`, because coverage is what
routes the verdict. Session 8's single DIFFER survives at the proposal line and disappears at
the outcome line, which is the correct reading of it: staged proposes `TRUE` with a missing
element and leans on the gate, the model proposes `UNVERIFIED` directly, and both establish
`UNVERIFIED`.

**31. Confirmed: `AAO_Interpretation__c` is still emitted, and the FALSE bar did not suppress
it.** A read-only call on transcript one under charter 1.1.0:

```
charter=1.1.0 findings=6 unanswered=()
AAO_T1 addressed/UNVERIFIED interpretation="" len=0
AAO_T2..T6 not_addressed/NONE interpretation="" len=0
```

**The distinction is the whole answer.** The value is the empty string, not null. The key is
present in every finding, so the schema is being followed and the reader is answering the
question; it has nothing to report because these propositions need no reading beyond their
own text. Null would have meant the field had stopped being returned, and that would have
been the regression. It is not one.

The honest limit: the field has never been non-empty in a live run, so only the plumbing is
proven, by a test that mocks a populated interpretation and asserts it reaches the row. The
mini-rubric has no under-specified proposition, so nothing in it should produce one.

**Read from the org (verbatim).**

- `Invalid XML tags or unable to find matching parent xml file for CustomField
  "AAO_Abstention_Reason__c"`. A comment before the root element is fine in an object file
  and breaks a decomposed field file. Moved inside the root.
- `Error parsing file: Element fieldPermissions is duplicated at this location in type
  PermissionSet`. The permission set XSD wants each element type grouped; appending
  `fieldPermissions` after `objectPermissions` fails even though the XML is well formed.
- `usage in=213 out=715 cacheRead=0 cacheWrite=3187` on the interpretation check. The cache
  had expired between runs, so this call re-wrote it rather than reading it.

**Assumed, not verified.**

- **The new enum values are proven in tests and have not been seen in a live run.** The blind
  deal's rows predate the split and still read `model_missed`, correctly, since nothing was
  backfilled. The next real pass will write the new values. Not spending four model calls to
  watch it happen.
- The five-minute cache TTL means session 8's caching measurement holds only for passes close
  together. A pass an hour later pays full price and writes the cache again. The measurement
  is real and the conditions belong next to it.

**Owed.**

1. **`AAO_Outcome__c` has no value for "not reported".** Needs ratifying, see above.
2. **`compare()` still treats two abstentions as matching regardless of reason.** Now that
   there are three reasons and one of them is not an abstention at all, that leniency hides
   more than it did.
3. Everything on session 4's list, unchanged, still led by the artifact hash over the path
   label and `isFull()` never consulting the element list.

---

## 2026-07-31 · session 10 · the trap removed rather than documented

**Did.** Item 32. `AAO_Outcome__c` gains `Not_Returned`, ratified. **109 AAO tests, 109
passing.** Item 33 acknowledged: no dedicated run, and no model calls were spent on this
session at all. The new values will be written by Saturday's discovery pass.

**The correction, stated as a correction.** Session 9 shipped `not_returned` as an abstention
reason on a row whose outcome still said `Abstained`, and wrote a note in the field
description explaining that counting abstentions by outcome would overcount. That note was
the defect, not the mitigation. **The plausible query was the wrong query, and the schema was
the thing making it wrong.** A field description cannot fix that: it can only warn whoever
happens to read it, and the person writing `WHERE AAO_Outcome__c = 'Abstained'` at speed is
precisely the person who will not.

The two values now mean what a reader would guess.

- `Abstained` is a judgment about evidence. The reader looked, and either nothing in the
  artifact bore on the proposition or it could not resolve what it found.
- `Not_Returned` is a fact about the charter. The reader never answered.

**Nothing was backfilled and nothing needed to be.** `not_returned` had never reached a live
row when this landed, so the ratification arrived before the first row that would have
carried the wrong outcome. That is luck rather than planning, and it is worth noticing that
session 9 came within one discovery pass of writing rows that would have needed correcting.

**Counts updated.** `AAO_Gate1.compare()` prints `NOT RETURNED` as its own line, deliberately
not folded into either grade, and a not-returned row renders as `(NOT RETURNED)` rather than
as an abstention, because the staged truth expects the reader to have looked and said
nothing and a row it never returned is a different failure. `AAO_Demo.status()` breaks the
candidate total into `abstained` and `notReturned` so a silent charter failure cannot hide
inside a total that looks healthy.

**Read from the org (verbatim).** Both free, no callouts:

```
--- AAO Demo - Tungsten Rehearsal
    candidates=12 (abstained=10 notReturned=0) sources=2
--- AAO Demo - Tungsten Rehearsal (seller said it)
    candidates=6 (abstained=5 notReturned=0) sources=1
NOT RETURNED  0
PROPOSALS  11/12
OUTCOMES   12/12
```

**Assumed, not verified.** That `Not_Returned` renders sensibly on the LWC. The pipeline view
groups candidates by outcome dynamically, so a new value appears as its own row without code
changes, but no row carries it yet so nothing has rendered. It will first appear on Saturday.

**Owed.**

1. `compare()` still treats two abstentions as matching regardless of reason. `not_returned`
   no longer hides there, so this is narrower than it was, but `nobody_said` and
   `model_declined` still compare equal.
2. Everything on session 4's list, unchanged, still led by the artifact hash over the path
   label and `isFull()` never consulting the element list.

---

## 2026-07-31 · session 11 · the two owed defects, paid

**Did.** Item 34. Both session-4 defects are fixed, with the test that defended one of them
corrected rather than deleted. **110 AAO tests, 110 passing.**

**Defect one: `isFull()` never consulted the element list.** It returned
`missing.isEmpty()`, so a proposal could declare itself complete by sending an empty missing
list. `covered:['e1'], missing:[]` against a three-element proposition read as full coverage
and routed its verdict straight through, unchallenged.

The no-argument version is gone. `isFull(List<String> contractElements)` checks that every
element the **contract** names is covered, and `AAO_Accumulate.verdictFor` takes the element
list and passes it. `AAO_Commit` reads `AAO_Evidence_Contract__r.AAO_Elements__c` and hands
it in, so the authority on what full means is the contract rather than the thing being
judged. A contract naming no elements returns false, because treating an empty list as
trivially satisfied would establish propositions out of nothing.

Two new assertions in `AAO_EvidenceLayerTest.verdictRoutesOnCoverage` state the defect
directly: one element of three with an empty missing list is `UNVERIFIED`, and an empty
element list is never full.

**Defect two: the artifact hash was computed over the path label.**
`AAO_Artifact_SHA256__c = sha256(sourceRef)`. Since that hash composes the scope key, and the
scope key is the dedup target, **identity was the filename**. Two different transcripts
delivered under one path label collided and the second was discarded as a re-delivery. One
transcript delivered under two labels looked like two pieces of evidence.

The hash is over content now, via `AAO_Seed.artifactSha`. In this build it equals
`AAO_SHA256__c`, because the fixture hands us turns rather than a file, so the delivered
artifact and the stored normalized text are the same string. They diverge the moment a real
connector lands, and keeping both named separately is what makes that a one-line change
rather than a change of meaning.

**The defending test was the worse half.** `theScopeKeyIsComposedByTheTriggerAndDedupes`
inserted a Source with **different text** while reusing the artifact hash and asserted the
rejection as correct. It was not correct; it was the defect written down as an expectation.
Corrected so a re-delivery is genuinely the same bytes, and a second test,
`twoDifferentArtifactsUnderOneLabelAreNotARedelivery`, asserts the half that was inverted:
different bytes under one label are different evidence and both must be stored.

`AAO_LiveIngestTest.stagedProposalsAreFoundByArtifactHashNotByFixtureCode` hashed the label
too, and now asserts that the artifact hash is **not** the hash of its path label.

**Assumed, not verified.** **Rows written before tonight carry the old label hashes**, so
stored data and current code disagree on how those hashes were derived. Nothing breaks:
every affected Source already has a claim, and `runForSource` short-circuits on
`already_committed` before it looks for a proposal. But a purge and reseed is required for a
clean org, and until that happens the three demo deals and the two Gate 1 deals hold hashes
no current code path would produce. Deliberately not reseeded: the proof register cites those
claim numbers.

---

## 2026-07-31 · session 12 · discovery, and the receipt that "works anywhere"

**Did.** Item 35, all five parts. The accumulation exit test now passes against Evidence
Contracts **the org produced**, not contracts we typed. **110 AAO tests, 110 passing.**

```
DISCOVERY EXIT TEST
  AUTHORED  questions present 6
  plan type "AAO Discovery" carries AAO_T1,AAO_T2,AAO_T3,AAO_T4,AAO_T5,AAO_T6
  cold start: opportunity 006WD00000SjxtTYAR with an Altify Opportunity on it
  DISCOVERED 6 contracts (5 Authored, 1 Inferred_Pending)
    AAO_T1 questionRecordId=a0aWD00000QamjuYAB basis=Authored elements=3 state=Derived
    AAO_T5 questionRecordId=a0aWD00000QamjyYAB basis=Inferred_Pending elements=1
           state=Awaiting_Ratification
  PASS T1SRC: verdict=UNVERIFIED claim=Established
  PASS T2SRC: verdict=TRUE claim=Established
  EXIT TEST PASSED against contracts the org produced.
  REPLAY exact=true.
```

`AAO_Question_Record_Id__c` is an Altify record id at last. Session 1's seed carries the
comment *"In production this is the rubric question's own record id. Here it is the fixture
code, padded, because there is no rubric record to point at until discovery runs against the
org."* That sentence is now false, which is the point of writing it down.

---

### 35e. THE DISCOVERY SPEC. Every ALTF name and behaviour read from the org, verbatim.

This section is the deliverable. Everything below cost a query, and every line of it would
have broken a plausible guess.

**`ALTF__Assessment_Question__c` — the rubric row. Org-global.**

| Field | Type | Note |
|---|---|---|
| `ALTF__Question__c` | picklist, **required, restricted** | **NOT the question.** Five values only: `Is the renewal at risk?`, `Is there an opportunity?`, `Can we compete?`, `Can we win?`, `Is it worth winning?` |
| `ALTF__Criterion_Text__c` | Text(255), **required** | **This is the question text.** |
| `ALTF__Help__c` | Textarea(1024) | The only field that can carry element decomposition. Authored path or nothing. |
| `ALTF__Long_Question__c` | Textarea(1280) | Unused by us. |
| `ALTF__AltifyId__c` | Text(100), **UNIQUE** | The natural external key. Proven unique by `DUPLICATE_VALUE, duplicate value found: ALTF__AltifyId__c duplicates value on record with id: a0aWD00000QamjuYAB`. A real discovery upserts on this. |
| `ALTF__Order_Number__c` | Number, **required** | |
| `ALTF__Active__c`, `ALTF__Mandatory__c`, `ALTF__Recommended__c`, `ALTF__Summary__c` | Checkbox | `Mandatory` is the closest thing to our gating flag. |
| `ALTF__Yes_Score__c`, `ALTF__No_Score__c`, `ALTF__Unknown_Score__c`, `ALTF__Yes_Label__c`, `ALTF__No_Label__c` | | Scoring. We never score. |
| `ALTF__Support_Competitor_Answer__c` | Checkbox | |

**It has no plan type lookup, no opportunity lookup, and no relationship to anything.** The
question set is one flat list per org.

**`ALTF__Opportunity_Plan_Type_List__c` — the plan-type chain. A custom setting, keyed by
`Name`.**

`ALTF__AssessmentQuestionIds__c`, **Text(255)**, and **its name is a lie**. It does not hold
Salesforce ids. It holds Altify codes, comma delimited, verbatim from this org:

```
Cross Sell    TC_1,TC_2,TC_4,TC_5,TC_6,TC_7,TC_9,AC_1,TC_10,TC_11,TC_12,TC_14,TC_15,TC_16,TC_13,TC_18,TC_20
Renewal       RC_1,RC_2,RC_3,RC_4,RC_5,RC_6,TC_6,TC_7,AC_1,TC_10,TC_14,RC_11,RC_13
```

Those codes join to `ALTF__Assessment_Question__c.ALTF__AltifyId__c`. **An implementation
that split this on commas and queried by Id would find nothing and report an empty rubric.**
The 255-character ceiling is a real bound on how many questions a plan type can carry:
Cross Sell is already at 93.

Also on it: `ALTF__Show_Assessment__c` (checkbox), the `ALTF__Show_FSM1__c` through
`ALTF__Show_FSM10__c` flags, and per-plan-type custom tab configuration.

**`ALTF__Opportunity_Manager_Settings__c` — a hierarchy custom setting, one org row here.**
`ALTF__Opportunity_Plan_Type__c` is a **string**, not a lookup: the default plan type is
named by text and joined to the list by `Name`.

**`ALTF__Assessment_Answer__c` — their answer row.** `ALTF__Opportunity__c` (lookup),
`ALTF__Assessment_Question__c` (lookup), `ALTF__Answer__c` picklist `Unknown` / `Yes` / `No`,
`ALTF__CompositeKey__c`, `ALTF__Note__c`, `ALTF__NoteEntered__c`, `ALTF__AltifyId__c`.
Three-valued, one row per opportunity per question. **This is the projection target when
that phase arrives, and its answer vocabulary is not ours.**

**`ALTF__Opportunity__c` — the Altify Opportunity, and the cold start.** It carries
`ALTF__Opportunity__c`, a **required** lookup to the **standard** Opportunity. It does not
exist until something creates it, and `ALTF__Assessment_Answer__c` points at **it**, never at
the standard Opportunity. A deal with no Altify record is the cold-start condition and
`AAO_Discovery.coldStart` is what resolves it.

**The state of this org, which is the customer condition and not a broken sandbox.**
`ALTF__Assessment_Question__c` held **zero rows**. The nine configured plan types list codes
(`TC_1`, `RC_11`, `AC_1`) for questions that **do not exist here**, and
`ALTF__Show_Assessment__c` is **false on all nine**. Config referencing a question set nobody
loaded is the normal starting state.

**WHAT ALTIFY DOES NOT CARRY, which matters more than what it does.**

- **No speaker requirement.** Nowhere on the question, nowhere on the plan type. It cannot be
  discovered because it does not exist to discover. Discovery writes `Any_Participant` and
  the journal says so. **This is the per-org charter overlay the seed named as an open design
  item, and discovery has just proved it is not optional.**
- **No route.** Our `AAO_Route__c` is mapped from the five categories by a table in
  `AAO_Discovery.ROUTE_BY_CATEGORY`. That mapping is **our convention, not Altify semantics**,
  and it is stated in the class so nobody reads a route off a contract and believes the
  customer authored it.
- **No decay class, no solicit flag, no per-person source.** Defaulted.

**Consequence, and it is the honest limit of tonight.** The seller-said-it downgrade
**cannot be reproduced from org-derived contracts**, because the requirement that produces it
is not in the org. The demo deals still show it; they run on the seeded rubric. Any claim
that the speaker rule works "from the customer's own rubric" would be false until the overlay
exists.

---

**Decided, and why.**

- **A new plan type, `AAO Discovery`, rather than editing one of the nine.** Those are
  customer configuration. Discovery reads the chain without touching them.
- **One proposition authored WITHOUT an elements block, on purpose.** `AAO_T5` has no
  `Elements:` section in its Help, so discovery has to reach `Inferred_Pending` honestly
  rather than being handed `Authored` for everything. It came back
  `basis=Inferred_Pending elements=1 state=Awaiting_Ratification`, which is the path a real
  under-specified customer question takes.
- **`AAO_Pipeline.contractsOverride` is a seam, not a second pipeline.** The whole claim is
  that the SAME code reaches the same outcomes against a rubric it did not author. A parallel
  discovery pipeline would have proved nothing.
- **Text is carried verbatim.** `AAO_Proposition_Text__c` is `ALTF__Criterion_Text__c`
  unmodified and `AAO_Guidance_Text__c` is `ALTF__Help__c` unmodified, because the content
  hash covers them and an upstream edit has to surface as a new contract rather than as a
  silent change of meaning.

**Read from the org (verbatim), the failures worth keeping.**

- `Discovery produced no contracts.` from a rubric that was sitting right there. The cause:
  `WHERE ALTF__AltifyId__c LIKE 'AAO\_%'`. The underscore is a SOQL single-character
  wildcard, escaping it inside an Apex string literal is not a documented escape, and **the
  query failed by returning zero rows rather than erroring.** Replaced with
  `WHERE ALTF__AltifyId__c IN :codes`. A silent-empty query is the worst failure mode in a
  discovery pass, because an empty rubric looks exactly like a customer who has not
  configured one.
- `DUPLICATE_VALUE, duplicate value found: ALTF__AltifyId__c duplicates value on record with
  id: a0aWD00000QamjuYAB` — which is how we learned the field is unique.

**Assumed, not verified.**

- That `ALTF__Show_Assessment__c = true` on our plan type makes the assessment visible in the
  Altify UI. Set, never looked at on screen.
- That the five categories map to routes the way `ROUTE_BY_CATEGORY` says. It is a convention
  we invented tonight and no Altify document was consulted.
- That a real customer rubric fits the `Elements:` convention in Help. Ours does because we
  authored it. **A customer's Help text will not**, which is why `Inferred_Pending` exists and
  why one proposition was deliberately routed through it.

**Owed.**

1. **The per-org charter overlay.** Speaker requirement and route have no home in Altify. This
   is now measured rather than predicted.
2. **Discovery reads one plan type by name.** Real orgs pick the plan type per opportunity;
   `ALTF__Opportunity_Manager_Settings__c.ALTF__Opportunity_Plan_Type__c` is the org default
   and there is presumably a per-opportunity selection not yet found.
3. **Projection into `ALTF__Assessment_Answer__c` is untouched**, as ruled. Their vocabulary
   is `Yes` / `No` / `Unknown` and ours is `TRUE` / `FALSE` / `UNVERIFIED`; the mapping is a
   decision, not a translation.
4. Everything on session 4's list that remains.

---

## 2026-07-31 · session 13 · the trap, the guard, and where rule data actually lives

**Did.** Items 36, 37, 38. **117 AAO tests, 117 passing**, and the discovery exit test still
green after re-authoring.

### 36. The describe, verbatim, and it does not fully agree with the glossary

`ALTF__Long_Question__c` **is present**. Here is the org, unedited:

```
--- Name
    label = 'Assessment Criterion Name'      type = 'string'    length = 80
--- ALTF__Question__c
    label = 'Section Heading'                type = 'picklist'  length = 255  nillable = False
    inlineHelpText = 'The section heading under which the criterion will be displayed.
      Defined as a picklist, you can edit the section headings (change the names of the
      existing and/or add new) under App Setup > Create > Objects > Assessment Criterion
      > Section Headi'
--- ALTF__Criterion_Text__c
    label = 'Criterion Text'                 type = 'string'    length = 255  nillable = False
    inlineHelpText = 'This is the text of the criterion, i.e. "Is there a compelling event?"'
--- ALTF__Help__c
    label = 'Help'                           type = 'textarea'  length = 1024
    inlineHelpText = 'Tip/Hint text displayed to the user on clicking the 'i' icon beside
      the assessment criterion. The same text is also displayed on the right of the
      "add comments" pop-up screen.'
--- ALTF__Long_Question__c
    label = 'Question Text'                  type = 'textarea'  length = 1280
    inlineHelpText = None
```

**Two sources disagree and both are credible.** Production's glossary rules `Long_Question`
the proposition and `Criterion_Text` a short title. The field **label** agrees: the one
called "Question Text" is `Long_Question`. But **this org's own inline help on
`Criterion_Text` says the opposite**, in terms, with an example sentence: *"This is the text
of the criterion, i.e. \"Is there a compelling event?\""*.

Followed the ruling and re-authored, **and made the read tolerate both**, because a
disagreement between the glossary and the shipped help text is a disagreement real customer
orgs will also contain. Discovery reads `Long_Question` as the proposition **when it is
populated** and falls back to `Criterion_Text` when it is blank, recording which it used:

> *"Long Question is empty, so the proposition was read from Criterion Text. In an org that
> authors the sentence there, that is correct; in an org that authors a short title there,
> this contract carries a title where a proposition belongs."*

Re-authored and re-run, verified in the org:

```
ALTF__Assessment_Question__c  AAO_T1
  ALTF__Criterion_Text__c  = "Budget Confirmed"
  ALTF__Long_Question__c   = "The customer's decision maker has confirmed that budget is
                              secured for this initiative in the current fiscal year."

AAO_Evidence_Contract__c      AAO_T1
  AAO_Proposition_Short__c = "Budget Confirmed"
  AAO_Proposition_Text__c  = "The customer's decision maker has confirmed that budget is
                              secured for this initiative in the current fiscal year."

EXIT TEST PASSED against contracts the org produced.  REPLAY exact=true.
```

**A correction to session 12.** That entry called `ALTF__Question__c` a picklist of "five
assessment categories" and implied the set was fixed. Its label is **Section Heading** and
its own help says the values are **editable and extensible per org**. So the five values in
this org are this org's, not Altify's, and any mapping keyed on them is keyed on customer
configuration. That makes item 38 sharper rather than softer.

**A finding from a collision.** Re-authoring moved the sentence from `Criterion_Text` to
`Long_Question` and the insert failed on `DUPLICATE_VALUE ... AAO_Contract_Key__c`. The key
is question record id plus content hash; the **content did not change**, only the field it
was read from, so identity held. That is the composer behaving exactly as designed, and it
proved it under a change nobody designed it for.

### 37. The guard

Discovery can no longer report an empty rubric without saying which kind of empty it is.

```
DISCOVERY FILTER FAULT, not an empty rubric. ALTF__Assessment_Question__c holds N rows
and the plan type "..." lists M codes (...), and none of them matched ALTF__AltifyId__c.
The rubric exists and this query cannot see it. Do not report this as an unconfigured org.
```

A non-empty table with zero matches is now a thrown fault. An empty table is the cold-start
condition and says so. This is written directly against session 12's `LIKE 'AAO\_%'`
failure, where a filter bug and an unconfigured customer produced **the same silent
result**, and the same shape would have hidden the wrong join key on
`ALTF__AssessmentQuestionIds__c` too. Four tests cover it plus the two no-configuration
cases.

**One more purge fault worth recording.** Derived contracts were being purged with
`AAO_Synthetic__c = TRUE` in the filter, and they were not marked, so six contracts from an
earlier run survived every purge and collided on the next insert. `AAO_Evidence_Contract__c`
carries **no delete law** (Source, Claim and Flag do), so the marker there was never a guard,
only a query filter pretending to be one. Purge is by `AAO_Rubric_Version__c = 'discovered-v1'`
now, which is our namespace by construction and the honest ownership test.

### 38. Recorded, not built: speaker requirement and route are OUR rule data

**Ruled and written down rather than implemented tonight.**

`AAO_Speaker_Requirement__c` and `AAO_Route__c` are **our rule-data layer**. They are not
discovered from Altify and never will be, because Altify carries neither: session 12 read the
whole question object and neither concept exists on it, on the plan type, or on the settings.

The sequence, per the existing setup-time-inference ruling:

1. **Discovery floor stays `Any_Participant`.** What discovery writes today is not a guess
   dressed as a read. It is the weakest requirement, which establishes least, and it is the
   correct floor for a value nobody has ratified.
2. **A setup-time inference pass proposes them**, per question, from the authored text.
   Charter-config work, sequenced later.
3. **A human ratifies.** Nothing a proposal pass produces becomes rule data unheard, which is
   the same bar Gate 1 sets for verdicts.

`AAO_Discovery.ROUTE_BY_CATEGORY` is therefore a **placeholder, and now a weaker one than it
looked**: it is keyed on Section Heading values that each org can rename and extend. It stays
because a contract needs a route, it is labelled in the class as our convention, and it is
first in line to be replaced by the proposal pass.

**The consequence stands and is unchanged.** The seller-said-it downgrade cannot be
reproduced from org-derived contracts until that layer exists. The demo deals show it because
they run on the seeded rubric. Anyone describing the speaker rule as working "from the
customer's own rubric" would be wrong.

**Owed.** The setup-time inference pass, and everything remaining on session 4's list.

---

## 2026-07-31 · session 14 · a filter becomes a law, and the Flag tab goes honest

**Did.** Items 39 and 40. **125 AAO tests, 125 passing.**

### 39. Evidence Contract is not deletable

Ratified and enforced. `AAO_EvidenceContractTrigger` gains `before delete`, and the handler
refuses unless the row is marked synthetic **and** the purge context is open, matching Source,
Claim and Flag.

The reason is the same as Claim's. Every claim carries the contract key it was adjudicated
under and still names it after the contract is gone, so deleting one leaves verdicts that
nothing can explain and no replay can reconstruct. **Supersede is the retirement path**, and
the error message names it: `AAO_Superseded_By__c` plus a contract state of `Superseded`
retires a contract without destroying what rests on it.

Session 13 had it exactly right that the marker was a filter pretending to be a guard. Two
tests now separate the two halves: the marker alone is refused, and the marker plus the purge
context succeeds.

**A finding while testing it.** The seed does **not** mark its contracts on the
`AAO_Seed.load` path, and does on the demo path, because `AAO_Pipeline` sets the marker from
the Source before calling `ensureContracts`. So a contract's marker depends on which entry
created it, and with a delete law in place that now decides whether the purge can remove it.
Recorded rather than fixed, because changing the seed's marking is a separate decision.

### 40. Day-one red

Every gating proposition stands red from the moment the deal exists.

```
--- AAO Demo - Live               candidates=0  sources=0  redsStanding=2
--- AAO Demo - Tungsten Rehearsal answer AAO_T1 = TRUE     redsStanding=1
--- Tungsten (seller said it)     answer AAO_T1 = UNVERIFIED  redsStanding=2
```

`Methodological`, state `Standing`, cause `Gating_Unmet`, and **`AAO_Raised_At__c` is the
opportunity's `CreatedDate`**, never `now()`. That is what makes age mean "how long has this
deal stood unanswered" rather than "how long since we noticed". The Flag trigger stamps
`now()` when the field is null, so it is set explicitly.

Establishment of `TRUE` clears it and records what cleared it. `FALSE` holds it and changes
the cause to `Established_False`, because a gating condition that is actively false is worse
than one nobody has evidence for and a count that treated them alike would measure the wrong
thing. `UNVERIFIED` holds it unchanged: partial evidence is not establishment. Clearance is
called from `AAO_Commit`, which is the single writer of the answer.

**The demo beat.** `AAO Demo - Live` opens with two reds standing. Ingest one leaves them
standing, because partial evidence establishes nothing. Ingest two clears one. The
seller-said-it deal keeps both reds **with full element coverage**, which is the sharpest
version of the speaker rule anyone will see: every part was said, and nothing was established,
so nothing cleared.

`AAO_Demo.status()` now prints `redsStanding=` per deal, and the pipeline view's flag sentence
has been rewritten. It used to read *"Nothing raises them yet"*. It now distinguishes three
genuinely different states: reds standing, all cleared by evidence, and a rubric that carries
no gating propositions at all, which "is a fact about the rubric, not a clean bill of health
for the deal."

**Decided, and why.**

- **Not a trigger on Opportunity.** "Raise on deal creation" sounds like a trigger and cannot
  be one: Opportunity is a standard object and the constraint is absolute. Raising is called
  by the paths that create deals, and `raiseFor` is idempotent so calling it twice is free.
  In production the caller is whatever provisions a deal into AAO. **That is a real
  difference from the design's wording** and it is recorded rather than glossed.

**Read from the org, and the two failures that taught the most.**

- **The first raise produced four reds per deal where two were theirs.** Once discovery has
  run, an org holds **more than one rubric at a time**: the seeded `mini-0.1.0` and the
  derived `discovered-v1`. A raise path that asked only "which contracts are gating" flagged
  every deal against every rubric in the org. `raiseFor` now takes a rubric version. **A deal
  is red against the rubric it is adjudicated under, not against every rubric that exists**,
  and nothing in the design had said so because until session 12 there was only ever one.
- **Raising ran before the contracts existed.** `AAO_Demo.scaffold` raised flags before the
  rubric was loaded, so it raised nothing, silently. It passed in the org because a previous
  run had left contracts behind, and failed in a test, which is the right way round to find
  it. `ensureContracts` now runs first.

**Assumed, not verified.** That `Not_Returned` and the new flag counts render sensibly on the
pipeline view. The controller was changed and its tests updated, but nothing has been looked
at on screen since session 6.

**Owed.**

1. **Nothing raises `Escalated`.** `AAO_Escalation_Threshold__c` sits on the contract and no
   code reads it, so a red stands forever at the same weight however old it is.
2. **Contention and Ratification flags still have no raise path.** Day-one red is the
   Methodological one only.
3. **The demo deals now carry flags**, which changes what the Flag tab shows from empty to
   populated. The run sheet's line *"if he clicks the Flag tab, it is empty"* is now wrong and
   the sheet needs a bump.
4. Everything remaining on session 4's list.

---

## 2026-07-31 · session 15 · one rubric per deal, and who owns a derived row

**Did.** Items 41, 42, 43. **125 AAO tests, 125 passing**, discovery exit test still green.

### 41. Rubric scoping is a law, and it was hiding in two more readers

`AAO_Rubric` is now the only reader of contracts. Session 14 scoped the flag raise and
stopped there, which fixed the symptom. Promoting it to a law found the same hole twice more:

- `AAO_Pipeline.liveContracts()` returned **every non-superseded contract in the org**.
- `AAO_Extract.run()` queried the same way for the charter prompt.

So after discovery ran, a model pass would have sent **twelve propositions where six were the
deal's**, and written an abstention row for every one of the six that were not. **It would
have read as thoroughness.** More propositions considered, more reds, more abstentions
logged: every number moves in the direction that looks like rigour. That is why this is a
law rather than a fix.

**The sandbox collision is a miniature of the real one**, and the class header says so. Two
rubrics in one org is not an artefact of having a seeded and a derived rubric here. It is
what a customer editing their rubric mid-quarter produces: a contract is per proposition per
version of its text, an edit creates a new generation, and deals opened before the edit are
still adjudicated under the old one. **Both generations are live and correct at the same
time.** Any reader asking "which contracts exist" rather than "which contracts is this deal
judged under" mixes them.

**The honest limit, recorded in the class.** There is no field saying which rubric a deal is
adjudicated under. `AAO_Rubric.active` is a caller-set static, so the binding lives in
whoever starts the run rather than on the deal. That is enough for one rubric per org and
**not enough for the mid-quarter edit this law exists to survive**. The binding wants to be a
field. Until it is, `AAO_Rubric` is the single place that would have to change.

### 42. Who owns a derived row

**Seeder-created rows are synthetic by the standing law.** `AAO_Seed.ensureContracts` now
marks unconditionally instead of inheriting whatever `MARK` happened to be set, which is what
made a contract's marker depend on which entry created it: marked from the demo path,
unmarked from `AAO_Seed.load`. With a delete law on the object, that inconsistency decided
whether the purge could remove a row.

**Discovery-derived rows are real system output and stay unmarked.** Six existing ones were
unmarked to match. They are therefore undeletable under session 14's law, which is correct
rather than awkward: **supersede is their retirement path.**

That forced a better design than the one it replaced. Discovery no longer purges and
reinserts its contracts; it **reuses them by contract key**. Unchanged upstream text produces
the same question record id and the same content hash, therefore the same key, therefore the
same contract:

```
AAO_T1: unchanged since the last pass, contract reused
...
purge: flags 2, bases 0, claims 2, candidates 12, answers 1, sources 2,
       derived contracts kept 6
```

That is what a contract is supposed to do, and the delete-and-reinsert it replaced was
quietly minting a new identity for the same proposition on every run.

**A state leak found while doing it.** The discovery purge cleared the deal's evidence and
left its flags, so a red cleared by a previous run stayed cleared against evidence that no
longer existed, and a reset did not return the deal to day one. Flags are purged now, and the
deal reads `raised 2, standing 2` at day one and `standing 1` after both passes.

### 43. Escalation stays unbuilt, and the reason is the point

Recorded rather than built. **`AAO_Escalation_Threshold__c` is a percentage of a denominator
that does not exist yet.** Age against what? The answer is Altify's derived close date, and
that requires Altify configured on the deal: an `ALTF__Opportunity__c` record with a plan and
a date, which is precisely the projection-era dependency this build has been careful not to
take on.

An escalation threshold measured against anything else would be measuring elapsed time
against a number we invented, and reporting it as urgency. **A red standing at uniform weight
is honest for now**: it says this gating condition is unmet, and it does not pretend to know
how late that makes the deal. It lands with projection-era work, not before.

**Owed.**

1. **The rubric binding wants to be a field on the deal**, not a static on the run.
2. **Supersede has no path.** A contract whose upstream text changes should be superseded and
   replaced; today discovery would simply insert the new generation and leave the old one
   live, which is exactly the two-generations condition item 41 is about.
3. Escalation, with projection.
4. The run sheet's "the Flag tab is empty" line, still wrong.
5. Everything remaining on session 4's list.

---

## 2026-07-31 · session 16 · supersede, and the binding becomes a fact about the deal

**Did.** Items 44 and 45, plus a full `docs/` replacement. **127 AAO tests, 127 passing**,
discovery exit test green.

### 44. Supersede

`AAO_Superseded_By__c` already carried the description *"Written by: Discovery, on hash
change."* It now is.

Same rubric question, different content hash, means the customer edited the words. That is a
**new generation of the proposition, not a correction to the old one**, because every claim
already stamped with the old contract was adjudicated against words the new one does not
carry. The old contract is set to `Superseded`, points at its replacement, and **keeps its
text verbatim forever**. It is never deleted, which is the entire reason session 14 made the
delete law.

The test does what item 44 specified: edit a question's text, re-run discovery, assert one
superseded and one live. It also asserts the old contract still holds the old wording, and
that a rubric-scoped read returns exactly one generation, because a superseded contract that
still reached a reader would reintroduce the two-generations bug from the other direction.

`AAO_Contract_State__c` and `AAO_Superseded_By__c` are outside the frozen set, so the
retirement is a legal update while the words stay immutable. That was designed in session 2
and used for the first time tonight.

### 45. The binding is a fact about the deal

`Opportunity.AAO_Rubric_Version__c`, written once at cold start or first adjudication, read
by `AAO_Rubric.versionFor`. Session 15 named this as the honest limit of that session, in
those terms, and it was right: `active` expressed a property of **the execution** when the
question is a property of **the deal**.

```
AAO Demo - Live                            -> mini-0.1.0
AAO Demo - Tungsten Rehearsal              -> mini-0.1.0
AAO Demo - Tungsten Rehearsal (seller...)  -> mini-0.1.0
AAO Discovery - Derived Contracts          -> discovered-v1
```

**Bound once and then left alone.** A deal already bound is not rebound: it has claims judged
under that rubric, and rebinding would make them incomparable to whatever came next,
silently. `AAO_Rubric.active` survives only as the value an **unbound** deal is bound to on
first adjudication, and as the fallback for a deal nothing has judged.

`AAO_Rubric.bind` is DML, so it runs after the callout on the model path. Ordering that the
session 7 rule already forced, now with a second reason.

**A field on the standard Opportunity, which is an exception to nothing.** The standing
constraint forbids fields on managed `ALTF__` objects and triggers on objects we do not own.
This is neither, and no trigger reads or writes it.

**Two deals read blank and were backfilled.** `AAO Gate1 - Model Round Two` and
`AAO Gate1 - Blind Reader` were adjudicated before the field existed, and blank means "nothing
has judged this deal yet", which was false of both. Bound to `mini-0.1.0`, which is what they
actually ran under.

### The docs replacement

`docs/` replaced wholesale from `aao-context 5`, as instructed, and treated as read-reference
only. The journal remains the write surface.

- **`aao-demo-runsheet-v1_2.md` replaces v1.1**, and the line this build flagged as wrong is
  gone. It reads *"The empty-Flag-tab line is retired; flags-do-not-age-yet takes its slot"*,
  and the new act one is **"The 'empty' deal that already owes answers"**. Checked against the
  org and it matches exactly: two reds standing on Live, unmoved by pass one because partial
  evidence establishes nothing, one clearing on pass two, and the seller-said-it deal holding
  both reds at full coverage.
- Its new closing bullet carries session 15's escalation reasoning verbatim, denominator and
  all.
- **`aao-field-tables-v0_8.md` is gone**, superseded by v0.10. Noting it because v0.8 is the
  version this entire build was authored from; what mattered from it is quoted in sessions 1
  to 6 and the removal loses nothing that is not written down here.
- New: `aao-state-board-v2_1.html`. Updated: the proof register and the competitive rebuttals.

**Owed.**

1. **The proof register is behind the org.** It still describes the state at session 8 and
   does not carry the blind reader's receipt, discovery, day-one red, or the two owed defects
   being paid. Its rows 12 and 19 were offered corrections in sessions 8 and 9 that have not
   landed. Not a code gap.
2. **Nothing supersedes a seeded contract**, only a derived one. The seed reuses by question
   record id rather than by content hash, so editing the fixture's wording would mutate
   meaning under a stable identity. Fine while the fixture is frozen, wrong the moment it is
   not.
3. Escalation, with projection. Everything remaining on session 4's list.

---

## 2026-07-31 · session 17 · version is attribution, never routing

**Did.** Item 45 revised; the previous 45 is cancelled and its field deleted from source and
from the org. **128 AAO tests, 128 passing**, discovery exit test green.

**The ruling, and it corrects me.** A deal always answers the org's **current active
questions**. Version is **attribution on receipts** and never routing: a claim records the
contract it was adjudicated under so anyone can see what the question said at the time, which
is a fact about the receipt rather than an instruction about which questions to ask next.

Session 16 built the opposite. It read a rubric version off the deal to decide which
questions to ask, and its justification was that two rubrics coexist in the org. **That is a
test-org artefact, not a product state**: it exists because this sandbox holds a seeded
fixture beside a derived rubric, and no customer org does that. Building a routing mechanism
on it made a scaffolding condition permanent.

`Opportunity.AAO_Rubric_Version__c` is deleted. Confirmed gone by query: no `AAO%` field
remains on Opportunity.

**The rule that replaces it.** The product path reads contracts that are **active,
non-superseded and unmarked**. Seeded rows are synthetic and invisible to it. Test and demo
entries opt into the synthetic set **by saying so at the call site**.

```
PRODUCT set (unmarked, active): 6
  AAO_T1..AAO_T6  rubric=discovered-v1   (T5 Awaiting_Ratification, the rest Derived)
SYNTHETIC set (opt-in): 6
```

**The default is the safe one**, and that is the point of choosing this discriminator. A new
reader that calls `AAO_Rubric.contracts()` and has never heard of any of this gets the
product's questions and never the fixture's. An accident fails towards asking real questions
about nothing rather than answering real deals with rehearsal questions.

**The caller-set static is retired.** It made the answer depend on execution order, and
nothing that reads a rubric should have to know what ran first. The scoped-reader structure
from item 41 stays: `AAO_Rubric` is still the only reader, and it still exists because an
unscoped read gave every deal four reds where two were its own.

**Supersede is untouched**, exactly as specified. When upstream text changes the old
generation retires and the new one is simply the question. That is now the *only* mechanism
by which a rubric changes generation, which is what the ruling means: there is no old
generation still being asked of anybody, only old claims still naming what they were judged
under.

**Read from the org.** The extraction tests failed on the revision, and they were right to.
They drive the model path, the model path is the product path, and the only rubric they had
was the marked fixture, so the product set was empty and every one of them reported *"No
evidence contracts in the org. There is nothing to ask about."* The fix is not a seam: they
now stand up their rubric **unmarked**, via a new `AAO_Seed.ensureContracts(fixture,
synthetic)`, which is them declaring that what they are testing is the org's questions rather
than a rehearsal fixture. The contract key is unique, so a proposition cannot exist in both
populations at once and the choice has to be made once, at creation.

**Assumed, not verified.** That no other caller depends on seeing both populations at once.
`AAO_Rubric` is the only reader and both its entries are explicit, so the compiler would have
caught a third, but nothing proves a future one will not call `contracts()` meaning
`contracts(true)`. The naming is the only guard.

**Owed.** Unchanged, minus the binding, which no longer exists to be owed. The proof register
is still behind the org, and nothing supersedes a seeded contract.

---

## 2026-07-31 · session 18 · the P route, and the schema question it found

**Did.** Item 46, parts a, b, d and e complete; c and f **blocked on a schema decision that
is Matthew's**, refused loudly rather than worked around. **132 AAO tests, 132 passing.**

### What works

**a. Real map rows.** `ALTF__Contact_Map_Details__c`, Dana as `Decision Maker` on the demo
deals. Data rows on a managed object, which the constraint permits; the field that ties a
basis to one lives on `AAO_Claim_Basis__c`, which is ours.

**b. Deterministic, no model.** "Is a decision maker identified on the relationship map" is
answered by counting rows on the relationship map. A model asked to do that could only be
less reliable than the count. An empty map returns `UNVERIFIED`, not `FALSE`: the absence of
a record is not a record that there is nobody, the same distinction the extraction charter
had to be taught in session 9.

**d. State verification, the twin of the byte check.** The byte check asks *are these words
actually in this artifact*; this asks *does this record actually say this*. Every cited row
is re-read before commit and confirmed to still carry the value being claimed, and a failure
**refuses the claim rather than downgrading it**: a row that does not say what it is cited
for is not weaker evidence, it is absent evidence.

The reason this route needs a different check at all is that a span and a map row are
opposite kinds of evidence. A transcript is immutable, so a quote verified once is verified
forever. A map row is live customer data, editable by anyone, usually by someone with no idea
a claim rests on it. Dana is Decision Maker today and Evaluator next Tuesday.

**e. The map beats the roster.** `AAO_SpeakerRule` now prefers the buying role on the org's
relationship map and falls back to the artifact roster, and the verdict reason names which it
used: *"Dana Ruiz is Decision Maker, per the relationship map"*. The roster is what a
transcript asserted about who was on a call; the map row is what the customer's own records
say about who this person is on this deal. **Standing is not something a transcript gets to
declare.** Tested both ways: the same speaker fails on a roster saying `User` and passes on a
map saying `Decision Maker`.

### What is blocked, and why I did not route around it

**`AAO_Candidate__c.AAO_Source__c` is required, and a P-route candidate has no Source.** Its
evidence is a record, not an artifact: no transcript, no bytes, nothing to point a Source at.
The schema was closed on the assumption that every candidate comes from a piece of delivered
evidence, and route P is the first thing to prove otherwise.

Two ways out, and both are rulings rather than fixes:

1. **Make `AAO_Source__c` optional on Candidate**, with the route or cited type carrying the
   discriminator. A change to a CLOSED table.
2. **Give a state read its own Source**, on the grounds that *the relationship map as it
   stood at 14:02* is the artifact and the snapshot is its bytes. Tidier in the model, and it
   invents an artifact nobody delivered.

I could have manufactured a Source and had a green end-to-end run tonight. That would have
made the schema decision silently, in a direction nobody chose, and buried it in a helper.
The route throws instead, naming both options and reporting how far it got:

```
The P route cannot write a Candidate: AAO_Candidate__c.AAO_Source__c is required and a
state-derived candidate has no Source. 1 map row(s) carry the role "Decision Maker",
state verification passed, and nothing was written. This is a schema decision, not a
defect: see AAO_MapRoute for the two options.
```

**The block is pinned as a test**, so whichever way it is ruled, the ruling is deliberate.

**c and f are built but unexercised.** `AAO_Claim_Basis__c.AAO_Cited_Map_Row__c` is added
(recorded below as an addition to a closed table), the snapshot shape is written, and
`AAO_MapRoute.thenAndNow` returns THEN and NOW from one subquery. None of it has run against
a real claim, because there is no real claim to run it against. I did not assert item 46f
against a hand-built claim: that would prove the query works and nothing about whether the
route produces one.

**Addition to a closed table, for ratification.** `AAO_Cited_Map_Row__c`, a lookup from
`AAO_Claim_Basis__c` to `ALTF__Contact_Map_Details__c`. `AAO_Cited_Type__c` has carried
`Map_Row` since session 2 and its description reads "which lookup is populated", plural, so
this completes a shape the discriminator already described. It is a lookup on our object to
a managed one, which is permitted; a field on theirs would not be.

**A design error of mine, caught by a test.** `AAO_MapRoute.run` originally read
`AAO_Synthetic.MARK` to decide which population it belonged to. That is exactly the implicit
form session 17 threw out: the answer depended on whether the last caller happened to leave
the marker set, and the demo's own scaffold clears it in a finally block. The caller declares
it now.

**Owed.** The Source ruling, and then c and f run for real. Everything else on session 4's
list.

---

## 2026-07-31 · session 19 · the evidence-family law, and the P route finished

**Did.** Item 47 as ruled, and item 46 c and f, which it unblocked. **139 tests, 139
passing** (was 132).

### The law

`AAO_Source__c` is no longer required on Candidate or Claim. In its place, in the triggers:

| Basis | Source | Spans | Cited rows |
|---|---|---|---|
| Transcript | required | required on a claim | forbidden |
| State | **must be null** | forbidden | at least one |
| Both | required | required on a claim | at least one |

**This is stronger than what it replaced, not weaker.** `required` only ever asserted that a
lookup was populated. It could not tell a row that its evidence did not match its story —
nothing stopped a state-derived row from carrying a Source it had never read a word from.
Now that is refused by name.

### What the ruling cost, honestly: it turned out to be three tables, not two

47 named Candidate and Claim. **Answer carried the same assumption in a third form** and I
could not correct the other two without it: its trigger required spans of every machine
establishment, so a state-derived answer was refused one layer past where the ruling had
looked. Spans are how a *transcript* answer is cited; a state answer is cited by the rows
its claim named and froze, and demanding a quote of it demands a quotation from an artifact
that does not exist. **`AAO_Answer__c.AAO_Basis__c` added, recorded for ratification.**

It carries something the other two do not: **the union of the claims that built it.** An
answer established from a call and later reinforced by a state read reads `Both`, which is
what `Both` has always meant and what nothing until now produced.

**Rows written before the field existed are read as Transcript, not backfilled.** Until 47
nothing else could be written at all, so the assumption is safe — but the stored value stays
null and only the check assumes. Nothing invents history.

### Where each half of the law lives, and why it had to be split

The "at least one cited row" half **cannot** be a before-insert trigger: `AAO_Claim_Basis__c`
rows carry a lookup to the claim, so they do not exist until the claim has an Id, and a
trigger asking for them would refuse every correct write. So:

- **forward** — the writer calls `requireBasisRows` after inserting the junction, in the same
  transaction, so a throw takes the claim back with it.
- **reverse** — a new trigger on Claim Basis refuses a cited row hung off a claim that
  declared it rests on an artifact.

The reverse is the direction a trigger can hold absolutely, and it is the likelier accident:
**a claim carrying receipts it never declared is a claim whose receipts do not match its
story.** Anyone reading it would see cited rows under a Transcript basis and have no way to
tell whether the answer came from the artifact or from the records.

### A distinction the first version got wrong

I wrote "Transcript requires spans" for both tables and the rehearsal failed. It was right to
fail. **A candidate is a proposal and a proposal with no spans is an abstention** — the
reader looked at this proposition and found nothing said about it, and that row is the whole
record of having looked. A claim is different: it asserts something moved, and an assertion
from an artifact with nothing quoted is a claim nobody can go back and check. Spans are
required of establishments, not of proposals.

### 46c and 46f, delivered

The P route writes its candidate **with no Source**, commits it through the same door route E
uses, and the claim carries a Claim Basis row citing the map row with its value frozen.

The exit check runs **against a route-produced claim**, which is the whole reason it was left
unwritten last session. Dana's role is edited to `Evaluator` after the fact:

- **THEN** — the snapshot still reads `Decision Maker`. The claim says what the row said when
  it was cited.
- **NOW** — the lookup traverses to `Evaluator`, one hop away, in the same subquery.

That gap is why the frozen half exists. Without it, editing a map row would silently rewrite
the evidence under every claim that ever rested on it, and the claim would go on asserting
something no record had ever said.

### A consequence of 47 I am surfacing rather than absorbing

**The speaker gate is about utterances, and a record has no utterer.** With no spans, the
loop never runs and `speakerOk` stays false, which would downgrade every state claim to
UNVERIFIED forever — not the gate deciding, the gate being asked a question that does not
apply. So for basis State the requirement is **recorded as not applicable**, in the same
field the transcript path writes its reason to:

> Speaker requirement Any_Participant does not apply: basis is State. Nobody said this; the
> record says it, and the record is named in the claim's cited rows.

Not skipped. Nobody reading a state claim later can mistake it for one that cleared a check
it never faced. **Whether a state route should be subject to a speaker requirement at all is
a rule-data question, not a code one** — put alongside the setup-time inference pass that
already owes speaker requirement and route.

**`merge` is a reserved word** — the DML statement. Renamed `combine`. Fourth in the family
after `system`, `commit` and `json`.

**Owed.** Unchanged, less the Source ruling. Plus: whether `Any_Participant` should even be
authored on a P-routed proposition.

---

## 2026-07-31 · session 20 · ruling 48 recorded

**Did.** Recorded 48 where the code was asking for it, and extended the collision list.

**`AAO_Answer__c.AAO_Basis__c` ratified as built, union semantics included.** The field
description no longer says "recorded for ratification"; it says ratified, and dates it. The
union half is the part that needed the word: an answer's family is not the last claim's, it
is every claim's, so a proposition established from a call and later reinforced by a state
read reads `Both`.

**The speaker gate's "not applicable" is now law for basis State**, not a consequence I was
watching. The distinction that got ratified is the one worth keeping: **not applicable is
RECORDED, not skipped.** A state claim carries the sentence saying the requirement did not
apply and why, in the same field the transcript path writes its reason to, so it can never
be misread as a claim that cleared a check it never faced.

### The collision list, and a correction to my own count

Extended in `docs/aao-field-tables-v0_10.md` from two to **five**, which is what the build
has actually hit. I called `merge` "fourth in the family" last session and that was one
short: `any` belongs on the list too. It failed the first deploy of the pipeline view
controller and is recorded at session 8 in this journal, but never reached the doc.

The list now separates them by **how they fail**, because the two kinds want different
habits:

- **Refused loudly, identifier named** — `commit`, `any`, `merge`.
- **Resolved silently, error surfacing elsewhere** — `json` shadows the `JSON` class,
  `system` shadows `System`. Both compile clean, because Apex is case-insensitive, and
  surface later as a missing method on `String`.

The second pair is the one worth teaching, precisely because the compiler will not teach it.

**A hazard in doing this at all, flagged.** `docs/` is read-reference and every context sync
replaces it wholesale — the last two syncs did exactly that. **This edit will be lost at the
next sync unless it is carried into the upstream document.** I made it because 48 said to,
and I am naming the cost rather than letting it disappear quietly.

**Owed.** Unchanged. Nothing further from session 19.

---

## 2026-07-31 · session 21 · context 8, and the sync hazard proving itself

**Did.** Synced `docs/` to context 8 and carried 47/48 back into the field tables. Nothing
built; nothing deployed. **Charter design v0.3 is design only, per the instruction — the
Inferred attribution section is proposed and awaiting ratification, and I built none of it.**

### The hazard I flagged last session happened on the very next sync

The incoming `aao-field-tables-v0_10.md` is byte-identical to context 7's. It does not carry
the collision list, and it does not carry 47 or 48 — the version number did not move, so a
wholesale replace silently reverted them. **The only genuine upstream change in the whole
folder is charter design v0.2 → v0.3.** I re-applied the corrections on top rather than
letting the sync eat them.

**This will keep happening.** The field tables are the object record and they drift behind
the org every time a ruling lands, because rulings arrive here and the doc is authored
elsewhere. Two edits now live only in the repo's copy.

### Carried back in, and worth naming because the tables are the object record

- **`AAO_Source__c` is no longer Required on Candidate or Claim.** The tables still said
  Required, which is now wrong in the direction that matters: someone reading them would
  conclude a state-derived row is impossible, which is exactly the belief 47 overturned.
- **`AAO_Candidate__c.AAO_Basis__c`** added, with why it is nullable at field level (pre-47
  rows must stay updatable; the trigger enforces it on insert and can say why).
- **`AAO_Answer__c.AAO_Basis__c`** added as ratified, union semantics stated in the row
  itself, and the read-as-Transcript rule for pre-48 rows.
- **The collision list**, five entries, split by how each fails.

**Owed, new.** These four corrections need to reach the authored field tables upstream, or
the next sync reverts them again and the repo's copy diverges further. That is a question
about where the tables are authored, not something I can fix from here.

**Read, not acted on.** Charter design v0.3 proposes a fourth diarization class, `Inferred`,
sitting between Attributed and Unsegmented, with attribution carrying its own cue as a
citation and degradation handled by the existing speaker requirement. It also states that
the speaker gate should record which attribution source it relied on — **which session 18
already built** for the map-versus-roster case, and 48 extended to `not applicable` for basis
State. The third source, `inferred + cue`, would slot into the same sentence. Recorded
because it is the one place the proposal touches shipped code; still building nothing.

---

## 2026-07-31 · session 22 · context 9, and the sync drift given a handle

**Did.** Synced `docs/` to context 9. **Nothing built, nothing deployed** — charter design
v0.4 is design only, per the instruction.

**Third sync running, same shape:** the only genuine upstream change is charter design
v0.3 → v0.4. `aao-field-tables-v0_10.md` arrived byte-identical again, so a wholesale
replace reverted 47, 48 and the collision list for the third time.

### So I stopped re-applying them by hand

`scripts/carry_forward_docs.py`. It re-applies the five corrections after a sync, and the
part that matters is what it does when it cannot: **each edit asserts its target and exits
loudly if the upstream text has moved.** A real upstream fix breaks the script rather than
silently double-applying, or worse, papering over a change somebody made on purpose. Re-run
after every sync; it is idempotent and reports which corrections were already carried.

**It is a patch over a divergence and it says so in its own header, including when to delete
it:** the moment the authored tables carry these. The journal is the record. This only keeps
`docs/` from contradicting it.

Verified by re-running it twice and against the previous commit: the carried tables come out
byte-identical to what I had hand-edited, so nothing was lost or drifted in the automation.

### Inferred attribution, ruled — read, not built

The People charter is closed except its output schema. Inferred attribution is **ruled with
a condition that is a gate rather than a sentiment**, and the gate is the interesting part:

> a **strip-and-restore harness** — take Attributed transcripts, strip the speaker labels,
> run the attributor on naked text, compare against the stripped truth.

**Ground truth by construction.** Every attributed transcript any org already holds becomes a
free test case, forever, with no labelling pass and no judgment call about what the right
answer was. That is the same move the byte check makes on spans and the state check makes on
map rows: find the thing that is already true and check against it, rather than asking
something to score itself.

Three metrics, and the one that carries the weight is **anchored-identity precision** —
when it says *Dana said this, cue attached*, how often is that right. That is the number
dispositional claims would stand on. **Thresholds are measured, never guessed; no document
carries one until the harness produces it.** Until the bar is met, Inferred sources run at
`Any_Participant` power only.

**Where it touches shipped code, when it lands.** The speaker gate already names its source —
session 18 built the map-versus-roster case, 48 added *not applicable* for basis State. A
third value, `inferred + cue`, goes in the same sentence. Recorded, not built.

**Owed.** Unchanged, plus the upstream field-tables question from session 21, now with a
script holding the line until it is answered.

---

## 2026-07-31 · session 23 · context 10, and an audit of doc against org

**Did.** Synced `docs/` to context 10. **Nothing built, nothing deployed.** Field tables
v0.10 → v0.11, which is the version bump I have been waiting three syncs for.

**The script broke, which is what it was for.** v0.11 renamed the file, so every target went
missing and `carry_forward_docs.py` exited loudly instead of silently doing nothing. That was
the whole design: a real upstream fix should break it, not be papered over.

**v0.11 retired most of it** and says so — the evidence-family law, the abstention enum,
`Not_Returned`, the blind-reader fields, the delete law, `AAO_Cited_Map_Row__c`, and the
speaker gate's *not applicable*. All correct against the org. Both `AAO_Source__c` rows now
read nullable with the family law spelled out.

### Four things v0.11 still has wrong, retargeted the script at them

1. **`AAO_Answer__c.AAO_Basis__c` has no row in section 4.** The change note says it was
   consolidated; the table has no entry for it. A shipped, ratified field with no line in the
   object record.
2. **Candidate's `AAO_Basis__c` is listed "Restricted, required".** It is not required at
   field level, deliberately: a required picklist would make every pre-47 candidate
   un-updatable. Enforcement is on insert in the trigger, which also lets the refusal explain
   itself. **This one would cause damage if believed** — someone adding the flag to match the
   doc breaks updates on existing rows.
3. **The reserved-word section still says "Two"** while v0.11's own change note says four.
   The document contradicts itself in two places.
4. **It is five, not four.** `any` has never reached this document. It took down the first
   deploy of the pipeline view controller and is at session 8 in this journal.

### Then I audited every field in the org against the tables

Three genuine omissions, and I did **not** add these — they are absences rather than
contradictions, and the tables are authored elsewhere. Reporting rather than authoring:

- **`AAO_Model_Config__mdt` appears in no document at all.** Thirteen fields. It pins the
  model name and both charter versions, and items 20–21 ruled precisely that these must live
  in one record and never be hardcoded. **The one place the whole build's model binding is
  recorded is undocumented.**
- **`AAO_Claim_Basis__c.AAO_Cited_Answer__c`** is in no document, on a table the docs call
  CLOSED.
- **`AAO_Claim__c.AAO_Subject_Contact__c`** is in no document.

Two apparent gaps that are not: `AAO_Synthetic__c` is covered once as a standing convention
in the v0.10 note ("a permanent field on every AAO object"), which is the right way to say it
once rather than eight times. `AAO_Flag__c` lives in the flags doc rather than the tables.

**Owed, new.** The four corrections and the three omissions both need to reach the authored
tables. The script holds the first four; nothing holds the last three but this entry.

---

## 2026-07-31 · session 24 · context 11, the audit closed, and the Model Config describe

**Did.** Synced `docs/` to context 11. **Nothing built, nothing deployed** — charter design
v0.5 read only.

### The carry-forward script is deleted, its job done

v0.12 carries **all four** corrections from session 23's audit, verified against the org
field by field:

- `AAO_Answer__c.AAO_Basis__c` has its row, union semantics stated.
- `AAO_Candidate__c.AAO_Basis__c` corrected to nullable — and the doc now gives the reason
  I gave, that required-at-the-field is the same mistake the family law replaced on
  `AAO_Source__c`.
- `AAO_Claim__c.AAO_Basis__c` stays required, correctly: the org has it required.
- The collision list reads five, with `any` present.

**So the script goes.** Its header named the condition for deleting it and the condition is
met; keeping it would be keeping a patch over a divergence that no longer exists, and a
second place where truth lives. It never once silently double-applied, and it broke loudly
on the v0.10 → v0.11 rename exactly as designed.

**One correction of mine that landed differently and better.** v0.12 also expanded
typed-lookup shorthand to full API names, on the reasoning that a shorthand like
`_Answer__c` is how a builder ships `Answer__c` without the prefix. I had read
`AAO_Cited_Answer__c` and `AAO_Claim__c.AAO_Subject_Contact__c` as *absent*; they were
present as shorthand and I misread the shorthand as an omission. Both are documented now,
and the naming hazard is a better catch than the one I reported.

### Owed and now paid: the verbatim describe of `AAO_Model_Config__mdt`

v0.12 adds the section as a **STUB** and asks for this. Read from `aossb2` on ~~2 August
2026~~ **31 July 2026** (date corrected in session 52 against commit `2c07de2`; the describe
itself is untouched), verbatim from `sf sobject describe`:

| API name | Type | Length | Required | Default | Writer | Reader |
|---|---|---|---|---|---|---|
| `DeveloperName` | string | 40 | yes | | The one record, `Default` | `AAO_Extract.config()` |
| `MasterLabel` | string | 40 | yes | | | |
| `AAO_Active__c` | boolean | | no | `False` | Human | The config reader, to disable a generation without deleting it |
| `AAO_Model_Name__c` | string | 80 | yes | | Human | `AAO_Extract.send()` — **the pin.** Never hardcoded, per items 20–21 |
| `AAO_Charter__c` | string | 80 | yes | | Human | Stamped on every Candidate and Claim as attribution |
| `AAO_Charter_Version__c` | string | 20 | yes | | Human | Same. Bumping it is how a charter change becomes visible on receipts |
| `AAO_Blind_Charter__c` | string | 80 | yes | | Human | The second reader's name. Distinct field because coverage is adjudicated by a different charter than the one that proposed |
| `AAO_Blind_Charter_Version__c` | string | 20 | yes | | Human | Same, versioned independently |
| `AAO_Blind_Enabled__c` | boolean | | no | `False` | Human | Whether the blind reader runs at all |
| `AAO_Effort__c` | string | 20 | yes | | Human | Passed to the API |
| `AAO_Max_Output_Tokens__c` | double | 9,0 | yes | | Human | Passed to the API |
| `AAO_Named_Credential__c` | string | 80 | yes | | Human | Which credential; the key itself is never here |
| `AAO_Endpoint_Path__c` | string | 120 | yes | | Human | Appended to the named credential |
| `AAO_Timeout_Ms__c` | double | 9,0 | yes | | Human | Callout timeout |
| `AAO_Anthropic_Beta__c` | string | 255 | no | | Human | Beta header, null today |

**The live record**, `Default`, read the same day:

```
AAO_Active__c                True          AAO_Effort__c                'high'
AAO_Model_Name__c            'claude-opus-5'
AAO_Charter__c               'AAO_Extract_Evidence'   AAO_Charter_Version__c        '1.1.0'
AAO_Blind_Charter__c         'AAO_Blind_Reader'       AAO_Blind_Charter_Version__c  '1.0.0'
AAO_Blind_Enabled__c         True          AAO_Max_Output_Tokens__c     16000
AAO_Named_Credential__c      'AAO_Anthropic'          AAO_Endpoint_Path__c '/v1/messages'
AAO_Timeout_Ms__c            120000        AAO_Anthropic_Beta__c        null
```

**Two observations worth carrying into v0.13.**

**Nothing on this type is written by machine.** Every row above says Human, and that is the
point of the object: it is the one place a person decides which model and which charter
version the whole build runs under, and no code may reach past it. It is configuration
pretending to be nothing else.

**Nine of thirteen are `required`, and `AAO_Active__c` defaults to `False`.** So a second
generation authored by hand is inert until someone deliberately turns it on, which is the
right direction for an accident to fail in — the same shape as `AAO_Rubric.contracts()`
defaulting to the product set.

**Owed.** `AAO_Flag__c` still has no section in the field tables; it lives in the flags doc,
which is defensible, but the tables never say so. `AAO_Synthetic__c` is covered once as a
standing convention rather than per object, which I still read as correct.

---

## 2026-07-31 · session 25 · context 12, corrections v2.0, and the annotation law

**Did.** Synced `docs/` to context 12. **139 tests, 139 passing**, re-run to confirm the org
still stands behind what corrections v2.0 claims on its behalf.

### The annotation law, recorded — there is nothing yet to build it into

Charter design v0.5 changed in place, without a version bump, and the change is a
ratification: **the machine annotates only machine-authored insight cards** (2× prepend,
reiteration date append). Reinforcement of a **human-authored** card writes a Claim with
outcome `Reinforced` and surfaces **beside** the card, never inside its text.

The instruction says build against this. **There is nothing to build against yet.**
`Insight_Card` exists in this repo only as a value on `AAO_Subject_Type__c` and
`AAO_Cited_Type__c`; no writer touches an insight card, and the Problems charter is open. So
this is recorded, not implemented, and I am saying so rather than manufacturing a surface to
hang it on.

**Why the law is the right one, so it survives to whoever writes that code.** Prepending "2×"
onto a card a human wrote is a machine edit to a human's words. That is the same violation
the pipeline already refuses in a different place: `AAO_Commit` returns
`Superseded_By_Human` rather than overwriting an answer a person established. **The
annotation rule is human precedence applied to text instead of to verdicts**, and the
`Reinforced` outcome it uses is the one already written when new evidence confirms something
standing without moving it. Nothing new is needed to obey it; the existing outcome already
means exactly this.

Tension (a) stays open. Nothing builds against projection of confirmations.

### Corrections v2.0, read against the build

Accurate where I can check it: the evidence-family law is stated correctly including the
reason for enforcing in triggers rather than by required flags, the five collisions are
right, no-rubric-binding is right, and the replay and downgrade claims match the suite.

**Three things it does not carry, one of which was explicitly directed into it.**

1. **The rubric-scoped-reader law is absent.** Item 41 said, verbatim, that the fix is
   *"promoted from bug fix to law, recorded for corrections v2.0: a deal is red against the
   rubric it is adjudicated under, and every reader of contracts is rubric-scoped."* v2.0
   records that no binding field exists — the *negative* — but not the rule that replaced it.
   **A reader of v2.0 alone would not know how the applicable set is decided**, only that it
   is not decided by a field on the deal.
2. **The synthetic marker as the product/test discriminator is absent** — the session-17
   revision, which is the answer to the question item 1 leaves open. `AAO_Rubric.contracts()`
   returns active, non-superseded, **unmarked** contracts; test and demo entries opt into the
   synthetic set by name. This is the mechanism behind "a deal always answers the org's
   current active questions."
3. **The speaker gate's *not applicable* for basis State is absent.** Ruled 48. It matters
   in a record aimed at corporate because it is the one place the family law changes what a
   *gate* does, not merely what a row looks like.

Two smaller notes: v2.0 says "over one hundred tests green" — true, and the number is **139**.
And `AAO_Flag__c` still has no section in the field tables; it lives in the flags doc, which
is defensible, but the tables never say so.

**Not authored by me.** These are absences in a document authored elsewhere and aimed at
corporate, so they are reported rather than written. Item 41's is the one I would act on
first: it was an explicit instruction to record, and it is the only one that leaves a reader
with a question the document raises and does not answer.

**Owed.** The `AAO_Model_Config__mdt` describe was paid in session 24 above, all thirteen
fields with writer and reader named plus the live `Default` record; re-surfaced this session
in the reply for pasting into v0.13.

---

## 2026-07-31 · session 26 · context 13, the swap, and both audits closing

**Did.** Synced `docs/` to context 13, which supersedes both earlier drops tonight. Nothing
built, nothing deployed. **The two superseded files are gone rather than orphaned:**
`aao-field-tables-v0_12.md` and `aao-corrections-v2_0.md` no longer exist in `docs/`, so
there is no stale copy of either sitting beside its replacement waiting to be read by
mistake.

### Field tables v0.13 — verified against the org, not taken on trust

**Section 7 is real.** All **thirteen** `AAO_Model_Config__mdt` fields are enumerated; I
checked the doc against the field directory rather than against my own session-24 entry, so
the check is doc-versus-org rather than doc-versus-me. Nothing missing.

**Both observations came back as stated design**, which is the outcome I wanted rather than
being quoted as opinion: the all-human writer column is the object's identity — *no code may
reach past it* — and `AAO_Active__c` defaulting to `False` is recorded as failing in the safe
direction.

**Section 8 closes the Flag gap the honest way**: a pointer saying the object is specified in
the flags doc. **I checked the pointer resolves** — the flags doc carries 19 of 20 fields,
the twentieth being `AAO_Synthetic__c`, which the tables cover once as a standing convention
across every AAO object. A pointer to a document that did not actually specify the thing
would have been worse than the silence it replaced, so it was worth checking.

**Nothing further owed on the field tables.** The full field audit is clean for the first
time: every field on every AAO object either appears in its own section or is covered by the
synthetic convention.

### Corrections v2.1 — the three omissions landed, correctly

All three, and each is stated in the form that makes it usable rather than merely present:

- **The rubric-scoped-reader law**, with the diagnosis I gave — v2.0 recorded how the
  applicable set is *not* decided without the rule that decides it.
- **The synthetic marker as the product-versus-test discriminator**, including `unmarked`.
- **The speaker gate's not-applicable**, with the reasoning intact: *a record has no utterer,
  so a speaker requirement asked of a state claim is a question that does not apply, and left
  alone the gate would downgrade every state claim forever.* That last clause is the part
  that matters, and it survived.

Test count reads **139**, matching the suite as re-run last session.

**Nothing owed on either document.** The remaining owed list is build work — escalation with
projection, the setup-time inference pass for speaker requirement and route, the Contention
and Ratification flags having no raise path, and the session-4 remainder — plus the two
charter items recorded and not built: the insight-card annotation law, which has no writer
to attach to yet, and Inferred attribution, gated on its strip-and-restore harness.

---

## 2026-07-31 · session 27 · context 14, and one number checked

**Did.** Synced `docs/` to context 14. One addition, `aao-seed-v3_0.md`; the other seventeen
byte-identical. Nothing built, nothing deployed, no build action taken.

### Verified from the org, because the seed says receipts not claims

The seed is an orientation document whose whole argument is *receipts, not roadmap*, so the
numbers in it are the ones most likely to be repeated in a room. Checked what is mine to
check:

| Claim in seed v3.0 | Read from the org | |
|---|---|---|
| `139 AAO tests green` | 139, 100 % | correct |
| org `00DWD00000DV7iT2AT`, `IsSandbox true` | same id, `IsSandbox = True`, name `Altify` | correct |
| Model Config all human-written, `Active` defaults False | matches the describe in session 24 | correct |
| **`Eight objects live with trigger laws, plus AAO_Model_Config__mdt`** | **seven** objects, seven triggers, one per object; `AAO_Model_Config` is the eighth row | **off by one** |

**`SELECT DeveloperName FROM CustomObject WHERE DeveloperName LIKE 'AAO%'` returns eight, and
`AAO_Model_Config` is one of the eight** — a custom metadata type is a CustomObject row in
the tooling API. So the sentence as written reads eight *plus* one and lands on nine. The
true shape:

> **Seven objects live with trigger laws** — Answer, Candidate, Claim, Claim Basis, Evidence
> Contract, Flag, Source, each with its own before-trigger — **plus `AAO_Model_Config__mdt`,
> which has no trigger because nothing machine-written ever touches it.** Eight rows in the
> org, seven of them data.

That last clause is why the miscount is worth correcting rather than rounding past: Model
Config genuinely does not belong in a count of objects-with-trigger-laws, and the reason it
does not is the same reason it exists.

**Consistent elsewhere, so this is one sentence and not a systemic error.** Field tables
v0.13 says six CLOSED plus a Flag pointer section plus a Model Config section, which is eight
sections and correct. Corrections v2.1's "fifteen entities" is the design object model rather
than deployed objects, a different count of a different thing.

**Not corrected by me.** The seed is authored elsewhere and is context only, per the
instruction. Reported here so it can be fixed before the QBR, where a builder in the room may
well ask how many objects.

Nothing owed changes. The build-owed list the seed carries back matches mine exactly:
escalation with projection, the setup-time inference pass, Contention and Ratification raise
paths, the session-4 remainder, the insight-card annotation writer once Problems closes, and
the Inferred attribution harness.

---

## 2026-08-01 · session 28 · the two output schemas, read out of the org

**Did.** No build action. Dumped the deployed output schemas for `AAO_Extract_Evidence`
1.1.0 and `AAO_Blind_Reader` 1.0.0 and pasted them back to design for charter design v0.6.

**Read from the org, not transcribed from source.** Ran anonymous Apex against `aossb2`
calling `AAO_ExtractCharter.schema(contracts, roster)` and `AAO_BlindCharter.schema(reviews)`
against the six live mini-rubric contracts, and serialized what came back. The distinction
matters here more than usual: **these schemas are not literals in the charter classes.** The
enums are closed at runtime from org data — `proposition_code` from the contract codes,
`element` from each contract's element list, `speaker` from the artifact's roster keys — so
a schema transcribed from source would have shown the shape and none of the values, and
design would have built an envelope against a template rather than against what the model
is actually handed.

### The finding that matters for a shared envelope

**The model's three-way status and the stored three-way abstention reason are different
triples, and the mapping is not identity.**

| Model emits `status` | Stored `AAO_Abstention_Reason__c` | Stored `AAO_Outcome__c` |
|---|---|---|
| `addressed` | — | as adjudicated |
| `not_addressed` | `nobody_said` | `Abstained` |
| `abstained` | `model_declined` | `Abstained` |
| *(nothing emitted for that code)* | `not_returned` | `Not_Returned` |

**The model cannot emit `not_returned`**, by construction: it is the record of a proposition
the reader never reported, so the only thing that can observe it is the pipeline noticing a
contract with no finding against it. Any shared envelope has to keep this shape — a charter
declares *addressed / not_addressed / abstained* and the fourth fact is derived by whatever
compares the emission against the rubric it was given.

That is also why the enum is four values on the picklist and three in the schema, with
`model_missed` retired-valid on top.

**Owed.** Unchanged.

---

## 2026-08-01 · session 29 · charter design v0.6 read against the deployed parser

**Did.** Synced the three-file drop (charter design v0.6, rebuttals v0.2, seed v3.1) and
deleted the three superseded copies. **No build action, on instruction.** Read v0.6 against
`AAO_ExtractCharter.parse` 1.1.0 and the schema as deployed. **Five things will not build as
written**, all in the generalization rather than the rulings.

**The claim that fails.** v0.6 says the extraction charter *"predates the generic `ref`/`body`
naming; its `proposition_code` is the `ref` and its body fields sit inline — the writer's
parser treats them identically."* The parser does not. It reads `f.get('proposition_code')`
literally and returns `Map<String, Finding>` keyed on it.

1. **`ref` fails silently, and fails as the worst possible signal.** An unknown key yields
   `code = null`, `knownCodes.contains(null)` is false, `continue`. **No exception, empty map,
   and the pipeline then writes `not_returned` for every handed unit.** `not_returned` is
   defined as a charter-quality signal — so a *parser* mismatch would present as the reader
   having answered nothing, which is exactly the fact that metric exists to detect. Rename
   with a fallback that reads either key and **throw** on a findings array that parses to
   zero recognised refs.

2. **A map keyed by `ref` cannot hold discovery findings.** `byCode.put(code, fin)`. Every
   discovery finding carries `ref: "NEW"`, so **N new people collapse to one** — last write
   wins, silently. Today they never arrive at all, because `knownCodes.contains('NEW')` is
   false and they are dropped. The return type has to become handed-map plus discovered-list,
   and both callers change with it.

3. **A closed enum cannot contain values the model invents in the same emission.** `element`
   is closed at runtime from the contracts' element ids. v0.6 has People spans tag
   `emission_id` (`m1`, `m2`…) — invented by the model *during* the emission, so unlistable
   before the call. Either the field goes open for those charters, losing the closure
   extraction depends on, or emission slots are pre-handed.

4. **And the same field is load-bearing arithmetic.** `AAO_Accumulate.verdictFor` returns the
   proposal only when `coverage.isFull(contractElements)`, comparing span `element` values
   against the contract's element ids. Fill that field with emission ids and coverage never
   matches: **every People finding lands UNVERIFIED at best and Abstained at worst**, by
   arithmetic rather than by judgment. Coverage needs its own field, or per-charter coverage.

5. **`NONE` has nowhere to be stored.** `AAO_Candidate__c.AAO_Proposed_Verdict__c` is
   restricted to `TRUE`/`FALSE`/`UNVERIFIED`. v0.6 has People and Problems emit `addressed`
   with `proposed_verdict: NONE` and the proposal in the body. That candidate is refused at
   insert with `INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST`. Today it never happens because only
   `addressed` findings build candidates and those always carry a real verdict. `UP_ONE` and
   `DOWN_ONE` have no home either.

**What is sound.** The status-mapping law is stated exactly right, including that the model
cannot emit `not_returned` by construction. The handed-versus-discovered split is the right
cut. And v0.6 names its own riskiest assumption — that ledger completeness has no comparator
on the discovery half — which is the honest version and matches how the byte check and the
state check both work: find the thing already true and check against it.

**Owed.** Unchanged. Build starts on Matthew's word.

---

## 2026-08-01 · session 30 · v0.7 did not arrive; the element-count question answered

**Did not sync.** `aao-charter-design-v0_7.md` is **not on disk**.
`~/Downloads/aao-context_14/` still holds `aao-charter-design-v0_6.md`, unmodified since
09:25, and `~/Downloads/aao-context/` is a stale 30 July folder holding field tables v0.8.
A search of `~/Downloads` finds no v0.7 at any depth. **Nothing copied, nothing deleted,
nothing committed against a file I cannot read.** The rulings in the message are recorded
here; the packet they belong to is not in the repo, so no build starts against a summary of
a document.

### Reportable 1, answered — and it does not need v0.7

**Single-element contracts carry `AAO_Element_Count__c` of one. Zero does not appear.**
Read from `aossb2`, all twelve live contracts across both populations:

| code | population | `AAO_Element_Count__c` | actual list length | elements basis |
|---|---|---|---|---|
| AAO_T1 | product | 3 | 3 | Authored |
| **AAO_T2** | product | **1** | 1 | Authored |
| AAO_T3 | product | 2 | 2 | Authored |
| AAO_T4 | product | 2 | 2 | Authored |
| **AAO_T5** | product | **1** | 1 | Inferred_Pending |
| AAO_T6 | product | 2 | 2 | Authored |
| **AAO_T2** | synthetic | **1** | 1 | Authored |
| *(T1, T3–T6 synthetic)* | | 3, 2, 2, 2, 2 | matching | |

**Count matches list length on every row, and no row is zero or null.**

**Zero is unreachable by construction, not by luck.** `AAO_Discovery.parseElements` states it
in its own header — *"The number of parts is never unknown, so an unauthored proposition
still gets one element, and it is the proposition itself"* — and returns `Inferred_Pending`
with a single element rather than an empty list when Help carries no `Elements:` block. The
discovery test `helpWithNoElementsBlockIsInferredPendingNotAuthored` holds that.

**And if a zero ever did appear it fails safe**, which is the reason the question is worth
asking. `AAO_Model.Coverage.isFull` returns **false** on an empty element list, with the
reason recorded at the branch: *returning true would establish propositions out of an empty
list.* So a zero-element contract can never establish anything; it can only fail to.

One difference worth naming since it shows in the table: **product `AAO_T5` has one element,
synthetic `AAO_T5` has two.** That is not drift. The seeded fixture authored two; discovery
read the same question from Altify's Help, found no authored `Elements:` block, and honestly
derived one element with basis `Inferred_Pending`. The two populations disagree because one
was typed and the other was read, which is exactly what the marker exists to keep apart.

### Reportable 2, blocked

**The output token count on the first live People pass cannot be measured yet.** There is no
People charter deployed and no People pass to run. It arrives with the build, and
`AAO_Extract.Usage` already logs input and output per call, so the number falls out of the
first run rather than needing separate instrumentation. Against the 16,000 ceiling on
`AAO_Model_Config__mdt.AAO_Max_Output_Tokens__c`, and worth watching precisely because the
People handed unit is now person crossed with dimension: the handed set multiplies where
extraction's did not.

**Owed.** Both reportables, one answered above and one pending the build. Re-drop v0.7.

---

## 2026-08-01 · session 31 · charter design v0.8 synced, the counter checked against the org

**Did.** Unzipped `aao-context_16.zip`, one file. `aao-charter-design-v0_8.md` in, **v0.6
deleted** — v0.7 never reached disk, so v0.6 was still the live copy here. **No build action
taken.** v0.8 folds v0.7's rulings in as its own changelog, so the packet is whole despite
the missing hop, and the accumulator-with-reset it withdraws was never built.

### The counter reads as buildable, and it is smaller than what it replaces

A clamped integer in −3…+3, moved by at most one per source-event, with rungs at fixed
positions and the rung read as the highest named position at or below the number. **Nothing
in it needs a mechanism I do not already have.** The properties the earlier versions wanted
laws for fall out of the arithmetic: the clamp is what stops banking, mentor costs two up and
one down because the rungs sit unevenly, and replay stays deterministic because a clamped sum
is order-dependent only at the boundaries.

**Verified the one claim it makes about my code.** v0.8 says *"The scope key is already scope
plus artifact hash plus part index, so the occasion is scope plus artifact hash."* True as
deployed. `AAO_ScopeKey` composes `S1|<Opportunity Id>|<Artifact SHA-256>|<Part Index>`, so
the source-event is that key with its last segment dropped. The 90-minute part split really
does collapse to one increment by construction rather than by a rule someone has to remember.

**Two build notes, neither a blocker.**

**The source-event key must be its own frozen composer, not a truncation at call sites.**
Every identity in this build is composed once by a frozen, versioned, single-writer class —
`AAO_AnswerKey`, `AAO_ScopeKey`, `AAO_ContractKey` — precisely so nobody re-derives it
slightly differently somewhere else. A `substringBeforeLast('|')` sprinkled through the
People writer would be the first identity in the system without an owner.

**And it must carry its own version letter, not inherit `S1`.** If the source-event key is
built by truncating the scope key, a future scope-key version bump silently changes what
counts as one occasion, and **every sentiment counter in every org re-derives to a different
number on the next replay.** The counter is a sum over occasions, so occasion identity is
load-bearing in a way the scope key's own version was never asked to be. Its own prefix,
bumped on its own schedule.

**Human override absolute, and it already has its shape.** Contradicting evidence writes its
claim and raises a flag while the value does not move — that is `Superseded_By_Human` applied
to a map dimension instead of an answer, the same law `AAO_Commit` already enforces. The
watermark is the part that is new: a human write must stop the machine writing that field
*forever*, which is stronger than precedence-on-collision and needs somewhere to live.

**Backdated evidence** re-derives in occurred order with no age cap, guarded only against
dates preceding the opportunity's `CreatedDate` — consistent with replay, which already
rebuilds in evidence-occurred order, and with day-one red, which already takes
`CreatedDate` as the floor for a deal's clock.

**Owed.** Unchanged, plus the two reportables: the element-count answer is delivered
(single-element contracts carry one, zero is unreachable and would fail safe), and the live
People output token count against the 16,000 ceiling arrives with the first pass.

---

## 2026-08-01 · session 32 · charter design v0.9 synced; three schema gaps in the People routes

**Did.** `aao-charter-design-v0_9.md` in, **v0.8 deleted**. **No build action.** Read the new
People-contracts section against the org. The ontology recovery is the strongest thing in the
file — the questions taken verbatim from Altify's own wizard rather than paraphrased from a
picklist label is the same discipline as reading propositions from the rubric table, and the
`ALTF__Status_Answer__c` hazard is well found: **the questions are the asset, the answers are
exhaust.** Three gaps, all in the routing rather than the ontology.

### 1. Coverage cannot be a frozen query, because participation is not queryable

All three Coverage questions are per-person counts over our own Sources: *have you met*,
*multiple recently*, *regularly*. **There is no Source-to-Contact relation in the schema.**
Participation lives only in `AAO_Source__c.AAO_Speaker_Roster__c`, a `LongTextArea` of 32,768
characters holding JSON, and **SOQL cannot filter into a text blob.**

So the recipe ruling does not reach this case as written. *A model writes the query once, the
query is frozen on the contract, Apex executes it* presumes the question is expressible as a
query, and *did this person participate* is not. Two ways out, both Matthew's:

- **A participant junction written at ingest** — a row per Source per person, which makes all
  three questions ordinary SOQL and also gives Coverage's window and frequency counts
  somewhere to be counted. It is our own object, so it breaks no constraint.
- **Coverage becomes Apex that deserializes rosters** for the deal's Sources. Deterministic,
  no model, still route P in spirit — but it is **not** a frozen query, so it should not be
  described as one, and it carries a governor ceiling the junction would not.

The junction is the one I would build. It is the same move key four already made: **a grain
not recorded cannot be declared later without reprocessing the corpus**, and participation is
exactly such a grain.

### 2. A Coverage claim has nothing it is allowed to cite

Route P writes basis `State`, and the evidence-family law **requires at least one Claim Basis
row** — `AAO_EvidenceFamily.requireBasisRows` throws otherwise, inside the transaction.
`AAO_Cited_Type__c` offers `Map_Row`, `Insight_Card`, `Decision_Criterion`, `Answer`,
`Qualifier_Status`, `Shadow_Person`. **No `Source`.** A Coverage claim citing the Sources it
counted is refused by our own law.

Needs a `Source` cited type plus an `AAO_Cited_Source__c` lookup. Worth noting the wider
state while we are here: **only two of the six declared cited types have lookup fields** —
`AAO_Cited_Answer__c` and `AAO_Cited_Map_Row__c`. The other four are enum values with nowhere
to point. Not urgent, but the table is smaller than it reads.

### 3. Support Q2 and Q4 need a speaker requirement that does not exist

v0.9 reads *"told you"* as fixing a speaker requirement: the person themselves, to the seller.
`AAO_Speaker_Requirement__c` offers `Seller`, `Any_Participant`, `Buyer_Side`,
`Decision_Maker_Or_Influencer`. **Every one of those is a CLASS of speaker. Q2 and Q4 need a
SUBJECT: this finding's own person said it.**

That is a genuinely new kind of requirement and it is cheap here and nowhere else — the
People handed unit is person crossed with dimension, so the gate already knows who the
finding is about. A new value, `Subject_Person`, and `AAO_SpeakerRule.evaluate` gains the
subject to compare against. **Without it, Q2 and Q4 would pass on a colleague vouching for
someone's preference**, which is the precise thing the wizard's wording excludes.

### On the open decision, one build-side fact rather than an opinion

Whether Support becomes five contracts with Altify's tree computing the rung is Matthew's.
The build-relevant fact is that **the tree and the counter answer different questions and
cannot both own the rung.** The tree derives a rung from five booleans held *now*: five
conditions landing in one call moves a person Neutral to Mentor in a single source-event,
which is exactly the teleport the ±1 law exists to forbid. The counter derives standing from
*movement over occasions*. One is a state read, the other is a history. If the tree owns the
rung, the ±1 law and the clamp stop meaning anything and should be withdrawn rather than left
sitting beside it; if the counter owns the rung, the five contracts are still worth having as
the evidence that justifies each move. **They compose only in that direction.**

### Still owed to design, and already answered here

**`AAO_Element_Count__c` carries one for single-element contracts. Zero does not appear.**
Answered from the org in session 30 and restated in the reply, since it came back on the owed
list — all twelve live contracts match their element-list length, zero is unreachable because
`AAO_Discovery.parseElements` returns the proposition itself as a single element when Help
carries no block, and a zero would fail safe anyway because `Coverage.isFull` returns false on
an empty list.

---

## 2026-08-01 · session 33 · ALTF custom labels and the insight-card type picklist

**Did.** Read-only Tooling API queries against **`aossb2`**. Nothing changed. No build action.

**Which org, and why.** `sf org list` offers `altify-dev`, `altify-pbo`, `aossb2`. There is
no `altify-prod` connection on this machine, and **`altify-pbo` is forbidden by standing
constraint**, so this is the sandbox. Anything below is true of `aossb2` and is **not** a
production finding.

**Guard applied before every filter**, per item 37: totals first, so a zero match is
distinguishable from an empty table. `ExternalString` holds **6,437** rows, **2,930** of them
`ALTF`. `ExternalStringLocalization` holds **25,965**.

### 1. Yes — the four definitions are custom labels, and they are richer than expected

They are not one help string each. Each concept carries a **definition, split account-level
and opportunity-level, plus numbered qualifying questions**, nearly all in category
`PeopleAndProblems`:

- `GOAL_DEF_OM` — *"A Goal is an end result which the Approver and Decision Maker need to
  achieve specific to the initiative, ideally with a measurable outcome and a specified time
  frame."* `GOAL_DEF_AM` is the account variant.
- `PRESSURE_DEF_OM` / `_AM`, `INITIATIVE_DEF_OM` / `_AM`, `OBSTACLE_DEF_OM` / `_AM`, all
  present and all similarly worded.
- **`GOAL_HELP_TEXT_1..3`, `PRESSURE_HELP_TEXT_1..2`, `INITIATIVE_HELP_TEXT_1..3`,
  `OBSTACLE_HELP_TEXT_1..3`**, each a qualifying question — *"Is this a goal of the decision
  maker specifically and not a company goal?"*, *"Is this a task, situation or process that
  will have negative consequences if it is not fixed?"*
- Account-plan variants exist as `*_HELP_TEXT_AM_*` and, notably, **sit in category `None`
  rather than `PeopleAndProblems`**, so a category filter would silently miss them. That is
  the `LIKE 'AAO\_%'` failure shape again and worth remembering if discovery ever reads these.

**Why this matters beyond the answer.** These are the same shape as the Support wizard
questions recovered in v0.9: **numbered, closed, authored by Altify, and phrased as
yes-or-no qualifiers.** They are Evidence Contract propositions in everything but storage —
which means the Problems charter has an authored ontology available to it exactly as People
does, rather than needing us to author one.

### 2. Yes — this org overrides ALTF labels, but not these

**Zero `ExternalStringLocalization` rows carry the `ALTF` namespace.** Every one of the
25,965 is `dfsle` (DocuSign) except **56 in the org's own namespace**, and resolving each
back to its parent shows **all 56 override `ALTF` labels**. So Translation Workbench override
of a managed label is live in this org and demonstrably works.

**55 of the 56 differ from the packaged value.** They are one rebranding, applied
consistently: **"Account Manager plan" → "Book of Business plan"** across the AM_* UI banners.

**None of them touches Goal, Pressure, Initiative or Obstacle.** The four definitions and
every numbered help question read exactly as packaged in this org.

**The lesson generalizes and is the thing to carry.** A customer *can* silently rewrite any
ALTF label, one already has, and the override lives in a different table from the label. **If
discovery ever derives propositions from label text, it must read the org's localization
layer and not the packaged value**, or it will author contracts from words no user of that
org has ever seen. That is the label-layer twin of the `ALTF__Status_Answer__c` hazard v0.9
recorded: the stored artifact and the displayed truth can disagree.

### 3. No — the insight-card type picklist has no label drift

`ALTF__Insight_Card__c.ALTF__Type__c`, restricted, five active values: **Goal, Pressure,
Initiative, Obstacle, Solution.** **Label equals API value on every one**, and none is
default. So the type may be read and written by API value directly with no translation step
in this org. **Note the scope of that claim:** it is a describe of `aossb2`, and a picklist
label is exactly the kind of thing Translation Workbench can move, so it is not a statement
about any customer org.

**Owed.** Unchanged.

---

## 2026-08-01 · session 34 · the three routing gaps built; v1.3 synced

**Did.** Built all three gaps ruled in v1.1. **146 tests, 146 passing** (was 139). Also
synced `aao-charter-design-v1_3.md`, deleting v1.1; **no build action on the v1.3 Problems
section**, which lands with the Politics charter.

### 1 · `AAO_Participant__c`, the participant junction

One row per Source per person, written in the Source's **after-insert, synchronously, and
not behind `AAO_Ingest.AUTO`**. Participation is a fact about the ARRIVAL of evidence rather
than a product of adjudicating it: a deal that never runs a pass still knows who was on its
calls, and coverage is answerable the moment the artifact lands.

**The subtlety worth the field, and it is inherited rather than invented.** A ninety-minute
call arrives as two or three Source rows of ONE artifact. Counting rows would report one
conversation as two and inflate every coverage answer that rests on a count. So each row
carries `AAO_Artifact_SHA256__c` and **coverage counts DISTINCT HASHES, not rows** — the same
source-event definition the sentiment counter uses, for the same reason. Held by a test:
three Source rows across two artifacts read as **two occasions**.

`AAO_Participant_Key__c` is unique, so re-ingesting cannot double-count anybody. That matters
more here than anywhere else, because a duplicate row here is a wrong answer there.

**What it cannot do, named rather than papered over.** It counts occasions, and questions two
and three say *meaningful* and *high quality*. `AAO_Substantive__c` is the only field that
speaks to substance, derived from the small-talk boundary the normalizer already finds, and
it is deliberately the weakest possible test — any substantive content at all. **Anything
stronger would be a threshold and no threshold is measured.** Missing boundary data counts as
substantive, so coverage understates rather than overstates.

**A real defect found while testing, and it was mine.** My first test wrote a roster in the
wrong JSON shape and the Source insert failed — which revealed that **a roster we cannot
parse would have rejected the evidence itself.** This runs in after-insert, so a throw rolls
back the artifact. Fixed: a parse failure records no participants and lets the artifact land.
Same ruling `AAO_Ingest` already makes about a failed enqueue — *a failure downstream of
arrival must never undo the arrival* — and the cost is one-directional, since coverage
under-counts rather than over-counts.

**The junction is not deletable outside a purge**, because deleting a row silently lowers an
answer claims already rest on. That surfaced immediately: `Restrict` on the Source lookup
broke three purge paths, so participants now clear first in `AAO_Demo.purge`,
`AAO_Gate1.purgeDeal` and `AAO_Live.reset`. Worth noting the constraint did exactly its job —
it refused to let evidence leave while something still pointed at it.

### 2 · `Source` as a cited type

`AAO_Cited_Type__c` gains `Source`, with an `AAO_Cited_Source__c` lookup. Without it a
Coverage claim was refused by our own evidence-family law: route P writes basis `State`,
`requireBasisRows` demands at least one cited row, and there was no value for a Source.

**What a Coverage claim cites is the point.** It cites the Sources it counted and never the
transcript text, because the answer rests on nothing anybody said. That is why this is a
cited row rather than a Source lookup on the claim itself, which would have made a state
claim look like a transcript claim to the family check.

### 3 · `Subject_Person`

Added to `AAO_Speaker_Requirement__c`; `evaluate` gains a fifth argument. Every other value
names a **class** of speaker; this names a **subject**. Held by a test: Dana saying it
herself passes, a colleague saying it about her fails with *"this proposition is about
someone else and asks what that person told you"*.

**With no subject supplied it REFUSES rather than passes** — a check that cannot run has not
been met. The argument is null on every other charter and the branch never fires.

**`when` is a reserved word**, from the `switch` statement. **Sixth in the family** after
`commit`, `json`, `system`, `merge`, `any`.

### v1.3, read not built

The four person-to-card questions collapsing to `Informer` / `Owner` is the same shape as the
`ALTF__Status_Answer__c` hazard and the label-override finding: **the customer's stored value
carries less than the question that produced it.** The ruling matches what the build already
does everywhere — derive from type when reading someone else's rows, record explicitly on our
own. That is the discovery pattern exactly: read what is there, never write what we inferred
as though it were given.

**Owed.** Unchanged, plus the substantive threshold, which is a measured number.

---

## 2026-08-01 · session 35 · v1.4 did not arrive; the Solutions join verified anyway

**Did not sync.** `aao-charter-design-v1_4.md` is **not on disk**. No file matching `v1_4`
anywhere under `~/Downloads` at any depth, and the newest `aao-context*.zip` is from 31 July.
`docs/` still holds v1.3. **Nothing copied, nothing deleted, nothing built.** Second time this
has happened; the v0.7 drop went the same way and the content reappeared folded into the next
version, so the rulings are recorded here and nothing is lost by waiting.

**No build action would have been correct regardless** — the message flags two things as
undecided (flag volume shape, and whether the cited-type enum keeps growing) and one as
explicitly Matthew's.

### The join is real, verified hop by hop against the org

`OpportunityLineItem` → `PricebookEntry` → `Product2.ALTF__Solution__c` →
`ALTF__Insight_Card__c.ALTF__Solution__c`:

| Object | Field | Type | Points at |
|---|---|---|---|
| `OpportunityLineItem` | `PricebookEntryId` | reference | `PricebookEntry` |
| `PricebookEntry` | `Product2Id` | reference | `Product2` |
| `Product2` | `ALTF__Solution__c` | reference | `ALTF__Solution__c` |
| `ALTF__Insight_Card__c` | `ALTF__Solution__c` | reference | `ALTF__Solution__c` |

**Both ends land on the same object, so the chain genuinely closes** rather than merely
looking like it does. It also traverses in one SOQL — `SELECT
PricebookEntry.Product2.ALTF__Solution__c FROM OpportunityLineItem` parses and runs. **Zero
rows in `aossb2`**, which is a fact about the sandbox and not about the join: nothing here
has line items. Worth a production read before anyone leans on the shape of the data.

**Why route P is right for it, and this is the strongest case yet.** A line item is a record,
there is no judgment in reading it, and the claim cites the row it read. That is exactly the
Coverage shape and exactly the map-row shape. **And no ratification is the correct call for
the same reason state verification exists:** re-reading the line item confirms or refuses it,
so there is nothing for a human to ratify that the byte-check twin does not already do.

**The edge is correctly ruled underivable.** A line item says what was quoted. It says nothing
about which pressure that solution answers, and inferring one would be inventing a causal
claim from a purchase order — the precise failure the whole build refuses.

### Two things this needs that do not exist yet

**A fifth flag type.** `AAO_Type__c` carries `Methodological`, `Contention_Negative`,
`Contention_Positive`, `Ratification`. The Identification flag was ratified as the fifth and
**has never been built either**, so a general missing-relation flag would be the sixth value
on a picklist currently holding four. Building it general rather than solution-specific is
right and matches how every other law here generalized — the Pressure-to-Goal hole and the
Politics edges want the same shape, and a flag that says *this thing has no edge to anything*
is one rule, not three.

**The cited-type question is worth answering now rather than per-request.**
`AAO_Cited_Type__c` holds **seven** values today — `Source`, `Map_Row`, `Insight_Card`,
`Decision_Criterion`, `Answer`, `Qualifier_Status`, `Shadow_Person` — and **only three have
lookup fields built**: `AAO_Cited_Answer__c`, `AAO_Cited_Map_Row__c`, `AAO_Cited_Source__c`.
`OpportunityLineItem` and `Product2` would make nine values and five lookups.

**The shape of the growth is what matters, not the count.** Every value is a distinct object
needing its own typed lookup, so the table grows one enum value plus one field per kind of
record we ever cite — and it is already four values ahead of its own implementation. The
alternative is a polymorphic reference, which Salesforce does not offer on custom lookups, so
the honest options are: keep growing the typed table, or store the cited row as an id string
plus its object name and lose referential integrity and the live half of then-and-now. **The
typed table is the one that keeps then-and-now working**, which is the whole reason Claim
Basis exists. Recorded for the ruling rather than decided here.

**Owed.** Re-drop v1.4. Plus the standing list, the substantive threshold, and now the four
declared-but-unbuilt cited lookups.

---

## 2026-08-01 · session 36 · the missing-relation flag, built general

**Did.** Synced `aao-charter-design-v1_5.md`, deleted v1.3. Built the missing-relation flag
to the ruled shape. **153 tests, 153 passing** (was 146).

### The shape, and both halves of why it is neither of the obvious ones

Keyed on **deal plus relation kind**, rolling up, **naming the rows inside it**, cleared only
when the count reaches zero.

- **Per card would be noise.** Twelve solutions with no stated problem is twelve flags saying
  one sentence, and a flag list nobody reads protects nobody.
- **Per deal would be useless.** *Something is missing an edge* cannot be acted on, because
  the three kinds are three different conversations — a discovery gap, a qualification gap,
  and a mapping gap.

**Built general rather than solution-specific**, per the ruling. `AAO_MissingRelation` does
not know what a Solution or a Pressure is: it takes a kind and a list of members, and whoever
knows the relation computes them. The moment it knows the domain it stops being general and
becomes three classes wearing one name.

**The count is the headline and the members are the work.** A rolled-up flag carrying only a
number would tell a seller there is a problem without telling them where — the exact failure
the receipts discipline exists to prevent — so `AAO_Missing_Members__c` names each row by id
and label.

**`AAO_Relation_Key__c` is unique**, so one-flag-per-deal-per-kind is a law the database holds
rather than a convention the code remembers. Without it two passes raise two flags and the
count becomes a lie.

### An existing law made a ruling I was about to make wrongly

I wrote the reopen path to restart the clock, and **the deploy refused it**:

> `AAO_Raised_At__c is immutable. It is what age is measured from, and on a gating
> proposition it is opportunity creation.`

**The refusal is right and I changed the design to match.** This flag is one standing question
about the deal — *does this deal have solutions with no stated problem* — and that question
has been askable since the deal existed. A gap reappearing is the same question answering yes
again, not a new question. **Restarting would have let a deal launder itself into looking
freshly imperfect by closing and reopening**, which is precisely the optimistic drift the
whole build refuses. Held by a test now: after clear-and-reopen, `AAO_Raised_At__c` still
reads the opportunity's `CreatedDate`.

A flag is also never raised just to be cleared: nothing missing writes nothing, because the
absence of a gap is not an event.

### Two things owed to the field tables at their next bump, recorded here so they survive

**1 · `when` is the sixth reserved-word collision**, from the `switch` statement. The list is
`commit`, `json`, `system`, `merge`, `any`, `when` — three refused loudly with the identifier
named (`commit`, `any`, `merge`), two resolved silently by case-insensitive shadowing (`json`,
`system`), and `when` refused loudly, so it joins the first group.

**2 · The after-insert exposure, stated generally.** Session 34 fixed it as one roster bug and
that was too small a description. **Anything hung off an after-insert trigger can turn our
defect into their lost evidence:** a throw there rolls back the row that caused it, so a
failure in derived, secondary work destroys the primary fact we were given. `AAO_Ingest`
already ruled this for the enqueue path — *a failure downstream of arrival must never undo the
arrival* — and the participant writer is the second instance, not a special case. **Every
future after-insert consumer inherits the rule**, and the safe direction is always to lose the
derived thing rather than the evidence.

**Owed.** Unchanged, plus: the volume shape is now built, so what remains for Solutions is the
line-item reader itself, which needs the cited-type ruling and the two new cited types.

---

## 2026-08-01 · session 37 · the line-item reader, and the edge it refuses to write

**Did.** Synced v1.7, deleted v1.5. Built the Solution route. **158 tests, 158 passing**
(was 153).

### The cited-type ruling gave the enum a test, which is the useful part

`Line_Item` added with an `AAO_Cited_Line_Item__c` lookup. `Product2` deliberately not, and
**the rule now has a criterion rather than a case-by-case argument**: a value earns a lookup
when we will compare its live state against the frozen snapshot, because that comparison is
the whole reason Claim Basis is half frozen and half live, and a text Id cannot do it.

A line item earns one — quantity, price and product all move, and a claim resting on a line
that has since changed is exactly the drift then-and-now exists to expose. **A product does
not, and the reason is sharper than reachability:** citing it would cite a *classification*
rather than a fact about this deal. The fact is that this deal carries this line. A claim
citing the product would still read as true after the line was removed.

### The route

`OpportunityLineItem` → `PricebookEntry` → `Product2.ALTF__Solution__c`, one traversal, no
model. A line whose product carries no solution is **skipped rather than guessed at**: not
every product is a methodology solution.

**No ratification, and the reason is not leniency.** Every other machine write asks a person
because a person can see something the machine cannot. Here there is nothing to see — the
claim says a line item exists and names the product it carries, and re-reading it confirms or
refuses that outright. **State verification already does what ratification would do**, so
asking would be asking someone to agree with a row they can read themselves.

**The route refuses a contract the org never asked.** There is no Solution proposition in the
rubric, so `contractCode` is declared by the caller and the route throws by name when it is
not in the applicable set. Choosing one would be the same mistake as manufacturing a Source.
Pinned as a test.

### What it may never do, which is the whole discipline

**It may say a solution is on this deal. It may never say which pressure or obstacle that
solution answers.** A line item records what was quoted; inferring a causal link from a
purchase order manufactures the one thing this build exists to refuse to manufacture.

So the gap gets a flag instead of a guess, and **the flag is Altify's own published test**,
not ours — the Solution admission test asks three questions about links to other cards, so an
unlinked Solution fails the methodology's own bar. Read from the org rather than assumed:
`ALTF__Insight_Card_Edge__c` carries the Solution on `ALTF__Solution_Insight_Card__c` and the
card it answers on `ALTF__Insight_Card__c`, so an edge existing *is* the question.

**Held by a test that asserts an absence**, which is the one worth keeping: after the route
runs on a deal with an unlinked Solution card, the flag stands, names the card, **and
`ALTF__Insight_Card_Edge__c` is still empty.** Another asserts the only exit — a human or a
span inserting the edge clears it, and nothing else does.

### Two laws recorded as general, both from refusals rather than from design

**Flags age from when the question became askable, not from when the answer last turned
bad.** This came out of the trigger refusing my reopen-restarts-the-clock code, and it is now
the stated rule rather than a property of one flag.

**Lose the derived thing, never the evidence.** The after-insert exposure, general: a throw in
derived work rolls back the primary fact we were given.

**Owed.** A Solution proposition in the rubric, which is contract-authoring rather than code.
Plus the standing list.

---

## 2026-08-01 · session 38 · invariant 9 applied, and the ordering law it nearly broke

**Did.** Built the cardinality guard. **164 tests, 164 passing** (was 158). No sync.

**The miss was mine and it was not a detail.** I wrote down that nine people against six
dimensions is fifty-four findings, named the sixteen-thousand-token ceiling beside it, and
**connected neither to the law that already governed both.** Invariant 9 has said all along
that every creation path carries an upper bound and abstains and flags past it. A ceiling
that is only discussed is not a ceiling.

### Why abstaining beats truncating, which is the substance rather than the mechanism

Without the guard the run does not refuse at a stated number. It discovers the number by
failing against the model's own limit, mid-pass, having already paid for the call. **And a
truncated response is worse than a refused one.** The parse law says a derived fact may never
be derivable from a parse failure — and a findings array cut off at the token ceiling
produces exactly that. **The comparator would read every unit past the cut as `not_returned`,
which is a fact about arithmetic wearing the clothes of a fact about evidence.** Fourteen
fabricated rows nobody could tell from real ones.

So it refuses the whole pass and says so, with both numbers recorded and **the ceiling frozen
on the flag**: raising the bound later must not silently rewrite why an older run abstained.

### The bug this nearly was, caught by the codebase's own comment

`AAO_Pipeline` carries an ordering law in its own words: *everything before the callout is
SOQL, because Apex forbids a callout after DML and a single row written above this line fails
the model call with an error that reads like a platform problem rather than an ordering one.*

**My first guard wrote a flag on the way past.** That would have broken the model call on
every pass that was WITHIN its bound — the passes nobody would think to test, because they
are the ones that work. The failure would have looked like the callout being broken rather
than the guard existing.

So the check is **pure**, and the writing is split:

- `check(proposed)` — no DML, safe before a callout, decides only.
- `refuse(...)` — writes, and only on the abstaining branch where no callout follows.
- `clearIfStanding(...)` — writes, and only after the pass.

**Pinned as a test that asserts a DML count of zero**, because that is the property, not a
side effect of how it happens to be written today.

### Where the bound lives

`AAO_Model_Config__mdt.AAO_Max_Findings_Per_Pass__c`, set to 60. It belongs there for the
same reason the model name does: the one place a person decides what the build runs under,
with no code allowed to reach past it, and it sits beside `AAO_Max_Output_Tokens__c`, which
is the reason it exists at all.

**A missing configuration is NOT read as unbounded.** An unbounded creation path is precisely
what invariant 9 forbids, so an absent value falls back to a finite 50 rather than to
infinity: **forgetting to configure must never be the same as choosing no limit.**

### Wired live, not left as a library

The guard runs on the extraction pass today, before the callout, so it is exercised rather
than waiting for the People charter to arrive and use it correctly. A test asserts the
rehearsal is well inside its bound — **a guard that fired on the rehearsal would be a bound
set wrong, not a bound doing its job.** `PEOPLE_PASS` is named and ready.

**Owed.** Unchanged, plus: the People assembler must call `check` before it builds its handed
set, which is the whole point of doing this now rather than after.

---

## 2026-08-01 · session 39 · context 17 synced; the persona field read ahead of building it

**Did.** Synced three files. Seed v4.0 and corrections v2.3 in. **Nothing built**, per the
drop. `aao-charter-design-v1_7.md` arrived **byte-identical** to the copy already here.

**A deletion correction.** The instruction said delete corrections v2.2; **v2.2 never reached
this repo.** What was here was **v2.1**, which v2.3 supersedes, so that is what I deleted —
the standing rule is one live copy per document and superseded versions are never kept beside
their replacement. `aao-corrections-v1_0.md` stays, because v2.3 itself says v1.0 remains
true. Seed v3.1 likewise never arrived; seeds v1.0 and v2.0 are kept upstream deliberately
and were left alone.

### Persona, read from the org before anyone builds against it

**`ALTF__Contact__c.ALTF__Altify_Personas__c` exists and is what the ruling says it is:**
multipicklist, **restricted**, twelve active values — CEO, CRO, Executive Sponsor, Sales
Leader, RevOps Leader, Enablement Leader, IT Leader, Procurement Lead, Altify Program Owner,
Consultant, Legal, Partner. Field length 4,099.

**Restricted is good news and closes a question in advance:** the persona emission's enum is
runtime-closed from these twelve, exactly like every other closed enum in the envelope. Free
text is structurally impossible, so the charter cannot invent a persona.

### Two hazards, both concrete, both worth ruling before the build

**1 · There are TWO persona fields on two different objects, and they disagree.**

- `ALTF__Contact__c.ALTF__Altify_Personas__c` — multipicklist, twelve values, the one ruled.
- **`Contact.Persona__c`** — a *different* field on the *standard* Contact: single picklist,
  restricted, three values, `Economic` / `Technical` / `Champion`.

`ALTF__Contact__c` is a custom junction of only seventeen fields carrying
`ALTF__Contact__c → Contact`, so **it is not the standard Contact and the two are one letter
apart in conversation.** This is the `AAO_Answer__c` versus `ALTF__Answer__c` hazard again,
and it is worse here because both fields are called persona and both are restricted, so a
write to the wrong one would succeed. **Say the Altify contact row or the standard contact,
never bare persona.**

**2 · "Additive only, the machine never removes a value" has no atomic form on a
multipicklist.**

A multipicklist is a semicolon-delimited string. There is no add-one-value operation: adding
means read, append, write the whole set back. **So two writers adding two different personas
in overlapping transactions produce last-write-wins, and one addition disappears with no
error.** That is precisely the failure the additive-only rule exists to prevent, arriving by
a different door.

The build already has the shape that solves it, twice over: the `DUPLICATE_VALUE` merge path
on `AAO_Answer__c`, and `requireBasisRows` verifying inside the transaction rather than
trusting. The persona writer needs the same discipline — **re-read and re-merge at write
time, and verify the value survived before returning** — rather than a read at the top of a
method and a write at the bottom.

Worth naming which law governs the write at all: this updates a field on a managed object we
do not own, so it falls under the **projection-pattern law — toggleable per customer** — not
under "data rows on managed objects are allowed", which covers creating rows rather than
editing someone else's.

### The Calculated Insight grain

Recorded, not acted on: it is a one-way door and must be decided before the insight ships.
Nothing in this repo touches Data Cloud, so there is no code position to protect yet — but
the reason it is one-way is worth having written down here, because it is the same reason
key four exists: **a grain not recorded cannot be declared later without reprocessing**, and
a Calculated Insight cannot be regrained without rebuilding its history.

**Owed.** Unchanged.

---

## 2026-08-01 · session 40 · corrections v2.4 synced; the licence read found

**Did.** Synced `aao-corrections-v2_4.md`, deleted v2.3. **Nothing built**, per the drop.
§4c is scope for a phase, not a task.

**A version-stamp inconsistency worth fixing before this goes to corporate.** The file's H1
reads `# AAO Corrections and Change Record, v2.2` and its last line reads *End v2.2*, while
the stamp on line 3 reads **v2.4**. The seed's own rule is *read the version stamp inside the
file, never trust the filename* — and here the title and the footer disagree with the stamp,
which is worse than a filename mismatch because both are inside the file.

### The one thing I could settle rather than record: how to read a licensed seller

§4c says the source of truth is a read and correctly rules out `sfLma__License__c`. **The
read exists and I found it.** In `aossb2`:

| Object | What it is | Read |
|---|---|---|
| `sfLma__License__c` | the ISV's own licence management, about *their* customers | **0 rows** — present but empty, exactly as the ruling says |
| `PackageLicense` | the installed package and its seat pool | **1 ALTF row**, `AllowedLicenses = -1` (unlimited), `UsedLicenses = 80` |
| `UserPackageLicense` | **who actually holds a seat** | **80 ALTF assignments** |

So **`UserPackageLicense` joined to `PackageLicense.NamespacePrefix = 'ALTF'` is the licensed-
seller read**, and it is a platform object rather than a managed one — no dependency on
Altify's own tables, nothing to break when the package upgrades, and it answers per user
rather than per org.

Two things about it that matter for the phase. `AllowedLicenses = -1` means unlimited, so
**the seat pool cannot be used to infer scarcity** and only the assignment rows tell the
truth. And this is a *package* licence rather than a *module* licence — it says the user may
use Altify, not which of the four modules they hold. **Module ownership needs a different
read, and §4c is right that it surfaces as permission rather than absence**, which means the
probe has to attempt or describe rather than count.

### Where the permission-set harness idea lands

**It is buildable today and it is the only honest option.** `aossb2` holds every module, so
module ownership cannot be observed here by any query — the difference between *not licensed*
and *not installed* is invisible in an org that has everything. Stripping a test user of
object access and running the pipeline as that user reproduces the actual failure mode,
because a permission failure and a licence failure arrive as the same DML error.

Worth naming what that harness would prove and what it would not: it proves **degradation**,
that a projection failure never touches the claim, the flag or the roll-up. It does not prove
**detection**, because a permission-stripped user is not the same signal a real unlicensed org
would give. Detection stays unverifiable until a differently-licensed org exists.

### Two numbers in §2.4 that have moved since it was written

- *"153 tests green"* — now **164**.
- *"Claim Basis declares eight cited types and has built two"* — **eight declared, four
  built.** `AAO_Cited_Answer__c`, `AAO_Cited_Map_Row__c`, `AAO_Cited_Source__c` and
  `AAO_Cited_Line_Item__c` all exist in the org. The remaining four —
  `Insight_Card`, `Decision_Criterion`, `Qualifier_Status`, `Shadow_Person` — are enum values
  pointing at nothing.

§2.4's other corrections check out: nine objects live counting `AAO_Model_Config__mdt`, and
six reserved words with `when` included.

**Owed.** Unchanged. The scope phase is recorded and not started.

---

## 2026-08-01 · session 41 · corrections v2.5 synced; §5's open read is closed, and the answer is the opposite

**Did.** Synced `aao-corrections-v2_5.md`, deleted v2.4. **Nothing built.** The stamp fix is
right and structural: a version that lives in one place cannot go stale in another.

### The open read in §5 is closed, and §2.1's retrieval note is wrong

§2.1 says *"the text is in the managed package UI, not in any queryable table"* and §5 keeps
*"whether the wizard's help text is reachable as custom labels through the Tooling API"* as
unsettled. **It is reachable, it is custom labels, and it was answered in session 33 — that
finding never reached this record.**

`ExternalString` in `aossb2` holds **2,930 ALTF labels**, and the wizard questions are among
them under a naming convention that makes them discoverable by pattern rather than by search:

```
AM_OM_SUPPORT_GUIDED_QUESTION_1   Has this person expressed a preference for a specific solution?
AM_OM_COVERAGE_GUIDED_QUESTION_2  Have you or a team member recently had multiple meaningful
                                  conversations with this person?
```

**Twenty-six `%GUIDED_QUESTION%` labels**, prefixed `AM_OM_` (both maps), `AM_` (account map)
or `OM_` (opportunity map). The insight admission tests are there too, as
`GOAL_HELP_TEXT_1..3`, `PRESSURE_HELP_TEXT_*`, `INITIATIVE_HELP_TEXT_*`,
`OBSTACLE_HELP_TEXT_*`, plus `*_DEF_AM` and `*_DEF_OM` definitions.

**This changes discovery from a manual transcription to a query.** The ontology §2.1 calls
the most consequential finding of the session is not trapped in a UI — it can be read the way
the assessment rubric is read, which is what "discovered rather than paraphrased" requires to
be true in a customer org rather than in a document.

### Three things in the enumeration that a discovery pass must handle

**1 · The account map and the opportunity map ask DIFFERENT questions, not translated ones.**
`AM_SUPPORT_GUIDED_QUESTION_1` reads *a specific **provider***; `AM_OM_SUPPORT_GUIDED_QUESTION_1`
reads *a specific **solution***. Q2 likewise: *your **company*** versus *your **solution***.
**These are different propositions, and reading one for the other would put the wrong
proposition text on a contract** — the exact failure the verbatim rule exists to prevent.

**2 · The numbering is sparse and is not a sequence.** Support runs 1, 2, 4, 5, 6, 7, 11, 14,
16; Political Status runs 1, 2, 3, 4, 6, 7, 9. **An assembler that iterates 1..N silently
misses questions and produces a short rubric that looks complete.** The set must be read by
pattern and taken whole.

**3 · The gaps are not the whole tree.** The recovered Support tree has five questions; the
labels carry nine, including *is this person vocal in their support of your competition* and
*do you have evidence that this person believes your success will hurt their company or job*.
**The wizard walk found the path taken, not the tree.** The labels are the superset, which is
another reason to read them rather than transcribe a click-through.

### And the label-override hazard applies directly

Recorded at session 33 and worth restating here because §2.1 now depends on it: **56
`ExternalString` localizations in this org override ALTF labels**, 55 with changed text (one
consistent rebranding, *Account Manager plan* → *Book of Business plan*). None touches the
question labels today.

**But a customer can silently rewrite any of them, and the override lives in a different
table from the label.** So a discovery pass deriving proposition text from labels **must read
the localization layer, not the packaged value**, or it authors contracts from words no user
of that org has ever seen. That is the label-layer twin of the `ALTF__Status_Answer__c`
hazard: **the stored artifact and the displayed truth can disagree.**

**Owed.** Unchanged. The scope phase is recorded and not started.

---

## 2026-08-01 · session 42 · corrections v2.6 synced; the owed enumeration delivered

**Did.** Synced v2.6, deleted v2.5. **Nothing built**, and nothing will be built against
v1.7's Support set. Delivered the owed enumeration, read from `aossb2` with the localization
overlay applied. **68 labels across the four patterns.**

**The overlay is empty, and that is a finding rather than a formality.** Of the 56
org-namespace overrides in this org, **zero touch any question, help-text or definition
label** — all 56 are the `AM_*` UI-banner rebranding. So the effective text equals the
packaged text here, and every string below is both. **The overlay still has to be applied in
code**, because it is empty in this org and cannot be assumed empty in a customer's.

### Guided questions · 26, and the split matters

**BOTH MAPS — `AM_OM_` — 16.** Coverage 1, 2, 3. Political Status 3, 4, 6, 7. Support 1, 2,
4, 5, 6, 7, 11, 14, 16.

**ACCOUNT MAP ONLY — `AM_` — 7.** Political Status 1, 2, 9. Support 1, 2, 4, 6.

**OPPORTUNITY MAP ONLY — `OM_` — 3.** Political Status 1, 2, 9.

**Support is nine on the opportunity map, not five.** The four never walked:

- `_6` — *Has this person told you they prefer an alternate solution, including an internal
  solution or do nothing at all?*
- `_11` — *Does this person prefer an alternative solution -including an internal solution or
  nothing at all?*
- `_14` — *Is this person vocal in their support of your competition?*
- `_16` — *Do you have evidence that this person believes your success will hurt their company
  or jeopardise their personal success?*

**`_6` and `_11` are near-duplicates with different wording and a stray hyphen**, which is
what an authored set looks like after years of edits. They are two labels and must stay two
propositions; collapsing them would be paraphrasing, which is the thing the verbatim rule
forbids.

**Political Status is seven, not three**, and the split is sharper than Support's. `_1`, `_2`
and `_9` exist in **separate AM and OM versions with genuinely different text** — the account
map asks *does this person define the company's goals*, the opportunity map asks *does this
person define the company's goals and objectives, **or do they merely have a good
understanding of them***. `_3`, `_4`, `_6`, `_7` are shared. **So Political Status is four
shared plus three per-map, and no single list is the ontology.**

**Numbering confirmed sparse and per-family, not global:** Support 1, 2, 4, 5, 6, 7, 11, 14,
16; Political Status 1, 2, 3, 4, 6, 7, 9; Coverage 1, 2, 3. Coverage is the only dense one and
the only one fully recovered by the walk — which is why the walk felt complete.

### The insight admission tests · YES, also a superset

**Solution's four are in the labels**, `SOLUTION_HELP_TEXT_1..4`, matching §2.2 verbatim
including *would a key player be able to articulate your unique business value from this
Solution*. And `SOLUTION_DEF_AM` / `_OM` exist, identical to each other, which §2.2 recorded
as owed.

**But Goal, Pressure and Initiative each carry SIX, not three** — `_1.._3` plus
`_AM_1.._AM_3`, a separate account-map set with different text. Obstacle carries **three
only**, with no AM variant. So the insight side has the same AM/OM split as the map side,
**and it is uneven across types** — which no walk would reveal, because a walk sees one map at
a time.

Two more that a pattern query catches and a walk would not: `PRESSURE_EDIT_TYPES_HELP_TEXT`
and `SOLUTION_EDIT_HELP_TEXT` are edit-form guidance rather than admission tests, so **the
`%HELP_TEXT%` pattern is broader than the ontology** and an assembler must filter by family
rather than take the pattern whole. Same class of hazard as the sparse numbering, in the
other direction: **the pattern under-collects if you iterate and over-collects if you do
not.**

**Owed.** Unchanged. v1.7's Support ontology is not to be built against; the enumeration above
is the input for correcting it.

---

## 2026-08-01 · session 43 · the opportunity-map paste, read from labels

**Did.** Synced v2.7, deleted v2.6. **Nothing built**, and nothing will be built against
v1.7's Support or Political sets, now marked SUPERSEDED.

**Delivered the opportunity-map set: 35 labels requested, 35 found, none missing, zero
overrides applying.** Read from `ExternalString` by exact name with the localization overlay
queried and found empty for all thirty-five. Every string below is verbatim from the org and
none is reconstructed from the walk. The full paste is in the reply to this instruction.

**Support 9, Political Status 7 (four shared + three OM-only), Coverage 3, and the five
insight admission sets — Goal 3, Pressure 3, Initiative 3, Obstacle 3, Solution 4.**

### Three things visible only once the OM set is isolated

**Support `_5` and `_7` are a matched pair pointing opposite ways.** *Is this person mentoring
**you**…* against *is this person mentoring **your competition** and working to help them
win*. Likewise `_2` and `_6`: preferring your solution against preferring an alternate one.
**Altify authored the negative half of the ladder explicitly**, which the walk missed entirely
because the walked path never went down the No branch far enough. The five recovered questions
were all on the positive spine.

**Political Status `_6` and `_7` were never walked and are not about authority at all.**
*Track record of success in implementing projects that deliver value* and *collects and
provides information to people of power and influence* — the first is competence, the second
is brokerage. The three walked questions were all about position. **A four-question ontology
read as three would have lost the two dimensions that are not hierarchy.**

**`PRESSURE_HELP_TEXT_3` differs from what §2.2 recorded.** The label reads *will this
pressure prevent a goal from being achieved?* — §2.2 lists Pressure with only two questions
and no third. So the insight side had a gap too, and it is the question that carries the
Pressure-to-Goal link the record separately notes as *taught but not stored*. **The
methodology asks about the edge that the schema cannot hold.**

### The spelling and punctuation are kept exactly

`organisation` in `OM_POLITICAL_STATUS_GUIDED_QUESTION_9` against `organization` in the AM
variant; `jeopardise` in `_16`; the stray hyphen in `_11`'s *-including*; the curly
apostrophes in `company's` and `customer's`. **None of it is normalised.** These strings
become proposition text, and a normalised quote is a paraphrase — the same rule that makes
the byte check possible on spans.

**Owed.** Unchanged. v1.8 is written from labels or not at all, and this is the input.

---

## 2026-08-01 · session 44 · the People ontology built, and the read that cannot run in Apex

**Did.** Synced v1.8, deleted v1.7. Built `AAO_PeopleOntology`. **171 tests, 171 passing**
(was 164). And found a blocker in the discovery story that is worth more than the class.

### The read cannot happen in Apex, established from the org rather than reasoned about

v1.8 and v2.6 both say a pattern query recovers any org's set at install with no human in it.
**That is true of the Tooling API and false of Apex**, and I only found out by trying to
compile it:

- **`ExternalString` is a Tooling API object.** Apex SOQL cannot see it. The compiler answers
  `Invalid type: ExternalString`.
- **`System.Label.ALTF.<name>` is the other door and it is shut too.** The compiler answers
  `External string does not exist` — because **2,576 of the 2,930 ALTF labels are
  `IsProtected = true`, including every guided question**, and a protected managed-package
  label is invisible to subscriber Apex. Only 354 are public.

**The finding stands and the mechanism changes.** The labels are the source of truth and they
are readable; what moves is WHERE the read runs. Two ways out, both rulings:

1. **A Tooling API callout at setup time**, through a Named Credential pointing at the org
   itself. This is the shape already ruled for state-based questions — read once, freeze on
   the contract, re-run when the content hash moves — and setup is where a callout is
   affordable. **The cost is that *zero customer-admin action* becomes one action**, because
   somebody must authorise a credential to their own org.
2. **The read happens outside the org and the labels arrive as data.** Honest, and it gives
   up the install-time automatic property that made this better than a walk.

**This is the third time a design sentence about our own reach has been wrong in the same
direction** — Coverage-as-a-frozen-query, the `required` flag on Source, and now this. All
three were claims about what the platform would let us do, made without asking it. The
standing rule already covers it and it keeps needing to fire.

### What was built regardless, because the rules are the valuable part

`AAO_PeopleOntology` is the **assembler**, and the seam is deliberate rather than a
workaround: whoever performs the read, the rules that turn labels into contracts are the
same and live in one place.

- **The family guard, which is the one that would have caught v1.7.** The expected shape is
  declared — Support 1, 2, 4, 5, 6, 7, 11, 14, 16 and the rest — while the TEXT always comes
  from the org. A short read refuses and names exactly which questions are missing. **Held by
  a test that removes the four the walk missed and asserts the refusal says `6, 7, 11, 14`.**
- **Byte-exact.** Tested on `organisation`, `jeopardise`, and the stray hyphen in `_11`'s
  `-including`. A normalised quote is a paraphrase.
- **Route per dimension.** Coverage P, Support and Political E.
- **`Subject_Person` only where the question says *told you*** — `_2`, `_4`, `_6`. Not `_16`,
  which asks whether the SELLER holds evidence, so it is observational rather than reported
  and requiring the subject to have said it would make it unanswerable.
- **Compound questions become elements and the decomposition is marked as OURS.** `_4`, `_5`
  and `_16` land `Inferred_Pending` and `Awaiting_Ratification`; the undecomposed fifteen
  land `Authored`, because Altify wrote those whole. **Altify authored the question; we split
  it; a human ratifies the split.**

`read()` refuses by name and explains both ways out, so the blocker cannot be walked past
silently. Pinned as a test.

**Owed.** The label-read ruling, which is Matthew's. Until then the ontology assembles from
supplied labels and authors nothing on its own.

---

## 2026-08-01 · session 45 · influence and conflict: what the labels actually carry

**Did.** Read-only pattern scan. **No build action.** Guard applied: **the ALTF label table
holds 2,930 rows**, so every zero below is a filter result and not an empty table.

### The suggested pattern would have missed the most important hit

**`%CONFLICT%` returns five labels. It does NOT return `CONFCLIT_MODE_HELP_TEXT`, because the
label name is misspelled in the package.** That row is the only conflict help text there is:

> **`CONFCLIT_MODE_HELP_TEXT`** — *Select the contact this person is in conflict with. (To
> focus on another person, click their power menu icon and select the action you want to
> take).*

Its influence twin is spelled correctly:

> **`INFLUENCE_MODE_HELP_TEXT`** — *Select the contact this person influences. (To focus on
> another person, click their power menu icon and select the action you want to take).*

**A pattern read must tolerate the vendor's typos**, and there is no rule that finds this one
in advance. What found it was reading the whole `%HELP_TEXT%` family in session 42 and looking
at the list — **the family sweep caught what the targeted pattern could not.** That is a third
face of the read-by-pattern-filter-by-family law: **the pattern must be wider than the thing
you are looking for, because the name you are looking for may be wrong.**

`%RELATIONSHIP_TYPE%` returns **zero** against a 2,930-row table, and `%DETRACT%` likewise.
Confirmed empty, not unread.

### The answer to the actual question: there is NO authored ontology

**Sixteen labels across influence and conflict, and every one is a UI string.** *Add Conflict.
Influences. Influenced By. Conflicts. No Conflicts Set.* Plus the two mode help texts above.

**The two help texts are interaction instructions, not propositions.** *Select the contact
this person influences* tells a user how to operate a picker. It does not say what influence
IS, what makes one person influence another, or how a seller would know. Set beside
`AM_OM_SUPPORT_GUIDED_QUESTION_5` — *is this person mentoring you by providing guidance,
political insight, or competitive information* — the difference is total. **One is a question
about the buyer; the other is a caption on a button.**

**So v1.8's claim that Politics has no authored ontology is CONFIRMED, and now it is confirmed
by a read rather than by a UI walk.** This is the case where a confirmed empty was worth as
much as a hit: the last two times absence was assumed the text was there, and this time it
genuinely is not.

### And the schema says the same thing, more sharply

`ALTF__Contact_Influence__c` carries **fourteen fields and only four that matter**:

| Field | |
|---|---|
| `ALTF__Influencing_Contact__c` | → Contact |
| `ALTF__Influenced_Contact__c` | → Contact |
| `ALTF__Type__c` | picklist: **`Conflict`, `Influence`** |
| `ALTF__AltifyId__c` | the external key |

**One object holds both, discriminated by a two-value picklist**, and there is no
`ALTF__Contact_Conflict__c` — it does not exist. **No strength, no direction beyond the two
contact lookups, no basis, no note, no date.** An edge is a bare triple: who, whom, which
kind.

**That is the same shape as the person-to-card finding and it is worth naming as a pattern.**
`ALTF__Insight_Card_Contact__c.ALTF__Type__c` collapses four authored questions into
`Informer` and `Owner`; `ALTF__Contact_Influence__c.ALTF__Type__c` collapses two relationship
kinds into one row with no room for why. **Altify's relationship layer stores the fact and
never the evidence for it** — which is precisely the gap this product exists to fill, and it
means our claims carry everything the edge cannot: the span, the speaker, the date, the
receipt.

**Consequence for the Politics charter, and it is a simplification.** There is nothing to
discover, so nothing to reconcile against a vendor ontology, so no AM/OM split, no sparse
numbering, no localization overlay to apply on the way in. **Politics is authored by us from
zero, contracts land `Inferred_Pending` until a human ratifies them, and that is the whole
story** — the same position Buyer Role is in, and now demonstrated rather than assumed.

**Owed.** Unchanged.

---

## 2026-08-01 · session 46 · v2.8 synced; the capability law applied to its own recommendation

**Did.** Synced v2.8, deleted v2.7. **No build action** — the sourcing decision is Matthew's
and is not ruled. But the new law says a capability claim is unverified until tried from the
runtime that will make the call, so I tried the recommendation's before it is ruled, and it
comes back mostly good.

### The recommendation is viable in Apex, with one boundary

Option 2 keys packaged text by package version. That only works if Apex can read the version
of somebody else's package. **It can.** `Publisher` is a real Apex-queryable object:

```
Publisher: NamespacePrefix = ALTF, MajorVersion = 9, MinorVersion = 18
```

**So the version selector is available where the product stands**, unlike the labels
themselves. That is the first of these four capability questions to come back positive.

**The boundary, and it is a real one.** `Publisher` gives **major and minor only.** The org
actually runs **9.18.3 build 1** — Tooling sees the patch and the build, Apex does not.

**A patch can change a label.** Salesforce permits label edits in a patch release, so
reference data keyed to `9.18` would serve 9.18.0's wording to an org running 9.18.3 and have
no way to know. Three honest responses, none of them mine to pick:

- **Accept it and say so**, on the same grounds as the overlay: rare, declared loudly, never
  assumed. A patch that rewords a guided question is unusual.
- **Key to major.minor and verify one canary label at runtime** — cheap, catches a reworded
  set without needing the patch number, and turns an invisible drift into a loud one. This is
  the shape I would build if it were mine.
- **Read the patch through Tooling**, which puts the callout back and defeats the point of
  option 2.

### Two stale items in v2.8 worth clearing

**§5's "owed immediately" is already paid.** It still asks for the `%GUIDED_QUESTION%`
enumeration with overlay; that was delivered in session 42 and the opportunity-map paste in
session 43. The line should close the way the Tooling-API read did.

**§4d's basis for "Politics has no authored ontology" is weaker than what we now hold.** It
reads *confirmed by Matthew from the UI*. **It is now confirmed by a read** — session 45,
sixteen labels across both families and every one a UI string, against a 2,930-row table so
the zero is a filter result rather than an unread table. Worth upgrading, because a UI walk is
exactly the evidence class that produced the five-question Support set.

### The capability law, and where I would point it next

The law is right and the three instances it names are the three that happened. **The fourth
is already visible in v2.8's own §4c:** *projection probes before it writes* assumes Apex can
distinguish a permission failure from a licence failure at probe time. **That is a capability
claim about the runtime and it has not been tried.** It is also the one where being wrong is
expensive, because the whole partial-ownership design rests on the probe telling the truth —
and v2.5 already found that permission and licence failures arrive as the same DML error,
which is a hint that the probe may not be able to say which it hit.

**Owed.** Unchanged.

---

## 2026-08-01 · session 47 · v2.9 and rebuttals v0.3; §8 verified against the org

**Did.** Synced both, deleted v2.8 and rebuttals v0.2. **No build action** — the label
sourcing decision is still Matthew's, so `AAO_PeopleOntology` stays an assembler and reads
nothing on its own.

### §8 is QBR-facing, so I checked it rather than trusting it

Both checkable claims hold, and one is stronger than stated.

**The per-dimension timestamp claim is right, and there are SIX not one.**
`ALTF__Contact_Map_Details__c` carries `Account_Relationship`, `Buyer_Role`, `Coverage`,
`Decision_Orientation`, `Political` and `Status` — each with its own `_Last_Modified__c` —
against exactly one record-level `LastModifiedById` and one `CreatedById`.

**That sharpens the sentence rather than merely confirming it.** Six separate decisions to
record *when this attribute changed*, and not one to record *who changed it*. The schema was
not built to the edge of provenance by accident; somebody went dimension by dimension adding
the timestamp and stopped at the name every single time. **It is a per-dimension clock with
no per-dimension author**, which is a better line than *built to the edge and stopped*.

**The Support value set is right and carries a sixth value the table omits.**
`ALTF__Status__c` is `Mentor`, `Supporter`, `Neutral`, `Non-Supporter`, `Enemy` — **plus
`Unknown`**. `ALTF__Coverage__c` likewise ends in `Unknown` after the four named levels.

**Worth adding to §8 rather than correcting**, because it strengthens the point: the schema
already has a slot meaning *nobody has answered this*, so the vendor's own model distinguishes
unanswered from neutral. **That is abstention in the storage layer, and it is the one thing
the field does carry that a nine-question read would need** — which makes the discarded part
even more precisely the reasoning, and only the reasoning.

### The two stale items survive into v2.9's body

The changelog records the read correctly, but neither downstream section moved:

- **§4d still reads *Confirmed by Matthew from the UI*.** It is now confirmed by a read of a
  2,930-row table. Worth upgrading precisely because a UI walk is the evidence class that
  produced the five-question Support set — leaving it as-is has the weaker basis outliving
  the stronger one in the same document.
- **§5 still carries *Owed immediately* for the enumeration**, delivered in sessions 42 and
  43. It should close the way the Tooling-API read did.

Second time flagging both. Recorded rather than repeated further.

### On the guard gap, which v2.9 states honestly and I want to sharpen slightly

v2.9 says the filter-fault guard does not catch the misspelling, and that some misses are only
caught by a person sweeping wider and reading the output. **That is true and it is the right
thing to write down.** One narrowing worth having: **the family guard catches this class
whenever a shape can be declared, and the misspelling is only invisible because nobody had
seen the family before.** Once `CONFCLIT_MODE_HELP_TEXT` is known, it is declarable and
guarded forever. So the uncatchable window is **first contact with a family**, not the family
itself — which makes the honest rule *the first read of any family is done by a person, and
every read after that is guarded*.

**Owed.** Unchanged. Waiting on the sourcing decision.

---

## 2026-08-01 · session 48 · the handoff set

**Did.** Synced context 19. **Nothing built**, per the drop. Seed v5.0 in; **seed v4.0 and
corrections v1.0 deleted** as instructed. The other three files arrived **byte-identical** to
the copies already here, so this drop is one new file and two deletions.

**Seed v5.0's `171 tests green` verified against the org: 171 run, 171 passing.** Checked
rather than carried forward, because a handoff document's numbers are the ones a new
conversation will repeat without re-checking.

### Deleting corrections v1.0 leaves two dangling references

Nothing in the corrections chain depended on it — **v2.9 contains zero references to v1.0**,
which is why the deletion is clean at that level. But two older documents still point at the
file, and one of them points at it as the top authority:

- **`aao-code-build-brief-v1_0.md`, line 14:** *"`docs/aao-corrections-v1_0.md` — the
  Answer/Claim correction. **Where this disagrees with anything else, it wins.**"*
- **`MANIFEST.md`, line 10:** lists it as *"Authoritative over the four project documents
  until they are bumped."*

**A pointer to a deleted file that claims precedence over everything is worse than a stale
copy**, because a reader who follows it finds nothing and has no way to tell whether the
authority moved or was withdrawn. The build brief and the manifest are both below the
corrections chain and neither has been bumped in this whole run, so they were always going to
drift; this is the first deletion that makes the drift visible.

**Not fixed by me** — both are authored elsewhere and `docs/` is read-reference. Reported so
the next bump of either can drop the line or repoint it at v2.9, which is where that authority
now lives.

### What is still in docs/ and deliberately so

Seed v1.0 and v2.0 remain. The instruction named v4.0 only, and earlier drops carried the
older seeds alongside the current one, so they read as kept history rather than oversight.
Flagging in case that assumption is wrong, since this drop was described as the full current
set and those two are the only files that could contradict it.

**Owed.** Unchanged. Waiting on the label sourcing decision; `AAO_PeopleOntology` remains an
assembler and reads nothing on its own.

---

## 2026-08-01 · session 49 · LAW #1: the ontology becomes ours

**Did.** Synced context 20, verified the capability first, built the seed type, loaded 35
records byte-exact and repointed the reader. **171 tests, 171 passing.**

### The sync arrived under stale filenames and I filed by stamp

The folder held `aao-code-build-brief-v1_0.md`, `aao-corrections-v2_0.md` and
`aao-demo-runsheet-v1_2.md`. **The content was current — v1.1, v3.0 and v1.3 by internal
stamp — and only the filenames were old.** Filed under the correct names and the stale ones
deleted, per the seed's own rule: *read the version stamp inside the file, never trust the
filename.* Syncing by filename would have regressed corrections from v2.9 to v2.0 and
reinstated two documents I already held. Seeds v1.0 and v2.0 deleted as instructed.

### Step 1 · verified from the platform, not from memory

**(b) Apex reads custom metadata records with no callout. VERIFIED:** one row returned,
`Limits.getCallouts()` = **0**, and this is already shipping in `AAO_Cardinality.ceiling()`.

**(a) The manageability names, established by deploying each candidate and keeping what the
platform accepted.** Guessing was refused first, and the refusal named the enum:

> `Error parsing file: 'NotARealValue' is not a valid value for the enum 'FieldManageability'`

| `FieldManageability` | accepted |
|---|---|
| `DeveloperControlled` | **yes** |
| `SubscriberControlled` | **yes** |
| `Locked` | **yes** |
| `PackageProtected`, `Upgradeable`, `SubscriberEditable` | rejected |

And the type-level enum is a different one, `SetupObjectVisibility`:

> `Error parsing file: 'Private' is not a valid value for the enum 'SetupObjectVisibility'`

`Public`, `Protected` and `PackageProtected` accepted; `Private` rejected. **`PackageProtected`
is valid on the TYPE and invalid on a FIELD**, which is the kind of thing that reads as
obvious once seen and would have been wrong if assumed.

**(c) Upgrade behaviour per manageability: UNVERIFIABLE HERE, and named as such.** There is
no packaging org, no packaged version of these components and no upgrade to observe —
everything above is unmanaged metadata in a subscriber sandbox. **Establishing what an upgrade
does to a subscriber's edit needs a packaging org, a separate subscriber org and a real
version bump.** It sits beside module licensing on the list of things this org structurally
cannot answer. Not assumed, and the build was shaped so it does not need the answer.

### Step 2 · the two-field shape, and why the unverifiable item made it load-bearing

`AAO_People_Question__mdt` with `AAO_Shipped_Text__c` (DeveloperControlled) and
`AAO_Org_Override__c` (SubscriberControlled, null until set).

**One field would force a choice between two failures.** DeveloperControlled alone: an upgrade
overwrites whatever the customer wrote, silently. SubscriberControlled alone: we can never
ship a correction, because the customer's value wins forever **and we cannot tell an
intentional edit from an untouched default.** Two fields dissolve both, and the reader prefers
the override only where it is populated, so **null is not a value** — an untouched org gets
our words and a customised org gets its own, with no flag, no branch and no migration.

**The recommendation was right and step 1 made it necessary rather than merely preferable.**
Because (c) is unverifiable, a design that leaned on manageability semantics would be resting
on an untested claim — the exact thing the capability law forbids. **This shape survives
upgrade by construction**, so the untested claim never has to be true.

### Step 3 and 4 · loaded and repointed

**Thirty-five records**, byte-exact: Support nine, Political Status seven, Coverage three,
plus Goal, Pressure, Initiative, Obstacle three each and Solution four. `organisation`,
`jeopardise`, the stray hyphen in `_11`'s `-including` and the curly apostrophes all ship as
read.

**The byte-exactness tests passed unchanged against the new source**, which was the check that
mattered: they assert the hyphen and the spellings and they never knew the source moved.

`AAO_PeopleOntology.read()` now runs a plain SOQL query over our own metadata. **The seam did
not move — only what feeds it.** The family guard is untouched and still refuses a short read,
proven by a test that removes the four questions the walk missed and asserts the message names
`6, 7, 11, 14`.

**A new test asserts LAW #1 is checkable rather than aspirational:** the read returns nineteen
guided questions with `Limits.getCallouts()` unchanged. **The same query returns the ontology
in an org that never had Altify installed.**

### Two refusals worth recording

**`UNKNOWN_EXCEPTION` with zero component errors, again.** Same signature as session 2's
type-and-record-in-one-deploy. This time the cause was different: my record files used the
`xsd:` prefix without declaring `xmlns:xsd`. **A malformed namespace surfaces as an
unattributed platform error rather than a parse error**, so the signature is worth knowing as
*something in the XML is wrong* rather than as one specific cause.

**`field 'AAO_Org_Override__c' can not be filtered in a query call`** — a LongTextArea cannot
appear in a WHERE clause, so `customised()` reads the set and tests null in Apex. **The field
stays long deliberately:** making it filterable means Text(255), the longest shipped question
is already 152 characters, and a customer rewriting one has no reason to stay under a ceiling
chosen for the convenience of a query. Thirty-five rows cost nothing.

**Politics untouched**, per the instruction.

**Owed.** The upgrade-behaviour verification, whenever a packaging org exists.

---

## 2026-08-02 · session 50 · context 21: the account ontology seeded, the guard scoped, Current state rewritten

**Did.** Synced five files. Extended the People ontology seed with the account-map families,
made the family guard scope-aware, rewrote the stale Current state block. **174 tests, 174
passing** (was 171). No other build: the scope resolver and the People projection writer stay
unbuilt, Politics untouched.

**The drop's filenames were stale, the stamps current.** `corrections v2_0` was v3.2 by
stamp, `code-build-brief v1_0` was v1.1, `demo-runsheet v1_2` was v1.3 — wait, those were the
previous drop; **this drop's five files carry matching stamps** (corrections v3.2, scope
resolver v0.4, account captures v0.2, two projection reads), all new, nothing to delete.
Verified stamps before filing regardless, because the last drop taught that lesson.

### The seed · 21 records, counted from the journal and read byte-exact from the org

The instruction said count from my own journal, not the block. Session 42 (line 3831) records
**AM Support 1/2/4/6, AM Political 1/2/9**, and (line 3869) the insight tests as `_AM_1..3` per
type with **Obstacle carrying no AM variant** — so Goal, Pressure, Initiative only. That is
**16 label-sourced**, matching the instruction's parenthetical exactly.

**Byte-exact text came from the org, not from memory**, the same authoring-time Tooling read
sessions 42/43 used — a one-time capture into our own seed, not a runtime dependency, so LAW
#1 holds. All 16 found, overlay empty. The AM/OM axis is visible in the bytes: AM Support says
**provider** and **company** where OM says **solution**; `AM_POLITICAL_1` is *"Does this person
define the company's goals?"* against the OM *"…goals and objectives, or do they merely have a
good understanding of them?"* — different propositions, not translations, kept apart.

**Decision Orientation's five values are UI-captured, and marked as such.** They have no label
behind them — the modal is definitions only, Buyer-Role-shaped — so the text is transcribed
from `aao-ontology-account-captures-v0_2` and cannot be re-queried. That distinction is
load-bearing, so it is recorded on the record: a new `AAO_Provenance__c` picklist, `Label` or
`UI_Capture`, DeveloperControlled. **Marking it stops a later pass from "verifying" a
UI-captured string against a label table that never held it** and declaring a phantom
mismatch. Null reads as `Label` for the 35 pre-field records, the `orTranscript` pattern
exactly — no history invented, no 35-file churn, only the genuinely-different rows carry a
value.

### The guard · scope-partitioned, and why that was the honest way to extend it

The instruction was *the family guard extends to the AM families and still refuses a short
read.* The wrong way was a flat merge: it would have made one `read()` demand both maps'
questions at once, broken the OM-only test, and — worse — let an account pass silently accept
the opportunity set as filler, which is the exact *short-read-looks-complete* failure the
guard exists to prevent, one level up.

So `NUMBERED` and `NAMED` are now keyed by scope. `read(scope)` / `assemble(labels, scope)`
guard per scope; the no-arg forms stay `OM` so every existing test passes untouched. **This is
the "map-scope parameter" the corrections doc already calls for, and it is the ontology layer,
not the projection writer** — no contract-building for AM, no scope resolver code, nothing the
"build nothing else" line forbids.

**What I deliberately did NOT encode:** how the account reading set composes the shared
`AM_OM_` labels with the AM-specific ones. Session 42 shows Support has four AM-specific
positions and five shared; which shared labels an account pass reads is a People-reopen
decision that is not ruled, and guarding a composition nobody authored would be the guess the
guard exists to refuse. The AM guard covers exactly what was seeded and named — AM Support
1/2/4/6, AM Political 1/2/9, Decision Orientation's five — and no more.

**The AM insight tests are seeded and unguarded**, mirroring the OM insight tests: both are
Problems-charter data, guarded when Problems is built, not by the People guard.

### Current state, rewritten from the org · owed since v3.1 §7.2

It had said 128 tests, seven objects, and *everything rests on proposals authored by hand* —
all pre-session-17, and the last of those is now simply false: the model path runs on real
transcripts and Gate 1 round two scored 12/12. Rewritten from live queries: eight objects,
two metadata types, 174 tests, the model pin read from the `Default` record, and an explicit
line that the People ontology is the seed layer only with the charter unbuilt. The one block
the journal's rules say must never go stale no longer is.

**Owed.** Unchanged, and now waiting on the two People-harness rulings — the rung derivation
and the citation budget — which the design side says are coming in the People harness brief.
The account reading-set composition joins the list, surfaced above.

---

## 2026-08-02 · session 51 · the restructure: five living documents, and the handoff written

**Did.** Synced `aao-bundle/` into `docs/` as a restructure rather than a drop. Rewrote
`MANIFEST.md` to the new set. Added a Handoff section to Current state so this directory can
move to a new environment cold. **Nothing built, nothing deployed; the working tree outside
docs/ and the journal is untouched.**

### The new shape

**Five living documents, unversioned filenames, version on the stamp line inside:** Board
(v1.0 — the orientation, replacing the seed), Glossary (v2.2), Architecture (v3.1, carrying
Theory and Computable Share), Model & Flow (v1.0, absorbing the field tables), Charters
(v2.0 — charter design v1.8 + scope resolver v0.4 + account captures v0.2 + **the People
harness brief v0.2** merged, with the Process section newly written). Satellites sit outside
the audit chain; `aao-corrections-archive.md` (stamped v3.2) is filed as the audit trail.

**Deleted as superseded:** both corrections files (v3.0, v3.2 → archive), charter-design
v1.8, scope-resolver v0.4, ontology-captures v0.2, field-tables v0.13, both
projection-surface reads (→ the five), seed v5.0 (→ Board), and the versioned copies of
rebuttals, proof register, plan-to-QBR and demo-runsheet (→ their living-name replacements).

### Three verifications worth recording

**The demo-runsheet conflict dissolved on inspection.** The instruction said keep my v1.3
over the bundle's v1.2 — but the bundle's copy is **stamped v1.3 and byte-identical to
mine**, proof-register likewise. So the living-name copies are in and nothing was lost;
the premise was stale, not the instruction wrong. Checked with `cmp`, not assumed.

**`people-harness-brief` was named for deletion and has never existed in `docs/`.** It was
owed to me as a file and evidently went straight into Charters as v0.2 instead — the
Charters changelog says so. Nothing to delete; the two rulings it was carrying (rung
derivation, citation budget) are confirmed present: **recency owns the rung** when sides
conflict, and **quotes live on Answer rows only, the map note is an overwritable
current-state composite.** Both now sit in the Board's locked list.

**Six legacy files kept deliberately:** code-build-brief v1.1, corp-seed v1.0,
flags-and-guidance v1.1, and the three HTML visuals. Not in the deletion list, no bundle
replacement, so they stay — deleting unnamed files is how the corrections-v1.0 dangling
pointers happened. MANIFEST marks them legacy pending explicit retirement.

### Reported for the Board's next bump, not corrected by me

The Board (stamped 2 Aug) trails session 50 (~~4 Aug~~ **2 Aug — corrected in session 52;
the two are the same day, so the Board trails by hours on facts rather than by two days on
the calendar, and the finding below stands unchanged**) on four facts its own rules say to take
from this journal anyway: tests are **174**, not 171; the ontology seed is **56 records
across both scopes**, not 35 opportunity-side; and two of its open CODE items — the
account-side seed records and the Current state rewrite — are **done** (session 50). The
board wins on open-versus-closed, so its ledger should close those two at the next rewrite.

**Owed.** Unchanged: the People harness build (brief now in Charters §P7), then per the
Board's sequence. The account reading-set composition stays open and deliberately unguarded.

**Addendum, same session.** The bundle folder itself was inside the repo, so the restructure
commit tracked it — leaving two live copies of every document, the exact condition the
one-live-copy rule exists to prevent. `aao-bundle/` is removed in a follow-up commit now that
its contents are confirmed committed under `docs/`; the folder was the transfer packet, and
the packet's job is done once it lands. Verified before deleting: all five living documents
plus satellites present in `docs/` in the restructure commit.

---

## 2026-08-02 · session 52 · the second Current state block marked superseded, and the calendar corrected against the commits

**Did.** Repaired the journal head: one Current state block where there were two, the
preamble sentence closed, the phase-bound sentence marked rather than dropped. Corrected
thirty-three session-heading dates against commit timestamps. Rewrote `README.md`, which
pointed at five files that do not exist. **Nothing built, nothing deployed; `force-app/` is
untouched and no test ran, because no code changed.**

### The defect · session 50's rewrite landed above the heading instead of replacing what was under it

Session 50 recorded *Current state, rewritten from the org*. It wrote the new block, but
placed it between the file title and the `## Current state` heading, so the stale block
survived underneath. The join also broke the preamble mid-clause: *Append-only. The only part
ever rewritten is `## Current state* with the backtick never closed.

**This is worse than an ordinary staleness and the reading rules name why.** Retrieval
returns chunks that may not carry their source. A reader landing in the lower block found
seven objects, 128 tests, and *everything demonstrated so far rests on proposals authored by
hand* presented as current, with nothing in the chunk to say it had been retired two sessions
earlier. Both blocks read as authoritative because both were.

**Marked in place, folded shut, never deleted — and I got this wrong first and reversed it.**
My first pass deleted the stale block outright, reasoning that Current state is the single
documented exception to *wrong text is marked wrong, never deleted*, and that marking leaves
the retrieval hazard intact because a retrieved fragment carries no marker. **The context 22
queue ruled otherwise, explicitly: mark the stale 128-tests block SUPERSEDED in place, never
delete.** Reversed within the session, before any commit, by recovering the block from
`HEAD:BUILD_JOURNAL.md`. It now sits under a `## SUPERSEDED` heading that names every wrong
number in it, with the text itself folded inside a collapsed `<details>` block so a reader
meets the warning before the content. **The reversal is the right call and my reasoning had a
hole:** deletion optimises for the retrieval hazard and pays for it with an unauditable gap,
and the law exists because that trade has been made badly before in this project.

**What the superseded block claims, all of it wrong now:** seven objects and 136 fields, five
triggers, 128 AAO tests passing, the first model call at 99 tests, and the sentence
*everything demonstrated so far rests on proposals authored by hand*. Its live operational
facts were carried up into the new **Carried forward** section of the live block: the
`AAO Pipeline` tab and its `ed71d06` rollback point, the Gate 1 round-two commands and why
the passes are separate, `AAO_Discovery.exitTest()` and the pointer to session 12's discovery
spec, and the instruction to read sessions 4, 8, 9, 10 and 12 before quoting this build.

**The projection sentence is deliberately NOT marked yet.** The queue says mark *projection
into Altify's own objects is a later phase and nothing touches them yet* superseded **when the
harness lands, not before**, so it stands verbatim in the live block with a dated note beneath
it saying exactly that. The note beside it corrects the one sentence that is spent: *the
People projection writer waits on two rulings* is false, the citation budget having closed at
Charters §P7 v0.2 and the Political Status derivation at Charters v2.1.

### The calendar · commits are the runtime evidence, and the journal was two days ahead

The system clock reads 2 August 2026 while sessions carried headings dated 3 and 4 August.
Treated as a defect and evidenced rather than reasoned about. Author and committer timestamps
are identical on every commit, and all fifty-one sessions map one-to-one onto commits by
subject line.

| Sessions | Commit range read | Heading said | Corrected to |
|---|---|---|---|
| 1 – 2 | `4a7d7f4` … `2d7e7af` | 2026-07-30 | unchanged |
| 3 – 18 | `4b8b070` 08:10 … `4f49bd3` 17:58 | 2026-07-31 | unchanged |
| 19 – 27 | `133c814` 18:47 … `9619d4e` 20:50 | 2026-08-01 / 08-02 | **2026-07-31** |
| 28 – 49 | `fbe20b4` 09:08 … `38eeb57` 16:13 | 2026-08-02 / 03 / 04 | **2026-08-01** |
| 50 – 51 | `be1d4a7` 14:30, `51a2a56` 15:35 | 2026-08-04 | **2026-08-02** |

**Thirty-three headings corrected. The build ran across four calendar days, not six** —
sessions 19 through 27 were the same 31 July evening that produced sessions 3 through 18, and
sessions 28 through 49 were one continuous 1 August. The drift begins at session 19 and grows
to two days, which reads like a date typed from memory at a session boundary and then carried
forward rather than a timezone artifact: a timezone slip would be uniform, and this one
compounds.

**Two inline dates marked in place, since they sit in append-only bodies.** Session 24's
`AAO_Model_Config__mdt` describe was read on 31 July, not 2 August (`2c07de2`); the describe
table itself is untouched. Session 51's *the Board (stamped 2 Aug) trails session 50 (4 Aug)*
loses its two-day premise, since both fall on 2 August. **The finding it carried survives
unchanged:** the Board still trails on the four facts, now by hours.

**Left alone deliberately.** Session 30's *stale 30 July folder* and session 35's *the newest
`aao-context*.zip` is from 31 July* are observed filesystem mtimes, not session dates, and
both are consistent with the corrected calendar. Session 7's *31 July* for the first model
call was always right.

**What this moves.** The QBR countdown runs from the commits: today is Sunday 2 August, the
QBR is the week of 10 August, and the build has one more day than the journal's own headings
implied.

### The documents were right and this repo was wrong

Board v1.0, Charters v2.0, Architecture v3.1, Model & Flow v1.0 and Glossary v2.2 all stamp
2 August 2026, which the commits confirm. **The drift was mine alone.** `docs/MANIFEST.md`,
which CODE authors, said *Restructured 4 August 2026* and now says 2 August.

### README.md · four dangling pointers, the failure mode session 51 named

It still ordered a reader through `docs/aao-field-tables-v0_8.md`,
`docs/aao-flags-and-guidance-v1_0.md`, `docs/aao-corrections-v1_0.md` and
`docs/aao-code-build-brief-v1_0.md`. **None exist.** Two were absorbed into the five living
documents, one is archived as `aao-corrections-archive.md`, one exists only at v1.1 and is
marked legacy. Rewritten to the real chain: Board first, then this journal's Current state
and Handoff, then MANIFEST, then the Charters section for the work at hand, with the
read-the-stamp-never-the-filename rule and the numbers-from-the-journal rule stated on the
front page where a cold pickup meets them first.

### Reported, not corrected by me

**The Board is owed two fixes at its next rewrite, both design's to make.** Its §2 figures
still read 171 tests and 35 seed records against the org's **174** and **56**, and its two
CODE ledger items (account-side seed records, Current state rewrite) closed in session 50.
Its §1 gives every document path as `claude/aao-board.md` while this repo mounts them at
`docs/`; three parties now read the Board from three mounts, so the paths want naming per
environment.

**Owed.** Unchanged and unstarted: the People harness, opportunity-level, RM-only shape.
Design confirmed the sequence: **the harness starts once briefed, and the brief arrives after
Matthew corrects the Political Status table.** The exclusion-list experiment needs only a
legal Political Status value on the map row to observe Altify's recalculation, so a
not-derived fixed value would technically serve, **but nothing about Political is left to the
harness's discretion** — the brief will carry either the ratified derivation or the
fixed-value instruction explicitly. The account reading-set composition stays open and
deliberately unguarded.

---

## 2026-08-02 · session 53 · context 22 synced, the seed split measured, and the step 0 probe

**Did.** Synced context 22 (Board v1.1, Charters v2.1, CODE-INBOX). Confirmed the 56-record
seed split from the org. **Ran the step 0 probe, and it corrects the brief's own assertion in
two ways.** Nothing built: per §P7.2 the probe result lands here before step 1 starts, and
step 1 is blocked on org access. **No code changed, no test run.**

### The sync

Board **v1.1** and Charters **v2.1** in; Architecture, Glossary and Model & Flow byte-identical
to my copies and left alone (`cmp`, not assumed). `CODE-INBOX.md` filed in `docs/`.
**`aao-demo-runsheet.md` deliberately absent from the zip and untouched here: mine is v1.3,
the project's is v1.2, and the queue says do not regress it.** Verified still v1.3 on disk.
Owed back to the project: v1.3's body through Matthew.

### Queue item 4 · the 56-record split, read from the org and not from any document

`SELECT ... FROM AAO_People_Question__mdt` returns **56**, and the Board's 35/21 is confirmed
— but the number that matters for building is a different one, so both are recorded here and
neither floats.

**By load generation, which the `AAO_Provenance__c` field now makes queryable:**

| Provenance | Count | What it is |
|---|---|---|
| null (reads as `Label`) | **35** | Session 49's opportunity-map load |
| `Label` | 16 | Session 50's account-map label-sourced records |
| `UI_Capture` | 5 | Decision Orientation, no label behind it |
| | **56** | **35 / 21, the Board's figure, confirmed** |

**By what the readers actually return, run from Apex against the org:**

```
AAO_PeopleOntology.read('OM') -> 19    AAO_PeopleOntology.read('AM') -> 12
overlap between them          -> 0     Limits.getCallouts() after both -> 0
AAO_PeopleOntology.customised() -> 0   (no org has overridden anything)
```

**The 19 matches session 49 exactly** and LAW #1 holds under measurement, not assertion: two
full scope reads, zero callouts, and the same query returns the ontology in an org that never
had Altify installed.

**The two splits are not the same split, and this is the finding.** By key prefix the seed is
7 account-only (`AM_`), 3 opportunity-only (`OM_`), **16 shared (`AM_OM_`)**, and 30 carrying
no scope in the name (16 opportunity-side insight help text, 9 account-side `_AM_` insight
help text, 5 Decision Orientation). **The 16 shared records are read by `OM` and by nothing
else: the AM read returns 12 and its overlap with OM is zero.** So "35 opportunity-side"
means *the 35 records session 49 loaded*, not *the 35 records the opportunity map reads*, and
"21 account-side" means *records added for the account map*, not *what an account pass reads*.
An account pass today reads **zero** of the sixteen questions whose own names say they belong
to both maps.

**That is session 50's open item, now measured rather than described:** the account
reading-set composition is unruled, so the guard covers exactly what was seeded and named and
refuses to invent a composition nobody authored. Still open, still deliberately unguarded, and
now with a number on it.

### Queue item 5 · STEP 0 PROBE · one API-written map row, and what the package did

**Probe row:** `a0eWD000003mi9tYAA` on `AAO Discovery - Derived Contracts`, contact Priya
Shah, note `AAO STEP 0 PROBE - safe to delete`. Deliberately not the demo spine, and
deliberately not `AAO Demo - Live111`, where Matthew created his own map row three minutes
earlier while working the related-list task in parallel. **His row was read and not touched.**

**1 · The package accepts an API-written map row.** Insert succeeded first try. No validation
rule, no trigger refusal, no required field beyond the three parents.

**2 · A package trigger fires on insert and populates `ALTF__AltifyId__c`** with
`00DWD00000DV7iT2AT-a0eWD000003mi9tYAA`, org id and record id joined. **We do not write it and
must not.**

**3 · The four "recalculated" fields are formula fields, and this is the significant finding.**
`ALTF__Is_Key_Player__c`, `ALTF__Squares__c`, `ALTF__Color__c` and `ALTF__ConcatenatedFields__c`
all describe as `calculated=true, updateable=false`. Read verbatim from the org:

```
ALTF__Is_Key_Player__c = IF((ISPICKVAL(ALTF__Political__c, "Political Structure")
                          || ISPICKVAL(ALTF__Political__c, "Inner Circle")), true, false)

ALTF__Squares__c       = MIN(6, CASE(ALTF__Status__c, "Mentor",2, "Enemy",2, "Supporter",1,
                          "Non-Supporter",1, "Neutral",0, "Unknown",0, 0)
                          + CASE(ALTF__Political__c, "Inner Circle",2, "Political Structure",1,
                          "Unknown",0, "Outside Political Structure",0, 0)
                          + CASE(ALTF__Buyer_Role__c, "decision maker",2, "approver",2,
                          "evaluator",1, "user",0, "other",0, 0))

ALTF__Color__c         = IF(ISPICKVAL(ALTF__Status__c,"Mentor"),"green", ... "grey")
```

**There is no recalculation to wait for.** Same-row formulas evaluate at query time. Observed:
`asyncCalls=0` in both probe transactions, and a re-read in a later transaction found every
value exactly as left, with nothing having moved in between.

**4 · The exclusion-list experiment as written in §P7.2 cannot pass, and should be restated.**
The brief asserts *project Political, let Altify recalculate, re-read; Is Key Player must move
and nothing else.* Measured:

| Wrote | Is_Key_Player | Squares | Color | Other stored fields |
|---|---|---|---|---|
| `Political` Unknown -> Inner Circle | false -> **true** | 0 -> **2** | grey (still) | none moved |
| `Status` Unknown -> Supporter | true (still) | 2 -> **3** | grey -> **half_green** | none moved |

**Is Key Player moves, and so does Squares.** Both are pure functions of the same picklists on
the same row, so a Political write necessarily moves Squares too, and there is no exclusion
list that could prevent it. **Proposed restatement, design's to rule:** *writing one dimension
moves that dimension's own `_Last_Modified` stamp and no other stamp; the derived formula
fields move as pure functions of the dimension picklists on the same row; no stored field we
did not write changes, and no automation fires.* That is checkable, and it passed as measured.

**5 · The package maintains per-dimension `_Last_Modified` stamps on API writes, by itself.**
This is the watermark substrate and we do not have to build it:

```
after insert       pol=22:47:43  status=22:47:43  role=22:47:43  coverage=null
after Status write pol=22:47:43  status=22:48:16  role=22:47:43  coverage=null
```

**Writing Status moved the Status stamp and only the Status stamp.** Coverage, never written,
stayed null rather than defaulting to a time. Per-dimension precedence and the human-edit
watermark both have a real substrate here, package-maintained, on API-written rows.

**6 · `ALTF__Political_Answer__c` stayed null** and `ALTF__Note__c` survived both writes
untouched. The package did not populate, clear, or reformat anything we wrote.

**Assumed, not verified.** Whether the package's UI path does more than its API path (the UI
may run wizard logic no trigger reproduces); whether `_Last_Modified` stamps behave the same
under bulk DML; whether a package upgrade changes any of the above. None of these are needed
by the harness as briefed.

**Owed.** The probe row is still in the org, labelled, on the Discovery deal. **Left rather
than deleted** because it is evidence for this entry and deleting data is not mine to decide;
one line from Matthew removes it.

### Blocker · step 1 cannot start · reported through Matthew, per the brief

**§P7.2 step 1 requires Black & Veatch pulled from production, read-only. No Altify production
org is authenticated on this machine.** `sf org list`, verbatim in substance:

| alias | org | sandbox | status |
|---|---|---|---|
| `aossb2` | Altify (sandbox) | yes | Connected — our target |
| `altify-pbo` | LessFeatures | no | Connected — **never read, standing law** |
| `altify-dev` | GRM TEK Corp | no | Connected — Developer Edition, not Altify prod |
| `ice` | ICE Mortgage Technology | no | **auth failed**, refresh token rejected |

**Black & Veatch is not in the sandbox either** (`SELECT Id,Name FROM Account WHERE Name LIKE
'%Veatch%'` returns nothing), so there is no local shortcut. Production auth needs Matthew at
a browser, and this session cannot run the OAuth flow. **Nothing was attempted against
`altify-pbo` or any org outside the target.**

Steps 2 and 3 depend on step 1's fixture and on the Casey transcript, which is not in the
repo. **Everything in the queue that does not need production is done.**

**Owed.** Production authentication and the Casey transcript, both Matthew's. Then step 1
seeder, step 2 run, step 3 assertions, per §P7.2 unchanged.

---

*Sessions 54 and 55 below were written to stray `BUILD_JOURNAL.md` files inside
`seed/bv-fixture/` and `seed/transcripts/bv-biweekly/`, because the shell's working directory was
inside those folders when the append ran. They never reached this file and the sequence read
53 -> 56 for six sessions. Spliced back into place in session 69, unedited, before the first
commit that would have preserved the hole. The stray files are deleted; this journal is the one
live copy.*

---

## 2026-08-02 · session 54 · context 23 synced, the B&V fixture verified against its manifest

**Did.** Synced context 23: Charters **v2.2** and the CODE-INBOX addendum. Landed the B&V
fixture and verified every claim its manifest makes before loading anything. **Nothing loaded,
nothing built, no code changed.** The load is ready to fire and is held on two questions below.

### The sync

Charters **v2.2** in; Board v1.1, Architecture, Glossary and Model & Flow byte-identical to my
copies (`cmp`) and left alone. Demo run sheet still absent from the zip and still v1.3 here,
unregressed. Fixture placed at **`seed/bv-fixture/`**, not `docs/`: `docs/` is the design
corpus the MANIFEST governs and five JSON payloads are not design documents. `seed/` already
exists for exactly this and holds `transcripts/`, `expected/` and `rubric/` beside it.

**§P7.2's exclusion-list assertion is corrected at v2.2 and my restatement was ratified
verbatim**, with the probe's positive findings carried in beside it. The prod-auth blocker
from session 53 is closed by the addendum: I never get production, design pulled the extract
read-only from org `00DHn000006jYatMAE` (IsSandbox false, verified before reading).

### The fixture, verified rather than trusted

Every count the manifest states, confirmed on arrival:

| File | Manifest | Read | |
|---|---|---|---|
| `accounts.json` | 3 | 3 | OK |
| `opportunities.json` | 6 | 6 | OK |
| `contacts.json` | 46 | 46 | OK |
| `opportunity_contact_roles.json` | 125 | 125 | OK |
| `users_reference.json` | 8 | 8 | OK |

**Referential closure is complete and was checked, not assumed.** Every `ReportsToId`,
`Contact.AccountId`, `Opportunity.AccountId`, `Role.ContactId` and `Role.OpportunityId`
resolves inside the fixture. Zero dangling references. **The ReportsTo tree has no cycles**,
four roots (Mario Azar CEO, Patrick O'Neill, Lisa Carter, David Park CFO) and a maximum depth
of four, so a two-pass load is sufficient and a dependency-ordered single pass is possible.

**The opportunity shape matches the brief's requirement:** four open (two Casey Lindlaw
renewals at Stage 3 closing 2028-03-31, two Renee Martin expansions at Stage 1) and two
closed-won under Chris Day, which is the owns-something traversal shape. Roles distribute
20 / 19 / 44 / 3 / 19 / 20 across the six, summing to 125. The four `Approver` and
`IsPrimary=true` rows are Joy Johnson twice and Patrick Hogan twice, exactly as stated.

**The three byte-exact anomalies are present and will be loaded verbatim** per the paraphrase
law: `'Steffanie Edwards HÃ¤fele'`, `'Patrick Oâ€™Neill'`, and the title truncated mid-word at
`'...South Central United States and Latin Americ'`. The identity matcher should see what
production actually contains.

Contacts hang 44 off Black & Veatch and 2 off Slalom, which is why the manifest orders Slalom
first. Email is populated on 29 of 46, phone on 28, mobile on 26, title on all 46.

### The owner remap is nearly an identity map, and the manifest did not know that

The manifest says remap every OwnerId deliberately and keep the role pattern. **Read from the
sandbox: every prod user id in the fixture already resolves there, same id, same role**, because
`aossb2` is a refresh of the same production org.

| Fixture owner | Sandbox | Role in sandbox | Action |
|---|---|---|---|
| Casey Lindlaw `005Hn00000Iyk38IAB` | active | Customer Success Manager | **no remap** — owns the two renewals, pattern intact |
| Renee Martin `005Hn00000Iyk1MIAR` | active | Account Executive | **no remap** — owns the two expansions and the account |
| David Nguyen `005Hn00000JHb6FIAT` | active | CEO | **no remap** — account owner |
| Wendy Higley `005Hn00000JHb1PIAT` | active | VP Sales | **no remap** — account owner |
| **Chris Day** `005Hn00000JHb1FIAT` | **INACTIVE** | Account Executive | **must remap**, owns both closed-won |

**Keeping the ids is the strongest possible reading of *keep the role pattern*:** the pattern
is not merely preserved, it is the original. Only the inactive owner forces a change.

**Two findings the manifest did not carry.** Chris Day is inactive **in the sandbox as well as
prod**, so the remap is required rather than precautionary. And `accounts.json` references
**Wendy Higley, who is not among the eight in `users_reference.json`** — harmless, because she
resolves and is active, but the reference file is one short of the owners the fixture actually
uses.

**Proposed Chris Day remap, Matthew's to veto:** an active Account Executive who owns nothing
else in this fixture, so the shape *a different AE owned the historical closed-won deals*
survives rather than collapsing into Renee. Candidates read from the org: John Van Schaick
`005V400000KurfdIAB` or Jennae Jizdeortega `005Hn00000JHb1eIAD`. **Defaulting to John Van
Schaick unless told otherwise**, recorded here so the choice is visible rather than buried in
a load script.

### Held, not decided · the fixture is real customer PII and this is a git repository

`contacts.json` holds 46 real Black & Veatch people with real emails, phones, mobiles, titles
and reporting lines; `accounts.json` holds revenue and headcount. **Charters §P7.2 step 1
item 5 accepts real PII in the sandbox org where model calls run, and that decision is
recorded. It does not rule on committing that payload to this repository**, which is a
different and permanent exposure: git history does not forget, and the handoff section exists
precisely because this directory is expected to move to other machines and people.

**Defaulted conservative and reversible:** `seed/bv-fixture/*.json` is gitignored with the
reasoning written into `.gitignore` itself. The files are on disk and load normally. The
manifest beside them carries no contact details and is tracked. **One line from Matthew
reverses this in either direction.**

**Owed.** Matthew's ruling on committing the payload; the Chris Day remap confirmation or
veto; and the Casey transcript, which arrives separately and enters through the front door as
a Source, never as fixture data. Then step 1 loads under the probe-first rule (one Opportunity
inserted and read before bulk), counts verified after rather than insert success.

---

## 2026-08-02 · session 55 · context 24: the transcript arrives, and the occurred clock is unblocked

**Did.** Synced context 24. Verified the transcript against its SHA-256 and its manifest
against the fixture and the transcript's own bytes. **The date blocker is closed.** Nothing
loaded, nothing built, no code changed. Step 1 is now unblocked in full.

### The sync · one file changed and one arrived

`CODE-INBOX.md` (addendum 2) is the only changed document. Board v1.1, Charters v2.2,
Architecture, Glossary and Model & Flow are byte-identical to my copies, and **so are all five
fixture JSONs and the fixture manifest** (`cmp`), so context 24 re-ships the fixture without
drift. Nothing to re-verify there and nothing regressed. Demo run sheet still absent and still
v1.3 here.

Transcript filed at **`seed/transcripts/bv-biweekly/`** beside its manifest and hash, under the
`seed/transcripts/` directory that already existed for exactly this.

### The date blocker · CLOSED, and the inbox contradicts its own manifest

**CODE-INBOX addendum 2 says the call date is still owed.** The transcript manifest, which is
more specific and carries the evidence, says the opposite and supplies it:

> **Call started: 24 June 2026, 7:01 AM. Duration per the platform record: 40:35.**
> Supplied by Matthew from the prod ECI VideoCall record `6qrV4000000JRMHIA4`.

**The manifest wins and the occurred clock is unblocked.** Recorded rather than silently
resolved, because the two documents in one zip disagree and a later reader deserves to know
which was followed and why. Last transcript stamp reads **40:17**, consistent with a 40:35
platform duration and a silent tail, so no words are missing from the end.

**The ECI stamp is recorded as one input and not the answer**, per the resolver law on ECI
stamps. Its Owner is Casey Lindlaw and its `RelatedRecordId` points at B&V Community
Licenses-150, which happens to agree with the manifest's suggested given deal. **Agreement is
noted, not leaned on**; the harness takes the deal as given from config, and the Board's
standing hazard already says ECI's related-record stamp is inference and unstable.

### Verification of the payload, all measured

**SHA-256 matches at packaging and again after the copy into the repo:**
`dc073f0594bac39bdae9db0bd497c423d143a42fb69a92c1a60b5cd8c9f5c363`. **These bytes are the
frozen artifact.**

**Shape:** 1,955 lines, 46,552 bytes, **489 utterances**, first stamp 00:14, last 40:17.

**Four speakers, exactly the four the manifest names**, with utterance counts read from the
file: Ashley Stroud 151, Renee Martin 147, Adam Meloan 135, Robbin Jones 56.

**Every person the manifest claims is in the fixture, is:**

| Claim | Result |
|---|---|
| Three external speakers exist as contacts with these exact names | Ashley Stroud, Adam Meloan, Robbin Jones — **all three present** |
| Seven named non-participants present | Steve Sienkiewicz, Chris Perrey, Elizabeth Enneking, Jason Baker, Matthew Raven, Brian Limpic, Patrick Hogan — **all seven present** |
| Renee Martin is the seller, not a contact | **Confirmed:** she is a User, absent from the contact set |
| Suggested given deal `006V400000TRBxyIAH` | **Present:** B&V Community Licenses-150, Stage 1, owner Renee Martin |

**The packaging decisions hold up under inspection.** Viewer chrome is gone: zero hits for
`Move the player`. **Nothing was normalized**, and the manifest's own examples are all present
in the bytes: `Joo.`, `They need falls.`, `Thank you, Mom.`, `the MB`, `Lempick`, `BNV`, `SKL`,
`Chris Perry`, and `Robin` in speech against `Robbin Jones` in the labels. **A normalized quote
would be a paraphrase**, so this matters more than it looks. No blank speaker labels, no
malformed stamps.

**Assumed, not verified.** That stripping the chrome lines does not change any span offset we
would have wanted against the chrome-inclusive raw. It cannot, because these bytes are the
frozen artifact and nothing byte-verifies against a file we do not hold — but if the
chrome-inclusive raw is ever made the artifact instead, **every span in this run is invalidated
and the run repeats.** The manifest offers that swap and it is superseded-not-edited if taken.

### The organizer/owner split is live in this call, and is not ours to resolve today

**Casey Lindlaw organizes the bi-weekly series and is absent from this instance** (traveling for
the T-Mobile launch, said on the call); **Renee Martin ran it.** The scope resolver's Test 1
reads the owner-organizer's role, so this is exactly the two-key case the resolver exists for.
**The People harness takes the deal as given and asserts no scope routing**, per §P7.2 and the
transcript manifest both. Recorded because it is real evidence sitting in the fixture for the
later resolver harness, not because anything today acts on it.

**The speaker-rank note is a live prediction, not decoration.** Renee is the seller and her
words downgrade structurally. Reported-speech density is high — what Steve wants, what Matt
asked for, what Pat asked at SKO — which is precisely the Subject_Person material Gate 1
records as the over-read failure mode. **Expected failure is over-reading, never fabrication**,
and the blind reader is the check.

### Held, unchanged · the PII ruling now has one more input

The transcript is a real recorded customer conversation and is the same class of exposure as the
fixture, so it is untracked on the same pending ruling. **One difference, and it cuts the other
way:** this file is the frozen artifact, so while it stays untracked **a clean checkout cannot
reproduce a replay without the file being supplied again.** The fixture is convenience; the
transcript is load-bearing for reproducibility.

**Split the difference where it can be split:** `bv-biweekly-transcript.sha256` and the manifest
**are tracked**, so a fresh checkout can prove a supplied copy is the exact artifact the claims
were verified against, without the repository carrying the words. Reasoning written into
`.gitignore` itself so it reads as a decision rather than an omission.

**Owed.** Matthew's ruling on committing the payloads; the Chris Day remap confirmation
(defaulted to John Van Schaick `005V400000KurfdIAB`, an active AE owning nothing else in this
fixture, so *a different AE owned the historical closed-won* survives). **Nothing else blocks
step 1.**
---

## 2026-08-02 · session 56 · step 1: the B&V fixture loaded, and the probe says Altify builds nothing

**Did.** Loaded the B&V fixture into `altify--aossb2` per §P7.2 step 1 and the fixture
manifest. **3 accounts, 46 contacts, 6 opportunities, 125 contact roles, all verified by
reading the org afterwards rather than by trusting insert success.** The one-record probe ran
first and returned a finding worth more than the load. **No code was written and no test was
run: this is data, not build.**

**Matthew's two rulings, both applied:** the PII split is ratified as designed (payloads
untracked, manifests and hashes tracked), and Chris Day remaps to **John Van Schaick**
`005V400000KurfdIAB`.

### The probe · §P7.2 step 1 item 2 · what Altify does on an API-inserted Opportunity

**It does nothing. Nothing at all.**

Method, because the answer is a negative and a negative is easy to fake: enumerated every
`ALTF__` custom object in the org (**82** after excluding ChangeEvent, Share, History, Feed and
Tag), took a timestamped baseline, inserted **one** Opportunity (`B&V Community Licenses-150`,
the harness's own given deal), then counted rows created since the mark across all 82. **Zero.**
Re-ran on a wider window to catch anything asynchronous. **Still zero.**

**Nine ALTF objects carry an Opportunity lookup and could have received a row**, which is what
makes the negative meaningful rather than vacuous:

```
ALTF__Account_Opportunity__c      ALTF__Insight_Section__c
ALTF__Contact_Map_Details__c      ALTF__Object_Relationship__c
ALTF__Decision_Criteria__c        ALTF__Opportunity__c
ALTF__Insight_Card__c             ALTF__Relationship_Map_Persona__c
ALTF__Log__c
```

**`ALTF__Opportunity__c` is the one to notice.** Altify's own per-opportunity record, the
scaffolding you would most expect a package to create on insert, **was not created.** No
qualifier scaffolding, no assessment shell, no map rows, not even a log line.

**What this means for the product, and it is a product truth rather than a fixture detail.**
The Altify surface is built lazily, by the UI or by an explicit action, never by the mere
existence of an Opportunity. **So our projection cannot assume any ALTF scaffolding exists on a
deal**; on a deal nobody has opened in Altify, the map rows we write may be the first ALTF rows
that deal has ever had. That is consistent with the standing hazard that ~80% of installs carry
no methodology history, and it means graceful absence is the normal path and not the edge.

**One trap avoided, recorded because it nearly scored the probe wrong.** The baseline showed
nine `ALTF__Log__c` rows in the preceding ten minutes and it would have been easy to read them
as the package reacting to my inserts. They are **Matthew's**, created about one a minute by
`Matt Weisberg` while he worked the Contact Map Details related list in the UI in parallel.
~~Attributed by `CreatedBy` before drawing any conclusion.~~ **THE METHOD IN THAT STRUCK
SENTENCE IS WRONG AND SESSION 57 PROVES IT: `CreatedBy` cannot distinguish me from Matthew,
because this CLI authenticates as `matt.weisberg@altify.com.aossb2`, user
`005V400000MCTUbIAP` — the same user record Matthew works the UI as.** The conclusion happens
to survive on other evidence: those log rows carry `ALTF__Opportunity__c` values pointing at
`AAO Demo - Live111` and the Discovery deal, never at any B&V record, so they are not my load.
**Right answer, unsound method, and the unsound method is the part worth remembering.**
**A concurrent human in the same org is a live confounder for every before-and-after
measurement in this harness**, and attribution must be by *what the row points at*, never by
who created it.

### The load · the seven verification lines, answered in order

**1 · Owners remapped deliberately, and the remap was almost an identity map.** Every prod owner
id resolves in the sandbox with the same id and role, so the role pattern is not merely
preserved, it is the original. Only the inactive owner needed changing. Read back from the org:

| Opportunity | Owner | Role | |
|---|---|---|---|
| both March-2028 Renewals | Casey Lindlaw | Customer Success Manager | kept |
| both expansions | Renee Martin | Account Executive | kept |
| both Closed Won | **John Van Schaick** | Account Executive | **remapped from Chris Day** |

Accounts: B&V Customer to Renee Martin, B&V Parent Account to David Nguyen, Slalom to Wendy
Higley. **The shape the resolver should eventually see is intact: a CSM owns the renewals, an
AE owns the expansions and the account, and a different AE owns the historical closed-won.**

**2 · One-record probe before bulk.** Done, above, before the other five inserted.

**3 · Counts verified after, not insert success.** Read from the org:

```
accounts 3/3    contacts 46/46    opportunities 6/6    contact roles 125/125
ReportsTo chains rebuilt 42/42
roles per opportunity 20 · 19 · 44 · 3 · 19 · 20 = 125, matching the fixture exactly
```

**4 · Stage and record-type fidelity.** `Stage 1`, `Stage 3` and `Closed Won` all survived, and
`IsClosed`/`IsWon` derived true on both closed-won. Types `Expansion`, `New Customer` and
`Renewal` survived. Picklist validity was checked against the sandbox **before** loading, not
discovered during it. Amounts and close dates intact, including 2028-03-31 on both renewals.

**5 · Real emails accepted deliberately.** Loaded as supplied: email on 29 of 46, phone on 28,
mobile on 26. The decision is §P7.2's and is recorded there and here.

**6 · The never-written law, distinguished and not breached.** This seeder wrote Accounts,
Contacts and Opportunities once, at fixture time, in a sandbox. **That is scaffolding.** The
product's runtime still never writes Opportunity or Account, and nothing in this load ran
through the product.

**7 · Multi-opportunity fixture is future-proofing and nothing here asserts routing.** Six
opportunities exist so the later scope-resolver harness has the which-opportunity problem to
solve. **Today's harness takes the deal as given.**

**Byte-exactness held through insert and was proved by reading back out of the org**, not by
trusting the write. All three anomalies survive with their codepoints intact:
`'Steffanie Edwards HÃ¤fele'` (`0xc3 0xa4`), `'Patrick Oâ€™Neill'` (`0xe2 0x80 0x99`), and the
title still truncated mid-word at `'...South Central United States and Latin Americ'`. **A
normalized name would have been a paraphrase and the identity matcher would have been tested
against a fiction.**

Slalom loaded before contacts as the manifest ordered, and both contacts parented to it
correctly (McKayla Allinder, Ethan Putman) rather than falling back to B&V. The four
`Approver` + `IsPrimary` rows survived: Joy Johnson and Patrick Hogan, twice each.

**Method note.** Loaded through the REST `composite/sobjects` collection endpoint with
`allOrNone=true`, which returns ids in request order, so the prod-to-sandbox mapping is captured
at write time rather than reconstructed by matching on names afterwards. **Matching on names
would have been unsound here precisely because two accounts share the name `Black & Veatch`.**

**Manifest item 6, paid:** `seed/bv-fixture/idmap-prod-to-sandbox.json`, 55 pairs, so the
adjudication can name records across both orgs. It holds Salesforce ids only, no names or
contact details, and is untracked under the ratified PII split because it lives in the payload
directory; **say the word if it should be tracked, since it is arguably integrity rather than
payload.**

### State of the org after this load

The three AAO demo deals and the Gate 1 deals are untouched. Matthew's own map row on
`AAO Demo - Live111` is untouched. The step 0 probe row from session 53 is still on
`AAO Discovery - Derived Contracts`, still labelled, still awaiting one word to remove it.
**No `ALTF__Contact_Map_Details__c` row exists on any B&V opportunity, which is the point:
building that surface is the product's job and watching it do so is the test.**

**Owed.** Step 2, the run: the Casey transcript through the front door as a Source with the
occurred clock at **24 June 2026, 7:01 AM**, People charter only, every other charter's
contracts unhanded, then the temporary `AAO_TEMP_` projection invoker. Then step 3's mechanical
assertions and the output surface for Matthew's adjudication.

---

## 2026-08-02 · session 57 · Altify builds the map surface itself, off contact roles

**Did.** Applied Matthew's two rulings. **Then found that the fixture load had already caused
Altify to build the entire B&V map surface — 125 empty `ALTF__Contact_Map_Details__c` rows —
and traced the cause.** This changes what step 2's projection does, so it is recorded before
step 2 starts rather than discovered inside it. **No code written, no test run.**

### The two rulings, applied

**PII split:** `idmap-prod-to-sandbox.json` is now tracked; it is integrity, not payload, and
holds Salesforce ids only. The `.gitignore` carries a negation with the reason on it.
**Probe row:** the session 53 step 0 row on `AAO Discovery - Derived Contracts` is deleted.
Matthew's own row on `AAO Demo - Live111` was not touched.

### The finding · a contact role creates a map row, synchronously, one for one

After the load the org held **126** map rows where it had held one. Measured rather than
assumed:

| Check | Result |
|---|---|
| Map rows on B&V opportunities | **125** |
| Contact roles on B&V opportunities | **125** |
| Identical `(contact, opportunity)` pair sets | **true** — zero map-only, zero role-only |
| Map row created in the same second as its contact role | **125 of 125** |
| Distribution across the six deals | 44 · 20 · 20 · 19 · 19 · 3, the contact-role distribution exactly |

**`OpportunityContactRole` insert is the trigger. Not Opportunity insert.** Session 56's step 0
finding stands and is unchanged, but it is narrower than its own wording suggested: **nothing
fires on an Opportunity insert** — that was measured across all 82 ALTF objects — and something
very much fires on a contact role insert. The probe asked the right question about the wrong
object, and only loading the rest of the fixture exposed it.

**Every one of the 125 rows carries null `ALTF__Status__c` and null `ALTF__Political__c`.**
Altify builds the skeleton and populates nothing.

### The attribution error in session 56, and why it matters more than the finding

Session 56 said the baseline log rows were Matthew's, **attributed by `CreatedBy`**. **That
method is invalid.** This CLI authenticates as `matt.weisberg@altify.com.aossb2`, user
`005V400000MCTUbIAP`, **which is the same user record Matthew works the UI as.** `CreatedBy`
cannot separate us, and for a while I read 125 machine-created rows as a human typing in a
browser.

The session 56 conclusion survives on other evidence: those log rows carry
`ALTF__Opportunity__c` pointing at `AAO Demo - Live111` and the Discovery deal, never at a B&V
record, so they were not my load. **Right answer, unsound method.** Marked in place in session
56 rather than rewritten. **Attribution in this org is by what a row points at, never by who
created it**, and that now binds every before-and-after measurement in this harness.

### What this does to §P7.2 step 2, stated before building against it

The brief says: *No map rows are seeded; building the map surface is the product's own job and
watching it do so is the test.* **No map rows were seeded — I inserted native parents only, as
briefed. Altify created the surface itself, off native contact roles.** The letter of the
brief holds. Its expectation does not, and the difference is load-bearing:

**Projection is now a populate, not a create.** For every person who holds a contact role on
the given deal, a map row already exists, empty, waiting. Our writer updates rather than
inserts, which is why the step 0 probe's per-dimension `_Last_Modified` finding matters so
much: those stamps are how a populate stays honest about which dimension it touched.

**But the writer cannot only populate.** A person who appears in the transcript and holds no
contact role has no row, and the ontology's whole point is that evidence introduces people the
CRM has not caught up with. **So the writer must handle both, and upsert is the honest shape:
populate where Altify built a row, create where it did not.** Recorded as a design consequence,
not a ruling; design's to confirm.

**This is also the realistic state and arguably better than the brief assumed.** A real
customer org has contact roles, so a real org has this skeleton. Watching Altify build it off
native data is a truer test than watching our product build it from nothing.

### Standing questions this raises, not answered here

Whether Altify's automation also *deletes* or re-parents map rows when a contact role is
removed, and whether it reacts to contact role *updates*. **Not probed**, because nothing in
step 2 depends on it and probing it means mutating fixture data the run is about to use.
Named so a later harness can measure it rather than assume either way.

**Owed.** Step 2 unchanged in scope: the Casey transcript through the front door as a Source,
occurred clock 24 June 2026 07:01, People charter only, then the temporary `AAO_TEMP_`
projection invoker draining into upserts on the 125-row surface that now exists.

---

## 2026-08-02 · session 58 · the Pipeline command center, built to spec v1.0

**Did.** Rebuilt `AAO_PipelineViewController` and the `aaoPipelineView` bundle to command-center
spec v1.0. **Items A through H and J are built. Item I is built except for one sub-item that
requires a schema change, which the spec forbids, so it is reported instead of guessed.**
**186 tests, 186 passing** (was 174; the view's own class went from 5 tests to 17).

### The one thing I stopped and reported rather than building · spec item I

The spec said the account-grain predicate must come from the built scope fields, and to stop
rather than guess if it is ambiguous. **It is not ambiguous. It is absent.**

| Object | `AAO_Account__c` | `AAO_Opportunity__c` |
|---|---|---|
| `AAO_Source__c` | required | **required** |
| `AAO_Candidate__c` | required | **required** |
| `AAO_Claim__c` | required | **required** |
| `AAO_Answer__c` | required | **required** |
| `AAO_Flag__c` | required | **required** |

`<required>true</required>` on the opportunity lookup of all five, and `AAO_ScopeKey.compose`
independently confirms it: it throws on a null scope and composes from the opportunity id
alone. **No row can carry account grain, so an account-scope group would render empty on every
account forever.** Making the lookup nullable is the schema change the Model & Flow head
amendment already contemplates ("Source's opportunity lookup goes nullable under a scope family
law") and it is not mine to make here.

**What I built instead of an empty box:** the account context is fully live (filter on
`AAO_Account__c`, per-deal headers, a scope column on every row), and it carries a sentence
saying account-grain rows cannot exist yet. **An empty group implies the query found nothing;
a sentence says the shape does not exist. Those are different claims and only one is true.**

### Built, item by item

**A · links.** `NavigationMixin.GenerateUrl` on every id the controller returns, resolved **once
per distinct id** and cached across polls, so a 200-row panel does not fire hundreds of calls
per tick. Anchors carry `target="_blank" rel="noopener"`. Sources, claims, answers, flags, flag
subjects, people, deals, candidates' latest pass, cited rows, map rows and the banner's artifact
all link. The claim row links its Source ref as asked. **The one-place-decides-colour principle
is untouched:** Apex still returns finished class strings and the component still concatenates
nothing.

**B · lineage, walkable, depth one.** Claims expand to the Candidate they came from (with what
it proposed), their Claim Basis citations (cited type, link, `Covers_Element`, and a
cited-row-deleted badge), and the Answer they moved. Answers expand to every Claim behind them
in occurred order. **Apex builds the nested model in two extra bounded queries**; the component
holds only which rows are open. That set lives on the component rather than the payload, because
the payload is replaced every two seconds and a poll would otherwise close whatever was being
read mid-run.

**C · projection is real and the hardcoded sentence is dead.** Queries answers with
`AAO_Projected_Value__c != null`; renders value, `Projected_Modstamp`, linked subject person, and
the target map row resolved by subject contact plus opportunity. The `off`/`live` badge and the
greyed panel both derive from whether rows exist. Empty state is now *"No projections yet on
this record."* **The old prose claimed projection was "not built" and "nothing has been written
back to any customer record" — step 2 falsifies both, and a fixed sentence that goes false is
worse than no sentence.** Where no map row resolves for a projected person, the row says so in
red rather than rendering a blank.

**D · flags have rows and no blinders.** All six types, not just `Methodological`: type badge,
state badge, linked subject, raised stamp, standing then escalated then cleared. **The People run
raises contention flags and the old panel could not have shown them.**

**E · people made visible.** Answers group under their subject person, person header linked,
dimensions beneath. Dimension comes from `AAO_PeopleOntology.dimension()` on the proposition
code; a non-People contract returns null and renders nothing. **The rung is the projected value
and nothing else** — a screen that derived its own rung would be inventing an answer the
projection writer never wrote. Answers with no person land in a last bucket that explains itself.

**F · publication honesty.** Held answers render at half opacity and greyscale with a `HELD`
badge, are excluded from the live count, and are **never hidden**. Header reads `N live · M
held`. View-level only; no other reader was touched.

**G · two clocks, labelled.** Occurred and recorded both render `d MMM yyyy HH:mm GMT`. **The
07:01 call cannot render as a bare date any more**, which the old `formatGmt('d MMM yyyy')` did.
Header reads `snapshot HH:mm:ss (local) · d MMM yyyy`. No unlabelled timestamp survives.

**H · scale guards.** `LIMIT 200` on sources, claims, answers and flags, each with a true total
from a `COUNT()` and a `showing 200 of N` line. **A silent cap reads exactly like completeness**,
which is why the total is queried separately rather than inferred from the page.

**J · run banner.** Newest pending artifact, linked, with stage `arrived` / `adjudicating` /
`committed` / `idle`, spinner while pending, last-refreshed stamp. Adaptive 2s/10s poll unchanged.

### Three laws caught my test fixtures, and all three were right

Recorded because the refusals are the useful part.

**1 · `AAO_AnswerKey`: identity does not move.** I tried to convert an Opportunity-subject answer
into a Contact-subject one. Refused: *"The answer key would change... This row is an answer to a
different question or about a different subject, which is a different row."* **Correct.** The
fixture now creates person answers instead of mutating them.

**2 · The cardinality guard (invariant 9).** Setting `AAO_Subject_Contact__c` while leaving
`AAO_Subject_Type__c = 'Opportunity'` was refused as a row expressing two subjects. **Correct**,
and it is why the fixture moves both fields together.

**3 · The evidence-family law (47/48).** A `MACHINE` establishment on a transcript basis with no
spans was refused: *"An establishment requires a citation."* The fixture uses `Basis = 'State'`,
which is the honest family for a projected map value — cited by the rows its claim named and
froze, never by a quote. **The law exempted it; the fixture did not dodge it.**

Two Apex reserved words also bit: `Page` (Visualforce) as an inner class name and `on` as a
field, both renamed to `Tally` and `isOn`.

### Verified, and what is NOT verified

**Verified by running against real org data**, both contexts: the harness deal
(`B&V Community Licenses-150`, correctly empty), the Tungsten rehearsal (2 sources, 2 claims,
1 answer, lineage present, both clocks with times, 2 flag rows across two states), the B&V
account (6 deals grouped, scope note present) and the demo account (9 sources, 9 claims, 5
answers, 12 flags gathered across 7 deals). 25 to 29 SOQL queries per snapshot against a limit
of 100.

**Not verified: the rendered DOM.** I exercised the controller from Apex and 17 tests; I have not
loaded the page in a browser, because that needs an interactive Salesforce login this session
cannot perform. **The template compiles and deploys, and that is not the same as looking right.**
Matthew should open the AAO Pipeline tab once before step 2 runs.

**Placement.** The meta now exposes Opportunity **and** Account. The component is on the
Opportunity record page's fifth tab as before. **Dropping it on an Account page is an admin
action in Lightning App Builder and was not done from here**, since no Account flexipage exists
in this repo to modify.

**Owed.** Step 2, unblocked and unchanged: the Casey transcript through the front door as a
Source, occurred clock 24 June 2026 07:01, People charter only, then the `AAO_TEMP_` invoker.
**Still open from session 57 and needed before the projection writer is built: whether the writer
upserts** (populate where Altify built a row, create where it did not) or something narrower.

---

## 2026-08-02 · session 59 · the tab race: an old defect the rework made visible

**Did.** Diagnosed and fixed the empty-`recordId` defect Matthew found on the Opportunity
placement. **Two of the three candidates in the report are falsified by evidence; the third is
right in substance and wrong in one detail worth correcting.** **186 tests, 186 passing.**
No controller logic changed apart from one error string.

### Candidate 1 · a design property shadowing the auto-wire · FALSIFIED

`aaoPipelineView.js-meta.xml` declares **zero** `<property>` elements. The `targetConfig` carries
only `<objects>`. There is nothing to shadow `@api recordId` with.

### Candidate 2 · stale component config cached in the flexipage XML · FALSIFIED

Retrieved `FlexiPage:Opportunity_Record_Page` live from the org and diffed it against the repo
copy: **byte-identical, `git diff` empty.** The live component instance is

```xml
<componentInstance>
    <componentName>aaoPipelineView</componentName>
    <identifier>aaoPipelineView_aaoTab</identifier>
</componentInstance>
```

with no `componentInstanceProperties` at all. Nothing stale, nothing passing a blank attribute.
The retrieved copy was reverted after the comparison so the repo is unchanged.

### Candidate 3 · the race · RIGHT, with one correction

**The correction, and it matters.** The report says the JS rework *moved the first Apex call
earlier than recordId assignment*. It did not. **The previous version called
`this.load()` from `connectedCallback` in exactly the same place**, and the previous Apex threw
on a null id in exactly the same way. **The race is older than the command center; the rework
did not introduce it, it made a latent defect visible.** Recording this because "the rework
broke it" and "the rework exposed it" lead to different places next time.

**Why this placement and not the other**, which is the part that actually explains the split
Matthew saw. The component sits in the **body facet of `flexipage_tab5`, titled "AAO Pipeline",
the fifth tab and not the default one.** A component inside a non-default tab is constructed
lazily, and on that path `connectedCallback` can run before the framework has assigned
`@api recordId`. The Account placement is a fresh top-level drop in a region, where the id is
assigned before connect, so the same bundle works. **The bundle was never the problem** — which
Matthew's own report already proved by rendering it fully on the Account page.

### The fix

`recordId` is taken through a getter and setter, and the first Apex call fires from there rather
than from `connectedCallback`. **Whichever happens last, the id arriving or the element
connecting, starts the load**, so ordering stops mattering. Four guards, each earning its place:

1. **`maybeStart()`** starts once and only once an id exists.
2. **`load()` refuses to call Apex with no id**, so if anything ever reaches it unguarded it
   stops rather than teaching the poll to raise the same error forever.
3. **`schedule()` does not reschedule with no id.** A poll that re-raises a configuration error
   every ten seconds is noise dressed as diligence, and that is exactly what was happening.
4. **`renderedCallback` fails loudly rather than spinning.** By first render the framework has
   assigned every `@api` value it will assign, so a missing id then is a real fault. **A
   permanent spinner is the same lie as a false empty state: it implies the system is working
   on something.**

A bonus correctness win that came free: a record swap under a console tab now reloads cleanly
instead of showing the previous record's snapshot, because the setter detects the change.

### The two guards now read differently on purpose

They were both a variant of *no record was supplied*, which would have made the next occurrence
undiagnosable. They are now discriminators:

- **`COMPONENT: no record id was ever handed to this component by the page`** — the framework
  never supplied an id. Placement fault, and the fix above did not take.
- **`SERVER: getSnapshot was called with no record id`** — something reached Apex without an
  id, meaning the component-side guard failed. **A different defect.**

If neither appears, it works. **Whoever re-checks can now report which sentence is on screen and
that alone identifies the failure**, instead of one string covering two causes.

### Not verified here, and it needs Matthew

**I cannot load the page.** That needs an interactive Salesforce login this session cannot
perform, so the fix is verified by reasoning, by the falsification of the other two candidates,
and by 186 passing tests — **not by looking at it.** The re-check is Matthew's, on both pages,
and Lightning caches component definitions hard enough that a plain reload can show the old
bundle: **hard-refresh, or the check proves nothing.**

**Owed.** Matthew's confirmation on the Opportunity tab and the Account page. Then step 2,
still unblocked and unchanged, and still carrying the open upsert question from session 57.

---

## 2026-08-02 · session 60 · step 2, part one: the writer, the contracts, and the rubric is global

**Did.** Built the ratified projection writer, built the People Evidence Contracts from the
seeded ontology, and closed the one gap that stopped the pipeline being per-person. **186 tests,
186 passing.** **Step 2 is not finished:** the Source is not ingested, no model pass has run,
there is no `AAO_TEMP_` invoker and no mechanical assertions. **I stopped on a structural finding
rather than build past it**, and the finding is below.

### Built and deployed

**`AAO_Project`, the projection writer, to the ratified shape.** Query-then-branch on the
`(contact, opportunity)` pair, never platform upsert. Row exists → populate only the dimensions
establishment moved. Row absent → create, established dimensions populated, rest null. **Two
rows → raise a Cardinality flag and write nothing; it never picks.** Support rung per §P7 with
recency arbitration; Political Status under the v2.1 ceiling with no contention flag and silent
re-derivation; Option C note that degrades to naming the value rather than clipping a quote,
because a clipped quote is at the edge of the paraphrase law. Held answers are excluded at the
query: **Held is live for nothing.** The human-edit watermark compares the native per-dimension
`_Last_Modified` against our own last write, which is exactly what the step 0 probe established.

**Matthew's correction is written into the class, not just the journal:** populate is normal only
where contact-role sync is on, and **the create leg is mandatory product behaviour** because a
person in the evidence with no contact role has no skeleton.

**`AAO_PeopleContracts`, our own rubric, no Altify anywhere in the read.** 48 contracts created
and verified in the org: **16 questions × 3 external speakers.** Coverage's three questions are
correctly absent, being route P and never extracted from words.

**The per-person code scheme, forced by a real constraint.** The extraction charter keys a
finding by proposition code alone and has **no subject field**, so the person must live in the
code or the model cannot say which of three people a sentence was about. `AAO_Proposition_Code__c`
is forty characters, so the code is a compact token: `S2#003WD00001PmxYSYAZ`. **The label is
never lost** — the byte-exact seed text is the proposition, curly apostrophes and all, and the
code is only an identifier.

**Two refusals shaped the contract, both correct.** `AAO_Element_Count__c = 0` was rejected:
*"A contract must know how many parts its proposition has."* A guided question is one
indivisible part, so it carries one element. Then the contract key collided across people,
because three people shared one question's content hash. **The person is part of the content**,
not decoration: *has THIS person expressed a preference* is a different proposition per person.
The contact id goes into the hash rather than into `AAO_Question_Record_Id__c`, which is
eighteen characters and cannot hold a code plus an id.

### The gap that was one line, and the surprise that it was only one

`AAO_Pipeline` never set `AAO_Subject_Contact__c` on a Candidate. **Everything downstream was
already per-person ready** and had been all along: `AAO_Commit` carries the subject to the Claim
and the Answer, `AAO_Accumulate` copies it, `AAO_Replay` reconstructs it, `AAO_AnswerKey`
composes identity on it. The chain was built for this and only its first link was missing.

Threaded on both paths, so the complete-ledger law survives per person: a People abstention is
recorded as being about that person rather than about the deal.

**One defect I introduced and caught in the same session.** Reading
`ec.AAO_Proposition_Code__c` broke every caller that had not selected it — the demo and
live-ingest paths hand contracts they built themselves, and an unqueried field throws. Nine
tests failed. Fixed with a null-safe accessor and by using the code already on the proposal.
**A per-person lookup must never be able to break a run that has no people in it.**

### THE FINDING · the rubric is org-global, so "People charter only" cannot be honoured yet

§P7.2 step 2 says **People charter only; every other charter's contracts sit unhanded.**

`AAO_Rubric.contracts()` is the only source of the applicable set, and it reads:

```sql
WHERE AAO_Contract_State__c != 'Superseded' AND AAO_Synthetic__c = :wantSynthetic
```

**No deal scope, no rubric-version scope, no charter scope.** `AAO_Pipeline.liveContracts()`
returns it whole, and `runForSource` has no overload that accepts a set. So a pass on the Casey
Source would hand the model **the 48 People contracts plus every discovery and demo contract in
the org**, which is precisely what the brief forbids. The demo contracts would abstain against a
B&V transcript, but they would burn tokens, pollute the candidate ledger, and make the run's own
completeness numbers meaningless.

**Consequence Matthew should know about now:** the 48 People contracts are non-synthetic and
therefore **already in the global applicable set**. They do not affect the test suite, which
scaffolds isolated data, and they have changed no existing row. But **any real pass on any deal
in this org would now consider them**, so they should be scoped or superseded before anything
else is run.

**This is design's call, not mine, and there are at least three shapes:** scope by rubric version
on the run; use the existing per-deal rubric binding (session 15's *one rubric per deal* and
session 16's *the binding becomes a fact about the deal*, which I did not have room to read
properly); or give `runForSource` an explicit contract set. **I did not guess**, for the same
reason I did not guess the account-grain predicate: a scoping rule invented here would look
right and quietly decide what every future charter reads.

### Owed, precisely

**Not built and not started:** the Source ingest (transcript verified and in the repo, occurred
clock 24 June 2026 07:01, roster of four), the model pass, the `AAO_TEMP_` invoker, and the
mechanical assertions. **`AAO_Project` has no unit tests yet** — it is deployed and compiles, and
its derivation has not been exercised against staged answers. That test is the next thing I write
regardless of the scoping ruling, because it needs no transcript.

**Assumption flagged in code, design's to rule:** Political Q1, Q2 and Q4 are two-sided, and
Charters v2.1 says their proposal enums are runtime-closed from the wizard's own semantic
options. Those enums are not built. The writer currently reads **TRUE as the strong side and
FALSE as the weak side**, which is the natural reading of *does this person define the goals, or
do they merely understand them.* Named in the class where it applies. Nothing else depends on it.

---

## 2026-08-02 · session 61 · the writer proved, and the applicable set declared

**Did.** Wrote `AAO_ProjectTest` (18 tests, green first run) and built the applicable-set
resolver to the ratified structure. **204 tests, 204 passing** (was 186). Build order stands:
ingest, pass, invoker and assertions are next and are not started.

### Build order step 1 · `AAO_Project` proved

**18 tests, passing on the first run.** The derivation tables are tested as pure functions,
through in-memory answers built with JSON so the contract relationship populates without DML —
not a shortcut, but so a wrong table row fails loudly instead of failing inside a write.

Support: Q2 alone is a Supporter; Q2+Q4 is **still** a Supporter and only Q2+Q4+Q5 is a Mentor,
which is the two-beyond-Supporter asymmetry; each of 6/11/14 is Non-Supporter and each of 7/16
is Enemy; **Q1 places nobody**; nothing established returns null and **never a computed
Neutral**; and when both sides stand, recency owns the rung with the displaced side named for
its opposite-polarity flag, tested in both directions.

Political under the ceiling: any one of Q1/Q2/Q4 strong alone reaches Inner Circle; **Q9 places
nobody**; brokering alone is Outside the Structure; **a lesser property arriving later never
downgrades** (Inner Circle plus advice plus brokering stays Inner Circle, and unlike Support
recency does not decide it); and Unset leaves the field null rather than writing the picklist's
`Unknown`, because `Unknown` is a claim and null is the absence of one.

**The ratified guard has its own test.** A `FALSE` on a two-sided question places somebody on the
weak side — *executes after approval* is a placement, not a demotion — while an `UNVERIFIED` on
the same question **places nobody**. The derivation reads the FALSE sets for the weak side and
never infers a weak side from a missing TRUE, so absence cannot manufacture a placement. The
guard is written into the class comment where the assumption used to sit.

All three write legs pass, **including the create leg**: established dimensions populated, every
other field left null, because a row filled out to look complete is a row claiming things nothing
established. The populate leg leaves an untouched `Buyer_Role` exactly as found. Two rows block
the write, raise a Cardinality flag, and leave both rows unwritten. A Held answer reaches nothing.

**Recorded per the ruling: the harness run will exercise populate only**, since every speaker on
the Casey call holds a contact role. **The create leg is covered by unit test and untested by the
run**, and those are different statements.

### Build order step 2 · the applicable set

**`AAO_Rubric.contracts()` is marked wrong in place**, in its own class comment, naming why it
was right for one rubric in discovery and is wrong law now. It survives for callers that want the
whole cabinet — inventory, the pipeline view, discovery's audits — and **must never feed a model**.

**`AAO_Evidence_Contract__c.AAO_Charter_Designation__c`**, restricted picklist, People / Problems
/ Politics / Process. The description names its writer (the contract seeders) and its readers
(the resolver only) per the field law, and states that no charter ever reads it, because a
charter's handed unit is the Evidence Contract and it never sees a module. **48 People contracts
stamped; 12 legacy contracts sit on null and `resolveProcess` deliberately still admits them.**

**`AAO_ApplicableSet.resolve(charters, source)`.** The set is declared and never inferred; there
is no "everything", and asking for one throws. `runForSource` gains a four-argument form, and the
three-argument form declares `{Process}` explicitly rather than leaving the old law wearing a new
signature.

**People resolves per roster**, the union of the deal's map rows and the Source's participants.
Both halves earn their place: the map is who the seller has already said matters, and the
participants are who actually spoke — **and evidence introduces people the CRM has not caught up
with, so map-only would make the writer's create leg unreachable.** A People contract whose code
carries no person is dropped as malformed rather than treated as global.

**Process resolves charter-filtered but NOT deal-filtered, and is labelled a half-measure in the
method that does it.** The config chain (plan type → plan-type-list row → question codes) is
walked by `AAO_Discovery` at cold start, but **nothing persists the resulting binding as a
queryable fact about the deal**, so the resolver cannot re-derive it from the deal alone. What is
built is strictly narrower than the global read it replaces. **This is the remaining half of the
ruling and it is owed.**

### Two defects I caused and caught, both worth the record

**A silent semantic change, caught by seven tests.** I made the resolver choose the synthetic or
product population from the Source's own flag, which reads as more correct than what it replaced.
`liveContracts()` was `AAO_Rubric.byCode()` = `byCode(false)`: **the product population always,
regardless of the Source.** Seven model-path tests broke, their Source marked and their contracts
not. Reverted, with the reasoning on the method: **the ruling changed which contracts resolve,
not which population**, and changing both at once would have hidden a semantic change inside a
structural one.

**A field that existed for Apex and not for SOQL.** The new field deployed green and every class
referencing it compiled, yet `describe` and SOQL both insisted `No such column`. **That signature
is missing field-level security, not a missing field** — Apex compiles against metadata while the
REST API enforces FLS. Granted on `AAO_Admin` and the back-stamp ran immediately. Worth knowing
as *"compiles but cannot be queried" means permissions*, because it reads exactly like a failed
deploy that reported success.

**Owed.** Step 3 onward, unstarted: the Source ingest (transcript verified in the repo, occurred
clock 24 June 2026 07:01, roster of four, SHA-256 confirmed), the People pass with the blind
reader on, the `AAO_TEMP_` invoker, and the mechanical assertions. Plus the Process per-deal
binding named above.

---

## 2026-08-02 · session 62 · THE RUN REPORT · the pass fired, established nothing, and found two defects

**Did.** Synced context 25 (Board v1.2, Charters v2.3, Architecture v3.2, Model & Flow v1.1,
Glossary v2.3; run sheet still v1.3 here). Ingested the Casey transcript as a Source. **Ran the
People pass against it: one real model callout, status `staged`, 48 candidates written, zero
claims, zero answers.** The invoker and the mechanical assertions are not built, because the pass
returned nothing to project. **Two defects found, one of them mine.**

### The run, verbatim from the pass outcome

```
status=staged  src=bv/biweekly-2026-06-24  from=model  charter=1.1.0
verdict=null  claim=null  abstentions=0 (nobody_said=0 model_declined=0)
notReturned=48  spansDropped=0  blindOverrides=0
EXTRACT model=claude-opus-5 charter=AAO_Extract_Evidence@1.1.0 findings=1
in=18696 out=7532 cacheRead=13799 ms=94860 stop=end_turn
UNANSWERED=(AAO_T2, AAO_T3, AAO_T4, AAO_T5, AAO_T6, PO1#...PmxYSYAZ, PO1#...PmxYbYAJ, ...)
```

**48 candidates on the deal, every one `Not_Returned` and every one `Subject_Type = Contact`.**
Zero claims, zero answers, nothing projected. **Zero spans dropped: no fabricated quote.**

**What worked.** The per-person threading works end to end: every candidate carries its subject
contact, which is the gap session 60 closed. The applicable set resolved exactly right —
**People 48, roster 44, Process 6, and an undeclared set refused.** The complete-ledger law held
per person: a proposition nothing was said about still wrote its row, attributed to the person it
was about rather than to the deal.

### DEFECT 1 · the declared set governs what is WRITTEN, not what is ASKED

`AAO_Extract.cls:203` reads `List<AAO_Evidence_Contract__c> contracts = AAO_Rubric.contracts();`
— **the org-global read, the one the ruling marked wrong.** So `runForSource` resolved 48 People
contracts and handed the writer 48, while the extractor built its prompt from the whole cabinet
and asked the model about **53** propositions: the 48 People ones plus `AAO_T2` through `AAO_T6`.
The `UNANSWERED` list names them, which is how it surfaced.

**The ruling's fourth clause is currently false: something WAS handed to the model that did not
resolve.** I marked `AAO_Rubric.contracts()` wrong in its own comment and wired the resolver into
`AAO_Pipeline`, and I did not audit the extractor for a second call site. **One wrong-law read
with two callers, and I fixed the caller I was looking at.**

### DEFECT 2 · the Source carries no normalized hash, and the law that stopped me was right

I omitted `AAO_SHA256__c` at insert. Setting it afterwards was refused:

> `AAO_SHA256__c is immutable on AAO_Source__c. Every span already stored was byte-verified
> against this record; editing it breaks the citation chain without anything appearing to fail.
> Re-ingest as a new Source instead.`

Re-ingesting collided on the scope key, correctly — dedup on bytes doing its job. Deleting the
first Source was refused too: *Sources leave by retirement, confirm-then-purge, library
acknowledgement first.* **Three laws in a row, all correct, all refusing to let me tidy up.**

So the Source stands with `AAO_Artifact_SHA256__c` correct and `AAO_SHA256__c` null. **Span
verification is unaffected** — it verifies against the stored text, not the fingerprint, and zero
spans dropped this run. What is missing is the integrity fingerprint that would detect later
tampering of the stored text by hash comparison alone.

**A question for design, not a fix I should make:** the guard fired on a **null-to-value**
transition. Setting a field that was never set is not editing it, and no span had been stored
when I tried. If the guard is meant to protect a citation chain, it could permit the first write
and forbid every later one. Left alone rather than loosened by the person it inconvenienced.

**Also recorded, and it is a platform fact worth keeping:** the platform **strips a trailing
newline from a LongTextArea**. The file is 46,552 bytes and the stored text is 46,551 characters,
a prefix missing its final `\n`. **The artifact and the stored normalized text can therefore never
be byte-identical when the artifact ends in a newline**, which is precisely why this schema
carries two hashes. The manifest's *this file's bytes are the frozen artifact* wants that
one-character qualification.

### Why the model established nothing, read honestly

**`findings=1` against 53 propositions asked.** Not a refusal and not a timeout: `stop=end_turn`,
7,532 output tokens, 94.9 seconds. The model answered, and it answered almost nothing.

**I am not going to diagnose this from one run.** The candidate explanations are the prompt
carrying 48 near-identical per-person propositions that differ only by an opaque id suffix, the
mixed-charter set defect above, and a transcript whose People content is largely reported speech
of the kind Gate 1 already flags as the over-read failure mode. **Defect 1 has to be fixed before
any of that is measurable**, because this run asked a question nobody intended to ask.

**What this run does establish**, and it is not nothing: the whole spine executes on real data.
Contracts resolve, a real callout completes, the ledger writes one row per proposition per
person, the subject threads through, and no quote was fabricated.

**Owed.** Fix defect 1 — the extractor must take the resolved set rather than read the rubric.
Then re-run and report. Then the `AAO_TEMP_` invoker and the mechanical assertions, neither of
which has anything to do until a claim exists. **Nothing has been handed to Matthew for
adjudication, because there is nothing yet to adjudicate.**

---

## 2026-08-03 · session 63 · step 0 and step 4 built; the AspenTech seed is blocked on a prod read

**Did.** Built the two items in the AspenTech post that do not need production: **step 0, the
extractor fix, and step 4, SHA determinism.** **204 tests, 204 passing.** Synced context 25
(Board v1.2, Charters v2.3, Architecture v3.2, Model & Flow v1.1, Glossary v2.3; run sheet still
v1.3 here). **Steps 1, 2, 3 and 5 are blocked and the blocker is measured below.**

### Step 0 · the extractor takes the resolved set, and the old read cannot be reached

**The rename is the fix, because a rename is the only restriction the compiler enforces.**
`AAO_Rubric.contracts()` is now `inventory()`, and `byCode()` is `inventoryByCode()`. **No caller
of the old names remains** — the only surviving mention is the sentence in `AAO_Extract` that
explains why they went.

`AAO_Extract.run(Id sourceId, List<AAO_Evidence_Contract__c> declared)` **takes the applicable set
as an argument and no longer reads a rubric at all.** Its old error, *no evidence contracts in the
org*, is replaced by *nothing resolved for the declared charter set*, because those are different
facts and the first one was never the true diagnosis.

`AAO_Pipeline.liveContracts()` is now `inventoryForHarness()` and is documented as inventory only,
never an applicable set and never a model path. Gate 1's harness follows it; the P route, the
Solution route and the flag raiser follow the renamed inventory read, which is correct — none of
them asks a model anything.

**Population semantics preserved again, deliberately.** `AAO_ExtractTest` now passes
`AAO_Rubric.inventory()`, which is byte-for-byte the population the old internal read used. The
ruling changed which contracts resolve, not which population, and this is the second time that
distinction has kept a structural change from smuggling a semantic one.

### Step 4 · the fingerprint is now a code-path guarantee

`AAO_SourceTriggerHandler.beforeInsert` computes `AAO_SHA256__c` from the received bytes
**unconditionally**, beside the scope key, for the same stated reason: a value composed anywhere
but here is a second composer, so a caller-supplied one is overwritten rather than trusted. The
normalizer version fills in where blank.

**The B&V gap cannot recur, by construction rather than by discipline** — omitting the value is no
longer something a caller is able to do. **No immutability exception exists or will**, and the
three laws that refused to let me repair that Source after the fact stay exactly as they are:
immutable field, dedup on bytes, Sources leave by retirement.

### Steps 1, 2, 3, 5 · BLOCKED, and measured rather than assumed

The post says to seed from **production VideoCall `6qrV4000000LY6jIAG`**, traverse to its Account,
and read the canonical ECI text from the org before freezing. **I cannot reach production**, which
context 23's addendum already settled: *you never get it; design side pulled the extract
read-only.*

**I checked whether the sandbox refresh made that moot, because it plausibly could have.** The
users carried over from prod with identical ids, so ECI data might have too. It did not:

| Read against `aossb2` | Result |
|---|---|
| `SELECT COUNT() FROM VideoCall` | **0 records** — the object exists, the data did not come across |
| `SELECT COUNT() FROM ConversationEntry` | **0 records** |
| `Account WHERE Name LIKE '%spen%'` | **nothing** |

So the AspenTech seed needs the same treatment B&V got: **design pulls the extract read-only from
production and ships it, plus the canonical ECI transcript text.** Step 3's instruction is the
sharp one and I cannot satisfy it from here: *read the canonical ECI text from the org and verify
what it actually contains before freezing — the paste is not the transcript.* **Verifying that a
paste matches the org requires reading the org**, so whoever pulls the extract has to do that
comparison, not me.

**What I need shipped, precisely:** the account, its contacts (including Corey, Neeraja, Fatima
and Jacob if they exist in production), all open opportunities plus at least one closed-won, the
users for the owner remap, the ECI recording metadata for the occurred clock, and the **canonical
ECI transcript text as the org stores it** — with the inference labels and player-position lines
still present, so the separation in step 3 is something I perform and record rather than something
I receive already done.

### Step 6 · the sequencing law, recorded here as binding

**The resolver build is the immediate next build after the People phase closes — before Politics,
before any other charter work.** Recorded as a hard law rather than a preference: without it no
Source can route and there is no product. It reorders the Board's step 4, which had Politics next.
The multi-opportunity fixtures are its harness material, and **B&V already provides half of it**:
six opportunities on one account, four open, two closed-won, with the which-opportunity problem
intact and deliberately unasserted by the People run.

### The B&V run's standing, unchanged

The 48 candidates from session 62 remain, every one `Not_Returned`, and **they were produced by
the defective extractor**. They are history, not a result: the pass asked about 53 propositions on
a set that declared 48. **Nothing about that run should be quoted as a measurement of the model or
of the People charter**, and re-running B&V under the corrected extractor is a separate decision
from seeding AspenTech.

**Owed.** The AspenTech extract and canonical ECI text from design. Then steps 1, 2, 3, 5, the
pass, the invoker and the assertions. Whether to re-run B&V corrected is Matthew's call.

---

## 2026-08-03 · session 64 · Emerson corrections recorded; the extract payload has not arrived

**Did.** Recorded the Emerson corrections and four findings from the design-side production reads.
**Built nothing: the extract itself is not on disk.** Steps 0 and 4 remain as session 63 left them,
204 tests passing.

### My error, corrected: the account is Emerson, not AspenTech

**I probed the sandbox for `%spen%` and reported nothing found, which was true and useless.** The
CRM account is **Emerson Electric Co., `001Hn00002CXGaMIAX`**; AspenTech is the contracting entity
name on paper only, and the participants carry `emerson.com` emails. **There was nothing to find
because I was looking for the wrong name** — a negative result against a wrong search term reads
exactly like a negative result against the right one, which is the standing hazard about sweeping
wider than the question, hitting me directly.

### The extract has not shipped, measured

The post describes the extract's contents in full. **The files are not on disk.** Checked
`~/Downloads` for any Emerson or AspenTech folder (none), the newest folder `AAAO_AUG31`, and the
`aao-context.zip` inside it: **that zip is context 25 exactly** — the five documents plus the B&V
fixture and transcript, fifteen files, nothing Emerson. Context 25 was already synced in session 62.

**What is owed as files:** the Account; 114 Contacts; three Opportunities; the two Users for the
remap; and whatever branch 4 resolves to for the transcript.

### Recorded now, because these are findings and not payload

**1 · The given deal is closed-won at run time, and evidence occurred while it was open.**
`006V400000VIJiIIAX`, Insights 500 Full Insight, closed won 31 July for $275,555; the call happened
**29 July**, when it was open. **Whether projection writes onto a closed deal's map is design's
open question and explicitly not mine to answer.** Recorded and proceeding when the extract lands.

**2 · ECI's related-record stamp misfires in the second direction.** On B&V it stamped an
opportunity for an account-flavoured call. Here it **stamped the account on a blatantly late-stage
deal call.** Two directions, two misfires, from two reads. **The Board's hazard that ECI's stamp is
inference and unstable is now evidenced rather than asserted**, and the given deal for this run is
a one-time scaffolding ruling standing in for the unbuilt resolver, journalled as ECI-supplied and
untested by us.

**3 · Two clocks on one artifact, both recorded.** Call `StartDateTime` **2026-07-29T20:00:55Z**,
duration 1245s; the transcript artifact's own window starts **20:04:20Z**, three minutes and
twenty-five seconds later. **The call clock is the occurred clock.** The gap is presumably joining
time before speech, and it is exactly the kind of difference that would silently become a
citation's date if the artifact window were taken as the call time.

**4 · The participant-resolution claim needs qualification, and this is a correction to v0.3.**
Both external `VideoCallParticipant` rows carry **`RelatedPersonId = null`**. The v0.3 claim that
resolution is *deterministic on every external row* conflates two things: **the email-match
mechanism is deterministic; its coverage is not.** Ryan Couture's Contact has **no email**, and
**no Contact exists for Jefferson Vargas at all**. So this fixture exercises the identity ladder
for real rather than falling through its first rung — which is the opposite of a problem for a
harness whose job is to find out what happens.

**5 · The transcript is a blob, not text, and neither branch may be built against.**
`VideoCallRecording 3QhV4000000LkhNKAS`, `FileType = TRANSCRIPT`, behind the ECI media endpoint and
not reachable by SOQL. Design will attempt retrieval; **unverified until tried**, which is the
capability law applied to somebody else's runtime. Branch (a) blob retrieved: I perform and record
the step-3 separation against actual stored content, noting the org may already hold annotations
apart from speech. Branch (b) retrieval fails everywhere: the paste becomes the artifact, verified
by Matthew against the video, **recorded as second-best with the reason**. **I have built nothing
that assumes either.**

### Held for Matthew, not started

**The B&V re-run under the corrected extractor is recommended by design and not authorised.** The
post carries `[Matthew: confirm.]` and no confirmation. It is one callout against a loaded fixture
and it would convert the voided session-62 run into the first honest baseline **before the Emerson
run adds a second variable**, which is a good argument. **It is still a real model callout on real
customer data and I am not taking a bracketed request to a third party as my instruction.**

**Owed.** The Emerson extract as files. Matthew's word on the B&V re-run. Then the seeder, the
step-3 separation on whichever branch lands, the pass, the invoker and the assertions.

---

## 2026-08-03 · session 65 · the Emerson extract verified; the seed held on one ruling

**Did.** Filed and verified the Emerson extract v2 against its manifest and Amendment 1. **Nothing
seeded and nothing built: Amendment 1 escalated the seed choice to Matthew and says nothing is
seeded until he rules.** Payload filed at `seed/emerson-fixture/`, untracked under the ratified PII
split, manifest tracked.

### Verified, all of it

| Claim | Read |
|---|---|
| `contact_roles.json` restructured to an object | `rows` = **17**, `_count` = **17** |
| stub deleted, full AspenTech account shipped | both true |
| AspenTech contacts | **54**, as stated |
| `ParentId` on both accounts | **null on both** — no hierarchy to infer |
| Emerson contacts / opportunities / users | 115 / 3 / 5 |
| VideoCall occurred clock | `2026-07-29T20:00:55Z` |
| Both external participants | `RelatedPersonId = null` |

Every duplicate pair the amendment names is present exactly as described, including the
intra-account `Ahmed Abdel-Hady` / `Ahmed Abdelhady` on AspenTech and `Kevin Keeling` sitting on
AspenTech with an `@emerson.com` address.

### The count correction, and the part worth keeping

Design fixed the `_summary`-inside-the-array defect and kept my note about it. **The lesson is
mine and it is the more useful half: my check counted array elements and reported 18 = 18, so it
agreed with the manifest while both were wrong.** A count check that reads the container rather
than the rows is not a count check. **It passed by coincidence**, and coincidence is worth flagging
louder than the data it was supposed to guard.

### The finding that sharpens Matthew's choice, and it is mine to state

Amendment 1 frames seeding all 54 as importing five duplicate identities "of people who already
hold roles on the given deal." **Measured, it is worse than that framing suggests: four of them
hold OCRs on the given deal itself**, which is the exact roster the People pass runs against.

```
Fatema Choudray      null email      OCR on 006V400000VIJiIIAX   vs Fatema Choudhury (AspenTech)
Denise Stauubach     null email      OCR on 006V400000VIJiIIAX   vs Denise Staubach  (AspenTech)
Patrick Cook         pat@aspentech.com        OCR on given deal  vs patrick.cook@aspentech.com
Luc Martin           luc.martin@aspentch.com  OCR on given deal  vs the correct domain
```

**Two of the four carry no email at all, and a third carries a typo'd domain**, so the email-match
rung cannot separate any of them. They would land in the roster the resolver hands the People
charter, as near-duplicate subjects of per-person contracts. **That is not background noise the run
might trip over; it is contamination of the run's own subject set.** It makes design's
one-variable-at-a-time read stronger rather than merely tidier.

### Held for Matthew · two rulings, nothing started

**1 · Filipe only, or all 54.** Design reads Filipe only, all 54 later as the identity-ladder
fixture. **I agree, on the evidence above**, and I note I had already elected all-54 on the Slalom
precedent before the AspenTech pull existed — **the precedent was sound and the new facts beat it**,
which is the correction being made here. Amendment 1 says nothing is seeded until Matthew rules,
so nothing is.

**2 · The B&V re-run under the corrected extractor.** Still `[Matthew: confirm.]`, still
unanswered across three relays. One callout against a loaded fixture; converts the voided
session-62 run into the first honest baseline before Emerson adds a second variable.

**Owed.** Both rulings. Then the seeder (probe-first, counts after, owners remapped to the same
sandbox ids), the transcript branch (a) or (b), the pass, the invoker and the assertions.

---

## 2026-08-03 · session 66 · the corrected B&V re-run does not fit inside Apex's callout ceiling

**Did.** Ran the B&V People pass twice under the corrected extractor on Matthew's go. **Both
attempts died with `System.CalloutException: Read timed out` at the platform ceiling.** No rows
written either time. **This is a structural finding, not bad luck**, and it blocks every People
pass in the current shape — B&V and Emerson alike.

### The measurement

| | propositions asked | result |
|---|---|---|
| Session 62, defective extractor | 53 | completed in **94,860 ms**, `cacheRead=13799`, `findings=1` |
| Session 66, attempt 1 | 48 | **Read timed out** |
| Session 66, attempt 2 | 48 | **Read timed out** |

`AAO_Model_Config__mdt.Default.AAO_Timeout_Ms__c` is **120000**, and `AAO_Extract` already clamps
to `PLATFORM_TIMEOUT_CEILING_MS`. **120 seconds is the platform maximum for an Apex callout; there
is no larger number to configure.** The one run that completed did so with 25 seconds of headroom.

### Why fewer propositions got slower, which is the part that matters

**The corrected extractor sends a different prompt, so the prompt cache is cold.** Session 62 read
13,799 cached tokens; changing the applicable set changed the prefix, and the cache that bought
those 25 seconds no longer applies. So the honest reading is not *48 is slower than 53* — it is
that **the pass only ever fitted with a warm cache, and nothing guarantees one.** A run whose
success depends on a cache hit is not a run that works.

### The consequence, stated but not ruled

**A 48-proposition per-person pass against a 46 KB artifact does not fit in one synchronous Apex
callout.** That is a fact about the shape of the pass, not about this transcript: Emerson's roster
is larger, so it is worse there.

The shapes available, cost stated, **design's to choose**:

- **Per-person calls.** Three calls of sixteen propositions instead of one of forty-eight, which
  is what the per-person contract design already implies. Each call is a third of the prompt.
  Cost: three callouts per artifact per pass, and the blind reader multiplies it.
- **Per-dimension calls.** Support and Political separately, nine and seven per person.
- **Off the synchronous path.** Queueable chaining or Batch, one callout per execution context.
  Cost: the 120-second ceiling applies per callout regardless, so this only helps if combined with
  splitting.
- **Smaller artifacts.** Part-splitting a long transcript, which `AAO_Part_Index__c` and
  `AAO_Part_Count__c` already exist for and which nothing has ever exercised.

**I have not built any of them.** Choosing one changes what a pass is and how its completeness
numbers compose across calls, which is a charter-design question rather than a plumbing one.

### What this does to the Emerson seed

**Nothing, and it does not block it.** Seeding is native-parent DML with no callout. **The seed
proceeds on Matthew's go as Filipe-only**; only the pass at the end of it is blocked, and it is
blocked for B&V too. The baseline number Matthew authorised is **not available** and the
session-62 run stays voided rather than becoming a baseline.

**Owed.** The pass-shape ruling, which is now the blocker for the whole People phase. Then the
Emerson seed, the transcript branch, the pass, the invoker and the assertions. **The B&V fixture
and Source are loaded and unchanged and will re-run in minutes once a shape is chosen.**

---

## 2026-08-03 · session 67 · Emerson seeded with all 54; the pass shape RULED

**Did.** Seeded the Emerson fixture on Matthew's override — **all 54 AspenTech contacts, not
Filipe only.** Verified from the org. **Ruled the pass shape, delegated to me.** The pass is held
per instruction and nothing was asked of any model.

### The seed, verified from the org rather than from insert success

| | seeded | expected |
|---|---|---|
| Accounts | **2** | Emerson + Aspen Technology |
| Contacts total | **168** | 114 + 54, deduped |
| on Emerson | **114** | ✓ |
| on Aspen Technology | **54** | ✓ |
| Opportunities | **2** | of 3 — see the drop below |
| Contact roles | **16** | of 17 — the 17th sat on the dropped deal |

Given deal `006V400000VIJiIIAX` → **`006WD00000TJmJZYA1`**, Closed Won, `IsWon` true, $275,555,
Renee Martin. Renewal → `006WD00000TJmLBYA1`, Stage 2, open, Renee Martin. **Stage, closed and won
fidelity all survived.** Owners are an identity remap: the prod refresh carried the users, so the
pattern is the original rather than a reproduction. Probe-first was honoured — the given deal went
in alone before the rest.

**Filipe is in both extract files.** Union by id is **168 distinct people, not 169**, and he is
placed on Aspen Technology where he actually lives. Inserting both rows would have manufactured a
169th person and a duplicate of the very kind this fixture exists to study.

### Two fidelity gaps, both recorded rather than papered over

**1 · The 2019 closed-lost opportunity is DROPPED, with its one contact role.** A sandbox
validation rule refuses it: *Reason Lost required when Stage is Closed Lost*. The extract ships no
`Reason Lost`, because production presumably holds one and the curated projection dropped it.
**I did not invent a value.** Supplying a plausible Reason Lost would be fabricating a production
read, and stage-shifting it to satisfy the rule would break the stage-fidelity verification item.
**The traversal shape does not need it** — the given deal is itself Closed Won, so owns-something
exists. Owed: `Reason_Lost__c` in the extract if the 2019 deal is wanted.

**2 · First and last names are RECONSTRUCTED, not read.** The extract ships `Name` only, and
`LastName` is required. Split on the final space: everything before is First, the last token is
Last. Correct for every name in this set, and **it is still a transformation** — any compound
surname would land wrong, and the sandbox `Name` for such a row would differ from production.

### THE PASS SHAPE · ruled, since Matthew delegated it

**Per person, one call each. Sixteen propositions per call, not forty-eight.**

**Why this and not the alternatives.** The per-person contract design already implies it: a
contract is `(question, person)`, the model is asked to reason about one named human at a time, and
a prompt carrying forty-eight propositions that differ only by an opaque id suffix is the most
likely explanation for `findings=1` on the one run that completed. **Splitting by person fixes the
timeout and the plausible quality problem with the same cut**, which none of the other options do.

- **Per dimension** splits nine and seven but keeps every person in one prompt, so the
  which-person ambiguity — the thing I most suspect — survives untouched.
- **Off the synchronous path** buys nothing alone: the 120-second ceiling is per callout, not per
  transaction.
- **Part-splitting the artifact** cuts the wrong axis. It shrinks the transcript every call must
  read, when the transcript is the one thing every proposition genuinely needs whole.

**What it costs, stated.** One callout per person per pass, and the blind reader doubles it: a
three-person roster is six callouts where it was two. Emerson's roster is larger and this is where
the cost bites, so the roster is the thing to bound, not the prompt. **Completeness composes by
addition rather than being read off one response** — the ledger already writes one row per
proposition per person, so `notReturned` per person sums to the pass total and the abstention rate
stays a direct query.

**What it does not change:** the declared applicable set, the resolver, the per-person threading,
the writer, and every law any of them enforces. **This is how one pass is executed, not what a
pass is.**

**Not built.** Ruled and recorded only, because Matthew's instruction was to hold the pass until
the shape was ruled, and the ruling is the deliverable he asked for.

**Owed.** Build the per-person split in `AAO_Extract`/`AAO_Pipeline`, re-run B&V for the baseline,
then the Emerson transcript branch, the pass, the invoker and the assertions.

---

## 2026-08-03 · session 68 · three rulings applied; the prompt ordering inverted on purpose

**Did.** Applied all three rulings. **The 2019 deal is closed as dropped-for-good, the Tylor
St. Clair name is corrected, and the prompt ordering is inverted to artifact-first as part of the
per-person shape.** 55 tests across the affected classes passing. **The per-person split itself is
not built** and is the next thing.

### Ruling 1 · the 2019 closed-lost deal, closed

**Nothing owed.** The Emerson fixture is final at **2 opportunities and 16 contact roles**, and no
`Reason_Lost__c` is coming. The traversal shape is satisfied by the given deal being closed-won
itself. Design's curation stripped the field; recorded as design's error and now moot. **The drop
is a ruling rather than a gap**, which is the difference between this and the B&V normalized-hash
gap that stays recorded as history.

### Ruling 2 · one reconstructed name corrected

`Tylor St. Clair` split on the final space gave `FirstName "Tylor St." / LastName "Clair"`.
Corrected in the org to **`Tylor` / `St. Clair`**, verified by read-back. Every other name in both
files survives the split, including the hyphenated ones and `Anjani Kumar Asthana`, where
`First "Anjani Kumar" / Last "Asthana"` is right.

**The reconstruction stays journalled as a transformation regardless.** The extract shipped `Name`
only; `LastName` is required; the split is ours. **One correction out of 168 is not evidence the
method is sound** — it is evidence that a particle like `St.` breaks it, and the next surname with
`van`, `de` or `bin` in it breaks it the same way. Design's gap to close in the next extract format
by shipping `FirstName` and `LastName` as read.

### Ruling 3 · artifact first, propositions second

`AAO_ExtractCharter.userContent` now emits `artifactBlock` then `rubricBlock`. **This inverts the
existing ordering, and the comment explaining why the rubric led was not wrong** — it was right for
the access pattern it was written for: one stable rubric read against many artifacts, where the
rubric is the invariant and the artifact is the volatile half.

**A per-person pass has the opposite pattern.** One artifact is read N times, once per person, and
only the proposition tail changes. With the rubric leading, each of N calls pays full price for
46 KB of transcript and every call sits back at the 120-second ceiling — which would have made the
split useless and looked like the split failing. Both comments are now in the file, so the next
reader sees an inversion made deliberately rather than a rule someone forgot.

**Marked unverified, and the run measures it.** That caching works through this path at all is
measured: session 62 read **13,799** cached tokens from Apex via the Named Credential. **That
artifact-first ordering earns a prefix hit on calls two and three is predicted, not verified.**
`cacheRead` per call goes in the run report; **near-zero on the later calls falsifies the
prediction and the shape gets revisited on evidence**, which is written into the method comment so
it cannot quietly become an assumption.

**Owed.** Build the per-person split in `AAO_Extract` and `AAO_Pipeline` — N callouts before any
DML, findings merged, completeness summed per person. Then B&V for the baseline with per-call
`cacheRead` reported, then Emerson.

---

## 2026-08-03 · session 70 · the per-person split is built and the B&V baseline still times out

**Did.** Built the per-person split and ran B&V. **`System.CalloutException: Read timed out` again.**
No rows written. **The prediction behind the shape is now in doubt on evidence, which is what the
falsification condition existed for**, and the decisive measurement is named below rather than
attempted on a dying context.

### What was built

`AAO_Pipeline` groups the resolved set by subject contact and makes **one `AAO_Extract.run` call per
person**, sixteen propositions each instead of one call of forty-eight. Contracts carrying no
person keep their own group, so a non-People charter in a declared set is asked once rather than
smeared across the people. **Every callout happens before any DML**, which the callout-after-DML
prohibition makes load bearing, and the loop accumulates proposals and writes nothing until done.
Per-call `cacheRead`, `inputTokens`, proposition count and finding count are composed into the
outcome note, as the run report requires.

### The result, and the reasoning it undermines

**Third consecutive timeout at the 120,000 ms ceiling**, now with a third of the propositions per
call. That points somewhere different from where I pointed.

**Session 62's completed run had a warm cache: 13,799 cached tokens, 94,860 ms.** Every attempt
since has been cold, because both the applicable-set fix and the artifact-first inversion changed
the prompt prefix. So the emerging reading is:

**the 46 KB artifact, read cold, is the dominant cost — not the proposition count.**

If that is right, my per-person reasoning is **half wrong in a way worth stating plainly.** Reducing
propositions per call does not reduce the artifact each call must read, and **call one can never hit
a cache**, so call one always pays cold whatever the split. Splitting by person cannot rescue a
shape whose first call does not fit. The part of the reasoning that survives is the which-person
ambiguity argument, which was about answer quality and never about latency.

**This does not yet falsify artifact-first ordering** — that prediction is about calls two onward and
no call two has ever run. It falsifies the assumption underneath the whole shape: that proposition
count was the binding constraint.

### The decisive measurement, named and NOT taken

**Time one single-person call — sixteen propositions, cold — and read whether it fits under 120
seconds at all.** That one number separates two very different worlds:

- **It fits.** The split works, the timeouts were the cold first call plus latency variance, and the
  cache prediction is testable from call two.
- **It does not fit.** No split on the proposition axis can work, because the artifact is the cost.
  The axis that matters becomes the artifact: part-splitting via `AAO_Part_Index__c` /
  `AAO_Part_Count__c`, which I dismissed as *cutting the wrong axis* and which this evidence would
  make the right one. Or the callout leaves Apex entirely.

**I did not take the measurement**, because a context ending mid-callout would leave an unreported
result, which is worse than an unreported plan.

**Owed.** That measurement first, before any further shape work. The shape ruling stands as ruled
until evidence moves it, and this entry is the evidence starting to move it. B&V and Emerson
fixtures are loaded and unchanged; nothing has been asked of any model that wrote a row.

---

## 2026-08-03 · session 71 · measurement 1: the split fits per transaction, and output does not scale

**Did.** Corrected my own wrong line and took measurement 1. **One cold single-person call fits:
87,805 ms.** But the token numbers falsify the arithmetic that predicted it, and the correction
matters more than the pass.

### My wrong line, marked wrong

**"Off the synchronous path buys nothing alone: the 120-second ceiling is per callout, not per
transaction" — WRONG.** The ceiling is **cumulative per transaction**: Apex Governor Limits,
maximum cumulative timeout for all callouts in a transaction, 120 seconds, synchronous and
asynchronous alike. **Three sequential calls inside one `runForSource` shared one budget**, so the
per-person split could never have helped from inside a single transaction. I asserted the wrong
reading twice and built on it once. **The split was sound and the transaction boundary killed it**,
which is the opposite of the conclusion I drew in session 70.

### Measurement 1 · one cold single-person call, isolated in its own transaction

```
subject 003WD00001PmxYSYAZ   propositions 16
elapsedMs   87,805
inputTokens 18,696   outputTokens 7,339
cacheRead   0        cacheCreate 5,500
findings    1        stop=end_turn
```

**It fits under 120 seconds with about 32 seconds of headroom.** One callout per transaction is
necessary and, for a sixteen-proposition call, sufficient. Three of these in one transaction is
263 seconds against a 120-second budget, which accounts for all three timeouts exactly.

### The finding the measurement produced, which nobody predicted

**Output did not scale down with propositions.**

| | propositions | inputTokens | outputTokens | ms |
|---|---|---|---|---|
| Session 62 | **53** | 18,696 | 7,532 | 94,860 (warm) |
| Measurement 1 | **16** | **18,696** | **7,339** | 87,805 (cold) |

**A third of the propositions produced 97% of the output and an identical input count.** The
estimate of 30 to 35 seconds per person assumed output was roughly proportional to propositions;
it is very nearly constant. **The method of that estimate was right and its premise is falsified by
measurement** — which is the only way a premise should fall.

Two consequences. **The per-person split buys the transaction boundary, not a cheaper call**: each
call costs about what the whole pass used to, so N people cost N times a full pass rather than one
pass divided N ways. Emerson's roster near seventeen becomes roughly seventeen transactions of
~88 seconds. And the identical `inputTokens` across a 37-proposition difference is odd enough to
name: **the proposition tail is a rounding error against the artifact in the prompt**, which is
consistent with the artifact dominating input while generation dominates time.

**`findings=1` again, now from sixteen propositions about one person.** That is the third run to
return a single finding, and it is now clearly independent of proposition count and of the
mixed-charter defect. **It is a quality question about the charter and it has never been the same
question as the timeout.** Nothing here diagnoses it.

### Artifact-first ordering · still predicted, and now genuinely testable

`cacheRead=0` with **`cacheCreate=5,500`**: the cold call **wrote** a cache entry rather than
reading one, which is exactly what a first call should do. **A prefix hit on call two remains
predicted and unverified**, and it is now testable for the first time, because a cache entry
demonstrably exists. If call two reads near zero, the ordering falls.

### Owed

**Measurement 2, not taken: chained-Queueable stack depth in `aossb2`.** Cap is 5 in Developer
Edition and Trial orgs; whether it binds a Developer sandbox of an Enterprise org is unverified.
B&V's three clear it either way; **Emerson's ~17 would not if it binds at 5**, so it is measured
before the chain is built out, not during Emerson. Batch with scope size 1 has no depth question,
which is why Batch is the shipping shape.

Then the temporary Queueable chain — **`AAO_TEMP_`-grade, condemned in advance, marked temporary in
code and here, to be replaced by the ruled batch layer and never allowed to become architecture** —
then the B&V baseline with per-call `cacheRead`, then Emerson.

---

## 2026-08-03 · session 72 · the per-person shape is RETIRED; Extract-Bind-Verify filed as §P7.3

**Did.** Filed `docs/aao-P7.3-extract-bind-verify.md` as the authoritative statement of the
redesign until it folds into Charters. **Recorded the retirement of the per-person pass shape,
which is my own work being superseded by ruling.** Nothing built: the four-stage rebuild is the
next session's whole job and is not something to begin on a spent context.

### The ruling, and why it is obviously right

**The per-person pass shape is dead, Matthew's ruling.** Measurement 71 is the argument: one call,
16 propositions, **18,696 input and 7,339 output**, and session 62's 53-proposition call was
**18,696 input and 7,532 output.** Input is dominated by the artifact and output by prose, and the
per-person shape pays **both, N times, for the same transcript.** Seventeen people is seventeen
reads of the same 18,700 tokens. **The shape does not fail at the ceiling; it fails at enterprise
volume, and the ceiling was only how it announced itself.**

**The B&V baseline on that shape is abandoned, not deferred.** A baseline of an untenable structure
measures nothing worth keeping. Session 62 and measurement 71 stand as **history and cost data
only** — neither is a quality number for the charter or the model.

**The nothing-redesigned-mid-run rule is superseded** by this ruling, because the run it protected
no longer exists. Worth stating so a later reader does not read the redesign as the rule being
broken.

### What I got wrong, and what the sequence of errors actually was

Three readings in three sessions, each replacing the last:

1. **Session 58-60:** proposition count is the binding constraint. Wrong.
2. **Session 70:** the artifact read cold is the dominant cost, and part-splitting is the axis.
   Half wrong — the artifact dominates *input* but generation dominates *time*.
3. **Session 71, corrected by Matthew:** the ceiling is cumulative per transaction, which I had
   asserted the opposite of. **The split was sound and the transaction boundary killed it.**

And now the ruling that makes all three moot: **the shape was wrong at a level none of my three
diagnoses reached.** Every one of them was a latency question. **The real objection is cost per
Source at volume**, which no amount of transaction plumbing addresses. I optimised the inside of a
structure instead of asking whether the structure was right, three times, and each fix was
correct about the thing it looked at.

**`findings=1`, three times, was the visible edge of it.** I named it a charter quality question
separate from the timeout, which was right, and then kept working on the timeout.

### The new shape, four stages, as filed

**Stage 1 · the read.** One call per Source, strong model, artifact-first, declared families in the
tail. Output is an **inventory of potential claims** — speaker, subject handle, line anchor,
minimal verbatim span, plausible families. **No verdicts, no per-sentence quizzing.**
**Stage 2 · binding.** Deterministic fan-out where mechanical; a small call carrying **span plus
proposition and no transcript** where judgment is needed. Binding promotes Candidate to Claim.
**Stage 3 · verification.** Blind reader, **separate and smaller model**, sees claim and span only,
never the binder's verdict, gated by an adjudicated comparison run before the small model is
trusted. **Its rejection count is the over-read catch rate** — the number that decides whether the
blind reader earns its place.
**Stage 4 · unchanged.** Everything downstream of Claim stands: accumulation, `AAO_Project`,
watermarks, Option C notes, quotes on Answer rows only.

**The inventory is the Candidate layer doing what its name always implied**, which is why this
redesign costs no schema: Candidate proposes, Claim records, Answer is what is true now. Abstention
rows are written **by Apex after binding**, at zero model cost for silence.

### One ruling already satisfied, and one thing to watch

**Coverage is computed, never extracted** — already true. `AAO_PeopleContracts` skips the Coverage
family with the comment *Coverage is a P route and is not extracted from words*, so the family has
never entered a read. The 48 seeded contracts are Support and Political only.

**Watch on the epistemics sentence, recorded because it is now load-bearing:** an unextracted
statement becomes a `model_missed` abstention rather than a probed answer. **Extract-once trusts
one family-guided pass for completeness and the residual is real, bounded and chosen.** That is a
weaker completeness claim than probing every proposition, and it is the right trade — but it means
`model_missed` is no longer a rare bookkeeping case and its rate is a number the harness should
report rather than bury.

### Owed · the next session's whole job

Build in the filed order: stage 1 extractor with a hard `max_tokens` and JSON-only output; binding
with the **~90-token evidence budget** (coextensive span, room to breathe, and the budget governs
model output while stored quotes stay full-fidelity); verification on the smallest model available
through the current credential, journalling which; the Apex abstention writer. **One callout per
transaction stands**; stage 2 and 3 group sizes come from measuring one, never from hope. Per-stage
telemetry: elapsed, tokens, `cacheRead`/`cacheCreate`, and the counts.

**Then B&V end to end as the new baseline, then Emerson, then the run report.** Fixtures, ingest,
SHA-at-insert, dedup, roster, declared set, writer, invoker, command center and byte-verification
all survive untouched.

---

## 2026-08-03 · session 73 · §P7.3 built end to end; stage 1 does not fit the callout bound, three times measured

**Did.** Synced the six documents. Marked the standalone P7.3 spec superseded. **Built all four
stages of Extract-Bind-Verify and the temporary invoker, 16 new tests, 218 AAO tests green.**
Probed the model roster from Apex and measured the group sizes rather than choosing them.
**Ran B&V three times and it did not complete.** Stage 1 is the wall and the wall is measured.

### Documents synced

All six incoming files were newer by stamp and were overwritten: Board v1.3, Charters v2.4,
Architecture v3.3, Model & Flow v1.2, Glossary v2.4, CODE inbox re-stamped last. Read by path,
stamp read inside each.

`docs/aao-P7.3-extract-bind-verify.md` carries a SUPERSEDED block at its head naming Charters
v2.4 §P7.3 as the live copy. Kept, not deleted. `docs/MANIFEST.md` gained a superseded table and
its Charters row now names §P7.3.

### Probe 1 · the model path, from the calling runtime

**`claude-haiku-4-5-20251001` IS the smallest model this credential reaches.** Not assumed:

```
claude-haiku-4-5-20251001    200   4,983 ms    402 in /   136 out    2 items
claude-3-5-haiku-20241022    404   207 ms      not_found_error
```

A prior-generation Haiku is not available, so "smallest available" and "smallest current" are the
same model here and there was no judgment call to make. **Stage 3 runs on it.** Structured output
works without `output_config.effort`, so the small stages send no effort key at all.

### Probe 2 · group sizes, measured, ruling 6

Twelve realistic items per call, cold, from Apex:

| stage | model | items | ms | in | out |
|---|---|---|---|---|---|
| 2 bind | claude-sonnet-5 | 12 | 13,610 | 1,252 | 1,188 (562 thinking) |
| 3 verify | claude-haiku-4-5 | 12 | 6,444 | 927 | 428 |
| 3 verify | claude-haiku-4-5 | 2 | 4,983 | 402 | 136 |

The haiku pair gives ~146 ms per item on ~4,690 ms of fixed overhead: these calls are
generation-bound, not item-bound. Sonnet is ~1,140 ms per item. **Group sizes set so predicted
elapsed is under half the ceiling: bind 24 (~29 s), verify 60 (~13 s).** Both live in config with
the measurement in the record's own comment, and `AAO_EBV` REFUSES to run a stage whose group
size is unset rather than defaulting — a constant in Apex would launder a guess.

### Built

`AAO_InventoryCharter` (stage 1), `AAO_BindCharter` (stage 2), `AAO_VerifyCharter` (stage 3),
`AAO_EBV` (the state machine and the report), `AAO_EBV_TEMP_Batch` (the invoker, condemned in its
own name), `AAO_EBVTest` (16 tests). Eleven config fields plus a twelfth added mid-session.

**Stage 4 is not a reimplementation.** `AAO_Pipeline`'s tail was EXTRACTED into
`commitProposals` and both `runForSource` and `AAO_EBV.stage4` call it. "Unchanged" is only true
if it is the same code.

**The read is guided by 16 FAMILIES, never by 48 per-person codes**, and a test asserts no
per-person code reaches the read through either entry. That is what makes the prompt independent
of roster size: three people is sixteen families and seventeen people is still sixteen.

**Separation is enforced, not requested.** `requireSeparateModels` throws before the callout if
the bind and verify models match, because the same reader asked twice produces a worthless
rejection count.

### Measured · the B&V run, three attempts, all recorded

Cleared the voided session-62 ledger first: 48 rows, every one `Not_Returned` /
`not_returned` / `AAO_Extract_Evidence@1.1.0`, zero claims on the Source. Deleted, counts
verified before and after. **Design note: the open question "can a void pass be marked void in
the org" is exactly this situation, and marking would have been better than deleting. There was
nothing to mark with.**

| run | stage 1 max_tokens | callout ms | in | out | cacheCreate | stop |
|---|---|---|---|---|---|---|
| 1 | 16,000 (shared) | **120,183 — CEILING** | — | — | — | `Read timed out` |
| 2 | 6,000 | 78,567 | 18,696 | 6,000 | 3,431 | **`max_tokens`** |
| 3 | 7,500 | 86,659 | 18,696 | 7,500 | 3,629 | **`max_tokens`** |

**Run 1 was my defect, twice over, and both are fixed.**

1. **`max_tokens` 16,000 on stage 1 could never have fitted.** At the generation rate measurement
   71 already showed (~84 tok/s), 16,000 tokens is ~190 seconds against a 120-second ceiling. The
   journal owed "a hard `max_tokens`" since session 72 and I shipped the shared 16,000 instead.
   Stage 1 now has its own bound, derived from the rate.
2. **The subject vocabulary was the whole 44-person roster.** The B&V deal has 44 map rows and
   contracts for three people, so the read was handed 41 handles that could not bind to anything:
   every item about one of them would have been generated, paid for, counted, and then dropped at
   `no_contract`. **The declared-set law was obeyed on the family axis and broken on the person
   axis in the same prompt.** The subject set is now derived from the families themselves.

**Runs 2 and 3 are the finding, and it is not a defect.** With both fixes in and the ruled
~90-token evidence budget added to the stage 1 prompt — where it had been MISSING, another
omission of mine; the bind charter had a word budget and the stage that actually produces spans
had the word "minimal" and no number — **the read still wants more than 7,500 output tokens on an
18,696-token artifact.** It truncates rather than times out, which is the better failure but is
still no pass.

**I stopped raising the number.** The config comment written before run 3 said 7,500 was the last
raise available and why: ~9,180 tokens is the arithmetic wall at the naive rate, and nothing above
~8,000 leaves margin for the variance that produced three timeouts on 3 August. Dialling past a
bound I set from measurement would be the local-fix hazard with my own name on it.

### The blind spot that makes the finding ambiguous, and it was mine

**`output_tokens` INCLUDES thinking tokens, and thinking counts against `max_tokens`.** My
telemetry never broke them out. So "the read wants more than 7,500 output tokens" has two readings
that I cannot currently separate:

- a large inventory, honestly produced, that one bounded call cannot carry; or
- a small inventory behind a large deliberation at `effort=high`.

These have opposite fixes. **Measurement 71's 7,339 output tokens carries the same ambiguity**,
which means a number three sessions have reasoned from has never been decomposed. The sonnet
bind probe reported `thinking_tokens: 562` of 1,188 — 47% — so this is not a hypothetical.

`AAO_Extract.Usage` now reads `output_tokens_details.thinking_tokens` and every telemetry line
carries it. **Deployed and unexercised against a live call: the next stage 1 measurement is the
first one that can answer the question.** Named rather than implied.

### Not done, and why

**EMERSON DID NOT RUN, AND IT IS BLOCKED ON AN ARTIFACT NOBODY HAS.** The fixture is seeded — 2
Accounts, 168 Contacts, 2 Opportunities, contact roles — and there is **no Source and no
transcript text.** `seed/emerson-fixture/videocall.json` carries VideoCall metadata, 3
participants and 2 recording rows and no speech. Manifest item 5 stands unchanged: the canonical
transcript is a blob behind the ECI media endpoint, not SOQL-readable, and neither branch (a)
retrieval nor branch (b) paste has landed. The zip carried five documents and the inbox. **I did
not manufacture a transcript to run against, and there is no other way to run Emerson.**

**The B&V baseline does not exist either.** Three runs, no pass, no claims, no rows. The board's
"B&V on the new shape is the baseline" is still owed and stage 1 is the only thing standing in the
way — stages 2, 3 and 4 have never been reached by a live call.

### Named for design, not diagnosed alone

1. **`findings=1` rides in unexplained, as instructed, and this shape cannot yet speak to it.**
   The pass never reached binding, so there is no finding count to compare. It is neither
   confirmed nor cleared by anything here.
2. **FALSE is unreachable from the chartered bind vocabulary.** §P7.3 names three verdicts and I
   implemented three. `does_not_establish` maps to UNVERIFIED, which is right for a missing
   confirmation and wrong for a positive denial — they land on the same value. **The
   TRUE-strong / FALSE-weak guard on two-sided questions therefore has no FALSE input in this
   shape.** Not patched: adding a fourth verdict would be redesigning the pass mid-build.
3. **`model_missed` is un-retired by ruling and the run-time number is a LOWER BOUND.** It was
   retired 31 July as ambiguous between two judgments about evidence; §P7.3 gives it a third
   meaning that is neither — a statement the read produced and the pass then lost. Apex can only
   see the misses in its own record, so **adjudication can move rows INTO the class and never
   out**, and the report says so on the line that carries the rate. The field description records
   the un-retirement with the old objection kept and marked.
4. **The stage 1 output bound is a structural question, not a dial.** If the inventory on an
   18,700-token artifact genuinely exceeds what one bounded callout can generate, then
   extract-once needs either a lower effort, a tighter item budget, or an artifact axis — and the
   last of those is the part-splitting I was told was the wrong axis. Design's to rule.

### Standing

204 tests became **218, all green** (237 org-wide, one pre-existing failure in
`ConvertToOpportunityTest` on an `AE_Summary__c` validation rule, untouched by this session and
nothing to do with AAO). Production never read. Nothing on native or ALTF objects. The invoker's
end-to-end behaviour past slot one is **unverified from the calling runtime** — no test can drive
six slots, because Apex refuses more than one `executeBatch` per test method.

**Owed, in order.** Decompose the stage 1 output with the thinking-token line now in place; that
one number decides whether this is an effort problem or a structural one. Then B&V. Then Emerson,
which needs a transcript before anything else. Then the run report with receipts, which this entry
is the honest partial form of.

---

## 2026-08-03 · session 74 · the thinking tokens answered it, and the answer moved the defect twice

**Did.** Decomposed stage 1's output and found the three-session premise was false. Swept effort,
found no setting that both fits the ceiling and reads reliably, and **stopped dialling.** Rewrote
the stage 1 charter, measured that the rewrite did not work, and stopped again. Packaged and
seeded the Emerson transcript. **Ran Extract-Bind-Verify end to end for the first time**, reached
stage 4, and found that no span on either artifact can ever project. Fixed that, and proved the
fix without a model call. **No baseline exists and nothing here is one.**

### Measurement 1 · the number that was on the wire the whole time

`AAO_Extract.Usage.thinkingTokens` was deployed and unexercised at the end of session 73. First
live read:

```
stage1_read  85,637 ms  in=18,696  out=7,500  thinking=7,500  cacheCreate=3,629  stop=max_tokens
```

**Thinking was 100% of output. The read emitted no content at all.** Not a truncated inventory:
no inventory. Three sessions read that wall as "the artifact yields more evidence than one
bounded call can carry" and it was never a statement about the inventory. The config comment
that predicted "extract-once on an 18,700-token artifact does not fit one bounded Apex callout"
is **marked wrong in place** and kept.

### Measurement 2 · the effort sweep, and there is no setting that works

`AAO_Inventory_Effort__c` added so stage 1 stops sharing `AAO_Effort__c` with the legacy path.

| effort | wall ms | out | thinking | items | stop |
|---|---|---|---|---|---|
| high | 85,637 | 7,500 | 7,500 (100%) | 0 | `max_tokens` |
| medium | 82,128 | 7,500 | 5,171 (69%) | — | `max_tokens` |
| low | 12,503 | 702 | 0 | 8 | `end_turn` |

**The inventory is ~700 to 1,900 output tokens.** The writing was never expensive; the reading
is. `medium` cannot fit the ceiling on this artifact — 7,500 tokens already cost 82 s and
completing it needs ~100 to 110 s against 120 — and there is no level between `low` and `medium`.

### Measurement 3 · `low` fits and is not reliable, and the charter rewrite did not fix it

Five identical runs, cache warm after the first. Charter 1.0.0: **8, 0, 0, 0, 20** items. Three
of five returned a well-formed, complete, EMPTY inventory in 53 to 86 output tokens.

It is not honest emptiness. The declared set is 48 contracts, 16 families about **three people
who are the three external speakers on the call** — Ashley Stroud (173 first-name hits), Adam
Meloan (140), Robbin Jones (56). The artifact is saturated with exactly the people being asked
about.

Charter **1.1.0** added the coverage rule: 1.0.0 carried nine prohibitions and not one
instruction to be exhaustive, which a model scoping work to the minimum satisfies by returning
nothing, and §P7.3 is find-then-bind-then-verify so the finding stage was doing the filtering the
verifier exists to do. Five runs at 1.1.0: **0, 2, 0, 0, 14.** Four more on the NF1 source: **0,
0, 0, 0.**

**It did not work, and the fix is left in place and reported as not working.** Across 14 runs,
4 were non-empty. The defect has now survived six fixes (three bound raises, subject-vocabulary
narrowing, the evidence budget, the effort change, the coverage rule) and the local-fix hazard
says that makes it the shape. **Design's to rule. I am not rewriting the prompt again.**

### The first end-to-end run, and what it found at stage 4

Stage 1 drew 16 items and the pass reached `done`. Stages 2, 3 and 4 had never been touched by a
live call before this.

```
stage1_read#1   items=16  45,524 ms  in=18,696  out=2,828 (thinking=1,294)  cacheRead=3,995
stage2_bind#1   items=24  60,728 ms  in=4,476   out=5,974 (thinking=4,690)   claude-sonnet-5
stage2_bind#2   items=18  53,486 ms  in=3,713   out=5,054 (thinking=3,970)   claude-sonnet-5
stage3_verify#1 items=10   5,925 ms  in=1,550   out=474   (thinking=0)       claude-haiku-4-5
TOTAL calls=4  165,663 ms  in=28,435  out=14,330
```

- **The measured bind group size is wrong.** Session 73 predicted ~29 s for 24 items; it took
  **60.7 s**, better than half the ceiling gone on one call. The prediction is falsified by the
  run exactly as its own comment said it would be. Not re-tuned yet.
- **The blind reader earned its place: 6 of 10 rejected, 60%.** Over-reading is the expected
  failure mode and the instrument caught it on its first live outing.
- Spans dropped not found: **0**. Byte verification passed on every span.
- `model_missed` **0**, and it is a lower bound by construction.

### THE FINDING · no span on either artifact can ever project

48 Candidates written, **0 Answers**. Every one of the 13 non-abstention candidates carries
`AAO_Outcome__c = Span_Failed`: 3 TRUE and 10 UNVERIFIED, plus 28 `nobody_said` and 7
`model_declined` abstentions.

`AAO_NormalForm.turns()` segments an Attributed artifact by splitting on newline and taking the
text before the first **TAB** as the speaker key; a line with no tab contributes no turn, and its
own comment calls that "a defect in the normaliser, not something to guess at".
`AAO_NormalForm.compose()` states the shape: `speakerKey + '\t' + utterance`, one turn per line.

Both artifacts were packaged in the ECI viewer's block layout instead:

```
bv/biweekly-2026-06-24        len=46,551  TABS=0  TURNS_FOUND=0
emerson/aspentech-2026-07-29  len=21,320  TABS=0  TURNS_FOUND=0
```

**Zero turns parse, so `containing()` returns null for every range and `AAO_SpanVerifier` fails
every span on contiguity AFTER the byte compare has already passed.** This is independent of
stage 1's instability and independent of effort: the B&V pass could never have projected, in any
session, at any setting. The Candidate layer has been written all along and the projection gate
has never once been passable on this artifact.

**Proved deterministically, no callout**, by taking real spans from the run above and putting
them through the same verifier against both artifacts:

| artifact | turns | byte compare | contiguity |
|---|---|---|---|
| `bv/biweekly-2026-06-24` | 0 | true ×3 | **FAIL (null) ×3** |
| `bv/biweekly-2026-06-24-nf1` | 489 | true ×3 | **PASS ×3**, speakers resolve correctly |

### Built and seeded

- `AAO_Inventory_Effort__c`, with the measurement in the field description.
- `AAO_InventoryCharter` **1.1.0**, the coverage rule, reported above as not having worked.
- **Emerson transcript packaged**, `normalize.py`, machine-piped rather than hand-transcribed
  because the Emerson fixture manifest names hand transcription as where slippage enters. 221
  turns, three speakers matching `videocall.json` exactly, 220 viewer-chrome lines and **7 ECI
  signal tags** removed to a sidecar. The tags are Einstein's inference, not speech; leaving them
  in would let a reader quote a machine's label as a human's sentence **and pass byte
  verification doing it**, which is a fabrication route rather than an over-read. All ASR noise
  kept verbatim (`Koopa`, `CUPA`, `Anne Fatima`, `Fat, am I gonna sign it` for Pat, `the signs
  SOW`). `Setup.` at 16:11 kept as speech and flagged.
- Sources: **SRC-00000032** (block layout, superseded), **SRC-00000033** Emerson NF1 (221 turns),
  **SRC-00000034** B&V NF1 (489 turns). SRC-32 stands because `AAO_Artifact_SHA256__c` is
  `FROZEN` and Sources leave by retirement, never deletion — three laws, each right, and the
  handler's own comment already settled an identical case: *"No immutability exception exists or
  will. The recorded history stays."*
- **A second fingerprint measurement:** LongTextArea strips a trailing newline, so a delivered
  file and its stored text carry two different SHA-256s, both correct about different things, and
  **spans verify against the stored one**. Recorded in the Emerson manifest rather than hidden.

### Not done, and why

**EMERSON DID NOT RUN.** The artifact exists, is well-formed and is seeded. **There are 48
`AAO_Evidence_Contract__c` rows in the org and all 48 point at the three B&V contacts. Zero exist
for any Emerson person**, so `AAO_ApplicableSet.resolve` returns empty and stage 1 throws before
any callout. Contract generation is mechanical (`AAO_PeopleContracts`, one per question per
person, from our own ontology); the free input is **which people**, which is the unbuilt
resolver's decision and is hand-scaffolded. Applying the B&V precedent mechanically (external
speakers with Contacts) yields **one person**: Couture. Vargas, the most active buyer-side voice
on the call, **has no Contact at all**, and everyone the adjudication is about — Neeraja, Fatima
(two candidates), Corey (weak), Jacob (none) — is mentioned-but-absent, which the board lists as
unruled and colliding with the person-row boundary law. **Design's, and it changes what the run
tests.**

**No baseline.** The one completed pass ran against an artifact that could not project, and
stage 1 is not reliable enough for a repeatable run regardless.

### Named for design

1. **The stage 1 read is unstable at the only effort that fits the ceiling**, and six fixes have
   not moved it. Six of fourteen measured runs produced anything at all. This is the shape.
2. **The normal form and the packaged artifacts disagree**, and the disagreement silently
   disabled projection for every run before this one. NF1 conversion is done for both; the frozen
   originals stand as history.
3. **The bind group size is falsified** — 60.7 s measured against ~29 s predicted, on a 120 s
   ceiling. Needs re-measuring before any run is trusted for latency.
4. **A 60% verification rejection rate** on the binder's first live outing. The instrument works;
   whether the binder is that over-eager or the verifier that strict is one adjudication away.
5. **`findings=1` is still unexplained** and this session cannot speak to it, but `0, 0, 0, 8,
   20` is the same instability wearing different clothes and they should be considered together.

### Standing

Production never read. Nothing on native or ALTF objects. `AAO_Ingest.AUTO` held false around
every seed so the legacy pipeline never wrote under the old charter.

**Tests re-run after the 1.1.0 charter edit and the `AAO_Extract` change: 239 org-wide, one
failure, and it is the same pre-existing `ConvertToOpportunityTest.testgetOppCreationDetails`
`AE_Summary__c` validation failure session 73 recorded — untouched by this session and nothing to
do with AAO.** `AAO_EBVTest` and `AAO_ExtractTest` are 37/37. The coverage rule and the new
effort field broke nothing, which is worth saying plainly and is also not evidence that either
of them works: the tests assert the charter's structure, and what 1.1.0 failed to change was the
model's behaviour.

---

## 2026-08-03 · session 74 · THE PROJECTION PROOF · NOT A BASELINE

**Read this heading as a fence.** Matthew ruled that a projection proof is not a baseline and
that he wanted one anyway. This is that, and nothing in it is a measurement of anything. The
stage 1 instability recorded above **stays open and unfixed**; this run does not close it, does
not reduce it, and must never be cited as evidence about it. What it establishes is one thing
only: **that the chain from artifact to relationship map is connected and, when stage 1 draws,
carries evidence the whole way.**

### The draw

Ran B&V on the NF1 Source (`SRC-00000034`) until stage 1 returned items. **Attempt 5.** Attempts
1 to 4 each returned a well-formed empty inventory and completed in about six seconds.

```
attempt=1  job=707WD0000A5GvVSYQ0  nonAbstentionCandidates=0
attempt=2  job=707WD0000A5GqpSYQS  nonAbstentionCandidates=0
attempt=3  job=707WD0000A5GshzYQC  nonAbstentionCandidates=0
attempt=4  job=707WD0000A5GrVPYQ0  nonAbstentionCandidates=0
attempt=5  job=707WD0000A5GuwEYQS  nonAbstentionCandidates=6   <- the draw
```

**Four empties then a draw is the instability doing exactly what it does.** It is not a hit rate.

### The pass · `stage done`, 5 calls, 237.2 s

```
stage1_read#1   items=25  45,095 ms  in=16,740  out=2,690 (thinking=0)      cacheRead=3,995
stage2_bind#1   items=24  69,155 ms  in=4,644   out=6,786 (thinking=5,565)  claude-sonnet-5
stage2_bind#2   items=24  71,797 ms  in=4,651   out=7,364 (thinking=6,003)  claude-sonnet-5
stage2_bind#3   items=15  42,922 ms  in=3,324   out=3,816 (thinking=2,979)  claude-sonnet-5
stage3_verify#1 items=16   8,275 ms  in=2,058   out=780   (thinking=0)      claude-haiku-4-5
TOTAL calls=5  237,244 ms  in=31,417  out=21,436
```

| | |
|---|---|
| inventory items | 25 |
| spans dropped, not found | **0** |
| bindings attempted | 63 |
| established by binder | 16 |
| **verification rejections** | **9 of 16 (56.3%)** |
| claims established | 6 |
| abstentions | 31 (nobody_said 23, model_declined 8, **model_missed 0**, a lower bound) |

**The bind group size is falsified harder than before.** 69.2 s and 71.8 s against a ~29 s
prediction, on a 120-second ceiling. One slow call away from a timeout. Owed a re-measurement
before any run is trusted for latency; not re-tuned here because that would be a measurement and
this is a proof.

### Candidate to Answer to map · it connects

**6 Answers written**, all TRUE, all Live, all `MACHINE`, all `covered:["e1"] missing:[]`, all
from candidates the blind reader marked **Upheld**. Before this run the deal carried **0**
Answers and **44 map rows with 0 populated**, so everything below is unambiguously this run.

`AAO_Project.run` → **0 created, 1 populated, 0 blocked, 2 unchanged.**

| person | code | question | quote |
|---|---|---|---|
| **Adam Meloan** | PO9 | aware of the politics | *"is Steve, Steve's having a lot of these kind of like leader meetings, isn't he?"* / *"I'd say Chris, Steve, and Patrick start there and then they can kind of bring the right people in"* |
| **Adam Meloan** | **PS7** | **collects and provides information to people of power** | *"That needs to go to Scott and Matt and Brian. Like that's Matt, that was a very specific ask from Matt last week. So I just want to make sure we keep that moving."* |
| **Adam Meloan** | S1 | preference for a specific solution | *"what I'm trying to do is just eliminate clicks"* |
| Ashley Stroud | PO9 | aware of the politics | *"I know Steve, it's very important to Steve that we advance this…"* / *"Steve and Patrick, and then I think Elizabeth might have some input here…"* |
| Ashley Stroud | S1 | preference for a specific solution | *"I think we can do both… we have to do a tier one scorecard, but we also can use MCP to accelerate inputs."* |
| Robbin Jones | S1 | preference for a specific solution | *"use your components that you guys to Altify design components that you have for like all your other buttons so that it can be consistent"* |

**The one map value that landed:**

```
Adam Meloan   ALTF__Political__c = Outside Political Structure
              ALTF__Note__c      = Political: Outside Political Structure — Adam Meloan, 24 June 2026
              ALTF__Political_Last_Modified__c = 2026-08-03 23:27:03
```

**One of 44 rows carries a value. Ashley and Robbin are `unchanged`, and that is correct rather
than a failure.** `POL_BROKER` is PS7, which is what places Adam Outside Political Structure; PO9
"places nobody and is not consulted"; S1 "opens the reading and places nobody". Ashley holds PO9
and S1 only, Robbin S1 only, so neither has anything that places them. The derivation did what
the charter's table says.

**The map note carries no quote by design** — `citation()` composes speaker plus date, and the
class says it "degrades to naming the value alone rather than truncating a quote, because a
clipped quote is at the edge of the paraphrase law." The quotes live on the Answer rows, one read
away, and are tabled above.

### TWO NEW DEFECTS, named rather than worked around

**D1 · A span the blind reader refused survives onto the standing Answer as a citation.**
`PO9#Ashley Stroud` carries two spans, both element `e1`. The blind reader **refused the first**:

> *blind reader refused: quantity: Span mentions Steve's preferences and MCP opportunity, but does not assert awareness of organisational politics.*

`e1` is covered by the surviving span, so the TRUE verdict is right. **But the Answer's span set
is the union and still cites the refused quote.** The refusal is recorded in the interpretation
and prunes nothing. A customer reading why an answer stands would be shown a quote this system's
own verifier judged insufficient, which is the one thing the blind reader exists to prevent.
Verdict correct, citations polluted. **Not patched.**

**D2 · `AAO_Project.citation()` reads `spans[0]` unconditionally.** The note's attribution is
taken from the first span in the list with no regard to whether that span survived verification.
Harmless on this run because both of Ashley's spans are hers and she was not projected anyway,
but the person credited on a customer-visible note can be drawn from a refused span. **Not
patched.** D1 and D2 compound: D1 leaves refused spans in the set, D2 reads position 0 out of it.

### What this proves and what it does not

Proves: NF1 fixed the span gate; Candidate → Answer → `ALTF__Contact_Map_Details__c` is
connected; the blind reader rejects at scale (56.3%) and the survivors project; the derivation
tables place people the way the charters say.

Does not prove, and must not be read as: any rate, any coverage number, any latency budget, or
anything at all about stage 1. **There is still no baseline.**

---

## 2026-08-04 · session 74 · two answers to the adjudication sheet

### S2 for Adam Meloan · `Abstained` / `nobody_said`

Asked which of three things happened. It is the first, and the least like a model failure:

```
S2#003WD00001PmxZ7YAJ  outcome=Abstained  reason=nobody_said
                       proposed=None  spans=None  interpretation=None  coverage=None
```

**No model was ever asked.** Stage 1 surfaced no item that bound to S2 for Adam, so it never
reached the binder and never reached the blind reader. Apex wrote the silence at zero cost, which
is what the charter says to do.

**The reason string overstates what was established.** `nobody_said` asserts the transcript is
silent. What is actually established is that this draw of stage 1 did not surface it. Nothing in
the pass can separate those, and `model_missed` was reported 0 — a lower bound by construction.
S2/Adam is therefore recorded as silence on the authority of a read that returned nothing at all
in ten of fourteen runs this session.

**This is the consequential abstention, because S2 is the only Support question with placement
power.** `supporter = t.contains('2')` and Mentor needs `{2,4,5}`. Adam's Support row: S1 TRUE
(places nobody), **S2 nobody_said**, S4 model_declined, S5 blind-refused, and S6/S7/S11/S14/S16
nobody_said. That is the whole reason `ALTF__Status__c` is null and only Political landed. **The
one question that could have placed him was never put to a model.** The mirror of the sheet's S1
finding: S1 is high cost, zero placement power and majority wrong; S2 is total placement power
and silently did not run.

### The "missing 1" · a unit mismatch in my report, not a lost claim

`16 − 9 = 7` was never required to equal `6`. The counters are in two units:

| counter | increments per | unit |
|---|---|---|
| `establishedByBinder` = 16 | `BindItem` in the bind group | **item** |
| `verificationRejections` = 9 | verify item; denominator `verifyPlan.size()` = 16 | **item** |
| `claimsEstablished` = 6 | proposal in `byCode.values()` with verdict TRUE | **(contract, person) pair** |

Corroborated in the org: the 6 Upheld pairs carry **10 spans** between them, and **7 pairs carry
a refusal note against 9 rejections**, so at least two pairs had more than one refused item and
`AAO_Interpretation__c` keeps only the last one written.

**DEFECT, MINE: `report()` prints item-unit and pair-unit counts adjacent with no label**, which
is what made the sheet compute a phantom. Not patched in this entry; named so the fix is one
change and not a rediscovery.

### Correction to the sheet's §3, rows 1 and 2

Rows 1 and 2 display the same span for PO9 and PS7. PS7's establishing span is *"That needs to go
to Scott and Matt and Brian. Like that's Matt, that was a very specific ask from Matt last week.
So I just want to make sure we keep that moving."* Both pairs carry two spans and the display
truncated to the shared first one. The grades are unaffected; the quote attributed to PS7 in the
sheet is not the one that established it.

### Full disposition of all 48 pairs, attempt 5

| outcome | reason | n |
|---|---|---|
| Abstained | nobody_said | 23 |
| Abstained | (UNVERIFIED) | 11 — of which **6 blind-refused**, **5 binder-UNVERIFIED** |
| Abstained | model_declined | 8 |
| Upheld | — | 6 |

**The 9 rejections are still ungraded and remain the highest-value ungraded evidence**, exactly as
the sheet says. Note for whoever grades them: 5 of the 11 UNVERIFIED never reached the blind
reader at all — the binder itself declined — so the blind reader's catch rate must be computed
against the 6 it refused plus the 3 refusals absorbed by pairs that survived, not against 11.

---

## 2026-08-04 · session 75 · the watermark question answered · three symptoms, one omission

Inbox item 1, taken first because it decays.

### It was never written

**Zero of the six Answers on the B&V deal carry `AAO_Projected_Value__c` or
`AAO_Projected_Modstamp__c`**, although `AAO_Project.run` populated Adam Meloan's map row at
`2026-08-03T23:27:03Z`. `AAO_Project` **reads** `AAO_Projected_Modstamp__c` (in `lastProjected`)
and **never writes** it or the value. The projection wrote to the customer surface and recorded
nothing on our own row saying it had.

### The omission disables the human-edit law

```apex
/** A human edit beats the machine forever. ... */
private static Boolean humanEdited(Datetime nativeStamp, Datetime ourLastWrite) {
    if (nativeStamp == null || ourLastWrite == null) { return false; }
    return nativeStamp > ourLastWrite;
}
```

`ourLastWrite` is `lastProjected(answers)`, the max `AAO_Projected_Modstamp__c`. Never written, so
always null, so **`humanEdited` always returns false and "a human edit beats the machine forever"
never fires.** The doc comment's carve-out is right and is being applied universally: it says a
row we have never written is "deliberately treated as ours to write", and because the field is
never written **every** contact is treated as first contact. A second pass would silently
overwrite a seller's hand edit. That is why this blocks a second pass on B&V, and the block is
real.

### The same omission is why command centre §6 renders `off`

§6 queries `AAO_Answer__c WHERE AAO_Projected_Value__c != null` and sets
`isOn = !rows.isEmpty()`. The field is never written, so the query returns nothing, so the panel
reads `off` and "No projections yet on this record" **while Adam's map row is populated**. §6
counts *answers carrying a projection watermark*, not map rows written, and those two have
silently diverged. One omission, three symptoms: no watermark, no human-edit protection, a
command centre blind to a projection that happened.

### CORRECTION to the inbox: for this run the modstamp IS reconstructible

The inbox records "the modstamp cannot be reconstructed later." **For this run it can.** The map
row carries `ALTF__Political_Last_Modified__c = 2026-08-03T23:27:03Z`, the package maintains that
stamp on API writes (Architecture v2.2, step 0 probe), and this row went from **0 populated to 1**
in our write — so that timestamp is ours and nobody else's. The two Answers behind the political
placement (PO9 and PS7 for Adam) can be stamped with it.

**Offered, not done.** Backfilling a watermark from a native stamp is inference standing in for a
record, and the standing rule is one input is never the answer. Design's to rule whether the
backfill is legitimate or whether B&V's second pass waits for a clean re-projection.

### Ruling 2 collides with existing data, and the harness will catch it

T7 asserts **"no abstention row exists anywhere (a query proving zero such rows is itself a
test)"**. The org holds **122 `AAO_Candidate__c` rows with `AAO_Outcome__c = 'Abstained'`, of 150
total**, all written by the retired shape. As written, T7 fails on contact regardless of what the
new pass does. Named rather than pre-emptively purged: this org's standing laws are that wrong
text is marked wrong rather than deleted and that Sources leave by retirement, so a mass delete is
not mine to assume.

### The 17 June fixture carries two fingerprints, and T0 should say which it asserts

| | bytes | sha256 |
|---|---|---|
| file as delivered | 42,785 | `c6d056ba…9196` (the addendum's number) |
| stored after `LongTextArea` | 42,784 | `ec8e7170…5a5f` |

The file ends with a trailing newline; `LongTextArea` strips it on save, measured session 73 and
now hit for the third time. Both numbers are correct about different things and **spans
byte-locate against the stored one**. T0's determinism assertion is satisfiable as written if it
targets the normalizer's in-memory output; it is not satisfiable against the stored artifact. One
clarifying line in the harness prevents a one-byte failure being read as a normalizer bug.

---

## 2026-08-04 · session 75 · addendum 02 synced; the re-paste is the retired artifact, not a second path

### The four answers, absorbed

Watermark backfill **refused**, and the reasoning is better than my offer: a watermark reconstructable
from a native stamp makes reconstruction available where the chain is *not* provable, and replay over
claims already re-projects for real. **Law: a watermark is written by the writer or it does not
exist.** The 3 August run stands as a projection made before the writer wrote watermarks.

T7 **scoped to the run** by provenance, not date, with the excluded count printed. The 122 legacy
`Abstained` rows stand as the decision log. T0's hash: **the stored form is canonical**, artifact
reissued, `ec8e7170` asserted and `c6d056ba` retired rather than corrected, because it named a file
that no longer exists. New law, third bite: **a normalizer's output contract is the stored form** —
any transform the platform applies on save is applied by the normalizer first, so what we hash, store
and verify against are one thing and never three. Pair ledger ratified as `AAO_Pair__c` with two
refinements I did not propose and both of which close real holes: **stage as an explicit picklist**
(`Located`/`Identified`) rather than inferred from a null lookup, and an **occurrence ordinal** on the
located row so a string matching more than once can say which match it is. Contracts: **mint 17,
supersede the 48, delete nothing.**

### The reissued artifact verifies

`ec8e7170…5a5f` · 42,784 bytes · 415 lines · 415 tabs · **0 no-tab lines** · no trailing newline.
Independently recomputed here and matching the addendum. The retired file is kept beside it as
`RETIRED-c6d056ba-…` rather than overwritten.

### The pasted transcript is the RETIRED artifact, and I nearly framed it as a second intake path

A transcript arrived pasted in full. It is the same 17 June call, and I checked before treating it as
new:

| | turns | speakers | sha256 |
|---|---|---|---|
| pasted | 415 | the five, snake-key | **`c6d056ba`** |
| retired artifact | 415 | identical | **`c6d056ba`** |
| canonical artifact | 415 | identical | `ec8e7170` |

**The paste is byte-identical to the retired artifact**, and identical to the canonical one after the
trailing newline. Utterance-set difference is zero in both directions; sequence similarity 1.0000.
Kept as `CONFIRM-repaste-reproduces-retired-c6d056ba.txt`.

**So there is still exactly one intake path, and T0's convergence diff still has nothing to converge.**
I had started to write this up as Path B2 before checking, which would have reported a convergence
test that never happened.

**What it does prove, and it is worth having:** the reissue changed *only* the trailing newline.
Nothing in the 415 turns moved. A reissued artifact could in principle have carried content changes
under cover of a hash change, and now it demonstrably did not.

**Path A remains untried.** The Get Conversation Transcript action has still never been called from
Apex, so hand-carried artifacts remain the only proven intake and the convergence assertion stays
unexercised.

---

## 2026-08-04 · session 75 · Charters v2.8 synced · the cheap count partly BREAKS the findings=1 explanation

### v2.8 in, delta applied surgically

Charters v2.8 arrived as a paste rather than a file. Rather than retype 199 KB — which is the
paraphrase hazard this build exists to refuse — the delta was applied against exact v2.7 anchors:
the v2.8 head stamp, §P8's title, §P8.4's counter paragraph, §P8.5's tightening, and §P8.9 whole
(which sits between §P8.7 and §P8.8, as delivered). **Verified: everything from `PART I` down is
BYTE-IDENTICAL to v2.7**, so the edit touched only what it claimed to. **A file would still be
better than a paste for the authoritative copy and is worth sending when convenient.**

### Inbox item 3 · the cheap count · UNIT: pairs, not bind items

The 16 established **items** sat across **12 pairs** (contract × person). Unit labelled at the
point of print, per the unit law.

| | established pairs | upheld | refused |
|---|---|---|---|
| **placing-nobody** (S1, PO9) | 5 | **5** | **0** |
| **projecting** (PS4, S5, PS7, PO2) | 7 | **1** | **6** |

By code: S1 ×3 and PO9 ×2 place nobody; PS4 ×3, S5 ×2, PS7 ×1, PO2 ×1 project.

### THE RESULT PARTLY BREAKS THE HYPOTHESIS, and the correction matters

The structural explanation on record is *"the read establishes gate questions that place nobody
and misses placement questions."* **The first half does not hold. The read established projecting
questions at 7 of 12, a clear majority.** It was not blind to placement.

**Every single pair the blind reader killed was a projecting question. Not one placing-nobody pair
was killed.** The one placing-nobody pair that drew a refusal at item level (PO9/Ashley) survived
anyway, because a second span covered the element. So the surviving claim set inverts: **5 of 6
upheld pairs place nobody, and exactly one projecting claim survived the whole pass** — PS7,
which is the single map value that landed.

**So the loss is at verification, not at the read.** The read finds placement evidence; the blind
reader refuses it at 6 of 7 while refusing placing-nobody evidence at 0 of 5.

### What this does NOT establish, stated because the numbers are small

Seven and five. **The asymmetry may be the verifier working correctly rather than failing:**
projecting questions are narrower claims (controls the outcomes, sells internally, approves and
sponsors) and are genuinely harder to carry coextensively than "aware of the politics" or
"expressed a preference". A reader that refuses the hard ones more often is doing its job. The
count cannot separate *the verifier is too strict on placement* from *placement claims are
actually weaker*, and **the 9 item-refusals remain ungraded**, which is exactly the evidence that
would separate them, and exactly what the adjudication sheet already names as the highest-value
ungraded material.

**Recorded as a finding with its denominator and its ambiguity, not as a verdict.** It relocates
the question from the read to the reader, which changes where the next measurement points.

---

## 2026-08-04 · session 75 · the fix bundle · one repair, four symptoms, verified on real data

### D1 · verification status per span

`AAO_Model.Span` gains `verification` (`UPHELD` / `REFUSED` / null) and `AAO_Model.upheld()` is
the one filter every reader calls. Stage 4 stamps each span from `verifyOk` **at the item that
was actually verified**, not from the pair's conclusion — which is the whole point, because a
pair can survive on one span while another was refused, and before this the refused one stayed on
the Answer as a citation.

**Refused spans are kept and marked, never deleted**, per design's lean and the standing law.
Null passes the filter deliberately: legacy rows predate the field, and treating unknown as
refused would silently blank every citation written before today. **Only REFUSED is refused.**

This also closes a data loss the defect caused: `AAO_Interpretation__c` is one field and kept only
the **last** refusal per pair, so of the 3 August run's 9 item-refusals, **7 are recoverable and 2
were overwritten** — and the logs that held them aged out (oldest retained is 4 Aug 05:00). Per-
span status means that cannot recur.

### D2 · the note's attribution

`AAO_Project.citation()` read `spans[0]` unconditionally. It now filters to upheld first. Harmless
on the 3 August run because both of Ashley's spans were hers; not something to leave resting on
that.

### The watermark · written by the writer, never inferred

`AAO_Project.stampProjected()` writes `AAO_Projected_Value__c` and `AAO_Projected_Modstamp__c` on
the answers whose own dimension moved. **`humanEdited()` now actually functions**: it compares the
native stamp against our last write, and our last write existed nowhere until today, so *"a human
edit beats the machine forever"* had never once fired.

**One nuance, decided and named.** The populate leg first stamped only when something changed,
which would have left the 3 August row unprotected forever and made the alarm unable to reach
zero. It now stamps when the row **already reads what we derive** as well. That cannot weaken the
guard: a hand edit changes the value, so it lands in the heldBack branch instead.

### §6 · two numbers, side by side

Ruled 4 August. The panel counts **map rows written** and, beside it, **rows projected with no
watermark**. Units in the field names and in the sentence.

The `AAO_Projected_Value__c != null` filter is gone from the query — it was what made a panel
report on a field nothing wrote. The detail list is scoped instead to rows that actually reached
Altify's record.

**A bug I introduced and the test caught, recorded because the catch is the point:** the first
counter treated any linked map row as written, because `mapRowLabel` always contains the record
Name — so empty contact-role skeletons counted as our output. That is reporting the customer's
configuration as our work, which is the first thing this counter exists to stop. Now keyed on the
row's own `Status`/`Political`.

### Verified on the real B&V deal, not only in tests

```
BEFORE   section6 label=live  mapRowsWritten=1  noWatermark=1
         (it read `off` before this bundle, while Adam's row was populated)
RE-PROJECT  0 created, 0 populated, 0 blocked, 3 unchanged
AFTER    PO9 Adam Meloan  value=Outside Political Structure  stamp=2026-08-04 16:47:47
         PS7 Adam Meloan  value=Outside Political Structure  stamp=2026-08-04 16:47:47
         section6 label=live  mapRowsWritten=1  noWatermark=0
```

**The alarm went 1 to 0 exactly as design predicted**, and it went there by re-projecting from
claims with the fixed writer — the sanctioned route — not by backfilling a stamp from a native
one. The 3 August run stands in history as what it was.

### The unit law

Eight counters in `AAO_EBV.report()` now name their unit at the point of print: bind items, verify
items, contract-person pairs, items, contracts. This is the line that made the adjudication sheet
compute a phantom missing claim from `16 − 9 ≠ 6`.

### Standing

**239 tests, one failure: the pre-existing `ConvertToOpportunityTest` / `AE_Summary__c` validation,
untouched by this session and nothing to do with AAO.** The touched classes are 51/51.

---

## 2026-08-04 · session 75 · the 7 refusals · CODE's first pass, REGISTERED BEFORE COMPARISON

Protocol per addendum 04. Two files in `review/`: `…-FOR-MATTHEW.csv` with **no grade filled by
me**, and `…-CODE-FIRST-PASS.csv` with my mechanical read. **This entry is the registration:
committed before I have seen any grade of his.** Denominator is **7, not 9**, and travels with the
finding always.

| Ref | Contract | Person | CODE grade |
|---|---|---|---|
| R1 | PO9 | Ashley Stroud | WRONGLY_REFUSED |
| R2 | S5 | Adam Meloan | WRONGLY_REFUSED |
| R3 | S5 | Ashley Stroud | WRONGLY_REFUSED |
| R4 | PS4 | Adam Meloan | RIGHTLY_REFUSED |
| R5 | PS4 | Ashley Stroud | RIGHTLY_REFUSED |
| R6 | PS4 | Robbin Jones | RIGHTLY_REFUSED |
| R7 | PO2 | Robbin Jones | RIGHTLY_REFUSED |

**3 wrongly-refused, 4 rightly-refused.**

### The pattern, and it is a third answer to the question the grading was set to decide

The grading was to decide whether call 3's bar on projecting claims is **miscalibrated** or
**correctly strict**. My read says neither, cleanly split by family:

**The four two-sided refusals (PS4 ×3, PO2) are correct, and the loss was a contract-shape
artifact.** Every one refuses the STRONG side while its own reason describes the WEAK side:
*"execution within others' direction"*, *"coordination activity but not controlling outcomes"*,
*"executing within a release plan ... not approving or sponsoring"*. Those are
`called on to make it happen` and `executes projects after they are approved` — **both of which
place Political Structure.** The old single two-sided contract had no slot for the side the words
actually supported, so a correct refusal destroyed a real placement. **v2.8's split into one-way
halves (`AAO_POL_PS1`, `AAO_POL_PS2`) already fixes this**; those same quotes would place under
the new set.

**The three wrong refusals are all the guard §P8.9 just corrected.** Two are S5 (mentoring:
guidance, political insight, competitive information) where the buyer names who to approach and
in what order, and offers to work a stakeholder — advocacy from a professional, refused for being
professional. The third is PO9, my least confident. **§P8.4 retires the Support quiz from
extraction entirely**, so S5 as an extraction contract is already gone.

**So both failure classes this grading exposes are already closed by v2.8, from opposite
directions** — the two-sided split for the four, the Support-quiz retirement for the two S5s. On
my read that argues **against** tightening call 3's wording: its judgments were sound and the
contract shape was what lost the evidence.

**That is a candidate, not a verdict.** Matthew's grades are the standard, mine is one read, and
the whole point of registering first is that it can be wrong in the open.

### One error, caught before it shipped

The first build keyed grades to a positional `ref` that a later sort reassigned, silently attaching
every basis to the wrong row. Rebuilt keyed on (contract, person) and verified row by row. **A
misattached grading would have poisoned the answer key's spine**, which is the one artifact
everything downstream is measured against.

---

## 2026-08-04 · session 75 · contract minting · seventeen live, forty-eight superseded

`AAO_PassContracts` mints the §P8 declared claim-path set. **17 minted, 48 superseded, nothing
deleted.** 247 tests, one pre-existing unrelated failure; the new class carries 8 of its own.

### The scaling law, as a number in the org

The retired set put the person in the proposition code (`S2#003WD...`) because the old charter
had no subject field. On the 17 June fixture's five-person roster that shape is **80
contract-questions**. This set is **17 at any roster size**, because the person is call 2's job
and appears in no code. There is a test asserting the count does not move with the roster, which
is the law rather than a comment.

| family | n | basis |
|---|---|---|
| Sentiment (`AAO_PS_1`) | 1 | ours |
| Political Status | 8 | 3 vendor-verbatim, 5 ours |
| Buyer Role | 5 | ours |
| Decision criteria | 3 | ours |
| Coverage | 0 | computed, never extracted |

### Vendor text byte-exact, ours marked as ours

`AAO_POL_PS3`, `PS4` and `OPS1` carry Altify's own wording character for character and land
`Authored` — the vendor's text needs nobody's ratification to be the vendor's text. The five
one-way halves we split out of the two-sided questions, plus Buyer Role and criteria, land
`Inferred_Pending` with `Requires_Ratification` true. **No paraphrase is presented as recovered
text**, and the vendor's originals stay untouched in `AAO_People_Question__mdt`.

### The split is the repair for a loss this build measured

The 24 June run refused four claims on the two-sided `PS4`/`PO2`, and Matthew graded all four
**right refusals**: the words carried the weak side and the single two-sided contract had no slot
for it, so a correct refusal destroyed a real placement. `AAO_POL_PS1` (*executes after approval*)
and `AAO_POL_PS2` (*called on to make it happen*) are the slots those quotes needed. **A test
asserts no proposition is two-sided**, so true-or-nothing cannot be reintroduced by wording.

`AAO_BR_EVAL` carries §P8.9's behavioural note: evaluating behaviour on the call establishes it
FULL; a stated function with no behaviour behind it is PARTIAL.

### Deliberately absent, each for a stated reason

The nine Support questions (retired from extraction at §P8.4, still the vendor's asset); vendor
`_9` political awareness and the weak half of `_1`, which place nobody under the ceiling
derivation — two of the three faults that retired S1; and Coverage, computed from participation.

### Minting is idempotent, and an edit cannot hide

The contract key is `code|contentHash`, unique and external. Re-minting unchanged text upserts
onto the same row (**second run: 0 minted, 17 unchanged**); re-minting *changed* text mints a new
contract and leaves the old one to be superseded. The trigger is the single composer of the key,
and `mint()` calls the same `compose()` so they cannot disagree.

### Three refusals from the object's own laws, all mine, all in the test fixture

The trigger and validation rules rejected my stand-in row three times running: no question record
id, no element count (*"the number of parts is never unknown"*), no speaker requirement or decay
class. **Every one was the schema refusing an incomplete contract, and every one was in my test
data rather than in `mint()`** — which is the field enforcing laws before the code reasons to
them, the same thing that happened to the flag clock in v1.7.

### What this retires, stated plainly

Superseding the 48 means `AAO_ApplicableSet.resolve` returns nothing for the People charter under
the old pass, so **`AAO_EBV` can no longer run on B&V**. That is intended — §P8 supersedes the
pass shape and the 24 June gate runs against call 1, not against `AAO_EBV`. Recorded so nobody
reads it later as a regression.

---

## 2026-08-04 · session 75 · `AAO_Pair__c` · the ledger, with both refinements as refusals

New object, self-lookup, 25 fields, one trigger, 12 tests, all green. 259 tests overall,
same one pre-existing unrelated failure. The two refinements Matthew ruled are not comments
in the schema: they are DML the database rejects.

### Why a new object rather than `AAO_Candidate__c`, in the org's own terms

A Candidate is a proposed **claim** with per-row verification state that retires into the
decision log. A call-1 pair has no subject, no person and no verdict; it is an observation
about the transcript, and it must outlive the Candidate rows because it is the
byte-verification and recall-gate record. Different fact, different lifecycle, different
container. The precedent is the envelope law, where handed and discovered findings are
separated for exactly this reason.

### Refinement 1 · the stage is explicit, and BOTH disagreements are refused

`AAO_Stage__c` is a restricted picklist, `Located` / `Identified`, required. Inferring the
stage from a null parent lookup would rebuild the unanswered-answer-row scar: one state with
two physical shapes. So the trigger refuses a `Located` row that carries a parent **and** an
`Identified` row that does not. The picklist and the lookup cannot disagree about which row
this is, in either direction.

`AAO_Stage__c` and `AAO_Disposition__c` are deliberately different fields with an
overlapping value name. **Stage says which call wrote this row; disposition says what call 2
concluded.** Both descriptions carry that sentence, because the collision is the kind of
thing that reads as a duplicate six months from now.

### Refinement 2 · the occurrence ordinal, plus the count it needs to mean anything

`AAO_Occurrence__c` is required on every located row and one-based; a row with none, or with
occurrence 3 of 2, is refused. `AAO_Occurrence_Count__c` came with it unasked, because
**occurrence 1 of 1 and occurrence 1 of 3 are different facts** and only the second tells a
reader the words were said more than once. Count 0 is refused outright: zero matches
discards the pair and increments a counter (unit: pairs), and never writes a row saying the
words were not found. On the 17 June fixture the ordinal will almost always be 1, which is
the ruling's own point.

### The prohibition law stops being a prompt sentence

The charter says call 1 never names a person and call 2 never finds new evidence. Those are
instructions to a model, and an instruction is a request. Here there are two field sets and
the trigger refuses either row carrying the other's:

| refused | because |
|---|---|
| `Located` row with a disposition, person, basis, verification or claim | call 1 never names a person |
| `Identified` row with answer text, meaning, coverage, offsets, occurrence or speaker key | call 2 never finds new evidence and never re-judges |

**Enforced both directions on purpose.** A rule enforced one way is a rule that gets around
itself.

### One-for-one-for-one is a unique index, not a count query

`AAO_Pair_Key__c` is `<run key>|<pair ref>|<L or I>`, Text(67), unique, external id,
composed only by the trigger. **The stage is inside the key**, so a second identification of
the same located pair collides on the database's own index. The arithmetic cannot race, and
a new caller cannot forget to check it. The run key is in there because the arithmetic is
per run: two runs over the same artifact emit the same pair refs and mean different things.

The pair ref is stored as the model returned it, so a disposition naming a ref we never
emitted is detectable as our bug per the parse law. **Binding by position is the defect this
build already paid for once**, in the refusal-grading CSV.

### `None` and `Ambiguous` are not abstention rows, stated in the field

They record what happened to a pair **that exists**. Nothing here asserts the transcript was
silent about anything. `Identified` with no person is refused (the unanswered answer row
again) and `None`/`Ambiguous` carrying a person is refused (call 2 doing both). A
verification stamp on a non-identified row is refused too: call 3 sees an identified claim
or it sees nothing.

### Two more things the object settled

**The anchor is immutable and the pair is undeletable.** Stage, keys, parent, answer text,
offsets, occurrence and artifact hash are frozen after insert; editing an anchor would move
it out from under a claim that cites it. There is no supersession path, unlike a contract,
because a pair is an observation about a **frozen** artifact: it does not go out of date,
and a re-run writes a new run key and leaves this one standing.

**The speaker key is derived in Apex, never asked of the model.** Whose turn contains a byte
range is arithmetic over the normal form. `AAO_Person__c` points at `AAO_Participant__c`
rather than Contact, because the 17 June fixture carries **two participants with no Contact
link** and a Contact lookup would drop them silently.

### The test fixture was wrong in exactly the way last entry's was

Three tests failed on `REQUIRED_FIELD_MISSING: AAO_Source__c` because I hand-built an
`AAO_Participant__c`. Participation is written by `AAO_Participants.record` on Source insert,
and that is the only path this org has. Rebuilt to insert a Source with a one-speaker roster
and read the participant back. **Same mistake as the contract minting: a stand-in row in a
shape the org never produces.** Worth naming twice, because it is now a pattern rather than
an incident.

### Owed, and named rather than assumed

`AAO_Run_Key__c` is text because **the run receipt object does not exist yet**. §P8.0 makes
it the replacement for abstention rows (one row per Source per pass) and it is not built. The
text field is carried now so the receipt can join later without backfilling a corpus.

Also unbuilt, deliberately: the two writers. Nothing yet inserts an `AAO_Pair__c` — that is
call 1's and call 2's Apex, and it follows the §P8.9 wording updates and the 24 June recall
gate.

---

## 2026-08-05 · session 76 · addendum 06 absorbed · call 1 exists, and omission is now catchable

273 tests, 100% pass, the same one pre-existing unrelated failure. Two classes: `AAO_PairLedger`
(the arithmetic ruling 1 named) and `AAO_LocateCharter` (call 1, with §P8.9 written in).

### Ruling 1 · the index cannot detect zero, and now something can

Matthew ratified the `run|ref|stage` unique index and named its limit in the same breath.
**The index refuses more than one; it cannot detect zero.** A located pair call 2 silently
never disposes of breaks one-for-one exactly as badly as a duplicate, and no insert ever
collides to reveal it. "Exactly one" is two assertions.

`AAO_PairLedger.assertOneForOne(runKey, afterVerify)` is the second one. It compares counts
between the row sets and throws; it writes no row, because the counts are the proof (§P8.0)
and a mismatch is always our bug per the parse law.

Three things it does deliberately:

- **A `None` or `Ambiguous` counts as a disposition.** Counting only the named ones would
  make a correct refusal look like an omission, which is precisely the confusion the
  abstention rows used to create.
- **`afterVerify` is an argument, not read off the data.** Before call 3 a pass with no
  verdicts is correct; after call 3 the identical rows are an omission. Inferring it from
  the shape would be a state with two physical shapes, which is what the explicit stage
  picklist exists to refuse.
- **The verdict count compares against identified-to-a-person only.** A `None` row is not
  owed a verdict; there is no claim in front of the reader on it.

### Ruling 2 · Participant is the grain, recorded as the model

Absorbed as stated, and it is a better reason than mine: the pass operates on **who was on
the call**, and Contact is a resolution *outcome* of a person rather than their identity.
Shadow people, mentioned-but-absent people with no last name, participants awaiting match —
all exist at Participant and only sometimes acquire a Contact. **Contact resolution hangs
off Participant and never gates it.** Owed to Model & Flow at its bump.

### Call 1 exists · `AAO_LocateCharter`, version `locate-2.0.0`

The §P8.9 item could not be "wording into call 1" because call 1 had no code. Built with the
four rulings written in from the start rather than patched over a neutral draft.

**The prohibition law is a missing field, not a sentence.** There is no `person`, `speaker`,
`contact`, `who_said` or `subject` property in the schema, and a test asserts each absence.
Same move `AAO_Pair__c` makes at the database: a charter instruction is a request, a missing
field is a refusal.

**§P8.9 is asserted literally in the tests, and that is on purpose.** Those rulings came from
a grading where every single disagreement was the guarded reader establishing LESS than the
grader, zero over-reads. An edit that quietly softens one of them is the one regression this
build cannot see from its own output, because **an under-read leaves no trace anywhere**. So
the test asserts the strings, and the reasons travel with the rules in the prompt.

### A reversal, recorded rather than left to look like an accident

`AAO_InventoryCharter` 1.1.0 says one sentence bearing on three families is **one item**.
§P8.9 ruling 2 says it is **three pairs**. Both charters are live in this org and would
otherwise read as disagreeing by accident. A test asserts the old rule still exists and the
new schema says `One entry per ESTABLISHMENT, not per sentence`.

### The meaning vocabulary, and the coupling it makes visible

Meanings are runtime-closed per family. Fifteen of the seventeen allow exactly one value,
because the propositions point one way; the two carrying real choice are sentiment (four
states) and criteria typing (`FORMAL`/`INFORMAL`). **A single-valued enum is not noise**: it
is what lets the parser reject a `MENTOR` on a Buyer Role pair as our bug rather than store a
meaning nothing can read.

A test walks `AAO_PassContracts.specs()` and asserts every declared code has a meaning. Mint
an eighteenth contract without one and call 1 would offer the question, the parser would
reject every pair against it, and **the question would be answered as silence** — which is
the failure this build spent three sessions learning to see.

### Two parser choices that cut toward reporting

- **Missing coverage becomes `Partial`, never a discard.** Partial is the instructed default
  under doubt, and an omitted value is doubt by definition. Discarding the pair would be an
  under-read created by our own parser.
- **Every refusal keeps its reason** in `Result.rejected`. A silently dropped pair is exactly
  how `AAO_Interpretation__c` lost two of nine refusals on the 3 August run.

### One deviation from §P8.1's schema, named rather than slipped in

§P8.1 gives call 1 a `resolution` object. It is emitted here as `deal` and `account` and
**never written anywhere**: the Source already carries both, and asking a model to re-resolve
what the record answers is asking a question the data has. It is collected so a
**disagreement is a finding**, which is a different thing from a resolution. There is no
field on `AAO_Pair__c` to receive it, and a test says so.

Same reasoning as the speaker key, which is derived in Apex from the offsets and the roster
rather than asked of the model.

### Still not built, named so the queue is honest

Nothing calls this charter yet. The runner, the byte-location step that turns `answer_text`
into offsets plus occurrence, call 2 and call 3 are the 24 June gate's work and the Emerson
run's. The run receipt object is still owed by §P8.0.

---

## 2026-08-05 · session 76 · THE 24 JUNE RECALL GATE RAN · three times · NOT PASSED, and it should not have

283 tests, 100% pass, same one pre-existing unrelated failure. Call 1 made its first real
callouts. **The gate does not pass, on all three runs, for the same two targets.**

### The numbers, first, because they answer the question three sessions have been asking

| run | wall ms | in | out | **thinking** | cacheRead | pairs parsed | located | discarded |
|---|---|---|---|---|---|---|---|---|
| 1 | 23,941 | 16,620 | 1,534 | **0** | 0 | 17 | 15 | 2 no match |
| 2 | 27,812 | 16,620 | 2,156 | **602** | 0 | 15 | 15 | 0 |
| 3 | 28,302 | 16,620 | 2,164 | **1,410** | 5,820 | 8 | 7 | 1 no match |

**Against 87,805 ms per person on the retired shape: ~28 seconds for the whole transcript,
whole roster, once.** No call is near the 120-second ceiling with room to spare, and the
prefix cached on run 3 as designed.

**The rumination is gone.** Thinking was the entire failure of the old stage 1 — a read that
spent its whole output budget deliberating and returned an empty inventory. Here it is 0,
602 and 1,410 tokens against 1,534 to 2,164 of output. That question is answered.

**The instability is NOT gone. 17, 15, 8 pairs on identical input.** Better than the old
8/0/0/0/20 — it never returns empty, which was the specific pathology — but a 2× spread
across runs is not a stable instrument, and it is recorded open exactly as the old one was.

### The gate did not pass, and the two failures are different failures

```
targets covered          0/2 (unit: targets)
targets owed             3 (unit: targets)
  missed, not found      1 (unit: targets)
  missed, routed away    1 (unit: targets)
GATE                     NOT PASSED
```

**The canonical criterion is still missed.** *"what I'm trying to do is just eliminate
clicks"* is at offset 14,264 of the artifact, verified present. Run 1: not found at all. Run
3: not found at all. Run 2: found, and filed under `AAO_BR_EVAL`. **The case charters v2.5
names as the one this build produced and missed by declaration is still missing under the
new shape**, and now it has a declared contract to land on. Criteria the read did produce
were different ones ("adoption and utilization of Altify"), so the family is not silent, it
is aimed wrong.

**The broker words are found but routed.** *"That needs to go to Scott and Matt and Brian…"*
comes back on runs 1 and 3 as `AAO_POL_PS2` (*called on to make it happen*) where the grade
says `AAO_POL_OPS1` (*collects and provides information to people of power and influence*).
The read saw the words. Two one-way contracts compete for the same sentence, which is a
wording problem in the contracts rather than a coverage problem in call 1.

**Separating those two was itself a repair, and the gate's own first run forced it.** The
first version scored by string containment. The located quote and the target quote shared
thirty-nine characters of one sentence, neither contained the other, and the report said NOT
FOUND AT ALL about words the read had plainly found. **A gate lying in the direction of
alarm is still a gate lying.** Matching is now byte-range intersection in the frozen
artifact — the same byte truth every other layer uses, with no opinion about where a sentence
ends — and the report says which of the two failures it is, because they call for opposite
repairs.

### A finding that changes the gate's target set, from §P8.0's own words

§P8.0 says a pair must exist for the words behind **each graded PASS**. Mapping the four onto
the seventeen:

| graded PASS | §P8 home |
|---|---|
| PS7/Adam · *collects and provides information to people of power and influence* | `AAO_POL_OPS1`, verbatim |
| PO9/Ashley · *Is this person aware of the politics in the organisation?* | **none** |
| PO9/Adam · same question | **none** |
| one of three S1 rows | `AAO_PS_1`, and WHICH is owed |

**Two of the four graded PASSES are on the one question §P8 deliberately does not declare.**
PO9 is political awareness, retired for placing nobody and being true of everyone worth
mapping. Their absence is the design working, not a recall failure, so the gate cannot
require them.

That is worth more than a footnote. The findings=1 explanation was *the read establishes gate
questions that place nobody and misses placement questions* — and here it is from the other
side: **half the graded PASSES were on a question that places nobody.** The gate's own target
set is evidence for the retirement.

### Three targets are OWED, and the gate refuses to pass while they are

Declared unresolved rather than left out, because a gate that silently omits the targets it
does not know about reports a clean pass over a smaller test.

1. **The S2/Adam placement words.** The first recorded UNDER. Never surfaced, so the words
   are nowhere in this org; only the grading names them. **Needed: the verbatim words, and
   `AAO_PS_1`/SUPPORTER is the expected landing.**
2. **Which S1 row is the fourth PASS** — Ashley, Adam or Robbin.
3. **Which two S1 rows are the OVERs**, so the must-not-reproduce assertion can run. It
   currently reports 0 reproduced, which is a vacuous 0.

### What the read actually returned, since this is the first look at the new shape

Run 1, 15 located pairs: 4 sentiment (1 SUPPORTER, **3 MENTOR**), 6 Political Structure, 2
Evaluator, 2 User, 1 criterion. **Zero Inner Circle, zero Approver, Decision Maker or
Signature, zero DC-F or DC-R.** Every fact pair came back `Partial`, which is the instructed
default under doubt behaving exactly as written.

**Three MENTOR reads on one call is worth grading before it is trusted.** §P8.9's advocacy
ruling was aimed at a reader that was under-reading support; whether it has over-corrected is
a question for Matthew's key, not for me.

**The hallucinated-quote rate is measured: 2 of 17 (run 1), 0 of 15 (run 2), 1 of 8 (run 3).**
Both run-1 discards were the same fabricated DC quote offered twice under DC-N and DC-F.
Byte matching caught every one, which is what it is for.

### Two things the build learned about itself on the way

**Field-level security is not granted by deploying a field.** Twenty of `AAO_Pair__c`'s
twenty-five fields were invisible to the running user and the whole object read as five
fields; Apex writes worked because Apex runs in system mode, so nothing failed until a query
from outside. The five that WERE visible are exactly the five marked required — required
fields cannot have FLS withheld. `AAO_Admin` now grants the rest. **A schema nobody can read
is not deployed, it is hidden.**

**The unique index caught a real duplicate on its second day.** Re-running the gate under the
same run key threw `DUPLICATE_VALUE` on `AAO_Pair_Key__c` rather than writing a second copy
of the run. That is ruling 1's first half working on live data, three hours after it was
ratified.

---

## 2026-08-05 · session 76 · addendum 07 · the target set settles, and the instability answers its own question

285 tests, 100% pass, same one pre-existing unrelated failure. No new callouts: the three
stored runs are re-scored against the settled target set, which is what having a run key on
every row is for.

### The three asks, absorbed

**The fourth PASS is Adam's S1 (CLM-34), and it does not add a target.** Its span is *"what
I'm trying to do is just eliminate clicks"* — the same span already carried as the canonical
criterion, and Matthew's 4 August ruling makes it the criterion Adam should carry. Two grades
land on one span, so the answerable count stays at two. **Recorded because a resolved ask
that changes no number reads as an omission otherwise.** The distinction the sheet draws is
the durable one and is now in the target's own text: *a person stating what he himself wants
establishes; describing a process or directing an implementation does not.*

**The two OVERs are Ashley's CLM-31 and Robbin's CLM-35**, both `wrong-scope`. They are
must-not-reproduce targets scored against `AAO_PS_1`, since S1 is retired and sentiment is
where a preference claim would now land. The reported zero has its denominator.

**The S2/Adam target is WITHDRAWN, not answered.** The sheet recorded that UNDER **with no
span**, from Matthew's read of the output against his knowledge of the call. Nobody has ever
named Adam's supporter words in the 24 June transcript and it is possible none exist.
**A gate target must be transcript-grounded; a read cannot be failed for missing what the
frozen bytes do not carry.** It stays in the target list carrying its reason, because
deleting it would erase why it was ever expected. `withdrawn` is a distinct state from
`owed`: owed means nobody has answered, withdrawn means the answer was that the artifact
does not carry it.

**PO9 is excluded by ruling now rather than by my inference**, with the reason journalled.

### Two scoring repairs the answers forced

**The coverage ratio no longer mixes in the exclusions.** With two must-not-reproduce targets
in the denominator the ratio could never reach one, so it would report a permanent failure
that means nothing. Recall targets and exclusions are counted separately: `targets covered
0/2`, `exclusions checked 2`.

**An over-read's words under a DIFFERENT contract are reported, never failed.** The grading
judged those words against one proposition and said nothing about any other. Calling
`AAO_BR_EVAL` on *"use your components"* a reproduction would punish a reading nobody graded.
It prints as a NOTE and goes in front of Matthew.

### Restraint holds. Recall does not.

**Zero over-reads reproduced as sentiment, in all three runs.** Both graded over-reads stayed
out of `AAO_PS_1`. The one-way split and the sentiment definition are doing the job they were
built for.

But both come back elsewhere, and one of those is a finding rather than a note:

| over-read | where it landed |
|---|---|
| Robbin CLM-35 *"use your components…"* | `AAO_BR_EVAL`, **all three runs** |
| Ashley CLM-31 *"we look at as many use cases…"* | `AAO_DC_N`, run 2 |

**Run 2 filed a graded-OVER process description as a criterion while filing the canonical
criterion under `AAO_BR_EVAL`.** The criteria family is not silent; it is aimed wrong, and it
swapped the two exactly.

### The instability question, answered with the separating measurement CODE asked for

Clustering every located pair across the three runs by (contract, overlapping byte range) —
overlap rather than string equality, because a boundary shift is not a different finding:

```
distinct establishments across 3 runs   26 (unit: establishments)
  in all three runs                      4
  in two runs                            2
  in one run only                       20
```

**This is not a stable core with a noisy fringe. The fringe is the read.** Fifteen per cent
recurs; seventy-seven per cent appears once and never again.

And the targets flicker. `PS7-broker` is 2 of 3; the canonical criterion is 1 of 3. Neither
is ever *covered*, so the headline stays a stable 0/2 — but what varies is **how** it fails,
which means a single run cannot be trusted to tell you which repair you need.

**The four that recur in all three runs are the whole stable core:**

| | contract | speaker | words |
|---|---|---|---|
| 1 | `AAO_BR_EVAL` | Robbin | *use your components that you guys to Altify design components…* |
| 2 | `AAO_POL_PS1` | Robbin | *That will be upgraded in our next sprint.* |
| 3 | `AAO_POL_PS1` | Robbin | *any Altify install, we don't have to go through security…* |
| 4 | `AAO_POL_PS2` | Robbin | *but I'll send a message and make sure they keep everybody up to date* |

**All four are one person, and the most stable establishment in the entire read is a graded
over-read wearing a new hat.** Nothing about the four is load-bearing for a relationship map.

Per the ruling: measured, not touched. No change to temperature, prompt or splitting.

### Queued for grading, and out of this prose per the standing rule

`review/sentiment-2026-06-24-FOR-MATTHEW.csv` — the three MENTOR reads from run 1, with
their proposition, their quotes, and the label meanings exactly as the model received them.
`…-CODE-FIRST-PASS.csv` is in this commit and stays out of the narrative until his copy
comes back.

### Blocking, and it is not mine to resolve

**The Emerson blind key.** The sheet has held that slot empty since 29 July. Emerson end to
end does not start until Matthew dictates it, or the `model_missed` denominator is lost for
the second fixture running.

---

## 2026-08-05 · session 76 · charters v2.9 · the three traps are dead and MENTOR moved rather than shrank

285 tests, 100% pass, same one pre-existing unrelated failure. v2.9 synced by delta, the label
text landed in the contract, three fresh gate runs.

### The sync, and one gap the fix exposed in minting

v2.9 applied against exact v2.8 anchors: the head stamp, and §P8.4's pinned label paragraph
inserted before *The scope of the retirement*. Everything else byte-identical.

The label meanings are now **quoted from §P8.4, never paraphrased**, in `AAO_PS_1`'s guidance —
which is where the defect came from in the first place. The first draft of MENTOR was written
in `AAO_PassContracts` rather than read from a charter, it opened with *guides you with
insight*, and that line is true of anyone participating well in a meeting.

**Re-minting exposed a real hole in `mint()`.** Editing a proposition changes its content hash,
so it mints a NEW row on the **same** rubric and the old one keeps standing. Supersession only
looked at the OLD rubric, so this would have left **two live `AAO_PS_1` contracts** and handed
call 1 the same question under two different definitions. Fixed: supersede anything live whose
key is not in the freshly minted set, either rubric. Result:

```
contracts: 1 minted, 16 unchanged, 1 superseded (unit: contracts)
AAO_PS_1  Superseded  f9945ac61b26      <- the "guides you with insight" text
AAO_PS_1  Derived     85eb2e9948df      <- v2.9
live on people-p8-v1: 17
```

**An in-place edit could not hide; its predecessor could. Now neither can.**

### The three named traps are gone. Every one of them.

None of the three graded-Neutral quotes reproduces as sentiment in any of the three v2.9 runs.
The exact sentences §P8.4 now names by hand — *this is a key step*, the business-cases question,
*we can do both* — are absent. `ENGAGEMENT IS NOT STANCE` did the specific job it was written
to do.

### But MENTOR did not shrink. It moved.

| | r1 | r2 | r3 | → | r4 | r5 | r6 |
|---|---|---|---|---|---|---|---|
| located pairs | 15 | 15 | 7 | | 10 | 23 | 30 |
| MENTOR | 3 | 4 | 1 | | 4 | 3 | **10** |
| SUPPORTER | 1 | 1 | 0 | | 0 | 1 | 3 |

The reads landed on an entirely different class of sentence: **routing and coordination talk.**
*"Again, let me talk, I'll talk to Steve about that"* (all three runs). *"That needs to go to
Scott and Matt and Brian."* *"engage our D&IT team first."* *"we can piggyback Ashley on
Robin's note."*

**Those fit the new definition better than the old ones fit the old.** Taking our item to a
named person inside their own organization is *their people, on our behalf*, which is what the
line says. So the model is reading the new text and finding a new candidate set, not ignoring
it. **Whether that set is right is Matthew's, and it is a fresh grading question rather than
this fix reporting home.**

### The fix created a contract collision, and it lands on a recall target

**`PS7-broker` — a graded PASS — now files as `AAO_PS_1`/MENTOR in two of three runs.** v2.9's
MENTOR (*guide you through their own organization... their politics, their process, their
people*) and `AAO_POL_OPS1` (*collect and provide information to people of power and
influence*) now describe overlapping evidence, and the model picks sentiment. The gate reports
it as **routed away** rather than not found, which is exactly the distinction that was built
two entries ago and is earning its keep here.

Named as a defect rather than worked around: **two live contracts compete for the same
sentence, and the newer one is winning a recall target away from the older.**

### A graded over-read reproduced for the first time in six runs

Run 6: **`S1-over-robbin` came back as `AAO_PS_1`/SUPPORTER** — CLM-35's exact words, which
Matthew graded OVER as wrong-scope carrying no preference. Five gate runs reported a clean
zero; this one did not. The exclusion set stopped being decorative.

### Two things no label meaning would have caught

**A sentiment read on our own seller.** Run 6 emitted `AAO_PS_1`/SUPPORTER on Renee Martin,
who is on the selling side. The question asks how **they** stand toward **us**; a sentiment
read on our own person has no subject. **That is a scope failure, not a calibration one**, and
no wording of the ladder addresses it — the gate needs a side check.

**The same words read two ways across runs.** *"let's try to get that discussion going pretty
quickly"* came back SUPPORTER in run 5 and MENTOR in run 6. Whatever the correct grade, the two
cannot both be right, and this is an instability specimen rather than a calibration one.

### Instability, again, and wider

10, 23, 30 located pairs against the previous 17, 15, 8. Part of that is §P8.9 working as
intended (one quote, several establishments), and part of it is the same 3× spread on identical
input. **The measurement stands open and untouched, per the ruling.** Thinking: 910, 1,160, 0.
Latency 27.8 s, 42.1 s, 33.2 s — run 5 is the longest call yet and still less than half the
ceiling.

### Queued for grading, out of this prose per the standing rule

`review/sentiment-v29-2026-06-24-FOR-MATTHEW.csv` — the 17 distinct sentiment reads across the
three v2.9 runs, clustered by speaker and quote so a boundary shift counts once, each carrying
**how many of the three runs produced it**, with the v2.9 label meanings exactly as the model
received them. Recurrence is on the sheet because a read that survives all three runs is a
different kind of claim than one that appeared once. `…-CODE-FIRST-PASS.csv` is in this commit
and stays out of the narrative until his copy comes back.

### Still blocking, still not mine

**The Emerson blind key.**

---

## 2026-08-05 · session 76 · EMERSON END TO END · all three calls ran, 14 pairs, 4 upheld

285 tests, 100% pass, same one pre-existing unrelated failure. **The §P8 pass exists end to
end for the first time.** Calls 2 and 3 were built this session; before today only call 1 had
ever run.

### The fixture is seeded and the hash round-trips exactly

`SRC-00000035` · `emerson/aspentech-2026-06-17-nf1` · **carrier, stored and declared all
`ec8e7170…5a5f`**, 42,784 chars. The trailing-newline hazard that produced two fingerprints in
session 73 is simply absent, because the artifact was reissued without one. Five participants
recorded at ingest. The 42 KB artifact rides a StaticResource because anonymous Apex caps
source at 32 KB.

### The numbers

| call | wall ms | in | out | thinking | cacheWrite |
|---|---|---|---|---|---|
| 1 · locate | 17,060 | 15,330 | 1,308 | **0** | 5,956 |
| 2 · identify | 9,361 | 4,355 | 748 | **0** | 1,549 |
| 3 · verify (14 calls) | 68,041 | — | 2,169 | 103 | 868 |
| **total** | **94,462** | | **4,225** | | |

**94.5 seconds for the whole call, whole roster, all three stages, against 87,805 ms per
person on the retired shape** — which on this five-person fixture would have been ~440 s for
one stage. **Call 3 is now the expensive stage at 72% of the wall clock**, because it runs one
claim per call.

### The arithmetic held, twice

```
pairs located            14 (unit: pairs)
dispositions made        14 (unit: pairs)     <- assertOneForOne(run, false)
  to a person            14 (unit: pairs)
  None or Ambiguous       0 (unit: pairs)
verdicts returned        14 (unit: claims)    <- assertOneForOne(run, true)
  upheld                  4 · refused 10 (unit: claims)
```

**Zero discarded for byte mismatch. All 14 quotes located in the frozen artifact exactly
once** — no hallucinated quote on this fixture at all, against 2/17 and 1/8 on B&V.

### Four defects, three of them mine, and one is an API constraint

**1 · The blind reader was never told the claimed meaning.** `verify()` selected
`AAO_Meaning__c` from the **identified** row, where it is always null — the ledger's own
trigger forbids call 2 from carrying it. So call 3 was handed *"the words below answer that
question"* with no meaning at all, and **for a sentiment claim that deletes the scope check
entirely**, which is the one thing §P8.3 adds for sentiment. Fixed to read from the located
row and re-run: **5 upheld / 9 refused became 4 upheld / 10 refused.** One claim survived only
because the reader could not see what it was being asked to verify.

**2 · `minItems` is not available on this API.** Handed 14 claims against a schema description
saying one verdict per claim, never omitting, call 3 returned **one**. The parse law caught it
and threw. The obvious repair is a schema bound, and the Messages API refuses it outright:
`For 'array' type, 'minItems' values other than 0 or 1 are not supported`. Measured, 400.

**3 · Batching by four failed differently and worse.** Handed q1/q10/q11/q12 the reader
returned q1 twice; handed one claim with a one-value `ref` enum it returned that ref twice.
Three malformations of one envelope, none repairable by wording. **The fix removes the field
rather than instructing against it:** at one claim per call there is nothing to key, so the
response is a verdict and a reason and mis-referencing is unexpressible. Same move as call 1
having no person field.

**4 · Every seller on this call is marked buyer side.** The sandbox's internal-domain list does
not carry `altify.com`, so both Altify participants read `buyer side` — **and call 2 was handed
that wrong label.** This is the same class as the Renee Martin sentiment read on B&V, and it is
the side check that finding said was needed. It is on the CSV as a defect row rather than
buried.

### What the read produced, and what the reader did to it

14 establishments: 5 Political Structure, 3 Evaluator, 3 criteria, 2 sentiment, 1 User, 1
Outside. Two people carry all of them — Jefferson Vargas (8) and Neeraja Chimata (6) — and
**Jefferson has no Contact link at all**, which is precisely why `AAO_Person__c` points at
Participant. Call 2 returned **14 of 14 to a person, zero NONE, zero AMBIGUOUS**, which is
either a clean roster or an over-confident reader and is one of the things the grading settles.

**Call 3 refused 10 of 14 (71%).** Against 24 June's 9 refusals of 16 items that is in the same
band, and both surviving criteria plus one sentiment read are what stands.

### Scoped narrower than the charter, said plainly

Call 2's closed list is the Source's **participants only**. Call 1 also reported two
mentioned-but-absent people (Fatima; Travis Hill, *VP of professional services who scoped the
managed services hours*), and under §P8.1 those are real candidates — but a mentioned person
has no Participant row, so a disposition naming one could not be written and would be dropped
after being paid for. **Shadow creation is the gates' work and is not built.**

The context window is **two turns each side**, and it is a **chosen** number, not a measured
one. §P8.0 says the threshold is measured and no document carries it; a chosen number
pretending to be measured is exactly what that law prevents.

### Owed to Matthew

`review/emerson-2026-06-17-FOR-MATTHEW.csv` — resolution rows first (account, occurred clock,
opportunity, and each person's identity outcome), then all 14 establishments including the ten
call 3 already refused, then eight blank UNDER rows. `…-RUN-FACTS.md` carries the run key,
charter versions, and the latency table beside it.

**Two resolution rows are marked NOT ASSERTED rather than presented for grading:** the
occurred-clock window cannot run honestly in a sandbox where every opportunity carries a seed
`CreatedDate` of 3 August, and the opportunity was **given by the seeder, not resolved**.
Grading either would grade the seed rather than the machine.

---

## 2026-08-05 · session 76 · the four Emerson defects · three closed, one barely moved, and a regression

285 tests, 100% pass, same one pre-existing unrelated failure. Re-run `emerson-0617-r3`,
`locate-2.1.0+d314a73c`. **Four variables changed at once, so a clean run cannot attribute the
repair, and the per-defect evidence below is what carries the attribution instead.**

**Upheld went from 4 of 14 (29%) to 14 of 18 (78%).** Matthew's grading implies ~10 of 14
should have stood, so this lands in the right band rather than overshooting into agreement.

### Defect 1 · the placement leak · CLOSED, and it was mine, made hours before it was caught

Repairing *"the blind reader was never told the meaning"* this morning, I began handing call 3
the **meaning** — and for the fifteen one-way families the meaning IS the placement. Call 3
then required the words to voice the proposition **and** its placement. Every political
refusal joined two clauses with *nor*, and one cited *who must approve*, which is
`AAO_POL_PS1` — the OTHER one-way half. **The two-sided test the split was minted to kill,
alive at call 3 while the schema test correctly reported no two-sided proposition exists.**

The fix makes it unexpressible rather than instructing against it. `carriesChoice(code)` is
true only where the family's meaning set has more than one member — sentiment's four states
and criteria typing's two. There is no branch that can leak a placement, the same move as call
1 having no person field and call 3 having no `ref` field.

Row for row against Matthew's grades:

| his grade | run 1 | run 3 |
|---|---|---|
| *"This looks like full coverage on political structure"* (Neeraja) | Refused, Partial | **Upheld, Full** |
| *"Overcomplicating, this is full"* (Jefferson, per-user rate) | Refused, Partial | **Upheld, Full** |
| Jefferson → Emerson procurement, wrongly refused | Refused | **Upheld, Full** |
| Jefferson brokering to approvers, wrongly refused | Refused | **Upheld, Full** |

**Zero refusals in the re-run join clauses with *nor*.** All four remaining refusals reason
about the proposition alone.

### Defect 2 · `AAO_BR_EVAL` · CLOSED

The old text was the vendor's definition read literally and **demanded criteria that do not
exist yet**: on most calls no criteria set is established, so a proposition requiring
assessment *against defined criteria* can never be true whatever the buyer does. §P8.9's
behavioural note was in the guidance and guidance cannot lower a bar the question raises.

Rewritten to behaviour — *weigh what is being offered, comparing options, pressing on
capability against a need, or probing price, terms or fit* — with Altify's definition kept as
the authored proposition's provenance rather than its test. Both graded rows now stand Full,
and **three Evaluator reads exist that did not exist before**, including two from Ryan Couture,
who carried nothing at all in run 1.

### Defect 3 · Full was unreachable · CLOSED, and the cause was mine

`coverage` was **not in the schema's `required` list**. The model omitted it on every pair and
the parser's default-to-Partial wrote Partial 14 of 14 — silently. A defaulted field looked
like a uniformly cautious reading.

Now required, and the default is counted rather than silent. **Run 3: Full 5, Partial 10, null
3 (sentiment), `coverageDefaulted = 0`.** The model is choosing.

### Defect 4 · multi-establishment · BARELY MOVED, and the way it moved is the finding

18 pairs from 17 distinct quotes: **exactly one quote carries two establishments.** And it is
the one I put in the prompt as the worked example, producing exactly the two pairs the example
named. **The model reproduced the example rather than generalising the rule**, which is a
worse result than the number suggests.

The three specimens:

| specimen | wanted | got |
|---|---|---|
| Neeraja *"I'm right here and I'm going to support…"* | 2 | **2** — SUPPORTER + POLITICAL_STRUCTURE |
| Neeraja *"flexibility of using those hours"* | 2 | **0 — the quote is gone from this run entirely** |
| Jefferson *"the annual total…"* | 3 | **2** — DC_N + DC_F |

Two things worth separating. The annual-total quote's missing third establishment is
**Decision Orientation, which is an undeclared family** — it was never reachable, so that
third pair could not have been emitted by any prompt. And the flexibility-of-hours quote is
not a multi-establishment failure at all: it is a **recall regression**.

### The regression, named rather than absorbed into the good news

**A graded PASS from run 1 is gone in run 2.** Matthew wrote of it *"This should be a real
criteria, Flexibility of Services Hours"* — and the re-run does not contain those words at
all. Nor does the THIN row he asked for more context on.

Same fixture, same artifact, clustered by contract and overlapping byte range:

```
distinct establishments across the two Emerson runs   23
  in both runs                                         9
  run 1 only                                           5
  run 2 only                                           9
```

**39% recur.** On the 24 June gate it was 15% across three runs. The four repairs changed what
gets read, so these two runs are not a clean instability measurement — but **the second data
point CODE asked for has arrived and it answers its question: the 77%-appears-once figure was
not that fixture's character.** Recall instability is the read's character, on both fixtures,
and it is the open problem.

### The provenance break · answered and closed

Call 1 ran as `locate-2.0.0` on both the 24 June gate and the first Emerson run, though v2.9's
label-meaning fix changed the prompt. **The break is real and the cause is that call 1's prompt
is two halves:** this charter's prose, and the declared contracts' own text. The fix landed in
`AAO_PS_1`'s guidance, so the contract moved and the charter version did not.

The stamped version now composes both: `locate-2.1.0+d314a73c`, where the suffix is a
fingerprint over the declared set's contract keys, and those keys already carry each
contract's content hash. **An edit to either half moves the string and it cannot not move.**
`AAO_Charter_Version__c` widened 20 → 40; the first write threw `STRING_TOO_LONG` at 22
characters, which is the field refusing an incomplete provenance rather than truncating it.

### Not repaired, deliberately

**The seller-side flag.** Both Altify participants still read `buyer side`, because the
sandbox's internal-domain list does not carry `altify.com`. It was not one of the four defects
and **changing a fifth variable would have made this re-run unreadable.** On the CSV as an open
row.

**Matthew's timestamped quotes.** His added rows carry ECI viewer timestamps (`21:39-59`,
`24:43`, `33:15`, `12:48`) that will not byte-locate in `ec8e7170`. **I do not hold his
returned file** — the sheet quotes the timestamps but not the row text — so the normalization
is owed and blocked on that file, and no target is built from a quote I cannot locate.

---

## 2026-08-05 · session 76 · the family sweep · recurrence 39% → 52%, pairs 18 → 40

289 tests, 100% pass, same one pre-existing unrelated failure. `locate-3.0.0+d314a73c`. Built
in the ruled order: the regression assertion set first, then the sweep, then two identical
runs.

### The regression set, built first, and it caught the thing retroactively

`AAO_Regression` turns every graded finding into a standing assertion. **No model call:** the
spans are recorded, and checking them is arithmetic over bytes. Traps and passes are the same
mechanism from opposite ends.

Run against the two existing Emerson runs before the sweep touched anything:

| run | verdict |
|---|---|
| `emerson-0617-r1` | **HELD** |
| `emerson-0617-r3` | **BROKEN** — `LOST emerson-q9 [AAO_DC_N]` |

The instrument named the exact regression the last report had to find by hand, from data that
was already in the org. **That is the whole argument for building it before the sweep rather
than after.**

Matthew's nine spans are in it, byte-located by design in `ec8e7170`. Six carry declared homes
and are `GRADED_MISS` targets; **three are Decision Orientation, an undeclared family, and are
reported as `UNREACHABLE` on their own line** so they can never inflate a recall failure — no
prompt, no read and no repair could produce them.

**UNDER-3 is recorded as a limit of the model, not a bad paste.** Matthew's read is one
establishment continued across an interruption: 248 of his 512 characters locate at 23,230,
three other speakers' turns intervene, and the resumed clause is a second span at 23,530. **One
establishment, two spans, and one-span-per-pair cannot express it.** On the record before
anything is built that assumes contiguity.

### The sweep · four reads, and the measurements CODE asked for

**1 · Recurrence across two identical sweep runs: 27 of 51, 52%.** Against 39% across the two
Emerson single reads and 15% across three 24 June runs. **Better, and not decisively** — the
bar was to beat 39% decisively and 52% does not clear that bar the way the ruling wanted. It is
the largest single improvement measured on this problem and it is not the answer to it.

**2 · Contracts reached by more than one family read: 0 in both runs.** The partition holds.
Same bytes reached by different contracts in different families is intended and is never
deduplicated — that is the multi-establishment the sweep exists to make structural.

**3 · Per-family pair counts**, which is addendum 11's concentration measurement arriving free:

| family | contracts | s1 | s2 |
|---|---|---|---|
| Buyer Role | 5 | 14 | 11 |
| Sentiment | 1 | 11 | 10 |
| Political Status | 8 | 9 | 12 |
| Decision criteria | 3 | 6 | 5 |

**The misses were not concentrated in one family.** Every family produced more under the sweep,
including Sentiment, which holds a single contract and still went from 2 pairs to 11 — a family
that cannot have been capacity-bound by contract count. That is worth stating plainly: **the
capacity problem is not only how many contracts are in view, it is how many things the read is
holding at once, and attention was the scarce resource rather than prompt size.**

**4 · Wall clock. Serial 63.1 s and 71.6 s, transaction 63.7 s and 71.8 s.** CODE's estimate
was ~68 s and assumed concurrency would be needed to stay inside the ceiling. **It is not:
four serial reads fit inside 120 s with room, and Apex cannot issue concurrent callouts from
one transaction anyway.** Concurrency is not available and is not needed; the number is
reported serial because that is the only number there is.

**5 · Total pairs: 40 and 38, against the single read's 18 and 14.** More than double, with
**zero byte-match discards and zero coverage defaults in both runs.**

### Defect 4 dissolved, structurally, as the ruling predicted

| | single read | sweep s1 | sweep s2 |
|---|---|---|---|
| quotes carrying >1 establishment | 1 of 17 | **7 of 31** | **4 of 33** |
| carrying >2 | 0 | **2** | **1** |

The worked example is gone from the prompt and multi-establishment went up sixfold. **Two
rewordings failed to teach what a partition made automatic.** Fourth time this build has taken
the same move: no person field on call 1, no `ref` field on call 3, no placement string at call
3, and now no cross-family judgment asked of one read.

### The sweep breaks the regression set, and that is a finding rather than a footnote

| run | regressions |
|---|---|
| s1 | **2** — `emerson-q9` and `emerson-q13` |
| s2 | **1** — `emerson-q13` |

`emerson-q13` is Matthew's **correct refusal**, lost in both sweep runs. A run that stops
finding it has not got better, it has stopped looking — and the assertion says so in those
words because that is exactly the reading a bigger pair count invites.

**So the sweep more than doubles the harvest and still loses graded findings.** Recall variance
did not go away; it went up in absolute terms and stayed present in kind. Both sweep runs
recovered a Matthew UNDER that no previous run had found (`under-1` and `under-5`), which is
real gain, and neither held everything it was supposed to.

**Recurrence at 52% on a doubled harvest is the honest summary: the sweep is a large
improvement and not a fix.** No further repair proposed here; the ruling was to build it, run
it twice, measure, and hand the output to Matthew.

---

## 2026-08-05 · session 76 · addendum 13 · the correct refusal leaves the set, and the breakage is one row

`locate-3.0.0+d314a73c`. Sweep graded output produced; the two corrections absorbed.

### The withdrawn assertion, and it changes the headline

`emerson-q13` was a `MUST_APPEAR` and the ruling is right that it should not have been:
**asserting a correct refusal must keep appearing asserts that call 1 must keep making a
mistake call 3 can catch.** It is now `CORRECT_REFUSAL` — reported as `CHANGED, undiagnosed`,
never scored — and the class carries the reason, because my own assertion text (*a run that
stops finding it has not got better, it has stopped looking*) is true of a graded PASS and
false here.

With it withdrawn:

| run | regressions |
|---|---|
| `emerson-sweep-s1` | **1** — `emerson-q9` |
| `emerson-sweep-s2` | **0 — HELD** |

**Named by ref as asked: the single lost graded PASS is `emerson-q9`, Matthew's *Flexibility of
Services Hours*.** And it is not new. It has been absent from every run since the grading —
`0617-r3`, both sweeps. **The sweep did not break it; the sweep did not repair it.** That
distinction was invisible inside my last aggregate and it is the one that matters: this is a
standing recall failure on one specific criterion, not instability introduced by the ruling.

### Design's metric correction, absorbed

Recurrence rate has a denominator that grows with the harvest, so a read finding more marginal
material scores worse at identical stability. **Stable establishments tripled, 9 → 27**, and
the trustworthy share of any one run went 50% → 67.5%. Recurrence rate is a secondary
diagnostic here and the gate is the regression set.

### The sweep, graded end to end

```
pairs located            40 (unit: pairs)
dispositions made        40 · to a person 40 · None or Ambiguous 0
verdicts returned        40 (unit: claims) · upheld 17 · refused 23
```

Zero byte discards, zero coverage defaults, zero traps reproduced. **Seven quotes carry more
than one establishment**, against 1 of 17 under the single read.

### Call 3 no longer fits in one transaction, and that is the sweep's real cost

Forty claims at one per call is **172 s of cumulative callout against a 120-second
per-transaction ceiling that is law-grade and unraiseable.** `verify` now takes only
unverified claims up to a limit and the caller drives it; three batches of 14 finished it.

**The sweep's cost is not call 1's 63 s — call 1 was always going to be fine. It is that
doubling the harvest doubled call 3, and call 3 is the stage with a hard ceiling.** Recorded
here rather than discovered by a timeout on a longer transcript.

### The load-bearing finding, ratified

**Sentiment holds one contract and went from 2 pairs to 11.** It cannot have been capacity-
bound by how many propositions it was holding. The scarce resource is **attention** — what one
read gives any single question when it is also asked sixteen others — and that explains the
rumination, the 15% on B&V, and why two rewordings failed where a partition succeeded without
instructing anything.

**The law it yields, worth stating once:** where an instruction has failed twice, change the
structure so the wrong answer cannot be expressed. Do not write the instruction a third time.

Design's named-but-unproposed next lever (partitioning the artifact rather than the contract
set) is recorded and **not built, not proposed, not ruled**.

### Owed to Matthew

`review/emerson-sweep-s1-FOR-MATTHEW.csv` — 40 establishments, resolution rows first,
multi-establishment rows marked as such, blank UNDER rows at the bottom.
`…-RUN-FACTS.md` carries the per-family table, the per-call latency, the transaction split, and
the regression line naming `emerson-q9`.

Still open and untouched: the seller-side flag, UNDER-3's turn-spanning span.
