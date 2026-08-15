# The Apex inventory · 83 classes, 9 triggers, and every rule the org enforces

**Deliverable (b) of the ninety-third stamp's item 3.** From the repo, class by class,
never from memory.

| | |
|---|---|
| **Tree** | `/Users/thefinalmachine/Downloads/claude`, branch `main`, project `aao-build` |
| **Org the code is deployed to** | `00DWD00000DV7iT2AT` — sandbox `aossb2` |
| **Counted** | 2026-08-15 |

**128 Apex classes: 83 production, 45 test. 9 triggers.**
**Zero declarative validation rules** — see the rules section, which is the finding.

## 1 · CLASS TO CALL · the §P8 pass, stage by stage

The pass is seven model-facing stages plus two deterministic ones. This is the map the
document set never had.

| Stage | Charter class | Driver | Writes |
|---|---|---|---|
| **call 0** · scope + roster | `AAO_ResolverCharter` | `AAO_Pass.resolve` | nothing; verdict returned |
| **call 1** · two comprehensive reads | `AAO_LocateCharter` | `AAO_Pass.locate` → `AAO_Locate` | `AAO_Pair__c` (Located) |
| **call 2a** · deterministic resolution | *(no charter — Apex only)* | `AAO_Pass.identifyDeterministic` → `AAO_Resolve.run` | `AAO_Pair__c` (Identified), `AAO_Participant__c`, `AAO_Flag__c` |
| **call 2b** · model leg on the remainder | `AAO_ResolveRequestCharter` | `AAO_Resolve.requests` | `AAO_Pair__c` (Identified), `AAO_Shadow_Person__c` |
| **call 2 (legacy)** · model over every pair | `AAO_IdentifyCharter` | `AAO_Pass.identify` | `AAO_Pair__c` (Identified) |
| **call 3** · blind verify, bucketed | `AAO_VerifyPairsCharter` | `AAO_Pass.verify` | `AAO_Pair__c` verdict fields |
| **join** | — | `AAO_PairCommit` → `AAO_Commit` → `AAO_Accumulate` | `AAO_Claim__c`, `AAO_Candidate__c`, `AAO_Answer__c`, `AAO_Criterion__c` |
| **projection** | — | `AAO_Project` | `ALTF__*` (see deliverable (d)) |
| **cards** | `AAO_CardFace` | `AAO_Cards` | `ALTF__Insight_Card__c` and its junctions |

**Two entries for call 2 is not a duplicate, it is the era boundary.** `AAO_IdentifyCharter`
is the model call over every located pair; `AAO_Resolve` is the twenty-seventh stamp's
deterministic stage. The eighty-first stamp measured `AAO_Resolve` at zero production
callers and ruled option (a): deterministic legs in front, model leg on the remainder only.
`AAO_Pass.identifyDeterministic` is that wiring, added 15 August. **Both paths exist in the
tree today; the deterministic one runs first and `identify` takes what it leaves.** The
twenty-eighth stamp's one-implementation rule is not yet satisfied and that is named debt.

## 2 · CLASS TO CHARTER · which family a class serves

| Charter / family | Classes |
|---|---|
| **The scope resolver** (call 0) | `AAO_ResolverCharter`, `AAO_ResolveDesignator` |
| **The resolver** (identity, call 2) | `AAO_Resolve`, `AAO_ResolveRequestCharter`, `AAO_IdentifyCharter`, `AAO_Identity`, `AAO_PersonName`, `AAO_Identification` |
| **People** | `AAO_PeopleContracts`, `AAO_PeopleOntology`, `AAO_SupportCounter`, `AAO_Coverage`, `AAO_MapValues`, `AAO_Participants` |
| **Problems** | `AAO_Cards`, `AAO_CardFace` |
| **Politics** | *(thin slice: person-to-insight links inside `AAO_Cards`)* |
| **Process / Assessment** | **not built** — deferred at the eighty-seventh stamp |
| **Criteria** | `AAO_Criteria` |
| **Cross-family (all charters)** | `AAO_PassContracts`, `AAO_ApplicableSet`, `AAO_Rubric`, `AAO_EvidenceFamily`, `AAO_SpeakerRule` |

**Politics has no class of its own, and that is correct rather than missing.** The
forty-second stamp slimmed it to people-to-insight links, which `AAO_Cards` writes as
`ALTF__Insight_Card_Contact__c` rows. Influence and conflict edges are deferred, not lost.

## 3 · THE TRIGGERS AND THE RULES THEY ENFORCE

**THE FINDING: there are ZERO declarative validation rules in this project.** `find
force-app -name '*.validationRule-meta.xml'` returns nothing. Every rule the org enforces
is Apex `addError` in a trigger handler — **44 of them across 8 handlers.**

That is why the org's laws are invisible to anyone reading the metadata tree for validation
rules, and it is why they surface only when something tries to break one. Two did today.

