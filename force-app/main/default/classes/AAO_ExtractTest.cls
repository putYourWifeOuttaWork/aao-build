/**
 * The model path, without a model.
 *
 * These tests exist because the interesting behaviour of a model integration is not what
 * happens when the model is right. It is what happens when it quotes something that is not
 * there, when it declines, when it runs out of room mid-JSON, and when it says nothing
 * about a proposition at all. None of those are reachable by calling the real API and
 * hoping, so the response is mocked and each case is asserted on purpose.
 *
 * The mocked responses are shaped like real ones, including a thinking block with empty
 * text ahead of the answer, because that is what actually arrives and reaching for
 * content[0] would work in a test built from a tidier fiction.
 */
@IsTest
private class AAO_ExtractTest {
    // Quotes that genuinely occur in dummy/transcript-one.
    private static final String Q_APPROVED = 'The funding is approved.';
    private static final String Q_EARMARKED =
        'it is earmarked for this project specifically, not a general pool.';
    private static final String Q_INVENTED = 'We have unlimited budget in perpetuity.';

    // ===================================================================== the harness

    private class Mock implements HttpCalloutMock {
        private String body;
        private Integer status = 200;
        public Mock(String body) {
            this.body = body;
        }
        public Mock(String body, Integer status) {
            this.body = body;
            this.status = status;
        }
        public HttpResponse respond(HttpRequest req) {
            // Asserted here rather than in a test, because it is true of every call: the
            // key is never in anything Apex builds. If this ever fails, a secret has been
            // moved into code.
            System.assert(
                !req.getBody().contains('sk-ant'),
                'The request body carries something that looks like an API key.'
            );
            System.assert(
                req.getEndpoint().startsWith('callout:'),
                'The endpoint must go through the named credential, not a literal host. ' +
                'Got: ' + req.getEndpoint()
            );
            HttpResponse res = new HttpResponse();
            res.setStatusCode(status);
            res.setStatus(status == 200 ? 'OK' : 'Error');
            res.setBody(body);
            return res;
        }
    }

    private static AAO_Extract.Config testConfig() {
        AAO_Extract.Config c = new AAO_Extract.Config();
        c.modelName = 'claude-opus-5';
        c.charter = 'AAO_Extract_Evidence';
        c.charterVersion = '1.0.0';
        c.namedCredential = 'AAO_Anthropic';
        c.endpointPath = '/v1/messages';
        c.effort = 'high';
        c.maxOutputTokens = 16000;
        c.timeoutMs = 120000;
        c.active = true;
        return c;
    }

    /** A response in the shape the API actually returns. */
    private static String envelope(String findingsJson, String stopReason) {
        return JSON.serialize(
            new Map<String, Object>{
                'model' => 'claude-opus-5',
                'stop_reason' => stopReason,
                'content' => new List<Object>{
                    // Thinking arrives first and carries no text under the default display
                    // setting. Code that takes content[0] breaks here, which is the point.
                    new Map<String, Object>{ 'type' => 'thinking', 'thinking' => '' },
                    new Map<String, Object>{ 'type' => 'text', 'text' => findingsJson }
                },
                'usage' => new Map<String, Object>{
                    'input_tokens' => 4211,
                    'output_tokens' => 883,
                    'cache_read_input_tokens' => 0,
                    'cache_creation_input_tokens' => 0
                }
            }
        );
    }

    private static Map<String, Object> finding(
        String code,
        String status,
        String verdict,
        List<Object> spans
    ) {
        return new Map<String, Object>{
            'proposition_code' => code,
            'status' => status,
            'proposed_verdict' => verdict,
            'interpretation' => '',
            'spans' => spans == null ? new List<Object>() : spans
        };
    }

    private static Map<String, Object> span(String quote, String speaker, String element) {
        return new Map<String, Object>{
            'quote' => quote,
            'speaker' => speaker,
            'element' => element
        };
    }

