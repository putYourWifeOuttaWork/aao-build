/**
 * THE EXTRACT-BIND-VERIFY PASS, Charters v2.4 §P7.3. Four stages, one callout per transaction.
 *
 * WHY THIS IS A STATE MACHINE AND NOT A METHOD. The 120-second callout ceiling is CUMULATIVE
 * PER TRANSACTION, measured and primary-doc-verified (Architecture v3.3): three sequential
 * calls in one `runForSource` shared one budget, which is exactly how the per-person split
 * died. So a pass with a variable number of calls cannot be a function. It is a sequence of
 * transactions, each making one bounded callout, and the state travels between them.
 *
 *   stage1        one callout   the read, producing the inventory
 *   plan          no callout    deterministic binding: spans located, subjects resolved,
 *                               families fanned out to contracts
 *   stage2Step    one callout   one group of bind items, repeated until the plan is done
 *   planVerify    no callout    the claims binding established, made into verify items
 *   stage3Step    one callout   one group of verify items, repeated
 *   stage4        no callout    every write in the pass, all of it, at the end
 *
 * **Every callout stage writes nothing and stage 4 calls out to nothing.** That is not tidiness:
 * Apex forbids a callout after DML in the same transaction, and a pass whose stages both wrote
 * and called would have to order itself correctly forever. Split this way it cannot get the
 * ordering wrong, and the deterministic middle stages are testable without spending a token.
 *
 * TWO ENTRIES, ONE IMPLEMENTATION. `AAO_EBV_TEMP_Batch` drives the stages from Batch Apex,
 * scope size 1, which is the shape that survives because per-transaction limits reset per
 * execute and there is no chain-depth question. `runStagesForMeasurement` drives the same
 * functions one transaction at a time from anonymous Apex, which is how the per-stage numbers
 * in BUILD_JOURNAL were taken. Neither has logic the other does not.
 */
public class AAO_EBV {
    public class EBVException extends Exception {
    }

    public static final String CHARTER_SET_PEOPLE = AAO_ApplicableSet.PEOPLE;

    /** The single element every People contract carries. Guided questions are indivisible. */
    private static final String ELEMENT = 'e1';

    // ========================================================================= telemetry

    /**
     * One stage call's cost, per the inbox's report-per-stage list. Kept per CALL rather than
     * per stage, because a stage that ran in four groups has four latencies and an average
     * hides the one that nearly hit the ceiling.
     */
    public class Telemetry {
        public String stage;
        public Integer groupNo;
        public Integer items;
        public Long elapsedMs;
        public Integer inputTokens = 0;
        public Integer outputTokens = 0;
        public Integer cacheRead = 0;
        public Integer cacheCreate = 0;
        /** Included in outputTokens, never beside it. See AAO_Extract.Usage. */
        public Integer thinking = 0;
        public Integer promptChars = 0;
        public String modelRequested;
        public String modelReported;
        public String charter;
        public String charterVersion;
        public String stopReason;

        public override String toString() {
            return stage +
                '#' + groupNo +
                ' items=' + items +
                ' ms=' + elapsedMs +
                ' in=' + inputTokens +
                ' out=' + outputTokens +
                ' (thinking=' + thinking + ')' +
                ' cacheRead=' + cacheRead +
                ' cacheCreate=' + cacheCreate +
                ' promptChars=' + promptChars +
                ' model=' + modelReported +
                ' charter=' + charter + '@' + charterVersion +
                ' stop=' + stopReason;
        }
    }

    // ============================================================================= state

    /**
     * Everything the pass carries between transactions. Serializable on purpose: the Batch
     * holds one of these across its executes, and anonymous Apex can hand one back in.
     *
     * There is no schema behind it and there is not meant to be. Model & Flow v1.2: the
     * inventory IS the Candidate layer, and Candidate rows are written once, at stage 4, by
     * the writer that has always written them.
     */
    public class State {
        public Id sourceId;
        public List<String> charters = new List<String>();
        public String stage = 'new';

        // ---- stage 1
        public List<AAO_InventoryCharter.Item> inventory =
            new List<AAO_InventoryCharter.Item>();
        /** Subject handle to contact, so later stages resolve without a second query. */
        public Map<String, String> handleToContact = new Map<String, String>();
        public Map<String, String> displayByContact = new Map<String, String>();

