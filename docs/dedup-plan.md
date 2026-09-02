# Duplication since 7.0 — work plan

Working plan from the 2026-09-02 audit of the code added between `mtex-7.0.0`
and `develop`. The audit looked for one thing: code that grew to cover an
individual case, and the duplication that follows from it. Grouped into work
packages by the seam they share, not by the file they live in. The MLS classes
are out of scope by decision on 2026-09-02.

Nothing added since 7.0 has shipped, so nothing in this plan carries a
compatibility duty. A branch, a flag or a helper introduced in this cycle can go
without a deprecation step.

## Ground rules

- One branch per work package, `feature/<name>`, merged into `develop` when its
  checks pass. Packages are independent unless a row says otherwise.
- **The file ends shorter.** A package that leaves a file longer than it found it
  has failed at that file. Where the shorter version drops a case, the row says
  which and the loss is the decision of whoever merges.
- **No trace of the detour.** No comment naming what was replaced, no
  "kept for compatibility", no shim that warns about an option that is gone.
- **Baseline before touching.** Every package starts by recording what the
  current code produces, so the comparison after is numeric rather than a
  matter of taste. The baseline is named per package.
- **Tests run only on request.** Each package lists the checks to ask for; none
  is started unasked. Targeted probes through the bridge stay under five minutes.

## Decisions needed up front

| # | decision | recommendation |
| --- | --- | --- |
| D1 | delete the legacy layout engine and the `newLayout` preference, or keep it one release | delete; it is unreleased and was extended this cycle only to stay level with the new one |
| D2 | `plotS2Grid`: one sweep direction, at the price of more NaN-separated strips on corner-cut sectors | one sweep, with the strips sharing the grid line where they branch or join |
| D3 | fold `sphericalAxisHeight`, `axisBox`, `axisArea` into one `axisBox` preference | no: the website wants spherical figures 370 high and maps up to 480, which one box cannot say |
| D4 | `spatialTransformRigid` becomes a `Shift` with a mean-displacement `fit`, or stays a class of its own | done; `rigid * rigid` folds into an affine that only moves |
| D5 | tolerance at which the undistorted TrueEBSD result has to agree with today's, when the dense shift field goes | measured, see WP3; the decision is at merge |
| D6 | `'doNotDraw'` stays accepted as a no-op for user scripts, while the 20 in-tree sites stop passing it | yes; one line in `drawNow` keeps the flag harmless |

## Work packages, in order

The order is by lines removed per unit of risk. WP1 and WP4 have numeric tests
already; WP3 is the largest and needs its baseline built first.

### WP1 — one layout engine (`feature/oneLayout`)

**Done 2026-09-02**, rows 1.1 to 1.10, on the branch. Two rows came out
differently from the table:

- 1.9 keeps the two preferences. The website build sets a spherical height
  of 370 beside a box 480 high, so one `axisBox` would grow every published
  spherical figure by a third. D3 does not hold; what went was the double
  `figSizeFactor` call.
- 1.11 stays as it is. A hold can only be taken on a figure that exists, and
  the twenty sites pass `'doNotDraw'` into the call that creates it, or
  forward it through `varargin` into nested plot calls that a hold would not
  reach.

Every position of the thirteen zoo figures is unchanged to the pixel and
twelve of the published images are byte identical; the thirteenth draws a
random sample. All five checks pass. 780 lines out, 142 in.

