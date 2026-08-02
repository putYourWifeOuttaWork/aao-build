# AAO Scope Resolver

> **The version lives on the stamp line below and nowhere else.**

**v0.4 · 2 August 2026 · The net-new participant rule: added to BOTH maps on a dual-scope call, because coverage is a claim and presence establishes it in both scopes. Supersedes adds-nobody and the establishment-gated proposal. Dimensional writes stay establishment-gated per scope. This closes the last open behavior of the resolver except per-claim scope.**

**v0.3 · 2 August 2026 · The B&V test ran and two rules graduate from it: the two-key lock and the dual-write rule. The which-opportunity match is no longer open — it worked on a real four-opportunity account, with one weighting correction.**

**Changed in v0.3, ruled by Matthew from the test.**

**The two-key lock · RULED.** Tests 1 and 2 both always run and **neither resolves alone.** Agreement resolves; disagreement falls to traversal. The org itself supplied the counterexample that forces this: Casey, a Customer Success Manager, owns both Black & Veatch renewal opportunities, so an account-oriented role owning deal calls is not an edge case, it is how renewals work. Role stops being a short-circuit and becomes half of a two-key lock, which also means a wrong entry in the role map can no longer misroute a call by itself.

**The dual-write rule · RULED.** When both scopes resolve, the evidence is related to **both** — the account and the specific opportunity. **ECI's failure on the B&V call was singularity, not the pick:** its one-slot stamp chose the right deal and thereby lost forty minutes of account truth. Under the dual rule, map details update in both scopes for already-mapped people, each scope's rubrics reading their own side of the two-sided summary; establishment rules are unchanged, no establishment no write, restatements land as reinforcements, and nobody new is added to either map by a dual-scope call.

**The overlap read weights curated rows, never bare membership · RULED from the clone finding.** Altify seeded the stamped deal's map by cloning all 44 account-map rows at creation; only nine were ever curated. Bare membership overlap is therefore inheritance, not signal. The discriminating read is rows a human touched — curated attributes, non-default values.

