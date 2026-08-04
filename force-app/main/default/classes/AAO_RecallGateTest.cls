/**
 * The gate is an instrument, so these tests are about whether it tells the truth: that a
 * boundary disagreement is not reported as a miss, that a miss says WHICH kind of miss it
 * is, and that an owed target cannot be quietly dropped to produce a pass.
 */
@isTest
private class AAO_RecallGateTest {
    /**
     * Every scored target's words, verbatim, in a stand-in artifact: the two that must be
     * found and the two that must not come back as sentiment.
     *
     * They are carried verbatim rather than approximated, because a target quote that is
     * not in the artifact reports NOT FOUND correctly, and a test built on that would be
     * asserting the gate is broken while it works. First draft of this class did exactly
     * that: an invented artifact that did not contain the words the targets name.
     */
    private static final String ARTIFACT =
        'adam\tSo Robin, do you want to take what\'s in the agenda or in the meeting? ' +
        'That needs to go to Scott and Matt and Brian. Like that\'s Matt, that was a very ' +
        'specific ask from Matt last week. So I just want to make sure we keep that moving.\n' +
        'adam\tBut I understand this is a pilot, so what I\'m trying to do is just ' +
        'eliminate clicks and just like, wouldn\'t it be great for a seller\n' +
        'robbin\tYeah, use your components that you guys to Altify design components that ' +
        'you have for like all your other buttons so that it can be consistent.\n' +
        'ashley\tI think we look at as many use cases as we can take on that are going to ' +
        'add value to the organization and we go after them.';

    @isTest
    static void aBoundaryDisagreementIsNotAMiss() {
        // The gate's own first run reported NOT FOUND AT ALL about words the read had
        // plainly found, because neither quote contained the other. Byte-range overlap has
        // no opinion about where a sentence ends.
        AAO_RecallGate.Coverage c = AAO_RecallGate.score(
            new List<AAO_Pair__c>{
                pair('AAO_POL_OPS1', 'So Robin, do you want to take what\'s in the agenda or in the meeting? That needs to go to Scott and Matt and Brian.')
            },
            ARTIFACT
        );
        System.assert(
            c.covered.toString().contains('PS7-broker'),
            'Overlapping ranges are the same words. Got: ' + c
        );
        System.assertEquals(1, c.targetsCovered, 'unit: targets');
    }

    @isTest
    static void aMissSaysWhichKindOfMissItIs() {
        // Not found at all is a recall failure and calls for a coverage repair in call 1.
        // Found under another contract is a routing failure and calls for a wording repair
        // in two contracts competing for one sentence. Opposite fixes, so one number would
        // send the next session the wrong way.
        AAO_RecallGate.Coverage routed = AAO_RecallGate.score(
            new List<AAO_Pair__c>{
                pair('AAO_POL_PS2', 'That needs to go to Scott and Matt and Brian.')
            },
            ARTIFACT
        );
        System.assertEquals(1, routed.routedElsewhere, 'unit: targets');
        System.assert(
            routed.missed.toString().contains('FILED UNDER AAO_POL_PS2'),
            'The report names where the words actually went. Got: ' + routed.missed
        );

        AAO_RecallGate.Coverage silent = AAO_RecallGate.score(
            new List<AAO_Pair__c>(), ARTIFACT
        );
        System.assertEquals(2, silent.notFound, 'unit: targets');
        System.assertEquals(0, silent.routedElsewhere, 'unit: targets');
    }

    @isTest
    static void findingEverythingIsNotEnoughIfAnOverReadComesBack() {
        // Both recall targets covered, and the gate still fails, because one of the graded
        // over-reads came back as sentiment. Recall and restraint are separate conditions
        // and passing one is not passing.
        AAO_RecallGate.Coverage c = AAO_RecallGate.score(
            new List<AAO_Pair__c>{
                pair('AAO_POL_OPS1', 'That needs to go to Scott and Matt and Brian.'),
                pair('AAO_DC_N', 'what I\'m trying to do is just eliminate clicks'),
                pair('AAO_PS_1', 'use your components that you guys to Altify design components')
            },
            ARTIFACT
        );
        System.assertEquals(2, c.targetsAnswerable, 'unit: targets');
        System.assertEquals(2, c.targetsCovered, 'Both recall targets found.');
        System.assertEquals(2, c.exclusionsChecked, 'unit: targets');
        System.assertEquals(1, c.reproduced.size(), 'And one over-read is back.');
        System.assertEquals(false, c.passed(), 'So the gate does not pass.');
    }

