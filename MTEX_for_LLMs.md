# MTEX 7.0 for LLMs

**Paste this file into your chat before asking an AI assistant to write MTEX code.**

Most language models learned MTEX from documentation and forum posts written for
**MTEX 5.x**. MTEX 6.0 (10/2024), 6.1 (10/2025) and 7.0 (08/2026) changed a lot of that
syntax. Code written from 5.x memory will often still *run* — and silently do something
else. This file lists the differences.

> **Instruction to the assistant:** treat everything below as authoritative and as newer
> than your training data. Where this file and your recollection disagree, this file is
> right. Where it is silent, say so rather than guessing, and check with `help <command>`
> or the pages under `doc/`.

---

## 0. The short list

If you read nothing else, these are the ten things most likely to be wrong in generated code.

| # | Don't write | Write |
|---|---|---|
| 1 | `ebsd = gridify(ebsd)` after loading | nothing — `EBSD.load` already returns a grid |
| 2 | `ebsd(x,y)` for "measurement near (x,y)" | `ebsd('xy',x,y)` — two numeric subscripts now mean row/column |
| 3 | `[grains,ebsd.grainId] = calcGrains(ebsd('indexed'))` | `[grains,ebsd] = calcGrains(ebsd)` |
| 4 | `grains = smooth(grains,5)` | `grains = smoothBoundary(grains,5)` |
| 5 | `grains.grainSize` | `grains.numPixel` |
| 6 | `ebsd.how2plot = 'y↑→x'` | `plottingConvention.default('y↑→x')` — read-only on data |
| 7 | `ebsd.CSList{1}` | `ebsd.CSList(1)` — an array, not a cell array |
| 8 | `orientation(M,cs)`, `quaternion(M)` | `orientation.byMatrix(M,cs)`, named constructors |
| 9 | `ebsd.prop.x`, `ebsd.prop.y` | `ebsd.pos` (a `vector3d`); `ebsd.x`/`ebsd.y` still work |
| 10 | assuming y points **up** | the default is now **y down** (`y↓→x`) |

---

## 1. Reference frames — the one genuinely new concept

MTEX 7.0 introduces `@referenceFrame`: an object that answers *"which coordinate system is
this data expressed in"*. It carries an identity, named axes, and the plotting convention
its data is drawn in. `@crystalSymmetry` and `@specimenSymmetry` delegate their axes and
`how2plot` to the frame they hold.

Named specimen frames are session-wide instances:

```matlab
specimenFrame.specimen      % generic, axes X, Y, Z — the default
specimenFrame.measurement   % instrument frame, axes X1, Y1, Z1
specimenFrame.rolling       % RD, TD, ND — RD north, TD west
specimenFrame.geological    % N, E, D

specimenFrame.rolling.makeDefault   % maps, pole figures and micron bar now say RD/TD/ND
referenceFrame.reset                % back to the pristine state (for scripted batch jobs)
```

Every data class prints its frame in the display header, e.g. `EBSD (Y1↓→X1)` or
`PoleFigure (TD←RD↑)`.

**Consequences you must respect when generating code:**

- Mixing frames is an **error**, not a warning. An orientation applied to data already in
  specimen coordinates no longer "works".
- `rot * ori` acts in the specimen frame, `ori * rot` in the crystal frame. Either **drops
  the symmetry group** it destroys and keeps only the frame. In 5.x the product kept the
  group and merely warned (and the warning usually did not even fire — the test was a
  quaternion dot > 0.99, i.e. it let 16° through as "a symmetry element").
- Rotating an `@SO3Fun` or `@SO3VectorField` by a non-symmetry rotation likewise warns and
  drops the group. All twelve `rotate` methods now agree; they used to disagree for `2`,
  `m`, `-4` and every other non-centrosymmetric order-two group.
- Data with no symmetry can still name its frame: `crystalSymmetry(cF)` /
  `specimenSymmetry(sF)` build the trivial group on a frame, and `cs.stripSym` derives one.
- A `@crystalSymmetry` will no longer accept a `@specimenFrame` — that used to replace the
  lattice by the identity silently. It raises `MTEX:wrongFrameClass`.

