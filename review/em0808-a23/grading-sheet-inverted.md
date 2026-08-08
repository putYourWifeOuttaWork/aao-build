# Grading sheet · run `em0808-a23` · INVERTED · for Matthew

**Fixture: the 29 July Emerson/AspenTech call, 20 minutes, three speakers.** This is the first
transcript nothing was calibrated against. Its numbers are the real ones; the 17 June numbers
are not, and never will be again.

> **INVERTED METHOD. Do Part 1 before you read Part 2.** Part 2 is our answers and it is below a
> deliberate break. Reading it first makes recall ungradeable, permanently, on the only unseen
> Emerson fixture we have. There is no answer key for this call and there cannot be one after
> you have seen ours.

---

# PART 1 · Before you look at anything of ours

Read the transcript (Source `a1XWD0000081H5R2AU`, or the 29 July recording). Then answer these
from the call, not from the deal.

## 1 · Who is on the buying committee, and what is each one?

For every person the call gives you evidence about — **including people who are discussed but
not in the room** — write the person and what the words establish.

| person | on the call? | what the call establishes | your confidence |
|---|---|---|---|
| | | | |

## 2 · What are the decision criteria?

Every condition, capability or outcome that has to be true for this deal to proceed. Name each
one **the way you would want it to read on the map**, which is the thing we cannot currently
produce and need you to define by example.

| criterion, as you would name it | formal or informal | required? | who voiced it |
|---|---|---|---|
| | | | |

## 3 · Sentiment

For each person who voices a stance toward us or our solution, where do they sit on the five
states, and on which words?

| person | state | the words |
|---|---|---|
| | | |

## 4 · The count that matters

**How many establishments should this call produce in total?** One number, your judgment.
This is the denominator for recall on unseen speech, and it does not exist until you write it.

Your number: ______

---
---

# PART 2 · What we produced

**Stop here if Part 1 is not filled in.**

We located 35 pairs, identified 28 to a person, and upheld 10.

## 2A · The ten upheld establishments · grade each TRUE or FALSE

| # | person | contract | reads as | offset | the words |
|---|---|---|---|---|---|
| 1 | **Wendy Higley** | AAO_BR_EVAL | Evaluator | 5566 | "If you want to pull up the terms and conditions, let me make sure those align. The binding effects, that's the same." |
| 2 | Ryan Couture | AAO_BR_USER | User | 18731 | "I'm looking forward to getting into the sandbox and start to build this out." |
| 3 | Jefferson Vargas | AAO_DC_N | a criterion | 5236 | "the only thing that's really of substance is the entity name, and I know that that will stop the car because there needs to be alignment there" |
| 4 | Jefferson Vargas | AAO_DC_R | required | 5236 | same words as 3 |
| 5 | Jefferson Vargas | AAO_DC_F | formal | 5857 | "typically speaking, legal does not like to have embedded links in the Ts and Cs, but I'm waiting for them to confirm on that" |
| 6 | Jefferson Vargas | AAO_DC_N | a criterion | 6956 | "in order for us to get to PO ... we're going to need to have clean versions of all three, the MSA, the SOW, and the order" |
| 7 | Jefferson Vargas | AAO_DC_R | required | 6974 | same words as 6 |
| 8 | Jefferson Vargas | AAO_DC_R | required | 9783 | "with this dollar amount, it's going to go to CFO ... that's where we've seen roadblocks in the past" |
| 9 | Jefferson Vargas | AAO_DC_F | formal | 9783 | "with this dollar amount, it's going to go to CFO" |
| 10 | Ryan Couture | AAO_PS_1 | Supporter | 18704 | "I'm looking forward to it ... there's been more and more of an ask on that relationship map and on the insights." |

Grade: __ TRUE, __ FALSE. **Row 1 is the one we already believe is wrong** and it is on the sheet
ungraded rather than removed, because your grade is the record.

## 2B · Three questions we need ruled, not just graded

**Q1 · Wendy Higley is our own seller and she is now a Contact on Emerson Electric Co.**
Row 1 above established a Buyer Role about her; projection created
Contact `003WD00001QZE73YAH` and put her on the buyer's relationship map. Nothing in the system
asks whether a claim's subject is on the buying side — `internalDomains` only identifies which
seller HEARD a claim. On 17 June the same two pairs were identified to Wendy and Renee Martin
and call 3 happened to refuse them, so the correct outcome was luck.

*Owed from you:* is "a claim's subject must be buyer-side" a law we build, and does it refuse at
identification, at the claim, or at projection? And what happens to the Contact we already
created.

**Q2 · The vendor object is displaying the word "CRITERION" to the seller.**
`ALTF__Decision_Criteria__c` on this opportunity reads `Subject = "CRITERION"`. The naming
proposition's meaning enum has exactly one value, the label, and we are writing the label where
the criterion's text belongs. Every criterion on an opportunity therefore keys to the same row.

*Owed from you:* your Part 1 answer to question 2 above IS the specification. A criterion needs
a short name a buyer would recognise, and only the charter can emit one. Your names tell us what
the field should hold.

**Q3 · Seven establishments were found and dropped because the person was not in the room.**
Among them:

| what was found | the words |
|---|---|
| who signs | "I believe Fatima will be the one signing it, yes." |
| who approves at this amount | "Because with this dollar amount, it's going to go to CFO" |
| pre-approval already given | "I think that he's aware of and approves of it. So he reviewed as far as she knows" |
| the real approval gate | "once that goes through Koopa ... that will be the approval that makes the determination" |

**Fatema Choudray is the person whose Political Status you set by hand to Inner Circle.** This
call names her as the signer and we dropped it, because a mentioned person has no participant
row and the shadow-creation path is not built. On the 17 June call this happened zero times out
of 44 pairs. On this one it is 7 of 35.

*Owed from you:* does the shadow-person path move up the queue, and does People close with it
unbuilt.

## 2C · What we are not claiming

**Recall is not measured.** Your Part 1 number is the denominator and we do not have it yet.
Precision is gradeable from 2A today. Our regression set does not reach this artifact at all —
all 39 assertions are keyed to 17 June or B&V — so nothing here is defended by it.
