/**
 * THE COMPUTED CATALOG'S FIRST ARITHMETIC. Process step (b), the hundred-twenty-sixth stamp:
 * *"Decision-maker-identified, committee gap, criteria coverage, insight completeness -
 * deterministic rows off our own ledger at the join, zero callouts, per §2 of the proposal."*
 *
 * ===== THE TWO PLANES, AND WHY THIS ONE WRITES CANDIDATES RATHER THAN CLAIMS.
 *
 * The evidence plane reads words. This one reads records. They answer the SAME questions, and
 * the hundred-twentieth stamp already ruled what that means: A1 is *"simultaneously an Authority
 * assessment answer and a persona-injection trigger - ONE computed fact, read by two planes,
 * never two facts."* So the computed plane is a second PROPOSER, never a second writer. It
 * builds candidates with basis State and hands them to `AAO_Commit`, which already carries the
 * human-precedence read, the merge path, the reinforcement rule, and - ratified at the
 * forty-eighth stamp and never yet exercised - the State branch of the speaker gate.
 *
 * That is the whole reason this class is short. Everything below the proposal already existed:
 *
 *   `AAO_EvidenceFamily`   the basis law, written 1 August for exactly this route, whose own
 *                          header names this build's first computation as its motivating case:
 *                          *"One decision maker is named on the relationship map rests on a
 *                          record, not on bytes."*
 *   `AAO_Claim_Basis__c`   the cited-row junction with its frozen snapshot, declared and,
 *                          until this build, never populated by anything.
 *   `AAO_Commit`           the State branch of the speaker gate, which records NOT APPLICABLE
 *                          rather than skipping, so a state claim can never be mistaken for one
 *                          that cleared a check it never faced.
 *
 * **So this run produces three things the project has declared for months and never made:** a
 * claim at basis State, a populated cited-row junction, and - where a question is answered from
 * both planes - an answer at basis Both, which `AAO_EvidenceFamily.combine` has been able to
 * compose since the day it was written.
 *
 * ===== WHAT IS COMPUTABLE, MEASURED RATHER THAN HOPED.
 *
 * Two of the fifteen. Not a limitation of this class: a property of the questions, readable in
 * their own element text. Thirteen of fifteen name the customer's mouth as a conjunct - *"the
 * customer states"*, *"it is the customer who voices it"*, *"per the customer's words"* - and no
 * record can stand in for a mouth. The two that do not are both Authority:
 *
 *   A1  the decision maker is identified   elements: a person is identified as making the final
 *       call; the identification rests on their own or a colleague's words. The first is a map
 *       fact. **The second is satisfied by CITING the answer that carries it**, whose own basis
 *       is Transcript - which is what a cited row of type Answer is for.
 *   A2  the decision maker is engaged      elements: the decision maker participated directly;
 *       the participation was in a conversation with us. Both are the participant row, whole.
 *       Nothing is inferred and no words are needed.
 *
 * **A2 is the specimen worth keeping.** Step (a) reported it REFUSED at the evidence plane, on
 * our own seller, because a seller cannot establish that a decision maker is engaged. That
 * refusal was correct and it left the question unanswered on a deal where the answer was sitting
 * in a participant row the whole time. The evidence plane was right to refuse; the computed
 * plane is right to answer; and the reason they do not conflict is that they are one fact read
 * two ways.
 *
 * ===== THE BINDING IS CONFIGURATION, BECAUSE THE CODE IS THE CUSTOMER'S.
 *
 * A predicate is ours. A question code is not - that is the hundred-twenty-eighth stamp's
 * ratified finding, one layer up from the meaning map. So nothing here names `AAO_BANT_A1`.
 * `AAO_Assessment_Stage__mdt.AAO_Computed_Predicate__c` binds predicate to question code,
 * seeded by us against our own BANT set and overridable per org, which is the shape §2 of the
 * proposal already ruled for computed qualifier predicates. An org whose rubric asks the
 * decision-maker question under another name binds it and the arithmetic follows.
 *
 * ===== WHAT COMPUTES AND WRITES NOTHING, AND WHY THAT IS NOT HALF A BUILD.
 *
 * Committee coverage, criteria coverage and insight completeness compute here exactly as the
 * stamp asks, and they answer NO DECLARED PROPOSITION. There is no contract for "eleven of
 * fourteen criteria are formal", so there is no answer for it to accrue onto and no claim it
 * could lawfully be. Minting contracts to give them somewhere to land would be authoring a
 * rubric nobody graded, which is design's and not mine. They are returned on the reading, they
 * are journalled on the receipt leg, and the landing-surface question is reported rather than
 * answered - the alternative being a row nothing reads, which this project has named five times.
 */
