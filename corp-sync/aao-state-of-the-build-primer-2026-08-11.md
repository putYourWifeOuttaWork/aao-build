# AAO · State of the Build · 11 August 2026

**This is a dated snapshot written for humans. The live ledger is `CODE-INBOX.md` in the shared build folder and the Altify Agency project; when this document and the ledger disagree, the ledger is current and this page is old. Replace this page at each fold; never edit it in place.**

## What AAO is, in two sentences

Altify Always On is a Salesforce-native layer that reads a deal's real conversations and verifies, per opportunity, which necessary conditions are actually true, binding every establishment to the verbatim words that produced it. It verifies, it never predicts: a value lands on the relationship map only with its quote, its byte offset, and an unbroken evidence trail behind it, and a human edit beats the machine forever.

## Where the build stands

**Efficiency: met and measured.** One 73-minute production transcript runs source-through-projection in about 59 seconds inside Salesforce, 7 model calls, clear of every per-transaction governor limit, with the full evidence trail (source, contract, pair, claim, answer, map row) verified live in the org. The old shape's 59 callouts became 7; its 150 seconds of resolution became 4, deterministic.

**Accuracy: the phase is live and its first graded production measurement is in.** Matthew graded the new two-read pipeline against the old pipeline on identical production speech, 83 establishments: the new shape graded 87.5 percent precision on what it upheld with 2 wrong refusals, against the old shape's 80 percent and 6. The machine's marking also caught every row about our own seller and kept her off the customer's buying committee. Zero fabrication stands across every corpus to date: quotes locate byte-exact or they are discarded and counted.

**The last gate on the People module is stability.** Identical input can produce different maps across reruns (a measured flicker in which true things get affirmed, never an invented one). A temperature-zero probe on the verifier is running now, with N-of-M voting held in reserve. A clean probe closes People; Problems, Politics, and Process then ride the same pass as added questions, not new pipelines.

## The laws that do not move

Production is read-only, unconditionally. No dependency on any Altify package version: the system runs with Altify absent. Nothing of ours lands on objects we do not own. Every value walks back to verbatim evidence; wrong records retire in place with reasons, nothing is ever deleted; no dismiss button exists anywhere. Corrections go into documents, never chat.

## Hard deadline

Dreamforce, September 2026. Build proven internally on Altify's own data first, then packaged for one or two pilot customers.
