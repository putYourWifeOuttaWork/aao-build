# The stability probe · `pf0808-s1/s2/s3` · the two-read shape flickers against itself

Thirty-second stamp item 2. Three identical runs of the express-lane pipeline on the frozen
Project Farma fixture (sha `018cac1b`), purged between each, `shardCount=2` driven on the plain
verify bucket so the 50-stretch number falls out of work already paid for. **Mechanical only,
nothing graded, nothing tuned against this output** (the stamp's rule). The question it answers:
tg1 and h1 were the same shape disagreeing on identical bytes, so is that shape-versus-shape or
the shape flickering against its own reruns? **Answer: it flickers, hard.**

## The three maps, side by side

| person · dimension | run 1 | run 2 | run 3 | verdict |
|---|---|---|---|---|
| **Adam** · Status | *(none)* | Supporter | **Mentor** | FLICKERING (3 distinct) |
| **Adam** · Political | Inner Circle | Political Structure | Political Structure | FLICKERING (2 distinct) |
| **Adam** · Buyer Role | *(none)* | *(none)* | *(none)* | stable (held all 3) |
| **Adam** · Coverage | Brief | Brief | Brief | **STABLE 3/3** |
| **Dan** · Status | *(none)* | Supporter | Supporter | FLICKERING (2/3) |
| **Dan** · Political | *(none)* | *(none)* | *(none)* | stable (none all 3) |
| **Dan** · Buyer Role | Evaluator | Evaluator | Evaluator | **STABLE 3/3** |
| **Dan** · Coverage | Brief | Brief | Brief | **STABLE 3/3** |
| **Kayla** · present? | **absent** | present | present | FLICKERING |
| **Kayla** · Political | - | *(none)* | Political Structure | FLICKERING |
| **Kayla** · Buyer Role | - | *(none)* | Evaluator | FLICKERING |
| **Kayla** · Coverage | - | Brief | Brief | FLICKERING (presence) |

**Stability rate on establishment cells that ever fire:** 3 of 10 are 3/3 STABLE (Dan's Buyer
Role, and coverage for the two people who always appear). **On the load-bearing dimensions
(Status / Political / Buyer-Role placement), 1 of 7 is stable** - only Dan as Evaluator survives
all three runs. Adam's Status took three different values across three runs of the same bytes:
nothing, Supporter, Mentor.

## Where the flicker lives, and it is NOT the reads

| run | located pairs | upheld claims | map rows |
|---|---|---|---|
| s1 | 42 | **8** | 2 |
| s2 | 42 | **17** | 3 |
| s3 | 43 | **21** | 3 |

**Location is stable (42 / 42 / 43); the verdict count nearly triples (8 → 21).** The reads find
essentially the same volume of evidence every time, and then the downstream verdicts - resolution,
and above all call 3 - disagree about which of it stands. The instability is concentrated AFTER
locate, not in recall. That reframes the attention hazard Matthew priced: on this fixture it is a
VERIFIER-and-join flicker, not a locator-recall flicker.

**This is a measurement, not a diagnosis, and per the working mode nothing is built or tuned
against it.** Two candidate contributors are named for the design list, neither investigated
here: model sampling temperature on call 3 (an LLM asked the same blind question three times may
answer differently), and the compounding path (independent reads → different pair content →
different claims → different verdicts). Which dominates is a design question, parked below.

## The 50-stretch number, from the sharded verify

`shardCount=2` split the plain bucket into two concurrent shards. The verify STAGE wall (max of
the three concurrent calls):

| run | plain shard 0 | plain shard 1 | sentiment | verify stage |
|---|---|---|---|---|
| s1 | 14.8 s | 14.6 s | 9.1 s | **~14.8 s** |
| s2 | 15.6 s | 15.4 s | 6.6 s | **~15.6 s** |
| s3 | 23.8 s | 15.5 s | 12.8 s | **~23.8 s** |

Verify dropped from h1's single-bucket 20.8 s to ~15 s under sharding (s3's 23.8 s is one shard
running long, itself part of the call-3 variance above). **But the 50-stretch was not cleanly met
this batch, and the reason is read variance, not verify:** the reads ran 27-43 s here against
h1's 27 s, and a 40 s read dominates any verify saving. Totals were 69-83 s. **With h1-typical
27 s reads the sharded graph lands ~52 s** (27 reads + 5 resolution + 15 verify + 5 join/proj);
the read-time variance is now the gating factor for the stretch, and it is the same variance the
flicker table is made of.

## What held (the free traps, every run)

Bytes exact and the demo-narration trap held on all three runs; no fictional designator or map
row appeared in any of them. Ledger HELD 3/3. The flicker is entirely in WHICH true things get
established, never in fabrication - the machine is unstable about what it affirms, never unsafe
about inventing.

## Parked for the next design session (working mode: not answered here)

- **The flicker is a design question, not an execution one.** Options with their costs, for
  design to weigh: (a) lower/zero call-3 sampling temperature, cheap, may not fully settle a
  blind reader; (b) N-of-M verify voting per claim, a real token cost and the exact thing the
  halving fought; (c) accept run-to-run flicker and define the product around a stability
  threshold, which is a methodology choice. Not built, not chosen.
- **Read-time variance (27-43 s)** is now the express-lane stretch's gating factor and a scaling
  input; it wants its own measurement (is it output-token variance, gateway latency, or thinking
  budget?).
- The buyer-role collision (thirty-second stamp item 3) is already Matthew's open call; this
  probe adds that Adam's role is HELD (collision) in all three runs, so the collision itself is
  stable even as his Status flickers.