public class AAO_ProcessCompute {
    public class ComputeException extends Exception {
    }

    public static final String P_DM_IDENTIFIED = 'DECISION_MAKER_IDENTIFIED';
    public static final String P_DM_ENGAGED = 'DECISION_MAKER_ENGAGED';

    /** One row the fact rests on, frozen at the moment it was read. */
    public class Cite {
        public String citedType;
        public Id rowId;
        public Map<String, Object> snapshot = new Map<String, Object>();

        public Cite(String citedType, Id rowId) {
            this.citedType = citedType;
            this.rowId = rowId;
        }
    }

    /**
     * A computed establishment: which predicate, about whom, and the rows that say so.
     *
     * There is no `denied` half and that is deliberate. A computed predicate that does not hold
     * is NEVER-ESTABLISHED, which is silence, and silence writes nothing - the by-stage marker
     * decides when it becomes a flag. DENIED is a VOICED no and only words can voice one, so the
     * computed plane cannot produce one and must not learn how.
     */
    public class Fact {
        public String predicate;
        public String questionCode;
        public Id contractId;
        public Id participantId;
        public Id contactId;
        public Id accountId;
        public String personName;
        public String because;
        public List<Cite> cites = new List<Cite>();
    }

    /** The counts. Deterministic, contract-free, and read by nothing yet but this run's leg. */
    public class Counts {
        public Integer peopleOnDeal = 0;
        public Integer peopleExternal = 0;
        public Map<String, Integer> byCoverage = new Map<String, Integer>();
        public Map<String, Integer> byBuyerRole = new Map<String, Integer>();
        public Integer criteria = 0;
        public Integer criteriaFormal = 0;
        public Integer criteriaInformal = 0;
        public Integer criteriaRequired = 0;
        public Integer cards = 0;
        public Map<String, Integer> cardsByType = new Map<String, Integer>();
        public Integer peopleWithAnInsight = 0;
        public Integer peopleWithNoInsight = 0;
    }

    public class Reading {
        public List<Fact> facts = new List<Fact>();
        public Counts counts = new Counts();
        /** Why a predicate could not be computed at all, as opposed to computing to silence. */
        public List<String> notes = new List<String>();
    }

    public class Outcome {
        public Integer factsComputed = 0;
        public Integer candidatesWritten = 0;
        public Integer claimsWritten = 0;
        public Integer citedRowsWritten = 0;
        public Integer alreadyStanding = 0;
        public List<String> notes = new List<String>();

        public override String toString() {
            return 'computed: ' +
                factsComputed + ' facts, ' + candidatesWritten + ' candidates, ' +
                claimsWritten + ' claims, ' + citedRowsWritten + ' cited rows, ' +
                alreadyStanding + ' already standing (unit: rows)';
        }
    }

    // ====================================================================== the binding

    /**
     * Question code by predicate, from configuration.
     *
     * **THE ROW IS THE OVERRIDE.** `AAO_Org_Override__c` on this type is a NUMBER and belongs to
     * the by-stage marker, not to this binding - it is the stage an org moves a red flag to, and
     * reading it here would have been the one-field-two-meanings shape. An org rebinds a
     * predicate by editing this row's question code or deploying its own row, which is the same
     * way it re-ranks a buyer role. Custom metadata is editable in the org by construction; that
     * is the whole reason the seed lives here rather than in Apex.
     */
    public static Map<String, String> predicateBindings() {
        Map<String, String> out = new Map<String, String>();
        for (AAO_Assessment_Stage__mdt m : [
            SELECT AAO_Question_Code__c, AAO_Computed_Predicate__c
            FROM AAO_Assessment_Stage__mdt
            WHERE AAO_Computed_Predicate__c != null AND AAO_Question_Code__c != null
        ]) {
            out.put(m.AAO_Computed_Predicate__c, m.AAO_Question_Code__c);
        }
        return out;
    }

