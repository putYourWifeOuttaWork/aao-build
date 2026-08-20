/**
 * PROCESS JOINS THE READS · the hundred-twenty-sixth's item 3(a).
 *
 * *"The evidence plane joins the reads. The fifteen BANT questions and the seeded qualifiers'
 * evidence halves ride the two comprehensive reads as pairs - rubric discovery already reads the
 * seed records; the Process charter brief adds their questions, never a new read."*
 *
 * **IT DISCOVERS, IT DOES NOT AUTHOR.** The codes, the question text, the guidance and the
 * elements all come from `ALTF__Assessment_Question__c` rows in the org, reached through the org's
 * own plan type - the same path `AAO_Discovery` walks, for the same LAW #1 reason: roughly four
 * installs in five carry a rubric nobody here wrote, and a build that only works against questions
 * we typed in works nowhere. That our sandbox's fifteen happen to be ours is an accident of the
 * seed, not something this class may rely on.
 *
 * **WHY IT MINTS AT THE PASS'S RUBRIC VERSION.** `AAO_RecallGate.declaredSet` selects on
 * `AAO_PassContracts.RUBRIC_VERSION`, so a contract minted anywhere else simply never reaches the
 * reads - which is why `AAO_Discovery`'s six live contracts at `discovered-v1` have never ridden
 * the §P8 pass. Minting into the same generation is what "adds its questions to the two
 * comprehensive reads, never a new read" means in rows.
 *
 * **AND THE PROVENANCE LAW IS ALREADY SATISFIED, so the version does not move.** The read's stamp
 * is `AAO_LocateCharter.effectiveVersion`, which composes the charter's own version with a
 * fingerprint of the declared set's contract keys - *"an edit anywhere in either half moves the
 * string, and it cannot not move."* Fifteen contracts entering the declared set therefore move
 * every stamped row's provenance automatically. `RUBRIC_VERSION` names the rubric GENERATION, not
 * the prompt, and bumping it would supersede twenty-one live People contracts to record a change
 * the composed stamp already records. **The string reads `people-p8-v1` and now covers Process
 * too, which is a misleading NAME and not a broken mechanism** - named here rather than fixed,
 * because renaming a version string is exactly the kind of change that looks cosmetic and
 * rewrites provenance.
 */
public class AAO_ProcessContracts {

    public class ProcessContractException extends Exception {}

    /** Ours, and the same one the seed writes. A customer org names its own. */
    public static final String PLAN_TYPE = AAO_ProcessSeed.PLAN_TYPE;

    public class Result {
        public Integer read = 0;
        public Integer minted = 0;
        public Integer reused = 0;
        /** Questions whose contract stands RETIRED, declined rather than silently re-minted. */
        public Integer retired = 0;
        public List<String> notes = new List<String>();
        public override String toString() {
            return 'PROCESS CONTRACTS\n  questions read ' + read +
                '\n  contracts minted ' + minted + ', reused ' + reused +
                ', declined as retired ' + retired +
                (notes.isEmpty() ? '' : '\n  ' + String.join(notes, '\n  '));
        }
    }

