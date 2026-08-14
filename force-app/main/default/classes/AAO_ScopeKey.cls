/**
 * The frozen composer for AAO_Scope_Key__c. Uniqueness is deal plus fingerprint plus
 * part, so the same call attached to two deals is two Sources and a split artifact is
 * several.
 *
 * Deterministic, frozen, versioned, single-writer, case-sensitive. Not a formula field,
 * for the same reason AAO_AnswerKey is not.
 *
 * Shape:  S1|<Opportunity Id, 18>|<Artifact SHA-256, 64 lowercase hex>|<Part Index>
 * Budget: 2 + 1 + 18 + 1 + 64 + 1 + 3 = 90 of the 101 the field allows.
 */
public class AAO_ScopeKey {
    public class KeyException extends Exception {
    }

    public static final String VERSION = 'S1';
    public static final String SEP = '|';

    private static final Pattern LOWER_HEX_64 = Pattern.compile('^[0-9a-f]{64}$');

    public static String compose(Id scopeId, String artifactSha, Integer partIndex) {
        if (scopeId == null) {
            throw new KeyException(
                'Cannot compose a scope key with no scope. An empty rendering would ' +
                'collide every unscoped Source onto one key.'
            );
        }
        if (String.isBlank(artifactSha)) {
            throw new KeyException(
                'Cannot compose a scope key with no artifact fingerprint. Without it the ' +
                'Source cannot be deduplicated.'
            );
        }
        if (artifactSha.length() != 64) {
            throw new KeyException(
                'An artifact fingerprint must be 64 characters; got ' +
                artifactSha.length() +
                '.'
            );
        }
        if (!LOWER_HEX_64.matcher(artifactSha).matches()) {
            // Rejected rather than folded on purpose. Folding would be a silent
            // transform on identity; accepting both cases would make one artifact
            // capable of producing two Sources.
            String why = artifactSha.toLowerCase() == artifactSha
                ? 'it is not hex'
                : 'it is not lowercase';
            throw new KeyException(
                'An artifact fingerprint must be 64 lowercase hex characters, but ' +
                why +
                '.'
            );
        }
        if (partIndex == null) {
            throw new KeyException(
                'Cannot compose a scope key with no part index. The field defaults to 1; ' +
                'a null here is a defect upstream.'
            );
        }
        if (partIndex < 1) {
            throw new KeyException('Part index is one-based; got ' + partIndex + '.');
        }
        return VERSION +
            SEP +
            String.valueOf(scopeId) +
            SEP +
            artifactSha +
            SEP +
            String.valueOf(partIndex);
    }

    public static String compose(AAO_Source__c s) {
        return compose(
            s.AAO_Opportunity__c,
            s.AAO_Artifact_SHA256__c,
            s.AAO_Part_Index__c == null ? null : s.AAO_Part_Index__c.intValue()
        );
    }
}