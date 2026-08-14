/**
 * Tests for the Extract-Bind-Verify pass, Charters v2.4 §P7.3.
 *
 * The pass is four stages and only two of them call out, which is the reason it is testable at
 * all: `plan`, `planVerify` and `stage4` are pure Apex over a state object, so the binding
 * fan-out, byte verification, the three-way verdict mapping and the complete ledger can all be
 * asserted without spending a token.
 *
 * WHAT THESE TESTS ARE FOR, and it is not coverage. Each one names a way the pass could be
 * wrong in a manner a green run would not reveal: a span that is not in the artifact counted as
 * silence, a rejection that still writes a claim, a verifier that is the same model as the
 * binder, a family fanned out to a person who has no contract. A count that passes can pass by
 * coincidence, so every assertion here checks what the number counts and not that it matched.
 */
@IsTest
private class AAO_EBVTest {
    // Two turns, both quoting exactly. The duplicate line is deliberate: it is the ambiguity
    // case, and byte verification must refuse it rather than pick one.
    private static final String LINE_A = 'The current tool is what my team complains about most.';
    private static final String LINE_B = 'I will need to take this to Dana before anything is signed.';
    private static final String LINE_DUP = 'Right, understood.';

    private static final String TEXT =
        'SPK_1: ' + LINE_A + '\n' +
        'SPK_2: ' + LINE_DUP + '\n' +
        'SPK_1: ' + LINE_B + '\n' +
        'SPK_2: ' + LINE_DUP + '\n';

    // ===================================================================== the harness

    private class Mock implements HttpCalloutMock {
        private List<String> bodies;
        private Integer i = 0;
        public List<String> sent = new List<String>();
        public Mock(List<String> bodies) {
            this.bodies = bodies;
        }
        public HttpResponse respond(HttpRequest req) {
            System.assert(
                !req.getBody().contains('sk-ant'),
                'The request body carries something that looks like an API key.'
            );
            System.assert(
                req.getEndpoint().startsWith('callout:'),
                'The endpoint must go through the named credential. Got: ' + req.getEndpoint()
            );
            sent.add(req.getBody());
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody(bodies[Math.min(i++, bodies.size() - 1)]);
            return res;
        }
    }

    private static String envelope(Object payload, String model) {
        return JSON.serialize(
            new Map<String, Object>{
                'model' => model,
                'stop_reason' => 'end_turn',
                'content' => new List<Object>{
                    new Map<String, Object>{ 'type' => 'thinking', 'thinking' => '' },
                    new Map<String, Object>{
                        'type' => 'text',
                        'text' => JSON.serialize(payload)
                    }
                },
                'usage' => new Map<String, Object>{
                    'input_tokens' => 1000,
                    'output_tokens' => 200,
                    'cache_read_input_tokens' => 0,
                    'cache_creation_input_tokens' => 0
                }
            }
        );
    }

    private static AAO_Extract.Config testConfig() {
        AAO_Extract.Config c = new AAO_Extract.Config();
        c.modelName = 'claude-opus-5';
        c.charter = 'AAO_Extract_Evidence';
        c.charterVersion = '1.1.0';
        c.namedCredential = 'AAO_Anthropic';
        c.endpointPath = '/v1/messages';
        c.effort = 'high';
        c.maxOutputTokens = 16000;
        c.timeoutMs = 120000;
        c.active = true;
        c.inventoryModel = 'claude-opus-5';
        c.inventoryCharter = 'AAO_Inventory_Read';
        c.inventoryCharterVersion = '1.0.0';
        c.bindModel = 'claude-sonnet-5';
        c.bindCharter = 'AAO_Bind_Proposition';
        c.bindCharterVersion = '1.0.0';
        c.bindGroupSize = 24;
        c.verifyModel = 'claude-haiku-4-5-20251001';
        c.verifyCharter = 'AAO_Coextension_Reader';
        c.verifyCharterVersion = '1.0.0';
        c.verifyGroupSize = 60;
        return c;
    }

