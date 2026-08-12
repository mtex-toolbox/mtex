# Documentation audit — open work

Working plan from the 2026-07-28 audit of all 251 `doc/**/*.m` pages, kept up
to date as items are closed. Items are grouped by the decision they need, not
by the page they live on.

**How to re-check link integrity.** The authoritative page set is what
`makeDoc` generates, and its naming rule (`@DocFile/DocFile.m`) is: a `.m`
file under an `@ClassName` directory publishes as `ClassName.basename.html`,
any other `.m` file publishes as `basename.html`. So flat class files such as
`SO3Fun/SO3KernelFunctions/SO3BumpKernel.m` are `SO3BumpKernel.html`, *not*
`SO3BumpKernel.SO3BumpKernel.html`.

There are **two** builds and they had different folder lists, which used to
make the same link resolve on the website and not in the local MATLAB help.
Both lists now agree (see item 4), but keep the distinction in mind: the
in-repo `doc/makeDoc/makeDoc.m` builds the MATLAB help into `doc/html`, while
`~/mtex/web/matlab/makeDoc.m` builds the website into
`~/mtex/web/pages/{function_reference_matlab,documentation_matlab}` and
additionally publishes `~/mtex/examples` into `pages/examples_matlab`, which
the in-repo build does not do at all.

Note also that `~/mtex/web/pages/` is a **stale** build. A page missing there
does not prove a missing target — always re-check against the source tree.

## What is still open

Items 1-10 and the 2026-08-10 pass below are closed except for:

- **Item 10** — deferred by decision on 2026-07-28, revisit much later. One of
  its entries (`SO3FunRBF/interpolate`) was fixed on 2026-08-06; the rest
  stand, minus the two whose *prose* was reworded on 2026-08-10 so the pages no
  longer read as unfinished (`interp(...,'bingham')` and the
  `SO3FunVectorField` quiver plot — the underlying questions are unchanged).
- **Twinning**, excluded by request on 2026-08-10: the `twinningSystem`
  dangling link, the empty `Misorientations/Twinning` chapter and the
  `Plasticity/TwinningTutorial` placeholder.
- **`EBSDGradient`**, still deliberately dangling — the page should be written
  against the non gridded gradient API that is in progress.
- **Four open questions** that no amount of editing can answer, left in place
  as `TODO` markers and listed in `TODO.md` C2: the (001)/(071) axes in
  `TiltAndTwistBoundaries.m`, the commented out Bingham test in
  `GrainOrientationParameters.m`, "deviation from an ellipse" in
  `EllipseBasedParameters.m`, and the "fibryness" measure in
  `Grain_dispersion_axes.m`.
- **`Plasticity/SachsModel`**, kept as an empty stub by decision on
  2026-08-10 even though `SingleSlipModel.m` covers the same physics.
- **Four content orphans** from item 6: `Dream3dGrains`, `S2FunQuadrature`,
  `MisorientationGrainExchangeSym`, `changelog`. `Contribute2Doc` is a fifth,
  prose only and reachable from the website.
- The `plotSection(mdf,'axisAngle')` **segfault** (item 6, in `TODO.md`) and
  the dead external links of `TODO.md` C5, including the `t.co` shortener on
  `HullBasedParameters.m:18`, which could not be resolved from this machine.

**Link status after the 2026-08-10 pass: 28 dangling instances, 26 of them
inside `changelog.m`.** The two live ones are `twinningSystem` and
`EBSDGradient`, both listed above. Re-derive with the recipe at the top of this
file rather than quoting older counts, which never added up.

## 2026-08-10 pass

A second sweep of the whole of `doc/`, driven by "scan doc/ for open ends and
fix those, except twinning systems". It closes items 2e and the sidebar orphans
of item 4, and most of the empty chapters of item 5.

**Links.** 19 live dangling instances resolved. Nine were smoothing filters
written as `taubinFilter.taubinFilter.html`; they live in
`EBSDAnalysis/BoundarySmoothing/`, not in an `@` folder, so the class prefix is
wrong — the same trap as `planarColorKey` in item 4. The rest:
`arrow3d`→`vector3d.arrow3d`, `S2FunBingham`→`S2Bingham` (the link wanted the
*doc page*, not the class), `calcCluster`→`mclComponents` (which is what the
code on that page actually calls), and `grainBoundary.componentSize`, an inline
dependent property that can never have a page, so the markup was dropped. The
four `grain3d.{equivalentSurface,shapeFactor,hasHole,isInclusion}` links in
`Grains3DProperties.m` pointed at methods that do not exist; by decision the
methods were *not* implemented and the table now lists them, together with
`caliper`, `equivalentRadius`, `equivalentPerimeter` and `isBoundary`, as
having no 3D counterpart yet. A `curvature` row on `grain3Boundary` went the
same way.

**Navigation.** Three 3D index pages (`EBSD3_index`, `grain3d_index`,
`grain3Boundary_index`) were wired into `EBSDAnalysis_index.toc`; all three
carried copy-pasted titles naming the 2D class. The two stale
`*DeLaValleePoussin_index` pages and `directionPlots_index` were deleted rather
than renamed — none was in a `.toc`, all had wrong titles, and no sibling
kernel has an index page.

The `PLEASE HELP AND ADD CONTENT HERE` heading was stripped from twelve
`TensorAnalysis/*_index.m` pages, where it published as a visible `<h2>`. While
there, 24 index page titles that were copy-paste duplicates were corrected —
eight `tools/*` pages all read "Statistics", four tensor pages read "Stress
Tensors", `parentGrainReconstructor_index` read "The Class EBSDsquare". The
`.toc` typo "Phase Transistion Analysis" was fixed.

**Duplicate pages removed.** `Plasticity/PlasticDeformation.m` and
`Plasticity/StrainAnalysis.m` were orphaned older variants of `SchmidtFactor.m`
and `SlipTransmission.m`, both already in the TOC and both longer; deleted.
`Rotations/RotationImport.m`, `Rotations/RotationExport.m` and
`Tutorials/ImportFromVPSC.m` were empty stubs duplicating
`CrystalOrientations/OrientationImport`, `OrientationExport` and
`Plasticity/VPSCImport`; deleted and their TOC entries repointed. The
"Texture evolution during rolling" section of `TaylorModel.m` moved into the
new `TextureEvolution` chapter. `Plasticity/Lankford.m` got a TOC slot.

