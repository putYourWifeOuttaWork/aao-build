/**
 * The synthetic marker, and the only door through which synthetic rows can leave.
 *
 * Rows written by the rehearsal are marked at insert, by the triggers, from MARK. Nothing
 * in the design reads the marker — it carries no meaning about evidence — but anyone
 * looking at this org needs to be able to tell a rehearsal row from a real one without
 * asking, and the QBR artifact has to be removable in one action.
 *
 * PURGING is the narrow exception to Source and Claim being undeletable. It is narrow on
 * purpose: the handlers allow a delete only when PURGING is true AND the row itself is
 * marked synthetic, so a real claim cannot be deleted even with the flag on. The general
 * retirement path — confirm-then-purge, library acknowledgement first — is still owed and
 * this is not it.
 */
public class AAO_Synthetic {
    /** Set by AAO_Demo around its writes. Triggers stamp AAO_Synthetic__c from it. */
    public static Boolean MARK = false;

    /** Set by AAO_Demo.purge only. Permits deletion of marked rows, and nothing else. */
    public static Boolean PURGING = false;

    /** True where this row may be deleted by the purge path. */
    public static Boolean deletable(Boolean rowIsSynthetic) {
        return PURGING && rowIsSynthetic == true;
    }
}