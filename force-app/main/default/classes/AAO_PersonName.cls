/**
 * THE DETERMINISTIC NAME PARSE. Addendum 19's requirement travelling with the create leg:
 * **Contact creation never writes the mangled roster string as the name.**
 *
 * The 17 June fixture's specimen is `Vargas, Jefferson [EMR/SYSS/AT/MEDI]` - an ECI display
 * form carrying a surname, a given name and an internal org path, in that order. Writing it
 * into `LastName` would put a routing code on a customer record, on a person the seller then
 * has to recognise, forever, and the record is one we created rather than one they typed. A
 * name is the one field a human reads first.
 *
 * **DETERMINISTIC, AND THAT IS THE WHOLE LICENCE TO DO IT AT ALL.** No model reads a name
 * here. The shapes below are recognised by structure, not by judgment, so the same string
 * always parses the same way and the parse is replayable by anyone holding the source form.
 * Where the structure is not recognised the parse REFUSES rather than guessing, and a refusal
 * is what holds the person at shadow stage instead of inventing a person.
 *
 * **THE SOURCE STRING IS KEPT.** `AAO_Shadow_Person__c.AAO_Source_Name__c` carries what
 * arrived, mangled and all, per the stored-form law - wrong text is marked wrong, never
 * deleted. Two practical reasons beyond the law: this parse is ours and can be wrong, and
 * re-deriving a name is only possible while what it was derived from still exists; and ASR
 * mangles names in the roster itself (Stacey to "Tracy", Claude to "clogged"), so the source
 * form is the audit trail on every identity decision downstream of it.
 */
public with sharing class AAO_PersonName {
    /** A parsed name, or a refusal carrying its reason. */
    public class Parsed {
        public String first;
        public String last;
        public String display;
        /** The shape that matched, for the record. Null where nothing did. */
        public String shape;
        public String refusedBecause;

        public Boolean ok() {
            return String.isNotBlank(last);
        }

        public override String toString() {
            return ok()
                ? display + ' [' + shape + ']'
                : 'REFUSED: ' + refusedBecause;
        }
    }

    /**
     * The bracketed suffix an ECI display name carries: `[EMR/SYSS/AT/MEDI]`, an internal org
     * path and never part of anybody's name. Stripped first, before any shape is tested,
     * because it would otherwise make every shape below look like it had an extra token.
     */
    private static final String BRACKETED = '\\s*\\[[^\\]]*\\]\\s*';

    /**
     * Titles and suffixes that are not names. Deliberately short: a long list starts making
     * judgments about what a name can be, and this method's whole claim is that it does not.
     */
    private static final Set<String> DROPPABLE = new Set<String>{
        'mr', 'mrs', 'ms', 'miss', 'dr', 'prof', 'sir',
        'jr', 'sr', 'ii', 'iii', 'iv', 'phd', 'md'
    };

    public static Parsed parse(String raw) {
        Parsed p = new Parsed();
        if (String.isBlank(raw)) {
            p.refusedBecause = 'no name arrived at all';
            return p;
        }

        String cleaned = raw.replaceAll(BRACKETED, ' ').trim().replaceAll('\\s+', ' ');
        if (String.isBlank(cleaned)) {
            p.refusedBecause =
                'the whole string was a bracketed org path, so nothing of it is a name: "' +
                raw + '"';
            return p;
        }

        // SHAPE 1: "Last, First" - the ECI form and the one the fixture carries. The comma is
        // the structure; there is no judgment in reading it.
        if (cleaned.contains(',')) {
            List<String> halves = cleaned.split(',', 2);
            String last = clean(halves[0]);
            String first = halves.size() > 1 ? clean(halves[1]) : null;
            if (String.isNotBlank(last)) {
                p.last = last;
                p.first = first;
                p.shape = 'Last, First';
                p.display = compose(p);
                return p;
            }
        }

        // SHAPE 2: "First Last" or "First Middle Last" - the last token is the surname and
        // everything before it is the given name. Two tokens or more.
        List<String> tokens = new List<String>();
        for (String t : cleaned.split(' ')) {
            String c = clean(t);
            if (String.isNotBlank(c)) {
                tokens.add(c);
            }
        }
        if (tokens.size() >= 2) {
            p.last = tokens[tokens.size() - 1];
            List<String> given = new List<String>();
            for (Integer i = 0; i < tokens.size() - 1; i++) {
                given.add(tokens[i]);
            }
            p.first = String.join(given, ' ');
            p.shape = tokens.size() == 2 ? 'First Last' : 'First Middle Last';
            p.display = compose(p);
            return p;
        }

        // SHAPE 3: one token. A surname alone is a real thing a roster carries, and Contact
        // needs only a LastName, so this is a name rather than a refusal.
        if (tokens.size() == 1) {
            p.last = tokens[0];
            p.shape = 'single token';
            p.display = compose(p);
            return p;
        }

        // NOTHING MATCHED. Refusing rather than guessing: the person holds at shadow stage,
        // which is a real and permanent state, and no Contact is invented for them.
        p.refusedBecause =
            'no recognised name shape in "' + raw + '", so no Contact name can be composed ' +
            'from it deterministically';
        return p;
    }

    /** Strip a droppable title or suffix, and the punctuation that usually rides with it. */
    private static String clean(String token) {
        if (token == null) {
            return null;
        }
        String t = token.trim();
        String bare = t.replaceAll('[.,]', '').toLowerCase();
        return DROPPABLE.contains(bare) ? '' : t.replaceAll('^[.,]+|[.,]+$', '').trim();
    }

    private static String compose(Parsed p) {
        return String.isBlank(p.first) ? p.last : p.first + ' ' + p.last;
    }
}
