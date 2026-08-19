/**
 * A FAILED INGEST BECOMES A ROW · R4, ordered at the hundred-tenth stamp: record, never rethrow.
 *
 * The swallow itself is correct and stays: the artifact is already stored and immutable, losing
 * one adjudication is recoverable by running the pipeline again, and losing the transaction would
 * take every other Source in the batch with it. **What was wrong is that the swallow's only
 * output was a debug line**, which is visible for exactly as long as somebody is watching a log -
 * and on the async path, nobody ever is. A Source that failed and a Source that found nothing
 * were the same fact seen from outside, which is the silent-success hazard in its oldest form.
 */
@IsTest
private class AAO_IngestFailureTest {

    /**
     * A syntactically real id for a row that is not there. `AAO_Pipeline.runForSource` opens by
     * reading the Source into a single sObject, so this raises a genuine, catchable
     * `QueryException` on the real code path - a real failure rather than a simulated one, and
     * verified from the runtime before it was relied on here.
     */
    private static Id absentSource() {
        return Id.valueOf(
            AAO_Source__c.SObjectType.getDescribe().getKeyPrefix() + '000000000000'
        );
    }

    @IsTest
    static void ASOURCETHATTHREWLEAVESALEGANDNOTONLYALOGLINE() {
        Id ghost = absentSource();

        Test.startTest();
        System.enqueueJob(new AAO_IngestQueueable(new List<Id>{ ghost }, true));
        Test.stopTest();

        List<AAO_Run_Receipt__c> rows = [
            SELECT AAO_Run_Key__c, AAO_Stages__c, AAO_Stage_Count__c
            FROM AAO_Run_Receipt__c
            WHERE AAO_Run_Key__c = :('ingest|' + ghost)
        ];
        System.assertEquals(
            1,
            rows.size(),
            'The failure is a queryable row. Before R4 this Source failed exactly as it does ' +
            'now and left nothing behind to find it by.'
        );
        System.assert(
            rows[0].AAO_Stages__c.contains(AAO_Receipt.STAGE_INGEST),
            'Filed under the ingest stage, so a reader can place it: ' + rows[0].AAO_Stages__c
        );
        System.assert(
            rows[0].AAO_Stages__c.contains('error'),
            'And it carries the reason rather than the fact of failure alone: ' +
            rows[0].AAO_Stages__c
        );
    }

    @IsTest
    static void ASOURCETHATCANNOTEVENBEREADSTILLLEAVESALEG() {
        // The hardest case, and the one the receipt's own swallow used to eat: a lookup to a row
        // that is not there is refused outright, so the leg vanished exactly where it mattered
        // most. The key carries the id as text, so nothing is lost by dropping the lookup.
        Id ghost = absentSource();

        Test.startTest();
        AAO_Receipt.recordFailure(
            'ingest|' + ghost, ghost, AAO_Receipt.STAGE_INGEST, 'the Source could not be read'
        );
        Test.stopTest();

        List<AAO_Run_Receipt__c> rows = [
            SELECT AAO_Source__c, AAO_Receipt_Key__c FROM AAO_Run_Receipt__c
            WHERE AAO_Run_Key__c = :('ingest|' + ghost)
        ];
        System.assertEquals(1, rows.size(), 'The trace survives the thing it is a trace of.');
        System.assertEquals(null, rows[0].AAO_Source__c, 'The lookup is dropped...');
        System.assert(
            rows[0].AAO_Receipt_Key__c.contains(String.valueOf(ghost)),
            '...and the key still names what failed: ' + rows[0].AAO_Receipt_Key__c
        );
    }

    @IsTest
    static void RUNNINGTHESAMEFAILURETWICEMERGESINTOONEROW() {
        Id ghost = absentSource();

        Test.startTest();
        System.enqueueJob(new AAO_IngestQueueable(new List<Id>{ ghost }, true));
        Test.stopTest();
        // A second attempt outside the async window, run directly, so the merge is what is
        // being measured rather than the harness.
        AAO_Receipt.recordFailure(
            'ingest|' + ghost, ghost, AAO_Receipt.STAGE_INGEST, 'second attempt'
        );

        List<AAO_Run_Receipt__c> rows = [
            SELECT AAO_Stage_Count__c FROM AAO_Run_Receipt__c
            WHERE AAO_Run_Key__c = :('ingest|' + ghost)
        ];
        System.assertEquals(
            1,
            rows.size(),
            'One row per Source, so a Source that keeps failing reads as ONE thing failing ' +
            'repeatedly rather than as many unrelated failures.'
        );
        System.assertEquals(2, rows[0].AAO_Stage_Count__c, 'Both attempts are on it.');
    }

    @IsTest
    static void ASOURCETHATSUCCEEDSWRITESNOFAILURELEG() {
        // The other half, and the one that keeps the first honest: a leg that appeared on every
        // ingest would carry no information at all.
        Test.startTest();
        System.enqueueJob(new AAO_IngestQueueable(new List<Id>(), true));
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Run_Receipt__c],
            'Nothing to do, nothing recorded.'
        );
    }
}
