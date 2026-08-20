/**
 * PERSONA GHOSTS. Process step (d), the hundred-twenty-sixth's item 3(d) and the
 * hundred-thirtieth's item 8.
 *
 * > *"The expectation mapping ships as our seed metadata keyed to stored values; ghosts injected
 * > where the stage expects an unmatched persona, eliminated on match at the join, enumerable and
 * > purgeable by construction."*
 *
 * ===== A GHOST IS COMPUTED, AND THAT IS WHY IT IS ENUMERABLE AND PURGEABLE BY CONSTRUCTION.
 *
 * A ghost is `expected at this stage` minus `matched by somebody on this deal`. Both sides are
 * ledger facts, so the whole thing is arithmetic over rows we already hold - and the
 * hundred-twenty-ninth ruled that shape for the counts in words that apply here unchanged:
 * *"storing them stores a cache of arithmetic and invites it to go stale."*
 *
 * The stamp's own acceptance conditions fall out rather than being built:
 *
 *   INJECTED    the stage moves, the expected set widens, and the ghost is simply there on the
 *               next read. Nothing writes it.
 *   ELIMINATED  a person is identified who matches the persona, and the ghost is gone on the next
 *               read. No row to retire, no row to delete, and no argument with the never-delete
 *               law about what eliminating one means.
 *   PURGEABLE   there is nothing to purge. **The strongest form of purgeable is nothing to purge.**
 *   ENUMERABLE  `ghostsOn` is the enumeration.
 *
 * The cost, carried rather than hidden: NO HISTORY. Nobody can ask when a ghost first appeared or
 * how long it stood. That question belongs to the D360 plane when it stands up, which is exactly
 * where the 129th put the same question for the counts.
 *
 * ===== NEVER A VENDOR ROW, AND THE MAP WRITER NEEDS NO CHANGE.
 *
 * `ALTF__Contact_Map_Details__c.ALTF__Contact__c` is `nillable = false`, measured three times
 * now, so an expected-but-unidentified persona can never stand on the relationship map. The
 * hundred-nineteenth asked for *"the map writer reads PROCESS state before writing people"* so
 * that it could INJECT ghosts as it wrote. **With ghosts computed and off-map there is nothing to
 * inject, so the map writer is untouched** - and that is the measured constraint simplifying the
 * design rather than a phrase left unhonoured. We also write nothing to
 * `ALTF__Relationship_Map_Persona__c`: manufacturing vendor rows is refused as default (122nd),
 * and a row on their object would carry their automation and our meaning at once.
 *
 * ===== THE MATCH IS BY TITLE, AND THE PROPOSAL'S RULE IS WRONG FOR THIS VOCABULARY.
 *
 * Proposal §3 proposes *"role establishment first, never title alone - titles resolve identity,
 * never establish roles, standing law."* That rule is right, and it is right about a different
 * axis. **Measured, the vendor's twelve persona values are JOB-SHAPED**: CEO, CRO, Executive
 * Sponsor, Sales Leader, RevOps Leader, Enablement Leader, IT Leader, Procurement Lead, Altify
 * Program Owner, Consultant, Legal, Partner. Not one of them is a methodology role, and the
 * proposal's own worked example ("your stage expects an Economic Buyer") names a value that is
 * not in this vocabulary and would not be in a customer's unless they configured it.
 *
 * So *"is this person the RevOps Leader"* is a question about WHO THEY ARE, not about what
 * authority they hold - and a title resolving identity is the standing law's own permitted use of
 * a title rather than a breach of it. **Establishing a buyer role from a title stays forbidden;
 * nothing here does that, and a persona match writes no role and moves no answer.**
 *
 * Deterministic, never a model, per the twenty-fourth stamp's ruling on title normalisation. And
 * the ladder's discipline holds on ambiguity: exactly one persona matches, more than one is
 * AMBIGUOUS and matches NOTHING, reported rather than picked.
 */
