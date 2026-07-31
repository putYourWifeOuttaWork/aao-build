/**
 * The evidence-family law on the proposing side, per AAO_EvidenceFamily.
 *
 * A candidate is where the shape is cheapest to refuse: nothing has been established yet,
 * nothing cites it, and the proposal can simply be rejected. By the time the same mistake
 * reaches a claim it has an answer hanging off it.
 */
public class AAO_CandidateTriggerHandler {
    public static void enforceFamily(
        List<AAO_Candidate__c> rows,
        Map<Id, AAO_Candidate__c> oldMap
    ) {
        for (AAO_Candidate__c c : rows) {
            AAO_Candidate__c prior = oldMap == null ? null : oldMap.get(c.Id);

            // A row written before the field existed keeps its null and stays updatable.
            // Backfilling nothing is the standing rule; the law starts clean at insert.
            if (prior != null && String.isBlank(prior.AAO_Basis__c) && String.isBlank(c.AAO_Basis__c)) {
                continue;
            }

            if (prior != null && prior.AAO_Basis__c != c.AAO_Basis__c && String.isNotBlank(prior.AAO_Basis__c)) {
                c.addError(
                    'A candidate cannot change its evidence family. It was ' +
                    prior.AAO_Basis__c +
                    ' and something is making it ' +
                    c.AAO_Basis__c +
                    '. A claim that already cited this row was adjudicated on the old ' +
                    'family, and editing it would rewrite what that claim rested on.'
                );
                continue;
            }

            String bad = AAO_EvidenceFamily.violation(
                'AAO_Candidate__c',
                c.AAO_Basis__c,
                c.AAO_Source__c,
                c.AAO_Spans__c,
                false
            );
            if (bad != null) {
                c.addError(bad);
            }
        }
    }
}
