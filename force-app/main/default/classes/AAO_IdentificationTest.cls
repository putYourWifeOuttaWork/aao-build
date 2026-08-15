/**
 * The Identification flag as a mechanism, tested at each of the five parts the ninetieth
 * stamp's item 10 names: type, raise at both held sites, bound key, clear-by-identification-
 * only, test.
 *
 * The schema test is first and is deliberate. The eighty-ninth and ninetieth stamps cost this
 * project a full session to a picklist value that existed in the tree and not in the org, and
 * to a green suite read as evidence of schema. A suite proves the tree self-consistent and
 * never that the org matches it, so this asserts the values through `Schema.describe`, which
 * is the running org's own answer and fails loudly if the deploy did not land.
 */
@IsTest
private class AAO_IdentificationTest {
    // ============================================================== 1 · the type exists

    @IsTest
    static void theTypeAndItsTwoCausesExistInTheRunningOrg() {
        Set<String> types = picklistValues(AAO_Flag__c.AAO_Type__c);
        System.assert(
            types.contains(AAO_Identification.TYPE),
            'AAO_Type__c carries no Identification value in this org. A picklist value is ' +
            'not the mechanism, but without it the mechanism cannot write a row. Got: ' + types
        );

        Set<String> causes = picklistValues(AAO_Flag__c.AAO_Cause__c);
        System.assert(
            causes.contains(AAO_Identification.CAUSE_AMBIGUOUS),
            'Identity_Ambiguous missing. Got: ' + causes
        );
        System.assert(
            causes.contains(AAO_Identification.CAUSE_UNRESOLVED),
            'Identity_Unresolved missing. Got: ' + causes
        );
    }

    /**
     * The two causes are not decoration: one asks a human to PICK between candidates and the
     * other asks them to NAME somebody the org has never heard of. Those are different work,
     * so a surface that collapsed them would send the seller to the wrong task.
     */
    @IsTest
    static void theTwoCausesAreDistinctAndSurviveTheRoundTrip() {
        Fixture f = fixture();
        Test.startTest();
        AAO_Identification.raiseFor(
            new List<AAO_Identification.Held>{
                held(f, 'Priya', AAO_Identification.CAUSE_UNRESOLVED),
                held(f, 'Jordan', AAO_Identification.CAUSE_AMBIGUOUS)
            }
        );
        Test.stopTest();

        Map<String, String> causeByKey = new Map<String, String>();
        for (AAO_Flag__c fl : [
            SELECT AAO_Bound_Key__c, AAO_Cause__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :f.oppId AND AAO_Type__c = 'Identification'
        ]) {
            causeByKey.put(fl.AAO_Bound_Key__c, fl.AAO_Cause__c);
        }
        System.assertEquals(2, causeByKey.size(), causeByKey.toString());
        System.assert(
            causeByKey.values().contains(AAO_Identification.CAUSE_UNRESOLVED)
            && causeByKey.values().contains(AAO_Identification.CAUSE_AMBIGUOUS),
            'Both causes must survive: ' + causeByKey
        );
    }

    // ============================================================== 2 · the bound key

    /**
     * Priya mentioned in session 3 and again in session 4 is ONE unidentified person. The
     * bound key is what makes the surface say that instead of stacking a red per mention.
     */
    @IsTest
    static void oneDesignatorRaisesOneFlagHoweverOftenItIsMentioned() {
        Fixture f = fixture();

        Test.startTest();
        Integer first = AAO_Identification.raiseFor(
            new List<AAO_Identification.Held>{ held(f, 'Priya', null) }
        );
        Integer second = AAO_Identification.raiseFor(
            new List<AAO_Identification.Held>{ held(f, 'Priya', null) }
        );
        // Same human, different casing and spacing, which is what a second transcript
        // actually looks like.
        Integer third = AAO_Identification.raiseFor(
            new List<AAO_Identification.Held>{ held(f, '  priya  ', null) }
        );
        Test.stopTest();

        System.assertEquals(1, first, 'the first mention raises');
        System.assertEquals(0, second, 'the same mention raises nothing');
        System.assertEquals(0, third, 'normalisation makes "  priya  " the same person');
        System.assertEquals(
            1,
            AAO_Identification.standing(f.oppId),
            'One person, one flag, three mentions.'
        );
    }

    // ================================================ 3 · clear by identification ONLY

    @IsTest
    static void itDoesNotClearWhileNobodyIsBound() {
        Fixture f = fixture();
        AAO_Identification.raiseFor(
            new List<AAO_Identification.Held>{ held(f, 'Priya', null) }
        );

        Test.startTest();
        Integer cleared = AAO_Identification.reconcile(f.oppId);
        Test.stopTest();

        System.assertEquals(0, cleared, 'nothing identified Priya, so nothing clears');
        System.assertEquals(
            1,
            AAO_Identification.standing(f.oppId),
            'A reconcile that finds no binding must leave the flag exactly where it was.'
        );
    }

