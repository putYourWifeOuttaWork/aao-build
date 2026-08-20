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
        if (absent.contains(module)) {
            return false;
        }
        // **GRACEFUL REFUSAL, THE BUILDABLE HALF** (135th, finding one). §P4's law says a
        // read-permission failure on an unlicensed module's tables reads as ABSENCE with a
        // configuration note, and it was written law with no code behind it: zero
        // `isAccessible`, `isQueryable`, `QueryException` or `NoAccessException` anywhere.
        // `AAO_Cards` carried 157 `ALTF__` references and no try-block.
        //
        // This is what bites the FIRST MIXED-LICENSE CUSTOMER - Relationship Map licensed,
        // Insights not - which is a real and common commercial shape and one no state of this
        // sandbox can produce, since it licenses everything.
        //
        // **The describe is asked rather than the query attempted**, deliberately: an
        // `isAccessible` check costs nothing, returns a Boolean, and cannot half-succeed, whereas
        // catching the exception means every caller wraps every read and one that forgets throws
        // anyway. The check is the facade's job; the callers just ask whether the module is there.
        //
        // **What this does NOT reach is rung 0**, and that is not this method's failure. Every
        // class referencing `ALTF__` types statically carries a compile dependency on the package,
        // so an org without it cannot deploy the code at all. That is the packaging decision the
        // 135th put to Matthew with its two options, and no runtime check can answer it.
        return readable(module);
    }

    /**
     * Whether this module's own surface can actually be read by whoever is running.
     *
     * One representative object per module - the one whose absence IS the module's absence: the
     * map rows, the insight cards, the assessment questions, the qualifiers. Checking every object
     * a module owns would be more thorough and less useful, because a module whose primary table
     * is unreadable is unlicensed and the rest follows.
     */
    @TestVisible
    private static Boolean readable(String module) {
        if (module == RELATIONSHIP_MAP) {
            return ALTF__Contact_Map_Details__c.SObjectType.getDescribe().isAccessible();
        }
        if (module == INSIGHT_MAP) {
            return ALTF__Insight_Card__c.SObjectType.getDescribe().isAccessible();
        }
        if (module == ASSESSMENT) {
            return ALTF__Assessment_Question__c.SObjectType.getDescribe().isAccessible();
        }
        if (module == SALES_PROCESS) {
            return ALTF__Sales_Process_Qualifier__c.SObjectType.getDescribe().isAccessible();
        }
        return false;
    }

    /**
     * The configuration note a caller shows where a module is absent. **Absence with a reason,
     * never an empty screen and never a thrown run** - §P4's own wording, and the difference
     * between a customer who understands what they are not licensed for and one who thinks the
     * product is broken.
     */
    public static String absenceNote(String module) {
        return module + ' is not available on this org, so nothing was discovered from it and ' +
            'nothing was projected to it. Everything AAO establishes still lands on our own ' +
            'ledger and every other plane is unaffected. If that is wrong, it is a licence or a ' +
            'permission question rather than a defect.';
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
