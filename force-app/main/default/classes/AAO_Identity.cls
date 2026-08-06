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

        // RUNG 3. Name, and ONLY within the account, and only where it is unambiguous. A name
        // is not an identifier and this rung knows it: the account bound keeps the search off
        // every namesake in the org, and two hits refuse rather than pick.
        if (name.ok() && accountId != null && String.isNotBlank(name.last)) {
            String last = name.last;
            List<Contact> byName = String.isBlank(name.first)
                ? [
                      SELECT Id FROM Contact
                      WHERE AccountId = :accountId AND LastName = :last
                      LIMIT 2
                  ]
                : [
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
