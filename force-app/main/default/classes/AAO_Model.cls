/**
 * The JSON shapes carried in the long-text fields, versioned. Spans, element coverage
 * and the speaker roster are the three that matter; each is stamped with a schema
 * version so a later shape is detectable rather than silently misread.
 *
 * These are plain data holders. All the rules live in AAO_SpanVerifier, AAO_SpeakerRule
 * and AAO_Accumulate.
 */
public class AAO_Model {
    public static final Integer SPANS_V = 1;
    public static final Integer COVERAGE_V = 1;
    public static final Integer ROSTER_V = 1;

    // ---------------------------------------------------------------------- spans

    public class Span {
        /** The Source this span is quoted from. Byte verification runs against it. */
        public String sourceId;
        public Integer partIndex;
        /** Character offsets into AAO_Normalized_Text__c, zero-based, end-exclusive. */
        public Integer startOffset;
        public Integer endOffset;
        /** The quoted words. Must equal the substring exactly. */
        public String quote;
        /** Roster key of the speaker whose turn this span lies in. Null if Unsegmented. */
        public String speaker;
        /** Which element of the proposition this span is offered for. */
        public String element;
        /**
         * WHAT THE BLIND READER SAID ABOUT THIS SPAN. `UPHELD`, `REFUSED`, or null where no
         * verification ran (legacy rows, and paths that never reach stage 3).
         *
         * Defect D1, session 74: the blind reader's refusal was recorded in the proposal's
         * interpretation and pruned nothing, so a span the reader explicitly refused stayed on
         * the standing Answer as a citation. The verdict was right — another span covered the
         * element — and the evidence set was wrong, which is the one thing the reader exists to
         * prevent. Recording per span rather than dropping the span follows the standing law:
         * wrong text is marked wrong, never deleted, and a refused quote is part of the record
         * of what the machine considered.
         *
         * **Readers filter; the ledger keeps.** Anything rendering citations to a human calls
         * `upheld()`. Nothing deletes.
         *
         * It also fixes a loss this defect caused: `AAO_Interpretation__c` is one field and kept
         * only the LAST refusal per pair, so on the 3 August run 2 of 9 item-refusals were
         * overwritten and unrecoverable once the logs aged out. Per-span status ends that.
         */
        public String verification;

        public Boolean isRefused() {
            return verification == REFUSED;
        }

        public String fingerprint() {
            return sourceId + ':' + startOffset + ':' + endOffset;
        }
    }

    public static final String UPHELD = 'UPHELD';
    public static final String REFUSED = 'REFUSED';

    /**
     * The spans a reader may show or cite: everything the blind reader did not refuse.
     *
     * Null verification passes deliberately. Legacy rows carry no status and predate the
     * check, and treating unknown as refused would silently blank every citation written
     * before this field existed. Unknown is not refused; only REFUSED is refused.
     */
    public static List<Span> upheld(List<Span> spans) {
        List<Span> out = new List<Span>();
        if (spans == null) {
            return out;
        }
        for (Span sp : spans) {
            if (sp != null && !sp.isRefused()) {
                out.add(sp);
            }
        }
        return out;
    }

    public class SpanSet {
        public Integer v;
        public List<Span> spans;
    }

    public static SpanSet parseSpans(String raw) {
        if (String.isBlank(raw)) {
            SpanSet empty = new SpanSet();
            empty.v = SPANS_V;
            empty.spans = new List<Span>();
            return empty;
        }
        SpanSet s = (SpanSet) JSON.deserialize(raw, SpanSet.class);
        if (s.spans == null) {
            s.spans = new List<Span>();
        }
        return s;
    }

    public static String serializeSpans(List<Span> spans) {
        SpanSet s = new SpanSet();
        s.v = SPANS_V;
        s.spans = spans;
        return JSON.serialize(s);
    }

    // ------------------------------------------------------------------- coverage

    /**
     * Covered and missing are both carried, so partial coverage is queryable and a flag
     * can say here is what stands and here is the piece still needed without re-deriving
     * the element list.
     */
    public class Coverage {
        public Integer v;
        public List<String> covered;
        public List<String> missing;

        /**
         * Full means every element the CONTRACT names is covered. It deliberately takes
         * the element list rather than trusting the missing list, because missing is
         * written by whoever proposed and an empty missing list is a claim, not a fact.
         *
         * The old no-argument version returned missing.isEmpty(), so a proposal of
         * covered:[e1] missing:[] read as full coverage of a three-element proposition
         * and routed a verdict straight through. There is no no-argument version any
         * more: the trap is removed rather than documented.
         */
        public Boolean isFull(List<String> contractElements) {
            if (contractElements == null || contractElements.isEmpty()) {
                // Nothing can fully cover a contract that names no elements. Returning
                // true here would establish propositions out of an empty list.
                return false;
            }
            Set<String> have = new Set<String>(
                covered == null ? new List<String>() : covered
            );
            for (String e : contractElements) {
                if (!have.contains(e)) {
                    return false;
                }
            }
            return true;
        }

        public Boolean isNone() {
            return covered == null || covered.isEmpty();
        }
    }

    public static Coverage parseCoverage(String raw) {
        if (String.isBlank(raw)) {
            return newCoverage(new List<String>(), new List<String>());
        }
        Coverage c = (Coverage) JSON.deserialize(raw, Coverage.class);
        if (c.covered == null) {
            c.covered = new List<String>();
        }
        if (c.missing == null) {
            c.missing = new List<String>();
        }
        return c;
    }

    public static Coverage newCoverage(List<String> covered, List<String> missing) {
        Coverage c = new Coverage();
        c.v = COVERAGE_V;
        c.covered = covered == null ? new List<String>() : covered;
        c.missing = missing == null ? new List<String>() : missing;
        return c;
    }

    public static String serializeCoverage(Coverage c) {
        c.v = COVERAGE_V;
        return JSON.serialize(c);
    }

    // --------------------------------------------------------------------- roster

    public class Speaker {
        /** The token that prefixes this speaker's turns in the normalized text. */
        public String key;
        public String display;
        public String email;
        /**
         * The buying role this person carries on the relationship map. In the sandbox
         * this is seeded here; in production it resolves from the Altify map row, whose
         * API name has not been read from altify--aossb2 yet. See BUILD_JOURNAL.
         */
        public String mapRole;
        public String contactId;
        /**
         * The User behind an internal participant. Key four on Claim resolves from this,
         * from participants, rather than being assumed from the deal owner.
         */
        public String userId;

        public String domain() {
            if (String.isBlank(email) || !email.contains('@')) {
                return null;
            }
            return email.substringAfterLast('@').toLowerCase();
        }
    }

    public class Roster {
        public Integer v;
        public List<Speaker> speakers;
    }

    public static Map<String, Speaker> parseRoster(String raw) {
        Map<String, Speaker> byKey = new Map<String, Speaker>();
        if (String.isBlank(raw)) {
            return byKey;
        }
        Roster r = (Roster) JSON.deserialize(raw, Roster.class);
        if (r.speakers == null) {
            return byKey;
        }
        for (Speaker sp : r.speakers) {
            byKey.put(sp.key, sp);
        }
        return byKey;
    }
}
