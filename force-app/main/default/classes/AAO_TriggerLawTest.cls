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

        // Same deal, same artifact, same part. The unique index is the dedup target.
        AAO_Source__c dup = new AAO_Source__c(
            AAO_Opportunity__c = src.AAO_Opportunity__c,
            AAO_Account__c = s.accountId,
            AAO_Normalized_Text__c = 'priya\tRedelivered.',
            AAO_Diarization__c = 'Attributed',
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

    // ===================================================== Claim is insert only

    @IsTest
    static void claimsCannotBeEdited() {
        AAO_Seed.Loaded s = load();
        AAO_Commit.commitCandidate(s.candidateByCode.get('C1').Id, s.internalDomains);

        AAO_Claim__c c = [SELECT Id, AAO_Verdict_After__c FROM AAO_Claim__c LIMIT 1];
        c.AAO_Verdict_After__c = 'TRUE';
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
}
