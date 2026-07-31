/**
 * THE EVIDENCE-FAMILY LAW. Ruled 47, 1 August 2026.
 *
 * `AAO_Source__c` used to be required on Candidate and Claim, which encoded an assumption
 * nobody had ever stated out loud: that all evidence is an artifact. Route P disproved it.
 * "One decision maker is named on the relationship map" rests on a record, not on bytes;
 * there is no transcript to point a Source at and inventing one would have manufactured an
 * artifact nobody delivered.
 *
 * So the required flag is gone and this replaces it. It is a strictly stronger check, not a
 * relaxation — `required` only ever asserted that a lookup was populated, and said nothing
 * about whether the row's evidence matched its shape:
 *
 *   Transcript  Source required, spans present.       Cited state rows forbidden.
 *   State       Source must be NULL, spans forbidden. At least one cited row required.
 *   Both        Source required, spans present.       At least one cited row required.
 *
 * WHERE EACH HALF IS ENFORCED, and why it is split. Everything about the row itself is
 * checked here, in before-insert, where a refusal costs nothing. The "at least one cited
 * row" half CANNOT be: `AAO_Claim_Basis__c` rows carry a lookup to the claim, so they do
 * not exist until the claim has an Id, and a before-insert trigger asking for them would
 * refuse every correct write. That half is enforced two ways instead:
 *
 *   forward  `requireBasisRows` — the single writer calls it after inserting the junction,
 *            inside the same transaction, so a throw rolls the claim back with it.
 *   reverse  the Claim Basis trigger refuses a cited row hung off a Transcript-only claim.
 *
 * The reverse direction is the one a trigger can hold absolutely, and it is the direction
 * an accident is likelier to take: a claim with cited rows it never declared is a claim
 * whose receipts do not match its story.
 */
public class AAO_EvidenceFamily {
    public static final String TRANSCRIPT = 'Transcript';
    public static final String STATE = 'State';
    public static final String BOTH = 'Both';

    /** True when this basis expects an artifact behind it. */
    public static Boolean needsSource(String basis) {
        return basis == TRANSCRIPT || basis == BOTH;
    }

    /** True when this basis expects named rows with their values frozen. */
    public static Boolean needsCitedRows(String basis) {
        return basis == STATE || basis == BOTH;
    }

    /**
     * The row-shaped half of the law, for one Candidate or one Claim. Returns null when the
     * row is lawful and the sentence to refuse it with when it is not.
     *
     * `label` names the object so the message says which table refused, because these two
     * are written by different code paths and the message is the first thing read.
     *
     * `isEstablishment` separates a proposal from an assertion. See the spans branch: an
     * abstention is a lawful candidate and never a lawful claim.
     */
    public static String violation(
        String label,
        String basis,
        Id sourceId,
        String spans,
        Boolean isEstablishment
    ) {
        if (String.isBlank(basis)) {
            return label +
                ' must declare its evidence family. Transcript, State or Both: what the ' +
                'row rests on decides what shape it has to be, and a row that will not say ' +
                'cannot be checked at all.';
        }
        if (needsSource(basis)) {
            if (sourceId == null) {
                return label +
                    ' has basis ' +
                    basis +
                    ' and no Source. Evidence that came from an artifact has to name the ' +
                    'artifact, or nothing can go back and read it.';
            }
            // ONLY AN ESTABLISHMENT NEEDS A QUOTE. A candidate is a proposal, and a
            // proposal with no spans is an abstention: the reader looked at this
            // proposition and found nothing said about it. That row is the whole record of
            // having looked and it has to be writable. A CLAIM is different — it asserts
            // something moved, and an assertion from an artifact with nothing quoted is a
            // claim nobody can go back and check.
            if (isEstablishment && String.isBlank(spans)) {
                return label +
                    ' has basis ' +
                    basis +
                    ' and no spans. An establishment from an artifact requires a citation.';
            }
            return null;
        }
        // State.
        if (sourceId != null) {
            return label +
                ' has basis State and a Source. State evidence is a record, not an ' +
                'artifact; a Source here would name a piece of evidence the answer was ' +
                'not read from. Cite the rows instead.';
        }
        if (String.isNotBlank(spans)) {
            return label +
                ' has basis State and carries spans. A span is a quotation from an ' +
                'artifact, and this row has none to quote from.';
        }
        return null;
    }

    /**
     * An answer stands on every claim that built it, so its family is the union of theirs.
     * A proposition established from a call and later reinforced by a state read genuinely
     * rests on both, which is what Both has always meant.
     *
     * Named `combine` because `merge` is an Apex DML statement and the compiler will not
     * have it. Fourth in the family after `system`, `commit` and `json`.
     */
    public static String combine(String standing, String arriving) {
        if (String.isBlank(standing)) {
            return arriving;
        }
        if (String.isBlank(arriving) || standing == arriving) {
            return standing;
        }
        return BOTH;
    }

    /**
     * What a row with no declared family should be READ as, for rows written before the
     * field existed. Every one of them came from a transcript, because until 47 nothing
     * else could be written at all. Assumed, not backfilled: the stored value stays null
     * and only the check treats it as Transcript, so nothing invents history.
     */
    public static String orTranscript(String basis) {
        return String.isBlank(basis) ? TRANSCRIPT : basis;
    }

    /**
     * The forward half, called by the writer after the junction is inserted and inside the
     * same transaction, so the throw takes the claim with it.
     *
     * This is deliberately not a soft warning. A State claim with no cited rows is an
     * assertion about the customer's data with nothing naming which record it read, which
     * is the exact failure the whole Claim Basis table exists to make impossible.
     */
    public static void requireBasisRows(Set<Id> claimIds) {
        if (claimIds == null || claimIds.isEmpty()) {
            return;
        }
        Map<Id, AAO_Claim__c> byId = new Map<Id, AAO_Claim__c>(
            [SELECT Id, Name, AAO_Basis__c FROM AAO_Claim__c WHERE Id IN :claimIds]
        );
        Set<Id> withRows = new Set<Id>();
        for (AAO_Claim_Basis__c b : [
            SELECT AAO_Claim__c FROM AAO_Claim_Basis__c WHERE AAO_Claim__c IN :claimIds
        ]) {
            withRows.add(b.AAO_Claim__c);
        }
        for (AAO_Claim__c c : byId.values()) {
            if (needsCitedRows(c.AAO_Basis__c) && !withRows.contains(c.Id)) {
                throw new FamilyException(
                    'Claim ' +
                    c.Name +
                    ' has basis ' +
                    c.AAO_Basis__c +
                    ' and no cited rows. State evidence has to name the records it read ' +
                    'and freeze what they said, or it is an assertion with no receipt.'
                );
            }
        }
    }

    public class FamilyException extends Exception {
    }
}
