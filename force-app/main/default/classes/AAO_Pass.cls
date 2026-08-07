/**
 * THE §P8 PASS, END TO END: call 1 locates and pairs, call 2 identifies, call 3 verifies.
 *
 * One method per call, each taking a run key, because a run is the unit the arithmetic is
 * computed over and every row carries it. Callouts and DML are separated exactly as
 * `AAO_Extract` separates them, and for the same reason.
 *
 * WHY THE THREE STEPS ARE THREE PUBLIC METHODS RATHER THAN ONE `run()`. Apex allows at most
 * 100 callouts and 120 seconds of cumulative callout time per transaction, and the ceiling
 * is law-grade and unraiseable. Three calls over a 42 KB artifact measured ~28 s, ~15 s and
 * ~20 s in the first Emerson run — comfortable in one transaction today, and the shape that
 * survives the day a transcript needs six calls is one where the caller can stop between
 * stages. The stages are also independently measurable, which is the whole reason the pair
 * ledger is two rows.
 */
public with sharing class AAO_Pass {
    public class PassException extends Exception {
    }

    // ============================================================== call 1 · locate and pair

    public class LocateRun {
        public AAO_Extract.StageResult call;
        public AAO_LocateCharter.Result parsed;
        public AAO_Locate.Located located;
    }

    public static LocateRun locate(Id sourceId, String runKey) {
        AAO_Source__c src = source(sourceId);
        List<AAO_Evidence_Contract__c> declared = AAO_RecallGate.declaredSet();
        List<String> codes = new List<String>();
        Map<String, Id> idByCode = new Map<String, Id>();
        for (AAO_Evidence_Contract__c ec : declared) {
            codes.add(ec.AAO_Proposition_Code__c);
            idByCode.put(ec.AAO_Proposition_Code__c, ec.Id);
        }

        String version = AAO_LocateCharter.effectiveVersion(declared);
        AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
        spec.stage = 'call1_locate';
        spec.charter = 'AAO_LocateCharter';
        spec.charterVersion = version;

        LocateRun r = new LocateRun();
        r.call = AAO_Extract.callStage(
            spec,
            AAO_LocateCharter.systemPrompt(),
            new List<String>{
                AAO_LocateCharter.rubricBlock(declared),
                '# The transcript\n\n' + src.AAO_Normalized_Text__c
            },
            AAO_LocateCharter.schema(codes)
        );
        r.parsed = AAO_LocateCharter.parse(r.call.rawText, codes);
        r.located = AAO_Locate.locate(src, r.parsed.pairs, runKey, version, idByCode);
        AAO_Locate.write(r.located);
        return r;
    }




    // ========================================================== call 0 · THE RESOLVER READ

    /**
     * The deterministic ladder's outputs, computed in Apex before call 0 and handed to it AS
     * EVIDENCE rather than as a verdict. That is the ladder's own pattern: a deterministic
     * read whose meaning cannot be interpreted alone is not decisive.
     */
    public class LadderEvidence {
        public String ownerRole = 'NOT AVAILABLE';
        public Boolean accountMapExists = false;
        public List<Opportunity> candidates = new List<Opportunity>();
        public Map<Id, Integer> overlapByOpp = new Map<Id, Integer>();
        public List<String> notes = new List<String>();
    }

    public class ResolveRun {
        public AAO_Extract.StageResult call;
        public AAO_ResolverCharter.Result verdict;
        public LadderEvidence ladder;
        /** Which grains dispatch. Today this is opportunity or nothing, per v3.2. */
        public List<String> dispatchedGrains = new List<String>();
        public List<String> routedNotDispatched = new List<String>();
    }

    /**
     * CALL 0, ALWAYS. It routes and resolves and never establishes.
     *
     * **THE ACCOUNT GRAIN IS BACKBURNERED (v3.2), so exactly one grain dispatches.** An
     * ACCOUNT verdict dispatches nothing and the Source lands carrying its verdict; a DUAL
     * verdict dispatches the opportunity family reads exactly as today and logs the account
     * half as routed-not-dispatched. Nothing account-side is extracted, written, or authored.
     *
     * **The verdict is returned and not persisted, and that is the run receipt's gap again.**
     * A resolution belongs to a run rather than to a Source — a re-run resolves again — so
     * its home is the receipt §P8.0 owes and does not have. Recorded rather than parked on a
     * field that would make a per-run fact look like a per-Source one.
     */
    public static ResolveRun resolve(Id sourceId) {
        AAO_Source__c src = source(sourceId);
        ResolveRun r = new ResolveRun();
        r.ladder = ladder(src);

        List<String> handles = new List<String>();
        Map<String, Id> oppByHandle = new Map<String, Id>();
        List<String> block = new List<String>{
            '# What was computed before you', '',
            'Owner-organizer role: ' + r.ladder.ownerRole,
            'An account-level map exists for this account: ' +
                (r.ladder.accountMapExists ? 'yes' : 'no'),
            ''
        };
        for (String n : r.ladder.notes) {
            block.add('  note: ' + n);
        }
        block.add('');
        block.add('# The candidate deals, as of the day this call happened');
        block.add('');
        Integer i = 0;
        for (Opportunity o : r.ladder.candidates) {
            i++;
            String h = 'd' + i;
            handles.add(h);
            oppByHandle.put(h, o.Id);
            Integer overlap = r.ladder.overlapByOpp.containsKey(o.Id)
                ? r.ladder.overlapByOpp.get(o.Id)
                : 0;
            block.add('  ' + h + ': ' + o.Name + ' (' + o.StageName + ', closes ' +
                o.CloseDate + '). Participants on this call who sit on its map: ' + overlap);
        }
        if (handles.isEmpty()) {
            block.add('  (none — no candidate deal was open at the time of this call)');
        }
        block.add('');

        AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
        spec.stage = 'call0_resolve';
        spec.charter = 'AAO_ResolverCharter';
        spec.charterVersion = AAO_ResolverCharter.effectiveVersion();

        r.call = AAO_Extract.callStage(
            spec,
            AAO_ResolverCharter.systemPrompt(),
            new List<String>{
                AAO_ResolverCharter.ontologyText(),
                String.join(block, '\n'),
                '# The transcript\n\n' + src.AAO_Normalized_Text__c
            },
            AAO_ResolverCharter.schema(handles)
        );
        r.verdict = AAO_ResolverCharter.parse(r.call.rawText, handles);
        // The two sides' quotes are checked against the frozen artifact here rather than in
        // the parse, because the parse holds the model's answer and this holds it against the
        // bytes - the same separation the pairs law makes one stage later.
        AAO_ResolverCharter.locate(r.verdict, src.AAO_Normalized_Text__c);

        // v3.2 dispatch. One grain, and the other is logged rather than silently dropped.
        if (r.verdict.carriesNothing()) {
            r.routedNotDispatched.add(
                'NEITHER side answered yes. Nothing dispatches. This state is reachable only ' +
                'under the v3.4 split - the retired two-sided question forced a pick among ' +
                'three - and it is surfaced rather than coerced, per the silence law.'
            );
            return r;
        }
        if (r.verdict.scope == AAO_ResolverCharter.OPPORTUNITY ||
            r.verdict.scope == AAO_ResolverCharter.DUAL) {
            r.dispatchedGrains.add('opportunity');
        }
        if (r.verdict.scope == AAO_ResolverCharter.ACCOUNT ||
            r.verdict.scope == AAO_ResolverCharter.DUAL) {
            r.routedNotDispatched.add(
                'account grain: backburnered at charters v3.2, no extraction, no writes, no ' +
                'contracts. Routed and logged.'
            );
        }
        return r;
    }

    /**
     * THE CANDIDATE SET IS BUILT ON THE EVIDENCE-OCCURRED CLOCK, never the run clock. The 17
     * June fixture is the standing specimen: at call time the account held one open deal;
     * by the first test run it had closed won and a renewal had opened, so a naive set
     * resolves the call to a deal that did not exist when the words were spoken.
     *
     * **In this sandbox the window cannot run honestly and says so** rather than producing a
     * number: every opportunity carries a seed `CreatedDate` weeks after the call, so
     * "existed at call time" is unanswerable from `CreatedDate` here. The candidates are
     * taken unfiltered and the note travels with them.
     */
    private static LadderEvidence ladder(AAO_Source__c src) {
        LadderEvidence e = new LadderEvidence();

        // Test 1: the owner-organizer's role, through the role map. There is no role map in
        // this org, so this leg reports NOT AVAILABLE rather than guessing — which is §P5's
        // own file-dump case, and the reason call 0 is unconditional.
        e.notes.add(
            'Owner role unavailable: no role map exists in this org, so Test 1 cannot run. ' +
            'Roughly 75% of the market are file-dump orgs in the same position.'
        );

        List<Opportunity> opps = [
            SELECT Id, Name, StageName, CloseDate, CreatedDate
            FROM Opportunity
            WHERE AccountId = :src.AAO_Account__c
            ORDER BY CreatedDate
        ];
        e.candidates = opps;
        e.notes.add(
            'The occurred-time window is NOT APPLIED here and no result depends on it: every ' +
            'opportunity in this sandbox carries a seed CreatedDate later than the call, so ' +
            'filtering on it would remove every candidate. All candidates are listed.'
        );

        // The map check, and participant overlap, both graceful under absence: a read failure
        // on an unlicensed or unpopulated ALTF table is absence and a note, never an error.
        try {
            e.accountMapExists = [
                SELECT COUNT()
                FROM ALTF__Contact_Map_Details__c
                WHERE ALTF__Account__c = :src.AAO_Account__c
                    AND ALTF__Opportunity__c = null
            ] > 0;

            Set<Id> onCall = new Set<Id>();
            for (AAO_Participant__c p : [
                SELECT AAO_Contact__c FROM AAO_Participant__c
                WHERE AAO_Source__c = :src.Id AND AAO_Contact__c != null
            ]) {
                onCall.add(p.AAO_Contact__c);
            }
            if (!onCall.isEmpty()) {
                for (ALTF__Contact_Map_Details__c m : [
                    SELECT ALTF__Opportunity__c, ALTF__Contact__c
                    FROM ALTF__Contact_Map_Details__c
                    WHERE ALTF__Contact__c IN :onCall AND ALTF__Opportunity__c != null
                ]) {
                    Integer n = e.overlapByOpp.containsKey(m.ALTF__Opportunity__c)
                        ? e.overlapByOpp.get(m.ALTF__Opportunity__c)
                        : 0;
                    e.overlapByOpp.put(m.ALTF__Opportunity__c, n + 1);
                }
            } else {
                e.notes.add(
                    'Participant overlap is empty: no participant on this call carries a ' +
                    'Contact link, so the deterministic overlap read has nothing to compare.'
                );
            }
        } catch (Exception ex) {
            e.notes.add(
                'The Altify map tables could not be read (' + ex.getTypeName() +
                '). Treated as absence and a configuration note, never an error.'
            );
        }
        return e;
    }

    // ========================================================== call 1 · THE FAMILY SWEEP

    public class SweepRun {
        public List<AAO_Extract.StageResult> calls = new List<AAO_Extract.StageResult>();
        public Map<String, Integer> pairsByFamily = new Map<String, Integer>();
        public Integer parsed = 0;
        public Integer located = 0;
        public Integer discardedNoMatch = 0;
        public Integer discardedCrossesTurns = 0;
        public Integer coverageDefaulted = 0;
        public List<String> rejected = new List<String>();
        public List<String> discardNotes = new List<String>();
        /** Family reads re-invoked because the first look came back a cheap blank. */
        public Integer blankRetries = 0;
        /** Families that came back blank twice. The second zero stands. */
        public List<String> blankTwice = new List<String>();
        /** Families a retry recovered, which is the guard earning its callout. */
        public List<String> blankRecovered = new List<String>();
        /** Serial wall clock. Concurrency is a separate question and is reported separately. */
        public Long serialMs = 0;

        public override String toString() {
            List<String> o = new List<String>{
                'call-1 invocations       ' + calls.size() + ' (unit: reads, one per family)',
                'pairs parsed             ' + parsed + ' (unit: pairs)',
                'pairs located            ' + located + ' (unit: pairs)',
                'discarded, no match      ' + discardedNoMatch + ' (unit: pairs)',
                'discarded, crosses turns ' + discardedCrossesTurns + ' (unit: pairs)',
                'coverage defaulted       ' + coverageDefaulted + ' (unit: pairs)',
                'blank retries           ' + blankRetries + ' (unit: reads)',
                'wall clock, THIS TRANSACTION ' + serialMs + ' ms of the 120,000 ms ceiling'
            };
            if (!blankRecovered.isEmpty()) {
                o.add('  retry RECOVERED        ' + String.join(blankRecovered, ', '));
            }
            if (!blankTwice.isEmpty()) {
                o.add('  blank TWICE, stands    ' + String.join(blankTwice, ', '));
            }
            List<String> fams = new List<String>(pairsByFamily.keySet());
            fams.sort();
            for (String f : fams) {
                o.add('  ' + f.rightPad(22) + ' ' + pairsByFamily.get(f) + ' (unit: pairs)');
            }
            return String.join(o, '\n');
        }
    }

    /**
     * ONE READ PER FAMILY over the whole artifact. Matthew's ruling, 5 August.
     *
     * **The invocation count is `families.size()` and nothing else.** Not roster size, not
     * transcript length, not evidence density. That is the cost law preserved exactly: it
     * forbids crossing by person, which is unbounded, and crossing by family is bounded by the
     * declared set.
     *
     * **Refs are family-prefixed** so two families cannot collide on the pair key, and so a
     * ref reads as the family that produced it. Same bytes reached by different contracts in
     * different families is the INTENDED behaviour of this shape and is never deduplicated:
     * that is precisely the multi-establishment the sweep exists to make structural.
     */
    /**
     * THE SWEEP SPLITS CALLER-SIDE, one family read per transaction. Ruled 6 August from the
     * a20 timings, and it is the call 3 pattern applied one stage earlier.
     *
     * **The ceiling binds at the transaction, not the callout.** a20's worst single family
     * read was 15,580 ms, 13% of the 120-second budget and comfortable; the four of them in
     * one transaction were 57,054 ms, 48%, and the wall scales with transcript length AND
     * with the number of declared families. Twice this transcript, or a fifth family, breaches
     * it. Split, the binding number becomes the worst single read and the account grain's
     * future families cost nothing.
     *
     * `families()` names the reads and the caller drives them, so the call count is still
     * exactly `families.size()` and is still a function of nothing else - not roster, not
     * length, not density. The cost law is untouched; only the transaction boundary moved.
     *
     * The whole-sweep entry point below stays for tests and for a short artifact where four
     * reads are provably inside the budget. **It is not the production path**, and its own
     * report says the cumulative number so nobody has to remember which one they called.
     */
    public static List<String> sweepFamilies() {
        List<String> names = new List<String>(
            AAO_LocateCharter.families(AAO_RecallGate.declaredSet()).keySet()
        );
        names.sort();
        return names;
    }

    /** ONE family read, one transaction, one bounded callout. The production path. */
    public static SweepRun locateFamily(Id sourceId, String runKey, String family) {
        return sweep(sourceId, runKey, new List<String>{ family });
    }

    /**
     * Every family in one transaction. Kept for tests and short artifacts; see the note on
     * `locateFamily` for why it is not what a run should call.
     */
    public static SweepRun locateSweep(Id sourceId, String runKey) {
        return sweep(sourceId, runKey, null);
    }

    private static SweepRun sweep(Id sourceId, String runKey, List<String> only) {
        AAO_Source__c src = source(sourceId);
        List<AAO_Evidence_Contract__c> declared = AAO_RecallGate.declaredSet();
        Map<String, Id> idByCode = new Map<String, Id>();
        for (AAO_Evidence_Contract__c ec : declared) {
            idByCode.put(ec.AAO_Proposition_Code__c, ec.Id);
        }
        String version = AAO_LocateCharter.effectiveVersion(declared);
        Map<String, List<AAO_Evidence_Contract__c>> fams =
            AAO_LocateCharter.families(declared);

        SweepRun sweep = new SweepRun();
        List<AAO_Pair__c> all = new List<AAO_Pair__c>();
        List<String> famNames = new List<String>(fams.keySet());
        famNames.sort();
        if (only != null) {
            List<String> wanted = new List<String>();
            for (String f : famNames) {
                if (only.contains(f)) {
                    wanted.add(f);
                }
            }
            if (wanted.isEmpty()) {
                throw new PassException(
                    'No declared family named ' + only + '. Declared: ' + famNames + '.'
                );
            }
            famNames = wanted;
        }

        for (String fam : famNames) {
            List<AAO_Evidence_Contract__c> block = fams.get(fam);
            List<String> codes = new List<String>();
            for (AAO_Evidence_Contract__c ec : block) {
                codes.add(ec.AAO_Proposition_Code__c);
            }

            AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
            spec.stage = 'call1_sweep_' + fam.deleteWhitespace().toLowerCase();
            spec.charter = 'AAO_LocateCharter';
            spec.charterVersion = version;

            List<String> body = new List<String>{
                AAO_LocateCharter.rubricBlock(block),
                '# The transcript\n\n' + src.AAO_Normalized_Text__c
            };
            Map<String, Object> schema = AAO_LocateCharter.schema(codes);

            AAO_Extract.StageResult sr = AAO_Extract.callStage(
                spec, AAO_LocateCharter.systemPrompt(), body, schema
            );
            sweep.calls.add(sr);
            sweep.serialMs += sr.elapsedMs;

            AAO_LocateCharter.Result parsed = AAO_LocateCharter.parse(sr.rawText, codes);

            // THE BLANK-RETRY GUARD, ruled 6 August from this build's own measurement.
            //
            // Two repeat sweeps on one frozen artifact under a byte-identical stamp returned
            // criteria 0 / 10 / 8 and sentiment 8 / 10 / 0. A family read either works or
            // comes back with nothing, and WHICH family it happens to is not stable - so the
            // zero is not a property of the questions and cannot be fixed by rewording them.
            //
            // The blank has a signature: it is CHEAP. The blank sentiment read finished in
            // 6,587 ms at 307 output tokens against 16,453 ms at 959 on the read that found
            // ten. It does not labour and fail; it returns early. So one re-invocation, once,
            // on that signature only.
            //
            // **It never forces pairs.** A second zero stands and is journalled, because a
            // family with genuinely nothing in it is a real and common answer - §P8.5 says
            // criteria are sparse and a rich harvest is a calibration alarm. What the guard
            // refuses is accepting a single cheap blank as a family's ONLY look. Both
            // invocations are on the record either way.
            //
            // Partitioning stays behind this, unbuilt, for the OTHER mode: the within-read
            // miss, where the family answers and one establishment goes missing. That is
            // q9's shape and this guard cannot see it. The two are never conflated again.
            if (parsed.pairs.isEmpty() && looksLikeACheapBlank(sr)) {
                sweep.blankRetries++;
                AAO_Extract.StageResult retry = AAO_Extract.callStage(
                    spec, AAO_LocateCharter.systemPrompt(), body, schema
                );
                sweep.calls.add(retry);
                sweep.serialMs += retry.elapsedMs;
                AAO_LocateCharter.Result second = AAO_LocateCharter.parse(retry.rawText, codes);
                if (second.pairs.isEmpty()) {
                    sweep.blankTwice.add(fam);
                } else {
                    sweep.blankRecovered.add(fam);
                    sr = retry;
                    parsed = second;
                }
            }
            sweep.parsed += parsed.pairs.size();
            sweep.coverageDefaulted += AAO_LocateCharter.coverageDefaulted;
            sweep.rejected.addAll(parsed.rejected);

            // The family prefix is what keeps two reads' refs from colliding on the pair key.
            String prefix = fam.substring(0, 2).toLowerCase();
            for (AAO_LocateCharter.Pair p : parsed.pairs) {
                p.ref = prefix + p.ref;
            }

            AAO_Locate.Located loc = AAO_Locate.locate(
                src, parsed.pairs, runKey, version, idByCode
            );
            sweep.located += loc.rows.size();
            sweep.discardedNoMatch += loc.discardedNoMatch;
            sweep.discardedCrossesTurns += loc.discardedCrossesTurns;
            sweep.discardNotes.addAll(loc.discardNotes);
            sweep.pairsByFamily.put(fam, loc.rows.size());
            all.addAll(loc.rows);
        }

        // One insert after every callout: the callout-then-DML order is the caller's sequence
        // to hold, exactly as AAO_Locate.write keeps it out of the locator.
        if (!all.isEmpty()) {
            insert all;
        }
        return sweep;
    }

    /**
     * THE CHEAP-BLANK SIGNATURE, measured rather than guessed.
     *
     * A working family read on the 17 June artifact spends 16 to 21 seconds and 950 to 1,900
     * output tokens. The blank spends 6.6 seconds and 307. The threshold sits between them
     * with room on both sides, and it is deliberately generous toward NOT retrying: a read
     * that laboured and honestly found nothing is a real answer and must not be second-guessed
     * into producing something.
     *
     * The numbers live here rather than in a document, per the standing rule that measurements
     * live in BUILD_JOURNAL and code, never in the architecture.
     */
    @TestVisible
    private static Integer BLANK_MAX_OUTPUT_TOKENS = 600;
    @TestVisible
    private static Long BLANK_MAX_MS = 12000;

    private static Boolean looksLikeACheapBlank(AAO_Extract.StageResult sr) {
        if (sr == null || sr.usage == null) {
            return false;
        }
        Integer out = sr.usage.outputTokens == null ? 0 : sr.usage.outputTokens;
        Long ms = sr.elapsedMs == null ? 0 : sr.elapsedMs;
        return out <= BLANK_MAX_OUTPUT_TOKENS && ms <= BLANK_MAX_MS;
    }

    // ====================================================================== call 3 · verify

    public class VerifyRun {
        public AAO_Extract.StageResult call;
        public List<AAO_VerifyPairsCharter.Verdict> verdicts;
        public Integer upheld = 0;
        public Integer refused = 0;
        public Integer batches = 0;
    }

    /**
     * CLAIMS PER CALL-3 CALL. §P8.0 already rules that call 3 splits per claim batch; this is
     * that split, and its first size was set by a defect rather than by a preference.
     *
     * Handed fourteen claims in one call against a schema description saying one verdict per
     * claim in order never omitting, the reader returned ONE. The parse law caught it and
     * threw, which is the check doing its job. **The obvious repair — `minItems` on the array
     * — is not available: the Messages API rejects `minItems` values other than 0 or 1
     * outright, measured 5 August, 400 invalid_request_error.** So the count cannot be a
     * schema bound and must be a batch size, which is what the charter said to build anyway.
     *
     * **A batch of four then failed differently and worse:** handed q1/q10/q11/q12, the reader
     * returned q1 twice. The parse law caught that too. So the size drops to ONE, which is
     * §P8.3's own sentence — *sees one identified claim and its quote* — and is the setting
     * where the blindness argument is strongest, since a reader holding four claims can let
     * one inform another. The cost is real and is measured rather than assumed: fourteen
     * calls instead of four. Raising it is a measurement, not a preference, and it needs the
     * mis-referencing to stop first.
     */
    public static final Integer VERIFY_BATCH = 1;

    /**
     * ONLY IDENTIFIED-TO-A-PERSON ROWS GO IN FRONT OF THE READER. A None or an Ambiguous row
     * has no claim on it, so there is nothing to verify and nothing is owed — which is
     * exactly what `assertOneForOne(runKey, true)` counts against.
     *
     * The reader is handed the question, the meaning, and the words. It is NOT handed the
     * person, and `AAO_VerifyPairsCharter` records why.
     */
    /**
     * DRIVEN ACROSS TRANSACTIONS, and the sweep is why.
     *
     * At one claim per call and ~5 s each, forty claims is ~200 s of cumulative callout time
     * against a 120-second per-transaction ceiling that is law-grade and unraiseable. So
     * `verify` takes only unverified claims, up to `maxClaims`, and the caller drives it until
     * none remain. **The sweep doubled the harvest and thereby made call 3 the first stage
     * that cannot finish in one transaction** — recorded as a real consequence of the ruling
     * rather than discovered later by a timeout.
     */
    public static VerifyRun verify(String runKey) {
        return verify(runKey, 1000);
    }

    public static VerifyRun verify(String runKey, Integer maxClaims) {
        List<AAO_Pair__c> claims = [
            // DEFECT, MINE, CAUGHT ON THE FIRST EMERSON RUN: this selected AAO_Meaning__c
            // from the IDENTIFIED row, where it is always null because the ledger's own
            // trigger forbids call 2 from carrying it. So the blind reader was handed "the
            // words below answer that question" with NO MEANING — and for a sentiment claim
            // that removes the scope check entirely, which is the one thing §P8.3 adds for
            // sentiment. The meaning lives on the located row and is read from there.
            SELECT Id, AAO_Pair_Ref__c,
                AAO_Located_Pair__r.AAO_Meaning__c,
                AAO_Located_Pair__r.AAO_Coverage__c,
                AAO_Located_Pair__r.AAO_Answer_Text__c,
                AAO_Located_Pair__r.AAO_Start_Offset__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Text__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey
                AND AAO_Stage__c = :AAO_PairKey.IDENTIFIED
                AND AAO_Disposition__c = 'Identified'
                AND AAO_Verification__c = null
            ORDER BY AAO_Located_Pair__r.AAO_Start_Offset__c
            LIMIT :maxClaims
        ];
        if (claims.isEmpty()) {
            throw new PassException(
                'No unverified identified claims on run ' + runKey + '. Call 3 verifies ' +
                'claims that exist and have not been verified.'
            );
        }

        Map<String, AAO_Pair__c> byRef = new Map<String, AAO_Pair__c>();
        for (AAO_Pair__c c : claims) {
            byRef.put(c.AAO_Pair_Ref__c, c);
        }

        VerifyRun r = new VerifyRun();
        r.verdicts = new List<AAO_VerifyPairsCharter.Verdict>();
        List<AAO_Pair__c> stamp = new List<AAO_Pair__c>();

        for (Integer start = 0; start < claims.size(); start += VERIFY_BATCH) {
            List<AAO_Pair__c> batch = new List<AAO_Pair__c>();
            for (Integer i = start; i < Math.min(start + VERIFY_BATCH, claims.size()); i++) {
                batch.add(claims[i]);
            }
            List<String> refs = new List<String>();
            // The contract code travels with the ref so call 3's schema can carry the
            // occasion-versus-solution conjunct on sentiment and on nothing else.
            List<String> codes = new List<String>();
            List<String> block = new List<String>{ '# The claims', '' };
            for (AAO_Pair__c c : batch) {
                refs.add(c.AAO_Pair_Ref__c);
                codes.add(c.AAO_Evidence_Contract__r.AAO_Proposition_Code__c);
                block.add('## ' + c.AAO_Pair_Ref__c);
                block.add('Question: ' + c.AAO_Evidence_Contract__r.AAO_Proposition_Text__c);
                // THE PLACEMENT NEVER REACHES THE BLIND READER. Ruled 5 August from the
                // first Emerson grading: call 3 verifies the proposition and nothing else.
                // `carriesChoice` is false for the fifteen one-way families, where the
                // meaning IS the placement, so there is no branch here that can leak it —
                // the wrong answer is unexpressible rather than instructed against, the same
                // move as call 1 having no person field and this call having no ref field.
                String voiced =
                    AAO_LocateCharter.carriesChoice(
                        c.AAO_Evidence_Contract__r.AAO_Proposition_Code__c
                    )
                        ? c.AAO_Located_Pair__r.AAO_Meaning__c
                        : null;
                block.add('The claim: the words below answer that question' +
                    (String.isBlank(voiced) ? '' : ', and what they voice is ' + voiced) + '.');
                block.add('Words: "' + c.AAO_Located_Pair__r.AAO_Answer_Text__c + '"');
                block.add('');
            }

            AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
            spec.stage = 'call3_verify';
            spec.charter = 'AAO_VerifyPairsCharter';
            spec.charterVersion = AAO_VerifyPairsCharter.VERSION;

            AAO_Extract.StageResult sr = AAO_Extract.callStage(
                spec,
                AAO_VerifyPairsCharter.systemPrompt(),
                new List<String>{ String.join(block, '\n') },
                refs.size() == 1
                    ? AAO_VerifyPairsCharter.schemaOne(codes[0])
                    : AAO_VerifyPairsCharter.schema(refs)
            );
            if (r.call == null) {
                r.call = sr;
            } else {
                // The batches are one logical call for reporting; the numbers add.
                r.call.usage.inputTokens += sr.usage.inputTokens;
                r.call.usage.outputTokens += sr.usage.outputTokens;
                r.call.elapsedMs += sr.elapsedMs;
            }
            r.batches++;
            if (refs.size() == 1) {
                r.verdicts.add(AAO_VerifyPairsCharter.parseOne(sr.rawText, refs[0], codes[0]));
            } else {
                r.verdicts.addAll(AAO_VerifyPairsCharter.parse(sr.rawText, refs));
            }
        }

        for (AAO_VerifyPairsCharter.Verdict v : r.verdicts) {
            AAO_Pair__c row = byRef.get(v.pairRef);
            row.AAO_Verification__c = v.carries == true ? 'Upheld' : 'Refused';
            row.AAO_Verification_Note__c = v.reason;
            if (v.carries == true) { r.upheld++; } else { r.refused++; }
            stamp.add(row);
        }
        update stamp;
        return r;
    }

    // ==================================================================== call 2 · identify

    public class IdentifyRun {
        public AAO_Extract.StageResult call;
        public List<AAO_IdentifyCharter.Disposition> dispositions;
        public List<AAO_Pair__c> rows = new List<AAO_Pair__c>();
        public Integer toAPerson = 0;
        public Integer none = 0;
        public Integer ambiguous = 0;
    }

    /**
     * THE CLOSED CANDIDATE LIST IS THE SOURCE'S PARTICIPANTS, and that is a deliberate
     * narrowing of §P8.1's `people` array for this run. Call 1 also reports people the call
     * merely TALKED ABOUT, and those are real candidates in the charter — but a mentioned
     * person has no Participant row, so a disposition naming one could not be written to
     * `AAO_Person__c` and would have to be dropped after being paid for. Named rather than
     * silently scoped: mentioned-person candidates need the shadow-creation path, which is
     * the gates' work and is not built.
     */
    public static IdentifyRun identify(Id sourceId, String runKey) {
        AAO_Source__c src = source(sourceId);
        List<AAO_Pair__c> located = [
            SELECT Id, AAO_Pair_Ref__c, AAO_Answer_Text__c, AAO_Meaning__c, AAO_Coverage__c,
                AAO_Start_Offset__c, AAO_End_Offset__c, AAO_Speaker_Key__c,
                AAO_Charter_Version__c, AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Text__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.LOCATED
            ORDER BY AAO_Start_Offset__c
        ];
        if (located.isEmpty()) {
            throw new PassException(
                'No located pairs on run ' + runKey + '. Call 2 identifies pairs that exist ' +
                'and there is nothing to identify.'
            );
        }

        List<AAO_IdentifyCharter.Candidate> candidates = candidates(sourceId);
        Map<String, Id> participantByHandle = new Map<String, Id>();
        List<String> handles = new List<String>();
        for (AAO_IdentifyCharter.Candidate c : candidates) {
            handles.add(c.handle);
            participantByHandle.put(c.handle, c.participantId);
        }

        List<String> refs = new List<String>();
        for (AAO_Pair__c p : located) {
            refs.add(p.AAO_Pair_Ref__c);
        }

        AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
        spec.stage = 'call2_identify';
        spec.charter = 'AAO_IdentifyCharter';
        spec.charterVersion = AAO_IdentifyCharter.VERSION;

        IdentifyRun r = new IdentifyRun();
        r.call = AAO_Extract.callStage(
            spec,
            AAO_IdentifyCharter.systemPrompt(),
            new List<String>{
                AAO_IdentifyCharter.candidateBlock(candidates),
                excerptBlock(src, located)
            },
            AAO_IdentifyCharter.schema(refs, handles)
        );
        r.dispositions = AAO_IdentifyCharter.parse(r.call.rawText, refs);

        Map<String, AAO_Pair__c> byRef = new Map<String, AAO_Pair__c>();
        for (AAO_Pair__c p : located) {
            byRef.put(p.AAO_Pair_Ref__c, p);
        }
        for (AAO_IdentifyCharter.Disposition d : r.dispositions) {
            AAO_Pair__c parent = byRef.get(d.pairRef);
            String disposition;
            Id person;
            if (d.person == AAO_IdentifyCharter.NONE) {
                disposition = 'None';
                r.none++;
            } else if (d.person == AAO_IdentifyCharter.AMBIGUOUS) {
                disposition = 'Ambiguous';
                r.ambiguous++;
            } else {
                disposition = 'Identified';
                person = participantByHandle.get(d.person);
                if (person == null) {
                    // Structurally unreachable: the enum is closed from these handles. If it
                    // happens it is ours, so it throws rather than quietly becoming a None.
                    throw new PassException(
                        'Call 2 named handle "' + d.person + '", which is not in the closed ' +
                        'list. This is our bug, per the parse law.'
                    );
                }
                r.toAPerson++;
            }
            r.rows.add(new AAO_Pair__c(
                AAO_Stage__c = AAO_PairKey.IDENTIFIED,
                AAO_Run_Key__c = runKey,
                AAO_Pair_Ref__c = d.pairRef,
                AAO_Charter__c = 'People',
                AAO_Charter_Version__c = AAO_IdentifyCharter.VERSION,
                AAO_Located_Pair__c = parent.Id,
                AAO_Source__c = sourceId,
                AAO_Artifact_SHA256__c = src.AAO_SHA256__c,
                AAO_Evidence_Contract__c = parent.AAO_Evidence_Contract__c,
                AAO_Disposition__c = disposition,
                AAO_Person__c = person,
                AAO_Identification_Basis__c = d.basis == null ? null : d.basis.abbreviate(255)
            ));
        }
        insert r.rows;
        return r;
    }

    /**
     * The excerpt block: each pair's quote with `WINDOW_TURNS` of context on each side.
     *
     * The window is a MEASURED number and this is its first setting, chosen rather than
     * measured, at two turns. Recorded as such in the journal: §P8.0 says the threshold is
     * measured and no document carries it, and a chosen number pretending to be a measured
     * one is the failure that law exists to prevent.
     */
    private static String excerptBlock(AAO_Source__c src, List<AAO_Pair__c> located) {
        List<AAO_NormalForm.Turn> turns = AAO_NormalForm.turns(
            src.AAO_Normalized_Text__c, src.AAO_Diarization__c
        );
        List<String> out = new List<String>();
        out.add('# The quotes');
        out.add('');
        for (AAO_Pair__c p : located) {
            out.add('## ' + p.AAO_Pair_Ref__c);
            out.add('The first reader took these words to answer: ' +
                p.AAO_Evidence_Contract__r.AAO_Proposition_Text__c);
            out.add('Quote: "' + p.AAO_Answer_Text__c + '"');
            out.add('Context:');
            Integer at = indexOfTurn(turns, p.AAO_Start_Offset__c.intValue());
            Integer lo = Math.max(0, at - AAO_IdentifyCharter.WINDOW_TURNS);
            Integer hi = Math.min(turns.size() - 1, at + AAO_IdentifyCharter.WINDOW_TURNS);
            for (Integer i = lo; i <= hi; i++) {
                AAO_NormalForm.Turn t = turns[i];
                out.add('  ' + (i == at ? '>> ' : '   ') + t.speakerKey + ': ' + t.utterance);
            }
            out.add('');
        }
        return String.join(out, '\n');
    }

    private static Integer indexOfTurn(List<AAO_NormalForm.Turn> turns, Integer offset) {
        for (Integer i = 0; i < turns.size(); i++) {
            if (offset >= turns[i].utteranceStart && offset <= turns[i].utteranceEnd) {
                return i;
            }
        }
        return 0;
    }

    /**
     * THE SPEAKER KEY IS ON THE CANDIDATE LINE AND THAT IS NOT AN ACCIDENT. Call 2's whole
     * job is attribution, and the roster key is what the excerpt block prints in front of
     * every turn. Giving it the display name alone would make it match names in prose
     * instead of speakers in turns.
     */
    public static List<AAO_IdentifyCharter.Candidate> candidates(Id sourceId) {
        List<AAO_IdentifyCharter.Candidate> out = new List<AAO_IdentifyCharter.Candidate>();
        for (AAO_Participant__c p : [
            SELECT Id, AAO_Roster_Key__c, AAO_Display_Name__c, AAO_Internal__c, AAO_Email__c
            FROM AAO_Participant__c
            WHERE AAO_Source__c = :sourceId
            ORDER BY AAO_Roster_Key__c
        ]) {
            AAO_IdentifyCharter.Candidate c = new AAO_IdentifyCharter.Candidate();
            c.handle = p.AAO_Roster_Key__c;
            c.display = p.AAO_Display_Name__c;
            c.side = p.AAO_Internal__c == true ? 'our side' : 'buyer side';
            c.participantId = p.Id;
            out.add(c);
        }
        if (out.isEmpty()) {
            throw new PassException(
                'Source ' + sourceId + ' has no participants, so call 2 has no closed list ' +
                'to identify against. Participation is written at ingest; a Source with none ' +
                'is an ingest defect rather than a quiet empty answer.'
            );
        }
        return out;
    }

    private static AAO_Source__c source(Id sourceId) {
        List<AAO_Source__c> rows = [
            SELECT Id, AAO_Normalized_Text__c, AAO_Diarization__c, AAO_SHA256__c,
                AAO_Source_Ref__c, AAO_Opportunity__c, AAO_Account__c,
                AAO_Evidence_Occurred__c
            FROM AAO_Source__c
            WHERE Id = :sourceId
        ];
        if (rows.isEmpty()) {
            throw new PassException('No Source ' + sourceId + '.');
        }
        return rows[0];
    }
}
