# AAO Sandbox Build Brief — for Claude Code

> **The version lives on the stamp line below and nowhere else.**

**v1.1 · 2 August 2026 · target org `altify--aossb2` · three dangling pointers repaired, and the rule that stops them recurring**

**Changed in v1.1, and it is a repair rather than an addition.** `docs/aao-corrections-v1_0.md` was deleted under the one-live-copy rule and **this file pointed at it in three places, one of them claiming precedence over everything else in the repo.** CODE found one of the three. **A pointer to a deleted file that claims authority is worse than a stale copy**, because a reader who follows it finds nothing and cannot tell whether the authority moved or was withdrawn.

**All three are repaired below and the old text is marked wrong rather than quietly replaced:** the read order, the repo layout listing, and the closing paragraph of *what is known to be missing*.

**The root cause is this file's referencing style, not the deletion**, and that is the part worth fixing. **This file named documents by a version embedded in a filename.** Paths are frozen at their original names and the version lives on the stamp line inside, so a filename is a locator and never a version — which means every reference of the form *corrections v1.0* was going to rot at the next bump whether or not anything was ever deleted. **References below now name the document and its role, with the filename as a locator only.**

**Also corrected: the last line of section 7 was wrong twice over.** It said the four project documents still carry the old vocabulary where Claim meant the current-state row. **The Glossary has since landed the Answer / Claim correction**, so that sentence is stale about the Glossary and it named the wrong file as authoritative in the same breath.

**And a distinction that was never written down, which is why this drift was invisible.** **The project keeps every version; `docs/` keeps exactly one.** The project is the archive and is supposed to hold retired versions. `docs/` is CODE's read-reference and holds one live copy per document, superseded ones deleted. A file existing in the project and absent from `docs/` is correct and expected. **The reverse is not**, and it happened at least once: the demo run sheet lived in the repo from session 16 and never reached the project at any version.

**v1.0 · 31 July 2026 · target org `altify--aossb2`**

This is the instruction set for the coding agent. It is written to be read **cold**, by an agent that has none of the conversation this design came out of. Everything it needs is either in this file or in the repo it creates.

---

## 0 · Read this order, first, every session

**Read the stamp line inside each file, never the filename.** Paths are frozen at their original names so that pointers between documents do not rot; the version is on the stamp line and nowhere else. A file called `v0_8` routinely holds `v0.13`.

1. `BUILD_JOURNAL.md` — what has already happened, what was verified, what is owed. **Always first.**
2. **The corrections and change record** — `docs/aao-corrections-v2_0.md`. **Where this disagrees with anything else, it wins**, including the four project documents, until each of them is bumped past it.
3. **The field tables** — `docs/aao-field-tables-v0_8.md`. Closed field tables, one section per object.
4. **The charter design** — `docs/aao-charter-design-v0_1.md`. The charters, the shared output envelope, and the recovered ontology. *(If this file is not in `docs/`, say so rather than proceeding without it — the ontology assembler was built from it.)*
5. **Flags and guidance** — `docs/aao-flags-and-guidance-v1_0.md`. Flag's fields and trigger law live here and not in the field tables.
6. This file.

> **Marked wrong, from v1.0.** Item 4 of the old read order was `docs/aao-corrections-v1_0.md` — *the Answer/Claim correction. Where this disagrees with anything else, it wins.* **That file is deleted.** The authority did not lapse; it moved to the corrections and change record above, which contains the Answer / Claim correction in full along with everything ruled since. The old ordering also put the corrections record fourth, behind the field tables, while describing it as beating everything — **it is first among the documents now, which is what that sentence always meant.**

---

## 1 · The build journal, and why it is not optional

**A future agent will open this repo with none of the context that produced it.** Git will tell it what changed. Git will not tell it why, what was tried and abandoned, what the org actually said when it was queried, or what is still owed. **The journal carries what the diff cannot.**

This is the project's own standing rule applied to code: corrections go into documents, versioned, stating what changed and marking what was wrong as wrong. Nuance held only in a chat window evaporates, and a coding session is a chat window.

