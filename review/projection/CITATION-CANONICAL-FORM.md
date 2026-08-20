# The citation becomes a citation

CODE, 21 August. The 156th's items 3 to 6.

## What it writes now

```
Marcus Reyes · Brightwell — discovery, call 1 · 18 Aug 2026, 11:24 AM PDT · SRC-00000057 @2190-2236
"My best rep spends nine hours a week on admin."
```

Who spoke, which call, when it happened, where in it, then the words. Before, the same row read
`Marcus Reyes: "My best rep spends nine hours a week on admin."` - a span and an attribution,
with the source reference and the locator both absent, which is a quotation rather than a
citation.

**Landed once, in the shared helper.** The Process panel and writer (a) both consume
`AAO_ProcessPanel.readingsFor`, so both screens gained provenance together and cannot drift.

**The bulk join holds.** Measured on the rehearsal deal: **3 queries for 4 readings** - the
answers, the sources, and the org's timezone. Constant, not per-row; fifteen questions do not
become fifteen queries.

**Component rulings, each honored:** WHEN is `AAO_Evidence_Occurred__c`, never `CreatedDate`;
rendered in the ORG's timezone with the zone named, read once per transaction, because a
citation is durable and two readers must not see two times. WHICH CALL is
`AAO_Meeting_Title__c`, omitted rather than fabricated when blank. WHERE is the Source's own
`Name` plus the span's byte range. **No second identity was minted**, per item 4.

## Three things the build found that the stamp could not

**One: writer (a) was truncating mid-quote.** Design flagged its call site as mine to confirm
rather than assert. It called `r.citation.abbreviate(2048)`, which would cut a citation in half
and leave a sentence that reads complete and is not - the exact damage item 5 forbids. It now
omits an oversized citation and says so in its notes, because the note is a mirror and the
ledger holds every span regardless.

**Two, and this one nearly shipped silently: the format and the ownership predicate are one
mechanism in two places.** `heldByHuman` recognised our notes by the shape `: "`, which **the
new canonical form does not contain**. Every citation this product wrote would have been read
back as a HUMAN's prose - held from update forever and refused by the purge's retraction.
Nothing would have errored; the rows would simply have frozen. The predicate now recognises the
canonical separator and the pre-156th form both, with a test that pins all four cases. The
durable answer is a watermark rather than a shape, and that is a schema change on a surface
humans also write, not something to do in the same hour as a format change.

**Three: a citation with no source is not a citation, and the helper now refuses to emit one.**
A test fixture without a source exposed it: the renderer fell back to `who` plus the words,
which is precisely the quotation the stamp refused, reintroduced one layer down while looking
fixed. `renderCitation` returns null when no source resolves. The fixture was corrected to carry
a real source, because it had been testing a shape the product does not produce.

## The compact form

`Reading.compactCitation` drops the call title and the timestamp only:

```
Marcus Reyes · SRC-00000057 @2190-2236
```

For the map row's 1,024 characters shared across four dimensions. Nothing becomes unfindable;
the source short name walks back to both dropped components in one hop. **It is available and
not yet consumed** - the map-row writer still writes its own note, and moving it onto this is a
separate change to a separate writer, named here rather than assumed done.

## Migration, proven rather than promised

The two rows standing on deal 1 in the old form were recognised as ours by the legacy shape and
upgraded in place: `updated 2, held for a human 0`. No row was orphaned by the format change.

## A fourth thing, found by the full suite rather than by the class under change

`AAO_ProcessPanelTest` failed twice on `Same value: null` after the change, and it was right to.
Its fixture also built spans with **no `sourceId`**, so its answers now yield no citation - the
same shape the writer's fixture carried, in a test class the change did not touch. Both fixtures
now insert a real `AAO_Source__c` and reference it from the span.

**Worth keeping: a law that tightens what counts as evidence will break every fixture that was
quietly cheating**, and the breakage is the law arriving rather than a regression. Two fixtures
in this repository asserted a citation on an answer that named no call. Neither could have
existed in production, where a span comes from a source by construction.

Suite green apart from the standing non-AAO failure; writer (a) at 8/8 including the new
coupling test, the panel at 7/7.
