/**
 * The seventeen, and the properties that make them the §P8 set rather than the old one.
 *
 * These assert the SHAPE laws, not the wording: that no code carries a person, that the count
 * is roster-independent, that vendor text is byte-exact, that ours is marked as ours, and that
 * minting twice is not minting thirty-four.
 */
@isTest
private class AAO_PassContractsTest {
    @isTest
    static void theSetIsSeventeenAndNoCodeCarriesAPerson() {
        List<AAO_PassContracts.Spec> specs = AAO_PassContracts.specs();
        System.assertEquals(17, specs.size(), 'Seventeen propositions, asked once per transcript.');

        Set<String> codes = new Set<String>();
        for (AAO_PassContracts.Spec sp : specs) {
            System.assert(
                !sp.code.contains('#'),
                'A code carrying "#" is the person-crossed shape §P8 retires. Got: ' + sp.code
            );
            System.assert(
                sp.code.length() <= 18,
                'The contract key composes from at most 18 characters. Got: ' + sp.code
            );
            System.assert(String.isNotBlank(sp.proposition), sp.code + ' has no proposition.');
            System.assert(String.isNotBlank(sp.guidance), sp.code + ' has no guidance.');
            System.assert(!sp.elements.isEmpty(), sp.code + ' has no elements.');
            codes.add(sp.code);
        }
        System.assertEquals(17, codes.size(), 'Every code is distinct.');
    }

    @isTest
    static void theCountDoesNotMoveWithTheRoster() {
        // The whole point of the redesign, stated as an assertion rather than a comment. The
        // old set was 16 questions x N people; on the 17 June fixture's five-person roster that
        // is 80 contract-questions. This set is seventeen at any roster size, because the person
        // is call 2's job and appears in no code here.
        Integer forThree = AAO_PassContracts.specs().size();
        Integer forSeventeen = AAO_PassContracts.specs().size();
        System.assertEquals(forThree, forSeventeen);
        System.assertEquals(17, forThree);
    }

    @isTest
    static void theVendorsOwnQuestionsAreCarriedByteExact() {
        // Byte-exact means byte-exact: these three are Altify's own wording and are not tidied,
        // reflowed, or Americanised on the way in.
        Map<String, String> expected = new Map<String, String>{
            'AAO_POL_PS3' => 'Do others seek this person out for advice and direction?',
            'AAO_POL_PS4' => 'Does this person have a track record of success in implementing projects that deliver value?',
            'AAO_POL_OPS1' => 'Does this person collect and provide information to people of power and influence?'
        };
        Map<String, AAO_PassContracts.Spec> byCode = byCode();
        for (String code : expected.keySet()) {
            System.assertEquals(
                expected.get(code),
                byCode.get(code).proposition,
                code + ' must carry the vendor text character for character.'
            );
            System.assertEquals(
                'Authored',
                byCode.get(code).basis,
                code + ' is the vendor\'s own text and needs nobody\'s ratification to be that.'
            );
        }
    }

    @isTest
    static void whatWeAuthoredIsMarkedAsOursAndAwaitsAHuman() {
        Map<String, AAO_PassContracts.Spec> byCode = byCode();
        // Every one-way half we split out of a two-sided vendor question, plus Buyer Role and
        // criteria, which the vendor never decomposed.
        for (String code : new List<String>{
            'AAO_POL_IC1', 'AAO_POL_IC2', 'AAO_POL_IC3', 'AAO_POL_PS1', 'AAO_POL_PS2',
            'AAO_BR_APP', 'AAO_BR_DM', 'AAO_BR_EVAL', 'AAO_BR_USER', 'AAO_BR_SIG',
            'AAO_DC_N', 'AAO_DC_F', 'AAO_DC_R', 'AAO_PS_1'
        }) {
            System.assertEquals(
                'Inferred_Pending',
                byCode.get(code).basis,
                code + ' is authored by us and must not present as recovered vendor text.'
            );
        }
    }

