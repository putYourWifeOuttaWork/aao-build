/**
 * CALL 0: the resolver's read. Charters v3.2, Part II. Runs on every Source, before the sweep.
 *
 * **It routes and resolves and never establishes.** That is the prohibition law taking its
 * clean form: call 0 decides which grains dispatch and who the candidates are; the family
 * reads establish and never route. Nothing call 0 emits is ever cited, and no pair carries a
 * scope it judged — a pair's scope is its read's declared grain, structurally.
 *
 * THE SIDED VOCABULARY IS THE READ'S ONTOLOGY AND IT IS OURS. Carried verbatim from §P5's
 * closed list, because it is authored text held to the same law as a proposition: a
 * normalised quote is a paraphrase. The two layers law governs it — **the vocabulary routes
 * and never gates a write; establishment writes and never routes.**
 *
 * THE STAMP COMPOSES TWO HALVES, per the standing law: this charter's prose plus the sided
 * ontology text it reads against. Both covered or the stamp is decoration.
 *
 * WHAT IT CANNOT DO, named rather than faked. Test 1 needs an owner-organizer with a mapped
 * role, and this org has no role map — so the deterministic ladder hands call 0 a NOT
 * AVAILABLE for that leg rather than a guess. §P5's own measure is that roughly 75% of the
 * market are file-dump orgs carrying neither, which is exactly why call 0 is unconditional.
 */
