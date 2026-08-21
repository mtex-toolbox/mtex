# EBSDAnalysis/

The EBSD → grains pipeline, plus parent-phase reconstruction.

- `@EBSD` (grid variants `@EBSDsquare`/`@EBSDhex`, volume `@EBSD3`/`@EBSD3square`) holds a
  whole scan as vectorized arrays. Select with `ebsd(idx)` / `ebsd(condition)`, never a loop.
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