public class AAO_Personas {
    /** One persona this org configured, with our grammar over the vendor's vocabulary. */
    public class Expectation {
        public String persona;
        public Decimal expectedFromStage;
        public List<String> patterns = new List<String>();
        public String note;
    }

    /** A person on the deal, and the persona their title resolves to. */
    public class Match {
        public Id contactId;
        public String personName;
        public String title;
        /** Null where the title resolves to no persona, or to more than one. */
        public String persona;
        public Boolean ambiguous = false;
        public List<String> candidates = new List<String>();
    }

    /** An expected persona that nobody on this deal fills. */
    public class Ghost {
        public String persona;
        public Decimal expectedFromStage;
        public Integer stageOrdinal;
        public String because;
    }

    public class Reading {
        public Integer stageOrdinal;
        public List<Ghost> ghosts = new List<Ghost>();
        public List<Match> matched = new List<Match>();
        public List<Match> unmatched = new List<Match>();
        public List<String> notes = new List<String>();
    }

    // ================================================================== configuration

    /**
     * Custom metadata cannot be inserted in a test, and the seed deliberately ships every
     * expectation BLANK, so the ghost path would be untestable without this. Same hook
     * `AAO_MapValues` carries for the buyer-role ranks, and for the same reason.
     */
    @TestVisible
    private static List<AAO_Persona_Expectation__mdt> stubbed;

    public static Map<String, Expectation> expectations() {
        Map<String, Expectation> out = new Map<String, Expectation>();
        List<AAO_Persona_Expectation__mdt> rows = stubbed != null
            ? stubbed
            : [
                SELECT AAO_Persona__c, AAO_Expected_From_Stage__c, AAO_Title_Patterns__c,
                       AAO_Note__c
                FROM AAO_Persona_Expectation__mdt
                WHERE AAO_Persona__c != null
            ];
        for (AAO_Persona_Expectation__mdt m : rows) {
            Expectation e = new Expectation();
            e.persona = m.AAO_Persona__c;
            e.expectedFromStage = m.AAO_Expected_From_Stage__c;
            e.note = m.AAO_Note__c;
            if (String.isNotBlank(m.AAO_Title_Patterns__c)) {
                for (String p : m.AAO_Title_Patterns__c.split(',')) {
                    if (String.isNotBlank(p)) {
                        e.patterns.add(p.trim().toLowerCase());
                    }
                }
            }
            out.put(e.persona, e);
        }
        return out;
    }

    // ======================================================================= the match

    /**
     * The persona a title resolves to, or null. **Exactly one match links; more than one is
     * ambiguous and links nothing**, which is the identity ladder's own three outcomes minus the
     * one that does not apply here, since a persona is never created.
     */
    public static Match matchTitle(String title, Map<String, Expectation> byPersona) {
        Match m = new Match();
        m.title = title;
        if (String.isBlank(title)) {
            return m;
        }
        String t = normalise(title);
        for (Expectation e : byPersona.values()) {
            for (String p : e.patterns) {
                if (t.contains(' ' + p + ' ')) {
                    m.candidates.add(e.persona);
                    break;
                }
            }
        }
        if (m.candidates.size() == 1) {
            m.persona = m.candidates[0];
        } else if (m.candidates.size() > 1) {
            m.candidates.sort();
            m.ambiguous = true;
        }
        return m;
    }

    /**
     * ===== WORD BOUNDARIES, NOT RAW SUBSTRINGS, and the first real title is why.
     *
     * The first draft asked `title.contains(pattern)` and *"Director, Revenue Operations"* - a
     * real title off a real deal - came back AMBIGUOUS between RevOps Leader and IT Leader.
     * **`cto` is a substring of `dire`cto`r`.** Every short abbreviation in this vocabulary has
     * the same problem: `ceo`, `cio`, `cro`, `it` will each turn up inside ordinary English words
     * for the rest of time, and each one silently makes a real match ambiguous, which under the
     * ladder's discipline means it matches NOTHING. A persona nobody can ever fill casts a ghost
     * that can never be eliminated.
     *
     * Found by running it against a title the org actually holds rather than one I made up.
     *
     * So the title is punctuation-stripped to single-spaced words and padded, and a pattern must
     * match on both edges. Still deterministic and still no model, per the twenty-fourth stamp.
     */
    @TestVisible
    private static String normalise(String title) {
        String t = title.toLowerCase().replaceAll('[^a-z0-9]+', ' ').trim();
        return ' ' + t + ' ';
    }

