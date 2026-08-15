# BUILD_JOURNAL

**LOSS MARKER · 13 August 2026 · THE PRIMARY DEVELOPMENT DEVICE WAS LOST WITH CODE'S ENTIRE REPOSITORY. The build repo had no remote, verified by cloning the only GitHub repository (`altify_moat_simple`, the moat website, 73 HTML commits ending 27 July, zero Apex) and searching its full history for ten known build hashes. Everything before this line — the source tree, the git history, the prior BUILD_JOURNAL, the freeze list file, the regression set, the correction scripts, and the historic `review/` exports — is gone from disk and recoverable only from the sandbox org (`sf project retrieve`, 126 AAO classes, all LastModified 2026-08-13T22:41Z, commit `6fde84a`) and from the claude.ai project's documents. This journal starts over here. It is restarted per the eighty-third stamp's item 4.**

---

## How this file works

One entry per working session, newest at the bottom. Every entry records what was **done**, what was **verified and how**, what was **found**, and what is **owed**. Numbers come from measurement, never from recall. A claim about the state of a document is not written here until that document has been opened by exact path. This file is CODE's, per `README-CHANNEL.md`; design writes `CODE-INBOX.md` and the law and satellite documents, and nothing here ever edits those.

---

## 2026-08-14 · Session 1 · New-device seeding, ledger restoration, repository re-baseline

**Context.** First session on the replacement device. Working folder `/Users/matthewweisberg/Downloads/claude_Aos/claude_code_Aos/`, created empty this morning, not a git repository, no tooling installed. Authorizing bytes: eighty-second stamp item 4(3), "Seed the new local folder from the project's documents"; eighty-third stamp item 1, which rules this folder canonical, and item 4, which authorizes the re-baseline and the private remote.

### Done

1. **Ledger seeded.** `CODE-INBOX.md` written to the canonical folder from the recovery carry. 387,677 bytes, 85 stamp headings, top stamp the eighty-second, tail ending on the eightieth stamp's given-name-rung entry.
2. **Ledger advanced to the eighty-fourth stamp.** The eighty-third and eighty-fourth stamps were spliced in above the eighty-second by a targeted edit rather than a whole-file rewrite. Reason recorded because it is the standing practice from here: re-typing a law document through a model is the drift hazard the thirty-seventh stamp names ("a hand-copied law document risks drift and the project's bytes are the authoritative ones"), and the hazard scales with the bytes re-typed. Splice, never retype.
3. **A partial hand copy was written and then destroyed.** Before the recovery carry arrived, this session began transcribing the ledger from a chat paste and reached the end of the eighty-second stamp (7,601 bytes). It was renamed off the canonical filename the moment a real carry was announced, and deleted when the authoritative 387 KB file landed. No hand-typed ledger text survives anywhere on disk. Recorded because a partial law document sitting at a canonical filename is the split-ledger disease in miniature.
4. **Documents seeded, two carries, 18 documents total.** Inventory and gaps at "Found" below.
5. **Repository initialized and the post-loss re-baseline commit made.** See "Re-baseline" below.
6. **This journal started.**

### Verified, and how

- **Ledger completeness**: byte count, stamp-heading count, and head/tail inspection against the pasted source. Not assumed from the filename.
- **Delivered documents**: every file's first bytes read to confirm it is the document its name claims. All 18 are genuine and carry their own version stamps.
- **Carry completeness**: the delivered set was counted against the 33-item manifest in `SEED-NEW-DEVICE.md`, item by item, rather than accepted as complete. This is what surfaced the gap below.
- **Tooling**: `git` 2.50.1 present. `gh` **not installed**. `sf` / `sfdx` **not installed**. Verified by invocation, not by assumption.

### Found

- **A state claim in the eighty-third stamp is wrong on this disk, and it is load-bearing.** Item 3 lists "the corpus record" among the documents "Delivered and verified", and then reasons from it: "the corpus record now carries their hashes, so any raw that arrives later is verifiable before use." **`aao-unseen-corpus-record-v1_0.md` is item 18 of the manifest and did not arrive in either carry.** It is not on disk. The consequence is real rather than clerical: it is the file carrying the fixture hashes, and the eighty-second stamp's own recovery plan makes it the sole path back to the lost freeze list ("the freeze list's substance is reconstructible from the corpus record and the stamps that quote it"). Until it lands, no arriving raw fixture can be hash-verified before use. Reported to design; not corrected here, because this journal does not edit the ledger.
- **The rest of the eighty-third stamp's item 3 checks out.** The other fourteen documents it names as delivered are on disk, and the five law documents, the adjudication sheet, the machine read sheet, the a23 diagnosis, the fixtures and the graded CSVs are correctly named as still owed.
- **A size-ceiling hypothesis of this session's was wrong and is marked so.** Observing that everything arriving was ≤17 KB while everything outstanding was large, this session proposed a truncation ceiling as the carry gap's mechanism, flagging it as suggestive rather than proven. The eighty-third stamp's item 2 supplies the measured cause: the recovery archive was built before the manifest was written and the two were never reconciled, so the missing items were never sent. No truncation exists. Marked wrong in place, not deleted.

### Re-baseline

Per the eighty-third stamp's item 4, in its order:

- **Time Machine check: NOT YET ANSWERED, and it is owed before the retrieve.** The stamp puts it first and prices it at ten seconds, because a backup returns the repository with its history and turns `sf project retrieve` into a cross-check instead of a rebuild. Nothing was spent on the retrieve while this is open.
- **Sandbox authentication: NOT DONE.** The Salesforce CLI is not installed on this device. Production needs no auth from a build machine, ever, and none was attempted.
- **Metadata retrieve: NOT DONE**, blocked on the two items above. The acceptance check when it runs is a live query and never a list: 126 AAO classes, every one LastModified 2026-08-13T22:41Z, diff clean.
- **Repository: INITIALIZED**, first commit labeled as the post-loss re-baseline, carrying the ledger, this journal, and the 18 seeded documents. The Apex source tree joins it at the retrieve.
- **Private remote: see the entry below.**

### Owed

1. The Time Machine or other backup answer, Matthew's, before any retrieve.
2. Salesforce CLI installed and authenticated to the **sandbox only**.
3. `sf project retrieve`, then the live-query check (126 classes, 2026-08-13T22:41Z, diff clean), then a second commit carrying the source.
4. The remaining 17 manifest items, priority order per the eighty-third stamp: `aao-unseen-corpus-record-v1_0.md` first on this session's finding above, then the adjudication sheet (§11), then the Board, then the rest.
5. Then the eighty-fourth stamp's queue in its order: the per-leg resolution diff report (report only, no build); the LOR contracts and the read-only measurement run, now unblocked by Matthew's plain-word yes; the wiring proposal on the diff's result; the config-inventory status confirmation riding any report.

---

## 2026-08-14 · Session 1, continued · Build tooling installed on the new device

At Matthew's direction, install everything the device needs. Nothing was elevated: no `sudo` was run, and no password was requested or handled.

### Done

- **npm's global prefix moved to a user-local path.** It was `/usr/local`, which is not writable without elevation. Now `~/.npm-global`, set in `~/.npmrc`. This is the standard sudo-free arrangement and it is recorded because it is a change to Matthew's user environment, not just to this folder.
- **Salesforce CLI installed**: `@salesforce/cli` 2.147.7, darwin-arm64 on node v24.16.0, via npm global. Core plugins present.
- **GitHub CLI installed**: `gh` 2.97.0 (released 2026-07-31), the official darwin-arm64 build from `github.com/cli/cli` releases, unpacked to `~/.local/opt/gh` and symlinked into `~/.npm-global/bin`. **The download was SHA-256 verified against the checksums file published in the same release before anything was extracted or run**: expected and actual both `a58b8fd77b417a38f47a0b54d1370c59b0fcdb324ccc9ca002b0998f7c4c999e`. A binary pulled off the network is exactly the kind of artifact this project verifies rather than trusts.
- **PATH persisted**: `~/.npm-global/bin` prepended in `~/.zshrc`. Verified from a fresh login shell rather than from the current one, because a tool that only resolves inside the shell that installed it is not installed: `sf` → `~/.npm-global/bin/sf`, `gh` → `~/.npm-global/bin/gh`, both reporting their versions.

### State

- `gh` is installed and **not authenticated** — "You are not logged into any GitHub hosts." Authentication is Matthew's to perform; this session neither requests nor handles tokens.
- `sf` is installed and **authenticated to nothing**. When it is, it authenticates to the **sandbox only**. Production is read-only unconditionally and needs no auth from a build machine, ever.

### Owed, superseding the list above

