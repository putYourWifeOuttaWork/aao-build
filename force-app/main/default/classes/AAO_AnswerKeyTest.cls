/**
 * Written before AAO_AnswerKey, per the build brief: the two key composers are the
 * highest-risk code in this build.
 *
 * The two failure modes the brief names by hand:
 *   - how an unpopulated lookup renders. Empty against a literal is the trap: it
 *     turns "no subject" into a silently valid key.
 *   - two rows that should collide stop colliding. The live version of this is the
 *     15-versus-18-character Id, which would give one subject two answer rows and
 *     quietly break the read-before-write that human precedence depends on.
 */
@IsTest
private class AAO_AnswerKeyTest {
    private static final Id CONTRACT = AAO_FakeId.of('a00');

    // ------------------------------------------------ two rows that should collide

    @IsTest
    static void sameSubjectExpressedShortAndLongProducesOneKey() {
        Id long18 = AAO_FakeId.of(Contact.SObjectType);
        Id short15 = AAO_FakeId.shortForm(long18);

        String a = AAO_AnswerKey.compose('Contact', long18, CONTRACT);
        String b = AAO_AnswerKey.compose('Contact', short15, CONTRACT);

        System.assertEquals(
            a,
            b,
            'A 15-character Id and its 18-character form are the same subject. If these ' +
            'keys differ, one subject gets two answer rows and human precedence stops ' +
            'being enforceable.'
        );
    }

    @IsTest
    static void sameSubjectAndContractCollidesEveryTime() {
        Id c = AAO_FakeId.of(Contact.SObjectType);
        System.assertEquals(
            AAO_AnswerKey.compose('Contact', c, CONTRACT),
            AAO_AnswerKey.compose('Contact', c, CONTRACT),
            'The composer is deterministic. Same inputs, same key, always.'
        );
    }

    // -------------------------------------------- rows that must not collide, do not

    @IsTest
    static void subjectTypeDiscriminatesEvenOnTheSameId() {
        Id shared = AAO_FakeId.of(Opportunity.SObjectType);
        System.assertNotEquals(
            AAO_AnswerKey.compose('Opportunity', shared, CONTRACT),
            AAO_AnswerKey.compose('Contact', shared, CONTRACT),
            'Subject type is the discriminator. Without it, opportunity-grain and ' +
            'person-grain rows are indistinguishable.'
        );
    }

    @IsTest
    static void differentContractsDoNotCollide() {
        Id c = AAO_FakeId.of(Contact.SObjectType);
        System.assertNotEquals(
            AAO_AnswerKey.compose('Contact', c, CONTRACT),
            AAO_AnswerKey.compose('Contact', c, AAO_FakeId.of('a00'))
        );
    }

    // ---------------------------------------- how an unpopulated lookup renders

    @IsTest
    static void nullSubjectThrowsAndNeverRendersEmpty() {
        try {
            String k = AAO_AnswerKey.compose('Contact', null, CONTRACT);
            System.assert(
                false,
                'A null subject rendered as a key instead of throwing. It produced: "' +
                k +
                '". An empty rendering makes every subjectless row of this type collide ' +
                'on one key.'
            );
        } catch (AAO_AnswerKey.KeyException e) {
            System.assert(
                e.getMessage().contains('subject'),
                'Expected the message to name the missing subject, got: ' + e.getMessage()
            );
        }
    }

    @IsTest
    static void nullContractThrows() {
        try {
            AAO_AnswerKey.compose('Contact', AAO_FakeId.of(Contact.SObjectType), null);
            System.assert(false, 'A null contract must not compose.');
        } catch (AAO_AnswerKey.KeyException e) {
            System.assert(e.getMessage().contains('contract'), e.getMessage());
        }
    }

    @IsTest
    static void blankSubjectTypeThrows() {
        try {
            AAO_AnswerKey.compose(null, AAO_FakeId.of(Contact.SObjectType), CONTRACT);
            System.assert(false, 'A null subject type must not compose.');
        } catch (AAO_AnswerKey.KeyException e) {
            System.assert(e.getMessage().contains('subject type'), e.getMessage());
        }
    }

    @IsTest
    static void unknownSubjectTypeThrowsRatherThanGuessing() {
        try {
            AAO_AnswerKey.compose('Sasquatch', AAO_FakeId.of(Contact.SObjectType), CONTRACT);
            System.assert(false, 'An unrecognised subject type must not compose.');
        } catch (AAO_AnswerKey.KeyException e) {
            System.assert(e.getMessage().contains('Sasquatch'), e.getMessage());
        }
    }

