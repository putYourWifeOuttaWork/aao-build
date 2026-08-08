/**
 * ECI viewer-paste intake. Twenty-sixth stamp: Project Farma's raw is a new shape, the ECI
 * conversation-viewer copy, and extending the matrix is the same deterministic class as the
 * WebVTT parser.
 *
 * **The shape, read from the real bytes (`75917ba2…`), each rule because the file carries it:**
 * - NUMBERED BLOCKS: every turn is prefixed `N. `; the numbering is stripped;
 * - PLAYER LINES: `N. Move the player to <seconds> seconds in the call`, a viewer control,
 *   discarded, with the speaker header on the following line;
 * - SPEAKER HEADERS in two orders glued to a timestamp: `Adam Pfeiffer01:05` (First Last) and
 *   `Lewis, Dan00:37` (Last, First), unified to First Last so one human is one key; the
 *   timestamp is `[h]h:mm:ss` late in the call and `mm:ss` early, always glued to the name
 *   with no space, which is how a header is told from an utterance that merely contains a time;
 * - ECI TOPIC TAGS: classifier labels on their own line between header and utterance
 *   ("Go To Market Tech Stack Discussion", "AI Tools and Automation Mentioned", "Product",
 *   "Next Step", "License Count or Usage Discussion"), sometimes carrying a "(N)" count and
 *   sometimes several concatenated with no separator; stripped only where a line reduces
 *   ENTIRELY to known tags, so a tag word inside real speech is never eaten;
 * - SAME-SPEAKER MERGING: consecutive blocks by one speaker become one turn, the same rule the
 *   VTT parser makes, because viewer cadence is not speech cadence and a span lies in one turn.
 *
 * **What it does NOT do, the same boundary as the VTT parser:** it does not create the Source,
 * resolve speakers to Contacts, or decide internal versus external. Speaker KEYS come only from
 * the header text; nothing is guessed.
 *
 * **The known-tag vocabulary is fixture-derived, and its home is named rather than assumed.**
 * ECI's full topic taxonomy is org-specific classifier output; this list is what this file
 * carries, and its permanent home is the same org-overridable seed metadata already owed at
 * packaging as the internal-domain and title-synonym lists. A tag this list does not know is
 * kept as utterance rather than dropped, which is the safe direction to be wrong in.
 */
public class AAO_IntakeECI {
    public class IntakeException extends Exception {
    }

    public class Result {
        public String normalizedText;
        public List<String> speakerKeys = new List<String>();
        public Integer turnCount = 0;
        public Integer blockCount = 0;
        public Integer tagLinesDropped = 0;
        public Integer playerLinesDropped = 0;
        public String diarization = 'Attributed';
    }

    private static final List<String> TOPIC_TAGS = new List<String>{
        // Longest first, so a greedy strip consumes the largest tag before its prefix.
        'License Count or Usage Discussion',
        'Go To Market Tech Stack Discussion',
        'AI Tools and Automation Mentioned',
        'Next Step',
        'Product'
    };

    private static final Pattern NUMBER_PREFIX = Pattern.compile('^\\d+\\.\\s+');
    // A header is a name glued to a trailing timestamp, no space between them.
    private static final Pattern HEADER =
        Pattern.compile('^([\\p{L}][\\p{L} .,\'\\-]*[\\p{L}])(\\d{1,2}:\\d{2}(?::\\d{2})?)$');

    public static Result parse(String rawEci) {
        if (String.isBlank(rawEci)) {
            throw new IntakeException('Empty ECI paste. Nothing to normalize.');
        }
        String text = rawEci.replace('\r\n', '\n').replace('\r', '\n');

        Result r = new Result();
        List<String> mergedSpeakers = new List<String>();
        List<String> mergedUtterances = new List<String>();
        String current = null;

        for (String rawLine : text.split('\n')) {
            String line = rawLine;

            // Strip a leading "N. " and remember whether it was a numbered block.
            Matcher nm = NUMBER_PREFIX.matcher(line);
            String content = line;
            Boolean numbered = false;
            if (nm.lookingAt()) {
                content = line.substring(nm.end());
                numbered = true;
            }
            String forClass = content.trim();

            if (forClass.startsWith('Move the player to')) {
                if (numbered) {
                    r.playerLinesDropped++;
                }
                continue;
            }

            String speaker = headerSpeaker(forClass);
            if (speaker != null) {
                r.blockCount++;
                if (!mergedSpeakers.isEmpty() &&
                    mergedSpeakers[mergedSpeakers.size() - 1] == speaker) {
                    // consecutive same speaker: keep appending to the open turn
                    current = speaker;
                    continue;
                }
                mergedSpeakers.add(speaker);
                mergedUtterances.add('');
                current = speaker;
                if (!r.speakerKeys.contains(speaker)) {
                    r.speakerKeys.add(speaker);
                }
                continue;
            }

            // Not a player line and not a header: a topic tag or an utterance.
            if (current == null) {
                continue; // preamble before the first speaker
            }
            if (isPureTagLine(forClass)) {
                r.tagLinesDropped++;
                continue;
            }
            String u = line.trim();
            if (String.isBlank(u)) {
                continue;
            }
            Integer last = mergedUtterances.size() - 1;
            mergedUtterances[last] = String.isBlank(mergedUtterances[last])
                ? u
                : mergedUtterances[last] + ' ' + u;
        }

        // Drop any turn that never gathered an utterance (a header with only tags under it).
        List<String> keptSpeakers = new List<String>();
        List<String> keptUtterances = new List<String>();
        for (Integer i = 0; i < mergedSpeakers.size(); i++) {
            if (String.isNotBlank(mergedUtterances[i])) {
                keptSpeakers.add(mergedSpeakers[i]);
                keptUtterances.add(mergedUtterances[i]);
            }
        }
        if (keptUtterances.isEmpty()) {
            throw new IntakeException('No attributable turns found in the ECI paste.');
        }
        r.turnCount = keptUtterances.size();
        r.normalizedText = AAO_NormalForm.compose(keptSpeakers, keptUtterances);
        return r;
    }

    /** The speaker a header line names, unified to First Last, or null if not a header. */
    private static String headerSpeaker(String s) {
        Matcher m = HEADER.matcher(s);
        if (!m.matches()) {
            return null;
        }
        return unify(m.group(1).trim());
    }

    /** "Last, First" -> "First Last"; "First Last" unchanged. One human, one key. */
    private static String unify(String name) {
        Integer comma = name.indexOf(',');
        if (comma < 0) {
            return name;
        }
        String last = name.substring(0, comma).trim();
        String first = name.substring(comma + 1).trim();
        if (String.isBlank(first) || String.isBlank(last)) {
            return name;
        }
        return first + ' ' + last;
    }

    /**
     * True where the line reduces ENTIRELY to known topic tags (with optional "(N)" counts
     * and no-separator concatenation). A line with any residue is kept as utterance, so a tag
     * word appearing inside real speech is never dropped.
     */
    private static Boolean isPureTagLine(String line) {
        String s = line.replaceAll('\\s*\\(\\d+\\)', '').trim();
        if (String.isBlank(s)) {
            return false;
        }
        for (String tag : TOPIC_TAGS) {
            s = s.replace(tag, '');
        }
        return String.isBlank(s.trim());
    }
}
