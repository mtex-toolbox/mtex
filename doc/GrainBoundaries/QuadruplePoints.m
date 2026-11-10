%% Quadruple Points
%
%%
% A *junction* is a boundary vertex where the number of meeting grain
% boundary segments is not two. On a square measurement grid, four pixels
% meet at every interior vertex. A checkerboard arrangement of two labels
% can therefore create a junction with four boundary segments - a
% *quadruple point*.
%
% The ambiguity is diagonal connectivity. Connecting one pair of like
% pixels separates the other pair, while connecting the other pair reverses
% that decision. The resulting grain count can depend on which diagonal is
% chosen because a grain is a spatially connected region.
%
% Exact four-way contacts in a two-dimensional physical network are usually
% unstable and split into three-segment junctions. The grid contact on this
% page is instead a digital-topology ambiguity introduced by sampling.
% In three dimensions, a physical quadruple point has a different meaning.
%
% <EBSD.calcGrains.html |calcGrains|> resolves this ambiguity during
% reconstruction, and the option |'removeQuadruplePoints',false| keeps the
% four-way contacts. This page assumes the reconstruction concepts
% introduced in <GrainReconstruction.html Grain Reconstruction>.

close all;

% display matrix rows downwards and columns to the right
plottingConvention.default('y↓→x');

%% Construct a diagonal contact
%
% This artificial map contains one crystal phase and two orientations. The
% pixels selected by |id| form a ring whose ends touch diagonally at its
% lower corner.

cs = crystalSymmetry('1','mineral','test');

id = [...
  0 0 0 0 0 0; ...
  0 1 1 1 1 0; ...
  0 1 1 1 1 0; ...
  0 1 0 0 1 0; ...
  0 1 0 0 1 0; ...
  0 1 1 1 0 0; ...
  0 0 0 0 0 0] == 1;

% assign one orientation to the ring and the identity to the background
rot = rotation.id(size(id));
rot(id) = rotation.byEuler(130*degree,120*degree,110*degree);

ebsd = EBSDsquare([],rot,2*ones(size(rot)),1:2,...
  {'not indexed',cs},'dxy',[1 1]);

% compute orientation colours explicitly to keep the output focused
colorKey = ipfColorKey(ebsd);
ebsdColors = colorKey.orientation2color(ebsd.orientations);
plot(ebsd,ebsdColors,'micronbar','off');

%%
% The two colours meet in a checkerboard pattern at the lower contact. The
% picture alone cannot say which diagonal should be connected.

%% Keep the junction
%
% With |'removeQuadruplePoints',false| the reconstruction closes the
% oriented ring at the diagonal contact. It then treats the
% identity-oriented interior and exterior as separate grains, so the map
% contains three grains rather than two.

grainsWithQuadruple = calcGrains(ebsd,'angle',10*degree,...
  'removeQuadruplePoints',false);

fprintf('quadruple point kept: %d grains\n',length(grainsWithQuadruple))

grainColors = colorKey.orientation2color(grainsWithQuadruple.meanOrientation);
plot(grainsWithQuadruple,grainColors,'micronbar','off');
hold on
plot(grainsWithQuadruple.boundary,'lineWidth',2);
hold off

%%
% The interior patch has its own outline. At the diagonal contact, four
% thick boundary segments end at the same vertex.

%% Resolve the junction during reconstruction
%
% Both diagonal pairs here pass the threshold. By default |calcGrains| joins
% the pair whose pixels lie in two different grains, so that joining them
% merges the grains: the interior and the exterior. The ring pixels were
% already connected to each other elsewhere. The expected two grains remain.

grains = calcGrains(ebsd,'angle',10*degree);

fprintf('default reconstruction: %d grains\n',length(grains))
fprintf('total boundary length: %g with the junction, %g without\n',...
  sum(grainsWithQuadruple.boundary.segLength),...
  sum(grains.boundary.segLength))
fprintf('strict triple points: %d\n',length(grains.triplePoints))

grainColors = colorKey.orientation2color(grains.meanOrientation);
plot(grains,grainColors,'micronbar','off');
hold on
plot(grains.boundary,'lineWidth',2);
hold off

%%
% The interior outline has joined the exterior network. The four-segment
% vertex has become two vertices a quarter of a pixel apart, and the two
% joined pixels meet along the neck between them, so the total boundary
% length changes by a fraction of a pixel. In a map of many grains each of
% the two vertices is a junction of three segments. Whether such a junction
% is a strict *triple point* depends on whether it separates three distinct
% real grains, see <TriplePoints.html Triple Points>; this map of two grains
% has none. A contact where neither diagonal pair passes the threshold stays
% a quadruple point.

%% Smooth the neck
%
% <grain2d.smoothBoundary.html |smoothBoundary|> moves every boundary vertex
% within the square of the pixel centres around it, so the neck widens. Its
% default <taubinFilter.html |taubinFilter|> suppresses the pixel staircase
% while limiting the systematic area loss of Laplacian smoothing, and
% afterwards every grain is given its measured area back as far as the
% pixel cells allow.

grains = smoothBoundary(grains);

grainColors = colorKey.orientation2color(grains.meanOrientation);
plot(grains,grainColors,'lineWidth',2,'micronbar','off');

%%
% The neck has opened into a waist about two pixels wide. Smoothing moves
% the geometry; the topological correction was made in the reconstruction.

%% Curvature at the opened contact
%
% Signed <grainBoundary.curvature.html curvature> makes the opened pinch
% visible as neighbouring bends in opposite directions.

gB = grains(1).boundary;

plot(gB,gB.curvature(10),'lineWidth',6,'micronbar','off');
mtexColorMap('blue2red');
setColorRange(0.5*[-1,1]);
mtexColorbar('title','signed curvature in 1/grid unit');

%%
% The blue and red extrema beside the pinch have opposite signs. The sign
% depends on the stored walk direction, so use
% <BoundaryCurvature.html Boundary Curvature> before interpreting it as
% convex or concave relative to a particular grain.

%% References
%
% * T. Y. Kong and A. Rosenfeld,
% <https://doi.org/10.1016/0734-189X(89)90147-3 Digital topology:
% Introduction and survey>, _Computer Vision, Graphics, and Image
% Processing_ 48 (1989), 357--393, develops the adjacency choices behind
% diagonal connectivity on a digital grid.
% * C. Herring,
% <https://doi.org/10.1007/978-3-642-59938-5_2 Surface Tension as a
% Motivation for Sintering>, in _The Physics of Powder Metallurgy_ (1951),
% 143--179, gives the classical capillary balance at physical junctions.
% * P. R. Rios and M. E. Glicksman,
% <https://doi.org/10.1080/14786435.2015.1050476 Grain boundary, triple
% junction and quadruple point mobility controlled normal grain growth>,
% _Philosophical Magazine_ 95 (2015), 2092--2127, distinguishes the roles of
% boundaries, triple junctions, and quadruple points in grain-growth models.

%% Next
%
% Continue with <BoundaryIntersections.html Boundary Intersections> for
% geometric crossings between boundaries and other curves. For the two
% operations used here, see <GrainSmoothing.html Grain Boundary Smoothing>
% and <BoundaryCurvature.html Boundary Curvature>.
