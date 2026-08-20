# The 139th's two builds, and the 140th's one-line question

CODE, 20 August. Both builds deployed to `aossb2`, proven at the runtime, committed by path.
Mechanism shape named for each, per the 139th's item 4.

## 0 · The 140th's item 4, answered in one line

**Neither the purge nor the A3 correction: the gap is exactly the three live establishments the
138th's deal carried and a purged deal does not.** The rehearsal deal holds three Live Process
answers, `AAO_BANT_N1`, `AAO_BANT_A3`, `AAO_BANT_N2`, all three AFFIRMED, and so three of the
fifteen Process flags read `Cleared` while twelve stand. At Stage 3 the fourteen questions past
their marker minus those three cleared is eleven, which is the 138th's count; on a purged deal
nothing is established, so all fourteen past-marker questions flag, which is CODE's fourteen.
14 - 3 = 11, and the two readings never disagreed about the mechanism.

Measured, not reasoned:

```
D stage=Stage 1 ordinal=1
F Process flags: standing=12 cleared=3
A AAO_BANT_N1 = AFFIRMED
A AAO_BANT_A3 = AFFIRMED
A AAO_BANT_N2 = AFFIRMED
P reds now = 0
```

The last line is the 140th's honest zero, standing in the org right now: Stage 1, ordinal 1, no
marker passed, nothing overdue, nothing red. A quiet blank is a state.

One correction to the stamp's guess, offered because the ledger is worth more exact than
flattering: A3 on the rehearsal deal reads AFFIRMED and always did. The DENIED A3 lives on the
proof deal. The A3 reword changed the question's words, not this deal's interpretation, so it
cannot have moved this count in either direction.

## 1 · Token telemetry (the 139th's item 1)

**Mechanism shape: a per-leg accumulator with no readers on any branch.** Five counts ride the
receipt leg, are summed into the leg by `summarise`, accumulated onto the receipt row by
`mergeLeg`, and surfaced on `AAO_DemoController.RunView`. Nothing else consumes them.

Design's binding law was that telemetry is observation and so must be incapable of changing a
run's behaviour. That is a claim about the code, so it is proven by the code rather than
asserted. Every appearance of `inputTokens`, `outputTokens`, `thinkingTokens`,
`cacheWriteTokens` and their five stored fields on the receipt path is an assignment, an
accumulation, a SELECT, or a display. The receipt path contains exactly one branch that reads a
token count:

```apex
if (c.usage.cacheReadTokens != null && c.usage.cacheReadTokens > 0) {
    warm = true;
}
```

That is the pre-existing COLD/WARM test. Its predicate is byte-identical before and after this
build; it moved inside a `c.usage != null` guard and nothing more. The five new counts introduce
no branch anywhere.

The prices are kept as two numbers, not one. `cacheReadTokens` and `cacheWriteTokens` are
separate columns because they are separate bills, and a reader who wants a raw token count can
add them. Collapsing them would have hidden whether the artifact-first prefix reorder is working.

**Proven on one real callout**, on the proof deal, with the rehearsal deal untouched:

```
R call 0 done
T RUN TOTALS: callouts=1 in=561 out=174 thinking=0 cacheRead=0 cacheWrite=2335
L call 0 resolve callouts=1 in=561 out=174 think=0 cacheRead=0 cacheWrite=2335
```

Leg and row agree because one leg is the whole run. A cold call: nothing read from cache, 2,335
tokens written into it. That is the shape John's question wanted, a rehearsal that prints its
own token bill instead of design's arithmetic.

One defect found and fixed on the way, which no test would have caught: `mergeLeg`'s own SELECT
omitted the five new fields, so the first accumulation would have thrown on an unselected field
and the class's existing swallow would have eaten it. The receipt would have stayed silently
zero and looked like a model that reports no usage. Both SELECTs now carry the fields.

## 2 · Per-call-class model config (the 139th's item 2)

**Mechanism shape: a lookup that returns the caller's fallback when no record claims the class.**
`AAO_Extract.forClass(callClass, fallbackModel, fallbackEffort, fallbackMax)` reads
`AAO_Model_Config__mdt` for a record naming that class and returns the passed-in fallback
untouched when none does. `asClass(spec, callClass)` stamps the class onto a `StageSpec`. The
four class constants are `router`, `read`, `verify`, `match`.