    /**
     * Four of the six subject types have no lookup on the objects yet, because the
     * target objects are Wave 2 or are managed objects whose API names have not been
     * read from the org. The composer must say so rather than compose something that
     * looks right.
     */
    @IsTest
    static void unwiredSubjectTypesThrowNamed() {
        for (String t : new List<String>{
            'Shadow_Person',
            'Insight_Card',
            'Qualifier',
            'Decision_Criterion'
        }) {
            AAO_Answer__c a = new AAO_Answer__c(
                AAO_Subject_Type__c = t,
                AAO_Evidence_Contract__c = CONTRACT
            );
            try {
                AAO_AnswerKey.compose(a);
                System.assert(false, t + ' composed a key from a lookup that does not exist yet.');
            } catch (AAO_AnswerKey.KeyException e) {
                System.assert(
                    e.getMessage().contains('not wired'),
                    'Expected an unwired-subject message for ' + t + ', got: ' + e.getMessage()
                );
            }
        }
    }

    // ------------------------------------------------------------ shape and budget

    @IsTest
    static void keyFitsTheFieldAndCarriesItsVersion() {
        String k = AAO_AnswerKey.compose(
            'Contact',
            AAO_FakeId.of(Contact.SObjectType),
            CONTRACT
        );
        System.assert(
            k.startsWith(AAO_AnswerKey.VERSION + AAO_AnswerKey.SEP),
            'Every key carries its composer version, so a later composer is detectable ' +
            'rather than silently mixed in. Got: ' + k
        );
        System.assert(
            k.length() <= 120,
            'AAO_Answer_Key__c is Text(120). This key was ' + k.length() + ': ' + k
        );
    }

    @IsTest
    static void longestPossibleKeyStillFits() {
        // Decision_Criterion is the longest subject type value. The pure core does not
        // check wiring, because wiring is only a question when resolving a lookup from
        // a record.
        String k = AAO_AnswerKey.compose(
            'Decision_Criterion',
            AAO_FakeId.of(Contact.SObjectType),
            CONTRACT
        );
        System.assert(k.length() <= 120, 'Worst case was ' + k.length() + ': ' + k);
    }

    @IsTest
    static void separatorCannotAppearInAnyComponent() {
        String k = AAO_AnswerKey.compose(
            'Contact',
            AAO_FakeId.of(Contact.SObjectType),
            CONTRACT
        );
        System.assertEquals(
            3,
            k.countMatches(AAO_AnswerKey.SEP),
            'Exactly three separators. If a component could contain the separator the ' +
            'key would be ambiguous. Got: ' + k
        );
    }

    // ------------------------------------------------- the same function, both rows

    @IsTest
    static void answerAndClaimComposeIdentically() {
        Id c = AAO_FakeId.of(Contact.SObjectType);

        AAO_Answer__c a = new AAO_Answer__c(
            AAO_Subject_Type__c = 'Contact',
            AAO_Subject_Contact__c = c,
            AAO_Evidence_Contract__c = CONTRACT
        );
        AAO_Claim__c cl = new AAO_Claim__c(
            AAO_Subject_Type__c = 'Contact',
            AAO_Subject_Contact__c = c,
            AAO_Evidence_Contract__c = CONTRACT
        );

        System.assertEquals(
            AAO_AnswerKey.compose(a),
            AAO_AnswerKey.compose(cl),
            'Subject identity on Claim is composed by the same frozen function as on ' +
            'Answer. Without that, replay cannot reconstruct the mirror.'
        );
    }

    @IsTest
    static void opportunitySubjectUsesTheRowsOwnOpportunity() {
        Id opp = AAO_FakeId.of(Opportunity.SObjectType);
        AAO_Answer__c a = new AAO_Answer__c(
            AAO_Subject_Type__c = 'Opportunity',
            AAO_Opportunity__c = opp,
            AAO_Evidence_Contract__c = CONTRACT
        );
        System.assertEquals(
            AAO_AnswerKey.compose('Opportunity', opp, CONTRACT),
            AAO_AnswerKey.compose(a),
            'A deal-grain proposition has no typed person lookup; its subject is the ' +
            'opportunity the row is already scoped to.'
        );
    }

    @IsTest
    static void aStrayTypedLookupIsRejected() {
        AAO_Answer__c a = new AAO_Answer__c(
            AAO_Subject_Type__c = 'Opportunity',
            AAO_Opportunity__c = AAO_FakeId.of(Opportunity.SObjectType),
            AAO_Subject_Contact__c = AAO_FakeId.of(Contact.SObjectType),
            AAO_Evidence_Contract__c = CONTRACT
        );
        try {
            AAO_AnswerKey.compose(a);
            System.assert(
                false,
                'A contact lookup populated on an opportunity-subject row is ambiguous ' +
                'about what the row is about, and the key would hide it.'
            );
        } catch (AAO_AnswerKey.KeyException e) {
            System.assert(e.getMessage().contains('exactly one'), e.getMessage());
        }
    }
}
