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
        AAO_Receipt.record(
            runKey, sourceId, AAO_Receipt.STAGE_LOCATE,
            new List<AAO_Extract.StageResult>{ r.call },
            r.located == null ? null : r.located.rows.size(), 0
        );
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
    /**
     * Call 0 with its run named, so its leg reaches the receipt.
     *
     * An overload rather than a changed signature: `resolve(sourceId)` is what every existing
     * driver and test calls, and a resolution belongs to a RUN rather than to a Source — the
     * comment below has said so since the receipt was only a gap. Callers that know their run key
     * pass it and get call 0's wall time journalled; callers that do not lose nothing they had.
     */
    public static ResolveRun resolve(Id sourceId, String runKey) {
        ResolveRun r = resolve(sourceId);
        AAO_Receipt.record(runKey, sourceId, AAO_Receipt.STAGE_RESOLVE, r.call);
        return r;
    }

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

        List<String> body = new List<String>{
            AAO_ResolverCharter.ontologyText(),
            String.join(block, '\n'),
            '# The transcript\n\n' + src.AAO_Normalized_Text__c
        };
        Map<String, Object> schema = AAO_ResolverCharter.schema(handles);

        // THE NAMED RETRY POLICY (thirty-fourth stamp), the fallback behind the schema fix.
        // The yes-is-the-quote schema makes yes-without-quote unexpressible, which should
        // end call 0's cold-flake; this is the backstop for any residual quote-law
        // violation (a quote the model invented that the byte check refuses). Exactly ONE
        // retry, both attempts journalled, a second failure stands and the run stops
        // honestly. Never a loop.
        Integer attempts = 0;
        while (true) {
            attempts++;
            r.call = AAO_Extract.callStage(
                spec, AAO_ResolverCharter.systemPrompt(), body, schema
            );
            try {
                r.verdict = AAO_ResolverCharter.parse(r.call.rawText, handles);
                // The two sides' quotes are checked against the frozen artifact here rather
                // than in the parse, because the parse holds the model's answer and this
                // holds it against the bytes - the same separation the pairs law makes one
                // stage later.
                AAO_ResolverCharter.locate(r.verdict, src.AAO_Normalized_Text__c);
                if (attempts > 1) {
                    r.routedNotDispatched.add(
                        'call 0 quote-law retry: attempt ' + attempts + ' succeeded after a ' +
                        'first quote-law violation. One retry only, both attempts on the record.'
                    );
                }
                break;
            } catch (AAO_ResolverCharter.CharterException e) {
                if (attempts >= 2) {
                    throw new PassException(
                        'Call 0 failed the quote law twice on run for source ' + sourceId +
                        '. One retry is the policy (thirty-fourth stamp); a second failure ' +
                        'stops the run rather than routing on an unchecked scope. Last: ' +
                        e.getMessage()
                    );
                }
                // fall through to the single retry
            }
        }

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
            // **SIDE-YES WITH DEAL-NONE DOES NOT DISPATCH.** Ruled 7 August, the silence law
            // reaching dispatch: the resolver abstains where it cannot decide, and nothing
            // writes. Opportunity-grain family reads against a deal that resolved to NONE
            // would locate pairs with no opportunity to land them on.
            //
            // **NONE is treated as honest rather than as a failure**, because expansion talk
            // routinely precedes any deal record: the B&V call scopes and prices an MCP
            // project that no open opportunity yet represents. That is the resolver being
            // right, not the resolver being stuck.
            //
            // Symmetrical with the backburnered account grain: routed, journalled with the
            // yes-quote as its reason, dispatching nothing. CARRIED to the Flags fold as the
            // expansion-detection specimen - a yes with NONE is an expansion detected before
            // its opportunity exists.
            Boolean namedADeal =
                r.verdict.opportunity != AAO_ResolverCharter.NO_DEAL &&
                r.verdict.opportunity != AAO_ResolverCharter.AMBIGUOUS;
            if (namedADeal) {
                r.dispatchedGrains.add('opportunity');
            } else {
                r.routedNotDispatched.add(
                    'opportunity grain: the call carries opportunity content and no candidate ' +
                    'deal fits (' + r.verdict.opportunity + '), so nothing dispatches and ' +
                    'nothing writes. The yes stands on its own words: "' +
                    r.verdict.opportunitySide.quote.abbreviate(160) + '"'
                );
            }
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
    /**
     * SUPERSEDED as the production path by `locateRead` (the twenty-seventh stamp): call 1
     * is two comprehensive reads, not four family reads. Kept callable for tests and for
     * history - the 5 August sweep ruling stands as superseded in place, never deleted.
     */
    public static SweepRun locateFamily(Id sourceId, String runKey, String family) {
        return sweep(sourceId, runKey, new List<String>{ family });
    }

    // ============================================== call 1 · TWO COMPREHENSIVE READS

    /**
     * ONE COMPREHENSIVE READ: the whole artifact, ALL declared families' question sets in
     * one prompt. Matthew's ruling, 8 August evening (twenty-seventh stamp), superseding
     * the family sweep: two reads, not one and not four, because inference drops things
     * and the reads' independent misses are the recall hedge.
     *
     * The caller drives read 1 and read 2 as separate transactions (and in parallel where
     * the platform allows); each is one bounded callout. Refs are read-prefixed (`r1q1`,
     * `r2q1`) so the two reads cannot collide on the pair key and so a ref reads as the
     * read that produced it. THE READS ARE NEVER MERGED HERE - the resolution stage owns
     * the merge, on contract plus byte-range intersection plus voiced meaning, never
     * string equality on quotes.
     *
     * The blank-retry guard rides along unchanged: a comprehensive read returning zero
     * pairs on a real sales call is even more suspicious than a family read doing so.
     */
    public static SweepRun locateRead(Id sourceId, String runKey, Integer readIndex) {
        if (readIndex != 1 && readIndex != 2) {
            throw new PassException(
                'Read index must be 1 or 2. Two comprehensive reads is the ruled shape: ' +
                'one misses things, four re-pays the sweep\'s cost for nothing.'
            );
        }
        AAO_Source__c src = source(sourceId);
        List<AAO_Evidence_Contract__c> declared = AAO_RecallGate.declaredSet();
        Map<String, Id> idByCode = new Map<String, Id>();
        List<String> codes = new List<String>();
        for (AAO_Evidence_Contract__c ec : declared) {
            codes.add(ec.AAO_Proposition_Code__c);
            idByCode.put(ec.AAO_Proposition_Code__c, ec.Id);
        }
        String version = AAO_LocateCharter.effectiveVersion(declared);

        AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
        spec.stage = 'call1_read' + readIndex;
        spec.charter = 'AAO_LocateCharter';
        spec.charterVersion = version;

        // THE CACHE PREFIX REORDER, thirtieth stamp item 1b: the ARTIFACT LEADS, carrying the
        // cache breakpoint (callStage puts it on block 0 when cachePrefix is true). The
        // transcript is the ~23,800-token block both reads send identically, so putting it
        // first makes it the cached prefix instead of the ~2,000-token rubric that led before.
        //
        // MEASURED, NOT ASSUMED, and the finding is reported rather than buried: prompt
        // caching matches the whole prefix INCLUDING the system message, and read A and read
        // B share one system prompt, so read B reuses read A's artifact prefix ONLY when the
        // reads run sequentially. Under the parallel reads (the stamp's own floor) neither
        // warms the other and cache_read stays 0 within the run; the win is realized under
        // production serialization and is measured in a sequential control, never claimed
        // from a parallel run. Call 0 and verify carry different system prompts and cannot
        // share this prefix at all, so the reorder is scoped to the reads where reuse is
        // even possible.
        List<String> body = new List<String>{
            '# The transcript\n\n' + src.AAO_Normalized_Text__c,
            AAO_LocateCharter.rubricBlock(declared)
        };
        Map<String, Object> schema = AAO_LocateCharter.schema(codes);

        SweepRun run = new SweepRun();
        AAO_Extract.StageResult sr = AAO_Extract.callStage(
            spec, AAO_LocateCharter.systemPrompt(), body, schema
        );
        run.calls.add(sr);
        run.serialMs += sr.elapsedMs;
        AAO_LocateCharter.Result parsed = AAO_LocateCharter.parse(sr.rawText, codes);

        // THE BLANK-RETRY GUARD IS RETIRED HERE, twenty-eighth stamp ("no more triple
        // checks"). Its trigger signature - output tokens and wall time measured on
        // per-family reads - was authored for a shape that no longer exists and matches
        // nothing about a comprehensive read. It survives on the sweep path as history. A
        // comprehensive read returning zero pairs is reported by its own numbers and, if
        // the two-read shape demonstrates a real cheap-blank mode, a guard is re-derived
        // from measurements of THIS shape rather than inherited from the old one - the
        // tuned-behaviour law applied to a guard.
        if (parsed.pairs.isEmpty()) {
            run.blankTwice.add('read' + readIndex);
        }
        run.parsed += parsed.pairs.size();
        run.coverageDefaulted += AAO_LocateCharter.coverageDefaulted;
        run.rejected.addAll(parsed.rejected);

        // The read prefix is what keeps the two reads' refs from colliding on the pair
        // key, exactly as the family prefix did for the sweep.
        for (AAO_LocateCharter.Pair p : parsed.pairs) {
            p.ref = 'r' + readIndex + p.ref;
        }

        AAO_Locate.Located loc = AAO_Locate.locate(src, parsed.pairs, runKey, version, idByCode);
        run.located += loc.rows.size();
        run.discardedNoMatch += loc.discardedNoMatch;
        run.discardedCrossesTurns += loc.discardedCrossesTurns;
        run.discardNotes.addAll(loc.discardNotes);
        run.pairsByFamily.put('read' + readIndex, loc.rows.size());
        AAO_Locate.write(loc);
        AAO_Receipt.record(
            runKey, sourceId, AAO_Receipt.STAGE_LOCATE + ' read ' + readIndex,
            run.calls, loc.rows.size(), 0
        );
        return run;
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
     * THE KEYED BATCH SIZE, twenty-seventh stamp. `schemaKeyed` makes the refs REQUIRED
     * OBJECT PROPERTIES, so omission and mis-referencing fail schema validation at the API
     * instead of parsing short - the structural completeness `minItems` could not provide
     * and the reason VERIFY_BATCH was pinned at one. Thirty is a starting size, bounded by
     * schema bulk rather than by trust; the timing gate measures it.
     *
     * Batches are homogeneous BY CONJUNCT, not by contract: the target question binds
     * sentiment and nothing else, so sentiment claims batch together and every other
     * family shares the plain shape. That is what makes one or two callouts per run
     * possible instead of one per contract code.
     */
    /**
     * The internal keyed sub-batch size, now PINNED TO THE GRAMMAR-BUDGET CAP (15, below).
     * It was 30, which is what let a ~24-claim bucket make one over-ceiling call and 400 on
     * `pf0808-i1`. At the cap, any bucket or shard sub-batches at 15, sequentially within its
     * transaction, and no single keyed call ever crosses the compiled-grammar ceiling -
     * independent of how many shards the caller drives. Sharding buys parallelism; this buys
     * grammar safety. A literal rather than a reference to the constant below, because Apex
     * initialises static finals in declaration order and this one leads.
     */
    public static final Integer VERIFY_KEYED_BATCH = 15;

    /**
     * THE GRAMMAR BUDGET, thirty-fourth stamp. The model gateway rejects a keyed schema whose
     * compiled grammar is too large ("compiled grammar is too large... reduce the number of
     * strict tools", a 400). Keyed schemas are how this build enforces completeness (one
     * required property per unit), so the ceiling scales with unit count.
     *
     * **THE CAP IS MEASURED, NOT AUTHORED IN LAW TEXT** (the ruling's own words): a single
     * plain bucket of 22 claims passed (`pf0808-h1`); ~24 claims 400'd (`pf0808-i1`). The cap
     * sits at 15 - comfortably below the observed 22-24 boundary with margin for a denser
     * schema (more properties per unit, e.g. sentiment's target field). The number lives here
     * and in BUILD_JOURNAL, never in a charter or a document as law. **shardCount is a
     * REQUIRED FUNCTION OF DENSITY, never a tuning knob:** the caller derives it from
     * `keyedShardCount`, and a 400 that fires despite the cap stops the run loudly (the
     * AAO_Extract 400 throw propagates), a ceiling like any governor.
     */
    public static final Integer GRAMMAR_CAP_UNITS = 15;

    /**
     * ===== R1 · THE SECOND CEILING, AND IT IS TIME RATHER THAN GRAMMAR.
     *
     * The hundred-thirteenth stamp's finding: **the 120-second cumulative-callout ceiling this
     * project has measured against since the sixteenth stamp is not the wall that actually
     * fails.** A callout with `AAO_Timeout_Ms__c = 120000` set DIED AT ~88,000 ms - 73% of a
     * ceiling it never reached - because the model gateway's own response wall is lower,
     * variable, and was unmeasured. Every timing table this project published reported worst
     * callout as a percentage of 120,000 ms, and that percentage was safe against the wrong
     * number. So R1's cap is derived against the MEASURED wall, which is what this is.
     *
     * **THE MEASUREMENT, from every verify callout the org has on record** (17 of them across
     * `wf-s3`, `wf-s4`, `wf-s5`, `pf0813-uphold`, `em0813-stack-c1`, `em0813-stack-c2`):
     *
     *   largest callout that SUCCEEDED   82,213 ms   (68 claims, wf-s5)
     *   observed death                  ~88,000 ms   (hundred-thirteenth stamp)
     *
     * so the wall sits inside a 5,787 ms band and 88,000 is the number we have actually hit.
     */
    public static final Integer MEASURED_GATEWAY_WALL_MS = 88000;

    /** 75% headroom, the same fraction as the 90-second split trigger and the 112-DML trigger. */
    public static final Integer CALLOUT_BUDGET_MS = 66000;

    /**
     * **THE WORST OBSERVED RATE, NOT THE AVERAGE ONE, and that choice is the whole finding.**
     *
     * Across the 17 measured callouts a least-squares fit gives `ms = 1303*claims + 2629` and it
     * is nearly worthless as a predictor: the residual spans +21,258 to -9,039 ms, and **three
     * calls of IDENTICAL size, 12 claims each, took 15,287, 25,462 and 39,526 ms** - a 2.6x
     * spread at fixed input. Per-claim time barely predicts anything; variance dominates.
     *
     * A cap must hold on a SLOW call, not on an average one, so it derives from the worst rate
     * measured (3,294 ms per claim, the 12-claim call that took 39,526 ms). The median rate of
     * 1,322 would have yielded a cap of 49 - which is larger than the 47- and 68-claim calls
     * that produced this whole line of work.
     */
    public static final Integer WORST_MS_PER_UNIT = 3294;

    /** floor(budget / worst rate). 66,000 / 3,294 = 20 units. Derived, never authored. */
    public static final Integer TIME_CAP_UNITS = 20;

    /**
     * ===== THE BINDING CEILING WINS, AND WHICH ONE BINDS IS A FACT RATHER THAN A BELIEF.
     *
     * Two independent ceilings on one call, measured separately and neither implied by the
     * other: the compiled-grammar 400 at ~22-24 units, and the gateway's response wall in time.
     * **Today grammar binds at 15 against time's 20**, so R1 changes no number and that is the
     * honest result of the derivation rather than a reason not to have made it - a cap asserted
     * to be safe and a cap measured to be safe are different facts, and only one of them
     * survives the corpus growing.
     *
     * At the binding cap, a call reaches `15 * 3,294 = 49,407 ms`, **56% of the measured wall**,
     * which is the first time this project has been able to say that sentence about the wall
     * that actually fails. Written as a minimum so that if either ceiling moves - the grammar
     * budget raised, or the measured rate worsening as Process adds claims to verify - the
     * tighter one takes over without anybody remembering to.
     */
    public static final Integer MAX_UNITS_PER_KEYED_CALL =
        GRAMMAR_CAP_UNITS < TIME_CAP_UNITS ? GRAMMAR_CAP_UNITS : TIME_CAP_UNITS;

    /** ceil(units / cap), at least one. The derivation the grammar budget makes mandatory. */
    public static Integer keyedShardCount(Integer unitCount) {
        if (unitCount == null || unitCount <= 0) {
            return 1;
        }
        return (unitCount + MAX_UNITS_PER_KEYED_CALL - 1) / MAX_UNITS_PER_KEYED_CALL;
    }

    /**
     * The shard count a bucket's verify REQUIRES, derived from its unverified-claim count
     * against the measured cap. The caller drives exactly this many concurrent shards; it
     * never picks a number itself.
     *
     * **THIS NUMBER IS ONLY CORRECT FOR SHARDS THAT RUN CONCURRENTLY, and a serial driver that
     * ignores that will silently leave pairs unverified.** Measured on `pf0813-uphold`, 13
     * August: each shard slices the set that is unverified WHEN IT RUNS, so fired together the
     * four slices partition one set and cover it. Fired one after another, shard 0 verifies its
     * slice and commits, shard 1 then slices an ALREADY-SMALLER set and takes a smaller share,
     * and so on — 15, 11, 8, 6 where four equal slices were planned, leaving 18 of 67 pairs
     * unverified with no error anywhere. It took two further rounds to drain.
     *
     * This is not a pipeline defect: the express lane fires the shards together and the
     * partition is exact. It is a contract on the CALLER, so it is written here rather than in
     * a report nobody reruns.
     *
     * **A SERIAL DRIVER MUST RE-ASK AND RE-DRIVE UNTIL THE BUCKET IS EMPTY** — recompute this
     * number, take shard 0 of the new count, repeat while it returns anything. That loop is
     * correct under both execution shapes, so a driver that cannot guarantee concurrency should
     * simply always use it.
     */
    public static Integer plannedVerifyShards(String runKey, String bucket) {
        Boolean wantSentiment = bucket == 'sentiment';
        Integer n = 0;
        for (AAO_Pair__c c : [
            SELECT AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey
                AND AAO_Stage__c = :AAO_PairKey.IDENTIFIED
                AND AAO_Disposition__c = 'Identified'
                AND AAO_Verification__c = null
        ]) {
            Boolean isSentiment = AAO_VerifyPairsCharter.takesTarget(
                c.AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            );
            if (isSentiment == wantSentiment) {
                n++;
            }
        }
        return keyedShardCount(n);
    }

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
        return verifyImpl(runKey, 1000, null, 1, 0);
    }

    public static VerifyRun verify(String runKey, Integer maxClaims) {
        return verifyImpl(runKey, maxClaims, null, 1, 0);
    }

    /**
     * VERIFY IS PARALLELIZED BY CONJUNCT BUCKET, thirtieth stamp item 1a: the reads' own
     * proven pattern applied to call 3. The caller drives one bucket per transaction and
     * fires them concurrently, exactly as it fires the two reads.
     *
     * **The two-batch split at 29 claims was CONJUNCT-HOMOGENEITY, never a size split**, and
     * that answers the stamp's question: the target field binds sentiment and nothing else,
     * so a sentiment claim and a Buyer Role claim can never share one schema. The multi-batch
     * shape is therefore PERMANENT whenever a run carries both kinds, and parallelism is the
     * whole fix rather than a tuning of batch size.
     *
     * `bucket` is 'sentiment' or 'plain'; `shardCount`/`shardIndex` split a bucket further
     * for a denser transcript (every shardCount-th claim from shardIndex), so a bucket that
     * would cross the 90-second trigger is driven as concurrent shards rather than one long
     * transaction. An empty bucket returns an empty run rather than throwing, because the
     * caller fires both buckets speculatively without knowing which are populated.
     */
    public static VerifyRun verify(
        String runKey, String bucket, Integer shardCount, Integer shardIndex
    ) {
        return verifyImpl(runKey, 1000, bucket, shardCount, shardIndex);
    }

    private static VerifyRun verifyImpl(
        String runKey, Integer maxClaims, String bucket, Integer shardCount, Integer shardIndex
    ) {
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
            if (bucket != null) {
                // A speculatively-fired bucket with nothing owed is not an error.
                return new VerifyRun();
            }
            throw new PassException(
                'No unverified identified claims on run ' + runKey + '. Call 3 verifies ' +
                'claims that exist and have not been verified.'
            );
        }

        // THE BUCKET AND SHARD SELECTION, in memory over the ordered claims so the shard is
        // deterministic across concurrent transactions reading the same run.
        if (bucket != null) {
            Boolean wantSentiment = bucket == 'sentiment';
            List<AAO_Pair__c> ofBucket = new List<AAO_Pair__c>();
            for (AAO_Pair__c c : claims) {
                Boolean isSentiment = AAO_VerifyPairsCharter.takesTarget(
                    c.AAO_Evidence_Contract__r.AAO_Proposition_Code__c
                );
                if (isSentiment == wantSentiment) {
                    ofBucket.add(c);
                }
            }
            List<AAO_Pair__c> sharded = new List<AAO_Pair__c>();
            for (Integer i = 0; i < ofBucket.size(); i++) {
                if (Math.mod(i, shardCount) == shardIndex) {
                    sharded.add(ofBucket[i]);
                }
            }
            claims = sharded;
            if (claims.isEmpty()) {
                return new VerifyRun();
            }
        }

        Map<String, AAO_Pair__c> byRef = new Map<String, AAO_Pair__c>();
        for (AAO_Pair__c c : claims) {
            byRef.put(c.AAO_Pair_Ref__c, c);
        }

        VerifyRun r = new VerifyRun();
        r.verdicts = new List<AAO_VerifyPairsCharter.Verdict>();
        List<AAO_Pair__c> stamp = new List<AAO_Pair__c>();

        // **BATCHES ARE HOMOGENEOUS BY CONJUNCT** (twenty-seventh stamp). The target
        // question binds sentiment and nothing else, so sentiment claims batch together
        // under the target-bearing schema and every other family shares the plain one. The
        // old homogeneous-by-contract grouping existed to keep the conjunct off fields
        // where it is meaningless; this achieves the same with two buckets instead of
        // seventeen, which is what makes one or two callouts per run possible. The keyed
        // schema (refs as REQUIRED OBJECT PROPERTIES) is what makes a thirty-claim batch
        // trustworthy where the array shape under-returned at fourteen and at four.
        List<AAO_Pair__c> sentimentClaims = new List<AAO_Pair__c>();
        List<AAO_Pair__c> plainClaims = new List<AAO_Pair__c>();
        for (AAO_Pair__c c : claims) {
            if (AAO_VerifyPairsCharter.takesTarget(
                c.AAO_Evidence_Contract__r.AAO_Proposition_Code__c)) {
                sentimentClaims.add(c);
            } else {
                plainClaims.add(c);
            }
        }
        List<List<AAO_Pair__c>> buckets = new List<List<AAO_Pair__c>>();
        for (Integer start = 0; start < plainClaims.size(); start += VERIFY_KEYED_BATCH) {
            List<AAO_Pair__c> b = new List<AAO_Pair__c>();
            for (Integer i = start;
                 i < Math.min(start + VERIFY_KEYED_BATCH, plainClaims.size()); i++) {
                b.add(plainClaims[i]);
            }
            buckets.add(b);
        }
        for (Integer start = 0; start < sentimentClaims.size(); start += VERIFY_KEYED_BATCH) {
            List<AAO_Pair__c> b = new List<AAO_Pair__c>();
            for (Integer i = start;
                 i < Math.min(start + VERIFY_KEYED_BATCH, sentimentClaims.size()); i++) {
                b.add(sentimentClaims[i]);
            }
            buckets.add(b);
        }

        for (List<AAO_Pair__c> batch : buckets) {
            Boolean sentiment = AAO_VerifyPairsCharter.takesTarget(
                batch[0].AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            );
            String conjunctCode = sentiment ? AAO_P8Codes.SENTIMENT : null;
            List<String> refs = new List<String>();
            List<String> block = new List<String>{ '# The claims', '' };
            for (AAO_Pair__c c : batch) {
                refs.add(c.AAO_Pair_Ref__c);
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

            // CALL 3 DISPATCHES THE CONFIGURED VERIFY MODEL, forty-first stamp ruling 1.
            //
            // The spec is still SEEDED from `inventorySpec()`, because the read spec is where
            // the output bound and the cache-prefix posture live and neither is what the
            // ruling moves. What the ruling moves is the MODEL: this borrowed the read model
            // and therefore ran verification on the same model that did the reading, while
            // `AAO_Verify_Model__c` sat in the config naming a different one. Config and code
            // now say the same thing, and `requireSeparateReaderAndVerifier` throws if they
            // ever converge again, so the drift cannot come back quietly.
            AAO_Extract.Config vcfg = AAO_Extract.config();
            AAO_Extract.requireSeparateReaderAndVerifier();
            AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
            spec.stage = 'call3_verify';
            spec.charter = 'AAO_VerifyPairsCharter';
            spec.charterVersion = AAO_VerifyPairsCharter.VERSION;
            spec.model = vcfg.verifyModel;
            // AND CALL 3 BUYS NO THINKING. `verifySpec()` has always omitted effort on purpose,
            // in its own words: the verifier "is answering a low-inference question about two
            // pieces of text, and buying thinking tokens for that is paying for deliberation
            // nobody asked for". Call 3 was carrying the READ's effort only because it seeds
            // from the read spec, which is the same borrowing ruling 1 corrects for the model.
            // The configured verifier refuses the parameter outright ("This model does not
            // support the effort parameter"), so leaving it set would have made ruling 1
            // unrunnable; the feature detection in AAO_Extract would now recover from that, and
            // this makes the recovery unnecessary rather than routine.
            spec.effort = null;
            // Attached HERE, at the site that actually dispatches call 3. The first attempt at
            // this wired `verifySpec()` and the wire still reported temp=unset, because that
            // spec belongs to the older extract-bind-verify path. Reads keep their variance:
            // `inventorySpec()` itself is never given a temperature.
            spec.temperature = vcfg.verifyTemperature;

            AAO_Extract.StageResult sr = AAO_Extract.callStage(
                spec,
                AAO_VerifyPairsCharter.systemPrompt(),
                new List<String>{ String.join(block, '\n') },
                refs.size() == 1
                    ? AAO_VerifyPairsCharter.schemaOne(conjunctCode)
                    : AAO_VerifyPairsCharter.schemaKeyed(refs, conjunctCode)
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
                r.verdicts.add(
                    AAO_VerifyPairsCharter.parseOne(sr.rawText, refs[0], conjunctCode)
                );
            } else {
                r.verdicts.addAll(
                    AAO_VerifyPairsCharter.parseKeyed(sr.rawText, refs, conjunctCode)
                );
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
        AAO_Receipt.record(
            runKey, AAO_Receipt.sourceForRun(runKey),
            AAO_Receipt.STAGE_VERIFY + (bucket == null ? '' : ' ' + bucket) +
                (shardCount != null && shardCount > 1 ? ' shard ' + shardIndex : ''),
            new List<AAO_Extract.StageResult>{ r.call }, r.upheld + r.refused, 0
        );
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
    /**
     * The default batch is THE MEASURED KEYED-CALL CAP, not a number large enough to mean
     * "all of them".
     *
     * It used to default to 1000, which was harmless while call 2's schema was an array and
     * merely optimistic. Since the schema became KEYED (13 August, Matthew's ruling) the
     * grammar ceiling binds here exactly as it binds call 3, so a caller handing 67 pairs
     * would build a schema with 67 required properties and 400 at the gateway. Defaulting to
     * the cap makes the safe thing the easy thing; the caller still drives the loop, which is
     * the contract this method has always had.
     */
    public static IdentifyRun identify(Id sourceId, String runKey) {
        return identify(sourceId, runKey, MAX_UNITS_PER_KEYED_CALL);
    }

    /** What the deterministic stage did, and what it left for the model leg. */
    public class DeterministicRun {
        public AAO_Resolve.Outcome outcome;
        public Integer flagsRaised = 0;
        public Integer flagsCleared = 0;

        /** True when the model leg has work. A clean transcript leaves this false. */
        public Boolean hasRemainder {
            get {
                return outcome != null && !outcome.remainder.isEmpty();
            }
        }

        public override String toString() {
            return outcome.toString() +
                '\nidentification raised   ' + flagsRaised + ' (unit: people)' +
                '\nidentification cleared  ' + flagsCleared + ' (unit: people)';
        }
    }

    /**
     * THE DETERMINISTIC STAGE, IN FRONT. The eighty-first stamp's item 3 ruled option (a),
     * the twenty-seventh stamp's own shape: `AAO_Resolve`'s legs dispose what a byte lookup
     * and a closed-list ladder can settle, and the model leg takes ONLY the remainder.
     *
     * Until this existed, `AAO_Resolve` had zero production callers and the pass drove
     * `identify` over every located pair - the divergence that stamp measured and closed.
     * Nothing in `AAO_Resolve` is rewritten here; it is retargeted, which is what wiring
     * proposal v3 ruled and why `AAO_Resolve.cls`'s ambiguity refusal is untouched.
     *
     * NAMED FOR CALL 2, NOT CALL 0. `resolve` on this class is already taken, and taken
     * correctly: it is call 0, the SCOPE resolver. This leg resolves IDENTITY, which is call
     * 2's job, so it carries call 2's word. Two different questions must not share a verb on
     * the one class that dispatches both.
     *
     * WHY IT IS ITS OWN ENTRY POINT AND ITS OWN TRANSACTION. This writes: dispositions,
     * mention participants, and flags. `identify` makes a CALLOUT. Callout-after-DML is
     * refused by the platform, and `AAO_Resolve.requests()` already throws by hand to say so.
     * So the caller runs this, commits, and then calls `identify` only when
     * `hasRemainder` - which on a clean transcript is never, and that zero is the
     * twenty-seventh stamp's predicted arithmetic rather than a failure.
     *
     * THE FLAG FIRES HERE, and this is the line that makes the Identification flag a
     * mechanism rather than a plan. `AAO_Resolve` collects held mentions and deliberately
     * never writes them; this is the caller that raises. Raise first, then reconcile, so a
     * run that both holds a designator and binds another closes what it can in one pass -
     * which is the read sheet's S5-01, a flag closing by identification.
     */
    public static DeterministicRun identifyDeterministic(Id sourceId, String runKey) {
        DeterministicRun r = new DeterministicRun();
        r.outcome = AAO_Resolve.run(sourceId, runKey);

        r.flagsRaised = AAO_Identification.raiseFor(r.outcome.held);

        // Re-read rather than infer: reconcile asks the org whether any held designator is
        // now bound to a Contact. A run that changed nothing clears nothing.
        Id oppId = source(sourceId).AAO_Opportunity__c;
        r.flagsCleared = AAO_Identification.reconcile(oppId);
        return r;
    }

    /**
     * The model leg's own raise, for the second held site. `AAO_Resolve.requests()` runs the
     * callout and then acts on the typed fields, so by the time its `RequestRun` exists the
     * callout is behind us and DML is lawful again. Kept as a separate call for the same
     * reason `resolve` is: the caller owns the transaction boundary, not this class.
     */
    public static Integer raiseHeld(AAO_Resolve.RequestRun requestRun) {
        if (requestRun == null) {
            return 0;
        }
        return AAO_Identification.raiseFor(requestRun.held);
    }

    /**
     * CALL 2 SPLITS BY PAIR BATCH, and the Project Farma run is why.
     *
     * Call 1 splits by family and call 3 by claim batch; call 2 was the one stage still handed
     * every located pair in a single call, because no fixture before this one produced enough.
     * The 73-minute Project Farma call located 59 pairs, and call 2 disposed ONE of them, twice,
     * and the one-for-one guard threw both times rather than let 58 vanish. That is the guard
     * doing exactly its job, and the fix is the same shape the other two calls already have.
     *
     * The batch is the closed set of refs handed to the schema, so the model is constrained to
     * return exactly this batch. Already-identified refs are excluded, so the caller drives it
     * until none remain, and the run-level one-for-one still checks located == disposed at the
     * end. No call retries by growing; the ceiling is split, not raised.
     */
    public static IdentifyRun identify(Id sourceId, String runKey, Integer maxPairs) {
        AAO_Source__c src = source(sourceId);
        Set<String> alreadyIdentified = new Set<String>();
        for (AAO_Pair__c p : [
            SELECT AAO_Pair_Ref__c FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.IDENTIFIED
        ]) {
            alreadyIdentified.add(p.AAO_Pair_Ref__c);
        }
        List<AAO_Pair__c> located = [
            SELECT Id, AAO_Pair_Ref__c, AAO_Answer_Text__c, AAO_Meaning__c, AAO_Coverage__c,
                AAO_Start_Offset__c, AAO_End_Offset__c, AAO_Speaker_Key__c,
                AAO_Charter_Version__c, AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Text__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.LOCATED
                AND AAO_Pair_Ref__c NOT IN :alreadyIdentified
            ORDER BY AAO_Start_Offset__c
            LIMIT :maxPairs
        ];
        if (located.isEmpty()) {
            throw new PassException(
                'No unidentified located pairs on run ' + runKey + '. Call 2 identifies pairs ' +
                'that exist and have not been identified.'
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
        AAO_Receipt.record(
            runKey, sourceId, AAO_Receipt.STAGE_IDENTIFY,
            new List<AAO_Extract.StageResult>{ r.call }, r.rows.size(), 0
        );
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
            // END-EXCLUSIVE, and this comparison used to read it as inclusive.
            //
            // `AAO_NormalForm` sets `utteranceEnd = lineStart + line.length()`, so the end is
            // ONE PAST the last character, and the last turn's end equals the body length
            // exactly (measured on the WF fixtures: 19,858 and 20,102 on bodies of exactly
            // those lengths). A point test written `offset <= utteranceEnd` therefore matches
            // BOTH the turn that ends at that offset and the turn that begins there, and takes
            // whichever comes first in the list - so a span starting exactly on a turn boundary
            // was attributed to the previous speaker.
            //
            // The sibling reader at `AAO_NormalForm:111` is NOT wrong and is deliberately left
            // alone: it tests a SPAN with `endOffset <= utteranceEnd`, and a span ending exactly
            // at the exclusive end genuinely is inside the turn. Point tests and range tests
            // read the same bound differently, which is exactly how this survived.
            if (offset >= turns[i].utteranceStart && offset < turns[i].utteranceEnd) {
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