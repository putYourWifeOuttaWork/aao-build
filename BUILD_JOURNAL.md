# Build journal

Append-only. The only part ever rewritten is `## Current state`. Everything below it is
chronological and never edited, including entries that turned out to be wrong — those get
a later entry saying so, never a deletion.

Every working session appends one entry, even a session that achieved nothing. A session
that failed and recorded why is worth more than a session that succeeded silently.

Anything read from the org is quoted, never summarised. Anything assumed goes in the
assumed list rather than being stated as fact anywhere else, because an assumption
recorded as a finding is how a wrong belief becomes load-bearing.

---

## Current state

**Deployed to `altify--aossb2`, green, and clickable.** Org verified by query:
`00DWD00000DV7iT2AT`, Name `Altify`, `IsSandbox true`.

Wave 1 plus Flag is live: seven objects (136 fields), five triggers, three frozen key
composers, span verification, the speaker rule, commit, replay, the mini-rubric and the
dummy transcripts, plus extraction charter v1 and the credential scaffolding it calls
through. **99 AAO tests, 99 passing.** One pre-existing sandbox test still fails on a
customer validation rule, and that failure is not ours.

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

**The first real model call is wired and has not been fired.** A charter assembles its
prompt from `AAO_Evidence_Contract__c` records at runtime, the model writes Candidates only
through `AAO_Pipeline`, and every existing gate decides. **99 AAO tests, 99 passing**,
including eleven that exercise the model path against mocked responses. What is missing is
the API key: it is pasted once into the `AAO_Anthropic` external credential in Setup, and
until it is, the callout fails with `The external credential isn't fully configured`.

Gate 1 round two, once the key is in, on `AAO Gate1 - Model Round Two`, which is isolated
from the three demo deals:

`AAO_Gate1.reset()` · `AAO_Gate1.pass('T1SRC')` · `AAO_Gate1.pass('T2SRC')` ·
`AAO_Gate1.compare()`

The passes are separate commands because Apex forbids a callout after DML in the same
transaction, which is the same reason the rehearsal's passes are separate.

**Still not done, and it is the same gap as the first day:** the mini-rubric is written
straight into `AAO_Evidence_Contract__c` and **discovery is skipped entirely**. The ALTF
rubric objects were confirmed present and empty in this org (session 3), so the ground is
prepared, but discovery itself stays owed and was deliberately not started.

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
