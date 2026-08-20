/**
 * THE ASSESSMENT SURFACE'S WRITER. Our answers become `ALTF__Assessment_Answer__c` rows with the
 * words that established them riding in the note.
 *
 * The hundred-fifty-first retired the word "vendor" for this surface and it is not retired here
 * either: the Altify screens are a PROJECTION OF OUR LEDGER, and this is the ledger reaching the
 * assessment screen. The never-write law is Opportunity and Account, the STANDARD objects. The
 * Altify managed objects are what we write; they are the project.
 *
 * ===== WHAT THIS WRITER WILL NOT DO, and each refusal is a measured constraint rather than
 * caution.
 *
 * **It never writes `Unknown`.** The picklist offers Yes, No and Unknown, and Unknown is what an
 * untouched row already says. Writing it would turn "we have established nothing here" into a
 * machine assertion, and the whole product is that a row says something only when words prove it.
 *
 * **It never creates the wrapper.** `ALTF__Assessment_Answer__c.ALTF__Opportunity__c` points at
 * `ALTF__Opportunity__c`, the Altify Opportunity, not at the standard one - measured, and the
 * same trap `AAO_Discovery` documents. A deal with no wrapper gets a note and no rows, because
 * wrapper creation is its own gated decision and not a side effect of projecting an answer.
 *
 * **It never overwrites a human's note.** The Note Payload law: exactly two things may occupy
 * that field, a citation written by the machine and prose written by a human. Anything that is
 * not blank and does not carry the shape this writer produces is treated as a human's and the
 * whole row is held, answer included, because half-writing a row a human owns is worse than
 * leaving it alone.
 */
