/**
 * STAGE 1 of the Extract-Bind-Verify pass (Charters v2.4 §P7.3). The read.
 *
 * One call per Source, strong model, artifact first. Output is an INVENTORY OF POTENTIAL
 * CLAIMS and nothing else: for each charter-relevant statement, who said it, who it is about,
 * where it sits, the minimal verbatim span, and the proposition FAMILIES it plausibly touches.
 *
 * WHAT THIS CHARTER MUST NOT DO, and why each one is structural rather than requested.
 *
 * 1. NO VERDICTS. There is no verdict field in the schema, so the read cannot propose one.
 *    Judging is stage 2's job against one proposition at a time, and a reader that judges
 *    while it reads pays for prose about every proposition it did not find — which is the
 *    measured cost that retired the previous shape (16 propositions produced 7,339 output
 *    tokens; 53 produced 7,532).
 *
 * 2. FAMILIES, NEVER PER-PERSON CODES. The declared set for one Emerson deal is sixteen
 *    questions times seventeen people. Asking about 272 codes is asking the same sixteen
 *    questions seventeen times in one prompt. The read is guided by the sixteen, and the
 *    person is a separate field on the item, which is what makes the prompt size independent
 *    of the roster size. **This is where the declared-set law binds first:** the families in
 *    the prompt are exactly the declared charters' families and never the whole cabinet.
 *
 * 3. NO CLOSED VOCABULARY IT DID NOT GET FROM THE ORG. Family tokens are the declared
 *    contracts' own tokens, speaker keys are this artifact's roster, subject handles are the
 *    applicable set's own people. There is no string the model could emit that would name a
 *    proposition we do not hold or a person who is not on this deal.
 *
 * 4. NO SILENCE REPORTING. The previous charter demanded one finding per proposition
 *    including the ones nothing was said about, and paid output tokens for each. Silence is
 *    written by Apex after binding at zero model cost, so this charter reports only what it
 *    found. **The consequence is named and owned in §P7.3:** an unextracted statement becomes
 *    a `model_missed` abstention rather than a directly probed answer.
 */
public class AAO_InventoryCharter {
    public class CharterException extends Exception {
    }

    /** Items beyond this are dropped by the parser rather than trusted. */
    public static final Integer MAX_ITEMS = 400;

    /**
     * The evidence budget, ruled 3 August: ~90 output tokens per finding, justified by
     * coextension and never by display. **It was missing from this charter in the first build**
     * — the bind charter got a word budget on its reason and stage 1, which is where spans are
     * actually produced, got the word "minimal" and no number. The first B&V run truncated at
     * 6,000 output tokens with the budget nowhere in the prompt.
     */
    public static final Integer EVIDENCE_BUDGET_TOKENS = 90;

    /** The subject value that means "not one of the people listed". */
    public static final String SUBJECT_NONE = 'none';

    // ======================================================================== families

    /**
     * One proposition family: the question, once, with the people it has contracts for.
     *
     * A People contract's code is `token#contactId` and the proposition text is identical
     * across the people, which is exactly why the read can be guided by the token alone.
     */
    public class Family {
        public String token;
        public String propositionText;
        public String propositionShort;
        public String speakerRequirement;
        /** Contacts this family holds a contract for, in the declared set. */
        public Set<Id> subjects = new Set<Id>();
        /** True where this family is not per-person and its subject is the deal. */
        public Boolean dealScoped = false;
    }

    /**
     * Collapse the declared set into its families.
     *
     * Deterministic order, because the family block is the cacheable prefix of the prompt and
     * a map's iteration order is not a promise. A prefix that reorders itself between calls
     * caches on paper and never reads.
     */
    public static Map<String, Family> families(
        Map<String, AAO_Evidence_Contract__c> declared
    ) {
        Map<String, Family> out = new Map<String, Family>();
        List<String> codes = new List<String>(declared.keySet());
        codes.sort();
        for (String code : codes) {
            AAO_Evidence_Contract__c ec = declared.get(code);
            String token = AAO_PeopleContracts.tokenOf(code);
            Id subject = AAO_PeopleContracts.contactOf(code);
            Boolean perPerson = token != null && subject != null;
            String key = perPerson ? token : code;

            Family f = out.get(key);
            if (f == null) {
                f = new Family();
                f.token = key;
                f.propositionText = ec.AAO_Proposition_Text__c;
                f.propositionShort = ec.AAO_Proposition_Short__c;
                f.speakerRequirement = ec.AAO_Speaker_Requirement__c;
                f.dealScoped = !perPerson;
                out.put(key, f);
            }
            if (perPerson) {
                f.subjects.add(subject);
            }
        }
        return out;
    }

