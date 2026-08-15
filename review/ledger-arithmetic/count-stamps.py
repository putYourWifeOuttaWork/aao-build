#!/usr/bin/env python3
"""
THE LEDGER'S STAMP COUNT, and why counting headings never gave it.

The obvious method - count '^## <Ordinal> stamp' headings - is wrong, and it is wrong in the
direction that hides the error: it UNDER-reports and looks tidy doing it. Measured on the ledger
at the eighty-sixth stamp: 81 strict heading matches against 86 stamps, five short.

The five are not malformed headings. THEY HAVE NO HEADING AT ALL. The inbox was re-stamped whole
on 9 August, and the stamps that predate the heading convention live in unheaded sections -
'Build queue, in order', 'Ratified from your a19 report', 'Standing, unchanged', 'Prior findings,
6 August morning', 'Sequence out'. There is nothing to repair in the document: the headings are
absent by history, not deviant by mistake, and rewriting them would edit the record to flatter a
counting method. FIX THE METHOD, NOT THE HEADINGS.

The method that is correct by construction: stamps are CONSECUTIVE ORDINALS, so the count is the
HIGHEST ordinal present, not the number of times a pattern matched. A heading is evidence a stamp
exists; its absence is not evidence one does not. Contiguity from the highest down to the lowest
headed stamp is checked separately, so a missing MIDDLE stamp - the failure that would actually
matter - is still caught loudly.
"""
import re, sys

ONES = {'first':1,'second':2,'third':3,'fourth':4,'fifth':5,'sixth':6,'seventh':7,'eighth':8,
        'ninth':9,'tenth':10,'eleventh':11,'twelfth':12,'thirteenth':13,'fourteenth':14,
        'fifteenth':15,'sixteenth':16,'seventeenth':17,'eighteenth':18,'nineteenth':19}
TENS = {'twentieth':20,'thirtieth':30,'fortieth':40,'fiftieth':50,'sixtieth':60,
        'seventieth':70,'eightieth':80,'ninetieth':90}
TENS_PREFIX = {'twenty':20,'thirty':30,'forty':40,'fifty':50,'sixty':60,'seventy':70,
               'eighty':80,'ninety':90}

def ordinal(word):
    w = word.lower()
    if w in ONES: return ONES[w]
    if w in TENS: return TENS[w]
    if '-' in w:
        t, o = w.split('-', 1)
        if t in TENS_PREFIX and o in ONES:
            return TENS_PREFIX[t] + ONES[o]
    return None

def count(path):
    text = open(path, encoding='utf-8').read()
    found = {}
    for h in re.findall(r'(?m)^## ([A-Za-z-]+) stamp', text):
        n = ordinal(h)
        if n: found[n] = h
    if not found:
        print('no stamp headings at all; the ledger cannot be counted this way'); return 1
    top, low = max(found), min(found)
    missing = [n for n in range(low, top + 1) if n not in found]
    print(f'  stamps (highest ordinal present) : {top}')
    print(f'  headed stamps                    : {len(found)}  (lowest headed: {low})')
    print(f'  unheaded, predating the convention: {top - len(found) - len(missing)}')
    # ABSORBED STAMPS ARE NOT GAPS. The tenth stamp records in its own words that "the eighth
    # and ninth stamps were absorbed at re-stamp"; an absorption is a documented decision, and a
    # counter that cannot tell it from a loss cries wolf on every honest ledger. Recognised from
    # the ledger's own sentence rather than from a hand-kept list, so the day an absorption is
    # undone the counter notices without anybody remembering to edit it.
    absorbed = set()
    m = re.search(r'The ([a-z-]+) and ([a-z-]+) stamps were absorbed', text)
    if m:
        absorbed = {ordinal(m.group(1)), ordinal(m.group(2))} - {None}
    gaps = [n for n in missing if n not in absorbed]
    print(f'  absorbed at re-stamp, recorded    : {len(absorbed)} {sorted(absorbed) if absorbed else ""}')
    print(f'  UNEXPLAINED GAPS                  : {len(gaps)} {gaps if gaps else ""}')
    print(f'  arithmetic: {len(found)} headed + {top - len(found) - len(missing)} unheaded '
          f'+ {len(absorbed)} absorbed = {len(found) + top - len(found) - len(missing) + len(absorbed)}'
          f'  (stamps: {top})')
    return 1 if gaps else 0

if __name__ == '__main__':
    sys.exit(count(sys.argv[1] if len(sys.argv) > 1 else 'CODE-INBOX.md'))
