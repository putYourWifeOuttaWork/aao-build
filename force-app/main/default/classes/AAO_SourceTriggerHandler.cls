/**
 * Source immutability, and the frozen scope-key composer.
 *
 * Source is what every span is byte-verified against. A transcript edited after a span
 * was verified against it breaks the citation chain silently, which is the exact failure
 * immutability exists to prevent. So the words, the fingerprints, the clock and the key
 * are frozen at insert.
 *
 * Two fields are deliberately mutable: AAO_Substantive_Offset__c and
 * AAO_Boundary_Basis__c. Small talk is marked, never cut, and the boundary is mutable so
 * a better detector can re-mark with no re-ingestion. Neither is ever read by span
 * verification.
 */
public class AAO_SourceTriggerHandler {
    private static final Set<String> FROZEN = new Set<String>{
        'AAO_Normalized_Text__c',
        'AAO_Diarization__c',
        'AAO_Speaker_Roster__c',
        'AAO_SHA256__c',
        'AAO_Artifact_SHA256__c',
        'AAO_Scope_Key__c',
        'AAO_Part_Index__c',
        'AAO_Part_Count__c',
        'AAO_Evidence_Occurred__c',
        'AAO_Opportunity__c',
        'AAO_Account__c',
        'AAO_Origin__c',
        'AAO_Normalizer_Version__c'
    };

    public static void beforeInsert(List<AAO_Source__c> rows) {
        for (AAO_Source__c s : rows) {
            s.AAO_Synthetic__c = AAO_Synthetic.MARK;
            if (s.AAO_Part_Index__c == null) {
                s.AAO_Part_Index__c = 1;
            }
            // Single writer. A caller-supplied key is not trusted, because a key composed
            // anywhere but here is a second composer.
            s.AAO_Scope_Key__c = AAO_ScopeKey.compose(s);

            // SHA determinism, RULED: the normalized-text fingerprint is computed by this code
            // path from the received bytes, unconditionally, and is never a step any caller
            // performs. A caller-supplied value is overwritten rather than trusted, for the same
            // reason the scope key is.
            //
            // This closes a real gap by construction. The B&V Casey Source was inserted without
            // one, the field is immutable by law, and the three laws that then refused to let it
            // be corrected were each right: immutable field, dedup on bytes, Sources leave by
            // retirement. **No immutability exception exists or will.** The recorded history
            // stays; the condition cannot recur, because omitting the value is no longer
            // something a caller is able to do.
            s.AAO_SHA256__c = AAO_NormalForm.sha256(s.AAO_Normalized_Text__c);

            // THE STAMP IS WRITER-SUPPLIED, NEVER CALLER-SUPPLIED. Ruled 8 August after the
            // a23 suite found `theSmallTalkBoundaryStaysMutable` failing on a field the test
            // never touches.
            //
            // The mechanism, measured rather than reasoned about: a before-insert trigger's
            // field changes are NOT synced back to the caller's in-memory sObject (only the
            // Id is). So a caller that assigns this field holds `NF1` while the row holds
            // `NF1+out:...`, the stale value stays in the sObject's field map, and the
            // caller's NEXT update - of any field at all - submits it and is refused by the
            // immutability guard below for a change nobody made.
            //
            // The scope key and the output hash never had this problem for one reason: no
            // caller assigns them, so they are absent from the field map and an update never
            // carries them. THAT is the property, and it is what "writer-supplied" means
            // here - not "computed by us", which they all already were, but "the caller has
            // no value of it to go stale".
            //
            // So a caller-supplied stamp FAILS LOUDLY rather than being silently overwritten.
            // Overwriting is what created the stale copy; refusing the write is the only
            // form of this rule that cannot recreate it, and it keeps the caller's sObject
            // exactly as the caller left it.
            if (String.isNotBlank(s.AAO_Normalizer_Version__c)) {
                s.addError(
                    'AAO_Normalizer_Version__c is written by AAO_SourceTriggerHandler and ' +
                    'must not be supplied by a caller. A supplied value cannot be overwritten ' +
                    'safely: before-insert changes are not synced back to the caller\'s ' +
                    'sObject, so the caller would keep a stale stamp and its next update of ' +
                    'ANY field would be refused as an immutability violation. Leave the field ' +
                    'null and the writer composes it.'
                );
                continue;
            }
            // The stamp composes, so two different byte outputs can never carry the same
            // one. Computed after the output hash above, because it is one of its halves.
            s.AAO_Normalizer_Version__c =
                AAO_NormalForm.stamp(s.AAO_Raw_SHA256__c, s.AAO_SHA256__c);
        }
    }

    /**
     * Evidence has landed. Adjudication follows, asynchronously, so a governor limit in the
     * pipeline can never roll back the arrival of the artifact itself.
     */
    public static void afterInsert(List<AAO_Source__c> rows) {
        // WHO WAS ON IT, recorded synchronously and unconditionally. Ruled v1.1.
        //
        // Not behind AAO_Ingest.AUTO and not in the queueable, because participation is a
        // fact about the ARRIVAL of evidence rather than a product of adjudicating it. A
        // deal that never runs a pipeline pass still knows who was on its calls, and
        // coverage is answerable the moment the artifact lands.
        AAO_Participants.record(rows, AAO_IngestQueueable.internalDomains());

        AAO_Ingest.onSourceInserted(rows);
    }

    public static void beforeUpdate(List<AAO_Source__c> rows, Map<Id, AAO_Source__c> oldById) {
        for (AAO_Source__c s : rows) {
            AAO_Source__c old = oldById.get(s.Id);
            for (String f : FROZEN) {
                if (s.get(f) != old.get(f)) {
                    s.addError(
                        f +
                        ' is immutable on AAO_Source__c. Every span already stored was ' +
                        'byte-verified against this record; editing it breaks the citation ' +
                        'chain without anything appearing to fail. Re-ingest as a new ' +
                        'Source instead.'
                    );
                    break;
                }
            }
        }
    }

    public static void beforeDelete(List<AAO_Source__c> rows) {
        for (AAO_Source__c s : rows) {
            if (AAO_Synthetic.deletable(s.AAO_Synthetic__c)) {
                continue;
            }
            s.addError(
                'AAO_Source__c is not deletable on the live path. Claims cite it and spans ' +
                'verify against it. Sources leave by retirement, confirm-then-purge, ' +
                'library acknowledgement first.'
            );
        }
    }
}