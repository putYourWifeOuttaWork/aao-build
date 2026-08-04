# AAO Pass Test Harness · the 17 June Emerson fixture

> **The version lives on the stamp line below and nowhere else. Satellite, outside the audit chain. The pass it tests is Charters v2.7 §P8; where this file and §P8 disagree, §P8 wins.**

**v1.0 · 4 August 2026 · First writing, commissioned by Matthew with the rebuild GO. The test suite for the rebuilt pass, end to end, on a real production call: intake and normalization, ID resolution, call 1 pairs, call 2 identification, call 3 verification, counter arithmetic, and projection preview, every stage emitting into one legible CSV that Matthew and design review together. Org facts below read from production `00DHn000006jYatMAE` on 4 August 2026, read-only. No LWC work is in scope; the review surface is the CSV, deliberately.**

---

## 1 · The fixture, read from production

**The call.** `VideoCall` `6qrV4000000J5K9IAK`, "Altify + AspenTech/Emerson Pricing + Buying Process Overview." 17 June 2026, 20:29 to 21:10 UTC, 2,455 seconds. Vendor `msteams`, recorded, diarization opted in, transcribed language `en`, MeetingType EXTERNAL. Host and owner: Renee Martin (`005Hn00000Iyk1MIAR`). ECI's `RelatedRecordId` stamp: `006V400000VIJiIIAX`. Event `00UV400000kb5RRMAY`.

**The participants, verbatim from `VideoCallParticipant`:**

| Name as captured | Email | RelatedPersonId | Side |
|---|---|---|---|
| Couture, Ryan [EMR/SYSS/AT/BED] | ryan.couture@emerson.com | **null** | External |
| Chimata, Neeraja [EMR/SYSS/AT/BED] | neeraja.chimata@emerson.com | `003V400000v7x90IAA` (Contact) | External |
| Vargas, Jefferson [EMR/SYSS/AT/MEDI] | jefferson.vargas@emerson.com | **null** | External |
| Wendy Higley | wendy.higley@altify.com | `005Hn00000JHb1PIAT` (User) | Internal |
| Renee Martin | renee.martin@altify.com | `005Hn00000Iyk1MIAR` (User) | Internal |

**The account and its opportunities.** Emerson Electric Co., `001Hn00002CXGaMIAX`. Three opportunities ever: the 2019 closed-lost; **"Emerson/Aspen Tech Insights 500 Full Insight" (`006V400000VIJiIIAX`), created 22 March 2026, OPEN on 17 June, closed won 31 July, Renee Martin's**; and "Emerson Electric Co. - Renewal" (`006V400000fH2KLIA0`), **created 3 August 2026**, Stage 2, open now.

**Why this call is the right test bed, four reasons.**

1. **The occurred-time trap, live.** At call time the account held exactly one open opportunity. Today it holds a different one. A candidate window built on the run date resolves this call to a renewal that did not exist when the words were spoken. The resolver must window candidates on the evidence-occurred clock (open plus recently closed as of 17 June), which the §P8.1 law now states. ECI's stamp happens to agree with the right answer here; it is one input and never the answer.
2. **The identity ladder gets real work.** Neeraja matches a Contact by the platform's own email join. Couture and Vargas do not: Couture's Contact situation must be discovered by the ladder (CRM step, name-at-account), and Vargas is the known specimen who "by ID does not exist," no Contact, no map row, despite driving legal, InfoSec, and the approver story on this account. Correct output is a link for Neeraja, ladder outcomes for Couture, and a Shadow candidate for Vargas. Any invented identity is a hard fail.
3. **The content is dense in exactly the families we just chartered.** Pricing and buying-process overview: decision criteria (the 17 June call was already recorded in Computable Share as dense with criterion content over an empty criteria object), Process and assessment material (budget, approval, procurement, timeline), and sentiment.
4. **It is fresh ground.** Nobody has graded it. Matthew and design review the CSV together and the joint grades become this fixture's answer key for every regression after. **This is a joint-review development fixture, deliberately not blind. The blind-key law is untouched and applies to the 29 July video, whose key remains unspent and owed before any output on that fixture exists.**

