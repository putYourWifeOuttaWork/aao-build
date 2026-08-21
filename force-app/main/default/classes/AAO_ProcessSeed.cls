/**
 * THE PROCESS SEEDS · a sandbox that looks like a customer's org, so rubric discovery has
 * something real to discover.
 *
 * Ungated by the hundred-twenty-third stamp: *"SEEDS UNGATED - CODE builds now, per the proposal
 * v0.4 with the 122nd's two rulings: the sandbox sales process (structure from the capture,
 * forecasting machinery VERBATIM, qualifier text ours, the close-planning qualifier included) and
 * the FIFTEEN BANT records with their BY-STAGE markers."*
 *
 * **WHY THIS IS A SEED AND NOT A FEATURE.** The package ships no question text - rubric discovery
 * reads whatever the org authored, which is LAW #1's whole point, because roughly four installs in
 * five will carry a rubric nobody here wrote. Seeding the sandbox does not make our rubric
 * canonical; it makes the sandbox a customer-shaped org so that the discovery path is exercised
 * against org rows rather than against a fixture we can quietly keep in step with the code.
 *
 * **IDEMPOTENT BY READ-BEFORE-WRITE, not by catching a duplicate.** Every row is keyed in
 * `ALTF__AltifyId__c` under the `AAO_SEED` prefix; this reads the standing rows for its key set
 * first and branches before composing any DML, which is the hundred-sixteenth stamp's law rather
 * than a convenience. Those keys are also what make the seed ENUMERABLE as ours on objects that
 * carry no watermark field of their own - the same problem the card writer met, solved the same
 * way.
 *
 * **THE TEXT LIVES HERE RATHER THAN IN `AAO_Seed.json`, deliberately.** The eighty-first stamp
 * named that file as one degree further from a config surface than it looks - shipped defaults and
 * runtime config in one static resource, a debt to be paid once at packaging rather than deepened
 * three lines at a time. This is not configuration: it is content authored once into a sandbox,
 * and it belongs where a reviewer reads it in a diff.
 */
public class AAO_ProcessSeed {

    public class SeedException extends Exception {}

    /** The watermark. Ours-ness on a vendor object that has no field for it. */
    public static final String KEY_PREFIX = 'AAO_SEED';
    public static final String PLAN_TYPE = 'AAO BANT (Sandbox)';
    public static final String PROCESS_NAME = 'AAO New Business (Sandbox)';

    public class Outcome {
        public Integer questionsInserted = 0;
        public Integer questionsUpdated = 0;
        public Integer markersFound = 0;
        public Integer processes = 0;
        public Integer stages = 0;
        public Integer processStages = 0;
        public Integer qualifiers = 0;
        public Integer junctions = 0;
        public List<String> notes = new List<String>();
        public override String toString() {
            return 'SEEDED\n' +
                '  assessment questions inserted ' + questionsInserted +
                ', re-authored ' + questionsUpdated + '\n' +
                '  by-stage markers read ' + markersFound + '\n' +
                '  sales process ' + processes + ', stages ' + stages +
                ', process stages ' + processStages + '\n' +
                '  global qualifiers ' + qualifiers + ', stage junctions ' + junctions + '\n' +
                (notes.isEmpty() ? '' : '  ' + String.join(notes, '\n  '));
        }
    }

    // =============================================================== the fifteen, as graded