    /**
     * THE CORE. The flag clears when, and only when, the designator is bound to a Contact,
     * and the Contact that did it is recorded on the row as the receipt.
     */
    @IsTest
    static void itClearsWhenTheLadderBindsTheDesignatorToAContact() {
        Fixture f = fixture();
        AAO_Identification.raiseFor(
            new List<AAO_Identification.Held>{ held(f, 'Priya', null) }
        );
        System.assertEquals(1, AAO_Identification.standing(f.oppId));

        // The binding a later run produces: a pair carrying the designator now points at a
        // participant that carries a Contact.
        bindDesignator(f, 'Priya');

        Test.startTest();
        Integer cleared = AAO_Identification.reconcile(f.oppId);
        Test.stopTest();

        System.assertEquals(1, cleared, 'the binding clears it');
        System.assertEquals(0, AAO_Identification.standing(f.oppId));

        AAO_Flag__c fl = [
            SELECT AAO_State__c, AAO_Cleared_At__c, AAO_Subject_Contact__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :f.oppId AND AAO_Type__c = 'Identification'
            LIMIT 1
        ];
        System.assertEquals('Cleared', fl.AAO_State__c);
        System.assertNotEquals(null, fl.AAO_Cleared_At__c);
        System.assertEquals(
            f.contactId,
            fl.AAO_Subject_Contact__c,
            'The clear carries its receipt: WHO this turned out to be. A cleared flag that ' +
            'cannot say who was identified is an assertion, not a record.'
        );
    }

    /**
     * The whole reason the flag is worth building. `AAO_Flags` says it of methodological
     * flags in its own header - "nothing here accepts a gesture" - and the same holds here:
     * a human writing an acknowledgement has not done the work.
     */
    @IsTest
    static void anAcknowledgementDoesNotClearIt() {
        Fixture f = fixture();
        AAO_Identification.raiseFor(
            new List<AAO_Identification.Held>{ held(f, 'Priya', null) }
        );

        AAO_Flag__c fl = [
            SELECT Id FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :f.oppId AND AAO_Type__c = 'Identification' LIMIT 1
        ];
        fl.AAO_Acknowledgement_Text__c = 'Seen it, will get to it';
        fl.AAO_Acknowledged_At__c = System.now();
        update fl;

        Test.startTest();
        Integer cleared = AAO_Identification.reconcile(f.oppId);
        Test.stopTest();

        System.assertEquals(0, cleared, 'a gesture is not an identification');
        System.assertEquals(
            1,
            AAO_Identification.standing(f.oppId),
            'The flag clears by identification only. Acknowledging it changes nothing about ' +
            'whether anybody knows who this person is.'
        );
    }

    /**
     * A person identified in session 4 and mentioned again in session 5 is not a new problem.
     * Re-opening would make the map flicker for a reason nobody could act on.
     */
    @IsTest
    static void aClearedFlagIsNotReopenedByALaterMention() {
        Fixture f = fixture();
        AAO_Identification.raiseFor(
            new List<AAO_Identification.Held>{ held(f, 'Priya', null) }
        );
        bindDesignator(f, 'Priya');
        AAO_Identification.reconcile(f.oppId);
        System.assertEquals(0, AAO_Identification.standing(f.oppId), 'cleared first');

        Test.startTest();
        Integer raised = AAO_Identification.raiseFor(
            new List<AAO_Identification.Held>{ held(f, 'Priya', null) }
        );
        Test.stopTest();

        System.assertEquals(0, raised);
        System.assertEquals(
            0,
            AAO_Identification.standing(f.oppId),
            'Mentioning an identified person again must not reopen their flag.'
        );
    }

    // ================================ 4 · the resolver collects and does not raise

    /**
     * The DML-before-callout boundary is real code in `AAO_Resolve.requests()`, which throws
     * if any DML has run in the transaction. So the held sites COLLECT and the caller raises.
     * This asserts the contract at the source rather than trusting the comment that states it.
     */
    @IsTest
    static void theResolverCollectsAndNeverRaisesSoTheCalloutBoundaryHolds() {
        List<ApexClass> body = [
            SELECT Body FROM ApexClass WHERE Name = 'AAO_Resolve' LIMIT 1
        ];
        if (body.isEmpty() || body[0].Body == null || body[0].Body == '(hidden)') {
            return; // Body is unreadable in a packaged context; nothing to assert against.
        }
        String src = body[0].Body;
        System.assert(
            src.contains('AAO_Identification.Held'),
            'AAO_Resolve must collect held mentions for the flag.'
        );
        System.assert(
            !src.contains('AAO_Identification.raiseFor'),
            'AAO_Resolve must NOT raise. Raising is DML, and requests() throws when DML has ' +
            'already run in the transaction, so a raise here would arm the very guard that ' +
            'protects the callout. The caller raises.'
        );
    }

