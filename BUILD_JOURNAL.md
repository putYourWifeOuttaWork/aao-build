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
