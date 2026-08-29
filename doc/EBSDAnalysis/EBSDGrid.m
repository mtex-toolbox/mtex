%% Gridded EBSD Data
%
%%
% Most EBSD maps are measured on a square or hexagonal scan lattice. By
% default, <EBSD.load.html |EBSD.load|> keeps that structure: it returns an
% @EBSDsquare or @EBSDhex whenever every measurement fits on one lattice.
% Otherwise it keeps the measurements as a plain @EBSD list and explains why.
%
% This page assumes basic <EBSDSelect.html EBSD selection> and
% <EBSDPlotting.html plotting>. See <EBSDIndex.html Select by Index> first if
% MATLAB row and column indexing is unfamiliar.
%
% A scan lattice, a matrix layout, and a reference frame answer different
% questions. The lattice says which measurements are neighbours. The layout
% says which specimen directions the matrix indices follow. The reference
% frame says which axes the positions and orientations are expressed in.

plottingConvention.default('y↑→x');
mtexdata twins

%%
% The summary identifies |ebsd| as an @EBSDsquare. Its 22879 measurements
% form a 137 by 167 matrix, with one entry per scan position. Apart from its
% matrix shape, it behaves like any other @EBSD variable.

plot(ebsd('Magnesium'),ebsd('Magnesium').orientations)

%%
% The rectangular outline follows the square measurement grid. The four
% corners of one pixel give the same information directly.

ebsd.unitCell

%% What a Grid Is Good For
%
% * Per-pixel data can be handed to image-processing and registration tools
% as a matrix, and |ebsd(i,j)| addresses one scan position.
% * <EBSDPlotting.html Plotting> and <EBSDDenoising.html denoising> are
% considerably faster because the raster does not have to be reconstructed.
%
% Matrix indexing means what it says. The measurement in row 50 and column
% 100 is

ebsd(50,100)

%%
% In the default layout, the first matrix dimension follows the grid
% direction closest to y. The second follows the direction closest to x.
% Both indices advance towards increasing coordinates. Thus |ebsd(1,1)| is
% the corner with the smallest coordinates, and |ebsd(i,j)| is the j-th
% pixel in the i-th scan row.
%
% This layout belongs to the map, not to the file traversal order. It is the
% same whichever corner the acquisition started from. Pass |'rowMajor'| to
% <EBSD.gridify.html |gridify|> for the transposed layout.
%
% A stored matrix is not required nearly as often as it once was. The
% <EBSD.gradientX.html orientation gradient>, <EBSD.curvature.html
% curvature>, <EBSD.calcGND.html GND>, and <EBSD.fill.html fill> operate on
% the virtual lattice derived by <EBSD.lattice.html |lattice|>. They also
% work on plain lists, phase subsets, and arbitrarily aligned maps.

%% Choosing the Layout
%
% A matrix is useful for image processing only when it is stored the same
% way round as the image. A forescatter or BSE image follows the order in
% which its detector wrote the pixels. That order need not match the map.
% <EBSDMapsAndImages.html Maps and Images> compares a real map with SEM
% images of the same area.
%
% |'columnMajor'| and |'rowMajor'| are the two layouts aligned with x and y.
% Both are <gridLayout.gridLayout.html |gridLayout|> objects. A layout names
% the row direction first, in the same order as |size(A)|. Suppose an
% image's rows run against x and its columns run along y, as for a detector
% mounted a quarter turn from the scan.

gL = gridLayout(-xvector,yvector)

%%
% Handing that layout to |gridify| changes the matrix shape and ordering.

ebsdI = gridify(ebsd,gL)

%%
% The map records the layout in which it is stored.

ebsdI.layout

%%
% Every per-pixel property follows the same layout. For this pair of
% layouts, band contrast is related by a quarter turn.

isequal(ebsdI.bc, rot90(ebsd.bc))

%%
% No value was resampled or invented. A transpose and flips are sufficient,
% so conversion back to the original layout is exact.

isequal(gridify(ebsdI,ebsd.layout).bc, ebsd.bc)

%%
% Layout changes storage, not the specimen. The positions and orientations
% are unchanged, and the plotting convention still draws both maps in the
% same specimen frame.

newMtexFigure('layout',[1,2])
plot(ebsd,ebsd.bc), mtexColorMap gray
title('columnMajor')
nextAxis
plot(ebsdI,ebsdI.bc), mtexColorMap gray
title('row against x, column along y')

%%
% The same features occupy the same screen positions in both panels. Only
% the labels describe a different order in memory.
%
% A rotated or sheared grid cannot match an axis-aligned layout exactly.
% |gridify| chooses the nearest transpose-and-flip permutation, just as it
% does for the two named flags. For an already gridded map,
% <EBSDsquare.transformReferenceFrame.html |transformReferenceFrame|>
% performs the same reindexing. Despite that method name, this operation is
% not a frame change: it does not re-express the specimen in different axes.

