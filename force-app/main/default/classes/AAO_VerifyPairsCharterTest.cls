/**
 * CALL 3, AND THE OCCASION-VERSUS-SOLUTION CONJUNCT. Ruled by Matthew at the map read,
 * 7 August, after courtesy-as-stance failed twice.
 *
 * **This class did not exist before today either**, which is the second component found
 * carrying zero tests through a structural change - `AAO_ResolverCharter` was the first, on
 * 6 August. The lesson is the same one and it is now standing: a component's suite must grow
 * when the component changes shape, and a suite that cannot see a component is green about
 * nothing.
 *
 * Pure-function tests on the schema and the parse. That is what the conjunct made possible:
 * the verdict used to be one boolean a reader rendered holistically, and there was nothing to
 * assert about it that was not really an assertion about the model.
 */
@IsTest
private class AAO_VerifyPairsCharterTest {
    private static final String REF = 'seq9';

    private static String payload(Boolean carries, String target) {
        Map<String, Object> body = new Map<String, Object>{
            'carries' => carries,
            'reason' => 'The words voice warmth about what comes next.'
        };
        if (target != null) {
            body.put('target', target);
        }
        return JSON.serialize(body);
    }

    // ===================================================================== the structure

    @IsTest
    static void theTargetIsAskedOnSentimentAndOnNothingElse() {
        Map<String, Object> sentiment = AAO_VerifyPairsCharter.schemaOne(AAO_P8Codes.SENTIMENT);
        Map<String, Object> props = (Map<String, Object>) sentiment.get('properties');
        System.assert(props.containsKey('target'), 'Sentiment carries the conjunct.');

        Set<String> required = new Set<String>();
        for (Object o : (List<Object>) sentiment.get('required')) {
            required.add(String.valueOf(o));
        }
        System.assert(
            required.contains('target'),
            'REQUIRED, not optional. An optional half is a half that can go unanswered, and ' +
            'an unanswered target is the reading that failed twice.'
        );

        // A Buyer Role claim has no "what does the feeling point at" to answer, and asking
        // would be a field with no meaning that a reader must still fill.
        Map<String, Object> role = AAO_VerifyPairsCharter.schemaOne('AAO_BR_EVAL');
        System.assertEquals(
            false,
            ((Map<String, Object>) role.get('properties')).containsKey('target'),
            'The conjunct binds sentiment only.'
        );
    }

    // ======================================================================== the verdict

    @IsTest
    static void aStanceTowardUsStands() {
        AAO_VerifyPairsCharter.Verdict v = AAO_VerifyPairsCharter.parseOne(
            payload(true, AAO_VerifyPairsCharter.TARGET_US), REF, AAO_P8Codes.SENTIMENT
        );
        System.assertEquals(true, v.carries, v.reason);
        System.assertEquals(AAO_VerifyPairsCharter.TARGET_US, v.target);
    }

    @IsTest
    static void courtesyCannotBeUpheldAsStance() {
        // THE seq11 / seq9 SHAPE. "Looking forward to it" - the reader may still feel the
        // sentence is warm and answer `carries` true, and it no longer matters, because
        // upholding a stance now requires naming us as its target. The refusal is arithmetic
        // rather than a judgment the reader could be talked out of.
        AAO_VerifyPairsCharter.Verdict v = AAO_VerifyPairsCharter.parseOne(
            payload(true, AAO_VerifyPairsCharter.TARGET_OCCASION), REF, AAO_P8Codes.SENTIMENT
        );
        System.assertEquals(
            false,
            v.carries,
            'Courtesy is not stance, and after two failures it is structurally inexpressible ' +
            'rather than instructed against.'
        );
        System.assert(
            v.reason.contains('occasion-versus-solution conjunct'),
            'The refusal names itself, so a grader can tell it from an ordinary refusal. ' +
            'Got: ' + v.reason
        );
        System.assert(
            v.reason.contains('Reader\'s own reason'),
            'And the reader\'s own words survive underneath it, because what it thought is ' +
            'the evidence for whether the conjunct is calibrated. Got: ' + v.reason
        );
    }

    @IsTest
    static void enthusiasmAboutTheirOwnWorkIsNotStanceEither() {
        // The other half of §P8.3's wrong-scope guard, now carried structurally.
        AAO_VerifyPairsCharter.Verdict v = AAO_VerifyPairsCharter.parseOne(
            payload(true, AAO_VerifyPairsCharter.TARGET_THEIR_OWN), REF, AAO_P8Codes.SENTIMENT
        );
        System.assertEquals(false, v.carries, v.reason);
    }

    @IsTest
    static void aRefusalStaysARefusalWhateverTheTarget() {
        AAO_VerifyPairsCharter.Verdict v = AAO_VerifyPairsCharter.parseOne(
            payload(false, AAO_VerifyPairsCharter.TARGET_US), REF, AAO_P8Codes.SENTIMENT
        );
        System.assertEquals(false, v.carries);
        System.assertEquals(
            'The words voice warmth about what comes next.',
            v.reason,
            'The conjunct only ever subtracts. A false is already false and its reason is ' +
            'the reader\'s, unrewritten.'
        );
    }

    @IsTest
    static void aMissingTargetOnSentimentThrows() {
        try {
            AAO_VerifyPairsCharter.parseOne(payload(true, null), REF, AAO_P8Codes.SENTIMENT);
            System.assert(false, 'Half a proposition is not an answer.');
        } catch (AAO_VerifyPairsCharter.CharterException e) {
            System.assert(
                e.getMessage().contains('half the proposition'),
                'A missing half is our bug per the parse law, never a silent default to ' +
                'the permissive reading. Got: ' + e.getMessage()
            );
        }
    }

    @IsTest
    static void aNonSentimentClaimIsUntouchedByTheConjunct() {
        AAO_VerifyPairsCharter.Verdict v = AAO_VerifyPairsCharter.parseOne(
            payload(true, null), 'buq3', 'AAO_BR_EVAL'
        );
        System.assertEquals(true, v.carries, 'No target, no conjunct, no change.');
        System.assertEquals(null, v.target);
    }

    @IsTest
    static void theBatchShapeIsUnchanged() {
        // The conjunct rides the single-claim shape, which is what call 3 uses when a batch
        // narrows to one. The multi-claim envelope is untouched, so nothing about batching
        // changed and the parse law's ref checks still bind.
        String batch = JSON.serialize(new Map<String, Object>{
            'verdicts' => new List<Object>{
                new Map<String, Object>{ 'ref' => 'a', 'carries' => true, 'reason' => 'x' },
                new Map<String, Object>{ 'ref' => 'b', 'carries' => false, 'reason' => 'y' }
            }
        });
        List<AAO_VerifyPairsCharter.Verdict> out =
            AAO_VerifyPairsCharter.parse(batch, new List<String>{ 'a', 'b' });
        System.assertEquals(2, out.size());
    }
}