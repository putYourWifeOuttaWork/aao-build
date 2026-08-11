/**
 * The row export and the timing report. Both are standing obligations on every run report as
 * of 6 August, so both get held to a shape rather than left to whoever writes the next report.
 */
@IsTest
private class AAO_RunExportTest {
    @IsTest
    static void everyExportCarriesItsHeaderEvenWithNothingToExport() {
        Id opp = AAO_FakeId.of(Opportunity.SObjectType);
        System.assert(AAO_RunExport.pairs('nosuchrun').startsWith('"pair_ref"'));
        System.assert(AAO_RunExport.claims(opp).startsWith('"claim_id"'));
        System.assert(AAO_RunExport.answers(opp).startsWith('"answer_key"'));
    }

    @IsTest
    static void thePairExportCarriesOffsetAndLengthSoTheCheckIsAnIntersection() {
        // Design's agents verify against the FROZEN ARTIFACT, not against our copy of the
        // quote. A verbatim column alone would only prove our string matches itself.
        String header = AAO_RunExport.pairs('nosuchrun').split('\n')[0];
        for (String col : new List<String>{
            'verbatim', 'start_offset', 'length', 'call3_verdict', 'artifact_sha256'
        }) {
            System.assert(header.contains(col), 'Missing ' + col + ' in: ' + header);
        }
    }

    @IsTest
    static void aQuoteCarryingAQuoteSurvivesTheCsv() {
        // RFC 4180, and it matters here more than usual: buyers say things in quotation marks
        // and a broken row is an unverifiable row.
        Fixture f = fixture();
        String csv = AAO_RunExport.pairs(f.runKey);
        System.assert(
            csv.contains('""supplier of choice""'),
            'Inner quotes are doubled rather than escaped away. Got: ' + csv
        );
        System.assertEquals(2, csv.split('\n').size(), 'Header plus one row, not three.');
    }

    @IsTest
    static void aRecordIsAlwaysExactlyOnePhysicalLineEvenWhenANoteCarriesATerminator() {
        // THE THIRTY-SEVENTH STAMP'S EXPORT DEFECT, and it was never an escaping bug. A lone
        // CARRIAGE RETURN reached a verification note in the org (em0806-a21/seq3 at index
        // 114 of 238 characters, em0807-a22/poq5 at index 43 of 140). RFC 4180 PERMITS CR
        // inside a quoted field, so the writer emitted it legally, and the line-oriented
        // carrier that puts these files on disk read it as a record terminator and threw
        // away the rest of the row: the note tail, the claim_id, the artifact_sha256, with
        // no error anywhere. The following row then parsed into the wreck of that one, 27
        // fields against a 15-field header, and its pair ref vanished from the export.
        //
        // This case was unreachable before: the fixture sets a verdict but never a NOTE, so
        // no test had ever put a character of model-written prose through the writer.
        Fixture f = fixture();
        AAO_Pair__c p = [
            SELECT Id FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :f.runKey AND AAO_Stage__c = 'Identified'
            LIMIT 1
        ];
        p.AAO_Verification_Note__c =
            'Terms probed.\r\nDecision chain named.\rOwnership asserted.\nEnds here.';
        update p;

        String csv = AAO_RunExport.pairs(f.runKey);

        System.assert(
            !csv.contains('\r'),
            'A bare CR inside a cell splits the record for any line-oriented reader. Got: ' +
            csv
        );
        // Apex String.split takes a REGEX and '\n' matches LF only, so THIS assertion alone
        // would have shipped green against the real defect. The CR assertion above is the
        // one that catches it. Both are kept because they fail for different reasons.
        System.assertEquals(
            2,
            csv.split('\n').size(),
            'One record is one physical line: header plus one row. Got: ' + csv
        );
        System.assert(
            csv.contains('Terms probed. Decision chain named. Ownership asserted. Ends here.'),
            'The note survives with its terminators neutralised to spaces rather than being ' +
            'truncated at the first one. Got: ' + csv
        );
    }