**Chapters written** — eight, each run headlessly before committing:
`GeneralConcepts/Properties`, `Grains/GrainExport`,
`Misorientations/AngleDistributionFunction`,
`Misorientations/AxisDistributionFunction`, `Plasticity/TextureEvolution`,
`Plotting/PlottingExport`, `PoleFigureAnalysis/PoleFigureExport`,
`SphericalFunctions/S2FunRadon`. `GrainBoundaries/QuadruplePoints.m`, until now
an untitled scratch script in no TOC, was turned into a page and wired in — it
is the only documentation of `calcGrains(...,'removeQuadruplePoints')`.

**Prose TODO markers**: 15 of 19 resolved (the four open questions above are
the remainder). The substantial ones were the shear modulus definition in
`AnisotropicTheory.m`, the default `X||a*, Z||c` alignment in
`SymmetryAlignment.m`, the `'interp'` versus `'density'` distinction and the
halfwidth in `ODFImport.m`, the VPSC section of `ODFExport.m`, the other Euler
section types in `EulerAngleSections.m`, a non-ODF example in
`SO3FunHarmonicRepresentation.m`, and full rewrites of `FundamentalSector.m`,
`TensorVisualisation.m` and `FibreODFs.m`.

### Code defects found on the way

Two were fixed because a doc page could not otherwise call a documented syntax:

- **`geometry/@symmetry/calcAxisDistribution.m:21`** did
  `if isa(varargin{1},'symmetry')` with no emptiness guard, so
  `calcAxisDistribution(cs)` — the second syntax in the function's own help —
  always threw "Index exceeds array bounds". Guarded.
- **`geometry/@orientation/bingham_test.m`** indexed `lambda` and `kappa` as
  columns (`kappa(2:4,:)`) while `mean(ori)` returns them as rows, so every
  call threw. Now flattened with `(:)`. **The function runs again but its
  output convention is unverified** — on data drawn from a spherical Bingham it
  returns 1.0 for the spherical test, which does not obviously match either
  reading of the statistic. It has no callers outside `templates/`. Do not
  document it until someone checks the sign convention.

Five more were measured and left alone:

- **`calcDensity` on an empty orientation list** dies with "Too many input
  arguments". `geometry/@orientation/calcKernelODF.m:41` handles the empty case
  with `odf = ODF(ori.CS,ori.SS)`, and `ODF` is an obsolete shim that no longer
  takes those arguments.
- **`calcPoleFigure(odf,pf.allH,pf.allR)`** — the obvious way to recompute a
  measured set of pole figures — throws "Number of elements must not change"
  whenever one entry of `allH` holds several Miller indices, i.e. for superposed
  pole figures. The default structure coefficients are one per *pole figure*,
  not one per Miller index. Workaround, used in `PoleFigureExport.m`: pass
  `'superposition',pf.c` explicitly.
- **`stiffnessTensor.rand` returns a plain `tensor` of rank 2.** The static
  `TensorAnalysis/@tensor/rand.m` hardcodes `T = tensor(...)`, and MATLAB gives
  a static method no way to learn which subclass it was called on. So
  `C = stiffnessTensor.rand; C.PoissonRatio(...)` fails with "Unrecognized
  method". The old `TensorVisualisation.m` used exactly this and was silently
  plotting a random rank 2 tensor while claiming to show a rank 4 one. A real
  fix needs a one line `rand.m` in each subclass.
- **`export(odf,fname,'VPSC')` silently writes a generic file.** `SO3Fun/export`
  reads the format from `get_option(varargin,'interface','generic')`, so a bare
  `'VPSC'` flag is ignored. `ODFExport.m` had this call under a `TODO!!!`
  marker; it now uses `'interface','VPSC'` and says why.
- **A new property needs `ebsd.prop.name = ...`, not `ebsd.name = ...`**, and
  no length check is performed — a too short property is accepted and only
  fails later on indexing. Both are documented in the new `Properties` chapter
  rather than changed.

## Closed

- **Kernel page links** (commit `c6b50f7a4`) — 12 links in `SO3Kernels.m` /
  `S2Kernels.m` used the doc page name as class prefix; plus `SO3Fun`,
  `SO3FunRBF` and `calcGBND` in the same two pages, which needed the opposite
  correction.
- **Malformed links whose target exists** (commit `a52cfd0bb`) — 10 links
  across 7 pages: `SO3FunHarmonic`, `SO3FunRBF`×2, `variants`×2,
  `calcVariants`, `caliper`, `fibonacciS2Grid`, `strainTensor`,
  `plottingConvention`.
- **`S2Kernels.m` intro list** (commit `1aff4c567`) — two bullets named
  kernels that do not exist for S2 (Abel Poisson, von Mises), one of them
  mangled markup that rendered literally; replaced by the restricted distance
  kernel, which does exist and was missing. Note the audit's claim that
  `@ClassName` is not link syntax was wrong: `globalReplacements.m` auto-links
  it, and the published page shows the other four bullets resolving fine.
  `S2Kernels.m` now has no dangling links.
- **Deprecated `hold all`** (commit `65c7f5a42`) — 4 executable calls plus the
  2 prose passages recommending it.
- **Misspelled `doc/PhaseTransitions/`** (commit `e0da26ef0`) — renamed; a
  pure rename, published page names come from file basenames.
- **`calcTensor` density residuals** (commit `0d51b358b`) — the `isfield` test
  ran against whichever `T` the phase loop ended with, and a density-less
  tensor left NaNs in the average. Now a per-phase `hasDensity` flag; the
  field is either a meaningful average or absent.
- **`tests/checkMeanTensor.m`** (commit `f120d7f21`) — no longer calls the
  abstract `symmetry` constructor. Runs now; still stops at its rank 3
  quadrature assert, see item 9.
