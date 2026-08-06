/**
 * Commit forks: a claim is written and an answer is upserted.
 *
 * The order of operations matters and is not arbitrary.
 *   1. verify the spans, because an unverified quote is not a citation
 *   2. adjudicate coverage, because coverage routes the outcome
 *   3. test the speaker requirement, because who said it gates whether coverage can
 *      become an establishment
 *   4. read the answer before writing it, because human precedence is enforced against
 *      what is already there
 *   5. upsert, catching DUPLICATE_VALUE as a merge rather than an error
 *   6. write the claim, which is the receipt and is never edited afterwards
 */
public class AAO_Commit {
    public class CommitException extends Exception {
    }

    public class Result {
        public AAO_Answer__c answer;
        /** Null where nothing was established, which is the honest outcome for silence. */
        public AAO_Claim__c claim;
        public String candidateStage;
        public String candidateOutcome;
        public String note;
        public Boolean merged = false;
    }

    /**
     * @param candidateId     an adjudicated candidate
     * @param internalDomains email domains on the selling side. Owed: this belongs in org
     *                        configuration, not an argument. See BUILD_JOURNAL.
     */
    public static Result commitCandidate(Id candidateId, Set<String> internalDomains) {
        AAO_Candidate__c cand = [
            SELECT
                Id,
                AAO_Evidence_Contract__c,
                AAO_Source__c,
                AAO_Basis__c,
                AAO_Opportunity__c,
                AAO_Account__c,
                AAO_Subject_Type__c,
                AAO_Subject_Contact__c,
                AAO_Participant__c,
                AAO_Shadow_Person__c,
                AAO_Criterion__c,
                AAO_Proposed_Verdict__c,
                AAO_Spans__c,
                AAO_Element_Coverage__c,
                AAO_Interpretation__c,
                AAO_Charter__c,
                AAO_Charter_Version__c,
                AAO_Publication_State__c,
                AAO_Evidence_Contract__r.AAO_Speaker_Requirement__c,
                AAO_Evidence_Contract__r.AAO_Elements__c,
                AAO_Evidence_Contract__r.AAO_Rubric_Version__c,
                AAO_Participant__r.AAO_Roster_Key__c,
                AAO_Participant__r.AAO_Contact__c,
                AAO_Source__r.AAO_Evidence_Occurred__c,
                AAO_Source__r.AAO_Speaker_Roster__c,
                AAO_Source__r.AAO_Diarization__c
            FROM AAO_Candidate__c
            WHERE Id = :candidateId
        ];

        Result r = new Result();

        // Held candidates stay on Candidate and never queue on the mirror.
        if (cand.AAO_Publication_State__c == 'Held') {
            r.candidateStage = 'Adjudicated';
            r.candidateOutcome = 'Pending';
            r.note = 'Held for ratification; nothing written to the mirror.';
            stampCandidate(cand, r, null);
            return r;
        }
        if (cand.AAO_Publication_State__c == 'Declined') {
            r.candidateStage = 'Reconciled';
            r.candidateOutcome = 'Rejected';
            r.note = 'Declined. A decline establishes nothing and writes no claim.';
            stampCandidate(cand, r, null);
            return r;
        }

        // 1 -------------------------------------------------------- verify the spans
        List<AAO_Model.Span> spans = AAO_Model.parseSpans(cand.AAO_Spans__c).spans;
        Map<Id, AAO_Source__c> sourceById = new Map<Id, AAO_Source__c>(
            [
                SELECT Id, AAO_Normalized_Text__c, AAO_Diarization__c
                FROM AAO_Source__c
                WHERE Id IN :AAO_SpanVerifier.sourceIds(spans)
            ]
        );
        AAO_SpanVerifier.Result sv = AAO_SpanVerifier.verify(spans, sourceById);
        if (!sv.isOk()) {
            r.candidateStage = 'Span_Checked';
            r.candidateOutcome = 'Span_Failed';
            r.note = sv.describe();
            stampCandidate(cand, r, null);
            return r;
        }

        // 2 ---------------------------------------------------- adjudicate coverage
        String answerKey = AAO_AnswerKey.compose(cand);
        AAO_Answer__c existing = readExisting(answerKey);

        AAO_Model.Coverage accumulated = AAO_Accumulate.mergeCoverage(
            existing == null ? null : existing.AAO_Element_Coverage__c,
            cand.AAO_Element_Coverage__c
        );
        // The contract says what full coverage is. Asking the proposal would be asking
        // the thing being judged.
        List<String> contractElements = AAO_ExtractCharter.elementIds(
            cand.AAO_Evidence_Contract__r
        );
        String verdict = AAO_Accumulate.verdictFor(
            accumulated,
            cand.AAO_Proposed_Verdict__c,
            contractElements
        );
        if (verdict == null) {
            // Nothing was said about this proposition. Nothing is written, and the
            // candidate row is the whole record of having looked.
            r.candidateStage = 'Adjudicated';
            r.candidateOutcome = 'Abstained';
            r.note = 'No element covered; nothing established.';
            stampCandidate(cand, r, null);
            return r;
        }

        // 3 ------------------------------------------- who must be the source of it
        Map<String, AAO_Model.Speaker> roster = cand.AAO_Source__c == null
            ? new Map<String, AAO_Model.Speaker>()
            : AAO_Model.parseRoster(cand.AAO_Source__r.AAO_Speaker_Roster__c);
        // The org's own relationship map, where it has one. Preferred over the roster,
        // because standing is not something a transcript gets to declare.
        Map<Id, String> roleByContact = new Map<Id, String>();
        for (ALTF__Contact_Map_Details__c row : [
            SELECT ALTF__Contact__c, ALTF__Buyer_Role__c
            FROM ALTF__Contact_Map_Details__c
            WHERE ALTF__Opportunity__c = :cand.AAO_Opportunity__c
        ]) {
            if (row.ALTF__Contact__c != null) {
                roleByContact.put(row.ALTF__Contact__c, row.ALTF__Buyer_Role__c);
            }
        }

        String requirement = cand.AAO_Evidence_Contract__r.AAO_Speaker_Requirement__c;
        Boolean speakerOk = false;
        List<String> speakerReasons = new List<String>();

        // THE SPEAKER GATE IS ABOUT UTTERANCES, AND A RECORD HAS NO UTTERER.
        //
        // RATIFIED 48 as the law for basis State. The rule ranks whoever SAID
        // the words; state evidence has no words and no speaker, so there is nothing to
        // rank. Running the loop anyway would leave speakerOk false on every state claim
        // and downgrade all of them to UNVERIFIED forever, which is not the gate deciding,
        // it is the gate being asked a question that does not apply to the row.
        //
        // NOT APPLICABLE IS RECORDED, NOT SKIPPED, and that distinction is the ratified
        // part. The reason goes on the claim in the
        // same field the transcript path uses, so nobody reading a state claim later can
        // mistake it for one that cleared a speaker check it never faced.
        if (!AAO_EvidenceFamily.needsSource(cand.AAO_Basis__c)) {
            speakerOk = true;
            speakerReasons.add(
                'Speaker requirement ' +
                requirement +
                ' does not apply: basis is State. Nobody said this; the record says it, ' +
                'and the record is named in the claim\'s cited rows.'
            );
        }

        // THE SUBJECT WAS NEVER SUPPLIED, and Subject_Person therefore refused every time it
        // ran. `AAO_PS_1` is the one §P8 contract that carries the requirement - sentiment
        // asks how THIS PERSON stands, so the person has to have said it - and with no
        // subject to check against, the gate's own honest refusal downgraded every sentiment
        // establishment to UNVERIFIED. The counter would then have read a ledger of claims
        // that established nothing and stood at zero for everyone, forever. Found by running
        // the join rather than by reading the gate.
        Id subjectContact = cand.AAO_Subject_Contact__c != null
            ? cand.AAO_Subject_Contact__c
            : (cand.AAO_Participant__r == null ? null : cand.AAO_Participant__r.AAO_Contact__c);
        String subjectRosterKey = cand.AAO_Participant__r == null
            ? null
            : cand.AAO_Participant__r.AAO_Roster_Key__c;

        for (Integer i = 0; i < spans.size(); i++) {
            String key = sv.speakerByIndex.get(i);
            AAO_SpeakerRule.Verdict v = AAO_SpeakerRule.evaluate(
                requirement,
                key == null ? null : roster.get(key),
                internalDomains,
                roleByContact,
                subjectContact,
                subjectRosterKey
            );
            speakerReasons.add(v.reason);
            if (v.satisfied) {
                speakerOk = true;
                break;
            }
        }

        // Key four of four, resolved from participants rather than assumed from the deal
        // owner. A grain not recorded cannot be declared later without reprocessing the
        // corpus, which means re-paying every model call, so it is resolved on the way
        // past rather than left for later.
        Id internalPerson = resolveInternalPerson(roster, internalDomains, sv.speakerByIndex);

        String claimOutcome = 'Established';
        if (!speakerOk) {
            // The regrade from Gate 1 run two. The words are real and the receipts are
            // real; what fails is that the wrong person said them. So it writes
            // UNVERIFIED carrying the evidence, never TRUE and never nothing.
            verdict = 'UNVERIFIED';
            claimOutcome = 'Downgraded';
            r.candidateOutcome = 'Downgraded_Speaker_Rank';
            r.note = 'Speaker requirement ' + requirement + ' unmet: ' +
                String.join(speakerReasons, '; ');
        }

        // 4 ------------------------------------------------------ human precedence
        if (
            existing != null &&
            existing.AAO_Established_By__c == 'HUMAN' &&
            String.isNotBlank(cand.AAO_Charter__c)
        ) {
            r.answer = existing;
            r.candidateStage = 'Reconciled';
            r.candidateOutcome = 'Superseded_By_Human';
            r.note = 'The standing answer was established by a human. Not overwritten.';
            stampCandidate(cand, r, null);
            return r;
        }

        String verdictBefore = existing == null ? null : existing.AAO_Verdict__c;
        if (existing != null && verdict == verdictBefore && claimOutcome == 'Established') {
            // New evidence confirming something already standing. It writes a claim and
            // moves no answer value, because guidance orders a person's criteria by what
            // they have pressed most recently and most often, and that is a count of
            // exactly these rows.
            claimOutcome = 'Reinforced';
            if (r.candidateOutcome == null) {
                r.candidateOutcome = 'Reinforced';
            }
        }

        // 5 ------------------------------------------ upsert, DUPLICATE_VALUE as merge
        AAO_Claim__c claim = buildClaim(
            cand, verdict, verdictBefore, claimOutcome, accumulated, internalPerson
        );

        AAO_Answer__c answer = existing == null
            ? newAnswer(cand)
            : existing;
        AAO_Accumulate.apply(answer, claim);
        // The union of the claims that built it, not the last one. An answer established
        // from a call and later reinforced by a state read rests on both.
        answer.AAO_Basis__c = AAO_EvidenceFamily.combine(
            answer.AAO_Basis__c,
            claim.AAO_Basis__c
        );
        answer.AAO_Publication_State__c = 'Live';

        answer = persist(answer, answerKey, claim, r);

        // 6 ----------------------------------------------------------- the receipt
        claim.AAO_Answer__c = answer.Id;
        claim.AAO_Candidate__c = cand.Id;
        insert claim;

        answer.AAO_Last_Claim__c = claim.Id;
        update answer;

        // Day-one red. TRUE clears the gating flag, FALSE holds it with a changed cause.
        // Here rather than in a trigger on Answer because commit is the single writer and
        // the clearance is part of establishing, not a side effect of a row changing.
        AAO_Flags.reconcile(cand.AAO_Opportunity__c, cand.AAO_Evidence_Contract__c);

        r.answer = answer;
        r.claim = claim;
        r.candidateStage = 'Committed';
        if (r.candidateOutcome == null) {
            r.candidateOutcome = 'Upheld';
        }
        stampCandidate(cand, r, claim.Id);
        return r;
    }