### Plotting conventions

**The default changed to `y↓→x`** (x east, y south, z into the screen) — how SEM images are
displayed and what nearly every vendor states. If a script assumed y-up, its maps are now
mirrored.

There are exactly three ways to say how something is aligned on screen:

```matlab
plot(ebsd,'how2plot','y↑→x')        % this one plot            (new in 7.0)
plottingConvention.default('y↑→x')  % the whole session
ebsd.frame = specimenFrame.rolling  % move the data to a named frame
```

Conventions are strings: each axis followed or preceded by the direction it points on
screen — `'y↑→x'`, `'x←↑y'`, `'z⊙→x'`, ASCII `'y^->x'`. `plotx2east`, `plotzIntoPlane` and
friends still exist and still work. `plottingConvention.ij` is the new default.

`how2plot` is **read-only on every class except `@referenceFrame`**. Assigning it to a data
object (the 6.1 syntax) attached an invisible private copy of the session frame that then
silently stopped following it. Reading `ebsd.how2plot` is unchanged, and `ebsd.frame = []`
still means "follow the session again".

**Importing no longer changes how the session plots.** Loading a `.mat` file and `mtexdata`
used to repoint the session convention; they do not any more. Documentation pages that want
a particular alignment now say so explicitly.

### Frame annotations

Every spherical plot not given in crystal coordinates is annotated with its frame's axis
names (X/Y/Z, X1/Y1/Z1, RD/TD/ND). Plots in crystal coordinates keep Miller indices at the
sector vertices instead. Switch off per plot or per session:

```matlab
plot(vector3d.rand(100),'noLabel')
plot(ebsd,ebsd.orientations,'refFrame','off')
setMTEXpref('showRefFrame','off')
```

---

## 2. EBSD import

```matlab
ebsd = EBSD.load('data.h5')                       % no format guessing needed
ebsd = EBSD.load('data.h5','dataSet',2)           % or 'dataSet','Area 2'
ebsd = EBSD.load('data.h5oina','dataSet','EBSD')  % the recorded, not post-processed map
ebsd = EBSD.load('data.h5','headerOnly')          % phases, header and data set list
ebsd = EBSD.load('data.edaxh5','setting',3)       % override the assumed setting
ebsd = EBSD.load(fname,'noGrid')                  % keep it a plain list
```

- All HDF5 flavours go through one json-driven interface, `loadEBSD_h5`. A new vendor is a
  json description, not a new interface. `loadEBSD_hdf5` and `loadEBSD_h5oina` are retired
  to `obsolete/`, as are `loadEBSD_ACOM`, `loadEBSD_sor`, `loadEBSD_csv`,
  `loadEBSD_Oxfordcsv`.
- **Files holding several maps** (EDAX areas, Oxford slices, EMSphInx scans) list them on
  import and let you pick with `'dataSet'`; the path is kept in `ebsd.opt.dataSet`.
  Previously only the first was imported, without a word.
- Reference frame corrections are unified across `ang`, `ctf`, `crc` and `h5` and stored in
  `ebsd.EulerCorrection`. Oxford `h5oina` files state their map/camera misalignment
  (`Scanning Rotation Angle`, usually 180°) and MTEX now reads it — **orientations imported
  from h5oina change by that angle** and now agree with the same map from a `ctf`.
- `ang`/`osc`/`oh5`/`edaxh5` of the same map now agree with each other. EDAX crystal-axis
  alignment (x ∥ a) is available for any symmetry: `crystalSymmetry('321',[4.9 4.9 5.4],'EDAX')`.
- EMSphInx counts phases from 0 (EDAX from 1) and flags unindexed patterns by 255; that is
  handled, and `'EDAX'` / `'EMSphInx'` overrule the guess.
- File header in `ebsd.opt.header`, EDAX SEM/PRIAS images in `ebsd.opt.electron_image`.
- There is a working **import wizard**: `import_wizard`, which exports the import as a script.

Assumption notices are `warning`s with ids now, so
`warning('off','MTEX:eulerCorrectionAssumed')` silences them.