    /**
     * §4 of the proposal as Matthew graded it, 19 August: **FIFTEEN, not sixteen.** N2 reworded
     * and opened to the human-established path, N4 reworded to alignment confirmed by the
     * customer, and **T3 dropped by the inversion law's own bar** - not knowing the buying steps
     * kills no deal - its substance moving to the sales process as a mutual-close-planning
     * qualifier. Symmetry never outranks the bar.
     *
     * Each carries ELEMENTS, and that is a requirement rather than a nicety: a contract that
     * declares no elements cannot mint (`AAO_PassContracts`, the eightieth stamp's ruling), so a
     * question authored without them would be seeded into the org and then lawfully refused.
     * Elements are the conjuncts of the question's own sentence, never additions to it.
     */
    private static List<Map<String, Object>> questions() {
        return new List<Map<String, Object>>{
            q('B1', 'A budget exists for this purchase',
              'Has the customer stated that funds are allocated or available for this purchase?',
              new List<String>{ 'the customer states funds are allocated or available',
                                'the funds are for this purchase' }),
            q('B2', 'The budget amount or range is known',
              'Has a figure or range been voiced by the customer?',
              new List<String>{ 'a figure or range is voiced',
                                'it is the customer who voices it' }),
            q('B3', 'The budget holder is identified',
              'Do we know, from the customer\'s words, who owns the funds?',
              new List<String>{ 'a person is named as owning the funds',
                                'the naming comes from the customer\'s words' }),
            q('B4', 'The approval path for funds is understood',
              'Has the customer described how spending this budget gets approved?',
              new List<String>{ 'the customer describes how spending is approved',
                                'the description is of THIS budget' }),
            q('A1', 'The decision maker is identified',
              'Is the person who makes the final call identified on the map from their own or ' +
              'colleagues\' words?',
              new List<String>{ 'a person is identified as making the final call',
                                'the identification rests on their own or a colleague\'s words' }),
            q('A2', 'The decision maker is engaged',
              'Has the decision maker participated directly in a conversation with us?',
              new List<String>{ 'the decision maker participated directly',
                                'the participation was in a conversation with us' }),
            // ===== A3, REWORDED BY MATTHEW'S RULING AT THE HUNDRED-THIRTY-SIXTH.
            //
            // His words: *"Wrong, who else can also be no-one and that is the best answer we can
            // get, rare, but best."* The proof run read *"there is nobody above me on it. It is
            // my decision, full stop"* as a DENIED, and the blind verifier was right to: the
            // contract asked who ELSE must approve, and the customer said nobody else does. **The
            // reader applied the words it was given, faithfully.** The tuning lives in the
            // proposition, which is the a23 class exactly, so the words move and the machinery
            // does not.
            //
            // An empty chain IS a described chain, and the strongest one a deal can hold.
            q('A3', 'The approval chain is understood',
              'Has the customer described the approval chain for this decision? An answer that ' +
              'nobody else must approve IS a description of the chain, and the strongest one.',
              new List<String>{
                  'the customer describes the approval chain, which may end with them'
              }),
            q('A4', 'Access to the decision maker exists',
              'Can we reach the decision maker without a blocker, per the customer\'s words?',
              new List<String>{ 'the decision maker is reachable',
                                'no blocker stands in the way, per the customer\'s words' }),
            q('N1', 'A business problem is confirmed in the customer\'s words',
              'Has the customer stated the problem in their own words?',
              new List<String>{ 'a business problem is stated',
                                'it is stated in the customer\'s own words' }),
            // THE ONE QUESTION WHOSE AFFIRMATIVE DOES NOT REQUIRE THE CUSTOMER'S MOUTH.
            q('N2', 'The problem is quantified',
              'Have the customer\'s problems been quantified? Estimates, user notes and impacts ' +
              'not voiced by the customer are allowed, so this may also be established by a ' +
              'human entry rather than by the customer\'s words.',
              new List<String>{ 'a quantity is attached to the customer\'s problem' }),
            q('N3', 'The consequence of inaction is stated',
              'Has the customer said what happens if nothing changes?',
              new List<String>{ 'the customer states what happens if nothing changes' }),
            q('N4', 'The customer confirms our solution resolves their problem',
              'Has the customer confirmed that our solutions can resolve their problem?',
              new List<String>{ 'the customer confirms our solution resolves the problem',
                                'the confirmation is the customer\'s, not our narration' }),
            q('T1', 'A target date exists',
              'Has the customer voiced a date or period for deciding or implementing?',
              new List<String>{ 'a date or period is voiced',
                                'it is for deciding or implementing' }),
            q('T2', 'A compelling event drives the date',
              'Is the date tied to something real that happens with or without us?',
              new List<String>{ 'the date is tied to a named event',
                                'the event happens with or without us' }),
            q('T4', 'The timeline is confirmed by the decision maker',
              'Has the decision maker, specifically, endorsed the timeline?',
              new List<String>{ 'the timeline is endorsed',
                                'the endorsement is the decision maker\'s specifically' }),
            // ===== MINTED FOR CLOSEPLAN, the fourteenth qualifier and the only one with no
            // BANT equivalent to bind to. Ruled MINT at the hundred-fifty-ninth: a permanent
            // grey row in a product about answers is the worse outcome.
            //
            // The premise was CHECKED against the transcript before minting rather than taken
            // on trust, because a proposition nothing can answer is exactly the grey row the
            // mint exists to avoid. Call 4 carries it almost verbatim - Ingrid: *"here's what
            // has to happen between now and a signature, and I want it written down and
            // shared, not living in anyone's head."*
            //
            // TWO ELEMENTS, because the qualifier's own text is a CONJUNCTION: described AND
            // shared. A close plan written down and never sent is the failure this question
            // exists to catch, so one element would have let it pass.
            q('C1', 'The close plan is described and shared',
              'Have the steps between now and signature been described, and shared with the ' +
              'customer rather than kept on our side?',
              new List<String>{ 'the steps between now and signature are described',
                                'they are shared with the customer' })
        };
    }

