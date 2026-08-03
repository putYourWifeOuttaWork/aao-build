# Emerson / AspenTech transcript · Source payload · MANIFEST

**File:** `emerson-aspentech-transcript.txt`. Ingested through the front door as a Source, never as fixture data.

**Seeded as `SRC-00000032`, `a1XWD0000081Gu92AE`**, 3 August 2026, scope key `S1|006WD00000TJmJZYA1|d0606eac…|1`.

## TWO FINGERPRINTS, BOTH CORRECT, AND SPANS VERIFY AGAINST THE SECOND

`AAO_Normalized_Text__c` is a LongTextArea and **LongTextArea strips a trailing newline on save**, measured session 73. The delivered file and the stored text therefore differ by exactly one byte:

| | bytes | SHA-256 | is |
|---|---|---|---|
| packaged file | 21,321 | `d0606eac75e6a878c78aa82b4a230975ffbab1c89cd7fdcdfb8bd7ccbf7db6fd` | `AAO_Artifact_SHA256__c`, the artifact as handed over, and what the scope key carries |
| stored text | 21,320 | `51bf052af7be8c44aa542d5fefc81efc06b2b48ccc5351dc358dff8977dcc16b` | `AAO_SHA256__c`, what the org holds, **and what spans byte-verify against** |

Both numbers are in `emerson-aspentech-transcript.sha256` and the file's is the one printed by `normalize.py`.

**This was tried the other way first and the attempt is recorded rather than tidied away.** Dropping the trailing newline to collapse the two fingerprints made the packaged file disagree with the Source already inserted from it, and the Source could not follow: `AAO_Artifact_SHA256__c` is in the trigger handler's `FROZEN` list, and that handler's own comment settles the matter for an identical earlier incident — *"No immutability exception exists or will. The recorded history stays."* The delete that would have allowed a clean re-seed is refused too, by the rule that Sources leave by retirement and never by deletion. Three laws, each right, and the correct outcome is to record the one-byte relationship rather than hide it. The B&V artifact stands in the same relationship and is not being changed either.

## Provenance, and it is not the canonical blob

**Supplied by Matthew, 3 August 2026, pasted into the CODE session from the ECI transcript viewer.** This is **branch (b)** of manifest item 5, which stood open since the Emerson fixture was handed over. Branch (a), retrieval of VideoCallRecording `3QhV4000000LkhNKAS` from the ECI media endpoint, remains unattempted and unverified from every runtime held.

**This artifact is therefore a human-mediated rendering of the transcript, not the canonical media blob.** It is what we have and it is honestly labelled. Anything adjudicated against it is adjudicated against a paste.

The raw paste is kept verbatim and unedited at `RAW-PASTE-2026-08-03.txt`. The transform from raw to artifact is `normalize.py`, run once, machine-piped rather than hand-edited — the Emerson fixture manifest records that its other files were "transcribed from MCP query results by design, not machine-piped" and names that as where slippage enters, so this one is not.

## Packaging numbers, reproducible by re-running `normalize.py`

| | |
|---|---|
| raw paste bytes | 31,789 |
| artifact bytes | 21,321 |
| viewer chrome lines removed | 220 |
| ECI signal tags removed | 7 |
| turns | 221 |
| SHA-256 | `d0606eac75e6a878c78aa82b4a230975ffbab1c89cd7fdcdfb8bd7ccbf7db6fd` |

Speaker turn counts: Wendy Higley 114, `Vargas, Jefferson [EMR/CSS/AT/MEDI]` 68, `Couture, Ryan [EMR/CSS/AT/BED]` 39. **Three speakers, matching `videocall.json`'s three participants exactly**, and the speaker labels are carried byte-exact including the bracketed org codes, because the roster keys on them.

## Two things removed, both because they are not speech

**1. Viewer chrome.** `Move the player to N seconds in the call`, emitted by the ECI viewer between every utterance. Same decision as the B&V transcript packaging on 2 August, and reversible the same way: the raw paste is kept beside the artifact, so if design prefers the chrome-inclusive raw as the frozen artifact, this file is superseded rather than edited.

**2. ECI signal tags, and this one is a judgment I am flagging rather than burying.** Seven labels lead an utterance body with no timestamp of their own:

| stamp | speaker | tag |
|---|---|---|
| 05:16 | Wendy Higley | Procurement Process Engaged (2) |
| 06:03 | Wendy Higley | Procurement Process Engaged (2) |
| 09:42 | Vargas, Jefferson | Pricing |
| 10:51 | Wendy Higley | Procurement Process Engaged |
| 11:33 | Wendy Higley | Procurement Process Engaged |
| 15:29 | Wendy Higley | Procurement Process Engaged |
| 16:11 | Vargas, Jefferson | Next Step |

