/**
 * Discovery. Evidence Contracts assembled by READING the org's own rubric tables, rather
 * than typed into ours.
 *
 * This is the standing hazard rehearsed for real. Every customer org has its own rubric,
 * authored by that customer, and a build that only works against a rubric we typed in works
 * nowhere. The receipt is at the bottom of this class: the same accumulation exit test,
 * same expected outcomes, with contracts the org produced.
 *
 * WHAT THE ORG ACTUALLY LOOKS LIKE, read on 31 July and not inferred. Every one of these
 * cost a query, and every one of them would have broken a plausible guess:
 *
 *   ALTF__Assessment_Question__c is the rubric row, and it is ORG-GLOBAL. It has no plan
 *   type lookup, no opportunity lookup, and no relationship to anything. The set of
 *   questions is one flat list per org.
 *
 *   ALTF__Question__c is NOT the question. It is a restricted picklist of five assessment
 *   categories: "Is the renewal at risk?", "Is there an opportunity?", "Can we compete?",
 *   "Can we win?", "Is it worth winning?". The question text lives in
 *   ALTF__Criterion_Text__c, required, 255 characters.
 *
 *   ALTF__Help__c is a 1024-character textarea. It is the only field on the question that
 *   can carry element decomposition, which makes it the Authored path or nothing.
 *
 *   ALTF__Opportunity_Plan_Type_List__c.ALTF__AssessmentQuestionIds__c is the plan-type
 *   chain, and its name is a lie. It holds ALTIFY CODES, not Salesforce ids:
 *   "TC_1,TC_2,TC_4,TC_5,AC_1,RC_11". Comma delimited, 255 characters, which bounds how
 *   many questions a plan type can carry. Those codes join to
 *   ALTF__Assessment_Question__c.ALTF__AltifyId__c. An implementation that split this on
 *   commas and queried by Id would find nothing and report an empty rubric.
 *
 *   The nine plan types in this org already list codes for questions that DO NOT EXIST
 *   here, and ALTF__Show_Assessment__c is false on every one of them. That is the customer
 *   condition, not a broken sandbox: config referencing a question set nobody loaded.
 *
 *   ALTF__Assessment_Answer__c points at ALTF__Opportunity__c, not at the standard
 *   Opportunity. The Altify Opportunity is a separate record carrying a required lookup to
 *   the standard one, and it does not exist until something creates it. That is the cold
 *   start.
 *
 * WHAT THE ORG DOES NOT CARRY, which matters more than what it does. There is no speaker
 * requirement anywhere on the Altify question, and no route. Neither can be discovered
 * because neither exists to discover. They are supplied below by our own overlay, and that
 * overlay is named in the journal as the thing a real customer org will need. Inventing
 * them from the category picklist and calling it discovery would be improvising rule data
 * and then reporting it as a read.
 */
public class AAO_Discovery {
    public class DiscoveryException extends Exception {
    }

    /** Our own plan type, so the nine the customer already configured are not touched. */
    public static final String PLAN_TYPE = 'AAO Discovery';
    public static final String OPP = 'AAO Discovery - Derived Contracts';
    public static final String RUBRIC_VERSION = 'discovered-v1';

    /**
     * Route is OUR convention, mapped from Altify's five assessment categories. Altify has
     * no route concept. Recorded here rather than buried so nobody later reads a route off
     * a contract and believes the customer authored it.
     */
    private static final Map<String, String> ROUTE_BY_CATEGORY = new Map<String, String>{
        'Can we compete?' => 'C',
        'Can we win?' => 'P',
        'Is it worth winning?' => 'E',
        'Is there an opportunity?' => 'E',
        'Is the renewal at risk?' => 'E'
    };

    // ============================================================ a. author the rubric

