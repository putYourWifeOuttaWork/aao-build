/**
 * THE CRITERIA LEDGER. Addendum 20: the criteria answer's subject is the criterion.
 *
 * **What this closes.** The answer key is subject plus contract, and the subject used to be the
 * person - so a buyer naming three criteria produced ONE answer on `AAO_DC_N` and two of the
 * three vanished with no counter reporting it. The criterion becomes the subject, one answer
 * row per criterion, and the person stays on the row as owner.
 *
 * **The three contracts describe one criterion between them.** `AAO_DC_N` names it, `AAO_DC_F`
 * types it by provenance, `AAO_DC_R` says whether failing it stops the purchase. Call 1 emits
 * them as separate pairs with no pointer between them, so **the join is byte range**: a typing
 * or gating pair belongs to the naming whose located span it overlaps. That is the same
 * mechanism the regression set already keys on, it is deterministic, and it is checkable
 * against the frozen artifact rather than against anything the model asserted. The a17 run's
 * own grading is the specimen - `deq1 [AAO_DC_N]` and `deq2 [AAO_DC_F]` are one quote at one
 * offset under two contracts.
 *
 * **A typing pair that overlaps no naming types nothing** and is reported rather than dropped
 * silently. It is not an error: the naming may have been refused at verification while the
 * typing was upheld, which is the two stages disagreeing about one sentence and is exactly the
 * thing a count should surface.
 */
