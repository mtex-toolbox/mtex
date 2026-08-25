#!/usr/bin/env python3
"""Structural checks for the MTEX documentation.

Run from the repository root:

    python3 doc/tools/check_doc_structure.py
    python3 doc/tools/check_doc_structure.py --published ~/mtex/web/pages

Exits nonzero when a count exceeds its budget in BUDGET below. The budgets are
the state of the tree when a check was written, so a check starts life passing
and fails the moment the number grows. Lower a budget when you fix something,
never raise one to make a run pass.

Traps this had to be written around, all of them met in practice:

* A .toc entry names a page by basename only and resolves anywhere in the
  tree, so a chapter may legitimately list a page kept in another folder.
  Grains.toc lists NeperInterface, which lives in EBSD3Analysis/.
* Four .toc files have no trailing newline. file2cell splits on \\n and is
  unaffected, but anything that concatenates them glues one chapter's last
  entry to the next chapter's first.
* A page under an @Class folder publishes as Class.page.html; anything else
  publishes as basename.html. SO3BumpKernel.m is not in an @ folder, so it is
  SO3BumpKernel.html and not SO3BumpKernel.SO3BumpKernel.html.
* Some dangling links are deliberate and are listed in EXPECTED below. They
  come from decisions recorded in docs/doc-audit-plan.md, not from neglect.
"""

import argparse
import collections
import os
import re
import sys

DOC = 'doc'
SKIP_DIRS = ('makeDoc', 'html')
SKIP_PATHS = (os.path.join('doc', 'tools'),)

# source folders whose .m files become function reference pages
SOURCE_DIRS = ['S1Fun', 'S2Fun', 'SO3Fun', 'EBSDAnalysis', 'ODFAnalysis',
               'PoleFigureAnalysis', 'TensorAnalysis', 'plotting', 'geometry',
               'interfaces', 'tools']

# deliberate, decided in docs/doc-audit-plan.md - not failures
EXPECTED = {
    'twinningSystem',      # twinning excluded by request, 2026-08-10
    'EBSDGradient',        # waiting on the non gridded gradient API
    # published from ~/mtex/examples, a build target this repo cannot see
    'ExIceSphericity',
    'example_WCCoSmall_2',
}

BUDGET = {
    # sixteen pages, counted in each tree root that reaches them
    'toc listed twice': 33,
    'toc entry unresolved': 0,
    'page unreachable': 5,       # changelog, Contribute2Doc and three others
    'narrative link dangling': 0,
    'chapter stub': 0,
    # the four smorf screenshots live only in web/images, so the offline
    # help lacks them; clears when doc/images becomes the single source
    'image missing': 4,
    # A ceiling, not a measurement, and only meaningful straight after a
    # complete makeDoc run: taken mid build the number falls as pages
    # republish, and it was seen going 863, 763, 732 within one minute while
    # a build was under way.
    #
    # 869 when this was first counted, 279 now. About 64 of what is left is
    # already fixed in the publisher and merely waiting for the pages to be
    # rebuilt, since staleness hashes the source and a publisher change
    # invalidates nothing. The rest are See also entries naming methods that
    # have no page at all - S2Grid.plot, SO3Fun.textureindex, EBSD.calcODF -
    # which want a decision each rather than a sweep.
    'reference link dangling': 142,
}

STUB_LINES = 15


def read_lines(path):
    with open(path, encoding='utf8', errors='replace') as fh:
        return fh.read().split('\n')


def doc_pages():
    """every publishable narrative page, as basename -> path"""
    pages = {}
    for root, dirs, files in os.walk(DOC):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        if root.startswith(SKIP_PATHS):
            continue
        for f in files:
            if f.endswith('.m'):
                pages[f[:-2]] = os.path.join(root, f)
    return pages


def api_names():
    """names the function reference publishes, by the @DocFile rule"""
    names = set()
    for top in SOURCE_DIRS:
        for root, dirs, files in os.walk(top):
            if any(x in root for x in ('/private', '/.git')):
                continue
            cls = re.search(r'@(\w+)$', root)
            for f in files:
                if not f.endswith('.m'):
                    continue
                names.add(f'{cls.group(1)}.{f[:-2]}' if cls else f[:-2])
    return names


