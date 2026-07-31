/**
 * Structurally valid Ids without DML, so the frozen key composers can be tested as
 * pure functions. Id.valueOf accepts the 15-character form and Apex widens it to 18,
 * which is exactly the widening the composers have to be immune to.
 */
@IsTest
public class AAO_FakeId {
    private static Integer counter = 0;

    public static Id of(Schema.SObjectType t) {
        return of(t.getDescribe().getKeyPrefix());
    }

    public static Id of(String keyPrefix) {
        counter++;
        String tail = String.valueOf(counter);
        return Id.valueOf(keyPrefix + '0'.repeat(12 - tail.length()) + tail);
    }

    /** The same record, expressed the short way. */
    public static Id shortForm(Id full) {
        return Id.valueOf(String.valueOf(full).substring(0, 15));
    }
}
