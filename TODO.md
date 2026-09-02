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
ignoring `'bandwidth'` once it reached them. A third pass closed E1 and E2 —
neither was the `calcUnitCell` bug it was filed as; the real defect is the
new E15, a shift that expands the vertex list instead of translating it.

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
| P14 | **`gridify` by default** — **implemented 2026-08-12** in `0fcb33a32`: `EBSD.load` grids whenever that loses no measurement, opt out with `'noGrid'` or `setMTEXpref('gridifyOnImport',false)`. G7 closed with it. Documentation rewritten 2026-08-13, see C0 | 2 | 0 | done | — | #2295, #2167, #2128, [→](#p14) |

---

## G. Grain reconstruction and boundaries

| # | Item | U | Sz | Status | Owner | Refs |
|---|------|:-:|:--:|--------|-------|------|
| G1 | Grain boundary smoothing that uses the band contrast | 1 | 1 | planned | Vivian | br/smoothBoundary |
| G2 | `ebsd = smooth(ebsd)` should fill pixels with `orientation == NaN` | 2 | 1 | planned | — | #192 |
| G3 | `smooth` should work on gridded data and return gridded data; what to fill and what not decided by `grainId`, not by the caller | 2 | 1 | planned | — | — |
| G4 | Faster `EBSD/smooth` — not per grain | 1 | 1 | idea | — | — |
| G5 | `minPixel` culling can isolate a pixel from its true grain, producing a malformed single-pixel grain | 2 | 1 | bug | — | #2574 |
| G6 | `minPixel` is ignored when alpha shapes are used — **fixed 2026-08-12** in `8a3f98703`: neither alpha-specific nor an outright ignore, but a systematic under-cull on every square map, since the Delaunay-only sizing pass runs 8-connected where the segmentation is 4-connected | 2 | 0 | done | — | #2513 |
| G7 | `calcGrains(EBSD(ebsd))` and `calcGrains(ebsd.gridify)` disagree — **fixed 2026-08-12** in `6f95f63b1`: `gridify` pads empty lattice sites with `phaseId = NaN`, which compares false against every phase, so every criterion scored a pad cell 0 against its neighbours and each became its own single-pixel grain. Normalised in `grainBoundaryCriterion/eval`. Indexed grains were never affected | 3 | 0 | done | — | #2295, [→](#p14) |
| G8 | `calcGrains` errors after `interp` — **not reproducible** on a synthetic map after the `interp` rewrite (2026-08-12: interp to half the step, 14641 points, 89 grains, no error); the reporter's own 50x50 map is attached to the issue and has not been tried | 2 | 0 | triage | — | #1870, [→](#g8) |
| G9 | Grain polygons that enclose a **negative** area, i.e. rings traced inside out — **fixed 2026-08-12**: the vertex rewrite in `removeQuadruplePoints` was row wise, so an edge shared by two neighbouring quadruple points lost one of its two writes and the grain whose corner was cut there was left with an open boundary walk. Not the mex, not the `atan2` branch cut. `steel1C_1` 2 → 0, open walks on forsterite/martensite/epidote/mylonite 2/2/2/6 → 0, see [→](#g9) | 2 | 2 | done | — | #2590, #2076, [→](#g9) |
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
| G41 | `assignGridIndex` was order dependent on a distorted map — **fixed 2026-08-13**: the walk trusted the outer component of a step outright, so a line change carried a whole line's worth of accumulated drift into it. The outer step is now measured against a drift model, the mirror of the inner one. Grid order goes from exact at 0.05% distortion to exact at 10%; file order and every undistorted map are bit identical | 3 | 0 | done | — | [→](#g41) |

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
| E1 | `ebsd.unitCell = calcUnitCell(xy)` stored a raw double — **fixed 2026-08-12** with a `set.unitCell` on `@EBSD` that converts, and `calcUnitCell` no longer returns a NaN cell for a single scan line | 2 | 0 | done | — | #2531, [→](#e1) |
| E2 | `calcUnitCell` breaks when the map's xy is far from the origin — **not `calcUnitCell`**, it is exact to 1e5 units out; the reproduction's `ebsd + [x y]` was the defect, see E15 | 2 | 0 | done | — | #1722, [→](#e2) |
| E3 | `gridify` and the ungridded EBSD report different point counts — **not a defect**, `gridify` re-inserts the scan positions the input is missing; a complete map keeps its count exactly (checked 2026-08-12) | 2 | 0 | done | — | #2167, [→](#e3) |
| E4 | `ebsd.gridify.phase` came back as a list while everything else on the object was the map — **fixed 2026-08-12**, the `phase` getter now takes the object's shape the way `isIndexed` already did | 2 | 0 | done | — | #2128, [→](#e4) |
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
| E15 | Shifting a `grainBoundary` / `triplePointList` silently expanded its vertex list instead of translating it — **fixed 2026-08-12**; the obsolete `obj + [x,y]` form, which expands the same way, is now rejected and gone from the docs | 3 | 0 | done | — | [→](#e15) |

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
| O6 | `vector3d` constructor is inconsistent across input shapes — **fixed 2026-08-12**, Ralf's call: an `N x 3` matrix now gives an `N x 1` list, `3 x N` still gives `1 x N`, `3 x 3` warns and is read column wise | 2 | 0 | done | — | #2145, [→](#o6) |
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
| F4 | `plotSection(mdf,'axisAngle')` segfaults on a cross-phase misorientation at bandwidth ≥ 32 — **fixed**, does not reproduce on 2026-09-02 | 3 | 1 | done | — | [→](#f4) |
| F5 | `'logarithmic'` was ignored by `plotPDF` — **fixed 2026-08-12**, `@vector3d/smooth` tested only for the short spelling `'log'` | 2 | 0 | done | — | #1691 |
| F6 | Filled contours extend past the edge of the pole figure — **reproduced and half diagnosed 2026-08-12**; the `'cutOutside'` guard is inert, for two independent reasons, and the second needs a decision on how far a partial pole figure may be extrapolated | 1 | 0 | decide | — | #707, [→](#f6) |
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
| L1 | The scale bar moves depending on the plotting convention — **already fixed** by the scaleBar rework that reads the convention back from the camera; measured 2026-08-12 across four conventions x four `Location` corners and the reporter's own preference pair, and pinned in `check_scaleBar` | 2 | 0 | done | — | #2576, [→](#l1) |
| L2 | Sigma sections ignore the plotting convention — **they do not**; measured 2026-08-12, the section follows `odf.SS.how2plot`. What the report actually shows is that data keeps the convention it captured at construction, so changing the default afterwards does not reach it — that is L4 | 2 | 0 | done | — | #2093, [→](#l2) |
| L2b | `setMTEXpref` had three preferences `getMTEXpref` could not read back — **fixed 2026-08-12**, `xyzPlotting`, `xAxisDirection` and `zAxisDirection` are held by the plotting convention, not by the appdata group | 2 | 0 | done | — | [→](#l2) |
| L3 | `histogram(grains.longAxis)` ignores the plotting convention — **fixed 2026-08-12**; it does follow it, but `setView`'s polaraxes branch measured the angle the wrong way round, so `x↑→y` came out rotated by exactly 180° | 2 | 0 | done | — | [→](#l3) |
| L4 | General plotting-convention oddities; `setMTEXpref('xAxisDirection',...)` has no effect | 3 | 1 | bug | — | #2014, #2096 |
| L5 | Crystal shapes do not follow the EBSD data when it is rotated or the convention changes | 2 | 1 | bug | — | #1952 |
| L6 | Colour keys in specimen coordinates should respect the plotting convention — better, `colorKey(what2color)` should take what it needs from the object | 2 | 1 | planned | — | [→](#l6) |
| L7 | `directionColorKey` bug | 1 | 0 | triage | — | #2515 |
| L8 | IPDF plots arrows incorrectly — **fixed 2026-08-12**, `arrow` sizes its head in pixels regardless of the segment, so on the short segments arrows are meant for the head was longer than the arrow; now capped at 0.4 of the segment | 2 | 0 | done | — | #2072, [→](#l8) |
| L9 | `ipfKey.inversePoleFigureDirection` should probably be `outOfPlane` | 1 | 0 | decide | — | — |
| L10 | `plot(ebsd,ebsd.orientation,'ipfDirection',xvector)` should work | 1 | 0 | idea | — | — |
| L11 | The IPF colour key disk cache is keyed only by point-group id, so it silently serves a stale table when the crystal frame changes — **fixed** in `3767b60b9`/`556c0b469`: the cache is in memory and keyed by a digest of the sector geometry and white centre, and `removeObsoleteCacheFiles` deletes what earlier versions left in `prefdir` | 3 | 0 | done | — | [→](#l11) |
| L12 | Colorbar at `'northoutside'` was placed below — **fixed 2026-08-12**; `'westoutside'` was equally broken. The side is kept in `mtexFig.cBarSide` and honoured by `calcTightInset`/`updateLayout` | 1 | 0 | done | — | #1744 |
| L13 | ODF subplots get different colormaps — **not a defect**: `mtexColorMap(ax,...)` on a single axes handle gives distinct colormaps, while the bare form deliberately covers every axes of the figure. `mtexColorMap` had no help at all, which is the actual gap; written 2026-08-12 | 1 | 0 | done | — | #1732 |
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
| L27 | `vector3d`'s own plot commands still pass `'doNotDraw'` to `newSphericalPlot` and lay out themselves at the end — the shape the eleven figure-building commands had before they were given a `layoutHold`. Give each a hold instead and drop the option: `plot`, `scatter`, `smooth`, `surf`, `quiver`, `circle`, `text` | 1 | 0 | planned | — | br/mtexLayout, [→](#l27) |
| L28 | `plotSeismicVelocities` builds five axes and ends in no `drawNow` at all, so it relies on the per-plot layouts and carries 14 `'doNotDraw'` to suppress them. It cannot take a `layoutHold` until it has a final `drawNow` to release into, and adding one changes the size the figure comes out | 1 | 0 | planned | — | br/mtexLayout |
| L29 | `@mtexLayout` — the `@mtexFigure` layout split into measure/solve/apply, the arithmetic a pure function testable without a figure. **Not verified against the documentation**: no doc page has been rendered under it, and R2026a has not been tried | 2 | 1 | wip | — | br/mtexLayout, [→](#l29) |

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
| C0b | **Four pages broken by gridify-on-import, fixed 2026-08-13** — `CrystalShapes` (the `ebsd(x,y)` meaning flip), `ODFTheory` (`reduce(ebsd,4)` on a hex grid), `LowLevelParentGrainReconstruction` and `MaParentGrainReconstructionAdvanced` (`phaseId` column vs map-shaped `grainId`). Two were code defects, not page defects, see [→](#c0b) | 3 | 0 | done | — | [→](#c0) |
| C0c | **Decide: should `ebsd.phaseId` be map shaped on a grid?** — it is the one per-pixel view that stays a column while `id`, `rotations`, `pos`, `isIndexed`, `phase` and every prop are the (r x c) map (#2128, pinned by `check_ebsdGrid/checkGridShapes`). Any user expression mixing `phaseId` with a prop therefore errors, which is what broke both parent-reconstruction pages. Now that an import returns a grid by default this is the common case, not the exotic one | 2 | 2 | decide | — | [→](#c0b) |
| C0 | **Document `gridify` by default** — **done 2026-08-13.** `EBSDGrid.m` rewritten around the imported map already being a grid, with the `'noGrid'` flag, the `gridifyOnImport` preference, the `MTEX:load:notOnGrid` case (eclogite) and the reordering note; a matching section in `EBSDImport.m`; stale claims fixed in `EBSDIndex.m`, `EBSDInter.m`, `Plasticity/GND.m`, `Plasticity/WBV.m`; changelog entry added. Every touched page was executed. Two defects found on the way, see [→](#c0) | 2 | 0 | done | — | [→](#p14) |
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

**Decided and implemented 2026-08-12.** `EBSD.load` now grids the data
whenever that is lossless, and refuses when it is not: the raster is bounded
before it is built (a stray position asked for a 35201 x 35201 lattice),
`gridify` runs inside a `try`, and the result is kept only if no indexed
measurement was dropped. `eclogite.ctf` fails that last test - 613 indexed
measurements over 565 lattice cells - and comes back as a plain list with a
`MTEX:load:notOnGrid` warning. Opt out per call with `'noGrid'`, globally
with `setMTEXpref('gridifyOnImport',false)`.

G7 was fixed on the way and separately (`6f95f63b1`): the two representations
disagreed because `gridify` pads empty lattice sites with `phaseId = NaN`,
which compares false against every phase, so every criterion scored a pad
cell 0 against its neighbours and each became its own single-pixel grain - a
solid 5841 cell hole gave 5842 notIndexed grains instead of 6. Normalised in
`grainBoundaryCriterion/eval`. The indexed grain count was never affected,
which is why it stayed hidden.

Note the reproduction above no longer distinguishes anything: after
`a5bc0f427` a plain list, a column major and a row major gridded map all give
3100 / 2905 / 2109862.588230 on forsterite. What remains is that gridding
REORDERS the measurements and cannot avoid it - the layout fixes dim 1 to y
while a .ctf runs x fastest - documented in `gridify`'s help. `calcGrains` is
invariant under that; `removeQuadruplePoints` is not, see G9.

### G41
Found 2026-08-13 while rewriting the gridify documentation. The two objects
below hold the *same set* of positions and derive the *same* lattice basis
`[0.3 0; 0 0.3]`; they differ only in the order of the list.

```matlab
fn = [mtexDataPath filesep 'EBSD' filesep 'twins.ctf'];
a = EBSD(mtexdata('twins','silent'));          % grid order, i.e. after gridify
b = EBSD.load(fn,'noGrid', ...
      'EulerCorrection',rotation.byAxisAngle(xvector,180*degree)); % file order

% same 5% trapezoidal drift on both, then look at the recovered indices
%   file order : I 0..166, J 0..136, 22879 unique cells of 22879   correct
%   grid order : I 0..174, J 0..136, 22593 unique cells of 22879   286 collide
```

The consequence is silent: `gridify` writes the measurements with
`mesh(ind) = pos`, so each of the 286 collisions loses one of its two
measurements and the surviving one sits a full step (0.3 µm) away from where
it was measured. `calcMesh`'s deformation branch is not at fault — it was
already fixed for order dependence, and it is handed the wrong `ind`.

Only *distorted* maps are affected; an undistorted one takes the ideal-grid
branch and is exact in either order. That is why nothing caught it before:
`check_gridify/checkDistortedGrid` is the only test that distorts a real map,
and until `EBSD.load` started gridding, `mtexdata('twins')` handed it the file
order, which happens to be the order that works.

Not caused by the gridify-on-import work, only exposed by it. The collision is
invisible precisely because a repeated index keeps the last write.

**Fixed 2026-08-13.** `stepwiseIndex` trusted the outer component of every step
outright. That is fine while the distortion runs along the *inner* direction —
which is measured cell by cell and was already drift-corrected — but a line
change undoes a whole line of inner travel in one step, so any drift the outer
coordinate picked up along that line rides along with it. The outer step now
gets the mirror of the inner treatment: the sub-cell part of the outer component
of every trusted single-cell step is the drift per inner cell, fitted across the
map by the same regression, and subtracted in proportion to the inner distance a
step actually covers. That corrects a multi-cell gap *within* a line as well as a
line change, with no need to tell them apart.

Two traps found while building it:

- the drift must be read off `outerRaw - round(outerRaw)`, never off `outerRaw`.
  A hexagonal map walked along its staggered direction moves a whole outer cell
  on every second step, so the raw components alternate 0 and -1; taken at face
  value that reads as half a cell of drift per inner cell on a *rigid* lattice,
  and multiplied by a line length it shattered the hex fixture in
  `check_calcGrainsCases` into 389 grains instead of 16.
- the regressor cannot be the accumulated outer index, which is exactly what a
  mis-rounded line change corrupts. It is now the outer coordinate read straight
  off the positions.

Measured on forsterite, highest trapezoidal drift at which `lattice.ij` is still
exact — full map / Forsterite / Enstatite / Diopside:

| order | before | after |
| --- | --- | --- |
| grid (y fastest) | 0.0005 / — / — / — | **0.10 / 0.05 / 0.02 / 0.02** |
| file (x fastest) | 0.49 / 0.20 / 0.20 / 0.20 | unchanged |

Grid order stays the weaker of the two by construction — a distortion along the
outer direction is modelled rather than measured — but 2% is still far beyond a
realistic stage drift. `check_gridDistortionBenchmark` now runs both orders and
pins the table above; it also had to stop reducing `ebsd.pos.x` without `(:)`,
since forsterite arrives map shaped now. `lattice.ij` is bit identical on all
seven bundled real maps in both orders, so grain reconstruction does not move and
no reference needed regenerating.

### G13
Note that FMC was rewritten on 2026-07-25 — saliency was dead code and
`quatmax` was chaotic; level-3 ARI went 0.84 → 0.95 at 2.7× the speed. #539
predates that rewrite and has not been re-checked against it. Re-verify
before spending time on it.

### G9
Reproduced 2026-08-12, by a different route than the original report:

```matlab
ebsd = EBSD.load('1C_1.ctf'); i = ebsd('indexed');
nnz(calcGrains(i).area < 0)                            % 0 of 104814
nnz(calcGrains(i,'removeQuadruplePoints').area < 0)    % 2 of 99875
```

`nnz(grains.area < 0)` is the detector; a negative area means the ring was
traced inside out, and `area`, `equivalentRadius`, `smoothBoundary` and every
plot then read a polygon that is not the grain.

Not the mex, contrary to #2076: forcing the MATLAB `calcPolygons` on the same
input gives **6** where `calcPolygonsC` gives **2**, so both tracers are being
handed a boundary graph that does not close and merely disagree about how to
fail on it. Not `minPixel` either - `'removeQuadruplePoints'` alone is enough -
and not new, the count is unchanged at `059ff152a`.

**Root caused and fixed 2026-08-12, and it is not the branch cut.** Splitting a
quadruple point rewrites the shared vertex of two of its four edges to a
duplicate, and that rewrite was row wise over all quadruple points at once:

```matlab
Ftmp = Fext(iqF(orderSub(1)),:).';
Ftmp(Ftmp == quadPoints.') = newVid;
Fext(iqF(orderSub(1)),:) = Ftmp.';    % repeated row -> only the last write survives
```

Two quadruple points that are neighbours share the edge between them, so that
edge is in the relocation list of both, and MATLAB keeps only the last write for
a repeated row. One rewrite is silently lost: the edge keeps the original vertex
where it should have taken the duplicate, the quadruple point ends up with three
of its four edges and the duplicate with one, and the grain whose corner was cut
there has an **open path** instead of a closed ring. `EulerCycles` closes every
walk it returns by repeating the first vertex, so the breakage never surfaces as
an error - it surfaces as a polygon that is not the grain. Fixed by assigning
element wise (`sub2ind`); the two writes to a shared edge touch its two
different endpoints, so nothing collides.

Measured, same data cache, `threshold` 5 degree, grains with an open boundary
walk before -> after: forsterite 2 -> 0, martensite 2 -> 0 (and its one negative
area -> 0), epidote 2 -> 0, mylonite 6 -> 0, `steel1C_1` 2 negative areas -> 0
with `nGrainsQP` and `totalLenQP` bit identical. The count of collisions
predicts it exactly - one collision breaks two grains.

On an ideal square grid the collision cannot happen: the shared edge points +x
at one quadruple point and -x at the other, and the angular sort puts those in
different relocation slots. It takes an irregular neighbourhood - a hole, a map
border - which is why real maps show it only a few times each.

Consequence for the reverted pairing work: **the conclusion in `4f351d38e` is an
artifact of this bug.** Re-applying `b2ca13189` + `14463616f` on top of the fix
gives `alphaBetaTitanium` at 1.5 degree **0** negative areas and 0 open walks
(was 117), 46230 grains, and only **1** negative area after
`smoothBoundary(...,5)` against **16** for the branch-cut pairing with the same
fix. The pairing can be decided per quadruple point after all, and doing so also
all but removes the smoothing induced breakage. **Both commits are back in the
tree** - see [→](#g9-followup).

Guarded: `check_calcGrainsCases` has a `checkClosedBoundary` helper asserting
that every vertex a grain's boundary uses is met by an even number of that
grain's segments - the sharp form, since testing `poly(1) == poly(end)` cannot
see an open walk - plus a 4x4 fixture with holes that fails on the unfixed tree.
The benchmark now pins `negAreaQP` at 0/0/0.

### G9-followup
**Done 2026-08-12:** `b2ca13189` + `14463616f` (deterministic pairing at a
quadruple point) are back, on top of the #2590 fix that removes the reason they
were reverted. What they buy: `removeQuadruplePoints` is no longer a function of
the order the measurements arrived in - shuffling `twins` used to move it
between 110 and 108 grains, and a gridified map disagreed with the same map as a
list - and smoothing induced negative areas on `alphaBetaTitanium` at 1.5 degree
drop from 16 to 1.

What they cost, all in the QP columns and all verified as the intended
direction: a matching diagonal is now found at every quadruple point instead of
roughly half of them, so more merge. `nGrainsQP` 2931 -> 2905 (forsterite),
99875 -> 97856 (`steel1C_1`), `alphaBetaTitanium` at 1.5 degree 52398 -> 46230;
copper has no mergeable quadruple point and does not move. `nGrains`,
`totalLen` and `meanArea` are unchanged on all three benchmark datasets, i.e.
the plain reconstruction is untouched. `steel1C_1.totalLenQP` goes -55.4 to
-76.3 against `totalLen`, which is the documented "merge also drops boundary
between two grains it joins that touch elsewhere" at a larger merge count;
`check_removeQuadruplePoints` still passes, and it asserts the non zero segment
lengths are identical with and without the option. Benchmark reference
regenerated.

Still open, and older than any of this: `sum(grains.area)` under
`removeQuadruplePoints` exceeds the plain sum by up to 0.08% (martensite at 10
degree, 85855.5 -> 85927.0), and it grows with the number of merges. Present
before the #2590 fix and before the pairing change, so it is neither's doing -
a merged grain that touches itself at a quadruple point apparently gets a
polygon slightly larger than the union of its parts. Worth a look, since every
per grain area on such a grain is wrong by that much.

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

### E15
`@grainBoundary/plus` and `@triplePointList/plus` shifted their vertices with

```matlab
if isa(xy,'vector3d'), xy = [xy.x,xy.y]; end
gB.allV = gB.allV + repmat(xy,size(gB.allV,1),1);
```

written when `allV` / `V` were an `n x 2` double. They are a `vector3d` now,
and `vector3d + numeric` adds the numeric to *each* of `x`, `y`, `z`
separately — so an `n x 2` matrix against the `n x 1` coordinate arrays
implicitly expands them to `n x 2`. `gB + vector3d(10,0,0)` on `twins` came
back with `allV` of size `[3723 2]` and an x range of `9.85 .. -0.15` where
the input spanned `49.95 .. 59.95`. No error, at any point.

The obsolete numeric form, `obj + [100,0]`, expands identically (a `1 x 2`
row) and hit `@EBSD` as well. That is what issue **#1722** actually
reproduces: `ebsd + [-3500 10]` on `single` returned a map with twice the
measurements, spread over a 3500 unit range in all three coordinates, and
`gridify` of it then asked for a 35201 x 35201 lattice — 30 GB, i.e. the
machine, not a `calcUnitCell` bug. `calcUnitCell` itself returns the exact
0.1 x 0.1 cell at shifts of 10, 100, 1000, 3500 and 1e5 units; the
`'DataScale',1` now passed to `uniquetol` is what fixed the originally
reported cause.

Fixed by shifting the `vector3d` directly in all four classes and rejecting
anything else with `MTEX:shift:invalidShift`, and by removing `obj + [x,y]`
from the `plus`/`minus` docstrings of `@EBSD`, `@grain2d`, `@grainBoundary`
and `@triplePointList`. `@triplePointList/plus` also tested `isa(v,
'triplPointList')` — misspelled, so the operands were never swapped.

Verification: `tests/core/check_spatialShift.m`, which asserts on the
positions and on the shape of the coordinate arrays, not just on the point
count — `size(gB)` reads the segment list and does not see the expansion.
Also pins that the lattice index range is unchanged by a far shift, which is
where #1722 actually goes wrong.

### F6
Reproduced 2026-08-12. A `Miller(1,1,1)` pole figure of a cubic ODF sampled
only to a polar angle of 60 degree, plotted with `'contourf'`: of the 22021
plotting grid nodes inside the hemisphere, **6498 lie beyond the measured
region and every one of them is given a value**. At 45 degree it is 10108 of
10108. A fully measured hemisphere has 0, so the padding itself is not the
problem — the values really are smeared out to the edge.

`@vector3d/smooth.m:52` already asks for the remedy, `interp(...,
'cutOutside', ...)`, and `@vector3d/interp.m` implements it. It is inert for
two independent reasons:

1. **The test is written along the wrong dimension.** It was
   `M(all(so(:,1:4)>delta),:) = NaN`, and `all` over an `n x 4` matrix
   without a dimension reduces down the COLUMNS, so it produced a `1 x 4`
   row that then indexed rows 1 to 4 of `M`. The per query point test never
   happened. Fixed to `all(...,2)`, which is unambiguously what the line
   means — but it changes nothing observable on its own, because of:

2. **`delta` is calibrated on a statistic the outliers pollute.**
   `delta = 4*quantile(minO,0.5)`, where `minO` is each *query* point's
   distance to the nearest datum — a set dominated by the very nodes the
   cut is meant to catch. Measured: **0 of 8507** nodes exceed it. A
   threshold derived from the data's own spacing, `v.resolution` (already
   computed a few lines above as `res`), is the obvious candidate.

Ralf's call on 2026-08-12 was to take the threshold from the data spacing,
`delta = k * v.resolution`. **Tried and reverted**, because the measurement
does not support any constant: on the 60 degree case, with
`v.resolution = 5.01` degree correctly reported, `k = 2` and `k = 4` blank
**all 8507** plotting nodes and `k = 6` still blanks 8401 of them. The
reason is that `angle_outer(vi,v)` reports a *median* nearest-data distance
of 75 degree and a maximum of 120 degree between an upper hemisphere query
grid and data covering the upper 60 degree cap — which is geometrically
impossible, since every query point within the cap has data within one
spacing of it. So the distances that both the old heuristic and any new one
are built on are not what they appear to be, and that is what has to be
understood first. Only the `all(...,2)` dimension fix was kept; it is a
no-op while delta stays as it is.

Note also that a symmetric pole figure legitimately constrains directions
outside the measured range, so once the cut works it has to be applied to
the *symmetrised* directions, not the raw ones.

### L8
`extern/arrow.m` measures its head in **pixels** — `Length` is documented as
"length of the arrowhead in pixels" and defaults to 16 — and takes no notice
of how long the segment is. Chaining arrows through a series of nearby
orientations, which is what the option is for, gives segments only a few
pixels long, so the head is longer than the whole arrow and sticks out past
its tip.

Measured on the pair from the report, whose two points are **0.0096** apart
in the plot:

| head length | patch extent |
|---|---|
| default (16 px) | **0.0279** |
| 6 px | 0.0105 |
| 2 px | 0.0096 |
| 0 px (bare shaft) | 0.0096 |

So the drawn patch was nearly three times the arrow it represents. That also
explains the reporter's own finding that zooming in about 6x fixes it and
less zoom fixes it partially — zoom changes exactly this ratio, since the
head is constant in pixels while the segment grows.

`@vector3d/scatter`'s arrow branch now caps the head at `0.4 *` the segment
length in pixels when the caller did not ask for a `'length'`, so a segment
long enough to carry the full 16 pixels is drawn exactly as before and a
short one keeps its head inside itself. An explicit `'length'` still wins.

Owning test `tests/plotting/check_arrowPlot.m`, which takes `'length',0` —
the bare shaft — as the reference segment rather than trying to recover the
two measurements from the markers, since those also carry the sector
corners.

### L3
`vector3d/histogram` does hand the convention to
`plottingConvention/setView`, whose polaraxes branch sets
`ThetaZeroLocation` and `ThetaDir`. It took

```matlab
round(angle(pC.east,xvector,zvector)/degree)
```

i.e. the angle *from east to x*, while `ThetaZeroLocation` asks where
`theta = 0` — the x axis of the data — is *drawn*, which is the angle the
other way round, `atan2(<x,north>,<x,east>)`. The two agree at 0 and 180
degree and swap top and bottom, so three of the four axis aligned
conventions looked right and only `x↑→y` was wrong — by exactly 180 degree.

Measured as the on screen angle of a tight cluster of directions, resolving
`ThetaZeroLocation` and `ThetaDir` back into an angle (it is their
combination that decides what the reader sees):

| convention | x lands / wanted | y lands / wanted |
|---|---|---|
| `y↑→x` | 0.6 / 0 | 90.7 / 90 |
| `y↓→x` | 0.3 / 0 | 270.7 / 270 |
| `x←↑y` | 180.0 / 180 | 90.4 / 90 |
| `x↑→y` | **270.0 / 90** | **180.2 / 360** |

New owner `tests/plotting/check_polarHistogram.m`.

### G8
Not reproducible as of 2026-08-12: interpolating `small` onto half its step
with a `meshgrid` and running `calcGrains` gives 89 grains from 14641 points
with no error. `@EBSD/interp` was rewritten since the report (see `bugs.md`
item 7 — `scatteredInterpolant` replaced by a local nearest-within-the-cell
test), and the reported "Index exceeds the number of array elements" is the
shape of failure that rewrite removed. The reporter's own 50x50 cutout is
attached to the issue as `no5_02um.zip` and has **not** been tried; that is
what would close this rather than leave it in triage.

### L2
Measured 2026-08-12 with an asymmetric `unimodalODF`, reading the peak
position off the first section's contour:

| what was changed | peak |
|---|---|
| `odf.SS.how2plot` out of screen | (+0.5913, +1.0242) |
| `odf.SS.how2plot` into screen | (-0.5913, +1.0242) |

So `plotSection(odf,'sigma')` **does** follow the convention — `pfSections`
passes `oS.SS.how2plot` into both `plotS2Grid` and the reference field.

What #2093 really runs into is that the convention is captured when the data
is constructed, not read at plot time: the report builds `odf` once and then
changes the preference, and `orientation.byEuler(...,cs)` had already taken
`specimenSymmetry.default` as it stood. `plottingConvention.matchDefault`
exists precisely so that data plotted the default way keeps referring to the
one default instance and does follow later changes, but data given an
explicit convention does not. That propagation question is L4, not a sigma
section defect. It is made harder to reason about by `plottingConvention`
being a handle class, so the report's `xyzPlot.intoScreen = zvector` mutates
the very object anything holding it already refers to — see
`plottingconvention-eq-and-default-frame` in the agent memory.

Found while measuring it, and fixed: `setMTEXpref` translates
`xyzPlotting`, `xAxisDirection` and `zAxisDirection` into a call on the
plotting convention instead of storing them in the appdata group, and
`getMTEXpref` knew nothing about that - it looked them up in the group,
found nothing and returned `[]` while the setting was in effect.
`getMTEXpref('xyzPlotting')` returned a `double`. All three read back now; a
convention no axis is aligned with reports `''` for the two axis directions,
since there is no such setting to name. New owner
`tests/core/check_mtexPref.m`.

### L1
Measured 2026-08-12 on `small`, projecting the bar's box centre onto the
convention's `east`/`north` (the axes `XDir`/`YDir` stay `normal` for every
convention — the view is applied through the camera, so a data space
measurement says nothing about where the bar appears):

| convention | east | north | corner |
|---|---|---|---|
| `y↑→x` | -0.87 | -0.83 | south west |
| `y↓→x` | -0.87 | -0.83 | south west |
| `x←↑y` | -0.87 | -0.83 | south west |
| `x↑→y` | -0.87 | -0.83 | south west |
| `xAxisDirection` west + `zAxisDirection` outOfPlane | -0.87 | -0.83 | south west |

The last row is #2576's own reproduction. The ruler also runs along screen
east (dot 1.00) with the label unrotated in all four, and `'Location'`
reaches all four corners correctly. So the report is answered by the
rework in which the bar reads the convention back from the axes camera; it
was never given a regression test, which it now has.

### O6
Measured before the change: `vector3d(3 x N)` → `1 x N`, `vector3d(N x 3)` →
`1 x N` (anything not already `3 x N` was transposed into it),
`vector3d(3 x 3)` → `1 x 3`, while `vector3d.byXYZ(N x 3)` → `N x 1`. So the
bare constructor accepted an `N x 3` matrix and returned the right
coordinates in the wrong orientation, silently, and disagreed with `byXYZ`
on the same input.

The contract now is that a matrix keeps the row / column correspondence of
the three argument form: `3 x N` is one vector per column and gives a row,
`N x 3` is one per row and gives a column. `3 x 3` satisfies both, so it
warns (`MTEX:vector3d:ambiguousMatrix`) and is read column wise, i.e.
unchanged; a matrix that is neither errors with `MTEX:vector3d:wrongSize`
instead of being transposed into shape.

Blast radius in tree is one call site, not nil as the commit message says —
that audit grepped for a single *identifier* argument and so missed
bracketed ones. `@grain2d/checkInside` builds `[xy zeros(n,1)]`, a genuine
`n x 3`. The orientation change is harmless there (`in` is assigned into a
column slice either way), but for exactly **three** query points that matrix
is also `3 x 3` and would now warn, so the call was moved to
`vector3d.byXYZ`, which reads rows unconditionally.

New owner `tests/core/check_vector3d.m` — there was none for the class the
whole geometry chain is built on.

### E4
Measured on gridified forsterite, `336 x 732`: `id`, `rotations`, `pos`,
`isIndexed`, `mad` and `bc` all came back `[336 732]`, `phase` and `phaseId`
came back `[245952 1]`. So `phase` was the single per-pixel view a sliding
window analysis indexes by `(row,col)` that could not be — which is what
#2128 reports as "different size outputs between 5.10.2 and 5.11.2".

`phaseId` is the storage and stays a column: `phaseList/length`, `numel` and
`end` all read `size(phaseId,1)` and `@EBSD` overrides only `size`, so
reshaping the property itself would make `numel(grid)` 336 rather than
245952. The fix is on the dependent `get.phase`, which now reshapes to
`size(pL)` exactly as `get.isIndexed` in the same file already did. Guarded
on `numel(phase) == prod(size(pL))`, because a `@grainBoundary` stores a
phase on each side — an `n x 2` `phaseId` against an `n x 1` object — and has
to keep its columns.

### E3
Not a defect. On forsterite: the complete map is `length(ebsd) = 245952` and
`numel(ebsd.gridify) = 245952`, unchanged. The counts differ only when the
input has holes — `ebsd('indexed')` is 187467 points and gridifies to 245952
— which is what `gridify` is for: it re-inserts the missing scan positions as
notIndexed so the map is a full rectangle. Same for a map that has been
through `interp`. Worth a sentence in the `gridify` help rather than a code
change.

### E1
`calcUnitCell` returns an `n x 2` list of coordinates while `ebsd.unitCell`
is a `vector3d`, so the documented recompute `ebsd.unitCell =
calcUnitCell(xy)` stored a raw double that every later reader of the property
tripped over, far from the assignment. The conversion existed in exactly one
place, `EBSD.loadobj`, and in the local `setUnitCell` of `updateUnitCell`;
it is now a `set.unitCell` on `@EBSD`, so the property cannot hold a double
whichever route wrote it.

Found on the way, from `bugs.md`: `calcUnitCell` returned a cell with a **NaN
side** for a single scan line. The coordinate that does not vary leaves
`uniquetol` a single value, so `mean(diff(...))` is NaN and `regularPoly`
propagates it. Reached by ordinary code — `check_ebsdGrid`'s own
`makeMultiPropMap` fixture is a single line and was carrying a NaN unit cell
the whole time. Now the spacing is taken from the direction the line does
extend in.

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
Fixed. The recipe below was a hard crash, not a MATLAB error, needing both a
differing left/right symmetry and bandwidth ≥ 32:

```matlab
ebsd = mtexdata('forsterite'); grains = calcGrains(ebsd);
mdf = calcDensity(grains.boundary('Fo','En').misorientation,'halfwidth',5*degree);
mdf.bandwidth = 32;  plotSection(mdf,'axisAngle')
```

It draws on 2026-09-02, at bandwidth 25, 32 and 48, over 11751 Fo-En segments
on R2024b - and at the `mtex-7.0.0` tag as well, so the fix predates that tag
and no commit here can be named for it. `MisorientationDistributionFunction.m`
plots the cross-phase MDF at a 90 degree section and passes the doc sweep.

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

### L27
Every plot command ends by laying the figure out, so a command that builds a
figure a plot at a time lays it out once per plot and throws all but the last
away. `plotPDF` of three pole figures called `drawNow` thirteen times — three
each from `newSphericalPlot`, `vector3d/smooth`, `vector3d/text` and
`mtexTitle` — and measured the axes seventeen times to produce one figure.
`layoutHold(mtexFig)` suspends the layout and returns an `onCleanup` that
resumes it; holding while building took that to five measurements and 3.88 s
to 2.16 s. Take the hold **after** any early return, since releasing does not
lay out — the `drawNow` the command already ends with does.

`vector3d`'s commands are the ones left. They are entry points, so each needs
its own hold rather than inheriting one, which is why they were not done with
the other eleven. `crystalShape/plot`, `crystalSymmetry/plotHKL`+`plotUVW`
and `symmetry/plot` are in the same position. `crystalShape/plot` is the one
to be careful with: there `'doNotDraw'` also means "you are a guest in this
axes" and gates `layoutCrystal`, which sets up a standalone 3d view —
`view(3)`, `vis3d`, axes off, the rotate widget — and must not run when the
shape is an overlay on a map.

### L29
Measured on R2024b: `check_mtexLayout` covers the grid, aspect ratio,
reserved bands and all four colorbar and legend sides in 70 ms with no figure
open. A settled layout writes nothing — `apply` skips any position within
half a pixel — so relaying an unchanged figure went 14-107 ms to 0.3-3.1 ms.
The unconditional second pass in `drawNow` is gone; every fixture converges
in one.

Against the legacy layout, `tests/lib/layoutFixtures` agrees to 0-4 px on
axes and legends. Colorbars differ by 3-8 px on purpose: a bar now hangs off
the bounding box of the axes the way a legend always has, clear of the
decorations on its side — hung off the axes box itself it drew over the
title, and `plotPDF` lost its (100)/(110)/(111) labels. `odfSections` comes
out about 14% larger, which Ralf accepted 2026-08-26.

What is not done is the part that matters most for a layout change: no
documentation page has been rendered under it. The layout only ever fails in
ways that show up as a figure, and every doc image so far was produced by the
old one. Two fixtures shifted 1-2 px in the last commit, so it is not
bit-identical to the rest of the branch either.

Do not retry replacing the text-extent round trip in `dataTextInset` without
reading `matlab_tightinset_zero_gotcha`: two arithmetic substitutions were
tried and both are wrong, one by 60 px and one by 106 px.

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

### C0
Done 2026-08-13. Beyond the gridify-by-default material itself, running the
pages turned up three things worth recording.

**The `mtexdata` `.mat` caches mask the whole feature.** `tools/mtexdata.m`
loads `data/<name>.mat` in preference to the source file, so on a machine
that has run MTEX before, `mtexdata twins` keeps returning the pre-branch
plain list and every rewritten page describes something the reader does not
see. The caches are gitignored derived data, so nothing in the repo records
the staleness. Regenerated here with `mtexdata(name,'force')`; a released
7.0 should either version the cache or drop it for EBSD sets.

**`loadEBSD_*` called directly bypasses the gridding.** The hook lives in
`EBSD.load`, so `mtexdata csl` and `mtexdata mylonite`, which call
`loadEBSD_generic` directly, still come back as plain lists while every other
sample set is gridded. Not wrong, but an inconsistency a user will notice.

**Two latent defects, neither reached by a doc page as written.**
`vector3d.byXYZ` on an *empty* matrix with other than three columns throws
"Coordinates have different size": the scalar `0` for z is repmat'd to
`1 x 1` while x and y stay `0 x 1`. `grain2d/checkInside` walks into it,
because for an @EBSD query it builds an `n x 3` and then appends a fourth
zero column at line 88 — which also silently discards z on every call. The
reachable symptom is `fill(ebsd,grains)` erroring whenever nothing is left to
fill: resampling copper onto a 2.5 µm square cell leaves 137 unfilled cells,
all outside the hull, so the query set is empty. Both are older than the
gridify work.

### C0b
Reported by Ralf against the rewritten docs, 2026-08-13. Four pages, three
distinct causes, two of which are code and not documentation.

**`ebsd(x,y)` silently changes meaning.** `@EBSD/subsind` reads two numeric
subscripts as a *position* and calls `findByLocation`; `@EBSDgrid/subsind`
reads them as *(row,column)*. `CrystalShapes.m` asked for the orientation at
(500,500) µm and got row 500 of a 97 row map, i.e. an out of range error.
The page now says `ebsd('xy',500,500)`, which selects the same pixel the list
form used to. **The dangerous case is not this one**: on a map with enough
rows and columns the positional form does not error, it silently returns a
different pixel. Every script written against pre-gridify MTEX that indexes
by position is exposed. Worth deciding whether the grid class should keep
overloading the same syntax at all.

**`@EBSDhex/reduce` took no factor** — it was written on the staggered matrix
subscripts and could only ever express `fak = 2`, so `reduce(ebsd,4)` in
`ODFTheory.m` raised "Too many input arguments" as soon as titanium started
arriving as an @EBSDhex. Deleted; `@EBSD/reduce` now selects on the lattice
index (`all(mod(ij,fak)==0,2)`) and scales the unit cell, which covers square
and hex, list and grid, rotated grids, and any factor in one implementation.
The list and the grid form now also agree pixel for pixel, which they did not
before: titanium/copper/ferrite/forsterite/twins at factors 2, 3 and 4 all
match exactly.

**`phaseId` is a column while every other per pixel view is the map.** Both
parent-reconstruction pages do

```matlab
parentGrains.phaseId(max(1,parentEBSD.grainId)) == x & parentEBSD.phaseId == y
```

which on a gridded map is an `(r x c)` against an `(r*c x 1)`. Flattened with
`(:)` in both pages, but the asymmetry itself is the real issue - see C0c.

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
