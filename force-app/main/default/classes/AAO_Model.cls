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

        public String fingerprint() {
            return sourceId + ':' + startOffset + ':' + endOffset;
        }
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

        public Boolean isFull() {
            return missing == null || missing.isEmpty();
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