- **Uncommitted 2026-07-28 execution fixes** (commit `b6da890ce`) —
  `CPOSeismicProperties.m`, `GrainReconstructionAdvanced.m`,
  `GrainReconstructionOld.m` were repaired during the sweep but never
  committed.
- **Plotting an empty grain boundary** — see item 7.
- **`SelectingGrains.m` mouse click** (commit `c0eafd55c`) — `simulateClick`
  needs input-injection permission from the window system and takes the page
  down when that is refused or slow; it also places the click by converting
  data coordinates to screen pixels, so the grain it hits depends on the build
  machine. Click kept but guarded, with a fallback selecting the grain at the
  same position. `EulerCycles2.m`, unreferenced since the merge, deleted in
  `7dc118cb5`.

## 1. Closed: links to real API that `makeDoc` gave no page (15 instances)

Two premises in the original write-up were wrong and are worth recording,
because they would send the next reader down the wrong path:

- **`makeDoc` needed no extending.** `rotation.byEuler`, `byMatrix`,
  `byRodrigues` are *also* declared in the classdef body and do get pages —
  because their bodies live in separate `@rotation/*.m` files. Only methods
  *implemented inline* in the classdef body have no page. The DocHelp toolbox
  is a separate repo (`~/mtex/makeDoc`) and was never the problem.
- **`grainBoundary.length` is not a misspelling of `segLength`.** The sentence
  at `BoundaryProperties.m:125` deliberately contrasts the two — `length` is
  the segment *count*, `segLength` the segment *lengths* — and links both.

### 1a. Resolved by splitting inline bodies into their own `.m` files

Each method moved out of its classdef body into `@Class/name.m`, with a help
block, so `makeDoc` now emits its page. Behaviour is unchanged; the doc pages
needed no edit at all, since the links were already spelled
`rotation.rand.html` etc. and simply had no target.

| new file | publishes as | was inline in |
|---|---|---|
| `geometry/@rotation/nan.m` | `rotation.nan.html` | `rotation.m:98` |
| `geometry/@rotation/id.m` | `rotation.id.html` | `rotation.m:102` |
| `geometry/@rotation/rand.m` (×2 links) | `rotation.rand.html` | `rotation.m:106` |
| `geometry/@rotation/inversion.m` | `rotation.inversion.html` | `rotation.m:110` |
| `TensorAnalysis/@tensor/rand.m` | `tensor.rand.html` | `tensor.m:236` |
| `EBSDAnalysis/@EBSDhex/hex2cube.m` | `EBSDhex.hex2cube.html` | `EBSDhex.m:202` |
| `EBSDAnalysis/@EBSDhex/cube2hex.m` | `EBSDhex.cube2hex.html` | `EBSDhex.m:223` |

`EBSDhex.cube2hex` was missed by the audit — it is cited on the same line as
`hex2cube` in `doc/EBSDAnalysis/EBSDIndex.m:111`.

The one recursion hazard, `rand(d)` inside `@tensor/rand.m` resolving to the
method rather than the builtin, does not occur: dispatch is on the argument
class, and `d` is a double. Verified.

`SO3Fun.eval` could not be handled this way — it is an `Abstract` declaration
(`SO3Fun/@SO3Fun/SO3Fun.m:46`), so no implementation file can exist. Retargeted
to `SO3FunHandle.eval.html`, which is the class actually in play at
`SO3FunConcept.m:36`.

`tensor.nan`, `tensor.eye`, `tensor.zeros` and `tensor.ones` are still inline
in the `@tensor` static block. Nothing links to them, so they were left alone —
but the block is now mixed, and splitting them out too would make it uniform.

### 1b. Resolved by retargeting to the base class

`makeDoc` emits no page for inherited methods, so the base-class page is the
only target that can resolve. Link *text* was left as written, so the reader
still reads `calcDensity`; only the href changed.

| link | retargeted to | at |
|---|---|---|
| `orientation.calcDensity` (×2) | `rotation.calcDensity` | `MDFAnalysis.m:36`, `ODFTutorial.m:31` |
| `orientation.std` | `quaternion.std` | `MartensiteVariants.m:55` |
| `orientation.discreteSample` | `SO3Fun.discreteSample` | `OptimalKernel.m:46` |
| `orientation.calcAxisDistribution` | `SO3Fun.calcAxisDistribution` | `MDFAnalysis.m:141` |

`grainBoundary.length` got a new `EBSDAnalysis/@grainBoundary/length.m` — a
documented `l = size(gB,1)` overload, mirroring the existing
`@quaternion/length.m`, which does get a page. Value is unchanged from the
builtin fallback (3219 on `twins`, verified).

The three `grain3d` links (`hasHole`, `isInclusion`, `shapeFactor`) do **not**
belong here: they exist nowhere on `grain3d` in any form and the table rows say
"TODO". Moved to item 2.

Verified by `tests/check_methodFiles.m` (new) plus `check_mtex`, and by running
`EBSDIndex.m`, `RotationDefinition.m`, `TensorDefinition.m`,
`TensorArithmetics.m` and `BoundaryProperties.m` clean.

Also fixed in passing: `mtex-include:32` still named the pre-rename
`doc/PhaseTransistions`. Four further stale include paths remain in that file
(`EBSDAnalysis/FMC`, `ODFAnalysis/standardODFs`,
`doc/FunctionReference/ODFAnalysis`, `tools/kernelFunctions`) — unrelated rot,
consumed only by `compile-mtex`, left alone. The
`doc/PhaseTransistions` warning MATLAB prints at startup on this machine comes
from `/opt/matlab-2024b/toolbox/local/pathdef.m`, a saved path, not the repo.

## 2. Closed: links to API that does not exist anywhere

Half of this item was misdiagnosed — five of the ten links had perfectly good
targets, and one of them was not in the audit at all.

### 2a. Not missing after all — retargeted

