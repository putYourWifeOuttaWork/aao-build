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
     * The seven subject types, and which typed lookup carries the subject for each.
     * Two are unwired: Insight Card and Qualifier are managed objects whose API names have
     * not been read from altify--aossb2. Guessing them would violate evidence over inference
     * about schema, so they throw by name instead.
     *
     * DECISION_CRITERION IS WIRED AT ADDENDUM 20, and it points at OUR criterion ledger
     * rather than at ALTF__Decision_Criteria__c. Two reasons, both standing law: the system
     * runs with Altify absent, so a subject at a managed object would make the whole criteria
     * path require a package; and claims land on our objects before anything is projected, so
     * a subject that IS the vendor row would need that row to exist before the claim that
     * establishes it. **The person stays on the row as owner, never as key** - the exception
     * below.
     *
     * SHADOW_PERSON IS WIRED AT ADDENDUM 19, pulled forward from Wave 2. Read the narrowing
     * with it: addendum 18 put the live person key on the Participant, which covers the same
     * people and covers them EARLIER, because participation is written at ingest and a shadow
     * is made at projection. So this type composes a key and is not what the pass writes.
     *
     * PARTICIPANT ENTERS AT ADDENDUM 18, and it is additive rather than a migration: no
     * key already in the org changes shape, because no key already in the org carries this
     * type. The ruling put the Claim on the Participant; the Answer follows because the
     * replay invariant is that claims in evidence-occurred order reconstruct the answer
     * EXACTLY, and an answer keyed on a Contact cannot be reconstructed from claims keyed
     * on a person who has no Contact. Jefferson Vargas is the specimen in both directions.
     */
    private static final Map<String, String> SUBJECT_LOOKUP = new Map<String, String>{
        'Opportunity' => 'AAO_Opportunity__c',
        'Contact' => 'AAO_Subject_Contact__c',
        'Participant' => 'AAO_Participant__c',
        'Shadow_Person' => 'AAO_Shadow_Person__c',
        'Decision_Criterion' => 'AAO_Criterion__c',
        'Insight_Card' => null,
        'Qualifier' => null
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
            a.AAO_Subject_Contact__c,
            a.AAO_Participant__c,
            a.AAO_Shadow_Person__c,
            a.AAO_Criterion__c
        );
    }

    public static String compose(AAO_Claim__c c) {
        return composeFromRow(
            c.AAO_Subject_Type__c,
            c.AAO_Evidence_Contract__c,
            c.AAO_Opportunity__c,
            c.AAO_Subject_Contact__c,
            c.AAO_Participant__c,
            c.AAO_Shadow_Person__c,
            c.AAO_Criterion__c
        );
    }

    public static String compose(AAO_Candidate__c c) {
        return composeFromRow(
            c.AAO_Subject_Type__c,
            c.AAO_Evidence_Contract__c,
            c.AAO_Opportunity__c,
            c.AAO_Subject_Contact__c,
            c.AAO_Participant__c,
            c.AAO_Shadow_Person__c,
            c.AAO_Criterion__c
        );
    }

    private static String composeFromRow(
        String subjectType,
        Id contractId,
        Id opportunityId,
        Id subjectContactId,
        Id participantId,
        Id shadowPersonId,
        Id criterionId
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
        //
        // **A CONTACT BESIDE A PARTICIPANT IS NOT A STRAY, and it is the one exception.**
        // Addendum 18 kept AAO_Subject_Contact__c on a participant-keyed row deliberately,
        // to carry the resolved Contact where one exists - a Contact is a resolution
        // outcome of that person, not a second subject. Refusing it here would force the
        // join to choose between recording the resolution and composing a key, and the
        // resolution is what projection reads to find the map row. The reverse stray still
        // throws: a Participant on a Contact-keyed row means two identities on one answer.
        Id resolved;
        if (subjectType == 'Opportunity') {
            resolved = opportunityId;
        } else if (subjectType == 'Participant') {
            resolved = participantId;
        } else if (subjectType == 'Shadow_Person') {
            resolved = shadowPersonId;
        } else if (subjectType == 'Decision_Criterion') {
            resolved = criterionId;
        } else {
            resolved = subjectContactId;
        }

        // **A PARTICIPANT ON A CRITERION ROW IS THE OWNER, NOT A SECOND SUBJECT.** Addendum
        // 20 states it directly: the criterion is the key and the person stays on the row as
        // owner. A criteria answer without its voicer would lose the one thing that makes a
        // criterion actionable - whose criterion it is - and the holder junction at
        // projection is written from exactly that field.
        Boolean ownerNotSubject =
            subjectType == 'Decision_Criterion' || subjectType == 'Participant';

        Boolean strayContact =
            subjectType != 'Contact' && !ownerNotSubject && subjectContactId != null;
        if (subjectType != 'Shadow_Person' && shadowPersonId != null) {
            throw new KeyException(
                'A row with subject type "' +
                subjectType +
                '" must express exactly one subject, but AAO_Shadow_Person__c is also ' +
                'populated.'
            );
        }
        if (subjectType != 'Decision_Criterion' && criterionId != null) {
            throw new KeyException(
                'A row with subject type "' +
                subjectType +
                '" must express exactly one subject, but AAO_Criterion__c is also populated.'
            );
        }
        if (strayContact) {
            throw new KeyException(
                'A row with subject type "' +
                subjectType +
                '" must express exactly one subject, but AAO_Subject_Contact__c is also ' +
                'populated.'
            );
        }
        if (!ownerNotSubject && participantId != null) {
            throw new KeyException(
                'A row with subject type "' +
                subjectType +
                '" must express exactly one subject, but AAO_Participant__c is also ' +
                'populated. A participant-keyed row may carry its resolved Contact; a ' +
                'Contact-keyed row may not carry a participant, because that is two ' +
                'identities on one answer and only one of them can be the key.'
            );
        }
        return compose(subjectType, resolved, contractId);
    }

    /** True where the subject type has a lookup on our objects today. */
    public static Boolean isWired(String subjectType) {
        return SUBJECT_LOOKUP.get(subjectType) != null;
    }
}