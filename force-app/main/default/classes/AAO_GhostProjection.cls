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

        // ===== ONE ROW PER MAP, MULTI-VALUED. The vendor refused the other grain.
        //
        // The hundred-fifty-second ratified one row per persona, on the reasoning that ghosts
        // must graduate INDEPENDENTLY - a contact matching Executive Sponsor must not clear a
        // standing Procurement Lead. The reasoning is right; the grain was not available.
        // Measured by being refused:
        //
        //   FIRST ROW accepted
        //   SECOND ROW, different persona, same map: REFUSED
        //   ONE ROW carrying three personas: ACCEPTED
        //
        // `Cannot insert duplicate Relationship Map Personas` is the vendor holding ONE persona
        // row per map, which is what its multipicklist was always for. **Independence survives
        // the change**: adding a ghost adds a value, graduating one removes that value, and the
        // others are untouched either way. It is a field edit rather than a row delete, and the
        // 154th's withdrawal rule reads the same.
        List<ALTF__Relationship_Map_Persona__c> rows = [
            SELECT Id, ALTF__Persona__c, ALTF__AltifyId__c
            FROM ALTF__Relationship_Map_Persona__c
            WHERE ALTF__Opportunity__c = :opportunityId
            ORDER BY CreatedDate ASC
        ];

        Set<String> enumerated = new Set<String>();
        for (AAO_Created_Row__c r : [
            SELECT AAO_Target_Id__c FROM AAO_Created_Row__c
            WHERE AAO_Target_Object__c = 'ALTF__Relationship_Map_Persona__c'
              AND AAO_Disowned__c = false
        ]) {
            enumerated.add(r.AAO_Target_Id__c);
        }

        if (rows.isEmpty()) {
            if (wanted.isEmpty()) {
                return o;
            }
            ALTF__Relationship_Map_Persona__c fresh = new ALTF__Relationship_Map_Persona__c(
                ALTF__Account__c = deal.AccountId,
                ALTF__Opportunity__c = opportunityId,
                ALTF__Persona__c = String.join(new List<String>(wanted), ';'),
                ALTF__AltifyId__c = KEY + String.valueOf(opportunityId).substring(0, 15)
            );
            insert fresh;
            o.created = wanted.size();
            AAO_CreatedRows.record(
                fresh.Id, WRITER + '@' + WRITER_VERSION, 'persona-ghost',
                'The cast this deal\'s rubric demands, standing from call one as lead-time ' +
                'nodes rather than flags.',
                runKey == null ? null : AAO_Receipt.sourceForRun(runKey), runKey
            );
            return o;
        }

        ALTF__Relationship_Map_Persona__c row = rows[0];
        String rowId = String.valueOf(row.Id);
        Boolean ours = enumerated.contains(rowId) || enumerated.contains(rowId.substring(0, 15));
        Set<String> standing = new Set<String>();
        if (String.isNotBlank(row.ALTF__Persona__c)) {
            for (String v : row.ALTF__Persona__c.split(';')) {
                standing.add(v.trim());
            }
        }

        if (!ours) {
            // SOMEBODY ELSE'S ROW. We may still need a ghost it does not carry, but the row is
            // theirs and this writer does not edit it - the same discipline the qualifier
            // surface learned on Matthew's WHEN1 tick, and the vendor allows no second row to
            // put ours beside it.
            for (String persona : wanted) {
                if (!standing.contains(persona)) {
                    o.notes.add(
                        'Ghost ' + persona + ' is owed but the map\'s only persona row was ' +
                        'written by somebody else, and the vendor allows just one. Held whole ' +
                        'rather than edited, and said out loud.'
                    );
                }
            }
            o.unchanged = standing.size();
            return o;
        }

        Set<String> after = new Set<String>(wanted);
        Integer added = 0;
        Integer withdrawn = 0;
        for (String persona : wanted) {
            if (!standing.contains(persona)) {
                added++;
            }
        }
        for (String persona : standing) {
            if (!wanted.contains(persona)) {
                // A GHOST THAT GRADUATED IS WITHDRAWN, one value at a time, leaving the rest
                // standing. A ghost beside the person who fills it is a lie the map tells
                // forever.
                withdrawn++;
            }
        }
        if (added == 0 && withdrawn == 0) {
            o.unchanged = standing.size();
            return o;
        }
        if (after.isEmpty()) {
            delete row;
            o.withdrawn = withdrawn;
            return o;
        }
        update new ALTF__Relationship_Map_Persona__c(
            Id = row.Id, ALTF__Persona__c = String.join(new List<String>(after), ';')
        );
        o.created = added;
        o.withdrawn = withdrawn;
        o.unchanged = standing.size() - withdrawn;
        return o;
    }
}
