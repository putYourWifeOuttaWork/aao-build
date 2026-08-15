# The eighty-ninth stamp's item 5 · ANSWERED, and it is 5(c) with a mechanism

**The eight anchor fields were in the org the whole time.** They were invisible to every
instrument both sides used, for one reason, and that reason is neither of the eighty-eighth
stamp's two candidate causes as either side stated them.

**CODE's own "the anchor fields are not in the org" is WRONG and is corrected here.** So is the
eighty-ninth stamp's item 1, and so is its item 2's reasoning. All three failed the same way: they
read an FLS-filtered view and reported it as existence.

## The answer, in one line

The fields exist in `00DWD00000DV7iT2AT`, deployed 2026-08-15. **They carried no field-level
security for any permission set**, and on this platform a Metadata-API-deployed field grants FLS to
nobody — **System Administrator included**. An unpermissioned field is absent from `describe`,
absent from FLS-aware SOQL, and uncompilable in anonymous Apex, while existing perfectly well.

## The eight API names, as item 5 requires

`AAO_Designator__c` · `AAO_Anchors__c` · `AAO_Anchor_Count__c` · `AAO_Identity_Provenance__c` ·
`AAO_Utterance_Source__c` · `AAO_Utterance_Start__c` · `AAO_Utterance_End__c` ·
`AAO_Utterance_Quote__c`

All eight on `AAO_Shadow_Person__c`, all `required=false`, all writable, none a formula.

## The measurement that separated existence from visibility

The same object, the same org, the same second, through two APIs:

| instrument | FLS-aware | count | the eight |
|---|---|---|---|
| `FieldDefinition` via **Tooling API** (`-t`) | **no** | 33 | **all PRESENT**, `LastModifiedDate` 2026-08-15T12:42:24Z and 13:07:38Z |
| `FieldDefinition` via **standard API** | **yes** | 24 | **all ABSENT** |
| `sf sobject describe` | yes | 23 | ABSENT |
| anonymous Apex `s.AAO_Designator__c` | yes | — | compile failed at that line |

**The Tooling row is the one that settles it**: a field cannot carry a `LastModifiedDate` in the
org's own schema catalogue and simultaneously not exist. Design's 24-row `FieldDefinition` result
is the standard-API row of this table exactly, which is why design and CODE agreed while both were
wrong.

## The control that proves the mechanism rather than asserting it

`FieldPermissions` on `AAO_Shadow_Person__c`, before the fix:

- the **eleven older fields** each carry `AAO_Admin` (readable, editable) — all eleven are named in
  `AAO_Admin.permissionset-meta.xml`
- the **eight anchors** carry only `sfdc_slack`, a system-granted permission set — **none of the
  eight is named in `AAO_Admin`**

And the natural experiment nobody designed: **`AAO_Shadow_Key__c` was modified in the very same
deploy, at the very same second (12:42:24Z), and stayed visible throughout.** It is
`required=true`, and a required field's FLS is universal and unrestrictable. All eight anchors are
`required=false`. **Same deploy, same object, same second, opposite visibility, and the only
difference between them is the `required` flag.** That is the mechanism measured, not inferred.

## Why the other evidence looked like it corroborated absence, and did not

- **`Held` on `AAO_Pair__c.AAO_Disposition__c` was visible** because it is a picklist *value* added
  to a field that already had FLS. No new field, no new grant needed.
- **`AAO_Shadow_Key__c`'s description edit was visible** for the `required=true` reason above.
- Both are in the eighty-ninth stamp's item 3 as proof that "metadata writes to this sandbox are
  landing today." **That conclusion was right.** They landed. So did the anchors.
- **The suite's 507 passing was not the false comfort it was taken for.** Deployed Apex compiles in
  system context and ignores FLS; anonymous Apex compiles against the running user's accessible
  schema. The suite was telling the truth about the fields, and the probe was telling the truth
  about the user. Both were read as claims about existence, and neither was.

## The new law's example is wrong, and the law survives with a sharper edge