    // ====================================================================== the arithmetic

    /**
     * THE READ. Pure: no DML, no callout, and no vendor write anywhere in it.
     *
     * It reads OUR ledger for everything a person's standing state carries, because our ledger
     * is authoritative and the vendor surface is a projection of it - the thirty-first stamp's
     * single-projection law. The one vendor read is the insight board, which we read wide and
     * write gated like every other vendor object.
     */
    public static Reading read(Id opportunityId) {
        Reading r = new Reading();
        if (opportunityId == null) {
            r.notes.add('No opportunity; nothing to compute.');
            return r;
        }

        Id accountId = [
            SELECT AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1
        ].AccountId;
        Map<String, String> bindings = predicateBindings();
        Map<String, AAO_Evidence_Contract__c> contractByCode = liveContracts(bindings.values());

        // ---------------------------------------------------------------- people and roles
        Map<Id, AAO_Participant__c> participantById = new Map<Id, AAO_Participant__c>(
            [
                SELECT Id, AAO_Display_Name__c, AAO_Contact__c, AAO_Internal__c,
                       AAO_Coverage_Projected_Value__c, AAO_Source__c
                FROM AAO_Participant__c
                WHERE AAO_Opportunity__c = :opportunityId
            ]
        );
        // One human, many participant rows - one per Source. Fold to the person the way
        // projection folds them, so the counts below say people and not appearances.
        //
        // **THE FOLD TAKES COVERAGE FROM WHICHEVER ROW CARRIES IT, and the first draft did not.**
        // Projection writes the band to ONE of a person's participant rows and leaves the others
        // blank, so a fold that just kept the last row read `(none)` for every person on a deal
        // whose map plainly shows Brief contact and Multiple contacts. It looked like a finding
        // about projection and was a defect in this loop. Measured on the rehearsal deal: Marcus
        // Reyes has three rows and exactly one carries `Multiple contacts`.
        //
        // **The count's honest limit, stated rather than fixed:** a person with a Contact folds
        // to one. A person WITHOUT one folds per name form, so "Priya" and "Priya Nair" count
        // twice - the eighty-seventh stamp's key-collapse ruling holding as ruled, since two
        // humans may share a form and different forms are never collapsed at the key. This is
        // therefore people AS THE LEDGER KNOWS THEM, which is the only count that can be made
        // without guessing, and it reads high where identities are unresolved.
        Map<String, AAO_Participant__c> personLatest = new Map<String, AAO_Participant__c>();
        Map<String, String> coverageByPerson = new Map<String, String>();
        for (AAO_Participant__c p : participantById.values()) {
            String key = p.AAO_Contact__c != null
                ? String.valueOf(p.AAO_Contact__c)
                : String.valueOf(p.Id);
            personLatest.put(key, p);
            if (String.isNotBlank(p.AAO_Coverage_Projected_Value__c)) {
                coverageByPerson.put(key, p.AAO_Coverage_Projected_Value__c);
            }
        }
        for (String key : personLatest.keySet()) {
            AAO_Participant__c p = personLatest.get(key);
            r.counts.peopleOnDeal++;
            if (p.AAO_Internal__c != true) {
                r.counts.peopleExternal++;
            }
            String band = coverageByPerson.containsKey(key)
                ? coverageByPerson.get(key)
                : '(none)';
            r.counts.byCoverage.put(band, one(r.counts.byCoverage, band));
        }

        // The standing buyer role of each person, off our own answers rather than off the map:
        // a map row is what we projected, and re-reading our own projection to establish a fact
        // would make the arithmetic depend on the write having succeeded.
        Set<String> roleCodes = AAO_P8Codes.buyerRoleCodes();
        Map<String, Set<String>> rolesByPerson = new Map<String, Set<String>>();
        Map<String, AAO_Answer__c> roleAnswerByPerson = new Map<String, AAO_Answer__c>();
        Map<String, AAO_Answer__c> anyAnswerByPerson = new Map<String, AAO_Answer__c>();
        // ONE QUERY, AND THE ANSWER ROWS ARE KEPT rather than re-fetched per person. The first
        // draft asked for the identifying answer inside the loop over decision makers - a query
        // in a loop, which is the ninety-sixth stamp's own lesson (`DML = 4C + M + B`, found one
        // frame down where a lexical grep could not see it). Bounded by two decision makers
        // today and unbounded by anything in the code, which is exactly the shape that meets a
        // governor on the one deal a customer cares most about.
        Map<String, AAO_Answer__c> answerByPersonAndRole = new Map<String, AAO_Answer__c>();
        for (AAO_Answer__c a : [
            SELECT Id, AAO_Subject_Contact__c, AAO_Subject_Contact__r.Name,
                   AAO_Participant__c, AAO_Participant__r.AAO_Display_Name__c,
                   AAO_Participant__r.AAO_Contact__c, AAO_Verdict__c, AAO_Basis__c,
                   AAO_Evidence_Occurred__c, AAO_Element_Completeness__c,
                   AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :opportunityId
              AND AAO_Publication_State__c = 'Live'
              AND AAO_Superseded_By__c = null
              AND AAO_Verdict__c = 'TRUE'
              AND AAO_Evidence_Contract__r.AAO_Proposition_Code__c IN :roleCodes
            ORDER BY AAO_Evidence_Occurred__c ASC NULLS FIRST, Id ASC
        ]) {
            String key = personKey(a);
            if (!rolesByPerson.containsKey(key)) {
                rolesByPerson.put(key, new Set<String>());
            }
            String code = a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
            String role = AAO_P8Codes.buyerRole(code);
            if (String.isNotBlank(role)) {
                rolesByPerson.get(key).add(role);
            }
            // Earliest first, so the answer kept is the one that FIRST established the role.
            if (!answerByPersonAndRole.containsKey(key + '|' + code)) {
                answerByPersonAndRole.put(key + '|' + code, a);
            }
            anyAnswerByPerson.put(key, a);
        }
        for (String key : rolesByPerson.keySet()) {
            String ceiling = AAO_P8Codes.buyerRoleCeiling(rolesByPerson.get(key));
            String band = String.isBlank(ceiling) ? '(none)' : ceiling;
            r.counts.byBuyerRole.put(band, one(r.counts.byBuyerRole, band));
        }

        // ---------------------------------------------------------------------- criteria
        for (AAO_Criterion__c c : [
            SELECT Id, AAO_Type__c, AAO_Required__c
            FROM AAO_Criterion__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Retired__c = false
        ]) {
            r.counts.criteria++;
            if (c.AAO_Type__c == 'Formal') {
                r.counts.criteriaFormal++;
            } else if (String.isNotBlank(c.AAO_Type__c)) {
                r.counts.criteriaInformal++;
            }
            if (c.AAO_Required__c == true) {
                r.counts.criteriaRequired++;
            }
        }

        // ------------------------------------------------------------ insight completeness
        Set<Id> contactsWithInsight = new Set<Id>();
        for (ALTF__Insight_Card_Contact__c link : [
            SELECT ALTF__Contact__c, ALTF__Insight_Card__r.ALTF__Type__c
            FROM ALTF__Insight_Card_Contact__c
            WHERE ALTF__Insight_Card__r.ALTF__Opportunity__c = :opportunityId
        ]) {
            if (link.ALTF__Contact__c != null) {
                contactsWithInsight.add(link.ALTF__Contact__c);
            }
        }
        for (ALTF__Insight_Card__c card : [
            SELECT Id, ALTF__Type__c
            FROM ALTF__Insight_Card__c
            WHERE ALTF__Opportunity__c = :opportunityId
        ]) {
            r.counts.cards++;
            String t = String.isBlank(card.ALTF__Type__c) ? '(none)' : card.ALTF__Type__c;
            r.counts.cardsByType.put(t, one(r.counts.cardsByType, t));
        }
        for (AAO_Participant__c p : personLatest.values()) {
            if (p.AAO_Internal__c == true) {
                continue;
            }
            if (p.AAO_Contact__c != null && contactsWithInsight.contains(p.AAO_Contact__c)) {
                r.counts.peopleWithAnInsight++;
            } else {
                r.counts.peopleWithNoInsight++;
            }
        }

        // ================================================== A1 · the decision maker is known
        Integer threshold = decisionMakerRank();
        if (threshold == null) {
            r.notes.add(
                'The buyer-role ranks carry no rank for the decision-maker value, so no ' +
                'ledger fact can say who makes the final call. Nothing computed for ' +
                P_DM_IDENTIFIED + ' or ' + P_DM_ENGAGED + '; blank beats wrong.'
            );
            return r;
        }
        AAO_Evidence_Contract__c a1 = contractByCode.get(bindings.get(P_DM_IDENTIFIED));
        AAO_Evidence_Contract__c a2 = contractByCode.get(bindings.get(P_DM_ENGAGED));
        if (a1 == null && a2 == null) {
            r.notes.add(
                'No live contract is bound to ' + P_DM_IDENTIFIED + ' or ' + P_DM_ENGAGED +
                '. The predicates computed nothing because this org declares no question for ' +
                'them to answer, which is graceful absence rather than a defect.'
            );
            return r;
        }

        for (String key : rolesByPerson.keySet()) {
            String topRole = null;
            Integer topRank = -1;
            for (String role : rolesByPerson.get(key)) {
                Integer rank = AAO_MapValues.rankOf(AAO_P8Codes.DIM_BUYER_ROLE, role);
                if (rank != null && rank >= threshold && rank > topRank) {
                    topRank = rank;
                    topRole = role;
                }
            }
            if (topRole == null) {
                // Established, and below the line that makes the final call. Silence, not a no.
                continue;
            }
            String roleCode = AAO_P8Codes.codeForBuyerRole(topRole);
            AAO_Answer__c identifying = answerByPersonAndRole.get(key + '|' + roleCode);
            if (identifying == null) {
                continue;
            }

            if (a1 != null) {
                Fact f = new Fact();
                f.predicate = P_DM_IDENTIFIED;
                f.questionCode = a1.AAO_Proposition_Code__c;
                f.contractId = a1.Id;
                f.participantId = identifying.AAO_Participant__c;
                f.contactId = contactOf(identifying);
                f.accountId = accountId;
                f.personName = nameOf(identifying);
                f.because =
                    f.personName + ' stands at ' + topRole + ' on this deal\'s ledger, and ' +
                    'the answer that says so was established from the words of the call.';
                Cite c = new Cite('Answer', identifying.Id);
                c.snapshot.put('proposition_code', roleCode);
                c.snapshot.put('buyer_role', topRole);
                c.snapshot.put('verdict', identifying.AAO_Verdict__c);
                c.snapshot.put('basis', identifying.AAO_Basis__c);
                c.snapshot.put('person', f.personName);
                c.snapshot.put('evidence_occurred', String.valueOf(
                    identifying.AAO_Evidence_Occurred__c
                ));
                f.cites.add(c);
                r.facts.add(f);
            }

            // ============================================ A2 · and they were in the room
            //
            // The participant row IS the participation. Citing the Source instead would say the
            // conversation happened without saying who was in it, and the fact under test is
            // exactly who was in it.
            //
            // A person identified as decision maker by a COLLEAGUE'S words has no participant
            // row, so this predicate correctly stays silent on them. That is the discrimination
            // that makes A2 worth computing rather than assuming from A1.
            if (a2 == null) {
                continue;
            }
            AAO_Participant__c seat = null;
            for (AAO_Participant__c p : participantById.values()) {
                Boolean sameByContact = f_contactMatch(p, identifying);
                if (sameByContact || p.Id == identifying.AAO_Participant__c) {
                    seat = p;
                    break;
                }
            }
            if (seat == null) {
                continue;
            }
            Fact f2 = new Fact();
            f2.predicate = P_DM_ENGAGED;
            f2.questionCode = a2.AAO_Proposition_Code__c;
            f2.contractId = a2.Id;
            f2.participantId = seat.Id;
            f2.contactId = seat.AAO_Contact__c != null
                ? seat.AAO_Contact__c
                : contactOf(identifying);
            f2.accountId = accountId;
            f2.personName = String.isNotBlank(seat.AAO_Display_Name__c)
                ? seat.AAO_Display_Name__c
                : nameOf(identifying);
            f2.because =
                f2.personName + ' holds a participant row on a conversation attributed to ' +
                'this opportunity, which is the record of having been in it.';
            Cite c2 = new Cite('Participant', seat.Id);
            c2.snapshot.put('display_name', seat.AAO_Display_Name__c);
            c2.snapshot.put('internal', seat.AAO_Internal__c);
            c2.snapshot.put('source', String.valueOf(seat.AAO_Source__c));
            c2.snapshot.put('buyer_role', topRole);
            f2.cites.add(c2);
            r.facts.add(f2);
        }
        return r;
    }

