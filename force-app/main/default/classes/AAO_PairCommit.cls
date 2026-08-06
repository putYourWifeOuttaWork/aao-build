/**
 * THE PAIRS-TO-WRITER JOIN. Upheld identified pairs become Claims and Answers.
 *
 * **Nothing joined the pair ledger to the answer path before this class.** The three §P8 calls
 * ran, located, identified and verified, and their output stopped at `AAO_Pair__c`;
 * `AAO_Answer__c` was written only from the retired EBV route. This is the pass's missing
 * spine and it is ordinary work under the addendum 18 placements.
 *
 * **IT GOES THROUGH `AAO_Commit` RATHER THAN AROUND IT, and that is the whole design.** A
 * second writer for answers would mean a second copy of the human-precedence read, the
 * `DUPLICATE_VALUE`-as-merge path, the speaker gate, the reinforcement rule and the flag
 * reconciliation - and two copies of a rule diverge, always. So this class does exactly one
 * thing the writer cannot do for itself: it turns a verified pair into the candidate shape the
 * writer already knows how to commit. Everything downstream of that is unchanged code.
 *
 * WHAT A PAIR CARRIES INTO THE CANDIDATE.
 * - **The person is the Participant**, never a Contact resolved on the way past. Claims key the
 *   Participant (addendum 18); the Contact travels beside it where identity has resolved to
 *   one, and null is a legitimate answer that must survive to projection rather than stopping
 *   the write here.
 * - **Coverage decides the proposed verdict, not the span set.** A `Full` pair proposes TRUE
 *   and a `Partial` pair proposes UNVERIFIED, because §P8 makes partial the instructed default
 *   under doubt and says a partial accrues safely and PLACES NOBODY. Encoding a partial as
 *   full-coverage-with-a-weaker-verdict is what makes that true: it accumulates its receipts on
 *   the answer, and `AAO_Project.derive` places only on TRUE.
 * - **The span is byte-located already.** Call 1 found the offsets in the frozen artifact, so
 *   the writer's own span check re-verifies rather than discovers, which is exactly what a
 *   second independent check is for.
 *
 * ONLY UPHELD, ONLY IDENTIFIED. A refused verification and a `None` or `Ambiguous`
 * identification are both dispositions the pass legitimately made, and both are already
 * counted by `AAO_PairLedger`. Neither writes, and neither is an error.
 */
