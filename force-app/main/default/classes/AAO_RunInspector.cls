/**
 * THE RUN INSPECTOR. What happened on this deal, and how do I get from a value back to the words.
 *
 * Matthew's primary use, ruled at the fifty-seventh stamp: *"see and reverse-engineer what happened
 * on an opportunity back to source"*. This is the verification sheet's walk, done by the machine
 * instead of by hand: **value to answer to claim to pair to byte-located quote to source.**
 *
 * **v2, the sixty-sixth stamp, from Matthew's read of the rendered v1.** What it READS is unchanged;
 * what it READS OUT is rebuilt to his four rulings: row titles carry words rather than contract
 * codes; rows group under the person they are about; the detail opens under its own row; refusals
 * collapse behind a count that stays visible; and the pipeline's order is DRAWN rather than implied,
 * twice over, as a run-level stepper and as the numbered path a single establishment actually took.
 *
 * **THE REFUSALS RIDE BESIDE THE UPHELD VALUES, and that is the point rather than a nicety.** A
 * surface that shows only what stood tells you what the machine believes; the refusals are where
 * trust is earned, because they are where you can see it declining to assert something it could
 * have asserted. Collapsing them by default is a default, never a hiding: the count is on the
 * stepper before anybody asks, and the Verified stage keeps its meaning line under test.
 *
 * READ-ONLY, STRUCTURALLY. There is no DML anywhere in this class and no method that could be
 * mistaken for one, and a test greps this body for every write verb to keep it that way. An
 * inspector that could change what it inspects is not an inspector.
 */
