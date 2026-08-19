/**
 * The computed catalog, and the two guards this build put in front of it.
 *
 * The honest limit, stated so nobody reads a green suite as more than it is: unit tests make no
 * callouts, so they prove the arithmetic and the shapes and never that the plane fires on a real
 * pass. That proof is `review/process/COMPUTED-AND-DENIED.md`, run at the runtime on a targeted
 * fixture, which is the capability law as the 125th extended it - *"a mechanism is unverified
 * until tried from the runtime that will exercise it, and a unit test is not that runtime."*
 */
@IsTest
private class AAO_ProcessComputeTest {
    // ============================================================ the binding is configuration

    @IsTest
    static void thePredicateBindingComesFromConfigurationRatherThanFromApex() {
        // If this ever reads a hardcoded code, LAW #1 has been broken again in the same place:
        // a predicate is ours and a question code is the customer's.
        Map<String, String> b = AAO_ProcessCompute.predicateBindings();
        System.assertEquals(
            2, b.size(), 'Two predicates are seeded; the rest of the fifteen bind to none.'
        );
        System.assert(
            b.containsKey(AAO_ProcessCompute.P_DM_IDENTIFIED) &&
            b.containsKey(AAO_ProcessCompute.P_DM_ENGAGED),
            'Both Authority predicates bind: ' + b
        );
    }

    // ================================================================== the arithmetic

    @IsTest
    static void aDecisionMakerOnTheLedgerComputesBothFacts() {
        Fixture f = fixture();
        AAO_Participant__c p = participant(f, 'gwen', 'Gwen Arkwright', f.contactId);
        answer(f, 'AAO_BR_SIG', p.Id, f.contactId);

        AAO_ProcessCompute.Reading r = AAO_ProcessCompute.read(f.oppId);

        System.assertEquals(2, r.facts.size(), 'Identified and engaged, both: ' + r.notes);
        Set<String> predicates = new Set<String>();
        for (AAO_ProcessCompute.Fact fact : r.facts) {
            predicates.add(fact.predicate);
            System.assertEquals(
                1, fact.cites.size(), 'A computed fact names the row it rests on.'
            );
        }
        System.assert(
            predicates.contains(AAO_ProcessCompute.P_DM_IDENTIFIED) &&
            predicates.contains(AAO_ProcessCompute.P_DM_ENGAGED),
            'Both predicates: ' + predicates
        );
    }

    @IsTest
    static void aRoleBelowTheLineIsSILENCEANDNEVERADENIAL() {
        // An Evaluator is established and is not the person who makes the final call. The
        // computed plane says NOTHING - never-established is silence, and the by-stage marker
        // decides when silence becomes a flag. A computed plane that produced DENIED here would
        // be voicing a no nobody said, which only words can do.
        Fixture f = fixture();
        AAO_Participant__c p = participant(f, 'ivan', 'Ivan Petrov', f.contactId);
        answer(f, 'AAO_BR_EVAL', p.Id, f.contactId, 'ivan', null);

        AAO_ProcessCompute.Reading r = AAO_ProcessCompute.read(f.oppId);
        System.assertEquals(0, r.facts.size(), 'Below the line is silence: ' + r.notes);
    }

    @IsTest
    static void identifiedByAColleagueIsNotTHESAMEASENGAGED() {
        // THE DISCRIMINATION THAT MAKES A2 WORTH COMPUTING. A person named as decision maker by
        // somebody else's words has a Contact and no participant row, because they were never in
        // the room. A1 holds; A2 must not follow from it.
        Fixture f = fixture();
        // Somebody was on the call, so a Source and a participant row exist - just not for the
        // person the words NAME. That is the whole shape under test.
        participant(f, 'gwen', 'Gwen Arkwright', f.contactId);
        Contact absent = new Contact(
            FirstName = 'Rich', LastName = 'Absent', AccountId = f.acctId
        );
        insert absent;
        answer(f, 'AAO_BR_SIG', null, absent.Id);

        AAO_ProcessCompute.Reading r = AAO_ProcessCompute.read(f.oppId);
        System.assertEquals(1, r.facts.size(), 'Identified only: ' + r.notes);
        System.assertEquals(
            AAO_ProcessCompute.P_DM_IDENTIFIED,
            r.facts[0].predicate,
            'Being named is not being in the room.'
        );
    }

