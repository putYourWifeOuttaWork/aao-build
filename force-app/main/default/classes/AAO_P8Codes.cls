/**
 * WHAT EACH OF THE SEVENTEEN PLACES. The derivation half of `people-p8-v1`.
 *
 * `AAO_PassContracts` is what the model is asked; this is what an upheld answer MEANS. They
 * are deliberately two classes over one code set: the first is prompt text and the second is
 * arithmetic, and blending them is how a wording change quietly becomes a placement change.
 *
 * **THIS CLASS EXISTS BECAUSE A LOOKUP WAS DONE BY STRING SURGERY AND WAS WRONG IN SILENCE.**
 * `AAO_PeopleContracts.tokenOf` splits a code on `#`, because the retired person-crossed set
 * put the contact id after one (`S2#003WD...`). **None of the seventeen carries a `#`**, so
 * against this rubric it returned null for every answer, the writer skipped every one of them,
 * and projection reported success over an empty derivation. Architecture v3.9 carries the
 * correction and the law it collected: a capability claim is unverified until tried from the
 * calling runtime, INCLUDING claims about our own code.
 *
 * So the map below is a map. Seventeen literal keys, no parsing, and an unrecognised code is
 * an explicit `null` that the caller must handle rather than a substring that happened to
 * come back empty. `assertCovers` holds it against `AAO_PassContracts.specs()` in the suite,
 * so a contract minted without a placement fails a test instead of vanishing at run time.
 */
