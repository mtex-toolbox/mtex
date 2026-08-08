%% Grain Boundary Smoothing
%
%%
% EBSD data is measured on a regular grid, so a grain boundary comes out of
% <EBSD.calcGrains.html |calcGrains|> as a staircase of pixel edges. Every
% segment runs along one of the grid axes, whatever direction the boundary
% actually has - which means the boundary is too long, its direction is
% quantized to a few values, and its curvature is meaningless.
%
% <grain2d.smoothBoundary.html |smoothBoundary|> repairs this.

mtexdata csl
[grains, ebsd] = ebsd.calcGrains('minPixel',3);

grainsSmooth = smoothBoundary(grains,5);

plot(grainsSmooth,grainsSmooth.meanOrientation,'micronbar','off')

%%
% This page is about using it. How it works, and the full list of algorithms
% it can use, is in <GrainSmoothingAdvanced.html Smoothing Algorithms>.

%% What it does
% Three things, in this order: the staircase is removed, the boundary is
% resampled at even spacing, and only then is it smoothed. The first two are
% not cosmetic - smoothing a staircase directly just makes a finer staircase.
%
% Seen on a few grains, against the measured boundary in grey:

plot(grains.boundary,'linewidth',4,'linecolor','LightGray','micronbar','off')
hold on
plot(grainsSmooth.boundary,'linewidth',2,'linecolor','Fuchsia')
hold off
axis([313 353 140 156])

%%
% The staircase overestimates the length of a boundary running at 45 degree by
% |sqrt(2)|, so the total boundary length drops by something of that order

[sum(grains.boundary('indexed').segLength), ...
 sum(grainsSmooth.boundary('indexed').segLength)]

%%
% and the distribution of boundary directions stops being a pair of spikes at
% 0 and 90 degree

figure
subplot(1,2,1)
histogram(grains.boundary('indexed').direction, ...
  'weights',grains.boundary('indexed').segLength,180)
subplot(1,2,2)
histogram(grainsSmooth.boundary('indexed').direction, ...
  'weights',grainsSmooth.boundary('indexed').segLength,180)

%% How much to smooth
% The second argument is the number of smoothing iterations. More of it means
% a smoother boundary, and the scatter around the grid directions keeps
% falling - but see the warning about shrinkage below before turning it up.

iter = [1 5 10 25];
color = copper(length(iter)+1);

plot(grains.boundary,'linewidth',1,'linecolor','LightGray','micronbar','off')
for i = 1:length(iter)
  hold on
  plot(smoothBoundary(grains,iter(i)).boundary('i','i'), ...
    'linewidth',2,'linecolor',color(i,:))
end
hold off
axis([313 353 140 156])

%% Which algorithm - the short version
% The smoothing step itself can be done in several ways, and the choice is
% made by passing a <boundaryFilter.boundaryFilter.html |boundaryFilter|>. For
% practical work there are two that matter.
%
% *Use the default* if the smoothed boundary is for plotting, or for measuring
% directions and lengths. It is a Laplacian, it is fast, and it is what
% |smoothBoundary(grains,5)| selects without being asked.
%
% *Use <taubinFilter.taubinFilter.html |taubinFilter|> if grain areas or shape
% parameters matter.* A Laplacian shrinks - every iteration pulls a convex
% region inwards and nothing bounds how far. Taubin follows each smoothing
% pass by a slightly larger unshrinking one, which stops the drift.

ref = smoothBoundary(grains,0);      % simplified and resampled, not smoothed
A0 = ref.area;
big = A0 > 10*median(grains.boundary.segLength)^2;
A0 = A0(big);

aL = smoothBoundary(grains,25).area;               aL = aL(big);
aT = smoothBoundary(grains,taubinFilter(25)).area; aT = aT(big);

% mean and worst change of grain area over 25 iterations, in percent
[100*mean((aL-A0)./A0), 100*min((aL-A0)./A0); ...
 100*mean((aT-A0)./A0), 100*min((aT-A0)./A0)]

%%
% The first row is the default, the second is Taubin. On a small grain the
% difference is visible - the Laplacian in magenta cuts inside the measured
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

%%
% There is a third option worth knowing about.
% <curvatureFilter.curvatureFilter.html |curvatureFilter|> replaces the
% iteration count by a *length* - the wavelength that gets damped to half
% amplitude. Detail finer than it is removed, detail coarser survives. Since
% it is a length it means the same thing whatever step size the map was
% measured at, so results stay comparable between scans.

F = curvatureFilter;
F.smoothingLength = 4;      % in the units of the map, here um

plot(grains.boundary,'linewidth',4,'linecolor','LightGray','micronbar','off')
hold on
plot(smoothBoundary(grains,F).boundary,'linewidth',2.5,'linecolor','Orange')
hold off
axis([313 353 140 156])

%%
% <huberFilter.huberFilter.html |huberFilter|> exists for faceted materials -
% it keeps genuine corners sharp instead of rounding them off. It is not a
% good default, see <GrainSmoothingAdvanced.html Smoothing Algorithms>.

%% When to switch the first two steps off
% Removing the staircase and resampling change the number of boundary
% segments, and a resampled segment no longer runs between one specific pair
% of pixels. So wherever |gB.ebsdId| is read per segment - to look up the
% orientations on either side of a boundary, for instance - both steps have to
% be off

grainsPlain = smoothBoundary(grains,5,'noSimplify','noRefine');

[length(grains.boundary), length(grainsSmooth.boundary), ...
 length(grainsPlain.boundary)]

%%
% The measured boundary, the smoothed one, and the one smoothed with both
% steps off - only the last keeps one segment per pixel edge.

%% Triple points
% Triple and quadruple points are held fixed, so which grains touch, and
% where, never changes. Pass |'moveTriplePoints'| to let them move as well.
% Be careful with it: it is what allows a small grain to shrink away.

 %#ok<*SAGROW>
