# Documentation audit — open work

Working plan from the 2026-07-28 audit of all 251 `doc/**/*.m` pages, kept up
to date as items are closed. Items are grouped by the decision they need, not
by the page they live on.

**How to re-check link integrity.** The authoritative page set is what
`makeDoc` generates, and its naming rule (`@DocFile/DocFile.m`) is: a `.m`
file under an `@ClassName` directory publishes as `ClassName.basename.html`,
any other `.m` file publishes as `basename.html`. So flat class files such as
`SO3Fun/SO3KernelFunctions/SO3BumpKernel.m` are `SO3BumpKernel.html`, *not*
`SO3BumpKernel.SO3BumpKernel.html`. Note also that the in-repo
`doc/makeDoc/makeDoc.m` omits `SO3Fun` and `S1Fun` from its reference-folder
list while `web/matlab/makeDoc.m` includes `SO3Fun` — the website has pages
the local MATLAB help build does not (see item 5).

Status as of 2026-07-28: **49 dangling link instances / 45 distinct targets
across 18 pages** (was 59/52/23 before the fixes below).

## Closed

- **Kernel page links** (commit `c6b50f7a4`) — 12 links in `SO3Kernels.m` /
  `S2Kernels.m` used the doc page name as class prefix; plus `SO3Fun`,
  `SO3FunRBF` and `calcGBND` in the same two pages, which needed the opposite
  correction.
- **Malformed links whose target exists** (commit `a52cfd0bb`) — 10 links
  across 7 pages: `SO3FunHarmonic`, `SO3FunRBF`×2, `variants`×2,
  `calcVariants`, `caliper`, `fibonacciS2Grid`, `strainTensor`,
  `plottingConvention`.

## 1. Links to real API that `makeDoc` gives no page (12 instances)

The referenced functions exist and work; they simply produce no HTML page, so
the links dangle. Decide as a group — retarget each to its nearest existing
page, drop the link and keep the prose, or teach `makeDoc` to emit pages for
methods declared inside a classdef body.

### 1a. Declared in a classdef body, so no separate `.m` file exists

| link | where it really lives |
|---|---|
| `rotation.nan` | `geometry/@rotation/rotation.m:98` |
| `rotation.id` | `geometry/@rotation/rotation.m:102` |
| `rotation.rand` (×2) | `geometry/@rotation/rotation.m:106` |
| `rotation.inversion` | `geometry/@rotation/rotation.m:110` |
| `tensor.rand` | `TensorAnalysis/@tensor/tensor.m:236` |
| `EBSDhex.hex2cube` | `EBSDAnalysis/@EBSDhex/EBSDhex.m` |
| `SO3Fun.eval` | `SO3Fun/@SO3Fun/SO3Fun.m:46` (abstract declaration) |

Cited from `doc/Rotations/RotationDefinition.m:7,8,9,155`,
`doc/Tensors/TensorDefinition.m:197`, `doc/EBSDAnalysis/EBSDIndex.m:111`,
`doc/SO3Functions/SO3FunConcept.m:36`.

Fixing this class properly would mean extending `makeDoc` rather than editing
doc prose — these are exactly the entry points a reader wants to click.

### 1b. Method exists only on a base class

| link | nearest existing page | note |
|---|---|---|
| `orientation.calcDensity` (×2 live) | `rotation.calcDensity` | `doc/Misorientations/MDFAnalysis.m:36`, `doc/Tutorials/ODFTutorial.m:31` |
| `orientation.std` | `quaternion.std` | `doc/PhaseTransistions/MartensiteVariants.m:55` |
| `orientation.discreteSample` | `SO3Fun.discreteSample` | `doc/GeneralConcepts/OptimalKernel.m:46` |
| `orientation.calcAxisDistribution` | `SO3Fun.calcAxisDistribution` | `doc/Misorientations/MDFAnalysis.m:141` |
| `grainBoundary.length` | `grainBoundary.segLength` | `doc/GrainBoundaries/BoundaryProperties.m:126` — different name, check the prose still reads right |
| `grain3d.hasHole`, `grain3d.isInclusion` | `grain2d.hasHole`, `grain2d.isInclusion` | `doc/EBSD3Analysis/Grains3DProperties.m:12` — page already marks these TODO |
| `grain3d.shapeFactor` | `grain2d.shapeFactor` | `doc/EBSD3Analysis/Grains3DProperties.m:11` — likewise |