    // ------------------------------------------------------------------- internals

    /**
     * A test seam for the merge path. Under genuine concurrency another writer creates
     * the row between our read and our insert; there is no way to stage that inside one
     * transaction, so this makes the first read miss and lets the unique index do the
     * rest for real.
     */
    @TestVisible
    private static Boolean simulateLostRace = false;
    private static Boolean raceSimulated = false;

    private static AAO_Answer__c readExisting(String answerKey) {
        if (simulateLostRace && !raceSimulated) {
            raceSimulated = true;
            return null;
        }
        List<AAO_Answer__c> found = [
            SELECT
                Id,
                AAO_Answer_Key__c,
                AAO_Verdict__c,
                AAO_Basis__c,
                AAO_Spans__c,
                AAO_Element_Coverage__c,
                AAO_Interpretation__c,
                AAO_Established_By__c,
                AAO_Charter_Version__c,
                AAO_Rubric_Version__c,
                AAO_Evidence_Occurred__c,
                AAO_Subject_Type__c,
                AAO_Subject_Contact__c,
                AAO_Participant__c,
                AAO_Shadow_Person__c,
                AAO_Criterion__c,
                AAO_Evidence_Contract__c,
                AAO_Opportunity__c,
                AAO_Account__c,
                AAO_Publication_State__c
            FROM AAO_Answer__c
            WHERE AAO_Answer_Key__c = :answerKey
            LIMIT 1
        ];
        return found.isEmpty() ? null : found[0];
    }

