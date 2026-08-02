AOS Sandbox Build Sheet · v1.0 · 30 July 2026 · for ratification

Target: Developer sandbox altify--aossb1. Source of truth: Architecture v2.9 entity inventory, Object Model v1.9 merges, Glossary v1.9 definitions. This sheet adds nothing to the design — it translates the ruled fourteen into deployable metadata, and flags the three choices that are genuinely new. Prefix AOS_ on every API name (choice #1 below). Production untouched, as always.

The fourteen, in build order

Wave 1 — the write path's spine (build first; the accumulation test runs on these six):

#	Object	Key fields	Notes
1	AOS_Source__c	Normalized_Text (long), SHA256 (unique ext id), Source_Ref (e.g. VideoCall Id), Evidence_Occurred (datetime), Opportunity lookup, Version, Origin (ECI/ingest/note)	Immutable once written — enforce in trigger. Resident copy for span checks
2	AOS_Evidence_Contract__c	Proposition_Code, Question_Record_Id + Content_Hash (composite unique), Proposition_Text, Route (P/C/E), Speaker_Requirement, Required_Role, Solicit, Elements (JSON — the frozen element decomposition), Threshold, Decay_Class, Rubric_Version	Rule data, human-ratified, versioned. Elements field is new since coextension — the frozen lists live here
3	AOS_Candidate__c	Evidence_Contract lookup, Source lookup, Proposed_Verdict, Spans (JSON), State (proposed / span_verified / span_failed / blind_upheld / blind_partial / blind_rejected / reconciled / committed / abstained), Charter + Version, Run lookup	Rejected + abstained rows ARE the decision log (kept merge)
4	AOS_Claim__c	Typed subject lookups (Contact, Shadow_Person, Insight_Card, Qualifier, Decision_Criterion) + Subject_Type discriminator + Derived_Key (unique ext id, frozen composer — the ruled key), Verdict (TRUE/FALSE/UNVERIFIED), Quote (long), Citation_Locator, Established_By (human/machine + charter ver), Evidence_Occurred, Opportunity (006) + Altify_Opportunity (a0y)	The mirror. Null-and-flag on subject delete. DUPLICATE_VALUE is the merge path
5	AOS_Journal_Event__c	Four keys (deal, person, proposition, account), two clocks (occurred, recorded), Subject identity, Change, Citation, Actor	Append-only — no update/delete in trigger. Replaying it must rebuild the mirror exactly: that is the wave-1 exit test
6	AOS_Flag__c	Evidence_Contract lookup, Opportunity, Tier, Cause, Watermark, Last_Evidence_Considered, Raised/Cleared clocks, State	A deletion never clears a flag

Wave 2 — politics and evidence periphery:

#	Object	Key fields	Notes
7	AOS_Link__c	From_Contact, To_Contact / To_Insight (typed), Link_Type (Influence/Conflict), Opportunity (required), Citation, Quote	Ours, not ALTF__Contact_Influence__c — theirs has no Opportunity and no citation home, which violates Citations Do Not Cross Deals in schema
8	AOS_Shadow_Person__c	Name, Email, Domain_Side, Promoted_To (Contact lookup, nullable)	The Jefferson Vargas fix. Promotable
9	AOS_Note_Evidence__c	Text-as-arrived, Author, Arrived, Opportunity, Flag / Contract addressed	Many rows to one flag. Consolidation into Source deliberately open
10	AOS_Non_Establishment_Rule__c	Pattern, Version, Superseded_By	Never deleted — superseded only

Wave 3 — lifecycle and derived:

#	Object	Key fields	Notes
11	AOS_Fulfilment__c	Persona, Opportunity, Opened, Closed, Closed_By	NOT folded into Flag — gaps precede flags (withdrawn merge)
12	AOS_Surfacing__c	What, Opportunity, Ritual, Shown_At	Append-only. Not a flag, not a journal row
13	AOS_Roll_Up__c	Parent = standard Opportunity (006), derived arithmetic complement of Altify's 109 fields only	Never duplicate a shipped field
14	AOS_Run__c	Bookmarks, Attempt counts, Dead letters	Purgeable

Deliberately NOT in the sandbox build: the six Data 360 tables (week 2, one-way doors, categorize on arrival not at-rest — the proposition-state and rubric snapshots materialize on the memory plane, never as core objects); Required Role Set as its own object (merged into Evidence Contract, kept); the discovered proposition corpus (Platform Cache, never persisted); anything on a 1GP-managed Altify object (standing ruling).

The three genuinely new choices, yours to ratify
Prefix AOS_ on all API names. Cheap, greppable, no namespace needed in a sandbox.
Spans/Elements as JSON long-text fields on Candidate and Evidence Contract for the PoC, rather than child objects. Costs queryability on span internals; buys two days. Promotable to child objects later without data loss. Flag if you want children now.
Verdict picklist is TRUE / FALSE / UNVERIFIED exactly — abstention and not-addressed write no Claim at all (they live in Candidate states), per the three-states ruling.
Seeding and the dummy-data test

A Developer sandbox copies metadata, not data — so altify--aossb1 almost certainly has an empty rubric. No assessment questions, no qualifier placements, no plan-type rows. That is a feature, not a blocker: we seed a mini-rubric of our own (six or so propositions spanning P, C, and E routes, with elements), which means the very first thing the build proves is per-org discovery against a rubric that is not Altify's production one — the standing hazard, rehearsed on day one. The Partial Copy request to David stays open for later realism.

Dummy transcripts beat real ones for this test, because we write them: ground truth is known by construction. The accumulation test then reads exactly as ruled — transcript one carries partial evidence, the proposition lands UNVERIFIED with its receipt; transcript two completes it, the Claim flips TRUE, the journal shows both receipts on the evidence-occurred clock, and replaying the journal reconstructs the mirror byte-for-byte. Pass that and the incrementalism model is demonstrated in an org, which is the sentence Toby gets.

Connection and build path

Recommended: Claude Code + sf CLI, metadata as source in a git repo, deployed with sf project deploy. Versioned schema Toby can literally be shown, repeatable into any org, and no write-capable MCP needs wiring. The read-side sandbox MCP connector that already exists on the account covers verification queries. Alternative — a write MCP against the sandbox — adds setup and buys nothing the CLI doesn't.

The ruling amendment this build requires — say yes out loud

The standing order was "Apex lands in the sandbox only after Gate 1 passes." Gate 1 has not passed; it has two fails, a pass, a pass-with-asterisks, and a retest pending. Building now amends that ordering to parallel tracks: schema and deterministic plumbing (objects, triggers, span verification, journal/mirror) build in the sandbox immediately; everything a charter writes remains governed by Gate 1's bar, and no model-written verdict is treated as trustworthy until round two clears. Production stays read-only, unconditionally. One line in the results doc records the amendment with today's date and your name on it.
