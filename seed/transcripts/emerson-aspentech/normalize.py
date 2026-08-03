#!/usr/bin/env python3
"""
Emerson / AspenTech transcript normalizer, session 74.

The transform is a script and not a hand edit ON PURPOSE. The Emerson fixture manifest
records that its other files were "transcribed from MCP query results by design, not
machine-piped", and names that as the place slippage enters. This artifact is the thing
spans byte-verify against, so it is piped.

TWO THINGS ARE REMOVED AND BOTH ARE REMOVED BECAUSE THEY ARE NOT SPEECH.

1. Viewer chrome: "Move the player to N seconds in the call". These are the ECI transcript
   viewer's seek links, emitted between every utterance. Same decision as the B&V transcript
   packaging on 2 August, and the same reversibility: if CODE or design prefers the
   chrome-inclusive raw as the frozen artifact, the raw paste is kept beside this file and
   this one is superseded rather than edited.

2. ECI signal tags: "Procurement Process Engaged", "Procurement Process Engaged (2)",
   "Pricing", "Next Step". These lead an utterance body with no timestamp of their own.
   THEY ARE EINSTEIN'S INFERENCE ABOUT THE CALL, NOT WORDS ANYBODY SAID. Leaving them in
   the artifact would let a reader quote a machine's label as a human's sentence and pass
   byte verification while doing it, which is a fabrication route rather than an over-read.
   The board's standing hazard is that ECI's stamps are inference that misfires in both
   directions; this applies the same rule one level down. They are written to a sidecar with
   their speaker and timestamp so nothing is lost.

NOT REMOVED, deliberately: every transcription artefact stays exactly as pasted. "Koopa" and
"CUPA" for Coupa, "Anne Fatima" for "and Fatima", "Van.", "Sun.", "Sh.", "Shh.", "M.", "Mmh.",
"Fat, am I gonna sign it" for "Pat", "the signs SOW" for "the signed SOW". A normalized quote
is a paraphrase and a paraphrase cannot byte-verify.

ONE JUDGMENT CALL, FLAGGED RATHER THAN BURIED: "Setup." at 16:11 is KEPT as speech. It
occupies a whole utterance slot with its own speaker and its own timestamp, which no ECI tag
in this file does, and it carries a full stop. Every removed tag leads a body without one.
It is more likely ASR noise than a label, and the cost of being wrong is one junk item that
binding drops, versus deleting something a person said.
"""

import hashlib
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
RAW = HERE / "RAW-PASTE-2026-08-03.txt"
OUT = HERE / "emerson-aspentech-transcript.txt"
TAGS_OUT = HERE / "eci-signal-tags.txt"
SHA_OUT = HERE / "emerson-aspentech-transcript.sha256"

CHROME = re.compile(r"^Move the player to [\d.]+ seconds in the call$")
STAMP = re.compile(r"^\d{1,2}:\d{2}$")

# Closed set, matched exactly. A tag we have not seen before stays in the speech and shows up
# as a strange item rather than being silently deleted by a loose pattern.
ECI_TAGS = {
    "Procurement Process Engaged",
    "Procurement Process Engaged (2)",
    "Pricing",
    "Next Step",
}