| # | what goes | where | how it is checked |
| --- | --- | --- | --- |
| 1.1 | `drawNowLegacy`, the `newLayout` branch in `drawNow.m:59` and `updateLayout.m:12`, the preference in `mtex_settings.m`, and the bodies of `calcPartition`, `calcAxesSize`, `calcTightInset`, `updateLayout` — including the `fixedAxisHeight` branches they gained this cycle | `plotting/@mtexFigure` | `check_mtexLayout`, `check_publishedFigure` |
| 1.2 | `requestedSize` in `drawNow.m:168` becomes the only copy of what `drawNowLegacy` also held | `drawNow.m` | same |
| 1.3 | `@mtexFigure/private/axesRatio.m`, identical to `@mtexLayout/private/axesRatio.m` bar the See-also line; one copy in `plotting/plotting_tools/` | both private folders | same |
| 1.4 | `colorbarSpec` in `measure.m:161` versus `calcTightInset.m:70` — after 1.1 only the first exists; the `try/catch` around `TightInset` inside it is a guard for one release and becomes a single branch | `measure.m` | `check_colorbarLocation` |
| 1.5 | the `ratioOf` cache and its three properties in `mtexLayout.m:105-143`; `measure`'s token already carries the camera state. One `cameraState` helper replaces the two 15-element key builders, and the four `PolarAxes` early-outs collapse into it | `mtexLayout.m`, `measure.m`, `axesRatio.m`, `axesInset.m` | `check_mtexLayout` |
| 1.6 | `heldFig` (written, never read); the second `isHeld` test in `resolve.m:30` | `mtexLayout.m`, `resolve.m` | `check_holdStatePlots` |
| 1.7 | the outer loop in `drawNowLayout` (`drawNow.m:129`) around `resolve`'s inner loop — `resolve` takes the refit and settles both in one loop | `drawNow.m`, `resolve.m` | `check_mtexLayout` timing row |
| 1.8 | the `[]`-versus-handle block in `adoptColorbars.m:33` and `adoptLegend.m:51`; `cBarAxis`/`legendAxis` initialise as `gobjects(0,1)` | `mtexFigure.m` and both adopters | `check_colorbarLocation` |
| 1.9 | the spherical/boxed branch in `drawNow.m:43` and again in `requestedSize`; one preference, one branch (D3) | `drawNow.m`, `mtex_settings.m`, `tests/plotting/publishFigureZoo.m` | `figureZoo` pixel comparison |
| 1.10 | `outerSpacing` property shadowing `figTightInset`; `screenExtent` wrapper beside direct `getScreenExtent` calls | `mtexFigure.m`, `drawNow.m` | `check_mtexLayout` |
| 1.11 | the 20 call sites passing `'doNotDraw'` use `layoutHold` (D6) | tree-wide | `check_holdStatePlots`, `figureZoo` |

**Baseline.** `publishFigureZoo` under the website preferences before the first
edit, kept in the scratchpad; the same publish after each row, compared image
by image. `check_mtexLayout` numbers as they stand.

**Expected.** About 500 lines out of `plotting/@mtexFigure` and `@mtexLayout`.

### WP2 — one spherical region path (`feature/oneSphericalRegion`)

**Done 2026-09-02**, rows 2.1, 2.2, 2.3, 2.5 and 2.6, on the branch. Two
rows came out differently from the table:

- 2.3: the second sweep hid a defect of the cut. The cells between the last
  grid line of one strip and the first of the next were never drawn, which
  showed as white wedges in the axis angle sections of `m-3` and `23` as soon
  as one sweep was left. Strips share the grid line where they branch or join
  now; the wedges are gone, and so are the corner slivers the two sweeps had.
- 2.4 stays. The three ways a frame reaches `annotateFrame` are three live
  caller conventions - `S2Fun/plot` passes the frame positionally,
  `sphericalPlot` forwards positional symmetries, `newSphericalPlot` passes
  `'dataFrame'` - and `namesOwnAxes` compares against the session frame,
  which is not the canonical X, Y, Z test of `conventionChar`.

The hemisphere and sector grids are bit identical to the old `makeGrid`,
`check_plotS2Grid` and `check_hemispherePlots` pass, and the zoo is unchanged
to the pixel. `check_sphericalAxesLabels` and
`check_plottingConventionOwnership` fail on develop already, on stale
assertions. 310 lines out, 117 in.

| # | what goes | where | how it is checked |
| --- | --- | --- | --- |
| 2.1 | `makeSphericalProjection.m:22-96`, the same region and projection logic as `newSphericalPlot.m:130-204`; one shared function, and `S2Fun/plot.m` calls it | `plotting/`, `plotting/plotting_tools/` | `check_hemispherePlots` |
| 2.2 | `sphericalProjection/makeGrid` (`sphericalProjection.m:98-145`), the pre-7.0 `plotS2Grid` verbatim; it calls `plotS2Grid` | `plotting/sphericalProjections/` | S2Fun plot pages in `figureZoo` |
| 2.3 | the second sweep in `plotS2Grid.m:57-80`, `rhoIntervals.m`, the `lowerPole/upperPole` arguments of `buildStrips` that exist for it, the `rhoRange` seed at line 47, and the `checkInside` safety net at line 90 (D2). `thetaIntervals` and `rhoIntervals` are twins; if D2 keeps both directions, they become one `intervals(sR,which)` | `geometry/geometry_tools/`, `geometry/@sphericalRegion/` | `check_hemispherePlots`, the #209 axis-angle section case |
| 2.4 | the three ways a frame reaches `annotateFrame.m:54-60`; all callers pass `'dataFrame'`, so that is the one way in. `namesOwnAxes` uses `referenceFrame/conventionChar`'s test | `plotting/plotting_tools/`, three callers | `check_sphericalAxesLabels` |
| 2.5 | `plottingConvention/matchDefault`, a no-op with one caller | `plottingConvention.m`, `specimenSymmetry.m:211` | `check_plottingConventionOwnership` |
| 2.6 | `directionColorKey.hsvFallback` and the lazy subclass construction in the base | `directionColorKey.m` | `ipfHSVKey` on a handful of point groups through the bridge, colours compared |

