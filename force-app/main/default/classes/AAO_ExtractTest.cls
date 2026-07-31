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
    private static final String Q_EARMARKED_FULL =
        'It came out of the operations modernisation pot, so it is earmarked for this ' +
        'project specifically, not a general pool.';
    // The quote that caused session 7's defect: real, verbatim, and it refutes the element
    // it was filed against.
    private static final String Q_CANNOT_TELL =
        'That I cannot tell you yet. Finance is still working through the calendar.';
    // In transcript one and in no span, so it is the probe for whether the second reader
    // was handed the artifact.
    private static final String NOT_IN_ANY_SPAN = 'So on the money side, where does this stand?';

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

    /** Replies in order, and keeps every request body for inspection. */
    private class SeqMock implements HttpCalloutMock {
        private List<String> bodies;
        private Integer i = 0;
        public List<String> sent = new List<String>();
        public SeqMock(List<String> bodies) {
            this.bodies = bodies;
        }
        public HttpResponse respond(HttpRequest req) {
            sent.add(req.getBody());
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody(bodies[Math.min(i++, bodies.size() - 1)]);
            return res;
        }
    }

    private static String blindEnvelope(List<Object> reviews) {
        return envelope(
            JSON.serialize(new Map<String, Object>{ 'reviews' => reviews }),
            'end_turn'
        );
    }

    private static Map<String, Object> review(String code, List<Object> elements) {
        return new Map<String, Object>{
            'proposition_code' => code,
            'elements' => elements
        };
    }

    private static Map<String, Object> elem(String id, Boolean established, String reason) {
        return new Map<String, Object>{
            'element' => id,
            'established' => established,
            'reason' => reason
        };
    }

    /** The extraction response that reproduces the 31 July specimen exactly. */
    private static String theSpecimen() {
        return envelope(
            JSON.serialize(
                new Map<String, Object>{
                    'findings' => new List<Object>{
                        finding(
                            'AAO_T1',
                            'addressed',
                            'FALSE',
                            new List<Object>{
                                span(Q_APPROVED, 'dana', 'e1'),
                                span(Q_EARMARKED_FULL, 'dana', 'e2'),
                                span(Q_CANNOT_TELL, 'dana', 'e3')
                            }
                        ),
                        finding('AAO_T2', 'not_addressed', 'NONE', null),
                        finding('AAO_T3', 'not_addressed', 'NONE', null),
                        finding('AAO_T4', 'not_addressed', 'NONE', null),
                        finding('AAO_T5', 'not_addressed', 'NONE', null),
                        finding('AAO_T6', 'not_addressed', 'NONE', null)
                    }
                }
            ),
            'end_turn'
        );
    }

    private static AAO_Extract.Config blindConfig() {
        AAO_Extract.Config c = testConfig();
        c.blindCharter = 'AAO_Blind_Reader';
        c.blindCharterVersion = '1.0.0';
        c.blindEnabled = true;
        return c;
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
     * With the second reader switched off, coverage falls back to elements that got a
     * located span. This is the session 7 behaviour and it is kept only so the second
     * reader can be switched out for a comparison. Two elements cited, three in the
     * contract, so the third is missing.
     */
    @IsTest
    static void withTheSecondReaderOffCoverageFallsBackToLocatedSpans() {
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
        System.assertEquals(2, o.modelDeclined, 'Two were discussed and not resolved.');
        System.assertEquals(4, o.nobodySaid, 'Four were never spoken to.');
        System.assertEquals(0, o.notReturned, 'The reader reported all six.');
        System.assertEquals(
            2,
            [
                SELECT COUNT()
                FROM AAO_Candidate__c
                WHERE AAO_Source__c = :src.Id AND AAO_Abstention_Reason__c = 'model_declined'
            ],
            'model_declined is reachable now that something actually reads the transcript.'
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
        System.assertEquals(
            6,
            [SELECT COUNT() FROM AAO_Candidate__c WHERE AAO_Source__c = :src.Id],
            'The ledger is still complete: a row per proposition considered.'
        );
        System.assertEquals(
            5,
            o.notReturned,
            'A proposition the reader never reported is not_returned. It is a fact about ' +
            'the charter, not a judgment about evidence.'
        );
        System.assertEquals(
            1,
            o.abstentions,
            'And it is NOT counted as an abstention. Only the one genuine nobody_said is, ' +
            'because an abstention rate that includes unreported propositions measures ' +
            'schema compliance and calls it something else.'
        );
        System.assertEquals(
            5,
            [
                SELECT COUNT()
                FROM AAO_Candidate__c
                WHERE AAO_Source__c = :src.Id AND AAO_Abstention_Reason__c = 'not_returned'
            ],
            'The reason is on the row, so the two cases are distinguishable after the fact. ' +
            'They were not on 31 July, which is why that run could not be diagnosed.'
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

    // ============================================================ the second reader

    /**
     * THE REGRESSION TEST FOR SESSION 7'S DEFECT, and the reason model call 2 exists.
     *
     * The first reader cites, for e3, a verbatim quote in which the speaker declines to
     * confirm e3. Session 7 counted that as coverage, coverage read full, and a wrong
     * FALSE was written as an established claim. The second reader refuses the element,
     * coverage drops to partial, and the partial route writes UNVERIFIED with its receipts,
     * which is the staged ground truth.
     */
    @IsTest
    static void theSecondReaderRefusesAnElementItsQuoteDoesNotEstablish() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        SeqMock mock = new SeqMock(
            new List<String>{
                theSpecimen(),
                blindEnvelope(
                    new List<Object>{
                        review(
                            'AAO_T1',
                            new List<Object>{
                                elem('e1', true, 'The funding is approved is an assertion.'),
                                elem('e2', true, 'Earmarked for this project specifically.'),
                                elem(
                                    'e3',
                                    false,
                                    'The speaker declines to say which fiscal year, so the ' +
                                    'quote is about this element and does not establish it.'
                                )
                            }
                        )
                    }
                )
            }
        );
        AAO_Extract.overrideConfig = blindConfig();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        AAO_Pipeline.Outcome o = AAO_Pipeline.runForSource(
            src.Id,
            new Set<String>{ 'altify.example' },
            AAO_Pipeline.FROM_MODEL
        );
        Test.stopTest();

        System.assertEquals(2, mock.sent.size(), 'Two model calls, extraction then blind.');
        System.assertEquals(0, o.spanDrops.size(), 'All three quotes are real.');
        System.assertEquals(1, o.blindOverrides.size(), 'One element was refused.');
        System.assert(
            o.blindOverrides[0].startsWith('AAO_T1/e3'),
            'Got: ' + o.blindOverrides[0]
        );

        AAO_Candidate__c cand = [
            SELECT AAO_Element_Coverage__c, AAO_Proposed_Verdict__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :src.Id AND AAO_Outcome__c != 'Abstained'
            LIMIT 1
        ];
        AAO_Model.Coverage cov = AAO_Model.parseCoverage(cand.AAO_Element_Coverage__c);
        System.assertEquals(
            new List<String>{ 'e1', 'e2' },
            cov.covered,
            'Only the two elements the second reader upheld.'
        );
        System.assertEquals(
            new List<String>{ 'e3' },
            cov.missing,
            'The refuted element is missing, which is what routes this to partial.'
        );
        System.assertEquals(
            false,
            cov.isFull(),
            'Partial coverage is the whole point: full coverage writes the verdict through.'
        );
    }

    /**
     * Blindness is structural, so it is asserted structurally. The second request must not
     * contain the artifact, and must not contain the first reader's verdict.
     */
    @IsTest
    static void theSecondReaderIsNeverGivenTheTranscriptOrTheFirstVerdict() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        SeqMock mock = new SeqMock(
            new List<String>{
                theSpecimen(),
                blindEnvelope(
                    new List<Object>{
                        review(
                            'AAO_T1',
                            new List<Object>{
                                elem('e1', true, 'asserted'),
                                elem('e2', true, 'asserted'),
                                elem('e3', false, 'declined')
                            }
                        )
                    }
                )
            }
        );
        AAO_Extract.overrideConfig = blindConfig();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        AAO_Pipeline.runForSource(
            src.Id,
            new Set<String>{ 'altify.example' },
            AAO_Pipeline.FROM_MODEL
        );
        Test.stopTest();

        String first = mock.sent[0];
        String second = mock.sent[1];

        System.assert(
            first.contains(NOT_IN_ANY_SPAN),
            'Sanity check: the first reader does get the transcript.'
        );
        System.assert(
            !second.contains(NOT_IN_ANY_SPAN),
            'The second reader was handed transcript text that was never cited. It is ' +
            'supposed to see the citations and nothing else.'
        );
        System.assert(
            !second.contains('proposed_verdict'),
            'The second reader was shown the first verdict, so it can agree with it.'
        );
        System.assert(
            second.contains(Q_CANNOT_TELL),
            'It does get the cited quotes; that is the thing it is judging.'
        );
    }

    /** The rubric is the cacheable prefix and the artifact must never precede it. */
    @IsTest
    static void theCacheBreakpointSitsOnTheRubricAndNotOnTheArtifact() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        SeqMock mock = new SeqMock(new List<String>{ theSpecimen() });
        AAO_Extract.Config cfg = testConfig();
        AAO_Extract.overrideConfig = cfg;
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        AAO_Extract.run(src.Id);
        Test.stopTest();

        String body = mock.sent[0];
        Integer breakpointAt = body.indexOf('cache_control');
        Integer transcriptAt = body.indexOf(NOT_IN_ANY_SPAN);
        System.assert(breakpointAt > 0, 'There is a cache breakpoint.');
        System.assert(
            breakpointAt < transcriptAt,
            'The breakpoint must precede the transcript. Anything volatile above it changes ' +
            'the prefix on every call and the cache silently never reads.'
        );
    }

    /** A second reader that says nothing about an element does not grant it coverage. */
    @IsTest
    static void aMissingSecondVerdictIsNotAYes() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        SeqMock mock = new SeqMock(
            new List<String>{
                theSpecimen(),
                // Answers e1 only. e2 and e3 are simply absent.
                blindEnvelope(
                    new List<Object>{
                        review('AAO_T1', new List<Object>{ elem('e1', true, 'asserted') })
                    }
                )
            }
        );
        AAO_Extract.overrideConfig = blindConfig();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        AAO_Pipeline.Outcome o = AAO_Pipeline.runForSource(
            src.Id,
            new Set<String>{ 'altify.example' },
            AAO_Pipeline.FROM_MODEL
        );
        Test.stopTest();

        AAO_Candidate__c cand = [
            SELECT AAO_Element_Coverage__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :src.Id AND AAO_Outcome__c != 'Abstained'
            LIMIT 1
        ];
        AAO_Model.Coverage cov = AAO_Model.parseCoverage(cand.AAO_Element_Coverage__c);
        System.assertEquals(
            new List<String>{ 'e1' },
            cov.covered,
            'Coverage needs an affirmative yes, and the absence of one is not one.'
        );
        System.assertEquals(2, o.blindOverrides.size());
    }

    /** The blind reader is never asked to judge standing. */
    @IsTest
    static void theBlindCharterDoesNotCarryTheSpeakerRule() {
        String prompt = AAO_BlindCharter.systemPrompt();
        System.assert(
            prompt.contains('Judge substance, not standing'),
            'It must be told explicitly to leave standing alone.'
        );
        System.assert(
            !prompt.contains('decision maker or influencer'),
            'The speaker requirement stays with AAO_SpeakerRule at commit, so the ' +
            'downgrade remains a law enforced by the schema and stays visible firing.'
        );
    }

    /** Absence of confirmation is UNVERIFIED, and the charter now says so in terms. */
    @IsTest
    static void theExtractionCharterForbidsFalseFromAbsence() {
        String prompt = AAO_ExtractCharter.systemPrompt();
        System.assert(
            prompt.contains('ABSENCE NEVER ESTABLISHES FALSE'),
            'The FALSE bar has to be explicit, because the model reached for FALSE on a ' +
            'missing confirmation on 31 July.'
        );
        System.assert(prompt.contains('I cannot tell you yet'), 'Named, because it happened.');
    }

    // ================================================ attribution and interpretation

    /**
     * Ratified 31 July: both readers are named on every row a model pass writes, including
     * the abstentions. Coverage routes the verdict, the second reader decides coverage, and
     * a coverage decision nobody can attribute is an answer nobody can attribute.
     */
    @IsTest
    static void bothReadersAreNamedOnEveryRowAModelPassWrites() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        AAO_Extract.overrideConfig = blindConfig();
        Test.setMock(
            HttpCalloutMock.class,
            new SeqMock(
                new List<String>{
                    theSpecimen(),
                    blindEnvelope(
                        new List<Object>{
                            review(
                                'AAO_T1',
                                new List<Object>{
                                    elem('e1', true, 'asserted'),
                                    elem('e2', true, 'asserted'),
                                    elem('e3', false, 'declined')
                                }
                            )
                        }
                    )
                }
            )
        );

        Test.startTest();
        AAO_Pipeline.runForSource(
            src.Id,
            new Set<String>{ 'altify.example' },
            AAO_Pipeline.FROM_MODEL
        );
        Test.stopTest();

        List<AAO_Candidate__c> rows = [
            SELECT
                AAO_Charter__c,
                AAO_Charter_Version__c,
                AAO_Blind_Charter__c,
                AAO_Blind_Charter_Version__c,
                AAO_Outcome__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :src.Id
        ];
        System.assertEquals(6, rows.size(), 'One row per proposition considered.');
        for (AAO_Candidate__c r : rows) {
            System.assertEquals('AAO_Extract_Evidence', r.AAO_Charter__c, 'the proposer');
            System.assertEquals('1.0.0', r.AAO_Charter_Version__c);
            System.assertEquals(
                'AAO_Blind_Reader',
                r.AAO_Blind_Charter__c,
                'Every row, abstentions included, names the second reader that ran on the ' +
                'pass. Outcome was ' + r.AAO_Outcome__c
            );
            System.assertEquals('1.0.0', r.AAO_Blind_Charter_Version__c);
        }
    }

    /** With no second reader, the blind fields are null rather than misleadingly filled. */
    @IsTest
    static void withNoSecondReaderTheBlindFieldsAreNull() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(HttpCalloutMock.class, new Mock(theSpecimen()));

        Test.startTest();
        AAO_Pipeline.runForSource(
            src.Id,
            new Set<String>{ 'altify.example' },
            AAO_Pipeline.FROM_MODEL
        );
        Test.stopTest();

        for (AAO_Candidate__c r : [
            SELECT AAO_Blind_Charter__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :src.Id
        ]) {
            System.assertEquals(
                null,
                r.AAO_Blind_Charter__c,
                'Null means no second reader ran, which for a model row means coverage ' +
                'fell back to counting located spans.'
            );
        }
    }

    /**
     * Item 31, the plumbing half. AAO_Interpretation__c has come back empty from every real
     * call so far, which is the good case and also means the path has never been exercised
     * by live data. This proves the path carries a populated interpretation to the row, so
     * that if a real one ever arrives it lands rather than being dropped.
     */
    @IsTest
    static void aPopulatedInterpretationReachesTheCandidateRow() {
        Id oppId = stageDeal();
        AAO_Source__c src = theSource(oppId);

        String reading =
            'Read "current fiscal year" as the customer\'s fiscal year rather than ours, ' +
            'because the proposition is about their budget.';
        Map<String, Object> f = finding(
            'AAO_T1',
            'addressed',
            'UNVERIFIED',
            new List<Object>{ span(Q_APPROVED, 'dana', 'e1') }
        );
        f.put('interpretation', reading);

        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(
            HttpCalloutMock.class,
            new Mock(
                envelope(
                    JSON.serialize(new Map<String, Object>{ 'findings' => new List<Object>{ f } }),
                    'end_turn'
                )
            )
        );

        Test.startTest();
        AAO_Pipeline.runForSource(
            src.Id,
            new Set<String>{ 'altify.example' },
            AAO_Pipeline.FROM_MODEL
        );
        Test.stopTest();

        AAO_Candidate__c cand = [
            SELECT AAO_Interpretation__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :src.Id AND AAO_Outcome__c != 'Abstained'
            LIMIT 1
        ];
        System.assertEquals(
            reading,
            cand.AAO_Interpretation__c,
            'The interpretation is the field that made the session 7 miss diagnosable. It ' +
            'must survive the trip from the charter to the row.'
        );
    }

    /** The schema still demands it, so a charter cannot quietly stop emitting it. */
    @IsTest
    static void theSchemaStillRequiresAnInterpretationField() {
        AAO_Ingest.AUTO = false;
        AAO_Demo.scaffold();
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
        ];
        String sch = JSON.serialize(
            AAO_ExtractCharter.schema(ecs, new Map<String, AAO_Model.Speaker>())
        );
        System.assert(sch.contains('"interpretation"'), 'Still in the schema.');
        System.assert(
            sch.contains('under-specified-question list'),
            'And still described as what it is for, so the reason to fill it survives ' +
            'charter edits.'
        );
    }
}
