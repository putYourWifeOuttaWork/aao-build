#!/usr/bin/env python3
"""
Re-apply the built law the authored field tables do not yet carry.

STATUS 2 Aug 2026: v0.11 retired most of this. The authored copy caught up on the
evidence-family law, the abstention enum, Not_Returned, the blind-reader fields, the delete
law and AAO_Cited_Map_Row__c. What remains below is the residue — four places where the doc
and the org still disagree, one of them a claim v0.11's own change note makes about itself.

WHY IT STILL EXISTS. docs/ is read-reference and every sync replaces it wholesale, so a
correction that lives only here dies on the next one. The journal is the record; this only
keeps docs/ from contradicting the org.

DELETE IT the moment the authored tables carry these four. Every edit asserts its target and
EXITS LOUDLY if the upstream text has moved, so a real upstream fix breaks this script
rather than silently double-applying or papering over a change somebody made on purpose.
That is exactly how the v0.10 -> v0.11 bump surfaced: the script stopped being able to find
its targets.
"""
import pathlib
import sys


def edit(path, old, new, label):
    p = pathlib.Path(path)
    s = p.read_text()
    if new in s:
        print('  already carried: ' + label)
        return
    if old not in s:
        sys.exit('UPSTREAM MOVED, re-check by hand: ' + label + ' in ' + path)
    p.write_text(s.replace(old, new, 1))
    print('  carried: ' + label)


FT = 'docs/aao-field-tables-v0_11.md'

# 1. The Answer's basis row is MISSING, though v0.11's change note says it was consolidated.
#    Without it the object record has no entry for a shipped, ratified field.
edit(
    FT,
    '| `AAO_Last_Claim__c` |',
    "| `AAO_Basis__c` | Picklist: `Transcript`/`State`/`Both` | Restricted, nullable | Commit | **Ratified 48.** THE UNION OF THE CLAIMS THAT BUILT IT: call-established then state-reinforced reads `Both`. Decides what counts as this answer's citation — spans for `Transcript`, the claim's cited rows for `State`. Pre-48 rows are READ as `Transcript`, never backfilled |\n"
    '| `AAO_Last_Claim__c` |',
    'Answer.Basis row, absent from section 4',
)

# 2. Candidate's basis is NOT required at field level, and the reason matters: a required
#    picklist would make every pre-47 candidate un-updatable. The trigger enforces it on
#    insert instead, which also lets the refusal explain itself.
edit(
    FT,
    '| `AAO_Basis__c` | Picklist: `Transcript`/`State`/`Both` | Restricted, required | The writer | The family discriminator; the triggers enforce the law against it |',
    '| `AAO_Basis__c` | Picklist: `Transcript`/`State`/`Both` | Restricted, **nullable at field level** | The writer | The family discriminator; the triggers enforce the law against it. Deliberately not `required`: a required picklist would make every pre-47 candidate un-updatable, and enforcing on insert in the trigger lets the refusal say why |',
    'Candidate.Basis is nullable, not required',
)

# 3 and 4. The change note says the list "grows to four"; the list section still says two,
#    and the true count is five. `any` took down the first deploy of the pipeline view
#    controller and has never reached this document.
edit(
    FT,
    '**Two Apex reserved-word collisions, recorded because they are permanent.** `commit` is a reserved word and cannot be a method name — our vocabulary uses *commit* as a pipeline stage, which is fine as data on a picklist and never as an identifier. And a parameter named `json` shadows the `JSON` system class, which resolves silently because Apex is case-insensitive. Both are naming hazards specific to this domain.',
    """**Five Apex reserved-word collisions, recorded because they are permanent.** v0.11's change note says four and this section still said two; both were short. `any` has never reached this document — it took down the first deploy of the pipeline view controller. They come in two kinds, and the second kind is the dangerous one.

**Refused loudly, with the identifier named.** `commit`, because our vocabulary uses *commit* as a pipeline stage — fine as data on a picklist, never as an identifier. `any`. And `merge`, which is a DML statement, so `AAO_EvidenceFamily.merge(String, String)` failed to parse at the declaration itself and was renamed `combine`.

**Resolved silently, with the error surfacing somewhere else entirely.** A parameter named `json` shadows the `JSON` system class, and a local named `system` shadows `System`. Both compile without complaint, because Apex is case-insensitive, and the failure appears later as a missing method on `String`. These are the two worth teaching, precisely because the compiler will not teach them.

Every one is a naming hazard specific to this domain: the words that collide are the words an evidence ledger most wants to use.""",
    'the collision list: five, split by how each fails',
)

edit(
    'docs/aao-corp-seed-v1_0.md',
    '`commit` is an Apex reserved word; a parameter named `json` silently shadows the JSON class.',
    '`commit` is an Apex reserved word; a parameter named `json` silently shadows the JSON class. Five collisions in total as of 1 Aug 2026 — see the field tables for the list, which separates the ones the compiler refuses from the two it accepts silently.',
    'collision pointer in corp seed',
)
