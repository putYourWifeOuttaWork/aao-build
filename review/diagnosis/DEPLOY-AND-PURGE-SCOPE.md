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

---

# The 146th's extension: the picklist at seed time, and the 12:52 plan-row rewrite

## The picklist could not have been ours, and the hypothesis conflates two objects

The 146th's likelier story is that `AAO BANT (Sandbox)` was **born inactive at seed time**. If
"seed time" means our seed, that is impossible, and the reason is worth more than the answer.

`Opportunity.Type` is a **standard field**:

```
FIELD Type custom=false
PV "AAO BANT (Sandbox)" active=true default=false
```

Its picklist values are metadata on a standard object. Our tree has no `Opportunity/` directory
and never had anything under one but a single custom field, since removed. And **no Apex of ours
uses the Metadata API** - zero hits across every class for `Metadata.Operations`,
`Metadata.DeployContainer`, or `MetadataService`. Apex DML cannot create, activate, or
deactivate a picklist value. **There is no mechanism anywhere in our code that can touch a
picklist at all.**

**The conflation, named because it will otherwise keep costing hours.** `AAO_ProcessSeed` writes
a DATA row whose Name is `AAO BANT (Sandbox)` into `ALTF__Opportunity_Plan_Type_List__c`. The
picklist VALUE `AAO BANT (Sandbox)` is METADATA on `Opportunity.Type`. Same string, two
different objects, two different creation mechanisms, and only one of them is ours. Our seed
creating the plan-type row neither creates nor could create the picklist value. Whatever made
that value, and whatever left it inactive, was a hand in Setup or a deploy from a tree that is
not this one.

## The 12:52 rewrite IS ours, and a deploy did not cause it

`AAO_ProcessSeed` writes vendor rows directly: `ALTF__Assessment_Question__c` at 263-304 and
`ALTF__Opportunity_Plan_Type_List__c` at 323 and 331. So the plan-type row is our seed's to
write, and the 146th's attribution of the write is correct.

**But the deploy did not run it.** `AAO_ProcessSeed.run()` is a plain `public static` method:
no `@InvocableMethod`, no `@future`, no `@AuraEnabled`, no `global`, no interface, no trigger.
Nothing about deploying a class executes it. Its only callers in the whole codebase are
`AAO_ProcessSeedTest`, and test DML rolls back.

So 12:52:47Z was a deliberate anonymous-Apex invocation. The `DeployRequest` table puts my
deploy at **12:52:23Z** and the row's `LastModifiedDate` at **12:52:47Z**, twenty-four seconds
later. Everything in this org runs as the shared user, so the audit cannot separate my hand from
a human's - but a seed deployed and then run twenty-four seconds later is the signature of the
builder running what he just deployed, and **I would rather name that than shelter behind a
shared user the 140th already ruled on.** Treat the write as mine unless something contradicts
it.

One number corrected from the same instrument that produced both halves: the trail reads "forty
seconds after `AAO_ProcessSeed` deployed"; deploy at 12:52:23 and write at 12:52:47 is
twenty-four.

## A standing fact the law does not carve out, raised because nobody asked

The purge-scope thread has been arguing about whether our code touches vendor rows. It does, and
not only in the purge: **the seed writes two vendor objects outside projection**,
`ALTF__Assessment_Question__c` and `ALTF__Opportunity_Plan_Type_List__c`.

The law as written says *"nothing of ours writes vendor objects outside projection, wrapper
creation included until Matthew rules otherwise."* The seed is a third case, and it predates
that sentence. Either it is authorized and the law needs the carve-out written where a reader
will find it, or it is not and design should rule. **What it should not be is unwritten**, since
the last two days have twice shown people reasoning from the law's text about what our code can
possibly have done.
