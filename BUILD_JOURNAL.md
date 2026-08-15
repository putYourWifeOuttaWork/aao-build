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
