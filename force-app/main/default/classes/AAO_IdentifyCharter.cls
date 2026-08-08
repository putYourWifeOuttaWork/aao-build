/**
 * CALL 2 of the §P8 pass: IDENTIFY. Charters v2.9 §P8.2.
 *
 * For each pair call 1 emitted: whose words are these. Input is the pairs, the closed
 * candidate list, and a window of turns around each pair for context. **It never reads the
 * whole artifact and it never re-judges the pair's meaning.**
 *
 * THE PROHIBITION IS A MISSING FIELD AGAIN. There is no `question_code`, no `answer_text`,
 * no `meaning` and no `coverage` in this schema, so call 2 cannot emit a pair, cannot change
 * one, and cannot decide a pair it dislikes is wrong. §P8.2 is explicit: **a pair it believes
 * is wrong is still identified, and call 3 exists to kill it.**
 *
 * EXACTLY ONE DISPOSITION PER HANDED PAIR, IN ORDER. That is the envelope law, and under §P8
 * it is enforced twice: the pair key's unique index refuses a second disposition, and
 * `AAO_PairLedger.assertOneForOne` catches a missing one. Neither mechanism sees what the
 * other sees.
 *
 * NONE AND AMBIGUOUS ARE NOT ABSTENTIONS. They record what happened to a pair that exists.
 * AMBIGUOUS specifically means two candidates and the context cannot separate them, which
 * routes to the Identification flag; NONE means the words belong to nobody on the closed
 * list. A model that says NONE because it is unsure is doing the wrong thing, and the prompt
 * says so.
 */