`makeDoc` deliberately emits no page for inherited methods, so retargeting to
the base class is the only link that can ever resolve. For the `grain3d`
three, the page is documenting a 3D method that does not exist yet — pointing
at the 2D one would be misleading, so these may belong with item 2 instead.

## 2. Links to API that does not exist anywhere (8 instances)

Each needs a drop-the-link vs. implement-the-function decision.

| link | cited at | note |
|---|---|---|
| `rotation.byQuaternion` | `doc/Rotations/RotationDefinition.m:6` | not present in `@rotation/rotation.m` |
| `rotation.byHomochoric` | `doc/Rotations/RotationDefinition.m:6` | ditto; homochoric support exists elsewhere (`SO3FunHomochoric`, `quaternion/cubochoric.m`) |
| `rotation.mirroring` | `doc/Rotations/RotationDefinition.m:9` | ditto |
| `orientation.cube` | `doc/CrystalOrientations/OrientationFibre.m:7` | no such method |
| `EBSD.export_cpr` | `doc/EBSDAnalysis/EBSDExport.m:6` | only `export_crc` / `export_ctf` exist |
| `grain3d.equivalentSurface` | `doc/EBSD3Analysis/Grains3DProperties.m:10` | no such method |
| `twinningSystem.twinningSystem` | `doc/CrystalOrientations/DefinitionAsCoordinateTransform.m:71` | no such class anywhere in MTEX |
| `S2AbelPoussinKernel` | `doc/SphericalFunctions/S2Kernels.m:29` | part of item 4 below |

## 3. Referenced doc pages that were never written (5)

| page | cited at |
|---|---|
| `EBSDGradient` | `doc/EBSDAnalysis/EBSDGrid.m:14` |
| `IceSphericity` | `doc/Grains/ShapeParameters.m:18` |
| `SO3FunVisualization` | `doc/SO3Functions/SO3FunConcept.m:63` |
| `RotationRepresentations` | `doc/Rotations/RotationDefinition.m:16` |
| `ParentGrainReconstruction` | `doc/PhaseTransistions/ParentChildVariants.m:139` |

Each needs a decision on scope and a TOC slot before it can be written.

## 4. `S2Kernels.m` intro list is broken markup (lines 22-29)

Four bullets use `@ClassName`, which is not MTEX link syntax and renders
literally; line 28 is mangled (`@S2AbelPoussinKernel.html de >`); line 29 says
"vom Mises" (typo for von) and links it to the same nonexistent target.
Neither an Abel-Poisson nor a von Mises kernel exists for S2. The real set is
`S2DeLaValleePoussinKernel`, `S2DirichletKernel`, `S2BumpKernel`,
`S2RestrictedDistanceKernel`, `SchulzDefocusingKernel` — and
`S2RestrictedDistanceKernel` is missing from the list. Needs the list
rewritten, not a prefix fix.

## 5. `doc/makeDoc/makeDoc.m` omits SO3Fun and S1Fun

Its `mtexFunctionFiles` list covers `S2Fun`, `EBSDAnalysis`, `ODFAnalysis`,
`PoleFigureAnalysis`, `TensorAnalysis`, `plotting`, `geometry`, `interfaces`,
`tools`. `web/matlab/makeDoc.m` has the same list plus `SO3Fun` and
`doc/FunctionReference`. Consequence: the MATLAB help built from the repo has
no reference page for any `SO3Fun*` class, so every `SO3Fun.*.html` link is
dead there while working on the website. Probably just needs the two folders
added.

## 6. Title-only stub pages (22)

