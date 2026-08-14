/**
 * AAO_Speaker_Requirement__c evaluated against the speaker of the span carrying the
 * assertion. Not who may appear in the citation set: who must be the source of it.
 *
 * This is the ruling that regraded Gate 1 run two. The same words about budget from the
 * seller are not the customer's decision maker confirming budget, and the system must
 * write UNVERIFIED with receipts rather than TRUE.
 *
 * Buyer and seller are derived by domain split. No platform labels: an internal user
 * account on the customer side, or a seller dialling in from a personal address, are both
 * cases where a platform label would lie and the domain would not.
 *
 * Owed: internalDomains should come from org configuration rather than a caller
 * argument. It is a parameter here because inventing a configuration object mid-build
 * would be improvising rule data. See BUILD_JOURNAL.
 */
public class AAO_SpeakerRule {
    /** Map roles that count as decision maker or influencer. */
    private static final Set<String> DM_OR_INFLUENCER = new Set<String>{
        'decision maker',
        'influencer'
    };

    public class Verdict {
        public Boolean satisfied;
        public String reason;

        public Verdict(Boolean satisfied, String reason) {
            this.satisfied = satisfied;
            this.reason = reason;
        }
    }

    /**
     * The buying role comes from the org's own relationship map where the org has one, and
     * from the artifact's roster only where it does not. Session 18.
     *
     * The roster is what a transcript asserted about who was on a call. The map row is what
     * the customer's own records say about who this person is on this deal. When they
     * disagree the map wins, because the speaker requirement is a question about standing
     * and standing is not something a transcript gets to declare.
     *
     * The reason string records which was used, so a verdict can never be traced back to a
     * source nobody can identify.
     */
    /**
     * Which side of the table. Public so the participant writer records the same answer the
     * gate would give, rather than re-deriving it slightly differently — Coverage's
     * questions all say "you or a team member", so this decides what Coverage counts.
     */
    public static Boolean isInternal(AAO_Model.Speaker sp, Set<String> internalDomains) {
        if (sp == null) {
            return false;
        }
        String domain = sp.domain();
        return domain != null && internalDomains != null && internalDomains.contains(domain);
    }

    public static Verdict evaluate(
        String requirement,
        AAO_Model.Speaker sp,
        Set<String> internalDomains
    ) {
        return evaluate(requirement, sp, internalDomains, null, null);
    }

    public static Verdict evaluate(
        String requirement,
        AAO_Model.Speaker sp,
        Set<String> internalDomains,
        Map<Id, String> roleByContact
    ) {
        return evaluate(requirement, sp, internalDomains, roleByContact, null);
    }

    /**
     * SUBJECT_PERSON, ruled v1.1, and it is a different kind of requirement from the others.
     *
     * Every other value names a CLASS of speaker: the selling side, the buying side, a
     * decision maker. Support Q2 and Q4 say "has this person TOLD YOU", which names a
     * SUBJECT — this finding's own person, and nobody else. Without it those questions would
     * pass on a colleague vouching for someone else's preference, which is precisely what
     * the wizard's wording excludes.
     *
     * It is cheap here and would be expensive anywhere else, because the People handed unit
     * is a person crossed with a dimension, so the gate already knows who the finding is
     * about. Both subject arguments are null on every other charter and the branch never fires.
     *
     * **THE SUBJECT IS TESTED BY ROSTER KEY FIRST, AND THAT IS ADDENDUM 18 REACHING THE GATE.**
     * Comparing the speaker's Contact against the subject's Contact asks whether two
     * RESOLUTION OUTCOMES match, which fails in the one direction that matters: a person with
     * no Contact can speak, can be identified, and could never satisfy a requirement that they
     * said it themselves - they would be silently downgraded to UNVERIFIED forever. The roster
     * key is the identity the artifact itself carries, so it is what the comparison uses; the
     * Contact comparison stays as the fallback for rows keyed before the ruling.
     */
    public static Verdict evaluate(
        String requirement,
        AAO_Model.Speaker sp,
        Set<String> internalDomains,
        Map<Id, String> roleByContact,
        Id subjectContactId
    ) {
        return evaluate(requirement, sp, internalDomains, roleByContact, subjectContactId, null);
    }

