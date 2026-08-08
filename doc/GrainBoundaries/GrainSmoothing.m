%% Grain Boundary Smoothing
%
%%
% EBSD data is measured on a regular grid, so a grain boundary comes out of
% <EBSD.calcGrains.html |calcGrains|> as a staircase of pixel edges. Every
% segment runs along one of the grid axes, whatever direction the boundary
% actually has - which means the boundary is too long, its direction is
% quantized to a few values, and its curvature is meaningless.
%
% <grain2d.smoothBoundary.html |smoothBoundary|> repairs this in three steps.
% Let us look at them one at a time, on a few grains of the csl data set. Which
% algorithm performs the third of them is a separate choice, discussed under
% <GrainSmoothing.html#9 Choosing the algorithm> further down - if you only
% read one line of it, note that the default shrinks your grains and
% |taubinFilter| does not.

mtexdata csl
[grains, ebsd] = ebsd.calcGrains('minPixel',3);

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

d = median(grains.boundary.segLength);

grains_simple = simplifyBoundary(grains,d/sqrt(2));

plot(grains.boundary,'linewidth',5,'linecolor','YellowGreen','micronbar','off')
hold on
plot(grains_simple.boundary,'linewidth',2,'linecolor','Fuchsia')
hold off
axis([313 353 140 156])

%%
% The staircase is gone and the boundary is much shorter, but note how few
% vertices are left - essentially only the corners survived.

[length(grains.boundary), length(grains_simple.boundary)]

%% Step 2: putting the sample points back
% Smoothing the result of step 1 directly would be a mistake. A curved
% boundary is now a handful of long chords, and a Laplacian simply cuts the
% corners off the polygon they form - which shrinks it. <grain2d.refineBoundary.html
% |refineBoundary|> therefore resamples each chain at equal arc length. This
% does not change the shape at all, only how it is sampled, but it gives the
% smoothing evenly spaced degrees of freedom that are no longer tied to the
% grid.

grains_refined = refineBoundary(grains_simple,d);

[length(grains_simple.boundary), length(grains_refined.boundary)]

%% Step 3: smoothing
% Only now does the actual smoothing happen - a constrained Laplacian, which
% replaces every vertex by the mean of its neighbours. Triple points,
% quadruple points and the ends of the inner boundary stay where they are.

grains_smooth = smoothBoundary(grains_refined,5,'noSimplify','noRefine');

plot(grains.boundary,'linewidth',5,'linecolor','YellowGreen','micronbar','off')
hold on
plot(grains_smooth.boundary,'linewidth',2,'linecolor','Fuchsia')
hold off
axis([313 353 140 156])

%% All three at once
% This is exactly what <grain2d.smoothBoundary.html |smoothBoundary|> does on
% its own, and both tolerances are derived from the median segment length
% taken *before* the first step - afterwards the median is the length of the
% straightened runs, not the pixel spacing.

grains_smooth = smoothBoundary(grains,5);

%%
% The total grain boundary length is reduced accordingly. A staircase
% overestimates the length of a 45 degree boundary by |sqrt(2)|, so a
% reduction of that order is what we expect.

sum(grains.boundary('indexed').segLength)
sum(grains_smooth.boundary('indexed').segLength)

%% Boundary directions
% The clearest way to see the grid is the distribution of boundary directions.
% Before smoothing it consists of nothing but spikes at 0 and 90 degree.

histogram(grains.boundary('indexed').direction, ...
  'weights',grains.boundary('indexed').segLength,180)

%%
% Afterwards it is a distribution.

histogram(grains_smooth.boundary('indexed').direction, ...
  'weights',grains_smooth.boundary('indexed').segLength,180)

%% Effect of smoothing iterations
% The second argument is the number of Laplacian iterations. The scatter
% around 0 and 90 degree decreases with it.

iter = [1 5 10 25];
color = copper(length(iter)+1);
plot(grains.boundary,'linewidth',1,'linecolor','Fuchsia','micronbar','off')
d2={};
for i = 1:length(iter)
  gs = smoothBoundary(grains,iter(i));
  hold on
  plot(gs.boundary('i','i'),'linewidth',2,'linecolor',color(i,:))
  d2{i} = gs.boundary('i','i').direction;
end
hold off
axis([313 353 140 156])

%%
% We can compare the histogram of the grain boundary directions of the
% entire map.

figure
for i=1:length(d2)
  subplot(2,2,i)
  histogram(d2{i}, 'weights',norm(d2{i}),180)
end

%% Switching the first two steps off
% Both can be switched off individually. |'noSimplify','noRefine'| leaves the
% plain Laplacian smoothing on the raw staircase.

grains_plain = smoothBoundary(grains,5,'noSimplify','noRefine');

plot(grains_smooth.boundary,'linewidth',2,'linecolor','Fuchsia','micronbar','off')
hold on
plot(grains_plain.boundary,'linewidth',2,'linecolor','DodgerBlue')
hold off
axis([313 353 140 156])

%%
% There is a good reason to do so. The first two steps change the number of
% boundary segments, and a resampled segment no longer runs between one
% specific pair of pixels - so wherever |gB.ebsdId| is read per segment, they
% have to be switched off.

[length(grains_smooth.boundary), length(grains_plain.boundary)]

%%
% Both tolerances may also be given explicitly. A larger |'refine'| length
% means fewer, longer segments, and hence more smoothing per iteration.

