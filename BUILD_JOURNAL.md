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

## 2026-08-01 · session 19 · the evidence-family law, and the P route finished

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
