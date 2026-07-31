/**
 * Replaying claims in evidence-occurred order must reconstruct every answer exactly.
 * That is the exit test.
 *
 * The mirror it rebuilds into is empty and in memory. It does not touch the live answers,
 * because a replay that overwrote what it was checking would prove nothing.
 *
 * Ordering is on AAO_Evidence_Occurred__c, never on processing time. A backfilled 2024
 * transcript ingested this morning has to replay into its own place in the sequence, or
 * the trend is worthless. Recorded-at and Id are tiebreaks only, so two claims stamped
 * with the same occurred clock still replay deterministically.
 */
public class AAO_Replay {
    /** Rebuilt answers, keyed by AAO_Answer_Key__c. */
    public static Map<String, AAO_Answer__c> rebuild(Id opportunityId) {
        Map<String, AAO_Answer__c> mirror = new Map<String, AAO_Answer__c>();

        for (AAO_Claim__c c : [
            SELECT
                Id,
                AAO_Answer__c,
                AAO_Source__c,
                AAO_Evidence_Contract__c,
                AAO_Opportunity__c,
                AAO_Account__c,
                AAO_Subject_Type__c,
                AAO_Subject_Contact__c,
                AAO_Verdict_Before__c,
                AAO_Verdict_After__c,
                AAO_Spans__c,
                AAO_Element_Coverage__c,
                AAO_Interpretation__c,
                AAO_Outcome__c,
                AAO_Actor__c,
                AAO_Charter_Version__c,
                AAO_Rubric_Version__c,
                AAO_Evidence_Occurred__c,
                AAO_Recorded_At__c
            FROM AAO_Claim__c
            WHERE AAO_Opportunity__c = :opportunityId
            ORDER BY AAO_Evidence_Occurred__c ASC, AAO_Recorded_At__c ASC, Id ASC
        ]) {
            String key = AAO_AnswerKey.compose(c);
            AAO_Answer__c a = mirror.get(key);
            if (a == null) {
                a = new AAO_Answer__c();
                mirror.put(key, a);
            }
            AAO_Accumulate.apply(a, c);
        }
        return mirror;
    }

    /**
     * Compare a rebuilt mirror against the live answers, field for field, on exactly the
     * fields replay is answerable for. Returns one line per disagreement; an empty list
     * is the pass condition.
     */
    public static List<String> diff(Map<String, AAO_Answer__c> rebuilt, List<AAO_Answer__c> live) {
        List<String> out = new List<String>();
        Map<String, AAO_Answer__c> liveByKey = new Map<String, AAO_Answer__c>();
        for (AAO_Answer__c a : live) {
            liveByKey.put(a.AAO_Answer_Key__c, a);
        }

        for (String key : liveByKey.keySet()) {
            if (!rebuilt.containsKey(key)) {
                out.add(
                    key +
                    ': present in the mirror, produced by no claim. Something wrote an ' +
                    'answer without a receipt.'
                );
            }
        }
        for (String key : rebuilt.keySet()) {
            if (!liveByKey.containsKey(key)) {
                out.add(key + ': replay produced an answer the mirror does not have.');
                continue;
            }
            AAO_Answer__c r = rebuilt.get(key);
            AAO_Answer__c l = liveByKey.get(key);
            for (String f : AAO_Accumulate.REPLAY_GOVERNED) {
                Object rv = r.get(f);
                Object lv = l.get(f);
                if (rv != lv) {
                    out.add(
                        key + '.' + f + ': replay says [' + rv + '], mirror says [' + lv + ']'
                    );
                }
            }
        }
        return out;
    }

    /** Every live answer on a deal, selecting exactly the replay-governed fields. */
    public static List<AAO_Answer__c> liveAnswers(Id opportunityId) {
        return [
            SELECT
                Id,
                AAO_Answer_Key__c,
                AAO_Verdict__c,
                AAO_Spans__c,
                AAO_Element_Coverage__c,
                AAO_Interpretation__c,
                AAO_Established_By__c,
                AAO_Charter_Version__c,
                AAO_Rubric_Version__c,
                AAO_Evidence_Occurred__c,
                AAO_Subject_Type__c,
                AAO_Evidence_Contract__c,
                AAO_Opportunity__c,
                AAO_Account__c,
                AAO_Subject_Contact__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :opportunityId
        ];
    }
}
