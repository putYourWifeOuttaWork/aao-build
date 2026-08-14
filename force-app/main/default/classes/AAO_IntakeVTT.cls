/**
 * WebVTT intake. Twentieth stamp item 4, pulled to the front by the twenty-fifth: the WF
 * fixture is a `.vtt`, a raw form the intake has never ingested, and extending the matrix is
 * the format half of the mechanism test.
 *
 * **What it produces, and why it stops there.** This class turns raw WebVTT into the two
 * things a Source needs: the NF1 normalized text (`<speakerKey>\t<utterance>` per line, the
 * frozen read shape `AAO_NormalForm` documents) and the ordered speaker list the roster is
 * built from. It does NOT create the Source, resolve speakers to Contacts, or decide internal
 * versus external. Those are the ingest and participant layers' jobs and duplicating them here
 * would be a second copy of a rule that must have exactly one.
 *
 * **The format facts it handles, each because the WF fixture carries it:**
 * - the `WEBVTT` header line, discarded;
 * - `NOTE`, `STYLE` and `REGION` blocks, discarded from the transcript body (a NOTE roster is
 *   read separately by `roster()` where present, and its shape is documented there);
 * - cue blocks: an optional cue-identifier line, a `HH:MM:SS.mmm --> HH:MM:SS.mmm` timestamp
 *   line with optional trailing settings, then one or more payload lines;
 * - voice tags `<v Speaker Name>...`, including the class form `<v.loud Speaker Name>`, which
 *   is how a cue names its speaker; every other tag (`</v>`, `<c>`, `<i>`, inline timestamps
 *   `<00:00:01.000>`) is stripped from the utterance;
 * - SAME-SPEAKER CUE MERGING: consecutive cues voiced by one speaker become one turn, because
 *   the cadence of captions is not the cadence of speech and a span must lie inside one turn.
 *
 * **The one thing it cannot finalize without the bytes, stated rather than hidden.** The
 * NOTE-header roster's exact line shape is a property of the specific file. `roster()` parses
 * the documented shape and returns empty where it does not match, so the caller learns the
 * roster was not read rather than getting a wrong one. Speaker KEYS always come from the voice
 * tags and are never guessed.
 */
public class AAO_IntakeVTT {
    public class IntakeException extends Exception {
    }

    public class Result {
        /** The NF1 body, ready for AAO_Normalized_Text__c. */
        public String normalizedText;
        /** Distinct speaker keys, in first-appearance order. */
        public List<String> speakerKeys = new List<String>();
        /** Every merged turn's speaker, parallel to the composed lines. For the record. */
        public Integer turnCount = 0;
        /** Cues read, before merging. The merge ratio is a cheap sanity signal. */
        public Integer cueCount = 0;
        public String diarization = 'Attributed';
    }

    /** display name -> what the NOTE roster said about them, where it said anything. */
    public class RosterEntry {
        public String display;
        public String email;
        public String title;
    }

    // ---------------------------------------------------------------- the transcript body

    public static Result parse(String rawVtt) {
        if (String.isBlank(rawVtt)) {
            throw new IntakeException('Empty WebVTT input. Nothing to normalize.');
        }
        // Normalize line endings first, so \r\n and \r never leak into a span. WebVTT is
        // defined over \n; a stray \r inside an utterance would be a byte the check trips on.
        String text = rawVtt.replace('\r\n', '\n').replace('\r', '\n');

        if (!text.trim().startsWith('WEBVTT')) {
            throw new IntakeException(
                'Not WebVTT: the stream must begin with the WEBVTT signature. Refusing to ' +
                'guess a format rather than normalize the wrong bytes.'
            );
        }

        Result r = new Result();
        List<String> mergedSpeakers = new List<String>();
        List<String> mergedUtterances = new List<String>();

        // Blocks are separated by one or more blank lines.
        for (String block : text.split('\n[ \t]*\n')) {
            String trimmed = block.trim();
            if (String.isBlank(trimmed)) {
                continue;
            }
            String firstLine = trimmed.split('\n')[0].trim();
            if (firstLine == 'WEBVTT' || firstLine.startsWith('WEBVTT ') ||
                firstLine == 'NOTE' || firstLine.startsWith('NOTE ') ||
                firstLine == 'STYLE' || firstLine.startsWith('STYLE') ||
                firstLine == 'REGION' || firstLine.startsWith('REGION')) {
                continue;
            }
            Cue cue = readCue(trimmed);
            if (cue == null) {
                continue;
            }
            r.cueCount++;

            // SAME-SPEAKER MERGE. A cue with no speaker of its own inherits the running one,
            // which is the multi-line-caption case: only the first line of a run carries <v>.
            if (String.isBlank(cue.speaker)) {
                if (mergedUtterances.isEmpty()) {
                    // A leading cue with no speaker at all. Attributed text cannot carry an
                    // unnamed turn without breaking the speaker requirement, so it is dropped
                    // and counted, never guessed at.
                    continue;
                }
                mergedUtterances[mergedUtterances.size() - 1] += ' ' + cue.utterance;
                continue;
            }
            if (!mergedSpeakers.isEmpty() &&
                mergedSpeakers[mergedSpeakers.size() - 1] == cue.speaker) {
                mergedUtterances[mergedUtterances.size() - 1] += ' ' + cue.utterance;
                continue;
            }
            mergedSpeakers.add(cue.speaker);
            mergedUtterances.add(cue.utterance);
            if (!r.speakerKeys.contains(cue.speaker)) {
                r.speakerKeys.add(cue.speaker);
            }
        }

        if (mergedUtterances.isEmpty()) {
            throw new IntakeException(
                'No cues with an attributable speaker were found. A WebVTT file whose cues ' +
                'carry no voice tags cannot be normalized as Attributed.'
            );
        }

        r.turnCount = mergedUtterances.size();
        r.normalizedText = AAO_NormalForm.compose(mergedSpeakers, mergedUtterances);
        return r;
    }

