/**
 * The People ontology read. The behaviours worth holding are the ones that would have caught
 * the failure this class exists because of: that the text is byte-exact, that a short family
 * refuses loudly rather than authoring a partial rubric, and that the compound questions are
 * marked as our decomposition rather than Altify's.
 *
 * These run against the real ALTF labels in the org, deliberately. A fixture would test the
 * assembler and not the read, and the read is the part that was wrong.
 */
@IsTest
private class AAO_PeopleOntologyTest {

    /**
     * The labels exactly as read from `aossb2` in session 43 by the Tooling API, overlay
     * applied and empty. Byte-exact including `organisation`, `jeopardise`, the stray hyphen
     * and the curly apostrophes.
     *
     * A fixture rather than a live read because APEX CANNOT READ THESE AT ALL — ExternalString
     * is Tooling-only and 2,576 of 2,930 ALTF labels are protected. That is recorded in
     * AAO_PeopleOntology and is the blocker this class was built around, not a shortcut.
     */
    private static Map<String, String> fixture() {
        return new Map<String, String>{
            'AM_OM_SUPPORT_GUIDED_QUESTION_1' => 'Has this person expressed a preference for a specific solution?',
            'AM_OM_SUPPORT_GUIDED_QUESTION_2' => 'Has this person told you they prefer your solution over all other alternatives?',
            'AM_OM_SUPPORT_GUIDED_QUESTION_4' => 'Does this person believe your solution is critical to their success and do they sell internally for you in your absence?',
            'AM_OM_SUPPORT_GUIDED_QUESTION_5' => 'Is this person mentoring you by providing guidance, political insight, or competitive information?',
            'AM_OM_SUPPORT_GUIDED_QUESTION_6' => 'Has this person told you they prefer an alternate solution, including an internal solution or do nothing at all?',
            'AM_OM_SUPPORT_GUIDED_QUESTION_7' => 'Is this person mentoring your competition and working to help them win?',
            'AM_OM_SUPPORT_GUIDED_QUESTION_11' => 'Does this person prefer an alternative solution -including an internal solution or nothing at all?',
            'AM_OM_SUPPORT_GUIDED_QUESTION_14' => 'Is this person vocal in their support of your competition?',
            'AM_OM_SUPPORT_GUIDED_QUESTION_16' => 'Do you have evidence that this person believes your success will hurt their company or jeopardise their personal success?',
            'AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_3' => 'Do others seek this person out for advice and direction?',
            'AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_4' => 'Does this person control the outcomes or are they called on to make it happen?',
            'AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_6' => 'Does this person have a track record of success in implementing projects that deliver value?',
            'AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_7' => 'Does this person collect and provide information to people of power and influence?',
            'OM_POLITICAL_STATUS_GUIDED_QUESTION_1' => 'Does this person define the company\u2019s goals and objectives, or do they merely have a good understanding of them?',
            'OM_POLITICAL_STATUS_GUIDED_QUESTION_2' => 'Does this person approve and sponsor initiatives, or do they execute projects after they are approved?',
            'OM_POLITICAL_STATUS_GUIDED_QUESTION_9' => 'Is this person aware of the politics in the organisation?',
            'AM_OM_COVERAGE_GUIDED_QUESTION_1' => 'Have you or a team member met with this person?',
            'AM_OM_COVERAGE_GUIDED_QUESTION_2' => 'Have you or a team member recently had multiple meaningful conversations with this person?',
            'AM_OM_COVERAGE_GUIDED_QUESTION_3' => 'Do you or a team member regularly and routinely have high quality conversations with this person?'
        };
    }


    /**
     * NINE, NOT FIVE. The whole point. The walk found the path taken; the labels are the
     * tree, and four of the nine establish the negative direction.
     */
    @IsTest
    static void theSupportSetIsNineAndComesFromLabels() {
        Test.startTest();
        Map<String, String> labels = AAO_PeopleOntology.assemble(fixture());
        Test.stopTest();

        Integer support = 0;
        for (String k : labels.keySet()) {
            if (AAO_PeopleOntology.dimension(k) == 'Support') {
                support++;
            }
        }
        System.assertEquals(9, support, 'Nine Support questions, not the five walked.');
        System.assertEquals(
            19,
            labels.size(),
            'Nine Support, seven Political, three Coverage.'
        );
        System.assert(
            labels.get('AM_OM_SUPPORT_GUIDED_QUESTION_14')
                .contains('vocal in their support of your competition'),
            'Including one the walk never reached.'
        );
    }

    /**
     * BYTE-EXACT. A normalised quote is a paraphrase, which is the same law that makes the
     * byte check possible on spans, applied to the proposition instead of the evidence.
     */
    @IsTest
    static void thePropositionTextIsByteExact() {
        Test.startTest();
        Map<String, String> labels = AAO_PeopleOntology.assemble(fixture());
        Test.stopTest();

        System.assert(
            labels.get('OM_POLITICAL_STATUS_GUIDED_QUESTION_9').contains('organisation'),
            'The opportunity map spells it with an s. The account map does not. Neither is ' +
            'corrected.'
        );
        System.assert(
            labels.get('AM_OM_SUPPORT_GUIDED_QUESTION_16').contains('jeopardise'),
            'Not Americanised.'
        );
        System.assert(
            labels.get('AM_OM_SUPPORT_GUIDED_QUESTION_11').contains('-including'),
            'The stray hyphen survives. Tidying it would be an edit to the customer\'s own ' +
            'methodology.'
        );
    }

