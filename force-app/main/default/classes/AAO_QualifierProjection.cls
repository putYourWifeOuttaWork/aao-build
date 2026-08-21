/**
 * THE SALES-PROCESS QUALIFIER SURFACE'S WRITER. Writer (b).
 *
 * The seed creates the qualifiers and says in its own comment that the machine-readable mapping
 * from qualifier to answer belongs to the Process build rather than to the seed. The binding is
 * that mapping, and it lives in `AAO_Qualifier_Binding__mdt` rather than in this class for the
 * reason LAW #1 gives: a customer org carries its own rubric and its own qualifier text, and a
 * binding compiled into Apex would be ours imposed on theirs.
 *
 * ===== BIND, NOT MINT, and the two paths converged on it independently.
 *
 * Six of the evidence qualifiers restate an assessment contract almost word for word. Minting
 * twins would put two near-identical propositions through the reads on every pass, doubling the
 * bill on the surface where the first measured receipt came in at half the estimate, and
 * producing two answers that can drift. So one establishment lights both screens: this reads
 * `AAO_ProcessPanel.readingsFor`, the SAME reading and the SAME citation the assessment surface
 * and the Process panel use, and there is no third opinion available anywhere.
 *
 * ===== WHAT IT WILL NOT DO.
 *
 * **It writes nothing where nothing is established.** A qualifier with no evidence keeps
 * whatever it has; silence is not a No, and asserting one would be the machine answering a
 * question the customer never addressed.
 *
 * **It does not touch a qualifier ahead of the open stage.** Architecture: projection touches
 * only qualifiers at or behind the open stage. A deal with no ordinal - one sitting outside the
 * org's open stages - therefore gets nothing, which is the by-stage plane's honest fallback and
 * not a failure of this writer.
 *
 * **It never overwrites a human's comment**, by the same predicate and for the same reason the
 * assessment writer holds: exactly two things may occupy that field, a citation written by the
 * machine and prose written by a human.
 */
