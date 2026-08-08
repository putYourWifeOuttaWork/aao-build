/**
 * THE STEP BETWEEN CALL 1 AND THE LEDGER: byte location, then rows.
 *
 * Call 1 returns words. This class finds those words in the frozen artifact, and only words
 * it finds become pairs. The rule is §P8.0's: **verbatim strings by exact match, never line
 * numbers.** Zero matches discards the pair and increments a counter (unit: pairs).
 * Multiple matches: all occurrences stand, because the words were said more than once, and
 * each occurrence gets its own row carrying its own ordinal.
 *
 * WHY THE MODEL IS NOT ASKED WHERE THE WORDS ARE. It was, in the retired shape: the
 * inventory charter had an `anchor` field described as "a locator for a human reader only"
 * and the span was the truth anyway. Here the locator is computed, so there is no second
 * account of where a quote sits that could disagree with the first. The speaker key is
 * computed the same way and for the same reason: whose turn contains a byte range is
 * arithmetic over the normal form, and a model is never asked a question the text answers.
 *
 * NO DML BEFORE THE CALLOUT, AND NONE IN THE LOCATOR. `locate()` is pure: it takes text and
 * pairs and returns rows in memory. `write()` does the DML. That split is the same one
 * `AAO_Extract` makes and for the same structural reason — a class that cannot write cannot
 * get callout ordering wrong.
 */
