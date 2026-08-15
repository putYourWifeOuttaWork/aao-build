/**
 * PROMOTION · the shadow becomes the person, and the flag it raised can finally clear.
 *
 * THE FAILURE THIS EXISTS TO FIX, measured on the Wells Fargo stack and graded by design at the
 * ninety-eighth stamp: the system created Priya Natarajan's Contact, put her on the map as
 * Approver, and left two Identification flags standing that said it could not identify her. **A
 * flag that cannot clear when the work IS done is the one failure this product cannot ship**, and
 * it had two causes, both closed here.
 *
 * **CAUSE ONE, SEQUENCING.** `AAO_Identification.reconcile` clears a flag only on a Contact
 * binding, and it ran at call 2a. The Contact is created by the create leg at PROJECTION, six
 * stages later. It asked the question while the answer was still no, and the answer arrived in
 * the same run minutes afterwards. `runAfterProjection` is that second ask, at the point where
 * the answer can be yes.
 *
 * **CAUSE TWO, AND ORDERING ALONE WOULD NOT HAVE FIXED IT.** She has TWO shadows, because s3 said
 * "Priya Natarajan" and s4 said "Priya", and the eighty-seventh stamp's key-collapse ruling
 * forbids collapsing forms at the key. That ruling does not move and is not weakened here. The
 * bound keys are `…|priya natarajan` and `…|priya`, so a clear that matched on the KEY could only
 * ever reach one of them and the other would stand open forever.
 *
 * **SO THE CLEAR IS BY PERSON, NEVER BY KEY**, which is Matthew's own wording at the ninety-ninth.
 * N forms, N shadows, ONE Contact, N flags cleared, and the keys stay uncollapsed. The forms are
 * allowed to differ; what they resolve to is what closes the work.
 *
 * WHAT PROMOTION IS NOT. It never creates a Contact, never edits one, never merges two, and never
 * guesses. It matches a designator this deal already held against a Contact this deal already
 * bound, and where more than one Contact answers to a designator it promotes NOTHING and leaves
 * the flag standing — the ladder's AMBIGUOUS terminal, in a second place, for the same reason.
 *
 * AND IT GIVES `AAO_Promoted_Contact__c` ITS FIRST WRITER. The field has been a plan since the
 * eighty-eighth stamp named it as debt, read by `AAO_Identification` and written by nothing. The
 * field-with-no-readers law's mirror image closes with this class.
 */
public class AAO_Promotion {
    public class Outcome {
        public Integer shadowsPromoted = 0;
        public Integer flagsCleared = 0;
        public Integer ambiguousHeld = 0;
        public List<String> notes = new List<String>();

        public override String toString() {
            List<String> o = new List<String>{
                'shadows promoted        ' + shadowsPromoted + ' (unit: shadows)',
                'flags cleared by person ' + flagsCleared + ' (unit: flags)',
                'held, ambiguous         ' + ambiguousHeld + ' (unit: designators)'
            };
            for (String n : notes) {
                o.add('  note: ' + n);
            }
            return String.join(o, '\n');
        }
    }

