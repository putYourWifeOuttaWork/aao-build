#!/usr/bin/env python3
"""
AAO normalizer: ECI viewer paste -> NF1.

NF1 = SpeakerKey <TAB> utterance, one turn per line, nothing else in the frozen bytes.
Everything stripped goes to a sidecar. Deterministic by construction: no clocks,
no randomness, no dict-order dependence.

Per the discovery-filter-fault law: strip machine annotations by KNOWN vocabulary,
count what was stripped, and report loudly anything annotation-shaped that is not
in the vocabulary rather than guessing.
"""
import hashlib
import json
import re
import sys

NAV = re.compile(r'^\d+\.\s+Move the player to [\d.]+ seconds in the call\s*$')
NAV_FIRST = re.compile(r'^\d+\.\s+(?=\S)')          # item 1 glues number to the speaker line
SPEAKER = re.compile(r'^(?P<name>.*?)(?P<ts>\d{1,2}:\d{2})\s*$')

# ECI topic-label vocabulary observed on this artifact. Labels may carry a
# " (N)" recurrence suffix and MAY BE CONCATENATED with no separator.
LABELS = [
    "AI Tools and Automation Mentioned",
    "Go To Market Tech Stack Discussion",
    "License Count or Usage Discussion",
    "Procurement Process Engaged",
    "Budget Constraints Discussed",
    "Low Adoption Signals",
    "Next Step",
    "Pricing",
    "Product",
]
LABEL_ALT = "|".join(re.escape(l) for l in sorted(LABELS, key=len, reverse=True))
LABEL_TOKEN = re.compile(r'(' + LABEL_ALT + r')(\s\(\d+\))?')

# Roster: display name as it appears in the artifact -> SpeakerKey.
# Built from VideoCallParticipant, read from production 4 Aug 2026.
ROSTER = [
    {"key": "renee_martin",     "participant": "Renee Martin",
     "email": "renee.martin@altify.com",     "related": "005Hn00000Iyk1MIAR", "side": "internal"},
    {"key": "wendy_higley",     "participant": "Wendy Higley",
     "email": "wendy.higley@altify.com",     "related": "005Hn00000JHb1PIAT", "side": "internal"},
    {"key": "ryan_couture",     "participant": "Couture, Ryan [EMR/SYSS/AT/BED]",
     "email": "ryan.couture@emerson.com",    "related": None,               "side": "external"},
    {"key": "neeraja_chimata",  "participant": "Chimata, Neeraja [EMR/SYSS/AT/BED]",
     "email": "neeraja.chimata@emerson.com", "related": "003V400000v7x90IAA", "side": "external"},
    {"key": "jefferson_vargas", "participant": "Vargas, Jefferson [EMR/SYSS/AT/MEDI]",
     "email": "jefferson.vargas@emerson.com", "related": None,              "side": "external"},
]

ORG_TAG = re.compile(r'\s*\[[^\]]*\]\s*$')


def canonical_forms(name):
    """Every spelling of a display name we will accept as the same person."""
    base = ORG_TAG.sub('', name).strip()
    forms = {name.strip().lower(), base.lower()}
    if ',' in base:
        last, first = [p.strip() for p in base.split(',', 1)]
        forms.add(f"{first} {last}".lower())
        forms.add(f"{last}, {first}".lower())
    else:
        parts = base.split()
        if len(parts) == 2:
            forms.add(f"{parts[1]}, {parts[0]}".lower())
    return forms


def strip_labels(line):
    """Return (labels_found, remainder). Remainder empty => whole line was labels."""
    found, pos = [], 0
    while pos < len(line):
        m = LABEL_TOKEN.match(line, pos)
        if not m:
            break
        found.append(m.group(0))
        pos = m.end()
    return found, line[pos:].strip()


