/**
 * The live deal. Seeded empty, and evidence arrives on it one artifact at a time.
 *
 * The difference from AAO_Demo is entirely the entry. AAO_Demo inserts a Source and then
 * adjudicates it inline, in a known order, because a rehearsal of accumulation has to be
 * deterministic about which transcript landed first. AAO_Live inserts a Source and stops.
 * The after-insert trigger enqueues, the Queueable calls the same
 * AAO_Pipeline.runForSource, and the claim appears a moment later without anybody asking
 * for it. That moment is the whole point of showing it.
 *
 * One line per transcript, from anonymous Apex:
 *
 *   AAO_Live.ingestOne();     // transcript one -> UNVERIFIED, asynchronously
 *   AAO_Live.ingestTwo();     // transcript two -> TRUE, asynchronously
 *   AAO_Live.status();        // job state, then what stands
 *   AAO_Live.reset();         // remove just this deal's rows, keep the rehearsal
 *
 * Fire ingestTwo only once ingestOne's job has finished. status() says so explicitly. The
 * accumulation would still be correct out of order — the answer carries what it has and
 * the claims carry their own occurred clocks — but the narrative would not be, and this
 * deal exists to be watched.
 */
public class AAO_Live {
    public class LiveException extends Exception {
    }

    public static String ingestOne() {
        return ingest('T1SRC');
    }

    public static String ingestTwo() {
        return ingest('T2SRC');
    }

    /**
     * Insert the artifact and stop. Everything after this is the org's own doing.
     */
    public static String ingest(String sourceCode) {
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        if (oppId == null) {
            throw new LiveException('The live deal was not scaffolded.');
        }

        Integer before = enqueuedCount();

        // AUTO stays on. This is the only difference that matters.
        AAO_Ingest.AUTO = true;
        AAO_Source__c src = AAO_Demo.findSource(c, sourceCode, oppId);

        Integer after = enqueuedCount();
        return 'INGESTED ' +
            sourceCode +
            ' as ' +
            src.Id +
            ' on ' +
            AAO_Demo.OPP_LIVE +
            '. Jobs enqueued this call: ' +
            (after - before) +
            '. Nothing has been adjudicated yet -- run AAO_Live.status() in a moment.';
    }

    // ======================================================================== status

