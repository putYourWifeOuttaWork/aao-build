/**
 * STAGE 2 of the Extract-Bind-Verify pass (Charters v2.4 §P7.3). Binding.
 *
 * An inventory item names a family and a person. The contract for that pair is found
 * DETERMINISTICALLY — `token#contactId`, no model involved, see `AAO_EBV.bindPlan` — and this
 * charter answers the one question that is left: does this span establish this proposition
 * about this person.
 *
 * **A binding call carries the span, the proposition and the subject. It does not carry the
 * transcript, and there is no parameter here through which one could arrive.** That is what
 * makes the call small enough to be measured in seconds instead of minutes, and it is also
 * what makes the judgment honest: a reader that can see the surrounding conversation can
 * establish a proposition from context the span does not contain, and the span is what gets
 * stored and shown.
 *
 * THREE VERDICTS, EXACTLY AS CHARTERED. establishes / does_not_establish / insufficient.
 * §P7.3 names three and this class implements three.
 *
 * **A consequence of that, reported rather than fixed here:** there is no verdict in this
 * vocabulary that reaches FALSE. `does_not_establish` maps to UNVERIFIED downstream, which is
 * correct under the standing law that absence of a confirmation is never a denial — but it
 * means a positive denial ("no, Dana does not own that budget") also lands on UNVERIFIED, and
 * the TRUE-strong / FALSE-weak guard on two-sided questions therefore has no FALSE input in
 * this shape. Named in BUILD_JOURNAL for design. Not invented around here: the pass shape is
 * not mine to redesign mid-build.
 */
public class AAO_BindCharter {
    public class CharterException extends Exception {
    }

    public static final String ESTABLISHES = 'establishes';
    public static final String DOES_NOT = 'does_not_establish';
    public static final String INSUFFICIENT = 'insufficient';

    /**
     * The evidence budget, ~90 output tokens per finding, ruled 3 August and justified by
     * coextension rather than by display. It governs MODEL OUTPUT only: the stored quote on
     * an Answer row stays full-fidelity from the transcript. Expressed to the model in words
     * because there is no per-item token limit in the API to set.
     */
    public static final Integer REASON_WORD_BUDGET = 45;

    // ============================================================================= input

    /** One thing to decide. Built by Apex, never by a model. */
    public class BindItem {
        public String id;
        /** The contract this binding would promote a Candidate against. */
        public String contractCode;
        public String propositionText;
        /** The person the proposition is asked about, as a name. */
        public String subjectDisplay;
        /** The roster key of whoever spoke the span. Identification only. */
        public String speaker;
        public String speakerRequirement;
        public String span;
        /** Carried through so the writer can rebuild the item without a second lookup. */
        public Id subjectContactId;
        public String inventoryItemId;
    }

    // ============================================================================ output

    public class Binding {
        public String id;
        /** establishes | does_not_establish | insufficient */
        public String verdict;
        public String reason;
    }

    // =========================================================================== schema