---

## 3. EBSD grids

**`EBSD.load` returns an `@EBSDsquare` or `@EBSDhex` whenever the measurements sit on one
lattice.** For nearly every real file, that means you get a gridded map and must not call
`gridify` yourself.

```matlab
ebsd('xy',x,y)   % the measurement closest to (x,y) — grid or list
ebsd(i,j)        % the pixel in row i, column j — gridded map only
```

**Two numeric subscripts are no longer a coordinate lookup.** On a plain list `ebsd(x,y)`
raises `MTEX:EBSD:ambiguousIndex`; on a gridded map the same expression is ordinary row /
column indexing. It used to mean "closest to the coordinate (x,y)" on a list and "row x,
column y" on a grid — with almost every file arriving gridded, that difference would be
decided by the data instead of by the script. Always write `ebsd('xy',x,y)` when you mean
the coordinate.

**Subsetting a grid gives back a list.** `ebsd('indexed')`, `ebsd('Forsterite')` and logical
masks return a plain `@EBSD`, because the selection is no longer a full raster. Re-`gridify`
if you need the matrix layout back. Several `mtexdata` sets are subsets and therefore also
arrive as plain lists — the "arrives gridded" rule is about `EBSD.load` on a real file.

**Gridding reorders the data.** The matrix layout fixes the first dimension to y, while a
`.ctf` or `.ang` runs x fastest, so `ebsd(k)` is generally *not* line k of the file. The
original ids are in `ebsd.oldId`.

- Both representations are accepted everywhere. `EBSD(ebsd)` and `gridify` convert at will.
- Data that would lose measurements by being gridded is never gridded and comes back as a
  list with a warning saying why. Turn gridding off globally with
  `setMTEXpref('gridifyOnImport',false)`.
- Both grid classes accept **rotated** grids. `@EBSDhex` no longer stores `dHex` or
  `isRowAlignment`; it derives them from the unit cell and pixel positions.

### Analysis no longer needs a grid

`gradientX/Y/Z`, `curvature`, `calcGND` and the gradient method of `weightedBurgersVec` work
on any `@EBSD` — plain list, phase subset or gridded map:

```matlab
kappa = curvature(ebsd)     % no ebsd.gridify needed
gnd   = calcGND(ebsd,dS)
```

They run on the virtual lattice derived from the unit cell, so rotated and sheared grids
work too (the old matrix implementation raised an error unless a grid direction lay along an
axis). `calcGND` now exists for hexagonal grids at all. `fill`, `smooth`, `interp` and
`weightedBurgersVec` keep the class and shape they were given.

---

## 4. Grain reconstruction

Entirely rewritten. Three parameters cover the common cases:

```matlab
[grains, ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',5,'alpha',3.1)
```

- `'angle'` — misorientation threshold
- `'minPixel'` — minimum number of pixels a grain must contain
- `'alpha'` — how far indexed regions grow into non-indexed ones (alpha shapes)

**The second output replaces the old `ebsd.grainId = ...` assignment.** Pixels belonging to
no grain — not indexed, or removed by `'minPixel'` — get `grainId == 0`. The old syntax
`[grains,ebsd.grainId] = calcGrains(ebsd)` still works but warns
(`MTEX:calcGrains:oldSyntax`).

Boundary criteria are objects of type `@grainBoundaryCriterion`, so any per-pixel property
can be segmented and every phase can get its own threshold:

```matlab
grains = calcGrains(ebsd,'angle',num2cell(thresholds))   % one per CSList entry
grains = calcGrains(ebsd,gbcCustom(ebsd.bc,10))          % segment by band contrast
grains = calcGrains(ebsd,'soft')                         % a soft threshold
grains = calcGrains(ebsd,'fmc',0.5,'minPixel',10,'verbose')
```

The criteria are `gbcAngle`, `gbcSoft`, `gbcFMC`, `gbcVariants`, `gbcCustom`.

