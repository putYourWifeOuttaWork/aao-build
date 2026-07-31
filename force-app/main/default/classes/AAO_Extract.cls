/**
 * The first real model call. Reads one Source, sends the rubric and the artifact to the
 * model named in AAO_Model_Config__mdt, and returns proposals.
 *
 * WHAT THIS CLASS IS ALLOWED TO PRODUCE: proposals, in memory. It writes nothing. It has no
 * DML in it at all, and that is structural rather than incidental. A callout cannot follow
 * DML in the same Apex transaction, so a class that both calls out and writes would have to
 * order itself carefully forever; a class that cannot write cannot get that wrong. Every row
 * that results from a model call is written by AAO_Pipeline, through the same builder the
 * fixture path uses, and judged by the same gates.
 *
 * THE KEY IS NOT HERE, and cannot be. The endpoint and the credential are named in custom
 * metadata, resolved to callout:AAO_Anthropic/..., and the Named Credential substitutes the
 * secret into the x-api-key header after this code has finished constructing the request.
 * Nothing in this class, in a debug log of this class, or in an exception thrown by this
 * class can contain the key.
 *
 * TOKENS ARE RETURNED, NOT LOGGED. usage.input_tokens and usage.output_tokens come back on
 * the Result so the caller can put them in the journal and the proof register. A cost
 * measurement that is not attributable to a named model and a named charter version is not
 * a measurement, which is why the config record carries both and both are stamped on the
 * Result next to the numbers.
 */
public class AAO_Extract {
    public class ExtractException extends Exception {
    }

    /** Apex will not honour a longer timeout than this, whatever the config says. */
    private static final Integer PLATFORM_TIMEOUT_CEILING_MS = 120000;

    // =========================================================================== config

    public class Config {
        public String modelName;
        public String charter;
        public String charterVersion;
        public String namedCredential;
        public String endpointPath;
        public String anthropicBeta;
        public String effort;
        public Integer maxOutputTokens;
        public Integer timeoutMs;
        public Boolean active;

        public String endpoint() {
            return 'callout:' + namedCredential + endpointPath;
        }
    }

    @TestVisible
    private static Config overrideConfig;

    public static Config config() {
        if (overrideConfig != null) {
            return overrideConfig;
        }
        List<AAO_Model_Config__mdt> rows = [
            SELECT
                AAO_Model_Name__c,
                AAO_Charter__c,
                AAO_Charter_Version__c,
                AAO_Named_Credential__c,
                AAO_Endpoint_Path__c,
                AAO_Anthropic_Beta__c,
                AAO_Effort__c,
                AAO_Max_Output_Tokens__c,
                AAO_Timeout_Ms__c,
                AAO_Active__c
            FROM AAO_Model_Config__mdt
            WHERE DeveloperName = 'Default'
            LIMIT 1
        ];
        if (rows.isEmpty()) {
            // Deliberately fatal. A default baked into Apex would be the hardcoded model
            // name that the config record exists to prevent, and it would be invisible in
            // exactly the case where knowing which model ran matters most.
            throw new ExtractException(
                'No AAO_Model_Config__mdt record named Default. The model name and charter ' +
                'version are configuration, and there is no fallback on purpose.'
            );
        }
        AAO_Model_Config__mdt r = rows[0];
        Config c = new Config();
        c.modelName = r.AAO_Model_Name__c;
        c.charter = r.AAO_Charter__c;
        c.charterVersion = r.AAO_Charter_Version__c;
        c.namedCredential = r.AAO_Named_Credential__c;
        c.endpointPath = r.AAO_Endpoint_Path__c;
        c.anthropicBeta = r.AAO_Anthropic_Beta__c;
        c.effort = r.AAO_Effort__c;
        c.maxOutputTokens = Integer.valueOf(r.AAO_Max_Output_Tokens__c);
        c.timeoutMs = Integer.valueOf(r.AAO_Timeout_Ms__c);
        c.active = r.AAO_Active__c;
        return c;
    }

