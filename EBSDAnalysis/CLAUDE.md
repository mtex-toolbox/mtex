# EBSDAnalysis/

The EBSD → grains pipeline, plus parent-phase reconstruction.

- `@EBSD` (and grid-specific `@EBSDsquare`/`@EBSDhex`, volume `@EBSD3`/`@EBSD3square`) holds per-pixel phase/orientation/property data for an entire scan as vectorized arrays — indexing (`ebsd(idx)`, `ebsd(condition)`) is the normal way to select sub-regions, not loops.
- `calcGrains` segments an `EBSD` object into a `grain2d` (or `grain3d` for volume data); the segmentation criterion is pluggable via `grainBoundaryCriteria/` (see `gbcCustom.m` for the extension point) and can additionally take a `'delaunay'` flag for an alpha-complex-based decomposition (`spatialDecompositionAlpha.m`) instead of the default Voronoi-style decomposition.
- Grain boundary segments live in a separate `@grainBoundary` object (`grains.boundary`), not on `grain2d` itself — each segment stores adjacent grain/EBSD ids, position, and misorientation; see the class doc in `@grainBoundary/grainBoundary.m`.
- `@parentGrainReconstructor` (`job = parentGrainReconstructor(ebsd, grains, p2c0)`) drives parent-phase reconstruction from child-phase data (e.g. austenite from martensite): it builds a graph over grain boundaries weighted by how well each boundary's misorientation matches the parent↔child orientation relationship (`calcGraph.m`, `calcGBVotes.m`, `private/calcBndWeights.m`), then a separate variant graph (`calcVariantGraph.m`) resolves which of several crystallographically equivalent parent variants each child grain belongs to.
- `@grain3Boundary`/`calcGBND.m` computes grain boundary normal distributions for 3D data — this is a distinct code path from the 2D `@grainBoundary`, not a generalization of it.

For regression testing changes in this folder, `tests/check_calcGrainsCases.m` is the fast (<1s), routine suite of small synthetic maps — run it after touching `calcGrains`/segmentation criteria before reaching for the much slower real-data benchmarks (`check_grainReconstructionBenchmark.m`, `check_grainBenchmark.m`).
