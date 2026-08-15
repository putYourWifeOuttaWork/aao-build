/**
 * THE RESOLUTION STAGE. Matthew's ruling, 8 August evening (twenty-seventh stamp), replacing
 * call 2: IDENTIFICATION IS DELETED AS A MODEL JOB.
 *
 * The diagnosis it exists because of: the Project Farma run spent 59 callouts asking a model
 * who spoke each of 59 pairs, one pair per call, when who spoke a pair is a BYTE LOOKUP -
 * its offset locates its containing turn, the turn's speaker key resolves through the roster
 * call 0 already holds. A deterministic job done by inference, priced at one callout per
 * datum. This class does that job in Apex, in one transaction, with zero model calls on the
 * clean path.
 *
 * THREE LEGS, IN ORDER:
 *
 * 1. THE MERGE. Call 1 is two comprehensive reads whose independent misses are the recall
 *    hedge, so the same establishment arrives twice. The merge key is CONTRACT plus
 *    BYTE-RANGE INTERSECTION plus SAME VOICED MEANING - never string equality on quotes,
 *    Matthew verbatim: "call 1 can have a high confidence where it comes back with a similar
 *    meaning answer pair twice. not byte for byte though." One establishment, both receipts
 *    kept: the absorbed row takes a Merged disposition naming its canonical, the canonical's
 *    identified row is marked Corroborated. A pair only one read found STANDS - the union is
 *    the point, corroboration marks and never gates. Same bytes and question with different
 *    meanings both ride to call 3 blind. Coverage merges conservative: the canonical is the
 *    row already carrying the weaker coverage, so no located row is ever edited.
 *
 *    One addition to the ruled key, design's, recorded so it can be overruled: THE
 *    DESIGNATORS MUST AGREE (both absent, or the same words). Two reads finding the same
 *    bytes about DIFFERENT subjects are two establishments about two people, and merging
 *    them would pick a subject silently.
 *
 * 2. SPEAKER ATTACH, the default case, pure arithmetic: offset to containing turn to roster
 *    participant. Self-subject pairs are done right there.
 *
 * 3. THE DESIGNATOR LEG. Pairs whose words are about someone other than their speaker
 *    resolve deterministically: first against the roster (the person may simply be another
 *    participant), then down `AAO_ResolveDesignator`'s ladder including the title rung.
 *    Exactly one match attaches; AMBIGUOUS holds honestly; ZERO is the remainder the model
 *    leg exists for. RESOLUTION ATTACHES SUBJECTS, NEVER SPEAKERS: a resolved mention
 *    becomes the pair's subject via a mention-minted Participant row (`mention:` roster
 *    key, excluded from coverage - presence establishes coverage and a mention is not
 *    presence), and the speaker-requirement gates keep pricing the evidence.
 *
 * CREATION DOES NOT HAPPEN HERE, and that is deliberate twice over. First, the ruled order:
 * ladder first, link the existing Contact, create only on ladder-zero - and the creating leg
 * is `AAO_Identity` at projection, which runs AFTER call 3 has verified and the join has
 * committed, so an unverified pair can never mint a Contact. Second, the demo-narration
 * trap: a fictional person narrated by a seller can reach a designator, and the only thing
 * that keeps them off the org's Contact table is that nothing creates before verification
 * refuses their pairs. The create-leg record (`AAO_Created_Row__c`) ships with this class
 * and `AAO_Identity` writes it on every creation.
 *
 * THE MODEL LEG IS A SEPARATE METHOD (`requests`), one bounded call, fired ONLY when this
 * transaction leaves a remainder, per the ruling. It emits TYPED RESOLUTION REQUESTS -
 * never query text, never SOQL, never clause fragments - and Apex composes and executes
 * every query from the typed fields. Ruled with a recorded correction of Matthew's wording:
 * he said the model "infers which queries are required and what the clauses are"; design
 * reads the intent as the model saying WHO needs resolving and WHAT is known, with Apex
 * owning clause composition, because model-authored query text is an injection surface.
 */
