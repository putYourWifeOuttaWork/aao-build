/**
 * THE SEED, HELD TO WHAT MATTHEW GRADED · fifteen questions, not sixteen, and T3 gone rather
 * than kept for symmetry.
 *
 * These assert the SHAPE the hundred-twenty-third ruled, not the wording, because the wording is
 * the org's to rewrite the moment a customer touches it and a test pinning a sentence would fail
 * on a lawful edit. What must not move: the count, the absence of T3, that every question can
 * mint, that running the seed twice seeds once, and that a missing by-stage marker is silence
 * rather than stage zero.
 */
@IsTest
private class AAO_ProcessSeedTest {

    @IsTest
    static void theSetIsFIFTEENandT3ISGONE() {
        Test.startTest();
        AAO_ProcessSeed.seedAssessment(new AAO_ProcessSeed.Outcome());
        Test.stopTest();

        List<ALTF__Assessment_Question__c> rows = [
            SELECT ALTF__AltifyId__c FROM ALTF__Assessment_Question__c
            WHERE ALTF__AltifyId__c IN :AAO_ProcessSeed.questionCodes()
        ];
        System.assertEquals(
            15,
            rows.size(),
            'Sixteen was the conventional target; the graded set is FIFTEEN because T3 failed ' +
            'the deal-killer bar and was MOVED rather than kept for symmetry - the inversion ' +
            'law grading its own instrument.'
        );
        Set<String> codes = new Set<String>();
        for (ALTF__Assessment_Question__c r : rows) {
            codes.add(r.ALTF__AltifyId__c);
        }
        System.assert(
            !codes.contains('AAO_BANT_T3'),
            'T3 is not an assessment question. Not knowing the buying steps kills no deal, so ' +
            'its substance lives on the sales process as a qualifier instead.'
        );
        System.assert(codes.contains('AAO_BANT_T4'), 'T4 stands; the gap in the numbering is T3.');
    }

    @IsTest
    static void EVERYQUESTIONCARRIESELEMENTSbecauseAContractWithNoneCANNOTMINT() {
        Test.startTest();
        AAO_ProcessSeed.seedAssessment(new AAO_ProcessSeed.Outcome());
        Test.stopTest();

        for (ALTF__Assessment_Question__c r : [
            SELECT ALTF__AltifyId__c, ALTF__Help__c FROM ALTF__Assessment_Question__c
            WHERE ALTF__AltifyId__c IN :AAO_ProcessSeed.questionCodes()
        ]) {
            System.assert(
                r.ALTF__Help__c != null && r.ALTF__Help__c.contains('Elements:') &&
                    r.ALTF__Help__c.contains('- e1: '),
                r.ALTF__AltifyId__c + ' carries no element block. The eightieth stamp refuses a ' +
                'zero-element contract AT MINT, so a question seeded without elements would be ' +
                'written into the org and then lawfully refused - a seed that quietly does not ' +
                'work. Help is the only field on the vendor question that can hold them.'
            );
        }
    }

    @IsTest
    static void SEEDINGTWICESEEDSONCE() {
        AAO_ProcessSeed.Outcome first = AAO_ProcessSeed.run();

        Test.startTest();
        AAO_ProcessSeed.Outcome second = AAO_ProcessSeed.run();
        Test.stopTest();

        System.assertEquals(15, first.questionsInserted, 'The first run writes the set.');
        System.assertEquals(
            0,
            second.questionsInserted,
            'The second writes nothing. Idempotent BY READ-BEFORE-WRITE - it queries the ' +
            'standing rows for its key set and branches before composing any DML - rather than ' +
            'by catching a duplicate, which is the hundred-sixteenth stamp\'s law and not a ' +
            'convenience.'
        );
        System.assertEquals(15, second.questionsUpdated, 'It re-authors in place instead.');
        System.assertEquals(
            15,
            [SELECT COUNT() FROM ALTF__Assessment_Question__c
             WHERE ALTF__AltifyId__c IN :AAO_ProcessSeed.questionCodes()],
            'And the org holds one set, not two.'
        );
        System.assertEquals(
            1,
            [SELECT COUNT() FROM ALTF__Sales_Process__c
             WHERE ALTF__AltifyId__c = 'AAO_SEED|PROC'],
            'The process is not duplicated either.'
        );
    }

    @IsTest
    static void aMISSINGMARKERISSILENCEandNEVERSTAGEZERO() {
        System.assertEquals(
            null,
            AAO_ProcessSeed.byStageFor('NOT_A_REAL_CODE'),
            'A question with no marker never reds on ABSENCE - only on a voiced no. Reading a ' +
            'missing marker as stage zero would red every unanswered question on every deal ' +
            'from stage one, which is the opposite of what absence-is-not-evidence means.'
        );
        System.assertNotEquals(
            null,
            AAO_ProcessSeed.byStageFor('AAO_BANT_B1'),
            'And the seeded markers are readable.'
        );
        System.assert(
            AAO_ProcessSeed.byStageFor('AAO_BANT_T4') >
                AAO_ProcessSeed.byStageFor('AAO_BANT_B1'),
            'The decision-maker-confirmed question is owed LATEST; the does-it-exist-at-all ' +
            'questions are owed earliest. Earlier than that, T4 would red on deals that are ' +
            'simply not there yet.'
        );
    }

