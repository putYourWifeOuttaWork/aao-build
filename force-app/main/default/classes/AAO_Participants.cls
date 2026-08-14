/**
 * WHO WAS ON A PIECE OF EVIDENCE, written at ingest so it can be asked of the database.
 * Ruled v1.1, from the audit that withdrew "Coverage is a frozen query".
 *
 * WHY THIS EXISTS. Coverage asks three questions and every one is a count over our own
 * activity: have we met this person, have we recently had several meaningful conversations,
 * do we regularly have high-quality ones. None of them could be asked. Participation lived
 * only inside AAO_Source__c.AAO_Speaker_Roster__c, a LongTextArea of JSON, and SOQL cannot
 * filter into a text blob. The recipe ruling presumes the question is expressible as a
 * query, and "did this person participate" was not.
 *
 * The alternative was deserialising rosters at read time. Deterministic and model-free, but
 * it is not a query, and it puts a governor ceiling between a seller and an answer that is
 * really just a count. This is key four's argument again: A GRAIN NOT RECORDED CANNOT BE
 * DECLARED LATER WITHOUT REPROCESSING THE CORPUS, and participation is exactly such a grain.
 *
 * THE ONE SUBTLETY, and it is inherited from the movement counter rather than invented here.
 * A ninety-minute call arrives as two or three Source rows of ONE artifact, because the gate
 * splits on duration and part index exists for that reason. Counting participant rows would
 * count one conversation twice. So every row carries the artifact hash and COVERAGE COUNTS
 * DISTINCT HASHES, not rows — the same source-event definition the sentiment counter uses,
 * for the same reason.
 *
 * What this junction cannot do, named rather than papered over: it counts OCCASIONS, and
 * questions two and three say "meaningful" and "high quality". AAO_Substantive__c is the
 * only thing here that speaks to substance, derived from the small-talk boundary the
 * normalizer already finds. The threshold behind it is a MEASURED number and this class
 * carries none.
 */
public class AAO_Participants {
    /**
     * A Source with no substantive content past the small-talk boundary is an occasion but
     * not a conversation. Deliberately the weakest possible test — presence of any
     * substantive content at all — because anything stronger would be a threshold, and no
     * threshold is measured yet.
     */
    private static Boolean substantive(AAO_Source__c s) {
        if (s.AAO_Duration_Seconds__c == null || s.AAO_Substantive_Offset__c == null) {
            // Unknown is not the same as no. A source that never carried a boundary reading
            // is counted as substantive rather than silently downgraded, because treating
            // missing data as a negative would make coverage understate itself.
            return true;
        }
        return s.AAO_Duration_Seconds__c > s.AAO_Substantive_Offset__c;
    }

    public static String key(Id sourceId, String rosterKey) {
        return String.valueOf(sourceId) + '|' + rosterKey;
    }

