# MLSFun: one abstract base for S2FunMLS and SO3FunMLS

Status: implemented 2026-10-15 in the working tree of `develop` (base 4890fa049), not
committed. Deferred: E1 to E3. Keep this file current.

## Context

`S2Fun/@S2FunMLS` (28 files, 2520 lines) and `SO3Fun/@SO3FunMLS` (36 files, 2860 lines)
are the same algorithm written twice. After normalising class and variable names, `diff`
leaves a few hundred lines, and most of those are the domain hooks (sphere vs rotation
group). The rest are accidents: one class got a fix or a feature the other did not
(TODO.md T7 records one such double fix). Every change has to be applied twice and is
verified once.

Goal: `classdef (Abstract) MLSFun` holds the machinery once; `S2FunMLS < S2Fun & MLSFun`
and `SO3FunMLS < SO3Fun & MLSFun` keep the public interface and supply the domain through
a small set of hooks. Outcomes stay the same up to floating-point order, except for the
bug fixes and alignments below, each flagged and checked against a reference battery.

## Implementation (2026-10-15)

Done: D1 to D15, B1 to B5, B8, C1 to C11, F1 to F3. Files as under "File layout after",
with the private helpers in camelCase (`evalKNN`, `evalRange`, `evalConst`,
`findOptimalSubset`, `computeOutlierIndicators`, `candidateCount`, `basisDegrees`,
`localBasis`, `solveOptions`, the warning and info helpers; `evalMonomialsS2`,
`evalSphericalHarmonics`, `localCoordinatesS2`, `evalMonomialsSO3`), since new code
follows MTEX style: no space after commas, camelCase locals.

Where the code differs from the plan text:
- D3: the probe showed concrete `isReal`, `antipodal` and `eval` in MLSFun satisfy the
  abstract declarations of S2Fun and SO3Fun; no forwards.
- B1: one setter instead of a cascade line plus an assertion: `set.centered` keeps
  `centered` true for an odd degree, and `set.degree` sets it. The constructor
  cascade and later assignments both go through it.
- B3: `cat` is shared, with the hook `toHandle`; `S2Fun/@S2FunHandle/cat.m` is new,
  mirroring `SO3FunHandle/cat`. MLS functions on different nodes are concatenated as a
  handle instead of failing an assertion.
- C7: `'cs'` and `'ss'` are kept as aliases of `'SRight'` and `'SLeft'`. A positional
  symmetry is found by `extractSym`, so a named `'ss',ss` would otherwise land on the
  crystal side.
- D5: the symmetries are applied to the nodes before the Voronoi volumes and the
  duplicate check, so a named `'SRight'`/`'SLeft'` now also enters those.
- Two more hooks with no-op defaults: `prepareNodes` (SO3: rotation to orientation,
  symmetries) and `indexNodes` (S2: KD tree). `local_coordinates_SO3` is inlined into
  the SO3 hook `basisPoints`, which also serves the non-centred branch.
- F3: the option lists stay in the class help texts, which are the user documentation;
  MLSFun has a short developer help. `tools/` is not in the root CLAUDE.md layout list,
  so that list is unchanged.

Found during implementation, fixed:
- B9: `vector3d/find` searched an antipodal S2 node set with the KD tree of v while the
  points searched were [v;-v]. Nodes on the upper hemisphere gave lower-hemisphere
  centers neighbors 0.77-0.90 rad away instead of 0.075. S2FunMLS builds the tree on
  [v;-v] for antipodal nodes, and find uses a stored tree only if it holds exactly the
  points searched.
- B11: `solve_lsq_book_varsize` crashed when a dyadic size group held one neighborhood
  (`repelem` of a scalar is a row). The same pattern broke a KNN batch of one center.
- `max(SO3FunMLS,SO3FunMLS)` on the same nodes returned an unassigned output.

Found during implementation, not fixed, recorded in TODO.md:
- O35 (B10), fixed 2026-10-16: antipodal SO3FunMLS was wrong for every symmetry. `eval`
  now adds the inverted nodes as nodes of their own before folding, as Ralf's findFold
  does. Tim decided against folding large groups in general: the fold of the specimen
  symmetry stays until E1 replaces it by the per-center lift (option 2 of the
  discussion of 2026-10-16), the inversion fold is the stopgap.
