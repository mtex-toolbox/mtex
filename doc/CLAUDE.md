# doc/

Every page here is an executable MATLAB script that `makeDoc` publishes to HTML — for the
offline MATLAB help and for https://mtex-toolbox.github.io. A page is prose *and* a working
example at once, so a page that does not run is a broken page.

`docs/` (plural, at the repo root) is something else: ADRs, agent notes and
`doc-audit-plan.md`. Nothing there is published.

## The two rules that cannot be broken

**Never rename a page.** The published URL is the file's basename
(`@DocFile/DocFile.m:62-69`), so `OrientationDefinition.m` is `OrientationDefinition.html`
and nothing else. Papers, the forum and Google all point at those names. Moving a page to
another folder is free; renaming it is not.

**Basenames are globally unique** across the whole tree. `makeHelpToc` resolves a `.toc`
entry by basename alone, ignoring the folder, and prints `The file X appears twice` if two
pages collide — then silently picks one.

## Navigation

The tree comes from `.toc` files, never from the folder layout. A `.toc` lists one page per
line, `PageName` then an optional display title:

```
OrientationDefinition            Definition
DefinitionAsCoordinateTransform  Theory
```

A page becomes a chapter by having a `.toc` of its own name beside it, and this nests to any
depth. Because entries resolve by basename, a chapter may list a page that lives in a
different folder — `Grains.toc` already lists `NeperInterface`, which sits in
`EBSD3Analysis/`. With no title, the page's own `%%` heading is used.

The website sidebar and the MATLAB help contents are **generated** from these files. Do not
hand-edit `~/mtex/web/_data/sidebars/`.

## Markup

Plain MATLAB `publish` markup, plus what `makeDoc/@DocFile/private/globalReplacements.m`
adds on top.

| what | how | notes |
| --- | --- | --- |
| section | `%%` then the title on the same line | starts a new idea; `%` continues the prose |
| inline code | `\|calcGrains\|` | pipes, not backticks |
| link to a page | `<EBSDIPFMap.html IPF Maps>` | the `.html` is **required** |
| link to an API | `<grain2d.isBoundary.html \|isBoundary\|>` | a `.` between class and method |
| link to a class | `@grain2d` in prose | auto-linked, see the trap below |
| MATLAB command | `<matlab:doc('hold') hold on>` | |
| static image | `<<geometry.svg>>` | PNG or SVG, see below |
| maths | `$x$` inline, `$$x$$` display | becomes MathJax on the website |
| table | `\|\| a \|\| b \|\| c \|\|` | needs **two or more** `\|\|` on the line, or it is read as prose |
| mlint marker | `%#ok<*NOPTS>` | stripped from the published page |

**Static images** must exist in *both* image directories, or the figure is missing from one
of the two builds: `~/mtex/web/images/` for the website and `doc/makeDoc/general/` for the
offline help.

**Do not use the `#Title` note box.** `globalReplacements.m` turns a comment line starting
with `#` into a `<div class="note">`, but it is used on no page and it is broken twice over:
the box runs to the next code line or `%%` and *swallows the heading it stops at*, so the
following section loses its title entirely; and the website has no CSS rule for
`div.note`, so it renders unstyled. Put optional theory in a plain `%%` section instead,
titled so a reader can skip it — "The maths behind this".

### Markup traps

Four ways to write markup that publishes as something other than what it says:

- **`||` inside a `|…|` span eats itself.** `publish` reads every `|` as a delimiter, so
  `|X||a*, Y||b|` publishes as `Xa*, Yb`. Write it as plain text, or use `&#124;&#124;`.
- **Maths must survive `publish`, not just MathJax.** `\mathsf` and `\boldsymbol` come out as
  red error boxes; use `\mathrm` and `\mathbf`.
- **An opening `$` must follow whitespace.** `$a$--$c$` prints the second term literally — put
  a space before it.
- **`publish` attaches code to the heading above it**, so end-of-page cleanup must not sit under
  `%% Further reading` or `%% Next`.

### Link traps

Three ways to write a link that publishes as a dead one, all of which have shipped:

- `<grain2d/isBoundary.html ...>` — a slash where the publisher needs a dot.
- `<EBSDIPFMap IPF Maps>` — the `.html` left off.
- `@planarColorKey` — the auto-linker calls `which(name)` and emits `Name.Name.html` when
  the name appears more than once in the path. Any file whose parent folder contains its own
  basename hits this and can never resolve. Write the link out by hand.

An `@Class/method.m` file publishes as `Class.method.html`; anything else publishes as
`basename.html`. `SO3BumpKernel.m` is not in an `@` folder, so it is `SO3BumpKernel.html`,
not `SO3BumpKernel.SO3BumpKernel.html`.

## How a page ends

Two closing `%%` sections, in this order.

**`%% References`** — the literature the page rests on. Include a reference where it gives an
important definition, an algorithm or a method the page uses; not general background, and not
something turned up by searching the web for the topic. One bullet each: authors, the title as
a DOI link where a DOI exists, journal or publisher and year, and **a sentence saying what that
reference gives the reader**.