**Baseline.** `figureZoo` publish as in WP1; `plotS2Grid` node counts and
NaN counts for the point groups of #209 (`m-3`, `23`, `mmm`) at 5 degree.

**Expected.** About 250 lines.

### WP3 — one representation of a distortion (`feature/oneDistortion`)

**Done 2026-09-02**, all three stages, three commits on the branch. Rows that
came out differently from the table:

- 3.4: `spatialTransformShift.fit` goes through the shared solver but stays
  the plain weighted least squares fit, since `check_spatialTransform` asserts
  that an outlier moves it, and the robust variant cost hop 1 of the WC-Co job
  0.08 px.
- 3.9 stays. The channel handling in `dynProp` serves every grid class
  property with several channels - `EBSD/reshape`, `subSet` and `scatterProp`
  all rest on r × c × k - not one caller.
- 3.15 keeps one guard: `check_mapImage` asserts that a constant image is left
  alone, which the builtin `rescale` does not do.
- The drift stage keeps its `'extrapolate'` option, which a test pins in both
  directions; the workflow asks for it at its one fit call.
- The test image handed from one stage to the next is still resampled stage
  by stage. Resampling it once through the exact inverse of the composite is
  the same map to six digits, but the residual of hop 1 is measured on that
  image and moved from 1.36 to 1.69 px with the rounding alone.

D5, measured on the hand tuned WC-Co job: the affine hops are unchanged to
1e-13 px, the tilt hop moves by 0.011 px median and 0.43 px at the far
corner, the residuals agree to two decimals, one to three percent of the
resampled pixels change at nearest neighbour ties and the border, and every
output map is translated by the offset it no longer carries. The box filter's
border rule reaches every pixel of a rescaled image, by up to 0.1. All five
checks and the three doc pages pass. 1152 lines out, 300 in.

**Stage a — the class hierarchy carries its own behaviour.**

| # | what goes | where |
| --- | --- | --- |
| 3.1 | `spatialTransformTilt`'s `eval`, `inv`, `isid`, `paramChar`, `stageList`, `char`, `shortChar` — it subclasses `spatialTransformComposite` and keeps `fitStage` and its default stages. The `isa(proto,'spatialTransformTilt')` branch in `calcDistortion.m:424` goes with it | `geometry/spatialTransforms/`, `@trueEbsd/calcDistortion.m` |
| 3.2 | nine `char` methods that are class name plus `paramChar`; one concrete `char` in the base | all subclasses |
| 3.3 | the two switch-on-class fit tables, `fitHopStage.m:81` and `Tilt.m:66`; one instance method `fit(proto,posA,posB,'weights',w)` on the base, each subclass reading its parameters off `proto`. This also removes the drift: Projective dropping the weights, Drift hard-coding the slow scan | `@trueEbsd/private/`, `spatialTransforms/` |
| 3.4 | `Shift.fit`'s own weighted solve; it is `shiftMatrix(Poly.fit(...,'degree',1))`. Weights validated once in `transformFitData`, not again in `robustLsq` and `Rigid` | `spatialTransformShift.m`, `Rigid.m`, `private/robustLsq.m` |
| 3.5 | the three `absorb` tables (D4) | `Shift.m`, `Rigid.m`, `Projective.m` |

Checked by `check_spatialTransform`, `check_spatialTransformFit`, bit identity of
the fitted coefficients on the fixtures both use.

**Stage b — the dense shift field goes.**

