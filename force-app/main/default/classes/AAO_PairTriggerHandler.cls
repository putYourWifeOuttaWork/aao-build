/**
 * The pair ledger's laws: the two shapes, the prohibition law made physical, and the
 * delete law.
 *
 * The ledger is two rows per pair on purpose, so every stage is measurable on its own.
 * That only holds if the two rows stay two SHAPES: a located row carries the words and no
 * person, an identified row carries the person and no words. The moment one row can carry
 * both, "pairs located" and "pairs identified" stop being separable counts and the reason
 * for the second row is gone.
 *
 * THE PROHIBITION LAW IS THE ONE THAT MATTERS. Call 1 never names a person. That is a
 * charter instruction to a model, and a charter instruction is a request. Here it is a
 * field the database will not let call 1 populate, which is the same move as putting the
 * stage in an explicit picklist rather than inferring it: cheap now, unpayable later.
 */
public class AAO_PairTriggerHandler {
    /**
     * Everything call 1 writes and call 2 must not, and the reverse. Enforced both ways,
     * because a rule enforced in one direction is a rule that gets around itself.
     */
    private static final Map<String, String> LOCATED_ONLY = new Map<String, String>{
        'AAO_Answer_Text__c' => 'the verbatim words',
        'AAO_Meaning__c' => 'the meaning those words voice',
        'AAO_Coverage__c' => 'full or partial coverage',
        'AAO_Criterion_Name__c' => 'the criterion\'s name',
        'AAO_About_Designator__c' => 'the designator of who the words are about',
        'AAO_About_Quote__c' => 'the designator\'s introducing quote',
        'AAO_Occurrence__c' => 'which occurrence the words are',
        'AAO_Occurrence_Count__c' => 'how many occurrences there were',
        'AAO_Start_Offset__c' => 'the start offset',
        'AAO_End_Offset__c' => 'the end offset',
        'AAO_Speaker_Key__c' => 'whose turn the words lie in'
    };

    private static final Map<String, String> IDENTIFIED_ONLY = new Map<String, String>{
        'AAO_Disposition__c' => 'the identification disposition',
        'AAO_Person__c' => 'the person',
        'AAO_Identification_Basis__c' => 'the identification basis',
        'AAO_Corroborated__c' => 'the two-read corroboration marker',
        'AAO_Verification__c' => 'the blind reader\'s verdict',
        'AAO_Verification_Note__c' => 'the blind reader\'s reason',
        'AAO_Claim__c' => 'the claim it became'
    };

    /**
     * Frozen once written. The words a verdict was reached against, and where they are.
     * Editing any of these would move an anchor out from under a claim that already cites
     * it, which is the same argument that freezes a contract's authored text.
     */
    private static final Set<String> FROZEN = new Set<String>{
        'AAO_Stage__c',
        'AAO_Run_Key__c',
        'AAO_Pair_Ref__c',
        'AAO_Pair_Key__c',
        'AAO_Located_Pair__c',
        'AAO_Answer_Text__c',
        'AAO_Start_Offset__c',
        'AAO_End_Offset__c',
        'AAO_Occurrence__c',
        'AAO_Artifact_SHA256__c'
    };

    public static void beforeInsert(List<AAO_Pair__c> rows) {
        for (AAO_Pair__c p : rows) {
            p.AAO_Synthetic__c = AAO_Synthetic.MARK;
            p.AAO_Pair_Key__c = AAO_PairKey.compose(p);
            validate(p);
        }
        refuseChainedIdentifications(rows);
    }

    public static void beforeUpdate(List<AAO_Pair__c> rows, Map<Id, AAO_Pair__c> oldById) {
        for (AAO_Pair__c p : rows) {
            AAO_Pair__c old = oldById.get(p.Id);
            for (String f : FROZEN) {
                if (p.get(f) != old.get(f)) {
                    p.addError(
                        f +
                        ' is immutable on AAO_Pair__c. A pair records what was found and ' +
                        'where; a claim adjudicated against these words rests on them ' +
                        'being the words that were there. Wrong text is marked wrong, ' +
                        'never edited.'
                    );
                    break;
                }
            }
            if (!p.hasErrors()) {
                validate(p);
            }
        }
    }

