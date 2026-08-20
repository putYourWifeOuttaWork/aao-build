/**
 * MATCH, NEVER MINT: the criterion half of the identity ruling. Process step (e).
 *
 * The hundred-twenty-fourth, and it is sharper than the card rule rather than looser:
 *
 * > *"A criterion voiced by a DIFFERENT mouth is the SAME criterion reinforced - match-not-mint
 * > against the deal's standing criterion list, name variance resolved at write time. The SAME
 * > mouth restating the SAME criterion is IGNORED - no row, no counter theater."*
 *
 * ===== WHY THIS IS ITS OWN STAGE, which is the only structural decision in the class.
 *
 * The match is a MEANING judgment. Measured on the graded Wells Fargo deal, four of fifteen
 * standing criteria are duplicates and the pairs defeat every string rule there is:
 *
 *     "Closed model risk approval"          / "Model risk approval closed, not pending"
 *     "Per-question citation status"        / "Per-question citation traceability"
 *     "Model risk documentation set"        / "Model risk documentation set per version"
 *     "Pilot evidence measures"             / "Pilot evidence on three measures"
 *
 * The last is F3's own specimen and the only cross-mouth one; **three of the four are the same
 * person saying it twice**, which is the half the ruling says must write nothing at all. And a
 * threshold tuned to catch these is loose enough to merge strangers - the hundred-eighth already
 * refused that trade on the card grain and it is the same trade here.
 *
 * So a model call, against a CLOSED LIST. It cannot ride the join, because the join mints the
 * criteria and **a callout after DML is fatal on this platform** - the single most load-bearing
 * constraint this build has. It cannot ride call 3 either: the verifier is blind by law and
 * handing it a standing list would end that. So it is one stage of its own, between verify and
 * the join, spending one callout on runs that name criteria and none on runs that do not.
 *
 * **PREVENTION, NOT REPAIR** (hundred-sixteenth): the duplicate stops being minted rather than
 * being merged afterwards on a row the customer has already read.
 */
