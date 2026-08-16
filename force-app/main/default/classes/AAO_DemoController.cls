/**
 * THE ON-RECORD DEMO'S CONTROLLER · paste text, mint a Source, drive the pass, watch it run.
 *
 * The hundred-fourth stamp's item 1. Two jobs and nothing else: START a run against the
 * opportunity the user is looking at, and REPORT what the run has journalled so far.
 *
 * **REAL RECEIPTS ONLY.** The stamp is explicit and it is the whole integrity of the surface:
 * this reads `AAO_Run_Receipt__c` and the pass's own rows, and it never estimates, never
 * interpolates between stages, and never draws a stage as running because time has passed.
 * A stage appears when it has journalled a leg, and not before. **A progress bar that moves
 * on a timer is a lie with an animation.**
 *
 * **IT IS COMPONENTIZED FOR THE LIFT.** The stamp asks for the paste surface and the
 * visualization to come out standalone later, so this controller knows nothing about Lightning
 * beyond its annotations: it takes ids and text and returns plain DTOs. The same two methods
 * serve a record page today and an app tomorrow.
 *
 * WHAT IT DOES NOT DO, deliberately: it does not purge, it does not project on its own, it does
 * not write to any vendor object, and it cannot run against production, which is read-only
 * unconditionally and enforced far below this class.
 */
