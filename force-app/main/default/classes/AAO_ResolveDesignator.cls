/**
 * THE RESOLUTION HALF OF CALL 0, MADE CALLABLE. Ruled 8 August, twenty-second stamp item 5,
 * and extended by the twenty-fourth to accept a title as well as a name.
 *
 * **What it is for.** a23 dropped 7 of 35 located pairs, all graded TRUE, because call 2's
 * closed candidate list is built from the roster and the person was mentioned rather than
 * present. Charters §P8.1 already required the candidate set to carry every load-bearing
 * mentioned person, so the drop was the implementation diverging from written law. A charter
 * that meets a person it cannot resolve calls this instead of dropping the pair.
 *
 * **WHY A SERVICE AND NOT A RE-ENTRANT CALL 0, which is the binding half of the ruling.** Call
 * 0 has two halves and only one of them is safe to re-enter. The SCOPE half is the routing
 * decision, and a family read that could re-open it could flip the pass's grain from inside,
 * which would break "call 0 routes and resolves and never establishes" and take the one-way
 * scope law with it. The RESOLUTION half has no such constraint: same deterministic ladder,
 * same NONE and AMBIGUOUS honesty, invoked on demand with a designator instead of once up
 * front.
 *
 * **THIS CLASS NEVER CREATES AND NEVER PICKS.** Creation is reachable only on ladder-zero and
 * sits behind the create-leg record, which ships first; AMBIGUOUS routes to the Identification
 * flag with the pair held. Both are somebody else's code on purpose: a resolver that could
 * create is a resolver whose failure mode is a row in the customer's CRM.
 *
 * **NOT WIRED INTO THE PASS YET, and that is deliberate.** The twenty-first stamp made a
 * name-based internal check a precondition of the mentioned-person path, and it is not built.
 * Until it is, nothing calls this from a live run: it is exercised by tests and by the
 * designator report. Building the deterministic half early costs nothing and lets the
 * zero-creation number be produced by real code rather than by reading rows.
 */
