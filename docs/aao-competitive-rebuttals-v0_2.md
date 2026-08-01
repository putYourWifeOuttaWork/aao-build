# AAO Competitive Rebuttals — living file

**v0.2 · 2 August 2026 · adds the value-curve argument (§6) and the KPI ledger (§7)**

**Changed in v0.2.** Two sections added for the QBR, both from Matthew's framing: we are not arguing against an acquisition's price tag, we are arguing for the underlying value curve of this system against comparable systems. Every sales-AI architecture is on one of two curves, multiplicative improvement or multiplicative decay, and only certain metrics reveal which — metrics we will measure. The same framing requires naming the KPIs that are no longer indicative of success, and why. Register discipline unchanged and applied throughout: §6 is by-construction argument; its arithmetic is arithmetic, never a benchmark; no external number appears anywhere until the register carries it as measured.

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

**"What would it cost to build this properly?"** Don't argue what an external build would cost; show what this one did cost, receipted: seed to model-verified pipeline in ~48 hours, one architect plus AI tooling, zero new infrastructure, zero new vendors, under a dollar of tokens (register row 26). The reason the number is small is structural, not heroic: everything expensive about the alternative, the storage, the identity, the security boundary, the memory plane, already existed inside the customer's platform. An external build spends its first millions recreating what we started on top of.

## 5 · Phrasing guardrails (say / never say)

- Say **our answer row**, never bare "answer" (ALTF__Answer__c exists).
- Say **Agentforce-ready, never Agentforce-dependent**; never "no Agentforce required."
- Say **verified / established**, never "scored" (Altify owns score; we produce none).
- Say **receipts**, never "confidence" (retired term, uncalibrated).
- Say **the meaning was staged; the machinery is the shipping path** for any pre-model demo.
- Say **by construction** for design properties; numbers only from the register's proven column.

## 6 · The value curve — multiplicative improvement or multiplicative decay · v0.2 · **by-construction argument**

**Framing law for the room: never argue against a price tag. Argue for the value curve.** The comparison is not "our build versus a fifty million dollar asset"; it is what any inference-first architecture does to an enterprise sales team over time, versus what a verification-first architecture does. Every system in this category sits on one of two curves. There is no flat option, because both mechanisms below are multiplicative.

**Why inference-first decays, argued from construction, no benchmarks claimed.**

**Errors multiply across hops.** An inference-everything stack is a chain: conversation to extracted entities, entities to graph edges, edges to re-inferred memory, memory to guidance. Per-hop error compounds multiplicatively. The arithmetic is arithmetic: five hops at ninety-five percent fidelity each is 0.95⁵ ≈ 77% end to end; at ninety percent it is 0.90⁵ ≈ 59%. We assert no particular per-hop number for any vendor — the point is structural: whatever their per-hop fidelity is, the end-to-end figure is the product, and every added hop moves it one direction.

**The corpus pollutes itself.** A knowledge graph that re-infers over its own prior inferences feeds outputs back in as inputs. Error stops being per-query and starts being cumulative: fidelity decays with corpus age. A system whose value is supposed to appreciate with data instead depreciates with it.

**The human check decays on the same clock.** People skim what is done for them, and they skim more each month; a twenty-five-row proposal table gets one yes, not twenty-five readings. Better models make this worse, not better, because fluency improves faster than fidelity — the wrong guidance reads more plausibly every generation. Falling fidelity, rising confidence, weakening review.

**The damage concentrates in the tail.** Enterprise sales damage is variance, not mean. One inverted read of who the economic buyer is, on one seven-figure pursuit, outweighs a quarter of harmless small errors — and the biggest deals carry the most unstructured data, so they present the most inference surface. Guidance noise reallocates the scarcest resource in the company, senior seller time, toward deals that cannot close and away from deals that could.

