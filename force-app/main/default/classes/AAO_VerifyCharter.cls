/**
 * STAGE 3 of the Extract-Bind-Verify pass (Charters v2.4 §P7.3). The blind reader.
 *
 * Sees a claim and the span offered for it. Nothing else: not the transcript, not the binder's
 * verdict, not the binder's reason, not any other claim. **The blindness is a property of the
 * signature rather than a promise in the prompt** — there is no parameter here that a verdict
 * could arrive through, which is the same structural argument the previous blind reader was
 * built on and the one thing about it worth carrying forward unchanged.
 *
 * It runs on a SEPARATE MODEL from the binder, and on the SMALLEST MODEL AVAILABLE THROUGH THE
 * CURRENT CREDENTIAL, both ruled 3 August. Which model that is was measured rather than
 * assumed, from this runtime, and is recorded in BUILD_JOURNAL beside the run it produced.
 *
 * **It is gated, not trusted.** The ruling attaches a quality gate: one adjudicated comparison
 * against the strong model on the same claim set before the small model is believed, and a
 * size-up if it passes over-reads the strong model catches. Until that comparison exists,
 * every rejection this reader makes is a number in a report and not yet a proven catch. The
 * count it produces — the verification-rejection count — is the whole argument for its
 * existence, which is why it is reported per stage and not buried in a total.
 *
 * WHAT IT CHECKS: coextension, on three axes, because those are where Gate 1's measured
 * failure mode lived. Same subject. Same scope. Same quantity. A span that says less than the
 * claim is an over-read even when everything in it is true.
 */
public class AAO_VerifyCharter {
    public class CharterException extends Exception {
    }

    /** Which axis failed, so a rejection is legible without re-reading the span. */
    public static final String AXIS_SUBJECT = 'subject';
    public static final String AXIS_SCOPE = 'scope';
    public static final String AXIS_QUANTITY = 'quantity';
    public static final String AXIS_NONE = 'none';

    // ============================================================================= input

    public class VerifyItem {
        public String id;
        public String claimText;
        public String subjectDisplay;
        public String span;
        /** Carried for the writer. Never sent to the model. */
        public String bindItemId;
    }

    // ============================================================================ output

    public class Verdict {
        public String id;
        public Boolean coextensive;
        public String axis;
        public String reason;
    }

    // =========================================================================== schema

    public static Map<String, Object> schema(List<VerifyItem> items) {
        List<String> ids = new List<String>();
        for (VerifyItem v : items) {
            ids.add(v.id);
        }

        Map<String, Object> verdictSchema = new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'id' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => ids
                },
                'coextensive' => new Map<String, Object>{
                    'type' => 'boolean',
                    'description' => 'true only where the span says exactly what the claim ' +
                        'says: same subject, same scope, same quantity. false where the span ' +
                        'says less, says it about someone else, or needs anything the span ' +
                        'does not contain.'
                },
                'axis' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => new List<String>{
                        AXIS_SUBJECT,
                        AXIS_SCOPE,
                        AXIS_QUANTITY,
                        AXIS_NONE
                    },
                    'description' => 'Which axis failed. "' + AXIS_NONE + '" when ' +
                        'coextensive is true.'
                },
                'reason' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'Under 40 words. Where you answer false, name what the ' +
                        'claim asserts that the span does not.'
                }
            },
            'required' => new List<String>{ 'id', 'coextensive', 'axis', 'reason' },
            'additionalProperties' => false
        };

        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'verdicts' => new Map<String, Object>{
                    'type' => 'array',
                    'items' => verdictSchema,
                    'description' => 'Exactly one entry per item given.'
                }
            },
            'required' => new List<String>{ 'verdicts' },
            'additionalProperties' => false
        };
    }

    // ==================================================================== system prompt

    public static String systemPrompt() {
        return String.join(
            new List<String>{
                'You check whether a quoted span is COEXTENSIVE with a claim: whether it says ' +
                'exactly that, no more and no less.',
                '',
                'You see the claim and the span. You do not see the transcript, the ' +
                'conversation around the span, who decided this claim, or why they decided ' +
                'it. You are not reviewing anybody\'s reasoning; you are reading two pieces ' +
                'of text and answering whether the second carries the first.',
                '',
                'THREE AXES, IN THIS ORDER.',
                '',
                'SUBJECT. Is the span about the person the claim is about? A span about a ' +
                'colleague, a team, or the room is not about this person, however similar the ' +
                'sentiment. This is the most common failure and it is the first thing to check.',
                '',
                'SCOPE. Does the span cover what the claim covers? One team is not the ' +
                'organisation. One deal is not the account. One quarter is not the year. A ' +
                'narrower span does not establish a wider claim.',
                '',
                'QUANTITY. Does the span assert as much as the claim asserts? "I like it" is ' +
                'not "committed to it". "We are looking at options" is not "has selected". ' +
                '"I will raise it" is not "has approved it". A softer span does not establish ' +
                'a harder claim.',
                '',
                'ANSWER FALSE WHEN YOU HAVE TO EXPLAIN. If making the span carry the claim ' +
                'takes a sentence beginning "well, presumably" or "in context this means", ' +
                'the answer is false. The span will be stored and shown as the evidence for ' +
                'this claim, and a reader will have only these words. If the words do not ' +
                'say it, it is not established.',
                '',
                'ANSWER TRUE WITHOUT HEDGING WHERE THE WORDS PLAINLY SAY IT. You are not here ' +
                'to raise the bar. A span that states the claim in ordinary language is ' +
                'coextensive even if it is casual, ungrammatical or brief.',
                '',
                'Do not consider whether the speaker was entitled to say it. That is decided ' +
                'elsewhere. Only whether these words carry this claim.'
            },
            '\n'
        );
    }

    // ==================================================================== user content

    public static String content(List<VerifyItem> items) {
        List<String> out = new List<String>();
        for (VerifyItem v : items) {
            out.add('ITEM ' + v.id);
            out.add(
                'Claim: ' +
                (String.isBlank(v.subjectDisplay) ? '' : v.subjectDisplay + ' — ') +
                v.claimText
            );
            out.add('Evidence offered, verbatim: "' + v.span + '"');
            out.add('');
        }
        return String.join(out, '\n');
    }

    // ========================================================================= parsing

    public static Map<String, Verdict> parse(String jsonText, Set<String> knownIds) {
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new CharterException(
                'The verify charter returned something that is not JSON. First 300 ' +
                'characters: ' + jsonText.abbreviate(300)
            );
        }
        Object raw = root.get('verdicts');
        if (!(raw instanceof List<Object>)) {
            throw new CharterException(
                'The verify charter returned JSON with no verdicts array. Keys present: ' +
                String.join(new List<String>(root.keySet()), ', ')
            );
        }

        Map<String, Verdict> out = new Map<String, Verdict>();
        for (Object vo : (List<Object>) raw) {
            Map<String, Object> m = (Map<String, Object>) vo;
            String id = (String) m.get('id');
            if (id == null || !knownIds.contains(id)) {
                continue;
            }
            Verdict v = new Verdict();
            v.id = id;
            Object c = m.get('coextensive');
            v.coextensive = c instanceof Boolean ? (Boolean) c : false;
            v.axis = (String) m.get('axis');
            v.reason = (String) m.get('reason');
            out.put(id, v);
        }
        return out;
    }
}
