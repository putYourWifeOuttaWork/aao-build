/**
 * WHAT "LIVE" MEANS FOR AN EVIDENCE CONTRACT, in one place.
 *
 * Nine readers across the source each spelled it `AAO_Contract_State__c != 'Superseded'`,
 * independently, and that was correct for exactly as long as Superseded was the only way a
 * contract could stop being live. **The hundred-twenty-ninth's item 6 ends that**: the twelve
 * discovered contracts retire WITHOUT a successor, and *"never as 'superseded,' which would
 * claim a succession that never happened."*
 *
 * So a second dead state exists, and nine places would each have had to learn about it. That is
 * the shape the failed-twice law is about - a rule spread across nine sites is a rule that will
 * be missed at the tenth, and a missed one reads a retired contract as live, which is precisely
 * the silent-drop-at-the-generation-layer defect this retirement exists to end. One place
 * decides; every reader asks it.
 */
public class AAO_ContractState {
    public static final String DERIVED = 'Derived';
    public static final String AWAITING = 'Awaiting_Ratification';
    public static final String RATIFIED = 'Ratified';
    /** A newer generation took over, and `AAO_Superseded_By__c` points at it. */
    public static final String SUPERSEDED = 'Superseded';
    /** This one stops, and no successor exists. `AAO_Retired_Because__c` says why. */
    public static final String RETIRED = 'Retired';

    /**
     * The states that mean this contract can no longer be read by a pass. Bind it into SOQL as
     * `AAO_Contract_State__c NOT IN :AAO_ContractState.DEAD` so a new dead state reaches every
     * reader by being added here and nowhere else.
     */
    public static final Set<String> DEAD = new Set<String>{ SUPERSEDED, RETIRED };

    public static Boolean isLive(String state) {
        return !DEAD.contains(state);
    }
}