    /**
     * The six propositions written into Altify's own question table, in Altify's shape.
     * Elements go into Help, because Help is the only field that can hold them, and one
     * proposition is deliberately authored WITHOUT an elements block so the honest
     * Inferred_Pending path is exercised rather than assumed.
     */
    public static String authorRubric() {
        Map<String, Object> fixture = AAO_Seed.fixture();
        List<Object> rubric = (List<Object>) fixture.get('rubric');

        List<String> codes = new List<String>();
        for (Object o : rubric) {
            codes.add((String) ((Map<String, Object>) o).get('code'));
        }

        Map<String, ALTF__Assessment_Question__c> existing = questionsByCode(
            new Set<String>(codes)
        );
        List<ALTF__Assessment_Question__c> toInsert = new List<ALTF__Assessment_Question__c>();
        List<ALTF__Assessment_Question__c> toUpdate = new List<ALTF__Assessment_Question__c>();
        Integer order = 1;

        for (Object o : rubric) {
            Map<String, Object> q = (Map<String, Object>) o;
            String code = (String) q.get('code');
            ALTF__Assessment_Question__c row = existing.get(code);
            if (row != null) {
                // Re-author in place. ALTF__AltifyId__c is unique, so a second insert is a
                // DUPLICATE_VALUE, and the point of re-authoring is to move the sentence
                // from Criterion_Text into Long_Question.
                row.Name = (String) q.get('short');
                row.ALTF__Criterion_Text__c = (String) q.get('short');
                row.ALTF__Long_Question__c = (String) q.get('proposition');
                row.ALTF__Help__c = helpTextFor(q);
                row.ALTF__Order_Number__c = order++;
                row.ALTF__Active__c = true;
                row.ALTF__Mandatory__c = (Boolean) q.get('gating');
                toUpdate.add(row);
                continue;
            }
            toInsert.add(
                new ALTF__Assessment_Question__c(
                    Name = (String) q.get('short'),
                    // UNIQUE. Proven by a DUPLICATE_VALUE on the second run, which makes
                    // it the natural external key for a rubric question and the thing a
                    // real discovery should upsert on.
                    ALTF__AltifyId__c = code,
                    // Required, restricted to five values, and it is the CATEGORY.
                    ALTF__Question__c = categoryFor(code),
                    // Criterion Text is the SHORT TITLE, "Budget Confirmed" style, and
                    // Long Question carries the sentence. The field labelled "Question
                    // Text" in this org is ALTF__Long_Question__c, and production's
                    // glossary rules it the proposition. Noted in the journal: this org's
                    // inline help on Criterion_Text disagrees, so discovery reads Long
                    // Question and falls back rather than assuming either convention.
                    ALTF__Criterion_Text__c = (String) q.get('short'),
                    ALTF__Long_Question__c = (String) q.get('proposition'),
                    ALTF__Help__c = helpTextFor(q),
                    ALTF__Order_Number__c = order++,
                    ALTF__Active__c = true,
                    ALTF__Mandatory__c = (Boolean) q.get('gating'),
                    ALTF__Yes_Label__c = 'Yes',
                    ALTF__No_Label__c = 'No'
                )
            );
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }

        // The plan-type chain. A NEW row, so the nine the customer configured are left
        // exactly as they are.
        List<ALTF__Opportunity_Plan_Type_List__c> pts = [
            SELECT Id, ALTF__AssessmentQuestionIds__c, ALTF__Show_Assessment__c
            FROM ALTF__Opportunity_Plan_Type_List__c
            WHERE Name = :PLAN_TYPE
            LIMIT 1
        ];
        String joined = String.join(codes, ',');
        if (joined.length() > 255) {
            throw new DiscoveryException(
                'The plan type carries its question list in a 255 character string, and ' +
                'this rubric needs ' +
                joined.length() +
                '. That ceiling is a real constraint on rubric size in any org.'
            );
        }
        if (pts.isEmpty()) {
            insert new ALTF__Opportunity_Plan_Type_List__c(
                Name = PLAN_TYPE,
                ALTF__AssessmentQuestionIds__c = joined,
                ALTF__Show_Assessment__c = true
            );
        } else {
            pts[0].ALTF__AssessmentQuestionIds__c = joined;
            pts[0].ALTF__Show_Assessment__c = true;
            update pts[0];
        }

        return 'AUTHORED\n  questions inserted ' +
            toInsert.size() +
            ', re-authored ' +
            toUpdate.size() +
            '\n  questions present ' +
            questionsByCode(new Set<String>(codes)).size() +
            '\n  plan type "' +
            PLAN_TYPE +
            '" carries ' +
            joined;
    }

