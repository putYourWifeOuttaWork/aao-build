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
        /**
         * WHEN IT STOPPED, AND HOW MANY TIMES, so a resume that fails again cannot be silent.
         *
         * The 141st's rider (i). The rehearsal's resume ran at 14:25:18, called the model twice
         * more, failed on a DIFFERENT scope than the first stop, and updated the receipt - and
         * Matthew reported it dead, because `stoppedBecause` carried a stage and a message and
         * nothing that changes between two failures of the same stage. A second failure that
         * renders identically to the first IS silence, whatever the receipt holds. The count
         * and the timestamp are what make a repeat legible as a new event.
         */
        @AuraEnabled public Datetime stoppedAt;
        @AuraEnabled public Integer stoppedAttempts = 0;
        // The ledger, live, so the surface shows evidence rather than only timings.
        @AuraEnabled public Integer located = 0;
        @AuraEnabled public Integer identified = 0;
        @AuraEnabled public Integer upheld = 0;
        @AuraEnabled public Integer refused = 0;
        @AuraEnabled public Integer claims = 0;
        @AuraEnabled public Integer answers = 0;
        @AuraEnabled public Integer cards = 0;

        /**
         * WHAT THE RUN COST, beside what it took. The 139th's item 1: a rehearsal that prints its
         * own token bill answers the cost question with a receipt instead of arithmetic.
         */
        @AuraEnabled public Long inputTokens = 0;
        @AuraEnabled public Long outputTokens = 0;
        @AuraEnabled public Long thinkingTokens = 0;
        @AuraEnabled public Long cacheReadTokens = 0;
        @AuraEnabled public Long cacheWriteTokens = 0;
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

        // NORMALISED BEFORE IT IS HASHED, never after. The hash is the byte-provenance key every
        // span is checked against, so it must be taken of the bytes actually STORED - hashing the
        // raw paste and storing the normalised form would make every offset check compare against
        // a string the org does not hold.
        String normalized = normalizePaste(text, roster);

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
            AAO_Normalized_Text__c = normalized,
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
            Crypto.generateDigest('SHA-256', Blob.valueOf(normalized))
        );
        src.AAO_Part_Index__c = 1;
        src.AAO_Part_Count__c = 1;

        // ===================== THE SAME BYTES ARE THE SAME OCCASION, SO THE SOURCE IS REUSED ==
        //
        // The hundred-twelfth stamp's item 3. Purge clears claims, answers, pairs, cards,
        // receipts and map rows, but **`AAO_Source__c` is undeletable on the live path** - claims
        // cite it and spans verify against it, which is the never-delete law holding correctly.
        // So `AAO_Scope_Key__c` (opportunity plus artifact hash) survives every purge, and
        // re-pasting the same transcript used to throw `DUPLICATE_VALUE` and make a deal
        // single-use per transcript.
        //
        // **REUSE IS MORE CORRECT THAN A SECOND ROW, not a workaround.** The same bytes on the
        // same deal ARE the same occasion; minting a second Source would assert a second
        // conversation happened, which is the thing this system exists not to do. Purge has
        // already removed everything derived from it, so re-enqueueing regenerates them.
        //
        // Matched on opportunity plus artifact hash rather than by rebuilding the scope key,
        // because the key's internal format is the trigger's to own and a caller reconstructing
        // it would be a second implementation of somebody else's rule.
        List<AAO_Source__c> standing = [
            SELECT Id FROM AAO_Source__c
            WHERE AAO_Opportunity__c = :opp.Id
              AND AAO_Artifact_SHA256__c = :src.AAO_Artifact_SHA256__c
            LIMIT 1
        ];

        Id sourceId;
        if (!standing.isEmpty()) {
            sourceId = standing[0].Id;
        } else {
            try {
                insert src;
            } catch (Exception e) {
                // THE CAUSE IS SURFACED, NEVER SWALLOWED (item 4). A generic "could not start
                // the run" hid a DUPLICATE_VALUE this morning, which is the silent-success
                // hazard in its third demo-surface instance after the ingest swallow and the
                // failure reporter. Whoever meets this next reads what actually happened.
                throw new AuraHandledException(
                    'The run could not start. The org said: ' + e.getMessage()
                );
            }
            sourceId = src.Id;
        }

        System.enqueueJob(new AAO_PassQueueable(sourceId, runKey));

        RunView v = new RunView();
        v.runKey = runKey;
        v.sourceId = sourceId;
        return v;
    }

    /**
     * PASTE TOLERANCE · `key: utterance` and `Display Name: utterance` become the canonical
     * `key<TAB>utterance`. The hundred-eleventh stamp's item 3, recommended and not blocking.
     *
     * A thirty-minute transcript pasted out of a document is exactly where a tab gets lost, and
     * the normal form wants tabs. So a line whose leading token before a colon matches a roster
     * KEY or a roster DISPLAY NAME is rewritten to the tab form; **everything else is left
     * exactly as it arrived.**
     *
     * THE CONSERVATISM IS THE POINT, and it is the never-invented law at the intake:
     *   - a line already carrying a tab is untouched, so the delivered tab-delimited transcripts
     *     take this path and come out byte-identical;
     *   - a colon that is not a speaker (`"Ideal state: two per person"`, a time, a URL) does not
     *     match a roster entry and is left alone;
     *   - an unmatched leading token is NEVER promoted to a speaker, because inventing a speaker
     *     is the one thing the roster law exists to prevent.
     *
     * Matching is on the roster the caller supplied, so this cannot reach past what the human
     * already declared about who was in the room.
     */
    // Public rather than TestVisible-private so it can be PROVED from the runtime, which is
    // where this project's capability law says a claim about behaviour has to be checked.
    public static String normalizePaste(String text, String roster) {
        if (String.isBlank(text)) {
            return text;
        }
        Set<String> known = new Set<String>();
        if (String.isNotBlank(roster)) {
            for (String line : roster.split('\n')) {
                List<String> parts = line.split(',');
                for (Integer i = 0; i < Math.min(2, parts.size()); i++) {
                    if (String.isNotBlank(parts[i])) {
                        known.add(parts[i].trim().toLowerCase());
                    }
                }
            }
        }
        if (known.isEmpty()) {
            return text;
        }

        List<String> out = new List<String>();
        for (String line : text.split('\n')) {
            if (line.contains('\t') || !line.contains(':')) {
                out.add(line);
                continue;
            }
            String head = line.substringBefore(':').trim();
            if (String.isBlank(head) || !known.contains(head.toLowerCase())) {
                out.add(line);
                continue;
            }
            out.add(head + '\t' + line.substringAfter(':').trim());
        }
        return String.join(out, '\n');
    }

    /**
     * PURGE THIS DEAL · the lawful purge, given a button.
     *
     * The hundred-eleventh stamp's item 1, and its own words on scope: **nothing here is new
     * about the deletion.** `AAO_Purge` is ruled, watermark-guarded and enumerated; this
     * discovers the run keys, deletes cards first so their junctions cascade rather than being
     * hand-deleted (the fifty-second stamp's incident), and hands the rest to the purge that
     * already exists.
     *
     * **A purge button on a sandbox harness is not a dismiss button on customer evidence** —
     * different object, different law, and the no-dismiss ruling is untouched.
     *
     * THE GUARDS ARE THE PURGE'S OWN AND ARE NOT WEAKENED HERE: a hand-edited map value still
     * aborts it, machine-Contact deletion is still bounded by the create-leg record, and a
     * non-synthetic flag stays undeletable. **A refusal is surfaced, never forced** - the caller
     * gets the reason as a message and the deal is left exactly as it was.
     */
    @AuraEnabled
    public static String purgeDeal(Id opportunityId) {
        if (opportunityId == null) {
            throw new AuraHandledException('No opportunity. This runs against a record.');
        }
        try {
            // The keys come from what the deal actually carries, never from a caller's memory:
            // receipts for runs that journalled, pairs for runs that did not get that far.
            Set<String> keys = new Set<String>();
            for (AAO_Run_Receipt__c r : [
                SELECT AAO_Run_Key__c FROM AAO_Run_Receipt__c
                WHERE AAO_Opportunity__c = :opportunityId AND AAO_Run_Key__c != null
            ]) {
                keys.add(r.AAO_Run_Key__c);
            }
            for (AAO_Pair__c p : [
                SELECT AAO_Run_Key__c FROM AAO_Pair__c
                WHERE AAO_Source__r.AAO_Opportunity__c = :opportunityId
                  AND AAO_Run_Key__c != null
                LIMIT 5000
            ]) {
                keys.add(p.AAO_Run_Key__c);
            }

            // CARDS FIRST. Deleting a card takes its placements and contact links by cascade;
            // deleting the junctions first orphans the card and was a live incident once.
            List<ALTF__Insight_Card__c> cards = [
                SELECT Id FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = :opportunityId
            ];
            Integer cardCount = cards.size();
            if (!cards.isEmpty()) {
                delete cards;
            }

            // ===== THE BOARD'S COLUMNS GO WITH THE CARDS, and only the ones we can PROVE we
            // wrote.
            //
            // Cards live inside sections, and deleting the cards left the columns standing empty
            // - three dated headers on a board with nothing under them, which reads as a purge
            // that half-worked.
            //
            // A section is a VENDOR object and carries no watermark of ours, so ours-ness cannot
            // be read off the row. What CAN be proved is the title: the writer composes it from
            // the Source's occurred date and meeting title, so the purge asks the writer what it
            // would have written and removes exactly those. **Matched on the EXACT title, never
            // on the date prefix** - `sectionFor` matches on the prefix so a human's better title
            // survives the next run, and by the same law a human's better title must survive the
            // PURGE. A retitled column is left standing, empty, rather than a person's words
            // deleted to tidy a board.
            //
            // The fifty-second stamp's incident is honoured by order: cards were deleted above,
            // so their placements have already cascaded and nothing here orphans a junction.
            Set<String> ourTitles = new Set<String>();
            for (AAO_Source__c src : [
                SELECT AAO_Evidence_Occurred__c, AAO_Meeting_Title__c
                FROM AAO_Source__c
                WHERE AAO_Opportunity__c = :opportunityId
            ]) {
                ourTitles.add(AAO_Cards.sectionTitle(src, null));
            }
            Integer sectionCount = 0;
            if (!ourTitles.isEmpty()) {
                List<ALTF__Insight_Section__c> ours = new List<ALTF__Insight_Section__c>();
                for (ALTF__Insight_Section__c sec : [
                    SELECT Id, ALTF__Short_Description__c
                    FROM ALTF__Insight_Section__c
                    WHERE ALTF__Opportunity__c = :opportunityId
                ]) {
                    if (ourTitles.contains(sec.ALTF__Short_Description__c)) {
                        ours.add(sec);
                    }
                }
                if (!ours.isEmpty()) {
                    delete ours;
                    sectionCount = ours.size();
                }
            }

            if (keys.isEmpty()) {
                return 'Nothing to purge beyond ' + cardCount + ' card(s) and ' + sectionCount +
                    ' board column(s): this deal carries no run keys.';
            }
            AAO_Purge.Outcome o = AAO_Purge.run(keys, opportunityId);

            // THE RESET CANNOT REMOVE THE PASTED ARTIFACT, and the org is right to refuse.
            //
            // A reset that leaves the bytes behind has a real consequence, so it is stated here
            // rather than discovered in a room: `AAO_Scope_Key__c` is `S1|opportunity|hash` and
            // unique, so **the same transcript cannot be pasted twice on one opportunity, purge
            // or no purge.** Rehearse a call on this deal and that call's bytes are spent here
            // forever.
            //
            // A first draft of this method tried to delete the spent Sources. The org refused it
            // outright - *"AAO_Source__c is not deletable on the live path. Claims cite it and
            // spans verify against it. Sources leave by retirement, confirm-then-purge"* - which
            // is the never-delete law holding, and the hundred-eleventh stamp's own line that
            // this button adds "nothing new about the deletion" turning out to be a description
            // of what the platform allows, not just a scope fence.
            //
            // **THE ANSWER IS A SECOND DEAL, NOT A DELETION**: rehearse on one opportunity and
            // present on another, so the room's deal meets each transcript for the first time.

            return 'Purged ' + cardCount + ' cards, ' + sectionCount + ' board columns, ' +
                o.claims + ' claims, ' + o.answers +
                ' answers, ' + o.pairs + ' pairs, ' + o.mapRows + ' map rows, ' + o.receipts +
                ' receipts across ' + keys.size() + ' run(s). The pasted artifacts stay (they ' +
                'are not deletable), so this deal will refuse those same transcripts again.';
        } catch (Exception e) {
            // SURFACED, NEVER FORCED. The commonest refusal is the human-watermark guard, which
            // is the purge protecting a person's edit and is exactly right.
            throw new AuraHandledException(
                'The purge refused and nothing was deleted beyond any cards already removed: ' +
                e.getMessage()
            );
        }
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

    /** One past run, enough to pick it out of a list without opening it. */
    public class RunOption {
        @AuraEnabled public String runKey;
        @AuraEnabled public String label;
        @AuraEnabled public Datetime startedAt;
        @AuraEnabled public Boolean finished = false;
        @AuraEnabled public Boolean stopped = false;
    }

    /**
     * EVERY RUN THIS DEAL STILL CARRIES, newest first.
     *
     * A refresh empties the component's own memory of what it ran, and before this the past was
     * simply unreachable from the paste surface - the work was still on the deal, but the
     * surface behaved as though nothing had happened. **A run that happened should be findable
     * from the place it was started.**
     *
     * Read from receipts, which is where a run's own account of itself lives; a run that
     * journalled nothing has nothing to show and is correctly absent.
     */
    @AuraEnabled
    public static List<RunOption> recentRuns(Id opportunityId) {
        List<RunOption> out = new List<RunOption>();
        if (opportunityId == null) {
            return out;
        }
        for (AAO_Run_Receipt__c r : [
            SELECT AAO_Run_Key__c, AAO_Stages__c, AAO_First_Stage_At__c, AAO_Last_Stage_At__c
            FROM AAO_Run_Receipt__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Run_Key__c != null
            ORDER BY AAO_First_Stage_At__c DESC NULLS LAST
            LIMIT 25
        ]) {
            RunOption o = new RunOption();
            o.runKey = r.AAO_Run_Key__c;
            o.startedAt = r.AAO_First_Stage_At__c;
            for (AAO_Receipt.Leg leg : AAO_Receipt.legsOf(r)) {
                if (String.isNotBlank(leg.error)) {
                    o.stopped = true;
                }
                if (leg.stage == AAO_Receipt.STAGE_CARDS && String.isBlank(leg.error)) {
                    o.finished = true;
                }
            }
            // A stopped run that was later resumed to the end is finished, not stopped: the
            // last word on a run is what it ended up doing, never what went wrong on the way.
            if (o.finished) {
                o.stopped = false;
            }
            o.label = o.runKey;
            out.add(o);
        }
        return out;
    }

    /**
     * RESUME A RUN THAT STOPPED, from the stage it stopped at.
     *
     * A callout timeout killed call 3 on a live run with twenty-seven identified pairs banked.
     * Everything before the failure is committed and the pass's watermarks make everything after
     * it idempotent, so the honest recovery is to re-enter at the failed stage rather than
     * re-run from the top and duplicate the reads.
     */
    /**
     * THE PROCESS PANEL, step (f). Cacheable and read-only: it reads rows and computes nothing
     * of its own, so it can be called on every render without costing the deal anything.
     *
     * Deliberately NOT folded into `RunView`. The panel is about the DEAL and the run view is
     * about a RUN - the map and the board carry no run key by design (the hundred-fourteenth's
     * own thesis), and Process state is the same shape. Folding them would make the panel look
     * like this run's output when it is the deal's standing state.
     */
    @AuraEnabled(cacheable=true)
    public static AAO_ProcessPanel.ProcessView processFor(Id opportunityId) {
        try {
            return AAO_ProcessPanel.read(opportunityId);
        } catch (Exception e) {
            // A panel that cannot read must not take the run page down with it. The run is the
            // thing the room is watching; the panel is beside it.
            throw new AuraHandledException(
                'The Process panel could not be read: ' + e.getMessage()
            );
        }
    }

    @AuraEnabled
    public static String resumeRun(Id opportunityId, String runKey) {
        if (opportunityId == null || String.isBlank(runKey)) {
            throw new AuraHandledException('No run to resume.');
        }
        AAO_Run_Receipt__c row = AAO_Receipt.forRun(opportunityId, runKey);
        if (row == null) {
            throw new AuraHandledException('That run journalled nothing, so there is no stage to resume from.');
        }
        // THE LAST FAILED LEG IS WHERE TO PICK UP - not the first stage with no leg.
        //
        // Stages that legitimately do nothing journal nothing: the deterministic leg never
        // writes one, and the model leg writes none when there is no remainder. Reading absence
        // as "unfinished" sent a resume back to the FRONT of a run that had failed at the END,
        // and it walked forward into a fully verified run and threw. A failed leg names its
        // stage; that is the only thing worth trusting here.
        String failedStage;
        for (AAO_Receipt.Leg leg : AAO_Receipt.legsOf(row)) {
            if (String.isNotBlank(leg.error)) {
                failedStage = leg.stage;
            }
        }
        if (String.isBlank(failedStage)) {
            return 'Nothing to resume: no stage on this run recorded a failure.';
        }
        String next = AAO_PassQueueable.stageForReceiptName(failedStage);
        if (String.isBlank(next)) {
            throw new AuraHandledException(
                'The run failed at "' + failedStage + '", which is not a stage this driver runs.'
            );
        }
        // `AAO_Receipt.forRun` does not select the Source lookup, and reading a field a SOQL
        // never asked for throws rather than returning null - so it is queried here rather than
        // assumed present on somebody else's row.
        List<AAO_Run_Receipt__c> withSource = [
            SELECT AAO_Source__c FROM AAO_Run_Receipt__c WHERE Id = :row.Id LIMIT 1
        ];
        Id sourceId = withSource.isEmpty() ? null : withSource[0].AAO_Source__c;
        if (sourceId == null) {
            throw new AuraHandledException('That run has no Source to resume against.');
        }
        AAO_PassQueueable.resumeAt(sourceId, runKey, next);
        return 'Resuming at "' + next + '". Work already done is not repeated.';
    }

    private static Long tok(Decimal d) {
        return d == null ? 0 : d.longValue();
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
            v.inputTokens = tok(row.AAO_Input_Tokens__c);
            v.outputTokens = tok(row.AAO_Output_Tokens__c);
            v.thinkingTokens = tok(row.AAO_Thinking_Tokens__c);
            v.cacheReadTokens = tok(row.AAO_Cache_Read_Tokens__c);
            v.cacheWriteTokens = tok(row.AAO_Cache_Write_Tokens__c);
            // **THE LAST LEG PER STAGE IS THE ONE THAT COUNTS**, and this is the whole reason a
            // resume looked like it did nothing.
            //
            // A resumed stage appends a SECOND leg: the failure, then the success. The first
            // version reported `stoppedBecause` from ANY leg carrying an error, so a stage that
            // failed and was then resumed successfully still painted the run as stopped -
            // forever. The surface froze at the failure while the pass ran on behind it, which
            // is the same class of lie as a progress bar on a timer, pointing the other way.
            //
            // **A stage that later succeeded is not a stage that is stopped.** The last word on
            // a stage is what it ended up doing, exactly as it is for a whole run.
            Map<String, AAO_Receipt.Leg> lastByStage = new Map<String, AAO_Receipt.Leg>();
            List<String> order = new List<String>();
            // EVERY failure counted, not only the surviving one, because the count is the
            // thing that changes when a resume fails again. `lastByStage` deliberately keeps
            // the last leg per stage; this keeps how many of them went wrong.
            Map<String, Integer> failuresByStage = new Map<String, Integer>();
            for (AAO_Receipt.Leg leg : AAO_Receipt.legsOf(row)) {
                if (!lastByStage.containsKey(leg.stage)) {
                    order.add(leg.stage);
                }
                lastByStage.put(leg.stage, leg);
                if (String.isNotBlank(leg.error)) {
                    Integer n = failuresByStage.containsKey(leg.stage)
                        ? failuresByStage.get(leg.stage)
                        : 0;
                    failuresByStage.put(leg.stage, n + 1);
                }
            }
            for (String stageName : order) {
                AAO_Receipt.Leg leg = lastByStage.get(stageName);
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
                    // THE ATTEMPT AND THE CLOCK RIDE WITH THE REASON. Two failures of one
                    // stage differ here even when the model's message is word for word the
                    // same, so a human looking at the surface can tell a stale stop from a
                    // fresh one without reading the receipt.
                    v.stoppedAttempts = failuresByStage.containsKey(leg.stage)
                        ? failuresByStage.get(leg.stage)
                        : 1;
                    v.stoppedAt = leg.at;
                    v.stoppedBecause =
                        leg.stage +
                        ' (attempt ' + v.stoppedAttempts +
                        (leg.at == null ? '' : ', ' + leg.at.format('HH:mm:ss')) + ')' +
                        ' — ' + leg.error;
                    v.finished = true;
                }
                if (leg.stage == AAO_Receipt.STAGE_CARDS && String.isBlank(leg.error)) {
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
        // SUPERSEDED ROWS COUNT NOWHERE (117th, amendment one). A tile that counted them would
        // turn the fragmentation into inflated numbers, which is quieter and worse than a crash.
        v.answers = [
            SELECT COUNT() FROM AAO_Answer__c
            WHERE AAO_Opportunity__c = :opportunityId AND AAO_Superseded_By__c = null
        ];
        v.cards = [
            SELECT COUNT() FROM ALTF__Insight_Card__c WHERE ALTF__Opportunity__c = :opportunityId
        ];
        return v;
    }
}