**One structural note, flagged rather than assumed.** The old Emerson blocker (all 48 contracts pointed at the three B&V contacts; zero existed for Emerson people) dissolves under v2.7, because contracts are no longer person-crossed: the declared question set is generic and people arrive through call 1's resolution. The harness proceeds on that basis. Matthew confirms or corrects.

## 2 · Transcript acquisition and the intake problem

**The worry this section answers, Matthew's, verbatim in spirit: we are only prepared for copy-pasted transcripts, while real transcripts arrive from many places, in many formats, with or without identities.**

**Acquisition for this fixture, two paths, both exercised.**

- **Path A, the platform path, and it is a capability test.** ECI's Get Conversation Transcript action (API 63.0+) returns structured turns with a related person per participant. It has never been called from Apex; the capability law says it is unverified until tried from the runtime that will make the call. CODE calls it from Apex in the sandbox-connected context, journals the result either way, and if it works it becomes the hot intake for ECI orgs. Transcripts never copy into sandboxes, so whatever this returns is hand-carried into `aossb2` as the frozen artifact, which is permanent practice, not a workaround.
- **Path B, the paste path.** Matthew pastes the transcript from the viewer. The viewer's copy is the known-bad block layout (zero tabs, the NF1 discovery), which makes it a deliberate normalization test case, not a nuisance.

**The intake matrix, designed now, built as far as this fixture exercises it.** Every intake declares three things before normalization runs: the source format, the diarization class (Attributed with platform identities, Attributed with name labels only, or Inferred), and whether inline machine annotations are expected. The formats the normalizer must eventually accept, with this fixture covering the first two:

| Format | Identities | Known hazards |
|---|---|---|
| ECI action JSON (Path A) | Platform IDs per turn | Unverified from Apex; annotation fields |
| ECI viewer paste (Path B) | Name labels | Block layout, zero tabs; inline topic labels are machine text, not speech (the Gate 1 finding: nineteen were present on the Tungsten call and byte-check would pass them) |
| Teams export (VTT / docx) | Name labels, timestamps | Timestamp lines, continuation blocks |
| Vendor exports (Gong, Zoom, Chorus) | Vendor labels | Per-vendor furniture; no IDs |
| Bare paste | Maybe nothing | May need the Inferred class, which runs at reduced power by standing law |

**Normalization requirements, tested not asserted.** Output is NF1 and only NF1: SpeakerKey, tab, utterance, one turn per line; timestamps, topic labels, and every machine annotation stripped to the sidecar, never in frozen bytes. Determinism: the same input normalized twice yields byte-identical output, asserted by hash. Convergence: Path A and Path B of the same call yield identical utterance text where the underlying words are the same, asserted by diff, and any divergence is journalled as a finding about the sources, not silently tolerated. The frozen artifact's hash is the fixture's identity from then on.

## 3 · The stage tests, in run order

