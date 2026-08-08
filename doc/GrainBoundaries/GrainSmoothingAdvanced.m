%% Smoothing Algorithms
%
%%
% <GrainSmoothing.html Grain Boundary Smoothing> shows how to use
% <grain2d.smoothBoundary.html |smoothBoundary|>. This page takes it apart:
% the three steps it performs, the tolerances they use, and the four
% algorithms available for the last of them.

mtexdata csl
[grains, ebsd] = ebsd.calcGrains('minPixel',3);

d = median(grains.boundary.segLength);

plot(ebsd,ebsd.orientations,'micronbar','off')
hold on
plot(grains.boundary('indexed'),'linewidth',5,'linecolor','YellowGreen')
hold off
axis([313 353 140 156])

%% Step 1: removing the grid
% A staircase is never further away than |d/sqrt(2)| from the straight line it
% approximates, |d| being the pixel spacing - the worst case is a boundary at
% 45 degree, whose corners sit exactly that far from the diagonal. So this is
% the tolerance that removes the grid and nothing else, and it is the default
% of <grain2d.simplifyBoundary.html |simplifyBoundary|>, which drops every
% vertex whose removal moves the boundary by less than it.

grains_simple = simplifyBoundary(grains,d/sqrt(2));

plot(grains.boundary,'linewidth',5,'linecolor','YellowGreen','micronbar','off')
hold on
plot(grains_simple.boundary,'linewidth',2,'linecolor','Fuchsia')
hold off
axis([313 353 140 156])

%%
% The staircase is gone and the boundary is much shorter, but note how few
% vertices are left - essentially only the corners survived.

fprintf(['simplifying at a tolerance of %.2f %s takes the boundary' ...
  ' from %d segments to %d\n'], d/sqrt(2), grains.scanUnit, ...
  length(grains.boundary), length(grains_simple.boundary))

%% Step 2: putting the sample points back
% Smoothing the result of step 1 directly would be a mistake. A curved
% boundary is now a handful of long chords, and a Laplacian simply cuts the
% corners off the polygon they form - which shrinks it. A circle of 15 pixel
% radius loses 14% of its area over 25 iterations that way, against 0.4% with
% this step in place. <grain2d.refineBoundary.html |refineBoundary|> therefore
% resamples each chain at equal arc length. This does not change the shape at
% all, only how it is sampled, but it gives the smoothing evenly spaced
% degrees of freedom that are no longer tied to the grid.

grains_refined = refineBoundary(grains_simple,d);

fprintf('resampling at %.2f %s puts them back: %d segments to %d\n', ...
  d, grains.scanUnit, length(grains_simple.boundary), ...
  length(grains_refined.boundary))

%% Step 3: smoothing
% Only now does the actual smoothing happen. Junctions stay where they are
% throughout.

grains_smooth = smoothBoundary(grains_refined,5,'noSimplify','noRefine');

plot(grains.boundary,'linewidth',5,'linecolor','YellowGreen','micronbar','off')
hold on
plot(grains_smooth.boundary,'linewidth',2,'linecolor','Fuchsia')
hold off
axis([313 353 140 156])

%%
% All three together are what |smoothBoundary(grains,5)| does, with both
% tolerances derived from the median segment length taken *before* the first
% step - afterwards the median is the length of the straightened runs, not the
% pixel spacing. Both can also be given explicitly.

grains_coarse = smoothBoundary(grains,5,'simplify',d/sqrt(2),'refine',2*d);

fprintf('resampling at %.2f %s instead leaves %d segments\n', ...
  2*d, grains.scanUnit, length(grains_coarse.boundary))

