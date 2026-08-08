# WF-OpenText Pass 1 · staged, blocked on one input

**CODE, 8 August, twenty-fifth stamp. Everything the live-org test needs is built and verified
EXCEPT the transcript bytes, which have not reached this side. Pass 1 cannot run without them,
and I will not fake a run against a file I do not have. This names exactly what is ready and
exactly what lands the moment the `.vtt` arrives.**

## The blocker, stated plainly

`aao-fixture-wf-opentext-2026-08-05-raw.vtt` (sha256 `be8e5e95…`) is **not in the repo, not in
the project folder, not in the delivered zip, and not anywhere on this machine by hash.** The
twentieth stamp says these files "reach you through Matthew"; this one has not. The twenty-fifth
stamp's own instruction is "verify the fixture hash on receipt; a mismatch is a corrupt carry,
stop and say so" — an absent file is the stronger version of that, and this is the stop.

**What I need:** the raw `.vtt` placed in `/Users/thefinalmachine/Downloads/` (or the project
folder). I verify `be8e5e95…` on arrival and, if it matches, run Pass 1.

## What is built and verified, so arrival is the only remaining step

| item (twenty-fifth stamp §3) | status |
|---|---|
| (a) retraction repair | **done earlier this session**; Wendy's claim retired, the coverage residue is the named ruling item, not a blocker |
| (b) WebVTT intake | **built and tested, 6/6.** `AAO_IntakeVTT` |
| (d) internal list classifies `opentext.com` | **done.** Added to the seed static resource; harmless to Emerson (no existing person carries it), correct for WF |
| seed in the org | **verified, not reseeded.** Wells Fargo, the Aviator opp at Stage 3, six `cib.wellsfargo.com` contacts, zero map rows, zero sources, Priya absent |
| (c) the Source row | **staged below**; needs the normalized text the intake produces from the real bytes |
| (e) the full pass to the live map | **staged below** |

## The WebVTT intake, and the one thing it cannot finalize without the bytes

`AAO_IntakeVTT.parse(raw)` produces the NF1 body (`<speakerKey>\t<utterance>` per line) and the
ordered speaker keys. It handles, each tested: the `WEBVTT` header, `NOTE`/`STYLE`/`REGION`
blocks, cue identifiers and `HH:MM:SS.mmm --> HH:MM:SS.mmm` timestamps, voice tags `<v Name>`
and `<v.class Name>`, tag stripping so no markup reaches a span, and **same-speaker cue
merging** so caption cadence does not fragment a turn.

**What it cannot finalize, named rather than hidden: the NOTE roster's exact line shape is a
property of the specific file.** `AAO_IntakeVTT.roster(raw)` parses two documented shapes
(`Name <email> | Title` and `Name | email | Title`) and returns **empty** where neither matches,
so the caller learns the roster was not read rather than receiving fabricated emails. Speaker
KEYS always come from the voice tags and are never guessed.

**Why the roster matters for the run:** participants resolve to Contacts by email, and the
seeded WF contacts are on `cib.wellsfargo.com` with OpenText sellers on `opentext.com`. If the
file's NOTE roster carries emails in a shape `roster()` reads, resolution is automatic. If it
does not, the run has two honest options, decided when I see the bytes: read the roster's actual
shape and extend `roster()` to it (deterministic, in scope), or map the voice-tag display names
to the seeded contacts by name (also deterministic, but it inherits the ASR-name hazard the
designator work just measured). **I will report which, with the reason, rather than pick
silently.**

## The staged run, exactly as it will execute

```
1. verify sha256(raw) == be8e5e95…                          # stop on mismatch
2. AAO_IntakeVTT.Result r = AAO_IntakeVTT.parse(raw)
   roster = AAO_IntakeVTT.roster(raw)                        # bind emails, or report the gap
3. insert AAO_Source__c:
     AAO_Source_Ref__c        = 'wf/opentext-aviator-2026-08-05-nf1'
     AAO_System_Ref__c        = 'teams:wfcib-aviator-s3-2026-08-05'
     AAO_Evidence_Occurred__c = 2026-08-05T14:00:00-04:00  (18:00:00Z)
     AAO_Account__c           = 001WD00000uYd9xYAC   (Wells Fargo & Company)
     AAO_Opportunity__c       = 006WD00000TWvH0YAL   (Aviator pilot, Stage 3)
     AAO_Origin__c            = 'ECI'                 (Teams capture; confirm field value set)
     AAO_Diarization__c       = 'Attributed'
     AAO_Normalized_Text__c   = r.normalizedText
     AAO_Speaker_Roster__c    = <roster json from voice tags + emails>
     AAO_Raw_SHA256__c        = sha256(raw)                  # so the stamp composes NF1+raw:
   # the before-insert trigger composes AAO_Normalizer_Version__c = NF1+raw:be8e5e95
   # after-insert records participants and marks internal via opentext.com + cib.wellsfargo.com
4. freeze: add the row to review/gate3/frozen-fixtures.md with counting status
     "AUTHORED - mechanism only, counts toward nothing" (verbatim, twentieth stamp)
5. run the pass on the pipeline AS IT STANDS (pre-designator), per the twenty-fifth stamp:
     call 0 resolve -> family sweep -> identify -> verify(batches) -> ledger
     -> join (internalDomains = {opentext.com, cib.wellsfargo.com... } )
     -> project to the live Wells Fargo map
   Priya and any other non-roster designator DROP or HOLD as today's code behaves.
   That is the honest Pass 1 baseline, not a failure of the test.
6. ship: pairs / claims / answers / coverage / regression-dispositions / timings
     into review/wf-opentext/, and tell Matthew the MAP is his grading surface.
```

**The sequencing overrides the twenty-fifth stamp already ruled, recorded so they are not
re-argued:** the caller-side join split does not block Pass 1 (a governor blowout rolls back and
prints the ceiling, which is a measurement); the absent-versus-too-narrow contract work is
pass-2-era. Both are design's call with the reasons on the record.

## Why I stopped here rather than push further

The next action is `verify the hash`, and it has no input. Building the Source row against
invented text would put fabricated speech under a real customer's opportunity on a live map,
which is the one thing this whole build refuses. Everything that could be built without the
bytes is built. The bytes are the gate.
