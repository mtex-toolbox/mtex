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
| G10 | `grains(1).poly` and `grains(1).boundary` have incompatible sizes | 2 | 0 | bug | — | #1555 |
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
| G35 | Formula reference error in the GND documentation | 2 | 0 | bug | — | #1346 |
| G36 | Weighted Burgers vector: error estimation | 1 | 1 | idea | — | #2064 |
| G37 | Overlay a grain map with the active slip system | 1 | 0 | idea | — | — |
| G38 | `grainReconstructionBenchmark` disagrees with its stored reference — 99868 vs 99857 grains on steel1C_1 | 2 | 0 | paused | — | [→](#g38) |
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
| D13 | The 3D classes are absent from the function-reference sidebar: `EBSD3_index`, `grain3d_index`, `grain3Boundary_index` | 1 | 0 | bug | — | docs/doc-audit-plan.md item 4 |

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
| E10 | `EBSD3.xy2ind`, `EBSDsquare/gradientX`, `gradientY`, `gridBoundary`, `interp` need a review — several disagree with their gridded counterparts | 2 | 1 | planned | — | [→](#e10) |
| E11 | `@EBSDsquare/interp` dies in `griddedInterpolant` with "Data is in MESHGRID format" on a gridified map; both orientations of the try/catch fallback fail | 2 | 0 | bug | — | docs/doc-audit-plan.md item 10 |
| E12 | `latticeBasis:38` "Index exceeds array bounds" — the real defect is a degenerate, self-intersecting unit cell reaching it, not the unguarded index | 2 | 1 | bug | — | [→](#e12) |

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
| O1 | `orientation/find` with the documented `int32` k errors — "Integers can only be raised to positive integral powers" | 2 | 0 | bug | — | #2580 |
| O2 | `SO3FunRBF` colon indexing: `B(1,:)` errors with "Out of range subscript" | 2 | 0 | bug | — | #2579 |
| O3 | Wrong misorientation angle when an orientation lies outside the fundamental region | 3 | 1 | bug | — | #2162 |
| O4 | `misorientation` volume gives different results by route | 2 | 1 | bug | — | #445 |
| O5 | Euler angles of random orientations are inconsistent with the crystal symmetry | 2 | 1 | triage | — | #1597 |
| O6 | `vector3d` constructor is inconsistent across input shapes | 2 | 0 | bug | — | #2145 |
| O7 | `calcComponents` gives strange results or crashes when `'angle'` is passed | 2 | 1 | bug | — | #1840 |
| O8 | `radon(odf,h,'bandwidth',64)` crashes — the option binds to the positional `r` | 2 | 0 | bug | — | [→](#o8) |
| O9 | `SO3FunComposition/radon` has no antipodal check of its own; it works only as long as every component type implements one | 1 | 0 | bug | — | [→](#o8) |
| O10 | `interp(...,'bingham')` is silently wrong under symmetry — relative error 0.92 for `'2'`, 0.95 for `'222'`, 0.67 for `'432'` | 1 | 1 | paused | — | [→](#o10) |
| O11 | `SO3FunRBF/rotate` is wrong — needs Thom's data to reproduce | 1 | 1 | blocked | — | — |
| O12 | `S2BumpKernel` is not normalized: `A(1) = 0.0076`, so `calcDensity` with it returns mean 0.0076 instead of 1 | 2 | 0 | bug | — | [→](#o12) |
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

---

## F. Pole figures and ODF reconstruction

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| F1 | Contoured pole figures differ between an ODF and the orientations it came from | 3 | 1 | triage | — | #172 |
| F2 | `calcODF` / `plotPDF` produce different results than 5.11.1 | 2 | 1 | triage | — | #2285, #2148 |
| F3 | `calcDensity` crashes MATLAB when producing a pole figure | 3 | 1 | crash | — | #1464, #580 |
| F4 | `plotSection(mdf,'axisAngle')` segfaults — needs differing left/right symmetry and bandwidth ≥ 32 | 3 | 1 | crash | — | [→](#f4) |
| F5 | `'logarithmic'` is ignored by `plotPDF` | 2 | 0 | bug | — | #1691 |
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
| L12 | Colorbar at `'northoutside'` is placed below | 1 | 0 | bug | — | #1744 |
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
| T1 | Compact S2Fun test suite: no plotting, 60 s ceiling, assertions that fail loudly — modelled on `tests/check_S1Fun.m` | 2 | 1 | planned | — | [→](#t1) |
| T2 | Same for SO3Fun, which is scattered over `tests/check_SO3Fun*.m` and `tests/SO3FunTests/` mixed with scratch files | 2 | 1 | planned | — | [→](#t1) |
| T3 | `find_optimal_subset.m:56` gates the linprog workaround on `version < 25`, but the bug already hits R2024b, so `'subsample'` dies | 2 | 0 | bug | — | [→](#t1) |
| T4 | Two `check_S2FunMLS.m` cells fail with "Index exceeds array bounds", not yet diagnosed | 1 | 0 | bug | — | [→](#t1) |
| T5 | `tests/checkMeanTensor.m` stops at a rank-3 quadrature assert that cannot pass at any halfwidth; left failing deliberately | 1 | 1 | decide | — | docs/doc-audit-plan.md item 9 |
| T6 | `tests/check_ebsd.m` fails on develop; `checkIpfColorCoding` blocks on a `pause`, so it cannot run headless | 2 | 0 | bug | — | — |

---

## C. Documentation

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| C1 | **14 empty chapters** — each publishes as a visible title-and-nothing page | 3 | 2 | planned | — | [→](#c-empty) |
| C2 | 26 prose TODO markers across the doc pages ("extend this section", "explain in more detail"); six sit on stub pages | 1 | 1 | planned | — | docs/doc-audit-plan.md item 10 |
| C3 | Four content orphans with no TOC slot: `Dream3dGrains`, `S2FunQuadrature`, `MisorientationGrainExchangeSym`, `changelog` | 1 | 0 | decide | — | docs/doc-audit-plan.md item 6 |
| C4 | Two stale `*DeLaValleePoussin_index` pages and a `directionPlots_index` with no source behind it | 1 | 0 | bug | — | docs/doc-audit-plan.md item 4 |
| C5 | Dead external links: 13 `code.google.com` in `changelog.m`, a `t.co` shortener on `Grains/HullBasedParameters.m:18` | 1 | 0 | planned | — | — |
| C6 | 18 of the remaining dangling links are inside `changelog.m` — archive material, probably out of scope | 0 | 0 | decide | — | — |
| C7 | Document the weighted Burgers vector | 1 | 1 | planned | — | — |
| C8 | Document transformation textures | 1 | 1 | planned | — | — |
| C9 | `calcCluster` / `calcComponents` / `max` documentation still uses the "hikers" phrasing | 1 | 0 | planned | — | — |
| C10 | Document `SHExtractor` | 1 | 0 | planned | — | — |
| C11 | Put the different hexagonal conventions on the homepage, and cover low symmetry | 2 | 1 | planned | — | — |
| C12 | Geometry talk: lattice directions vs lattice normals via Kikuchi patterns, with Nolze's picture | 1 | 0 | idea | — | — |
| C13 | Upload the Kikuchi `.mat` data | 1 | 0 | idea | — | — |
| C14 | Document the noise-level estimation behind the KAM options | 1 | 0 | planned | — | see G33 |
| C15 | Check that `"options"` works everywhere `'options'` does | 1 | 0 | wip | — | — |

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
As of 2026-07-24 `check_grainReconstructionBenchmark` fails two of three
cases against the checked-in reference: `copper` differs by ~1e-6 (harmless
float drift), but `steel1C_1` differs in `removeQuadruplePoints` grain count,
99868 vs 99857 — a real topology difference. Most likely from the
hole/dummy-cell position reconstruction commits (`23f4566e1`, `8ab07ae9d`,
`588f71202`). **Do not** run `check_grainReconstructionBenchmark('update')`
to make it pass until the topology change near holes has been confirmed as
intended.

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
`EBSDsquare/gridBoundary`, `EBSDsquare/interp`. See P14 for the reproduction
that motivated it.

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
`radon`'s signature is `radon(SO3F,h,r,varargin)`, so a third positional
option string binds to `r` and reaches `dot_outer` as "Dot indexing is not
supported for variables of this type". Workaround today is
`radon(odf,h,[],'bandwidth',64)`. Affects every implementation: `@SO3Fun`,
`@SO3FunRBF`, `@SO3FunCBF`, `@SO3FunBingham`, `@SO3FunHarmonic`,
`@SO3FunComposition`. Fix either by detecting an option string in position 3
and shifting it into `varargin`, or by dropping `r` from the positional API.

Separately, `@SO3FunComposition/radon` only sums the component transforms and
has no final antipodal check of its own, unlike `@SO3Fun/radon.m` and
`@SO3FunRBF/radon.m`. `varargin` is forwarded, so it works as long as every
component type implements that logic — there is no safety net if one does
not, which was exactly the situation for `@SO3FunCBF` until 2026-08-06.

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
numbers nobody reads. Note that fixing T3 makes the suite slower, since
`'subsample'` runs a `linprog` per node.

### C-empty
Fourteen chapters are wired into a `.toc` and therefore publish as a visibly
empty page — a title and nothing else. The sidebar entry is the reminder.
Found by the 2026-07-28 doc audit, `docs/doc-audit-plan.md` item 5.

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