public with sharing class AAO_IdentifyCharter {
    public class CharterException extends Exception {
    }

    public static final String VERSION = 'identify-1.0.0';
    public static final String NONE = 'NONE';
    public static final String AMBIGUOUS = 'AMBIGUOUS';

    /** Turns of context on each side of a pair's own turn. */
    public static final Integer WINDOW_TURNS = 2;

    public class Disposition {
        public String pairRef;
        public String person;
        public String basis;
    }

    /** One candidate, as call 2 sees it: a handle, a name, and which side they are on. */
    public class Candidate {
        public String handle;
        public String display;
        public String side;
        public Id participantId;
    }

    // ======================================================================= the schema

    public static Map<String, Object> schema(List<String> pairRefs, List<String> handles) {
        List<String> people = new List<String>(handles);
        people.sort();
        people.add(NONE);
        people.add(AMBIGUOUS);

        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'dispositions' => new Map<String, Object>{
                    'type' => 'array',
                    // NOTE, Project Farma run: minItems/maxItems would force the count
                    // structurally, but Anthropic structured outputs reject an array minItems
                    // other than 0 or 1 (400). So completeness is enforced by the caller
                    // instead: call 2 is driven in small batches and the one-for-one guard
                    // throws on any short return, which is what the batching in AAO_Pass is for.
                    'description' => 'EXACTLY ONE ENTRY PER PAIR YOU WERE HANDED, in the ' +
                        'order handed, never omitting one. There are ' + pairRefs.size() +
                        ' pairs and there must be ' + pairRefs.size() + ' entries.',
                    'items' => new Map<String, Object>{
                        'type' => 'object',
                        'properties' => new Map<String, Object>{
                            'pair_ref' => new Map<String, Object>{
                                'type' => 'string',
                                'enum' => pairRefs
                            },
                            'person' => new Map<String, Object>{
                                'type' => 'string',
                                'enum' => people,
                                'description' => 'Who these words belong to, from the list. ' +
                                    NONE + ' where they belong to nobody on it. ' +
                                    AMBIGUOUS + ' where two candidates fit and the context ' +
                                    'cannot separate them. Never invent a name.'
                            },
                            'basis' => new Map<String, Object>{
                                'type' => 'string',
                                'description' => 'One short sentence: spoken by them, said ' +
                                    'about them by name, or answered when addressed.'
                            }
                        },
                        'required' => new List<String>{ 'pair_ref', 'person', 'basis' },
                        'additionalProperties' => false
                    }
                }
            },
            'required' => new List<String>{ 'dispositions' },
            'additionalProperties' => false
        };
    }

    // ================================================================ the system prompt

    public static String systemPrompt() {
        return String.join(
            new List<String>{
                'You are given short quotes taken from one sales-call transcript, each with ' +
                'the turns immediately around it. For each quote you say WHO it belongs to, ' +
                'and nothing else.',
                '',
                'A first reader found these quotes and decided what they mean. A third reader ' +
                'will check whether the words really carry that meaning. Your only job is the ' +
                'person in the middle.',
                '',
                'RULES.',
                '',
                'ONE ANSWER PER QUOTE, FOR EVERY QUOTE, IN THE ORDER GIVEN. Never skip one ' +
                'and never merge two. If you cannot decide, that is still an answer: say ' +
                'AMBIGUOUS.',
                '',
                'THE LIST IS CLOSED. Answer with a handle from the list, or NONE, or ' +
                'AMBIGUOUS. Never a name that is not on it, and never a name you infer from ' +
                'the words.',
                '',
                'NONE AND AMBIGUOUS MEAN DIFFERENT THINGS AND ARE NOT INTERCHANGEABLE. NONE ' +
                'is: these words belong to somebody who is not on the list at all. AMBIGUOUS ' +
                'is: two or more people on the list fit and the context in front of you ' +
                'cannot separate them. Uncertainty between listed people is AMBIGUOUS, never ' +
                'NONE.',
                '',
                'WHOSE WORDS, NOT WHO IS MENTIONED. The speaker of a quote owns it. Where the ' +
                'quote is plainly ABOUT a different person by name and the first reader\'s ' +
                'question is about that person, say so in your basis and answer with the ' +
                'person it is about. Where you are unsure which of the two the question ' +
                'wants, answer with the speaker.',
                '',
                'YOU DO NOT JUDGE THE QUOTE. Not whether it answers anything, not whether the ' +
                'first reader read it correctly, not whether it is good evidence. A quote you ' +
                'think is wrong still gets a person. There is a reader after you whose entire ' +
                'job is to kill bad ones, and taking that job from it makes the machine worse.',
                '',
                'YOU DO NOT SEE THE WHOLE TRANSCRIPT AND MUST NOT ACT AS IF YOU DO. Use the ' +
                'context you are given. If it is not enough, say AMBIGUOUS rather than ' +
                'reasoning from what a call like this usually contains.'
            },
            '\n'
        );
    }

    // ================================================================ the user content

    public static String candidateBlock(List<Candidate> candidates) {
        List<String> out = new List<String>();
        out.add('# The people');
        out.add('');
        out.add('Answer with the handle on the left.');
        out.add('');
        for (Candidate c : candidates) {
            out.add('  ' + c.handle + ': ' + c.display + ' (' + c.side + ')');
        }
        out.add('  ' + NONE + ': the words belong to nobody above.');
        out.add('  ' + AMBIGUOUS + ': two or more of the above fit and the context cannot separate them.');
        return String.join(out, '\n');
    }

    // ========================================================================= parsing

    /**
     * One for one, checked here rather than trusted. A missing disposition is our bug and a
     * ref we never handed is our bug; both throw, per the parse law.
     */
    public static List<Disposition> parse(String jsonText, List<String> handedRefs) {
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new CharterException(
                'Call 2 returned something that is not JSON. First 300 characters: ' +
                (jsonText == null ? '(null)' : jsonText.abbreviate(300))
            );
        }
        if (!(root.get('dispositions') instanceof List<Object>)) {
            throw new CharterException(
                'Call 2 returned JSON with no dispositions array. Keys present: ' +
                String.join(new List<String>(root.keySet()), ', ')
            );
        }

        Set<String> handed = new Set<String>(handedRefs);
        Set<String> seen = new Set<String>();
        List<Disposition> out = new List<Disposition>();
        for (Object o : (List<Object>) root.get('dispositions')) {
            Map<String, Object> m = (Map<String, Object>) o;
            Disposition d = new Disposition();
            d.pairRef = (String) m.get('pair_ref');
            d.person = (String) m.get('person');
            d.basis = (String) m.get('basis');
            if (!handed.contains(d.pairRef)) {
                throw new CharterException(
                    'Call 2 disposed a pair ref we never handed it: ' + d.pairRef +
                    '. This is our bug, never a model behaviour, per the parse law.'
                );
            }
            if (seen.contains(d.pairRef)) {
                throw new CharterException(
                    'Call 2 disposed ' + d.pairRef + ' twice. One for one, for one.'
                );
            }
            seen.add(d.pairRef);
            out.add(d);
        }
        if (seen.size() != handed.size()) {
            Set<String> missing = new Set<String>(handed);
            missing.removeAll(seen);
            throw new CharterException(
                'Call 2 was handed ' + handed.size() + ' pairs and disposed ' + seen.size() +
                ' (unit: pairs). Never returned: ' +
                String.join(new List<String>(missing), ', ') +
                '. The unique index cannot see an omission, which is why this check exists.'
            );
        }
        return out;
    }
}