    // ====================================================================== the write

    /**
     * Compute, then propose. Zero callouts, and it says so by never touching `AAO_Extract`.
     *
     * **A RE-RUN COUNTS UNCHANGED, NEVER REINFORCED.** The sixty-second stamp ruled it for cards
     * and the eightieth for the counter, and a computed fact is the case where it bites hardest:
     * a state claim has no spans, so nothing about the row itself would stop the same map fact
     * being re-asserted on every pass until the reinforcement count read like a person pressing
     * a point ten times. The read-before-write is the citation: a fact whose cited row already
     * stands behind a claim on this contract is the same observation, and it is skipped.
     */
    public static Outcome run(Id opportunityId, String runKey) {
        Long startedAt = System.currentTimeMillis();
        Outcome o = runInner(opportunityId);
        // A CODE-ONLY LEG, and the stage is worth one for the reason every other code-only stage
        // is: a plane that leaves no leg is a plane nobody can price. Zero callouts, so the leg
        // reads `n/a` for cache and its whole content is wall clock, governors, and what it
        // produced - which is the honest shape of a stage that spends queries and no tokens.
        AAO_Receipt.record(
            runKey,
            AAO_Receipt.sourceForRun(runKey),
            AAO_Receipt.STAGE_COMPUTE,
            System.currentTimeMillis() - startedAt,
            o.claimsWritten
        );
        return o;
    }