public with sharing class AAO_ResolverCharter {
    public class CharterException extends Exception {
    }

    public static final String VERSION = 'resolve-1.0.0';

    public static final String OPPORTUNITY = 'OPPORTUNITY';
    public static final String ACCOUNT = 'ACCOUNT';
    public static final String DUAL = 'DUAL';
    public static final String NO_DEAL = 'NONE';
    public static final String AMBIGUOUS = 'AMBIGUOUS';

    // ============================================================ the sided vocabulary

    /**
     * §P5's closed list, verbatim. Meanings of each side, never strings to grep — the read is
     * what the conversation is ABOUT. The `renewals` entry is struck by Matthew's own ruling
     * and is not carried: an opportunity is an opportunity whatever the org calls it.
     */
    private static final List<String> OPPORTUNITY_SIDE = new List<String>{
        'the decision process and decision criteria',
        'a compelling event and its date',
        'budget, funding, approval to spend',
        'evaluation, proof, demos in an evaluation context',
        'proposal, pricing, quote, negotiation',
        'competition and alternatives',
        'contract, legal, procurement, signature',
        'timeline to a decision',
        'who must say yes to a purchase',
        'ROI justification before a purchase',
        'feasibility study',
        'RFP / RFQ',
        'technical approval and security analyses in the context of a purchase',
        'close plan or mutual action plan'
    };

    private static final List<String> ACCOUNT_SIDE = new List<String>{
        'adoption and utilization of an owned product',
        'onboarding, training, enablement',
        'business reviews and QBRs',
        'support, escalations, service delivery',
        'managed-services execution',
        'value realization from what is owned',
        'roadmap and relationship cadence',
        'account team orchestration across many deals',
        'consumption',
        'trailing ROI',
        'success and service programs',
        'center of excellence',
        'continuation planning',
        'product- or program-related health performance'
    };

    /** The authored caveats, in the ontology itself, per §P5. */
    private static final List<String> CAVEATS = new List<String>{
        'Late-stage onboarding discussion inside a still-open deal reads account-shaped and is not.',
        'Expansion seeding ("we could also use this for...") on an account call is the DUAL ' +
        'trigger, not a scope flip.',
        'A seller demoing on an account call does not make it a deal call.',
        'Account-shaped talk bearing directly on an open opportunity\'s outcome routes to that ' +
        'opportunity as well.'
    };

    /** The ontology half of the two-halves stamp. */
    public static String ontologyText() {
        List<String> out = new List<String>{ '# Opportunity-side content', '' };
        for (String s : OPPORTUNITY_SIDE) {
            out.add('  - ' + s);
        }
        out.add('');
        out.add('# Account-side content');
        out.add('');
        for (String s : ACCOUNT_SIDE) {
            out.add('  - ' + s);
        }
        out.add('');
        out.add('# Caveats, authored into the ontology');
        out.add('');
        for (String s : CAVEATS) {
            out.add('  - ' + s);
        }
        return String.join(out, '\n');
    }

    public static String effectiveVersion() {
        String hex = EncodingUtil.convertToHex(
            Crypto.generateDigest('SHA-256', Blob.valueOf(systemPrompt() + ontologyText()))
        );
        return VERSION + '+' + hex.substring(0, 8);
    }

    // ================================================================== what comes back

    public class Mention {
        public String name;
        public String why;
    }

    public class Result {
        public String scope;
        public String scopeBecause;
        public String opportunity;
        public String opportunityBecause;
        public List<Mention> mentions = new List<Mention>();
    }

    // ======================================================================= the schema

    public static Map<String, Object> schema(List<String> oppHandles) {
        List<String> opps = new List<String>(oppHandles);
        opps.sort();
        opps.add(NO_DEAL);
        opps.add(AMBIGUOUS);

        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'scope' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => new List<String>{ OPPORTUNITY, ACCOUNT, DUAL },
                    'description' => 'What this call is about. ' + DUAL +
                        ' where it genuinely serves both, which is a real and ordinary case ' +
                        'rather than an escape hatch.'
                },
                'scope_because' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'One or two sentences naming the content that decided ' +
                        'it. On ' + DUAL + ', name a specimen from EACH side.'
                },
                'opportunity' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => opps,
                    'description' => 'Which deal this call served, from the candidate list. ' +
                        NO_DEAL + ' where no listed deal fits. ' + AMBIGUOUS +
                        ' where two fit and the call cannot separate them. On a pure ' +
                        ACCOUNT + ' call, answer ' + NO_DEAL + '.'
                },
                'opportunity_because' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'One sentence. What in the call points at that deal.'
                },
                'mentions' => new Map<String, Object>{
                    'type' => 'array',
                    'description' => 'People the call TALKED ABOUT who did not speak on it, ' +
                        'and only where the mention is LOAD-BEARING: a stated holder, a ' +
                        'stated gate, a stated role. A name dropped in chatter is not one.',
                    'items' => new Map<String, Object>{
                        'type' => 'object',
                        'properties' => new Map<String, Object>{
                            'name' => new Map<String, Object>{ 'type' => 'string' },
                            'why' => new Map<String, Object>{
                                'type' => 'string',
                                'description' => 'What the call said they hold or decide.'
                            }
                        },
                        'required' => new List<String>{ 'name', 'why' },
                        'additionalProperties' => false
                    }
                }
            },
            'required' => new List<String>{
                'scope', 'scope_because', 'opportunity', 'opportunity_because', 'mentions'
            },
            'additionalProperties' => false
        };
    }

    // ================================================================ the system prompt

    public static String systemPrompt() {
        return String.join(
            new List<String>{
                'You read one sales-call transcript and answer three routing questions: what ' +
                'this call is about, which deal it served, and which people it talked about ' +
                'who were not on it.',
                '',
                'You are the first of several readers and the only one that routes. Everything ' +
                'after you reads the same transcript again to find what was established; your ' +
                'answers decide which questions those readers are given. **Nothing you say is ' +
                'ever recorded as evidence about anybody.**',
                '',
                'RULES.',
                '',
                'YOU ESTABLISH NOTHING. Not a person\'s standing, not their role, not what ' +
                'they decided. You route. A reader after you does the rest with the words in ' +
                'front of it.',
                '',
                'ACCOUNT AND OPPORTUNITY ARE ABOUT DIFFERENT THINGS, NOT DIFFERENT PEOPLE. An ' +
                'opportunity call is about a purchase that has not happened: what it costs, ' +
                'who approves it, when it closes, what it is measured against. An account ' +
                'call is about a relationship that already exists: what they own and whether ' +
                'they use it, how it is going, what happens next in the partnership.',
                '',
                'DUAL IS REAL AND IS NOT A HEDGE. Many calls genuinely serve both — a renewal ' +
                'conversation that turns to how the current deployment is going, an adoption ' +
                'review where somebody floats an expansion. **Answer DUAL when both sides are ' +
                'substantively present, and name a specimen from each when you do.** Do not ' +
                'answer DUAL because you are unsure which one it is; that is what the reasons ' +
                'field is for.',
                '',
                'THE DEAL LIST IS CLOSED. Answer with a listed deal, or NONE, or AMBIGUOUS. ' +
                'The list was built as of the day this call happened, not today, so a deal ' +
                'that closed or opened since is deliberately absent or present accordingly.',
                '',
                'MENTIONED PEOPLE MUST BE LOAD-BEARING. Somebody who approves this, owns the ' +
                'budget for it, or must be convinced. A name in passing earns no entry. If ' +
                'you are listing more than a handful, you have the bar wrong.',
                '',
                'THE EVIDENCE YOU ARE GIVEN IS EVIDENCE, NOT AN ANSWER. Anything computed ' +
                'before you — who owns the deal, which people overlap which map, what the ' +
                'candidate deals are — is one input. Where it disagrees with what the call ' +
                'plainly says, the call wins and your reason says so.'
            },
            '\n'
        );
    }

    // ========================================================================= parsing

    public static Result parse(String jsonText, List<String> oppHandles) {
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new CharterException(
                'Call 0 returned something that is not JSON. First 300 characters: ' +
                (jsonText == null ? '(null)' : jsonText.abbreviate(300))
            );
        }
        Result r = new Result();
        r.scope = (String) root.get('scope');
        r.scopeBecause = (String) root.get('scope_because');
        r.opportunity = (String) root.get('opportunity');
        r.opportunityBecause = (String) root.get('opportunity_because');
        if (!new Set<String>{ OPPORTUNITY, ACCOUNT, DUAL }.contains(r.scope)) {
            throw new CharterException(
                'Call 0 returned a scope outside the closed set: ' + r.scope +
                '. Our bug, per the parse law.'
            );
        }
        Set<String> allowed = new Set<String>(oppHandles);
        allowed.add(NO_DEAL);
        allowed.add(AMBIGUOUS);
        if (!allowed.contains(r.opportunity)) {
            throw new CharterException(
                'Call 0 named a deal outside the closed candidate set: ' + r.opportunity
            );
        }
        if (root.get('mentions') instanceof List<Object>) {
            for (Object o : (List<Object>) root.get('mentions')) {
                Map<String, Object> m = (Map<String, Object>) o;
                Mention mn = new Mention();
                mn.name = (String) m.get('name');
                mn.why = (String) m.get('why');
                if (String.isNotBlank(mn.name)) {
                    r.mentions.add(mn);
                }
            }
        }
        return r;
    }
}
