%% Smoothing Algorithms
%
%%
% <GrainSmoothing.html Grain Boundary Smoothing> introduces
% <grain2d.smoothBoundary.html |smoothBoundary|>. This page explains its
% two stages, the tolerances they use, and the four filters available for
% the first stage.
%
% The page assumes that grains have already been reconstructed as in
% <GrainReconstruction.html Grain Reconstruction>. A grain boundary is one
% segment between neighbouring EBSD measurements that belong to different
% grains. A *chain* is a maximal run of those segments from one junction to
% the next. <BoundaryProperties.html Grain Boundary Properties> introduces
% this representation in detail.

close all;
mtexdata csl silent
[grains,ebsd] = ebsd.calcGrains('minPixel',3);

% the pixel spacing
d = median(grains.boundary.segLength);

% compute the colours explicitly to keep the published output quiet
indexed = ebsd('indexed');
colorKey = ipfColorKey(indexed);
ipfColors = colorKey.orientation2color(indexed.orientations);
plot(indexed,ipfColors,'micronbar','off')
hold on
plot(grains.boundary('indexed'),'linewidth',5,'linecolor','YellowGreen')
hold off
axis([313 353 140 156])

%%
% The yellow-green staircase is the measured boundary in the area used
% throughout the page. Its steps follow the square measurement grid rather
% than the physical boundary direction.

%% Step 1: smooth inside the pixel cells
% A vertex of the staircase is a corner of four pixels. Its *cell* is the
% square spanned by their centres, shrunk by |d/20| on every side, where |d|
% is the pixel spacing. On a hexagonal grid a corner belongs to three pixels
% and its cell is a triangle.
%
% The filter moves the vertices in steps. After every step, a vertex that has
% left its cell is moved back to the nearest point of it. While both ends of
% a segment lie in their cells, the segment passes between the two pixel
% centres it was measured between. So no pixel changes sides.
%
% A junction without a cell, in a filled notIndexed region, stays within half
% a pixel spacing. The other vertices of such a region move freely. The pixel
% edges are the segments with a nonzero |gB.pixelDist|, the distance of the
% two pixel centres on either side, which
% <EBSD.calcGrains.html |calcGrains|> records.

grainsCells = smoothBoundary(grains,'noSimplify');

plot(grains.boundary,'linewidth',5,'linecolor','YellowGreen','micronbar','off')
hold on
plot(grainsCells.boundary,'linewidth',2,'linecolor','Fuchsia')
plot(ebsd.x,ebsd.y,'.k','markerSize',6)
hold off
axis([313 353 140 156])

%%
% The magenta boundary cuts across the pixel steps and keeps every black
% pixel centre on its side. It still has one vertex for every pixel corner of
% the staircase.

fprintf('%d of the %d boundary segments are pixel edges\n', ...
  nnz(grains.boundary.pixelDist > 0),length(grains.boundary))

%% Step 2: simplify without crossing a pixel
% <grain2d.simplifyBoundary.html |simplifyBoundary|> runs the Douglas-Peucker
% algorithm on every chain. It replaces a run of vertices by the chord between
% its ends when no vertex lies further than a tolerance from it. Otherwise it
% splits the run at the farthest vertex and tries both halves.
%
% |smoothBoundary| uses a tolerance of |d/10|. That removes what the first
% stage has straightened and keeps every bend. A chord is also refused when
% it would bring the centre of a pixel next to a pixel edge closer than
% |d/20|, or put it on the other side.

grainsSmooth = smoothBoundary(grains);

plot(grains.boundary,'linewidth',5,'linecolor','YellowGreen','micronbar','off')
hold on
plot(grainsSmooth.boundary,'linewidth',2,'linecolor','Fuchsia')
plot(ebsd.x,ebsd.y,'.k','markerSize',6)
hold off
axis([313 353 140 156])

%%
% The magenta boundary keeps a vertex only where it bends. It passes every
% black pixel centre on the same side as the staircase.

fprintf('simplifying takes the boundary from %d segments to %d\n', ...
  length(grainsCells.boundary),length(grainsSmooth.boundary))

%%
% Of several vertices equally far from a chord, the one nearest the middle of
% the run is kept, then the one smallest in x, then in y. So the result
% depends neither on the direction a chain is walked nor on the numbering of
% the grains.
%
% The tolerance may also be set explicitly.

grainsCoarse = smoothBoundary(grains,'simplify',d/2);

