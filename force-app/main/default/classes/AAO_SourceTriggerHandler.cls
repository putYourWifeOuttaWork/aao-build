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