public with sharing class AAO_AnswerProjection {
    public class ProjectionException extends Exception {
    }

    public static final String WRITER = 'AAO_Answer_Projection';
    public static final String WRITER_VERSION = '1.0.0';

    /** The stored values, measured from the picklist rather than assumed from the labels. */
    private static final String YES = 'Yes';
    private static final String NO = 'No';

    /** `ALTF__Note__c` is 2,048. The qualifier surface's comment is 32,768; this one is not. */
    @TestVisible
    private static Integer NOTE_CHARS = 2048;

    public class Outcome {
        public Integer created = 0;
        public Integer updated = 0;
        public Integer unchanged = 0;
        public Integer humanHeld = 0;
        public Integer noQuestion = 0;
        public List<String> notes = new List<String>();

        public override String toString() {
            return 'assessment projection: created ' + created + ', updated ' + updated +
                ', unchanged ' + unchanged + ', held for a human ' + humanHeld +
                ', no question carrying the code ' + noQuestion +
                (notes.isEmpty() ? '' : ' | ' + String.join(notes, ' | '));
        }
    }

    /**
     * THE STAGE ENTRY, which journals a leg. A stage that leaves no receipt leg cannot be
     * measured, and an unmeasurable stage is one nobody can price or resume from.
     */
    public static Outcome run(Id opportunityId, String runKey) {
        if (String.isBlank(runKey)) {
            return run(opportunityId);
        }
        Long startedAt = System.currentTimeMillis();
        Outcome o = project(opportunityId, runKey);
        AAO_Receipt.record(
            runKey, AAO_Receipt.sourceForRun(runKey), AAO_Receipt.STAGE_ASSESSMENT,
            System.currentTimeMillis() - startedAt, o.created + o.updated + o.unchanged
        );
        return o;
    }

    /** The same work with no leg, for callers that are not the pass. */
    public static Outcome run(Id opportunityId) {
        return project(opportunityId, null);
    }

    private static Outcome project(Id opportunityId, String runKey) {
        Outcome o = new Outcome();
        if (opportunityId == null) {
            return o;
        }
        // MODULE-GATED PER THE LADDER (122nd, 134th). An org without the Assessment module has
        // no such screen to project onto, and writing rows it cannot render would be inventing
        // an audience.
        if (!AAO_Modules.present(AAO_Modules.ASSESSMENT, opportunityId)) {
            o.notes.add(AAO_Modules.absenceNote(AAO_Modules.ASSESSMENT));
            return o;
        }

        List<ALTF__Opportunity__c> wrappers = [
            SELECT Id FROM ALTF__Opportunity__c
            WHERE ALTF__Opportunity__c = :opportunityId
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];
        if (wrappers.isEmpty()) {
            o.notes.add(
                'No Altify Opportunity exists for this deal, so there is no assessment to ' +
                'answer. Nothing was written and nothing was created: the wrapper is its own ' +
                'decision, not a side effect of projecting.'
            );
            return o;
        }
        Id wrapperId = wrappers[0].Id;

        // THE SAME READING THE PANEL SHOWS, from the same method, deliberately. Two surfaces
        // disagreeing about what a call established is the worst defect available here.
        Map<String, AAO_ProcessPanel.Reading> readings =
            AAO_ProcessPanel.readingsFor(opportunityId);
        if (readings.isEmpty()) {
            o.notes.add('Nothing is established on this deal yet, so nothing is projected.');
            return o;
        }

        Map<String, Id> questionByCode = new Map<String, Id>();
        for (ALTF__Assessment_Question__c q : [
            SELECT Id, ALTF__AltifyId__c FROM ALTF__Assessment_Question__c
            WHERE ALTF__AltifyId__c IN :readings.keySet()
        ]) {
            questionByCode.put(q.ALTF__AltifyId__c, q.Id);
        }

        Map<Id, ALTF__Assessment_Answer__c> existing = new Map<Id, ALTF__Assessment_Answer__c>();
        for (ALTF__Assessment_Answer__c a : [
            SELECT Id, ALTF__Assessment_Question__c, ALTF__Answer__c, ALTF__Note__c,
                   ALTF__NoteEntered__c
            FROM ALTF__Assessment_Answer__c
            WHERE ALTF__Opportunity__c = :wrapperId
        ]) {
            existing.put(a.ALTF__Assessment_Question__c, a);
        }

        List<ALTF__Assessment_Answer__c> fresh = new List<ALTF__Assessment_Answer__c>();
        List<ALTF__Assessment_Answer__c> patch = new List<ALTF__Assessment_Answer__c>();

        for (String code : readings.keySet()) {
            AAO_ProcessPanel.Reading r = readings.get(code);
            String value = valueFor(r.interpretation);
            if (value == null) {
                continue;
            }
            Id questionId = questionByCode.get(code);
            if (questionId == null) {
                o.noQuestion++;
                o.notes.add('No assessment question carries the code ' + code + '.');
                continue;
            }
            String note = String.isBlank(r.citation) ? null : r.citation.abbreviate(NOTE_CHARS);
            ALTF__Assessment_Answer__c row = existing.get(questionId);
            if (row == null) {
                fresh.add(new ALTF__Assessment_Answer__c(
                    ALTF__Opportunity__c = wrapperId,
                    ALTF__Assessment_Question__c = questionId,
                    ALTF__Answer__c = value,
                    ALTF__Note__c = note,
                    ALTF__NoteEntered__c = note != null
                ));
                continue;
            }
            if (heldByHuman(row)) {
                o.humanHeld++;
                o.notes.add(
                    'Held for a human on ' + code + ': the note carries prose this writer did ' +
                    'not write, so neither it nor the answer beside it is touched.'
                );
                continue;
            }
            if (row.ALTF__Answer__c == value && row.ALTF__Note__c == note) {
                o.unchanged++;
                continue;
            }
            row.ALTF__Answer__c = value;
            row.ALTF__Note__c = note;
            row.ALTF__NoteEntered__c = note != null;
            patch.add(row);
        }

        if (!fresh.isEmpty()) {
            insert fresh;
            o.created = fresh.size();
            // THE VENDOR'S OWN NAME CONVENTION, read off their own rows rather than guessed:
            // the record's fifteen character Id, and an AltifyId of org plus record. A card
            // written without it renders wrong in their UI, which the criteria write already
            // documents, and the three assessment answers standing in this org since 6 August
            // carry exactly this shape.
            String orgId = String.valueOf(UserInfo.getOrganizationId());
            List<ALTF__Assessment_Answer__c> named = new List<ALTF__Assessment_Answer__c>();
            List<Id> created = new List<Id>();
            for (ALTF__Assessment_Answer__c a : fresh) {
                String id18 = String.valueOf(a.Id);
                named.add(new ALTF__Assessment_Answer__c(
                    Id = a.Id,
                    Name = id18.substring(0, 15),
                    ALTF__AltifyId__c = orgId + '-' + id18
                ));
                created.add(a.Id);
            }
            update named;
            // ENUMERATED SO IT CAN BE DISOWNED. A machine-created row we cannot enumerate is a
            // row we can never disown, and the purge already respects this record.
            AAO_CreatedRows.recordAll(
                created,
                WRITER + '@' + WRITER_VERSION,
                'assessment-answer',
                'Projected from an establishment on this deal, with the words that made it.',
                runKey == null ? null : AAO_Receipt.sourceForRun(runKey),
                runKey
            );
        }
        if (!patch.isEmpty()) {
            update patch;
            o.updated = patch.size();
        }
        return o;
    }

    /**
     * AFFIRMED is a Yes and DENIED is a No, and nothing else is anything.
     *
     * DENIED IS NOT FALSE, per the inversion law: a voiced no is a TRUE verdict whose reading is
     * a denial, and on this surface it is exactly the No the methodology wants to see. Any other
     * interpretation returns null and writes nothing at all.
     */
    @TestVisible
    private static String valueFor(String interpretation) {
        if (interpretation == 'AFFIRMED') {
            return YES;
        }
        if (interpretation == 'DENIED') {
            return NO;
        }
        return null;
    }

    /**
     * WHOSE WORDS ARE IN THE NOTE.
     *
     * Blank is nobody's and is ours to fill. A note carrying the shape this writer produces -
     * `Who: "the words"` - is ours or is indistinguishable from ours. Anything else is a human's
     * prose and the row is held whole.
     *
     * The rule is deliberately conservative in one direction: when in doubt this holds, because
     * the cost of wrongly holding is a row that stays blank and the cost of wrongly writing is
     * a human's sentence destroyed. Human edits beat the machine forever.
     */
    public static Boolean heldByHuman(ALTF__Assessment_Answer__c row) {
        String note = row.ALTF__Note__c;
        if (String.isBlank(note)) {
            return false;
        }
        return !(note.contains(': "') && note.endsWith('"'));
    }
}
