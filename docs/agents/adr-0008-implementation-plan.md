# Implementing ADR 0008 — the frame carries the group

## Where to work

Worktree `/home/hielscher/mtex/frameSymmetry`, branch `feature/frameSymmetry`, off `develop`.
Its matlab-bridge venv is already set up (`docs/agents/matlab-bridge/`); every increment here
is a `classdef` edit, so the session needs a restart after each one. The `develop` worktree
at `/home/hielscher/mtex/develop` is the fingerprint baseline. Ralf works in the repo
concurrently — name every path when staging, and never `git stash`.

## Context

`docs/adr/0008-frames-carry-symmetry.md` reverses ADR 0003's carrier choice: the point group
moves onto the reference frame, objects carry frames, and the fake symmetries — a group
manufactured only so a frame has somewhere to live — disappear. 13 rules, 5 open items, none
of which block the work.

Four decisions are already settled and recorded: `.CS` returns the frame and the frame
answers group questions; an empty convention in an old `.mat` means none was recorded;
colour is out of the register key, first import wins; the input bracket says direct or
reciprocal only.

Increments 0 and 1 have landed on `feature/frameSymmetry`, on top of the three that
preceded this plan (`45080e0c0`, `d8bb811fa`, `6ab4e81a0`): `gridLayout` out of the frame
hierarchy, rule 11's brackets, the fingerprint, and the two consolidations.

**The starting position is far better than the ADR implies.** `symmetry` stores exactly
three things — `id`, `rot`, `frame` (`geometry/@symmetry/symmetry.m:19-21`) — and
`crystalSymmetry` stores *no* lattice at all: `axes`, `abc`, `abg` and the rest are already
`Dependent`, delegating to `cs.frame`. The flip is therefore not a data migration. It is
moving two properties inward and inverting one pointer.

## The oracle — build this first

The test suite cannot be the safety net, because `.CS` changes type and the tiers go red by
design. The net is a numeric fingerprint, which is type-agnostic by construction.

**`docs/agents/frameFingerprint.m`** — 4215 observables across `symmetry`, `referenceFrame`,
`Miller`, `vector3d`, `orientation`, `SO3Fun`, `S2Fun`, `tensor`, `PoleFigure` and
`EBSD`/`grain2d`, printed as `name = %.12g`. It runs in about eight seconds on a warm
session. Nothing whose value is a class name or a handle is emitted — frame identity appears
as a 0/1 comparison — and every observable is probed on its own, printing `name = ERROR` when
it throws, so a carrier that is mid-conversion does not blind the rest.

Run it by **absolute path** from both worktrees, which is what guarantees the two sides
execute identical script text; `docs/agents/` is not on the MTEX path. The shared engine
name is global to the machine, so the second worktree needs its own:

```
SESSION_NAME=mtexdev /home/hielscher/mtex/develop/docs/agents/matlab-bridge/start_session.sh
SESSION_NAME=mtexdev matlab_run.py \
  "run('/home/hielscher/mtex/frameSymmetry/docs/agents/frameFingerprint.m')" > fp-develop.txt
```

then the same line against `mtexcc` in the branch worktree, and `diff`. Any moved digit is a
defect until proven otherwise. Where an increment *intends* a change, the expected diff goes
in the commit message.

The baseline against `develop` `8f8eb3524` is byte-identical to the branch, and stayed so
through both consolidations.

## Order of work

Centre-out. Increments 1–3 keep the tree green; the red window opens at 4 and closes at 9.
The facade decided above means red is scoped to the carrier being converted, never global.

