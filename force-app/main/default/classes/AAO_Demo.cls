/**
 * The durable rehearsal. Same fixtures as the exit test, committed for real.
 *
 * The exit test proves the behaviour and then rolls back, so nobody can open the org and
 * look at it. This leaves the two claims, the answer and the ledger sitting on a deal that
 * can be clicked through. It is the QBR artifact.
 *
 * Three properties it has to have, and how each is achieved:
 *
 *   **The timeline is real.** passOne and passTwo are separate entry points, meant to be
 *   run as separate transactions. The evidence-occurred clock is eleven days apart because
 *   the transcripts say so; the recorded-at clock is genuinely apart because the two runs
 *   genuinely are. The exit test cannot show that — it commits both inside one transaction.
 *
 *   **Idempotent.** Every pass checks whether its own claim already exists before writing.
 *   The unique keys do most of the work: a re-delivered Source collides on
 *   AAO_Scope_Key__c and a re-derived contract collides on AAO_Contract_Key__c. Claims
 *   have no unique key, by design, so the guard here is explicit.
 *
 *   **Removable in one action.** Every AAO row is marked AAO_Synthetic__c at insert, and
 *   purge deletes only marked rows. Account, Opportunity and Contact carry no marker
 *   field — no field is added to a standard object for this — so they are matched by their
 *   deliberately unmistakable names instead.
 *
 * Run:
 *   AAO_Demo.passOne();       // transcript one  -> UNVERIFIED
 *   AAO_Demo.passTwo();       // transcript two  -> TRUE      (separate transaction)
 *   AAO_Demo.passNegative();  // the seller said it -> UNVERIFIED, on its own deal
 *   AAO_Demo.status();
 *   AAO_Demo.purge();
 */
public class AAO_Demo {
    public static final String ACCOUNT_NAME = 'AAO Demo - Tungsten Rehearsal';
    public static final String OPP_MAIN = 'AAO Demo - Tungsten Rehearsal';
    public static final String OPP_NEGATIVE = 'AAO Demo - Tungsten Rehearsal (seller said it)';
    /** Seeded empty. Evidence arrives here through the live path, not through a pass. */
    public static final String OPP_LIVE = 'AAO Demo - Live';
    public static final String CHARTER = 'AAO_Extract_Evidence';
    public static final String CHARTER_VERSION = '0.1.0';

    public class DemoException extends Exception {
    }

    /** Everything the rehearsal needs, found or created. */
    public class Ctx {
        public Account acct;
        public Map<String, Id> oppByDeal = new Map<String, Id>();
        public Map<String, Contact> contactByKey = new Map<String, Contact>();
        public Map<String, AAO_Evidence_Contract__c> contractByCode =
            new Map<String, AAO_Evidence_Contract__c>();
        public Set<String> internalDomains = new Set<String>();
        public Map<String, Object> fixture;
        public String rosterJson;
    }

    // ===================================================================== the passes

    public static String passOne() {
        return runPass('T1SRC', OPP_MAIN);
    }

    public static String passTwo() {
        return runPass('T2SRC', OPP_MAIN);
    }

    public static String passNegative() {
        return runPass('NEGSRC', OPP_NEGATIVE);
    }

    /**
     * The rehearsal runs the pipeline synchronously and in order, because a demonstration
     * of accumulation has to be deterministic about which transcript landed first. The
     * live path on OPP_LIVE runs the same pipeline asynchronously; see AAO_Live.
     */
    private static String runPass(String sourceCode, String oppName) {
        Ctx c = scaffold();
        Id oppId = c.oppByDeal.get(oppName);

        // Auto-ingest off: this entry adjudicates inline, and a Queueable enqueued by the
        // same insert would arrive afterwards to find the work already done. Harmless, but
        // an async job fired for nothing is a thing a future reader would have to explain.
        Boolean prior = AAO_Ingest.AUTO;
        AAO_Ingest.AUTO = false;
        AAO_Pipeline.Outcome o;
        try {
            AAO_Synthetic.MARK = true;
            AAO_Source__c src = findSource(c, sourceCode, oppId);
            AAO_Synthetic.MARK = false;
            o = AAO_Pipeline.runForSource(src.Id, c.internalDomains);
        } finally {
            AAO_Ingest.AUTO = prior;
            AAO_Synthetic.MARK = false;
        }

        if (o.status == 'already_committed') {
            return 'SKIPPED. ' +
                sourceCode +
                ' has already been committed on ' +
                oppName +
                '. Nothing written. Run AAO_Demo.purge() first to redo it.';
        }
        return 'OK. ' + sourceCode + ' committed on ' + oppName + '. ' + o;
    }

