# Run `pf0811-t0` · the temperature-0 stability probe · THE PROBE CANNOT RUN AS SPECIFIED

Thirty-eighth stamp item 4. Authorizing bytes: *"CODE reruns the three-run stability probe with
TEMPERATURE 0 ON CALL 3 ONLY, reads untouched (their variance is the ruled recall hedge), purge
between, mechanical diff on the merge key, nothing tuned against the output."*

**Result, measured and not asserted: the temperature knob does not exist on the model call 3 runs.
The gateway refuses the parameter with HTTP 400. No three-run probe was produced, because none
could be. The instrument was built, tried from the calling runtime, and reported.**

## The refusal, verbatim from the wire

Every call 3 in the first corrected run returned:

```
400 Bad Request
{"type":"error","error":{"type":"invalid_request_error",
 "message":"`temperature` is deprecated for this model."}}
```

Three request ids, one per verify shard: `req_011CdwFzSfCSgPYTdKfzGqRY` (plain shard 0),
`req_011CdwFzTDSRih7tFRief3us` (plain shard 1), `req_011CdwFzT9U9e9UKMyTKZaFX` (sentiment).

## The capability matrix, probed directly rather than inferred

A minimal 64-token call per model, temperature 0, same credential and endpoint:

| model | `temperature` accepted? |
|---|---|
| `claude-opus-5` | **REFUSED**, deprecated for this model |
| `claude-sonnet-5` | **REFUSED**, deprecated for this model |
| `claude-haiku-4-5-20251001` | ACCEPTED, `stop_reason=end_turn` |

**Call 3 dispatches on `claude-opus-5`.** So option (a) from the stability probe's parked list,
*"lower/zero call-3 sampling temperature, cheap, may not fully settle a blind reader"*, is not
cheap-but-uncertain. It is **unavailable** on the current verifier. That is a fact about the
endpoint, not a judgment about the remedy.

## What was built, and the state the org is in now

The knob is real and shipped, because the measurement needed it and it is the reversible half:

- `AAO_Model_Config__mdt.AAO_Verify_Temperature__c` (Number 4,2). **Blank means the key is never
  put on the wire**, which is the baseline every prior measurement was taken against; a key with a
  default behind it is a different request, so null omits rather than defaults. Same discipline
  `effort` already follows.
- `AAO_Extract.Config.verifyTemperature`, `StageSpec.temperature`, emitted in the request body only
  when non-null, and journalled on `StageResult` (`temp=unset` or `temp=0.00`) so a probe can
  **evidence** what went on the wire instead of claiming it.
- `AAO_Pass` line ~966: call 3's spec takes the temperature at the site that actually dispatches it.

**The org is back at baseline**: `AAO_Verify_Temperature__c` is nil again, verified from the calling
runtime (`call3 temperature = null`). Probe run keys purged (`0` map rows, `0` claims left behind).
Nothing is tuned, and no map carries anything from this run.

## The first-attempt miss, recorded because it is the reason the check exists

The first wiring attached the temperature to `AAO_Extract.verifySpec()`, which is the obvious place
and the wrong one. The run completed and the wire reported **`temp=unset`** with
`model=claude-opus-5`, not the haiku that `verifySpec()` names. Call 3 of the §P8 pass does not use
`verifySpec()`; it builds from `inventorySpec()` and overrides the stage and charter. Had the run
not printed the temperature it actually sent, this session would have reported a temperature-0 probe
that never sent a temperature. The `temp=` journal field exists because of that miss.

## STRUCTURAL FINDING, parked with options and costs, NOT built

Chasing the above surfaced a divergence between written configuration and wire behaviour, the same
shape as the coverage-Internal finding the thirty-seventh stamp ruled on. Measured:

| stage | model the config names | model actually dispatched |
|---|---|---|
| reads (call 1) | `AAO_Inventory_Model__c` = opus-5 | claude-opus-5 |
| bind | `AAO_Bind_Model__c` = **sonnet-5** | not on the §P8 path |
| **call 3 verify** | `AAO_Verify_Model__c` = **haiku-4-5** | **claude-opus-5** |