public with sharing class AAO_CriterionMatch {
    public static final String VERSION = 'criterion-match-1.0.0';
    public static final String NONE = 'NONE';
    public static final String STAGE = 'criterion match';

    public class Outcome {
        public Integer considered = 0;
        public Integer matched = 0;
        public Integer sameMouth = 0;
        public Integer fresh = 0;
        public List<String> notes = new List<String>();

        public override String toString() {
            return 'criterion match: ' + considered + ' considered, ' + matched + ' matched (' +
                sameMouth + ' same mouth), ' + fresh + ' new (unit: naming pairs)';
        }
    }

    @TestVisible
    private static Map<Id, Id> stubbed;

    /**
     * Resolve every upheld naming pair on this run against the deal's standing criteria, and
     * leave the answer on the pair for the join to read.
     *
     * Zero callouts where nothing names a criterion, and zero where the deal has no standing
     * criteria to match against - a closed list with nothing in it is not a question.
     */
    public static Outcome run(String runKey) {
        Outcome o = new Outcome();
        List<AAO_Pair__c> namings = [
            SELECT Id, AAO_Pair_Ref__c, AAO_Person__c,
                   AAO_Located_Pair__r.AAO_Criterion_Name__c,
                   AAO_Located_Pair__r.AAO_Source__r.AAO_Opportunity__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey
              AND AAO_Stage__c = :AAO_PairKey.IDENTIFIED
              AND AAO_Disposition__c = 'Identified'
              AND AAO_Verification__c = 'Upheld'
              AND AAO_Evidence_Contract__r.AAO_Proposition_Code__c = :AAO_P8Codes.CRITERION_NAMING
              AND AAO_Located_Pair__r.AAO_Criterion_Name__c != null
        ];
        if (namings.isEmpty()) {
            return o;
        }
        o.considered = namings.size();

        Id opportunityId = namings[0].AAO_Located_Pair__r.AAO_Source__r.AAO_Opportunity__c;
        Map<Id, AAO_Criterion__c> standing = new Map<Id, AAO_Criterion__c>([
            SELECT Id, AAO_Subject__c, AAO_Voiced_By__c
            FROM AAO_Criterion__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Retired__c = false
        ]);
        if (standing.isEmpty()) {
            o.fresh = namings.size();
            o.notes.add(
                'This deal carries no standing criteria, so there is nothing to match against ' +
                'and no call was made. Every naming on this run is new by construction.'
            );
            return o;
        }

        calls = new List<AAO_Extract.StageResult>();
        Map<Id, Id> resolved = stubbed != null ? stubbed : ask(namings, standing.values());
        // The leg, so a stage that spends a callout can be priced. A stage with no leg is a
        // stage nobody can measure, which is why every other one has had one since the receipt.
        AAO_Receipt.record(runKey, AAO_Receipt.sourceForRun(runKey), STAGE, calls, null, 0);

        List<AAO_Pair__c> patch = new List<AAO_Pair__c>();
        for (AAO_Pair__c p : namings) {
            Id match = resolved.get(p.Id);
            AAO_Pair__c row = new AAO_Pair__c(Id = p.Id);
            if (match == null || !standing.containsKey(match)) {
                o.fresh++;
                patch.add(row);
                continue;
            }
            row.AAO_Criterion_Match__c = match;
            // SAME MOUTH IS A DIFFERENT DISPOSITION, so it travels with the match rather than
            // being recomputed by the join from rows it would have to re-read.
            Boolean same = p.AAO_Person__c != null &&
                p.AAO_Person__c == standing.get(match).AAO_Voiced_By__c;
            row.AAO_Criterion_Match_Same_Mouth__c = same;
            o.matched++;
            if (same) {
                o.sameMouth++;
            }
            o.notes.add(
                p.AAO_Pair_Ref__c + ': "' + p.AAO_Located_Pair__r.AAO_Criterion_Name__c +
                '" is the standing criterion "' + standing.get(match).AAO_Subject__c + '"' +
                (same
                    ? ', and the same mouth said both, so it writes nothing.'
                    : ', voiced by a different mouth, so it reinforces rather than minting.')
            );
            patch.add(row);
        }
        if (!patch.isEmpty()) {
            update patch;
        }
        return o;
    }

    // ====================================================================== the call

    /** The stage's own calls, collected so the leg prices the whole stage rather than a shard. */
    private static List<AAO_Extract.StageResult> calls;

    private static Map<Id, Id> ask(
        List<AAO_Pair__c> namings, List<AAO_Criterion__c> standing
    ) {
        Map<Id, Id> out = new Map<Id, Id>();
        List<String> choices = new List<String>{ NONE };
        List<String> menu = new List<String>();
        for (AAO_Criterion__c c : standing) {
            choices.add(String.valueOf(c.Id));
            menu.add(String.valueOf(c.Id) + ' = "' + c.AAO_Subject__c + '"');
        }

        Integer cap = AAO_Pass.MAX_UNITS_PER_KEYED_CALL;
        Integer shards = AAO_Pass.keyedShardCount(namings.size());
        for (Integer i = 0; i < shards; i++) {
            List<AAO_Pair__c> shard = new List<AAO_Pair__c>();
            for (Integer j = i * cap; j < Math.min((i + 1) * cap, namings.size()); j++) {
                shard.add(namings[j]);
            }
            if (!shard.isEmpty()) {
                out.putAll(askShard(shard, choices, menu, i + 1, shards));
            }
        }
        return out;
    }

    private static Map<Id, Id> askShard(
        List<AAO_Pair__c> namings,
        List<String> choices,
        List<String> menu,
        Integer shardNo,
        Integer shardCount
    ) {
        Map<Id, Id> out = new Map<Id, Id>();
        Map<String, Object> props = new Map<String, Object>();
        List<String> required = new List<String>();
        List<String> block = new List<String>();
        block.add('STANDING CRITERIA ON THIS DEAL:');
        block.addAll(menu);
        block.add('');
        block.add('NEWLY VOICED, one per line:');
        for (AAO_Pair__c p : namings) {
            String key = p.Id;
            block.add(key + ': "' + p.AAO_Located_Pair__r.AAO_Criterion_Name__c + '"');
            props.put(key, new Map<String, Object>{
                'type' => 'string',
                'enum' => choices,
                'description' => 'The id of the standing criterion this one ALREADY IS, or ' +
                    NONE + '.'
            });
            required.add(key);
        }
        if (required.isEmpty()) {
            return out;
        }

        AAO_Extract.Config cfg = AAO_Extract.config();
        AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
        spec.stage = 'criterion_match';
        spec.charter = 'AAO_CriterionMatch';
        spec.charterVersion = VERSION;
        spec.model = cfg.verifyModel;
        spec.effort = null;
        spec.temperature = cfg.verifyTemperature;

        try {
            AAO_Extract.StageResult r = AAO_Extract.callStage(
                spec,
                systemPrompt(),
                new List<String>{ String.join(block, '\n') },
                new Map<String, Object>{
                    'type' => 'object',
                    'properties' => props,
                    'required' => required,
                    'additionalProperties' => false
                }
            );
            calls.add(r);
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(r.rawText);
            for (String ref : parsed.keySet()) {
                Object v = parsed.get(ref);
                if (v == null || String.valueOf(v) == NONE) {
                    continue;
                }
                try {
                    out.put(Id.valueOf(ref), Id.valueOf(String.valueOf(v)));
                } catch (Exception ignored) {
                    // Not an id is not a match. Nothing is guessed.
                }
            }
        } catch (Exception e) {
            // NOT FATAL, and the fallback is the honest one: an unmatched naming MINTS, which is
            // exactly what the writer did before this stage existed. A failed match costs a
            // duplicate a human can merge by eye; a guessed match costs a criterion nobody can
            // find again.
            System.debug(
                LoggingLevel.WARN,
                'Criterion match not resolved for shard ' + shardNo + ' of ' + shardCount +
                ': ' + e.getMessage()
            );
        }
        return out;
    }

    private static String systemPrompt() {
        return 'You decide whether a newly voiced decision criterion is one this deal ALREADY ' +
            'carries.\n\n' +
            'You are given the STANDING CRITERIA on the deal, each with an id, and one or more ' +
            'NEWLY VOICED criterion names. For each new one, return the id of the standing ' +
            'criterion it ALREADY IS, or ' + NONE + '.\n\n' +
            'A decision criterion is a condition that must be true for the buyer to decide ' +
            'yes.\n\n' +
            'RULES:\n' +
            '1. THE SAME CONDITION IN OTHER WORDS IS THE SAME CRITERION. "Closed model risk ' +
            'approval" and "Model risk approval closed, not pending" are one condition said ' +
            'twice. Two names can share almost no words and still be one criterion.\n' +
            '2. A NARROWER OR WIDER CONDITION IS A DIFFERENT CRITERION. "Model risk ' +
            'documentation set" and "Model risk documentation set per version" are one ' +
            'condition only if the second adds no requirement the first did not carry. Where it ' +
            'adds one, answer ' + NONE + '.\n' +
            '3. WHEN IN DOUBT, ' + NONE + '. Two criteria a person can merge by eye cost far ' +
            'less than one criterion that silently swallowed a condition nobody can now see.\n' +
            '4. Choose only from the ids listed. Never invent one.\n' +
            '5. Answer for every new name you are given, and nothing else.';
    }
}
