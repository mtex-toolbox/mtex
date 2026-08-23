# EBSDAnalysis/

The EBSD → grains pipeline, plus parent-phase reconstruction.

- `@EBSD` (grid variants `@EBSDsquare`/`@EBSDhex`, volume `@EBSD3`/`@EBSD3square`) holds a
  whole scan as vectorized arrays. Select with `ebsd(idx)` / `ebsd(condition)`, never a loop.
- `@mapImage` is an image plus the geometry saying where on the specimen it sits, so an
  image and a map are comparable objects. Its grid is **regular** — origin, perpendicular
  `d1`/`d2`, `pos` derived — which is why it does *not* descend from `@EBSDgrid`, whose
  per-pixel `pos` exists to carry rotated, sheared and distorted grids. An image is never
  those: a distortion is applied by resampling, never by moving grid points. The payoff is
  `griddedInterpolant` in `interp` where `@EBSD/interp` must use `scatteredInterpolant`. An
  EBSD map joins a sequence of images as `mapImage(ebsd.bc,ebsd)`. An image pre-processed for
  registration is an entry of its own, with `spatialTransformId` between it and its source —
  nothing on the class declares what to register on, since that is a fact about a
  comparison. `edgeMap` is a **method, not a property**: it normalises and differences the
  whole image, so compute once and keep it rather than reading it in a loop.
- `@trueEbsd2` aligns a sequence of `@mapImage`s of one specimen area — the TrueEBSD method,
  [arXiv 2605.00703](https://arxiv.org/abs/2605.00703). No single distortion relates an EBSD
  map to an electron image, so the sequence is a **chain**: each consecutive pair is separated
  by one distortion simple enough to fit, and the hops compose. A handle class guiding a
  process, like `@parentGrainReconstructor`. `job.T(n)` is an unfitted `@spatialTransform` —
  **the class is the model**, and a multi-stage hop is written `Shift + Drift`, never `*`,
  because `mtimes` absorbs an operand reporting `isid` and an unfitted prototype does. **On a
  spike branch**: copied in from the Apache-2.0 TrueEBSD add-on, still carrying its
  transitional name and its own comment style; `docs/adr/0006` carries the verdict on whether
  it stays. `@pairShifts` and `tools/registration_tools/remapShifted` came with it and are
  deliberately *copies* rather than moves, so the add-on stays self-sufficient.
- `calcGrains` segments an `@EBSD` into a `grain2d` (`grain3d` for volume data). The
  criterion is pluggable — `grainBoundaryCriteria/`, extension point `gbcCustom.m`. The
  `'delaunay'` flag selects the alpha-complex decomposition (`spatialDecompositionAlpha.m`)
  over the default Voronoi one. `gbcFMC` defaults: `docs/adr/0004-fmc-parameter-defaults.md`.
- Boundary segments live in `@grainBoundary` (`grains.boundary`), not on `grain2d`. Each
  segment stores adjacent grain/EBSD ids, position and misorientation. Segments are stored
  in **walk order** — `docs/adr/0002-ordered-boundary-segments.md`.
- `@parentGrainReconstructor` (`job = parentGrainReconstructor(ebsd,grains,p2c0)`): builds a
  boundary graph weighted by orientation-relationship fit (`calcGraph.m`, `calcGBVotes.m`,
  `private/calcBndWeights.m`), then `calcVariantGraph.m` resolves which parent variant each
  child grain belongs to.
- `@grain3Boundary`/`calcGBND.m` is a **distinct code path** from the 2D `@grainBoundary`,
  not a generalization. They differ observably: in crystal coordinates the 3D one returns an
  `S2FunHarmonicSym`, exactly symmetric under the crystal group; the 2D one builds with
  `'noSymmetry'` and merely attaches a `crystalSymmetry`.

Traps:

- `calcGBND` reads orientations through `gB.ebsdId`. Default `smoothBoundary` rewrites
  `ebsdId` while leaving segment directions and lengths untouched, so the GBND shifts ~10%
  with nothing erroring. Pinned by `core/check_gbnd`.
- `calcGrains` returns notIndexed grains alongside the indexed ones and gives every pixel a
  `grainId`. Code that assumes every grain is indexed breaks on real maps.

Testing: `core/check_calcGrainsCases` (<1 s, synthetic) is the routine suite after touching
`calcGrains` or a criterion. Reach for `slow/check_grainReconstructionBenchmark` /
`slow/check_grainBenchmark` only when that is not enough. Full map in `tests/CLAUDE.md`.