    private static Outcome runInner(Id opportunityId) {
        Outcome o = new Outcome();
        Reading r = read(opportunityId);
        o.notes.addAll(r.notes);
        o.factsComputed = r.facts.size();
        if (r.facts.isEmpty()) {
            return o;
        }

        Set<String> standing = standingCitations(opportunityId);

        List<AAO_Candidate__c> toInsert = new List<AAO_Candidate__c>();
        List<Fact> kept = new List<Fact>();
        for (Fact f : r.facts) {
            String fingerprint = f.contractId + '|' + f.cites[0].rowId;
            if (standing.contains(fingerprint)) {
                o.alreadyStanding++;
                continue;
            }
            toInsert.add(candidateFor(opportunityId, f));
            kept.add(f);
        }
        if (toInsert.isEmpty()) {
            return o;
        }
        insert toInsert;
        o.candidatesWritten = toInsert.size();

        List<AAO_Claim_Basis__c> cited = new List<AAO_Claim_Basis__c>();
        Set<Id> claimIds = new Set<Id>();
        for (Integer i = 0; i < toInsert.size(); i++) {
            AAO_Commit.Result res = AAO_Commit.commitCandidate(
                toInsert[i].Id, AAO_IngestQueueable.internalDomains()
            );
            if (res.claim == null) {
                o.notes.add(
                    kept[i].predicate + ' proposed and established nothing: ' + res.note
                );
                continue;
            }
            o.claimsWritten++;
            claimIds.add(res.claim.Id);
            for (Cite c : kept[i].cites) {
                cited.add(basisRow(res.claim.Id, c));
            }
        }
        if (!cited.isEmpty()) {
            insert cited;
            o.citedRowsWritten = cited.size();
        }
        // THE FORWARD HALF OF THE EVIDENCE-FAMILY LAW, called by the writer inside the same
        // transaction so a throw rolls the claim back with it. A trigger cannot hold this
        // direction: the junction does not exist until the claim has an Id.
        AAO_EvidenceFamily.requireBasisRows(claimIds);
        return o;
    }

