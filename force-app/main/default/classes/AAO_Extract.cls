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
        public String blindCharter;
        public String blindCharterVersion;
        public Boolean blindEnabled = false;
        public String namedCredential;
        public String endpointPath;
        public String anthropicBeta;
        public String effort;
        public Integer maxOutputTokens;
        public Integer timeoutMs;
        public Boolean active;

        // ---- Extract-Bind-Verify, Charters v2.4 §P7.3. THREE STAGES, THREE MODELS, and the
        // separation is ruled rather than convenient: the binder and the verifier must be
        // different models because independence is the entire point of a second reader.
        // Group sizes live here rather than in Apex because they came from measurement and
        // will move when the next measurement says so — a constant in Apex would make a
        // measured number look like a design decision.
        public String inventoryModel;
        /**
         * Stage 1's own output bound, separate from the shared one because it is the only
         * stage where max_tokens is a TIME budget rather than a size one. The shared value is
         * 16,000, which at the measured generation rate is ~190 seconds and therefore cannot
         * fit the 120-second ceiling. The B&V run timed out at exactly 120.4 s with it.
         */
        public Integer inventoryMaxOutputTokens;
        /**
         * Stage 1's own effort, separate from the shared one, and separate for the same
         * reason the output bound is: on this stage effort is not a quality dial.
         *
         * `max_tokens` bounds thinking and content TOGETHER. Measurement 74 ran stage 1 at
         * the shared `high` and the read spent 7,500 of 7,500 output tokens on thinking and
         * emitted ZERO content — not a truncated inventory, no inventory. Three sessions had
         * read that wall as "the artifact yields more evidence than one call can carry" and
         * the number that says otherwise was on the wire the whole time.
         *
         * Blank falls back to the shared value, so the legacy path is untouched by this
         * field existing.
         */
        public String inventoryEffort;
        public String inventoryCharter;
        public String inventoryCharterVersion;
        /**
         * Stage 3's sampling temperature, and stage 3's alone. Null means the key is never
         * put on the wire, which is the baseline this project measured everything else
         * against; sending a number the endpoint would otherwise have picked is a different
         * request, not a neutral one, so the null case omits rather than defaults.
         *
         * It exists because the stability probe located the flicker: across three identical
         * runs on the same frozen bytes, location held (42/42/43 located pairs) while upheld
         * verdicts nearly tripled (8 to 21). The instability is downstream of locate, which
         * makes call 3 the place where determinism is worth measuring. The reads are
         * deliberately outside this field: their variance is the ruled recall hedge and
         * removing it would be removing the thing the two-read shape is for.
         */
        public Decimal verifyTemperature;
        public String bindModel;
        public String bindCharter;
        public String bindCharterVersion;
        public Integer bindGroupSize;
        public String verifyModel;
        public String verifyCharter;
        public String verifyCharterVersion;
        public Integer verifyGroupSize;

        public String endpoint() {
            return 'callout:' + namedCredential + endpointPath;
        }
    }

    /**
     * One stage's model settings, resolved from config, so the callout body does not have to
     * know which stage it is serving.
     *
     * `effort` is blank for the small stages on purpose. It is a real request parameter and a
     * real cost: the binder and the verifier are answering a low-inference question about two
     * pieces of text, and buying thinking tokens for that is paying for deliberation nobody
     * asked for. Stage 1 keeps it.
     */
    public class StageSpec {
        public String stage;
        public String model;
        public String effort;
        public Integer maxTokens;
        public String charter;
        public String charterVersion;
        /** Whether the first content block carries a cache breakpoint. */
        public Boolean cachePrefix = false;
        /**
         * Sampling temperature, sent only when a stage sets one. Null omits the key, the same
         * discipline `effort` follows and for the same reason: a key with a default behind it
         * is a different request from no key at all, and every measurement this project holds
         * was taken without it.
         */
        public Decimal temperature;
    }

    /** What one stage call produced, with everything the journal needs to name it. */
    public class StageResult {
        public String stage;
        public String rawText;
        public Usage usage = new Usage();
        public String modelRequested;
        public String modelReported;
        public String stopReason;
        public String charter;
        public String charterVersion;
        public Long elapsedMs;
        public Integer promptChars;
        /** What was actually on the wire, so a probe can evidence it rather than claim it. */
        public Decimal temperature;
        /**
         * True when a temperature was configured, the model refused it, and the call was
         * remade without it (forty-first stamp ruling 2, the BYO-LLM law). A run that reports
         * `temp=refused` is telling you the stability knob was NOT applied, which is a
         * different run from one that never asked for it.
         */
        public Boolean temperatureRefused = false;
        /** Same, for the reasoning-effort knob, so the journal names which knob was missing. */
        public Boolean effortRefused = false;

        public override String toString() {
            return stage +
                ' model=' + modelReported +
                ' charter=' + charter + '@' + charterVersion +
                ' ms=' + elapsedMs +
                ' ' + usage +
                ' promptChars=' + promptChars +
                (temperatureRefused == true
                    ? ' temp=REFUSED_BY_MODEL'
                    : (temperature == null ? ' temp=unset' : ' temp=' + temperature)) +
                (effortRefused == true ? ' effort=REFUSED_BY_MODEL' : '') +
                ' stop=' + stopReason;
        }
    }

    public static StageSpec inventorySpec() {
        Config cfg = config();
        requireActive(cfg);
        StageSpec s = new StageSpec();
        s.stage = 'stage1_read';
        s.model = String.isBlank(cfg.inventoryModel) ? cfg.modelName : cfg.inventoryModel;
        // Stage 1's own effort when set. See Config.inventoryEffort: the shared value is
        // what produced a read that spent its whole output budget thinking.
        s.effort = String.isBlank(cfg.inventoryEffort) ? cfg.effort : cfg.inventoryEffort;
        s.maxTokens = cfg.inventoryMaxOutputTokens == null
            ? cfg.maxOutputTokens
            : cfg.inventoryMaxOutputTokens;
        s.charter = cfg.inventoryCharter;
        s.charterVersion = cfg.inventoryCharterVersion;
        s.cachePrefix = true;
        return s;
    }

    public static StageSpec bindSpec() {
        Config cfg = config();
        requireActive(cfg);
        StageSpec s = new StageSpec();
        s.stage = 'stage2_bind';
        s.model = cfg.bindModel;
        s.maxTokens = cfg.maxOutputTokens;
        s.charter = cfg.bindCharter;
        s.charterVersion = cfg.bindCharterVersion;
        return s;
    }

    public static StageSpec verifySpec() {
        Config cfg = config();
        requireActive(cfg);
        StageSpec s = new StageSpec();
        s.stage = 'stage3_verify';
        s.model = cfg.verifyModel;
        s.maxTokens = cfg.maxOutputTokens;
        s.charter = cfg.verifyCharter;
        s.charterVersion = cfg.verifyCharterVersion;
        // Stage 3 only. Nothing upstream reads this, which is the point: the reads keep their
        // variance because that variance is the recall hedge the two-read shape is built on.
        s.temperature = cfg.verifyTemperature;
        return s;
    }

    /**
     * The separation, enforced in code rather than trusted to a config record.
     *
     * A verifier that is the same model as the binder is not a second reader, it is the same
     * reader asked twice, and every rejection count it produces is worthless. This throws
     * before the callout rather than reporting a suspicious number afterwards.
     */
    public static void requireSeparateModels() {
        Config cfg = config();
        if (String.isBlank(cfg.bindModel) || String.isBlank(cfg.verifyModel)) {
            throw new ExtractException(
                'Both AAO_Bind_Model__c and AAO_Verify_Model__c must be set. §P7.3 rules ' +
                'binding and verification onto separate models and there is no default.'
            );
        }
        if (cfg.bindModel == cfg.verifyModel) {
            throw new ExtractException(
                'The bind model and the verify model are both ' + cfg.bindModel + '. ' +
                'Verification on the same model as binding is the same reader asked twice, ' +
                'and its rejection count would measure nothing. Ruled separate, 3 August.'
            );
        }
    }

    /**
     * THE SAME SEPARATION, ON THE PATH WHERE VERIFICATION ACTUALLY HAPPENS.
     *
     * `requireSeparateModels` above guards the extract-bind-verify path and was the only guard
     * that existed. The §P8 pass never called it, and §P8's call 3 built its spec from
     * `inventorySpec()` and inherited the READ model, so for three weeks the reader and the
     * verifier were the same model on the wire while the config record named a different one.
     * The guard was watching a comparison the running pass did not use. That is the drift the
     * forty-first stamp's ruling 1 closes, and this is the half that stops it recurring
     * silently: the pass asks, every call 3, whether the two models are still distinct.
     *
     * The comparison is READER versus VERIFIER because on §P8 those are the two readings that
     * must be independent. There is no binder on this path.
     */
    public static void requireSeparateReaderAndVerifier() {
        Config cfg = config();
        if (String.isBlank(cfg.verifyModel)) {
            throw new ExtractException(
                'AAO_Verify_Model__c is blank. §P8 call 3 dispatches the CONFIGURED verify ' +
                'model (forty-first stamp, ruling 1) and there is no fallback on purpose: ' +
                'falling back to the read model is precisely the drift this replaces.'
            );
        }
        if (String.isBlank(cfg.inventoryModel)) {
            throw new ExtractException('AAO_Inventory_Model__c is blank; the reads have no model.');
        }
        if (cfg.inventoryModel == cfg.verifyModel) {
            throw new ExtractException(
                'The read model and the verify model are both ' + cfg.inventoryModel +
                '. Call 3 is meant to be a SECOND reader; the same model asked again is the ' +
                'same reader asked twice, and every verdict it returns would measure nothing.'
            );
        }
    }

    private static void requireActive(Config cfg) {
        if (cfg.active != true) {
            throw new ExtractException(
                'AAO_Model_Config__mdt.Default is not Active. Model calls are switched off.'
            );
        }
    }

    /**
     * One stage call. Shared by all three so they cannot drift apart in how they read usage,
     * handle a refusal, or find the text block.
     */
    public static StageResult callStage(
        StageSpec spec,
        String systemText,
        List<String> userBlocks,
        Map<String, Object> outputSchema
    ) {
        if (String.isBlank(spec.model)) {
            throw new ExtractException(
                'Stage ' + spec.stage + ' has no model configured. There is no fallback: a ' +
                'measurement that cannot name the model that produced it is not a measurement.'
            );
        }
        List<Object> blocks = new List<Object>();
        for (Integer i = 0; i < userBlocks.size(); i++) {
            Map<String, Object> b = new Map<String, Object>{
                'type' => 'text',
                'text' => userBlocks[i]
            };
            if (i == 0 && spec.cachePrefix == true) {
                b.put('cache_control', new Map<String, Object>{ 'type' => 'ephemeral' });
            }
            blocks.add(b);
        }

        Call c = send(config(), spec, systemText, blocks, outputSchema);

        StageResult r = new StageResult();
        r.stage = spec.stage;
        r.temperature = c.temperatureSent;
        r.temperatureRefused = c.temperatureRefused == true;
        r.effortRefused = c.effortRefused == true;
        r.rawText = c.text;
        r.usage = c.usage;
        r.modelRequested = spec.model;
        r.modelReported = c.modelReported;
        r.stopReason = c.stopReason;
        r.charter = spec.charter;
        r.charterVersion = spec.charterVersion;
        r.elapsedMs = c.elapsedMs;
        Integer chars = systemText == null ? 0 : systemText.length();
        for (String b : userBlocks) {
            chars += b == null ? 0 : b.length();
        }
        r.promptChars = chars;
        return r;
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
                AAO_Blind_Charter__c,
                AAO_Blind_Charter_Version__c,
                AAO_Blind_Enabled__c,
                AAO_Named_Credential__c,
                AAO_Endpoint_Path__c,
                AAO_Anthropic_Beta__c,
                AAO_Effort__c,
                AAO_Max_Output_Tokens__c,
                AAO_Timeout_Ms__c,
                AAO_Active__c,
                AAO_Inventory_Model__c,
                AAO_Inventory_Max_Output_Tokens__c,
                AAO_Inventory_Effort__c,
                AAO_Inventory_Charter__c,
                AAO_Inventory_Charter_Version__c,
                AAO_Bind_Model__c,
                AAO_Bind_Charter__c,
                AAO_Bind_Charter_Version__c,
                AAO_Bind_Group_Size__c,
                AAO_Verify_Model__c,
                AAO_Verify_Charter__c,
                AAO_Verify_Charter_Version__c,
                AAO_Verify_Group_Size__c,
                AAO_Verify_Temperature__c
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
        c.blindCharter = r.AAO_Blind_Charter__c;
        c.blindCharterVersion = r.AAO_Blind_Charter_Version__c;
        c.blindEnabled = r.AAO_Blind_Enabled__c == true;
        c.namedCredential = r.AAO_Named_Credential__c;
        c.endpointPath = r.AAO_Endpoint_Path__c;
        c.anthropicBeta = r.AAO_Anthropic_Beta__c;
        c.effort = r.AAO_Effort__c;
        c.maxOutputTokens = Integer.valueOf(r.AAO_Max_Output_Tokens__c);
        c.timeoutMs = Integer.valueOf(r.AAO_Timeout_Ms__c);
        c.active = r.AAO_Active__c;
        c.inventoryModel = r.AAO_Inventory_Model__c;
        c.inventoryMaxOutputTokens = r.AAO_Inventory_Max_Output_Tokens__c == null
            ? null
            : Integer.valueOf(r.AAO_Inventory_Max_Output_Tokens__c);
        c.inventoryEffort = r.AAO_Inventory_Effort__c;
        c.inventoryCharter = r.AAO_Inventory_Charter__c;
        c.inventoryCharterVersion = r.AAO_Inventory_Charter_Version__c;
        c.bindModel = r.AAO_Bind_Model__c;
        c.bindCharter = r.AAO_Bind_Charter__c;
        c.bindCharterVersion = r.AAO_Bind_Charter_Version__c;
        c.bindGroupSize = r.AAO_Bind_Group_Size__c == null
            ? null
            : Integer.valueOf(r.AAO_Bind_Group_Size__c);
        c.verifyModel = r.AAO_Verify_Model__c;
        c.verifyCharter = r.AAO_Verify_Charter__c;
        c.verifyCharterVersion = r.AAO_Verify_Charter_Version__c;
        c.verifyGroupSize = r.AAO_Verify_Group_Size__c == null
            ? null
            : Integer.valueOf(r.AAO_Verify_Group_Size__c);
        // Null stays null rather than becoming a number. See Config.verifyTemperature.
        c.verifyTemperature = r.AAO_Verify_Temperature__c;
        return c;
    }

    // =========================================================================== result

    public class Usage {
        public Integer inputTokens = 0;
        public Integer outputTokens = 0;
        public Integer cacheReadTokens = 0;
        public Integer cacheCreationTokens = 0;
        /**
         * THINKING TOKENS, BROKEN OUT, and the absence of this line is why three sessions of
         * measurement cannot answer a question they should have been able to.
         *
         * `output_tokens` INCLUDES thinking, and thinking counts against `max_tokens`. So an
         * inventory read that truncates at 7,500 output tokens may have produced a small
         * inventory behind a large deliberation, or a large inventory with no deliberation, and
         * measurement 71's 7,339 output tokens has the same ambiguity in it. Those are
         * completely different findings with completely different fixes — lower the effort, or
         * accept that the artifact yields more evidence than one bounded call can carry — and
         * the number that separates them was on the wire the whole time and never read.
         */
        public Integer thinkingTokens = 0;

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
                cacheCreationTokens +
                ' thinking=' +
                thinkingTokens;
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
    /**
     * **The declared applicable set is an argument, never a read.** This method used to call
     * `AAO_Rubric.contracts()` itself, so a pass that resolved forty-eight People contracts
     * asked the model about fifty-three — the declared set governed what was written and not
     * what was asked. The set now arrives from `AAO_ApplicableSet` through the pipeline, and
     * the read it used to make no longer exists under that name.
     */
    public static Result run(Id sourceId, List<AAO_Evidence_Contract__c> declared) {
        Config cfg = config();
        if (cfg.active != true) {
            throw new ExtractException(
                'AAO_Model_Config__mdt.Default is not Active. Model calls are switched off.'
            );
        }

        AAO_Source__c src = [
            SELECT
                Id,
                AAO_Opportunity__c,
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

        // Whatever resolved, and nothing else. An unscoped read here sends every generation of
        // every proposition to the charter at once, and it reads as thoroughness.
        List<AAO_Evidence_Contract__c> contracts = declared == null
            ? new List<AAO_Evidence_Contract__c>()
            : declared;
        if (contracts.isEmpty()) {
            throw new ExtractException(
                'Nothing resolved for the declared charter set, so there is nothing to ask ' +
                'about. This is not the same as an org with no contracts in it.'
            );
        }

        Map<String, AAO_Model.Speaker> roster = AAO_Model.parseRoster(src.AAO_Speaker_Roster__c);

        String systemText = AAO_ExtractCharter.systemPrompt();
        String rubric = AAO_ExtractCharter.rubricBlock(contracts);
        String artifact = AAO_ExtractCharter.artifactBlock(src, roster);

        // TWO BLOCKS, AND THE ORDER IS THE WHOLE POINT. Caching is a prefix match: the
        // rubric is identical for every artifact in this org until somebody edits a
        // contract, and the transcript changes every call. Rubric first with the
        // breakpoint on it, artifact after. Put anything volatile above the breakpoint and
        // the cache silently never reads, with no error to notice.
        List<Object> blocks = new List<Object>{
            new Map<String, Object>{
                'type' => 'text',
                'text' => rubric,
                'cache_control' => new Map<String, Object>{ 'type' => 'ephemeral' }
            },
            new Map<String, Object>{ 'type' => 'text', 'text' => artifact }
        };

        Call c = send(
            cfg,
            systemText,
            blocks,
            AAO_ExtractCharter.schema(contracts, roster)
        );

        Result out = new Result();
        out.sourceId = src.Id;
        out.sourceRef = src.AAO_Source_Ref__c;
        out.charter = cfg.charter;
        out.charterVersion = cfg.charterVersion;
        out.elapsedMs = c.elapsedMs;
        out.promptChars = systemText.length() + rubric.length() + artifact.length();
        out.usage = c.usage;
        out.modelReported = c.modelReported;
        out.stopReason = c.stopReason;

        Set<String> codes = new Set<String>();
        for (AAO_Evidence_Contract__c ec : contracts) {
            codes.add(ec.AAO_Proposition_Code__c);
        }
        out.findings = AAO_ExtractCharter.parse(c.text, codes);

        for (String code : codes) {
            if (!out.findings.containsKey(code)) {
                out.unanswered.add(code);
            }
        }
        out.unanswered.sort();
        return out;
    }

    // ================================================================= the second reader

    public class BlindResult {
        /** Keyed proposition code, then element id. */
        public Map<String, Map<String, AAO_BlindCharter.ElementVerdict>> verdicts;
        public Usage usage = new Usage();
        public String modelReported;
        public String stopReason;
        public String charter;
        public String charterVersion;
        public Long elapsedMs;
        public Integer promptChars;

        public override String toString() {
            return 'BLIND charter=' +
                charter +
                '@' +
                charterVersion +
                ' reviewed=' +
                (verdicts == null ? 0 : verdicts.size()) +
                ' ' +
                usage +
                ' ms=' +
                elapsedMs +
                ' stop=' +
                stopReason;
        }
    }

    /**
     * Model call 2. Takes citations and returns, per element, whether they establish it.
     *
     * It is handed reviews and nothing else. There is no parameter here through which a
     * transcript or an earlier verdict could arrive, which is what makes the blindness a
     * property of the code rather than a promise in a prompt.
     *
     * Not cached. The content is different on every call by construction, since it is the
     * citations a particular pass produced, so a breakpoint would pay the write premium and
     * never read.
     */
    public static BlindResult review(List<AAO_BlindCharter.Review> reviews) {
        Config cfg = config();
        if (cfg.active != true) {
            throw new ExtractException(
                'AAO_Model_Config__mdt.Default is not Active. Model calls are switched off.'
            );
        }
        if (reviews == null || reviews.isEmpty()) {
            throw new ExtractException('The blind reader was called with nothing to review.');
        }

        String systemText = AAO_BlindCharter.systemPrompt();
        String content = AAO_BlindCharter.content(reviews);

        Call c = send(
            cfg,
            systemText,
            new List<Object>{ new Map<String, Object>{ 'type' => 'text', 'text' => content } },
            AAO_BlindCharter.schema(reviews)
        );

        Set<String> codes = new Set<String>();
        for (AAO_BlindCharter.Review r : reviews) {
            codes.add(r.contract.AAO_Proposition_Code__c);
        }

        BlindResult out = new BlindResult();
        out.charter = cfg.blindCharter;
        out.charterVersion = cfg.blindCharterVersion;
        out.usage = c.usage;
        out.modelReported = c.modelReported;
        out.stopReason = c.stopReason;
        out.elapsedMs = c.elapsedMs;
        out.promptChars = systemText.length() + content.length();
        out.verdicts = AAO_BlindCharter.parse(c.text, codes);
        return out;
    }

    // ============================================================== the callout itself

    private class Call {
        Usage usage = new Usage();
        String modelReported;
        String stopReason;
        Long elapsedMs;
        String text;
        /** What actually rode the wire on the request that succeeded, null if none did. */
        Decimal temperatureSent;
        /** True when the model refused the key and the call was remade without it. */
        Boolean temperatureRefused = false;
        /** Same, for the reasoning-effort knob. */
        Boolean effortRefused = false;
    }

    /**
     * The pre-§P7.3 entry. Kept so the retired one-call pass and its tests still run exactly
     * as they did: they are history and cost data, and history that stops compiling stops
     * being checkable.
     */
    private static Call send(
        Config cfg,
        String systemText,
        List<Object> userBlocks,
        Map<String, Object> outputSchema
    ) {
        StageSpec legacy = new StageSpec();
        legacy.stage = 'legacy';
        legacy.model = cfg.modelName;
        legacy.effort = cfg.effort;
        legacy.maxTokens = cfg.maxOutputTokens;
        return send(cfg, legacy, systemText, userBlocks, outputSchema);
    }

    /** One request, one response, shared by every charter so they cannot drift apart. */
    private static Call send(
        Config cfg,
        StageSpec spec,
        String systemText,
        List<Object> userBlocks,
        Map<String, Object> outputSchema
    ) {
        Map<String, Object> outputConfig = new Map<String, Object>{
            'format' => new Map<String, Object>{
                'type' => 'json_schema',
                'schema' => outputSchema
            }
        };
        // Omitted rather than sent empty. An `effort` key with a null behind it is not the
        // same request as no key at all, and the small stages are measured without one.
        if (String.isNotBlank(spec.effort)) {
            outputConfig.put('effort', spec.effort);
        }

        Map<String, Object> body = new Map<String, Object>{
            'model' => spec.model,
            'max_tokens' => spec.maxTokens,
            'system' => systemText,
            'messages' => new List<Object>{
                new Map<String, Object>{ 'role' => 'user', 'content' => userBlocks }
            },
            'output_config' => outputConfig
        };
        // Same rule as `effort` above: omitted rather than sent empty, so a run with no
        // temperature configured puts the exact bytes on the wire it always has.
        if (spec.temperature != null) {
            body.put('temperature', spec.temperature);
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(cfg.endpoint());
        req.setMethod('POST');
        req.setTimeout(Math.min(cfg.timeoutMs, PLATFORM_TIMEOUT_CEILING_MS));
        if (String.isNotBlank(cfg.anthropicBeta)) {
            req.setHeader('anthropic-beta', cfg.anthropicBeta);
        }
        req.setBody(JSON.serialize(body));

        Long started = System.currentTimeMillis();
        HttpResponse res = new Http().send(req);

        Call c = new Call();
        c.elapsedMs = System.currentTimeMillis() - started;
        c.temperatureSent = spec.temperature;

        // OPTIONAL MODEL CAPABILITIES ARE FEATURE-DETECTED, NEVER REQUIRED. Forty-first
        // stamp, ruling 2: the product is BYO-LLM, each org configures its own model per call,
        // and a customer's model may or may not carry a given knob. The ruling extends LAW #1's
        // discipline (feature detection, never version checks) to MODEL CAPABILITIES, so a
        // configured extra that the chosen model refuses must not restrict the model choice or
        // fail the run. The key is dropped, the call is remade, and the fact is journalled so a
        // run report can say the knob was unavailable rather than implying it was applied.
        //
        // Detection is on the endpoint's OWN refusal, never on a model-name list. A name or
        // version check would be exactly the LAW #1 mistake and would be wrong the first time a
        // customer points this at a model nobody here has heard of. Measured on this org:
        //   temperature  opus-5 and sonnet-5 refuse ("deprecated for this model"), haiku accepts
        //   effort       haiku-4-5 refuses ("does not support the effort parameter"), opus accepts
        // Two different models, two different missing knobs, in opposite directions. That is the
        // whole argument for detecting rather than knowing.
        //
        // The loop retries once per refused key, because a model may lack more than one, and
        // stops as soon as a request is not refused for a key we actually sent.
        for (Integer attempt = 0; attempt < 2; attempt++) {
            if (res.getStatusCode() != 400 || res.getBody() == null) {
                break;
            }
            String err = res.getBody();
            Boolean dropped = false;
            if (body.containsKey('temperature') && err.contains('temperature')) {
                body.remove('temperature');
                c.temperatureRefused = true;
                c.temperatureSent = null;
                dropped = true;
            }
            if (outputConfig.containsKey('effort') && err.contains('effort')) {
                outputConfig.remove('effort');
                c.effortRefused = true;
                dropped = true;
            }
            if (!dropped) {
                break;
            }
            req.setBody(JSON.serialize(body));
            started = System.currentTimeMillis();
            res = new Http().send(req);
            c.elapsedMs = System.currentTimeMillis() - started;
        }

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
        c.modelReported = (String) root.get('model');
        c.stopReason = (String) root.get('stop_reason');
        readUsage(c.usage, (Map<String, Object>) root.get('usage'));

        // Checked before the content is read, not after. A refusal returns HTTP 200 with an
        // empty or partial content array, so code that reaches for content[0] first breaks
        // on the one response it most needs to report clearly.
        if (c.stopReason == 'refusal') {
            throw new ExtractException(
                'The model declined this request. Nothing was proposed and nothing is ' +
                'written. stop_details: ' +
                JSON.serialize(root.get('stop_details'))
            );
        }
        if (c.stopReason == 'max_tokens') {
            throw new ExtractException(
                'The response hit max_tokens and the JSON is truncated, so it cannot be ' +
                'parsed. Raise AAO_Max_Output_Tokens__c on the config record. ' +
                c.usage
            );
        }

        c.text = firstTextBlock(root);
        if (String.isBlank(c.text)) {
            throw new ExtractException(
                'The response carried no text block. stop_reason=' +
                c.stopReason +
                ' usage=' +
                c.usage
            );
        }
        return c;
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
        Object details = raw.get('output_tokens_details');
        if (details instanceof Map<String, Object>) {
            u.thinkingTokens = intOf(((Map<String, Object>) details).get('thinking_tokens'));
        }
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
