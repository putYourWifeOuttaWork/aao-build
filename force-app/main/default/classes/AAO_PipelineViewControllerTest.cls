/**
 * The pipeline command center's controller.
 *
 * The assertions worth having here are the ones about honesty rather than shape: that a
 * record with nothing on it says so rather than looking like a loading state, that a
 * landed-but-not-adjudicated artifact reads PENDING, that a Held answer is visibly dead and
 * excluded from the live count rather than silently dropped, that all six flag types are
 * counted rather than only the one the old panel looked at, and that the projection panel
 * says what is true rather than carrying a sentence written before projection existed.
 */
@IsTest
private class AAO_PipelineViewControllerTest {
    /** Answers are grouped by subject person now; most assertions want them flat. */
    private static List<AAO_PipelineViewController.AnswerRow> flat(
        AAO_PipelineViewController.Snapshot s
    ) {
        List<AAO_PipelineViewController.AnswerRow> out =
            new List<AAO_PipelineViewController.AnswerRow>();
        for (AAO_PipelineViewController.PersonGroup g : s.people) {
            out.addAll(g.answers);
        }
        return out;
    }

    /**
     * A person-subject answer, created rather than converted. `AAO_AnswerKey` freezes identity
     * at birth: an Opportunity-subject row cannot be UPDATED into a Contact-subject row,
     * because that is a different question about a different subject and therefore a
     * different row. Both laws are correct, so the fixture obeys them instead of routing
     * around them.
     */
    private static AAO_Answer__c personAnswer(Id oppId, Id acctId, Id contactId, String value) {
        // The contract is rubric-scoped and carries no opportunity lookup, so it is taken
        // from an answer already standing on this deal. Reusing the contract is safe: the
        // key is subject-typed, so `Contact|<id>|<contract>` cannot collide with
        // `Opportunity|<id>|<contract>`.
        AAO_Answer__c seed = [
            SELECT AAO_Evidence_Contract__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :oppId
            LIMIT 1
        ];
        AAO_Synthetic.MARK = true;
        AAO_Answer__c a = new AAO_Answer__c(
            AAO_Opportunity__c = oppId,
            AAO_Account__c = acctId,
            AAO_Evidence_Contract__c = seed.AAO_Evidence_Contract__c,
            AAO_Subject_Type__c = 'Contact',
            AAO_Subject_Contact__c = contactId,
            AAO_Verdict__c = 'TRUE',
            AAO_Established_By__c = 'MACHINE',
            // State basis, deliberately: a projected map value is cited by the rows its claim
            // named and froze, never by a transcript quote. The evidence-family law (47/48)
            // exempts it from the span requirement rather than the fixture dodging one.
            AAO_Basis__c = 'State',
            AAO_Publication_State__c = 'Live'
        );
        if (value != null) {
            a.AAO_Projected_Value__c = value;
            a.AAO_Projected_Modstamp__c = System.now();
        }
        insert a;
        AAO_Synthetic.MARK = false;
        return a;
    }

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
        System.assertEquals('Opportunity', s.context);
        System.assertEquals(0, s.sources.size());
        System.assertEquals(0, s.claims.size());
        System.assertEquals(0, flat(s).size());
        System.assertEquals(false, s.hasPending);
        System.assertEquals(AAO_Demo.OPP_LIVE, s.contextName);
        System.assert(
            s.emptyText.contains('true statement about the deal'),
            'The empty state has to be a claim about the deal, not a loading state. Got: ' +
            s.emptyText
        );
    }

    @IsTest
    static void twoPassesReadAsATimeline() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        AAO_Demo.passTwo();
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1].Id;

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
        // CORRECTED IN PLACE, seventieth stamp: the uphold governs, so both claims stand TRUE.
        // The speaker-downgrade path further down this class still asserts UNVERIFIED and still
        // passes, which is the check that the ruling retired ONE gate and not the others.
        System.assertEquals('TRUE', s.claims[0].after);
        System.assertEquals('TRUE', s.claims[1].before);
        System.assertEquals('TRUE', s.claims[1].after);
        System.assert(
            s.claims[0].snippet.contains('funding is approved'),
            'Got: ' + s.claims[0].snippet
        );
        System.assertEquals(
            'slds-badge slds-theme_success',
            s.claims[1].theme,
            'The controller is the one place a verdict becomes a colour.'
        );

        // ---- candidates
        System.assertEquals('dummy/transcript-two', s.candidates.latestPassLabel);
        System.assertEquals(6, s.candidates.latestTotal, 'Six propositions considered on the pass.');
        System.assertEquals(12, s.candidates.grandTotal, 'Six on each of two passes.');

        // ---- answers
        List<AAO_PipelineViewController.AnswerRow> answers = flat(s);
        System.assertEquals(1, answers.size());
        System.assertEquals('TRUE', answers[0].verdict);
        System.assertEquals('AAO_T1', answers[0].code);
        System.assertEquals('e1, e2, e3', answers[0].covered);
        System.assertEquals('—', answers[0].missing);
        System.assertEquals(true, answers[0].complete);
        System.assertEquals('MACHINE', answers[0].establishedBy);

        // ---- flags. Day-one red is live, so this deal is not flagless.
        System.assertEquals(
            1,
            s.flags.standingCount,
            'AAO_T2 gates and nothing has established it, so it stands red.'
        );
        System.assertEquals(1, s.flags.clearedCount);
        System.assert(
            s.flags.sentence.contains('raised at deal creation'),
            'Got: ' + s.flags.sentence
        );
        System.assertEquals(
            2,
            s.flags.rows.size(),
            'The panel shows rows now, not just a number.'
        );
        System.assertEquals(
            'Standing',
            s.flags.rows[0].state,
            'Standing sorts before cleared, because that is the order a reader cares about.'
        );
    }

    // ------------------------------------------------------------------- G · two clocks

    @IsTest
    static void bothClocksCarryATimeAndAreLabelled() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1].Id;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        // A call at 07:01 that renders as a bare date has discarded the half of the stamp
        // the occurred clock exists for.
        System.assert(
            s.claims[0].occurred.contains(':') && s.claims[0].occurred.endsWith('GMT'),
            'Occurred must carry a time and name its zone. Got: ' + s.claims[0].occurred
        );
        System.assert(
            s.claims[0].recorded.contains(':') && s.claims[0].recorded.endsWith('GMT'),
            'Recorded must carry a time and name its zone. Got: ' + s.claims[0].recorded
        );
        System.assert(
            s.generatedAt.startsWith('snapshot ') && s.generatedAt.contains('(local)'),
            'The header stamp names its own zone and carries its date. Got: ' + s.generatedAt
        );
    }

    // ------------------------------------------------------------ B · depth-one lineage

    @IsTest
    static void aClaimCarriesItsCandidateAndTheAnswerItMoved() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        AAO_Demo.passTwo();
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1].Id;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        AAO_PipelineViewController.ClaimRow c = s.claims[0];
        System.assertNotEquals(null, c.candidateId, 'A claim came from a candidate.');
        System.assertNotEquals(null, c.answerId, 'And it moved an answer.');
        System.assertEquals(true, c.hasLineage);
        System.assert(
            c.candidateLabel.contains('proposed'),
            'The candidate label says what it proposed. Got: ' + c.candidateLabel
        );

        // And the answer carries every claim behind it, in occurred order.
        AAO_PipelineViewController.AnswerRow a = flat(s)[0];
        System.assertEquals(2, a.claims.size(), 'Both claims stand behind the one answer.');
        System.assertEquals(true, a.hasLineage);
        // CORRECTED IN PLACE, seventieth stamp: both claims now read TRUE because each was
        // upheld, so the ORDER can no longer be read off the verdicts. It is asserted on the
        // occurred clock instead, which is what "oldest first" was always about.
        System.assertEquals('TRUE', a.claims[0].after, 'Each claim stands on its own uphold.');
        System.assertEquals('TRUE', a.claims[1].after);
        System.assert(
            a.claims[0].occurred < a.claims[1].occurred, 'Occurred order, oldest first.'
        );
    }

    // -------------------------------------------------------- F · publication honesty

    @IsTest
    static void aHeldAnswerIsVisiblyDeadAndNotCountedLive() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        AAO_Demo.passTwo();
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1].Id;

        AAO_Answer__c a = [SELECT Id FROM AAO_Answer__c WHERE AAO_Opportunity__c = :oppId LIMIT 1];
        a.AAO_Publication_State__c = 'Held';
        update a;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        List<AAO_PipelineViewController.AnswerRow> answers = flat(s);
        System.assertEquals(
            1,
            answers.size(),
            'Held is never silently hidden. It renders, and it renders dead.'
        );
        System.assertEquals(true, answers[0].held);
        System.assertEquals('aao-held', answers[0].rowClass, 'It has to LOOK dead.');
        System.assertEquals(0, s.liveCount, 'And it is not counted as live.');
        System.assertEquals(1, s.heldCount);
        System.assertEquals('0 live · 1 held', s.publicationLine);
    }

    // ------------------------------------------------------------------ D · all six types

    @IsTest
    static void everyFlagTypeIsCountedNotJustTheMethodologicalOne() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        Account acct = [SELECT Id FROM Account WHERE Id IN (
            SELECT AccountId FROM Opportunity WHERE Id = :oppId
        ) LIMIT 1];
        Contact subject = [SELECT Id, Name FROM Contact WHERE AccountId = :acct.Id LIMIT 1];

        AAO_Synthetic.MARK = true;
        insert new List<AAO_Flag__c>{
            new AAO_Flag__c(
                AAO_Opportunity__c = oppId,
                AAO_Account__c = acct.Id,
                AAO_Type__c = 'Contention_Negative',
                AAO_Cause__c = 'History_Contradicts',
                AAO_State__c = 'Standing',
                AAO_Subject_Contact__c = subject.Id,
                AAO_Raised_At__c = System.now()
            ),
            new AAO_Flag__c(
                AAO_Opportunity__c = oppId,
                AAO_Account__c = acct.Id,
                AAO_Type__c = 'Contention_Positive',
                AAO_Cause__c = 'History_Better',
                AAO_State__c = 'Cleared',
                AAO_Subject_Contact__c = subject.Id,
                AAO_Raised_At__c = System.now()
            )
        };
        AAO_Synthetic.MARK = false;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        // Day-one red already stands on this deal, so the total is the scaffold's plus mine.
        // The assertion that matters is that the contention types are visible AT ALL: the old
        // panel counted Methodological only and both of these were invisible on it.
        Map<String, AAO_PipelineViewController.FlagRow> byType =
            new Map<String, AAO_PipelineViewController.FlagRow>();
        for (AAO_PipelineViewController.FlagRow r : s.flags.rows) {
            byType.put(r.type, r);
        }
        System.assertEquals(
            true,
            byType.containsKey('Contention_Negative'),
            'The People run raises contention flags; the screen built to watch the run has ' +
            'to show them. Types present: ' + byType.keySet()
        );
        System.assertEquals(true, byType.containsKey('Contention_Positive'));
        System.assertEquals(true, byType.containsKey('Methodological'), 'And it still shows the old one.');
        System.assertEquals('Standing', byType.get('Contention_Negative').state);
        System.assertEquals(subject.Name, byType.get('Contention_Negative').subjectName);
        System.assertNotEquals(
            null,
            byType.get('Contention_Negative').subjectId,
            'The subject is linkable.'
        );
        System.assertEquals('Cleared', byType.get('Contention_Positive').state);
        System.assertEquals(
            'Standing',
            s.flags.rows[0].state,
            'Standing still sorts before cleared.'
        );
    }

    // --------------------------------------------------------------- C · projection real

    @IsTest
    static void theProjectionPanelReportsWhatIsTrueRatherThanAFixedSentence() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        AAO_Demo.passTwo();
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1].Id;

        // Before: nothing projected, and the panel says exactly that.
        AAO_PipelineViewController.Snapshot before =
            AAO_PipelineViewController.getSnapshot(oppId);
        System.assertEquals('off', before.projection.label);
        System.assertEquals(false, before.projection.isOn);
        System.assertEquals(
            'No projections yet on this record.',
            before.projection.sentence,
            'The old hardcoded sentence claimed projection was "not built". Step 2 makes ' +
            'that false, so the panel derives its own text now.'
        );

        Contact subject = [SELECT Id, Name FROM Contact LIMIT 1];
        Id acctId = [SELECT AccountId FROM Opportunity WHERE Id = :oppId].AccountId;
        personAnswer(oppId, acctId, subject.Id, 'Supporter');

        // AN ANSWER CARRYING A WATERMARK IS NOT A PROJECTION, and this assertion is the
        // ruling of 4 August made executable. Until v2.8 the panel counted answers with a
        // projected value, so this state read `live` while NOTHING had reached the customer's
        // map. That is the collapse the ruling removes: projected and protected are two facts.
        AAO_PipelineViewController.Snapshot answerOnly =
            AAO_PipelineViewController.getSnapshot(oppId);
        System.assertEquals(
            'off',
            answerOnly.projection.label,
            'A watermarked answer with no map row has projected nothing. The old panel said ' +
            'live here, which is exactly the confusion section 6 was rebuilt to end.'
        );
        System.assertEquals(0, answerOnly.projection.mapRowsWritten, 'unit: rows');

        // Now the value actually reaches Altify's own row, which is what projection means.
        insert new ALTF__Contact_Map_Details__c(
            ALTF__Account__c = acctId,
            ALTF__Opportunity__c = oppId,
            ALTF__Contact__c = subject.Id,
            ALTF__Status__c = 'Supporter'
        );

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        System.assertEquals('live', s.projection.label);
        System.assertEquals(true, s.projection.isOn, 'The badge derives from the map rows.');
        System.assertEquals(1, s.projection.mapRowsWritten, 'unit: rows');
        System.assertEquals(
            0,
            s.projection.rowsProjectedWithNoWatermark,
            'The answer behind this row carries a watermark, so the alarm counter is zero. ' +
            'Any nonzero here means a human edit on that row would not be protected.'
        );
        System.assertEquals(1, s.projection.rows.size());
        System.assertEquals('Supporter', s.projection.rows[0].value);
        System.assertEquals(subject.Id, s.projection.rows[0].subjectId, 'The person is linkable.');
        System.assertEquals(subject.Name, s.projection.rows[0].subjectName);
        System.assert(
            String.isNotBlank(s.projection.rows[0].modstamp),
            'The write stamp shows, so a reader can tell a fresh projection from a stale one.'
        );
        System.assert(
            s.projection.sentence.contains('map row') &&
                s.projection.sentence.contains('unit: rows'),
            'The sentence counts map rows and names its unit. Got: ' + s.projection.sentence
        );

        // The person group sorts first, so the projected row is index 0 of the flat list.
        AAO_PipelineViewController.AnswerRow row = flat(s)[0];
        System.assertEquals(true, row.projected);
        System.assertEquals('Supporter', row.projectedValue);
    }

    /**
     * The rung is the projected value on a People dimension and nothing else. A screen that
     * derived a rung of its own would be inventing an answer the projection writer never wrote.
     */
    @IsTest
    static void noRungIsShownForANonPeopleContract() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        AAO_Demo.passTwo();
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1].Id;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        AAO_PipelineViewController.AnswerRow a = flat(s)[0];
        System.assertEquals(
            null,
            a.dimension,
            'AAO_T1 is not a People proposition, so the ontology returns no dimension.'
        );
        System.assertEquals(null, a.rung, 'And with no dimension there is no rung to show.');
    }

    // ---------------------------------------------------------------- E · people grouping

    @IsTest
    static void answersGroupUnderTheirSubjectPerson() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        AAO_Demo.passTwo();
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1].Id;

        Contact subject = [SELECT Id, Name FROM Contact LIMIT 1];
        Id acctId = [SELECT AccountId FROM Opportunity WHERE Id = :oppId].AccountId;
        personAnswer(oppId, acctId, subject.Id, null);

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        System.assertEquals(2, s.people.size(), 'One person group, plus the non-person bucket.');
        System.assertEquals(true, s.people[0].isPerson, 'People sort first.');
        System.assertEquals(subject.Name, s.people[0].personName);
        System.assertEquals(subject.Id, s.people[0].contactId, 'One click to the person.');
        System.assertEquals(1, s.people[0].answers.size());
        System.assertEquals(
            false,
            s.people[1].isPerson,
            'And the non-person bucket sorts last rather than being mixed in.'
        );
    }

    @IsTest
    static void answersWithNoPersonGroupLastAndSayWhyTheyHaveNoPerson() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        AAO_Demo.passTwo();
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1].Id;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        System.assertEquals(1, s.people.size());
        System.assertEquals(false, s.people[0].isPerson);
        System.assertEquals('Not about a person', s.people[0].personName);
        System.assert(
            s.people[0].subtitle.contains('deal itself'),
            'The bucket explains itself rather than looking like a bug. Got: ' +
            s.people[0].subtitle
        );
    }

    // ------------------------------------------------------------- I · account context

    @IsTest
    static void anAccountShowsEveryDealsRowsAndSaysWhyThereIsNoAccountScopeGroup() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        AAO_Demo.passTwo();
        AAO_Demo.passNegative();
        Id acctId = [
            SELECT AccountId FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1
        ]
        .AccountId;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(acctId);
        Test.stopTest();

        System.assertEquals('Account', s.context);
        System.assertEquals(true, s.showScope, 'Every row names its scope in account context.');
        System.assert(s.deals.size() >= 3, 'The account groups its deals. Got: ' + s.deals.size());
        System.assertEquals(
            3,
            s.claims.size(),
            'Two claims from the main deal plus the downgrade from the negative one, ' +
            'gathered across deals by the account filter.'
        );
        for (AAO_PipelineViewController.ClaimRow c : s.claims) {
            System.assertEquals('Deal', c.scope);
            System.assertNotEquals(null, c.dealId, 'And each names the deal it belongs to.');
        }
        // The one part of spec item I that is not built, and the screen says so rather than
        // rendering an empty box that implies the query found nothing.
        System.assert(
            s.scopeNote.contains('Account-grain rows cannot exist yet'),
            'Got: ' + s.scopeNote
        );
        System.assert(
            s.emptyText.contains('about the account'),
            'The empty prose is scope-aware. Got: ' + s.emptyText
        );
    }

    // ---------------------------------------------------------------- H · scale honesty

    @IsTest
    static void everyPanelReportsItsOwnTotalRatherThanTruncatingSilently() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passOne();
        AAO_Demo.passTwo();
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_MAIN LIMIT 1].Id;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        System.assertEquals(2, s.claimPage.total);
        System.assertEquals(2, s.claimPage.shown);
        System.assertEquals(false, s.claimPage.capped);
        System.assertEquals('2', s.claimPage.line, 'Uncapped shows the plain number.');

        // The capped rendering is what matters: a silent cap reads exactly like completeness.
        AAO_PipelineViewController.Tally t = new AAO_PipelineViewController.Tally();
        t.seal(200, 1470);
        System.assertEquals(true, t.capped);
        System.assertEquals('showing 200 of 1470', t.line);
    }

    // ---------------------------------------------------------------- J · the run banner

    @IsTest
    static void theBannerNamesThePendingArtifactAndItsStage() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_Synthetic.MARK = true;
        AAO_Demo.findSource(c, 'T1SRC', oppId);
        AAO_Synthetic.MARK = false;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        System.assertEquals(true, s.banner.active);
        System.assertEquals('adjudicating', s.banner.stage);
        System.assertNotEquals(null, s.banner.sourceId, 'The banner links the artifact.');
        System.assert(
            s.banner.sentence.contains('adjudication has not landed'),
            'Got: ' + s.banner.sentence
        );
        System.assert(String.isNotBlank(s.banner.lastRefreshed));
    }

    @IsTest
    static void anIdleRecordSaysNothingHasArrivedRatherThanShowingAStage() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(
            c.oppByDeal.get(AAO_Demo.OPP_LIVE)
        );
        Test.stopTest();

        System.assertEquals('idle', s.banner.stage);
        System.assertEquals(false, s.banner.active);
    }

    // ---------------------------------------------------------------- the refusal paths

    @IsTest
    static void theSpeakerDowngradeIsVisibleAsSuch() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.passNegative();
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = :AAO_Demo.OPP_NEGATIVE LIMIT 1].Id;

        Test.startTest();
        AAO_PipelineViewController.Snapshot s = AAO_PipelineViewController.getSnapshot(oppId);
        Test.stopTest();

        System.assertEquals(1, s.claims.size());
        System.assertEquals('Downgraded', s.claims[0].outcome);
        System.assertEquals('UNVERIFIED', s.claims[0].after);
        System.assertEquals('slds-badge slds-theme_warning', s.claims[0].theme);
        System.assertEquals(
            true,
            flat(s)[0].complete,
            'Full coverage and still UNVERIFIED. The view has to be able to show that ' +
            'combination, because it is the whole point of the speaker rule.'
        );
        System.assertEquals('UNVERIFIED', flat(s)[0].verdict);
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

    /** The component is exposed for two objects. A third is a wiring fault, not an empty page. */
    @IsTest
    static void anObjectWithNoScopeRuleIsRefusedRatherThanGuessedAt() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Contact someone = [SELECT Id FROM Contact LIMIT 1];

        Boolean threw = false;
        Test.startTest();
        try {
            AAO_PipelineViewController.getSnapshot(someone.Id);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();
        System.assertEquals(
            true,
            threw,
            'A Contact id has no scope rule here. Guessing one would invent a filter.'
        );
    }
}