public with sharing class AAO_RunInspector {
    // ------------------------------------------------------------------------ the shapes

    public class RunOption {
        @AuraEnabled public String runKey;
        @AuraEnabled public String label;
        @AuraEnabled public Datetime latestActivity;
        @AuraEnabled public Integer pairCount;
    }

    /**
     * One step of the pipeline, at run grain, in the order the pipeline actually runs it.
     *
     * `countLabel` is composed here rather than in the template because a stage can carry two
     * numbers ("24 upheld / 21 refused") and a template that stitched them would be inventing
     * presentation the surface's own vocabulary should own.
     */
    public class Step {
        @AuraEnabled public String label;
        @AuraEnabled public String countLabel;
        @AuraEnabled public String meaning;
        public Step(String label, String countLabel, String meaning) {
            this.label = label;
            this.countLabel = countLabel;
            this.meaning = meaning;
        }
    }

    /** Kept for the v1 callers and for the stage-vocabulary law's own test. */
    public class StageCount {
        @AuraEnabled public String stage;
        @AuraEnabled public Integer count;
        @AuraEnabled public String meaning;
        public StageCount(String stage, Integer count, String meaning) {
            this.stage = stage;
            this.count = count;
            this.meaning = meaning;
        }
    }

    /**
     * One hop of the walk, in WORDS rather than object names.
     *
     * A step that did not happen is not omitted: it renders greyed and carries its reason, so a
     * refusal's path is exactly as legible as an uphold's. Omitting the dead steps would make
     * every trace look like a success that simply ended early.
     */
    public class PathStep {
        @AuraEnabled public Integer n;
        @AuraEnabled public String label;
        @AuraEnabled public String detail;
        @AuraEnabled public Boolean happened;
        @AuraEnabled public String reason;
    }

    /** One thing the run put in front of a human, with everything behind it. */
    public class Trace {
        @AuraEnabled public String id;
        /** FAMILY PLUS ESTABLISHED VALUE, Matthew's ruling. Never a contract code. */
        @AuraEnabled public String title;
        /** The contract's own plain-language name, for the hover and the opened detail. */
        @AuraEnabled public String shortName;
        @AuraEnabled public String person;
        @AuraEnabled public Boolean personInternal;
        @AuraEnabled public String internalReason;
        @AuraEnabled public String dimension;
        @AuraEnabled public String value;
        @AuraEnabled public String verdict;
        @AuraEnabled public String contractCode;
        @AuraEnabled public String question;
        @AuraEnabled public String quote;
        @AuraEnabled public Integer startOffset;
        @AuraEnabled public Integer endOffset;
        @AuraEnabled public String range;
        @AuraEnabled public String sourceRef;
        @AuraEnabled public Datetime occurred;
        @AuraEnabled public String refusalNote;
        @AuraEnabled public Boolean upheld;
        /** True where the title had to fall back to the code. A defect to report, never silent. */
        @AuraEnabled public Boolean titleFellBackToCode;
        @AuraEnabled public List<PathStep> path = new List<PathStep>();
    }

    /**
     * Establishments group under the person they are ABOUT, because that is how the relationship
     * map reads and because "what do we know about this person, and how do we know it" is the
     * question a reviewer actually arrives with.
     */
    public class PersonGroup {
        @AuraEnabled public String name;
        @AuraEnabled public Boolean internal;
        @AuraEnabled public String internalReason;
        @AuraEnabled public Integer upheldCount;
        @AuraEnabled public Integer refusedCount;
        @AuraEnabled public String countLabel;
        @AuraEnabled public String refusedLabel;
        @AuraEnabled public List<Trace> upheld = new List<Trace>();
        @AuraEnabled public List<Trace> refused = new List<Trace>();
    }

    /**
     * One stage's performance, as the run journalled it. Never recomputed on the page.
     *
     * Every string here is composed in Apex rather than in the template for the reason the
     * counts are: a page that stitched "23 of 100" out of two numbers would be presenting
     * telemetry, and presenting telemetry is how a number acquires a meaning nobody measured.
     */
    public class PerfLine {
        @AuraEnabled public String stage;
        @AuraEnabled public String wall;
        @AuraEnabled public String callouts;
        @AuraEnabled public String soql;
        @AuraEnabled public String dml;
        @AuraEnabled public String cpu;
        @AuraEnabled public String heap;
        @AuraEnabled public String cache;
        @AuraEnabled public String produced;
        /** True where any governor crossed 80 percent of its ceiling. Flagged, per the law. */
        @AuraEnabled public Boolean nearACeiling = false;
    }

    public class RunView {
        @AuraEnabled public String runKey;
        @AuraEnabled public List<Step> pipeline = new List<Step>();
        @AuraEnabled public List<StageCount> stages = new List<StageCount>();
        @AuraEnabled public List<PersonGroup> people = new List<PersonGroup>();
        @AuraEnabled public List<Trace> upheld = new List<Trace>();
        @AuraEnabled public List<Trace> refused = new List<Trace>();
        @AuraEnabled public Integer refusedTotal = 0;
        @AuraEnabled public String note;
        /** False where the run journalled no per-stage performance anywhere this page can read. */
        @AuraEnabled public Boolean performanceJournalled = false;
        @AuraEnabled public String performanceNote;
        @AuraEnabled public String performanceSummary;
        @AuraEnabled public List<PerfLine> performance = new List<PerfLine>();
        @AuraEnabled public List<String> defects = new List<String>();
    }

    // ------------------------------------------------------------------------ the reads

    /**
     * The runs that touched this deal, newest first. The picker's contents.
     *
     * Grouped in Apex rather than SOQL because the run key is a text field and the vendor-quirk
     * lesson from the board work applies generally: an aggregate that throws at runtime rather
     * than compile time is a worse trade than a loop over a bounded set.
     */
    @AuraEnabled(cacheable=true)
    public static List<RunOption> runsFor(Id opportunityId) {
        Map<String, RunOption> byKey = new Map<String, RunOption>();
        for (AAO_Pair__c p : [
            SELECT AAO_Run_Key__c, CreatedDate
            FROM AAO_Pair__c
            WHERE AAO_Source__r.AAO_Opportunity__c = :opportunityId
                AND AAO_Run_Key__c != null
            ORDER BY CreatedDate DESC
            LIMIT 5000
        ]) {
            RunOption o = byKey.get(p.AAO_Run_Key__c);
            if (o == null) {
                o = new RunOption();
                o.runKey = p.AAO_Run_Key__c;
                o.label = p.AAO_Run_Key__c;
                o.latestActivity = p.CreatedDate;
                o.pairCount = 0;
                byKey.put(o.runKey, o);
            }
            o.pairCount++;
        }
        List<RunOption> out = byKey.values();
        // Newest first: the default pick is the latest run, which is what a tester wants.
        for (Integer i = 0; i < out.size(); i++) {
            for (Integer j = i + 1; j < out.size(); j++) {
                if (out[j].latestActivity > out[i].latestActivity) {
                    RunOption t = out[i];
                    out[i] = out[j];
                    out[j] = t;
                }
            }
        }
        return out;
    }

    /**
     * One run: the pipeline drawn in order, the people it spoke about, and every trace behind them.
     *
     * The stage vocabulary is the pipeline's own rather than invented labels, because a tester
     * comparing this against a run report must see the same words in both places.
     */
    @AuraEnabled(cacheable=true)
    public static RunView inspect(Id opportunityId, String runKey) {
        RunView v = new RunView();
        v.runKey = runKey;
        readPerformance(v, opportunityId, runKey);
        if (String.isBlank(runKey)) {
            v.note = 'No run selected.';
            drawPipeline(v, 0, 0, 0, 0, 0, 0, 0, 0);
            return v;
        }

        Integer located = [
            SELECT COUNT() FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.LOCATED
        ];
        List<AAO_Pair__c> identified = [
            SELECT Id, AAO_Pair_Ref__c, AAO_Disposition__c, AAO_Verification__c,
                AAO_Verification_Note__c, AAO_Identification_Basis__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Text__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Short__c,
                AAO_Person__r.AAO_Display_Name__c, AAO_Person__r.AAO_Internal__c,
                AAO_Source__c, AAO_Source__r.AAO_Source_Ref__c,
                AAO_Source__r.AAO_Evidence_Occurred__c,
                AAO_Claim__c, AAO_Claim__r.AAO_Outcome__c, AAO_Claim__r.AAO_Interpretation__c,
                AAO_Claim__r.AAO_Retired__c, AAO_Claim__r.AAO_Answer__c,
                AAO_Claim__r.AAO_Answer__r.AAO_Verdict__c,
                AAO_Claim__r.AAO_Answer__r.AAO_Projected_Value__c,
                AAO_Claim__r.AAO_Answer__r.AAO_Projected_Modstamp__c,
                AAO_Located_Pair__r.AAO_Answer_Text__c,
                AAO_Located_Pair__r.AAO_Start_Offset__c,
                AAO_Located_Pair__r.AAO_End_Offset__c,
                AAO_Located_Pair__r.AAO_Meaning__c,
                AAO_Located_Pair__r.AAO_Criterion_Name__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.IDENTIFIED
            ORDER BY AAO_Located_Pair__r.AAO_Start_Offset__c NULLS LAST, AAO_Pair_Ref__c
        ];

        // The card the writer drew from a given establishment, keyed the way the writer keys it:
        // type plus the verbatim it was drawn from. That is layer 1 of the card writer's own
        // dedup, so this page reads the same identity the writer wrote and guesses at nothing.
        Map<String, String> cardByEvidence = cardFacesByEvidence(opportunityId);

        Map<String, PersonGroup> groups = new Map<String, PersonGroup>();
        Set<Id> claims = new Set<Id>();
        Set<Id> answers = new Set<Id>();
        Set<Id> sources = new Set<Id>();
        Integer upheldCount = 0;
        Integer refusedCount = 0;
        Integer merged = 0;

        for (AAO_Pair__c p : identified) {
            if (p.AAO_Source__c != null) {
                sources.add(p.AAO_Source__c);
            }
            if (p.AAO_Claim__c != null) {
                claims.add(p.AAO_Claim__c);
                if (p.AAO_Claim__r.AAO_Answer__c != null) {
                    answers.add(p.AAO_Claim__r.AAO_Answer__c);
                }
            }
            // A merged receipt carries no verdict of its own: the establishment rides its
            // canonical pair and this row exists so the second read's bytes are not lost. It is
            // counted and named, never shown as an establishment nobody judged.
            if (String.isBlank(p.AAO_Verification__c)) {
                merged++;
                continue;
            }

            Trace t = traceOf(p, cardByEvidence);
            // A gap in the words is REPORTED, never smoothed over: a fallback that looks like a
            // name is how a missing name survives a review.
            if (t.titleFellBackToCode) {
                v.defects.add(
                    'Contract ' + t.contractCode + ' places no value this page can name, so its ' +
                    'rows show the code. Fix it on the contract, never here.'
                );
            }
            if (String.isBlank(t.shortName)) {
                v.defects.add(
                    'Contract ' + t.contractCode + ' carries no plain-language short name, so ' +
                    'its opened detail has no proposition name to show.'
                );
            }
            String who = String.isBlank(t.person) ? 'Not attributed to a person' : t.person;
            PersonGroup g = groups.get(who);
            if (g == null) {
                g = new PersonGroup();
                g.name = who;
                g.internal = t.personInternal == true;
                g.internalReason = t.internalReason;
                g.upheldCount = 0;
                g.refusedCount = 0;
                groups.put(who, g);
            }
            if (t.upheld == true) {
                upheldCount++;
                g.upheldCount++;
                g.upheld.add(t);
                v.upheld.add(t);
            } else {
                refusedCount++;
                g.refusedCount++;
                g.refused.add(t);
                v.refused.add(t);
            }
        }

        for (PersonGroup g : groups.values()) {
            g.countLabel = g.upheldCount + ' established, ' + g.refusedCount + ' refused';
            g.refusedLabel = g.refusedCount + ' refused';
        }
        v.people = sortedGroups(groups.values());
        v.refusedTotal = refusedCount;

        Integer mapRows = [
            SELECT COUNT() FROM ALTF__Contact_Map_Details__c
            WHERE ALTF__Opportunity__c = :opportunityId
        ];
        Integer cards = [
            SELECT COUNT() FROM ALTF__Insight_Card__c
            WHERE ALTF__Opportunity__c = :opportunityId
        ];

        drawPipeline(
            v, sources.size(), located, identified.size(), upheldCount, refusedCount,
            claims.size(), answers.size(), mapRows
        );
        v.stages.add(new StageCount('Located', located, STAGE_LOCATED));
        v.stages.add(new StageCount('Identified', identified.size(), STAGE_IDENTIFIED));
        v.stages.add(new StageCount('Upheld', upheldCount, STAGE_UPHELD));
        v.stages.add(new StageCount('Refused', refusedCount, STAGE_REFUSED));
        v.stages.add(new StageCount('Map rows', mapRows, STAGE_MAP));
        v.stages.add(new StageCount('Cards', cards, STAGE_CARDS));
        // The last step's second number is the card count, which the stepper needs and the
        // stage list already carries. Composed here so the template stitches nothing.
        v.pipeline[v.pipeline.size() - 1].countLabel = mapRows + ' map rows, ' + cards + ' cards';

        List<String> notes = new List<String>();
        if (identified.isEmpty()) {
            notes.add(
                'This run located ' + located + ' pairs and identified none. A run with ' +
                'locations and no identifications stopped at resolution.'
            );
        }
        if (merged > 0) {
            notes.add(
                merged + ' identified rows are merge receipts: the second read found the same ' +
                'words, so the establishment rides its canonical pair and these keep the bytes.'
            );
        }
        if (!notes.isEmpty()) {
            v.note = String.join(notes, ' ');
        }
        return v;
    }

    // ------------------------------------------------------------------------ performance

    /**
     * The performance panel, read off the run's receipt and NEVER computed here.
     *
     * The sixty-sixth stamp's constraint is the whole design of this method: *"showing only
     * numbers the run actually journalled, nothing recomputed or estimated on the page"*. So a
     * run with no receipt gets a sentence saying so rather than a plausible number derived from
     * record timestamps, and a run with a receipt gets exactly its own legs back.
     *
     * A pass that predates the receipt object keeps that honest answer forever, which is correct:
     * those runs genuinely journalled nothing, and back-filling them would be inventing history.
     */
    private static void readPerformance(RunView v, Id opportunityId, String runKey) {
        AAO_Run_Receipt__c receipt = AAO_Receipt.forRun(opportunityId, runKey);
        if (receipt == null) {
            v.performanceJournalled = false;
            v.performanceNote = PERFORMANCE_NOT_JOURNALLED;
            return;
        }
        List<AAO_Receipt.Leg> legs = AAO_Receipt.legsOf(receipt);
        if (legs.isEmpty()) {
            v.performanceJournalled = false;
            v.performanceNote = 'This run has a receipt carrying no stage legs.';
            return;
        }
        v.performanceJournalled = true;
        v.performanceNote = null;
        v.performanceSummary =
            receipt.AAO_Stage_Count__c + ' stages · ' +
            ms(receipt.AAO_Total_Wall_Ms__c) + ' serial · ' +
            receipt.AAO_Callouts__c + ' model calls · worst callout ' +
            ms(receipt.AAO_Worst_Callout_Ms__c) + ' of the 120 s ceiling · ' +
            (String.isBlank(receipt.AAO_Cache_State__c) ? 'cache unknown' : receipt.AAO_Cache_State__c);
        for (AAO_Receipt.Leg leg : legs) {
            PerfLine p = new PerfLine();
            p.stage = leg.stage;
            p.wall = ms(leg.wallMs);
            p.callouts = leg.callouts == null || leg.callouts == 0
                ? 'none'
                : leg.callouts + (leg.worstCalloutMs == null || leg.worstCalloutMs == 0
                    ? ''
                    : ', worst ' + ms(leg.worstCalloutMs));
            p.soql = of(leg.soql, leg.soqlLimit);
            p.dml = of(leg.dml, leg.dmlLimit);
            p.cpu = of(leg.cpuMs, leg.cpuLimit) + ' ms';
            p.heap = of(leg.heap, leg.heapLimit) + ' bytes';
            p.cache = leg.cache;
            p.produced = leg.produced == null ? '' : String.valueOf(leg.produced);
            // A CEILING WE DO NOT PRINT IS A CEILING WE DISCOVER AT TWENTY-FIVE. The join has
            // reached 100 of 100 on SOQL once already, so crossing 80 percent is marked here
            // rather than left for a reader to divide in their head.
            p.nearACeiling = near(leg.soql, leg.soqlLimit) || near(leg.dml, leg.dmlLimit) ||
                near(leg.cpuMs, leg.cpuLimit) || near(leg.heap, leg.heapLimit);
            v.performance.add(p);
        }
    }

    private static String ms(Object raw) {
        if (raw == null) {
            return '—';
        }
        Long n = raw instanceof Decimal ? ((Decimal) raw).longValue() : (Long) raw;
        return n >= 1000 ? (n / 1000) + '.' + Math.mod(n, 1000).format().leftPad(3, '0') + ' s'
            : n + ' ms';
    }

    private static String of(Integer used, Integer cap) {
        if (used == null) {
            return '—';
        }
        return used + (cap == null ? '' : ' of ' + cap);
    }

    private static Boolean near(Integer used, Integer cap) {
        return used != null && cap != null && cap > 0 && (used * 100 / cap) >= 80;
    }

    // ------------------------------------------------------------------------ the drawing

    /**
     * THE ORDER IS DRAWN, not implied. Seven steps in the pipeline's real order, each in plain
     * language, each carrying the number the run actually produced.
     *
     * A reader who has never seen the architecture should be able to say what happened and in what
     * sequence from this line alone, which is the whole of Matthew's ruling.
     */
    private static void drawPipeline(
        RunView v, Integer sources, Integer located, Integer identified, Integer upheld,
        Integer refused, Integer claims, Integer answers, Integer mapRows
    ) {
        v.pipeline.add(new Step('Source read',
            sources + (sources == 1 ? ' call' : ' calls'),
            'The frozen transcript the whole run is measured against.'));
        v.pipeline.add(new Step('Words located', String.valueOf(located),
            'Words the reads found and byte-located against that transcript.'));
        v.pipeline.add(new Step('People identified', String.valueOf(identified),
            'Located pairs the resolution stage kept, merged and attached to a speaker.'));
        // THE STAGE KEEPS ITS MEANING LINE (sixty-third stamp, defaulted but not weakened at the
        // sixty-sixth), and it has to be true of the step it sits under: this step covers both
        // sides of the verdict, so it names both and then says why the refusals are shown.
        v.pipeline.add(new Step('Verified', upheld + ' upheld / ' + refused + ' refused',
            'What the blind verifier let stand, beside what it declined. ' +
            'The refusals are where trust is earned.'));
        v.pipeline.add(new Step('Claims written', String.valueOf(claims),
            'Upheld establishments the join recorded as claims, each with its receipt.'));
        v.pipeline.add(new Step('Answers ledgered', String.valueOf(answers),
            'Our own ledger of what stands, which every surface downstream reads.'));
        v.pipeline.add(new Step('Projected', String.valueOf(mapRows),
            'What reached the relationship map and the insight board.'));
    }

    /**
     * THE WALK-BACK, one row: value to answer to claim to pair to quote to source.
     *
     * The offsets travel with the quote because they are what makes the claim checkable: a reader
     * can go to those bytes in the transcript and read the words for themselves, which is the
     * whole difference between a citation and an assertion.
     */
    private static Trace traceOf(AAO_Pair__c p, Map<String, String> cardByEvidence) {
        Trace t = new Trace();
        t.id = p.Id;
        t.person = p.AAO_Person__r == null ? null : p.AAO_Person__r.AAO_Display_Name__c;
        t.personInternal = p.AAO_Person__r != null && p.AAO_Person__r.AAO_Internal__c == true;
        if (t.personInternal == true) {
            t.internalReason = INTERNAL_REASON;
        }
        t.contractCode = p.AAO_Evidence_Contract__r == null
            ? null
            : p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
        t.question = p.AAO_Evidence_Contract__r == null
            ? null
            : p.AAO_Evidence_Contract__r.AAO_Proposition_Text__c;
        t.shortName = p.AAO_Evidence_Contract__r == null
            ? null
            : p.AAO_Evidence_Contract__r.AAO_Proposition_Short__c;
        t.dimension = AAO_P8Codes.dimensionOf(t.contractCode);
        t.verdict = p.AAO_Verification__c;
        t.upheld = p.AAO_Verification__c == 'Upheld';
        t.refusalNote = p.AAO_Verification_Note__c;
        if (p.AAO_Located_Pair__r != null) {
            t.quote = p.AAO_Located_Pair__r.AAO_Answer_Text__c;
            t.value = p.AAO_Located_Pair__r.AAO_Meaning__c;
            t.startOffset = p.AAO_Located_Pair__r.AAO_Start_Offset__c == null
                ? null
                : Integer.valueOf(p.AAO_Located_Pair__r.AAO_Start_Offset__c);
            t.endOffset = p.AAO_Located_Pair__r.AAO_End_Offset__c == null
                ? null
                : Integer.valueOf(p.AAO_Located_Pair__r.AAO_End_Offset__c);
            if (t.startOffset != null) {
                t.range = 'bytes ' + t.startOffset + '-' + t.endOffset;
            }
        }
        if (p.AAO_Source__r != null) {
            t.sourceRef = p.AAO_Source__r.AAO_Source_Ref__c;
            t.occurred = p.AAO_Source__r.AAO_Evidence_Occurred__c;
        }

        // THE TITLE: family plus the value, in the words the map reads in.
        String established = establishedValue(p);
        t.title = titleFor(t.person, t.contractCode, established);
        t.titleFellBackToCode = established == null;
        walk(t, p, cardByEvidence);
        return t;
    }

    /**
     * The value this establishment carries, from the machine's own record of it rather than from
     * a fresh reading of the code.
     *
     * The ladder, and every rung is a row somewhere rather than a guess:
     *
     * 1. **A CRITERION'S IDENTITY IS ITS NAME** (eighteenth stamp), so a criteria row titles with
     *    the name the establishing words carried. Titling it "Criterion: Criterion" — which is
     *    what the claim's own interpretation word yields — says nothing at all, and this surface
     *    exists to stop exactly that.
     * 2. An UPHELD row takes the claim's `AAO_Interpretation__c`, which is what the join actually
     *    recorded when it wrote the establishment.
     * 3. A REFUSED row has no claim, so it takes the located pair's VOICED MEANING: the value the
     *    read proposed and the verifier then declined. That is what "the title still says what
     *    was at stake" needs, and it is a stored value rather than an inference from the code.
     * 4. Only if all three are absent does it fall to the contract's placement tables.
     */
    private static String establishedValue(AAO_Pair__c p) {
        String code = p.AAO_Evidence_Contract__r == null
            ? null
            : p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
        Boolean isCriteria = AAO_P8Codes.DIM_CRITERIA == AAO_P8Codes.dimensionOf(code);
        String named = p.AAO_Located_Pair__r == null
            ? null
            : p.AAO_Located_Pair__r.AAO_Criterion_Name__c;
        if (isCriteria && String.isNotBlank(named)) {
            return named;
        }
        String claimed = p.AAO_Claim__c == null ? null : p.AAO_Claim__r.AAO_Interpretation__c;
        if (String.isNotBlank(claimed) && !isCriteria) {
            return titleCase(claimed);
        }
        String voiced = p.AAO_Located_Pair__r == null
            ? null
            : p.AAO_Located_Pair__r.AAO_Meaning__c;
        if (String.isNotBlank(voiced) && !(isCriteria && voiced == 'CRITERION')) {
            return titleCase(voiced);
        }
        String proposed = AAO_P8Codes.buyerRole(code);
        if (proposed == null) {
            proposed = AAO_P8Codes.politicalPlacement(code);
        }
        if (proposed == null) {
            proposed = AAO_P8Codes.problemType(code);
        }
        return proposed;
    }

    /** The map's own words for a dimension, so the Inspector and the map read alike. */
    private static final Map<String, String> DIMENSION_LABEL = new Map<String, String>{
        'support' => 'Support',
        'political' => 'Political Status',
        'buyer role' => 'Buyer Role',
        'criteria' => 'Criterion',
        'problems' => null,
        'coverage' => 'Coverage'
    };

    @TestVisible
    private static String titleFor(String person, String code, String established) {
        String who = String.isBlank(person) ? 'Not attributed' : person;
        if (established == null) {
            // No placement table knows this code, so the code shows. Reported as a defect above
            // rather than dressed up as a name nobody authored.
            return who + ' · ' + (String.isBlank(code) ? 'unknown contract' : code);
        }
        String dim = AAO_P8Codes.dimensionOf(code);
        String label = dim == null ? null : DIMENSION_LABEL.get(dim);
        // Problems name their own type ("Initiative"), so a "Problems: " prefix would only
        // repeat the word the value already carries.
        return who + ' · ' + (String.isBlank(label) ? established : label + ': ' + established);
    }

    // ------------------------------------------------------------------------ the numbered path

    /**
     * THE PATH THIS VALUE TOOK, one hop per line, in words rather than object names.
     *
     * Every establishment walks the same eight steps whether it survived or not, and a step that
     * did not happen carries its reason instead of vanishing. That symmetry is the whole reason a
     * refusal is as readable here as an uphold: you can see exactly where it stopped and why,
     * which is what "the refusals are where trust is earned" means when it is drawn.
     */
    private static void walk(Trace t, AAO_Pair__c p, Map<String, String> cardByEvidence) {
        t.path.add(step(1, 'Read the call', true,
            (t.sourceRef == null ? 'the frozen transcript' : t.sourceRef) +
            (t.occurred == null ? '' : ', ' + t.occurred.format('d MMMM yyyy')), null));

        t.path.add(step(2, 'Found the words', t.range != null,
            t.range == null ? null : t.range + ' of the frozen transcript, quoted verbatim',
            t.range == null ? 'The pair carries no byte range.' : null));

        Boolean attributed = String.isNotBlank(t.person);
        t.path.add(step(3, 'Identified the speaker', attributed,
            attributed
                ? t.person + (String.isBlank(p.AAO_Identification_Basis__c)
                    ? ''
                    : ' — ' + p.AAO_Identification_Basis__c)
                : null,
            attributed ? null : 'The resolution stage attached no person to these words.'));

        t.path.add(step(4, 'Asked the question', String.isNotBlank(t.question),
            t.question, 'The contract carries no proposition text.'));

        Boolean judged = String.isNotBlank(t.verdict);
        t.path.add(step(5, 'Verified blind', judged,
            judged
                ? t.verdict + (String.isBlank(t.refusalNote) ? '' : ' — ' + t.refusalNote)
                : null,
            judged ? null : 'This pair never reached the verifier.'));

        Boolean claimed = p.AAO_Claim__c != null;
        String claimDetail = null;
        if (claimed) {
            claimDetail = p.AAO_Claim__r.AAO_Outcome__c +
                (String.isBlank(p.AAO_Claim__r.AAO_Interpretation__c)
                    ? ''
                    : ' as ' + titleCase(p.AAO_Claim__r.AAO_Interpretation__c)) +
                (p.AAO_Claim__r.AAO_Retired__c == true ? ', since retired' : '');
        }
        t.path.add(step(6, 'Wrote the claim', claimed, claimDetail, claimed ? null : noClaim(t)));

        Boolean ledgered = claimed && p.AAO_Claim__r.AAO_Answer__c != null;
        t.path.add(step(7, 'Ledgered the answer', ledgered,
            ledgered ? 'Answer stands ' + p.AAO_Claim__r.AAO_Answer__r.AAO_Verdict__c : null,
            ledgered ? null : 'No answer: an establishment with no claim reaches no ledger.'));

        t.path.add(projectionStep(t, p, cardByEvidence, ledgered));
    }

    /**
     * Why no claim exists, stated from the rows rather than from a guess at the join's reasoning.
     *
     * The internal case is the one this can name with certainty, because the join's rule is
     * written and the participant's own flag proves it applies. Everything else says what is
     * true (no claim is linked) without asserting a cause nobody measured.
     */
    private static String noClaim(Trace t) {
        if (t.upheld != true) {
            return 'No claim: the verifier refused this establishment, and a refusal writes none.';
        }
        if (t.personInternal == true) {
            return 'No claim: ' + INTERNAL_REASON;
        }
        return 'No claim is linked to this pair.';
    }

    private static PathStep projectionStep(
        Trace t, AAO_Pair__c p, Map<String, String> cardByEvidence, Boolean ledgered
    ) {
        if (t.personInternal == true) {
            // THE WORDING IS EXACT BECAUSE THIS PATH ITSELF PROVED THE LOOSE VERSION WRONG. The
            // first draft said the JOIN refuses an internal speaker, and then rendered a Jennae
            // establishment whose claim and answer the join had plainly written: on the Problems
            // family the refusal happens at the card writer, downstream of both. The surface
            // caught its own overstatement, which is the whole argument for building it.
            return step(8, 'Projected', false, null, 'Nothing projected: ' + INTERNAL_REASON);
        }
        String card = cardByEvidence.get(
            cardKey(AAO_P8Codes.problemType(t.contractCode), t.quote)
        );
        if (card != null) {
            return step(8, 'Projected', true, 'An insight card on the board: "' + card + '"', null);
        }
        if (ledgered && String.isNotBlank(p.AAO_Claim__r.AAO_Answer__r.AAO_Projected_Value__c)) {
            String writtenOn = p.AAO_Claim__r.AAO_Answer__r.AAO_Projected_Modstamp__c == null
                ? ''
                : ', written ' +
                    p.AAO_Claim__r.AAO_Answer__r.AAO_Projected_Modstamp__c.format('d MMMM yyyy');
            String label = DIMENSION_LABEL.get(t.dimension);
            return step(8, 'Projected', true,
                (label == null ? 'On the map' : label) + ': ' +
                p.AAO_Claim__r.AAO_Answer__r.AAO_Projected_Value__c + writtenOn, null);
        }
        if (t.upheld != true) {
            return step(8, 'Projected', false, null,
                'Nothing projected: a refused establishment never reaches a surface.');
        }
        return step(8, 'Projected', false, null,
            'Nothing on the map or the board carries this establishment yet.');
    }

    private static PathStep step(
        Integer n, String label, Boolean happened, String detail, String reason
    ) {
        PathStep s = new PathStep();
        s.n = n;
        s.label = label;
        s.happened = happened == true;
        s.detail = detail;
        s.reason = happened == true ? null : reason;
        return s;
    }

    // ------------------------------------------------------------------------ small readers

    /**
     * The board's cards, keyed by the EVIDENCE they were drawn from.
     *
     * This mirrors `AAO_Cards`' own layer-1 identity key (type plus normalised verbatim) so the
     * Inspector reads the same identity the writer wrote. Reading the writer's key rather than
     * inventing a match is the difference between showing where an establishment landed and
     * guessing at it.
     */
    private static Map<String, String> cardByEvidenceOf(List<ALTF__Insight_Card__c> cards) {
        Map<String, String> out = new Map<String, String>();
        for (ALTF__Insight_Card__c c : cards) {
            String verbatim = verbatimOf(c.ALTF__Long_Description__c);
            if (String.isBlank(verbatim)) {
                continue;
            }
            out.put(cardKey(c.ALTF__Type__c, verbatim), c.ALTF__Short_Description__c);
        }
        return out;
    }

    private static Map<String, String> cardFacesByEvidence(Id opportunityId) {
        return cardByEvidenceOf([
            SELECT ALTF__Type__c, ALTF__Short_Description__c, ALTF__Long_Description__c
            FROM ALTF__Insight_Card__c
            WHERE ALTF__Opportunity__c = :opportunityId
            LIMIT 500
        ]);
    }

    @TestVisible
    private static String cardKey(String type, String verbatim) {
        if (String.isBlank(type) || String.isBlank(verbatim)) {
            return 'no-card-key';
        }
        String v = verbatim.toLowerCase()
            .replaceAll('[^a-z0-9 ]', '')
            .replaceAll('\\s+', ' ')
            .trim();
        return type + '#' + v;
    }

    /** The verbatim back out of a card's details, reading the marker the writer itself wrote. */
    @TestVisible
    private static String verbatimOf(String details) {
        if (String.isBlank(details)) {
            return null;
        }
        String marker = 'In their words: "';
        Integer at = details.indexOf(marker);
        if (at < 0) {
            return null;
        }
        String tail = details.substring(at + marker.length());
        Integer close = tail.lastIndexOf('"');
        return close <= 0 ? tail : tail.substring(0, close);
    }

    /** GOAL becomes Goal, DECISION_MAKER becomes Decision Maker. The ledger shouts; a page does not. */
    @TestVisible
    private static String titleCase(String raw) {
        if (String.isBlank(raw)) {
            return raw;
        }
        List<String> words = new List<String>();
        for (String w : raw.trim().toLowerCase().replace('_', ' ').split('\\s+')) {
            words.add(w.length() <= 1 ? w.toUpperCase() : w.substring(0, 1).toUpperCase() + w.substring(1));
        }
        return String.join(words, ' ');
    }

    /** Externals first and alphabetical, then internals, who establish nothing on a buyer's map. */
    private static List<PersonGroup> sortedGroups(List<PersonGroup> gs) {
        List<PersonGroup> out = new List<PersonGroup>(gs);
        for (Integer i = 0; i < out.size(); i++) {
            for (Integer j = i + 1; j < out.size(); j++) {
                Boolean swap = (out[j].internal == false && out[i].internal == true) ||
                    (out[j].internal == out[i].internal &&
                        out[j].name.compareTo(out[i].name) < 0);
                if (swap) {
                    PersonGroup t = out[i];
                    out[i] = out[j];
                    out[j] = t;
                }
            }
        }
        return out;
    }

    // ------------------------------------------------------------------------ the wordings

    /**
     * THE FIFTY-FIFTH... sixty-fifth stamp's owed item: an internal speaker is MARKED, never
     * hidden. Jennae's establishments are real and the pipeline genuinely upheld them; what an
     * unmarked row misleads about is why nothing followed. Showing the reason beside the row is
     * the same principle as showing the refusals beside the upholds.
     */
    @TestVisible
    private static final String INTERNAL_REASON =
        'a seller\'s words never establish a buyer\'s condition, so no card or map row follows ' +
        'from them, whatever the pipeline recorded on the way.';

    private static final String STAGE_LOCATED =
        'Words the reads found and byte-located against the frozen transcript.';
    private static final String STAGE_IDENTIFIED =
        'Located pairs the resolution stage kept, merged and attached to a speaker.';
    private static final String STAGE_UPHELD = 'Establishments the blind verifier let stand.';
    private static final String STAGE_REFUSED =
        'Establishments the verifier declined. This is where trust is earned.';
    private static final String STAGE_MAP =
        'People placed on the relationship map for this deal, all runs.';
    private static final String STAGE_CARDS = 'Insight cards standing on this deal, all runs.';

    /**
     * THE HONEST ANSWER FOR A RUN THAT JOURNALLED NOTHING, and it stays honest forever.
     *
     * The receipt object exists as of the sixty-seventh stamp, so runs from here carry their own
     * numbers. Runs from BEFORE it do not, and this is what they say. Back-filling them would be
     * inventing history, and deriving a timing from record timestamps would be exactly the
     * recomputation the sixty-sixth stamp forbade. A surface that cannot say "this was never
     * measured" will eventually say something worse.
     */
    @TestVisible
    private static final String PERFORMANCE_NOT_JOURNALLED =
        'This run journalled no per-stage performance. The run receipt object was built at the ' +
        'sixty-seventh stamp, so passes from that point carry their own wall time and governor ' +
        'consumption; earlier passes measured nothing, and their numbers exist only in each ' +
        'run\'s written report. Deriving them here from record timestamps would be a number ' +
        'recomputed on the page, which is not what this panel is for.';
}