| link | reality | now points at |
|---|---|---|
| `rotation.byQuaternion` | the link text is literally `rotation(quat)`, i.e. the **constructor** | `rotation.rotation.html` |
| `rotation.mirroring` | `geometry/geometry_tools/reflection.m` **is** this operation, returning an improper rotation | `reflection.html`, link text corrected to `reflection` |
| `EBSD.export_cpr` | `export_crc` exists and the link text already said "cpr/crc" | `EBSD.export_crc.html` |

### 2b. Existed, but inline in a classdef body (the item 1a pattern)

`orientation.cube` (`@orientation/orientation.m:123`) and `orientation.goss`
(`:139`) both exist. `orientation.goss` was **not** in the audit's list.

Decision: **remove the link markup**, not split the files. The `@orientation`
static block holds 35 inline methods — 4 constructors, ~20 named texture
components and ~11 orientation relationships (Bain, KurdjumovSachs,
NishiyamaWassermann, Pitsch, Burgers, ...) — and splitting two of them would
be arbitrary. `OrientationFibre.m:7` now reads "the |cube| and the |goss|
orientation" as plain text.

`tensor.eye` is a third instance of this pattern, found by the sweep below and
still dangling.

### 2c. Genuinely missing — implemented

`rotation.byHomochoric` now exists as `geometry/@rotation/byHomochoric.m`, the
inverse of `quaternion/homochoric.m`. Recovering $\omega$ from
$\rho = (\frac34(\omega-\sin\omega))^{1/3}$ has no closed form, so it is a
Newton iteration started at $\omega \approx 2\rho$ (exact to $O(\rho^5)$).

Two numerical points worth keeping:

- `omega - sin(omega)` and `1 - cos(omega)` both cancel catastrophically near
  $\omega = 0$. The derivative is written `1.5*sin(omega/2).^2` and the
  residual switches to a four-term series below $\omega = 0.1$.
- $\rho = 0$ leaves the axis undefined; without a guard the identity came back
  as `NaN`.

**Do not measure this with `angle()`.** `angle(rot,rot)` — a rotation against
itself — already reports up to `6e-8`, because it goes through `acos` near 1.
Measured by quaternion distance the roundtrip is `1.3e-15`; by `angle` it looks
like `6e-8`. Likewise, small-angle accuracy has to be read off
`2*asin(|vector part|)`, since `homochoric` itself recovers $\omega$ through
`acos(cos(omega/2))` and has lost every digit by $\omega = 10^{-7}$.
Covered by `tests/check_homochoric.m`.

### 2d. Genuinely missing — deliberately left dangling

Decided 2026-07-28: keep the doc pages as they are and record the functions as
work to do, in `TODO.md`. The dangling links act as the reminder.

- `twinningSystem` (`DefinitionAsCoordinateTransform.m:71`) — noted under
  "Major / twinning class" in `TODO.md`.
- `grain3d.equivalentSurface`, `.shapeFactor`, `.hasHole`, `.isInclusion`
  (`Grains3DProperties.m:10-12`) — noted under "EBSD3d / Grain3d". `grain2d`
  has all four.

## 2e. New: the link inventory is materially incomplete

Sweeping **all** class-qualified links in `doc/**/*.m` against the generated
page set turned up 17 dangling targets that appear nowhere in this plan. The
audit's "48 instances / 44 targets" therefore understates the problem.

Caveat on method: `~/mtex/web/pages/` is a **stale** build, so a missing page
there does not prove a missing target. Everything below was re-checked against
the source tree, which is the reliable signal.

Exists in source, page simply not rebuilt (no action needed):
`EBSD.calcGrains`, `EBSD.lattice`, `EBSD.transform`, `EBSDsquare.interp`,
`SO3Fun.optimalSample`, `gbcFMC.gbcFMC`.

Wrong case in the link, target exists:
`ebsd.calcGrains.html` → `EBSD.calcGrains.html`,
`EBSDSquare.interp.html` → `EBSDsquare.interp.html`.

Inline in a classdef body, i.e. the item 1a pattern: `tensor.eye`.

No such method or class found anywhere — each needs the item 2 treatment:
`BinghamS2.BinghamS2`, `BinghamS2.fit` (confirmed: renamed to `S2FunBingham`, see item 4),
`EBSD.calcMis2Mean`, `EBSD.erode`, `EBSD.transform2PolarReferenceFrame`,
`grain2d.neighbours`, `grain2d.numNeighbours` (British spelling; `neighbors` /
`numNeighbors` exist), `grain2d.surfor`, `grainBoundary.componentSize`,
`orientation.calcLankford`, `stiffnessTensor.plotWaveVelocities`.

Note several of these sit in files with uncommitted working-tree edits
(`EBSDGrid.m`, `ClusterDemo.m`), so they may be in-flight rather than rotted.

## 3. Closed: referenced doc pages that were never written

Only two of the five were real authoring gaps. Three had existing targets under
a different name — and one of those targets is not in this repo at all.

| page | outcome |
|---|---|
| `SO3FunVisualization` | retargeted to `ODFPlot.html`, which `SO3Functions.toc` already lists under the label "Plotting" in that very section |
| `ParentGrainReconstruction` | retargeted to `MaParentGrainReconstruction.html` ("Parent Austenite Reconstruction"), which discusses `calcVariants` in detail at line 231 |
| `IceSphericity` | retargeted to `ExIceSphericity.html` — simply a misnamed link |
| `RotationRepresentations` | **written**, see below |
| `EBSDGradient` | left untouched on purpose, see below |

### `IceSphericity` — the target lives outside this repo

`ExIceSphericity.m` is in `~/mtex/examples/ExGrains/`, a **sibling tree**, not
in `mtex/doc`. The website build (`web/matlab/makeDoc.m:158`) publishes it from
`mtex_path/../examples` into `pages/examples_matlab/`, a different output
directory from `pages/documentation_matlab/`. The in-repo
`doc/makeDoc/makeDoc.m` does not build examples at all, so this link resolves
on the website and not in the local MATLAB help — the same split as item 4.

A bare `<ExIceSphericity.html ...>` is nonetheless the right form: example
pages already link to reference pages the same way across directories (e.g.
`ExIceSphericity.html` itself links to `grain2d.area.html`).