1. **The Time Machine or other backup answer**, Matthew's, still first and still ten seconds: a backup returns the repository with its history and turns the retrieve into a cross-check instead of a rebuild.
2. `gh auth login` by Matthew, then the private remote is created and the re-baseline commit pushed.
3. `sf` authenticated to the sandbox, then `sf project retrieve`, then the live-query check (126 AAO classes, every one LastModified 2026-08-13T22:41Z, diff clean), then a second commit carrying the source.
4. The 17 outstanding manifest documents, `aao-unseen-corpus-record-v1_0.md` first per this session's finding.
5. Then the eighty-fourth stamp's queue in its order.

---

## 2026-08-14 · Session 1, continued · THE SOURCE IS BACK · retrieve verified against the org

Matthew reports no Time Machine backup, so the sandbox is the only source of truth and the eighty-third stamp's no-remote branch runs in full. Authorizing bytes: eighty-third stamp item 4.

### The org, queried before anything was pulled

`00DWD00000DV7iT2AT`, Name `Altify`, **`IsSandbox = true`**, InstanceName USA758S, Enterprise Edition. Authorized as `matt.weisberg@altify.com.aossb2` against `https://altify--aossb2.sandbox.my.salesforce.com`, API version 67.0. Production was never authenticated and needs no auth from a build machine, ever. `sfdx-project.json` carries `sfdcLoginUrl: https://test.salesforce.com` so this project cannot quietly default at production later.

### The acceptance check, a live query and never a list

- **126 AAO Apex classes.** Matches the eighty-second stamp's number exactly.
- **All 126 modified inside a three-second window**, `MIN(LastModifiedDate) = 2026-08-13T22:41:50Z`, `MAX = 2026-08-13T22:41:53Z`. One deployment, which is the `6fde84a` deploy the ledger names. The stamp's "every one LastModified 2026-08-13T22:41Z" holds.

### Retrieved to `force-app/`, counted on disk against the org census

| Type | On disk | Org census |
|---|---|---|
| ApexClass `AAO_*` | 126 | 126 |
| ApexTrigger | 9 | 9 |
| CustomObject (incl. 4 `__mdt`) | 17 | 17 |
| CustomMetadata records | 68 | 68 |
| LightningComponentBundle | 3 | 3 |
| StaticResource | 4 | 4 |
| FlexiPage | 5 | 5 |
| CustomTab | 5 | 5 |
| PermissionSet | 1 | 1 |

700 files total. The 68 custom metadata records break down as 56 `AAO_People_Question`, **10 `AAO_Map_Value`**, 1 `AAO_Model_Config`, 1 `AAO_Setting`. The ten Map_Value rows are the seventy-eighth stamp's "six buyer-role, four political", recovered intact. `AAO_Created_Row__c` — the create-leg record — is among the 17 objects.

### Two process findings, both from checking rather than trusting

1. **The first retrieve pulled nothing and exited 0.** `force-app/` did not exist, so the CLI raised `MissingPackageDirectoryError` and still returned exit code 0 to the shell. Taking the exit code as the answer would have produced an empty tree committed as a re-baseline. **Standing consequence: a retrieve is verified by counting what landed on disk against the org, never by its exit status.**
2. **The metadata census caught two types the retrieve filter had missed.** A wildcard filter list is a guess about what exists; `sf org list metadata` per type is the fact. `FlexiPage` (5) and `CustomTab` (5) were absent from the first filter set and are in the tree only because the census ran. Same law as always: enumerate, then verify against the enumeration.

### RECOVERY, larger than expected · THE FROZEN FIXTURE BYTES ARE IN THE ORG AND THEY SELF-VERIFY

The static resources carry normalized NF1 fixture bytes, and **their SHA-256 prefixes match hashes this ledger already quotes**, so they are verifiable today without the corpus record:

| Static resource | Bytes | SHA-256 (first 16) | Ledger citation |
|---|---|---|---|
| `AAO_Emerson_0617_NF1.txt` | 42,784 | `ec8e717045f87015` | Seventh stamp: "everything was calibrated on `ec8e7170`, so it is now the training set" |
| `AAO_Emerson_Transcript.txt` | 19,774 | `9e9740060bd348a1` | Fifteenth stamp: "run `emerson/aspentech-2026-07-29-nf1` (`9e974006`)" |
| `AAO_BV_Transcript_NF1.txt` | 43,129 | `2bed419d1079cdde` | Black and Veatch NF1; no hash quoted in the ledger, so this one still needs the corpus record |
| `AAO_Seed.json` | 13,307 | `569073ad8c49649d` | The seed, carrying the internal-domain list per the eighty-first stamp |

Two of the four are now confirmed against the ledger's own bytes by independent hash rather than by filename. This narrows what the missing corpus record is needed for; it does not remove the need for it, since the Black and Veatch hash and every counting status still live only there.

### Owed, superseding the list above

1. `gh auth login` by Matthew, then the private remote and the push. **The history still exists on exactly one machine, which is the condition that caused this journal to start over.** Highest-value open item.
2. The 17 outstanding manifest documents, `aao-unseen-corpus-record-v1_0.md` first.
3. Then the eighty-fourth stamp's queue in its order: the per-leg resolution diff report (report only); the LOR contracts and the read-only measurement run.

---

## 2026-08-14 · Session 2 · The bridge returns · a defect of this journal's own · the remote closes

### DEFECT, this session's own, recorded before anything else · COMMIT `3a1db34` DOES NOT CONTAIN WHAT ITS MESSAGE SAYS

`3a1db34` is titled "journal: remote created public, flipped private and verified before any push." **It also silently carried all seventeen owed manifest documents and the entire eighty-fifth stamp**, because every commit this session was made with `git add -A` and design's bridge had written them to the canonical folder between commits. Measured: `CODE-INBOX.md` went 87 stamps / 397,699 bytes at `34c4331` to 88 stamps / 404,442 bytes at `3a1db34`, and `git log --diff-filter=A` puts `aao-board.md`, `aao-charters.md`, `aao-unseen-corpus-record-v1_0.md`, the adjudication sheet and the fixture raws all at that same commit. **Seventeen law and evidence documents entered the permanent record under a commit message about a GitHub setting, and were pushed that way.**

**The evidence was in front of me and I explained it away.** Verifying the push, this session counted "local docs at root: 38" against an expectation of about 21, noted the discrepancy in its own output, and moved on with "the important verification holds" because the local-versus-remote totals matched. The totals matching is exactly what a silent `git add -A` sweep guarantees; it cannot detect the sweep. **A number that does not match the expectation is a finding, not a rounding difference, and moving on because a different check passed is how a carry lands unexamined.**

**Standing consequences, both adopted:**
1. **`git status` is the cheapest detector of a landed carry, and it is checked at every pickup.** Design's correction, credited: the ledger never arrives as a new file, it updates IN PLACE at the canonical path, so an mtime sweep across other folders finds nothing while `git status` has been saying `M CODE-INBOX.md` the whole time. This session swept `Downloads`, `Desktop` and `Documents` for new files and explicitly excluded the repo folder as "our own activity", which is precisely where the answer was.
2. **Commits are staged deliberately, never `git add -A` on a folder another agent writes to.** The canonical folder has two writers by law — design writes the ledger and the documents, CODE writes `review/` and the repo — so a blanket add will keep silently absorbing design's work under CODE's commit messages. Paths are named from here, and anything unexpected in `git status` is inventoried before it is staged.

### The carry, verified on disk

`CODE-INBOX.md` now 410,809 bytes, 89 stamp headings, mtime 2026-08-14 14:26:04 local. Eighty-sixth stamp at line 12, eighty-fifth at line 32, eighty-fourth at line 52, everything below untouched. **The splice was performed by design; this session re-spliced nothing and retyped nothing.** Also landed: `aao-wf-corpus-stage-arc-v0_1.md`, 6,281 bytes.

**The manifest is confirmed closed from this side**, checked by exact filename rather than taken from the stamp: all seventeen previously-absent items are present, zero absent, 37 documents at the canonical root. The eighty-fifth stamp's item 2 corrects the eighty-third's wrong claim about the corpus record and credits session 1's count; the record is now consistent.

### The remote · ITEM 5 CLOSES · VISIBILITY CONFIRMED FROM THE API

The eighty-sixth stamp's item 5 asks for visibility verified rather than assumed. **Confirmed from the GitHub API, not from the flag passed and not from the command's silence:** `GET /repos/putYourWifeOuttaWork/aao-build` returns `private: true`, `visibility: private`. The sequence was: repository found already existing and **public** (`private: false`, 0 KB, never pushed); push withheld; `gh repo edit --visibility private`; **re-read from the API and confirmed private while still empty**; then and only then the push. Nothing was ever exposed.

Push verified end to end: five commits on the remote, remote HEAD `3a1db34` identical to local HEAD, 738 blobs on the remote against 738 local tracked files, working tree clean. **The eighty-fifth stamp's HIGH finding and the eighty-sixth stamp's item 5 are both closed.**

### Next

The eighty-sixth stamp's queue item (b): the per-leg resolution diff report, `AAO_Pass.identify` against the twenty-seventh stamp's text and against `AAO_Resolve`. **Report only, no build**, per the eighty-first stamp's condition 3(i).

