/**
 * The Run Inspector's laws.
 *
 * What is asserted here is what a screenshot cannot show: that it reads and never writes, that the
 * refusals reach the surface as their own collection rather than being filtered out of a list of
 * successes, that a walk-back carries the offsets that make its quote checkable, and, as of the
 * sixty-sixth stamp, that the surface reads out in WORDS and draws the pipeline's real ORDER.
 *
 * The v2 rulings are asserted rather than eyeballed for the same reason the refusal wording is: a
 * later session can drop a title back to a contract code, or quietly stop rendering the steps that
 * did not happen, and every count on the page would still add up while the surface stopped being
 * legible to the person it was built for.
 */
@IsTest
private class AAO_RunInspectorTest {
    @IsTest
    static void itIsReadOnlyByConstruction() {
        // AN INSPECTOR THAT COULD CHANGE WHAT IT INSPECTS IS NOT AN INSPECTOR. Asserted against
        // the class body rather than by convention, so a later session cannot quietly add a write
        // path and leave the name promising otherwise.
        ApexClass body = [
            SELECT Body FROM ApexClass WHERE Name = 'AAO_RunInspector' LIMIT 1
        ];
        for (String write : new List<String>{
            'insert ', 'update ', 'upsert ', 'delete ', 'Database.'
        }) {
            System.assert(
                !body.Body.contains(write),
                'The inspector must hold no write path. Found: ' + write
            );
        }
    }

    @IsTest
    static void anEmptyDealAnswersWithoutThrowing() {
        Opportunity o = deal('AAO Inspector Test');

        Test.startTest();
        List<AAO_RunInspector.RunOption> runs = AAO_RunInspector.runsFor(o.Id);
        AAO_RunInspector.RunView v = AAO_RunInspector.inspect(o.Id, null);
        Test.stopTest();

        System.assertEquals(0, runs.size(), 'No runs, and that is an answer rather than an error.');
        System.assertEquals(
            'No run selected.', v.note, 'It says why it is empty instead of rendering blank.'
        );
        System.assert(v.upheld.isEmpty() && v.refused.isEmpty());
        System.assert(
            !v.pipeline.isEmpty(),
            'The order is drawn even with nothing in it, so an empty run still reads as a pipeline.'
        );
    }

    @IsTest
    static void theStageVocabularyNAMESTHEREFUSALSANDSAYSWHYTHEYMATTER() {
        // The refusals are a first-class stage with a first-class meaning, because a surface that
        // shows only what stood tells a reviewer what the machine believes and not whether to
        // believe it. If a later session drops this stage the counts still add up and the
        // surface quietly stops earning trust, so the wording is asserted.
        //
        // THE SIXTY-SIXTH STAMP DEFAULTED THE REFUSED ROWS TO HIDDEN AND DID NOT WEAKEN THIS:
        // the meaning line now has to survive on the STEPPER too, which is the surface a reader
        // sees before they ever expand anything.
        Opportunity o = deal('AAO Inspector Vocab');

        AAO_RunInspector.RunView v = AAO_RunInspector.inspect(o.Id, 'no-such-run');
        Map<String, String> meaningByStage = new Map<String, String>();
        for (AAO_RunInspector.StageCount s : v.stages) {
            meaningByStage.put(s.stage, s.meaning);
        }
        System.assert(
            meaningByStage.containsKey('Refused'),
            'Refused is a stage the surface shows, never a filtered-out remainder.'
        );
        System.assert(
            meaningByStage.get('Refused').contains('trust is earned'),
            'And it says why it is there. Got: ' + meaningByStage.get('Refused')
        );
        System.assert(meaningByStage.containsKey('Located'));
        System.assert(meaningByStage.containsKey('Upheld'));

        Map<String, String> meaningByStep = new Map<String, String>();
        for (AAO_RunInspector.Step s : v.pipeline) {
            meaningByStep.put(s.label, s.meaning);
        }
        System.assert(
            meaningByStep.get('Verified').contains('trust is earned'),
            'The drawn order carries the meaning line too. Got: ' + meaningByStep.get('Verified')
        );
    }

    @IsTest
    static void theOrderIsDrawnInThePipelinesRealSequence() {
        // The order IS the information. A stepper whose steps drift out of sequence teaches a
        // reader the wrong pipeline while every number on it stays correct.
        Opportunity o = deal('AAO Inspector Order');
        AAO_RunInspector.RunView v = AAO_RunInspector.inspect(o.Id, 'no-such-run');

        List<String> labels = new List<String>();
        for (AAO_RunInspector.Step s : v.pipeline) {
            labels.add(s.label);
        }
        System.assertEquals(
            new List<String>{
                'Source read', 'Words located', 'People identified', 'Verified',
                'Claims written', 'Answers ledgered', 'Projected'
            },
            labels,
            'The stepper is the pipeline in the order it runs.'
        );
    }

