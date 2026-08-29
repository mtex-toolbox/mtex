%% Denoising Orientation Maps
%
%%
% Every measured orientation has uncertainty. Some errors are systematic:
% an incorrect pattern centre or reference frame can bias a whole map in a
% related way. A filter cannot discover that bias from the map alone. Check
% the setup as described in <EBSDReferenceFrame.html Reference Frames>
% before treating point-to-point variation as noise.
%
% Random errors appear instead as scatter between nearby measurements. This
% page reduces that scatter while trying to preserve real orientation
% gradients and abrupt changes inside grains. Filling measurements whose
% phase is |notIndexed| is a different operation; see
% <EBSDFilling.html Filling Missing Data>.
%
% The examples assume that you can reconstruct grains and read an
% orientation map. Those steps are introduced in
% <GrainReconstruction.html Grain Reconstruction> and
% <EBSDIPFMap.html IPF Maps>. A quantitative comparison of the filters and
% their effect on KAM and GND calculations is given by
% <https://doi.org/10.1107/S1600576719009075 Hielscher et al. (2019)>.
%
%% Making the noise visible
%
% The example is a map of deformed magnesium. Its plotting convention is
% set explicitly so that the specimen frame does not depend on the current
% MTEX session.

% import the data
plottingConvention.default('y↑→x');
mtexdata twins silent

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
% The grains appear almost uniformly coloured. This does not show that the
% measurements are noise-free: the IPF key displays absolute orientation,
% and sub-degree differences produce only small colour changes.
%
% A more sensitive view compares every orientation with the original mean
% orientation of its grain. Hue represents the misorientation axis and
% saturation represents its angle. This colour scheme follows
% <https://doi.org/10.1016/j.ultramic.2017.06.021 Thomsen et al. (2017)>.

% use the original grain means as reference orientations
grainMean = grains(ebsd.grainId).meanOrientation;
colorKey = axisAngleColorKey;
colorKey.oriRef = grainMean;

% keep one colour scale for every comparison on this page
rawDeviation = angle(ebsd.orientations,grainMean);
colorKey.maxAngle = quantile(rawDeviation,0.8);

plot(ebsd,colorKey.orientation2color(ebsd.orientations))
hold on
plot(grains.boundary,'linewidth',2)
hold off

fprintf('Raw mean deviation from the grain mean: %.2f degree\n', ...
  mean(rawDeviation,'omitnan')./degree);

%%
% Two patterns now separate. Smooth colour gradients across the larger
% grains record lattice bending in the deformed crystal. Pixel-to-pixel
% speckle superposed on those gradients is the signature to reduce. The
% printed mean contains both effects, so its decrease is a diagnostic of
% smoothing rather than a direct measurement of the noise amplitude.
%
%% How |smooth| uses the grain structure
%
% Every filter on this page is applied with <EBSD.smooth.html |smooth|>.
% Because |calcGrains| assigned |ebsd.grainId|, |smooth| treats each grain
% separately. It therefore does not average orientations across a
% reconstructed grain boundary. An abrupt change inside one reconstructed
% grain is a subgrain boundary, and whether it survives depends on the
% filter.
%
% Denoising changes the orientations in the returned map. It does not
% reconstruct the grains or move their boundaries, which is why the same
% original boundaries are overlaid throughout. Reconstruct the grains
% again only if the denoised orientations should define a new segmentation.
%
% Two variational filters are useful in practice. The total variation
% filter favours sharp internal changes; the smoothing spline favours a
% continuously curved map and chooses its own smoothing parameter.
%
%% The total variation filter
%
% The @halfQuadraticFilter balances fidelity to the measured orientations
% against first-order smoothness over the map. Its default total variation
% model permits jumps, so it can preserve a subgrain boundary instead of
% averaging across it. This method for rotation-valued images is described
% by <https://doi.org/10.3934/ipi.2016001 Bergmann et al. (2016)> and builds
% on the total variation model of
% <https://doi.org/10.1016/0167-2789(92)90242-F Rudin et al. (1992)>.
%
% The property |F.alpha| controls the trade-off; larger values smooth more.
% The property |F.threshold| prevents smoothing across neighbour
% differences above its value. The default settings are used here. Their
% price is a tendency towards cartoon-like patches and staircases.

F = halfQuadraticFilter;

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data on the fixed colour scale
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

hqDeviation = angle(ebsdS.orientations,colorKey.oriRef);
fprintf('Total variation mean deviation: %.2f degree\n', ...
  mean(hqDeviation,'omitnan')./degree);