### The suite · RUN AND VERIFIED · exactly the expected shape

Test run `707WD0000A84Avs` against aossb2, `RunLocalTests`, 232,553 ms. **501 methods, 500 Pass, 1 Fail**, and the one failure is the standing non-AAO one the ledger has carried since the fourth stamp: `ConvertToOpportunityTest.testgetOppCreationDetails`, failing on `FIELD_CUSTOM_VALIDATION_EXCEPTION — AE Summary is required when no opportunity is created`, an org-resident validation rule on a non-AAO object. **The eighty-second stamp's expected shape, "500 of 501 with the standing non-AAO failure", is met exactly.** No AAO test fails. The retrieved tree is a working build, not just a syntactically valid one.

### The remote · CREATED PUBLIC BY DEFAULT, CAUGHT BEFORE THE PUSH

`putYourWifeOuttaWork/aao-build` was created through the GitHub UI and came back **public**: `private: false`, `visibility: public`, created 2026-08-14T16:13:41Z, 0 KB, never pushed. It was checked by API before anything was pushed into it, and the push was withheld.

**What a public push would have exposed, named precisely, because this is why the eighty-third stamp says PRIVATE:** the four static resources carry whole normalized customer transcripts as bytes; the ledger and the run README name real people with their titles, buyer roles and political placements at Emerson, Wells Fargo, Project Farma and Black and Veatch; live Salesforce record IDs appear throughout; and the strategy record, competitive positioning and pricing discussion are in the documents. The repository was flipped with `gh repo edit --visibility private` and **re-verified from the API rather than from the command's silence**: `private: true`, `visibility: private`, still 0 KB. Only then was the push attempted.

**Standing consequence: a remote's visibility is verified by reading it back from the API before the first push, never assumed from the flag passed or from the UI default.** Nothing was exposed, because the repository was empty for the whole window between creation and verification.

**And the CLI's own summary was wrong, which is worth recording because it is this project's own law biting in a new place.** The human-format banner printed `Outcome: Failed` beside `Tests Ran 501`, `Pass Rate 100%`, `Fail Rate 0%` — a summary that contradicts itself, and whose rates would have had this session report a clean suite. The truth came from querying the run's own rows: `SELECT Outcome, COUNT(Id) FROM ApexTestResult WHERE AsyncApexJobId = '707WD0000A84Avs' GROUP BY Outcome` returns Pass 500, Fail 1. The run-level row disagrees again in its own way (`MethodsCompleted 481` against `MethodsEnqueued 501`), so the per-method rows are the only trustworthy grain. **Standing consequence, the same one the working mode already states for run reports: a summary is not evidence, the rows are. This now applies to tool output as much as to our own reports.**

---

## 2026-08-14 · Session 2, continued · CORRECTION IN PLACE for commit `3a1db34` · two verification laws adopted

### CORRECTION · WHAT COMMIT `3a1db34` ACTUALLY CONTAINS

`3a1db34` is pushed, so its history is not rewritten and its message is not edited. The wrong text stands where it is and is corrected here, per the corrections law.

**Its message reads** "journal: remote created public, flipped private and verified before any push." **What it actually contains, in addition to that journal entry:**

- **All seventeen previously-owed manifest documents**: the five law documents (Board, Glossary, Architecture, Model and Flow, Charters), the corpus record v1.1, the adjudication sheet, the machine read sheet, the a23 refusal diagnosis, the four fixture raws, the Pitch capture sidecar, the two graded CSVs, and the tg1-versus-Pass-1 grading record.
- **The entire eighty-fifth stamp.**

**The receipt, measured:** `CODE-INBOX.md` stood at **87 stamps / 397,699 bytes at `34c4331`** and at **88 stamps / 404,442 bytes at `3a1db34`**. `git log --diff-filter=A` places `aao-board.md`, `aao-charters.md`, `aao-unseen-corpus-record-v1_0.md`, `aao-adjudication-sheet.md` and `aao-fixture-projectfarma-2026-07-30-raw.txt` at `3a1db34`.

**Cause:** every commit in session 1 used `git add -A` on a folder design also writes to, so design's bridge writes were swept into CODE's commits between commits. **Nothing was lost and nothing was wrong on disk; the record of WHO PUT WHAT THERE AND WHEN was wrong, which is the part a ledger exists to keep.**

### Two verification laws adopted this session

**1 · A STAMP COUNT COUNTS STAMPS, not H2 headings.** This session verified splices with `grep -c '^## '`, which returns **89** on the current ledger while the top stamp is the **eighty-sixth**. Eight H2s are not stamps: "The new working mode", "a20 verification, midday", "Prior findings, 6 August morning", "Build queue, in order", "Ratified from your a19 report", "Standing, unchanged", "Sequence out", and "For the next design session". The correct pattern is `^## <Ordinal> stamp`, which returns **81**, and **81 reconciles exactly with an eighty-sixth top stamp**: ordinals one through three predate this re-stamped file, and the eighth and ninth were absorbed at re-stamp, which the ledger documents in its own text at the tenth stamp. Adopted: count `^## [Ordinal] stamp`, and reconcile the count against the top ordinal through documented gaps, so a heading count can never drift into being read as a stamp number.

**2 · A COMMENT ASSERTING THE ABSENCE OF A CAPABILITY IS A STATE CLAIM.** `AAO_Pass.cls:1087-1091` says the shadow-creation path "is the gates' work and is not built." It is built and live. The state-claim law binds a comment exactly as it binds a stamp: unverified until the code it names is opened. Recorded because this report and design both read that comment as current before it was checked.

### The `identify-1.0.0` pinning check · BENIGN, and one count corrected

Design flagged six test files pinning `identify-1.0.0` while the charter emits `identify-2.0.0`. **Measured: four test files, five occurrences** — `AAO_CriteriaTest` (2), `AAO_PairCommitTest` (1), `AAO_RunInspectorTest` (1), `AAO_RunExportTest` (1). A fifth file carries the string but is a document, not code: `aao-adjudication-sheet.md`.

**All five occurrences are fixture literals**, of the form `AAO_Charter_Version__c = 'identify-1.0.0'`, setting a field on a pair row the test constructs. **No test asserts an emitted charter version against a pinned one anywhere in the suite** — a search for any `assertEquals` referencing a version, and specifically for any assert referencing `AAO_IdentifyCharter.VERSION`, returns nothing. So nothing is asserting a stale constant, and the suite's 500 of 501 is not resting on one. They are inert historical values in test data. **Not changed**: they are not defects, and editing test fixtures to chase a version they never assert would be churn. Recorded so the next session does not re-investigate.

---

## Session 107 · 15 August · THE ANCHOR FIELDS WERE ALWAYS IN THE ORG · the eighty-ninth stamp's item 5 answered as 5(c), with a mechanism · TWO SOURCE TREES AND A THIRD ORG · CODE's own "not in the org" corrected against itself

**Correction first, per the corrections law.** CODE reported that the eight utterance-anchor fields
were absent from `00DWD00000DV7iT2AT`, and recommended taking it to Matthew as an environment
blocker. **That was wrong.** The fields were deployed and present the entire time. The eighty-ninth
stamp's item 1 and item 2 are wrong in the same direction and for the same reason, and both are
corrected here rather than at either party's expense: **design and CODE independently read an
FLS-filtered view of the org and reported it as existence.** Two instruments agreeing is not
corroboration when both share a blind spot.

### The mechanism, measured rather than reasoned

A field deployed through the Metadata API grants field-level security to **no permission set and no
profile, System Administrator included.** An unpermissioned field is:

- absent from `sf sobject describe`
- absent from standard-API `FieldDefinition`
- uncompilable in anonymous Apex, which compiles against the running user's accessible schema
- **fully present** in Tooling-API `FieldDefinition`, carrying a real `LastModifiedDate`
- **fully usable** by deployed Apex, which compiles in system context and ignores FLS

Same object, same org, same second, two APIs: **33 fields via Tooling with all eight present at
`2026-08-15T12:42:24Z` and `13:07:38Z`; 24 fields via the standard API with all eight absent.**
Design's 24-row result is that second row exactly.

### The control nobody designed, and it is what makes this a diagnosis

`AAO_Shadow_Key__c` was modified in the same deploy at the same second and **stayed visible
throughout**. It is `required=true`, and a required field's FLS is universal and unrestrictable.
All eight anchors are `required=false`. Same deploy, same object, same second, opposite visibility,
and the only difference between them is one flag. `FieldPermissions` confirms it from the other
side: the eleven older fields each carry `AAO_Admin`; the eight anchors carried only the
system-granted `sfdc_slack`; and `AAO_Admin.permissionset-meta.xml` named the eleven and none of
the eight.

### The eighty-ninth stamp's new law: its example is wrong, and the law needs one clause

