/**
 * CALL 1 of the §P8 pass: LOCATE AND PAIR. Charters v2.8 §P8.1, calibrated by §P8.9.
 *
 * One read of the whole artifact. Output is question-answer PAIRS: a question from the
 * declared set, the verbatim words that answer it, and the meaning those words voice.
 * **No person is ever attached.** Who said it is call 2's job; whether the words carry it
 * is call 3's.
 *
 * WHAT THIS CHARTER MUST NOT DO, each structural rather than requested.
 *
 * 1. NO PERSON, ANYWHERE. There is no person field in the schema, so call 1 cannot name
 *    one. This is the prohibition law, and it is the same move `AAO_Pair__c` makes at the
 *    database: a charter instruction is a request, a missing field is a refusal.
 *
 * 2. NO FALSE, NO INVERSION, NO TWO-SIDED VERDICT. Every declared proposition points one
 *    way. Words either voice it or produce nothing. This is not a style rule: the 24 June
 *    run refused four claims on the two-sided `PS4`/`PO2` CORRECTLY and destroyed the
 *    placement the words supported, because one contract had no slot for the weak side.
 *
 * 3. NO SILENCE. A question nobody answered produces no pair, no row and no model thought.
 *    There is nothing to write about what was not said.
 *
 * §P8.9, THE FIRST CALIBRATION, AND WHY IT IS IN THIS CLASS RATHER THAN A LATER ONE.
 *
 * The 17 June review CSV was graded twice before any model ran: by design under every guard
 * this build carries, and by Matthew as the standard. **Every disagreement ran the same
 * direction — the guarded reader established LESS than the grader. Not one over-read.** A
 * reader holding all the guards lands too conservative to be useful, and a model holding
 * them will too. All four rulings bind call 1's instructions, so they are written into the
 * prompt below rather than compensated for downstream:
 *
 * - **The content of the call, never the title, in both directions.** Half was always law:
 *   a role is never inferred from a title. The other half is law now: behaviour on the call
 *   establishes. The guard against titles was never a guard against evidence.
 * - **One quote, several establishments.** Consequential sentences rarely establish exactly
 *   one thing, and picking the single best reading of a rich sentence is under-reading
 *   wearing discipline's clothes. Instructed affirmatively, as ruled.
 * - **Advocacy is never discounted for coming from a professional.** The neutral
 *   disposition guards against pleasantries, never against a buyer coaching the seller
 *   through her own organization's process. The guard as written was eating the most
 *   load-bearing sentiment evidence a call carries.
 * - **The families are not equally heavy.** Support, Political Status and Buyer Role are
 *   the product; criteria are sparse by nature and expected empty on most calls.
 *
 * **This is a direct reversal of `AAO_InventoryCharter` 1.1.0's `ONE STATEMENT, ONE ITEM`
 * rule**, which said one sentence bearing on three families is one item. Under §P8.9 it is
 * three pairs. Recorded here because the two charters would otherwise read as disagreeing
 * by accident rather than by ruling.
 */
