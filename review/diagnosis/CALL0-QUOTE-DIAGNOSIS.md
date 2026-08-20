# The 141st's diagnosis: call 0's yes without words

CODE, 20 August. The one question first, then the mechanism, then two of the stamp's own
premises corrected with measurement.

## THE ONE-WORD ANSWER: **ABSENT**

The quote was **present in the response, correctly keyed, and empty**. Not mis-keyed. Not a
failed byte match.

Reproduced live, at the effort call 0 actually runs:

```
X low#5 oppYes=true/quoteLen=149  acctYes=true/quoteLen=0  => QUOTE-LAW VIOLATION  out=204 think=0
X low#8 oppYes=true/quoteLen=149  acctYes=true/quoteLen=0  => QUOTE-LAW VIOLATION  out=196 think=0
```

`carries_account_content: true` beside `account_content_quote: ""`. That is byte-for-byte the
condition `AAO_ResolverCharter.side()` throws on, and it is the same side the rehearsal's first
failure named at 14:22.

**Mis-keyed is ruled out by observation.** Every one of eighteen live responses returned exactly
the eight declared keys and no others:

```
KEYS (opportunity_because, opportunity, account_content_because, account_content_quote,
      carries_account_content, opportunity_content_because, opportunity_content_quote,
      carries_opportunity_content)
```

**Failed-byte-match is ruled out by the code path.** The byte match lives at
`AAO_ResolverCharter.locate`, `artifact.indexOf(s.quote)`, and throws its own distinct message
about a quote that "does not locate in the artifact." The rehearsal's error says "quoted
nothing," which is thrown earlier in `side()`, before `locate` is ever called. The two are not
interchangeable and the error message does not cover both. Design's worry that a quote spanning
a TAB would die and read as "quoted nothing" is a real worry about a real hazard, and this
transcript is TAB-separated, so it will matter later. It is not what happened here.

## THE MECHANISM, and it is a premise of the thirty-fourth stamp that does not hold

The thirty-fourth stamp's note, quoted from the code at `AAO_Pass.cls`:

> The yes-is-the-quote schema makes yes-without-quote unexpressible

**It is expressible, and the model expresses it about one time in five.** The schema declares:

```apex
'account_content_quote' => new Map<String, Object>{ 'type' => 'string', ... }
```

required, with `additionalProperties: false`. **The empty string is a valid string.** So a
response carrying `true` beside `""` satisfies the schema completely, the endpoint returns it as
conformant, and the quote law is enforced only afterwards, in Apex, as an exception. The schema
does not make the violation unexpressible; it makes it *undetectable until the parse*. The
retry policy is not a backstop behind a schema that prevents this, it is the only thing standing
there.

This is the "a comment is not a mechanism" law with the pieces swapped: a schema was believed to
be a mechanism, and for this one property it is prose.

## PREMISE CORRECTION ONE: there IS a downsize, and it was there all along

The 141st, section 1: *"the config is the standing Default: claude-opus-5, effort high, 16k
output ceiling — no downsize to blame."* Measured at the runtime:

```
CFG Default model=claude-opus-5 effort=high max=16000.0 active=true class=null
CFG shared effort=high/16000.0   INVENTORY effort=low/12000.0
SPEC model=claude-opus-5 effort=low max=12000 cachePrefix=true
```

The Default record does say high and 16k. **Call 0 does not use them.** It builds from
`AAO_Extract.inventorySpec()`, which resolves the **Inventory** fields, Stage 1's own effort and
ceiling, and those read **low** and **12,000**. Call 0 has been running at the READ class's
downsize since it was given the read spec's endpoint and credential.

`asClass(spec, CLASS_ROUTER)` names the class honestly but changes nothing, because
`forClass` returns the caller's fallback when no record claims the class, and no record does
(`class=null` on Default). That is the config split working exactly as it was shipped inert
yesterday, and it is now the mechanism standing ready for this.

## PREMISE CORRECTION TWO: the effort correlates, but it does not explain a 4-for-4 streak

Measured on this transcript, same source, same block, same schema, same system prompt, varying
only effort:

| effort | attempts | quote-law violations |
|---|---|---|
| low (what call 0 runs) | 14 | **3** |
| high (what the Default says) | 4 | 0 |

Every violation carried `think=0`. Several clean responses did too, so zero thinking is a
companion of the failure rather than a proof of it, and four high-effort samples are far too few
to call high a fix.

**Said plainly, because the arithmetic matters:** at three-in-fourteen, four consecutive failures
in one run is roughly a one-in-five-hundred event. Effort alone does not account for the
rehearsal's streak. Either the two attempts inside one `resolve` are correlated, which they
plausibly are since the retry sends the byte-identical request to a model with no temperature
set, or something about the 14:22 request differed in a way the receipt does not record. **I am
not claiming effort as the cause. I am reporting it as a measured contributing factor and as a
premise of the stamp that needed correcting.**

## What the reproduction could not hold identical, named

