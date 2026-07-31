/**
 * The P route, and the thing that finally makes Claim Basis mean something.
 *
 * Route E answers a proposition from what somebody SAID: spans, quoted verbatim, verified
 * byte for byte against a frozen artifact. Route P answers one from what the org's own
 * records STATE: rows on the relationship map, read at claim time. No model is involved and
 * none should be. "Is a decision maker identified on the relationship map" is answered by
 * counting rows on the relationship map, and a model asked to do that could only be less
 * reliable than the count.
 *
 * WHY THIS NEEDED A DIFFERENT VERIFICATION, and it is the whole point of the route.
 *
 * A span is safe to freeze because its artifact is immutable: the transcript cannot change
 * under the claim, so a quote verified once is verified forever. A map row is the opposite.
 * It is live customer data, editable by anyone, at any time, and usually by someone who has
 * no idea a claim rests on it. Dana is Decision Maker today and Evaluator next Tuesday.
 *
 * So the P route freezes what it cited, in AAO_Snapshot__c, at claim time. The claim says
 * what the row said THEN. The lookup still points at the row, so what it says NOW is one
 * traversal away. Both halves in one subquery, and the gap between them is the reason the
 * frozen half exists at all: without it, editing a map row would silently rewrite the
 * evidence under every claim that ever rested on it.
 *
 * STATE VERIFICATION is the twin of the byte check. Before commit, every cited row is
 * re-read and confirmed to still carry the value being claimed. The byte check asks "are
 * these words actually in this artifact"; this asks "does this record actually say this".
 * Same question, different kind of evidence, and a claim that fails it is not written.
 */
public class AAO_MapRoute {
    public class MapRouteException extends Exception {
    }

    /** The proposition this route answers. Route P in the mini-rubric. */
    public static final String CODE = 'AAO_T2';
    public static final String ELEMENT = 'e1';
    public static final String ROLE_DECISION_MAKER = 'Decision Maker';
    /** Not a charter. Deterministic Apex, and the version is still attribution. */
    public static final String READER = 'AAO_Map_Count';
    public static final String READER_VERSION = '1.0.0';

    // ============================================================ a. the map rows

    /**
     * Data rows on a managed object, which the standing constraint permits. What it forbids
     * is a FIELD on one, and there is none: the lookup that ties a basis to a map row lives
     * on AAO_Claim_Basis__c, which is ours.
     */
    public static Integer seedMapRows(Id opportunityId, Id accountId, Id contactId) {
        List<ALTF__Contact_Map_Details__c> existing = [
            SELECT Id
            FROM ALTF__Contact_Map_Details__c
            WHERE ALTF__Opportunity__c = :opportunityId AND ALTF__Contact__c = :contactId
        ];
        if (!existing.isEmpty()) {
            return 0;
        }
        insert new ALTF__Contact_Map_Details__c(
            ALTF__Opportunity__c = opportunityId,
            ALTF__Account__c = accountId,
            ALTF__Contact__c = contactId,
            ALTF__Buyer_Role__c = ROLE_DECISION_MAKER,
            ALTF__Account_Relationship__c = 'External',
            ALTF__Coverage__c = 'In-depth',
            ALTF__Status__c = 'Supporter'
        );
        return 1;
    }

    // ====================================================== b. the deterministic read

    public class Reading {
        public List<ALTF__Contact_Map_Details__c> cited =
            new List<ALTF__Contact_Map_Details__c>();
        public String verdict;
        public String note;
    }

    /**
     * Count the map rows that carry the buying role the proposition asks about. That is the
     * entire reader.
     */
    public static Reading read(Id opportunityId) {
        Reading r = new Reading();
        for (ALTF__Contact_Map_Details__c row : [
            SELECT Id, ALTF__Buyer_Role__c, ALTF__Contact__r.Name, ALTF__Contact__c
            FROM ALTF__Contact_Map_Details__c
            WHERE ALTF__Opportunity__c = :opportunityId
        ]) {
            if (row.ALTF__Buyer_Role__c == ROLE_DECISION_MAKER) {
                r.cited.add(row);
            }
        }
        // UNVERIFIED rather than FALSE on an empty map, and the distinction is the same one
        // the extraction charter had to be taught: an empty relationship map is the absence
        // of a record, not a record that there is no decision maker.
        r.verdict = r.cited.isEmpty() ? 'UNVERIFIED' : 'TRUE';
        r.note = r.cited.size() + ' map row(s) carry the role "' + ROLE_DECISION_MAKER + '"';
        return r;
    }

    // ==================================================== d. state verification

