# The cold-start module

CODE, 21 August. The 173rd's items 3 and 4, built to Matthew's bar: no human step between
creating a deal and reading the result.

## The gate, answered before a line was written

The 173rd put one read ahead of everything: **can we create the wrapper at all?** It was already
answered at the 168th confirm and the evidence stands in the org - `a0yWD000001ehwvYAA`, created
by us from Apex on a deal that had none, and furnished by the vendor exactly as it furnishes its
own. **Outcome (a): the cold start is ours end to end**, and the bar is reachable as written.

**My own probe had left the gap the ownership law exists to catch.** That wrapper was not in
`AAO_Created_Row__c`. I created a row on a vendor object and did not enumerate it, which is item
4(v) exactly. Recorded now, describing the act I performed. The lesson is small and sharp: **the
ownership law is easiest to break in a probe**, because a probe feels like it does not count, and
the row it leaves behind counts as much as any other.

## What it does, proven on a deal that had nothing

```
BEFORE: wrappers=0
RUN 1: wrapperCreated=true planAssigned=true process=AAO New Business (Sandbox)
       stage=Qualify ordinal=1 rubric=15 questions/15 qualifiers
RUN 2: wrapperCreated=false planAssigned=false | "This deal already carries a plan."
wrappers now = 1 | enumerated = 2
```

A deal with no wrapper and no plan ends with a wrapper, a process, a first stage, a live ordinal,
and **its rubric resolved for that deal** - fifteen assessment questions from the plan type,
fifteen qualifiers from the process's stage junctions. Second run writes nothing.

## The four refusals, each a ruling rather than caution

**It never chooses a process.** Resolved from the deal's Type through the vendor's own mapping,
read per org and per run. A Type with no mapping is refused BY NAME so a reader can fix the
mapping instead of guessing what went wrong:

```
RUN 1: ... | This deal carries no Type, so no plan can be resolved through the vendor's
             mapping. Nothing written, and nothing guessed.
```

And a deal we cannot plan gets **no wrapper either** - creating one for a deal we then refuse to
plan would leave a shell we made for no reason.

**It never re-assigns a standing plan.** Whoever assigned it, it is theirs.

**It never repairs a de-linked wrapper.** A wrapper that lost its process on a stage advance (the
166th) is a different state from one that never had a plan, and the deal's own field history is
the witness that tells them apart. Re-writing it would paper over the vendor's behaviour with our
guess about what it meant.

**It never moves a stage on a planned deal.** It writes the FIRST stage onto a deal with no plan
at all, which is what opening the vendor UI would have done, and nothing else ever. Advancing is
the seller's act through the gate, which is the whole point of the gate.

## What the bar still needs

This is the plan half - the part that was unbuilt and blocking. The rest of the bar (the persona
cast standing, People/Problems/Politics, the projections, Process reading the projected state,
the second projection) is the pass itself, and it needs the cold start wired ahead of call 0 so a
transcript on an unplanned deal plans it first. **Named rather than implied: the module exists
and is not yet called by the pass.**

## CLOSEPLAN's premise, checked before minting

The 159th ruled MINT on the grounds that call 4 carries the evidence. Verified against the actual
transcript rather than taken on trust, because a proposition nothing answers is the permanent
grey row the mint was chosen to avoid:

> **ingrid**: *"Then here's what has to happen between now and a signature, and I want it written
> down and shared, not living in anyone's head."*
> **sam**: *"I'll turn that into a shared close plan today, one page, both companies' names on
> the steps..."*

Ingrid's line is CLOSEPLAN's question almost word for word. The premise holds and the mint will
be answered.

---

# The pass now leads with the cold start, CLOSEPLAN is minted, and I broke my own law

## Wired

`S_COLD_START` is the pass's FIRST stage, ahead of call 0, with its own receipt leg. A transcript
arriving on a deal that has never been opened in an Altify surface plans it before anything is
asked of it, because every stage after presumes a rubric exists. On a planned deal the stage
costs one query and says so.

## CLOSEPLAN, minted through the seed

The fourteenth qualifier is the only one with no BANT equivalent, ruled MINT at the 159th. Now
`AAO_BANT_C1`:

```
C1 criterion:    The close plan is described and shared
C1 proposition:  Have the steps between now and signature been described, and shared with the
                 customer rather than kept on our side?
marker for C1 = 4.0        bindings now = 14
```

**Two elements, because the qualifier's own text is a conjunction** - described AND shared. A
close plan written down and never sent is precisely the failure the question exists to catch, and
one element would have let it pass. The by-stage marker is **Propose (4)**, the EARLIER of the two
stages CLOSEPLAN is resident at, because a qualifier asked at Propose is already being asked when
the deal reaches Propose whatever else asks it later. Speaker requirement is **Any**, per
Matthew's ruling that internal-team statements are evidence: the seller saying *"I'll turn that
into a shared close plan"* is the act the question asks about.

**Fourteen of fourteen are now bound.** `unbound 0`.

## The seventh recognition specimen, and it is mine

Binding the fourteenth surfaced this in the same run:

```
held for a human 7 | Held for a human on PEOPLE1: the comment is not ours. | ... MAPPED ...
DMINSIGHT ... CRITERIA ... CHAIN ... SUPPORT ...
```

**Six rows this writer created, read back as a human's prose and frozen.** The computed plane
ships a NEW comment shape - plain state citations like *"All 2 named approvers stand on the
map"* - and I did not teach the ownership predicate to recognise it.

**I wrote the law two turns before I broke it:** *"a format and the predicate that recognises it
are one mechanism in two places, and they move together or they lie."* Then I shipped a format
and left the predicate behind. Nothing errored. Six rows simply stopped being ours.

The fix has two halves and the second is the interesting one. Going forward, state citations
carry the canonical separator and say which plane produced them - `Computed from the ledger ·
All 2 named approvers stand on the map` - which a reader wants anyway, because "computed from
rows" and "somebody said this" are different kinds of evidence. But that only fixes what we write
NEXT, and the six were frozen by what was already stored. **Teaching `ours()` to accept plain
sentences would have made every human comment look like ours, which is the wrong direction to be
wrong in.** So the repair is exact instead: a stored comment byte-for-byte identical to the
sentence this computation produces right now was produced by it. The frozen rows repaired -
`updated 6` - and the predicate did not loosen by a single character.

Idempotent after: `unchanged 12, held for a human 1, unbound 0` - the one held row being
Matthew's WHEN1, untouched as it has been throughout.
