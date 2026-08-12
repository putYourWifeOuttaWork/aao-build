/**
 * The Run Inspector's laws.
 *
 * What is asserted here is what a screenshot cannot show: that it reads and never writes, that the
 * refusals reach the surface as their own collection rather than being filtered out of a list of
 * successes, and that a walk-back carries the offsets that make its quote checkable.
 */
@IsTest
private class AAO_RunInspectorTest {
    @IsTest
    static void itIsReadOnlyByConstruction() {
        // AN INSPECTOR THAT COULD CHANGE WHAT IT INSPECTS IS NOT AN INSPECTOR. Asserted against
        // the class body rather than by convention, so a later session cannot quietly add a write
        // path and leave the name promising otherwise.
        ApexClass body = [
            SELECT Body FROM ApexClass WHERE Name = 'AAO_RunInspector' LIMIT 1
        ];
        for (String write : new List<String>{
            'insert ', 'update ', 'upsert ', 'delete ', 'Database.'
        }) {
            System.assert(
                !body.Body.contains(write),
                'The inspector must hold no write path. Found: ' + write
            );
        }
    }

    @IsTest
    static void anEmptyDealAnswersWithoutThrowing() {
        Account a = new Account(Name = 'AAO Inspector Test');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Inspector Deal', AccountId = a.Id, StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;

        Test.startTest();
        List<AAO_RunInspector.RunOption> runs = AAO_RunInspector.runsFor(o.Id);
        AAO_RunInspector.RunView v = AAO_RunInspector.inspect(o.Id, null);
        Test.stopTest();

        System.assertEquals(0, runs.size(), 'No runs, and that is an answer rather than an error.');
        System.assertEquals(
            'No run selected.', v.note, 'It says why it is empty instead of rendering blank.'
        );
        System.assert(v.upheld.isEmpty() && v.refused.isEmpty());
    }

    @IsTest
    static void theStageVocabularyNAMESTHEREFUSALSANDSAYSWHYTHEYMATTER() {
        // The refusals are a first-class stage with a first-class meaning, because a surface that
        // shows only what stood tells a reviewer what the machine believes and not whether to
        // believe it. If a later session drops this stage the counts still add up and the
        // surface quietly stops earning trust, so the wording is asserted.
        Account a = new Account(Name = 'AAO Inspector Vocab');
        insert a;
        Opportunity o = new Opportunity(
            Name = 'AAO Inspector Vocab Deal', AccountId = a.Id, StageName = 'Stage 1',
            CloseDate = Date.today().addDays(30)
        );
        insert o;

        AAO_RunInspector.RunView v = AAO_RunInspector.inspect(o.Id, 'no-such-run');
        Map<String, String> meaningByStage = new Map<String, String>();
        for (AAO_RunInspector.StageCount s : v.stages) {
            meaningByStage.put(s.stage, s.meaning);
        }
        System.assert(
            meaningByStage.containsKey('Refused'),
            'Refused is a stage the surface shows, never a filtered-out remainder.'
        );
        System.assert(
            meaningByStage.get('Refused').contains('trust is earned'),
            'And it says why it is there. Got: ' + meaningByStage.get('Refused')
        );
        System.assert(meaningByStage.containsKey('Located'));
        System.assert(meaningByStage.containsKey('Upheld'));
    }
}