    // ========================================================================== people

    /**
     * The subject vocabulary: a short handle per person, with the name as read.
     *
     * Handles rather than record ids for two reasons. An eighteen-character id differs from
     * another by one character in the middle, and a model that mistypes one silently binds a
     * statement to the wrong human; and the handle list is short enough to sit in a schema
     * enum without dominating the prompt. Sorted by id so the same roster always produces the
     * same handles, which keeps the prompt prefix stable.
     *
     * **FirstName and LastName as read, never Name-only** — fixture law, Model & Flow v1.2.
     * The final-space split broke on `St. Clair` and breaks identically on `van` and `de`.
     */
    public class People {
        public Map<String, Id> byHandle = new Map<String, Id>();
        public Map<Id, String> handleOf = new Map<Id, String>();
        public Map<Id, String> displayOf = new Map<Id, String>();

        public List<String> handles() {
            List<String> hs = new List<String>(byHandle.keySet());
            hs.sort();
            return hs;
        }
    }

    /**
     * THE SUBJECT VOCABULARY IS THE DECLARED SET'S OWN PEOPLE, NOT THE ROSTER.
     *
     * The first build of this class passed the whole roster, and the B&V run timed out at the
     * ceiling with it. The B&V deal has **44 map rows and contracts for three of them**, so the
     * read was handed forty-four handles of whom forty-one could not bind to anything: every
     * item about one of them would have been dropped at `no_contract` after being generated,
     * paid for, and counted. That is the declared-set law being obeyed on the family axis and
     * broken on the person axis in the same prompt.
     *
     * The set is derived from the families rather than passed separately, so the two halves of
     * the prompt cannot disagree about who this pass is about.
     */
    public static People peopleForSet(Map<String, Family> fams) {
        Set<Id> subjects = new Set<Id>();
        for (Family f : fams.values()) {
            subjects.addAll(f.subjects);
        }
        return people(subjects);
    }

    public static People people(Set<Id> roster) {
        List<Id> ids = new List<Id>(roster);
        ids.sort();
        Map<Id, Contact> rows = new Map<Id, Contact>(
            [SELECT Id, FirstName, LastName, Title, Email FROM Contact WHERE Id IN :ids]
        );

        People p = new People();
        Integer n = 0;
        for (Id cid : ids) {
            n++;
            String handle = 'p' + n;
            Contact c = rows.get(cid);
            String display = c == null
                ? String.valueOf(cid)
                : (String.isBlank(c.FirstName) ? '' : c.FirstName + ' ') +
                  (String.isBlank(c.LastName) ? '' : c.LastName) +
                  (String.isBlank(c.Title) ? '' : ', ' + c.Title);
            p.byHandle.put(handle, cid);
            p.handleOf.put(cid, handle);
            p.displayOf.put(cid, display.trim());
        }
        return p;
    }

    // ==================================================================== what comes back

    public class Item {
        /** Assigned by the parser, so every later stage can name the item it came from. */
        public String id;
        /** Roster key of the speaker whose turn the span lies in. */
        public String speaker;
        /** Person handle the statement is ABOUT, or SUBJECT_NONE. */
        public String subject;
        /** Whatever the read offers as a locator. Never trusted; the span is the truth. */
        public String anchor;
        public String span;
        public List<String> families = new List<String>();

        public override String toString() {
            return id +
                ' spk=' + speaker +
                ' subj=' + subject +
                ' fam=' + families +
                ' "' + (span == null ? '' : span.abbreviate(50)) + '"';
        }
    }

    // ======================================================================== the schema

