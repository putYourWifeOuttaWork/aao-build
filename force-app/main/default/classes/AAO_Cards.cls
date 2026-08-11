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
        public List<String> notes = new List<String>();

        public override String toString() {
            return 'cards: ' + created + ' created, ' + reinforced + ' reinforced, ' +
                unchanged + ' unchanged, ' + contradictionsFlagged + ' contradictions flagged; ' +
                'links: ' + linksWritten + ' written, ' + linksHeld + ' held; placed on board: ' +
                placedOnBoard + ' in ' + sectionsCreated + ' new section(s)' +
                (notes.isEmpty() ? '' : '\n  ' + String.join(notes, '\n  '));
        }
    }

    /**
     * One deal's cards, from its standing upheld Problems answers.
     *
     * Reads answers rather than pairs on purpose: an answer is the established thing, carries the
     * accumulation, and is what survives a rerun. A pair is one read's proposal.
     */
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
                AAO_Source__r.AAO_Evidence_Occurred__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Person__c, AAO_Person__r.AAO_Display_Name__c,
                AAO_Person__r.AAO_Internal__c, AAO_Person__r.AAO_Contact__c,
                AAO_Located_Pair__r.AAO_Answer_Text__c
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
        Map<String, ALTF__Insight_Card__c> byMeaning = new Map<String, ALTF__Insight_Card__c>();
        for (ALTF__Insight_Card__c c : standing) {
            byMeaning.put(meaningKey(c.ALTF__Type__c, c.ALTF__Short_Description__c), c);
        }

        List<ALTF__Insight_Card__c> fresh = new List<ALTF__Insight_Card__c>();
        List<AAO_Pair__c> freshSource = new List<AAO_Pair__c>();
        Map<Id, ALTF__Insight_Card__c> patchById = new Map<Id, ALTF__Insight_Card__c>();
        Map<String, Integer> seenThisRun = new Map<String, Integer>();

        // THE FACE IS INFERRED, forty-ninth stamp item 3(a). One batched call over the whole
        // harvest, so the model writes the headlines and the writer never puts a raw verbatim on
        // the face again. The words themselves are untouched and go to `Long_Description`.
        Map<String, String> headline = AAO_CardFace.infer(established);

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
            String face = headline.containsKey(a.AAO_Pair_Ref__c)
                ? headline.get(a.AAO_Pair_Ref__c)
                : faceFrom(words);
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
                ALTF__Long_Description__c = words,
                ALTF__Note__c = citation(a) + '.'
            );
            fresh.add(card);
            freshSource.add(a);
            byMeaning.put(key, card);
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
        List<ALTF__Insight_Section__c> found = [
            SELECT Id, ALTF__X_Coordinate__c
            FROM ALTF__Insight_Section__c
            WHERE ALTF__Opportunity__c = :opportunityId
                AND ALTF__Short_Description__c = :title
            LIMIT 1
        ];
        if (!found.isEmpty()) {
            return found[0];
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

    @TestVisible
    private static String sectionTitle(AAO_Source__c src, String callType) {
        Datetime occurred = src == null ? null : src.AAO_Evidence_Occurred__c;
        String d = occurred == null ? 'Undated call' : occurred.format('d MMMM yyyy');
        return String.isBlank(callType) ? d : d + ': ' + callType;
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
