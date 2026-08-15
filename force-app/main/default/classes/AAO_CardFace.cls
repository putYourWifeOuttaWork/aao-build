/**
 * THE INFERRED CARD FACE. One line per established insight, written by the machine.
 *
 * Matthew's clarification, recorded at the forty-sixth stamp and made a queue item at the
 * forty-ninth: the card's face is *"an inferred, above-the-fold short summary written by the
 * machine, one sentence or less, while the details and citations live in the detail fields."*
 * The first writer put the VERBATIM on the face, which is why a card on the live board ended
 * mid-sentence at "what's the PC way to say it?".
 *
 * **THIS IS A SUMMARY, NEVER A JUDGMENT, and the prompt says so in those words.** The type is
 * already decided by the contract and upheld by call 3; nothing here may re-open it, soften it,
 * add a fact the words do not carry, or drop one they do. The verbatim is untouched and travels
 * to `ALTF__Long_Description__c`, so the face can always be checked against what was said.
 *
 * It runs on the CONFIGURED VERIFY MODEL because this is a small, low-inference rewriting job of
 * exactly the kind that model is there for, and it buys no thinking. It is one batched call for
 * a whole deal's harvest rather than one per card. A failure here is NOT fatal: the caller falls
 * back to the deterministic first-sentence face, because a readable card with a blunt face beats
 * no card at all.
 */
