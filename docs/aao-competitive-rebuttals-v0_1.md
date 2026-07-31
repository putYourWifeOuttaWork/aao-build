# AAO Competitive Rebuttals — living file

**v0.1 · 31 July 2026 · running list, append as questions arrive**
Discipline: every answer here leans only on proof-register rows. Proven rows may be stated flat; needs-measurement rows are stated as design properties ("by construction") never as benchmarks; unverified rows are not used at all. Update this file the moment a new objection appears in a meeting, with the answer that worked or the answer we wished we had.

---

## 1 · The vision-slide audit — "true only if"

Any always-on AI slide (Toby's GPT sketch, Gong's marketing, a pod pitch) makes the same promises. Never attack the slide; claim it. Each sentence is true only under conditions, and the conditions are our build.

| The promise | True only if | Which is |
|---|---|---|
| Keep plans always current | every update carries the words that caused it and can never overwrite a human | the write law + human precedence |
| Auto-handle with confidence | "confidence" means passed deterministic checks, since model confidence is uncalibrated | the four gates; autonomy levels change who approves, never what is checked |
| Alert what matters | a flag has a cause and clears only when the cause goes | flag law; no dismissal |
| Learn and improve | learning is proposed by the machine, promoted by a human, versioned, never deleted | rule discovery |
| Signals from everywhere | evidence and context stay distinct, or outputs inherit the credibility of the least credible input | speaker requirement, admission gates, derived-classifications-never-trusted |
| Secure by design, enterprise native | the middle of the system is records you can open, not verbs you must trust | nouns over verbs: Source, Candidate, Claim, Answer, Flag |

**The structural critique behind all of it: a promise diagram has no nouns. You cannot audit a verb.** When InfoSec asks why a field says what it says, a verb has no answer. Enterprise trust attaches to records you can open, query, and replay.

## 2 · Versus the build-on-AWS / GraphRAG shape

**The second system.** Draw the boundary picture for an AWS build and a second system appears: its own store, its own identity, its own copy of customer conversation data, its own security review, its own DPA. Ours adds zero new systems; one review of a boundary every customer already approved.

**Memory determinism.** Their history is stored inference: to answer "how has this person behaved across two years," a graph stack retrieves, re-reads and re-infers, model tokens every time, different answer possible every time. Ours is receipts under keys: the same question is one lookup, zero model tokens, same answer every time, by construction. Contention and call prep read known rows and never re-read a transcript.

**Cost shape.** Always-monitoring architectures spend proportional to data volume forever. Ours spends on new evidence a bounded number of times, then everything downstream is keyed reads. (Numbers land in the register as model calls go live; until then this is stated as the design property it is.)

**Drift.** Un-receipted learning means the system's beliefs move and nobody can say why today differs from yesterday. Our answers change only when a claim is written, and every claim names its evidence.

## 3 · Versus the SMB buy (pod / Champify shape)

Contact-centric, external infrastructure, two SMB clients. Toby's own words: "I guarantee they are not even prepared to go hook up a JCI for a Spectrum." What a buy purchases is a head start on the wrong boundary: the enterprise objections (residency, review, determinism, methodology depth) are the parts they would still have to build, inside a stack that makes those parts hardest. We are past the part they'd be starting.

## 4 · Salesforce licensing and pigeonholing rebuttals

**"Isn't this just Agentforce?"** No, and it's ruled in the architecture: an agent runtime is a consumer of what we produce, never the substrate. We depend on the Trust Layer as a model gateway and on Data 360 for ingestion and memory. Neither is Agentforce. The phrase: **Agentforce-ready, never Agentforce-dependent.** Works identically under Claude, Copilot, MCP, or a runtime that doesn't exist yet.

**"Doesn't building on Salesforce pigeonhole us?"** The evidence model (contracts, claims, answers, receipts) is schema, not platform magic; it's portable in principle. What the platform buys is the moat: the customer's truth already lives there, the trust boundary is already signed, and co-sell exists. Portability is retained at the design layer; the boundary advantage is why we start here.

**"What does the platform cost us?"** Honest version: Data Services credits are metered and we meter them from day one (ruled); token economics favor keyed reads over re-reads by construction; hard numbers enter the register with the first live model passes. Never claim "free."

**"What if Salesforce builds this themselves?"** They own the commodity layers: runtime, gateway, lake. What they do not own is the methodology as data, the rubric discovery, the enforcement layer, and twenty years of what a winning enterprise deal structurally requires. We build the proprietary layer beneath their commodity layers, which is the stated strategy.

**"Why not wait for the platform's agents to just do this?"** Verbs versus nouns. A runtime can converse; it cannot be the deal's system of record. Whatever agents win, they will need something trustworthy to read. We are what they read.

## 5 · Phrasing guardrails (say / never say)

- Say **our answer row**, never bare "answer" (ALTF__Answer__c exists).
- Say **Agentforce-ready, never Agentforce-dependent**; never "no Agentforce required."
- Say **verified / established**, never "scored" (Altify owns score; we produce none).
- Say **receipts**, never "confidence" (retired term, uncalibrated).
- Say **the meaning was staged; the machinery is the shipping path** for any pre-model demo.
- Say **by construction** for design properties; numbers only from the register's proven column.

---

*End v0.1. Append, don't rewrite; when an answer is battle-tested in a real meeting, mark it with the date it worked.*