public with sharing class AAO_PairCommit {
    public class JoinException extends Exception {
    }

    /** What one join did, in counts that each name their unit. */
    public class Outcome {
        public String runKey;
        public Integer pairsRead = 0;
        public Integer pairsEligible = 0;
        public Integer pairsNotUpheld = 0;
        public Integer pairsNotIdentified = 0;
        public Integer pairsAlreadyCommitted = 0;
        public Integer claimsWritten = 0;
        public Integer answersWritten = 0;
        public Integer countersRebuilt = 0;
        public Integer criteriaMinted = 0;
        /** Typing or gating pairs whose span overlaps no naming, so they type nothing. */
        public Integer criteriaUnattached = 0;
        public List<String> refusals = new List<String>();

        /**
         * THE STAGE ARITHMETIC, AT THIS STAGE. Eligible pairs in, claims out. A join that
         * read pairs and wrote no claim is the same shape of defect the projection guard
         * catches one stage later, and it is expressible here only as a reported zero.
         */
        public Boolean committedNothing() {
            return pairsEligible > 0 && claimsWritten == 0;
        }

        public override String toString() {
            String s = String.join(
                new List<String>{
                    'pairs read               ' + pairsRead + ' (unit: pairs)',
                    '  eligible               ' + pairsEligible + ' (unit: pairs)',
                    '  verification refused   ' + pairsNotUpheld + ' (unit: pairs)',
                    '  no identification      ' + pairsNotIdentified + ' (unit: pairs)',
                    '  already committed      ' + pairsAlreadyCommitted + ' (unit: pairs)',
                    'claims written           ' + claimsWritten + ' (unit: claims)',
                    'answers written          ' + answersWritten + ' (unit: answers)',
                    'support counters rebuilt ' + countersRebuilt + ' (unit: people)',
                    'criteria minted          ' + criteriaMinted + ' (unit: criteria)',
                    '  typing unattached      ' + criteriaUnattached + ' (unit: pairs)'
                },
                '\n'
            );
            if (committedNothing()) {
                s += '\n  COMMITTED NOTHING. ' + pairsEligible + ' upheld identified pairs ' +
                    'produced no claim. This is a join defect, not a recall result: the pass ' +
                    'found evidence and none of it reached the answer path.';
            }
            for (String r : refusals) {
                s += '\n  ' + r;
            }
            return s;
        }
    }

    // ============================================================================ the run

    /**
     * Join one run's verified pairs onto the answer path.
     *
     * Per pair rather than bulk-DML'd, for the reason projection is: each is a read-then-branch
     * decision against standing state, and one person's refusal must not stop another's write.
     * A buying group's worth of rows, not a data load.
     */
    public static Outcome run(String runKey, Set<String> internalDomains) {
        if (String.isBlank(runKey)) {
            throw new JoinException('Cannot join pairs with no run key.');
        }
        Outcome o = new Outcome();
        o.runKey = runKey;

        List<AAO_Pair__c> pairs = [
            SELECT
                Id,
                AAO_Pair_Ref__c,
                AAO_Disposition__c,
                AAO_Verification__c,
                AAO_Claim__c,
                AAO_Verification_Note__c,
                AAO_Person__c,
                AAO_Person__r.AAO_Contact__c,
                AAO_Person__r.AAO_Display_Name__c,
                AAO_Charter__c,
                AAO_Charter_Version__c,
                AAO_Located_Pair__c,
                AAO_Located_Pair__r.AAO_Answer_Text__c,
                AAO_Located_Pair__r.AAO_Meaning__c,
                AAO_Located_Pair__r.AAO_Coverage__c,
                AAO_Located_Pair__r.AAO_Start_Offset__c,
                AAO_Located_Pair__r.AAO_End_Offset__c,
                AAO_Located_Pair__r.AAO_Speaker_Key__c,
                AAO_Located_Pair__r.AAO_Source__c,
                AAO_Located_Pair__r.AAO_Source__r.AAO_Opportunity__c,
                AAO_Located_Pair__r.AAO_Source__r.AAO_Account__c,
                AAO_Located_Pair__r.AAO_Source__r.AAO_Evidence_Occurred__c,
                AAO_Located_Pair__r.AAO_Source__r.AAO_Part_Index__c,
                AAO_Evidence_Contract__c,
                AAO_Evidence_Contract__r.AAO_Elements__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = 'Identified'
            ORDER BY AAO_Pair_Ref__c
        ];
        o.pairsRead = pairs.size();
        if (pairs.isEmpty()) {
            return o;
        }

        List<AAO_Pair__c> eligible = new List<AAO_Pair__c>();
        for (AAO_Pair__c p : pairs) {
            if (p.AAO_Disposition__c != 'Identified' || p.AAO_Person__c == null) {
                o.pairsNotIdentified++;
                continue;
            }
            if (p.AAO_Verification__c != 'Upheld') {
                // A refusal is a disposition the pass made, not an error. It is already
                // counted by the ledger; it is named here so the join's own totals add up.
                o.pairsNotUpheld++;
                continue;
            }
            if (p.AAO_Claim__c != null) {
                // THE EVIDENCE WATERMARK, AT THE PAIR GRAIN. A pair that already became a
                // claim is not read again, which is the standing invariant that the same
                // evidence record is never read twice. Without it a re-run writes a second
                // Reinforced claim from the SAME words - and reinforcement is a count that
                // guidance orders by, so an inflated one is a lie about how often somebody
                // pressed something. It also doubles the counter, since two claims sharing
                // one source-event net two steps, which is how this was found.
                o.pairsAlreadyCommitted++;
                continue;
            }
            eligible.add(p);
        }
        o.pairsEligible = eligible.size();
        if (eligible.isEmpty()) {
            return o;
        }

        // THE CRITERIA PASS RUNS FIRST, because a criteria answer's subject is a criterion
        // and the criterion has to exist before the row that points at it. Addendum 20.
        Map<Id, AAO_Criterion__c> criterionByPair = mintCriteria(eligible, o);

        List<AAO_Candidate__c> candidates = new List<AAO_Candidate__c>();
        for (AAO_Pair__c p : eligible) {
            candidates.add(candidateFor(p, criterionByPair.get(p.Id)));
        }
        insert candidates;

        List<AAO_Pair__c> committed = new List<AAO_Pair__c>();
        Map<String, Id> sentimentPeople = new Map<String, Id>();

        for (Integer i = 0; i < candidates.size(); i++) {
            AAO_Pair__c p = eligible[i];
            AAO_Commit.Result r = AAO_Commit.commitCandidate(
                candidates[i].Id,
                internalDomains == null ? new Set<String>() : internalDomains
            );
            if (r.claim != null) {
                o.claimsWritten++;
                committed.add(new AAO_Pair__c(Id = p.Id, AAO_Claim__c = r.claim.Id));
            }
            if (r.answer != null) {
                o.answersWritten++;
            }
            if (r.claim == null) {
                o.refusals.add(
                    p.AAO_Pair_Ref__c + ' (' +
                    p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c + '): ' +
                    r.candidateOutcome +
                    (String.isBlank(r.note) ? '' : ' - ' + r.note)
                );
            }
            Id oppId = p.AAO_Located_Pair__r.AAO_Source__r.AAO_Opportunity__c;
            if (p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c == AAO_P8Codes.SENTIMENT) {
                sentimentPeople.put(
                    String.valueOf(p.AAO_Person__c) + '|' + oppId,
                    p.AAO_Person__c
                );
            }
        }

        if (!committed.isEmpty()) {
            update committed;
        }
        o.countersRebuilt = rebuildCounters(sentimentPeople.keySet());
        return o;
    }

    // ------------------------------------------------------------------ one candidate

    /**
     * Mint one criterion per naming pair, then attach every typing and gating pair to the
     * naming its located span overlaps. Returns the criterion each criteria pair belongs to,
     * so the candidate that follows can subject it.
     *
     * **A naming that is not upheld mints nothing**, which is why a typing pair overlapping it
     * comes back unattached rather than typing a criterion nothing established. That is two
     * stages disagreeing about one sentence, and it is counted rather than swallowed.
     */
    private static Map<Id, AAO_Criterion__c> mintCriteria(
        List<AAO_Pair__c> eligible,
        Outcome o
    ) {
        Map<Id, AAO_Criterion__c> out = new Map<Id, AAO_Criterion__c>();
        List<AAO_Pair__c> namings = new List<AAO_Pair__c>();
        List<AAO_Pair__c> typings = new List<AAO_Pair__c>();
        for (AAO_Pair__c p : eligible) {
            String code = p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
            if (code == AAO_P8Codes.CRITERION_NAMING) {
                namings.add(p);
            } else if (code == AAO_P8Codes.CRITERION_FORMAL ||
                       code == AAO_P8Codes.CRITERION_REQUIRED) {
                typings.add(p);
            }
        }
        if (namings.isEmpty() && typings.isEmpty()) {
            return out;
        }

        List<AAO_Criteria.Span> namedSpans = new List<AAO_Criteria.Span>();
        for (AAO_Pair__c p : namings) {
            AAO_Pair__c loc = p.AAO_Located_Pair__r;
            AAO_Criterion__c c = AAO_Criteria.mint(
                loc.AAO_Meaning__c,
                loc.AAO_Source__r.AAO_Opportunity__c,
                loc.AAO_Source__r.AAO_Account__c,
                p.AAO_Person__c,
                loc.AAO_Source__c,
                loc.AAO_Source__r.AAO_Evidence_Occurred__c
            );
            out.put(p.Id, c);
            namedSpans.add(new AAO_Criteria.Span(
                loc.AAO_Source__c, loc.AAO_Start_Offset__c, loc.AAO_End_Offset__c
            ));
            o.criteriaMinted++;
        }

        // Keyed by Id rather than listed: DC_F and DC_R on one criterion are two pairs and
        // one row, and Apex refuses a duplicate Id in an update list.
        Map<Id, AAO_Criterion__c> typed = new Map<Id, AAO_Criterion__c>();
        for (AAO_Pair__c p : typings) {
            AAO_Pair__c loc = p.AAO_Located_Pair__r;
            Integer at = AAO_Criteria.namingFor(
                new AAO_Criteria.Span(
                    loc.AAO_Source__c, loc.AAO_Start_Offset__c, loc.AAO_End_Offset__c
                ),
                namedSpans
            );
            if (at == null) {
                o.criteriaUnattached++;
                o.refusals.add(
                    p.AAO_Pair_Ref__c + ' (' +
                    p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c +
                    '): types no criterion, because its span overlaps no upheld naming on ' +
                    'this run.'
                );
                continue;
            }
            AAO_Criterion__c c = out.get(namings[at].Id);
            out.put(p.Id, c);
            if (p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c ==
                AAO_P8Codes.CRITERION_FORMAL) {
                c.AAO_Type__c = 'Formal';
            } else {
                c.AAO_Required__c = true;
            }
            typed.put(c.Id, c);
        }
        if (!typed.isEmpty()) {
            update typed.values();
        }
        return out;
    }

    private static AAO_Candidate__c candidateFor(AAO_Pair__c p, AAO_Criterion__c criterion) {
        AAO_Pair__c located = p.AAO_Located_Pair__r;
        if (located == null) {
            throw new JoinException(
                'Identified pair ' + p.AAO_Pair_Ref__c + ' has no located row. The ledger ' +
                'writes both or neither, so this is our bug and not a model behaviour.'
            );
        }

        List<String> elements = AAO_ExtractCharter.elementIds(p.AAO_Evidence_Contract__r);

        AAO_Model.Span span = new AAO_Model.Span();
        span.sourceId = String.valueOf(located.AAO_Source__c);
        span.partIndex = located.AAO_Source__r == null
            ? null
            : Integer.valueOf(located.AAO_Source__r.AAO_Part_Index__c);
        span.startOffset = located.AAO_Start_Offset__c == null
            ? null
            : Integer.valueOf(located.AAO_Start_Offset__c);
        span.endOffset = located.AAO_End_Offset__c == null
            ? null
            : Integer.valueOf(located.AAO_End_Offset__c);
        span.quote = located.AAO_Answer_Text__c;
        span.speaker = located.AAO_Speaker_Key__c;
        // The element the quote is offered for. Fifteen of the seventeen carry exactly one, so
        // this is the only element that exists; the criteria naming contract carries three and
        // call 1 does not say which, so it names the first rather than inventing a split. What
        // the coverage says is what routes the verdict, and it is set from the pair below.
        span.element = elements.isEmpty() ? null : elements[0];
        span.verification = 'UPHELD';

        AAO_Model.Coverage cov = new AAO_Model.Coverage();
        cov.covered = new List<String>(elements);
        cov.missing = new List<String>();

        // COVERAGE DECIDES THE VERDICT WHERE THE QUESTION TAKES COVERAGE, and **sentiment
        // does not** (§P8.4, and Addendum 19's first ruling). A sentiment read is whole: the
        // words voice one of four states or they produce no pair, and accumulation is the
        // counter's job rather than a coverage grade. `AAO_LocateCharter.takesCoverage` is
        // the single place that knows which questions those are, so this asks it rather than
        // repeating the list.
        //
        // **THIS WAS A DEFECT AND IT WAS MINE.** The charter side was already correct - the
        // sentiment family read's schema carries no `coverage` property at all, so the model
        // could not have offered one, and the a17 pairs came back with coverage null exactly
        // as they should. This line then read null as "not Full" and downgraded every
        // sentiment establishment to UNVERIFIED, which is why the counter stood at zero for
        // everyone and the map carried no Support value. A category error asked as a question
        // gets a wrong answer; asked as an if-else, it gets a silent one.
        String code = p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
        String proposed;
        if (!AAO_LocateCharter.takesCoverage(code)) {
            proposed = 'TRUE';
        } else {
            // Full carries every element the proposition names and proposes TRUE; Partial
            // carries some, is the instructed default under doubt, and proposes UNVERIFIED -
            // a finding with its receipts that satisfies no condition and places nobody.
            // True-or-nothing means FALSE is never proposed from this path at all.
            proposed = located.AAO_Coverage__c == 'Full' ? 'TRUE' : 'UNVERIFIED';
        }

        return new AAO_Candidate__c(
            AAO_Evidence_Contract__c = p.AAO_Evidence_Contract__c,
            AAO_Source__c = located.AAO_Source__c,
            AAO_Opportunity__c = located.AAO_Source__r.AAO_Opportunity__c,
            AAO_Account__c = located.AAO_Source__r.AAO_Account__c,
            AAO_Basis__c = AAO_EvidenceFamily.TRANSCRIPT,
            // The subject is the person, and the person is the Participant. The resolved
            // Contact rides beside it where identity has produced one; where it has not, the
            // row is still fully expressible, which is the entire point of the ruling.
            // THE SUBJECT IS THE CRITERION ON THE CRITERIA PATH and the person on every
            // other, with the person carried as OWNER either way. Addendum 20. A criteria
            // pair with no criterion is a typing that attached to nothing; it still becomes a
            // candidate so its evidence is on the record, and it types nothing because there
            // is nothing to type.
            AAO_Subject_Type__c = criterion == null ? 'Participant' : 'Decision_Criterion',
            AAO_Criterion__c = criterion == null ? null : criterion.Id,
            AAO_Participant__c = p.AAO_Person__c,
            AAO_Subject_Contact__c = criterion != null
                ? null
                : (p.AAO_Person__r == null ? null : p.AAO_Person__r.AAO_Contact__c),
            AAO_Proposed_Verdict__c = proposed,
            AAO_Spans__c = AAO_Model.serializeSpans(new List<AAO_Model.Span>{ span }),
            AAO_Element_Coverage__c = AAO_Model.serializeCoverage(cov),
            // What the words voice. For sentiment this IS the state the counter reads.
            AAO_Interpretation__c = located.AAO_Meaning__c,
            AAO_Charter__c = p.AAO_Charter__c,
            AAO_Charter_Version__c = p.AAO_Charter_Version__c,
            AAO_Publication_State__c = 'Live',
            AAO_Stage__c = 'Proposed',
            AAO_Outcome__c = 'Pending',
            AAO_Synthetic__c = AAO_Synthetic.MARK
        );
    }

    // ---------------------------------------------------------------- the counter

    /**
     * REBUILD THE STANDING COUNTER FROM THE CLAIMS THAT JUST LANDED.
     *
     * The field is the standing value and it is rebuildable from claims in evidence-occurred
     * order, so a drift between the two is a bug rather than a tie-break (addendum 18). This
     * rebuilds rather than incrementing for exactly that reason: an increment can drift and a
     * replay cannot, and §P8.4 already promises that replay in evidence-occurred order
     * reconstructs the counter exactly. Rebuilding is that promise executed rather than
     * asserted.
     *
     * @param personScopes keys of the shape `<participant id>|<opportunity id>`, because
     *                     stance is per scope and a counter per person global would be wrong
     *                     the day the account grain returns.
     */
    private static Integer rebuildCounters(Set<String> personScopes) {
        if (personScopes.isEmpty()) {
            return 0;
        }
        Set<Id> participantIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        for (String key : personScopes) {
            List<String> halves = key.split('\\|');
            participantIds.add((Id) halves[0]);
            opportunityIds.add((Id) halves[1]);
        }

        Map<String, List<AAO_Claim__c>> claimsByScope = new Map<String, List<AAO_Claim__c>>();
        for (AAO_Claim__c c : [
            SELECT
                Id,
                AAO_Participant__c,
                AAO_Opportunity__c,
                AAO_Source__c,
                AAO_Interpretation__c,
                AAO_Evidence_Occurred__c
            FROM AAO_Claim__c
            WHERE
                AAO_Participant__c IN :participantIds
                AND AAO_Opportunity__c IN :opportunityIds
                AND AAO_Evidence_Contract__r.AAO_Proposition_Code__c = :AAO_P8Codes.SENTIMENT
                // A downgraded claim carries real receipts and established nothing, so it
                // moves the counter by nothing. Only what established may accumulate.
                AND AAO_Verdict_After__c = 'TRUE'
        ]) {
            String key = String.valueOf(c.AAO_Participant__c) + '|' + c.AAO_Opportunity__c;
            if (!personScopes.contains(key)) {
                continue;
            }
            if (!claimsByScope.containsKey(key)) {
                claimsByScope.put(key, new List<AAO_Claim__c>());
            }
            claimsByScope.get(key).add(c);
        }

        Map<String, AAO_Answer__c> answerByScope = new Map<String, AAO_Answer__c>();
        for (AAO_Answer__c a : [
            SELECT Id, AAO_Participant__c, AAO_Opportunity__c, AAO_Support_Counter__c
            FROM AAO_Answer__c
            WHERE
                AAO_Participant__c IN :participantIds
                AND AAO_Opportunity__c IN :opportunityIds
                AND AAO_Evidence_Contract__r.AAO_Proposition_Code__c = :AAO_P8Codes.SENTIMENT
        ]) {
            answerByScope.put(
                String.valueOf(a.AAO_Participant__c) + '|' + a.AAO_Opportunity__c,
                a
            );
        }

        List<AAO_Answer__c> moved = new List<AAO_Answer__c>();
        for (String key : answerByScope.keySet()) {
            AAO_Answer__c a = answerByScope.get(key);
            Integer rebuilt = AAO_SupportCounter.rebuild(claimsByScope.get(key));
            if (a.AAO_Support_Counter__c != null &&
                Integer.valueOf(a.AAO_Support_Counter__c) == rebuilt) {
                continue;
            }
            moved.add(new AAO_Answer__c(Id = a.Id, AAO_Support_Counter__c = rebuilt));
        }
        if (!moved.isEmpty()) {
            update moved;
        }
        return answerByScope.size();
    }
}