        // ---- stage 2
        public List<AAO_BindCharter.BindItem> bindPlan =
            new List<AAO_BindCharter.BindItem>();
        public Integer bindCursor = 0;
        public Map<String, String> bindVerdict = new Map<String, String>();
        public Map<String, String> bindReason = new Map<String, String>();

        // ---- stage 3
        public List<AAO_VerifyCharter.VerifyItem> verifyPlan =
            new List<AAO_VerifyCharter.VerifyItem>();
        public Integer verifyCursor = 0;
        public Map<String, Boolean> verifyOk = new Map<String, Boolean>();
        public Map<String, String> verifyNote = new Map<String, String>();

        // ---- counted along the way, never recomputed at the end
        public Integer declaredContracts = 0;
        public Integer rosterSize = 0;
        public Integer families = 0;
        public Integer inventoryItems = 0;
        public Integer spanDropsNotFound = 0;
        public Integer spanDropsAmbiguous = 0;
        public Integer subjectOutOfSet = 0;
        public Integer familyWithoutContract = 0;
        public Integer bindingsAttempted = 0;
        public Integer bindingsUnanswered = 0;
        public Integer establishedByBinder = 0;
        public Integer verificationRejections = 0;
        public Integer verificationsUnanswered = 0;
        public Integer claimsEstablished = 0;

        public List<Telemetry> telemetry = new List<Telemetry>();
        /** Every drop, with its reason, so a count is never the only record of one. */
        public List<String> drops = new List<String>();
        public String outcomeLine;

        public Boolean bindDone() {
            return bindCursor >= bindPlan.size();
        }

        public Boolean verifyDone() {
            return verifyCursor >= verifyPlan.size();
        }
    }

    public static State begin(Id sourceId, Set<String> charters) {
        State s = new State();
        s.sourceId = sourceId;
        s.charters = new List<String>(charters);
        return s;
    }

    // ============================================================== stage 1 · the read

    /**
     * One callout. The whole artifact, the declared set's FAMILIES, and the deal's people.
     *
     * SOQL only before the callout, which is load bearing. Everything this method learns it
     * learns by reading, and the one thing it does is send a request.
     */
    public static State stage1(State s) {
        AAO_Source__c src = source(s.sourceId);
        AAO_ApplicableSet.Resolved resolved = AAO_ApplicableSet.resolve(
            new Set<String>(s.charters),
            src
        );
        if (resolved.contracts.isEmpty()) {
            throw new EBVException(
                'Nothing resolved for the declared charter set, so there is nothing to read ' +
                'for. ' + resolved
            );
        }
        // Applied before the call rather than discovered by it, and pure, because writing a
        // flag here would put DML in front of a callout.
        AAO_Cardinality.Verdict bound = AAO_Cardinality.check(resolved.contracts.size());
        if (!bound.withinBound) {
            throw new EBVException('Cardinality: ' + bound.reason);
        }

        Map<String, AAO_InventoryCharter.Family> fams =
            AAO_InventoryCharter.families(resolved.contracts);
        // The declared set's own people, never the roster. See `peopleForSet`: the B&V roster is
        // 44 and the declared set holds contracts for 3, and handing the read the other 41 is
        // paying to generate items that can only be dropped.
        AAO_InventoryCharter.People ppl = AAO_InventoryCharter.peopleForSet(fams);
        Map<String, AAO_Model.Speaker> roster =
            AAO_Model.parseRoster(src.AAO_Speaker_Roster__c);

        s.declaredContracts = resolved.contracts.size();
        s.rosterSize = resolved.roster.size();
        s.families = fams.size();
        for (String h : ppl.byHandle.keySet()) {
            Id cid = ppl.byHandle.get(h);
            s.handleToContact.put(h, String.valueOf(cid));
            s.displayByContact.put(String.valueOf(cid), ppl.displayOf.get(cid));
        }

        String systemText = AAO_InventoryCharter.systemPrompt();
        String rubric = AAO_InventoryCharter.rubricBlock(fams, ppl);
        String artifact = AAO_ExtractCharter.artifactBlock(src, roster);

        AAO_Extract.StageResult r = AAO_Extract.callStage(
            AAO_Extract.inventorySpec(),
            systemText,
            new List<String>{ rubric, artifact },
            AAO_InventoryCharter.schema(fams, ppl, roster)
        );

        s.inventory = AAO_InventoryCharter.parse(r.rawText);
        s.inventoryItems = s.inventory.size();
        record(s, r, 1, s.inventoryItems);
        s.stage = 'read';
        return s;
    }

