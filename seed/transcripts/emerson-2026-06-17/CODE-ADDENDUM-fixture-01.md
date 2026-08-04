# CODE addendum 01 · 4 August 2026, evening · the Emerson fixture is normalized and attached

**Reads against:** Charters v2.7 §P8, the harness satellite §2 and T0/T1, Board v1.5. This addendum does not change any ruling; it delivers the fixture and records what normalizing it proved.

## What is attached

| File | What it is |
|---|---|
| `emerson-2026-06-17-raw-viewer-paste.txt` | The ECI viewer paste, exactly as it came off the page. Provenance copy; never read by the pass |
| `normalize_eci_paste.py` | Reference normalizer, Python, deterministic by construction |
| `emerson-2026-06-17-nf1.txt` | **The frozen artifact.** NF1: SpeakerKey, tab, utterance, one turn per line, nothing else |
| `emerson-2026-06-17-nf1.sidecar.json` | Everything stripped, plus per-turn timestamps, roster resolution, and the hash |

**`sha256 = c6d056baeb751d7025ea646f8755d717278e785ec06bb7526989e91735769196`**, 415 turns.

**The Apex normalizer must reproduce that hash byte for byte from the same input.** That is T0's determinism assertion and it now has a target number instead of a description. The Python is a reference implementation and a test oracle, not the shipping path.

## What normalizing it proved, four findings

**1 · The annotation hazard is worse than the Tungsten specimen, and it now has a number.** Gate 1 found nineteen machine topic labels inline on the Tungsten call. This artifact carries **41 label tokens across 33 lines**, and eight of those lines carry **two labels concatenated with no separator at all**: `ProductNext Step`, `AI Tools and Automation MentionedGo To Market Tech Stack Discussion`, `Budget Constraints DiscussedNext Step`, `Low Adoption SignalsAI Tools and Automation Mentioned (2)`. A naive splitter on any single label name silently corrupts the neighbouring one.

The stripped inventory, by type: Product 9, Next Step 8, AI Tools and Automation Mentioned 4 (+2 as `(2)`), License Count or Usage Discussion 2 (+4 as `(2)`), Go To Market Tech Stack Discussion 3, Product (2) 3, Budget Constraints Discussed 2, Procurement Process Engaged 2, Low Adoption Signals 1, Pricing 1.

**`Low Adoption Signals` is the one to look at hardest.** It is not a topic marker, it is a machine's *judgment* about the customer, sitting in the transcript in a position where an unstripped read would treat it as text on the artifact. Had it survived, a model could have cited a machine's inference about adoption as though it were the record. That is the annotation hazard at its worst, and it is why stripping is a law and not a nicety.

**The rule the normalizer implements, and it follows the discovery-filter-fault law:** strip by known-vocabulary match only; a label-shaped line is stripped only when the *entire* line decomposes into known label tokens; anything label-shaped followed by real text is **kept and reported loudly** rather than guessed at. Two guards run in both directions: a warning if a label prefix precedes real text, and a warning if an utterance is entirely label vocabulary (which would mean the rule mis-fired). This artifact produced zero warnings.

**2 · The roster join fails on display name for exactly one person, and it is the only person with a Contact.** The artifact renders four participants exactly as `VideoCallParticipant` does and renders Neeraja as **`Neeraja Chimata`** against the platform's **`Chimata, Neeraja [EMR/SYSS/AT/BED]`**. Exact-string matching resolves four of five and drops the one who is the only external participant carrying a `RelatedPersonId`. The normalizer resolves her by permutation (`Last, First [tag]` ↔ `First Last`, org tag stripped) and **records the match type on every row** so a permutation match is never invisible. Recorded as a rule, not a fix for this file: display-name joins need the permutation and tag-stripping forms, and the match type travels with the resolution.

**3 · Turn order is not strict chronology.** Several turns share a timestamp to the millisecond (items 7 and 8 both at 37.812; 10 and 11 both at 38.972) because people spoke over each other. Ordering is stable and deterministic, but nothing may assume a turn's timestamp is strictly greater than its predecessor's. Contiguity is checked **within a turn only**, which is the existing span law and now has a specimen.

**4 · The parent/subsidiary question is live inside the fixture, not just in the org.** The account record is Emerson Electric Co. and the deal names both companies, while Jefferson says on the call that he is `part of the sourcing team at ... Aspen Tech` and is `trying to introduce myself as being from Emerson because Aspen Tech and Emerson are coming together`, and Wendy answers his question about Emerson with `We don't have any agreement with Emerson`. So the buying entity, the account record, and the parent are three things in motion during the call. This is the resolver's parked parent/subsidiary topology item appearing as evidence. **Nothing changes today:** the account resolves to Emerson Electric Co. and T1 asserts that. It is recorded so the resolver session has a real specimen instead of an argument.

## T0 and T1 assertions, now concrete

T0 passes when: the Apex normalizer's output hashes to the value above; 414 navigation lines, 1 inline item number, 415 timestamps and 33 label lines are stripped and counted; zero warnings; and normalizing twice is byte-identical.

T1 passes when: the account resolves to Emerson Electric Co. (`001Hn00002CXGaMIAX`); the candidate opportunity window is built as of **2026-06-17T20:29:36Z** and **contains `006V400000VIJiIIAX` and does not contain `006V400000fH2KLIA0`** (the renewal, created 3 August, did not exist at call time); the opportunity resolves to Insights 500; ECI's `RelatedRecordId` is recorded as an input that agreed rather than as the reason; and person resolution yields a Contact link for Neeraja, honest ladder outcomes for Ryan Couture, a Shadow candidate for Jefferson Vargas, and the two internal users.

**Every quote in a pair must byte-locate in the frozen artifact exactly once.** Thirteen candidate spans across criteria, sentiment, budget, the compelling event and the compliance gate were checked by hand against the artifact: eleven located exactly once, and the two negative controls (`Low Adoption Signals`, `Move the player to`) located zero times, which is the strip working.

## Two things that stay yours to build

The **Path A capability test**: call the Get Conversation Transcript action from Apex and journal the result either way. This paste is Path B and it works; Path A has still never been tried from the runtime that will make the call, and until it is, hand-carried artifacts are the only proven intake.

The **intake matrix** beyond this format, per harness §2: format and diarization class declared per intake before normalization runs. This fixture exercises the ECI viewer paste. Teams exports, vendor exports and bare pastes remain designed and unbuilt.
