# AAO Proof Register — living file

**v0.1 · 31 July 2026**
Discipline: three statuses. **PROVEN** carries the receipt and may be stated flat. **NEEDS MEASUREMENT** names its test and is stated only as a design property ("by construction"). **UNVERIFIED** is never repeated externally. A claim moves up only with a receipt; nothing moves silently.

## PROVEN in the org, receipt named

1. **Incrementalism across evidence.** UNVERIFIED with receipts after call one, TRUE after call two, first claim untouched forever. Receipt: live run 31 Jul, claims CLM-00000008/9; exit test green.
2. **Replay.** Answers deleted and rebuilt from claims exactly, field for field. Receipt: in-org REPLAY exact=true on all three demo deals.
3. **Same evidence twice produces nothing.** Duplicate ingest enqueued zero jobs, live on camera, twice. Receipt: terminal transcripts 31 Jul.
4. **Two clocks / backfill.** June evidence processed in July, ordered by occurred, not by processing. Receipt: status output, claims 11 days apart occurred, seconds apart recorded.
5. **Arrival survives adjudication.** Trigger and Queueable are separate transactions; the artifact lands even if judging fails. Receipt: AAO_LiveIngestTest asserts zero claims before stopTest.
6. **Zero dependency on Altify.** Full pipeline on an opportunity with no Altify record; all fourteen ALTF rubric tables present and empty. Receipt: describe 31 Jul; demo deals.
7. **Speaker rank enforced structurally.** Identical words from the seller land UNVERIFIED, outcome Downgraded, with full element coverage. Receipt: seller-said-it deal.
8. **Complete consideration ledger.** Every proposition gets a candidate row including nobody-said, so "did it even look" is answerable. Receipt: candidates=6 per pass in org.
9. **Write-blocking customer constraints are real.** The sandbox's own pre-existing test fails on a customer validation rule. Receipt: ConvertToOpportunityTest failure, journal.
10. **Secret handling.** API key in an encrypted write-only slot, merged after Apex builds the request, unreadable from code, absent from debug logs. Receipt: credential deploy 31 Jul, journal, verbatim platform messages.
11. **First live model pass.** claude-opus-5 through the Named Credential: 3,137 tokens in, 915 out, 13.7s, prompt 6,292 chars assembled at runtime from Evidence Contract records, closed enums from org data. Six findings, **zero hallucinated spans** (spansDropped=0), five correct nobody-said abstentions. Receipt: Gate 1 pass T1SRC, 31 Jul 11:48.
12. **The harness catches a wrong verdict.** Model proposed FALSE on an open answer; ground truth UNVERIFIED; span check passed (real quotes), coverage read full (located spans), and the comparison caught it because the blind reader is not yet wired. Empirical demonstration that the four checks are non-substitutable. Receipt: same run.
13. **model_missed is measurable for the first time.** Reachable only once a model actually reads; first pass recorded 0. Receipt: same run.

## NEEDS MEASUREMENT, test named

14. **Token cost per answered question vs re-read architectures.** By construction: keyed reads cost zero model tokens; measure across Gate 1 round two and first real transcripts. First data point in row 11. Note: cacheRead=0 on pass one; the contract prefix is cacheable and prompt caching is an unexploited saving.
15. **Latency per pass at scale** (the 25-transcript day). First point: 13.7s single pass.
16. **Abstention rate by charter version.** Detector built (candidate reasons by charter). Baseline accumulates from round two.
17. **Small-talk boundary accuracy.** Labelling exercise, ruled; boundary marked not cut, so the test stays runnable forever.
18. **Third-party signals as attention pointers.** Gong topics as hints that narrow the read, never establish. Design compatible (derived classifications read, never trusted); test later.
19. **Blind reader catch rate.** Row 12 is the reason. Wire Model Call 2, re-run the same specimen, record whether it kills the FALSE.

## UNVERIFIED — do not repeat externally

20. **Data 360 native connectors for Gong / Teams transcripts.** Said to Toby 31 Jul; check the connector catalog before it travels further.
21. **Foundations credits make the PoC free for every customer.** Verify the entitlement story.
22. **All Altify customers on Salesforce Enterprise with Trust Layer available.** Verify.

## Structural arguments (argued in the documents, evidenced as measurements land)

23. **Determinism requires binary propositions and closed vocabularies**; a graph store's history is stored inference, re-derived per ask, non-deterministic by construction. Ours is receipts under keys: same question, one lookup, same answer.
24. **Enterprise trust posture.** Everything inside the customer's existing Salesforce boundary; no second system, no new DPA, no data egress; every value answers "why does this say this" in one hop.
25. **Cost shape.** Always-monitoring spends with data volume forever; AAO spends on new evidence a bounded number of times, then keyed reads.

*Append with receipts. Corrections mark the old row wrong rather than deleting it.*