    // ========================================================= plan · deterministic binding

    /**
     * NO MODEL. Spans located byte for byte, subjects resolved, families fanned out.
     *
     * This is the half of binding §P7.3 calls mechanical, and keeping it out of the model is
     * most of why the pass is affordable: one inventory item naming three families about one
     * person is three bind items and no extra reading. The judgment the model is left is one
     * span against one proposition.
     *
     * FOUR WAYS AN ITEM DIES HERE, all counted and all recorded with a reason:
     *   not_in_artifact       the quote is not in the stored text. The failure byte
     *                         verification exists to catch. The item is lost, and the
     *                         proposition it named becomes model_missed rather than silence,
     *                         because the read demonstrably saw a statement.
     *   occurs_more_than_once we cannot say which turn it lies in, so we cannot say who spoke
     *                         it, so the speaker rule has nothing to evaluate.
     *   subject_out_of_set    the read said the statement is about nobody on the list. An
     *                         honest observation with nowhere to go, kept as a number.
     *   no_contract           the family is real and this person has no contract for it. A
     *                         gap in the declared set, not a defect in the read.
     */
    public static State plan(State s) {
        AAO_Source__c src = source(s.sourceId);
        AAO_ApplicableSet.Resolved resolved = AAO_ApplicableSet.resolve(
            new Set<String>(s.charters),
            src
        );
        Map<String, AAO_Evidence_Contract__c> contracts = resolved.contracts;
        String text = src.AAO_Normalized_Text__c;

        Integer n = 0;
        for (AAO_InventoryCharter.Item it : s.inventory) {
            // ---- byte verification, first, because everything else is wasted without it
            Integer at = text.indexOf(it.span);
            if (at < 0) {
                s.spanDropsNotFound++;
                s.drops.add(
                    it.id + ' not_in_artifact "' + it.span.abbreviate(70) + '"'
                );
                continue;
            }
            if (text.indexOf(it.span, at + 1) >= 0) {
                s.spanDropsAmbiguous++;
                s.drops.add(
                    it.id + ' occurs_more_than_once "' + it.span.abbreviate(70) + '"'
                );
                continue;
            }

            String contactId = it.subject == AAO_InventoryCharter.SUBJECT_NONE
                ? null
                : s.handleToContact.get(it.subject);
            if (it.subject != AAO_InventoryCharter.SUBJECT_NONE && contactId == null) {
                s.subjectOutOfSet++;
                s.drops.add(it.id + ' subject_out_of_set handle=' + it.subject);
                continue;
            }

            for (String fam : it.families) {
                // The fan-out, and the whole reason the read never sees a per-person code:
                // family plus person IS the contract key, and Apex can compose it.
                String code = contactId == null
                    ? fam
                    : fam + AAO_PeopleContracts.SEP + contactId;
                AAO_Evidence_Contract__c ec = contracts.get(code);
                if (ec == null) {
                    s.familyWithoutContract++;
                    s.drops.add(it.id + ' no_contract code=' + code);
                    continue;
                }
                n++;
                AAO_BindCharter.BindItem b = new AAO_BindCharter.BindItem();
                b.id = 'b' + n;
                b.inventoryItemId = it.id;
                b.contractCode = code;
                b.propositionText = ec.AAO_Proposition_Text__c;
                b.subjectContactId = contactId == null ? null : Id.valueOf(contactId);
                b.subjectDisplay = contactId == null
                    ? null
                    : s.displayByContact.get(contactId);
                b.speaker = it.speaker;
                b.speakerRequirement = ec.AAO_Speaker_Requirement__c;
                b.span = it.span;
                s.bindPlan.add(b);
            }
        }
        s.bindingsAttempted = s.bindPlan.size();
        s.stage = 'planned';
        return s;
    }

    // ============================================================== stage 2 · one bind group

