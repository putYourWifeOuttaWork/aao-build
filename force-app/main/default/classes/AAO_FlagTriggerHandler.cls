/**
 * Flag's trigger law: type is set at birth and never changes.
 *
 * Type determines two independent things — how the flag can be cleared, and how it is
 * measured. Nothing downstream reconstructs a flag's origin to know how to treat it, so a
 * type that could move would silently change both. Colour is display, derived from type;
 * nothing reasons about colour and there is no colour field.
 *
 * No delete on the live path. A deletion of a subject never clears a flag: it empties the
 * answer's subject, the condition reverts to UNVERIFIED, and the ordinary machinery raises
 * the ordinary flag. No gesture on any rendering clears anything.
 *
 * Nothing raises flags yet. This law exists ahead of the raise path so that when the raise
 * path arrives it cannot quietly write a mutable type.
 */
public class AAO_FlagTriggerHandler {
    public static void beforeInsert(List<AAO_Flag__c> rows) {
        for (AAO_Flag__c f : rows) {
            f.AAO_Synthetic__c = AAO_Synthetic.MARK;
            if (f.AAO_Raised_At__c == null) {
                f.AAO_Raised_At__c = System.now();
            }
            if (String.isBlank(f.AAO_State__c)) {
                f.AAO_State__c = 'Standing';
            }
        }
    }

    public static void beforeUpdate(List<AAO_Flag__c> rows, Map<Id, AAO_Flag__c> oldById) {
        for (AAO_Flag__c f : rows) {
            AAO_Flag__c old = oldById.get(f.Id);
            if (f.AAO_Type__c != old.AAO_Type__c) {
                f.addError(
                    'AAO_Type__c is immutable after insert. Type determines how a flag can ' +
                    'be cleared and how it is measured, and nothing downstream ' +
                    'reconstructs a flag\'s origin to know how to treat it. Raise a new ' +
                    'flag instead.'
                );
                continue;
            }
            if (f.AAO_Raised_At__c != old.AAO_Raised_At__c) {
                f.addError(
                    'AAO_Raised_At__c is immutable. It is what age is measured from, and on ' +
                    'a gating proposition it is opportunity creation.'
                );
            }
        }
    }

    public static void beforeDelete(List<AAO_Flag__c> rows) {
        for (AAO_Flag__c f : rows) {
            if (AAO_Synthetic.deletable(f.AAO_Synthetic__c)) {
                continue;
            }
            f.addError(
                'AAO_Flag__c is not deletable on the live path. A flag is cleared by ' +
                'evidence, by written acknowledgement, or by approval, according to its ' +
                'type. Deleting one destroys the measurement it exists to produce.'
            );
        }
    }
}