    // =========================================================================== result

    public class Usage {
        public Integer inputTokens = 0;
        public Integer outputTokens = 0;
        public Integer cacheReadTokens = 0;
        public Integer cacheCreationTokens = 0;

        public Integer billableInput() {
            return inputTokens + cacheCreationTokens;
        }

        public override String toString() {
            return 'in=' +
                inputTokens +
                ' out=' +
                outputTokens +
                ' cacheRead=' +
                cacheReadTokens +
                ' cacheWrite=' +
                cacheCreationTokens;
        }
    }

    public class Result {
        public Id sourceId;
        public String sourceRef;
        /** Keyed by proposition code. Every contract asked about appears exactly once. */
        public Map<String, AAO_ExtractCharter.Finding> findings;
        public Usage usage = new Usage();
        /** The model that actually answered, as reported by the API, not as requested. */
        public String modelReported;
        public String stopReason;
        public String charter;
        public String charterVersion;
        public Long elapsedMs;
        public Integer promptChars;
        /** Codes we asked about that came back missing. Should always be empty. */
        public List<String> unanswered = new List<String>();

        public override String toString() {
            return 'EXTRACT ' +
                sourceRef +
                ' model=' +
                modelReported +
                ' charter=' +
                charter +
                '@' +
                charterVersion +
                ' findings=' +
                (findings == null ? 0 : findings.size()) +
                ' ' +
                usage +
                ' ms=' +
                elapsedMs +
                ' stop=' +
                stopReason +
                (unanswered.isEmpty() ? '' : ' UNANSWERED=' + unanswered);
        }
    }

    // ============================================================================== run

