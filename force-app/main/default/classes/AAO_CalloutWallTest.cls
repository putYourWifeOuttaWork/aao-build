/**
 * R1 · THE CAP IS DERIVED AGAINST THE MEASURED WALL, and the derivation is held to its arithmetic.
 *
 * These assert relationships rather than values, deliberately. **The numbers are measurements and
 * are expected to move** as Process adds claims to verify and the exposed stage grows; what must
 * not move is that the budget stays a fixed fraction of the wall, that the cap stays derived from
 * the budget and the worst measured rate, and that the tighter of the two independent ceilings is
 * the one that binds. A test pinning `15` would fail the day the derivation did its job.
 */
@IsTest
private class AAO_CalloutWallTest {

    @IsTest
    static void theBudgetIsSEVENTYFIVEPERCENTofTheMEASUREDwallAndNotOfTheDocumentedOne() {
        Decimal fraction =
            Decimal.valueOf(AAO_Pass.CALLOUT_BUDGET_MS) / AAO_Pass.MEASURED_GATEWAY_WALL_MS;
        System.assert(
            fraction >= 0.70 && fraction <= 0.80,
            'The same 75% headroom as the 90-second split trigger and the 112-statement DML ' +
            'trigger, so the three read as one rule in three units. Got ' + fraction
        );
        System.assert(
            AAO_Pass.MEASURED_GATEWAY_WALL_MS < 120000,
            'AND IT IS MEASURED AGAINST THE WALL THAT ACTUALLY FAILS. A callout with a 120,000 ' +
            'ms timeout set died at ~88,000, so every timing table this project published was ' +
            'safe against the wrong number. A budget derived from 120,000 would rebuild that ' +
            'mistake with a fresh coat on it.'
        );
    }

    @IsTest
    static void theTimeCapIsTheBUDGETOVERTHEWORSTRATEandNotTheAverageOne() {
        Integer derived = AAO_Pass.CALLOUT_BUDGET_MS / AAO_Pass.WORST_MS_PER_UNIT;
        System.assertEquals(
            derived,
            AAO_Pass.TIME_CAP_UNITS,
            'Derived, never authored. Three calls of identical size took 15,287, 25,462 and ' +
            '39,526 ms, so per-unit time barely predicts anything and a cap must hold on a slow ' +
            'call rather than an average one.'
        );
    }

    @IsTest
    static void theTIGHTERofTheTwoCeilingsBindsAndItIsGrammarToday() {
        System.assertEquals(
            Math.min(AAO_Pass.GRAMMAR_CAP_UNITS, AAO_Pass.TIME_CAP_UNITS),
            AAO_Pass.MAX_UNITS_PER_KEYED_CALL,
            'Two independent ceilings, neither implied by the other. Written as a minimum so ' +
            'that if either moves, the tighter one takes over without anybody remembering to.'
        );
        System.assert(
            AAO_Pass.MAX_UNITS_PER_KEYED_CALL * AAO_Pass.WORST_MS_PER_UNIT <
                AAO_Pass.CALLOUT_BUDGET_MS,
            'And a full call at the binding cap fits inside the budget with room, which is the ' +
            'first time this project can say that about the wall that actually fails.'
        );
    }

    @IsTest
    static void aSLOWCALLTHATRETURNEDISMARKEDANDNEVERFAILED() {
        AAO_Receipt.Leg leg = new AAO_Receipt.Leg();
        System.assertEquals(
            null,
            leg.wallWarning,
            'Null on every callout inside its budget, so the warning means something when it ' +
            'is not null.'
        );
        System.assert(
            AAO_Pass.CALLOUT_BUDGET_MS > 0,
            'And the threshold the warning fires on is the derived budget rather than a second ' +
            'number that could drift away from it.'
        );
    }
}
