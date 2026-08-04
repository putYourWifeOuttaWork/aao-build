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
                'wall clock, SERIAL       ' + serialMs + ' ms'
            };
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
    public static SweepRun locateSweep(Id sourceId, String runKey) {
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

            AAO_Extract.StageResult sr = AAO_Extract.callStage(
                spec,
                AAO_LocateCharter.systemPrompt(),
                new List<String>{
                    AAO_LocateCharter.rubricBlock(block),
                    '# The transcript\n\n' + src.AAO_Normalized_Text__c
                },
                AAO_LocateCharter.schema(codes)
            );
            sweep.calls.add(sr);
            sweep.serialMs += sr.elapsedMs;

            AAO_LocateCharter.Result parsed = AAO_LocateCharter.parse(sr.rawText, codes);
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
    public static VerifyRun verify(String runKey) {
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
            ORDER BY AAO_Located_Pair__r.AAO_Start_Offset__c
        ];
        if (claims.isEmpty()) {
            throw new PassException(
                'No identified claims on run ' + runKey + '. Call 3 verifies claims that ' +
                'exist.'
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

            AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
            spec.stage = 'call3_verify';
            spec.charter = 'AAO_VerifyPairsCharter';
            spec.charterVersion = AAO_VerifyPairsCharter.VERSION;

            AAO_Extract.StageResult sr = AAO_Extract.callStage(
                spec,
                AAO_VerifyPairsCharter.systemPrompt(),
                new List<String>{ String.join(block, '\n') },
                refs.size() == 1
                    ? AAO_VerifyPairsCharter.schemaOne()
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
                r.verdicts.add(AAO_VerifyPairsCharter.parseOne(sr.rawText, refs[0]));
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