| Trigger | Handler | `addError` guards |
|---|---|---|
| `AAO_PairTrigger` | `AAO_PairTriggerHandler` | **17** |
| `AAO_ClaimTrigger` | `AAO_ClaimTriggerHandler` | 7 |
| `AAO_AnswerTrigger` | `AAO_AnswerTriggerHandler` | 5 |
| `AAO_EvidenceContractTrigger` | `AAO_EvidenceContractTriggerHandler` | 5 |
| `AAO_FlagTrigger` | `AAO_FlagTriggerHandler` | 3 |
| `AAO_SourceTrigger` | `AAO_SourceTriggerHandler` | 3 |
| `AAO_CandidateTrigger` | `AAO_CandidateTriggerHandler` | 2 |
| `AAO_ClaimBasisTrigger` | `AAO_ClaimBasisTriggerHandler` | 2 |
| `AAO_ParticipantTrigger` | *(no handler guards)* | 0 |

### The two the org taught CODE on 15 August, quoted from the runtime

Both were learned the same way: something was inserted or deleted, and the database refused
with a sentence explaining the design. They belong in the reference because **a rule that
only appears when you break it is a rule nobody can read in advance.**

**1 · A Located pair may not carry a person.** `AAO_PairTriggerHandler.validateLocated`:

> *"A Located pair carries the person (AAO_Person__c), which is not call 1's to write. Each
> call's charter forbids the other calls' jobs, and the failure mode is a call quietly
> taking back a job that was taken from it, so the prohibition is a field the database
> refuses rather than a sentence in a prompt."*

**The consequence that bit:** the designator lives on the Located parent, the person on the
Identified child, and `AAO_Resolve.disposition()` does not copy the designator forward. Any
query asking for both columns on one row matches nothing, ever. That defect shipped into
`AAO_Identification`'s clear path and was caught only because a fixture went through the
org's own validation.

**2 · A non-synthetic flag may never be deleted.** `AAO_FlagTriggerHandler.beforeDelete`:

> *"AAO_Flag__c is not deletable on the live path. A flag is cleared by evidence, by written
> acknowledgement, or by approval, according to its type. Deleting one destroys the
> measurement it exists to produce."*

The same shape guards `AAO_Pair__c`: *"The pair ledger is the record that a stage ran at
all... a deleted row makes those counts lie rather than fail."* The single door is
`AAO_Synthetic.deletable(rowIsSynthetic)`, which returns `PURGING && rowIsSynthetic == true`
— **26 lines, and the only way any AAO row leaves this org.**

## 4 · EVERY PRODUCTION CLASS, ONE LINE EACH

Sorted by name. The line is the class's own opening description, not a paraphrase.