| # | increment | state |
| --- | --- | --- |
| 0 | fingerprint + develop baseline | **done**, `6663d1e9a` |
| 1 | the two consolidations from `frameSimplification.md` | **done**, `f901995af` `70ca81df4` |
| 2A | the frame carries the group | **done**, `722b259f3` |
| 2B | `crystalSymmetry`/`specimenSymmetry` become functions returning frames | **done**, `12df3545c` |
| 3 | interning on the full key, immutability, colour rule | **done**, `591a9380e` `1d2d9774a` |
| 4 | `orientation`/`rotation` — `CS`/`SS` return frames | **done**, `frameA`/`frameB` |
| 5 | `vector3d` absorbs `Miller` | **done**, `668b4a379` `c173b7c80` + the flip |
| 6 | `S2Fun`, `SO3Fun`, `tensor` | **done**, `c13453691`…`c18d995eb` |
| 7 | phase identity — `phaseItem` absorbed, `CSList` holds frames | **done**, `a8c841399` |
| 8 | `transformReferenceFrame` takes a rule; `orientation.align` | **done**, `00553b095` |
| 9 | the facade becomes the deprecated shell; `loadobj` migration | green |
| 10 | outer ring — plotting, interfaces, doc sweep, changelog | green |

### 1 — the consolidations (behaviour-preserving)

The two items `docs/agents/frameSimplification.md` left open, both of which shrink what the
flip has to touch. The fingerprint is unchanged across both.

- **1.3** — the four sameness predicates became `framesFit` for the frame half and `symFits`
  for the group half, in `geometry/geometry_tools/`, with `'strict'`, `'same'` and
  `'compatible'` as the leniency. The ADR's "one tolerance in one place" is not yet landed:
  `referenceFrame.tolAligned` and `tolCompatible` are still two, and `eqTol`, `sim` and
  `eqLazy` still read them separately. That collapses at increment 3, where the register door
  absorbs them.
- **1.4** — frame ownership had three idioms and now has one, `getFrame`/`setFrame` over a
  `Hidden framePrivate`. Ten classes plus `tensor` were converted; `symmetry`, `mapImage`
  and the `frameLeft`/`frameRight` trio stay as they are because increments 2, 4 and 6 remove
  or rewrite them. So increments 4–7 repeat one pattern instead of three.

### 2 — the group moves onto the frame

The frame carries the group **as a `symmetry` object**, `frame.sym`. There is no cycle,
because the group loses its back-pointer: `frame → sym` is one way. That keeps the 31
methods of `@symmetry` operating on a real object instead of two loose fields, and makes
`frame.name` and `frame.sym.name` read as the phase and the group side by side.

The decisions behind it, taken 2026-08-28:

- **`crystalSymmetry` and `specimenSymmetry` stop being classes.** `symmetry` is enough;
  whether a group acts on a crystal or a specimen is what the frame says. The two names
  survive as **functions returning a frame**.
- **`sym.name` is the point group symbol**, not the mineral. The mineral is the frame's name.
- **`sym` is per frame and a value**, like `plottingConvention`.
- **`Laue` and `properGroup` are frames**, cached on the frame, so `ori.CS.Laue` keeps
  working. They cannot be precomputed inside a `symmetry`: a Laue group's Laue is itself, and
  a value cannot contain itself.

A group does not change after it is built, so everything derived from it is computed with
it rather than cached lazily — `multiplicityZ` and `multiplicityPerpZ` are properties set by
`set.rot`, and `@symmetry/multiplicityZ.m` is gone.

**2A landed** (`722b259f3`): the frame carries `sym`, `Laue` and `properGroup`, and
`symmetry` became instantiable. Nothing reads the new path, so the fingerprint is unchanged.

#### 2B — the flip, and why it has no green intermediate

Measured on the tree, excluding `.claude/worktrees/`:

| | |
| --- | --- |
| constructor calls, keep working untouched | 748 |
| `isa` sites needing edits | 179 |
| class-level uses needing edits | 138, of which `specimenSymmetry.default` is 96 |
| method files to relocate | 12 |

Two splits look attractive and are **not** available:

- Renaming `specimenSymmetry.default` to `specimenFrame.default` first. Those 96 sites want a
  symmetry until the flip; a frame does not substitute for one.
- Moving the `WignerD` memo and the `fundamentalRegion` cache onto the frame first. Today one
  frame handle serves a group, its Laue class, its proper group **and** its group-stripped
  stand-in, so a frame-keyed memo would hand `WignerD(stripSym(cs))` the coefficients of
  `cs`. The caches can only move once each group has its own frame, which is the flip itself.