    /**
     * Guidance plus the element decomposition, in a form a reader can parse back out.
     * AAO_T5 is authored WITHOUT the block on purpose: its elements are Inferred_Pending
     * in the rubric and discovery has to be able to say so honestly rather than inventing
     * an Authored basis it did not read.
     */
    private static String helpTextFor(Map<String, Object> q) {
        String out = (String) q.get('guidance');
        if (q.get('elementsBasis') != 'Authored') {
            return out;
        }
        List<String> lines = new List<String>{ out, '', 'Elements:' };
        for (Object eo : (List<Object>) q.get('elements')) {
            Map<String, Object> e = (Map<String, Object>) eo;
            lines.add('- ' + e.get('id') + ': ' + e.get('text'));
        }
        return String.join(lines, '\n');
    }

    private static String categoryFor(String code) {
        if (code == 'AAO_T3' || code == 'AAO_T6') {
            return 'Can we compete?';
        }
        if (code == 'AAO_T1') {
            return 'Is it worth winning?';
        }
        return 'Can we win?';
    }

    /**
     * Queried by explicit code rather than by a LIKE pattern. The first attempt used
     * LIKE 'AAO\\_%' to match our prefix and matched nothing: the underscore is a SOQL
     * single-character wildcard, escaping it inside an Apex string literal is not a
     * documented escape sequence, and the query failed silently by returning zero rows
     * rather than erroring. Discovery then reported an empty rubric against a rubric that
     * was sitting right there. The codes are always known, so ask for them by name.
     */
    private static Map<String, ALTF__Assessment_Question__c> questionsByCode(
        Set<String> codes
    ) {
        Map<String, ALTF__Assessment_Question__c> byCode = new Map<String, ALTF__Assessment_Question__c>();
        for (ALTF__Assessment_Question__c q : [
            SELECT
                Id,
                Name,
                ALTF__AltifyId__c,
                ALTF__Question__c,
                ALTF__Criterion_Text__c,
                ALTF__Long_Question__c,
                ALTF__Help__c,
                ALTF__Active__c,
                ALTF__Mandatory__c,
                ALTF__Order_Number__c
            FROM ALTF__Assessment_Question__c
            WHERE ALTF__AltifyId__c IN :codes
        ]) {
            byCode.put(q.ALTF__AltifyId__c, q);
        }
        return byCode;
    }

    // ========================================================== b. the discovery pass

    public class Derived {
        public Map<String, AAO_Evidence_Contract__c> byCode =
            new Map<String, AAO_Evidence_Contract__c>();
        public List<String> notes = new List<String>();
        public Integer authored = 0;
        public Integer inferred = 0;
        public Integer reused = 0;
        /** Old generations retired because their upstream text changed. */
        public Integer superseded = 0;
    }

