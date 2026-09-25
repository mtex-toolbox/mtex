# geometry/

The core class hierarchy. Every object holds an array of many entities, never one.

- `quaternion` → `rotation` → `orientation`. An `orientation` carries a
  `crystalSymmetry`/`specimenSymmetry` pair (`CS`/`SS`) and with it fundamental-zone
  reduction, symmetric equivalents and misorientation.
- `vector3d` → `Miller`. A `Miller` is a `vector3d` in a crystal frame plus a convention
  (`hkl`/`hkil`/`uvw`/`UVTW`). `MillerConvention.m` owns hkl↔uvw — never hand-roll it.
- `symmetry` → `crystalSymmetry`/`specimenSymmetry` is threaded through both chains.
- `@referenceFrame` → `@crystalFrame`/`@specimenFrame` carries the axes and the plotting
  convention. **Only a frame carries a convention**; `how2plot` is read only everywhere
  else. See `docs/adr/0003-reference-frame-vs-symmetry.md`.
- `@gridLayout` is the fourth subclass and the odd one: it relates the two *array* indices
  of a gridded map or an image to a frame's basis — dimension 1 first, so
  `gridLayout(rowDir,colDir)` matches `size(A)` and `A(i,j)`. It carries **no** convention:
  the only screen it could mean is the one `imagesc` imposes, which `gridLayout.assumedFor`
  names outright. `ebsd.layout`/`mg.layout` read it off `d1` and `d2`; `gridify` and
  `transformReferenceFrame` take one as a target.
- `spatialTransforms/` holds `spatialTransform` and its subclasses — a map from position to
  position, as an object. An abstract base plus concrete classes as bare files, the
  `EBSDSmoothing/` layout. Direction is the contract: `T` maps a position in one frame to
  the same point in the next, `T2 * T1` applies `T1` first, and filling an output grid
  always uses `inv(T)`. **`+` and `*` are different operations**: `T1 + T2` declares a
  multi-stage *model*, reads left to right, and drops only a literal `spatialTransformId`
  (by class); `T2 * T1` *composes* and simplifies by value, so an operand reporting `isid`
  disappears. An unfitted prototype has zero coefficients and so reports `isid` — hence
  `spatialTransformShift * spatialTransformDrift` is a bare drift with the shift gone,
  while `spatialTransformShift + spatialTransformDrift` is the two-stage model it looks
  like. Use `+` before fitting, `*` after. **An array is a chain, not a collection** —
  `[T1 T2 T3]` is the composite written out, so inverting it reverses the order
  (`docs/adr/0007`). Nothing implements that yet: the methods are scalar-only and MATLAB
  dispatches on a heterogeneous array only what is `Sealed`, which is `mtimes`, `plus` and
  `display` — so `inv(job.T)` errors, and the fold `inv(T(3)*T(2)*T(1))` is the way round
  it. Consumed by `EBSD/transform` and
  `grain2d/transform`. Every class
  fits itself from two point sets through one solver, `private/robustLsq` — supply a design
  matrix, get bisquare-reweighted coefficients. `inv` is exact for the affine and the
  homography and iterates otherwise, via `spatialTransformInverse`.

Traps:

- The fundamental zone is a convex region bounded by quaternion half-spaces
  (`dot(q,N) <= 0`) in `@orientationRegion`, not an angle range.
  `@symmetry/fundamentalRegionEuler` is a bounding box, about 3x too large for cubic — an
  orientation outside it is not a bug.
- `@embedding` must be an **isometry for every Laue class**, not just cubic and hexagonal.
  Verify across all of them when touching `@embedding/double.m`.
- `functionSignatures.json` drives tab-completion for this folder. Keep it in sync with
  public signatures.

`@crystalShape`, `@dislocationSystem`, `@fibre` and `misorientation/` build on the above.
Check `orientation`/`vector3d` for the behaviour before adding it here.
