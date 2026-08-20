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

        String prefix = KEY + String.valueOf(opportunityId).substring(0, 15) + '|';
        String ourKeys = prefix + '%';
        Map<String, ALTF__Relationship_Map_Persona__c> standing =
            new Map<String, ALTF__Relationship_Map_Persona__c>();
        for (ALTF__Relationship_Map_Persona__c p : [
            SELECT Id, ALTF__AltifyId__c, ALTF__Persona__c
            FROM ALTF__Relationship_Map_Persona__c
            WHERE ALTF__Opportunity__c = :opportunityId AND ALTF__AltifyId__c LIKE :ourKeys
        ]) {
            standing.put(p.ALTF__AltifyId__c, p);
        }

        List<ALTF__Relationship_Map_Persona__c> fresh =
            new List<ALTF__Relationship_Map_Persona__c>();
        for (String persona : wanted) {
            String key = prefix + persona;
            if (standing.containsKey(key)) {
                o.unchanged++;
                continue;
            }
            fresh.add(new ALTF__Relationship_Map_Persona__c(
                ALTF__Account__c = deal.AccountId,
                ALTF__Opportunity__c = opportunityId,
                ALTF__Persona__c = persona,
                ALTF__AltifyId__c = key
            ));
        }

        // A GHOST THAT GRADUATED IS WITHDRAWN, NOT LEFT STANDING. The persona filled, so the
        // slot is no longer empty and a ghost beside the person who fills it would be a lie the
        // map tells forever. Only rows carrying OUR key are touched: the key is the enumeration,
        // and a row somebody else made is not ours to withdraw.
        List<ALTF__Relationship_Map_Persona__c> gone =
            new List<ALTF__Relationship_Map_Persona__c>();
        for (String key : standing.keySet()) {
            if (!wanted.contains(key.substringAfter(prefix))) {
                gone.add(standing.get(key));
            }
        }

        if (!fresh.isEmpty()) {
            insert fresh;
            o.created = fresh.size();
            List<Id> created = new List<Id>();
            for (ALTF__Relationship_Map_Persona__c p : fresh) {
                created.add(p.Id);
            }
            AAO_CreatedRows.recordAll(
                created,
                WRITER + '@' + WRITER_VERSION,
                'persona-ghost',
                'A persona this stage expects that nobody on the deal fills.',
                runKey == null ? null : AAO_Receipt.sourceForRun(runKey),
                runKey
            );
        }
        if (!gone.isEmpty()) {
            delete gone;
            o.withdrawn = gone.size();
        }
        return o;
    }
}
