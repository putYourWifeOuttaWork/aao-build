/**
 * Gate 1 round two, run in the org.
 *
 * Round one graded a model against these same transcripts outside any system. This is the
 * same bar applied to the same evidence with the real machinery underneath: a real model
 * reads the artifact, writes Candidates through AAO_Pipeline, and the existing gates decide
 * what survives. The comparison against staged ground truth is the grade.
 *
 * THREE COMMANDS, NOT ONE, AND THE REASON IS A PLATFORM RULE RATHER THAN A PREFERENCE.
 * Apex forbids a callout after DML in the same transaction. Pass one writes rows; pass two
 * calls out. They therefore cannot be the same execution, and pretending otherwise would
 * mean discovering it at runtime in front of somebody. Two passes, two commands, which is
 * also exactly the shape of the live demo.
 *
 *     AAO_Gate1.reset()      no callout. Fresh deal, both artifacts, nothing adjudicated.
 *     AAO_Gate1.pass('T1SRC') one callout, then commit.
 *     AAO_Gate1.pass('T2SRC') one callout, then commit.
 *     AAO_Gate1.compare()    no callout. The grade.
 *
 * SCOPE. Everything here is confined to one Opportunity that no other part of the build
 * touches. reset() deletes only rows hanging off that deal, never AAO_Demo.purge(), which
 * clears every synthetic row in the org and would take the three demo deals with it. The
 * demo state is frozen and this must not be able to disturb it even by accident.
 */
public class AAO_Gate1 {
    public class Gate1Exception extends Exception {
    }

    /**
     * The deal a round runs on. Named per round rather than reused, because reset() purges
     * and the proof register cites runs by their rows. Purging the deal that a receipt
     * points at would leave the register describing a run that no longer exists anywhere.
     */
    public static final String OPP = 'AAO Gate1 - Model Round Two';
    public static final String OPP_BLIND = 'AAO Gate1 - Blind Reader';

    /** Which deal the next call operates on. Set it, then reset and pass. */
    public static String deal = OPP;

    /** The two artifacts, in evidence order. */
    public static final List<String> PASSES = new List<String>{ 'T1SRC', 'T2SRC' };

    // ============================================================================ reset

    /**
     * A deal with both artifacts stored and nothing adjudicated. No callout, so this is
     * safe to run repeatedly and free.
     */
    public static String reset() {
        Boolean priorAuto = AAO_Ingest.AUTO;
        // The after-insert trigger would enqueue the FIXTURE pipeline for these sources,
        // which would adjudicate them before the model ever saw them and quietly make the
        // comparison meaningless.
        AAO_Ingest.AUTO = false;
        try {
            List<String> out = new List<String>();
            out.add(purgeDeal());

            AAO_Demo.Ctx c = AAO_Demo.scaffold();
            Id oppId = ensureOpp(c);

            AAO_Synthetic.MARK = true;
            try {
                for (String code : PASSES) {
                    AAO_Source__c s = AAO_Demo.findSource(c, code, oppId);
                    out.add('source ' + code + ' ' + s.AAO_Source_Ref__c + ' ' + s.Id);
                }
            } finally {
                AAO_Synthetic.MARK = false;
            }
            out.add('opportunity ' + deal + ' ' + oppId);
            out.add('contracts in org ' + AAO_Pipeline.liveContracts().size());
            return 'GATE1 RESET\n  ' + String.join(out, '\n  ');
        } finally {
            AAO_Ingest.AUTO = priorAuto;
        }
    }

    private static Id ensureOpp(AAO_Demo.Ctx c) {
        List<Opportunity> found = [SELECT Id FROM Opportunity WHERE Name = :deal LIMIT 1];
        if (!found.isEmpty()) {
            return found[0].Id;
        }
        Opportunity o = new Opportunity(
            Name = deal,
            AccountId = c.acct.Id,
            StageName = AAO_Seed.defaultStage(),
            CloseDate = Date.newInstance(2026, 12, 31)
        );
        insert o;
        return o.Id;
    }

