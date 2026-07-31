# seed

The mini-rubric, the dummy transcripts and the expected outcomes.

## Where the bytes actually live

**One file:** `force-app/main/default/staticresources/AAO_Seed.json`.

The build brief's layout puts transcripts under `seed/transcripts/`. They are not
duplicated here, and that is deliberate. Apex has to read the exact bytes a span was
verified against, which means the transcripts must deploy as a static resource. A second
copy under `seed/` would be two accounts of one fact with no mechanism to say which had
drifted — the pattern this project rules against everywhere else, including in the
document that specifies this layout.

So `seed/` holds what is *about* the fixtures, and the fixtures themselves live once, in
the place they have to live to be readable from Apex.

- `rubric/README.md` — the six propositions and what each one is in the set to exercise
- `expected/README.md` — the ground truth, and the exit test that asserts it
- `transcripts/README.md` — the transcripts, and why they are frozen

## Frozen

The transcripts are frozen once written. A transcript edited after a span was verified
against it breaks the citation chain, which is the exact failure `AAO_Source__c`
immutability exists to prevent. Editing `AAO_Seed.json` invalidates every offset already
resolved from it.

Spans in the fixture are authored as **quotes, never as offsets**. `AAO_Seed` resolves
them against the composed normalized text and refuses if a quote is absent or ambiguous.
Hand-written offsets would be a second account of where the words are, and the first thing
to rot.

## Loading

Seeding runs from Apex, inside tests. There is no anonymous-Apex seeding path yet, because
nothing in this repo has been run against `altify--aossb2`. See `BUILD_JOURNAL.md`.
