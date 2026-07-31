/**
 * Model call 2. The blind reader.
 *
 * It is handed a proposition, that proposition's elements, the first reader's
 * interpretation where there was one, and the spans the first reader cited after those
 * spans were located in the artifact. Per element it answers one question: do these spans
 * establish it, yes or no. Its no overrides claimed coverage.
 *
 * BLINDNESS IS STRUCTURAL HERE, NOT PROMISED. The functions below are never given the
 * transcript and are never given a verdict, so there is no wording anywhere that could leak
 * either. `content()` takes a contract, an interpretation and a list of spans. That is the
 * entire surface. A future edit that wants to pass the transcript in has to change a
 * signature, which is a thing a reviewer sees.
 *
 * WHY IT EXISTS, in one specimen. On 31 July the first reader cited, for the element
 * "available in the current fiscal year", the words "That I cannot tell you yet. Finance is
 * still working through the calendar." The quote is real, it is verbatim, and it is the
 * right passage to look at. It also refutes the element. Nothing in the pipeline was
 * checking whether a cited span supported what it was filed under, so coverage read full
 * and a wrong verdict was written as an established claim. Verbatim is not supporting, and
 * this class is the difference.
 *
 * WHAT IT MUST NOT DO. It does not apply the speaker requirement. That stays with
 * AAO_SpeakerRule at commit, deliberately, so the downgrade remains a law enforced by the
 * schema and stays visible firing.
 */
public class AAO_BlindCharter {
    public class BlindException extends Exception {
    }

    // ==================================================================== what goes in

    /** One proposition's citations, as the blind reader receives them. */
    public class Review {
        public AAO_Evidence_Contract__c contract;
        public String interpretation;
        public List<AAO_Model.Span> spans;

        public Review(
            AAO_Evidence_Contract__c contract,
            String interpretation,
            List<AAO_Model.Span> spans
        ) {
            this.contract = contract;
            this.interpretation = interpretation;
            this.spans = spans;
        }
    }

    // =================================================================== what comes back

    public class ElementVerdict {
        public String element;
        public Boolean established;
        public String reason;
    }

    // ======================================================================== the schema