    /**
     * Read the chain, assemble contracts. Settings names a plan type by STRING; the plan
     * type row carries codes; the codes join to the question's AltifyId; the question
     * carries the text and the Help.
     */
    public static Derived discover() {
        Derived d = new Derived();

        List<ALTF__Opportunity_Plan_Type_List__c> pts = [
            SELECT Name, ALTF__AssessmentQuestionIds__c, ALTF__Show_Assessment__c
            FROM ALTF__Opportunity_Plan_Type_List__c
            WHERE Name = :PLAN_TYPE
            LIMIT 1
        ];
        if (pts.isEmpty()) {
            throw new DiscoveryException(
                'No plan type "' + PLAN_TYPE + '". Author the rubric first.'
            );
        }
        String raw = pts[0].ALTF__AssessmentQuestionIds__c;
        if (String.isBlank(raw)) {
            throw new DiscoveryException(
                'Plan type "' + PLAN_TYPE + '" lists no questions.'
            );
        }
        List<String> codes = raw.split(',');
        Set<String> wanted = new Set<String>();
        for (String c : codes) {
            wanted.add(c.trim());
        }
        d.notes.add('plan type ' + PLAN_TYPE + ' lists ' + codes.size() + ' codes');

        Map<String, ALTF__Assessment_Question__c> byCode = questionsByCode(wanted);

        // What discovery has already derived. Ruled session 15: a derived contract is real
        // system output, not a rehearsal row, so it is NOT marked synthetic and is never
        // deleted. Re-running discovery against unchanged text must find the same contract
        // rather than make a second one, and the contract key is exactly the test for
        // that: question record id plus the hash of its proposition and guidance. Unchanged
        // text, same key, same contract.
        Map<String, AAO_Evidence_Contract__c> existingByKey =
            new Map<String, AAO_Evidence_Contract__c>();
        // Every live generation, by the rubric question it came from. A second generation
        // of the same question means the customer edited the text, and the old one has to
        // be retired without being destroyed.
        Map<String, List<AAO_Evidence_Contract__c>> liveByQuestion =
            new Map<String, List<AAO_Evidence_Contract__c>>();
        for (AAO_Evidence_Contract__c ec : [
            SELECT
                Id,
                AAO_Contract_Key__c,
                AAO_Proposition_Code__c,
                AAO_Question_Record_Id__c,
                AAO_Elements_Basis__c,
                AAO_Element_Count__c,
                AAO_Contract_State__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Rubric_Version__c = :RUBRIC_VERSION
        ]) {
            existingByKey.put(ec.AAO_Contract_Key__c, ec);
            if (ec.AAO_Contract_State__c != 'Superseded') {
                if (!liveByQuestion.containsKey(ec.AAO_Question_Record_Id__c)) {
                    liveByQuestion.put(
                        ec.AAO_Question_Record_Id__c,
                        new List<AAO_Evidence_Contract__c>()
                    );
                }
                liveByQuestion.get(ec.AAO_Question_Record_Id__c).add(ec);
            }
        }

        // ITEM 37. "The table has no rows" and "my query matched none of them" are
        // different facts and only one of them is the customer's fault. Reporting an
        // empty rubric for the second is how the LIKE defect hid: a filter bug looks
        // exactly like an org nobody has configured, and it looks like it silently.
        if (byCode.isEmpty()) {
            Integer inTable = [SELECT COUNT() FROM ALTF__Assessment_Question__c];
            if (inTable > 0) {
                throw new DiscoveryException(
                    'DISCOVERY FILTER FAULT, not an empty rubric. ' +
                    'ALTF__Assessment_Question__c holds ' +
                    inTable +
                    ' rows and the plan type "' +
                    PLAN_TYPE +
                    '" lists ' +
                    wanted.size() +
                    ' codes (' +
                    String.join(new List<String>(wanted), ',') +
                    '), and none of them matched ALTF__AltifyId__c. The rubric exists and ' +
                    'this query cannot see it. Do not report this as an unconfigured org.'
                );
            }
            throw new DiscoveryException(
                'The rubric is genuinely empty: ALTF__Assessment_Question__c holds no ' +
                'rows at all. This is the cold-start condition, not a fault.'
            );
        }
        List<AAO_Evidence_Contract__c> toInsert = new List<AAO_Evidence_Contract__c>();

        for (String c : codes) {
            String code = c.trim();
            ALTF__Assessment_Question__c q = byCode.get(code);
            if (q == null) {
                // Exactly the condition this org is already in on its own nine plan types.
                d.notes.add(
                    code + ': listed by the plan type and absent from the question table'
                );
                continue;
            }
            if (q.ALTF__Active__c != true) {
                d.notes.add(code + ': present and inactive, skipped');
                continue;
            }

            // The proposition is the SENTENCE. This org labels ALTF__Long_Question__c
            // "Question Text" and production's glossary rules it the proposition, with
            // Criterion Text a short title. But this org's own inline help on
            // Criterion_Text says the opposite, so the read falls back rather than
            // assuming, and says which field it used.
            String propositionText = String.isNotBlank(q.ALTF__Long_Question__c)
                ? q.ALTF__Long_Question__c
                : q.ALTF__Criterion_Text__c;
            String shortTitle = String.isNotBlank(q.ALTF__Long_Question__c)
                ? q.ALTF__Criterion_Text__c
                : q.Name;
            if (String.isBlank(q.ALTF__Long_Question__c)) {
                d.notes.add(
                    code +
                    ': Long Question is empty, so the proposition was read from ' +
                    'Criterion Text. In an org that authors the sentence there, that is ' +
                    'correct; in an org that authors a short title there, this contract ' +
                    'carries a title where a proposition belongs.'
                );
            }

            Elements el = parseElements(q.ALTF__Help__c, propositionText);
            if (el.basis == 'Authored') {
                d.authored++;
            } else {
                d.inferred++;
            }

            String expectedKey = AAO_ContractKey.compose(
                q.Id,
                AAO_ContractKey.contentHash(propositionText, q.ALTF__Help__c)
            );
            AAO_Evidence_Contract__c already = existingByKey.get(expectedKey);
            if (already != null) {
                d.byCode.put(code, already);
                d.reused++;
                d.notes.add(code + ': unchanged since the last pass, contract reused');
                continue;
            }
            if (liveByQuestion.containsKey(q.Id)) {
                // Same rubric question, different content hash. The customer edited the
                // words, and a claim adjudicated under the old words was adjudicated
                // against something this new contract does not say.
                d.notes.add(
                    code +
                    ': upstream text changed, so this is a new generation and the previous ' +
                    'one is superseded rather than replaced'
                );
            }

            toInsert.add(
                new AAO_Evidence_Contract__c(
                    // Identity is the rubric record itself, at last. Until tonight this
                    // was the fixture code because there was no record to point at.
                    AAO_Question_Record_Id__c = q.Id,
                    AAO_Proposition_Code__c = code,
                    AAO_Proposition_Short__c = shortTitle,
                    // Verbatim. Not summarised, not reformatted. The content hash covers
                    // this text and an edit upstream must surface as a new contract.
                    AAO_Proposition_Text__c = propositionText,
                    AAO_Guidance_Text__c = q.ALTF__Help__c,
                    AAO_Elements__c = JSON.serialize(el.elements),
                    AAO_Element_Count__c = el.elements.size(),
                    AAO_Elements_Basis__c = el.basis,
                    // Ours, not Altify's. See ROUTE_BY_CATEGORY.
                    AAO_Route__c = route(q.ALTF__Question__c),
                    // Ours, and undiscoverable. Altify carries no speaker requirement.
                    AAO_Speaker_Requirement__c = 'Any_Participant',
                    AAO_Decay_Class__c = 'Standing',
                    AAO_Gating__c = q.ALTF__Mandatory__c == true,
                    AAO_Solicit__c = false,
                    AAO_Requires_Ratification__c = el.basis == 'Inferred_Pending',
                    AAO_Contract_State__c = el.basis == 'Inferred_Pending'
                        ? 'Awaiting_Ratification'
                        : 'Derived',
                    AAO_Rubric_Version__c = RUBRIC_VERSION
                )
            );
        }
        if (d.byCode.isEmpty() && toInsert.isEmpty()) {
            throw new DiscoveryException('Discovery produced no contracts.');
        }
        if (!toInsert.isEmpty()) {
            // Deliberately UNMARKED. A derived contract is what the system read out of the
            // customer's own rubric; it is real output, not a rehearsal artefact, and the
            // synthetic marker would say otherwise. It is therefore also undeletable under
            // the session 14 law, which is correct: supersede is its retirement path.
            Boolean prior = AAO_Synthetic.MARK;
            AAO_Synthetic.MARK = false;
            try {
                insert toInsert;
            } finally {
                AAO_Synthetic.MARK = prior;
            }
            for (AAO_Evidence_Contract__c ec : toInsert) {
                d.byCode.put(ec.AAO_Proposition_Code__c, ec);
            }

            // Retire the generation this one replaces. Never delete: the delete law exists
            // because every claim stamped with the old contract still names it, and those
            // claims were adjudicated against words the new contract does not carry.
            // Superseded keeps them explicable forever.
            List<AAO_Evidence_Contract__c> retire = new List<AAO_Evidence_Contract__c>();
            for (AAO_Evidence_Contract__c fresh : toInsert) {
                List<AAO_Evidence_Contract__c> priors = liveByQuestion.get(
                    fresh.AAO_Question_Record_Id__c
                );
                if (priors == null) {
                    continue;
                }
                for (AAO_Evidence_Contract__c previous : priors) {
                    if (previous.Id == fresh.Id) {
                        continue;
                    }
                    previous.AAO_Contract_State__c = 'Superseded';
                    previous.AAO_Superseded_By__c = fresh.Id;
                    retire.add(previous);
                }
            }
            if (!retire.isEmpty()) {
                update retire;
                d.superseded = retire.size();
            }
        }
        return d;
    }

