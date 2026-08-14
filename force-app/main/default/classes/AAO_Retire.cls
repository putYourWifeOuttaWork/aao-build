/**
 * CLAIMS RETIRE, NEVER DELETE. Ruled by Matthew, 6 August 2026.
 *
 * **The locked record law reaching the claim ledger.** A claim that should never have
 * established anything presents a problem the ledger had no answer for: deleting it destroys
 * the evidence of our own mistake, which is exactly the thing worth keeping, and correcting it
 * in place is editing history. So it is marked retired. The replay skips it, the derivation
 * empties, and **retraction - already ratified and already built - clears the map value it had
 * carried.** The correction travels the lawful path rather than a special one.
 *
 * **The first case is the one that earned the ruling.** Run `em0806-a21` reproduced
 * `trap-seq11-courtesy`: call 3 upheld a courtesy read as SUPPORTER, the join wrote it as
 * Ryan Couture's only sentiment claim, the counter moved to +1, and projection put Supporter
 * on his map row. The never-projected rule now refuses that pair at the claim on every future
 * run, but a rule built today does not reach backwards, and the standing value was wrong.
 *
 * **What retirement is NOT.** It is not a verdict that the words were misquoted, and it is not
 * a judgment about the person. The pair still exists, the quote still byte-locates, call 3's
 * verdict still stands on the record. What retirement says is narrower and is the only thing
 * it says: **this establishment should not have moved anything.**
 */
