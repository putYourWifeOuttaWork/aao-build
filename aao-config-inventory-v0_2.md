# AAO · Configuration inventory · v0.2 · 13 August 2026

**Satellite. v0.1 was compiled from the ledger; v0.2 folds CODE's one-line-per-item confirmation against the repo and the org (eighty-first stamp, commit `6fde84a`). Three statuses sharpened, one item added. Where this page and the ledger disagree, the ledger is right.**

**The principle, from LAW #1 and the seventy-sixth stamp:** facts about an org are read from the org per run; facts an org may legitimately differ on ship as our seed, org-overridable, keyed to stored API values, never to labels; no org fact is ever hardcoded in logic. The seventy-seventh stamp built the first real instance and it is the pattern the rest follow.

## Built and confirmed

**1 · Map value ranks and the label-to-value map** · `AAO_Map_Value__mdt`, ten rows queried in-org (six buyer-role, Signature Approver 5 down to Unknown 0; four political, Inner Circle 3 down to Unknown 0), org-overridable, keyed to stored values, the no-label-in-logic test standing. Extends with LOR rows when the LOR draft is ruled buildable.

**2 · Model configuration** · `AAO_Anthropic.namedCredential` confirmed. **Sharpened: knob feature detection is TEMPERATURE-SPECIFIC, not general.** Only temperature carries the detect-and-retry shape; the forty-third stamp's "every knob" claim is corrected in place there. The BYO-LLM law stands; the generalization is owed, not built. The Trust Layer remains the packaged endgame, never blurred with today's direct calls.

**3 · Model routing per call** · `AAO_Model_Config__mdt` confirmed, 28 fields including verify, inventory and bind model choices plus verify temperature. Whether per-call model choice should be admin-visible remains undecided, recorded not assumed.

## Ruled, not built

**4 · Internal domain list** · **Sharpened: it lives in `AAO_Seed.json`** (`internalDomains: altify.example, altify.com, opentext.com`), read by `AAO_Seed`, one degree further from a config surface than "static resource" suggested. Ruled home unchanged: org-overridable seed metadata, the twenty-sixth stamp's one-debt-three-faces, paid once at packaging.

**5 · Title synonym list** · confirmed as `TITLE_CANON`, an Apex constant in `AAO_ResolveDesignator`, its own comment naming seed metadata as the owed home.

**6 · Admission-filter role and license map** · confirmed unbuilt; no admission filter exists. Ruled at the twenty-eighth stamp; must exist before any automated funnel or pilot ingest.

**7 · Declared families per org** · `AAO_Evidence_Contract__c.AAO_Family__c` exists and routes; no per-org declaration surface.

**8 · Lane flag** · **Sharpened: there is NO lane flag and no lane branch anywhere; "express lane" appears only in comments.** Batch versus express is today a property of how a driver sequences calls, not a switch. The thirty-second stamp's dispatcher-config ruling stands unbuilt whole.

**9 · Contact toggle** · confirmed: `AAO_Settings.CONTACT_CREATION` reads its setting; the picklist-not-checkbox shape stands; packaging surface unbuilt. The single-token creation bar (eightieth stamp) binds with the toggle ON, a bar and not a configuration.

**10 · Hot/cold retention window** · confirmed unbuilt, no Data 360 reference in any class. A POC gate by Matthew's 13 August direction; the proposal is load-bearing and every D360 capability fact verifies from the runtime before it is asserted.

## Constants that look like config, listed so nobody configures them by accident

The trailing-90-day coverage window (law). The never-blank procedure, the ladder semantics, and call 3's blindness (law). The 90-second split trigger and the 120-second ceiling (platform facts with our margins). NF1 and the composed normalizer stamp (written law). **Added at v0.2: the shadow-reason vocabulary** (`Ambiguous`, `Single_Token`), our own picklist, not org-varying.

## Not yet inventoried anywhere, named so packaging finds them

Permission sets and FLS for every AAO object and the Inspector page; the run trigger's permissions when it exists; per-org purge authorization (sandbox-only today by practice); whether managed custom metadata records are subscriber-editable in the exact shape we need (a capability fact, verified from the runtime at packaging, unverified today); the admin surface that edits any of this (nothing exists; metadata plus admin-ratified rows is the v0 answer, a real admin UI is a product decision nobody has made).

## The packaging posture

Nothing here blocks the current phase; everything here blocks a pilot install. The inventory exists so the config plane is built once, deliberately, instead of accreting as patches. Next actions when Matthew calls for them: design proposes the metadata types and their seed rows in one satellite; the one-debt-three-faces items land together; the feature-detection generalization rides the same fold.