    private static String route(String category) {
        String r = ROUTE_BY_CATEGORY.get(category);
        return r == null ? 'E' : r;
    }

    public class Elements {
        public List<Object> elements = new List<Object>();
        public String basis;
    }

    /**
     * Elements out of authored Help where the author named them, and an honest
     * Inferred_Pending where they did not. The number of parts is never unknown, so an
     * unauthored proposition still gets one element, and it is the proposition itself.
     */
    public static Elements parseElements(String help, String propositionText) {
        Elements out = new Elements();
        if (String.isNotBlank(help)) {
            Boolean inBlock = false;
            for (String line : help.split('\n')) {
                String t = line.trim();
                if (t.toLowerCase().startsWith('elements:')) {
                    inBlock = true;
                    continue;
                }
                if (!inBlock || !t.startsWith('-') || !t.contains(':')) {
                    continue;
                }
                String body = t.substring(1).trim();
                String id = body.substringBefore(':').trim();
                String text = body.substringAfter(':').trim();
                if (String.isNotBlank(id) && String.isNotBlank(text)) {
                    out.elements.add(
                        new Map<String, Object>{ 'id' => id, 'text' => text }
                    );
                }
            }
        }
        if (!out.elements.isEmpty()) {
            out.basis = 'Authored';
            return out;
        }
        out.elements.add(
            new Map<String, Object>{ 'id' => 'e1', 'text' => propositionText }
        );
        out.basis = 'Inferred_Pending';
        return out;
    }