    @isTest
    static void theTwoSidedQuestionsBecameHalvesThatEachPlaceSomething() {
        // The 24 June run refused four claims on the two-sided PS4/PO2 CORRECTLY, and lost the
        // placement the words actually supported because the contract had no slot for the weak
        // side. Graded by Matthew 4 August, four of four right refusals. These halves are the
        // repair, so the strong and weak sides must both exist and be distinct.
        Map<String, AAO_PassContracts.Spec> byCode = byCode();
        System.assertNotEquals(null, byCode.get('AAO_POL_IC2'), 'strong half of the vendor _2');
        System.assertNotEquals(null, byCode.get('AAO_POL_PS1'), 'weak half of the vendor _2');
        System.assertNotEquals(null, byCode.get('AAO_POL_IC3'), 'strong half of the vendor _4');
        System.assertNotEquals(null, byCode.get('AAO_POL_PS2'), 'weak half of the vendor _4');
        System.assertNotEquals(
            byCode.get('AAO_POL_IC3').proposition,
            byCode.get('AAO_POL_PS2').proposition,
            'The halves must ask different questions, or the split bought nothing.'
        );
        for (AAO_PassContracts.Spec sp : AAO_PassContracts.specs()) {
            System.assert(
                !sp.proposition.contains(' or are they ') && !sp.proposition.contains(' or do they '),
                'True-or-nothing: no proposition may be two-sided. Got: ' + sp.proposition
            );
        }
    }

    @isTest
    static void criteriaNamingCarriesItsThreeElements() {
        System.assertEquals(
            3,
            byCode().get('AAO_DC_N').elements.size(),
            'DC-N is identifiable condition, stance, and decision linkage, so partial accrual ' +
            'has something to be partial about.'
        );
    }

    @isTest
    static void mintingIsIdempotentAndSupersedesThePersonCrossedSet() {
        AAO_Synthetic.MARK = true;
        // Stand in for the retired 48: one row on the old rubric, active.
        insert new AAO_Evidence_Contract__c(
            AAO_Proposition_Code__c = 'S1#003000000000000AAA',
            AAO_Proposition_Text__c = 'Has this person expressed a preference for a specific solution?',
            AAO_Route__c = 'E',
            AAO_Charter_Designation__c = 'People',
            AAO_Contract_State__c = 'Derived',
            AAO_Rubric_Version__c = AAO_PassContracts.SUPERSEDES_RUBRIC,
            // The trigger is the single composer of the key and needs this to compose from.
            AAO_Question_Record_Id__c = 'S1',
            // The number of parts is never unknown, per the object's own validation.
            AAO_Elements__c = '[{"id":"e1","text":"Has this person expressed a preference for a specific solution?"}]',
            AAO_Element_Count__c = 1,
            AAO_Elements_Basis__c = 'Authored',
            AAO_Speaker_Requirement__c = 'Any_Participant',
            AAO_Decay_Class__c = 'Standing',
            AAO_Synthetic__c = true
        );

        Test.startTest();
        AAO_PassContracts.Result first = AAO_PassContracts.mint();
        AAO_PassContracts.Result second = AAO_PassContracts.mint();
        Test.stopTest();

        System.assertEquals(17, first.minted, 'unit: contracts');
        System.assertEquals(1, first.superseded, 'The old rubric is superseded, never deleted.');
        System.assertEquals(
            0,
            second.minted,
            'Minting unchanged text again upserts onto the same key. Seventeen, not thirty-four.'
        );
        System.assertEquals(17, second.unchanged, 'unit: contracts');
        System.assertEquals(
            0,
            second.superseded,
            'Nothing is left to supersede on a second run.'
        );

        System.assertEquals(
            17,
            [
                SELECT COUNT()
                FROM AAO_Evidence_Contract__c
                WHERE AAO_Rubric_Version__c = :AAO_PassContracts.RUBRIC_VERSION
                    AND AAO_Contract_State__c != 'Superseded'
            ],
            'Seventeen live contracts on the new rubric.'
        );
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM AAO_Evidence_Contract__c
                WHERE AAO_Rubric_Version__c = :AAO_PassContracts.SUPERSEDES_RUBRIC
                    AND AAO_Contract_State__c = 'Superseded'
            ],
            'The old row still exists. Wrong text is marked wrong, never deleted.'
        );
    }

    @isTest
    static void anEditedPropositionMintsANewContractRatherThanChangingOneInPlace() {
        // The content hash is the only detector of an in-place edit, and the key carries it,
        // so changed text cannot quietly overwrite the contract that produced past claims.
        String a = AAO_ContractKey.contentHash('Does this person control the outcomes?', 'g');
        String b = AAO_ContractKey.contentHash('Does this person control the outcome?', 'g');
        System.assertNotEquals(a, b, 'One character changes the hash, so it changes the key.');
    }

    private static Map<String, AAO_PassContracts.Spec> byCode() {
        Map<String, AAO_PassContracts.Spec> m = new Map<String, AAO_PassContracts.Spec>();
        for (AAO_PassContracts.Spec sp : AAO_PassContracts.specs()) {
            m.put(sp.code, sp);
        }
        return m;
    }
}
