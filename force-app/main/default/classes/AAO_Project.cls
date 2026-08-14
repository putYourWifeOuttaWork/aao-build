/**
 * The People projection writer.
 *
 * Turns standing Answers about a person into values, a note and citations on Altify's own
 * `ALTF__Contact_Map_Details__c` rows. This is the first thing in the build that writes to a
 * managed object, and it is allowed to: data rows on managed objects are the product's output
 * surface. Fields, metadata, triggers and logic on them remain forbidden.
 *
 * **Upsert is query-then-branch, ratified, and NOT platform upsert** - there is no external id
 * on Altify's object to upsert against. Read before write on the `(contact, opportunity)` pair:
 *
 * - **row exists** -> populate only the dimensions establishment moved, leaving the rest alone.
 *   Honest under the native per-dimension `_Last_Modified` stamps, which the step 0 probe
 *   proved the package maintains by itself on API writes.
 * - **row absent** -> create it, established dimensions populated, everything else null.
 * - **two rows for one pair** -> raise a flag and write nothing. Never pick.
 *
 * **The two legs are not equally normal, and the difference is Matthew's correction to session
 * 57.** The empty skeletons this sandbox has came from contact-role sync, which is a customer
 * configuration that can be switched off. **Populate is normal only where that sync is on. The
 * create leg is mandatory product behaviour**, because a person who appears in evidence and
 * holds no contact role has no row and must still be mapped.
 *
 * ============================================================================
 * RE-AIMED AT `people-p8-v1`, Architecture v3.9. **This class was reported built and proven
 * and was neither.** Its eighteen passing tests proved it against `people-om-v1`-shaped codes
 * (`S2#003WD...`); against the §P8 contract set `tokenOf` split on a `#` the seventeen do not
 * carry, every answer was skipped, `derive()` returned empty, and projection wrote nothing
 * while reporting success. A suite can be green and irrelevant at the same time.
 *
 * What changed with the re-aim:
 * - **Code parsing is a lookup, not string surgery** - `AAO_P8Codes`, one literal map, held
 *   against the declared set by a test rather than by hope.
 * - **The Political ceiling reads TRUE only.** The weak sides are their own contracts now, so
 *   no verdict is read for its falseness anywhere.
 * - **Support comes off the counter**, not off a nine-question conjunction tree. The quiz was
 *   retired from extraction at §P8.4 and the derivation that consumed it goes with it.
 * - **Buyer Role and criteria enter** as dimensions the stage arithmetic counts.
 *
 * Read the derivation tables in `docs/aao-charters.md`, not here: sentiment and the counter at
 * §P8.4, Political Status at charters v2.1. This class implements them and is not their source.
 */