    // ================================================================== the scaffold

    public static Ctx scaffold() {
        Ctx c = new Ctx();
        c.fixture = AAO_Seed.fixture();
        for (Object d : (List<Object>) c.fixture.get('internalDomains')) {
            c.internalDomains.add(((String) d).toLowerCase());
        }

        // ---- account
        List<Account> accts = [SELECT Id, Name FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        if (accts.isEmpty()) {
            c.acct = new Account(Name = ACCOUNT_NAME);
            insert c.acct;
        } else {
            c.acct = accts[0];
        }

        // ---- the three deals
        Map<String, Opportunity> oppByName = new Map<String, Opportunity>();
        for (Opportunity o : [
            SELECT Id, Name
            FROM Opportunity
            WHERE Name IN (:OPP_MAIN, :OPP_NEGATIVE, :OPP_LIVE) AND AccountId = :c.acct.Id
        ]) {
            oppByName.put(o.Name, o);
        }
        List<Opportunity> toInsert = new List<Opportunity>();
        for (String n : new List<String>{ OPP_MAIN, OPP_NEGATIVE, OPP_LIVE }) {
            if (!oppByName.containsKey(n)) {
                toInsert.add(
                    new Opportunity(
                        Name = n,
                        AccountId = c.acct.Id,
                        StageName = AAO_Seed.defaultStage(),
                        CloseDate = Date.newInstance(2026, 12, 31)
                    )
                );
            }
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
            for (Opportunity o : toInsert) {
                oppByName.put(o.Name, o);
            }
        }
        for (String n : oppByName.keySet()) {
            c.oppByDeal.put(n, oppByName.get(n).Id);
        }

        // Day-one red. Raised here because Opportunity is a standard object and we do not
        // put triggers on objects we do not own, so "on deal creation" is the caller's
        // job. Idempotent, so scaffolding twice raises nothing twice.
        //
        // THE CONTRACTS HAVE TO EXIST FIRST. The rubric is what says which propositions
        // gate, so raising before it is loaded raises nothing at all and does it silently.
        // That passed against an org where a previous run had already left contracts
        // behind, and failed against a test, which is the right way round to find it.
        AAO_Synthetic.MARK = true;
        try {
            c.contractByCode = AAO_Seed.ensureContracts(c.fixture);
            // Explicitly the synthetic set. The rehearsal answers the fixture's questions,
            // and the product path cannot see them.
            AAO_Flags.raiseFor(new Set<Id>(c.oppByDeal.values()), true);
        } finally {
            AAO_Synthetic.MARK = false;
        }

        // ---- the roster, as contacts
        List<Object> people = (List<Object>) c.fixture.get('people');
        Map<String, String> emailByKey = new Map<String, String>();
        Set<String> emails = new Set<String>();
        for (Object o : people) {
            Map<String, Object> p = (Map<String, Object>) o;
            emailByKey.put((String) p.get('key'), (String) p.get('email'));
            emails.add((String) p.get('email'));
        }
        Map<String, Contact> byEmail = new Map<String, Contact>();
        for (Contact ct : [
            SELECT Id, Email
            FROM Contact
            WHERE Email IN :emails AND AccountId = :c.acct.Id
        ]) {
            byEmail.put(ct.Email, ct);
        }
        List<Contact> newContacts = new List<Contact>();
        for (Object o : people) {
            Map<String, Object> p = (Map<String, Object>) o;
            String email = (String) p.get('email');
            if (byEmail.containsKey(email)) {
                continue;
            }
            String display = (String) p.get('display');
            newContacts.add(
                new Contact(
                    FirstName = display.substringBefore(' '),
                    LastName = display.substringAfter(' '),
                    Email = email,
                    Title = (String) p.get('title'),
                    AccountId = c.acct.Id
                )
            );
        }
        if (!newContacts.isEmpty()) {
            insert newContacts;
            for (Contact ct : newContacts) {
                byEmail.put(ct.Email, ct);
            }
        }
        for (String key : emailByKey.keySet()) {
            c.contactByKey.put(key, byEmail.get(emailByKey.get(key)));
        }
        c.rosterJson = AAO_Seed.rosterFor(people, c.contactByKey, c.internalDomains);

        // ---- the mini-rubric, from the one place both entries read it
        AAO_Synthetic.MARK = true;
        c.contractByCode = AAO_Seed.ensureContracts(c.fixture);
        AAO_Synthetic.MARK = false;

        return c;
    }

    // ==================================================================== the records

    /**
     * Find the Source for this fixture code on this deal, or create it. Public because the
     * live path creates its Sources the same way; what differs between the two entries is
     * only whether AAO_Ingest.AUTO is on when the insert happens.
     */
    public static AAO_Source__c findSource(Ctx c, String sourceCode, Id oppId) {
        Map<String, Object> spec = null;
        for (Object o : (List<Object>) c.fixture.get('sources')) {
            Map<String, Object> s = (Map<String, Object>) o;
            if (s.get('code') == sourceCode) {
                spec = s;
                break;
            }
        }
        if (spec == null) {
            throw new DemoException('No source "' + sourceCode + '" in the fixture.');
        }

        String text = AAO_Seed.normalizedTextFor(spec);
        String artifactSha = AAO_Seed.artifactSha(spec);
        String scopeKey = AAO_ScopeKey.compose(oppId, artifactSha, 1);

        List<AAO_Source__c> found = [
            SELECT Id, AAO_Normalized_Text__c, AAO_Source_Ref__c, AAO_Scope_Key__c
            FROM AAO_Source__c
            WHERE AAO_Scope_Key__c = :scopeKey
            LIMIT 1
        ];
        if (!found.isEmpty()) {
            return found[0];
        }

        AAO_Synthetic.MARK = true;
        AAO_Source__c src = new AAO_Source__c(
            AAO_Opportunity__c = oppId,
            AAO_Account__c = c.acct.Id,
            AAO_Normalized_Text__c = text,
            AAO_Diarization__c = (String) spec.get('diarization'),
            AAO_Speaker_Roster__c = spec.get('diarization') == 'Unsegmented'
                ? null
                : c.rosterJson,
            AAO_SHA256__c = AAO_NormalForm.sha256(text),
            AAO_Artifact_SHA256__c = artifactSha,
            AAO_Part_Index__c = 1,
            AAO_Part_Count__c = 1,
            AAO_Source_Ref__c = (String) spec.get('sourceRef'),
            AAO_Origin__c = (String) spec.get('origin'),
            AAO_Evidence_Occurred__c = AAO_Seed.gmt((String) spec.get('occurred')),
            AAO_Duration_Seconds__c = (Integer) spec.get('durationSeconds')
        );
        insert src;
        AAO_Synthetic.MARK = false;
        return [
            SELECT Id, AAO_Normalized_Text__c, AAO_Source_Ref__c, AAO_Scope_Key__c
            FROM AAO_Source__c
            WHERE Id = :src.Id
        ];
    }

    // ======================================================================== status

    public static String status() {
        List<String> out = new List<String>();
        for (Opportunity o : [
            SELECT Id, Name
            FROM Opportunity
            WHERE Name IN (:OPP_MAIN, :OPP_NEGATIVE, :OPP_LIVE)
            ORDER BY Name
        ]) {
            out.add('--- ' + o.Name + ' (' + o.Id + ')');
            for (AAO_Answer__c a : [
                SELECT
                    Name,
                    AAO_Verdict__c,
                    AAO_Established_By__c,
                    AAO_Element_Completeness__c,
                    AAO_Evidence_Occurred__c,
                    AAO_Evidence_Contract__r.AAO_Proposition_Code__c
                FROM AAO_Answer__c
                WHERE AAO_Opportunity__c = :o.Id
            ]) {
                out.add(
                    '    answer ' +
                    a.Name +
                    ' ' +
                    a.AAO_Evidence_Contract__r.AAO_Proposition_Code__c +
                    ' = ' +
                    a.AAO_Verdict__c +
                    ' by ' +
                    a.AAO_Established_By__c +
                    ' coverage=' +
                    a.AAO_Element_Completeness__c
                );
            }
            for (AAO_Claim__c cl : [
                SELECT
                    Name,
                    AAO_Verdict_Before__c,
                    AAO_Verdict_After__c,
                    AAO_Outcome__c,
                    AAO_Evidence_Occurred__c,
                    AAO_Recorded_At__c,
                    AAO_Internal_Person__c,
                    AAO_Source__r.AAO_Source_Ref__c
                FROM AAO_Claim__c
                WHERE AAO_Opportunity__c = :o.Id
                ORDER BY AAO_Evidence_Occurred__c ASC
            ]) {
                out.add(
                    '    claim  ' +
                    cl.Name +
                    ' ' +
                    cl.AAO_Verdict_Before__c +
                    ' -> ' +
                    cl.AAO_Verdict_After__c +
                    ' (' +
                    cl.AAO_Outcome__c +
                    ') occurred=' +
                    cl.AAO_Evidence_Occurred__c.formatGmt('yyyy-MM-dd') +
                    ' recorded=' +
                    cl.AAO_Recorded_At__c.formatGmt('yyyy-MM-dd HH:mm:ss') +
                    ' key4=' +
                    cl.AAO_Internal_Person__c +
                    ' src=' +
                    cl.AAO_Source__r.AAO_Source_Ref__c
                );
            }
            out.add(
                '    candidates=' +
                [SELECT COUNT() FROM AAO_Candidate__c WHERE AAO_Opportunity__c = :o.Id] +
                ' (abstained=' +
                [
                    SELECT COUNT()
                    FROM AAO_Candidate__c
                    WHERE AAO_Opportunity__c = :o.Id AND AAO_Outcome__c = 'Abstained'
                ] +
                ' notReturned=' +
                [
                    SELECT COUNT()
                    FROM AAO_Candidate__c
                    WHERE AAO_Opportunity__c = :o.Id AND AAO_Outcome__c = 'Not_Returned'
                ] +
                ')' +
                ' sources=' +
                [SELECT COUNT() FROM AAO_Source__c WHERE AAO_Opportunity__c = :o.Id] +
                ' redsStanding=' +
                AAO_Flags.standing(o.Id)
            );
        }
        return out.isEmpty() ? 'Nothing seeded.' : String.join(out, '\n');
    }

    // ========================================================================= purge

    /**
     * Removable in one action. Deletion order follows the required lookups, which carry
     * Restrict: a parent cannot go before its children. Only marked rows are touched, and
     * the triggers enforce that independently — PURGING alone is not enough to delete a
     * claim that was not written by the rehearsal.
     */
    public static String purge() {
        AAO_Synthetic.PURGING = true;
        List<String> out = new List<String>();
        try {
            out.add('claim bases ' + del([SELECT Id FROM AAO_Claim_Basis__c WHERE AAO_Synthetic__c = TRUE]));
            out.add('claims      ' + del([SELECT Id FROM AAO_Claim__c WHERE AAO_Synthetic__c = TRUE]));
            out.add('flags       ' + del([SELECT Id FROM AAO_Flag__c WHERE AAO_Synthetic__c = TRUE]));
            out.add('candidates  ' + del([SELECT Id FROM AAO_Candidate__c WHERE AAO_Synthetic__c = TRUE]));
            out.add('answers     ' + del([SELECT Id FROM AAO_Answer__c WHERE AAO_Synthetic__c = TRUE]));
            out.add('participants' + del([SELECT Id FROM AAO_Participant__c WHERE AAO_Synthetic__c = TRUE]));
            out.add('sources     ' + del([SELECT Id FROM AAO_Source__c WHERE AAO_Synthetic__c = TRUE]));
            out.add('contracts   ' + del([SELECT Id FROM AAO_Evidence_Contract__c WHERE AAO_Synthetic__c = TRUE]));

            // Standard objects carry no marker field, because no field is added to a
            // standard object for a rehearsal. They are matched by name instead, which is
            // why the names are deliberately unmistakable.
            List<Opportunity> opps = [
                SELECT Id FROM Opportunity WHERE Name IN (:OPP_MAIN, :OPP_NEGATIVE, :OPP_LIVE)
            ];
            out.add('opportunities ' + del(opps));
            List<Account> accts = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME];
            out.add('contacts    ' + del([SELECT Id FROM Contact WHERE AccountId IN :accts]));
            out.add('accounts    ' + del(accts));
        } finally {
            AAO_Synthetic.PURGING = false;
        }
        return 'purged:\n  ' + String.join(out, '\n  ');
    }

    private static Integer del(List<SObject> rows) {
        if (!rows.isEmpty()) {
            delete rows;
        }
        return rows.size();
    }
}