    /**
     * The codes, for anything that needs to ASK FOR THEM BY NAME rather than pattern-match.
     *
     * `AAO_Discovery` already paid for this lesson and wrote it down: *"The first attempt used
     * LIKE 'AAO\\_%' to match our prefix and matched nothing: the underscore is a SOQL"*
     * wildcard, so a prefix full of underscores matches loosely in one direction and not at all
     * in the other. **A key set is exact; a LIKE over our own keys is a guess.** This test suite
     * re-learned it in one run, which is the lesson being cheap the second time.
     */
    public static List<String> questionCodes() {
        List<String> out = new List<String>();
        for (Map<String, Object> q : questions()) {
            out.add((String) q.get('code'));
        }
        return out;
    }

    /** Every vendor row this seed owns, by exact key. Enumerable is the point of the watermark. */
    public static Set<String> seedKeys(String kind) {
        Set<String> keys = new Set<String>();
        if (kind == 'STAGE' || kind == 'PS') {
            for (Integer i = 1; i <= 5; i++) {
                keys.add(KEY_PREFIX + '|' + kind + '|' + i);
            }
        }
        return keys;
    }

    private static Map<String, Object> q(
        String suffix, String shortText, String proposition, List<String> elements
    ) {
        List<Object> els = new List<Object>();
        Integer n = 1;
        for (String e : elements) {
            els.add(new Map<String, Object>{ 'id' => 'e' + n++, 'text' => e });
        }
        return new Map<String, Object>{
            'code' => 'AAO_BANT_' + suffix,
            'short' => shortText,
            'proposition' => proposition,
            'elements' => els
        };
    }

    /**
     * OUR OVERLAY ONTO THE VENDOR'S FIVE CATEGORIES, and it is named as an overlay rather than
     * presented as a read. `ALTF__Question__c` is a restricted picklist of five assessment
     * categories and is NOT the question; nothing in the org maps BANT onto them, so this mapping
     * is ours. `AAO_Discovery` already records the same discipline for route, in the same words:
     * inventing a mapping and then reporting it as discovery would be improvising rule data.
     */
    private static String categoryFor(String code) {
        if (code.startsWith('AAO_BANT_A')) {
            // Authority is the political question: who decides, who approves, can we reach them.
            return 'Can we win?';
        }
        if (code == 'AAO_BANT_N4') {
            // Alignment of OUR solution to THEIR problem is the competitive question, not the
            // existence question that the other three Need items ask.
            return 'Can we compete?';
        }
        return 'Is there an opportunity?';
    }

    // =============================================================== the by-stage markers

    /**
     * The stage past which an UNESTABLISHED question becomes a red flag. Org override wins where
     * set; the shipped default stands otherwise. Returns null where no marker exists, and a null
     * marker must never be read as stage zero - a question with no marker simply never reds on
     * absence, only on a voiced no.
     */
    public static Decimal byStageFor(String questionCode) {
        for (AAO_Assessment_Stage__mdt m : AAO_Assessment_Stage__mdt.getAll().values()) {
            if (m.AAO_Question_Code__c == questionCode) {
                return m.AAO_Org_Override__c != null ? m.AAO_Org_Override__c : m.AAO_By_Stage__c;
            }
        }
        return null;
    }

    // =============================================================== the seed

    public static Outcome run() {
        Outcome o = new Outcome();
        seedAssessment(o);
        seedSalesProcess(o);
        return o;
    }