`AAO_Pass.ladder` is private, so the "what was computed before you" block was rebuilt in the
harness from the same queries and the same string format rather than called. Owner role
`NOT AVAILABLE`, the two standing notes, the participant-overlap note, the account-map check,
and all five candidate deals in `CreatedDate` order with their overlap counts. Same source
(`a1XWD0000084D8X2AU`, SRC-00000057, 2,770 characters, confirmed identical to the run's), same
ontology, same system prompt, same schema, same spec. The residual risk is that the rebuilt
block differs from the real one in some byte I cannot see, and it is named here rather than
assumed away.

## What the record cannot answer, and why that is itself a finding

The raw response is **unrecoverable from the record by construction.** On the second failure
`AAO_Pass.resolve` throws a `PassException`, and `r.call.rawText` dies with the throw: it is
never returned, never recorded, and no debug log existed for the 14:22 window. The diagnosis
design asked for could only be produced by reproducing the call, not by reading the run. A
stage that can fail on the content of a response should keep the response it failed on.

---

# The fix, on the lawful path

Charter version moves `resolve-1.1.0` -> `resolve-1.2.0`.

## Why the fix is a schema change and not only an instruction

The 141st scoped the fix for case (a) to "the resolver charter's instruction." The measurement
above says an instruction cannot reach this: the violation is schema-valid, so no wording makes
it impossible, only less likely. Before touching the schema's shape I probed whether the
endpoint could express the law with the boolean left in place, using a conditional that requires
a non-empty quote exactly when the boolean is true:

```
PROBE REFUSED: output_config.format.schema:
For 'object' type, property 'then' is not supported
```

Conditionals are refused. `minLength` cannot be applied unconditionally either, because a NO
must leave the quote empty. **That closes every route that keeps the boolean, and leaves exactly
one mechanism: the quote is the answer.**

## What changed

Both `carries_opportunity_content` and `carries_account_content` are gone from the schema's
properties and from its required list. `side()` derives the answer from the words:

```apex
s.carries = String.isNotBlank(s.quote);
```

There is no longer a boolean to say yes with, so a yes without words is not caught, it is
**unexpressible**. That is what the thirty-fourth stamp's note claimed and what the schema did
not do.

Two protections were preserved rather than traded away for the repair:

**A missing question is still not a no.** The boolean's absence used to throw. Now an ABSENT
quote key throws and a PRESENT-AND-EMPTY one is a no. Absent and empty are different things and
the parse says so, so a question that never got asked can still never be read as an answer.

**A retired field coming back is our bug, not the model's.** If a response carries
`carries_*_content`, the schema on the wire is not the schema in this class, and it throws
rather than passing silently. A retired field that quietly reappears is the silent-wrong-answer
shape, and the 142nd's law says to check the address.

## Measured at the runtime, on the real path

`AAO_Pass.resolve` against SRC-00000057, the rehearsal's own source, fourteen real resolves:

| | before (resolve-1.1.0) | after (resolve-1.2.0) |
|---|---|---|
| rehearsal run, 14:22 and 14:25 | **0 of 4 attempts parsed** | n/a |
| quote-law violations, harness, effort low | 3 in 14 | **0 in 15** |
| real resolves dispatching | n/a | **12 of 14** |

The two non-dispatches were one `Read timed out`, a network failure with nothing to do with the
charter, and one reason-guard refusal. Every successful resolve located its quote in the
artifact and dispatched the opportunity grain.

## The risk I checked rather than assumed

Removing the per-side boolean could suppress the smaller side, which is the exact loss the
split exists to prevent and which the system prompt warns about in its own words. Fifteen
consecutive resolves on Brightwell call 1 returned an empty account side, where one old-schema
run on a shorter body had quoted 166 characters of account content. So the mechanism was probed
directly, on an unmistakably account-grain body with no purchase mechanics in it:

```
P#1 scope=ACCOUNT oppLen=0 acctLen=141 acct="Honestly, adoption has been uneven. Two of the
    four regions use it daily and the other two have basically stopped logging in..."
P#2 scope=ACCOUNT oppLen=0 acctLen=141  (identical)
```

**The account side fires cleanly, and the opportunity side goes empty in the same response.**
The mechanism works in both directions. What remains is a calibration question rather than a
broken part: on Brightwell call 1 the model now judges the account content not to rise to a
yes, and in every FAITHFUL old-schema observation it did not either. The old schema's two
account-yes results on that body were precisely the two broken ones, `true` beside `""`. The
new charter turns those into a clean no.

**Whether that no is right about this transcript is a judgment, and it is not mine to make.**
It is visible in the rehearsal, which is the correct place for it to be judged.

## The residual, stated plainly

One resolve in fourteen still refused, on the reason guard rather than the quote law. The
quote-law violation is now unexpressible; the reason guard is a separate floor and can still be
missed. The one-retry policy stands behind both. **The rehearsal is unblocked, not made
infallible**, and the difference is worth keeping in the ledger.
