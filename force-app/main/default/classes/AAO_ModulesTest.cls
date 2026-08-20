/**
 * The module facade. It answers TRUE for everything today, so what is worth asserting is the
 * shape that will matter when it does not: that an unknown module never resolves to a silent
 * true, that the rungs read as the ladder ruled them, and that assessment and sales process are
 * asked about separately.
 */
@IsTest
private class AAO_ModulesTest {
    @IsTest
    static void everyMODULEISPRESENTUNTILDETECTIONEXISTS() {
        Id opp = null;
        for (String m : new List<String>{
            AAO_Modules.RELATIONSHIP_MAP, AAO_Modules.INSIGHT_MAP,
            AAO_Modules.ASSESSMENT, AAO_Modules.SALES_PROCESS
        }) {
            System.assertEquals(
                true, AAO_Modules.present(m, opp),
                m + ' is hardcoded present, and the whole value of the facade is that the ' +
                'hardcoding is in ONE place.'
            );
        }
        System.assertEquals(4, AAO_Modules.rung(opp), 'Which is rung 4, the sandbox\'s own state.');
    }

    /**
     * **AN UNKNOWN MODULE THROWS RATHER THAN RESOLVING TRUE.** A typo that reads as present is a
     * projection target nobody notices is missing, which is the silent-drop shape this facade
     * exists to prevent rather than to introduce.
     */
    @IsTest
    static void anUNKNOWNMODULENEVERRESOLVESTOASILENTTRUE() {
        Boolean threw = false;
        try {
            AAO_Modules.present('Opportunity Manager', null);
        } catch (AAO_Modules.ModuleException e) {
            threw = true;
            System.assert(
                e.getMessage().contains('Opportunity Manager'),
                'And the refusal names it: ' + e.getMessage()
            );
        }
        System.assert(threw, 'An unrecognised module is refused, never assumed.');
    }

    /** The ladder, walked from the bottom. Each rung includes the ones below it. */
    @IsTest
    static void theRUNGSREADASTHELADDERRULEDTHEM() {
        AAO_Modules.absent = new Set<String>{ AAO_Modules.RELATIONSHIP_MAP };
        System.assertEquals(0, AAO_Modules.rung(null), 'No relationship map is the no-Altify rung.');

        AAO_Modules.absent = new Set<String>{ AAO_Modules.INSIGHT_MAP };
        System.assertEquals(1, AAO_Modules.rung(null), 'Map only.');

        AAO_Modules.absent = new Set<String>{ AAO_Modules.ASSESSMENT };
        System.assertEquals(2, AAO_Modules.rung(null), 'Plus insight map.');

        AAO_Modules.absent = new Set<String>{ AAO_Modules.SALES_PROCESS };
        System.assertEquals(3, AAO_Modules.rung(null), 'Plus assessment.');
    }

    /**
     * **ASSESSMENT AND SALES PROCESS ARE SEPARATELY LICENSED**, so a deal can carry one without
     * the other and nothing may ask about them together. The merged Process corpus has to
     * tolerate its qualifier half vanishing between two runs while the assessment half stands.
     */
    @IsTest
    static void assessmentANDSALESPROCESSAREASKEDSEPARATELY() {
        AAO_Modules.absent = new Set<String>{ AAO_Modules.ASSESSMENT };

        System.assertEquals(
            false, AAO_Modules.present(AAO_Modules.ASSESSMENT, null),
            'Assessment gone.'
        );
        System.assertEquals(
            true, AAO_Modules.present(AAO_Modules.SALES_PROCESS, null),
            'And sales process still standing, which is a state a customer can really be in.'
        );
    }

    /** A run's receipt has to be able to say what it saw: a verdict computed under rung 4 and
     *  read under rung 2 needs its provenance to say so. */
    @IsTest
    static void aRUNCANSAYWHATITSAW() {
        AAO_Modules.absent = new Set<String>{ AAO_Modules.SALES_PROCESS };
        String said = AAO_Modules.describe(null);
        System.assert(said.contains('rung 3'), said);
        System.assert(said.contains('Sales Process=absent'), said);
        System.assert(said.contains('Assessment=present'), said);
    }
}
