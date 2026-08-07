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
    /**
     * Both sides answered no. Not a scope: the absence of one, and it dispatches nothing.
     * Unreachable under the retired two-sided question, which forced a pick among three.
     */
    public static final String NEITHER = 'NEITHER';
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

    /** One side's independent answer. Two of these derive the scope; neither outranks. */
    public class Side {
        public String name;
        public Boolean carries;
        public String quote;
        public String because;
        /** Byte offset in the frozen artifact, or null where it was never located. */
        public Integer offset;

        public Boolean located() {
            return offset != null;
        }
    }

    public class Result {
        /** DERIVED from the two sides in Apex. The model never answers this. */
        public String scope;
        /** COMPOSED from the two sides. No longer a field the model fills. */
        public String scopeBecause;
        public Side opportunitySide = new Side();
        public Side accountSide = new Side();
        public String opportunity;
        public String opportunityBecause;
        public List<Mention> mentions = new List<Mention>();

        /**
         * **BOTH SIDES NO.** The split makes this expressible where the two-sided question
         * could not say it, so it is surfaced rather than coerced into one of the three. A
         * call carrying no chartered content on either side dispatches nothing, which is the
         * silence law's own answer: we write what happened, and nothing did.
         */
        public Boolean carriesNothing() {
            return scope == NEITHER;
        }
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
                // TWO ONE-WAY QUESTIONS, ANSWERED INDEPENDENTLY. Charters v3.4. There is no
                // `scope` field for the model to fill any more: the verdict is DERIVED from
                // these two answers in Apex, so a majority cannot eat a minority scope
                // because NO QUESTION ASKS FOR A MAJORITY.
                'carries_opportunity_content' => new Map<String, Object>{
                    'type' => 'boolean',
                    'description' => 'Does this call carry opportunity content AT ALL? Not ' +
                        'mostly, not primarily - at all. Answer this without reference to ' +
                        'how much account content there is.'
                },
                'opportunity_content_quote' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'VERBATIM words from the transcript, character for ' +
                        'character, that carry opportunity content. Empty string where the ' +
                        'answer above is false. This is checked against the stored artifact.'
                },
                'opportunity_content_because' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'One sentence: what makes those words opportunity ' +
                        'content. Empty string where the answer above is false.'
                },
                'carries_account_content' => new Map<String, Object>{
                    'type' => 'boolean',
                    'description' => 'Does this call carry account content AT ALL? Not ' +
                        'mostly, not primarily - at all. **Answer this on its own merits. ' +
                        'The previous answer is not evidence about this one, and a call ' +
                        'that is mostly about a purchase can still carry account content.**'
                },
                'account_content_quote' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'VERBATIM words from the transcript, character for ' +
                        'character, that carry account content. Empty string where the ' +
                        'answer above is false. This is checked against the stored artifact.'
                },
                'account_content_because' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'One sentence: what makes those words account content. ' +
                        'Empty string where the answer above is false.'
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
                'carries_opportunity_content',
                'opportunity_content_quote',
                'opportunity_content_because',
                'carries_account_content',
                'account_content_quote',
                'account_content_because',
                'opportunity', 'opportunity_because', 'mentions'
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
                'YOU ARE ASKED ABOUT EACH SIDE SEPARATELY, AND THE TWO ANSWERS DO NOT ' +
                'COMPETE. There is no question here asking which side wins, which side is ' +
                'primary, or what the call is MOSTLY about. **Answer each side as if the ' +
                'other had not been asked.** A call that is ninety percent purchase ' +
                'mechanics and carries one real stretch of account content is a yes on both, ' +
                'and saying so is correct rather than a hedge.',
                '',
                'A YES MUST BRING WORDS. Where you answer yes, quote the transcript verbatim, ' +
                'character for character. **The quote is checked against the stored ' +
                'transcript and a yes whose words cannot be found there is thrown out.** ' +
                'Where you answer no, leave the quote empty; a no needs no evidence, because ' +
                'it asserts nothing.',
                '',
                'THE SMALLER SIDE IS THE ONE THAT GETS LOST. Whichever side is the minority ' +
                'of the call is the side that has to survive your reading of it, so read for ' +
                'it deliberately: a single sustained stretch about what they already own, ' +
                'how a rollout will run, or where the relationship goes next is account ' +
                'content whether or not the rest of the call is a negotiation.',
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

    /**
     * Strings that satisfy a required field and answer nothing. Deliberately short: a long
     * list starts judging prose quality, and this check only ever catches the case where the
     * model filled a slot rather than answered it.
     */
    private static final Set<String> NON_REASONS = new Set<String>{
        'placeholder', 'n/a', 'na', 'none', 'tbd', 'unknown', 'null', 'reason',
        'because', 'see above', 'as above', 'no reason', 'not applicable', '-', '.'
    };

    /**
     * The floor is characters rather than words, and it is set where a real reason cannot
     * fall below it: the shortest honest scope reason on any run to date is a clause naming
     * what the content was about.
     */
    @TestVisible
    private static Integer REASON_MIN_CHARS = 25;

    private static void requireReason(String field, String value) {
        String v = value == null ? '' : value.trim();
        if (String.isBlank(v)) {
            throw new CharterException(
                'Call 0 returned no ' + field + '. A verdict without a reason is a verdict ' +
                'nobody can check, and the schema requiring the field is not the same as the ' +
                'field carrying an answer. Our bug or the model\'s, per the parse law.'
            );
        }
        if (NON_REASONS.contains(v.toLowerCase().replaceAll('[.!]$', ''))) {
            throw new CharterException(
                'Call 0 filled ' + field + ' with the non-reason "' + v + '". A required ' +
                'field satisfied by a placeholder is a field that looks answered, and every ' +
                'reader downstream treats it as one.'
            );
        }
        if (v.length() < REASON_MIN_CHARS) {
            throw new CharterException(
                'Call 0 returned a ' + field + ' of ' + v.length() + ' characters ("' + v +
                '"), below the ' + REASON_MIN_CHARS + '-character floor. The floor is ' +
                'mechanical on purpose: judging whether prose is GOOD would be the ' +
                'judgment this design keeps out of the loop, and judging whether it EXISTS ' +
                'is a length.'
            );
        }
    }

    /**
     * Read one side. A `carries` of true must bring words with it: the quote is what the
     * byte check locates and the reason is what a human reads, and neither substitutes.
     */
    private static Side side(Map<String, Object> root, String prefix, String label) {
        Side s = new Side();
        s.name = label;
        Object raw = root.get('carries_' + prefix + '_content');
        if (!(raw instanceof Boolean)) {
            throw new CharterException(
                'Call 0 did not answer carries_' + prefix + '_content with a boolean. The ' +
                'two sides are independent answers and a missing one is not a no: it is a ' +
                'question that never got asked. Our bug, per the parse law.'
            );
        }
        s.carries = (Boolean) raw;
        s.quote = trimmed(root.get(prefix + '_content_quote'));
        s.because = trimmed(root.get(prefix + '_content_because'));
        if (!s.carries) {
            return s;
        }
        if (String.isBlank(s.quote)) {
            throw new CharterException(
                'Call 0 answered yes to ' + label + ' content and quoted nothing. A yes ' +
                'without words is the shape this split exists to kill: an unquoted side ' +
                'cannot be checked, and an unchecked side is how a scope read gets graded ' +
                'right for the wrong reason.'
            );
        }
        requireReason(prefix + '_content_because', s.because);
        return s;
    }

    private static String trimmed(Object o) {
        return o == null ? '' : String.valueOf(o).trim();
    }

    /**
     * DUAL IS ARITHMETIC. Both yes, and no weighing happens anywhere: not in the model, which
     * never saw the other answer, and not here, which only counts.
     */
    // The parameters are NOT named `opportunity` and `account`: Apex identifiers are
    // case-insensitive, so those names shadow the OPPORTUNITY and ACCOUNT string constants
    // this method returns, and the compiler reports it as a Boolean-to-String conversion.
    public static String deriveScope(Boolean oppSide, Boolean acctSide) {
        Boolean o = oppSide == true;
        Boolean a = acctSide == true;
        if (o && a) {
            return DUAL;
        }
        if (o) {
            return OPPORTUNITY;
        }
        if (a) {
            return ACCOUNT;
        }
        return NEITHER;
    }

    /**
     * The composed reason. Downstream readers and every run report still want one sentence
     * for the verdict, and under the split there is no single authored one - so it is built
     * from the halves that produced it, each naming itself.
     */
    private static String composeBecause(Side opp, Side acct) {
        List<String> parts = new List<String>();
        for (Side s : new List<Side>{ opp, acct }) {
            parts.add(
                s.name + ' content: ' + (s.carries ? 'YES. ' + s.because : 'no.')
            );
        }
        return String.join(parts, ' ');
    }

    /**
     * LOCATE EACH SIDE'S EVIDENCE IN THE FROZEN ARTIFACT. Call 0 routes and never establishes,
     * so these quotes are not claims and no pair is built from them - but a reason nobody can
     * find is the `placeholder` defect wearing a quotation mark, and the guard that fixed one
     * has no principled reason to miss the other.
     *
     * **A yes whose words are not in the transcript is refused**, because that answer is
     * strictly worse than a no: it routes reads at content that was never said.
     */
    public static void locate(Result r, String artifact) {
        if (r == null || String.isBlank(artifact)) {
            return;
        }
        for (Side s : new List<Side>{ r.opportunitySide, r.accountSide }) {
            if (!s.carries) {
                continue;
            }
            Integer at = artifact.indexOf(s.quote);
            if (at < 0) {
                throw new CharterException(
                    'Call 0 answered yes to ' + s.name + ' content on words that are not in ' +
                    'the artifact: "' + s.quote.abbreviate(120) + '". A quote that does not ' +
                    'locate is worse than no quote at all, because it routes family reads at ' +
                    'content nobody said.'
                );
            }
            s.offset = at;
        }
    }

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
        r.opportunity = (String) root.get('opportunity');
        r.opportunityBecause = (String) root.get('opportunity_because');

        // THE SCOPE VERDICT IS DERIVED, NEVER READ. Charters v3.4, earned by the failed-twice
        // law after two majority collapses on the same fixture (a17 returned OPPORTUNITY
        // against the gate's DUAL; a21 re-read the services scoping correctly under Matthew's
        // split ruling and still left the two account-grain stretches unmentioned).
        //
        // **The defect was never the wording, which is why two wording-era fixes did not
        // reach it.** One question asking "opportunity, account, or both" invites a reader to
        // weigh the sides against each other, and weighing is what produces a majority. So the
        // question that asks for a comparison is GONE. Two questions ask about one side each,
        // neither knows the other's answer, and DUAL is an arithmetic result rather than a
        // third option competing with two stronger-sounding ones.
        r.opportunitySide = side(root, 'opportunity', OPPORTUNITY);
        r.accountSide = side(root, 'account', ACCOUNT);
        r.scope = deriveScope(r.opportunitySide.carries, r.accountSide.carries);
        r.scopeBecause = composeBecause(r.opportunitySide, r.accountSide);
        Set<String> allowed = new Set<String>(oppHandles);
        allowed.add(NO_DEAL);
        allowed.add(AMBIGUOUS);
        if (!allowed.contains(r.opportunity)) {
            throw new CharterException(
                'Call 0 named a deal outside the closed candidate set: ' + r.opportunity
            );
        }
        // A VERDICT WITHOUT A REAL REASON FAILS LOUDLY AND NEVER FILLS. Ruled 6 August from
        // the B&V run, where `scope_because` came back as the literal string `placeholder`.
        //
        // **The schema required the field and nothing required it to carry a reason**, which
        // is the defaulted-coverage shape again: a required field satisfied by a non-reason
        // is a field that looks answered, and every downstream reader treats it as one. The
        // B&V verdict was correct - ACCOUNT, the gate's own expectation - and its reasoning
        // was unreadable, so nobody could have told a right answer from a lucky one.
        //
        // Structural rather than a nudge, per the failed-twice law: this is checked at the
        // parse, so a filled reason cannot reach a run report at all. Deterministic and
        // mechanical - a length floor and a short filler set - because a rule that judged
        // whether prose was *good* would be the thing this design keeps out of the loop.
        requireReason('scope_because', r.scopeBecause);
        // The opportunity reason is required only where a deal was actually named. NO_DEAL
        // and AMBIGUOUS are refusals, and demanding a reason for one is demanding prose about
        // an absence.
        if (r.opportunity != NO_DEAL && r.opportunity != AMBIGUOUS) {
            requireReason('opportunity_because', r.opportunityBecause);
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
