/**
 * ECI viewer-paste intake, tested against lines lifted verbatim in shape from the Project
 * Farma raw (75917ba2): numbered blocks, player lines, both header orders, concatenated topic
 * tags, hh:mm:ss late timestamps, and the same-speaker merge.
 */
@IsTest
private class AAO_IntakeECITest {

    private static final String ECI =
        '1. Jennae Jizdeortega00:03\n' +
        'Product (2)\n' +
        'is to just review the business objectives you shared with me last week.\n' +
        '2. Move the player to 26.19 seconds in the call\n' +
        'Jennae Jizdeortega00:26\n' +
        'Aside from that, ask questions throughout.\n' +
        '3. Move the player to 37.31 seconds in the call\n' +
        'Lewis, Dan00:37\n' +
        'I think the main point is the mapping.\n' +
        '4. Move the player to 65.15 seconds in the call\n' +
        'Adam Pfeiffer01:05\n' +
        'AI Tools and Automation MentionedProductGo To Market Tech Stack Discussion\n' +
        'We have a diverse user group within Salesforce.\n' +
        '5. Move the player to 4305.47 seconds in the call\n' +
        'Adam Pfeiffer01:11:48\n' +
        'And a much later timestamp in the same call.';

    @IsTest
    static void headersInBothOrdersUnifyToOneKeyPerHuman() {
        AAO_IntakeECI.Result r = AAO_IntakeECI.parse(ECI);
        System.assert(r.speakerKeys.contains('Dan Lewis'),
            'Lewis, Dan unifies to Dan Lewis: ' + r.speakerKeys);
        System.assert(r.speakerKeys.contains('Adam Pfeiffer'), r.speakerKeys.toString());
        System.assert(r.speakerKeys.contains('Jennae Jizdeortega'), r.speakerKeys.toString());
    }

    @IsTest
    static void consecutiveSameSpeakerBlocksMergeAndTagsAndPlayerLinesVanish() {
        AAO_IntakeECI.Result r = AAO_IntakeECI.parse(ECI);
        List<AAO_NormalForm.Turn> turns = AAO_NormalForm.turns(r.normalizedText, 'Attributed');
        // Jennae blocks 1+2 merge; Dan; Adam blocks 4+5 merge -> three turns.
        System.assertEquals(3, turns.size(), r.normalizedText);
        System.assertEquals('Jennae Jizdeortega', turns[0].speakerKey);
        System.assert(
            turns[0].utterance.startsWith('is to just review') &&
            turns[0].utterance.endsWith('ask questions throughout.'),
            'the two Jennae blocks joined: ' + turns[0].utterance
        );
        System.assert(r.playerLinesDropped >= 3, 'player lines dropped: ' + r.playerLinesDropped);
        System.assert(r.tagLinesDropped >= 2, 'tag lines dropped: ' + r.tagLinesDropped);
    }

    @IsTest
    static void noTopicTagOrPlayerControlSurvivesIntoASpan() {
        AAO_IntakeECI.Result r = AAO_IntakeECI.parse(ECI);
        System.assert(!r.normalizedText.contains('Move the player'), r.normalizedText);
        System.assert(!r.normalizedText.contains('Go To Market Tech Stack'), r.normalizedText);
        System.assert(!r.normalizedText.contains('AI Tools and Automation'), r.normalizedText);
        // But the real word "Product" inside speech would survive; the tag line did not.
        System.assert(r.normalizedText.contains('diverse user group'), r.normalizedText);
    }

    @IsTest
    static void aTagWordInsideRealSpeechIsNotEaten() {
        String eci =
            '1. Adam Pfeiffer00:10\n' +
            'Our Product roadmap is the whole reason we are here.';
        AAO_IntakeECI.Result r = AAO_IntakeECI.parse(eci);
        System.assert(
            r.normalizedText.contains('Our Product roadmap is the whole reason we are here.'),
            'a line with residue beyond a tag is kept whole: ' + r.normalizedText
        );
    }

    @IsTest
    static void theLateHourTimestampIsRecognisedAsAHeader() {
        AAO_IntakeECI.Result r = AAO_IntakeECI.parse(ECI);
        System.assert(
            r.normalizedText.contains('And a much later timestamp in the same call.'),
            'the 01:11:48 header parsed and its utterance was kept: ' + r.normalizedText
        );
        System.assert(!r.normalizedText.contains('01:11:48'), 'the timestamp did not leak');
    }
}
