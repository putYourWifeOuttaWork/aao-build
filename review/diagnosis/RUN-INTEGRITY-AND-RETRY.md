# The run-integrity guard, the varied retry, and the panel confirm

CODE, 21 August. The 178th's items 4, 3 and 2(ii).

## Item 2(ii), answered first because it is a one-liner: the panel is right

**The panel reads the deal's answers correctly, and the 16 is a cross-family count.**

```
DEAL 006WD00000TzLlQYAV  stage=Discover  ordinal=2
ALL live answers = 16  |  Process-family = 4
the 16 live answers by family: {null=7, Problems=5, Process=4}
PANEL readings = 3 -> (AAO_BANT_N2, AAO_BANT_N1, AAO_BANT_A3)
```

The four Process answers are N2 twice (two subjects), N1 and A3 - **three distinct questions**,
which is exactly what the panel shows established of fifteen. So "16 standing answers but
qualifiers not completed" is neither panel timing nor a read miss: sixteen counts every family,
and only four of them are Process. **Not a ninth specimen.**

## Item 4, the finding that outranks the error: the run-integrity guard

Call 0 answered `d6` - a sibling deal - reasoning from "the largest overlap of participants." The
demo kit reuses one cast across sibling deals, so overlap is a TIE, and the model breaks it
toward the deal with more history, which is systematically the older one and systematically the
wrong one.

**The paste path knows the deal by construction**, so a resolver disagreement is not a judgment
to defer to - it is a contradiction to refuse. The guard compares the resolved deal against the
SOURCE'S OWN and throws with both names:

> Call 0 resolved this call to "X" but the transcript arrived on "Y". A run whose evidence and
> answers would land on two different deals is the split-brain shape, and it stops here rather
> than routing.

**No silent coercion.** We do not quietly re-point the run at the source's deal. The model
believed something false about this call, and that is worth stopping for - a run that corrected
itself invisibly would leave nobody knowing the resolver is broken on sibling deals.

The refusal names both deals because a refusal that does not say what it disagreed with cannot be
acted on.

## Item 3, the call-0 hardening: the retry asks harder rather than asking again

Design's preferred remedy was structured output. **Call 0 already uses it** -
`output_config.format` with a json_schema - and the pathology happened anyway, because the
garbage landed INSIDE the quote string rather than after the JSON. So neither structured output
nor "take the first well-formed JSON value" reaches it: both were already satisfied by a response
that was well-formed and wrong.

Remedy (b), trimming the quote to its longest locating prefix, was considered and **refused**. A
prefix that locates is genuinely verbatim, but "we will not renew" has a locating prefix that
means the opposite of the sentence. Repairing a polluted quote by truncation is exactly the
damage the citation law exists to prevent.

So remedy (c), which is design's own instrument law turned on the retry: **an identical retry
against a deterministic pathology is the instrument reading its own fingerprints.** Both attempts
produced the same shape for the same reason. The second attempt now escalates EFFORT - call 0
inherits the read class's `low` from `inventorySpec`, and the 141st measured three quote-law
violations in fourteen at low against none in four at high. The retry asks harder rather than
asking again.

**Named as a limit rather than a claim:** four high-effort samples are not proof that high effort
fixes this, and this is a variation, not a cure. What it guarantees is that the second attempt is
a different question - which the first retry policy never was.
