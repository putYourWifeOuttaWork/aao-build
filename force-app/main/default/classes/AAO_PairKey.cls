/**
 * The frozen composer for AAO_Pair__c.AAO_Pair_Key__c.
 *
 * Shape:  <Run Key, 32>|<Pair Ref, 32>|<Stage, 1>
 * Budget: 32 + 1 + 32 + 1 + 1 = 67, which is exactly Text(67). The field length is the
 *         arithmetic, so a shape change here is a field-length change. Same forcing
 *         function as AAO_ContractKey, and for the same reason.
 *
 * THE STAGE IS IN THE KEY, and that is the point. One-for-one-for-one says every located
 * pair receives exactly one disposition from call 2. With the stage in the key, a second
 * identification of the same pair collides on a unique index. The arithmetic is enforced
 * by the platform rather than by a count query, so it cannot race, cannot be forgotten by
 * a new caller, and does not need to be remembered at every write site.
 *
 * The run key is in the key because the arithmetic is per run. Two runs over the same
 * artifact emit the same pair refs and mean different things.
 */
public class AAO_PairKey {
    public class KeyException extends Exception {
    }

    public static final String SEP = '|';

    public static final String LOCATED = 'Located';
    public static final String IDENTIFIED = 'Identified';

    private static final Map<String, String> STAGE_CHAR = new Map<String, String>{
        LOCATED => 'L',
        IDENTIFIED => 'I'
    };

    public static String compose(String runKey, String pairRef, String stage) {
        if (String.isBlank(runKey)) {
            throw new KeyException(
                'Cannot compose a pair key with no run key. The one-for-one-for-one ' +
                'arithmetic is per run and meaningless across runs.'
            );
        }
        if (runKey.length() > 32) {
            throw new KeyException(
                'A run key is at most 32 characters; got ' + runKey.length() + '.'
            );
        }
        if (String.isBlank(pairRef)) {
            throw new KeyException(
                'Cannot compose a pair key with no pair ref. The ref is how call 2\'s ' +
                'disposition binds to call 1\'s pair, and binding by position is the ' +
                'defect this build already paid for once in the refusal grading.'
            );
        }
        if (pairRef.length() > 32) {
            throw new KeyException(
                'A pair ref is at most 32 characters; got ' + pairRef.length() + '.'
            );
        }
        if (runKey.contains(SEP) || pairRef.contains(SEP)) {
            throw new KeyException(
                'Neither a run key nor a pair ref may contain "' + SEP + '", or two ' +
                'different pairs could compose the same key.'
            );
        }
        String c = STAGE_CHAR.get(stage);
        if (c == null) {
            throw new KeyException(
                'A pair key needs a stage of ' + LOCATED + ' or ' + IDENTIFIED +
                '; got ' + stage + '. The stage is explicit by ruling and is never ' +
                'inferred from whether the parent lookup is null.'
            );
        }
        return runKey + SEP + pairRef + SEP + c;
    }

    public static String compose(AAO_Pair__c p) {
        return compose(p.AAO_Run_Key__c, p.AAO_Pair_Ref__c, p.AAO_Stage__c);
    }
}