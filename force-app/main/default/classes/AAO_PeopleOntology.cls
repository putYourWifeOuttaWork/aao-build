/**
 * THE PEOPLE ONTOLOGY, read from Altify's own authored labels rather than walked.
 * Unblocked by charter design v1.8.
 *
 * The wizard questions are custom labels. `ExternalString` holds them, and a pattern query
 * recovers ANY org's set at install with no human in it — which is what makes "discovered
 * rather than paraphrased" true in a customer org rather than only in a document. A manual
 * walk recovers one org's wizard, and recovers it incompletely: the walk that produced v1.7
 * found five Support questions where nine exist, because it followed the path taken rather
 * than the tree, and every one of the four it missed establishes the NEGATIVE direction.
 *
 * FOUR LAWS GOVERN THIS READ, and each of them is a defect that already happened.
 *
 * 1. READ BY PATTERN, FILTER BY FAMILY. `%GUIDED_QUESTION%` under-collects if you iterate
 *    1..N — the numbering is sparse per family (Support runs 1, 2, 4, 5, 6, 7, 11, 14, 16) —
 *    and `%HELP_TEXT%` over-collects, because `PRESSURE_EDIT_TYPES_HELP_TEXT` is edit-form
 *    guidance rather than an admission test. So the pattern is the net and the family is the
 *    filter, and neither alone is right.
 *
 * 2. BE LOUD WHEN THE FAMILIES DO NOT MATCH. The discovery filter-fault law, applied to
 *    labels: a populated table matching nothing is a failure, not an empty result. Here it
 *    is sharper, because a SHORT read looks exactly like a complete one — that is precisely
 *    how v1.7 shipped a five-question ontology.
 *
 * 3. APPLY THE LOCALIZATION OVERLAY. A customer may rewrite any label, and the override
 *    lives in a DIFFERENT TABLE from the label. It is empty in this org, which is a finding
 *    and not a licence to skip it: reading `ExternalString` alone would author contracts from
 *    words no user of that org has ever seen.
 *
 * 4. BYTE-EXACT, ALWAYS. `organisation` on the opportunity map against `organization` on the
 *    account map. `jeopardise`. The stray hyphen in `_11`'s `-including`. The curly
 *    apostrophes. None of it is tidied on the way in, because A NORMALISED QUOTE IS A
 *    PARAPHRASE — the same law that makes the byte check possible on spans, applied to the
 *    proposition instead of the evidence.
 *
 * WHAT THIS CLASS DOES NOT DO. It does not walk, guess, or fill gaps. If the org's labels
 * disagree with the expected families it refuses and says which family was short, because a
 * rubric assembled from a partial read is the failure this whole file exists to prevent.
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
    public static final Map<String, List<Integer>> EXPECTED = new Map<String, List<Integer>>{
        'AM_OM_SUPPORT_GUIDED_QUESTION_' => new List<Integer>{ 1, 2, 4, 5, 6, 7, 11, 14, 16 },
        'AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_' => new List<Integer>{ 3, 4, 6, 7 },
        'OM_POLITICAL_STATUS_GUIDED_QUESTION_' => new List<Integer>{ 1, 2, 9 },
        'AM_OM_COVERAGE_GUIDED_QUESTION_' => new List<Integer>{ 1, 2, 3 }
    };

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
     * THE READ CANNOT HAPPEN IN APEX, and this is a finding rather than a limitation of this
     * class. Established from the org, not reasoned about:
     *
     *   `ExternalString` is a TOOLING API object. Apex SOQL cannot see it at all — the
     *   compiler answers `Invalid type: ExternalString`.
     *
     *   `System.Label.ALTF.<name>` is the other door and it is shut too. **2,576 of the
     *   2,930 ALTF labels are `IsProtected = true`, including every guided question**, and a
     *   protected managed-package label is invisible to subscriber Apex. The compiler
     *   answers `External string does not exist`. Only 354 are public.
     *
     * So the sentence *a pattern query recovers any org's set at install with no human in
     * it* is true of the Tooling API and false of Apex. The labels ARE the source of truth
     * and they ARE readable; what changes is WHERE the read runs.
     *
     * TWO WAYS OUT AND BOTH ARE RULINGS, not implementation choices:
     *
     *   1. A Tooling API callout at SETUP TIME, through a Named Credential pointing at the
     *      org itself. This fits the shape already ruled for state-based questions — a read
     *      performed once, frozen on the contract, re-run when the content hash moves — and
     *      setup is exactly where a callout is affordable. It needs an admin to authorise a
     *      credential to their own org, so *zero customer-admin action* becomes one action.
     *
     *   2. The read happens outside the org entirely and the labels arrive as data, the way
     *      the mini-rubric did. Honest, and it gives up the install-time automatic property
     *      that made this approach better than a walk.
     *
     * Until that is ruled, `read()` refuses and this class is the ASSEMBLER: hand it the
     * labels and it applies every law — family guard, byte-exactness, element structure,
     * speaker requirement, route. `assemble()` is the seam, and it is a seam rather than a
     * workaround: whoever performs the read, the rules that turn labels into contracts are
     * the same and live here.
     */
    public static Map<String, String> read() {
        throw new OntologyException(
            'The label read cannot run in Apex. ExternalString is a Tooling API object that ' +
            'Apex SOQL cannot see, and System.Label is shut because 2,576 of 2,930 ALTF ' +
            'labels are protected, including every guided question. The read must come from ' +
            'the Tooling API — a setup-time callout through a Named Credential to this org, ' +
            'or an out-of-org step — and this class assembles from whatever performs it. ' +
            'Refusing rather than reading a different, wrong source.'
        );
    }

    /**
     * The assembler, and the whole of the ruled behaviour. Hand it label name to verbatim
     * text, overlay already applied by whoever read it.
     */
    public static Map<String, String> assemble(Map<String, String> labels) {
        Set<String> wanted = new Set<String>();
        for (String prefix : EXPECTED.keySet()) {
            for (Integer n : EXPECTED.get(prefix)) {
                wanted.add(prefix + n);
            }
        }
        Map<String, String> kept = new Map<String, String>();
        for (String name : wanted) {
            if (labels != null && labels.containsKey(name)) {
                // BYTE-EXACT. Not trimmed, not case-folded, not de-hyphenated.
                kept.put(name, labels.get(name));
            }
        }
        verify(wanted, kept);
        return kept;
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
    private static void verify(Set<String> wanted, Map<String, String> found) {
        if (found.isEmpty()) {
            throw new OntologyException(
                'No ALTF guided-question labels in this org at all. Either the package is ' +
                'not installed or the label names have changed; both are loud failures and ' +
                'neither is an empty ontology.'
            );
        }
        List<String> shortFamilies = new List<String>();
        for (String prefix : EXPECTED.keySet()) {
            List<String> missing = new List<String>();
            for (Integer n : EXPECTED.get(prefix)) {
                if (!found.containsKey(prefix + n) || String.isBlank(found.get(prefix + n))) {
                    missing.add(String.valueOf(n));
                }
            }
            if (!missing.isEmpty()) {
                shortFamilies.add(prefix + ' missing ' + String.join(missing, ', '));
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
