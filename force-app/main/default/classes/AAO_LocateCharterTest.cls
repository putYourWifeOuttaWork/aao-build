/**
 * Call 1's charter: the prohibition law as a missing field, the meanings as a closed set,
 * and §P8.9's four rulings actually present in the text that goes to the model.
 *
 * The §P8.9 assertions are deliberately literal. Those rulings came from a grading where
 * EVERY disagreement was the guarded reader establishing less than the grader, so a later
 * edit that quietly softens one of them is the exact regression this build cannot see from
 * its own output: an under-read leaves no trace anywhere.
 */
@isTest
private class AAO_LocateCharterTest {
    @isTest
    static void thereIsNoPersonFieldAnywhereInTheSchema() {
        // The prohibition law made physical, same move AAO_Pair__c makes at the database.
        String s = JSON.serialize(AAO_LocateCharter.schema(codes()));
        for (String forbidden : new List<String>{
            'person', 'speaker', 'contact', 'who_said', 'subject'
        }) {
            System.assert(
                !s.toLowerCase().contains('"' + forbidden + '"'),
                'Call 1 must have no way to name a person. Found a "' + forbidden +
                '" property in the schema.'
            );
        }
    }

    @isTest
    static void theFourCalibrationRulingsAreInTheProseTheModelReads() {
        String p = AAO_LocateCharter.systemPrompt();
        System.assert(
            p.contains('BEHAVIOUR ON THE CALL ESTABLISHES'),
            '§P8.9 ruling 1: the content of the call, never the title, in BOTH directions.'
        );
        System.assert(
            p.contains('ONE QUOTE, SEVERAL ESTABLISHMENTS'),
            '§P8.9 ruling 2: a sentence answering three questions is three pairs.'
        );
        System.assert(
            p.contains('ADVOCACY IS NEVER DISCOUNTED FOR COMING FROM A PROFESSIONAL'),
            '§P8.9 ruling 3: the guard as written was eating the best sentiment evidence.'
        );
        System.assert(
            p.contains('Decision ' + 'criteria are RARE'),
            '§P8.9 ruling 4: criteria are sparse and the families are not equally heavy.'
        );
        System.assert(
            p.contains('under-reading wearing') && p.contains('discipline'),
            'The reason is carried with the rule, because a rule without its reason is the ' +
            'first thing a later edit softens.'
        );
    }

    @isTest
    static void thisCharterReversesOneStatementOneItemOnPurpose() {
        // AAO_InventoryCharter 1.1.0 says one sentence bearing on three families is ONE
        // item. §P8.9 says it is three pairs. Asserted so the two charters read as
        // disagreeing by ruling rather than by accident.
        System.assert(
            AAO_InventoryCharter.systemPrompt().contains('ONE STATEMENT, ONE ITEM'),
            'The rule being reversed must still exist to be reversed.'
        );
        String s = JSON.serialize(AAO_LocateCharter.schema(codes()));
        System.assert(
            s.contains('One entry per ESTABLISHMENT, not per sentence'),
            'The schema itself has to say it; the prompt alone leaves the shape ambiguous.'
        );
    }

    @isTest
    static void everyDeclaredContractHasAMeaningItCanVoice() {
        // The coupling that would otherwise break silently: mint an eighteenth contract and
        // call 1 would offer it with no legal meaning, so every pair against it is rejected
        // by the parser and the question is answered as silence.
        for (AAO_PassContracts.Spec sp : AAO_PassContracts.specs()) {
            System.assert(
                !AAO_LocateCharter.meaningsFor(sp.code).isEmpty(),
                sp.code + ' is declared but call 1 has no meaning it can voice, so every ' +
                'pair against it would be parsed away and read as silence.'
            );
        }
    }

    @isTest
    static void aMeaningFromTheWrongFamilyIsRejectedAndTheReasonIsKept() {
        AAO_LocateCharter.Result r = AAO_LocateCharter.parse(
            JSON.serialize(new Map<String, Object>{
                'deal' => 'renewal',
                'account' => 'AspenTech',
                'mentions' => new List<Object>(),
                'pairs' => new List<Object>{
                    new Map<String, Object>{
                        'question_code' => 'AAO_BR_EVAL',
                        'answer_text' => 'we compared it against our shortlist',
                        'meaning' => 'MENTOR'
                    }
                }
            }),
            codes()
        );
        System.assertEquals(0, r.pairs.size(), 'A sentiment state is not a Buyer Role.');
        System.assertEquals(1, r.rejected.size(), 'A refused pair is recorded, never dropped.');
        System.assert(
            r.rejected[0].contains('AAO_BR_EVAL can voice'),
            'The reason names the legal set. Got: ' + r.rejected[0]
        );
    }

    @isTest
    static void aQuestionOutsideTheDeclaredSetIsRefusedRatherThanStored() {
        AAO_LocateCharter.Result r = AAO_LocateCharter.parse(
            body(new Map<String, Object>{
                'question_code' => 'AAO_POL_PS9',
                'answer_text' => 'she signs off on all of it',
                'meaning' => 'POLITICAL_STRUCTURE'
            }),
            codes()
        );
        System.assertEquals(0, r.pairs.size());
        System.assert(
            r.rejected[0].contains('outside the declared set'),
            'The declared-set law binds the claim path. Got: ' + r.rejected[0]
        );
    }