%% Choosing the algorithm
% Which algorithm performs the third step is decided by a
% <boundaryFilter.boundaryFilter.html |boundaryFilter|>. They fall into two
% groups. |laplaceFilter| and |taubinFilter| apply a local averaging step a
% fixed number of times, so how far they smooth depends on how densely the
% boundary is sampled. |curvatureFilter| and |huberFilter| instead define the
% smooth boundary as the solution of a minimization problem, stated in terms
% of a *length*, which does not change when the same sample is measured on a
% finer grid.
%
% Do not expect to tell them apart by eye. At sensible settings all four land
% within a line width of each other on this map - the differences are real but
% sub-pixel, and they show up in the *statistics* of the boundary rather than
% in a picture of it. So what follows measures instead of plotting.
%
% The reference for all of the numbers below is the boundary after steps 1 and
% 2 but before any smoothing, i.e. zero iterations, restricted to grains
% larger than a few pixels.

ref = smoothBoundary(grains,0);
A0 = ref.area;
big = A0 > 10*d^2;
A0 = A0(big);

%% The Laplace filter
% <laplaceFilter.laplaceFilter.html |laplaceFilter|> replaces every vertex by
% a weighted mean of itself and its neighbours, |iter| times. It is the
% default.
%
% A Laplacian is a low pass filter with gain below one everywhere except at
% zero frequency, so it shrinks: every iteration pulls a convex region
% inwards, and nothing bounds how far.

aL5  = smoothBoundary(grains,5).area;  aL5 = aL5(big);
aL25 = smoothBoundary(grains,25).area; aL25 = aL25(big);

fprintf('grain area, laplaceFilter\n')
fprintf(['   5 iterations %+6.2f%% on average,' ...
  ' %+6.1f%% for the worst grain\n'], ...
  100*mean((aL5-A0)./A0), 100*min((aL5-A0)./A0))
fprintf(['  25 iterations %+6.2f%% on average,' ...
  ' %+6.1f%% for the worst grain\n'], ...
  100*mean((aL25-A0)./A0), 100*min((aL25-A0)./A0))

%%
% The averaging includes a vertex with the weight of its own degree, which is
% how the adjacency comes out of the vertex-segment incidence matrix. For a
% vertex with two neighbours the mean is therefore |(2*V + Vl + Vr)/4|, so the
% documented default |lambda = 0.5| is in truth a rate of 0.25. The other
% kernels - |'gauss'|, |'exp'|, |'umbrella'| - reweight the same adjacency by
% the distance between neighbours.

%% The Taubin filter
% <taubinFilter.taubinFilter.html |taubinFilter|> follows every smoothing pass
% by a slightly larger *unshrinking* pass with a negative step |mu|, so that
% the gain over the pair is |(1-lambda*k)(1-mu*k)|, which is about one over
% the low frequencies. The shape is smoothed and the area is given back.

aT5  = smoothBoundary(grains,taubinFilter(5)).area;  aT5 = aT5(big);
aT25 = smoothBoundary(grains,taubinFilter(25)).area; aT25 = aT25(big);

fprintf('grain area, taubinFilter\n')
fprintf(['   5 iterations %+6.2f%% on average,' ...
  ' %+6.1f%% for the worst grain\n'], ...
  100*mean((aT5-A0)./A0), 100*min((aT5-A0)./A0))
fprintf(['  25 iterations %+6.2f%% on average,' ...
  ' %+6.1f%% for the worst grain\n'], ...
  100*mean((aT25-A0)./A0), 100*min((aT25-A0)./A0))

%%
% The mean stays put instead of marching downwards. On a small grain the
% difference is visible: the Laplacian in magenta cuts inside the measured
% staircase, Taubin in blue follows it.

A = grains.area;
[~,id] = min(abs(A - 30));
c = grains(id).centroid;

plot(grains.boundary,'linewidth',4,'linecolor','LightGray','micronbar','off')
hold on
plot(smoothBoundary(grains,25).boundary,'linewidth',2.5,'linecolor','Fuchsia')
plot(smoothBoundary(grains,taubinFilter(25)).boundary, ...
  'linewidth',2.5,'linecolor','DodgerBlue')
hold off
axis([c.x-12 c.x+12 c.y-12 c.y+12])