fprintf('simplifying at %.2f %s instead leaves %d segments\n', ...
  d/2,grains.scanUnit,length(grainsCoarse.boundary))

%% What simplification changes
% Simplification changes the number of boundary segments. A segment that no
% longer lies between one specific pair of EBSD measurements gets the row
% |[0 0]| in |gB.ebsdId|, as the outer boundary has. Use |'noSimplify'| when an
% analysis needs that per-segment association for every segment.
%
% Smoothing also changes lengths, areas, directions, and curvatures. It is a
% measurement choice, not merely a plotting choice. Record the filter and
% its settings when comparing maps or reporting shape statistics.

%% Choose the filter
% A <boundaryFilter.html |boundaryFilter|> controls the first stage.
% <laplaceFilter.html |laplaceFilter|> and
% <taubinFilter.html |taubinFilter|> apply a local averaging step a fixed
% number of times. Their effect therefore depends on how densely the boundary
% is sampled. <curvatureFilter.html |curvatureFilter|> and
% <huberFilter.html |huberFilter|> instead specify a smoothing length in map
% units, which does not change when the same sample is measured on a finer
% grid. That length makes the setting comparable between scans only when
% their spatial units and preprocessing are also comparable.
%
% Every filter works inside the cells. The averaging filters return each
% vertex to its cell after every step, the other two once after their solve.
%
% Do not expect to distinguish sensible settings by eye on this map. All four
% results lie within a line width of one another, but their sub-pixel
% differences appear in boundary statistics. The following examples therefore
% compare grain areas with those of the measured staircase. Grains with
% areas no greater than |10*d^2| are excluded so that a few-pixel grain does
% not dominate the percentages.

A0 = grains.area;
big = A0 > 10*d^2;
A0 = A0(big);

fprintf('area comparison uses %d of %d grains\n',nnz(big),length(grains))

%% The Laplace filter
% <laplaceFilter.html |laplaceFilter|> replaces each movable vertex by a
% weighted local mean, |iter| times. Repeated averaging pulls a convex grain
% inward. The cells limit how far a vertex of a pixel edge can go, but not
% how often a grain loses area that way.

aL5 = smoothBoundary(grains,laplaceFilter(5)).area;
aL5 = aL5(big);
aL25 = smoothBoundary(grains,laplaceFilter(25)).area;
aL25 = aL25(big);

fprintf('grain area, laplaceFilter\n')
fprintf(['   5 steps %+6.2f%% on average,' ...
  ' %+6.1f%% for the worst grain\n'], ...
  100*mean((aL5-A0)./A0),100*min((aL5-A0)./A0))
fprintf(['  25 steps %+6.2f%% on average,' ...
  ' %+6.1f%% for the worst grain\n'], ...
  100*mean((aL25-A0)./A0),100*min((aL25-A0)./A0))

%% The Taubin filter
% <taubinFilter.html |taubinFilter|> is the default. It follows every
% smoothing pass with a slightly larger unshrinking pass. This approximately
% gives the area back instead of letting the mean area drift downwards. Areas
% still change, so the method is shrinkage resistant rather than exactly area
% preserving.

aT5 = smoothBoundary(grains,5).area;
aT5 = aT5(big);
aT25 = smoothBoundary(grains,25).area;
aT25 = aT25(big);

fprintf('grain area, taubinFilter\n')
fprintf(['   5 steps %+6.2f%% on average,' ...
  ' %+6.1f%% for the worst grain\n'], ...
  100*mean((aT5-A0)./A0),100*min((aT5-A0)./A0))
fprintf(['  25 steps %+6.2f%% on average,' ...
  ' %+6.1f%% for the worst grain\n'], ...
  100*mean((aT25-A0)./A0),100*min((aT25-A0)./A0))

%%
% The grain whose area is closest to 30 square map units sits on the bottom
% edge of the map. Along its upper edge the Laplace result in magenta runs
% just inside the Taubin result in blue.

A = grains.area;
[~,id] = min(abs(A-30));
c = grains(id).centroid;

plot(grains.boundary,'linewidth',4,'linecolor','LightGray','micronbar','off')
hold on
plot(smoothBoundary(grains,laplaceFilter(25)).boundary, ...
  'linewidth',2.5,'linecolor','Fuchsia')
plot(smoothBoundary(grains,25).boundary, ...
  'linewidth',2.5,'linecolor','DodgerBlue')
