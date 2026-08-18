# Tests

Tiered suite. `runTests` runs a tier; every `check_*.m` in a tier folder is a test of that
tier, so adding a file is all it takes to register it.

| tier | what belongs there | budget |
| --- | --- | --- |
| `core/` | the computational and algorithmic core, on synthetic or tiny data | **whole tier under 60 s** |
| `slow/` | real datasets, benchmarks, anything minutes-long | opt-in, not budgeted |
| `plotting/` | tests whose assertion is about a graphics object | opt-in, not budgeted |
| `lib/` | fixtures and generators, not tests | never collected |

A file at `tests/` root is deliberately **not** collected by `runTests`. That is where a test
goes when it cannot currently pass — `check_WignerD` (#2582) and `check_SO3FunRBFApproximation` (#2588) — or has not been
converted yet — `SO3FunTests/test_convolution`. Each carries a header saying so. A tier is meant
to go green, so a test that is known to fail does not belong in one; parking it here keeps it and
its assertion alive without making the tier meaningless.

`check_mtex`, `check_mex` and `check_mexComplete` also stay at `tests/` root. `check_mtex` runs the
core tier. `check_mex` is an installer called from `startup_mtex.m` on every start, not a test.
`check_mexComplete` is the build gate referenced by `.github/workflows/build-mex.yml`.

## Before adding a test

Most bug fixes do not earn a new file. This folder reached 84 files by adding one per bug, and
about a third of them asserted nothing at all. In order:

1. **Does it deserve a regression test?** Yes if the bug produced wrong numbers or a wrong
   shape **silently**. No if MATLAB or `checkcode` would have caught it — undefined variable,
   wrong argument count, missing field, a stale docstring. Those are edits, not regressions.

2. **Which file owns the subsystem?** See the map below. Add a local `check<Thing>` subfunction
   there and call it from the driver. That is how `check_calcGrainsCases`, `check_gridify` and
   `check_boundaryChains` are already built — the pattern exists, use it.

3. **Only if nothing owns it**, add a file — and it owns that subsystem from then on. Put it in
   the map.

**A new test must fail on the unfixed tree.** Check that it does, and say so in the commit
message. A test that passes before the fix documents nothing.

**`core/` is synthetic by default.** `mtexdata` is the dominant cost in this suite. A 24×24
synthetic map catches shape, convention and ordering bugs exactly as well as forsterite does —
that is why `check_calcGrainsCases` runs in under a second while the forsterite-based tests take
tens. Real data needs a reason, or the test goes in `slow/`.

**Delete tests with their subject.** When the thing a test covers is removed or rewritten, remove
or rewrite the test in the same commit. A vacuous assertion is worse than no test. Investigation
findings go in the commit message or a GitHub issue — never a `.m` file parked in this folder.

## Running them

- Iterating on a fix: run the **one** owning file, through `docs/agents/matlab-bridge/`.
- Before committing: `runTests` once.
- `runTests('slow')` / `runTests('plotting')`: only when you touched that subsystem, or when
  asked — these are minutes, not seconds. Ask before starting one.
- Never `runTests('all')` unattended.

## Ownership map

**Priority areas.** Anything depending on a **mex file** and **orientation geometry** are the
critical ones; **import → grain reconstruction** is the important route. When the core tier runs
over budget, trim from outside these before trimming inside them.

| subsystem | owning test |
| --- | --- |
| orientation `log`/`exp`, tangent spaces | `core/check_logReference` |
| rotation representations (Euler, axis–angle, matrix, Rodrigues) | `core/check_eulerquat` |
| homochoric coordinates | `core/check_homochoric` |
| misorientation distance, antipodal flag | `core/check_antipodalDistance` |
| fundamental region projection | `core/check_fundamentalRegion` |
| `orientation/find`, k-nearest and epsilon | `core/check_find` |
| orientation embedding | `core/check_embedding` |
| symmetry comparison, `eqTol`/`sim` | `core/check_symmetryCompare` |
| reference frames: symmetry→frame delegation, frame transitions, `ensureCS` compatibility, and that a crystal-framed derivative (`fundamentalSector`, IPF colors) does not follow the session convention | `core/check_referenceFrame` |
| `vector3d` construction and shape contract | `core/check_vector3d` |
| crystal axes, `X\|\|a` / `X\|\|a*` alignment, EDAX frame | `core/check_crystalAxes` |
| `Miller`, crystal directions, hkl↔uvw | `core/check_Miller` |
| **every mex binary's functional behaviour** | `core/check_mexFunctions` |
| mex build completeness | `check_mexComplete` (root) |
| **EBSD import**, text formats (.ctf, .ang) and the Oxford binary pair (.cpr/.crc) | `core/check_ebsdImport` |
| **EBSD import**, HDF5 and multi-scan files | `slow/check_ebsdImportH5` |
| **EBSD export**, text formats and round trips | `core/check_ebsdExport` |
| **EBSD export**, HDF5 into a copy of the reference file | `slow/check_ebsdImportH5` |
| `EBSD` object: construction, `display`, `loadobj`, `interp` | `core/check_ebsd` |
| EBSD grid geometry, `unitCell`/`lattice.ij`, `dynProp` | `core/check_ebsdGrid` |
| spatial shift (`plus`/`minus`) of EBSD, grains, boundaries, triple points | `core/check_spatialShift` |
| `EBSD/gradient`, KAM | `core/check_gradient` |
| `gridify` on real data | `slow/check_gridify` |
| `calcGrains` | `core/check_calcGrainsCases` |
| `grain2d/merge` argument dispatch | `core/check_grainMerge` |
| grain boundary walk order | `core/check_boundaryChains` |
| `chainOrder` mex vs MATLAB | `core/check_chainOrder` |
| Voronoi / Delaunay backends | `core/check_jcvoronoi` |
| pseudo symmetry cleanup | `core/check_cleanUpPseudoSym` |
| grain boundary smoothing | `core/check_boundaryChains` (order/topology) + `core/check_gbnd` (the ebsdId seam) |
| grain boundary normal distribution, 2d | `core/check_gbnd` |
| grain boundary normal distribution, 3d | `slow/check_gbnd3d` |
| quadruple point merging | `slow/check_removeQuadruplePoints` |
| 3d grains, face orientation | `slow/check_orientFaces` |
| convolution, all type pairs | `core/check_convolution` |
| SO3 vector fields — tangent spaces, curl, div, antiderivative, rotate, quadrature | `core/check_SO3TangentVectors` |
| SO3 vector field approximation — `interpolate`, `SO3VectorFieldRBF` | `slow/check_SO3VectorFieldApprox` |
| `rotate` on `SO3Fun` subclasses | `core/check_SO3FunRotate` |
| kernel halfwidth | `core/check_kernelHalfwidth` |
| ODF gradients | `core/check_odfGrad` |
| `optimalSample` — that the L-BFGS memory is used, weights on the simplex | `core/check_optimalSample` |
| Clebsch–Gordan coefficients | `core/check_clebschGordan` |
| Wigner D | `check_WignerD` at tests/ root — **known failure, #2582**, so not in a tier |
| `calcDensity` edge cases | `core/check_calcDensityEmpty` |
| S2 kernel normalization | `core/check_S2KernelNormalization` |
| `S1Fun` arithmetic | `core/check_S1Fun` |
| `S1Fun/plot` options | `plotting/check_S1FunPlot` |
| MLS subsampling | `slow/check_MLSSubsample` |
| `radon` options | `core/check_radonOptions` |
| RBF approximation | `check_SO3FunRBFApproximation` at tests/ root — **known failure, #2588** |
| `calcPoleFigure` superposition | `core/check_calcPoleFigureSuperposition` |
| pole figure → ODF inversion | `slow/check_poleFigureInversion` |
| tensor factories, `tensor` constructor arguments | `core/check_tensorFactories` |
| which object owns `how2plot`, and that setting it does not leak into a shared symmetry | `core/check_plottingConventionOwnership` |
| `calcTensor` averaging | `slow/check_meanTensor` |
| ODF export interfaces | `core/check_odfExport` |
| `holdOn`/`holdRelease` semantics | `core/check_holdGuard` |
| `setMTEXpref`/`getMTEXpref` round trip | `core/check_mtexPref` |
| command window text wrapping, hyperlink integrity | `core/check_wraptext` |
| `mtexFigure` layout, colorbar placement | `plotting/check_colorbarLocation` |
| micron bar, reference frame indicator | `plotting/check_scaleBar` |
| polar histogram of directions, `setView` on a polaraxes | `plotting/check_polarHistogram` |
| `'arrow'` option of `vector3d/scatter` (e.g. `plotIPDF`) | `plotting/check_arrowPlot` |
| `grain2d/quiver` - arrow anchoring, center markers, head size | `plotting/check_grainQuiver` |
| overlays on a map (crystal shapes, S2Fun) sit on the viewer's side | `plotting/check_mapOverlays` |
| spherical axes labels | `plotting/check_sphericalAxesLabels` |
| color scale options | `plotting/check_logColorScale` |
| plots leave hold state untouched | `plotting/check_holdStatePlots` |
| EBSD map plot backends (patch/imagesc/surf), per-pixel shape contract | `plotting/check_ebsdMapBackends` |

## Fixtures

`lib/EBSDGrainBenchmark` generates synthetic EBSD maps with known grain structure and ground
truth in `prop.trueGrainId`; `lib/scoreGrainBenchmark` scores a reconstruction against it.
`benchmarkData/grainReconstructionReference` holds the stored topology snapshot for
`slow/check_grainReconstructionBenchmark`. Its `'update'` mode rewrites that file — the
hand-written provenance comments in it explain why each number is what it is, so check they
survive.
