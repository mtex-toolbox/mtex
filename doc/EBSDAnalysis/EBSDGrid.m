%% Gridded EBSD Data
%
%%
% EBSD data is measured on a square or a hexagonal grid, and MTEX keeps it
% on that grid: <EBSD.load.html |EBSD.load|> returns an @EBSDsquare or an
% @EBSDhex whenever the measurements really do sit on one lattice, and falls
% back to a plain list of pixels only when they do not. Which of the two you
% have got is stated by the class of the variable

plottingConvention.default('y↑→x');
mtexdata twins

%%
% This is an @EBSDsquare, i.e. the 22879 measurements are stored as a
% 137 x 167 matrix, one entry per scan position and arranged the way the map
% is. Apart from that it behaves like any other @EBSD variable

plot(ebsd('Magnesium'),ebsd('Magnesium').orientations)

%%
% and a look at the unit cell confirms the square grid

ebsd.unitCell

%% What a Grid Is Good For
%
% * the data can be handed to image processing and registration tools as a
% matrix, and |ebsd(i,j)| addresses a scan position
% * <EBSDPlotting.html plotting> and <EBSDDenoising.html denoising> are
% considerably faster, as the raster does not have to be reconstructed first
%
% Matrix indexing means what it says - the measurement in row 50 and column
% 100 of the map is

ebsd(50,100)

%%
% In the default layout the first matrix dimension is the grid direction
% closest to y and the second one the grid direction closest to x, both
% oriented such that the coordinates increase. Accordingly |ebsd(1,1)| is the
% corner with the smallest coordinates and |ebsd(i,j)| is the j-th pixel of
% the i-th scan row. This is a property of the map and not of the file - it
% is the same whichever corner the acquisition started from and whichever
% direction it scanned in. Pass |'rowMajor'| to <EBSD.gridify.html
% |gridify|> if you want the transposed layout.
%
% A grid is not required nearly as often as it used to be. The
% <EBSD.gradientX.html orientation gradient>, <EBSD.curvature.html
% curvature>, <EBSD.calcGND.html GND> and <EBSD.fill.html fill> are computed
% on the virtual lattice that <EBSD.lattice.html |lattice|> derives from the
% unit cell, and therefore work on arbitrarily aligned data just as well.

%% Choosing the Layout
%
% The first bullet above - hand the data to image processing as a matrix -
% only pays off if the matrix is the way round the picture is. A forescatter
% or BSE image of the same area is stored the way its detector wrote it, and
% that need not be the way MTEX stores a map. Correlating the two, or using
% one as a mask on the other, then needs the map in the image's layout -
% <EBSDMapsAndImages.html Maps and Images> does that with a real map and the
% SEM images taken of the same area.
%
% |'columnMajor'| and |'rowMajor'| are the two layouts aligned with x and y,
% and they are <gridLayout.gridLayout.html |gridLayout|>s like any other. Hand
% |gridify| a different one and the map is stored that way instead. A layout
% names the row direction first, the order |size(A)| is written in. Say the
% picture's rows run against x and its columns along y - a detector mounted a
% quarter turn from the scan

gL = gridLayout(-xvector,yvector)

%%
% Then the map goes into that layout, and its shape follows

ebsdI = gridify(ebsd,gL)

%%
% Nothing was resampled and no value invented: a transpose and two flips are
% all that is ever applied, which is why this is safe to do to orientation
% data. A map states the layout it is in, so it can be read back off

ebsdI.layout

%%
% Every per pixel property comes out in that layout, so band contrast is now
% a matrix that can be put beside an image stored the same way with nothing in
% between. For this particular pair of layouts that is a quarter turn, and it
% really is only that - reindexed, not resampled

isequal(ebsdI.bc, rot90(ebsd.bc))

%%
% Putting it back is therefore exact. The two layouts are a conversion, not a
% transformation, and |ebsd.layout| names the one to come back to

isequal(gridify(ebsdI,ebsd.layout).bc, ebsd.bc)

%%
% Note what has *not* changed. The layout is how the measurements are stored,
% not where the specimen is, so the map still plots the same way up - MTEX
% moves the camera for the screen, never the data

nextAxis
plot(ebsd,ebsd.bc), mtexColorMap gray
title('columnMajor')
nextAxis
plot(ebsdI,ebsdI.bc), mtexColorMap gray
title('row ||-x, col ||y')

%%
% A grid that is rotated or sheared cannot land on an axis aligned layout
% exactly, and is put as close to it as a permutation can get - the same
% best effort |gridify| has always made for the two flags.
% <EBSDsquare.transformReferenceFrame.html |transformReferenceFrame|> is this
% step under its own name, for a map that is already gridded.

%% Data That Can Not Be Put on a Grid
%
% Gridding writes the measurements into a rectangular raster, which is
% faithful only if they really do sit on one lattice. Should two of them
% land in the same cell, one would be lost - so MTEX keeps such a data set
% as a plain list instead, and says why

ebsd = EBSD.load([mtexEBSDPath filesep 'eclogite.ctf'],...
  'EulerCorrection', rotation.byAxisAngle(zvector,180*degree))