public with sharing class AAO_Project {
    public class ProjectException extends Exception {
    }

    /** Our writer's identity, stamped so a projected value is attributable. */
    public static final String WRITER = 'AAO_People_Projection';

    /**
     * 2.0.0 at the re-aim. The version moves because the writer's INPUT rubric moved: a value
     * written by 1.0.0 was derived from `people-om-v1` codes and a value written by this one
     * was not, and a watermark that could not tell them apart would compare two different
     * derivations as though they were one.
     */
    public static final String WRITER_VERSION = '2.0.0';

    // ===================================================================== the outcome

    public class PersonResult {
        /**
         * True when the ROSTER placed this person rather than the evidence: they were on the
         * call and carry derived Coverage, and the machine established nothing else about them.
         */
        @AuraEnabled
        public Boolean placedFromRoster = false;
        /** Answers and claims whose subject-contact link this projection filled in. */
        @AuraEnabled
        public Integer linksBackfilled = 0;
        @AuraEnabled
        public Id contactId;
        @AuraEnabled
        public Id participantId;
        @AuraEnabled
        public Id shadowPersonId;
        /** resolved | created | shadowed, from the identity ladder. */
        @AuraEnabled
        public String identity;
        @AuraEnabled
        public String personName;
        @AuraEnabled
        public String support;
        @AuraEnabled
        public Integer supportCounter;
        @AuraEnabled
        public String political;
        @AuraEnabled
        public String buyerRole;
        @AuraEnabled
        public Integer criteriaNamed;
        @AuraEnabled
        public String note;
        /** created | populated | blocked | unchanged | unresolved */
        @AuraEnabled
        public String action;
        @AuraEnabled
        public Id mapRowId;
        @AuraEnabled
        public List<String> dimensionsWritten = new List<String>();
        @AuraEnabled
        public List<String> heldBack = new List<String>();
        /** Dimensions cleared because the evidence no longer supports what we wrote. */
        @AuraEnabled
        public List<String> retracted = new List<String>();
        @AuraEnabled
        public String reason;

        public override String toString() {
            return personName +
                ': ' + action +
                ' support=' + support +
                (supportCounter == null ? '' : '(' + supportCounter + ')') +
                ' political=' + political +
                ' role=' + buyerRole +
                (criteriaNamed == null || criteriaNamed == 0
                    ? ''
                    : ' criteria=' + criteriaNamed) +
                (dimensionsWritten.isEmpty() ? '' : ' wrote' + dimensionsWritten) +
                (heldBack.isEmpty() ? '' : ' held' + heldBack) +
                (retracted.isEmpty() ? '' : ' RETRACTED' + retracted) +
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
        /** People whose identity resolves to no Contact, so no map row can be reached. */
        public Integer unresolved = 0;
        /**
         * People placed by the ROSTER rather than by the evidence (forty-fourth stamp item 1).
         * Reported separately because it is a different kind of claim: it asserts that somebody
         * was on the call, never that the machine established anything about them.
         */
        public Integer placedFromRoster = 0;
        /** Contacts the create leg made for people the org had none for. */
        public Integer contactsCreated = 0;
        /** Criteria written into the vendor's own object, with their holder junctions. */
        public Integer criteriaProjected = 0;
        public Integer criteriaHeldPartial = 0;
        public Integer criteriaAlreadyProjected = 0;
        public Integer criteriaHolderless = 0;
        /** Values cleared from the map because the evidence no longer supports them. */
        public Integer valuesRetracted = 0;
        /** People held at shadow stage, which is a real and often permanent state. */
        public Integer shadowed = 0;

        /**
         * THE STAGE ARITHMETIC EXTENDED THROUGH PROJECTION, the fourth stage. Architecture
         * v3.9, from a defect: `derive()` was proven against the retired EBV path and, run
         * against the §P8 contract set, skipped every answer and returned empty - so
         * **projection wrote nothing and reported success**, and the map would have come back
         * blank from a run that looked like it worked.
         *
         * Answers in and dimension-writes out, counted and reported. **An empty derivation is
         * now expressible only as a reported zero.** The one-for-one-for-one law already
         * counts between the pair rows; this is the same law reaching the last stage, and the
         * reason it belongs here rather than in a test is that a test asserts what someone
         * thought to assert, while a printed pair of counters is read by whoever reads the run.
         */
        public Integer answersRead = 0;
        public Map<String, Integer> writesByDimension = freshDimensionCounts();

        /**
         * Answers whose proposition code this writer has no placement for. **Separate from a
         * zero on purpose.** A derivation that produced nothing because nothing was
         * establishable is a recall result; a derivation that produced nothing because the
         * writer did not recognise a single code is the v3.9 defect, and the two are
         * indistinguishable from the totals alone.
         */
        public Integer answersUnplaced = 0;
        public Set<String> unplacedCodes = new Set<String>();

        public Integer dimensionWrites() {
            Integer n = 0;
            for (Integer v : writesByDimension.values()) {
                n += v;
            }
            return n;
        }

        /** True where answers were read and not one of them produced a value. */
        public Boolean derivedNothing() {
            return answersRead > 0 && dimensionWrites() == 0;
        }

        public override String toString() {
            String s = 'projection: ' + created + ' created, ' + populated + ' populated, ' +
                blocked + ' blocked, ' + unchanged + ' unchanged, ' +
                unresolved + ' unresolved' +
                '\n  contacts created         ' + contactsCreated + ' (unit: contacts)' +
                '\n  criteria projected       ' + criteriaProjected + ' (unit: criteria)' +
                '\n    held, partial          ' + criteriaHeldPartial + ' (unit: criteria)' +
                '\n    already projected      ' + criteriaAlreadyProjected + ' (unit: criteria)' +
                '\n    no holder link         ' + criteriaHolderless + ' (unit: criteria)' +
                '\n  people held at shadow    ' + shadowed + ' (unit: people)' +
                '\n  values retracted         ' + valuesRetracted + ' (unit: values)' +
                '\n  answers read             ' + answersRead + ' (unit: answers)' +
                '\n  answers unplaced         ' + answersUnplaced + ' (unit: answers)' +
                '\n  dimension values written ' + dimensionWrites() + ' (unit: values)';
            for (String d : AAO_P8Codes.dimensions()) {
                s += '\n    ' + d.rightPad(22) + ' ' + writesByDimension.get(d) +
                    ' (unit: values)';
            }
            if (answersUnplaced > 0) {
                List<String> codes = new List<String>(unplacedCodes);
                codes.sort();
                s += '\n  UNPLACED CODES: ' + String.join(codes, ', ') +
                    '. This writer has no placement for them, so their answers moved ' +
                    'nothing. Either the contract set and the placement map have drifted ' +
                    'apart, or these answers belong to a superseded rubric.';
            }
            if (derivedNothing()) {
                s += '\n  DERIVED NOTHING. ' + answersRead + ' answers produced no value on ' +
                    'any dimension. This is a writer defect, not a recall result: the map ' +
                    'comes back blank and the run would otherwise have reported success.';
            }
            for (PersonResult p : people) {
                s += '\n  ' + p;
            }
            return s;
        }
    }

    private static Map<String, Integer> freshDimensionCounts() {
        Map<String, Integer> m = new Map<String, Integer>();
        for (String d : AAO_P8Codes.dimensions()) {
            m.put(d, 0);
        }
        return m;
    }

    // ======================================================================== the run

    /**
     * Project every person with standing People answers on this deal.
     *
     * Deliberately not bulk-DML'd across people: each person is a read-then-branch decision and
     * one person's blocked pair must not stop another person's write. The volumes here are a
     * buying group, not a data load.
     */
    /**
     * Projection with its run named, so its leg reaches the receipt.
     *
     * An overload rather than a changed signature: projection is keyed on the DEAL, because it
     * writes the deal's current state from the standing ledger rather than from one run's output.
     * The run key is therefore telemetry here and nothing else — it says which pass paid for this
     * projection's time, and it changes nothing about what gets written.
     */
    public static Outcome run(Id opportunityId, String runKey) {
        Long startedAt = System.currentTimeMillis();
        Outcome o = run(opportunityId);
        AAO_Receipt.record(
            runKey, AAO_Receipt.sourceForRun(runKey), AAO_Receipt.STAGE_PROJECT,
            System.currentTimeMillis() - startedAt, o.dimensionWrites()
        );
        return o;
    }

    public static Outcome run(Id opportunityId) {
        if (opportunityId == null) {
            throw new ProjectException('Cannot project with no opportunity.');
        }
        Outcome o = new Outcome();
        o.opportunityId = opportunityId;

        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId].AccountId;

        // COVERAGE IS COMPUTED, so it is read once for the deal rather than per person and
        // it consults no contract, no claim and no model.
        Map<Id, Integer> occasions = AAO_Coverage.occasionsByPerson(opportunityId);

        Map<String, List<AAO_Answer__c>> byPerson = standingByPerson(opportunityId);
        if (byPerson.isEmpty()) {
            // No person-subject answers is not the same as nothing to project: criteria are
            // subjected to the criterion, so a deal whose only harvest was criteria has an
            // empty roster here and a full one below. Returning early would have made the
            // criteria write unreachable on exactly the run that is all criteria.
            // NOT a return any more: the roster places people the evidence never mentioned,
            // so a run whose model output was empty still writes the deal's coverage skeleton.
            // Criteria are projected once, at the end, on every path.
        }

        List<AAO_Participant__c> coverageStamps = new List<AAO_Participant__c>();
        List<String> personKeys = new List<String>(byPerson.keySet());
        personKeys.sort();
        for (String personKey : personKeys) {
            List<AAO_Answer__c> answers = byPerson.get(personKey);
            o.answersRead += answers.size();

            Derivation d = derive(answers);
            // Coverage joins the derivation AFTER the answer walk, deliberately: it is not an
            // answer and must never be counted as one. `answersRead` stays honest, and a deal
            // whose only dimension is coverage still reports zero answers read.
            d.occasions = occasions.get(answers[0].AAO_Participant__c);
            d.coverage = AAO_Coverage.valueFor(d.occasions);
            o.answersUnplaced += d.unplaced;
            o.unplacedCodes.addAll(d.unplacedCodes);
            for (String dim : d.valuesDerived()) {
                o.writesByDimension.put(dim, o.writesByDimension.get(dim) + 1);
            }

            PersonResult r = project(opportunityId, accountId, answers, d);
            // A WATERMARK IS WRITTEN BY THE WRITER OR IT DOES NOT EXIST, and until now that
            // law had never reached coverage - the one dimension with no Answer to carry it.
            // a23 wrote Wendy Higley's coverage and recorded nothing, so the value became
            // unprovable as ours the moment it landed. Recorded here, beside the write.
            // STAMPED ON ASSERTION, NOT ONLY ON CHANGE - the same rule the answer watermark
            // already follows and for the same reason: a re-projection that changes nothing has
            // still asserted this value, and if only a changed write stamped, a row whose map
            // value already matches would never acquire a watermark and would stay unprovable
            // as ours forever. Held back is excluded, because a held value is the human's and
            // stamping it would be us claiming their edit.
            if (d.coverage != null && !r.heldBack.contains('Coverage') &&
                answers[0].AAO_Participant__c != null) {
                coverageStamps.add(new AAO_Participant__c(
                    Id = answers[0].AAO_Participant__c,
                    AAO_Coverage_Projected_Value__c = d.coverage,
                    AAO_Coverage_Projected_Modstamp__c = System.now()
                ));
            }
            o.people.add(r);
            o.valuesRetracted += r.retracted.size();
            if (r.identity == 'created') {
                o.contactsCreated++;
            } else if (r.identity == 'shadowed') {
                o.shadowed++;
            }
            if (r.action == 'created') {
                o.created++;
            } else if (r.action == 'populated') {
                o.populated++;
            } else if (r.action == 'blocked') {
                o.blocked++;
            } else if (r.action == 'unresolved') {
                o.unresolved++;
            } else {
                o.unchanged++;
            }
        }

        // ---- THE ROSTER PLACEMENT LEG. Forty-fourth stamp, item 1, Matthew's ruling ------
        //
        // **PRESENCE ON THE MAP MUST NOT RIDE READ VARIANCE.** Kayla Stanley was on the call
        // and fell off the map in two of three identical probe runs, because a person earned a
        // row only by having CLAIMS, and claims come from the model. The roster does not: it is
        // deterministic data on the Source, and roster-to-Contact resolution is code. So every
        // resolved external participant is placed with its derived Coverage whether or not the
        // model established anything about them, and the evidence-driven loop above enriches
        // rows that already exist.
        //
        // It runs AFTER that loop rather than before, and the ordering is deliberate: the loop
        // may CREATE a Contact through the identity ladder, and a person resolved during the
        // run should be placed in the same run rather than waiting for the next one.
        //
        // `occasions` is the roster, already filtered: mention rows never count coverage and
        // Internal-true participants are excluded at the source (thirty-seventh stamp item 4),
        // so neither can be placed from here. A participant with no Contact is not placed,
        // because `ALTF__Contact_Map_Details__c.ALTF__Contact__c` is required and no Contact is
        // ever faked; the create leg stays evidence-driven, which is where the ruling leaves it.
        Set<Id> alreadyHandled = new Set<Id>();
        for (PersonResult pr : o.people) {
            if (pr.participantId != null) {
                alreadyHandled.add(pr.participantId);
            }
        }
        List<AAO_Participant__c> rosterRows = [
            SELECT Id, AAO_Contact__c, AAO_Display_Name__c, AAO_Email__c, AAO_Roster_Key__c,
                AAO_Source__c, AAO_Coverage_Projected_Value__c,
                AAO_Coverage_Projected_Modstamp__c
            FROM AAO_Participant__c
            WHERE Id IN :occasions.keySet() AND AAO_Contact__c != null
            ORDER BY AAO_Display_Name__c
        ];
        for (AAO_Participant__c person : rosterRows) {
            if (alreadyHandled.contains(person.Id)) {
                continue;
            }
            Derivation rd = new Derivation();
            rd.occasions = occasions.get(person.Id);
            rd.coverage = AAO_Coverage.valueFor(rd.occasions);
            if (rd.coverage == null) {
                // The silence law: zero occasions writes nothing, so a roster row nobody met
                // still places nobody.
                continue;
            }
            PersonResult rr = project(
                opportunityId, accountId, new List<AAO_Answer__c>(), rd, person
            );
            rr.placedFromRoster = true;
            o.placedFromRoster++;
            o.writesByDimension.put(
                AAO_P8Codes.DIM_COVERAGE, o.writesByDimension.get(AAO_P8Codes.DIM_COVERAGE) + 1
            );
            if (!rr.heldBack.contains('Coverage')) {
                coverageStamps.add(new AAO_Participant__c(
                    Id = person.Id,
                    AAO_Coverage_Projected_Value__c = rd.coverage,
                    AAO_Coverage_Projected_Modstamp__c = System.now()
                ));
            }
            o.people.add(rr);
            if (rr.action == 'created') {
                o.created++;
            } else if (rr.action == 'populated') {
                o.populated++;
            } else if (rr.action == 'blocked') {
                o.blocked++;
            } else if (rr.action == 'unresolved') {
                o.unresolved++;
            } else {
                o.unchanged++;
            }
        }

        if (!coverageStamps.isEmpty()) {
            update coverageStamps;
        }
        projectCriteria(opportunityId, accountId, o);
        return o;
    }

    /**
     * THE CRITERIA WRITE. Addendum 20: it flows from criterion-subject answers.
     *
     * **Only whole criteria project**, under the standing partial law. A criterion whose
     * naming came back Partial stands as UNVERIFIED with its receipts on our own rows, is
     * visible to anyone reading them, and does not reach the customer's map - because a
     * partial accrues safely and PLACES NOBODY, and a vendor row is a placement. Whether
     * partials survive at all is Matthew's after the criteria measurement, so they are held
     * and counted rather than dropped.
     *
     * Three DML per pass and not per criterion, which is the ruled shape: insert the criteria,
     * update them to stamp `Name` with each record's own fifteen-character Id (the convention
     * on every existing row, and not a label), insert the holder junctions. Bulkified, the
     * count does not grow with volume.
     *
     * **The two conventions that are invisible from the schema and each silently break a
     * record**: `Name` holds the record's own Id, and `ALTF__Subject__c` holds the criterion
     * text and is what the interface displays. A criterion written without Subject renders
     * blank; written without the opportunity it never reaches the deal's map at all.
     * `ALTF__AltifyId__c` is stamped by something on their side and we do not write it.
     */
    private static void projectCriteria(Id opportunityId, Id accountId, Outcome o) {
        // Retired criteria never project: the collapsed placeholder rows are the first
        // occupants of that state, and shipping one would put the retired mistake on the
        // customer's map.
        Map<Id, AAO_Criterion__c> byId = new Map<Id, AAO_Criterion__c>([
            SELECT Id, AAO_Subject__c, AAO_Type__c, AAO_Required__c, AAO_Voiced_By__c,
                AAO_Voiced_By__r.AAO_Contact__c, AAO_Projected_Criterion_Id__c
            FROM AAO_Criterion__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Retired__c = false
        ]);
        if (byId.isEmpty()) {
            return;
        }

        // WHOLE ONLY, AND THIS GATE NOW READS COMPLETENESS DIRECTLY.
        //
        // **A HELD DECISION MUST NOT CHANGE AS A SIDE EFFECT OF AN UNRELATED RULING.** This
        // read the naming answer's VERDICT, which worked only because a partial used to write
        // UNVERIFIED. Matthew's uphold-governs ruling at the sixty-ninth stamp made an upheld
        // partial read TRUE — and this gate would then have let PARTIAL CRITERIA REACH THE
        // VENDOR OBJECT, silently reversing the standing partial law ("whole criteria only;
        // partials' fate is Matthew's after the measurement, held"). Neither the sixty-ninth
        // nor the seventieth stamp mentions criteria, so nothing ruled that reversal.
        //
        // The gate therefore keeps its meaning by reading the thing it always meant: element
        // COMPLETENESS, which the same ruling makes the proper home for exactly this. Both
        // conditions now stand explicitly — the verifier must have upheld it AND the elements
        // must be whole — so a refusal still never reaches a customer-visible row either.
        Map<Id, String> verdictByCriterion = new Map<Id, String>();
        Map<Id, String> completenessByCriterion = new Map<Id, String>();
        for (AAO_Answer__c a : [
            SELECT AAO_Criterion__c, AAO_Verdict__c, AAO_Element_Completeness__c
            FROM AAO_Answer__c
            WHERE AAO_Criterion__c IN :byId.keySet()
                AND AAO_Subject_Type__c = 'Decision_Criterion'
                AND AAO_Publication_State__c = 'Live'
                AND AAO_Evidence_Contract__r.AAO_Proposition_Code__c = :AAO_P8Codes.CRITERION_NAMING
        ]) {
            verdictByCriterion.put(a.AAO_Criterion__c, a.AAO_Verdict__c);
            completenessByCriterion.put(a.AAO_Criterion__c, a.AAO_Element_Completeness__c);
        }
        List<String> namingElements = new List<String>();
        for (AAO_Evidence_Contract__c ec : [
            SELECT AAO_Elements__c, AAO_Element_Count__c FROM AAO_Evidence_Contract__c
            WHERE AAO_Proposition_Code__c = :AAO_P8Codes.CRITERION_NAMING
                AND AAO_Contract_State__c != 'Superseded'
            LIMIT 1
        ]) {
            namingElements = AAO_ExtractCharter.elementIds(ec);
        }

        List<AAO_Criterion__c> toWrite = new List<AAO_Criterion__c>();
        for (AAO_Criterion__c c : byId.values()) {
            if (String.isNotBlank(c.AAO_Projected_Criterion_Id__c)) {
                // The watermark, and the only record that we already wrote this one: the
                // vendor object carries no external id to upsert against.
                o.criteriaAlreadyProjected++;
                continue;
            }
            Boolean upheld = verdictByCriterion.get(c.Id) == 'TRUE';
            Boolean whole = namingElements.isEmpty() ||
                AAO_Model.parseCoverage(completenessByCriterion.get(c.Id)).isFull(namingElements);
            if (!upheld || !whole) {
                o.criteriaHeldPartial++;
                continue;
            }
            toWrite.add(c);
        }
        if (toWrite.isEmpty()) {
            return;
        }

        List<ALTF__Decision_Criteria__c> rows = new List<ALTF__Decision_Criteria__c>();
        for (AAO_Criterion__c c : toWrite) {
            rows.add(new ALTF__Decision_Criteria__c(
                ALTF__Account__c = accountId,
                ALTF__Opportunity__c = opportunityId,
                ALTF__Subject__c = c.AAO_Subject__c,
                ALTF__Type__c = String.isBlank(c.AAO_Type__c) ? 'Informal' : c.AAO_Type__c,
                ALTF__Required__c = c.AAO_Required__c == true
            ));
        }
        insert rows;

        List<ALTF__Decision_Criteria__c> named = new List<ALTF__Decision_Criteria__c>();
        List<ALTF__Decision_Criteria_Contact__c> holders =
            new List<ALTF__Decision_Criteria_Contact__c>();
        Datetime now = Datetime.now();
        for (Integer i = 0; i < rows.size(); i++) {
            named.add(new ALTF__Decision_Criteria__c(
                Id = rows[i].Id,
                Name = String.valueOf(rows[i].Id).substring(0, 15)
            ));
            AAO_Criterion__c c = toWrite[i];
            c.AAO_Projected_Criterion_Id__c = String.valueOf(rows[i].Id);
            c.AAO_Projected_Modstamp__c = now;
            Id holder = c.AAO_Voiced_By__r == null ? null : c.AAO_Voiced_By__r.AAO_Contact__c;
            if (holder == null) {
                // Attribution is the one thing a recorded call hands us free, and this is the
                // case where it cannot land: the junction requires a Contact and this voicer
                // holds at shadow stage. The criterion still projects, because the criterion
                // is true whether or not we can name its holder in their schema.
                o.criteriaHolderless++;
            } else {
                holders.add(new ALTF__Decision_Criteria_Contact__c(
                    ALTF__Decision_Criteria__c = rows[i].Id,
                    ALTF__Contact__c = holder
                ));
            }
            o.criteriaProjected++;
        }
        update named;
        if (!holders.isEmpty()) {
            insert holders;
        }
        update toWrite;
    }

    /**
     * Standing answers about people on this deal, newest establishment last so the note and
     * the recency arbitration both read the same order.
     *
     * **KEYED ON THE PERSON, WHICH IS THE PARTICIPANT WHERE ONE IS CARRIED.** Addendum 18 put
     * the claim onto the Participant, so answers written since carry it; answers written
     * before still key on the Contact. Grouping on whichever is present keeps one person's
     * pre-ruling and post-ruling answers on one map row instead of projecting them twice.
     */
    private static Map<String, List<AAO_Answer__c>> standingByPerson(Id opportunityId) {
        Map<String, List<AAO_Answer__c>> out = new Map<String, List<AAO_Answer__c>>();
        for (AAO_Answer__c a : [
            SELECT
                Id,
                AAO_Subject_Contact__c,
                AAO_Subject_Contact__r.Name,
                AAO_Participant__c,
                AAO_Participant__r.AAO_Display_Name__c,
                AAO_Participant__r.AAO_Contact__c,
                AAO_Participant__r.AAO_Coverage_Projected_Value__c,
                AAO_Participant__r.AAO_Coverage_Projected_Modstamp__c,
                AAO_Verdict__c,
                AAO_Interpretation__c,
                AAO_Support_Counter__c,
                AAO_Evidence_Occurred__c,
                AAO_Spans__c,
                AAO_Publication_State__c,
                AAO_Projected_Value__c,
                AAO_Projected_Modstamp__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Answer__c
            WHERE
                AAO_Opportunity__c = :opportunityId
                AND AAO_Subject_Type__c IN ('Contact', 'Participant')
                AND (AAO_Subject_Contact__c != NULL OR AAO_Participant__c != NULL)
                // Held is live for nothing. A held answer never reaches a customer record.
                AND AAO_Publication_State__c = 'Live'
            ORDER BY AAO_Evidence_Occurred__c ASC NULLS FIRST, Id ASC
        ]) {
            String key = personKeyOf(a);
            if (!out.containsKey(key)) {
                out.put(key, new List<AAO_Answer__c>());
            }
            out.get(key).add(a);
        }
        return out;
    }

    private static String personKeyOf(AAO_Answer__c a) {
        return a.AAO_Participant__c != null
            ? String.valueOf(a.AAO_Participant__c)
            : String.valueOf(a.AAO_Subject_Contact__c);
    }

    /**
     * The Contact this person's map row hangs off, resolved through the Participant where the
     * answer keys on one. `ALTF__Contact_Map_Details__c.ALTF__Contact__c` is required, so a
     * person with no resolved Contact cannot reach the map at all.
     */
    private static Id contactOf(AAO_Answer__c a) {
        if (a.AAO_Subject_Contact__c != null) {
            return a.AAO_Subject_Contact__c;
        }
        return a.AAO_Participant__r == null ? null : a.AAO_Participant__r.AAO_Contact__c;
    }

    /**
     * The participation row behind this answer, with what the ladder needs selected. Read
     * per person rather than bulked because the create leg only ever runs for the few people
     * a deal has no Contact for, and paying a query for each of those is cheaper than paying
     * one for everybody.
     */
    private static AAO_Participant__c participantOf(AAO_Answer__c a) {
        if (a.AAO_Participant__c == null) {
            return null;
        }
        List<AAO_Participant__c> found = [
            SELECT Id, AAO_Contact__c, AAO_Email__c, AAO_Roster_Key__c, AAO_Display_Name__c,
                AAO_Source__c
            FROM AAO_Participant__c
            WHERE Id = :a.AAO_Participant__c
            LIMIT 1
        ];
        return found.isEmpty() ? null : found[0];
    }

    /**
     * Stamp the resolved Contact onto every answer and claim of this participant that has none.
     *
     * Per person rather than bulked, for the same reason the identity ladder is: this runs only
     * for the few people a deal had no Contact for, and paying two queries for each of those is
     * cheaper than paying them for everybody. Rows that already carry a link are untouched, so
     * this is idempotent and re-projection costs nothing.
     */
    private static Integer backfillSubjectContact(Id participantId, Id contactId) {
        if (participantId == null || contactId == null) {
            return 0;
        }
        Integer n = 0;
        List<AAO_Answer__c> answers = [
            SELECT Id FROM AAO_Answer__c
            WHERE AAO_Participant__c = :participantId AND AAO_Subject_Contact__c = null
        ];
        for (AAO_Answer__c a : answers) {
            a.AAO_Subject_Contact__c = contactId;
        }
        if (!answers.isEmpty()) {
            update answers;
            n += answers.size();
        }
        // CLAIMS ARE DELIBERATELY NOT TOUCHED, and the org refuses the attempt: "AAO_Claim__c
        // is insert only apart from retirement ... A claim is one establishment from one piece
        // of evidence, and it is never edited." The first cut of this backfill did try, and the
        // validation rule caught it mid-projection, which is the immutability law doing its job.
        // It costs nothing here: the contact page reads ANSWERS, which is the surface Matthew
        // found empty, and the claim's link is repaired for future runs by the identity ladder
        // writing the resolved Contact back onto the participant, so the next join stamps it
        // from a participant that now has one.
        return n;
    }

    private static String nameOf(AAO_Answer__c a) {
        if (a.AAO_Participant__r != null &&
            String.isNotBlank(a.AAO_Participant__r.AAO_Display_Name__c)) {
            return a.AAO_Participant__r.AAO_Display_Name__c;
        }
        if (a.AAO_Subject_Contact__r != null &&
            String.isNotBlank(a.AAO_Subject_Contact__r.Name)) {
            return a.AAO_Subject_Contact__r.Name;
        }
        return String.valueOf(personKeyOf(a));
    }

    // ------------------------------------------------------------------ one person

    private static PersonResult project(
        Id opportunityId,
        Id accountId,
        List<AAO_Answer__c> answers,
        Derivation d
    ) {
        return project(opportunityId, accountId, answers, d, null);
    }

    /**
     * `roster` is the participation row for a person the ROSTER places rather than the
     * evidence: forty-fourth stamp item 1. It is null on the evidence-driven path, where the
     * identity is read off the answers exactly as before, and non-null only when `answers` is
     * empty, which is the case that could not previously be expressed at all.
     */
    private static PersonResult project(
        Id opportunityId,
        Id accountId,
        List<AAO_Answer__c> answers,
        Derivation d,
        AAO_Participant__c roster
    ) {
        Boolean fromRoster = answers.isEmpty();
        PersonResult r = new PersonResult();
        Id contactId = fromRoster ? roster.AAO_Contact__c : contactOf(answers[0]);
        r.contactId = contactId;
        r.participantId = fromRoster ? roster.Id : answers[0].AAO_Participant__c;
        r.personName = fromRoster ? roster.AAO_Display_Name__c : nameOf(answers[0]);
        r.support = d.support;
        r.supportCounter = d.supportCounter;
        r.political = d.political;
        r.buyerRole = d.buyerRole;
        r.criteriaNamed = d.criteria.size();
        r.note = d.note;

        if (!d.buyerRoleCollision.isEmpty()) {
            r.heldBack.add('Buyer Role');
        }

        // **A DERIVATION THAT PLACES NOBODY IS EXACTLY WHEN RETRACTION MUST RUN**, so this no
        // longer returns early. It used to, and that would have made the ratified retraction
        // unreachable in the one case it exists for: an answer falling to UNVERIFIED leaves
        // the derivation empty and the map still carrying what we wrote.
        //
        // What the empty derivation still skips is the CREATE leg, below - making a map row
        // to write nothing into is a row asserting a person we established nothing about.

        // THE MAP NEEDS A CONTACT AND THIS PERSON HAS NONE, so the create leg runs: the
        // ladder again, then a create where the toggle allows it, then a shadow. Addendum 19,
        // ruling 3. Before this the writer reported the gap and stopped, which was honest and
        // was not the ruling.
        //
        // `unresolved` STAYS, as the honest report of what the leg could not do. It is now
        // the narrow case rather than the whole case: the person is held at shadow stage,
        // which is a real and for a toggle-off org a PERMANENT state, and the map is the one
        // surface they cannot reach - `ALTF__Contact_Map_Details__c.ALTF__Contact__c` is
        // required, so there is no map row to write without a Contact and none is faked.
        if (contactId == null && !d.placesAnybody()) {
            r.action = 'unchanged';
            r.reason = 'Nothing established for this person on any map dimension.';
            return r;
        }
        if (contactId == null) {
            AAO_Participant__c person = fromRoster ? roster : participantOf(answers[0]);
            if (person == null) {
                r.action = 'unresolved';
                r.reason =
                    'No Contact and no participation row, so there is nothing to resolve ' +
                    'from. A pre-ruling answer keyed on a Contact that has since been ' +
                    'deleted lands here.';
                return r;
            }
            AAO_Identity.Resolution res = AAO_Identity.resolve(person, accountId, opportunityId);
            r.identity = res.action;
            r.shadowPersonId = res.shadowPersonId;
            if (res.reachesTheMap()) {
                contactId = res.contactId;
                r.contactId = contactId;
                r.reason = res.reason;
                // THE SUBJECT-CONTACT BACKFILL. Forty-fourth stamp, item 3, Matthew's finding:
                // Dan Lewis's contact page showed zero answers while his answers existed and
                // were Live. The join stamps `AAO_Subject_Contact__c` from the participant's
                // contact, and a person whose Contact is CREATED BY THIS RUN had none at join
                // time, so the link was null forever and the evidence trail only walked one
                // way. The ladder has just resolved it, so the rows are stamped here, which is
                // the earliest moment the answer is true.
                r.linksBackfilled = backfillSubjectContact(person.Id, contactId);
            } else {
                r.action = 'unresolved';
                r.reason =
                    'Held at shadow stage, so no map row can be reached: ' +
                    'ALTF__Contact_Map_Details__c.ALTF__Contact__c is required and no ' +
                    'Contact exists. ' + res.reason +
                    ' The derivation stands on our own rows and projects the moment identity ' +
                    'resolves.';
                return r;
            }
        }

        // ---- read before write, on the pair
        List<ALTF__Contact_Map_Details__c> rows = [
            SELECT
                Id,
                ALTF__Status__c,
                ALTF__Political__c,
                ALTF__Buyer_Role__c,
                ALTF__Coverage__c,
                ALTF__Note__c,
                ALTF__Status_Last_Modified__c,
                ALTF__Political_Last_Modified__c,
                ALTF__Buyer_Role_Last_Modified__c,
                ALTF__Coverage_Last_Modified__c
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
            raiseDuplicateFlag(opportunityId, accountId, contactId, rows.size(), 'map rows');
            return r;
        }

        if (rows.isEmpty() && !d.placesAnybody()) {
            r.action = 'unchanged';
            r.reason = 'Nothing established for this person on any map dimension, and no ' +
                'map row exists to retract from.';
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
            if (d.buyerRole != null) {
                fresh.ALTF__Buyer_Role__c = d.buyerRole;
                r.dimensionsWritten.add('Buyer Role');
            }
            if (d.coverage != null) {
                fresh.ALTF__Coverage__c = d.coverage;
                r.dimensionsWritten.add('Coverage');
            }
            fresh.ALTF__Note__c = d.note;
            insert fresh;
            r.mapRowId = fresh.Id;
            r.action = 'created';
            // No answers on the roster path means nothing to watermark here; the coverage
            // watermark is stamped on the PARTICIPANT by run(), which is the only row a
            // roster-placed person has.
            if (!fromRoster) {
                stampProjected(answers, d, null);
            }
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
        Boolean matched =
            (d.support != null && row.ALTF__Status__c == d.support) ||
            (d.political != null && row.ALTF__Political__c == d.political) ||
            (d.buyerRole != null && row.ALTF__Buyer_Role__c == d.buyerRole);

        // On the roster path the coverage watermark IS the last thing we projected for this
        // person, because coverage is the only dimension a roster placement writes.
        Datetime ours = fromRoster
            ? roster.AAO_Coverage_Projected_Modstamp__c
            : lastProjected(answers);

        // **A POPULATED VALUE WE CANNOT PROVE IS OURS IS THE HUMAN'S.** Found 7 August by the
        // watermark check on Matthew's own map edit: he set Fatema Choudray's Political Status
        // to Inner Circle, and we hold no answer, no participation row and no watermark for
        // her at all.
        //
        // `humanEdited` compares stamps and returns false when `ourLastWrite` is null, because
        // first contact was deliberately carved out as ours to write. That carve-out was
        // correct while the only way to hold no watermark was to have never met the row - and
        // a human authoring a value on a row we have never touched breaks exactly that
        // assumption. Under the stamp test alone, the first run that established any Political
        // Status for Fatema would have overwritten a deliberate human judgment, which is the
        // one outcome this system exists to prevent.
        //
        // The repair is the test retraction already uses, applied one stage earlier: a
        // non-blank value that our own watermark does not claim was put there by somebody
        // else, because nobody else could have. Absence of our watermark plus presence of a
        // value IS the evidence of a human edit; it is not the absence of evidence.
        // TOUCHED IS PER DIMENSION, ruled 8 August under one binding constraint: it must mean
        // OUR OWN RECORDED PROJECTION WATERMARK for that dimension, never the native
        // `ALTF__*_Last_Modified__c` stamp. The native stamps are non-null precisely for the
        // rows a human edited - Fatema's Political Status carries one, hers - so reading them
        // as ours would silently undo the session-77 repair inside the repair, which is the
        // correction-that-disables-what-it-corrects hazard firing on its own first instance.
        //
        // Per person was too coarse and the a23 correction is what proved it: Wendy Higley's
        // only answer stood UNVERIFIED and placed nothing, so by the per-person test we had
        // never touched her row, and the Coverage value WE wrote could never be retracted.
        //
        // Coverage supplies its watermark from the participant rather than from an answer,
        // because it is computed and has none. Without that half this per-dimension test would
        // make coverage PERMANENTLY UNWRITABLE rather than retractable - it would hold back on
        // first contact and every contact after it, since no answer can ever carry a coverage
        // watermark. The two halves ship together or neither is correct.
        Map<String, Set<String>> ourValues = ourValuesByDimension(answers);
        // On the roster path there are no answers to carry a watermark, so coverage's is read
        // off the participation row directly. Without this a roster-placed person's own
        // previous coverage write would be invisible to the guard below and would read as a
        // human edit on the second projection, freezing the one dimension the row exists for.
        Datetime coverageMark = fromRoster
            ? roster.AAO_Coverage_Projected_Modstamp__c
            : coverageWatermark(answers);
        String recordedCoverage;
        if (coverageMark != null) {
            recordedCoverage = fromRoster
                ? roster.AAO_Coverage_Projected_Value__c
                : answers[0].AAO_Participant__r.AAO_Coverage_Projected_Value__c;
        }
        if (String.isNotBlank(recordedCoverage)) {
            ourValues.put(AAO_P8Codes.DIM_COVERAGE, new Set<String>{ recordedCoverage });
        }

        // THE BOOTSTRAP, and it is not a detail: coverage's watermark is recorded only when
        // coverage is written, so on every row written before that recording existed there is
        // none. Applying the per-dimension test to coverage alone froze it on ALL SIX people
        // on the first run of this repair - including Neeraja and Jefferson, whose values we
        // had provably just written - which is the a22 defect reproduced exactly: "the
        // correction freezing the thing it corrects".
        //
        // So where we hold no coverage watermark, coverage falls back to the per-person test
        // it used before. That still never reads `ALTF__Coverage_Last_Modified__c` - the whole
        // of the binding constraint - because the fallback is our own recorded projection
        // watermarks on the other dimensions. It relaxes only "for that dimension", only
        // toward our own records, and only until the row carries a coverage watermark of its
        // own, after which the per-dimension test governs it permanently.
        //
        // Fatema is unaffected either way: she has no answers, no participation and no
        // watermark of any kind, so both tests hold her back and the session-77 repair stands.
        Boolean coverageTouched = ourValues.containsKey(AAO_P8Codes.DIM_COVERAGE) ||
            (String.isBlank(recordedCoverage) && !ourValues.isEmpty());

        if (d.support != null) {
            if (humanEdited(row.ALTF__Status_Last_Modified__c, ours) ||
                humanAuthored(row.ALTF__Status__c, ourValues.get(AAO_P8Codes.DIM_SUPPORT),
                    ourValues.containsKey(AAO_P8Codes.DIM_SUPPORT))) {
                r.heldBack.add('Support');
            } else if (row.ALTF__Status__c != d.support) {
                patch.ALTF__Status__c = d.support;
                r.dimensionsWritten.add('Support');
                wrote = true;
            }
        }
        if (d.political != null) {
            if (humanEdited(row.ALTF__Political_Last_Modified__c, ours) ||
                humanAuthored(row.ALTF__Political__c, ourValues.get(AAO_P8Codes.DIM_POLITICAL),
                    ourValues.containsKey(AAO_P8Codes.DIM_POLITICAL))) {
                r.heldBack.add('Political');
            } else if (row.ALTF__Political__c != d.political) {
                patch.ALTF__Political__c = d.political;
                r.dimensionsWritten.add('Political');
                wrote = true;
            }
        }
        if (d.buyerRole != null) {
            if (humanEdited(row.ALTF__Buyer_Role_Last_Modified__c, ours) ||
                humanAuthored(row.ALTF__Buyer_Role__c, ourValues.get(AAO_P8Codes.DIM_BUYER_ROLE),
                    ourValues.containsKey(AAO_P8Codes.DIM_BUYER_ROLE))) {
                r.heldBack.add('Buyer Role');
            } else if (row.ALTF__Buyer_Role__c != d.buyerRole) {
                patch.ALTF__Buyer_Role__c = d.buyerRole;
                r.dimensionsWritten.add('Buyer Role');
                wrote = true;
            }
        }
        if (d.coverage != null) {
            if (humanEdited(row.ALTF__Coverage_Last_Modified__c, ours) ||
                humanAuthored(row.ALTF__Coverage__c, ourValues.get(AAO_P8Codes.DIM_COVERAGE),
                    coverageTouched)) {
                r.heldBack.add('Coverage');
            } else if (row.ALTF__Coverage__c != d.coverage) {
                patch.ALTF__Coverage__c = d.coverage;
                r.dimensionsWritten.add('Coverage');
                wrote = true;
            }
        }

        // RETRACTION IS WHAT RE-RUN DOES WHEN THE DERIVATION EMPTIES. Ratified 6 August.
        //
        // Projection writes the current derivation INCLUDING NULL, and only where the
        // watermark proves the value is ours and unmodified. The defect it closes: two answers
        // stood UNVERIFIED on a20 while the map carried their old projected values, because
        // the writer only ever wrote a value and never cleared one.
        //
        // **The guard is the watermark pair doing exactly what it was built for.** Ours means
        // the field still reads what we last wrote AND the native per-dimension stamp has not
        // moved since. Either half failing means the value is the human's, and it is held back
        // exactly as an ordinary write would be.
        //
        // **The cost, named rather than discovered**: the vendor field cannot express *we
        // established this and the evidence no longer supports it*. Blanked, it reads
        // identically to *never established* - the null-versus-UNVERIFIED distinction arriving
        // at a schema with no room for it. The note carries what the field cannot. No flag
        // today, journalled always; revisited at the Flags and Guidance fold.
        Set<String> retractedCodes = new Set<String>();
        for (Retraction rt : retractions(row, d, answers, ours)) {
            patch.put(rt.field, null);
            r.retracted.add(rt.dimension);
            retractedCodes.add(rt.dimensionCode);
            wrote = true;
        }
        if (!r.retracted.isEmpty()) {
            d.retractedNote =
                'Retracted ' + String.join(r.retracted, ', ') +
                ': we established these and the evidence no longer supports them. A blank ' +
                'field cannot say that, so it is said here.';
        }
        if (wrote) {
            // Option C: the note explains the values currently showing, and is overwritten
            // freely. Overwriting it never touches evidence, because the receipts live on our
            // Answer rows and the note was always a projection of them.
            patch.ALTF__Note__c = composeWithRetraction(d);
            update patch;
        }
        if (wrote || matched) {
            if (!fromRoster) {
                stampProjected(answers, d, retractedCodes);
            }
        }

        r.action = wrote ? 'populated' : 'unchanged';
        if (!wrote && r.heldBack.isEmpty()) {
            r.reason = 'The map already reads what the evidence establishes.';
        } else if (!wrote) {
            r.reason = 'Every established dimension is human-owned on this row.';
        }
        return r;
    }

    private class Retraction {
        String field;
        /** The human label, for the note a seller reads. */
        String dimension;
        /** The `AAO_P8Codes` dimension, for matching the answers that carried it. */
        String dimensionCode;
        Retraction(String field, String dimension, String dimensionCode) {
            this.field = field;
            this.dimension = dimension;
            this.dimensionCode = dimensionCode;
        }
    }

    /**
     * Every dimension the map still carries our value for and the derivation no longer
     * supports. Empty is the normal case.
     */
    private static List<Retraction> retractions(
        ALTF__Contact_Map_Details__c row,
        Derivation d,
        List<AAO_Answer__c> answers,
        Datetime ours
    ) {
        List<Retraction> out = new List<Retraction>();
        Map<String, String> standing = new Map<String, String>{
            'ALTF__Status__c' => (String) row.get('ALTF__Status__c'),
            'ALTF__Political__c' => (String) row.get('ALTF__Political__c'),
            'ALTF__Buyer_Role__c' => (String) row.get('ALTF__Buyer_Role__c'),
            'ALTF__Coverage__c' => (String) row.get('ALTF__Coverage__c')
        };
        Map<String, String> derived = new Map<String, String>{
            'ALTF__Status__c' => d.support,
            'ALTF__Political__c' => d.political,
            'ALTF__Buyer_Role__c' => d.buyerRole,
            'ALTF__Coverage__c' => d.coverage
        };
        Map<String, String> stamps = new Map<String, String>{
            'ALTF__Status__c' => 'ALTF__Status_Last_Modified__c',
            'ALTF__Political__c' => 'ALTF__Political_Last_Modified__c',
            'ALTF__Buyer_Role__c' => 'ALTF__Buyer_Role_Last_Modified__c',
            'ALTF__Coverage__c' => 'ALTF__Coverage_Last_Modified__c'
        };
        Map<String, String> labels = new Map<String, String>{
            'ALTF__Status__c' => 'Support',
            'ALTF__Political__c' => 'Political',
            'ALTF__Buyer_Role__c' => 'Buyer Role',
            'ALTF__Coverage__c' => 'Coverage'
        };
        Map<String, String> dimensionCodes = new Map<String, String>{
            'ALTF__Status__c' => AAO_P8Codes.DIM_SUPPORT,
            'ALTF__Political__c' => AAO_P8Codes.DIM_POLITICAL,
            'ALTF__Buyer_Role__c' => AAO_P8Codes.DIM_BUYER_ROLE,
            'ALTF__Coverage__c' => AAO_P8Codes.DIM_COVERAGE
        };

        Set<String> weWrote = ourProjectedValues(answers);
        for (String field : standing.keySet()) {
            String live = standing.get(field);
            if (String.isBlank(live) || derived.get(field) != null) {
                continue;
            }
            // PROVABLY OURS, both halves. The value still reads what we last wrote, and the
            // native stamp has not moved since we wrote it.
            if (!weWrote.contains(live)) {
                continue;
            }
            if (humanEdited((Datetime) row.get(stamps.get(field)), ours)) {
                continue;
            }
            out.add(new Retraction(field, labels.get(field), dimensionCodes.get(field)));
        }
        return out;
    }

    /** The values our own watermark says we put on this person's row. */
    private static Set<String> ourProjectedValues(List<AAO_Answer__c> answers) {
        Set<String> out = new Set<String>();
        for (AAO_Answer__c a : answers) {
            if (String.isNotBlank(a.AAO_Projected_Value__c)) {
                out.add(a.AAO_Projected_Value__c);
            }
        }
        return out;
    }

    /**
     * A human edit beats the machine forever. If the native per-dimension stamp is newer than
     * our own last write to this person, somebody moved it by hand after we did, and their
     * value stands.
     *
     * A row we have never written carries a stamp from whatever created it, so first contact
     * is deliberately treated as ours to write: `ourLastWrite == null` means no prior claim.
     */
    /**
     * A live value nobody can prove we wrote. Blank is not authored by anyone, and a value our
     * own watermark names is ours to move.
     */
    private static Boolean humanAuthored(
        String liveValue, Set<String> ourValuesForDimension, Boolean weHaveTouchedThisRow
    ) {
        if (String.isBlank(liveValue)) {
            return false;
        }
        // **A DIMENSION THAT CANNOT CARRY A WATERMARK IS NOT THEREBY THE HUMAN'S.** Found by
        // running a22: Coverage is COMPUTED rather than extracted, so it has no Answer row and
        // therefore no `AAO_Projected_Value__c` of its own. The first cut of this guard read
        // that absence as evidence of a human edit and held back every coverage value we had
        // written ourselves - the correction freezing the thing it corrected, which is the
        // exact hazard the retraction watermark fix was about.
        //
        // The distinction the guard actually wants is between a row WE HAVE NEVER TOUCHED,
        // where a value can only be somebody else's (Fatema Choudray), and a row we demonstrably
        // wrote where one dimension keeps no watermark. On the second, the stamp test is the
        // whole guard, which is what it was before today and is unchanged for it.
        if (!weHaveTouchedThisRow) {
            return true;
        }
        return ourValuesForDimension != null && !ourValuesForDimension.contains(liveValue);
    }

    /**
     * What our watermark says we put on this person's row, per dimension.
     *
     * Per dimension rather than one flat set, even though the four vendor vocabularies happen
     * to be disjoint today: that disjointness is an accident of the picklists rather than a
     * property anyone guaranteed, and a guard that holds a human edit back is not a place to
     * spend an accident.
     */
    private static Map<String, Set<String>> ourValuesByDimension(List<AAO_Answer__c> answers) {
        Map<String, Set<String>> out = new Map<String, Set<String>>();
        for (AAO_Answer__c a : answers) {
            if (String.isBlank(a.AAO_Projected_Value__c)) {
                continue;
            }
            String dim = AAO_P8Codes.dimensionOf(codeOf(a));
            if (dim == null) {
                continue;
            }
            if (!out.containsKey(dim)) {
                out.put(dim, new Set<String>());
            }
            out.get(dim).add(a.AAO_Projected_Value__c);
        }
        return out;
    }

    /**
     * Our own recorded coverage watermark for this person, or null where we hold none.
     *
     * Read from the participant because coverage is computed and keeps no Answer. NEVER read
     * from `ALTF__Coverage_Last_Modified__c`: that is the vendor's stamp on the row and is
     * non-null exactly where somebody edited it, so treating it as ours would hand every
     * human coverage edit straight back to the machine.
     */
    private static Datetime coverageWatermark(List<AAO_Answer__c> answers) {
        for (AAO_Answer__c a : answers) {
            if (a.AAO_Participant__r != null &&
                a.AAO_Participant__r.AAO_Coverage_Projected_Modstamp__c != null) {
                return a.AAO_Participant__r.AAO_Coverage_Projected_Modstamp__c;
            }
        }
        return null;
    }

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
     * a native stamp, however sound the chain looks - the 3 August run's chain was provably
     * deterministic and the backfill was still refused, because the precedent costs more than
     * the row. Replay over claims re-projects for real, so refusing costs nothing.
     *
     * Stamped only where something was actually written, and only on the answers that carried
     * the dimension that moved: an answer whose dimension was held back for a human edit has
     * not been projected and must not claim it has.
     */
    private static void stampProjected(
        List<AAO_Answer__c> answers, Derivation d, Set<String> retractedDimensions
    ) {
        Datetime now = Datetime.now();
        List<AAO_Answer__c> touched = new List<AAO_Answer__c>();
        Set<String> retracted = retractedDimensions == null
            ? new Set<String>()
            : retractedDimensions;
        for (AAO_Answer__c a : answers) {
            String value = projectedValueFor(a, d);
            // **A RETRACTION IS A WRITE, AND A WRITE STAMPS ITS WATERMARK.** Found 6 August by
            // reading the corrected export: retraction cleared Ryan Couture's Support on the
            // map and left the watermark reading `Supporter`, because the skip below tested
            // only whether a value came back non-null.
            //
            // That is the compare-and-swap hazard firing from our own correction. On the next
            // pass the writer reads a blank field against a watermark saying `Supporter`, sees
            // they differ, and concludes A HUMAN CLEARED IT - so the dimension becomes
            // human-owned forever and the machine stops writing it. The one write that exists
            // to fix a mistake would have permanently frozen the field it fixed.
            //
            // The distinction the skip actually wants is between a dimension we DID NOT WRITE
            // (held back for a human, or simply not derived) and one we wrote AS NULL. Only
            // the first must not claim projection.
            Boolean wasRetracted = retracted.contains(
                AAO_P8Codes.dimensionOf(codeOf(a))
            );
            if (value == null && !wasRetracted) {
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
        String dim = AAO_P8Codes.dimensionOf(codeOf(a));
        if (dim == AAO_P8Codes.DIM_SUPPORT) {
            return d.support;
        }
        if (dim == AAO_P8Codes.DIM_POLITICAL) {
            return d.political;
        }
        if (dim == AAO_P8Codes.DIM_BUYER_ROLE) {
            return d.buyerRole;
        }
        // Criteria do not project onto the map row, so there is no map value for one of their
        // answers to have contributed and nothing to watermark against.
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

    private static String codeOf(AAO_Answer__c a) {
        return a.AAO_Evidence_Contract__r == null
            ? null
            : a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c;
    }

    // =================================================================== the derivation

    /** One criterion this person named, with its typing and its gate. */
    public class CriterionRead {
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String criterionType = 'Informal';
        @AuraEnabled
        public Boolean required = false;
        @AuraEnabled
        public Datetime asOf;
    }

    public class Derivation {
        public String support;
        /** The standing counter, carried so a report can show momentum beside standing. */
        public Integer supportCounter;
        public String political;
        public String buyerRole;
        /**
         * The roles that stood when more than one did. **Empty is the normal case and a
         * populated list is a refusal, not a value** - see `buyerRoleFrom`.
         */
        public List<String> buyerRoleCollision = new List<String>();
        /**
         * Established roles the LADDER outranked. Projected nowhere; carried to the note with
         * their citations, because a role the evidence established does not stop existing
         * when a higher one is also established.
         */
        public List<String> buyerRoleOutranked = new List<String>();
        public List<CriterionRead> criteria = new List<CriterionRead>();
        /** Computed, never extracted. Null is leave-alone, which is the silence law. */
        public String coverage;
        public Integer occasions;
        /** What the vendor field cannot express, carried to the note. */
        public String retractedNote;
        public String note;
        /** True where this call's movement reversed the standing polarity. */
        public Boolean supportPolarityReversed = false;
        /** Answers whose code this writer has no placement for. */
        public Integer unplaced = 0;
        public Set<String> unplacedCodes = new Set<String>();
        public Datetime supportAsOf;
        public Datetime politicalAsOf;

        /** The dimensions that produced a value. What the stage arithmetic counts. */
        public List<String> valuesDerived() {
            List<String> out = new List<String>();
            if (support != null) {
                out.add(AAO_P8Codes.DIM_SUPPORT);
            }
            if (political != null) {
                out.add(AAO_P8Codes.DIM_POLITICAL);
            }
            if (buyerRole != null) {
                out.add(AAO_P8Codes.DIM_BUYER_ROLE);
            }
            if (!criteria.isEmpty()) {
                out.add(AAO_P8Codes.DIM_CRITERIA);
            }
            if (coverage != null) {
                out.add(AAO_P8Codes.DIM_COVERAGE);
            }
            return out;
        }

        /** Whether anything derived reaches the map row. Criteria do not; they are records. */
        public Boolean placesAnybody() {
            return support != null || political != null || buyerRole != null ||
                coverage != null;
        }
    }

    /** Exposed for the harness assertions: derive without writing anything. */
    public static Derivation derive(List<AAO_Answer__c> answers) {
        // One query for every span's own occurred clock, so a citation can carry the date the
        // words were SAID rather than the answer's latest. Resolved here rather than per
        // citation because a per-call lookup on a buying group is a governor bill for nothing.
        return derive(answers, occurredBySource(answers));
    }

    public static Derivation derive(
        List<AAO_Answer__c> answers, Map<Id, Datetime> occurredBySource
    ) {
        Derivation d = new Derivation();

        Set<String> politicalPlacements = new Set<String>();
        Set<String> rolesEstablished = new Set<String>();
        List<String> supportCitations = new List<String>();
        List<String> politicalCitations = new List<String>();
        List<String> buyerRoleCitations = new List<String>();
        List<AAO_Answer__c> criteriaAnswers = new List<AAO_Answer__c>();

        for (AAO_Answer__c a : answers) {
            String code = codeOf(a);
            if (String.isBlank(code)) {
                continue;
            }
            String dim = AAO_P8Codes.dimensionOf(code);
            if (dim == null) {
                // Named, never skipped in silence. This is the v3.9 defect's own shape.
                d.unplaced++;
                d.unplacedCodes.add(code);
                continue;
            }

            // TRUE-OR-NOTHING. Every §P8 question points one way, so an establishment is a
            // TRUE and nothing else places anybody. UNVERIFIED is a real finding with real
            // receipts and it satisfies no condition; FALSE no longer exists in the pass, and
            // the weak Political sides that used to be read off one are their own contracts.
            if (a.AAO_Verdict__c != 'TRUE') {
                continue;
            }

            if (dim == AAO_P8Codes.DIM_SUPPORT) {
                // The counter is the mechanism; this answer's job is to carry it and to
                // supply the citation the note shows.
                if (a.AAO_Support_Counter__c != null) {
                    d.supportCounter = Integer.valueOf(a.AAO_Support_Counter__c);
                }
                d.supportAsOf = later(d.supportAsOf, a.AAO_Evidence_Occurred__c);
                supportCitations.add(citation(a, occurredBySource));
            } else if (dim == AAO_P8Codes.DIM_POLITICAL) {
                politicalPlacements.add(AAO_P8Codes.politicalPlacement(code));
                d.politicalAsOf = later(d.politicalAsOf, a.AAO_Evidence_Occurred__c);
                politicalCitations.add(citation(a, occurredBySource));
            } else if (dim == AAO_P8Codes.DIM_BUYER_ROLE) {
                rolesEstablished.add(AAO_P8Codes.buyerRole(code));
                // EVERY DIMENSION LINE CARRIES ITS CITATION (thirtieth stamp item 4): the
                // Buyer Role line used to render bare while Support and Political carried
                // date and speaker. Captured here the same way, newest last.
                buyerRoleCitations.add(citation(a, occurredBySource));
            } else if (dim == AAO_P8Codes.DIM_CRITERIA) {
                criteriaAnswers.add(a);
            }
        }

        d.support = AAO_SupportCounter.rungFor(d.supportCounter);
        d.political = AAO_P8Codes.politicalCeiling(politicalPlacements);
        buyerRoleFrom(rolesEstablished, d);
        d.criteria = criteriaFrom(criteriaAnswers);
        d.note = composeNote(d, supportCitations, politicalCitations, buyerRoleCitations);
        return d;
    }

    /**
     * Buyer Role. **One role or none, and several is a refusal.**
     *
     * `ALTF__Buyer_Role__c` is a single-select picklist and the pass can establish more than
     * one - §P8.9 ruled that behaviour on the call establishes, and one person can plainly
     * evaluate and use the same product. There is no authored ordering among the five: unlike
     * Political Status, which the methodology declares as a ceiling, the vendor's Buyer Role
     * values are an unordered set, and inventing a ranking here would be **the machine
     * deciding what outranks what**, which is the line that keeps a discovered criterion from
     * raising a flag.
     *
     * So this applies the law already in this class one line up - two map rows for one pair
     * raise a flag and write nothing, never pick - to two roles for one field. It costs
     * under-writing rather than mis-writing, which is the safe direction, and it produces the
     * measurement the ruling needs: how often several roles actually stand together.
     *
     * **OPEN, and stated as an assumption rather than a settled rule.** If Matthew rules an
     * ordering, it replaces this method and nothing else in the class moves.
     */
    private static void buyerRoleFrom(Set<String> established, Derivation d) {
        if (established.isEmpty()) {
            return;
        }
        if (established.size() == 1) {
            d.buyerRole = new List<String>(established)[0];
            return;
        }

        // THE LADDER, Matthew's ruling, ruled at the thirty-eighth stamp and built at the
        // forty-fifth: "The writer projects the highest-ranked ESTABLISHED role, Decision Maker
        // above Evaluator above User; the unprojected established roles ride the Option C note
        // with their citations; the refusal-note hold is superseded for ladder-resolvable
        // collisions and stays for anything the ladder cannot rank."
        //
        // Before this, EVERY collision was a refusal, and the field held its "the evidence
        // establishes Evaluator, User and the field holds one" note. That was right while
        // nothing ranked the roles; it is wrong now that something does, and Adam Pfeiffer's
        // row is the acceptance case. The hold survives only where the ladder genuinely cannot
        // answer, which is any set touching Approver or Signature Approver.
        // THE HOLD IS GONE, and its absence is the seventy-seventh stamp's whole point. The
        // procedure returns null only for an EMPTY set, which never reaches this line because
        // the caller does not call it with nothing. Every other set yields a value, so a person
        // with evidence never carries a blank Buyer Role again.
        String ceiling = AAO_P8Codes.buyerRoleCeiling(established);
        if (ceiling == null) {
            // Unreachable by construction and left standing rather than deleted: if the
            // procedure ever regains a way to answer nothing, this records that it happened
            // instead of writing a silent blank nobody can trace.
            List<String> several = new List<String>(established);
            several.sort();
            d.buyerRoleCollision = several;
            return;
        }
        d.buyerRole = ceiling;
        // The roles the procedure outranked are NOT discarded: they were established by evidence
        // and the note carries them with their citations, which is what makes a projected
        // Approver still auditable back to the Evaluator words.
        d.buyerRoleOutranked = AAO_MapValues.outranked(
            AAO_P8Codes.DIM_BUYER_ROLE, established
        );
    }

    /**
     * The criteria this person named, typed by provenance and gated by their own words.
     *
     * **Criteria do not reach the map row.** They are `ALTF__Decision_Criteria__c` records
     * with holder junctions, which is a different write with its own mechanics, so this
     * derives and reports them and writes nothing. What that write still needs is named in
     * BUILD_JOURNAL and is not invented here: a person naming three criteria produces three
     * criteria and ONE answer per contract, because the answer key is subject plus contract
     * and the subject is the person - so the criteria path needs its answers subjected to the
     * criterion, which is the fifth subject type and is not wired.
     */
    private static List<CriterionRead> criteriaFrom(List<AAO_Answer__c> answers) {
        List<CriterionRead> out = new List<CriterionRead>();
        Boolean formal = false;
        Boolean required = false;
        for (AAO_Answer__c a : answers) {
            String code = codeOf(a);
            if (code == AAO_P8Codes.CRITERION_FORMAL) {
                formal = true;
            } else if (code == AAO_P8Codes.CRITERION_REQUIRED) {
                required = true;
            }
        }
        for (AAO_Answer__c a : answers) {
            if (codeOf(a) != AAO_P8Codes.CRITERION_NAMING) {
                continue;
            }
            if (String.isBlank(a.AAO_Interpretation__c)) {
                continue;
            }
            CriterionRead c = new CriterionRead();
            c.subject = a.AAO_Interpretation__c;
            // Typing is by PROVENANCE (Matthew's ruling): organizational standing spoken
            // makes it Formal, else Informal and upgradeable. A naming with no attribution
            // defaults Informal and is not a failure.
            c.criterionType = formal ? 'Formal' : 'Informal';
            c.required = required;
            c.asOf = a.AAO_Evidence_Occurred__c;
            out.add(c);
        }
        return out;
    }

    private static String composeWithRetraction(Derivation d) {
        if (String.isBlank(d.retractedNote)) {
            return d.note;
        }
        String base = String.isBlank(d.note) ? '' : d.note + '\n';
        return (base + d.retractedNote).abbreviate(NOTE_MAX);
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
        Derivation d,
        List<String> supportCitations,
        List<String> politicalCitations,
        List<String> buyerRoleCitations
    ) {
        List<String> parts = new List<String>();
        if (d.support != null) {
            parts.add(
                'Support: ' + d.support +
                (supportCitations.isEmpty()
                    ? ''
                    : ' - ' + supportCitations[supportCitations.size() - 1])
            );
        }
        if (d.political != null) {
            parts.add(
                'Political: ' + d.political +
                (politicalCitations.isEmpty()
                    ? ''
                    : ' - ' + politicalCitations[politicalCitations.size() - 1])
            );
        }
        if (d.buyerRole != null) {
            parts.add(
                'Buyer Role: ' + d.buyerRole +
                (buyerRoleCitations.isEmpty()
                    ? ''
                    : ' - ' + buyerRoleCitations[buyerRoleCitations.size() - 1])
            );
            if (!d.buyerRoleOutranked.isEmpty()) {
                // THE LADDER'S OTHER HALF. The ruling projects the highest role AND keeps the
                // rest visible: "the unprojected established roles ride the Option C note with
                // their citations". Without this line the map would silently drop a role the
                // evidence established, which is the same silence the refusal note exists to
                // end, just quieter.
                parts.add(
                    'Also established, outranked by ' + d.buyerRole + ': ' +
                    String.join(d.buyerRoleOutranked, ', ') +
                    (buyerRoleCitations.size() < 2
                        ? ''
                        : ' - ' + buyerRoleCitations[0])
                );
            }
        } else if (!d.buyerRoleCollision.isEmpty()) {
            // The refusal says so on the surface the seller reads, because a blank field
            // beside three established roles is the silence this whole design exists to end.
            parts.add(
                'Buyer Role: not written. The evidence establishes ' +
                String.join(d.buyerRoleCollision, ', ') +
                ' and the field holds one.'
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
        if (d.support != null) {
            plain.add('Support: ' + d.support);
        }
        if (d.political != null) {
            plain.add('Political: ' + d.political);
        }
        if (d.buyerRole != null) {
            plain.add('Buyer Role: ' + d.buyerRole);
            if (!d.buyerRoleOutranked.isEmpty()) {
                // Survives the degrade: the outranked roles are FACTS the evidence
                // established, not decoration, so they outlive the citations when the note
                // has to shed length.
                plain.add(
                    'Also established, outranked: ' + String.join(d.buyerRoleOutranked, ', ')
                );
            }
        }
        plain.add('Full citations on the AAO answer rows for this person.');
        return String.join(plain, '\n').abbreviate(NOTE_MAX);
    }

    /**
     * Plain date and speaker, ONE PER SPAN. No record id ever reaches a human surface.
     *
     * **AN ACCUMULATED ESTABLISHMENT IS NEVER RENDERED AS ONE STATEMENT.** Matthew's ruling at
     * the seventieth stamp: completeness accumulates across utterances, and the integrity
     * condition that makes that honest is that every element keeps its own words, its own
     * speaker and THE DATE IT WAS SAID. A reader must be able to see that this was assembled
     * over time, and when each part was said.
     *
     * **THE DEFECT THIS CLOSES, found by reading this method against that ruling.** It took
     * `spans[0].speaker` and paired it with the ANSWER'S occurred date — and the answer's clock
     * only ever moves FORWARDS, so an establishment carrying March's words and June's words
     * credited March's speaker with June's date. That is a citation for a moment that never
     * happened, assembled out of two that did. It is harmless on today's fixture because every
     * span shares one source, which is exactly why it survived; it becomes wrong the first time
     * a second call lands, and Matthew's ruling makes that case law rather than hypothetical.
     *
     * Rendering is deduped and date-ordered, so the single-source case reads exactly as before
     * ("Dan Lewis, 30 July 2026") and the accumulated case reads as what it is
     * ("Adam Pfeiffer, 3 March 2026; Adam Pfeiffer, 12 June 2026").
     */
    @TestVisible
    private static String citation(AAO_Answer__c a, Map<Id, Datetime> occurredBySource) {
        // D2, session 74: this read spans[0] unconditionally, so the person credited on a
        // customer-visible note could be taken from a span the blind reader had refused.
        // Filter first, then render what survives.
        List<AAO_Model.Span> spans = AAO_Model.upheld(
            AAO_Model.parseSpans(a.AAO_Spans__c).spans
        );
        if (spans.isEmpty()) {
            // NO SPANS STILL CARRIES THE DATE. Caught by the note test: an early return of the
            // bare phrase dropped the answer's own occurred clock, which is the only date there
            // is when there are no spans to carry their own. Losing a date is a smaller error
            // than attaching the wrong one, and it is still an error.
            return 'on the call' + (a.AAO_Evidence_Occurred__c == null
                ? ''
                : ', ' + a.AAO_Evidence_Occurred__c.formatGmt('d MMMM yyyy'));
        }
        // Sorted by the SPAN'S OWN date, so the parts read in the order they were said rather
        // than in the order the join happened to commit them.
        Map<String, Datetime> whenByLine = new Map<String, Datetime>();
        for (AAO_Model.Span s : spans) {
            Datetime said = s.sourceId == null || occurredBySource == null
                ? null
                : occurredBySource.get((Id) s.sourceId);
            // The answer's own clock is the fallback ONLY where the span's source is unknown,
            // and only then, because it is the latest date on the answer rather than this
            // span's date and using it by default is the defect above.
            if (said == null) {
                said = a.AAO_Evidence_Occurred__c;
            }
            String who = String.isBlank(s.speaker) ? 'on the call' : s.speaker;
            String line = who + (said == null ? '' : ', ' + said.formatGmt('d MMMM yyyy'));
            if (!whenByLine.containsKey(line)) {
                whenByLine.put(line, said);
            }
        }
        List<String> lines = new List<String>(whenByLine.keySet());
        for (Integer i = 0; i < lines.size(); i++) {
            for (Integer j = i + 1; j < lines.size(); j++) {
                Datetime x = whenByLine.get(lines[i]);
                Datetime y = whenByLine.get(lines[j]);
                if (x != null && y != null && y < x) {
                    String t = lines[i];
                    lines[i] = lines[j];
                    lines[j] = t;
                }
            }
        }
        return String.join(lines, '; ');
    }

    /** The occurred clock per Source, so every span can carry the date IT was said. */
    private static Map<Id, Datetime> occurredBySource(List<AAO_Answer__c> answers) {
        Set<Id> sourceIds = new Set<Id>();
        for (AAO_Answer__c a : answers) {
            for (AAO_Model.Span s : AAO_Model.parseSpans(a.AAO_Spans__c).spans) {
                if (String.isNotBlank(s.sourceId)) {
                    sourceIds.add((Id) s.sourceId);
                }
            }
        }
        Map<Id, Datetime> out = new Map<Id, Datetime>();
        if (sourceIds.isEmpty()) {
            return out;
        }
        for (AAO_Source__c s : [
            SELECT Id, AAO_Evidence_Occurred__c FROM AAO_Source__c WHERE Id IN :sourceIds
        ]) {
            out.put(s.Id, s.AAO_Evidence_Occurred__c);
        }
        return out;
    }

    // -------------------------------------------------------------------- internals

    private static void raiseDuplicateFlag(
        Id opportunityId,
        Id accountId,
        Id contactId,
        Integer howMany,
        String unit
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