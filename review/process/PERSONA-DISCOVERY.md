# Persona injection · the discovery, not the proposal · 119th stamp item 3

The stamp's own division of labour: **CODE discovers; design proposes; Matthew rules the
mechanics.** So this reports what the org says and stops there. Nothing below is a
recommendation and nothing was written to the org.

| | |
|---|---|
| **Tree / org** | `/Users/thefinalmachine/Downloads/claude` on `main` · `00DWD00000DV7iT2AT` |
| **Method** | describes and row counts from the runtime, per the capability law. Read only. |

## 1 · THE PERSONA DEFINITION HAS A VENDOR HOME, and it is not what the stamp assumes

**`ALTF__Relationship_Map_Persona__c` exists.** Empty in this sandbox, zero rows ever.

```
ALTF__Account__c        REFERENCE  REQUIRED  -> Account
ALTF__Opportunity__c    REFERENCE            -> Opportunity
ALTF__Persona__c        MULTIPICKLIST
ALTF__Functional_Role__c MULTIPICKLIST
ALTF__AltifyId__c       STRING
Name                    STRING
createable=true  updateable=true  deletable=true
```

**There is no Contact lookup on it at all.** A persona in the vendor's model is a property of an
ACCOUNT (required) and optionally of a DEAL. It is not a person-shaped row.

## 2 · THE GHOST CANNOT BE A MAP ROW, and that is settled rather than open

The stamp leaves open "whether the ghost is a vendor row or ours ... never on the vendor map if
the vendor requires a Contact." Read from the runtime:

```
ALTF__Contact_Map_Details__c.ALTF__Contact__c   nillable = FALSE
```

**The vendor requires a Contact.** So an expected-but-unidentified persona can never stand on the
relationship map as a map row, which is the forty-seventh stamp's ratified narrower reading
holding on a third measurement. The open question is therefore narrower than the stamp states,
and it is a real choice rather than a formality:

- **a vendor PERSONA row** (`ALTF__Relationship_Map_Persona__c`), which needs no Contact, is
  opportunity-scoped, and appears to be the object the vendor built for exactly this; or
- **ours**, the shadow-person discipline, which the stamp already names as the nearest kin.

## 3 · THE FINDING THAT CUTS ACROSS THE STAMP'S PREMISE · NOTHING LINKS A PERSONA TO A STAGE

The stamp's item 3 opens: *"The sales process defines PERSONAS the stage expects on the
relationship map."*

I swept every `ALTF__` object in the org for a reference to
`ALTF__Relationship_Map_Persona__c`. **There are none. Not one field anywhere points at it.** And
the sales-process chain carries no persona column of its own:

```
ALTF__Sales_Process__c            -> no persona field
ALTF__Sales_Process_Stage__c      -> Sales_Process, Stage, SortOrder, Duration, thresholds
ALTF__Sales_Process_Stage_Qualifier__c -> Stage, Qualifier, Mandatory, Importance, Sort_Order
ALTF__Sales_Process_Qualifier__c  -> Question, Tip, UI_Readonly
```

**So the vendor surface does not today express "this stage expects these personas."** The persona
row is account-and-deal scoped and stage-blind. That is not an argument against the direction; it
is the shape of the gap the direction would be filling, and design should propose against it
knowingly rather than discover it mid-build.

## 4 · THE PERSONA VALUES ARE ORG CONFIGURATION, and one of them names Altify

```
ALTF__Persona__c (12): CEO | CRO | Executive Sponsor | Sales Leader | RevOps Leader |
  Enablement Leader | IT Leader | Procurement Lead | Altify Program Owner | Consultant |
  Legal | Partner

ALTF__Functional_Role__c (1): Placeholder
```

`Altify Program Owner` is the tell: **this is not a shipped taxonomy, it is this org's own
go-to-market**, configured for Altify selling Altify. A customer's org will carry different
values, and the second field is literally unconfigured.

**This is the seventy-sixth stamp's hazard on a new object.** That stamp found the same stored
value reading "Signature Approver" in one org and "Decision Maker and Approver" in another, and
ruled that a ladder keyed to labels ranks different things in different orgs. Anything that keys
behaviour to these twelve strings inherits that whole problem, and the ruled answer already
exists: values ship as org-overridable seed metadata keyed to stored values, never label strings
in logic.

## 5 · WHAT I DID NOT DO

No persona row was created, no picklist value proposed, no mechanism built. The reconciliation
rules the stamp sketches (a real person identified against a standing ghost eliminates it; a
process-state change may inject new ones) are design's to propose and Matthew's to rule, and
they now have the org's actual shape to be proposed against.

**One thing worth carrying into that proposal, from the hundred-sixteenth stamp rather than from
here:** an injected ghost is a machine-written row on a customer-visible surface, so it needs the
create-leg record and the disown discipline that machine-created Contacts already have, or it
becomes a row nobody can enumerate and therefore nobody can withdraw.
