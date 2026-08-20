/**
 * THE PROCESS PANEL. Process step (f), the hundred-thirty-second's item 8.
 *
 * > *"the minimal Process panel on the existing run page: the fifteen assessment rows (TRUE with
 * > citation, quiet blank, RED with its reason), the ghost list, qualifier state, counts through
 * > `AAO_ProcessCompute.read()`, and the cause-display vocabulary priced in its report."*
 *
 * **READ-ONLY, and asserted rather than promised** - the same posture the Run Inspector took at
 * the sixty-third, and for the same reason: a surface named "panel" that could write is a surface
 * a later session will make write. A test greps this class for every DML verb.
 *
 * ===== IT SHOWS WHAT THE ROWS SAY AND NEVER RECOMPUTES THEM.
 *
 * Every number here comes from the class that owns it - `AAO_ProcessCompute.read()` for the
 * counts, `AAO_Flags.redsOn()` for the flags, `AAO_Personas.ghostsOn()` for the ghosts. Nothing
 * is re-derived on the way to the screen, because a surface that recomputes is a second
 * implementation of somebody else's rule and the two diverge, always.
 *
 * ===== THE CAUSE VOCABULARY: `Established_False` NEVER REACHES A SCREEN.
 *
 * The hundred-thirtieth named the residue and the hundred-thirty-second made it (f)'s to price:
 * the standing cause vocabulary writes `Established_False` beside answers that read verdict TRUE
 * with interpretation DENIED, and **the label says FALSE in a system that has no FALSE.** The
 * value predates true-or-nothing.
 *
 * Two things are done about it and they are not alternatives:
 *
 *   THE DISPLAY MAPPING, here, because the panel needs words today and this is where the panel's
 *   own vocabulary belongs. A voiced no reads as a voiced no.
 *   THE PICKLIST LABEL, changed beside it, because the mapping only fixes OUR surface and a
 *   report, a list view or a Setup page still shows the raw label to anyone who looks. **The API
 *   NAME is untouched** - `Established_False` still stores, so no row moves, no code changes and
 *   no history is rewritten; only the word a human sees does.
 *
 * The full pricing is in the step (f) report. What is refused, and named so it is not proposed
 * again: renaming the API value. It would rewrite what every standing flag row stores to correct
 * a word, which is the cosmetic-change-that-rewrites-provenance shape the hundred-twenty-eighth
 * ruled out for `people-p8-v1`.
 */
