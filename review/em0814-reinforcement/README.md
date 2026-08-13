# The eightieth stamp's queue · the reinforcement ruling and the identity ruling

**Org confirmed before anything: `00DWD00000DV7iT2AT`, "Altify", `IsSandbox = true`.** Production
untouched. Rows in `rows/`, correction scripts beside this file so every write is reproducible
from what it was derived from rather than from what a session typed.

**Authorizing bytes, quoted, per the receipt rule.** Eightieth stamp item 4: *"a claim reinforces
only where its spans intersect NO span already standing on the answer, compared within the same
Source. Any intersection, not only identity, and not only containment... THE RULING THEREFORE
BINDS AT BOTH GRAINS."* Item 5: *"the resolver gains a GIVEN-NAME RUNG... exactly one match LINKS,
more than one is AMBIGUOUS and holds, zero falls through. CREATE CONSERVATIVELY: A SINGLE-TOKEN
DESIGNATOR CAN LINK BUT NEVER CREATE."* Item 7: *"(a)... (b)... (d) the config-inventory status
confirmation, one line per item, riding any report."*

Item 7(c), the LOR contracts, **parks**: it builds *"on Matthew's plain-word yes on
`aao-politics-lor-draft-v1_0.md`"*, and the ledger records no yes. Nothing was built toward it.

---

## THE NUMBER IS TEN, NOT SEVEN, and the ruling's own test is why

The stamp says *"THE EXISTING SEVEN inflated counts on Emerson"*. Seven is what the 13 August
measurement found, and that measurement tested **identical** byte ranges. The ruling replaced
identity with **intersection**. Re-measured under the rule as ruled, in replay order:

```
answers                    20
Established                20    unchanged
Reinforced                 17  → 7     genuine second utterances
Corroborated (new)          -  → 10    the two reads finding one thing twice
```

The three the old count missed are exactly the shape design named when it chose intersection:
one read drew a wider boundary than the other around one sentence. Jefferson Vargas's
`AAO_PB_OBST` is the clearest — 9775-10048 against 9919-10048, the second quote a literal
substring of the first. **Design's own reason for preferring intersection over identity was
worth 43 percent more than the evidence that prompted it.**

## What was built

**1 · The answer grain.** `AAO_Accumulate.intersectsStanding` compares a claim's spans against
every span already standing on the answer, **within the same Source**, half-open ranges, the same
arithmetic the resolution stage's own merge uses so the two places that test overlap cannot drift
into disagreeing about what overlap means. `AAO_Commit` now branches three ways in the sixty-ninth
stamp's own priority order: COMPLETENESS (the words advanced the requirement → Established),
then CORROBORATION (the same words seen again → Corroborated), then REINFORCEMENT (new words for
a standing point → Reinforced). `Corroborated` is a new value on both restricted picklists and
`AAO_Accumulate.movesTheAnswer` treats it exactly as Reinforced: the claim is written, its spans
merge, the verdict does not move.

**Cross-Source needs no special case and that is not an accident of the implementation.** Byte
offsets are per-artifact, so claims from different calls never intersect and always count. That
delivers the rejected option (b)'s intent for free while keeping what (b) would have destroyed: a
person who presses the same point three times in one call did press it three times, at three
different offsets, and all three still count. A test pins that case by itself.

**2 · The card grain.** Layer 1 was `type + normalised verbatim`, an equality key. It is now the
byte range, scoped by type **and** by source, taken off the located row because the identified
disposition carries no offsets and the card carries none either — putting engineering numbers in
a customer-facing detail field would be the wrong trade, and the harvest is the source of truth
anyway. Standing cards are matched back to their pair through the verbatim they stored.

The range is claimed **immediately** on writing a card, before the next establishment is read.
The CFO pair was written in one batch from one harvest, so a check consulting only cards standing
before the run would have let it through again.

**Same type and same source are both load-bearing.** One utterance can carry an Obstacle and a
Goal, and those are two cards by construction: whether the Obstacle is a type error is Matthew's
grading question at item 6, and it is not this rule's to suppress. A test asserts the
non-suppression, so nobody later "improves" the rule into eating the specimen.