%% Data That Cannot Be Put on a Grid
%
% A rectangular raster is faithful only when every measurement occupies a
% distinct site of one lattice. If two measurements land in the same cell,
% one would be lost. MTEX therefore keeps such data as a list and reports
% the collision rather than silently dropping a measurement.

ebsd = EBSD.load([mtexEBSDPath filesep 'eclogite.ctf'],...
  'EulerCorrection', rotation.byAxisAngle(zvector,180*degree))

%%
% The warning above gives the number of colliding measurements. MTEX also
% keeps a list when the positions are too irregular to span a sensible
% raster. You may request a list independently of the data, either for one
% import,
%
%   ebsd = EBSD.load(fname,'noGrid')
%
% or for the whole session.
%
%   setMTEXpref('gridifyOnImport',false)
%
% You may change representation later. |EBSD(ebsd)| flattens a gridded map
% into a list, while <EBSD.gridify.html |gridify|> puts a list on its grid.

%% Selecting a Subset Drops the Matrix Shape
%
% Selecting a phase, region, or indexed measurements usually leaves a shape
% that is not rectangular. The result is therefore a plain list, although
% every retained measurement still lies on the original lattice.

mtexdata twins silent

ebsdMg = ebsd('Magnesium')

%%
% Reapplying <EBSD.gridify.html |gridify|> restores the matrix shape.

ebsdMg = ebsd('Magnesium').gridify

%%
% The variables |ebsd| and |ebsdMg| differ at the 46 positions that were not
% indexed. In |ebsd| those are real measurements in the separate
% |'notIndexed'| phase: a diffraction pattern was recorded but could not be
% indexed. Selecting magnesium removes those measurements and creates gaps,
% meaning missing sites within scan lines.
%
% After |gridify|, each gap is an empty lattice site in |ebsdMg|. Its
% orientation and |phaseId| are |NaN| because no selected measurement
% belongs there. It is not a notIndexed measurement.

[nnz(isnan(ebsd.phaseId)), nnz(isnan(ebsdMg.phaseId))]

%%
% The empty sites complete the rectangle. Row and column ranges can
% therefore select and plot a rectangular subregion.

plot(ebsdMg(50:100,5:100),ebsdMg(50:100,5:100).orientations)

%% Gridding Reorders the Measurements
%
% <EBSD.gridify.html |gridify|> does not preserve input order, and generally
% cannot. The layout fixes the first matrix dimension to y, whereas |.ctf|
% and |.ang| files usually write x fastest. MATLAB linear indexing runs down
% a matrix column, while such a file runs across the map. Consequently,
% |ebsd(k)| after gridding is generally not line k of the input file.
%
% Nothing is lost. The property |oldId| keeps the original ids. Its upper
% left corner shows consecutive ids running along matrix rows, while MATLAB
% linear indices run down columns.

ebsd.oldId(1:3,1:4)

%%
% The second output of |gridify| translates in the other direction. In
% particular, |ebsdGrid.pos(newId)| returns the gridded positions in the
% order of the input list.

[ebsdGrid,newId] = gridify(EBSD(ebsd));

isequal(ebsdGrid.pos(newId), EBSD(ebsd).pos)

%%
% This distinction matters only to code that depends on input order. Grain
% reconstruction does not: <EBSD.calcGrains.html |calcGrains|> returns the
% same grains from the list and from the map.

%% The Gradient
%
% The orientation gradient, the incomplete Nye tensor, and the gradient
% form of the weighted Burgers vector are computed on the virtual lattice.
% They therefore do not require a stored matrix. The default integral form
% of the weighted Burgers vector is a raster algorithm and grids internally.
%
% A grid does no harm, so this example continues with |ebsdMg|. The result
% has the same matrix shape as the map.

gradX = ebsdMg.gradientX;

plot(ebsdMg,norm(gradX))
setColorRange([0,4*degree])

%%
% The colour field follows the same rectangular raster, including its empty
% sites. No separate gridding step was needed for the derivative itself.

%% Hexagonal Grids
%
% The same principles apply to a hexagonal scan. MTEX imports it as an
% @EBSDhex and provides the same row and column indexing.

mtexdata copper silent

[grains, ebsd] = calcGrains(ebsd);

ebsd

%%

plot(ebsd(1:20,1:40),ebsd(1:20,1:40).orientations,...
  'micronbar','off','edgeColor','black')

%%
% The black cell edges reveal the alternating half-step offset between scan
% rows. The matrix is rectangular even though its pixel footprints are
% hexagons.