Note the page defines sphericity as $\Psi = A/(P\cdot R)$ but MTEX has **no**
`grain2d.sphericity` method — the example computes it inline. The
`ShapeParameters.m` table row therefore still advertises a property that does
not exist, which is a separate matter from the link.

### `RotationRepresentations` — written

`doc/Rotations/RotationRepresentations.m`, plus a TOC slot after
`RotationDefinition` in `Rotations.toc`. It compares the three 3D-vector
representations MTEX offers, all of the form $\vec v = f(\omega)\,\vec n$:

| | $f(\omega)$ | region | equal volume |
|---|---|---|---|
| Rodrigues | $\tan(\omega/2)$ | unbounded | no |
| homochoric | $(\frac34(\omega-\sin\omega))^{1/3}$ | ball, radius $(3\pi/4)^{1/3}$ | yes |
| cubochoric | — | cube, edge $\pi^{2/3}$ | yes |

Verified numerically while writing it: Rodrigues norms reach ~1e4 over 2000
random rotations, the homochoric radius maxes at 1.3306 against
$(3\pi/4)^{1/3} = 1.3307$, and the cubochoric half-edge at 1.0724 against
$\pi^{2/3}/2 = 1.0725$. The page also shows the equal-volume property directly,
by matching the homochoric radial histogram against $3r^2/R^3$.

There is no `rotation.byCubochoric`; the page composes the inverse as
`rotation.byHomochoric(cubo2homo(...))`, which roundtrips to 2.1e-15.

The link to `angle` had to go to `quaternion.angle.html` — `@rotation` has no
`angle.m`, the same base-class situation as item 1b.

### `EBSDGradient` — deferred, not dropped

The claim on `EBSDGrid.m:14` is correct: gradient computation really is a
gridded-only feature today, exposed as the `gradientX` dependent property on
`@EBSDsquare` and `@EBSDhex`. Decided 2026-07-28 to leave the dangling link
alone, because a feature branch is in progress that computes the gradient for
arbitrary (non-gridded) EBSD maps; the page should be written against that API,
not the current one.

## 4. Closed: `makeDoc` omitted SO3Fun and S1Fun

Fixed in both builds, and the omission was one folder wider than recorded:

- `doc/makeDoc/makeDoc.m` (this repo) omitted **both** `SO3Fun` and `S1Fun`.
  Both added. `DocFile` picks up 363 and 73 files respectively, so the local
  MATLAB help gains ~436 reference pages that previously did not exist.
- `web/matlab/makeDoc.m` (the separate `~/mtex/web` repo) already had `SO3Fun`
  but omitted `S1Fun`. Added there too — **left uncommitted**, since it is a
  different repository.

Consequence of the `S1Fun` gap: it was the only case where a class had no
reference page in *either* build, so `@S1Fun` and `@S1FunHarmonic` in prose
dangled everywhere, cited from `doc/Grains/EllipseBasedParameters.m` and
`doc/SphericalFunctions/S1FunHarmonics.m`.

### The `@ClassName` auto-link category, swept for the first time

The earlier sweeps only looked at explicit `<X.Y.html>` links. `@Name` in prose
is auto-linked by `~/mtex/makeDoc/@DocFile/private/globalReplacements.m`, which
resolves `which(Name)` and then decides:

- name occurs **more than once** in the path → `<Name.Name.html>` (a classdef
  in an `@Name` folder);
- occurs once and the path contains `mtex` → `<Name.html>`;
- otherwise no link at all, the text stays literal `@Name`.

Reproducing that rule over all of `doc/` gives 111 distinct `@names` and only
four dangling targets — a much cleaner category than the explicit links.
`S1Fun` and `S1FunHarmonic` are fixed by the above. `gbcFMC` is a stale-build
artifact (it lives under `EBSDAnalysis`, already built). The fourth is a
genuine defect in the heuristic:

**`planarColorKey` can never resolve.** It lives at
`plotting/planarColorKeys/planarColorKey.m` — not a class folder — so its page
is `planarColorKey.html`. But the *folder* name contains the file name, so the
occurrence count is 2 and the rule emits `planarColorKey.planarColorKey.html`.
Decided 2026-07-28 to record rather than fix: the correct test is "a path
component equal to `@` + name", but that lives in a third repo and today the
only citation is in `changelog.m` (archive). Any file whose parent folder name
contains its own basename hits this.

### Navigation: the sidebar is a separate mechanism

Adding the folders creates the reference *pages*; the sidebar entries under
`doc/FunctionReference/` are separate — one `Name_index.m` file holding nothing
but a `%% Name` title, listed in a `.toc`. The generated `*_index.html` really
is just that title; the method listing comes from the sidebar built by
`makeHelpToc`, not from the page.

Both gaps found here are now **fixed**:

- **`S1Fun` had no index at all.** Added `S1Fun_index.m`, `S1FunHandle_index.m`
  and `S1FunHarmonic_index.m` to `SphericalFunctions_index/`, appended to its
  `.toc` after `S2Kernel_index`. Placing them under "Spherical Functions"
  rather than in a new top-level section follows the documentation side, where
  `SphericalFunctions.toc` already ends with `S1FunHarmonics  Fourier Series`.
- **`BinghamS2_index.m` was stale.** The class is now `S2FunBingham`
  (`S2Fun/@S2FunBingham/`); `BinghamS2` exists nowhere in the source. Renamed
  to `S2FunBingham_index.m` (via `git mv`) and the `.toc` entry updated. This
  is the confirmed origin of the `BinghamS2.*` targets in item 2e, whose only
  doc citations are `changelog.m:812-813`, i.e. archive.

