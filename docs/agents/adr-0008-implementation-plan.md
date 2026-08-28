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
| 2B | `crystalSymmetry`/`specimenSymmetry` become functions returning frames | red: the flip |
| 3 | interning on the full key, immutability, colour rule | green |
| 4 | `orientation`/`rotation` — `CS`/`SS` return frames | red: `geometry/` |
| 5 | `vector3d` absorbs `Miller` | red: `geometry/` |
| 6 | `S2Fun`, `SO3Fun`, `tensor` | red: function spaces |
| 7 | phase identity — `phaseItem` absorbed, `CSList` holds frames | red: `EBSDAnalysis/` |
| 8 | `transformReferenceFrame` takes a rule; `orientation.align` | red shrinking |
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

Register key becomes cell + alignment + group + mineral + convention, with the shape
tolerance of rule 2. Colour stays out of the key, first import wins. Frames drop
`matlab.mixin.Copyable`. Importers get the documented bypass so one file's two phases stay
two.

The fingerprint stays identical but *identity* changes: constructions that produced separate
handles now unify. Grep handle-equality sites before and after — `==` on frames, `sim`,
`eqTol`, `eqLazy` — since more of them will now answer true.

### 4 — `orientation` and `rotation`

`rotation` stays frameless. `orientation` stores two frames under directional names;
`CS`/`SS` become dependent, resolving **positionally** to source and target, and return
frames. The frame forwards group queries: `id`, `rot`, `numSym`, `isLaue` pass through, while
`Laue` and `properGroup` return the **sibling frame** carrying that group — rule 7's sibling
made reachable, and what rule 9's `symmetrise` moves between.

Choke points, all small: `geometry/@symmetry/ensureCS.m` (55 lines),
`geometry/@orientation/private/ensureSym.m` (59), `.../private/extractSym.m` (23),
`tools/option_tools/extractSym.m` (32), `EBSDAnalysis/specimenSymmetryFor.m` (41). ~210 lines
carry the semantics.

### 5 — `vector3d` absorbs `Miller`

`dispStyle` (`MillerConvention`) moves to `vector3d` unchanged; `Miller(h,k,l,cf)` survives
as a constructor function returning a framed `vector3d`; the 25 methods in `geometry/@Miller/`
mostly evaporate rather than migrate. `vector3d` branches on `isa(frame,'crystalFrame')` for
index display, `symmetrise` and `dspacing` — or better, delegates to the frame, which is what
increment 1.4 sets up.

Ship the replacement for `isa(x,'Miller')` in the same increment: 54 sites here plus user
code, and it fails silently.

### 6 — function spaces and tensors

`S2Fun` carries one frame like `vector3d`, so `S2FunHarmonicSym` stops being a class.
`SO3Fun` carries two like `orientation`. `tensor` keeps one frame and loses the triclinic
placeholder; its own invariance group becomes derivable rather than conflated with the
crystal's.

### 7 — phase identity

`referenceFrame` becomes abstract and `matlab.mixin.Heterogeneous`; `phaseItem` is absorbed
into it and `notIndexed` re-parented as `notIndexedFrame`; `isIndexed` becomes dependent on
the class. `CSList` keeps its name and holds frames. `eqTol` and `sim` are absorbed into the
register door.

Sealing has to be designed in, not retrofitted: a method dispatches across a heterogeneous
array only if `Sealed` on the root, `handle.eq` does not come free, and the gap only shows on
a dataset carrying an unindexed phase — which most real ones do.

### 8 — `transformReferenceFrame` and `align`

The verb gains an explicit rule (`byScreenAlignment` / `byAxes` / components) and the
`tolerance` option; `orientation.align(cFa,cFb)` is new; `symmetrise` becomes the
larger-group case of the same transform. Existing implementations to extend:
`TensorAnalysis/@tensor`, `SO3Fun/@SO3Fun`, `geometry/@orientation`, `geometry/@Miller`,
`EBSDAnalysis/@mapImage`, `@EBSDsquare`, `@EBSDhex`.

### 9 — compatibility

The facade from increment 2 becomes the shipped deprecated shell. `loadobj` on
`crystalSymmetry`, `specimenSymmetry` and `notIndexed` converts old `.mat` content; an empty
convention stays empty. `ori.CS = cs` keeps working with a once-per-call-site warning naming
`transformReferenceFrame`.

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