    /**
     * A pair is the byte-verification and the recall-gate record, and it outlives the
     * Candidate rows that retire into the decision log. Deleting one destroys the evidence
     * that a stage ever ran, which is exactly what the arithmetic between the row sets is
     * counting. There is no supersession path here because a pair is an observation about
     * a frozen artifact: it does not go out of date, and a re-run writes a new run key.
     */
    public static void beforeDelete(List<AAO_Pair__c> rows) {
        for (AAO_Pair__c p : rows) {
            if (AAO_Synthetic.deletable(p.AAO_Synthetic__c)) {
                continue;
            }
            // The purge door, twenty-eighth stamp: the sandbox harness deleting its own
            // run-enumerated rows is not the never-delete law's subject. Open only inside
            // AAO_Purge.run's own transaction, only for the enumerated run keys.
            if (AAO_Purge.allowsPair(p)) {
                continue;
            }
            p.addError(
                'AAO_Pair__c is not deletable on the live path. The pair ledger is the ' +
                'record that a stage ran at all: pairs located, pairs identified, ' +
                'identifications refused, verifications refused are counts between two ' +
                'row sets, and a deleted row makes those counts lie rather than fail. ' +
                'A re-run writes a new run key and leaves this one standing.'
            );
        }
    }

    private static void validate(AAO_Pair__c p) {
        if (p.AAO_Stage__c == AAO_PairKey.LOCATED) {
            validateLocated(p);
        } else if (p.AAO_Stage__c == AAO_PairKey.IDENTIFIED) {
            validateIdentified(p);
        }
        validateOffsets(p);
    }

    private static void validateLocated(AAO_Pair__c p) {
        if (p.AAO_Located_Pair__c != null) {
            p.addError(
                'A Located pair has no parent. It IS the parent: call 1 emits it and ' +
                'call 2 links to it.'
            );
        }
        forbid(p, IDENTIFIED_ONLY, 'call 1', 'Located');

        if (String.isBlank(p.AAO_Answer_Text__c)) {
            p.addError(
                'A Located pair with no answer text is a pair with no anchor. The ' +
                'verbatim words ARE the anchor; that is why there is no separate anchor ' +
                'entity. A pair whose words do not byte-match the artifact is discarded ' +
                'and counted (unit: pairs), never written empty.'
            );
        }
        if (p.AAO_Occurrence__c == null || p.AAO_Occurrence__c < 1) {
            p.addError(
                'A Located pair must say which occurrence it is, one-based. A verbatim ' +
                'string matching more than once anchors every occurrence, so without ' +
                'this the sidecar timestamp lookup and the context window are ambiguous. ' +
                'On most fixtures this is 1, which is not an argument for leaving it off.'
            );
        }
        if (p.AAO_Occurrence_Count__c != null) {
            if (p.AAO_Occurrence_Count__c < 1) {
                p.addError(
                    'Zero matches discards the pair and increments a counter. It never ' +
                    'writes a row saying the words were not found.'
                );
            } else if (
                p.AAO_Occurrence__c != null &&
                p.AAO_Occurrence__c > p.AAO_Occurrence_Count__c
            ) {
                p.addError(
                    'Occurrence ' + p.AAO_Occurrence__c + ' of ' +
                    p.AAO_Occurrence_Count__c + ' does not exist.'
                );
            }
        }
    }

