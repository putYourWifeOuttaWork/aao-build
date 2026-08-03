# B&V fixture extract · MANIFEST · read before loading

**Provenance.** Extracted 2 August 2026 by design-side Claude via MCP read from Altify production, org `00DHn000006jYatMAE`, verified by Organization query (IsSandbox false) before any read. Read-only throughout; nothing was written to production. Target for all inserts: `altify--aossb2` only.

**Contents and counts, verified at build:** `accounts.json` 3 · `opportunities.json` 6 (4 open: two Casey Lindlaw renewals at Stage 3 closing 2028-03-31, two Renee Martin expansions at Stage 1; 2 closed-won, Chris Day, for the traversal shape) · `contacts.json` 46 · `opportunity_contact_roles.json` 125 · `users_reference.json` 8 (prod owners, for deliberate remap; NOT to insert).

**What is deliberately absent.** No `ALTF__Contact_Map_Details__c` rows and no Altify map data of any kind: building the map surface is the product's job in the harness. Measured for the record and not extracted: prod holds 129 CMD rows across this account (44 account-level, 44 on the Community-150 expansion, 19 on each closed-won, 3 on the demo opp), and the set of contacts those rows reference is byte-identical to the 46 the contact roles reference. So the fixture's contact set is complete against both sources.

**Load order and remap notes:**
1. Accounts first. Slalom must exist before contacts (two contacts parent to it) or those two get AccountId remap. The parent-typed duplicate B&V account is optional; no children reference it in this fixture.
2. Users are reference only. Remap every OwnerId to sandbox users deliberately, and keep the ROLE pattern, not just validity: Casey Lindlaw (CSM role) owns the renewals, Renee Martin (AE role) owns the expansions and the account. The resolver's Test 1 will eventually read owner roles; seed the pattern it should see. **Chris Day is INACTIVE in prod** — closed-won owner must remap or insert fails.
3. Contacts after accounts. `ReportsToId` chains are intact up to the CEO (Mario Azar) and reference only IDs inside this file; load in dependency order or two passes (insert, then update ReportsToId).
4. Opportunities after accounts, with the one-record probe first per §P7.2 step 1 item 2 (read what ALTF creates on insert before bulk).
5. Contact roles last. Four rows carry Role=Approver and IsPrimary=true (Joy Johnson twice, Patrick Hogan twice); all other 121 rows are role-null.
6. Prod IDs will not survive insert. Preserve them as external references (a mapping file prod-id to sandbox-id at load time) so the transcript adjudication can name records across both orgs.
7. Counts verified after load, not insert success: 3/46/6/125 or the run does not start.

**Byte-exactness notes, kept deliberately:** two names carry mojibake exactly as prod stores them ("Steffanie Edwards HÃ¤fele", "Patrick Oâ€™Neill") and one title is truncated mid-word in prod ("...Latin Americ"). Loaded verbatim per the paraphrase law; the identity matcher should see what production actually contains. Real emails retained deliberately per §P7.2 step 1 item 5, decision recorded.

**The transcript is NOT in this bundle.** Matthew supplies the Casey call transcript separately; it enters through the front door as a Source, never as fixture data.
