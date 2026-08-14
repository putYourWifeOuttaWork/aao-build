/**
 * THE CREATE LEG. Addendum 19, ruling 3: attempt the ladder, create where allowed, and where
 * neither works make the shadow - with the failure legible either way.
 *
 * **Why it exists at all.** `ALTF__Contact_Map_Details__c.ALTF__Contact__c` is required, so a
 * person the pass identified and the org has no Contact for cannot reach the relationship map
 * however good the evidence about them is. Before this class the writer reported that and
 * stopped, which was honest and was not the ruling. Jefferson Vargas is the first live case:
 * identified on the 17 June fixture, driving the legal, InfoSec and approver story, and by Id
 * he does not exist.
 *
 * **THE LADDER RUNS AGAIN HERE, and that is deliberate rather than duplicated work.** Identity
 * is resolved once at ingest, when participation is written; between then and projection a
 * seller may have created the Contact by hand, and re-running the cheap legs costs two queries
 * and stops us creating a duplicate of a person who now exists. Resolution is not a fact that
 * stays true.
 *
 * **NEVER PICK is the law here as it is at the map row.** A name matching two Contacts on one
 * account resolves to neither: the writer refuses and the person holds at shadow stage, which
 * is a real state rather than a failure. Picking would attach a call's worth of evidence to
 * whichever row sorted first.
 *
 * **MATCH AGGRESSIVELY, CREATE CONSERVATIVELY** (eightieth stamp, and the twenty-first stamp
 * before it in those words). The two halves pull in opposite directions on purpose. Matching
 * costs a query and its failure mode is a held pair; creating costs a permanent row in somebody
 * else's CRM and its failure mode is a duplicate human. So this ladder searches wider than it
 * used to and mints narrower: a single spoken token is searched as a given OR family name
 * across the account and the deal's map rows, and it can LINK but can never CREATE.
 *
 * **THERE ARE TWO LADDERS IN THIS SYSTEM AND ONLY ONE OF THEM CAN CREATE.** This one, and
 * `AAO_ResolveDesignator` at the resolution stage. That is not duplication for its own sake -
 * they answer at different moments with different inputs - but it is a hazard with a measured
 * cost: the given-name rung existed on the resolution ladder and not on this one, so the rung
 * that would have looked did not run on the path that mints. Any rung added to either is
 * considered for both.
 */