    @IsTest
    static void theTimingReportNamesTheWorstSingleCalloutAndTheWorstTransaction() {
        AAO_RunExport.Timings sweep = new AAO_RunExport.Timings('call 1 sweep');
        sweep.calls.add(call(14867));
        sweep.calls.add(call(18551));
        sweep.calls.add(call(21036));
        sweep.calls.add(call(16453));
        AAO_RunExport.Timings zero = new AAO_RunExport.Timings('call 0 resolve');
        zero.calls.add(call(7777));

        String s = AAO_RunExport.timingReport(new List<AAO_RunExport.Timings>{ zero, sweep });
        System.assert(s.contains('WORST SINGLE CALLOUT     21036 ms'), s);
        System.assert(s.contains('WORST TRANSACTION        70907 ms'), s);
        System.assert(
            s.contains('CUMULATIVE PER TRANSACTION'),
            'The per-callout number is comfortable and the per-transaction number is the one ' +
            'that binds. A report that showed only the first would read as safe. Got: ' + s
        );
        System.assert(s.contains('59% of the ceiling'), 'unit: percent of 120,000 ms. ' + s);
    }

    @IsTest
    static void anEmptyStageIsSkippedRatherThanPrintedAsZero() {
        AAO_RunExport.Timings none = new AAO_RunExport.Timings('join');
        String s = AAO_RunExport.timingReport(new List<AAO_RunExport.Timings>{ none });
        System.assert(!s.contains('join '), 'A stage with no callouts has no wall to report.');
    }

    private static AAO_Extract.StageResult call(Long ms) {
        AAO_Extract.StageResult r = new AAO_Extract.StageResult();
        r.elapsedMs = ms;
        return r;
    }

    private class Fixture {
        String runKey = 'exportrun01';
        Id sourceId;
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Fixture f = new Fixture();
        Account a = new Account(Name = 'AAO Export Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Export Test Deal', AccountId = a.Id, StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        String text = 'buyer\tYou are our "supplier of choice" now.';
        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = o.Id, AAO_Account__c = a.Id, AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c =
                '00000000000000000000000000000000000000000000000000000000000000ee',
            AAO_Part_Index__c = 1, AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = text, AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 6, 17, 15, 0, 0),
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{
                    'speakers' => new List<Object>{
                        new Map<String, Object>{ 'key' => 'buyer', 'display' => 'A Buyer' }
                    }
                }
            ),
            AAO_Synthetic__c = true
        );
        insert src;
        f.sourceId = src.Id;

        AAO_PassContracts.mint();
        Id contract = [
            SELECT Id FROM AAO_Evidence_Contract__c
            WHERE AAO_Proposition_Code__c = :AAO_P8Codes.SENTIMENT
                AND AAO_Contract_State__c != 'Superseded'
            LIMIT 1
        ].Id;
        String quote = 'You are our "supplier of choice" now.';
        Integer start = text.indexOf(quote);
        AAO_Pair__c located = new AAO_Pair__c(
            AAO_Run_Key__c = f.runKey, AAO_Pair_Ref__c = 'se1', AAO_Stage__c = 'Located',
            AAO_Charter__c = 'AAO_LocateCharter', AAO_Charter_Version__c = 'locate-3.0.0',
            AAO_Source__c = src.Id, AAO_Evidence_Contract__c = contract,
            AAO_Answer_Text__c = quote, AAO_Meaning__c = 'SUPPORTER',
            AAO_Start_Offset__c = start, AAO_End_Offset__c = start + quote.length(),
            AAO_Speaker_Key__c = 'buyer', AAO_Occurrence__c = 1, AAO_Occurrence_Count__c = 1,
            AAO_Pair_Key__c = AAO_PairKey.compose(f.runKey, 'se1', 'Located'),
            AAO_Synthetic__c = true
        );
        insert located;
        insert new AAO_Pair__c(
            AAO_Run_Key__c = f.runKey, AAO_Pair_Ref__c = 'se1', AAO_Stage__c = 'Identified',
            AAO_Charter__c = 'AAO_IdentifyCharter', AAO_Charter_Version__c = 'identify-1.0.0',
            AAO_Located_Pair__c = located.Id, AAO_Evidence_Contract__c = contract,
            AAO_Disposition__c = 'Identified',
            AAO_Person__c = [
                SELECT Id FROM AAO_Participant__c WHERE AAO_Source__c = :src.Id LIMIT 1
            ].Id,
            AAO_Verification__c = 'Upheld',
            AAO_Pair_Key__c = AAO_PairKey.compose(f.runKey, 'se1', 'Identified'),
            AAO_Synthetic__c = true
        );
        AAO_Synthetic.MARK = false;
        return f;
    }
}