    /**
     * THE PASS, run after projection so the Contacts this run created are visible to it.
     *
     * Deterministic end to end: no model call, no inference, one query set and two writes.
     */
    public static Outcome runAfterProjection(Id opportunityId) {
        Outcome o = new Outcome();
        if (opportunityId == null) {
            return o;
        }

        List<Opportunity> opps = [
            SELECT AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1
        ];
        if (opps.isEmpty() || opps[0].AccountId == null) {
            return o;
        }
        Id accountId = opps[0].AccountId;

        // THE CANDIDATE SET IS THIS DEAL'S OWN BOUND PEOPLE, never the account's whole Contact
        // list. A shadow is promoted because THIS deal resolved that person, not because a
        // Contact somewhere on the account happens to share a name.
        Map<Id, Contact> boundByContact = new Map<Id, Contact>();
        for (AAO_Participant__c p : [
            SELECT AAO_Contact__c, AAO_Contact__r.Name, AAO_Contact__r.FirstName,
                   AAO_Contact__r.LastName
            FROM AAO_Participant__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Contact__c != null
        ]) {
            boundByContact.put(p.AAO_Contact__c, p.AAO_Contact__r);
        }
        if (boundByContact.isEmpty()) {
            return o;
        }

        // Every name form a Contact answers to, normalised. A designator matching ANY of them is
        // that person; a designator matching forms of two different Contacts is ambiguous.
        Map<String, Set<Id>> contactsByForm = new Map<String, Set<Id>>();
        for (Id cid : boundByContact.keySet()) {
            Contact c = boundByContact.get(cid);
            for (String form : formsOf(c)) {
                if (!contactsByForm.containsKey(form)) {
                    contactsByForm.put(form, new Set<Id>());
                }
                contactsByForm.get(form).add(cid);
            }
        }

        List<AAO_Shadow_Person__c> shadows = [
            SELECT Id, AAO_Designator__c, AAO_Promoted_Contact__c
            FROM AAO_Shadow_Person__c
            WHERE AAO_Account__c = :accountId AND AAO_Promoted_Contact__c = null
        ];
        if (shadows.isEmpty()) {
            return o;
        }

        List<AAO_Shadow_Person__c> promote = new List<AAO_Shadow_Person__c>();
        // Every designator that resolved, grouped by the Contact it resolved to. This is the
        // "by person" half: the flags of ALL of a person's forms clear together.
        Map<Id, Set<String>> designatorsByContact = new Map<Id, Set<String>>();

        for (AAO_Shadow_Person__c s : shadows) {
            String d = AAO_Identification.normalise(s.AAO_Designator__c);
            if (String.isBlank(d)) {
                continue;
            }
            Set<Id> matches = contactsByForm.get(d);
            if (matches == null || matches.isEmpty()) {
                continue;
            }
            if (matches.size() > 1) {
                // NOTHING IS PROMOTED AND THE FLAG STAYS STANDING. Two people of this deal answer
                // to this designator, and a guess here would put one person's evidence on the
                // other's record permanently.
                o.ambiguousHeld++;
                o.notes.add(
                    'Held: "' + s.AAO_Designator__c + '" answers to ' + matches.size() +
                    ' bound Contacts on this deal, so nothing is promoted and the flag stands.'
                );
                continue;
            }
            Id cid = new List<Id>(matches)[0];
            promote.add(
                new AAO_Shadow_Person__c(
                    Id = s.Id,
                    AAO_Promoted_Contact__c = cid,
                    AAO_Promoted_At__c = System.now()
                )
            );
            if (!designatorsByContact.containsKey(cid)) {
                designatorsByContact.put(cid, new Set<String>());
            }
            designatorsByContact.get(cid).add(d);
        }

        if (!promote.isEmpty()) {
            update promote;
            o.shadowsPromoted = promote.size();
        }

        // CLEAR BY PERSON. Every flag whose designator resolves to this Contact clears, whatever
        // form it was raised under, and each carries the Contact as its receipt.
        for (Id cid : designatorsByContact.keySet()) {
            o.flagsCleared += AAO_Identification.clearForPerson(
                opportunityId,
                designatorsByContact.get(cid),
                cid
            );
        }

        // AND THE SEQUENCING HALF. The ordinary path - a mention whose person the ladder bound
        // to a Contact this run - is `reconcile`'s own job, and this is the point in the pass
        // where it can answer yes. Called after promotion so a promoted shadow's flag is already
        // closed and is not asked about twice.
        o.flagsCleared += AAO_Identification.reconcile(opportunityId);
        return o;
    }

    /**
     * The name forms a Contact answers to, normalised. Deliberately narrow: full name, and each
     * of first and last ALONE. No initials, no nicknames, no fuzzy distance - the eightieth
     * stamp's ASR-name hazard says a misheard name is not an invented quote and the byte check
     * cannot catch it, so this matches exactly or not at all.
     */
    @TestVisible
    private static Set<String> formsOf(Contact c) {
        Set<String> out = new Set<String>();
        if (c == null) {
            return out;
        }
        for (String s : new List<String>{ c.Name, c.FirstName, c.LastName }) {
            String n = AAO_Identification.normalise(s);
            if (String.isNotBlank(n)) {
                out.add(n);
            }
        }
        if (String.isNotBlank(c.FirstName) && String.isNotBlank(c.LastName)) {
            out.add(AAO_Identification.normalise(c.FirstName + ' ' + c.LastName));
            out.add(AAO_Identification.normalise(c.LastName + ', ' + c.FirstName));
        }
        return out;
    }
}