    public static Map<String, Object> schema(List<BindItem> items) {
        List<String> ids = new List<String>();
        for (BindItem b : items) {
            ids.add(b.id);
        }

        Map<String, Object> bindingSchema = new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'id' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => ids,
                    'description' => 'The item id you are answering. One answer per item.'
                },
                'verdict' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => new List<String>{ ESTABLISHES, DOES_NOT, INSUFFICIENT },
                    'description' => ESTABLISHES + ': the words in the span assert the ' +
                        'proposition about the named subject. ' + DOES_NOT + ': the span ' +
                        'bears on the proposition and does not assert it, including where it ' +
                        'asserts the opposite. ' + INSUFFICIENT + ': the span is not enough ' +
                        'to tell either way. These are three different facts.'
                },
                'reason' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'Under ' + REASON_WORD_BUDGET + ' words, naming the ' +
                        'words in the span that decided it. Not a summary of the span.'
                }
            },
            'required' => new List<String>{ 'id', 'verdict', 'reason' },
            'additionalProperties' => false
        };

        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'bindings' => new Map<String, Object>{
                    'type' => 'array',
                    'items' => bindingSchema,
                    'description' => 'Exactly one entry per item given. Never omit one: an ' +
                        'item you do not answer is recorded as unbound, which is a worse ' +
                        'outcome than ' + INSUFFICIENT + '.'
                }
            },
            'required' => new List<String>{ 'bindings' },
            'additionalProperties' => false
        };
    }

    // ==================================================================== system prompt

    public static String systemPrompt() {
        return String.join(
            new List<String>{
                'You decide, for each item, whether one quoted span establishes one ' +
                'proposition about one named person.',
                '',
                'You see the span and the proposition. You do not see the transcript, the ' +
                'conversation around the span, any other item, or anything this deal ' +
                'currently records. That is deliberate: the span is what will be stored and ' +
                'shown as the evidence, so the span alone has to carry the claim.',
                '',
                'RULES.',
                '',
                'THE SUBJECT MUST MATCH. The proposition is about the named person. A span ' +
                'that establishes the same thing about somebody else establishes nothing ' +
                'here. Check the subject before anything else, because this is the failure ' +
                'this stage exists to prevent.',
                '',
                'THE SCOPE MUST MATCH. A span about one team does not establish a ' +
                'proposition about the organisation. A span about one quarter does not ' +
                'establish one about the year. Narrower is not smaller-but-fine; it is a ' +
                'different proposition.',
                '',
                'ABSENCE NEVER ESTABLISHES ANYTHING. "I do not know", "we have not decided", ' +
                '"that is still being worked out", a deferral, or a question left unanswered ' +
                'are all ' + DOES_NOT + ' at most, and usually ' + INSUFFICIENT + '. They ' +
                'are never ' + ESTABLISHES + '.',
                '',
                'ONE ASSENT DOES NOT CARRY A COMPOUND ANTECEDENT. If the span is a "yes" to a ' +
                'question containing three things, it establishes one thing at most and you ' +
                'should not credit the other two.',
                '',
                'PLANS ARE NOT EVENTS. "We will have budget approved next month" establishes ' +
                'a stated intention and does not establish approved budget. If the ' +
                'proposition asks for the event, the answer is ' + DOES_NOT + '.',
                '',
                'JUDGE SUBSTANCE, NOT STANDING. You are told which speaker the proposition ' +
                'would require so you can see whose words these are. You must not lower a ' +
                'verdict because of who spoke. Whether that person was entitled to establish ' +
                'it is decided after you, by machinery you cannot see, and if you pre-apply ' +
                'it the machinery has nothing left to catch.',
                '',
                'DO NOT REACH. If you find yourself explaining what the speaker must have ' +
                'meant, or filling in what the span implies, the answer is ' + DOES_NOT + '. ' +
                'The measured failure of this system is over-reading, never invention.'
            },
            '\n'
        );
    }

    // ==================================================================== user content

    public static String content(List<BindItem> items) {
        List<String> out = new List<String>();
        for (BindItem b : items) {
            out.add('ITEM ' + b.id);
            out.add('Proposition: ' + b.propositionText);
            out.add(
                'Subject: ' +
                (String.isBlank(b.subjectDisplay) ? 'the deal' : b.subjectDisplay)
            );
            out.add(
                'Spoken by: ' +
                (String.isBlank(b.speaker) ? 'unattributed' : b.speaker) +
                '. Requirement, for identification only: ' +
                (String.isBlank(b.speakerRequirement) ? 'unspecified' : b.speakerRequirement)
            );
            out.add('Span, verbatim: "' + b.span + '"');
            out.add('');
        }
        return String.join(out, '\n');
    }

    // ========================================================================= parsing

    public static Map<String, Binding> parse(String jsonText, Set<String> knownIds) {
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new CharterException(
                'The bind charter returned something that is not JSON. First 300 ' +
                'characters: ' + jsonText.abbreviate(300)
            );
        }
        Object raw = root.get('bindings');
        if (!(raw instanceof List<Object>)) {
            throw new CharterException(
                'The bind charter returned JSON with no bindings array. Keys present: ' +
                String.join(new List<String>(root.keySet()), ', ')
            );
        }

        Map<String, Binding> out = new Map<String, Binding>();
        for (Object bo : (List<Object>) raw) {
            Map<String, Object> m = (Map<String, Object>) bo;
            String id = (String) m.get('id');
            // An answer to an item we did not send is dropped rather than trusted. It has
            // nowhere to go: the contract and the subject live on the item, not the answer.
            if (id == null || !knownIds.contains(id)) {
                continue;
            }
            Binding b = new Binding();
            b.id = id;
            b.verdict = (String) m.get('verdict');
            b.reason = (String) m.get('reason');
            out.put(id, b);
        }
        return out;
    }
}