**The B&V test result, recorded:** scope read on 61% of the transcript returned account-primary with expansion seeding (Adam Meloan's *"maybe that is one of our first business cases"*), which is the dual trigger per the ontology's own caveat. Which-opportunity resolved to Community Licenses-150 by agreement of curated-overlap (3 of 3 participants curated there; 1 of 3 on the demo deal; 0 of 3 on both renewals) and content match (community licenses and MCP use-case talk; zero renewal language). Participant-to-contact proved deterministic in ECI orgs: `VideoCallParticipant.RelatedPersonId` was populated with real Contact ids on every external row.

**v0.2 · 2 August 2026 · Matthew's corrections land: the account-map check replaces the account-plan check, ownership traversal is demoted to a suggestive read, the which-opportunity match gains its method and stays OPEN pending the live test, and dual-scope gains the two-sided summary.**

**Changed in v0.2, all from Matthew.** **The account-plan check is dead.** Account plans are an Altify schema most customers will not have — half or more run relationship and insight maps only — and a plan can live in a PowerPoint no system sees, so gating anything on plan existence fails orgs for not owning a feature. **The check is whether an account MAP exists** — account-scoped map or insight rows — which is readable in every org that has the smallest footprint. **Ownership traversal is demoted from deterministic to suggestive:** with CPQ or SAP carrying the commercials, the CRM cannot prove what an account owns; closed-won history over a trailing window suggests ownership and guarantees nothing. And one floor stated: **a call in scope at all means at least one open opportunity exists**, because licensed-owner scoping is what admitted the call, so which-opportunity always has a candidate.

**What this file is.** How one piece of evidence learns which map it may speak to: an opportunity or the account itself. This decision runs before any charter and gates every write. Wrong scope on a call writes machine claims into a seven-figure deal record or pollutes a durable account map, so the resolver is held to the same bar as establishment even though it only routes.

**Why nothing platform-supplied can carry it, measured 2 August.** ECI's `RelatedRecordId` is inference and unstable inference: the same recurring meeting (Altify | T-Mobile Lion Team, one series, five instances) was stamped to the account twice and to an opportunity three times inside five weeks. A CSM's account call (Altify | Black & Veatch Bi-weekly, 24 June) was stamped to an opportunity while its transcript discusses adoption, enablement, MCP rollout and QBR prep, with not one sentence about the deal it was filed under. And roughly 75% of target customers have no ECI at all; their transcripts arrive as files with no related record. **The stamp, where present, is one input. It is never the answer.**

---

## The tests, in order · RULED

**The ladder is ordered by decisiveness, not by determinism.** That is the correction to the first draft of this design: a deterministic read whose meaning cannot be interpreted alone is not decisive. Ownership traversal is perfectly deterministic and means nothing by itself, because an account that owns product still runs new-business and expansion deals. So the cheap decisive test runs first, the near-decisive semantic test second, and the deterministic-but-ambiguous read serves as the interpreter's evidence, not as a verdict.

### Test 1 · The call owner's role · deterministic at runtime

**The owner-organizer of the call is the person whose work the call is.** An account manager organizing a call is doing account work even when she pulls in a seller to demo the product she needs demonstrated — the B&V call exactly. Speakers do not control; the organizer does.

The owner's role resolves through the **role map**: this org's role names classified account-oriented or sales-oriented, **derived once per org at setup, model-proposed, admin-ratified in one sitting, cached forever** — setup-time inference, the same mechanism as persona derivation and computability. One ratification at install. **No per-call and no per-series ratification exists anywhere in this design.**

Internal owner, mapped role → resolved. Sales-oriented → deal side, and Locate narrows to which deal (Test 3 supplies the match where no ID exists). Account-oriented → account scope, done. External or unmapped owner → fall through.

### Test 2 · What is discussed · the scope read, basic inference

A summary-level read of subject, agenda and transcript answering one authored question: **is this call about account matters or opportunity matters.** It runs second because its answer prunes everything after it: **an account verdict ends the resolver** — no traversal, no ownership check, nothing else to know.

The sided vocabulary it reads against is **ours to author, shipped as seed metadata exactly like the People ontology** (two fields, org override, LAW #1 shape). Draft below, owed correction.

This is inference and it is admitted deliberately: what a call is about is nearly always sayable from what was said, the classification **routes and never establishes**, nothing it produces is cited, and its failure mode falls through rather than deciding.

### Test 3 · Traversal · suggestive evidence for the interpreter, and the map check

Runs only when Tests 1–2 have not resolved, and always when an opportunity-side call needs its specific deal.

**The map check, deterministic and first within this test:** does an account-level map exist for this account — account-scoped Contact Map Details or insight rows, opportunity lookup null. Readable in every org with any Altify footprint. **No account map and the summary reads opportunity → opportunity call, done.** An account map exists → the account is a live mapping surface and dual scope is possible, decided by what the summary found.

**The ownership read, suggestive only · corrected in v0.2:** closed-won opportunities over a trailing window suggest the account owns something; CPQ in Salesforce or SAP means the CRM may never prove it. Owns-nothing-visible with no account map supports new business. **Ownership never decides anything alone.**

**The which-opportunity match · method ruled, mechanism OPEN pending the live test.** A global account routinely holds two, three, four open opportunities, so knowing a call is opportunity-side is half the answer. Two reads combine, one deterministic and one inferred, both against the **closed candidate set of this account's open opportunities**:

1. **Participant overlap, deterministic:** the call participants' email addresses against each candidate opportunity's Contact Map Details. The deal whose map holds the people on the call is the deal the call served.
2. **Content match, inferred:** subject, agenda and the Test 2 summary against each candidate's attributes — name, type, stage, close-date talk.

Agreement resolves. The model answers candidate, NONE, or AMBIGUOUS — the People identity-match shape reused — and AMBIGUOUS falls to the flag. **OPEN until the B&V test below is run and the method is seen to work on a real multi-opportunity account.**

### Test 4 · Speakers · tiebreak only

Who is speaking, last, weakest. This is ECI's entire method and the B&V misfile is what it produces when trusted; it enters only as a tiebreak between surviving candidates.

### Test 5 · The flag

Still unresolved → yellow flag asking where the call belongs. **Target rate: one in a hundred, not a workflow.** The evidence has already landed regardless — Sources always land; scope gates adjudication and writes, never arrival.

---

## The dual-scope call · Matthew's opening ruling, deeper design owed

The expansion case is real: managed services on an owned product is an account-level opportunity, and one call legitimately serves both scopes.

**The net-new participant rule · RULED, superseding two earlier positions.** *v0.1 ruled adds-nobody; an establishment-gated alternative was proposed in session and rejected; both are superseded by this, Matthew's ruling, and the reasoning is recorded because it corrects a miss.*

**A net-new external participant on a dual-scope call is added to BOTH maps.** The argument is the system's own law applied honestly: **coverage is a claim, and presence establishes it** — a silent attendee establishes at most coverage, which is not nothing, it is a claim, and a claim that needs a person earns the row. Coverage is scope-symmetric by construction: the occasion happened for the account and for the deal alike. So the coverage claim alone justifies the row in both scopes, and the person lands on both maps with coverage counted and **every other dimension at Unknown, which the maps natively support.**

**Why both rather than the inferred one, stated as the conservatism it is.** A wrong single-map placement by inference costs a team guidance on a person they cannot see — an account-level power hire filed only onto a deal map is invisible to account management forever. A person present on both maps with honest Unknowns costs nothing and lies about nothing. **We reduce the impact of our mistakes rather than the elegance of our placements.**

**Dimensional claims remain establishment-gated per scope, unchanged.** Decision orientation moves on the account row only from account-side words; buyer role moves on the deal row only from deal-side words; coverage moves on both from the occasion itself. Addition is by presence; every dimension beyond coverage is by establishment.

**Every existing guard binds untouched:** the admission gates and cardinality caps (a two-hundred-person webinar already fails the bounded-committee gate and adds nobody), the identity ladder and Identification flag before any row, and the Contact toggle governing whether any of it reaches Altify's own tables — shadow persons where it is off.

For **already-mapped** people the v0.1 mechanics stand: the binary rubrics run over each person **once per scope** — account questions against the account row, opportunity questions against the deal row — and each claim lands in its own scope.

**The two-sided summary · added in v0.2, Matthew's.** On a dual-scope call the scope read produces **two summaries from one pass**: the account-focused summary (maintenance, adoption, consumption of what is owned) and the opportunity-focused summary (the expansion, its future close, its decision talk), each side carrying the parts of the call the ontology assigns to it. Each summary then drives its own scope's reads, so the account rubrics see account content and the deal rubrics see deal content, from one transcript, with nothing read twice.

**The dual trigger, restated with the v0.2 corrections:** an account map exists AND the content reads both sides. Ownership is not in the trigger — an account map plus mixed content is dual even where the CRM cannot prove ownership.

**Named open, not settled here:** whether scope ultimately resolves per claim rather than per call. *(The net-new-person question is closed above in v0.4; the which-opportunity mechanism closed in v0.3 by the B&V test.)*

---

## The account/opportunity content ontology · DRAFT v0 · owed Matthew's correction

Authored by us, shipped as seed, org-overridable. Sided vocabulary, not keywords — the read is what the conversation is about, and the lists below are the meaning of each side, not strings to grep.

**Opportunity-side:** the decision process and decision criteria · a compelling event and its date · budget, funding, approval to spend · evaluation, proof, demos in an evaluation context · proposal, pricing, quote, negotiation · competition and alternatives · contract, legal, procurement, signature · timeline to a decision · who must say yes to a purchase · **renewal conversations** (renewals are opportunities in the methodology — two renewal processes exist) · ROI justification before a purchase.

**Account-side:** adoption and utilization of an owned product · onboarding, training, enablement · business reviews and QBRs · support, escalations, service delivery · managed-services execution · value realization from what is owned · roadmap and relationship cadence · account team orchestration across many deals.

**Authored caveats, in the ontology itself:** late-stage onboarding discussion inside a still-open deal reads account-shaped and is not · expansion seeding ("we could also use this for…") on an account call is the dual-scope trigger, not a scope flip · a seller demoing on an account call does not make it a deal call (the organizer test already said so).

---

## Where this sits

Before the admission gate's per-charter checks, after Locate finds the account. The account is always findable — every call resolves to an account by participants and domains, D360 match rules supplying that join for file-dump orgs on the slow lane, the deterministic email-domain join staying the hot path. **Scope selection is the resolver's job alone; D360 identity resolution answers who, never which scope.**

---

*End v0.1. The ontology draft above is the piece owed correction; the ladder is ruled. Folds into charter design at its next bump.*
