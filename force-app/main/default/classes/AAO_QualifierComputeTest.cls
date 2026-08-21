@IsTest
private class AAO_QualifierComputeTest {

    /**
     * THE EMPTY-UNIVERSE PIN, one case per predicate. The 171st's law: a Yes produced by an
     * empty universe is not a Yes, and vacuous truth resolves to UNANSWERED rather than to
     * satisfied. The four universally-quantified predicates must go silent on a deal that has
     * named nobody; the existential one must fail honestly; and CHAIN is the one that would
     * hurt, because it is mandatory at Propose and a false Yes there passes a political gate
     * on the deal carrying the least evidence.
     */
    @IsTest
    static void aNEMPTYUNIVERSENEVERPRODUCESAYES() {
        Id oppId = bareDeal();

        Test.startTest();
        Map<String, AAO_QualifierCompute.Verdict> v = AAO_QualifierCompute.evaluate(oppId);
        Test.stopTest();

        for (String universal : new List<String>{
            AAO_QualifierCompute.SPEAKERS_MAPPED_WITH_ROLE,
            AAO_QualifierCompute.KEY_PLAYERS_SUPPORTIVE,
            AAO_QualifierCompute.APPROVERS_ON_MAP,
            AAO_QualifierCompute.DECISION_MAKER_HAS_INSIGHT
        }) {
            System.assertEquals(
                false,
                v.containsKey(universal),
                universal + ' quantifies over an empty set on this deal and must go UNANSWERED. ' +
                'A Yes here is the system\'s most confident answer on the deal carrying the ' +
                'least evidence, which is the opposite of what this product claims to do.'
            );
        }
    }

    @IsTest
    static void anEXISTENTIALFAILSHONESTLYRATHERTHANGOINGSILENT() {
        // PEOPLE1 reads "at least one external participant is identified on the relationship
        // map". An empty map is a real No, not an unanswered - the difference between a
        // question with an empty universe and a question with a negative answer.
        Id oppId = bareDeal();

        Test.startTest();
        Map<String, AAO_QualifierCompute.Verdict> v = AAO_QualifierCompute.evaluate(oppId);
        Test.stopTest();

        System.assertEquals('No', v.get(AAO_QualifierCompute.EXTERNAL_ON_MAP).status);
    }

    @IsTest
    static void aDEALWITHNOCRITERIAFAILSTHEFIRSTCLAUSE() {
        // The question is a CONJUNCTION: "Decision criteria are recorded AND no required
        // criterion is still open." Zero criteria fails the first clause, and must never
        // compute Yes off an empty second one.
        Id oppId = bareDeal();

        Test.startTest();
        Map<String, AAO_QualifierCompute.Verdict> v = AAO_QualifierCompute.evaluate(oppId);
        Test.stopTest();

        AAO_QualifierCompute.Verdict c = v.get(AAO_QualifierCompute.REQUIRED_CRITERIA_CLOSED);
        System.assertEquals('No', c.status, 'Zero criteria recorded is a No, never a Yes.');
        System.assert(c.because.contains('No decision criteria are recorded'), c.because);
    }

    @IsTest
    static void aVERDICTALWAYSCARRIESTHEROWSTHATMADEIT() {
        // A computed answer's provenance is ROWS, not a quote, because nobody said it - so a
        // verdict with no state citation is the same failure a Yes with no words would be.
        Id oppId = bareDeal();

        Test.startTest();
        Map<String, AAO_QualifierCompute.Verdict> v = AAO_QualifierCompute.evaluate(oppId);
        Test.stopTest();

        for (String k : v.keySet()) {
            System.assert(
                String.isNotBlank(v.get(k).because),
                k + ' answered with no state citation behind it.'
            );
        }
    }

    @IsTest
    static void CRITERIARECORDEDWITHNONEREQUIREDISANABSENCENOTAFINDING() {
        // RULED FROM THE EXTRACTOR at the 172nd's item 5, not from taste. AAO_PairCommit sets
        // AAO_Required__c = true ONLY where the AAO_DC_R proposition is upheld on evidence;
        // nothing ever writes false and nothing sweeps the rest. So zero-required means we have
        // not yet learned which criteria are hard - a different thing from learning that none
        // of them is - and the honest verdict is UNANSWERED rather than a satisfied Yes.
        Id oppId = bareDeal();
        Account a = [SELECT Id FROM Account WHERE Name = 'AAO Compute Test' LIMIT 1];
        AAO_Synthetic.MARK = true;
        insert new AAO_Criterion__c(
            AAO_Opportunity__c = oppId,
            AAO_Account__c = a.Id,
            AAO_Subject__c = 'Reads existing Salesforce data',
            // The org's own law: a criterion carries its key or it does not exist.
            AAO_Criterion_Key__c = 'AAO|CRIT|TEST|reads-existing-salesforce-data',
            AAO_Type__c = 'Informal',
            AAO_Synthetic__c = true
        );
        AAO_Synthetic.MARK = false;

        Test.startTest();
        Map<String, AAO_QualifierCompute.Verdict> v = AAO_QualifierCompute.evaluate(oppId);
        Test.stopTest();

        System.assertEquals(
            false,
            v.containsKey(AAO_QualifierCompute.REQUIRED_CRITERIA_CLOSED),
            'A criterion is recorded, so the first conjunct holds - but none has been ' +
            'established as required, so the second quantifies over an empty set. UNANSWERED, ' +
            'never a Yes.'
        );
    }

    private static Id bareDeal() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Compute Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Compute Deal', AccountId = a.Id,
            StageName = 'Stage 1', CloseDate = Date.today().addDays(30)
        );
        insert o;
        AAO_Synthetic.MARK = false;
        return o.Id;
    }
}
