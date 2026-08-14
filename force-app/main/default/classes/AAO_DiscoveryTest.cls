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

    // ============================================================ supersede, item 44

    private static ALTF__Assessment_Question__c question(String sentence) {
        return new ALTF__Assessment_Question__c(
            Name = 'Budget Confirmed',
            ALTF__AltifyId__c = 'AAO_T1',
            ALTF__Question__c = 'Is it worth winning?',
            ALTF__Criterion_Text__c = 'Budget Confirmed',
            ALTF__Long_Question__c = sentence,
            ALTF__Help__c = 'Guidance.\n\nElements:\n- e1: the only part',
            ALTF__Order_Number__c = 1,
            ALTF__Active__c = true,
            ALTF__Mandatory__c = true
        );
    }

    /**
     * ITEM 44. A customer edits the wording of a rubric question mid-quarter. That is a new
     * generation of the proposition, not a correction to the old one, because every claim
     * already stamped with the old contract was adjudicated against words the new one does
     * not carry.
     *
     * The old contract is marked Superseded and points at its replacement. It is never
     * deleted: the delete law exists precisely so those claims stay explicable forever.
     */
    @IsTest
    static void editingAQuestionUpstreamSupersedesTheOldGenerationRatherThanReplacingIt() {
        insert new ALTF__Opportunity_Plan_Type_List__c(
            Name = AAO_Discovery.PLAN_TYPE,
            ALTF__AssessmentQuestionIds__c = 'AAO_T1',
            ALTF__Show_Assessment__c = true
        );
        ALTF__Assessment_Question__c q = question(
            'The decision maker has confirmed budget is secured.'
        );
        insert q;

        AAO_Discovery.Derived first = AAO_Discovery.discover();
        System.assertEquals(1, first.byCode.size());
        System.assertEquals(0, first.superseded, 'Nothing to retire on a first pass.');
        Id firstId = first.byCode.get('AAO_T1').Id;

        // The customer rewords the question.
        q.ALTF__Long_Question__c =
            'The decision maker has confirmed budget is secured AND allocated.';
        update q;

        Test.startTest();
        AAO_Discovery.Derived second = AAO_Discovery.discover();
        Test.stopTest();

        System.assertEquals(
            1,
            second.superseded,
            'One generation retired. Got notes: ' + second.notes
        );
        Id secondId = second.byCode.get('AAO_T1').Id;
        System.assertNotEquals(
            firstId,
            secondId,
            'A changed content hash is a different contract, not an edited one.'
        );

        AAO_Evidence_Contract__c old = [
            SELECT AAO_Contract_State__c, AAO_Superseded_By__c, AAO_Proposition_Text__c
            FROM AAO_Evidence_Contract__c
            WHERE Id = :firstId
        ];
        System.assertEquals('Superseded', old.AAO_Contract_State__c);
        System.assertEquals(
            secondId,
            old.AAO_Superseded_By__c,
            'And it names its replacement, so lineage is followable.'
        );
        System.assertEquals(
            'The decision maker has confirmed budget is secured.',
            old.AAO_Proposition_Text__c,
            'The old words survive verbatim. That is the whole reason it is not deleted: ' +
            'a claim stamped with this contract was judged against these words.'
        );

        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM AAO_Evidence_Contract__c
                WHERE
                    AAO_Rubric_Version__c = :AAO_Discovery.RUBRIC_VERSION
                    AND AAO_Contract_State__c != 'Superseded'
            ],
            'Exactly one live generation.'
        );
    }

    /** And a rubric-scoped reader must not hand a superseded generation to anything. */
    @IsTest
    static void aSupersededGenerationIsInvisibleToTheScopedReader() {
        insert new ALTF__Opportunity_Plan_Type_List__c(
            Name = AAO_Discovery.PLAN_TYPE,
            ALTF__AssessmentQuestionIds__c = 'AAO_T1',
            ALTF__Show_Assessment__c = true
        );
        ALTF__Assessment_Question__c q = question('First wording.');
        insert q;
        AAO_Discovery.discover();

        q.ALTF__Long_Question__c = 'Second wording.';
        update q;

        Test.startTest();
        AAO_Discovery.discover();
        Test.stopTest();

        // The product set: unmarked, active, non-superseded. Discovery writes unmarked
        // rows, so this is exactly what it produced.
        List<AAO_Evidence_Contract__c> live = AAO_Rubric.inventory();
        System.assertEquals(1, live.size(), 'One generation, not two.');
        System.assertEquals('Second wording.', live[0].AAO_Proposition_Text__c);
    }
}