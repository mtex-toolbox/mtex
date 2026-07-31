%% Gridded EBSD Data
%
%%
% In this section we discuss specific operations that are available for
% EBSD data which are measured on a square or hexagonal grid. 
%
% By default MTEX ignores any gridding in the data. The reason for this is
% that when restricting to some subset, e.g. to a certain phase, the data
% will not form a regular grid anyway. For that reason, almost all
% functions in MTEX are implemented to work for arbitrarily aligned data.
%
% On the other hand, there are certain functions that are only available or
% much faster for gridded data. Those functions include <EBSDPlotting.html
% plotting>, <EBSDGradient.html gradient computation> and
% <EBSDDenoising.html denoising>. The key command to make MTEX aware of
% EBSD data on a hexagonal or square grid is <EBSD.gridify.html |gridify|>.
%
% In order to explain the corresponding concept in more detail lets import
% some sample data.

mtexdata twins

plot(ebsd('Magnesium'),ebsd('Magnesium').orientations)

%%
% As we can see already from the phase plot above the data have been
% measured at an rectangular grid. A quick look at the unit cell verifies
% this

ebsd.unitCell

%%
% If we apply the command <EBSD.gridify.html |gridify|> to the data set

ebsd = ebsd.gridify

%%
% we data get aligned in a 137 x 167 matrix. In particular we may now apply
% standard matrix indexing to our EBSD data, e.g., to access the EBSD data
% at position 50,100 we can simply do

ebsd(50,100)

%% 
% It is important to understand that the property of being shaped as a
% matrix is lost as soon as we <EBSDSelect.html select> a subset of data

ebsdMg = ebsd('Magnesium')

%%
% However, we may always force it into matrix form by reapplying the
% command <EBSD.gridify.html |gridify|>

ebsdMg = ebsd('Magnesium').gridify

%%
% The difference between both matrix shapes EBSD variables |ebsd| and
% |ebsdMg| is that not indexed pixels in |ebsd| are stored as the separate
% phase |'notIndexed'| while in |ebsdMg| all pixels have phase Magnesium
% but the Euler angles of the not indexed pixels are set to |nan|. This
% allows to select and plot subregions of the EBSD map in a very intuitive
% way by

plot(ebsdMg(50:100,5:100),ebsdMg(50:100,5:100).orientations)

%% The Gradient
% Data on a square or hexagonal grid has the additional advantage to allow
% the computation of the orientations gradient, the incomplete Nye tensor,
% as well the weighted Burgers vector.

gradX = ebsdMg.gradientX;

plot(ebsdMg,norm(gradX))
setColorRange([0,4*degree])

%% Hexagonal Grids
%
% Next lets import some data on a hexagonal grid

mtexdata copper silent

[grains, ebsd] = calcGrains(ebsd);
ebsd = ebsd.gridify

plot(ebsd,ebsd.orientations)

%%
% Indexing works here similarly as for square grids

plot(ebsd(1:20,1:40),ebsd(1:20,1:40).orientations,'micronbar','off','edgeColor','black')

%% Switching from Hexagonal to Square Grid
%
% Sometimes it is required to resample EBSD data on a hex grid on a square
% grid. This can be accomplished by passing to the command
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
% In the above example we have chosen the square unit cell to have
% approximately the same size as the hexagonal unit cell. This leads to
% quite some distortions as squares can not reproduces all the shapes of
% the hexagons. We can reduce this issue by choosing the square unit cell
% significantly smaller then the hexagonal unit cell.

% a smaller unit cell
unitCell = 0.5*vector3d([-1 -1 1 1].',[-1 1 1 -1].',0);