    // ====================================================================== the reading

    /**
     * Ghosts on a deal. Pure: no DML, no callout, nothing written anywhere.
     *
     * **Buyer side only.** A seller is not a member of the buying committee, so a seller filling
     * a persona fills nothing - the same law the internal-subject gate carries, applied where it
     * would otherwise let our own account executive stand in for the customer's Sales Leader.
     */
    public static Reading ghostsOn(Id opportunityId) {
        Reading r = new Reading();
        if (opportunityId == null) {
            r.notes.add('No opportunity; nothing to compute.');
            return r;
        }
        Map<String, Expectation> byPersona = expectations();
        if (byPersona.isEmpty()) {
            r.notes.add(
                'This org states no persona expectations at all, so no stage expects anybody ' +
                'and no ghost can stand. Graceful absence rather than a defect.'
            );
            return r;
        }
        r.stageOrdinal = AAO_Flags.stageOrdinalOf(opportunityId);

        // One human, many participant rows. Fold on the Contact, because a title is a Contact's.
        Map<Id, AAO_Participant__c> byContact = new Map<Id, AAO_Participant__c>();
        for (AAO_Participant__c p : [
            SELECT Id, AAO_Display_Name__c, AAO_Contact__c, AAO_Contact__r.Title,
                   AAO_Internal__c
            FROM AAO_Participant__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Contact__c != null
        ]) {
            if (p.AAO_Internal__c == true) {
                continue;
            }
            byContact.put(p.AAO_Contact__c, p);
        }

        Set<String> filled = new Set<String>();
        for (AAO_Participant__c p : byContact.values()) {
            Match m = matchTitle(p.AAO_Contact__r.Title, byPersona);
            m.contactId = p.AAO_Contact__c;
            m.personName = p.AAO_Display_Name__c;
            if (m.persona != null) {
                filled.add(m.persona);
                r.matched.add(m);
            } else {
                r.unmatched.add(m);
                if (m.ambiguous) {
                    r.notes.add(
                        m.personName + ' matches more than one persona (' +
                        String.join(m.candidates, ', ') + ') on the title "' + m.title +
                        '", so it matches none. Exactly one links; more than one holds.'
                    );
                }
            }
        }

        for (Expectation e : byPersona.values()) {
            if (e.expectedFromStage == null) {
                // NEVER EXPECTED. Blank is never read as stage zero, the same null semantics the
                // by-stage marker carries, and it is the honest default while nothing states
                // which personas a stage wants.
                continue;
            }
            if (filled.contains(e.persona)) {
                continue;
            }
            if (r.stageOrdinal == null) {
                r.notes.add(
                    'Persona ' + e.persona + ' is expected from stage ' +
                    e.expectedFromStage.setScale(0) + ', and this deal\'s stage could not be ' +
                    'ordered against the org\'s open stages, so nothing can be compared. No ghost.'
                );
                continue;
            }
            if (r.stageOrdinal < e.expectedFromStage) {
                continue;
            }
            Ghost g = new Ghost();
            g.persona = e.persona;
            g.expectedFromStage = e.expectedFromStage;
            g.stageOrdinal = r.stageOrdinal;
            g.because =
                'This deal is at stage ' + r.stageOrdinal + ' and the persona ' + e.persona +
                ' is expected from stage ' + e.expectedFromStage.setScale(0) +
                '. Nobody identified on this deal fills it.';
            r.ghosts.add(g);
        }
        return r;
    }
}