def main() -> int:
    raw = RAW.read_text()
    raw_lines = raw.split("\n")

    chrome_removed = 0
    kept = []
    for line in raw_lines:
        if CHROME.match(line.strip()):
            chrome_removed += 1
            continue
        kept.append(line)

    # Walk the stream. A speaker line is any non-empty line immediately followed by a stamp.
    turns = []           # (speaker, stamp, [body lines])
    tags_found = []      # (stamp, speaker, tag)
    i = 0
    n = len(kept)
    while i < n:
        if not kept[i].strip():
            i += 1
            continue
        if i + 1 < n and STAMP.match(kept[i + 1].strip()):
            speaker = kept[i].rstrip()
            stamp = kept[i + 1].strip()
            i += 2
            body = []
            while i < n:
                # Stop at the next speaker/stamp pair.
                if kept[i].strip() and i + 1 < n and STAMP.match(kept[i + 1].strip()):
                    break
                body.append(kept[i])
                i += 1
            while body and not body[0].strip():
                body.pop(0)
            while body and not body[-1].strip():
                body.pop()
            if body and body[0].strip() in ECI_TAGS:
                tags_found.append((stamp, speaker, body[0].strip()))
                body.pop(0)
                while body and not body[0].strip():
                    body.pop(0)
            if body:
                turns.append((speaker, stamp, body))
            continue
        i += 1

    # NF1, THE CANONICAL NORMAL FORM, and getting this wrong is why the first Emerson seed
    # could never have projected.
    #
    # AAO_NormalForm.turns() segments an Attributed artifact by splitting on newline and
    # taking the text before the first TAB as the speaker key; a line with no tab
    # "contributes no turn". AAO_NormalForm.compose() shows the shape it expects:
    # speakerKey + "\t" + utterance, joined by newlines, one turn per line.
    #
    # The first packaging used the ECI viewer's own block layout (speaker, newline, stamp,
    # newline, text). It has no tabs, so turns() returned ZERO turns, containing() returned
    # null for every span, and AAO_SpanVerifier failed every one on "the range is not
    # contiguous inside a single speaker turn" AFTER the byte compare had already passed.
    # Measured session 74 on both artifacts: TABS=0, TURNS_FOUND=0. The B&V artifact carries
    # the same defect and is frozen; this one is not, so this one is fixed.
    #
    # Timestamps cannot live in the line: the speaker key is everything before the first tab
    # and has to match the roster key exactly, so "Wendy Higley [00:03]" would resolve to
    # nobody. They go to a sidecar index instead, keyed by utterance offset, so adjudication
    # can still find the moment without the artifact carrying anything unquotable.
    out_lines = []
    stamp_index = []
    offset = 0
    for speaker, stamp, body in turns:
        utterance = " ".join(" ".join(body).split())
        line = speaker + "\t" + utterance
        stamp_index.append((stamp, speaker, offset + len(speaker) + 1, len(utterance)))
        out_lines.append(line)
        offset += len(line) + 1
    # TRAILING NEWLINE KEPT, and the reason is worth stating because it looks like an error.
    #
    # AAO_Normalized_Text__c is a LongTextArea and LongTextArea STRIPS A TRAILING NEWLINE on
    # save, measured session 73. So the delivered file and the stored text differ by exactly
    # one byte and carry two different fingerprints, BOTH of which are correct about different
    # things: AAO_Artifact_SHA256__c is the file as handed over, AAO_SHA256__c is what the org
    # holds, and SPANS BYTE-VERIFY AGAINST THE LATTER. The manifest carries both.
    #
    # Session 74 tried to collapse the two by dropping the newline here. That was the wrong
    # instinct twice over: it makes this file disagree with the Source already inserted from
    # it, and the fields are frozen by law with no exception, so the row cannot be brought
    # along. The B&V artifact has the same one-byte relationship and is not being changed
    # either. Recording the difference beats hiding it.
    # No trailing newline: compose() joins lines and stops, and LongTextArea would strip one
    # anyway, which is what put two fingerprints on the first seed.
    text = "\n".join(out_lines)

    OUT.write_text(text)
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
    SHA_OUT.write_text(digest + "  " + OUT.name + "\n")

    idx = ["# Utterance timestamps, kept beside the artifact because NF1 has no room for them.",
           "# The speaker key is everything before the first tab and must match the roster key,",
           "# so a stamp inside the line would resolve to nobody.",
           "# stamp\tspeaker\tutteranceStart\tutteranceLength", ""]
    for stamp, speaker, st, ln in stamp_index:
        idx.append(f"{stamp}\t{speaker}\t{st}\t{ln}")
    (HERE / "timestamp-index.tsv").write_text("\n".join(idx) + "\n")

    tag_lines = ["# ECI signal tags stripped from the artifact, kept as history, never as speech.",
                 "# stamp\tspeaker\ttag", ""]
    for stamp, speaker, tag in tags_found:
        tag_lines.append(f"{stamp}\t{speaker}\t{tag}")
    TAGS_OUT.write_text("\n".join(tag_lines) + "\n")

    speakers = {}
    for speaker, _, _ in turns:
        speakers[speaker] = speakers.get(speaker, 0) + 1

    print(f"raw bytes            {len(raw)}")
    print(f"normalized bytes     {len(text)}")
    print(f"chrome lines removed {chrome_removed}")
    print(f"ECI tags removed     {len(tags_found)}")
    print(f"turns                {len(turns)}")
    print(f"sha256               {digest}")
    print("speakers:")
    for s, c in sorted(speakers.items(), key=lambda kv: -kv[1]):
        print(f"  {c:4d}  {s}")
    print("tags:")
    for stamp, speaker, tag in tags_found:
        print(f"  {stamp}  {speaker}  ::  {tag}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