    @IsTest
    static void theCountsAreArithmeticAndCostNoCallout() {
        Fixture f = fixture();
        participant(f, 'gwen', 'Gwen Arkwright', f.contactId);
        AAO_Synthetic.MARK = true;
        insert new AAO_Criterion__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Subject__c = 'Annual total cost',
            AAO_Type__c = 'Formal',
            AAO_Required__c = true,
            AAO_Criterion_Key__c = f.oppId + '|annual total cost'
        );
        AAO_Synthetic.MARK = false;

        AAO_ProcessCompute.Reading r = AAO_ProcessCompute.read(f.oppId);
        System.assertEquals(1, r.counts.peopleOnDeal, 'One person on the deal.');
        System.assertEquals(1, r.counts.criteria, 'One standing criterion.');
        System.assertEquals(1, r.counts.criteriaFormal, 'Formal.');
        System.assertEquals(1, r.counts.criteriaRequired, 'Required.');
        System.assertEquals(0, Limits.getCallouts(), 'The computed plane spends no tokens.');
    }

    // ================================================================== the write

    @IsTest
    static void theWriteMakesAStateClaimThatNAMESITSROWS() {
        Fixture f = fixture();
        AAO_Participant__c p = participant(f, 'gwen', 'Gwen Arkwright', f.contactId);
        answer(f, 'AAO_BR_SIG', p.Id, f.contactId);

        AAO_ProcessCompute.Outcome o = AAO_ProcessCompute.run(f.oppId, 'test-compute');

        System.assertEquals(2, o.claimsWritten, 'Two claims: ' + o + ' ' + o.notes);
        System.assertEquals(2, o.citedRowsWritten, 'Each names the row it rests on.');
        for (AAO_Claim__c c : [
            SELECT AAO_Basis__c, AAO_Source__c, AAO_Spans__c,
                   (SELECT AAO_Cited_Type__c, AAO_Snapshot__c FROM AAO_Claim_Bases__r)
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :f.oppId AND AAO_Basis__c = 'State'
        ]) {
            // The evidence-family law, from the row's own side: state evidence is a record, not
            // an artifact, so a Source here would name a piece of evidence nothing was read from.
            System.assertEquals(null, c.AAO_Source__c, 'A state claim names no artifact.');
            System.assertEquals(null, c.AAO_Spans__c, 'A state claim has nothing to quote.');
            System.assertEquals(1, c.AAO_Claim_Bases__r.size(), 'Its rows are named.');
            System.assert(
                String.isNotBlank(c.AAO_Claim_Bases__r[0].AAO_Snapshot__c),
                'And frozen, or the citation rots the moment the row moves.'
            );
        }
    }

    @IsTest
    static void theSAMEOBSERVATIONTWICEWRITESONCE() {
        // A state claim has no spans, so nothing about the row itself would stop the same map
        // fact being re-asserted every pass. The citation is the read-before-write.
        Fixture f = fixture();
        AAO_Participant__c p = participant(f, 'gwen', 'Gwen Arkwright', f.contactId);
        answer(f, 'AAO_BR_SIG', p.Id, f.contactId);

        AAO_ProcessCompute.run(f.oppId, 'test-compute');
        AAO_ProcessCompute.Outcome second = AAO_ProcessCompute.run(f.oppId, 'test-compute');

        System.assertEquals(0, second.claimsWritten, 'Nothing written twice: ' + second);
        System.assertEquals(2, second.alreadyStanding, 'And it says why: ' + second);
    }

    @IsTest
    static void aRecordIsNotAnUtteranceSOITCORROBORATES() {
        // The reinforcement count is a number guidance orders by, and a ledger read of a fact
        // the words established is not a second time anybody said it.
        Fixture f = fixture();
        AAO_Participant__c p = participant(f, 'gwen', 'Gwen Arkwright', f.contactId);
        answer(f, 'AAO_BR_SIG', p.Id, f.contactId);
        // The evidence plane got there first, on words, AND ANSWERED THE WHOLE QUESTION. That
        // second half matters: a standing answer that is only partly covered is ADVANCED by the
        // computed claim, and advancing completeness is an establishment rather than a
        // repetition - the sixty-ninth stamp's three axes, in the priority order `AAO_Commit`
        // already applies. Corroboration is only reachable once there is nothing left to advance.
        answer(
            f, 'AAO_BANT_A1', p.Id, f.contactId, 'gwen',
            JSON.serialize(
                new Map<String, Object>{
                    'v' => 1,
                    'covered' => new List<String>{ 'e1', 'e2' },
                    'missing' => new List<String>()
                }
            )
        );

        AAO_ProcessCompute.run(f.oppId, 'test-compute');

        List<AAO_Claim__c> claims = [
            SELECT AAO_Outcome__c
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :f.oppId
              AND AAO_Basis__c = 'State'
              AND AAO_Evidence_Contract__r.AAO_Proposition_Code__c = 'AAO_BANT_A1'
        ];
        System.assertEquals(1, claims.size(), 'One computed claim on A1.');
        System.assertEquals(
            AAO_Accumulate.CORROBORATED,
            claims[0].AAO_Outcome__c,
            'Corroborated, never Reinforced: nobody said it twice.'
        );
    }

    // ================================================================== the mute guard

    @IsTest
    static void aDeclaredContractWithNoMEANINGSREFUSESLOUDLY() {
        // The 127th's ruling as the 128th corrected its key: keyed on FAMILY, never on code.
        // A contract whose family has no meaning vocabulary would have every pair against it
        // parsed away as silence, which reads downstream exactly like an honest nothing-said.
        AAO_Synthetic.MARK = true;
        AAO_Evidence_Contract__c mute = new AAO_Evidence_Contract__c(
            AAO_Proposition_Code__c = 'AAO_ZZ_MUTE',
            AAO_Proposition_Short__c = 'A family nothing can voice',
            AAO_Proposition_Text__c = 'Nothing here can be said.',
            AAO_Elements__c = JSON.serialize(
                new List<Object>{ new Map<String, Object>{ 'id' => 'e1', 'text' => 'x' } }
            ),
            AAO_Element_Count__c = 1,
            AAO_Family__c = 'Problems',
            AAO_Route__c = 'E',
            AAO_Rubric_Version__c = AAO_PassContracts.RUBRIC_VERSION,
            AAO_Content_Hash__c =
                '0000000000000000000000000000000000000000000000000000000000000099',
            AAO_Contract_Key__c =
                'AAO_ZZ_MUTE|0000000000000000000000000000000000000000000000000000000000000099'
        );
        AAO_Synthetic.MARK = false;

        Boolean threw = false;
        String message = '';
        try {
            AAO_LocateCharter.registerFamilies(
                new List<AAO_Evidence_Contract__c>{ mute }
            );
        } catch (AAO_LocateCharter.CharterException e) {
            threw = true;
            message = e.getMessage();
        }
        System.assert(threw, 'A mute contract is refused at declaration, before any callout.');
        System.assert(
            message.contains('AAO_ZZ_MUTE'),
            'And the refusal NAMES it, or the next person has to go looking: ' + message
        );
    }

    @IsTest
    static void aDeclaredSETTHATCANSPEAKPASSESTHEGUARD() {
        // The guard's negative control. Without this, the test above passes for a build whose
        // guard refuses everything, which is the green-suite hazard wearing a safety label.
        Fixture f = fixture();
        AAO_LocateCharter.registerFamilies(f.contracts.values());
        System.assert(true, 'A declared set with meanings declares without complaint.');
    }

    // ================================================================== fixture

    private class Fixture {
        Id oppId;
        Id acctId;
        Id contactId;
        Map<String, AAO_Evidence_Contract__c> contracts;
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Compute Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Compute Test Deal',
            AccountId = a.Id,
            StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        Contact c = new Contact(FirstName = 'Gwen', LastName = 'Arkwright', AccountId = a.Id);
        insert c;

        Fixture f = new Fixture();
        f.oppId = o.Id;
        f.acctId = a.Id;
        f.contactId = c.Id;
        f.contracts = new Map<String, AAO_Evidence_Contract__c>();
        AAO_PassContracts.mint();
        // The two Process contracts the bindings point at. Minting them from the vendor rubric
        // is `AAO_ProcessContracts`' job and its own test's; what this class needs is the row.
        List<AAO_Evidence_Contract__c> process = new List<AAO_Evidence_Contract__c>();
        Map<String, String> bindings = AAO_ProcessCompute.predicateBindings();
        Integer n = 1;
        for (String predicate : bindings.keySet()) {
            String code = bindings.get(predicate);
            process.add(
                new AAO_Evidence_Contract__c(
                    // The trigger composes the contract key from this, so a fixture that omits
                    // it is refused - which is the frozen-composer law catching a test that
                    // built a shape the product never produces.
                    AAO_Question_Record_Id__c = ('a0aTEST00000000' + n).left(18),
                    AAO_Proposition_Code__c = code,
                    AAO_Proposition_Short__c = code,
                    AAO_Proposition_Text__c = 'The question ' + code + ' asks.',
                    AAO_Elements__c = JSON.serialize(
                        new List<Object>{
                            new Map<String, Object>{ 'id' => 'e1', 'text' => 'first half' },
                            new Map<String, Object>{ 'id' => 'e2', 'text' => 'second half' }
                        }
                    ),
                    AAO_Element_Count__c = 2,
                    AAO_Family__c = AAO_ApplicableSet.PROCESS,
                    AAO_Charter_Designation__c = AAO_ApplicableSet.PROCESS,
                    AAO_Route__c = 'E',
                    AAO_Speaker_Requirement__c = 'Any_Participant',
                    AAO_Contract_State__c = 'Derived',
                    AAO_Decay_Class__c = 'Standing',
                    AAO_Elements_Basis__c = 'Authored',
                    AAO_Rubric_Version__c = AAO_PassContracts.RUBRIC_VERSION,
                    AAO_Content_Hash__c =
                        '000000000000000000000000000000000000000000000000000000000000000' + n
                )
            );
            n++;
        }
        insert process;
        for (AAO_Evidence_Contract__c ec : [
            SELECT Id, AAO_Proposition_Code__c, AAO_Family__c, AAO_Elements__c,
                   AAO_Element_Count__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Rubric_Version__c = :AAO_PassContracts.RUBRIC_VERSION
                AND AAO_Contract_State__c != 'Superseded'
        ]) {
            f.contracts.put(ec.AAO_Proposition_Code__c, ec);
        }
        AAO_Synthetic.MARK = false;
        return f;
    }

    /**
     * Participation is only ever written by `AAO_Participants.record` on Source insert, so this
     * builds the Source rather than hand-inserting the junction. A hand-built junction is a shape
     * the product never produces, which is the fixture mistake this build has already made twice.
     */
    private static AAO_Participant__c participant(
        Fixture f, String key, String display, Id contactId
    ) {
        AAO_Synthetic.MARK = true;
        insert new AAO_Source__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Origin__c = 'ingest',
            // 64 lowercase HEX, or the scope key refuses it - which is the frozen composer
            // catching a fixture that built a shape the product never produces.
            AAO_Artifact_SHA256__c =
                '0000000000000000000000000000000000000000000000000000000000000'
                    + String.valueOf(Math.abs(key.hashCode())).right(3),
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = key + '\tI sign off on this. It is my call.',
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 8, 19, 15, 0, 0),
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{
                    'v' => 1,
                    'speakers' => new List<Object>{
                        new Map<String, Object>{
                            'key' => key,
                            'display' => display,
                            'email' => key + '@proofco.example'
                        }
                    }
                }
            )
        );
        AAO_Synthetic.MARK = false;
        List<AAO_Participant__c> found = [
            SELECT Id, AAO_Contact__c, AAO_Display_Name__c
            FROM AAO_Participant__c
            WHERE AAO_Opportunity__c = :f.oppId AND AAO_Display_Name__c = :display
            LIMIT 1
        ];
        System.assertEquals(1, found.size(), 'The Source wrote its participant.');
        if (contactId != null && found[0].AAO_Contact__c != contactId) {
            AAO_Synthetic.MARK = true;
            update new AAO_Participant__c(Id = found[0].Id, AAO_Contact__c = contactId);
            AAO_Synthetic.MARK = false;
            found = [
                SELECT Id, AAO_Contact__c, AAO_Display_Name__c
                FROM AAO_Participant__c
                WHERE Id = :found[0].Id
            ];
        }
        return found[0];
    }

    private static Id sourceOn(Id oppId) {
        return [
            SELECT Id FROM AAO_Source__c WHERE AAO_Opportunity__c = :oppId
            ORDER BY CreatedDate ASC LIMIT 1
        ].Id;
    }

    /** A standing live establishment, the shape the join leaves behind. */
    private static AAO_Answer__c answer(
        Fixture f, String code, Id participantId, Id contactId
    ) {
        return answer(f, code, participantId, contactId, 'gwen', null);
    }

    private static AAO_Answer__c answer(
        Fixture f, String code, Id participantId, Id contactId, String speakerKey,
        String completeness
    ) {
        AAO_Evidence_Contract__c ec = f.contracts.get(code);
        System.assertNotEquals(null, ec, 'No contract for ' + code);
        AAO_Synthetic.MARK = true;
        AAO_Answer__c a = new AAO_Answer__c(
            AAO_Opportunity__c = f.oppId,
            AAO_Account__c = f.acctId,
            AAO_Evidence_Contract__c = ec.Id,
            AAO_Subject_Type__c = participantId == null ? 'Contact' : 'Participant',
            AAO_Subject_Contact__c = contactId,
            AAO_Participant__c = participantId,
            AAO_Verdict__c = 'TRUE',
            AAO_Established_By__c = 'MACHINE',
            AAO_Basis__c = 'Transcript',
            // A MACHINE ESTABLISHMENT WITH NO SPANS IS NOT AN ESTABLISHMENT - the org's own
            // validation, refusing an empty span list. The fixture carries a real one, because
            // the point of these tests is what the computed plane does BESIDE evidence that
            // stands, not what it does beside a shape the pass never writes.
            AAO_Spans__c = JSON.serialize(
                new Map<String, Object>{
                    'v' => 1,
                    'spans' => new List<Object>{
                        new Map<String, Object>{
                            'sourceId' => String.valueOf(sourceOn(f.oppId)),
                            'partIndex' => 1,
                            // The roster key is five characters plus a tab, so the quote starts
                            // at 5. The span verifier checks these bytes against the stored
                            // artifact, which is why they are arithmetic rather than a guess.
                            'startOffset' => 5,
                            'endOffset' => 39,
                            'quote' => 'I sign off on this. It is my call.',
                            'speaker' => speakerKey,
                            'element' => 'e1'
                        }
                    }
                }
            ),
            AAO_Element_Completeness__c = completeness,
            AAO_Publication_State__c = 'Live',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 8, 19, 15, 0, 0)
        );
        insert a;
        AAO_Synthetic.MARK = false;
        return a;
    }
}