    public static String status() {
        List<String> out = new List<String>();

        List<Opportunity> opps = [
            SELECT Id, Name FROM Opportunity WHERE Name = :AAO_Demo.OPP_LIVE LIMIT 1
        ];
        if (opps.isEmpty()) {
            return 'The live deal does not exist yet. Run AAO_Live.ingestOne().';
        }
        Id oppId = opps[0].Id;
        out.add('--- ' + AAO_Demo.OPP_LIVE + ' (' + oppId + ')');

        List<AsyncApexJob> jobs = [
            SELECT Id, Status, ExtendedStatus, CompletedDate
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'AAO_IngestQueueable'
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];
        if (jobs.isEmpty()) {
            out.add('    no ingest jobs have run');
        }
        for (AsyncApexJob j : jobs) {
            out.add(
                '    job ' +
                j.Id +
                ' ' +
                j.Status +
                (j.ExtendedStatus == null ? '' : ' (' + j.ExtendedStatus + ')')
            );
        }

        for (AAO_Source__c s : [
            SELECT Name, AAO_Source_Ref__c, AAO_Evidence_Occurred__c
            FROM AAO_Source__c
            WHERE AAO_Opportunity__c = :oppId
            ORDER BY AAO_Evidence_Occurred__c ASC
        ]) {
            out.add(
                '    source ' +
                s.Name +
                ' ' +
                s.AAO_Source_Ref__c +
                ' occurred=' +
                s.AAO_Evidence_Occurred__c.formatGmt('yyyy-MM-dd')
            );
        }

        for (AAO_Answer__c a : [
            SELECT
                Name,
                AAO_Verdict__c,
                AAO_Established_By__c,
                AAO_Element_Coverage__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :oppId
        ]) {
            out.add(
                '    answer ' +
                a.Name +
                ' ' +
                a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c +
                ' = ' +
                a.AAO_Verdict__c +
                ' by ' +
                a.AAO_Established_By__c +
                ' coverage=' +
                a.AAO_Element_Coverage__c
            );
        }

        for (AAO_Claim__c cl : [
            SELECT
                Name,
                AAO_Verdict_Before__c,
                AAO_Verdict_After__c,
                AAO_Outcome__c,
                AAO_Evidence_Occurred__c,
                AAO_Recorded_At__c,
                AAO_Internal_Person__c,
                AAO_Source__r.AAO_Source_Ref__c
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :oppId
            ORDER BY AAO_Evidence_Occurred__c ASC
        ]) {
            out.add(
                '    claim  ' +
                cl.Name +
                ' ' +
                cl.AAO_Verdict_Before__c +
                ' -> ' +
                cl.AAO_Verdict_After__c +
                ' (' +
                cl.AAO_Outcome__c +
                ') occurred=' +
                cl.AAO_Evidence_Occurred__c.formatGmt('yyyy-MM-dd') +
                ' recorded=' +
                cl.AAO_Recorded_At__c.formatGmt('yyyy-MM-dd HH:mm:ss') +
                ' key4=' +
                cl.AAO_Internal_Person__c +
                ' src=' +
                cl.AAO_Source__r.AAO_Source_Ref__c
            );
        }

        Integer sources = [SELECT COUNT() FROM AAO_Source__c WHERE AAO_Opportunity__c = :oppId];
        Integer claims = [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c = :oppId];
        out.add(
            '    candidates=' +
            [SELECT COUNT() FROM AAO_Candidate__c WHERE AAO_Opportunity__c = :oppId] +
            ' sources=' +
            sources +
            ' claims=' +
            claims
        );
        if (claims < sources) {
            out.add(
                '    PENDING: ' +
                (sources - claims) +
                ' source(s) have landed and not yet been adjudicated. Wait for the job.'
            );
        }
        return String.join(out, '\n');
    }

    /**
     * Clear just the live deal, leaving the rehearsal alone, so the walkthrough can be run
     * again from empty without rebuilding everything.
     */
    public static String reset() {
        List<Opportunity> opps = [
            SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_LIVE LIMIT 1
        ];
        if (opps.isEmpty()) {
            return 'Nothing to reset.';
        }
        Id oppId = opps[0].Id;

        AAO_Synthetic.PURGING = true;
        List<String> out = new List<String>();
        try {
            // Participants first: they hang off Sources under a Restrict constraint, so a
            // Source cannot leave while one still points at it.
            out.add('participants ' + del([
                SELECT Id FROM AAO_Participant__c
                WHERE AAO_Opportunity__c = :oppId AND AAO_Synthetic__c = TRUE
            ]));
            out.add('claims     ' + del([
                SELECT Id FROM AAO_Claim__c
                WHERE AAO_Opportunity__c = :oppId AND AAO_Synthetic__c = TRUE
            ]));
            out.add('candidates ' + del([
                SELECT Id FROM AAO_Candidate__c
                WHERE AAO_Opportunity__c = :oppId AND AAO_Synthetic__c = TRUE
            ]));
            out.add('answers    ' + del([
                SELECT Id FROM AAO_Answer__c
                WHERE AAO_Opportunity__c = :oppId AND AAO_Synthetic__c = TRUE
            ]));
            out.add('sources    ' + del([
                SELECT Id FROM AAO_Source__c
                WHERE AAO_Opportunity__c = :oppId AND AAO_Synthetic__c = TRUE
            ]));
        } finally {
            AAO_Synthetic.PURGING = false;
        }
        return 'live deal reset:\n  ' + String.join(out, '\n  ');
    }

    private static Integer del(List<SObject> rows) {
        if (!rows.isEmpty()) {
            delete rows;
        }
        return rows.size();
    }

    private static Integer enqueuedCount() {
        return Limits.getQueueableJobs();
    }
}
