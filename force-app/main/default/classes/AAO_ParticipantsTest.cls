/**
 * The participant junction and the Subject_Person requirement, ruled v1.1.
 *
 * The behaviours worth holding are the ones that decide whether a coverage count is true:
 * that participation is recorded from arrival alone, that parts of one call are one
 * occasion rather than three, that re-ingesting cannot inflate a count, and that a
 * requirement naming a subject refuses a colleague speaking for them.
 */
@IsTest
private class AAO_ParticipantsTest {
    private static AAO_Demo.Ctx setUp() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        return AAO_Demo.scaffold();
    }

    private static AAO_Source__c partOf(AAO_Demo.Ctx c, String sha, Integer part, Datetime occurredAt) {
        return new AAO_Source__c(
            AAO_Opportunity__c = c.oppByDeal.get(AAO_Demo.OPP_LIVE),
            AAO_Account__c = c.acct.Id,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c = sha,
            AAO_Part_Index__c = part,
            AAO_Part_Count__c = 2,
            AAO_Evidence_Occurred__c = occurredAt,
            AAO_Normalized_Text__c = 'dana: we are aligned on the timeline.',
            AAO_Diarization__c = 'Attributed',
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{ 'speakers' => new List<Object>{
                    new Map<String, Object>{
                        'key' => 'dana',
                        'display' => 'Dana Ruiz',
                        'email' => 'dana.ruiz@northwind.example',
                        'contactId' => c.contactByKey.get('dana').Id
                    },
                    new Map<String, Object>{
                        'key' => 'sam',
                        'display' => 'Sam Patel',
                        'email' => 'sam.patel@altify.example'
                    }
                } }
            )
        );
    }

    private static String sha(String seed) {
        return EncodingUtil.convertToHex(
            Crypto.generateDigest('SHA-256', Blob.valueOf(seed))
        );
    }

    /**
     * The whole point of the object. Participation is a fact about the ARRIVAL of evidence,
     * so it is recorded whether or not a pipeline pass ever runs. Before this, "have we met
     * this person" could not be asked of the database at all.
     */
    @IsTest
    static void participationIsRecordedFromArrivalAloneAndIsQueryable() {
        AAO_Demo.Ctx c = setUp();

        Test.startTest();
        insert partOf(c, sha('call-one'), 1, Datetime.now().addDays(-3));
        Test.stopTest();

        List<AAO_Participant__c> rows = [
            SELECT AAO_Roster_Key__c, AAO_Contact__c, AAO_Internal__c, AAO_Artifact_SHA256__c
            FROM AAO_Participant__c
            ORDER BY AAO_Roster_Key__c
        ];
        System.assertEquals(2, rows.size(), 'One row per person on the artifact.');
        System.assertEquals('dana', rows[0].AAO_Roster_Key__c);
        System.assertNotEquals(
            null,
            rows[0].AAO_Contact__c,
            'A roster entry that resolves to a Contact links to it.'
        );
        System.assertEquals(false, rows[0].AAO_Internal__c, 'Dana is on the buying side.');
        System.assertEquals(
            true,
            rows[1].AAO_Internal__c,
            'And Coverage counts our side, so which side someone is on has to be recorded.'
        );
    }

    /**
     * THE SUBTLETY WORTH A TEST. A ninety-minute call arrives as several Source rows of one
     * artifact. Counting rows would report one conversation as two, which would inflate
     * every coverage answer that rests on a count. Occasions are DISTINCT ARTIFACTS.
     */
    @IsTest
    static void partsOfOneCallAreOneOccasionAndTwoCallsAreTwo() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        Id danaId = c.contactByKey.get('dana').Id;
        String one = sha('the-long-call');

        Test.startTest();
        insert new List<AAO_Source__c>{
            partOf(c, one, 1, Datetime.now().addDays(-5)),
            partOf(c, one, 2, Datetime.now().addDays(-5)),
            partOf(c, sha('a-separate-call'), 1, Datetime.now().addDays(-1))
        };
        Test.stopTest();

        System.assertEquals(
            6,
            [SELECT COUNT() FROM AAO_Participant__c],
            'Three Source rows, two people each.'
        );

        AAO_Participants.Coverage cov = AAO_Participants.coverage(oppId, danaId, null);
        System.assertEquals(
            2,
            cov.occasions,
            'Two conversations, not three. The split call is one occasion, which is the ' +
            'same source-event definition the sentiment counter uses.'
        );
        System.assertEquals(true, cov.met(), 'And question one is answerable.');
        System.assertNotEquals(null, cov.lastSeen, 'Recency falls out of the same read.');
    }

    /** Re-ingesting the same artifact must not inflate a count. */
    @IsTest
    static void reIngestingCannotDoubleCountAnybody() {
        AAO_Demo.Ctx c = setUp();
        AAO_Source__c s = partOf(c, sha('once'), 1, Datetime.now());
        insert s;
        Integer before = [SELECT COUNT() FROM AAO_Participant__c];

        Test.startTest();
        // The same Source, offered again. The unique key refuses it silently, which is the
        // merge path and not an error.
        AAO_Participants.record(
            new List<AAO_Source__c>{
                [
                    SELECT
                        Id,
                        AAO_Opportunity__c,
                        AAO_Account__c,
                        AAO_Speaker_Roster__c,
                        AAO_Evidence_Occurred__c,
                        AAO_Artifact_SHA256__c,
                        AAO_Duration_Seconds__c,
                        AAO_Substantive_Offset__c
                    FROM AAO_Source__c
                    WHERE Id = :s.Id
                ]
            },
            new Set<String>{ 'altify.example' }
        );
        Test.stopTest();

        System.assertEquals(
            before,
            [SELECT COUNT() FROM AAO_Participant__c],
            'Nothing added. Every coverage answer is a count, so a duplicate here is a ' +
            'wrong answer there.'
        );
    }

    /** A window bounds "recently" and "regularly" without any decay mechanism. */
    @IsTest
    static void theWindowIsAReadAndNothingDecays() {
        AAO_Demo.Ctx c = setUp();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        Id danaId = c.contactByKey.get('dana').Id;

        insert new List<AAO_Source__c>{
            partOf(c, sha('long-ago'), 1, Datetime.now().addDays(-200)),
            partOf(c, sha('lately'), 1, Datetime.now().addDays(-2))
        };

        Test.startTest();
        AAO_Participants.Coverage all = AAO_Participants.coverage(oppId, danaId, null);
        AAO_Participants.Coverage recent = AAO_Participants.coverage(
            oppId,
            danaId,
            Datetime.now().addDays(-30)
        );
        Test.stopTest();

        System.assertEquals(2, all.occasions, 'All of history.');
        System.assertEquals(
            1,
            recent.occasions,
            'The answer changed because the window moved, not because a job ground a ' +
            'number down. That is the no-decay ruling holding without a mechanism.'
        );
    }

    /** A participant row is not deletable: deleting one silently lowers a coverage answer. */
    @IsTest
    static void aParticipantRowIsNotDeletableOutsideAPurge() {
        AAO_Demo.Ctx c = setUp();
        insert partOf(c, sha('kept'), 1, Datetime.now());
        AAO_Participant__c p = [SELECT Id FROM AAO_Participant__c LIMIT 1];

        AAO_Synthetic.MARK = false;
        p.AAO_Synthetic__c = false;
        update p;

        String err;
        Test.startTest();
        try {
            delete p;
        } catch (DmlException e) {
            err = e.getDmlMessage(0);
        }
        Test.stopTest();

        System.assert(
            err != null && err.contains('not deletable'),
            'Got: ' + err
        );
    }

    // ============================================ Subject_Person, the third gap

    /**
     * Every other speaker requirement names a CLASS. This one names a SUBJECT, and the
     * difference is the whole point: Support Q2 and Q4 ask what THIS PERSON told you, so a
     * colleague vouching for them establishes nothing.
     */
    @IsTest
    static void subjectPersonRefusesAColleagueVouchingForSomeoneElse() {
        AAO_Demo.Ctx c = setUp();
        Contact dana = c.contactByKey.get('dana');
        Contact other = c.contactByKey.values()[0] == dana
            ? c.contactByKey.values()[1]
            : c.contactByKey.values()[0];

        AAO_Model.Speaker herself = new AAO_Model.Speaker();
        herself.display = 'Dana Ruiz';
        herself.email = 'dana.ruiz@northwind.example';
        herself.contactId = dana.Id;

        AAO_Model.Speaker colleague = new AAO_Model.Speaker();
        colleague.display = 'A Colleague';
        colleague.email = 'colleague@northwind.example';
        colleague.contactId = other.Id;

        Test.startTest();
        AAO_SpeakerRule.Verdict own = AAO_SpeakerRule.evaluate(
            'Subject_Person',
            herself,
            c.internalDomains,
            null,
            dana.Id
        );
        AAO_SpeakerRule.Verdict vouched = AAO_SpeakerRule.evaluate(
            'Subject_Person',
            colleague,
            c.internalDomains,
            null,
            dana.Id
        );
        AAO_SpeakerRule.Verdict noSubject = AAO_SpeakerRule.evaluate(
            'Subject_Person',
            herself,
            c.internalDomains,
            null,
            null
        );
        Test.stopTest();

        System.assertEquals(true, own.satisfied, own.reason);
        System.assert(own.reason.contains('themselves'), own.reason);

        System.assertEquals(
            false,
            vouched.satisfied,
            'Somebody speaking FOR Dana does not answer what Dana told you.'
        );
        System.assert(vouched.reason.contains('about someone else'), vouched.reason);

        System.assertEquals(
            false,
            noSubject.satisfied,
            'And with no subject to check against the requirement REFUSES rather than ' +
            'passes: a check that cannot run has not been met.'
        );
    }

    /** The other requirements are untouched by the new argument. */
    @IsTest
    static void theExistingRequirementsAreUnchangedByTheNewParameter() {
        AAO_Demo.Ctx c = setUp();
        AAO_Model.Speaker sp = new AAO_Model.Speaker();
        sp.display = 'Sam Patel';
        sp.email = 'sam.patel@altify.example';

        Test.startTest();
        System.assertEquals(
            true,
            AAO_SpeakerRule.evaluate('Seller', sp, c.internalDomains).satisfied
        );
        System.assertEquals(
            false,
            AAO_SpeakerRule.evaluate('Buyer_Side', sp, c.internalDomains, null).satisfied
        );
        Test.stopTest();
    }
}