/**
 * The four trigger laws, each tested for the thing it is there to stop.
 *
 * These are not coverage tests. Each one names a specific way the design breaks if the
 * law is absent, and asserts that the org refuses.
 */
@IsTest
private class AAO_TriggerLawTest {
    private static AAO_Seed.Loaded seed;

    private static AAO_Seed.Loaded load() {
        if (seed == null) {
            seed = AAO_Seed.load();
        }
        return seed;
    }

    // ==================================================== Source is immutable

    @IsTest
    static void editingATranscriptIsRefused() {
        AAO_Seed.Loaded s = load();
        AAO_Source__c src = s.sourceByCode.get('T1SRC');

        src.AAO_Normalized_Text__c = 'priya\tSomething else entirely.';
        try {
            update src;
            System.assert(
                false,
                'A transcript edited after a span was verified against it breaks the ' +
                'citation chain silently. The org must refuse.'
            );
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('immutable'),
                'Expected an immutability message, got: ' + e.getMessage()
            );
        }
    }

    @IsTest
    static void theOccurredClockCannotBeMoved() {
        AAO_Seed.Loaded s = load();
        AAO_Source__c src = s.sourceByCode.get('T1SRC');
        src.AAO_Evidence_Occurred__c = System.now();
        try {
            update src;
            System.assert(false, 'Moving the occurred clock re-orders replay.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('immutable'), e.getMessage());
        }
    }

    /**
     * THE STAMP IS WRITER-OWNED, and this test exists because the composed stamp broke
     * `theSmallTalkBoundaryStaysMutable` below without touching the field it asserts on.
     *
     * A caller that supplies the stamp keeps its supplied value in the sObject's field
     * map - before-insert changes are not synced back - so its next update submits a
     * stale stamp and is refused for a change nobody made. Refusing the supply at insert
     * is what makes that state unreachable.
     */
    @IsTest
    static void aCallerSuppliedStampIsRefused() {
        AAO_Seed.Loaded s = load();
        AAO_Source__c donor = [
            SELECT AAO_Normalized_Text__c, AAO_Diarization__c, AAO_Account__c,
                AAO_Opportunity__c, AAO_Origin__c, AAO_Artifact_SHA256__c,
                AAO_Evidence_Occurred__c
            FROM AAO_Source__c
            WHERE Id = :s.sourceByCode.get('T1SRC').Id
        ];

        AAO_Source__c supplied = new AAO_Source__c(
            AAO_Source_Ref__c = 'law/caller-supplied-stamp',
            AAO_Normalized_Text__c = donor.AAO_Normalized_Text__c,
            AAO_Diarization__c = donor.AAO_Diarization__c,
            AAO_Account__c = donor.AAO_Account__c,
            AAO_Opportunity__c = donor.AAO_Opportunity__c,
            AAO_Origin__c = donor.AAO_Origin__c,
            AAO_Artifact_SHA256__c = AAO_NormalForm.sha256('law-caller-supplied-stamp'),
            AAO_Evidence_Occurred__c = donor.AAO_Evidence_Occurred__c,
            AAO_Normalizer_Version__c = AAO_NormalForm.VERSION
        );

        try {
            insert supplied;
            System.assert(
                false,
                'A caller-supplied stamp leaves the caller holding a stale value the ' +
                'immutability guard later refuses. The org must refuse the supply instead.'
            );
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('written by AAO_SourceTriggerHandler'),
                'Expected the writer-owned message, got: ' + e.getMessage()
            );
        }
    }

    /**
     * The other half: with the field left alone, the writer composes it, and the caller's
     * sObject carries no stamp to go stale - so an ordinary update still works. This is
     * the assertion the composed stamp actually broke.
     */
    @IsTest
    static void theWriterComposesTheStampAndTheCallerKeepsNoStaleCopy() {
        AAO_Seed.Loaded s = load();
        AAO_Source__c src = s.sourceByCode.get('T1SRC');

        System.assertEquals(
            null,
            src.AAO_Normalizer_Version__c,
            'The caller must hold no stamp; holding one is what goes stale.'
        );

        AAO_Source__c stored = [
            SELECT AAO_Normalizer_Version__c FROM AAO_Source__c WHERE Id = :src.Id
        ];
        System.assert(
            stored.AAO_Normalizer_Version__c.contains('+'),
            'The writer composes the stamp: ' + stored.AAO_Normalizer_Version__c
        );

        src.AAO_Boundary_Basis__c = 'detector-v3';
        update src;
    }

    /**
     * Small talk is marked, never cut, and the boundary is mutable so a better detector
     * can re-mark with no re-ingestion. Span verification never reads it.
     */
    @IsTest
    static void theSmallTalkBoundaryStaysMutable() {
        AAO_Seed.Loaded s = load();
        AAO_Source__c src = s.sourceByCode.get('T1SRC');
        src.AAO_Substantive_Offset__c = 44;
        src.AAO_Boundary_Basis__c = 'detector-v2';
        update src;

        AAO_Source__c reread = [
            SELECT AAO_Substantive_Offset__c, AAO_Boundary_Basis__c
            FROM AAO_Source__c
            WHERE Id = :src.Id
        ];
        System.assertEquals(44, reread.AAO_Substantive_Offset__c);
        System.assertEquals('detector-v2', reread.AAO_Boundary_Basis__c);
    }

    @IsTest
    static void sourcesAreNotDeletable() {
        AAO_Seed.Loaded s = load();
        try {
            delete s.sourceByCode.get('T1SRC');
            System.assert(false, 'Claims cite Sources and spans verify against them.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('not deletable'), e.getMessage());
        }
    }

    @IsTest
    static void theScopeKeyIsComposedByTheTriggerAndDedupes() {
        AAO_Seed.Loaded s = load();
        AAO_Source__c src = [
            SELECT
                AAO_Scope_Key__c,
                AAO_Opportunity__c,
                AAO_Artifact_SHA256__c,
                AAO_SHA256__c,
                AAO_Normalized_Text__c,
                AAO_Part_Index__c
            FROM AAO_Source__c
            WHERE Id = :s.sourceByCode.get('T1SRC').Id
        ];
        System.assertEquals(
            AAO_ScopeKey.compose(
                src.AAO_Opportunity__c,
                src.AAO_Artifact_SHA256__c,
                src.AAO_Part_Index__c.intValue()
            ),
            src.AAO_Scope_Key__c,
            'The trigger is the single writer of the scope key.'
        );

        // THE SAME ARTIFACT, ARRIVING AGAIN. Same deal, same bytes, same part.
        // Corrected in session 11. This block used to send DIFFERENT text while reusing
        // the artifact hash, and asserted the rejection as correct. It was not correct,
        // and the test was defending the defect: the hash was computed over the path
        // label, so two unrelated transcripts delivered under one filename collided and
        // the second was silently discarded as a re-delivery. The hash is over the
        // content now, so a genuine re-delivery has to be genuinely the same bytes.
        AAO_Source__c dup = new AAO_Source__c(
            AAO_Opportunity__c = src.AAO_Opportunity__c,
            AAO_Account__c = s.accountId,
            AAO_Normalized_Text__c = src.AAO_Normalized_Text__c,
            AAO_Diarization__c = 'Attributed',
            AAO_SHA256__c = src.AAO_SHA256__c,
            AAO_Artifact_SHA256__c = src.AAO_Artifact_SHA256__c,
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Origin__c = 'ECI',
            AAO_Evidence_Occurred__c = System.now()
        );
        Database.SaveResult sr = Database.insert(dup, false);
        System.assert(!sr.isSuccess(), 'A re-delivered artifact must not create a second Source.');
        System.assertEquals(
            StatusCode.DUPLICATE_VALUE,
            sr.getErrors()[0].getStatusCode(),
            'DUPLICATE_VALUE is the merge signal, not a generic failure.'
        );
    }

    /**
     * The other half of the same law, and the half that was inverted until session 11.
     * Two different transcripts can arrive under one path label: a file overwritten, a
     * meeting series reusing a name, a connector that numbers nothing. They are different
     * evidence and both must be stored. Identity is the content, never the label.
     */
    @IsTest
    static void twoDifferentArtifactsUnderOneLabelAreNotARedelivery() {
        AAO_Seed.Loaded s = load();
        AAO_Source__c src = [
            SELECT
                AAO_Opportunity__c,
                AAO_Source_Ref__c,
                AAO_Normalized_Text__c,
                AAO_Artifact_SHA256__c
            FROM AAO_Source__c
            WHERE Id = :s.sourceByCode.get('T1SRC').Id
        ];

        String differentText = 'priya\tA different call entirely, same filename.';
        AAO_Source__c other = new AAO_Source__c(
            AAO_Opportunity__c = src.AAO_Opportunity__c,
            AAO_Account__c = s.accountId,
            AAO_Normalized_Text__c = differentText,
            AAO_Diarization__c = 'Attributed',
            AAO_SHA256__c = AAO_NormalForm.sha256(differentText),
            AAO_Artifact_SHA256__c = AAO_NormalForm.sha256(differentText),
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            // Deliberately the same label as the first.
            AAO_Source_Ref__c = src.AAO_Source_Ref__c,
            AAO_Origin__c = 'ECI',
            AAO_Evidence_Occurred__c = System.now()
        );
        Database.SaveResult sr = Database.insert(other, false);

        System.assert(
            sr.isSuccess(),
            'Different bytes under the same path label are different evidence and must ' +
            'both be stored. Rejecting the second one loses a transcript silently, which ' +
            'is what this build did until session 11. Error was: ' +
            (sr.isSuccess() ? '' : String.valueOf(sr.getErrors()))
        );
        System.assertNotEquals(
            src.AAO_Artifact_SHA256__c,
            AAO_NormalForm.sha256(differentText),
            'The hashes differ because the content differs. That is the whole fix.'
        );
    }

    // ===================================================== Claim is insert only

    @IsTest
    static void claimsCannotBeEdited() {
        AAO_Seed.Loaded s = load();
        AAO_Commit.commitCandidate(s.candidateByCode.get('C1').Id, s.internalDomains);

        // THE LAW IS INTACT AND THIS SETUP WENT STALE, which is worth spelling out because the
        // failure looked alarming. It set the verdict to TRUE, and under the uphold-governs
        // ruling the claim ALREADY reads TRUE, so the update moved no field and the handler
        // correctly let a no-op through. Mutate to something that genuinely differs.
        AAO_Claim__c c = [SELECT Id, AAO_Verdict_After__c FROM AAO_Claim__c LIMIT 1];
        System.assertEquals('TRUE', c.AAO_Verdict_After__c, 'The claim stands on its uphold.');
        c.AAO_Verdict_After__c = 'UNVERIFIED';
        try {
            update c;
            System.assert(
                false,
                'A claim that can be edited stops being a receipt, and progress stops ' +
                'being visible.'
            );
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('insert only'), e.getMessage());
        }
    }

    @IsTest
    static void claimsCannotBeDeleted() {
        AAO_Seed.Loaded s = load();
        AAO_Commit.commitCandidate(s.candidateByCode.get('C1').Id, s.internalDomains);
        AAO_Claim__c c = [SELECT Id FROM AAO_Claim__c LIMIT 1];
        try {
            delete c;
            System.assert(false, 'Claims leave by retirement, not by delete.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('not deletable'), e.getMessage());
        }
    }

    @IsTest
    static void aMachineClaimWithoutACharterStampIsRefused() {
        AAO_Seed.Loaded s = load();
        AAO_Commit.commitCandidate(s.candidateByCode.get('C1').Id, s.internalDomains);
        AAO_Answer__c a = [SELECT Id, AAO_Spans__c FROM AAO_Answer__c LIMIT 1];

        AAO_Claim__c c = new AAO_Claim__c(
            AAO_Answer__c = a.Id,
            AAO_Candidate__c = s.candidateByCode.get('C1').Id,
            AAO_Source__c = s.sourceByCode.get('T1SRC').Id,
            AAO_Evidence_Contract__c = s.contractByCode.get('AAO_T1').Id,
            AAO_Opportunity__c = s.opportunityByDeal.get('main'),
            AAO_Account__c = s.accountId,
            AAO_Subject_Type__c = 'Opportunity',
            AAO_Verdict_After__c = 'TRUE',
            AAO_Spans__c = a.AAO_Spans__c,
            AAO_Basis__c = 'Transcript',
            AAO_Outcome__c = 'Established',
            AAO_Actor__c = 'MACHINE',
            AAO_Charter__c = null,
            AAO_Evidence_Occurred__c = System.now(),
            AAO_Recorded_At__c = System.now()
        );
        try {
            insert c;
            System.assert(
                false,
                'A write is MACHINE only if it carries a charter stamp. Everything else ' +
                'is HUMAN.'
            );
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('charter stamp'), e.getMessage());
        }
    }

    // ====================================================== Answer's write law

    @IsTest
    static void aMachineEstablishmentWithNoCitationIsRefused() {
        AAO_Seed.Loaded s = load();
        AAO_Answer__c a = new AAO_Answer__c(
            AAO_Evidence_Contract__c = s.contractByCode.get('AAO_T1').Id,
            AAO_Opportunity__c = s.opportunityByDeal.get('main'),
            AAO_Account__c = s.accountId,
            AAO_Subject_Type__c = 'Opportunity',
            AAO_Verdict__c = 'TRUE',
            AAO_Established_By__c = 'MACHINE',
            AAO_Publication_State__c = 'Live'
        );
        try {
            insert a;
            System.assert(false, 'An establishment requires a citation.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('requires a citation'), e.getMessage());
        }
    }

    @IsTest
    static void aFabricatedQuoteIsRefused() {
        AAO_Seed.Loaded s = load();
        AAO_Source__c src = s.sourceByCode.get('T1SRC');

        AAO_Model.Span sp = new AAO_Model.Span();
        sp.sourceId = String.valueOf(src.Id);
        sp.partIndex = 1;
        sp.startOffset = 0;
        sp.endOffset = 20;
        sp.quote = 'Budget is definitely approved, I promise.';
        sp.element = 'e1';

        AAO_Answer__c a = new AAO_Answer__c(
            AAO_Evidence_Contract__c = s.contractByCode.get('AAO_T1').Id,
            AAO_Opportunity__c = s.opportunityByDeal.get('main'),
            AAO_Account__c = s.accountId,
            AAO_Subject_Type__c = 'Opportunity',
            AAO_Verdict__c = 'TRUE',
            AAO_Established_By__c = 'MACHINE',
            AAO_Publication_State__c = 'Live',
            AAO_Spans__c = AAO_Model.serializeSpans(new List<AAO_Model.Span>{ sp })
        );
        try {
            insert a;
            System.assert(false, 'Spans are byte-verified. A quote that is not there is not evidence.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Span verification failed'),
                e.getMessage()
            );
        }
    }

    @IsTest
    static void aHumanAnswerIsNeverTakenByAMachine() {
        AAO_Seed.Loaded s = load();
        AAO_Commit.commitCandidate(s.candidateByCode.get('C1').Id, s.internalDomains);

        AAO_Answer__c a = [
            SELECT Id, AAO_Established_By__c, AAO_Verdict__c
            FROM AAO_Answer__c
            LIMIT 1
        ];
        a.AAO_Established_By__c = 'HUMAN';
        a.AAO_Verdict__c = 'TRUE';
        update a;

        a.AAO_Established_By__c = 'MACHINE';
        try {
            update a;
            System.assert(
                false,
                'Misreading a machine write as human costs one overwrite. Misreading a ' +
                'human write as machine destroys a person\'s judgment.'
            );
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Human precedence'), e.getMessage());
        }
    }

    @IsTest
    static void commitDoesNotOverwriteAHumanAnswer() {
        AAO_Seed.Loaded s = load();
        AAO_Commit.commitCandidate(s.candidateByCode.get('C1').Id, s.internalDomains);

        AAO_Answer__c a = [SELECT Id, AAO_Established_By__c FROM AAO_Answer__c LIMIT 1];
        a.AAO_Established_By__c = 'HUMAN';
        update a;

        Test.startTest();
        AAO_Commit.Result r = AAO_Commit.commitCandidate(
            s.candidateByCode.get('C2').Id,
            s.internalDomains
        );
        Test.stopTest();

        System.assertEquals(null, r.claim, 'No claim is written over a human answer.');
        System.assertEquals('Superseded_By_Human', r.candidateOutcome);
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM AAO_Claim__c
                WHERE AAO_Opportunity__c = :s.opportunityByDeal.get('main')
            ],
            'The second pass wrote nothing.'
        );
    }

    @IsTest
    static void identityDoesNotMove() {
        AAO_Seed.Loaded s = load();
        AAO_Commit.commitCandidate(s.candidateByCode.get('C1').Id, s.internalDomains);

        AAO_Answer__c a = [
            SELECT Id, AAO_Evidence_Contract__c, AAO_Answer_Key__c
            FROM AAO_Answer__c
            LIMIT 1
        ];
        a.AAO_Evidence_Contract__c = s.contractByCode.get('AAO_T6').Id;
        try {
            update a;
            System.assert(
                false,
                'An answer to a different question is a different row, not this row edited.'
            );
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Identity does not move'), e.getMessage());
        }
    }

    /**
     * DUPLICATE_VALUE is a merge path, never an error path: catch, re-read the colliding
     * row, apply precedence, proceed.
     */
    @IsTest
    static void duplicateValueIsAMergePathNotAnErrorPath() {
        AAO_Seed.Loaded s = load();
        AAO_Commit.commitCandidate(s.candidateByCode.get('C1').Id, s.internalDomains);

        Test.startTest();
        AAO_Commit.simulateLostRace = true;
        AAO_Commit.Result r = AAO_Commit.commitCandidate(
            s.candidateByCode.get('C2').Id,
            s.internalDomains
        );
        Test.stopTest();

        System.assert(r.merged, 'The collision must be handled as a merge.');
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM AAO_Answer__c
                WHERE AAO_Opportunity__c = :s.opportunityByDeal.get('main')
            ],
            'The merge landed on the existing row rather than creating a second.'
        );
        System.assertEquals(
            'TRUE',
            r.answer.AAO_Verdict__c,
            'Having lost the race, the write still completed correctly.'
        );
        System.assertEquals(
            2,
            [
                SELECT COUNT()
                FROM AAO_Claim__c
                WHERE AAO_Opportunity__c = :s.opportunityByDeal.get('main')
            ],
            'Both receipts exist.'
        );
    }

    // =============================================== Evidence Contract immutability

    @IsTest
    static void editingAPropositionInPlaceIsRefused() {
        AAO_Seed.Loaded s = load();
        AAO_Evidence_Contract__c ec = s.contractByCode.get('AAO_T1');
        ec.AAO_Proposition_Text__c = 'Something the charter was never asked.';
        try {
            update ec;
            System.assert(
                false,
                'Every claim stamped with this contract was adjudicated against the words ' +
                'as they read then.'
            );
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('immutable'), e.getMessage());
        }
    }

    @IsTest
    static void theElementCountAndTheElementListCannotDisagree() {
        AAO_Seed.Loaded s = load();
        AAO_Evidence_Contract__c ec = new AAO_Evidence_Contract__c(
            AAO_Question_Record_Id__c = 'AAO_T9',
            AAO_Proposition_Text__c = 'A proposition.',
            AAO_Guidance_Text__c = 'Some guidance.',
            AAO_Elements__c = '[{"id":"e1"},{"id":"e2"}]',
            AAO_Element_Count__c = 5,
            AAO_Elements_Basis__c = 'Authored',
            AAO_Route__c = 'E',
            AAO_Speaker_Requirement__c = 'Any_Participant',
            AAO_Decay_Class__c = 'Event',
            AAO_Contract_State__c = 'Derived',
            AAO_Rubric_Version__c = 'mini-0.1.0'
        );
        try {
            insert ec;
            System.assert(
                false,
                'Coverage arithmetic reads the count and the blind reader reads the list.'
            );
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('cannot disagree'), e.getMessage());
        }
    }

    @IsTest
    static void theContractKeyIsComposedFromTheAuthoredText() {
        AAO_Seed.Loaded s = load();
        AAO_Evidence_Contract__c ec = [
            SELECT
                AAO_Contract_Key__c,
                AAO_Content_Hash__c,
                AAO_Question_Record_Id__c,
                AAO_Proposition_Text__c,
                AAO_Guidance_Text__c
            FROM AAO_Evidence_Contract__c
            WHERE Id = :s.contractByCode.get('AAO_T1').Id
        ];
        System.assertEquals(
            AAO_ContractKey.contentHash(
                ec.AAO_Proposition_Text__c,
                ec.AAO_Guidance_Text__c
            ),
            ec.AAO_Content_Hash__c,
            'The hash is the only detector of an in-place edit.'
        );
        System.assertEquals(
            ec.AAO_Question_Record_Id__c + '|' + ec.AAO_Content_Hash__c,
            ec.AAO_Contract_Key__c
        );
        System.assertEquals(
            ec.AAO_Question_Record_Id__c.length() + 1 + 64,
            ec.AAO_Contract_Key__c.length()
        );
        System.assertEquals(
            83,
            18 + 1 + 64,
            'The budget is a full 18-character question id plus a separator plus a ' +
            '64-character hash, which is exactly Text(83). There is no room for a version ' +
            'token, which is why AAO_ContractKey carries none.'
        );
    }

    // ============================================ Evidence Contract is not deletable

    /**
     * Ratified session 14. Until then the only thing between a live contract and a delete
     * was a WHERE clause in a purge, and session 13 proved that filter could be wrong
     * without anything complaining.
     */
    @IsTest
    static void contractsCannotBeDeletedOnTheLivePath() {
        AAO_Seed.Loaded s = load();
        AAO_Evidence_Contract__c ec = [
            SELECT Id, AAO_Synthetic__c FROM AAO_Evidence_Contract__c LIMIT 1
        ];

        // Marked synthetic by the seed, but PURGING is false, so this is the live path.
        System.assertEquals(false, AAO_Synthetic.PURGING);
        try {
            delete ec;
            System.assert(
                false,
                'A deletable contract leaves every claim stamped with it naming words that ' +
                'no longer exist.'
            );
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('not deletable'), e.getMessage());
            System.assert(
                e.getMessage().contains('Supersede'),
                'The error must name the retirement path that does exist. Got: ' +
                e.getMessage()
            );
        }
    }

    /**
     * And the purge path still works, because the rehearsal has to be removable in one
     * action. The law needs BOTH the marker and the context, so this builds a marked
     * contract rather than assuming the seed marks its own.
     *
     * Worth recording: the seed does NOT mark contracts on the AAO_Seed.load path. It does
     * on the demo path, because AAO_Pipeline sets the marker from the Source before calling
     * ensureContracts. So a contract's marker depends on which entry created it, and with
     * the delete law in place that now decides whether the purge can remove it.
     */
    @IsTest
    static void thePurgeContextCanStillRetireAMarkedContract() {
        AAO_Seed.Loaded s = load();
        AAO_Evidence_Contract__c source = [
            SELECT
                AAO_Proposition_Code__c,
                AAO_Proposition_Short__c,
                AAO_Proposition_Text__c,
                AAO_Guidance_Text__c,
                AAO_Elements__c,
                AAO_Element_Count__c,
                AAO_Elements_Basis__c,
                AAO_Route__c,
                AAO_Speaker_Requirement__c,
                AAO_Decay_Class__c,
                AAO_Contract_State__c,
                AAO_Rubric_Version__c
            FROM AAO_Evidence_Contract__c
            LIMIT 1
        ];

        AAO_Synthetic.MARK = true;
        AAO_Evidence_Contract__c marked = new AAO_Evidence_Contract__c(
            AAO_Question_Record_Id__c = 'PURGE_LAW_SPECIMEN',
            AAO_Proposition_Code__c = 'PURGE_LAW',
            AAO_Proposition_Short__c = source.AAO_Proposition_Short__c,
            AAO_Proposition_Text__c = 'A contract that exists only to be purged.',
            AAO_Guidance_Text__c = source.AAO_Guidance_Text__c,
            AAO_Elements__c = source.AAO_Elements__c,
            AAO_Element_Count__c = source.AAO_Element_Count__c,
            AAO_Elements_Basis__c = source.AAO_Elements_Basis__c,
            AAO_Route__c = source.AAO_Route__c,
            AAO_Speaker_Requirement__c = source.AAO_Speaker_Requirement__c,
            AAO_Decay_Class__c = source.AAO_Decay_Class__c,
            AAO_Contract_State__c = source.AAO_Contract_State__c,
            AAO_Rubric_Version__c = source.AAO_Rubric_Version__c
        );
        insert marked;
        AAO_Synthetic.MARK = false;

        System.assertEquals(
            true,
            [SELECT AAO_Synthetic__c FROM AAO_Evidence_Contract__c WHERE Id = :marked.Id]
                .AAO_Synthetic__c
        );

        // Marked but no purge context: still refused.
        try {
            delete marked;
            System.assert(false, 'The marker alone is not permission.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('not deletable'), e.getMessage());
        }

        AAO_Synthetic.PURGING = true;
        try {
            delete marked;
        } finally {
            AAO_Synthetic.PURGING = false;
        }
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Evidence_Contract__c WHERE Id = :marked.Id]
        );
    }
}