    // ============================================================== c. the cold start

    /**
     * A standard Opportunity with no Altify record, then the Altify Opportunity created
     * on top of it. ALTF__Opportunity__c carries a required lookup to the standard
     * Opportunity, and nothing creates it for you.
     */
    public static Id coldStart(Id accountId) {
        List<Opportunity> found = [SELECT Id FROM Opportunity WHERE Name = :OPP LIMIT 1];
        Id oppId;
        if (found.isEmpty()) {
            Opportunity o = new Opportunity(
                Name = OPP,
                AccountId = accountId,
                StageName = AAO_Seed.defaultStage(),
                CloseDate = Date.newInstance(2026, 12, 31)
            );
            insert o;
            oppId = o.Id;
        } else {
            oppId = found[0].Id;
        }

        List<ALTF__Opportunity__c> alt = [
            SELECT Id FROM ALTF__Opportunity__c WHERE ALTF__Opportunity__c = :oppId LIMIT 1
        ];
        if (alt.isEmpty()) {
            insert new ALTF__Opportunity__c(ALTF__Opportunity__c = oppId);
        }
        return oppId;
    }

    // ====================================================== d. the works-anywhere receipt

    /**
     * The accumulation exit test, run against contracts the org produced.
     *
     * Same transcripts, same staged proposals, same expected outcomes as the rehearsal:
     * transcript one writes UNVERIFIED with its receipts, transcript two flips it to TRUE,
     * the first claim is untouched, and replaying the claims rebuilds the answer exactly.
     *
     * The only thing that changed is where the questions came from. That is the whole
     * point: it converts "works in any org" from a claim into a receipt.
     */
    public static String exitTest() {
        Boolean priorAuto = AAO_Ingest.AUTO;
        AAO_Ingest.AUTO = false;
        List<String> out = new List<String>();
        try {
            out.add(purge());
            out.add(authorRubric());

            AAO_Demo.Ctx c = AAO_Demo.scaffold();
            Id oppId = coldStart(c.acct.Id);
            out.add('cold start: opportunity ' + oppId + ' with an Altify Opportunity on it');

            Derived d = discover();
            out.add(
                'DISCOVERED ' +
                d.byCode.size() +
                ' contracts (' +
                d.authored +
                ' Authored, ' +
                d.inferred +
                ' Inferred_Pending, ' +
                d.reused +
                ' reused, ' +
                d.superseded +
                ' superseded)'
            );
            for (String n : d.notes) {
                out.add('  ' + n);
            }
            for (String code : new List<String>{ 'AAO_T1', 'AAO_T5' }) {
                AAO_Evidence_Contract__c ec = d.byCode.get(code);
                if (ec != null) {
                    out.add(
                        '  ' +
                        code +
                        ' questionRecordId=' +
                        ec.AAO_Question_Record_Id__c +
                        ' basis=' +
                        ec.AAO_Elements_Basis__c +
                        ' elements=' +
                        ec.AAO_Element_Count__c +
                        ' state=' +
                        ec.AAO_Contract_State__c
                    );
                }
            }

            // Day-one red against the PRODUCT set, which is what discovery derived. The
            // seeded fixture is marked synthetic and invisible here.
            AAO_Synthetic.MARK = true;
            try {
                out.add(
                    'day-one red: raised ' +
                    AAO_Flags.raiseFor(new Set<Id>{ oppId }, false) +
                    ', standing ' +
                    AAO_Flags.standing(oppId)
                );
            } finally {
                AAO_Synthetic.MARK = false;
            }

            // The pipeline judges against what discovery produced, not against the seed.
            AAO_Pipeline.contractsOverride = d.byCode;
            AAO_Synthetic.MARK = true;
            try {
                for (String code : new List<String>{ 'T1SRC', 'T2SRC' }) {
                    AAO_Source__c src = AAO_Demo.findSource(c, code, oppId);
                    AAO_Pipeline.Outcome o = AAO_Pipeline.runForSource(
                        src.Id,
                        c.internalDomains
                    );
                    out.add('PASS ' + code + ': ' + o);
                }
            } finally {
                AAO_Synthetic.MARK = false;
                AAO_Pipeline.contractsOverride = null;
            }

            out.add('reds standing after both passes: ' + AAO_Flags.standing(oppId));
            out.add(verify(oppId));
            List<String> replayDiff = AAO_Replay.diff(
                AAO_Replay.rebuild(oppId),
                AAO_Replay.liveAnswers(oppId)
            );
            out.add(
                replayDiff.isEmpty()
                    ? 'REPLAY exact=true. The answer rebuilds from its claims, field for ' +
                      'field, with contracts the org produced.'
                    : 'REPLAY exact=false: ' + String.join(replayDiff, '; ')
            );
        } finally {
            AAO_Ingest.AUTO = priorAuto;
        }
        return 'DISCOVERY EXIT TEST\n  ' + String.join(out, '\n  ');
    }

