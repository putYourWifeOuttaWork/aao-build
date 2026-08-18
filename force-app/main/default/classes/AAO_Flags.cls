/**
 * Day-one red. The raise path the Flag object has been waiting for since session 2.
 *
 * THE RULE. Every gating proposition stands red from the moment the deal exists. Nothing
 * raises it, because it was never down. `AAO_Raised_At__c` is opportunity creation, not the
 * moment this code ran, which is what makes age mean "how long has this deal been open
 * without an answer" rather than "how long since we noticed".
 *
 * Establishment of TRUE clears it. FALSE holds it and changes its cause to
 * `Established_False`, because a gating condition that is actively false is worse than one
 * nobody has evidence for, and a count that treated them the same would be measuring the
 * wrong thing. UNVERIFIED holds it unchanged: partial evidence is not establishment.
 *
 * WHY THIS IS NOT A TRIGGER ON OPPORTUNITY, which is what "raise on deal creation" sounds
 * like it wants. Opportunity is a standard object and the standing constraint is absolute:
 * no Apex trigger on any object we do not own. So raising is called explicitly by the paths
 * that create deals, and `raiseFor` is idempotent so calling it twice is free. In production
 * the caller is whatever provisions a deal into AAO. That is a real difference from the
 * design's "on creation" wording and it is recorded rather than glossed.
 *
 * Methodological flags clear on evidence only, never on acknowledgement. Nothing here
 * accepts a gesture.
 */
public class AAO_Flags {
    /** The day-one cause: a gating proposition with nothing established yet. */
    public static final String CAUSE_UNMET = 'Gating_Unmet';
    /** The worse case: evidence established the gating condition as false. */
    public static final String CAUSE_FALSE = 'Established_False';

    // ============================================================================ raise

    /**
     * Every gating contract, on every opportunity given, raised red as at deal creation.
     * Idempotent: an opportunity that already carries a flag for a contract gets nothing.
     *
     * Called on deal setup and again whenever discovery adds a gating contract, because a
     * rubric that gains a gating proposition gains it for deals that already exist.
     */
    /** The product path: the org's current questions. */
    public static Integer raiseFor(Set<Id> opportunityIds) {
        return raiseFor(opportunityIds, false);
    }

