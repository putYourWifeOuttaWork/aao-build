/**
 * People Evidence Contracts, built from our own seeded ontology.
 *
 * Every other rubric in this build is discovered from Altify's tables. This one is not, and
 * that is LAW #1 in practice: `AAO_People_Question__mdt` is our metadata, the read needs no
 * callout and no package, and these contracts assemble in an org that never had Altify
 * installed.
 *
 * **One contract per (question, person), because the extraction charter keys a finding by
 * proposition code alone.** The charter has no subject field, so the person has to live in the
 * code or the model cannot say which of four people a sentence was about. `AAO_Proposition_Code__c`
 * is forty characters, which is why the code is a compact family token rather than the label:
 *
 * ```
 *   S2#003WD00001PZZVRYA5      Support question 2, about that contact
 *   PO1#003WD00001PZZVRYA5     Political, opportunity-only family, question 1
 *   PS4#003WD00001PZZVRYA5     Political, shared AM_OM_ family, question 4
 * ```
 *
 * The label itself is never lost: it is carried byte-exact as the proposition text, straight
 * out of the seed, overlay applied. **The code is an identifier; the proposition is the words.**
 */
public with sharing class AAO_PeopleContracts {
    public class PeopleContractException extends Exception {
    }

    public static final String RUBRIC_VERSION = 'people-om-v1';
    public static final String SEP = '#';

    /** Family tokens. Short because the code field is forty characters. */
    public static final String T_SUPPORT = 'S';
    public static final String T_POL_OM = 'PO';
    public static final String T_POL_SHARED = 'PS';

    private static final String SUP_LABEL = 'AM_OM_SUPPORT_GUIDED_QUESTION_';
    private static final String POL_SHARED_LABEL = 'AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_';
    private static final String POL_OM_LABEL = 'OM_POLITICAL_STATUS_GUIDED_QUESTION_';

    /** The family token and number for an ontology label, or null if it is not a People one. */
    public static String tokenFor(String label) {
        if (label.startsWith(SUP_LABEL)) {
            return T_SUPPORT + label.substring(SUP_LABEL.length());
        }
        if (label.startsWith(POL_SHARED_LABEL)) {
            return T_POL_SHARED + label.substring(POL_SHARED_LABEL.length());
        }
        if (label.startsWith(POL_OM_LABEL)) {
            return T_POL_OM + label.substring(POL_OM_LABEL.length());
        }
        return null;
    }

    public static String codeFor(String label, Id contactId) {
        String t = tokenFor(label);
        return t == null ? null : t + SEP + String.valueOf(contactId);
    }

    /** The family-and-number half of a per-person code, e.g. `S2`. */
    public static String tokenOf(String code) {
        Integer i = code == null ? -1 : code.indexOf(SEP);
        return i <= 0 ? null : code.substring(0, i);
    }

    /** The person half of a per-person code. */
    public static Id contactOf(String code) {
        Integer i = code == null ? -1 : code.indexOf(SEP);
        if (i < 0 || i == code.length() - 1) {
            return null;
        }
        try {
            return Id.valueOf(code.substring(i + 1));
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * The person behind a contract, safe against a caller that did not select the code.
     *
     * Not every path through the pipeline queries `AAO_Proposition_Code__c` — the demo and
     * live-ingest paths hand contracts they built themselves. Reading an unqueried field
     * throws `SObjectException`, and a per-person lookup must never be able to break a run
     * that has no people in it at all.
     */
    public static Id contactOfContract(AAO_Evidence_Contract__c ec) {
        if (ec == null) {
            return null;
        }
        String code;
        try {
            code = ec.AAO_Proposition_Code__c;
        } catch (SObjectException e) {
            return null;
        }
        return contactOf(code);
    }

    // ==================================================================== the build

    public class Built {
        public Integer created = 0;
        public Integer existing = 0;
        public Integer people = 0;
        public Integer questions = 0;
        public List<AAO_Evidence_Contract__c> contracts = new List<AAO_Evidence_Contract__c>();

        public override String toString() {
            return 'people contracts: ' + created + ' created, ' + existing + ' already there, ' +
                questions + ' questions x ' + people + ' people';
        }
    }

    /**
     * Build the opportunity-scope People rubric for a named set of people.
     *
     * **The people are handed in rather than discovered.** Who belongs on a map is the scope
     * resolver's question and the resolver is design-frozen, not built. Handing the set in
     * keeps this class honest about what it does and does not decide.
     */
    public static Built build(Set<Id> contactIds) {
        if (contactIds == null || contactIds.isEmpty()) {
            throw new PeopleContractException(
                'Cannot build a People rubric for nobody. The set of people is an input here, ' +
                'not a guess: who belongs on a map is the scope resolver\'s question.'
            );
        }
        Map<String, String> ontology = AAO_PeopleOntology.read(AAO_PeopleOntology.SCOPE_OM);

        Built b = new Built();
        b.people = contactIds.size();

        Map<String, AAO_Evidence_Contract__c> already = new Map<String, AAO_Evidence_Contract__c>();
        for (AAO_Evidence_Contract__c ec : [
            SELECT Id, AAO_Proposition_Code__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Rubric_Version__c = :RUBRIC_VERSION
        ]) {
            already.put(ec.AAO_Proposition_Code__c, ec);
        }

        List<AAO_Evidence_Contract__c> fresh = new List<AAO_Evidence_Contract__c>();
        Integer questionCount = 0;
        for (String label : ontology.keySet()) {
            String token = tokenFor(label);
            if (token == null) {
                continue; // Coverage is a P route and is not extracted from words.
            }
            questionCount++;
            String propositionText = ontology.get(label);
            String dimension = AAO_PeopleOntology.dimension(label);

            for (Id contactId : contactIds) {
                String code = token + SEP + String.valueOf(contactId);
                if (already.containsKey(code)) {
                    b.existing++;
                    b.contracts.add(already.get(code));
                    continue;
                }
                fresh.add(
                    new AAO_Evidence_Contract__c(
                        AAO_Proposition_Code__c = code,
                        AAO_Proposition_Short__c = shortOf(dimension, label, propositionText),
                        AAO_Proposition_Text__c = propositionText,
                        // The seed label IS the question's identity here. There is no Altify
                        // question record behind a People proposition and inventing one would
                        // be a dangling pointer with a plausible shape.
                        AAO_Question_Record_Id__c = token,
                        // The person is part of the content, not decoration. "Has THIS
                        // person expressed a preference" is a different proposition for each
                        // person, and the contract key must say so or three people collide on
                        // one key. The id goes into the hash rather than into
                        // AAO_Question_Record_Id__c, which is eighteen characters and cannot
                        // hold a code plus an id.
                        AAO_Content_Hash__c = AAO_ContractKey.contentHash(
                            propositionText,
                            String.valueOf(contactId)
                        ),
                        AAO_Rubric_Version__c = RUBRIC_VERSION,
                        AAO_Charter_Designation__c = AAO_ApplicableSet.PEOPLE,
                        AAO_Route__c = AAO_PeopleOntology.route(dimension),
                        AAO_Speaker_Requirement__c = AAO_PeopleOntology.speakerRequirement(
                            label,
                            dimension
                        ),
                        AAO_Contract_State__c = 'Derived',
                        AAO_Decay_Class__c = 'Standing',
                        AAO_Elements_Basis__c = 'Authored',
                        // A guided question is one indivisible part: it asks one thing and it
                        // is established or it is not. The count is never unknown, which the
                        // contract's own validation rule enforces, and zero would be a claim
                        // that the proposition has no content.
                        AAO_Elements__c = '[{"id":"e1","text":' +
                            JSON.serialize(propositionText) + '}]',
                        AAO_Element_Count__c = 1,
                        AAO_Gating__c = false,
                        AAO_Solicit__c = false,
                        AAO_Requires_Ratification__c = false,
                        AAO_Per_Person_Source__c = 'handed set, opportunity scope',
                        AAO_Synthetic__c = AAO_Synthetic.MARK
                    )
                );
            }
        }
        b.questions = questionCount;
        if (!fresh.isEmpty()) {
            insert fresh;
            b.created = fresh.size();
            b.contracts.addAll(fresh);
        }
        return b;
    }

    /**
     * The short form the pipeline view and the map note read. Names the dimension and the
     * question so a row is legible without opening the contract, and never paraphrases the
     * proposition: the full words live in `AAO_Proposition_Text__c`.
     */
    private static String shortOf(String dimension, String label, String text) {
        String head = (dimension == null ? 'People' : dimension.replace('_', ' ')) +
            ' ' +
            label.substring(label.lastIndexOf('_') + 1);
        String tail = text == null ? '' : ' · ' + text;
        return (head + tail).abbreviate(255);
    }

    /** Every People contract standing for this rubric, keyed by code, for the pipeline. */
    public static Map<String, AAO_Evidence_Contract__c> byCode() {
        Map<String, AAO_Evidence_Contract__c> out =
            new Map<String, AAO_Evidence_Contract__c>();
        for (AAO_Evidence_Contract__c ec : [
            SELECT
                Id,
                AAO_Proposition_Code__c,
                AAO_Proposition_Short__c,
                AAO_Proposition_Text__c,
                AAO_Elements__c,
                AAO_Element_Count__c,
                AAO_Route__c,
                AAO_Speaker_Requirement__c,
                AAO_Guidance_Text__c,
                AAO_Gating__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Rubric_Version__c = :RUBRIC_VERSION
            ORDER BY AAO_Proposition_Code__c ASC
        ]) {
            out.put(ec.AAO_Proposition_Code__c, ec);
        }
        return out;
    }
}