    /**
     * One callout carrying one group of bind items. Group size is config, and config because it
     * was measured: ruling 6 says group sizes for stages 2 and 3 are measured and never
     * assumed. The numbers behind the current value are in the config record's own comment.
     */
    public static State stage2Step(State s) {
        if (s.bindDone()) {
            return s;
        }
        AAO_Extract.requireSeparateModels();
        Integer size = groupSize(AAO_Extract.config().bindGroupSize, 'AAO_Bind_Group_Size__c');
        List<AAO_BindCharter.BindItem> callGroup = new List<AAO_BindCharter.BindItem>();
        for (Integer i = s.bindCursor; i < s.bindPlan.size() && callGroup.size() < size; i++) {
            callGroup.add(s.bindPlan[i]);
        }

        AAO_Extract.StageResult r = AAO_Extract.callStage(
            AAO_Extract.bindSpec(),
            AAO_BindCharter.systemPrompt(),
            new List<String>{ AAO_BindCharter.content(callGroup) },
            AAO_BindCharter.schema(callGroup)
        );

        Set<String> ids = new Set<String>();
        for (AAO_BindCharter.BindItem b : callGroup) {
            ids.add(b.id);
        }
        Map<String, AAO_BindCharter.Binding> answers = AAO_BindCharter.parse(r.rawText, ids);

        for (AAO_BindCharter.BindItem b : callGroup) {
            AAO_BindCharter.Binding a = answers.get(b.id);
            if (a == null) {
                // Sent and never answered. Not the same as insufficient: the binder made no
                // judgment at all, so counting it as one would measure schema compliance.
                s.bindingsUnanswered++;
                s.drops.add(b.id + ' bind_unanswered code=' + b.contractCode);
                continue;
            }
            s.bindVerdict.put(b.id, a.verdict);
            s.bindReason.put(b.id, a.reason);
            if (a.verdict == AAO_BindCharter.ESTABLISHES) {
                s.establishedByBinder++;
            }
        }

        s.bindCursor += callGroup.size();
        record(s, r, groupNoFor(s, 'stage2_bind'), callGroup.size());
        s.stage = s.bindDone() ? 'bound' : 'binding';
        return s;
    }

    // ===================================================== planVerify · what gets checked

    /**
     * Only what the binder established is verified, and that is the point of the stage.
     *
     * Verification catches OVER-READING: a claim the binder accepted on a span that does not
     * carry it. A binding the binder refused has nothing to over-read, so sending it would
     * spend tokens to be told what we already recorded. The rejection count that comes out of
     * this stage is therefore a rate against established claims, not against everything.
     */
    public static State planVerify(State s) {
        Integer n = 0;
        for (AAO_BindCharter.BindItem b : s.bindPlan) {
            if (s.bindVerdict.get(b.id) != AAO_BindCharter.ESTABLISHES) {
                continue;
            }
            n++;
            AAO_VerifyCharter.VerifyItem v = new AAO_VerifyCharter.VerifyItem();
            v.id = 'v' + n;
            v.bindItemId = b.id;
            v.claimText = b.propositionText;
            v.subjectDisplay = b.subjectDisplay;
            v.span = b.span;
            s.verifyPlan.add(v);
        }
        s.stage = 'verify_planned';
        return s;
    }

    public static State stage3Step(State s) {
        if (s.verifyDone()) {
            return s;
        }
        AAO_Extract.requireSeparateModels();
        Integer size = groupSize(
            AAO_Extract.config().verifyGroupSize,
            'AAO_Verify_Group_Size__c'
        );
        List<AAO_VerifyCharter.VerifyItem> callGroup = new List<AAO_VerifyCharter.VerifyItem>();
        for (Integer i = s.verifyCursor; i < s.verifyPlan.size() && callGroup.size() < size; i++) {
            callGroup.add(s.verifyPlan[i]);
        }

        AAO_Extract.StageResult r = AAO_Extract.callStage(
            AAO_Extract.verifySpec(),
            AAO_VerifyCharter.systemPrompt(),
            new List<String>{ AAO_VerifyCharter.content(callGroup) },
            AAO_VerifyCharter.schema(callGroup)
        );

        Set<String> ids = new Set<String>();
        for (AAO_VerifyCharter.VerifyItem v : callGroup) {
            ids.add(v.id);
        }
        Map<String, AAO_VerifyCharter.Verdict> answers = AAO_VerifyCharter.parse(r.rawText, ids);

        for (AAO_VerifyCharter.VerifyItem v : callGroup) {
            AAO_VerifyCharter.Verdict a = answers.get(v.id);
            if (a == null) {
                // A claim nobody verified does not write as established. Coverage needs an
                // affirmative yes and the absence of one is not one — the same rule the
                // previous blind reader was held to.
                s.verificationsUnanswered++;
                s.verifyOk.put(v.bindItemId, false);
                s.verifyNote.put(v.bindItemId, 'the blind reader returned no verdict');
                continue;
            }
            s.verifyOk.put(v.bindItemId, a.coextensive == true);
            s.verifyNote.put(
                v.bindItemId,
                (a.axis == null ? '' : a.axis + ': ') + a.reason
            );
            if (a.coextensive != true) {
                s.verificationRejections++;
            }
        }

        s.verifyCursor += callGroup.size();
        record(s, r, groupNoFor(s, 'stage3_verify'), callGroup.size());
        s.stage = s.verifyDone() ? 'verified' : 'verifying';
        return s;
    }