hold off
axis([c.x-12 c.x+12 c.y-12 c.y+12])

%% The curvature filter
% <curvatureFilter.html |curvatureFilter|> has no step count.
% |smoothingLength| is the wavelength damped to half amplitude, in the units
% of the map. Detail finer than that length is suppressed more strongly, and
% coarser detail survives. This gives the parameter a physical meaning that
% a step count does not have.

F = curvatureFilter;
F.smoothingLength = 8*d;

aC = smoothBoundary(grains,F).area;
aC = aC(big);

fprintf('grain area, curvatureFilter at a smoothing length of %.1f %s\n', ...
  8*d,grains.scanUnit)
fprintf('  %+6.2f%% on average, %+6.1f%% for the worst grain\n', ...
  100*mean((aC-A0)./A0),100*min((aC-A0)./A0))

%% The Huber filter
% <huberFilter.html |huberFilter|> uses the same smoothing length but protects
% sharp corners. Gentle undulations are smoothed like |curvatureFilter|,
% while a genuinely faceted boundary keeps its facets. This protection can
% also preserve corners left by the pixel grid on a boundary that is really
% straight or smooth. Reach for this filter when the material is faceted,
% not by default.
%
% |threshold| is the turning angle at one vertex of the result, not the total
% angle of a corner. Smoothing first spreads a corner over roughly
% |smoothingLength/h| vertices, where |h| is their spacing. The Huber step
% then sharpens it again. A threshold of 15 degree is appropriate for the
% <EBSDDenoising.html |l1TVFilter|> on orientations, but it would
% never activate corner protection here. The default boundary threshold is
% 5 degree.

G = huberFilter;
G.smoothingLength = 8*d;

aH = smoothBoundary(grains,G).area;
aH = aH(big);

fprintf('grain area, huberFilter at the same smoothing length\n')
fprintf('  %+6.2f%% on average, %+6.1f%% for the worst grain\n', ...
  100*mean((aH-A0)./A0),100*min((aH-A0)./A0))

%%
% On a synthetic Voronoi map, whose boundaries are exactly straight,
% |huberFilter| scatters the boundary directions more than |curvatureFilter|.
% It protects raster corners as if they were facets. This is the cost of
% preserving real corners.

%% Junctions and the step count
% A *junction* is a vertex where the number of meeting segments is not two.
% Triple and quadruple points move with the smoothing, each within its cell,
% so the grains that meet there stay the same. A loose end, where an inner
% boundary fades out, stays where it is. The junctions on the outer map boundary and
% the corners of its convex hull remain fixed unless |'moveOuterBoundary'| is
% passed.

iter = [2 5 20 40];
color = copper(length(iter)+1);
dir = cell(size(iter));

plot(grains.boundary,'linewidth',1,'linecolor','LightGray','micronbar','off')
for i = 1:length(iter)
  gs = smoothBoundary(grains,iter(i));
  hold on
  plot(gs.boundary('i','i'),'linewidth',2,'linecolor',color(i,:))
  dir{i} = gs.boundary('i','i').direction;
end
hold off
axis([313 353 140 156])
mtexTitle('2, 5, 20, and 40 steps: dark to light')

%%
% Two and five steps, the dark curves, still follow the pixel corners. The
% light curves of 20 and 40 steps nearly coincide. Once a boundary runs
% straight between its bends, further steps change little.
%
% The direction histograms show the same progression. Each bar is weighted
% by segment length, and each panel is labelled with its step count. The
% radial scales differ, so compare the angular shapes rather than the
% absolute bar heights.

figure
for i = 1:length(dir)
  subplot(2,2,i)
  histogram(dir{i},'weights',norm(dir{i}),180)
  mtexTitle(sprintf('%d steps',iter(i)))
end

%%
% With two and five steps the length still collects in a few directions,
% among them the grid axes. With 20 and 40 steps it spreads over all
% directions.