| # | what goes | where |
| --- | --- | --- |
| 3.6 | `pairShifts` as a stored representation: `fitHopStage.m:56-68` stops sampling `T` onto every pixel; `undistort.m:74-85` stops summing fields and composes `job.T` with `*`; the identity hop's zero field in `calcDistortion.m:200` is `spatialTransformId` | `@trueEbsd`, `tools/registration_tools/@pairShifts` |
| 3.7 | `remapShifted` with `inverseRemap` and the `'test2ref'/'ref2test'` switch; the undistorted image is `interp(img, eval(inv(T),posRef))` through `@mapImage/interp`, and `spatialTransformInverse` is the one inverter | `tools/registration_tools/` |
| 3.8 | `rebuildMap` in `undistort.m:149` and the same loop in `pixelSizeMatch.m:234`; both are `gridify(interp(ebsd,posNew),gL)` once `EBSD/interp` keeps unindexed points, which is a one-place fix in `interp` | `@trueEbsd`, `@EBSD/interp.m` |
| 3.9 | the `nChannels`/`objShape`/`assignRows` block in `dynProp.m:262-335`, there for one producer; that producer reshapes to `n x k`, the convention `EBSD/interp` already uses | `tools/dynProp.m`, `undistort.m:132` |
| 3.10 | `'backend'`, `'remapBackend'`, the `'xcfBackend'` warning and the five-class list for `retryMax` in `calcDistortion.m:73-96`; `undistort`'s own `'backend'` | `@trueEbsd` |
| 3.11 | `roiShift` in `calcDistortion.m:438` and `hopStr` in `display.m:107`; one summary read off the transform | `@trueEbsd` |

**Baseline for stage b.** Run `check_trueEbsd` and the three doc pages
(`EBSDTrueEbsd`, `EBSDMapsAndImages`, `EBSDSpatialTransform`) before the first
edit and keep every output array of `job.undistort` in the scratchpad. After
stage b the same arrays are compared at the D5 tolerance. ADR 0006 states the
class reproduces every published number; that is what D5 protects.

**Stage c — utilities that exist already.**

| # | what goes | replaced by |
| --- | --- | --- |
| 3.12 | `nameOf`, `imgName`, `nameStr` | the constructor assigns `img%d` once, so `.name` is never empty |
| 3.13 | `sizeStr` twice | `size2str` |
| 3.14 | `@mapImage/private/percentileOf.m` | `quantile` |
| 3.15 | `stretch` in `rescale.m:64` | MATLAB `rescale` |
| 3.16 | `boxMean`/`boxSum`/`padReplicate` in `imboxfilt.m:57` | `movmean` twice, edge rule stated |
| 3.17 | `gridSize` in `mapImage.m:193` | `size(mg.img,[1 2])` |
| 3.18 | three `layoutIndex` calls with the same arguments in `transformReferenceFrame.m:98`; `rotateBasis`/`rotateVector` beside `ori * v` | one call, the product |
| 3.19 | `'dedupeBand'`, `'coarseMesh'` in `xcfCorrelate`, `'tune'` in `robustLsq`, the `pairShifts` copy constructor, `~iscell(job.shifts)` in `display.m:96`, `repmat(spatialTransform.empty,1,0)` in `trueEbsd.m:117` | nothing passes them |
| 3.20 | the `isMap` fork in `xcfShift.m:64,120` | a bare matrix is wrapped as a `mapImage` at the top |

Checked by `check_mapImage`, `check_mapImagePlot`, `check_spatialTransform`.

**Expected.** About 900 lines across the three stages, `remapShifted` and
`@pairShifts` gone as files.

### WP4 — the exporters reference what the loaders own (`feature/exportersShareLoaders`)

**Done 2026-09-02**, one commit on the branch. Rows that came out differently
from the table:

- 4.7 and 4.15 stay. Both avoid a read of the reference file, which is a
  cost and not a duplication, and the sentinel would have to travel through
  the provenance struct to be recorded at import.
- 4.10 keeps the grid path and drops the other one. A Channel text file is a
  grid, so a map that is no axis aligned grid is refused by `gridSteps` with
  the advice to rotate it back.
- 4.3 needed one shared helper after all: `phaseId` of a gridded map is a
  column, not the matrix its shape suggests, and a padded hexagonal cell
  carries NaN there.