| Class | Lines | What it does |
|---|---|---|
| `AAO_Accumulate` | 304 | How a claim moves an answer. Commit calls this going forwards; Replay calls this |
| `AAO_AnswerKey` | 238 | The frozen composer for AAO_Answer_Key__c, and for the identical subject identity on |
| `AAO_AnswerTriggerHandler` | 148 | Answer's frozen key composer, and the write law. |
| `AAO_ApplicableSet` | 252 | The applicable set for one pass, DECLARED and never global. |
| `AAO_BindCharter` | 234 | STAGE 2 of the Extract-Bind-Verify pass (Charters v2.4 §P7.3). Binding. |
| `AAO_BlindCharter` | 272 | Model call 2. The blind reader. |
| `AAO_CandidateTriggerHandler` | 46 | The evidence-family law on the proposing side, per AAO_EvidenceFamily. |
| `AAO_CardFace` | 192 | THE INFERRED CARD FACE. One line per established insight, written by the machine. |
| `AAO_Cardinality` | 205 | INVARIANT 9. Every creation path carries an upper bound and abstains and flags past it. |
| `AAO_Cards` | 963 | THE CARD WRITER. Problems become `ALTF__Insight_Card__c` rows on the deal. |
| `AAO_ClaimBasisTriggerHandler` | 43 | The reverse half of the evidence-family law. |
| `AAO_ClaimTriggerHandler` | 145 | Claim is insert only. Block every update and every delete. |
| `AAO_Commit` | 737 | Commit forks: a claim is written and an answer is upserted. |
| `AAO_ContractKey` | 68 | The frozen composer for AAO_Contract_Key__c. |
| `AAO_Coverage` | 258 | COVERAGE. Computed, never extracted; presence establishes it; no model call anywhere. |
| `AAO_CreatedRows` | 47 | THE CREATE-LEG RECORD'S WRITER. One call per machine-created org row, from every |
| `AAO_Criteria` | 175 | THE CRITERIA LEDGER. Addendum 20: the criteria answer's subject is the criterion. |
| `AAO_Demo` | 424 | The durable rehearsal. Same fixtures as the exit test, committed for real. |
| `AAO_Discovery` | 815 | Discovery. Evidence Contracts assembled by READING the org's own rubric tables, rather |
| `AAO_EBV` | 857 | THE EXTRACT-BIND-VERIFY PASS, Charters v2.4 §P7.3. Four stages, one callout per transaction. |
| `AAO_EBV_TEMP_Batch` | 131 | THE INVOKER, AND IT IS CONDEMNED IN ITS OWN NAME. |
| `AAO_EvidenceContractTriggerHandler` | 118 | The frozen contract-key composer, and the immutability of authored text. |
| `AAO_EvidenceFamily` | 172 | THE EVIDENCE-FAMILY LAW. Ruled 47, 1 August 2026. |
| `AAO_Extract` | 897 | The first real model call. Reads one Source, sends the rubric and the artifact to the |
| `AAO_ExtractCharter` | 464 | Extraction charter v1. Assembles the prompt and the output schema from Evidence Contract |
| `AAO_FakeId` | 24 | Structurally valid Ids without DML, so the frozen key composers can be tested as |
| `AAO_FlagTriggerHandler` | 62 | Flag's trigger law: type is set at birth and never changes. |
| `AAO_Flags` | 216 | Day-one red. The raise path the Flag object has been waiting for since session 2. |
| `AAO_Gate1` | 506 | Gate 1 round two, run in the org. |
| `AAO_Identification` | 312 | THE IDENTIFICATION FLAG, as a mechanism rather than a picklist value. |
| `AAO_IdentifyCharter` | 253 | CALL 2 of the §P8 pass: IDENTIFY. Charters v2.9 §P8.2. |
| `AAO_Identity` | 540 | THE CREATE LEG. Addendum 19, ruling 3: attempt the ladder, create where allowed, and where |
| `AAO_Ingest` | 49 | The live ingestion path. A Source arriving is the event; everything else follows from it. |
| `AAO_IngestQueueable` | 66 | Runs the pipeline for Sources that have just landed. |
| `AAO_IntakeECI` | 182 | ECI viewer-paste intake. Twenty-sixth stamp: Project Farma's raw is a new shape, the ECI |
| `AAO_IntakeVTT` | 295 | WebVTT intake. Twentieth stamp item 4, pulled to the front by the twenty-fifth: the WF |
| `AAO_InventoryCharter` | 524 | STAGE 1 of the Extract-Bind-Verify pass (Charters v2.4 §P7.3). The read. |
| `AAO_Live` | 245 | The live deal. Seeded empty, and evidence arrives on it one artifact at a time. |
| `AAO_Locate` | 216 | THE STEP BETWEEN CALL 1 AND THE LEDGER: byte location, then rows. |
| `AAO_LocateCharter` | 788 | CALL 1 of the §P8 pass: LOCATE AND PAIR. Charters v2.8 §P8.1, calibrated by §P8.9. |
| `AAO_MapRoute` | 349 | The P route, and the thing that finally makes Claim Basis mean something. |
| `AAO_MapValues` | 201 | THE NEVER-BLANK DECISION PROCEDURE, and the label-to-value map it reads. |
| `AAO_MissingRelation` | 176 | THE MISSING-RELATION FLAG. Ruled v1.5, and the ruling is about SHAPE rather than content. |
| `AAO_Model` | 226 | The JSON shapes carried in the long-text fields, versioned. Spans, element coverage |
| `AAO_NormalForm` | 140 | The frozen normal form for AAO_Normalized_Text__c, and the turn segmentation every |
| `AAO_P8Codes` | 275 | WHAT EACH OF THE SEVENTEEN PLACES. The derivation half of `people-p8-v1`. |
| `AAO_PairCommit` | 842 | THE PAIRS-TO-WRITER JOIN. Upheld identified pairs become Claims and Answers. |
| `AAO_PairKey` | 76 | The frozen composer for AAO_Pair__c.AAO_Pair_Key__c. |
| `AAO_PairLedger` | 169 | ONE FOR ONE, FOR ONE, as a count-match. The half the unique index cannot see. |
| `AAO_PairTriggerHandler` | 288 | The pair ledger's laws: the two shapes, the prohibition law made physical, and the |
| `AAO_Participants` | 202 | WHO WAS ON A PIECE OF EVIDENCE, written at ingest so it can be asked of the database. |
| `AAO_Pass` | 1403 | THE §P8 PASS, END TO END: call 1 locates and pairs, call 2 identifies, call 3 verifies. |
| `AAO_PassContracts` | 535 | THE DECLARED CLAIM-PATH CONTRACTS FOR §P8. Seventeen, asked once per transcript. |
| `AAO_PeopleContracts` | 250 | People Evidence Contracts, built from our own seeded ontology. |
| `AAO_PeopleOntology` | 426 | THE PEOPLE ONTOLOGY. OURS, seeded, overridable per org. Ruled v3.0 under LAW #1. |
| `AAO_PersonName` | 142 | THE DETERMINISTIC NAME PARSE. Addendum 19's requirement travelling with the create leg: |
| `AAO_Pipeline` | 776 | The per-source pipeline body. One implementation, three entries. |
| `AAO_PipelineViewController` | 1154 | One call, one snapshot, for the AAO Pipeline command center. |
| `AAO_Project` | 1813 | The People projection writer. |
| `AAO_Purge` | 230 | THE PURGE-AND-RERUN PROTOCOL, twenty-eighth stamp item 3. Test cycles purge and re-run on |
| `AAO_RecallGate` | 543 | THE RECALL GATE (§P8.0). Before anything downstream is trusted, call 1 runs against the |
| `AAO_Receipt` | 359 | THE RUN RECEIPT'S WRITER. One row per Source per pass, merged a stage at a time. |
| `AAO_Regression` | 852 | EVERY GRADED FINDING BECOMES A STANDING ASSERTION ON EVERY LATER RUN. |
| `AAO_Replay` | 129 | Replaying claims in evidence-occurred order must reconstruct every answer exactly. |
| `AAO_Resolve` | 809 | THE RESOLUTION STAGE. Matthew's ruling, 8 August evening (twenty-seventh stamp), replacing |
| `AAO_ResolveDesignator` | 334 | THE RESOLUTION HALF OF CALL 0, MADE CALLABLE. Ruled 8 August, twenty-second stamp item 5, |
| `AAO_ResolveRequestCharter` | 178 | THE MODEL LEG'S CHARTER: TYPED RESOLUTION REQUESTS. Twenty-seventh stamp. |
| `AAO_ResolverCharter` | 512 | CALL 0: the resolver's read. Charters v3.2, Part II. Runs on every Source, before the sweep. |
| `AAO_Retire` | 207 | CLAIMS RETIRE, NEVER DELETE. Ruled by Matthew, 6 August 2026. |
| `AAO_Rubric` | 97 | THE LAW: every reader of contracts asks for a set, and the product's set is the org's |
| `AAO_RunExport` | 327 | THE ROW EXPORT AND THE TIMINGS. Standing obligations on every run report, ruled 6 August. |
| `AAO_RunInspector` | 861 | THE RUN INSPECTOR. What happened on this deal, and how do I get from a value back to the words. |
| `AAO_ScopeKey` | 79 | The frozen composer for AAO_Scope_Key__c. Uniqueness is deal plus fingerprint plus |
| `AAO_Seed` | 544 | Loads the mini-rubric and the dummy transcripts from the AAO_Seed static resource. |
| `AAO_Settings` | 66 | THE ORG-OVERRIDABLE SETTINGS READER. One shipped default, one subscriber override, and the |
| `AAO_SolutionRoute` | 306 | THE SOLUTION ROUTE. Route P, basis State, no model and no ratification. Ruled v1.4–v1.7. |
| `AAO_SourceTriggerHandler` | 139 | Source immutability, and the frozen scope-key composer. |
| `AAO_SpanVerifier` | 183 | Byte verification. Every span must equal the substring of its own Source's normalized |
| `AAO_SpeakerRule` | 230 | AAO_Speaker_Requirement__c evaluated against the speaker of the span carrying the |
| `AAO_SupportCounter` | 317 | THE SENTIMENT COUNTER. Charters §P8.4, arithmetic refined at v2.8 from the first joint |
| `AAO_Synthetic` | 26 | The synthetic marker, and the only door through which synthetic rows can leave. |
| `AAO_VerifyCharter` | 211 | STAGE 3 of the Extract-Bind-Verify pass (Charters v2.4 §P7.3). The blind reader. |
| `AAO_VerifyPairsCharter` | 438 | CALL 3 of the §P8 pass: VERIFY. Charters v2.9 §P8.3. The blind reader, on the pair shape. |

### The five largest, because size marks where the thinking went

- **`AAO_Project`** (1813 lines) — The People projection writer.
- **`AAO_Pass`** (1403 lines) — THE §P8 PASS, END TO END: call 1 locates and pairs, call 2 identifies, call 3 verifies.
- **`AAO_PipelineViewController`** (1154 lines) — One call, one snapshot, for the AAO Pipeline command center.
- **`AAO_Cards`** (963 lines) — THE CARD WRITER. Problems become `ALTF__Insight_Card__c` rows on the deal.
- **`AAO_Extract`** (897 lines) — The first real model call. Reads one Source, sends the rubric and the artifact to the

## 5 · THE TEST CLASSES

**45 test classes.** The suite runs 516 tests; 515 pass and the one failure is
the standing non-AAO `ConvertToOpportunityTest`, which is org-resident and unrelated.

