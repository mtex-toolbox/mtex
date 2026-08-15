# Static doc/ audit against the uncommitted "orientation without symmetry" round

2026-08-15, before the full doc run. Audited: every topic folder (html/, makeDoc/
excluded) by grep against each behavior change in the working tree, hits inspected
individually. Bottom line: **no page should error; two pages change output visibly and
deserve a look; one page needs actual editing (changelog).**

## Checked and clean — no page breaks

* **Wrong-sided `ori * ori` now errors (was warning).** All composition sites checked:
  `TaylorHex.m:99`, `TextureEvolution.m:45,91` — `ori .* orientation(-W)` resolves to a
  plain `rotation` (the spin tensor carries the default specimen CS, so
  `spinTensor/orientation` returns a bare rotation) → unchanged bare-rotation branch;
  `RotationSpinTensor.m:132` `ori_ref * mori_123` — same CS handle on the inner sides →
  fast pass. Every `inv(...)`-composition (MTEXvsBungeConvention, MisorientationTheory,
  Taylor pages, MagneticAnisotropy, RotationFibre, OrientationInversePoleFigure,
  DefinitionAsCoordinateTransform) is right-sided, specimen–specimen inner, or has a
  tensor/vector operand (gated downstream in `rotate`/`fitFrame`) — none reaches the
  new error.
* **Arithmetic/conv compatibility (`fitSym`).** Only *loosened* (different mineral
  names with the same group and aligned frames now pass); cross-group arithmetic still
  errors — verified live with SantaFe. `SO3FunConvolution.m` operands all fit.
* **rotate family now keeps the frame (stripSym) instead of writing session
  defaults.** In every doc page hit (`SO3FunOperations.m:153`, `CombinedPlots.m:30`)
  the affected side lives on the session frame anyway → output identical.
  `PoleFigure/rotate` was never part of the change.
* **`transformReferenceFrame` demos** (CrystalReferenceSystem, SymmetryAlignment) call
  the untouched explicit function.
* **No doc text mentions ID1/stripSym/extractSym/hidden symmetries** — nothing to
  rename in prose.

## Expected output changes (picture/log diffs to accept, no code edits needed)

* **`GrainBoundaries/BoundaryNormalDistribution.m:113,145`** — `[value,pos] =
  max(gbnd1)` / `max(gbcd)`: `pos` is now a **Miller** carrying the trivial group on
  the crystal frame (the resolved crystalFrame→Miller open problem; this page is the
  motivating case). `annotate(pos)` works. NOTE: the trivial group means the Miller
  displays 3-index hkl, not hkil, although the page prose talks about
  $\{10\bar{1}2\}$ — check the rendered output; if 4-index is wanted there, that is a
  display-convention question on trivial-group Millers, not a page bug.
* **`SO3Functions/SO3FunVectorField.m`** — headers stabilized (the original
  complaint): `G` and `GR` both read `Quartz → y↑→x` (the group suffix drops on the
  inactive side); tangent-vector displays now show a frame header (`(y↑→x)` left,
  `(Quartz)` right) consistent with the intern-symmetries line. Technical-details
  prose still accurate.
* **`Rotations/RotationTangentSpace.m`**, **`SO3Functions/SO3FunOperations.m`** — same
  display-header changes on tangent vectors / gradient fields; content unchanged.
* `TiltAndTwistBoundaries.m:88` already returned Miller (density of Miller axes is a
  Sym function) — unchanged; the specimen-side density at :125 unchanged.

## Adaptation actually required

* **`GeneralConcepts/changelog.m`** — extend the *Named Reference Frames* section with
  this round: `cs.stripSym` (the trivial group carrying the frame, cached),
  `crystalSymmetry(cF)` / `specimenSymmetry(sF)`, extrema/samples of plain
  crystal-framed S2Funs return Miller, compatibility checks compare frames not groups
  (`ensureSym` via the fitFrame gate — wrong-sided composition now errors),
  `extractSym`'s `'empty'` mode.

## Watch for in the run logs

* The `fitFrame` absorb path prints "transforming the rotation accordingly" — no page
  should trigger it (none found statically); if it appears, that page composes across
  differently-aligned crystal frames and deserves a look.
* The warning "During evaluation: The symmetries of the quadratureSO3Grid do not
  match..." is pre-existing sealed-handle-eq noise (predates this round), not a
  regression.