%%
% The same happens for a scan whose positions are too irregular to span a
% sensible raster at all. Independently of the data you may always ask for a
% plain list, either for a single import
%
%   ebsd = EBSD.load(fname,'noGrid')
%
% or for the whole session
%
%   setMTEXpref('gridifyOnImport',false)
%
% and you may always change your mind afterwards: |EBSD(ebsd)| flattens a
% gridded map into a list, <EBSD.gridify.html |gridify|> puts a list onto its
% grid.

%% Selecting a Subset Drops the Matrix Shape
%
% It is important to understand that the property of being shaped as a
% matrix is lost as soon as we <EBSDSelect.html select> a subset of the data
% - a phase, a region, the indexed measurements - since what is left is in
% general not a rectangle any more

mtexdata twins silent

ebsdMg = ebsd('Magnesium')

%%
% We may always force it back into matrix form by reapplying the command
% <EBSD.gridify.html |gridify|>

ebsdMg = ebsd('Magnesium').gridify

%%
% The two matrix shaped variables |ebsd| and |ebsdMg| differ in what sits at
% the 46 positions that were not indexed. In |ebsd| those are measurements
% like any other, belonging to the separate phase |'notIndexed'|. In
% |ebsdMg| they were never part of the selection, so |gridify| had nothing
% to put there and left the lattice site empty - its orientation is |NaN|
% and it belongs to no phase at all, which is what an empty |phaseId|
% distinguishes

[nnz(isnan(ebsd.phaseId)), nnz(isnan(ebsdMg.phaseId))]

%%
% Either way the map is a full rectangle, which is what allows to select and
% plot subregions of it in a very intuitive way

plot(ebsdMg(50:100,5:100),ebsdMg(50:100,5:100).orientations)

%% Gridding Reorders the Measurements
%
% <EBSD.gridify.html |gridify|> does not preserve the order in which the
% measurements arrive, and can not: the layout described above fixes the
% first matrix dimension to y, while a |.ctf| or |.ang| file is written with
% x varying fastest, so MATLAB's column major linear indexing runs down the
% map where the file runs across it. After gridding, |ebsd(k)| is therefore
% in general not the measurement in line k of the file any more.
%
% Nothing is lost by that. The original ids are kept as the property
% |oldId|, and looking at its top left corner shows the effect directly -
% consecutive ids run along a matrix row, i.e. across the map, while
% MATLAB's linear index runs down a column

ebsd.oldId(1:3,1:4)

%%
% and the second output of |gridify| is the translation in the other
% direction, i.e. |ebsdGrid.pos(newId)| are the positions of the list in the
% order of the list

[ebsdGrid,newId] = gridify(EBSD(ebsd));

isequal(ebsdGrid.pos(newId), EBSD(ebsd).pos)

%%
% This matters only for code that depends on the order of its input, and
% grain reconstruction does not - <EBSD.calcGrains.html |calcGrains|>
% returns the same grains whether it is handed the list or the map.

%% The Gradient
%
% The orientation gradient, the incomplete Nye tensor and the weighted
% Burgers vector are computed on the virtual lattice and therefore do not
% require a grid. A grid does not hurt either, so we simply continue with
% the map we already have - the result then comes back in the shape of the
% map.

gradX = ebsdMg.gradientX;

plot(ebsdMg,norm(gradX))
setColorRange([0,4*degree])

%% Hexagonal Grids
%
% Nothing above is specific to square grids. Data measured on a hexagonal
% grid is imported as an @EBSDhex and indexed in exactly the same way

mtexdata copper silent

[grains, ebsd] = calcGrains(ebsd);

ebsd

%%

plot(ebsd(1:20,1:40),ebsd(1:20,1:40).orientations,'micronbar','off','edgeColor','black')

%% Switching from Hexagonal to Square Grid
%
% Sometimes it is required to resample EBSD data measured on a hex grid onto
% a square grid. This can be accomplished by passing to the command
% <EBSD.gridify.html |gridify|> a square unit cell by the option |unitCell|.

% define a square unit cell
unitCell = 2.5 * vector3d([-1 -1 1 1].',[-1 1 1 -1].',0);

% use the square unit cell for gridify
ebsdS = ebsd.gridify('unitCell',unitCell)

% visualize the result
plot(ebsd,ebsd.orientations,'layout',[1,2])
nextAxis
plot(ebsdS, ebsdS.orientations)

%%
% Note the difference to gridding a map onto its own lattice: a custom unit
% cell defines a grid the measurements do not lie on, so the values of the
% new pixels are interpolated from the nearest measurements - see
% <EBSD.interp.html |interp|>. The resampled map is complete, but it can
% only be as good as its resolution allows. In the example above we have
% chosen the square unit cell to have approximately the same size as the
% hexagonal one, and since squares can not reproduce the shapes of hexagons
% the grain boundaries come out visibly stair cased. We reduce this by
% choosing the square unit cell significantly smaller than the hexagonal one.