    // ================================================== stage 4 · every write in the pass

    /**
     * Chartered as unchanged, and unchanged means the same code: this hands proposals to
     * `AAO_Pipeline.commitProposals`, which is the tail `runForSource` has always run. The
     * same builder, the same six ordered commit steps, the same span verification, the same
     * speaker rule, the same human precedence, the same merge, the same complete ledger.
     *
     * WHAT THE THREE VERDICTS BECOME, and the one that has nowhere to go:
     *   establishes + verified        TRUE, element covered
     *   establishes + rejected        UNVERIFIED, element missing. The over-read catch.
     *   does_not_establish           UNVERIFIED, element missing
     *   insufficient                 no proposal at all; abstention, model_declined
     *   nothing bound for the pair    abstention, nobody_said
     *   statement seen and then lost  abstention, model_missed
     *
     * **FALSE is unreachable from this vocabulary and that is reported, not patched.** §P7.3
     * charters three bind verdicts and three is what is implemented. A positive denial lands
     * on UNVERIFIED beside a missing confirmation, so the TRUE-strong / FALSE-weak guard has
     * no FALSE input in this shape. Named in BUILD_JOURNAL for design to rule on.
     */
    public static State stage4(State s, Set<String> internalDomains) {
        AAO_Source__c src = source(s.sourceId);
        AAO_ApplicableSet.Resolved resolved = AAO_ApplicableSet.resolve(
            new Set<String>(s.charters),
            src
        );
        Map<String, AAO_Evidence_Contract__c> contracts = resolved.contracts;
        AAO_Extract.Config cfg = AAO_Extract.config();

        // One proposal per contract, even where several spans bound to it: a Candidate is
        // per proposition, and the spans are the evidence list on it.
        Map<String, AAO_Pipeline.Proposal> byCode =
            new Map<String, AAO_Pipeline.Proposal>();
        Map<Id, String> abstentionByContract = new Map<Id, String>();
        // Contracts the read produced a statement for, whatever became of it. What separates
        // model_missed from nobody_said at the end.
        Set<String> touched = new Set<String>();

        for (AAO_BindCharter.BindItem b : s.bindPlan) {
            touched.add(b.contractCode);
            String verdict = s.bindVerdict.get(b.id);
            if (verdict == null) {
                continue;
            }
            if (verdict == AAO_BindCharter.INSUFFICIENT) {
                AAO_Evidence_Contract__c ec = contracts.get(b.contractCode);
                if (ec != null && !byCode.containsKey(b.contractCode)) {
                    abstentionByContract.put(ec.Id, 'model_declined');
                }
                continue;
            }

            Boolean established = verdict == AAO_BindCharter.ESTABLISHES &&
                s.verifyOk.get(b.id) == true;

            AAO_Pipeline.Proposal p = byCode.get(b.contractCode);
            if (p == null) {
                p = new AAO_Pipeline.Proposal();
                p.contractCode = b.contractCode;
                p.subjectType = b.subjectContactId == null ? 'Opportunity' : 'Contact';
                p.proposedVerdict = 'UNVERIFIED';
                byCode.put(b.contractCode, p);
            }
            // A contract with a proposal is not an abstention, whatever else happened to it.
            AAO_Evidence_Contract__c ec = contracts.get(b.contractCode);
            if (ec != null) {
                abstentionByContract.remove(ec.Id);
            }

            AAO_Model.Span sp = locate(src, b.span, b.speaker);
            if (sp != null) {
                // D1: the span carries what the reader said about IT, not what the pair
                // concluded. A pair can survive on one span while another was refused, and
                // before this the refused one stayed on the Answer as a citation.
                // Only spans the reader actually saw get a status; a span on a binding the
                // binder never established was never verified and stays null rather than
                // being called upheld by default.
                if (verdict == AAO_BindCharter.ESTABLISHES && s.verifyOk.containsKey(b.id)) {
                    sp.verification = s.verifyOk.get(b.id) == true
                        ? AAO_Model.UPHELD
                        : AAO_Model.REFUSED;
                }
                p.spans.add(sp);
            }
            if (established) {
                p.proposedVerdict = 'TRUE';
                if (!p.covered.contains(ELEMENT)) {
                    p.covered.add(ELEMENT);
                }
            }
            // The reason the blind reader gave, kept where a human will read it. The
            // interpretation field is the under-specified-question list and a rejection note
            // is exactly that kind of record.
            String note = s.verifyNote.get(b.id);
            if (verdict == AAO_BindCharter.ESTABLISHES && !established &&
                String.isNotBlank(note)) {
                p.interpretation = ('blind reader refused: ' + note).abbreviate(255);
            }
        }

        List<AAO_Pipeline.Proposal> proposals = new List<AAO_Pipeline.Proposal>();
        for (AAO_Pipeline.Proposal p : byCode.values()) {
            if (!p.covered.contains(ELEMENT)) {
                p.missing.add(ELEMENT);
            }
            if (p.proposedVerdict == 'TRUE') {
                s.claimsEstablished++;
            }
            proposals.add(p);
        }

        // The complete ledger's third reason. A pair the read saw a statement for and the
        // pass lost is not silence, and calling it nobody_said would make the abstention rate
        // report the transcript's silence when it is reporting the machine's.
        for (String code : touched) {
            AAO_Evidence_Contract__c ec = contracts.get(code);
            if (ec == null || byCode.containsKey(code) ||
                abstentionByContract.containsKey(ec.Id)) {
                continue;
            }
            abstentionByContract.put(ec.Id, 'model_missed');
        }
        for (String lost : lostCodes(s, contracts)) {
            AAO_Evidence_Contract__c ec = contracts.get(lost);
            if (ec != null && !byCode.containsKey(lost)) {
                abstentionByContract.put(ec.Id, 'model_missed');
            }
        }

        AAO_Pipeline.Outcome o = new AAO_Pipeline.Outcome();
        o.sourceId = src.Id;
        o.sourceRef = src.AAO_Source_Ref__c;
        o.proposalSource = AAO_Pipeline.FROM_MODEL;
        o.charter = cfg.inventoryCharter;
        o.charterVersion = cfg.inventoryCharterVersion;
        o.blindCharter = cfg.verifyCharter;
        o.blindCharterVersion = cfg.verifyCharterVersion;

        o = AAO_Pipeline.commitProposals(
            src,
            contracts,
            proposals,
            abstentionByContract,
            internalDomains,
            o
        );
        s.outcomeLine = String.valueOf(o);
        s.stage = 'done';
        return s;
    }