**These are Einstein's inference about the call, not words anybody said.** Left in the artifact, a reader could quote a machine's label as a human's sentence and pass byte verification while doing it — a fabrication route rather than an over-read, and the one failure mode §P7.3 says must not exist. The board's standing hazard is that ECI's stamps are inference that misfires in both directions; this applies the same rule one level down. They are preserved with speaker and timestamp in `eci-signal-tags.txt`, so nothing is lost and the decision is reversible.

Matched as a **closed set of exact strings**, deliberately. A tag we have not seen before stays in the speech and shows up as a strange item, rather than being silently deleted by a loose pattern.

## One call kept rather than stripped, and it may be wrong

**`Setup.` at 16:11, Wendy Higley, is KEPT as speech.** It occupies a whole utterance slot with its own speaker and its own timestamp, which no removed tag does, and it carries a full stop, which no removed tag does. It is more likely ASR noise than a label. If it is a label, the cost is one junk item that binding drops; if it is speech and I had stripped it, I would have deleted something a person said. **Flagged so adjudication can overrule it.**

## Not normalized, deliberately

Every transcription artefact is carried exactly as pasted, because a normalized quote is a paraphrase and a paraphrase cannot byte-verify:

`Koopa` (3) and `CUPA` (1) for Coupa · `Anne Fatima` for "and Fatima" · `Fat, am I gonna sign it` for Pat · `the signs SOW` for "the signed SOW" · `Van.`, `Sun.`, `Sh.`, `Shh.`, `M.`, `Mmh.`, `Ha.` · `Aspen Tech` / `Aspen Technology` / `Aspen Technology Inc` all as spoken.

**`Fat, am I gonna sign it` matters for adjudication:** Wendy is asking whether *Pat* signs, and Ryan answers about *Fatima*. Two different people, one mis-transcription, and the answer may not be to the question asked. Recorded, not repaired.

## Call metadata for the Source row

- **Occurred clock: `2026-07-29T20:00:55Z`**, the VideoCall `StartDateTime`. Duration **1245 s**, the VideoCall's. Per the CODE finding folded into Emerson amendment 1, no duration on the transcript record is the transcript's own, so the call clock is the occurred clock. The artifact's own last stamp is 17:24, and the transcript window (20:04:20Z to 20:21:47Z) is 1047 s; neither is used as the occurred clock.
- **Given deal, Matthew's one-time ruling:** sandbox `006WD00000TJmJZYA1`, Emerson/Aspen Tech Insights 500 Full Insight, **Closed Won 2026-07-31, $275,555**. Account `001WD00000uC7bnYAC`, Emerson Electric Co.
- **Evidence occurred 2026-07-29, two days before the deal closed.** The closed-deal projection question is live on this run and is design's open item; the run proceeds and records rather than ruling.
- **ECI misfire, second direction, already journaled:** the VideoCall's `RelatedRecordId` stamps the ACCOUNT on this deal call. One input, never the answer. Scope routing is not asserted by this run; the deal is taken as given.

## Speaker roster mapping, as read from the org

| transcript key | resolves to | note |
|---|---|---|
| `Wendy Higley` | User `005Hn00000JHb1PIAT` | Altify, seller side. Prod refresh carried the User id unchanged. Her words downgrade structurally under the speaker rule. |
| `Couture, Ryan [EMR/CSS/AT/BED]` | Contact `003WD00001Pt0W4YAJ` | Emerson account. **Contact has no email**, so the email on the roster comes from the VideoCall participant row, not from the Contact. Confirms Emerson manifest item 4. |
| `Vargas, Jefferson [EMR/CSS/AT/MEDI]` | **no Contact exists** | Confirms Emerson manifest item 7. He is the most active buyer-side voice on the call and he has no CRM row at all. |

**Named but absent, all unresolved and none asserted:** Neeraja (Chimata, resolves clean), Fatima (**two candidates**, Fatema Choudray on Emerson and Fatema Choudhury on AspenTech), Corey (weak candidate Corey Black, not asserted), Jacob (**no Contact match**; nearest is Jake Fritz, not asserted), Renee, Pat.

## The blocker this artifact runs into, recorded here because it is not the artifact's fault

**No `AAO_Evidence_Contract__c` rows exist for any Emerson person.** All 48 contracts in the org point at the three B&V contacts. `AAO_ApplicableSet.resolve` therefore returns an empty set for this Source and `AAO_EBV.stage1` throws before any callout. Contract generation itself is mechanical (`AAO_PeopleContracts`, one contract per question per person, from our own ontology); the free input is **which people**, and that is the unbuilt resolver's decision, hand-scaffolded. **Design's to rule, and it changes what the run tests.** See the run report.