%% The maths behind the stages
% The cell of a vertex of a pixel edge of length $L$ is a regular polygon
% about the vertex's measured position. It has four faces on a square grid
% and three on a hexagonal one, all at the distance $L/2 - d/20$, one of them
% facing along the edge. A vertex outside is moved onto the face it lies
% furthest beyond, and along that face no further than its corners. That is
% the nearest point of the polygon.
%
% The normalized boundary Laplacian |L| measures how far a vertex lies from
% the mean of its neighbours. The Laplace filter applies a low-pass step with
% gain $1-\lambda k$. Its adjacency includes the vertex itself with the
% weight of its degree. A vertex with two neighbours therefore uses
% |(2*V + Vl + Vr)/4|. The documented default |lambda = 0.5| consequently
% acts at a rate of 0.25. The |'gauss'|, |'exp'|, and |'umbrella'| kernels
% reweight this adjacency by neighbour distance.
%
% The Taubin filter follows that step with a negative step |mu|. The gain of
% a pair is $(1-\lambda k)(1-\mu k)$, which is approximately one at low
% frequencies when |mu| is chosen slightly larger in magnitude than
% |lambda|. High-frequency boundary steps are damped while broad shape is
% restored.
%
% The curvature filter instead finds the vertices $\mathbf{V}$ that minimize
%
% $$\|\mathbf{V}-\mathbf{V}_0\|^2 + \alpha\|L\mathbf{V}\|^2.$$
%
% The minimizer comes from one sparse linear system. The fixed vertices, the
% outer junctions and the corners of the convex hull, are eliminated from
% that system rather than penalized, so they stay exactly in place. On
% vertices sampled at spacing $h$, the filter gain is
% $1/(1+4\alpha\sin^4(\omega/2))$. The value of |smoothingLength| is the
% wavelength damped to half amplitude. Using the exact inverse rather than a
% small-angle approximation matters at short wavelengths: the approximation
% is already 20% wrong at four times the spacing. The implemented cutoff is
% within 0.05% of the requested value from three to 400 times the spacing.
%
% The Huber filter replaces the squared curvature penalty with a Huber
% function. It is quadratic below |threshold| and linear above it. A
% least-squares penalty spreads a large turn over many vertices and rounds a
% corner. A linear, $\ell^1$-like penalty concentrates the turn into fewer
% vertices and preserves the corner. MTEX solves this problem by iteratively
% reweighted least squares until it converges. The |iterMax| property is a
% safety limit, not a smoothing control.
%
% In the second stage, a chord from vertex $a$ to vertex $b$ is refused when a
% pixel centre lies inside the polygon that the run from $a$ to $b$ and the
% chord enclose, or closer than $d/20$ to the chord.

%% References
%
% * S. F. F. Gibson, <https://doi.org/10.1007/BFb0056277 Constrained Elastic
% Surface Nets: Generating Smooth Surfaces from Binary Segmented Data>,
% _MICCAI 1998_, LNCS 1496, 888-898, smooths a voxel surface while holding
% every vertex in its cell, the idea of the first stage.
% * D. H. Douglas and T. K. Peucker,
% <https://doi.org/10.3138/FM57-6770-U75U-7727 Algorithms for the Reduction
% of the Number of Points Required to Represent a Digitized Line or Its
% Caricature>, _The Canadian Cartographer_ 10 (1973), 112-122, introduce the
% line simplification of the second stage.
% * M. de Berg, M. van Kreveld and S. Schirra,
% <https://doi.org/10.1559/152304098782383007 Topologically Correct
% Subdivision Simplification Using the Bandwidth Criterion>, _Cartography and
% Geographic Information Systems_ 25 (1998), 243-257, simplify a line without
% moving it across given points, the constraint of the second stage.
% * G. Taubin, <https://doi.org/10.1145/218380.218473 A Signal Processing
% Approach to Fair Surface Design>, _Proceedings of SIGGRAPH 1995_, 351-358,
% develops the shrinkage-resistant filter used by default.
% * P. J. Huber, <https://doi.org/10.1214/aoms/1177703732 Robust Estimation of
% a Location Parameter>, _The Annals of Mathematical Statistics_ 35 (1964),
% 73-101, gives the corner-preserving penalty of |huberFilter|.
% * <https://www.iso.org/standard/74309.html ISO 13067:2020, Microbeam
% analysis - Electron backscatter diffraction - Measurement of average grain
% size> sets out area-derived EBSD grain-size reporting. It concerns
% two-dimensional sectional measurements and does not turn a smoothing choice
% into a three-dimensional measurement.

%% Next
% Continue with <TwinningBoundaries.html Inferring Twin Boundaries>, where a
% smoothed boundary network is classified by the misorientations across it.
% <BoundaryCurvature.html Boundary Curvature> shows how geometric smoothing
% affects curvature. <ShapeParameters.html Shape Parameters> develops the
% grain areas, perimeters, and shape descriptors that make filter choice a
% quantitative part of an analysis.