`created=false` was **literally true and correctly reported** — the fields already existed, so
there was nothing to create. The deploy never lied; every `Succeeded, 22 components` was accurate.
More sharply: the law's prescribed remedy, querying `FieldDefinition` for the specific API names
after the deploy, is precisely what design did, and it **returned the wrong answer**. The
amendment the evidence forces:

> A report of deploy success names the org id the query ran against **and** whether the API used
> enforces FLS. Existence and visibility are two facts, and a report states both.

Which is the field-with-no-readers law one level down: **a field with no permission is a field with
no readers, and it reads as a field that is not there.**

### The second finding, independent, and the larger process hazard

- **The global `sf` default target org is `altify-dev` `00Dg500000B0KjZEAV`**, not the sandbox.
  Neither project set a project-level target org, so any `sf` command without `-o` addressed it.
  `AAO_Shadow_Person__c` **does not exist in that org at all** (`describe` → `NOT_FOUND`,
  `FieldDefinition` → 0 rows).
- **Two source trees exist on this device.** `/Users/thefinalmachine/Downloads/claude` (`main`,
  project `aao-build`) carries 21 field files including all eight anchors.
  `/Users/thefinalmachine/Downloads/aao-sandbox` (`master`, project `aao-sandbox`) carries 13 and
  none of the eight. **The second is the pre-loss lineage and is evidence under the custody rule;
  nothing in it was touched, including its `sf` config.** It is also the shell's default working
  directory.

Two independent ways for a command to silently address the wrong thing. **Fixed in the live tree
only:** `sf config set target-org=aossb2`, verified by `sf org display` returning
`00DWD00000DV7iT2AT`. The eighty-ninth stamp's item 4 is therefore answered in the negative as it
stood, and answered in the affirmative from here.

### The fix and its verification

Eight `fieldPermissions` blocks added to `AAO_Admin.permissionset-meta.xml`, readable and editable,
all eight being writable non-formula fields. Deployed **explicitly `-o aossb2`**, job
`0AfWD00000FuquX0AR`, host `altify--aossb2.sandbox.my.salesforce.com`.

**Verified by the org, FLS-aware, all three affirmative:**

| instrument | before | after |
|---|---|---|
| FLS-aware `FieldDefinition` | 24 fields, eight ABSENT | **32 fields, all eight PRESENT** |
| anonymous Apex probe | compile failed at line 2 | **Compiled successfully · `COMPILE PROBE OK: probe`** |
| SOQL selecting all anchor columns | — | **succeeds, 0 records** |

The eight API names, as item 5 requires: `AAO_Designator__c`, `AAO_Anchors__c`,
`AAO_Anchor_Count__c`, `AAO_Identity_Provenance__c`, `AAO_Utterance_Source__c`,
`AAO_Utterance_Start__c`, `AAO_Utterance_End__c`, `AAO_Utterance_Quote__c`.

### What it does to the read

**S5-19, DELTA-1, and the mention-held half of S5-18 are MEASURABLE.** The eighty-ninth stamp's
item 8 fallback does not fire and those rows do not grade NOT MEASURABLE. **The honest boundary,
unchanged:** these fields have never held a row, so their writability under load rests on the suite
alone, and the WF read is still the first real exercise of the branch that writes them — the
eighty-eighth stamp's zero-coverage disclosure stands untouched.

Report and every artifact: `review/anchor-visibility/`.

### Session 107, cont'd · THE LOOSE ARTIFACTS IN `~/Downloads`, swept by hash and preserved selectively

Matthew flagged that deliverables have been landing loose in `~/Downloads`. Swept the whole
directory, compared **by content hash against every file in the repo**, never by name, so a
same-named older copy could not read as present and a renamed identical copy could not read as
missing.

**Brought in, because it is human-authored and irreplaceable** (`review/human-grading/`): the a23
graded CSV, 43 rows, and five Numbers grading surfaces Matthew worked in by hand plus the tg1
sheet's Numbers original. The eighty-second stamp's item 3(b) named this exact class as the true
archive loss if no remote exists; a remote exists now.

**The load-bearing gap it closed:** the repo held the tg1 graded CSV and **no machine-readable a23
grading at all** — the a23 grades lived only as prose in the adjudication sheet's §11 and the
refusal diagnosis. That is the only row-level human grading on unseen speech this project has, the
source of refusals 0-of-18 against the training set's 21-of-23, and the thirty-seventh stamp calls
its comparison "mechanically derivable." **Prose is not a source for a mechanical derivation.**

**Left out, each checked rather than assumed:**

- **Five `CODE-INBOX` snapshots** (8 August, topping at the nineteenth, twenty-eighth,
  twenty-ninth, thirtieth and thirty-second stamps). Sampled 38-39 of 40 long lines from each
  already present verbatim in the live ledger; the misses are lines later struck in place per the
  corrections law. Nothing recoverable. Matthew's own read of these was right.
- **Every context archive** (`aao-context_1`–`_27`, `aao-bundle`, `AAO_aug2_7pm`, `AAAO_AUG31`, the
  code handoffs, `aao-docs-2026-08-08`). All carry law documents at states the repo has passed:
  that archive's adjudication sheet is 40,003 bytes against the repo's 57,594 with §11.
- **`altifyos-*`, decks, PDFs, architecture PNGs, charter-design v0.7–v1.8, corrections v2.4–v2.8,
  proof registers, board v22.** Superseded lineage or communication artifacts; none load-bearing on
  an open item.

`review/ledger-deliveries/` keeps `aao-stamp-87.md` as carry provenance, so a splice can be
re-verified against the bytes it was made from rather than against a memory of them.

**The originals remain in `~/Downloads` untouched.** Nothing was moved or deleted; these are copies.

---

## Session 108 · 15 August · THE IDENTIFICATION FLAG IS BUILT AS A MECHANISM · the org refused a wrong fixture and exposed a real defect in the class it was testing · suite 516, 515 AAO passing · THE RAISE HAS NO PRODUCTION CALLER YET, and that is stated rather than glossed

The ninetieth stamp's item 10, second clause: "the Identification flag as a BUILT MECHANISM -
`AAO_Flag__c.AAO_Type__c` still has no `Identification` value, and a picklist value is not the
mechanism: type, raise at both held sites, bound key, clear-by-identification-only, test."

**All five parts built.** `AAO_Identification` plus `AAO_IdentificationTest`, 8 tests, and the
two collection points in `AAO_Resolve`.

### The five parts

**TYPE.** `Identification` on `AAO_Type__c`; `Identity_Ambiguous` and `Identity_Unresolved` on
`AAO_Cause__c`. Two causes, not one, because they are different work: one asks a human to PICK
between candidates, the other to NAME somebody the org has never heard of. Verified in
`00DWD00000DV7iT2AT` through the FLS-aware Apex describe, which is the running org's answer:
`TYPE has Identification: true`, both causes true.

**RAISE AT BOTH HELD SITES.** `AAO_Resolve`'s AMBIGUOUS terminal and the model leg's HELD
terminal. **Both COLLECT onto the result object; neither writes.** Raising is DML and
`AAO_Resolve.requests()` throws when DML has already run in the transaction, so a write on
that path would arm the very guard that protects the callout. A test greps the deployed class
body and fails if `AAO_Resolve` ever gains a `raiseFor` call.

**BOUND KEY.** `ident|<oppId>|<normalised designator>`, the cardinality guard's own pattern
reused. Priya in s3 and Priya in s4 are ONE unidentified person; three mentions raise one flag,
and `"  priya  "` normalises onto the same key. A cleared flag is never reopened by a later
mention.

**CLEAR BY IDENTIFICATION ONLY.** `reconcile` re-reads the org and clears exactly those
designators now bound to a Contact, recording WHO on `AAO_Subject_Contact__c` as the receipt.
It does not clear on acknowledgement (tested), on age, or because a later run stopped
mentioning the person.

### The org refused a wrong fixture, and the refusal found a real defect

The first fixture put the designator and the person on one pair. The insert was refused:
*"A Located pair carries the person (AAO_Person__c), which is not call 1's to write."*

That is `AAO_PairTriggerHandler` enforcing the charter separation as a database error rather
than a sentence in a prompt, and **it exposed a defect in the class the fixture was testing.**
Call 1 writes `AAO_About_Designator__c` onto the Located pair and is forbidden the person; call
2 writes the person onto an Identified pair pointing back at it, and `AAO_Resolve.disposition()`
does not copy the designator forward. **My clear path queried both columns on one row, so it
could never have matched, ever, and the flag would never have cleared.** Corrected to read the
designator through `AAO_Located_Pair__r`. The code was fixed, not the test.

Recorded because it is the discipline paying in an unusual direction: the fixture was wrong, and
being wrong against a real org is what made the defect visible. A hand-rolled in-memory fixture
would have passed and shipped a flag that never clears.

### THE BOUNDARY, named because a mechanism with no caller is a plan

