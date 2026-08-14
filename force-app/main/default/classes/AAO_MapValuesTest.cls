/**
 * THE NEVER-BLANK PROCEDURE, one test per branch, so no branch can quietly reopen.
 *
 * The seventy-seventh stamp's procedure is exhaustive by design, and the property that makes it
 * worth anything is negative: **the only path that leaves a field unwritten is an empty set.**
 * A property like that is not provable by looking at the code, only by walking every branch, so
 * this class walks them.
 */
@IsTest
private class AAO_MapValuesTest {
    private static final String BR = AAO_P8Codes.DIM_BUYER_ROLE;

    private static AAO_Map_Value__mdt row(String dim, String stored, Integer rank, String label) {
        return new AAO_Map_Value__mdt(
            AAO_Dimension__c = dim,
            AAO_Stored_Value__c = stored,
            AAO_Rank__c = rank,
            AAO_Displayed_Label__c = label
        );
    }

    private static void seed() {
        AAO_MapValues.reset();
        AAO_MapValues.stubbed = new List<AAO_Map_Value__mdt>{
            row(BR, 'Signature Approver', 5, 'Decision Maker and Approver'),
            row(BR, 'Decision Maker', 4, null),
            row(BR, 'Approver', 3, null),
            row(BR, 'Evaluator', 2, null),
            row(BR, 'User', 1, null),
            row(BR, 'Unknown', 0, null)
        };
    }

    @IsTest
    static void anEMPTYSETISTHEONLYBLANK() {
        seed();
        System.assertEquals(null, AAO_MapValues.decide(BR, new Set<String>()));
        System.assertEquals(null, AAO_MapValues.decide(BR, null));
    }

    @IsTest
    static void oneVALUEISALWAYSWRITTENEVENUNRANKED() {
        // "If the set has ONE value: WRITE IT. No hold, no note-instead-of-value, no exception."
        // Including a value this seed has never heard of: one established value has nothing to
        // lose a comparison to, so there is nothing to be uncertain between.
        seed();
        System.assertEquals('User', AAO_MapValues.decide(BR, new Set<String>{ 'User' }));
        System.assertEquals(
            'Chief Bottle Washer',
            AAO_MapValues.decide(BR, new Set<String>{ 'Chief Bottle Washer' }),
            'An unranked value standing alone is still written. This is the line that most ' +
            'directly ends the blank.'
        );
    }

    @IsTest
    static void severalVALUESWRITETHEHIGHESTRANKED() {
        seed();
        System.assertEquals(
            'Approver',
            AAO_MapValues.decide(BR, new Set<String>{ 'Evaluator', 'Approver' }),
            'The acceptance case: Adam Pfeiffer reads Approver, not blank.'
        );
        System.assertEquals(
            'Signature Approver',
            AAO_MapValues.decide(BR, new Set<String>{ 'User', 'Signature Approver', 'Approver' })
        );
        System.assertEquals(
            new List<String>{ 'Approver', 'User' },
            AAO_MapValues.outranked(BR, new Set<String>{ 'User', 'Signature Approver', 'Approver' }),
            'Everything not written is kept for the note, in a stable order.'
        );
    }

    @IsTest
    static void anUNRANKEDVALUESORTSBELOWEVERYRANKEDONEBUTSTAYSELIGIBLE() {
        seed();
        System.assertEquals(
            'User',
            AAO_MapValues.decide(BR, new Set<String>{ 'User', 'Chief Bottle Washer' }),
            'Rank 1 still beats no rank at all.'
        );
        System.assert(
            AAO_MapValues.outranked(BR, new Set<String>{ 'User', 'Chief Bottle Washer' })
                .contains('Chief Bottle Washer'),
            'And the unranked value is not discarded, only outranked.'
        );
    }

    @IsTest
    static void onlyUNRANKEDVALUESTAKETHEVENDORPICKLISTORDER() {
        // "If the established set contains only unranked values, write the FIRST BY THE VENDOR
        // PICKLIST ORDER." Read by describe, because a customer's picklist order is a fact about
        // their org and asking the schema is the only way to know it that cannot drift.
        AAO_MapValues.reset();
        AAO_MapValues.stubbed = new List<AAO_Map_Value__mdt>();
        String picked = AAO_MapValues.decide(
            BR, new Set<String>{ 'Evaluator', 'Approver', 'User' }
        );
        System.assertNotEquals(null, picked, 'NEVER null for a non-empty set. That is the law.');
        System.assertEquals(
            'Approver', picked,
            'The vendor picklist declares Approver first, so with no ranks at all it wins.'
        );
    }