Fixed in passing: `SphericalFunctions_index.m` was titled **"The Spherical de
la Vallee Poussin Kernel"** — a copy-paste from the neighbouring
`S2DeLaValleePoussin_index.m`. Every sibling section page carries its section
name ("Orientation Dependent Functions", "Geometry Related Classes", "EBSD
Analysis"), and both `FunctionReference.toc:5` and the documentation landing
page say "Spherical Functions", so that is what it now reads.

### Open: four more sidebar orphans, same family

Sweeping every `doc/FunctionReference/**/*.toc` in **both** directions — broken
entries and unlisted files — turns up index pages that exist but appear in no
`.toc`, so they are unreachable:

| orphan | source class | note |
|---|---|---|
| `EBSDAnalysis/EBSD3_index` | `@EBSD3` exists | `EBSDAnalysis_index.toc` lists 2D classes only |
| `EBSDAnalysis/grain3d_index` | `@grain3d` exists | ditto |
| `EBSDAnalysis/grain3Boundary_index` | `@grain3Boundary` exists | ditto |
| `SphericalFunctions_index/S2DeLaValleePoussin_index` | source is `S2DeLaValleePoussinKernel.m` | stale name, same pattern as `BinghamS2` |
| `SO3Functions_index/SO3DeLaValleePoussin_index` | source is `SO3DeLaValleePoussinKernel.m` | ditto |
| `plotting/directionPlots_index` | **none** | no `directionPlots` anywhere in the source |

The 3D omission may well be deliberate while 3D support is in flux, hence left
as a decision rather than fixed.

**Checker note.** The *broken-entry* direction is full of false positives and a
naive script will report them: entries in `FunctionReference.toc` resolve to
pages one folder down (`geometry_index` →
`doc/FunctionReference/geometry/geometry_index.m`), `tools_index.toc` legitimately
references `dubna_tools_index` in the `PoleFigureAnalysis_index/` folder, and
`plotting_index.toc`'s `mapPlot`/`scaleBar`/`sphericalPlot` are classdefs in
`plotting/` whose pages come from the source tree. Cross-folder `.toc`
references are normal here. Only the orphan direction produced real findings.

## 5. Closed: title-only stub pages

Re-derived rather than taken on trust, and the count was **21, not 22** —
16 wired into a TOC plus 5 unreachable. Three corrections to the original list:

- **`PhaseTransitions/PhaseTransitions.m` is not a stub.** It is a *section
  landing page*, exactly like `Grains.m`, `Rotations.m`, `Tensors.m` and a
  dozen others: a title, with the `.toc` supplying the content. Counting it as
  a stub means counting every section landing page.
- **`Grains/GrainExport.m` is not a bare title** — it reads "TODO / Please help
  to fill this chapter". Three stubs carry such markers: it,
  `OrientationExport` and `TwinningTutorial`.
- **Two stubs had inbound links**, which the audit did not record and which
  decides whether they can be deleted at all:
  `CrystalOrientations/OrientationExport` ← `ODFAnalysis/RandomSampling.m:90`,
  and `CrystalOrientations/SpecimenSymmetry` ←
  `SO3Functions/SO3FunSymmetricFunctions.m:6`.

### Deleted (4 of the 5 unreachable ones)

`EBSDAnalysis/EBSDAxisAngleMaps.m`, `ODFAnalysis/DiscretizationError.m`,
`ODFAnalysis/ImportExportODFAnalysis.m` and the 0-byte
`doc/VectorsRotations/RotationsOperations.m` — the last taking the whole
`doc/VectorsRotations/` folder with it, which held nothing else and was
referenced nowhere. `Plasticity/TwinningTutorial.m` kept by decision, as its
TODO marker records an intent to write it.

### Written (the 2 reachable ones)

- **`CrystalOrientations/OrientationExport.m`** — the counterpart of the
  existing `OrientationImport.m`. Covers `quaternion/export` (Bunge by default,
  other conventions, `radians`, `quaternion`, and extra columns from a struct)
  and `orientation/export_VPSC` including its `weights` option.
- **`CrystalOrientations/SpecimenSymmetry.m`** — what specimen symmetry is and
  why it acts from the left, how to define one, the difference between `'1'`
  (1 element) and `'triclinic'` (= $\bar1$, 2 elements), and what imposing
  `'mmm'` does to an ODF. The texture index claim is measured, not asserted:
  27.8852 → 7.2683, and the page prints both.

Two things worth copying when writing further pages:

- **Do not write into `data/`.** `ODFExport.m` writes `odf.txt` and `odf.mtex`
  there, and both are **tracked**, so every doc build dirties the repo. The new
  page writes to `tempdir` and deletes afterwards.
- **`textureindex` is in `obsolete/`** and warns. The current spelling is
  `norm(odf)^2`.

### Remaining: 14 empty chapters, recorded in `TODO.md`

Decided 2026-07-28: leave them wired into their TOCs, since the empty sidebar
entry *is* the reminder, and track the list in `TODO.md` under "Documentation -
empty chapters". They are `Properties`, `GrainExport`,
`AngleDistributionFunction`, `AxisDistributionFunction`, `Twinning`,
`SachsModel`, `SlipTransmission`, `TextureEvolution`, `PlottingExport`,
`PoleFigureExport`, `RotationExport`, `RotationImport`, `S2FunRadon`,
`ImportFromVPSC`.

Not stubs, despite having no executable code — these are legitimate
prose-only pages: `EBSDExport`, `EBSDInterfaceHDF5`, `Contribute2Doc`,
`GeneralConceptsConfiguration`, `MisorientationGrainExchangeSym`.

Incidental: `crystalSymmetry('quartz')` — a bare mineral name — errors in
`crystalSymmetry.m:155`. No doc page uses that form (they all use
`crystalSymmetry.load('quartz.cif')`), so nothing is broken by it.

## 6. Closed: orphan pages

Re-derived: **15** orphans, not 16 (item 5's deletions removed three stubs).
Ten with real content, four zero-code, and one point worth keeping — several
orphans are **recently maintained**, last commits between 2026-07-08 and
2026-07-28, so they are live work rather than rot.

Not orphans, despite matching a naive check: `doc/Documentation.m` and
`doc/DocumentationMatlab.m` are the roots of the two TOC trees, named directly
in the `makeHelpToc` calls.

### Duplicate pairs where the empty page was the published one

- **`SlipTransmission`** — the 26 byte stub was in `Plasticity.toc` while the
  misspelled `SlipTransmition.m`, 3.6 kB of real content on the m' parameter
  (touched 2026-07-08), was orphaned. `git mv`'d the content over the stub; the
  existing TOC entry now resolves to it and the misspelling is gone.
- **`Vectors`** — `Vectors.toc` pointed at `VectorsDefinition.m` (1115 B, Apr
  2024) while the newer, better structured `VectorDefinition.m` (1530 B, May
  2025) was orphaned. TOC repointed, the old file deleted, and the newer
  page's copy-paste defect fixed: it did `v = vector3d(1,2,3)` and then claimed
  "coordinates (1,1,0)".
- **`MisorientationDistributionFunction`** — merged. The in-TOC page (724 B,
  "TODO: please help to extend") and the orphaned `MDFAnalysis.m` (3.7 kB,
  "TODO: please help to redo") were both titled "Misorientation Distribution
  Function". Consolidated into the in-TOC page, `MDFAnalysis.m` deleted, the
  dead `%% SUB:` markup and the empty `%%` blocks dropped. No inbound links
  pointed at any of these six files, so no link repair was needed.

### Given a TOC slot (all verified to run first)

`BoundaryMisorientations` → `GrainBoundaries.toc`, `Grain_dispersion_axes` and
`GrainReconstructionOld` → `Grains.toc`, `DislocationSystems` →
`Plasticity.toc`, `BoundaryTutorial` → `Tutorials.toc`.

### A segfault found by merging the MDF pages

`plotSection(mdf,'axisAngle')` **crashes MATLAB** — a segmentation violation,
not a catchable error. It needs both a cross-phase misorientation (differing
left and right symmetry) *and* bandwidth ≥ 32:

    mdf = calcDensity(grains.boundary('Fo','En').misorientation,'halfwidth',5*degree);
    mdf.bandwidth = 25;  plotSection(mdf,'axisAngle')   % fine
    mdf.bandwidth = 32;  plotSection(mdf,'axisAngle')   % segmentation violation

Same-phase MDFs (`CS == SS`) are fine at bandwidth 25, 32 and 48, and
`plotPDF` is fine on the crashing object, so it is specific to the axis-angle
sections. Recorded in `TODO.md` under Fixes. The merged page shows the
axis-angle sections of a same-phase MDF instead.

This is why the five pages above were run *before* being wired into a TOC:
`calcDensity` on a cross-phase boundary misorientation is a completely routine
thing for a doc page to do.

### Still orphaned, decided later

`Grains/Dream3dGrains.m` (296 B, 2024-02-23, no title at all — its first line
is a bare `%%`), `SphericalFunctions/S2FunQuadrature.m` (92 B, 2020-03-30,
title misspelled "Qudarature"), `Misorientations/MisorientationGrainExchangeSym.m`
(298 B, 2019-10-23, prose only) and `GeneralConcepts/changelog.m`. The last is
in no `.toc` and has no inbound link, yet publishes as `changelog.html` on the
website — presumably reached through the site's own navigation rather than
through `makeDoc`, so it should not be treated as dead.

## 7. Closed: plotting an empty grain boundary

Originally reported as `EulerCycles2.m:16` "Sparse matrix sizes must be
nonnegative integer scalars" via `doc/Grains/SelectingGrains.m:48`. The real
condition was an **empty** boundary, not a subset one — `max(FF(:))` is `[]`
for empty `F` and `sparse` rejects an empty size, while the `isempty(F)` guard
sat three lines below the `sparse` call it was meant to protect.

Resolved by merging `feature/orderedBoundary` (commit `8309d0a79`), which
rewrote `plotOrdered2` to use the stored walk order directly instead of
rediscovering connectivity with an Euler cycle walk. **`EulerCycles2.m` now
has no callers anywhere** and is dead code — a candidate for deletion.

One follow-on remained after the merge and is fixed in `eef2e2820`: with
nothing drawn, `h` is a 1x0 `GraphicsPlaceholder` and
`h(1).Annotation.LegendInformation` in `@grainBoundary/plot.m` errored. Now
guarded.

Verified after the merge: 6 empty-boundary variants (ordered, smooth,
DisplayName, colour data, simple, simple+colour) and 7 non-empty regression
variants all pass; `check_mtex`, `check_calcGrainsCases`,
`check_boundaryChains` and `check_chainOrder` pass; and
`BoundaryProperties.m`, `TiltAndTwistBoundaries.m`, `TriplePoints.m`,
`GrainReconstruction.m`, `BoundaryMisorientations.m` all run clean.

**`SelectingGrains.m` is flaky, not broken.** It picks its grain with
`simulateClick(9000,3500)`, which headless lands on a different grain each run
(observed 22, 20, 15, 15, 15 — all clean) or misses entirely. When it misses,
`grains([]).meanOrientation` carries a default triclinic CS matching no entry
in `CSList`, so `@grain2d/findByOrientation.m:22` takes its
`if isempty(phaseId), grains = []; return` branch and returns a raw double;
line 73 then dies with "Dot indexing is not supported for variables of this
type". That early return arguably should produce an empty `grain2d` rather
than `[]` — separate, pre-existing, not caused by the merge.

## 8. Closed: the sim / ensureCS lattice tolerance gap

Two tolerances answer the same question — "are these two crystalSymmetries the
same crystal?" — an order of magnitude apart:

- `geometry/phaseItem.m:130` (`simPair`, used by `sim`) requires the same
  mineral name, the same Laue id, and `all(abs(abc1-abc2)/max(abc1) < 1e-2)`
  → **1 %** on lattice parameters.
- `geometry/@symmetry/ensureCS.m:22` transforms automatically when
  `csNew.id == csOld.id && norm(MM-eye(3))/norm(MM) < 1e-1` → **10 %**.

**Correction to the original entry: `sim` has exactly one caller in the whole
codebase**, `EBSDAnalysis/@EBSD/calcTensor.m:43`. The concern that changing it
would "change phase-matching semantics everywhere `sim` is used" was
unfounded — there is nowhere else.

Measured on the Diopside case (`mtexdata forsterite` vs the Isaak et al. cell):

| | a | b | c |
|---|---|---|---|
| published | 9.585 | 8.776 | 5.260 |
| measured | 9.746 | 8.990 | 5.251 |
| relative deviation | 1.68 % | **2.23 %** | 0.09 % |

so `simPair` rejects, while `ensureCS`'s own metric gives 0.047 against its
0.1 threshold and would transform happily.

**Decided 2026-07-28: keep the 1 % semantics, fix the error message.** The
tolerance is a deliberate guard, and `CPOSeismicProperties.m` already teaches
the correct remedy. What was wrong was the diagnosis: a near miss on the
lattice parameters reported as `Missing tensor for phase: Diopside`, which
reads as "you forgot to pass a tensor". `calcTensor` now detects the near miss
— same mineral, same Laue group, lattice out of tolerance — and prints both
cells, the deviation, the thresholds, and the `transformReferenceFrame` call
that fixes it. A genuinely absent tensor still gives the short message.

### Fixed alongside: the `specimenSymmetry` self-comparison

`geometry/@specimenSymmetry/specimenSymmetry.m` compared `obj1` against
**itself** — `obj1.Laue.id == obj1.Laue.id` — so any two specimen symmetries
counted as equal. The typo appeared **twice**, in `sim` (line 79) and in
`eqTol` (line 69); only the first was in the original note.

`eqTol` is the one that mattered. `SO3Fun/@SO3Fun/ensureCompatibleSymmetries.m:54`
guards SO3Fun arithmetic with `~eqTol(SO3F1.CS, SO3F2.CS) || ~eqTol(SO3F1.SS,
SO3F2.SS)`, so the specimen-symmetry half of that guard was a **no-op**:
adding, subtracting or multiplying two SO3Funs with different specimen
symmetries was silently accepted, yielding a result carrying whichever `SS`
came first. That contradicts the explicit intent in the file ("Currently only
same symmetries are suitable"). It is now rejected.

The `crystalSymmetry` path is untouched — the base `eqTolPair` in
`phaseItem.m:154` always had `obj1.Laue.id == obj2.Laue.id` correctly; the
`specimenSymmetry` override was the outlier.

Verified: ten specimen-symmetry-sensitive doc pages still run
(`DetectionOfSampleSymmetry`, `SO3FunSymmetricFunctions`, `SpecimenSymmetry`,
`ODFModeling`, `ODFComponents`, `SO3FunOperations`, `SO3FunDefinition`,
`TransformationTexture`, `ODFTheory`, `OrientationSymmetry`), and `check_mtex`,
`checkMeanTensor`, `check_explog`, `check_embedding`, `check_methodFiles`,
`check_homochoric` pass. Four tests fail both with and without the change
(`check_FourierODF` needs interactive input, `check_SO3FunRotate` is a "not
implemented yet" stub, `check_equidistribution` and `check_fundamentalRegion`
error on their own arguments) — pre-existing, confirmed by re-running against a
stashed baseline. New regression test: `tests/check_symmetryCompare.m`.

## 9. Closed: checkMeanTensor's quadrature assert

The measured table is confirmed, but the **diagnosis in the original entry was
wrong**. Deviation of `calcTensor(odf,T,...)` from `rotate(T,o)`:

| halfwidth | Fourier | quadrature |
|---|---|---|
| 0.5° | 0.00039 | 0.02748 |
| 1.0° | 0.00157 | 0.00833 |
| 2.0° | 0.00627 | 0.00624 |
| 4.0° | 0.02487 | 0.02475 |

At 2° the two methods **agree** (0.00627 vs 0.00624). That residual is not a
quadrature error at all — it is the intrinsic difference between an ODF average
of finite width and a delta function. **No method can meet 2e-3 against
`rotate(T,o)` at a 2° halfwidth**, so the assert was mis-specified rather than
detecting a defect. The Fourier assert on the line above passes only because it
uses a 1° halfwidth, not because Fourier is better.

The assert now compares the two code paths against each other, which is what it
was presumably meant to test: `mean|quadrature − Fourier| < 1e-3`, measured at
6.0e-5.

Quadrature accuracy for sharp ODFs is a separate, real limitation:
`SO3Fun/@SO3Fun/calcTensor.m:34` builds its grid with a fixed default
`resolution` of 2.5°, so it cannot resolve a sharper peak — `|quad − Fourier|`
is 6.0e-5 at 2° but 8.1e-3 at 1°. Scaling the resolution with the halfwidth is
possible via the existing `'resolution'` option but expensive: the triclinic
SO(3) grid holds 950k points at 2.5°, 4.4M at 1.5° and 14.9M at 1°.

**`tests/checkMeanTensor.m` now passes end to end for the first time.** Fixing
the assert exposed the abandoned scratch block at the end of the file
(`ebsd_corrected`, `C_Epidote`, `odf_Epidote`, `CS`, `SS`, `C_Glaucophane` —
none ever defined), which had been unreachable behind the failing assert. It
was removed, with a pointer to git history in its place.

## 10. Deferred (decided 2026-07-28: revisit much later)

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
- ~~**`SO3FunRBF/private/spatialMethod.m:37`** — `doc/PoleFigureAnalysis/
  PoleFigureRefinement.m:21` calls `calcODFIterative(pf,'nothinning')` and
  dies at `y = reshape(y,numel(nodes),[])` with "Product of known dimensions,
  78, not divisible into total number of elements, 3", via
  `calcODFIterative:92` → `SO3FunRBF/interpolate.m:105`.~~ **Fixed
  2026-08-06** in `SO3FunRBF/interpolate.m`: the values arrive shaped like the
  evaluation grid (`SO3Fun/eval` returns `size(nodes)`, e.g. 3 x 26 for an
  `equispacedSO3Grid`), so `for index = 1:size(y,2)` sliced columns of the
  grid instead of function components. `interpolate` now flattens `y` to
  `numel(nodes) x []` first. `PoleFigureRefinement.m` runs end to end and
  `calcODFIterative` beats plain `calcODF` on dubna (RP 0.17-0.32 vs
  0.26-0.44) with the grid growing 78 -> 205 -> 1170 -> 4605 -> 19848.
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