    @IsTest
    static void THECLOSEPLANNINGQUALIFIERISONEROWONTWOLATESTAGES() {
        Test.startTest();
        AAO_ProcessSeed.seedSalesProcess(new AAO_ProcessSeed.Outcome());
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM ALTF__Sales_Process_Qualifier__c
             WHERE ALTF__AltifyId__c = 'AAO_SEED|Q|CLOSEPLAN'],
            'T3\'s substance is ONE global qualifier...'
        );
        List<ALTF__Sales_Process_Stage_Qualifier__c> js = [
            SELECT ALTF__Sales_Process_Stage__r.ALTF__SortOrder__c
            FROM ALTF__Sales_Process_Stage_Qualifier__c
            WHERE ALTF__Sales_Process_Qualifier__r.ALTF__AltifyId__c = 'AAO_SEED|Q|CLOSEPLAN'
        ];
        System.assertEquals(
            2,
            js.size(),
            '...linked to TWO stages, which is what "the late stages" means and what the ' +
            'junction is for. Two copies of the qualifier would be the duplicate-identity ' +
            'defect on a new object.'
        );
        for (ALTF__Sales_Process_Stage_Qualifier__c j : js) {
            System.assert(
                j.ALTF__Sales_Process_Stage__r.ALTF__SortOrder__c >= 4,
                'And both are LATE stages: mutual close planning on a first call is a question ' +
                'nobody can answer yet.'
            );
        }
    }

    @IsTest
    static void EVERYSTAGEEXERCISESBOTHPLANES() {
        Test.startTest();
        AAO_ProcessSeed.seedSalesProcess(new AAO_ProcessSeed.Outcome());
        Test.stopTest();

        Map<Decimal, Integer> computedByStage = new Map<Decimal, Integer>();
        Map<Decimal, Integer> evidenceByStage = new Map<Decimal, Integer>();
        for (ALTF__Sales_Process_Stage_Qualifier__c j : [
            SELECT ALTF__Sales_Process_Stage__r.ALTF__SortOrder__c,
                ALTF__Sales_Process_Qualifier__r.ALTF__UI_Readonly__c
            FROM ALTF__Sales_Process_Stage_Qualifier__c
            WHERE ALTF__Sales_Process_Stage__r.ALTF__AltifyId__c IN :AAO_ProcessSeed.seedKeys('PS')
        ]) {
            Decimal st = j.ALTF__Sales_Process_Stage__r.ALTF__SortOrder__c;
            Boolean computed = j.ALTF__Sales_Process_Qualifier__r.ALTF__UI_Readonly__c;
            Map<Decimal, Integer> bucket = computed ? computedByStage : evidenceByStage;
            bucket.put(st, (bucket.containsKey(st) ? bucket.get(st) : 0) + 1);
        }
        for (Decimal st : new List<Decimal>{ 1, 2, 3, 4, 5 }) {
            System.assert(
                computedByStage.get(st) != null && computedByStage.get(st) > 0,
                'Stage ' + st + ' carries no COMPUTED-plane qualifier, so the computed-state ' +
                'catalog would go unexercised there on the first run.'
            );
            System.assert(
                evidenceByStage.get(st) != null && evidenceByStage.get(st) > 0,
                'Stage ' + st + ' carries no EVIDENCE-plane qualifier. A seed that exercised ' +
                'one plane only would prove half the design and read as proving all of it.'
            );
        }
    }

    @IsTest
    static void THESEEDNEVERMAKESITSELFTHEORGSDEFAULTPROCESS() {
        Test.startTest();
        AAO_ProcessSeed.seedSalesProcess(new AAO_ProcessSeed.Outcome());
        Test.stopTest();

        ALTF__Sales_Process__c p = [
            SELECT ALTF__Default_Process__c, ALTF__IsActive__c, ALTF__Version__c
            FROM ALTF__Sales_Process__c WHERE ALTF__AltifyId__c = 'AAO_SEED|PROC'
        ];
        System.assertEquals(
            false,
            p.ALTF__Default_Process__c,
            'A seed that made itself the default would change how every deal in the org ' +
            'behaves, which is not what a seed is for.'
        );
        System.assertEquals(true, p.ALTF__IsActive__c, 'But it is usable, or it proves nothing.');
    }

    @IsTest
    static void THEPLANTYPECODESTRINGFITSTHE255CEILING() {
        Test.startTest();
        AAO_ProcessSeed.Outcome o = AAO_ProcessSeed.seedAssessment(new AAO_ProcessSeed.Outcome());
        Test.stopTest();

        ALTF__Opportunity_Plan_Type_List__c pt = [
            SELECT ALTF__AssessmentQuestionIds__c FROM ALTF__Opportunity_Plan_Type_List__c
            WHERE Name = :AAO_ProcessSeed.PLAN_TYPE
        ];
        System.assert(
            pt.ALTF__AssessmentQuestionIds__c.length() <= 255,
            'The plan type carries its question list as a 255-character comma-delimited string ' +
            'of ALTIFY CODES, not ids. That is a real ceiling on rubric size in any org and it ' +
            'is why the codes are short. Got ' + pt.ALTF__AssessmentQuestionIds__c.length()
        );
        System.assertEquals(
            15,
            pt.ALTF__AssessmentQuestionIds__c.split(',').size(),
            'And all fifteen are on it, or the plan type shows a partial rubric.'
        );
    }
}
