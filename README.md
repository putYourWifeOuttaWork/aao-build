# aao-sandbox

Altify Always On — schema and deterministic plumbing, built in the `altify--aossb2`
sandbox. Metadata is the source; git is the artifact.

**Read in this order, first, every session:**

1. `docs/aao-board.md` — the orientation document: current state, the locked laws nobody
   relitigates, the open ledger with owners, next steps. It replaced the seed.
2. `BUILD_JOURNAL.md` — the `## Current state` block and the Handoff section under it: what
   has happened, what was verified, what is owed. **Every number comes from here, never from
   a document in `docs/`.**
3. `docs/MANIFEST.md` — what each file in `docs/` is authoritative for, and which files are
   satellites or legacy.
4. `docs/aao-charters.md` — the section for whatever is being built. §P7 holds the harness
   briefs.

**Filenames carry no version. The version lives on the stamp line inside each file; read the
stamp, never the filename.** One live copy per document. Where a document and this journal
disagree: numbers come from the journal, substance from the document's stamped body.

Production is read-only, unconditionally. The only target org is `altify--aossb2`, and the
`altify-pbo` org is never read.