    /**
     * The org's assessment questions, reached the way the org itself chains them: the plan type
     * carries ALTIFY CODES in a 255-character comma-delimited string, and those join to
     * `ALTF__AltifyId__c`. Splitting that on commas and querying by Id finds nothing and reports
     * an empty rubric - `AAO_Discovery` wrote that down and this reads it rather than rediscover.
     */
    /**
     * ===== THE APPLICABLE SET IS A PER-DEAL FACT, and until now this resolved it per ORG.
     *
     * The hundred-thirty-third: *"The chain is right; the entry point is wrong."* The walk below
     * is unchanged and always was the org's own - Plan Type List row, its comma-delimited
     * `ALTF__AssessmentQuestionIds__c`, joined on `ALTF__AltifyId__c`, active only, in order. What
     * was wrong is that it pinned the walk to a CONSTANT naming our seeded sandbox plan type, so
     * every deal in the org got the same fifteen and **a renewal-type deal would have been asked
     * new-business questions.** The Charters have carried the per-deal ruling since 3 August;
     * §P7.2.1 named the half-measure in so many words. The documents did not need refreshing.
     *
     * The chain, measured from this org rather than assumed:
     *
     *   `ALTF__Opportunity_Manager_Settings__c.ALTF__Opportunity_Plan_Type__c`  names a FIELD
     *        -> in this org it reads `Type`, the standard Opportunity picklist. A customer can
     *           point it anywhere, which is why the field is read BY NAME at runtime and never
     *           hardcoded.
     *   the deal's value in that field  matches  `ALTF__Opportunity_Plan_Type_List__c.Name`
     *   that row's `ALTF__AssessmentQuestionIds__c`  restricts the set
     *
     * **THE PACKAGE'S OWN DEFAULT SEMANTICS, mirrored cell for cell: empty, null and unmapped all
     * resolve to EVERY ACTIVE QUESTION.** Not to nothing. An org that has not configured a plan
     * type is asking every question it authored, and returning an empty set there would be us
     * inventing a restriction the package does not apply.
     *
     * **THE FIELD NAME IS VALIDATED AGAINST THE DESCRIBE BEFORE IT REACHES A QUERY.** It comes
     * from a settings record rather than from a user, but a name concatenated into SOQL unchecked
     * is an injection surface whatever its provenance - the twenty-second stamp's own ruling that
     * Apex composes every query from typed fields, applied to a field name as much as to a value.
     */
    public static List<ALTF__Assessment_Question__c> discoverQuestions(Id opportunityId) {
        String planType = planTypeOf(opportunityId);

        Set<String> codes = null;
        if (String.isNotBlank(planType)) {
            List<ALTF__Opportunity_Plan_Type_List__c> pts = [
                SELECT ALTF__AssessmentQuestionIds__c
                FROM ALTF__Opportunity_Plan_Type_List__c
                WHERE Name = :planType
                LIMIT 1
            ];
            if (!pts.isEmpty() && String.isNotBlank(pts[0].ALTF__AssessmentQuestionIds__c)) {
                codes = new Set<String>();
                for (String c : pts[0].ALTF__AssessmentQuestionIds__c.split(',')) {
                    if (String.isNotBlank(c)) {
                        codes.add(c.trim());
                    }
                }
            }
        }

        if (codes == null) {
            // Unmapped, unconfigured or blank. The package asks everything active; so do we.
            return [
                SELECT Id, Name, ALTF__AltifyId__c, ALTF__Criterion_Text__c,
                    ALTF__Long_Question__c, ALTF__Help__c, ALTF__Question__c,
                    ALTF__Mandatory__c, ALTF__Active__c, ALTF__Order_Number__c
                FROM ALTF__Assessment_Question__c
                WHERE ALTF__Active__c = TRUE
                ORDER BY ALTF__Order_Number__c
            ];
        }
        return [
            SELECT Id, Name, ALTF__AltifyId__c, ALTF__Criterion_Text__c, ALTF__Long_Question__c,
                ALTF__Help__c, ALTF__Question__c, ALTF__Mandatory__c, ALTF__Active__c,
                ALTF__Order_Number__c
            FROM ALTF__Assessment_Question__c
            WHERE ALTF__AltifyId__c IN :codes AND ALTF__Active__c = TRUE
            ORDER BY ALTF__Order_Number__c
        ];
    }

