/**
 * Extraction charter v1. Assembles the prompt and the output schema from Evidence Contract
 * records, at runtime, and parses what comes back.
 *
 * No callout happens here. This class is pure text in and text out, which is the only
 * reason the charter is testable at all: the prompt a given rubric produces can be asserted
 * without spending a token.
 *
 * FOUR THINGS THIS CHARTER DELIBERATELY DOES NOT DO.
 *
 * 1. It does not read the mirror. No Answer row, no prior claim, no current verdict is
 *    queried or injected. A charter that can see what the deal currently says can agree
 *    with it, and agreement is indistinguishable from evidence.
 *
 * 2. It does not apply the speaker requirement. The requirement is injected, because the
 *    model needs it to know which utterance carries the assertion, and the schema then
 *    forbids it from changing the verdict on that basis. Who may establish what is enforced
 *    by AAO_SpeakerRule at commit, structurally. If the charter pre-applied the rule the
 *    seller-said-it deal would come back UNVERIFIED already, the downgrade would never
 *    fire, and we would have replaced an enforced law with a request.
 *
 * 3. It does not decide element coverage. It cites spans against elements; coverage is
 *    computed from the spans that survive byte verification. A model asserting its own
 *    coverage is a model grading its own homework, and it is what the fixture did.
 *
 * 4. It does not choose the vocabulary. Every enum in the output schema is built from the
 *    rubric in the org: proposition codes are the contracts that exist, element ids are the
 *    elements those contracts carry, speakers are the roster on this artifact. The model
 *    cannot name a proposition we do not have or a person who was not on the call, because
 *    there is no string it could emit that would mean that.
 */
public class AAO_ExtractCharter {
    public class CharterException extends Exception {
    }

    /** Bound on spans per proposition, enforced here rather than requested in prose. */
    public static final Integer MAX_SPANS = 5;

    // ==================================================================== what comes back

    public class QuotedSpan {
        public String quote;
        public String speaker;
        public String element;
    }

    public class Finding {
        public String propositionCode;
        /** addressed | not_addressed | abstained */
        public String status;
        /** TRUE | FALSE | UNVERIFIED | NONE */
        public String proposedVerdict;
        public String interpretation;
        public List<QuotedSpan> spans;
    }

    public class Findings {
        public List<Finding> findings;
    }

    // ======================================================================== the schema

