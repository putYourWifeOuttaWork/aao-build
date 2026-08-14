/**
 * THE PEOPLE ONTOLOGY. OURS, seeded, overridable per org. Ruled v3.0 under LAW #1.
 *
 * THE SOURCE MOVED AND NOTHING ELSE DID. The questions were recovered from Altify's labels
 * and they are the right questions, but nothing here reads that package, keys on its version,
 * or behaves differently when it is absent. `AAO_People_Question__mdt` ships the text as our
 * own seed data, and the upstream label name survives as an IDENTITY we chose to keep — so
 * the family guard can assert a shape and so anyone comparing our wording to Altify's can
 * find the counterpart — never as a dependency to satisfy.
 *
 * Why not read the labels: 2,576 of the 2,930 ALTF labels are protected, so `ExternalString`
 * is Tooling-only and `System.Label` is shut to subscriber Apex. Every route to them either
 * needed a callout or keyed on a package version, and LAW #1 forbids the second outright.
 *
 * TWO FIELDS, AND THE SECOND IS THE POINT. `AAO_Shipped_Text__c` is ours, DeveloperControlled,
 * replaced on upgrade. `AAO_Org_Override__c` is theirs, SubscriberControlled, null until
 * somebody sets it, and never touched by us. The reader prefers the override where it is
 * populated. **This survives upgrade by construction rather than by trusting manageability
 * semantics that cannot be tested from a subscriber org**, and it makes "has this org
 * customised this question" a query rather than an inference.
 *
 * FOUR LAWS STILL GOVERN THE READ, and each is a defect that already happened.
 *
 * 1. READ THE SET, FILTER BY FAMILY. The numbering is sparse (Support runs 1, 2, 4, 5, 6, 7,
 *    11, 14, 16) and a family pattern over-collects, so an iterator under-collects and a bare
 *    pattern over-collects. Neither alone is right.
 *
 * 2. BE LOUD WHEN THE FAMILIES DO NOT MATCH. A SHORT read looks exactly like a complete one —
 *    that is precisely how v1.7 shipped a five-question ontology against a nine-question set.
 *
 * 3. THE OVERRIDE IS PART OF THE READ. It is null everywhere today, which is a fact about
 *    today and not a licence to skip it.
 *
 * 4. BYTE-EXACT, ALWAYS. `organisation` against `organization`. `jeopardise`. The stray hyphen
 *    in `_11`'s `-including`. The curly apostrophes. None of it is tidied on the way in,
 *    because A NORMALISED QUOTE IS A PARAPHRASE — the law that makes the byte check possible
 *    on spans, applied to the proposition instead of the evidence.
 *
 * WHAT THIS CLASS DOES NOT DO. It does not walk, guess, or fill gaps. If the seeds disagree
 * with the expected families it refuses and names which family was short.
 */
public class AAO_PeopleOntology {
    public class OntologyException extends Exception {
    }

    public static final String RUBRIC_VERSION = 'people-om-v1';

    /**
     * THE EXPECTED FAMILIES, opportunity-map side, from the enumeration in session 43.
     *
     * These are declared rather than discovered ON PURPOSE, and the distinction matters: the
     * TEXT is always read from the org and never from here, but the SHAPE is asserted so a
     * short read is caught. Without this the class would happily author whatever it found,
     * which is what happened last time.
     */
    public static final String SCOPE_OM = 'OM';
    public static final String SCOPE_AM = 'AM';

    /**
     * THE EXPECTED FAMILIES, now partitioned by map scope. Ruled v3.2: "a map-scope
     * parameter injecting that scope's question set." The text is always read from the org;
     * the SHAPE is asserted so a short read is caught, per scope, and the two scopes never
     * bleed — an account pass cannot silently accept the opportunity set as filler, which is
     * the family-guard failure one level up.
     *
     * OM is unchanged from the original enumeration. AM carries only the AM-SPECIFIC families
     * seeded this session — Support 1/2/4/6, Political 1/2/9 — and Decision Orientation as a
     * named family below. HOW THE ACCOUNT SET COMPOSES THE SHARED `AM_OM_` LABELS with these
     * AM-specific ones is a People-reopen decision that is not yet ruled and is deliberately
     * NOT encoded here: guarding a composition nobody has authored would be the exact guess
     * this guard exists to refuse.
     */
    public static final Map<String, Map<String, List<Integer>>> NUMBERED =
        new Map<String, Map<String, List<Integer>>>{
            SCOPE_OM => new Map<String, List<Integer>>{
                'AM_OM_SUPPORT_GUIDED_QUESTION_' => new List<Integer>{ 1, 2, 4, 5, 6, 7, 11, 14, 16 },
                'AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_' => new List<Integer>{ 3, 4, 6, 7 },
                'OM_POLITICAL_STATUS_GUIDED_QUESTION_' => new List<Integer>{ 1, 2, 9 },
                'AM_OM_COVERAGE_GUIDED_QUESTION_' => new List<Integer>{ 1, 2, 3 }
            },
            SCOPE_AM => new Map<String, List<Integer>>{
                'AM_SUPPORT_GUIDED_QUESTION_' => new List<Integer>{ 1, 2, 4, 6 },
                'AM_POLITICAL_STATUS_GUIDED_QUESTION_' => new List<Integer>{ 1, 2, 9 }
            }
        };