    @IsTest
    static void aRowTitleCarriesWORDSANDNEVERACONTRACTCODE() {
        // Matthew's ruling: FAMILY PLUS ESTABLISHED VALUE, and it reads the way the map reads.
        // A code on a title is what v1 shipped and what he named on sight.
        System.assertEquals(
            'Dan Lewis · Buyer Role: Evaluator',
            AAO_RunInspector.titleFor('Dan Lewis', 'AAO_BR_EVAL', 'Evaluator')
        );
        System.assertEquals(
            'Kayla Stanley · Political Status: Political Structure',
            AAO_RunInspector.titleFor('Kayla Stanley', 'AAO_POL_PS2', 'Political Structure')
        );
        // Problems name their own type, so a "Problems: " prefix would only repeat the word the
        // value already carries.
        System.assertEquals(
            'Adam Pfeiffer · Initiative',
            AAO_RunInspector.titleFor('Adam Pfeiffer', 'AAO_PB_INIT', 'Initiative')
        );
    }

    @IsTest
    static void aCONTRACTWITHNOVALUESHOWSITSCODEANDTHATISREPORTED() {
        // "Where a contract has no short name the code shows and that is a DEFECT TO REPORT, not
        // a silent fallback." A fallback that looks like a name is how a gap survives a review.
        System.assertEquals(
            'Somebody · AAO_XX_UNKNOWN',
            AAO_RunInspector.titleFor('Somebody', 'AAO_XX_UNKNOWN', null),
            'An unplaceable code shows as itself rather than as an invented name.'
        );
    }

    @IsTest
    static void rowsGROUPUNDERTHEPERSONTHEYAREABOUT() {
        Fixture f = fixture();

        Test.startTest();
        AAO_RunInspector.RunView v = AAO_RunInspector.inspect(f.opportunityId, f.runKey);
        Test.stopTest();

        Map<String, AAO_RunInspector.PersonGroup> byName =
            new Map<String, AAO_RunInspector.PersonGroup>();
        for (AAO_RunInspector.PersonGroup g : v.people) {
            byName.put(g.name, g);
        }
        System.assertEquals(2, v.people.size(), 'One group per person. Got: ' + byName.keySet());
        System.assertEquals('A Buyer', v.people[0].name, 'Externals lead; internals follow.');
        System.assertEquals(1, byName.get('A Buyer').upheldCount);
        System.assertEquals(1, byName.get('A Buyer').refusedCount);
        System.assertEquals(
            '1 established, 1 refused',
            byName.get('A Buyer').countLabel,
            'The group carries its count, which is what makes it collapsible without loss.'
        );
    }

    @IsTest
    static void theREFUSEDCOUNTSURVIVESTHEROWSBEINGCOLLAPSED() {
        // The sixty-third stamp's law, defaulted and not weakened: a surface that hides HOW MUCH
        // was declined stops earning trust, so the count reaches the page whether or not the
        // reader ever expands the rows.
        Fixture f = fixture();
        AAO_RunInspector.RunView v = AAO_RunInspector.inspect(f.opportunityId, f.runKey);

        System.assertEquals(1, v.refusedTotal, 'The run-level refused count is on the view.');
        for (AAO_RunInspector.PersonGroup g : v.people) {
            System.assertNotEquals(
                null, g.refusedLabel, 'Every group can name its refusals before showing them.'
            );
        }
        Boolean drawn = false;
        for (AAO_RunInspector.Step s : v.pipeline) {
            drawn = drawn || (s.label == 'Verified' && s.countLabel.contains('1 refused'));
        }
        System.assert(drawn, 'And the stepper carries it before anybody asks.');
    }

    @IsTest
    static void aREFUSEDROWNAMESTHEVALUEPROPOSEDANDDECLINED() {
        // "A refused row carries the family and the value that was PROPOSED and declined, so the
        // title still says what was at stake." A refused row titled with nothing but a person
        // would make the refusal unreadable, which is the opposite of why refusals are shown.
        Fixture f = fixture();
        AAO_RunInspector.RunView v = AAO_RunInspector.inspect(f.opportunityId, f.runKey);

        System.assertEquals(1, v.refused.size());
        System.assertEquals(
            'A Buyer · Political Status: Political Structure',
            v.refused[0].title,
            'The refusal says what was at stake, not merely that something was declined.'
        );
    }