public with sharing class AAO_DemoController {
    /** One journalled stage, flattened for a surface that should not parse receipts itself. */
    public class StageView {
        @AuraEnabled public String stage;
        @AuraEnabled public Long wallMs;
        @AuraEnabled public Integer callouts;
        @AuraEnabled public Long worstCalloutMs;
        @AuraEnabled public Integer produced;
        @AuraEnabled public String cache;
        @AuraEnabled public String error;
        @AuraEnabled public Datetime at;
    }

    /** Where a run has got to, read entirely from rows the pass itself wrote. */
    public class RunView {
        @AuraEnabled public String runKey;
        @AuraEnabled public Id sourceId;
        @AuraEnabled public List<StageView> stages = new List<StageView>();
        @AuraEnabled public Long totalWallMs = 0;
        @AuraEnabled public Integer callouts = 0;
        @AuraEnabled public Long worstCalloutMs = 0;
        @AuraEnabled public String cacheState;
        /** True once the pass has journalled its last stage, or stopped with a reason. */
        @AuraEnabled public Boolean finished = false;
        @AuraEnabled public String stoppedBecause;
        // The ledger, live, so the surface shows evidence rather than only timings.
        @AuraEnabled public Integer located = 0;
        @AuraEnabled public Integer identified = 0;
        @AuraEnabled public Integer upheld = 0;
        @AuraEnabled public Integer refused = 0;
        @AuraEnabled public Integer claims = 0;
        @AuraEnabled public Integer answers = 0;
        @AuraEnabled public Integer cards = 0;
    }

    /**
     * Mint a Source from pasted text and start the pass against it.
     *
     * The run key carries the user and the minute so two people demoing at once cannot collide,
     * and so a run is traceable to who started it without a second object to record that.
     */
    @AuraEnabled
    public static RunView startRun(Id opportunityId, String text, String label, String roster) {
        if (opportunityId == null) {
            throw new AuraHandledException('No opportunity. This runs against a record.');
        }
        if (String.isBlank(text)) {
            throw new AuraHandledException(
                'Nothing pasted. The pass reads evidence; it does not invent any.'
            );
        }

        Opportunity opp = [
            SELECT Id, AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1
        ];

        String runKey =
            'demo-' + UserInfo.getUserId().left(8).toLowerCase() + '-' +
            System.now().format('yyyyMMddHHmmss');

        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = opp.Id,
            AAO_Account__c = opp.AccountId,
            // `AAO_Origin__c` is a RESTRICTED picklist carrying exactly {ECI, ingest}, which
            // the org refused a third value for on the first try. `ingest` is the honest one:
            // this text arrived through an intake surface rather than through the ECI
            // connector, and inventing an origin value to make a demo look distinct would put
            // a word in the provenance column that no connector ever wrote.
            AAO_Origin__c = 'ingest',
            AAO_Normalized_Text__c = text,
            AAO_Diarization__c = 'Attributed',
            AAO_Evidence_Occurred__c = System.now(),
            AAO_Meeting_Title__c = String.isBlank(label) ? null : label.abbreviate(120),
            // THE ROSTER IS SUPPLIED, NEVER READ OUT OF THE WORDS, and that is the
            // eighty-eighth stamp's roster law rather than a shortcut: "The side split never
            // comes from the VTT body and must not... It comes from `AAO_Speaker_Roster__c`,
            // structured JSON supplied at ingest." A connector supplies it from the meeting
            // platform's attendee metadata; a paste surface has to ask, because the one place
            // it may never come from is the transcript.
            //
            // The pass proved this the hard way on the first demo run: with no roster the
            // Source carried no participants and the resolution stage refused with "a Source
            // with none is an ingest defect" - a LAWFUL refusal, correctly stopping rather
            // than inventing a speaker.
            AAO_Speaker_Roster__c = rosterJson(roster)
        );
        // The artifact hash is the byte-provenance key every span is checked against, so it is
        // computed from the very bytes stored rather than supplied by the caller - the same
        // reason the normalizer stamp is writer-supplied and never caller-supplied.
        src.AAO_Artifact_SHA256__c = EncodingUtil.convertToHex(
            Crypto.generateDigest('SHA-256', Blob.valueOf(text))
        );
        src.AAO_Part_Index__c = 1;
        src.AAO_Part_Count__c = 1;
        insert src;

        System.enqueueJob(new AAO_PassQueueable(src.Id, runKey));

        RunView v = new RunView();
        v.runKey = runKey;
        v.sourceId = src.Id;
        return v;
    }

    /**
     * `key, Display Name, email` per line into the roster shape the intake already reads.
     *
     * The email is what decides internal versus external (`AAO_SpeakerRule.isInternal` reads
     * the domain and nothing else), so a line without one is carried as a speaker whose side
     * is unknown rather than guessed at from the name.
     */
    private static String rosterJson(String roster) {
        List<Object> speakers = new List<Object>();
        if (String.isNotBlank(roster)) {
            for (String line : roster.split('\n')) {
                List<String> parts = line.split(',');
                if (parts.isEmpty() || String.isBlank(parts[0])) {
                    continue;
                }
                Map<String, Object> sp = new Map<String, Object>{
                    'key' => parts[0].trim(),
                    'display' => parts.size() > 1 && String.isNotBlank(parts[1])
                        ? parts[1].trim()
                        : parts[0].trim()
                };
                if (parts.size() > 2 && String.isNotBlank(parts[2])) {
                    sp.put('email', parts[2].trim());
                }
                speakers.add(sp);
            }
        }
        if (speakers.isEmpty()) {
            throw new AuraHandledException(
                'Who was on this call? One per line: key, Display Name, email. The side split ' +
                'comes from attendee metadata and never from the transcript body, so the pass ' +
                'refuses a Source with no participants rather than inventing them.'
            );
        }
        return JSON.serialize(new Map<String, Object>{ 'v' => 1, 'speakers' => speakers });
    }

    /**
     * What the run has journalled. Called on a poll; cheap and read-only by construction.
     *
     * `finished` is derived from the receipt's own last leg rather than from elapsed time,
     * because the only honest answer to "is it done" is "it wrote the last stage".
     */
    @AuraEnabled
    public static RunView progress(Id opportunityId, String runKey) {
        RunView v = new RunView();
        v.runKey = runKey;
        if (opportunityId == null || String.isBlank(runKey)) {
            return v;
        }

        AAO_Run_Receipt__c row = AAO_Receipt.forRun(opportunityId, runKey);
        if (row != null) {
            v.totalWallMs = row.AAO_Total_Wall_Ms__c == null
                ? 0
                : row.AAO_Total_Wall_Ms__c.longValue();
            v.callouts = row.AAO_Callouts__c == null ? 0 : row.AAO_Callouts__c.intValue();
            v.worstCalloutMs = row.AAO_Worst_Callout_Ms__c == null
                ? 0
                : row.AAO_Worst_Callout_Ms__c.longValue();
            v.cacheState = row.AAO_Cache_State__c;
            for (AAO_Receipt.Leg leg : AAO_Receipt.legsOf(row)) {
                StageView s = new StageView();
                s.stage = leg.stage;
                s.wallMs = leg.wallMs;
                s.callouts = leg.callouts;
                s.worstCalloutMs = leg.worstCalloutMs;
                s.produced = leg.produced;
                s.cache = leg.cache;
                s.error = leg.error;
                s.at = leg.at;
                v.stages.add(s);
                if (String.isNotBlank(leg.error)) {
                    v.stoppedBecause = leg.stage + ' — ' + leg.error;
                    v.finished = true;
                }
                if (leg.stage == AAO_Receipt.STAGE_CARDS) {
                    v.finished = true;
                }
            }
        }

        for (AggregateResult ar : [
            SELECT AAO_Stage__c stage, AAO_Verification__c ver, COUNT(Id) n
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey
            GROUP BY AAO_Stage__c, AAO_Verification__c
        ]) {
            Integer n = (Integer) ar.get('n');
            if ((String) ar.get('stage') == AAO_PairKey.LOCATED) {
                v.located += n;
                continue;
            }
            v.identified += n;
            String ver = (String) ar.get('ver');
            if (ver == 'Upheld') {
                v.upheld += n;
            } else if (ver != null) {
                v.refused += n;
            }
        }

        v.claims = [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Opportunity__c = :opportunityId];
        v.answers = [SELECT COUNT() FROM AAO_Answer__c WHERE AAO_Opportunity__c = :opportunityId];
        v.cards = [
            SELECT COUNT() FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = :opportunityId
        ];
        return v;
    }
}