Every text export of eight maps is byte identical to before, every HDF5
export of four vendor files reads back identically, `check_ebsdExport` and
`check_odfExport` pass. `check_ebsdImport` and `check_ebsdImportH5` fail on
develop already - eclogite gridifies to 58 × 37, scan 3 of EMSphinx has 13
not indexed pixels - with the same numbers under the loaders of the branch.
325 lines out, 153 in.

| # | what goes | where | how it is checked |
| --- | --- | --- | --- |
| 4.1 | `scrPrnt` in all three exporters; one `interfaces/private/scrPrnt.m`, or three `fprintf` formats. `silent` exists for all or none | `exportEBSD_h5/ang/ctf.m` | `check_ebsdExport` |
| 4.2 | the TSL tables: `tslSymmetryCodes.m:31` equals `TSL2pointGroup.m:112`, `laueList` is the inverse of the switch at `TSL2pointGroup.m:60`, and `mtexId2ctfId` in `exportEBSD_ctf.m:62` is a third table beside the Channel list in `loadEBSD_ctf.m:32` and `loadEBSD_crc.m:245`. One owner per list, indexed from both sides | `interfaces/private/`, `interfaces/tools/`, both ctf files | `check_ebsdExport` round trips |
| 4.3 | `angPhaseNumbers` and both `phaseColumn` helpers; the outcome is 1..N in `indexedPhasesId` order either way, which is a three-line lookup table | `exportEBSD_ang.m:202-228`, `exportEBSD_ctf.m:186,261` | same |
| 4.4 | `csOf` and its copy `csOfPhase` in the test; `ensureCSArray` rules the cell out | `interfaces/private/csOf.m`, three callers, `check_ebsdExport.m:275` | same |
| 4.5 | `export_h5`'s translation into a `'root'` option nothing reads; the wrapper is the one line `export_ang` and `export_ctf` are | `@EBSD/export_h5.m` | same |
| 4.6 | the three attempts in `writeHeaderValue` (`exportEBSD_h5.m:296-307`); `writeFixedString` already handles both string types | `exportEBSD_h5.m` | `check_ebsdImportH5` (slow), the h5 vendor corpus round trip |
| 4.7 | the not-indexed sentinel recomputed on export, reading the data set once for its class and again for its data; the loader records it in `opt.h5.phase` | `loadEBSD_h5.m:552`, `exportEBSD_h5.m:211,512,550` | same |
| 4.8 | `fileLength` reading a whole column to count it; `h5info(...).Dataspace.Size` | `exportEBSD_h5.m:471` | same |
| 4.9 | the step-size rectangle literal in `loadEBSD_ang.m:107`, `loadEBSD_ctf.m:67`, `loadEBSD_h5.m:397` and the hand-typed hexagon at `loadEBSD_ang.m:105`; `calcUnitCell`'s `regularPoly` exposed or the step passed through | three loaders, `interfaces/tools/calcUnitCell.m` | `check_ebsdImport`, unit cells bit identical |
| 4.10 | the gridded path of `exportEBSD_ctf` (`isGrid`, lines 70-81, 158-164, 212-217); the ungridded path writes a gridded map correctly, padded hex cells excepted — say so | `exportEBSD_ctf.m` | `check_ebsdExport` hex case |
| 4.11 | `importedHeader.m`, `hdrGet`'s double absence check and two-way coercion; `buildHeaderStruct` coerced already | `interfaces/private/` | `check_ebsdExport` |
| 4.12 | `gridSteps`'s unused default and the `fmt` argument that names only an error | `interfaces/private/gridSteps.m` | same |
| 4.13 | `space_group_TSLNumber`, reducible to the `EDAX` handler with one field; `EMSphinx.json` points at that | `loadEBSD_h5.m:454`, `hdf5_config/EMSphinx.json` | `check_ebsdImportH5` EMSphInx file |
| 4.14 | `latticeFreedom` in `import_wizard.m:2158` and `impliedAngles` in `buildImportWizardScript.m:81`; one method on `latticeType`, which already knows | `interfaces/import_wizard/`, `geometry/latticeType.m` | wizard script generation on the fixture set |
| 4.15 | the VPSC letter switch in both directions | `loadODF_VPSC.m:93`, `@orientation/export_VPSC.m:24` | `check_odfExport` |

