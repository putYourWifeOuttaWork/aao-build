/**
 * CALL 3 of the §P8 pass: VERIFY. Charters v2.9 §P8.3. The blind reader, on the pair shape.
 *
 * Sees one claim and its quote and says whether the words carry it. **It does not see the
 * person, the transcript, the other claims, or what any earlier reader concluded.**
 * Blindness is structural and visible in the schema's absences, exactly as
 * `AAO_Blind_Reader` 1.0.0 made it visible: there is no person field, no transcript
 * reference, no confidence, and no way to say "probably".
 *
 * THE PERSON IS WITHHELD DELIBERATELY, and it is worth saying why rather than assuming it.
 * The reader's question is whether these words carry this meaning. Knowing whose words they
 * are can only help it agree — a senior title makes a claim about authority read as more
 * plausible without one more word of evidence — and that is the speaker-rank reasoning the
 * gates do after verification, on purpose.
 *
 * THE SCOPE CHECK IS THE WHOLE POINT FOR SENTIMENT. Both graded over-reads on 24 June were
 * right-sounding words about the wrong thing, so the sentiment instruction asks the reader
 * one extra question: does this feeling point at US and OUR SOLUTION, or at something else
 * the speaker also cares about.
 */
public with sharing class AAO_VerifyPairsCharter {
    public class CharterException extends Exception {
    }

    public static final String VERSION = 'verify-pairs-1.0.0';

    public class Verdict {
        public String pairRef;
        public Boolean carries;
        public String reason;
        /** What the feeling points at. Sentiment only; null everywhere else. */
        public String target;
    }

    public static Map<String, Object> schema(List<String> pairRefs) {
        return schema(pairRefs, null);
    }

    /**
     * The batch shape, and it carries the conjunct too.
     *
     * **Found the same day the conjunct was built, by running it: the conjunct rode only the
     * single-claim path.** Call 3 batches by default and narrows to one claim only at the tail,
     * so in ordinary operation every sentiment claim would have gone through this schema and
     * skipped the target question entirely. A structural guard reachable only on a code path
     * that rarely executes is a guard that is not there.
     *
     * The batch is homogeneous by contract because `AAO_Pass` groups by family before
     * batching, so one code governs the whole schema and the field stays absent everywhere it
     * would be meaningless.
     */
    public static Map<String, Object> schema(List<String> pairRefs, String contractCode) {
        Map<String, Object> item = new Map<String, Object>{
            'ref' => new Map<String, Object>{
                'type' => 'string',
                'enum' => pairRefs
            },
            'carries' => new Map<String, Object>{
                'type' => 'boolean',
                'description' => 'true only if the quoted words assert the ' +
                    'claim. false if they merely mention it, discuss it, ' +
                    'imply it, or say something adjacent to it.'
            },
            'reason' => new Map<String, Object>{
                'type' => 'string',
                'description' => 'One sentence. On a false, name what is ' +
                    'missing or say what the quote actually asserts instead.'
            }
        };
        List<String> itemRequired = new List<String>{ 'ref', 'carries', 'reason' };
        if (takesTarget(contractCode)) {
            item.put('target', targetProperty());
            itemRequired.add('target');
        }
        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'verdicts' => new Map<String, Object>{
                    'type' => 'array',
                    'description' => 'One entry per claim, in the order given, never ' +
                        'omitting one. There are ' + pairRefs.size() + ' claims.',
                    'items' => new Map<String, Object>{
                        'type' => 'object',
                        'properties' => item,
                        'required' => itemRequired,
                        'additionalProperties' => false
                    }
                }
            },
            'required' => new List<String>{ 'verdicts' },
            'additionalProperties' => false
        };
    }

    /**
     * THE KEYED BATCH SHAPE, twenty-seventh stamp, and it is the structural repair of the
     * under-return defect that forced batch=1 everywhere.
     *
     * The array shape failed three ways (one verdict from fourteen, a duplicated ref from
     * four, a repeated ref from one) and the platform rejects `minItems`, so an array's
     * completeness was only ever prose. Here the verdicts come back as an OBJECT whose
     * REQUIRED PROPERTIES are the claim refs themselves: a response missing one fails
     * schema validation at the API rather than parsing short, and a response inventing one
     * fails on `additionalProperties`. Mis-referencing and omission both become
     * unexpressible - `schemaOne`'s own virtue, generalized to any batch size.
     */
    public static Map<String, Object> schemaKeyed(List<String> pairRefs, String contractCode) {
        Map<String, Object> item = new Map<String, Object>{
            'carries' => new Map<String, Object>{
                'type' => 'boolean',
                'description' => 'true only if the quoted words assert the ' +
                    'claim. false if they merely mention it, discuss it, ' +
                    'imply it, or say something adjacent to it.'
            },
            'reason' => new Map<String, Object>{
                'type' => 'string',
                'description' => 'One sentence. On a false, name what is ' +
                    'missing or say what the quote actually asserts instead.'
            }
        };
        List<String> itemRequired = new List<String>{ 'carries', 'reason' };
        if (takesTarget(contractCode)) {
            item.put('target', targetProperty());
            itemRequired.add('target');
        }
        Map<String, Object> perRef = new Map<String, Object>();
        for (String ref : pairRefs) {
            perRef.put(ref, new Map<String, Object>{
                'type' => 'object',
                'properties' => item,
                'required' => itemRequired,
                'additionalProperties' => false
            });
        }
        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'verdicts' => new Map<String, Object>{
                    'type' => 'object',
                    'properties' => perRef,
                    'required' => new List<String>(pairRefs),
                    'additionalProperties' => false
                }
            },
            'required' => new List<String>{ 'verdicts' },
            'additionalProperties' => false
        };
    }

    /** The keyed batch's parser. Every handed ref present or it throws; nothing extra. */
    public static List<Verdict> parseKeyed(
        String jsonText, List<String> handedRefs, String contractCode
    ) {
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new CharterException(
                'Call 3 returned something that is not JSON. First 300 characters: ' +
                (jsonText == null ? '(null)' : jsonText.abbreviate(300))
            );
        }
        if (!(root.get('verdicts') instanceof Map<String, Object>)) {
            throw new CharterException(
                'Call 3 returned no verdicts object. Keys present: ' +
                String.join(new List<String>(root.keySet()), ', ')
            );
        }
        Map<String, Object> byRef = (Map<String, Object>) root.get('verdicts');
        List<Verdict> out = new List<Verdict>();
        for (String ref : handedRefs) {
            if (!(byRef.get(ref) instanceof Map<String, Object>)) {
                throw new CharterException(
                    'Call 3 omitted ' + ref + ', which the schema\'s required list should ' +
                    'have made impossible. Our bug, per the parse law.'
                );
            }
            Map<String, Object> m = (Map<String, Object>) byRef.get(ref);
            Verdict v = new Verdict();
            v.pairRef = ref;
            v.carries = (Boolean) m.get('carries');
            v.reason = (String) m.get('reason');
            v.target = (String) m.get('target');
            applyConjunct(v, contractCode);
            out.add(v);
        }
        return out;
    }

    public static String systemPrompt() {
        return String.join(
            new List<String>{
                'You are given claims. Each is a question, a reading of what some words mean, ' +
                'and the words themselves. For each one you say whether those exact words ' +
                'carry that reading.',
                '',
                'You see nothing else. Not who said it, not what came before or after, not ' +
                'what anyone else concluded. That is deliberate: your value is that you ' +
                'cannot be persuaded by anything except the words in front of you.',
                '',
                'RULES.',
                '',
                'COEXTENSION IS THE TEST. The words must carry the claim\'s SUBJECT, its ' +
                'SCOPE and its QUANTITY. Words about a related thing, a smaller thing, or one ' +
                'instance of a pattern do not carry a claim about the thing itself.',
                '',
                'MENTIONING IS NOT ASSERTING. A quote that raises a topic, asks about it, ' +
                'plans to address it, or describes somebody else doing it does not assert it.',
                '',
                'FOR A CLAIM ABOUT HOW SOMEONE STANDS TOWARD US, CHECK WHAT THE FEELING ' +
                'POINTS AT. Enthusiasm about their own project, their own plan, or the ' +
                'general idea is not a stance toward us and our solution. This is the failure ' +
                'that gets past readers most often: right-sounding words about the wrong ' +
                'thing.',
                '',
                'SAY FALSE WHEN IT IS FALSE. You are the last check before this is written ' +
                'down as true. There is no partial credit, no confidence score, and no ' +
                '"probably" — either the words carry it or they do not.',
                '',
                'ANSWER EVERY CLAIM, IN ORDER, NEVER SKIPPING ONE.'
            },
            '\n'
        );
    }


    // ================================================ the occasion-versus-solution conjunct
    //
    // **RULED by Matthew at the map read, 7 August, after courtesy-as-stance failed twice.**
    // seq11 (24 June) and seq9 (a21) are the same shape: "Looking forward to it" upheld as
    // SUPPORTER. The blind reader read positive anticipation toward the MEETING as a stance
    // toward US.
    //
    // **The prompt already told it not to.** "FOR A CLAIM ABOUT HOW SOMEONE STANDS TOWARD US,
    // CHECK WHAT THE FEELING POINTS AT" has been in the system prompt the whole time, and both
    // failures happened under it. So a third wording fix is not the answer: per the
    // failed-twice law the STRUCTURE changes so the wrong answer cannot be expressed.
    //
    // **The target becomes its own required question, and the verdict becomes arithmetic.**
    // The reader no longer renders one holistic judgment in which a warm sentence can carry
    // the day; it answers what the words voice and, separately, WHAT THE FEELING POINTS AT.
    // Apex conjoins them. A courtesy read now has to name the occasion as its target, and
    // naming it is what refuses it - the same move as the scope split, where DUAL became
    // arithmetic over two one-way answers rather than a third option competing with two.

    public static final String TARGET_US = 'US_OR_OUR_SOLUTION';
    public static final String TARGET_OCCASION = 'THE_MEETING_OR_OCCASION';
    public static final String TARGET_THEIR_OWN = 'THEIR_OWN_WORK_OR_PLAN';
    public static final String TARGET_OTHER = 'SOMETHING_ELSE';

    /** Only a stance pointed at us or our solution establishes on this dimension. */
    public static Boolean targetEstablishes(String target) {
        return target == TARGET_US;
    }

    /**
     * The conjunct binds SENTIMENT and nothing else. "What does the feeling point at" is not a
     * question about a Buyer Role or a decision criterion, and asking it there would be a
     * field with no meaning that a reader must still fill - which is the defaulted-coverage
     * shape this build has already been bitten by twice.
     */
    public static Boolean takesTarget(String contractCode) {
        return contractCode == AAO_P8Codes.SENTIMENT;
    }

    /**
     * THE SINGLE-CLAIM SHAPE, and it exists because the reference field was an invitation to
     * error with no information in it.
     *
     * Handed one claim with a one-value `ref` enum, the reader returned that ref twice. Handed
     * four, it returned one of them twice. Handed fourteen, it returned one verdict. Three
     * different malformations of the same envelope, all caught by the parse law and none of
     * them repairable by wording.
     *
     * **When exactly one claim is in front of the reader there is nothing to key**, so the
     * response is a verdict and a reason. Mis-referencing becomes unexpressible, which is the
     * same move as call 1 having no person field: the failure is removed rather than
     * instructed against.
     */
    /** One definition, so the two shapes cannot drift apart in what they ask. */
    private static Map<String, Object> targetProperty() {
        return new Map<String, Object>{
            'type' => 'string',
            'enum' => new List<String>{
                TARGET_US, TARGET_OCCASION, TARGET_THEIR_OWN, TARGET_OTHER
            },
            'description' => 'WHAT THE FEELING POINTS AT, answered on its own and not ' +
                'as part of the verdict above. ' + TARGET_US + ' only where the warmth ' +
                'is toward us, our company, or what we are selling. ' + TARGET_OCCASION +
                ' where it is toward the meeting, the conversation, the next call, or ' +
                'working together as an event - "looking forward to it", "good to meet ' +
                'you", "thanks for your time". ' + TARGET_THEIR_OWN + ' where it is ' +
                'about their own project, plan or progress. ' + TARGET_OTHER +
                ' for anything else. Answer this even when you answered carries false.'
        };
    }

    public static Map<String, Object> schemaOne() {
        return schemaOne(null);
    }

    public static Map<String, Object> schemaOne(String contractCode) {
        Map<String, Object> props = new Map<String, Object>{
            'carries' => new Map<String, Object>{
                'type' => 'boolean',
                'description' => 'true only if the quoted words assert the claim. false ' +
                    'if they merely mention it, discuss it, imply it, or say something ' +
                    'adjacent to it.'
            },
            'reason' => new Map<String, Object>{
                'type' => 'string',
                'description' => 'One sentence. On a false, name what is missing or say ' +
                    'what the quote actually asserts instead.'
            }
        };
        List<String> required = new List<String>{ 'carries', 'reason' };
        if (takesTarget(contractCode)) {
            props.put('target', targetProperty());
            required.add('target');
        }
        return new Map<String, Object>{
            'type' => 'object',
            'properties' => props,
            'required' => required,
            'additionalProperties' => false
        };
    }

    public static Verdict parseOne(String jsonText, String pairRef) {
        return parseOne(jsonText, pairRef, null);
    }

    public static Verdict parseOne(String jsonText, String pairRef, String contractCode) {
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new CharterException(
                'Call 3 returned something that is not JSON for ' + pairRef +
                '. First 300 characters: ' +
                (jsonText == null ? '(null)' : jsonText.abbreviate(300))
            );
        }
        if (!(root.get('carries') instanceof Boolean)) {
            throw new CharterException(
                'Call 3 returned no boolean verdict for ' + pairRef + '. Keys present: ' +
                String.join(new List<String>(root.keySet()), ', ')
            );
        }
        Verdict v = new Verdict();
        v.pairRef = pairRef;
        v.carries = (Boolean) root.get('carries');
        v.reason = (String) root.get('reason');
        v.target = (String) root.get('target');
        applyConjunct(v, contractCode);
        return v;
    }

    /**
     * THE CONJUNCTION, IN APEX, and it runs on both shapes. A courtesy read cannot arrive as
     * an upheld stance, because upholding one requires naming us as its target.
     */
    private static void applyConjunct(Verdict v, String contractCode) {
        if (!takesTarget(contractCode)) {
            v.target = null;
            return;
        }
        if (String.isBlank(v.target)) {
            throw new CharterException(
                'Call 3 answered the stance for ' + v.pairRef + ' and did not answer what ' +
                'the feeling points at. The target is half the proposition, not a ' +
                'qualifier on it, and a missing half is our bug per the parse law.'
            );
        }
        if (v.carries == true && !targetEstablishes(v.target)) {
            v.carries = false;
            v.reason =
                'Refused by the occasion-versus-solution conjunct: the words were read ' +
                'as voicing the stance, but the feeling points at ' + v.target +
                ' rather than at us or our solution. Courtesy is not stance. Reader\'s ' +
                'own reason: ' + v.reason;
        }
    }

    public static List<Verdict> parse(String jsonText, List<String> handedRefs) {
        return parse(jsonText, handedRefs, null);
    }

    public static List<Verdict> parse(
        String jsonText, List<String> handedRefs, String contractCode
    ) {
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new CharterException(
                'Call 3 returned something that is not JSON. First 300 characters: ' +
                (jsonText == null ? '(null)' : jsonText.abbreviate(300))
            );
        }
        if (!(root.get('verdicts') instanceof List<Object>)) {
            throw new CharterException(
                'Call 3 returned JSON with no verdicts array. Keys present: ' +
                String.join(new List<String>(root.keySet()), ', ')
            );
        }
        Set<String> handed = new Set<String>(handedRefs);
        Set<String> seen = new Set<String>();
        List<Verdict> out = new List<Verdict>();
        for (Object o : (List<Object>) root.get('verdicts')) {
            Map<String, Object> m = (Map<String, Object>) o;
            Verdict v = new Verdict();
            v.pairRef = (String) m.get('ref');
            v.carries = (Boolean) m.get('carries');
            v.reason = (String) m.get('reason');
            applyConjunct(v, contractCode);
            if (!handed.contains(v.pairRef) || seen.contains(v.pairRef)) {
                throw new CharterException(
                    'Call 3 returned a verdict for ' + v.pairRef +
                    ' which was either never handed or handed once and answered twice. Our ' +
                    'bug, per the parse law.'
                );
            }
            seen.add(v.pairRef);
            out.add(v);
        }
        if (seen.size() != handed.size()) {
            Set<String> missing = new Set<String>(handed);
            missing.removeAll(seen);
            throw new CharterException(
                'Call 3 was handed ' + handed.size() + ' claims and returned ' + seen.size() +
                ' verdicts (unit: claims). Never returned: ' +
                String.join(new List<String>(missing), ', ') + '.'
            );
        }
        return out;
    }
}