public with sharing class AAO_ResolveDesignator {
    /** A name, or a title, or a pronoun's resolved antecedent carrying whichever it turned out to be. */
    public enum Kind {
        NAME,
        TITLE
    }

    /** LINKED | AMBIGUOUS | ZERO. The ladder's three standard outcomes and no fourth. */
    public class Outcome {
        public String designator;
        public Kind kind;
        public String verdict;
        public Id contactId;
        /** Which rung answered, or the last rung tried. For the record, always. */
        public String rung;
        public String because;
        /** Every rung tried, in order, whether it answered or not. */
        public List<String> rungsTried = new List<String>();
        /** The candidates an AMBIGUOUS verdict refused to choose between. */
        public List<Id> candidates = new List<Id>();

        public Boolean linked() {
            return verdict == 'LINKED';
        }

        public override String toString() {
            return designator + ' [' + kind + '] -> ' + verdict +
                (contactId == null ? '' : ' ' + contactId) +
                ' via ' + rung + (String.isBlank(because) ? '' : ' :: ' + because);
        }
    }

    /**
     * TITLE SYNONYMS, DETERMINISTIC, NEVER A MODEL. Ruled: "CFO" and "Chief Financial Officer"
     * are one title, and the mapping is a list rather than a judgment.
     *
     * **Its seed-metadata home is owed at packaging** and is named here rather than assumed,
     * exactly as the internal-domain list's home is already a standing debt. An Apex constant
     * is the wrong long-term place for anything an org must override; it is the right place
     * for something that must be deterministic today and has no override surface yet.
     */
    private static final Map<String, String> TITLE_CANON = new Map<String, String>{
        'cfo' => 'chief financial officer',
        'chief financial officer' => 'chief financial officer',
        'ceo' => 'chief executive officer',
        'chief executive officer' => 'chief executive officer',
        'cio' => 'chief information officer',
        'chief information officer' => 'chief information officer',
        'cto' => 'chief technology officer',
        'chief technology officer' => 'chief technology officer',
        'coo' => 'chief operating officer',
        'chief operating officer' => 'chief operating officer',
        'ciso' => 'chief information security officer',
        'chief information security officer' => 'chief information security officer',
        'vp' => 'vice president',
        'vice president' => 'vice president',
        'svp' => 'senior vice president',
        'senior vice president' => 'senior vice president',
        'gc' => 'general counsel',
        'general counsel' => 'general counsel'
    };

    public static String canonicalTitle(String raw) {
        if (String.isBlank(raw)) {
            return null;
        }
        String key = raw.trim().toLowerCase().replaceAll('[.]', '');
        return TITLE_CANON.containsKey(key) ? TITLE_CANON.get(key) : key;
    }

    /**
     * Resolve one designator against one account's world.
     *
     * The rungs run ONCE, in order, and each is journalled whether it answered or not. **This
     * is a ladder and not a loop:** "a few reasonable tries" means these tries, not a model
     * retrying until something matches, which is how a resolver becomes a name generator.
     */
    public static Outcome resolve(
        String designator, Kind designatorKind, Id accountId, Id opportunityId
    ) {
        Outcome o = new Outcome();
        o.designator = designator;
        o.kind = designatorKind;

        if (String.isBlank(designator)) {
            o.verdict = 'ZERO';
            o.rung = 'none';
            o.because = 'No designator was supplied, so there is nothing to resolve. A pair ' +
                'reaching here without one is a call 1 defect rather than a resolution result.';
            return o;
        }
        if (accountId == null) {
            o.verdict = 'ZERO';
            o.rung = 'none';
            o.because = 'No account scope. Every rung below is account-bound on purpose, ' +
                'because a name is not an identifier and an unscoped search finds namesakes.';
            return o;
        }

        return designatorKind == Kind.TITLE
            ? byTitle(designator, accountId, opportunityId, o)
            : byName(designator, accountId, o);
    }

    // ------------------------------------------------------------------ the name rungs

    private static Outcome byName(String designator, Id accountId, Outcome o) {
        // A SINGLE SPOKEN TOKEN IS CHECKED BEFORE THE PARSER, and finding out why cost a red
        // test worth keeping in the record.
        //
        // `AAO_PersonName.parse` reads one token as a SURNAME, which is right for the input it
        // was built for: a roster string like "Vargas, Jefferson [EMR/CSS/AT/MEDI]" is some
        // system's record of a human and its bare token is a family name. A MENTIONED name is
        // the opposite - a23's span says "Fatima", and in speech a lone first name is the
        // common case. Same parser, different class of input, and the reading inverts.
        //
        // That is the tuned-behaviour law in miniature: the parser is not wrong, it was
        // verified only against the input it was written for. So a single token is searched
        // as EITHER given or family name, account-bound, and never picked between.
        if (!designator.trim().contains(' ')) {
            return bySingleToken(designator.trim(), accountId, o);
        }

        AAO_PersonName.Parsed name = AAO_PersonName.parse(designator);
        o.rungsTried.add('name parse');
        if (!name.ok()) {
            o.verdict = 'ZERO';
            o.rung = 'name parse';
            o.because = 'The designator did not parse to a name deterministically: ' +
                name.refusedBecause + ' Refused rather than guessed.';
            return o;
        }

        // RUNG 2 · full name within the account.
        o.rungsTried.add('name within the account');
        List<Contact> hits = String.isBlank(name.first)
            ? [
                  SELECT Id FROM Contact
                  WHERE AccountId = :accountId AND LastName = :name.last
                  LIMIT 3
              ]
            : [
                  SELECT Id FROM Contact
                  WHERE AccountId = :accountId
                      AND LastName = :name.last
                      AND FirstName = :name.first
                  LIMIT 3
              ];
        return settle(hits, 'name within the account', o);
    }

    /**
     * One token, no surname. Speech is full of these and Fatema is the a23 specimen: the span
     * says "Fatima" and nothing else.
     *
     * Searched as given OR family name because a lone spoken token can be either, scoped to
     * the account, and STILL never picking. Two matches on one account is AMBIGUOUS, which is
     * the honest answer and the one the Identification flag exists for.
     */
    private static Outcome bySingleToken(String token, Id accountId, Outcome o) {
        o.rungsTried.add('single token as given or family name, within the account');
        List<Contact> hits = [
            SELECT Id FROM Contact
            WHERE AccountId = :accountId
                AND (FirstName = :token OR LastName = :token)
            LIMIT 3
        ];
        return settle(hits, 'single token within the account', o);
    }

    // ------------------------------------------------------------------ the title rung

    /**
     * THE TITLE RUNG, ruled 8 August. Matthew's own sketch: Contact where Title matches,
     * scoped to the account, plus the contacts already on map rows for the account or
     * opportunity.
     *
     * **A title can LINK but can never CREATE**, and that is the free structural guard the
     * ruling names: a Contact requires a LastName and "CFO" does not have one. So the two
     * fuzziest designator kinds, titles and pronouns, are structurally incapable of reaching
     * the creation leg. Only a real name gets there, and that path sits behind ladder-zero,
     * the internal check and the create-leg record.
     */
    private static Outcome byTitle(String designator, Id accountId, Id opportunityId, Outcome o) {
        String canon = canonicalTitle(designator);
        o.rungsTried.add('title within the account');

        Map<Id, Contact> hits = new Map<Id, Contact>();
        for (Contact c : [
            SELECT Id, Title FROM Contact
            WHERE AccountId = :accountId AND Title != NULL
        ]) {
            if (canonicalTitle(c.Title) == canon) {
                hits.put(c.Id, c);
            }
        }

        // The map-row leg of Matthew's sketch: people already on this deal's or account's map
        // are candidates even where the Contact hangs off another account.
        o.rungsTried.add('title on the account or opportunity map rows');
        Set<Id> mapped = new Set<Id>();
        try {
            for (ALTF__Contact_Map_Details__c m : [
                SELECT ALTF__Contact__c FROM ALTF__Contact_Map_Details__c
                WHERE ALTF__Account__c = :accountId
                    OR ALTF__Opportunity__c = :opportunityId
            ]) {
                if (m.ALTF__Contact__c != null) {
                    mapped.add(m.ALTF__Contact__c);
                }
            }
        } catch (Exception e) {
            // An unreadable or unlicensed vendor table is absence and a note, never an error.
            o.rungsTried.add('map rows unreadable (' + e.getTypeName() + '), treated as absence');
        }
        if (!mapped.isEmpty()) {
            for (Contact c : [SELECT Id, Title FROM Contact WHERE Id IN :mapped AND Title != NULL]) {
                if (canonicalTitle(c.Title) == canon) {
                    hits.put(c.Id, c);
                }
            }
        }

        return settle(new List<Contact>(hits.values()), 'title within the account', o);
    }

    // ------------------------------------------------------------------ the terminal

    /**
     * The ladder's three outcomes, in one place so no rung can invent a fourth.
     *
     * **ZERO IS "we did our best", Matthew's phrase, and it is a HELD pair rather than a
     * dropped one.** The whole point of the ruling is that the information is never lost: the
     * pair keeps its evidence and its reason and waits, where before it vanished with nothing
     * reporting the drop.
     */
    private static Outcome settle(List<Contact> hits, String rung, Outcome o) {
        o.rung = rung;
        if (hits.size() == 1) {
            o.verdict = 'LINKED';
            o.contactId = hits[0].Id;
            return o;
        }
        if (hits.size() > 1) {
            o.verdict = 'AMBIGUOUS';
            for (Contact c : hits) {
                o.candidates.add(c.Id);
            }
            o.because = hits.size() + ' candidates match this designator and nothing in the ' +
                'words separates them. Never pick: this routes to the Identification flag ' +
                'with the pair held, because a link guessed under ambiguity is worse than no ' +
                'link at all.';
            return o;
        }
        o.verdict = 'ZERO';
        o.because = 'No candidate matched on any rung. The pair is HELD with its evidence ' +
            'and this reason, never dropped and never guessed.';
        return o;
    }
}
