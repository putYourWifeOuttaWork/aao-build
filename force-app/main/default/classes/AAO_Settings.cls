/**
 * THE ORG-OVERRIDABLE SETTINGS READER. One shipped default, one subscriber override, and the
 * override wins only where it was actually set.
 *
 * The shape is the role-map pattern the ontology already uses (`AAO_People_Question`), and the
 * one subtlety is why the override is a picklist rather than a checkbox: **a checkbox cannot
 * express "untouched".** With a shipped default of ON and a checkbox override, an admin who
 * had never opened the record would be indistinguishable from one who had deliberately
 * unticked it, and the customer could never turn the thing off. Blank means untouched; On and
 * Off both mean somebody decided.
 */
public with sharing class AAO_Settings {
    /**
     * MAY WE CREATE A CONTACT for a person who appears in the evidence and has none?
     *
     * **Default ON. Matthew's ruling, 5 August, Addendum 19; design recommended OFF and both
     * are recorded** - design's case was that creating records in a customer's CRM on install
     * day is the write an InfoSec review asks about first, and that an org which wanted it
     * could turn it on knowingly. Matthew's ruling is that a person in the evidence with no
     * Contact is unreachable on the map, and shipping unreachable-by-default makes the map
     * thin for exactly the customers with the least existing data.
     *
     * The toggle governs CREATION only. Toggle off, and the person still gets a shadow row,
     * still carries claims and answers, and still cannot reach the Altify map, because that
     * map row requires a Contact. Shadow persons are permanent for a toggle-off org.
     */
    public static final String CONTACT_CREATION = 'Contact_Creation';

    /** Test seam. A metadata type cannot be inserted in a test, so the value is injectable. */
    @TestVisible
    private static Map<String, Boolean> overrideForTest = new Map<String, Boolean>();

    private static Map<String, Boolean> cache = new Map<String, Boolean>();

    public static Boolean isOn(String developerName) {
        if (overrideForTest.containsKey(developerName)) {
            return overrideForTest.get(developerName);
        }
        if (cache.containsKey(developerName)) {
            return cache.get(developerName);
        }

        Boolean value = false;
        List<AAO_Setting__mdt> rows = [
            SELECT AAO_Shipped_Default__c, AAO_Org_Override__c
            FROM AAO_Setting__mdt
            WHERE DeveloperName = :developerName
            LIMIT 1
        ];
        if (!rows.isEmpty()) {
            AAO_Setting__mdt row = rows[0];
            // Blank override means untouched, and an untouched org gets our default.
            value = String.isBlank(row.AAO_Org_Override__c)
                ? row.AAO_Shipped_Default__c == true
                : row.AAO_Org_Override__c == 'On';
        }
        // A missing row reads OFF, which is the safe direction for anything governing a write
        // into a customer's own records: an absent setting must never be read as permission.
        cache.put(developerName, value);
        return value;
    }

    public static Boolean mayCreateContacts() {
        return isOn(CONTACT_CREATION);
    }
}