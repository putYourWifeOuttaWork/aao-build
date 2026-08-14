# Seeding a new device's folder from the project · 14 August 2026

**Read this in the session that is connected to the NEW device. Everything below is pulled with `project_read` from the Altify Agency project and written to disk locally. The project is canonical until the local channel is re-established (eighty-second stamp).**

## Which folder, decided before anything is written

**One folder holds the ledger and the law documents. Two folders holding either is the split-ledger disease, which cost this project a full week in early August and was closed at the thirty-seventh stamp.** `Downloads/claude` already has CODE seeding into it, so unless Matthew says otherwise `Downloads/claude` is the canonical working surface and `claude_aos` is for his own uploads and scratch. If he prefers `claude_aos`, everything below moves there and `Downloads/claude` is emptied, not mirrored.

## The lane rule, restated because the new device is where it gets broken

Design writes `CODE-INBOX.md` and the law and satellite documents. CODE writes `review/` and its repo, and is the only agent that deploys to the org. The eighty-second stamp's item 4(3) said "seed the new local folder from the project's documents" without naming who; **design seeds the documents, CODE seeds its repo.** If both do it, one overwrites the other from a stale read, which is the exact hazard the ledger names.

## Pull order, by exact path, `claude/` prefix in the project

**First, the state (nothing else is safe to act on without these):**

1. `claude/CODE-INBOX.md` — the ledger, current through the eighty-second stamp. This is the single most important file in the project.
2. `claude/aao-board.md` — Board v2.9. Note its own stamp is behind the ledger; the ledger wins on state, the Board on the locked law list.
3. `claude/aao-open-questions.md` — the register, through item 36.

**Second, the law documents (large; pull straight to disk, do not read inline):**

4. `claude/aao-charters.md` — v3.5
5. `claude/aao-architecture.md` — v4.12
6. `claude/aao-model-and-flow.md` — v1.5
7. `claude/aao-glossary.md` — v2.7

**Third, the working sheets:**

8. `claude/aao-verification-sheet.md` · 9. `claude/aao-map-read-sheet-v0_3.md` · 10. `claude/aao-machine-read-sheet-v1_0.md` · 11. `claude/aao-adjudication-sheet.md` (carries §11, the a23 grading) · 12. `claude/aao-primer.md`

**Fourth, the live satellites:**

13. `claude/aao-politics-lor-draft-v1_0.md` (awaiting Matthew's yes) · 14. `claude/aao-config-inventory-v0_2.md` · 15. `claude/aao-problems-politics-draft-v1_0.md` · 16. `claude/aao-inspector-v2-spec-draft.md` · 17. `claude/aao-span-set-caps-proposal-v1_0.md` · 18. `claude/aao-unseen-corpus-record-v1_0.md` · 19. `claude/aao-a23-refusal-diagnosis-v1_0.md` · 20. `claude/README-CHANNEL.md` · 21. `claude/aao-device-loss-reconciliation-2026-08-13.md` · 22. `claude/aao-state-of-the-build-primer-2026-08-13.md` · 23. `claude/aao-seed-execution-2026-08-13-LOR.md` · 24. `claude/aao-probe-t0-verification-2026-08-11.md` · 25. `claude/aao-review-em0814-reinforcement-README.md`

**Fifth, the fixtures and graded records (needed before any run):**

26. `claude/aao-fixture-projectfarma-2026-07-30-raw.txt` · 27. `claude/aao-fixture-wf-opentext-2026-08-05-raw.vtt` · 28. `claude/aao-fixture-handle-2023-11-22-raw.txt` · 29. `claude/aao-fixture-emerson-2026-06-17-nf1.txt` · 30. `claude/thepitch-ep126-page-capture.txt` · 31. `claude/aao-grading-record-tg1-vs-pass1-v1_0.md` · 32. `claude/aao-grading-tg1-vs-pass1-graded.csv` · 33. `claude/aao-sweep-s1-graded.csv`

**Everything else in the project is history and can be pulled on demand:** the corrections archive, gate 1 records and harness, the projection surfaces, the code build brief, demo runsheet, competitive rebuttals, proof register, plan-to-QBR, flags-and-guidance, the research documents, the state board HTML, the earlier primers and config inventory v0.1, and `applicable_set.json`.

## What is NOT in the project and cannot be

CODE's repository: source tree, git history, BUILD_JOURNAL, the freeze list file, the regression set, the correction scripts, and the historic `review/` exports. **The build repo had no remote** (verified 13 August by cloning the only GitHub repo, `altify_moat_simple`, which is the moat website: 73 HTML commits ending 27 July, zero Apex). The source is recovered by `sf project retrieve` from the sandbox: **126 AAO classes, all LastModified 2026-08-13T22:41Z, commit `6fde84a`**, verified by query. That count is the re-baseline check.

## After seeding

Design cuts a stamp re-establishing the local-first channel and naming the canonical folder. CODE re-baselines its repo, creates a PRIVATE remote before any build, and restarts BUILD_JOURNAL with a loss marker on line one. Then the eighty-first stamp's queue resumes: the per-leg resolution diff report, the wiring proposal, then the LOR contracts on Matthew's plain-word yes.
