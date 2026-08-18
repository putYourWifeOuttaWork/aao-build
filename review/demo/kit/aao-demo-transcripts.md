# AAO demo transcripts · selling Altify to Brightwell Group

Three calls on one deal, in order, building from a skeptical discovery to a pilot commitment. Run them **in sequence on the same deal** (the harness deal) and the map fills in, sentiment moves, new people appear, and the decision criteria firm up — all cited back to the words below.

**How to run each call:** on the deal's **AAO Pipeline** tab, paste that call's *Participants* into **Who was on the call?**, paste its *Transcript* into **Paste the transcript**, set a label, and hit **Run the pass**. Then reset between full rehearsals with the **Purge this deal** button (CODE is wiring it now).

**Two things that matter:** copy the transcript from a plain-text editor so the tabs survive (each line is `speakerkey` + a TAB + their words), and the seller (`@altify.com`) is intentionally kept off the buyer's map — a good thing to point at. Brightwell people are `@brightwell.example`.

The arc, so you can narrate it: **Call 1** surfaces the problem and a skeptic (Marcus). **Call 2** brings the CFO (Karen) in cold and turns her with cited evidence; Raj's criterion hardens; Priya wants a pilot. **Call 3** clears security, Karen commits budget, Marcus endorses, and it heads to a pilot-to-rollout close.

---

## Call 1 — Discovery  ·  label: `Brightwell — discovery, call 1`

**Participants** (paste into *Who was on the call?*):

```
sam, Sam Ruiz, sam.ruiz@altify.com
dana, Dana Okafor, dana.okafor@brightwell.example
raj, Raj Patel, raj.patel@brightwell.example
marcus, Marcus Reyes, marcus.reyes@brightwell.example
```

**Transcript** (paste into *Paste the transcript*):

```
sam	Thanks everyone. Dana pulled you together, so before I say a word about Altify I just want to understand how revenue actually runs at Brightwell today.
dana	Happy to set it up. We're about forty reps across three regions, and my honest problem is our forecast is off by around twenty percent every quarter. I can't tell you which deals are real until they either close or die.
marcus	I'll push back a little, because I've heard the forecast pitch before. We bought a tool two years ago that promised exactly this and my reps never touched it. Adoption sat at maybe forty percent and then we quietly stopped paying for it.
sam	That's fair, and honestly the adoption story matters to me more than the forecast one. Raj, you own the systems side. What does that forty percent look like from where you sit?
raj	It looks like a graveyard of required fields nobody fills in. We bolted a methodology onto Salesforce, but it lives in a separate tab, so the reps run the deal in their head and backfill the tool the night before the QBR. The data is fiction.
dana	And the fiction costs us. We lost about one point two million in slipped deals last year that looked green in the system right up until they slipped.
marcus	That number I believe, because I lived it. The Henderson deal was commit for two straight quarters and then vanished in a week.
sam	So the real problem isn't that you lack a methodology. It's that the methodology isn't where the selling happens. That's the whole thesis behind what we do. Altify runs inside Salesforce, on the opportunity, not in a side tab.
dana	That's the part I want my team to see. If it's native, and it's on the record they already open every day, I think adoption stops being a fight.
raj	The thing I'll need to prove is that it reads what's already there. If I have to migrate three years of history by hand, this is dead on arrival for me.
sam	Understood, and that's a fair test. Let me ask the other direction. What would make this a clear win for each of you a year from now?
dana	A forecast I can defend to the board without a spreadsheet full of gut feels.
raj	Adoption above eighty percent without me nagging a single person.
marcus	Honestly? My best rep spends nine hours a week on admin. Give her half of that back and I'll champion this myself.
sam	Those are three numbers I can work with. Next time I'll bring our solution architect and show the native piece against your own process rather than a slide. Who else needs to be in the room?
dana	Our enablement lead, Priya. If she doesn't buy it, adoption won't happen no matter what I say.
marcus	And keep it honest. If it can't do something, tell me plainly, because that's how I'll know the rest is true.
sam	Deal. I'd rather lose a feature than lose the relationship.
```

*Builds:* Dana → champion/supporter (VP RevOps); Marcus → VP Sales, skeptic, conditional ("I'll champion it myself"); Raj → user + the native/reads-existing-data criterion. Cards with numbers: forecast off 20%, adoption 40%, $1.2M slipped, 9 hrs/week admin. Sam stays off the map.

---

## Call 2 — Evaluation  ·  label: `Brightwell — technical eval, call 2`

**Participants:**

```
sam, Sam Ruiz, sam.ruiz@altify.com
alex, Alex Chen, alex.chen@altify.com
dana, Dana Okafor, dana.okafor@brightwell.example
raj, Raj Patel, raj.patel@brightwell.example
priya, Priya Nair, priya.nair@brightwell.example
karen, Karen Lindqvist, karen.lindqvist@brightwell.example
```

**Transcript:**