    public static Outcome seedAssessment(Outcome o) {
        List<Map<String, Object>> qs = questions();
        List<String> codes = new List<String>();
        for (Map<String, Object> q : qs) {
            codes.add((String) q.get('code'));
        }

        // READ FIRST, branch before any DML. The hundred-sixteenth's law, and on this object it
        // is also the only safe path: `ALTF__AltifyId__c` is unique here, proven by a
        // DUPLICATE_VALUE on `AAO_Discovery`'s second run.
        Map<String, ALTF__Assessment_Question__c> standing =
            new Map<String, ALTF__Assessment_Question__c>();
        for (ALTF__Assessment_Question__c row : [
            SELECT Id, ALTF__AltifyId__c FROM ALTF__Assessment_Question__c
            WHERE ALTF__AltifyId__c IN :codes
        ]) {
            standing.put(row.ALTF__AltifyId__c, row);
        }

        List<ALTF__Assessment_Question__c> toInsert = new List<ALTF__Assessment_Question__c>();
        List<ALTF__Assessment_Question__c> toUpdate = new List<ALTF__Assessment_Question__c>();
        Integer order = 1;
        for (Map<String, Object> q : qs) {
            String code = (String) q.get('code');
            Decimal byStage = byStageFor(code);
            if (byStage != null) {
                o.markersFound++;
            } else {
                o.notes.add(
                    'NO BY-STAGE MARKER for ' + code + '. It will red on a voiced no and never ' +
                    'on absence, which is lawful but is not what the seed intends.'
                );
            }
            ALTF__Assessment_Question__c row = standing.get(code);
            if (row == null) {
                row = new ALTF__Assessment_Question__c(ALTF__AltifyId__c = code);
                toInsert.add(row);
            } else {
                toUpdate.add(row);
            }
            row.Name = ((String) q.get('short')).left(80);
            row.ALTF__Criterion_Text__c = ((String) q.get('short')).left(255);
            row.ALTF__Long_Question__c = (String) q.get('proposition');
            row.ALTF__Help__c = helpTextFor(q, byStage);
            row.ALTF__Question__c = categoryFor(code);
            row.ALTF__Order_Number__c = order++;
            row.ALTF__Active__c = true;
            // MANDATORY IS THE VENDOR'S OWN GATE AND IS NOT OURS TO SET FROM THE INVERSION LAW.
            // Every one of the fifteen is a deal-killer by Matthew's ruling, but "mandatory"
            // here means the vendor blocks stage movement on it - a different gate with a
            // different job (hundred-twenty-second, item 2). Ours is the BY-STAGE marker.
            row.ALTF__Mandatory__c = false;
            row.ALTF__Yes_Label__c = 'Yes';
            row.ALTF__No_Label__c = 'No';
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
            o.questionsInserted = toInsert.size();
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
            o.questionsUpdated = toUpdate.size();
        }

        // The plan-type chain, on OUR OWN plan type so the ones the org configured are untouched.
        // Its question list is a 255-character comma-delimited string of ALTIFY CODES, not ids -
        // a real ceiling on rubric size in any org, and the reason the codes are short.
        String joined = String.join(codes, ',');
        if (joined.length() > 255) {
            throw new SeedException(
                'The plan type carries its question list in 255 characters and this set needs ' +
                joined.length() + '.'
            );
        }
        o.notes.add('plan-type code string ' + joined.length() + ' of 255 characters');
        List<ALTF__Opportunity_Plan_Type_List__c> pts = [
            SELECT Id FROM ALTF__Opportunity_Plan_Type_List__c WHERE Name = :PLAN_TYPE LIMIT 1
        ];
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
        return o;
    }

    /**
     * Guidance plus the element decomposition, in the shape `AAO_Discovery` reads back:
     * `Elements:` then one `- id: text` line each. Help is the ONLY field on the vendor's
     * question that can carry elements, which makes it the authored path or nothing.
     *
     * The by-stage marker rides the guidance as PROSE FOR A HUMAN, never as the machine's source
     * of truth - the machine reads `AAO_Assessment_Stage__mdt`. A number that appears in two
     * places is a number that will one day disagree with itself, so this one says where it came
     * from rather than pretending to be it.
     */
    private static String helpTextFor(Map<String, Object> q, Decimal byStage) {
        List<String> lines = new List<String>();
        lines.add(
            'A deal-killer test: the affirmative is what the deal needs, and a NO is a red flag. ' +
            'A no VOICED by the customer flags immediately at any stage; never established flags ' +
            'only past its by-stage marker' +
            (byStage == null ? '.' : ' (stage ' + byStage.setScale(0) + ' in this org).')
        );
        lines.add('');
        lines.add('Elements:');
        for (Object eo : (List<Object>) q.get('elements')) {
            Map<String, Object> e = (Map<String, Object>) eo;
            lines.add('- ' + e.get('id') + ': ' + e.get('text'));
        }
        return String.join(lines, '\n').left(1024);
    }