Shipped inert, and the inertness is measured rather than described. With no record naming a
class, every class returns the caller's own fallback verbatim, and a real spec built through the
ordinary path is unchanged:

```
K router -> model=FALLBACK-MODEL effort=FALLBACK-EFFORT max=4242
K read   -> model=FALLBACK-MODEL effort=FALLBACK-EFFORT max=4242
K verify -> model=FALLBACK-MODEL effort=FALLBACK-EFFORT max=4242
K match  -> model=FALLBACK-MODEL effort=FALLBACK-EFFORT max=4242
S read spec model=claude-opus-5 effort=low max=12000
R records naming a class: 0
```

The callers now name their own class, which is the part that is not configuration: call 0 is
`CLASS_ROUTER`, `inventorySpec` is `CLASS_READ`, call 3 is `CLASS_VERIFY`, and both
`AAO_CardFace` and `AAO_CriterionMatch` are `CLASS_MATCH`. Until a record claims a class the
ladder is a no-op, so this build changes no run today and can change one tomorrow without a
deploy. A field with no readers is a plan, not a mechanism; this one has four readers and no
writers yet, which is the other half of the same law and is the intended state.

## 3 · What was not touched

The rehearsal deal. It stands where design set it at 14:07:49, `Stage 1`, `Type` intact at
`AAO BANT (Sandbox)`, ordinal 1, zero reds, zero ghosts. The one callout proving telemetry was
made on the proof deal for exactly that reason. Per v0_3 the purge is the rehearsal's opening
move and is Matthew's to run, not the machine's to anticipate.

## 4 · Suite, and three process facts worth the ledger

Suite unchanged at **609 run, 608 pass**. The single failure is the standing org-resident
non-AAO `ConvertToOpportunityTest.testgetOppCreationDetails`, which dies on an org validation
rule, `FIELD_CUSTOM_VALIDATION_EXCEPTION, AE Summary is required when no opportunity is created
... [AE_Summary__c]`. Same failure that stood at the 136th's commit, and it touches nothing AAO
owns.

**Fact one: the CLI's own summary contradicted itself and the org told the truth.** The
human-format summary printed `Pass Rate 100%` and `Fail Rate 0%` beside `Outcome Failed`, which
cannot all hold at once. Querying `ApexTestResult` for the run's job id named the one failure in
a single line. The rule this earns: **when the tool's summary contradicts itself, the org is the
authority and the query is the receipt.** A green summary is not a green suite.

**Fact two, the more dangerous one: the CLI's global `target-org` is `altify-dev`, not
`aossb2`.** Partway through this session bare `sf` commands began resolving to
`matt.f1acf8da6351@agentforce.com` rather than the sandbox. Caught by reading the `Target Org`
line of a running validate, which was cancelled within thirty seconds. Nothing was written: a
validate is check-only, and the only other affected commands were read-only queries whose
zero-row answers I had briefly and wrongly read as evidence rather than as a wrong address.
`altify-dev` holds **zero** classes matching `AAO_%`, so no AAO Apex could ever have run there;
both readings in this report were re-taken with `-o aossb2` pinned and came back identical. The
global config belongs to the user and was not changed. **Every `sf` command in the AAO tree now
names its org explicitly.**

**Fact three: the shell's working directory reset mid-session to the preloss evidence tree.**
Caught on the first write that failed rather than on a write that succeeded somewhere wrong.
`/Users/thefinalmachine/Downloads/aao-sandbox` is clean, carrying only the untracked backup
directory it already had; nothing was created, edited, or removed there. All paths in this
tree are now absolute. The evidence stays evidence.

Both of the last two facts share one shape and it is the same shape as the telemetry defect in
section 1: **a silent wrong answer reads exactly like a right one.** A query against the wrong
org returns zero rows, not an error. A SELECT missing a field throws into a swallow and leaves a
zero. A summary can print 100% over a failure. The defence is never to trust the shape of the
answer, only its address.
