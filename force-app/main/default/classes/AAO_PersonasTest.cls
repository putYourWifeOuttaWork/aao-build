/**
 * Persona ghosts. The behaviours worth pinning are the ones that decide whether a ghost is
 * signal or noise: that a title resolves to exactly one persona or to none, that a seller fills
 * nothing, that a blank expectation never ghosts, and that a ghost disappears the moment somebody
 * fills it rather than needing to be retired.
 */
@IsTest
private class AAO_PersonasTest {
    // ================================================================== the vocabulary

    @IsTest
    static void theVOCABULARYISTHEVENDORSANDTHEGRAMMARISOURS() {
        Map<String, AAO_Personas.Expectation> byPersona = AAO_Personas.expectations();
        System.assertEquals(
            12, byPersona.size(),
            'The twelve stored values this org configured on the vendor persona field.'
        );
        System.assert(
            byPersona.containsKey('Altify Program Owner'),
            'Keyed to the STORED value, label hazard and all: ' + byPersona.keySet()
        );
        // **TEN BLANK, TWO SEEDED, and the two are Matthew's own.** This test used to assert all
        // twelve blank, which was true and became wrong at the hundred-thirty-sixth: he
        // authorized a DEMO SEED of Executive Sponsor and Procurement Lead so the Brightwell arc
        // has a ghost to show. The property worth keeping is unchanged and is what is asserted
        // now: **the seed states no methodology nobody gave it.** Ten rows still say nothing,
        // and the two that speak were spoken for.
        Set<String> seeded = new Set<String>{ 'Executive Sponsor', 'Procurement Lead' };
        Integer blank = 0;
        for (AAO_Personas.Expectation e : byPersona.values()) {
            if (seeded.contains(e.persona)) {
                System.assertNotEquals(
                    null, e.expectedFromStage,
                    e.persona + ' carries the demo seed Matthew authorized at the 136th.'
                );
                continue;
            }
            System.assertEquals(
                null, e.expectedFromStage,
                'Which personas a stage expects is a methodology statement and nothing states ' +
                'one for ' + e.persona + '. It must stay blank.'
            );
            blank++;
        }
        System.assertEquals(10, blank, 'Ten rows still say nothing, which is the honest default.');
    }

    // ======================================================================= the match

    @IsTest
    static void aTITLERESOLVESTOEXACTLYONEPERSONA() {
        Map<String, AAO_Personas.Expectation> byPersona = AAO_Personas.expectations();
        System.assertEquals(
            'RevOps Leader',
            AAO_Personas.matchTitle('Director, Revenue Operations', byPersona).persona,
            'A real title off a real deal, matched deterministically and never by a model.'
        );
        System.assertEquals(
            'Sales Leader',
            AAO_Personas.matchTitle('VP Sales', byPersona).persona
        );
    }

    @IsTest
    static void aTITLEMATCHINGNOTHINGISJUSTAPERSON() {
        AAO_Personas.Match m = AAO_Personas.matchTitle(
            'Chief Operating Officer', AAO_Personas.expectations()
        );
        System.assertEquals(null, m.persona, 'No persona in this vocabulary covers a COO.');
        System.assertEquals(false, m.ambiguous, 'And that is not ambiguity, it is absence.');
    }

    /** Exactly one links; more than one holds. The identity ladder's own discipline. */
    @IsTest
    static void aTITLEMATCHINGTWOPERSONASMATCHESNONE() {
        AAO_Personas.Match m = AAO_Personas.matchTitle(
            'General Counsel and Head of Procurement', AAO_Personas.expectations()
        );
        System.assertEquals(true, m.ambiguous, 'Two personas answer to this title.');
        System.assertEquals(null, m.persona, 'So it links to neither, rather than being picked.');
        System.assertEquals(2, m.candidates.size(), 'Both are named: ' + m.candidates);
    }

    // ======================================================================= the ghosts

    @IsTest
    static void aBLANKEXPECTATIONNEVERGHOSTS() {
        // **BLANK IS NEVER READ AS STAGE ZERO**, the same null semantics the by-stage marker
        // carries. Asserted against the BLANK rows specifically rather than against the whole
        // sheet: the sheet used to be entirely blank and is not since the 136th's demo seed, and
        // a test that depended on that would keep breaking every time a row is graded. The
        // property is about a blank row, so it is asked of blank rows.
        Fixture f = fixture('Stage 4', 'Director, Revenue Operations', false);
        AAO_Personas.Reading r = AAO_Personas.ghostsOn(f.oppId);

        Set<String> ghosted = new Set<String>();
        for (AAO_Personas.Ghost g : r.ghosts) {
            ghosted.add(g.persona);
        }
        for (AAO_Personas.Expectation e : AAO_Personas.expectations().values()) {
            if (e.expectedFromStage == null) {
                System.assert(
                    !ghosted.contains(e.persona),
                    e.persona + ' states no stage and must never ghost, even at the last open ' +
                    'one. Got: ' + ghosted
                );
            }
        }
    }

