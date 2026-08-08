/**
 * Loads the mini-rubric and the dummy transcripts from the AAO_Seed static resource.
 *
 * Spans are authored as quotes, never as offsets, and resolved here against the composed
 * normalized text. That is deliberate: hand-written offsets would be a second account of
 * where the words are, and the first thing to rot.
 *
 * A Developer sandbox copies metadata, not data, so the org's rubric tables are empty.
 * That is the feature: day one is a per-org discovery test against a rubric that is not
 * Altify's production one.
 *
 * OWED, and it is the gap between this class and the build brief. The brief asks for
 * these propositions to be authored into the org's OWN rubric records so discovery walks
 * its real path. That needs the Altify rubric object API names, which have not been read
 * from altify--aossb2. Writing AAO_Evidence_Contract__c directly, as this does, skips
 * discovery entirely. See BUILD_JOURNAL.
 */
public class AAO_Seed {
    public class SeedException extends Exception {
    }

    public static final String RESOURCE = 'AAO_Seed';
    public static final String RUBRIC_VERSION = 'mini-0.1.0';

    /** Everything the seeder created, by the codes used in the fixture. */
    public class Loaded {
        public Map<String, Id> opportunityByDeal = new Map<String, Id>();
        public Id accountId;
        public Map<String, Contact> contactByKey = new Map<String, Contact>();
        public Map<String, AAO_Evidence_Contract__c> contractByCode =
            new Map<String, AAO_Evidence_Contract__c>();
        public Map<String, AAO_Source__c> sourceByCode = new Map<String, AAO_Source__c>();
        public Map<String, AAO_Candidate__c> candidateByCode = new Map<String, AAO_Candidate__c>();
        public Set<String> internalDomains = new Set<String>();
    }

    // ------------------------------------------------------------------ the fixture

