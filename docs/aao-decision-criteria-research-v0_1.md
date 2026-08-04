# AAO Decision Criteria Research

> **The version lives on the stamp line below and nowhere else. Satellite, outside the audit chain.**

**v0.1 · 4 August 2026 · First writing. The research grounding for decision-criteria recognition, commissioned by the Board v1.4 seed as the session's first act, before any charter text. Sources: web research retrieved 4 August 2026, cited inline; verbatim quotes were machine-extracted from live pages, and any quote that becomes load-bearing in a governed document must be re-verified against its source first. Org facts read from production `00DHn000006jYatMAE` on 4 August 2026, read-only, per the evidence law. The recognition rules in section 5 are the deliverable: propositions precise enough that a sentence is mechanically recognizable as a criterion being NAMED. One decision is surfaced for Matthew in section 6 and left open.**

**What this is.** The three call charters need decision-criteria contracts, and no contract existed when the 24 June run met "what I'm trying to do is just eliminate clicks." This satellite grounds those contracts: what a decision criterion is across the methodologies this product lives beside, what the org's own object can hold, and the sentence-level rules for recognizing the moment a criterion is named rather than a topic discussed. It feeds the charter writing and is not itself charter text.

---

## 1 · What the methodologies say

### 1.1 · Altify / TAS, the object's own methodology

The lineage runs TAS (Target Account Selling, Siebel MultiChannel Services era) through The TAS Group and Dealmaker to Upland Altify's Opportunity Manager. Two facts anchor everything else.

**The formal and informal types are defined in Altify's own user guide, verbatim** (Opportunity Manager User Guide 9.7, help.uplandsoftware.com/altify/help/v9.7/PDFs/OpportunityManager_UserGuide_9.7.pdf):

- Formal Decision Criteria: "Tangible, objective and measurable criteria, e.g. 24/7 support."
- Informal Decision Criteria: "Intangible and subjective criteria, e.g. User-friendly."

The Administrator Guide 9.7 carries a second gloss of the same pair, close paraphrase as extracted: formal as official, documented evaluation standards established by the buying organization; informal as unstated preferences and personal priorities of individual stakeholders (help.uplandsoftware.com/altify/help/admin/v9.7/For%20PDFs/OpportunityManager_AdministratorGuide_9.7.pdf). **The two glosses draw the line on different axes, tangibility versus provenance, and the difference decides a design question in section 5.4.**

**Criteria are anchored into the assessment by hard-coded IDs.** The Administrator Guide 9.7: two shipped assessment questions are hard-coded, `TC_6` displays formal decision criteria and `TC_14` displays informal ones; the standard configuration is sixteen questions under the four headings (Is there an opportunity? Can we compete? Can we win? Is it worth winning?). The four questions themselves are TAS's spine, carried verbatim in the Siebel licensed implementation (docs.oracle.com/cd/E95904_01/books/AppsAdmin/target-account-selling.html), where each criterion is rated plus, minus, or question mark, with the question mark the instructed answer when "you do not have enough information" (docs.oracle.com/cd/B40099_02/books/AppsAdmin/AppsAdminTargetAcctSelling6.html). Abstention as a first-class answer is native to this methodology.