%% Switching from a Hexagonal to a Square Grid
%
% Some external image-processing tools require square pixels. Passing a
% square |unitCell| to <EBSD.gridify.html |gridify|> resamples the hexagonal
% measurements onto such a grid.

% define a square unit cell
unitCell = 2.5 * vector3d([-1 -1 1 1].',[-1 1 1 -1].',0);

% use the square unit cell for gridify
ebsdS = ebsd.gridify('unitCell',unitCell)

% visualize the result
plot(ebsd,ebsd.orientations,'layout',[1,2])
nextAxis
plot(ebsdS,ebsdS.orientations)

%%
% This operation differs fundamentally from restoring a map's own lattice.
% The new grid sites do not coincide with the measured ones, so
% <EBSD.interp.html |interp|> copies values from the nearest measurements.
% The left panel shows the measured hexagons; the right shows the square
% pixels after resampling.
%
% The square cell above has approximately the same size as the hexagonal
% one. Squares cannot reproduce hexagonal outlines, so grain boundaries in
% the right panel are visibly staircased. A smaller square cell reduces the
% size of the steps.

% a smaller unit cell
unitCell = 0.5*vector3d([-1 -1 1 1].',[-1 1 1 -1].',0);

% use the small square unit cell for gridify
ebsdS = ebsd.gridify('unitCell',unitCell)