```
sam	Good to see everyone again. Alex is our solution architect and he's driving today. Dana, you brought Karen, so welcome Karen.
karen	Thank you. I'll be direct. I hold the budget and I'm the one who signs, so I came looking for the reasons this won't work.
dana	Which is exactly why I wanted you here early instead of at the very end.
alex	Then let me start where Raj left us last time. This is your actual Brightwell org, and this is the opportunity record your reps already open. Everything I show lives right here. No separate login, no side tab.
raj	Show me the history question. This contact map, this committee. Did you build that by hand, or did it read what we already have?
alex	It read it. Every contact on this map came from your existing opportunity contact roles. We didn't migrate anything, we projected onto what was already there.
raj	Okay. That's the exact thing I said was dead on arrival, and it isn't. That matters to me a lot.
priya	My worry is different. My reps will not read a methodology manual. If this asks them to learn a new language, they'll route around it the way they did last time.
alex	They don't learn anything. The system reads the calls and emails they already send and fills the map itself. The rep opens a relationship map that's already most of the way right and just corrects what's wrong.
priya	If that's real, it changes my whole enablement plan. Half my job today is chasing people to update fields.
karen	What does it cost, and what am I comparing it against?
sam	For forty reps it's a hundred and eighty thousand a year. You're comparing that to the one point two million Dana watched slip last year, and to the tool you already pay for that nobody opens.
karen	I'll be honest about my scar. The last platform we bought couldn't produce an audit trail when compliance came asking, and I lost a quarter of my year cleaning it up. So my bar isn't the price. It's whether I can trust the number it shows me.
alex	Then this is the part you'll care about most. Every value on this map is cited. Click any status and it shows you the exact sentence, from the exact call, that established it, with the date and the speaker.
karen	Show me one.
alex	This one says Marcus is a supporter. Here's the reason, in his own words on the discovery call. Give her half of that back and I'll champion this myself. Nothing here is inferred. It's traced to something a real person actually said.
karen	That is more than my current system does. I'm not sold, but that's the first thing today that lowered my blood pressure.
dana	For the record, that's a big movement for Karen.
priya	I want to pilot it with one region before we commit anything. If adoption in that region beats forty percent, I'll take it to the whole floor myself.
sam	That's exactly how I'd want to earn it. One region, sixty days, measured honestly against your current baseline.
raj	My one hard requirement, and I want it in writing. It stays Salesforce-native and it never requires a separate data warehouse. The day it needs its own database, security gets involved and this becomes a year-long project.
sam	Noted, and it's native by design. Which is a good segue, because security is exactly who I think we bring in next.
karen	Yes. If Tomas signs off on the security review, I'll open the budget conversation. That's my condition.
```

*Builds:* Karen enters cold as approver/decision-maker and **moves** on cited evidence ("lowered my blood pressure"); Priya → user/supporter wanting a one-region pilot; Raj hardens the native / no-warehouse criterion; the citation of Marcus's own line reinforces him. Coverage rises as people recur.

---

## Call 3 — Security & business case  ·  label: `Brightwell — decision, call 3`

**Participants:**

```
sam, Sam Ruiz, sam.ruiz@altify.com
dana, Dana Okafor, dana.okafor@brightwell.example
karen, Karen Lindqvist, karen.lindqvist@brightwell.example
marcus, Marcus Reyes, marcus.reyes@brightwell.example
tomas, Tomas Reyes, tomas.reyes@brightwell.example
```

**Transcript:**

```
sam	Thanks all. Tomas, you've had our security package for a week, and Karen made you the gate, so let's start with you.
tomas	I've been through it. SOC 2 Type Two is current, single sign-on through our Okta works, and because it's Salesforce-native there's no new data store for me to review. That frankly removes my biggest objection before I even raise it.
karen	That's the sentence I needed to hear.
tomas	My one open item is data residency. We have EU customers, and that data has to stay in region. I didn't see it spelled out anywhere.
sam	It's configurable per workspace, and I'll get you the region controls document today so it's in writing and not just my word in a meeting.
tomas	If that holds up, I'll sign off on the security side. On the record, I'm comfortable.
dana	Then let me put the business case on the table while we're all here. If we get adoption to eighty percent and the forecast tightens from twenty percent off to even ten, that's most of the one point two million back in the first year.
karen	I've been running that same math. At a hundred and eighty thousand against that, I'm not fighting the price anymore. My fight was always trust, and the citations answered it.
marcus	I'll say what I said the first day. I've been burned, so I don't hand out endorsements. But I've watched this thing quote my own reps back to me accurately three separate times now, and I can't argue with it. I'm in, and I'll tell the floor I'm in.
dana	That's the whole game, Marcus. If you say it out loud, they'll adopt it.
karen	Then here's where I land. Tomas gets his residency document and signs the review, we run Priya's one-region pilot for sixty days, and if adoption clears sixty percent I approve the full rollout before Q1.
sam	That's a plan I can hold myself to. Security doc to Tomas today, pilot scope to Priya this week, and I keep to the Q1 date.
marcus	One condition from me. When it's wrong, it has to be easy to fix, because the day a rep can't override it is the day they stop trusting it.
sam	Agreed, and it's built that way. A human edit always wins and it's never overwritten. The machine proposes, your people decide.
dana	Then I think we know our next step. Let's get the pilot moving.
```

*Builds to the close:* Tomas → security approver + data-residency criterion; Karen commits budget (fully warmed); Marcus endorses out loud (supporter → advocacy); Dana consolidates. The human-override line is a clean note to end on.