public with sharing class AAO_LocateCharter {
    public class CharterException extends Exception {
    }

    /**
     * Bumped from 2.0.0 on 5 August: the worked example, the second pass, and coverage
     * becoming required all change what the model reads.
     */
    /**
     * 3.0.0 · THE FAMILY SWEEP, ruled by Matthew 5 August. Call 1 runs once per FAMILY over
     * the whole artifact rather than once per transcript holding all seventeen contracts.
     *
     * The reasoning, recorded because the alternative was cheaper to build: seventeen
     * contracts held against a forty-minute artifact in one read is a capacity problem, and
     * the flicker — 15% recurrence across three 24 June runs, 39% across two Emerson runs — is
     * what capacity exhaustion looks like from outside. A union over N runs would raise recall
     * by paying three times for the same defect and leave output volume run-dependent, and a
     * system whose answer depends on how many times you asked it is not an instrument.
     *
     * **THE COST LAW IS PRESERVED EXACTLY.** It forbids crossing questions BY PERSON, which
     * scales with the roster without bound and is what made the retired shape cost 87,805 ms
     * per person. Crossing by FAMILY is bounded at four and scales with nothing about the
     * call: not roster size, not transcript length, not evidence density. A twelve-person call
     * is still four reads. `AAO_PassTest` fails if that ever stops being true.
     *
     * **The worked example is REMOVED at this version.** It produced imitation rather than
     * generalisation — one quote of seventeen carried two establishments and it was the one in
     * the example, yielding exactly the two pairs the example named. Under the sweep it has
     * nothing left to do: the sentiment read and the political read see the same sentence
     * independently, so multi-establishment across families stops being instructed and becomes
     * structural. The affirmative instruction survives only for the narrower within-family
     * case, which is a real thing that still has to work.
     */
    /**
     * 4.0.0 · TWO COMPREHENSIVE READS, Matthew's ruling, 8 August evening (twenty-seventh
     * stamp), superseding the family sweep as call 1's shape. Each read covers the whole
     * artifact carrying ALL declared families' question sets in one prompt; two reads, not
     * one and not four, because inference drops things and the reads' independent misses are
     * the recall hedge ("let us do 2 comprehensive reads... so as to let the inference
     * differences help each other"). The sweep's own reasoning and its two-to-eleven
     * measurement stand as history: one fixture, priced by the tuned-behaviour law. The cost
     * law survives intact - the read count is TWO and scales with nothing about the call.
     *
     * THE DESIGNATOR ARRIVES AT THIS VERSION TOO (ruled at the twenty-fourth stamp, carried
     * into the read shape by the twenty-seventh): where the words are about a person other
     * than the speaker, the pair carries the name or title AS WRITTEN plus the introducing
     * span quoted - because the reader that holds the whole artifact is the only one that can
     * resolve a pronoun the way a human does, and the quoted introduction is the mitigation
     * for the wrong-referent hazard the byte check cannot catch. No org identity is ever
     * attached; resolution is the next stage's deterministic job.
     */
    /**
     * 3.1.0 · THE CRITERION'S NAME, ruled 8 August (a23, refined at the twenty-seventh stamp).
     * A criterion's identity is its name: a descriptive word or words STATING THE CONDITION
     * THAT MUST BE TRUE FOR THE BUYER TO MAKE THE POSITIVE DECISION, derived from the
     * establishing words. "Annual total cost" is the specimen. Before this version the naming
     * pair's meaning enum was closed at the literal string CRITERION, `mintCriteria` passed
     * that word as the criterion's text, and every criterion in the org collapsed onto one row
     * whose vendor Subject displayed the word CRITERION to the seller. The name is a derived
     * LABEL, deliberately outside the byte check: the verbatim establishing words stay on
     * `answer_text` under the evidence law, and the name is what a buyer would recognise.
     */
    public static final String VERSION = 'locate-4.0.0';

    /**
     * THE FAMILY OF A CONTRACT, from its code. Four families, and the number is bounded by the
     * declared set rather than by anything about the call.
     */
    public static String familyOf(String code) {
        if (code == 'AAO_PS_1') { return 'Sentiment'; }
        if (code.startsWith('AAO_POL_')) { return 'Political Status'; }
        if (code.startsWith('AAO_BR_')) { return 'Buyer Role'; }
        if (code.startsWith('AAO_DC_')) { return 'Decision criteria'; }
        throw new CharterException(
            'Contract ' + code + ' belongs to no family the sweep knows, and it declares no ' +
            'AAO_Family__c. A contract with no family would be silently swept by nobody, so ' +
            'this throws rather than dropping it. THE FIX IS DATA, NOT CODE: set AAO_Family__c ' +
            'on the contract and the pass carries it without an Apex change.'
        );
    }

    /**
     * THE FAMILY THE CONTRACT DECLARES, falling back to the code ladder above.
     *
     * **Adding a family is a data act, not an Apex edit, and until now it was the reverse.**
     * `familyOf(String)` is a hardcoded prefix ladder that THROWS on any code it does not
     * recognise, and `families()` runs it over the whole declared set, so the first Problems or
     * Politics contract minted on the live rubric would not have degraded that one family: it
     * would have failed call 1 outright, for every family at once, before a single read.
     * Preparing the pass to carry added families (forty-first stamp, item iv) is mostly this.
     *
     * The declared value wins where present; blank falls back to the ladder, so the seventeen
     * contracts seeded before this field existed keep their families with nothing migrated in a
     * hurry. The throw survives both paths, because a contract nobody sweeps is still worse than
     * a loud failure, and its message now names the remedy.
     *
     * This is ROUTING and never charter content. It says which read a question travels in; it
     * says nothing about what the question asks, which is the charter's to declare and design's
     * to write.
     */
    public static String familyOf(AAO_Evidence_Contract__c ec) {
        if (ec != null && String.isNotBlank(ec.AAO_Family__c)) {
            return ec.AAO_Family__c.trim();
        }
        return familyOf(ec == null ? null : ec.AAO_Proposition_Code__c);
    }

    /** Declared contracts grouped by family, in a deterministic order. */
    public static Map<String, List<AAO_Evidence_Contract__c>> families(
        List<AAO_Evidence_Contract__c> declared
    ) {
        Map<String, List<AAO_Evidence_Contract__c>> out =
            new Map<String, List<AAO_Evidence_Contract__c>>();
        List<AAO_Evidence_Contract__c> sorted = new List<AAO_Evidence_Contract__c>(declared);
        sorted.sort(new ByCode());
        for (AAO_Evidence_Contract__c ec : sorted) {
            String fam = familyOf(ec);
            if (!out.containsKey(fam)) {
                out.put(fam, new List<AAO_Evidence_Contract__c>());
            }
            out.get(fam).add(ec);
        }
        return out;
    }

    /**
     * THE VERSION THE ROW CARRIES, and it is not this class's version alone.
     *
     * The first Emerson grading raised it as a provenance break and it is a real one. Call 1's
     * prompt is this charter's prose PLUS the declared contracts' own text, so when v2.9's
     * label-meaning fix landed in `AAO_PS_1`'s guidance the prompt changed and
     * `locate-2.0.0` did not. **Same version string, two different prompts** — which makes
     * every stamped row's provenance a claim rather than a fact.
     *
     * The effective version composes the charter version with a fingerprint of the declared
     * set's contract keys, and those keys already carry each contract's content hash. So an
     * edit anywhere in either half moves the string, and it cannot not move.
     */
    public static String effectiveVersion(List<AAO_Evidence_Contract__c> declared) {
        List<String> keys = new List<String>();
        for (AAO_Evidence_Contract__c ec : declared) {
            keys.add(ec.AAO_Contract_Key__c);
        }
        keys.sort();
        String hex = EncodingUtil.convertToHex(
            Crypto.generateDigest('SHA-256', Blob.valueOf(String.join(keys, '|')))
        );
        return VERSION + '+' + hex.substring(0, 8);
    }

    /** Pairs beyond this are dropped by the parser rather than trusted. */
    public static final Integer MAX_PAIRS = 400;

    /** The evidence budget, ruled 3 August: coextension is the reason, never brevity. */
    public static final Integer EVIDENCE_BUDGET_TOKENS = 90;

    // ===================================================================== the meanings

    /**
     * THE MEANING VOCABULARY, RUNTIME-CLOSED PER FAMILY.
     *
     * Most declared propositions point at exactly one meaning, because they point one way:
     * a `AAO_POL_IC2` pair means Inner Circle or it is not a pair. The two that carry real
     * choice are sentiment (four states) and criteria typing (formal or informal), and
     * those are the two where the model is actually deciding something.
     *
     * A single-valued enum is not noise here. It is what makes `meaning` a field the parser
     * can validate against the family, so a MENTOR on a Buyer Role pair is caught as our
     * bug rather than stored as a meaning nobody can read.
     */
    private static final Map<String, List<String>> MEANINGS = new Map<String, List<String>>{
        'AAO_PS_1' => new List<String>{ 'MENTOR', 'SUPPORTER', 'NON_SUPPORTER', 'ENEMY' },
        'AAO_POL_IC1' => new List<String>{ 'INNER_CIRCLE' },
        'AAO_POL_IC2' => new List<String>{ 'INNER_CIRCLE' },
        'AAO_POL_IC3' => new List<String>{ 'INNER_CIRCLE' },
        'AAO_POL_PS1' => new List<String>{ 'POLITICAL_STRUCTURE' },
        'AAO_POL_PS2' => new List<String>{ 'POLITICAL_STRUCTURE' },
        'AAO_POL_PS3' => new List<String>{ 'POLITICAL_STRUCTURE' },
        'AAO_POL_PS4' => new List<String>{ 'POLITICAL_STRUCTURE' },
        'AAO_POL_OPS1' => new List<String>{ 'OUTSIDE_POLITICAL_STRUCTURE' },
        'AAO_BR_APP' => new List<String>{ 'APPROVER' },
        'AAO_BR_DM' => new List<String>{ 'DECISION_MAKER' },
        'AAO_BR_EVAL' => new List<String>{ 'EVALUATOR' },
        'AAO_BR_USER' => new List<String>{ 'USER' },
        'AAO_BR_SIG' => new List<String>{ 'SIGNATURE_APPROVER' },
        'AAO_DC_N' => new List<String>{ 'CRITERION' },
        'AAO_DC_F' => new List<String>{ 'FORMAL', 'INFORMAL' },
        'AAO_DC_R' => new List<String>{ 'REQUIRED' }
    };

    /**
     * SENTIMENT HAS NO PARTIAL (§P8.4). A sentiment read is whole and accumulation is the
     * counter's job; the fact families accrue by coverage instead. Two accrual mechanisms,
     * both receipts-backed, and a coverage value on a sentiment pair is a category error
     * rather than a harmless extra.
     */
    private static final Set<String> NO_COVERAGE = new Set<String>{ 'AAO_PS_1' };

    public static List<String> meaningsFor(String code) {
        List<String> m = MEANINGS.get(code);
        return m == null ? new List<String>() : m;
    }

    /**
     * True where the family's meaning set carries an actual CHOICE.
     *
     * Fifteen of the seventeen allow exactly one meaning, because the propositions point one
     * way — `AAO_POL_IC2` means Inner Circle or it is not a pair. For those, **the meaning IS
     * the placement, and a placement is what a true proposition points at rather than
     * something the words must voice.**
     *
     * That distinction is not academic. It is the defect the first Emerson grading found, and
     * I introduced it hours before it was caught: repairing "the blind reader was never told
     * the meaning" I began handing call 3 the placement string, and call 3 then required the
     * words to voice BOTH the proposition and its placement. Every political refusal joined
     * two clauses with *nor*, and one of them cited `who must approve` — `AAO_POL_PS1`, the
     * OTHER one-way half. **The two-sided test the split was minted to kill, alive at call 3
     * while the schema test correctly reported no two-sided proposition exists.**
     *
     * So this is the gate on what reaches the blind reader: the meaning travels only where it
     * carries information the proposition does not. Sentiment (four states) and criteria
     * typing (formal or informal) do. Nothing else does.
     */
    public static Boolean carriesChoice(String code) {
        return meaningsFor(code).size() > 1;
    }

    public static Boolean takesCoverage(String code) {
        return !NO_COVERAGE.contains(code);
    }

    // ================================================================== what comes back

    public class Pair {
        /** Assigned by the parser. Becomes AAO_Pair__c.AAO_Pair_Ref__c. */
        public String ref;
        public String questionCode;
        public String answerText;
        public String meaning;
        /** Full or Partial on fact families; null on sentiment. */
        public String coverage;
        /** The criterion's name, AAO_DC_N pairs only; null everywhere else. */
        public String criterionName;
        /** The designator, only where the words are about someone other than the speaker. */
        public String aboutWords;
        /** The designator's introducing span, quoted; byte-checked by the locator. */
        public String aboutQuote;

        public override String toString() {
            return ref + ' ' + questionCode + ' ' + meaning +
                (coverage == null ? '' : '/' + coverage) +
                ' "' + (answerText == null ? '' : answerText.abbreviate(50)) + '"';
        }
    }

    /** A person the call talked about. Call 2's closed list is the roster PLUS these. */
    public class Mention {
        public String name;
        public String note;
    }

    /** How many pairs arrived with no coverage and took the default. Should be zero. */
    public static Integer coverageDefaulted = 0;

    public class Result {
        /**
         * What call 1 believes this call is about. **Never trusted and never written**: the
         * Source already carries the deal and the account, and asking a model to re-resolve
         * what the record answers is asking a question the data has. It is collected so a
         * DISAGREEMENT is a finding, which is a different thing from a resolution.
         */
        public String dealSaid;
        public String accountSaid;
        public List<Mention> mentions = new List<Mention>();
        public List<Pair> pairs = new List<Pair>();
        /** Pairs the model returned that the parser refused, with the reason. */
        public List<String> rejected = new List<String>();
    }

    // ======================================================================= the schema

    public static Map<String, Object> schema(List<String> declaredCodes) {
        List<String> codes = new List<String>(declaredCodes);
        codes.sort();

        Set<String> meanings = new Set<String>();
        Boolean anyCoverage = false;
        for (String c : codes) {
            meanings.addAll(meaningsFor(c));
            anyCoverage = anyCoverage || takesCoverage(c);
        }
        List<String> meaningEnum = new List<String>(meanings);
        meaningEnum.sort();

        Map<String, Object> pairProps = new Map<String, Object>{
            'question_code' => new Map<String, Object>{
                'type' => 'string',
                'enum' => codes,
                'description' => 'The declared question these words answer.'
            },
            'answer_text' => new Map<String, Object>{
                'type' => 'string',
                'description' => 'The MINIMAL verbatim substring that answers the question, ' +
                    'character for character from the transcript, including punctuation and ' +
                    'capitalisation. Do not tidy, join, trim, correct or paraphrase, and do ' +
                    'not stitch two turns together. Words that do not match the stored text ' +
                    'exactly are discarded and the pair is lost.'
            },
            'meaning' => new Map<String, Object>{
                'type' => 'string',
                'enum' => meaningEnum,
                'description' => 'The state these words voice, from the set the question ' +
                    'allows. Most questions allow exactly one, because they point one way.'
            }
        };
        if (anyCoverage) {
            pairProps.put('coverage', new Map<String, Object>{
                'type' => 'string',
                'enum' => new List<String>{ 'Full', 'Partial' },
                'description' => 'Full when the words carry every element the question ' +
                    'names, Partial when they carry some. PARTIAL IS THE DEFAULT UNDER ' +
                    'DOUBT: a partial accrues safely. Omit on sentiment, which has no partial.'
            });
        }
        // THE DESIGNATOR, required with an empty-string default like the criterion name and
        // for the coverage lesson's reason: an optional field gets omitted on every pair,
        // and an omitted designator silently reads as self-subject, which on a mentioned
        // person is a wrong attribution nothing downstream can see.
        pairProps.put('about', new Map<String, Object>{
            'type' => 'string',
            'description' => 'EMPTY STRING where the words are about their own speaker, ' +
                'which is the usual case. Where the words are ABOUT A DIFFERENT PERSON, ' +
                'that person\'s name or title EXACTLY AS WRITTEN in the transcript - a ' +
                'misspelt name stays misspelt. Where the words use a pronoun, the name or ' +
                'title the pronoun refers to, found in the surrounding transcript. Never a ' +
                'guess and never a person the transcript does not introduce.'
        });
        pairProps.put('about_quote', new Map<String, Object>{
            'type' => 'string',
            'description' => 'EMPTY STRING when about is empty. Otherwise the verbatim ' +
                'transcript span that INTRODUCES who the person is - the words that let ' +
                'you connect the pair to them. Checked character for character against ' +
                'the stored transcript; a quote that does not match drops the about and ' +
                'the pair falls back to its speaker.'
        });
        Boolean anyNaming = codes.contains('AAO_DC_N');
        if (anyNaming) {
            pairProps.put('criterion_name', new Map<String, Object>{
                'type' => 'string',
                'description' => 'ONLY on an AAO_DC_N pair: the criterion\'s NAME, a short ' +
                    'descriptive phrase stating the condition that must be true for the ' +
                    'buyer to make the positive decision, derived from the quoted words. ' +
                    '"Annual total cost" is the model. Two to six words a buyer would ' +
                    'recognise as their own criterion; never a full sentence, never the ' +
                    'quote repeated. On every other question write an empty string.'
            });
        }

        // COVERAGE IS REQUIRED, changed 5 August. It was optional, the model omitted it on
        // every pair, and the parser's default-to-Partial then wrote Partial 14 of 14 across
        // every family on every quote. **A dimension that emits one value is not reading, it
        // is defaulting** — and because the default was silent, the whole run looked like a
        // reading that happened to be uniformly cautious.
        //
        // Required for every pair including sentiment, where the parser discards it: a
        // per-item conditional requirement is not expressible in one schema, and one wasted
        // enum on a sentiment pair costs less than an unreachable value on the fifteen
        // families where Full is the honest answer.
        List<String> required = new List<String>{
            'question_code', 'answer_text', 'meaning', 'about', 'about_quote'
        };
        if (anyCoverage) {
            required.add('coverage');
        }
        // Required for the same reason coverage is: optional fields get omitted on every
        // pair (the coverage lesson, 5 August). The empty string on non-naming pairs is
        // the same wasted-enum trade the coverage requirement already made on sentiment.
        if (anyNaming) {
            required.add('criterion_name');
        }

        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'deal' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'What this call is about, in the transcript\'s own ' +
                        'words. One short phrase. Say "unclear" rather than guessing.'
                },
                'account' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'The buying organization, as the transcript names it. ' +
                        'Say "unclear" rather than guessing.'
                },
                'mentions' => new Map<String, Object>{
                    'type' => 'array',
                    'description' => 'People the call TALKED ABOUT who did not speak on it. ' +
                        'Names only, as spoken, even where only a first name was used.',
                    'items' => new Map<String, Object>{
                        'type' => 'object',
                        'properties' => new Map<String, Object>{
                            'name' => new Map<String, Object>{ 'type' => 'string' },
                            'note' => new Map<String, Object>{
                                'type' => 'string',
                                'description' => 'What the call said they do. One phrase.'
                            }
                        },
                        'required' => new List<String>{ 'name', 'note' },
                        'additionalProperties' => false
                    }
                },
                'pairs' => new Map<String, Object>{
                    'type' => 'array',
                    'description' => 'One entry per ESTABLISHMENT, not per sentence. A ' +
                        'sentence that answers three questions is three pairs quoting the ' +
                        'same words. A question nobody answered is simply absent.',
                    'items' => new Map<String, Object>{
                        'type' => 'object',
                        'properties' => pairProps,
                        'required' => required,
                        'additionalProperties' => false
                    }
                }
            },
            'required' => new List<String>{ 'deal', 'account', 'mentions', 'pairs' },
            'additionalProperties' => false
        };
    }

    // ================================================================ the system prompt

    public static String systemPrompt() {
        return String.join(
            new List<String>{
                'You read one sales-call transcript once and produce QUESTION-ANSWER PAIRS: ' +
                'for each place the words answer one of the questions you are given, the ' +
                'question, the words themselves quoted exactly, and the meaning those words ' +
                'voice.',
                '',
                'You are the first reader. A deterministic stage attaches the person to ' +
                'each pair you emit - from whose turn the words sit in, or from the about ' +
                'designator you supply - and a later blind reader sees one pair at a time ' +
                'with no context and decides whether the words really carry it. Every quote ' +
                'you write is checked character by character against the stored transcript ' +
                'before anything is kept.',
                '',
                'RULES.',
                '',
                'NEVER SAY WHO A PERSON IS. You never attach an identity, an email, a role ' +
                'in our records, or a conclusion about anybody. Who each person IS in the ' +
                'org\'s world is the next stage\'s deterministic job. The one thing you do ' +
                'say, in the about field only: where the words are ABOUT a person other ' +
                'than their speaker, write that person\'s name or title exactly as the ' +
                'transcript writes it, with the introducing span quoted in about_quote. A ' +
                'misspelt name stays misspelt; a pronoun becomes the name or title it ' +
                'refers to in the surrounding transcript, with the introduction quoted. ' +
                'Where the words are about the speaker themselves, about is an empty ' +
                'string, and that is the usual case.',
                '',
                'EVERY QUESTION POINTS ONE WAY. You are never asked whether something is ' +
                'false, and there is no way to say so. Words either voice the question\'s own ' +
                'direction or they produce nothing at all. If the words say the opposite, ' +
                'that is not a pair; it may be an answer to a DIFFERENT question in the list, ' +
                'so look before you drop it.',
                '',
                'COVERAGE IS YOUR JOB. FILTERING IS NOT. Report every place the words answer ' +
                'a question, including ones you think are weak. You are not the bar. The two ' +
                'mistakes are not equal: a pair that should not have survived is caught by ' +
                'the third reader and counted, while a pair you leave out is caught by ' +
                'nothing and becomes silence that looks like an answer.',
                '',
                // ---- §P8.9, ruling 2 ------------------------------------------------
                'ONE QUOTE, SEVERAL ESTABLISHMENTS. The consequential sentences in a call ' +
                'rarely establish exactly one thing, and when a sentence answers three ' +
                'questions you emit three pairs quoting the same words. Do not choose the ' +
                'single best reading of a rich sentence. Picking one is under-reading wearing ' +
                'discipline\'s clothes.',
                '',
                'TWO QUESTIONS IN THE LIST CAN BOTH BE ANSWERED BY ONE SENTENCE. Where ' +
                'that happens, emit both pairs quoting the same words. The same quote ' +
                'appearing twice in your output is correct, not a duplicate.',
                '',
                                'THE CONTENT OF THE CALL, NEVER THE TITLE, IN BOTH DIRECTIONS. A title never ' +
                'establishes anything by itself: a person called Director of Operations has ' +
                'established nothing by being called that. And the reverse is equally binding ' +
                '— BEHAVIOUR ON THE CALL ESTABLISHES. Somebody comparing options against a ' +
                'stated need is evaluating, whatever their level. Somebody routing the case ' +
                'to the deciding body is placed by that act. An entry-level person put on the ' +
                'project who evaluates, evaluates. The guard against titles is not a guard ' +
                'against evidence.',
                '',
                // ---- §P8.9, ruling 3 ------------------------------------------------
                'ADVOCACY IS NEVER DISCOUNTED FOR COMING FROM A PROFESSIONAL. Being polite to ' +
                'a vendor is not support, and greetings, thanks and pleasantries voice no ' +
                'stance. But a buyer who coaches the seller through her own organization\'s ' +
                'process, tells them what the approvers need to see, or moves the case ' +
                'internally IS voicing support, and the fact that she is doing her job does ' +
                'not discount it. That is the most load-bearing sentiment evidence a call ' +
                'carries and it is not to be read as mere professionalism.',
                '',
                // ---- §P8.9, ruling 4 ------------------------------------------------
                'THE QUESTIONS ARE NOT EQUALLY HEAVY. How people stand toward us, where they ' +
                'sit politically, and what part they play in the buying decision are what ' +
                'this read is for, and that is where your attention belongs. Decision ' +
                'criteria are RARE: expect zero to a few on any call, and often none. If you ' +
                'find yourself returning many criteria and few placements, you have it ' +
                'backwards and should read again.',
                '',
                'QUOTE VERBATIM AND KEEP IT COEXTENSIVE. The quote is the shortest stretch of ' +
                'words that still carries the whole answer: its subject, its scope and its ' +
                'quantity. Too short and it stops meaning what it meant; too long and it ' +
                'smuggles in words that carry nothing. Aim for one sentence, take two where ' +
                'the second is what makes the first say anything. About ' +
                EVIDENCE_BUDGET_TOKENS + ' tokens per pair.',
                '',
                'PARTIAL IS THE DEFAULT UNDER DOUBT, where the question takes coverage. Full ' +
                'means the words carry every element the question names. A partial accrues ' +
                'safely and places nobody, so reach for it rather than stretching a quote ' +
                'into a Full it does not support.',
                '',
                'DO NOT INFER BEYOND THE WORDS. Plans, intentions and expectations are not ' +
                'the events they describe, and guidance the speaker cancels in the same ' +
                'breath is not guidance. Quote what was said and let the meaning be what the ' +
                'words voice.',
                '',
                'WRITE NOTHING ABOUT SILENCE. A question nobody answered simply has no pair. ' +
                'You are not asked to account for it and there is no field to account for it ' +
                'in. This rule is about entries you must not write; it is not permission to ' +
                'report less, and it does not narrow the coverage rule above.',
                '',
                'You are not shown, and must not guess at, any conclusion reached about these ' +
                'people before today. Agreeing with a past conclusion is not evidence.'
            },
            '\n'
        );
    }

    // ================================================================ the user content

    /**
     * THE CACHEABLE HALF: the seventeen questions, identical for every artifact until
     * somebody mints a new contract. It leads the message and carries the cache breakpoint.
     * The declared set is the contracts the org holds, so there is no question in this
     * block that the org cannot record an answer to.
     */
    public static String rubricBlock(List<AAO_Evidence_Contract__c> declared) {
        List<AAO_Evidence_Contract__c> sorted = new List<AAO_Evidence_Contract__c>(declared);
        sorted.sort(new ByCode());

        List<String> out = new List<String>();
        out.add('# The questions');
        out.add('');
        out.add(
            'Each is asked ONCE about this whole transcript, never once per person. Use the ' +
            'code on the left as the question code of a pair.'
        );
        out.add('');
        for (AAO_Evidence_Contract__c ec : sorted) {
            String code = ec.AAO_Proposition_Code__c;
            out.add('## ' + code);
            out.add('Question: ' + ec.AAO_Proposition_Text__c);
            List<String> ms = meaningsFor(code);
            out.add(
                ms.size() == 1
                    ? 'Meaning, when the words answer it: ' + ms[0] + '.'
                    : 'Meaning, one of: ' + String.join(ms, ', ') + '.'
            );
            if (String.isNotBlank(ec.AAO_Guidance_Text__c)) {
                out.add('Guidance: ' + ec.AAO_Guidance_Text__c);
            }
            if (takesCoverage(code) && ec.AAO_Element_Count__c > 1) {
                out.add(
                    'This question names ' + ec.AAO_Element_Count__c.intValue() +
                    ' parts, so Full requires all of them and Partial is the honest answer ' +
                    'when the words carry some.'
                );
            } else if (!takesCoverage(code)) {
                out.add('No coverage on this one: the read is whole or there is no pair.');
            }
            out.add('');
        }
        return String.join(out, '\n');
    }

    public class ByCode implements Comparator<AAO_Evidence_Contract__c> {
        public Integer compare(AAO_Evidence_Contract__c a, AAO_Evidence_Contract__c b) {
            return a.AAO_Proposition_Code__c.compareTo(b.AAO_Proposition_Code__c);
        }
    }

    // ========================================================================= parsing

    /**
     * Everything refused here is refused for a reason that is recorded, never dropped
     * silently. A pair the parser throws away is a pair the model paid for, and a silent
     * drop is exactly how the old `AAO_Interpretation__c` lost two of nine refusals.
     */
    public static Result parse(String jsonText, List<String> declaredCodes) {
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new CharterException(
                'Call 1 returned something that is not JSON. First 300 characters: ' +
                (jsonText == null ? '(null)' : jsonText.abbreviate(300))
            );
        }
        if (!(root.get('pairs') instanceof List<Object>)) {
            throw new CharterException(
                'Call 1 returned JSON with no pairs array. Keys present: ' +
                String.join(new List<String>(root.keySet()), ', ')
            );
        }

        Set<String> allowed = new Set<String>(declaredCodes);
        coverageDefaulted = 0;
        Result r = new Result();
        r.dealSaid = (String) root.get('deal');
        r.accountSaid = (String) root.get('account');

        if (root.get('mentions') instanceof List<Object>) {
            for (Object mo : (List<Object>) root.get('mentions')) {
                Map<String, Object> m = (Map<String, Object>) mo;
                Mention mn = new Mention();
                mn.name = (String) m.get('name');
                mn.note = (String) m.get('note');
                if (String.isNotBlank(mn.name)) {
                    r.mentions.add(mn);
                }
            }
        }

        Integer n = 0;
        for (Object po : (List<Object>) root.get('pairs')) {
            if (r.pairs.size() >= MAX_PAIRS) {
                r.rejected.add('beyond MAX_PAIRS (' + MAX_PAIRS + '), dropped untrusted');
                break;
            }
            Map<String, Object> m = (Map<String, Object>) po;
            n++;
            Pair p = new Pair();
            p.ref = 'q' + n;
            p.questionCode = (String) m.get('question_code');
            p.answerText = (String) m.get('answer_text');
            p.meaning = (String) m.get('meaning');
            p.coverage = (String) m.get('coverage');
            p.criterionName = (String) m.get('criterion_name');
            p.aboutWords = (String) m.get('about');
            p.aboutQuote = (String) m.get('about_quote');

            String bad = reject(p, allowed);
            if (bad == null) {
                r.pairs.add(p);
            } else {
                r.rejected.add(p.ref + ' ' + bad);
            }
        }
        return r;
    }

    private static String reject(Pair p, Set<String> allowed) {
        if (String.isBlank(p.questionCode) || !allowed.contains(p.questionCode)) {
            return 'names a question outside the declared set: ' + p.questionCode;
        }
        if (String.isBlank(p.answerText)) {
            return 'has no words, so it has no anchor';
        }
        List<String> ms = meaningsFor(p.questionCode);
        if (!new Set<String>(ms).contains(p.meaning)) {
            return 'meaning "' + p.meaning + '" is not one ' + p.questionCode +
                ' can voice (' + String.join(ms, ', ') + ')';
        }
        Boolean wantsCoverage = takesCoverage(p.questionCode);
        if (!wantsCoverage && String.isNotBlank(p.coverage)) {
            // Not fatal to the pair; the coverage is the category error, not the words.
            p.coverage = null;
        }
        if (wantsCoverage && String.isBlank(p.coverage)) {
            // Partial is the instructed default under doubt, so an omission takes it rather
            // than costing the pair. A missing value is doubt by definition.
            //
            // BUT THE DEFAULT IS COUNTED NOW. It ran silently on all fourteen pairs of the
            // first Emerson run and made a defaulted field look like a read one. With
            // `coverage` required in the schema this should be zero; if it is not, the
            // number says so instead of the value hiding it.
            p.coverage = 'Partial';
            coverageDefaulted++;
        }
        if (wantsCoverage && p.coverage != 'Full' && p.coverage != 'Partial') {
            return 'coverage "' + p.coverage + '" is neither Full nor Partial';
        }
        // THE CRITERION'S NAME IS ITS IDENTITY (3.1.0). On the naming contract a blank name
        // is a pair that cannot mint a distinguishable criterion - the collapsed-row defect
        // by another door - so it is refused with its reason rather than defaulted, per the
        // required-reason-field law: a name field satisfied by a non-name fails loudly,
        // never fills. On every other contract the field is the schema's empty-string tax
        // and is discarded.
        if (p.questionCode == 'AAO_DC_N') {
            p.criterionName = p.criterionName == null ? null : p.criterionName.trim();
            if (String.isBlank(p.criterionName)) {
                return 'is a naming pair with no criterion name, and a criterion\'s ' +
                    'identity is its name';
            }
            if (p.criterionName.length() > 255) {
                return 'has a criterion name of ' + p.criterionName.length() +
                    ' characters; a name is a short phrase, not the quote';
            }
        } else {
            p.criterionName = null;
        }
        // THE DESIGNATOR IS BOTH FIELDS OR NEITHER. A designator with no introducing quote
        // has no visible evidence for the resolution it claims, which is the wrong-referent
        // hazard unmitigated; a quote with no designator anchors nothing. Either half alone
        // is dropped (the pair survives as self-subject) and counted by the locator's note
        // path when the quote later fails the byte check.
        p.aboutWords = String.isBlank(p.aboutWords) ? null : p.aboutWords.trim();
        p.aboutQuote = String.isBlank(p.aboutQuote) ? null : p.aboutQuote;
        if (p.aboutWords == null || p.aboutQuote == null) {
            p.aboutWords = null;
            p.aboutQuote = null;
        }
        return null;
    }
}