**`BUILD_JOURNAL.md`, at the repo root. Append-only.** The only part ever rewritten is the `## Current state` block at the top, which is a short answer to *where is this right now*. Everything below it is chronological and never edited, including entries that turned out to be wrong — those get a later entry saying so, never a deletion.

**Every working session appends one entry, even a session that achieved nothing.** A session that failed and recorded why is worth more than a session that succeeded silently.

```markdown
## 2026-07-31 · session N

**Did.** What was created, changed, deployed. One or two lines; the diff has the detail.

**Decided, and why.** The part the diff cannot show. Any choice between two workable
options, with the reason. If nothing was decided, say so.

**Read from the org.** Anything learned by querying `altify--aossb2`, quoted verbatim —
field names, picklist values, row counts, error text. This is evidence and it is the one
thing that cannot be re-derived by reasoning. Never paraphrase an error message.

**Assumed, not verified.** Anything believed but not checked against the org. This list
is how the next agent knows what to distrust.

**Owed.** What the next session must pick up. Carried forward until done.
```

**Two rules that keep it honest.** Anything read from the org is quoted, never summarised, because the standing ruling is evidence over inference *including about our own schema*. And anything assumed is written in the assumed list rather than stated as fact anywhere else, because an assumption recorded as a finding is how a wrong belief becomes load-bearing.

---

## 2 · Repo layout

```
aao-sandbox/
  BUILD_JOURNAL.md            ← read first, append every session
  MANIFEST.md                 ← what is in docs/ and what each is authoritative for
  README.md                   ← 10 lines: what this is, the read order above
  docs/                       ← the design. Copied in, not linked.
                                One live copy per document; superseded versions deleted.
                                Filenames are locators. The version is inside.
    aao-corrections-v2_0.md
    aao-field-tables-v0_8.md
    aao-charter-design-v0_1.md
    aao-flags-and-guidance-v1_0.md
    aao-demo-runsheet-v1_2.md
    aao-code-build-brief-v1_0.md
  force-app/main/default/
    objects/                  ← metadata as source, one folder per object
    triggers/
    classes/
  seed/
    rubric/                   ← the mini-rubric, as data
    transcripts/              ← dummy transcripts, frozen once written
    expected/                 ← ground truth for the exit test
```

**The docs folder is copied into the repo, not referenced.** The repo has to be self-sufficient, because the whole point is that it survives being opened somewhere else with nobody remembering to bring context along.

> **Marked wrong, from v1.0.** The listing carried `aao-corrections-v1_0.md`, deleted. It also omitted `MANIFEST.md`, which exists and is the thing a cold reader would open second.

**`docs/` holds one live copy per document. The project holds every version.** They are different stores with different jobs and neither is a backup of the other. **A document in the project and not in `docs/` is ordinary.** A document in `docs/` and not in the project is a fault, and it is how the demo run sheet sat in this repo from session 16 without existing anywhere else.

---

## 3 · Standing constraints — these are not negotiable

**Production is read-only, unconditionally.** Nothing in this repo ever authenticates to a production org. The only target is `altify--aossb2`.

**No Apex triggers on any object we do not own.** Not Opportunity, Account, Contact, Task, Note, Attachment. Change detection on customer objects is polling by `SystemModstamp` against a stored watermark. Triggers exist only on `AAO_` objects.

**No field is ever added to a managed `ALTF__` object.**

**Evidence over inference about schema.** Facts about the org come from querying the org. If a field cannot be justified by naming the process that reads it and the process that writes it, it is invented and does not ship.

**A capability claim is unverified until it has been tried from the runtime that will make the call**, not from whichever tool was convenient. Three design sentences about our own reach have been wrong in the same direction — Coverage as a frozen query, `required` on Source, and the labels by pattern query — and each was a true fact generalised to a place it did not hold. *Added in v1.1; the law is ruled in the corrections record.*

**Prefix `AAO_` on every API name.** The endgame is a 2GP sharing the `ALTF` namespace so our Apex can call Altify's non-global classes directly. `AAO_` now is the prove-it-first choice and a later rename and redeploy is an accepted cost. **Do not optimise against the rename.**

