/**
 * Call 2's envelope law, asserted on the SHAPE rather than on the prose that used to ask for it.
 *
 * The law is old (§P8.2: exactly one disposition per handed pair). What is new, and what these
 * tests exist to keep, is that the schema now makes a short return INEXPRESSIBLE instead of
 * merely forbidden. On 13 August the array shape returned one disposition for sixty-seven pairs
 * and the prose in its description did nothing to stop it, so the distinction is not academic.
 */
@IsTest
private class AAO_IdentifyCharterTest {
    private static List<String> refs() {
        return new List<String>{ 'r1q1', 'r1q2', 'r2q7' };
    }

    private static List<String> handles() {
        return new List<String>{ 'Adam Pfeiffer', 'Dan Lewis' };
    }

    @IsTest
    static void theSCHEMAISKEYEDANDEVERYHANDEDREFISREQUIRED() {
        // THE WHOLE POINT. One property per ref, every ref in `required`, and nothing else
        // permitted. A model cannot omit one, cannot repeat one, and cannot invent one, because
        // none of those are shapes this object can take.
        Map<String, Object> s = AAO_IdentifyCharter.schema(refs(), handles());

        Map<String, Object> props = (Map<String, Object>) s.get('properties');
        System.assertEquals(
            new Set<String>(refs()), props.keySet(),
            'One property per handed ref, keyed by the ref itself.'
        );
        System.assertEquals(
            new Set<String>(refs()), new Set<String>((List<String>) s.get('required')),
            'EVERY ref is required. This is the line that makes a short return impossible.'
        );
        System.assertEquals(
            false, s.get('additionalProperties'),
            'And a ref we never handed cannot be returned at all.'
        );
    }

    @IsTest
    static void theSCHEMAISNOTANARRAYANYMORE() {
        // Asserted as its own law because reverting is a one-line temptation: an array reads
        // more naturally and is what most schemas look like. The array shape is precisely what
        // failed, and prose in a description is a request rather than a constraint.
        String json = JSON.serialize(AAO_IdentifyCharter.schema(refs(), handles()));
        System.assert(
            !json.contains('"dispositions"'),
            'The array envelope is gone. Got: ' + json.abbreviate(300)
        );
        System.assert(
            !json.contains('"array"'),
            'No array anywhere: the count cannot be requested, only guaranteed.'
        );
    }

    @IsTest
    static void everyPERSONVALUEISCLOSEDANDCARRIESNONEANDAMBIGUOUS() {
        Map<String, Object> s = AAO_IdentifyCharter.schema(refs(), handles());
        Map<String, Object> props = (Map<String, Object>) s.get('properties');
        Map<String, Object> one = (Map<String, Object>) props.get('r1q1');
        Map<String, Object> oneProps = (Map<String, Object>) one.get('properties');
        Map<String, Object> person = (Map<String, Object>) oneProps.get('person');
        Set<String> allowed = new Set<String>((List<String>) person.get('enum'));

        System.assert(allowed.contains('Adam Pfeiffer') && allowed.contains('Dan Lewis'));
        System.assert(
            allowed.contains(AAO_IdentifyCharter.NONE) &&
            allowed.contains(AAO_IdentifyCharter.AMBIGUOUS),
            'NONE and AMBIGUOUS are answers, not absences, so they live in the closed list.'
        );
        System.assertEquals(
            4, allowed.size(), 'The list is CLOSED. Nothing else is sayable. Got: ' + allowed
        );
        System.assertEquals(
            new Set<String>{ 'person', 'basis' },
            new Set<String>((List<String>) one.get('required')),
            'A disposition without its basis is a verdict with no reason.'
        );
    }

    @IsTest
    static void theKEYEDRESPONSEPARSESINTHEORDERWEASKEDIN() {
        // A JSON object carries no key order and nothing downstream needs one (AAO_Pass consumes
        // dispositions through a map keyed by ref). The parse still returns them in the handed
        // order so a run report reads the way the call was made.
        String raw = '{"r2q7":{"person":"Dan Lewis","basis":"c"},' +
            '"r1q1":{"person":"Adam Pfeiffer","basis":"a"},' +
            '"r1q2":{"person":"NONE","basis":"b"}}';

        List<AAO_IdentifyCharter.Disposition> out = AAO_IdentifyCharter.parse(raw, refs());

        System.assertEquals(3, out.size());
        System.assertEquals('r1q1', out[0].pairRef, 'Handed order, not returned order.');
        System.assertEquals('r1q2', out[1].pairRef);
        System.assertEquals('r2q7', out[2].pairRef);
        System.assertEquals('Adam Pfeiffer', out[0].person);
        System.assertEquals('NONE', out[1].person);
    }

    @IsTest
    static void aSHORTRETURNSTILLTHROWSEVENTHOUGHTHESCHEMAFORBIDSIT() {
        // THE GUARD IS NOT MADE REDUNDANT BY THE SCHEMA. The schema is the gateway's promise;
        // this is our own check of it, and the day a promise stops being kept is exactly the day
        // nobody is watching. This guard is what caught the array shape failing on 13 August.
        String raw = '{"r1q1":{"person":"Adam Pfeiffer","basis":"a"}}';
        try {
            AAO_IdentifyCharter.parse(raw, refs());
            System.assert(false, 'A short return must throw, schema or no schema.');
        } catch (AAO_IdentifyCharter.CharterException e) {
            System.assert(
                e.getMessage().contains('handed 3 pairs and disposed 1'),
                'And it names what is missing. Got: ' + e.getMessage()
            );
            System.assert(e.getMessage().contains('r1q2') && e.getMessage().contains('r2q7'));
        }
    }

    @IsTest
    static void aREFWENEVERHANDEDISOURBUGANDTHROWS() {
        String raw = '{"r1q1":{"person":"Adam Pfeiffer","basis":"a"},' +
            '"r1q2":{"person":"NONE","basis":"b"},' +
            '"r2q7":{"person":"NONE","basis":"c"},' +
            '"r9q9":{"person":"NONE","basis":"d"}}';
        try {
            AAO_IdentifyCharter.parse(raw, refs());
            System.assert(false, 'A ref we never handed must throw.');
        } catch (AAO_IdentifyCharter.CharterException e) {
            System.assert(
                e.getMessage().contains('r9q9') && e.getMessage().contains('our bug'),
                'Named as OURS, per the parse law. Got: ' + e.getMessage()
            );
        }
    }

    @IsTest
    static void nonJsonIsNamedRatherThanSwallowed() {
        try {
            AAO_IdentifyCharter.parse('not json at all', refs());
            System.assert(false, 'Unparseable output must throw.');
        } catch (AAO_IdentifyCharter.CharterException e) {
            System.assert(e.getMessage().contains('not JSON'), e.getMessage());
        }
    }
}