/**
 * Byte verification. Every span must equal the substring of its own Source's normalized
 * text, exactly, and must be contiguous inside a single speaker turn.
 *
 * This is the reason Source is immutable. A transcript edited after a span was verified
 * against it breaks the citation chain, and the break is silent, so the verifier here
 * only ever proves the state of the world at the moment it runs.
 *
 * It reports every failure rather than the first, because a span set that fails in three
 * ways is three findings and a caller that saw one would fix one and re-run.
 */
public class AAO_SpanVerifier {
    public class Failure {
        public Integer index;
        public String reason;

        public Failure(Integer index, String reason) {
            this.index = index;
            this.reason = reason;
        }

        public override String toString() {
            return 'span[' + index + ']: ' + reason;
        }
    }

    public class Result {
        public List<Failure> failures = new List<Failure>();
        /** Roster key of the speaker for each verified span, by span index. */
        public Map<Integer, String> speakerByIndex = new Map<Integer, String>();

        public Boolean isOk() {
            return failures.isEmpty();
        }

        public String describe() {
            List<String> parts = new List<String>();
            for (Failure f : failures) {
                parts.add(f.toString());
            }
            return String.join(parts, '; ');
        }
    }

    /**
     * @param spans      the spans to verify
     * @param sourceById every Source any span points at, with AAO_Normalized_Text__c and
     *                   AAO_Diarization__c selected
     */
    public static Result verify(List<AAO_Model.Span> spans, Map<Id, AAO_Source__c> sourceById) {
        Result r = new Result();
        if (spans == null || spans.isEmpty()) {
            return r;
        }

        Map<Id, List<AAO_NormalForm.Turn>> turnsBySource = new Map<Id, List<AAO_NormalForm.Turn>>();

        for (Integer i = 0; i < spans.size(); i++) {
            AAO_Model.Span sp = spans[i];

            if (String.isBlank(sp.sourceId)) {
                r.failures.add(new Failure(i, 'no source; a quote with no artifact is not evidence'));
                continue;
            }
            Id sid;
            try {
                sid = Id.valueOf(sp.sourceId);
            } catch (Exception e) {
                r.failures.add(new Failure(i, 'source id "' + sp.sourceId + '" is not an id'));
                continue;
            }
            AAO_Source__c src = sourceById.get(sid);
            if (src == null) {
                r.failures.add(new Failure(i, 'source ' + sp.sourceId + ' was not supplied'));
                continue;
            }
            String text = src.AAO_Normalized_Text__c;
            if (text == null) {
                r.failures.add(new Failure(i, 'source ' + sp.sourceId + ' has no normalized text'));
                continue;
            }

            if (sp.startOffset == null || sp.endOffset == null) {
                r.failures.add(new Failure(i, 'offsets are missing'));
                continue;
            }
            if (sp.startOffset < 0 || sp.endOffset <= sp.startOffset) {
                r.failures.add(
                    new Failure(
                        i,
                        'offsets [' + sp.startOffset + ',' + sp.endOffset + ') are not a range'
                    )
                );
                continue;
            }
            if (sp.endOffset > text.length()) {
                r.failures.add(
                    new Failure(
                        i,
                        'offset ' + sp.endOffset + ' runs past the end of the text (' +
                        text.length() + ')'
                    )
                );
                continue;
            }

            // The byte compare. Everything else is structure; this is the citation.
            String actual = text.substring(sp.startOffset, sp.endOffset);
            if (sp.quote == null || actual != sp.quote) {
                r.failures.add(
                    new Failure(
                        i,
                        'quote does not match the source. Offsets say "' +
                        actual +
                        '", the span claims "' +
                        sp.quote +
                        '"'
                    )
                );
                continue;
            }

            // Contiguity inside one turn.
            if (!turnsBySource.containsKey(sid)) {
                turnsBySource.put(
                    sid,
                    AAO_NormalForm.turns(text, src.AAO_Diarization__c)
                );
            }
            AAO_NormalForm.Turn t = AAO_NormalForm.containing(
                turnsBySource.get(sid),
                sp.startOffset,
                sp.endOffset
            );
            if (t == null) {
                r.failures.add(
                    new Failure(
                        i,
                        'the range is not contiguous inside a single speaker turn'
                    )
                );
                continue;
            }

            if (src.AAO_Diarization__c != 'Unsegmented') {
                if (String.isNotBlank(sp.speaker) && sp.speaker != t.speakerKey) {
                    r.failures.add(
                        new Failure(
                            i,
                            'the span attributes this to "' +
                            sp.speaker +
                            '" but the turn belongs to "' +
                            t.speakerKey +
                            '"'
                        )
                    );
                    continue;
                }
            }

            r.speakerByIndex.put(i, t.speakerKey);
        }
        return r;
    }

    /** Every source id named by a span set, for one bulk query. */
    public static Set<Id> sourceIds(List<AAO_Model.Span> spans) {
        Set<Id> ids = new Set<Id>();
        if (spans == null) {
            return ids;
        }
        for (AAO_Model.Span sp : spans) {
            if (String.isNotBlank(sp.sourceId)) {
                try {
                    ids.add(Id.valueOf(sp.sourceId));
                } catch (Exception e) {
                    // Not an id. verify() reports it; collecting is not the place to throw.
                }
            }
        }
        return ids;
    }
}
