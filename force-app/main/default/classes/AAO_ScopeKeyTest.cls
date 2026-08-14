/**
 * Written before AAO_ScopeKey. The scope key is the dedup target for evidence, so a
 * defect here either re-ingests the same transcript forever or silently merges two
 * different ones.
 */
@IsTest
private class AAO_ScopeKeyTest {
    private static final String SHA =
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

    // ------------------------------------------------ two rows that should collide

    @IsTest
    static void sameScopeExpressedShortAndLongProducesOneKey() {
        Id long18 = AAO_FakeId.of(Opportunity.SObjectType);
        Id short15 = AAO_FakeId.shortForm(long18);

        System.assertEquals(
            AAO_ScopeKey.compose(long18, SHA, 1),
            AAO_ScopeKey.compose(short15, SHA, 1),
            'The same opportunity in its two Id forms is one scope. If these differ the ' +
            'same artifact ingests twice.'
        );
    }

    @IsTest
    static void sameArtifactRedeliveredComposesTheSameKey() {
        Id opp = AAO_FakeId.of(Opportunity.SObjectType);
        System.assertEquals(
            AAO_ScopeKey.compose(opp, SHA, 1),
            AAO_ScopeKey.compose(opp, SHA, 1),
            'Idempotent re-delivery depends on this being the same string.'
        );
    }

    // -------------------------------------------- rows that must not collide, do not

    @IsTest
    static void partsOfOneArtifactDoNotCollide() {
        Id opp = AAO_FakeId.of(Opportunity.SObjectType);
        System.assertNotEquals(
            AAO_ScopeKey.compose(opp, SHA, 1),
            AAO_ScopeKey.compose(opp, SHA, 2),
            'A split artifact is several Sources. Collapsing them loses evidence.'
        );
    }

    @IsTest
    static void theSameArtifactOnTwoDealsDoesNotCollide() {
        System.assertNotEquals(
            AAO_ScopeKey.compose(AAO_FakeId.of(Opportunity.SObjectType), SHA, 1),
            AAO_ScopeKey.compose(AAO_FakeId.of(Opportunity.SObjectType), SHA, 1),
            'Uniqueness is deal plus fingerprint. One call attached to two deals is two ' +
            'Sources.'
        );
    }

    @IsTest
    static void partIndexIsNotZeroPaddedIntoAmbiguity() {
        Id opp = AAO_FakeId.of(Opportunity.SObjectType);
        System.assertNotEquals(
            AAO_ScopeKey.compose(opp, SHA, 1),
            AAO_ScopeKey.compose(opp, SHA, 11)
        );
    }

    // ------------------------------------------------------ empty against a literal

    @IsTest
    static void nullScopeThrowsAndNeverRendersEmpty() {
        try {
            String k = AAO_ScopeKey.compose(null, SHA, 1);
            System.assert(
                false,
                'A null scope rendered as a key instead of throwing. It produced: "' +
                k +
                '". Every unscoped Source would then collide on one key.'
            );
        } catch (AAO_ScopeKey.KeyException e) {
            System.assert(e.getMessage().contains('scope'), e.getMessage());
        }
    }

    @IsTest
    static void nullFingerprintThrows() {
        try {
            AAO_ScopeKey.compose(AAO_FakeId.of(Opportunity.SObjectType), null, 1);
            System.assert(false, 'A Source with no fingerprint cannot be deduplicated.');
        } catch (AAO_ScopeKey.KeyException e) {
            System.assert(e.getMessage().contains('fingerprint'), e.getMessage());
        }
    }

    @IsTest
    static void nullPartIndexThrows() {
        try {
            AAO_ScopeKey.compose(AAO_FakeId.of(Opportunity.SObjectType), SHA, null);
            System.assert(false, 'Part index defaults to 1 on the field; null here is a bug.');
        } catch (AAO_ScopeKey.KeyException e) {
            System.assert(e.getMessage().contains('part index'), e.getMessage());
        }
    }

    // ------------------------------------------------------ the fingerprint itself

    /**
     * Hex case matters. If the composer accepted both cases, one artifact delivered by
     * two normalisers would produce two Sources and dedup would quietly stop working.
     * If the composer lowercased instead of rejecting, it would be a silent transform
     * on identity, which is the thing frozen composers exist to prevent.
     */
    @IsTest
    static void uppercaseFingerprintIsRejectedRatherThanFolded() {
        try {
            AAO_ScopeKey.compose(AAO_FakeId.of(Opportunity.SObjectType), SHA.toUpperCase(), 1);
            System.assert(false, 'Mixed-case fingerprints must be rejected, not folded.');
        } catch (AAO_ScopeKey.KeyException e) {
            System.assert(e.getMessage().contains('lowercase'), e.getMessage());
        }
    }

    @IsTest
    static void shortFingerprintIsRejected() {
        try {
            AAO_ScopeKey.compose(AAO_FakeId.of(Opportunity.SObjectType), 'abc123', 1);
            System.assert(false, 'A truncated fingerprint must not compose.');
        } catch (AAO_ScopeKey.KeyException e) {
            System.assert(e.getMessage().contains('64'), e.getMessage());
        }
    }

    @IsTest
    static void nonHexFingerprintIsRejected() {
        try {
            AAO_ScopeKey.compose(
                AAO_FakeId.of(Opportunity.SObjectType),
                'z3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                1
            );
            System.assert(false, 'A non-hex fingerprint must not compose.');
        } catch (AAO_ScopeKey.KeyException e) {
            System.assert(e.getMessage().contains('hex'), e.getMessage());
        }
    }

    // ------------------------------------------------------------ shape and budget

    @IsTest
    static void keyFitsTheFieldAndCarriesItsVersion() {
        String k = AAO_ScopeKey.compose(AAO_FakeId.of(Opportunity.SObjectType), SHA, 999);
        System.assert(
            k.startsWith(AAO_ScopeKey.VERSION + AAO_ScopeKey.SEP),
            'Got: ' + k
        );
        System.assert(
            k.length() <= 101,
            'AAO_Scope_Key__c is Text(101). Worst case was ' + k.length() + ': ' + k
        );
        System.assertEquals(3, k.countMatches(AAO_ScopeKey.SEP), 'Got: ' + k);
    }

    @IsTest
    static void composesFromTheRecord() {
        Id opp = AAO_FakeId.of(Opportunity.SObjectType);
        AAO_Source__c s = new AAO_Source__c(
            AAO_Opportunity__c = opp,
            AAO_Artifact_SHA256__c = SHA,
            AAO_Part_Index__c = 2
        );
        System.assertEquals(AAO_ScopeKey.compose(opp, SHA, 2), AAO_ScopeKey.compose(s));
    }
}