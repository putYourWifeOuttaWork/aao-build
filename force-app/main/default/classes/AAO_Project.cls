/**
 * The People projection writer.
 *
 * Turns standing Answers about a person into values, a note and citations on Altify's own
 * `ALTF__Contact_Map_Details__c` rows. This is the first thing in the build that writes to a
 * managed object, and it is allowed to: data rows on managed objects are the product's output
 * surface. Fields, metadata, triggers and logic on them remain forbidden.
 *
 * **Upsert is query-then-branch, ratified, and NOT platform upsert** — there is no external id
 * on Altify's object to upsert against. Read before write on the `(contact, opportunity)` pair:
 *
 * - **row exists** → populate only the dimensions establishment moved, leaving the rest alone.
 *   Honest under the native per-dimension `_Last_Modified` stamps, which the step 0 probe
 *   proved the package maintains by itself on API writes.
 * - **row absent** → create it, established dimensions populated, everything else null.
 * - **two rows for one pair** → raise a flag and write nothing. Never pick.
 *
 * **The two legs are not equally normal, and the difference is Matthew's correction to session
 * 57.** The empty skeletons this sandbox has came from contact-role sync, which is a customer
 * configuration that can be switched off. **Populate is normal only where that sync is on. The
 * create leg is mandatory product behaviour**, because a person who appears in evidence and
 * holds no contact role has no row and must still be mapped.
 *
 * Read the derivation tables in `docs/aao-charters.md`, not here: Support at §P7 and Political
 * Status at charters v2.1. This class implements them and is not their source.
 */
