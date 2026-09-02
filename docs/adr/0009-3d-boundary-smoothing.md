# 3D grain boundaries are smoothed stratum by stratum, and coarsened by clustering

**Status: decided and implemented 2026-09-02.** `grain3d/smoothBoundary`,
`grain3d/reduceBoundary`, `grain3d/refineBoundary`, `grain3Boundary/edges`,
`grain3Boundary/nodeType`, `boundaryFilter/prepare`.

## The mesh

`calcGrains(EBSD3square)` returns the voxel staircase: two triangles per voxel face, a
face separating exactly two grains with its normal from `grainId(:,1)` to
`grainId(:,2)`, three faces on a triple-line edge, four or more grains at a quadruple
point, and the outer hull as a further class of each. Every normal is axis aligned, so
boundary normal distributions, curvatures and areas taken from it measure the grid.
The mesh is a stratified complex, not a manifold: a vertex on a triple line has no
normal, and any operation run per grain opens gaps between grains. Everything below is
judged on the shared vertex list with the strata as constraints.

## Decision

1. **The vertices move, nothing else.** Smoothing never changes `F`, `I_GF`, `grainId`,
   `ebsdId` or `misrotation`, as in two dimensions.
2. **The filter is the `boundaryFilter` of the 2D pipeline.** Its contract,
   `V = smooth(F,V,A_V,isFixed,h)`, only needs a vertex adjacency with the degree on
   the diagonal, so `laplaceFilter`, `taubinFilter`, `curvatureFilter` and
   `huberFilter` run unchanged on the surface adjacency. Uniform umbrella weights, not
   cotangent ones: the voxel mesh is regular, so the tangential drift of the uniform
   operator is mild, and the four filters and their documented parameters stay one
   implementation. A hook `prepare(F,mesh)` hands a filter the faces, edges, node types
   and normals, so a filter working on face normals rather than on the vertex graph
   can be added without touching the driver.
3. **The scheme is hierarchical** (Maddali, Ta'asan & Suter 2016): quadruple points and
   the hull are fixed, the triple lines are smoothed as curves between their quadruple
   points, then the faces as surfaces between the triple lines. A junction is never
   averaged with the interior of a face. The `'coupled'` scheme, one pass over all
   vertices with the junctions merely pinned, is kept as the DREAM.3D behaviour and as
   the second instance of the option, so a third scheme has a place to go.
4. **Coarsening is label-aware vertex clustering** (Rossignac & Borrel 1993), one
   `unique` on the key `[lattice cell, grains at the vertex, hull planes]`. The key
   makes a triple line merge only along itself, a quadruple point only with an
   identical one, and the hull only within its plane, which is the 3D reading of
   "junctions stay" in `grain2d/reduceBoundary`. The cluster centroid is the default,
   the quadric minimiser (Lindstrom 2000) the flag `'quadric'`. A clustering is a
   simplicial map, so every grain surface stays a closed chain and the volumes still
   follow from the divergence theorem. Quadric edge collapse was rejected: it needs a
   priority queue and label-aware collapse predicates, neither of which vectorises.
5. **Refinement is 1-to-4 midpoint subdivision**, pure index arithmetic.
6. **Volume is conserved only globally.** The hull is fixed, so the total volume is
   exact. Per grain, `taubinFilter` conserves approximately, `'maxDisplacement'` bounds
   the travel of the surface (Gibson 1998), and that is where it stops: exact per-grain
   conservation (Kuprat et al. 2001) is a sequential sweep.

Measured on SmallIN100 (757562 triangles, 346729 vertices): edges 0.18 s, node types
0.16 s, reduce by 2 to 293358 faces 0.57 s (quadric 0.91 s), ten Laplace iterations
1.1 s, ten Taubin iterations 1.0 s, the curvature filter on the reduced mesh 1.0 s.

## The alternatives

| algorithm | functional | preserves | cost per pass | strata |
| --- | --- | --- | --- | --- |
| Laplacian umbrella | Dirichlet energy | nothing, shrinks every mode | one sparse product | junctions diffuse unless pinned |
| Taubin λ‖μ, 10.1145/218380.218473 | low-pass gain (1−λk)(1−μk) | low frequencies, volume approximately | two products | same |
| implicit fairing, 10.1145/311535.311576 | ‖V−V0‖² + α‖LV‖² | a smoothing length | one sparse solve | Dirichlet rows eliminated |
| DREAM.3D per-node λ, 10.1186/2193-9772-3-5 | Laplacian with six node-type rates | junctions approximately | one product | strata coupled, hence 400 iterations at 0.025 |
| hierarchical, 10.1016/j.commatsci.2016.08.021 | stratified Laplacian | junctions, network topology | a few solves per level | purpose built |
| Kuprat, 10.1006/jcph.2001.6816 | Laplacian + min-norm volume correction | each grain's volume exactly | sequential sweeps | native |
| normal filtering, 10.1109/TVCG.2007.1065, 10.1111/cgf.12742 | filtered face normals, then a vertex fit | creases and corners | O(F) + vertex steps | face based, a decision at triple-line edges |
| L0 / TV on normals, 10.1145/2461912.2461965, 10.1109/TVCG.2015.2398432 | piecewise flat prior | sharp features | many solves | the prior is the artefact to remove |
| SurfaceNets, 10.1007/BFb0056277, JCGT 11(1) 2022 | elastic net inside the voxel | displacement ≤ 1 voxel | one product | multi-label native, an extraction, not a filter |
| quadric edge collapse, 10.1145/258734.258849 | min v̄ᵀQv̄ | geometry, features via penalties | O(n log n), a heap | label-aware predicates needed |
| vertex clustering, 10.1007/978-3-642-78114-8_29 | one representative per cell | what the key encodes | O(n) | label safe with the right key |
| quadric clustering, 10.1145/344779.344912 | representative minimises the plane quadric | flat facets, sharp lines | O(n) + batched 3×3 solves | same |

## Consequences

- A voxel mesh should be coarsened before it is smoothed: the cluster centroid already
  averages the staircase, and the filters then act on a mesh a quarter the size.
- `nodeType` is the vertex classification every later 3D operation keys on; it follows
  DREAM.3D's numbering so that imported and reconstructed meshes read the same.
- `I_VF` is sized by `allV` and indexed with doubles; anything derived from it,
  `I_VG` and `nodeType`, aligns with `allV`.
- A face-normal filter is the next scheme to add, through `prepare`; TGV on the
  normals is the principled answer where a piecewise-flat prior is wanted.