% use the small square unit cell for gridify
ebsdS = ebsd.gridify('unitCell',unitCell)
nextAxis
plot(ebsdS,ebsdS.orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% It is important to understand that the command <EBSD.gridify.html
% |gridify|> does not increase the number of data points. As a consequence,
% we end up with many white spots in the map which corresponds to
% orientations that have been set to NaN. In order to fill these white
% spots, we may either use the command <EBSD.fill.html |fill|> which performs
% nearest neighbor interpolation or the command <EBSD.smooth |smooth|> which
% allows for more sophisticated interpolation methods.

%%

% nearest neighbor interpolation
ebsdS1 = fill(ebsdS,grains)

plot(ebsdS1('indexed'),ebsdS1('indexed').orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%

% interpolation using a TV regularization term
F = halfQuadraticFilter;
F.alpha = 0.5;
ebsdS2 = smooth(ebsdS,F,'fill',grains)

nextAxis(1,2)
plot(ebsdS2('indexed'),ebsdS2('indexed').orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%% Gridify on Rotated Maps
% A similar situation occurs if <EBSD.gridify.html |gridify|> is applied to
% rotated data.

ebsd = rotate(ebsd,20*degree);

ebsdG = ebsd.gridify

plot(ebsdG,ebsdG.orientations)

%%
% Again we may observe white spots within the map which we can easily fill
% with the <EBSD.fill.html |fill|> command.

ebsdGF = fill(ebsdG)

plot(ebsdGF,ebsdGF.orientations)

%% Robustness to Distorted (e.g. Trapezoidal) Grids
%
% Real EBSD stages sometimes drift smoothly during a scan rather than
% rotating rigidly. A common signature is a trapezoidal distortion: each
% scan row is stretched or compressed about the map centre by an amount
% that grows with the row's y position, so the same nominally rectangular
% map ends up narrower at one edge than at the other. MTEX reconstructs
% the underlying grid indices of an <EBSD.EBSD.html |EBSD|> object robustly
% under this kind of smooth, non-rigid distortion, including on a phase
% subset - which matters for <EBSD.gridify.html |gridify|> above, and for
% plotting (the |surf| backend).
%
% Grid index recovery being robust does not, on its own, make grain
% reconstruction robust to the same distortion: <EBSD.calcGrains.html
% |calcGrains|> currently still places notIndexed holes and the map's
% outer edge using a rigid (non-distortion-aware) reconstruction, a
% separate, not yet fixed limitation documented in
% EBSDAnalysis/@EBSD/private/spatialDecompositionGrid.m.
%
% We demonstrate this on a real map, rather than a small synthetic one,
% since the failure mode this guards against only becomes visible once the
% map is realistically wide - a small toy grid stays safe at distortion
% levels that already break a real, wide map.

mtexdata forsterite

%%
% The command <EBSD.transform.html |transform|> applies an arbitrary
% function to the position of every pixel, leaving orientations and all
% other properties untouched. Here we scale the x-position of every pixel
% about the map's centre by an amount that grows linearly with y - a
% trapezoidal stage drift of up to |trapFrac| at the top and bottom edges.
% Note that the distortion is defined through the physical y position, not
% through a column of <EBSD.lattice.html |ebsd.lattice.ij|> - which of its
% two columns happens to correspond to rows vs columns depends on an
% internal, unspecified choice of the lattice basis and is not something
% to rely on.

x = ebsd.pos.x; xCenter = (min(x)+max(x))/2;
y = ebsd.pos.y; yCenter = (min(y)+max(y))/2; yHalf = (max(y)-min(y))/2;
trapFrac = 0.05;

distort = @(pos) vector3d( ...
  xCenter + (pos.x-xCenter) .* (1 + trapFrac*(pos.y-yCenter)/yHalf), ...
  pos.y, pos.z);

ebsdDistorted = transform(ebsd, distort);

plot(ebsdDistorted('Fo'),ebsdDistorted('Fo').orientations)

%%
% Even though every row has now shifted by a different amount, MTEX
% recovers exactly the same grid indices as for the undistorted map -
% for the full map as well as for a subset of a single phase, where gaps
% now occur within a scan line and not only between lines.

isequal(ebsdDistorted.lattice.ij, ebsd.lattice.ij)
isequal(ebsdDistorted('Fo').lattice.ij, ebsd('Fo').lattice.ij)





%#ok<*NASGU>