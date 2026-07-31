/**
 * THE LAW: a deal is adjudicated under ONE rubric, and every reader of contracts is scoped
 * to it. Ruled session 15, for corrections v2.0.
 *
 * This started as a bug fix. Day-one red raised four flags per deal where two were theirs,
 * because after discovery ran the org held two rubrics at once and the raise path asked only
 * "which contracts are gating". Scoping it fixed the flags and left the same hole in two
 * other readers, which is how a bug fix turns out to be a missing law.
 *
 * THE SANDBOX COLLISION IS A MINIATURE OF THE REAL ONE. Two rubrics in one org is not an
 * artefact of having both a seeded and a derived rubric here. It is what a customer editing
 * their rubric mid-quarter produces: contracts are per proposition per version of their
 * text, an edit creates a new generation, and deals opened before the edit are still being
 * adjudicated under the old one. Both generations are live and correct at the same time.
 * Any reader that asks "which contracts exist" rather than "which contracts is this deal
 * judged under" silently mixes the generations, and it mixes them in the direction that
 * looks like more rigour: more propositions considered, more reds raised, more abstentions
 * logged. It would read as thoroughness.
 *
 * WHAT IS OWED, and it is the honest limit of this. There is no field recording which rubric
 * a given deal is adjudicated under. `active` is a caller-set static, which means the binding
 * lives in whoever starts the run rather than on the deal. That is enough for one rubric per
 * org and not enough for the mid-quarter edit this law exists to survive. The binding wants
 * to be a field, and until it is, this class is the single place that would have to change.
 */
public class AAO_Rubric {
    /**
     * The rubric this execution adjudicates under. Defaults to the seeded mini-rubric,
     * which is what the demo and the model path run on. Discovery sets its own around its
     * work and puts it back.
     */
    public static String active = AAO_Seed.RUBRIC_VERSION;

    /**
     * Every contract in one rubric, with every field any reader needs. One query rather
     * than one per caller, so a new reader cannot quietly reintroduce an unscoped one.
     */
    public static List<AAO_Evidence_Contract__c> contracts(String rubricVersion) {
        return [
            SELECT
                Id,
                AAO_Proposition_Code__c,
                AAO_Proposition_Short__c,
                AAO_Proposition_Text__c,
                AAO_Guidance_Text__c,
                AAO_Elements__c,
                AAO_Element_Count__c,
                AAO_Elements_Basis__c,
                AAO_Speaker_Requirement__c,
                AAO_Per_Person_Source__c,
                AAO_Gating__c,
                AAO_Route__c,
                AAO_Rubric_Version__c,
                AAO_Contract_State__c
            FROM AAO_Evidence_Contract__c
            WHERE
                AAO_Contract_State__c != 'Superseded'
                AND AAO_Rubric_Version__c = :rubricVersion
            ORDER BY AAO_Proposition_Code__c
        ];
    }

    public static List<AAO_Evidence_Contract__c> contracts() {
        return contracts(active);
    }

    public static Map<String, AAO_Evidence_Contract__c> byCode(String rubricVersion) {
        Map<String, AAO_Evidence_Contract__c> out = new Map<String, AAO_Evidence_Contract__c>();
        for (AAO_Evidence_Contract__c ec : contracts(rubricVersion)) {
            out.put(ec.AAO_Proposition_Code__c, ec);
        }
        return out;
    }

    public static Map<String, AAO_Evidence_Contract__c> byCode() {
        return byCode(active);
    }
}
