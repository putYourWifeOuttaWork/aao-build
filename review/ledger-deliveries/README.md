# Ledger stamps as delivered, kept as carry provenance

Design's stamps reach this device by hand and are spliced into `CODE-INBOX.md`. The delivered
artifact is kept here so a splice can be re-verified against the bytes it was made from, rather
than against a memory of them.

| file | bytes | sha256 | spliced |
|---|---|---|---|
| `aao-stamp-87.md` | 7,126 | `d89e2226…` | yes, 410,809 + 7,126 = 417,935 exact |

The eighty-eighth and eighty-ninth stamps arrived through chat rather than as files, so no delivery
artifact exists for them; their splice arithmetic is recorded in the commit and in BUILD_JOURNAL
(417,935 + 17,317 = 435,252 exact).

**The standing gap, per the eighty-ninth stamp's item 10:** stamps land in the project and reach
this device only when carried. `CODE-INBOX.md` is git-tracked and pushes to `origin/main`, so
writing a stamp there is the whole channel, both devices, no hand-carry.