    /**
     * NAMED families, whose members are authored values rather than numbered questions.
     * Decision Orientation is Buyer-Role-shaped: no vendor question set, UI-captured
     * definitions, `Inferred_Pending` until ratified. It is guarded the same way — a missing
     * value is a short family — but its members are keys, not integers.
     */
    public static final Map<String, Map<String, List<String>>> NAMED =
        new Map<String, Map<String, List<String>>>{
            SCOPE_OM => new Map<String, List<String>>(),
            SCOPE_AM => new Map<String, List<String>>{
                'DECISION_ORIENTATION_' => new List<String>{
                    'DECISION_ORIENTATION_FINANCIAL',
                    'DECISION_ORIENTATION_TECHNICAL',
                    'DECISION_ORIENTATION_RELATIONSHIP',
                    'DECISION_ORIENTATION_BUSINESS',
                    'DECISION_ORIENTATION_UNKNOWN'
                }
            }
        };

    /** The original name, kept pointing at the opportunity scope so nothing external breaks. */
    public static final Map<String, List<Integer>> EXPECTED = NUMBERED.get(SCOPE_OM);

        /** Which dimension a label belongs to. The family prefix decides; nothing is inferred. */
    public static String dimension(String label) {
        if (label.contains('SUPPORT_GUIDED_QUESTION')) {
            return 'Support';
        }
        if (label.contains('POLITICAL_STATUS_GUIDED_QUESTION')) {
            return 'Political_Status';
        }
        if (label.contains('COVERAGE_GUIDED_QUESTION')) {
            return 'Coverage';
        }
        if (label.startsWith('DECISION_ORIENTATION_')) {
            return 'Decision_Orientation';
        }
        return null;
    }

    /**
     * Route per dimension, ours and not Altify's.
     *
     * Coverage is P because every one of its three questions is about US — met, recently,
     * regularly — so it is answered by counting our own participation and never by reading
     * what a buyer said. Support and Political are E: they are propositions about what the
     * buyer said and did, and they need spans.
     */
    public static String route(String dim) {
        return dim == 'Coverage' ? 'P' : 'E';
    }

    /**
     * SUBJECT_PERSON WHERE THE QUESTION SAYS "TOLD YOU", and nowhere else. From v1.8: `_2`,
     * `_4` and `_6` fix the subject, because they ask what THIS PERSON said to the seller and
     * a colleague vouching for them establishes nothing.
     *
     * `_14` and `_16` deliberately do not. `_16` asks whether the SELLER holds evidence,
     * which makes it observational rather than reported — so requiring the subject to have
     * said it would make an observational proposition unanswerable.
     */
    private static final Set<String> SUBJECT_LABELS = new Set<String>{
        'AM_OM_SUPPORT_GUIDED_QUESTION_2',
        'AM_OM_SUPPORT_GUIDED_QUESTION_4',
        'AM_OM_SUPPORT_GUIDED_QUESTION_6'
    };

    public static String speakerRequirement(String label, String dim) {
        if (SUBJECT_LABELS.contains(label)) {
            return 'Subject_Person';
        }
        if (dim == 'Coverage') {
            // A record has no utterer. The gate records not-applicable for basis State.
            return 'Any_Participant';
        }
        return 'Any_Participant';
    }

