/**
 * THE CARD WRITER. Problems become `ALTF__Insight_Card__c` rows on the deal.
 *
 * The forty-sixth stamp's ratified draft, built against a real harvest rather than a guess: the
 * first Project Farma run with meanings declared produced sixteen upheld Problems establishments,
 * and every rule below was written with those rows in front of it.
 *
 * WHAT A CARD IS, per the draft: one sentence or less on the face, in the speaker's own terms,
 * understandable at a glance; the citation and the full words in the detail fields; the receipt on
 * the claim, as everywhere. **Admission carries no materiality judgment** (forty-second stamp): a
 * card is admitted because a person genuinely said the thing, and the size of the thing is not a
 * gate anywhere in this class.
 *
 * WHAT THIS CLASS DOES NOT DO, each because it is somebody else's ruled job: it does not judge
 * TYPE (call 3 did that, and the contract is the type), it does not touch a human-authored card,
 * and it writes no edge beyond the person-to-insight link the thin Politics slice ruled in.
 */
public with sharing class AAO_Cards {
    public class CardException extends Exception {
    }

    /** The face is one sentence or less. Long enough to mean something, short enough to scan. */
    private static final Integer FACE_MAX = 160;

    public class Outcome {
        public Id opportunityId;
        public Integer answersRead = 0;
        public Integer created = 0;
        public Integer reinforced = 0;
        public Integer unchanged = 0;
        public Integer contradictionsFlagged = 0;
        public Integer linksWritten = 0;
        public Integer linksHeld = 0;
        /** Cards given a section membership, which is what makes them render at all. */
        public Integer placedOnBoard = 0;
        /** Dated sections created for this run's calls. */
        public Integer sectionsCreated = 0;
        /** Owner links written: responsible on initiatives, impacted on obstacles and pressures. */
        public Integer ownerLinksWritten = 0;
        /** Our own duplicate cards retired: same evidence, face drifted between runs. */
        public Integer spuriousRetired = 0;
        public List<String> notes = new List<String>();

        public override String toString() {
            return 'cards: ' + created + ' created, ' + reinforced + ' reinforced, ' +
                unchanged + ' unchanged, ' + contradictionsFlagged + ' contradictions flagged; ' +
                'links: ' + linksWritten + ' written, ' + linksHeld + ' held; placed on board: ' +
                placedOnBoard + ' in ' + sectionsCreated + ' new section(s); owner links: ' +
                ownerLinksWritten + '; duplicates retired: ' + spuriousRetired +
                (notes.isEmpty() ? '' : '\n  ' + String.join(notes, '\n  '));
        }
    }

    /**
     * One deal's cards, from its standing upheld Problems answers.
     *
     * Reads answers rather than pairs on purpose: an answer is the established thing, carries the
     * accumulation, and is what survives a rerun. A pair is one read's proposal.
     */
    /**
     * The card writer with its run named, so its leg reaches the run receipt.
     *
     * The last stage of the pass to get one, and it was owed and named rather than forgotten:
     * `AAO_Receipt.STAGE_CARDS` has been declared and unwired since the sixty-seventh stamp.
     * An overload rather than a changed signature, the same shape projection took, because the
     * writer is keyed on the DEAL — it writes the board's current state from standing pairs, not
     * one run's output — and the run key is telemetry here saying which pass paid for the time.
     */
    public static Outcome run(Id opportunityId, String runKey) {
        Long startedAt = System.currentTimeMillis();
        Outcome o = run(opportunityId);
        AAO_Receipt.record(
            runKey, AAO_Receipt.sourceForRun(runKey), AAO_Receipt.STAGE_CARDS,
            System.currentTimeMillis() - startedAt, o.created + o.reinforced + o.unchanged
        );
        return o;
    }

    public static Outcome run(Id opportunityId) {
        if (opportunityId == null) {
            throw new CardException('Cannot write cards with no opportunity.');
        }
        Outcome o = new Outcome();
        o.opportunityId = opportunityId;
        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId].AccountId;

        // THE GRAIN IS ONE CARD PER DISTINCT INSIGHT, forty-ninth stamp item 3(b).
        //
        // This reads PAIRS rather than answers, and the choice is the engineering call the stamp
        // left to CODE inside the ruling. The answer key is subject plus contract, so every Goal
        // one person voiced collapses into a single Goal answer: sixteen upheld establishments
        // became four cards, and Adam's ninety-million target, key-account move and internal
        // connectivity gap showed as one. A pair is one establishment from one stretch of words,
        // which is exactly what a card is. The cost is honest and named: a pair is one read's
        // proposal, so the accumulation an answer carries is not behind these rows; the CLAIM is
        // still the receipt, and the verdict read here is the one call 3 upheld.
        List<AAO_Pair__c> established = [
            SELECT Id, AAO_Pair_Ref__c, AAO_Source__c,
                AAO_Source__r.AAO_Evidence_Occurred__c, AAO_Source__r.AAO_Source_Ref__c,
                AAO_Source__r.AAO_Meeting_Title__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Person__c, AAO_Person__r.AAO_Display_Name__c,
                AAO_Person__r.AAO_Internal__c, AAO_Person__r.AAO_Contact__c,
                AAO_Located_Pair__r.AAO_Answer_Text__c,
                // THE BYTE RANGE, selected off the LOCATED row because the identified
                // disposition carries none: layer 1 tests OVERLAP now, not equality, and
                // overlap is arithmetic on offsets rather than a comparison of strings.
                AAO_Located_Pair__r.AAO_Start_Offset__c,
                AAO_Located_Pair__r.AAO_End_Offset__c
            FROM AAO_Pair__c
            WHERE AAO_Source__r.AAO_Opportunity__c = :opportunityId
                AND AAO_Stage__c = :AAO_PairKey.IDENTIFIED
                AND AAO_Verification__c = 'Upheld'
                AND AAO_Evidence_Contract__r.AAO_Family__c = 'Problems'
            ORDER BY AAO_Source__r.AAO_Evidence_Occurred__c ASC, Id ASC
        ];
        o.answersRead = established.size();
        if (established.isEmpty()) {
            return o;
        }

        // THE FACE CALL RUNS BEFORE ANY DML IN THIS METHOD, and the position is load-bearing
        // rather than tidy. A callout after DML throws "uncommitted work pending", and the
        // duplicate-retirement below is a DELETE. While the collapse only fired on exact
        // repeats it almost never had anything to delete, so the ordering was wrong and
        // unreachable at the same time; extending layer 1 to overlaps makes it reachable on the
        // very next Emerson write. Found by reading the order rather than by the run failing,
        // which is the cheaper way to find it.
        //
        // THE FACE IS INFERRED, forty-ninth stamp item 3(a). One batched call over the whole
        // harvest, so the model writes the headlines and the writer never puts a raw verbatim on
        // the face again. The words themselves are untouched and go to `Long_Description`.
        Map<String, AAO_CardFace.Face> headline = AAO_CardFace.infer(established);

        // ---- read before write: the deal's standing cards, ours and theirs ------------------
        //
        // DEDUP-AWARE WRITING IS THE STANDING DISCIPLINE (forty-second stamp), so the compare
        // happens against everything already on the deal rather than only against what this run
        // wrote. Human-authored cards are in this set and are never edited: they can only be
        // reinforced beside, per the annotation law.
        List<ALTF__Insight_Card__c> standing = [
            SELECT Id, ALTF__Type__c, ALTF__Short_Description__c, ALTF__Long_Description__c,
                ALTF__Note__c, ALTF__Generated_By_Max__c
            FROM ALTF__Insight_Card__c
            WHERE ALTF__Opportunity__c = :opportunityId
        ];
        // TWO LAYERS, AND BOTH ARE REQUIRED (sixty-first stamp item 2).
        //
        // LAYER 1, IDENTITY, byte-stable: a card is identified by the EVIDENCE it was drawn
        // from, never by its face. The face is a fresh model call every run, so keying on it
        // made a reworded face read as a new insight and the board inflated from 12 cards to 14
        // on a harvest with nothing new established. Same evidence, same card, forever.
        //
        // LAYER 2, MEANING, unchanged and NOT replaced by layer 1: "the same problem restated in
        // new words is reinforcement, not a new card". That compares DIFFERENT evidence, a later
        // call saying the same thing in new words, and it is the reinforcement mechanic. A
        // byte-only key would silently retire it and turn every restatement into a duplicate the
        // first time a second call lands, so layer 1 sits BENEATH layer 2, never instead of it.
        //
        // **LAYER 1 TESTS OVERLAP, NOT EQUALITY (eightieth stamp), and the specimen is why.**
        // Two Obstacle cards stood on the 29 July Emerson call, both Jefferson Vargas: one drawn
        // from bytes 9775-10048 and one from 9919-10048, the second quote a literal SUBSTRING of
        // the first. One utterance, two reads, two boundaries, two cards on a board a customer
        // would read. An equality key lets that through; an intersection key catches it. Same
        // rule, same arithmetic and same reason as the answer counter's, because a card and a
        // reinforcement count are two readings of the one question "how many distinct things did
        // this person say".
        Map<String, ALTF__Insight_Card__c> byEvidence = new Map<String, ALTF__Insight_Card__c>();
        Map<String, ALTF__Insight_Card__c> byMeaning = new Map<String, ALTF__Insight_Card__c>();
        List<ALTF__Insight_Card__c> spurious = new List<ALTF__Insight_Card__c>();

        // The evidence a standing card was drawn from, recovered by matching its stored verbatim
        // back to the pair that wrote it. The CARD carries no offsets - putting engineering
        // numbers in a customer-facing detail field would be the wrong trade - so the harvest is
        // where the range comes from, and the harvest is the source of truth anyway.
        Map<String, AAO_Pair__c> pairByEvidence = new Map<String, AAO_Pair__c>();
        for (AAO_Pair__c a : established) {
            String type = AAO_P8Codes.problemType(a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c);
            String words = a.AAO_Located_Pair__r == null
                ? null
                : a.AAO_Located_Pair__r.AAO_Answer_Text__c;
            if (type == null || String.isBlank(words)) {
                continue;
            }
            String ek = evidenceKey(type, words);
            if (!pairByEvidence.containsKey(ek)) {
                pairByEvidence.put(ek, a);
            }
        }

        List<Held> held = new List<Held>();
        for (ALTF__Insight_Card__c c : standing) {
            byMeaning.put(meaningKey(c.ALTF__Type__c, c.ALTF__Short_Description__c), c);
            String v = verbatimOf(c.ALTF__Long_Description__c);
            if (String.isBlank(v)) {
                // No marker means this card is not one of ours. A human's card is never
                // identified, never collapsed, never touched.
                continue;
            }
            String ek = evidenceKey(c.ALTF__Type__c, v);
            Held overlap = overlapping(held, c.ALTF__Type__c, pairByEvidence.get(ek));
            if (byEvidence.containsKey(ek) || overlap != null) {
                // TWO OF OUR CARDS ON ONE UTTERANCE, which is the inflation this fix ends: the
                // same words carded twice because the face was reworded between runs, or the two
                // reads drew different boundaries around one sentence. The elder is the parent
                // and stands; the younger is retired at the next write rather than deleted by
                // hand. Deleting the CARD takes its own junctions with it, which is the safe
                // direction; deleting junctions cascades the other way.
                spurious.add(c);
                continue;
            }
            byEvidence.put(ek, c);
            Held h = heldFor(c.ALTF__Type__c, pairByEvidence.get(ek));
            if (h != null) {
                held.add(h);
            }
        }
        if (!spurious.isEmpty()) {
            delete spurious;
            o.spuriousRetired = spurious.size();
            o.notes.add(spurious.size() + ' duplicate card(s) retired: the same utterance was ' +
                'already carded, by identical words or by an overlapping byte range.');
        }

        List<ALTF__Insight_Card__c> fresh = new List<ALTF__Insight_Card__c>();
        List<AAO_Pair__c> freshSource = new List<AAO_Pair__c>();
        Map<Id, ALTF__Insight_Card__c> patchById = new Map<Id, ALTF__Insight_Card__c>();
        Map<String, Integer> seenThisRun = new Map<String, Integer>();

        String decisionMaker = decisionMakerOn(opportunityId);

        for (AAO_Pair__c a : established) {
            String code = a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
            String type = AAO_P8Codes.problemType(code);
            if (type == null) {
                o.notes.add('No card type for ' + code + '; skipped rather than guessed.');
                continue;
            }
            // OUR OWN SIDE NEVER BECOMES A CARD. Seller words never establish a buyer's problem,
            // which the contracts say and the join's internal-subject gate already enforces;
            // this is the belt beside that brace, because a card is customer-visible.
            if (a.AAO_Person__r != null && a.AAO_Person__r.AAO_Internal__c == true) {
                o.notes.add('Internal speaker establishment skipped: no card for our own side.');
                continue;
            }
            String words = a.AAO_Located_Pair__r == null
                ? null
                : a.AAO_Located_Pair__r.AAO_Answer_Text__c;
            if (String.isBlank(words)) {
                o.notes.add('Pair ' + a.AAO_Pair_Ref__c + ' carries no words; no card written.');
                continue;
            }
            // Keyed by pair Id: the ref is unique per RUN only, and this writer reads every
            // run on the deal. See AAO_CardFace for what the collision cost on the WF stack.
            AAO_CardFace.Face inferred = headline.get(a.Id);
            String face = inferred == null ? faceFrom(words) : inferred.face;
            String summary = inferred == null ? null : inferred.summary;

            // LAYER 1 FIRST. This establishment already has a card, whatever the face says
            // today. Nothing is written and nothing is counted as reinforcement: a rerun of the
            // same words is not the buyer saying it twice, and neither is a second read drawing
            // a wider or narrower boundary around one sentence.
            String idKey = evidenceKey(type, words);
            if (byEvidence.containsKey(idKey)) {
                o.unchanged++;
                continue;
            }
            Held collides = overlapping(held, type, a);
            if (collides != null) {
                o.unchanged++;
                o.notes.add('Pair ' + a.AAO_Pair_Ref__c + ' overlaps bytes already carded (' +
                    collides.startOffset + '-' + collides.endOffset + '); one utterance, one ' +
                    'card. No card written.');
                continue;
            }
            String key = meaningKey(type, face);

            if (byMeaning.containsKey(key)) {
                // SAME TYPE, SAME MEANING IS REINFORCEMENT. The parent card is kept and its
                // text is never rewritten; the count rides the note, which is the only field
                // the reinforcement mechanics may touch. Human-authored cards are reinforced
                // beside in exactly this way and never edited otherwise.
                Integer n = seenThisRun.containsKey(key) ? seenThisRun.get(key) : 1;
                n++;
                seenThisRun.put(key, n);
                ALTF__Insight_Card__c parent = byMeaning.get(key);
                String reiteration = citation(a) + ' reiterated this.';
                String note = parent.ALTF__Note__c == null ? '' : parent.ALTF__Note__c;
                if (note.contains(reiteration)) {
                    o.unchanged++;
                    continue;
                }
                parent.ALTF__Note__c =
                    ('Said ' + n + ' times. ' + note + ' ' + reiteration).trim().abbreviate(255);
                patchById.put(parent.Id, parent);
                o.reinforced++;
                continue;
            }

            // SAME TYPE, DIFFERENT MEANING IS A NEW CARD. Completely different language is a
            // different insight, as ruled, so nothing here tries to be clever about paraphrase.
            ALTF__Insight_Card__c card = new ALTF__Insight_Card__c(
                ALTF__Opportunity__c = opportunityId,
                ALTF__Account__c = accountId,
                ALTF__Type__c = type,
                ALTF__Short_Description__c = face,
                ALTF__Long_Description__c = details(summary, a, words, type, decisionMaker),
                ALTF__Note__c = citation(a) + '.'
            );
            fresh.add(card);
            freshSource.add(a);
            byMeaning.put(key, card);
            byEvidence.put(idKey, card);
            // AND THE RANGE IS CLAIMED IMMEDIATELY, before the next establishment is read. The
            // CFO pair was written in ONE batch from one harvest, so a check that only consulted
            // cards standing before the run would have let it through again.
            Held h = heldFor(type, a);
            if (h != null) {
                held.add(h);
            }
            seenThisRun.put(key, 1);
        }

        if (!fresh.isEmpty()) {
            insert fresh;
            o.created = fresh.size();
            // The Name convention the vendor's own records follow: the record's own fifteen
            // character Id, not a label. A card written without it renders wrong in their UI,
            // the same trap the criteria write documents.
            List<ALTF__Insight_Card__c> named = new List<ALTF__Insight_Card__c>();
            for (ALTF__Insight_Card__c c : fresh) {
                named.add(new ALTF__Insight_Card__c(
                    Id = c.Id, Name = String.valueOf(c.Id).substring(0, 15)
                ));
            }
            update named;
            attachToBoard(opportunityId, accountId, fresh, freshSource, o);
        }
        if (!patchById.isEmpty()) {
            update patchById.values();
        }

        writeLinks(fresh, freshSource, o);
        writeOwnerLinks(opportunityId, o);
        return o;
    }

    /**
     * THE PERSON-TO-INSIGHT LINK, the thin Politics slice: who said it.
     *
     * `Informer` rather than `Owner`, deliberately. The evidence establishes that this person
     * VOICED the thing; whose goal or obstacle it ultimately is, is a different assertion nobody
     * ruled, and the vendor's own vocabulary keeps them apart.
     *
     * THE BOTH-ENDPOINTS LAW RIDES: a link writes only where the person resolves to a Contact and
     * the card exists. A missing endpoint HOLDS with its evidence rather than writing half a link,
     * and the hold is counted so it is visible in the run report.
     */
    private static void writeLinks(
        List<ALTF__Insight_Card__c> cards,
        List<AAO_Pair__c> sources,
        Outcome o
    ) {
        List<ALTF__Insight_Card_Contact__c> links = new List<ALTF__Insight_Card_Contact__c>();
        for (Integer i = 0; i < cards.size(); i++) {
            AAO_Pair__c a = sources[i];
            Id contactId = a.AAO_Person__r == null ? null : a.AAO_Person__r.AAO_Contact__c;
            if (contactId == null || cards[i].Id == null) {
                o.linksHeld++;
                o.notes.add(
                    'Link held: ' +
                    (a.AAO_Person__r == null ? 'a speaker' : a.AAO_Person__r.AAO_Display_Name__c) +
                    ' reaches no Contact, so the card stands with its evidence and the link waits.'
                );
                continue;
            }
            links.add(new ALTF__Insight_Card_Contact__c(
                ALTF__Insight_Card__c = cards[i].Id,
                ALTF__Contact__c = contactId,
                ALTF__Type__c = 'Informer'
            ));
        }
        if (links.isEmpty()) {
            return;
        }
        insert links;
        o.linksWritten = links.size();
        List<ALTF__Insight_Card_Contact__c> named = new List<ALTF__Insight_Card_Contact__c>();
        for (ALTF__Insight_Card_Contact__c l : links) {
            named.add(new ALTF__Insight_Card_Contact__c(
                Id = l.Id, Name = String.valueOf(l.Id).substring(0, 15)
            ));
        }
        update named;
    }

    /**
     * THE OWNER LINKS: who is responsible for, or impacted by, each card.
     *
     * **`Owner` IS THE VENDOR'S OWN WORD FOR BOTH**, and that is evidence rather than inference.
     * `ALTF__Insight_Card_Contact__c.ALTF__Type__c`'s description reads: *"informer (who told you
     * about it) or an owner (someone who is impacted and/or responsible for the success of an
     * initiative)"*. The panel slots differ only in label; they all bind this one link type. An
     * earlier stretch parked this question rather than guess the mapping, and the field's own
     * description turned out to be the missing byte.
     *
     * MATTHEW'S RULING ON WHO LINKS WHERE, fifty-ninth stamp, keyed on ESTABLISHED map values so
     * nothing here adds a new inference on top of one:
     *   INITIATIVES  responsible: Evaluator OR ABOVE, because they are engaged to evaluate,
     *                approve or decide it.
     *   OBSTACLES and PRESSURES  impacted: Users. (The functional-team half rides the card-time
     *                model call in its own stretch; the role-based half is deterministic and
     *                ships first.)
     *   GOALS        owners ONLY: a Decision Maker, or a person explicitly stated as owner of
     *                the metric. No one else is linked to a Goal, and where nobody qualifies the
     *                slot stays EMPTY: blank beats wrong.
     *
     * **A HUMAN LINK IS NEVER TOUCHED.** This adds links that do not exist and edits none, which
     * is also how it stays idempotent across reruns. Noted honestly: the vendor's link object
     * carries no field we could watermark, so "machine-written" cannot be stamped on the row
     * itself; the protection is that nothing existing is ever modified or deleted.
     */
    private static void writeOwnerLinks(Id opportunityId, Outcome o) {
        // The ESTABLISHED role per person, read off the map the projection already wrote.
        Map<Id, String> roleByContact = new Map<Id, String>();
        for (ALTF__Contact_Map_Details__c m : [
            SELECT ALTF__Contact__c, ALTF__Buyer_Role__c
            FROM ALTF__Contact_Map_Details__c
            WHERE ALTF__Opportunity__c = :opportunityId
                AND ALTF__Contact__c != null
                AND ALTF__Buyer_Role__c != null
        ]) {
            roleByContact.put(m.ALTF__Contact__c, m.ALTF__Buyer_Role__c);
        }
        if (roleByContact.isEmpty()) {
            o.notes.add('No established buyer roles on the map, so no Owner links: the map is ' +
                'what this reads and it knows nobody yet.');
            return;
        }

        List<ALTF__Insight_Card__c> cards = [
            SELECT Id, ALTF__Type__c FROM ALTF__Insight_Card__c
            WHERE ALTF__Opportunity__c = :opportunityId
        ];
        Set<String> standing = new Set<String>();
        for (ALTF__Insight_Card_Contact__c l : [
            SELECT ALTF__Insight_Card__c, ALTF__Contact__c, ALTF__Type__c
            FROM ALTF__Insight_Card_Contact__c
            WHERE ALTF__Insight_Card__r.ALTF__Opportunity__c = :opportunityId
        ]) {
            standing.add(l.ALTF__Insight_Card__c + '|' + l.ALTF__Contact__c + '|' + l.ALTF__Type__c);
        }

        List<ALTF__Insight_Card_Contact__c> fresh = new List<ALTF__Insight_Card_Contact__c>();
        for (ALTF__Insight_Card__c c : cards) {
            for (Id contactId : roleByContact.keySet()) {
                if (!ownerQualifies(c.ALTF__Type__c, roleByContact.get(contactId))) {
                    continue;
                }
                String key = c.Id + '|' + contactId + '|Owner';
                if (standing.contains(key)) {
                    continue;
                }
                standing.add(key);
                fresh.add(new ALTF__Insight_Card_Contact__c(
                    ALTF__Insight_Card__c = c.Id,
                    ALTF__Contact__c = contactId,
                    ALTF__Type__c = 'Owner'
                ));
            }
        }
        if (fresh.isEmpty()) {
            o.notes.add('No Owner links qualified: nobody on the map holds a role the ruling ' +
                'links for these card types. Blank beats wrong.');
            return;
        }
        insert fresh;
        List<ALTF__Insight_Card_Contact__c> named = new List<ALTF__Insight_Card_Contact__c>();
        for (ALTF__Insight_Card_Contact__c l : fresh) {
            named.add(new ALTF__Insight_Card_Contact__c(
                Id = l.Id, Name = String.valueOf(l.Id).substring(0, 15)
            ));
        }
        update named;
        o.ownerLinksWritten = fresh.size();
    }

    /** Matthew's assignment table, as a function. Anything not named here links nobody. */
    @TestVisible
    private static Boolean ownerQualifies(String cardType, String buyerRole) {
        if (cardType == 'Initiative') {
            // Evaluator OR ABOVE. The approver roles count where the map established them.
            return buyerRole == 'Evaluator' || buyerRole == 'Decision Maker' ||
                buyerRole == 'Approver' || buyerRole == 'Signature Approver';
        }
        if (cardType == 'Obstacle' || cardType == 'Pressure') {
            return buyerRole == 'User';
        }
        if (cardType == 'Goal') {
            // ONLY a Decision Maker deterministically. The stated-metric-owner case is words,
            // not a role, so it rides the model leg and is not guessed at from a map value.
            return buyerRole == 'Decision Maker';
        }
        return false;
    }

    /**
     * THE CALL'S OWN SECTION, and the cards packed from the top of each lane.
     *
     * Matthew's ruling, fifty-first stamp, from reading the live board: the machine's cards from
     * a given source land in THEIR OWN section titled for the call, never in the deal's default
     * column, and each lane packs Y = 1, 2, 3 with no gaps so the most possible cards sit above
     * the fold. The board then reads left to right as a timeline of conversations.
     *
     * THE CONTINUE-BELOW POLICY IS SUPERSEDED WHERE IT CAUSED THE SPRAWL. It survives only inside
     * a lane already carrying this section's own standing cards, which is a rerun adding to the
     * same call; across sections it produced the scattered column Matthew read.
     *
     * HUMAN SECTIONS AND HUMAN CARDS ARE NEVER TOUCHED OR REPOSITIONED. This creates its own
     * section and writes only its own placements; the deal's default column is handed back
     * untouched, per the annotation law's spirit.
     */
    private static void attachToBoard(
        Id opportunityId,
        Id accountId,
        List<ALTF__Insight_Card__c> cards,
        List<AAO_Pair__c> sources,
        Outcome o
    ) {
        // Grouped by SOURCE, because a section is a call and a run can carry more than one.
        Map<Id, List<ALTF__Insight_Card__c>> bySource =
            new Map<Id, List<ALTF__Insight_Card__c>>();
        Map<Id, AAO_Source__c> sourceRow = new Map<Id, AAO_Source__c>();
        for (Integer i = 0; i < cards.size(); i++) {
            AAO_Pair__c p = sources[i];
            Id srcId = p.AAO_Source__c;
            if (srcId == null) {
                o.notes.add('A card has no source, so it gets no dated section; placement held.');
                continue;
            }
            if (!bySource.containsKey(srcId)) {
                bySource.put(srcId, new List<ALTF__Insight_Card__c>());
            }
            bySource.get(srcId).add(cards[i]);
            sourceRow.put(srcId, p.AAO_Source__r);
        }
        if (bySource.isEmpty()) {
            return;
        }

        List<ALTF__Insight_Card_Section__c> memberships =
            new List<ALTF__Insight_Card_Section__c>();
        for (Id srcId : bySource.keySet()) {
            ALTF__Insight_Section__c section = sectionFor(
                opportunityId, accountId, sourceRow.get(srcId), null, o
            );
            memberships.addAll(
                pack(section, bySource.get(srcId), o)
            );
        }
        if (memberships.isEmpty()) {
            return;
        }
        insert memberships;
        nameRows(memberships);
        o.placedOnBoard = memberships.size();
    }

    /**
     * The section for one call, found by title or created.
     *
     * THE TITLE IS THE CALL'S DATE AND TYPE, "30 July 2026: Discovery Call" in shape. **No field
     * on `AAO_Source__c` carries a call type today** (`AAO_Origin__c` holds the ingest origin,
     * `ECI`, which is how the bytes arrived and not what kind of conversation it was), so the
     * ruling's own fallback applies and the title is the DATE ALONE until a source can say. That
     * gap is named in the run report rather than papered over with a guess, because a section
     * mis-titled "Discovery Call" on a renewal call is worse than one titled by date.
     */
    @TestVisible
    private static ALTF__Insight_Section__c sectionFor(
        Id opportunityId,
        Id accountId,
        AAO_Source__c src,
        String callType,
        Outcome o
    ) {
        String title = sectionTitle(src, callType);
        String datePrefix = sectionTitle(src, null);
        // MATCHED ON THE CALL'S DATE, NOT ON THE EXACT TITLE, and that is a defect fix rather
        // than a convenience. The first cut matched the whole string, so once a human retitled
        // the call's section "30 July 2026: Discovery Call" the writer no longer recognised it,
        // created a SECOND section titled "30 July 2026", and left the retitled one standing
        // empty beside it. Matthew saw the two columns on the board. A section belongs to a
        // CALL, the call's date is what identifies it, and a human's better title for it must
        // survive the next run rather than be shadowed by one of ours.
        for (ALTF__Insight_Section__c existing : [
            SELECT Id, ALTF__X_Coordinate__c, ALTF__Short_Description__c
            FROM ALTF__Insight_Section__c
            WHERE ALTF__Opportunity__c = :opportunityId
            ORDER BY ALTF__X_Coordinate__c ASC NULLS LAST
        ]) {
            String label = existing.ALTF__Short_Description__c;
            if (String.isNotBlank(label) &&
                (label == title || label.startsWith(datePrefix))) {
                return existing;
            }
        }
        // A NEW COLUMN TO THE RIGHT OF EVERYTHING STANDING, so calls read left to right in the
        // order they were added and no existing column is displaced.
        Decimal nextX = 0;
        for (ALTF__Insight_Section__c existing : [
            SELECT ALTF__X_Coordinate__c FROM ALTF__Insight_Section__c
            WHERE ALTF__Opportunity__c = :opportunityId
        ]) {
            if (existing.ALTF__X_Coordinate__c != null &&
                existing.ALTF__X_Coordinate__c > nextX) {
                nextX = existing.ALTF__X_Coordinate__c;
            }
        }
        nextX = nextX + 1;
        ALTF__Insight_Section__c section = new ALTF__Insight_Section__c(
            ALTF__Opportunity__c = opportunityId,
            ALTF__Account__c = accountId,
            ALTF__Short_Description__c = title,
            ALTF__X_Coordinate__c = nextX
        );
        insert section;
        update new ALTF__Insight_Section__c(
            Id = section.Id, Name = String.valueOf(section.Id).substring(0, 15)
        );
        o.sectionsCreated++;
        o.notes.add('Section created: "' + title + '".');
        return section;
    }

    /**
     * Public so the PURGE can ask the writer what it would have titled a section, rather than
     * re-deriving the rule and drifting from it. One implementation, two readers - the same
     * reason `sectionFor` matches on this instead of on a string it composes itself.
     */
    public static String sectionTitle(AAO_Source__c src, String callType) {
        Datetime occurred = src == null ? null : src.AAO_Evidence_Occurred__c;
        String d = occurred == null ? 'Undated call' : occurred.format('d MMMM yyyy');
        // THE MEETING TITLE, carried by intake from the source system and never inferred
        // (fifty-seventh stamp item 2). An explicit callType still wins where a caller passes
        // one; otherwise the source's own title is used; otherwise the date alone, which is the
        // ruled fallback and is honest rather than a shortfall.
        String label = callType;
        if (String.isBlank(label) && src != null) {
            label = src.AAO_Meeting_Title__c;
        }
        return String.isBlank(label) ? d : d + ': ' + label.trim();
    }

    /**
     * THE GRID: within each type row, cards go side by side up to THREE ACROSS, then wrap.
     *
     * Matthew's refinement, fifty-third stamp, from reading the rendered board: the first packing
     * put one card per line and let each lane drift rightward, so five Obstacles were five lines
     * deep. His math, verbatim: for the nth card of a lane, one-based,
     * `X = ((n-1) mod 3) + 1` and `Y = ((n-1) div 3) + 1`, scoped to the lane inside the
     * machine's section. Five Obstacles therefore render three wide then two wide, all above the
     * fold, which is the whole point of the rule.
     *
     * THE LANE IS THE CARD'S TYPE AND THE BOARD GROUPS BY IT ITSELF, so the type is not encoded
     * in a coordinate: X and Y position a card INSIDE its type row. The previous cut spent X on
     * the lane, which is what made the rows drift.
     */
    private static List<ALTF__Insight_Card_Section__c> pack(
        ALTF__Insight_Section__c section,
        List<ALTF__Insight_Card__c> cards,
        Outcome o
    ) {
        // Cards already standing in THIS section, counted per type. Continue-below survives here
        // and nowhere else: a rerun adding to the same call must not sit on that call's own
        // cards. Across sections it caused the sprawl and is superseded.
        Map<String, Integer> takenByType = new Map<String, Integer>();
        for (ALTF__Insight_Card_Section__c m : [
            SELECT ALTF__Insight_Card__r.ALTF__Type__c
            FROM ALTF__Insight_Card_Section__c
            WHERE ALTF__Insight_Section__c = :section.Id
        ]) {
            String t = m.ALTF__Insight_Card__r == null
                ? ''
                : m.ALTF__Insight_Card__r.ALTF__Type__c;
            takenByType.put(t, (takenByType.containsKey(t) ? takenByType.get(t) : 0) + 1);
        }

        List<ALTF__Insight_Card_Section__c> out = new List<ALTF__Insight_Card_Section__c>();
        for (ALTF__Insight_Card__c c : cards) {
            String t = c.ALTF__Type__c;
            Integer n = (takenByType.containsKey(t) ? takenByType.get(t) : 0) + 1;
            takenByType.put(t, n);
            out.add(new ALTF__Insight_Card_Section__c(
                ALTF__Insight_Card__c = c.Id,
                ALTF__Insight_Section__c = section.Id,
                ALTF__X_Coordinate__c = gridX(n),
                ALTF__Y_Coordinate__c = gridY(n)
            ));
        }
        return out;
    }

    /** Cards per line inside a type row. Matthew's number, read off the rendered board. */
    @TestVisible
    private static final Integer ACROSS = 3;

    @TestVisible
    private static Integer gridX(Integer n) {
        return Math.mod(n - 1, ACROSS) + 1;
    }

    @TestVisible
    private static Integer gridY(Integer n) {
        return ((n - 1) / ACROSS) + 1;
    }

    /** The lane order the board reads in. Unknown types land right of the four ruled ones. */
    @TestVisible
    private static Decimal laneFor(String type) {
        if (type == 'Goal') { return 1; }
        if (type == 'Pressure') { return 2; }
        if (type == 'Initiative') { return 3; }
        if (type == 'Obstacle') { return 4; }
        return 5;
    }

    private static void nameRows(List<ALTF__Insight_Card_Section__c> rows) {
        List<ALTF__Insight_Card_Section__c> named = new List<ALTF__Insight_Card_Section__c>();
        for (ALTF__Insight_Card_Section__c m : rows) {
            named.add(new ALTF__Insight_Card_Section__c(
                Id = m.Id, Name = String.valueOf(m.Id).substring(0, 15)
            ));
        }
        update named;
    }

    /**
     * THE DETAILS, three layers in the ruled order (fifty-fourth stamp item 2).
     *
     * (i) the INFERRED SUMMARY of what the headline means, model-written at card time because the
     * model already made that judgment; (ii) the CITATION LINE carrying speaker, date and source
     * name; (iii) the VERBATIM as the receipt.
     *
     * **THE CITATION IS WRITTEN INTO THIS TEXT AND NOT ONLY INTO `ALTF__Note__c`**, which is the
     * defect this closes: the citation existed on every card already and the vendor panel does
     * not surface that field, so from Matthew's seat the cards were uncited. A receipt nobody can
     * see is not a receipt.
     */
    private static String details(
        String summary,
        AAO_Pair__c a,
        String words,
        String type,
        String decisionMaker
    ) {
        List<String> layers = new List<String>();
        if (String.isNotBlank(summary)) {
            layers.add(summary);
        }
        layers.add('Source: ' + citation(a) + sourceName(a) + '.');
        layers.add('In their words: "' + words + '"');
        // Enrichment, item 4: only where the MAP already knows, and marked as ours so nobody
        // reads a machine fill as a human's answer. Blank where the map does not know, because
        // guessing the accountable person is the inference this whole build refuses.
        if (type == 'Goal' && String.isNotBlank(decisionMaker)) {
            layers.add(
                'Decision Maker responsible (from the relationship map, machine-written): ' +
                decisionMaker + '.'
            );
        }
        return String.join(layers, '\n\n');
    }

    private static String sourceName(AAO_Pair__c a) {
        return a.AAO_Source__r == null || String.isBlank(a.AAO_Source__r.AAO_Source_Ref__c)
            ? ''
            : ', ' + a.AAO_Source__r.AAO_Source_Ref__c;
    }

    /** The map's Decision Maker on this deal, or null where the map does not know one. */
    private static String decisionMakerOn(Id opportunityId) {
        List<ALTF__Contact_Map_Details__c> dm = [
            SELECT ALTF__Contact__r.Name
            FROM ALTF__Contact_Map_Details__c
            WHERE ALTF__Opportunity__c = :opportunityId
                AND ALTF__Buyer_Role__c = 'Decision Maker'
            LIMIT 2
        ];
        // Never pick between two, the standing rule wherever the map is ambiguous.
        return dm.size() == 1 ? dm[0].ALTF__Contact__r.Name : null;
    }

    // ------------------------------------------------------------------------ internals

    /**
     * The card face: one sentence or less, in the speaker's own terms.
     *
     * Derived from the establishing words rather than from a fresh model call, and the reason is
     * the evidence law rather than thrift: the words are what was verified, so a face taken from
     * them cannot drift from what call 3 upheld. It cuts at the first sentence boundary and
     * falls back to a length bound, so a rambling establishment still yields something scannable
     * while the FULL words stay on the card in `Long_Description`.
     */
    @TestVisible
    private static String faceFrom(String words) {
        String w = words.trim().replaceAll('\\s+', ' ');
        for (String stop : new List<String>{ '. ', '? ', '! ' }) {
            Integer at = w.indexOf(stop);
            if (at > 0 && at < FACE_MAX) {
                return w.substring(0, at + 1).trim();
            }
        }
        if (w.length() <= FACE_MAX) {
            return w;
        }
        Integer cut = w.substring(0, FACE_MAX).lastIndexOf(' ');
        return (cut > 40 ? w.substring(0, cut) : w.substring(0, FACE_MAX)).trim();
    }

    /**
     * A byte range on one artifact that already carries a card of this type. Layer 1's real
     * unit: not a string, a stretch of somebody's speech.
     */
    @TestVisible
    private class Held {
        public String type;
        public Id sourceId;
        public Integer startOffset;
        public Integer endOffset;
    }

    /** The range behind an establishment, or null where the harvest cannot say. */
    private static Held heldFor(String type, AAO_Pair__c a) {
        if (a == null || a.AAO_Located_Pair__r == null) {
            return null;
        }
        return heldOf(
            type,
            a.AAO_Source__c,
            a.AAO_Located_Pair__r.AAO_Start_Offset__c,
            a.AAO_Located_Pair__r.AAO_End_Offset__c
        );
    }

    /** The same, from the values themselves, so the arithmetic is testable without DML. */
    @TestVisible
    private static Held heldOf(String type, Id sourceId, Decimal startOffset, Decimal endOffset) {
        if (startOffset == null || endOffset == null) {
            return null;
        }
        Held h = new Held();
        h.type = type;
        h.sourceId = sourceId;
        h.startOffset = Integer.valueOf(startOffset);
        h.endOffset = Integer.valueOf(endOffset);
        return h;
    }

    /**
     * The card already standing on these bytes, or null.
     *
     * SAME TYPE AND SAME SOURCE, both load-bearing. Same type, because one utterance can
     * legitimately carry an Obstacle and a Goal and those are two cards by construction, which
     * is a grading question and not a duplicate. Same source, because byte offsets are
     * per-artifact, so two calls carrying the same numbers are two different sentences - which
     * is also what makes a genuine restatement on a later call reach layer 2, where the
     * reinforcement mechanic lives.
     *
     * A range the harvest cannot supply returns null and the card is written. Undercounting a
     * board hides an insight; this rule exists to stop DOUBLE-counting, so its own uncertainty
     * resolves toward writing.
     */
    private static Held overlapping(List<Held> held, String type, AAO_Pair__c a) {
        return overlapping(held, heldFor(type, a));
    }

    @TestVisible
    private static Held overlapping(List<Held> held, Held mine) {
        if (mine == null) {
            return null;
        }
        for (Held h : held) {
            if (h.type != mine.type || h.sourceId != mine.sourceId) {
                continue;
            }
            if (h.startOffset < mine.endOffset && mine.startOffset < h.endOffset) {
                return h;
            }
        }
        return null;
    }

    /**
     * The dedup key: type plus normalised face.
     *
     * Case and inner spacing are normalised and nothing else is. "Completely different language
     * is a different insight" was ruled, so this deliberately does NOT try to detect paraphrase:
     * a writer that guessed at sameness would silently merge two things a person said.
     */
    @TestVisible
    private static String meaningKey(String type, String face) {
        String f = face == null ? '' : face.toLowerCase().replaceAll('[^a-z0-9 ]', '').trim();
        return type + '|' + f.replaceAll('\\s+', ' ');
    }

    /**
     * LAYER 1's KEY: the card's TYPE plus the EVIDENCE it was drawn from.
     *
     * The verbatim is the byte-stable half. It is the located span's own text, so the same
     * establishment yields the same string on every rerun no matter how the face is reworded,
     * which is exactly the property the face lacks and the reason the board inflated.
     */
    @TestVisible
    private static String evidenceKey(String type, String verbatim) {
        String v = verbatim == null
            ? ''
            : verbatim.toLowerCase().replaceAll('[^a-z0-9 ]', '').replaceAll('\\s+', ' ').trim();
        return type + '#' + v;
    }

    /**
     * The verbatim back out of a card's details, so a standing card can be identified by the
     * evidence behind it. Reads the layer this writer itself wrote, which is why the marker is a
     * fixed phrase rather than a guess at prose.
     */
    @TestVisible
    private static String verbatimOf(String details) {
        if (String.isBlank(details)) {
            return null;
        }
        String marker = 'In their words: "';
        Integer at = details.indexOf(marker);
        if (at < 0) {
            return null;
        }
        String tail = details.substring(at + marker.length());
        Integer close = tail.lastIndexOf('"');
        return close <= 0 ? tail : tail.substring(0, close);
    }

    /** Plain date and speaker, the ruled style. No record ids reach a human surface. */
    private static String citation(AAO_Pair__c a) {
        String who = a.AAO_Person__r == null ||
            String.isBlank(a.AAO_Person__r.AAO_Display_Name__c)
            ? 'a participant'
            : a.AAO_Person__r.AAO_Display_Name__c;
        String occurredOn = a.AAO_Source__r == null ||
            a.AAO_Source__r.AAO_Evidence_Occurred__c == null
            ? 'a call'
            : a.AAO_Source__r.AAO_Evidence_Occurred__c.format('d MMMM yyyy');
        return who + ', ' + occurredOn;
    }

    /** The verbatim words behind the establishment, from the stored spans. */
    @TestVisible
    private static String firstSpanText(String spansJson) {
        if (String.isBlank(spansJson)) {
            return null;
        }
        AAO_Model.SpanSet set0 = AAO_Model.parseSpans(spansJson);
        for (AAO_Model.Span s : set0.spans) {
            if (String.isNotBlank(s.quote)) {
                return s.quote;
            }
        }
        return null;
    }
}