    public static Map<String, Object> schema(
        Map<String, Family> fams,
        People ppl,
        Map<String, AAO_Model.Speaker> roster
    ) {
        List<String> tokens = new List<String>(fams.keySet());
        tokens.sort();

        List<String> subjects = ppl.handles();
        // The escape hatch, deliberately present. A statement about somebody who is not on
        // this deal's roster is a real thing to have read, and forcing the model to pick one
        // of the listed people would turn an honest out-of-set observation into a wrong
        // binding. These items are counted and dropped at binding, never guessed at.
        subjects.add(SUBJECT_NONE);

        Map<String, Object> speakerProp = new Map<String, Object>{
            'type' => 'string',
            'description' => 'The roster key of the person whose turn this span lies in.'
        };
        List<String> speakerKeys = new List<String>(roster.keySet());
        speakerKeys.sort();
        if (!speakerKeys.isEmpty()) {
            speakerProp.put('enum', speakerKeys);
        }

        Map<String, Object> itemSchema = new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'speaker' => speakerProp,
                'subject' => new Map<String, Object>{
                    'type' => 'string',
                    'enum' => subjects,
                    'description' => 'The person this statement is ABOUT, which is often not ' +
                        'the person speaking. "' + SUBJECT_NONE + '" where it is about ' +
                        'nobody on the list, or about the deal rather than a person.'
                },
                'anchor' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'Where in the transcript this sits, in whatever form the ' +
                        'text gives you. A locator for a human reader only.'
                },
                'span' => new Map<String, Object>{
                    'type' => 'string',
                    'description' => 'The MINIMAL verbatim substring that carries the ' +
                        'statement, character for character from the transcript, including ' +
                        'punctuation and capitalisation. Shortest span that still carries ' +
                        'subject, scope and quantity. A span that does not match the stored ' +
                        'text exactly is discarded and everything resting on it is lost.'
                },
                'families' => new Map<String, Object>{
                    'type' => 'array',
                    'items' => new Map<String, Object>{
                        'type' => 'string',
                        'enum' => tokens
                    },
                    'description' => 'Every proposition family this span plausibly touches. ' +
                        'Plausibly, not certainly: whether it establishes any of them is ' +
                        'decided after you, one proposition at a time. Err towards listing a ' +
                        'family you are unsure of and never towards a family the words do ' +
                        'not touch at all.'
                }
            },
            'required' => new List<String>{
                'speaker',
                'subject',
                'anchor',
                'span',
                'families'
            },
            'additionalProperties' => false
        };

        return new Map<String, Object>{
            'type' => 'object',
            'properties' => new Map<String, Object>{
                'items' => new Map<String, Object>{
                    'type' => 'array',
                    'items' => itemSchema,
                    'description' => 'One entry per charter-relevant statement you found. ' +
                        'Statements nothing in the list touches are simply not entries: ' +
                        'silence is recorded by machinery after you and costs you nothing.'
                }
            },
            'required' => new List<String>{ 'items' },
            'additionalProperties' => false
        };
    }

    // ================================================================== the system prompt

    public static String systemPrompt() {
        return String.join(
            new List<String>{
                'You read one sales-call transcript once and produce an INVENTORY of the ' +
                'statements in it that bear on a list of proposition families. You do not ' +
                'judge whether any proposition is established. That happens after you, one ' +
                'proposition at a time, by a reader that will see your span and nothing else.',
                '',
                'You are the first stage of a machine. Nothing you produce is trusted on its ' +
                'own: every span is checked byte for byte against the stored transcript, ' +
                'every binding is judged separately, and an independent reader checks each ' +
                'surviving claim against its span before anything is recorded.',
                '',
                'RULES.',
                '',
                'QUOTE VERBATIM. A span must be a character-for-character substring of the ' +
                'transcript as given to you. Do not tidy, join, trim, correct or paraphrase. ' +
                'Do not stitch two turns together. A span that does not match exactly is ' +
                'discarded and everything that rested on it is lost.',
                '',
                'MINIMAL AND COEXTENSIVE. The span is the shortest stretch of words that ' +
                'still carries the whole statement: its subject, its scope, and its quantity. ' +
                'Too short and it stops meaning what it meant; too long and it smuggles in ' +
                'words that carry nothing. Aim for one sentence, take two where the second is ' +
                'what makes the first say anything.',
                '',
                'THE BUDGET IS ABOUT ' + EVIDENCE_BUDGET_TOKENS + ' TOKENS PER ITEM, ' +
                'coextension being the reason and not brevity for its own sake. An item is a ' +
                'span, a speaker, a subject, an anchor and a family list; if your spans are ' +
                'running longer than two sentences you are quoting the conversation rather ' +
                'than the statement. The anchor is a short locator, never a description.',
                '',
                'ONE ITEM PER STATEMENT AND NO MORE. Do not enter the same statement twice ' +
                'under different families; the family list on one item is how a statement ' +
                'touches several questions. Do not enter a statement whose only bearing on a ' +
                'family is that it is on the same topic.',
                '',
                'THE SUBJECT IS WHO THE STATEMENT IS ABOUT, NOT WHO IS TALKING. A seller ' +
                'saying "Dana owns that budget" is a statement about Dana. Report the speaker ' +
                'and the subject separately and do not collapse them.',
                '',
                'FAMILIES ARE PLAUSIBILITY, NOT VERDICTS. List every family the words could ' +
                'bear on. You are not deciding anything by listing one, and a family you ' +
                'leave off is a question that will be answered as silence.',
                '',
                'ONE STATEMENT, ONE ITEM. If one sentence bears on three families, that is ' +
                'one item listing three families, not three items. If two separate sentences ' +
                'bear on the same family about the same person, those are two items.',
                '',
                'DO NOT INFER BEYOND THE WORDS. Plans, intentions and expectations are not ' +
                'the events they describe. "We will have budget approved next month" is a ' +
                'statement about an intention. Report it as the words are, and let the ' +
                'judging stage decide what it establishes.',
                '',
                'REPORT NOTHING ABOUT SILENCE. A family nobody spoke to produces no item. ' +
                'You are not asked to account for the families you did not find and you must ' +
                'not write entries saying you did not find them.',
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
     * THE CACHEABLE HALF. The families and the people: identical for every artifact on this
     * deal until somebody edits a contract or the roster moves. It leads the message and
     * carries the cache breakpoint.
     *
     * **The ordering argument from the retired shape does not apply here and the inversion is
     * undone deliberately.** Artifact-first was right for one artifact read N times, where
     * only the proposition tail changed. §P7.3 reads each artifact ONCE, so the artifact is
     * the volatile half again and the stable half is the rubric. Across Sources that share a
     * deal this prefix is identical, which is the only caching left to win and is why
     * `cacheRead` is still reported.
     */
    public static String rubricBlock(Map<String, Family> fams, People ppl) {
        List<String> out = new List<String>();

        out.add('# The people');
        out.add('');
        out.add(
            'These are the people this deal holds questions about. Use the handle on the ' +
            'left as the subject of an item.'
        );
        out.add('');
        for (String h : ppl.handles()) {
            out.add('  ' + h + ': ' + ppl.displayOf.get(ppl.byHandle.get(h)));
        }
        out.add('  ' + SUBJECT_NONE + ': the statement is about nobody above, or about the deal.');
        out.add('');

        out.add('# The proposition families');
        out.add('');
        List<String> tokens = new List<String>(fams.keySet());
        tokens.sort();
        for (String t : tokens) {
            Family f = fams.get(t);
            out.add('## ' + t);
            out.add('Proposition: ' + f.propositionText);
            out.add(
                'Asked about: ' +
                (f.dealScoped
                    ? 'the deal.'
                    : 'each person separately, so a span bears on this family about the ' +
                      'person it is about and not about the room.')
            );
            out.add(
                'Speaker requirement, for identification only: ' +
                describeRequirement(f.speakerRequirement) +
                ' Do not let it change what you report.'
            );
            out.add('');
        }
        return String.join(out, '\n');
    }

    private static String describeRequirement(String requirement) {
        if (requirement == 'Decision_Maker_Or_Influencer') {
            return 'the assertion would have to come from a buyer-side decision maker or influencer.';
        }
        if (requirement == 'Buyer_Side') {
            return 'the assertion would have to come from the buying side.';
        }
        if (requirement == 'Seller') {
            return 'the assertion would have to come from the selling side.';
        }
        if (requirement == 'Any_Participant') {
            return 'any participant could carry the assertion.';
        }
        return 'unspecified.';
    }

    // ========================================================================== parsing

    public static List<Item> parse(String jsonText) {
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new CharterException(
                'The inventory charter returned something that is not JSON. First 300 ' +
                'characters: ' + jsonText.abbreviate(300)
            );
        }
        Object raw = root.get('items');
        if (!(raw instanceof List<Object>)) {
            throw new CharterException(
                'The inventory charter returned JSON with no items array. Keys present: ' +
                String.join(new List<String>(root.keySet()), ', ')
            );
        }

        List<Item> out = new List<Item>();
        Integer n = 0;
        for (Object io : (List<Object>) raw) {
            if (out.size() >= MAX_ITEMS) {
                break;
            }
            Map<String, Object> m = (Map<String, Object>) io;
            n++;
            Item it = new Item();
            it.id = 'i' + n;
            it.speaker = (String) m.get('speaker');
            it.subject = (String) m.get('subject');
            it.anchor = (String) m.get('anchor');
            it.span = (String) m.get('span');
            Object fs = m.get('families');
            if (fs instanceof List<Object>) {
                for (Object f : (List<Object>) fs) {
                    if (f instanceof String) {
                        it.families.add((String) f);
                    }
                }
            }
            // An item with no span carries nothing. An item with no family names no
            // question. Neither can produce a binding, so neither is kept.
            if (String.isNotBlank(it.span) && !it.families.isEmpty()) {
                out.add(it);
            }
        }
        return out;
    }
}