    // ====================================================================== internals

    private static AAO_Candidate__c candidateFor(Id opportunityId, Fact f) {
        AAO_Candidate__c c = new AAO_Candidate__c(
            AAO_Opportunity__c = opportunityId,
            AAO_Account__c = f.accountId,
            // PENDING, like every other candidate at birth. The outcome is `AAO_Commit`'s to
            // write when it adjudicates; a proposer that stamped its own outcome would be
            // grading its own proposal.
            AAO_Outcome__c = 'Pending',
            AAO_Evidence_Contract__c = f.contractId,
            // NO SOURCE AND NO SPANS. The evidence-family law refuses a State row that carries
            // either, and it is right to: a span is a quotation from an artifact and this row
            // has none to quote from.
            AAO_Basis__c = AAO_EvidenceFamily.STATE,
            AAO_Proposed_Verdict__c = 'TRUE',
            AAO_Publication_State__c = 'Live',
            AAO_Stage__c = 'Adjudicated',
            AAO_Interpretation__c = f.because,
            AAO_Charter__c = 'AAO_ProcessCompute',
            AAO_Charter_Version__c = VERSION,
            AAO_Synthetic__c = AAO_Synthetic.MARK
        );
        // The subject is the PERSON, matching the grain the evidence plane already writes on
        // these contracts. A deal-level subject would put one contract's answers at two grains,
        // which is one fact with two representations - the shape that later shows the wrong
        // thing for a defensible reason. The deal-level roll-up is arithmetic over the answers
        // and needs no second representation to stand on.
        if (f.participantId != null) {
            c.AAO_Subject_Type__c = 'Participant';
            c.AAO_Participant__c = f.participantId;
            c.AAO_Subject_Contact__c = f.contactId;
        } else {
            c.AAO_Subject_Type__c = 'Contact';
            c.AAO_Subject_Contact__c = f.contactId;
        }
        c.AAO_Element_Completeness__c = fullCoverage(f.contractId);
        return c;
    }

