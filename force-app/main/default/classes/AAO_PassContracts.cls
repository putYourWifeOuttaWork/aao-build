/**
 * THE DECLARED CLAIM-PATH CONTRACTS FOR §P8. Seventeen, asked once per transcript.
 *
 * Charters v2.8 §P8 and CODE addendum 02. This replaces the person-crossed set
 * `AAO_PeopleContracts` mints: that shape put the person in the proposition code
 * (`S2#003WD...`) because the old charter had no subject field, so a five-person roster on the
 * 17 June fixture would have produced **eighty** contract-questions. Under §P8 the person is
 * call 2's job and the question is asked once, so the code carries no person and the set is
 * seventeen whatever the roster size. **That is the scaling law in one number.**
 *
 * WHAT IS OURS AND WHAT IS THE VENDOR'S, marked rather than blended. Where Altify authored the
 * question, its text is carried BYTE-EXACT — curly apostrophes, British and American spellings
 * side by side, all of it — because a normalised quote is a paraphrase and the proposition is
 * held to the same law as evidence. Where a vendor question was TWO-SIDED, our one-way halves
 * are authored by us, derived from it, and land `Inferred_Pending` until a human ratifies them.
 * The vendor's original stays in `AAO_People_Question__mdt` and is never edited.
 *
 * TRUE-OR-NOTHING (§P8.0). Every proposition here points one way. The two-sided political
 * questions are split into halves that each point at their own placement, which is not a
 * cosmetic change: the 24 June run refused four claims on `PS4`/`PO2` **correctly**, because the
 * words carried the weak side and the single two-sided contract had no slot for it. Graded by
 * Matthew 4 August, four of four upheld as right refusals. Those same quotes place Political
 * Structure under `AAO_POL_PS1` and `AAO_POL_PS2`.
 *
 * WHAT IS DELIBERATELY ABSENT.
 * - **The nine Support questions.** Retired from extraction at §P8.4; sentiment is read directly
 *   into five states by `AAO_PS_1`. They remain the vendor's asset in the metadata.
 * - **`OM_..._QUESTION_9`** (political awareness) and **the weak half of `_1`** (merely
 *   understanding the goals). Both place nobody under the ceiling derivation, which is two of the
 *   three faults that retired S1. Recorded in the ontology, undeclared here.
 * - **Coverage.** Computed from participation, never extracted. No contract, no pair, no model.
 */