    @IsTest
    static void aPERSONAEXPECTEDANDUNFILLEDSTANDSASAGHOST() {
        AAO_Personas.stubbed = new List<AAO_Persona_Expectation__mdt>{
            expectation('Executive Sponsor', 2, 'executive sponsor')
        };
        Fixture f = fixture('Stage 3', 'Director, Revenue Operations', false);

        AAO_Personas.Reading r = AAO_Personas.ghostsOn(f.oppId);

        System.assertEquals(1, r.ghosts.size(), 'One expected, nobody fills it: ' + r.notes);
        System.assertEquals('Executive Sponsor', r.ghosts[0].persona);
        System.assert(
            r.ghosts[0].because.contains('expected from stage 2'),
            'And it says why: ' + r.ghosts[0].because
        );
    }

    @IsTest
    static void aGHOSTISGONEWHENSOMEBODYFILLSIT() {
        // ELIMINATION, and there is nothing to eliminate: the ghost was never a row.
        AAO_Personas.stubbed = new List<AAO_Persona_Expectation__mdt>{
            expectation('RevOps Leader', 2, 'revenue operations,revops')
        };
        Fixture f = fixture('Stage 3', 'Director, Revenue Operations', false);

        AAO_Personas.Reading r = AAO_Personas.ghostsOn(f.oppId);

        System.assertEquals(0, r.ghosts.size(), 'Filled, so no ghost stands.');
        System.assertEquals(1, r.matched.size(), 'And the person who fills it is named.');
        System.assertEquals('RevOps Leader', r.matched[0].persona);
    }

    @IsTest
    static void aGHOSTSTANDSLONGBEFOREITSDUESTAGEANDCARRIESIT() {
        // REVERSED BY RULING at the hundred-seventieth, and the reversal is the point rather
        // than an adjustment. This asserted that a ghost is quiet until its stage expects it -
        // correct for a FLAG. Matthew's reasoning redefined what a ghost IS: a persona required
        // at stage 4 is a relationship that must START now, because influence cannot be
        // manufactured on the due date. The cast is a set of LEAD-TIME NODES and it stands from
        // call one, carrying no accusation. The by-stage plane still governs flags and only
        // flags, which is why nothing about red-flagging changed with it.
        AAO_Personas.stubbed = new List<AAO_Persona_Expectation__mdt>{
            expectation('Executive Sponsor', 4, 'executive sponsor')
        };
        Fixture f = fixture('Stage 2', 'Director, Revenue Operations', false);

        AAO_Personas.Reading r = AAO_Personas.ghostsOn(f.oppId);

        System.assertEquals(1, r.ghosts.size(),
            'A persona due at 4 stands at 2, because threading takes months and the due date ' +
            'is when it must already be done.');
        System.assertEquals(4, r.ghosts[0].expectedFromStage.setScale(0),
            'And it carries WHEN it is due, so the map can order the cast as a path rather ' +
            'than a pile.');
    }

    /**
     * **A SELLER FILLS NOTHING.** Our own account executive is not the customer's Sales Leader,
     * and without this our side of the call would quietly satisfy the buying committee.
     */
    @IsTest
    static void aSELLERFILLSNOTHING() {
        AAO_Personas.stubbed = new List<AAO_Persona_Expectation__mdt>{
            expectation('Sales Leader', 2, 'vp sales,head of sales')
        };
        Fixture f = fixture('Stage 3', 'VP Sales', true);

        AAO_Personas.Reading r = AAO_Personas.ghostsOn(f.oppId);

        System.assertEquals(
            1, r.ghosts.size(),
            'The only person with the title is on the selling side, so the seat is still empty.'
        );
        System.assertEquals(0, r.matched.size(), 'And a seller matches nothing at all.');
    }

    @IsTest
    static void anUNORDERABLESTAGECASTSNOGHOSTANDSAYSWHY() {
        AAO_Personas.stubbed = new List<AAO_Persona_Expectation__mdt>{
            expectation('Executive Sponsor', 2, 'executive sponsor')
        };
        Fixture f = fixture('Qualify', 'Director, Revenue Operations', false);

        AAO_Personas.Reading r = AAO_Personas.ghostsOn(f.oppId);

        // The ordinal is still unorderable and still reported as such - that half was always
        // right and is untouched. What changed is the consequence: a deal that cannot be
        // ordered is exactly a deal nobody has worked yet, and it needs its cast MORE than a
        // late-stage one, not less. Nothing here is compared against the ordinal any more,
        // because a ghost is not a flag.
        System.assertEquals(null, r.stageOrdinal, 'An inactive stage has no place in the order.');
        System.assertEquals(1, r.ghosts.size(),
            'The cast stands anyway. An unorderable deal is a deal at its beginning, which is ' +
            'when a lead-time node is worth the most.');
    }