    public static Map<String, Object> schema(List<Review> reviews) {
        List<String> codes = new List<String>();
        Set<String> elementIds = new Set<String>();
        for (Review r : reviews) {
            codes.add(r.contract.AAO_Proposition_Code__c);
            for (String id : AAO_ExtractCharter.elementIds(r.contract)) {
                elementIds.add(id);
            }
        }
        List<String> elems = new List<String>(elementIds);
        elems.sort();

        Map<String, Object> elementSchema = new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'element' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => elems
                },
                'established' => new Map<String, Object>{
                    'type' => 'boolean',
                    'description' => 'true only if the quotes given assert this element. ' +
                        'false if they merely mention it, discuss it, decline to confirm ' +
                        'it, or deny it.'
                },
                'reason' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'One sentence. On a false, name what is missing or ' +
                        'what the quote actually says instead.'
                }
            },
            'required' => new List<String>{ 'element', 'established', 'reason' },
            'additionalProperties' => false
        };

        Map<String, Object> reviewSchema = new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'proposition_code' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => codes
                },
                'elements' => new Map<String, Object>{
                    'type' => 'array',
                    'items' => elementSchema,
                    'description' => 'One entry for every element of this proposition, ' +
                        'including the ones no quote was offered for.'
                }
            },
            'required' => new List<String>{ 'proposition_code', 'elements' },
            'additionalProperties' => false
        };

        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'reviews' => new Map<String, Object>{
                    'type' => 'array',
                    'items' => reviewSchema
                }
            },
            'required' => new List<String>{ 'reviews' },
            'additionalProperties' => false
        };
    }

    // ================================================================== the system prompt

    public static String systemPrompt() {
        return String.join(
            new List<String>{
                'You are the second reader. You decide whether specific quoted evidence ' +
                'establishes specific elements of a proposition.',
                '',
                'You are not shown the transcript these quotes came from, and you are not ' +
                'shown what any earlier reader concluded. You see the question and the ' +
                'citations, and that is deliberate: you exist to check the citations, and a ' +
                'reader who could see the earlier answer would agree with it.',
                '',
                'For each element, answer one question. Do the quotes given establish it?',
                '',
                'ESTABLISH MEANS THE WORDS ASSERT IT. A quote that names the subject of an ' +
                'element without asserting it does not establish it. A quote in which ' +
                'somebody declines to confirm, says they do not know, defers to a later ' +
                'date, or says the matter is still being worked out does not establish the ' +
                'element it was filed under. Such a quote is evidence about that element and ' +
                'it is not establishment of it, and the correct answer is false.',
                '',
                'A question establishes nothing. Where a question and its answer are both ' +
                'quoted, the answer does the establishing; a question with no answer beside ' +
                'it establishes nothing at all.',
                '',
                'One assent does not carry a compound antecedent. If a quoted question ' +
                'contains three things and the quoted reply is "yes", that establishes one ' +
                'of them at most.',
                '',
                'Judge substance, not standing. Whether the speaker was entitled to establish ' +
                'the element is decided elsewhere, by machinery you cannot see. Never lower ' +
                'an answer because of who spoke.',
                '',
                'An element with no quote offered for it is not established. Say so rather ' +
                'than omitting it.',
                '',
                'Be willing to say no. Somebody has already said yes by filing the quote ' +
                'against the element, and a second reader who only confirms is not a check. ' +
                'A no is not a failure here; it is the reason you were asked.'
            },
            '\n'
        );
    }

    // ==================================================================== the user content

    public static String content(List<Review> reviews) {
        List<String> out = new List<String>();
        for (Review r : reviews) {
            out.add(
                '## ' +
                r.contract.AAO_Proposition_Code__c +
                ' — ' +
                r.contract.AAO_Proposition_Short__c
            );
            out.add('');
            out.add('Proposition: ' + r.contract.AAO_Proposition_Text__c);
            out.add('');
            out.add('Elements:');
            for (Object o : AAO_ExtractCharter.elementList(r.contract)) {
                Map<String, Object> e = (Map<String, Object>) o;
                out.add('  ' + e.get('id') + ': ' + e.get('text'));
            }
            if (String.isNotBlank(r.interpretation)) {
                // The first reader's reading of an under-specified question. Carried because
                // the blind reader has to judge against the same reading, not a different
                // one it invented. It is not a verdict and does not say what was concluded.
                out.add('');
                out.add(
                    'The first reader recorded this interpretation of the question: ' +
                    r.interpretation
                );
            }
            out.add('');
            if (r.spans == null || r.spans.isEmpty()) {
                out.add('No quotes were offered for this proposition.');
            } else {
                out.add('Quotes offered, with the element each was filed against:');
                for (AAO_Model.Span sp : r.spans) {
                    out.add(
                        '  [' +
                        sp.element +
                        '] ' +
                        (String.isBlank(sp.speaker) ? 'unattributed' : sp.speaker) +
                        ': "' +
                        sp.quote +
                        '"'
                    );
                }
            }
            out.add('');
        }
        return String.join(out, '\n');
    }

    // ========================================================================== parsing

    /** Keyed proposition code, then element id. */
    public static Map<String, Map<String, ElementVerdict>> parse(
        String jsonText,
        Set<String> knownCodes
    ) {
        Map<String, Map<String, ElementVerdict>> byCode = new Map<String, Map<String, ElementVerdict>>();
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new BlindException(
                'The blind reader returned something that is not JSON. First 300 ' +
                'characters: ' +
                jsonText.abbreviate(300)
            );
        }
        Object raw = root.get('reviews');
        if (!(raw instanceof List<Object>)) {
            throw new BlindException(
                'The blind reader returned JSON with no reviews array. Keys present: ' +
                String.join(new List<String>(root.keySet()), ', ')
            );
        }

        for (Object ro : (List<Object>) raw) {
            Map<String, Object> r = (Map<String, Object>) ro;
            String code = (String) r.get('proposition_code');
            if (!knownCodes.contains(code)) {
                continue;
            }
            Map<String, ElementVerdict> byElement = new Map<String, ElementVerdict>();
            Object rawElems = r.get('elements');
            if (rawElems instanceof List<Object>) {
                for (Object eo : (List<Object>) rawElems) {
                    Map<String, Object> e = (Map<String, Object>) eo;
                    ElementVerdict v = new ElementVerdict();
                    v.element = (String) e.get('element');
                    v.established = e.get('established') == true;
                    v.reason = (String) e.get('reason');
                    if (String.isNotBlank(v.element)) {
                        byElement.put(v.element, v);
                    }
                }
            }
            byCode.put(code, byElement);
        }
        return byCode;
    }
}
