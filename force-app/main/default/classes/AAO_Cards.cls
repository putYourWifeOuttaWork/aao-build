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
        public List<String> notes = new List<String>();

        public override String toString() {
            return 'cards: ' + created + ' created, ' + reinforced + ' reinforced, ' +
                unchanged + ' unchanged, ' + contradictionsFlagged + ' contradictions flagged; ' +
                'links: ' + linksWritten + ' written, ' + linksHeld + ' held' +
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

        List<AAO_Answer__c> answers = [
            SELECT Id, AAO_Verdict__c, AAO_Spans__c, AAO_Evidence_Occurred__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Participant__c, AAO_Participant__r.AAO_Display_Name__c,
                AAO_Participant__r.AAO_Internal__c, AAO_Participant__r.AAO_Contact__c,
                AAO_Subject_Contact__c
            FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :opportunityId
                AND AAO_Publication_State__c = 'Live'
                AND AAO_Verdict__c = 'TRUE'
                AND AAO_Evidence_Contract__r.AAO_Family__c = 'Problems'
            ORDER BY AAO_Evidence_Occurred__c ASC, Id ASC
        ];
        o.answersRead = answers.size();
        if (answers.isEmpty()) {
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
        List<AAO_Answer__c> freshSource = new List<AAO_Answer__c>();
        List<ALTF__Insight_Card__c> patches = new List<ALTF__Insight_Card__c>();
        Map<String, Integer> seenThisRun = new Map<String, Integer>();

        for (AAO_Answer__c a : answers) {
            String code = a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
            String type = AAO_P8Codes.problemType(code);
            if (type == null) {
                o.notes.add('No card type for ' + code + '; skipped rather than guessed.');
                continue;
            }
            // OUR OWN SIDE NEVER BECOMES A CARD. Seller words never establish a buyer's problem,
            // which the contracts say and the join's internal-subject gate already enforces;
            // this is the belt beside that brace, because a card is customer-visible.
            if (a.AAO_Participant__r != null && a.AAO_Participant__r.AAO_Internal__c == true) {
                o.notes.add('Internal speaker establishment skipped: no card for our own side.');
                continue;
            }
            String words = firstSpanText(a.AAO_Spans__c);
            if (String.isBlank(words)) {
                o.notes.add('Answer ' + a.Id + ' carries no span text; no card written.');
                continue;
            }
            String face = faceFrom(words);
            String key = meaningKey(type, face);

            if (byMeaning.containsKey(key)) {
                // SAME TYPE, SAME MEANING IS REINFORCEMENT. The parent card is kept and its
                // text is never rewritten; the count rides the note, which is the only field
                // the reinforcement mechanics may touch.
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
                patches.add(new ALTF__Insight_Card__c(
                    Id = parent.Id,
                    ALTF__Note__c = ('Said ' + n + ' times. ' + note + ' ' + reiteration).trim()
                        .abbreviate(255)
                ));
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
        }
        if (!patches.isEmpty()) {
            update patches;
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
        List<AAO_Answer__c> sources,
        Outcome o
    ) {
        List<ALTF__Insight_Card_Contact__c> links = new List<ALTF__Insight_Card_Contact__c>();
        for (Integer i = 0; i < cards.size(); i++) {
            AAO_Answer__c a = sources[i];
            Id contactId = a.AAO_Subject_Contact__c != null
                ? a.AAO_Subject_Contact__c
                : (a.AAO_Participant__r == null ? null : a.AAO_Participant__r.AAO_Contact__c);
            if (contactId == null || cards[i].Id == null) {
                o.linksHeld++;
                o.notes.add(
                    'Link held: ' +
                    (a.AAO_Participant__r == null ? 'a speaker' : a.AAO_Participant__r.AAO_Display_Name__c) +
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
    private static String citation(AAO_Answer__c a) {
        String who = a.AAO_Participant__r == null ||
            String.isBlank(a.AAO_Participant__r.AAO_Display_Name__c)
            ? 'a participant'
            : a.AAO_Participant__r.AAO_Display_Name__c;
        String occurredOn = a.AAO_Evidence_Occurred__c == null
            ? 'a call'
            : a.AAO_Evidence_Occurred__c.format('d MMMM yyyy');
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
