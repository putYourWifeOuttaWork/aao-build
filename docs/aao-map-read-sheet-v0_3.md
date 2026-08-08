# AAO Map Read Sheet · v0.3 · 5 August 2026

**v0.3, same day: the criteria expectation corrected for the join as built (the `ALTF__Decision_Criteria__c` write awaits the fifth-subject placement, so the criterion appears as an Answer with receipts, never in the vendor object on this run), and the Buyer Role collision note added. v0.2 added the step-by-step procedure.**

**For Matthew's user-read of the Emerson map after the Addendum 17 projection run. Inverted method: open the map fresh, read as a user, then check against this sheet. Keyed on the graded s1 set (adjudication sheet §9, Addendum 15); CODE's 27-assertion regression set is the authority where this sheet and it differ. Every establishment on the map must be an Answer row with a citation; words on the map with no citation chain are a defect regardless of whether they are true.**

---

## The read, step by step

1. CODE hands you the run id.
2. Open the Emerson AspenTech opportunity in the sandbox; bring up the relationship map and the related lists you added.
3. Walk the three buyer cards in order, Jefferson, Neeraja, Ryan, against the must-be list below. Click into evidence on every row you check; the verbatim words must be there.
4. Check every line of the must-not list.
5. Make one deliberate edit anywhere on the map and tell CODE what you touched; the watermark is verified from the journal, never from trust.
6. Anything that surprises you, in either direction, becomes one grade line: ref if it has one, quote if it does not, what you saw, True or False.

## Must be on the map

**Buyer Role · Evaluator, three people.** Jefferson Vargas (buq2, buq7), Neeraja Chimata (buq3, buq4, buq8), Ryan Couture (buq5, buq6). Each with citations to the verbatim quotes.

**Political · Jefferson** (poq1, the PS2 half upheld). Placement per the one-way-half contract; the citation carries the quote at offset 5634.

**Sentiment · Jefferson, counter at +2, moved by two mentor-grade establishments** (seq6, seq4). Ceiling is +3 mentor-grade; two moves from zero is +2. Each move journalled on its own side with its quote.

**Criteria · "Annual total cost," Jefferson, DC_N and DC_F Formal** (deq1/deq2, the q10 closure), present as the criteria Answer with receipts and citations. **On this run it does NOT reach `ALTF__Decision_Criteria__c`: the criteria write awaits the fifth-subject placement, so an empty vendor criteria object is expected, never a failure.** Grade the Answer and its evidence, not the object.

## Must NOT be on the map

- **Ryan Couture as SUPPORTER from "…Looking forward to it."** (seq11). Courtesy is not stance; this is the sixth graded trap. If it projects, the run fails regardless of everything else.
- **Renee Martin or Wendy Higley anywhere on the buyer side.** The domain fix is in before this run; sellers on the buyer map means the fix did not land.
- **Any partial criterion inside `ALTF__Decision_Criteria__c`** (deq3, deq4, deq5, deq6). Partials accrue with receipts and project nothing until elements complete. Their receipts should exist in the ledger; the criteria object stays clean.
- **A Buyer Role picked by the machine where two were established.** Where the pass establishes two roles for one person, the writer never picks: the field holds one-or-none, the note names the collision, and the count is reported. If you see a collision note, record the number; it is designed behavior, not a defect. An ordering, if you ever rule one, replaces this.
- **Anything account-grain, anywhere.** The backburner holds.
- **Any establishment without a citation.**

## May vary, and is reported, never silent

- **q9 · Neeraja · "Flexibility of Services Hours"** (the 2-of-4 recall specimen). Present: it projects as a criterion. Absent: the regression instrument reports it; absence is the known recall problem, not a projection defect.
- **poq7 / seq2** (one quote, offset 10348, Neeraja). Graded True by you, refused by call 3, under examination. Expect them absent from the map until that closes; their absence is recorded, not a new finding.
- Establishments outside the stable set may appear or not between runs; grade what you see on its own words.

## How to read as a user

Click into evidence on every row you check: the verbatim words should be there, byte-true to the call, with the source. Edit something and it must watermark; an edit that does not fire `humanEdited` is a defect. Anything that surprises you, in either direction, comes back as a grade line: ref if it has one, quote if it does not.

**NOT ASSERTED on this fixture:** the which-opportunity occurred-time window; anything account-grain. Numbers from BUILD_JOURNAL.

---

*End v0.3. Satellite, outside the audit chain; folds its findings into the adjudication sheet after the read.*