**`AAO_Resolve` still has ZERO production callers** - the eighty-first stamp's finding, unchanged
and re-measured this session. So the two raise sites cannot fire in production until the ladder
is driven from the pass, which is item 10's FIRST clause and is still to do. **The flag does not
raise on a live run today.** Saying otherwise would be the field-with-no-readers pattern wearing
a new coat, one paragraph after this class's own header warns about it.

What is true: the mechanism is built, deployed, and tested against the org, and it needs no
further change when the ladder lands - the collection points are already in both terminals.

**Also disclosed:** the clear path reads `AAO_Shadow_Person__c.AAO_Promoted_Contact__c` as its
second binding, and **nothing writes that field** - promotion is the eighty-eighth stamp's named
debt. It is read deliberately so wiring promotion clears these flags with no change here, and it
is a reader waiting on a writer rather than a working path sold as one.

### Suite

516 ran, one failure, the standing non-AAO `ConvertToOpportunityTest`. 515 AAO passing, up 8 from
508. Deploy target org named per the ninetieth stamp's item 8: `00DWD00000DV7iT2AT`, from
`/Users/thefinalmachine/Downloads/claude` on `main`, every command carrying `-o aossb2`.

---

## Session 109 · 15 August · THE LADDER IS WIRED AND THE FLAG FIRES · rung 3 proven live through the driven path on a THROWAWAY, never Wells Fargo · `AAO_Resolve` has a production caller for the first time since the eighty-first stamp measured it had none

Authorising bytes, ninety-first stamp item 4: *"The wiring is done when S4-09 fires on a live
Wells Fargo run, not when the suite is green - the suite already passes with the mechanism
unreachable, which is the field-with-no-readers pattern in its sixth instance, a mechanism with
no caller."*

### What was built

`AAO_Pass.identifyDeterministic(sourceId, runKey)` returning `DeterministicRun`, plus
`AAO_Pass.raiseHeld(requestRun)` for the model leg's terminal. The eighty-first stamp's option
(a): the deterministic legs dispose what a byte lookup and a closed-list ladder can settle, and
the model leg takes only the remainder. `identify()` already excluded already-identified refs,
so the remainder falls out of ordering rather than a rewrite - **`AAO_Resolve` is retargeted,
not rewritten**, which is what wiring proposal v3 ruled.

**A NAME COLLISION CAUGHT BEFORE IT COMPILED.** The first draft called this `resolve` returning
`ResolveRun`. Both are taken, and taken correctly: `AAO_Pass.resolve` is CALL 0, the SCOPE
resolver. This leg resolves IDENTITY, which is call 2's job, so it took call 2's word. Two
different questions must not share a verb on the class that dispatches both.

**THE TRANSACTION BOUNDARY IS WHY IT IS ITS OWN ENTRY POINT.** This writes dispositions, mention
participants and flags; `identify` makes a callout; callout-after-DML is refused by the platform
and `AAO_Resolve.requests()` already throws by hand to say so. The caller runs this, commits,
then calls `identify` only when `hasRemainder` - which on a clean transcript is never, and that
zero is the twenty-seventh stamp's predicted arithmetic rather than a failure.

### THE FLAG FIRES, measured

Run through the wired entry point on a throwaway account, `-o aossb2`, org `00DWD00000DV7iT2AT`:

```
BEFORE: standing identification flags = 0
pairs read               1 (unit: pairs)
AFTER:  standing identification flags = 1
FLAG Identification / Identity_Ambiguous / Standing / Identify "Bettina Marchetti"
     key=ident|006WD00000TlT2fYAF|bettina marchetti
```

**NOT ON WELLS FARGO.** The eighty-eighth stamp's item 1 and Matthew's own words: the instrument
gets no rehearsal, ever. Verified after: WF `006WD00000TWvH0YAL` still carries 3 sources and
**0 identification flags**. S4-09 itself grades at the read; this proves its mechanism is
reachable, which is precisely what item 4 says the suite could not prove.

### A DESIGN FACT THE PROOF SURFACED, worth design's eye

**LADDER-ZERO DOES NOT RAISE.** The first proof used a designator matching nobody and no flag
appeared - correctly. Ladder-zero falls to the REMAINDER for the model leg, which may still
resolve it, and flagging before that would cry wolf. The deterministic held site is AMBIGUOUS
only; ladder-zero's flag comes from the model leg's HELD terminal through `raiseHeld`. So on a
run where the caller does not fire the model leg, a ladder-zero designator raises nothing. That
is deliberate and it is stated so nobody reads a missing flag as a defect.

**Consequence for the read:** S4-09's path depends on which terminal Bettina and Priya land in.
An ambiguous designator flags without a callout; an unmatched one flags only after the model leg
runs. Both are wired.

### THE RESIDUE, marked and reported rather than forced

The proof deliberately ran the LIVE path (`AAO_Synthetic.MARK = false`) so it exercised what the
read will exercise. That fidelity has a price: the rows it produced are real, and the org refused
to delete them, twice, correctly.

- `AAO_Flag__c`: *"not deletable on the live path. A flag is cleared by evidence... Deleting one
  destroys the measurement it exists to produce."*
- `AAO_Pair__c`: *"The pair ledger is the record that a stage ran at all... a deleted row makes
  those counts lie rather than fail."*

`AAO_Synthetic.deletable()` permits deletion only of synthetic rows while purging, so these
stand. **Residue: 2 accounts (`001WD00000v1dL7YAI`, `001WD00000v1qWnYAI`, both named
`AAO WIRE PROOF THROWAWAY`), 2 opportunities, 2 sources, 3 pairs, 1 flag.** Isolated from Wells
Fargo, Emerson and Project Farma; it cannot contaminate a read. Marked and reported, the
twenty-first stamp's own disposition for a machine row we cannot lawfully remove.

**The lesson, kept:** a proof script either marks synthetic throughout and proves less, or runs
live and leaves permanent evidence. It cannot do both. Choose deliberately and say which.

### Suite

516 ran, one failure, the standing non-AAO `ConvertToOpportunityTest`. 515 AAO passing,
unchanged by the wiring.

---

## Session 110 · 15 August · THE SCHEMA AND FLOW REFERENCE · four deliverables, 1,161 lines, all from the org or the repo · THE FLS DIFF IS CLEAN AT 317 = 317 · zero declarative validation rules · the Claim Basis question answered: the link moved, it is not missing

The ninety-third stamp's item 3. Every file names the tree and the org id, per the tree-and-org
hazard: `/Users/thefinalmachine/Downloads/claude` on `main`, org `00DWD00000DV7iT2AT`.

Design's `aao-org-field-inventory-2026-08-15.md` committed first as `045615d`, unmodified, as
the baseline for the diff.

### (a) The FLS-blind schema dump · `review/schema-reference/a-schema-dump-tooling.md`

All 17 entities through the **Tooling API**, which does not enforce FLS: 13 custom objects and
4 metadata types, with every picklist's full value set from
`CustomField.Metadata.valueSet.valueSetDefinition` including the `isActive` flag.

**THE DIFF IS CLEAN. 317 fields FLS-blind, 317 FLS-aware, and every one of the 17 per-entity
counts identical.** Nothing to grant. The only FLS gap this org had was the eight anchor fields
on `AAO_Shadow_Person__c`, closed this morning by adding their `fieldPermissions` to `AAO_Admin`
(job `0AfWD00000FuquX0AR`); design now reads 21 on that object and so does the Tooling API,
which is that grant verified from the other side.

**Stated so it is not over-read: the check is repeatable, not permanent.** A field deployed
through the Metadata API grants FLS to nobody, System Administrator included, so the next new
field is invisible to design the moment it lands and until its permission does.

**40 picklist fields, 163 values, ZERO inactive.** No value anywhere is a ghost.

### (b) The Apex inventory · `review/schema-reference/b-apex-inventory.md`

128 classes: 83 production, 45 test. 9 triggers. Every production class one line, taken from its
own opening description rather than paraphrased. Two maps: **class to call** (call 0, the two
comprehensive reads, call 2a deterministic and 2b model leg, call 3, join, projection, cards) and
**class to charter** (People, Problems, Politics, Process, the resolver, the scope resolver).

**THE FINDING: THERE ARE ZERO DECLARATIVE VALIDATION RULES IN THIS PROJECT.** `find force-app
-name '*.validationRule-meta.xml'` returns nothing. **All 44 guards are Apex `addError` across 8
trigger handlers — 17 on `AAO_Pair__c` alone, more than any other object.** That is exactly why
the org's laws are unreadable from the metadata tree and surface only when something breaks one,
which is how CODE learned two of them today. Both are quoted verbatim in the file.

Recorded honestly: **two entries exist for call 2** — `AAO_IdentifyCharter` (model over every
pair) and `AAO_Resolve` (deterministic). Both are in the tree; the deterministic one now runs
first and `identify` takes the remainder. **The twenty-eighth stamp's one-implementation rule is
not yet satisfied, and that is named debt rather than glossed.**

