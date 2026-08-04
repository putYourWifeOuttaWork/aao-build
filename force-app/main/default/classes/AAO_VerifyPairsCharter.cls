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
    }

    public static Map<String, Object> schema(List<String> pairRefs) {
        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'verdicts' => new Map<String, Object>{
                    'type' => 'array',
                    'description' => 'One entry per claim, in the order given, never ' +
                        'omitting one. There are ' + pairRefs.size() + ' claims.',
                    'items' => new Map<String, Object>{
                        'type' => 'object',
                        'properties' => new Map<String, Object>{
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
                        },
                        'required' => new List<String>{ 'ref', 'carries', 'reason' },
                        'additionalProperties' => false
                    }
                }
            },
            'required' => new List<String>{ 'verdicts' },
            'additionalProperties' => false
        };
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
    public static Map<String, Object> schemaOne() {
        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
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
            },
            'required' => new List<String>{ 'carries', 'reason' },
            'additionalProperties' => false
        };
    }

    public static Verdict parseOne(String jsonText, String pairRef) {
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
        return v;
    }

    public static List<Verdict> parse(String jsonText, List<String> handedRefs) {
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