def normalize(raw_text):
    lines = raw_text.split('\n')
    turns, stripped, warnings = [], [], []
    seq_expected, i = 1, 0

    while i < len(lines):
        line = lines[i]
        if not line.strip():
            i += 1
            continue

        if NAV.match(line):
            n = int(line.split('.', 1)[0])
            if n != seq_expected:
                warnings.append(f"sequence: expected item {seq_expected}, saw {n}")
                seq_expected = n
            stripped.append({"kind": "navigation", "text": line.strip()})
            seq_expected += 1
            i += 1
            continue

        # Speaker line (item 1 carries the item number inline).
        cand = NAV_FIRST.sub('', line) if NAV_FIRST.match(line) else line
        if NAV_FIRST.match(line):
            n = int(line.split('.', 1)[0])
            if n != seq_expected:
                warnings.append(f"sequence: expected item {seq_expected}, saw {n}")
                seq_expected = n
            seq_expected += 1
            stripped.append({"kind": "item_number", "text": line.split('.', 1)[0] + "."})

        sm = SPEAKER.match(cand)
        if not sm:
            warnings.append(f"unparsed line {i+1}: {line[:80]!r}")
            i += 1
            continue

        display, ts = sm.group('name').strip(), sm.group('ts')
        stripped.append({"kind": "timestamp", "text": ts, "speaker": display})
        i += 1

        # Optional machine topic-label line between speaker and utterance.
        labels = []
        if i < len(lines):
            found, remainder = strip_labels(lines[i].strip())
            if found and not remainder:
                labels = found
                stripped.append({"kind": "topic_label", "text": lines[i].strip(),
                                 "decomposed": found, "speaker": display})
                i += 1
            elif found and remainder:
                warnings.append(
                    f"line {i+1}: label-shaped prefix {found} followed by text; NOT stripped: {lines[i][:80]!r}")

        if i >= len(lines):
            warnings.append(f"speaker line {display} at {ts} has no utterance")
            break

        utterance = lines[i].strip()
        i += 1

        # Guard: an utterance that is entirely known-label text would mean our
        # rule mis-fired. Report rather than swallow.
        lf, lr = strip_labels(utterance)
        if lf and not lr:
            warnings.append(f"utterance is entirely label vocabulary, kept anyway: {utterance!r}")

        turns.append({"display": display, "ts": ts, "text": utterance, "labels": labels})

    # Roster resolution.
    lookup = {}
    for p in ROSTER:
        for f in canonical_forms(p["participant"]):
            lookup[f] = p

    seen, roster_findings = {}, []
    for t in turns:
        forms = canonical_forms(t["display"])
        hit = next((lookup[f] for f in sorted(forms) if f in lookup), None)
        if hit is None:
            t["key"] = "UNRESOLVED"
            roster_findings.append({"display": t["display"], "outcome": "UNRESOLVED"})
        else:
            t["key"] = hit["key"]
            if t["display"] not in seen:
                exact = t["display"].strip().lower() == hit["participant"].strip().lower()
                seen[t["display"]] = {
                    "artifact_name": t["display"],
                    "participant_name": hit["participant"],
                    "speaker_key": hit["key"],
                    "match": "exact" if exact else "permutation",
                    "related_person_id": hit["related"],
                    "side": hit["side"],
                }

    nf1 = "\n".join(f"{t['key']}\t{t['text']}" for t in turns) + "\n"
    sidecar = {
        "artifact": "emerson-2026-06-17-nf1",
        "source_format": "eci_viewer_paste",
        "diarization_class": "Attributed",
        "video_call_id": "6qrV4000000J5K9IAK",
        "occurred_start_utc": "2026-06-17T20:29:36Z",
        "turns": len(turns),
        "stripped_counts": {
            "navigation": sum(1 for s in stripped if s["kind"] == "navigation"),
            "item_number": sum(1 for s in stripped if s["kind"] == "item_number"),
            "timestamp": sum(1 for s in stripped if s["kind"] == "timestamp"),
            "topic_label": sum(1 for s in stripped if s["kind"] == "topic_label"),
        },
        "topic_labels": [s for s in stripped if s["kind"] == "topic_label"],
        "turn_timestamps": [{"i": n, "speaker_key": t["key"], "mmss": t["ts"]}
                            for n, t in enumerate(turns)],
        "roster_resolution": sorted(seen.values(), key=lambda r: r["speaker_key"]),
        "warnings": warnings,
    }
    return nf1, sidecar


if __name__ == "__main__":
    raw = open(sys.argv[1], encoding="utf-8").read()
    nf1, side = normalize(raw)
    nf1_b, _ = normalize(raw)          # determinism: normalize twice
    assert nf1 == nf1_b, "NON-DETERMINISTIC NORMALIZATION"
    side["nf1_sha256"] = hashlib.sha256(nf1.encode()).hexdigest()
    open(sys.argv[2], "w", encoding="utf-8").write(nf1)
    open(sys.argv[3], "w", encoding="utf-8").write(json.dumps(side, indent=2))
    print(json.dumps({k: side[k] for k in
                      ("turns", "stripped_counts", "nf1_sha256", "warnings")}, indent=2))
    print("\nroster:")
    for r in side["roster_resolution"]:
        print(f"  {r['speaker_key']:18} {r['match']:11} artifact={r['artifact_name']!r} "
              f"participant={r['participant_name']!r} related={r['related_person_id']}")
    labs = {}
    for s in side["topic_labels"]:
        for d in s["decomposed"]:
            labs[d] = labs.get(d, 0) + 1
    print("\ntopic labels stripped, by type:")
    for k in sorted(labs, key=lambda x: (-labs[x], x)):
        print(f"  {labs[k]:3}  {k}")