    /** The expected outcomes, asserted rather than eyeballed. */
    private static String verify(Id oppId) {
        List<String> fails = new List<String>();

        List<AAO_Answer__c> answers = [
            SELECT
                AAO_Verdict__c,
                AAO_Element_Completeness__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Evidence_Contract__r.AAO_Question_Record_Id__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :oppId
        ];
        if (answers.size() != 1) {
            fails.add('expected one answer, got ' + answers.size());
        } else {
            if (answers[0].AAO_Verdict__c != 'TRUE') {
                fails.add('expected TRUE, got ' + answers[0].AAO_Verdict__c);
            }
            if (!String.valueOf(answers[0].AAO_Evidence_Contract__r.AAO_Question_Record_Id__c)
                    .startsWith('a')) {
                fails.add(
                    'the answer rests on a contract whose identity is not an Altify record: ' +
                    answers[0].AAO_Evidence_Contract__r.AAO_Question_Record_Id__c
                );
            }
        }

        List<AAO_Claim__c> claims = [
            SELECT AAO_Verdict_Before__c, AAO_Verdict_After__c, AAO_Outcome__c
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :oppId
            ORDER BY AAO_Evidence_Occurred__c
        ];
        if (claims.size() != 2) {
            fails.add('expected two claims, got ' + claims.size());
        } else {
            if (claims[0].AAO_Verdict_Before__c != null ||
                claims[0].AAO_Verdict_After__c != 'UNVERIFIED') {
                fails.add(
                    'claim one should be null to UNVERIFIED, got ' +
                    claims[0].AAO_Verdict_Before__c +
                    ' to ' +
                    claims[0].AAO_Verdict_After__c
                );
            }
            if (claims[1].AAO_Verdict_Before__c != 'UNVERIFIED' ||
                claims[1].AAO_Verdict_After__c != 'TRUE') {
                fails.add(
                    'claim two should be UNVERIFIED to TRUE, got ' +
                    claims[1].AAO_Verdict_Before__c +
                    ' to ' +
                    claims[1].AAO_Verdict_After__c
                );
            }
        }

        return fails.isEmpty()
            ? 'EXIT TEST PASSED against contracts the org produced. ' +
              'UNVERIFIED with receipts, then TRUE, first claim untouched.'
            : 'EXIT TEST FAILED:\n    ' + String.join(fails, '\n    ');
    }

