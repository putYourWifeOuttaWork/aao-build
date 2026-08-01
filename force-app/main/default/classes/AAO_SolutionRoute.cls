/**
 * THE SOLUTION ROUTE. Route P, basis State, no model and no ratification. Ruled v1.4–v1.7.
 *
 * What the deal has bought is a fact about the deal, and it is already written down. The
 * join closes without inference:
 *
 *   OpportunityLineItem -> PricebookEntry -> Product2.ALTF__Solution__c
 *                                            ALTF__Insight_Card__c.ALTF__Solution__c
 *
 * Both ends land on the same object, verified hop by hop in the org before any of this was
 * written.
 *
 * WHY NO RATIFICATION, which is the part worth understanding rather than obeying. Every
 * other machine write asks a human at some point because a human can see something the
 * machine cannot. Here there is nothing to see: the claim says a line item exists and names
 * which product it carries, and re-reading the line item confirms or refuses that outright.
 * STATE VERIFICATION ALREADY DOES WHAT RATIFICATION WOULD DO, so asking a person would be
 * asking them to agree with a row they can read themselves.
 *
 * WHAT THIS ROUTE MAY NOT DO, and it is the whole discipline of it. It may say a solution is
 * on this deal. It may NEVER say which pressure or obstacle that solution answers. A line
 * item records what was quoted, and inferring a causal link from a purchase order is
 * manufacturing the one thing this build exists to refuse to manufacture. That edge comes
 * from spans or from a person, and from nothing else.
 *
 * So the gap gets a flag instead of a guess, and the flag is not our invention: Altify's own
 * published admission test for a Solution asks three questions about links to other cards. A
 * Solution with no edge fails the methodology's own bar, not ours.
 */
public class AAO_SolutionRoute {
    public static final String READER = 'AAO_Line_Item_Read';
    public static final String READER_VERSION = '1.0.0';

    public class SolutionRouteException extends Exception {
    }

    /** One solution this deal has bought, and the line item that says so. */
    public class Bought {
        public Id solutionId;
        public Id lineItemId;
        public String productName;
        public Decimal quantity;

        public Bought(Id solutionId, OpportunityLineItem oli) {
            this.solutionId = solutionId;
            this.lineItemId = oli.Id;
            this.productName = oli.PricebookEntry == null || oli.PricebookEntry.Product2 == null
                ? null
                : oli.PricebookEntry.Product2.Name;
            this.quantity = oli.Quantity;
        }
    }

    /**
     * What this deal has bought, from its own line items. One traversal, no model, no
     * judgment. A line item whose product carries no solution is skipped rather than
     * guessed at: not every product is a methodology solution.
     */
    public static List<Bought> bought(Id opportunityId) {
        List<Bought> out = new List<Bought>();
        for (OpportunityLineItem oli : [
            SELECT
                Id,
                Quantity,
                PricebookEntry.Product2.Name,
                PricebookEntry.Product2.ALTF__Solution__c
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
        ]) {
            Id sol = oli.PricebookEntry == null || oli.PricebookEntry.Product2 == null
                ? null
                : oli.PricebookEntry.Product2.ALTF__Solution__c;
            if (sol != null) {
                out.add(new Bought(sol, oli));
            }
        }
        return out;
    }

    /**
     * The frozen half of a Solution basis. What the line item said WHEN THE CLAIM WAS
     * WRITTEN — cited fields only, never what was merely available, the same discipline the
     * map route uses.
     */
    public static String snapshot(Bought b) {
        return JSON.serialize(
            new Map<String, Object>{
                'v' => 1,
                'citedLineItemId' => b.lineItemId,
                'solutionId' => b.solutionId,
                'productName' => b.productName,
                'quantity' => b.quantity
            }
        );
    }

    /**
     * STATE VERIFICATION, the twin of the byte check, and the reason no human ratifies this.
     * Re-read every cited line item and confirm it still carries the solution being claimed.
     * A line removed or re-pointed between the read and the commit refuses the claim rather
     * than weakening it.
     */
    public static List<String> verifyState(List<Bought> cited) {
        List<String> failures = new List<String>();
        if (cited.isEmpty()) {
            return failures;
        }
        Map<Id, Id> solutionByLineItem = new Map<Id, Id>();
        Set<Id> ids = new Set<Id>();
        for (Bought b : cited) {
            ids.add(b.lineItemId);
            solutionByLineItem.put(b.lineItemId, b.solutionId);
        }
        Map<Id, OpportunityLineItem> fresh = new Map<Id, OpportunityLineItem>(
            [
                SELECT Id, PricebookEntry.Product2.ALTF__Solution__c
                FROM OpportunityLineItem
                WHERE Id IN :ids
            ]
        );
        for (Id lineItemId : solutionByLineItem.keySet()) {
            OpportunityLineItem now = fresh.get(lineItemId);
            if (now == null) {
                failures.add(lineItemId + ': the cited line item no longer exists');
                continue;
            }
            Id sol = now.PricebookEntry == null || now.PricebookEntry.Product2 == null
                ? null
                : now.PricebookEntry.Product2.ALTF__Solution__c;
            if (sol != solutionByLineItem.get(lineItemId)) {
                failures.add(
                    lineItemId +
                    ': cited for solution ' +
                    solutionByLineItem.get(lineItemId) +
                    ' and now carries ' +
                    sol
                );
            }
        }
        return failures;
    }

    // ============================================ the edge we may never derive