    @isTest
    static void doubtAboutCoverageBecomesPartialRatherThanCostingThePair() {
        // Partial is the instructed default under doubt, and a missing value IS doubt. A
        // pair discarded for an omitted enum would be an under-read created by our parser,
        // which is the one failure mode nothing downstream can see. (Moved off AAO_DC_N at
        // 3.1.0: a naming pair now has its own required field with its own refusal.)
        AAO_LocateCharter.Result r = AAO_LocateCharter.parse(
            body(new Map<String, Object>{
                'question_code' => 'AAO_BR_EVAL',
                'answer_text' => 'what I\'m trying to do is just eliminate clicks',
                'meaning' => 'EVALUATOR'
            }),
            codes()
        );
        System.assertEquals(1, r.pairs.size(), 'The pair survives.');
        System.assertEquals('Partial', r.pairs[0].coverage, 'Doubt accrues safely.');
    }

    @isTest
    static void aNamingPairCarriesItsNameAndANamelessOneIsRefused() {
        // A criterion's identity is its name (3.1.0). A naming pair without one cannot mint
        // a distinguishable criterion - the collapsed-row defect by another door - so it is
        // refused with its reason rather than defaulted.
        AAO_LocateCharter.Result named = AAO_LocateCharter.parse(
            body(new Map<String, Object>{
                'question_code' => 'AAO_DC_N',
                'answer_text' => 'the big one for us is what this costs us per year, all in',
                'meaning' => 'CRITERION',
                'coverage' => 'Full',
                'criterion_name' => '  Annual total cost '
            }),
            codes()
        );
        System.assertEquals(1, named.pairs.size(), 'The named pair survives.');
        System.assertEquals(
            'Annual total cost',
            named.pairs[0].criterionName,
            'Trimmed, and carried as its own field beside the verbatim words.'
        );

        AAO_LocateCharter.Result nameless = AAO_LocateCharter.parse(
            body(new Map<String, Object>{
                'question_code' => 'AAO_DC_N',
                'answer_text' => 'the big one for us is what this costs us per year, all in',
                'meaning' => 'CRITERION',
                'coverage' => 'Full',
                'criterion_name' => '   '
            }),
            codes()
        );
        System.assertEquals(0, nameless.pairs.size());
        System.assert(
            nameless.rejected[0].contains('identity is its name'),
            'The refusal carries the law. Got: ' + nameless.rejected[0]
        );
    }

    @isTest
    static void aNonNamingPairsCriterionNameIsDiscardedAsTheSchemaTax() {
        // criterion_name is required schema-wide when AAO_DC_N is declared (the coverage
        // lesson: optional fields get omitted), so non-naming pairs pay an empty-string
        // tax the parser discards.
        AAO_LocateCharter.Result r = AAO_LocateCharter.parse(
            body(new Map<String, Object>{
                'question_code' => 'AAO_BR_EVAL',
                'answer_text' => 'we compared it against our shortlist',
                'meaning' => 'EVALUATOR',
                'coverage' => 'Full',
                'criterion_name' => 'should not survive'
            }),
            codes()
        );
        System.assertEquals(1, r.pairs.size());
        System.assertEquals(
            null,
            r.pairs[0].criterionName,
            'A criterion name on a non-naming pair is a category error, discarded.'
        );
    }

    @isTest
    static void theSchemaRequiresTheCriterionNameOnlyWhereNamingIsDeclared() {
        String withNaming = JSON.serialize(AAO_LocateCharter.schema(codes()));
        System.assert(
            withNaming.contains('criterion_name'),
            'The naming read must carry the name property.'
        );
        String withoutNaming = JSON.serialize(
            AAO_LocateCharter.schema(new List<String>{ 'AAO_PS_1', 'AAO_BR_EVAL' })
        );
        System.assert(
            !withoutNaming.contains('criterion_name'),
            'A read with no naming contract has nothing to name.'
        );
    }

    @isTest
    static void sentimentCarriesNoCoverageEvenIfTheModelOffersOne() {
        AAO_LocateCharter.Result r = AAO_LocateCharter.parse(
            body(new Map<String, Object>{
                'question_code' => 'AAO_PS_1',
                'answer_text' => 'I\'m going to support whatever it\'s going to take',
                'meaning' => 'SUPPORTER',
                'coverage' => 'Full'
            }),
            codes()
        );
        System.assertEquals(1, r.pairs.size(), 'The words are fine; the coverage is not.');
        System.assertEquals(
            null,
            r.pairs[0].coverage,
            'A sentiment read is whole (§P8.4). Accumulation is the counter\'s job.'
        );
        System.assert(
            !AAO_LocateCharter.takesCoverage('AAO_PS_1'),
            'And the charter says so before the model is asked.'
        );
    }

