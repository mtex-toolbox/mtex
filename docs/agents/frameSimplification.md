# Simplifying the reference frame machinery

Static analysis of `feature/referenceFrame` (merge base `0c7c3dc07`), 2026-08-16.
Nothing was executed for the survey; the measurements are greps and line counts.

## What the branch added

| | |
| --- | --- |
| new frame classes | 830 lines — `@referenceFrame` 250, `@specimenFrame` 142, `@crystalFrame` 101 + methods, `orientation/fitFrame` 63 |
| churn in existing files | ~380 lines across `symmetry`, `crystalSymmetry`, `specimenSymmetry`, `vector3d`, `plottingConvention`, `extractSym`, `ensureCompatibleSymmetries` |
| classes carrying a frame | 19 |
| files touching `framePrivate` | 24 |

---

# Part 1 — simplification with no change in functionality

## 1.1 One cascade per class, not two — DONE

Fourteen `set.how2plot` implementations, **112 lines**, most of them duplicating the
`set.frame` in the same class:

```matlab
% EBSD/set.how2plot                    % EBSD/set.frame
ebsd.pos.how2plot = pC;                ebsd.pos.frame = fr;
ebsd.unitCell.frame = ebsd.pos.frame;  ebsd.unitCell.frame = fr;
ebsd.N.frame = ebsd.pos.frame;         ebsd.N.frame = fr;
```

`set.how2plot` already resolves a convention to a frame through
`specimenSymmetry.frameFor`, so every cascading class collapses to

```matlab
function x = set.how2plot(x,pC), x.frame = specimenSymmetry.frameFor(pC); end
```

**Not cosmetic.** Two setters that must stay in lockstep, across nine classes, is
eighteen chances to forget one — and it has been forgotten twice already:
`PoleFigure/set.frame` did not sync `SS` while `set.how2plot` did (fixed in
`e816fcc69`), and the `X.how2plot = Y.how2plot` fork family from the overnight
round of 2026-08-15 is the same shape.

The *primitive* setters stay as they are, because they define what assigning a
frame means and are the base of the recursion: `vector3d`, `S2Fun`, `symmetry`,
`referenceFrame`, `tensor`.

## 1.2 The rotate family had drifted — DONE

Twelve `rotate`/`rotate_outer` methods carried the same warn-and-strip block twice
each — 23 copies — and the guard had diverged into **three incompatible predicates
in nine spellings**:

| spelling | copies |
| --- | --- |
| `numSym(SO3F.CS.Laue)>2` | 7 |
| `length(cs.rot)>2` | 6 |
| `length(cs)>2` | 4 |

`numSym(X.Laue)` and `length(X.rot)` are **not the same test**. For a
non-centrosymmetric group they differ by a factor two: point group `'2'` has
`numSym(Laue)==4` but `length(rot)==2`. So rotating an ODF with `CS='2'` by a
rotation that is not a symmetry element warned and stripped in
`SO3FunHarmonic/rotate_outer`, and silently kept the (now false) symmetry claim in
`SO3FunComposition/rotate`. Same operation, different answer, depending only on
which representation the ODF happened to be in.

`numSym(sym.Laue) > 2` is the correct guard — it means "the point group is not `1`
or `-1`", i.e. the symmetry claims something a rotation can destroy. The
`length(sym.rot) > 2` spelling under-warns for every non-centrosymmetric group of
order 2. Resolved onto one helper, `SO3Fun/dropSymmetry.m`.

**This is a deliberate behaviour change**, documented in `doc/GeneralConcepts/changelog.m`:
six of the twelve methods now warn and drop where they used to stay silent, for
every non-centrosymmetric group of order two (`2`, `m`, `-4`, ...). Anyone relying
on the old silence was carrying a symmetry claim that the rotation had already
invalidated. Core tier 40/40 after the change.

The membership test generalises cleanly: `~all(any(rot(:).' == sym.rot(:)))`
reduces to `~any(rot == sym.rot(:))` for a single rotation, so `rotate` and
`rotate_outer` share one expression.

## 1.3 Four "are these the same?" predicates that want to be one — OPEN

All minted on this branch, all the same question at different leniency, in three
different files:

| | rule |
| --- | --- |
| `fitSym` | Laue id + mineral + frames fit |
| `fitFrames` | same handle or aligned, never across kinds |
| `symMatches` | handle eq, or id eq + same frame handle |
| `symMismatch` | frames fit, group only when both non-trivial |

They have already drifted once: the `SO3Fun × S2Fun` branch of
`ensureCompatibleSymmetries` carried an inline copy of the frame test **without**
the frame-kind guard until it was consolidated on 2026-08-16.