- O36, fixed 2026-10-16: degree 0 with range search returned 0 at centers without
  neighbors; such a center takes a minimal KNN neighborhood now.
- O37, done 2026-10-16: the `distance` property is deleted.
- O39, fixed 2026-10-16: `orientation/find` held k*48 candidates per query for all
  queries at once; it batches them to about 2 GB now, with one shared KD tree. The
  former 12 GB case peaks at 2.4 GB.
- O38: E1 to E3. With 432 on both sides, `orientation/find` makes construction take
  24 s at degree 2 and 274 s at degree 4 for 1500 nodes, unchanged from the original.
- Resolved: Tim's own class at `/home/tim/Matlab/MLS/@MLSFun` is renamed to `MLSFunRD`,
  so it no longer shadows the MTEX base.

Speed, 2026-10-16: `evalKNN` computes the weights first and drops the candidate columns
beyond the last positive weight of a batch (candidates come sorted by distance), so
basis, local coordinates and solves see about 28 % fewer rows; values equal to 2e-14,
default options 15 to 16 % faster on S2 and SO(3). The eval batches target 2 GB.
Considered and left: the smooth-delta helper (its range search defines the values), the
refinement step of the solver (E2), distances straight from the KD tree in
`vector3d/find` (core function used everywhere).

Verification:
- battery of 42 cases, original vs new (scripts and .mat in the session scratchpad):
  every case without a planned change agrees to 2e-14 relative in the values and
  1.5e-10 in the condition numbers. Deviations: SO3 degree 3 non-centred 2.56 -> 8.0e-3
  (B1), SO3 subsample with 432 0.71 -> 0.036 (B5), S2 antipodal degree 3 8.0e-5 ->
  1.3e-5 (B9), S2 degree 3 non-centred now centred with the same values (B1), antipodal
  misorientation 2.29 -> 2.28 with other thresholds (C1), `guess_nn` (C3).
- timing, 20000 nodes, old vs new in fresh sessions: equal within 5 %; a profile of the
  symmetric SO3 construction 2.07 s vs 2.05 s.
- `tests/core/check_MLSFun` fails on the original commit in all six check groups and
  passes now, 2.3 s warm, 8.8 s in a fresh MATLAB. `core/check_symmetryCompare` and
  `slow/check_MLSSubsample` (extended by the SO(3) case of B5) pass. The core tier was
  not run.

## Findings

### Identical (verified by normalised diff)

Constructor option parsing; `set.w` (all weight functions); setters for oF, candidateFactor,
degree, mincond, detectOutliers, subsample, tangent, isReal, antipodal; nn;
show_reg_params; init_auxgrid, estimate_auxgrid_points, update_auxgrid_dn;
baseline_amplification; init_reg_auxgrid; guess_nn, count_neighbors; separation_distance;
eval.m (batching, warnings/info bookkeeping, degree-0 path, N==1 path, componentwise
outlier path); eval_knn, eval_range, eval_const, find_optimal_subset (incl.
linprogOptions), compute_outlier_indicators, getQuantile, candidate_count;
init_reg_params; cat, horzcat, vertcat, size, numel, length, end, subsref, subsasgn,
subSet, reshape, permute, squeeze, transpose, ctranspose, conj, uminus; interpolate;
display (all but two strings); calcFourier (structure).

### Domain-specific

| | S2FunMLS | SO3FunMLS |
| --- | --- | --- |
| domain dimension d | 2 | 3 |
| ansatz dimension | (L+1)(L+2)/2 | nchoosek(L+3,3) |
| basis | monomials or spherical harmonics | monomials |
| basis block sizes (tangent / harmonic) | l+1 / 2l+1 | nchoosek(l+2,2) / (l+1)^2 |
| local coordinates | shortest rotation to Z, south-pole frame | project2FundamentalRegion, inv(center)*node |
| local origin | vector3d.Z | orientation.id |
| ball fraction (compute_delta, aux grid size) | (1+antipodal)(1-cos r)/2 | symmetry factor * (2/pi)(phi - sin phi cos phi), phi = r/2 |
| uniform grid | fibonacciS2Grid + KD searcher | equispacedSO3Grid(CS,SS) |
| random points | uniform on S2 | uniform quaternions with CS/SS |
| eval pre-processing | none | orientation(), properGroup, symmetrise w.r.t. smaller side, rebuild aux grid |
| node pre-processing | KD searcher in nodes.opt | rotation -> orientation |
| distinct by construction | fibonacciS2Grid | SO3Grid |
| Voronoi weights | calcVoronoiArea | calcVoronoiVolume |
| symmetry bookkeeping | frame = nodes.frame | SLeft/SRight = nodes.SS/CS, bandwidth |
| degree_laplace_shift | 1 | 2 |
| smooth delta smoothing | d_n^2, sqrt | d_n^3, cbrt |
| minimal outlier range | 3 | 4 |
| display header | frame | symChar |
| calcFourier bandwidth, approximate grid, example | S2 versions | SO3 versions |
| extra overloads | - | inv, rotate, plot (SO3Fun interface) |

