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
dummy transcripts. **74 AAO tests, 74 passing.**

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

**Still not done, and it is the same gap as yesterday:** the mini-rubric is written
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