Re-verified 2026-07-28. Seventeen are wired into a TOC, so they publish as an
empty page; all are 15-65 bytes, i.e. a `%%` title and nothing else. Each
needs either content or removal from its TOC.

`Misorientations/AngleDistributionFunction`,
`Misorientations/AxisDistributionFunction`, `Grains/GrainExport`,
`Tutorials/ImportFromVPSC`, `CrystalOrientations/OrientationExport`,
`PhaseTransistions/PhaseTransitions`, `Plotting/PlottingExport`,
`PoleFigureAnalysis/PoleFigureExport`, `GeneralConcepts/Properties`,
`Rotations/RotationExport`, `Rotations/RotationImport`,
`SphericalFunctions/S2FunRadon`, `Plasticity/SachsModel`,
`Plasticity/SlipTransmission`, `CrystalOrientations/SpecimenSymmetry`,
`Plasticity/TextureEvolution`, `Misorientations/Twinning`.

Five further stubs are in no TOC and linked from nowhere, so they are pure
dead weight and can simply be deleted: `ODFAnalysis/DiscretizationError`,
`EBSDAnalysis/EBSDAxisAngleMaps`, `ODFAnalysis/ImportExportODFAnalysis`,
`Plasticity/TwinningTutorial`, and the 0-byte
`doc/VectorsRotations/RotationsOperations.m` (its whole folder looks stale).

Not stubs, despite having no executable code — these are legitimate
prose-only pages: `EBSDExport`, `EBSDInterfaceHDF5`, `Contribute2Doc`,
`GeneralConceptsConfiguration`, `MisorientationGrainExchangeSym`.

## 7. Orphan pages (16)

No TOC entry and no inbound link, so unreachable in the published docs. Ten
have real content and need a decision each — give it a TOC slot, link it from
a related page, or delete it as superseded:

| page | code lines |
|---|---|
| `Grains/GrainReconstructionOld.m` | 55 |
| `Plasticity/SlipTransmition.m` | 52 (note the misspelling; `Plasticity/SlipTransmission.m` is the empty stub in item 6) |
| `Grains/Grain_dispersion_axes.m` | 41 |
| `GrainBoundaries/BoundaryMisorientations.m` | 35 |
| `Misorientations/MDFAnalysis.m` | 23 |
| `Plasticity/DislocationSystems.m` | 16 |
| `Vectors/VectorDefinition.m` | 15 |
| `Grains/Dream3dGrains.m` | 9 |
| `Tutorials/BoundaryTutorial.m` | 8 |
| `SphericalFunctions/S2FunQuadrature.m` | 3 |

The remaining six are the stubs already listed in item 6.

`Vectors/VectorDefinition.m` has a likely explanation: it is a newer, larger
rewrite (1530 B, May 2025) of `Vectors/VectorsDefinition.m` (1115 B, Apr
2024), and `Vectors.toc` still points at the older one. Probably just needs
the TOC repointed and the stale file deleted — but confirm which text is
wanted first.

Checked and clean: all 31 `.toc` files resolve, 0 broken entries. (An earlier
report of three broken entries — `mapPlot`, `scaleBar`, `sphericalPlot` in
`plotting_index.toc` — was a false positive; those are classdefs in
`plotting/` whose reference pages do exist.)

## 8. To fix: plotting a subset of grain boundaries

`doc/Grains/SelectingGrains.m:48` → `@grainBoundary/plot.m:49` → subfunction
`plotOrdered2:82` → `tools/graph_tools/EulerCycles2.m:16`, "Sparse matrix
sizes must be nonnegative integer scalars". Re-verified 2026-07-28 by running
the page end to end.

Plotting a *subset* of boundaries is a common operation, so this is worth
fixing. Note it does not trigger for every subset: plotting
`grains(1:n).boundary` for n in {1,2,5,20,100} and `grainSize>500` on
forsterite all succeed. The page's failing subset comes from its simulated
mouse click, so reproduce it by running the page rather than by picking a
subset by hand. Most likely an index-remapping gap in `plotOrdered2` when the
boundary's vertex/segment ids are no longer contiguous.

