/**
 * The applicable set for one pass, DECLARED and never global.
 *
 * **`AAO_Rubric.contracts()` is marked wrong for this job in its own class comment.** It reads
 * every non-superseded contract in the org, which was right when there was one rubric and
 * discovery was proving it could be built at all. It is wrong law now: a pass on one deal would
 * be handed every charter's contracts and every other deal's people.
 *
 * **Resolution is per charter, and differently per charter, because the scoping rule differs by
 * kind.** That asymmetry is the point rather than an inconsistency:
 *
 * - **People** resolves **per roster.** A person-contract is applicable only where its subject
 *   contact is on the given deal's map or among the Source's own participants. Charter scoping
 *   alone would not stop Ashley's sixteen questions being asked on an unrelated T-Mobile deal;
 *   **roster scoping is what makes person-contracts safe to exist globally at all.**
 * - **Process** resolves **per deal through the config chain** (plan type → plan-type-list row →
 *   question codes). That chain is Architecture's and is not wired into this resolver yet, which
 *   is stated in `resolveProcess` rather than papered over.
 *
 * **Nothing is handed to the model that did not resolve**, so the completeness numbers on a pass
 * mean what they say.
 */
public with sharing class AAO_ApplicableSet {
    public class ApplicableSetException extends Exception {
    }

    public static final String PEOPLE = 'People';
    public static final String PROBLEMS = 'Problems';
    public static final String POLITICS = 'Politics';
    public static final String PROCESS = 'Process';

    public class Resolved {
        /** Code to contract, exactly what the pass may hand the model. */
        public Map<String, AAO_Evidence_Contract__c> contracts =
            new Map<String, AAO_Evidence_Contract__c>();
        /** Per charter, how many resolved, for the journal and the pass outcome. */
        public Map<String, Integer> countByCharter = new Map<String, Integer>();
        /** Charters declared that resolved nothing, and why. Never silent. */
        public Map<String, String> emptyReasons = new Map<String, String>();
        /** People only: the roster the person-contracts were scoped against. */
        public Set<Id> roster = new Set<Id>();

        public override String toString() {
            String s = 'applicable set: ' + contracts.size() + ' contracts';
            for (String c : countByCharter.keySet()) {
                s += '\n  ' + c + ': ' + countByCharter.get(c);
            }
            for (String c : emptyReasons.keySet()) {
                s += '\n  ' + c + ': 0 — ' + emptyReasons.get(c);
            }
            return s;
        }
    }

    /**
     * Resolve a declared charter set for one Source.
     *
     * The charter set is declared by the caller and never inferred. A pass that wants People
     * says People; there is no "everything" and asking for one is a refusal rather than a
     * convenience, because "everything" is the law this class replaces.
     */
    public static Resolved resolve(Set<String> charters, AAO_Source__c src) {
        if (charters == null || charters.isEmpty()) {
            throw new ApplicableSetException(
                'A pass must declare which charters it is running. There is no global ' +
                'applicable set any more: the org-wide read was right for one rubric in ' +
                'discovery and is wrong law now.'
            );
        }
        if (src == null || src.AAO_Opportunity__c == null) {
            throw new ApplicableSetException(
                'Cannot resolve an applicable set without a Source and its deal. Scoping is ' +
                'per deal for every charter, so an unscoped Source has no answer here.'
            );
        }
        Resolved r = new Resolved();
        for (String charter : charters) {
            if (charter == PEOPLE) {
                resolvePeople(r, src);
            } else if (charter == PROCESS) {
                resolveProcess(r, src);
            } else {
                // Problems and Politics are unopened charters. Declaring one is not an error,
                // and pretending it resolved would be.
                r.emptyReasons.put(
                    charter,
                    'the ' + charter + ' charter is not built, so no contract carries its ' +
                    'designation and nothing can resolve'
                );
            }
        }
        return r;
    }

    // ------------------------------------------------------------------ People · roster

    /**
     * A person-contract is applicable where its subject is in the room or on the map.
     *
     * The roster is the union of two sources, deliberately: the deal's own map rows, which is
     * who the seller has already said matters, and the Source's participants, which is who
     * actually spoke. **Evidence introduces people the CRM has not caught up with**, so
     * restricting to the map alone would make the create leg of the writer unreachable.
     */
    private static void resolvePeople(Resolved r, AAO_Source__c src) {
        r.roster = rosterFor(src);
        if (r.roster.isEmpty()) {
            r.emptyReasons.put(
                PEOPLE,
                'no person is on this deal\'s map or among this Source\'s participants, so no ' +
                'person-contract is applicable'
            );
            return;
        }
        Integer n = 0;
        for (AAO_Evidence_Contract__c ec : [
            SELECT
                Id,
                AAO_Proposition_Code__c,
                AAO_Proposition_Short__c,
                AAO_Proposition_Text__c,
                AAO_Guidance_Text__c,
                AAO_Elements__c,
                AAO_Element_Count__c,
                AAO_Elements_Basis__c,
                AAO_Speaker_Requirement__c,
                AAO_Per_Person_Source__c,
                AAO_Gating__c,
                AAO_Route__c,
                AAO_Rubric_Version__c,
                AAO_Contract_State__c,
                AAO_Charter_Designation__c,
                AAO_Synthetic__c
            FROM AAO_Evidence_Contract__c
            WHERE
                AAO_Charter_Designation__c = :PEOPLE
                AND AAO_Contract_State__c != 'Superseded'
                AND AAO_Synthetic__c = :isSynthetic(src)
        ]) {
            Id subject = AAO_PeopleContracts.contactOf(ec.AAO_Proposition_Code__c);
            // A People contract with no person in its code is malformed rather than global.
            // Dropping it is correct: an unscopeable person-contract has no deal it belongs to.
            if (subject == null || !r.roster.contains(subject)) {
                continue;
            }
            r.contracts.put(ec.AAO_Proposition_Code__c, ec);
            n++;
        }
        r.countByCharter.put(PEOPLE, n);
        if (n == 0) {
            r.emptyReasons.put(
                PEOPLE,
                'the roster has ' + r.roster.size() + ' people but no People contract exists ' +
                'for any of them yet'
            );
        }
    }

    /** Map rows on the deal, plus whoever spoke on this artifact. */
    public static Set<Id> rosterFor(AAO_Source__c src) {
        Set<Id> out = new Set<Id>();
        for (ALTF__Contact_Map_Details__c m : [
            SELECT ALTF__Contact__c
            FROM ALTF__Contact_Map_Details__c
            WHERE ALTF__Opportunity__c = :src.AAO_Opportunity__c AND ALTF__Contact__c != NULL
        ]) {
            out.add(m.ALTF__Contact__c);
        }
        for (AAO_Participant__c p : [
            SELECT AAO_Contact__c
            FROM AAO_Participant__c
            WHERE AAO_Source__c = :src.Id AND AAO_Contact__c != NULL
        ]) {
            out.add(p.AAO_Contact__c);
        }
        return out;
    }

    // ----------------------------------------------------------------- Process · per deal

    /**
     * **Not wired, and saying so rather than guessing.**
     *
     * Assessment and qualifier contracts resolve per deal through the config chain ruled in
     * Architecture: plan type on the deal, to the plan-type-list row, to the question codes
     * that row admits. `AAO_Discovery` already walks that chain when it authors contracts at
     * cold start, but nothing persists the resulting binding as a queryable fact about the
     * deal, so this resolver cannot re-derive it from the deal alone.
     *
     * Until it can, Process resolves **charter-filtered but not deal-filtered**, which is
     * strictly narrower than the global read it replaces and is honestly labelled as a
     * half-measure rather than presented as the rule.
     */
    private static void resolveProcess(Resolved r, AAO_Source__c src) {
        Integer n = 0;
        for (AAO_Evidence_Contract__c ec : [
            SELECT
                Id,
                AAO_Proposition_Code__c,
                AAO_Proposition_Short__c,
                AAO_Proposition_Text__c,
                AAO_Guidance_Text__c,
                AAO_Elements__c,
                AAO_Element_Count__c,
                AAO_Elements_Basis__c,
                AAO_Speaker_Requirement__c,
                AAO_Per_Person_Source__c,
                AAO_Gating__c,
                AAO_Route__c,
                AAO_Rubric_Version__c,
                AAO_Contract_State__c,
                AAO_Charter_Designation__c,
                AAO_Synthetic__c
            FROM AAO_Evidence_Contract__c
            WHERE
                AAO_Contract_State__c != 'Superseded'
                AND AAO_Synthetic__c = :isSynthetic(src)
                AND (AAO_Charter_Designation__c = :PROCESS
                    OR AAO_Charter_Designation__c = NULL)
        ]) {
            // A People contract must never fall through the Process branch on a null
            // designation, so the person test runs here too.
            if (AAO_PeopleContracts.contactOf(ec.AAO_Proposition_Code__c) != null) {
                continue;
            }
            r.contracts.put(ec.AAO_Proposition_Code__c, ec);
            n++;
        }
        r.countByCharter.put(PROCESS, n);
        if (n == 0) {
            r.emptyReasons.put(PROCESS, 'no Process contract exists in this org');
        }
    }

    /**
     * Which of two populations a pass resolves against.
     *
     * **This deliberately preserves the semantics of the read it replaces and does not improve
     * on them.** `AAO_Pipeline.liveContracts()` called `AAO_Rubric.byCode()`, which is
     * `byCode(false)`: the product population, never the synthetic one, regardless of whether
     * the Source itself was marked. I first made this follow the Source's own flag, which reads
     * as more correct and is a **behaviour change** — it broke seven model-path tests whose
     * Source is marked and whose contracts are not.
     *
     * The scoping ruling changed WHICH contracts resolve, not WHICH POPULATION. Changing both
     * at once would have hidden a semantic change inside a structural one. Left as the caller's
     * choice to make explicitly, later, on purpose.
     */
    private static Boolean isSynthetic(AAO_Source__c src) {
        return false;
    }
}