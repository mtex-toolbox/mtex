# MTEX — TODO

Consolidated 2026-08-09, at the `mtex-7.0.beta.1` mark. This replaces the
free-form list that had grown two copies of half its headings.

Four sources were merged: the previous `TODO.md`, all **117 open GitHub
issues**, the still-open items of `docs/doc-audit-plan.md`, and the paused
investigation backlogs from agent sessions. Every open issue number appears
in exactly one row, so this file is also the issue triage map — recurring
issues were folded into the theme they belong to rather than kept as
individual entries.

Rows that carry a real reproduction, a measurement or a decision to be made
link to [Details](#details) at the bottom. Nothing was dropped for brevity;
items believed finished were removed only when the code confirms it.

Updated 2026-08-11: T3, C17 and C20 fixed, E11 and D13 found to be already
done, O1 and O2 could not be reproduced. Two new rows, O28 and T7, come out
of that pass.

Updated 2026-08-12: O12, C19, F5 and L12 fixed, each with a check script.
G10 could not be confirmed as a defect. A second pass the same day fixed O8,
O9, C18 and G35; O8 turned out to have a second half, two implementations
ignoring `'bandwidth'` once it reached them.

## Legend

**U — urgency**

| | |
|---|---|
| `3` | must happen now — release blocker, silent wrong result, or a crash on a path people use daily |
| `2` | next release — real defect or visibly half-finished feature, but there is a workaround |
| `1` | wanted, no deadline |
| `0` | someday, or speculative |

**Sz — size**

| | |
|---|---|
| `3` | multi-release project |
| `2` | weeks |
| `1` | a few days |
| `0` | under a day |

**Status** — `bug` reproduced defect · `crash` takes MATLAB down · `idea` not
designed yet · `planned` designed, not started · `wip` in progress · `paused`
started and stopped, notes exist · `decide` blocked on a product decision ·
`triage` reported, never confirmed

**Refs** — `#N` GitHub issue · `br/X` unmerged branch · path = file or doc page

Every U and Sz below is a proposal, not a measurement — the point of the pass
is to replace them with your numbers.

---

## P. Major projects

The multi-release work. Everything here is bigger than one branch.

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| P1 | **TrueEBSD** — new `transformation` class, transform `EBSD`/`grain2d`, then integrate properly into MTEX rather than bolting it on | 1 | 3 | planned | — | [→](#p1) |
| P2 | **Twinning class** — a `twinningSystem` alongside `slipSystem`/`dislocationSystem`; decide which properties it carries, then parent–twin reconstruction | 2 | 3 | wip | Phillip | #367, [→](#p2) |
| P3 | **Stable HDF5 interface** — one h5 path that round-trips, replacing the per-vendor guessing | 2 | 2 | planned | — | #1365, #2268 |
| P4 | **Drop format sniffing** — interfaces should not each re-check "is this my format?"; dispatch once, centrally | 1 | 2 | idea | — | [→](#p4) |
| P5 | **3D EBSD / grain3d to parity with 2D** — the class exists, most of the analysis does not | 2 | 3 | wip | — | #2256, [→](#d) |
| P6 | **Clustering grain reconstruction (`grainSegmenter`)** — noise-robust segmentation; threshold-based `calcGrains` has no valid operating point on noisy maps | 1 | 2 | paused | — | br/grainSegmenter, [→](#p6) |
| P7 | **Statistical testing** — compare two EBSD sets, EBSD ↔ ODF; decide whether an EBSD set is representative enough for an ODF | 1 | 2 | idea | — | [→](#p7) |
| P8 | **Discover orientation relationships** — find matching planes and directions automatically instead of naming an OR | 1 | 2 | idea | — | — |
| P9 | **Displacement fields** | 0 | 2 | idea | — | — |
| P10 | **Optimal transport** — as a distance / interpolation between textures | 0 | 2 | idea | — | — |
| P11 | **EBSD simulation** — forward-model a map from an ODF plus a microstructure | 0 | 2 | idea | — | — |
| P12 | **Texture heterogeneity / local ODF estimation** | 0 | 2 | idea | — | — |
| P13 | **Single-precision storage** throughout, to halve memory on large maps | 1 | 2 | idea | — | #2466 |
| P14 | **`gridify` by default** — make the gridded EBSD the normal representation, not an opt-in | 2 | 2 | decide | — | #2295, #2167, #2128, [→](#p14) |

---

## G. Grain reconstruction and boundaries

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| G1 | Grain boundary smoothing that uses the band contrast | 1 | 1 | planned | Vivian | br/smoothBoundary |
| G2 | `ebsd = smooth(ebsd)` should fill pixels with `orientation == NaN` | 2 | 1 | planned | — | #192 |
| G3 | `smooth` should work on gridded data and return gridded data; what to fill and what not decided by `grainId`, not by the caller | 2 | 1 | planned | — | — |
| G4 | Faster `EBSD/smooth` — not per grain | 1 | 1 | idea | — | — |
| G5 | `minPixel` culling can isolate a pixel from its true grain, producing a malformed single-pixel grain | 2 | 1 | bug | — | #2574 |
| G6 | `minPixel` is ignored when alpha shapes are used | 2 | 0 | bug | — | #2513 |
| G7 | `calcGrains(EBSD(ebsd))` and `calcGrains(ebsd.gridify)` disagree — different grains from the same data | 3 | 1 | bug | — | #2295, [→](#p14) |
| G8 | `calcGrains` errors after `interp` | 2 | 0 | bug | — | #1870 |
| G9 | `calcPolygonsC` produces negative areas | 2 | 0 | bug | — | #2076 |
| G10 | `grains(1).poly` and `grains(1).boundary` have incompatible sizes — on a synthetic map `poly` has 17 vertices for 16 segments, i.e. a closed ring, which may be the whole report; needs the reporter's case (checked 2026-08-12) | 2 | 0 | triage | — | #1555 |
| G11 | `neighbors` returns wrong results | 1 | 0 | triage | — | #865 |
| G12 | `grainMean` behaves differently since 6.0 beta3 | 1 | 0 | triage | — | #2090 |
| G13 | FMC segmentation fails | 1 | 1 | triage | — | #539, [→](#g13) |
| G14 | `insidepoly` mishandles points exactly on the boundary; `findByLocation` should use it | 2 | 0 | bug | — | #2527 |
| G15 | jcvoronoi rounding | 1 | 0 | triage | — | #2440 |
| G16 | Progress bar for `calcGrains` | 1 | 0 | idea | — | #1881 |
| G17 | Separate sub-routine for sub-boundary calculations | 1 | 1 | idea | — | #2052 |
| G18 | Tooltip in `grainBoundary/plot` | 0 | 0 | idea | — | #788 |
| G19 | Sample x,y along a grain boundary at a chosen interval | 1 | 0 | idea | — | #97 |
| G20 | Grain size by the intercept-line method | 1 | 1 | idea | — | #48 |
| G21 | Grain volume distribution | 1 | 0 | idea | — | #281 |
| G22 | Median grain orientation next to the mean, via `cluster` | 1 | 1 | idea | — | #265 |
| G23 | Boundary density | 1 | 1 | idea | — | — |
| G24 | `gB.V` — expose boundary vertices as a first-class property | 1 | 0 | idea | — | — |
| G25 | `calcGrains` should also produce `variantId` and `parentGrainId` | 1 | 1 | idea | — | — |
| G26 | `calcGBND` for traces | 1 | 1 | idea | — | — |
| G27 | Better default parameters for parent grain reconstruction | 2 | 1 | planned | — | #644, br/betterParentGrain |
| G28 | `calcParentFromGraph` | 1 | 1 | idea | — | #643 |
| G29 | Weighted Voronoi in parent grain reconstruction | 1 | 1 | idea | — | #642 |
| G30 | Packet-to-packet child misorientations | 1 | 0 | idea | — | — |
| G31 | Pseudosymmetry correction using the OR | 1 | 1 | idea | — | — |
| G32 | Variant selection in transformation texture | 1 | 1 | idea | — | — |
| G33 | KAM: default filter masks that respect the grid resolution; option to compute per distance and on rings | 2 | 1 | planned | — | [→](#g33) |
| G34 | GND computation should solve the fit only approximately | 1 | 1 | idea | — | #1923 |
| G35 | Formula reference error in the GND documentation — **fixed 2026-08-12**; `GND.m` had been corrected already, `DislocationSystems.m` still carried `U_edge = (1-nu) U_screw` instead of `U_screw/(1-nu)`, plus the open ends around it | 2 | 0 | done | — | #1346 |
| G36 | Weighted Burgers vector: error estimation | 1 | 1 | idea | — | #2064 |
| G37 | Overlay a grain map with the active slip system | 1 | 0 | idea | — | — |
| G38 | `removeQuadruplePoints` destroyed real grain boundary — fixed, reference regenerated, benchmark green | 2 | 0 | done | — | [→](#g38) |
| G39 | Analytic Voronoi decomposition for gap-free regular grids — 43 % of `calcGrains` runtime is Fortune's sweep | 1 | 1 | paused | — | br/analytic-voronoi-grid, [→](#g39) |
| G40 | Speed up the segmentation criterion `gbcAngle.doEvaluate` — 0.71 s of `doSegmentation`'s 1.47 s | 1 | 1 | paused | — | [→](#g39) |

---

## D. 3D EBSD and grain3d

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| D1 | Shape metrics still missing on `grain3d`, though the doc page already advertises them: `equivalentSurface`, `shapeFactor`, `hasHole`, `isInclusion` | 2 | 1 | planned | — | doc/EBSD3Analysis/Grains3DProperties.m, [→](#d) |
| D2 | Curvature and convex hull for 3D grains | 1 | 1 | planned | — | br/curvature-direct-computation |
| D3 | `grainBoundaryCharacter` in 3D | 1 | 1 | planned | — | — |
| D4 | `characteristicShape` in 3D | 1 | 1 | planned | — | — |
| D5 | `grain3d.orientFaces` does not detect cavities — a grain enclosing another gets its surface oriented outwards; detected and warned about, not solved | 1 | 1 | bug | — | tests/check_orientFaces.m |
| D6 | 3D visualization | 2 | 2 | planned | — | #2256 |
| D7 | 3D boundary smoothing | 1 | 1 | planned | — | — |
| D8 | Cubit export | 0 | 1 | idea | — | — |
| D9 | `slice`, nearest neighbours on 3D data | 1 | 1 | planned | — | — |
| D10 | `grains.volume` is slow when called from `grain3d/display` | 1 | 0 | bug | — | #2092 |
| D11 | 3D orientation analysis crashes | 2 | 1 | triage | — | #2377 |
| D12 | `loadEBSD_dream3d` and `loadEBSD_xnovo` are not functional yet — blocked on 3D support itself | 1 | 1 | blocked | — | [→](#d12) |
| D13 | The 3D classes were absent from the function-reference sidebar — **done** in the 2026-08-10 pass, all three are in `doc/FunctionReference/EBSDAnalysis/EBSDAnalysis_index.toc` (checked 2026-08-11) | 1 | 0 | done | — | docs/doc-audit-plan.md item 4 |

---

## E. EBSD data and maps

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| E1 | `calcUnitCell` bug in `interfaces/tools` | 2 | 0 | bug | — | #2531 |
| E2 | `calcUnitCell` breaks when the map's xy is far from the origin | 2 | 0 | bug | — | #1722 |
| E3 | `gridify` and the ungridded EBSD report different point counts | 2 | 0 | bug | — | #2167 |
| E4 | Indexing a gridified EBSD returns a different size than in 5.10.2 | 2 | 0 | bug | — | #2128 |
| E5 | Rotating/cropping an EBSD map leaves an artifact | 2 | 1 | triage | — | #471 |
| E6 | `EBSD/cat` should be able to remove overlapping data | 1 | 1 | idea | — | #362 |
| E7 | Edge-preserving bilateral filter | 1 | 1 | idea | — | #346 |
| E8 | Texture strength index computed directly from EBSD data | 1 | 1 | idea | — | — |
| E9 | `orientation` ↔ property mapping | 1 | 1 | idea | — | — |
| E10 | `EBSD3.xy2ind` needs a review — `gradientX`/`gradientY` are done, and the `EBSDsquare/interp` half of this row is obsolete with E11 | 2 | 1 | planned | — | [→](#e10) |
| E11 | `@EBSDsquare/interp` died in `griddedInterpolant` with "Data is in MESHGRID format" — **gone**, the `@EBSD` merge deleted that file and `@EBSD/interp` makes no grid assumption (checked 2026-08-11) | 2 | 0 | done | — | docs/doc-audit-plan.md item 10 |
| E12 | `latticeBasis:38` "Index exceeds array bounds" — the real defect is a degenerate, self-intersecting unit cell reaching it, not the unguarded index | 2 | 1 | bug | — | [→](#e12) |
| E13 | `gridify` transposes the map at a 45° grid rotation — the layout tie-break is decided by float noise | 1 | 0 | bug | — | [→](#e13) |
| E14 | `gridify` cannot place a rotated hexagonal grid — **fixed**, hexify is lattice based and @EBSDhex stores no geometry | 2 | 1 | done | — | [→](#e14) |

---

## I. Import and export

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| I1 | `.ang` import: notIndexed points are dropped instead of being re-filled | 3 | 1 | bug | — | #2191, #2035, #2189, #1322 |
| I2 | `.ang` export: the written file cannot be read back, by MTEX or by TSL | 3 | 1 | bug | — | #1962, #1048, #804 |
| I3 | `ebsd.export('x.h5')` writes an h5 that `EBSD.load` cannot read | 3 | 1 | bug | — | #1365, [→](#p3) |
| I4 | Stitched HKL `.CRC` files fail to read | 2 | 1 | triage | — | #163 |
| I5 | Map spacing wrong from a rounding error on `.ctf` import | 2 | 0 | bug | — | #697 |
| I6 | Export an ODF as lossless ASCII | 1 | 0 | bug | — | #659 |
| I7 | `loadODF_VPSC`, plus the empty `Tutorials/ImportFromVPSC` page it would fill | 1 | 1 | idea | — | #297 |
| I8 | Export an EBSD map as a vector object | 1 | 1 | idea | — | #984 |
| I9 | Header-only import — every interface should be able to return metadata without reading the per-pixel blocks, so a browser can preview cheaply | 2 | 1 | planned | — | [→](#i9) |

---

## W. Import wizard

The wizard's own list at `interfaces/import_wizard/TODO.md` is the working
copy; only what is still open is summarised here.

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| W1 | Defaults to the lowest point group in the Laue class and rounds the unit cell parameters | 2 | 0 | bug | — | #2099 |
| W2 | Rename "Import to workspace" → "Import to variable" and swap the button order; "Export to Script" → "Generate import script" | 1 | 0 | planned | — | wizard 16, 17 |
| W3 | Clicking "Import to variable" should move focus to the Workspace | 1 | 0 | planned | — | wizard 18 |
| W4 | Phase table: split "Pixel" into "Pixels" and "%", right-aligned | 1 | 0 | planned | — | wizard 20 |
| W5 | Treeview of `ebsd.opt` in the empty space on the right | 1 | 1 | planned | — | wizard 21 |
| W6 | Two-column layout for the basic file info panel | 1 | 0 | planned | — | wizard 22 |
| W7 | Clicking a phase's Symmetry cell should open a separate symmetry editor | 1 | 1 | planned | — | wizard 23 |
| W8 | Generated script polish: `notIndexed(...)` name only, named plotting conventions, `EulerCorrection` as its own variable, an IPF-Z sanity plot, short-hand symmetry for cubic/orthorhombic | 2 | 1 | planned | — | wizard 25–28, 35 |
| W9 | Replotting pole figures after a Euler-frame change is slower than it needs to be | 1 | 1 | paused | — | wizard 14 |
| W10 | `import_wizard_old` is referenced from four doc pages but lives only in `obsolete/` | 2 | 0 | decide | — | [→](#w10) |

---

## O. Orientations, rotations and function spaces

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| O1 | `orientation/find` with the documented `int32` k errors — **could not reproduce** on 2026-08-11, `find(v,w,int32(3))` works; needs the reporter's exact call before closing | 2 | 0 | triage | — | #2580 |
| O2 | `SO3FunRBF` colon indexing: `B(1,:)` errors with "Out of range subscript" — **could not reproduce** on 2026-08-11; needs the reporter's exact object before closing | 2 | 0 | triage | — | #2579 |
| O3 | Wrong misorientation angle when an orientation lies outside the fundamental region | 3 | 1 | bug | — | #2162 |
| O4 | `misorientation` volume gives different results by route | 2 | 1 | bug | — | #445 |
| O5 | Euler angles of random orientations are inconsistent with the crystal symmetry | 2 | 1 | triage | — | #1597 |
| O6 | `vector3d` constructor is inconsistent across input shapes | 2 | 0 | bug | — | #2145 |
| O7 | `calcComponents` gives strange results or crashes when `'angle'` is passed | 2 | 1 | bug | — | #1840 |
| O8 | `radon(odf,h,'bandwidth',64)` crashed — the option bound to the positional `r` — **fixed 2026-08-12**, an option string in position 3 is shifted into `varargin` in all five implementations; `@SO3FunRBF` and `@SO3FunBingham` additionally ignored `'bandwidth'` once it arrived | 2 | 0 | done | — | [→](#o8) |
| O9 | `SO3FunComposition/radon` had no antipodal check of its own — **fixed 2026-08-12**, it now decides the flag itself instead of inheriting whatever its components set | 1 | 0 | done | — | [→](#o8) |
| O10 | `interp(...,'bingham')` is silently wrong under symmetry — relative error 0.92 for `'2'`, 0.95 for `'222'`, 0.67 for `'432'` | 1 | 1 | paused | — | [→](#o10) |
| O11 | `SO3FunRBF/rotate` is wrong — needs Thom's data to reproduce | 1 | 1 | blocked | — | — |
| O12 | `S2BumpKernel` was not normalized, `A(1) = 0.0076` — **fixed 2026-08-12**, `eval` divides by the relative area of the cap, so `A(1) = 1` and `calcDensity` has mean 1 | 2 | 0 | done | — | [→](#o12) |
| O13 | `SO3Fun/eval` with a mismatched symmetry should complain, not silently proceed | 1 | 0 | idea | — | — |
| O14 | `fibre/fit`: the global search is 2–25 s per fit and has a fast path only for trivial symmetry; the log/exp Gauss–Newton core is solid, fast global candidate scoring is the open problem | 1 | 2 | paused | — | [→](#o14) |
| O15 | `S1Fun` should possibly store a normal direction and a zero direction | 1 | 0 | decide | — | — |
| O16 | Sub-regions of ODF space | 0 | 1 | idea | — | — |
| O17 | Inner product of one ODF against several reference ODFs | 1 | 0 | idea | — | — |
| O18 | Axis/angle distribution normalization | 1 | 0 | idea | — | — |
| O19 | Angle range as an option for `odf/calcAxisDistribution` | 1 | 0 | idea | — | #385 |
| O20 | Index a polygon on the sphere | 1 | 1 | idea | — | #299 |
| O21 | `cmeans` for `vector3d` | 0 | 0 | idea | — | #361 |
| O22 | Fit an `SO3VectorField` | 1 | 1 | idea | Mathew Bolan | — |
| O23 | ODF compactification | 0 | 2 | idea | Erik | — |
| O24 | Transformation textures via convolution | 1 | 1 | idea | — | #328 |
| O25 | `Miller/line` | 1 | 0 | planned | — | br/mixedMiller |
| O26 | `circle(ori,radius)` should work in pole figures and ODF sections | 1 | 0 | idea | — | — |
| O27 | 17 class-qualified doc links dangle, eleven of which name API that exists nowhere | 2 | 1 | planned | — | docs/doc-audit-plan.md item 2e |
| O28 | `SO3FunMLS` needs the Symbolic Math Toolbox — `SO3FunMLS.m:319` calls `syms`, so the whole class is unavailable, and untestable, without that licence | 2 | 1 | bug | — | [→](#o28) |

---

## F. Pole figures and ODF reconstruction

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| F1 | Contoured pole figures differ between an ODF and the orientations it came from | 3 | 1 | triage | — | #172 |
| F2 | `calcODF` / `plotPDF` produce different results than 5.11.1 | 2 | 1 | triage | — | #2285, #2148 |
| F3 | `calcDensity` crashes MATLAB when producing a pole figure | 3 | 1 | crash | — | #1464, #580 |
| F4 | `plotSection(mdf,'axisAngle')` segfaults — needs differing left/right symmetry and bandwidth ≥ 32 | 3 | 1 | crash | — | [→](#f4) |
| F5 | `'logarithmic'` was ignored by `plotPDF` — **fixed 2026-08-12**, `@vector3d/smooth` tested only for the short spelling `'log'` | 2 | 0 | done | — | #1691 |
| F6 | Filled contours extend past the edge of the pole figure | 1 | 0 | bug | — | #707 |
| F7 | `plotSection` glitch for m-3 | 1 | 0 | triage | — | #209 |
| F8 | Better visualization of an OR in pole figures | 1 | 1 | idea | — | — |
| F9 | Sigma-section coloured pole figure; marker size in sigma sections | 1 | 0 | idea | — | — |
| F10 | Error analysis of an ODF reconstructed from XRD | 1 | 1 | idea | — | — |
| F11 | Explain the relationship between Fourier coefficients and spherical harmonic coefficients | 1 | 0 | idea | — | #193 |
| F12 | The `S2FunRadon` chapter is empty | 1 | 0 | planned | — | [→](#c-empty) |
| F13 | Improved ODF reconstruction | 1 | 2 | idea | Dan | — |

---

## X. Tensors, plasticity and physical properties

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| X1 | Sachs model with hardening rules, parallel `lsqnonneg` | 1 | 2 | planned | — | doc/Plasticity/SachsModel.m |
| X2 | Taylor model with hardening rules | 2 | 2 | wip | — | br/TaylorModel |
| X3 | Yield locus | 1 | 1 | idea | — | — |
| X4 | Eshelby inclusion, micromechanics | 0 | 2 | idea | — | — |
| X5 | `calcTensor` runs out of memory on large EBSD files | 2 | 1 | bug | — | #2002 |
| X6 | Nye tensor calculation is wrong | 2 | 1 | triage | — | #194 |
| X7 | `vector3d` and Schmid-factor commands disagree | 2 | 1 | triage | — | #1672 |
| X8 | `SchmidFactor(sS,sigma)` should warn when the reference systems differ | 1 | 0 | planned | — | — |
| X9 | Schmid factor for twinning, plotted on the IPF | 1 | 1 | idea | — | #1488 |
| X10 | Pre-defined twin systems, like the pre-defined slip systems | 1 | 1 | idea | — | #367, [→](#p2) |
| X11 | Plane atomic density | 1 | 0 | idea | — | #2266 |
| X12 | Ellipsoid representation for rank-2 tensors | 1 | 0 | idea | — | #326 |
| X13 | 3D property plots with the radius given by the velocity or another property | 1 | 1 | idea | — | #379 |
| X14 | Magnetic anisotropy should be documented with tensors | 1 | 0 | planned | — | — |
| X15 | The `sim` / `ensureCS` lattice tolerance gap: 1 % vs 10 %, so `calcTensor` rejects pairs the automatic frame transform would handle | 2 | 0 | decide | — | [→](#x15) |

---

## L. Plotting and colour

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| L1 | The scale bar moves depending on the plotting convention | 2 | 0 | bug | — | #2576 |
| L2 | Sigma sections ignore the plotting convention | 2 | 0 | bug | — | #2093 |
| L3 | `histogram(grains.longAxis)` ignores the plotting convention | 2 | 0 | bug | — | — |
| L4 | General plotting-convention oddities; `setMTEXpref('xAxisDirection',...)` has no effect | 3 | 1 | bug | — | #2014, #2096 |
| L5 | Crystal shapes do not follow the EBSD data when it is rotated or the convention changes | 2 | 1 | bug | — | #1952 |
| L6 | Colour keys in specimen coordinates should respect the plotting convention — better, `colorKey(what2color)` should take what it needs from the object | 2 | 1 | planned | — | [→](#l6) |
| L7 | `directionColorKey` bug | 1 | 0 | triage | — | #2515 |
| L8 | IPDF plots arrows incorrectly | 2 | 0 | bug | — | #2072 |
| L9 | `ipfKey.inversePoleFigureDirection` should probably be `outOfPlane` | 1 | 0 | decide | — | — |
| L10 | `plot(ebsd,ebsd.orientation,'ipfDirection',xvector)` should work | 1 | 0 | idea | — | — |
| L11 | The IPF colour key disk cache is keyed only by point-group id, so it silently serves a stale table when the crystal frame changes | 3 | 0 | bug | — | [→](#l11) |
| L12 | Colorbar at `'northoutside'` was placed below — **fixed 2026-08-12**; `'westoutside'` was equally broken. The side is kept in `mtexFig.cBarSide` and honoured by `calcTightInset`/`updateLayout` | 1 | 0 | done | — | #1744 |
| L13 | ODF subplots get different colormaps | 1 | 0 | bug | — | #1732 |
| L14 | `colorrange` misbehaves | 1 | 0 | triage | — | #1608 |
| L15 | ODFs plot differently than expected | 1 | 0 | triage | — | #320 |
| L16 | Plotting a circle glitches | 1 | 0 | bug | — | #330 |
| L17 | `S2Fun/plot` should honour MTEX coordinates in 3D | 1 | 0 | bug | — | #481 |
| L18 | Align spherical plots with a z-axis that is not perpendicular to the plane | 1 | 1 | idea | — | #520 |
| L19 | Change the projection direction of a crystallographic plot | 1 | 1 | idea | — | #249 |
| L20 | Move `vector3d` axis labels outside the hemisphere boundary | 1 | 0 | idea | — | #266 |
| L21 | Text scale mode for publication-ready figures | 1 | 1 | idea | — | #809 |
| L22 | Direct plots to a specific axis from an app | 1 | 0 | idea | — | #341 |
| L23 | Internal faces in crystal shapes | 1 | 1 | idea | — | #504 |
| L24 | Streamline plot — example from Björn | 0 | 0 | idea | Björn | — |
| L25 | Stereographic methods | 2 | 1 | wip | — | — |
| L26 | 3D-aware `mtexFigure` layout | 1 | 1 | paused | — | br/mtexFigure3dLayout |

---

## R. Performance and memory

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| R1 | `EBSD.load` carries a large time penalty | 2 | 1 | triage | — | #1450 |
| R2 | Out of memory during GND density calculation on large maps | 2 | 1 | bug | — | #1923, see G34 |
| R3 | Out of memory in `calcTensor` on large maps | 2 | 1 | bug | — | #2002, see X5 |
| R4 | Single-precision variables to cut runtime and RAM | 1 | 2 | idea | — | #2466, see P13 |
| R5 | Possible memory leak in mex initialisation on macOS | 1 | 1 | triage | — | #1392 |
| R6 | `grain3d/display` calling `grains.volume` is slow | 1 | 0 | bug | — | #2092, see D10 |

---

## B. Build, mex, platform and release

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| B1 | `wignerTrafomex.mexw64` reported as an invalid Win32 application; `wignerTrafoAdjointmex` not found | 3 | 1 | bug | — | #2487, #2268, [→](#b1) |
| B2 | nfft binaries do not run on some Windows systems | 2 | 1 | triage | — | #614 |
| B3 | `extern/libdirectional` is not shipped for all architectures | 2 | 1 | triage | — | #501 |
| B4 | `jcvoronoi_mex` fails to build on Ubuntu | 2 | 0 | bug | — | #2482 |
| B5 | Antivirus software flags jcvoronoi | 1 | 0 | triage | — | #2298 |
| B6 | The `compile-mtex` script no longer works | 2 | 0 | bug | — | #2369 |
| B7 | The release zip contains an extra file | 2 | 0 | bug | — | #2367 |
| B8 | Use a public-access configuration for the matGeom submodule | 2 | 0 | planned | — | #2546 |
| B9 | Cloud CI — partially answered by the mex build matrix, still no test CI | 2 | 1 | wip | — | #1028, [→](#b1) |
| B10 | Errors on MATLAB R2025a | 3 | 1 | triage | — | #2387 |
| B11 | MATLAB crashes during MTEX startup | 2 | 1 | triage | — | #1625, #1778, #630 |
| B12 | Version-to-version behaviour differences and compatibility reports | 1 | 1 | triage | — | #1710, #1493, #1309 |
| B13 | The 5.6.0 download link on the website is broken | 1 | 0 | bug | — | #687 |
| B14 | Better advertisement of the toolbox | 1 | 1 | idea | — | — |

---

## T. Testing

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| T1 | Compact S2Fun test suite: no plotting, 60 s ceiling, assertions that fail loudly — modelled on `tests/check_S1Fun.m` | 2 | 1 | partly done | — | [→](#t1) |
| T2 | Same for SO3Fun, which is scattered over `tests/check_SO3Fun*.m` and `tests/SO3FunTests/` mixed with scratch files — **done 2026-08-12**, `tests/SO3FunTests/` is gone; the scratch files were deleted and `check_SO3FunRotate`, `check_kernelHalfwidth`, `check_odfGrad` converted into asserting tests in `core/` | 2 | 1 | done | — | [→](#t1) |
| T3 | `'subsample'` died because the linprog workaround was gated on `version < 25` — **fixed 2026-08-11**, the options are now chosen by probing the solver, and every simplex variant fails on R2024b too | 2 | 0 | done | — | [→](#t3) |
| T4 | Two `check_S2FunMLS.m` cells fail with "Index exceeds array bounds", not yet diagnosed — **obsolete 2026-08-12**, the file is deleted: it asserted nothing, swept 64 option combinations and zeroed four known-bad ones by magic column index. The S2FunMLS coverage it nominally gave is gone with it, see T1 | 1 | 0 | wontfix | — | [→](#t1) |
| T5 | `tests/checkMeanTensor.m` stops at a rank-3 quadrature assert that cannot pass at any halfwidth; left failing deliberately — **stale 2026-08-12**: it passes end to end in 3.05 s, now at `tests/slow/check_meanTensor.m` (renamed to the `check_*` convention so the runner collects it) with its unclosed figures removed | 1 | 1 | done | — | docs/doc-audit-plan.md item 9 |
| T6 | `tests/check_ebsd.m` fails on develop; `checkIpfColorCoding` blocks on a `pause`, so it cannot run headless — **done 2026-08-12**: both deleted. The old `check_ebsd.m` asserted nothing and depended on `obsolete/calcODF.m`; `checkIpfColorCoding` had no assertions and used the deprecated `ipdfHSVOrientationMapping`. The name `check_ebsd` is now the merged EBSD object test in `core/` | 2 | 0 | done | — | — |
| T7 | `find_optimal_subset.m` exists twice, in `S2Fun/@S2FunMLS/private` and `SO3Fun/@SO3FunMLS/private`, differing only in argument names — every fix has to be applied twice | 1 | 0 | planned | — | [→](#t3) |

---

## C. Documentation

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| C1 | **3 empty chapters left** — `Misorientations/Twinning`, `Plasticity/SachsModel`, `Plasticity/TwinningTutorial`; the other eleven were written or dropped on 2026-08-10 | 2 | 1 | planned | — | [→](#c-empty) |
| C2 | 4 prose TODO markers left, all genuine open questions rather than authoring gaps | 1 | 1 | decide | — | [→](#c-todo) |
| C3 | Four content orphans with no TOC slot: `Dream3dGrains`, `S2FunQuadrature`, `MisorientationGrainExchangeSym`, `changelog` (plus the prose-only `Contribute2Doc`) | 1 | 0 | decide | — | docs/doc-audit-plan.md item 6 |
| C4 | ~~Two stale `*DeLaValleePoussin_index` pages and a `directionPlots_index`~~ deleted 2026-08-10, together with 24 copy-pasted index page titles and the 12 `PLEASE HELP` headings | — | — | done | — | docs/doc-audit-plan.md |
| C5 | Dead external links: 13 `code.google.com` in `changelog.m`, a `t.co` shortener on `Grains/HullBasedParameters.m:18` | 1 | 0 | planned | — | — |
| C6 | 26 of the 28 remaining dangling links are inside `changelog.m` — archive material, probably out of scope. The two live ones are `twinningSystem` and `EBSDGradient`, both deliberate | 0 | 0 | decide | — | — |
| C7 | Document the weighted Burgers vector | 1 | 1 | planned | — | — |
| C8 | Document transformation textures | 1 | 1 | planned | — | — |
| C9 | `calcCluster` / `calcComponents` / `max` documentation still uses the "hikers" phrasing | 1 | 0 | planned | — | — |
| C10 | Document `SHExtractor` | 1 | 0 | planned | — | — |
| C11 | Put the different hexagonal conventions on the homepage, and cover low symmetry | 2 | 1 | planned | — | — |
| C12 | Geometry talk: lattice directions vs lattice normals via Kikuchi patterns, with Nolze's picture | 1 | 0 | idea | — | — |
| C13 | Upload the Kikuchi `.mat` data | 1 | 0 | idea | — | — |
| C14 | Document the noise-level estimation behind the KAM options | 1 | 0 | planned | — | see G33 |
| C15 | Check that `"options"` works everywhere `'options'` does | 1 | 0 | wip | — | — |
| C16 | `bingham_test` runs again after a row/column fix, but its output convention is unverified — do not document until checked | 1 | 0 | decide | — | [→](#c16) |
| C17 | `calcDensity` on an **empty** orientation list died in the obsolete `ODF(cs,ss)` shim — **fixed 2026-08-11**, an empty and an all `NaN` list both give the uniform ODF | 2 | 0 | done | — | — |
| C18 | `calcPoleFigure(odf,pf.allH,pf.allR)` threw for superposed pole figures unless `'superposition',pf.c` was passed — **fixed 2026-08-12**, the default is one coefficient per crystal direction, all equal, so a superposed pole figure is the mean of its components | 2 | 0 | done | — | [→](#c18) |
| C19 | `stiffnessTensor.rand` returned a plain rank 2 `tensor` — **fixed 2026-08-12** with a `rand.m` on both rank 4 classes that draws a Gram matrix, since a random *array* is not a stiffness tensor; no `zeros`/`ones`/`nan` for the same reason | 2 | 1 | done | — | [→](#c19) |
| C20 | `export(odf,fname,'VPSC')` silently wrote a *generic* file — **fixed 2026-08-11**, the interface is taken as a bare flag as well and an unknown one is named | 2 | 0 | done | — | — |
| C21 | A new property needs `ebsd.prop.name = ...`; `ebsd.name = ...` errors, and no length check is done on the value | 1 | 0 | decide | — | — |

---

## S. Research, papers and collaborations

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| S1 | Paper on grain reconstruction | 1 | 2 | planned | Vivian | — |
| S2 | Paper on improved ODF reconstruction | 1 | 2 | planned | Dan | — |
| S3 | KAM, noise estimation, noise floor | 1 | 1 | planned | Ulrich Faul | see G33 |
| S4 | GND sample | 1 | 1 | planned | Ulrich Faul | — |

---

# Details

Longer notes for the rows that link here. Everything below was verified at
the date given; re-check before acting on a measurement.

### P1
New `transformation` class, able to transform `EBSD` and `grain2d` objects.
The third part — integrating it into MTEX properly rather than keeping it a
side path — is the part that makes this XL.

### P2
`doc/CrystalOrientations/DefinitionAsCoordinateTransform.m:71` already lists
"twinning systems" alongside `slipSystem` and `dislocationSystem`, and links
to a `twinningSystem` class that does not exist. The link is left dangling on
purpose as a reminder. Phillip has a deformation-twin class nearly done.
Parent–twin reconstruction is the second half.

### P3
`ebsd.export('x.h5')` writes a file `EBSD.load` cannot read (#1365), and
mixed-vendor h5 handling keeps producing separate reports. The
`loadEBSD_universal_hdf5.m` / `loadEBSD_h5.m` hdf5_config system covers
Bruker, EDAX, Oxford, ThermoFisher and EMSphInx; it does not cover XNOVO's
GrainMapper3D.

### P4
Today each interface checks whether a file is its own format, so adding a
format means touching the dispatch logic in several places and every
mis-detection surfaces as a confusing downstream error. `EBSD3.load` already
diverges from `EBSD.load` here — the former goes through
`check_interfaces.m`, the latter dispatches directly on the extension.

### P6
`EBSDAnalysis/@grainSegmenter/` on `br/grainSegmenter`, implemented
2026-07-25 with constant and linear region models; it beat the existing chain
on all three benchmark levels. Measured on the real steel1C_1 map: 2.5 M
pixels in 79 s. Fragmentation was root-caused to the error model — real
intra-grain curvature reaches 2.4° against an assumed σ of 0.33°. The branch
is 2 commits ahead of develop and 206 behind; it needs a rebase before
anything else. Baselines live in `tests/EBSDGrainBenchmark.m`,
`tests/scoreGrainBenchmark.m`, `tests/check_grainBenchmark.m`.

### P7
Two questions, one machinery: is the texture of EBSD set A the same as that
of set B, and does an EBSD set contain enough orientations to justify the ODF
estimated from it.

### P14
Three issues describe the same underlying split: `calcGrains(EBSD(ebsd))` and
`calcGrains(ebsd.gridify)` produce different grains (#2295), `gridify`
changes the point count (#2167), and indexing a gridified map returns
different sizes than it used to (#2128). Reproduction kept from the old file:

```matlab
ebsd = mtexdata('forsterite');
grains = ebsd.calcGrains;
plot(grains(grains.isBoundary))
nextAxis
ebsd = ebsd.gridify;
grains = ebsd.calcGrains;
plot(grains(grains.isBoundary))
```

Making gridded the default representation would remove the class of problem
rather than the individual symptoms, but it is a breaking change and needs a
decision first.

### G13
Note that FMC was rewritten on 2026-07-25 — saliency was dead code and
`quatmax` was chaotic; level-3 ARI went 0.84 → 0.95 at 2.7× the speed. #539
predates that rewrite and has not been re-checked against it. Re-verify
before spending time on it.

### G33
Two related requests: default filter masks whose size follows the grid
resolution instead of a fixed pixel count, and the option to compute KAM per
distance and on rings. The noise-floor documentation (C14) and Ulrich Faul's
noise-estimation work (S3) belong with it.

### G38
Investigated 2026-08-10. It was a real bug, not a stale reference, and not
where the earlier note guessed. **Fixed** in `br/quadruplePointMerge`
(`48c70823c`).

**Root cause.** `removeQuadruplePoints` splits a vertex where four grains
meet into two triple points: it appends a duplicate of the vertex, rewrites
two of the four edges onto it, and adds a segment joining the two. The
duplicate sits at the same coordinates, so that segment has zero length.
`mergeQuadrupleGrains` then merges away those of them the segmentation
criterion would not have called a boundary — but it identified them
*positionally*, as `gB(end-qAdded+1:end)`, relying on them having been
appended last. `13d90f5f5` (ordered boundary segments) made the
`grainBoundary` constructor sort every segment into chain walk order; its
own message lists "only stored positional indices" as breaking. So the
merge consumed unrelated, **real** segments: on forsterite 100 of them,
carrying 4529.8 of grain boundary, 0.21% of the map, while the grain count
moved only 2931 → 2926. Fixed by identifying them by vertex pair, which
survives the reordering, plus an assert — the old code had no way to notice
it was addressing the wrong rows.

**Why nothing caught it.** The benchmark records `totalLen`/`meanArea` for
the plain reconstruction only, so `nGrainsQP` was the sole probe of this
path, and a bare count cannot separate a tie-break from destroyed geometry.
It now records the QP boundary length too.

**Corrections to the earlier note**, all measured: the suspected commits
(`23f4566e1`, `8ab07ae9d`, `588f71202` — the hole/dummy-cell work) are *not*
the cause; `588f71202` is where the reference was written and reproduces it
exactly (forsterite QP 2931). Its numbers were stale throughout — steel is
99818 at HEAD, not 99868; `copper` passes; `forsterite` was failing too and
went unmentioned. Bisected on forsterite (0.74 s, no need for the 157 MB
map) in an isolated worktree seeded with the same cached `forsterite.mat`
the reference used, so the loader could not confound it.

**The residual on steel1C_1 — resolved, not a second bug.** Measured at
`13d90f5f5^` against a cached copy of the map:

| | nGrains | nGrainsQP | totalLen | totalLenQP |
|---|---|---|---|---|
| `13d90f5f5^` pre-bug | 104814 | 99843 | 156035.7019482653 | 155980.2966759322 |
| `develop` fixed | 104814 | 99843 | 156035.7019 | 155980.2967 |

Identical, so the fix restores steel exactly as it restores forsterite, and
the 55.4 loss is long-standing correct behaviour: `@grain2d/merge.m:204-205`
drops *every* segment whose two sides end up in the same merged grain, not
only those passed in `gB`, so a quadruple-point merge joining two grains that
also touch along a real boundary elsewhere removes that boundary too. It
needs enough grains to occur — never on forsterite, titanium or twins.

Consequently the "QP length equals plain length" check added alongside the
fix was over-generalised from small maps: the benchmark now reports
`totalLenQP` and leaves the pass/fail to the stored reference, and
`check_removeQuadruplePoints` documents that its invariant is scoped to the
three maps it names.

**The reference's 99857 is itself stale**, and the earlier note was half
right about why. `588f71202` wrote it on 24 Jul; `13d90f5f5^` on 27 Jul
already gives 99843. So the hole/dummy-cell commits (`23f4566e1`,
`fac9b9e8c`) did move steel by 14 grains — intended, since they legitimately
change reconstructed vertex positions and hence which vertices have exactly
four incident edges. Two independent changes had stacked: 99857 → 99843
(intended) and 99843 → 99818 (the bug, now fixed).

**Closed 2026-08-10.** Reference regenerated with Ralf's go-ahead: steel now
records 99843, and every dataset carries `totalLenQP`. All three match; the
benchmark is green for the first time since 24 Jul.

Note the reference file's own history: `forsterite.nGrainsQP` has flipped
three times, once purely session to session with byte-identical code, and
`steel1C_1.nGrainsQP` once, recorded as "accepted as a benign tie-break, not
re-verified independently". This metric has always been the fragile one —
which is exactly why it needed the geometry alongside it.

**Do not** run `check_grainReconstructionBenchmark('update')` until the
steel residual is classified.

### G39
Profiled on `$HOME/mtex/data/1C_1.ctf` (2.5 M pixels) 2026-07-22.
`jcvoronoi2_mex`, Fortune's sweep, is ~43 % of total `calcGrains` time — the
single biggest cost. `br/analytic-voronoi-grid` holds a rolled-back
`analyticGridDecomposition` helper for `spatialDecompositionGrid.m` that
skips the sweep entirely on gap-free regular grids, where every real cell
keeps exactly its own pixel. Not re-verified against current code. The
adjacency-only first pass was closed separately by the `'delaunayOnly'` flag
(commit `13db5772a`). Second lead: `gbc.eval` inside `doSegmentation` costs
0.71 s of 1.47 s — unclear whether there is real redundancy there or just
inherent per-pair cost.

### D
`doc/EBSD3Analysis/Grains3DProperties.m` advertises four methods that
`grain2d` has and `grain3d` does not: `equivalentSurface`, `shapeFactor`,
`hasHole`, `isInclusion`. Those doc links are left dangling on purpose as the
reminder. Shape metrics and `fitEllipse` are done.

### D12
`interfaces/loadEBSD_dream3d.m` and `interfaces/loadEBSD_xnovo.m` target 3D
data and are not functional (per Ralf, 2026-07-23). Failures from them are
expected, not regressions. Do not add header-only support to them before 3D
support itself is finished.

### E10
Kept verbatim from the old file as the list to review together:
`EBSD3.xy2ind`, `EBSDsquare/gradientX`, `EBSDsquare/gradientY`,
`EBSDsquare/interp`. See P14 for the reproduction that motivated it.

`EBSDsquare/gridBoundary` and `EBSDhex/gridBoundary` were also on this list;
both were deleted 2026-08-10 as dead code. Nothing called them —
`spatialDecompositionAlpha` builds its own dummy ring in index space.

`gradientX`/`gradientY` are **done**: they now live on `@EBSD`, are computed
on `ebsd.lattice`, and the three `error('Todo')` for grids not aligned with
an axis are gone — a known linear field is recovered exactly on 30 and 45
degree rotated, sheared and hex geometries. The hex version also turned out
to be wrong by `sqrt(3)` in one tensor column and is fixed. `interp` is
still open, phase 5 of that project.

### E14
`@EBSD/private/hexify.m` placed each measurement by rounding its raw x/y
against hard coded `sqrt(3)` and `3/2` factors taken off `ebsd.extent`, so
it only described a hex lattice aligned with the axes. Rotated, several
measurements rounded onto one cell and `phaseId(newId) = ebsd.phaseId` kept
whichever came last — silently:

| map | 20° | 45° |
|---|---|---|
| titanium (8100 px) | 421 lost (5.2%) | 621 (7.7%) |
| ferrite (63045 px) | 3407 lost (5.4%) | 4858 (7.7%) |

**Fixed 2026-08-11**, in two steps.

First the representation. `@EBSDhex` stored `dHex` + `isRowAlignment`, which
between them express exactly two orientations, so a rotated grid was not
representable at all — the state space was too small to hold the answer.
Both, plus `offset`, `dx` and `dy`, are dependent on `unitCell`/`pos` now,
and the constructor keeps a supplied `unitCell` instead of overwriting it
with an axis aligned hexagon. `isRowAlignment` turned out not to be needed
as state: it says which matrix index carries the parity stagger, and that is
visible in `pos` — one direction's step is constant, the other alternates
between two translations 60° apart. Reading it off `pos` is a statement
about the lattice, not the axes, so it survives any rotation. The old
`offset = sign(pos.x(2,1)-pos.x(1,1))` flipped from 45° on and inverted the
whole staggered addressing.

Then `hexify` itself, now built on the lattice like `squarify`: with `u` the
dense lattice direction and `v` the one 60° from it, a cell at axial index
`(i,j)` sits at `row = j+1`, `col = i + floor(j/2) + 1` — exactly the offset
convention `cube2hex` already implements, so `hex2cube`/`cube2hex` keep
working. Positions come from `latticeModel` and the measured nodes are put
back exactly.

Result: 0 collisions at 0°, 20° and 45° on both maps, and the measured
positions are now preserved *exactly* — the old code moved them by up to
0.02 because it rebuilt them from theoretical coordinates. Unrotated layouts
are unchanged (titanium 97×84, ferrite 270×234), and the grain
reconstruction benchmark still matches on all three datasets.

One consequence worth knowing: `dx`/`dy` are the measured spacings now, not
`sqrt(3)*dHex` and `1.5*dHex` by construction. On titanium the measured
column step is 12.000000 against `sqrt(3)*dHex` = 11.999824, because
`calcUnitCell` fits the cell statistically.

Still open, and not blocking: `export_ang` writes XSTEP/YSTEP from `dx`/`dy`,
and a rotated grid has no scalar step along x or y. That call site has to
refuse or export the unrotated spacing.

### E13
`@EBSD/private/squarify.m`'s `orientGrid` decides which lattice direction
becomes matrix dimension 1 with

```matlab
horizontal = @(d) abs(dot(d,xvector)) - abs(dot(d,yvector));
isXFirst   = horizontal(d1) > horizontal(d2);
```

At a 45° grid rotation both directions are equally horizontal, so both sides
are 0 and the comparison is settled by rounding noise. Reproduced 2026-08-10
on `twins`, rotating positions only:

| rotation | `size(ebsd.gridify)` |
|---|---|
| 44.999999999° | 137 x 167 |
| 45.000000000° | 167 x 137 |
| 45.000000001° | 167 x 137 |

A 1e-9 degree difference transposes the whole map. Both layouts hold the same
data, so nothing is computed wrongly, but the same physical map can gridify
to transposed layouts across imports — which defeats the point of the grid
classes, whose reason to exist is handing a stable matrix to image
registration tools.

The sign normalisation just below (`dot(d1,ref(1)) < 0`) has the same problem at
the same configuration.

Fix by stating the tie-break instead of leaving it to the noise, and note
that `check_gridify`'s `checkResampleRotated` already exercises a 45° rotated
unit cell. Deliberately not bundled into the @EBSDgrid / latticeModel work:
it touches the path every gridify takes, so it wants its own change and its
own test. Phase 2 of the @EBSD project (the lattice-native gradient) needs
the same basis pinned down and is the natural place to do it.

### E12
`doc/EBSDAnalysis/EBSDGrid.m:141` → `EBSD/plot:93` → `plotUnitCells:51` →
`plotSurf:15` → `calcMesh:29` → `latticeBasis.m:38`. The unguarded `cand(1)`
is the symptom: at the crash site the `EBSDsquare` carries a degenerate,
self-intersecting unit cell (x extent 0.83, y extent ~9) although the page
asked for a unit square, so every candidate translation is near-parallel to
`a1` and `find(d<0.5)` is empty. Guarding the index would hide the real
defect. Only reachable because the `@EBSDsquare/plotUnitCells.m` and
`@EBSDhex/plotUnitCells.m` overrides were deleted — they dispatched straight
to `plotSurf` and never entered `latticeBasis`.

### I9
`loadEBSD_ctf.m` already reads its header separately from the bulk data, so
it is the natural place to prototype a header-only path. The wizard's
metadata display currently only runs after a full `EBSD.load`, so browsing a
directory pays a full load per file. See wizard item 13.

### W10
`import_wizard_old` is called from `ODFImport.m:18`, `PoleFigureImport.m:16`
and `:134`, and `PoleFigureTutorial.m:8`, but lives only in `obsolete/`.
Either point those pages at the current wizard, or rewrite their GUI sections
around the plain load commands. Product decision, not a code fix.

### O8
**Fixed 2026-08-12.** `radon`'s signature is `radon(SO3F,h,r,varargin)`, so a
third positional option string bound to `r` and reached `dot_outer` as "Dot
indexing is not supported for variables of this type"; the workaround was
`radon(odf,h,[],'bandwidth',64)`. Of the two proposed fixes the first was
taken — an option string in position 3 is shifted into `varargin` — because
dropping `r` from the positional API would break `radon(SO3F,h,r)`, which is
the documented way to get plain doubles and is used across `plotPDF`,
`calcPDF` and `calcPoleFigure`. The shift sits at the very top of each file,
before anything reads `r`: `@SO3FunHarmonic` tests `r.antipodal` at line 22,
well before its own `if nargin<3` at line 30.

Five implementations carry it — `@SO3Fun`, `@SO3FunRBF`, `@SO3FunCBF`,
`@SO3FunBingham`, `@SO3FunHarmonic`. `@SO3FunComposition` never needed it,
its signature is `radon(odf,h,varargin)`.

**Two of them then ignored the option they had just been handed**, which the
row did not say:

- `@SO3FunRBF/radon` passed `SO3F.psi.bandwidth` to both quadratures
  literally, so `'bandwidth'` had no effect at all. It now caps the request
  at the kernel bandwidth the way `@SO3FunHarmonic/radon` caps at its own —
  a larger request cannot be answered with information that is not there, a
  smaller one is an honest truncation.
- `@SO3FunBingham/radon` forwarded `varargin` into the inner function handle
  but not to `S2FunHarmonicSym.quadrature` itself, so the bandwidth of the
  result was the quadrature default.

`@SO3FunComposition/radon` (O9) only summed the component transforms and had
no final antipodal check of its own, unlike `@SO3Fun/radon.m` and
`@SO3FunRBF/radon.m`. `varargin` is forwarded, so it worked as long as every
component type implemented that logic — no safety net if one does not, which
was exactly the situation for `@SO3FunCBF` until 2026-08-06. It now decides
the flag itself, from `'antipodal'`, `CS.isLaue`, `h.antipodal` and
`r.antipodal`, as `@SO3Fun/radon` does.

Verification: `tests/check_radonOptions.m` — every implementation, the
shifted option against the explicit `[]` form, the positional syntaxes that
have to keep working, and the composition antipodal flag over a Laue group
and over an antipodal `h`. Fails on the unfixed tree.

### O10
Does not error, silently returns a bad fit. Relative error against the source
ODF, from `fibreODF(fibre.rand(cs))` sampled on `equispacedSO3Grid(cs)`:
`'1'` 0.0043, `'2'` 0.92, `'222'` 0.95, `'432'` 0.67. This is what
`doc/SO3Functions/SO3FunApproximationTheory.m:172` ("TODO: Dont work") refers
to; the page works around it with `crystalSymmetry("1")`. Deferred by
decision on 2026-07-28.

### O12
`S2Fun/S2KernelFunctions/S2BumpKernel.m` builds its Legendre coefficients
with `calcFourier(psi,L,psi.halfwidth)` and never normalizes. For
`S2BumpKernel(10*degree)`, `psi.A(1) == 0.0076` — the relative area of a 10°
cap — where `S2DeLaValleePoussinKernel` and `S2DirichletKernel` both give
`A(1) == 1`. Its `eval` returns a bare 0/1 indicator, not a density.
Consequence: `calcDensity(v,'kernel',S2BumpKernel(10*degree))` has mean
0.0076 and max 0.0397 instead of the m.u.d. normalization every other kernel
gives, with nothing warning on the way. Found 2026-08-08.

### O14
Four approaches were tried on 2026-07-26 to replace `geometry/@fibre/fit.m`'s
grid search; the ones that produced a fibre at all were 5–30× faster but none
matched accuracy on mmm, 432 or a pathological C2 case. Keep the log/exp
Gauss–Newton core — `log(rotation.byAxisAngle(h,theta)) = theta*h` exactly,
so re-linearization is not an approximation — and land it as a replacement
for the `'local'` branch, which today only works for `CS.numProper == 1`.
The open problem is purely fast, accurate *global* candidate scoring:
widening 5 → 30 refined candidates barely moved accuracy, so the bottleneck
is score quality, not the number of starts. Do not retry `calcPDF(odf,hGrid)`
for batched scoring — its array-`h` behaviour is superposition, not
independent per-candidate results; that would need custom code at the
`radon.m` Fourier-coefficient level.

### F4
Hard crash, not a MATLAB error. Needs both a differing left/right symmetry
(a cross-phase misorientation) and bandwidth ≥ 32. Reproduced on R2024b:

```matlab
ebsd = mtexdata('forsterite'); grains = calcGrains(ebsd);
mdf = calcDensity(grains.boundary('Fo','En').misorientation,'halfwidth',5*degree);
mdf.bandwidth = 25;  plotSection(mdf,'axisAngle')   % fine
mdf.bandwidth = 32;  plotSection(mdf,'axisAngle')   % segmentation violation
```

Same-phase (Fo→Fo, `CS == SS`) is fine at bandwidth 25, 32 and 48, so it is
the combination that matters. Found 2026-07-28 while merging the MDF doc
pages; that page now plots axis-angle sections of a same-phase MDF instead.

### X15
Two tolerances answer the same question an order of magnitude apart.
`geometry/phaseItem.m`'s `simPair` (used by `sim`, and by
`@EBSD/calcTensor.m:40`) requires `all(abs(abc1-abc2)/max(abc1) < 1e-2)` — 1 %
— while `geometry/@symmetry/ensureCS.m:31` transforms automatically at
`norm(MM-eye(3))/norm(MM) < 1e-1` — 10 % — and calls
`transformReferenceFrame` itself. So the transform *is* automatic via
`@tensor/rotate.m:18`, but `calcTensor` errors at its own `sim` pre-check
first. Concretely: the Diopside tensor in `CPOSeismicProperties.m` deviates
1.7 % in a and 2.2 % in b from the measured Diopside phase of
`mtexdata forsterite` — inside `ensureCS`, outside `sim`. Numerically the
frame choice barely matters (0.008 % in the aggregate), so this is about
which failures users are made to fix by hand. Aligning the two would change
phase-matching semantics globally. **Ralf's call.**

### L6
The general fix is not to thread the convention through each colour key, but
to have `colorKey(what2color)` take the required information from the object
being coloured. `histogram(grains.longAxis)` (L3) and the specimen-coordinate
keys are two symptoms of the same design gap.

### L11
`ipfColorKey.precompute`, called by `@EBSD/plot.m` for every IPF map,
replaces the exact `direction2color` with an `S2FunGrid` lookup cached at
`~/.matlab/R<rel>/mtex_cache/colorKeys/ipfColorKey_id<pointGroupId>_v1.mat`.
The key holds only the point-group id and a hand-bumped `_v1` — nothing about
the crystal frame, the `HSVDirectionKey` or the sector geometry. The
hexagonal 622 cache (`id36`) written 2026-07-10 was built while `calcAxis`
still returned X‖a instead of X‖a*, so α-Ti maps came out rotated 30° about c
with max RGB deviation 0.79. Cubic was unaffected because a*‖a there.

### B1
The mex CI matrix build (`.github/workflows/build-mex.yml`) works as of
2026-08-07 — mexa64 2m11s, mexmaca64 3m14s, mexw64 6m44s — which addresses
the drift that produced most of these reports, but the older binaries in the
wild are what the issues are about. Releases stay drafts until CI attaches
the binaries. macos-13 runners are unusable. Windows needs MinGW installed
explicitly via `products:` on `setup-matlab`. There is still no *test* CI,
only a build one, which is what #1028 asked for.

### T1
Measured 2026-08-06 on R2024b. S2Fun is only `tests/check_S2FunMLS.m`, a cell
script taking 69.9 s, roughly 80 % of it figure rendering: one default
resolution plot of an `S2FunMLS` costs 8.9 s against 0.9 s to build it and
1.9 s to evaluate it at 1e4 nodes, and the same plot at
`'resolution',5*degree` costs 0.9 s, over about 15 plot calls. Node counts
are not the bottleneck — plots are. 3 of its 12 cells already error out.
SO3Fun is scattered over `tests/check_SO3Fun*.m` and `tests/SO3FunTests/`,
which mixes check scripts with scratch files (`problems.m`, `testing.m`,
`Newapproximation.m`); not yet timed. Model both on `tests/check_S1Fun.m` — a
function with assertions that fails loudly, not a cell script that prints
numbers nobody reads. Note that T3 being fixed makes the suite slower, since
`'subsample'` runs a `linprog` per node.

### T3
**Fixed 2026-08-11.** The recorded diagnosis was wrong in its key claim: the
problem does not start at R2025a. Measured on R2024b, where the default
`linprog` algorithm is already `dual-simplex-highs`, asking for the fifth
output (the Lagrange multipliers, which the optimal subset selection needs)
fails for every simplex variant — `dual-simplex`, `dual-simplex-highs` and the
default with "Unrecognized field name optimstatus", `dual-simplex-legacy` with
an internal error `-1000@-1000`. Only `interior-point` and
`interior-point-legacy` return them. So `'subsample'` was dead on the release
MTEX is developed against, not only on the one after it.

Version sniffing being what got this wrong, it is gone: one trivial two
variable program is solved with the preferred options and the fallback is
taken only if that throws, cached in a `persistent` so it costs a single solve
per session. Covered by `tests/check_MLSSubsample.m`, which asserts the
approximation is usable rather than merely constructible.

The SO3 side carries the same helper but could not be tested — see O28. The
duplication itself is T7: `find_optimal_subset.m` exists twice, differing only
in argument names, so this fix had to be applied twice.

### O28
`SO3Fun/@SO3FunMLS/SO3FunMLS.m:319` calls `syms phi`, i.e. the class needs the
Symbolic Math Toolbox. On a machine without that licence every
`SO3FunMLS(...)` call dies with "Undefined function 'syms' for input arguments
of type 'char'", which is also why the SO3 half of T3 could not be verified.
Found 2026-08-11. Either replace the symbolic step with a numeric one, or
declare the dependency and fail with a message that names the toolbox.

### C-empty
Of the fourteen empty chapters found by the 2026-07-28 doc audit
(`docs/doc-audit-plan.md` item 5), three remain:

- `Misorientations/Twinning` — excluded from the 2026-08-10 pass by request
- `Plasticity/SachsModel` — kept as a stub by decision; there is no Sachs
  implementation in the source and `SingleSlipModel.m` covers the same physics
- `Plasticity/TwinningTutorial` — in no toc, kept as a placeholder

Written on 2026-08-10: `GeneralConcepts/Properties`, `Grains/GrainExport`,
`Misorientations/AngleDistributionFunction`,
`Misorientations/AxisDistributionFunction`, `Plasticity/TextureEvolution`,
`Plotting/PlottingExport`, `PoleFigureAnalysis/PoleFigureExport`,
`SphericalFunctions/S2FunRadon`. Deleted as duplicates of pages that already
had the content: `Rotations/RotationImport`, `Rotations/RotationExport`,
`Tutorials/ImportFromVPSC`. `Plasticity/SlipTransmission` had already been
filled from the misspelled `SlipTransmition.m`.

The historical list follows.

- `GeneralConcepts/Properties`
- `Grains/GrainExport` — carries a "please help to fill" marker
- `Misorientations/AngleDistributionFunction`
- `Misorientations/AxisDistributionFunction`
- `Misorientations/Twinning`
- `Plasticity/SachsModel`
- `Plasticity/SlipTransmission` — note that `Plasticity/SlipTransmition.m`,
  misspelled, has 52 lines of real content and is in no toc
- `Plasticity/TextureEvolution`
- `Plotting/PlottingExport`
- `PoleFigureAnalysis/PoleFigureExport`
- `Rotations/RotationExport`
- `Rotations/RotationImport`
- `SphericalFunctions/S2FunRadon`
- `Tutorials/ImportFromVPSC` — would follow from I7

Plus `Plasticity/TwinningTutorial`, in no toc, kept as a placeholder.

---

### C-todo
The four prose `TODO` markers left in `doc/` on 2026-08-10. Each is a question
about the data, not a gap in the writing, so they were left in place rather
than papered over.

- `GrainBoundaries/TiltAndTwistBoundaries.m:91` — "we find two preferred
  misorientation axes, (001) and (071), can this be interpreted?"
- `Grains/GrainOrientationParameters.m:281` — a commented out Bingham test on
  a single grain, see also C16
- `Grains/EllipseBasedParameters.m:253` — "get deviation from an ellipse etc",
  i.e. a goodness of fit measure for the fitted ellipse that does not exist yet
- `Grains/Grain_dispersion_axes.m:108` — use the eigenvalues of `fibre.fit` to
  quantify how fibre like a grain is

### C16
`geometry/@orientation/bingham_test.m` indexed `lambda` and `kappa` as columns
while `mean(ori)` hands them back as rows, so every call threw "Index in
position 1 exceeds array bounds". Fixed 2026-08-10 by flattening with `(:)`.

It now runs, but the numbers have not been validated. On 5000 orientations
drawn from `BinghamODF([10 10 10 0],...)` the three tests return 1.0000, 1.0000
and 0.8157, and `T = 1-gammainc(p/2,v/2,'upper')` is the chi-squared CDF rather
than a p-value, so it is unclear which way round to read it. No callers outside
`templates/EBSD_bingham_tests.m`. `doc/ODFAnalysis/BinghamODFs.m` therefore
mentions the function but does not demonstrate it.

### C18
**Fixed 2026-08-12.** `SO3Fun/@SO3Fun/calcPoleFigure.m:66` reshapes the result
of `calcPDF` to `size(r{ip})`. The default structure coefficients were built
as one per pole figure, `repcell(1,1,length(h))`, so when a cell entry of `h`
held several Miller indices — a superposed pole figure — `calcPDF` returned
one value per Miller index and the reshape failed.

Reproduced with `mtexdata dubna`, whose third pole figure superposes
$(10\bar11)$ and $(01\bar11)$:

    pf = ...; odf = calcODF(pf,'silent');
    calcPoleFigure(odf,pf.allH,pf.allR)                          % threw
    calcPoleFigure(odf,pf.allH,pf.allR,'superposition',pf.c)     % worked

The default is now one coefficient per crystal direction, all equal, i.e.
the superposed pole figure is the *mean* of its components and so is again a
pole density with mean one — the same thing the non-superposed case returns.
Equal *ones* would have been the other reading, but that scales a superposed
pole figure by the number of contributing directions and nothing downstream
expects that. Explicit coefficients are still taken as they are, unnormalized:
`pf.c` for dubna is `[0.52 1.23]`, which does not sum to one, and measured
structure coefficients are not the place for MTEX to impose a convention.

Note that `calcPDF` itself is left alone. With a scalar `'superposition'` and
several Miller indices it returns one pole density per index rather than
their sum, which is what `plotPDF` relies on.

Verification: `tests/check_calcPoleFigureSuperposition.m` — the default is
the mean, explicit coefficients are honoured exactly, a plain pole figure is
unchanged, and the reported dubna call returns 7 pole figures of the right
shape. Fails on the unfixed tree.

### C19
**Fixed 2026-08-12, but not as this row described it.** Wrapping `tensor.rand`
in the subclass constructor - the way `eye` is already restated on both rank 4
classes - is wrong: a tensor of independent random entries is neither
symmetric nor positive definite, so the constructor's own checks fire and
every call warns twice. `@stiffnessTensor/rand.m` and
`@complianceTensor/rand.m` therefore draw a random Gram matrix `A*A'` in Voigt
notation, shifted away from singularity, which has both properties by
construction.

For the same reason there are deliberately **no** `zeros`, `ones` or `nan`
counterparts - none of them is a stiffness tensor. `check_tensorFactories`
asserts they still resolve to the base class, so that adding them means
thinking about the invariant first. The rank 2 subclasses were left alone:
their inherited factories at least give the right rank, and a random
`spinTensor` or `strainTensor` raises the same question about the symmetry
each of them requires.

## Unmerged branches

Everything not on develop, with its distance as of 2026-08-09. A branch far
behind needs a rebase before its content can be judged.

| Branch | Ahead | Behind | Last commit | Row |
|--------|-------|--------|-------------|-----|
| `feature/TaylorModel` | 62 | 1089 | 2026-03-11 | X2 |
| `feature/sortSegments` | 15 | 1319 | 2025-02-19 | — |
| `feature/grainSegmenter` | 2 | 206 | 2026-07-26 | P6 |
| `feature/mtexFigure3dLayout` | 1 | 158 | 2026-07-28 | L26 |
| `feature/betterParentGrain` | 1 | 195 | 2026-07-28 | G27 |
| `feature/completeBoundaries` | 1 | 218 | 2026-07-25 | — |
| `feature/curvature-direct-computation` | 1 | 273 | 2026-07-14 | D2 |
| `experiment/analytic-voronoi-grid` | 1 | 250 | 2026-07-22 | G39 |
| `feature/mixedMiller` | 1 | 1611 | 2024-10-04 | O25 |
| `feature/orderedBoundarySegments` | 1 | 2283 | 2024-03-14 | superseded, ordered boundaries shipped |
| `origin/feature/grain3d` | 1 | 1673 | 2024-10-08 | superseded |
| `feature/smoothBoundary` | 0 | 30 | 2026-08-08 | G1 — merged |
| `feature/mexPortability` | 0 | 50 | 2026-08-07 | B1 — merged |
| `origin/feature/textureTomography` | 0 | 1503 | 2024-11-25 | merged |
| `origin/feature/plane3d` | 0 | 1689 | 2024-10-08 | merged |