    /**
     * Write one row per person on each Source. Idempotent by the unique key, so re-ingesting
     * an artifact cannot double-count anybody — which matters more here than anywhere else,
     * because every coverage answer rests on a count.
     */
    public static Integer record(List<AAO_Source__c> sources, Set<String> internalDomains) {
        List<AAO_Participant__c> rows = new List<AAO_Participant__c>();
        Set<String> emails = new Set<String>();
        Map<Id, Map<String, AAO_Model.Speaker>> rosterBySource = new Map<Id, Map<String, AAO_Model.Speaker>>();

        for (AAO_Source__c s : sources) {
            // A ROSTER WE CANNOT READ MUST NOT REJECT THE EVIDENCE. This runs in the
            // Source's after-insert, so a throw here rolls back the artifact itself, and
            // participation is a derived convenience while the artifact is the thing we
            // were given. Same ruling AAO_Ingest already makes about a failed enqueue: a
            // failure downstream of arrival must never undo the arrival.
            //
            // The cost is honest and one-directional: coverage under-counts rather than
            // over-counts, so a person we cannot parse reads as less met, never more.
            Map<String, AAO_Model.Speaker> roster;
            try {
                roster = AAO_Model.parseRoster(s.AAO_Speaker_Roster__c);
            } catch (Exception e) {
                roster = new Map<String, AAO_Model.Speaker>();
            }
            rosterBySource.put(s.Id, roster);
            for (AAO_Model.Speaker sp : roster.values()) {
                if (String.isNotBlank(sp.email)) {
                    emails.add(sp.email.toLowerCase());
                }
            }
        }

        // Resolve to Contacts where we can. A roster entry that resolves to nobody still
        // earns a row: they were on the call, and losing that is losing the coverage fact.
        Map<String, Id> contactByEmail = new Map<String, Id>();
        if (!emails.isEmpty()) {
            for (Contact c : [SELECT Id, Email FROM Contact WHERE Email IN :emails]) {
                contactByEmail.put(c.Email.toLowerCase(), c.Id);
            }
        }

        for (AAO_Source__c s : sources) {
            Boolean sub = substantive(s);
            for (String rosterKey : rosterBySource.get(s.Id).keySet()) {
                AAO_Model.Speaker sp = rosterBySource.get(s.Id).get(rosterKey);
                String email = String.isBlank(sp.email) ? null : sp.email.toLowerCase();
                Id contactId = String.isNotBlank(sp.contactId)
                    ? (Id) sp.contactId
                    : (email == null ? null : contactByEmail.get(email));

                rows.add(
                    new AAO_Participant__c(
                        AAO_Source__c = s.Id,
                        AAO_Contact__c = contactId,
                        AAO_Opportunity__c = s.AAO_Opportunity__c,
                        AAO_Account__c = s.AAO_Account__c,
                        AAO_Roster_Key__c = rosterKey,
                        AAO_Display_Name__c = sp.display,
                        AAO_Email__c = sp.email,
                        AAO_Internal__c = AAO_SpeakerRule.isInternal(sp, internalDomains),
                        AAO_Evidence_Occurred__c = s.AAO_Evidence_Occurred__c,
                        AAO_Artifact_SHA256__c = s.AAO_Artifact_SHA256__c,
                        AAO_Substantive__c = sub,
                        AAO_Participant_Key__c = key(s.Id, rosterKey)
                    )
                );
            }
        }
        if (rows.isEmpty()) {
            return 0;
        }

        // The unique key does the deduplicating, the same merge path Answer already uses.
        // A collision here is re-ingestion, which is correct behaviour and not an error.
        Integer written = 0;
        for (Database.SaveResult sr : Database.insert(rows, false)) {
            if (sr.isSuccess()) {
                written++;
                continue;
            }
            for (Database.Error e : sr.getErrors()) {
                if (e.getStatusCode() != StatusCode.DUPLICATE_VALUE) {
                    throw new ParticipantException(
                        'Could not record participation: ' + e.getMessage()
                    );
                }
            }
        }
        return written;
    }

    // ===================================================== the three coverage questions

    public class Coverage {
        /** Distinct source-events, not rows. Parts of one call are one occasion. */
        public Integer occasions = 0;
        public Integer substantiveOccasions = 0;
        public Datetime firstSeen;
        public Datetime lastSeen;

        /** Q1: have you or a team member met with this person. */
        public Boolean met() {
            return occasions > 0;
        }
    }

    /**
     * Read the three Coverage facts for one person on one deal. This is the shape the
     * frozen query was supposed to take and could not, and it is an ordinary aggregate now.
     *
     * `since` bounds "recently" and "regularly". It is passed in rather than fixed here,
     * because the window is a measured number and this class carries none.
     */
    public static Coverage coverage(Id opportunityId, Id contactId, Datetime since) {
        Coverage cov = new Coverage();
        // A null window means all of history. Expressed as a floor rather than a branch so
        // there is one query and one code path.
        Datetime floorAt = since == null ? Datetime.newInstance(1900, 1, 1, 0, 0, 0) : since;
        Set<String> events = new Set<String>();
        Set<String> substantiveEvents = new Set<String>();

        for (AAO_Participant__c p : [
            SELECT AAO_Artifact_SHA256__c, AAO_Substantive__c, AAO_Evidence_Occurred__c
            FROM AAO_Participant__c
            WHERE
                AAO_Opportunity__c = :opportunityId
                AND AAO_Contact__c = :contactId
                AND AAO_Evidence_Occurred__c >= :floorAt
            ORDER BY AAO_Evidence_Occurred__c
        ]) {
            // DISTINCT ARTIFACT, never distinct row. A split call is one occasion.
            String ev = String.isBlank(p.AAO_Artifact_SHA256__c)
                ? 'row:' + p.Id
                : p.AAO_Artifact_SHA256__c;
            events.add(ev);
            if (p.AAO_Substantive__c == true) {
                substantiveEvents.add(ev);
            }
            if (cov.firstSeen == null) {
                cov.firstSeen = p.AAO_Evidence_Occurred__c;
            }
            cov.lastSeen = p.AAO_Evidence_Occurred__c;
        }
        cov.occasions = events.size();
        cov.substantiveOccasions = substantiveEvents.size();
        return cov;
    }

    public class ParticipantException extends Exception {
    }
}