    /**
     * Contracts a dropped span would have bound to, so a lost statement is not silently
     * recorded as silence. Derived from the drop list rather than kept as a second structure,
     * because two structures that must agree eventually will not.
     */
    private static Set<String> lostCodes(
        State s,
        Map<String, AAO_Evidence_Contract__c> contracts
    ) {
        Set<String> out = new Set<String>();
        Map<String, AAO_InventoryCharter.Item> byId =
            new Map<String, AAO_InventoryCharter.Item>();
        for (AAO_InventoryCharter.Item it : s.inventory) {
            byId.put(it.id, it);
        }
        for (String d : s.drops) {
            if (!d.contains('not_in_artifact') && !d.contains('occurs_more_than_once')) {
                continue;
            }
            AAO_InventoryCharter.Item it = byId.get(d.substringBefore(' '));
            if (it == null || it.subject == AAO_InventoryCharter.SUBJECT_NONE) {
                continue;
            }
            String cid = s.handleToContact.get(it.subject);
            if (cid == null) {
                continue;
            }
            for (String fam : it.families) {
                String code = fam + AAO_PeopleContracts.SEP + cid;
                if (contracts.containsKey(code)) {
                    out.add(code);
                }
            }
        }
        return out;
    }

    // ============================================================== the measurement entry