### (c) The current flow · `review/schema-reference/c-current-flow.md`

Fifteen stages, admission through projection, **each naming the object written**, plus the four
stages that deliberately write nothing (admission refusal, call 0's verdict, abstention, silence
at projection).

**Loop one and loop two are RETIRED and MARKED IN PLACE.** A retirement block now sits at the
head of `aao-model-and-flow.md` Part II §1 pointing here; the loops, the seventeen-stage write
path and both diagrams stand unedited beneath it. Nothing deleted.

### (d) The ALTF projection map · `review/schema-reference/d-altf-projection-map.md`

Field level, from `AAO_P8Codes` and `AAO_Project` rather than prose. Every dimension's target
`ALTF__` object and field API name with its watermark, and the value-to-value mapping: support
counter to band, eight political codes to three placements, five buyer-role codes with their
overridable ranks, occasions to coverage, four problem codes to card types. Plus the
eighteen `ALTF__` API names we read and never write, and the two that are read-only by ruling.

### THE THREE FINDINGS, ANSWERED

**1 · `AAO_Pair__c`, 371 rows and 29 fields, is undocumented because it is TWO PHYSICAL SHAPES IN
ONE TABLE.** A `Located` pair is call 1's proposal and is FORBIDDEN the person; an `Identified`
pair is call 2's disposition, points at its parent, and carries the person only when the
disposition is `Identified`. Measured today: **236 Located, 135 Identified; 134 dispositions
`Identified` and exactly 1 `Ambiguous`** — and that one is CODE's own from the wiring proof. So
**every refusal branch on this object is essentially unexercised on real data.**

**2 · `AAO_Shadow_Person__c` has 21 fields and has NEVER held a row.** Zero ever, not zero lately.
With the eighty-eighth stamp's zero-coverage disclosure beside it, the Wells Fargo read writes
this object's first row during a graded run. **There is no known-good state to regress from**, so
a divergence there is a finding about a never-walked path rather than a regression.

**3 · `AAO_Claim_Basis__c` at zero against 100 claims: THE CHAIN IS NOT A LINK SHORT, THE LINK
MOVED.** Measured: **all 100 claims are `Basis = Transcript`, all 100 carry spans, all 100 carry
a Source.** A transcript-basis claim records its basis on itself, and the receipt walks end to
end. The junction exists for `Basis = State` — it cites pre-existing org rows and tombstones them
if deleted — and **zero of 100 claims are State or Both.** Decisively: the §P8 pipeline
references `AAO_Claim_Basis__c` **zero times across all seven** of `AAO_Pass`, `AAO_Resolve`,
`AAO_PairCommit`, `AAO_Commit`, `AAO_Accumulate`, `AAO_Project`, `AAO_Cards`. Its writers are
gate-1 and EBV era plus a UI controller.

**The latent gap, named rather than left to be rediscovered:** the first `State`-basis claim on
the §P8 path would have nowhere to record what it cited or whether that row still exists.
Nothing is broken today, and "nothing is broken today" is the sentence that preceded the
anchor-field day.

---

## Session 111 · 15 August · WELLS FARGO SESSION 3 · THE MEASUREMENT RUN · one run, no rehearsal, no tuning · 78 located, 78 disposed, HELD · the shadow object wrote its first row ever · the two-read merge fired 24 times after measuring zero

Authorising bytes, ninety-fourth stamp item 7: *"Run Wells Fargo session 3 alone."*

`SRC-00000045`, occurred 2026-08-05T18:00:00Z, run key `wf-s3`, org `00DWD00000DV7iT2AT` from
`/Users/thefinalmachine/Downloads/claude` on `main`. **Sequenced by
`AAO_Evidence_Occurred__c`, never by name** — 45 is the earliest call despite the highest number.
The other two were not run. Prior state verified clean: 0 claims, 0 pairs, 0 flags, 0 map rows,
0 shadows.

Full report and rows: `review/wf-s3/`.

### THE THREE ANSWERS DESIGN COULD NOT RECOVER AFTERWARDS

**1 · Terminal.** **Zero AMBIGUOUS. The deterministic leg raised no flag at all.** It left a
two-ref remainder, both "Priya Natarajan", which the model leg disposed `Held` as
`named-off-artifact` with candidate NONE. **So on this transcript the Identification flag fires
only after a callout.** S4-09's liveness here depends on the model leg running, not on the
deterministic stage. A third Priya pair merged rather than holding, so three located pairs about
one person produced one flag — the bound key working on real data.

**2 · Shadow.** **`SP-00000000`, the first row this object has ever held.** Key
`001WD00000uYd9xYAC|mention:priya natarajan` — the third branch, account plus `mention:` plus
normalised designator, exactly as the eighty-seventh stamp ruled. Provenance `Utterance`,
anchors 2, offsets 21061-21198, reason `Unresolvable`. **The provenance boundary held**: identity
columns empty, nothing minted from verbatim.

**3 · Refusal branches.** **Two fired, both first walks.** `Merged` 24 and `Held` 2, against
`Identified` 52. **`Merged` is the larger result:** the eighty-first stamp measured 0 of 67
corroborated and diagnosed `AAO_Resolve` as having zero callers. **It is live — 24 of 78 merged**,
each carrying its reason. The twenty-seventh stamp's byte-intersection merge on real speech at
last.

### Ledger

78 located, 78 disposed, one for one for one, **HELD**. 52 verified: 31 upheld, 21 refused.
31 claims, 26 answers, 5 criteria, 1 shadow. Map 6 rows, cards 10 (Goal 3, Initiative 3,
Obstacle 3, Pressure 1), 9 owner links.

### Timings, from the receipt rather than recomputed

`RCPT-00000004`, 7 stages, 174,172 ms, cache WARM, 0 splits. **Worst single callout 55,162 ms
(call 3, 4 batches) against the 120,000 ms ceiling — 46%.** Reads 47,592 COLD and 38,847 WARM;
call 0 5,885; deterministic leg **281 ms**. Driven serially end to end at roughly 192 s, which is
NOT comparable to the ratified concurrent ~59 s per the seventy-fourth stamp's caution.

### THREE FINDINGS, none fixed except the one blocking a standing obligation

**1 · THE JOIN RAN DML AT 133 OF 150 — 89% of the ceiling**, at only 31 claims, with 196 DML
rows. The sixteenth stamp's join wall, closer than ever measured. The caller-side split exists
and was not needed here, but **the margin is 17 statements** and s4/s5 stack onto existing state.
Reported, not fixed; no tuning during the read.

**2 · THE RECEIPT DOES NOT JOURNAL THE MODEL LEG.** It records 4 callouts; the pass made 5.
`call2_requests` at 4,577 ms is absent from the stages array — the model leg has no receipt leg
wired, the same gap the card writer had before the seventieth stamp closed it.

**3 · LAWFUL FIX · the row export refused every Problems pair and blamed the data.**
`AAO_RunExport.pairs()` threw *"Contract AAO_PB_GOAL … declares no AAO_Family__c. THE FIX IS
DATA, NOT CODE."* **The message is wrong about its own cause.** `AAO_PB_GOAL` does declare
`AAO_Family__c = 'Problems'`; the export called `familyOf(String)`, the prefix ladder, instead of
the `familyOf(AAO_Evidence_Contract__c)` overload the forty-third stamp added for this, and never
selected the field. Fixed by selecting it and calling the record overload. **Read-only reporting
path: every row in the report was written before the fix and is unchanged by it.**

**The general lesson, second instance today: an error message that names its own cause can be
wrong**, and this one would have sent the next reader to edit correct data.

### retryNotes

1. **Call 0 quote-law retry**, fourth instance of the known cold-flake: attempt 1 answered yes
   with no quote and was refused, attempt 2 succeeded. Both on the record.
2. **Call 3 invocation 1 threw and was NOT diagnosed.** The second completed all 4 batches and
   verified all 52. **The error text was not captured and is not invented here.** Counts
   reconcile exactly (31 + 21 = 52), so nothing was lost.

**Nothing in this run is graded by CODE, no number was tuned toward any expectation, and the run
was not repeated.**

---

## Session 112 · 15 August · THE STATIC DML COUNT · the answer to the question asked is ZERO, and the ceiling is breached for a different reason · s4 DOES NOT RUN · a DML split trigger proposed, and a cheaper fix that should land first

The ninety-fifth stamp's item 6, a read of the code rather than a run. Full working:
`review/wf-s3/DML-CEILING.md`.

### THE QUESTION ASKED · zero, and the premise is wrong in the safe direction

**Not one DML statement on the pass path is conditional on prior state existing.** There is
exactly one prior-state branch in the whole join, `AAO_Commit.persist`: `update answer` when the
answer has an Id, `Database.insert` when it does not. **One statement either way — the update leg
REPLACES the insert rather than adding to it.** Every other statement fires identically whether
or not s3 ran first. Stacking adds no update legs and there is no patch-leg growth vector.

