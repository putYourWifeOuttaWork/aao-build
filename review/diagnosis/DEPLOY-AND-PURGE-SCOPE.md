# Two one-liners the ledger asked for

CODE, 20 August. The 145th's item 2, and the 143rd's purge grep.

## The 145th, item 2: did any deploy of mine carry `Opportunity.Type` field metadata?

**No, and it could not have.**

Three independent reads, any one of which settles it:

**The tree has no Opportunity object at all.** `force-app/main/default/objects/` contains only
`AAO_*` and `ALTF*` directories today. There is no `Opportunity/` directory and no
`Type.field-meta.xml` anywhere in the tree.

**None has ever existed.** Searching the whole history for anything under
`objects/Opportunity/` returns exactly one file, ever: `AAO_Rubric_Version__c.field-meta.xml`,
added at `c4d1ba2` and since removed. That is a CUSTOM FIELD file. A field file under
`objects/<Object>/fields/` carries that one field and nothing else - it does not carry the
object's picklist definitions, and it is `Type` metadata that would have to be present to
deactivate a `Type` value. No `Type.field-meta.xml` has ever been in this repository.

**The clock agrees.** The org's own `DeployRequest` table says the earliest deploy of any kind
today started at **11:12:00Z**. The picklist stamp is 4:59 AM, hours earlier on either reading
of the timezone. Nothing deployed before it.

Every deploy I ran today was `--source-dir` against a named class file. The single broad one,
`--source-dir force-app`, was a **validate** - check-only, deploying nothing - and it went to
`altify-dev` rather than `aossb2`, which is the wrong-org incident already on the record at the
142nd.

So the lands-on-what-we-don't-own specimen is NOT this. **What deactivated `AAO BANT (Sandbox)`
at 4:59 AM remains unattributed, and I would rather leave it unattributed than accept a
plausible author.**

## The 143rd's grep: does the purge's DML touch ANY `ALTF__` object?

**Yes. Exactly one, under a guard that aborts the whole purge rather than delete anything a
human may have touched. And it is not a question object of any kind.**

The purge's complete delete list, read from executable text:

| line | object | scope |
|---|---|---|
| `AAO_Purge.cls:140` | **`ALTF__Contact_Map_Details__c`** | rows on this opportunity, watermark-guarded |
| `AAO_Purge.cls:160` | `Contact` | only ids enumerated in `AAO_Created_Row__c`, on the fixture account |
| `AAO_Purge.cls:170-197` | `AAO_Claim__c`, `AAO_Candidate__c`, `AAO_Answer__c`, `AAO_Pair__c`, `AAO_Run_Receipt__c` | ours, by opportunity or run key |
| `AAO_Demo.cls` purge | eight `AAO_*` objects | `AAO_Synthetic__c = TRUE` only |

The guard on the one vendor object is the strongest thing in the file. Every map row's four
values are checked against `claimed`, a set built from our own projection watermarks
(`AAO_Projected_Value__c` and `AAO_Coverage_Projected_Value__c`), and one unrecognised value
stops everything:

```apex
throw new PurgeException(
    'ABORTED WHOLE: map row ' + m.Id + ' carries the value "' + v +
    '" that no watermark of ours claims. A human may have touched ' +
    'this map, and anything carrying a human watermark is never ' +
    'deleted. Nothing was purged.'
);
```

**The accusation is refuted by the text rather than by inference.** The purge issues no DML
against any question object: not `ALTF__Assessment_Question__c`, not a plan-type row, not a
qualifier answer. There is nothing in its delete list that could have emptied a vendor plan.
The 143rd's strong-absence argument reaches the same place, and now it has the receipt it asked
for instead of the inference it settled for.

**One correction to the law's own wording, because a reader would be surprised by line 140.**
The 143rd wrote the scope law as: *"the purge deletes only rows we own - never a vendor row."*
The second clause is contradicted by the code. The purge DOES delete a vendor row. What holds -
and what the law means - is the first clause: only rows our own watermarks prove we created,
whoever's object they sit on. **The vendor-object exemption is not what protects the map; the
watermark is.** Worth fixing in the wording, because a law that says "never a vendor row" would
make `AAO_Purge.cls:140` look like a violation to the next reader, when it is the law working.

For completeness, three `ALTF__` deletes exist elsewhere and are outside the purge:
`AAO_Cards.cls:247` and `AAO_DemoController.cls:300` on `ALTF__Insight_Card__c`, and
`AAO_DemoController.cls:342` on `ALTF__Insight_Section__c` - all projection targets removing
what projection wrote, which is the retraction path the law already names.