    public static Integer raiseFor(Set<Id> opportunityIds, Boolean synthetic) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return 0;
        }

        // SCOPED TO THE APPLICABLE SET. Not a detail: an unscoped read gave every deal
        // four reds where two were its own, because the org held a seeded fixture and a
        // derived rubric at the same time. Session 17 settled the discriminator: the
        // product's questions are the unmarked ones, and a demo or test entry says so at
        // the call site rather than being guessed at here.
        List<AAO_Evidence_Contract__c> gating = new List<AAO_Evidence_Contract__c>();
        for (AAO_Evidence_Contract__c ec : AAO_Rubric.inventory(synthetic)) {
            if (ec.AAO_Gating__c == true) {
                gating.add(ec);
            }
        }
        if (gating.isEmpty()) {
            return 0;
        }

        Map<Id, Opportunity> opps = new Map<Id, Opportunity>(
            [SELECT Id, AccountId, CreatedDate FROM Opportunity WHERE Id IN :opportunityIds]
        );
        if (opps.isEmpty()) {
            return 0;
        }

        // What already stands, so this can be called as often as anyone likes.
        Set<String> already = new Set<String>();
        for (AAO_Flag__c f : [
            SELECT AAO_Opportunity__c, AAO_Evidence_Contract__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c IN :opportunityIds AND AAO_Type__c = 'Methodological'
        ]) {
            already.add(f.AAO_Opportunity__c + '|' + f.AAO_Evidence_Contract__c);
        }

        List<AAO_Flag__c> raise = new List<AAO_Flag__c>();
        for (Opportunity o : opps.values()) {
            for (AAO_Evidence_Contract__c ec : gating) {
                if (already.contains(o.Id + '|' + ec.Id)) {
                    continue;
                }
                raise.add(
                    new AAO_Flag__c(
                        AAO_Opportunity__c = o.Id,
                        AAO_Account__c = o.AccountId,
                        AAO_Evidence_Contract__c = ec.Id,
                        AAO_Type__c = 'Methodological',
                        AAO_State__c = 'Standing',
                        AAO_Cause__c = CAUSE_UNMET,
                        // Deal creation, not now. Age is how long this deal has stood
                        // without an answer, and the trigger would otherwise stamp the
                        // moment this code happened to run.
                        AAO_Raised_At__c = o.CreatedDate
                    )
                );
            }
        }
        if (raise.isEmpty()) {
            return 0;
        }
        insert raise;
        return raise.size();
    }

    // ========================================================================== clear

    /**
     * Called by commit once an answer has been written. TRUE clears; FALSE holds with a
     * changed cause; anything else holds unchanged.
     *
     * Deliberately re-reads rather than trusting a passed verdict, so there is one place
     * that decides and it is the answer row itself.
     */
    public static void reconcile(Id opportunityId, Id contractId) {
        if (opportunityId == null || contractId == null) {
            return;
        }
        List<AAO_Flag__c> flags = [
            SELECT Id, AAO_State__c, AAO_Cause__c, AAO_Cleared_At__c, AAO_Answer__c
            FROM AAO_Flag__c
            WHERE
                AAO_Opportunity__c = :opportunityId
                AND AAO_Evidence_Contract__c = :contractId
                AND AAO_Type__c = 'Methodological'
                AND AAO_State__c != 'Cleared'
        ];
        if (flags.isEmpty()) {
            return;
        }
        List<AAO_Answer__c> answers = [
            SELECT Id, AAO_Verdict__c
            FROM AAO_Answer__c
            WHERE
                AAO_Opportunity__c = :opportunityId
                AND AAO_Evidence_Contract__c = :contractId
                AND AAO_Superseded_By__c = null
            LIMIT 1
        ];
        if (answers.isEmpty()) {
            return;
        }
        String verdict = answers[0].AAO_Verdict__c;

        List<AAO_Flag__c> changed = new List<AAO_Flag__c>();
        for (AAO_Flag__c f : flags) {
            if (verdict == 'TRUE') {
                f.AAO_State__c = 'Cleared';
                f.AAO_Cleared_At__c = System.now();
                f.AAO_Answer__c = answers[0].Id;
                changed.add(f);
            } else if (verdict == 'FALSE' && f.AAO_Cause__c != CAUSE_FALSE) {
                // Still standing, and now standing for a worse reason. A gating condition
                // established false is not the same as one nobody has evidence for, and a
                // count that treated them alike would measure the wrong thing.
                f.AAO_Cause__c = CAUSE_FALSE;
                f.AAO_Answer__c = answers[0].Id;
                changed.add(f);
            }
        }
        if (!changed.isEmpty()) {
            update changed;
        }
    }

    // ========================================================================= reading

    /** Standing reds on a deal, which is the number the demo watches fall. */
    public static Integer standing(Id opportunityId) {
        return [
            SELECT COUNT()
            FROM AAO_Flag__c
            WHERE
                AAO_Opportunity__c = :opportunityId
                AND AAO_Type__c = 'Methodological'
                AND AAO_State__c = 'Standing'
        ];
    }

    /**
     * Raise across every deal that has AAO rows, then reconcile each against what is
     * already established. The one-shot for bringing an org that predates the raise path
     * into a consistent state.
     */
    public static String backfill(Set<Id> opportunityIds, Boolean synthetic) {
        Integer raised = raiseFor(opportunityIds, synthetic);

        for (AAO_Flag__c f : [
            SELECT AAO_Opportunity__c, AAO_Evidence_Contract__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c IN :opportunityIds AND AAO_State__c != 'Cleared'
        ]) {
            reconcile(f.AAO_Opportunity__c, f.AAO_Evidence_Contract__c);
        }

        List<String> out = new List<String>{ 'raised ' + raised };
        for (Id oppId : opportunityIds) {
            out.add(
                '  ' +
                oppId +
                ' standing=' +
                standing(oppId) +
                ' cleared=' +
                [
                    SELECT COUNT()
                    FROM AAO_Flag__c
                    WHERE AAO_Opportunity__c = :oppId AND AAO_State__c = 'Cleared'
                ]
            );
        }
        return String.join(out, '\n');
    }
}