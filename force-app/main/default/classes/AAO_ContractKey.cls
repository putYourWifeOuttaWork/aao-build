/**
 * The frozen composer for AAO_Contract_Key__c.
 *
 * Shape:  <Question Record Id, 18>|<Content Hash, 64 lowercase hex>
 * Budget: 18 + 1 + 64 = 83, which is exactly Text(83). The field length is the
 *         arithmetic, which is why this composer carries no version token: there is no
 *         room for one. A shape change here is a field-length change, and that is the
 *         intended forcing function.
 *
 * Identity is the question record plus the hash of its proposition and guidance, so an
 * in-place edit of the authored text produces a new contract rather than mutating one.
 */
public class AAO_ContractKey {
    public class KeyException extends Exception {
    }

    public static final String SEP = '|';

    private static final Pattern LOWER_HEX_64 = Pattern.compile('^[0-9a-f]{64}$');

    public static String compose(String questionRecordId, String contentHash) {
        if (String.isBlank(questionRecordId)) {
            throw new KeyException(
                'Cannot compose a contract key with no question record id.'
            );
        }
        if (questionRecordId.length() > 18) {
            throw new KeyException(
                'A question record id is at most 18 characters; got ' +
                questionRecordId.length() +
                '.'
            );
        }
        if (String.isBlank(contentHash)) {
            throw new KeyException(
                'Cannot compose a contract key with no content hash. The hash is the ' +
                'only detector of an in-place edit.'
            );
        }
        if (!LOWER_HEX_64.matcher(contentHash).matches()) {
            throw new KeyException(
                'A content hash must be 64 lowercase hex characters.'
            );
        }
        return questionRecordId + SEP + contentHash;
    }

    public static String compose(AAO_Evidence_Contract__c ec) {
        return compose(ec.AAO_Question_Record_Id__c, ec.AAO_Content_Hash__c);
    }

    /**
     * The hash discovery computes: proposition text and guidance text, in that order,
     * separated by a record separator that cannot occur in either.
     */
    public static String contentHash(String propositionText, String guidanceText) {
        // ASCII record separator. It cannot occur in authored rubric text, so text
        // cannot be shifted across the boundary to forge the same hash.
        String rs = String.fromCharArray(new List<Integer>{ 30 });
        String joined =
            (propositionText == null ? '' : propositionText) +
            rs +
            (guidanceText == null ? '' : guidanceText);
        return EncodingUtil.convertToHex(
            Crypto.generateDigest('SHA-256', Blob.valueOf(joined))
        );
    }
}