    // ========================================================================== fixture

    private class Fixture {
        Id acctId;
        Id oppId;
        Id contactId;
        Id sourceId;
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        Fixture f = new Fixture();
        Account a = new Account(Name = 'AAO Identification Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Identification Test Deal',
            AccountId = a.Id,
            StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        Contact c = new Contact(
            FirstName = 'Priya', LastName = 'Natarajan', AccountId = a.Id,
            Email = 'priya@customer.example'
        );
        insert c;
        f.acctId = a.Id;
        f.oppId = o.Id;
        f.contactId = c.Id;
        return f;
    }

    private static AAO_Identification.Held held(Fixture f, String designator, String cause) {
        AAO_Identification.Held h = new AAO_Identification.Held();
        h.opportunityId = f.oppId;
        h.accountId = f.acctId;
        h.designator = designator;
        h.cause = cause == null ? AAO_Identification.CAUSE_UNRESOLVED : cause;
        h.basis = 'Named in the evidence with no match in the org.';
        h.occurred = Datetime.newInstanceGmt(2026, 8, 5, 18, 0, 0);
        return h;
    }

    /**
     * The shape a later run leaves behind once the ladder links the designator: a pair whose
     * `AAO_Person__c` is a participant carrying the Contact. Participation is written by the
     * Source after-insert and never by hand, so this builds a Source and reads the row back.
     */
    private static void bindDesignator(Fixture f, String designator) {
        AAO_Synthetic.MARK = true;
        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c =
                'aa00000000000000000000000000000000000000000000000000000000000001',
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = 'priya\tSomething was said.',
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 8, 19, 14, 0, 0),
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{
                    'speakers' => new List<Object>{
                        new Map<String, Object>{
                            'key' => 'priya',
                            'display' => 'Priya Natarajan',
                            'email' => 'priya@customer.example'
                        }
                    }
                }
            ),
            AAO_Synthetic__c = true
        );
        insert src;
        AAO_Synthetic.MARK = false;
        f.sourceId = src.Id;

        AAO_Participant__c p = [
            SELECT Id, AAO_Contact__c
            FROM AAO_Participant__c
            WHERE AAO_Source__c = :src.Id
            LIMIT 1
        ];
        System.assertEquals(
            f.contactId,
            p.AAO_Contact__c,
            'The fixture is only meaningful if the roster resolved to the seeded Contact.'
        );

        // THE LAWFUL TWO-ROW SHAPE, and the org taught it to this fixture by refusing the
        // one-row version. Call 1 writes the designator onto a Located pair and is forbidden
        // the person; call 2 writes the person onto an Identified pair pointing back at it
        // and is forbidden the located-only fields. `AAO_PairTriggerHandler` enforces both
        // with `addError`. The first draft of this fixture put both on one row, the insert
        // was refused, and the refusal exposed a real defect in the class it was testing:
        // the clear path was querying a shape that cannot exist.
        AAO_Pair__c located = new AAO_Pair__c(
            AAO_Stage__c = 'Located',
            AAO_Run_Key__c = 'ident-test',
            AAO_Pair_Ref__c = 'r1q1',
            AAO_Charter__c = 'AAO_LocateCharter',
            AAO_Charter_Version__c = 'locate-4.0.0',
            AAO_Source__c = src.Id,
            AAO_Artifact_SHA256__c = src.AAO_SHA256__c,
            AAO_Answer_Text__c = 'Something was said.',
            AAO_About_Designator__c = designator,
            AAO_Start_Offset__c = 6,
            AAO_End_Offset__c = 25,
            AAO_Occurrence__c = 1
        );
        insert located;

        insert new AAO_Pair__c(
            AAO_Stage__c = 'Identified',
            AAO_Run_Key__c = 'ident-test',
            AAO_Pair_Ref__c = 'r1q1',
            AAO_Charter__c = 'People',
            AAO_Charter_Version__c = 'resolve-1.0.0',
            AAO_Located_Pair__c = located.Id,
            AAO_Source__c = src.Id,
            AAO_Artifact_SHA256__c = src.AAO_SHA256__c,
            AAO_Disposition__c = 'Identified',
            AAO_Person__c = p.Id,
            AAO_Identification_Basis__c = 'The ladder linked it on a later read.'
        );
    }

    private static Set<String> picklistValues(Schema.SObjectField field) {
        Set<String> out = new Set<String>();
        for (Schema.PicklistEntry e : field.getDescribe().getPicklistValues()) {
            out.add(e.getValue());
        }
        return out;
    }
}