⚠ A cell array of thresholds must have **one entry per element of `ebsd.CSList`** — which
includes the not-indexed entries, so it is usually more than the number of phases you can
see in the map. Anything else raises *"The number of thresholds does not match the number of
phases"*. Either pass a single threshold for all phases, or build the list from
`numel(ebsd.CSList)`.

Fast multiscale clustering (`gbcFMC`) — for deformed material where no single threshold
works — was rewritten: it judges clusters by misorientation against their own internal
spread, fits a lattice curvature so a bent grain is not mistaken for a scattered one, and
clusters each phase separately. Adjusted Rand index on a deformed-map benchmark went 0.84 →
0.96 at a third of the runtime. Note that `calcGrains(ebsd,'fmc',cmaha)` used to fall back
to plain angle thresholding **without saying so**.

Two related commands:

```matlab
gbnd = calcGBND(grains.boundary('Fo','Fo'),ebsd('Fo'),'halfwidth',10*degree)
gbcd = calcGBND(gB,grains('Fo'),moriRef)     % for a fixed misorientation
gbnd = calcGBND(grains3.boundary)            % 3d, specimen coordinates
[ebsd,grains] = cleanUpPseudoSym(ebsd,grains,mori,'threshold',1.5)
```

`calcGBND` (grain boundary normal distribution) supersedes `calcGBPD`. `cleanUpPseudoSym`
detects grains split by pseudo-symmetric indexing and reassigns the affected pixels.

---

## 5. Grain boundaries are ordered now

The segments of a `@grainBoundary` are no longer an unordered bag. They are sorted into
**chains** — maximal runs of segments joined at vertices where exactly two segments meet —
so consecutive segments share a vertex. Each chain occupies a contiguous block of rows and
is oriented so that the grain in `gB.grainId(:,1)` lies **to the left** of the walk
direction.

```matlab
gB = grains.boundary
gB.chainId, gB.chainSize, gB.isChainStart, gB.isChainEnd, gB.isClosed
gB.arcLength, gB.chainLength
gB.chainV                       % vertex ids, chains separated by NaN
```

This is what makes curvature signed and boundary simplification possible:

```matlab
gB    = flip(gB, gB.grainId(:,2) == grains(k).id)   % put grain k on the left
kappa = gB.curvature                                % positive bulges into column 2

grains = simplifyBoundary(grains,epsilon)  % Douglas–Peucker per chain
grains = reduceBoundary(grains,n)          % blunt: keep every n-th vertex
grains = refineBoundary(grains,delta)      % resample at equal arc length
tf     = isOuterBoundary(grains)           % which grains border the map
```

All of these keep junctions exactly where they are. `gB.reorder` is deprecated — segments
are already in walk order. `gB.V` now returns the two end points of every segment; the plain
list of all vertices is `gB.allV`.

### Smoothing

```matlab
grains = smoothBoundary(grains,5)
grains = smoothBoundary(grains,5,'noSimplify','noRefine')   % the 5.x behaviour
grains = smoothBoundary(grains,taubinFilter)
grains = smoothBoundary(grains,curvatureFilter('smoothingLength',3))
```

`smooth(grains)` is `smoothBoundary(grains)` now — `smooth` on an `@EBSD` denoises
orientations, something else entirely. The old name still works, still does the old thing,
and warns.

`smoothBoundary` performs **three** steps by default: simplify at `d/sqrt(2)` (d = pixel
spacing), refine, then the Laplacian smoothing it used to do alone. Because the first two
change the number of segments, switch them off wherever you read `gB.ebsdId` per segment.

Filters: `laplaceFilter` (default, unchanged), `taubinFilter` (unshrinks), `curvatureFilter`
(one sparse solve, knob is a *length* not an iteration count), `huberFilter` (keeps faceted
boundaries faceted).

---

## 6. Functions, sampling, approximation

```matlab
sF      = S2FunMLS(nodes,values,'degree',3)        % moving least squares on the sphere
SO3F    = SO3FunMLS(ori,values,'delta',5*degree,'detectOutliers')
ori     = optimalSample(odf,10000)                 % formerly compactify
[ori,c] = optimalSample(odf,500)                   % optimize the weights too
[c,center] = calcCluster(ori)                      % CLASSIX by default
odf     = calcODFIterative(pf,'halfwidth',5*degree)
```