    /**
     * The deal's own plan-type value, read through the org's own pointer. Null wherever the chain
     * cannot be walked, which the caller reads as "every active question" rather than as an error.
     */
    @TestVisible
    private static String planTypeOf(Id opportunityId) {
        if (opportunityId == null) {
            return null;
        }
        List<ALTF__Opportunity_Manager_Settings__c> settings = [
            SELECT ALTF__Opportunity_Plan_Type__c
            FROM ALTF__Opportunity_Manager_Settings__c
            LIMIT 1
        ];
        if (settings.isEmpty() || String.isBlank(settings[0].ALTF__Opportunity_Plan_Type__c)) {
            return null;
        }
        String fieldName = settings[0].ALTF__Opportunity_Plan_Type__c.trim();

        // VALIDATED, NEVER CONCATENATED BLIND. A settings row is org configuration and not user
        // input, and it is still checked against the describe before it reaches a query.
        Map<String, Schema.SObjectField> fields =
            Opportunity.SObjectType.getDescribe().fields.getMap();
        Schema.SObjectField f = fields.get(fieldName.toLowerCase());
        if (f == null || !f.getDescribe().isAccessible()) {
            return null;
        }

        List<sObject> rows = Database.query(
            'SELECT ' + f.getDescribe().getName() +
            ' FROM Opportunity WHERE Id = :opportunityId LIMIT 1'
        );
        if (rows.isEmpty()) {
            return null;
        }
        Object v = rows[0].get(f.getDescribe().getName());
        return v == null ? null : String.valueOf(v);
    }

    /**
     * Whose mouth this question requires, from configuration, defaulting to `Any_Participant`
     * where an org states nothing. Never guessed from the question's words at runtime: reading
     * a proposition to decide who may answer it would be inference standing in for a ruling.
     */
    @TestVisible
    private static Map<String, String> speakerRequirements() {
        Map<String, String> out = new Map<String, String>();
        for (AAO_Assessment_Stage__mdt m : [
            SELECT AAO_Question_Code__c, AAO_Speaker_Requirement__c
            FROM AAO_Assessment_Stage__mdt
            WHERE AAO_Question_Code__c != null AND AAO_Speaker_Requirement__c != null
        ]) {
            out.put(m.AAO_Question_Code__c, m.AAO_Speaker_Requirement__c);
        }
        return out;
    }

    private static Map<String, String> requirementCache;

    private static String speakerRequirementFor(String code) {
        if (requirementCache == null) {
            requirementCache = speakerRequirements();
        }
        String r = requirementCache.get(code);
        return String.isBlank(r) ? 'Any_Participant' : r;
    }

