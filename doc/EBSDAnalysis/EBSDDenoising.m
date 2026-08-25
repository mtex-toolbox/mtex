%% Denoising Orientation Maps
%
%%
% Every measured orientation is a little wrong. Part of that error is
% systematic - a badly calibrated system turns the whole map the same way -
% and no filter can find it, because nothing in the data says it is there.
% The rest is random: a noisy Kikuchi pattern, the tolerance of the
% indexing algorithm, and each measurement scattered independently of its
% neighbours. Random error is what this page removes, by using the fact
% that neighbouring points in a real specimen are nearly always nearly
% equal.
%
% Filling in points that could not be indexed at all is a different
% operation, described in <EBSDFilling.html Filling Missing Data>.
%
%% Making the noise visible
%
% The example is a map of deformed magnesium.

% import the data
plottingConvention.default('y↑→x');
mtexdata twins

% reconstruct the grain structure
[grains,ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',5);

% smooth grain boundaries
grains = smoothBoundary(grains,5);

% consider only indexed data
ebsd = ebsd('indexed');

% plot the orientation map
ipfKey = ipfColorKey(ebsd.CS.properGroup);
plot(ebsd,ipfKey.orientation2color(ebsd.orientations))

% and on top the grain boundaries
hold on
plot(grains.boundary,'linewidth',2,'linecolor','white')
hold off

%%
% There is no noise to be seen, and that is a property of the colour key
% rather than of the data: a whole grain is one colour, and an error of a
% fraction of a degree does not change that colour visibly. Subtracting the
% grain mean orientation from every point puts what is left on a scale
% where it can be seen.

% the axisAngleColorKey colorizes misorientation according to their axis and angle
colorKey = axisAngleColorKey;

% we set the reference orientations as the mean orientation of each grain
colorKey.oriRef = grains(ebsd.grainId).meanOrientation;

plot(ebsd,colorKey.orientation2color(ebsd.orientations))
hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% Two things are in this picture at once. The smooth gradients across the
% larger grains are real - that is how a deformed crystal bends - and the
% pixel to pixel speckle laid over them is not. On average a point deviates
% from its grain mean by 0.70°, and the job of a filter is to take the
% speckle out of that number while leaving the gradient alone.
%
% All filters are applied by <EBSD.smooth.html |smooth|>. Two of them are
% worth using in practice, and the rest of this page is about why.
%
%% The total variation filter
%
% The @halfQuadraticFilter is a variational filter: rather than averaging a
% window, it looks for the map that is at once close to the measurements
% and smooth, and a parameter decides which of the two matters more. What
% "smooth" means is the interesting part. By default it is the
% <https://en.wikipedia.org/wiki/Total_variation_denoising total variation>,
% which is small for a map made of flat pieces with jumps between them - so
% the filter preserves a subgrain boundary instead of averaging across it.
% The price is the same as for the @medianFilter: a tendency towards
% cartoon like patches and staircases.

F = halfQuadraticFilter;

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% The speckle is gone and the gradients have survived. The average
% deviation from the grain mean is now 0.58°, so about a sixth of the
% scatter was noise; the remainder is the deformation, which is signal and
% should not go anywhere.
%
%% The smoothing spline filter
%
% The @splineFilter is the one |smooth| uses when no filter is named. It is
% variational as well, but measures smoothness by the curvature of the
% orientation map, which makes the result round rather than faceted, and
% smooths subgrain boundaries away with everything else. Its advantage is
% practical: it is the only filter that calibrates its own regularization
% parameter, so there is nothing to tune.

F = splineFilter;

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

% the smoothing parameter determined during smoothing is
F.alpha

%%
% For this map it chose about 4.6. The average deviation from the grain
% mean, 0.59°, is essentially the same as before, but the picture is
% rounder: the fine structure the total variation filter kept inside the
% grains has been smoothed over.
%
%% Technical details - further filters
%
% The filters below are kept for comparison and for completeness. In
% practice they are inferior to the two above, and the sections say in what
% way.
%
% The first three - the @meanFilter, the @medianFilter and the
% @KuwaharaFilter - are sliding window filters: each point is replaced by
% something computed from the points around it, and nothing else enters.
%
%% The mean filter
%
% The simplest of all: replace each orientation by the mean of its
% neighbours.

% define the meanFilter
F = meanFilter;
F.numNeighbours = 1;

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS, colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% The noise is reduced, and a larger window reduces it further - at the
% cost of blurring everything else by the same amount.

F.numNeighbours = 3;

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

%% The median filter
%
% A mean is pulled by a single bad measurement and averages every subgrain
% boundary away. A median is not and does not, which makes it the more
% robust of the two.

F = medianFilter;

% define the size of the window to be used for finding the median
F.numNeighbours = 3; % this corresponds to a 7x7 window

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% What it produces instead are cartoon like patches with visible steps
% between them - the staircase effect, which is what a median does to a
% gentle gradient.
%
%% The Kuwahara filter
%
% Also built to survive outliers and to keep subgrain boundaries: it
% divides the window into quadrants and takes the one that is most uniform.
% In practice the results are rarely satisfactory.

F = KuwaharaFilter;
F.numNeighbours = 5;

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

%% The infimal convolution filter
%
% A compromise between the @splineFilter and the @halfQuadraticFilter: it
% adds a second order term to the total variation, so that a linear
% gradient survives where plain total variation would turn it into a
% staircase, while a boundary stays sharp. It is still under development
% and is not recommended.

F = infimalConvolutionFilter;
F.lambda = 0.01; % smoothing parameter for the gradient
F.mu = 0.005;    % smoothing parameter for the hessian

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off