    private static Id stageDeal() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        Id oppId = c.oppByDeal.get(AAO_Demo.OPP_LIVE);
        AAO_Synthetic.MARK = true;
        AAO_Demo.findSource(c, 'T1SRC', oppId);
        AAO_Synthetic.MARK = false;
        return oppId;
    }

    private static AAO_Source__c theSource(Id oppId) {
        return [
            SELECT Id, AAO_Normalized_Text__c
            FROM AAO_Source__c
            WHERE AAO_Opportunity__c = :oppId
            LIMIT 1
        ];
    }

    // ================================================================== the good case

    /**
     * Coverage is computed from the spans that were located, never taken from the model.
     * Two elements cited, three in the contract, so the third is missing and the answer is
     * partial. The model is not asked what it covered and could not have said.
     */
    @IsTest
    static void coverageIsDerivedFromLocatedSpansAndNotFromTheModel() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        String findings = JSON.serialize(
            new Map<String, Object>{
                'findings' => new List<Object>{
                    finding(
                        'AAO_T1',
                        'addressed',
                        'TRUE',
                        new List<Object>{
                            span(Q_APPROVED, 'dana', 'e1'),
                            span(Q_EARMARKED, 'dana', 'e2')
                        }
                    ),
                    finding('AAO_T2', 'not_addressed', 'NONE', null),
                    finding('AAO_T3', 'not_addressed', 'NONE', null),
                    finding('AAO_T4', 'not_addressed', 'NONE', null),
                    finding('AAO_T5', 'not_addressed', 'NONE', null),
                    finding('AAO_T6', 'not_addressed', 'NONE', null)
                }
            }
        );

        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(HttpCalloutMock.class, new Mock(envelope(findings, 'end_turn')));

        Test.startTest();
        AAO_Pipeline.Outcome o = AAO_Pipeline.runForSource(
            src.Id,
            new Set<String>{ 'altify.example' },
            AAO_Pipeline.FROM_MODEL
        );
        Test.stopTest();

        System.assertEquals('staged', o.status);
        System.assertEquals('model', o.proposalSource);
        System.assertEquals(
            '1.0.0',
            o.charterVersion,
            'The charter version on the rows must come from configuration, not from the ' +
            'fixture constant.'
        );

        AAO_Candidate__c cand = [
            SELECT AAO_Element_Coverage__c, AAO_Proposed_Verdict__c, AAO_Charter_Version__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :src.Id AND AAO_Outcome__c != 'Abstained'
            LIMIT 1
        ];
        AAO_Model.Coverage cov = AAO_Model.parseCoverage(cand.AAO_Element_Coverage__c);
        System.assertEquals(2, cov.covered.size(), 'Two elements were cited.');
        System.assertEquals(
            new List<String>{ 'e3' },
            cov.missing,
            'The third element of the contract was never cited, so it is missing. ' +
            'Nothing in the response said so.'
        );
        System.assertEquals(false, cov.isFull());
        System.assertEquals('1.0.0', cand.AAO_Charter_Version__c);
    }

    // ============================================================= the interesting cases

    /**
     * The one that matters most. A quote that is not in the artifact is dropped and
     * counted, the run continues, and the coverage it would have carried is not credited.
     */
    @IsTest
    static void aQuoteThatIsNotInTheArtifactIsDroppedAndCountedNotTrusted() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        String findings = JSON.serialize(
            new Map<String, Object>{
                'findings' => new List<Object>{
                    finding(
                        'AAO_T1',
                        'addressed',
                        'TRUE',
                        new List<Object>{
                            span(Q_APPROVED, 'dana', 'e1'),
                            span(Q_INVENTED, 'dana', 'e3')
                        }
                    ),
                    finding('AAO_T2', 'not_addressed', 'NONE', null),
                    finding('AAO_T3', 'not_addressed', 'NONE', null),
                    finding('AAO_T4', 'not_addressed', 'NONE', null),
                    finding('AAO_T5', 'not_addressed', 'NONE', null),
                    finding('AAO_T6', 'not_addressed', 'NONE', null)
                }
            }
        );

        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(HttpCalloutMock.class, new Mock(envelope(findings, 'end_turn')));

        Test.startTest();
        AAO_Pipeline.Outcome o = AAO_Pipeline.runForSource(
            src.Id,
            new Set<String>{ 'altify.example' },
            AAO_Pipeline.FROM_MODEL
        );
        Test.stopTest();

        System.assertEquals(
            'staged',
            o.status,
            'A fabricated quote is a finding about the model, not a reason to abort the run.'
        );
        System.assertEquals(1, o.spanDrops.size());
        System.assertEquals('not_in_artifact', o.spanDrops[0].reason);
        System.assertEquals('AAO_T1', o.spanDrops[0].contractCode);

        AAO_Candidate__c cand = [
            SELECT AAO_Element_Coverage__c, AAO_Spans__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :src.Id AND AAO_Outcome__c != 'Abstained'
            LIMIT 1
        ];
        AAO_Model.Coverage cov = AAO_Model.parseCoverage(cand.AAO_Element_Coverage__c);
        System.assertEquals(
            new List<String>{ 'e1' },
            cov.covered,
            'Only the span that survived location counts toward coverage.'
        );
        System.assert(
            cov.missing.contains('e3'),
            'The element the invented quote was offered for is still missing.'
        );
        System.assertEquals(
            1,
            AAO_Model.parseSpans(cand.AAO_Spans__c).spans.size(),
            'The invented span is not stored, so nothing downstream can rest on it.'
        );
    }

    /**
     * The two abstention reasons are the reason the enum has two values. Until something
     * read a transcript, model_missed was unreachable and every abstention was asserted to
     * be nobody_said.
     */
    @IsTest
    static void notAddressedAndAbstainedAreRecordedAsDifferentReasons() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        String findings = JSON.serialize(
            new Map<String, Object>{
                'findings' => new List<Object>{
                    finding('AAO_T1', 'abstained', 'NONE', null),
                    finding('AAO_T2', 'abstained', 'NONE', null),
                    finding('AAO_T3', 'not_addressed', 'NONE', null),
                    finding('AAO_T4', 'not_addressed', 'NONE', null),
                    finding('AAO_T5', 'not_addressed', 'NONE', null),
                    finding('AAO_T6', 'not_addressed', 'NONE', null)
                }
            }
        );

        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(HttpCalloutMock.class, new Mock(envelope(findings, 'end_turn')));

        Test.startTest();
        AAO_Pipeline.Outcome o = AAO_Pipeline.runForSource(
            src.Id,
            new Set<String>{ 'altify.example' },
            AAO_Pipeline.FROM_MODEL
        );
        Test.stopTest();

        System.assertEquals(6, o.abstentions, 'Nothing was proposed, so every row abstains.');
        System.assertEquals(2, o.modelMissed, 'Two were discussed and not resolved.');
        System.assertEquals(4, o.nobodySaid, 'Four were never spoken to.');
        System.assertEquals(
            2,
            [
                SELECT COUNT()
                FROM AAO_Candidate__c
                WHERE AAO_Source__c = :src.Id AND AAO_Abstention_Reason__c = 'model_missed'
            ],
            'model_missed is reachable now that something actually reads the transcript.'
        );
    }

    /** A proposition the model simply omits is owed, not silently skipped. */
    @IsTest
    static void aPropositionTheModelIgnoresIsRecordedAsOwed() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        String findings = JSON.serialize(
            new Map<String, Object>{
                'findings' => new List<Object>{
                    finding('AAO_T1', 'not_addressed', 'NONE', null)
                }
            }
        );

        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(HttpCalloutMock.class, new Mock(envelope(findings, 'end_turn')));

        Test.startTest();
        AAO_Pipeline.Outcome o = AAO_Pipeline.runForSource(
            src.Id,
            new Set<String>{ 'altify.example' },
            AAO_Pipeline.FROM_MODEL
        );
        Test.stopTest();

        System.assertEquals(5, o.extraction.unanswered.size(), 'Five were never answered.');
        System.assertEquals(6, o.abstentions, 'The ledger is still complete.');
        System.assertEquals(
            5,
            o.modelMissed,
            'An unanswered proposition is the model missing it, not nobody speaking to it.'
        );
    }

    /** Tokens are the proof register's first real numbers, so they must survive the trip. */
    @IsTest
    static void tokenCountsAreCarriedBackWithTheModelThatProducedThem() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        String findings = JSON.serialize(
            new Map<String, Object>{
                'findings' => new List<Object>{
                    finding('AAO_T1', 'not_addressed', 'NONE', null),
                    finding('AAO_T2', 'not_addressed', 'NONE', null),
                    finding('AAO_T3', 'not_addressed', 'NONE', null),
                    finding('AAO_T4', 'not_addressed', 'NONE', null),
                    finding('AAO_T5', 'not_addressed', 'NONE', null),
                    finding('AAO_T6', 'not_addressed', 'NONE', null)
                }
            }
        );

        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(HttpCalloutMock.class, new Mock(envelope(findings, 'end_turn')));

        Test.startTest();
        AAO_Extract.Result r = AAO_Extract.run(src.Id);
        Test.stopTest();

        System.assertEquals(4211, r.usage.inputTokens);
        System.assertEquals(883, r.usage.outputTokens);
        System.assertEquals('claude-opus-5', r.modelReported);
        System.assertEquals('1.0.0', r.charterVersion);
        System.assert(r.promptChars > 0, 'The prompt is assembled from records, not empty.');
    }

    // ======================================================================= refusals

    /** A refusal is HTTP 200 with no usable content. It must be said, not parsed. */
    @IsTest
    static void aRefusalIsReportedRatherThanParsedAsAnEmptyAnswer() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        String body = JSON.serialize(
            new Map<String, Object>{
                'model' => 'claude-opus-5',
                'stop_reason' => 'refusal',
                'stop_details' => new Map<String, Object>{
                    'type' => 'refusal',
                    'category' => 'cyber'
                },
                'content' => new List<Object>(),
                'usage' => new Map<String, Object>{
                    'input_tokens' => 10,
                    'output_tokens' => 0
                }
            }
        );

        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(HttpCalloutMock.class, new Mock(body));

        Boolean threw = false;
        String message;
        Test.startTest();
        try {
            AAO_Extract.run(src.Id);
        } catch (AAO_Extract.ExtractException e) {
            threw = true;
            message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'A refusal must not read as a clean empty result.');
        System.assert(message.contains('declined'), message);
        System.assertEquals(
            0,
            [SELECT COUNT() FROM AAO_Candidate__c WHERE AAO_Source__c = :src.Id],
            'A refusal writes nothing at all.'
        );
    }

    /** Truncated JSON is a configuration problem and the message has to say which. */
    @IsTest
    static void hittingMaxTokensSaysSoInsteadOfFailingToParse() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(
            HttpCalloutMock.class,
            new Mock(envelope('{"findings":[{"proposition_c', 'max_tokens'))
        );

        Boolean threw = false;
        String message;
        Test.startTest();
        try {
            AAO_Extract.run(src.Id);
        } catch (AAO_Extract.ExtractException e) {
            threw = true;
            message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, threw);
        System.assert(
            message.contains('AAO_Max_Output_Tokens__c'),
            'The message must name the field to change. Got: ' + message
        );
    }

    /** A non-200 says what the endpoint said, so the failure is diagnosable. */
    @IsTest
    static void anErrorStatusIsReportedWithTheBody() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(
            HttpCalloutMock.class,
            new Mock('{"type":"error","error":{"type":"authentication_error"}}', 401)
        );

        Boolean threw = false;
        String message;
        Test.startTest();
        try {
            AAO_Extract.run(src.Id);
        } catch (AAO_Extract.ExtractException e) {
            threw = true;
            message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, threw);
        System.assert(message.contains('401'), message);
        System.assert(message.contains('authentication_error'), message);
    }

    /** The off switch is configuration, so turning model calls off needs no deploy. */
    @IsTest
    static void anInactiveConfigRefusesToCallOutAtAll() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        AAO_Extract.Config cfg = testConfig();
        cfg.active = false;
        AAO_Extract.overrideConfig = cfg;

        Boolean threw = false;
        Test.startTest();
        try {
            AAO_Extract.run(src.Id);
        } catch (AAO_Extract.ExtractException e) {
            threw = true;
        }
        Test.stopTest();
        System.assertEquals(true, threw);
    }

    // ================================================================ the charter itself

    /**
     * Every vocabulary the model can answer in comes from the org. It cannot name a
     * proposition we do not hold or a person who was not on the call, because there is no
     * string it could return that would mean that.
     */
    @IsTest
    static void everyVocabularyInTheSchemaIsBuiltFromOrgRecords() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.Ctx c = AAO_Demo.scaffold();
        List<AAO_Evidence_Contract__c> ecs = [
            SELECT
                Id,
                AAO_Proposition_Code__c,
                AAO_Proposition_Short__c,
                AAO_Proposition_Text__c,
                AAO_Guidance_Text__c,
                AAO_Elements__c,
                AAO_Speaker_Requirement__c,
                AAO_Per_Person_Source__c
            FROM AAO_Evidence_Contract__c
            ORDER BY AAO_Proposition_Code__c
        ];
        Map<String, AAO_Model.Speaker> roster = AAO_Model.parseRoster(c.rosterJson);

        Test.startTest();
        Map<String, Object> sch = AAO_ExtractCharter.schema(ecs, roster);
        Test.stopTest();

        String asText = JSON.serialize(sch);
        System.assert(asText.contains('"AAO_T1"'), 'Proposition codes come from the rubric.');
        System.assert(asText.contains('"dana"'), 'Speakers come from the roster.');
        System.assert(
            asText.contains('"not_addressed"') && asText.contains('"abstained"'),
            'The two abstention states are separate values in the schema itself.'
        );
        System.assert(
            asText.contains('"additionalProperties":false'),
            'Structured output requires closed objects.'
        );
    }

    /** The prompt is assembled from records. Change the guidance, change the prompt. */
    @IsTest
    static void thePromptCarriesTheContractTextAsTheOrgHoldsIt() {
        Id oppId = stageDeal();
        AAO_Source__c src = [
            SELECT
                Id,
                AAO_Source_Ref__c,
                AAO_Normalized_Text__c,
                AAO_Speaker_Roster__c,
                AAO_Diarization__c
            FROM AAO_Source__c
            WHERE AAO_Opportunity__c = :oppId
            LIMIT 1
        ];
        List<AAO_Evidence_Contract__c> ecs = [
            SELECT
                Id,
                AAO_Proposition_Code__c,
                AAO_Proposition_Short__c,
                AAO_Proposition_Text__c,
                AAO_Guidance_Text__c,
                AAO_Elements__c,
                AAO_Speaker_Requirement__c,
                AAO_Per_Person_Source__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Proposition_Code__c = 'AAO_T1'
        ];

        Test.startTest();
        String user = AAO_ExtractCharter.userContent(
            src,
            ecs,
            AAO_Model.parseRoster(src.AAO_Speaker_Roster__c)
        );
        Test.stopTest();

        System.assert(
            user.contains(ecs[0].AAO_Proposition_Text__c),
            'The proposition text is injected verbatim from the record.'
        );
        System.assert(
            user.contains(ecs[0].AAO_Guidance_Text__c),
            'So is the guidance.'
        );
        System.assert(user.contains('e1: funds are approved'), 'So are the elements.');
        System.assert(
            user.contains('decision maker or influencer'),
            'And the speaker requirement, in words.'
        );
        System.assert(
            user.contains('Do not let this change your verdict'),
            'With the instruction that stops the charter pre-empting the speaker gate.'
        );
        System.assert(
            user.contains(src.AAO_Normalized_Text__c),
            'The artifact is sent exactly as stored, because quotes are matched against it.'
        );
        System.assert(
            !user.contains('UNVERIFIED'),
            'The charter must not be shown the mirror vocabulary as current state.'
        );
    }
}