## 9. Deferred (decided 2026-07-28: revisit much later)

Verified as still present, deliberately not being worked on now. Recorded so
they are not rediscovered from scratch.

- **`interp(...,'bingham')` is wrong under symmetry.** It does not error, it
  silently returns a bad fit. Relative error against the source ODF, from
  `fibreODF(fibre.rand(cs))` sampled on `equispacedSO3Grid(cs)`:
  `'1'` 0.0043, `'2'` 0.92, `'222'` 0.95, `'432'` 0.67. This is what
  `doc/SO3Functions/SO3FunApproximationTheory.m:172` ("TODO: Dont work")
  refers to; the page works around it by using `crystalSymmetry("1")`.
- **`SO3FunVectorField.m:209`** — `quiver3` on an `SO3VectorFieldHandle`
  allegedly plots something other than what `eval` returns. Not confirmed: the
  page runs, and the arrow count is consistent with the small cubic
  fundamental zone, so the complaint is about arrow directions and needs a
  visual check.
- **`latticeBasis.m:38` "Index exceeds array bounds"** via
  `doc/EBSDAnalysis/EBSDGrid.m:141` → `EBSD/plot:93` → `EBSD/plotUnitCells:51`
  → `plotSurf:15` → `calcMesh:29`. The unguarded `cand(1)` is only the
  symptom. At the crash site the `EBSDsquare` carries a degenerate,
  self-intersecting unit cell — the page asked for a unit square
  (`0.5*vector3d([-1 -1 1 1],[-1 1 1 -1],0)`) but the stored cell is

      V (centred)          trans                d = |cos| to a1
       0.4167   3.4969      0.0000  -1.0760      1.0000
      -0.4167  -4.5729     -0.8333  -8.0698      0.9947
      -0.4167  -3.4969      0.0000   1.0760      1.0000
       0.4167   4.5729      0.8333   8.0698      0.9947

  so every candidate translation is near-parallel to `a1` and
  `find(d<0.5)` is empty. Guarding the index would hide the real defect.
  Only reachable because `@EBSDsquare/plotUnitCells.m` and
  `@EBSDhex/plotUnitCells.m` are deleted in the working tree (in-flight
  plotting refactor) — the deleted override dispatched straight to `plotSurf`
  and never entered `latticeBasis`.
- **`@EBSDsquare/interp.m:31`** — `doc/EBSDAnalysis/EBSDInter.m:32` does
  `interp(ebsd,30.5,5.5)` on a gridified EBSD and dies in
  `griddedInterpolant` with "Data is in MESHGRID format, NDGRID format is
  required". The function wraps the call in try/catch with a transposed
  fallback; both orientations fail. Committed, clean code.
- **`SO3FunRBF/private/spatialMethod.m:37`** — `doc/PoleFigureAnalysis/
  PoleFigureRefinement.m:21` calls `calcODFIterative(pf,'nothinning')` and
  dies at `y = reshape(y,numel(nodes),[])` with "Product of known dimensions,
  78, not divisible into total number of elements, 3", via
  `calcODFIterative:92` → `SO3FunRBF/interpolate.m:105`. Committed, clean code.
- **`import_wizard_old`** is called from four doc sites — `ODFImport.m:18`,
  `PoleFigureImport.m:16` and `:134`, `PoleFigureTutorial.m:8` — but lives
  only in `obsolete/`. Needs a product decision (point at a current wizard, or
  rewrite those GUI sections around the load commands).
- **26 prose TODO markers** ("extend this section", "explain in more detail")
  across the doc pages; six of them sit on stub pages already listed in item
  6. Authoring backlog.
- **Dead external links**: 13 `code.google.com` in `changelog.m` (archive
  material), and a `t.co` shortener on a live page,
  `doc/Grains/HullBasedParameters.m:18`.
- **18 of the 48 remaining dangling link instances are inside `changelog.m`**
  — archive entries naming functions that were later removed or renamed.
  Probably out of scope for link repair.