    public class Verification {
        public Boolean passed = true;
        public List<String> failures = new List<String>();
    }

    /**
     * The state-side twin of the byte check. Re-read every cited row and confirm it still
     * carries the value being claimed. Between the read and the commit anything could have
     * changed it, and a claim that cites a row for a value it no longer holds is a claim
     * about something that is not there.
     */
    public static Verification verifyState(List<ALTF__Contact_Map_Details__c> cited) {
        Verification v = new Verification();
        if (cited.isEmpty()) {
            return v;
        }
        Set<Id> ids = new Map<Id, ALTF__Contact_Map_Details__c>(cited).keySet();
        Map<Id, ALTF__Contact_Map_Details__c> fresh = new Map<Id, ALTF__Contact_Map_Details__c>(
            [
                SELECT Id, ALTF__Buyer_Role__c
                FROM ALTF__Contact_Map_Details__c
                WHERE Id IN :ids
            ]
        );
        for (ALTF__Contact_Map_Details__c row : cited) {
            ALTF__Contact_Map_Details__c now = fresh.get(row.Id);
            if (now == null) {
                v.passed = false;
                v.failures.add(row.Id + ': the cited row no longer exists');
                continue;
            }
            if (now.ALTF__Buyer_Role__c != ROLE_DECISION_MAKER) {
                v.passed = false;
                v.failures.add(
                    row.Id +
                    ': cited as "' +
                    ROLE_DECISION_MAKER +
                    '" and now reads "' +
                    now.ALTF__Buyer_Role__c +
                    '"'
                );
            }
        }
        return v;
    }

    // ================================================== c. the claim and its basis

    public class Outcome {
        public Id claimId;
        public Id answerId;
        public String verdict;
        public Integer basisRows = 0;
        public String note;

        public override String toString() {
            return 'P-ROUTE verdict=' +
                verdict +
                ' claim=' +
                claimId +
                ' basis=' +
                basisRows +
                (String.isBlank(note) ? '' : ' note=' + note);
        }
    }

    /**
     * Answer the P proposition on one deal, through the same commit machinery route E uses,
     * then freeze what it rested on.
     */
    public static Outcome run(Id opportunityId, Set<String> internalDomains) {
        return run(opportunityId, internalDomains, false);
    }

    /**
     * `synthetic` is declared by the caller, per session 17. The first version of this read
     * AAO_Synthetic.MARK to decide, which is the implicit form the same ruling threw out:
     * the answer then depends on whether whoever called last happened to leave the marker
     * set, and the demo's own scaffold clears it in a finally block. Which population a run
     * belongs to is not something to infer from a leftover flag.
     */
    public static Outcome run(
        Id opportunityId,
        Set<String> internalDomains,
        Boolean synthetic
    ) {
        Outcome o = new Outcome();

        Map<String, AAO_Evidence_Contract__c> contracts = AAO_Rubric.byCode(synthetic);
        AAO_Evidence_Contract__c ec = contracts.get(CODE);
        if (ec == null) {
            throw new MapRouteException(
                'No contract ' + CODE + ' in the applicable set. Nothing to answer.'
            );
        }

        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :opportunityId];

        Reading r = read(opportunityId);
        o.verdict = r.verdict;
        o.note = r.note;
        if (r.cited.isEmpty()) {
            o.note = r.note + '. Nothing established, and no claim written.';
            return o;
        }

        Verification v = verifyState(r.cited);
        if (!v.passed) {
            // Refused, not downgraded. A cited row that does not say what it is cited for
            // is not weaker evidence, it is absent evidence.
            throw new MapRouteException(
                'State verification failed, so nothing was written: ' +
                String.join(v.failures, '; ')
            );
        }

        // UNBLOCKED BY 47. The candidate is written with no Source, because a state read
        // has no artifact, and it declares basis State so the evidence-family law checks
        // it against the right shape: no Source, no spans, cited rows required.
        AAO_Candidate__c cand = new AAO_Candidate__c(
            AAO_Evidence_Contract__c = ec.Id,
            AAO_Basis__c = AAO_EvidenceFamily.STATE,
            AAO_Opportunity__c = opportunityId,
            AAO_Account__c = opp.AccountId,
            AAO_Subject_Type__c = 'Opportunity',
            AAO_Proposed_Verdict__c = r.verdict,
            AAO_Element_Coverage__c = AAO_Model.serializeCoverage(
                AAO_Model.newCoverage(new List<String>{ ELEMENT }, new List<String>())
            ),
            AAO_Interpretation__c = r.note +
                ', which is what the proposition asks for. Counted, not read: no model was ' +
                'asked, because a count is the only thing that can prove what is not there.',
            AAO_Stage__c = 'Adjudicated',
            AAO_Outcome__c = 'Pending',
            // Not a charter. Deterministic Apex, and the version is still attribution:
            // whoever reads this claim in a year needs to know which reader produced it and
            // which version of the counting rule it used.
            AAO_Charter__c = READER,
            AAO_Charter_Version__c = READER_VERSION,
            AAO_Publication_State__c = 'Live',
            AAO_Synthetic__c = synthetic
        );
        insert cand;

