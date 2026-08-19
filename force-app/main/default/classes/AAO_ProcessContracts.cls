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
        public List<String> notes = new List<String>();
        public override String toString() {
            return 'PROCESS CONTRACTS\n  questions read ' + read +
                '\n  contracts minted ' + minted + ', reused ' + reused +
                (notes.isEmpty() ? '' : '\n  ' + String.join(notes, '\n  '));
        }
    }

    /**
     * The org's assessment questions, reached the way the org itself chains them: the plan type
     * carries ALTIFY CODES in a 255-character comma-delimited string, and those join to
     * `ALTF__AltifyId__c`. Splitting that on commas and querying by Id finds nothing and reports
     * an empty rubric - `AAO_Discovery` wrote that down and this reads it rather than rediscover.
     */
    public static List<ALTF__Assessment_Question__c> discoverQuestions() {
        List<ALTF__Opportunity_Plan_Type_List__c> pts = [
            SELECT ALTF__AssessmentQuestionIds__c
            FROM ALTF__Opportunity_Plan_Type_List__c
            WHERE Name = :PLAN_TYPE
            LIMIT 1
        ];
        if (pts.isEmpty() || String.isBlank(pts[0].ALTF__AssessmentQuestionIds__c)) {
            // GRACEFUL ABSENCE, never an error: an org with no assessment plan type configured
            // is a licensed-module question, and the 2 August ruling says absence reads as
            // absence with a configuration note.
            return new List<ALTF__Assessment_Question__c>();
        }
        Set<String> codes = new Set<String>();
        for (String c : pts[0].ALTF__AssessmentQuestionIds__c.split(',')) {
            if (String.isNotBlank(c)) {
                codes.add(c.trim());
            }
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

    public static Result mint() {
        Result r = new Result();
        List<ALTF__Assessment_Question__c> qs = discoverQuestions();
        r.read = qs.size();
        if (qs.isEmpty()) {
            r.notes.add(
                'No assessment questions reachable through plan type "' + PLAN_TYPE + '". ' +
                'Process reads nothing, which is graceful absence rather than an error.'
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
              AND AAO_Contract_State__c != 'Superseded'
        ]) {
            standing.put(ec.AAO_Proposition_Code__c, ec);
        }

        List<AAO_Evidence_Contract__c> toInsert = new List<AAO_Evidence_Contract__c>();
        for (ALTF__Assessment_Question__c q : qs) {
            String code = q.ALTF__AltifyId__c;
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
                // Ours and undiscoverable: Altify carries no speaker requirement anywhere.
                AAO_Speaker_Requirement__c = 'Any_Participant',
                AAO_Decay_Class__c = 'Standing',
                // NOT the vendor's Mandatory. That gates STAGE MOVEMENT and is the vendor's job;
                // ours is the by-stage red-flag marker. Two gates, two jobs (122nd, item 2).
                AAO_Gating__c = false,
                AAO_Solicit__c = false,
                AAO_Family__c = AAO_ApplicableSet.PROCESS,
                AAO_Charter_Designation__c = AAO_ApplicableSet.PROCESS,
                AAO_Contract_State__c = el.basis == 'Inferred_Pending'
                    ? 'Awaiting_Ratification'
                    : 'Derived',
                AAO_Requires_Ratification__c = el.basis == 'Inferred_Pending',
                AAO_Rubric_Version__c = AAO_PassContracts.RUBRIC_VERSION,
                AAO_Content_Hash__c = hash,
                AAO_Contract_Key__c = AAO_ContractKey.compose(code, hash),
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