    /**
     * COMPOUND QUESTIONS BECOME ELEMENTS, from v1.8's element structure.
     *
     * `_4` is compound (believes it is critical AND sells internally). `_5` is a three-way or
     * (guidance, political insight, competitive information). `_16` is compound the same way
     * (their company OR their personal success).
     *
     * Everything else is one element, and that element is the proposition itself — the same
     * honest default `AAO_Discovery.parseElements` uses, so a question nobody decomposed
     * still gets exactly one part and zero is unreachable.
     */
    private static final Map<String, List<String>> ELEMENTS = new Map<String, List<String>>{
        'AM_OM_SUPPORT_GUIDED_QUESTION_4' => new List<String>{
            'believes your solution is critical to their success',
            'sells internally for you in your absence'
        },
        'AM_OM_SUPPORT_GUIDED_QUESTION_5' => new List<String>{
            'providing guidance',
            'providing political insight',
            'providing competitive information'
        },
        'AM_OM_SUPPORT_GUIDED_QUESTION_16' => new List<String>{
            'believes your success will hurt their company',
            'believes your success will jeopardise their personal success'
        }
    };

    public class Element {
        public String id;
        public String text;

        public Element(String id, String text) {
            this.id = id;
            this.text = text;
        }
    }

    public static List<Element> elementsFor(String label, String propositionText) {
        List<Element> out = new List<Element>();
        List<String> parts = ELEMENTS.get(label);
        if (parts == null) {
            out.add(new Element('e1', propositionText));
            return out;
        }
        for (Integer i = 0; i < parts.size(); i++) {
            out.add(new Element('e' + (i + 1), parts[i]));
        }
        return out;
    }

    // =========================================================== the read

    /**
     * The read, from our own seed records. No callout, no Tooling API, no package
     * dependency — a plain SOQL query over custom metadata, which is why this works in an
     * org that never had Altify installed.
     *
     * THE OVERRIDE WINS WHERE IT IS POPULATED, and null is not a value. An untouched org
     * silently gets the shipped default; a customised org silently gets its own words. No
     * flag, no migration, no branch anywhere else in the system.
     */
    public static Map<String, String> read() {
        return read(SCOPE_OM);
    }

    public static Map<String, String> read(String scope) {
        Map<String, String> byKey = new Map<String, String>();
        for (AAO_People_Question__mdt q : [
            SELECT AAO_Question_Key__c, AAO_Shipped_Text__c, AAO_Org_Override__c
            FROM AAO_People_Question__mdt
        ]) {
            byKey.put(
                q.AAO_Question_Key__c,
                String.isNotBlank(q.AAO_Org_Override__c)
                    ? q.AAO_Org_Override__c
                    : q.AAO_Shipped_Text__c
            );
        }
        return assemble(byKey, scope);
    }

    /**
     * Which questions this org has rewritten.
     *
     * Still a fact read off the record rather than an inference, but NOT a WHERE clause: a
     * LongTextArea cannot be filtered in SOQL — `field 'AAO_Org_Override__c' can not be
     * filtered in a query call` — so the null test happens in Apex over the whole set.
     *
     * The field stays long on purpose. Making it filterable means Text(255), and the longest
     * shipped question is already 152 characters; a customer rewriting one has no reason to
     * stay under a ceiling we chose for the convenience of a query. Thirty-five rows of
     * custom metadata cost nothing to read, and the constraint is the platform's rather than
     * the design's.
     */
    public static Set<String> customised() {
        Set<String> out = new Set<String>();
        for (AAO_People_Question__mdt q : [
            SELECT AAO_Question_Key__c, AAO_Org_Override__c FROM AAO_People_Question__mdt
        ]) {
            if (String.isNotBlank(q.AAO_Org_Override__c)) {
                out.add(q.AAO_Question_Key__c);
            }
        }
        return out;
    }

    /**
     * The assembler, and the whole of the ruled behaviour. Hand it label name to verbatim
     * text, overlay already applied by whoever read it.
     */
    public static Map<String, String> assemble(Map<String, String> labels) {
        return assemble(labels, SCOPE_OM);
    }

    public static Map<String, String> assemble(Map<String, String> labels, String scope) {
        Set<String> wanted = wantedFor(scope);
        Map<String, String> kept = new Map<String, String>();
        for (String name : wanted) {
            if (labels != null && labels.containsKey(name)) {
                // BYTE-EXACT. Not trimmed, not case-folded, not de-hyphenated.
                kept.put(name, labels.get(name));
            }
        }
        verify(scope, kept);
        return kept;
    }

    /** Every full key a scope expects, numbered families plus named ones. */
    private static Set<String> wantedFor(String scope) {
        Set<String> wanted = new Set<String>();
        Map<String, List<Integer>> nums = NUMBERED.get(scope);
        if (nums != null) {
            for (String prefix : nums.keySet()) {
                for (Integer n : nums.get(prefix)) {
                    wanted.add(prefix + n);
                }
            }
        }
        Map<String, List<String>> named = NAMED.get(scope);
        if (named != null) {
            for (String family : named.keySet()) {
                wanted.addAll(named.get(family));
            }
        }
        return wanted;
    }

