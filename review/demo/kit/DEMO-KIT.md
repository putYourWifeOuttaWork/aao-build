# AAO demo kit · 19 August · enterprise SaaS

Everything for tomorrow: three transcripts, their rosters, and a purge script. All verified against the source, not remembered. Write target is always the **harness deal** (`AAO DEMO HARNESS DEAL`, `006WD00000Tn91RYAR`) — never Wells Fargo.

## Two rules the surface enforces (why the files look the way they do)

1. **Turns are `key⇥utterance`** — a real TAB between the speaker key and their words, one turn per line. The `.txt` files already have this; open one, select-all, copy, paste. Don't retype it as "Name: words" — it won't segment.
2. **Side is set by email domain.** Internal (kept off the buyer's map) = `@altify.com`. Everyone else is a buyer and lands on the map. That's why the rep is `sam@altify.com` — and it's a good beat to point at: *our own rep never appears on the customer's committee, by construction.*

The roster box wants `key, Display Name, email` — one per line, commas (no tabs). The `key` must match the speaker label in the transcript.

---

## The flow (about 10 minutes)

**Step 0 — clean the board once.** Run `demo-purge.apex` (see bottom). The harness deal carries CODE's test residue; this zeroes it. Expect `AFTER cards=0 claims=0 answers=0 maprows=0`.

**Step 1 — rehearse (proves the live polling loop).** On the harness deal's `AAO_Demo_Run` page, paste the **rehearsal** roster + transcript, Run, and watch the stages tick in. This is the one thing never proven under a real render cycle — so do it before the room. ~30–40s.

**Step 2 — purge again.** Run the script. Back to a clean board.

**Step 3 — the room.** Paste the **room** roster + transcript, Run. One clean call → a map with three buyers, roles, sentiment, problems with numbers on the cards, and a decision criterion. Sam is absent from the map — point at that.

**Step 4 (optional, the money shot) — watch it firm up.** *Without purging*, paste **call 2**. A new person (the CISO) appears, a second criterion lands, and Karen's sentiment moves up as the same map accretes. This is the "maps firm up over calls" thesis on screen. (It adds only *new* insight — it deliberately doesn't restate an obstacle, because restatement would duplicate a card, the one open decision.)

**Step 5 — after.** Run the purge once more so the deal is clean for next time.

Two things to avoid in the room: don't re-paste the same transcript twice on one deal (the idempotence guard refuses it — that's why rehearsal and room are different bytes), and don't hand-edit a map cell before purging (the human-watermark guard will then correctly refuse to purge).

---

## 1 · REHEARSAL  (file: `demo-rehearsal.txt`)

**Roster** (paste into "Who was on the call?"):

```
sam, Sam Ruiz, sam.ruiz@altify.com
miguel, Miguel Alvarez, miguel.alvarez@cedarpark.example
tanya, Tanya Brooks, tanya.brooks@cedarpark.example
```

Label: `Cedar Park — intro call`. Transcript: open `demo-rehearsal.txt`, copy all, paste.

## 2 · THE ROOM  (file: `demo-room.txt`)

**Roster:**

```
sam, Sam Ruiz, sam.ruiz@altify.com
dana, Dana Okafor, dana.okafor@brightwell.example
raj, Raj Patel, raj.patel@brightwell.example
karen, Karen Lindqvist, karen.lindqvist@brightwell.example
```

Label: `Brightwell — platform evaluation`. Transcript: `demo-room.txt`.

What to expect on the map: **Dana** — supporter, advocacy ("I'll champion it"), the 9-hrs/week obstacle and the goal to cut it; **Raj** — user, owns the rollout, the "native Snowflake lineage" criterion; **Karen** — approver / decision maker, skeptical warming ("my bar is high" → "if that holds up I'm listening"), the audit-trail pressure and the price; **Sam** — not on the map (internal).

## 3 · CALL 2 · firm-up  (file: `demo-call2.txt`)

**Roster:**

```
sam, Sam Ruiz, sam.ruiz@altify.com
dana, Dana Okafor, dana.okafor@brightwell.example
karen, Karen Lindqvist, karen.lindqvist@brightwell.example
tomas, Tomas Reyes, tomas.reyes@brightwell.example
```

Label: `Brightwell — security review`. Transcript: `demo-call2.txt`. Paste this **without purging** after the room call to show the map accrete: Tomas appears (security evaluator), a data-residency criterion lands, Karen moves up.

---

## The purge script  (`demo-purge.apex`)

Dev Console → Debug → Open Execute Anonymous Window, paste, Execute. Or `sf apex run -f demo-purge.apex -o aossb2`. It deletes cards first (junctions cascade), then everything else by run key via the lawful `AAO_Purge`. It keeps the Source rows by design — which is exactly why each run needs fresh bytes. Read the `BEFORE`/`AFTER` lines in the debug log to confirm a clean board.

If you ever want a *completely* fresh deal instead of purging, tell me and I'll stand up a second throwaway opportunity so rehearsal and room never touch the same record.