    /**
     * Solution cards on this deal with no edge to any other card.
     *
     * `ALTF__Insight_Card_Edge__c` carries the Solution on `ALTF__Solution_Insight_Card__c`
     * and the card it answers on `ALTF__Insight_Card__c`, so an edge existing is exactly the
     * question. Read from the org, not assumed.
     *
     * This is a READ of what a human or a span established. It never proposes an edge: the
     * whole point of the flag is that the link cannot be derived from what was bought.
     */
    public static List<AAO_MissingRelation.Member> unlinkedSolutions(Id opportunityId) {
        List<ALTF__Insight_Card__c> cards = [
            SELECT Id, Name, ALTF__Solution__c
            FROM ALTF__Insight_Card__c
            WHERE ALTF__Opportunity__c = :opportunityId AND ALTF__Type__c = 'Solution'
        ];
        if (cards.isEmpty()) {
            return new List<AAO_MissingRelation.Member>();
        }
        Set<Id> linked = new Set<Id>();
        for (ALTF__Insight_Card_Edge__c e : [
            SELECT ALTF__Solution_Insight_Card__c
            FROM ALTF__Insight_Card_Edge__c
            WHERE
                ALTF__Solution_Insight_Card__c IN :cards
                AND ALTF__Insight_Card__c != NULL
        ]) {
            linked.add(e.ALTF__Solution_Insight_Card__c);
        }

        List<AAO_MissingRelation.Member> missing = new List<AAO_MissingRelation.Member>();
        for (ALTF__Insight_Card__c card : cards) {
            if (!linked.contains(card.Id)) {
                missing.add(new AAO_MissingRelation.Member(card.Id, card.Name));
            }
        }
        return missing;
    }

    /**
     * Bring the unlinked-Solution flag into line with the map as it stands.
     *
     * Separate from the claim path on purpose: a solution can be unlinked whether or not it
     * came from a line item, and the flag is about the map rather than about our reading of
     * it.
     */
    public static AAO_Flag__c reconcileFlag(Id opportunityId, Id accountId) {
        return AAO_MissingRelation.reconcile(
            opportunityId,
            accountId,
            AAO_MissingRelation.SOLUTION_WITHOUT_PROBLEM,
            unlinkedSolutions(opportunityId)
        );
    }

    // ============================================================== the claim

    public class Outcome {
        public Integer solutionsFound = 0;
        public Integer basisRows = 0;
        public Id claimId;
        public String note;
    }

    /**
     * Write the state claim for what this deal has bought, through the same door every other
     * route uses.
     *
     * `contractCode` is DECLARED BY THE CALLER and not inferred. There is no Solution
     * proposition in the mini-rubric today, and picking one here would be inventing a
     * question the org never asked — the same mistake as manufacturing a Source. When a
     * Solution contract exists, this route answers it; until then it refuses by name and
     * says which contract it wanted.
     */
    public static Outcome run(
        Id opportunityId,
        Id accountId,
        String contractCode,
        Set<String> internalDomains,
        Boolean synthetic
    ) {
        Outcome o = new Outcome();
        AAO_Evidence_Contract__c ec = AAO_Rubric.byCode(synthetic).get(contractCode);
        if (ec == null) {
            throw new SolutionRouteException(
                'No contract "' +
                contractCode +
                '" in the applicable set, so there is no question for the line items to ' +
                'answer. The route refuses rather than choosing a proposition the org ' +
                'never asked.'
            );
        }

        List<Bought> items = bought(opportunityId);
        o.solutionsFound = items.size();
        if (items.isEmpty()) {
            o.note = 'No line item on this deal carries a solution, and nothing was written.';
            return o;
        }

        List<String> failures = verifyState(items);
        if (!failures.isEmpty()) {
            // Refused, not downgraded. A line item that no longer carries what it is cited
            // for is absent evidence, not weak evidence.
            throw new SolutionRouteException(
                'State verification failed, so nothing was written: ' +
                String.join(failures, '; ')
            );
        }

        AAO_Candidate__c cand = new AAO_Candidate__c(
            AAO_Evidence_Contract__c = ec.Id,
            AAO_Basis__c = AAO_EvidenceFamily.STATE,
            AAO_Opportunity__c = opportunityId,
            AAO_Account__c = accountId,
            AAO_Subject_Type__c = 'Opportunity',
            AAO_Proposed_Verdict__c = 'TRUE',
            AAO_Element_Coverage__c = AAO_Model.serializeCoverage(
                AAO_Model.newCoverage(
                    AAO_ExtractCharter.elementIds(ec),
                    new List<String>()
                )
            ),
            AAO_Interpretation__c = items.size() +
                ' line item(s) on this deal carry a methodology solution. Read, not judged: ' +
                'no model was asked, because what a deal has bought is written down.',
            AAO_Stage__c = 'Adjudicated',
            AAO_Outcome__c = 'Pending',
            AAO_Charter__c = READER,
            AAO_Charter_Version__c = READER_VERSION,
            AAO_Publication_State__c = 'Live',
            AAO_Synthetic__c = synthetic
        );
        insert cand;

        AAO_Commit.Result cr = AAO_Commit.commitCandidate(cand.Id, internalDomains);
        o.claimId = cr.claim == null ? null : cr.claim.Id;
        o.note = cr.note;
        if (o.claimId == null) {
            return o;
        }

        List<AAO_Claim_Basis__c> rows = new List<AAO_Claim_Basis__c>();
        for (Bought b : items) {
            rows.add(
                new AAO_Claim_Basis__c(
                    AAO_Claim__c = o.claimId,
                    AAO_Cited_Type__c = 'Line_Item',
                    AAO_Cited_Line_Item__c = b.lineItemId,
                    AAO_Covers_Element__c = AAO_ExtractCharter.elementIds(ec)[0],
                    AAO_Snapshot_Taken__c = System.now(),
                    AAO_Snapshot__c = snapshot(b)
                )
            );
        }
        insert rows;
        o.basisRows = rows.size();

        AAO_EvidenceFamily.requireBasisRows(new Set<Id>{ o.claimId });
        return o;
    }
}