Everything in the first block is a function of d alone (D4).

### Accidental differences (resolved by B and C below)

`s` dead on SO3; `approximate(@handle)` broken on S2; `cat` fallback broken on S2;
`plus` branches differ (required by the base classes); SO3-only value shortcuts;
`subsasgn` bandwidth merge; baseline ignores antipodal on SO3; `guess_nn` random vs
grid; `compute_delta` dim*oF vs nn; `fill_distance` options; two geometry-score
formulas; non-centred reuse shortcut; weight scaling 4pi/N vs pi^2/N; S2 symmetry
option type filter; dead Voronoi fallbacks; small wording differences.

### Bugs

B1. SO3, `centered = false`, odd degree gives wrong values. Measured: degree 3 on a
    quadratic test function, 4000 random orientations, no symmetry: max error 1.65 (2.29
    with random quaternion signs) against 2e-15 for degree 2. Cause: raw quaternion signs
    enter the odd basis; the flip is gated on `antipodal`, which on SO(3) means
    ori = inv(ori), while q = -q always holds on S^3; MTEX does not normalise signs (25 %
    of `orientation.rand` have a < 0). The centred branch is safe because
    `project2FR_ref` enforces dot(q, q_ref) >= 0.
B2. `S2FunMLS.approximate(@(v) ...)` errors: reads `f.s` of an S2FunHandle. Verified.
B3. `S2FunMLS/cat` with a non-MLS S2Fun errors: `S2FunHandle(F)` stores the object as
    `fun`; `eval` calls `fun(v)`.
