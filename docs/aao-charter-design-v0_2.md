# AAO Charter Design

**v0.2 · 1 August 2026 · DRAFT — People charter open, self-report ruled, Identification ratified**

**Changed in v0.2.** Self-report ruled: sentiment moves one rung conservatively; terminal rungs (Mentor, Enemy) are earned across multiple separate sources and lost the same way; no behavioral-pattern inference for support — stated sentiment and human input only; a human write watermarks the dimension forever (existing precedence law). The Identification flag is RATIFIED as the fifth type, its own thing: not Ratification (which asks permission for a known write), linked to whatever red its resolution would release. New surfacing law from Matthew: a red that is one answer away from clearing is surfaced proactively regardless of tier or value. PENDING ONE RULING: Source optional on Candidate and Claim, with the evidence-family law (words → Source required; state → Claim Basis rows required; both → both) — recommended, awaiting Matthew's word; the P route is blocked on it.

Companion to the AAO Field Tables (objects) and the four project documents. This file does for the charters what the field tables did for the objects: one section per charter, every emission naming what may produce it and what checks it, rulings marked as rulings. The extraction (assessment/evidence) charter is live at 1.1.0 and its lessons feed this design.

**Changed in v0.1.** People charter opened. The person-row boundary ruled, the identity-resolution ladder ruled, the shadow scope widened, the promotion path settled (closing the object model's named open item), the CRM-write toggle recognized as the existing projection-pattern law, and one new flag type proposed: Identification, the help flag.

---

## 0 · Ruled this session, cross-charter

**The recipe ruling (state-based questions).** A model may write the query, once, at setup; the query is frozen on the contract and executed by Apex every pass. Interpretation by the model, completeness by the database (only a query can prove what is NOT there), determinism by freezing. The question-changed hash sends the model back to re-derive. Guardrails in Apex regardless of what the model wrote: deal-scoped, read-only. **The human surface is sentences, never code:** the admin sees their question, the machine's reading of it in plain words, and Approve / Revise; Revise is typed natural language round-tripped through the same model until the sentence sounds right. Default path requires zero customer-admin action — the classifier proposes from discovery; whoever deploys glances once. Runtime model-reading-of-state (the C route) is the universal floor and always works; frozen queries are the earned upgrade for pure counts.

**No rubric binding on deals** (re-confirmed): a deal always answers the org's current active questions; version is attribution on receipts, never routing.

---

## 1 · The People charter

Reads evidence; may speak only about human beings on this deal. Three kinds of emission, all Candidates, all through the ordinary gates:

1. **Existence** — this person is on this deal (participant, or referenced as mattering).
2. **Movement** — a cited nudge of one rung on an ordinal dimension (Support, Political, Coverage), from current state, never a teleport.
3. **Assertion** — this person IS something (Decision Maker, Approver), TRUE / FALSE / UNVERIFIED with a span, like any claim.

### The person-row boundary · RULED

**A person earns a row when a claim needs them.** Speakers earn rows because their words create claims. A referenced-but-absent person earns a row only when the mention is load-bearing — a stated holder, a stated gate, a stated role ("my boss John won't take a call until he sees ROI"). A name dropped in chatter creates no claim and therefore no row. This is the cardinality law for people: rows follow evidence-need. A twenty-name war story creates nothing.

### The identity-resolution ladder · RULED

For any person the charter wants to speak about, in order:

1. **Roster** — were they on the call? Deterministic, from the Source.
2. **CRM** — a Contact at this account matching the name. One query.
3. **Memory** — the account's history (prior deals, prior appearances). One keyed lookup.

Outcomes: **exactly one match** → link, machine-attributed, contestable like any claim. **Zero matches** → Shadow Contact. **Multiple matches** → Shadow Contact + Identification flag (below). Disambiguation may use stated context (title, role, relationship to speaker) but a link under ambiguity is never guessed.

### Shadow Contact, widened · RULED

Two origins now: (a) a call participant who is not a Contact (the original definition), and (b) a person referenced as mattering who was never present. Both are honest half-identities on our object. **A Contact without a last name cannot exist** — Salesforce enforces LastName, so partial identities structurally cannot leak into the CRM. Inference may enrich a shadow (proposed title, employer) as clearly-marked machine enrichment, never as establishment.

### The promotion path · RULED (closes Object Model §8's open item)

Shadow → real Contact → map row. Promotion happens when identity completes: a human confirms (via the Identification flag's answer, or by creating the Contact themselves), or evidence completes it. Contact creation into the customer's CRM is governed by the projection-pattern law: **any write to a native object we do not own ships only toggleable per customer.** Toggle off: shadows persist until a human creates the person; the map row lands only when a real Contact exists. Toggle on: creation still requires full identity and passes the ordinary checks.

### The Identification flag · PROPOSED, awaiting Matthew's word on the name

**The fifth flag type: the system asking for missing knowledge.** Distinct from Ratification ("may I write this known thing") — this is "I don't know what to write." Carries: the citation (source, turn, the sentence or two of context), the candidates found (zero, or the ambiguous set), what is needed (a last name; which John), and where to answer. **Clearance needs no new rule: the answer re-enters as evidence** — the human's reply comes through the ordinary door, resolves the identity, and the flag clears because its cause is gone. Never dismissible. Surfaces on rollups as blocking the relationship map.

**Autonomy-independence, stated as principle:** autonomy levels govern permission; this flag exists because of missing knowledge. It fires identically at level 3.

### Standing laws that bind this charter (from the existing corpus)

Attendance is not evidence of position — a silent attendee establishes at most coverage. Roles are never inferred from job titles. Movement is ±1 from current state with a span; structural inference may exceed one rung only where structure compels it. Absence never establishes. Per-charter admission gates: on a town-hall call this charter abstains while insight proceeds. Cardinality guards on every creation path.

### Self-report and the sentiment ladder · RULED 1 Aug

The way a human would do it. **Clear, sustained sentiment on a call moves a person one rung, conservatively, never more than one per source-event** (the ±1 law already held). **Terminal rungs are sticky:** nobody reaches Mentor or Enemy on one call — entering an extreme requires the same signal across multiple separate sources, and leaving one requires the same. **No behavioral-pattern inference** ("how they behaved as a call-closure piece") to derive support — too much reading between lines; the inputs are stated sentiment on calls and human judgment, nothing else. A human setting the dimension **watermarks it forever**; the machine stops writing that field (existing precedence law, applied). Open for the build: the counting rule for "multiple separate sources" (distinct Source rows? distinct days?) — lands with the output schema.

### The Identification flag · RATIFIED 1 Aug

Fifth flag type, confirmed. Not Ratification (permission for a known write); this is missing knowledge. Where its answer would clear a red, the two are linked and **the red is surfaced proactively regardless of tier or value** — Matthew's nearly-clearable law: the cheapest red to clear is the one one answer away. First concrete priority rule the surfacing design owns.

### Open, next in line

1. What this charter may do on Unsegmented sources, where no words can be attributed to anyone.
2. Output schema (the JSON the charter emits), after the above closes.

---

## 2 · The Problems charter (insights + criteria) — not yet opened
## 3 · The Politics charter (links, influence, conflict) — not yet opened

*End v0.1. One charter at a time, same as the objects: present, close, move on.*
