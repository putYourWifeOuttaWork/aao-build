/**
 * The frozen composer for AAO_Answer_Key__c, and for the identical subject identity on
 * AAO_Claim__c.
 *
 * Deterministic, frozen, versioned, single-writer, case-sensitive. Deliberately not a
 * formula field: a formula recomputes on read and would silently change meaning under a
 * schema change, which for a uniqueness key means the merge path stops firing and human
 * precedence stops being enforceable without anything appearing to break.
 *
 * Shape:  A1|<SubjectType>|<Subject Id, 18>|<Evidence Contract Id, 18>
 * Budget: 2 + 1 + 18 + 1 + 18 + 1 + 18 = 59 of the 120 the field allows.
 *
 * Never change VERSION and the shape in the same edit without a migration: keys already
 * in the org were composed by the version they carry.
 */
public class AAO_AnswerKey {
    public class KeyException extends Exception {
    }

    public static final String VERSION = 'A1';
    public static final String SEP = '|';

    /**
     * The six subject types, and which typed lookup carries the subject for each.
     * Four are unwired: AAO_Shadow_Person__c is Wave 2, and Insight Card, Qualifier and
     * Decision Criterion are managed objects whose API names have not been read from
     * altify--aossb2. Guessing them would violate evidence over inference about schema,
     * so they throw by name instead.
     */
    private static final Map<String, String> SUBJECT_LOOKUP = new Map<String, String>{
        'Opportunity' => 'AAO_Opportunity__c',
        'Contact' => 'AAO_Subject_Contact__c',
        'Shadow_Person' => null,
        'Insight_Card' => null,
        'Qualifier' => null,
        'Decision_Criterion' => null
    };

    // ------------------------------------------------------------------ pure core

    public static String compose(String subjectType, Id subjectId, Id contractId) {
        if (String.isBlank(subjectType)) {
            throw new KeyException('Cannot compose an answer key with no subject type.');
        }
        if (!SUBJECT_LOOKUP.containsKey(subjectType)) {
            throw new KeyException(
                'Cannot compose an answer key for unrecognised subject type "' +
                subjectType +
                '". Known types: ' +
                String.join(new List<String>(SUBJECT_LOOKUP.keySet()), ', ')
            );
        }
        if (subjectId == null) {
            throw new KeyException(
                'Cannot compose an answer key with no subject. Subject type was "' +
                subjectType +
                '". An empty rendering would collide every subjectless row of this type ' +
                'onto one key.'
            );
        }
        if (contractId == null) {
            throw new KeyException(
                'Cannot compose an answer key with no evidence contract.'
            );
        }
        // String.valueOf on an Id always yields the 18-character form, which is what
        // makes a 15-character input and its 18-character form one key.
        return VERSION +
            SEP +
            subjectType +
            SEP +
            String.valueOf(subjectId) +
            SEP +
            String.valueOf(contractId);
    }

    // ------------------------------------------------------- the same key, two rows

    public static String compose(AAO_Answer__c a) {
        return composeFromRow(
            a.AAO_Subject_Type__c,
            a.AAO_Evidence_Contract__c,
            a.AAO_Opportunity__c,
            a.AAO_Subject_Contact__c
        );
    }

    public static String compose(AAO_Claim__c c) {
        return composeFromRow(
            c.AAO_Subject_Type__c,
            c.AAO_Evidence_Contract__c,
            c.AAO_Opportunity__c,
            c.AAO_Subject_Contact__c
        );
    }

    public static String compose(AAO_Candidate__c c) {
        return composeFromRow(
            c.AAO_Subject_Type__c,
            c.AAO_Evidence_Contract__c,
            c.AAO_Opportunity__c,
            c.AAO_Subject_Contact__c
        );
    }

    private static String composeFromRow(
        String subjectType,
        Id contractId,
        Id opportunityId,
        Id subjectContactId
    ) {
        if (String.isBlank(subjectType)) {
            throw new KeyException('Cannot compose an answer key with no subject type.');
        }
        if (!SUBJECT_LOOKUP.containsKey(subjectType)) {
            throw new KeyException(
                'Cannot compose an answer key for unrecognised subject type "' +
                subjectType +
                '".'
            );
        }
        if (SUBJECT_LOOKUP.get(subjectType) == null) {
            throw new KeyException(
                'Subject type "' +
                subjectType +
                '" is not wired: it has no typed lookup on this object yet. Wave 2, or ' +
                'the managed object API name has not been read from the org. Refusing to ' +
                'compose a key that would look right.'
            );
        }

        // Exactly one subject may be expressed on a row. A stray lookup means the row
        // is ambiguous about what it is an answer to, and a key that ignored the stray
        // would hide that.
        Id resolved = subjectType == 'Opportunity' ? opportunityId : subjectContactId;
        Boolean strayContact = subjectType != 'Contact' && subjectContactId != null;
        if (strayContact) {
            throw new KeyException(
                'A row with subject type "' +
                subjectType +
                '" must express exactly one subject, but AAO_Subject_Contact__c is also ' +
                'populated.'
            );
        }
        return compose(subjectType, resolved, contractId);
    }

    /** True where the subject type has a lookup on our objects today. */
    public static Boolean isWired(String subjectType) {
        return SUBJECT_LOOKUP.get(subjectType) != null;
    }
}
