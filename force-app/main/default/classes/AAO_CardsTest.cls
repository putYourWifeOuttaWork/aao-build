/**
 * The card writer's pure functions, held as pure functions.
 *
 * The board-writing legs are exercised in-org against the real harvest; what is asserted here is
 * the arithmetic and the naming, which are the parts a rerun cannot show you went wrong quietly.
 */
@IsTest
private class AAO_CardsTest {
    // =============================================== the section title, fifty-seventh stamp 2

    private static AAO_Source__c src(String meetingTitle) {
        return new AAO_Source__c(
            AAO_Evidence_Occurred__c = Datetime.newInstanceGmt(2026, 7, 30, 15, 0, 0),
            AAO_Meeting_Title__c = meetingTitle
        );
    }

    @IsTest
    static void theMeetingTitleFromTheSourceSystemTitlesTheSection() {
        // MATTHEW'S RULING: the call type comes from the meeting title the source system already
        // recorded, never from a model reading the transcript. A column heading on a customer's
        // board is the last place to put an inference.
        System.assertEquals(
            '30 July 2026: Weekly Sync',
            AAO_Cards.sectionTitle(src('Weekly Sync'), null),
            'Date, colon, the title as the source system wrote it.'
        );
    }

    @IsTest
    static void noMeetingTitleFallsBackToTheDateAndThatIsHonestRatherThanAShortfall() {
        // A hand-carried paste carries no metadata. Project Farma is exactly this case, which is
        // why its section reads "30 July 2026" until a connector supplies a title.
        System.assertEquals(
            '30 July 2026',
            AAO_Cards.sectionTitle(src(null), null),
            'The ruled fallback. Inventing "Discovery Call" here would be a guess on a heading.'
        );
        System.assertEquals('30 July 2026', AAO_Cards.sectionTitle(src('   '), null));
    }

    @IsTest
    static void anExplicitCallTypeStillWinsSoAMigrationCanNameItsOwnSection() {
        System.assertEquals(
            '30 July 2026: Discovery Call',
            AAO_Cards.sectionTitle(src('Weekly Sync'), 'Discovery Call')
        );
    }

    @IsTest
    static void anUndatedSourceSaysSoRatherThanTitlingItselfNothing() {
        System.assertEquals(
            'Undated call',
            AAO_Cards.sectionTitle(new AAO_Source__c(), null)
        );
    }

    // ============================== the two layers, sixty-first stamp: identity beneath meaning

    @IsTest
    static void theSAMEEVIDENCEISTHESAMECARDHOWEVERTHEFACEISREWORDED() {
        // THE TEST THAT WOULD HAVE CAUGHT THE INFLATION. The face is a fresh model call every
        // run, so keying identity on it made a reworded face read as a new insight: 12 cards
        // became 14 from a harvest with nothing new established. Identity is the EVIDENCE.
        String words = 'I\'d say our key pressures are, well, number one, like resourcing';
        System.assertEquals(
            AAO_Cards.evidenceKey('Pressure', words),
            AAO_Cards.evidenceKey('Pressure', words),
            'Same words, same key, forever.'
        );
        // Two runs, two different faces, one piece of evidence: still one card.
        System.assertNotEquals(
            AAO_Cards.meaningKey('Pressure', 'Resourcing pressure (non-sales driven)'),
            AAO_Cards.meaningKey('Pressure', 'Resourcing pressure outside sales'),
            'The FACES differ, which is exactly what fooled the old single-layer key...'
        );
        System.assertEquals(
            AAO_Cards.evidenceKey('Pressure', words),
            AAO_Cards.evidenceKey('Pressure', words.toUpperCase()),
            '...and the evidence key is unmoved by it.'
        );
    }

    @IsTest
    static void layerTwoSURVIVESSoARestatementIsStillReinforcementNotADuplicate() {
        // The meaning layer is NOT replaced by identity. A later call restating the same problem
        // in new words is DIFFERENT evidence, and the ruled behaviour is reinforcement. A
        // byte-only key would silently retire that and duplicate every restatement.
        System.assertNotEquals(
            AAO_Cards.evidenceKey('Obstacle', 'we operate in silos'),
            AAO_Cards.evidenceKey('Obstacle', 'the teams are siloed from each other'),
            'Different words are different evidence, so identity cannot see them as one...'
        );
        System.assertEquals(
            AAO_Cards.meaningKey('Obstacle', 'Silos across the org'),
            AAO_Cards.meaningKey('Obstacle', 'silos  across   the ORG'),
            '...and the meaning layer is what catches the restatement.'
        );
    }

    @IsTest
    static void aCardWithNoMarkerIsNOTOURSAndIsNeverIdentifiedOrCollapsed() {
        // A human-authored card carries no "In their words" layer, so it yields no evidence key
        // and the collapse cannot reach it. Human cards are never touched.
        System.assertEquals(null, AAO_Cards.verbatimOf('A card someone typed by hand.'));
        System.assertEquals(null, AAO_Cards.verbatimOf(null));
        System.assertEquals(
            'we tend to operate in silos',
            AAO_Cards.verbatimOf(
                'They work in isolation.\n\nSource: Adam, 30 July 2026.\n\n' +
                'In their words: "we tend to operate in silos"'
            ),
            'And ours round-trips, which is what makes identity readable off a standing card.'
        );
    }

    // ======================================================= the grid, fifty-third stamp math

    @IsTest
    static void cardsGoThreeAcrossThenWrap() {
        // Matthew's math, from his read of the rendered board. Five obstacles are three wide
        // then two wide, which is what puts them above the fold.
        List<String> laid = new List<String>();
        for (Integer n = 1; n <= 5; n++) {
            laid.add('(' + AAO_Cards.gridX(n) + ',' + AAO_Cards.gridY(n) + ')');
        }
        System.assertEquals(
            '(1,1) (2,1) (3,1) (1,2) (2,2)',
            String.join(laid, ' '),
            'Three across, then the next line down within the same type row.'
        );
    }

    @IsTest
    static void theMeaningKeyNormalisesCaseAndSpacingAndNothingElse() {
        // "Completely different language is a different insight" was ruled, so this must NOT
        // try to detect paraphrase: a writer guessing at sameness silently merges two things a
        // person said.
        System.assertEquals(
            AAO_Cards.meaningKey('Goal', 'Standardize  via SALESFORCE'),
            AAO_Cards.meaningKey('Goal', 'standardize via salesforce')
        );
        System.assertNotEquals(
            AAO_Cards.meaningKey('Goal', 'Standardize via Salesforce'),
            AAO_Cards.meaningKey('Obstacle', 'Standardize via Salesforce'),
            'Same words under a different type are a different insight.'
        );
        System.assertNotEquals(
            AAO_Cards.meaningKey('Goal', 'Standardize via Salesforce'),
            AAO_Cards.meaningKey('Goal', 'Consolidate onto one platform'),
            'And paraphrase is deliberately NOT collapsed.'
        );
    }
}
