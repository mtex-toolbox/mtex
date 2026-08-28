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

Three increments have landed on `feature/frameSymmetry` (`45080e0c0`, `d8bb811fa`,
`6ab4e81a0`, `556e25581`): `gridLayout` out of the frame hierarchy, and rule 11's brackets.

**The starting position is far better than the ADR implies.** `symmetry` stores exactly
three things — `id`, `rot`, `frame` (`geometry/@symmetry/symmetry.m:19-21`) — and
`crystalSymmetry` stores *no* lattice at all: `axes`, `abc`, `abg` and the rest are already
`Dependent`, delegating to `cs.frame`. The flip is therefore not a data migration. It is
moving two properties inward and inverting one pointer.

## The oracle — build this first

The test suite cannot be the safety net, because `.CS` changes type and the tiers go red by
design. The net is a numeric fingerprint, which is type-agnostic by construction.

**`docs/agents/frameFingerprint.m`** — evaluates a few hundred expressions across every
carrier path and prints `name = %.12g` lines: orientation angles and `symmetrise` counts,
`Miller` coordinates and `dspacing`, ODF values at fixed nodes, pole figure intensities,
tensor entries after rotation, EBSD/grain scalar summaries. Deterministic — no
`Date.now`-style inputs, fixed `mtexdata` sets, seeded random via a fixed `rng`.

```
# baseline, once, from the develop worktree that already exists
cd /home/hielscher/mtex/develop && matlab_run "frameFingerprint" > fp-develop.txt
# after every increment
cd /home/hielscher/mtex/frameSymmetry && matlab_run "frameFingerprint" > fp-branch.txt
diff fp-develop.txt fp-branch.txt
```

Any moved digit is a defect until proven otherwise. Where an increment *intends* a change,
the expected diff goes in the commit message.

Two caveats to build in: exclude anything whose value is a class name or a handle, and keep
the corpus runnable when a carrier is mid-conversion (wrap each block in try/catch and print
`name = ERROR`, so a red carrier does not blind you to the rest).

## Order of work

Centre-out. Increments 1–3 keep the tree green; the red window opens at 4 and closes at 9.
The facade decided above means red is scoped to the carrier being converted, never global.

| # | increment | state |
| --- | --- | --- |
| 0 | fingerprint + develop baseline | green |
| 1 | the two consolidations from `frameSimplification.md` | green |
| 2 | group moves onto the frame, `symmetry` becomes a facade | green |
| 3 | interning on the full key, immutability, colour rule | green |
| 4 | `orientation`/`rotation` — `CS`/`SS` return frames | red: `geometry/` |
| 5 | `vector3d` absorbs `Miller` | red: `geometry/` |
| 6 | `S2Fun`, `SO3Fun`, `tensor` | red: function spaces |
| 7 | phase identity — `phaseItem` absorbed, `CSList` holds frames | red: `EBSDAnalysis/` |
| 8 | `transformReferenceFrame` takes a rule; `orientation.align` | red shrinking |
| 9 | the facade becomes the deprecated shell; `loadobj` migration | green |
| 10 | outer ring — plotting, interfaces, doc sweep, changelog | green |

### 1 — the consolidations (behaviour-preserving)

`docs/agents/frameSimplification.md` leaves two items OPEN, both of which shrink what the
flip has to touch. Do them first, with the fingerprint proving they changed nothing.

- **1.3** — `fitSym`, `fitFrames`, `symMatches`, `symMismatch` are four spellings of "are
  these the same?" at different leniency, and have already drifted once. One function with a
  leniency argument. This is also where the ADR's "one tolerance in one place" lands.
- **1.4** — frame ownership has two idioms: overridable `getFrame`/`setFrame` (`vector3d`,
  `Miller`, `S2Fun`, `SO3TangentVector`; `framePrivate` in 24 files) and plain
  `get.frame`/`set.frame` (`EBSD`, `grain2d`, `grain3d`, `grainBoundary`, `triplePointList`,
  `PoleFigure`). Unify on the first — it already expresses "derived, refuses assignment".
  19 classes carry a frame; after this they carry it the same way, so increments 4–7 repeat
  one pattern instead of two.

### 2 — the group moves onto the frame

`referenceFrame` gains the group (`id`, `rot`); `symmetry` keeps its class and its 31
methods but reads them from its frame. `crystalSymmetry`/`specimenSymmetry` keep working
unchanged for every caller. Nothing outside `geometry/@symmetry/` and
`geometry/@referenceFrame/` should need an edit, and the fingerprint must be byte-identical.

Store the group on the frame as `id` + `rot` directly, **not** as a `symmetry` object — the
frame holding a symmetry that holds the frame is a cycle, and `symmetry` is only those two
fields plus the back-pointer being removed.

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
