# AAO Corrections and Change Record

> **The version lives on the stamp line below and nowhere else.** The H1 carried a version through v2.4 and went stale, which is the same defect the glossary carried through three versions, Architecture through one and Data Flow through two. Removing it is the only fix that cannot rot.

**v3.2 · 2 August 2026 · The scope session. The account/opportunity boundary is designed end to end, tested live on Black & Veatch, and ruled. One Process charter over a merged corpus. Stage scoping ruled read-wide, write-gated. In progress carries UNVERIFIED. Four new project documents hold the detail; this record holds the rulings and points at them.**

**Changed in v3.2.** A full working session with Matthew, every ruling tested against production where production could answer. **Detail lives in four documents filed today** — `aao-scope-resolver` (v0.4 by stamp), `aao-ontology-account-captures` (v0.2), and the two projection-surface reads, `spm-om` and `rm-im` — this record does not restate them.

### The Process charter · RULED · one charter, module-segmented configuration

**One Process charter over one merged corpus of assessment questions and sales-process qualifiers.** The charter never sees a module: its handed unit is the Evidence Contract, and a qualifier contract and an assessment contract are the same shape — proven, not argued, because extraction 1.1.0 ran the mini-rubric's six propositions with no module identity and never noticed. Graceful absence covers the unlicensed org (no configured processes → no qualifier contracts → never asked), and the capability matrix stays in the projection layer where the licensing ruling already confines it. **Configuration is segmented by module regardless: four surfaces — relationship map, insight map, sales process, assessment — each its own custom settings, none ever an open prompt template.** The charter is the unit of injection; the module is the unit of configuration; they meet at the contract. **One new rule: graceful refusal** — a read-permission failure on an unlicensed module's tables is treated exactly as absence, no propositions and a configuration note, never an error.

**SPM licensing recorded:** Opportunity Manager includes relationship map, insight map and assessment; Sales Process Manager is a separately licensed add-on, locked in-package for non-licensees. The design is indifferent by construction, and unlocking modules later changes discovery and projection scope with zero charter changes.

### Stage scoping · RULED · read wide, write gated

**Reading is never stage-gated.** Every pass listens against the deal's whole rubric, including questions standing Yes, because a Yes can be undone by a tune change and no model ever chooses which answered questions to keep watching — attention selection by inference is an integrity hole. **Writing is stage-gated:** projection touches only qualifiers at or behind the open stage, ordinary writes only where the answer is not Yes; a standing Yes moves only through demotion (machine-written) or contention (human-written). **The watermark seam dissolves under claims-first:** evidence for a future-stage qualifier is claimed the day it is heard; when the stage opens, projection catches up from our own answer rows in one deterministic sweep, no transcript re-read. The open stage is a field read: the Altify Opportunity stamps process, stage, and a dirty formula.

### The qualifier projection surface · read whole, and one ruling

From the SPM/OM projection read (filed): **`ALTF__Qualifier_Answer__c` is the target** — required Altify Opportunity lookup, optional lookup to the global qualifier (not the placement), composite key for idempotent upsert, Comment at 32,768 characters so the citation budget problem does not exist on this surface. The status vocabulary is org-global: **No, In progress, Yes — there is no Unknown slot. RULED: In progress carries UNVERIFIED**, because both mean the same fact — something was said, the work has begun, no longer nothing and not yet established. Consequence: null stays never-asked, In progress is asked-and-open with the citation in Comment, so the qualifier surface preserves asked-versus-never-asked more legibly than the assessment surface does. Human-written In progress rows (648 in production) are human-authored and never demoted.

**Per-question answer labels exist on the assessment side only** — `ALTF__Yes_Label__c` / `ALTF__No_Label__c`, forty characters, per question, no Unknown label, nothing per-question on SPM. **They are authored rubric text and discovery reads them into the evidence contract** as qualifying-evidence guidance; the slot-is-API-value law is unchanged.

### The account/opportunity boundary · opened, fed, and ruled

**The two maps are one schema with two fill conventions**, read from 40,350 rows: Buyer Role is opportunity-only in practice (40.1% vs 1.6%), Decision Orientation account-only (25.7% vs 3.1%), Support/Political/Coverage on both, all five insight types on both in near-identical mix. **The reopen of People and Problems is one section each — a map-scope parameter injecting that scope's question set** — because the vendor authored the account rubric already and the label enumeration recovered it.

**The account ontology is captured whole** (filed): Decision Orientation's five values from the wizard; the five account lane definitions with the causal chain authored into them in prose; the account admission tests, where **decision maker becomes key player and personal goals become the executive's business goals** — that substitution is the whole AM/OM axis; Obstacle and Solution tests identical across maps, consistent with the labels. **The scoped-out ruling on Decision Orientation is qualified:** humans-only survives at deal level; at account level the definitions become our authored ontology, Buyer Role's shape, `Inferred_Pending` until ratified. **Owed to the seed: the account-side label records** (AM Support four, AM Political three, the AM insight-test nine) **plus Decision Orientation's five values.**

**The scope stamp law · RULED, generalizing the opportunity stamp.** Every machine-written row carries exactly one scope, deal or account, taken from the evidence's own resolved scope, never inferred across. Deal evidence never writes account maps; account evidence gains its legal home. Consequences owed to the field tables: Source's opportunity lookup goes nullable under a scope family law (account always required), and account streams get their own engagement category, which the neutral-rate ruling anticipated.

### The scope resolver · designed, tested live, ruled · detail in its own document

ECI's related-record stamp is inference and unstable — the same recurring meeting stamped to the account twice and an opportunity three times in five weeks; a CSM's account call filed under a $55k deal whose transcript never mentions it — and 75% of customers have no ECI. **The resolver:** the two-key lock (owner-role via a setup-time-ratified role map, and the content read against our authored sided ontology — both always run, neither resolves alone, agreement resolves); traversal as interpreter's evidence (the account-map check deterministic, ownership suggestive only under CPQ/SAP); the which-opportunity match against the closed candidate set of the account's open opportunities, **weighted by curated rows never bare membership** — Altify cloned all 44 account rows onto the B&V deal map at creation and only nine were ever touched; speakers as tiebreak; flag at one in a hundred. **Tested live on the B&V call: dual scope, account-primary with expansion seeding, which-opportunity resolved correctly by agreement of both reads.** **Dual-write ruled:** both homes named, ECI's failure was singularity, not the pick. **Net-new participants on a dual-scope call are added to BOTH maps** — coverage is a claim, presence establishes it, and it is scope-symmetric — with every dimension beyond coverage establishment-gated per scope. Open by design: whether scope ever resolves per claim.

### The harness sequence · Matthew's, and it holds after everything above