B4. `reg_auxgrid` / `init_reg_auxgrid`: fed `init_reg_params` from 2026-08-04 (amplification
    measured on the function's own nodes at random centres) until the baseline rewrite of
    2026-08-18; orphaned since. 1500-3000 random points per regularized object, never read.
B5. `find_optimal_subset` on SO3 uses `inv(center) * nodes` without projecting to the
    centre's fundamental region (wrong local positions with crystal symmetry), carries the
    B1 sign issue, and duplicates its loop body for the parfor case.
B6. S2 `'symmetry'/'ss'` option typed 'crystalSymmetry': a specimenSymmetry is silently
    ignored. Moot after B2 (the options go).
B7. SO3 with both symmetries non-trivial rebuilds the auxiliary grid (up to 200k points,
    one KNN pass) on every `eval` call. Correct result, hidden cost. Handled with E1.
B8. TODO.md O28 (Symbolic Toolbox) is obsolete, no `syms` in the class; T7 (duplicate
    find_optimal_subset) is closed by this refactor.

Geometry score: diagnostic only (no solver reads it; the HAMLS experiments never read
`info`; only `~/Matlab/testing/MLS/benchmark_SO3FunMLS_multifunction.m` and the already
stale `~/Matlab/mtex-mlsfun-docu/S2_SO3_FunMLS_regularization_overview.tex` mention it).

## Decisions

### D. Design

D1. `classdef (Abstract) MLSFun` (value class) in `tools/math_tools/@MLSFun/`, next to
    the two solvers it uses (precedent for a class folder under tools:
    `tools/registration_tools/@pairShifts`). `startup_mtex` adds the folder recursively.
    `S2FunMLS < S2Fun & MLSFun`, `SO3FunMLS < SO3Fun & MLSFun`.
D2. MLSFun defines only names that neither S2Fun nor SO3Fun define. Colliding names:
    display, plus, uminus, conj, times, rdivide, sum, max, min, mean, inv, rotate, plot,
    calcFourier, numel. Shared logic behind such a name gets a unique name in MLSFun
    (`valueOp`, `displayBody`) and a thin per-class file. MATLAB requires a subclass to
    redefine a method two superclasses both define.
D3. `isReal`, `antipodal`, `eval` collide only with Abstract declarations (S2Fun:
    isReal, eval; SO3Fun: isReal, antipodal, eval). Implementation step 0 probes (three
    scratchpad classdef files) whether a concrete definition in MLSFun satisfies them; if
    not, each concrete class carries three one-line forwards.
D4. One Constant property `domainDim` (2 or 3), set in each concrete class, drives:
    dim = nchoosek(L+d, d); tangent block sizes nchoosek(l+d-1, d-1); harmonic block sizes
    nchoosek(l+d, d) - nchoosek(l+d-2, d); minimal outlier range d+1; smooth-delta
    exponent d; Laplace shift d-1. Reproduces every current number exactly; replaces
    basis_degrees_S2/SO3, candidate_count_S2/SO3 and three hard-coded constants.
D5. Constructor split: shared `F = init(F, nodes, values, varargin)` in MLSFun. Each
    concrete constructor: nargin == 0 return; function-handle / S2Fun (SO3Fun) dispatch to
    approximate; domain pre-processing of the nodes (SO3: rotation -> orientation,
    symmetries from the options or positional arguments applied to the nodes; S2: KD
    searcher); init; post-processing (S2: frame = nodes.frame).
D6. Public names unchanged (all properties, compute_delta, init_auxgrid, guess_nn,
    show_reg_params, init_reg_params, ...). New hooks in camelCase, Hidden.
D7. `supportMargin = 1.10` and `candidateTol = 1e-4` become Constant properties of MLSFun.
D8. The warnings/info helpers (initWarnings, mergeWarnings, issueWarnings, initRegInfo,
    insertRegInfo, sliceRegInfo, reshapeRegInfo) become one private function each in
    `@MLSFun/private`.
D9. Domain private helpers stay in their class folders (eval_monomials_S2,
    eval_spherical_harmonics, local_coordinates_S2; eval_monomials_SO3,
    local_coordinates_SO3), reached through hooks. `@MLSFun/private` is invisible from the
    concrete folders, so hooks are methods, never private functions.
D10. Static constructors approximate / interpolate / example stay per class.
D11. Same-class helper objects (degree-0 smooth-delta MLS) are built with
    `feval(class(F), ...)`.
D12. The two solvers stay in tools/math_tools, unchanged.
D13. `s` is removed from both classes (B2). SLeft, SRight, bandwidth, CS/SS stay SO3-only.
D14. display: body in MLSFun, three-line stub per class passing `inputname(1)`; header
    string and basis name come from hooks.
D15. `compute_delta` becomes one generic bisection of `ballFraction(F, r) = nn / N` on
    [0, pi] (60 steps, machine precision).

Hooks (Abstract, Hidden, declared in MLSFun; implemented in each class):

| hook | S2FunMLS | SO3FunMLS | used by |
| --- | --- | --- | --- |
| `domainDim` (Constant) | 2 | 3 | D4 |
| `evalBasis(F, pts)` | monomials / spherical harmonics | monomials | eval_knn, eval_range, find_optimal_subset |
| `[pts, signCoord] = localCoordinates(F, centers, cid, nodes, gid)` | shortest rotation to Z; sign = z | project2FR, inv(c)*n; sign = a | eval_knn, eval_range, find_optimal_subset |
| `localOrigin(F)` | vector3d.Z | orientation.id | basis at the centre |
| `ballFraction(F, r)` | (1+ap)(1-cos r)/2 | symFactor*(2/pi)(phi-sin phi cos phi), phi=r/2 | compute_delta, estimate_auxgrid_points |
| `uniformGrid(F, n)` | fibonacciS2Grid(n) + searcher, antipodal | equispacedSO3Grid(CS,SS,'points',n) | init_auxgrid, baseline_amplification, guess_nn |
| `randomPoints(F, n, stream)` | uniform S2 | uniform S3 with CS/SS | baseline_amplification |
| `prepareNodes(F, nodes)` | KD searcher | rotation -> orientation | init |
| `nodesDistinct(F, nodes)` | isa fibonacciS2Grid | isa SO3Grid | init |
| `voronoiWeights(F, nodes)` | calcVoronoiArea | calcVoronoiVolume | init |
| `[F, pts] = prepareEval(F, pts)` (concrete default: no-op) | - | orientation(), properGroup, symmetrise, init_auxgrid | eval |
| `headerInfo(F)`, `basisName(F)` | frame header; monomials/harmonics | symChar; monomials | display |
| `fillDistance(F)` | current S2 max call | current SO3 max call | fill_distance |
| `symmetryKey(F)` | antipodal | SLeft.id, SRight.id, antipodal | baseline cache |

### B. Bug fixes

B1. Odd degree forces `centered = true`: in the constructor cascade (next to
    regularize -> tangent -> centered -> monomials) and in `set.degree`; `eval` asserts
    the invariant in one line so a manual `centered = false` errors instead of returning
    garbage. `regularize -> tangent` already holds for every degree, so odd degree with
    regularization uses tangent monomials as the HAMLS remark requires. The non-centred
    branch never sees an odd degree; its sign-flip code goes. One help sentence.
B2. `s` removed from S2FunMLS: plain S2Fun semantics (ADR 0003). The getFrame/getSym
    overrides go; the frame is the nodes' frame; the S2 options 'symmetry'/'cs'/'s'/'ss'
    go; `calcFourier` chooses its bandwidth without a symmetry factor (identical for the
    default specimen symmetry); `approximate` builds
    `S2FunHandle(f, S2Fun.extractFrame(varargin{:}))` and an `equispacedS2Grid` carrying
    `f.frame`. B6 is moot.
B3. Per-class `cat.m`. The S2 fallback mirrors `SO3FunHandle/cat`: one `S2FunHandle`
    whose function concatenates the evaluations along dim+1.
B4. Remove `reg_auxgrid`, `init_reg_auxgrid` and the constructor call.
B5. `find_optimal_subset`: local positions through the `localCoordinates` hook
    (projected, sign-fixed, vectorised); one loop body as a local function called from a
    `for` and a `parfor` header (the `threads == 1` branch stays, so no pool is touched).
B7. With E1.
B8. TODO.md: close T7, mark O28 obsolete.

### C. Alignments (each changes one class's output; the battery reports the deviation)

C1. `baseline_amplification` on SO3 honours antipodal like S2 (reference nodes get the
    flag, cache key includes it). Only antipodal (misorientation) SO3 functions change.
C2. `compute_delta` targets nn (integer) in both; S2's delta moves only for non-integer
    dim*oF.
C3. `guess_nn` probes `uniformGrid(F, 1e4)` in both (S2: fibonacci instead of random).
C4. Value shortcuts for times, rdivide, sum, max on coinciding nodes in both classes
    through the shared `valueOp` helper; the help says times/rdivide/max act on the node
    values and return the MLS fit of the result, not the product of the fits; plus and sum
    are exact. S2 gains times.m, rdivide.m, sum.m, max.m.
C5. The bandwidth merge in `subsasgn` is dropped; the result keeps the left operand's
    bandwidth. S2FunMLS gets no bandwidth property.
C6. Geometry score dropped: `info.geometryScore` disappears, both `local_geometry_score_*`
    go, `localCoordinates` returns no tangent coordinates, the non-centred branch no
    longer computes local coordinates for the diagnostic alone. CHANGELOG names the field.
C7. SO3 symmetries: the dead 'symmetry'/'cs'/'s'/'ss' options go; 'SLeft'/'SRight' stay
    unchanged; a symmetry passed positionally (`extractSym(varargin, 'empty')`, first =
    SRight, second = SLeft, like every other SO3Fun constructor) is applied to the nodes
    exactly as the named options are. Nothing that works today changes.
C8. `fill_distance` stays a per-class hook, unchanged (the live paper scripts
    errorVsBandwidth.m and weatherExample.m read it on S2).
C9. The non-centred "reuse basis on all nodes" shortcut goes in both; the branch always
    evaluates the basis at the hook's representatives. Identical results.
C10. Weight scalings 4pi/N and pi^2/N dropped. The solver divides every page's weights by
    their mean and then normalises the columns, the degree-0 average is a ratio; the
    scale never reaches the solve. `vor_weights` stays the Voronoi area.
C11. `calcSO3VoronoiWeights` replaced by `nodes.calcVoronoiVolume`; extra `[]` in
    displayClass removed; "adopted" -> "adapted".

### E. Deferred: separate commits after the refactor, same battery

E1. No stored copies in `SO3FunMLS/eval` (decided direction, 2026-10-16). The local fit
    at a center c needs every copy g_L m^±1 g_R of a node m inside the support ball, not
    only the nearest one. A node is inside twice exactly when the ball crosses the
    boundary of the fundamental region centred at c. With one symmetry that region has
    the fixed inner radius half the smallest rotation angle (45° for 432, 30° for 622);
    with two symmetries or the inversion it shrinks to zero near fixed points such as the
    identity misorientation. Measured with 2000 nodes and 40 neighbors, 60 random and 40
    boundary centers: a node twice in the ball at 0 % of the centers for one-sided
    symmetries, 22 % for 432/222, 27 % for 432/432, 71 % for 432/432 antipodal, 63 % for
    622/622 antipodal; with one side and the inversion folded, 0 % everywhere.
    `orientation/find` returned the brute-force neighbors in all eight cases, kNN and
    range, random and boundary centers.
    Plan: search the unfolded nodes with `find`; place the nearest copy of each node at
    the center (a two-sided projection with inversion and quaternion sign); add the
    further copies from the pairs (g_L, g_R, ±) with angle(g_L c^±1 g_R, c) < 2 delta,
    which is empty away from fixed points and complete by the triangle inequality. In
    KNN mode keep the nn nearest copies. This removes the |G|-fold node copies, the
    auxiliary grid rebuilt per call (B7), and the one-sided radius limit.
    Note: `orientation/find` folds the smaller group and the inversion internally
    (findFold) and asks the KD tree for k*|G| candidates; that, not the local solve,
    dominates with two symmetries (construction 24 s of 25 s for 1500 nodes 432/432 at
    degree 2). Embeddings (Hielscher, Lippert) would avoid the fold in the search, but
    MTEX's `embedding` has 7 to 27 dimensions for the crystal groups and ignores the
    specimen symmetry.
E2. Solver: for pages without active regularization solve the rectangular problem by QR
    (`pagemldivide(B, fw)`) instead of Gram + one refinement step. The Gram matrix is still
    needed for the amplification that decides activation, so the gain is accuracy (kappa
    instead of kappa^2 then refined), not time.
E3. KD searcher for SO3 nodes (`quaternion/find` rebuilds knnsearch over [-v; v] per call;
    `orientation/find`'s symmetrised candidate set depends on the radius).

### F. Process

F1. Reference battery recorded with the current code before any edit: fixed seeds, small
    sizes, both classes; degrees 0/2/3; knn and range (delta = compute_delta); centred and
    non-centred (even degree); tangent; regularize on/off; antipodal; CS+SS (SO3);
    subsample; vector valued with detectOutliers; outputs vals, conds, info. Saved as .mat
    in the scratchpad. After the refactor every unchanged case matches to 1e-12; every
    deviation is one of B/C and is reported with its size.
F2. Tests first. `tests/core/check_MLSFun.m` (synthetic, a few seconds, within the 60 s
    core budget) is written before the refactor and must fail on the current tree:
    both classes reproduce a polynomial in the ansatz space in every mode; B1 (odd
    degree is evaluated centred and accurate), B2 (`approximate(@handle)`), B3 (cat with
    a handle), B5 (subsample with a crystal symmetry, skipped without the Optimization
    Toolbox as in check_MLSSubsample), C7 (positional symmetry). Row in the
    tests/CLAUDE.md ownership map. `slow/check_MLSSubsample` and
    `core/check_symmetryCompare` keep running. Any tier run only after asking.
F3. Docs: MLSFun help text (the shared options); both class helps point to it and get
    the odd-degree sentence; CHANGELOG entry (incl. the removed `info.geometryScore` and
    the removed S2 symmetry options); TODO T7/O28; one line each in S2Fun/CLAUDE.md,
    SO3Fun/CLAUDE.md and the root CLAUDE.md layout list. The doc reference tree keeps
    S2FunMLS and SO3FunMLS; MLSFun gets no user page (`doc/makeDoc/makeDoc.m` lists the
    documented folders explicitly).
F4. No push. Commits only when Tim asks. Handoff note under project label `mtex-mlsfun`.

## File layout after

```
tools/math_tools/@MLSFun/
  MLSFun.m          classdef: properties, setters/getters, init, hook declarations,
                    compute_delta, init_auxgrid, estimate_auxgrid_points,
                    update_auxgrid_dn, baseline_amplification, show_reg_params,
                    guess_nn, count_neighbors, numArgumentsFromSubscript
  eval.m  init_reg_params.m  displayBody.m  valueOp.m  cat.m  size.m  length.m
  end.m  subsref.m  subsasgn.m  subSet.m  reshape.m  permute.m  squeeze.m
  transpose.m  ctranspose.m  horzcat.m  vertcat.m
  private/  evalKNN.m  evalRange.m  evalConst.m  findOptimalSubset.m
            computeOutlierIndicators.m  candidateCount.m  getQuantile.m
            basisDegrees.m  localBasis.m  solveOptions.m  initWarnings.m
            mergeWarnings.m  issueWarnings.m  initRegInfo.m  insertRegInfo.m
            sliceRegInfo.m  reshapeRegInfo.m

S2Fun/@S2FunMLS/
  S2FunMLS.m (help, ctor, hooks)  approximate.m  calcFourier.m  example.m
  interpolate.m  display.m (stub)  cat.m  plus.m  times.m  rdivide.m  sum.m  max.m
  uminus.m  conj.m
  private/  evalMonomialsS2.m  evalSphericalHarmonics.m  localCoordinatesS2.m

SO3Fun/@SO3FunMLS/
  SO3FunMLS.m (help, SLeft/SRight/bandwidth, ctor, hooks)  approximate.m
  calcFourier.m  example.m  interpolate.m  display.m (stub)  cat.m  plus.m  times.m
  rdivide.m  sum.m  max.m  uminus.m  conj.m  inv.m  rotate.m  plot.m  numel.m
  private/  evalMonomialsSO3.m
```

Deleted from both: horzcat, vertcat, ctranspose, end, init_reg_params, length, permute,
reshape, size, squeeze, subsasgn, subSet, subsref, transpose, numel (S2 only, inherited
from S2Fun), private/{basis_degrees_*, candidate_count_*, compute_outlier_indicators,
eval_basis_functions, eval_const, eval_knn, eval_range, find_optimal_subset, getQuantile,
local_geometry_score_*}.

Rough size: 5400 lines today, about 2600 after.

## Implementation order

0. Copy this plan to `docs/agents/mlsfun-refactor.md`. Probe D3 in the scratchpad.
1. Write `tests/core/check_MLSFun.m`; run it through mrun; record that it fails on the
   current tree and where.
2. Record the F1 battery with the current tree.
3. Create `tools/math_tools/@MLSFun` from the S2 files (the S2 side is the reference in
   git history: "rewrite SO3FunMLS according to S2FunMLS"), generalising with the hook
   table and D4; `mrun --restart` (new folder).
4. Rewrite `S2FunMLS.m` and `SO3FunMLS.m` onto the base; delete the duplicated files.
5. Apply B and C.
6. Compare against the battery; explain every deviation. Run check_MLSFun,
   check_symmetryCompare, check_MLSSubsample through mrun.
7. F3 docs. Ask before running the core tier. Report; no commit without being asked.
8. F4 handoff.

## Verification

- F1 battery: equality to 1e-12 on every unchanged case, both classes, all modes.
- check_MLSFun fails on the current tree (B1, B2, B3, B5, C7) and passes after.
- B1: SO3, degree 3 with 'centered', false requested: the object is centred and the
  quadratic test function is reproduced to the centred-fit level (about 1e-3), not 1.65.
- B2/B3: `S2FunMLS.approximate(@(v) v.z)` and `[S2FunMLS; S2FunHandle]` run.
- B5: subsample with a crystal symmetry on SO3 gives a usable fit (small N).
- `check_symmetryCompare` (S2FunMLS cat/subsasgn) and `check_MLSSubsample` pass.
- Core tier once before any commit, after asking.
