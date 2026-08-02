# AAO Account-Level Ontology Captures

> **The version lives on the stamp line below and nowhere else.**

**v0.2 · 2 August 2026 · The account insight map ontology captured whole: five lane definitions, four admission tests, four example lists, and the person-to-card questions. One incident during the walk, logged in section 4.**

**What this file is.** Verbatim ontological text captured from the production UI for the account-level halves of the People and Problems charters, held here until it folds into the charter design record at its next bump. Provenance for everything below: read from the Altify production org's own UI on 2 August 2026, screenshots taken by Matthew, transcribed byte-exact. Spelling and punctuation untouched.

**Why this file exists.** The account map reopen needs ontological text for the dimensions and card types the account map actually uses. Decision Orientation is the account map's own dimension, filled on roughly 26 percent of account rows against 3 percent of opportunity rows, and it was scoped out of deal work for exactly that reason. It comes back into scope for the account-level People charter.

**What this reopens, named rather than passed over.** The Scoped-Out Dimension ruling said Decision Orientation is humans-only: no `_Answer__c` field, no wizard questions, a judgment about character rather than a report of speech. **The first half stays true and the second half is now qualified by Matthew's direction: the definitions below become the ontology, the same shape as Buyer Role** — no vendor question set exists, so we author the propositions from the definition text, contracts land `Inferred_Pending` until ratified, and establishment still requires words a person actually said, never a personality read. The scope-out survives at deal level. At account level the dimension is in scope for the charter.

---

## 1 · Decision Orientation · the five values, verbatim from the wizard

**Surface:** the Decision Orientation modal on the account relationship map, "Select manually" — there is no guided-question path, only definitions. Each value carries a card description, a "Who are they?" text, and a "What next?" text.

### Financial

**Card:** This person's primary interest is price, cost and economics.

**Who are they?** This person's primary interest is the price, cost, and economics of your solution.

**What next?** When meeting with this person, keep in mind your product must be viable while numbers and negotiations will be their priority.

### Technical

**Card:** This person's primary interest is product functionality and technical capability.

**Who are they?** This person is often analytical and detail-oriented.

Their primary interest is in your product functionality and technical capability.

**What next?** When meeting with this person, keep in mind that product demonstrations, benchmarks, and careful deliberation will be their priority.

### Relationship

**Card:** This person is looking to partner with someone.

**Who are they?** Their primary interest is the people and company that will be servicing their organization.

**What next?** When meeting with this person, keep in mind your product must be viable while overall support, trust, effort, and responsiveness will be their priority.

### Business

**Card:** This person sees the big picture and considers the overall business impact your solution will have on their company's current and future state.

**Who are they?** This person can properly balance the technical, financial, and relationship issues.

Their vision is often strategic and extends beyond their company to include their clients, their competition, and their partner community.

**What next?** When meeting with this person, industry knowledge and articulating business vs. product value will be key.

### Unknown

**Card:** Decision orientation is unknown.

---

## 2 · What the charter takes from this

**The shape is Buyer Role's shape, exactly.** Manual pick, definitions and nothing else, so we author the propositions from the definition text and a human ratifies them. Contracts land `Inferred_Pending`.

**The "Who are they?" text is the proposition source. The "What next?" text is guidance and never enters the reader's input** — it is seller coaching, the same class as the insight admission tests that were ruled guidance rather than gates.

**Establishment stays evidence-bound.** *This person's primary interest is price, cost and economics* is establishable from words the person said — pressing on price, asking for the economics, negotiating terms. It is the speech-report reading of a definition that was written as a character sketch, and the charter takes the speech reading, because behavioural-pattern inference is already forbidden. One FALSE-direction hazard to carry into authoring: these four values are not mutually exclusive by evidence — a person can press on price and ask for benchmarks in one call — so the propositions must be authored as independent assertions with the value derived from which one dominates by count of establishments, or the dimension abstains as AMBIGUOUS. **That derivation rule is not settled here.**

**The four "What next?" texts are enablement content for guidance**, the same join the Solution enablement sections ruling recorded: when guidance speaks about a person with an established orientation, the vendor's own coaching sentence is one read away.

---

## 3 · Account insight map · captured whole

**Provenance:** walked in the production UI on 2 August 2026, Account Plan for Salesforce, Inc., Insights tab, via browser. Lane tooltips read by hover; admission tests and examples read from the *What is an account X?* link on an open card panel. Byte-exact, including one shipped typo. **The Acc Solutions lane exists** — it renders only when the Acc Solutions toggle is on, which is why it is easy to believe it absent.

### 3.1 · The five lane definitions, verbatim

**Acc Goals:** An Account Goal is an end result which an Executive needs to achieve, ideally with a measurable outcome and a specified time frame.

**Acc Pressures:** An Account Pressure is an internal and/or external business issue that significantly impacts achieving the Goal(s), and serves as a driver for Initiative(s).

**Acc Initiatives:** An Account Initiative is a project created to address the Pressure(s) and achieve the Goal(s).

**Acc Obstacles:** An Account Obstacle is an internal operational problem, typically with either organization, process, culture, skills, or technology. Something that is broken, or doesnt exist, and needs to be enabled during the Initiative.

> *"doesnt" ships without an apostrophe. It stays that way here, per the byte-exactness law, and it is another `CONFCLIT`-class specimen: the package contains typos and a sweep that assumes clean text misses things.*

**Acc Solutions:** A set of capabilities, products, or services that help remove the Obstacles - enabling the success of the Initiative, relieving the Pressures, and contributing to achieving the Goals.

