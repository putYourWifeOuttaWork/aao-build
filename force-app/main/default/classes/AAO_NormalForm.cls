/**
 * The frozen normal form for AAO_Normalized_Text__c, and the turn segmentation every
 * contiguity check reads.
 *
 * NORMAL FORM v1
 * --------------
 * Attributed and Segmented: one turn per line, `<speakerKey>\t<utterance>`, lines
 * separated by \n, no trailing newline. The utterance region of a turn is everything
 * after the tab up to but not including the newline. A span must lie inside exactly one
 * utterance region: it may not cross a newline and it may not reach back into the
 * speaker prefix.
 *
 * Unsegmented: no turns. The whole document is one region, which is why an unsegmented
 * artifact can carry verifiable spans and still cannot satisfy any speaker requirement
 * beyond Any_Participant.
 *
 * Offsets are character offsets into the whole normalized text, zero-based and
 * end-exclusive, and they include the speaker prefix region in their arithmetic. That is
 * deliberate: an offset means the same thing whatever the diarization, so span
 * verification never has to know which shape it is looking at to do the byte compare.
 *
 * This class is a stand-in for the real normaliser, which does not exist yet. What is
 * frozen here is the READ side: whatever writes AAO_Normalized_Text__c must produce this
 * shape, because every span already stored was verified against it.
 */
public class AAO_NormalForm {
    public static final String VERSION = 'NF1';

    /**
     * THE NORMALIZER STAMP COMPOSES. Ruled 7 August, the two-halves provenance law reaching
     * normalization: a version string that does not cover an input which changes the output is
     * decoration.
     *
     * **The defect it closes, from the freeze list:** both 29 July rows carried
     * `AAO_Normalizer_Version__c = NF1` with different artifact hashes. One version, two byte
     * outputs, and the stamp could not tell the fixture from its predecessor.
     *
     * **The composed stamp guarantees what the ruling asks structurally**: two different byte
     * outputs cannot carry identical stamps, because the hash is part of the stamp.
     *
     * **The prefix says which half answered**, the same anti-silent-default shape as the
     * occasion key. `NF1+raw:` is the ruled form, composed from what we normalized FROM, and it
     * is the one that distinguishes two normalizations of one input. `NF1+out:` is the fallback
     * for rows whose raw input we never recorded, composed from the output's own bytes: it
     * still cannot collide across different outputs, and it cannot tell you that two rows came
     * from one raw input, which is exactly the weaker claim the prefix is there to make.
     */
    public static String stamp(String rawSha, String outputSha) {
        if (String.isNotBlank(rawSha)) {
            return VERSION + '+raw:' + rawSha.left(8);
        }
        if (String.isNotBlank(outputSha)) {
            return VERSION + '+out:' + outputSha.left(8);
        }
        return VERSION;
    }

    public class Turn {
        public String speakerKey;
        /** Region of the utterance itself, excluding the speaker prefix and the tab. */
        public Integer utteranceStart;
        public Integer utteranceEnd;
        public String utterance;
    }

    /**
     * Turns in document order. Unsegmented text yields a single turn with a null
     * speaker covering the whole document.
     */
    public static List<Turn> turns(String normalizedText, String diarization) {
        List<Turn> out = new List<Turn>();
        if (normalizedText == null) {
            return out;
        }

        if (diarization == 'Unsegmented') {
            Turn t = new Turn();
            t.speakerKey = null;
            t.utteranceStart = 0;
            t.utteranceEnd = normalizedText.length();
            t.utterance = normalizedText;
            out.add(t);
            return out;
        }

        Integer cursor = 0;
        for (String line : normalizedText.split('\n', -1)) {
            Integer lineStart = cursor;
            cursor += line.length() + 1; // + the newline that split consumed

            Integer tab = line.indexOf('\t');
            if (tab < 0) {
                // A line with no speaker prefix in an attributed artifact is a defect in
                // the normaliser, not something to guess at. It contributes no turn, so
                // any span over it fails contiguity and says so.
                continue;
            }
            Turn t = new Turn();
            t.speakerKey = line.substring(0, tab);
            t.utteranceStart = lineStart + tab + 1;
            t.utteranceEnd = lineStart + line.length();
            t.utterance = line.substring(tab + 1);
            out.add(t);
        }
        return out;
    }

    /** The turn containing the whole range, or null if the range crosses or misses one. */
    public static Turn containing(List<Turn> turns, Integer startOffset, Integer endOffset) {
        for (Turn t : turns) {
            if (startOffset >= t.utteranceStart && endOffset <= t.utteranceEnd) {
                return t;
            }
        }
        return null;
    }

    /**
     * Compose normalized text from turns. Used by seeding so the fixtures and the
     * verifier cannot disagree about the shape.
     */
    public static String compose(List<String> speakerKeys, List<String> utterances) {
        if (speakerKeys.size() != utterances.size()) {
            throw new IllegalArgumentException(
                'Speaker keys and utterances must be the same length.'
            );
        }
        List<String> lines = new List<String>();
        for (Integer i = 0; i < speakerKeys.size(); i++) {
            lines.add(speakerKeys[i] + '\t' + utterances[i]);
        }
        return String.join(lines, '\n');
    }

    public static String sha256(String text) {
        return EncodingUtil.convertToHex(
            Crypto.generateDigest('SHA-256', Blob.valueOf(text == null ? '' : text))
        );
    }
}