    @IsTest
    static void everyESTABLISHMENTWALKSTHEWHOLEPATHANDDEADSTEPSKEEPTHEIRREASON() {
        // A path with its dead steps removed reads as a success that simply ended, which is a lie
        // about a refusal. Every trace walks all eight steps; the ones that did not happen carry
        // a reason instead of a detail.
        Fixture f = fixture();
        AAO_RunInspector.RunView v = AAO_RunInspector.inspect(f.opportunityId, f.runKey);

        AAO_RunInspector.Trace refusedTrace = v.refused[0];
        System.assertEquals(8, refusedTrace.path.size(), 'All eight hops, always.');

        Map<String, AAO_RunInspector.PathStep> byLabel =
            new Map<String, AAO_RunInspector.PathStep>();
        for (AAO_RunInspector.PathStep s : refusedTrace.path) {
            byLabel.put(s.label, s);
        }
        System.assert(byLabel.get('Found the words').happened, 'The words were located.');
        System.assert(byLabel.get('Identified the speaker').happened);
        System.assert(!byLabel.get('Wrote the claim').happened, 'A refusal writes no claim.');
        System.assert(
            byLabel.get('Wrote the claim').reason.contains('refused'),
            'And it SAYS why rather than going quiet. Got: ' + byLabel.get('Wrote the claim').reason
        );
        System.assertEquals(
            null,
            byLabel.get('Wrote the claim').detail,
            'A step that did not happen carries no detail to be mistaken for one that did.'
        );
        System.assert(!byLabel.get('Projected').happened);
    }

    @IsTest
    static void anINTERNALSPEAKERISMARKEDWITHTHEREASONNOTHINGFOLLOWED() {
        // The sixty-fifth stamp's owed item, CODE's own catch: Jennae appears on the upheld list
        // because the pipeline genuinely upheld her establishments and the card writer refuses
        // her correctly, so no card exists. Showing raw establishments is right; an UNMARKED
        // internal speaker misleads at a glance.
        Fixture f = fixture();
        AAO_RunInspector.RunView v = AAO_RunInspector.inspect(f.opportunityId, f.runKey);

        AAO_RunInspector.PersonGroup seller = v.people[v.people.size() - 1];
        System.assertEquals('A Seller', seller.name);
        System.assert(seller.internal, 'The group knows the speaker is ours.');
        System.assert(
            seller.internalReason.contains('no card or map row follows'),
            'And it says what did NOT follow, which is the thing a glance gets wrong. Got: ' +
            seller.internalReason
        );

        AAO_RunInspector.Trace t = seller.upheld[0];
        System.assert(t.personInternal, 'The marker reaches the row, not only the group.');
        AAO_RunInspector.PathStep projected = t.path[7];
        System.assertEquals('Projected', projected.label);
        System.assert(!projected.happened, 'An internal speaker projects nothing.');
        // THE WORDING IS NARROW ON PURPOSE. The first draft of this reason said the JOIN refuses
        // an internal speaker, and the rendered page then showed a Jennae establishment whose
        // claim and answer the join had plainly written: on the Problems family the refusal
        // happens at the card writer, downstream of both. The reason names the OUTCOME, which
        // is measured, and not the stage, which was inferred and wrong.
        System.assert(
            projected.reason.contains('no card or map row follows'),
            'And the path says so at the step where it stopped. Got: ' + projected.reason
        );
        System.assert(
            !projected.reason.contains('the join refuses'),
            'It never names a stage it did not measure. Got: ' + projected.reason
        );
    }

    @IsTest
    static void performanceSAYSPLAINLYTHATNOTHINGISJOURNALLED() {
        // The stamp asks for per-stage wall time and governors behind a toggle, "showing only
        // numbers the run actually journalled, nothing recomputed on the page". Nothing in the
        // ORG journals them, because the run receipt object confirmed at the twenty-ninth stamp
        // was never built. Saying so is the honest answer; deriving a timing from record
        // timestamps would be exactly the recomputation the stamp forbids.
        Opportunity o = deal('AAO Inspector Perf');
        AAO_RunInspector.RunView v = AAO_RunInspector.inspect(o.Id, 'no-such-run');

        System.assert(!v.performanceJournalled, 'It claims no numbers it does not have.');
        System.assert(
            v.performanceNote.contains('receipt'),
            'And it names what would carry them. Got: ' + v.performanceNote
        );
    }

    // ------------------------------------------------------------------------ the fixture

    private class Fixture {
        String runKey = 'inspectrun01';
        Id opportunityId;
    }

