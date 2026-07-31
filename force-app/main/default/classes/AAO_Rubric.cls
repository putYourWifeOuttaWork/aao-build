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
 * THE BINDING IS A FACT ABOUT THE DEAL, as of session 16.
 * `Opportunity.AAO_Rubric_Version__c` records which rubric a deal is adjudicated under,
 * written once at cold start or first adjudication and never changed. Session 15 left this
 * as a caller-set static and said so: that expressed a property of the execution when the
 * question is a property of the deal, which is exactly the distinction the mid-quarter edit
 * turns on. `active` survives only as the value a deal is bound TO on its first
 * adjudication, and as the fallback for a deal nothing has judged yet.
 */
public class AAO_Rubric {
    /**
     * What an UNBOUND deal will be bound to on its first adjudication. Not the answer to
     * "which rubric is this deal judged under" any more; that is on the deal.
     */
    public static String active = AAO_Seed.RUBRIC_VERSION;

    /**
     * The rubric this deal is adjudicated under. The field is the authority; `active` is
     * only the default for a deal nothing has judged yet.
     */
    public static String versionFor(Id opportunityId) {
        if (opportunityId == null) {
            return active;
        }
        List<Opportunity> rows = [
            SELECT AAO_Rubric_Version__c FROM Opportunity WHERE Id = :opportunityId
        ];
        if (rows.isEmpty() || String.isBlank(rows[0].AAO_Rubric_Version__c)) {
            return active;
        }
        return rows[0].AAO_Rubric_Version__c;
    }

    /**
     * Bind a deal to a rubric, once. A deal already bound is left alone: it has claims
     * judged under that rubric and rebinding it would make them incomparable to whatever
     * came next, silently.
     *
     * DML, so never call it before a callout.
     */
    public static Boolean bind(Id opportunityId, String rubricVersion) {
        if (opportunityId == null || String.isBlank(rubricVersion)) {
            return false;
        }
        List<Opportunity> rows = [
            SELECT Id, AAO_Rubric_Version__c FROM Opportunity WHERE Id = :opportunityId
        ];
        if (rows.isEmpty() || String.isNotBlank(rows[0].AAO_Rubric_Version__c)) {
            return false;
        }
        rows[0].AAO_Rubric_Version__c = rubricVersion;
        update rows[0];
        return true;
    }

    public static Map<String, AAO_Evidence_Contract__c> byCodeForDeal(Id opportunityId) {
        return byCode(versionFor(opportunityId));
    }

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