The wider zoo is 14 predicates over ~138 call sites, but `eqTol`, `sim` and
`eqLazy` are pre-existing public API and stay. It is specifically these four that
should be one function with a leniency argument.

## 1.4 Two idioms for "who owns the frame" — OPEN

- **overridable `getFrame`/`setFrame`** — `vector3d`, `Miller`, `S2Fun`,
  `SO3TangentVector`; `framePrivate` in 24 files
- **plain `get.frame`/`set.frame`** — `EBSD`, `grain2d`, `grain3d`,
  `grainBoundary`, `triplePointList`, `PoleFigure`

Same concept, two spellings, and reasoning does not carry from one family to the
other. The first is strictly better: it already expresses "derived, refuses
assignment" (`Miller`, `SO3TangentVector`). Unifying is mechanical.

---

# Part 2 — dropping divergent conventions

**Status: to be discussed, not decided.** This section is the material for that
discussion, not a recommendation to act.

The proposal: one specimen frame and one plotting convention per MATLAB session.
Objects would no longer be able to carry a convention that differs from the
session's.

## What it deletes

| | size |
| --- | --- |
| `specimenSymmetry.frameFor`'s fork branch | small, but it is the keystone — everything below follows from it |
| all 14 `set.how2plot` bodies | 112 lines → one session-level setter |
| `referenceFrame.reintern` + `matchDefault` | ~35 lines, they exist only to re-join divergent conventions on load |
| frame/convention reconciliation in 12 `loadobj` methods | → one rule, in the container classes only |
| `specimenSymmetryFor`, the register's fork/no-fork distinction | `byName` shrinks to a label lookup |
| most of `check_plottingConventionOwnership` | the whole file polices the ownership question |

Roughly **300 lines**. The line count is the smaller prize.

## What it really deletes

The question *"does this object own a frame, or follow one?"* Nearly every defect
found on this branch traces to it:

- the `X.how2plot = Y.how2plot` fork family — an equal-valued copy that silently
  stops following its source
- `PoleFigure` holding the same fact in two carriers that could disagree
- class-default shared handles (`SO3TangentVector.hiddenCS`, `PoleFigure.SS`)
  minted once per session and following nothing
- the `check_plottingConventionOwnership` tier failure, where an EBSD import
  legitimately moved the session default and a later test could not tell

Removing the concept removes the family, not just the instances.

## What must stay regardless

- **`crystalFrame` in full.** Per-phase lattice axes are not a convention, and
  crystal frames are genuinely plural in one session — a two-phase map has two.
- **The crystal-side `framePrivate`.** Tensors and `S2Fun`s really do live in
  crystal coordinates; that slot is not about conventions.
- **`fitFrame` / `isAligned` / `isCompatible`.** Frame transitions are the actual
  value of ADR 0003 and are untouched by this question.

## What is lost

Plotting two datasets with different conventions in one session. Concretely:

1. two labs' data side by side, each in its own acquisition convention
2. a documentation page showing the same data in two conventions to explain them
3. comparing an imported map against a rolled-sheet reference frame without
   converting one of them first

Named frames could survive as **labels**: `specimenFrame.rolling.makeDefault`
would still switch RD/TD/ND and the convention together, just never two at once.

## Intermediate positions worth weighing

- **Session-wide default, per-object override only via an explicit frame.**
  Keep `framePrivate` but delete `frameFor`'s fork: a convention can only be set
  on a *named frame*, never inline on an object. Kills the accidental fork while
  keeping deliberate divergence.
- **Divergence allowed but never inherited.** Objects may carry their own frame,
  but derived results always take the session default unless told otherwise.
  Most of the bugs were about silent *inheritance* of a fork, not the fork itself.
- **Full collapse**, as proposed above.

## Questions the discussion has to answer

1. Does any real workflow need two conventions live at once? If nobody can name
   one, the support costs ~300 lines and all the bugs for nothing.
2. What happens to a `.mat` file saved under a different convention — apply to
   the session, or refuse? (Container classes already apply to the session, so
   this is mostly aligned already.)
3. Do named specimen frames survive as labels, and can they still be switched
   mid-session?
4. Is `plottingConvention` still a value class people can pass around, or does it
   become reachable only through the session frame?

---

# Order of work

1. **1.2** — a correctness convergence, not a refactor. Done.
2. **1.1** — removes a live bug family. Done.
3. **1.3 / 1.4** — structural; they get more expensive the more code lands on the
   branch. Do before the next increment.
4. **Part 2** — a design decision, to be discussed.