plot(ebsdS,ebsdS.orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% The smaller cells follow the original boundary more closely. They do not
% add spatial resolution: every new orientation still comes from a nearest
% measured hexagon. <EBSDInter.html Regridding and Interpolation> develops
% this distinction in detail.
%
% Pixels that remain notIndexed correspond to measurements that were not
% indexed in the source map. <EBSD.fill.html |fill|> may replace them by
% nearest-neighbour interpolation. <EBSD.smooth.html |smooth|> offers more
% sophisticated methods; see <EBSDFilling.html Filling Missing Data>.

%% Rotated Grids
%
% Rotating a map rotates its unit cell together with its positions. The
% lattice therefore survives, and the map remains an @EBSDsquare or
% @EBSDhex. Nothing needs repair or interpolation.

ebsdR = rotate(ebsd,20*degree)

%%

plot(ebsdR,ebsdR.orientations)

%%
% The map is turned on screen, while the object summary still identifies a
% hexagonal grid. If the same data arrives as a plain list, |gridify|
% recovers the rotated lattice without requiring axis alignment.

gridify(EBSD(ebsdR))

%% Robustness to Distorted Grids
%
% EBSD is measured on a tilted specimen. Seen from a finite working
% distance, the far edge is farther away and appears smaller. The measured
% positions can therefore depart smoothly from any single rigid lattice.
% MTEX still reconstructs the underlying grid indices of an
% <EBSD.EBSD.html |EBSD|> object. This matters to |gridify| and to every
% operation that needs neighbours, including <EBSD.calcGrains.html
% |calcGrains|> and the |surf| plotting backend.
%
% Grid reconstruction uses a local deformation model. MTEX first fits an
% ideal affine grid. It then interpolates the local deviation between the
% measured positions and that grid wherever a cell has no measurement.
% Thus a gap, a notIndexed hole, and the dummy cells used to bound the map
% follow the measured distortion rather than an unrelated rigid lattice.
%
% These terms are distinct. A gap is a run of measurements removed from a
% scan line, such as by selecting one phase. A hole is a connected
% notIndexed area inside the scanned region. A dummy cell is a synthetic
% cell beyond the scanned edge; it has no id and never becomes a grain.
%
% The example uses a real map because the failure appears only when the map
% is realistically wide. A small synthetic grid remains safe at distortion
% levels that already misindex a wide map.

mtexdata small

%%
% <EBSD.transform.html |transform|> moves every pixel and its unit cell. It
% leaves orientations and all other per-pixel properties untouched. The
% command takes a <spatialTransform.html |spatialTransform|>, which records
% the mapping as an object; see <EBSDSpatialTransform.html Spatial
% Transforms>.
%
% A tilt is a projective transform. Straight lines remain straight, but
% parallel lines need not, and scale varies across the frame. Three values
% specify it: the surface tilt, the working distance, and the point left in
% place. |byTilt| tilts about the x axis, so the tilt angle foreshortens the
% map across that axis, along y. The working distance controls perspective,
% which vanishes as that distance grows.
%
% Here the tilt is known and imposed. Recovering an unknown tilt from two
% measured images is the inverse problem. <spatialTransformTilt.html
% |spatialTransformTilt|> fits it in stages.

theta  = 20*degree;                             % surface tilt
wd     = 8*(max(ebsd.pos.y) - min(ebsd.pos.y)); % working distance
centre = mean(ebsd.pos);                        % what the tilt leaves in place

distort = spatialTransformProjective.byTilt(theta,wd,centre)

%%
% The map is compressed along y, from 3000 to 2820 micrometres, while the x
% extent is left alone by the tilt and only stretched by perspective. It
% tapers towards the edge that is farther away.

ebsdDistorted = transform(ebsd,distort);

plot(ebsdDistorted('Fo'),ebsdDistorted('Fo').orientations)
hold on
plot(ebsdDistorted('En'),ebsdDistorted('En').orientations)
plot(ebsdDistorted('Di'),ebsdDistorted('Di').orientations)
hold off

%%
% The following pair measures the imposed distortion in cell units. Its
% first value is the maximum pixel displacement. Its second is the largest
% residual after the best affine grid has been removed.

pos0 = [ebsd.pos.x(:),ebsd.pos.y(:)];
posD = [ebsdDistorted.pos.x(:),ebsdDistorted.pos.y(:)];
ijD = double(ebsdDistorted.lattice.ij);
isIndexed = ebsdDistorted.isIndexed(:);
affineDesign = [ones(size(ijD,1),1),ijD];
affineFit = affineDesign(isIndexed,:) \ posD(isIndexed,:);
cellSize = ebsd.lattice.dxy;
distortionInCells = [max(vecnorm(posD-pos0,2,2)),...
  max(vecnorm(posD-affineDesign*affineFit,2,2))] / cellSize

%%
% Every pixel has moved by up to 2.48 cells. Once the affine foreshortening
% is removed, 0.80 cell remains. That is enough for a rigid reconstruction
% to round a pixel onto its neighbour's site. Even so, MTEX recovers the
% same grid indices as for the undistorted map.

isequal(ebsdDistorted('Fo').lattice.ij, ebsd('Fo').lattice.ij)

%%
% Drawing each measurement as its unit cell shows the result. The cells form
% one continuous deformed mesh, with no cell sheared independently of its
% neighbours. A rigid reconstruction would make the mesh wavy and would
% give <EBSD.calcGrains.html |calcGrains|> the wrong neighbours.

plot(ebsdDistorted('Fo'),ebsdDistorted('Fo').orientations,...
  'unitCell','EdgeColor','black')
hold on
plot(ebsdDistorted('En'),ebsdDistorted('En').orientations,...
  'unitCell','EdgeColor','black')
plot(ebsdDistorted('Di'),ebsdDistorted('Di').orientations,...
  'unitCell','EdgeColor','black')
hold off

%%
% Grain reconstruction consequently sees the distorted map as the same
% neighbourhood graph as the original.

grains = calcGrains(ebsdDistorted,'minPixel',3)
grains = smoothBoundary(grains,'noSimplify');

hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% The boundary overlay remains closed and follows the tapered map. No
% duplicated or missing grain strips appear along its edges.

%% Further Reading
%
% * R. C. Staunton,
% <https://doi.org/10.1016/S1076-5670(08)70188-5 _Hexagonal Sampling in
% Image Processing_>, Advances in Imaging and Electron Physics 107,
% 231--307 (1999), reviews the geometry and image-processing consequences
% of hexagonal sampling.
% * V. S. Tong and T. B. Britton,
% <https://doi.org/10.1016/j.ultramic.2020.113130 _TrueEBSD: Correcting
% spatial distortions in electron backscatter diffraction maps_>,
% Ultramicroscopy 221, 113130 (2021), separates tilt and drift distortion
% and demonstrates pixel-scale correction.
% * Y. B. Zhang, A. Elbrønd and F. X. Lin,
% <https://doi.org/10.1016/j.matchar.2014.08.003 _A method to correct
% coordinate distortion in EBSD maps_>, Materials Characterization 96,
% 158--165 (2014), treats nonlinear drift by registering an EBSD map to a
% reference image.
% * <https://www.iso.org/standard/74309.html ISO 13067:2020>, _Microbeam
% analysis - Electron backscatter diffraction - Measurement of average
% grain size_, defines EBSD grain-size measurement on two-dimensional
% sections. Consult it before treating a resampled raster as quantitative
% evidence about spatial resolution or grain size.

%% Next
%
% <EBSDMapsAndImages.html Maps and Images> uses layouts to compare an EBSD
% map with detector images pixel by pixel. <EBSDInter.html Regridding and
% Interpolation> develops resampling onto a different lattice.
% <EBSDSpatialTransform.html Spatial Transforms> introduces the transform
% models used above, and <EBSDTrueEbsd.html TrueEBSD Distortion Correction>
% fits them to measured images. Continue with <GrainReconstruction.html
% Grain Reconstruction> when the goal is to turn measurements into grains.

%%
%#ok<*NASGU>