    /**
     * ONE STAGE PER CALL, from anonymous Apex, so each callout gets its own transaction and
     * its own 120-second budget. This is how the per-stage numbers were taken.
     *
     * It is not a shortcut around the invoker: it calls the same six functions in the same
     * order the Batch calls them, and returns the state as JSON so the next transaction can
     * carry on from it.
     */
    public static State advance(State s, Set<String> internalDomains) {
        if (s.stage == 'new') {
            return plan(stage1(s));
        }
        if (s.stage == 'planned' || s.stage == 'binding') {
            State next = stage2Step(s);
            return next.bindDone() ? planVerify(next) : next;
        }
        if (s.stage == 'verify_planned' || s.stage == 'verifying') {
            return stage3Step(s);
        }
        if (s.stage == 'verified' || s.stage == 'bound') {
            return stage4(s, internalDomains);
        }
        throw new EBVException('Nothing to advance: the pass is at stage ' + s.stage + '.');
    }

    /** How many transactions are left, so a driver knows when to stop asking. */
    public static Boolean finished(State s) {
        return s.stage == 'done';
    }

    /**
     * The state, as text, so one anonymous-Apex transaction can hand the pass to the next.
     *
     * The Batch does not need this — `Database.Stateful` carries the object natively. It exists
     * for the measurement driver, where every stage has to be its own execution so that every
     * callout gets its own 120-second budget and its own visible latency. **The numbers in
     * BUILD_JOURNAL came through here**, which is why it is product code with a comment rather
     * than a script in a scratch directory.
     */
    public static String toJson(State s) {
        return JSON.serialize(s);
    }

    public static State fromJson(String raw) {
        return (State) JSON.deserialize(raw, State.class);
    }

    // =================================================================== the run report

    /**
     * The report the inbox asks for, in one string, with the receipts beside the counts.
     *
     * RATES ARE PRINTED WITH THEIR DENOMINATORS. A rate on its own is not a receipt, and the
     * one that matters most here — `model_missed` — is a lower bound by construction rather
     * than a measurement, which the line says out loud.
     */
    public static String report(State s) {
        List<String> out = new List<String>();
        out.add('=== EXTRACT-BIND-VERIFY · Charters v2.4 §P7.3 ===');
        out.add('source        ' + s.sourceId);
        out.add('charters      ' + s.charters);
        out.add('stage         ' + s.stage);
        out.add('');
        out.add('--- per stage, per call ---');
        for (Telemetry t : s.telemetry) {
            out.add('  ' + t);
        }
        Long total = 0;
        Integer inTok = 0;
        Integer outTok = 0;
        Integer cr = 0;
        Integer cc = 0;
        for (Telemetry t : s.telemetry) {
            total += t.elapsedMs == null ? 0 : t.elapsedMs;
            inTok += t.inputTokens;
            outTok += t.outputTokens;
            cr += t.cacheRead;
            cc += t.cacheCreate;
        }
        out.add(
            '  TOTAL calls=' + s.telemetry.size() +
            ' ms=' + total +
            ' in=' + inTok +
            ' out=' + outTok +
            ' cacheRead=' + cr +
            ' cacheCreate=' + cc
        );
        out.add('');
        out.add('--- counts ---');
        out.add('declared contracts        ' + s.declaredContracts + ' (unit: contracts)');
        out.add('roster                    ' + s.rosterSize + ' people');
        out.add('families read against     ' + s.families);
        out.add('inventory items           ' + s.inventoryItems + ' (unit: items)');
        out.add('spans dropped, not found  ' + s.spanDropsNotFound);
        out.add('spans dropped, ambiguous  ' + s.spanDropsAmbiguous);
        out.add('subject out of set        ' + s.subjectOutOfSet);
        out.add('family with no contract   ' + s.familyWithoutContract);
        out.add('bindings attempted        ' + s.bindingsAttempted + ' (unit: bind items)');
        out.add('bindings unanswered       ' + s.bindingsUnanswered + ' (unit: bind items)');
        // THE UNIT LAW, ruled 4 August, and this line is its origin. `establishedByBinder`
        // and `verificationRejections` count bind and verify ITEMS; `claimsEstablished`
        // counts (contract, person) PAIRS. Printed adjacent and unlabeled, they made the
        // adjudication sheet compute a phantom missing claim from 16 - 9 != 6. Nothing was
        // missing; the units were different. Every counter now names its unit at the point
        // of print.
        out.add('established by binder     ' + s.establishedByBinder + ' (unit: bind items)');
        out.add(
            'VERIFICATION REJECTIONS   ' + s.verificationRejections +
            ' of ' + s.verifyPlan.size() + ' checked (unit: verify items)' +
            rate(s.verificationRejections, s.verifyPlan.size())
        );
        out.add('verifications unanswered  ' + s.verificationsUnanswered + ' (unit: verify items)');
        out.add('claims established        ' + s.claimsEstablished + ' (unit: contract-person pairs)');
        out.add('');
        out.add('--- outcome, from the writer that has always written ---');
        out.add('  ' + s.outcomeLine);
        out.add('');
        out.add('--- drops, each one recorded and not only counted ---');
        if (s.drops.isEmpty()) {
            out.add('  none');
        } else {
            for (String d : s.drops) {
                out.add('  ' + d);
            }
        }
        return String.join(out, '\n');
    }

