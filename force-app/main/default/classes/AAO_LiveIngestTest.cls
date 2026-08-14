/**
 * The live ingestion path: a Source landing is the only thing anybody does, and everything
 * after it is the org's own doing.
 *
 * The assertion that matters most is the one made *before* Test.stopTest(): nothing has
 * been adjudicated yet. Without it these tests would pass identically if the pipeline ran
 * inline, and the whole claim about the live path would be unproven.
 */
@IsTest
private class AAO_LiveIngestTest {
    // ============================================ evidence lands, adjudication follows

    @IsTest
    static void aSourceLandingIsAdjudicatedAsynchronouslyAndLandsUnverified() {
        Test.startTest();
        String report = AAO_Live.ingestOne();

        // Still inside the transaction that inserted the Source. The Queueable has been
        // enqueued and has not run. If anything has been written here, the work is inline
        // and this test is not testing what it says it tests.
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Claim__c],
            'Nothing may be adjudicated in the transaction that delivered the evidence. ' +
            report
        );
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Source__c],
            'The artifact itself lands immediately and durably. ' + report
        );
        Test.stopTest(); // the Queueable runs here

        List<AAO_Claim__c> claims = [
            SELECT AAO_Verdict_Before__c, AAO_Verdict_After__c, AAO_Outcome__c, AAO_Actor__c
            FROM AAO_Claim__c
        ];
        System.assertEquals(1, claims.size(), 'The job wrote exactly one claim.');
        System.assertEquals(null, claims[0].AAO_Verdict_Before__c);
        // CORRECTED IN PLACE, seventieth stamp. This asserted UNVERIFIED on the retired rule
        // that partial coverage gates the verdict; Matthew ruled THE UPHOLD GOVERNS at the
        // sixty-ninth. WHAT THE ASSERTION WAS ABOUT IS NOW MEASURED WHERE IT BELONGS, two lines
        // below: transcript one covers two of three elements, and COMPLETENESS is what says so.
        System.assertEquals(
            'TRUE',
            claims[0].AAO_Verdict_After__c,
            'The verifier upheld these words, so the claim stands with the spans it has.'
        );
        System.assertEquals('MACHINE', claims[0].AAO_Actor__c);

        AAO_Answer__c a = [SELECT AAO_Verdict__c, AAO_Element_Completeness__c FROM AAO_Answer__c];
        System.assertEquals('TRUE', a.AAO_Verdict__c);
        AAO_Model.Coverage cov = AAO_Model.parseCoverage(a.AAO_Element_Completeness__c);
        System.assertEquals(2, cov.covered.size());
        System.assertEquals(1, cov.missing.size(), 'e3 is still missing.');

        System.assertEquals(
            6,
            [SELECT COUNT() FROM AAO_Candidate__c],
            'The ledger is complete on the async path too: one proposal plus five ' +
            'abstentions.'
        );
    }

    @IsTest
    static void theSecondArtifactFlipsItToTrueAndReplayStaysExact() {
        // Transcript one, staged through the same pipeline function, synchronously, so the
        // one Test.startTest this method gets can be spent on the async pass.
        AAO_Ingest.AUTO = false;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_Synthetic.MARK = true;
        AAO_Source__c s1 = AAO_Demo.findSource(c, 'T1SRC', oppId);
        AAO_Synthetic.MARK = false;
        AAO_Pipeline.Outcome first = AAO_Pipeline.runForSource(s1.Id, c.internalDomains);
        System.assertEquals('staged', first.status, first.toString());
        System.assertEquals('TRUE', first.verdict);
        AAO_Ingest.AUTO = true;

        Test.startTest();
        AAO_Live.ingestTwo();
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Claim__c],
            'The second artifact has landed and has not been adjudicated yet.'
        );
        Test.stopTest();

        List<AAO_Claim__c> claims = [
            SELECT AAO_Verdict_Before__c, AAO_Verdict_After__c, AAO_Evidence_Occurred__c
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :oppId
            ORDER BY AAO_Evidence_Occurred__c ASC
        ];
        System.assertEquals(2, claims.size());
        // CORRECTED IN PLACE with the assertion above, same ruling. The POINT survives whole:
        // the first claim is untouched and nothing edited it, which is what makes progress
        // visible. What progresses across the two artifacts is COMPLETENESS, not the verdict.
        System.assertEquals(
            'TRUE',
            claims[0].AAO_Verdict_After__c,
            'The first claim is untouched. Nothing edited it.'
        );
        System.assertEquals('TRUE', claims[1].AAO_Verdict_Before__c);
        System.assertEquals('TRUE', claims[1].AAO_Verdict_After__c);
        System.assertEquals(
            11L * 24 * 60 * 60 * 1000,
            claims[1].AAO_Evidence_Occurred__c.getTime() -
            claims[0].AAO_Evidence_Occurred__c.getTime(),
            'Eleven days apart on the occurred clock, whichever way the evidence arrived.'
        );

        AAO_Answer__c a = [
            SELECT AAO_Verdict__c, AAO_Spans__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :oppId
        ];
        System.assertEquals('TRUE', a.AAO_Verdict__c);
        Set<Id> quoted = new Set<Id>();
        for (AAO_Model.Span sp : AAO_Model.parseSpans(a.AAO_Spans__c).spans) {
            quoted.add(Id.valueOf(sp.sourceId));
        }
        System.assertEquals(2, quoted.size(), 'Quotes from both artifacts.');

        // Replay must still be exact when the claims were written by two different entries.
        List<String> differences = AAO_Replay.diff(
            AAO_Replay.rebuild(oppId),
            AAO_Replay.liveAnswers(oppId)
        );
        System.assert(
            differences.isEmpty(),
            'Replaying claims in evidence-occurred order must reconstruct the answer ' +
            'exactly, no matter which entry wrote them. Differences: ' +
            String.join(differences, ' | ')
        );
    }

    // ==================================================== what the path refuses to do

    /**
     * A Source with nothing staged for it writes nothing, and says so. This is the honest
     * shape of the gap: until a charter runs, an artifact only becomes a claim if a
     * proposal was authored for it.
     */
    @IsTest
    static void anArtifactWithNoStagedProposalWritesNothing() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);

        AAO_Synthetic.MARK = true;
        AAO_Source__c stranger = new AAO_Source__c(
            AAO_Opportunity__c = oppId,
            AAO_Account__c = c.acct.Id,
            AAO_Normalized_Text__c = 'priya\tAn artifact nobody has read.',
            AAO_Diarization__c = 'Attributed',
            AAO_Speaker_Roster__c = c.rosterJson,
            AAO_SHA256__c = AAO_NormalForm.sha256('x'),
            AAO_Artifact_SHA256__c = AAO_NormalForm.sha256('dummy/never-seen-before'),
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Source_Ref__c = 'dummy/never-seen-before',
            AAO_Origin__c = 'ingest',
            AAO_Evidence_Occurred__c = System.now()
        );
        insert stranger;
        AAO_Synthetic.MARK = false;

        Test.startTest();
        AAO_Pipeline.Outcome o = AAO_Pipeline.runForSource(stranger.Id, c.internalDomains);
        Test.stopTest();

        System.assertEquals('no_staged_proposal', o.status, o.toString());
        System.assertEquals(0, [SELECT COUNT() FROM AAO_Claim__c]);
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Answer__c],
            'No proposal means no candidate, no claim and no answer. Silence is not a verdict.'
        );
        System.assert(o.note.contains('No proposal is staged'), o.note);
    }

    /**
     * The two entries cannot both commit the same artifact. The synchronous caller wins
     * inside its own transaction; a job enqueued by the same insert arrives afterwards and
     * finds the work done.
     */
    @IsTest
    static void theTwoEntriesCannotBothCommitOneArtifact() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_Synthetic.MARK = true;
        AAO_Source__c s = AAO_Demo.findSource(c, 'T1SRC', oppId);
        AAO_Synthetic.MARK = false;

        Test.startTest();
        AAO_Pipeline.Outcome one = AAO_Pipeline.runForSource(s.Id, c.internalDomains);
        AAO_Pipeline.Outcome two = AAO_Pipeline.runForSource(s.Id, c.internalDomains);
        Test.stopTest();

        System.assertEquals('staged', one.status);
        System.assertEquals('already_committed', two.status, two.toString());
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Claim__c],
            'One artifact, one claim, however many times the pipeline is asked.'
        );
    }

    @IsTest
    static void autoOffMeansNothingIsEnqueued() {
        AAO_Ingest.AUTO = false;

        Test.startTest();
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        AAO_Synthetic.MARK = true;
        AAO_Demo.findSource(c, 'T1SRC', c.oppByDeal.get(AAO_Demo.OPP_LIVE));
        AAO_Synthetic.MARK = false;
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Claim__c],
            'With auto-ingest off, a Source landing adjudicates nothing. This is what lets ' +
            'the rehearsal stay synchronous and ordered.'
        );
    }

    /**
     * The rehearsal and the live deal are separate deals, so evidence on one never lands on
     * the other. Worth asserting, because both read the same fixture.
     */
    @IsTest
    static void theRehearsalAndTheLiveDealDoNotBleed() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();

        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Id live = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        Id main = c.oppByDeal.get(AAO_Demo.OPP_MAIN);
        System.assertNotEquals(live, main);
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c = :live],
            'The rehearsal wrote nothing on the live deal.'
        );
        System.assertEquals(1, [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c = :main]);
    }

    @IsTest
    static void resetClearsTheLiveDealAndLeavesTheRehearsal() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Id live = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_Synthetic.MARK = true;
        AAO_Source__c s = AAO_Demo.findSource(c, 'T1SRC', live);
        AAO_Synthetic.MARK = false;
        AAO_Pipeline.runForSource(s.Id, c.internalDomains);

        Test.startTest();
        String report = AAO_Live.reset();
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c = :live],
            report
        );
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AAO_Claim__c],
            'The rehearsal is untouched. ' + report
        );
    }

    @IsTest
    static void statusIsReadableBeforeAnythingHasHappened() {
        System.assert(
            AAO_Live.status().contains('does not exist yet'),
            AAO_Live.status()
        );
    }

    @IsTest
    static void stagedProposalsAreFoundByArtifactHashNotByFixtureCode() {
        Map<String, Object> fixture = AAO_Seed.fixture();

        // The hash of the artifact's CONTENT, not of 'dummy/transcript-one'. Session 11:
        // hashing the label made a filename the identity of a piece of evidence.
        Map<String, Object> spec;
        for (Object o : (List<Object>) fixture.get('sources')) {
            Map<String, Object> m = (Map<String, Object>) o;
            if (m.get('code') == 'T1SRC') {
                spec = m;
            }
        }
        String sha = AAO_Seed.artifactSha(spec);
        System.assertNotEquals(
            AAO_NormalForm.sha256((String) spec.get('sourceRef')),
            sha,
            'The artifact hash must not be the hash of its path label.'
        );

        List<Object> staged = AAO_Pipeline.stagedFor(fixture, sha);
        System.assertEquals(
            1,
            staged.size(),
            'A trigger has a Source and nothing else, so the proposal has to be findable ' +
            'from the artifact itself.'
        );
        System.assertEquals('C1', ((Map<String, Object>) staged[0]).get('code'));

        System.assertEquals(
            0,
            AAO_Pipeline.stagedFor(fixture, AAO_NormalForm.sha256('nothing/here')).size()
        );
    }
}