**Nothing a model writes is trusted yet.** Schema and deterministic plumbing build now. Anything a charter writes stays governed by Gate 1's bar, and no model-written verdict is treated as trustworthy until test round two clears. *(Round two has since cleared: twelve of twelve on outcomes, eleven of twelve on proposals, zero hallucinated spans. The bar stands for everything after it.)*

---

## 4 · Build order

**Step 1 — connect and scaffold.** `sf org login web --alias aossb2 --instance-url https://test.salesforce.com`, then `sf project generate`, metadata as source, deploy with `sf project deploy start`. **Record the org id, API version and the exact CLI version in the journal.**

**Step 2 — the five objects the exit test needs.** `AAO_Source__c`, `AAO_Evidence_Contract__c`, `AAO_Candidate__c`, `AAO_Answer__c`, `AAO_Claim__c`, plus `AAO_Claim_Basis__c`. Field tables are in `docs/`. Flag is closed but **not in the replay path**, so it follows.

**Step 3 — the four trigger laws.** Source immutability and the frozen scope-key composer. Answer's frozen key composer, the write law, and `DUPLICATE_VALUE` caught as a merge path rather than an error. Claim insert-only. Flag type immutable.

> **The two key composers are the highest-risk code in this build.** Both are deterministic, frozen, versioned, single-writer, and case-sensitive. Neither is a formula field, because a formula recomputes on read and would silently change meaning under a schema change. **Write the unit tests for these before the composers**, including how an unpopulated lookup renders — empty against a literal, and two rows that should collide stop colliding.

**Step 4 — seed the mini-rubric.** Section 5.

**Step 5 — the accumulation test.** Section 6.

---

## 5 · The mini-rubric

**A Developer sandbox copies metadata, not data, so the org's rubric tables are empty.** That is the feature: day one becomes a per-org discovery test against a rubric that is not Altify's production one. **The standing hazard, rehearsed.**

Six propositions of our own, spanning all three routes. Author them into the org's own rubric records so discovery walks its real path.

**Worked example, and the one the exit test runs on:**

```
Code:            AAO_T1
Short:           Budget Confirmed
Proposition:     The customer's decision maker has confirmed that budget is secured
                 for this initiative in the current fiscal year.
Guidance (Help): Budget is confirmed when a decision maker states that funds are
                 approved, that they are allocated to this initiative specifically,
                 and that they are available in the current fiscal year.
Route:           E (evidence only)
Elements:        e1 funds are approved
                 e2 allocated to this initiative specifically
                 e3 available in the current fiscal year
Elements_Basis:  Authored   ← the guidance text names all three, so no human ratifies
Speaker req:     Decision_Maker_Or_Influencer
Decay class:     Event
Gating:          true
Per_Person:      null
```

**Note what this exercises deliberately:** the guidance text names its own parts, so element resolution is a read rather than an inference, and `Elements_Basis` is `Authored`. That is the path we want to be the main path.

**The other five, specified rather than written out.** One route P (a predicate over map state, no model — *the decision team is identified*). One route C (charter reading transcript plus committed state). One with `Per_Person_Source` populated, so the per-person count and the empty-set guard are exercised. One with `Elements_Basis` deliberately `Inferred_Pending`, so the ratification path is exercised. One non-gating, so day-one red is not the only behaviour tested.

---

## 6 · The dummy transcripts and the exit test

**We write them, so ground truth is known by construction.** Both are `Attributed` diarization. **Freeze them once written** — a transcript edited after a span was verified against it breaks the citation chain, which is the exact failure immutability exists to prevent.

**Roster.** Dana Ruiz, VP Operations at the customer, mapped Buyer Role = Decision Maker. Priya Shah, seller. Domain split does the buyer/seller derivation; no platform labels.

**Transcript one — partial.** Dana states funds are approved and allocated to this initiative, and explicitly does not commit on timing.

```
priya    So on the money side, where does this stand?
dana     The funding is approved. It came out of the operations modernisation pot,
         so it is earmarked for this project specifically, not a general pool.
priya    That is helpful. And is that this year's money or next?
dana     That I cannot tell you yet. Finance is still working through the calendar.
```

**Expected after transcript one.** Coverage: e1 and e2 covered, e3 not. **Partial coverage → the answer is written `UNVERIFIED`, carrying the spans that exist.** One claim, verdict before null, verdict after `UNVERIFIED`, basis `Transcript`, actor `MACHINE`. **Dana is the mapped decision maker, so the speaker requirement is satisfied** — the same words from Priya would have failed it.