public with sharing class AAO_Identity {
    /** resolved | created | shadowed */
    public class Resolution {
        public Id contactId;
        public Id shadowPersonId;
        public String action;
        public String reason;
        /** Which rung of the ladder answered, for the record. */
        public String rung;

        public Boolean reachesTheMap() {
            return contactId != null;
        }

        public override String toString() {
            return action +
                (rung == null ? '' : ' by ' + rung) +
                (reason == null ? '' : ' :: ' + reason);
        }
    }

    /**
     * Resolve one identified person to something the map can hold.
     *
     * @param p         the participant row the pair identified, with its Contact, email,
     *                  roster key and display name selected.
     * @param accountId the deal's account. The grain a shadow person is keyed at, because a
     *                  person is one person across that account's deals.
     */
    public static Resolution resolve(AAO_Participant__c p, Id accountId) {
        return resolve(p, accountId, null);
    }

    /**
     * The deal is passed so the given-name rung can see the deal's own map rows, which is the
     * eightieth stamp's scope in its own words: "matched against given names scoped to the
     * account and the deal's map rows". An overload rather than a changed signature, so every
     * existing caller keeps working and only the projection, which knows the deal, opts in.
     */
    public static Resolution resolve(AAO_Participant__c p, Id accountId, Id opportunityId) {
        Resolution r = new Resolution();

        // RUNG 1. Already linked. Ingest resolved it, or a human did.
        if (p.AAO_Contact__c != null) {
            r.contactId = p.AAO_Contact__c;
            r.action = 'resolved';
            r.rung = 'the participation row';
            return r;
        }

        // RUNG 2. Email, which is the only identifier in a roster that is meant to be unique.
        if (String.isNotBlank(p.AAO_Email__c)) {
            String email = p.AAO_Email__c.toLowerCase();
            List<Contact> byEmail = [
                SELECT Id FROM Contact WHERE Email = :email LIMIT 2
            ];
            if (byEmail.size() == 1) {
                r.contactId = byEmail[0].Id;
                r.action = 'resolved';
                r.rung = 'email';
                linkBack(p, r.contactId);
                return r;
            }
            if (byEmail.size() > 1) {
                r.reason =
                    'two or more Contacts share this email, so the writer refuses to choose ' +
                    'between them.';
            }
        }

        AAO_PersonName.Parsed name = AAO_PersonName.parse(
            String.isBlank(p.AAO_Display_Name__c) ? p.AAO_Roster_Key__c : p.AAO_Display_Name__c
        );

        // A SINGLE SPOKEN TOKEN IS ITS OWN RUNG, and the eightieth stamp is the receipt for it.
        //
        // WHAT HAPPENED: a designator of one word, "Fatima", reached this ladder from the
        // resolution stage. `AAO_PersonName.parse` reads one token as a SURNAME, which is right
        // for the input it was built for - a roster string's bare token is a family name - so
        // rung 3 searched `LastName = 'Fatima'`, found nothing, and rung 4 CREATED a Contact
        // with no first name, no email and no title on a customer-named account. Fatema
        // Choudray, VP Premier Sales Performance, was already sitting on that same account,
        // seeded, and is the same human. Her machine-minted twin then wrote `Signature
        // Approver`, rank 5, onto the relationship map a seller reads.
        //
        // TWO MECHANISMS FAILED. This ladder had no rung that matched a bare given name (the
        // resolution stage's ladder does; two ladders, one of them creation-capable, and the
        // rung was on the other one). And the twenty-fourth stamp's free structural guard did
        // not hold: its reasoning was that a Contact requires a LastName so "CFO" can never
        // create, which is true of titles and NOT true of one spoken first name, because one
        // token parses into LastName and satisfies the schema. The guard was believed to mean
        // only a real full name can create. It never meant that.
        Boolean oneToken = name.ok() && String.isBlank(name.first);
        if (oneToken && accountId != null) {
            // MATCH AGGRESSIVELY. Given OR family name, because a lone spoken token is far more
            // often somebody's first name, scoped to the account and to the deal's map rows,
            // and STILL never picking between two.
            List<Contact> byToken = givenOrFamily(name.last, accountId, opportunityId);
            if (byToken.size() == 1) {
                r.contactId = byToken[0].Id;
                r.action = 'resolved';
                r.rung = 'single token as given or family name, within the account';
                linkBack(p, r.contactId);
                return r;
            }
            if (byToken.size() > 1) {
                return shadow(
                    p, accountId, name, 'Ambiguous',
                    byToken.size() + ' people on this account answer to "' + name.last +
                    '" as a given or family name, and one spoken word cannot separate them. ' +
                    'Held for the Identification flag; a link guessed under ambiguity is ' +
                    'worse than no link at all.',
                    r
                );
            }
        }

        // RUNG 3. Name, and ONLY within the account, and only where it is unambiguous. A name
        // is not an identifier and this rung knows it: the account bound keeps the search off
        // every namesake in the org, and two hits refuse rather than pick.
        if (name.ok() && accountId != null && String.isNotBlank(name.last) && !oneToken) {
            String last = name.last;
            List<Contact> byName = [
                SELECT Id FROM Contact
                WHERE AccountId = :accountId
                    AND LastName = :last
                    AND FirstName = :name.first
                LIMIT 2
            ];
            if (byName.size() == 1) {
                r.contactId = byName[0].Id;
                r.action = 'resolved';
                r.rung = 'name, within the account';
                linkBack(p, r.contactId);
                return r;
            }
            if (byName.size() > 1) {
                r.reason =
                    'two or more Contacts on this account carry this name, so the writer ' +
                    'refuses to choose between them.';
            }
        }

        // RUNG 4. CREATE, where the toggle allows it and a name parses deterministically.
        if (!name.ok()) {
            return shadow(p, accountId, name, 'Unresolvable', name.refusedBecause, r);
        }

        // CREATE CONSERVATIVELY · A SINGLE-TOKEN DESIGNATOR CAN LINK BUT NEVER CREATE.
        //
        // This completes the twenty-fourth stamp's guard by that guard's own logic rather than
        // adding a new rule beside it: the point was always that only a real full name reaches
        // creation, and the LastName requirement was mistaken for a mechanism that guaranteed
        // it. One word is a thing somebody said, not a person's name on a record a seller will
        // read for years, and a wrong spelling of it is permanent in their CRM. So ladder-zero
        // on one token HOLDS with its evidence and its reason.
        if (oneToken) {
            return shadow(
                p, accountId, name, 'Single_Token',
                'All this person has is one spoken word, "' + name.last + '", which matched ' +
                'nobody on the account by given or family name. A single token may LINK and ' +
                'may never CREATE: a transcript spelling minted as a Contact carries the ' +
                'transcriber\'s error into the CRM permanently, and "Fatima" for Fatema ' +
                'Choudray is the measured case. Held with its evidence for the ' +
                'Identification flag.',
                r
            );
        }
        if (!AAO_Settings.mayCreateContacts()) {
            return shadow(
                p, accountId, name, 'Toggle_Off',
                'Contact creation is switched off for this org. This is configuration rather ' +
                'than a failure, and the person persists here permanently.',
                r
            );
        }

        Contact fresh = new Contact(
            AccountId = accountId,
            FirstName = name.first,
            LastName = name.last,
            Email = p.AAO_Email__c
        );
        Database.SaveResult sr = Database.insert(fresh, false);
        if (sr.isSuccess()) {
            r.contactId = sr.getId();
            r.action = 'created';
            r.rung = 'created from the parsed name';
            r.reason =
                'No Contact existed for this person. Created as "' + name.display +
                '" from the source form "' + sourceName(p) + '" (' + name.shape + ').';
            // THE CREATE-LEG RECORD, before anything else touches the new row. This leg
            // created Dan Lewis with nothing systematically recording it; from here every
            // creation is enumerable and therefore disownable. A mention-minted
            // participant (roster key `mention:`) reached here through the resolution
            // stage; a plain roster key is the original leg.
            AAO_CreatedRows.record(
                r.contactId,
                sourceName(p),
                p.AAO_Roster_Key__c != null && p.AAO_Roster_Key__c.startsWith('mention:')
                    ? AAO_CreatedRows.LEG_MENTION
                    : AAO_CreatedRows.LEG_ROSTER,
                r.reason,
                p.AAO_Source__c,
                null
            );
            linkBack(p, r.contactId);
            return r;
        }

        // FAILURE LEGIBLE. The org refused the write, and an admin reading the shadow row
        // should not have to reproduce it to learn why.
        List<String> errs = new List<String>();
        for (Database.Error e : sr.getErrors()) {
            errs.add(e.getStatusCode() + ': ' + e.getMessage());
        }
        return shadow(
            p, accountId, name, 'Create_Failed', String.join(errs, ' | '), r
        );
    }

    /**
     * THE GIVEN-NAME RUNG's search: one token as a given OR family name, scoped to the account
     * and to the deal's own map rows.
     *
     * The map-row leg is Matthew's own sketch from the title rung, applied here for the same
     * reason: somebody already placed on this deal is a candidate even where their Contact
     * hangs off a different account, because being on the map is a stronger statement about
     * relevance than an AccountId is.
     *
     * **EXACT MATCHING, DELIBERATELY, and the limit is stated rather than papered over.** This
     * rung compares strings the way the ladder has always compared them. It therefore does NOT
     * link "Fatima" to "Fatema", which is the very row that occasioned it: the ASR heard one
     * spelling and the CRM carries another, one character apart. Fuzzy matching is not ruled and
     * is not invented here, because a resolver that guesses at near-spellings attaches a call's
     * worth of evidence to whoever sorted closest. What protects that row is the creation bar
     * below, not this rung.
     */
    @TestVisible
    private static List<Contact> givenOrFamily(String token, Id accountId, Id opportunityId) {
        Map<Id, Contact> hits = new Map<Id, Contact>(
            [
                SELECT Id FROM Contact
                WHERE AccountId = :accountId
                    AND (FirstName = :token OR LastName = :token)
                LIMIT 3
            ]
        );

        Set<Id> mapped = new Set<Id>();
        try {
            for (ALTF__Contact_Map_Details__c m : [
                SELECT ALTF__Contact__c FROM ALTF__Contact_Map_Details__c
                WHERE ALTF__Account__c = :accountId OR ALTF__Opportunity__c = :opportunityId
            ]) {
                if (m.ALTF__Contact__c != null && !hits.containsKey(m.ALTF__Contact__c)) {
                    mapped.add(m.ALTF__Contact__c);
                }
            }
        } catch (Exception e) {
            // An unreadable or unlicensed vendor table is absence, never an error. The account
            // leg above still answered.
        }
        if (!mapped.isEmpty()) {
            hits.putAll(
                [
                    SELECT Id FROM Contact
                    WHERE Id IN :mapped AND (FirstName = :token OR LastName = :token)
                    LIMIT 3
                ]
            );
        }
        return hits.values();
    }

    // ------------------------------------------------------------------ the shadow

    /**
     * Make the shadow, or find the one already made. Keyed per account so two runs over the
     * same person produce one row, and never deleted afterwards: the claims written while we
     * only knew this person from a call are keyed against their participation, and the shadow
     * is the record of who they were at that point.
     */
    private static Resolution shadow(
        AAO_Participant__c p,
        Id accountId,
        AAO_PersonName.Parsed name,
        String reasonCode,
        String detail,
        Resolution r
    ) {
        String key = shadowKey(p, accountId);
        AAO_Shadow_Person__c row = new AAO_Shadow_Person__c(
            AAO_Shadow_Key__c = key,
            AAO_Account__c = accountId,
            AAO_Participant__c = p.Id,
            AAO_Display_Name__c = name.ok() ? name.display : null,
            AAO_First_Name__c = name.ok() ? name.first : null,
            AAO_Last_Name__c = name.ok() ? name.last : null,
            AAO_Source_Name__c = sourceName(p),
            AAO_Email__c = p.AAO_Email__c,
            AAO_Reason__c = reasonCode,
            AAO_Reason_Detail__c = detail,
            AAO_Synthetic__c = AAO_Synthetic.MARK
        );
        Database.UpsertResult ur = Database.upsert(
            row, AAO_Shadow_Person__c.AAO_Shadow_Key__c, false
        );
        if (ur.isSuccess()) {
            r.shadowPersonId = ur.getId();
        } else {
            List<String> errs = new List<String>();
            for (Database.Error e : ur.getErrors()) {
                errs.add(e.getMessage());
            }
            detail = detail + ' (and the shadow row could not be written either: ' +
                String.join(errs, '; ') + ')';
        }
        r.action = 'shadowed';
        r.rung = 'shadow, ' + reasonCode;
        r.reason = detail;
        return r;
    }

    /**
     * Email where there is one, roster key where there is not - and the account either way.
     * Not the participant id: that is per SOURCE, so keying on it would make one person a new
     * shadow on every call they attend.
     */
    @TestVisible
    private static String shadowKey(AAO_Participant__c p, Id accountId) {
        String tail = String.isNotBlank(p.AAO_Email__c)
            ? p.AAO_Email__c.toLowerCase()
            : 'roster:' + p.AAO_Roster_Key__c;
        return String.valueOf(accountId) + '|' + tail;
    }

    private static String sourceName(AAO_Participant__c p) {
        return String.isBlank(p.AAO_Display_Name__c)
            ? p.AAO_Roster_Key__c
            : p.AAO_Display_Name__c;
    }

    /**
     * Write the resolution back onto the participation row, so the next pass starts at rung 1
     * and the cheap legs stop being re-run for a person already answered. Derived work, so it
     * fails quietly: losing the shortcut costs a query, and throwing here would cost the
     * projection.
     */
    private static void linkBack(AAO_Participant__c p, Id contactId) {
        try {
            update new AAO_Participant__c(Id = p.Id, AAO_Contact__c = contactId);
        } catch (Exception e) {
            // The safe direction is always to lose the derived thing.
        }
    }
}