% a smaller unit cell
unitCell = 0.5*vector3d([-1 -1 1 1].',[-1 1 1 -1].',0);

% use the small square unit cell for gridify
ebsdS = ebsd.gridify('unitCell',unitCell)

plot(ebsdS,ebsdS.orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% What is left not indexed in the resampled map are the pixels that were not
% indexed in the source map. Those may be interpolated as well, either by
% <EBSD.fill.html |fill|>, which performs nearest neighbor interpolation, or
% by <EBSD.smooth.html |smooth|>, which allows for more sophisticated
% methods - see <EBSDFilling.html Filling Missing Data>.

%% Rotated Grids
%
% Rotating a map rotates its unit cell along with the positions, so the grid
% survives the rotation and the map remains an @EBSDsquare or an @EBSDhex.
% There is nothing to repair and no data to interpolate.

ebsdR = rotate(ebsd,20*degree)

%%

plot(ebsdR,ebsdR.orientations)

%%
% The same holds if such data reaches MTEX as a plain list - |gridify|
% recovers the rotated lattice, it does not require an axis aligned one

gridify(EBSD(ebsdR))

%% Robustness to Distorted Grids
%
% EBSD is measured on a tilted specimen, and a tilted surface is not imaged
% rigidly: seen from a finite working distance its far edge is further away
% and comes out smaller, so the scan positions no longer sit on a rigid
% lattice. MTEX reconstructs the underlying grid indices of an
% <EBSD.EBSD.html |EBSD|> object robustly under this kind of smooth,
% non-rigid distortion - which matters for <EBSD.gridify.html |gridify|>
% above, but also for any operation that needs the map's grid structure
% internally, such as <EBSD.calcGrains.html |calcGrains|> or the |surf|
% plotting backend.
%
% We demonstrate this on a real map, rather than a small synthetic one,
% since the failure mode this guards against only becomes visible once the
% map is realistically wide - a small toy grid stays safe at distortion
% levels that already break a real, wide map.

mtexdata small

%%
% The command <EBSD.transform.html |transform|> moves every pixel of a map,
% and its unit cell with it, leaving orientations and all other properties
% untouched. It takes a <spatialTransform.html
% |spatialTransform|>, so the distortion is written down as an object rather
% than as a closure - see <EBSDSpatialTransform.html Spatial Transforms>.
%
% A tilt is a projective transform: the surface is seen obliquely, so
% straight lines stay straight but parallel ones need not and the scale
% varies across the frame. Three things state it - how far the surface is
% tilted, how far away it is seen from, and the point it is tilted about.
% The tilt angle foreshortens along the tilt axis, the working distance sets
% how much the scale varies across the frame, and as it grows the
% perspective vanishes and only the foreshortening is left.
%
% This is the tilt one *knows*, written down to impose it. Recovering one
% that was only measured is the other direction, and is what
% <spatialTransformTilt.html |spatialTransformTilt|>
% fits in stages from two images.

theta  = 20*degree;                             % surface tilt
wd     = 8*(max(ebsd.pos.y) - min(ebsd.pos.y)); % working distance
centre = mean(ebsd.pos);                        % what the tilt leaves in place

distort = spatialTransformProjective.byTilt(theta,wd,centre)

%%
% The map is foreshortened along the tilt axis and tapers towards the edge
% that is further away

ebsdDistorted = transform(ebsd, distort);

plot(ebsdDistorted('Fo'),ebsdDistorted('Fo').orientations)
hold on
plot(ebsdDistorted('En'),ebsdDistorted('En').orientations)
plot(ebsdDistorted('Di'),ebsdDistorted('Di').orientations)
hold off

%%
% Every pixel has moved, by up to two and a half cells and by a different
% amount at each end of the map. Most of that is the foreshortening, which
% is affine and which a lattice absorbs without noticing; what a grid
% reconstruction has to survive is the three quarters of a cell that is left
% once the best affine is taken out - more than enough to round a pixel onto
% its neighbour's site. Even so, MTEX recovers exactly the same grid indices
% as for the undistorted map

isequal(ebsdDistorted('Fo').lattice.ij, ebsd('Fo').lattice.ij)

%%
% Drawing the pixels as their unit cells shows what that buys. The cells are
% those of one lattice, followed through the distortion: a mesh that closes
% up, with no cell sheared against its neighbour. A map indexed against a
% rigid lattice instead comes out visibly wavy here, and would hand
% <EBSD.calcGrains.html |calcGrains|> the wrong neighbours with it.

plot(ebsdDistorted('Fo'),ebsdDistorted('Fo').orientations,'unitCell','EdgeColor','black')
hold on
plot(ebsdDistorted('En'),ebsdDistorted('En').orientations,'unitCell','EdgeColor','black')
plot(ebsdDistorted('Di'),ebsdDistorted('Di').orientations,'unitCell','EdgeColor','black')
hold off

%%
% so grain reconstruction runs on the distorted map as it would on the
% undistorted one

grains = calcGrains(ebsdDistorted,'minPixel',3)
grains = smoothBoundary(grains,'noSimplify')

hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
%#ok<*NASGU>