    public static String rate(Integer n, Integer denom) {
        if (denom == null || denom == 0) {
            return ' (no denominator: nothing was checked)';
        }
        Decimal pct = (Decimal.valueOf(n) / Decimal.valueOf(denom) * 100)
            .setScale(1, System.RoundingMode.HALF_UP);
        return ' (' + pct + '%)';
    }

    // ======================================================================== internals

    private static AAO_Source__c source(Id sourceId) {
        return [
            SELECT
                Id,
                AAO_Opportunity__c,
                AAO_Account__c,
                AAO_Source_Ref__c,
                AAO_Artifact_SHA256__c,
                AAO_Normalized_Text__c,
                AAO_Speaker_Roster__c,
                AAO_Diarization__c,
                AAO_Synthetic__c
            FROM AAO_Source__c
            WHERE Id = :sourceId
        ];
    }

    /**
     * The model's resolver, and it returns null where the fixture's throws. A quote that is
     * not there is a finding about the model, never a defect in the run.
     */
    private static AAO_Model.Span locate(AAO_Source__c src, String quote, String speaker) {
        String text = src.AAO_Normalized_Text__c;
        Integer at = text.indexOf(quote);
        if (at < 0 || text.indexOf(quote, at + 1) >= 0) {
            return null;
        }
        AAO_Model.Span sp = new AAO_Model.Span();
        sp.sourceId = String.valueOf(src.Id);
        sp.partIndex = 1;
        sp.startOffset = at;
        sp.endOffset = at + quote.length();
        sp.quote = quote;
        sp.speaker = speaker;
        sp.element = ELEMENT;
        return sp;
    }

    private static Integer groupSize(Integer configured, String field) {
        if (configured == null || configured < 1) {
            throw new EBVException(
                field + ' is not set on AAO_Model_Config__mdt.Default. Group sizes are ' +
                'measured, never assumed, and there is no default to fall back on: a ' +
                'constant here would make a guess look like a measurement.'
            );
        }
        return configured;
    }

    private static Integer groupNoFor(State s, String stage) {
        Integer n = 0;
        for (Telemetry t : s.telemetry) {
            if (t.stage == stage) {
                n++;
            }
        }
        return n + 1;
    }

    private static void record(
        State s,
        AAO_Extract.StageResult r,
        Integer groupNo,
        Integer items
    ) {
        Telemetry t = new Telemetry();
        t.stage = r.stage;
        t.groupNo = groupNo;
        t.items = items;
        t.elapsedMs = r.elapsedMs;
        t.inputTokens = r.usage.inputTokens;
        t.outputTokens = r.usage.outputTokens;
        t.cacheRead = r.usage.cacheReadTokens;
        t.cacheCreate = r.usage.cacheCreationTokens;
        t.thinking = r.usage.thinkingTokens;
        t.promptChars = r.promptChars;
        t.modelRequested = r.modelRequested;
        t.modelReported = r.modelReported;
        t.charter = r.charter;
        t.charterVersion = r.charterVersion;
        t.stopReason = r.stopReason;
        s.telemetry.add(t);
    }
}
