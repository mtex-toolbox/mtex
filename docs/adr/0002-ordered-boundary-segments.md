# Store grain boundary segments in walk order; derive chains from it

`grains.boundary.F` used to be an Nx2 segment list in whatever order `spatialDecomposition`
emitted — on `mtexdata small` only 11.5% of consecutive rows chained head-to-tail. Every
consumer that needed a walkable boundary re-derived the order itself and differently:
`plotOrdered2` ran `EulerCycles2` on every plot call, `curvature` built the sparse `A_F`
and guessed neighbours from segment-id differences, `calcMeanDirection` took a sparse
matrix power, `grain2d/smooth` re-found junctions from `diag(A_V)`, and `grain2d/subSet`
already did the reordering properly but only for a single grain — so `grains(k).boundary`
was ordered while `grains.boundary` was not. We decided to make walk order an
unconditional invariant of `grainBoundary` and derive everything else from it.

## Considered Options

We chose **Nx2 rows in walk order** over storing `F` as a NaN-separated vertex list
(`[1 4 5 NaN 3 6 4 NaN ...]`), which is the shape plotting and subdivision actually want.
The vertex list breaks the lockstep invariant the whole class is built on: a chain of *s*
segments needs *s+1* vertices plus a separator, so on `mtexdata small` `F` would hold 1320
entries against 976 rows of `grainId`/`ebsdId`/`phaseId`/`misrotation`. `length(gB)` would
stop having one answer and `subSet`/`subsref`/`dynProp` alignment would need an explicit
segment-to-entry map everywhere. Keeping `F` Nx2 costs nothing, because the vertex list is
recoverable in O(n) as the derived `chainV` property — so the NaN shape is still available
to plotting and refinement, just not as the storage.

We chose to **derive** the chain structure rather than store it. Junctions are vertices
where the number of meeting segments is not two, which is one `accumarray` over `F`; chain
membership is a `cumsum` on top. Nothing is cached, so nothing can go stale the way
`inclusionId` did when producers forgot to maintain it. Note that walk order *alone* is
not sufficient to recover chains: two distinct chains meeting at a junction and stored in
consecutive rows would be silently welded into one, so the junction term is load-bearing,
not a refinement.

We chose **unconditional** over a `'keepOrder'`/`'orderBoundary'` flag. A conditional
invariant is worse than none, because every consumer must then test for it and the old
slow path stays in the tree forever.

Chains are oriented so the grain in `grainId(:,1)` lies to the left. `grainId` columns
were already sorted deterministically by the constructor and `calcPolygons` already winds
outer loops positively, so this convention was already latent in the data; making it
explicit is what gives `curvature` a meaningful sign instead of the `abs()` fallback it
used before.

## Consequences

- `grains.boundary` row order changes. Logical masks and phase-pair indexing are
  unaffected; only stored positional indices break.
- `F(:,1) < F(:,2)` no longer holds. `cat` must dedupe on `sort(F,2)`, and `flip` must now
  flip `F` along with `grainId`/`ebsdId`/`misrotation`.
- `curvature` returns a **signed** value from now on; positive bulges into `grainId(:,2)`.
- `gB.direction` is unchanged and stays `antipodal = true`. The sign is available by
  clearing the flag — which `calcGBPD` already did, meaning it was consuming an arbitrary
  sign before this change.
- Old `.mat` files are re-ordered on load, so a saved `grain2d` satisfies the invariant.