**Baseline.** Export every fixture `check_ebsdExport` uses, and the vendor
corpus, before the first edit; after each row the files are byte-compared where
the format is deterministic and value-compared where it is not.

**Expected.** About 350 lines.

### WP5 — small single-caller cases (`feature/singleCallerCases`)

**Done 2026-09-02**, seven commits on the branch, one per row group. Rows
that came out differently from the table:

- 5.1 keeps `'method','steepestDescent'` as an alias that empties the memory,
  by decision on 2026-09-02; the second branch through the loop is gone.
- 5.8 also drops the assertion in `check_calcLankford` that asked for a
  message of its own on a rho outside [0,1], by decision on 2026-09-02.
- 5.11 stays. `char(cs,'compact')` is the symmetry name with a link, not the
  plotting convention in crystal directions the header shows.
- 5.12 stays. The table is the only place that carries the description of
  each family; the constructors carry only their indices.
- 5.6 does the double parse only; the key stays a numeric vector, a digest
  would save nothing.

Every sample, weight, discrepancy, axis distribution and fundamental region
of a fixed seed is bit identical to before. check_optimalSample,
check_axisDistribution, check_calcLankford, check_calcParent2Child and
check_referenceFrame pass. 281 lines out, 183 in.

| # | what goes | where | how it is checked |
| --- | --- | --- | --- |
| 5.1 | `'method','steepestDescent'`, `useLBFGS` and both `else` loops in the two `optimalSample` files; `'memory',0` is that method | `S2Fun/@S2Fun/optimalSample.m`, `SO3Fun/@SO3Fun/optimalSample.m` | `check_optimalSample`, discrepancy equal at equal iterations |
| 5.2 | `lambda` normalised to 1 and then threaded through seven calls | `S2Fun/@S2Fun/optimalSample.m:229` | same |
| 5.3 | the `innerIter` and weight-option warnings, prose about a previous version | both `optimalSample` files | same |
| 5.4 | `twoLoop` twice and the kernel weight setup three times, the third in `discrepancy.m:60`; one private `kernelWeights`, `twoLoop` once under `tools/` | `S2Fun/@S2Fun/`, `SO3Fun/@SO3Fun/` | same |
| 5.5 | the `minAngle/maxAngle` clip in three `calcAxisDistribution` files; `symmetry`'s version is a one-line wrapper around `orientationRegion`'s | `geometry/@orientationRegion`, `geometry/@symmetry`, `SO3Fun/@SO3Fun` | `check_axisDistribution` |
| 5.6 | `fundamentalRegion` parsing its second argument twice, the hand-rolled key, `exist('dcs','var')`; `dcs` computed in both branches, key by `digest` as `ipfColorKey.m:222` does | `geometry/@symmetry/fundamentalRegion.m` | regions bit identical on every point group pair, cache hit rate unchanged |
| 5.7 | `gridLayout.assumedFor` re-deriving `orientation.byScreenAlignment` and its empty-convention assert | `geometry/@gridLayout/gridLayout.m:169-183` | `check_gridify` (slow) or a handful of layouts through the bridge |
| 5.8 | the validation block in `calcLankford.m:59-108`; `isPerp(RD,ND)` stays | `ODFAnalysis/calcLankford.m` | `check_calcLankford` |
| 5.9 | the two-branch call in `calcTaylorFun` (`calcTaylor.m:161`); one call with three outputs | `TensorAnalysis/@strainTensor/calcTaylor.m` | Taylor pages in `figureZoo` |
| 5.10 | the `s == 1` branch, `delete_option('global')`, and the undocumented `numLocal` and `3000` in `calcParent2Child` | `geometry/misorientation/calcParent2Child.m:78,131,173` | `check_calcParent2Child` |
| 5.11 | the hand-built convention header in `crystalSymmetry/display.m:9` and `specimenSymmetry` display; `char(cs,'compact')` renders it | `geometry/@crystalSymmetry`, `geometry/@specimenSymmetry` | display output compared |
| 5.12 | `hexHint`'s family table beside the ten static constructors that encode the same | `geometry/@slipSystem/slipSystem.m:254` | error text compared |

**Expected.** About 250 lines.

## What the tree gains

Nothing. Every row removes a path, a table or a guard and keeps the behaviour
the tests state. The rows that lose a case say so: 2.3 (more strips), 4.10
(padded hex cells on ctf export), 5.8 (error messages from arithmetic instead
of from a check).