**T0 · Intake and normalization.** Inputs: the raw artifact(s). Asserts: format detected and declared; annotations stripped and counted (unit: annotations); turns parsed (unit: turns, expect a real number, not zero, which was the NF1 defect's signature); determinism hash; convergence diff where both paths exist; sidecar carries what was stripped. CSV rows: one per check, plus one per stripped-annotation type with an example.

**T1 · Resolution.** Inputs: the frozen artifact, call metadata (name, owner, participants, occurred datetime), and the seeded org. Asserts, mechanically where truth is known: account resolves to Emerson Electric Co.; the candidate opportunity window is built as of 17 June (the run must show its window and the renewal must be absent from it); the opportunity resolves to Insights 500; the ECI stamp is recorded as an input that agreed, never as the reason; participant identification lands Neeraja's Contact, the ladder's honest outcome for Couture, a Shadow candidate for Vargas, and the two internal Users; scope (deal, account, or dual) is recorded with its basis for joint review rather than pre-asserted. CSV rows: one per resolution output, English basis sentence each.

**T2 · Call 1, pairs.** Inputs per §P8.1. Asserts mechanically: every pair's answer text byte-locates in the frozen artifact (misses counted, unit: pairs); no pair carries a person; no pair carries a question outside the declared set; sentiment pairs carry exactly one of the five states; fact pairs carry full or partial. Reviewed jointly, not pre-asserted: did it find the criteria we know are in there, the buying-process material, the sentiment, and nothing invented. Telemetry: latency, input, output, thinking share (the rumination check).

**T3 · Call 2, identification.** Asserts mechanically: exactly one disposition per pair, in order (one-for-one, throws on mismatch); every identification is from the closed candidate list or NONE or AMBIGUOUS; AMBIGUOUS routes to the Identification flag path. Reviewed jointly: are the attributions right, with the basis sentence legible.

**T4 · Call 3, verification.** Asserts mechanically: one verdict per identified claim (for one); the reader saw only claim and quote. Reviewed jointly: each refusal's one-sentence reason. The sentiment scope guard is watched specifically: any quote upheld as sentiment toward us that is actually about something else is the over-reading disease and gets named in review.

**T5 · Arithmetic.** Asserts mechanically, per person: reads net per call; counter moves one step toward the voiced state and never past it; mixed evidence nets to no move with all quotes journalled; explicit declarations jump with the sequence flagged; replay over the claims reproduces the counter exactly. CSV rows: person, prior position, reads with quotes, movement, new position, new rung, flag raised or not.

**T6 · Projection preview, dry run in sandbox.** What would write, where, per the writer's rules: map dimensions with Option C notes, criteria rows with Subject text and voicer junctions, qualifier and assessment answers where Process material established. Nothing writes to anything in this test beyond the preview rows themselves; the write path's own tests already exist. CSV rows: target object, field, value, citation in plain words.

**T7 · The receipts.** One run receipt exists for the Source (the did-we-read-it row); one-for-one-for-one holds across all three stages; every counter printed carries its unit; no abstention row exists anywhere (a query proving zero such rows is itself a test).

**Sequencing note.** The 24 June B&V recall gate (graded targets) still runs first, before this fixture, because it is the only fixture with an existing answer key. This fixture then becomes the second key once jointly graded.

## 4 · The CSV, the review surface

One CSV per run, one row per output, columns fixed: **Stage · Item · Check or Question · Person · Quote · System Answer · Basis in plain English · Expected · Match · Notes.** Expected is filled only where ground truth exists (T0, T1, mechanical T2 through T5 checks) and shows REVIEW where the answer is Matthew's to grade. Match is YES, NO, or REVIEW. Every English sentence in Basis is written for a human reading fast: "Renee organized the call and owns the only deal that was open that day," not a code path. No record IDs in Basis; IDs live in their own columns where needed. Matthew and design walk the REVIEW rows together; the graded CSV is archived beside the fixture and becomes the regression key.

## 5 · Seeding, and what CODE owes back

Sandbox seeding follows the §P7.2 seeder law unchanged: Emerson native parents from production reads (Account, Contacts, the Insights 500 opportunity with its real stages and dates, the renewal, the 2019 closed-lost for history shape), owners remapped by intent, one-record probe before bulk, counts verified after, real emails accepted as recorded practice. No map rows seeded; watching the product build them is the test. The frozen artifact hand-carried in. Owed back to BUILD_JOURNAL: the Path A capability result, the normalization hashes, every measured constant with its measurement, and the CSV.

---

*End v1.0. Corrections go into this file, marked wrong in place, never deleted. The graded CSV, once it exists, is recorded beside this satellite, and its grades outrank this file's expectations wherever they disagree.*
