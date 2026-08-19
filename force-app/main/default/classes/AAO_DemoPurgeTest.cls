/**
 * THE PURGE TAKES THE BOARD'S COLUMNS DOWN WITH THE CARDS, AND LEAVES A PERSON'S OWN COLUMN
 * STANDING.
 *
 * Matthew saw it on the board: three sections, one per call, still standing after a purge that
 * had correctly removed every record under them. A reset that leaves empty headings reads as a
 * reset that half-worked.
 *
 * The section is a VENDOR object and carries no watermark of ours, so ours-ness cannot be read
 * off the row - it has to be PROVED, and the only available proof is that the title is exactly
 * the one the writer composes. That makes the two halves below the whole behaviour, and the
 * second half is the one that matters more: `sectionFor` matches on the date PREFIX so a human's
 * better title survives the next run, and the purge must honour the same law or the fifty-second
 * stamp's ruling holds on writes and is revoked on deletes.
 */
@IsTest
private class AAO_DemoPurgeTest {

    private static final Datetime OCCURRED = Datetime.newInstanceGmt(2026, 7, 30, 15, 0, 0);

    private static Opportunity deal() {
        Account a = new Account(Name = 'AAO Purge Test Account');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Purge Test Deal', AccountId = a.Id, StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        insert new AAO_Source__c(
            AAO_Opportunity__c = o.Id,
            AAO_Account__c = a.Id,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c = 'a'.repeat(64),
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = 'Kayla: We are evaluating.',
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = OCCURRED,
            AAO_Meeting_Title__c = 'Brightwell discovery, call 1',
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{
                    'speakers' => new List<Object>{
                        new Map<String, Object>{
                            'key' => 'kayla', 'display' => 'Kayla Stanley',
                            'email' => 'kayla@customer.example'
                        }
                    }
                }
            )
        );
        return o;
    }

    // The Account is REQUIRED on a section, which the org taught on the first run of this test.
    private static Id section(Opportunity o, String title) {
        ALTF__Insight_Section__c s = new ALTF__Insight_Section__c(
            ALTF__Opportunity__c = o.Id,
            ALTF__Account__c = o.AccountId,
            ALTF__Short_Description__c = title,
            ALTF__X_Coordinate__c = 1
        );
        insert s;
        return s.Id;
    }

    @IsTest
    static void theColumnTHEWRITERTITLEDGoesDownWithItsCards() {
        Opportunity o = deal();
        AAO_Source__c src = [
            SELECT AAO_Evidence_Occurred__c, AAO_Meeting_Title__c
            FROM AAO_Source__c WHERE AAO_Opportunity__c = :o.Id LIMIT 1
        ];
        Id ours = section(o, AAO_Cards.sectionTitle(src, null));

        Test.startTest();
        String report = AAO_DemoController.purgeDeal(o.Id);
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM ALTF__Insight_Section__c WHERE Id = :ours],
            'The purge asks the writer what it would have titled this call\'s column and takes ' +
            'exactly that one down. Left standing, it is an empty heading on a reset board. ' +
            report
        );
        System.assert(
            report.contains('1 board column'),
            'The count is reported, because a deletion nobody can see is a deletion nobody can ' +
            'check. Got: ' + report
        );
    }

    @IsTest
    static void aHUMANSOWNTITLEONTHESAMEDATESurvivesThePurge() {
        Opportunity o = deal();
        AAO_Source__c src = [
            SELECT AAO_Evidence_Occurred__c, AAO_Meeting_Title__c
            FROM AAO_Source__c WHERE AAO_Opportunity__c = :o.Id LIMIT 1
        ];
        // The exact shape the fifty-second stamp's incident produced: a person retitled the
        // column, so it STARTS WITH what the writer composes and is not equal to it. `sectionFor`
        // reuses this on the next run rather than creating a second column beside it.
        String theirs = AAO_Cards.sectionTitle(src, null) + ' (Q3 push)';
        Id kept = section(o, theirs);
        Id alsoTheirs = section(o, 'Enter title');

        Test.startTest();
        String report = AAO_DemoController.purgeDeal(o.Id);
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM ALTF__Insight_Section__c WHERE Id = :kept],
            'A prefix match is what the WRITER uses to find a column, and using it to DELETE ' +
            'would destroy the person\'s own words to tidy a board. Exact title or it stays. ' +
            report
        );
        System.assertEquals(
            1,
            [SELECT COUNT() FROM ALTF__Insight_Section__c WHERE Id = :alsoTheirs],
            'A column that was never ours is never the purge\'s to take. ' + report
        );
        System.assert(
            report.contains('0 board column'),
            'And it says it removed none, rather than reporting a deletion it did not make. ' +
            'Got: ' + report
        );
    }

    @IsTest
    static void aDealWithNoSourceTouchesNoColumnAtAll() {
        Account a = new Account(Name = 'AAO Purge Bare Account');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Purge Bare Deal', AccountId = a.Id, StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        // No Source means no title the writer could have composed, so there is nothing the purge
        // can prove is ours. It must leave the board alone rather than fall back to the date.
        Id standing = section(o, '30 July 2026');

        Test.startTest();
        String report = AAO_DemoController.purgeDeal(o.Id);
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM ALTF__Insight_Section__c WHERE Id = :standing],
            'With no Source there is no proof of authorship, and no proof means no deletion. ' +
            report
        );
    }
}