So the flip is one commit, with the fingerprint as the closing gate.

#### 2B — the work list

**The 31 `@symmetry` methods.** 19 are pure group and stay: `check`, `display`, `dispLine`,
`elements`, `eq`, `ne`, `isLaue`, `isProper`, `Laue`, `LaueName`, `numProper`, `numSym`,
`properGroup`, `properSubGroup`, `quaternion`, `rotation`, `nfold`, `factor`, `mtimes`.

8 must move to `@referenceFrame`, each because it needs to know where the group lives:
`fundamentalSector` (reads `how2plot`, tilts by `aAxis.rho`, stamps `N.frame`), `plot`
(draws in the group's convention), `ensureCS` (a transition between two crystal frames),
`union` and `disjoint` (every branch mints a frame-carrying object), `rotation_special`
(reads `cs.axes` — and takes `symAxis` from `@symmetry/private/`, which has to be promoted),
`maxAngle` and `calcAxisDistribution` (both through `fundamentalRegion`).

4 are surgical: `fundamentalRegion` (only the `dcs.fundamentalSector` call and the `symKey`
helper, whose own comment says the key must include the axes and the convention — the
argument that it belongs on the frame), `fundamentalRegionEuler` (three `isa` guards
disambiguating the 312/321 setting, plus one default), `calcAngleDistribution` (two lines),
`WignerD` (its `cs.opt.fhat` memo).

**Three things the value-class conversion breaks, to fix in the same commit.**

- `fundamentalRegion.m:71,137` call `.copy` on a symmetry. The cache hands out copies only
  because a symmetry is a handle; as a value both lines delete.
- `WignerD.m:56,73` write the Fourier memo to `cs.opt`. Under value semantics those become
  silent no-ops and the coefficients are recomputed on every call. **The memo moves to the
  frame**, which stays a handle.
- `phaseItem` supplies `mineral`, `color`, `isIndexed` and the sealed `eq`/`eqTol`/`sim`.
  `crystalFrame` takes them by becoming `< referenceFrame & phaseItem`, exactly as
  `crystalSymmetry` does today. Phase identity proper is increment 7.

**Two defects to fix while passing through.** `crystalSymmetry.byElements` holds a pure
group-closure algorithm in the wrong class — it wants to be `symmetry.closure(rot)` with the
frame wrapped round the result. And `@crystalSymmetry/add.m` re-runs that closure passing
only the mineral name, silently dropping the lattice axes.

### 3 — interning and immutability

The register key is cell + alignment + group + mineral + convention; colour is out of it and
the registered instance keeps the colour it was first given, while a colour asked for
explicitly still wins. `crystalSymmetry` and `specimenSymmetry` ask the register; an importer
says `'noIntern'`. Frames dropped `matlab.mixin.Copyable`, and a frame is **sealed** when the
register stores it — cell, alignment, group and axes names refuse assignment, while name,
colour and convention stay open so `plottingConvention.default` still reaches the data that
follows it.

**The ADR's "shape not size" rule did not survive contact.** Uniform scaling moves no
crystallographic *direction*, but it scales every *d-spacing*, so a scale-free key unified a
unit cube with a 3.52 Å cell and `crystalSymmetry('432').Laue` acquired another phase's
lattice constants. The key compares the cell **relatively** instead: 2.87 against 2.866 is
0.14% and one phase, 1 against 3.52 is two lattices. The tolerance is the new
`frameShapeTolerance` setting.

Two things to know:

- The register store is a **cell array**. Assigning a `crystalFrame` into an array typed
  `referenceFrame` slices it to the base class, which made the register answer "new frame" to
  everything until it was found — the same constraint that makes the phase list heterogeneous.
- **Sealing happens on use.** Passing a frame into an API that interns it — `byScreenAlignment`
  does — seals it there and then. A frame is configured before it is used, not after.

### 4 — `orientation` and `rotation`

`rotation` stays frameless. `orientation` stores its two frames as **`frameA` and `frameB`**,
settling ADR open item 3: named by position rather than by kind, because an orientation maps a
direction given in A into coordinates of B, and for a misorientation both are crystal frames.
`CS` and `SS` are dependent and resolve onto them, which is what they have always meant —
`inv(ori)` swaps the two, so `inv(ori).CS` is the specimen side. Writing `ori.CS` still writes
the frame through silently; the warning the ADR wants belongs with the deprecated shell at
increment 9.

Most of this arrived with increment 2: `.CS` already returned a frame, and the frame already
forwarded `id`, `rot`, `numSym` and `isLaue` while `Laue` and `properGroup` returned the
sibling. What was left was where the two frames sit.

`SO3Fun` and `SO3VectorField` carry the same pair under the same names, from increment 6.

### 5 — `vector3d` absorbs `Miller`

`dispStyle` and the indices moved down with `ca7172f30`, the 25 methods followed. What
`@Miller` still holds is its constructor and `loadobj`.

**A direction stands for its symmetrically equivalent set when the frame it is written in
carries a group** — `geometry/hasSymmetry.m`, not the class and not crystal against
specimen: a specimen frame with a sample symmetry says the same thing. That decides the
default in `symmetrise`, `unique`, `dot`, `dot_outer`, `mean`, `project2FundamentalRegion`,
`region`, `gridify` and `calcDensity`. The indices themselves, and with them `char`,
`display`, `round` and `dspacing`, follow the frame being a crystal one —
`isCrystalDirection`.

In `dot` and `dot_outer` **one of the two sides carrying a group is enough** — the symmetrised
side goes first and `dot_outer` transposes its result back. That is wider than `@Miller/dot`,
which needed a `Miller` on both sides.

The rule reaches further than the class did, because vectors inside MTEX carry frames that
were never `Miller`. Where such an element is one plane, or one representative already
reduced into a sector, rather than a direction standing for its equivalents, it takes the
frame **without** the group: `sphericalRegion` strips it in `set.N`, which is what keeps the
cubic fundamental sector at its three bounding normals, and `HSVDirectionKey` strips it after
projecting into the sector, where one direction gets one colour. Making those call sites say
`'noSymmetry'` is the wrong way round — `crystalFrame.aAxis` is the next candidate to be
written group-free.

**Open:** whether `dot(v1,v2)` really needs the two groups to fit, or whether one being a
subgroup of the other is enough. `symFits(...,'compatible')` decides it today and only warns.

Two defects fixed while passing through: `Miller(v,cs)` built from a `vector3d` came out
`xyz` styled, since the property default now lives on `vector3d` where `xyz` is right, so the
constructor sets `hkl`, or `hkil` where the lattice asks for it; and `ori * m` into a
specimen frame returned a `Miller` sitting in a specimen frame — `rotate` and `rotate_outer`
read `q.frameB` and hand back a `vector3d`.

`gridify` returns its `S2Grid` in the crystal frame instead of a `Miller` copy of it.

`Miller` is a **constructor function** in `geometry/Miller.m` returning a framed `vector3d`,
and the 41 `isa(x,'Miller')` guards ask `isCrystalDirection` or `hasSymmetry` instead. The
class-name lookups went with them: `getClass` takes a predicate, and `argin_check(...,'Miller')`
became an assert naming the frame.

Three things the flip turned up:

- **Writing `x`, `y` or `z` from outside the class leaves a `vector3d` empty**, because
  `numArgumentsFromSubscript` is 0 — inside a classdef the same line writes the property
  directly, which is why the constructor never had to care. The components go through
  `vector3d(x,y,z)`.
- **Keeping the input object would keep its class**, so `Miller(log(...),cs)` handed
  `SO3FunRBF/grad` an `SO3TangentVector` where the class used to flatten it. Every branch
  builds a plain `vector3d`.
- **A saved `Miller` no longer loads.** `data/ptx.mat`, `dubna.mat` and `dubnaodf.mat` held
  them and were deleted, so `mtexdata` re-imports; user `.mat` files wait for increment 9.

### 6 — function spaces and tensors

`S2Fun` carries one frame like `vector3d`, so `S2FunHarmonicSym` stops being a class.
`SO3Fun` carries two like `orientation`. `tensor` keeps one frame and loses the triclinic
placeholder; its own invariance group becomes derivable rather than conflated with the
crystal's.

Done in five commits, each with the fingerprint byte-identical at 4532 observables.

**A spherical function written in a frame that carries a group is symmetric under that
group** — the rule increment 5 gave a direction, and Ralf's call for `quadrature`. So
`S2FunHarmonic.quadrature(f,cs)` spreads the input over the group on request, buys
antipodal from a Laue group, and symmetrises; the 14 callers of the class static are a
rename. `S2FunHarmonicSym` is a constructor function returning a framed `S2FunHarmonic`,
and the methods that used to key on the class ask `hasSymmetry`, which now covers an
`S2Fun` as it covers a `vector3d`.

The frame being the only place a symmetry can hide is what forces the rest: `plus`,
`times`, `rdivide`, `power` and `min` write their result in `S2Fun.jointFrame`, which
carries a group only where both operands do, and `rotate` and `symmetrise` about an
off-z axis write the group free sibling. A sum of invariant functions is invariant, so
`plus` sets the frame rather than symmetrising again. `symmetrise` must not name the
group to the quadrature it drives — that would send it straight back into `symmetrise`.

**The tensor's two frames were the one contradiction the flip could not encode.** It
stored a reference system and, beside it, a frame of its own for the plotting convention,
so the function it turns into had to carry one of each. Now `CS` is the single frame under
its older name, and a `plottingConvention` handed to a tensor already in a crystal frame is
refused (`MTEX:tensor:fixedConvention`) rather than forking a second frame. Where the
derived function really is invariant — `directionalMagnitude`, `linearCompressibility`,
`birefringence`, the wave velocities — it says so through its frame; `PoissonRatio` and
`shearModulus` with one direction held fixed write the group free sibling.

**`SO3Fun` and `SO3VectorField` store `frameA`/`frameB`**, Ralf's call over renaming the
two aliases only: A the crystal side acting from the right, B the specimen side acting
from the left, the same pair an `orientation` has. `CS`, `SS`, `SRight` and `SLeft` are
dependent on them and keep working everywhere, including as assignment targets. The
twelve subclasses store or derive the pair under the new names; `frameLeft`/`frameRight`
are gone, since the frame is the property now.

Left open, each in the increment that owns it:

- the `doc/` pages still describe `S2FunHarmonicSym` as a class — increment 10.
- a saved `.mat` holding an `S2FunHarmonicSym`, a stored `SLeft`/`SRight`, or a stored
  tensor `CS` no longer loads into the property it came from — increment 9, together with
  `crystalSymmetry` and `Miller`.

### 7 — phase identity

`referenceFrame` becomes abstract and `matlab.mixin.Heterogeneous`; `phaseItem` is absorbed
into it and `notIndexed` re-parented as `notIndexedFrame`; `isIndexed` becomes dependent on
the class. `CSList` keeps its name and holds frames. `eqTol` and `sim` are absorbed into the
register door.

Done in one commit. `notIndexed` survives as the **function** that builds a
`notIndexedFrame`, so the importers keep their line, the way `crystalSymmetry` did at
increment 2. `isIndexed` is `~isa(fr,'notIndexedFrame')` and `mineral` is the frame's
`name`, which removes the second copy of the same string that `crystalSymmetry` used to
keep in step by hand. `eqTol` and `sim` are one implementation each in
`@referenceFrame/private`, beside `sameEntity`, with a branch per kind of frame — the
crystal branch from `phaseItem`, the specimen branch from the two files `@specimenFrame`
held.

**One answer moves, in twelve observables.** A frame and its Laue, proper or stripped
sibling now compare `eqTol` and `sim` **equal**. They did not before, and the reason was
not a rule: `clone` copies a frame's `name` but never copied its `mineral`, so the sibling
of Forsterite was a frame with no mineral and the mineral test failed on it. With `mineral`
being the name, both predicates rest on the group and the alignment, which is what they say
they compare.

Two things the increment ran into, neither of them the design:

- **the `data/*.mat` caches go stale on a class change.** A cached `mtexdata` set holds the
  saved `CSList`; once `phaseItem` was gone the property came back `[]`, and the whole EBSD
  block of the fingerprint went red while the import itself was fine. `rm data/*.mat` and
  they re-import — the same footgun increment 5 hit with saved `Miller` objects.
- **`ebsd.CSList.isIndexed` in one expression returns only the first element**, where
  `L = ebsd.CSList; [L.isIndexed]` returns all five. That is `@EBSD/subsref` not passing a
  comma separated list out of a chained reference, and it predates this work.

Sealing has to be designed in, not retrofitted: a method dispatches across a heterogeneous
array only if `Sealed` on the root, `handle.eq` does not come free, and the gap only shows on
a dataset carrying an unindexed phase — which most real ones do.

### 8 — `transformReferenceFrame` and `align`

The verb gains an explicit rule (`byScreenAlignment` / `byAxes` / components) and the
`tolerance` option; `orientation.align(cFa,cFb)` is new; `symmetrise` becomes the
larger-group case of the same transform. Existing implementations to extend:
`TensorAnalysis/@tensor`, `SO3Fun/@SO3Fun`, `geometry/@orientation`, `geometry/@Miller`,
`EBSDAnalysis/@mapImage`, `@EBSDsquare`, `@EBSDhex`.

Done in one commit. **`@mapImage` already had the rule**, grown while raster images were
being made comparable, so the increment was to lift its three ways into
`geometry/geometry_tools/frameTransition.m` and put `vector3d`, `orientation`, `tensor` and
`SO3Fun` through it: an orientation given outright, `'byScreenAlignment'`, or the bases.
Ralf's call was that reading the bases stays the default, so no existing call changes and
`'tolerance'` simply reaches the reading.

`orientation.align(frA,frB)` is that reading under a name — the geometric sibling of
`byScreenAlignment` and the rotation the verb applies. It **errors** where the two frames
are not related by a rotation at all, at `referenceFrame.tolCompatible`, which is the
tolerance `ensureCS` already decides transformability by; the orientation method used to
warn about the same thing after applying the matrix anyway.

**A tensor turned by anything but an element of its own group now drops the claim** —
`rotate` and `rotate_outer` write the group free sibling. That is increment 6's open item,
and Ralf's call over deriving the invariance from the coefficients. The membership test
costs `numSym` comparisons and is skipped for lists longer than the group, where the caller
is turning a tensor into the orientations of a map and the answer is always to drop it.
`symmetrise` and `checkSymmetry` rotate by the group's own elements and are untouched.

`symmetrise` keeps its own name and signature — Ralf's call. What it shares with the
transform is that both are stated in frames and their groups, not that one is a case of the
other; a transform never changes how many elements there are.

### 9 — compatibility

The facade from increment 2 becomes the shipped deprecated shell. `loadobj` on
`crystalSymmetry`, `specimenSymmetry` and `notIndexed` converts old `.mat` content; an empty
convention stays empty. `ori.CS = cs` keeps working with a once-per-call-site warning naming
`transformReferenceFrame`.

**The shell cannot be a facade, and that decided the shape of the increment.** Measured on
R2024b: a constructor may not return another class, **not even a subclass of itself**
(`MATLAB:class:mustReturnObject`), and a `@crystalSymmetry` class folder always beats a
`crystalSymmetry.m` function on the path. So the name is either the class or the factory,
never both. Worse, when the class is missing there is no hook at all: MATLAB substitutes the
unloadable objects while rebuilding the property, and `grain2d/loadobj` receives a finished
grain2d whose `CSList` has already collapsed to one `notIndexedFrame` — which is what
`data/testgrains.mat` and `data/EBSD/trueEbsdWCCoSmall.mat` do today.

**Ralf's answer, 2026-08-28: the name goes to a tombstone.** The factory syntax moves into
`crystalFrame`, the function `crystalSymmetry` goes, and `@crystalSymmetry` becomes a class
that exists only to be found by `load` — a constructor that errors naming `crystalFrame`,
and a `loadobj` that converts. Measured that this works: the tombstone's `loadobj` receives
a struct carrying every saved field and may return an object of another class. So old files
convert by themselves, and a script calling the old name gets an exact error rather than
silence. Same for `specimenSymmetry` and `notIndexed`.

A plain tombstone, not a base class: `isa(x,'crystalSymmetry')` becomes false everywhere,
which is silent, but the class genuinely is gone and a vestigial ancestor would claim
otherwise forever. **`Miller` keeps its function** and gets no tombstone — 663 call sites,
no better name, and what has to survive a load is EBSD and grain data, which carries no
crystal directions.

Landed so far:

- `93de59f90` — **a loaded frame joins the register through the same door.**
  `referenceFrame/loadobj` always called `reintern`, but `reintern` searched the *name* map
  and required a stated convention on both sides, so only named specimen frames ever
  re-unified. Every carrier came back from a file with a frame that was not the one it was
  saved with; all seven do now. That is also issue #2609, which asked for a `loadobj` on
  `@tensor`: the frame is the single point of repair, so no carrier needs one.
- `32b7648df` — `ori.CS = cs` tells the line that wrote it, once, through `mtexWarnOnce`.
  The note hangs off `@orientation/subsasgn` rather than the setter, because a property
  written inside a class method never goes through `subsasgn` — so MTEX's own bookkeeping
  neither warns nor pays the 40 microseconds that reading the stack costs.
- `b31f6d0ee` — `crystalFrame` takes the whole `crystalSymmetry` syntax.
- `eb95a2d4f` — `specimenFrame` takes the whole `specimenSymmetry` syntax. The two meet in
  the first argument, so a string is a point group when it **names one exactly** and the
  frame's name otherwise — exactly, because `findsymmetry` also matches a substring and
  `specimenFrame.measurement` would have become the point group `m`.

Left to do: the sweep (642 `crystalSymmetry(`, 110 `specimenSymmetry(`, 10 `notIndexed(`
across source, tests and `doc/`), then the three tombstones and the proof that
`data/testgrains.mat` comes back with its five phases.

### 10 — outer ring

`plotting/`, `interfaces/` (including the import wizard's `newCS.color` and
`CSList(row).color` paths), the 354 `doc/` pages, `changelog.m`. Tests green. The
`dot`/`angle` annotation pass — 456 calls, 190 files, 34 already flagged — is independent of
all of the above and can run in parallel at any point.

## Traps

- **`classdef` edits need a bridge restart**, and `clear classes` poisons a warm session.
  Every increment here is a classdef edit.
- **MATLAB forbids conditional superclass constructor calls** — restructure with a flag and a
  single `s@symmetry(...)` call. This bit ADR 0003's increment 15.
- **`getClass`/`get_flag` return the FIRST match**, so argument order is precedence; an
  appended default silently beats a user flag.
- **A setter that errors during property restore struct-ifies old `.mat` objects**, so any
  class whose `set.frame` can throw needs a struct-capable `loadobj`.
- **`symmetry` is a handle class** and assigning `how2plot` on one can move the global
  default; increment 3 widens that reach.
- Counts must exclude `.claude/worktrees/`, which holds a full second copy of the tree and
  doubles any figure taken from the repo root.

## Verification

Per increment, in this order:

1. `frameFingerprint` diff against the develop baseline — the primary gate.
2. The owning `check_*` files for the carrier just converted (`tests/CLAUDE.md` has the
   ownership map). Expect red in increments 4–8 for carriers not yet reached; record which,
   so a *new* failure is distinguishable from an expected one.
3. `runTests` on the core tier at increments 3, 9 and 10 only — ask first, it is ~110 s.
4. A doc/ sweep before merging: the pages are the best smoke for carrier paths, and static
   greps miss what they catch.

Merge `develop` into the branch at every increment boundary — a long-lived branch that
diverges silently is worse than the conflicts.
