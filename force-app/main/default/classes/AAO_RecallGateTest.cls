/**
 * The gate is an instrument, so these tests are about whether it tells the truth: that a
 * boundary disagreement is not reported as a miss, that a miss says WHICH kind of miss it
 * is, and that an owed target cannot be quietly dropped to produce a pass.
 */
@isTest
private class AAO_RecallGateTest {
    /**
     * The two answerable targets, verbatim, in a stand-in artifact.
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
        'eliminate clicks and just like, wouldn\'t it be great for a seller';

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
    static void anOwedTargetMakesAPassImpossible() {
        // A gate that passes while a target is owed is a gate over a smaller test, which is
        // the exact shape of the mistake this build exists to refuse.
        AAO_RecallGate.Coverage c = AAO_RecallGate.score(
            new List<AAO_Pair__c>{
                pair('AAO_POL_OPS1', 'That needs to go to Scott and Matt and Brian.'),
                pair('AAO_DC_N', 'what I\'m trying to do is just eliminate clicks')
            },
            ARTIFACT
        );
        System.assertEquals(
            c.targetsAnswerable,
            c.targetsCovered,
            'Every answerable target is covered in this fixture.'
        );
        System.assert(c.targetsOwed > 0, 'And three targets are still owed.');
        System.assertEquals(
            false,
            c.passed(),
            'So the gate does not pass. There is no argument that gets around this.'
        );
    }

    @isTest
    static void theOwedTargetsCarryTheQuestionTheyNeedAnswered() {
        // An owed target whose note does not say what is needed is a TODO, not an entry in
        // an instrument.
        Integer owed = 0;
        for (AAO_RecallGate.Target t : AAO_RecallGate.targets()) {
            if (!t.isOwed()) {
                continue;
            }
            owed++;
            System.assert(
                t.why.contains('Needed:'),
                t.key + ' is owed but does not say what would resolve it.'
            );
        }
        System.assertEquals(3, owed, 'unit: targets');
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
