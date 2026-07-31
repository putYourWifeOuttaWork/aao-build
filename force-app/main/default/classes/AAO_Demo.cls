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
        return runPass('T1SRC', 'C1', 'main', OPP_MAIN);
    }

    public static String passTwo() {
        return runPass('T2SRC', 'C2', 'main', OPP_MAIN);
    }

    public static String passNegative() {
        return runPass('NEGSRC', 'CNEG', 'negative', OPP_NEGATIVE);
    }

    private static String runPass(
        String sourceCode,
        String candidateCode,
        String fixtureDeal,
        String oppName
    ) {
        Ctx c = scaffold();
        Id oppId = c.oppByDeal.get(oppName);

        AAO_Source__c src = findSource(c, sourceCode, oppId);
        if (alreadyCommitted(src.Id)) {
            return 'SKIPPED. ' +
                sourceCode +
                ' has already been committed on ' +
                oppName +
                '. Nothing written. Run AAO_Demo.purge() first to redo it.';
        }

        AAO_Synthetic.MARK = true;
        AAO_Candidate__c cand = buildCandidate(c, candidateCode, src, oppId);
        AAO_Commit.Result r = AAO_Commit.commitCandidate(cand.Id, c.internalDomains);
        List<AAO_Candidate__c> abstentions = logAbstentions(c, src, oppId);
        AAO_Synthetic.MARK = false;

        return 'OK. ' +
            sourceCode +
            ' committed on ' +
            oppName +
            '. verdict=' +
            (r.answer == null ? 'none' : r.answer.AAO_Verdict__c) +
            ' claim=' +
            (r.claim == null ? 'none' : r.claim.AAO_Outcome__c) +
            ' internalPerson=' +
            (r.claim == null ? 'n/a' : String.valueOf(r.claim.AAO_Internal_Person__c)) +
            ' abstentions=' +
            abstentions.size() +
            (String.isBlank(r.note) ? '' : ' note=' + r.note);
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

        // ---- the two deals
        Map<String, Opportunity> oppByName = new Map<String, Opportunity>();
        for (Opportunity o : [
            SELECT Id, Name
            FROM Opportunity
            WHERE Name IN (:OPP_MAIN, :OPP_NEGATIVE) AND AccountId = :c.acct.Id
        ]) {
            oppByName.put(o.Name, o);
        }
        List<Opportunity> toInsert = new List<Opportunity>();
        for (String n : new List<String>{ OPP_MAIN, OPP_NEGATIVE }) {
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

        // ---- the mini-rubric, found by its question record id
        Map<String, AAO_Evidence_Contract__c> existing =
            new Map<String, AAO_Evidence_Contract__c>();
        for (AAO_Evidence_Contract__c ec : [
            SELECT Id, AAO_Question_Record_Id__c, AAO_Rubric_Version__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Rubric_Version__c = :AAO_Seed.RUBRIC_VERSION
        ]) {
            existing.put(ec.AAO_Question_Record_Id__c, ec);
        }

        AAO_Synthetic.MARK = true;
        List<AAO_Evidence_Contract__c> newContracts = new List<AAO_Evidence_Contract__c>();
        List<String> newCodes = new List<String>();
        for (Object o : (List<Object>) c.fixture.get('rubric')) {
            Map<String, Object> q = (Map<String, Object>) o;
            String code = (String) q.get('code');
            if (existing.containsKey(code)) {
                c.contractByCode.put(code, existing.get(code));
                continue;
            }
            List<Object> elements = (List<Object>) q.get('elements');
            newCodes.add(code);
            newContracts.add(
                new AAO_Evidence_Contract__c(
                    AAO_Question_Record_Id__c = code,
                    AAO_Proposition_Code__c = code,
                    AAO_Proposition_Short__c = (String) q.get('short'),
                    AAO_Proposition_Text__c = (String) q.get('proposition'),
                    AAO_Guidance_Text__c = (String) q.get('guidance'),
                    AAO_Elements__c = JSON.serialize(elements),
                    AAO_Element_Count__c = elements.size(),
                    AAO_Elements_Basis__c = (String) q.get('elementsBasis'),
                    AAO_Route__c = (String) q.get('route'),
                    AAO_Speaker_Requirement__c = (String) q.get('speakerRequirement'),
                    AAO_Decay_Class__c = (String) q.get('decayClass'),
                    AAO_Gating__c = (Boolean) q.get('gating'),
                    AAO_Solicit__c = (Boolean) q.get('solicit'),
                    AAO_Per_Person_Source__c = (String) q.get('perPersonSource'),
                    AAO_Requires_Ratification__c = (Boolean) q.get('requiresRatification'),
                    AAO_Contract_State__c = (String) q.get('contractState'),
                    AAO_Rubric_Version__c = AAO_Seed.RUBRIC_VERSION
                )
            );
        }
        if (!newContracts.isEmpty()) {
            insert newContracts;
            for (Integer i = 0; i < newCodes.size(); i++) {
                c.contractByCode.put(newCodes[i], newContracts[i]);
            }
        }
        AAO_Synthetic.MARK = false;

        return c;
    }

    // ==================================================================== the records

    /** Find the Source for this fixture code on this deal, or create it. */
    private static AAO_Source__c findSource(Ctx c, String sourceCode, Id oppId) {
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
        String artifactSha = AAO_NormalForm.sha256((String) spec.get('sourceRef'));
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
            AAO_Duration_Seconds__c = (Integer) spec.get('durationSeconds'),
            AAO_Normalizer_Version__c = AAO_NormalForm.VERSION
        );
        insert src;
        AAO_Synthetic.MARK = false;
        return [
            SELECT Id, AAO_Normalized_Text__c, AAO_Source_Ref__c, AAO_Scope_Key__c
            FROM AAO_Source__c
            WHERE Id = :src.Id
        ];
    }

    private static AAO_Candidate__c buildCandidate(
        Ctx c,
        String candidateCode,
        AAO_Source__c src,
        Id oppId
    ) {
        Map<String, Object> spec = null;
        for (Object o : (List<Object>) c.fixture.get('candidates')) {
            Map<String, Object> cc = (Map<String, Object>) o;
            if (cc.get('code') == candidateCode) {
                spec = cc;
                break;
            }
        }
        if (spec == null) {
            throw new DemoException('No candidate "' + candidateCode + '" in the fixture.');
        }

        List<AAO_Model.Span> spans = new List<AAO_Model.Span>();
        for (Object so : (List<Object>) spec.get('spans')) {
            Map<String, Object> sp = (Map<String, Object>) so;
            spans.add(
                AAO_Seed.resolve(
                    src,
                    (String) sp.get('quote'),
                    (String) sp.get('speaker'),
                    (String) sp.get('element')
                )
            );
        }

        AAO_Candidate__c cand = new AAO_Candidate__c(
            AAO_Evidence_Contract__c = c.contractByCode
                .get((String) spec.get('contractCode'))
                .Id,
            AAO_Source__c = src.Id,
            AAO_Opportunity__c = oppId,
            AAO_Account__c = c.acct.Id,
            AAO_Subject_Type__c = (String) spec.get('subjectType'),
            AAO_Proposed_Verdict__c = (String) spec.get('proposedVerdict'),
            AAO_Spans__c = AAO_Model.serializeSpans(spans),
            AAO_Element_Coverage__c = AAO_Model.serializeCoverage(
                AAO_Model.newCoverage(
                    AAO_Seed.strings((List<Object>) spec.get('covered')),
                    AAO_Seed.strings((List<Object>) spec.get('missing'))
                )
            ),
            AAO_Stage__c = 'Adjudicated',
            AAO_Outcome__c = 'Pending',
            AAO_Charter__c = CHARTER,
            AAO_Charter_Version__c = CHARTER_VERSION,
            AAO_Publication_State__c = 'Live',
            AAO_Synthetic__c = true
        );
        insert cand;
        return cand;
    }

    /** The complete ledger for this pass: a row for every proposition nothing was said about. */
    private static List<AAO_Candidate__c> logAbstentions(Ctx c, AAO_Source__c src, Id oppId) {
        Set<Id> proposedFor = new Set<Id>();
        for (AAO_Candidate__c cd : [
            SELECT AAO_Evidence_Contract__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :src.Id
        ]) {
            proposedFor.add(cd.AAO_Evidence_Contract__c);
        }

        List<AAO_Candidate__c> rows = new List<AAO_Candidate__c>();
        for (AAO_Evidence_Contract__c ec : c.contractByCode.values()) {
            if (proposedFor.contains(ec.Id)) {
                continue;
            }
            rows.add(
                new AAO_Candidate__c(
                    AAO_Evidence_Contract__c = ec.Id,
                    AAO_Source__c = src.Id,
                    AAO_Opportunity__c = oppId,
                    AAO_Account__c = c.acct.Id,
                    AAO_Subject_Type__c = 'Opportunity',
                    AAO_Stage__c = 'Adjudicated',
                    AAO_Outcome__c = 'Abstained',
                    AAO_Abstention_Reason__c = 'nobody_said',
                    AAO_Charter__c = CHARTER,
                    AAO_Charter_Version__c = CHARTER_VERSION,
                    AAO_Publication_State__c = 'Live',
                    AAO_Synthetic__c = true
                )
            );
        }
        insert rows;
        return rows;
    }

    private static Boolean alreadyCommitted(Id sourceId) {
        return [SELECT COUNT() FROM AAO_Claim__c WHERE AAO_Source__c = :sourceId] > 0;
    }

    // ======================================================================== status

    public static String status() {
        List<String> out = new List<String>();
        for (Opportunity o : [
            SELECT Id, Name
            FROM Opportunity
            WHERE Name IN (:OPP_MAIN, :OPP_NEGATIVE)
            ORDER BY Name
        ]) {
            out.add('--- ' + o.Name + ' (' + o.Id + ')');
            for (AAO_Answer__c a : [
                SELECT
                    Name,
                    AAO_Verdict__c,
                    AAO_Established_By__c,
                    AAO_Element_Coverage__c,
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
                    a.AAO_Element_Coverage__c
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
                ' sources=' +
                [SELECT COUNT() FROM AAO_Source__c WHERE AAO_Opportunity__c = :o.Id]
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
            out.add('sources     ' + del([SELECT Id FROM AAO_Source__c WHERE AAO_Synthetic__c = TRUE]));
            out.add('contracts   ' + del([SELECT Id FROM AAO_Evidence_Contract__c WHERE AAO_Synthetic__c = TRUE]));

            // Standard objects carry no marker field, because no field is added to a
            // standard object for a rehearsal. They are matched by name instead, which is
            // why the names are deliberately unmistakable.
            List<Opportunity> opps = [
                SELECT Id FROM Opportunity WHERE Name IN (:OPP_MAIN, :OPP_NEGATIVE)
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
