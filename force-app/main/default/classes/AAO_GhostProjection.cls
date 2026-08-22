/**
 * THE PERSONA GHOSTS, PROJECTED ONTO THE MAP.
 *
 * A ghost is a persona a stage expects and nobody on this deal fills. `AAO_Personas` computes
 * them; this writes them where the map can draw them, as `ALTF__Relationship_Map_Persona__c`.
 *
 * ===== THIS REVERSES A REFUSAL, AND THE REVERSAL HAS AN AUTHOR.
 *
 * `AAO_Personas` still carries the sentence *"We also write nothing to
 * `ALTF__Relationship_Map_Persona__c`: manufacturing vendor rows is refused as default
 * (122nd)."* That refusal stood on a frame the hundred-fifty-first retired: these are not
 * vendor rows to be manufactured, they are OUR projection surface, named across the law
 * documents. The measured half of that comment stands untouched and is why this class exists at
 * all rather than the map writer being changed:
 * `ALTF__Contact_Map_Details__c.ALTF__Contact__c` is `nillable = false`, measured three times,
 * so an unfilled persona can never stand as a map-details row. **`ALTF__Relationship_Map_Persona__c`
 * has no Contact field at all** - measured here, and that is precisely why a ghost fits on it
 * and not on the other.
 *
 * ===== ONE DECISION HERE HAS NO WORKED EXAMPLE, AND IS NAMED RATHER THAN BURIED.
 *
 * `ALTF__Persona__c` is a MULTIPICKLIST, and this org holds ZERO rows of this object, so there
 * is no vendor row to copy the way the assessment writer copies theirs. One row could carry
 * every expected persona, or one row could carry one. **This writes ONE ROW PER PERSONA**, for
 * two reasons: it is the grain `AAO_Persona_Expectation__mdt` already states ("one row per
 * persona STORED VALUE, never a label"), and a map that draws a ghost per row can only place
 * distinct ghosts if the rows are distinct. If their UI wants the other grain, the change is
 * this method and nothing else, and the rows are enumerated so they can be withdrawn whole.
 */
