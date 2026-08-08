/**
 * THE MODEL LEG'S CHARTER: TYPED RESOLUTION REQUESTS. Twenty-seventh stamp.
 *
 * Fired ONLY where the resolution stage's deterministic legs leave a remainder: designators
 * the roster does not carry and the ladder returns ZERO for. One bounded call. The model
 * never writes query text, never SOQL, never clause fragments - it says WHO needs resolving
 * and WHAT is known, in typed fields, and Apex composes and executes every query from them.
 * Recorded as design's one deliberate correction of Matthew's wording ("it infers which
 * queries are required and what the clauses are"): model-authored query text is an injection
 * surface and an unparseable drift mode, while typed fields are checkable and the parse law
 * binds them. The recipe ruling's own logic at run grain: interpretation by the model,
 * execution by the database.
 *
 * THE SCHEMA IS CHANNEL-AGNOSTIC BY DESIGN. Nothing in a request presumes a transcript: a
 * note's body carries no roster, so on notes and emails nearly every pair takes this leg,
 * naming people who may appear only as titles. Built for transcripts now; notes drop in
 * later without reshaping.
 *
 * COMPLETENESS IS STRUCTURAL, NOT PROSE. The under-return defect (one disposition from a
 * 59-pair batch, and `minItems` rejected by the platform) is designed out here: the
 * requests come back as an OBJECT whose REQUIRED PROPERTIES are the designator handles, so
 * a response missing one fails schema validation instead of parsing short.
 */
public with sharing class AAO_ResolveRequestCharter {
    public class CharterException extends Exception {
    }

    public static final String VERSION = 'resolve-requests-1.0.0';

    public static final String NONE = 'NONE';
    public static final String TITLE_ONLY = 'title-only';
    public static final String NAMED_OFF_ARTIFACT = 'named-off-artifact';
    public static final String ON_ARTIFACT_NO_CONTACT = 'on-artifact-no-contact';
    public static final String AMBIGUOUS_ANTECEDENT = 'ambiguous-antecedent';

    public class Request {
        public String handle;
        public String designator;
        public String kind;
        public String candidate;
        public String side;
        public String basis;
    }

    public static Map<String, Object> schema(
        List<String> handles, List<String> candidateHandles
    ) {
        List<String> candidates = new List<String>(candidateHandles);
        candidates.sort();
        candidates.add(NONE);

        Map<String, Object> perHandle = new Map<String, Object>();
        for (String h : handles) {
            perHandle.put(h, new Map<String, Object>{
                'type' => 'object',
                'properties' => new Map<String, Object>{
                    'kind' => new Map<String, Object>{
                        'type' => 'string',
                        'enum' => new List<String>{
                            TITLE_ONLY, NAMED_OFF_ARTIFACT,
                            ON_ARTIFACT_NO_CONTACT, AMBIGUOUS_ANTECEDENT
                        },
                        'description' => TITLE_ONLY + ': a role with no name anywhere in ' +
                            'the surrounding words. ' + NAMED_OFF_ARTIFACT + ': a named ' +
                            'person who was not on this call. ' + ON_ARTIFACT_NO_CONTACT +
                            ': a named person who spoke on this call. ' +
                            AMBIGUOUS_ANTECEDENT + ': the words do not settle who is meant.'
                    },
                    'candidate' => new Map<String, Object>{
                        'type' => 'string',
                        'enum' => candidates,
                        'description' => 'The person on the closed list these words mean, ' +
                            'or ' + NONE + '. Never a name that is not on the list.'
                    },
                    'side' => new Map<String, Object>{
                        'type' => 'string',
                        'enum' => new List<String>{ 'buyer', 'seller', 'unclear' },
                        'description' => 'Which organization the words place this person ' +
                            'in, ONLY where the words themselves voice it.'
                    },
                    'basis' => new Map<String, Object>{
                        'type' => 'string',
                        'description' => 'One short sentence from the quoted context.'
                    }
                },
                'required' => new List<String>{ 'kind', 'candidate', 'side', 'basis' },
                'additionalProperties' => false
            });
        }

        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'requests' => new Map<String, Object>{
                    'type' => 'object',
                    'properties' => perHandle,
                    'required' => new List<String>(handles),
                    'additionalProperties' => false
                }
            },
            'required' => new List<String>{ 'requests' },
            'additionalProperties' => false
        };
    }

    public static String systemPrompt() {
        return String.join(
            new List<String>{
                'You are handed short designators from one sales-call transcript - a name ' +
                'or a title the call used for a person the deterministic resolver could ' +
                'not place - each with the words that introduced them. For each one you ' +
                'classify WHO needs resolving and WHAT is known. You never look anything ' +
                'up, never invent a person, and never write a query: a database stage ' +
                'executes everything from your typed fields.',
                '',
                'RULES.',
                '',
                'ONE REQUEST PER DESIGNATOR, and the response shape enforces it.',
                '',
                'THE LIST IS CLOSED. candidate is a handle from the list or ' + NONE + '. ' +
                'A person the transcript talks about who is not on the list is ' + NONE +
                ', whatever their name.',
                '',
                'THE SIDE COMES FROM THE WORDS. Say seller or buyer only where the quoted ' +
                'words place them; otherwise unclear. A guess about the org chart is not ' +
                'an answer.',
                '',
                'A PERSON WHO EXISTS ONLY IN A STORY IS NOBODY. Sellers demonstrate ' +
                'products by narrating fictional people and companies. A designator that ' +
                'names a character in a demonstration, an example, or a hypothetical is ' +
                NONE + ' with kind ' + AMBIGUOUS_ANTECEDENT + ' and a basis saying so - ' +
                'never ' + NAMED_OFF_ARTIFACT + ', which is reserved for real people of ' +
                'this deal\'s world.'
            },
            '\n'
        );
    }

    public static List<Request> parse(
        String jsonText, Map<String, String> designatorByHandle
    ) {
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new CharterException(
                'The model leg returned something that is not JSON. First 300 characters: ' +
                (jsonText == null ? '(null)' : jsonText.abbreviate(300))
            );
        }
        if (!(root.get('requests') instanceof Map<String, Object>)) {
            throw new CharterException(
                'The model leg returned no requests object. Keys: ' +
                String.join(new List<String>(root.keySet()), ', ')
            );
        }
        Map<String, Object> reqs = (Map<String, Object>) root.get('requests');
        List<Request> out = new List<Request>();
        for (String h : designatorByHandle.keySet()) {
            if (!(reqs.get(h) instanceof Map<String, Object>)) {
                throw new CharterException(
                    'The model leg omitted handle ' + h + ', which the schema\'s required ' +
                    'list should have made impossible. Our bug, per the parse law.'
                );
            }
            Map<String, Object> m = (Map<String, Object>) reqs.get(h);
            Request r = new Request();
            r.handle = h;
            r.designator = designatorByHandle.get(h);
            r.kind = (String) m.get('kind');
            r.candidate = (String) m.get('candidate');
            r.side = (String) m.get('side');
            r.basis = (String) m.get('basis');
            out.add(r);
        }
        return out;
    }
}