public with sharing class AAO_Resolve {
    public class ResolveException extends Exception {
    }

    /** `resolution-`, not `resolve-`: AAO_ResolverCharter (call 0) already stamps
     *  `resolve-…`, and two stages sharing a version prefix is a provenance smear. */
    public static final String VERSION = 'resolution-1.0.0';

    /** The disposition an absorbed read's row takes. Counted by the ledger as disposed. */
    public static final String MERGED = 'Merged';

    public class Outcome {
        public Integer pairsRead = 0;
        public Integer merged = 0;
        public Integer speakerAttached = 0;
        public Integer designatorRoster = 0;
        public Integer designatorLinked = 0;
        public Integer designatorAmbiguous = 0;
        public Integer mentionParticipants = 0;
        /** Located refs the deterministic legs could not dispose. The model leg's input. */
        public List<String> remainder = new List<String>();
        /**
         * Mentions this leg refused to guess, for the Identification flag. COLLECTED, NEVER
         * RAISED HERE: raising is DML, and `requests()` throws if any DML has run in the
         * transaction, so a write on this path would arm the very guard that protects the
         * callout. The caller raises after the legs it intends to run.
         */
        public List<AAO_Identification.Held> held = new List<AAO_Identification.Held>();
        public List<String> notes = new List<String>();

        public override String toString() {
            List<String> o = new List<String>{
                'pairs read               ' + pairsRead + ' (unit: pairs)',
                'merged (absorbed)        ' + merged + ' (unit: pairs)',
                'speaker-attached         ' + speakerAttached + ' (unit: pairs)',
                'designator via roster    ' + designatorRoster + ' (unit: pairs)',
                'designator via ladder    ' + designatorLinked + ' (unit: pairs)',
                'designator ambiguous     ' + designatorAmbiguous + ' (unit: pairs)',
                'mention participants     ' + mentionParticipants + ' (unit: people)',
                'remainder for model leg  ' + remainder.size() + ' (unit: pairs)'
            };
            for (String n : notes) {
                o.add('  note: ' + n);
            }
            return String.join(o, '\n');
        }
    }

    // ================================================================== the deterministic run

    public static Outcome run(Id sourceId, String runKey) {
        AAO_Source__c src = [
            SELECT Id, AAO_Normalized_Text__c, AAO_Diarization__c, AAO_SHA256__c,
                AAO_Opportunity__c, AAO_Account__c, AAO_Evidence_Occurred__c,
                AAO_Artifact_SHA256__c
            FROM AAO_Source__c
            WHERE Id = :sourceId
        ];
        List<AAO_NormalForm.Turn> turns = AAO_NormalForm.turns(
            src.AAO_Normalized_Text__c, src.AAO_Diarization__c
        );

        Set<String> alreadyDisposed = new Set<String>();
        for (AAO_Pair__c p : [
            SELECT AAO_Pair_Ref__c FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.IDENTIFIED
        ]) {
            alreadyDisposed.add(p.AAO_Pair_Ref__c);
        }

        List<AAO_Pair__c> located = [
            SELECT Id, AAO_Pair_Ref__c, AAO_Meaning__c, AAO_Coverage__c,
                AAO_Start_Offset__c, AAO_End_Offset__c, AAO_Speaker_Key__c,
                AAO_About_Designator__c, AAO_About_Quote__c,
                AAO_Evidence_Contract__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.LOCATED
                AND AAO_Pair_Ref__c NOT IN :alreadyDisposed
            ORDER BY AAO_Start_Offset__c
        ];
        Outcome o = new Outcome();
        o.pairsRead = located.size();
        if (located.isEmpty()) {
            return o;
        }

        Map<String, AAO_Participant__c> roster = rosterByKey(sourceId);

        // ---- leg 1 · the merge --------------------------------------------------------
        Map<Id, AAO_Pair__c> canonicalByAbsorbed = mergePlan(located, o);
        Set<Id> absorbed = canonicalByAbsorbed.keySet();
        Set<Id> corroborated = new Set<Id>();
        for (AAO_Pair__c canonical : canonicalByAbsorbed.values()) {
            corroborated.add(canonical.Id);
        }

        List<AAO_Pair__c> rows = new List<AAO_Pair__c>();
        for (AAO_Pair__c p : located) {
            if (absorbed.contains(p.Id)) {
                AAO_Pair__c canonicalRow = canonicalByAbsorbed.get(p.Id);
                rows.add(disposition(p, src, runKey, MERGED, null, false,
                    'Merged into ' + canonicalRow.AAO_Pair_Ref__c + ': same contract, ' +
                    'overlapping bytes, same voiced meaning, same subject. The receipt ' +
                    'stands here; the establishment rides the canonical.'));
                o.merged++;
            }
        }

        // ---- legs 2 and 3 · attach ----------------------------------------------------
        List<AAO_Participant__c> mentionsToInsert = new List<AAO_Participant__c>();
        Map<String, AAO_Participant__c> mentionByKey = new Map<String, AAO_Participant__c>();
        // Ladder-linked rows wait for their mention participant's Id (the insert has not
        // happened yet); the key list is parallel to the row list.
        List<AAO_Pair__c> pending = new List<AAO_Pair__c>();
        List<String> pendingKeys = new List<String>();

        for (AAO_Pair__c p : located) {
            if (absorbed.contains(p.Id)) {
                continue;
            }
            Boolean corr = corroborated.contains(p.Id);

            if (String.isBlank(p.AAO_About_Designator__c)) {
                // Leg 2 · the byte lookup. The speaker key was computed at location; the
                // roster resolves it. This is the whole of what 59 callouts used to buy.
                AAO_Participant__c speaker = roster.get(p.AAO_Speaker_Key__c);
                if (speaker == null) {
                    throw new ResolveException(
                        'Pair ' + p.AAO_Pair_Ref__c + ' sits in turn of speaker key "' +
                        p.AAO_Speaker_Key__c + '", which is not on the roster. ' +
                        'Participation is written at ingest; this is an ingest defect, ' +
                        'never a quiet None.'
                    );
                }
                rows.add(disposition(p, src, runKey, 'Identified', speaker.Id, corr,
                    'Deterministic: the words sit in ' + p.AAO_Speaker_Key__c +
                    '\'s turn and are about their own speaker.' +
                    (corr ? ' Corroborated by both reads.' : '')));
                o.speakerAttached++;
                continue;
            }

            // Leg 3 · the designator. Roster first: the person the words are about may
            // simply be another participant on the call.
            AAO_Participant__c onRoster = rosterMatch(p.AAO_About_Designator__c, roster);
            if (onRoster != null) {
                rows.add(disposition(p, src, runKey, 'Identified', onRoster.Id, corr,
                    'Deterministic: designator "' + p.AAO_About_Designator__c +
                    '" matches roster participant ' + onRoster.AAO_Roster_Key__c +
                    '. Introduced: "' + p.AAO_About_Quote__c.abbreviate(120) + '"' +
                    (corr ? ' Corroborated by both reads.' : '')));
                o.designatorRoster++;
                continue;
            }

            AAO_ResolveDesignator.Kind kind =
                AAO_ResolveDesignator.isKnownTitle(p.AAO_About_Designator__c)
                    ? AAO_ResolveDesignator.Kind.TITLE
                    : AAO_ResolveDesignator.Kind.NAME;
            AAO_ResolveDesignator.Outcome ladder = AAO_ResolveDesignator.resolve(
                p.AAO_About_Designator__c, kind, src.AAO_Account__c, src.AAO_Opportunity__c
            );

            if (ladder.linked()) {
                mentionFor(
                    p.AAO_About_Designator__c, ladder.contactId, src,
                    mentionByKey, mentionsToInsert
                );
                pending.add(disposition(p, src, runKey, 'Identified', null, corr,
                    'Deterministic ladder, rung "' + ladder.rung + '": designator "' +
                    p.AAO_About_Designator__c + '" links one Contact. ' +
                    blank(ladder.because).abbreviate(140) +
                    (corr ? ' Corroborated by both reads.' : '')));
                pendingKeys.add(mentionKey(p.AAO_About_Designator__c));
                o.designatorLinked++;
                continue;
            }
            if (ladder.verdict == 'AMBIGUOUS') {
                rows.add(disposition(p, src, runKey, 'Ambiguous', null, false,
                    'Held: designator "' + p.AAO_About_Designator__c + '" matches more ' +
                    'than one candidate and context cannot separate them here. ' +
                    'The Identification flag\'s case; never a pick. ' +
                    blank(ladder.because).abbreviate(140)));
                o.held.add(heldFor(
                    src, p.AAO_About_Designator__c,
                    AAO_Identification.CAUSE_AMBIGUOUS,
                    'Matches more than one candidate on this account and context cannot ' +
                    'separate them. ' + blank(ladder.because).abbreviate(400),
                    null
                ));
                o.designatorAmbiguous++;
                continue;
            }
            // ZERO · the remainder. The model leg is the only thing allowed to look next,
            // and it is a separate bounded call, so this pair stays undisposed in this
            // transaction and the caller decides whether to fire the leg. The located
            // row's About fields hold the evidence either way - nothing is lost.
            o.remainder.add(p.AAO_Pair_Ref__c);
        }

        if (!mentionsToInsert.isEmpty()) {
            insert mentionsToInsert;
            o.mentionParticipants = mentionsToInsert.size();
        }
        for (Integer i = 0; i < pending.size(); i++) {
            pending[i].AAO_Person__c = mentionByKey.get(pendingKeys[i]).Id;
            rows.add(pending[i]);
        }

        if (!rows.isEmpty()) {
            insert rows;
        }
        return o;
    }

    // ================================================================== the model leg

    /**
     * One held mention, shaped for the flag. Reads the deal and the clock off the Source so
     * the flag ages from when the words were spoken rather than from when this ran.
     */
    private static AAO_Identification.Held heldFor(
        AAO_Source__c src, String designator, String cause, String basis, Id shadowPersonId
    ) {
        AAO_Identification.Held h = new AAO_Identification.Held();
        h.opportunityId = src.AAO_Opportunity__c;
        h.accountId = src.AAO_Account__c;
        h.designator = designator;
        h.cause = cause;
        h.basis = basis;
        h.shadowPersonId = shadowPersonId;
        h.occurred = src.AAO_Evidence_Occurred__c;
        return h;
    }

    public class RequestRun {
        public AAO_Extract.StageResult call;
        public List<AAO_ResolveRequestCharter.Request> requests;
        public Integer attachedToCandidate = 0;
        public Integer mintedForCreation = 0;
        public Integer heldNone = 0;
        /** Same contract as `Outcome.held`: collected here, raised by the caller. */
        public List<AAO_Identification.Held> held = new List<AAO_Identification.Held>();

        public override String toString() {
            return String.join(
                new List<String>{
                    'requests returned        ' +
                        (requests == null ? 0 : requests.size()) + ' (unit: designators)',
                    'attached to a candidate  ' + attachedToCandidate + ' (unit: pairs)',
                    'minted toward creation   ' + mintedForCreation + ' (unit: pairs)',
                    'held None                ' + heldNone + ' (unit: pairs)'
                },
                '\n'
            );
        }
    }

    /**
     * ONE BOUNDED CALL for the remainder the deterministic legs left, then Apex acts on the
     * typed fields. Fire only when `run().remainder` is non-empty; the clean-transcript
     * arithmetic is zero calls here.
     *
     * WHAT APEX DOES WITH EACH TYPED REQUEST, and none of it is the model's to do:
     * - candidate on the closed list: the pair attaches to that participant.
     * - NONE, kind named-off-artifact or on-artifact-no-contact: a mention Participant is
     *   minted with NO Contact. Creation stays at projection (`AAO_Identity`, ladder-zero,
     *   behind the toggle and the create-leg record) and therefore behind call 3's verify.
     * - NONE, kind title-only: held as None. A TITLE CAN LINK BUT NEVER CREATE - a Contact
     *   requires a LastName and a title has none - so ladder-zero on a title dead-ends.
     * - NONE, kind ambiguous-antecedent: held as None with the reason. This is also where
     *   the demo-narration prompt routes fictional people, so nothing downstream of this
     *   line can mint a character from a seller's story.
     * - a voiced seller side: held as None; a seller is not a buying-committee member by
     *   construction and the join's gate would refuse the claim anyway.
     */
    public static RequestRun requests(Id sourceId, String runKey) {
        // THE TRANSACTION BOUNDARY, ENFORCED AT THE CALL SITE rather than left to a comment or
        // to a driver's habits (wiring proposal v3, section 3, adopted as a wiring constraint).
        //
        // `run()` writes rows and this leg makes a callout, so the two are separate transactions
        // BY DESIGN - this method re-queries the org rather than taking `run()`'s in-memory
        // output precisely so it can be. A caller that runs both in one transaction gets
        // "uncommitted work pending" from the platform, at the callout, after the DML has
        // already landed.
        //
        // THE PRECEDENT IS CITED BECAUSE IT ALREADY COST US ONCE: at the eightieth stamp both
        // verify buckets ran in one transaction and the callout followed the DML, and the run
        // had to be rebuilt from the untouched harvest. A rule that only exists in prose gets
        // rediscovered by whoever writes the next driver.
        if (Limits.getDmlStatements() > 0) {
            throw new ResolveException(
                'The model leg must start its own transaction. ' + Limits.getDmlStatements() +
                ' DML statement(s) have already run here, so the callout below would fail with ' +
                'uncommitted work pending. Call run() and requests() in separate transactions: ' +
                'requests() re-reads the org by design, so nothing is lost by splitting them.'
            );
        }
        AAO_Source__c src = [
            SELECT Id, AAO_Normalized_Text__c, AAO_Diarization__c, AAO_SHA256__c,
                AAO_Opportunity__c, AAO_Account__c, AAO_Evidence_Occurred__c,
                AAO_Artifact_SHA256__c
            FROM AAO_Source__c
            WHERE Id = :sourceId
        ];
        Set<String> alreadyDisposed = new Set<String>();
        for (AAO_Pair__c p : [
            SELECT AAO_Pair_Ref__c FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.IDENTIFIED
        ]) {
            alreadyDisposed.add(p.AAO_Pair_Ref__c);
        }
        List<AAO_Pair__c> remainder = [
            SELECT Id, AAO_Pair_Ref__c, AAO_About_Designator__c, AAO_About_Quote__c,
                AAO_Evidence_Contract__c, AAO_Speaker_Key__c,
                AAO_Start_Offset__c, AAO_End_Offset__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey AND AAO_Stage__c = :AAO_PairKey.LOCATED
                AND AAO_Pair_Ref__c NOT IN :alreadyDisposed
            ORDER BY AAO_Start_Offset__c
        ];
        if (remainder.isEmpty()) {
            throw new ResolveException(
                'No undisposed pairs on run ' + runKey + '. The model leg fires only when ' +
                'the deterministic legs leave a remainder.'
            );
        }

        Map<String, AAO_Participant__c> roster = rosterByKey(sourceId);
        List<String> candidateHandles = new List<String>();
        List<String> candidateLines = new List<String>();
        for (String k : roster.keySet()) {
            if (k.startsWith('mention:')) {
                continue;
            }
            AAO_Participant__c p = roster.get(k);
            candidateHandles.add(k);
            candidateLines.add('  ' + k + ': ' + p.AAO_Display_Name__c + ' (' +
                (p.AAO_Internal__c == true ? 'our side' : 'buyer side') + ')');
        }

        // One request per distinct designator, not per pair: five pairs about "Rich" are
        // one question about who Rich is.
        Map<String, String> designatorByHandle = new Map<String, String>();
        Map<String, List<AAO_Pair__c>> pairsByHandle = new Map<String, List<AAO_Pair__c>>();
        Map<String, String> handleByKey = new Map<String, String>();
        Integer di = 0;
        for (AAO_Pair__c p : remainder) {
            String key = mentionKey(p.AAO_About_Designator__c);
            String h = handleByKey.get(key);
            if (h == null) {
                di++;
                h = 'd' + di;
                handleByKey.put(key, h);
                designatorByHandle.put(h, p.AAO_About_Designator__c);
                pairsByHandle.put(h, new List<AAO_Pair__c>());
            }
            pairsByHandle.get(h).add(p);
        }

        AAO_Extract.StageSpec spec = AAO_Extract.inventorySpec();
        spec.stage = 'call2_requests';
        spec.charter = 'AAO_ResolveRequestCharter';
        spec.charterVersion = AAO_ResolveRequestCharter.VERSION;

        RequestRun r = new RequestRun();
        r.requests = new List<AAO_ResolveRequestCharter.Request>();

        // THE GRAMMAR BUDGET REACHES THE MODEL LEG (thirty-fourth stamp). Its typed-request
        // schema is one required property per designator handle, so it grows with unresolved
        // people - harmless at a transcript's two, but a note or email hands it five to ten,
        // and the same compiled-grammar ceiling verify hit lives here. The handles are
        // chunked at the measured cap and each chunk is its own bounded callout, so the
        // schema per call never crosses the ceiling. Derived NOW, before notes rediscover it
        // with customer data in flight. On a transcript this is one chunk; the loop is the
        // shape, not a cost.
        List<String> allHandles = new List<String>(designatorByHandle.keySet());
        Integer cap = AAO_Pass.MAX_UNITS_PER_KEYED_CALL;
        for (Integer start = 0; start < allHandles.size(); start += cap) {
            List<String> chunk = new List<String>();
            Map<String, String> chunkDesignators = new Map<String, String>();
            for (Integer i = start; i < Math.min(start + cap, allHandles.size()); i++) {
                chunk.add(allHandles[i]);
                chunkDesignators.put(allHandles[i], designatorByHandle.get(allHandles[i]));
            }

            List<String> block = new List<String>{ '# The people on the call', '' };
            block.addAll(candidateLines);
            block.add('');
            block.add('# The designators needing resolution');
            block.add('');
            for (String h : chunk) {
                AAO_Pair__c specimen = pairsByHandle.get(h)[0];
                block.add('## ' + h);
                block.add('As written: "' + designatorByHandle.get(h) + '"');
                block.add('Introduced: "' + specimen.AAO_About_Quote__c + '"');
                block.add('Spoken in the turn of: ' + specimen.AAO_Speaker_Key__c);
                block.add('');
            }

            AAO_Extract.StageResult sr = AAO_Extract.callStage(
                spec,
                AAO_ResolveRequestCharter.systemPrompt(),
                new List<String>{ String.join(block, '\n') },
                AAO_ResolveRequestCharter.schema(chunk, candidateHandles)
            );
            if (r.call == null) {
                r.call = sr;
            } else {
                r.call.usage.inputTokens += sr.usage.inputTokens;
                r.call.usage.outputTokens += sr.usage.outputTokens;
                r.call.elapsedMs += sr.elapsedMs;
            }
            r.requests.addAll(
                AAO_ResolveRequestCharter.parse(sr.rawText, chunkDesignators)
            );
        }

        List<AAO_Participant__c> mentionsToInsert = new List<AAO_Participant__c>();
        Map<String, AAO_Participant__c> mentionByKey = new Map<String, AAO_Participant__c>();
        List<AAO_Pair__c> rows = new List<AAO_Pair__c>();
        List<AAO_Pair__c> pending = new List<AAO_Pair__c>();
        List<String> pendingKeys = new List<String>();

        for (AAO_ResolveRequestCharter.Request req : r.requests) {
            List<AAO_Pair__c> pairs = pairsByHandle.get(req.handle);
            for (AAO_Pair__c p : pairs) {
                if (req.candidate != AAO_ResolveRequestCharter.NONE) {
                    AAO_Participant__c cand = roster.get(req.candidate);
                    if (cand == null) {
                        throw new ResolveException(
                            'The model leg named candidate "' + req.candidate + '", not on ' +
                            'the closed list. Our bug, per the parse law.'
                        );
                    }
                    rows.add(disposition(p, src, runKey, 'Identified', cand.Id, false,
                        'Model leg: designator "' + req.designator + '" is candidate ' +
                        req.candidate + '. ' + blank(req.basis).abbreviate(150)));
                    r.attachedToCandidate++;
                    continue;
                }
                if (req.side == 'seller') {
                    rows.add(disposition(p, src, runKey, 'None', null, false,
                        'Held: the words place "' + req.designator + '" on the selling ' +
                        'side, and a seller is not a buying-committee member by ' +
                        'construction. ' + blank(req.basis).abbreviate(140)));
                    r.heldNone++;
                    continue;
                }
                if (req.kind == AAO_ResolveRequestCharter.NAMED_OFF_ARTIFACT ||
                    req.kind == AAO_ResolveRequestCharter.ON_ARTIFACT_NO_CONTACT) {
                    // THE FABRICATION RETIRES HERE. This branch used to mint a Participant with
                    // no Contact for a person who was never on the call, so a read-shaped stage
                    // wrote into the roster - the deterministic substrate coverage, the internal
                    // check and participant placement all read - and three classes grew a
                    // `mention:` prefix filter to compensate. A prefix convention is not a
                    // constraint: any query that forgets it counts a mention as presence.
                    //
                    // The person is now HELD on the proof that somebody said their name, with
                    // every anchor kept. Rung 3's flag is the surface a human works, and the
                    // pair binds if and when the ladder resolves them.
                    //
                    // KEPT DELIBERATELY, AND NAMED AS DEBT: where rung 1 UNIQUELY LINKS a real
                    // Contact, `run()`'s leg 3 still mints. That is not ratified architecture -
                    // a Participant row for someone who was not on the call still asserts
                    // something false - and the `mention:` filters survive for exactly that
                    // subset until promotion is wired.
                    AAO_Identity.Utterance u = new AAO_Identity.Utterance();
                    u.designator = req.designator;
                    u.sourceId = src.Id;
                    u.startOffset = p.AAO_Start_Offset__c == null
                        ? null : Integer.valueOf(p.AAO_Start_Offset__c);
                    u.endOffset = p.AAO_End_Offset__c == null
                        ? null : Integer.valueOf(p.AAO_End_Offset__c);
                    u.quote = p.AAO_About_Quote__c;
                    AAO_Identity.Resolution held = AAO_Identity.holdMention(
                        u, src.AAO_Account__c, 'Unresolvable',
                        'Held from the model leg: "' + req.designator + '" is a real person of ' +
                        'this deal (' + req.kind + ') with no match in the org. No participation ' +
                        'is fabricated; the utterance is the proof. ' +
                        blank(req.basis).abbreviate(100)
                    );
                    rows.add(disposition(p, src, runKey, 'Held', null, false,
                        'Held on its utterance, shadow ' + held.shadowPersonId + '. ' +
                        blank(req.basis).abbreviate(120)));
                    r.held.add(heldFor(
                        src, req.designator,
                        AAO_Identification.CAUSE_UNRESOLVED,
                        'A real person of this deal (' + req.kind + ') with no match in the ' +
                        'org. Held on the utterance; no participation is fabricated. ' +
                        blank(req.basis).abbreviate(400),
                        held.shadowPersonId
                    ));
                    r.mintedForCreation++;
                    continue;
                }
                if (req.kind == AAO_ResolveRequestCharter.TITLE_ONLY) {
                    rows.add(disposition(p, src, runKey, 'None', null, false,
                        'Held: "' + req.designator + '" is a title matching nobody, and ' +
                        'a title can link but never create - a Contact requires a ' +
                        'LastName and a title has none. The evidence stands on the ' +
                        'located row. ' + blank(req.basis).abbreviate(120)));
                    r.heldNone++;
                    continue;
                }
                rows.add(disposition(p, src, runKey, 'None', null, false,
                    'Held: the words do not settle who "' + req.designator + '" is (' +
                    req.kind + '). ' + blank(req.basis).abbreviate(150)));
                r.heldNone++;
            }
        }

        if (!mentionsToInsert.isEmpty()) {
            insert mentionsToInsert;
        }
        for (Integer i = 0; i < pending.size(); i++) {
            pending[i].AAO_Person__c = mentionByKey.get(pendingKeys[i]).Id;
            rows.add(pending[i]);
        }
        insert rows;
        return r;
    }

    private static String blank(String s) {
        return s == null ? '' : s;
    }

    // ============================================================================ the merge

    /**
     * The merge plan: absorbed located row to its canonical. Greedy within a contract, r1
     * against r2, first intersecting unconsumed partner wins - deterministic because both
     * sides are offset-ordered.
     *
     * THE CANONICAL IS THE ROW ALREADY CARRYING THE CONSERVATIVE COVERAGE, which is what
     * lets "partial unless both reads say full" hold without editing a located row: where
     * the reads disagree, the Partial row IS the canonical; where they agree, either is.
     */
    private static Map<Id, AAO_Pair__c> mergePlan(List<AAO_Pair__c> located, Outcome o) {
        Map<Id, List<AAO_Pair__c>> byContract = new Map<Id, List<AAO_Pair__c>>();
        for (AAO_Pair__c p : located) {
            if (!byContract.containsKey(p.AAO_Evidence_Contract__c)) {
                byContract.put(p.AAO_Evidence_Contract__c, new List<AAO_Pair__c>());
            }
            byContract.get(p.AAO_Evidence_Contract__c).add(p);
        }

        Map<Id, AAO_Pair__c> canonicalByAbsorbed = new Map<Id, AAO_Pair__c>();
        for (List<AAO_Pair__c> contractGroup : byContract.values()) {
            List<AAO_Pair__c> r1 = new List<AAO_Pair__c>();
            List<AAO_Pair__c> r2 = new List<AAO_Pair__c>();
            for (AAO_Pair__c p : contractGroup) {
                if (p.AAO_Pair_Ref__c.startsWith('r1')) {
                    r1.add(p);
                } else if (p.AAO_Pair_Ref__c.startsWith('r2')) {
                    r2.add(p);
                }
                // Refs with neither prefix (a sweep-era run) simply never merge.
            }
            Set<Id> consumed = new Set<Id>();
            for (AAO_Pair__c a : r1) {
                for (AAO_Pair__c b : r2) {
                    if (consumed.contains(b.Id)) {
                        continue;
                    }
                    if (!intersects(a, b) || a.AAO_Meaning__c != b.AAO_Meaning__c) {
                        continue;
                    }
                    if (!designatorsAgree(a, b)) {
                        continue;
                    }
                    AAO_Pair__c canonical = conservativeOf(a, b);
                    AAO_Pair__c other = canonical.Id == a.Id ? b : a;
                    canonicalByAbsorbed.put(other.Id, canonical);
                    consumed.add(b.Id);
                    break;
                }
            }
        }
        return canonicalByAbsorbed;
    }

    private static Boolean intersects(AAO_Pair__c a, AAO_Pair__c b) {
        if (a.AAO_Start_Offset__c == null || b.AAO_Start_Offset__c == null) {
            return false;
        }
        return a.AAO_Start_Offset__c < b.AAO_End_Offset__c &&
            b.AAO_Start_Offset__c < a.AAO_End_Offset__c;
    }

    private static Boolean designatorsAgree(AAO_Pair__c a, AAO_Pair__c b) {
        String da = a.AAO_About_Designator__c;
        String db = b.AAO_About_Designator__c;
        if (String.isBlank(da) && String.isBlank(db)) {
            return true;
        }
        return da != null && db != null && da.equalsIgnoreCase(db);
    }

    private static AAO_Pair__c conservativeOf(AAO_Pair__c a, AAO_Pair__c b) {
        // Partial beats Full for canonical-ship, because the canonical's stored coverage is
        // what the join reads and the merged coverage is Full only where both said Full.
        if (a.AAO_Coverage__c == 'Partial' && b.AAO_Coverage__c == 'Full') {
            return a;
        }
        if (b.AAO_Coverage__c == 'Partial' && a.AAO_Coverage__c == 'Full') {
            return b;
        }
        return a;
    }

    // ==================================================================== the roster leg

    private static Map<String, AAO_Participant__c> rosterByKey(Id sourceId) {
        Map<String, AAO_Participant__c> out = new Map<String, AAO_Participant__c>();
        for (AAO_Participant__c p : [
            SELECT Id, AAO_Roster_Key__c, AAO_Display_Name__c, AAO_Internal__c,
                AAO_Email__c, AAO_Contact__c
            FROM AAO_Participant__c
            WHERE AAO_Source__c = :sourceId
        ]) {
            out.put(p.AAO_Roster_Key__c, p);
        }
        if (out.isEmpty()) {
            throw new ResolveException(
                'Source ' + sourceId + ' has no participants. Participation is written at ' +
                'ingest; a Source with none is an ingest defect.'
            );
        }
        return out;
    }

    /**
     * A designator against the roster's display names: exact display match, or a single
     * token matching exactly one participant's first or last display token. More than one
     * match is nobody - never pick - and the ladder gets its turn.
     */
    @TestVisible
    private static AAO_Participant__c rosterMatch(
        String designator, Map<String, AAO_Participant__c> roster
    ) {
        String want = designator.trim();
        List<AAO_Participant__c> hits = new List<AAO_Participant__c>();
        for (AAO_Participant__c p : roster.values()) {
            if (String.isBlank(p.AAO_Display_Name__c) ||
                p.AAO_Roster_Key__c != null && p.AAO_Roster_Key__c.startsWith('mention:')) {
                continue;
            }
            String display = p.AAO_Display_Name__c.trim();
            if (display.equalsIgnoreCase(want)) {
                hits.add(p);
                continue;
            }
            if (!want.contains(' ')) {
                for (String token : display.split('\\s+')) {
                    if (token.equalsIgnoreCase(want)) {
                        hits.add(p);
                        break;
                    }
                }
            }
        }
        return hits.size() == 1 ? hits[0] : null;
    }

    // ================================================================= the mention subject

    @TestVisible
    private static String mentionKey(String designator) {
        return 'mention:' + designator.trim().toLowerCase().replaceAll('\\s+', '-');
    }

    /**
     * The mention-minted Participant: the subject carrier for a person the call talked
     * about. Display name is the designator VERBATIM (the ASR-name law: what was said is
     * the source form, and the linked Contact carries the resolved identity); the email
     * rides from the Contact so the join's internal-domain gate can see a seller. Excluded
     * from coverage by its roster-key prefix.
     */
    private static AAO_Participant__c mentionFor(
        String designator,
        Id contactId,
        AAO_Source__c src,
        Map<String, AAO_Participant__c> mentionByKey,
        List<AAO_Participant__c> toInsert
    ) {
        String key = mentionKey(designator);
        if (mentionByKey.containsKey(key)) {
            return mentionByKey.get(key);
        }
        List<AAO_Participant__c> existing = [
            SELECT Id, AAO_Roster_Key__c, AAO_Display_Name__c, AAO_Contact__c
            FROM AAO_Participant__c
            WHERE AAO_Participant_Key__c = :(String.valueOf(src.Id) + '|' + key)
            LIMIT 1
        ];
        if (!existing.isEmpty()) {
            mentionByKey.put(key, existing[0]);
            return existing[0];
        }
        String email = null;
        if (contactId != null) {
            List<Contact> c = [SELECT Email FROM Contact WHERE Id = :contactId LIMIT 1];
            email = c.isEmpty() ? null : c[0].Email;
        }
        AAO_Participant__c row = new AAO_Participant__c(
            AAO_Source__c = src.Id,
            AAO_Contact__c = contactId,
            AAO_Opportunity__c = src.AAO_Opportunity__c,
            AAO_Account__c = src.AAO_Account__c,
            AAO_Roster_Key__c = key,
            AAO_Display_Name__c = designator.trim(),
            AAO_Email__c = email,
            AAO_Internal__c = false,
            AAO_Evidence_Occurred__c = src.AAO_Evidence_Occurred__c,
            AAO_Artifact_SHA256__c = src.AAO_Artifact_SHA256__c,
            AAO_Substantive__c = false,
            AAO_Participant_Key__c = String.valueOf(src.Id) + '|' + key
        );
        mentionByKey.put(key, row);
        toInsert.add(row);
        return row;
    }

    private static AAO_Pair__c disposition(
        AAO_Pair__c located,
        AAO_Source__c src,
        String runKey,
        String disp,
        Id personId,
        Boolean corroborated,
        String basis
    ) {
        return new AAO_Pair__c(
            AAO_Stage__c = AAO_PairKey.IDENTIFIED,
            AAO_Run_Key__c = runKey,
            AAO_Pair_Ref__c = located.AAO_Pair_Ref__c,
            AAO_Charter__c = 'People',
            AAO_Charter_Version__c = VERSION,
            AAO_Located_Pair__c = located.Id,
            AAO_Source__c = src.Id,
            AAO_Artifact_SHA256__c = src.AAO_SHA256__c,
            AAO_Evidence_Contract__c = located.AAO_Evidence_Contract__c,
            AAO_Disposition__c = disp,
            AAO_Person__c = personId,
            AAO_Corroborated__c = corroborated,
            AAO_Identification_Basis__c = basis == null ? null : basis.abbreviate(255)
        );
    }
}