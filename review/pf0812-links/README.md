# The vendor link model, read before writing · fifty-seventh stamp item 3, leg (i)

**The stamp ordered a read and a report before any write:** *"CODE first reads the vendor's link
model to map panel slots to link types (Informer and Owner are known; what carries 'responsible' and
'impacted' on each panel is read from the org, not guessed) and reports what exists before writing."*
Read from `aossb2` by describe. **The finding stops the deterministic leg where it stands.**

## What exists

| object | fields |
|---|---|
| `ALTF__Insight_Card_Contact__c` | `ALTF__Contact__c`, `ALTF__Insight_Card__c`, **`ALTF__Type__c` PICKLIST {Informer, Owner}**, `ALTF__AltifyId__c` |
| `ALTF__Insight_Card_Edge__c` | `ALTF__Insight_Card__c`, `ALTF__Solution_Insight_Card__c`, `ALTF__Insight_Section__c` |

**THE CARD-TO-PERSON LINK CARRIES EXACTLY TWO TYPES, `Informer` AND `Owner`. There is no
`Responsible` and no `Impacted`.** The edge object links cards to cards and to sections; it reaches
no Contact at all, so it cannot carry a person relationship either.

## What that means for the ruled leg, stated plainly

**RESPONSIBLE has a plausible home; IMPACTED has none.**

- **Responsible → `Owner`.** The Goal panel asks *"Who is the Decision Maker responsible for this
  Goal?"*, and the card object carries no decision-maker field of its own, so that panel slot is
  almost certainly bound to an `Owner` link. That is an inference from two facts (the question
  exists, no field backs it) and it is exactly the kind of inference the stamp told me to report
  rather than act on. **Not written.**
- **Impacted → nothing.** No picklist value, no second junction, no field. Writing impacted people
  as `Owner` would assert that the people an obstacle lands on are accountable for it, which is a
  different claim and a wrong one.

## Options for design, with costs, none chosen

1. **Use `Owner` for responsible on Initiatives, leave impacted unwritten.** Ships half the ruling
   now. Cost: if the panel binds `Owner` to something else, we are writing into the wrong slot on a
   customer-visible surface, and the check for that is a human opening the panel.
2. **Confirm the binding with Altify, then write both if a slot exists.** Cost: waiting.
3. **Carry responsible and impacted in the card details text**, machine-written and watermarked, the
   way the decision-maker enrichment already lands. Cost: visible but unstructured, so nothing can
   query or roll it up.
4. **Add our own junction and render it in the Run Inspector** rather than the vendor panel. Cost:
   a surface of our own to maintain, and it is invisible in the vendor UI Matthew is reviewing in.

**Nothing was written.** The org-ownership rails hold: data rows on their objects, never metadata,
so adding a picklist value to `ALTF__Type__c` is not ours to do.