> **The causal chain is authored INTO these definitions.** Pressure names Goals and Initiatives; Initiative names Pressures and Goals; Obstacle names the Initiative; Solution names Obstacles, Initiative, Pressures and Goals. The vendor states the edge structure per lane on the account map, in prose, while the schema still holds one typed edge. Rebuttals-grade.

### 3.2 · The admission tests, verbatim, with the opportunity-map deltas

**Account Goal** — You should think about the following to help you determine if this is an account Goal: Is this a business goal which an executive needs to achieve? · What KPI will the executive use to measure results? · Does the result need to be achieved within a specific time frame?

> *Differs from the opportunity test on every question: deal-level asks about the decision maker's personal goal, how the decision maker is measured or compensated, and quantification. Account-level asks business goal, executive, KPI. **Personal versus business is the axis of the AM/OM split for Goal.***

**Account Pressure** — Is this pressure on the business impacting the executive's goals? *(rendered as: How is this pressure on the business impacting the executive's goals?)* · Is the pressure causing an initiative to be prioritized, sponsored, and funded by a key player? · Is the pressure connected to a compelling event?

> *Deal-level asks the pressure categories, sponsorship by the decision maker, and whether it prevents a goal. Account-level drops categories, moves sponsorship to a key player, and adds the compelling event. **The decision-maker role systematically becomes key player at account level.***

**Account Initiative** — Is the initiative in place to address internal or external pressures on the business? · Is a business pressure causing the initiative to be prioritized, sponsored, and funded by a key player? · Will success of the initiative have an impact on the executive's goals?

> *Same three-question shape as deal level with the same two substitutions: key player for decision maker, executive's goals for the decision maker's goal.*

**Account Obstacle** — identical to the opportunity test, all three questions, fixed with your solution, significant enough to establish substantial value, negative consequences if not fixed. **Consistent with the label enumeration: Obstacle has no AM variant.**

**Account Solution** — identical to the opportunity test, all four questions, ending on *Would a key player be able to articulate your unique business value from this Solution?* **Consistent with `SOLUTION_DEF_AM` and `_OM` being identical.** No examples link is offered for Solution.

### 3.3 · The example lists, verbatim

**Goals (7):** Grow revenue by 15% in next 6 quarters · Increase shareholder value by 2% in 3 years · Enter APAC market in next Financial year with new cloud product · Grow from 2k to 3k net new customers by end of this Financial year · Improve profitability margins by 3% · Expand market share by 6% · Become innovation leader

**Pressures (11), category tags theirs:** Eroding market share (competitive) · Difficult mergers or acquisitions · Slow time to market (market) · Decreasing shareholder value (financial) · Cost rising by x percent (financial) · Profits down by x percent (financial) · ROI too slow (financial) · Insufficient revenue - flat or x % up or down (financial) · High turnover (operational) · Customer satisfaction down by 10% · Lack of trust from partners (partner)

> *The parenthetical tags map examples onto the Pressure Type checkbox set, and two examples carry no tag. Authored, imperfect, kept as is.*

**Initiatives (12): identical to the opportunity map's twelve**, already recorded verbatim in charter design. One list serves both maps.

**Obstacles (9):** Managers not equipped to validate and coach · Tools and processes outdated · Low average deal size · Slipping deals · Sales cycles are too long · Can't get relationships at executive level · Not generating enough leads · Too many IT resources to meet reporting requirements · Data is in multiple systems

### 3.4 · Person-to-card on the account map, read from the panels

Goal asks **Who is the Key Player responsible for this Goal?** — where the opportunity map asks for the Decision Maker. Initiative asks **Who is responsible for the success or failure of the Project/Initiative?**, unchanged. Pressure and Obstacle ask **Who is impacted?**, unchanged. Every panel carries **Who told you about this?**, unchanged. **So the informer, impacted-by and responsible-for structure is identical across maps, and only the named role of the responsible party shifts, decision maker at deal level, key player at account level.** The four-questions-two-stored-values finding carries to the account map untouched.

Also observed: the account Solution card carries the full enablement section stack live — Key Messages Discovery and Business Case, Case Studies and Customer Success Stories, Sales Tools, Competitive Positioning, Customer Value Stack — so the enablement join recorded for deal-level solutions exists at account level too. Initiative panels carry Desired outcome free text and the Low/Med/High priority, and an inline Solutions relation. Terminal states match deal level: Achieved, Resolved, Completed, Overcome, Implemented.

---

## 4 · Incident log · one accidental write in production, reverted

During the walk, a click intended for a card's help icon landed on the small circled glyph on an unconfirmed card, **which is the confirmation control** — the unconfirmed-status marker and the confirm button are the same pixel. The card *Pressure: Customer expectations for integrated AI and data privacy compliance* on the Salesforce, Inc. account plan was **confirmed under Matt Weisberg's login and reverted to Unconfirmed within about two minutes.** No field content was changed; the LastModified trail retains both touches.

**Recorded for three reasons.** Honesty: the walk was declared read-only and one click was not. Method: card text and named help links only, never the status glyph — the glyph is a write. And evidence: **a single stray click on a suggestion card produces a Confirmed insight with a named confirmer who never read it.** This is the mechanism behind the five-cards-in-twenty-seconds finding, demonstrated accidentally by the person building the system that exists to fix it. It goes beside that finding in rebuttals.

---

*End v0.2. Everything here folds into charter design at its next bump; this file is the capture surface, not the ruling surface.*
