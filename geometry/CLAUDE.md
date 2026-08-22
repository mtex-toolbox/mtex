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
- `spatialTransforms/` holds `spatialTransform` and its subclasses — a map from position to
  position, as an object. An abstract base plus concrete classes as bare files, the
  `EBSDSmoothing/` layout. Direction is the contract: `T` maps a position in one frame to
  the same point in the next, `T2 * T1` applies `T1` first, and filling an output grid
  always uses `inv(T)`. Consumed by `EBSD/transform` and `grain2d/transform`.

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
