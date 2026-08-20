/**
 * THE CREATE-LEG RECORD'S WRITER. One call per machine-created org row, from every
 * create-capable leg, because A MACHINE-CREATED ROW WE CANNOT ENUMERATE IS A ROW WE CAN
 * NEVER DISOWN (twenty-first stamp item 6, shipped with the resolution rebuild per the
 * twenty-seventh). The record is the enumeration; disowning is a mark and a report on it,
 * never a deletion of the target.
 */
public with sharing class AAO_CreatedRows {
    public class CreatedRowException extends Exception {
    }

    public static final String LEG_ROSTER = 'roster-participant';
    public static final String LEG_MENTION = 'mentioned-person';

    public static AAO_Created_Row__c record(
        Id targetId,
        String sourceForm,
        String leg,
        String reason,
        Id sourceId,
        String runKey
    ) {
        if (targetId == null) {
            throw new CreatedRowException(
                'Cannot record a creation with no created row. The record exists to ' +
                'enumerate what was made; a null target enumerates nothing.'
            );
        }
        if (String.isBlank(reason)) {
            throw new CreatedRowException(
                'A creation with no stated reason is not recordable. The reason is the ' +
                'whole point of the record.'
            );
        }
        AAO_Created_Row__c row = new AAO_Created_Row__c(
            AAO_Target_Id__c = String.valueOf(targetId),
            AAO_Target_Object__c = String.valueOf(targetId.getSobjectType()),
            AAO_Source_Form__c = sourceForm == null ? null : sourceForm.abbreviate(255),
            AAO_Leg__c = leg,
            AAO_Reason__c = reason,
            AAO_Source__c = sourceId,
            AAO_Run_Key__c = runKey
        );
        insert row;
        return row;
    }

    /**
     * THE SAME RECORD, IN BULK, because one DML per created row does not fit the governor model.
     *
     * `DML ~ C + 9` against a ceiling of 150, and a fifteen-question assessment projected one
     * watermark at a time would spend fifteen statements enumerating what a single statement can
     * enumerate. Same refusals as `record`: no target is not recordable, and no reason is not
     * recordable, and here they throw on the FIRST offender rather than silently writing the
     * good ones, because a partial enumeration is the thing this record exists to prevent.
     */
    public static List<AAO_Created_Row__c> recordAll(
        List<Id> targetIds,
        String sourceForm,
        String leg,
        String reason,
        Id sourceId,
        String runKey
    ) {
        List<AAO_Created_Row__c> rows = new List<AAO_Created_Row__c>();
        if (targetIds == null || targetIds.isEmpty()) {
            return rows;
        }
        if (String.isBlank(reason)) {
            throw new CreatedRowException(
                'A creation with no stated reason is not recordable. The reason is the ' +
                'whole point of the record.'
            );
        }
        for (Id targetId : targetIds) {
            if (targetId == null) {
                throw new CreatedRowException(
                    'Cannot record a creation with no created row. The record exists to ' +
                    'enumerate what was made; a null target enumerates nothing.'
                );
            }
            rows.add(new AAO_Created_Row__c(
                AAO_Target_Id__c = String.valueOf(targetId),
                AAO_Target_Object__c = String.valueOf(targetId.getSobjectType()),
                AAO_Source_Form__c = sourceForm == null ? null : sourceForm.abbreviate(255),
                AAO_Leg__c = leg,
                AAO_Reason__c = reason,
                AAO_Source__c = sourceId,
                AAO_Run_Key__c = runKey
            ));
        }
        insert rows;
        return rows;
    }
}