    // =============================================================== the sales process

    /**
     * ONE PROCESS, FIVE STAGES, FOURTEEN GLOBAL QUALIFIERS, FIFTEEN JUNCTION ROWS.
     *
     * **THE ONE INSTRUCTION I COULD NOT CARRY OUT, stated here rather than in a report nobody
     * rereads.** The hundred-twenty-second ruled the eight required forecasting fields *"COPY
     * VERBATIM FROM THE PROD CAPTURE"*, on the reasoning that inventing them would be tuning a
     * surface we do not understand and *"the capture already carries working values."*
     * **It does not.** `aao-projection-surface-spm-om-v0_1.md` carries field DEFINITIONS, help
     * text, the five process names with their version numbers, and exactly one sample row - the
     * stage-qualifier junction. No forecasting value appears anywhere in it, and the same is true
     * of the stage structure the spec says to adapt. Design's production connection is lost
     * (hundred-twentieth, item 5), so they cannot be fetched now either.
     *
     * **So every number below comes from the VENDOR'S OWN help text, captured verbatim on
     * 2 August, quoted at the line that uses it** - which is the closest lawful thing to the
     * ruling's intent, and is quoting rather than inventing. **Where the capture states no
     * guidance at all, the value is marked NO GUIDANCE and is a placeholder awaiting design.**
     * The stage names and every word of qualifier text are ours by the spec's own instruction
     * ("TEXT REWRITTEN, never copied verbatim - prod's qualifier text is Altify's production
     * methodology content and our seed is our own").
     */
    public static Outcome seedSalesProcess(Outcome o) {
        // ---- the process
        String procKey = KEY_PREFIX + '|PROC';
        List<ALTF__Sales_Process__c> found = [
            SELECT Id FROM ALTF__Sales_Process__c WHERE ALTF__AltifyId__c = :procKey LIMIT 1
        ];
        ALTF__Sales_Process__c proc = found.isEmpty()
            ? new ALTF__Sales_Process__c(ALTF__AltifyId__c = procKey)
            : found[0];
        proc.Name = PROCESS_NAME;
        proc.ALTF__Description__c =
            'Seeded by AAO so the sandbox is customer-shaped and rubric discovery has org ' +
            'records to discover. Structure and text are ours; see AAO_ProcessSeed.';
        // "This is the probability of the opportunity closing after all steps have been
        // completed.  This is usually 100%" - vendor help text, captured.
        proc.ALTF__Final_Stage_Probability__c = 100;
        // "Enter the number of days typically taken to close an opportunity after all steps
        // have been completed.  This can be zero." - vendor help text, captured.
        proc.ALTF__Closure_Duration__c = 0;
        // Our sandbox figure, and the only input the two below are derived from.
        proc.ALTF__Average_Deal_Size__c = 100000;
        // "typically set to one quarter of the average deal size" - vendor help text, captured.
        proc.ALTF__Pebble_Value__c = 25000;
        // "typically set to four times the average deal size" - vendor help text, captured.
        proc.ALTF__Rock_Value__c = 400000;
        // NO GUIDANCE IN THE CAPTURE, AND THE ORG REFUSED THE FIRST READING.
        //
        // The first attempt mirrored the vendor's quarter-and-four-times language as percents
        // (25 and 400) and the org threw `FIELD_CUSTOM_VALIDATION_EXCEPTION, Only 0-100% is
        // valid` - so these are genuine percentages, not multipliers, and the value fields'
        // guidance does not carry over to them. The schema teaching us its own law again.
        //
        // With no captured guidance and a hard 0-100 bound, both sit at the process threshold,
        // which is the ONE stance a seed can defend: **deal size introduces no differentiation.**
        // A seed that invented a forecasting policy it could not explain would be tuning a
        // surface we do not understand, which is the exact thing the hundred-twenty-second ruled
        // against when it said to copy rather than invent. Flagged for design.
        proc.ALTF__Pebble_Percentage__c = 75;
        proc.ALTF__Rock_Percentage__c = 75;
        // NO GUIDANCE IN THE CAPTURE beyond what it is FOR: "An opportunity must achieve the
        // threshold percentage (and be within the forecasting close date) in order to be deemed
        // Projected in the Forecast Analysis for Altify."
        proc.ALTF__Threshold__c = 75;
        proc.ALTF__Version__c = 1;
        proc.ALTF__IsActive__c = true;
        proc.ALTF__Disabled__c = false;
        // NEVER THE ORG'S DEFAULT. A seed that made itself the default process would change how
        // every deal in the org behaves, which is not what a seed is for.
        proc.ALTF__Default_Process__c = false;
        proc.ALTF__Multiple_Buyers__c = false;
        upsertRow(proc, found.isEmpty());
        o.processes = 1;
        o.notes.add(
            'FORECASTING MACHINERY: the capture carries no values, only definitions - so these ' +
            'are the vendor\'s own captured defaults, quoted at each line. Pebble/Rock percent ' +
            'and Threshold had NO guidance and are flagged placeholders; the org refused the ' +
            'first Pebble/Rock reading with "Only 0-100% is valid", so they are percentages ' +
            'rather than multipliers and carry no size differentiation.'
        );

        // ---- the five stages, ours by the spec's own instruction to rewrite text
        List<List<String>> stageSpec = new List<List<String>>{
            new List<String>{ '1', 'Qualify',  '20', '14' },
            new List<String>{ '2', 'Discover', '40', '21' },
            new List<String>{ '3', 'Validate', '60', '21' },
            new List<String>{ '4', 'Propose',  '75', '14' },
            new List<String>{ '5', 'Commit',   '90', '7'  }
        };
        Map<String, ALTF__Stage__c> stagesByKey = new Map<String, ALTF__Stage__c>();
        Set<String> stageKeys = seedKeys('STAGE');
        for (ALTF__Stage__c st : [
            SELECT Id, ALTF__AltifyId__c FROM ALTF__Stage__c
            WHERE ALTF__AltifyId__c IN :stageKeys
        ]) {
            stagesByKey.put(st.ALTF__AltifyId__c, st);
        }
        List<ALTF__Stage__c> stageIns = new List<ALTF__Stage__c>();
        List<ALTF__Stage__c> stageUpd = new List<ALTF__Stage__c>();
        for (List<String> sp : stageSpec) {
            String k = KEY_PREFIX + '|STAGE|' + sp[0];
            ALTF__Stage__c st = stagesByKey.get(k);
            Boolean isNew = st == null;
            if (isNew) { st = new ALTF__Stage__c(ALTF__AltifyId__c = k); }
            st.Name = sp[1];
            st.ALTF__SortOrder__c = Decimal.valueOf(sp[0]);
            if (isNew) { stageIns.add(st); } else { stageUpd.add(st); }
            stagesByKey.put(k, st);
        }
        if (!stageIns.isEmpty()) { insert stageIns; }
        if (!stageUpd.isEmpty()) { update stageUpd; }
        o.stages = stageSpec.size();

        // ---- the process stages
        Map<String, ALTF__Sales_Process_Stage__c> psByKey =
            new Map<String, ALTF__Sales_Process_Stage__c>();
        Set<String> psKeys = seedKeys('PS');
        for (ALTF__Sales_Process_Stage__c ps : [
            SELECT Id, ALTF__AltifyId__c FROM ALTF__Sales_Process_Stage__c
            WHERE ALTF__AltifyId__c IN :psKeys
        ]) {
            psByKey.put(ps.ALTF__AltifyId__c, ps);
        }
        List<ALTF__Sales_Process_Stage__c> psIns = new List<ALTF__Sales_Process_Stage__c>();
        List<ALTF__Sales_Process_Stage__c> psUpd = new List<ALTF__Sales_Process_Stage__c>();
        for (List<String> sp : stageSpec) {
            String k = KEY_PREFIX + '|PS|' + sp[0];
            ALTF__Sales_Process_Stage__c ps = psByKey.get(k);
            Boolean isNew = ps == null;
            if (isNew) { ps = new ALTF__Sales_Process_Stage__c(ALTF__AltifyId__c = k); }
            ps.Name = sp[1];
            ps.ALTF__Sales_Process__c = proc.Id;
            ps.ALTF__Stage__c = stagesByKey.get(KEY_PREFIX + '|STAGE|' + sp[0]).Id;
            ps.ALTF__SortOrder__c = Decimal.valueOf(sp[0]);
            ps.ALTF__Duration__c = Decimal.valueOf(sp[3]);
            // "The percentage score that must be achieved on the stage before the opportunity
            // can move to the next stage" - vendor help text, captured. THIS IS THE VENDOR'S
            // STAGE GATE and it is not our by-stage marker: that one gates red-flag timing on
            // assessment questions. Two gates, two jobs (hundred-twenty-second, item 2).
            ps.ALTF__Qualification__c = Decimal.valueOf(sp[2]);
            // NO GUIDANCE IN THE CAPTURE for the RAG thresholds. Amber at half the stage's own
            // qualification bar and Green at the bar itself is the only reading that keeps them
            // ordered and tied to a number the vendor DOES define. Flagged.
            ps.ALTF__Amber__c = Decimal.valueOf(sp[2]) / 2;
            ps.ALTF__Green__c = Decimal.valueOf(sp[2]);
            if (isNew) { psIns.add(ps); } else { psUpd.add(ps); }
            psByKey.put(k, ps);
        }
        if (!psIns.isEmpty()) { insert psIns; }
        if (!psUpd.isEmpty()) { update psUpd; }
        o.processStages = stageSpec.size();

        // ---- the global qualifiers and the junction
        //
        // Every stage carries at least one COMPUTED-plane and one EVIDENCE-plane qualifier, per
        // the spec, so the computed-state catalog exercises both on its first run. The plane is
        // written into the tip as prose for a human; the MACHINE-READABLE mapping from qualifier
        // to computable predicate is §2's configuration and belongs to the Process build, not to
        // the seed - noted so nobody later reads a tip as a predicate.
        //
        // MUTUAL CLOSE PLANNING carries T3's dropped substance and is ONE global qualifier linked
        // to TWO late stages, which is what the junction is for and what "the late stages" means.
        List<List<String>> quals = new List<List<String>>{
            //  stage, code,     mandatory, importance,        plane,      question
            new List<String>{'1','PROBLEM','true','Essential','EVIDENCE','The customer has described a business problem in their own words.'},
            new List<String>{'1','PEOPLE1','false','Important','COMPUTED','At least one external participant is identified on the relationship map.'},
            new List<String>{'1','WHEN1','false','Nice to have','EVIDENCE','The customer has voiced a timeframe for deciding.'},
            new List<String>{'2','MAPPED','true','Very important','COMPUTED','Everyone who has spoken on a call is placed on the relationship map with a buyer role.'},
            new List<String>{'2','FUNDS','false','Very important','EVIDENCE','The customer has named the funds or the person who owns them.'},
            new List<String>{'2','INACTION','false','Important','EVIDENCE','The customer has said what happens if nothing changes.'},
            new List<String>{'3','DMINSIGHT','true','Essential','COMPUTED','The decision maker carries at least one goal or pressure on the insight board.'},
            new List<String>{'3','FIT','true','Essential','EVIDENCE','The customer has confirmed our solution addresses the problem they described.'},
            new List<String>{'3','CRITERIA','false','Important','COMPUTED','Decision criteria are recorded and no required criterion is still open.'},
            new List<String>{'4','CHAIN','true','Very important','COMPUTED','Every approver the customer has named is represented on the relationship map.'},
            new List<String>{'4','EVENT','true','Essential','EVIDENCE','A compelling event with a date has been voiced by the customer.'},
            new List<String>{'4','CLOSEPLAN','true','Essential','EVIDENCE','The steps between now and signature are described and shared with the customer.'},
            new List<String>{'5','SUPPORT','true','Essential','COMPUTED','Every identified key player stands at Supporter or better.'},
            new List<String>{'5','ENDORSED','true','Essential','EVIDENCE','The decision maker has endorsed the timeline in their own words.'},
            new List<String>{'5','CLOSEPLAN','true','Essential','EVIDENCE','The steps between now and signature are described and shared with the customer.'}
        };

        Set<String> qKeys = new Set<String>();
        for (List<String> qq : quals) { qKeys.add(KEY_PREFIX + '|Q|' + qq[1]); }
        Map<String, ALTF__Sales_Process_Qualifier__c> qByKey =
            new Map<String, ALTF__Sales_Process_Qualifier__c>();
        for (ALTF__Sales_Process_Qualifier__c gq : [
            SELECT Id, ALTF__AltifyId__c FROM ALTF__Sales_Process_Qualifier__c
            WHERE ALTF__AltifyId__c IN :qKeys
        ]) {
            qByKey.put(gq.ALTF__AltifyId__c, gq);
        }
        List<ALTF__Sales_Process_Qualifier__c> gqIns = new List<ALTF__Sales_Process_Qualifier__c>();
        List<ALTF__Sales_Process_Qualifier__c> gqUpd = new List<ALTF__Sales_Process_Qualifier__c>();
        Set<String> seen = new Set<String>();
        for (List<String> qq : quals) {
            String k = KEY_PREFIX + '|Q|' + qq[1];
            if (seen.contains(k)) { continue; }
            seen.add(k);
            ALTF__Sales_Process_Qualifier__c gq = qByKey.get(k);
            Boolean isNew = gq == null;
            if (isNew) { gq = new ALTF__Sales_Process_Qualifier__c(ALTF__AltifyId__c = k); }
            gq.Name = (qq[1] == 'CLOSEPLAN' ? 'Mutual close planning' : qq[1]).left(80);
            gq.ALTF__Question__c = qq[5];
            gq.ALTF__Tip__c = qq[4] == 'COMPUTED'
                ? 'COMPUTED PLANE: this is arithmetic over rows AAO already wrote - no model ' +
                  'call, no inference, the same law Coverage obeys. Its machine-readable ' +
                  'predicate is configuration and is not this text.'
                : 'EVIDENCE PLANE: established only by what someone said on a call, cited to ' +
                  'their words and verified blind.';
            gq.ALTF__UI_Readonly__c = qq[4] == 'COMPUTED';
            if (isNew) { gqIns.add(gq); } else { gqUpd.add(gq); }
            qByKey.put(k, gq);
        }
        if (!gqIns.isEmpty()) { insert gqIns; }
        if (!gqUpd.isEmpty()) { update gqUpd; }
        o.qualifiers = seen.size();

        Set<String> jKeys = new Set<String>();
        for (List<String> qq : quals) {
            jKeys.add(KEY_PREFIX + '|SQ|' + qq[0] + '|' + qq[1]);
        }
        Map<String, ALTF__Sales_Process_Stage_Qualifier__c> jByKey =
            new Map<String, ALTF__Sales_Process_Stage_Qualifier__c>();
        for (ALTF__Sales_Process_Stage_Qualifier__c j : [
            SELECT Id, ALTF__AltifyId__c FROM ALTF__Sales_Process_Stage_Qualifier__c
            WHERE ALTF__AltifyId__c IN :jKeys
        ]) {
            jByKey.put(j.ALTF__AltifyId__c, j);
        }
        List<ALTF__Sales_Process_Stage_Qualifier__c> jIns =
            new List<ALTF__Sales_Process_Stage_Qualifier__c>();
        List<ALTF__Sales_Process_Stage_Qualifier__c> jUpd =
            new List<ALTF__Sales_Process_Stage_Qualifier__c>();
        Map<String, Integer> sortIn = new Map<String, Integer>();
        for (List<String> qq : quals) {
            String k = KEY_PREFIX + '|SQ|' + qq[0] + '|' + qq[1];
            Integer next = sortIn.containsKey(qq[0]) ? sortIn.get(qq[0]) + 1 : 1;
            sortIn.put(qq[0], next);
            ALTF__Sales_Process_Stage_Qualifier__c j = jByKey.get(k);
            Boolean isNew = j == null;
            if (isNew) { j = new ALTF__Sales_Process_Stage_Qualifier__c(ALTF__AltifyId__c = k); }
            j.ALTF__Sales_Process_Stage__c = psByKey.get(KEY_PREFIX + '|PS|' + qq[0]).Id;
            j.ALTF__Sales_Process_Qualifier__c = qByKey.get(KEY_PREFIX + '|Q|' + qq[1]).Id;
            j.ALTF__Mandatory__c = qq[2] == 'true';
            j.ALTF__Importance__c = qq[3];
            j.ALTF__Sort_Order__c = next;
            if (isNew) { jIns.add(j); } else { jUpd.add(j); }
        }
        if (!jIns.isEmpty()) { insert jIns; }
        if (!jUpd.isEmpty()) { update jUpd; }
        o.junctions = quals.size();
        return o;
    }

    private static void upsertRow(SObject row, Boolean isNew) {
        if (isNew) { insert row; } else { update row; }
    }
}