    private static void validateIdentified(AAO_Pair__c p) {
        if (p.AAO_Located_Pair__c == null) {
            p.addError(
                'An Identified pair must point at the Located pair it identifies. ' +
                'Without the link there is nothing to count against, and the ' +
                'one-for-one-for-one arithmetic is the completeness proof.'
            );
        }
        forbid(p, LOCATED_ONLY, 'call 2', 'Identified');

        if (String.isBlank(p.AAO_Disposition__c)) {
            p.addError(
                'An Identified pair must carry exactly one disposition: a person, None, ' +
                'or Ambiguous. None and Ambiguous are not abstention rows; they say what ' +
                'happened to a pair that exists, never that the transcript was silent.'
            );
            return;
        }
        Boolean named = p.AAO_Disposition__c == 'Identified';
        if (named && p.AAO_Person__c == null) {
            p.addError(
                'A disposition of Identified with no person is the unanswered answer row ' +
                'again: one state wearing two physical shapes. Use None or Ambiguous.'
            );
        }
        if (!named && p.AAO_Person__c != null) {
            p.addError(
                'A disposition of ' + p.AAO_Disposition__c + ' carries no person. ' +
                'Call 2 says who it is or says it cannot, and never both.'
            );
        }
        if (p.AAO_Verification__c != null && p.AAO_Disposition__c != 'Identified') {
            p.addError(
                'The blind reader verifies an identified claim. There is no claim in ' +
                'front of it on a ' + p.AAO_Disposition__c + ' row.'
            );
        }
    }

    private static void validateOffsets(AAO_Pair__c p) {
        Boolean hasStart = p.AAO_Start_Offset__c != null;
        Boolean hasEnd = p.AAO_End_Offset__c != null;
        if (hasStart != hasEnd) {
            p.addError(
                'A byte location is a range or it is nothing. One offset without the ' +
                'other locates no words.'
            );
            return;
        }
        if (hasStart) {
            if (p.AAO_Start_Offset__c < 0) {
                p.addError('Offsets into the normalized text are zero-based and never negative.');
            } else if (p.AAO_End_Offset__c <= p.AAO_Start_Offset__c) {
                p.addError(
                    'The end offset is exclusive, so it is strictly greater than the ' +
                    'start. Got ' + p.AAO_Start_Offset__c + ' to ' + p.AAO_End_Offset__c + '.'
                );
            }
        }
    }

    private static void forbid(
        AAO_Pair__c p,
        Map<String, String> fields,
        String who,
        String stage
    ) {
        for (String f : fields.keySet()) {
            Object v = p.get(f);
            if (v == null || v == '' || v == false) {
                continue;
            }
            p.addError(
                'A ' + stage + ' pair carries ' + fields.get(f) + ' (' + f + '), which ' +
                'is not ' + who + '\'s to write. Each call\'s charter forbids the other ' +
                'calls\' jobs, and the failure mode is a call quietly taking back a job ' +
                'that was taken from it, so the prohibition is a field the database ' +
                'refuses rather than a sentence in a prompt.'
            );
            return;
        }
    }

    /**
     * The ledger is two rows deep and never a chain. An identification of an
     * identification would make "pairs identified" a tree walk instead of a count, and
     * the whole reason for the second row is that the count is trivial.
     */
    private static void refuseChainedIdentifications(List<AAO_Pair__c> rows) {
        Set<Id> parents = new Set<Id>();
        for (AAO_Pair__c p : rows) {
            if (p.AAO_Located_Pair__c != null) {
                parents.add(p.AAO_Located_Pair__c);
            }
        }
        if (parents.isEmpty()) {
            return;
        }
        Map<Id, AAO_Pair__c> byId = new Map<Id, AAO_Pair__c>(
            [SELECT Id, AAO_Stage__c FROM AAO_Pair__c WHERE Id IN :parents]
        );
        for (AAO_Pair__c p : rows) {
            if (p.AAO_Located_Pair__c == null || p.hasErrors()) {
                continue;
            }
            AAO_Pair__c parent = byId.get(p.AAO_Located_Pair__c);
            if (parent != null && parent.AAO_Stage__c != AAO_PairKey.LOCATED) {
                p.addError(
                    'An Identified pair points at a Located pair. This one points at an ' +
                    parent.AAO_Stage__c + ' pair, which would make the ledger a chain. ' +
                    'It is two rows deep, and that is what makes every stage a count.'
                );
            }
        }
    }
}
