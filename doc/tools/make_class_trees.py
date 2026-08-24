#!/usr/bin/env python3
"""Write a plain inheritance tree into each function reference section page.

Run from the repository root:

    python3 doc/tools/make_class_trees.py          # rewrite the pages
    python3 doc/tools/make_class_trees.py --show   # print, change nothing

The section pages used to carry a hand drawn svg. Both of them had aged
badly - S2Fun.svg still named BinghamS2, renamed years ago, and showed 11 of
the 22 classes; geometry.svg showed 15 of 46 and knew nothing of reference
frames or spatial transforms. A picture nobody regenerates is a picture that
slowly starts lying, so this is generated from the classdefs instead.

Names and inheritance only. Anything richer - properties, methods - is
already on the class pages and would only be a second copy to keep in step.
"""

import argparse
import os
import re
import sys

# section page -> the source folders whose classes it covers
SECTIONS = [
    ('doc/FunctionReference/geometry/geometry_index.m', ['geometry']),
    ('doc/FunctionReference/TensorAnalysis/TensorAnalysis_index.m', ['TensorAnalysis']),
    ('doc/FunctionReference/SO3Functions_index/SO3Functions_index.m', ['SO3Fun']),
    ('doc/FunctionReference/SphericalFunctions_index/SphericalFunctions_index.m',
     ['S2Fun', 'S1Fun']),
    ('doc/FunctionReference/EBSDAnalysis/EBSDAnalysis_index.m', ['EBSDAnalysis']),
    ('doc/FunctionReference/PoleFigureAnalysis_index/PoleFigureAnalysis_index.m',
     ['PoleFigureAnalysis']),
    ('doc/FunctionReference/plotting/plotting_index.m', ['plotting']),
]

LEAD = 'The classes of this section and how they derive from one another:'


def classdefs(folders):
    """class -> (superclasses, folder) for every classdef in these folders"""
    out = {}
    for top in folders:
        for root, dirs, files in os.walk(top):
            if any(x in root for x in ('/private', '/.git')):
                continue
            at = re.search(r'@(\w+)$', root)
            for f in files:
                if not f.endswith('.m'):
                    continue
                name = f[:-2]
                if at and name != at.group(1):
                    continue          # a method, not the classdef
                path = os.path.join(root, f)
                with open(path, encoding='utf8', errors='replace') as fh:
                    head = fh.read(4000)
                m = re.search(r'^\s*classdef[^%\n]*?\b' + re.escape(name) +
                              r'\b\s*(?:<\s*([^\n%]+))?', head, re.M)
                if not m:
                    continue
                sup = []
                if m.group(1):
                    sup = [s.strip() for s in m.group(1).split('&') if s.strip()]
                out[name] = (sup, top)
    return out


def tree_lines(names, sup, seen, indent=0):
    """the indented block, each class shown once"""
    lines = []
    for n in sorted(names):
        if n in seen:
            continue
        seen.add(n)
        lines.append('  ' * indent + n)
        # a class with two superclasses - crystalSymmetry is symmetry and
        # phaseItem - would otherwise appear under each of them
        kids = sorted(c for c, s in sup.items() if s and s[0] == n)
        lines += tree_lines(kids, sup, seen, indent + 1)
    return lines


def render(folders, all_classes):
    mine = {c for c, (s, top) in all_classes.items() if top in folders}
    sup = {c: s for c, (s, _) in all_classes.items()}

    # a root is a class of this section whose parent is not also in it
    roots = {c for c in mine if not (set(sup.get(c, [])) & mine)}

    local = {c: [p for p in sup.get(c, []) if p in mine] for c in mine}
    seen = set()
    lines = []
    for r in sorted(roots):
        if r in seen:
            continue
        seen.add(r)
        parent = next((p for p in sup.get(r, []) if p in all_classes), None)
        lines.append(f'{r}  (< {parent})' if parent else r)
        kids = sorted(c for c in mine if local[c] and local[c][0] == r)
        lines += tree_lines(kids, local, seen, 1)
    return lines


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--show', action='store_true', help='print, change nothing')
    args = ap.parse_args()

    if not os.path.isdir('doc'):
        sys.exit('run me from the repository root')

    folders = sorted({f for _, fs in SECTIONS for f in fs})
    everything = classdefs(folders)

    for page, fs in SECTIONS:
        lines = render(fs, everything)
        if not lines:
            print(f'no classes for {page}, left alone')
            continue

        with open(page, encoding='utf8') as fh:
            title = fh.readline().rstrip('\n')

        body = [title, '%', f'% {LEAD}', '%']
        body += ['%   ' + l for l in lines]
        body += ['%']

        if args.show:
            print('\n'.join(body) + '\n')
        else:
            with open(page, 'w', encoding='utf8') as fh:
                fh.write('\n'.join(body) + '\n')
            print(f'{len(lines):3} classes -> {page}')


if __name__ == '__main__':
    main()
