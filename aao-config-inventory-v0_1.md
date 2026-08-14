# AAO · Configuration inventory · v0.1 · 13 August 2026

**Satellite. Written at Matthew's naming of the debt ("we haven't built ANY of the core config or custom metadata which we'll need to configure this product"). This is the inventory of every org-varying fact the product depends on: where it lives today, its ruled home, and its status. Statuses were compiled from the ledger, not from the repo or the org; CODE confirms each with one report line, no build. Where this page and the ledger disagree, the ledger is right.**

**The principle, from LAW #1 and the seventy-sixth stamp:** facts about an org are read from the org per run; facts an org may legitimately differ on ship as our seed, org-overridable, keyed to stored API values, never to labels; no org fact is ever hardcoded in logic. The seventy-seventh stamp built the first real instance and it is the pattern the rest follow.

## Built

**1 · Map value ranks and the label-to-value map** · `AAO_Map_Value__mdt`, ten rows (six buyer-role, four political), org-overridable, keyed to stored values, a test asserting no label string reaches logic. BUILT at the seventy-seventh stamp; verified in-org. Extends with LOR rows when the LOR draft is ruled buildable.

**2 · Model configuration** · Named Credential to the gateway; per-model knob feature detection (temperature and every other knob), the BYO-LLM law, generalized at the forty-third stamp. The Trust Layer remains the packaged endgame and is never blurred with today's direct calls.

**3 · Model routing per call** · call 3 on the small fast model, reads on the strong model, dispatch in code. Whether per-call model choice should be admin-visible configuration is undecided and recorded here, not assumed.

## Ruled, not built

**4 · Internal domain list** · today a static resource carrying `altify.com` and `opentext.com`; ruled home is org-overridable seed metadata (the twenty-sixth stamp's "one gap, three faces": this list, the title synonyms, and the internal flag discipline are one debt, paid once at packaging).

**5 · Title synonym list** · the resolver's title rung normalizes titles through a deterministic synonym list ruled as seed metadata, org-overridable (twenty-fourth stamp). The rung is built; the list's packaging home is not.

**6 · Admission-filter role and license map** · which organizer or participant roles admit a call, admin-ratified and cached (twenty-eighth stamp). The filter itself is ruled and unbuilt; it must exist before any automated funnel or pilot ingest.

**7 · Declared families per org** · licensing decides which rubrics exist, graceful refusal where absent (thirty-first stamp). Today the declared set is code plus `AAO_Family__c` routing on contracts; the per-org declaration surface is unbuilt.

**8 · Lane flag** · batch versus express is dispatcher config, one code path, one flag (thirty-second stamp). The express lane's admission-drop semantics are owed before any non-fixture artifact runs express.

**9 · Contact toggle** · machine-created Contacts ON by default, a picklist because a checkbox cannot express untouched; shadow persons permanent for toggle-off customers. Ruled; packaging surface unbuilt.

**10 · Hot/cold retention window** · the claims chain streams to Data 360 after roughly 30 days, Salesforce holds the hot window (seventeenth stamp, design direction, proposal owed). NOW A POC GATE by Matthew's 13 August direction; the proposal moves from queued to load-bearing, and every D360 capability fact verifies from the runtime before it is asserted.

## Constants that look like config, listed so nobody configures them by accident

The trailing-90-day coverage window (ruled law, not a knob today). The never-blank procedure, the ladder semantics, and call 3's blindness (law). The 90-second split trigger and the 120-second ceiling (platform facts with our margins). NF1 and the composed normalizer stamp (written law).

## Not yet inventoried anywhere, named so packaging finds them

Permission sets and FLS for every AAO object and the Inspector page; the run trigger's permissions when it exists; per-org purge authorization (sandbox-only today by practice); whether managed custom metadata records are subscriber-editable in the exact shape we need (a capability fact, verified from the runtime at packaging, unverified today); the admin surface that edits any of this (nothing exists; metadata plus admin-ratified rows is the v0 answer, a real admin UI is a product decision nobody has made).

## The packaging posture

Nothing here blocks the current phase; everything here blocks a pilot install. The inventory exists so the config plane is built once, deliberately, instead of accreting as patches. Next actions when Matthew calls for them: CODE confirms per-item status against repo and org; design proposes the metadata types and their seed rows in one satellite; the one-debt-three-faces items land together.
