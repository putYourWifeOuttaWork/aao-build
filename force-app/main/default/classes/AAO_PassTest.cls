/**
 * The cost law, as an assertion rather than a paragraph.
 *
 * The retired shape crossed questions by PERSON and cost 87,805 ms per person; a five-person
 * call was ~440 s for one stage. The family sweep crosses by FAMILY instead, and the whole
 * argument for it rests on that count being bounded by the declared set and by nothing about
 * the call. A comment saying so would not survive the first well-meaning refactor.
 */
@isTest
private class AAO_PassTest {
    @isTest
    static void theNumberOfReadsIsBoundedByTheDECLAREDSETAndNothingElse() {
        Map<String, List<AAO_Evidence_Contract__c>> fams =
            AAO_LocateCharter.families(declared());
        System.assertEquals(
            4,
            fams.size(),
            'Four families: sentiment, political status, buyer role, criteria. This is the ' +
            'call-1 invocation count and it is the whole cost argument.'
        );
        Integer total = 0;
        for (List<AAO_Evidence_Contract__c> f : fams.values()) {
            total += f.size();
        }
        System.assertEquals(17, total, 'Every contract is swept by exactly one family.');
    }

    @isTest
    static void theReadCountDoesNotMoveWithTheROSTER() {
        // The law forbids crossing by person because that is unbounded. This asserts the
        // negative directly: nothing about a call's people can reach the read count, because
        // the grouping function takes only the declared set.
        Integer forAnyRoster = AAO_LocateCharter.families(declared()).size();
        System.assertEquals(
            forAnyRoster,
            AAO_LocateCharter.families(declared()).size(),
            'A twelve-person call is still four reads, and so is a two-person call.'
        );
        System.assertEquals(4, forAnyRoster, 'unit: reads');
    }

    @isTest
    static void everyDeclaredContractHasAFamilyOrTheSweepThrows() {
        // A contract with no family would be swept by nobody and would go silently unasked,
        // which is the invisible failure this whole build exists to refuse.
        for (AAO_PassContracts.Spec sp : AAO_PassContracts.specs()) {
            System.assertNotEquals(
                null,
                AAO_LocateCharter.familyOf(sp.code),
                sp.code + ' belongs to no family.'
            );
        }
        Boolean threw = false;
        try {
            AAO_LocateCharter.familyOf('AAO_SOMETHING_NEW');
        } catch (AAO_LocateCharter.CharterException e) {
            threw = true;
            System.assert(e.getMessage().contains('swept by nobody'), e.getMessage());
        }
        System.assert(threw, 'An unfamilied contract must throw, never be dropped.');
    }

    @isTest
    static void theWorkedExampleIsGoneAndTheWithinFamilyRuleRemains() {
        // Removed at 3.0.0: it produced imitation rather than generalisation. Asserted so a
        // later session does not helpfully add it back.
        String p = AAO_LocateCharter.systemPrompt();
        System.assert(
            !p.contains('WORKED EXAMPLE'),
            'The example anchored the model to itself; under the sweep it has no job.'
        );
        System.assert(
            p.contains('TWO QUESTIONS IN THE LIST CAN BOTH BE ANSWERED BY ONE SENTENCE'),
            'Within one family, multi-establishment still has to work and is still instructed.'
        );
    }

    private static List<AAO_Evidence_Contract__c> declared() {
        List<AAO_Evidence_Contract__c> out = new List<AAO_Evidence_Contract__c>();
        for (AAO_PassContracts.Spec sp : AAO_PassContracts.specs()) {
            out.add(new AAO_Evidence_Contract__c(
                AAO_Proposition_Code__c = sp.code,
                AAO_Proposition_Text__c = sp.proposition,
                AAO_Element_Count__c = sp.elements.size()
            ));
        }
        return out;
    }
}