- `optimalSample` replaces random sampling by an almost perfectly equidistributed set
  representing a given function. Points are moved by L-BFGS; `'method','steepestDescent'`
  restores the old plain gradient descent. It starts from an equispaced grid, so the count
  it returns is **approximately** the one you asked for — `optimalSample(odf,200)` gave 308
  in a test. Check `length(ori)` rather than assuming.
- `calcCluster` defaults to CLASSIX — much faster than hierarchical clustering, and needs no
  cluster count.
- `calcODFIterative` inverts pole figure data by iteratively adjusting the kernel width,
  which is far more robust for irregularly sampled data.

### Tangent spaces and vector-valued functions

A `@SO3TangentVector` stores the rotation and symmetries it is attached to, so switching
representation needs no second argument:

```matlab
t = odf.grad(ori); right(t)     % t knows ori
```

What used to be a *multivariate* function is now a **vector-valued** function
(`SO3FunVectorValued`), and arrays of them behave like any MATLAB array: `cat`, `reshape`,
`permute`, `squeeze`, `transpose`, indexing and assignment — previously `@SO3FunHarmonic`
only, now `@SO3FunHandle` and `@SO3FunRBF` too. `@SO3VectorField` supports `+ - .* ./`,
`dot` and `normSquare`.

Note that `*` is **not** pointwise for function classes: `SO3Fun`, `S2Fun`, `S1Fun` and the
kernel classes raise an error telling you to use `.*` or `conv()`.

Also new: `sqrt`, `smooth`, `invRadon` on `@S2Fun`; class `@S2FunGrid`; every `@S2Fun`
carries a symmetry and hence a `CS`, `SS` and `how2plot`; a spherical Fourier transform based
on the double Fourier sphere method (`NFSFT` default, bandwidth beyond 1023);
`doEulerStep(odf,vF,dt,'implicit')`; `expRight`/`logRight` on SO(3) and S²; derivatives of
`@S1Fun`; `@progressCounter`; `crystalSymmetry.default`; `colorcet` colormaps; `'zero2white'`.

---

## 7. What arrived in 6.0 and 6.1

Included because models trained before late 2024 miss these too.

**6.0 (10/2024)**

- **Full 3D grains.** Import 3D grain networks from Neper or Dream3D; `@grain3d`,
  `@grain3Boundary`, `@EBSD3`. See `Grains3DOperations` / `Grains3DProperties`.
- **Pseudo-3D 2D classes.** `@EBSD`, `@grain2d`, `@grainBoundary` are no longer confined to
  the xy-plane — an EBSD map can sit on any of the faces of a cube.
  - `ebsd.pos` is the measurement position and is a `@vector3d`
  - `grains.V`, `grains.centroid`, `grains.longAxis` are `@vector3d`
  - `ebsd.N`, `grains.N` give the map normal; maps with different normals cannot be merged
- `@plottingConvention` introduced; `'upper'`/`'lower'` refer to the out-of-screen direction.
- Neper interface, `'minPixel'` for `calcGrains`, ipf sections, `grains(id).V` returns only
  that grain's vertices, `dot(vF1,vF2)` for spherical vector fields, `'FaceColor'` colorizes
  crystal shapes by orientation, `transform2PolarReferenceFrame`, area detectors in ODF
  reconstruction.
- `calcParentEBSD` now gives a **constant** parent orientation within each parent grain;
  `'exactOR'` restores the old fixed-OR/varying-orientation behaviour.

**6.1 (10/2025)** — mostly speedups and mex stability (`check_mex`, `mex_install`, automatic
download on startup). Syntax: `grains.grainSize` → `grains.numPixel`; `how2plot` stored on
data objects — **but note 7.0 made that read-only again, see §1**.

---

## 8. Renamed, removed, and changed in meaning

