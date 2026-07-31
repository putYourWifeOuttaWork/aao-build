/**
 * Discovery's two decisions that do not need an org to test: how elements come out of
 * authored Help, and what happens when a query matches nothing.
 *
 * The end-to-end receipt is AAO_Discovery.exitTest(), run against the real ALTF tables.
 * It is not a unit test and does not belong here: it writes to managed objects and its
 * whole value is that it touches the org rather than a fixture.
 */
@IsTest
private class AAO_DiscoveryTest {
    // ================================================================ element parsing

    @IsTest
    static void elementsComeOutOfAuthoredHelpText() {
        String help =
            'Budget is confirmed when a decision maker states that funds are approved.\n' +
            '\n' +
            'Elements:\n' +
            '- e1: funds are approved\n' +
            '- e2: allocated to this initiative specifically\n' +
            '- e3: available in the current fiscal year';

        AAO_Discovery.Elements el = AAO_Discovery.parseElements(help, 'the proposition');

        System.assertEquals('Authored', el.basis);
        System.assertEquals(3, el.elements.size());
        Map<String, Object> first = (Map<String, Object>) el.elements[0];
        System.assertEquals('e1', first.get('id'));
        System.assertEquals('funds are approved', first.get('text'));
    }

    /**
     * The honest path, and the one a real customer's Help text will take. Nobody outside
     * this build writes an Elements block, so an unauthored decomposition has to reach
     * Inferred_Pending rather than being invented as Authored.
     */
    @IsTest
    static void helpWithNoElementsBlockIsInferredPendingNotAuthored() {
        AAO_Discovery.Elements el = AAO_Discovery.parseElements(
            'Just some guidance prose, the way a customer actually writes it.',
            'The customer and the seller have agreed an implementation timeline.'
        );

        System.assertEquals('Inferred_Pending', el.basis);
        System.assertEquals(
            1,
            el.elements.size(),
            'The number of parts is never unknown, so an unauthored proposition still ' +
            'gets one element.'
        );
        System.assertEquals(
            'The customer and the seller have agreed an implementation timeline.',
            ((Map<String, Object>) el.elements[0]).get('text'),
            'And that element is the proposition itself, not a guess at its parts.'
        );
    }

    @IsTest
    static void blankHelpIsInferredPending() {
        System.assertEquals(
            'Inferred_Pending',
            AAO_Discovery.parseElements(null, 'a proposition').basis
        );
        System.assertEquals(
            'Inferred_Pending',
            AAO_Discovery.parseElements('   ', 'a proposition').basis
        );
    }

    /** A bullet outside the block is prose, not an element. */
    @IsTest
    static void bulletsBeforeTheElementsHeadingAreNotElements() {
        String help =
            '- this is a prose bullet: it is not an element\n' +
            'Elements:\n' +
            '- e1: the only real one';

        AAO_Discovery.Elements el = AAO_Discovery.parseElements(help, 'p');
        System.assertEquals(1, el.elements.size());
        System.assertEquals('e1', ((Map<String, Object>) el.elements[0]).get('id'));
    }

    // =========================================================== item 37, the guard

    /**
     * An empty rubric and a filter that matched nothing are different facts, and only one
     * of them is the customer's. This is the branch where the table really is empty.
     *
     * Tests see no ALTF rows, so this exercises the cold-start branch directly. The other
     * branch is asserted on its message construction below, because reaching it requires
     * managed-object rows that a unit test has no business creating.
     */
    @IsTest
    static void anEmptyQuestionTableReportsColdStartNotAFault() {
        insert new ALTF__Opportunity_Plan_Type_List__c(
            Name = AAO_Discovery.PLAN_TYPE,
            ALTF__AssessmentQuestionIds__c = 'AAO_T1,AAO_T2',
            ALTF__Show_Assessment__c = true
        );

        Boolean threw = false;
        String message;
        Test.startTest();
        try {
            AAO_Discovery.discover();
        } catch (AAO_Discovery.DiscoveryException e) {
            threw = true;
            message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, threw);
        System.assert(
            message.contains('genuinely empty'),
            'With no rows at all this is the cold-start condition and must say so. ' +
            'Got: ' + message
        );
        System.assert(
            !message.contains('FILTER FAULT'),
            'And it must not accuse the query. Got: ' + message
        );
    }

    /** No plan type at all is its own message, not an empty rubric. */
    @IsTest
    static void noPlanTypeIsNotAnEmptyRubric() {
        Boolean threw = false;
        String message;
        Test.startTest();
        try {
            AAO_Discovery.discover();
        } catch (AAO_Discovery.DiscoveryException e) {
            threw = true;
            message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, threw);
        System.assert(
            message.contains('Author the rubric first'),
            'Got: ' + message
        );
    }

    /** A plan type that lists nothing is a configuration fact, stated as one. */
    @IsTest
    static void aPlanTypeListingNoQuestionsSaysSo() {
        insert new ALTF__Opportunity_Plan_Type_List__c(
            Name = AAO_Discovery.PLAN_TYPE,
            ALTF__Show_Assessment__c = true
        );

        Boolean threw = false;
        String message;
        Test.startTest();
        try {
            AAO_Discovery.discover();
        } catch (AAO_Discovery.DiscoveryException e) {
            threw = true;
            message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, threw);
        System.assert(message.contains('lists no questions'), 'Got: ' + message);
    }
}