public with sharing class AAO_PassContracts {
    public class ContractException extends Exception {
    }

    /** The rubric this set belongs to. The person-crossed set is `people-om-v1`. */
    public static final String RUBRIC_VERSION = 'people-p8-v1';

    /** The rubric superseded when this one is minted. */
    public static final String SUPERSEDES_RUBRIC = 'people-om-v1';

    /** Vendor-authored text carried verbatim; ours pending a human. */
    private static final String BASIS_VENDOR = 'Authored';
    private static final String BASIS_OURS = 'Inferred_Pending';

    /** One contract to mint. */
    public class Spec {
        public String code;
        public String shortLabel;
        public String proposition;
        public String guidance;
        public String speakerRequirement;
        public String basis;
        public List<String> elements;

        public Spec(
            String code,
            String shortLabel,
            String proposition,
            String guidance,
            String speakerRequirement,
            String basis,
            List<String> elements
        ) {
            this.code = code;
            this.shortLabel = shortLabel;
            this.proposition = proposition;
            this.guidance = guidance;
            this.speakerRequirement = speakerRequirement;
            this.basis = basis;
            this.elements = elements;
        }
    }

    // ==================================================================== the seventeen

    public static List<Spec> specs() {
        List<Spec> out = new List<Spec>();

        // ---- SENTIMENT · 1 · route E ------------------------------------------------
        //
        // NEUTRAL IS NOT EMITTABLE and that is deliberate (§P8.4): neutral is the derived
        // reading when nothing stands, so a neutral pair would move the counter zero and write
        // a row about nothing, which is the abstention just retired wearing a different hat.
        // Words that voice no stance produce no pair.
        out.add(new Spec(
            'AAO_PS_1',
            'Sentiment · How does this person stand toward us?',
            'Do this person\'s own words voice how they stand toward us and our solution?',
            // THE LABEL MEANINGS ARE THE CHARTER'S, VERBATIM (§P8.4, pinned at v2.9). They are
            // quoted here, never paraphrased, for the reason the propositions are byte-exact:
            // the first draft of MENTOR was written here rather than read from the charter, it
            // opened with "guides you with insight," and the second joint grading found that
            // line true of anyone participating well in a meeting. Three MENTOR reads, three
            // Neutrals. **The ladder's strictest state carried its loosest wording — the same
            // defect class that retired S1 — and a reader pushed off under-reading by §P8.9
            // escaped straight into it.** Mentor-grade evidence is what crosses to +3, so a
            // cheap MENTOR makes terminals cheap.
            'One of MENTOR, SUPPORTER, NON_SUPPORTER, ENEMY. These are label meanings, never ' +
            'an interrogation checklist.\n' +
            'MENTOR: their words guide you through THEIR OWN ORGANIZATION on your behalf - ' +
            'their politics, their process, their people - or advocate for you when you are ' +
            'not in the room; insight about the work, the product, or the project is ' +
            'participation, not mentoring.\n' +
            'SUPPORTER: prefers you and says so.\n' +
            'NON_SUPPORTER: prefers an alternative, including doing nothing.\n' +
            'ENEMY: works against you, or believes your success harms them.\n' +
            'There is no partial and no neutral. No neutral label exists: words that voice no ' +
            'stance produce no pair, and ENGAGEMENT IS NOT STANCE - questions, process ' +
            'suggestions, "I think this is a key step," a person doing their job well and ' +
            'warmly, all voice nothing and emit nothing; emitting no pair on a warm sentence ' +
            'is correct behaviour, not under-reading.\n' +
            'Advocacy is never discounted for coming from a professional (§P8.9): a buyer who ' +
            'coaches you through her own approval process, tells you what the approvers need ' +
            'to see, or moves your case internally is voicing support while doing her job. ' +
            'Guidance the speaker cancels in the same breath is not guidance (Matthew, ' +
            '4 August, on "let\'s not plan on it").',
            'Subject_Person',
            BASIS_OURS,
            new List<String>{ 'Do this person\'s own words voice how they stand toward us and our solution?' }
        ));

        // ---- POLITICAL STATUS · 8 · route E · each points at exactly one placement ----
        //
        // Inner Circle. IC1 and IC2 are our one-way halves of the vendor's two-sided _1 and _2;
        // IC3 is our half of the two-sided _4.
        out.add(pol('AAO_POL_IC1', 'Political · Inner Circle · defines goals',
            'Does this person define the company\'s goals and objectives?',
            'Establishes Inner Circle. Our authored half of the vendor\'s two-sided ' +
            'OM_POLITICAL_STATUS_GUIDED_QUESTION_1. The other side of that question (merely ' +
            'having a good understanding of the goals) places nobody and is not declared.',
            BASIS_OURS));
        out.add(pol('AAO_POL_IC2', 'Political · Inner Circle · approves and sponsors',
            'Does this person approve and sponsor initiatives?',
            'Establishes Inner Circle. Our authored half of the vendor\'s two-sided ' +
            'OM_POLITICAL_STATUS_GUIDED_QUESTION_2; the other half is AAO_POL_PS1.',
            BASIS_OURS));
        out.add(pol('AAO_POL_IC3', 'Political · Inner Circle · controls outcomes',
            'Does this person control the outcomes?',
            'Establishes Inner Circle. Our authored half of the vendor\'s two-sided ' +
            'AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_4; the other half is AAO_POL_PS2. ' +
            'Coordinating, expediting, or routing a request is NOT controlling outcomes; those ' +
            'words belong to AAO_POL_PS2.',
            BASIS_OURS));

        // Political Structure. PS1 and PS2 are the weak halves the old two-sided contracts
        // could not record; PS3 and PS4 are the vendor's own, verbatim.
        out.add(pol('AAO_POL_PS1', 'Political · Structure · executes after approval',
            'Does this person execute projects after they are approved?',
            'Establishes Political Structure. Our authored half of the vendor\'s two-sided ' +
            'OM_POLITICAL_STATUS_GUIDED_QUESTION_2. Executing within an approved plan, or ' +
            'asking for resources against one, lands here rather than at AAO_POL_IC2.',
            BASIS_OURS));
        out.add(pol('AAO_POL_PS2', 'Political · Structure · called on to make it happen',
            'Is this person called on to make it happen?',
            'Establishes Political Structure. Our authored half of the vendor\'s two-sided ' +
            'AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_4. Being handed a specific ask and keeping ' +
            'it moving lands here rather than at AAO_POL_IC3.',
            BASIS_OURS));
        out.add(pol('AAO_POL_PS3', 'Political · Structure · sought for advice',
            'Do others seek this person out for advice and direction?',
            'Establishes Political Structure. The vendor\'s own question, carried verbatim from ' +
            'AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_3.',
            BASIS_VENDOR));
        out.add(pol('AAO_POL_PS4', 'Political · Structure · track record',
            'Does this person have a track record of success in implementing projects that deliver value?',
            'Establishes Political Structure. The vendor\'s own question, carried verbatim from ' +
            'AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_6.',
            BASIS_VENDOR));

        // Outside Political Structure.
        out.add(pol('AAO_POL_OPS1', 'Political · Outside · information broker',
            'Does this person collect and provide information to people of power and influence?',
            'Establishes Outside Political Structure. The vendor\'s own question, carried ' +
            'verbatim from AM_OM_POLITICAL_STATUS_GUIDED_QUESTION_7. This is the only ' +
            'proposition that places Outside, and nobody is placed there by absence of evidence.',
            BASIS_VENDOR));

        // ---- BUYER ROLE · 5 · route E · all ours, from the vendor's definition text ----
        //
        // §P8.9, ruling 1: THE CONTENT OF THE CALL, NEVER THE TITLE, IN BOTH DIRECTIONS. The
        // long-standing half is that a role is never inferred from a title. The half added on
        // 4 August is that behaviour on the call establishes.
        String behaviour =
            'Behaviour on the call establishes, and a title never does, in either direction ' +
            '(§P8.9). A person doing the thing is the thing, whatever their level or job name.';
        out.add(br('AAO_BR_APP', 'Buyer Role · Approver',
            'Does this person retain the right to review, approve or veto the decision, or to release the funds?',
            behaviour));
        out.add(br('AAO_BR_DM', 'Buyer Role · Decision Maker',
            'Does this person make the commitment to a vendor or a strategic direction?',
            behaviour));
        out.add(br('AAO_BR_EVAL', 'Buyer Role · Evaluator',
            'Is this person responsible for analysing proposed solutions against defined criteria?',
            behaviour + ' For this proposition specifically, ruled 4 August: EVALUATING ' +
            'BEHAVIOUR ON THE CALL ESTABLISHES THIS FULLY — comparing options, pressing on ' +
            'capability against a stated need, running the solution against criteria. A stated ' +
            'function with no evaluating behaviour behind it is PARTIAL.'));
        out.add(br('AAO_BR_USER', 'Buyer Role · User',
            'Does this person use, or will they use, the products or services being bought?',
            behaviour));
        out.add(br('AAO_BR_SIG', 'Buyer Role · Signature Approver',
            'Is this person the one who signs?',
            behaviour));

        // ---- DECISION CRITERIA · 3 · route E · §P8.5, tightened at v2.8 ----------------
        //
        // CRITERIA ARE SPARSE BY NATURE and often zero on a call. A read returning many is a
        // calibration alarm, not a rich harvest: the first graded fixture produced thirteen
        // candidates and Matthew's grading dissolved nearly all of them into people
        // establishments and process facts.
        String dcNegatives =
            'The negative rules bind: seller words never name a buyer criterion; a buyer\'s ' +
            'question is not a naming; a stated goal does not create a criterion; description ' +
            'of the current state carries no stance. Buying-process mechanics are never ' +
            'criteria — questionnaires to complete, documents to package, review sequences, who ' +
            'sends what to whom are Process-family material. Coaching the seller on how to win ' +
            'internal approval is never a criterion either; it is sentiment and political ' +
            'evidence about the coach. Expect zero to a few on any call.';
        out.add(new Spec(
            'AAO_DC_N',
            'Criteria · naming',
            'Did this person, in their own words, state a condition, capability or outcome and tie it to evaluating, choosing or proceeding with a solution?',
            'THE DECISION LINKAGE IS THE SHARP EDGE (§P8.5, tightened at v2.8): the condition ' +
            'must bear on CHOOSING OR JUDGING the solution or vendor. ' + dcNegatives,
            'Buyer_Side',
            BASIS_OURS,
            new List<String>{
                'An identifiable condition, capability or outcome',
                'A stance the speaker takes toward it',
                'A linkage to evaluating, choosing or proceeding with a solution'
            }
        ));
        out.add(new Spec(
            'AAO_DC_F',
            'Criteria · formal by provenance',
            'Did this person attribute the criterion to an organizational evaluation standard — a document, process, scorecard, committee or mandate?',
            'Establishes Formal. Typing is by PROVENANCE, Matthew\'s ruling: organizational ' +
            'standing spoken makes it Formal, else it stays Informal and is upgradeable. A ' +
            'naming with no such attribution defaults Informal and is not a failure.',
            'Buyer_Side',
            BASIS_OURS,
            new List<String>{ 'An attribution to an organizational evaluation standard' }
        ));
        out.add(new Spec(
            'AAO_DC_R',
            'Criteria · required',
            'Did this person state that failing this condition blocks or ends the purchase?',
            'Gate language only, and the default is unchecked. Strength of feeling is not a ' +
            'gate; the words must say that failing it stops the purchase.',
            'Buyer_Side',
            BASIS_OURS,
            new List<String>{ 'Gate language: failing this blocks or ends the purchase' }
        ));

        return out;
    }

    private static Spec pol(
        String code,
        String shortLabel,
        String proposition,
        String guidance,
        String basis
    ) {
        return new Spec(
            code, shortLabel, proposition, guidance, 'Any_Participant', basis,
            new List<String>{ proposition }
        );
    }

    private static Spec br(String code, String shortLabel, String proposition, String guidance) {
        return new Spec(
            code, shortLabel, proposition, guidance, 'Any_Participant', BASIS_OURS,
            new List<String>{ proposition }
        );
    }

    // ========================================================================= minting

    public class Result {
        public Integer minted = 0;
        public Integer unchanged = 0;
        public Integer superseded = 0;
        public List<String> codes = new List<String>();

        public override String toString() {
            return 'contracts: ' + minted + ' minted, ' + unchanged + ' unchanged, ' +
                superseded + ' superseded (unit: contracts)';
        }
    }

    /**
     * Mint the seventeen and supersede the person-crossed set.
     *
     * **Idempotent by content hash**, which is the same mechanism the reconciler will use: the
     * contract key is `code|hash`, unique and external, so re-minting unchanged text upserts
     * onto the same row and re-minting CHANGED text mints a new contract and leaves the old one
     * standing to be superseded. An in-place edit cannot hide.
     *
     * **Nothing is deleted.** The 48 move to `Superseded`, which is the mechanism already in the
     * applicable-set law, and they stay readable as the record of what ran on 24 June.
     */
    public static Result mint() {
        Result r = new Result();
        List<AAO_Evidence_Contract__c> rows = new List<AAO_Evidence_Contract__c>();

        for (Spec sp : specs()) {
            if (sp.code.length() > 18) {
                throw new ContractException(
                    'Proposition code "' + sp.code + '" is ' + sp.code.length() +
                    ' characters; the contract key composes from at most 18.'
                );
            }
            String hash = AAO_ContractKey.contentHash(sp.proposition, sp.guidance);
            rows.add(new AAO_Evidence_Contract__c(
                AAO_Proposition_Code__c = sp.code,
                AAO_Proposition_Short__c = sp.shortLabel,
                AAO_Proposition_Text__c = sp.proposition,
                AAO_Guidance_Text__c = sp.guidance,
                AAO_Elements__c = elementsJson(sp.elements),
                AAO_Element_Count__c = sp.elements.size(),
                AAO_Elements_Basis__c = sp.basis,
                AAO_Speaker_Requirement__c = sp.speakerRequirement,
                AAO_Route__c = 'E',
                AAO_Charter_Designation__c = 'People',
                AAO_Contract_State__c = 'Derived',
                AAO_Rubric_Version__c = RUBRIC_VERSION,
                AAO_Decay_Class__c = 'Standing',
                AAO_Gating__c = false,
                // Ours pending a human is exactly what ratification is for; the vendor's own
                // text needs nobody's approval to be the vendor's own text.
                AAO_Requires_Ratification__c = sp.basis == BASIS_OURS,
                AAO_Question_Record_Id__c = sp.code,
                AAO_Content_Hash__c = hash,
                AAO_Contract_Key__c = AAO_ContractKey.compose(sp.code, hash),
                AAO_Synthetic__c = AAO_Synthetic.MARK
            ));
            r.codes.add(sp.code);
        }

        Database.UpsertResult[] ups = Database.upsert(
            rows,
            AAO_Evidence_Contract__c.AAO_Contract_Key__c,
            true
        );
        for (Database.UpsertResult u : ups) {
            if (u.isCreated()) {
                r.minted++;
            } else {
                r.unchanged++;
            }
        }

        // TWO SUPERSESSIONS, NOT ONE, and the second was missing until the v2.9 label fix
        // needed it. Editing a proposition changes its content hash, so it mints a NEW row
        // and the old one keeps standing — on the SAME rubric. Superseding only the old
        // rubric would have left two live AAO_PS_1 contracts, the declared set would offer
        // sentiment twice, and call 1 would be handed the same question under two different
        // definitions. An in-place edit cannot hide, and now neither can its predecessor.
        Set<String> minted = new Set<String>();
        for (AAO_Evidence_Contract__c ec : rows) {
            minted.add(ec.AAO_Contract_Key__c);
        }
        List<AAO_Evidence_Contract__c> old = [
            SELECT Id, AAO_Contract_Key__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Contract_State__c != 'Superseded'
                AND (AAO_Rubric_Version__c = :SUPERSEDES_RUBRIC
                    OR (AAO_Rubric_Version__c = :RUBRIC_VERSION
                        AND AAO_Contract_Key__c NOT IN :minted))
        ];
        for (AAO_Evidence_Contract__c ec : old) {
            ec.AAO_Contract_State__c = 'Superseded';
        }
        if (!old.isEmpty()) {
            update old;
            r.superseded = old.size();
        }
        return r;
    }

    private static String elementsJson(List<String> elements) {
        List<Object> out = new List<Object>();
        Integer i = 0;
        for (String e : elements) {
            i++;
            out.add(new Map<String, Object>{ 'id' => 'e' + i, 'text' => e });
        }
        return JSON.serialize(out);
    }
}