| Old | New | Old still works? |
|---|---|---|
| `smooth(grains)` | `smoothBoundary(grains)` | yes, warns, keeps old behaviour |
| `grains.grainSize` | `grains.numPixel` | yes, warns |
| `compactify` | `optimalSample` | — |
| `BinghamS2` | `S2FunBingham`, fitted by `S2FunBingham.fit(v)` | — |
| `calcGBPD` | `calcGBND` | superseded |
| `inversePoleFigureDirection` | `ipfDirection` (also a plot option) | yes, alias |
| `orientation.Burger` | `orientation.Burgers` | yes, warns |
| `gB.reorder` | nothing — already ordered | yes, warns |
| `sphericalRegion(...)` | `sphericalRegion.byVertices` | yes, warns |
| `extern/kde` | `kde1d` (it shadowed MATLAB's own `kde`) | — |
| `loadEBSD_hdf5`, `loadEBSD_h5oina` | `loadEBSD_h5` | moved to `obsolete/` |
| `loadEBSD_ACOM`, `_sor`, `_csv`, `_Oxfordcsv` | — | moved to `obsolete/` |
| `ebsd(x,y)` (coordinate lookup) | `ebsd('xy',x,y)` | **no** — errors on a list, silently means row/column on a grid |
| `ebsd.how2plot = ...` | `plottingConvention.default(...)` | **no — read-only** |
| `ebsd.CSList{i}` | `ebsd.CSList(i)` | **no — it is an array now** |

**Constructors.** `quaternion`, `rotation` and `orientation` accept only the component
syntax `quaternion(a,b,c,d)`, `orientation(a,b,c,d,CS,SS)`. Everything else goes through a
named constructor: `vector3d.byPolar`, `orientation.byMatrix(M,cs)`, `rotation.byEuler`,
`rotation.byAxisAngle`, and the new `rotation.byHomochoric`, `rotation.id`, `rotation.nan`,
`rotation.rand`, `rotation.inversion`.

**Symmetry comparison** happens on three levels:

```matlab
cs1 == cs2        % the same object
eqTol(cs1,cs2)    % the same Laue group and axes
sim(cs1,cs2)      % the same lattice, possibly different alignment of x, y, z
```

**`CSList` is an array** of `@crystalSymmetry` and `@notIndexed`, not a cell array. A
not-indexed phase can carry a name and a colour:

```matlab
ebsd.CSList(1) = notIndexed('amorphous',[0.5 0.5 0.5])
```

**`multiplicity` changed meaning.** It now returns the number of symmetrically equivalent
directions/fibres/misorientations — the crystallographic sense. `multiplicity(Miller(1,0,0,cs))`
is 6 in `m-3m`, not 8. It used to return the reciprocal quantity (the number of symmetry
operations fixing the input), contradicting its own help. The two multiply to the group
order, so the old value is `numSym(cs) ./ multiplicity(m)`.

**`slipSystem.hcp` does not exist** and will not: which systems carry deformation, and at
which CRSS, is a property of the material, not the lattice. Use `slipSystem.basal`,
`slipSystem.prismaticA`, `slipSystem.pyramidalCA`, … The error message lists them all.

---

## 9. Silent changes — numbers move

Code that still runs unchanged may now produce different results. Flag these to users
rather than quietly regenerating reference values.

- **Default plotting convention is y-down.** Maps drawn without an explicit convention are
  mirrored relative to 5.x/6.x output.
- **Hexagonal gradients were wrong by √3.** `gradientX` on a row-aligned hex grid divided by
  `dHex` where the neighbour distance is `sqrt(3)*dHex`. Hexagonal `curvature`, `calcGND`
  and gradient-based `weightedBurgersVec` change accordingly. Square grids unaffected.
- **`gridify` of a rotated hex map** silently placed several measurements on one cell and
  kept the last — 5.2% of a titanium map rotated by 20°. Cells are placed by lattice index
  now.
- **`calcGrains(...,'removeQuadruplePoints')`** merged the wrong segments and destroyed real
  boundary (0.21% of a forsterite map).
- **`merge(grains,...)`** assigned rather than added its merge matrix in two of six
  branches, so a call stating several criteria applied only some, depending on the order
  they were written. `merge(grains,twinBoundary,'inclusions','maxSize',5)` left the twins
  unmerged. `'maxPixel'` now takes the mean orientation of the largest grain rather than
  averaging.
- **Symmetry is dropped by rotations** that destroy it (§1), which changes any downstream
  symmetrised ODF. `DetectionOfSampleSymmetry` went from a 15.6° error to 0.8°.
- **Boundary smoothing does three steps by default**, so segment counts and areas differ
  from `smooth(grains,n)`.
- **h5oina orientations rotate** by the Scanning Rotation Angle, usually 180°.
- `interp(ebsd,x,y)` with row vectors used to return an object whose `length` reported 1 and
  dropped query points on gridded sources.
- `.mat` files written by MTEX 5.11 load again — the `@triplePointList` vertex list and the
  `@grainBoundary` `CSList` used to come back unusable. Grain maps saved before the walk
  order are reoriented on load by `grain2d.loadobj`.

---

## 10. A canonical modern script

Copy this shape rather than a 5.x one.

```matlab
% import — no gridify, no format guessing
ebsd = EBSD.load('map.h5oina');

% alignment is a session or per-plot choice, never a property of the data
plottingConvention.default('y↓→x');       % the default anyway

% grains: one call, second output carries grainId (0 = no grain)
[grains, ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',5,'alpha',3.1);
grains = smoothBoundary(grains,5);

% plot — ebsd.orientations needs a single phase, so select one first
plot(ebsd('Forsterite'),ebsd('Forsterite').orientations)   % 'exact' for true unit cells
hold on
plot(grains.boundary,'lineWidth',2)
hold off

% boundary analysis uses the walk order
gB    = grains('Forsterite').boundary('Forsterite','Forsterite');
kappa = gB.curvature;
gbnd  = calcGBND(gB,ebsd('Forsterite'),'halfwidth',10*degree);

% orientation analysis
odf = calcDensity(ebsd('Forsterite').orientations);
ori = optimalSample(odf,10000);
```

---

## 11. Not in 7.0 — currently on `develop`

Only relevant if you are working from a development checkout.

- **`log(ori,ori_ref)`** in the left tangent space did not reduce the pair by crystal
  symmetry while `angle` always did, so neighbouring pixels stored as different symmetric
  representatives came back as up to 180° apart. Every `gradient`, `curvature`, `calcGND`
  and `WBV` number inherited it. Affected neighbour pairs: 1.7% (forsterite), 5.8% (csl),
  7.0% (twins), 62% (titanium). Denoising first hides the effect, which is why the GND and
  WBV example sheets are unchanged. (Issue #194, open since 2016.)
- **HDF5 export that keeps the file.** `export(ebsd,'denoised.h5oina')` copies the file the
  data came from and writes only the changed data into the copy, so the result is still a
  vendor-format file. MTEX's own flat layout and the `'standalone'` flag are gone — use
  `.mat` to carry a map between sessions. Text exporters are interfaces now
  (`exportEBSD_ang`, `exportEBSD_ctf`).
- Both hemispheres of a spherical plot are two axes but **one plot**, so `circle`, markers
  and anything added with `hold on` reaches both (issue #330). Passing `'upper'` and
  `'lower'` together now means both.
- `plotS2Grid` takes a `@referenceFrame` and returns directions of that frame.
- `sphericalRegion.thetaIntervals` / `rhoIntervals` return the components of a
  **disconnected** region, where `thetaRange` returns only their hull — the axis sector of
  `m-3`, `23` and `mmm` really does fall apart into separate caps near the maximum
  misorientation angle (issue #209).
- `calcAxisDistribution(mdf,'minAngle',20*degree,'maxAngle',40*degree)`.
- `insidepoly` reported points sitting exactly on a boundary as off it, on the largest-x
  side of a map (issue #2527).
- VPSC files are recognised by their fourth header line, and the Kocks/Roe convention letter
  is honoured rather than assumed to be Bunge.

---

*The syntax in this file was executed against mtex-7.0.0 on MATLAB R2024b, not only read
off the changelog. When updating it for a new release, please re-run the examples.*