```
% * R. Panozzo, <https://doi.org/10.1016/0040-1951(83)90073-2 Two-dimensional analysis
% of shape-fabric using projections of digitized lines in a plane>, _Tectonophysics_ 95
% (1983), 279-294, introduces the PAROR construction.
```

Older pages call this section `%% Further reading`. It is the same section — write
`%% References`, and never both on one page.

**`%% Next`** — where to read on, as prose rather than a list. Name each page by link,
`<Misorientations.html Misorientations>`, and say what it adds. Follow the chapter's teaching
order and its `.toc`. A page with nothing to hand off to may leave this out.

Both are ordinary `%%` sections, so the trap above applies: no page cleanup may sit under
either heading.

## Writing

The reader is learning crystallographic texture analysis, not just the API. Assume interest
and no prior MTEX.

- **One idea per sentence**, and no sentence spanning more than two lines of source.
- **Define a term the first time it appears**, or link to where it is defined. Never
  introduce jargon in the same sentence that uses it. Reuse the definitions in
  `CONTEXT.md` — grain, notIndexed, chain, junction, triple point, reference frame, frame
  change, variant, packet — so the pages and the glossary cannot drift apart.
- **Prefer the concrete word** in prose: "the map", "the grain", "the boundary". Keep the
  class name for when the class itself is the subject.
- **Say what to notice.** A plot with no reading is decoration. After a figure, say what the
  reader should see in it.
- **Theory last.** Open with the idea in plain language; put formulas and derivations in a
  clearly marked closing `%%` section.
- **Every key concept gets a picture** — a generated figure where MTEX can draw the thing,
  a hand-authored SVG where it cannot.
- **Correct a page, do not debate it.** When you replace a wrong reading, write what the
  figure shows; never write against the sentence you deleted ("mirrored *rather than*
  turned", "the mismatch does *not simply* accumulate"). The reader never saw it. See
  "Every edit reads as if the previous version never existed" in the root `CLAUDE.md`.

Phrases that keep reappearing and should not: *most simplest*, *nothing else then*, *more
then*, *lets us* (for *let us*), *allows to* (for *allows you to*).

Spelling that is correct here and may look wrong: Miller **indices**, **fundamental** region,
**arithmetics**, the **ghost** effect, Bunge, Rodrigues, Wigner, Schmid, forsterite,
enstatite, diopside, austenite, martensite, misorientation, disorientation, antipodal,
halfwidth, notIndexed.

## Running and previewing

**Run a page through the bridge, never by hand in a fresh MATLAB.** `mtexdata` assigns into
the base workspace, so a plain `run` fails on any page that loads data:

```
docs/agents/matlab-bridge/start_session.sh
docs/agents/matlab-bridge/.venv/bin/python docs/agents/matlab-bridge/matlab_run.py \
  "evalin('base','run doc/Grains/SelectingGrains.m')"
```

A **new** `.m` file needs a bridge restart before the session can see it.

Preview in increasing cost — do not skip a rung:

```
cd ~/mtex/web && docker-compose up                 # the whole site at localhost:4000
cd ~/mtex/web/matlab && matlab -batch "makeDoc('doc','file',<pattern>)"   # fast, sidebars untouched
cd ~/mtex/web/matlab && matlab -batch "makeDoc('doc','checkLinks')"       # full, sidebars rebuilt
```

`doc/makeDoc/makeDoc.m`, the offline MATLAB help, is **obsolete** — it still runs
but is no longer kept in step with the website build, so its pages are not what a
reader sees. Do not preview against it, and do not port a website build change to it.

Figures are published at **twice** the size they are shown at, and the CSS halves
them again — so the size of an image and the page that embeds it belong together.
The build's revert pass knows this and keeps anything rendered more than 10% away
from the committed size; `'keepImages'` skips that pass altogether.

A full build takes far longer than five minutes and republishes into `~/mtex/web`, which is
the live site — ask before starting one.

## Traps

- **A misspelt option is silently ignored.** `calcGrains(ebsd,'theshold',10*degree)` ran for
  years on a published tutorial and looked right, because the default happened to be the
  same value. Copy option names, do not type them.
- **`.toc` files may lack a trailing newline**, so a tool that `cat`s them glues the last
  entry of one chapter to the first of the next. `file2cell` splits on `\n` and is
  unaffected; naive shell checkers are not.
- **A `.toc` title is only a label.** Changing it changes the sidebar, never a URL.
- **`makeDoc('doc','file',...)` leaves the sidebars alone** by design — they can only be
  generated from the complete page list. A tree change needs a full build to show up.
- **Do not set global figure preferences with `setMTEXpref`** — `makeDoc.m` fixes those. This
  does not apply to a `'figSize'` argument passed to `newMtexFigure`, which is per-figure;
  removing one of those collapses the layout.
- **A `plottingConvention.default(...)` call in a page is deliberate.** It fixes the frame the
  page's figures are drawn in, so removing one changes every figure below it. Write it in the
  string form — `plottingConvention.default('y↑→x')`, `('y←↑x')`, `('y↓→x')` — never as an
  object plus `makeDefault`. Add one only where the page's data needs a frame that its
  reference frame does not already supply.