    /** Scoped to this deal. Deliberately not AAO_Demo.purge. */
    private static String purgeDeal() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Name = :deal];
        if (opps.isEmpty()) {
            return 'purge: no prior deal';
        }
        Set<Id> oppIds = new Map<Id, Opportunity>(opps).keySet();

        AAO_Synthetic.PURGING = true;
        List<String> out = new List<String>();
        try {
            out.add(
                'bases ' +
                del([
                    SELECT Id
                    FROM AAO_Claim_Basis__c
                    WHERE AAO_Claim__r.AAO_Opportunity__c IN :oppIds AND AAO_Synthetic__c = TRUE
                ])
            );
            out.add(
                'claims ' +
                del([
                    SELECT Id
                    FROM AAO_Claim__c
                    WHERE AAO_Opportunity__c IN :oppIds AND AAO_Synthetic__c = TRUE
                ])
            );
            out.add(
                'candidates ' +
                del([
                    SELECT Id
                    FROM AAO_Candidate__c
                    WHERE AAO_Opportunity__c IN :oppIds AND AAO_Synthetic__c = TRUE
                ])
            );
            out.add(
                'answers ' +
                del([
                    SELECT Id
                    FROM AAO_Answer__c
                    WHERE AAO_Opportunity__c IN :oppIds AND AAO_Synthetic__c = TRUE
                ])
            );
            out.add(
                'sources ' +
                del([
                    SELECT Id
                    FROM AAO_Source__c
                    WHERE AAO_Opportunity__c IN :oppIds AND AAO_Synthetic__c = TRUE
                ])
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

    // ============================================================================= pass

    /** One artifact, one model call, then the ordinary pipeline. */
    public static String pass(String sourceCode) {
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Id oppId = ensureOpp(c);
        AAO_Source__c src = sourceFor(sourceCode, oppId);

        AAO_Pipeline.Outcome o = AAO_Pipeline.runForSource(
            src.Id,
            c.internalDomains,
            AAO_Pipeline.FROM_MODEL
        );

        List<String> out = new List<String>();
        out.add(o.toString());
        if (!o.spanDrops.isEmpty()) {
            out.add('spans dropped, meaning the quote was not in the artifact as given:');
            for (AAO_Pipeline.SpanDrop d : o.spanDrops) {
                out.add('  ' + d);
            }
        }
        if (!o.blindOverrides.isEmpty()) {
            out.add('the second reader refused these elements, overriding claimed coverage:');
            for (String ov : o.blindOverrides) {
                out.add('  ' + ov);
            }
        }
        if (o.blind != null) {
            out.add(
                'BLIND   ' +
                o.blind.charter +
                '@' +
                o.blind.charterVersion +
                '  in=' +
                o.blind.usage.inputTokens +
                '  out=' +
                o.blind.usage.outputTokens +
                '  cacheRead=' +
                o.blind.usage.cacheReadTokens +
                '  promptChars=' +
                o.blind.promptChars +
                '  ms=' +
                o.blind.elapsedMs
            );
        }
        if (o.extraction != null) {
            out.add(
                'TOKENS  in=' +
                o.extraction.usage.inputTokens +
                '  out=' +
                o.extraction.usage.outputTokens +
                '  cacheRead=' +
                o.extraction.usage.cacheReadTokens +
                '  cacheWrite=' +
                o.extraction.usage.cacheCreationTokens +
                '  promptChars=' +
                o.extraction.promptChars +
                '  ms=' +
                o.extraction.elapsedMs +
                '  model=' +
                o.extraction.modelReported
            );
        }
        return 'GATE1 PASS ' + sourceCode + ' on ' + deal + '\n  ' + String.join(out, '\n  ');
    }

    private static AAO_Source__c sourceFor(String sourceCode, Id oppId) {
        Map<String, Object> fixture = AAO_Seed.fixture();
        String sourceRef;
        for (Object o : (List<Object>) fixture.get('sources')) {
            Map<String, Object> s = (Map<String, Object>) o;
            if (s.get('code') == sourceCode) {
                sourceRef = (String) s.get('sourceRef');
            }
        }
        if (sourceRef == null) {
            throw new Gate1Exception('No source "' + sourceCode + '" in the fixture.');
        }
        List<AAO_Source__c> rows = [
            SELECT Id, AAO_Source_Ref__c
            FROM AAO_Source__c
            WHERE AAO_Opportunity__c = :oppId AND AAO_Source_Ref__c = :sourceRef
            LIMIT 1
        ];
        if (rows.isEmpty()) {
            throw new Gate1Exception(
                'Source ' + sourceCode + ' is not staged on ' + deal + '. Run reset first.'
            );
        }
        return rows[0];
    }

    // ========================================================================== compare

    /**
     * The grade. For every proposition on every artifact, what the fixture staged against
     * what the model proposed, and then what the gates did with it.
     *
     * The fixture is treated as ground truth here because it was authored from the
     * transcripts by construction. That is a real limitation and it is worth stating: a
     * disagreement is evidence that the two readers differ, not proof that the model is
     * wrong. Where they differ the transcript is the tiebreaker, read by a human.
     */
    public static String compare() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Name = :deal LIMIT 1];
        if (opps.isEmpty()) {
            return 'GATE1 COMPARE: no ' + deal + '. Run reset and the passes first.';
        }
        Id oppId = opps[0].Id;
        Map<String, Object> fixture = AAO_Seed.fixture();

        List<String> out = new List<String>();
        Integer agree = 0;
        Integer differ = 0;

        for (AAO_Source__c src : [
            SELECT Id, AAO_Source_Ref__c, AAO_Artifact_SHA256__c
            FROM AAO_Source__c
            WHERE AAO_Opportunity__c = :oppId
            ORDER BY AAO_Evidence_Occurred__c
        ]) {
            out.add('');
            out.add('ARTIFACT ' + src.AAO_Source_Ref__c);

            // ---- ground truth, staged
            Map<String, Map<String, Object>> truthByCode = new Map<String, Map<String, Object>>();
            for (Object so : AAO_Pipeline.stagedFor(fixture, src.AAO_Artifact_SHA256__c)) {
                Map<String, Object> spec = (Map<String, Object>) so;
                truthByCode.put((String) spec.get('contractCode'), spec);
            }

            // ---- what the model actually caused to be written
            Map<String, AAO_Candidate__c> actualByCode = new Map<String, AAO_Candidate__c>();
            for (AAO_Candidate__c cd : [
                SELECT
                    AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                    AAO_Proposed_Verdict__c,
                    AAO_Element_Coverage__c,
                    AAO_Spans__c,
                    AAO_Outcome__c,
                    AAO_Abstention_Reason__c,
                    AAO_Interpretation__c,
                    AAO_Charter_Version__c
                FROM AAO_Candidate__c
                WHERE AAO_Source__c = :src.Id
            ]) {
                actualByCode.put(
                    cd.AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                    cd
                );
            }

            List<String> codes = new List<String>(AAO_Pipeline.liveContracts().keySet());
            codes.sort();
            for (String code : codes) {
                Map<String, Object> truth = truthByCode.get(code);
                AAO_Candidate__c actual = actualByCode.get(code);

                String expectedVerdict = truth == null
                    ? '(abstain)'
                    : (String) truth.get('proposedVerdict');
                String expectedCovered = truth == null
                    ? '-'
                    : joinSorted(AAO_Seed.strings((List<Object>) truth.get('covered')));

                String gotVerdict;
                String gotCovered;
                if (actual == null) {
                    gotVerdict = '(no row)';
                    gotCovered = '-';
                } else if (actual.AAO_Outcome__c == 'Abstained') {
                    gotVerdict = '(abstain:' + actual.AAO_Abstention_Reason__c + ')';
                    gotCovered = '-';
                } else {
                    gotVerdict = actual.AAO_Proposed_Verdict__c;
                    AAO_Model.Coverage cov = AAO_Model.parseCoverage(
                        actual.AAO_Element_Coverage__c
                    );
                    gotCovered = joinSorted(cov.covered);
                }

                Boolean verdictMatches = expectedVerdict.startsWith('(abstain')
                    ? gotVerdict.startsWith('(abstain')
                    : expectedVerdict == gotVerdict;
                Boolean coverageMatches = expectedCovered == gotCovered;
                Boolean same = verdictMatches && coverageMatches;
                if (same) {
                    agree++;
                } else {
                    differ++;
                }

                out.add(
                    '  ' +
                    (same ? 'agree ' : 'DIFFER') +
                    ' ' +
                    code +
                    '  staged[' +
                    expectedVerdict +
                    ' cov=' +
                    expectedCovered +
                    ']  model[' +
                    gotVerdict +
                    ' cov=' +
                    gotCovered +
                    ']  gate=' +
                    (actual == null ? '-' : actual.AAO_Outcome__c) +
                    (actual != null && String.isNotBlank(actual.AAO_Interpretation__c)
                        ? '\n         interpretation: ' + actual.AAO_Interpretation__c
                        : '')
                );
            }
        }

        out.add('');
        out.add('ANSWERS ON THIS DEAL');
        for (AAO_Answer__c a : [
            SELECT
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Verdict__c,
                AAO_Element_Coverage__c,
                AAO_Established_By__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :oppId
            ORDER BY AAO_Evidence_Contract__r.AAO_Proposition_Code__c
        ]) {
            AAO_Model.Coverage cov = AAO_Model.parseCoverage(a.AAO_Element_Coverage__c);
            out.add(
                '  ' +
                a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c +
                ' = ' +
                a.AAO_Verdict__c +
                '  covered=' +
                joinSorted(cov.covered) +
                '  missing=' +
                joinSorted(cov.missing) +
                '  by=' +
                a.AAO_Established_By__c
            );
        }

        out.add('');
        out.add('AGREE ' + agree + '   DIFFER ' + differ);
        return 'GATE1 COMPARE' + String.join(out, '\n');
    }

    private static String joinSorted(List<String> vals) {
        if (vals == null || vals.isEmpty()) {
            return '-';
        }
        List<String> copy = new List<String>(vals);
        copy.sort();
        return String.join(copy, ',');
    }
}
