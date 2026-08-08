# Gate 3 · the frozen fixture list

**NF1 only, per the twelfth stamp.** The stored form is the fixture form; byte offsets mean
nothing against any other bytes. Raw rows stay as provenance and are listed nowhere.

**Nothing runs until this list is confirmed.**

> **TAKE THE FIXTURE FROM THIS LIST, NEVER FROM THE ORG.** Ruled 7 August. The two 29 July
> rows are permanently indistinguishable by stamp - both carry the uncomposed `NF1`, because
> the composed stamp arrived after them and the restamp was refused by the immutability rule
> that protects every span already verified against those records. **This list is the only
> thing that disambiguates them.** A query against the org picks whichever row sorts first,
> and half the time that is the wrong artifact with byte offsets that mean nothing.

## Frozen and ready · 2 unseen fixtures

| # | ref | artifact sha256 | occurred | duration | speakers | account | deal / stage | shape |
|---|---|---|---|---|---|---|---|---|
| 1 | `emerson/aspentech-2026-07-29-nf1` | `9e9740060bd348a1b3f64e21c1352d19bb942a7c43f4eb083cea23354b24a26c` | 29 Jul 20:00:55 | 1,245 s | 3 | Emerson Electric Co. | Insights 500 Full Insight (Stage 3) | short, small roster, same account as the training set, later in the deal |
| 2 | `bv/biweekly-2026-06-24-nf1` | `2bed419d1079cdde1cbe0881e03ba40466f6466156596a980b80a842b76f25f9` | 24 Jun 07:01:00 | 2,435 s | 4 | Black & Veatch | Community Licenses-150 (Stage 1) | **long, account-side call, non-Emerson account, early stage** |

Fixture 2 satisfies three of the ruled mix requirements on its own: account-side, non-Emerson,
different stage. Fixture 1 varies roster size, length and deal position against the training set.

## The training set, named so it is never counted as unseen

| ref | artifact sha256 | why it is excluded |
|---|---|---|
| `emerson/aspentech-2026-06-17-nf1` | `ec8e717045f8701534963576ded2a736df5a27b5314721f20b6aa004d5f25a5f` | everything was calibrated against it; its precision no longer predicts anything |

## BLOCKED · the three or more production transcripts

**No production org is authorized in this environment.** The authorized connections are
`altify-dev`, `altify-pbo` (never read, standing), `aossb2` (the sandbox), and `ice`. There is
no `altify--prod`, so **the production pull cannot be performed from here at all** - not a
permission question, a connection that does not exist.

This is named rather than worked around. **The two substitutions available are both wrong**:
`ice` is a demo org whose transcripts are not customer speech, and the synthetic `dummy/*`
Sources in the sandbox are authored fixtures, which is the training-set problem again wearing a
different name. Gate 3's whole point is unseen customer speech, and neither is that.

**Owed from Matthew:** either a production connection authorized for this environment, or the
transcripts pulled and handed over as files for normalization here.

## A stamp that is not distinguishing what it claims to

Both 29 July rows carry `AAO_Normalizer_Version__c = NF1` and **different artifact hashes**
(`9e974006` and `d0606eac`). One normalizer version, two byte outputs.

`9e974006`, the `-nf1` suffixed ref, is the fixture. The other is an earlier normalization kept
as provenance. **But the version stamp cannot tell them apart**, which is the two-halves
provenance law's own complaint pointed at normalization: a version string that does not cover
an input that changes the output is decoration. Named, not fixed, and not blocking gate 3;
worth a ruling before the corpus grows.

*(For contrast, the B&V raw row carries `AAO_Normalizer_Version__c = null` and is correctly
excluded by the NF1-only rule with no ambiguity at all.)*
