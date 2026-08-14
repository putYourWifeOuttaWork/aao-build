/**
 * THE ROW EXPORT AND THE TIMINGS. Standing obligations on every run report, ruled 6 August.
 *
 * **A report without its rows cannot be verified and does not count as a report.** Design's
 * agents check the export against the frozen artifact and the regression seed, which means
 * every quote has to carry its offset and length so an intersection can be computed rather
 * than a string compared. That is the same reason the regression set keys on byte range: the
 * stored string is our copy of the evidence and the artifact is the evidence.
 *
 * **And the timings, because one number here has a hard platform limit.** The 120-second
 * cumulative-per-transaction callout ceiling is unraiseable and shared across namespaces, so a
 * run report that omits per-callout wall hides the only measurement that can end a pass by
 * platform refusal rather than by anything we chose.
 *
 * Everything here reads and prints. It writes nothing, so it can be run over a finished run
 * without changing what the run did.
 */
public with sharing class AAO_RunExport {
    private static final String NL = '\n';

    /**
     * RFC 4180: quote every field, double the inner quotes. Offsets make it verifiable.
     *
     * AND ONE RECORD IS ALWAYS ONE PHYSICAL LINE, which RFC 4180 does not require and which
     * cost three exports before it was written down. The quoting below was never wrong: a
     * lone CARRIAGE RETURN stored in a verification note travelled out of here correctly
     * quoted, because the spec explicitly PERMITS CR and LF inside a quoted field. The
     * line-oriented carrier that puts these files on disk then read that CR as a record
     * terminator, kept the bytes before it, and discarded the rest of the row: the note
     * tail, the claim_id and the artifact_sha256, silently and with no error. LEGALITY IS
     * NOT SURVIVABILITY. Every consumer of these files counts rows by counting lines, so
     * the writer now guarantees that identity instead of hoping for it.
     *
     * Measured, on the two corrupt records that still exist: `em0806-a21/seq3` carried one
     * CR at index 114 of a 238-character note, and the CSV holds exactly `note[:114]`;
     * `em0807-a22/poq5` carried one CR at index 43 of 140. Across all 403 identified pairs
     * in the sandbox, 2 notes carry a CR and 0 carry an LF, which is why this went three
     * runs without being seen.
     *
     * The '\r\n' pair collapses FIRST so a Windows terminator becomes one space and not two.
     * `replace` is used rather than `replaceAll` because these are literals, not patterns.
     */
    private static String q(Object v) {
        String s = v == null ? '' : String.valueOf(v);
        s = s.replace('\r\n', ' ').replace('\r', ' ').replace('\n', ' ');
        return '"' + s.replace('"', '""') + '"';
    }

    private static String row(List<Object> cells) {
        List<String> out = new List<String>();
        for (Object c : cells) {
            out.add(q(c));
        }
        return String.join(out, ',');
    }

    // ============================================================================ pairs

    /**
     * One row per identified pair, carrying its located half. The verbatim words travel with
     * their offset and length so the check is an intersection against the artifact rather
     * than a comparison against our own copy of it.
     */
    public static String pairs(String runKey) {
        List<String> lines = new List<String>{
            row(new List<Object>{
                'pair_ref', 'family', 'contract_code', 'verbatim', 'start_offset', 'length',
                'meaning', 'coverage', 'disposition', 'person', 'contact_resolved',
                'call3_verdict', 'verification_note', 'claim_id', 'artifact_sha256'
            })
        };
        for (AAO_Pair__c p : [
            SELECT
                AAO_Pair_Ref__c, AAO_Disposition__c, AAO_Verification__c,
                AAO_Verification_Note__c, AAO_Claim__c, AAO_Artifact_SHA256__c,
                AAO_Person__r.AAO_Display_Name__c, AAO_Person__r.AAO_Contact__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Located_Pair__r.AAO_Answer_Text__c,
                AAO_Located_Pair__r.AAO_Meaning__c,
                AAO_Located_Pair__r.AAO_Coverage__c,
                AAO_Located_Pair__r.AAO_Start_Offset__c,
                AAO_Located_Pair__r.AAO_End_Offset__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = 'Identified'
            ORDER BY AAO_Pair_Ref__c
        ]) {
            AAO_Pair__c loc = p.AAO_Located_Pair__r;
            String code = p.AAO_Evidence_Contract__r == null
                ? null
                : p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
            Decimal startAt = loc == null ? null : loc.AAO_Start_Offset__c;
            Decimal endAt = loc == null ? null : loc.AAO_End_Offset__c;
            lines.add(row(new List<Object>{
                p.AAO_Pair_Ref__c,
                AAO_LocateCharter.familyOf(code),
                code,
                loc == null ? null : loc.AAO_Answer_Text__c,
                startAt,
                startAt == null || endAt == null ? null : (endAt - startAt),
                loc == null ? null : loc.AAO_Meaning__c,
                loc == null ? null : loc.AAO_Coverage__c,
                p.AAO_Disposition__c,
                p.AAO_Person__r == null ? null : p.AAO_Person__r.AAO_Display_Name__c,
                p.AAO_Person__r == null ? null : p.AAO_Person__r.AAO_Contact__c,
                p.AAO_Verification__c,
                p.AAO_Verification_Note__c,
                p.AAO_Claim__c,
                p.AAO_Artifact_SHA256__c
            }));
        }
        return String.join(lines, NL);
    }

    // =========================================================================== claims

    public static String claims(Id opportunityId) {
        List<String> lines = new List<String>{
            row(new List<Object>{
                'claim_id', 'contract_code', 'subject_type', 'participant', 'contact',
                'criterion', 'verdict_before', 'verdict_after', 'outcome', 'interpretation',
                'basis', 'charter_version', 'rubric_version', 'evidence_occurred'
            })
        };
        for (AAO_Claim__c c : [
            SELECT Id, AAO_Subject_Type__c, AAO_Participant__r.AAO_Display_Name__c,
                AAO_Subject_Contact__c, AAO_Criterion__r.AAO_Subject__c,
                AAO_Verdict_Before__c, AAO_Verdict_After__c, AAO_Outcome__c,
                AAO_Interpretation__c, AAO_Basis__c, AAO_Charter_Version__c,
                AAO_Rubric_Version__c, AAO_Evidence_Occurred__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :opportunityId
            ORDER BY AAO_Evidence_Contract__r.AAO_Proposition_Code__c, Id
        ]) {
            lines.add(row(new List<Object>{
                c.Id,
                c.AAO_Evidence_Contract__r == null
                    ? null
                    : c.AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                c.AAO_Subject_Type__c,
                c.AAO_Participant__r == null ? null : c.AAO_Participant__r.AAO_Display_Name__c,
                c.AAO_Subject_Contact__c,
                c.AAO_Criterion__r == null ? null : c.AAO_Criterion__r.AAO_Subject__c,
                c.AAO_Verdict_Before__c,
                c.AAO_Verdict_After__c,
                c.AAO_Outcome__c,
                c.AAO_Interpretation__c,
                c.AAO_Basis__c,
                c.AAO_Charter_Version__c,
                c.AAO_Rubric_Version__c,
                c.AAO_Evidence_Occurred__c
            }));
        }
        return String.join(lines, NL);
    }

    // ========================================================================== answers

    public static String answers(Id opportunityId) {
        List<String> lines = new List<String>{
            row(new List<Object>{
                'answer_key', 'contract_code', 'subject_type', 'participant', 'contact',
                'criterion', 'verdict', 'support_counter', 'interpretation',
                'publication_state', 'projected_value', 'projected_modstamp'
            })
        };
        for (AAO_Answer__c a : [
            SELECT AAO_Answer_Key__c, AAO_Subject_Type__c, AAO_Subject_Contact__c,
                AAO_Participant__r.AAO_Display_Name__c, AAO_Criterion__r.AAO_Subject__c,
                AAO_Verdict__c, AAO_Support_Counter__c, AAO_Interpretation__c,
                AAO_Publication_State__c, AAO_Projected_Value__c, AAO_Projected_Modstamp__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :opportunityId
            ORDER BY AAO_Evidence_Contract__r.AAO_Proposition_Code__c, Id
        ]) {
            lines.add(row(new List<Object>{
                a.AAO_Answer_Key__c,
                a.AAO_Evidence_Contract__r == null
                    ? null
                    : a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                a.AAO_Subject_Type__c,
                a.AAO_Participant__r == null ? null : a.AAO_Participant__r.AAO_Display_Name__c,
                a.AAO_Subject_Contact__c,
                a.AAO_Criterion__r == null ? null : a.AAO_Criterion__r.AAO_Subject__c,
                a.AAO_Verdict__c,
                a.AAO_Support_Counter__c,
                a.AAO_Interpretation__c,
                a.AAO_Publication_State__c,
                a.AAO_Projected_Value__c,
                a.AAO_Projected_Modstamp__c
            }));
        }
        return String.join(lines, NL);
    }

    // ======================================================================== timings

    /**
     * ONE STAGE'S CALLOUTS. Addendum 20: per-callout wall, and the worst single one named
     * against the ceiling.
     *
     * **The ceiling is cumulative per TRANSACTION, not per callout, and that is the number
     * that actually binds.** A single 21-second family read is nowhere near 120; four of them
     * in one transaction is 70 seconds of a budget that cannot be raised. So this reports both
     * and says which is close.
     */
    public class Timings {
        public String stage;
        public List<AAO_Extract.StageResult> calls = new List<AAO_Extract.StageResult>();

        public Timings(String stage) {
            this.stage = stage;
        }

        public Long worst() {
            Long w = 0;
            for (AAO_Extract.StageResult c : calls) {
                if (c != null && c.elapsedMs != null && c.elapsedMs > w) {
                    w = c.elapsedMs;
                }
            }
            return w;
        }

        public Long cumulative() {
            Long t = 0;
            for (AAO_Extract.StageResult c : calls) {
                if (c != null && c.elapsedMs != null) {
                    t += c.elapsedMs;
                }
            }
            return t;
        }
    }

    /** The platform's own number, measured and primary-doc-verified. Never raised. */
    public static final Long CEILING_MS = 120000;

    /**
     * GOVERNOR CONSUMPTION, PRINTED PER STAGE. Standing obligation, ruled 6 August.
     *
     * **A ceiling we do not print is a ceiling we discover at twenty-five.** The a21 join
     * finished at SOQL 100 of 100 on seventeen pairs and nothing in the run report said so;
     * it was found by reading the debug log's limit block by hand. The callout ceiling has
     * been watched for weeks because it had a number in a document. This one did not.
     *
     * Called at the END of a stage, in the same transaction as the work it measures. A limit
     * reading taken from another transaction is a reading of nothing.
     */
    public static String governors(String stage) {
        return String.join(
            new List<String>{
                stage + ':',
                '  SOQL   ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries() +
                    pct(Limits.getQueries(), Limits.getLimitQueries()),
                '  DML    ' + Limits.getDmlStatements() + ' of ' +
                    Limits.getLimitDmlStatements() +
                    pct(Limits.getDmlStatements(), Limits.getLimitDmlStatements()),
                '  rows   ' + Limits.getDmlRows() + ' of ' + Limits.getLimitDmlRows(),
                '  CPU    ' + Limits.getCpuTime() + ' of ' + Limits.getLimitCpuTime() + ' ms'
            },
            '\n'
        );
    }

    private static String pct(Integer used, Integer cap) {
        if (cap == null || cap == 0) {
            return '';
        }
        Integer p = (Integer) ((Decimal) used / cap * 100).round();
        return '  (' + p + '%)' + (p >= 80 ? '  ** APPROACHING THE CEILING **' : '');
    }

    public static String timingReport(List<Timings> stages) {
        List<String> out = new List<String>{
            'stage timings (unit: ms, wall per callout)'
        };
        Long worstSingle = 0;
        String worstStage;
        Long worstTransaction = 0;
        String worstTransactionStage;

        for (Timings t : stages) {
            if (t == null || t.calls.isEmpty()) {
                continue;
            }
            List<String> each = new List<String>();
            for (AAO_Extract.StageResult c : t.calls) {
                each.add(String.valueOf(c.elapsedMs));
            }
            out.add(
                '  ' + t.stage.rightPad(24) +
                t.calls.size() + ' callout(s), cumulative ' + t.cumulative() +
                ' ms, worst ' + t.worst() + ' ms  [' + String.join(each, ', ') + ']'
            );
            if (t.worst() > worstSingle) {
                worstSingle = t.worst();
                worstStage = t.stage;
            }
            if (t.cumulative() > worstTransaction) {
                worstTransaction = t.cumulative();
                worstTransactionStage = t.stage;
            }
        }

        out.add('');
        out.add(
            'WORST SINGLE CALLOUT     ' + worstSingle + ' ms (' + worstStage + '), ' +
            pct(worstSingle) + ' of the 120,000 ms ceiling'
        );
        out.add(
            'WORST TRANSACTION        ' + worstTransaction + ' ms (' +
            worstTransactionStage + '), ' + pct(worstTransaction) + ' of the ceiling'
        );
        out.add(
            'The ceiling is CUMULATIVE PER TRANSACTION and shared across certified managed ' +
            'namespaces, so the second number is the one that binds. It is unraiseable by ' +
            'Support.'
        );
        return String.join(out, NL);
    }

    private static String pct(Long ms) {
        return String.valueOf((ms * 100 / CEILING_MS)) + '%';
    }
}