**People harness first, opportunity-level, RM-only shaped** — a quarter of customers run relationship map only, so RM working is approximately a v1. Then People + Problems + Politics at opportunity level (~half of customers), then account-level RM/IM, then the comprehensive OM/SPM harness, which is deliberately on the back burner. **The People harness waits on exactly two rulings, owed to Matthew as options: the rung derivation from the nine Support propositions (the tree's mapping table has never been authored and cannot be read from the org — the wizard logic is UI code), and the citation budget on the 1,024-character shared map note (open term 8 since v1.6).** The watermark exclusion experiment runs inside the harness, not before it.

### Charter-ledger correction, so nobody inherits the slip

**Politics is open, not closed** — People closed except the persona emission, Problems closed, Politics confirmed no-vendor-ontology but unopened. **The Process charter has a ruling and no section**; today's session is its content, and the section is writing, not deciding.

### Named open, new this session

**Licensing seat-gaming, Matthew's catch:** if pipeline scope follows the licensed opportunity owner, assigning every opportunity to one licensed owner runs the org on one seat. The scoping read (owner-licensed vs caller-licensed) needs its own ruling before pilot pricing. **Dual-scope discovery residue:** per-claim scope. **The D360 ingestion ruling owed:** match rules for foreign-transcript participant resolution, exact-email only, slow lane only.

### Incident, disclosed

During the read-only production walk, one click meant for a card's help icon landed on the confirmation glyph — they are the same pixel on an unconfirmed card — and confirmed an insight card under Matthew's login; reverted to Unconfirmed within two minutes, both touches in the audit trail. Logged in the captures document. The mechanism is itself evidence: one stray click manufactures a Confirmed card with a named confirmer who never read it.

---

**v3.1 · 2 August 2026 · The corporate reconciliation. All six corporate documents read whole. Criterion Text is reversed, LAW #1 breaks two things in the set, and the sourcing ruling closes the glossary's own open term.**

**Changed in v3.1.** The six current corporate documents were opened by exact path and read end to end: Architecture v3.0, Glossary v2.1, Object Model v2.1, Data Flow v2.4, Computable Share v1.6, Theory v1.4. **Note the filename hazard immediately: the glossary file is named `aao-glossary-v2_0.md` and is stamped v2.1.** Read the stamp.

**Who this is for.** Whoever carries these results into the corporate documents at each one's next bump. This record supersedes them where they disagree. **Every item below names which document changes and what the new sentence has to say.**

**The build journal was read before this was written**, 49 sessions of it, and the reconciliation is section 7. **It changed two things in this record and found a defect in the journal itself.** No build-state number appears here that the journal does not carry.

---

## 1 · The assessment proposition is BOTH fields · RULED · and it reverses a correction three documents carry

**Matthew's ruling: `ALTF__Criterion_Text__c` and `ALTF__Long_Question__c` are equally important, and together they usually make more sense than either alone. The proposition is the pair.**

**This reverses a correction that is stated as a correction in three places.** Architecture v3.0: *"The proposition text is `ALTF__Long_Question__c`, not `ALTF__Criterion_Text__c`. Correction. Criterion Text is described in the schema as a title."* Architecture v2.9, generalised: *"the sentence is the proposition and the display name is never read."* Glossary vocabulary mapping: *"Criterion Text — **A title, never the proposition.** A short phrase capturing the essence."* And the glossary's own v1.5 changelog: *"every earlier version of this table was wrong."*

**This is the fourth position that mapping has held**, which is itself the finding. It read Criterion Text as the proposition before v1.5, Long Question from v1.5, carried both rows until v1.6 removed one, and is now the pair.

### Why it went wrong, read from the field describe rather than argued

**The field documents itself two ways and the record read one of them.**

Its **description** reads: *"Title text for this assessment question - generally a short phrase capturing the essence of the question, such as 'Compelling Event' or 'Access to Funds'."* That is the sentence Architecture quotes.

Its **inline help** — the text an admin actually sees while configuring the rubric — reads: *"This is the text of the criterion, i.e. 'Is there a compelling event?'"*

**So Altify tells the schema reader it is a title and tells the admin it is the question.** A design that reads only the description inherits one org's filling convention as a law. That is the standing hazard arriving through field metadata rather than through data, and it is a new face of it worth recording: **read a field's inline help as well as its description, because they are written for different readers and can disagree.**

### The asymmetry that makes the old ruling unsafe rather than merely incomplete

**`ALTF__Criterion_Text__c` is required. `ALTF__Long_Question__c` is not.** Read from the org, 2 August.

So the corporate record keyed the proposition on the **optional** half of the pair and demoted the half that always exists. In an org whose admin followed the inline help, Long Question is empty and **there is no proposition text at all** — the corpus reads as a set of questions with no sentences, and nothing detects it.

### The rule, stated so it is buildable

**The proposition is Criterion Text plus Long Question where Long Question is populated, and Criterion Text alone where it is not.** Criterion Text is required so it is always present; the pair degrades to a singleton in one direction only and never in the other. **Both halves are stored byte-exact and neither is ever paraphrased into the other.**

### What has to change, per document

**Glossary.** The vocabulary-mapping row *A title, never the proposition* is wrong and marked wrong in place. Both rows become one entry: the assessment proposition is the pair. **Do not delete the history** — this mapping has now been wrong in four different ways and the row should say so, because a reader who has seen two of the four needs to know which one is live.

**Architecture.** The correction paragraph is itself corrected in place. **The generalised sentence from v2.9 — *the sentence is the proposition and the display name is never read* — must not survive as written**, because it is the sentence that will be applied by analogy to the next field pair somebody meets.

**Object Model.** Neither field name appears anywhere in it, so nothing to correct and one thing to add: **proposition identity is composed from both fields**, which is a key-composition statement and belongs there beside Answer's key.

**Field Tables.** `AAO_Proposition_Short__c` currently reads *Display. Never read as the proposition.* **That is now the load-bearing field being documented as decoration.** Its reader column gains the charter and the hash.

**Computable Share.** No route assignment moves. **The proposition-short column of every question in its table is a title today and should be re-read as the pair**, because at least one route judgment was made against a sentence that was half the question.

### The change detector is broken by this and it is the sharpest consequence

Architecture describes the rubric snapshot's hash as covering *"the source field name, the scoping rows, and active question content"*, and lists the snapshot's payload as *"text, heading, scores, applicable plan types and the resolution route."* **Singular, undifferentiated *text*. No document in the set says which field is hashed.**

**If the hash covers Long Question only, an admin editing the required field changes what the question means and no contract supersedes.** The claim then answers a question that no longer exists, which is the exact residual the question-text fingerprint on Claim was added to catch — except the fingerprint would also miss it, because it is taken over the same text.

**Ruled here: the content hash covers both fields, and the fingerprint on Claim is taken over the same composition.** Whether the hash also covers guidance is a separate question and is **not settled** — see the open list.

> **Recorded as an inconsistency in Architecture, found while reading for this.** The document states two different hashes at two different grains and reconciles neither: one keyed *org Id × question record Id × content hash* (per question), and one covering *source field name plus scoping rows plus active question content* hashed together (per org, whole config). Both are called the change detector. **They are two mechanisms and the set should say so, or an implementer builds whichever one they read first.**

---

## 2 · What LAW #1 breaks in the corporate set

**LAW #1, ruled in v3.0: nothing may depend on an ALTF package version, and the system runs with Altify absent.** Read against the corporate set, it breaks two things. One is a documentation gap and one is a live v3.0 ruling.

### 2.1 · The version-independence sentence was wrong as written, and Matthew's correction replaces it · RULED

Architecture states: *"no Altify API name appears anywhere in our code or metadata, reads or writes. Field names are looked up at run time."*

**Ruled wrong by Matthew, 2 August, and the reason is practical rather than doctrinal: it is not possible to query properly without naming what you query.** The applicable-set chain, the persona target, the licence read — all of them name ALTF API names because SOQL requires it, and no resolution layer exists or should. An earlier draft of this section proposed building one; **that proposal is withdrawn.**

**What LAW #1 actually requires is three things, each already law elsewhere in the set, and the wrong sentence was a conflation of them:**

1. **No metadata is ever added to any ALTF object** — no field, no trigger, no logic. That is what would make our package version-dependent, and it is the absolute rule.
2. **No dependency on a package version** — no minimum, no version key, no behaviour that differs by release.
3. **Graceful absence** — an ALTF object or field that is not there produces no propositions and no error, which is what makes reading by name safe in an org where the name resolves to nothing.

**Reading a stable API name is not a version dependency.** The ALTF API names have been stable for five years, and when this package reaches engineering, field and object API names will be aligned for coordinated updating across packages — which is the correct place for that coupling to be managed, not in a runtime indirection layer.

**Architecture's sentence is marked wrong at its next bump and replaced with the three rules above.**

**One design thought recorded with it, Matthew's, connecting to an open item that already exists.** A customer adding a custom field to an ALTF object that a charter must read — or either package needing a change the other has not shipped — points at a **per-charter schema injection surface**: configuration that tells a charter what to read beyond what it ships knowing. Object Model already carries this as the open **per-org charter overlay** (*"injectable natural-language sections for orgs whose ontology drifts from what charters read; rule-data family, sibling of Evidence Contract"*), and the ontology override built in session 49 is its first shipped instance. **The overlay item should be widened from natural-language sections to schema too, at Object Model's next bump. Open, not designed.**

### 2.2 · The licensed-seller filter returns empty with Altify absent · a v3.0 ruling, live

Architecture v3.0 rules licensed-sellers-only as **one of three global filters on the whole system**, and settles the read as `UserPackageLicense` joined to `PackageLicense` on `NamespacePrefix = 'ALTF'`. It defends the read as *"platform objects, so an upgrade cannot break the read."*

**That is version resilience and it is not absence resilience, and the document never addresses absence.** In an org with no Altify installed there is no `PackageLicense` row for that namespace, the licensed-seller set is empty, and **every opportunity is filtered out of the pipeline.** Under LAW #1 as ruled, the system currently processes nothing in exactly the orgs LAW #1 exists to serve.

**The pattern for fixing it already exists in the set and was simply never applied here.** Data Flow draws the Altify Opportunity as a gate rather than an assumption: loop one runs against a bare opportunity with no Altify record at all, loop two abstains and flags. **The seller filter needs the same treatment — a gate with a defined behaviour when the read returns nothing, rather than a filter that silently returns nothing.**

**What that behaviour should be is a decision and is left open**, because it is a scope question rather than a mechanism question: with no Altify licence to scope on, either every opportunity is in scope, or scope comes from a filter we own, or the system declines to run until an admin defines one. **Options and costs are owed to Matthew as a separate item; nothing else waits on it.**

### 2.3 · What LAW #1 does NOT break, recorded so nobody re-opens it

**Record-sourced propositions are untouched.** Assessment questions and sales-process qualifiers are records in the customer's own org, read at runtime by SOQL. Nothing about them keys on a package version. The glossary's *a customer on a 2014 version or a rewritten rubric works without configuration* stands exactly as written for this half of the corpus.

**Graceful absence already covers the schema-sourced dimensions.** A dimension absent from the org produces no propositions, never an error. That is feature detection and it is what LAW #1 asks for.

**The parent split is already absence-safe.** Loop one commits to the standard Opportunity and needs no Altify record; only loop two requires one and it abstains honestly.

---

## 3 · What the sourcing ruling closes, and the sentence it marks wrong

**The v3.0 ontology ruling closes two items the glossary explicitly holds open**, and they must be closed in the glossary rather than left to be discovered as stale.

**Open term 14, verbatim:** *"How discovery obtains the guided-question text. The questions are unreachable from Apex... Two options are written up in the corrections record with a recommendation. **Until it is ruled, no document in this set states a sourcing mechanism.**"* **Ruled. Neither option won; the ontology ships as our own seed reference data, assumed universal, overridable per org by configuration.**

**The Guided Question entry**, which carries the same *not ruled* sentence inside a term definition. It gains the mechanism.

### The sentence that must be marked wrong, and the exact narrowing

Rubric Discovery is built on this, and it appears in the glossary and again in Data Flow's stage notes:

> *"The package ships no questions, no field names, no picklist values, and no help text."*

And in the glossary's definition of Proposition: *"Its text is never authored by us and never ships in the package."*

**This is now false for schema-sourced propositions and remains exactly true for record-sourced ones.** The narrowing is precise and should be written as a narrowing rather than a reversal:

**The package ships no *record-sourced* questions — no assessment criterion text, no qualifier text, no field names, no picklist values, no help text. It ships the schema-sourced ontology as seed reference data, overridable per org, because that text is unreachable from the runtime that needs it.**

**Why the narrowing is honest rather than convenient.** The reason Rubric Discovery exists is that a customer who rewrote their methodology must still work, and their methodology is the record-sourced half — the questions they authored, in their records, readable. Altify's packaged wizard text was never that. **Discovery keeps every guarantee it was built to make.**

**And the detection objection dissolves rather than being accepted.** Every rejected sourcing option was faulted for being unable to know its text was wrong, and that fault existed only because each one claimed to be reading the customer's questions. **The seed design claims nothing it cannot back:** we ship a default, show it to the admin in sentences, and they confirm or revise.

### Already consistent, no change needed

**Computable Share v1.6 routed the dimension ontologies before the sourcing was ruled and the routes survive it unchanged:** Coverage P, Support E, Political Status E, Buyer Role authored by us landing `Inferred_Pending`. **A route is a property of what a proposition needs, not of where its text came from**, which is why nothing moved. Recorded because it is a useful confirmation that the seam was in the right place.

---

## 4 · The qualifier side, stated precisely — smaller than feared and different in shape

**Correcting a claim made in conversation on 2 August and never in a document: it is not true that the Process charter has never read a real sales-process qualifier.** All 44 mandatory stage-qualifier placements were read from production on 28 July, they collapse to **19 distinct sentences**, every one is routed in Computable Share, and they carry a three-way readability split plus two named patterns (compound sentences, and roughly half being first-person about our own actions, which sends them to the note door rather than the transcript door). **The content is read. The graph is not.**

**The object graph exists in exactly one sentence, in Data Flow's cold-start stage notes:** *"Stage is not a field on a qualifier. It lives on a junction: `Sales_Process` to `Sales_Process_Stage` to `Sales_Process_Stage_Qualifier` to `Sales_Process_Qualifier`. Reading the full rubric means walking that chain and ignoring stage. Reading the live set means adding the stage filter. Same data, two reads."*

**That is a placement statement sitting in the wrong document.** Architecture is authoritative for the inventory and where things live, and it does not carry the chain at all. **It should, at Architecture's next bump**, with Data Flow keeping the two-reads distinction that is genuinely a flow statement.

### What is still absent across all six documents

**`ALTF__Qualifier_Answer__c` appears in no corporate document at any version.** Data Flow says a verdict lands on *"the assessment answer or the qualifier status, both parented to the Altify Opportunity"* and names neither object. **`ALTF__Assessment_Answer__c` is likewise never named as an API name.** So the two projection targets of loop two are described only in prose.

**Our Answer's qualifier subject has no concrete target.** Object Model gives the natural key as *opportunity + qualifier* and stops. **`Qualifier_Status` is a declared Claim Basis cited type pointing at nothing**, which is consistent with it having no object behind it in any document.

**Never read, and named as never read:** `ALTF__Template_Qualifier__c` and `ALTF__Template_Qualifier_Details__c`. **A template layer above the qualifier means qualifier text may originate from a template a customer instantiated rather than being authored on their process** — a provenance chain no document mentions, and the same shape as a shipped seed, which makes it directly relevant to the sourcing ruling.

**Never mentioned anywhere:** `ALTF__Stage__c` (distinct from `ALTF__Sales_Process_Stage__c`) and `ALTF__Qualifier_Quicklink__c`.

**Object Model is behind Architecture on one qualifier item and should not be read for it.** It calls `ALTF__Sales_Process_Mapping__c` *"now load-bearing… this object's name suggests it may hold that link"* — which is inference about our own schema, forbidden by standing rule. **Architecture corrected this at v2.4: it was read on 28 July, eleven rows, plan-type strings to sales processes, and it does not hold the qualifier-to-condition link.** The fallback — a setup-time mapping charter — is the live path.

---

## 5 · Document-integrity defects, found by reading the set whole

Recorded because each one misleads a reader who is doing everything right.

**The glossary's retrieval warning is stale and self-defeating.** It reads *"Every heading in this file is stamped `gloss v2.0`"* while **eight headings carry `gloss v2.1`**. A reader applying the file's own stated test to validate a retrieved chunk **rejects every v2.1 section, which is all four of its v2.1 corrections.** This is the retrieval hazard the warning exists to prevent, firing on the warning itself. **Fix at the next bump and make the warning name no version at all.**

**Object Model counts memory tables twice and disagrees with itself.** Section 7 says seven; section 8 still says six. A v2.0 remnant not swept.

**Object Model calls the decision criterion both a fifth Claim subject and a fourth subject shape**, in the section title and the body.

**Architecture preserves a known defect deliberately and correctly** — the v1.8 changelog entry reading `arch v2.5`, which it cannot have said at v1.8, because an earlier bump replaced a string file-wide and overwrote its own history. **Named here only so nobody "fixes" it: it is evidence of a real failure mode and it is doing its job.**

**The corporate namespace has a structural problem the claude namespace does not.** Every bump writes a new file, so retired versions accumulate in project knowledge competing for relevance. **This is why retrieval served a stale glossary rather than merely being unlucky.** Two halves to the fix: delete retired corporate versions, which lose nothing because each live document carries the full changelog beneath it; and move corporate onto frozen paths at each document's next bump, as the claude namespace already does. **Matthew's, and it is a deletion, so it is not taken unilaterally.**

---

## 6 · Bump instructions, per document

**Glossary** — the largest. Criterion Text mapping reversed and its four-way history stated. Rubric Discovery and Proposition narrowed to record-sourced. Guided Question gains the sourcing mechanism. Open term 14 closed. Retrieval warning de-versioned. **Open term 13, the model-role naming decision, is still Matthew's and still open.**

**Architecture** — Criterion Text correction corrected, and the generalised *the sentence is the proposition* sentence withdrawn. The *no Altify API name anywhere* sentence marked wrong and replaced with the three real rules (no metadata on ALTF objects, no version dependency, graceful absence). The licensed-seller filter given absence behaviour. The qualifier object chain added to the inventory. The two hashes reconciled or declared as two.

**Object Model** — proposition identity composed from both fields. The Sales Process Mapping sentence struck against Architecture's read. The six-versus-seven and fourth-versus-fifth inconsistencies swept. **The qualifier subject given a concrete target once the answer object is read.**

**Data Flow** — the package-ships-no-questions sentence narrowed. The qualifier chain kept as a two-reads statement with placement moving to Architecture. Cold seed already correct per dimension.

**Computable Share** — proposition text re-read as the pair; no route moves. Its method-versus-this-org boundary is the best-stated version of the standing hazard in the whole set and should be left exactly as it is.

**Theory** — nothing to correct. Its v1.4 addition, that Altify's schema stores the answer and discards the reasoning, is strengthened rather than weakened by the Criterion Text finding: **the methodology authored two fields of question and the record kept one.** Same shape, fourth instance.

---

## 7 · The build journal, read · what it confirms, and the defect at the top of it

**Forty-nine sessions read.** The journal is doing its job: every org read is quoted verbatim, every assumption sits on the assumed list, and the owed list carries forward. Two things in it change this record and one is a defect in the journal itself.

### 7.1 · LAW #1 is built and checkable, not merely ruled

Session 49 built it. **`AAO_People_Question__mdt`, two fields — `AAO_Shipped_Text__c` DeveloperControlled and `AAO_Org_Override__c` SubscriberControlled, null until set — thirty-five records loaded byte-exact**, and the reader repointed. The byte-exactness tests passed unchanged against the new source, which is the check that mattered: they assert the hyphen and the spellings and never knew the source moved.

**And LAW #1 now has a test rather than a sentence:** the read returns nineteen guided questions with `Limits.getCallouts()` unchanged, and **the same query returns the ontology in an org that never had Altify installed.** That is the law made checkable, and it is the strongest single argument against every sourcing option that lost.

**Two platform facts established by deploying candidates rather than by reasoning, and they belong in the field tables.** `FieldManageability` accepts `DeveloperControlled`, `SubscriberControlled` and `Locked`, and rejects `PackageProtected`, `Upgradeable` and `SubscriberEditable`. The type-level enum is a different one, `SetupObjectVisibility`, accepting `Public`, `Protected` and `PackageProtected`. **`PackageProtected` is valid on the type and invalid on a field** — the kind of asymmetry that reads as obvious once seen and would have been wrong if assumed.

**One item is unverifiable in this org and is named rather than assumed:** what a package upgrade does to a subscriber's edit, per manageability. There is no packaging org, no packaged version and no upgrade to observe. **It joins module licensing on the list of things this org structurally cannot answer** — and the two-field shape was chosen so the answer is never needed, because the reader prefers the override only where it is populated and null is not a value. **A design that leaned on manageability semantics would have rested on an untested claim, which is the capability law's own prohibition.**

### 7.2 · The journal's Current state block is thirty-seven sessions stale · DEFECT

**The block stops at session 12.** It reports *128 AAO tests, 128 passing* and, above that, *99 AAO tests, 99 passing*; the org has been at **171 tests, 171 passing** since session 48, verified by running them rather than carried forward. It describes discovery landing in session 12 as the newest thing and says nothing of the ontology, the People and Problems charters, the missing-relation flag, the licence read, the label enumeration or LAW #1.

**The journal's own rule is that Current state is the one part ever rewritten.** It has not been. And it is the first thing the brief tells a cold agent to read, so **the stalest text in the repo sits at the top of the document whose purpose is to prevent staleness.**

**This is the same defect as the end lines the corporate documents fixed by de-versioning, and the same defect as the glossary's retrieval warning** — a summary that must be maintained by hand, in a file whose every other line is append-only, will rot. **Recorded as a finding rather than a rebuke: the append-only discipline worked perfectly and the one mutable block failed, which is an argument about mutable summaries rather than about anyone's diligence.**

### 7.3 · Two conventions for filenames, and they are opposite

**The project holds frozen paths; `docs/` holds stamp-named files.** Session 49 records the collision plainly: the sync arrived as `aao-corrections-v2_0.md` carrying v3.0, and **filing by filename would have regressed corrections from v2.9 to v2.0** and reinstated two documents already held. CODE files by stamp and deletes the stale name.

**Both conventions are coherent and neither is wrong.** The project needs frozen paths because a cross-reference must stay openable. `docs/` has no cross-references to break and gains from the filename matching the stamp. **What is wrong is that no document said there were two**, so the build brief's repo-layout block was written against the project's convention and does not describe the folder it claims to describe. Corrected at the build brief's next bump, together with `MANIFEST.md`, which sits in `docs/` and not at the repo root as that block says.

**Consequence for the handoff, adopted now:** files in the context zip carry their stamp name, so CODE files them directly and deletes nothing.

### 7.4 · A date drift worth one line

**Journal sessions run to 2026-08-04 while every corporate and working document is stamped 2 August 2026**, and both record the same days. Nothing depends on it today, and any chronological reconstruction across the two sets will be wrong by two days until one is corrected.

---

## 8 · Owed before this is finished

**Three reads that would close open items cheaply:** `ALTF__Qualifier_Answer__c` and `ALTF__Assessment_Answer__c` described; the template qualifier pair read; and `ALTF__Help__c` on assessment criteria read, which the glossary has carried as open term 9 since v1.4 and calls *the first draft of every evidence contract*.

**One decision owed to Matthew, options and costs, not opened here:** what the seller scope filter becomes in an org with no Altify licence to read.

**One rewrite owed to CODE:** the Current state block, from the org rather than from the sessions below it.

---

**v3.0 · 2 August 2026 · LAW #1, and the end of the label sourcing question. The ontology becomes ours, seeded and injectable, and stops being a read of anybody's package.**

**Changed in v3.0. Matthew's ruling, and it retires the whole option set rather than choosing from it.**

### LAW #1 · No dependency on any 1GP package version, ever

**The system works without Altify installed, and on any Altify package version.** Nothing we build may key on an ALTF package version, require a minimum version, or behave differently because a version differs. Version compatibility is **feature detection, never a version check** — which the Glossary already ruled under Graceful Absence. **This states it at full strength and places it above the sourcing question rather than inside it.**

**Three options and one late addition are all killed by it, and that is the point.** Packaged text keyed by package version keys on a version. The Tooling callout reads one specific org's installed package. And the proposal to unprotect the guided-question labels in our own package — which would have made `System.Label` resolve from subscriber Apex with the localization overlay arriving free, no callout and no setup action — **reaches only orgs that upgrade to that release, so it is a version dependency wearing the costume of a fix.** It was the strongest option on fidelity and the clearest violation of the law, which is the useful thing about it.

**The Publisher read is withdrawn as a design input.** `Publisher` carries `MajorVersion` and `MinorVersion` for `ALTF` and returned **Altify 9.19** on 2 August over the standard data path rather than the Tooling path. Whether Apex can see it no longer matters, because nothing may key on the answer. **Recorded as a fact about the org and removed from the decision.**

### The ruling · the ontology is ours, assumed universal, overridable per org

**Where the labels cannot be read, the recovered question text is treated as ontologically universal**, shipped as our own reference data — **unless configuration within the charters says otherwise for that org.** So **People and Problems must both accept injection of proposition text per label**, at setup, by configuration rather than by code.

**This is not a new mechanism. It is the ontology injection point ruled in charter design v1.1, generalised.** That ruling already said: per-org, per-type authored description, defaulting to what was recovered from the package, confirmed by the admin through the recipe pattern's sentences-not-code surface. It was ruled for insight card types. **It now governs every proposition in both charters, and the default stops being *what we read from this org* and becomes *what we ship*.**

### What this fixes that no other option did

**The detection objection dissolves rather than being accepted.** Every option was faulted for being unable to tell that its text was wrong. That fault existed only because each one claimed to be reading the customer's own questions. **This design claims nothing it cannot back:** we ship a default, we show it to the admin in sentences, they confirm or revise. An org that has customised says so at setup, which is a configuration step rather than a silent failure. **Detecting that we do not know stops being load-bearing, because we are no longer asserting that we know.**

**And it survives the standing hazard, which nothing else did.** Roughly eighty percent of installs have no Altify history and some will have no package at all. **Every earlier option produced no ontology whatsoever in an org with no ALTF package**, because every one of them was a read of that package. Under this ruling the evidence engine runs there unchanged and only projection degrades — the property already ruled in the licensing work, now earning its keep for a case nobody designed it for.

### What it costs, declared rather than discovered

**The recovered wording is Altify's and we now ship it.** Byte-exactness still binds: `organisation` against `organization`, `jeopardise`, the stray hyphen in `_11`'s `-including`, the curly apostrophes — all ship exactly as read, because **a normalised quote is a paraphrase whoever is holding it.**

**A customer who has rewritten their wizard questions and never visits the config surface gets ours.** Same residual the packaged-text option carried, and smaller here, because the surface exists and sits inside setup rather than behind an optional upgrade nobody knows to enable.

### The build consequence, and one trap that is the trap we just walked into

**Seed text ships as custom metadata — not as data, not as labels.** Custom metadata is packaged, upgradeable, queryable from Apex with no callout, and editable in Setup, which is what makes the override a configuration motion rather than a deploy. **Discovery composes Evidence Contract rows from it exactly as it composes them from rubric records today; the assembler's seam does not move, only what feeds it.**

> **Ship the type and its records PUBLIC, never protected.** A protected custom metadata record in a managed package is invisible and uneditable to the subscriber — **which is precisely the failure we have just spent a day ruling around, reproduced inside our own package by one checkbox.** 2,576 of 2,930 ALTF labels are protected and that is the entire reason the ontology was unreachable. The same flag exists on custom metadata types, on their records, and on their fields. **Unverified, and it is the first check:** that a subscriber can read and edit our seed records from a managed context, tried from Apex rather than from whichever tool is convenient.

**One field-level question the ruling opens.** Evidence Contract records who decomposed a compound question in `AAO_Elements_Basis__c` and records **nothing about where the proposition text came from**, because until now there was one answer: read from the org. There are now two — our shipped seed, and the org's own injection — and the difference is visible to a seller, since a flag quotes the proposition and whether that sentence is their wording or ours changes how it reads. **Either a text-source discriminator on the contract, or the existing contract state carries it**: a seed lands `Derived`, an injected override lands `Ratified` by the admin who wrote it. The second adds no field and is probably right. **Owed to the field tables.**

### Recovered, and a one-way drift the handoff loop is supposed to prevent

**The demo run sheet exists.** It was listed as live from seed v3.0 onward, was not in project knowledge at any version, and was struck in seed v5.1 as possibly never having existed. It sits in CODE's repo at `docs/aao-demo-runsheet-v1_2.md`, committed at `c4d1ba2` in session 16 and unmodified since. **It was in the repo and never in the project**, and it went unnoticed for two weeks because nothing ever reads a file nobody remembers. Filed at v1.3 with three stale say-unprompted lines corrected.

**The distinction that was never written down, and its absence is why this was invisible: the project keeps every version, `docs/` keeps one.** A document in the project and not in `docs/` is ordinary. **The reverse is a fault.** Now stated in the build brief.

### A fourth face of read-by-pattern-filter-by-family, and this one is created by deletion

Deleting corrections v1.0 left dangling pointers, and **the sweep for them found one of three.** The build brief carried the deleted filename in its read order, in its repo layout block, and in the closing paragraph of what is known to be missing — where it named the file as authoritative over the four project documents. **A pointer to a deleted file that claims precedence is worse than a stale copy**, because a reader who follows it finds nothing and cannot tell whether the authority moved or was withdrawn.

**The root cause is a referencing style, not the deletion.** The brief named documents by a version embedded in a filename, while paths are frozen and the version lives on the stamp inside. **Every reference of that form was going to rot at the next bump whether or not anything was ever deleted.** Repaired in build brief v1.1, which now names each document by role with the filename as a locator only.

**So the rule has a fourth face: a deletion silently converts every pointer to it into a false authority**, and the guard that fires on zero results does not fire, because the pointers are still there and still read as valid. **Sweep the whole tree for a filename before deleting it, and read the list.**

---

**v2.9 · 2 August 2026 · Politics confirmed to have no ontology, by read rather than by memory. A third face of the pattern rule, and the guard gap it exposes.**

**Changed in v2.9.** CODE swept both families read-only against a stated total of 2,930 ALTF labels, so **every zero is a filter result rather than an empty table.** `%RELATIONSHIP_TYPE%` → 0. `%DETRACT%` → 0.

**Sixteen labels across influence and conflict, and every one is a UI string** — *Add Conflict*, *Influences*, *Influenced By*, *No Conflicts Set* — plus two mode help texts that are **interaction instructions rather than propositions**. *Select the contact this person influences* tells a user how to operate a picker; it never says what influence is or how a seller would know. **So Politics is authored by us from zero, `Inferred_Pending` until ratified, now demonstrated rather than assumed** — and with nothing to discover there is no vendor ontology to reconcile, no AM/OM split, no sparse numbering and no overlay, which makes Politics **simpler** than the two charters before it.

**The schema says it harder.** `ALTF__Contact_Influence__c` holds both kinds in one object, discriminated by a two-value picklist (`Conflict`, `Influence`), with an influencing contact, an influenced contact and an external key. **`ALTF__Contact_Conflict__c` does not exist. No strength, no basis, no note, no date — an edge is a bare triple.** That is the third instance of one pattern and it is now recorded as the product's own argument in **competitive rebuttals §8**: nine Support questions collapse to one picklist value, four person-to-card questions collapse to `Informer`/`Owner`, two relationship kinds collapse to a bare triple. **Altify's relationship layer stores the fact and never the evidence for it.**

### A third face of read-by-pattern-filter-by-family, and the guard does not cover it

**The package misspells a label.** `CONFCLIT_MODE_HELP_TEXT` — so `%CONFLICT%` returns five labels and misses the only one that mattered. What found it was sweeping the whole `%HELP_TEXT%` family and reading the list.

So the rule has three faces now: **an iterator under-collects** because numbering is sparse; **a family pattern over-collects** because edit guidance shares it; and **a targeted pattern under-collects because the name you are looking for may be wrong.** The rule that covers all three: **sweep wider than the question, read the list, filter after.**

> **And the third face is not covered by the discovery-filter-fault guard, which is worth stating rather than glossing.** That guard fires on a populated table returning **zero** matches. `%CONFLICT%` returned five. **A non-empty result missing the one row you needed looks exactly like success**, and no guard we have detects it. The family guard CODE built for the guided questions catches this class only where an expected shape can be declared in advance, which is possible for a numbered set and impossible for a set you have never seen. **Some misses are only caught by a person sweeping wider than the question and reading the output.** Recorded as a limit rather than pretended away.

**v2.8 · 2 August 2026 · The labels are unreachable from Apex. A capability law, the third instance that forced it, and the sourcing decision that follows.**

**Changed in v2.8. CORRECTED: v2.6 and v2.7 both say a pattern query recovers any org's question set at install with no human in it. That is true of the Tooling API and false of Apex, and the product runs in Apex.** `ExternalString` is a Tooling API object — `Invalid type: ExternalString` from Apex SOQL. `System.Label.ALTF.<name>` is shut too, because **2,576 of the 2,930 ALTF labels are `IsProtected = true`, including every guided question**, and a protected managed-package label is invisible to subscriber Apex. Only 354 are public. Found by CODE trying to compile it.

### The capability law · RULED, and it took three instances

**A capability claim is unverified until it has been tried from the runtime that will make the call, not from whichever tool was convenient.**

Three design sentences about our own reach have now been wrong in the same direction: **Coverage as a frozen query** (participation is not queryable), **`required` on Source** (a required field cannot express a conditional law), and **labels by pattern query** (Tooling can see them, Apex cannot). Each was a claim about what the platform would allow, asserted without asking it. Each was also a true fact generalised to a place it did not hold — the Tooling API really does return those labels, and nothing about that tells you what Apex can see.

**This is narrower than *evidence over inference, including about our own schema*, and it needs its own line**, because the schema rule is satisfied by reading the org and this failure survives reading the org. What it does not survive is trying it from where the product will stand.

### The sourcing decision · Matthew's

> **CLOSED IN v3.0, and none of the options below won.** LAW #1 forbids any dependency on a package version, which kills the first two outright and kills the recommendation with them. The ontology is shipped as our own seed data and injectable per org. **Retained below as the record of what was considered and why it was wrong**, per the rule that wrong text is marked wrong and never deleted.

**One fact reframes the trade: the question text is a property of the package version, not of the org.** It ships in the managed package, so every org on a given version carries identical text, and **only the localization overlay is org-specific.**

That also settles a rules question before it is asked. *The package ships no questions* exists so a customer who rewrote their rubric still works, and their rubric is the **record-sourced** propositions — assessment questions and qualifiers — which are genuinely readable from their records. Altify's own packaged wizard text is not that.

| Option | Fidelity | Cost |
|---|---|---|
| **Tooling API callout at setup**, Named Credential to the org itself, frozen on the contract, re-read on hash change — the recipe-ruling shape | Full, including overlay | **Zero admin action becomes one**, and Tooling scope is broad enough to be an InfoSec conversation |
| **Package text keyed by version, shipped as reference data** | Packaged wording only; overrides undetected | Zero admin action |
| **Recommended: the second, with the overlay read as an optional upgrade** | Full where a customer has customised | Zero in the common case; **per-customer configuration rather than an architectural fork**, the same shape as polling versus Change Data Capture |

**The honest cost of the recommendation, declared rather than discovered:** an org that overrides a question label without enabling the upgrade gets the packaged wording. Given 56 overrides exist here and **none touches a question**, that is rare — but *rare* was the reasoning that produced two wrong assumptions today, so it is declared loudly and never assumed.

**None of this touches the assembler.** `AAO_PeopleOntology` was built with the seam in the right place: whoever performs the read, the rules that turn labels into contracts live in one place. **This is a sourcing decision, not an architectural one.**

### Built with it · 171 tests green

**The family guard is the law that would have caught v1.7.** Expected shape is declared (Support 1, 2, 4, 5, 6, 7, 11, 14, 16 and so on) while **the text always comes from the org**. A short read refuses and names what is missing, and the test removes exactly the four questions the walk missed and asserts the refusal names `6, 7, 11, 14`. The discovery-filter-fault law, pointed at labels, with our own failure as its fixture.

**Byte-exactness is tested** on `organisation`, `jeopardise` and `_11`'s stray hyphen. **Routes:** Coverage P, Support and Political E.

**`Subject_Person` only where the question says *told you*** — `_2`, `_4`, `_6`. **Not `_16`**, and CODE's reason is sharper than v1.8's: `_16` asks whether **the seller** holds evidence, so requiring the subject to have said it would make the question unanswerable rather than merely strict.

**A new distinction worth keeping · the question is authored, the decomposition is ours.** `_4`, `_5` and `_16` are compound, so their elements are our split rather than Altify's authoring, and they land `Inferred_Pending` / `Awaiting_Ratification` while the rest land `Authored`. **Altify authored the question; we split it; a human ratifies the split.** `AAO_Elements_Basis__c` therefore records who decomposed, never who wrote the text.

---

**v2.7 · 2 August 2026 · The full enumeration, 68 labels with the overlay applied. Charter design v1.7's ontology is SUPERSEDED and must be rebuilt from labels, not from the walk.**

**Changed in v2.7.** CODE produced the owed enumeration. **The walk recovered a minority of an authored set that is larger, split per map, and sparse in a way that made a partial read feel complete.**

**Per map, opportunity side:** Support **nine** (`AM_OM_` 1, 2, 4, 5, 6, 7, 11, 14, 16), Political Status **seven** (four shared as `AM_OM_` 3, 4, 6, 7 plus three opportunity-only as `OM_` 1, 2, 9), Coverage **three** (`AM_OM_` 1, 2, 3). The account map differs: Political takes its own `AM_` 1, 2, 9, and Support takes `AM_` versions of 1, 2, 4, 6. **So for Political Status no single list is the ontology**, and for Support four of the nine are map-specific.

**Why the walk felt complete, and it is worth naming as a detection rule.** Numbering is sparse **per family rather than globally**, and **Coverage is the only dense family** — one, two, three. It is also the only family the walk recovered whole. A partial read of a sparse set looks exactly like a complete read of a dense one.

**`_6` and `_11` are near-duplicates with different wording and a stray hyphen** — *has this person told you they prefer an alternate solution, including an internal solution or do nothing at all* against *does this person prefer an alternative solution -including an internal solution or nothing at all*. **They are two labels and stay two propositions. Collapsing them is paraphrasing**, which is the thing the verbatim rule exists to forbid, and an authored set after years of edits is supposed to look like this.

**The insight admission tests are supersets too, and unevenly.** Solution carries four, `SOLUTION_HELP_TEXT_1..4`, matching §2.2 verbatim, and `SOLUTION_DEF_AM` / `_OM` exist and are identical, which closes an owed item. But **Goal, Pressure and Initiative each carry six** — `_1.._3` plus a separate account-map set `_AM_1.._AM_3` — while **Obstacle carries three with no AM variant at all.** The AM/OM split runs through the insight side and is uneven across types, which no walk can reveal because a walk sees one map at a time. *(That asymmetry is itself informative: obstacles are deal-local, while goals, pressures and initiatives exist at account level too.)*

**The overlay is empty here, and that is a finding rather than a licence to skip it.** All 56 org overrides are `AM_*` UI rebranding and **zero touch a question, help-text or definition label**, so effective text equals packaged text in this org. **It must still be applied in code**, because empty here cannot be assumed empty in a customer's org — the standing hazard, stated once more.

**One pattern hazard from both directions, and it generalises.** `%HELP_TEXT%` **over-collects**: `PRESSURE_EDIT_TYPES_HELP_TEXT` and `SOLUTION_EDIT_HELP_TEXT` are edit-form guidance rather than admission tests. Sparse numbering means an iterator **under-collects**. **So an assembler reads by pattern, filters by family, and is loud when the families do not match what it expected** — the discovery-filter-fault law applied to labels.

**CHARTER DESIGN v1.7's RECOVERED ONTOLOGY IS SUPERSEDED.** Its Support and Political sets are a partial walk presented as the ontology. **It must be rebuilt from the enumerated labels with the localization overlay applied, never reconstructed from the walked strings**, because stitching a verbatim set from fragments is paraphrasing with extra steps. Nothing is to be built against v1.7's question sets. The full enumeration lives in CODE's journal, session 42.

**v2.6 · 2 August 2026 · The wizard questions ARE queryable — §2.1 corrected, §5's open read closed, and the recovered Support set found incomplete.**

**Changed in v2.6.** CODE closed §5's open read and it comes back the opposite of what §2.1 recorded. **The question text is custom labels: `ExternalString` holds 2,930 ALTF labels, 26 of them `%GUIDED_QUESTION%`, plus the insight admission tests as `GOAL_HELP_TEXT_*` and `PRESSURE_HELP_TEXT_*`.** Discovery becomes a pattern query rather than a manual walk, which is what makes *discovered rather than paraphrased* true in a customer org rather than only here. Four consequences. **The account map and opportunity map ask different questions** — provider and your company against solution and your solution — which independently confirms the cold-seeding ruling and improves it, because the durable half is the account map's own proposition rather than a seed. **The numbering is sparse** (Support runs 1, 2, 4, 5, 6, 7, 11, 14, 16), so an assembler iterating 1..N silently ships a short rubric. **The recovered Support set is incomplete — nine questions exist against five walked** — so charter design v1.7 must be corrected against the enumeration rather than patched. And **discovery must read the localization layer rather than the packaged label**, because 56 overrides already exist in this org and the override lives in a different table, which is the answer-string hazard in a new place.

**v2.5 · 2 August 2026 · The licensed-seller read is settled from the org; package licence and module licence separated; what the permission harness proves and what it cannot.**

**Changed in v2.5.** CODE found the read that §4c recorded as owed, and it is platform rather than managed so nothing breaks on package upgrade: **`UserPackageLicense` joined to `PackageLicense.NamespacePrefix = 'ALTF'`** answers who holds a seat, per user, with 80 assignments in the sandbox. Two things follow. **`AllowedLicenses = -1` means unlimited**, so the seat pool cannot be used to infer scarcity and only the assignment rows tell the truth. And **a package licence is not a module licence** — it says the user may use Altify, never which of the four modules the org holds, so §4c conflated two reads and only one of them is now solved. Also sharpened: **the permission harness proves degradation, not detection.** A permission failure and a licence failure arrive as the same DML error, so *a projection failure never touches the claim, the flag or the roll-up* is fully testable today; *which modules this customer holds* stays unverifiable until a differently-licensed org exists. Numbers moved: **164 tests green**, and Claim Basis now has **four of eight cited types built**.

**v2.4 · 2 August 2026 · Adds scope, licensing and partial product ownership as a build phase of its own (§4c), and the Politics sequencing ruling (§4d).**

**Changed in v2.4.** **Three scoping filters become global rules**: licensed sellers only, opportunity types excluded by configuration, and **module ownership**, which is new and is not graceful absence — the objects exist because the package is installed and the customer is not licensed, so a write fails on permission rather than on absence. The shape uses a property already ruled: claims land on our objects and projection is what varies, so **a customer with relationship map only still gets the whole evidence engine.** The **admin error log** is the first admin-facing surface and needs expected-unavailable treated as configuration rather than error. **None of this is testable in Altify's own org**, which holds every module, so the harness is permission sets rather than a differently-licensed org. Also clarified: Opportunity and Account are never written and that is absolute, while **Contact remains toggleable exactly as originally designed** — toggle on, we write it and its children; toggle off, shadow persons persist and cannot reach the Altify map, because the map row's Contact lookup is required. **Politics opens on influence and conflict**, because that half needs only the relationship map.

**Changed in v2.3.** **Flags get no charter** — existence and clearance stay deterministic, and the nuance Matthew was reaching for lives in guidance, where it is already named as owed. **Contention splits three ways**, and the configurable part is authored at setup and frozen rather than run by a model each night, because Calculated Insights are immutable once shipped. **Persona goes in the People charter as a fourth emission**, additive only, which dissolves the cross-deal collision the schema would otherwise create.

---

**v2.2 · 2 August 2026 · The reconciliation. Everything from the 2 August ontology session, checked line by line against Architecture v2.9, Glossary v2.0, Data Flow v2.3 and this record's own v2.1 — sorted into what it confirms, what it corrects, and what it breaks.**

**Changed in v2.2.** A full session of design ran against a stale reading of the corporate record: project-knowledge retrieval served **Glossary v1.9 while v2.0 was current**, which is the retrieval hazard those documents warn about, working exactly as documented. The four current documents have now been opened directly rather than searched. **The session's work survives the check, with one apology, three corrections to the corporate record, and four things it broke that must reopen.** The corrections are the valuable half: one of them raises the standard for an entire class of proposition.

**Who this is for.** Same as v2.1: the corporate project's agent, carrying results back into the canonical documents. Stamped corporate documents as of this writing: **Architecture v2.9, Glossary v2.0, Object Model v2.0, Data Flow v2.3**, Theory v1.3, Computable Share v1.5. This record supersedes them where they disagree. Charter detail lives in `aao-charter-design` (now v1.8), field detail in `aao-field-tables` (v0.13).

---

## 0 · The apology, recorded because the lesson is the point

**Matthew said solution cards from line items were something we had already agreed to do. He was right and I told him it was parked.** Glossary Section J has carried it as settled: *Solution Card — two kinds. **Linked**, established by an opportunity line item through `Product2.ALTF__Solution__c`, cited by the line item record, free, state-established, no model.* Plus **Solution Coverage**: the set difference computed in Apex, missing cards **created silently and not flagged**, on observed data 3 of 94 line-item pairs had a card.

I checked charter design v0.5, found *quick-links from insights to solution cards* parked as guidance enrichment, and reported that as the answer. **They are different items.** The link from an insight to a solution card is guidance enrichment and is still parked. The creation of a solution card from a line item was ruled long ago. **The lesson is the one this record already contains twice: open the document, do not search it, and do not answer from the nearest-looking passage.**

**What survives from 2 August on solutions:** the card / edge distinction, which the glossary does not state — the card is state and the edge is evidence, and an edge asserting that a product addresses an obstacle can never come from a line item. And the unlinked-Solution flag, which is a **different gap** from the one the glossary declines to flag. The glossary refuses to flag *a line item with no card*, correctly, because the system just closed that gap itself. **Ours flags a card with no edge**, which nothing closes and nobody sees.

---

## 1 · What the session CONFIRMS

**The loop order is an invariant and the session respected it.** Loop one is Relationship, Insight and Link, committing maps to the standard Opportunity (`006`). Loop two is Assessment, reading the transcript **and the maps loop one just committed**, writing to the Altify Opportunity (`a0y`). Our People, Problems and Politics are exactly loop one's three charters under different names. **Consequence worth stating plainly: Politics is not "after" Problems, it is the third peer in the same loop, and loop one is incomplete until it exists.** Every assessment verdict computed today reads a map with no influence or conflict edges in it.

**Reconciliation's outcome routing matches what the session ruled independently.** Data Flow §1a: same verdict standing → reinforcement appends a receipt and the mirror is untouched; contradicting human-authored value → contention flag, never a write; partial element coverage → `UNVERIFIED` carrying the spans that exist. Those are the Problems charter's reinforcement rule and the annotation law, arrived at from the other direction.

**Coverage as state, not judgment, is consistent with the speaker-gate ruling already in v2.1** — a record has no utterer, so for basis State the gate records not-applicable and names the cited row rather than skipping.

**Buyer Role as assertion propositions is already the glossary's shape.** Section I: categorical dimensions are *assertion propositions — is X the Decision Maker, TRUE / FALSE / UNVERIFIED, with a span*. The session's ruling that we author Buyer Role's questions ourselves is the missing half, not a divergence.

**The three items v2.1 named as deliberately unsettled: two are now closed.** Charter output schemas for People and Problems are written. The machine-confirmation projection question is ruled as an autonomy level. **The Politics charter remains open and is now the only one of the three still standing.**

---

## 2 · What the session CORRECTS in the corporate record

### 2.1 · Glossary Section B is wrong, and this is the most consequential finding of the session

The glossary states, of schema-sourced propositions: *the field label plus the value set is the rubric. **Nothing else. There is no sentence to find, because Altify never wrote one.***

**Altify wrote one. Several, per dimension.** Recovered verbatim from production on 2 August by walking the *Help me select* wizard read-only:

- **Support · five questions.** Has this person expressed a preference for a specific solution? · Has this person told you they prefer your solution over all other alternatives? · Is this person willing to provide you helpful information when asked? · Does this person believe your solution is critical to their success and do they sell internally for you in your absence? · Is this person mentoring you by providing guidance, political insight, or competitive information?
- **Political Status · three questions, three-way options.** Does this person approve and sponsor initiatives, or do they execute projects after they are approved? [Approves/Sponsors · Executes · Not sure] · Do others seek this person out for advice and direction? [Yes · No · Not sure] · Does this person control the outcomes or are they called on to make it happen? [Controls · Implements · Not sure]
- **Coverage · three questions.** Have you or a team member met with this person? · Have you or a team member recently had multiple meaningful conversations with this person? · Do you or a team member regularly and routinely have high quality conversations with this person?
- **Buyer Role · no wizard.** Manual pick with a definition per value. The one dimension where we author.

**The glossary is right about the answer path and righter than it knew.** `_Answer__c` holding `Yes;Yes;Yes;Yes;No` is the wizard, not the question, and must never be read as proposition text. Production confirms it harder: a live row whose answer path resolves to **Supporter** under the recovered tree carries a stored value of **Mentor**, because the wizard has a *Select manually* toggle and a later manual pick leaves the old path behind. **The questions are the asset; the answers are exhaust.**

**Why this raises a standard rather than adding a fact.** Schema-sourced propositions have been running on a field label where record-sourced propositions run on verbatim authored text. That asymmetry is now closed. **Every dimension gets proposition text from the customer's own methodology**, discovered rather than paraphrased, which is the same law that governs the assessment side.

> **AMENDED IN v3.0.** The last sentence above is now half wrong and is corrected rather than deleted. **The text is not discovered from the customer's org, because it cannot be** — it is shipped by us as reference data and overridden by the customer at setup where they have customised. What survives, and it is the part that mattered: **the proposition is a verbatim authored sentence rather than a field label, and it is never paraphrased.** Where it comes from moved; what it is did not.

**CORRECTED IN v2.6, and the v2.5 sentence here was wrong.** It read *the text is in the managed package UI, not in any queryable table*, and closed with the Tooling API as an open read. **The text is queryable, it is custom labels, and CODE had already established this in session 33 — the finding never reached this record.** `ALTF__Translation__c` being empty and the platform `Translation` object holding only language enablement are both true and were the wrong places to look.

**`ExternalString` holds 2,930 ALTF labels**, and the questions sit under naming conventions that make them discoverable by pattern: **26 `%GUIDED_QUESTION%` labels** for the map dimensions, plus `GOAL_HELP_TEXT_*` and `PRESSURE_HELP_TEXT_*` for the insight admission tests and `*_DEF_AM` / `*_DEF_OM` for the value definitions.

**This is what makes *discovered rather than paraphrased* true in a customer org rather than only in this document.** A manual walk recovers one org's wizard; a pattern query recovers any org's, at install, with no human in it.

> **SUPERSEDED IN v2.8 and CLOSED IN v3.0.** Tooling can run that pattern query; Apex cannot, and the product runs in Apex. Under LAW #1 the point is moot: no read of the package may be relied on at all.

**Four consequences, and two of them are defects in what shipped today.**

**The account map and the opportunity map ask different questions, not translations.** `AM_SUPPORT_GUIDED_QUESTION_1` asks about a specific **provider**; `AM_OM_SUPPORT_GUIDED_QUESTION_1` asks about a specific **solution**. Q2 likewise: **your company** against **your solution**. Reading one for the other puts the wrong proposition text on a contract, which is the exact failure the verbatim rule exists to prevent.

> **This independently confirms the cold-seeding ruling and improves it.** §4c-era reasoning held that Support cannot carry across deals because its questions are about this deal's solution. **Altify encoded that distinction by authoring two separate question sets.** So the durable half is not a seed at all — it is the account map's own proposition, answered in its own right, about the provider relationship rather than this sale. Cold seeding does not attenuate account-level Support onto a deal; **the two are different propositions and both stand.**

**The numbering is sparse and is not a sequence.** Support runs 1, 2, 4, 5, 6, 7, 11, 14, 16. **An assembler iterating 1..N produces a short rubric that looks complete**, which is the discovery-filter-fault shape again: assume nothing about density, read what is there, and be loud when the read does not match.

**The labels are a superset of the walked tree, so the recovered set is INCOMPLETE.** Nine Support questions exist against the five recovered on 2 August, including *is this person vocal in their support of your competition* and *do you have evidence that this person believes your success will hurt their company or job*. **The wizard walk found the path taken, not the tree.** Charter design v1.7 presents five questions as the Support ontology and must be corrected against the full enumeration rather than patched by guessing.

**Discovery must read the localization layer, never the packaged label.** 56 localizations already override ALTF labels in this org, 55 with changed text, one consistent Account Manager plan to Book of Business plan rebranding. None touches the question labels today, but a customer can override any of them, **and the override lives in a different table from the label.** Reading `ExternalString` alone would author contracts from words no user of that org has ever seen. **Same shape as the `ALTF__Status_Answer__c` hazard: the stored artifact and the displayed truth can disagree.**

> **REPLACED IN v3.0.** The overlay is unreachable from Apex like the label itself, so this requirement cannot be met by reading. **It is met instead by the config surface**: an org whose wording differs states its own text at setup, which is the same protection reached by an honest route.

**Process note, recorded because it is the day's recurring failure.** This was known in session 33 and never reached a document, so an afternoon was spent recovering it by hand and a charter closed on an incomplete set. Corrections go into versioned documents, never chat — and that rule is only load-bearing if it fires for findings as well as for rulings.

### 2.2 · The insight ontology is authored too, and Solution's definition changes a ruling

Each insight type carries an authored admission test behind its *What is a…* link, with an examples list beside it. Goal, Pressure, Initiative and Obstacle carry three questions each. **Solution carries four, and three of them are about links to other cards** — how does your Solution address the Obstacles for your customer's initiative, what Pressures will it have the most impact on, how does it contribute to achieving their Goals, and **would a key player be able to articulate your unique business value from this Solution.**

**So a Solution card with no edges fails Altify's own published definition**, which is a far stronger basis for the unlinked-Solution flag than the one it was ruled on. And the fourth question is the strongest evidence proposition on the insight map, because it asks whether the buyer said the value back in their own words — checkable from a transcript, from a subject set (`ALTF__Is_Key_Player__c`) that is already closed and derived.

**Terminal states are per type and no two share a lifecycle:** Goal → Achieved, Pressure → Resolved, Initiative → Completed, Obstacle → Overcome, Solution → Implemented.

**These tests are guidance, not admission gates. RULED.** They are discovery-completeness prompts wearing the clothes of definitions — *do you know how the decision maker is measured* tests the seller, not the card. Admission stays on genuineness. **The authored text must stay out of the reader's input**, or the model treats it as criteria whatever the charter says.

### 2.3 · The person-to-card relation: four questions, two stored values

The methodology asks **who is responsible for** a Goal and an Initiative, **who is impacted by** a Pressure and an Obstacle, and separately **who told you** about any of them. `ALTF__Insight_Card_Contact__c.ALTF__Type__c` carries only `Informer` and `Owner`, so **impacted-by and responsible-for are the same row.** That distinction is what makes guidance addressable: *this takes that pressure off your shoulders* versus *you own this obstacle*, which means nothing to the person hearing it. **Ruled: derive from card type when reading existing human rows, record explicitly on our own claims**, because the buckets are demonstrably noisy.

**And the causal chain is taught but not stored.** Pressure-to-Goal linkage is free text on `ALTF__Impact__c`, a field doing double duty as desired-outcome for Initiatives. Glossary Section J is right that `ALTF__Insight_Card_Edge__c` runs the full chain in principle, but the schema carries **one** typed target, `ALTF__Solution_Insight_Card__c`. Altify's own MCP server calls *Pressures → Goals → Initiatives → Solutions* the healthy pattern while nothing can query whether it holds. **This is Politics charter territory and it is larger than the person mapping.**

### 2.4 · Smaller corrections to v2.1's own numbers

**Nine objects live, not eight** — `AAO_Participant__c` added. **164 tests green** (139 at v2.1, 153 mid-session). **Reserved-word collisions are six, not five:** `commit`, `json`, `system`, `merge`, `any`, **`when`** (from `switch`). Four refuse loudly; `json` and `system` resolve silently and are the dangerous pair.

**Claim Basis declares eight cited types and has built four** *(v2.5 — was two)*. Built: `Answer`, `Map_Row`, `Source`, `Line_Item`. **Still enum values pointing at nothing: `Insight_Card`, `Decision_Criterion`, `Qualifier_Status`, `Shadow_Person`.** v2.1 recorded six typed lookups and the org had two. `Source` is added (a Coverage claim cites the Sources it counted) and `OpportunityLineItem` is added. **`Product2` is deliberately not added** — reachable by traversal from the line item, so citing it separately would cite a classification rather than a fact about this deal. **The rule for what earns a lookup: a cited type gets one when we will compare its live state against the frozen snapshot.** That is the whole reason the object is half frozen and half live, and a text Id cannot do it.

**Two laws the build taught us, both from the deploy refusing a design.** `AAO_Raised_At__c` is immutable, so a reopened flag cannot restart its clock — **a flag ages from when its question became askable, not from when the answer last turned bad**, or a deal launders itself by closing and reopening. And **anything hung off an after-insert trigger can turn our defect into the customer's lost evidence**, because a throw there rolls back the row that caused it; the safe direction is always to lose the derived thing rather than the evidence.

---

## 3 · What the session BREAKS and must reopen

**These are real and none was noticed while ruling, because the memory plane was not in view.**

### 3.1 · Cold seeding is broken by the tree ruling · MUST REOPEN

The session ruled that **ontology owns the rung**: a person's Support is what Altify's tree computes from five propositions, and the ±1 delta law and the −3…+3 clamp were withdrawn for ontology-backed dimensions.

**Data Flow draws cold seed as a boundary crossing** — Data 360 to core, once per opportunity — and the glossary defines **Prior** and **Attenuation**: a historical Mentor seeds at Supporter, paying a rung for having been earned somewhere else, and a seeded value is a prior rather than an establishment because citations do not cross deals.

**Under the tree there is no ladder to seed a position on.** The rung is derived from five propositions that are per-deal by construction, so a new opportunity starts with all five null and a person with a decade of history reads at the floor. **Either cold seed writes a rung directly, which gives the rung two producers and breaks the derivation, or cold seeding dies.** Neither is acceptable as it stands. **Matthew's, and it is the largest thing this reconciliation found.**

### 3.2 · Coverage has no home for its window · MUST REOPEN

Coverage's third question asks whether you *regularly and routinely* have high quality conversations — a window far longer than the warm window. **Sources retire from core after thirty days**, and `AAO_Participant__c` is **not among the seven memory tables** (Claim, Fulfilment, Surfacing, Roll-Up, proposition-state snapshot, rubric snapshot, decision log). So Coverage cannot be a core count at the grain it actually needs. **Either participation streams as an eighth memory table, or the counts roll up before their Sources retire.** Not designed either way.

### 3.3 · The People fan-out has no cardinality guard · MUST REOPEN

Invariant 9: every creation path carries an upper bound, and exceeding it means abstain and flag. The People handed unit is **person crossed with dimension**, so nine people against six dimensions is fifty-four findings in one pass. The session named the output-token ceiling and **never applied the cardinality guard**, which is the law that already exists for exactly this.

### 3.4 · Delta reconstruction needs restating, not repairing

The glossary says *state is reconstructible from the journal by summing deltas.* Under the tree it is reconstructible from the five contract answers instead. **Same guarantee, different mechanism** — replay still works and the exit test is unaffected — but the sentence in the glossary becomes wrong for ontology-backed dimensions and must be restated rather than left standing.

**Historical contention survives.** Ordinal contention is integer subtraction across rungs, and the rung is still an ordinal label however it was derived. Supporter today against Enemy historically is still three rungs. No change needed.

---

## 4b · Persona · RULED 2 Aug · the People charter's fourth emission

**Persona goes in the People charter, not Politics.** Three reasons. The glossary's own reason for Link existing is that it emits claims about **pairs**, and *Dana is an IT Leader* is a single-entity claim. The **same sentence** establishes existence and persona, so splitting them means two charters firing on one utterance with nothing to arbitrate, which is the argument already used to keep criteria inside the Insight charter. And it costs nothing, because the pass is already reading about that person for five other dimensions.

**Additive only, and the machine never removes a persona.** `ALTF__Contact__c.ALTF__Altify_Personas__c` is a **multipicklist** carrying the same twelve values as the persona record, and it is **account-durable — one set per person across every opportunity**, which is architecture we inherited rather than chose. Additive semantics dissolve the problem: deal A establishes IT Leader, deal B establishes Sales Leader, and both are true. No overwrite, no cross-deal collision on a field that outlives the deal, no contention on it, and human precedence holds trivially because nothing is ever taken away. **Removal stays a human act forever.**

**The identifiers are simpler than they look.** Contact is the hub — both `ALTF__Contact_Map_Details__c` and `ALTF__Contact__c` carry a required lookup to it. Our Claim already carries the Contact as key three, so the Altify Contact is reachable by traversal and needs no new key. Subject type is `Contact`, which already exists. The only addition is a cited type if the Altify Contact's state is to be frozen at claim time.

**Correction to the persona vocabulary claim.** The glossary calls the value set *almost entirely job titles and being used as one*. Read from production: **CEO, CRO, Executive Sponsor, Sales Leader, RevOps Leader, Enablement Leader, IT Leader, Procurement Lead, Altify Program Owner, Consultant, Legal, Partner.** Exactly **two job titles and ten personifications**. And the glossary's proposed fix — adding Approver and Decision Maker to the persona set — is **rejected**: persona says what kind of person, Buyer Role says their role in this purchase, Support says where they stand. *A supportive IT leader who is also a decision maker* is three existing dimensions composed. Collapsing them into one list destroys the composition the rubric needs.

**Also corrected: Decision Orientation and Adaptability are two different fields, not one field with two labels.** Decision Orientation is on the map row, deal-scoped, Financial / Technical / Relationship / Business, 3% filled. **Adaptability is on the Altify Contact**, person-durable, Innovator / Visionary / Pragmatist / Conservative / Laggard. **Adaptability is out of scope by ruling — it cannot be inferred.** The person-durable tier carries Persona and Adaptability; the deal tier carries Support, Political, Coverage, Buyer Role and Decision Orientation. **Only the deal tier has been designed for.**

**Owed, and the halves must land in order.** Persona *identification* works on any pass once the People charter carries it, including deals in flight. **Ghost *injection* on deals already in flight is undesigned** — the cold-start path fires at opportunity creation only, so a hundred open deals have no ghosts to graduate, and a rubric change that adds a persona requirement reaches nothing already running. **Identification without injection graduates nothing.** Injection first.

**And the Role charter is the persona derivation wearing a name that hides it.** It writes exactly one field, `AAO_Required_Map_Role__c` on the Evidence Contract, whose sole reader is *which person must exist on the map — seeds the ghost*, answering from the persona vocabulary. It is not Buyer Role and not Decision Orientation. **The name collides with Buyer Role and should be retired for persona derivation.** Its classification as a charter stands, on Matthew's ruling that the charter is the unit of per-org configuration and injection, which is a better definition than one based on what a thing reads.

---

## 4c · Scope, licensing and partial ownership · RULED 2 Aug · a build phase of its own

### What may be written where

| Target | Rule |
|---|---|
| **Opportunity, Account** | **Never written. Absolute.** |
| **Contact** | **Toggleable**, and always was — toggle on, we write the Contact and its children; toggle off, a human creates it and shadow persons persist |
| **Any native object** | **No metadata added, no triggers, no logic. Absolute.** |
| **Altify managed objects and fields** | Written, toggleable per target. This is the project |

**The consequence of the Contact toggle, stated because it changes what shadow objects are.** `ALTF__Contact_Map_Details__c.ALTF__Contact__c` is a **required** lookup to the standard Contact, so a map row cannot exist without one. With the toggle off, **a shadow person can never appear on the Altify map** until a human creates the Contact. Shadow objects are transitional for toggle-on customers and **permanent for toggle-off customers**, and they carry a whole class of people for the life of the deal on our surfaces alone. That architecture needs settling before shadow work starts.

### Three scoping filters, all new as global rules

**Licensed sellers only · the read is SETTLED, v2.5, from the org.** Only opportunities owned by a licensed seller enter the pipeline. The filter existed for the note poll and is now global.

| Object | What it is | In `aossb2` |
|---|---|---|
| `sfLma__License__c` | the ISV's own licence management, about **their** customers | **0 rows** — present and empty, as ruled |
| `PackageLicense` | the installed package and its seat pool | 1 ALTF row, `AllowedLicenses = -1`, `UsedLicenses = 80` |
| **`UserPackageLicense`** | **who actually holds a seat** | **80 ALTF assignments** |

**`UserPackageLicense` joined to `PackageLicense.NamespacePrefix = 'ALTF'` is the read.** Platform objects rather than managed ones, so nothing breaks on package upgrade, and it answers per user rather than per org.

**`AllowedLicenses = -1` means unlimited**, so the seat pool cannot be used to infer scarcity. Only the assignment rows tell the truth.

**And a package licence is not a module licence.** This says the user may use Altify. It says nothing about which of the four modules the org holds, so the two reads that §4c treated as one are separate and **only the seller read is solved.** The module read is still owed, and per the ruling below it has to probe rather than count, because the difference surfaces as permission rather than as absence. The four modules correspond to the content tabs observed in the production UI — Process, Relationships, Insights, Assessment — which should be confirmed rather than assumed.

> **v3.0 note.** `PackageLicense` carries no version field, confirmed by describe: eleven fields, namespace, seat counts, status, expiry and nothing else. Under LAW #1 that is now a comfort rather than a gap — **there is no version on the read we depend on, so the read cannot acquire a version dependency by accident.**

**Opportunity types out of scope.** Some types are excluded by configuration, the same shape as the applicable-set chain.

**Module ownership, and this one is genuinely new.** Customers hold different combinations: relationship map only, plus insight map, plus assessment, or all four. **This is not graceful absence.** Graceful absence covers an object or rubric record that is not there. Here the objects exist because the package is installed and the customer is not licensed for the module, so **a write fails on permission rather than on absence**, and nothing in the record handles that.

### The shape, and it uses a property already ruled

**Claims land on our objects first; Altify's fields receive a projection.** So a projection that cannot land does not touch the claim. **The capability matrix lives entirely in the projection layer and no charter knows about it.** A customer with relationship map only still gets the whole evidence engine and simply sees less of it in Altify's panels, which is the same property as running in an org that never had Altify, now earning its keep for a case nobody designed it for.

**Projection probes before it writes**, records what it found, and a failure to project never affects the claim, the flag, or the roll-up.

**The admin error log is the first admin-facing surface in the design, and it needs one distinction built in from the start: expected-unavailable is configuration, not an error.** A log filling nightly with *projection failed, module not licensed* trains an admin to ignore it, and then the one real failure arrives in a stream nobody reads. It carries a named contact or set of contacts at the org.

### The testing problem, and it is the standing hazard again

**None of this can be tested in Altify's own org, which is fully licensed with every module.** The harness is therefore **permission sets rather than a differently-licensed org**: strip a test user of access to the insight card object, run the pipeline, and confirm it degrades correctly rather than failing. Buildable in the sandbox today.

**Be precise about what it buys · v2.5. It proves degradation, not detection.** A permission failure and a licence failure arrive as the same DML error, so a permission-stripped user reproduces the real failure mode exactly, and *a projection failure never touches the claim, the flag or the roll-up* is **fully testable now**. What stays unverifiable until a differently-licensed org exists is **detecting which modules a customer holds**, because in an org that has everything the difference between not licensed and not installed is invisible.

**This is a build phase of its own** — licence detection, type scoping, the capability matrix, projection probing, the error log, the Contact toggle, and a permission-restricted test harness for all of it.

---

## 4d · Politics sequencing · RULED 2 Aug

**Influence and conflict first; person-to-card links second.** Person-to-card links need the insight map, so they only work for customers licensed for it. **Influence and conflict need only the relationship map, which is the smallest footprint any customer has.** So the half that works for everyone is the half with no authored ontology behind it, and it is also the half that makes the map political rather than a list. The person-to-card half is more valuable for call prep, but it already has most of its design from the four-questions-two-values finding and can wait.

**Politics has no authored ontology.** Confirmed by Matthew from the UI and by CODE's sweep in v2.9: influence and conflict carry no wizard and no help text. So Politics is the charter where **we author the propositions**, the same position Buyer Role is in, with the same consequence — contracts land at `Inferred_Pending` until a human ratifies them.

> **v3.0 note, and it is a simplification.** Politics was the one charter already in the shape LAW #1 now requires of all of them: **text authored by us, shipped, overridable per org.** Under the ruling, Politics stops being the exception and becomes the template. People and Problems move to where Politics already stood.

**And it narrows further. The informer is deterministic from the participant roster**, so who said it is free and never reaches a model. What Politics must establish is who owns or is impacted by a card **where that differs from who said it**, plus influence, plus conflict. Three things, all pairs, all authored by us.

---

## 4 · The charter inventory, reconciled

**Six charters are named. At least eight model roles exist.** Glossary Section E's table plus two roles defined elsewhere in the same document:

| Charter | Loop / trigger | Our name |
|---|---|---|
| **Relationship** | Loop one | **People** |
| **Insight** | Loop one | **Problems** |
| **Link** | Loop one | **Politics** — the only loop-one charter not yet opened |
| **Assessment** | Loop two, after maps commit | **Extraction** (live, 1.1.0) |
| **Role** | Setup time, per sales process | — |
| **Re-adjudication** | Per candidate, blind | **The blind reader** (1.0.0) |
| **Insight Contention** | Scheduled, after the write | **not in the table, and it needs a model** |
| **Rule Discovery** | Weekly, over the decision log | **not in the table, and it needs a model** |

**Matthew's two proposed charters, resolved.**

**The process charter already exists as route C.** Glossary added Resolution Route in v1.8: **P** is deterministic Apex with no model, **E** is evidence only, and **C** is *a charter with state — loop two reading the transcript and our committed rows together, citing rows when it cites state*. That is qualifiers reading the political situation after it has been written, and Proposition Kind backs it: state-established is an Apex predicate **or a model where judgment is required**. **It is the Assessment charter's second job, not a seventh charter**, and the ordering Matthew insisted on is the loop invariant.

**The contention charter is real and unhoused.** Glossary defines **Insight Contention** as contention over unstructured content with no ladder to subtract, *so this requires a model*, running on a schedule. It is one of the four checks. It has no charter. **Matthew is right.**

**And the count is unsettled by the glossary's own admission**, which says of setup-time inference that whether it is one charter with four output schemas or four charters sharing one lifecycle *is an implementation call and is not settled here.* Two of those four instances — qualifier-to-condition and criterion-to-question — are open.

**Naming bridge, for anyone reading both sets.** People = Relationship · Problems = Insight · Politics = Link · Extraction = Assessment · blind reader = Re-adjudication. **One vocabulary should win at the next glossary bump**, and it should be the glossary's, because the glossary is authoritative for vocabulary and the working names were never ruled.

---

## 4a · Flags and contention · RULED 2 Aug

### Flags get no charter, and the nuance lives one layer over

**Flag existence and clearance stay deterministic forever.** A flag has a cause; the cause is a proposition state, a missing relation, a pending candidate or an unanswered identity question. None of that needs judgment, and the architecture's hardest rule forbids putting one there: **nothing gates a flag being raised, and a customer cannot configure the system not to tell them something.** A model deciding whether a flag fires is the machine deciding what is do-or-die, which the criterion ruling already refuses for exactly this reason.

**What has the nuance is what a flag says and which one surfaces first, and that is guidance.** Guidance may infer because guidance establishes nothing, and both halves are already named as owed: **flag content forks on coverage** (a flag over nothing says *not started, here is what to get*; a flag over partial coverage says *here is what stands, with receipts, and here is the missing element*), and **tiered flag surfacing**, added at Matthew's direction and not yet designed, with its tension already recorded — a structurally unresolvable top-tier item holds everything beneath it invisible while their clocks keep running.

**Severity is already algorithmically configurable and needs nothing new.** It is the org's own answer scores, normalised against that org's observed maximum spread rather than an absolute cutoff, with fallback to No Score where Unknown Score is zero or null.

### Contention is three things, not one

| | Establishes by | When | Model? |
|---|---|---|---|
| **Ordinal contention** | Integer subtraction across rungs — current state minus historical aggregate against a threshold | After the write, scheduled | **No.** Free, replayable |
| **Insight contention** | Semantic comparison — a stated purchase driver against an account's historical buying pattern | Scheduled, outside the write path | **Yes, at runtime.** No ladder to subtract |
| **Pattern contention** *(new)* | Authored queries over the memory plane at grains beyond sentiment — per person, per opportunity pattern, per account | **Authored once at setup, frozen, executed by Apex every pass** | **Yes, at setup only** |

**Pattern contention is the configurable charter Matthew asked for, and its shape is the recipe ruling rather than a new mechanism.** A model writes the query once, the query freezes, Apex executes it. Interpretation from the model, completeness from the database because only a query can prove what is not there, determinism from the freeze. The admin surface is sentences and never code, with Approve or Revise, exactly as ruled for state-based questions.

**Why it must be setup-time rather than runtime, stated so nobody reopens it.** Calculated Insights are close to immutable once shipped: dimensions cannot be added later unless they are key qualifier dimensions, measures cannot be removed, and API name, data type and rollup behaviour are fixed at creation. A model inventing aggregates at runtime fights that wall every night. Frozen queries run as static SOQL against data model objects, supported from API 61.0, which is the path that does not require the insight layer to bend. **Insight contention is the exception and stays a runtime model read, because semantic comparison cannot be frozen into a query.**

**Still owed, and it is a one-way door.** The contention aggregate's grain. Aggregating over the rung is what the design assumed and is cheap. Aggregating over the five Support propositions would let contention say *across five deals this person has never once told you they prefer your solution, and they read as a Supporter today* — far more actionable, and impossible to narrow later. **Decide before the insight ships, not after.**

---

## 5 · What is still deliberately not settled

The **Politics / Link charter**, now the only unopened loop-one charter, opening on influence and conflict. **Insight Contention's charter.** **Rule Discovery's charter.** The two open setup-time inference instances. Quick-links from insights to qualifiers. **The module-ownership read**, which must probe rather than count. **The contention aggregate's Calculated Insight grain**, which is one-way. **The proposition-text source discriminator** on Evidence Contract, opened by v3.0.

*Closed in v2.6: whether the wizard's help text is reachable as custom labels. It is — `ExternalString`, 2,930 ALTF labels. See §2.1.*
*Closed in v2.8: it is reachable from Tooling and not from Apex.*
*Closed in v3.0: where the ontology comes from. It comes from us, and no read of any package version is relied on anywhere.*

---

*End of record. LAW #1 is the highest thing in this document and it outranks every option, recommendation and convenience below it. Where an earlier version reasons from what a package version contains, that reasoning is retained as history and is not to be built on.*
