#!/usr/bin/env python3
"""
Re-apply the schema rulings the authored docs do not yet carry.

WHY THIS EXISTS. docs/ is read-reference and every context sync replaces it wholesale. The
field tables are the object record, but rulings arrive in this repo and the tables are
authored elsewhere, so each sync silently reverts them: three syncs running, the incoming
aao-field-tables-v0_10.md has been byte-identical to the one before it while the org moved
underneath. Re-applying by hand is how corrections get lost.

DELETE THIS SCRIPT the moment the authored tables carry these. It is a patch over a
divergence, not a place to keep truth: the journal is the record, and this only keeps docs/
from contradicting it. Every edit below asserts its target and EXITS LOUDLY if the upstream
text has moved, so a real upstream fix breaks this script rather than silently double-
applying or papering over a change somebody made on purpose.
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


FT = 'docs/aao-field-tables-v0_10.md'

edit(
    FT,
    '| `AAO_Evidence_Contract__c` / `AAO_Source__c` | Lookup | Required | Extraction | Which question; which evidence |',
    '| `AAO_Evidence_Contract__c` | Lookup | Required | Extraction | Which question |\n'
    '| `AAO_Source__c` | Lookup | **Nullable since 47** | Extraction | Which evidence, when the evidence is an artifact. Null on a state-derived row, and the evidence-family law requires it to be null there |\n'
    '| `AAO_Basis__c` | Picklist: `State`/`Transcript`/`Both` | Restricted, nullable | Whoever proposes | **Ruled 47.** Which family of evidence this rests on, and therefore what shape it must have. Not required at field level so pre-47 rows stay updatable; enforced on insert by the trigger, which can say why |',
    '47: Candidate.Source nullable + Candidate.Basis',
)

edit(
    FT,
    '| `AAO_Source__c` | Lookup | Required | Commit | The evidence. Singular and correct |',
    '| `AAO_Source__c` | Lookup | **Nullable since 47** | Commit | The evidence, when the evidence is an artifact. Singular and correct. Null on a state claim, which cites rows instead |',
    '47: Claim.Source nullable',
)

edit(
    FT,
    '| `AAO_Spans__c` | Long Text, JSON | — | Commit, **accumulating across claims** |',
    "| `AAO_Basis__c` | Picklist: `State`/`Transcript`/`Both` | Restricted, nullable | Commit | **Ratified 48.** THE UNION OF THE CLAIMS THAT BUILT IT: established from a call and later reinforced by a state read reads `Both`, which is what `Both` has always meant. Decides what counts as this answer's citation — spans for `Transcript`, the claim's cited rows for `State`. Pre-48 rows are READ as `Transcript`, never backfilled |\n"
    '| `AAO_Spans__c` | Long Text, JSON | — | Commit, **accumulating across claims** |',
    '48: Answer.Basis',
)

edit(
    FT,
    '**Two Apex reserved-word collisions, recorded because they are permanent.** `commit` is a reserved word and cannot be a method name — our vocabulary uses *commit* as a pipeline stage, which is fine as data on a picklist and never as an identifier. And a parameter named `json` shadows the `JSON` system class, which resolves silently because Apex is case-insensitive. Both are naming hazards specific to this domain.',
    """**Five Apex reserved-word collisions, recorded because they are permanent.** Extended 1 Aug 2026 per ruling 48. The count was previously two; this is the full list the build has actually hit, and they come in two kinds. The second kind is the dangerous one.

**Refused loudly, with the identifier named.** `commit`, because our vocabulary uses *commit* as a pipeline stage — fine as data on a picklist, never as an identifier. `any`, which is on nobody's list and took down the first deploy of the pipeline view controller. `merge`, which is a DML statement, so `AAO_EvidenceFamily.merge(String, String)` failed to parse at the declaration itself and was renamed `combine`.

**Resolved silently, with the error surfacing somewhere else entirely.** A parameter named `json` shadows the `JSON` system class, and a local named `system` shadows `System`. Both compile without complaint, because Apex is case-insensitive, and the failure appears later as a missing method on `String`. These are the two worth teaching, precisely because the compiler will not teach them.

Every one is a naming hazard specific to this domain: the words that collide are the words an evidence ledger most wants to use.""",
    '48: the collision list',
)

edit(
    'docs/aao-corp-seed-v1_0.md',
    '`commit` is an Apex reserved word; a parameter named `json` silently shadows the JSON class.',
    '`commit` is an Apex reserved word; a parameter named `json` silently shadows the JSON class. Five collisions in total as of 1 Aug 2026 — see the field tables for the list, which separates the ones the compiler refuses from the two it accepts silently.',
    '48: collision pointer in corp seed',
)
