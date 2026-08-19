/**
 * THE LAW: every reader of contracts asks for a set, and the product's set is the org's
 * current questions. Ruled session 41 and revised session 17.
 *
 * A DEAL ALWAYS ANSWERS THE ORG'S CURRENT ACTIVE QUESTIONS. There is no per-deal rubric
 * binding and there must not be one. Version is **attribution on receipts** and never
 * routing: a claim records the contract it was adjudicated under so anyone can see what the
 * question said at the time, and that is a fact about the receipt rather than an instruction
 * about which questions to ask next. A deal opened last quarter is asked today's questions
 * today; its old claims keep naming the old contract, which is exactly what supersede
 * preserves.
 *
 * Session 16 built the opposite of this: a rubric-version field on the Opportunity, read for
 * routing. It is deleted. The reasoning that produced it treated the sandbox's two rubrics
 * as a product state, and it is not one, it is a test-org artefact of holding a seeded
 * fixture and a derived rubric side by side.
 *
 * SO THE SET IS DECIDED BY THE SYNTHETIC MARKER, not by a version string.
 *
 *   contracts()          the product set: active, non-superseded, and UNMARKED.
 *                        Seeded rows are marked synthetic and are invisible to it.
 *   contracts(true)      the synthetic set, which test and demo entries opt into
 *                        explicitly, by saying so at the call site.
 *
 * The default is the safe one. A new reader that calls `contracts()` and forgets this
 * distinction gets the product's questions and never the fixture's, which is the direction
 * an accident should fail in. The old caller-set static is gone: it made the answer depend
 * on execution order, and nothing that reads a rubric should have to know what ran first.
 */
public class AAO_Rubric {
    /**
     * ~~Every contract in the applicable set~~ **WRONG LAW as of the applicable-set ruling,
     * 2 August. This read is org-wide: no deal scope, no charter scope, no roster scope.** It
     * was right when there was one rubric and discovery was proving a rubric could be built at
     * all, and it is wrong now that People contracts exist per person and per charter. A pass
     * resolved from here would be handed every charter's contracts and every other deal's
     * people. **`AAO_ApplicableSet.resolve(charters, source)` is the law for a pass.** This
     * method survives for callers that genuinely want the whole cabinet — inventory, the
     * pipeline view, discovery's own audits — and must never be used to feed a model.
     *
     * One query rather than one per caller, so a new reader cannot quietly reintroduce an
     * unscoped one.
     *
     * `synthetic` is not a filter on a detail. It is which of two populations the caller
     * belongs to, and the caller is the only thing that knows.
     */
    public static List<AAO_Evidence_Contract__c> inventory(Boolean synthetic) {
        Boolean wantSynthetic = synthetic == true;
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
                AAO_Contract_State__c,
                AAO_Synthetic__c
            FROM AAO_Evidence_Contract__c
            WHERE
                AAO_Contract_State__c NOT IN :AAO_ContractState.DEAD
                AND AAO_Synthetic__c = :wantSynthetic
            ORDER BY AAO_Proposition_Code__c
        ];
    }

    /**
     * The product set. Active, not superseded, not synthetic.
     *
     * **Renamed from `contracts()` deliberately, so a model-path caller cannot compile against
     * it.** The old name read like the applicable set and was used as one; `AAO_Extract` called
     * it and asked the model about fifty-three propositions on a pass that had declared forty-
     * eight. A rename is the only restriction the compiler enforces.
     */
    public static List<AAO_Evidence_Contract__c> inventory() {
        return inventory(false);
    }

    public static Map<String, AAO_Evidence_Contract__c> inventoryByCode(Boolean synthetic) {
        Map<String, AAO_Evidence_Contract__c> out = new Map<String, AAO_Evidence_Contract__c>();
        for (AAO_Evidence_Contract__c ec : inventory(synthetic)) {
            out.put(ec.AAO_Proposition_Code__c, ec);
        }
        return out;
    }

    public static Map<String, AAO_Evidence_Contract__c> inventoryByCode() {
        return inventoryByCode(false);
    }
}