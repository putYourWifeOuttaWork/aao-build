/**
 * The applicable set is a PER-DEAL fact. The hundred-thirty-third's fix, and the two things worth
 * pinning are the ones a customer would be hurt by: that a deal's own plan type selects its
 * questions, and that a retirement is never silently undone by the next mint.
 */
@IsTest
private class AAO_ProcessContractsTest {
    /**
     * **THE PACKAGE'S OWN DEFAULT SEMANTICS: unmapped resolves to EVERY ACTIVE QUESTION, not to
     * none.** An org that has not configured a plan type is asking every question it authored,
     * and returning nothing there would be us inventing a restriction the package does not apply.
     */
    @IsTest
    static void anUNMAPPEDPLANTYPERESOLVESTOEVERYACTIVEQUESTION() {
        Fixture f = fixture();

        List<ALTF__Assessment_Question__c> all =
            AAO_ProcessContracts.discoverQuestions(f.oppId);

        System.assertEquals(
            2, all.size(),
            'Both active questions, because this deal names no plan type the org maps.'
        );
    }

    /** An inactive question is never applicable, whatever any plan type lists. */
    @IsTest
    static void anINACTIVEQUESTIONISNEVERAPPLICABLE() {
        Fixture f = fixture();
        AAO_Synthetic.MARK = true;
        insert new ALTF__Assessment_Question__c(
            Name = 'Retired question',
            ALTF__AltifyId__c = 'AAO_PCT_OFF',
            ALTF__Criterion_Text__c = 'Off',
            ALTF__Question__c = 'Is this asked?',
            ALTF__Long_Question__c = 'Is this asked?',
            ALTF__Active__c = false,
            ALTF__Order_Number__c = 3
        );
        AAO_Synthetic.MARK = false;

        System.assertEquals(
            2, AAO_ProcessContracts.discoverQuestions(f.oppId).size(),
            'Three exist and two are active.'
        );
    }

    /** No deal, no chain to walk, and null is read as "everything active" by the caller rather
     *  than as an error - graceful absence is the ruled shape at every rung of this chain. */
    @IsTest
    static void noDEALRESOLVESGRACEFULLY() {
        fixture();
        System.assertEquals(
            2, AAO_ProcessContracts.discoverQuestions(null).size(),
            'A missing deal cannot restrict, so nothing is restricted.'
        );
    }

    /**
     * **A RETIRED CONTRACT IS DECLINED, NEVER RE-MINTED.** Read-before-write asks for LIVE
     * contracts, so a retired one is invisible to it - and without the guard the next mint would
     * create a fresh contract for the same question and silently undo a deliberate retirement.
     * The hundred-twenty-ninth retired twelve contracts as an experiment's output; this fix is
     * what made those questions reachable again, so the two rulings would have collided on the
     * first run of the fixed path.
     */
    @IsTest
    static void aRETIREDCONTRACTISDECLINEDNEVERREMINTED() {
        Fixture f = fixture();
        AAO_ProcessContracts.Result first = AAO_ProcessContracts.mint(f.oppId);
        System.assertEquals(2, first.minted, 'Both mint on first encounter: ' + first);

        // Retire one through the lawful path, exactly as the hundred-twenty-ninth did.
        AAO_Evidence_Contract__c ec = [
            SELECT Id FROM AAO_Evidence_Contract__c
            WHERE AAO_Proposition_Code__c = 'AAO_PCT_ONE' LIMIT 1
        ];
        AAO_Synthetic.MARK = true;
        update new AAO_Evidence_Contract__c(
            Id = ec.Id,
            AAO_Contract_State__c = AAO_ContractState.RETIRED,
            AAO_Retired_Because__c = 'An experiment\'s output, never live in a pass.'
        );
        AAO_Synthetic.MARK = false;

        AAO_ProcessContracts.Result second = AAO_ProcessContracts.mint(f.oppId);

        System.assertEquals(0, second.minted, 'Nothing is minted: ' + second);
        System.assertEquals(1, second.retired, 'One question declined as retired: ' + second);
        System.assertEquals(1, second.reused, 'And the live one is reused: ' + second);
        System.assertEquals(
            1,
            [
                SELECT COUNT() FROM AAO_Evidence_Contract__c
                WHERE AAO_Proposition_Code__c = 'AAO_PCT_ONE'
            ],
            'And the retired question still has exactly ONE contract, the retired one.'
        );
    }

    /** Minting twice with nothing changed writes nothing. Idempotent by content hash, which is
     *  the same mechanism the reconciler uses. */
    @IsTest
    static void mintingTWICEWRITESONCE() {
        Fixture f = fixture();
        AAO_ProcessContracts.mint(f.oppId);
        AAO_ProcessContracts.Result again = AAO_ProcessContracts.mint(f.oppId);
        System.assertEquals(0, again.minted, 'Nothing new: ' + again);
        System.assertEquals(2, again.reused, 'Both reused: ' + again);
    }

    // ========================================================================= fixture

    private class Fixture {
        Id oppId;
    }

    private static Fixture fixture() {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO PCT');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO PCT Deal', AccountId = a.Id,
            StageName = 'Stage 1', CloseDate = Date.today().addDays(30)
        );
        insert o;
        insert new List<ALTF__Assessment_Question__c>{
            new ALTF__Assessment_Question__c(
                Name = 'PCT one',
                ALTF__AltifyId__c = 'AAO_PCT_ONE',
                ALTF__Criterion_Text__c = 'The first thing',
                ALTF__Question__c = 'Is the first thing true?',
                ALTF__Long_Question__c = 'Is the first thing true?',
                ALTF__Help__c = 'Elements:\n- e1: the first thing is true',
                ALTF__Active__c = true,
                ALTF__Order_Number__c = 1
            ),
            new ALTF__Assessment_Question__c(
                Name = 'PCT two',
                ALTF__AltifyId__c = 'AAO_PCT_TWO',
                ALTF__Criterion_Text__c = 'The second thing',
                ALTF__Question__c = 'Is the second thing true?',
                ALTF__Long_Question__c = 'Is the second thing true?',
                ALTF__Help__c = 'Elements:\n- e1: the second thing is true',
                ALTF__Active__c = true,
                ALTF__Order_Number__c = 2
            )
        };
        AAO_Synthetic.MARK = false;
        Fixture f = new Fixture();
        f.oppId = o.Id;
        return f;
    }
}