public with sharing class AAO_CardFace {
    /** Kept small: a face that runs long stops being scannable, which is its whole job. */
    /**
     * THE FACE IS A SHORTENED CLAUSE, NOT A SENTENCE. Matthew's grade on the live board: the
     * third Goal's headline was "TOO LONG (the whole sentence instead of a shortened version)",
     * and his shape for it is "Ideal state: 2-3 large key accounts per person". Hard-capped so a
     * card scans at a glance; everything the clause drops is one layer down in the details.
     */
    private static final Integer MAX_CHARS = 60;
    /** The inferred summary that opens the details. Room for a thought, not a paragraph. */
    private static final Integer SUMMARY_CHARS = 240;

    /** What the model wrote for one card: the clause on the face, the meaning below it. */
    public class Face {
        public String face;
        public String summary;
    }

    @TestVisible
    private static Map<String, Face> stubbed;

    /**
     * Pair ref to one-line face. Refs absent from the map fall back to the caller's own rule.
     */
    public static Map<String, Face> infer(List<AAO_Pair__c> pairs) {
        Map<String, Face> out = new Map<String, Face>();
        if (stubbed != null) {
            return stubbed;
        }
        if (pairs == null || pairs.isEmpty()) {
            return out;
        }

        List<String> block = new List<String>();
        Map<String, Object> props = new Map<String, Object>();
        List<String> required = new List<String>();
        for (AAO_Pair__c p : pairs) {
            String words = p.AAO_Located_Pair__r == null
                ? null
                : p.AAO_Located_Pair__r.AAO_Answer_Text__c;
            if (String.isBlank(words) || String.isBlank(p.AAO_Pair_Ref__c)) {
                continue;
            }
            String type = AAO_P8Codes.problemType(
                p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            );
            if (type == null) {
                continue;
            }
            // KEYED BY THE PAIR'S ID, NOT ITS REF, AND THE DISTINCTION IS THE WHOLE DEFECT.
            //
            // `AAO_Pair_Ref__c` is unique WITHIN A RUN - `r1q2` is read 1's second pair, and
            // every run on a deal has one. The caller scopes by OPPORTUNITY across every run,
            // so on a stacked deal s3's `r1q2`, s4's `r1q2` and s5's `r1q2` all arrive here.
            //
            // What that did, on the Wells Fargo stack: `required` is a List, so the refs
            // duplicated and the gateway refused the whole call with `has non-unique elements`;
            // the fallback then wrote raw verbatim onto twelve card faces and Matthew graded
            // them unusable off the live map. **The 400 was the lucky half.** `props` is a Map,
            // so a colliding ref SILENTLY OVERWROTE the earlier pair's words, and `out` is
            // keyed the same way, so a face would have been attributed to the wrong card with
            // nothing to catch it. A refused call is visible; a wrong face is not.
            //
            // The Id is unique per deal, per org, forever, so no ref can collide however many
            // calls stack up. Nothing else about the shape changes.
            String key = p.Id;
            block.add(key + ' [' + type + ']: "' + words + '"');
            props.put(key, new Map<String, Object>{
                'type' => 'object',
                'properties' => new Map<String, Object>{
                    'face' => new Map<String, Object>{
                        'type' => 'string',
                        'description' => 'A shortened CLAUSE, at most ' + MAX_CHARS +
                            ' characters, not a full sentence.'
                    },
                    'summary' => new Map<String, Object>{
                        'type' => 'string',
                        'description' => 'One or two sentences saying what the clause means, ' +
                            'at most ' + SUMMARY_CHARS + ' characters.'
                    }
                },
                'required' => new List<String>{ 'face', 'summary' },
                'additionalProperties' => false
            });
            required.add(key);
        }
        if (required.isEmpty()) {
            return out;
        }

        Map<String, Object> schema = new Map<String, Object>{
            'type' => 'object',
            'properties' => props,
            'required' => required,
            'additionalProperties' => false
        };

        AAO_Extract.Config cfg = AAO_Extract.config();
        AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
        spec.stage = 'card_face';
        spec.charter = 'AAO_CardFace';
        spec.charterVersion = VERSION;
        spec.model = cfg.verifyModel;
        // No thinking bought, for the reason call 3 buys none: this is a low-inference rewrite.
        spec.effort = null;
        spec.temperature = cfg.verifyTemperature;

        try {
            AAO_Extract.StageResult r = AAO_Extract.callStage(
                spec, systemPrompt(), new List<String>{ String.join(block, '\n') }, schema
            );
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(r.rawText);
            for (String ref : parsed.keySet()) {
                Map<String, Object> got = (Map<String, Object>) parsed.get(ref);
                if (got == null) {
                    continue;
                }
                String faceText = String.valueOf(got.get('face'));
                if (String.isBlank(faceText)) {
                    continue;
                }
                Face f = new Face();
                f.face = trim(faceText, MAX_CHARS);
                f.summary = got.get('summary') == null
                    ? null
                    : trim(String.valueOf(got.get('summary')), SUMMARY_CHARS);
                out.put(ref, f);
            }
        } catch (Exception e) {
            // Not fatal, deliberately. The caller has a deterministic fallback, and a deal whose
            // cards all carry blunt faces is a worse board than this one and a far better board
            // than an empty one.
            System.debug(LoggingLevel.WARN, 'Card faces not inferred: ' + e.getMessage());
        }
        return out;
    }

    public static final String VERSION = 'cardface-1.0.0';

    /**
     * Bound the face WITHOUT an ellipsis, cutting at a word boundary.
     *
     * `abbreviate` was the obvious call and it appends "...", which is the one thing the prompt
     * above explicitly forbids: a trailing ellipsis on the face advertises that the reader is
     * missing something, on the single line they are guaranteed to read, when the full words are
     * already one field away. Overlong faces are rare (the model is told the bound) and this
     * degrades them to a clean short line rather than a visibly clipped one.
     */
    @TestVisible
    private static String trim(String face, Integer bound) {
        String f = face.trim().replaceAll('\\s+', ' ');
        if (f.length() <= bound) {
            return f;
        }
        Integer cut = f.substring(0, bound).lastIndexOf(' ');
        String bounded = cut > (bound / 3) ? f.substring(0, cut) : f.substring(0, bound);
        return bounded.trim().removeEnd(',').removeEnd(';');
    }

    @TestVisible
    private static String systemPrompt() {
        return 'You write the one-line face of an insight card for a seller reading a deal ' +
            'board.\n\n' +
            'You are given established insights, each with a REF, a TYPE already decided, and ' +
            'the buyer\'s VERBATIM WORDS. For each ref return TWO things:\n' +
            '  face    - a SHORTENED CLAUSE, at most ' + MAX_CHARS + ' characters, that a ' +
            'seller can read at a glance. NOT the whole sentence. Shape it like ' +
            '"Ideal state: 2-3 large key accounts per person" or "Silos across manufacturing ' +
            'networks": a label for the thing, not a retelling of it.\n' +
            '  summary - one or two sentences saying what that clause MEANS, at most ' +
            SUMMARY_CHARS + ' characters, in their terms.\n\n' +
            'RULES, each of which matters more than fluency:\n' +
            '1. SUMMARISE, NEVER JUDGE. The type is already settled and is not yours to ' +
            'revisit, soften, strengthen or re-label.\n' +
            '2. ADD NOTHING. If the words do not carry a number, a name, a date or a cause, ' +
            'your line does not either. Inventing detail here is the one failure that cannot ' +
            'be caught downstream, because the face is what a seller reads and believes.\n' +
            '3. DROP NOTHING LOAD-BEARING. If the words name what is wanted, what pushes, what ' +
            'is underway or what blocks, that belongs on the line.\n' +
            '4. Their terms, not ours. No vendor vocabulary, no coaching, no advice, no ' +
            'recommendation.\n' +
            '5. The face is a CLAUSE and is hard-capped; a face that runs to a full ' +
            'sentence has failed even if every word is true. No trailing ellipsis.\n' +
            '6. No quotation marks, no speaker name, no date. The verbatim and the citation are ' +
            'carried on the card already; repeating them on the face wastes the only line the ' +
            'reader is guaranteed to see.\n\n' +
            'Return one line per ref, for every ref given.';
    }
}