    private class Fixture {
        Id oppId;
        Id acctId;
        Id contactId;
        Id sourceId;
        Map<String, AAO_Evidence_Contract__c> contracts;
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO EBV Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO EBV Test Deal',
            AccountId = a.Id,
            StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        // FirstName and LastName as read. The final-space split broke on St. Clair.
        Contact c = new Contact(
            FirstName = 'Ashley',
            LastName = 'St. Clair',
            Title = 'Director of Operations',
            AccountId = a.Id
        );
        insert c;

        AAO_Model.Speaker s1 = new AAO_Model.Speaker();
        s1.key = 'SPK_1';
        s1.display = 'Ashley St. Clair';
        s1.contactId = String.valueOf(c.Id);
        AAO_Model.Speaker s2 = new AAO_Model.Speaker();
        s2.key = 'SPK_2';
        s2.display = 'Renee Martin';
        AAO_Model.Roster r = new AAO_Model.Roster();
        r.v = AAO_Model.ROSTER_V;
        r.speakers = new List<AAO_Model.Speaker>{ s1, s2 };

        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = o.Id,
            AAO_Account__c = a.Id,
            AAO_Source_Ref__c = 'test/ebv',
            // The fingerprint is structural at insert and the trigger refuses a Source
            // without one, which is the omission-impossible-by-construction law doing its job
            // on a test as readily as on a run.
            AAO_Artifact_SHA256__c = AAO_NormalForm.sha256(TEXT),
            AAO_Normalized_Text__c = TEXT,
            AAO_Speaker_Roster__c = JSON.serialize(r),
            AAO_Diarization__c = 'Attributed',
            AAO_Synthetic__c = true
        );
        insert src;