**The honest concession, stated before anyone raises it.** Against an empty CRM, inference-first wins early, and it will demo well: fields fill, dashboards go green, bottom-quartile reps are lifted by any information at all. The argument is never that inference produces nothing. The argument is the derivative, not the intercept: their curve starts up and bends down as the corpus pollutes and trust erodes; ours starts modest and compounds, because receipts accumulate and stay true forever. What a buy acquires is a depreciating stock of inferences. What the build creates is an appreciating stock of evidence.

**Why ours compounds, each clause a register row or a by-construction property.** Replay rebuilds every answer exactly from claims (proven). The same question is one keyed read, zero model tokens, same answer every time (by construction). Every attributed transcript is a free attribution test case forever (by construction, the strip-and-restore harness). Reinforcement counts make importance measurable instead of asserted (by construction). Nothing is ever silently overwritten, so the corpus cannot pollute itself (the write law, proven in the org).

**The kill question, for Robert to ask any inference-first vendor:** what is your measured per-hop fidelity, and show me the citation behind any single field. There is no answer, because the architecture does not retain one. We answer the same question with Gate 1 rows: 12/12 outcomes against staged truth, zero hallucinated spans ever, byte-verified.

## 7 · The KPI ledger — what stopped meaning success, and what we will measure · v0.2

**Adoption was the metric of the software era. Enforcement and fidelity are the metrics of this one.** When generation is free, every KPI that counts production goes green under slop. A KPI that cannot fall when the system is wrong is not a success metric; it is a vanity metric with a dashboard. Both curves in §6 look identical on the retired list below — that is exactly why the list must be named out loud, because the acquisition target's deck will be built from it.

**No longer indicative of success, and why:**

| Retired KPI | Why it stopped meaning anything |
|---|---|
| Field / plan completeness % | Generation is free; an inference stack fills every field whether or not the content is true. Completeness now measures output volume, not knowledge. |
| Coverage dashboards going green | Same failure at the aggregate: green measures that something was written, never that it was established. |
| Activity capture volume | Counts what was recorded, not what was understood. Rises identically under both curves. |
| Count of AI-generated updates | Measures the machine's productivity, which is unlimited and worthless in itself. |
| Suggestion acceptance rate | The inversion: near-100% acceptance is a warning light, not a win. It measures skimming. A healthy acceptance rate has texture, because humans who actually read sometimes say no. |
| Adoption / DAU / logins | The software-era metric. This system is designed to collapse human data entry toward zero; succeeding at that lowers "usage" while raising truth. |

**Still meaning something, and we will measure them (each enters the register as measured the day it lands; until then, by construction):**

| Fidelity-era KPI | What it tells you |
|---|---|
| Citation coverage | Share of written values carrying verbatim receipts. The single number that separates the two curves. |
| Span verification pass rate | Byte-checked quotes against the frozen artifact. Gate 1's number, currently zero hallucinated spans ever. |
| Abstention rate by charter | A reader that never abstains is inferring. Tracked per charter and per reason; `not_returned` tracked separately as charter quality, never blended in. |
| Human overturn rate | How often a person contests or overturns a machine answer. The only "accuracy" number that can fall over time and mean it. |
| Evidence-driven confirmation rate | Confirmations earned by the counting rules versus asserted by gesture. The won-deal outlier (44/66 human-confirmed) is what this looks like when real. |
| Reinforcement counts | How often a thing has been pressed, reconstructible from claims. Importance measured, never inferred. |
| Replay fidelity | Answers rebuilt exactly from claims, run as a test, currently proven in the org. |
| Day-one red clearance | Reds cleared by TRUE — by doing the work — never by dismissal, which does not exist. |
| Time-to-truth | Evidence-occurred to answer-established. Two clocks make it measurable; one clock would make it a guess. |

**Discipline note.** §6 contains no measured claim about any competitor and must never acquire one secondhand; if a number about their side ever enters this file, it enters with a source and a date or it does not enter. §7's right-hand column is the measurement plan; each row graduates to the register individually.

---

*End v0.2. Append, don't rewrite; when an answer is battle-tested in a real meeting, mark it with the date it worked.*