    private static Opportunity deal(String name) {
        Account a = new Account(Name = name);
        insert a;
        Opportunity o = new Opportunity(
            Name = name + ' Deal', AccountId = a.Id, StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        return o;
    }

    /**
     * One buyer with an upheld Buyer Role and a refused Political placement, and one of our own
     * sellers with an upheld establishment nothing followed from. That is the smallest shape
     * that exercises every v2 ruling at once: titles, grouping, the collapsed refusals, the
     * numbered path on both a survivor and a casualty, and the internal marking.
     */
    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Fixture f = new Fixture();
        Opportunity o = deal('AAO Inspector Fixture');
        f.opportunityId = o.Id;

        String text = 'buyer\tWe will evaluate it against the shortlist. ' +
            'They call on me when it has to happen. seller\tI can walk you through it.';
        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = o.Id, AAO_Account__c = o.AccountId, AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c =
                '00000000000000000000000000000000000000000000000000000000000000cc',
            AAO_Part_Index__c = 1, AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = text, AAO_Diarization__c = 'Attributed',
            AAO_Source_Ref__c = 'inspector/2026-08-12-fx',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 8, 12, 15, 0, 0),
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{
                    'speakers' => new List<Object>{
                        new Map<String, Object>{
                            'key' => 'buyer', 'display' => 'A Buyer',
                            'email' => 'buyer@example.com'
                        },
                        new Map<String, Object>{
                            'key' => 'seller', 'display' => 'A Seller',
                            'email' => 'seller@altify.com'
                        }
                    }
                }
            ),
            AAO_Synthetic__c = true
        );
        insert src;
        AAO_PassContracts.mint();

        Map<String, Id> participants = new Map<String, Id>();
        for (AAO_Participant__c p : [
            SELECT Id, AAO_Roster_Key__c FROM AAO_Participant__c WHERE AAO_Source__c = :src.Id
        ]) {
            participants.put(p.AAO_Roster_Key__c, p.Id);
        }

        pair(f, src.Id, participants.get('buyer'), 'AAO_BR_EVAL', 'br1',
            'We will evaluate it against the shortlist.', 'EVALUATOR', 'Upheld', null);
        pair(f, src.Id, participants.get('buyer'), 'AAO_POL_PS2', 'po1',
            'They call on me when it has to happen.', 'POLITICAL STRUCTURE', 'Refused',
            'The words describe the structure without placing authority in it.');
        pair(f, src.Id, participants.get('seller'), 'AAO_PB_INIT', 'pb1',
            'I can walk you through it.', 'INITIATIVE', 'Upheld', null);

        AAO_Synthetic.MARK = false;
        return f;
    }

    private static void pair(
        Fixture f, Id sourceId, Id personId, String code, String ref, String quote,
        String meaning, String verdict, String note
    ) {
        Id contract = [
            SELECT Id FROM AAO_Evidence_Contract__c
            WHERE AAO_Proposition_Code__c = :code AND AAO_Contract_State__c != 'Superseded'
            LIMIT 1
        ].Id;
        AAO_Source__c src = [
            SELECT AAO_Normalized_Text__c FROM AAO_Source__c WHERE Id = :sourceId
        ];
        Integer start = src.AAO_Normalized_Text__c.indexOf(quote);
        AAO_Pair__c located = new AAO_Pair__c(
            AAO_Run_Key__c = f.runKey, AAO_Pair_Ref__c = ref, AAO_Stage__c = 'Located',
            AAO_Charter__c = 'AAO_LocateCharter', AAO_Charter_Version__c = 'locate-3.0.0',
            AAO_Source__c = sourceId, AAO_Evidence_Contract__c = contract,
            AAO_Answer_Text__c = quote, AAO_Meaning__c = meaning,
            AAO_Start_Offset__c = start, AAO_End_Offset__c = start + quote.length(),
            AAO_Occurrence__c = 1, AAO_Occurrence_Count__c = 1,
            AAO_Pair_Key__c = AAO_PairKey.compose(f.runKey, ref, 'Located'),
            AAO_Synthetic__c = true
        );
        insert located;
        insert new AAO_Pair__c(
            AAO_Run_Key__c = f.runKey, AAO_Pair_Ref__c = ref, AAO_Stage__c = 'Identified',
            AAO_Charter__c = 'AAO_IdentifyCharter', AAO_Charter_Version__c = 'identify-1.0.0',
            AAO_Located_Pair__c = located.Id, AAO_Evidence_Contract__c = contract,
            AAO_Source__c = sourceId, AAO_Disposition__c = 'Identified',
            AAO_Identification_Basis__c = 'Deterministic: the words sit in their own turn.',
            AAO_Person__c = personId, AAO_Verification__c = verdict,
            AAO_Verification_Note__c = note,
            AAO_Pair_Key__c = AAO_PairKey.compose(f.runKey, ref, 'Identified'),
            AAO_Synthetic__c = true
        );
    }
}