**Transcript two — completes it.** Eleven days later.

```
priya    Did finance land on the timing?
dana     They did. It is in the current fiscal year, confirmed last Thursday.
         The budget is approved and sitting against this initiative, so we are
         clear to proceed this year.
```

**Expected after transcript two.** e3 now covered, so **coverage is complete and the answer flips to `TRUE`**, carrying spans from both sources. **A second claim**, verdict before `UNVERIFIED`, verdict after `TRUE`, its own singular Source lookup pointing at transcript two. The first claim still says `UNVERIFIED` and is untouched.

### The exit test, precisely

1. **Two claims exist**, ordered by `AAO_Evidence_Occurred__c`, eleven days apart. Not by processing time.
2. **The first claim still reads `UNVERIFIED`.** Nothing edited it. This is what makes progress visible.
3. **The answer reads `TRUE`** and its accumulated spans include quotes from both sources.
4. **Every span byte-verifies** against its own Source's normalized text, and every span is contiguous inside a single speaker turn.
5. **Replaying claims in evidence-occurred order reconstructs the answer exactly.** Rebuild from an empty mirror; the result must be identical field for field.
6. **The candidate ledger is complete** — every proposition considered on each pass has a row, including the ones nothing was said about, carrying `nobody_said`.

**Passing this demonstrates incrementalism in an org rather than in an argument. That is the sentence Toby gets.**

### Also worth running, cheaply

**A negative case:** the same words as transcript two, spoken by Priya instead of Dana. Expected: the speaker requirement fails, and it writes `UNVERIFIED` with receipts rather than `TRUE`. This is the ruling that regraded Gate 1 run two, and it should be provable in the org in one run.

**An unsegmented artifact:** one transcript with no speaker turns at all, the Notion shape. Expected: it is stored with `Diarization = Unsegmented`, spans verify as contiguous substrings of the whole document, and **it cannot satisfy the speaker requirement on `AAO_T1` at all.** Otherwise we only ever prove the easy class.

---

## 7 · What is known to be missing

Recorded so a fresh agent does not mistake absence for oversight.

**Note Evidence's field table.** Ruled as its own object with the envelope shape — its words live in Source with origin `note`, and the object carries author, arrival, address and attempt sequence. Table is Wave 2.

**Guidance's field table.** Topology is settled; fields are Wave 2.

**Surfacing, delivery, dismissal mechanics and efficacy measurement.** Deliberately after the objects, in that order.

**A seventh memory table for the decision log.** Not built in the sandbox because nothing retires in the proof, but its stream category and clock lock at creation, so it is decided before any stream is made.

**Write-blocking customer constraints.** A customer requiring a mailing address before a contact may join a relationship map is a real, observed case. Discovery must read validation rules, required fields and record types alongside the rubric, as rule data on core — **not on the memory plane, because deciding whether a write will succeed cannot be a cross-plane read inside the write path.** A blocked write records itself as blocked with the rule named, and never throws.

**The four project documents are behind, and the corrections and change record is authoritative over them until each is bumped.** *Corrected in v1.1.*

> **Marked wrong, from v1.0.** This paragraph read: *Architecture, Glossary, Object Model and Data Flow still carry the old vocabulary where Claim meant the current-state row. `docs/aao-corrections-v1_0.md` is authoritative until they are bumped.* **Both halves are wrong now.** The named file is deleted. And **the Glossary has since landed the Answer / Claim correction in full** — Claim is the immutable establishment, Answer is the upserted current-state row, Claim Basis is the junction, and Journal Event is retired as both term and entity. The Glossary is behind for other reasons, chiefly its statement that a schema-sourced proposition has no authored sentence to find, which the label enumeration falsifies. **Read the corrections record for what is behind and why; do not carry a list of stale documents in this file, because that list is exactly the thing that goes stale.**

---

*End v1.1. The journal is the thing that makes this repo portable. Write it every session, quote the org verbatim, and carry the owed list forward. And name documents by what they are, never by a version in a filename.*