**3 · A defect found by reading the order, not by a run failing.** The writer deleted its
duplicates and *then* made the face callout — DML before a callout, which throws "uncommitted work
pending". It was wrong and unreachable at the same time, because the collapse almost never had
anything to delete while it only fired on exact repeats. Extending layer 1 to overlaps makes it
reachable on the very next Emerson write. The face call now runs before any DML in the method,
with the reason in the comment.

**4 · The given-name rung**, on `AAO_Identity` — the create-capable ladder — searching a bare
single token as a given **or** family name, scoped to the account and to the deal's map rows.
Standard three outcomes: one LINKS, more than one is AMBIGUOUS and holds, zero falls through. The
same map-row leg was added to `AAO_ResolveDesignator`'s single-token rung so the two ladders scope
it identically.

**5 · A single-token designator can link but never create.** Ladder-zero on one token HOLDS with
its evidence and its reason (`Single_Token` on the shadow row), with the toggle ON, because this
is a bar and not a configuration. This completes the twenty-fourth stamp's guard by that guard's
own logic: the point was always that only a real full name reaches creation, and the LastName
requirement was mistaken for a mechanism that guaranteed it.

**A hazard named in the header where a future session reads it: there are TWO ladders and only one
can create.** The given-name rung already existed on `AAO_ResolveDesignator` and not on
`AAO_Identity`, so the rung that would have looked was not on the path that mints. Any rung added
to either is now considered for both.

## The corrections, by rows, lawful path only

**The counts.** A claim is insert-only apart from retirement, so the mis-labelled row cannot be
edited to say Corroborated — and the ruling says in terms that *"both claims stand as evidence
with their own spans"*, so retiring alone would destroy what it protects. Both halves, in this
order: **write the replacement first** carrying the same evidence under the corrected outcome,
**then retire the original** with its reason. The trigger's own words license it: *"the evidence
still exists and can be read again into a new claim that says so on its own row."*

```
10 replacement claims inserted, outcome Corroborated
10 originals retired in place with their reason, never deleted
standing by outcome: Established 20, Reinforced 7, Corroborated 10, retired 10
answers by verdict:  TRUE 20        nothing downgraded, nothing lost
```

**The map did not move**: `rows/map-before.csv` and `rows/map-after-counts.csv` diff clean, byte
for byte.

**The card pair.** Re-derived through the writer's own collapse rather than deleted by hand, which
is the sixty-second stamp's ratified mechanism. `1 duplicate retired`; the elder card
(`a0pWD0000043HgMYAU`, the wider quote) stands, the younger (`a0pWD0000043HgNYAU`) is gone and its
placement cascaded with it. Board 10 → 9 cards, 9 placements. The cross-type pair
(`a0pWD0000043An0YAE` Obstacle / `a0pWD0000043An1YAE` Goal) stands untouched, as it must.

**The duplicate person.** Create-leg row `MK-00000022` marked disowned with its reason. Both
standing Fatima claims retired with theirs — *the words are sound and the subject is wrong*, which
is the narrow thing retirement says. Projection then retracted: the Fatima map row reads
`Signature Approver` no longer and carries *"Retracted Buyer Role: we established these and the
evidence no longer supports them. A blank field cannot say that, so it is said here."* The other
three Emerson rows are untouched at their 21:27 stamps.

---

## Three findings design does not have

### 1 · THE 27TH STAMP'S MERGE IS BUILT AND IS NOT ON THE DRIVEN PATH

`AAO_Resolve` — the deterministic resolution stage carrying the two-read merge, the designator
ladder, and the corroboration marker — **has zero callers in production code.** `grep` across
every non-test class returns nothing. The pass drives `AAO_Pass.identify`, which is the model call
over every located pair, and never the deterministic legs.

Measured, and it is unambiguous: **0 of 67 identified pairs across `em0813-stack-c1` and
`em0813-stack-c2` carry `AAO_Corroborated__c = true`.** Not a low rate. Zero.

