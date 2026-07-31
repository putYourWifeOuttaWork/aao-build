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

    public static Verdict evaluate(
        String requirement,
        AAO_Model.Speaker sp,
        Set<String> internalDomains
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
            if (String.isBlank(sp.mapRole)) {
                return new Verdict(
                    false,
                    sp.display + ' carries no buying role on the relationship map'
                );
            }
            return DM_OR_INFLUENCER.contains(sp.mapRole.toLowerCase())
                ? new Verdict(true, sp.display + ' is mapped as ' + sp.mapRole)
                : new Verdict(
                      false,
                      sp.display +
                      ' is mapped as ' +
                      sp.mapRole +
                      ', which is neither decision maker nor influencer'
                  );
        }
        return new Verdict(
            false,
            'unrecognised speaker requirement "' + requirement + '"'
        );
    }
}
