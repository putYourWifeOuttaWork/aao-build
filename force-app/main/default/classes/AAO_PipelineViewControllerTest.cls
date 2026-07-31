/**
 * The internal pipeline view's controller.
 *
 * The assertions worth having here are the ones about honesty rather than shape: that a deal
 * with nothing on it says so rather than looking like a loading state, that a landed-but-not-
 * adjudicated artifact reads PENDING, and that an empty flag list carries the sentence
 * explaining nothing raises flags yet.
 */
@IsTest
private class AAO_PipelineViewControllerTest {
    @IsTest
    static void anEmptyDealSaysSoRatherThanLookingLikeLoading() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(
            c.oppByDeal.get(AAO_Demo.OPP_LIVE)
        );
        Test.stopTest();

        System.assertEquals(true, s.isEmpty);
        System.assertEquals(0, s.sources.size());
        System.assertEquals(0, s.claims.size());
        System.assertEquals(0, s.answers.size());
        System.assertEquals(false, s.hasPending);
        System.assertEquals(AAO_Demo.OPP_LIVE, s.opportunityName);
    }

    @IsTest
    static void twoPassesReadAsATimeline() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        AAO_Demo.passTwo();
        Id oppId = [
            SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1
        ]
        .Id;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        System.assertEquals(false, s.isEmpty);

        // ---- sources, both adjudicated
        System.assertEquals(2, s.sources.size());
        System.assertEquals(0, s.pendingCount);
        System.assertEquals(false, s.hasPending, 'Nothing is waiting, so the view slows down.');
        for (AAO_PipelineViewController.SourceRow r : s.sources) {
            System.assertEquals('Adjudicated', r.status);
        }
        System.assertEquals(
            'dummy/transcript-one',
            s.sources[0].sourceRef,
            'Sources read in the order the evidence happened.'
        );

        // ---- claims, in occurred order, before -> after
        System.assertEquals(2, s.claims.size());
        System.assertEquals('—', s.claims[0].before, 'Nothing preceded the first claim.');
        System.assertEquals('UNVERIFIED', s.claims[0].after);
        System.assertEquals('UNVERIFIED', s.claims[1].before);
        System.assertEquals('TRUE', s.claims[1].after);
        System.assert(
            String.isNotBlank(s.claims[0].snippet),
            'A claim shows the first quote it rests on.'
        );
        System.assert(
            s.claims[0].snippet.contains('funding is approved'),
            'Got: ' + s.claims[0].snippet
        );
        System.assertEquals(
            'slds-badge slds-theme_success',
            s.claims[1].theme,
            'The controller is the one place a verdict becomes a colour.'
        );

        // ---- candidates, latest pass and total
        System.assertEquals('dummy/transcript-two', s.candidates.latestPassLabel);
        System.assertEquals(6, s.candidates.latestTotal, 'Six propositions considered on the pass.');
        System.assertEquals(12, s.candidates.grandTotal, 'Six on each of two passes.');
        System.assert(!s.candidates.latest.isEmpty());

        // ---- answers
        System.assertEquals(1, s.answers.size());
        System.assertEquals('TRUE', s.answers[0].verdict);
        System.assertEquals('AAO_T1', s.answers[0].code);
        System.assertEquals('e1, e2, e3', s.answers[0].covered);
        System.assertEquals('—', s.answers[0].missing);
        System.assertEquals(true, s.answers[0].complete);
        System.assertEquals('MACHINE', s.answers[0].establishedBy);

        // ---- flags, and the sentence that stops an empty list reading as a clean bill
        System.assertEquals(0, s.flags.count);
        System.assertEquals(false, s.flags.hasAny);
        System.assert(
            s.flags.sentence.contains('raise path does not'),
            'An empty flag list must say why it is empty. Got: ' + s.flags.sentence
        );

        // ---- projection, off
        System.assertEquals('off', s.projection.label);
        System.assert(
            s.projection.sentence.contains('not built'),
            s.projection.sentence
        );
    }

    /**
     * The state the whole async path exists to make visible: the artifact is stored and
     * adjudication has not landed.
     */
    @IsTest
    static void aLandedButUnadjudicatedArtifactReadsPending() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_Synthetic.MARK = true;
        AAO_Demo.findSource(c, 'T1SRC', oppId);
        AAO_Synthetic.MARK = false;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        System.assertEquals(1, s.sources.size());
        System.assertEquals(true, s.sources[0].pending);
        System.assertEquals('PENDING', s.sources[0].status);
        System.assertEquals(0, s.sources[0].claimCount);
        System.assertEquals(1, s.pendingCount);
        System.assertEquals(
            true,
            s.hasPending,
            'This is what puts the view on the two-second cadence and the spinner on the row.'
        );
        System.assertEquals(false, s.isEmpty, 'A source has arrived, so the deal is not empty.');
    }

    @IsTest
    static void theSpeakerDowngradeIsVisibleAsSuch() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passNegative();
        Id oppId = [
            SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_NEGATIVE LIMIT 1
        ]
        .Id;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        System.assertEquals(1, s.claims.size());
        System.assertEquals('Downgraded', s.claims[0].outcome);
        System.assertEquals('UNVERIFIED', s.claims[0].after);
        System.assertEquals(
            'slds-badge slds-theme_warning',
            s.claims[0].theme
        );
        System.assertEquals(
            true,
            s.answers[0].complete,
            'Full coverage and still UNVERIFIED. The view has to be able to show that ' +
            'combination, because it is the whole point of the speaker rule.'
        );
        System.assertEquals('UNVERIFIED', s.answers[0].verdict);
    }

    /**
     * A missing record id is a wiring fault. It must not render as "nothing has arrived on
     * this deal", because that sentence is a claim about the customer and this would be a
     * claim about our own configuration.
     */
    @IsTest
    static void aMissingRecordIdIsAFaultNotAnEmptyDeal() {
        Boolean threw = false;
        Test.startTest();
        try {
            AAO_PipelineViewController.getSnapshot(null);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();
        System.assertEquals(
            true,
            threw,
            'A null record id returned a snapshot instead of throwing, which would dress a ' +
            'misconfigured component up as an empty opportunity.'
        );
    }
}