        // Through the same door route E uses. Every existing gate decides; nothing about
        // this route gets to skip one. The speaker gate records itself as not applicable
        // rather than being bypassed, which is a consequence of 47 worth watching.
        AAO_Commit.Result cr = AAO_Commit.commitCandidate(cand.Id, internalDomains);
        o.verdict = cr.answer == null ? r.verdict : cr.answer.AAO_Verdict__c;
        o.answerId = cr.answer == null ? null : cr.answer.Id;
        o.claimId = cr.claim == null ? null : cr.claim.Id;
        o.note = r.note + '. ' + cr.note;

        if (o.claimId == null) {
            // A gate refused it. That is the gate working, not this route failing.
            o.note = r.note + '. No claim written: ' + cr.note;
            return o;
        }

        o.basisRows = writeBasis(o.claimId, r.cited);

        // The forward half of the family law, checked now that the junction exists and
        // inside the same transaction, so a throw takes the claim back with it.
        AAO_EvidenceFamily.requireBasisRows(new Set<Id>{ o.claimId });
        return o;
    }

    /**
     * What the claim rested on, frozen. The snapshot is the cited fields and their values
     * at claim time; the lookup is the live row. Both, on purpose.
     */
    private static Integer writeBasis(
        Id claimId,
        List<ALTF__Contact_Map_Details__c> cited
    ) {
        List<AAO_Claim_Basis__c> rows = new List<AAO_Claim_Basis__c>();
        for (ALTF__Contact_Map_Details__c row : cited) {
            rows.add(
                new AAO_Claim_Basis__c(
                    AAO_Claim__c = claimId,
                    AAO_Cited_Type__c = 'Map_Row',
                    AAO_Cited_Map_Row__c = row.Id,
                    AAO_Covers_Element__c = ELEMENT,
                    AAO_Snapshot_Taken__c = System.now(),
                    // WHAT WAS CITED, not what was available. Only the fields the claim
                    // actually rested on.
                    AAO_Snapshot__c = JSON.serialize(
                        new Map<String, Object>{
                            'v' => 1,
                            'citedRowId' => row.Id,
                            'ALTF__Buyer_Role__c' => row.ALTF__Buyer_Role__c,
                            'ALTF__Contact__c' => row.ALTF__Contact__c,
                            'contactName' => row.ALTF__Contact__r == null
                                ? null
                                : row.ALTF__Contact__r.Name
                        }
                    )
                )
            );
        }
        insert rows;
        return rows.size();
    }

    // ============================================== f. then and now, one subquery

    /**
     * The exit check, and the sentence it exists to make true: editing the cited row
     * changes nothing about the claim, and the live lookup shows the new value.
     */
    public static String thenAndNow(Id opportunityId) {
        List<String> out = new List<String>();
        for (AAO_Claim_Basis__c b : [
            SELECT
                AAO_Cited_Type__c,
                AAO_Covers_Element__c,
                AAO_Snapshot__c,
                AAO_Snapshot_Taken__c,
                AAO_Cited_Map_Row__c,
                AAO_Cited_Map_Row__r.ALTF__Buyer_Role__c,
                AAO_Claim__r.Name,
                AAO_Claim__r.AAO_Verdict_After__c
            FROM AAO_Claim_Basis__c
            WHERE AAO_Claim__r.AAO_Opportunity__c = :opportunityId
        ]) {
            Map<String, Object> snap = (Map<String, Object>) JSON.deserializeUntyped(
                b.AAO_Snapshot__c
            );
            out.add(
                b.AAO_Claim__r.Name +
                ' [' +
                b.AAO_Covers_Element__c +
                '] ' +
                b.AAO_Cited_Type__c +
                '  THEN role=' +
                snap.get('ALTF__Buyer_Role__c') +
                '  NOW role=' +
                (b.AAO_Cited_Map_Row__r == null
                    ? '(row deleted)'
                    : b.AAO_Cited_Map_Row__r.ALTF__Buyer_Role__c)
            );
        }
        return out.isEmpty()
            ? 'no claim basis rows on this deal'
            : String.join(out, '\n  ');
    }
}
