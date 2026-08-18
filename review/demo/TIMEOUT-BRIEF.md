# Brief for design · the callout timeout, what it cost, and what it changes

Written 18 August, from three live demo-surface runs. **Everything here is measured; nothing is
inferred from the code alone.**

## 1 · WHAT HAPPENED

```
LEG "call 3 verify"  0ms  ERROR = System.CalloutException: Read timed out
```

**Three times across two runs**, on the demo harness deal, at call 3. Not a governor, not the
120-second per-transaction ceiling, and not our code: **the HTTP read on the model callout timed
out.** The transaction had done nothing wrong and had spent nothing.

Two other stage failures rode alongside it and both were mine, named here so the timeout is not
blamed for them:

- **`AAO_Resolve.ResolveException: No undisposed pairs.`** The driver's model-leg guard counted
  LOCATED pairs carrying a designator — always above zero after the reads, because located rows
  are the PARENTS and they stay. So the guard never skipped and the model leg fired on a run the
  deterministic pass had fully disposed. **The pass was right and the driver's question was
  wrong.** Fixed: undisposed is located rows with no Identified child, counted in Apex because
  SOQL refuses an inner and outer select on the same object.
- **The failure reporter died before reporting.** `recordFailure` built a `Leg` with null numerics,
  `mergeLeg` dereferenced them, and its own swallow ate the throw — so a stage that died left NO
  trace at all. Found by probing whether the leg landed rather than trusting it had.

## 2 · WHY THIS IS A NEW CLASS, AND THE REASON IT NEVER SURFACED BEFORE

**Every graded run in this project was driven by CODE from a shell, one `sf apex run` per stage.**
A timeout there was invisible: the operator saw it, re-ran that one command, and the run continued.
**The failure mode was absorbed by a human and never entered the record.**

Under the driver it is fatal by default: the chain stops, and before the failure leg existed it
stopped **silently**, which is byte-for-byte the shape that let 39 upheld pairs produce zero claims
on 16 August.

**So the timeout is not new. What is new is that the product now has to survive it without a person
in the loop** — which is precisely what the hundred-fourth stamp's demo was built to expose, and
it exposed it on day one.

## 3 · THE FIX, AND WHAT IT DELIBERATELY DOES NOT DO

**`resumeRun` re-enters at the stage that failed.** The receipt says where: a leg carrying an error
is treated as NOT done. Everything before it is committed, and the pass's own watermarks make
everything after it idempotent — verify skips what is verified, the join skips what carries a
claim. **Re-running from the top would re-locate and duplicate every pair**, so resume is the only
correct recovery.

This is the ninety-second stamp's split rule reaching FAILURE as well as SIZE: complete the
remaining work in a continuation, never redo.

**It does not auto-retry.** A silent retry would hide the rate, and the rate is the thing design
needs. Today a human clicks Resume and the reason stays on the receipt. **Proved three times.**

## 4 · WHAT IT MEANS FOR THE PROJECT · five things

**(a) R3, Transaction Finalizers, moves from accepted to urgent.** The hundred-tenth accepted it
first in the post-demo order. A Finalizer journals the stage and reason in its OWN transaction
after an uncatchable failure. **My catch cannot cover a `LimitException`, which kills the
transaction outright**, so the honest limit written into `assertEligibleAccountedFor` stands: an
in-transaction assertion dies with the transaction it would warn about. **A timeout is catchable
and a governor death is not, and only the Finalizer closes the second half.**

**(b) THE 120-SECOND CEILING IS NOT THE BINDING TIMEOUT.** Measured worst callouts: 37.9 s here,
87.6 s on Wells Fargo s5 — 32% and 73% of the ceiling, both "safe". **And the call still timed
out.** The HTTP read timeout is a separate, shorter, and less predictable wall. Every timing table
this project has published measures against 120,000 ms; **none of them measures the thing that
actually failed.**

**(c) VERIFY IS THE EXPOSED STAGE and its exposure grows with the corpus.** Call 3 is the longest
callout in the pass and the one that scales with claim count. Wells Fargo s5's 87.6 s was already
the highest ever recorded, and the trend across s3/s4/s5 was monotonic — 46%, 60%, 73%. **A stage
that is both the longest and the most likely to time out is where a retry policy has to land.**

**(d) THE RETRY POLICY COVERS THE WRONG CALL.** The thirty-fifth stamp's one-retry policy is scoped
to call 0's resolve leg and its charter exceptions. **Nothing covers a transport timeout on any
stage.** Whether a timed-out callout should retry once automatically — and if so, whether that
re-opens the tuned-behaviour question, since a retried verify is a second dispatch of the same
claims — is design's ruling, not mine, and I have not built toward either answer.

**(e) THE DEMO IS SAFE AND THE FAILURE IS NARRATABLE.** The yellow box names the cause in the
operator's own words and the Resume button picks up exactly where it stopped. **A demo that can
show its own failure honestly is stronger than one that has never met one**, and this one has met
three.

## 5 · WHAT I HAVE NOT DONE, ON PURPOSE

I have not touched the pass plane: no change to the reads, resolution, verify, the join,
projection, the charters, or any law object. The timeout is met at the DRIVER, which is
demo-surface. **Whether verify should shard smaller, retry, or move to a longer-tolerance
transport is a pass-plane ruling and stays design's.**

## 6 · ONE OBSERVATION FROM THE STACKED RUN, unresolved

The second call on the same deal produced **8 cards, the same count as the first**, and the
Inspector shows its establishments landing on the same three people. That is consistent with the
derived-entity-identity question already open with Matthew (the hundred-eighth): a restatement
across calls may still duplicate, and the reach of card dedup is still unverified. **Recorded as an
observation, not a diagnosis** — the run stacking was interrupted by the timeouts, so it is not a
clean measurement of accrual and should not be read as one.
