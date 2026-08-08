/**
 * WebVTT intake, tested against a synthesized file matching the format the twentieth stamp
 * describes: voice tags, cue timestamps, same-speaker cue merging, a NOTE roster.
 *
 * The synthesized file is not the WF fixture and is not claimed to be. It exercises every
 * format rule the parser makes so that when the real bytes arrive the only unknown is the
 * roster's exact line shape, which the parser reports rather than guesses.
 */
@IsTest
private class AAO_IntakeVTTTest {

    private static final String VTT =
        'WEBVTT\n' +
        '\n' +
        'NOTE\n' +
        'Katherine Villanueva <katherine.villanueva@cib.wellsfargo.com> | Managing Director\n' +
        'Dana Ortiz <dana.ortiz@opentext.com> | Account Executive\n' +
        '\n' +
        'NOTE This is a non-roster note and must be ignored.\n' +
        '\n' +
        '1\n' +
        '00:00:00.000 --> 00:00:04.000\n' +
        '<v Katherine Villanueva>Welcome everyone to the pilot review.\n' +
        '\n' +
        '2\n' +
        '00:00:04.000 --> 00:00:08.000\n' +
        '<v Katherine Villanueva>Let us start with the governance question.\n' +
        '\n' +
        '00:00:08.000 --> 00:00:12.500\n' +
        '<v.loud Dana Ortiz>Happy to take that one.\n' +
        '\n' +
        '00:00:12.500 --> 00:00:16.000\n' +
        '<v Dana Ortiz>The model risk review <i>is</i> already scheduled.';

    @IsTest
    static void consecutiveSameSpeakerCuesMergeIntoOneTurn() {
        AAO_IntakeVTT.Result r = AAO_IntakeVTT.parse(VTT);

        // Four cues, but Katherine's two merge and Dana's two merge: two turns.
        System.assertEquals(4, r.cueCount, 'four cues read');
        System.assertEquals(2, r.turnCount, 'merged to two turns: ' + r.normalizedText);

        List<AAO_NormalForm.Turn> turns = AAO_NormalForm.turns(r.normalizedText, 'Attributed');
        System.assertEquals(2, turns.size(), r.normalizedText);
        System.assertEquals('Katherine Villanueva', turns[0].speakerKey);
        System.assertEquals(
            'Welcome everyone to the pilot review. Let us start with the governance question.',
            turns[0].utterance,
            'the two Katherine cues joined with a single space'
        );
        System.assertEquals('Dana Ortiz', turns[1].speakerKey,
            'the .loud class does not change the name');
    }

    @IsTest
    static void everyTagIsStrippedFromTheUtterance() {
        AAO_IntakeVTT.Result r = AAO_IntakeVTT.parse(VTT);
        System.assert(
            !r.normalizedText.contains('<'),
            'no markup survives into a span: ' + r.normalizedText
        );
        System.assert(
            r.normalizedText.contains('The model risk review is already scheduled'),
            'the <i> tag is removed and the words close up: ' + r.normalizedText
        );
    }

    @IsTest
    static void theComposedTextIsAValidNf1BodyWithNoTrailingNewline() {
        AAO_IntakeVTT.Result r = AAO_IntakeVTT.parse(VTT);
        System.assert(!r.normalizedText.endsWith('\n'), 'NF1 carries no trailing newline');
        // Every span offset must land inside exactly one utterance region.
        Integer at = r.normalizedText.indexOf('governance');
        AAO_NormalForm.Turn t = AAO_NormalForm.containing(
            AAO_NormalForm.turns(r.normalizedText, 'Attributed'), at, at + 'governance'.length()
        );
        System.assertNotEquals(null, t, 'the word sits inside a turn, not across the tab or newline');
    }

    @IsTest
    static void theRosterReadsBothColumnsAndTheSellerDomain() {
        Map<String, AAO_IntakeVTT.RosterEntry> roster = AAO_IntakeVTT.roster(VTT);
        System.assertEquals(2, roster.size(), 'the real NOTE roster, not the prose NOTE');
        System.assertEquals(
            'katherine.villanueva@cib.wellsfargo.com',
            roster.get('Katherine Villanueva').email
        );
        System.assertEquals(
            'dana.ortiz@opentext.com',
            roster.get('Dana Ortiz').email,
            'the seller side is opentext.com, which the internal-domain list now classifies'
        );
        System.assertEquals('Managing Director', roster.get('Katherine Villanueva').title);
    }

    @IsTest
    static void nonWebVttInputIsRefusedRatherThanGuessed() {
        try {
            AAO_IntakeVTT.parse('Speaker\tsome plain text that is not vtt');
            System.assert(false, 'must refuse a non-WebVTT stream');
        } catch (AAO_IntakeVTT.IntakeException e) {
            System.assert(e.getMessage().contains('WEBVTT'), e.getMessage());
        }
    }

    @IsTest
    static void aCueWithNoVoiceTagInheritsTheRunningSpeaker() {
        String vtt =
            'WEBVTT\n\n' +
            '00:00:00.000 --> 00:00:03.000\n' +
            '<v Alison Reyes>First line here.\n' +
            'and a wrapped second line with no tag.';
        AAO_IntakeVTT.Result r = AAO_IntakeVTT.parse(vtt);
        List<AAO_NormalForm.Turn> turns = AAO_NormalForm.turns(r.normalizedText, 'Attributed');
        System.assertEquals(1, turns.size());
        System.assertEquals(
            'First line here. and a wrapped second line with no tag.',
            turns[0].utterance
        );
    }
}
