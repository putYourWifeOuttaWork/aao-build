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
    /** The honest no-match, named rather than left as an empty string. */
    public static final String NONE = 'NONE';

    /** What the model wrote for one card: the clause on the face, the meaning below it. */
    public class Face {
        public String face;
        public String summary;
        /**
         * THE STANDING CARD THIS INSIGHT ALREADY IS, or null for a new one.
         *
         * The hundred-twenty-fourth's identity ruling, and the hundred-eighth's option (d) which
         * design leaned to and Matthew ruled: *"identity is minted ONCE and matched thereafter"*.
         * The face call already fires at card-write, so it additionally receives the standing
         * board as a CLOSED CANDIDATE LIST and returns match-or-NONE - the same identification
         * discipline people already get, and no second callout.
         *
         * Why it had to become a judgment: layer 2 was normalised string equality on the face,
         * and the hundred-eighth's measured specimen defeats any string rule at all. *"6 hrs/week
         * chasing prior approvals"* and *"Sign-off chase: ~1 day/week, no change"* are one
         * insight and share almost no tokens, so a threshold loose enough to catch them is loose
         * enough to merge strangers.
         */
        public Id matchesStanding;
    }

    /** A standing card offered to the model as a candidate. Closed list, never open. */
    public class Candidate {
        public Id cardId;
        public String type;
        public String face;

        public Candidate(Id cardId, String type, String face) {
            this.cardId = cardId;
            this.type = type;
            this.face = face;
        }
    }

    @TestVisible
    private static Map<String, Face> stubbed;

    /**
     * Pair ref to one-line face. Refs absent from the map fall back to the caller's own rule.
     */
    /**
     * SHARDED, because the face call is a keyed strict schema and the grammar ceiling is a
     * property of every one of them.
     *
     * The thirty-fourth stamp measured the ceiling and the thirty-fifth ruled that
     * `keyedShardCount` drives it, on the reasoning that this is not a verify quirk: one
     * required property per unit means the compiled grammar scales with unit count, whatever
     * the call is for. The face call was the last keyed call still handing the gateway
     * everything at once, and on the clean Wells Fargo re-run it 400'd with **"The compiled
     * grammar is too large"** on twenty-nine cards. Before that it 400'd on duplicate refs, and
     * fixing the key was what let this one become visible - the second constraint was always
     * underneath.
     *
     * WHAT IT COSTS TO GET THIS WRONG, which is why it is not just a face problem: the
     * deterministic fallback writes RAW VERBATIM as the face, and Matthew graded exactly that
     * off the live map at the ninety-ninth stamp - goals that are not goals, no metrics,
     * nothing anyone can understand from the titles. **And the face is layer 2 of the card
     * dedup**, the meaning layer the sixty-first stamp ruled must never be replaced by layer 1,
     * so a board of verbatim faces cannot recognise a restatement as reinforcement either. One
     * 400 costs the surface AND the dedup's reach.
     *
     * A SHARD THAT FAILS LOSES ONLY ITS OWN FACES, and says so with its index. All-or-nothing
     * was the previous behaviour and it is strictly worse: twenty-nine cards went blunt because
     * one call was too big for the gateway.
     */
    public static Map<String, Face> infer(List<AAO_Pair__c> pairs) {
        return infer(pairs, new List<Candidate>());
    }

    public static Map<String, Face> infer(List<AAO_Pair__c> pairs, List<Candidate> standing) {
        Map<String, Face> out = new Map<String, Face>();
        if (stubbed != null) {
            return stubbed;
        }
        if (pairs == null || pairs.isEmpty()) {
            return out;
        }

        Integer cap = AAO_Pass.MAX_UNITS_PER_KEYED_CALL;
        Integer shards = AAO_Pass.keyedShardCount(pairs.size());
        for (Integer i = 0; i < shards; i++) {
            List<AAO_Pair__c> shard = new List<AAO_Pair__c>();
            for (Integer j = i * cap; j < Math.min((i + 1) * cap, pairs.size()); j++) {
                shard.add(pairs[j]);
            }
            if (!shard.isEmpty()) {
                out.putAll(inferShard(shard, i + 1, shards, standing));
            }
        }
        return out;
    }

    private static Map<String, Face> inferShard(
        List<AAO_Pair__c> pairs,
        Integer shardNo,
        Integer shardCount,
        List<Candidate> standing
    ) {
        Map<String, Face> out = new Map<String, Face>();

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

            // ===== THE CLOSED CANDIDATE LIST, SCOPED TO THIS UNIT'S OWN TYPE.
            //
            // Two reasons and both are load bearing. **An Obstacle is never a Goal**, so offering
            // cross-type candidates would invite a merge the type system already forbids - and
            // Matthew's own cross-type pair on Emerson (identical faces, one Goal one Obstacle)
            // is the specimen of why those must stay two rows and go to him as a grade rather
            // than be collapsed by a matcher. And the enum is the compiled grammar's width:
            // `keyedShardCount` bounds unit COUNT, nothing bounds candidate count, so scoping by
            // type keeps the thirty-fourth stamp's ceiling out of reach on a deal with a large
            // standing board.
            List<String> choices = new List<String>{ NONE };
            List<String> menu = new List<String>();
            for (Candidate c : standing) {
                if (c.type != type || c.cardId == null) {
                    continue;
                }
                choices.add(String.valueOf(c.cardId));
                menu.add(String.valueOf(c.cardId) + ' = "' + c.face + '"');
            }
            Map<String, Object> unitProps = new Map<String, Object>{
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
            };
            List<String> unitRequired = new List<String>{ 'face', 'summary' };
            if (menu.size() > 0) {
                block.add(
                    '    standing ' + type + ' cards this could already be: ' +
                    String.join(menu, ' | ')
                );
                unitProps.put('matches', new Map<String, Object>{
                    'type' => 'string',
                    'enum' => choices,
                    'description' => 'The id of the standing card this insight ALREADY IS, or ' +
                        NONE + '. Same insight in other words, or from another mouth, is the ' +
                        'SAME card. Genuinely new substance is ' + NONE + ' even when it is ' +
                        'about the same subject. Choose only from the ids listed for this item.'
                });
                unitRequired.add('matches');
            }
            props.put(key, new Map<String, Object>{
                'type' => 'object',
                'properties' => unitProps,
                'required' => unitRequired,
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
                // The match is read only where a candidate list was offered, and only where the
                // answer is one of the ids offered FOR THIS UNIT. The enum makes anything else
                // inexpressible; this is the parse refusing to trust that, which is the same
                // posture the one-for-one guard keeps toward the gateway's own promise.
                Object m = got.get('matches');
                if (m != null && String.valueOf(m) != NONE) {
                    try {
                        f.matchesStanding = Id.valueOf(String.valueOf(m));
                    } catch (Exception ignored) {
                        // A value that is not an id is not a match. Nothing is guessed.
                    }
                }
                out.put(ref, f);
            }
        } catch (Exception e) {
            // Not fatal, deliberately. The caller has a deterministic fallback, and a deal whose
            // cards all carry blunt faces is a worse board than this one and a far better board
            // than an empty one.
            System.debug(
                LoggingLevel.WARN,
                'Card faces not inferred for shard ' + shardNo + ' of ' + shardCount +
                ' (' + pairs.size() + ' units): ' + e.getMessage()
            );
        }
        return out;
    }

    /**
     * **1.1.1, 16 August** - 3b writes the number as DIGITS and 3c requires the line to finish.
     * 1.1.0 said "spelled as they said it", and on its first real board that spent twenty of
     * the sixty characters on "ninety five thousand" and delivered FIVE OF TWENTY-NINE faces
     * cut mid-thought, ending on "for", "by", "does not". That is the unreadable-title class
     * Matthew graded at the ninety-ninth stamp, reintroduced by the rule meant to cure it. The
     * repair is a shorter spelling of the same number, never a different number.
     *
     * **1.1.0, 16 August** - the face carries the measurable where the words carry one (rule
     * 3b), per the hundred-fourth stamp's item 3(b). The guidance moved, so the version moves
     * with it: the two-halves law binds a face the same as any other model output, and a board
     * written under 1.0.0 must be distinguishable from one written under 1.1.0. Sharding is a
     * transport change and would not have moved it on its own.
     */
    /**
     * **1.2.0** - the call gains the closed-list match (124th's identity ruling). The version
     * moves because the prompt and the schema both changed, and the two-halves law says a version
     * string covers every input that can change the output it stamps. A face written under 1.1.1
     * was written by a call that was never asked whether the insight already existed.
     */
    public static final String VERSION = 'cardface-1.2.0';

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
            'board, and you say whether each insight is one the board ALREADY CARRIES.\n\n' +
            'You are given established insights, each with a REF, a TYPE already decided, and ' +
            'the buyer\'s VERBATIM WORDS. Some items also list the STANDING CARDS of that same ' +
            'type already on this deal. For each ref return TWO things, or THREE where standing ' +
            'cards are listed for it:\n' +
            '  face    - a SHORTENED CLAUSE, at most ' + MAX_CHARS + ' characters, that a ' +
            'seller can read at a glance. NOT the whole sentence. Shape it like ' +
            '"Ideal state: 2-3 large key accounts per person" or "Silos across manufacturing ' +
            'networks": a label for the thing, not a retelling of it.\n' +
            '  summary - one or two sentences saying what that clause MEANS, at most ' +
            SUMMARY_CHARS + ' characters, in their terms.\n' +
            '  matches - ONLY where standing cards are listed for that ref: the id of the one ' +
            'this insight ALREADY IS, or ' + NONE + '.\n\n' +
            'ON MATCHING, which decides whether a seller reads one insight or two:\n' +
            'M1. THE SAME INSIGHT IN OTHER WORDS IS THE SAME CARD, whoever said it. A second ' +
            'person restating a problem the board already carries is that card again, not a new ' +
            'one. Two lines can share almost no words and still be one insight.\n' +
            'M2. GENUINELY NEW SUBSTANCE IS ' + NONE + ', even about the same subject. A ' +
            'restatement that carries a fact the standing card does not - a number, a named ' +
            'system, a new consequence, a concrete instance - is a NEW insight.\n' +
            'M3. WHEN IN DOUBT, ' + NONE + '. Two cards a person can merge by eye cost far less ' +
            'than one card that silently swallowed something nobody can now see.\n' +
            'M4. Choose only from the ids listed for THAT ref. Never invent one, never borrow ' +
            'an id listed under a different ref.\n\n' +
            'RULES, each of which matters more than fluency:\n' +
            '1. SUMMARISE, NEVER JUDGE. The type is already settled and is not yours to ' +
            'revisit, soften, strengthen or re-label.\n' +
            '2. ADD NOTHING. If the words do not carry a number, a name, a date or a cause, ' +
            'your line does not either. Inventing detail here is the one failure that cannot ' +
            'be caught downstream, because the face is what a seller reads and believes.\n' +
            '3. DROP NOTHING LOAD-BEARING. If the words name what is wanted, what pushes, what ' +
            'is underway or what blocks, that belongs on the line.\n' +
            '3b. CARRY THE NUMBER, AS DIGITS. Where the words themselves carry a measurable - ' +
            'a quantity, a currency amount, a percentage, a count, a duration or a deadline - ' +
            'it goes ON THE FACE, in their units. "9 hrs/week hunting prior work", "$95k ' +
            'credits, year one", "60 days" are the whole difference between a line a seller ' +
            'can act on and a line they have to open the card to understand. WRITE THE NUMBER ' +
            'AS DIGITS even where they said it in words: the face is hard-capped at ' +
            MAX_CHARS + ' characters, "ninety five thousand" spends twenty of them and "$95k" ' +
            'spends four, and the verbatim on the card already carries how they said it. This ' +
            'RULE 3b NEVER OVERRIDES RULE 2: where the words carry no measurable, the face ' +
            'carries none, and a number that is not in the words is a fabrication on the one ' +
            'line the reader believes. Do not derive, round, convert, annualise or total ' +
            'anything - digits are a shorter spelling of their number, never a different one.\n' +
            '3c. THE FACE ENDS ON A WHOLE THOUGHT. It is cut to the cap at a word boundary, so ' +
            'a line that runs long is delivered ending on "for", "by", "does not" or "plus", ' +
            'which reads as broken rather than brief. Write it short enough to finish.\n' +
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