grains_coarse = smoothBoundary(grains,5,'simplify',d/sqrt(2),'refine',2*d);

length(grains_coarse.boundary)

%% Choosing the algorithm
% Which algorithm performs the third step is decided by a
% <boundaryFilter.boundaryFilter.html |boundaryFilter|>. They fall into two
% groups. |laplaceFilter| and |taubinFilter| apply a local averaging step a
% fixed number of times, so how far they smooth depends on how densely the
% boundary is sampled. |curvatureFilter| and |huberFilter| instead define the
% smooth boundary as the solution of a minimization problem, stated in terms
% of a *length*, which does not change when the same sample is measured on a
% finer grid.

gL = smoothBoundary(grains,5);                  % laplaceFilter, the default
gT = smoothBoundary(grains,taubinFilter(5));
gC = smoothBoundary(grains,curvatureFilter('smoothingLength',8*d));
gH = smoothBoundary(grains,huberFilter('smoothingLength',8*d));

plot(grains.boundary,'linewidth',3,'linecolor','LightGray','micronbar','off')
hold on
plot(gL.boundary,'linewidth',2,'linecolor','Fuchsia')
plot(gT.boundary,'linewidth',2,'linecolor','DodgerBlue')
plot(gC.boundary,'linewidth',2,'linecolor','Orange')
plot(gH.boundary,'linewidth',2,'linecolor','ForestGreen')
hold off
axis([313 353 140 156])

%% The Laplace filter
% <laplaceFilter.laplaceFilter.html |laplaceFilter|> replaces every vertex by
% a weighted mean of itself and its neighbours, |iter| times. It is the
% default and what |smoothBoundary(grains,5)| selects.
%
% It has one structural weakness: a Laplacian is a low pass filter with gain
% below one everywhere, so it shrinks. Every iteration pulls a convex region
% inwards, without bound. On the forsterite data set the grains lose on
% average 0.3% of their area after 5 iterations and 2.8% after 25 - and the
% worst affected grain loses 72%.

%% The Taubin filter
% <taubinFilter.taubinFilter.html |taubinFilter|> follows every smoothing pass
% by a slightly larger *unshrinking* pass with a negative step, so the gain
% over the pair returns to about one at low frequencies. The shape is smoothed
% and the area is given back: the same 25 iterations that cost the Laplacian
% 2.8% of the average grain area cost Taubin nothing - the mean drift is |+0.9%|
% and the worst grain loses 13% rather than 72%.

%% The curvature filter
% <curvatureFilter.curvatureFilter.html |curvatureFilter|> is the first of the
% variational filters. It minimizes
%
%   |V - V0|^2 + alpha * |L V|^2
%
% in a single sparse solve - there is no iteration count at all, the result
% depends only on |alpha|. And |alpha| is not stated directly but through
% |smoothingLength|, the wavelength that is damped to half amplitude. Detail
% finer than it is removed, detail coarser survives, and because it is a
% length it means the same thing whatever step size the map was measured at.

F = curvatureFilter;
F.smoothingLength = 8*d;
gC = smoothBoundary(grains,F);

plot(grains.boundary,'linewidth',3,'linecolor','LightGray','micronbar','off')
hold on
plot(gC.boundary,'linewidth',2,'linecolor','Orange')
hold off
axis([313 353 140 156])

%% The Huber filter
% <huberFilter.huberFilter.html |huberFilter|> penalizes the same curvature,
% but with a Huber function instead of a square: quadratic below a threshold,
% linear above it. A least squares penalty spreads a large deviation over many
% vertices and so rounds a corner off, whereas an l^1 penalty concentrates it
% in as few vertices as possible and leaves the corner standing. So gentle
% undulations are smoothed exactly as by |curvatureFilter| while a genuinely
% faceted boundary keeps its facets.
%
% Be aware of the trade this makes. On a map whose boundaries are really
% straight or really smooth, the corners it protects are the leftovers of the
% pixel grid, and it is then the *worst* of the four - on a synthetic Voronoi
% map, where every boundary is exactly straight, it doubles the scatter of the
% boundary directions compared to |curvatureFilter|. Reach for it when the
% material is faceted, not by default.

%% Triple points
% <grain2d.smoothBoundary.html |smoothBoundary|> keeps the triple junctions
% locked by default. Sometimes it is necessary to allow them to move.

plot(grains.boundary,'linewidth',1,'linecolor','Fuchsia')
for i = 1:length(iter)
  gs = smoothBoundary(grains,iter(i),'moveTriplePoints');
  hold on
  plot(gs.boundary('i','i'),'linewidth',2,'linecolor',color(i,:))
  d2{i} = gs.boundary('i','i').direction;
end
hold off
axis([313 353 140 156])

%%
% Comparing the grain boundary direction histograms shows that we
% suppressed the gridding effect even a little more.

figure
for i=1:length(d2)
   subplot(2,2,i)
   histogram(d2{i}, 'weights',norm(d2{i}),180)
end

%%
% Be careful, since this allows small grains to shrink with an increasing
% number of iterations. This is what the resampling step protects against: a
% circular grain of 15 pixel radius loses 14% of its area over 25 iterations
% when it is only simplified and then smoothed, against 0.4% when it is
% resampled in between.

 %#ok<*SAGROW>