    /**
     * THE GUARD THAT WOULD HAVE CAUGHT v1.7. A short read of a sparse set looks exactly
     * like a complete read of a dense one, so the shape is asserted and a gap refuses by
     * name rather than shipping a rubric that is quietly four questions short.
     */
    @IsTest
    static void aShortFamilyRefusesAndNamesWhatIsMissing() {
        Map<String, String> partial = fixture();
        // The five the walk found, and the four it did not. Exactly the v1.7 defect.
        partial.remove('AM_OM_SUPPORT_GUIDED_QUESTION_6');
        partial.remove('AM_OM_SUPPORT_GUIDED_QUESTION_7');
        partial.remove('AM_OM_SUPPORT_GUIDED_QUESTION_11');
        partial.remove('AM_OM_SUPPORT_GUIDED_QUESTION_14');

        Test.startTest();
        String err;
        try {
            AAO_PeopleOntology.assemble(partial);
        } catch (AAO_PeopleOntology.OntologyException e) {
            err = e.getMessage();
        }
        Test.stopTest();

        System.assertNotEquals(null, err, 'It must refuse rather than author what it found.');
        System.assert(err.contains('FAMILY SHORT'), err);
        System.assert(
            err.contains('6, 7, 11, 14'),
            'And name exactly which questions are missing. Got: ' + err
        );
    }

    /** And the read itself refuses, because Apex cannot see these labels at all. */
    @IsTest
    static void theApexReadRefusesAndExplainsWhy() {
        Test.startTest();
        String err;
        try {
            AAO_PeopleOntology.read();
        } catch (AAO_PeopleOntology.OntologyException e) {
            err = e.getMessage();
        }
        Test.stopTest();

        System.assert(err != null && err.contains('protected'), 'Got: ' + err);
        System.assert(
            err.contains('Tooling API'),
            'And name where the read must come from instead. Got: ' + err
        );
    }

    /** Coverage is P because its questions are about us; Support and Political are E. */
    @IsTest
    static void coverageRoutesToStateAndTheOthersToEvidence() {
        Test.startTest();
        System.assertEquals('P', AAO_PeopleOntology.route('Coverage'));
        System.assertEquals('E', AAO_PeopleOntology.route('Support'));
        System.assertEquals('E', AAO_PeopleOntology.route('Political_Status'));
        Test.stopTest();
    }

    /**
     * "Told you" fixes the subject; observational questions must not. `_16` asks whether the
     * SELLER holds evidence, so requiring the subject to have said it would make an
     * observational proposition unanswerable.
     */
    @IsTest
    static void subjectPersonIsSetOnlyWhereTheQuestionSaysToldYou() {
        Test.startTest();
        System.assertEquals(
            'Subject_Person',
            AAO_PeopleOntology.speakerRequirement('AM_OM_SUPPORT_GUIDED_QUESTION_2', 'Support')
        );
        System.assertEquals(
            'Subject_Person',
            AAO_PeopleOntology.speakerRequirement('AM_OM_SUPPORT_GUIDED_QUESTION_6', 'Support')
        );
        System.assertEquals(
            'Any_Participant',
            AAO_PeopleOntology.speakerRequirement('AM_OM_SUPPORT_GUIDED_QUESTION_16', 'Support'),
            'Observational, not reported.'
        );
        Test.stopTest();
    }

    /** Compound questions become elements, and the decomposition is ours and says so. */
    @IsTest
    static void compoundQuestionsCarryElementsMarkedAsOurs() {
        Test.startTest();
        List<AAO_Evidence_Contract__c> built = AAO_PeopleOntology.build(fixture(), true);
        Test.stopTest();

        Map<String, AAO_Evidence_Contract__c> byCode = new Map<String, AAO_Evidence_Contract__c>();
        for (AAO_Evidence_Contract__c ec : built) {
            byCode.put(ec.AAO_Proposition_Code__c, ec);
        }
        System.assertEquals(19, built.size());

        AAO_Evidence_Contract__c five = byCode.get('AM_OM_SUPPORT_GUIDED_QUESTION_5');
        System.assertEquals(3, five.AAO_Element_Count__c, 'A three-way or.');
        System.assertEquals(
            'Inferred_Pending',
            five.AAO_Elements_Basis__c,
            'Altify authored the question; WE split it, so it waits for a human.'
        );
        System.assertEquals('Awaiting_Ratification', five.AAO_Contract_State__c);

        AAO_Evidence_Contract__c one = byCode.get('AM_OM_SUPPORT_GUIDED_QUESTION_1');
        System.assertEquals(1, one.AAO_Element_Count__c, 'Never zero.');
        System.assertEquals(
            'Authored',
            one.AAO_Elements_Basis__c,
            'Undecomposed means Altify authored it whole.'
        );
    }
}
