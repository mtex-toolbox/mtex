# MTEX Technical Changelog

What changed under the hood, release by release: the symptom, the cause, what was
done about it, and the numbers or issue it was measured against. Written for
developers and coding agents working on MTEX.

The changelog for users is `doc/GeneralConcepts/changelog.m`, published as
[Changelog](https://mtex-toolbox.github.io/changelog.html). Releases up to and
including 6.1 have one combined list there and no entry here.

## develop

### Reference Frames

- a `@crystalSymmetry` accepted any reference frame, including a `@specimenFrame` -
  and since the crystal axes are read straight off `frame.basis`, that replaced the
  lattice by the identity without a word. Such an assignment raises
  `MTEX:wrongFrameClass` now. To give a crystal symmetry a plotting convention of
  its own, fork its frame: `fr = crystalFrame(cs.axes,'name',cs.mineral)`, set
  `fr.how2plot` and assign that
- `plotS2Grid` takes a `@referenceFrame` and returns directions of that frame, e.g.
  `plotS2Grid('upper',cs.frame)` for a grid of crystal directions. Which hemisphere
  is the upper one is then decided by the crystal frame instead of the session
  convention, and the result needs no `Miller(v,cs)` cast to be used as a crystal
  direction
- `SchmidFactor` no longer warns about a tension direction that states no reference
  frame, such as `vector3d.Z` or a plain plotting grid - only a direction or stress
  tensor that names a frame contradicting the one of the slip systems does

### EBSD Export

- `exportEBSD_h5` copies the file the data was imported from and writes only the
  changed data into the copy, so the result is still a file of the vendor's own
  format. `EBSD.load` remembers the file and the data sets it read in `ebsd.opt.h5`;
  another reference file may be named by `'reference'`. Changes to the phase list -
  a renamed mineral, a corrected lattice parameter - are written back into the phase
  header as well. Verified against Bruker, EDAX (.oh5 and .edaxh5), EMSphInx, Oxford
  and ThermoFisher files
- MTEX's own flat HDF5 layout, and the `'standalone'` flag that wrote it, are gone.
  Nothing could read it back: `loadEBSD_h5` picks its parser by matching a
  `/Manufacturer` attribute against `interfaces/hdf5_config/*.json` and the exporter
  wrote no such attribute, so `EBSD.load` on a file MTEX had just written died with
  "No Manufacturer config found for: unknown". A `.mat` file is the way to carry a
  map between MTEX sessions
- the text exporters are interfaces like the loaders they mirror, `exportEBSD_ang`
  and `exportEBSD_ctf`, with `export_ang` and `export_ctf` kept as wrappers
- neither the ang nor the ctf exporter undid the Euler angle correction its loader
  applies, so importing an exported map turned it by 180 degree. An import/export
  cycle now reproduces the angles of the original file
- the .ang phase block stated symmetry codes 132 to 137 for the monoclinic and
  orthorhombic alignment variants. EDAX numbers only 32 point groups, so those codes
  were read back as space group ids and a monoclinic phase came back as tetragonal,
  failing the import with "a and b must be equal". The Laue code and the point group
  id are written now
- exporting a hexagonal map to .ang dropped the last column of every scan row,
  whether or not it held measurements, and stated NCOLS_ODD/NCOLS_EVEN accordingly.
  The cells that carry no measurement are told apart from the ones that do now, and
  a full hexagonal map exports and imports unchanged
- the ctf exporter renumbered phases by a loop that tested phase 1 rather than the
  phase it was about to renumber, and derived the grid from `unique` of the
  coordinates. Phases are written as Channel numbers them, 1 to N in the order of
  the phase table with 0 for not indexed
- the ang and ctf exporters state the column layout they write (`VERSION` for .ang),
  so the importer no longer has to guess it

### Plotting

- `plotSection(mdf,'axisAngle','Sections',6)` is between one and a half and two
  times faster, the wider margin on an otherwise idle machine. The time went to
  three places, none of them the data: the bounding circles of a region were drawn
  with 8641 points each, purely so that clipping them would not visibly cut a corner
  - they are sampled at a degree now, all circles of a region at once, and the end
  of every arc is bisected onto the boundary, which is both cheaper and more
  accurate. `orientationRegion` rebuilt the sector of rotational axes for every
  candidate vertex, although it is needed only for the ones at 180 degree. And
  `fundamentalRegion` now remembers the regions it computed - keyed on the
  rotations, the lattice, the convention and the mineral of both symmetries, never
  on the point group id, so two differently aligned symmetries of the same class
  cannot be confused
- an axis angle section coloured area outside the sector it draws, and left area
  inside it white. The reason is that a spherical region is bounded by small
  circles, so the polar angles belonging to a fixed azimuth angle need not form a
  single interval - close to the maximum misorientation angle the axis sector is cut
  open at its corners and eventually falls apart into separate caps, for the point
  groups `m-3`, `23` and `mmm`. `plotS2Grid` kept the bounding box of such a region
  and punched NaN holes into it, which a surface survives but `contourf` does not -
  it draws straight across the gap. The grid is now assembled from strips that have
  one interval per grid line, swept along whichever of the two angles gives fewer of
  them, and each strip is contoured on its own. This is [issue
  #209](https://github.com/mtex-toolbox/mtex/issues/209). The two new methods
  `thetaIntervals` and `rhoIntervals` return the components, where `thetaRange`
  returns only their hull. Both solve for the crossings with the bounding circles in
  closed form, where `thetaRange` used to walk a discretisation of ten thousand
  polar angles per grid line - a spherical plotting grid is built about four times
  faster now, and its boundary is exact rather than snapped to that discretisation.
  As a further side effect the grid of a disconnected region is no longer padded out
  to the bounding box, so a narrow sector costs a fraction of the points it used to
- a three dimensional spherical plot, `plot(sF,'3d')` and friends, ignored the
  plotting convention it was given whenever that convention happened to equal the
  session default - the whole of the pristine x-east / y-down / z-into-screen
  alignment - and used its own tilted camera instead. It told a convention the
  caller had passed from the one its callers append for their own data by comparing
  values; the two are marked apart now, so a convention handed in is always honoured
- a small circle drawn on a plot that covers both hemispheres went into whichever of
  the two axes happened to be current - the lower one, even for a cone around an
  axis in the upper hemisphere - and the part of it that crossed the equator was
  clipped away at the rim instead of being continued in the other half. An upper and
  a lower hemisphere are two axes but one plot, and they know about each other now,
  so `circle`, markers, labels and everything else added with `hold on` reaches both
  of them, each showing the part that falls into its hemisphere. Drawing the two
  halves by hand, one `'upper'` and one `'lower'` plot per hemisphere, is no longer
  necessary. This is [issue #330](https://github.com/mtex-toolbox/mtex/issues/330).
  Passing `'upper'` and `'lower'` together gave a single hemisphere as well, fewer
  axes than passing neither - it now means the same as asking for both
- a three dimensional spherical plot lost its X / Y / Z arrows when the annotation
  moved into the `sphericalPlot` constructor - `plot(...,'3d')` never builds one.
  The decision lives in `annotateFrame` now, shared by `sphericalPlot` and both 3d
  builders. `plot3d` also draws a spherical grid on the `'grid'` flag, off by
  default
- `restrict2Upper` and `restrict2Lower` added their condition even when the region
  already carried it, and `sphericalRegion/plot` draws one boundary per condition,
  so the same circle was drawn twice. The polar grid was drawn after the boundary
  and painted out its middle, leaving the two antialiased flanks - the boundary read
  as two hairlines instead of one thick circle
- a contour plot with `'log'` died on a non positive minimum:
  `logspace(log10(colorRange(1)),...)` returns complex levels as soon as the lower
  bound is not positive, and a contoured ODF routinely has a small negative minimum.
  The levels start at the smallest positive value in the data now, and fall back to
  linear spacing when nothing is positive. This closes [issue
  #1691](https://github.com/mtex-toolbox/mtex/issues/1691)
- `plotSection(odf,'contourf')` errored in `intervalsFromBreaks`, where `repelem`
  returns a row for a single grid line and the two halves of the stack did not
  concatenate
- the arrows of a Schmid factor plot were drawn at the length of a `@Miller`, which
  is a reciprocal lattice spacing rather than a length in the plot. Both are
  normalized now
- a compact grain boundary plot showed spiky joins under R2024b and later. The patch
  path uses round joins now

### Orientation Gradients, Curvature and GND

- `log(ori,ori_ref)` in the left tangent space did not reduce the pair by crystal
  symmetry, while `angle(ori,ori_ref)` always did. A left tangent vector is `ori *
  inv(ori_ref)`, and the symmetry acts between the two factors - the equally valid
  representatives are `ori * s * inv(ori_ref)` - so once the product is formed it
  can no longer be reduced, and the pair has to be reduced first. It was not, so two
  neighbouring pixels stored as different symmetric representatives of their
  orientations - which is a property of the file, not of the material - came back as
  a rotation of up to 180 degree instead of the fraction of a degree that really
  separates them. Every `EBSD.gradient`, `gradientX/Y/Z`, `curvature`, `calcGND` and
  `WBV` number inherited that. This is [issue
  #194](https://github.com/mtex-toolbox/mtex/issues/194), open since 2016;
  `@ThomasChauve`'s reading of Pantleon 2005 was right all along.

**Numbers move.** The affected pixels are not rare: of the neighbour pairs in the
shipped datasets 1.7 percent (forsterite), 5.8 percent (csl), 7.0 percent (twins)
and 62 percent (titanium) were computed from an overstated misorientation. Denoising
a map with `smooth` rewrites the orientations of a grain consistently and hides the
effect, which is why the GND and WBV example sheets - both of which denoise before
they compute - are unchanged, to 3e-6 percent and bit for bit respectively. Without
denoising they are not: the weighted Burgers vector of the undenoised `single`
dataset had a mean norm of 15.7 against the 0.127 it has now, on all three stencils.

### Points On A Grain Boundary

- `insidepoly`, the fast point in polygon engine MTEX uses in place of MATLAB's
  `inpolygon`, reported points sitting exactly on a grain boundary as off it - but
  only ever on one side of a map, the side with the largest x. The engine brackets
  each edge by a half open interval in x, which is what makes the crossing count
  right where two edges meet, and it used that same bracket for the on-boundary
  test. A vertex that is a local maximum in x is the excluded end of both edges
  meeting there, so no edge ever looked at a point sitting exactly on it. The
  bracket is closed for the on test now and stays half open for the crossing count.
  On the map of [issue #2527](https://github.com/mtex-toolbox/mtex/issues/2527) this
  made 504 of the queried boundary points come back wrong, and
  `grains.isOuterBoundary` found 110 boundary grains instead of 147

- `isOuterBoundary` no longer asks that question at all. The envelope it lays around
  the map is spanned by vertices of the grains themselves, so which grain it touches
  is a matter of vertex identity and is read off the polygons directly - exact,
  faster, and independent of how a point lying on a boundary is classified

### Plasticity

- there is no `slipSystem.hcp` and there will not be one: which slip and twinning
  systems carry the deformation of a hexagonal material, and at which critical
  resolved shear stress, is a property of the material and the experiment rather
  than of the lattice. The placeholder that used to warn and then return nothing -
  which made `dislocationSystem.hcp` fail with "Output argument sS not assigned" -
  now raises an error that lists every predefined hexagonal family,
  `slipSystem.basal`, `slipSystem.prismaticA`, `slipSystem.pyramidalCA` and the
  rest, with the Miller indices of each, so the set can be put together on the spot
- `slipSystem/SchmidFactor` checked the reference frames in one direction only: it
  caught a specimen stress tensor against crystal slip systems, but not a crystal
  tensor against slip systems already rotated into specimen coordinates by `ori *
  sS` - that combination silently returned a Schmid factor computed across two
  frames. The tension direction syntax `sS.SchmidFactor(r)` checked nothing at all,
  so the very same computation warned or stayed silent depending on whether it was
  written as a direction or as a uniaxial stress tensor. Both branches now apply the
  same test, and the warning carries the identifier `MTEX:frameMismatch` so it can
  be switched off. A crystal direction has to be stated as a `@Miller`, since a
  plain `@vector3d` is taken to be a specimen direction

### VPSC Files

- a VPSC texture file is now recognised by its fourth header line - the Euler angle
  convention and the number of orientations - instead of by the string `TEXTURE AT
  STRAIN` on the first. Only VPSC **output** carries that marker, so the weight
  (`.wts`) files that are handed to VPSC, and the files `export_VPSC` itself writes,
  were both rejected as "Interface VPSC does not fit file format!". Reading back
  what MTEX exported now works
- the convention letter is honoured rather than assumed: a file announcing Kocks
  (`K`) or Roe (`R`) angles is read in that convention instead of being silently
  treated as Bunge. `export_VPSC` likewise writes the letter that matches the angles
  it wrote, and defaults to Bunge rather than to the `EulerAngleConvention`
  preference, which may be one VPSC cannot express

### Fundamental Regions

- `orientationRegion/checkInside` tested whether its two symmetries are trivial by
  comparing them against a freshly constructed `crystalSymmetry`, i.e. it built a
  symmetry object on every call only to throw it away. `orientationRegion/cleanUp`
  calls it a few hundred times, so this was the bulk of `fundamentalRegion(cs,cs)` -
  and an axis angle section plot builds the fundamental region twice. The comparison
  object is built once now; `fundamentalRegion` is about three times faster and
  returns bit identical regions

### Axis Distributions

- `calcAxisDistribution` takes `'minAngle'` and `'maxAngle'`, so the axis
  distribution can be restricted to the rotations an axis angle section shows rather
  than always covering the whole fundamental region. It works the same way on an
  ODF, on an MDF, on a `@symmetry` and on an `@orientationRegion`, and passes
  through `plotAxisDistribution` and `calcAxisVolume`

```matlab
adf = calcAxisDistribution(mdf,'minAngle',20*degree,'maxAngle',40*degree)
```

### Import Wizard

- the phase table is where a phase is edited. `Symmetry` and `Align` are categorical
  columns and therefore drawn as dropdowns, the lattice parameters are numeric
  cells, and every edit is funnelled through one rebuild that reads the whole row,
  because a lattice ties its parameters together. `Align` offers the twelve axis
  alignments - X parallel to u, Z parallel to w - that construct on every lattice,
  measured rather than guessed, and a frame that none of them reproduces still
  imports, reads as `(custom)` and survives an edit to an unrelated cell
- the `Phase` column was a `uint8`, so a negative phase number saturated to zero. An
  `.ang` numbers its indexed phases from 0 and its not indexed one `-1`, so
  `ferrite.ang` showed phase 0 on both rows
- the window came up at a fixed 1300 × 700 - wider than a 1024 × 768 screen -
  because `WindowState` `'maximized'` does not resize a uifigure at all, it keeps
  the `Position` it was given and reports itself as maximized. The figure is
  constructed at the size of the primary monitor now, before it has a single child,
  so the layout tree is built once at its final size, and the plotting path is
  warmed up while you are still browsing for a file
- a `uiaxes` is created at 400 × 300 and a `uigridlayout` corrects that only on its
  next layout pass, after the callback that created it has returned. So every map
  was rendered twice, and the scale bar - which sizes itself from the footprint of
  its label in data units - kept the sizes of the small axes, 27.3 px against 77.4
  px for the reference frame triad. The plot tabs parent their axes directly now
- the import is exported as a script by `buildImportWizardScript`, which fills the
  template in `templates/import/` from the wizard's own state - the phase list as
  edited, the plotting convention, the Euler correction, the selected data set and a
  closing plot of the dominant phase

### EBSD Import

- a Bruker file was read at two units at once: `Bruker.json` took the position from
  the beam column and row index, step 1, and the unit cell from `XSTEP`/`YSTEP` in
  micrometre. `gridify` then sized its lattice from the micrometre cell - 17.8
  million nodes for 2.66 million measurements, 85 percent of them empty - or refused
  a grid altogether. The micrometre columns `X SAMPLE`/`Y SAMPLE` are read now:
  `h5_bruker.h5` imports in 1.6 s instead of 65.7 s, and `BCWQ10min2.h5` gridifies
  at all
- a `.cpr` file that declares more phases than it describes - Channel 5 writes one
  short when it stitches projects - died with "Unrecognized field name phase13". The
  undescribed phase keeps its slot, so every phase after it stays where it is, and a
  warning says so
- an Oxford `.h5oina` stores its EDS element maps beside the EBSD data rather than
  inside it, so they stopped being imported when `loadEBSD_h5oina` was retired. A
  config's `additions.group` may be a list now, subgroups are descended into and
  prefixed, and the EDS header arrives as `ebsd.opt.eds.header`. A coarser EDS
  raster is not a property of this map and is skipped with a warning
- `calcUnitCell` honours `'GridResolution'`, `'GridType'` and `'GridRotation'`. All
  three were reachable from user code and dead on every route out of the function -
  a scalar resolution errored, a pair was ignored three times over. This is [issue
  #2600](https://github.com/mtex-toolbox/mtex/issues/2600)
- a property need not be one number per pixel - a forescatter image has five diode
  channels, an RGB one three. `gridify` kept only the first of them, silently;
  `squarify` and `hexify` share one `scatterProp` now that builds `r × c × k`
- a `@notIndexed` phase carrying a name and a colour - a thresholded mask promoted
  to a phase of its own - reported `NaN` as its colour and was drawn as nothing and
  left out of the legend. `phaseList/get.color` asks the phase now
- `trim` cuts a gridded map to the smallest rectangle containing data, dropping the
  empty rim that registering, rotating or masking leaves. Unlike `subGrid` it only
  removes rows and columns that are entirely empty, so notIndexed pixels enclosed by
  measurements survive
- `calcMesh` interpolated the deformation field over the whole lattice and then
  overwrote every measured node with its measurement, and built three
  `scatteredInterpolant` over the identical point set. One interpolant, three value
  sets, evaluated only where nothing is measured; a complete grid skips the
  interpolation entirely

### Grain Reconstruction

- `calcGrains` could return an indexed grain below `'minPixel'`. The culling happens
  before the decomposition, and it changes the map the alpha closing runs on - a
  pixel reaching its grain over a Voronoi face bridge can lose that bridge when
  other pixels are culled elsewhere and then be found isolated. The postcondition is
  enforced after the segmentation now, at no measurable cost
- variant type grain reconstruction is available from `calcGrains` itself

### Phase Transitions

- `calcParent2Child` returned a different relationship for the same misorientations
  in a different order. Every place that reduced the data drew a random subsample -
  two calls disagreed by up to 0.4 degree - and the trimming resolved ties by input
  order. The subsample is a stride through an angle sorted list now, so it is a
  function of the misorientations alone: repeat calls and permuted input agree
  exactly
- the iteration is a trimmed fixed point iteration on a named objective, and it
  searches the misorientation fundamental zone by default rather than trusting
  `p2c0`. On martensite that answers 1.46 degree away from where the iteration
  started at Kurdjumov-Sachs lands, and fits better - KS is simply not in the best
  basin. **This changes results** for every caller that does not pass `'local'`, by
  about 1.4 degree in `p2c` and several degrees in a habit plane computed from it.
  `'local'` remains the right choice for refining a relationship already trusted and
  for many small fits in a loop, where the fixed cost of the scan dominates. The
  derivation, the measurements and the rejected alternatives are in Fitting an
  Orientation Relationship and in `docs/adr/0005-parent-to-child-fit.md`
- `calcParentEBSD` reported variant 1 and packet 1 for every pixel without an
  orientation, `min(...,[],2)` returning `NaN` as the value but 1 as the index. Both
  ids are `NaN` there now

### Sampling and Approximation

- `optimalSample` and its spherical sibling move their points by L-BFGS instead of
  by gradient descent. The functional is badly conditioned, which is exactly what
  gradient descent is slow on: at the point it reaches after 325 iterations on
  `SO3Fun.dubna` the Hessian still has 12 negative eigenvalues, i.e. the iteration
  is crawling along a saddle. Roughly an order of magnitude in time to equal
  discrepancy on SO(3), a factor 3 on the sphere. The left tangent space trivializes
  the tangent bundle of SO(3), so the secant pairs may be accumulated as they are;
  on the sphere they are parallel transported along the geodesic of every step
- the descent method is selectable, `'method','lbfgs'` (the default) or
  `'method','steepestDescent'`, following the convention of `calcKernel` and
  `calcCluster`. `'memory'` goes back to meaning the depth of the L-BFGS memory
- the weights are a softmax block of the same quasi Newton iteration rather than an
  alternating inner solve, which drops the simplex constraint, `mlsq` and
  `innerIter` and lets the memory see the coupling between where a point sits and
  how much mass it carries
- asking for weights together with a `'warmUp'` could return the equal weights `1/M`
  without a single weight step ever having run: the weights are held fixed during
  the warm up, so the termination test degenerated to its orientation half. The warm
  up ends at that point now and the weight step takes over
- the MLS classes use the Wendland weight by default. A `'plateau'` weight is
  available, constant on the inner 60 percent of the support and tapering with a C1
  smoothstep, which spreads the local fit over the whole neighbourhood - a
  concentrated weight makes the fit hinge on the few nearest nodes and swing
  whenever their ranking changes under the moving evaluation point
- the automatic regularization onset of the MLS classes was an absolute threshold.
  The amplification of a perfectly distributed neighbourhood is not one but a floor
  that grows with the degree and the dimension of the manifold - 2.63 to 4.31 on S2,
  3.63 to 40.8 on SO(3) for degree 2 to 6 - so a flawless equispaced SO(3) grid
  regularized 95 percent of its pages at degree 6 with nothing to correct. The onset
  is placed relative to that floor now, measured once per ansatz space and cached

### Orientation and Spherical Functions

- `WignerD(ori,'kernel',psi)` dropped the kernel: the option was parsed by nobody,
  the expansion ran to `maxSO3Bandwidth` and the result disagreed with
  `calcFourier(SO3FunRBF(ori,psi,1))` by the kernel's Chebyshev coefficients and by
  its length
- `SO3FunCBF/grad` symmetrised over the crystal symmetry only, while `eval` averages
  over the proper specimen group as well, so the analytic gradient described a
  different function as soon as the specimen symmetry was not trivial
- `SO3FunRBF.approximate(ori,values)` accepts nodes and values, as `interpolate`
  does - it assumed an `@SO3Fun` or a function handle and died in `orientation/cat`
- `harmonicMethod` opened by assigning to a local `eps`, which shadows the builtin
  for the rest of the function, including the two places that sparsify the system
  matrix at machine precision. The threshold therefore scaled with the amplitude of
  the function it must not depend on
- `sphericalHarmonicTrafo` is fixed for high bandwidth
- `eval` hands the mex only the coefficients it reads and probes the symmetries only
  when they can be used, so evaluating a bandwidth 128 function at bandwidth 32 no
  longer copies 44 MB for nothing - 68.5 ms to 12.9 ms, output bit identical. The
  NFFT oversampling is halved and `multiplicityZ` is cached on the symmetry
- `calcComponents` with `'seed'` and `'radius'` together died with "Index exceeds
  the number of array elements": `accumarray` sizes its output by the largest
  subscript it is handed, so every mode no seed came close enough to was missing
  from the end of the weights

### Color Keys

- `ipfHSVKey` came out all red for any real triclinic cell - the hue spanned 0.0017
  of the color wheel instead of all of it. The `rho = 0` reference is `outOfScreen -
  center`, which is the zero vector exactly when the fundamental sector is a
  hemisphere, since then its barycenter is its pole. `crystalSymmetry('-1')` escaped
  it only by accident, its center being `zvector`. There is a fallback to the
  frame's east now, and `-1` still warns that a hemisphere with antipodal boundary
  identification has no topologically correct key - that part is real
- that warning was raised in two wordings by three keys and could not be switched
  off, neither call passing an identifier. It is one message with the identifier
  `MTEX:noTopologicalColorKey` now, and goes through `mtexWarning`, which drops the
  backtrace and wraps the text
- a plain `directionColorKey(cs,'antipodal')` failed with "Unable to use a value of
  type Miller as an index": `dir2color` is filled only from an explicit option but
  was called unconditionally. It falls back to the HSV key now, which is what a bare
  `directionColorKey` shows when it is plotted. This closes [issue
  #2515](https://github.com/mtex-toolbox/mtex/issues/2515)

### Tensors

- a right sided tangent space is expressed in crystal coordinates and a left sided
  one in specimen coordinates, but a `@spinTensor` came out of the conversion with
  the constructor default `specimenSymmetry('1')` either way - correct by accident
  on the left, crystal coordinates declared as specimen coordinates on the right. A
  spin tensor keeps the frame it was computed in now

### Display, Conventions and Warnings

- the plotting convention arrows were written out literally in three places and
  ignored the `UTF8Output` preference, which `@Miller/char` and
  `@crystalSymmetry/char` honour - with it switched off every convention header
  printed mojibake. `plottingConvention.arrows` is the single source now and
  `str2rot` parses the ASCII forms back, so printed output round trips in both modes
- a display states its plotting convention in the header line and, when the
  pictogram describes the convention completely, nowhere else - the
  `outOfScreen`/`north`/`east` listing below only repeated it. A `@crystalSymmetry`
  states it in crystal directions
- the deprecated `plottingConvention` alias on `@vector3d` and `@EBSD` is gone. Its
  setter forked the session frame onto one object by ordinary get-modify-set, which
  is the fork family that a read only `how2plot` ended. Use the frame idiom instead,
  as Axes Alignment shows
- `mtexWarning` wrapped its lines to exactly the window width in a narrow command
  window, so the command window wrapped them a second time, usually inside the
  indent. One column of slack removes it

### Maps, Images and Transforms

```matlab
mg = mapImage(ebsd.bc,ebsd)              % an EBSD map joins as one of the images
mg = mapImage(bse,'dxy',0.05,'name','bse')
[u,peak,pos] = xcfShift(imA,imB);        % u is the displacement FROM A TO B
T = spatialTransformShift.fit(pos, pos + u, 'weights', peak);
T = spatialTransformDrift.fit(posA,posB,'slowScan',xvector);
ebsd = transform(ebsd,T)                 % and transform(ebsd,inv(T)) back again
v = interp(mg, eval(inv(T),target.pos))  % resample through a transform
ebsd = gridify(ebsd,gridLayout(-xvector,yvector))
ebsd = gridify(ebsd,gridLayout(otherMap))
gL = ebsd.layout                         % read the layout back off a map
```

- a `@spatialTransform` fixes its direction once: `T` maps a position in one frame
  to the same physical point in the next, and `T2 * T1` applies `T1` first. Filling
  an output grid therefore always uses `inv(T)` - for each target pixel, ask where
  it came from. `T * pos` evaluates, as for a `@rotation`. `EBSD/transform` takes
  one instead of the bare function handle it used to
- declaring a multi stage model is `+`, composing fitted ones is `*`, and the two
  are different operations. `*` simplifies and decides by value: an operand
  reporting `isid` disappears, and an unfitted prototype has zero coefficients, so
  `spatialTransformShift * spatialTransformDrift` is a bare drift with the shift
  silently gone. `+` keeps both stages and drops only a literal
  `spatialTransformId`. Note `+` chains the maps rather than adding the
  displacements, unlike the `+` of a `@vector3d`
- two affines absorb into a third; anything else composes into a
  `spatialTransformComposite` that keeps its stages. Every subclass is named for the
  distortion it models - shift, affine, polynomial, homography, a linear spline down
  the slow scan direction, a scattered field - and fits itself from two point sets
  through one weighted bisquare solver, so a low confidence measurement is outvoted
  rather than dragging the fit. `inv` is exact where the model allows it and
  otherwise iterates the displacement field back, saying so when the field folds;
  `discretize` collapses a chain of any length into one interpolated field
- differently modelled transforms share a base class, so a chain of hops is one
  array rather than a cell array
- `xcfShift` divides the region two images share into tiles and phase correlates
  each against its counterpart, returning a sub pixel displacement per tile and the
  height of the correlation peak that produced it. The peak height is the fit
  weight, not a diagnostic - a tile that landed on featureless background must not
  get an equal vote. `u` is the displacement FROM A TO B: the feature at `pos` in A
  is at `pos + u` in B. Given two `@mapImage` the answer is in specimen units
  instead of pixels. Only the region where both images are finite is tiled, so
  padding left by an earlier resampling is excluded rather than correlated against
- a `@mapImage` grid is regular - an origin and two perpendicular step vectors, with
  `pos` derived rather than stored. That is what separates it from an `@EBSDgrid`,
  which stores a position per pixel and so may be rotated, sheared or distorted; an
  image is none of those, since a distortion is applied by resampling onto a new
  regular grid. So `interp` is a `griddedInterpolant` and `pos2ind` is a projection
  and a round. `size`, `numel` and `length` describe the ARRAY of images, not the
  grid - the opposite choice from `@EBSD`; the grid is `gridSize(mg)`
- `mapImage/transformReferenceFrame` lays the array out in another `@gridLayout` - a
  transpose and two flips, nothing resampled - and turns the map that travels with
  it, so `ebsd.bc` keeps sitting beside the image pixel for pixel. `edgeMap` is the
  transform that makes a band contrast map comparable to a backscatter image:
  absolute brightness is not comparable, boundaries are. An image pre-processed for
  registration - gamma compressed, filtered - is simply another entry in the
  sequence, with the identity as the transform between it and the image it came
  from; there is no `registerOn` property saying which channel to register on
- `mapImage/plot` draws the image in micrometres where it sits, so it overlays the
  map without either being permuted
- a `@gridLayout` names the direction each array index advances along, dimension 1
  first, and any axis aligned one may be asked for - which is what puts a map in the
  same array order as an image it is to be compared with pixel by pixel. `gridify`
  takes one as well as `'columnMajor'` and `'rowMajor'`, which are now just the two
  layouts aligned with x and y, and `ebsd.layout` reads it back off a map. Nothing
  is resampled - `layoutIndex` works out the transpose and two flips relating two
  layouts and `EBSDsquare/transformReferenceFrame` applies them to a map that is
  already gridded. A layout no permutation can reach is refused; a rotated or
  sheared grid is put as close to the one asked for as a permutation can get,
  exactly as the flags always did
- `spatialTransformProjective.byTilt` states a tilt that is known rather than
  fitting one, which is two physical numbers and a centre where a general projective
  transform is eight coefficients
- `assignGridIndex` modelled the inner cell size as a function of the outer
  coordinate alone. That is exact for a trapezoidal drift but holds the size
  constant in precisely the direction a perspective varies it: on a tilted map the
  size runs 0.92 to 1.12 of nominal along the scan. The size is fitted affinely in
  both lattice coordinates now, and integrated across a big step rather than sampled
- a `@spatialTransform` sequence displays as a table, stage by stage. Why an array
  of them is a chain rather than a collection is
  `docs/adr/0007-transform-array-is-a-chain.md`

### Build and Housekeeping

- MTEX has no Image Processing Toolbox dependency anywhere. `imresize` and
  `normxcorr2` were left in one check of the TrueEBSD workflow, which is gone - the
  constructor compares the `@gridLayout` of every entry instead
- the pole figure and ODF wizards still run the retired GUIDE code, whose finish
  step reached the editor through the Java bridge
  `com.mathworks.mlservices.MLEditorServices` and therefore crashed from R2025a on.
  They use the documented editor API now, and the fallback that was meant to catch
  the failure - and itself raised "Not enough input arguments" - works. This closes
  [issue #2387](https://github.com/mtex-toolbox/mtex/issues/2387)
- the `insidepoly` mex binaries are rebuilt for all four platforms against a
  libstdc++ that MATLAB actually ships, `compile-mtex` builds its include list from
  the tree, and `makeRelease` drops `doc/html` from every release rather than only
  from the betas
- `SchmidtFactor.m` is spelt `SchmidFactor.m`
- a structural checker for the documentation runs in CI, so a `See also` entry or a
  link pointing at a page that does not exist is caught before it is published


## MTEX 7.0 - 08/2026

### Grain Reconstruction

`calcGrains` covers small grain removal, alpha shapes and gridded as well as
arbitrarily placed data in a single call. Its second output replaces the previous
`ebsd.grainId = ...` assignment and marks pixels belonging to no grain - not indexed
or removed by `'minPixel'` - by `grainId == 0`. All boundary criteria are objects of
type `@grainBoundaryCriterion` (`gbcAngle`, `gbcSoft`, `gbcFMC`, `gbcVariants`,
`gbcCustom`), so any per pixel property may be segmented and every phase may get a
threshold of its own

```matlab
grains = calcGrains(ebsd,'angle',{10*degree,15*degree}) % one per phase
grains = calcGrains(ebsd,gbcCustom(ebsd.bc,10))  % segment by band contrast
grains = calcGrains(ebsd,'soft')                 % a soft threshold
```

Fast multiscale clustering `@gbcFMC` - the criterion for deformed material where no
single threshold angle works - has been rewritten. It judges two clusters by their
misorientation against their own internal spread, fits a lattice curvature so that a
bent grain is not mistaken for a scattered one, and clusters each phase separately,
which lifts the adjusted Rand index on a benchmark of deformed maps from 0.84 to
0.96 at a third of the runtime. Note that `calcGrains(ebsd,'fmc',cmaha)` used to
fall back to angle thresholding without saying so

```matlab
grains = calcGrains(ebsd,'fmc',0.5,'minPixel',10,'verbose')
```

The new data set `mtexdata EMSphinx` illustrates this in Grain Reconstruction.
Advanced Grain Reconstruction shows how to write a criterion of your own, Markovian
Clustering the second way of turning one into grains. Two new commands complete the
picture

- `calcGBND` estimates the distribution of grain boundary normals, in specimen or in
  crystal coordinates, 2d and 3d
- `cleanUpPseudoSym` detects grains split by pseudo symmetric indexing - by the
  tortuosity of the separating boundary - and reassigns the affected pixels

```matlab
gbnd = calcGBND(grains.boundary('Fo','Fo'),ebsd('Fo'),'halfwidth',10*degree)
gbcd = calcGBND(gB,grains('Fo'),moriRef)   % for a fixed misorientation
gbnd = calcGBND(grains3.boundary)          % 3d, specimen coordinates
[ebsd,grains] = cleanUpPseudoSym(ebsd,grains,mori,'threshold',1.5)
```

### Grain Boundaries in Walk Order

The segments of a `@grainBoundary` are not an unordered list anymore. They are
sorted into chains - maximal runs of segments joined at vertices where exactly two
segments meet - so that consecutive segments share a vertex. Any other vertex is a
junction and terminates a chain. Each chain occupies a contiguous block of rows and
is oriented such that the grain in `gB.grainId(:,1)` lies to the left of the walk
direction

```matlab
gB = grains.boundary
gB.chainId, gB.chainSize, gB.isChainStart, gB.isChainEnd, gB.isClosed
gB.arcLength, gB.chainLength   % length along and of the chain
gB.chainV                      % vertex ids, chains separated by NaN
```

This is what allows to coarsen or to refine a boundary as a curve instead of as a
bag of segments. All of the following keep the junctions exactly where they are, so
which grains touch, and where, is unchanged

- `simplifyBoundary(grains,epsilon)` drops every vertex whose removal moves the
  boundary by less than `epsilon` - Douglas Peucker on each chain - which turns the
  pixel staircase into the straight line it approximates
- `reduceBoundary(grains,n)` is the blunt alternative, keeping every n-th vertex
  regardless of shape
- `refineBoundary(grains,delta)` resamples each chain at equal arc length instead of
  subdividing its segments, which only made the staircase finer
- `isOuterBoundary(grains)` tells which grains border the map, no longer obvious
  once an alpha shape has traced it

The walk order is also what gives `curvature` its sign: a segment is stored with the
grain in `gB.grainId(:,1)` to its left, so a positive curvature bulges into
`gB.grainId(:,2)` - for the whole map at once, not only for one grain at a time.
Which of the two grains ends up in the first column is not decided by
`grains(k).boundary`, so put the grain the sign is meant to refer to there

```matlab
gB = flip(gB, gB.grainId(:,2) == grains(k).id)   % grain k to the left
kappa = gB.curvature                             % positive = convex
```

Grain maps saved before the walk order are turned the right way round when they are
loaded - a grain whose segments enclose `-area` is reversed by `grain2d.loadobj`,
which leaves a well formed file untouched. See Boundary Curvature.

What used to be `smooth(grains)` is called `smoothBoundary(grains)` now - `smooth`
on an `@EBSD` denoises orientations, something entirely different - and it performs
all three steps by default: simplify at `d/sqrt(2)`, `d` the pixel spacing, which
removes the grid and nothing else, refine, and only then the Laplacian smoothing it
used to do on its own, which without the first two cuts the corners off a curve

```matlab
grains = smoothBoundary(grains,5)
grains = smoothBoundary(grains,5,'noSimplify','noRefine')   % as before
```

The old name still works and still does the old thing, so a script written against
it keeps its grain areas and its segment count. Since the first two steps change the
number of segments, switch them off wherever `gB.ebsdId` is read per segment.

Which algorithm smooths is a choice now, made by passing a `@boundaryFilter` - the
same pattern as the `@EBSDFilter` of `smooth(ebsd,F)`

```matlab
grains = smoothBoundary(grains,taubinFilter)
grains = smoothBoundary(grains,curvatureFilter('smoothingLength',3))
```

`laplaceFilter` is the default and unchanged, `taubinFilter` unshrinks after every
pass where a Laplacian shrinks without bound, `curvatureFilter` replaces the
iteration by a single sparse solve whose knob is a **length** rather than an
iteration count, and `huberFilter` keeps a genuinely faceted boundary faceted.
Advanced Grain Smoothing compares them.

### EBSD Import

All HDF5 flavours are handled by one json driven interface `loadEBSD_h5`, so no
format has to be guessed and a new vendor is a matter of a json description rather
than of a new interface. The import wizard is started by `import_wizard` and exports
the import as a script

```matlab
ebsd = EBSD.load('data.h5')                  % no format guessing needed
ebsd = EBSD.load('data.h5','dataSet',2)      % or 'dataSet','Area 2'
ebsd = EBSD.load('data.h5oina','dataSet','EBSD') % not the post processed data
ebsd = EBSD.load('data.h5','headerOnly')     % phases, header and data sets
ebsd = EBSD.load('data.ctf','EulerCorrection',rotation.byEuler(pi,0,0))
```

- a file holding several maps - EDAX areas, Oxford slices, EMSphInx scans - lists
  them on import and lets you pick one by `'dataSet'`, whose path is kept in
  `ebsd.opt.dataSet`. Previously only the first one was imported, without a word
- Oxford files may store the map as recorded and as cleaned up by the vendor
  software - both are offered as data sets of that file, the cleaned up one is
  imported by default and the recorded one by `'dataSet','EBSD'`
- reference frame corrections are unified across `ang`, `ctf`, `crc` and `h5` files
  and stored in `ebsd.EulerCorrection`
- Oxford `h5oina` files state the misalignment between the map and the Euler angle
  reference frame - AZtec shows the map in beam view but the orientations in camera
  view - as `Scanning Rotation Angle`. MTEX now reads it instead of assuming it, as
  it still has to for `ctf` and `crc`. Orientations imported from `h5oina` change by
  that angle, usually 180 degree, and now agree with the same map imported from a
  `ctf`
- EMSphInx writes the EDAX `ang` and HDF5 layouts, but counts the phases from 0 and
  flags a pattern it could not index by 255, where EDAX counts from 1 and keeps 0
  for not indexed - so every phase used to come out shifted by one. Its `ang`
  carries no vendor marker at all and is recognized by its empty phase descriptions;
  `'EDAX'` and `'EMSphInx'` overrule that guess. Pixels an ROI mask kept out of the
  run - a valid looking phase at orientation (0,0,0) with every quality measure zero
  - are marked notIndexed instead of fusing into one huge spurious grain
- the file header is kept in `ebsd.opt.header` and readable by `'headerOnly'`
  without importing the data at all, the SEM / PRIAS images an EDAX map comes with
  in `ebsd.opt.electron_image`, as the Oxford electron images already were
- faster import, automatic column and degree/radiant detection

The formats `ang`, `osc`, `oh5` and `edaxh5` may all hold the very same map, but
were interpreted differently. They now agree on the alignment between Euler angle
and map reference frame, on the crystal axes alignment used by EDAX - x parallel to
a for triclinic, trigonal and hexagonal lattices, now available for any symmetry by
the option `'EDAX'` - and on the point group of the phases, where `ang` and `osc`
used to report the Laue group `622` instead of `6/mmm` and `432` instead of `m-3m`.
As the `setting` is not stored in the file, the most common setting 2 is assumed
instead of leaving the Euler angles uncorrected - state one of `'setting',1` to
`'setting',4` yourself, or switch the correction off by `'setting',0`

```matlab
ebsd = EBSD.load('data.edaxh5','setting',3)  % not the assumed setting 2
cs = crystalSymmetry('321',[4.9 4.9 5.4],'EDAX')   % x // a
```

Phases of Bruker files keep their International Tables number and atomic basis in
`cs.opt.spaceId` and `cs.opt.atoms`. Fixed along the way: `ang` files whose header
contains a stray carriage return - as written by some EDAX exports - silently lost
their first data point.

### EBSD Grids

Both representations - the gridded map and the plain list - are accepted everywhere,
and `EBSD(ebsd)` and `gridify` convert between them at any time. Data that would
lose measurements by being gridded - two of them falling into the same lattice cell,
or positions too irregular to span a raster - is never gridded and comes back as a
list with a warning saying why. A plain list can also be asked for explicitly

```matlab
ebsd = EBSD.load(fname,'noGrid')     % this import
setMTEXpref('gridifyOnImport',false) % every import
```

One syntax had to go for this: `ebsd(x,y)` used to be the measurement closest to the
coordinate `(x,y)` on a list, while on a gridded map the very same expression is the
pixel in row `x` and column `y`. Since almost every file now arrives gridded, that
silent difference would decide itself by the data rather than by the script, so
`ebsd(x,y)` is an error now. Ask for the coordinate by name

```matlab
ebsd('xy',x,y)   % the measurement closest to (x,y), grid or list
ebsd(i,j)        % the pixel in row i and column j, gridded map only
```

Both grid classes accept a **rotated** grid now. `@EBSDhex` in particular no longer
stores `dHex` and `isRowAlignment` - those could express only two orientations - but
derives them, together with `offset`, `dx` and `dy`, from the unit cell and the
pixel positions.

### EBSD Analysis No Longer Needs a Grid

Computations that used to require `gridify` now work on any `@EBSD` - a plain list,
a phase subset, or a gridded map alike. This concerns the orientation gradient and
everything built on it: `curvature`, `calcGND` and the gradient method of
`weightedBurgersVec`

```matlab
kappa = curvature(ebsd)      % no ebsd.gridify needed
gnd   = calcGND(ebsd,dS)
```

They are computed on the virtual lattice MTEX derives from the unit cell, so they
also work for grids that are rotated or sheared with respect to the x/y axes, which
the previous matrix based implementation could not do at all - `ebsd.gradientX`
raised an error unless a grid direction happened to lie along an axis. `calcGND`
additionally exists for hexagonal grids now; there simply was no hexagonal
implementation before.

`fill`, `smooth`, `interp` and `weightedBurgersVec` keep the class and the shape
they were given. Previously `fill` and `smooth` turned a plain `@EBSD` into an
`@EBSDsquare`, and `weightedBurgersVec` returned a result shaped like the grid
rather than like the input.

### Corrections Worth Knowing

- `gradientX` on a row aligned hexagonal grid divided by `dHex` where the neighbour
  distance is `sqrt(3)*dHex`, so hexagonal `curvature`, `calcGND` and the gradient
  based `weightedBurgersVec` were wrong by a factor 1.732 in one column of the
  tensor. Values on hexagonal maps change accordingly; square grids are unaffected
- `gridify` of a rotated hexagonal map silently placed several measurements on the
  same cell and kept only the last - 5.2% of a titanium map rotated by 20 degree. It
  now places cells by their lattice index and keeps the measured positions exactly
- `calcGrains(...,'removeQuadruplePoints')` merged the wrong boundary segments and
  destroyed real grain boundary - 0.21% of a forsterite map
- `merge` assigned rather than added its merge matrix in two of the six branches
  collecting the criteria, so a call stating several of them applied only some, and
  which ones depended on the order they were written in -
  `merge(grains,twinBoundary,'inclusions','maxSize',5)` left the twins unmerged.
  Every criterion is applied now, and a numeric value following an option name is no
  longer mistaken for a list of grain pairs
- `export_ang` of a square grid failed in the header with an unrecognized `dx`. It
  works again, and refuses a rotated grid, whose spacings the ang format cannot
  express
- `interp(ebsd,x,y)` with row vectors returned an object whose `length` reported 1,
  and dropped query points when the source was a gridded map

### Plotting EBSD Maps

EBSD and grain maps are drawn through three backends - `imagesc`, `surf` and
`patch`. An axis aligned square grid goes to `imagesc`, any other square grid to
`surf`, a hexagonal grid to `patch`, and inverse pole figure colors are precomputed
via spherical lookup tables. Only `patch` draws one unit cell per pixel, which is
what made large maps slow, so the routing may be overruled by `'backend'` and the
exact unit cells are still available by `'exact'`

```matlab
plot(ebsd,ebsd.orientations)                 % fast, the new default
plot(ebsd,ebsd.orientations,'exact')         % exact unit cells, as before
plot(ebsd,ebsd.orientations,'backend','patch')
```

The micron bar has been rewritten as a `@scaleBar` object - it follows the plotting
convention, rescales while zooming and takes options

```matlab
plot(ebsd,'Location','nw','SBBackgroundColor','k','SBLineColor','w','Length',50)
```

### Reference Frame Annotations

On top of the micron bar a box indicates how the specimen reference frame is aligned
on screen - an arrow for every axis with a component in the screen plane, a circled
dot or cross for the one pointing out of or into it, exactly as in the string form
of `@plottingConvention`. It follows the data when the map is reoriented, e.g. by
`setView`.

What used to be reserved to pole figures now happens on every spherical plot that is
not given in crystal coordinates as well - the axes of the reference frame are
annotated with the axes names of the frame the data lives in: X, Y, Z by default,
X1, Y1, Z1 for the measurement frame of the instrument, RD, TD, ND once the rolling
frame rules the session (see **Named Reference Frames** below). This includes
`@vector3d` and `@S2Fun` plots, `@sigmaSections` and `@pfSections`, spherical
densities as returned by `calcGBND` or `calcDensity`, and `@specimenSymmetry`. Plots
in crystal coordinates - `@Miller`, inverse pole figures, `@ipfSections`, color
keys, single crystal tensors - keep their Miller indices at the vertices of the
fundamental sector instead. Both are customized by the same `pfAnnotations`
preference that pole figures always used, and switched off per plot or for the
session

```matlab
pfAnnotations = @(varargin) text([vector3d.X,vector3d.Y],{'RD','ND'},...
  'BackgroundColor','w','tag','axesLabels',varargin{:});
setMTEXpref('pfAnnotations',pfAnnotations);
```

```matlab
plot(vector3d.rand(100),'noLabel')
plot(ebsd,ebsd.orientations,'refFrame','off')
setMTEXpref('showRefFrame','off')
```

### The Default Plotting Convention

The new default `y↓→x` is `plottingConvention.ij` - x to east, y to south and z into
the screen - as SEM images are displayed and nearly every EBSD import states anyway.
Pole figures are not affected, spherical plots align themselves with the hemisphere
they show. A `@plottingConvention` is stated as a string, each axis followed or
preceded by the direction it points to on screen

```matlab
plot(ebsd,'how2plot','y↑→x')      % also 'x←↑y', 'z⊙→x', ASCII 'y^->x'
```

Plotting conventions are carried by reference frames: data plotted the default way
follows the session's default frame, hence changing the default convention also
turns data imported before

```matlab
plotx2east                                             % turns all data
plottingConvention.default('y↑→x')                     % the same by a string
pC = plottingConvention.default; pC.east = yvector; pC.makeDefault
```

A convention belongs to a frame and never to a data object, so `how2plot` is read
only on every class but `@referenceFrame`. Data is aligned differently by drawing
one plot in another convention as above, by moving the session, or by moving the
data into a frame that carries its own convention - `ebsd.frame =
specimenFrame.rolling`.

### Named Reference Frames

Behind the conventions sits a new class `@referenceFrame` that answers "what
coordinate system is this data expressed in". A frame carries an identity, named
axes and the plotting convention its data is drawn in; `@crystalSymmetry` and
`@specimenSymmetry` delegate their frame data (crystal axes, `how2plot`) to the
frame they hold. Specimen frames come as named session instances

```matlab
specimenFrame.specimen      % the generic frame, axes X, Y, Z - the default
specimenFrame.measurement   % the instrument frame, axes X1, Y1, Z1
specimenFrame.rolling       % RD, TD, ND - RD north, TD west
specimenFrame.geological    % N, E, D
```

and any of them can take over the session by

```matlab
specimenFrame.rolling.makeDefault
```

after which maps, pole figures and the micron bar annotate RD / TD / ND and plot in
the rolling convention - no manual label definition needed. Every data class shows
the frame it lives in at the top of its display, e.g. `EBSD (Y1↓→X1)` or `PoleFigure
(TD←RD↑)`; a crystal frame displays its alignment (`X``a`) and the resulting
convention in crystal directions (`⊙c→a`).

Rotating data by an `@orientation` now moves it from the crystal to the specimen
frame (or back): the result adopts the new frame but never claims the orientation's
symmetry, and mixing frames raises an error instead of silently producing numbers in
an undefined coordinate system. Conventions loaded from `.mat` files are decided by
the container: an `@EBSD` or `@PoleFigure` applies the convention its positions were
saved with to the whole session, individual vectors keep theirs private. Scripted
environments that run many independent jobs in one session can restore the pristine
state by

```matlab
referenceFrame.reset
```

Data without any symmetry can now state the frame it lives in: the trivial group
carrying a frame is a first class citizen, obtained from a symmetry by `cs.stripSym`
or directly from a frame by

```matlab
crystalSymmetry(cF)    % the trivial group on the crystal frame cF
specimenSymmetry(sF)
```

Extrema and samples of a spherical function expressed in a crystal frame
- for instance the deliberately unsymmetrised boundary normal distribution of
  `calcGBND` - therefore come back as `@Miller` with proper crystal indices

```matlab
[value,pos] = max(gbnd)   % pos is a Miller now
```

Along the same lines the compatibility checks behind orientation products and
`@SO3Fun` arithmetic compare the reference frames the coordinates are expressed in,
rather than the symmetry groups: aligned crystal frames combine even when the groups
differ, a compatible frame transition is absorbed automatically, and a wrong sided
product - an orientation applied to data in specimen coordinates - is an error now
instead of a warning.

### Rotating a function drops a symmetry it destroys - now consistently

Rotating an `@SO3Fun` or an `@SO3VectorField` by a rotation which is not one of its
own symmetry elements destroys that symmetry, so the group is dropped and only the
reference frame kept. The twelve `rotate` methods implementing this had drifted into
three different tests for "is there a symmetry to lose", and they disagree for every
non centrosymmetric point group of order two - `2`, `m`, `-4` and friends.
Concretely

```matlab
cs  = crystalSymmetry('2',[1 2 3],[90 100 90]*degree);
odf = unimodalODF(orientation.rand(cs));
rot = rotation.byAxisAngle(vector3d(1,2,3),37*degree);
odf = rotate(odf,rot,'right');
```

warned and dropped the symmetry in `@SO3FunHarmonic`, and silently kept the
- by then false - claim of `2` symmetry in `@SO3FunComposition` and the
  `@SO3VectorField` classes. All of them now warn and drop, which is the correct
  behaviour: the rotated function really is no longer `2` symmetric. If you relied
  on the old silence, the symmetry was already wrong; a result that should keep its
  group has to be rotated by a symmetry element.

### Orientation products follow the same rule

`rot * ori` acts in the specimen frame and so can only destroy the specimen
symmetry; `ori * rot` acts in the crystal frame and destroys the crystal one. Both
now drop the group and keep the frame, through the very same helper. Previously the
product kept the group and merely warned, and the test for "is this a symmetry
element" was a quaternion dot above 0.99
- which is a rotation angle of 16.2 degree, so any rotation up to sixteen degrees
  passed as a symmetry element and not even the warning fired.

This was visible in Detection of Sample Symmetry, which rotates a sample by 15.6
degree in order to destroy its orthotropic symmetry deliberately. The claim of `222`
survived the rotation, the ODF estimated from those orientations was symmetrised
with it, and `centerSpecimen` then had nothing left to find: it returned the
identity, an error of the full 15.6 degree. It now recovers the rotation to 0.8
degree.

### A plotting convention belongs to a reference frame

There are exactly three ways to say how something should be aligned on screen, and a
plotting convention is now always a property of a reference frame rather than of a
data object

```matlab
plot(ebsd,'how2plot','y↑→x')       % this one plot
plottingConvention.default('y↑→x') % the whole session
ebsd.frame = specimenFrame.rolling % move the data to a named frame
```

The first of these is new. Assigning a convention to the data itself, `ebsd.how2plot
= 'y↑→x'`, used to attach a private copy of the session frame to that one object - a
frame that carried the session frame's name and axis labels, was indistinguishable
from it in every display, and then silently stopped following it. `how2plot` is
therefore read only on every class but `@referenceFrame`, where the convention
actually lives. Reading it is unchanged, and `ebsd.frame = []` still means "follow
the session again".

### Importing data no longer changes how the session plots

A file describes its own data, not your screen. Loading an `.mat` file, and
`mtexdata`, no longer repoint the session convention. An import may still state
**which frame** the data lives in - Oxford data lands in `specimenFrame.measurement`
with the axes `X1`, `Y1`, `Z1` - and a convention you pass yourself still applies,
since that is your choice and not the file's.

Documentation pages that want a particular alignment now say so, which they
previously inherited invisibly from `mtexdata`.

This also applies to `S2Fun.smiley`, which used to carry its own convention so the
face always read right - a page that shows it now declares
`plottingConvention.default('y↑→x')` like any other.

### Color Keys Say What They Are

Color keys used to display as MATLAB's dump of their properties, in which every
interesting one read `[1x1 crystalSymmetry]`. They now show the pair of reference
systems they map between in the header, the way an `@orientation` does, and below it
only the settings that distinguish them from a default key

```matlab
ipfKey = ipfColorKey (Titanium (Alpha) → y↓→x)
```

```matlab
  ipfDirection : (0,0,1)
  direction key: HSVDirectionKey
```

A directional color key additionally states which way round its colors run, written
in the axes of its frame - `⊙c→a` for a crystal key. That layout belongs to the
frame of the symmetry and not to the session.

The property `inversePoleFigureDirection` is called `ipfDirection` now, and
`'ipfDirection'` works as a plot option beside the old spelling

```matlab
plot(ebsd,ebsd.orientations,'ipfDirection',vector3d.X)
```

The long name keeps working as an alias, so existing scripts are unaffected.

### Approximation, Sampling and Clustering

Moving least squares approximation supports vector valued data, outlier detection,
smoothly varying support radii and Voronoi weights, and `@planarColorKey` turns any
pair of scalar properties into a color

```matlab
SO3F = SO3FunMLS(ori,values,'delta',5*degree,'detectOutliers')
cK   = planarColorKey(winter,'colorModel','white');
rgb  = cK.property2color(grains.longAxis,grains.aspectRatio);
```

### Tangent Spaces and Vector Valued Functions

A `@SO3TangentVector` stores the symmetries along with the rotation it is attached
to, and for `@SO3VectorFieldHarmonic` the switch between the left and the right
representation is performed directly on the harmonic coefficients. Arrays of vector
valued functions support `cat`, `reshape`, `permute`, `squeeze`, `transpose`,
indexing and assignment - which worked for `@SO3FunHarmonic` only and now works for
`@SO3FunHandle` and `@SO3FunRBF` as well. `@SO3VectorField` comes with the
arithmetic `+,-,.*,./` together with `dot` and `normSquare`, and a `@SO3FunRBF`
draws its pole figures, inverse pole figures and sections directly instead of
through a harmonic approximation.

### Syntax Changes

- `ebsd.CSList` is not a cell array anymore but an array of `@crystalSymmetry` and
  `@notIndexed` objects. In particular a not indexed phase can now carry a name and
  a color

```matlab
ebsd.CSList(1) = notIndexed('amorphous',[0.5 0.5 0.5])
```

- the constructors `quaternion`, `rotation` and `orientation` only accept the syntax
  `quaternion(a,b,c,d)`, `orientation(a,b,c,d,CS,SS)`. Use the named constructors
  `vector3d.byPolar(theta,rho)`, `orientation.byMatrix(M,cs)`, ... instead. Newly
  available are `rotation.byHomochoric`, `rotation.id`, `rotation.nan`,
  `rotation.rand` and `rotation.inversion`
- symmetries are compared on three levels - `cs1 == cs2` checks for the same object,
  `eqTol(cs1,cs2)` for the same Laue group and axes, and `sim(cs1,cs2)` for the same
  lattice with possibly different alignment of x, y, z
- `gB.V` returns the two end points of every boundary segment, the plain list of all
  vertices is `gB.allV`
- `multiplicity` now returns the number of symmetrically equivalent directions,
  fibres or misorientations - the multiplicity as the term is used
  crystallographically, e.g. `multiplicity(Miller(1,0,0,cs))` is 6 in `m-3m` and not
  8. It used to return the reciprocal quantity, the number of symmetry operations
  fixing the input, which contradicted its own help line. The two multiply to the
  order of the group, so the old value is `numSym(cs) ./ multiplicity(m)`. This
  affects `@Miller`, `@orientation` and `@fibre` alike

### Renamed and Removed

- `smooth(grains)` is `smoothBoundary(grains)` now, the old name forwards to the old
  behaviour and warns
- the spherical Bingham distribution `BinghamS2` has been renamed `@S2FunBingham`
  and is fitted by `S2FunBingham.fit(v)`
- `calcGBPD` has been superseded by `calcGBND`
- six EBSD interfaces have been retired to `obsolete/` - `loadEBSD_ACOM`,
  `loadEBSD_sor`, `loadEBSD_csv` and `loadEBSD_Oxfordcsv` as they were unused,
  `loadEBSD_hdf5` and `loadEBSD_h5oina` as they are covered by `loadEBSD_h5`
- `extern/kde` is called `kde1d` now as it used to shadow the `kde` of recent MATLAB
  versions

### Minor Additions

- `transform(ebsd,fun)` and `transform(grains,fun)` apply an arbitrary, not
  necessarily rigid, map to every position - to simulate an instrument distortion or
  to reproject a map
- `ebsd.lattice` is the one place that turns `ebsd.unitCell` and `ebsd.pos` into a
  lattice basis and a per pixel integer index, `ebsd.fixPos` repairs coordinates
  suffering from rounding, `gridify` takes `'rowMajor'` and `'columnMajor'` as well
  as `'unitCell'` to interpolate onto another grid, and a hexagonal grid is
  addressed in cube coordinates by `hex2cube` and `cube2hex`
- `find` on `@orientation`, `@quaternion` and `@vector3d` returns the closest point,
  the k closest points or all points within an epsilon neighborhood, together with
  their distances
- `sqrt`, `smooth` and `invRadon` on `@S2Fun`, the new class `@S2FunGrid`, and every
  `@S2Fun` carries a symmetry, hence a `CS`, a `SS` and a `how2plot`
- screw dislocations of a `@dislocationSystem` have proper Burgers vector lengths
  for hexagonal lattices
- `merge(grains,...,'maxPixel')` takes the mean orientation of the largest grain
  involved instead of averaging
- `doEulerStep(odf,vF,dt,'implicit')` provides an implicit Euler scheme for texture
  evolution
- new spherical Fourier transform based on the double Fourier sphere method, `NFSFT`
  is the default, bandwidths beyond 1023 are supported
- low level exponential and logarithm maps `expRight`, `logRight` on SO(3) and S2,
  arithmetic `+,-,.*,./` for `@SO3Kernel` and `@S2Kernel`, derivatives of `@S1Fun`
- new class `@progressCounter` for progress display, `crystalSymmetry.default` for
  fast default symmetries, `colorcet` perceptually uniform color maps and the flag
  `'zero2white'` for color ranges
- use UTF8 to display (11̅0) instead of (1-10). Requires a suitable font like Julia
  Monospace.

### Under the Hood

- a legend placed outside the axes is laid out by `@mtexFigure`, not by MATLAB,
  which used to leave its distance to the plot depending on how many times the
  figure had been resized. The distance is `'legendSpacing'`, e.g.
  `plot(cS,'colored','legendSpacing',30)`, or `setMTEXpref('legendSpacing',30)`
- an axes is shaped like the shadow its plot box casts on the screen, so that a
  `@crystalShape` no longer sits in a much too wide axes

- markers are drawn as scatter objects throughout, which is faster than the patches
  used before and keeps marker transparency on `print` and `exportgraphics`, where
  it used to be lost in every file format. Lines, i.e. the option `'edgecolor'`,
  remain patches
- the mex files are compiled for every platform on our continuous integration and
  attached to the release, `check_mex` downloads them from there and grain
  reconstruction falls back to a MATLAB Voronoi wherever a mex file is missing.
  `mex_install` reports which source failed to compile rather than failing quietly
- `.mat` files written by MTEX 5.11 load again - the vertex list of a
  `@triplePointList` and the `CSList` of a `@grainBoundary` came back unusable
- `ebsd('phaseName').orientations` carries the plotting convention of the map, and a
  `@specimenSymmetry` displays the convention it holds - `specimenSymmetry.default`
  is where the session wide default lives
- a note about an assumption an import had to make - the Euler correction, the
  `setting` of an EDAX file - is emitted as a warning instead of being printed to
  the error stream, where the command window painted it in the red of a failed
  import. Such notes carry an id, so `warning('off','MTEX:eulerCorrectionAssumed')`
  silences them
- documentation links printed to the command window resolve against a local
  `doc/html` where it is installed and against [the online
  documentation](https://mtex-toolbox.github.io) where it is not - a clone carries
  no generated html, and `web()` on a missing file did nothing at all, no page and
  no error. Line wrapping in the command window no longer breaks such a link apart,
  which it did for every link it ever touched