    public static Verdict evaluate(
        String requirement,
        AAO_Model.Speaker sp,
        Set<String> internalDomains,
        Map<Id, String> roleByContact,
        Id subjectContactId,
        String subjectRosterKey
    ) {
        if (String.isBlank(requirement)) {
            return new Verdict(false, 'no speaker requirement was supplied');
        }
        if (sp == null) {
            // The unsegmented case lands here for everything except Any_Participant:
            // there is no speaker to test, so the requirement cannot be met.
            return requirement == 'Any_Participant'
                ? new Verdict(true, 'any participant, and the artifact has no speakers')
                : new Verdict(
                      false,
                      'the artifact carries no speaker attribution, so "' +
                      requirement +
                      '" cannot be satisfied by it'
                  );
        }

        String domain = sp.domain();
        Boolean internal = domain != null && internalDomains != null &&
            internalDomains.contains(domain);

        if (requirement == 'Subject_Person') {
            if (subjectContactId == null && String.isBlank(subjectRosterKey)) {
                // Refusing rather than passing. A requirement that the speaker BE the
                // subject cannot be checked without a subject, and a check that cannot run
                // has not been met.
                return new Verdict(
                    false,
                    'this requires the subject of the finding to have said it, and no ' +
                    'subject was supplied to check against'
                );
            }
            if (String.isNotBlank(subjectRosterKey)) {
                return subjectRosterKey == sp.key
                    ? new Verdict(true, sp.display + ' said it themselves')
                    : new Verdict(
                          false,
                          sp.display +
                          ' said it, but this proposition is about someone else and asks ' +
                          'what that person told you. Somebody vouching for a colleague does ' +
                          'not establish it.'
                      );
            }
            Id spoke = String.isBlank(sp.contactId) ? null : (Id) sp.contactId;
            if (spoke == subjectContactId) {
                return new Verdict(true, sp.display + ' said it themselves');
            }
            return new Verdict(
                false,
                sp.display +
                ' said it, but this proposition is about someone else and asks what that ' +
                'person told you. Somebody vouching for a colleague does not establish it.'
            );
        }
        if (requirement == 'Any_Participant') {
            return new Verdict(true, 'any participant');
        }
        if (requirement == 'Seller') {
            return internal
                ? new Verdict(true, sp.display + ' is on the selling side')
                : new Verdict(false, sp.display + ' is not on the selling side');
        }
        if (requirement == 'Buyer_Side') {
            return internal
                ? new Verdict(
                      false,
                      sp.display + ' is on the selling side, and this requires the buyer side'
                  )
                : new Verdict(true, sp.display + ' is on the buying side');
        }
        if (requirement == 'Decision_Maker_Or_Influencer') {
            if (internal) {
                return new Verdict(
                    false,
                    sp.display +
                    ' is on the selling side, and this requires a buyer-side decision ' +
                    'maker or influencer'
                );
            }
            // Prefer the map. Fall back to the roster, and say which.
            String role = sp.mapRole;
            String roleSource = 'the artifact roster';
            if (roleByContact != null && String.isNotBlank(sp.contactId)) {
                String fromMap = roleByContact.get((Id) sp.contactId);
                if (String.isNotBlank(fromMap)) {
                    role = fromMap;
                    roleSource = 'the relationship map';
                }
            }
            if (String.isBlank(role)) {
                return new Verdict(
                    false,
                    sp.display +
                    ' carries no buying role, on the relationship map or the roster'
                );
            }
            return DM_OR_INFLUENCER.contains(role.toLowerCase())
                ? new Verdict(
                      true,
                      sp.display + ' is ' + role + ', per ' + roleSource
                  )
                : new Verdict(
                      false,
                      sp.display +
                      ' is ' +
                      role +
                      ' per ' +
                      roleSource +
                      ', which is neither decision maker nor influencer'
                  );
        }
        return new Verdict(
            false,
            'unrecognised speaker requirement "' + requirement + '"'
        );
    }
}