Every §P8 stage (call 0, both reads, the resolution model leg, call 3) builds from
`inventorySpec()`. `bindSpec()` and `verifySpec()` are read only by the older `AAO_EBV` path.
`AAO_Extract.requireSeparateModels()`, whose comment reads *"A verifier that is the same model as
the binder is not a second reader, it is the same reader asked twice, and every rejection count it
produces is worthless"*, is called from `AAO_EBV` **only, never from the §P8 pass** (verified by
grep: two callers, both in `AAO_EBV`, plus its test).

Stated precisely, so this is not over-read: **call 3's BLINDNESS still holds** and is structural in
the schema (no person field, no transcript, per `AAO_VerifyPairsCharter`). What does not hold on the
§P8 path is **MODEL SEPARATION**: the reader and the verifier are the same model. Whether that is
intentional (the strong model was wanted for verification) or drift is a design question, and the
separation guard not covering the path where verification actually happens is a fact either way.

Options for design, with costs, none chosen and none built:

1. **Point call 3 at the configured `AAO_Verify_Model__c` (haiku-4-5).** Restores model separation
   and makes the temperature probe runnable, since haiku accepts the parameter. Cost: it changes
   the verifier on every measurement this project holds, so the graded numbers (tg1 87.5 percent,
   Pass 1 80.0 percent) would not carry forward, and the thirty-seventh stamp's own caveat on the
   small model applies: *"Gated, not trusted: one adjudicated comparison against the strong model is
   owed before its rejections are believed."*
2. **Extend `requireSeparateModels()` to the §P8 path.** Cheap to write, but it would throw on
   every run until option 1 or an explicit exemption is ruled, so it is a ruling, not a fix.
3. **Rule the current shape correct in writing** (same model, blindness carrying independence) and
   correct the config so it stops naming models the pass does not use. Cheapest, and it makes the
   ledger honest, but it accepts that "second reader" means second reading rather than second model.

The temperature remedy itself now depends on this: **there is no temperature-0 probe of call 3 that
does not also change the verifier model.** N-of-M voting, which the stamp already holds in reserve
(*"N-of-M voting stays in reserve if the probe measures insufficient"*), is model-independent and
does not have that entanglement.

## retryNotes

**Call 0 failed the quote law twice and stopped the run, which is the policy working.** Message:
*"Call 0 answered yes to ACCOUNT content and quoted nothing ... an unchecked side is how a scope
read gets graded right for the wrong reason."* One retry fired per the thirty-fourth stamp's named
policy, the second failure stopped rather than routing on an unchecked scope. This is the known
call-0 flake on Project Farma, unchanged by anything here.

Also recorded: the reads are **1-indexed** (`locateRead` refuses index 0: *"Read index must be 1 or
2"*). The first driver used 0 and 1 and lost one read; caught by the exit code, fixed, rerun.

## What this run did measure before call 3 refused

Not a stability result, and it is not offered as one. Single run, for the record: reads 29,851 ms
and 27,845 ms in parallel, **49 located pairs**, resolution deterministic leg 338 ms, model leg
7,258 ms (2 designator units). Governors clear everywhere: worst reading resolution SOQL 7/100,
join SOQL 48/100 and DML 56/150 on the earlier run, heap under 92 KB of 6 MB. Label **COLD**
(`cache_read=0` on call 0 and both reads).

## What this does and does not establish

It establishes that the temperature remedy cannot be measured on the current verifier, and it
establishes why, from the wire. It does **not** establish that temperature would or would not settle
the flicker, because that question is now unreachable without changing the model. The flicker
measurement from `pf0808-stability` stands unchanged and unrefuted: location stable (42/42/43),
upheld nearly tripling (8 to 21), 1 of 7 load-bearing cells stable across three identical runs.