    private static AAO_Answer__c newAnswer(AAO_Candidate__c cand) {
        return new AAO_Answer__c(
            AAO_Evidence_Contract__c = cand.AAO_Evidence_Contract__c,
            AAO_Opportunity__c = cand.AAO_Opportunity__c,
            AAO_Account__c = cand.AAO_Account__c,
            AAO_Subject_Type__c = cand.AAO_Subject_Type__c,
            AAO_Subject_Contact__c = cand.AAO_Subject_Contact__c,
            AAO_Participant__c = cand.AAO_Participant__c,
            AAO_Shadow_Person__c = cand.AAO_Shadow_Person__c,
            AAO_Criterion__c = cand.AAO_Criterion__c,
            AAO_Publication_State__c = 'Live'
        );
    }

    private static AAO_Claim__c buildClaim(
        AAO_Candidate__c cand,
        String verdictAfter,
        String verdictBefore,
        String outcome,
        AAO_Model.Coverage accumulated,
        Id internalPerson
    ) {
        return new AAO_Claim__c(
            AAO_Source__c = cand.AAO_Source__c,
            AAO_Evidence_Contract__c = cand.AAO_Evidence_Contract__c,
            AAO_Opportunity__c = cand.AAO_Opportunity__c,
            AAO_Account__c = cand.AAO_Account__c,
            AAO_Subject_Type__c = cand.AAO_Subject_Type__c,
            AAO_Subject_Contact__c = cand.AAO_Subject_Contact__c,
            // THE CLAIM KEYS THE PARTICIPANT (addendum 18). The Contact beside it is the
            // resolution outcome where one exists, and null is a legitimate answer.
            AAO_Participant__c = cand.AAO_Participant__c,
            AAO_Shadow_Person__c = cand.AAO_Shadow_Person__c,
            AAO_Criterion__c = cand.AAO_Criterion__c,
            AAO_External_Person__c = cand.AAO_Subject_Contact__c,
            AAO_Internal_Person__c = internalPerson,
            AAO_Verdict_Before__c = verdictBefore,
            AAO_Verdict_After__c = verdictAfter,
            AAO_Spans__c = cand.AAO_Spans__c,
            // The claim freezes the coverage as adjudicated on this pass, which is the
            // accumulated view, because that is what the verdict was decided on.
            AAO_Element_Coverage__c = AAO_Model.serializeCoverage(accumulated),
            AAO_Interpretation__c = cand.AAO_Interpretation__c,
            // The claim inherits the candidate's family. Hardcoding Transcript here was
            // safe only while every candidate had a Source; route P writes one that does
            // not, and a claim that misdeclared its family would be checked against the
            // wrong shape.
            AAO_Basis__c = String.isBlank(cand.AAO_Basis__c)
                ? AAO_EvidenceFamily.TRANSCRIPT
                : cand.AAO_Basis__c,
            AAO_Outcome__c = outcome,
            AAO_Actor__c = String.isBlank(cand.AAO_Charter__c) ? 'HUMAN' : 'MACHINE',
            AAO_Charter__c = cand.AAO_Charter__c,
            AAO_Charter_Version__c = cand.AAO_Charter_Version__c,
            AAO_Rubric_Version__c = cand.AAO_Evidence_Contract__r.AAO_Rubric_Version__c,
            // A state read has no artifact and therefore no delivery time. The
            // evidence occurred when the record was read, which is now.
            AAO_Evidence_Occurred__c = cand.AAO_Source__c == null
                ? System.now()
                : cand.AAO_Source__r.AAO_Evidence_Occurred__c,
            AAO_Recorded_At__c = System.now(),
            AAO_Retrospective__c = false
        );
    }

