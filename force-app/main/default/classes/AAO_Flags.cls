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
    /**
     * The interpretation an inversion-law family voices when the words establish the NEGATIVE.
     * Read here rather than only at the reader, because a DENIED answer stands at verdict TRUE
     * and a flag path that consults the verdict alone reads a proven deal-killer as an answer.
     */
    public static final String DENIED = 'DENIED';

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
        // ===== EVERY ANSWER, NOT THE FIRST ONE THE DATABASE HAPPENED TO RETURN.
        //
        // `LIMIT 1` with no ordering was lawful while every gating contract had at most one
        // answer per deal, which was true of the seventeen: their subject is a person and their
        // gating flag is per deal, and no gating contract had ever been keyed per person.
        // **PROCESS BREAKS THAT.** Fifteen assessment questions land one answer PER PERSON, so a
        // deal-level flag now faces several answers about one question and an arbitrary pick
        // would clear a deal-killer on whichever row sorted first.
        List<AAO_Answer__c> answers = [
            SELECT Id, AAO_Verdict__c, AAO_Interpretation__c, AAO_Evidence_Occurred__c
            FROM AAO_Answer__c
            WHERE
                AAO_Opportunity__c = :opportunityId
                AND AAO_Evidence_Contract__c = :contractId
                AND AAO_Superseded_By__c = null
            ORDER BY AAO_Evidence_Occurred__c ASC NULLS FIRST, Id ASC
        ];
        if (answers.isEmpty()) {
            return;
        }

        // ===== A VOICED NO IS AN ESTABLISHMENT, AND IT MUST NOT CLEAR THE FLAG IT PROVES.
        //
        // **The defect this closes would have been silent and exactly backwards.** Under the
        // inversion law a DENIED answer stands at verdict TRUE - the establishment is real,
        // cited to the customer's own affirmative words about the negative, and true-or-nothing
        // is unbreached (128th, item 3). This method read the verdict alone. So the moment
        // `AAO_Gating__c` went true on the fifteen, a customer saying *"there is no budget
        // allocated for this"* would have CLEARED the budget deal-killer, on a TRUE, for a
        // defensible reason, and the one condition the flag exists to surface would have
        // disappeared at the moment it was proven.
        //
        // Found by reading the two mechanisms side by side before populating rather than after,
        // which is what the 128th's item 7 asked for.
        //
        // **DENIED OUTRANKS AFFIRMED, and that is the 120th's ruling rather than a tiebreak I
        // invented:** a voiced no *"flags red immediately at any stage"*. So one person's yes
        // does not undo another's no. Where both stand the red stands and the disagreement is
        // real signal - the contention family is where that belongs, and it is not built here.
        Boolean anyDenied = false;
        Boolean anyAffirmed = false;
        AAO_Answer__c deniedRow = null;
        AAO_Answer__c affirmedRow = null;
        for (AAO_Answer__c a : answers) {
            if (a.AAO_Verdict__c == 'FALSE') {
                anyDenied = true;
                if (deniedRow == null) { deniedRow = a; }
                continue;
            }
            if (a.AAO_Verdict__c != 'TRUE') {
                // UNVERIFIED holds everything unchanged. Partial evidence is not establishment.
                continue;
            }
            if (a.AAO_Interpretation__c == DENIED) {
                anyDenied = true;
                if (deniedRow == null) { deniedRow = a; }
            } else {
                anyAffirmed = true;
                if (affirmedRow == null) { affirmedRow = a; }
            }
        }

        String verdict = anyDenied ? 'FALSE' : (anyAffirmed ? 'TRUE' : null);
        AAO_Answer__c decidedBy = anyDenied ? deniedRow : affirmedRow;
        if (verdict == null) {
            return;
        }

        List<AAO_Flag__c> changed = new List<AAO_Flag__c>();
        for (AAO_Flag__c f : flags) {
            if (verdict == 'TRUE') {
                f.AAO_State__c = 'Cleared';
                f.AAO_Cleared_At__c = System.now();
                f.AAO_Answer__c = decidedBy.Id;
                changed.add(f);
            } else if (verdict == 'FALSE' && f.AAO_Cause__c != CAUSE_FALSE) {
                // Still standing, and now standing for a worse reason. A gating condition
                // established false is not the same as one nobody has evidence for, and a
                // count that treated them alike would measure the wrong thing.
                f.AAO_Cause__c = CAUSE_FALSE;
                f.AAO_Answer__c = decidedBy.Id;
                changed.add(f);
            }
        }
        if (!changed.isEmpty()) {
            update changed;
        }
    }

    // ============================================================ the by-stage read · (c)

    /**
     * ===== WHAT MAKES A STANDING FLAG READ RED RIGHT NOW.
     *
     * The hundred-twentieth stamp ruled two shapes of "no" and they red on different clocks:
     *
     *   VOICED NO         the customer affirmatively stated the negative, cited to their words.
     *                     **Hard red at ANY stage.** Cause `Established_False`.
     *   NEVER ESTABLISHED absence, and absence is not evidence. Reds ONLY past the question's
     *                     BY-STAGE marker. Cause `Gating_Unmet`. **A null marker never flags** -
     *                     the 125th's ratified semantics, null is never read as stage zero.
     *
     * **THE FLAG ROW EXISTS FROM DAY ONE EITHER WAY, and its redness is a READ.** Two reasons,
     * and the second is the load-bearing one. `AAO_Raised_At__c` is deal creation, so age means
     * *how long has this deal stood without an answer* rather than *how long since we noticed* -
     * creating the row late would destroy that. And a stage can move BACKWARDS; a design that
     * created rows on the way past would have to delete them on the way back, and this system
     * does not delete. So nothing is written when a stage moves, and this method answers the
     * question at the moment somebody asks it - which is the 129th's item 5 ruling for the
     * counts, applied to the flags for the same reason.
     */
    public class Red {
        public Id flagId;
        public Id contractId;
        public String code;
        public String question;
        public String cause;
        /** True where this flag reads red at the deal's CURRENT stage. */
        public Boolean isRed;
        /** Plain words: why it is red, or why it is lawfully quiet. */
        public String because;
        public Decimal marker;
        public Integer stageOrdinal;
    }

    /**
     * Every standing methodological flag on the deal, each answered red or quiet with its reason.
     * Read-only: no DML anywhere in it.
     */
    public static List<Red> redsOn(Id opportunityId) {
        List<Red> out = new List<Red>();
        if (opportunityId == null) {
            return out;
        }
        Integer ordinal = stageOrdinalOf(opportunityId);
        Map<String, Decimal> markerByCode = markers();

        for (AAO_Flag__c f : [
            SELECT Id, AAO_Cause__c, AAO_Evidence_Contract__c,
                   AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                   AAO_Evidence_Contract__r.AAO_Proposition_Short__c,
                   AAO_Evidence_Contract__r.AAO_Contract_State__c
            FROM AAO_Flag__c
            WHERE AAO_Opportunity__c = :opportunityId
              AND AAO_Type__c = 'Methodological'
              AND AAO_State__c = 'Standing'
              // A DEAL-KILLER TEST THAT NO LONGER EXISTS CANNOT KILL A DEAL. A flag whose
              // contract has been superseded or retired stays on the row - nothing is deleted
              // and the record of having been raised is history - but it is not READ as a
              // standing condition, because the question behind it is no longer asked. Clearing
              // it instead would claim evidence answered it, which is a different and false
              // thing to say.
              AND AAO_Evidence_Contract__r.AAO_Contract_State__c NOT IN :AAO_ContractState.DEAD
            ORDER BY AAO_Evidence_Contract__r.AAO_Proposition_Code__c
        ]) {
            Red r = new Red();
            r.flagId = f.Id;
            r.contractId = f.AAO_Evidence_Contract__c;
            r.code = f.AAO_Evidence_Contract__r == null
                ? null
                : f.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
            r.question = f.AAO_Evidence_Contract__r == null
                ? null
                : f.AAO_Evidence_Contract__r.AAO_Proposition_Short__c;
            r.cause = f.AAO_Cause__c;
            r.marker = markerByCode.get(r.code);
            r.stageOrdinal = ordinal;

            if (f.AAO_Cause__c == CAUSE_FALSE) {
                r.isRed = true;
                r.because =
                    'The customer voiced the negative and it stands as an establishment in ' +
                    'their own words. A voiced no reds at any stage.';
            } else if (r.marker == null) {
                // NULL IS NEVER STAGE ZERO. Absence of a marker is absence of a rule, and a
                // rule nobody wrote does not get invented at read time.
                r.isRed = false;
                r.because =
                    'Never established, and this question carries no by-stage marker, so ' +
                    'nothing says when not knowing becomes a deal-killer. Quiet, lawfully.';
            } else if (ordinal == null) {
                // The deal's stage could not be ordered against the org's own stages. Blank
                // beats wrong: a red raised on a stage we could not read is a red nobody can act on.
                r.isRed = false;
                r.because =
                    'Never established, and this deal\'s stage could not be ordered against ' +
                    'the org\'s open stages, so the marker cannot be compared. Quiet, and the ' +
                    'reason is ours rather than the deal\'s.';
            } else if (ordinal >= r.marker) {
                r.isRed = true;
                r.because =
                    'Unknown past stage ' + r.marker.setScale(0) + '. Nobody has established ' +
                    'this and the deal has reached the stage by which it should have been known.';
            } else {
                r.isRed = false;
                r.because =
                    'Not established yet, and the deal is at stage ' + ordinal + ' against a ' +
                    'marker of ' + r.marker.setScale(0) + '. Unknown here is quiet and lawful.';
            }
            out.add(r);
        }
        return out;
    }

    /** How many of them actually read red right now. */
    public static Integer redCount(Id opportunityId) {
        Integer n = 0;
        for (Red r : redsOn(opportunityId)) {
            if (r.isRed == true) {
                n++;
            }
        }
        return n;
    }

    /**
     * The by-stage markers, ours, seeded and ORG-OVERRIDABLE, keyed to the question code.
     * `AAO_Org_Override__c` wins where an org has moved the marker, which is the whole reason
     * that field is a number on this type.
     */
    public static Map<String, Decimal> markers() {
        Map<String, Decimal> out = new Map<String, Decimal>();
        for (AAO_Assessment_Stage__mdt m : [
            SELECT AAO_Question_Code__c, AAO_By_Stage__c, AAO_Org_Override__c
            FROM AAO_Assessment_Stage__mdt
            WHERE AAO_Question_Code__c != null
        ]) {
            out.put(
                m.AAO_Question_Code__c,
                m.AAO_Org_Override__c != null ? m.AAO_Org_Override__c : m.AAO_By_Stage__c
            );
        }
        return out;
    }

    /**
     * THE DEAL'S STAGE AS A NUMBER, read from the ORG rather than assumed from a name.
     *
     * Our marker is an ordinal and a customer org carries stage NAMES and an order, never a
     * number - LAW #1's shape at the stage plane. So the ordinal is the deal's position among
     * the org's ACTIVE OPEN stages ordered by `SortOrder`: whatever an org calls its stages, the
     * third open one is the third. Closed stages are excluded because a closed deal is not
     * somewhere along the way, and inactive ones because they are not part of the path any more.
     *
     * Null where the deal's stage is not among them, which the caller reads as *do not flag*.
     */
    /**
     * ===== THE AXIS IS THE VENDOR'S, AND IT WAS OURS ALL ALONG.
     *
     * The hundred-sixty-fifth, at Matthew's refusal of the picklist plan: *"Salesforce Oppty
     * stage should not have any bearing here."* He was right. The methodology's stage axis is
     * five `ALTF__Sales_Process_Stage__c` rows under the process - Qualify 1 through Commit 5,
     * each carrying its own `ALTF__SortOrder__c` - and every one of them carries OUR seed's
     * AltifyId. The build spent a week trying to conjure an axis out of the org's picklist that
     * our own seed had already created and left standing.
     *
     * `Opportunity.StageName` is DOWNSTREAM of that axis in an SPM org: the vendor re-asserts
     * it from its own source of truth when a human works the Sales Process Manager, which is
     * why both historic "reverts" sat beside a human in that UI while every API write on a
     * quiet deal held. Nothing was sabotaging our stage writes; we were writing to a projection.
     *
     * ===== FEATURE-DETECTED BY THE PREDICATE, NEVER BY A VERSION CHECK.
     *
     * Wrapper EXISTENCE is not the predicate - a wrapper materializes for any deal any Altify
     * surface touched, and eight of this org's ten hold a null stage pointer. The predicate is
     * the pointer itself. Where it is null, or where there is no wrapper at all, the org's own
     * open stages remain the axis: that is the LAW #1 fallback for an org without Altify or
     * without SPM, and it is the path this method has always taken.
     */
    public static Integer stageOrdinalOf(Id opportunityId) {
        if (opportunityId == null) {
            return null;
        }
        // ===== THE LOOKUP IS NOT THE DURABLE FIELD. THE NAME IS.
        //
        // Measured, minutes after this method first shipped reading the lookup: writer (b)
        // projected `PROBLEM = Yes` onto deal 2, the vendor recomputed, the deal SATISFIED
        // Qualify's mandatory gate and ADVANCED to Discover - and on that advance the vendor
        // NULLED `ALTF__Sales_Process_Stage__c` while leaving
        // `ALTF__Sales_Process_Stage_Name__c` reading `Discover`. A predicate resting on the
        // lookup would therefore report NO AXIS on exactly the deals that are moving through
        // the process, which is the worst possible time to lose it.
        //
        // So the name is read first and the lookup second. Both resolve to the same ordinal
        // through the process's own stage rows; the name simply survives the advance.
        List<ALTF__Opportunity__c> wrappers = [
            SELECT ALTF__Sales_Process_Stage__c,
                   ALTF__Sales_Process_Stage__r.ALTF__SortOrder__c,
                   ALTF__Sales_Process_Stage_Name__c
            FROM ALTF__Opportunity__c
            WHERE ALTF__Opportunity__c = :opportunityId
            ORDER BY CreatedDate ASC
        ];
        Set<String> wanted = new Set<String>();
        for (ALTF__Opportunity__c w : wrappers) {
            if (w.ALTF__Sales_Process_Stage__r != null &&
                    w.ALTF__Sales_Process_Stage__r.ALTF__SortOrder__c != null) {
                return w.ALTF__Sales_Process_Stage__r.ALTF__SortOrder__c.intValue();
            }
            if (String.isNotBlank(w.ALTF__Sales_Process_Stage_Name__c)) {
                wanted.add(w.ALTF__Sales_Process_Stage_Name__c);
            }
        }
        if (!wanted.isEmpty()) {
            for (ALTF__Sales_Process_Stage__c st : [
                SELECT Name, ALTF__SortOrder__c FROM ALTF__Sales_Process_Stage__c
                WHERE Name IN :wanted AND ALTF__SortOrder__c != null
                ORDER BY ALTF__SortOrder__c ASC
            ]) {
                return st.ALTF__SortOrder__c.intValue();
            }
        }

        List<Opportunity> opps = [
            SELECT StageName FROM Opportunity WHERE Id = :opportunityId LIMIT 1
        ];
        if (opps.isEmpty() || String.isBlank(opps[0].StageName)) {
            return null;
        }
        Integer i = 0;
        for (OpportunityStage st : [
            SELECT MasterLabel
            FROM OpportunityStage
            WHERE IsActive = true AND IsClosed = false
            ORDER BY SortOrder ASC NULLS LAST
        ]) {
            i++;
            if (st.MasterLabel == opps[0].StageName) {
                return i;
            }
        }
        return null;
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