public with sharing class AAO_P8Codes {
    public class CodeException extends Exception {
    }

    // ------------------------------------------------------------------ the dimensions

    public static final String DIM_SUPPORT = 'support';
    public static final String DIM_POLITICAL = 'political';
    public static final String DIM_BUYER_ROLE = 'buyer role';
    public static final String DIM_CRITERIA = 'criteria';
    /**
     * COVERAGE IS COMPUTED, NEVER EXTRACTED, so it has a dimension and no contract. Presence
     * establishes it and the participant junction is its evidence; no model call anywhere.
     * It is the one dimension the writer must not count as an answer read.
     */
    public static final String DIM_COVERAGE = 'coverage';
    /**
     * PROBLEMS. Like criteria, this dimension places nobody on the map ROW: its answers become
     * insight CARDS, which are their own records with their own junctions. It is declared here
     * anyway because `assertCovers` is the guard that a minted contract cannot go unplaced, and
     * "this one writes a card rather than a field" is a placement, not an exemption.
     */
    public static final String DIM_PROBLEMS = 'problems';

    /** The dimension order the run report prints in. Support and Political lead (§P8.9). */
    public static List<String> dimensions() {
        return new List<String>{
            DIM_SUPPORT, DIM_POLITICAL, DIM_BUYER_ROLE, DIM_CRITERIA, DIM_COVERAGE,
            DIM_PROBLEMS
        };
    }

    // ------------------------------------------------------------------ the placements

    /**
     * Political Status, by placement rather than by question number.
     *
     * **The ceiling reads TRUE only, and that is the whole point of the one-way split.** The
     * retired shape had two-sided questions, so the weak side had to be read off a FALSE
     * verdict — with the standing guard that a FALSE places somebody only where words
     * affirmatively support the weak side, never as absence of strong-side evidence. Under
     * §P8 the weak sides are their own contracts with their own affirmative words (PS1 and
     * PS2 are the halves the old contracts could not record), so **no verdict on this
     * dimension is ever read for its falseness.** The guard is not relaxed; it is retired,
     * because the thing it guarded against can no longer be expressed.
     */
    private static final Map<String, String> POLITICAL_PLACEMENT = new Map<String, String>{
        'AAO_POL_IC1' => 'Inner Circle',
        'AAO_POL_IC2' => 'Inner Circle',
        'AAO_POL_IC3' => 'Inner Circle',
        'AAO_POL_PS1' => 'Political Structure',
        'AAO_POL_PS2' => 'Political Structure',
        'AAO_POL_PS3' => 'Political Structure',
        'AAO_POL_PS4' => 'Political Structure',
        'AAO_POL_OPS1' => 'Outside Political Structure'
    };

    /**
     * The ceiling order. Highest placement the standing establishments support; one
     * establishment suffices at every level and a lesser property never downgrades.
     */
    private static final List<String> POLITICAL_CEILING = new List<String>{
        'Inner Circle',
        'Political Structure',
        'Outside Political Structure'
    };

    /** Buyer Role. The vendor's picklist values, byte-exact, read from altify--aossb2. */
    private static final Map<String, String> BUYER_ROLE = new Map<String, String>{
        'AAO_BR_APP' => 'Approver',
        'AAO_BR_DM' => 'Decision Maker',
        'AAO_BR_EVAL' => 'Evaluator',
        'AAO_BR_USER' => 'User',
        'AAO_BR_SIG' => 'Signature Approver'
    };

    /**
     * THE BUYER-ROLE LADDER, Matthew's ruling, confirmed 11 August and quoted at the
     * forty-fifth stamp: *"The writer projects the highest-ranked ESTABLISHED role, Decision
     * Maker above Evaluator above User; the unprojected established roles ride the Option C
     * note with their citations; the refusal-note hold is superseded for ladder-resolvable
     * collisions and stays for anything the ladder cannot rank."* His shorter form on the map:
     * if they are Evaluator and User, they are Evaluator.
     *
     * His reasoning, from the grading sheet's row 3 and worth keeping beside the order: an
     * Evaluator outranks a User *"not because it is later, but because almost all evaluators
     * are also users"*. The ladder is about which role SUBSUMES the other, never about which
     * establishment arrived last.
     *
     * **APPROVER AND SIGNATURE APPROVER ARE DELIBERATELY ABSENT.** Only three roles were
     * ranked, and a collision touching an unranked one is exactly what the ruling means by
     * "anything the ladder cannot rank": it keeps the refusal-note hold. Guessing where an
     * Approver sits against a Decision Maker would be this file inventing a ruling.
     */
    /**
     * SUPERSEDED BY CONFIGURATION at the seventy-seventh stamp, and kept only as the fallback
     * for an org whose seed carries no ranks at all. The ranks now live on
     * `AAO_Map_Value__mdt` because they are a methodology statement an org must be able to
     * state, and because a relabelled slot needs somewhere to say what its words mean.
     *
     * Matthew's original ordering is preserved here whole, with his reasoning, because it is
     * what the seed ships: an Evaluator outranks a User *"not because it is later, but because
     * almost all evaluators are also users"*. The ladder is about which role SUBSUMES the
     * other, never about which establishment arrived last.
     */
    private static final List<String> BUYER_ROLE_LADDER = new List<String>{
        'Decision Maker',
        'Evaluator',
        'User'
    };

    /**
     * The Buyer Role to write, given everything established. **NEVER NULL FOR A NON-EMPTY SET.**
     *
     * *(Corrected in place, seventy-seventh stamp. This used to return null on any set touching
     * a role the ladder did not rank, and the caller then held the field and wrote a refusal
     * note instead. That was right while nothing ranked Approver or Signature Approver; it left
     * Adam Pfeiffer's Buyer Role BLANK on a live map with two roles established behind it, and
     * Matthew ruled the blank out: one established value is written, several write the
     * highest-ranked, and an unranked value never causes a blank.)*
     *
     * The procedure itself lives in `AAO_MapValues` so that one place owns every branch of it.
     */
    public static String buyerRoleCeiling(Set<String> roles) {
        return AAO_MapValues.decide(DIM_BUYER_ROLE, roles);
    }

    /**
     * Whether the SEED ranks this role, which is now a question about configuration rather
     * than about a constant. It no longer explains a hold, because there are no holds: an
     * unranked value sorts below every ranked one and is still written where it stands alone.
     */
    public static Boolean ranksBuyerRole(String role) {
        return role != null && AAO_MapValues.rankOf(DIM_BUYER_ROLE, role) != null;
    }

    /**
     * PROBLEMS, and the vendor card TYPE each code writes. The type is the judgment call 3
     * makes (type matching is the verified judgment, forty-second stamp), so the mapping from
     * our code to the vendor's picklist is arithmetic once that judgment stands.
     */
    private static final Map<String, String> PROBLEM_TYPE = new Map<String, String>{
        'AAO_PB_GOAL' => 'Goal',
        'AAO_PB_PRESS' => 'Pressure',
        'AAO_PB_INIT' => 'Initiative',
        'AAO_PB_OBST' => 'Obstacle'
    };

    /** The vendor card type this code establishes, or null where the code is not a Problem. */
    public static String problemType(String code) {
        return String.isBlank(code) ? null : PROBLEM_TYPE.get(code);
    }

    /** Sentiment. One contract; its meaning is the state, and the counter does the rest. */
    public static final String SENTIMENT = 'AAO_PS_1';

    /** Criteria. Naming carries the criterion; the other two type and gate the one it named. */
    public static final String CRITERION_NAMING = 'AAO_DC_N';
    public static final String CRITERION_FORMAL = 'AAO_DC_F';
    public static final String CRITERION_REQUIRED = 'AAO_DC_R';

    private static final Map<String, String> DIMENSION_OF = buildDimensionOf();

    private static Map<String, String> buildDimensionOf() {
        Map<String, String> m = new Map<String, String>();
        m.put(SENTIMENT, DIM_SUPPORT);
        for (String code : POLITICAL_PLACEMENT.keySet()) {
            m.put(code, DIM_POLITICAL);
        }
        for (String code : BUYER_ROLE.keySet()) {
            m.put(code, DIM_BUYER_ROLE);
        }
        m.put(CRITERION_NAMING, DIM_CRITERIA);
        m.put(CRITERION_FORMAL, DIM_CRITERIA);
        m.put(CRITERION_REQUIRED, DIM_CRITERIA);
        for (String code : PROBLEM_TYPE.keySet()) {
            m.put(code, DIM_PROBLEMS);
        }
        return m;
    }

    // ------------------------------------------------------------------------ readers

    /** The dimension this code places on, or null where the code is not one of ours. */
    public static String dimensionOf(String code) {
        return String.isBlank(code) ? null : DIMENSION_OF.get(code);
    }

    public static Boolean isKnown(String code) {
        return dimensionOf(code) != null;
    }

    /** The Political Status value this code establishes, or null. */
    public static String politicalPlacement(String code) {
        return String.isBlank(code) ? null : POLITICAL_PLACEMENT.get(code);
    }

    /** The Buyer Role value this code establishes, or null. */
    public static String buyerRole(String code) {
        return String.isBlank(code) ? null : BUYER_ROLE.get(code);
    }

    /**
     * Every code that establishes a Buyer Role. These seventeen are OURS, so naming them in
     * Apex is lawful here in a way it never is for a discovered rubric: the computed catalog
     * reads the People ledger through them and reaches the Process questions through
     * configuration instead. Ours by code, theirs by config, and the line between is the same
     * line LAW #1 draws everywhere else.
     */
    public static Set<String> buyerRoleCodes() {
        return BUYER_ROLE.keySet().clone();
    }

    /** The code that establishes a given Buyer Role value, or null. */
    public static String codeForBuyerRole(String value) {
        if (String.isBlank(value)) {
            return null;
        }
        for (String code : BUYER_ROLE.keySet()) {
            if (BUYER_ROLE.get(code) == value) {
                return code;
            }
        }
        return null;
    }

    /** The stored Buyer Role value our own decision-maker code names. */
    public static final String BUYER_ROLE_DECISION_MAKER_CODE = 'AAO_BR_DM';

    /**
     * The highest placement in a set of established Political values, or null for an empty
     * set. **Nobody is placed by absence**: an empty set returns null and the field is left
     * alone rather than written `Unknown`.
     */
    public static String politicalCeiling(Set<String> placements) {
        // Same procedure, same guarantee. This dimension could always answer because its
        // vocabulary was closed and fully ranked; it now answers from the same configured
        // ranks, so an org that adds a placement gets a ranking it can state rather than a
        // silent fall-through.
        return AAO_MapValues.decide(DIM_POLITICAL, placements);
    }

    // -------------------------------------------------------------------- the guard

    /**
     * Every declared contract has a placement, and every placement has a declared contract.
     *
     * Called from the suite rather than at run time, because the failure it catches is a
     * build-time one: minting a contract this class has never heard of would make its answers
     * unplaceable, which is the v3.9 defect exactly - a code the writer silently skips.
     * Symmetric on purpose: a placement with no contract is a rule for a question nobody asks.
     */
    public static void assertCovers(List<AAO_PassContracts.Spec> specs) {
        Set<String> declared = new Set<String>();
        List<String> unplaced = new List<String>();
        for (AAO_PassContracts.Spec sp : specs) {
            declared.add(sp.code);
            if (!isKnown(sp.code)) {
                unplaced.add(sp.code);
            }
        }
        List<String> unasked = new List<String>();
        for (String code : DIMENSION_OF.keySet()) {
            if (!declared.contains(code)) {
                unasked.add(code);
            }
        }
        if (unplaced.isEmpty() && unasked.isEmpty()) {
            return;
        }
        unplaced.sort();
        unasked.sort();
        throw new CodeException(
            'The declared set and the placement map disagree. Contracts with no placement ' +
            '(their answers would be silently skipped): ' +
            (unplaced.isEmpty() ? 'none' : String.join(unplaced, ', ')) +
            '. Placements with no contract (a rule for a question nobody asks): ' +
            (unasked.isEmpty() ? 'none' : String.join(unasked, ', ')) +
            '.'
        );
    }
}