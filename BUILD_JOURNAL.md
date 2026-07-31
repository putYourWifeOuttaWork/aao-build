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

**Deployed to `altify--aossb2` and green. The exit test passes in the org.**

Wave 1 is live: six objects (110 fields), four triggers, three frozen key composers, span
verification, the speaker rule, commit, replay, the mini-rubric, the dummy transcripts.
67 AAO tests, 67 passing. `AAO_AccumulationTest.theAccumulationTest` passes, which means
incrementalism is demonstrated in an org rather than in an argument.

One test fails in the run and **it is not ours**: `ConvertToOpportunityTest`, pre-existing
sandbox code, failing on a customer validation rule. See session 2.

```bash
sf project deploy start --target-org aossb2
```

```bash
sf apex run test --target-org aossb2 --tests AAO_AccumulationTest AAO_TriggerLawTest AAO_EvidenceLayerTest AAO_AnswerKeyTest AAO_ScopeKeyTest --result-format human --wait 30
```

**What is not yet done** is the part that makes this a real per-org discovery test rather
than a schema demo: the mini-rubric is written straight into `AAO_Evidence_Contract__c`
and **discovery is skipped entirely**. That is Owed item 3 and it is the biggest gap
between this repo and the brief. Nothing has been seeded into the org as durable data
either — the fixtures exist only inside test transactions, which roll back.

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
