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
 * - **THE UPHOLD DECIDES THE PROPOSED VERDICT.** *(Corrected in place at the seventieth stamp.
 *   This paragraph used to read "Coverage decides the proposed verdict": a `Full` pair proposed
 *   TRUE and a `Partial` pair proposed UNVERIFIED, on the rule that partial is the instructed
 *   default under doubt. Matthew ruled at the sixty-ninth that the blind verifier decides truth
 *   and completeness is recorded as data, never as a verdict gate, because a read-side hedge
 *   outranking the checker inverts the layering this whole pass rests on.)* Only upheld pairs
 *   reach the candidate builder, so the proposal is TRUE and element COMPLETENESS travels beside
 *   it. What the old rule protected is unchanged: a partial accrues its receipts on the answer,
 *   and completeness is what accumulates across utterances by union at the join.
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
        /** Upheld, identified, and refused by a standing graded trap. Addendum 17. */
        public Integer pairsTrapped = 0;
        /** Upheld, identified, and refused because the subject is a seller. Ruled 8 Aug. */
        public Integer pairsInternalSubject = 0;
        public Integer claimsWritten = 0;
        public Integer answersWritten = 0;
        public Integer countersRebuilt = 0;
        public Integer criteriaMinted = 0;
        /** Typing or gating pairs whose span overlaps no naming, so they type nothing. */
        public Integer criteriaUnattached = 0;
        /** Answers whose verdict the replay disagreed with, and corrected. */
        public Integer verdictsRebuilt = 0;
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
                    '  refused, graded trap   ' + pairsTrapped + ' (unit: pairs)',
                    '  subject is a seller    ' + pairsInternalSubject + ' (unit: pairs)',
                    'claims written           ' + claimsWritten + ' (unit: claims)',
                    'answers written          ' + answersWritten + ' (unit: answers)',
                    'support counters rebuilt ' + countersRebuilt + ' (unit: people)',
                    'criteria minted          ' + criteriaMinted + ' (unit: criteria)',
                    '  typing unattached      ' + criteriaUnattached + ' (unit: pairs)',
                    'verdicts rebuilt         ' + verdictsRebuilt + ' (unit: answers)'
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
    /**
     * THE CALLER-SIDE JOIN SPLIT, ruled at the sixteenth stamp and built here on the day the
     * wall was hit by ordinary use.
     *
     * Its authorising bytes, sixteenth stamp: *"The caller-side join split moves AHEAD of the
     * production-transcript runs. The DML wall (~33 pairs at 81/150) sits where a dense
     * enterprise call plausibly lands."* And the forty-eighth, on the SOQL side of the same
     * wall: *"its mitigations (caller-side join split, bulkified single projection) are already
     * ruled."*
     *
     * **THE WALL, MEASURED RATHER THAN PREDICTED THIS TIME.** The forty-eighth stamp met it at
     * 34 upheld and bulkified `readExisting` to get back under; `pf0811-goal` then joined 24
     * upheld inside the ceiling. On 13 August a purged rerun produced 28 upheld and the join
     * threw `Too many SOQL queries: 101`. So the bulkification bought roughly ten more pairs
     * and the ceiling is still a ceiling, exactly as both stamps said it would be.
     *
     * The split is safe by construction because the pair watermark already makes the join
     * resumable: a pair that became a claim is skipped on the next pass, so the caller simply
     * calls again until `pairsEligible` reaches zero. Nothing about the read-then-branch
     * semantics changes; only how many of them one transaction attempts.
     */
    public static Outcome run(String runKey, Set<String> internalDomains, Integer maxPairs) {
        BATCH = maxPairs;
        try {
            return run(runKey, internalDomains);
        } finally {
            BATCH = null;
        }
    }

    /** The current transaction's pair budget, or null for "everything eligible". */
    @TestVisible
    private static Integer BATCH = null;

    public static Outcome run(String runKey, Set<String> internalDomains) {
        if (String.isBlank(runKey)) {
            throw new JoinException('Cannot join pairs with no run key.');
        }
        Outcome o = new Outcome();
        o.runKey = runKey;
        // The join is code seconds rather than model seconds, so nothing measures it for free.
        Long startedAt = System.currentTimeMillis();

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
                AAO_Person__r.AAO_Email__c,
                AAO_Charter__c,
                AAO_Charter_Version__c,
                AAO_Located_Pair__c,
                AAO_Located_Pair__r.AAO_Answer_Text__c,
                AAO_Located_Pair__r.AAO_Meaning__c,
                AAO_Located_Pair__r.AAO_Coverage__c,
                AAO_Located_Pair__r.AAO_Criterion_Name__c,
                AAO_Located_Pair__r.AAO_Start_Offset__c,
                AAO_Located_Pair__r.AAO_End_Offset__c,
                AAO_Located_Pair__r.AAO_Speaker_Key__c,
                AAO_Located_Pair__r.AAO_Source__c,
                AAO_Located_Pair__r.AAO_Source__r.AAO_Normalized_Text__c,
                AAO_Located_Pair__r.AAO_Source__r.AAO_SHA256__c,
                AAO_Located_Pair__r.AAO_Source__r.AAO_Source_Ref__c,
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
        // The split is applied AFTER eligibility so the outcome's own counts still describe the
        // whole run: a reader sees how many pairs were eligible and how many this transaction
        // took, rather than a truncated view that looks like the run was smaller than it was.
        if (BATCH != null && eligible.size() > BATCH) {
            // Named `thisTransaction` rather than `batch`: APEX IS CASE-INSENSITIVE, so a local
            // `batch` silently shadows the static `BATCH` and the comparison below becomes
            // Integer against List. It failed to compile, which is the good version of that
            // mistake; the bad version is a language where it would have compiled.
            List<AAO_Pair__c> thisTransaction = new List<AAO_Pair__c>();
            for (Integer i = 0; i < BATCH; i++) {
                thisTransaction.add(eligible[i]);
            }
            o.refusals.add(
                'Caller-side split: ' + eligible.size() + ' pairs eligible, ' + BATCH +
                ' taken this transaction. Call again until pairs eligible reaches zero; the ' +
                'pair watermark makes the join resumable.'
            );
            eligible = thisTransaction;
        }

        // THE NEVER-PROJECTED RULE, Addendum 17, wired here at last. A pair whose words and
        // contract reproduce a standing graded trap is refused BEFORE it becomes a claim.
        //
        // **Reported and never projected is one rule and only the reporting half existed.**
        // a21 is the proof: the regression report named `trap-seq11-courtesy` as reproduced in
        // the same run whose join wrote it as an ordinary claim, moved Ryan Couture's counter
        // to +1 and put Supporter on his map row. A report that watches the thing happen is
        // not an enforcement of anything.
        //
        // It refuses at the CLAIM rather than at the write, because the counter rebuilds from
        // claims: a projection-side refusal would be undone by the next replay.
        AAO_Source__c artifactSource = eligible.isEmpty()
            ? null
            : eligible[0].AAO_Located_Pair__r.AAO_Source__r;
        if (artifactSource != null) {
            Map<Id, String> traps = AAO_Regression.trapped(
                eligible,
                artifactSource.AAO_Normalized_Text__c,
                artifactSource.AAO_SHA256__c,
                artifactSource.AAO_Source_Ref__c
            );
            if (!traps.isEmpty()) {
                List<AAO_Pair__c> survivors = new List<AAO_Pair__c>();
                for (AAO_Pair__c p : eligible) {
                    if (traps.containsKey(p.Id)) {
                        o.pairsTrapped++;
                        o.refusals.add(
                            p.AAO_Pair_Ref__c + ' (' +
                            p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c +
                            '): REFUSED by the standing grading "' + traps.get(p.Id) +
                            '". The pass found it and call 3 upheld it; a graded trap is ' +
                            'reported and never projected.'
                        );
                    } else {
                        survivors.add(p);
                    }
                }
                eligible = survivors;
            }
        }

        // THE INTERNAL-DOMAIN GATE APPLIES TO CLAIM SUBJECTS. Ruled 8 August, from a23.
        //
        // `internalDomains` has been threaded into this method since the join existed and
        // was used for exactly one thing: resolving WHICH SELLER heard a claim. Nothing
        // anywhere asked who a claim was ABOUT. So a23 upheld a Buyer Role EVALUATOR on
        // Wendy Higley - our own seller - and projection created her a Contact on the
        // customer's account.
        //
        // a22 met the identical shape on the same two people and call 3 happened to refuse
        // both. The correct outcome was the verifier's judgment, which is not a rule. A
        // seller cannot be a member of the buying committee BY CONSTRUCTION.
        //
        // Scoped to the person-subject dimensions deliberately. A criteria claim's subject
        // is the criterion, not the person, so this gate does not fire there; whether a
        // criterion voiced by a seller should stand is a different question about the
        // VOICER and it is not this ruling's. Named rather than folded in silently.
        eligible = withoutInternalSubjects(eligible, internalDomains, o);

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
        // One read for the whole batch instead of one per pair. Ruled 6 August; the branch
        // logic inside the writer is untouched, only where its rows come from.
        AAO_Commit.primeCandidates(new List<Id>(new Map<Id, AAO_Candidate__c>(candidates).keySet()));

        List<AAO_Pair__c> committed = new List<AAO_Pair__c>();
        Set<Id> touchedAnswers = new Set<Id>();
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
                touchedAnswers.add(r.answer.Id);
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
        o.verdictsRebuilt = rebuildVerdicts(touchedAnswers);
        o.countersRebuilt = rebuildCounters(sentimentPeople.keySet());
        // THE JOIN'S GOVERNOR LINE IS THE ONE THAT HAS ACTUALLY BITTEN TWICE (SOQL 101 at the
        // forty-eighth stamp, DML 81 of 150 at the sixteenth), so it is the leg most worth
        // having on a row rather than in a report nobody reruns.
        AAO_Receipt.record(
            runKey, AAO_Receipt.sourceForRun(runKey), AAO_Receipt.STAGE_JOIN,
            System.currentTimeMillis() - startedAt, o.claimsWritten
        );
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
    /**
     * The person-subject dimensions. A claim on one of these asserts something about WHO
     * the person is in the buying committee, so its subject must be buyer-side.
     */
    private static final Set<String> PERSON_SUBJECT_DIMENSIONS = new Set<String>{
        AAO_P8Codes.DIM_SUPPORT,
        AAO_P8Codes.DIM_POLITICAL,
        AAO_P8Codes.DIM_BUYER_ROLE
    };

    /**
     * Refuse, with its reason, any person-subject pair whose subject sits on a selling-side
     * domain. Structural: the reader's verdict is not consulted and cannot override it.
     *
     * THE GAP IS NAMED RATHER THAN PAPERED OVER: this decides on the participant's email
     * domain, so a roster row carrying no email is not refused here. That is the silence
     * law applied - absence of a domain is not evidence of a buyer - and it is the reason
     * the shadow path's own gate has to make the same check when it resolves a mentioned
     * person who never appears on a roster at all.
     */
    private static List<AAO_Pair__c> withoutInternalSubjects(
        List<AAO_Pair__c> eligible,
        Set<String> internalDomains,
        Outcome o
    ) {
        if (internalDomains == null || internalDomains.isEmpty()) {
            return eligible;
        }
        List<AAO_Pair__c> survivors = new List<AAO_Pair__c>();
        for (AAO_Pair__c p : eligible) {
            String code = p.AAO_Evidence_Contract__r == null
                ? null
                : p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
            String email = p.AAO_Person__r == null ? null : p.AAO_Person__r.AAO_Email__c;
            if (!PERSON_SUBJECT_DIMENSIONS.contains(AAO_P8Codes.dimensionOf(code)) ||
                !isInternal(email, internalDomains)) {
                survivors.add(p);
                continue;
            }
            o.pairsInternalSubject++;
            o.refusals.add(
                p.AAO_Pair_Ref__c + ' (' + code + '): REFUSED, the subject is on the ' +
                'selling side (' + email + '). A seller is not a member of the buying ' +
                'committee, so no claim about one is written. Structural, not the ' +
                'verifier\'s call.'
            );
        }
        return survivors;
    }

    private static Boolean isInternal(String email, Set<String> internalDomains) {
        if (String.isBlank(email) || !email.contains('@')) {
            return false;
        }
        return internalDomains.contains(email.substringAfterLast('@').toLowerCase());
    }

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
        // Parallel to namedSpans, NOT to namings: a nameless naming mints nothing and must
        // not shift which criterion a typing span attaches to.
        List<AAO_Pair__c> mintedNamings = new List<AAO_Pair__c>();
        for (AAO_Pair__c p : namings) {
            AAO_Pair__c loc = p.AAO_Located_Pair__r;
            // THE NAME, NEVER THE MEANING (twenty-seventh stamp). The meaning enum on the
            // naming contract is closed at the literal word CRITERION, and passing it here
            // is what collapsed every criterion in the org onto one row displaying that
            // word to the seller. The name states the condition that must be true for the
            // positive decision, and the key is opportunity plus name. A naming pair from a
            // pre-3.1.0 run carries no name and mints nothing, counted, because minting the
            // placeholder again would recreate the collapsed row this fix retires.
            if (String.isBlank(loc.AAO_Criterion_Name__c)) {
                o.criteriaUnattached++;
                o.refusals.add(
                    p.AAO_Pair_Ref__c + ' (' + AAO_P8Codes.CRITERION_NAMING + '): mints no ' +
                    'criterion, because the pair carries no criterion name. A criterion\'s ' +
                    'identity is its name; the placeholder is never minted again.'
                );
                continue;
            }
            AAO_Criterion__c c = AAO_Criteria.mint(
                loc.AAO_Criterion_Name__c,
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
            mintedNamings.add(p);
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
            AAO_Criterion__c c = out.get(mintedNamings[at].Id);
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

        // ELEMENT COMPLETENESS, RECORDED HONESTLY. This used to stamp `covered = every element
        // the contract declares, missing = []` UNCONDITIONALLY, so the row said "complete" no
        // matter what the read found — the self-contradiction the sixty-eighth stamp named,
        // where one candidate claimed full completeness in one field and unverified-for-
        // incompleteness in another.
        //
        // It mattered little while completeness gated nothing. It matters now: with the verdict
        // off it (Matthew's uphold-governs ruling) completeness is the ONLY honest record of
        // which parts of a question the words answered, it is what the join-side union
        // accumulates across utterances, and it is what the criteria path reads to keep partial
        // criteria off a customer-visible vendor row.
        //
        // The three cases, and none of them guesses:
        //   ONE ELEMENT — a pair exists, so the single element is covered. "Partial" is not
        //     expressible on a one-element question and is not recorded as if it were.
        //   MULTI-ELEMENT, read said Full — every element covered, on the read's own word.
        //   MULTI-ELEMENT, read said Partial — only the element this span is offered for. Call 1
        //     does not say WHICH of the three a criteria naming span answers, so this records
        //     the one the span is attributed to and leaves the rest missing rather than
        //     inventing a split or claiming the lot.
        AAO_Model.Coverage cov = new AAO_Model.Coverage();
        String propositionCode = p.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
        Boolean readSaidFull = located.AAO_Coverage__c == 'Full' ||
            !AAO_LocateCharter.takesCoverage(propositionCode);
        if (elements.size() <= 1 || readSaidFull) {
            cov.covered = new List<String>(elements);
            cov.missing = new List<String>();
        } else {
            cov.covered = span.element == null
                ? new List<String>()
                : new List<String>{ span.element };
            cov.missing = new List<String>();
            for (String e : elements) {
                if (!cov.covered.contains(e)) {
                    cov.missing.add(e);
                }
            }
        }

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
        // THE UPHOLD GOVERNS. Matthew's ruling, sixty-ninth stamp: "Where the blind verifier
        // upheld the words, the answer reads TRUE; element completeness is recorded as data,
        // never as a verdict gate."
        //
        // **WHAT THIS LINE USED TO DO, AND WHY IT WAS WRONG TWICE OVER.** It read
        // `located.AAO_Coverage__c`, which is CALL 1's OWN VOICED LABEL, and proposed
        // UNVERIFIED whenever the read had hedged. So a read-side hedge decided the verdict and
        // a later uphold by the blind verifier could not overturn it — the reader outranking
        // the checker, which inverts the layering the whole architecture rests on. It was also
        // INCOHERENT WITH ITS OWN ROW: this method stamps element completeness as covered-every
        // -element four lines below, so the candidate said "complete" in one field and
        // "unverified for incompleteness" in another. And on the twelve single-element
        // contracts "some of it" is not even expressible: either the element is covered or
        // there is no pair. Eight of fifty-one such pairs came back Partial on one fixture.
        //
        // Only pairs the verifier UPHELD reach this method (the eligibility filter above
        // refuses every other disposition), so the proposal is TRUE and completeness travels
        // beside it as data rather than as a gate.
        String proposed = 'TRUE';

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
            // THE SUBJECT CONTACT RIDES ON BOTH PATHS (twenty-seventh stamp). It used to be
            // nulled on the criteria path, which made criterion claims unreachable from the
            // voicer's evidence list - the null-Subject defect Matthew found on the live
            // map. The answer KEY is untouched: Decision_Criterion keys on AAO_Criterion__c,
            // so this field is linkage, never identity, on that path.
            AAO_Subject_Contact__c = p.AAO_Person__r == null
                ? null
                : p.AAO_Person__r.AAO_Contact__c,
            AAO_Proposed_Verdict__c = proposed,
            AAO_Spans__c = AAO_Model.serializeSpans(new List<AAO_Model.Span>{ span }),
            AAO_Element_Completeness__c = AAO_Model.serializeCoverage(cov),
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

    /**
     * REPLAY EVERY TOUCHED ANSWER'S VERDICT FROM ITS OWN CLAIMS. Ruled 6 August with the
     * clobber fix, and it is the second half rather than a duplicate of the first.
     *
     * The write-time guard in `AAO_Accumulate` depends on the order claims arrive in: it can
     * only refuse to weaken something already standing. **The replay does not depend on
     * order at all**, so a run that committed its pairs in any sequence lands on the same
     * verdict, and a disagreement between the two is reported rather than hidden. That is the
     * counter's own pattern - drift unexpressible rather than merely forbidden - applied to
     * the field the counter does not cover.
     */
    /**
     * Public because RETIREMENT NEEDS IT. The join reaches this on its own runs, but a
     * retirement changes what the ledger says without any pair being joined, and an answer
     * that still reads TRUE over a retired claim is exactly the divergence retirement exists
     * to close. `AAO_Retire` calls it directly.
     */
    public static Integer rebuildVerdicts(Set<Id> answerIds) {
        if (answerIds.isEmpty()) {
            return 0;
        }
        Map<Id, List<AAO_Claim__c>> byAnswer = new Map<Id, List<AAO_Claim__c>>();
        for (AAO_Claim__c c : [
            SELECT AAO_Answer__c, AAO_Verdict_After__c, AAO_Evidence_Occurred__c
            FROM AAO_Claim__c
            WHERE AAO_Answer__c IN :answerIds
                // RETIRED CLAIMS ESTABLISH NOTHING. Ruled 6 August: a claim that should never
                // have established anything is marked rather than deleted, and this is where
                // the marking does its work - the verdict replays from what is left, which is
                // the same mechanism that made the clobber fix order-independent.
                AND AAO_Retired__c = FALSE
            ORDER BY AAO_Evidence_Occurred__c ASC NULLS FIRST, Id ASC
        ]) {
            if (!byAnswer.containsKey(c.AAO_Answer__c)) {
                byAnswer.put(c.AAO_Answer__c, new List<AAO_Claim__c>());
            }
            byAnswer.get(c.AAO_Answer__c).add(c);
        }

        List<AAO_Answer__c> moved = new List<AAO_Answer__c>();
        for (AAO_Answer__c a : [
            SELECT Id, AAO_Verdict__c, AAO_Established_By__c
            FROM AAO_Answer__c
            WHERE Id IN :answerIds
        ]) {
            // A human-established answer is theirs. The replay reads machine claims and must
            // never reach across that line.
            if (a.AAO_Established_By__c == 'HUMAN') {
                continue;
            }
            // **AN ANSWER WHOSE EVERY CLAIM IS RETIRED ESTABLISHES NOTHING**, and that state
            // was unreachable until retirement existed. `verdictFromClaims` returns null for
            // an empty list, and the guard below reads null as "I was not handed this answer's
            // claims" and leaves the standing verdict alone - which was right when the only
            // way to see zero claims was to not have queried them. Retirement makes zero LIVE
            // claims a real and meaningful answer to a question we did ask, and reading it as
            // silence would leave an answer standing TRUE on receipts that were all withdrawn.
            //
            // It lands UNVERIFIED rather than null or FALSE: the proposition WAS addressed, the
            // retired claims still carry their receipts and are still readable, and UNVERIFIED
            // is the state that places nobody - so projection retracts, which is the ratified
            // behaviour and the reason retirement is a lawful correction rather than a delete.
            Boolean noLiveClaims = !byAnswer.containsKey(a.Id);
            String replayed = noLiveClaims
                ? 'UNVERIFIED'
                : AAO_Accumulate.verdictFromClaims(byAnswer.get(a.Id));
            if (replayed == null || replayed == a.AAO_Verdict__c) {
                continue;
            }
            moved.add(new AAO_Answer__c(Id = a.Id, AAO_Verdict__c = replayed));
        }
        if (!moved.isEmpty()) {
            update moved;
        }
        return moved.size();
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
    /** Public for the same reason as `rebuildVerdicts`. Key shape: participantId + '|' + oppId. */
    public static Integer rebuildCounters(Set<String> personScopes) {
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
                // And a retired claim moves the counter by nothing, for the same reason.
                AND AAO_Retired__c = FALSE
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