The eighty-ninth stamp's item 6 rests on `created=false` proving nothing. **In this case
`created=false` was literally true and correctly reported**: the fields already existed, so there
was nothing to create. The deploy never lied. Every redeploy reporting `Succeeded, 22 components`
was accurate.

The law as written would not have caught this, because the prescribed remedy — "query
`FieldDefinition` or `EntityDefinition` for the specific API names after the deploy" — is exactly
what design did, and it returned the wrong answer. **The amendment the evidence forces:**

> Deploy success is established by querying the org for the specific API names, **naming the org id
> the query ran against, and naming whether the API used enforces FLS.** A field absent from an
> FLS-aware read is not thereby absent from the org; the Tooling `FieldDefinition` view is the
> existence question, and the standard view is the visibility question. **They are two facts and a
> report states both.**

This is the same shape as the field-with-no-readers law, one level down: **a field with no
permission is a field with no readers, and it reads as a field that is not there.**

## A second finding, independent, and it is the larger process hazard

While reconstructing which instrument read which org:

| | | |
|---|---|---|
| **global `sf` default target org** | `altify-dev` | `00Dg500000B0KjZEAV` — **not the sandbox** |
| neither project set a project-level target org | | any `sf` command without `-o` went to `altify-dev` |
| `AAO_Shadow_Person__c` in `altify-dev` | **does not exist at all** | `describe` → `NOT_FOUND`; `FieldDefinition` → 0 rows |

**And there are two source trees on this device:**

| path | branch | `sfdx-project.json` name | anchor field files |
|---|---|---|---|
| `/Users/thefinalmachine/Downloads/claude` | `main` | `aao-build` | **21 fields, all eight present** |
| `/Users/thefinalmachine/Downloads/aao-sandbox` | `master` | `aao-sandbox` | 13 fields, **none of the eight** |

`aao-sandbox` is the pre-loss lineage and is **evidence under the custody rule; nothing in it was
touched, including its `sf` config.** It is also the shell's default working directory, which is the
hazard: the default cwd is the quarantined tree and the default org is a third org where our object
does not exist. Two independent ways for a command to silently address the wrong thing.

**Fixed, in the live tree only:** `sf config set target-org=aossb2` in
`/Users/thefinalmachine/Downloads/claude/.sf/config.json`. An unqualified `sf` command from the
live tree now resolves to `00DWD00000DV7iT2AT`, verified by `sf org display`.

## The fix, and the verification that counts

Added the eight `fieldPermissions` blocks to `AAO_Admin.permissionset-meta.xml` (readable and
editable, all eight writable non-formula fields), deployed **explicitly `-o aossb2`**, job
`0AfWD00000FuquX0AR`, host `altify--aossb2.sandbox.my.salesforce.com`.

**Three instruments, after, all affirmative and all FLS-aware:**

```
FLS-aware FieldDefinition   24 → 32 fields · ALL EIGHT PRESENT
anonymous Apex probe        Compiled successfully · Executed successfully
                            USER_DEBUG|COMPILE PROBE OK: probe
SOQL selecting all anchors  succeeds · 0 records (no shadow persons on this deal yet)
```

## What this does to the read

**S5-19, DELTA-1, and the mention-held half of S5-18 are MEASURABLE.** They do not grade NOT
MEASURABLE, and the eighty-ninth stamp's item 8 fallback does not fire. The utterance existence
proof, the anchor count, and `N anchors` are all readable through design's own connection now.

**One caveat, stated because it is the honest boundary:** these fields have never held a row. The
SOQL returns zero records. Their *writability under load* is proven only by the suite, and the WF
read is still the first real exercise of the branch that writes them — which is exactly the
zero-coverage disclosure the eighty-eighth stamp's item 4 already recorded. Nothing here softens
that.

## The pattern, and its count

The eighty-ninth stamp put the field-with-no-readers pattern at six and said its law now runs both
directions. **This is the third direction: a reader and a field, and no permission between them.**
The cheap check joins the other two — before a ruling rests on a field, grep for its readers, and
query for its permission.