    /**
     * One artifact, every proposition in the rubric, one call.
     *
     * Contracts are read, never created. The charter's job is to answer the questions the
     * org holds, and a charter that can create a question it then answers is not measuring
     * anything. It is also what keeps this callout-safe: creating them would be DML.
     */
    public static Result run(Id sourceId) {
        Config cfg = config();
        if (cfg.active != true) {
            throw new ExtractException(
                'AAO_Model_Config__mdt.Default is not Active. Model calls are switched off.'
            );
        }

        AAO_Source__c src = [
            SELECT
                Id,
                AAO_Source_Ref__c,
                AAO_Normalized_Text__c,
                AAO_Speaker_Roster__c,
                AAO_Diarization__c
            FROM AAO_Source__c
            WHERE Id = :sourceId
        ];
        if (String.isBlank(src.AAO_Normalized_Text__c)) {
            throw new ExtractException(
                'Source ' + src.AAO_Source_Ref__c + ' has no normalized text to read.'
            );
        }

        List<AAO_Evidence_Contract__c> contracts = [
            SELECT
                Id,
                AAO_Proposition_Code__c,
                AAO_Proposition_Short__c,
                AAO_Proposition_Text__c,
                AAO_Guidance_Text__c,
                AAO_Elements__c,
                AAO_Speaker_Requirement__c,
                AAO_Per_Person_Source__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Contract_State__c != 'Superseded'
            ORDER BY AAO_Proposition_Code__c
        ];
        if (contracts.isEmpty()) {
            throw new ExtractException(
                'No evidence contracts in the org. There is nothing to ask about.'
            );
        }

        Map<String, AAO_Model.Speaker> roster = AAO_Model.parseRoster(src.AAO_Speaker_Roster__c);

        String systemText = AAO_ExtractCharter.systemPrompt();
        String user = AAO_ExtractCharter.userContent(src, contracts, roster);
        Map<String, Object> outputSchema = AAO_ExtractCharter.schema(contracts, roster);

        Map<String, Object> body = new Map<String, Object>{
            'model' => cfg.modelName,
            'max_tokens' => cfg.maxOutputTokens,
            'system' => systemText,
            'messages' => new List<Object>{
                new Map<String, Object>{ 'role' => 'user', 'content' => user }
            },
            'output_config' => new Map<String, Object>{
                'effort' => cfg.effort,
                'format' => new Map<String, Object>{
                    'type' => 'json_schema',
                    'schema' => outputSchema
                }
            }
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint(cfg.endpoint());
        req.setMethod('POST');
        req.setTimeout(Math.min(cfg.timeoutMs, PLATFORM_TIMEOUT_CEILING_MS));
        if (String.isNotBlank(cfg.anthropicBeta)) {
            req.setHeader('anthropic-beta', cfg.anthropicBeta);
        }
        String payload = JSON.serialize(body);
        req.setBody(payload);

        Long started = System.currentTimeMillis();
        HttpResponse res = new Http().send(req);
        Long elapsed = System.currentTimeMillis() - started;

        Result out = new Result();
        out.sourceId = src.Id;
        out.sourceRef = src.AAO_Source_Ref__c;
        out.charter = cfg.charter;
        out.charterVersion = cfg.charterVersion;
        out.elapsedMs = elapsed;
        out.promptChars = systemText.length() + user.length();

        if (res.getStatusCode() != 200) {
            throw new ExtractException(
                'The model endpoint returned ' +
                res.getStatusCode() +
                ' ' +
                res.getStatus() +
                '. Body: ' +
                res.getBody().abbreviate(600)
            );
        }

        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        out.modelReported = (String) root.get('model');
        out.stopReason = (String) root.get('stop_reason');
        readUsage(out.usage, (Map<String, Object>) root.get('usage'));

        // Checked before the content is read, not after. A refusal returns HTTP 200 with an
        // empty or partial content array, so code that reaches for content[0] first breaks
        // on the one response it most needs to report clearly.
        if (out.stopReason == 'refusal') {
            throw new ExtractException(
                'The model declined this request. Nothing was proposed and nothing is ' +
                'written. stop_details: ' +
                JSON.serialize(root.get('stop_details'))
            );
        }
        if (out.stopReason == 'max_tokens') {
            throw new ExtractException(
                'The response hit max_tokens and the JSON is truncated, so it cannot be ' +
                'parsed. Raise AAO_Max_Output_Tokens__c on the config record. ' +
                out.usage
            );
        }

        String text = firstTextBlock(root);
        if (String.isBlank(text)) {
            throw new ExtractException(
                'The response carried no text block. stop_reason=' +
                out.stopReason +
                ' usage=' +
                out.usage
            );
        }

        Set<String> codes = new Set<String>();
        for (AAO_Evidence_Contract__c ec : contracts) {
            codes.add(ec.AAO_Proposition_Code__c);
        }
        out.findings = AAO_ExtractCharter.parse(text, codes);

        for (String code : codes) {
            if (!out.findings.containsKey(code)) {
                out.unanswered.add(code);
            }
        }
        out.unanswered.sort();
        return out;
    }

    // ======================================================================== internals

    private static void readUsage(Usage u, Map<String, Object> raw) {
        if (raw == null) {
            return;
        }
        u.inputTokens = intOf(raw.get('input_tokens'));
        u.outputTokens = intOf(raw.get('output_tokens'));
        u.cacheReadTokens = intOf(raw.get('cache_read_input_tokens'));
        u.cacheCreationTokens = intOf(raw.get('cache_creation_input_tokens'));
    }

    private static Integer intOf(Object o) {
        return o == null ? 0 : Integer.valueOf(o);
    }

    /**
     * Thinking blocks arrive alongside the answer and carry no text under the default
     * display setting, so the first block is routinely not the one we want. Take the first
     * text block that actually has text in it.
     */
    private static String firstTextBlock(Map<String, Object> root) {
        Object content = root.get('content');
        if (!(content instanceof List<Object>)) {
            return null;
        }
        for (Object bo : (List<Object>) content) {
            Map<String, Object> b = (Map<String, Object>) bo;
            if (b.get('type') == 'text' && String.isNotBlank((String) b.get('text'))) {
                return (String) b.get('text');
            }
        }
        return null;
    }
}