    /**
     * The output schema. Every vocabulary in it is closed and every closed vocabulary is
     * built from org data, so an invented proposition code or an invented speaker is not a
     * value the model is able to return.
     */
    public static Map<String, Object> schema(
        List<AAO_Evidence_Contract__c> contracts,
        Map<String, AAO_Model.Speaker> roster
    ) {
        List<String> codes = new List<String>();
        Set<String> elementIds = new Set<String>();
        for (AAO_Evidence_Contract__c ec : contracts) {
            codes.add(ec.AAO_Proposition_Code__c);
            for (String id : elementIds(ec)) {
                elementIds.add(id);
            }
        }
        List<String> elems = new List<String>(elementIds);
        elems.sort();

        Map<String, Object> spanProps = new Map<String, Object>{
            'quote' => new Map<String, Object>{
                'type' => 'string',
                'description' => 'Verbatim, character for character, from the transcript. ' +
                    'It is checked byte for byte against the stored artifact and a span ' +
                    'that does not match exactly is discarded.'
            },
            'element' => new Map<String, Object>{
                'type' => 'string',
                'enum' => elems,
                'description' => 'Which element of this proposition the quote is offered for.'
            }
        };

        // Speakers are the roster on THIS artifact. An unsegmented artifact has none, and
        // then the field is a free string that will simply never satisfy a speaker-gated
        // proposition downstream, which is the correct outcome rather than an error here.
        List<String> speakerKeys = new List<String>(roster.keySet());
        speakerKeys.sort();
        Map<String, Object> speakerProp = new Map<String, Object>{
            'type' => 'string',
            'description' => 'The roster key of the person whose turn this quote lies in.'
        };
        if (!speakerKeys.isEmpty()) {
            speakerProp.put('enum', speakerKeys);
        }
        spanProps.put('speaker', speakerProp);

        Map<String, Object> spanSchema = new Map<String, Object>{
            'type' => 'object',
            'properties' => spanProps,
            'required' => new List<String>{ 'quote', 'speaker', 'element' },
            'additionalProperties' => false
        };

        Map<String, Object> findingSchema = new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'proposition_code' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => codes
                },
                'status' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => new List<String>{ 'addressed', 'not_addressed', 'abstained' },
                    'description' => 'addressed: the transcript speaks to this proposition ' +
                        'and you are proposing a verdict. not_addressed: nobody said ' +
                        'anything bearing on it. abstained: it was discussed and you cannot ' +
                        'reach a verdict. These are three different facts and collapsing ' +
                        'the last two makes the abstention rate measure nothing.'
                },
                'proposed_verdict' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => new List<String>{ 'TRUE', 'FALSE', 'UNVERIFIED', 'NONE' },
                    'description' => 'NONE unless status is addressed. Judge only whether ' +
                        'the words establish the proposition. Do NOT lower a verdict ' +
                        'because of who spoke; that is adjudicated after you. FALSE ' +
                        'requires a positive assertion that the proposition does not ' +
                        'hold. A missing confirmation, a deferral, or "I do not know" is ' +
                        'UNVERIFIED, never FALSE.'
                },
                'interpretation' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'Empty string is the good case. Fill this only where ' +
                        'you had to read the proposition beyond its own text to apply it, ' +
                        'and say what you took it to mean. Populated rows are the ' +
                        'under-specified-question list.'
                },
                'spans' => new Map<String, Object>{
                    'type' => 'array',
                    'items' => spanSchema,
                    'description' => 'Empty unless status is addressed. At most ' +
                        MAX_SPANS +
                        ' are kept and the rest are dropped by the writer.'
                }
            },
            'required' => new List<String>{
                'proposition_code',
                'status',
                'proposed_verdict',
                'interpretation',
                'spans'
            },
            'additionalProperties' => false
        };

        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'findings' => new Map<String, Object>{
                    'type' => 'array',
                    'items' => findingSchema,
                    'description' => 'Exactly one entry per proposition given, in the order ' +
                        'given. Never omit one: a proposition nobody spoke to is a finding ' +
                        'with status not_addressed, and the complete ledger is the point.'
                }
            },
            'required' => new List<String>{ 'findings' },
            'additionalProperties' => false
        };
    }

    // ================================================================== the system prompt

    public static String systemPrompt() {
        return String.join(
            new List<String>{
                'You read one piece of sales-call evidence and report, for each proposition ' +
                'you are given, whether that evidence establishes it and which words it rests on.',
                '',
                'You are the first reader. Nothing you produce is trusted on its own: every ' +
                'quote you cite is verified byte for byte against the stored transcript, and ' +
                'independent gates decide what is recorded. Your job is an accurate reading, ' +
                'not a useful-sounding one.',
                '',
                'RULES.',
                '',
                'Quote verbatim. A span must be a character-for-character substring of the ' +
                'transcript as given to you, including its punctuation and capitalisation. Do ' +
                'not tidy, join, trim or paraphrase. A span that does not match exactly is ' +
                'discarded and the coverage it would have carried is lost.',
                '',
                'Cite the words that carry the assertion, not the words around them. A ' +
                'question that produced an answer may be cited alongside the answer where the ' +
                'answer alone is meaningless, but the span that carries the claim is the one ' +
                'that has to say it.',
                '',
                'One assent does not carry a compound antecedent. If someone asks a question ' +
                'containing three separate things and the reply is "yes", that establishes ' +
                'one thing at most, and you should say which one rather than crediting all three.',
                '',
                'Judge substance, not standing. You are told which speaker a proposition ' +
                'requires so that you can identify whose utterance would carry it. You must ' +
                'not use it to change the verdict. If the words establish the proposition, ' +
                'propose that verdict and report the speaker accurately; whether that person ' +
                'was entitled to establish it is decided after you, by machinery you cannot see.',
                '',
                'Element by element. Offer each span against the specific element it evidences. ' +
                'Do not offer one span for all elements of a proposition.',
                '',
                'Report every proposition, including the ones nothing was said about. Silence ' +
                'about a proposition is itself a recorded fact, and it is a different fact from ' +
                'discussion you could not resolve.',
                '',
                'Do not infer beyond the evidence. Plans, intentions and expectations are not ' +
                'the events they describe. "We will have budget approved next month" is not ' +
                'approved budget.',
                '',
                'ABSENCE NEVER ESTABLISHES FALSE. FALSE means the evidence positively asserts ' +
                'that the proposition does not hold. Silence does not, and neither does ' +
                'anything in the family of "I do not know", "I cannot tell you yet", "we have ' +
                'not decided", "that is still being worked out", or a question left ' +
                'unanswered. Those are absence of confirmation, and absence of confirmation ' +
                'is UNVERIFIED. Reach for FALSE only when somebody said the thing is not so. ' +
                'If you find yourself proposing FALSE because a confirmation is missing ' +
                'rather than because a denial is present, the answer you want is UNVERIFIED.',
                '',
                'You are not shown, and must not guess at, any current state for this deal. ' +
                'What was concluded before is none of your business and agreeing with it is ' +
                'not evidence.'
            },
            '\n'
        );
    }

    // ==================================================================== the user content

    /**
     * The rubric and the artifact, assembled from records. Nothing here is a literal in
     * Apex: change a contract's guidance in the org and the next call sends the new text.
     *
     * Kept because it is the whole prompt in one string, which is what the tests assert
     * against. The live call sends the two halves as separate content blocks so the first
     * can be cached; see rubricBlock and artifactBlock.
     */
    public static String userContent(
        AAO_Source__c src,
        List<AAO_Evidence_Contract__c> contracts,
        Map<String, AAO_Model.Speaker> roster
    ) {
        // ARTIFACT FIRST, propositions second. Part of the per-person pass shape, ruled.
        //
        // This INVERTS the ordering below, and the comment on `rubricBlock` explaining why the
        // rubric led is not wrong — it was right for the access pattern it was written for: one
        // stable rubric read against many artifacts, where the rubric is the invariant.
        //
        // A per-person pass has the opposite pattern. One artifact is read N times, once per
        // person, and only the proposition tail changes. With the rubric leading, each of N
        // calls pays full price for 46 KB of transcript and every call is back at the
        // 120-second ceiling. With the artifact leading, the transcript sits in the cacheable
        // prefix and calls two and three read it instead of sending it.
        //
        // **The prefix hit on calls two and three is PREDICTED, not verified.** That caching
        // works at all through this path is measured: session 62 read 13,799 cached tokens from
        // Apex via the Named Credential. That this ordering earns a hit per person is not.
        // `cacheRead` per call goes in the run report, and near-zero on the later calls
        // falsifies the prediction and the shape gets revisited on evidence.
        return artifactBlock(src, roster) + '\n\n' + rubricBlock(contracts);
    }

    /**
     * THE CACHEABLE HALF. Identical for every artifact in an org until somebody edits a
     * contract, which is exactly the shape prompt caching wants: a stable prefix followed
     * by volatile content. It is first in the message and carries the cache breakpoint, so
     * the second artifact of a pass reads the rubric from cache instead of paying for it
     * again.
     *
     * Nothing volatile may move above this line. A timestamp, a source ref or a roster in
     * here would change the prefix on every call and the cache would never read, silently,
     * with no error to notice.
     */
    public static String rubricBlock(List<AAO_Evidence_Contract__c> contracts) {
        List<String> out = new List<String>();

        out.add('# The propositions');
        out.add('');
        for (AAO_Evidence_Contract__c ec : contracts) {
            out.add('## ' + ec.AAO_Proposition_Code__c + ' — ' + ec.AAO_Proposition_Short__c);
            out.add('');
            out.add('Proposition: ' + ec.AAO_Proposition_Text__c);
            if (String.isNotBlank(ec.AAO_Guidance_Text__c)) {
                out.add('Guidance: ' + ec.AAO_Guidance_Text__c);
            }
            out.add('Elements, each of which needs its own evidence:');
            for (Object o : elementList(ec)) {
                Map<String, Object> e = (Map<String, Object>) o;
                out.add('  ' + e.get('id') + ': ' + e.get('text'));
            }
            out.add(
                'Speaker requirement: ' +
                describeRequirement(ec.AAO_Speaker_Requirement__c) +
                ' Identify whose words carry the assertion. Do not let this change your verdict.'
            );
            if (String.isNotBlank(ec.AAO_Per_Person_Source__c)) {
                out.add(
                    'This proposition is asked per person, so a span establishes it about ' +
                    'the person who said it and not about the room.'
                );
            }
            out.add('');
        }
        return String.join(out, '\n');
    }

    /** THE VOLATILE HALF. Roster and transcript, different for every artifact. */
    public static String artifactBlock(
        AAO_Source__c src,
        Map<String, AAO_Model.Speaker> roster
    ) {
        List<String> out = new List<String>();

        out.add('# Who is on this call');
        out.add('');
        if (roster.isEmpty()) {
            out.add(
                'The artifact carries no speaker attribution. Report the speaker of each ' +
                'span as the empty string.'
            );
        } else {
            // Roles and sides, because they are what the speaker requirement is written
            // against. Not a hint about the answer: a decision maker can say something that
            // establishes nothing.
            for (String key : roster.keySet()) {
                AAO_Model.Speaker sp = roster.get(key);
                out.add(
                    '  ' +
                    key +
                    ': ' +
                    sp.display +
                    (String.isBlank(sp.mapRole) ? '' : ', ' + sp.mapRole) +
                    (String.isBlank(sp.email) ? '' : ' <' + sp.email + '>')
                );
            }
        }
        out.add('');

        out.add('# The transcript');
        out.add('');
        out.add(
            'This is the stored artifact exactly as held. Your quotes are matched against ' +
            'this text and nothing else.'
        );
        out.add('');
        out.add(src.AAO_Normalized_Text__c);

        return String.join(out, '\n');
    }

    private static String describeRequirement(String requirement) {
        if (requirement == 'Decision_Maker_Or_Influencer') {
            return 'the assertion must come from a buyer-side decision maker or influencer.';
        }
        if (requirement == 'Buyer_Side') {
            return 'the assertion must come from the buying side.';
        }
        if (requirement == 'Seller') {
            return 'the assertion must come from the selling side.';
        }
        if (requirement == 'Any_Participant') {
            return 'any participant may carry the assertion.';
        }
        return 'unspecified.';
    }

    // ========================================================================= elements

    public static List<Object> elementList(AAO_Evidence_Contract__c ec) {
        if (String.isBlank(ec.AAO_Elements__c)) {
            return new List<Object>();
        }
        return (List<Object>) JSON.deserializeUntyped(ec.AAO_Elements__c);
    }

    public static List<String> elementIds(AAO_Evidence_Contract__c ec) {
        List<String> ids = new List<String>();
        for (Object o : elementList(ec)) {
            ids.add((String) ((Map<String, Object>) o).get('id'));
        }
        return ids;
    }

    // ========================================================================== parsing

    /**
     * The model returns findings keyed by proposition code. Anything it says about a
     * proposition we did not ask about is dropped rather than trusted, and the drop is
     * reported by the caller.
     */
    public static Map<String, Finding> parse(String jsonText, Set<String> knownCodes) {
        Map<String, Finding> byCode = new Map<String, Finding>();
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new CharterException(
                'The charter returned something that is not JSON. First 300 characters: ' +
                jsonText.abbreviate(300)
            );
        }
        Object rawFindings = root.get('findings');
        if (!(rawFindings instanceof List<Object>)) {
            throw new CharterException(
                'The charter returned JSON with no findings array. Keys present: ' +
                String.join(new List<String>(root.keySet()), ', ')
            );
        }

        for (Object fo : (List<Object>) rawFindings) {
            Map<String, Object> f = (Map<String, Object>) fo;
            String code = (String) f.get('proposition_code');
            if (!knownCodes.contains(code)) {
                continue;
            }

            Finding fin = new Finding();
            fin.propositionCode = code;
            fin.status = (String) f.get('status');
            fin.proposedVerdict = (String) f.get('proposed_verdict');
            fin.interpretation = (String) f.get('interpretation');
            fin.spans = new List<QuotedSpan>();

            Object rawSpans = f.get('spans');
            if (rawSpans instanceof List<Object>) {
                for (Object so : (List<Object>) rawSpans) {
                    if (fin.spans.size() >= MAX_SPANS) {
                        break;
                    }
                    Map<String, Object> s = (Map<String, Object>) so;
                    QuotedSpan q = new QuotedSpan();
                    q.quote = (String) s.get('quote');
                    q.speaker = (String) s.get('speaker');
                    q.element = (String) s.get('element');
                    if (String.isNotBlank(q.quote)) {
                        fin.spans.add(q);
                    }
                }
            }
            byCode.put(code, fin);
        }
        return byCode;
    }
}