    public static Map<String, Object> fixture() {
        List<StaticResource> rs = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :RESOURCE
            LIMIT 1
        ];
        if (rs.isEmpty()) {
            throw new SeedException(
                'The ' +
                RESOURCE +
                ' static resource is not in the org. Deploy force-app before seeding.'
            );
        }
        return (Map<String, Object>) JSON.deserializeUntyped(rs[0].Body.toString());
    }

    /**
     * The mini-rubric as contracts, found or created, keyed by proposition code. Shared by
     * the durable runner and the live pipeline so neither can seed a rubric the other
     * would not recognise.
     *
     * Found by question record id at this rubric version. Re-running creates nothing: the
     * contract key is unique, and a contract is per proposition per version of its text.
     */
    public static Map<String, AAO_Evidence_Contract__c> ensureContracts(
        Map<String, Object> fixture
    ) {
        return ensureContracts(fixture, true);
    }

    /**
     * `synthetic` decides which population these contracts join. True is the seeder's
     * default and what the rehearsal uses: marked rows, invisible to the product path.
     *
     * False exists for tests that exercise the PRODUCT path, which by session 17's rule
     * reads unmarked contracts only. Such a test is not opting out of the marker law, it
     * is declaring that the rubric it is standing up is the org's questions rather than a
     * rehearsal fixture. The contract key is unique, so the same proposition cannot exist
     * in both populations at once and the choice has to be made once, here.
     */
    public static Map<String, AAO_Evidence_Contract__c> ensureContracts(
        Map<String, Object> fixture,
        Boolean synthetic
    ) {
        Map<String, AAO_Evidence_Contract__c> byCode =
            new Map<String, AAO_Evidence_Contract__c>();
        for (AAO_Evidence_Contract__c ec : [
            SELECT Id, AAO_Question_Record_Id__c
            FROM AAO_Evidence_Contract__c
            WHERE AAO_Rubric_Version__c = :RUBRIC_VERSION
        ]) {
            byCode.put(ec.AAO_Question_Record_Id__c, ec);
        }

        List<AAO_Evidence_Contract__c> toCreate = new List<AAO_Evidence_Contract__c>();
        List<String> newCodes = new List<String>();
        for (Object o : (List<Object>) fixture.get('rubric')) {
            Map<String, Object> q = (Map<String, Object>) o;
            String code = (String) q.get('code');
            if (byCode.containsKey(code)) {
                continue;
            }
            List<Object> elements = (List<Object>) q.get('elements');
            newCodes.add(code);
            toCreate.add(
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
                    AAO_Rubric_Version__c = RUBRIC_VERSION
                )
            );
        }
        if (!toCreate.isEmpty()) {
            // Ruled session 15. Seeder-created rows are synthetic by the standing law, and
            // this is the seeder. It used to inherit whatever MARK happened to be set,
            // which meant a contract's marker depended on which entry created it: marked
            // from the demo path, unmarked from AAO_Seed.load. With a delete law on the
            // object that inconsistency decided whether the purge could remove a row.
            Boolean priorMark = AAO_Synthetic.MARK;
            AAO_Synthetic.MARK = synthetic == true;
            try {
                insert toCreate;
            } finally {
                AAO_Synthetic.MARK = priorMark;
            }
            for (Integer i = 0; i < newCodes.size(); i++) {
                byCode.put(newCodes[i], toCreate[i]);
            }
        }
        return byCode;
    }

    // --------------------------------------------------------------------- loading

    /**
     * Stages fixtures. It does not adjudicate them.
     *
     * Auto-ingest is off for the whole of this method, and that is not a convenience. The
     * after-insert trigger on AAO_Source__c means any transaction that inserts a Source now
     * enqueues adjudication for it, and a fixture loader inserting four transcripts would
     * silently commit all four at Test.stopTest -- on deals the calling test never asked
     * about. Tests drive the pipeline explicitly; AAO_LiveIngestTest turns AUTO back on
     * where the async path is the thing under test.
     */
    public static Loaded load() {
        Boolean priorAuto = AAO_Ingest.AUTO;
        AAO_Ingest.AUTO = false;
        try {
            return loadStaged();
        } finally {
            AAO_Ingest.AUTO = priorAuto;
        }
    }

    private static Loaded loadStaged() {
        Map<String, Object> f = fixture();
        Loaded out = new Loaded();

        for (Object d : (List<Object>) f.get('internalDomains')) {
            out.internalDomains.add(((String) d).toLowerCase());
        }

        // ---- the customer, and the three deals the fixtures need kept apart
        Account acct = new Account(Name = 'Northwind Traders (AAO sandbox)');
        insert acct;
        out.accountId = acct.Id;

        // Three deals, so the negative case and the unsegmented case cannot pollute the
        // accumulation the exit test asserts on. Ordered explicitly rather than by map
        // iteration, because the two loops have to agree and a map does not promise that.
        List<String> deals = new List<String>{ 'main', 'negative', 'unsegmented' };
        Map<String, String> dealNames = new Map<String, String>{
            'main' => 'Northwind - Operations Modernisation',
            'negative' => 'Northwind - Operations Modernisation (wrong speaker)',
            'unsegmented' => 'Northwind - Operations Modernisation (unsegmented)'
        };
        List<Opportunity> opps = new List<Opportunity>();
        for (String deal : deals) {
            opps.add(
                new Opportunity(
                    Name = dealNames.get(deal),
                    AccountId = acct.Id,
                    StageName = defaultStage(),
                    CloseDate = Date.newInstance(2026, 12, 31)
                )
            );
        }
        insert opps;
        for (Integer i = 0; i < deals.size(); i++) {
            out.opportunityByDeal.put(deals[i], opps[i].Id);
        }

        // ---- the roster, as contacts
        List<Object> people = (List<Object>) f.get('people');
        List<Contact> contacts = new List<Contact>();
        for (Object o : people) {
            Map<String, Object> p = (Map<String, Object>) o;
            String display = (String) p.get('display');
            contacts.add(
                new Contact(
                    FirstName = display.substringBefore(' '),
                    LastName = display.substringAfter(' '),
                    Email = (String) p.get('email'),
                    Title = (String) p.get('title'),
                    AccountId = acct.Id
                )
            );
        }
        insert contacts;
        for (Integer k = 0; k < people.size(); k++) {
            out.contactByKey.put(
                (String) ((Map<String, Object>) people[k]).get('key'),
                contacts[k]
            );
        }

        // ---- the mini-rubric
        List<AAO_Evidence_Contract__c> contracts = new List<AAO_Evidence_Contract__c>();
        List<String> codes = new List<String>();
        for (Object o : (List<Object>) f.get('rubric')) {
            Map<String, Object> q = (Map<String, Object>) o;
            String code = (String) q.get('code');
            codes.add(code);
            List<Object> elements = (List<Object>) q.get('elements');
            contracts.add(
                new AAO_Evidence_Contract__c(
                    // In production this is the rubric question's own record id. Here it
                    // is the fixture code, padded, because there is no rubric record to
                    // point at until discovery runs against the org.
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
                    AAO_Rubric_Version__c = RUBRIC_VERSION
                )
            );
        }
        insert contracts;
        for (Integer k = 0; k < codes.size(); k++) {
            out.contractByCode.put(codes[k], contracts[k]);
        }

        // ---- the sources
        String rosterJson = rosterFor(people, out.contactByKey, out.internalDomains);
        List<AAO_Source__c> sources = new List<AAO_Source__c>();
        List<String> sourceCodes = new List<String>();
        for (Object o : (List<Object>) f.get('sources')) {
            Map<String, Object> s = (Map<String, Object>) o;
            sourceCodes.add((String) s.get('code'));
            String text = normalizedTextFor(s);
            Id oppId = out.opportunityByDeal.get((String) s.get('deal'));
            sources.add(
                new AAO_Source__c(
                    AAO_Opportunity__c = oppId,
                    AAO_Account__c = acct.Id,
                    AAO_Normalized_Text__c = text,
                    AAO_Diarization__c = (String) s.get('diarization'),
                    AAO_Speaker_Roster__c = s.get('diarization') == 'Unsegmented'
                        ? null
                        : rosterJson,
                    AAO_SHA256__c = AAO_NormalForm.sha256(text),
                    // The artifact hash is over the artifact. It used to be over
                    // sourceRef, the path label, which made two different transcripts
                    // delivered under one filename look like the same evidence arriving
                    // twice, and made one transcript delivered under two filenames look
                    // like two pieces of evidence. See session 11.
                    AAO_Artifact_SHA256__c = artifactSha(s),
                    AAO_Part_Index__c = 1,
                    AAO_Part_Count__c = 1,
                    AAO_Source_Ref__c = (String) s.get('sourceRef'),
                    AAO_Origin__c = (String) s.get('origin'),
                    AAO_Evidence_Occurred__c = gmt((String) s.get('occurred')),
                    AAO_Duration_Seconds__c = (Integer) s.get('durationSeconds')
                )
            );
        }
        insert sources;
        for (Integer k = 0; k < sourceCodes.size(); k++) {
            out.sourceByCode.put(sourceCodes[k], sources[k]);
        }

        // ---- the candidates, with quotes resolved to offsets
        Map<Id, AAO_Source__c> sourceById = new Map<Id, AAO_Source__c>(sources);
        List<AAO_Candidate__c> candidates = new List<AAO_Candidate__c>();
        List<String> candCodes = new List<String>();
        for (Object o : (List<Object>) f.get('candidates')) {
            Map<String, Object> c = (Map<String, Object>) o;
            candCodes.add((String) c.get('code'));
            Id oppId = out.opportunityByDeal.get((String) c.get('deal'));

            List<AAO_Model.Span> spans = new List<AAO_Model.Span>();
            for (Object so : (List<Object>) c.get('spans')) {
                Map<String, Object> sp = (Map<String, Object>) so;
                AAO_Source__c src = out.sourceByCode.get((String) sp.get('sourceCode'));
                spans.add(
                    resolve(
                        src,
                        (String) sp.get('quote'),
                        (String) sp.get('speaker'),
                        (String) sp.get('element')
                    )
                );
            }

            candidates.add(
                new AAO_Candidate__c(
                    AAO_Evidence_Contract__c = out.contractByCode
                        .get((String) c.get('contractCode'))
                        .Id,
                    AAO_Source__c = out.sourceByCode.get((String) c.get('sourceCode')).Id,
                    AAO_Basis__c = AAO_EvidenceFamily.TRANSCRIPT,
                    AAO_Opportunity__c = oppId,
                    AAO_Account__c = acct.Id,
                    AAO_Subject_Type__c = (String) c.get('subjectType'),
                    AAO_Proposed_Verdict__c = (String) c.get('proposedVerdict'),
                    AAO_Spans__c = AAO_Model.serializeSpans(spans),
                    AAO_Element_Coverage__c = AAO_Model.serializeCoverage(
                        AAO_Model.newCoverage(
                            strings((List<Object>) c.get('covered')),
                            strings((List<Object>) c.get('missing'))
                        )
                    ),
                    AAO_Stage__c = 'Adjudicated',
                    AAO_Outcome__c = 'Pending',
                    AAO_Charter__c = (String) c.get('charter'),
                    AAO_Charter_Version__c = (String) c.get('charterVersion'),
                    AAO_Publication_State__c = 'Live'
                )
            );
        }
        insert candidates;
        for (Integer k = 0; k < candCodes.size(); k++) {
            out.candidateByCode.put(candCodes[k], candidates[k]);
        }

        return out;
    }

    /**
     * The complete ledger. Every proposition considered on a pass writes a row,
     * including the ones nothing was said about, so the abstention rate is a direct
     * query and "did it even look" is answerable.
     *
     * Called once per pass, after the candidates that did propose something.
     */
    public static List<AAO_Candidate__c> logAbstentions(
        Loaded loaded,
        String deal,
        String sourceCode,
        String charter,
        String charterVersion
    ) {
        Id oppId = loaded.opportunityByDeal.get(deal);
        AAO_Source__c src = loaded.sourceByCode.get(sourceCode);

        Set<Id> proposedFor = new Set<Id>();
        for (AAO_Candidate__c c : [
            SELECT AAO_Evidence_Contract__c
            FROM AAO_Candidate__c
            WHERE AAO_Source__c = :src.Id
        ]) {
            proposedFor.add(c.AAO_Evidence_Contract__c);
        }

        List<AAO_Candidate__c> rows = new List<AAO_Candidate__c>();
        for (AAO_Evidence_Contract__c ec : loaded.contractByCode.values()) {
            if (proposedFor.contains(ec.Id)) {
                continue;
            }
            rows.add(
                new AAO_Candidate__c(
                    AAO_Evidence_Contract__c = ec.Id,
                    AAO_Source__c = src.Id,
                    AAO_Basis__c = AAO_EvidenceFamily.TRANSCRIPT,
                    AAO_Opportunity__c = oppId,
                    AAO_Account__c = loaded.accountId,
                    AAO_Subject_Type__c = 'Opportunity',
                    AAO_Proposed_Verdict__c = null,
                    AAO_Stage__c = 'Adjudicated',
                    AAO_Outcome__c = 'Abstained',
                    AAO_Abstention_Reason__c = 'nobody_said',
                    AAO_Charter__c = charter,
                    AAO_Charter_Version__c = charterVersion,
                    AAO_Publication_State__c = 'Live'
                )
            );
        }
        insert rows;
        return rows;
    }

    // ------------------------------------------------------------------- internals

    /** "2026-06-15T15:00:00Z" as a GMT datetime, without relying on JSON coercion. */
    public static Datetime gmt(String iso8601) {
        return Datetime.valueOfGmt(iso8601.replace('T', ' ').removeEnd('Z'));
    }

    /**
     * The first available Opportunity stage. Read from the org rather than assumed:
     * stage picklists are customer data and "Qualification" is a default, not a promise.
     */
    public static String defaultStage() {
        for (Schema.PicklistEntry e : Opportunity.StageName.getDescribe().getPicklistValues()) {
            if (e.isActive()) {
                return e.getValue();
            }
        }
        throw new SeedException('The Opportunity stage picklist has no active values.');
    }

    public static List<String> strings(List<Object> raw) {
        List<String> out = new List<String>();
        if (raw == null) {
            return out;
        }
        for (Object o : raw) {
            out.add((String) o);
        }
        return out;
    }

    /**
     * The identity of a piece of evidence is its content. In this build the delivered
     * artifact and the stored normalized text are the same string, because the fixture
     * hands us turns rather than a file, so this equals AAO_SHA256__c. When a real
     * connector lands they diverge: artifact hash is what arrived, AAO_SHA256__c is what
     * we stored after normalising. Keeping both named separately now is what makes that
     * divergence a change of one line rather than a change of meaning.
     */
    public static String artifactSha(Map<String, Object> s) {
        return AAO_NormalForm.sha256(normalizedTextFor(s));
    }

    public static String normalizedTextFor(Map<String, Object> s) {
        if (s.get('diarization') == 'Unsegmented') {
            return (String) s.get('unsegmentedText');
        }
        List<String> keys = new List<String>();
        List<String> utterances = new List<String>();
        for (Object o : (List<Object>) s.get('turns')) {
            Map<String, Object> t = (Map<String, Object>) o;
            keys.add((String) t.get('speaker'));
            utterances.add((String) t.get('text'));
        }
        return AAO_NormalForm.compose(keys, utterances);
    }

    public static String rosterFor(
        List<Object> people,
        Map<String, Contact> contactByKey,
        Set<String> internalDomains
    ) {
        List<AAO_Model.Speaker> speakers = new List<AAO_Model.Speaker>();
        for (Object o : people) {
            Map<String, Object> p = (Map<String, Object>) o;
            AAO_Model.Speaker sp = new AAO_Model.Speaker();
            sp.key = (String) p.get('key');
            sp.display = (String) p.get('display');
            sp.email = (String) p.get('email');
            sp.mapRole = (String) p.get('mapRole');
            Contact c = contactByKey.get(sp.key);
            sp.contactId = c == null ? null : String.valueOf(c.Id);
            // An internal participant is a User. In the sandbox that is whoever is running
            // this, which is what makes key four exercised rather than dead.
            String d = sp.domain();
            if (d != null && internalDomains != null && internalDomains.contains(d)) {
                sp.userId = UserInfo.getUserId();
            }
            speakers.add(sp);
        }
        AAO_Model.Roster r = new AAO_Model.Roster();
        r.v = AAO_Model.ROSTER_V;
        r.speakers = speakers;
        return JSON.serialize(r);
    }

    /**
     * Find the quote in the source's own normalized text and record where it is. If the
     * quote is not there, or is there more than once, that is a defect in the fixture and
     * it says so rather than picking one.
     */
    public static AAO_Model.Span resolve(
        AAO_Source__c src,
        String quote,
        String speaker,
        String element
    ) {
        String text = src.AAO_Normalized_Text__c;
        Integer at = text.indexOf(quote);
        if (at < 0) {
            throw new SeedException(
                'The fixture quotes "' +
                quote +
                '" but it does not occur in ' +
                src.AAO_Source_Ref__c +
                '. Ground truth by construction only works if the construction is right.'
            );
        }
        if (text.indexOf(quote, at + 1) >= 0) {
            throw new SeedException(
                'The fixture quote "' +
                quote +
                '" occurs more than once in ' +
                src.AAO_Source_Ref__c +
                ', so which one it means is a guess. Lengthen the quote.'
            );
        }
        AAO_Model.Span sp = new AAO_Model.Span();
        sp.sourceId = String.valueOf(src.Id);
        sp.partIndex = 1;
        sp.startOffset = at;
        sp.endOffset = at + quote.length();
        sp.quote = quote;
        sp.speaker = speaker;
        sp.element = element;
        return sp;
    }
}