The specimen is exact. `r1q10` and `r2q7` on the 29 July call both quote **8322-8371**, both read
meaning `SIGNATURE_APPROVER`, both name designator "Fatima" — same contract, identical bytes,
identical meaning. `AAO_Resolve.mergePlan` would have collapsed them into one canonical row marked
Corroborated. It never ran, so two pairs rode to call 3 and two claims landed on one answer.

**This does not weaken the eightieth stamp's ruling; it explains why the join was where the
damage showed.** The stamp is right that nobody priced the join. What is also true is that the
stage which would have caught it one step earlier is not wired in. The join-side rule is now
built and is the correct backstop either way, because same-bytes-DIFFERENT-meaning pairs are
*meant* to survive the merge and still collapse onto one answer. Nothing was built toward wiring
`AAO_Resolve`: that is a change to the pass's shape and it is design's.

### 2 · THE REBUILT LADDER DOES NOT LINK FATIMA TO FATEMA, and while the twin stands it links to the twin

Tried from the runtime rather than reasoned about. The rung matches **exactly**, as every rung on
that ladder always has, and the CRM carries `Fatema` while the transcript said `Fatima` — one
character apart. So the stamp's *"re-attaches if and only if the rebuilt ladder links it"*
resolves to: **it does not re-attach.** Fuzzy matching is not ruled and was not invented; a
resolver that guesses at near-spellings attaches a call's worth of evidence to whoever sorted
closest. **What actually closed this defect is the creation bar, not the rung.**

Worse, and measured: with the twin still standing on the account, the given-name rung resolves
"Fatima" **to the twin** (`resolved by single token as given or family name, within the account`
→ `003WD00001RCfLzYAL`). An aggressive matcher finds a minted duplicate exactly as readily as it
finds a real person. **The rung cannot un-make a duplicate; it can only stop the next one.**

Fatema therefore stands as the acceptance case *for the creation bar*. She is not an acceptance
case for the rung, and calling her one would be flattering the build. The rung's own acceptance
case is a lone token that matches a real given name, which is tested.

### 3 · DISOWNING AND PURGE-ENUMERABILITY ARE IN TENSION, and the code resolves it the other way

The stamp says the created Contact is *"MARKED AND DISOWNED... and enumerable for the sandbox
purge exactly because the record carries it."* `AAO_Purge` deletes machine-created Contacts
`WHERE AAO_Disowned__c = false`. **Marking the twin disowned makes the purge skip it.**

The code's reading is the twenty-first stamp's ruling verbatim: *"the Contact stays, marked and
reported as machine-created-and-disowned with its reason, and Matthew or the customer's admin
decides deletion holding facts we do not have."* Disowned means we stop touching it, deletion
included. So the purge filter is not a bug and it was not changed on a hunch. Design's phrase and
design's earlier ruling point opposite ways and one of them has to give.

**The twin's reach, measured before any disposition, because no delete on a vendor object happens
without it:** 1 map row, 2 card-contact links, 1 participant, 1 answer, and Contact carries 184
child relationships in this org. Nothing was deleted. If design wants the row gone in the sandbox
it is a deliberate one-off, not an automatic consequence of the mark.

---

## Timings and governors

No model call in this stretch except the card writer's one face call, which is its normal cost.

| leg | wall | SOQL | DML | callouts |
|---|---|---|---|---|
| count correction (10 replacements + 10 retirements + rebuilds) | one transaction | within ceiling | within ceiling | 0 |
| card re-derive | 6,925 ms | 7 / 100 | 1 / 150 | 1 |
| projection (retraction) | 1,029 ms | 22 / 100 | 6 / 150 | 0 |

Worst single callout: the card face call, inside the writer's measured 6.9 s, nowhere near the
120-second ceiling.

## retryNotes

None. No model call flaked, no stage was retried, nothing was re-run to get a different answer.
One thing is worth recording as a near-miss rather than a retry: the DML-before-callout ordering
in the card writer would have thrown on this very run had it not been read first.

---

## The config inventory, one line per item