public with sharing class AAO_GhostProjection {
    public class GhostProjectionException extends Exception {
    }

    public static final String WRITER = 'AAO_Ghost_Projection';
    public static final String WRITER_VERSION = '1.0.0';
    private static final String KEY = 'AAO|RMP|';
    /** The vendor's own word for a slot that is not yet a person. Adopted, not invented. */
    private static final String PLACEHOLDER = 'Placeholder';

    public class Outcome {
        public Integer created = 0;
        public Integer unchanged = 0;
        public Integer withdrawn = 0;
        public List<String> notes = new List<String>();

        public override String toString() {
            return 'ghost projection: created ' + created + ', unchanged ' + unchanged +
                ', withdrawn ' + withdrawn +
                (notes.isEmpty() ? '' : ' | ' + String.join(notes, ' | '));
        }
    }

    public static Outcome run(Id opportunityId) {
        return project(opportunityId, null);
    }

    /** The stage entry, which journals a leg. */
    public static Outcome run(Id opportunityId, String runKey) {
        if (String.isBlank(runKey)) {
            return project(opportunityId, null);
        }
        Long startedAt = System.currentTimeMillis();
        Outcome o = project(opportunityId, runKey);
        AAO_Receipt.record(
            runKey, AAO_Receipt.sourceForRun(runKey), AAO_Receipt.STAGE_GHOSTS,
            System.currentTimeMillis() - startedAt, o.created + o.unchanged
        );
        return o;
    }

    /** One ledger entry per VALUE, because the value is the unit the vendor gave us to own. */
    private static final String LEG = 'persona-ghost';

    private static Outcome project(Id opportunityId, String runKey) {
        Outcome o = new Outcome();
        if (opportunityId == null) {
            return o;
        }
        if (!AAO_Modules.present(AAO_Modules.RELATIONSHIP_MAP, opportunityId)) {
            o.notes.add(AAO_Modules.absenceNote(AAO_Modules.RELATIONSHIP_MAP));
            return o;
        }
        Opportunity deal = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId];
        if (deal.AccountId == null) {
            o.notes.add(
                'This deal has no Account, and the persona row requires one, so no ghost can ' +
                'stand. Absence with its reason.'
            );
            return o;
        }

        AAO_Personas.Reading reading = AAO_Personas.ghostsOn(opportunityId);
        Set<String> wanted = new Set<String>();
        for (AAO_Personas.Ghost g : reading.ghosts) {
            wanted.add(g.persona);
        }

        // ===== ONE ROW PER MAP, AND OWNERSHIP AT THE VALUE GRAIN.
        //
        // The vendor holds ONE persona row per map - a second row with a different persona is
        // refused, one row with three values is accepted - so the row is not a unit anyone can
        // own. Under row-grain ownership a map whose single row a human touched first could
        // never carry our cast at all, which is most real deals in most real orgs: the flagship
        // People feature silently absent exactly where sellers work.
        //
        // So the hundred-seventy-fifth moves ownership to the VALUE: **we ADD values and
        // enumerate each one we added; we REMOVE only values we enumerated; a human's values
        // are never touched, reordered, or removed; and a human deleting the row deletes ours
        // with it, because the human wins.** The precedent is standing - the machine already
        // adds to `ALTF__Contact__c`'s persona multipicklist and never removes a human's.
        //
        // The line against the WHEN1 incident, so it stays usable: writing INTO a human's
        // content alters what they expressed; adding a value beside theirs on a field whose
        // vendor-defined grain is shared does not.
        List<ALTF__Relationship_Map_Persona__c> rows = [
            SELECT Id, ALTF__Persona__c, ALTF__Functional_Role__c
            FROM ALTF__Relationship_Map_Persona__c
            WHERE ALTF__Opportunity__c = :opportunityId
            ORDER BY CreatedDate ASC
        ];

        ALTF__Relationship_Map_Persona__c row = rows.isEmpty() ? null : rows[0];
        Set<String> standing = new Set<String>();
        if (row != null && String.isNotBlank(row.ALTF__Persona__c)) {
            for (String v : row.ALTF__Persona__c.split(';')) {
                standing.add(v.trim());
            }
        }
        // OUR VALUES, by the ledger rather than by resemblance.
        Set<String> oursByLedger = new Set<String>();
        if (row != null) {
            String rowId15 = String.valueOf(row.Id).substring(0, 15);
            for (AAO_Created_Row__c r : [
                SELECT AAO_Leg__c, AAO_Target_Id__c FROM AAO_Created_Row__c
                WHERE AAO_Target_Object__c = 'ALTF__Relationship_Map_Persona__c'
                  AND AAO_Disowned__c = false
            ]) {
                if (String.isBlank(r.AAO_Target_Id__c) ||
                        !r.AAO_Target_Id__c.startsWith(rowId15)) {
                    continue;
                }
                if (String.isNotBlank(r.AAO_Leg__c) && r.AAO_Leg__c.startsWith(LEG + ':')) {
                    oursByLedger.add(r.AAO_Leg__c.substringAfter(LEG + ':'));
                }
            }
        }

        Set<String> toAdd = new Set<String>();
        for (String persona : wanted) {
            if (!standing.contains(persona)) {
                toAdd.add(persona);
            }
        }
        Set<String> toRemove = new Set<String>();
        for (String persona : standing) {
            // ONLY VALUES WE ENUMERATED. A human's value is never removed, and a value standing
            // on the row that no ledger entry claims is somebody else's by definition.
            if (!wanted.contains(persona) && oursByLedger.contains(persona)) {
                toRemove.add(persona);
            }
        }
        for (String persona : standing) {
            if (!wanted.contains(persona) && !oursByLedger.contains(persona)) {
                o.notes.add(
                    persona + ' stands on this map and no ledger entry of ours claims it, so it ' +
                    'is left exactly where it is.'
                );
            }
        }

        if (toAdd.isEmpty() && toRemove.isEmpty()) {
            o.unchanged = standing.size();
            return o;
        }

        Set<String> after = new Set<String>(standing);
        after.addAll(toAdd);
        after.removeAll(toRemove);

        if (row == null) {
            ALTF__Relationship_Map_Persona__c fresh = new ALTF__Relationship_Map_Persona__c(
                ALTF__Account__c = deal.AccountId,
                ALTF__Opportunity__c = opportunityId,
                ALTF__Persona__c = String.join(new List<String>(after), ';'),
                // THE VENDOR'S OWN PLACEHOLDER, adopted rather than invented. Its entire value
                // set is the single value `Placeholder`, which is strong evidence it already
                // holds the concept of an expected slot that is not yet a person. Whether it
                // renders differently is UNVERIFIED and is Matthew's to see; setting it costs
                // nothing and adopting the vendor's vocabulary is the same discipline that made
                // us write answers under their conventions instead of ours.
                ALTF__Functional_Role__c = PLACEHOLDER,
                ALTF__AltifyId__c = KEY + String.valueOf(opportunityId).substring(0, 15)
            );
            insert fresh;
            row = fresh;
        } else if (after.isEmpty()) {
            // Every value on the row was ours and none is wanted. The row goes with them.
            delete row;
            o.withdrawn = toRemove.size();
            return o;
        } else {
            update new ALTF__Relationship_Map_Persona__c(
                Id = row.Id, ALTF__Persona__c = String.join(new List<String>(after), ';')
            );
        }

        // ONE LEDGER ENTRY PER VALUE ADDED, naming the value, so withdrawal is exact.
        List<AAO_Created_Row__c> entries = new List<AAO_Created_Row__c>();
        for (String persona : toAdd) {
            entries.add(new AAO_Created_Row__c(
                AAO_Target_Id__c = String.valueOf(row.Id),
                AAO_Target_Object__c = 'ALTF__Relationship_Map_Persona__c',
                AAO_Source_Form__c = WRITER + '@' + WRITER_VERSION,
                AAO_Leg__c = LEG + ':' + persona,
                AAO_Reason__c =
                    'A persona this deal\'s rubric demands, standing from call one as a ' +
                    'lead-time node rather than a flag.',
                AAO_Run_Key__c = runKey
            ));
        }
        if (!entries.isEmpty()) {
            insert entries;
        }
        o.created = toAdd.size();
        o.withdrawn = toRemove.size();
        o.unchanged = standing.size() - toRemove.size();
        return o;
    }
}
