# AAO probe verification · pf0811-t0 · the temperature-0 stability probe · design's per-run check · 11 August 2026

**Satellite, outside the audit chain. Records design's verification of CODE's run `pf0811-t0` against the verification sheet (v1.0) and the looks-right standard. Companion: the fortieth stamp. Run README: `review/pf0811-t0/README.md`. Numbers are CODE's; nothing is asserted beyond the report. This run is a negative capability finding plus one purged diagnostic run, not a stability export, so several lenses read N/A by construction; that is recorded, not skipped.**

## Verdict

CLEAN on every applicable lens. The probe could not run as specified because the verifier model refuses the `temperature` parameter; the finding is measured from the wire, correctly reported, and nothing was tuned or left in the org. No defect in CODE's work. The structural finding it surfaced (model separation on the §P8 path) is parked for a strong session, not ruled here.

## The lenses

**1 · Provenance.** N/A by construction for upheld claims: the run projected nothing (0 claims, 0 map rows) and was purged, so there is no export to match against the frozen artifact. The refusal is evidenced instead by three gateway request ids (`req_011CdwFzSfCSgPYTdKfzGqRY`, `req_011CdwFzTDSRih7tFRief3us`, `req_011CdwFzT9U9e9UKMyTKZaFX`) and a per-model capability matrix probed directly. Evidenced from the wire, not inferred.

**2 · Arithmetic.** Trivially satisfied at zero: nothing upheld, nothing projected, located = disposed = 0 persisted. The single diagnostic run's 49 located pairs is a reported count, explicitly not offered as a claim ledger or a stability result.

**3 · Law compliance.** Holds on report. No map touched (0 map rows; "no map carries anything from this run"). Call 3's blindness affirmed and structural in the schema. The temperature knob follows the null-omits-rather-than-defaults discipline (blank is never on the wire), matching `effort`. Nothing tuned against any output. The probe ran in the aossb2 sandbox, CODE's lane; production untouched. Design could not corroborate the sandbox state in-org this session (see below).

**4 · Ceilings and governors.** Printed for the single diagnostic run and under the laws: reads 29,851 ms and 27,845 ms in parallel (worst callout well under the 120,000 ms cap), resolution deterministic leg 338 ms, model leg 7,258 ms; SOQL worst 7/100 reading resolution and 48/100 join, DML 56/150, heap under 92 KB of 6 MB, nothing past 80 percent. Label COLD (`cache_read=0` on call 0 and both reads).

**5 · Report honesty.** Exemplary, the strongest lens here. Measured never asserted. The capability matrix probed directly rather than inferred. The first-attempt miss recorded with the exact reason the check exists: the temperature first landed on `verifySpec()`, which the §P8 call 3 does not use; the wire printed `temp=unset` with `model=claude-opus-5`, and the `temp=` journal field exists because of that miss. retryNotes present (call 0 quote-law double-failure stop; reads 1-indexed). The run states plainly what it does and does not establish.

**6 · Regression consequences.** N/A: this is queue item (e), not a regression run; the grades' regression fold is item (a), separate and still owed.

## Taken on CODE's report, not corroborated in-org this session

The only Salesforce MCP available is production and read-only, and it returned the OpenText org (`00Diw000000fKafEAE`, `IsSandbox false`), which is neither the Altify production id the rails name (`00DHn000006jYatMAE`) nor the aossb2 sandbox where the probe ran. One `Organization` metadata query was run, no data was read, and no further query was made. These three claims are therefore taken on CODE's report, which verified them from the calling runtime, and a two-query sandbox spot-check is owed to a sandbox-connected session:

- `AAO_Model_Config__mdt.AAO_Verify_Temperature__c` is nil again (baseline restored).
- Probe run keys purged: 0 map rows.
- Probe run keys purged: 0 claims.

## What this run does and does not establish

Establishes: the temperature remedy cannot be measured on the current verifier (`claude-opus-5`), and why, from the wire; and that call 3 currently runs on the reader's own model, so blindness holds but model separation does not on the §P8 path. Does not establish: whether temperature would settle the flicker, now unreachable without changing the model. The `pf0808-stability` flicker measurement stands unchanged: location stable 42/42/43, upheld 8 to 21, 1 of 7 load-bearing cells stable across three identical runs.

## Provenance of this check

Read this session: `review/pf0811-t0/README.md` (full); `CODE-INBOX.md` stamps fortieth through twenty-ninth; `aao-verification-sheet.md` v1.0; `aao-grading-record-tg1-vs-pass1-v1_0.md` v1.0; `README-CHANNEL.md`. The `review/` tree confirmed `pf0811-t0` is the only new CODE output since the thirty-ninth stamp. BUILD_JOURNAL was not present in the channel; no number here originates outside CODE's report.
