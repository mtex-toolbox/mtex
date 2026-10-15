# Notes on a fast `find` for `fibonacciS2Grid`

Status: **there is no `find` method on this class.** `fibgrid.find(...)` falls through to
`@vector3d/find`, i.e. the generic KD-tree path. The four files in `private/`
(`fibonacciS2Grid_find`, `_find_region`, `_findbig`, `_findbig_region`) are an unfinished
attempt at a faster one — nothing in the toolbox calls them, and as written they cannot
run: they read `fibgrid.opt.rho`, but the constructor computes `rho` as a local variable
and only ever assigns `x`, `y`, `z`. `opt` is never touched.

This note records what is worth doing instead, should someone pick it up. **None of the
code below has been run** — it is a sketch of the idea, not a tested implementation.

## Why the grid can be searched analytically

The constructor lays the points out so that `z` is *exactly linear in the grid index*:

```matlab
idx = (n : -1 : -n)';      % N = 2n+1 points
sintheta = 2/(2*n+1) * idx;   % == z
```

So grid point `j` (1-based, construction order) has

```
idx = n+1-j        z_j = 2*(n+1-j)/N        j = n+1 - z*N/2
```

which inverts in O(1). Everything within angular radius `eps` of a query lies in
`z ∈ [cos(theta+eps), cos(theta-eps)]`, and that maps to a **contiguous index range** —
no search, no sorted copy, no cached state. `n` is recoverable as `(numel(fibgrid)-1)/2`,
so the class needs no new properties for this.

`rho`, by contrast, is a golden-ratio sequence `mod(2*pi/phi*idx, 2*pi)` — equidistributed
but scrambled, with no useful order in the index.

## What the dead `private/` helpers got wrong

Both do the `z`-band correctly and then fall over on the second step:

- `fibonacciS2Grid_find` calls `unique(rhoGrid)` on **every call** — an O(N log N) sort per
  query batch, worse than the KD-tree it was meant to replace.
- `fibonacciS2Grid_findbig` avoids the sort but still builds `mod(fibgrid.rho, 2*pi)` for
  the *whole* grid, O(N) per call.
- Both then loop `for k = 1:s` over queries, because each query's candidate set has a
  different length.

The fix all three miss: **compute `rho` only for the candidates inside the band.** That
makes the whole thing O(band) with no full-grid work and nothing to cache — and therefore
nothing to invalidate, which matters, see `plus.m` in this folder.

## Sketch — `findQuick`

Untested. Nearest neighbour only; `k > 1` and eps-range would need the band widened until
enough points are collected.

```matlab
function [ind,d] = findQuick(fibgrid,w)

N   = numel(fibgrid);
n   = (N-1)/2;
eps = 2*fibgrid.resolution;        % safe upper bound for the nearest point

% --- band in z: exact, O(1) -------------------------------------------------
z     = w.z;
theta = acos(z);
jLo = max(ceil (n+1 - cos(max(theta-eps,0 ))*N/2), 1);
jHi = min(floor(n+1 - cos(min(theta+eps,pi))*N/2), N);

% --- narrow by rho, but only for the band members ---------------------------
% conservative half-width in rho at this latitude
epsRho = acos(max(cos(eps) - z.^2, 0) ./ (1 - z.^2));
% for each query: I = (jLo:jHi)', rhoBand = atan2(fibgrid.y(I),fibgrid.x(I))
% keep |rhoBand - w.rho| (mod 2*pi) < epsRho, then brute-force the survivors

% --- exact distance over the survivors --------------------------------------
% d = acos(sum(fibgrid.xyz(cand,:) .* w.xyz, 2)); [d,ind] = min(...)
```

Band size is roughly `N*sin(theta)*r` with `r ≈ 2/sqrt(N)`, i.e. **O(sqrt(N))** —
about 200 candidates for the N = 10001 auxiliary grid `S2FunMLS` builds.

The awkward part in MATLAB is that the candidate sets are *ragged*, one length per query.
Either loop (what the dead helpers do, and why they would have been slow anyway) or
flatten with `repelem`/`accumarray`.

## The O(1) alternative

Keinert et al., *Spherical Fibonacci Mapping* (SIGGRAPH Asia 2015), gives an inverse
mapping that returns the nearest point after evaluating **exactly 4 candidates**, in O(1)
regardless of `N`, with no preprocessing.

It applies here unchanged: with `i = n-idx` our layout is

```
z = 2*(n-i)/(2*n+1) = (2*n-2*i)/(2*n+1)
```

which is identical to the canonical `z = 1 - (2*i+1)/N` for `N = 2*n+1`, and our `rho`
differs from the canonical `2*pi*frac(i/phi)` only by a constant rotation. So this is the
standard lattice.

Two attractions over the band method: it is O(1) rather than O(sqrt(N)), and it yields a
*fixed* 4 candidates per query, so the whole search vectorises over all queries with no
loop and no ragged arrays — probably the larger practical win.

Caveats: it answers **nearest neighbour only**, so `k > 1` and eps-range still need the
band method — note `compute_sepdist` in this class calls `find(fibgrid,2)`. It also
assumes the points really are the canonical lattice, which is why `plus.m` demotes the
result to `vector3d`: a shifted grid must not keep the class and be searched this way. Any
implementation needs a brute-force cross-check test against `@vector3d/find` before it is
trusted.

## If someone picks this up

Decide first whether to override all of `@vector3d/find`'s contract — it has three modes
(`k = 1`, `k` nearest, eps-range returning a sparse incidence matrix) plus `antipodal` and
a `distance` option — or only the `k`-nearest paths and delegate the rest upward. And
either finish or delete `private/`; leaving four uncallable files there is worse than
having neither.
