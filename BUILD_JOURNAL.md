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

**Nothing has been deployed. Nothing has been run. No org has been queried.**

The repo holds a complete, deploy-ready Wave 1: six objects (110 fields), four triggers,
the three frozen key composers, span verification, the speaker rule, commit, replay, the
mini-rubric, the dummy transcripts, and the exit test. All of it is **authored, none of it
is verified**, because `altify--aossb2` is not authenticated on this machine and
`sf org login web` needs a human at a browser.

**The next session's first job is to authenticate and deploy.** Until that happens, treat
every claim in this repo about how Salesforce will behave as a hypothesis. The Apex has
never been compiled.

```bash
sf org login web --alias aossb2 --instance-url https://test.salesforce.com
```

Then, from the repo root:

```bash
sf project deploy start --target-org aossb2
```

```bash
sf apex run test --target-org aossb2 --test-level RunLocalTests --result-format human --wait 20
```

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
