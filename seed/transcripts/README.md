# The dummy transcripts

We wrote them, so ground truth is known by construction.

Authored in `force-app/main/default/staticresources/AAO_Seed.json` under `sources`. They
are not duplicated here — see `seed/README.md` for why.

**Frozen once written.** A transcript edited after a span was verified against it breaks
the citation chain, which is the exact failure immutability exists to prevent.
`AAO_SourceTriggerHandler` enforces the same rule in the org.

## Roster

| Key | Person | Side | Map role |
|---|---|---|---|
| `dana` | Dana Ruiz, VP Operations, `dana.ruiz@northwind.example` | buyer | Decision Maker |
| `priya` | Priya Shah, Account Executive, `priya.shah@altify.example` | seller | — |

Buyer and seller are derived by **domain split**, against `internalDomains` in the
fixture. No platform labels: an internal user account on the customer side, or a seller
dialling in from a personal address, are both cases where a platform label would lie and
the domain would not.

## The four artifacts

| Code | Deal | Diarization | Occurred | What it is for |
|---|---|---|---|---|
| `T1SRC` | main | Attributed | 2026-06-15 | Transcript one. Dana states funds approved and allocated, explicitly does not commit on timing |
| `T2SRC` | main | Attributed | 2026-06-26 | Transcript two, eleven days later. Dana confirms the fiscal year |
| `NEGSRC` | negative | Attributed | 2026-06-26 | The same words as transcript two, spoken by Priya instead of Dana |
| `UNSEGSRC` | unsegmented | **Unsegmented** | 2026-06-26 | One artifact with no speaker turns at all, the Notion shape |

The negative and unsegmented cases sit on their own opportunities so they cannot pollute
the accumulation the exit test asserts on.

## Normal form

Turns are `<speakerKey>\t<utterance>`, one per line, `\n` separated, no trailing newline.
A span must lie inside exactly one utterance region: it may not cross a newline and it may
not reach back into the speaker prefix. `AAO_NormalForm` is the single reader of that
shape, and `AAO_NormalForm.compose` is what builds the fixtures, so a fixture and the
verifier cannot disagree about bytes.

Unsegmented artifacts have no turns. The whole document is one region, which is why one
can carry verifiable spans and still satisfy no speaker requirement beyond
`Any_Participant`.