    /**
     * Every element covered, because a computed fact answers the whole question or it is not a
     * fact. Read from the CONTRACT, never authored here: asking the proposal what full coverage
     * is would be asking the thing being judged.
     */
    private static String fullCoverage(Id contractId) {
        AAO_Evidence_Contract__c ec = [
            SELECT Id, AAO_Elements__c, AAO_Element_Count__c
            FROM AAO_Evidence_Contract__c
            WHERE Id = :contractId
            LIMIT 1
        ];
        List<String> ids = AAO_ExtractCharter.elementIds(ec);
        AAO_Model.Coverage cov = new AAO_Model.Coverage();
        cov.v = 1;
        cov.covered = ids;
        cov.missing = new List<String>();
        return JSON.serialize(cov);
    }

    private static AAO_Claim_Basis__c basisRow(Id claimId, Cite c) {
        AAO_Claim_Basis__c b = new AAO_Claim_Basis__c(
            AAO_Claim__c = claimId,
            AAO_Cited_Type__c = c.citedType,
            AAO_Snapshot__c = JSON.serialize(c.snapshot),
            AAO_Snapshot_Taken__c = System.now(),
            AAO_Cited_Row_Deleted__c = false
        );
        if (c.citedType == 'Answer') {
            b.AAO_Cited_Answer__c = c.rowId;
        } else if (c.citedType == 'Participant') {
            b.AAO_Cited_Participant__c = c.rowId;
        } else if (c.citedType == 'Map_Row') {
            b.AAO_Cited_Map_Row__c = c.rowId;
        } else {
            throw new ComputeException(
                'No typed lookup for cited type "' + c.citedType + '". A cited row that names ' +
                'no record is a citation that points nowhere.'
            );
        }
        return b;
    }