        // NO PARTICIPANT ROW IS WRITTEN HERE, and the first version of this fixture wrote one.
        // Ingest already records participants from the roster on insert, so a hand-written row
        // collides on the participant key — which is the idempotence guard working, on a test
        // that was quietly duplicating what the product does. The roster's `contactId` is what
        // puts Ashley on the applicable set, and it does so through the real writer.
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM AAO_Participant__c
                WHERE AAO_Source__c = :src.Id AND AAO_Contact__c = :c.Id
            ],
            'Ingest records participants from the roster. If this is zero the roster shape ' +
            'changed and every applicable-set assertion below is measuring nothing.'
        );

        Fixture f = new Fixture();
        f.oppId = o.Id;
        f.acctId = a.Id;
        f.contactId = c.Id;
        f.sourceId = src.Id;
        f.contracts = new Map<String, AAO_Evidence_Contract__c>();
        // A MARKED SOURCE WITH UNMARKED CONTRACTS, deliberately, because that is the
        // combination the resolver actually reads: `AAO_ApplicableSet.isSynthetic` returns
        // false unconditionally and says in its own comment that it preserves the semantics of
        // the read it replaced rather than improving on them. A fixture that marked its
        // contracts too would resolve nothing and the failure would look like the pass.
        AAO_Synthetic.MARK = false;
        for (
            AAO_Evidence_Contract__c ec : AAO_PeopleContracts.build(new Set<Id>{ c.Id }).contracts
        ) {
            f.contracts.put(ec.AAO_Proposition_Code__c, ec);
        }
        return f;
    }

    private static Map<String, Object> item(
        String speaker,
        String subject,
        String span,
        List<String> families
    ) {
        return new Map<String, Object>{
            'speaker' => speaker,
            'subject' => subject,
            'anchor' => 'turn 1',
            'span' => span,
            'families' => families
        };
    }

    private static Map<String, Object> binding(String id, String verdict) {
        return new Map<String, Object>{
            'id' => id,
            'verdict' => verdict,
            'reason' => 'because of the words in the span'
        };
    }

    private static Map<String, Object> verdictRow(String id, Boolean ok, String axis) {
        return new Map<String, Object>{
            'id' => id,
            'coextensive' => ok,
            'axis' => axis,
            'reason' => 'the span does not say what the claim says'
        };
    }

    // =================================================== stage 1 · what the read is asked

    @IsTest
    static void theReadIsAskedAboutFamiliesAndNotAboutPerPersonCodes() {
        Fixture f = fixture();
        AAO_Extract.overrideConfig = testConfig();
        Mock m = new Mock(
            new List<String>{
                envelope(
                    new Map<String, Object>{
                        'items' => new List<Object>{
                            item('SPK_1', 'p1', LINE_A, new List<String>{ 'S2' })
                        }
                    },
                    'claude-opus-5'
                )
            }
        );
        Test.setMock(HttpCalloutMock.class, m);

        Test.startTest();
        AAO_EBV.State s = AAO_EBV.stage1(
            AAO_EBV.begin(f.sourceId, new Set<String>{ AAO_ApplicableSet.PEOPLE })
        );
        Test.stopTest();

        System.assertEquals(
            16,
            s.declaredContracts,
            'Sixteen questions for one person. The B&V deal is the same sixteen across three ' +
            'people, which is forty-eight, and Emerson is the same sixteen across seventeen.'
        );
        System.assertEquals(
            16,
            s.families,
            'One person, so contracts and families happen to be equal here. The number that ' +
            'matters is that families never multiply by the roster: three people is still ' +
            'sixteen families and seventeen people is still sixteen.'
        );
        String body = m.sent[0];
        System.assert(
            !body.contains('S2' + AAO_PeopleContracts.SEP + f.contactId),
            'The read must never be shown a per-person code. Sending one is the retired ' +
            'shape wearing the new one\'s name.'
        );
        System.assert(
            body.contains('p1'),
            'The subject vocabulary is handles, so the read can name a person without an id.'
        );
        System.assertEquals(1, s.inventoryItems);
    }

    // ==================================================== plan · the deterministic middle

    @IsTest
    static void oneItemNamingThreeFamiliesBecomesThreeBindingsWithNoExtraReading() {
        Fixture f = fixture();
        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(
            HttpCalloutMock.class,
            new Mock(
                new List<String>{
                    envelope(
                        new Map<String, Object>{
                            'items' => new List<Object>{
                                item(
                                    'SPK_1',
                                    'p1',
                                    LINE_A,
                                    new List<String>{ 'S1', 'S2', 'S4' }
                                )
                            }
                        },
                        'claude-opus-5'
                    )
                }
            )
        );

        Test.startTest();
        AAO_EBV.State s = AAO_EBV.plan(
            AAO_EBV.stage1(
                AAO_EBV.begin(f.sourceId, new Set<String>{ AAO_ApplicableSet.PEOPLE })
            )
        );
        Test.stopTest();

        System.assertEquals(
            3,
            s.bindingsAttempted,
            'The fan-out is Apex composing token#contactId, not a second model call.'
        );
        Set<String> codes = new Set<String>();
        for (AAO_BindCharter.BindItem b : s.bindPlan) {
            codes.add(b.contractCode);
            System.assertEquals(
                f.contactId,
                b.subjectContactId,
                'Every binding carries the person the contract is about.'
            );
            System.assertEquals(LINE_A, b.span);
        }
        System.assertEquals(
            new Set<String>{
                'S1' + AAO_PeopleContracts.SEP + f.contactId,
                'S2' + AAO_PeopleContracts.SEP + f.contactId,
                'S4' + AAO_PeopleContracts.SEP + f.contactId
            },
            codes
        );
    }

    @IsTest
    static void aSpanThatIsNotInTheArtifactIsDroppedAndNotBound() {
        Fixture f = fixture();
        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(
            HttpCalloutMock.class,
            new Mock(
                new List<String>{
                    envelope(
                        new Map<String, Object>{
                            'items' => new List<Object>{
                                item(
                                    'SPK_1',
                                    'p1',
                                    'The current tool is what my team complain about most.',
                                    new List<String>{ 'S2' }
                                ),
                                item('SPK_2', 'p1', LINE_DUP, new List<String>{ 'S1' })
                            }
                        },
                        'claude-opus-5'
                    )
                }
            )
        );

        Test.startTest();
        AAO_EBV.State s = AAO_EBV.plan(
            AAO_EBV.stage1(
                AAO_EBV.begin(f.sourceId, new Set<String>{ AAO_ApplicableSet.PEOPLE })
            )
        );
        Test.stopTest();

        System.assertEquals(
            1,
            s.spanDropsNotFound,
            'One word changed is not a verbatim span. "complain" for "complains".'
        );
        System.assertEquals(
            1,
            s.spanDropsAmbiguous,
            'A span occurring twice cannot be attributed to a turn, so nobody said it.'
        );
        System.assertEquals(0, s.bindingsAttempted, 'Neither item survived byte verification.');
        System.assertEquals(2, s.drops.size(), 'Every drop is recorded, never only counted.');
    }

    @IsTest
    static void aStatementAboutSomebodyOutsideTheSetIsCountedAndNotGuessedAt() {
        Fixture f = fixture();
        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(
            HttpCalloutMock.class,
            new Mock(
                new List<String>{
                    envelope(
                        new Map<String, Object>{
                            'items' => new List<Object>{
                                item(
                                    'SPK_1',
                                    AAO_InventoryCharter.SUBJECT_NONE,
                                    LINE_B,
                                    new List<String>{ 'S2' }
                                )
                            }
                        },
                        'claude-opus-5'
                    )
                }
            )
        );

        Test.startTest();
        AAO_EBV.State s = AAO_EBV.plan(
            AAO_EBV.stage1(
                AAO_EBV.begin(f.sourceId, new Set<String>{ AAO_ApplicableSet.PEOPLE })
            )
        );
        Test.stopTest();

        System.assertEquals(
            0,
            s.bindingsAttempted,
            'A subject of "none" has no contract to bind to, and the pass must not pick one.'
        );
        System.assertEquals(
            1,
            s.familyWithoutContract,
            'The family is real and no contract exists for a deal-scoped subject under a ' +
            'People declaration. That is a gap in the set, not a defect in the read.'
        );
    }

    // ============================================= stage 3 · the rejection that must bite

    @IsTest
    static void aRejectedVerificationDoesNotWriteAnEstablishedClaim() {
        Fixture f = fixture();
        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(
            HttpCalloutMock.class,
            new Mock(
                new List<String>{
                    envelope(
                        new Map<String, Object>{
                            'items' => new List<Object>{
                                item('SPK_1', 'p1', LINE_A, new List<String>{ 'S1' }),
                                item('SPK_1', 'p1', LINE_B, new List<String>{ 'S2' })
                            }
                        },
                        'claude-opus-5'
                    ),
                    envelope(
                        new Map<String, Object>{
                            'bindings' => new List<Object>{
                                binding('b1', AAO_BindCharter.ESTABLISHES),
                                binding('b2', AAO_BindCharter.ESTABLISHES)
                            }
                        },
                        'claude-sonnet-5'
                    ),
                    envelope(
                        new Map<String, Object>{
                            'verdicts' => new List<Object>{
                                verdictRow('v1', true, AAO_VerifyCharter.AXIS_NONE),
                                verdictRow('v2', false, AAO_VerifyCharter.AXIS_QUANTITY)
                            }
                        },
                        'claude-haiku-4-5-20251001'
                    )
                }
            )
        );

        Test.startTest();
        AAO_EBV.State s = AAO_EBV.begin(
            f.sourceId,
            new Set<String>{ AAO_ApplicableSet.PEOPLE }
        );
        s = AAO_EBV.plan(AAO_EBV.stage1(s));
        s = AAO_EBV.planVerify(AAO_EBV.stage2Step(s));
        s = AAO_EBV.stage3Step(s);
        s = AAO_EBV.stage4(s, new Set<String>{ 'altify.com' });
        Test.stopTest();

        System.assertEquals(2, s.establishedByBinder, 'The binder accepted both.');
        System.assertEquals(
            1,
            s.verificationRejections,
            'The blind reader refused one. This count IS the argument for the stage.'
        );
        System.assertEquals(
            1,
            s.claimsEstablished,
            'Two bindings, one rejection, one established claim. A rejection that still ' +
            'writes TRUE would make the whole stage decorative.'
        );

        Map<String, AAO_Candidate__c> byCode = new Map<String, AAO_Candidate__c>();
        for (AAO_Candidate__c cd : [
            SELECT
                AAO_Proposed_Verdict__c,
                AAO_Element_Completeness__c,
                AAO_Interpretation__c,
                AAO_Outcome__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :f.sourceId
        ]) {
            byCode.put(cd.AAO_Evidence_Contract__r.AAO_Proposition_Code__c, cd);
        }
        AAO_Candidate__c refused = byCode.get('S2' + AAO_PeopleContracts.SEP + f.contactId);
        System.assertNotEquals(null, refused);
        System.assertEquals(
            'UNVERIFIED',
            refused.AAO_Proposed_Verdict__c,
            'A refused claim is UNVERIFIED, never FALSE: absence of a carried claim is not ' +
            'a denial.'
        );
        System.assert(
            refused.AAO_Interpretation__c != null &&
            refused.AAO_Interpretation__c.startsWith('blind reader refused:'),
            'The reason a claim was refused must be legible on the row, not only in a log.'
        );
        AAO_Model.Coverage cov = AAO_Model.parseCoverage(refused.AAO_Element_Completeness__c);
        System.assertEquals(0, cov.covered.size(), 'Coverage needs an affirmative yes.');
    }

    @IsTest
    static void theCompleteLedgerCoversEveryDeclaredContract() {
        Fixture f = fixture();
        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(
            HttpCalloutMock.class,
            new Mock(
                new List<String>{
                    envelope(
                        new Map<String, Object>{
                            'items' => new List<Object>{
                                item('SPK_1', 'p1', LINE_A, new List<String>{ 'S1' })
                            }
                        },
                        'claude-opus-5'
                    ),
                    envelope(
                        new Map<String, Object>{
                            'bindings' => new List<Object>{
                                binding('b1', AAO_BindCharter.INSUFFICIENT)
                            }
                        },
                        'claude-sonnet-5'
                    )
                }
            )
        );

        Test.startTest();
        AAO_EBV.State s = AAO_EBV.begin(
            f.sourceId,
            new Set<String>{ AAO_ApplicableSet.PEOPLE }
        );
        s = AAO_EBV.plan(AAO_EBV.stage1(s));
        s = AAO_EBV.planVerify(AAO_EBV.stage2Step(s));
        System.assert(s.verifyDone(), 'Nothing was established, so nothing needs verifying.');
        s = AAO_EBV.stage4(s, new Set<String>{ 'altify.com' });
        Test.stopTest();

        System.assertEquals(
            16,
            [SELECT COUNT() FROM AAO_Candidate__c WHERE AAO_Source__c = :f.sourceId],
            'One row per declared contract. The complete ledger is the point, and Apex ' +
            'writes the silence at zero model cost.'
        );
        Map<String, Integer> byReason = new Map<String, Integer>();
        for (AAO_Candidate__c cd : [
            SELECT AAO_Abstention_Reason__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :f.sourceId
        ]) {
            String r = cd.AAO_Abstention_Reason__c;
            byReason.put(r, (byReason.containsKey(r) ? byReason.get(r) : 0) + 1);
        }
        System.assertEquals(
            1,
            byReason.get('model_declined'),
            'insufficient is a judgment about evidence and reads as model_declined.'
        );
        System.assertEquals(
            15,
            byReason.get('nobody_said'),
            'The other fifteen are silence, and silence cost nothing to record.'
        );
    }

    @IsTest
    static void aStatementSeenAndThenLostIsModelMissedAndNotSilence() {
        Fixture f = fixture();
        AAO_Extract.overrideConfig = testConfig();
        Test.setMock(
            HttpCalloutMock.class,
            new Mock(
                new List<String>{
                    envelope(
                        new Map<String, Object>{
                            'items' => new List<Object>{
                                // Verbatim except for one word. The read saw a statement
                                // about S1 for this person and the pass cannot locate it.
                                item(
                                    'SPK_1',
                                    'p1',
                                    'The current tool is what my team complain about most.',
                                    new List<String>{ 'S1' }
                                )
                            }
                        },
                        'claude-opus-5'
                    )
                }
            )
        );

        Test.startTest();
        AAO_EBV.State s = AAO_EBV.begin(
            f.sourceId,
            new Set<String>{ AAO_ApplicableSet.PEOPLE }
        );
        s = AAO_EBV.plan(AAO_EBV.stage1(s));
        s = AAO_EBV.planVerify(s);
        s = AAO_EBV.stage4(s, new Set<String>{ 'altify.com' });
        Test.stopTest();

        List<AAO_Candidate__c> missed = [
            SELECT AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :f.sourceId AND AAO_Abstention_Reason__c = 'model_missed'
        ];
        System.assertEquals(
            1,
            missed.size(),
            'The read reported a statement bearing on this proposition and the pass lost ' +
            'it. Recording that as nobody_said would blame the transcript for the machine.'
        );
        System.assertEquals(
            'S1' + AAO_PeopleContracts.SEP + f.contactId,
            missed[0].AAO_Evidence_Contract__r.AAO_Proposition_Code__c
        );
        System.assertEquals(
            15,
            [
                SELECT COUNT()
                FROM AAO_Candidate__c
                WHERE
                    AAO_Source__c = :f.sourceId
                    AND AAO_Abstention_Reason__c = 'nobody_said'
            ],
            'One miss plus fifteen silences is the whole declared set. The ledger is ' +
            'complete or the abstention rate has no denominator.'
        );
    }

    // ============================================== the separation, enforced not requested

    @IsTest
    static void theVerifierMayNotBeTheSameModelAsTheBinder() {
        AAO_Extract.Config c = testConfig();
        c.verifyModel = c.bindModel;
        AAO_Extract.overrideConfig = c;

        Boolean threw = false;
        try {
            AAO_Extract.requireSeparateModels();
        } catch (AAO_Extract.ExtractException e) {
            threw = true;
            System.assert(
                e.getMessage().contains('same reader asked twice'),
                'The message has to say why, not just that it refused: ' + e.getMessage()
            );
        }
        System.assert(
            threw,
            'One model doing both stages makes the rejection count worthless, so it is a ' +
            'refusal before the callout and not a caveat on the report afterwards.'
        );
    }

    @IsTest
    static void anUnmeasuredGroupSizeIsARefusalAndNeverADefault() {
        Fixture f = fixture();
        AAO_Extract.Config c = testConfig();
        c.bindGroupSize = null;
        AAO_Extract.overrideConfig = c;

        AAO_EBV.State s = AAO_EBV.begin(
            f.sourceId,
            new Set<String>{ AAO_ApplicableSet.PEOPLE }
        );
        AAO_BindCharter.BindItem b = new AAO_BindCharter.BindItem();
        b.id = 'b1';
        b.contractCode = 'S1' + AAO_PeopleContracts.SEP + f.contactId;
        b.span = LINE_A;
        s.bindPlan.add(b);

        Boolean threw = false;
        try {
            AAO_EBV.stage2Step(s);
        } catch (AAO_EBV.EBVException e) {
            threw = true;
            System.assert(
                e.getMessage().contains('measured, never assumed'),
                'The refusal must name the ruling: ' + e.getMessage()
            );
        }
        System.assert(threw, 'Ruling 6. A constant in Apex would launder a guess.');
    }

    // ========================================================== the charters, as text

    @IsTest
    static void theBindCallCarriesNoTranscript() {
        List<AAO_BindCharter.BindItem> items = new List<AAO_BindCharter.BindItem>();
        AAO_BindCharter.BindItem b = new AAO_BindCharter.BindItem();
        b.id = 'b1';
        b.propositionText = 'This person has stated a business problem.';
        b.subjectDisplay = 'Ashley St. Clair';
        b.span = LINE_A;
        b.speaker = 'SPK_1';
        items.add(b);

        String content = AAO_BindCharter.content(items);
        System.assert(content.contains(LINE_A), 'The span is what it is asked about.');
        System.assert(
            !content.contains(LINE_B),
            'A second line of the transcript is a second line of the transcript. The ' +
            'blindness is the signature: there is no parameter one could arrive through.'
        );
        System.assert(
            !content.contains(LINE_DUP),
            'Nothing but this item may be in this item\'s prompt.'
        );
    }

    @IsTest
    static void theVerifyCallCarriesNeitherTheTranscriptNorTheBindersVerdict() {
        List<AAO_VerifyCharter.VerifyItem> items = new List<AAO_VerifyCharter.VerifyItem>();
        AAO_VerifyCharter.VerifyItem v = new AAO_VerifyCharter.VerifyItem();
        v.id = 'v1';
        v.claimText = 'This person has stated a business problem.';
        v.subjectDisplay = 'Ashley St. Clair';
        v.span = LINE_A;
        v.bindItemId = 'b1';
        items.add(v);

        String content = AAO_VerifyCharter.content(items);
        System.assert(content.contains(LINE_A));
        System.assert(!content.contains(LINE_B), 'No transcript.');
        System.assert(
            !content.containsIgnoreCase(AAO_BindCharter.ESTABLISHES),
            'The checker must never see what the binder concluded, or it is reviewing a ' +
            'conclusion instead of reading two pieces of text.'
        );
        System.assert(
            !content.contains('b1'),
            'Not even the binder\'s item id travels: it is the join key and nothing else.'
        );
    }

    @IsTest
    static void anAnswerToAnItemWeNeverSentIsDroppedRatherThanTrusted() {
        Map<String, AAO_BindCharter.Binding> parsed = AAO_BindCharter.parse(
            JSON.serialize(
                new Map<String, Object>{
                    'bindings' => new List<Object>{
                        binding('b1', AAO_BindCharter.ESTABLISHES),
                        binding('b99', AAO_BindCharter.ESTABLISHES)
                    }
                }
            ),
            new Set<String>{ 'b1' }
        );
        System.assertEquals(1, parsed.size());
        System.assert(
            !parsed.containsKey('b99'),
            'An answer about an item we did not send has no contract and no subject behind ' +
            'it. There is nowhere for it to go and guessing is the only alternative to a drop.'
        );
    }

    @IsTest
    static void anItemWithNoSpanOrNoFamilyIsNotAnItem() {
        List<AAO_InventoryCharter.Item> items = AAO_InventoryCharter.parse(
            JSON.serialize(
                new Map<String, Object>{
                    'items' => new List<Object>{
                        item('SPK_1', 'p1', LINE_A, new List<String>{ 'S1' }),
                        item('SPK_1', 'p1', '', new List<String>{ 'S1' }),
                        item('SPK_1', 'p1', LINE_B, new List<String>())
                    }
                }
            )
        );
        System.assertEquals(
            1,
            items.size(),
            'A span with no words carries nothing and a family list with no families names ' +
            'no question. Neither can produce a binding.'
        );
    }

    @IsTest
    static void theStateSurvivesBeingWrittenOutAndReadBack() {
        Fixture f = fixture();
        AAO_EBV.State s = AAO_EBV.begin(
            f.sourceId,
            new Set<String>{ AAO_ApplicableSet.PEOPLE }
        );
        AAO_InventoryCharter.Item it = new AAO_InventoryCharter.Item();
        it.id = 'i1';
        it.speaker = 'SPK_1';
        it.subject = 'p1';
        it.span = LINE_A;
        it.families = new List<String>{ 'S1' };
        s.inventory.add(it);
        s.handleToContact.put('p1', String.valueOf(f.contactId));
        s.stage = 'read';

        AAO_EBV.State back = AAO_EBV.fromJson(AAO_EBV.toJson(s));

        System.assertEquals(f.sourceId, back.sourceId);
        System.assertEquals('read', back.stage);
        System.assertEquals(1, back.inventory.size());
        System.assertEquals(LINE_A, back.inventory[0].span);
        System.assertEquals(
            String.valueOf(f.contactId),
            back.handleToContact.get('p1'),
            'The handle-to-person map has to survive the round trip or binding in the next ' +
            'transaction resolves every subject to nobody.'
        );
    }

    @IsTest
    static void theTemporaryInvokerWiresUpAndCarriesTheStateAcrossAnExecute() {
        Fixture f = fixture();
        AAO_Extract.overrideConfig = testConfig();
        Mock m = new Mock(
            new List<String>{
                envelope(
                    new Map<String, Object>{
                        'items' => new List<Object>{
                            item('SPK_1', 'p1', LINE_A, new List<String>{ 'S1' })
                        }
                    },
                    'claude-opus-5'
                )
            }
        );
        Test.setMock(HttpCalloutMock.class, m);

        AAO_EBV_TEMP_Batch b = new AAO_EBV_TEMP_Batch(
            f.sourceId,
            new Set<String>{ AAO_ApplicableSet.PEOPLE },
            new Set<String>{ 'altify.com' },
            1
        );

        Test.startTest();
        Database.executeBatch(b, 1);
        Test.stopTest();

        // ONE EXECUTE, AND THE ASSERTION IS ON THE CALLOUT, NOT ON `b.state`.
        //
        // The first version of this test asserted `b.state.stage == 'planned'` and failed with
        // 'new', which is correct behaviour and a wrong test: the framework serializes the
        // batch and runs its own instance, so the local reference never sees the pass advance.
        // The mock is not serialized, so what it received IS observable — and what it received
        // is the thing worth asserting anyway.
        //
        // WHAT THIS PROVES: start/execute/finish wire up, and one execute makes exactly one
        // callout, which is the property the ceiling law demands. **WHAT IT DOES NOT PROVE: that
        // a whole multi-stage pass completes in the org.** Apex refuses more than one
        // `executeBatch` per test method, so no test can drive six slots. That claim is
        // unverified from the calling runtime and is named as such in BUILD_JOURNAL rather than
        // implied by a green test.
        System.assertEquals(
            1,
            m.sent.size(),
            'One callout in one transaction. Two here would be two calls sharing one ' +
            '120-second budget, which is exactly what killed the last shape.'
        );
        System.assert(
            m.sent[0].contains('proposition families'),
            'The one call a first slot makes is the stage 1 read.'
        );
        System.assert(
            !m.sent[0].contains(AAO_PeopleContracts.SEP + f.contactId),
            'Not even through the invoker may a per-person code reach the read.'
        );
    }

    @IsTest
    static void theReportPrintsRatesWithTheirDenominators() {
        System.assertEquals(' (25.0%)', AAO_EBV.rate(1, 4));
        System.assertEquals(
            ' (no denominator: nothing was checked)',
            AAO_EBV.rate(0, 0),
            'A rate over nothing is not zero percent, it is not a rate.'
        );
    }
}