    /** Scoped to the discovery deal and to rows carrying our own codes. */
    public static String purge() {
        List<String> out = new List<String>();
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Name = :OPP];
        AAO_Synthetic.PURGING = true;
        try {
            if (!opps.isEmpty()) {
                Set<Id> ids = new Map<Id, Opportunity>(opps).keySet();
                // Flags too. Purging the deal's evidence and leaving its flags meant a
                // red cleared by a previous run stayed cleared against evidence that no
                // longer existed, so a reset did not return the deal to day one.
                out.add('flags ' + del([
                    SELECT Id FROM AAO_Flag__c
                    WHERE AAO_Opportunity__c IN :ids AND AAO_Synthetic__c = TRUE
                ]));
                out.add('bases ' + del([
                    SELECT Id FROM AAO_Claim_Basis__c
                    WHERE AAO_Claim__r.AAO_Opportunity__c IN :ids AND AAO_Synthetic__c = TRUE
                ]));
                out.add('claims ' + del([
                    SELECT Id FROM AAO_Claim__c
                    WHERE AAO_Opportunity__c IN :ids AND AAO_Synthetic__c = TRUE
                ]));
                out.add('candidates ' + del([
                    SELECT Id FROM AAO_Candidate__c
                    WHERE AAO_Opportunity__c IN :ids AND AAO_Synthetic__c = TRUE
                ]));
                out.add('answers ' + del([
                    SELECT Id FROM AAO_Answer__c
                    WHERE AAO_Opportunity__c IN :ids AND AAO_Synthetic__c = TRUE
                ]));
                out.add('sources ' + del([
                    SELECT Id FROM AAO_Source__c
                    WHERE AAO_Opportunity__c IN :ids AND AAO_Synthetic__c = TRUE
                ]));
            }
            // CONTRACTS ARE NOT PURGED. Ruled session 15: derived contracts are real
            // system output and the session 14 delete law makes them undeletable anyway.
            // Re-running discovery reuses them by contract key, so there is nothing to
            // clean up: unchanged text produces the same key and the same row. A contract
            // whose text HAS changed upstream is superseded, not deleted, and that path is
            // still owed.
            out.add(
                'derived contracts kept ' +
                [
                    SELECT COUNT()
                    FROM AAO_Evidence_Contract__c
                    WHERE AAO_Rubric_Version__c = :RUBRIC_VERSION
                ]
            );
        } finally {
            AAO_Synthetic.PURGING = false;
        }
        return 'purge: ' + String.join(out, ', ');
    }

    private static Integer del(List<SObject> rows) {
        if (!rows.isEmpty()) {
            delete rows;
        }
        return rows.size();
    }
}