public with sharing class AAO_QualifierProjection {
    public class QualifierException extends Exception {
    }

    public static final String WRITER = 'AAO_Qualifier_Projection';
    public static final String WRITER_VERSION = '1.0.0';

    /** Measured from the picklist, never taken from a label. */
    private static final String YES = 'Yes';
    private static final String NO = 'No';
    /** `ALTF__Comment__c` is 32,768, so the citation budget problem does not exist here. */
    @TestVisible
    private static Integer COMMENT_CHARS = 32768;

    public class Outcome {
        public Integer created = 0;
        public Integer updated = 0;
        public Integer unchanged = 0;
        public Integer humanHeld = 0;
        public Integer unbound = 0;
        public List<String> notes = new List<String>();

        public override String toString() {
            return 'qualifier projection: created ' + created + ', updated ' + updated +
                ', unchanged ' + unchanged + ', held for a human ' + humanHeld +
 ', unbound ' + unbound +
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
            runKey, AAO_Receipt.sourceForRun(runKey), AAO_Receipt.STAGE_QUALIFIERS,
            System.currentTimeMillis() - startedAt, o.created + o.updated + o.unchanged
        );
        return o;
    }

    private static Outcome project(Id opportunityId, String runKey) {
        Outcome o = new Outcome();
        if (opportunityId == null) {
            return o;
        }
        if (!AAO_Modules.present(AAO_Modules.SALES_PROCESS, opportunityId)) {
            o.notes.add(AAO_Modules.absenceNote(AAO_Modules.SALES_PROCESS));
            return o;
        }
        List<ALTF__Opportunity__c> wrappers = [
            SELECT Id FROM ALTF__Opportunity__c
            WHERE ALTF__Opportunity__c = :opportunityId ORDER BY CreatedDate ASC LIMIT 1
        ];
        if (wrappers.isEmpty()) {
            o.notes.add(
                'No Altify Opportunity exists for this deal, so there is no sales process to ' +
                'qualify. Nothing written, and no wrapper invented as a side effect.'
            );
            return o;
        }
        Id wrapperId = wrappers[0].Id;

        // ===== AN ESTABLISHMENT WRITE IS RESIDENCE-INDEPENDENT, and this is a CORRECTION.
        //
        // This writer used to refuse a qualifier resident ahead of the deal's stage, and to
        // refuse the whole deal when it had no ordinal. Both were wrong, confirmed against
        // design's own reading at the hundred-sixty-fifth: **evidence is recorded wherever the
        // call put it.** FUNDS is resident at Discover, but a customer who names their budget
        // during the Qualify call has named it, and a surface that discards that until the deal
        // advances would be forgetting something true because of where the calendar is.
        //
        // The ordinal governs FLAGS and EXPECTATIONS - what is overdue, which ghost should
        // stand - and it is exactly the wrong instrument for what has been said out loud. A
        // qualifier is also resident at TWO stages in this org (Mutual close planning sits at
        // Propose and Commit), so single residence was never a safe assumption either.
        Map<String, AAO_Qualifier_Binding__mdt> bindings = bindings();
        if (bindings.isEmpty()) {
            o.notes.add('This org states no qualifier bindings, so nothing can be answered.');
            return o;
        }
        Map<String, AAO_ProcessPanel.Reading> readings =
            AAO_ProcessPanel.readingsFor(opportunityId);
        // THE COMPUTED PLANE, evaluated once for the whole deal. Arithmetic over rows we already
        // wrote: no contract, no model call, and a state citation naming the rows rather than a
        // quote, because nobody said it.
        Map<String, AAO_QualifierCompute.Verdict> computed =
            AAO_QualifierCompute.evaluate(opportunityId);

        // The qualifier definitions and the stage each sits at, through the junction.
        Map<Id, Decimal> stageOf = new Map<Id, Decimal>();
        Map<Id, String> codeOf = new Map<Id, String>();
        for (ALTF__Sales_Process_Stage_Qualifier__c j : [
            SELECT ALTF__Sales_Process_Qualifier__c,
                   ALTF__Sales_Process_Qualifier__r.ALTF__AltifyId__c,
                   ALTF__Sales_Process_Stage__r.ALTF__SortOrder__c
            FROM ALTF__Sales_Process_Stage_Qualifier__c
            WHERE ALTF__Sales_Process_Qualifier__c != null
        ]) {
            Id q = j.ALTF__Sales_Process_Qualifier__c;
            Decimal at = j.ALTF__Sales_Process_Stage__r == null
                ? null
                : j.ALTF__Sales_Process_Stage__r.ALTF__SortOrder__c;
            // ONE QUALIFIER CAN SIT AT TWO STAGES (CLOSEPLAN does, by design). The EARLIEST is
            // the one that matters: a qualifier asked at stage 4 is already being asked when
            // the deal reaches stage 4, whatever else asks it later.
            if (at != null && (!stageOf.containsKey(q) || at < stageOf.get(q))) {
                stageOf.put(q, at);
            }
            String full = j.ALTF__Sales_Process_Qualifier__r == null
                ? null
                : j.ALTF__Sales_Process_Qualifier__r.ALTF__AltifyId__c;
            if (String.isNotBlank(full)) {
                codeOf.put(q, full.substringAfterLast('|'));
            }
        }

        // ===== ON THIS SURFACE OWNERSHIP IS ENUMERATION, NOT SHAPE, and that is a correction
        // paid for with a real row.
        //
        // The comment predicate is right for the assessment note, where a human who writes
        // anything writes prose. It is WRONG here, and the proof is Matthew's WHEN1 tick: he
        // created that row by clicking Yes and left the comment blank. A blank comment reads as
        // "nobody's, ours to fill" - true of a blank comment on OUR row, false of a blank
        // comment on HIS. This writer wrote a citation onto a row a human made, which is the
        // one law that does not bend, and it was restored by hand.
        //
        // So a row this writer did not create is held whole, whatever its comment says or does
        // not say. The watermark is the record of what we made; everything else is somebody
        // else's. The comment predicate stays as a second gate for rows that ARE ours, because
        // a human can still write prose onto one of them afterwards.
        Set<String> enumerated = new Set<String>();
        for (AAO_Created_Row__c r : [
            SELECT AAO_Target_Id__c FROM AAO_Created_Row__c
            WHERE AAO_Target_Object__c = 'ALTF__Qualifier_Answer__c' AND AAO_Disowned__c = false
        ]) {
            enumerated.add(r.AAO_Target_Id__c);
        }

        Map<Id, ALTF__Qualifier_Answer__c> standing = new Map<Id, ALTF__Qualifier_Answer__c>();
        for (ALTF__Qualifier_Answer__c qa : [
            SELECT Id, ALTF__Sales_Process_Qualifier__c, ALTF__Status__c, ALTF__Comment__c
            FROM ALTF__Qualifier_Answer__c WHERE ALTF__Opportunity__c = :wrapperId
        ]) {
            standing.put(qa.ALTF__Sales_Process_Qualifier__c, qa);
        }

        List<ALTF__Qualifier_Answer__c> fresh = new List<ALTF__Qualifier_Answer__c>();
        List<ALTF__Qualifier_Answer__c> patch = new List<ALTF__Qualifier_Answer__c>();

        for (Id qualifierId : codeOf.keySet()) {
            String code = codeOf.get(qualifierId);
            AAO_Qualifier_Binding__mdt b = bindings.get(code);
            if (b == null) {
                o.unbound++;
                continue;
            }
            String status;
            String comment;

            if (String.isNotBlank(b.AAO_Predicate__c)) {
                AAO_QualifierCompute.Verdict v = computed.get(b.AAO_Predicate__c);
                if (v == null) {
                    // The predicate had nothing to measure. Silence is not a No.
                    continue;
                }
                status = v.status;
                comment = v.because;
            } else if (String.isNotBlank(b.AAO_Contract_Codes__c)) {
                // ANY OF THE BOUND CONTRACTS SATISFIES IT. FUNDS reads "the funds OR the
                // person who owns them", so its binding is a disjunction and the first
                // established one answers.
                AAO_ProcessPanel.Reading hit;
                for (String c : b.AAO_Contract_Codes__c.split(';')) {
                    AAO_ProcessPanel.Reading r = readings.get(c.trim());
                    if (r == null) {
                        continue;
                    }
                    if (r.interpretation == 'AFFIRMED') {
                        hit = r;
                        break;
                    }
                    if (hit == null) {
                        hit = r;
                    }
                }
                if (hit == null) {
                    // Nothing established. Silence is not a No.
                    continue;
                }
                status = hit.interpretation == 'AFFIRMED'
                    ? YES
                    : (hit.interpretation == 'DENIED' ? NO : null);
                if (status == null) {
                    continue;
                }
                comment = String.isBlank(hit.citation) ? null : hit.citation;
            } else {
                o.unbound++;
                continue;
            }
            if (comment != null && comment.length() > COMMENT_CHARS) {
                // A citation is never truncated mid-quote.
                comment = null;
            }

            ALTF__Qualifier_Answer__c row = standing.get(qualifierId);
            if (row == null) {
                fresh.add(new ALTF__Qualifier_Answer__c(
                    ALTF__Opportunity__c = wrapperId,
                    ALTF__Sales_Process_Qualifier__c = qualifierId,
                    ALTF__Status__c = status,
                    ALTF__Comment__c = comment
                ));
                continue;
            }
            String rowId = String.valueOf(row.Id);
            Boolean weMadeIt =
                enumerated.contains(rowId) || enumerated.contains(rowId.substring(0, 15));
            if (!weMadeIt) {
                o.humanHeld++;
                o.notes.add(
                    'Held on ' + code + ': this writer did not create that row, so it is ' +
                    'somebody else\'s whole. Status and comment untouched.'
                );
                continue;
            }
            if (AAO_AnswerProjection.heldByHuman(row.ALTF__Comment__c)) {
                o.humanHeld++;
                o.notes.add('Held for a human on ' + code + ': the comment is not ours.');
                continue;
            }
            if (row.ALTF__Status__c == status && row.ALTF__Comment__c == comment) {
                o.unchanged++;
                continue;
            }
            row.ALTF__Status__c = status;
            row.ALTF__Comment__c = comment;
            patch.add(row);
        }

        if (!fresh.isEmpty()) {
            insert fresh;
            o.created = fresh.size();
            String orgId = String.valueOf(UserInfo.getOrganizationId());
            List<ALTF__Qualifier_Answer__c> named = new List<ALTF__Qualifier_Answer__c>();
            List<Id> created = new List<Id>();
            for (ALTF__Qualifier_Answer__c qa : fresh) {
                String id18 = String.valueOf(qa.Id);
                named.add(new ALTF__Qualifier_Answer__c(
                    Id = qa.Id,
                    Name = id18.substring(0, 15),
                    ALTF__AltifyId__c = orgId + '-' + id18
                ));
                created.add(qa.Id);
            }
            update named;
            AAO_CreatedRows.recordAll(
                created, WRITER + '@' + WRITER_VERSION, 'qualifier-answer',
                'Projected from an establishment this qualifier binds to, with its citation.',
                runKey == null ? null : AAO_Receipt.sourceForRun(runKey), runKey
            );
        }
        if (!patch.isEmpty()) {
            update patch;
            o.updated = patch.size();
        }
        return o;
    }

    private static Map<String, AAO_Qualifier_Binding__mdt> bindings() {
        Map<String, AAO_Qualifier_Binding__mdt> out =
            new Map<String, AAO_Qualifier_Binding__mdt>();
        for (AAO_Qualifier_Binding__mdt b : [
            SELECT AAO_Qualifier_Code__c, AAO_Contract_Codes__c, AAO_Predicate__c, AAO_Plane__c
            FROM AAO_Qualifier_Binding__mdt
        ]) {
            if (String.isNotBlank(b.AAO_Qualifier_Code__c)) {
                out.put(b.AAO_Qualifier_Code__c, b);
            }
        }
        return out;
    }
}
