/**
 * COVERAGE, and the one law it did not enforce until the thirty-eighth stamp.
 *
 * **This class did not exist before, and that is the finding it opens with.** Coverage has been
 * computed since 6 August and no test has ever asserted a coverage-derived value: a grep across
 * every `*Test.cls` finds no `ALTF__Coverage` assertion, no `DIM_COVERAGE`, and no
 * `writesByDimension` check for the dimension. The single existing `occasionsByPerson` call in
 * `AAO_ResolveTest` asserts that a MENTION row counts nothing. So the dimension's whole positive
 * behaviour was untested, and the divergence below survived three runs inside that blind spot.
 *
 * The divergence: `AAO_Internal__c` carried the description "Read by: Coverage" from the day it
 * was created, and `AAO_Coverage` never mentioned the field. The description was aspirational and
 * nothing failed, because nothing looked.
 */
@IsTest
private class AAO_CoverageTest {
    private static final String SHA =
        '00000000000000000000000000000000000000000000000000000000000000c0';

    private class Fixture {
        Id oppId;
        Id sourceId;
    }

    /** One call, two people on the roster: one of theirs, one of ours. */
    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Coverage Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Coverage Test Deal', AccountId = a.Id, StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;

        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = o.Id,
            AAO_Account__c = a.Id,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c = SHA,
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = 'Kayla: We are evaluating. Renee: Happy to help.',
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 7, 30, 15, 0, 0),
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{
                    'speakers' => new List<Object>{
                        new Map<String, Object>{
                            'key' => 'kayla', 'display' => 'Kayla Stanley',
                            'email' => 'kayla@customer.example'
                        },
                        new Map<String, Object>{
                            'key' => 'renee', 'display' => 'Renee Martin',
                            'email' => 'renee.martin@altify.com'
                        }
                    }
                }
            ),
            AAO_Synthetic__c = true
        );
        insert src;
        AAO_Synthetic.MARK = false;

        Fixture f = new Fixture();
        f.oppId = o.Id;
        f.sourceId = src.Id;
        return f;
    }

    private static AAO_Participant__c row(Id sourceId, String rosterKey) {
        return [
            SELECT Id, AAO_Internal__c, AAO_Roster_Key__c
            FROM AAO_Participant__c
            WHERE AAO_Source__c = :sourceId AND AAO_Roster_Key__c = :rosterKey
            LIMIT 1
        ];
    }

    @IsTest
    static void ourOwnSideDerivesNoCoverageAndTheirsStillDoes() {
        Fixture f = fixture();
        AAO_Participant__c ours = row(f.sourceId, 'renee');
        AAO_Participant__c theirs = row(f.sourceId, 'kayla');

        // Set the flag directly rather than relying on the internal-domain set reaching this
        // fixture: the thing under test is what COVERAGE does with the flag, not what the
        // participant writer does to set it. Those are two builds and this test owns one.
        ours.AAO_Internal__c = true;
        theirs.AAO_Internal__c = false;
        update new List<AAO_Participant__c>{ ours, theirs };

        Test.startTest();
        Map<Id, Integer> occasions = AAO_Coverage.occasionsByPerson(f.oppId);
        Test.stopTest();

        System.assertEquals(
            null,
            occasions.get(ours.Id),
            'An internal participant must derive NOTHING. Every guided question reads "have ' +
            'you or a team member met with this person", so a team member is the actor and ' +
            'never the subject; scoring one answers a question the wizard does not ask.'
        );
        System.assertEquals(
            1,
            occasions.get(theirs.Id),
            'And the buyer side is untouched: one call is one occasion. A guard that also ' +
            'silenced the people coverage exists for would be a worse defect than the one ' +
            'it repairs.'
        );
        System.assertEquals(
            AAO_Coverage.BRIEF,
            AAO_Coverage.valueFor(occasions.get(theirs.Id)),
            'One occasion is Brief contact, unchanged.'
        );
    }

    @IsTest
    static void theExclusionRidesBOTHQueriesSoTheRowSetsStayOneSet() {
        // `occasionsByPerson` reads participants twice: once to hash occasions, once to group
        // them by identity. The class already states the rule for the mention exclusion, "the
        // two row sets must be one set", and the internal conjunct rides it. If only the
        // grouping query were filtered, an internal row would leave an orphan hash; if only
        // the hash query were, `hashes.get(p.Id)` returns null and the addAll dereferences it.
        // A NullPointerException here is the shape that failure takes, so this asserts the
        // call completes AND that nothing leaks into the result.
        Fixture f = fixture();
        AAO_Participant__c ours = row(f.sourceId, 'renee');
        ours.AAO_Internal__c = true;
        update ours;

        Test.startTest();
        Map<Id, Integer> occasions = AAO_Coverage.occasionsByPerson(f.oppId);
        Test.stopTest();

        System.assertEquals(
            false,
            occasions.containsKey(ours.Id),
            'The internal row must be absent from the map entirely, not present with a null. ' +
            'Present-with-null would mean one query saw it and the other did not.'
        );
        System.assertEquals(
            1,
            occasions.size(),
            'Exactly the one external person survives. Got: ' + occasions
        );
    }

    @IsTest
    static void everyParticipantInternalMeansTheDimensionWritesNothingRatherThanThrowing() {
        // The all-internal call is the degenerate case, and it must reach the silence law
        // rather than an exception: zero occasions writes nothing.
        Fixture f = fixture();
        List<AAO_Participant__c> all = [
            SELECT Id, AAO_Internal__c FROM AAO_Participant__c WHERE AAO_Source__c = :f.sourceId
        ];
        for (AAO_Participant__c p : all) {
            p.AAO_Internal__c = true;
        }
        update all;

        Test.startTest();
        Map<Id, Integer> occasions = AAO_Coverage.occasionsByPerson(f.oppId);
        Test.stopTest();

        System.assertEquals(
            true, occasions.isEmpty(), 'No rows in, no counts out. Got: ' + occasions
        );
    }
}