The only prior-state branch that could add one is the `DUPLICATE_VALUE` collision (`update
colliding`, +1), and prior state makes that branch LESS likely, not more, because an answer
carrying an Id never reaches the insert.

### THE SECOND PREMISE IS ALSO WRONG, AND THIS ONE IS NOT SAFE · there is DML inside a loop

`AAO_PairCommit.run` line 324 calls `AAO_Commit.commitCandidate` once per candidate, and that
method performs **four DML statements per call**: persist (1), `insert claim`, `update answer` for
the last-claim pointer, and `update cand` in `stampCandidate`. Plus `AAO_Criteria.mint` line 124
does a **single-row `Database.upsert` inside the same loop**, once per criteria pair.

`AAO_PairCommit`'s own five statements are genuinely bulk and `isEmpty`-guarded, at most one each.

### THE MODEL, EXACT AGAINST THE MEASUREMENT

```
DML = 4·C + M + B      C = candidates, M = criteria minted, B = bulk statements fired
```

**s3: C=31, M=5, B=4 → 4(31) + 5 + 4 = 133. Measured 133.** Exact, not approximate.

**Ceiling: 4C + M + B ≤ 150, worst constants M=5 B=5 → C ≤ 35.** 35 candidates = 149 and fits;
36 = 153 and does not. **s3 used 31. The headroom is four candidates.**

### THE VERDICT · s4 DOES NOT RUN

**Nothing in the code caps C.** The join commits every eligible candidate for its run key in one
transaction: no batch, no split, no guard. The worst case is unbounded and crosses 150 at 36.

**The expected case is stated too rather than hidden:** the join is keyed by run key, so s4 commits
s4's candidates only, not the cumulative set, and s4's transcript is 25,779 bytes against s3's
25,598 — so s4 will probably land near 133 again. **Probably is not a ceiling.** Four candidates
of margin, on the measurement instrument, on a run that cannot be rehearsed, where a breach rolls
the entire join back, is not a margin. Stopped per the stamp's own instruction.

### PROPOSED · the DML split trigger, deliberately the same shape as the 90-second wall

> Any stage whose DML statement count crosses **112 (75% of 150)** inside one transaction
> completes its remaining work in a continuation call in the next transaction: **never redo,
> never retry-by-growing.** Split units: the join by **candidate batch**, projection by
> **map-row batch**, cards by **card batch**. **Every split event journals** —
> `AAO_Run_Receipt__c.AAO_Split_Events__c` exists and read **0** this run.

75% is taken from the existing trigger rather than invented. At 112 the join has committed about
27 candidates and can still finish any single candidate's four-statement group in the remaining
38, which is what makes the threshold safe rather than merely early.

### AND A CHEAPER FIX THAT SHOULD LAND FIRST · bulkify three of the four

`insert claim`, the last-claim `update answer`, `update cand`, and the criterion upsert are all
collectable with no semantic change. **`persist` must stay per-candidate and that is deliberate:**
it reads standing state, branches on it, and handles `DUPLICATE_VALUE` per row, and the
forty-eighth stamp's read-then-branch semantics have to stay byte-identical — bulkifying it would
be the clobber defect returning.

**After bulkification: C + ~9 instead of 4C + 9. At 31 candidates that is 40 statements instead
of 133**, and the ceiling moves from 35 candidates to roughly 140. This is the same move the
forty-eighth stamp made for the join's SOQL at 101, applied to the other governor.

**Recommended order: bulkify, then add the split trigger as the backstop.** Neither is built; both
are proposals, per the receipt rule.

**s3's rows are untouched, nothing was re-run, and the instrument still carries exactly one graded
run.**

---

## Session 113 · 15 August · THE JOIN IS BULKIFIED, 133 DML BECOMES 35 · s4 STACKED ON s3 · and the stack found the thing it exists to find: THE COUNTERS CANNOT ACCUMULATE ACROSS CALLS

The ninety-sixth stamp, in its order: bulkify, prove byte-identical, re-measure, run s4.
Reports: `review/wf-s4/README.md`, rows in `review/wf-s4/rows/`.

### The bulkification · commit `bd4987a`

Three of `commitCandidate`'s four per-candidate statements plus the criterion upsert move out of
the loop, via a deferred buffer in `AAO_Commit` and the same shape in `AAO_Criteria`. **One
implementation, two invocation moments** per the twenty-eighth stamp: a caller that opens no batch
gets the per-row behaviour byte for byte. **`persist` stays per-candidate** as scoped.

**THE BAR CAUGHT A REAL DIVERGENCE.** The first batch boundary put the criteria flush after
`mintCriteria`, but the typing pass INSIDE that method updates the rows the naming loop minted and
needs their Ids. `AAO_CriteriaTest` failed `MISSING_ARGUMENT`. Boundary moved, suite restored.

**BYTE-IDENTICAL, no version moves.** Suite 516, 515 AAO passing. The frozen-corpus replay diffs
sit in `AAO_Spans__c` and `AAO_Element_Completeness__c`, and **the diff contains zero references to
either field** — a pre-existing replay-versus-live serialization property, not a commit property.
Failure semantics identical: the join is one transaction, so a throw rolls back either way, and
both upserts use `allOrNone = true`. **Honest limit: the fully decisive test is not runnable**,
because claims are insert-only and the join cannot re-run on the same pairs; s4 is the first live
exercise and its ledger reconciles.

### The re-measurement, confirmed against the org

**Join DML 133 → 35 of 150. SOQL 83 → 69. Join wall 4,186 → 2,148 ms.** Predicted `C + 9`;
25 candidates gave 34 predicted against 35 measured, the extra being a bulk statement that fired
on s4 and not s3. **Ceiling moves from 35 candidates to roughly 140.**

### THE FINDING · counters cannot accumulate across calls, and it is structural

**Rohan and Alison did NOT increment. Neither did Katherine. Tom got a second establishment and it
created a SECOND ANSWER ROW at −1 rather than moving him to −2.**

```
A1|Participant|a1ZWD000002bZnI2AU|<contract>  counter -1   (s3)
A1|Participant|a1ZWD000002bZs82AE|<contract>  counter -1   (s4)
```

**The answer key is scoped to `AAO_Participant__c`, and a Participant is one row per Source per
person.** Measured: three Tom rows, one per call, all pointing at the same Contact. **So a person
on two calls has two answer keys and cross-call accumulation cannot happen for any dimension keyed
this way.**

**It is a ruled design and `AAO_AnswerKey`'s own header says why** — the key moved to Participant
at addendum 18 so the replay invariant holds for a person with no Contact. **The consequence on a
stacked read was never priced.**

**What it costs:** the ninety-fifth stamp left open whether the counter's arithmetic earns its
place, to be settled by whether three calls of accumulation produce bands the ontology would not
name alone. **That experiment cannot run as designed, because the counter cannot accumulate across
calls at all.** The maps-firm-up thesis is carried today by **Coverage**, which derives from
distinct occasion counts and did move, and not by the counters. **Not fixed, not tuned; design's
to rule.**

### The other two answers

**Priya's flag stayed open and was never reopened — correct. Her shadow was NOT reused.** s3 said
"Priya Natarajan", s4 said "Priya"; different normalised designators, so different shadow and
bound keys, so **a second shadow row (`SP-00000002`) and a second standing flag for one human.**
This is the eighty-seventh stamp's key-collapse reading behaving exactly as ruled — different
forms never collapse at the key — and **this run is that ruling's cost arriving on real data.**
Within a form the key held: three s3 pairs gave one flag, two s4 pairs gave one more.

**No claim carried `State` or `Both`.** 56 claims, all `Transcript`; `AAO_Claim_Basis__c` still 0
org-wide. The latent gap stays latent.

### The ledger and the map

s4: 74 located, 74 identified, one for one for one. Dispositions Identified 48, **Merged 20,
Held 6**. Verified 48: upheld 25, refused 23. Deal after the stack: 56 claims, 47 answers,
8 criteria. **Projection 0 created, 3 populated, 0 blocked, 14 unchanged** — three dimensions
filled that were blank after s3, nothing overwritten. **People and Problems carried forward**, and
the card writer reinforced one card rather than duplicating it.

**Worst callout 72,230 ms (call 3) against the 120,000 ceiling — 60%**, up from s3's 46% and
clear. Roughly 232 s serially.

**retryNotes: none.** Call 0 did not flake, call 3 completed in one invocation, nothing was re-run.

---

## Session 114 · 15 August · WELLS FARGO s5 · THE STACK COMPLETES · Priya became a real person and NEITHER FLAG CLEARED · the join model predicts a third measurement exactly · two defects found

The ninety-seventh stamp's item 5: s5 on the current code, no answer-key fix first. Report and
rows: `review/wf-s5/`.

### 1 · PRIYA · reported as it happened

