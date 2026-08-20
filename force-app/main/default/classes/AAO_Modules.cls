/**
 * IS THIS ALTIFY MODULE PRESENT FOR THIS DEAL. One place, asked by everything.
 *
 * The hundred-thirty-fourth's item 4, and it is (c)'s own lesson applied BEFORE the failure
 * instead of after it. Nine readers spelling "live" nine ways needed one place deciding; a
 * module check spread across every discovery source and every projection target would need the
 * same, and there the missed tenth reader is not a stale row - it is **a crash in exactly the org
 * the product is sold into**, because the whole claim is that the system runs whole without any
 * of these modules.
 *
 * ===== THE LADDER, ruled by Matthew on 20 August, five rungs each including the ones below.
 *
 *   0  NO ALTIFY AT ALL     our ledger, charters, flags and surfaces, whole. Projection nowhere.
 *                           LAW #1's founding case.
 *   1  RELATIONSHIP MAP     People projects. Problems, Process and the qualifier plane land on
 *                           OUR objects only, graceful absence on every vendor surface.
 *   2  + INSIGHT MAP        cards project.
 *   3  + ASSESSMENT         assessment questions discoverable, assessment answers projectable.
 *   4  + SALES PROCESS      qualifiers discoverable, the vendor's stage-movement gate live.
 *
 * **What a module's absence removes is exactly two things: its DISCOVERY SOURCE and its
 * PROJECTION TARGET. Never a charter, never a read, never our flags.** The charters read the same
 * in every state and the reads cost the same, which is why this facade answers a question about
 * WRITING AND DISCOVERING and is never consulted by a charter.
 *
 * ===== IT ANSWERS TRUE FOR EVERYTHING TODAY, AND THAT IS THE POINT.
 *
 * Per-user module licence is **not readable or verifiable in this sandbox**, where one user owns
 * everything and every module is licensed - the Board has carried that as parked and structurally
 * unanswerable here since the consolidation. So the answer is hardcoded until detection becomes
 * buildable, and the value of the facade is entirely that **the hardcoding is in ONE place.**
 *
 * **AND THE ANSWER IS A PER-RUN FACT, NEVER A CACHED IDENTITY.** A customer who stops paying for
 * Sales Process Manager stops having it overnight, mid-quarter, with runs in flight either side.
 * So nothing here memoises across a transaction boundary and nothing writes the state onto a
 * record as though it were a property of the deal.
 */
public class AAO_Modules {
    public static final String RELATIONSHIP_MAP = 'Relationship Map';
    public static final String INSIGHT_MAP = 'Insight Map';
    public static final String ASSESSMENT = 'Assessment';
    public static final String SALES_PROCESS = 'Sales Process';

    /**
     * **ASSESSMENT AND SALES PROCESS ARE SEPARATELY LICENSED**, which is why they are two
     * constants rather than one "Opportunity Manager". The one-charter-one-corpus ruling has to
     * tolerate the qualifier half of the merged Process corpus vanishing between two runs while
     * the assessment half stands, so nothing may ask about them together.
     */
    private static final Set<String> KNOWN = new Set<String>{
        RELATIONSHIP_MAP, INSIGHT_MAP, ASSESSMENT, SALES_PROCESS
    };

    @TestVisible
    private static Set<String> absent = new Set<String>();

    /**
     * Whether this module is present for this deal, right now.
     *
     * The opportunity is taken even though nothing reads it yet, deliberately: Matthew ruled the
     * reference is **the people on the deal** - the licences of its owner and those associated to
     * it - so detection when it builds is per-deal, and a facade whose signature could not carry
     * that would have to change at every call site on the day it lands.
     */
    public static Boolean present(String module, Id opportunityId) {
        if (!KNOWN.contains(module)) {
            throw new ModuleException(
                'Unknown Altify module "' + module + '". The ladder has four named rungs above ' +
                'the no-Altify state, and a fifth name means either a new module or a typo - ' +
                'neither of which should resolve to a silent true.'
            );
        }
        // Hardcoded present. See the class header: detection is parked as unbuildable in this
        // sandbox, and the rail exists so it lands in one place when it is not.
        return !absent.contains(module);
    }

    /** The rung this deal sits on, 0 through 4, for a receipt or a report to say. */
    public static Integer rung(Id opportunityId) {
        if (!present(RELATIONSHIP_MAP, opportunityId)) {
            return 0;
        }
        if (!present(INSIGHT_MAP, opportunityId)) {
            return 1;
        }
        // Assessment and Sales Process are separately licensed, so the ladder above rung 2 is not
        // strictly ordered: a deal can carry Sales Process without Assessment. The rung is
        // reported as the HIGHEST CONTIGUOUS rung, and `present` stays the honest per-module
        // answer that every caller should actually be asking.
        if (!present(ASSESSMENT, opportunityId)) {
            return 2;
        }
        return present(SALES_PROCESS, opportunityId) ? 4 : 3;
    }

    /** What a run saw, for its receipt. A verdict computed under rung 4 and read under rung 2
     *  needs its provenance to say so. */
    public static String describe(Id opportunityId) {
        List<String> seen = new List<String>();
        for (String m : new List<String>{
            RELATIONSHIP_MAP, INSIGHT_MAP, ASSESSMENT, SALES_PROCESS
        }) {
            seen.add(m + '=' + (present(m, opportunityId) ? 'present' : 'absent'));
        }
        return 'rung ' + rung(opportunityId) + ' (' + String.join(seen, ', ') + ')';
    }

    public class ModuleException extends Exception {
    }
}