%%
% The isolated colour changes are largely gone, while extended gradients
% and sharp internal changes remain. Read the printed reduction together
% with the map: the remaining deviation includes real deformation and
% should not be driven to zero.
%
%% The smoothing spline filter
%
% The @splineFilter is the filter that |smooth| uses when none is supplied.
% It penalizes curvature rather than first-order variation. The result is
% rounder than the total variation result, but fine subgrain boundaries are
% smoothed with the noise.
%
% Of the filters on this page, it is the only one that selects its own
% regularization parameter. It does so by generalized cross-validation and
% uses robust smoothing by default, following
% <https://doi.org/10.1016/j.csda.2009.09.020 Garcia (2010)>. This automatic
% mode is not yet fully supported on hexagonal grids; MTEX emits a warning
% there, and the @halfQuadraticFilter is the safer choice.

F = splineFilter;

% smooth the data and retain the selected parameter
[ebsdS,F] = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data on the fixed colour scale
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

splineDeviation = angle(ebsdS.orientations,colorKey.oriRef);
fprintf('Spline smoothing parameter alpha: %.2f\n',F.alpha);
fprintf('Spline mean deviation: %.2f degree\n', ...
  mean(splineDeviation,'omitnan')./degree);

%%
% For this map the selected value is about 4.6. The printed mean deviation
% is close to the total variation result, but the spatial result is not the
% same: the spline makes the colour fields rounder and removes more of the
% fine internal structure.
%
%% Technical details - further filters
%
% The filters below are retained for comparison and completeness. In
% practice they are inferior to the two above for this map. The first three
% are sliding-window filters: each orientation is replaced by a value
% computed only from a local neighbourhood.
%
% The median and Kuwahara filters are not yet fully supported on hexagonal
% grids. The infimal convolution filter has the same limitation.
%
%% The mean filter
%
% The @meanFilter replaces each orientation by a local mean. A radius of
% one gives the smallest neighbourhood.

F = meanFilter;
F.numNeighbours = 1;

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data on the fixed colour scale
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% The isolated speckle is weaker, but the extended colour fields have also
% spread. A local mean has no criterion for distinguishing a noisy jump
% from a real one inside the grain.
%
% Increasing |F.numNeighbours| broadens the spatial support. More noise is
% removed, at the cost of blurring every internal feature further.

F.numNeighbours = 3;

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data on the fixed colour scale
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% Compared with the preceding map, the broader patches and weaker narrow
% features show the cost of increasing the neighbourhood.
%
%% The median filter
%
% A mean is pulled towards one bad measurement and averages across every
% internal step. The @medianFilter selects the neighbouring orientation
% with the smallest mean distance to the others. It is therefore more
% robust to isolated outliers and more likely to preserve a subgrain
% boundary.

F = medianFilter;

% use a 7-by-7 window
F.numNeighbours = 3;

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data on the fixed colour scale
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% The map breaks into cartoon-like patches with visible steps. This
% staircase effect is what the median does to a gentle orientation
% gradient.
%
%% The Kuwahara filter
%
% The @KuwaharaFilter is also designed to survive outliers and preserve
% subgrain boundaries. It divides the neighbourhood into four overlapping
% quadrants and uses the mean of the most uniform one. The block structure
% in the result shows why it is rarely satisfactory in practice.

F = KuwaharaFilter;
F.numNeighbours = 5;

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data on the fixed colour scale
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% Large rectangular colour patches follow the selected subwindows rather
% than the smooth gradients visible in the raw map.
%
%% The infimal convolution filter
%
% The @infimalConvolutionFilter combines first- and second-order penalties.
% A linear gradient can then survive where plain total variation tends to
% create a staircase, while a sharp internal boundary can remain. The
% model is described by
% <https://doi.org/10.1007/978-3-319-58771-4_36 Bergmann et al. (2017)>.
% This MTEX implementation is still under development and is not
% recommended for routine use.

F = infimalConvolutionFilter;
F.lambda = 0.01; % first-order regularization parameter
F.mu = 0.005;    % second-order regularization parameter

% smooth the data
ebsdS = smooth(ebsd,F);
ebsdS = ebsdS('indexed');

% plot the smoothed data on the fixed colour scale
colorKey.oriRef = grains(ebsdS.grainId).meanOrientation;
plot(ebsdS,colorKey.orientation2color(ebsdS.orientations))

hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% The result is smoother within gradients than the total variation map and
% sharper at internal steps than the spline map. It offers no practical
% advantage here that outweighs its experimental status.
%
%% Choosing a filter
%
% Use the @halfQuadraticFilter when preserving subgrain boundaries matters.
% Use the @splineFilter on a square grid when smooth gradients and automatic
% parameter selection matter more. In either case, vary the smoothing
% strength and check that persistent spatial features remain; a lower mean
% deviation alone does not prove that the result is better.
%
% Denoising is usually preparation for a noise-sensitive calculation.
% <EBSDKAM.html Kernel Average Misorientation> and
% <EBSDGROD.html Grain Reference Orientation Deviation> continue with the
% same distinction between point-to-point scatter and real lattice bending.