public with sharing class AAO_Retire {
    public class RetireException extends Exception {
    }

    /** The shortest honest reason names what was wrong. Same floor the resolver's guard uses. */
    @TestVisible
    private static Integer REASON_MIN_CHARS = 25;

    public class Outcome {
        public Integer read = 0;
        public Integer retired = 0;
        public Integer alreadyRetired = 0;
        /** The replay's disagreement with the standing answers, corrected in the same breath. */
        public Integer verdictsRebuilt = 0;
        public Integer countersRebuilt = 0;
        public List<String> lines = new List<String>();

        public override String toString() {
            String s = String.join(
                new List<String>{
                    'claims read              ' + read + ' (unit: claims)',
                    '  retired                ' + retired + ' (unit: claims)',
                    '  already retired        ' + alreadyRetired + ' (unit: claims)',
                    'verdicts rebuilt         ' + verdictsRebuilt + ' (unit: answers)',
                    'counters rebuilt         ' + countersRebuilt + ' (unit: people)'
                },
                '\n'
            );
            for (String l : lines) {
                s += '\n  ' + l;
            }
            return s;
        }
    }

    /**
     * Retire claims by id, with one reason covering them.
     *
     * Bulk rather than one-at-a-time because a retirement is usually a set: a trap that fired
     * across several pairs is one decision about one graded finding, and splitting it into N
     * calls would let half of it land.
     */
    public static Outcome byIds(Set<Id> claimIds, String because) {
        Outcome o = new Outcome();
        if (claimIds == null || claimIds.isEmpty()) {
            return o;
        }
        String reason = because == null ? '' : because.trim();
        if (reason.length() < REASON_MIN_CHARS) {
            throw new RetireException(
                'A retirement carries its reason, and this one is ' + reason.length() +
                ' characters. Retiring rather than deleting exists so somebody later can ' +
                'read what we got wrong and why we decided so; a retirement nobody can read ' +
                'is a deletion that left a row behind.'
            );
        }

        List<AAO_Claim__c> claims = [
            SELECT Id, Name, AAO_Retired__c, AAO_Verdict_After__c, AAO_Participant__c,
                AAO_Answer__c, AAO_Opportunity__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c
            FROM AAO_Claim__c
            WHERE Id IN :claimIds
        ];
        o.read = claims.size();

        List<AAO_Claim__c> toUpdate = new List<AAO_Claim__c>();
        for (AAO_Claim__c c : claims) {
            if (c.AAO_Retired__c == true) {
                // Idempotent on purpose. Re-running a correction must not throw, or the safe
                // response to an uncertain state becomes "do not run it".
                o.alreadyRetired++;
                o.lines.add(c.Name + ' was already retired; left alone.');
                continue;
            }
            toUpdate.add(
                new AAO_Claim__c(
                    Id = c.Id,
                    AAO_Retired__c = true,
                    AAO_Retired_Because__c = reason,
                    AAO_Retired_At__c = System.now()
                )
            );
            o.lines.add(
                c.Name + ' [' +
                (c.AAO_Evidence_Contract__r == null
                    ? 'no contract'
                    : c.AAO_Evidence_Contract__r.AAO_Proposition_Code__c) +
                '] retired; it had established ' + c.AAO_Verdict_After__c + '.'
            );
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
            o.retired = toUpdate.size();
        }
        // The reconcile below runs over every claim READ, not only the ones this call marked.
        // Idempotency has to reach the whole operation: a retirement that marked the row and
        // then failed before reconciling would otherwise be uncorrectable by re-running, which
        // is the worst property a correction path can have.

        // **RETIREMENT RECONCILES THE LEDGER OR IT IS ONLY A LABEL.** Marking the claim is half
        // the ruling; the other half is that the replay now disagrees with the standing answer,
        // and nothing else in the system would ever run it - the join reaches its rebuilds only
        // on its own runs, and a retirement joins no pairs. An answer still reading TRUE over a
        // retired claim is precisely the divergence this exists to close, so it is closed here,
        // in the same transaction, rather than left for a later run that may never come.
        Set<Id> answerIds = new Set<Id>();
        Set<String> personScopes = new Set<String>();
        for (AAO_Claim__c c : claims) {
            if (c.AAO_Answer__c != null) {
                answerIds.add(c.AAO_Answer__c);
            }
            if (c.AAO_Participant__c != null && c.AAO_Opportunity__c != null) {
                personScopes.add(
                    String.valueOf(c.AAO_Participant__c) + '|' + c.AAO_Opportunity__c
                );
            }
        }
        o.verdictsRebuilt = AAO_PairCommit.rebuildVerdicts(answerIds);
        o.countersRebuilt = AAO_PairCommit.rebuildCounters(personScopes);
        return o;
    }

    /**
     * Retire every claim on a run that reproduces a standing graded trap.
     *
     * **This is the backward-reaching half of the never-projected rule.** `AAO_PairCommit`
     * refuses a trapped pair before it becomes a claim, which fixes every run from here on and
     * reaches nothing already written. This retires what is already written, by the same
     * matcher, so the two halves cannot disagree about what a trap is.
     */
    public static Outcome trapsOnRun(String runKey) {
        if (String.isBlank(runKey)) {
            throw new RetireException('Cannot retire a run\'s traps with no run key.');
        }
        List<AAO_Pair__c> pairs = [
            SELECT
                Id,
                AAO_Pair_Ref__c,
                AAO_Claim__c,
                AAO_Answer_Text__c,
                AAO_Located_Pair__r.AAO_Answer_Text__c,
                AAO_Evidence_Contract__r.AAO_Proposition_Code__c,
                AAO_Located_Pair__r.AAO_Source__r.AAO_Normalized_Text__c,
                AAO_Located_Pair__r.AAO_Source__r.AAO_SHA256__c,
                AAO_Located_Pair__r.AAO_Source__r.AAO_Source_Ref__c
            FROM AAO_Pair__c
            WHERE AAO_Run_Key__c = :runKey
                AND AAO_Stage__c = 'Identified'
                AND AAO_Claim__c != NULL
        ];
        Outcome o = new Outcome();
        if (pairs.isEmpty()) {
            return o;
        }
        AAO_Source__c src = pairs[0].AAO_Located_Pair__r.AAO_Source__r;
        Map<Id, String> traps = AAO_Regression.trapped(
            pairs, src.AAO_Normalized_Text__c, src.AAO_SHA256__c, src.AAO_Source_Ref__c
        );
        if (traps.isEmpty()) {
            return o;
        }
        Map<Id, String> reasonByClaim = new Map<Id, String>();
        for (AAO_Pair__c p : pairs) {
            if (traps.containsKey(p.Id)) {
                reasonByClaim.put(
                    p.AAO_Claim__c,
                    'Retired 6 August 2026 under the never-projected rule (Addendum 17). ' +
                    'Pair ' + p.AAO_Pair_Ref__c + ' on run ' + runKey + ' reproduces the ' +
                    'standing graded trap "' + traps.get(p.Id) + '". Call 3 upheld it, which ' +
                    'is why it reached a claim at all; the grading is what refuses it. The ' +
                    'pair, its quote and its verdict are untouched and still readable.'
                );
            }
        }
        // One reason per trap, so a run reproducing two traps does not label both with one.
        for (Id claimId : reasonByClaim.keySet()) {
            Outcome one = byIds(new Set<Id>{ claimId }, reasonByClaim.get(claimId));
            o.read += one.read;
            o.retired += one.retired;
            o.alreadyRetired += one.alreadyRetired;
            o.lines.addAll(one.lines);
        }
        return o;
    }
}