    @IsTest
    static void aVALUENOTHINGKNOWSISSTILLWRITTEN() {
        // The last branch, and the one a real org will hit first: a relabelled or custom entry
        // that is in neither our seed nor the vendor picklist. Alphabetical is arbitrary and is
        // SAID to be arbitrary; what it must not do is return null.
        AAO_MapValues.reset();
        AAO_MapValues.stubbed = new List<AAO_Map_Value__mdt>();
        String picked = AAO_MapValues.decide(BR, new Set<String>{ 'Zebra', 'Aardvark' });
        System.assertEquals('Aardvark', picked);
        System.assertNotEquals(null, picked, 'Still not a blank.');
    }

    @IsTest
    static void theLABELMAPISCONFIGURATIONANDNEVERTOUCHESLOGIC() {
        // Matthew's ruling: an org may relabel a slot, so it must be able to state what its
        // words mean. The label is carried for humans; the DECISION reads stored values only,
        // which is what stops a relabelling from silently changing what our ranking means.
        seed();
        System.assertEquals(
            'Decision Maker and Approver',
            AAO_MapValues.labelOf(BR, 'Signature Approver'),
            'Production displays the stored Signature Approver under that label.'
        );
        System.assertEquals(
            'Evaluator', AAO_MapValues.labelOf(BR, 'Evaluator'),
            'Where the org says nothing, the label IS the stored value.'
        );
        System.assertEquals(
            'Signature Approver',
            AAO_MapValues.decide(BR, new Set<String>{ 'Signature Approver', 'Decision Maker' }),
            'And the decision is unaffected by the label: it ranks the STORED value.'
        );
    }

    @IsTest
    static void noLABELSTRINGISHARDCODEDINLOGIC() {
        // Asserted against the class body, the same way the Inspector's read-only law is. A
        // relabelled org is only safe if no branch anywhere compares against a display word.
        ApexClass body = [SELECT Body FROM ApexClass WHERE Name = 'AAO_MapValues' LIMIT 1];
        for (String label : new List<String>{
            'Decision Maker and Approver', 'Signature Approver', 'Decision Maker',
            'Approver', 'Evaluator', 'Inner Circle'
        }) {
            System.assert(
                !body.Body.contains('\'' + label + '\''),
                'A value string in the procedure is a ranking an org cannot restate. Found: ' +
                label
            );
        }
    }

    @IsTest
    static void theSEEDSHIPSTHERANKSTHESTAMPNAMED() {
        // Against the real metadata rather than the stub, so the shipped defaults are asserted
        // and not merely intended.
        AAO_MapValues.reset();
        System.assertEquals(5, AAO_MapValues.rankOf(BR, 'Signature Approver'));
        System.assertEquals(4, AAO_MapValues.rankOf(BR, 'Decision Maker'));
        System.assertEquals(3, AAO_MapValues.rankOf(BR, 'Approver'));
        System.assertEquals(2, AAO_MapValues.rankOf(BR, 'Evaluator'));
        System.assertEquals(1, AAO_MapValues.rankOf(BR, 'User'));
        System.assertEquals(0, AAO_MapValues.rankOf(BR, 'Unknown'));
        String pol = AAO_P8Codes.DIM_POLITICAL;
        System.assertEquals(3, AAO_MapValues.rankOf(pol, 'Inner Circle'));
        System.assertEquals(2, AAO_MapValues.rankOf(pol, 'Political Structure'));
        System.assertEquals(1, AAO_MapValues.rankOf(pol, 'Outside Political Structure'));
        System.assertEquals(0, AAO_MapValues.rankOf(pol, 'Unknown'));
    }

    @IsTest
    static void supportANDSENTIMENTAREDELIBERATELYABSENT() {
        // They keep their counter arithmetic and a net zero reads Neutral, per the forty-fourth
        // stamp. Ranking them would be a second mechanism for a question that already has one.
        AAO_MapValues.reset();
        System.assertEquals(null, AAO_MapValues.rankOf(AAO_P8Codes.DIM_SUPPORT, 'Supporter'));
    }
}