public with sharing class AAO_Locate {
    public class LocateException extends Exception {
    }

    /** One located pair, plus what happened to the ones that are not here. */
    public class Located {
        public List<AAO_Pair__c> rows = new List<AAO_Pair__c>();
        /** Pairs whose words are nowhere in the artifact. Counted, never written. */
        public Integer discardedNoMatch = 0;
        /** Pairs whose words match but not inside a single turn. */
        public Integer discardedCrossesTurns = 0;
        public List<String> discardNotes = new List<String>();

        public override String toString() {
            return String.join(
                new List<String>{
                    'pairs located            ' + rows.size() + ' (unit: pairs)',
                    'discarded, no match      ' + discardedNoMatch + ' (unit: pairs)',
                    'discarded, crosses turns ' + discardedCrossesTurns + ' (unit: pairs)'
                },
                '\n'
            );
        }
    }

    /**
     * Find every occurrence of every pair's words and build the located rows.
     *
     * @param src        the frozen artifact. Its stored text is canonical, per the
     *                   normalizer's output-contract law: what we hash, store and verify
     *                   against are one thing and never three.
     */
    public static Located locate(
        AAO_Source__c src,
        List<AAO_LocateCharter.Pair> pairs,
        String runKey,
        String charterVersion,
        Map<String, Id> contractIdByCode
    ) {
        if (src == null || String.isBlank(src.AAO_Normalized_Text__c)) {
            throw new LocateException(
                'Cannot locate against a Source with no normalized text. The stored form is ' +
                'the artifact; there is nothing else to byte-match against.'
            );
        }
        String text = src.AAO_Normalized_Text__c;
        List<AAO_NormalForm.Turn> turns = AAO_NormalForm.turns(text, src.AAO_Diarization__c);

        Located out = new Located();
        Integer n = 0;
        for (AAO_LocateCharter.Pair p : pairs) {
            n++;
            // THE INTRODUCING QUOTE IS EVIDENCE AND GETS THE EVIDENCE TREATMENT: byte-checked
            // against the artifact. A designator whose introduction does not match drops the
            // DESIGNATOR, never the pair - the words themselves still located - and the note
            // says so, because a silently vanished designator reads as self-subject.
            if (p.aboutQuote != null && text.indexOf(p.aboutQuote) < 0) {
                out.discardNotes.add(
                    p.ref + ' ' + p.questionCode + ': designator "' + p.aboutWords +
                    '" dropped, its introducing quote does not byte-match the artifact. ' +
                    'The pair survives as its speaker\'s.'
                );
                p.aboutWords = null;
                p.aboutQuote = null;
            }
            List<Integer> starts = occurrences(text, p.answerText);
            if (starts.isEmpty()) {
                out.discardedNoMatch++;
                out.discardNotes.add(
                    p.ref + ' ' + p.questionCode + ': no byte match for "' +
                    p.answerText.abbreviate(60) + '"'
                );
                continue;
            }

            Integer kept = 0;
            for (Integer occ = 0; occ < starts.size(); occ++) {
                Integer start = starts[occ];
                Integer endEx = start + p.answerText.length();
                AAO_NormalForm.Turn t = AAO_NormalForm.containing(turns, start, endEx);
                if (t == null) {
                    // The words are in the artifact but straddle a turn boundary or the
                    // speaker prefix. A quote that is partly two people's is nobody's.
                    out.discardedCrossesTurns++;
                    out.discardNotes.add(
                        p.ref + ' ' + p.questionCode + ': occurrence ' + (occ + 1) +
                        ' does not lie inside one turn'
                    );
                    continue;
                }
                kept++;
                out.rows.add(row(
                    src, p, runKey, charterVersion, contractIdByCode,
                    // The ordinal is the position among ALL matches, not among the kept
                    // ones, so it still points at the same words if a sibling is dropped.
                    ref(p.ref, occ + 1, starts.size()),
                    occ + 1,
                    starts.size(),
                    start,
                    endEx,
                    t.speakerKey
                ));
            }
            if (kept == 0) {
                out.discardNotes.add(
                    p.ref + ' ' + p.questionCode + ': every occurrence crossed a turn'
                );
            }
        }
        return out;
    }

    /**
     * A single-match pair keeps its plain ref. Only a repeated one is suffixed, so the
     * common case reads as the model's own handle and the ordinal in the key means the
     * words really were said more than once.
     */
    private static String ref(String base, Integer occ, Integer total) {
        return total == 1 ? base : base + '.' + occ;
    }

    private static AAO_Pair__c row(
        AAO_Source__c src,
        AAO_LocateCharter.Pair p,
        String runKey,
        String charterVersion,
        Map<String, Id> contractIdByCode,
        String pairRef,
        Integer occ,
        Integer occCount,
        Integer startOffset,
        Integer endOffset,
        String speakerKey
    ) {
        return new AAO_Pair__c(
            AAO_Stage__c = AAO_PairKey.LOCATED,
            AAO_Run_Key__c = runKey,
            AAO_Pair_Ref__c = pairRef,
            AAO_Charter__c = 'People',
            AAO_Charter_Version__c = charterVersion,
            AAO_Source__c = src.Id,
            AAO_Artifact_SHA256__c = src.AAO_SHA256__c,
            AAO_Evidence_Contract__c = contractIdByCode.get(p.questionCode),
            AAO_Answer_Text__c = p.answerText,
            AAO_Meaning__c = p.meaning,
            AAO_Coverage__c = p.coverage,
            AAO_Criterion_Name__c = p.criterionName,
            AAO_About_Designator__c = p.aboutWords,
            AAO_About_Quote__c = p.aboutQuote,
            AAO_Occurrence__c = occ,
            AAO_Occurrence_Count__c = occCount,
            AAO_Start_Offset__c = startOffset,
            AAO_End_Offset__c = endOffset,
            AAO_Speaker_Key__c = speakerKey
        );
    }

    /**
     * Every start offset at which `needle` occurs, in document order.
     *
     * OVERLAPPING MATCHES ARE NOT SOUGHT: the scan advances past the match it found. A
     * quote overlapping itself is a pathological case for a sentence of speech, and
     * counting one occurrence twice would make the ordinal lie about how often the words
     * were said, which is the one thing it is for.
     */
    @TestVisible
    private static List<Integer> occurrences(String haystack, String needle) {
        List<Integer> out = new List<Integer>();
        if (String.isBlank(needle)) {
            return out;
        }
        Integer cursor = 0;
        Integer at = haystack.indexOf(needle, cursor);
        while (at >= 0) {
            out.add(at);
            cursor = at + needle.length();
            at = haystack.indexOf(needle, cursor);
        }
        return out;
    }

    // =========================================================================== writing

    /**
     * The rows land. Separate from `locate` so the callout-then-DML order is a property of
     * the caller's sequence rather than something this class has to remember.
     */
    public static List<AAO_Pair__c> write(Located located) {
        if (located.rows.isEmpty()) {
            return located.rows;
        }
        insert located.rows;
        return located.rows;
    }
}