    /**
     * THE FILTER-FAULT GUARD, applied to labels. A short read looks exactly like a complete
     * one, which is how a five-question ontology shipped as the Support set, so this refuses
     * per family and names which family came up short.
     *
     * It also distinguishes the two causes the discovery guard distinguishes: nothing at all
     * means the labels are not in this org, and something-but-not-everything means the
     * package differs from what was enumerated. Those are different conversations.
     */
    private static void verify(String scope, Map<String, String> found) {
        if (found.isEmpty()) {
            throw new OntologyException(
                'No ' +
                scope +
                '-scope people-ontology seeds resolved. Either the seed is not deployed or ' +
                'the keys have changed; both are loud failures and neither is an empty ' +
                'ontology.'
            );
        }
        List<String> shortFamilies = new List<String>();

        Map<String, List<Integer>> nums = NUMBERED.get(scope);
        if (nums != null) {
            for (String prefix : nums.keySet()) {
                List<String> missing = new List<String>();
                for (Integer n : nums.get(prefix)) {
                    if (!found.containsKey(prefix + n) || String.isBlank(found.get(prefix + n))) {
                        missing.add(String.valueOf(n));
                    }
                }
                if (!missing.isEmpty()) {
                    shortFamilies.add(prefix + ' missing ' + String.join(missing, ', '));
                }
            }
        }

        Map<String, List<String>> named = NAMED.get(scope);
        if (named != null) {
            for (String family : named.keySet()) {
                List<String> missing = new List<String>();
                for (String k : named.get(family)) {
                    if (!found.containsKey(k) || String.isBlank(found.get(k))) {
                        missing.add(k);
                    }
                }
                if (!missing.isEmpty()) {
                    shortFamilies.add(family + ' missing ' + String.join(missing, ', '));
                }
            }
        }

        if (!shortFamilies.isEmpty()) {
            throw new OntologyException(
                'ONTOLOGY FAMILY SHORT. ' +
                String.join(shortFamilies, '; ') +
                '. Refusing rather than authoring a partial rubric: a short read of a ' +
                'sparse set is indistinguishable from a complete read of a dense one, ' +
                'which is exactly how the walked Support set shipped with four questions ' +
                'missing.'
            );
        }
    }

    // ================================================== the contracts

    /**
     * Assemble Evidence Contracts from the labels. Identity is the LABEL NAME, which is the
     * stable upstream identity here in the way a question record id is on the assessment
     * side, plus the content hash — so a customer rewriting a label surfaces as a new
     * generation through the supersede path rather than silently changing an old contract.
     */
    public static List<AAO_Evidence_Contract__c> build(
        Map<String, String> supplied,
        Boolean synthetic
    ) {
        Map<String, String> labels = assemble(supplied);
        List<AAO_Evidence_Contract__c> out = new List<AAO_Evidence_Contract__c>();

        for (String label : new List<String>(labels.keySet())) {
            String text = labels.get(label);
            String dim = dimension(label);
            List<Element> els = elementsFor(label, text);

            out.add(
                new AAO_Evidence_Contract__c(
                    AAO_Question_Record_Id__c = label,
                    AAO_Proposition_Code__c = label,
                    AAO_Proposition_Short__c = dim + ' ' + label.substringAfterLast('_'),
                    // BYTE-EXACT. Not trimmed, not case-folded, not de-hyphenated.
                    AAO_Proposition_Text__c = text,
                    AAO_Guidance_Text__c = null,
                    AAO_Elements__c = JSON.serialize(els),
                    AAO_Element_Count__c = els.size(),
                    // Altify authored the question; we decomposed the compound ones, so the
                    // decomposition is ours and says so until a human ratifies it.
                    AAO_Elements_Basis__c = ELEMENTS.containsKey(label)
                        ? 'Inferred_Pending'
                        : 'Authored',
                    AAO_Route__c = route(dim),
                    AAO_Speaker_Requirement__c = speakerRequirement(label, dim),
                    AAO_Decay_Class__c = 'Standing',
                    AAO_Gating__c = false,
                    AAO_Solicit__c = false,
                    AAO_Requires_Ratification__c = ELEMENTS.containsKey(label),
                    AAO_Contract_State__c = ELEMENTS.containsKey(label)
                        ? 'Awaiting_Ratification'
                        : 'Derived',
                    AAO_Rubric_Version__c = RUBRIC_VERSION,
                    AAO_Synthetic__c = synthetic
                )
            );
        }
        return out;
    }
}