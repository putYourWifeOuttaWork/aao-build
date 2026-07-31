/**
 * The frozen contract-key composer, and the immutability of authored text.
 *
 * A contract is per proposition, per version of its text. An in-place edit of the
 * proposition or its guidance is a new contract, not a mutation of this one, because
 * every claim already stamped with this contract was adjudicated against the words as
 * they read then. The content hash is the only detector of such an edit, so the hash and
 * the text it covers are frozen together.
 */
public class AAO_EvidenceContractTriggerHandler {
    private static final Set<String> FROZEN = new Set<String>{
        'AAO_Question_Record_Id__c',
        'AAO_Content_Hash__c',
        'AAO_Contract_Key__c',
        'AAO_Proposition_Short__c',
        'AAO_Proposition_Text__c',
        'AAO_Guidance_Text__c'
    };

    public static void beforeInsert(List<AAO_Evidence_Contract__c> rows) {
        for (AAO_Evidence_Contract__c ec : rows) {
            ec.AAO_Synthetic__c = AAO_Synthetic.MARK;
            if (String.isBlank(ec.AAO_Content_Hash__c)) {
                ec.AAO_Content_Hash__c = AAO_ContractKey.contentHash(
                    ec.AAO_Proposition_Text__c,
                    ec.AAO_Guidance_Text__c
                );
            }
            ec.AAO_Contract_Key__c = AAO_ContractKey.compose(ec);
            validate(ec);
        }
    }

    public static void beforeUpdate(
        List<AAO_Evidence_Contract__c> rows,
        Map<Id, AAO_Evidence_Contract__c> oldById
    ) {
        for (AAO_Evidence_Contract__c ec : rows) {
            AAO_Evidence_Contract__c old = oldById.get(ec.Id);
            for (String f : FROZEN) {
                if (ec.get(f) != old.get(f)) {
                    ec.addError(
                        f +
                        ' is immutable on AAO_Evidence_Contract__c. A contract is per ' +
                        'proposition per version of its text; every claim already stamped ' +
                        'with this contract was adjudicated against the words as they read ' +
                        'then. Supersede it with a new contract instead.'
                    );
                    break;
                }
            }
            if (!ec.hasErrors()) {
                validate(ec);
            }
        }
    }

    /**
     * Ratified 31 July, session 14. Contracts were deletable by anything that could run a
     * DML statement, and the only thing standing between a live contract and a delete was
     * a WHERE clause in the purge that happened to filter on the synthetic marker. That is
     * a filter pretending to be a guard, and session 13 proved it: the filter was wrong,
     * six contracts survived every purge, and nothing complained.
     *
     * The reason a contract must not be deletable is the same reason a claim must not be.
     * Every claim carries the contract key it was adjudicated under. Delete the contract
     * and those claims still name it, so the words a verdict was judged against are gone
     * while the verdict remains, and no replay can ever explain it again.
     *
     * SUPERSEDE IS THE RETIREMENT PATH. AAO_Superseded_By__c and AAO_Contract_State__c
     * exist for exactly this: a contract that should no longer be used stops being used
     * and keeps existing, so the claims that rest on it stay legible.
     */
    public static void beforeDelete(List<AAO_Evidence_Contract__c> rows) {
        for (AAO_Evidence_Contract__c ec : rows) {
            if (AAO_Synthetic.deletable(ec.AAO_Synthetic__c)) {
                continue;
            }
            ec.addError(
                'AAO_Evidence_Contract__c is not deletable on the live path. Every claim ' +
                'stamped with this contract was adjudicated against its words, and those ' +
                'claims still name it: deleting it leaves verdicts that nothing can ' +
                'explain. Supersede it instead, with AAO_Superseded_By__c and a contract ' +
                'state of Superseded, which retires it without destroying what rests on it.'
            );
        }
    }

    private static void validate(AAO_Evidence_Contract__c ec) {
        // The number of parts is never unknown.
        if (ec.AAO_Element_Count__c == null || ec.AAO_Element_Count__c < 1) {
            ec.addError(
                'A contract must know how many parts its proposition has. The number of ' +
                'parts is never unknown.'
            );
            return;
        }
        List<Object> elements;
        try {
            elements = (List<Object>) JSON.deserializeUntyped(
                String.isBlank(ec.AAO_Elements__c) ? '[]' : ec.AAO_Elements__c
            );
        } catch (Exception e) {
            ec.addError('AAO_Elements__c is not a JSON list: ' + e.getMessage());
            return;
        }
        if (elements.size() != ec.AAO_Element_Count__c) {
            ec.addError(
                'AAO_Element_Count__c says ' +
                ec.AAO_Element_Count__c +
                ' but AAO_Elements__c lists ' +
                elements.size() +
                '. Coverage arithmetic reads the count and the blind reader reads the list; ' +
                'they cannot disagree.'
            );
        }
    }
}
