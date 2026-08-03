# Emerson Extract · production read-only pull for the AspenTech-call harness fixture

Pulled by design via Salesforce MCP against production `altify.my.salesforce.com` (org 00DHn000006jYatMAE), 3 August 2026. Read-only throughout; nothing written. Every value below is a verbatim production read unless marked as a note.

## The given deal · Matthew's one-time ruling
**Given deal: `006V400000VIJiIIAX` — Emerson/Aspen Tech Insights 500 Full Insight.** Scaffolding standing in for the unbuilt resolver, same status as the hand-seeded contracts standing in for the reconciler. ECI's RelatedRecordId on the VideoCall points at the ACCOUNT (`001Hn00002CXGaMIAX`, Emerson Electric Co.) — journal as a measured ECI misfire, second direction (B&V was an account call stamped to a deal; this is a deal call stamped to the account).

## Facts CODE must journal
1. **The given deal is Closed Won as of run time** (won 2026-07-31, $275,555, 511 qty, owner Renee Martin). Evidence occurred 2026-07-29 while it was open. Whether projection writes onto a closed deal's map is an open design question — proceed and record, do not rule.
2. **At call time exactly ONE open opportunity existed.** The Renewal (`006V400000fH2KLIA0`, Stage 2, close 2029-07-30) was created 2026-08-03 16:58 UTC — five days AFTER the call, spun up on the win. Which-opportunity at occurred time had one candidate. (Resolver-harness note, non-asserted here.)
3. **Occurred clock:** VideoCall StartDateTime 2026-07-29T20:00:55Z, duration 1245s. The transcript artifact's own window starts 20:04:20Z. The call clock is the occurred clock.
4. **Both external VideoCallParticipant rows carry RelatedPersonId = null** (Couture's Contact has no email; Vargas has no Contact). The v0.3 "deterministic on every external row" claim gets its qualification at fold time: mechanism deterministic, coverage not.
5. **The canonical transcript is a blob**: VideoCallRecording `3QhV4000000LkhNKAS`, FileType=TRANSCRIPT, beside the MP4 (`3QhV4000000LkhOKAS`). Not SOQL-readable; no ContentDocumentLink exists on the VideoCall. Retrieval from the ECI media endpoint remains unverified from every runtime held this session. Branch (a)/(b) of the step-3 instruction stands.
6. **Cross-account contact role:** Filipe Soares-Pinto (`003Hn00002pHeyxIAC`) holds an OCR on the given deal but lives on a SEPARATE account — **Aspen Technology `001Hn00002CXEJHIA5`** exists in production as its own Account. Seed choice is CODE's: seed the AspenTech account + Filipe as a second native parent, or drop that one OCR and journal the drop. Do not orphan the OCR.
7. **Roster mapping status for the named-absent:** Neeraja Chimata resolves clean (Contact + email + OCR, and the deal notes name her as champion). "Fatima" = Fatema Choudray (Contact, null email, OCR; deal notes: exec, awarded the deal). "Corey" has a weak candidate in Corey Black (null email, no OCR) — do not assert the match. "Jacob" has NO Contact match (nearest is Jake Fritz, CIO — do not assert). Kathy and David appear in deal notes with no pull attempted.

## Files
- `account.json` — Emerson Electric Co., curated field projection (system/audit and celigo_/ia_ package fields dropped; full record available on ask)
- `aspentech-account-stub.json` — Aspen Technology account id/name only (pull full record on ask if CODE elects to seed it)
- `opportunities.json` — all 3 opportunities, curated projection preserving stage, type, record dates, payment terms, Altify process fields, and the Insights 500 deal-note history verbatim
- `contacts.jsonl` — 114 Contacts on the Emerson account (Id, Name, Email, Title) + Filipe on AspenTech, flagged
- `contact_roles.json` — all 18 OpportunityContactRoles (16 on the given deal, 1 on the 2019 closed-lost, 0 on the Renewal)
- `users.json` — 5 Users for the owner remap
- `videocall.json` — VideoCall, 3 participants, 2 recordings, verbatim

## Owner-remap intent (seeder verification item 1)
Renee Martin (AE, owner-host of the call, owner of the given deal and the Renewal) and Wendy Higley (VP Sales, speaker, owner of the 2019 opp) exist in the sandbox with identical IDs (prod refresh carried users). Map prod OwnerIds to the same sandbox users. ECI writer rows were created by the Automated Process user (`005Hn00000JbyVEIAZ`).

## Transcription caveat
`contacts.jsonl`, `contact_roles.json`, `users.json` and the curated projections were transcribed from MCP query results by design, not machine-piped. The seeder verification list's count checks (114 contacts, 18 OCRs, 3 opps, 5 users) are the guard against transcription slippage — verify counts after insert as always, and flag any row that fails validation back through the zip rather than repairing it silently.

---

# Amendment 1 · 3 August 2026 · AspenTech pull, OCR count correction

**Re-stamped last, per the zip law.**

## Correction, design's error
`contact_roles.json` previously put its `_summary` note inside the array, so array length read 18 while only **17 real OCRs** exist. Restructured as an object: `rows` holds the 17, `_count` states 17. CODE's catch, and CODE's own note stands: a check that passes by coincidence is worth flagging louder than the data it checked.

## Duration finding, CODE's, recorded
The TRANSCRIPT record's 1245s equals the VideoCall's duration, not its own window (20:04:20Z to 20:21:47Z is 1047s, matching the MP4). **No duration on the transcript record is the transcript's own.** The call clock stays the occurred clock.

## Aspen Technology, pulled in full
`aspentech-account.json` (stub deleted) and `aspentech-contacts.jsonl`, **54 Contacts**. Two structural facts:

1. **ParentId is null on both accounts.** Emerson and Aspen Technology are unrelated records in this CRM despite the real-world acquisition. **Do not infer a hierarchy.**
2. **The account pair carries real duplicate-identity noise**, and it lands directly on the given deal's roster:
   - **Fatema Choudray** (Emerson, OCR on given deal, null email, VP Premier Sales Performance) versus **Fatema Choudhury** (AspenTech, null email, Dir World Wide Sales Operations). The transcript's spoken "Fatima" now has **two** candidates. Neither resolves without adjudication.
   - **Patrick Cook** twice: Emerson row `pat@aspentech.com` holds the OCR; AspenTech row `patrick.cook@aspentech.com`. Same person, two accounts, alias versus full email.
   - **Luc Martin** twice: Emerson row holds the OCR with domain typo `@aspentch.com`; AspenTech row correct.
   - **Denise Stauubach** (Emerson, OCR) versus **Denise Staubach** (AspenTech). One extra u.
   - **Ahmed Abdel-Hady / Ahmed Abdelhady**: intra-account duplicate on AspenTech, two rows two spellings.
   - **Kevin Keeling** sits on AspenTech carrying `kpk87@emerson.com` — an email whose domain contradicts its account. A live counterexample to treating the domain join as deterministic for identity, though it stays deterministic for account location.

**Seed choice, now materially different from when it was handed over.** CODE elected to seed AspenTech as a second native parent on the Slalom precedent, which is sound. But seeding all 54 imports five duplicate identities of people who already hold roles on the given deal, before the identity ladder has ever run on real data. Two options, cost stated, and this one is Matthew's rather than CODE's because it changes what the run is testing:

- **Filipe only.** One native parent, one Contact, the OCR unorphaned. The run tests People on a clean roster. Cost: the duplicate hazard stays undiscovered until a later fixture, and the account is a lie about production shape.
- **All 54.** The run tests People and meets real duplicate-identity noise at once. Cost: two variables in one run, and an Identification-flag storm could mask a People finding. Honest, and possibly premature.

Design's read: **Filipe only for this run**, all 54 as the identity-ladder fixture later. One variable at a time is the rule the whole harness runs on. Matthew's call; nothing is seeded until he rules.