    /**
     * The merge path. DUPLICATE_VALUE on AAO_Answer_Key__c means another writer created
     * the row between our read and our insert. That is not an error: it is the unique
     * index doing the job it exists for. Catch it, re-read the colliding row, apply
     * precedence, proceed.
     */
    private static AAO_Answer__c persist(
        AAO_Answer__c answer,
        String answerKey,
        AAO_Claim__c claim,
        Result r
    ) {
        if (answer.Id != null) {
            update answer;
            return answer;
        }

        Database.SaveResult sr = Database.insert(answer, false);
        if (sr.isSuccess()) {
            answer.Id = sr.getId();
            return answer;
        }

        for (Database.Error e : sr.getErrors()) {
            if (e.getStatusCode() == StatusCode.DUPLICATE_VALUE) {
                AAO_Answer__c colliding = readExisting(answerKey);
                if (colliding == null) {
                    throw new CommitException(
                        'DUPLICATE_VALUE on "' +
                        answerKey +
                        '" but the colliding row could not be re-read. ' +
                        e.getMessage()
                    );
                }
                if (colliding.AAO_Established_By__c == 'HUMAN' && claim.AAO_Actor__c == 'MACHINE') {
                    r.note = 'Merged onto a human-established answer; not overwritten.';
                    r.merged = true;
                    return colliding;
                }
                AAO_Accumulate.apply(colliding, claim);
                colliding.AAO_Publication_State__c = 'Live';
                update colliding;
                r.merged = true;
                return colliding;
            }
        }
        throw new CommitException(
            'Could not write the answer: ' + sr.getErrors()[0].getMessage()
        );
    }

    /**
     * The internal participant behind this claim. Preference order matters: somebody who
     * actually spoke in the cited spans, before anybody merely present on the call. Never
     * the deal owner, who may not have been in the room.
     */
    private static Id resolveInternalPerson(
        Map<String, AAO_Model.Speaker> roster,
        Set<String> internalDomains,
        Map<Integer, String> speakerByIndex
    ) {
        Set<String> spokeHere = new Set<String>(speakerByIndex.values());

        Id fallback = null;
        for (AAO_Model.Speaker sp : roster.values()) {
            if (String.isBlank(sp.userId)) {
                continue;
            }
            String d = sp.domain();
            if (d == null || internalDomains == null || !internalDomains.contains(d)) {
                continue;
            }
            if (spokeHere.contains(sp.key)) {
                return (Id) sp.userId;
            }
            if (fallback == null) {
                fallback = (Id) sp.userId;
            }
        }
        return fallback;
    }

    private static void stampCandidate(AAO_Candidate__c cand, Result r, Id claimId) {
        cand.AAO_Stage__c = r.candidateStage;
        cand.AAO_Outcome__c = r.candidateOutcome;
        cand.AAO_Claim__c = claimId;
        update cand;
    }
}