public with sharing class AAO_Criteria {
    public class CriteriaException extends Exception {
    }

    /** The maximum the vendor's own Subject field holds, carried here so it can refuse. */
    public static final Integer SUBJECT_MAX = 255;

    /**
     * The criterion key: opportunity plus a content hash of the text, normalized for case and
     * whitespace ONLY.
     *
     * Normalizing further would start deciding that two differently-worded criteria are one
     * criterion, which is a judgment and not a key. Normalizing not at all would make "Must
     * pass InfoSec" and "must pass infosec " two criteria, which is a spelling difference
     * doing the work of a distinction. Case and whitespace is the line where the rule is still
     * mechanical.
     */
    public static String key(Id opportunityId, String subject) {
        if (opportunityId == null) {
            throw new CriteriaException(
                'Cannot key a criterion with no opportunity. A criterion is a deal artifact: ' +
                'every one of the 402 rows in production carries an Opportunity despite the ' +
                'vendor schema making it optional.'
            );
        }
        if (String.isBlank(subject)) {
            throw new CriteriaException('Cannot key a criterion with no text.');
        }
        String normalized = subject.toLowerCase().trim().replaceAll('\\s+', ' ');
        Blob digest = Crypto.generateDigest('SHA-256', Blob.valueOf(normalized));
        return String.valueOf(opportunityId) + '|' + EncodingUtil.convertToHex(digest).substring(0, 32);
    }

    /**
     * Upsert one criterion from a naming pair, and return the row.
     *
     * **The same criterion voiced on three calls is one criterion carrying three claims**, not
     * three criteria carrying one each. That is what makes reinforcement countable, and
     * guidance orders a person's criteria by what they have pressed most recently and most
     * often - an ordering that is a count of exactly those rows.
     *
     * **THE SUBJECT IS THE CRITERION'S NAME (twenty-seventh stamp)**: a descriptive phrase
     * stating the condition that must be true for the buyer to make the positive decision,
     * emitted by call 1 from the establishing words. It used to be the naming pair's meaning,
     * whose enum is closed at the literal word CRITERION - so every criterion in the org
     * keyed onto one row and the vendor displayed that word to the seller. The verbatim
     * establishing words stay on the pair and the claim; this is the label the key and the
     * vendor Subject carry.
     *
     * **A RETIRED ROW IS NEVER RESURRECTED.** The upsert would silently un-retire a row whose
     * key matches, so the retired row is checked first and refused loudly. Criteria retire,
     * never delete, and never quietly come back.
     */
    public static AAO_Criterion__c mint(
        String subject,
        Id opportunityId,
        Id accountId,
        Id participantId,
        Id sourceId,
        Datetime occurred
    ) {
        String text = subject == null ? null : subject.trim();
        if (String.isBlank(text)) {
            throw new CriteriaException('A criterion with no text is not a criterion.');
        }
        if (text.length() > SUBJECT_MAX) {
            // REFUSING RATHER THAN TRUNCATING. The vendor's Subject field holds 255 and is
            // what its interface displays; a clipped criterion would read as the buyer's
            // words while being ours, which is the edge of the paraphrase law.
            throw new CriteriaException(
                'A criterion of ' + text.length() + ' characters exceeds the ' + SUBJECT_MAX +
                ' the vendor\'s Subject field holds. Truncating would publish a sentence the ' +
                'buyer did not say under their name.'
            );
        }

        String criterionKey = key(opportunityId, text);
        List<AAO_Criterion__c> standing = [
            SELECT Id, AAO_Retired__c
            FROM AAO_Criterion__c
            WHERE AAO_Criterion_Key__c = :criterionKey
            LIMIT 1
        ];
        if (!standing.isEmpty() && standing[0].AAO_Retired__c) {
            throw new CriteriaException(
                'Criterion key ' + criterionKey + ' ("' + text + '") belongs to a RETIRED ' +
                'row. Upserting would silently un-retire it. If this criterion is real ' +
                'again, that is a human decision about the retired row, not a mint.'
            );
        }

        AAO_Criterion__c row = new AAO_Criterion__c(
            AAO_Criterion_Key__c = criterionKey,
            AAO_Subject__c = text,
            AAO_Opportunity__c = opportunityId,
            AAO_Account__c = accountId,
            AAO_Voiced_By__c = participantId,
            AAO_Source__c = sourceId,
            AAO_Evidence_Occurred__c = occurred,
            AAO_Synthetic__c = AAO_Synthetic.MARK
        );
        if (deferring) {
            // DEDUPED BY KEY, LAST WINS, which is what the per-row upsert did. A bulk upsert
            // REFUSES duplicate external ids in one call, and two naming pairs can name the
            // same criterion, so the map is required rather than tidy. Both callers get the
            // SAME instance back, so both see the Id the flush writes onto it.
            AAO_Criterion__c held = pending.get(criterionKey);
            if (held == null) {
                pending.put(criterionKey, row);
                return row;
            }
            held.AAO_Subject__c = row.AAO_Subject__c;
            held.AAO_Voiced_By__c = row.AAO_Voiced_By__c;
            held.AAO_Source__c = row.AAO_Source__c;
            held.AAO_Evidence_Occurred__c = row.AAO_Evidence_Occurred__c;
            return held;
        }
        Database.upsert(row, AAO_Criterion__c.AAO_Criterion_Key__c, true);
        return row;
    }

    // ============================================ THE DEFERRED MINT, one statement per run
    //
    // `mint` is called once per naming pair inside the join's loop, and its single-row upsert
    // was four of the 133 DML statements s3's join spent. Same contract as
    // `AAO_Commit`'s buffer: a caller that opens no batch gets the per-row behaviour byte for
    // byte, and the retired-row guard above still runs per call because it is a read.
    private static Boolean deferring = false;
    private static Map<String, AAO_Criterion__c> pending = new Map<String, AAO_Criterion__c>();

    public static void beginDeferred() {
        deferring = true;
        pending = new Map<String, AAO_Criterion__c>();
    }

    /** Returns the DML statements spent: one, or none when nothing was minted. */
    public static Integer flushDeferred() {
        Integer stmts = 0;
        if (!pending.isEmpty()) {
            Database.upsert(
                pending.values(),
                AAO_Criterion__c.AAO_Criterion_Key__c,
                true
            );
            stmts++;
        }
        deferring = false;
        pending = new Map<String, AAO_Criterion__c>();
        return stmts;
    }

    // ------------------------------------------------------- the byte-range join

    /** A located span, reduced to what the overlap test needs. */
    public class Span {
        public Id sourceId;
        public Integer startOffset;
        public Integer endOffset;

        public Span(Id sourceId, Decimal startOffset, Decimal endOffset) {
            this.sourceId = sourceId;
            this.startOffset = startOffset == null ? null : Integer.valueOf(startOffset);
            this.endOffset = endOffset == null ? null : Integer.valueOf(endOffset);
        }

        /**
         * Byte-range intersection against the frozen artifact, never the stored string. Two
         * spans overlap where they share the same Source and any byte at all: a typing clause
         * sits inside the sentence that named the criterion, so containment and partial
         * overlap are both the same evidence.
         */
        public Boolean overlaps(Span other) {
            if (other == null || sourceId != other.sourceId) {
                return false;
            }
            if (startOffset == null || endOffset == null ||
                other.startOffset == null || other.endOffset == null) {
                return false;
            }
            return startOffset < other.endOffset && other.startOffset < endOffset;
        }
    }

    /**
     * Which naming a typing or gating pair belongs to, by byte range. Null where none
     * overlaps, which the caller counts rather than swallows.
     */
    public static Integer namingFor(Span typing, List<Span> namings) {
        if (typing == null || namings == null) {
            return null;
        }
        for (Integer i = 0; i < namings.size(); i++) {
            if (typing.overlaps(namings[i])) {
                return i;
            }
        }
        return null;
    }
}