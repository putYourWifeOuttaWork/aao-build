/**
 * THE MISSING-RELATION FLAG. Ruled v1.5, and the ruling is about SHAPE rather than content.
 *
 * Keyed on deal plus relation kind. Not per card, not per deal.
 *
 *   Per card would be noise. Twelve solutions with no stated problem is twelve flags saying
 *   the same sentence, and a flag list nobody reads protects nobody.
 *
 *   Per deal would be useless. "Something is missing an edge" cannot be acted on, because
 *   the three kinds are three different conversations: a solution with no stated problem is
 *   a discovery gap, a pressure with no linked goal is a qualification gap, and a person
 *   with no influence edges is a mapping gap. Rolling them together would produce a number
 *   nobody can do anything with.
 *
 * So one flag per kind per deal, rolling up, NAMING THE ROWS INSIDE IT. The count is the
 * headline and the members are the work.
 *
 * GENERAL ON PURPOSE. The Solutions case surfaced it, but the Pressure-to-Goal hole and the
 * Politics influence edges want exactly this, and building it three times would be three
 * places for it to drift apart.
 *
 * CLEARANCE IS THE COUNT REACHING ZERO AND NOTHING ELSE. There is no dismissal on this flag
 * any more than on the others: its cause is that edges do not exist, so the only thing that
 * clears it is the edges existing. A flag that can be waved away stops being evidence that
 * anything was ever checked.
 */
public class AAO_MissingRelation {
    public static final String TYPE = 'Missing_Relation';
    public static final String CAUSE = 'Relation_Missing';

    public static final String SOLUTION_WITHOUT_PROBLEM = 'Solution_Without_Problem';
    public static final String PRESSURE_WITHOUT_GOAL = 'Pressure_Without_Goal';
    public static final String PERSON_WITHOUT_INFLUENCE_EDGE = 'Person_Without_Influence_Edge';

    /** One row that is missing its relation. Named, because a count alone is not actionable. */
    public class Member {
        public String id;
        public String label;

        public Member(String id, String label) {
            this.id = id;
            this.label = label;
        }
    }

    public static String key(Id opportunityId, String relationKind) {
        return String.valueOf(opportunityId) + '|' + relationKind;
    }

    /**
     * Bring the flag for one deal and one relation kind into line with what is actually
     * missing. Idempotent: called with the same set twice it writes nothing the second time
     * beyond the watermark, and called with an empty set it clears.
     *
     * `missing` is computed by whoever knows the relation — this class deliberately does not
     * know what a Solution or a Pressure is, because the moment it does it stops being
     * general and starts being three classes wearing one name.
     */
    public static AAO_Flag__c reconcile(
        Id opportunityId,
        Id accountId,
        String relationKind,
        List<Member> missing
    ) {
        String k = key(opportunityId, relationKind);
        List<AAO_Flag__c> found = [
            SELECT
                Id,
                AAO_State__c,
                AAO_Missing_Count__c,
                AAO_Missing_Members__c,
                AAO_Cleared_At__c,
                AAO_Raised_At__c
            FROM AAO_Flag__c
            WHERE AAO_Relation_Key__c = :k
            LIMIT 1
        ];
        AAO_Flag__c flag = found.isEmpty() ? null : found[0];
        Integer count = missing == null ? 0 : missing.size();

        if (count == 0) {
            if (flag == null || flag.AAO_State__c == 'Cleared') {
                // Nothing missing and nothing standing. A flag is not raised just to be
                // cleared: the absence of a gap is not an event.
                return flag;
            }
            flag.AAO_State__c = 'Cleared';
            flag.AAO_Cleared_At__c = System.now();
            flag.AAO_Missing_Count__c = 0;
            flag.AAO_Missing_Members__c = JSON.serialize(new List<Member>());
            update flag;
            return flag;
        }

        String members = JSON.serialize(missing);
        if (flag == null) {
            flag = new AAO_Flag__c(
                AAO_Opportunity__c = opportunityId,
                AAO_Account__c = accountId,
                AAO_Type__c = TYPE,
                AAO_Cause__c = CAUSE,
                AAO_State__c = 'Standing',
                AAO_Relation_Kind__c = relationKind,
                AAO_Relation_Key__c = k,
                AAO_Missing_Count__c = count,
                AAO_Missing_Members__c = members,
                // Fires from the start, like day-one red: the gap exists from the moment
                // the row does, and dating it to when we noticed would make every one of
                // these look as young as the code that looked.
                AAO_Raised_At__c = raisedAt(opportunityId)
            );
            insert flag;
            return flag;
        }

        flag.AAO_Missing_Count__c = count;
        flag.AAO_Missing_Members__c = members;
        if (flag.AAO_State__c == 'Cleared') {
            // It closed and reopened: a new row of this kind arrived without its edge.
            //
            // THE CLOCK DOES NOT RESTART, and the existing law decided that rather than me.
            // AAO_Raised_At__c is immutable by trigger, so the first attempt to restart it
            // was refused — and the refusal is right. This flag is one standing question
            // about the deal, "does this deal have solutions with no stated problem", and
            // that question has been askable since the deal existed. A gap reappearing is
            // the same question answering yes again, not a new question. Restarting would
            // have let a deal look freshly imperfect forever by closing and reopening.
            flag.AAO_State__c = 'Standing';
            flag.AAO_Cleared_At__c = null;
        }
        update flag;
        return flag;
    }

    /**
     * Age is measured from the DEAL, matching day-one red. A gap that has stood since the
     * opportunity existed should not read as new because we only just built the check.
     */
    private static Datetime raisedAt(Id opportunityId) {
        List<Opportunity> o = [
            SELECT CreatedDate FROM Opportunity WHERE Id = :opportunityId LIMIT 1
        ];
        return o.isEmpty() ? System.now() : o[0].CreatedDate;
    }

    /** What is standing on a deal, by kind. */
    public static Map<String, AAO_Flag__c> standing(Id opportunityId) {
        Map<String, AAO_Flag__c> out = new Map<String, AAO_Flag__c>();
        for (AAO_Flag__c f : [
            SELECT
                Id,
                AAO_Relation_Kind__c,
                AAO_Missing_Count__c,
                AAO_Missing_Members__c,
                AAO_Raised_At__c
            FROM AAO_Flag__c
            WHERE
                AAO_Opportunity__c = :opportunityId
                AND AAO_Type__c = :TYPE
                AND AAO_State__c != 'Cleared'
        ]) {
            out.put(f.AAO_Relation_Kind__c, f);
        }
        return out;
    }

    public static List<Member> members(AAO_Flag__c flag) {
        if (flag == null || String.isBlank(flag.AAO_Missing_Members__c)) {
            return new List<Member>();
        }
        return (List<Member>) JSON.deserialize(
            flag.AAO_Missing_Members__c,
            List<Member>.class
        );
    }
}
