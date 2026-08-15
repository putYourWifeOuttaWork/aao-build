# The schema and flow reference · CODE's four deliverables

The ninety-third stamp's item 3. Each file names the tree and the org id it came from, per the
tree-and-org hazard.

| | |
|---|---|
| **Tree** | `/Users/thefinalmachine/Downloads/claude`, branch `main`, project `aao-build` |
| **Org** | `00DWD00000DV7iT2AT` — sandbox `aossb2`, instance `USA758S` |
| **Built** | 2026-08-15 |

| File | Deliverable | Instrument |
|---|---|---|
| `a-schema-dump-tooling.md` | (a) every field on 17 entities, every picklist value | **Tooling API** — FLS-blind |
| `b-apex-inventory.md` | (b) 83 classes, class-to-charter, class-to-call, triggers and rules | the repo |
| `c-current-flow.md` | (c) admission to projection, object written per stage | the classes and the org's row counts |
| `d-altf-projection-map.md` | (d) ALTF targets at field level, value to value | `AAO_P8Codes`, `AAO_Project` |

Design's half, the FLS-aware counterpart used for (a)'s diff, is
`aao-org-field-inventory-2026-08-15.md` at the repo root.

## The headline results

**(a) THE DIFF IS CLEAN: 317 fields FLS-blind, 317 FLS-aware, every per-entity count identical.
No FLS gap to grant.** The only gap this org had was the eight anchor fields on
`AAO_Shadow_Person__c`, closed earlier today. **The check is repeatable, not permanent** — the
next Metadata-API-deployed field will be invisible to design the moment it lands.

**(b) THERE ARE ZERO DECLARATIVE VALIDATION RULES.** All 44 guards are Apex `addError` across 8
trigger handlers, 17 of them on `AAO_Pair__c` alone. That is why the org's laws are unreadable
from the metadata tree and surface only when something breaks one.

**(c) LOOP ONE AND LOOP TWO ARE RETIRED**, marked in place at the head of `aao-model-and-flow.md`
Part II §1 with a pointer here, unedited.

**(d) The map is the contract; the run's row export is the evidence.** A dimension missing from
a map row means one of three different things, and only the Answer ledger distinguishes them.

## The three findings, answered in (c)

1. **`AAO_Pair__c`** carries **two physical shapes in one table** — a Located proposal forbidden
   the person, an Identified disposition forbidden the located-only fields — which is why one
   paragraph could never describe it. Measured: 236 Located, 135 Identified, and **134 of 135
   dispositions are the happy path**, so every refusal branch is essentially unexercised.
2. **`AAO_Shadow_Person__c` has never held a row.** Zero ever, not zero lately. Combined with the
   eighty-eighth stamp's zero-coverage disclosure, the Wells Fargo read writes this object's
   first row during a graded run — **there is no known-good state to regress from.**
3. **`AAO_Claim_Basis__c` is not a missing link; the link moved.** All 100 claims are
   `Basis = Transcript` and carry their spans and Source on themselves. The junction serves
   `Basis = State`, which this corpus has never produced, and **the §P8 pipeline references it
   zero times in all seven of its classes.** The gap is latent, not actual, and is named.
