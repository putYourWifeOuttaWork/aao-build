# em0807-a22 · stage timings and governors

Unit: milliseconds wall per callout, and governor consumption per stage. Ceiling 120,000 ms
cumulative per transaction, unraiseable, shared across certified managed namespaces.

| stage | txn | callouts | wall | % of ceiling | SOQL | DML |
|---|---|---|---|---|---|---|
| call 0 · resolve | 1 | 1 | 12,160 | 10% | 6/100 | 0/150 |
| call 1 · Sentiment | 2 | 1 | 12,861 | 11% | 2/100 | 1/150 |
| call 1 · Political Status | 3 | 1 | 15,674 | 13% | 2/100 | 1/150 |
| call 1 · Buyer Role | 4 | 1 | 16,242 | 14% | 2/100 | 1/150 |
| call 1 · Decision criteria | 5 | 1 | 17,857 | 15% | 2/100 | 1/150 |
| call 2 · identify | 6 | 1 | 18,627 | 16% | 4/100 | 1/150 |
| call 3 · verify, batch set 1 | 7 | 12 | 47,189 | 39% | 2/100 | 1/150 |
| call 3 · verify, batch set 2 | 8 | 12 | 51,104 | 43% | 2/100 | 1/150 |
| call 3 · verify, batch set 3 | 9 | 12 | 50,142 | 42% | 2/100 | 1/150 |
| call 3 · verify, batch set 4 | 10 | 7 | 36,029 | 30% | 2/100 | 1/150 |
| join | 11 | 0 | no callouts | — | **55/100** | **81/150** |
| projection | 12 | 0 | no callouts | — | 9/100 | 3/150 |

**WORST SINGLE CALLOUT: 18,627 ms** (call 2) — 16% of the ceiling.
**WORST TRANSACTION: 51,104 ms** (call 3 batch set 2) — 43% of the ceiling.

## The bulkification, priced

| | a21, before | a22, after |
|---|---|---|
| eligible pairs | 17 | 18 |
| join SOQL | **100 of 100** | **55 of 100** |
| SOQL per eligible pair | ~5.9 | ~3.1 |
| pairs before the ceiling | ~17 | **~32** |

**Roughly a doubling of headroom, and it did not remove the ceiling.** The join breaks at about
thirty-two eligible pairs rather than seventeen.

**DML IS NOW CO-BINDING AND WAS NOT PRINTED BEFORE.** 81 of 150 at eighteen eligible pairs is
~4.5 per pair, so DML also runs out at about thirty-three. Bulkifying the reads moved SOQL to
where DML already was; the two now break together, which means **the next lever is the
caller-side split rather than another read-side fix**, because no amount of read bulkification
moves a DML wall.

## Call 3 is the widest transaction

Four batch sets rather than three, because **batches are now homogeneous by family** so the
conjunct can ride the batch schema. That costs a partial batch at each family boundary and buys
a structural guard that is otherwise reachable only on the single-claim path.
