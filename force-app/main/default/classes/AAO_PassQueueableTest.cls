@IsTest
private class AAO_PassQueueableTest {

    /**
     * THE DOOR AND THE ORDER ARE ONE MECHANISM, and this test is the thing that would have
     * caught the first cold rehearsal's defect before Matthew ran it.
     *
     * `S_COLD_START` was added as the ORDER's new head and the entry constructor still named
     * `S_RESOLVE`. The run began at call 0, the cold start never executed, the wrapper appeared
     * 82 seconds later when a human opened the UI, and NOTHING ERRORED - eleven lawful stages
     * on a deal with no plan. The order and the entry point had drifted, and no test could see
     * it because nothing compared them.
     */
    @IsTest
    static void theRUNBEGINSWHERETHEORDERSAYSITDOES() {
        Id sourceId = AAO_FakeId.of(AAO_Source__c.SObjectType);
        AAO_PassQueueable q = new AAO_PassQueueable(sourceId, 'door-vs-order');

        System.assertEquals(
            AAO_PassQueueable.ORDER[0],
            q.startsAt(),
            'The entry point must begin at the ORDER\'s own first stage. Naming a stage here ' +
            'instead is a second place to forget, and forgetting it costs a whole cold start ' +
            'with no error anywhere.'
        );
    }

    @IsTest
    static void theCOLDSTARTISTHEHEADOFTHEORDER() {
        // Stated as its own assertion because the reason is load-bearing: every stage after it
        // presumes a rubric exists, so a transcript on an unplanned deal must be planned before
        // anything is asked of it.
        System.assertEquals(
            AAO_PassQueueable.S_COLD_START,
            AAO_PassQueueable.ORDER[0],
            'The cold start runs first or the pass asks questions of a deal with no rubric.'
        );
    }
}