**Per-criterion capabilities in the current product** (User Guide 9.6 and 9.7): a criterion can be renamed, set Mandatory (the guide's reading: "the deal can only progress if the criterion is met"), given a Milestone ("stages in the customer's buying process"), rated for solution fit against each competitor, linked to obstacles on the insight map, and linked to contacts: "add or remove contacts for whom the criterion is of importance," with the system suggesting contacts from the relationship map. Completeness scoring counts criteria uncovered, formal and informal separately, in bands at one-to-three and above-three. The count of criteria found is itself the methodology's measure of discovery quality.

### 1.2 · MEDDIC / MEDDPICC

The D is Decision Criteria in every variant. Definitions from the three methodology owners:

- MEDDICC (Andy Whyte's company, trademark holder): "The Decision Criteria are the various criteria by which a decision to purchase your solution will be judged," typed three ways: Technical (does it meet the requirements), Economic (finance, risk, efficiency), Relationship (values and direction alignment between the organizations) (meddicc.com/what-is-meddpicc/decision-criteria).
- Force Management (Kaplan, PTC lineage): "Formal solution requirements in which each decision maker will evaluate the solution" (forcemanagement.com/blog/meddic-vs.-meddpic-the-meaning-difference-and-benefits-of-each-for-sales-qualification-force-management). Note the per-decision-maker framing inside the definition itself.
- MEDDIC Academy (Lahoutifard, PTC alumnus): "Deals are often won or lost at the time the Decision Criteria are defined and written" (meddic.academy/new-course-decision-criteria/). The naming moment is the deal-deciding moment, in the methodology's own words.

Secondary sources converge on the formal-and-informal split in so many words: criteria are "the formal and informal factors a buying organization uses to evaluate solutions" (exec.com/learn/meddpicc-the-complete-guide); "formal and documented, or informal and unspoken but influential" (salesboostconsulting.com/blog/mastering-decision-criteria-in-meddicc); the cultural and legal register is "often vague and not formally defined. However, it is of utmost importance when closing large deals" (now.iseeit.com/what-is-decision-criteria-how-to-influence-them-in-you-favor-meddicc/).

**Ownership is explicit.** Whyte: which part of the criteria matters "will depend on... which stakeholder inside of it you are dealing with." Lahoutifard: ask "who are these criteria for or who in the Account, has pushed so that this criteria is at the top"; the criterion's author reveals the competitive position. The McMahon-lineage treatment has each criterion "owned by specific stakeholders" as a validation check (julianstorz.de/sales/meddpicc-decision-criteria-control-how-the-decision-is-made-or-dont-control-the-deal/).

**Criteria are mutable and elicited.** Every owner teaches influencing them; Force Management's elicitation is explicitly designed so buyers "anchor on required capabilities on their own," because "people don't argue with their own conclusions" (forcemanagement.com/seller-blog/how-to-stack-customer-requirements-in-your-favor). The elicitation questions in circulation ask for must-haves, deal-breakers, rankings, and evaluation standards: "What criteria will you use to evaluate potential solutions?", "What are the must-have features...", "What are the deal-breakers...", "How would you rank..." (federicopresicci.com/blog/sales/meddpicc-questions/; qwilr.com/blog/25-meddic-questions/). A buyer's answer to such a question, naming a requirement, threshold, ranking, or outcome, is what the methodology counts as a criterion surfacing. And criteria change as stakeholders enter: "a CTO might add a security requirement in week six that wasn't on the original list" (prospeo.io/s/meddpicc).

### 1.3 · Miller Heiman

Strategic Selling's contribution is that **the criteria split by person, not only by register.** Each buying influence evaluates on its own axis: User Buyers judge "the potential impact of your product or service on their job performance"; Technical Buyers "screen out possible suppliers... they can (and often do) give a final no"; the Economic Buyer gives final approval (book text via medium.com/@mitchrencher/the-new-strategic-selling-15cab2099b2e; role flags per contact in the licensed Siebel implementation, docs.oracle.com/cd/E05553_01/books/AppsAdmin/AppsAdminStratSelling6.html).

**Win-Results is the informal register with a person attached:** "A Win is the fulfillment of a subjective, personal promise made to oneself to serve one's self-interest. A Result is the measurable impact that a product has on one or more of your customer's business processes." The Blue Sheet records a Personal Win and a Business Result per contact, as free text, in the licensed implementation. Conceptual Selling adds that the buyer's Concept, "their mental picture of a good outcome," pre-exists the seller and is to be captured "in their words, not yours" (b2bsalestraining.org/miller-heiman-conceptual-selling; prospeo.io/s/miller-heiman-conceptual-selling).

### 1.4 · Procurement and RFP practice

Formal procurement is the limiting case: criteria written down, published, and legally binding on the evaluation.

**Every regime splits gate from gradient.** US federal practice separates requirements of acceptability (pass or fail; under LPTA "tradeoffs are not permitted," FAR 15.101-2, acquisition.gov/far/15.101-2) from weighted tradeoff factors, all of which "shall be stated clearly in the solicitation" with relative importance (FAR 15.304). Canada's Supply Manual: "Mandatory criteria are assessed on a simple pass/fail basis. Bids that fail to meet any of the mandatory criteria will be considered non-responsive," against rated criteria scored for relative merit (canadabuys.canada.ca/en/supply-manual/chapter-5). The EU's MEAT framework publishes criteria and weightings in advance (Directive 2014/24/EU Article 67). MoSCoW's must-have test is the spoken deal-breaker formalized: "What happens if this requirement is not met? If the answer is 'cancel the project...', then it is a Must Have requirement" (agilebusiness.org/dsdm-project-framework/moscow-prioritisation.html).

**The verb conventions, and their limit.** RFC 2119 (MUST/SHALL as absolute requirement, SHOULD as weighable preference, MAY as truly optional) and ISO/IEC/IEEE 29148 (shall mandatory, should preference, will fact-not-requirement, must avoided as ambiguous) are the institutional encoding of gate versus gradient into words. But the one practitioner source that addresses the cue directly warns that in RFPs "the location of the criterion (Mandatory section vs. Rated section), not the verb, is what determines whether it's pass/fail" (bidfit.ca/guides/mandatory-vs-desirable-criteria-canadian-rfps). Form underdetermines force even in formal text; more so in speech.

### 1.5 · What linguistics and NLP add

Three findings that bear directly on the three-call shape:

- **Speech-act theory says the naming is usually indirect.** A buyer naming a criterion rarely uses an imperative; the act arrives as volitive or deontic modality ("what we're looking for is...", "it has to...") whose force is read from context, intonation, and position in the dialogue (plato.stanford.edu/entries/speech-acts/; deontic modality per Palmer, Mood and Modality, CUP 2001). The dialogue-act annotation standard for exactly this problem, ISO 24617-2, is applied in practice by ML over utterance features, not by rule tables, which is evidence that surface form alone cannot carry the judgment.
- **Even humans only moderately agree on the grounding moment.** In the closest published analogue, aligning elicitation-interview transcripts to requirements, human inter-annotator agreement on whether a transcript chunk supports a requirement was kappa 0.470 (arxiv.org/html/2510.08622v2). The naming judgment is real judgment; a verification pass and honest abstention are not optional decorations.
- **The strongest criteria are systematically unspoken.** Kano's must-be attributes are "taken for granted when fulfilled" and not mentioned in discussion (microtool.de/en/knowledge-base/what-is-the-kano-model/). Silence about a criterion is never evidence the criterion is absent, which is the existing silence hazard restated from the buyer's side.

---

## 2 · The convergent structure

Across four traditions that never coordinated, the same three-part shape appears.

**Two registers: gate and gradient.** Mandatory, pass-fail, must-have, deal-breaker on one side; rated, weighted, should-have, preference on the other. Altify carries it as the Required flag, MEDDIC as must-haves versus priorities, procurement as mandatory versus rated, MoSCoW as Must versus Should. The gate register maps onto `ALTF__Required__c`.

**Two provenances: the organization's standard and the person's preference.** The documented, published, committee-owned criterion versus the voiced want of an individual. Altify carries it as Formal versus Informal, MEDDIC as formal-documented versus informal-unspoken, Miller Heiman as Business Result versus Personal Win, procurement as the published solicitation versus everything the evaluators privately care about.

**Ownership by person.** Altify links criteria to contacts and suggests them from the relationship map; Miller Heiman records wins per buying influence; MEDDIC asks who pushed each criterion. No tradition treats a criterion as free-floating. This is the research confirming the ruled position: decision criteria are relationship-map territory, and a criterion is owned by the person who voiced it.

And one structural warning: the naming moment is judgment over indirect speech, at only moderate human agreement. Markers can locate candidates with high recall; they cannot adjudicate. That division of labor is exactly call 1 (locate wide) versus call 2 (claim against contracts) versus call 3 (verify), so the literature independently predicts the pass shape already ruled.

---

## 3 · The org as it stands · production read, 4 August 2026

Read-only, org `00DHn000006jYatMAE`. The standing hazard applies in full: this is Altify's own org, saturated with methodology practice, and roughly 80% of target installs will look nothing like it.

### 3.1 · Schema

`ALTF__Decision_Criteria__c`: `Name` (string 80), `ALTF__Account__c` (lookup, **required**), `ALTF__Opportunity__c` (lookup, **nullable**), `ALTF__Type__c` (picklist: Formal, Informal; not required, no default), `ALTF__Required__c` (checkbox), `ALTF__Milestone__c` (**string 80, free text, not a lookup**), `ALTF__Subject__c` (textarea 255), `ALTF__AltifyId__c`.

Children: `ALTF__Decision_Criteria_Contact__c` (junction to Contact, both lookups required, relationship `ALTF__Decision_Criterion_Contacts__r`); `ALTF__Decision_Criteria_Insight_Card__c` (relationship `ALTF__Decision_Criteria_Obstacles__r`, the obstacle link the user guide describes); `ALTF__Decision_Criteria_Position__c` (the per-competitor solution-fit rating).

Consequences worth naming: the account lookup being required and the opportunity lookup nullable means account-grain criteria are schema-possible; Milestone being free text means nothing validates it against the sales process; Type having no default means an untyped criterion is representable and exists in production; and the contact junction has no uniqueness constraint.

### 3.2 · Live rows

404 criteria: 329 Formal, 74 Informal, 1 untyped. Even in the methodology vendor's own org, formal outnumbers informal four and a half to one. Read beside Kano's under-verbalization finding and the canonical missed case, the informal register is exactly where capture fails today, and exactly where transcript evidence has the most to add.

162 criterion-contact links across 404 criteria: most criteria name no owner, in the org of the company whose methodology says criteria belong to people.

Field usage, from a 25-row recent sample: **the criterion text lives in `ALTF__Subject__c`; `Name` on UI-created rows carries an ID-like string** (for example `a0lV4000002LJBN`), while one API-created row shows the opposite (text in Name, Subject null, untyped, no opportunity). Milestone is almost always null; where present it is free text ("Discovery"). One criterion carries the same contact linked twice, confirming the junction accepts duplicates. Junk rows exist ("rtrwetrwtwre"). Exactly one criterion org-wide has no opportunity, and it is the anomalous API-created row, so account-grain is unused in practice.

Real informal criteria from the sample, worth keeping because they show the register in the wild: "Bill enjoys working with Pat and Team"; "Reflects Liz's Methodology and will allow her to 'shine' in the training phase"; "Exec Sponsor who purchased still there and now Head of Americas"; "Altify / MathWorks partnership for nearly 10 years". These are relationship facts and personal wins, Miller Heiman's Win column living inside Altify's Informal type. Real formal criteria range from bare noun phrases ("Price", "Cost", "SFDC Native") to full requirement sentences ("AI features must be reviewable for enterprise data-governance and privacy alignment").

---

## 4 · Vocabulary used below, informally

The Glossary takes new terms at the charter writing, not here. Within this satellite: **naming** is the speech event in which a criterion comes into existence as evidence; **marker** is a surface form that locates a candidate naming; **stance** is the speaker's expressed relation to a condition (needing it, wanting it, requiring it), as opposed to mentioning or describing it.

---

## 5 · The recognition rules, as propositions

These are drafted to be chartable: binary units, element-structured, each establishable from quoted words by the existing envelope machinery. Codes are working handles for this satellite only.

### 5.1 · DC-N · the naming proposition

**This person, in their own words, stated a condition, capability, or outcome and tied it to evaluating, choosing, or proceeding with a solution.**

Three elements, all required:

- **e1 · An identifiable condition.** The words contain a quotable condition, capability, property, or outcome. Not a topic ("let's talk about security") but a thing that could be met or unmet ("it has to pass our security review").
- **e2 · Stance.** The speaker expresses their own or their organization's relation to it: needing, wanting, requiring, prioritizing, or conditioning the decision on it. Description of the current state, narration of the past, or commentary on a third party outside the buying organization does not carry stance.
- **e3 · Decision linkage.** The condition bears on selecting, approving, evaluating, or proceeding with a solution or vendor. This element is the boundary against the insight families: a Pressure describes the business's situation; a criterion conditions the choice. One utterance can establish both, and the dedup machinery (`nearest_existing`) already handles a statement that lands twice.

**The marker families, for call 1's wide locate.** Markers are anchor cues, deliberately over-inclusive; they locate, and never establish, because form underdetermines force (sections 1.4, 1.5). Call 2 judges the elements; call 3 verifies.

| Family | Register | Examples of surface forms |
|---|---|---|
| Deontic necessity | gate-leaning | we need, it must, it has to, required, can't work without |
| Conditional commitment | gate | if it can't X we're out, that's a deal-breaker, non-starter, otherwise no deal |
| Volitive / goal | gradient-leaning | what I'm trying to do is, what we're looking for is, the goal is, we want, ideally |
| Priority / ranking | gradient | the most important thing is, top three, matters more than, nice to have |
| Evaluation frame | either | we're evaluating on, the criteria are, it'll be scored on, the RFP says, procurement requires |
| Elicited answer | either | any buyer answer to a criteria-eliciting question (what are your must-haves, what does success look like, what would stop this) |

**Negative rules, the failures the run must not commit.** The expected failure mode is over-reading, so these carry as much weight as the positives:

- **Seller words never name a buyer criterion.** The methodology itself demands the buyer anchor "on their own"; a seller's proposed requirement is influence, not evidence, until the buyer's words carry it. What a buyer's assent to a seller's words establishes is an open question, section 6.
- **A buyer's question is not a naming.** "Does it do SSO?" anchors a candidate for call 1; it establishes nothing without stance. Repeated questioning still establishes nothing.
- **Discussion is not a naming.** A topic examined at length, a demo narrated, a feature admired in passing: no stance, no criterion.
- **Current-state description and complaint are not namings.** "The reps hate the current tool" is insight territory (a Pressure or Obstacle) unless the speaker converts it to stance ("so whatever we buy has to be something they'll actually open").
- **Absence never establishes**, including here: a criterion not spoken is not thereby absent (Kano), and silence claims are bounded by the reader's measured reliability, per the standing silence hazard.

### 5.2 · DC-R · the required proposition

**This person stated that failing this condition blocks or ends the purchase.** Establishable only from gate language: conditional commitment ("if we can't get it under legal review by Q3, this doesn't happen"), explicit deal-breaker vocabulary, or mandatory framing attributed to the buying process ("procurement will disqualify anyone without SOC 2"). This is MoSCoW's cancel-the-project test and procurement's non-responsive rule heard in speech. Gradient language never sets it, however emphatic; "really, really important" is priority, not a gate. Default false: an unestablished DC-R leaves `ALTF__Required__c` unchecked, which is the null-never-Unknown discipline applied to a checkbox whose unchecked state must mean not-established-as-mandatory, never established-as-optional.

### 5.3 · Ownership · derived, not asked

The ruled position stands and the research supports it from three directions (section 2): **the criterion belongs to the person who voiced it.** Ownership is therefore derived from the span's speaker, exactly as speaker attribution already works; it is never a separate question to the model, and never a question per person. The junction rows written are: the voicer, always.

The reported-holder case composes with existing law rather than needing new law: "Sarah will insist on single sign-on" is a naming by the speaker (stance attributed within the buying organization, e2 satisfied) whose mention of Sarah is load-bearing, a stated holder under the person-row boundary, so Sarah earns a row through the ordinary machinery. Whether Sarah is also linked as a criterion-contact on the strength of another person's report is left to the charter writing; the conservative default is voicer-only links, with the report visible in the claim.

### 5.4 · DC-F · the typing rule, and the fork inside it

The two Altify glosses (section 1.1) disagree on the axis, and a transcript forces the choice:

- **Tangibility** (User Guide 9.7 verbatim): Formal is tangible, objective, measurable; Informal is intangible, subjective. But "what I'm trying to do is just eliminate clicks" is tangible and measurable, and it is the canonical informal criterion by Matthew's own grade. From a transcript, tangibility misclassifies the case this build exists to catch.
- **Provenance** (Administrator Guide gloss, MEDDIC's formal-documented versus informal-unspoken, procurement's published-solicitation limit case): Formal is a criterion carrying organizational standing, attributed to a document, process, scorecard, committee, or mandate ("the RFP says", "procurement requires", "our evaluation matrix has"); Informal is a person's voiced preference, want, or goal, whatever its measurability. On this axis the canonical case types Informal correctly, and the discriminator is recognizable in words, which tangibility is not.

The recognition rule drafted here takes provenance, with typing as two one-sided establishments rather than one judgment: **DC-F, this person attributed the criterion to an organizational evaluation standard**, establishes Formal; a naming with stance but no such attribution defaults Informal. A criterion typed Informal upgrades to Formal when its organizational standing later surfaces, which the mutability findings say is normal deal physics (a week-six stakeholder writes last week's preference into the scorecard). The choice of axis is Matthew's and is surfaced in section 6; everything else in this satellite survives either answer.

### 5.5 · The field map

| Recognition output | Lands on | Note |
|---|---|---|
| Composed criterion statement | `ALTF__Subject__c` (255) | Composed by the writer from the span, the same law as card text: the model never writes furniture. Verbatim words live on Answer rows only, per existing law. Production convention puts text in Subject, not Name (section 3.2); the writer follows the org's own convention, exact shape CODE's at build |
| DC-N established | the row exists | A criterion row is created only on an established naming; discovery-shaped, `nearest_existing` names the row it refused to duplicate |
| DC-F established / not | `ALTF__Type__c` Formal / Informal | Per section 5.4; never null on our writes, the untyped state is not ours |
| DC-R established | `ALTF__Required__c` | Default unchecked, gate language only |
| Voicer (and holders, pending 6.2) | `ALTF__Decision_Criteria_Contact__c` | Junction accepts duplicates (measured, 3.2), so the writer needs the query-then-branch discipline here too |
| Spoken buying-process stage, if any | `ALTF__Milestone__c` (free text 80) | Only when spoken ("before the security review"); expected rare; never invented, stays null otherwise |
| Deal / account | `ALTF__Opportunity__c` / `ALTF__Account__c` | Scope from the resolver as everywhere; account-grain schema-possible, unused in practice (3.2), deal grain leads per the Board |

Restatement of an existing criterion is reinforcement, not a new row, inheriting the Problems charter's dedup shape whole: keep the parent, count the reinforcement, a different person restating appends attribution (and, pending 6.2, a junction row for the new voicer).

### 5.6 · The canonical case, worked

"what I'm trying to do is just eliminate clicks" (Adam Meloan, 24 June B&V call, graded PASS on substance by Matthew, uncapturable then because no criteria contract existed).

- Marker: volitive family, "what I'm trying to do is". Call 1 anchors it.
- e1: an identifiable outcome, eliminate clicks. Met.
- e2: stance, first person, own goal. Met.
- e3: decision linkage, spoken about what the solution under discussion should do for him. Met in context, which is exactly what call 2's measured surrounding window exists to supply; the marker alone does not carry e3.
- DC-F: no organizational standing attributed. Informal, matching the grade.
- DC-R: no gate language. Not required.
- Ownership: Adam voiced it; the junction row is Adam's.

The rules recover the miss. The negative rules then have to be checked against the same fixture the other way: the two S1 over-reads were wrong-scope establishments, and the recall gate (strip-and-restore on the 24 June fixture against Matthew's six grades) measures both directions at the charter writing.

---

## 6 · Open at the charter writing, and one decision surfaced now

**6.1 · The decision surfaced, Matthew's: the typing axis (section 5.4).** Tangibility follows the User Guide's verbatim sentence but misclassifies the canonical case and is not recognizable from words; provenance follows the Administrator Guide, MEDDIC, and procurement practice, classifies the canonical case correctly, and is recognizable from words, but reads against the object's own help text on one axis, and some genuinely objective spoken requirements will type Informal until their organizational standing surfaces. The satellite drafts provenance; the call is open.

**6.2 · Left to the charter writing, per the seed:** whether assent establishes (a buyer's "yes, exactly, that's a must" after a seller-worded condition; lean: explicit assent whose own words carry stance establishes, bare yes does not, and the span cites both turns); whether a reported holder gets a junction row or voicer-only (lean: voicer-only, 5.3); and the abstention vocabulary, verdict set, and anchor mechanics, which are pass-shape questions, not criteria questions.

**6.3 · The riskiest unvalidated assumption, named.** That the six marker families give call 1 high recall on real transcripts: the negative space (namings with no listed marker) is unmeasured, and kappa 0.470 among humans warns the boundary is genuinely contested. What to measure first: the ruled recall gate, strip-and-restore on the 24 June fixture against Matthew's six grades plus the canonical criterion, before any charter text is trusted. A second cheap measure exists in the org itself: the 74 production informal criteria are a free test list of what real informal criteria look like, checkable against the families by reading, no model needed.

---

*End v0.1. Feeds the three call charters; folds nothing into the five documents by itself. Corrections go into this file, marked wrong in place, never deleted.*