public with sharing class AAO_ProcessPanel {
    /** One assessment question, as a seller reads it. */
    public class AssessmentRow {
        @AuraEnabled public String code;
        @AuraEnabled public String question;
        /** AFFIRMED, DENIED, RED or BLANK. What the seller's eye lands on first. */
        @AuraEnabled public String state;
        @AuraEnabled public String display;
        @AuraEnabled public String because;
        /** Who said it and what they said, where words established it. */
        @AuraEnabled public String citation;
        @AuraEnabled public Boolean isRed = false;
        @AuraEnabled public String css;
    }

    public class GhostRow {
        @AuraEnabled public String persona;
        @AuraEnabled public String because;
    }

    public class QualifierRow {
        @AuraEnabled public String name;
        @AuraEnabled public String question;
        @AuraEnabled public String plane;
        @AuraEnabled public Boolean mandatory = false;
        @AuraEnabled public String state;
    }

    public class CountRow {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class ProcessView {
        @AuraEnabled public String stageLine;
        @AuraEnabled public Integer redCount = 0;
        @AuraEnabled public List<AssessmentRow> assessment = new List<AssessmentRow>();
        @AuraEnabled public List<GhostRow> ghosts = new List<GhostRow>();
        @AuraEnabled public List<QualifierRow> qualifiers = new List<QualifierRow>();
        @AuraEnabled public List<CountRow> counts = new List<CountRow>();
        /** Graceful absence, in words, wherever a plane has nothing to show and a reason why. */
        @AuraEnabled public List<String> notes = new List<String>();
    }

    // ====================================================== the display vocabulary

    /**
     * The word a seller reads for a standing flag's cause. **Nothing here ever says FALSE**, and
     * nothing outside this method decides what a cause is called.
     */
    @TestVisible
    private static String wordFor(String cause) {
        if (cause == AAO_Flags.CAUSE_FALSE) {
            // The value's API name is `Established_False` and it predates true-or-nothing. What
            // it MEANS is the hundred-twentieth's voiced no: an establishment in the customer's
            // own words, about the negative, standing as evidence rather than as a false.
            return 'Voiced no';
        }
        if (cause == AAO_Flags.CAUSE_UNMET) {
            return 'Not established';
        }
        return cause;
    }

    // ============================================================== the reading

    public static ProcessView read(Id opportunityId) {
        ProcessView v = new ProcessView();
        if (opportunityId == null) {
            v.notes.add('No opportunity, so nothing to show.');
            return v;
        }

        Integer ordinal = AAO_Flags.stageOrdinalOf(opportunityId);
        Opportunity opp = [
            SELECT StageName FROM Opportunity WHERE Id = :opportunityId LIMIT 1
        ];
        v.stageLine = ordinal == null
            ? opp.StageName + ' (outside the open stages, so no by-stage flag can fire)'
            : opp.StageName + ' (stage ' + ordinal + ')';

        assessment(opportunityId, v);
        ghosts(opportunityId, v);
        qualifiers(opportunityId, ordinal, v);
        counts(opportunityId, v);
        return v;
    }

    /**
     * One row per declared Process contract, whatever its state - **including the ones with
     * nothing on them.** A panel that showed only what fired would be a panel that cannot show a
     * quiet blank, and a quiet blank is one of the three states the hundred-twentieth ruled.
     */
    private static void assessment(Id opportunityId, ProcessView v) {
        Map<String, AAO_Evidence_Contract__c> contracts =
            new Map<String, AAO_Evidence_Contract__c>();
        for (AAO_Evidence_Contract__c ec : [
            SELECT Id, AAO_Proposition_Code__c, AAO_Proposition_Short__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Family__c = :AAO_ApplicableSet.PROCESS
              AND AAO_Contract_State__c NOT IN :AAO_ContractState.DEAD
            ORDER BY AAO_Proposition_Code__c
        ]) {
            contracts.put(ec.AAO_Proposition_Code__c, ec);
        }
        if (contracts.isEmpty()) {
            v.notes.add(
                'This org declares no Process questions, so the assessment plane has nothing ' +
                'to show. Graceful absence rather than a defect.'
            );
            return;
        }

        // What the words established, per question. EXTRACTED to `readingsFor` so the native
        // Assessment surface writes the SAME reading and the SAME citation this panel shows.
        // Two surfaces disagreeing about one question is the worst defect available here,
        // because both of them look authoritative and neither says which to believe.
        Map<String, Reading> readings = readingsFor(opportunityId);
        Map<String, String> voiced = new Map<String, String>();
        Map<String, String> citations = new Map<String, String>();
        for (String code : readings.keySet()) {
            voiced.put(code, readings.get(code).interpretation);
            citations.put(code, readings.get(code).citation);
        }

        Map<String, AAO_Flags.Red> redByCode = new Map<String, AAO_Flags.Red>();
        for (AAO_Flags.Red r : AAO_Flags.redsOn(opportunityId)) {
            redByCode.put(r.code, r);
        }

        for (String code : contracts.keySet()) {
            AssessmentRow row = new AssessmentRow();
            row.code = code;
            row.question = contracts.get(code).AAO_Proposition_Short__c;
            AAO_Flags.Red red = redByCode.get(code);
            String reading = voiced.get(code);

            if (red != null && red.isRed == true) {
                row.state = 'RED';
                row.isRed = true;
                row.display = wordFor(red.cause);
                row.because = red.because;
                row.citation = citations.get(code);
                row.css = 'aaorow aaored';
            } else if (reading == 'AFFIRMED') {
                row.state = 'AFFIRMED';
                row.display = 'Yes';
                row.citation = citations.get(code);
                row.because = null;
                row.css = 'aaorow aaoyes';
            } else if (reading == 'DENIED') {
                // Established as a no, and quiet at this stage. It is still an establishment and
                // still carries its words: silence and a voiced no must never read alike.
                row.state = 'DENIED';
                row.display = wordFor(AAO_Flags.CAUSE_FALSE);
                row.citation = citations.get(code);
                row.because = red == null ? null : red.because;
                row.css = 'aaorow aaono';
            } else {
                row.state = 'BLANK';
                row.display = null;
                row.because = red == null
                    ? 'Nothing established, and no deal-killer flag stands on it.'
                    : red.because;
                row.css = 'aaorow aaoblank';
            }
            v.assessment.add(row);
        }
        v.redCount = AAO_Flags.redCount(opportunityId);
    }

    /**
     * ONE QUESTION'S READING AND THE WORDS BEHIND IT.
     *
     * Public because the native Assessment writer consumes exactly this: the panel and the
     * Altify screen must not be able to disagree about what a call established or about which
     * words prove it.
     */
    public class Reading {
        public String code;
        public String interpretation;
        /** The full citation: who, which call, when it happened, where in it, then the words. */
        public String citation;
        /**
         * THE SAME CITATION FOR A NOTE THAT CANNOT AFFORD THE FULL ONE. The map row's
         * `ALTF__Note__c` is 1,024 characters FOR THE WHOLE ROW, shared across four dimensions,
         * so roughly 256 each, and a ninety-character header eats a third of one dimension's
         * allowance. This drops the call title and the timestamp ONLY: the source short name
         * walks back to both, so nothing becomes unfindable, it just takes one hop.
         */
        public String compactCitation;
    }

    /**
     * The strongest reading per question, with its citation.
     *
     * Several people can answer one question, so the strongest reading wins: a voiced no
     * outranks an affirmed, which is the hundred-twentieth's own tiebreak and the same one the
     * flag path applies.
     */
    public static Map<String, Reading> readingsFor(Id opportunityId) {
        Map<String, Reading> out = new Map<String, Reading>();
        if (opportunityId == null) {
            return out;
        }
        List<AAO_Answer__c> answers = [
            SELECT AAO_Interpretation__c, AAO_Verdict__c, AAO_Spans__c,
                   AAO_Subject_Contact__r.Name, AAO_Participant__r.AAO_Display_Name__c,
                   AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :opportunityId
              AND AAO_Publication_State__c = 'Live'
              AND AAO_Superseded_By__c = null
              AND AAO_Verdict__c = 'TRUE'
              AND AAO_Evidence_Contract__r.AAO_Family__c = :AAO_ApplicableSet.PROCESS
            ORDER BY AAO_Evidence_Occurred__c ASC NULLS FIRST
        ];
        // ONE SOURCE QUERY FOR THE WHOLE RENDER, never one per row. Fifteen questions must not
        // become fifteen queries against a governor budget the join already spends most of.
        Map<Id, AAO_Source__c> sources = sourcesFor(answers);
        for (AAO_Answer__c a : answers) {
            String code = a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
            if (out.containsKey(code) && out.get(code).interpretation == 'DENIED') {
                continue;
            }
            Reading r = new Reading();
            r.code = code;
            r.interpretation = a.AAO_Interpretation__c;
            r.citation = citationOf(a, sources);
            r.compactCitation = compactCitationOf(a, sources);
            out.put(code, r);
        }
        return out;
    }

    /** Every source any of these answers quotes, in one query. */
    private static Map<Id, AAO_Source__c> sourcesFor(List<AAO_Answer__c> answers) {
        Set<Id> ids = new Set<Id>();
        for (AAO_Answer__c a : answers) {
            for (AAO_Model.Span sp : spansOf(a.AAO_Spans__c)) {
                if (String.isNotBlank(sp.sourceId)) {
                    try {
                        ids.add(Id.valueOf(sp.sourceId));
                    } catch (Exception e) {
                        // A span naming something that is not an Id names no call. It is not a
                        // citation we can complete, and a fabricated one is worse than none.
                    }
                }
            }
        }
        if (ids.isEmpty()) {
            return new Map<Id, AAO_Source__c>();
        }
        return new Map<Id, AAO_Source__c>([
            SELECT Id, Name, AAO_Meeting_Title__c, AAO_Evidence_Occurred__c
            FROM AAO_Source__c WHERE Id IN :ids
        ]);
    }

    private static List<AAO_Model.Span> spansOf(String spansJson) {
        if (String.isBlank(spansJson)) {
            return new List<AAO_Model.Span>();
        }
        try {
            AAO_Model.SpanSet set0 = AAO_Model.parseSpans(spansJson);
            return set0 == null || set0.spans == null
                ? new List<AAO_Model.Span>()
                : set0.spans;
        } catch (Exception e) {
            return new List<AAO_Model.Span>();
        }
    }

    /**
     * ===== A CITATION, NOT A QUOTATION.
     *
     * The Glossary: "Citation - Span plus source reference plus locator. Every
     * evidence-established verdict has one. There is no other basis." This used to emit
     * `Who: "quote"` - a span and an attribution, with the source reference and the locator
     * both ABSENT - so a reader could not answer WHICH CALL, WHEN, or WHERE IN IT. A quote with
     * a name attached is a quotation; a citation is a quotation you can walk back to its bytes.
     *
     * The canonical form, ruled at the hundred-fifty-sixth:
     *
     *   Dana Okafor . Brightwell, call 1 . 18 Aug 2026, 6:24 PM PDT . SRC-00000057 @1797-1881
     *   "my honest problem is our forecast is off by around twenty percent every quarter."
     */
    private static String citationOf(AAO_Answer__c a, Map<Id, AAO_Source__c> sources) {
        return renderCitation(a, sources, false);
    }

    private static String compactCitationOf(AAO_Answer__c a, Map<Id, AAO_Source__c> sources) {
        return renderCitation(a, sources, true);
    }

    private static String renderCitation(
        AAO_Answer__c a, Map<Id, AAO_Source__c> sources, Boolean compact
    ) {
        String who = a.AAO_Participant__r != null &&
                String.isNotBlank(a.AAO_Participant__r.AAO_Display_Name__c)
            ? a.AAO_Participant__r.AAO_Display_Name__c
            : (a.AAO_Subject_Contact__r == null ? null : a.AAO_Subject_Contact__r.Name);

        List<AAO_Model.Span> spans = spansOf(a.AAO_Spans__c);
        if (spans.isEmpty()) {
            // No span is no citation. An attribution alone WAS the defect, not a fallback.
            return null;
        }
        AAO_Model.Span sp = spans[0];
        AAO_Source__c src;
        if (String.isNotBlank(sp.sourceId)) {
            try {
                src = sources.get(Id.valueOf(sp.sourceId));
            } catch (Exception e) {
                src = null;
            }
        }

        // NO SOURCE IS NO CITATION, and this is the 156th's own definition enforced at the
        // only place that can enforce it. "Span plus source reference plus locator" - a span
        // with a name attached and no call behind it is the QUOTATION the stamp refused, and
        // emitting one here would reintroduce the defect one layer down while looking fixed.
        if (src == null) {
            return null;
        }
        List<String> head = new List<String>();
        if (String.isNotBlank(who)) {
            head.add(who);
        }
        // WHICH CALL, and never a fabricated one: an unnamed call is honestly unnamed, and the
        // source short name below still finds it.
        if (!compact && src != null && String.isNotBlank(src.AAO_Meeting_Title__c)) {
            head.add(src.AAO_Meeting_Title__c);
        }
        // WHEN THE CALL HAPPENED, never when the machine wrote the row: CreatedDate would date
        // a decade-old conversation to last Tuesday. Rendered in the ORG's timezone with the
        // zone named, because a floating local time makes two readers disagree about one row.
        if (!compact && src != null && src.AAO_Evidence_Occurred__c != null) {
            head.add(src.AAO_Evidence_Occurred__c.format('d MMM yyyy, h:mm a zzz', orgZone()));
        }
        // WHERE IN IT. The short name is the Source's own `Name`; no second identity is minted,
        // one stamp after a key that omitted the opportunity.
        if (src != null) {
            head.add(
                sp.startOffset == null
                    ? src.Name
                    : src.Name + ' @' + sp.startOffset +
                      (sp.endOffset == null ? '' : '-' + sp.endOffset)
            );
        }
        if (head.isEmpty()) {
            return null;
        }

        String out = String.join(head, ' \u00b7 ');
        if (String.isNotBlank(sp.quote)) {
            out += '\n"' + sp.quote + '"';
        }
        // MORE THAN ONE SPAN: the canonical citation and a plain count of the rest. The ledger
        // holds every span regardless; the note is a MIRROR and our own row is the record.
        if (spans.size() > 1) {
            out += ' (+' + (spans.size() - 1) + ' more on the ledger)';
        }
        return out;
    }

    /**
     * The org's default timezone, read once per transaction. Not the running user's: a citation
     * is a durable artifact read by many people, and two readers must not see two times.
     */
    private static String orgZoneCache;

    private static String orgZone() {
        if (orgZoneCache == null) {
            orgZoneCache = [SELECT TimeZoneSidKey FROM Organization LIMIT 1].TimeZoneSidKey;
        }
        return orgZoneCache;
    }


    private static void ghosts(Id opportunityId, ProcessView v) {
        AAO_Personas.Reading r = AAO_Personas.ghostsOn(opportunityId);
        for (AAO_Personas.Ghost g : r.ghosts) {
            GhostRow row = new GhostRow();
            row.persona = g.persona;
            row.because = g.because;
            v.ghosts.add(row);
        }
        if (r.ghosts.isEmpty()) {
            v.notes.add(
                r.matched.isEmpty()
                    ? 'No persona gap stands. Nothing on this deal is expected and unfilled.'
                    : 'No persona gap stands; ' + r.matched.size() +
                      ' of the people on this deal fill an expected persona.'
            );
        }
        v.notes.addAll(r.notes);
    }

    /**
     * The qualifiers this deal's stage carries, and what is known about each.
     *
     * **THIS IS THE PLANE WITH THE LEAST TO SAY, AND IT SAYS SO.** Qualifiers carry no contracts
     * yet - that build is the (b) ruling's parked eventual home - so no qualifier has an answer
     * and the honest state on every row is "not established". Showing the rows anyway is the
     * point: a seller can see what the stage asks of them before anything can answer it, and a
     * panel that hid the plane until it worked would hide the fact that it does not.
     */
    private static void qualifiers(Id opportunityId, Integer ordinal, ProcessView v) {
        if (!AAO_Modules.present(AAO_Modules.SALES_PROCESS, opportunityId)) {
            v.notes.add(
                'Sales Process is not present for this deal, so it carries no qualifiers and ' +
                'the vendor stage gate is not in play. Everything else on this panel stands.'
            );
            return;
        }
        List<ALTF__Sales_Process_Stage_Qualifier__c> junctions = [
            SELECT ALTF__Mandatory__c,
                   ALTF__Sales_Process_Stage__r.ALTF__Stage__c,
                   ALTF__Sales_Process_Qualifier__r.Name,
                   ALTF__Sales_Process_Qualifier__r.ALTF__Question__c,
                   ALTF__Sales_Process_Qualifier__r.ALTF__Tip__c
            FROM ALTF__Sales_Process_Stage_Qualifier__c
            ORDER BY ALTF__Sales_Process_Qualifier__r.Name
        ];
        if (junctions.isEmpty()) {
            v.notes.add('This org has no sales-process qualifiers configured.');
            return;
        }
        for (ALTF__Sales_Process_Stage_Qualifier__c j : junctions) {
            QualifierRow row = new QualifierRow();
            row.name = j.ALTF__Sales_Process_Qualifier__r.Name;
            row.question = j.ALTF__Sales_Process_Qualifier__r.ALTF__Question__c;
            row.mandatory = j.ALTF__Mandatory__c == true;
            String tip = j.ALTF__Sales_Process_Qualifier__r.ALTF__Tip__c;
            row.plane = String.isNotBlank(tip) && tip.startsWith('COMPUTED')
                ? 'computed'
                : 'evidence';
            row.state = 'not established';
            v.qualifiers.add(row);
        }
        v.notes.add(
            'Qualifiers show what each stage asks and carry no state yet: they have no ' +
            'contracts, so nothing can answer them. That build is named and parked, not missing.'
        );
    }

    private static void counts(Id opportunityId, ProcessView v) {
        AAO_ProcessCompute.Reading r = AAO_ProcessCompute.read(opportunityId);
        add(v, 'people on the deal', String.valueOf(r.counts.peopleOnDeal));
        add(v, 'external', String.valueOf(r.counts.peopleExternal));
        add(v, 'criteria', String.valueOf(r.counts.criteria));
        add(v, 'formal criteria', String.valueOf(r.counts.criteriaFormal));
        add(v, 'insight cards', String.valueOf(r.counts.cards));
        add(v, 'people with an insight', String.valueOf(r.counts.peopleWithAnInsight));
        add(v, 'people without one', String.valueOf(r.counts.peopleWithNoInsight));
        v.notes.addAll(r.notes);
    }

    private static void add(ProcessView v, String label, String value) {
        CountRow c = new CountRow();
        c.label = label;
        c.value = value;
        v.counts.add(c);
    }
}