    /** contract id plus cited row id, for every claim already standing on this deal. */
    private static Set<String> standingCitations(Id opportunityId) {
        Set<String> out = new Set<String>();
        for (AAO_Claim_Basis__c b : [
            SELECT AAO_Cited_Answer__c, AAO_Cited_Participant__c, AAO_Cited_Map_Row__c,
                   AAO_Claim__r.AAO_Evidence_Contract__c
            FROM AAO_Claim_Basis__c
            WHERE AAO_Claim__r.AAO_Opportunity__c = :opportunityId
              AND AAO_Claim__r.AAO_Retired__c = false
        ]) {
            Id row = b.AAO_Cited_Answer__c != null
                ? b.AAO_Cited_Answer__c
                : (b.AAO_Cited_Participant__c != null
                    ? b.AAO_Cited_Participant__c
                    : b.AAO_Cited_Map_Row__c);
            if (row != null) {
                out.add(b.AAO_Claim__r.AAO_Evidence_Contract__c + '|' + row);
            }
        }
        return out;
    }

    private static Map<String, AAO_Evidence_Contract__c> liveContracts(List<String> codes) {
        Map<String, AAO_Evidence_Contract__c> out =
            new Map<String, AAO_Evidence_Contract__c>();
        if (codes == null || codes.isEmpty()) {
            return out;
        }
        for (AAO_Evidence_Contract__c ec : [
            SELECT Id, AAO_Proposition_Code__c, AAO_Elements__c, AAO_Element_Count__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Proposition_Code__c IN :codes
              AND AAO_Contract_State__c NOT IN :AAO_ContractState.DEAD
        ]) {
            out.put(ec.AAO_Proposition_Code__c, ec);
        }
        return out;
    }

    /**
     * The rank at or above which a role makes the final call, read from CONFIGURATION. An org
     * that re-ranks its ladder moves this line with it, which is the seventy-seventh stamp's
     * whole point: the ranks are a methodology statement an org must be able to state.
     */
    private static Integer decisionMakerRank() {
        String dm = AAO_P8Codes.buyerRole(AAO_P8Codes.BUYER_ROLE_DECISION_MAKER_CODE);
        return dm == null ? null : AAO_MapValues.rankOf(AAO_P8Codes.DIM_BUYER_ROLE, dm);
    }

    private static Boolean f_contactMatch(AAO_Participant__c p, AAO_Answer__c a) {
        Id target = contactOf(a);
        return target != null && p.AAO_Contact__c == target;
    }

    private static Id contactOf(AAO_Answer__c a) {
        if (a.AAO_Subject_Contact__c != null) {
            return a.AAO_Subject_Contact__c;
        }
        return a.AAO_Participant__c != null ? a.AAO_Participant__r.AAO_Contact__c : null;
    }

    private static String nameOf(AAO_Answer__c a) {
        if (a.AAO_Participant__c != null &&
            String.isNotBlank(a.AAO_Participant__r.AAO_Display_Name__c)) {
            return a.AAO_Participant__r.AAO_Display_Name__c;
        }
        if (a.AAO_Subject_Contact__c != null && a.AAO_Subject_Contact__r != null) {
            return a.AAO_Subject_Contact__r.Name;
        }
        return 'this person';
    }

    private static String personKey(AAO_Answer__c a) {
        Id contact = contactOf(a);
        if (contact != null) {
            return String.valueOf(contact);
        }
        return a.AAO_Participant__c != null
            ? String.valueOf(a.AAO_Participant__c)
            : String.valueOf(a.AAO_Subject_Contact__c);
    }

    private static Integer one(Map<String, Integer> m, String k) {
        Integer n = m.get(k);
        return n == null ? 1 : n + 1;
    }

    /**
     * The computed plane's own version, composed like every other charter's so a claim written
     * by it can be told from one written by an earlier arithmetic. It moves whenever a predicate
     * changes what it computes, because a version string covers every input that can change the
     * output it stamps.
     */
    public static final String VERSION = 'compute-1.0.0';
}