She is on the s5 roster **with no email and no contactId**. **The mention resolved** — one pair,
`r2q3`, designator `"Priya"`, disposition `Identified`, person Priya Natarajan. **Zero remainder,
zero Held, no model leg fired.** A Contact was created for her at projection
(`003WD00001RRgsrYAD`) and she carries a map row, `Approver` / `Brief contact`.

**AND NEITHER FLAG CLEARED. All three still Standing, both shadows unpromoted, `flagsCleared = 0`.**

**Two separable causes, both real.** First, a SEQUENCING FAULT: `reconcile` clears only on a
Contact binding and runs at **call 2a**, while the Contact is created by the create leg at
**projection**, six stages later. It asked the question while the answer was still no, and the
answer arrived minutes afterwards in the same run. It would clear on a subsequent run and there is
none. Second, and independent of ordering: **only ONE of her two flags could ever clear**, because
the bound keys are `…|priya natarajan` and `…|priya` and the s5 pair carries `"Priya"`. **The
other stays open forever.** That is the eighty-seventh stamp's key-collapse ruling at its final
cost — one human, two shadows, two flags, and the reconciliation path reaching at most one.

**S5-01 did not happen.** She reconciled as a speaker; her held identities did not.

### 2 · THE RETIREMENT DELTA FIRED, and Jared stayed put

Held by run: **s3 = 2, s4 = 6, s5 = 0.** Eight held pairs across s3 and s4 — DELTA-1's predicted
movement arriving. **s5's zero is correct rather than a failure**: Priya is rostered and Bettina
is not mentioned. **Jared's single pair, `wf-s4 r1q35`, stayed `Identified`** — the MUST-NOT-MOVE
half held.

### 3 · CARDS AND COVERAGE

**One card was reinforced rather than duplicated — on s4.** Created/reinforced/unchanged by run:
s3 10/0/0, s4 6/1/10, s5 12/0/16. **28 cards, 0 duplicates retired.** The 16 unchanged on s5 is
dedup holding across three calls.

**Coverage did NOT move again and CANNOT.** Everyone on two or more calls hit `Multiple contacts`
at s4, which is the derivable ceiling because `In-depth` is deliberately underivable. **Coverage
saturates after two calls**, which matters: it is the one dimension carrying the maps-firm-up
thesis now that the counters cannot accumulate, and it has a two-step range.

### 4 · THE JOIN'S DML · the model predicts a third measurement exactly

**39 of 150 measured, 39 predicted** (30 candidates + 9). Across the three runs: **133 → 35 → 39**,
against 31 / 25 / 30 candidates. **The model has now predicted three measurements exactly, once
before the change and twice after.**

**SOQL is the governor to watch next: 81 of 100 on s5**, against DML's 39 of 150. It did not fall
with the DML and is now the closer ceiling.

### Ledger and timings

s5: 83 located, 83 identified, HELD. Verified 64: upheld 30, refused 34. Deal after three calls:
**86 claims, 70 answers, 28 cards, 7 map rows, claim basis {Transcript = 86}** — still no `State`,
still no `Both`.

`RCPT-00000006`: 8 stages, 195,888 ms, 5 callouts, WARM. **Worst callout 87,593 ms against the
120,000 ceiling — 73%, up from 46% and 60%. Three runs, monotonically rising.**

### TWO DEFECTS, NEITHER FIXED

**1 · The card-face call 400s on a duplicate ref.** `output_config.format.schema … ['r1q1','r1q2',
…,'r1q2',…] has non-unique elements`, request `req_011Ce5Ai58ejU8LLzuK12t1q`. The writer builds an
enum containing `r1q2` twice. **The deterministic fallback wrote the faces**, so no card was lost,
but s5's twelve carry raw verbatim rather than inferred summaries and the fifty-fourth stamp's
content spec is not met on them.

**2 · Call 3 needed five invocations.** Four produced no output; the fifth did all five batches.
**Undiagnosed and not invented.** Counts reconcile (30 + 34 = 64). Second occurrence — s3 needed
two, s5 needed five.

### retryNotes

1. **Call 0 invocation 1 failed both attempts and stopped**; invocation 2 succeeded, DUAL. Error
   captured this time: *"Call 0 returned no `opportunity_content_because`."* The thirty-fifth
   stamp's second named flake face, fifth instance.
2. Call 3's five invocations, above.

**Nothing graded by CODE, no number tuned, s3 and s4 untouched. Stopping: the answer-key fix
scopes next with all three runs in hand.**

---

## Session 115 · 15 August · PROMOTION, THE CARD-FACE ROOT CAUSE, THE A2 PERSON-DURABLE KEY, AND THE CLEAN RE-RUN · the key fix worked and was NOT sufficient · three predictions failed and all three trace to one unexplained defect

The ninety-ninth stamp's items 4(a) through (d). Predictions committed at `b2a2514` **before the
purge**. Full report: `review/wf-clean/`.

### What was built

**(a) `AAO_Promotion.runAfterProjection`** — shadows whose designator resolves to a Contact bound
on this deal gain `AAO_Promoted_Contact__c`; every Identification flag of that PERSON clears
whatever form raised it. **Clear by person, never by key**, which is the only way both of Priya's
flags could close while the eighty-seventh stamp's key-collapse ruling stays intact. Ambiguity
promotes nothing. Plus the sequencing half: `reconcile` runs again after projection. Gives
`AAO_Promoted_Contact__c` its first writer.

**(b) THE CARD-FACE ROOT CAUSE.** The face was keyed by `AAO_Pair_Ref__c`, unique **per run**,
while the writer reads **every run on the deal** — so s3's, s4's and s5's `r1q2` all arrived.
`required` is a List so they duplicated and 400'd; `props` is a Map so **a colliding ref silently
overwrote the earlier pair's words**. The 400 was the lucky half: a refused call is visible, a
wrong face is not. Now keyed by pair Id.

**(c) `AAO_AnswerKey` A1 → A2.** A Participant answer resolves to its Contact where one exists.
And the tension it surfaced, caught by `AAO_ProjectTest`: the create leg lands a Contact AFTER an
answer exists, so the key moves and the frozen guard refused. **Permitted exactly one transition**
— participant to that participant's own Contact, verified by reading the participant from the org.
Every other key change still throws.

### (d) THE CLEAN RE-RUN · what it proved and what it did not

**THE KEY FIX WORKED.** Every answer is `A2|Participant|<CONTACT ID>|…`. **Answers fell 70 → 34.
Tom is ONE row, not two.**

**AND THE COUNTER STILL DID NOT ACCUMULATE.** Tom carries **three** sentiment claims on that one
row and reads **−1**: one `Established`, two `Reinforced`. `AAO_Accumulate.movesTheAnswer` returns
false for `Reinforced`, so confirming evidence moves no counter — the seventy-first stamp's ruled
behaviour, working as written.

**So there is a SECOND, INDEPENDENT mechanism blocking accumulation that the key fix could never
reach.** The ninety-fifth stamp's open question is answered and the answer is negative: a person
who says a non-supportive thing on three calls scores −1. Recorded against the eightieth stamp's
own reasoning, which predicted the opposite — *"claims from different calls never intersect and
always count"* — they did not count, because the already-standing-verdict test decided it, not the
intersection test, and the two were never reconciled.

**THE SECOND FINDING, and three failed predictions trace to it.** Priya produced **16 pairs
identified to her, 9 upheld, and ZERO claims.** No claims → no projection → no Contact → nothing
for promotion to promote → her flags stayed Standing. **Promotion was never reached, so it is
untested, and I am not guessing the cause at the end of a long session.** Measured and named as
the first thing to diagnose next.

**Predictions: 4 met, 2 half, 4 failed.** Answers fell further than predicted (34 against 45–55).
Bettina's flag correctly stayed standing — promotion is not too loose. **Three of the four
failures are the one Priya defect.**

**The card-face fix is confirmed and revealed the next constraint.** The duplicate-ref 400 is gone
and s3 and s4 inferred their faces cleanly; s5 now fails with **`The compiled grammar is too
large`** — the thirty-fourth stamp's keyed-grammar ceiling, previously invisible behind the
duplicate error. The card-face call is the one keyed call with no shard cap, and `keyedShardCount`
already exists for exactly this. **Not built: this run was the verification.**

### A PROTOCOL GAP

**`AAO_Purge` does not cover cards, shadows or flags** — 28 cards, 3 shadows and 3 flags survived a
full purge. Cards were deleted by hand card-first per the fifty-second and seventy-third stamps.
Shadows and flags were deliberately left, and that was better: they are the exact rows that failed
before, so promotion was tested against real specimens. Reported, not changed.

### The run

Worst callout 82,566 ms, **69% of the ceiling**. Join DML **39 and 31 of 150**, SOQL 78 and 62.
Deal totals: 51 claims, 34 answers, 29 cards, 6 map rows. Coverage held; cards deduped across
calls (6 unchanged at s4, 16 at s5). **Call 0 did not flake on any of the three — the first clean
sweep in six sessions.** Nothing re-run, nothing tuned.