    @IsTest
    static void anORGTHATSTATESNOEXPECTATIONSGETSGRACEFULABSENCE() {
        AAO_Personas.stubbed = new List<AAO_Persona_Expectation__mdt>();
        Fixture f = fixture('Stage 4', 'Director, Revenue Operations', false);
        AAO_Personas.Reading r = AAO_Personas.ghostsOn(f.oppId);
        System.assertEquals(0, r.ghosts.size());
        System.assert(
            r.notes[0].contains('Graceful absence'),
            'Absence of configuration is not a defect: ' + r.notes
        );
    }


    /**
     * **THE REGRESSION SPECIMEN, and it is a defect running found and reading never would.**
     *
     * `contains` matched `cto` inside `dire`cto`r`, so the first real title off a real deal came
     * back ambiguous between RevOps Leader and IT Leader and therefore matched NOTHING - which
     * would have left a persona nobody can ever fill, casting a ghost that can never be
     * eliminated. Every short abbreviation in this vocabulary has the same shape.
     */
    @IsTest
    static void aSHORTABBREVIATIONDOESNOTMATCHINSIDEALONGERWORD() {
        Map<String, AAO_Personas.Expectation> byPersona = AAO_Personas.expectations();

        AAO_Personas.Match m = AAO_Personas.matchTitle('Director, Revenue Operations', byPersona);
        System.assertEquals(
            'RevOps Leader', m.persona,
            'cto lives inside director and must not match there: ' + m.candidates
        );

        System.assertEquals(
            'IT Leader',
            AAO_Personas.matchTitle('CTO', byPersona).persona,
            'And the abbreviation still matches when it IS the word.'
        );
        System.assertEquals(
            'IT Leader',
            AAO_Personas.matchTitle('Group CTO, Platform', byPersona).persona,
            'Including inside a longer title, on its own boundaries.'
        );
        System.assertEquals(
            null,
            AAO_Personas.matchTitle('Managing Director', byPersona).persona,
            'And an ordinary title with no persona in it still resolves to none.'
        );
    }

    // ========================================================================= fixture

    private class Fixture {
        Id oppId;
    }

    private static AAO_Persona_Expectation__mdt expectation(
        String persona, Integer fromStage, String patterns
    ) {
        return new AAO_Persona_Expectation__mdt(
            AAO_Persona__c = persona,
            AAO_Expected_From_Stage__c = fromStage,
            AAO_Title_Patterns__c = patterns
        );
    }

    /**
     * One deal at a named stage with one external or internal person carrying a title.
     * Participation is written by the Source trigger rather than by hand, because a hand-built
     * junction is a shape the product never produces.
     */
    private static Fixture fixture(String stageName, String title, Boolean internal) {
        AAO_Ingest.AUTO = false;
        AAO_Synthetic.MARK = true;
        Account a = new Account(Name = 'AAO Personas Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Personas Deal',
            AccountId = a.Id,
            StageName = stageName,
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        String domain = internal ? 'altify.com' : 'proofco.example';
        Contact c = new Contact(
            FirstName = 'Dana', LastName = 'Okafor', AccountId = a.Id,
            Title = title, Email = 'dana@' + domain
        );
        insert c;
        insert new AAO_Source__c(
            AAO_Opportunity__c = o.Id,
            AAO_Account__c = a.Id,
            AAO_Origin__c = 'ingest',
            AAO_Artifact_SHA256__c =
                '0000000000000000000000000000000000000000000000000000000000000077',
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Normalized_Text__c = 'dana\tWe should talk about the rollout.',
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 8, 19, 15, 0, 0),
            AAO_Speaker_Roster__c = JSON.serialize(
                new Map<String, Object>{
                    'v' => 1,
                    'speakers' => new List<Object>{
                        new Map<String, Object>{
                            'key' => 'dana',
                            'display' => 'Dana Okafor',
                            'email' => 'dana@' + domain
                        }
                    }
                }
            )
        );
        List<AAO_Participant__c> found = [
            SELECT Id, AAO_Contact__c FROM AAO_Participant__c WHERE AAO_Opportunity__c = :o.Id
        ];
        System.assertEquals(1, found.size(), 'The Source wrote its participant.');
        if (found[0].AAO_Contact__c == null) {
            update new AAO_Participant__c(Id = found[0].Id, AAO_Contact__c = c.Id);
        }
        AAO_Synthetic.MARK = false;

        Fixture f = new Fixture();
        f.oppId = o.Id;
        return f;
    }
}