%% The curvature filter
% <curvatureFilter.curvatureFilter.html |curvatureFilter|> is the first of the
% variational filters. It minimizes
%
%   |V - V0|^2 + alpha * |L V|^2
%
% where |L| is the normalized Laplacian, so |L V| measures how far a vertex
% sits off the line through its neighbours. There is no iteration count at
% all: the minimizer is the solution of one sparse linear system, and the
% junctions are eliminated from it rather than penalized, so they stay exactly
% where they are.
%
% |alpha| is not stated directly but through |smoothingLength|. On a boundary
% sampled at spacing |h| the filter has gain |1/(1+4*alpha*sin(w/2)^4)|, and
% |smoothingLength| is the wavelength that this damps to half amplitude.
% Inverting that relation exactly rather than for small |w| matters at the
% short end - the small angle form is 20% out already at four times the
% spacing - and the realized cutoff is then within 0.05% of the requested one
% from three times the spacing up to four hundred times it.

F = curvatureFilter;
F.smoothingLength = 8*d;

aC = smoothBoundary(grains,F).area; aC = aC(big);

fprintf('grain area, curvatureFilter at a smoothing length of %.1f %s\n', ...
  8*d, grains.scanUnit)
fprintf('  %+6.2f%% on average, %+6.1f%% for the worst grain\n', ...
  100*mean((aC-A0)./A0), 100*min((aC-A0)./A0))

%% The Huber filter
% <huberFilter.huberFilter.html |huberFilter|> penalizes the same curvature,
% but with a Huber function instead of a square: quadratic below a threshold,
% linear above it. A least squares penalty spreads a large deviation over many
% vertices and so rounds a corner off, whereas an |l^1| penalty concentrates
% it in as few vertices as possible and leaves the corner standing. Gentle
% undulations are therefore smoothed exactly as by |curvatureFilter| while a
% genuinely faceted boundary keeps its facets. It is solved by iteratively
% reweighted least squares, run to convergence, so |iterMax| is a safety limit
% rather than a tuning knob.
%
% |threshold| is the turning angle *at a single vertex of the result*, not the
% total angle of the corner - the smoothing spreads a corner over roughly
% |smoothingLength/h| vertices before the reweighting sharpens it back. On a
% rasterized hexagon smoothed with |smoothingLength = 8*h| the 60 degree
% corners come back as
%
%  threshold    30    15     8     4     2   degree
%  corner       22    28    49    68    80   degree
%
% so a threshold of 15 degree, the value that is right for the
% <EBSDDenoising.html |halfQuadraticFilter|> on orientations, would never fire
% here. The default is 5 degree.

G = huberFilter;
G.smoothingLength = 8*d;

aH = smoothBoundary(grains,G).area; aH = aH(big);

fprintf('grain area, huberFilter at the same smoothing length\n')
fprintf('  %+6.2f%% on average, %+6.1f%% for the worst grain\n', ...
  100*mean((aH-A0)./A0), 100*min((aH-A0)./A0))

%%
% Be aware of the trade this makes. On a map whose boundaries are really
% straight or really smooth, the corners it protects are the leftovers of the
% pixel grid. On a synthetic Voronoi map, where every boundary is exactly
% straight and the true answer is therefore known, it doubles the scatter of
% the boundary directions compared with |curvatureFilter|. Reach for it when
% the material is faceted, not by default.

%% Moving the triple points
% All of the above holds the junctions fixed, so which grains touch, and
% where, is unchanged. |'moveTriplePoints'| releases them.

iter = [1 5 10 25];
color = copper(length(iter)+1);

plot(grains.boundary,'linewidth',1,'linecolor','LightGray','micronbar','off')
dir = {};
for i = 1:length(iter)
  gs = smoothBoundary(grains,iter(i),'moveTriplePoints');
  hold on
  plot(gs.boundary('i','i'),'linewidth',2,'linecolor',color(i,:))
  dir{i} = gs.boundary('i','i').direction;
end
hold off
axis([313 353 140 156])

%%
% It suppresses the gridding effect a little further, at the price of letting
% small grains shrink away - with a Laplacian there is nothing to stop them.

figure
for i=1:length(dir)
  subplot(2,2,i)
  histogram(dir{i},'weights',norm(dir{i}),180)
end

 %#ok<*SAGROW>