    private class Cue {
        String speaker;
        String utterance;
    }

    private static Cue readCue(String block) {
        List<String> lines = block.split('\n');
        Integer i = 0;

        // Optional cue identifier: any line before the timestamp that is not itself a
        // timestamp. WebVTT allows one, and it is discarded.
        if (i < lines.size() && !lines[i].contains('-->')) {
            i++;
        }
        if (i >= lines.size() || !lines[i].contains('-->')) {
            // No timestamp line. Not a cue.
            return null;
        }
        i++; // consume the timestamp line

        String runningSpeaker = null;
        List<String> parts = new List<String>();
        for (; i < lines.size(); i++) {
            String payload = lines[i];
            String voiced = speakerOf(payload);
            if (voiced != null) {
                runningSpeaker = voiced;
            }
            String u = stripTags(payload).trim();
            if (String.isNotBlank(u)) {
                parts.add(u);
            }
        }
        if (parts.isEmpty()) {
            return null;
        }
        Cue c = new Cue();
        c.speaker = runningSpeaker;
        c.utterance = String.join(parts, ' ');
        return c;
    }

    /**
     * The speaker a payload line names, or null. Handles `<v Name>` and `<v.class Name>`.
     * Everything from the first space inside the tag to the closing `>` is the name.
     */
    private static String speakerOf(String payload) {
        Integer open = payload.indexOf('<v');
        if (open < 0) {
            return null;
        }
        Integer close = payload.indexOf('>', open);
        if (close < 0) {
            return null;
        }
        String vtag = payload.substring(open + 2, close); // after "<v"
        Integer space = vtag.indexOf(' ');
        if (space < 0) {
            // "<v>" or "<vSomething>" with no name. Not a usable voice tag.
            return null;
        }
        String name = vtag.substring(space + 1).trim();
        return String.isBlank(name) ? null : name;
    }

    /** Remove every `<...>` run. Utterances carry words, never markup. */
    private static String stripTags(String s) {
        if (s == null) {
            return '';
        }
        List<String> keep = new List<String>();
        Boolean inTag = false;
        for (Integer i = 0; i < s.length(); i++) {
            String ch = s.substring(i, i + 1);
            if (ch == '<') {
                inTag = true;
            } else if (ch == '>') {
                inTag = false;
            } else if (!inTag) {
                keep.add(ch);
            }
        }
        return String.join(keep, '');
    }

    // ---------------------------------------------------------------- the NOTE roster

    /**
     * Parse a NOTE roster block, where the file carries one, into display -> RosterEntry.
     *
     * **Documented shape, and the reason it is tolerant.** The block is a `NOTE` whose body
     * lines each name one speaker. Two forms are read, because a hand-authored fixture and a
     * captured export write it differently:
     * - `Display Name <email@domain> | Title`
     * - `Display Name | email@domain | Title`
     * Missing email or title is fine; a line that matches neither shape is skipped, not
     * guessed. Where no NOTE roster is present this returns empty, and the caller must learn
     * the emails another way rather than receive fabricated ones.
     */
    public static Map<String, RosterEntry> roster(String rawVtt) {
        Map<String, RosterEntry> out = new Map<String, RosterEntry>();
        if (String.isBlank(rawVtt)) {
            return out;
        }
        String text = rawVtt.replace('\r\n', '\n').replace('\r', '\n');
        for (String block : text.split('\n[ \t]*\n')) {
            String trimmed = block.trim();
            String firstLine = trimmed.split('\n')[0].trim();
            if (firstLine != 'NOTE' && !firstLine.startsWith('NOTE ')) {
                continue;
            }
            List<String> lines = trimmed.split('\n');
            for (Integer i = 1; i < lines.size(); i++) {
                RosterEntry e = readRosterLine(lines[i].trim());
                if (e != null) {
                    out.put(e.display, e);
                }
            }
        }
        return out;
    }

    private static RosterEntry readRosterLine(String line) {
        if (String.isBlank(line)) {
            return null;
        }
        // Form A: Display <email> | Title  (title optional)
        if (line.contains('<') && line.contains('>')) {
            Integer lt = line.indexOf('<');
            Integer gt = line.indexOf('>', lt);
            String display = line.substring(0, lt).trim();
            String email = line.substring(lt + 1, gt).trim();
            if (String.isBlank(display) || !email.contains('@')) {
                return null;
            }
            RosterEntry e = new RosterEntry();
            e.display = display;
            e.email = email.toLowerCase();
            String tail = line.substring(gt + 1).trim();
            if (tail.startsWith('|')) {
                e.title = tail.substring(1).trim();
            } else if (String.isNotBlank(tail)) {
                e.title = tail;
            }
            return e;
        }
        // Form B: Display | email | Title
        if (line.contains('|')) {
            List<String> cols = line.split('\\|');
            String display = cols[0].trim();
            if (String.isBlank(display)) {
                return null;
            }
            RosterEntry e = new RosterEntry();
            e.display = display;
            if (cols.size() > 1 && cols[1].contains('@')) {
                e.email = cols[1].trim().toLowerCase();
            }
            if (cols.size() > 2 && String.isNotBlank(cols[2])) {
                e.title = cols[2].trim();
            }
            return e;
        }
        return null;
    }
}