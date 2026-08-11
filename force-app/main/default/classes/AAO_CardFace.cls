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
    private static final Integer MAX_CHARS = 120;

    @TestVisible
    private static Map<String, String> stubbed;

    /**
     * Pair ref to one-line face. Refs absent from the map fall back to the caller's own rule.
     */
    public static Map<String, String> infer(List<AAO_Pair__c> pairs) {
        Map<String, String> out = new Map<String, String>();
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
            block.add(p.AAO_Pair_Ref__c + ' [' + type + ']: "' + words + '"');
            props.put(p.AAO_Pair_Ref__c, new Map<String, Object>{
                'type' => 'string',
                'description' => 'One line, at most ' + MAX_CHARS +
                    ' characters, summarising ' + p.AAO_Pair_Ref__c + '.'
            });
            required.add(p.AAO_Pair_Ref__c);
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
                String face = String.valueOf(parsed.get(ref));
                if (String.isNotBlank(face)) {
                    out.put(ref, trim(face));
                }
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
    private static String trim(String face) {
        String f = face.trim().replaceAll('\\s+', ' ');
        if (f.length() <= MAX_CHARS) {
            return f;
        }
        Integer cut = f.substring(0, MAX_CHARS).lastIndexOf(' ');
        String bounded = cut > 40 ? f.substring(0, cut) : f.substring(0, MAX_CHARS);
        return bounded.trim().removeEnd(',').removeEnd(';');
    }

    @TestVisible
    private static String systemPrompt() {
        return 'You write the one-line face of an insight card for a seller reading a deal ' +
            'board.\n\n' +
            'You are given established insights, each with a REF, a TYPE already decided, and ' +
            'the buyer\'s VERBATIM WORDS. For each ref, return ONE LINE that says what that ' +
            'person conveyed, in their own terms, understandable at a glance.\n\n' +
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
            '5. One sentence or less, at most ' + MAX_CHARS + ' characters, no trailing ' +
            'ellipsis, and never a fragment that stops mid-thought.\n' +
            '6. No quotation marks, no speaker name, no date. The verbatim and the citation are ' +
            'carried on the card already; repeating them on the face wastes the only line the ' +
            'reader is guaranteed to see.\n\n' +
            'Return one line per ref, for every ref given.';
    }
}