public with sharing class AAO_Project {
    public class ProjectException extends Exception {
    }

    /** Our writer's identity, stamped so a projected value is attributable. */
    public static final String WRITER = 'AAO_People_Projection';
    public static final String WRITER_VERSION = '1.0.0';

    // ------------------------------------------------------------------ the ontology

    // Family tokens as `AAO_PeopleContracts` mints them: `S2#<contact>`, `PO1#<contact>`,
    // `PS4#<contact>`. The writer reads the token half; the person comes off the answer's own
    // subject lookup, which the commit path already carries.
    private static final String SUP = AAO_PeopleContracts.T_SUPPORT;
    private static final String POL_SHARED = AAO_PeopleContracts.T_POL_SHARED;
    private static final String POL_OM = AAO_PeopleContracts.T_POL_OM;

    /**
     * Support, from the authored table. Q1 opens the reading and places nobody.
     *
     * Mentor needs Q2 and Q4 and Q5; Supporter needs Q2; Non-Supporter is any of 6, 11, 14;
     * Enemy is 7 or 16. Neutral is the state of not knowing and is never computed as a balance.
     */
    private static final Set<String> SUP_MENTOR = new Set<String>{ '2', '4', '5' };
    private static final Set<String> SUP_NEGATIVE = new Set<String>{ '6', '11', '14' };
    private static final Set<String> SUP_ENEMY = new Set<String>{ '7', '16' };

    /**
     * Political Status, the ceiling model. Placement is the highest value the standing
     * establishments support; a lesser property never downgrades.
     *
     * **TRUE-as-strong, FALSE-as-weak is RATIFIED**, with one guard that has to hold.
     *
     * **A FALSE places somebody on the weak side only where words affirmatively support the
     * weak side** — *he executes what others approve* — and **never as the absence of
     * strong-side evidence.** Absence is `UNVERIFIED`, and UNVERIFIED places nobody, which is
     * why this derivation consults the FALSE sets for the weak side and never infers a weak
     * side from a missing TRUE.
     *
     * That is coextension doing the work the runtime-closed enums were designed for: the blind
     * reader enforces the affirmative-weak-side reading as an ordinary coverage check, so a
     * FALSE with no words behind it cannot reach here as an establishment. The enums become a
     * later refinement rather than a blocker.
     */
    private static final Set<String> POL_STRONG_OM = new Set<String>{ '1', '2' }; // define, approve
    private static final Set<String> POL_STRONG_SHARED = new Set<String>{ '4' }; // controls outcomes
    private static final Set<String> POL_WEAK_SHARED = new Set<String>{ '3', '6' }; // advice, delivery
    private static final String POL_BROKER = '7'; // information brokering, shared family

    // ===================================================================== the outcome

    public class PersonResult {
        @AuraEnabled
        public Id contactId;
        @AuraEnabled
        public String personName;
        @AuraEnabled
        public String support;
        @AuraEnabled
        public String political;
        @AuraEnabled
        public String note;
        /** created | populated | blocked | unchanged */
        @AuraEnabled
        public String action;
        @AuraEnabled
        public Id mapRowId;
        @AuraEnabled
        public List<String> dimensionsWritten = new List<String>();
        @AuraEnabled
        public List<String> heldBack = new List<String>();
        @AuraEnabled
        public String reason;

        public override String toString() {
            return personName +
                ': ' + action +
                ' support=' + support +
                ' political=' + political +
                (dimensionsWritten.isEmpty() ? '' : ' wrote' + dimensionsWritten) +
                (heldBack.isEmpty() ? '' : ' held' + heldBack) +
                (reason == null ? '' : ' :: ' + reason);
        }
    }

    public class Outcome {
        public Id opportunityId;
        public List<PersonResult> people = new List<PersonResult>();
        public Integer created = 0;
        public Integer populated = 0;
        public Integer blocked = 0;
        public Integer unchanged = 0;

        public override String toString() {
            String s = 'projection: ' + created + ' created, ' + populated + ' populated, ' +
                blocked + ' blocked, ' + unchanged + ' unchanged';
            for (PersonResult p : people) {
                s += '\n  ' + p;
            }
            return s;
        }
    }

    // ======================================================================== the run

    /**
     * Project every person with standing People answers on this deal.
     *
     * Deliberately not bulk-DML'd across people: each person is a read-then-branch decision and
     * one person's blocked pair must not stop another person's write. The volumes here are a
     * buying group, not a data load.
     */
    public static Outcome run(Id opportunityId) {
        if (opportunityId == null) {
            throw new ProjectException('Cannot project with no opportunity.');
        }
        Outcome o = new Outcome();
        o.opportunityId = opportunityId;

        Map<Id, List<AAO_Answer__c>> byPerson = standingByPerson(opportunityId);
        if (byPerson.isEmpty()) {
            return o;
        }

        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId].AccountId;

        for (Id contactId : byPerson.keySet()) {
            PersonResult r = project(opportunityId, accountId, contactId, byPerson.get(contactId));
            o.people.add(r);
            if (r.action == 'created') {
                o.created++;
            } else if (r.action == 'populated') {
                o.populated++;
            } else if (r.action == 'blocked') {
                o.blocked++;
            } else {
                o.unchanged++;
            }
        }
        return o;
    }

    /**
     * Standing answers about people on this deal, newest establishment last so the note and
     * the recency arbitration both read the same order.
     */
    private static Map<Id, List<AAO_Answer__c>> standingByPerson(Id opportunityId) {
        Map<Id, List<AAO_Answer__c>> out = new Map<Id, List<AAO_Answer__c>>();
        for (AAO_Answer__c a : [
            SELECT
                Id,
                AAO_Subject_Contact__c,
                AAO_Subject_Contact__r.Name,
                AAO_Verdict__c,
                AAO_Evidence_Occurred__c,
                AAO_Spans__c,
                AAO_Publication_State__c,
                AAO_Projected_Modstamp__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Answer__c
            WHERE
                AAO_Opportunity__c = :opportunityId
                AND AAO_Subject_Type__c = 'Contact'
                AND AAO_Subject_Contact__c != NULL
                // Held is live for nothing. A held answer never reaches a customer record.
                AND AAO_Publication_State__c = 'Live'
            ORDER BY AAO_Evidence_Occurred__c ASC NULLS FIRST, Id ASC
        ]) {
            if (!out.containsKey(a.AAO_Subject_Contact__c)) {
                out.put(a.AAO_Subject_Contact__c, new List<AAO_Answer__c>());
            }
            out.get(a.AAO_Subject_Contact__c).add(a);
        }
        return out;
    }

    // ------------------------------------------------------------------ one person

    private static PersonResult project(
        Id opportunityId,
        Id accountId,
        Id contactId,
        List<AAO_Answer__c> answers
    ) {
        PersonResult r = new PersonResult();
        r.contactId = contactId;
        r.personName = answers[0].AAO_Subject_Contact__r == null
            ? String.valueOf(contactId)
            : answers[0].AAO_Subject_Contact__r.Name;

        Derivation d = derive(answers);
        r.support = d.support;
        r.political = d.political;
        r.note = d.note;

        if (d.support == null && d.political == null) {
            r.action = 'unchanged';
            r.reason = 'Nothing established for this person on either dimension.';
            return r;
        }

        // ---- read before write, on the pair
        List<ALTF__Contact_Map_Details__c> rows = [
            SELECT
                Id,
                ALTF__Status__c,
                ALTF__Political__c,
                ALTF__Note__c,
                ALTF__Status_Last_Modified__c,
                ALTF__Political_Last_Modified__c
            FROM ALTF__Contact_Map_Details__c
            WHERE ALTF__Contact__c = :contactId AND ALTF__Opportunity__c = :opportunityId
            ORDER BY CreatedDate ASC
        ];

        if (rows.size() > 1) {
            // Never pick. Picking one silently is how a projection starts overwriting a row
            // nobody is looking at, and the duplicate is a real condition somebody has to see.
            r.action = 'blocked';
            r.mapRowId = rows[0].Id;
            r.reason =
                rows.size() + ' map rows exist for this person on this deal. The writer ' +
                'refuses to choose between them; nothing was written.';
            raiseDuplicateFlag(opportunityId, accountId, contactId, rows.size());
            return r;
        }

        if (rows.isEmpty()) {
            // THE CREATE LEG. Mandatory product behaviour: a person in the evidence with no
            // contact role has no skeleton, and contact-role sync is a customer setting that
            // can be off.
            ALTF__Contact_Map_Details__c fresh = new ALTF__Contact_Map_Details__c(
                ALTF__Account__c = accountId,
                ALTF__Opportunity__c = opportunityId,
                ALTF__Contact__c = contactId
            );
            if (d.support != null) {
                fresh.ALTF__Status__c = d.support;
                r.dimensionsWritten.add('Support');
            }
            if (d.political != null) {
                fresh.ALTF__Political__c = d.political;
                r.dimensionsWritten.add('Political');
            }
            fresh.ALTF__Note__c = d.note;
            insert fresh;
            r.mapRowId = fresh.Id;
            r.action = 'created';
            stampProjected(answers, d);
            // Everything else stays null on purpose: we establish what evidence establishes
            // and we do not fill a row out to look complete.
            return r;
        }

        // ---- THE POPULATE LEG, dimension by dimension
        ALTF__Contact_Map_Details__c row = rows[0];
        r.mapRowId = row.Id;
        ALTF__Contact_Map_Details__c patch = new ALTF__Contact_Map_Details__c(Id = row.Id);
        Boolean wrote = false;

        // Whether the row ALREADY reads what we derive. It matters for the watermark: a
        // re-projection that changes nothing has still asserted this value, and if only a
        // changed write stamped, the 3 August rows would stay unprotected forever and the
        // no-watermark alarm could never reach zero. Stamping here cannot weaken the human
        // guard: a hand edit changes the value, so it lands in the heldBack branch instead.
        Boolean matched = false;
        if (d.support != null && row.ALTF__Status__c == d.support) {
            matched = true;
        }
        if (d.political != null && row.ALTF__Political__c == d.political) {
            matched = true;
        }

        if (d.support != null) {
            if (humanEdited(row.ALTF__Status_Last_Modified__c, lastProjected(answers))) {
                r.heldBack.add('Support');
            } else if (row.ALTF__Status__c != d.support) {
                patch.ALTF__Status__c = d.support;
                r.dimensionsWritten.add('Support');
                wrote = true;
            }
        }
        if (d.political != null) {
            if (humanEdited(row.ALTF__Political_Last_Modified__c, lastProjected(answers))) {
                r.heldBack.add('Political');
            } else if (row.ALTF__Political__c != d.political) {
                patch.ALTF__Political__c = d.political;
                r.dimensionsWritten.add('Political');
                wrote = true;
            }
        }
        if (wrote) {
            // Option C: the note explains the values currently showing, and is overwritten
            // freely. Overwriting it never touches evidence, because the receipts live on our
            // Answer rows and the note was always a projection of them.
            patch.ALTF__Note__c = d.note;
            update patch;
        }
        if (wrote || matched) {
            stampProjected(answers, d);
        }

        r.action = wrote ? 'populated' : 'unchanged';
        if (!wrote && r.heldBack.isEmpty()) {
            r.reason = 'The map already reads what the evidence establishes.';
        } else if (!wrote) {
            r.reason = 'Every established dimension is human-owned on this row.';
        }
        return r;
    }

    /**
     * A human edit beats the machine forever. If the native per-dimension stamp is newer than
     * our own last write to this person, somebody moved it by hand after we did, and their
     * value stands.
     *
     * A row we have never written carries a stamp from whatever created it, so first contact
     * is deliberately treated as ours to write: `ourLastWrite == null` means no prior claim.
     */
    private static Boolean humanEdited(Datetime nativeStamp, Datetime ourLastWrite) {
        if (nativeStamp == null || ourLastWrite == null) {
            return false;
        }
        return nativeStamp > ourLastWrite;
    }

    /**
     * THE WATERMARK, WRITTEN BY THE WRITER. Session 75, and it was simply missing.
     *
     * `lastProjected` below READ `AAO_Projected_Modstamp__c` and nothing ever wrote it, so it
     * always returned null, so `humanEdited` always returned false, so **"a human edit beats
     * the machine forever" never fired**: its own comment carves out first contact as ours to
     * write, and with the field never written every contact was first contact. A second pass
     * would have silently overwritten a seller's hand edit. The same omission is why command
     * centre section 6 read `off` while a map row was populated.
     *
     * Ruled 4 August, and it generalizes past this row: **a watermark is written by the writer
     * or it does not exist.** No watermark is ever inferred, reconstructed, or backfilled from
     * a native stamp, however sound the chain looks — the 3 August run's chain was provably
     * deterministic and the backfill was still refused, because the precedent costs more than
     * the row. Replay over claims re-projects for real, so refusing costs nothing.
     *
     * Stamped only where something was actually written, and only on the answers that carried
     * the dimension that moved: an answer whose dimension was held back for a human edit has
     * not been projected and must not claim it has.
     */
    private static void stampProjected(List<AAO_Answer__c> answers, Derivation d) {
        Datetime now = Datetime.now();
        List<AAO_Answer__c> touched = new List<AAO_Answer__c>();
        for (AAO_Answer__c a : answers) {
            String value = projectedValueFor(a, d);
            if (value == null) {
                continue;
            }
            touched.add(new AAO_Answer__c(
                Id = a.Id,
                AAO_Projected_Value__c = value,
                AAO_Projected_Modstamp__c = now
            ));
        }
        if (!touched.isEmpty()) {
            update touched;
        }
    }

    /** The value this answer's own dimension contributed, or null if it contributed none. */
    private static String projectedValueFor(AAO_Answer__c a, Derivation d) {
        String code = a.AAO_Evidence_Contract__r == null
            ? null
            : a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
        String token = String.isBlank(code) ? null : AAO_PeopleContracts.tokenOf(code);
        String family = token == null ? null : familyOf(token);
        if (family == null) {
            return null;
        }
        if (family == SUP) {
            return d.support;
        }
        if (family == POL_SHARED || family == POL_OM) {
            return d.political;
        }
        return null;
    }

    private static Datetime lastProjected(List<AAO_Answer__c> answers) {
        Datetime latest;
        for (AAO_Answer__c a : answers) {
            if (a.AAO_Projected_Modstamp__c == null) {
                continue;
            }
            if (latest == null || a.AAO_Projected_Modstamp__c > latest) {
                latest = a.AAO_Projected_Modstamp__c;
            }
        }
        return latest;
    }

    // =================================================================== the derivation

    public class Derivation {
        public String support;
        public String political;
        public String note;
        /** Support only: the side that lost the recency arbitration, for the contention flag. */
        public String displacedSide;
        public Datetime supportAsOf;
        public Datetime politicalAsOf;
    }

    /** Exposed for the harness assertions: derive without writing anything. */
    public static Derivation derive(List<AAO_Answer__c> answers) {
        Derivation d = new Derivation();

        // Standing TRUE and standing FALSE, by question number within family.
        Set<String> supTrue = new Set<String>();
        Set<String> polTrueShared = new Set<String>();
        Set<String> polTrueOm = new Set<String>();
        Set<String> polFalseShared = new Set<String>();
        Set<String> polFalseOm = new Set<String>();
        Datetime newestPositive;
        Datetime newestNegative;
        List<String> supportCitations = new List<String>();
        List<String> politicalCitations = new List<String>();

        for (AAO_Answer__c a : answers) {
            String code = a.AAO_Evidence_Contract__r == null
                ? null
                : a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
            if (String.isBlank(code)) {
                continue;
            }
            String token = AAO_PeopleContracts.tokenOf(code);
            if (token == null) {
                continue;
            }
            String family = familyOf(token);
            String num = numberOf(token);
            if (family == null || num == null) {
                continue;
            }
            Boolean isTrue = a.AAO_Verdict__c == 'TRUE';
            Boolean isFalse = a.AAO_Verdict__c == 'FALSE';
            if (!isTrue && !isFalse) {
                continue; // UNVERIFIED establishes nothing and places nobody.
            }

            if (family == SUP) {
                if (isTrue) {
                    supTrue.add(num);
                    if (SUP_NEGATIVE.contains(num) || SUP_ENEMY.contains(num)) {
                        newestNegative = later(newestNegative, a.AAO_Evidence_Occurred__c);
                    } else {
                        newestPositive = later(newestPositive, a.AAO_Evidence_Occurred__c);
                    }
                    supportCitations.add(citation(a));
                }
            } else if (family == POL_SHARED) {
                if (isTrue) {
                    polTrueShared.add(num);
                    politicalCitations.add(citation(a));
                } else {
                    polFalseShared.add(num);
                }
            } else if (family == POL_OM) {
                if (isTrue) {
                    polTrueOm.add(num);
                    politicalCitations.add(citation(a));
                } else {
                    polFalseOm.add(num);
                }
            }
        }

        d.support = supportRung(supTrue, newestPositive, newestNegative, d);
        d.political = politicalCeiling(polTrueOm, polTrueShared, polFalseOm, polFalseShared);
        d.note = composeNote(d.support, d.political, supportCitations, politicalCitations);
        return d;
    }

    /**
     * Support. Recency owns the rung when both sides stand; nothing averages, and Neutral is
     * never the resolution of a conflict.
     */
    private static String supportRung(
        Set<String> t,
        Datetime newestPositive,
        Datetime newestNegative,
        Derivation d
    ) {
        Boolean enemy = !intersects(t, SUP_ENEMY).isEmpty();
        Boolean negative = !intersects(t, SUP_NEGATIVE).isEmpty();
        Boolean mentor = t.containsAll(SUP_MENTOR);
        Boolean supporter = t.contains('2');

        Boolean darkSide = enemy || negative;
        Boolean lightSide = mentor || supporter;

        if (!darkSide && !lightSide) {
            return null; // Nothing established in either direction. Not a computed Neutral.
        }
        if (darkSide && lightSide) {
            // Both sides stand. The most recent establishment on the evidence-occurred clock
            // governs, and the loser becomes a contention flag of the opposite polarity.
            Boolean positiveWins =
                newestPositive != null &&
                (newestNegative == null || newestPositive > newestNegative);
            d.displacedSide = positiveWins ? 'negative' : 'positive';
            return positiveWins
                ? (mentor ? 'Mentor' : 'Supporter')
                : (enemy ? 'Enemy' : 'Non-Supporter');
        }
        if (darkSide) {
            return enemy ? 'Enemy' : 'Non-Supporter';
        }
        return mentor ? 'Mentor' : 'Supporter';
    }

    /**
     * Political Status, the ceiling. The highest placement the standing establishments
     * support; one establishment suffices at every level; a lesser property never downgrades.
     *
     * Exit happens only inside a two-sided question, which is why the weak sides read from the
     * FALSE sets rather than from absence. Q9 places nobody and is not consulted.
     */
    private static String politicalCeiling(
        Set<String> trueOm,
        Set<String> trueShared,
        Set<String> falseOm,
        Set<String> falseShared
    ) {
        Boolean strong =
            !intersects(trueOm, POL_STRONG_OM).isEmpty() ||
            !intersects(trueShared, POL_STRONG_SHARED).isEmpty();
        if (strong) {
            return 'Inner Circle';
        }
        // Weak side of a two-sided question is the FALSE verdict on that question; the plain
        // one-sided questions (advice, delivery) count on their TRUE.
        Boolean weak =
            falseOm.contains('2') ||
            falseShared.contains('4') ||
            !intersects(trueShared, POL_WEAK_SHARED).isEmpty();
        if (weak) {
            return 'Political Structure';
        }
        if (trueShared.contains(POL_BROKER)) {
            return 'Outside Political Structure';
        }
        // Unset. Nobody is placed outside the structure by absence of evidence, so this
        // returns null and the field is left alone rather than written 'Unknown'.
        return null;
    }

    // ------------------------------------------------------------------- the note

    /**
     * Option C. The most recent establishment per dimension, in plain words, explaining the
     * value currently showing. Older receipts live on our Answer rows, one read away.
     *
     * Never a record id on a human surface, and it degrades to naming the value alone rather
     * than truncating a quote, because a clipped quote is at the edge of the paraphrase law.
     */
    private static final Integer NOTE_MAX = 1024;

    private static String composeNote(
        String support,
        String political,
        List<String> supportCitations,
        List<String> politicalCitations
    ) {
        List<String> parts = new List<String>();
        if (support != null) {
            parts.add(
                'Support: ' + support +
                (supportCitations.isEmpty()
                    ? ''
                    : ' — ' + supportCitations[supportCitations.size() - 1])
            );
        }
        if (political != null) {
            parts.add(
                'Political: ' + political +
                (politicalCitations.isEmpty()
                    ? ''
                    : ' — ' + politicalCitations[politicalCitations.size() - 1])
            );
        }
        if (parts.isEmpty()) {
            return null;
        }
        String note = String.join(parts, '\n');
        if (note.length() <= NOTE_MAX) {
            return note;
        }
        // Degrade to Option B behaviour rather than clip a quote.
        List<String> plain = new List<String>();
        if (support != null) {
            plain.add('Support: ' + support);
        }
        if (political != null) {
            plain.add('Political: ' + political);
        }
        plain.add('Full citations on the AAO answer rows for this person.');
        return String.join(plain, '\n').abbreviate(NOTE_MAX);
    }

    /** Plain date and speaker. No record id ever reaches a human surface. */
    private static String citation(AAO_Answer__c a) {
        // D2, session 74: this read spans[0] unconditionally, so the person credited on a
        // customer-visible note could be taken from a span the blind reader had refused.
        // Harmless where every span shares a speaker; not guaranteed, and not something to
        // leave resting on that. Filter first, then take the first survivor.
        List<AAO_Model.Span> spans = AAO_Model.upheld(
            AAO_Model.parseSpans(a.AAO_Spans__c).spans
        );
        String who = spans.isEmpty() || String.isBlank(spans[0].speaker)
            ? 'on the call'
            : spans[0].speaker;
        String occurredOn = a.AAO_Evidence_Occurred__c == null
            ? ''
            : ', ' + a.AAO_Evidence_Occurred__c.formatGmt('d MMMM yyyy');
        return who + occurredOn;
    }

    // -------------------------------------------------------------------- internals

    private static void raiseDuplicateFlag(
        Id opportunityId,
        Id accountId,
        Id contactId,
        Integer howMany
    ) {
        insert new AAO_Flag__c(
            AAO_Opportunity__c = opportunityId,
            AAO_Account__c = accountId,
            AAO_Subject_Contact__c = contactId,
            AAO_Type__c = 'Cardinality',
            AAO_Cause__c = 'Cardinality_Exceeded',
            AAO_State__c = 'Standing',
            AAO_Raised_At__c = System.now(),
            AAO_Proposed_Count__c = howMany,
            AAO_Ceiling__c = 1,
            AAO_Synthetic__c = AAO_Synthetic.MARK
        );
    }

    /** `S2` -> `S`, `PO1` -> `PO`, `PS4` -> `PS`. The letters are the family. */
    private static String familyOf(String token) {
        String letters = '';
        for (Integer i = 0; i < token.length(); i++) {
            String ch = token.substring(i, i + 1);
            if (ch.isNumeric()) {
                break;
            }
            letters += ch;
        }
        return String.isBlank(letters) ? null : letters;
    }

    /** `S2` -> `2`. The digits are the question number within the family. */
    private static String numberOf(String token) {
        String digits = '';
        for (Integer i = 0; i < token.length(); i++) {
            String ch = token.substring(i, i + 1);
            if (ch.isNumeric()) {
                digits += ch;
            }
        }
        return String.isBlank(digits) ? null : digits;
    }

    private static Set<String> intersects(Set<String> a, Set<String> b) {
        Set<String> out = new Set<String>(a);
        out.retainAll(b);
        return out;
    }

    private static Datetime later(Datetime a, Datetime b) {
        if (a == null) {
            return b;
        }
        if (b == null) {
            return a;
        }
        return a > b ? a : b;
    }
}