    @isTest
    static void theCoverageRatioNeverMixesInTheExclusions() {
        // A ratio counting must-not-reproduce targets in its denominator can never reach
        // one, so it would report a permanent failure that means nothing.
        AAO_RecallGate.Coverage c = AAO_RecallGate.score(
            new List<AAO_Pair__c>{
                pair('AAO_POL_OPS1', 'That needs to go to Scott and Matt and Brian.'),
                pair('AAO_DC_N', 'what I\'m trying to do is just eliminate clicks')
            },
            ARTIFACT
        );
        System.assertEquals(c.targetsAnswerable, c.targetsCovered, '2 of 2, not 2 of 4.');
        System.assertEquals(0, c.reproduced.size());
        System.assertEquals(0, c.targetsOwed, 'Addendum 07 answered every ask.');
        System.assert(c.passed(), 'This is what a pass looks like, and no run has one yet.');
    }

    @isTest
    static void overReadWordsUnderAnotherContractAreReportedAndNotFailed() {
        // The grading judged those words against one proposition and said nothing about any
        // other. "use your components" may honestly be evaluating behaviour; calling that a
        // reproduction would punish a reading nobody graded.
        AAO_RecallGate.Coverage c = AAO_RecallGate.score(
            new List<AAO_Pair__c>{
                pair('AAO_POL_OPS1', 'That needs to go to Scott and Matt and Brian.'),
                pair('AAO_DC_N', 'what I\'m trying to do is just eliminate clicks'),
                pair('AAO_BR_EVAL', 'use your components that you guys to Altify design components')
            },
            ARTIFACT
        );
        System.assertEquals(0, c.reproduced.size(), 'Not a reproduction.');
        System.assertEquals(1, c.overReadWordsElsewhere.size(), 'But it is worth saying.');
        System.assert(
            c.overReadWordsElsewhere[0].contains('AAO_BR_EVAL'),
            'The note names where the words went. Got: ' + c.overReadWordsElsewhere
        );
        System.assert(c.passed(), 'A reported observation does not fail the gate.');
    }

    @isTest
    static void theWithdrawnTargetStaysVisibleAndCarriesItsReason() {
        // The S2/Adam UNDER was recorded with no span, from deal knowledge rather than a
        // graded quote. A gate target must be transcript-grounded, so it is withdrawn — and
        // kept, because deleting it would erase why it was ever expected.
        AAO_RecallGate.Coverage c = AAO_RecallGate.score(new List<AAO_Pair__c>(), ARTIFACT);
        System.assertEquals(1, c.targetsWithdrawn, 'unit: targets');
        System.assert(
            c.withdrawn[0].contains('S2-adam-placement') &&
            c.withdrawn[0].contains('WITHDRAWN'),
            'Got: ' + c.withdrawn
        );
        System.assertEquals(
            0,
            c.targetsOwed,
            'Withdrawn is not owed. Owed means nobody has answered; withdrawn means the ' +
            'answer was that the artifact does not carry it.'
        );
    }

    private static AAO_Pair__c pair(String code, String words) {
        // The contract is a relationship field the gate reads, so the row is built rather
        // than inserted: this test is about the scoring, not about the ledger's laws, which
        // AAO_PairLedgerTest already holds.
        return (AAO_Pair__c) JSON.deserialize(
            JSON.serialize(new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'type' => 'AAO_Pair__c' },
                'AAO_Answer_Text__c' => words,
                'AAO_Evidence_Contract__r' => new Map<String, Object>{
                    'attributes' => new Map<String, Object>{
                        'type' => 'AAO_Evidence_Contract__c'
                    },
                    'AAO_Proposition_Code__c' => code
                }
            }),
            AAO_Pair__c.class
        );
    }
}
