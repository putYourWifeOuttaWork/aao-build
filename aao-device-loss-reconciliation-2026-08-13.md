# AAO · Device-loss reconciliation · 13 August 2026

**Written the night the primary development device was lost, after verifying what survives rather than assuming it. The eighty-second stamp in `CODE-INBOX.md` is the ledger's record of this event; this page is the human runbook. The claude.ai project is the canonical document store until a new local folder is established.**

## The verdict, up front

Every document, every ruling, every graded result, and every fixture survives, current through the eighty-first stamp, because the project mirror was synced minutes before the loss. The build's deployed truth at commit `6fde84a` lives in the sandbox org, which no laptop carries, and both org connections answer without the lost device, verified by query tonight. The one thing whose fate is not yet known is CODE's git repository, and one question sizes it: **does the repo have a remote?**

## Held and verified, by category

**The ledger and registers:** `CODE-INBOX.md` through the eighty-second stamp; `aao-open-questions.md` through item 36; the config inventory v0.2.

**The five law documents:** Board v2.9, Glossary, Architecture, Model and Flow, Charters. The project copies were already the authoritative ones; the lost disk carried only the stale 8 August sync, so the loss of the disk copies loses nothing.

**The graded record:** the adjudication sheet with §11, the tg1-versus-Pass-1 grading record and graded CSV, the sweep s1 graded CSV, the a23 refusal diagnosis.

**The fixtures, with hashes recorded in the corpus record and stamps:** Project Farma raw, WF-OpenText VTT, Handle, Emerson 17 June NF1, the Pitch page capture.

**The working sheets and satellites:** verification sheet, map-read sheet, machine-read sheet, corpus record, span-set caps, LOR draft v1.0, Problems/Politics draft, Inspector v2 spec, probe-t0 verification, both seed-execution docs, both primers, README-CHANNEL, demo runsheet, competitive rebuttals, proof register, plan-to-QBR, flags-and-guidance, projection surfaces, code build brief, sandbox build sheet, gate 1 records and harness, corrections archive, research docs. The em0814-reinforcement run README is preserved into the project tonight.

**The orgs:** sandbox `aossb2` (`00DWD00000DV7iT2AT`) with every deployed class, test, object, custom metadata record, map row, card, and receipt; production, read-only as always. Resident runs' rows remain queryable and re-exportable from the org itself.

## At risk, precisely

**CODE's repository** (source tree, git history, BUILD_JOURNAL, the freeze list file, regression set, correction scripts). **ANSWERED, same night, measured: THE BUILD REPO HAD NO REMOTE.** The only GitHub repository, `altify_moat_simple`, is the moat-website satellite: 73 commits of HTML ending 27 July, zero build commits, zero Apex, verified by cloning it and searching its history for ten known build hashes. What this actually loses, assuming no Time Machine or other Mac backup surfaces: git history (whose narrative the ledger carries stamp by stamp), BUILD_JOURNAL as an artifact (its load-bearing numbers are quoted throughout the ledger), the raw export CSVs of already-purged historic runs, and the correction scripts (regenerable). What it does not lose: **the build itself. The sandbox carries all 126 AAO classes, every one LastModified 2026-08-13T22:41Z, tonight's `6fde84a` deployment, verified by query**, plus the custom objects, the ten custom metadata records, the Inspector, and the NF1 artifact bytes inside the org's own Source rows. The re-baseline check is a live query, never a hand-copied list: retrieve, confirm 126 classes, diff clean. The moat site itself is safe on GitHub.

**Historic run exports** under `review/` (pf0808 and pf0811 era CSVs, calibration, the comparison satellite, em0814's row files). Archives whose conclusions are folded into the ledger; the true loss, if no remote, is the raw audit files of already-purged runs.

**corp-notes/**: minor, unmirrored.

No ruling, no law, and no graded result lived only on the lost device.

## The new-device runbook

1. Download the recovery zip from this conversation, or pull the documents from the project, into a new `claude/` working folder. Connect it to a session; design re-establishes the local-first channel with a stamp at that moment.
2. The remote question is answered: none existed. So: `sf project retrieve` from the sandbox, fresh repository, first commit labeled post-loss re-baseline, BUILD_JOURNAL restarted with a loss marker, and a PRIVATE remote created under the GitHub account before any build; the public moat repo is never the home for product source. Verification is the live query: 126 AAO classes, all stamped 2026-08-13T22:41Z. One check worth ten seconds first: if the lost Mac had Time Machine or any backup, the whole repo with history comes back and the retrieve becomes a cross-check instead of a rebuild.
3. Authenticate CODE's tooling to the sandbox only. Production needs no auth from a build machine, ever.
4. Run the suite; 500 of 501 with the standing non-AAO failure is the expected shape.
5. Resume the eighty-first stamp's queue exactly where it stands: the per-leg diff report, the resolution-wiring proposal, then LOR contracts on Matthew's yes.

## Standing to Matthew

The repo-remote answer. The plain-word yes on the LOR draft. The twin's disposition (now waits for a device that can reach the sandbox UI, or rule it in conversation and CODE executes). The cross-type card grade, from the board once he can view it.