Against the repo and the org this session, `aao-config-inventory-v0_1.md` in inbox order.

| # | item | status as inventoried | confirmed |
|---|---|---|---|
| 1 | Map value ranks and label map | Built | **CONFIRMED.** 10 `AAO_Map_Value__mdt` rows queried in-org: 6 buyer role (Signature Approver 5 → Unknown 0), 4 political (Inner Circle 3 → Unknown 0); 10 records in `customMetadata/`; the no-label-in-logic test stands. |
| 2 | Model configuration | Built | **CONFIRMED with one correction.** `AAO_Anthropic.namedCredential` exists; knob feature detection is real but is **temperature-specific**, not general: `AAO_Extract` carries a temperature field and a refused-and-retried flag, and no other knob has one. The inventory's "temperature and every other knob" overstates it. |
| 3 | Model routing per call | Built | **CONFIRMED.** `AAO_Model_Config__mdt` carries 28 fields including `AAO_Verify_Model__c`, `AAO_Inventory_Model__c`, `AAO_Bind_Model__c`, `AAO_Verify_Temperature__c`. Admin-visibility of per-call choice is still undecided, as stated. |
| 4 | Internal domain list | Ruled, not built | **CONFIRMED, and it is not a static resource in the sense the inventory implies.** It lives in `AAO_Seed.json` (`internalDomains: altify.example, altify.com, opentext.com`), read by `AAO_Seed`. Same debt, one degree further from a config surface than "static resource" suggests. |
| 5 | Title synonym list | Ruled, not built | **CONFIRMED.** `TITLE_CANON`, an Apex constant in `AAO_ResolveDesignator`, with its own comment naming seed metadata as the owed home. |
| 6 | Admission-filter role and license map | Ruled, unbuilt | **CONFIRMED UNBUILT.** No admission filter exists; the only matches for the word are unrelated ("admission carries no materiality judgment" in the card writer). |
| 7 | Declared families per org | Partly built | **CONFIRMED.** `AAO_Evidence_Contract__c.AAO_Family__c` exists and routes; no per-org declaration surface. |
| 8 | Lane flag | Ruled, unbuilt | **CONFIRMED UNBUILT, and stronger than the inventory says.** There is no lane flag and no lane branch anywhere; "express lane" appears only in comments. Batch versus express is today a property of how a driver sequences calls, not a switch. |
| 9 | Contact toggle | Ruled, packaging unbuilt | **CONFIRMED.** `AAO_Settings.CONTACT_CREATION` reads `AAO_Setting.Contact_Creation.md`; the picklist-not-checkbox shape stands. |
| 10 | Hot/cold retention window | Proposal owed | **CONFIRMED UNBUILT.** No Data 360 reference in any class. |
| — | Constants that look like config | listed | **CONFIRMED as constants**, none configurable. |
| — | Not yet inventoried | named | **NO CHANGE.** No permission-set or FLS work landed this stretch. |

One item to add at the next revision, surfaced by this stretch: **the shadow-reason vocabulary**
gained `Ambiguous` and `Single_Token`, which is our own picklist and not org-varying, so it is a
constant that looks like config and belongs in that section rather than in the inventory proper.

## Suite

**501 tests, 500 passing.** The one failure is the standing org-resident non-AAO
`ConvertToOpportunityTest.testgetOppCreationDetails`, failing on the org's own
`AE_Summary__c` validation rule exactly as it has since the fourth stamp. Suite 490 → 501:
eleven new tests, all of them assertions about the two rulings.

The four that are worth naming, because each pins something a later session could undo in one
line: the intersection boundary table (identical, containment, partial, **adjacent-is-not-
overlapping**, cross-source, empty); a second press in the same call still counting;
`overlapIsSCOPEDBYTYPEANDBYSOURCE`, which asserts the cross-type pair is **not** collapsed so the
rule cannot quietly eat Matthew's grading specimen; and
`theMISHEARDSPELLINGDOESNOTLINKANDCRUCIALLYDOESNOTCREATE`, which records the honest limit rather
than a flattering one.
