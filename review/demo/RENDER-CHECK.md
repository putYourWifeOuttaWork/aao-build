# The render check · done, and it found a defect nothing else could

The hundred-seventh stamp's item 3 and the hundred-eighth's item 4 both left this as the
outstanding step. **It is done, and the sixty-fifth stamp's law earned its keep again.**

## What was done

A record page, `AAO_Demo_Run`, carrying `aaoRunDemo` above `aaoRunInspector`, deployed and opened
in Lightning App Builder against org `00DWD00000DV7iT2AT`.

**It is a NEW page and it is NOT activated.** No existing record page was edited and no assignment
was changed, so nothing in the org moved for any user. It mirrors `AAO_Pipeline_Internal`, which is
the precedent for an AAO-owned Opportunity page already in the tree.

**The preview record App Builder chose is "AAO Demo - Tungsten Rehearsal", an unrelated
opportunity. Not Wells Fargo, which is untouched, and not the harness deal.**

## What was seen

```
Run the pass on this deal
  What was this? (optional)                                  [Discovery call, 16 August]
  Who was on the call? (key, Display Name, email — one line)  [marcus, Marcus Reyes, marcus…]
  Paste the transcript, note or email                         [speaker  their words...]
  [ Run the pass ]   ← greyed, correctly refusing an empty form
  The pass reads what is here and establishes only what the words carry.
  Every stage below is drawn from what the run journalled, never estimated.

Run Inspector
  No runs have touched this opportunity yet.
```

All four inputs present with their placeholders, the helper text intact, and the Inspector
beneath correctly reporting no runs — because this preview record has none, which is the honest
answer rather than an empty component.

## THE DEFECT · the button was inverted, and only the page could show it

```html
<lightning-button ... disabled={canRun}>
```

`canRun` is TRUE when the run is possible. **So the button was disabled exactly when it could run,
and enabled when it could not.** The one control on the surface did the opposite of its job.

**Why it survived everything else:** the suite was green, the controller was proved end to end
from the runtime, and the pass ran twice through this very component's controller. **None of them
can see a button.** The sixty-fifth stamp says it exactly — *controller-proven is not
rendered-proven* — and this is its second confirmed instance.

**Why the shape exists at all, kept as the standing note:** LWC markup has **no negation
operator**, so an inverted condition must be exposed as its own named getter. `disabled={!canRun}`
is not expressible, and the tempting `disabled={canRun}` compiles, deploys and reads almost right.
Fixed with a `cannotRun` getter carrying that reason in its own comment.

**Re-rendered after the fix: the button is greyed with empty fields.** Correct.

## What is proved, and what is still not

**PROVED:** the component renders on a Lightning page; layout holds; every label, placeholder and
helper line is what was written; the disabled logic is correct; the Inspector coexists with it on
one page.

**NOT PROVED, and named rather than implied: the polling loop under a real render cycle.** The App
Builder canvas is a preview and does not execute the Apex actions, so `startRun`, the three-second
poll, the stage list filling in, and the finish-and-stop behaviour have been proved only from the
runtime. **Seeing the stages tick over live needs the page activated on a record and a real
paste** — which is a one-click activation on this page, and Matthew's call whether to make it the
org's Opportunity page or leave it as a page he opens deliberately.

**Suite unchanged at 516, 515 AAO passing. Nothing tuned. Wells Fargo untouched.**