def toc_tree():
    """(root page -> ordered entries) for every .toc in the tree"""
    tocs = {}
    for root, dirs, files in os.walk(DOC):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        if root.startswith(SKIP_PATHS):
            continue
        for f in files:
            if not f.endswith('.toc'):
                continue
            entries = []
            for line in read_lines(os.path.join(root, f)):
                m = re.match(r'\s*(\S+)', line)
                if m:
                    entries.append(m.group(1))
            tocs[f[:-4]] = entries
    return tocs


def reachable(start, tocs):
    seen, stack = set(), [start]
    while stack:
        p = stack.pop()
        if p in seen:
            continue
        seen.add(p)
        stack.extend(tocs.get(p, []))
    return seen


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--published', help='path to web/pages for the link scan')
    args = ap.parse_args()

    if not os.path.isdir(DOC):
        sys.exit('run me from the repository root')

    pages, api, tocs = doc_pages(), api_names(), toc_tree()
    found = collections.Counter()
    report = collections.defaultdict(list)

    def fail(kind, detail):
        found[kind] += 1
        report[kind].append(detail)

    # a page listed twice inside one tree root is a duplicate in the sidebar;
    # the same page under two different roots is not, the trees are separate
    for root in ('Documentation', 'DocumentationMatlab'):
        if root not in tocs:
            continue
        seen = collections.Counter()
        for chapter in reachable(root, tocs):
            for e in tocs.get(chapter, []):
                seen[e] += 1
        for name, n in seen.items():
            if n > 1:
                fail('toc listed twice', f'{root}: {name} listed {n} times')

    for chapter, entries in tocs.items():
        for e in entries:
            if (e not in pages and e not in tocs and e not in api
                    and e not in EXPECTED):
                fail('toc entry unresolved', f'{chapter}.toc -> {e}')

    reached = set()
    for root in ('Documentation', 'DocumentationMatlab'):
        reached |= reachable(root, tocs)
    for name in pages:
        if name not in reached and not name.endswith('_index'):
            fail('page unreachable', name)

    link = re.compile(r'<([A-Za-z0-9_.]+)\.html\s')
    for name, path in pages.items():
        if name == 'changelog':
            continue
        text = '\n'.join(read_lines(path))
        for target in link.findall(text):
            head = target.split('.')[0]
            if (target not in pages and target not in api
                    and target not in EXPECTED and head not in EXPECTED):
                fail('narrative link dangling', f'{name} -> {target}')

    # a chapter landing page that says nothing orients nobody
    for name, path in pages.items():
        folder = os.path.basename(os.path.dirname(path))
        if (name == folder and not name.endswith('_index')
                and len(read_lines(path)) < STUB_LINES):
            fail('chapter stub', name)

    # a static image has to exist in both builds' image directories
    include = re.compile(r'<<([A-Za-z0-9_.\-]+\.(?:png|jpg|gif|svg))>>')
    imgdirs = [os.path.join(DOC, 'makeDoc', 'general'),
               os.path.join(os.path.expanduser('~'), 'mtex', 'web', 'images')]
    for name, path in pages.items():
        for img in include.findall('\n'.join(read_lines(path))):
            for d in imgdirs:
                if os.path.isdir(d) and not os.path.exists(os.path.join(d, img)):
                    fail('image missing', f'{name}: {img} not in {d}')

    if args.published:
        base = os.path.expanduser(args.published)
        folders = ['function_reference_matlab', 'documentation_matlab',
                   'examples_matlab']
        have = set()
        for d in folders:
            p = os.path.join(base, d)
            if os.path.isdir(p):
                have |= set(os.listdir(p))
        href = re.compile(r'href="([^":/#?]+\.html)"')
        for d in folders[:2]:
            p = os.path.join(base, d)
            if not os.path.isdir(p):
                continue
            for fn in os.listdir(p):
                if not fn.endswith('.html'):
                    continue
                with open(os.path.join(p, fn), encoding='utf8',
                          errors='replace') as fh:
                    for t in href.findall(fh.read()):
                        if t not in have:
                            fail('reference link dangling', f'{fn} -> {t}')

    bad = False
    print(f'{"check":26} {"found":>6} {"budget":>7}')
    for kind, budget in BUDGET.items():
        if kind == 'reference link dangling' and not args.published:
            continue
        n = found[kind]
        flag = '' if n <= budget else '  OVER BUDGET'
        if flag:
            bad = True
        print(f'{kind:26} {n:6} {budget:7}{flag}')
        if flag:
            for d in report[kind][:10]:
                print(f'      {d}')

    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