    /**
     * Mint the contracts for THIS DEAL'S applicable set.
     *
     * **CONTRACTS STAY PLAN-TYPE-AGNOSTIC** (133rd, item ii): identity is still the question
     * record id plus its content hash, so one question shared by two plan types is ONE contract
     * and the deal's applicable set decides which contracts ride that deal's reads. **Selection
     * at dispatch, never a second mint.** A question a new plan type introduces mints on first
     * encounter, which is the ingest-time reconciler arriving through its first real consumer.
     */
    public static Result mint(Id opportunityId) {
        requirementCache = null;
        Result r = new Result();
        List<ALTF__Assessment_Question__c> qs = discoverQuestions(opportunityId);
        r.read = qs.size();
        if (qs.isEmpty()) {
            r.notes.add(
                'No assessment questions are reachable for this deal through the org\'s own ' +
                'plan-type chain, and none are active. Process reads nothing, which is graceful ' +
                'absence rather than an error.'
            );
            return r;
        }

        Set<String> codes = new Set<String>();
        for (ALTF__Assessment_Question__c q : qs) {
            codes.add(q.ALTF__AltifyId__c);
        }
        // READ BEFORE WRITE, the hundred-sixteenth's law: the standing rows for this key set
        // first, branch before any DML is composed.
        Map<String, AAO_Evidence_Contract__c> standing =
            new Map<String, AAO_Evidence_Contract__c>();
        for (AAO_Evidence_Contract__c ec : [
            SELECT Id, AAO_Proposition_Code__c, AAO_Content_Hash__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Proposition_Code__c IN :codes
              AND AAO_Rubric_Version__c = :AAO_PassContracts.RUBRIC_VERSION
              AND AAO_Contract_State__c NOT IN :AAO_ContractState.DEAD
        ]) {
            standing.put(ec.AAO_Proposition_Code__c, ec);
        }

        // ===== A RETIRED CONTRACT IS NOT RE-MINTED, and this fix is what made that reachable.
        //
        // Read-before-write above asks for LIVE contracts, so a retired one is not found - and
        // without this the next mint would create a fresh contract for the same question and
        // **silently undo a deliberate retirement.** That is the
        // correction-that-disables-what-it-corrects shape, and it became reachable the moment the
        // applicable set stopped being a constant: this org holds twenty-one active questions and
        // six of them are the experiment's, whose contracts the hundred-twenty-ninth retired as
        // *"an experiment's output... never live in a pass"*. Every deal here carries a null plan
        // type, which resolves to every active question, so those six arrive on the very first
        // run of the fixed path.
        //
        // `AAO_Criteria.mint` already refuses an upsert onto a retired row for the identical
        // reason and in almost these words. It THROWS; this SKIPS, and the difference is
        // deliberate: a criterion mint is one row in one run, while throwing here would make an
        // entire class of deals unrunnable for a reason that is ours rather than the org's. The
        // question stays active in their rubric, we decline to carry it, and the note says so
        // rather than either side happening silently.
        Set<String> retired = new Set<String>();
        for (AAO_Evidence_Contract__c ec : [
            SELECT AAO_Proposition_Code__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Proposition_Code__c IN :codes
              AND AAO_Contract_State__c = :AAO_ContractState.RETIRED
        ]) {
            retired.add(ec.AAO_Proposition_Code__c);
        }

        List<AAO_Evidence_Contract__c> toInsert = new List<AAO_Evidence_Contract__c>();
        for (ALTF__Assessment_Question__c q : qs) {
            String code = q.ALTF__AltifyId__c;
            if (retired.contains(code) && !standing.containsKey(code)) {
                r.retired++;
                r.notes.add(
                    code + ': a RETIRED contract stands for this question and no live one does, ' +
                    'so nothing is minted. Re-minting would undo a deliberate retirement by ' +
                    'creating a fresh contract for the same question.'
                );
                continue;
            }
            String proposition = String.isNotBlank(q.ALTF__Long_Question__c)
                ? q.ALTF__Long_Question__c
                : q.ALTF__Criterion_Text__c;
            AAO_Discovery.Elements el = AAO_Discovery.parseElements(q.ALTF__Help__c, proposition);
            if (el.elements == null || el.elements.isEmpty()) {
                // The eightieth stamp's mint law, and it reaches a DISCOVERED contract exactly
                // as it reaches an authored one: elements are how completeness is expressed.
                throw new ProcessContractException(
                    'Assessment question "' + code + '" declares no elements, so nothing can ' +
                    'ever say how much of it a set of words answers. Its Help field carries no ' +
                    'element block. Nothing was minted.'
                );
            }
            String hash = AAO_ContractKey.contentHash(proposition, q.ALTF__Help__c);
            AAO_Evidence_Contract__c already = standing.get(code);
            if (already != null && already.AAO_Content_Hash__c == hash) {
                r.reused++;
                continue;
            }
            if (already != null) {
                r.notes.add(
                    code + ': the org edited the question, so this is a new generation. The ' +
                    'previous contract stands and is superseded rather than replaced, because ' +
                    'claims adjudicated under the old words were adjudicated against something ' +
                    'the new one does not say.'
                );
            }
            toInsert.add(new AAO_Evidence_Contract__c(
                AAO_Question_Record_Id__c = q.Id,
                AAO_Proposition_Code__c = code,
                AAO_Proposition_Short__c = q.ALTF__Criterion_Text__c,
                AAO_Proposition_Text__c = proposition,
                AAO_Guidance_Text__c = q.ALTF__Help__c,
                AAO_Elements__c = JSON.serialize(el.elements),
                AAO_Element_Count__c = el.elements.size(),
                AAO_Elements_Basis__c = el.basis,
                AAO_Route__c = 'E',
                // OURS AND UNDISCOVERABLE, so it is CONFIGURATION: Altify carries no speaker
                // requirement anywhere, and a discovered question cannot say whose mouth answers
                // it. Seeded on `AAO_Assessment_Stage__mdt` beside the by-stage marker and the
                // computed predicate, org-overridable, falling back to `Any_Participant` where
                // an org states nothing. Thirteen of the fifteen carry `Buyer_Side` because
                // their OWN element text names the customer's mouth.
                AAO_Speaker_Requirement__c = speakerRequirementFor(code),
                AAO_Decay_Class__c = 'Standing',
                // ===== TRUE, AND IT WAS FALSE HERE UNTIL (c) MEASURED WHY.
                //
                // **The false was mine and it answered the wrong question.** The comment that
                // stood here reasoned about the VENDOR's `Mandatory`, which gates stage movement
                // and is the vendor's job, and concluded ours should be false to avoid copying
                // theirs. But `AAO_Gating__c` is not the vendor's field wearing our name: it is
                // the field that drives OUR methodological red-flag family, `AAO_Flags`, which
                // is built and wired and has been since session 2. Setting it false meant the
                // fifteen deal-killer questions raised no deal-killer flags at all.
                //
                // The inversion law settles it in one line (120th): **an assessment question IS
                // a deal-killer test.** All fifteen, by construction.
                //
                // The two fields are still two jobs, and that is the answer to the 128th's item
                // 7 rather than a contradiction of the 122nd: `AAO_Gating__c` says THIS QUESTION
                // IS A DEAL-KILLER TEST AT ALL, which is what raises the standing flag at deal
                // creation; the BY-STAGE marker says WHEN AN UNANSWERED ONE READS RED. One fact
                // about the question, one fact about the clock, neither doing the other's work.
                AAO_Gating__c = true,
                AAO_Solicit__c = false,
                AAO_Family__c = AAO_ApplicableSet.PROCESS,
                AAO_Charter_Designation__c = AAO_ApplicableSet.PROCESS,
                AAO_Contract_State__c = el.basis == 'Inferred_Pending'
                    ? 'Awaiting_Ratification'
                    : 'Derived',
                AAO_Requires_Ratification__c = el.basis == 'Inferred_Pending',
                AAO_Rubric_Version__c = AAO_PassContracts.RUBRIC_VERSION,
                AAO_Content_Hash__c = hash,
                // **THE KEY IS NOT SET HERE AT ALL, and it never should have been.**
                //
                // `AAO_EvidenceContractTrigger` composes it unconditionally in before-insert
                // from `AAO_Question_Record_Id__c`, which is set two lines up, so this line was
                // overwritten the moment the row hit the org. `AAO_Discovery` has always relied
                // on the trigger and set nothing; this path set it too, which is the same rule
                // implemented twice - and the twenty-eighth stamp's answer to that is one
                // implementation, always.
                //
                // The second implementation was not merely redundant, it was the one that could
                // break: it passed the CODE where `AAO_ContractKey.compose` names its parameter
                // `questionRecordId` and refuses anything over 18 characters. That worked only
                // because our fifteen BANT codes are short. `ALTF__AltifyId__c` on a DISCOVERED
                // question is whatever the customer's rubric carries, and a nineteen-character
                // one would have thrown here, in the caller, before the trigger it duplicates
                // could compose the correct key from the record id sitting right beside it.
                //
                // LAW #1's shape one more time, and I reported the symptom as an "18-character
                // proposition-code ceiling" before reading the mechanism. There is no such
                // ceiling on a discovered contract. There was a caller doing the trigger's job
                // badly.
                //
                // Nothing migrates: the trigger already wrote every standing key from the record
                // id, so removing this line changes no row and corrects no data. It removes a
                // throw that would have fired in someone else's org.
                AAO_Synthetic__c = AAO_Synthetic.MARK
            ));
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
            r.minted = toInsert.size();
        }
        return r;
    }
}