    @isTest
    static void theRubricBlockIsOrderedSoThePromptPrefixCanCache() {
        List<AAO_Evidence_Contract__c> declared = new List<AAO_Evidence_Contract__c>{
            contract('AAO_POL_PS4', 'later', 1),
            contract('AAO_BR_APP', 'earlier', 1),
            contract('AAO_DC_N', 'three parts', 3)
        };
        String block = AAO_LocateCharter.rubricBlock(declared);
        System.assert(
            block.indexOf('## AAO_BR_APP') < block.indexOf('## AAO_DC_N'),
            'A map\'s iteration order is not a promise, and a prefix that reorders itself ' +
            'caches on paper and never reads.'
        );
        System.assert(
            block.contains('names 3 parts'),
            'A multi-element question must say so, or Partial has nothing to be partial about.'
        );
        System.assert(
            block.contains('the read is whole or there is no pair') == false,
            'None of these three is sentiment.'
        );
    }

    @isTest
    static void callOneIsAskedForTheDealButItIsNeverTheResolution() {
        // Collected so a disagreement is a finding. The Source already carries the deal, and
        // asking a model to re-resolve what the record answers is asking a question the data
        // has. Named here so nobody later wires dealSaid into a lookup.
        AAO_LocateCharter.Result r = AAO_LocateCharter.parse(
            body(new Map<String, Object>{
                'question_code' => 'AAO_POL_IC2',
                'answer_text' => 'I approved that budget line',
                'meaning' => 'INNER_CIRCLE'
            }),
            codes()
        );
        System.assertEquals('renewal', r.dealSaid);
        System.assertEquals(
            'AAO_Pair__c',
            'AAO_Pair__c',
            'There is no field on AAO_Pair__c for what call 1 said the deal was, which is ' +
            'the point: it is a measurement, not a resolution.'
        );
    }

    // ------------------------------------------------------------------- fixtures

    private static List<String> codes() {
        List<String> out = new List<String>();
        for (AAO_PassContracts.Spec sp : AAO_PassContracts.specs()) {
            out.add(sp.code);
        }
        return out;
    }

    private static String body(Map<String, Object> pair) {
        return JSON.serialize(new Map<String, Object>{
            'deal' => 'renewal',
            'account' => 'AspenTech',
            'mentions' => new List<Object>(),
            'pairs' => new List<Object>{ pair }
        });
    }

    private static AAO_Evidence_Contract__c contract(String code, String text, Integer parts) {
        return new AAO_Evidence_Contract__c(
            AAO_Proposition_Code__c = code,
            AAO_Proposition_Text__c = text,
            AAO_Element_Count__c = parts
        );
    }

    // ============================================ adding a family is a data act, not a build

    @IsTest
    static void aContractInANewFamilyRoutesOnWhatItDeclares() {
        // FORTY-FIRST STAMP, ITEM (iv). Problems and Politics enter the pass next, and before
        // this the family map was a hardcoded prefix ladder that THREW on any code it did not
        // recognise. `families()` runs it across the whole declared set, so the first contract
        // minted in a new family would not have degraded that family: it would have failed
        // call 1 outright, for every family at once, before a single read happened.
        AAO_Evidence_Contract__c problem = contract(
            'AAO_PRB_1', 'The buyer named a problem this deal has to solve.', 1
        );
        problem.AAO_Family__c = 'Problems';

        System.assertEquals(
            'Problems',
            AAO_LocateCharter.familyOf(problem),
            'The contract declares its own family and the pass carries it. No Apex edit, no ' +
            'new prefix in a ladder, and nothing here says what the question ASKS, which is ' +
            'the charter\'s to declare.'
        );

        Map<String, List<AAO_Evidence_Contract__c>> grouped = AAO_LocateCharter.families(
            new List<AAO_Evidence_Contract__c>{
                contract('AAO_BR_USER', 'Buyer role, user.', 1),
                problem
            }
        );
        System.assertEquals(2, grouped.size(), 'Two families, one of them brand new.');
        System.assert(grouped.containsKey('Problems'), 'Got: ' + grouped.keySet());
        System.assert(grouped.containsKey('Buyer Role'), 'And the old one is untouched.');
    }

    @IsTest
    static void adeclaredFamilyWinsAndABlankOneFallsBackToTheLadder() {
        AAO_Evidence_Contract__c legacy = contract('AAO_BR_USER', 'Buyer role, user.', 1);
        System.assertEquals(
            'Buyer Role',
            AAO_LocateCharter.familyOf(legacy),
            'Blank falls back, so the seventeen contracts seeded before the field existed ' +
            'keep their families with nothing migrated in a hurry.'
        );
    }

    @IsTest
    static void aContractWithNeitherAFamilyNorAKnownPrefixStillThrows() {
        // The loud failure survives both paths: a contract nobody sweeps is worse than a
        // throw. What changed is that the message now names the remedy, which is data.
        try {
            AAO_LocateCharter.familyOf(contract('AAO_ZZZ_9', 'Unknown.', 1));
            System.assert(false, 'A contract no read would carry must not pass silently.');
        } catch (AAO_LocateCharter.CharterException e) {
            System.assert(
                e.getMessage().contains('AAO_Family__c'),
                'The error has to tell the reader the fix is data, not code. Got: ' +
                e.getMessage()
            );
        }
    }
}