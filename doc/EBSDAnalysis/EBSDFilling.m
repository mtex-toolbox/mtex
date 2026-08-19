%% Fill Missing Data in Orientation Maps
%
% Not every pixel of an EBSD scan can be indexed. A pattern measured on a
% grain boundary is the superposition of the patterns of both neighboring
% grains, cracks, pores, scratches and surface contamination return no
% usable pattern at all, and a phase that was not included in the phase
% list used during indexing can not be indexed either. All those pixels
% appear as |notIndexed| in the imported data set. Some data sets contain
% in addition positions at which no measurement was taken at all, e.g.
% because the scan was interrupted or because the map has been cropped to
% an irregular region.
%
% In this section we demonstrate how the orientations at those positions
% can be recovered by interpolating from the surrounding measurements. Two
% things should be kept in mind:
%
% * the recovered orientations are an interpolation and not a measurement
% * only the orientations are interpolated - all other properties of the
% data set are left undefined, see the section *Which Data is Interpolated*
% below
%
% Reducing the random error of the pixels that *have* been indexed is a
% different problem which is discussed in the section
% <EBSDDenoising.html Denoising Orientation Maps>.

%%
% We demonstrate the filling capabilities of MTEX at the hand of an
% orientation map of ferrite.

% import the data
mtexdata ferrite

% reconstruct the grain structure
[grains,ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',5);

% smooth grain boundaries
grains = smoothBoundary(grains,5);

% plot the orientation map
plot(ebsd,ebsd.orientations)

% and on top the grain boundaries
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%% A Very Sparse Measured Data Set
%
% Although the data set has already some not indexed pixels we artificially
% make the situation even worse by throwing away 75 percent of all
% measurements.

rng(0) % make the example reproducible
ebsdSub = ebsd(rand(length(ebsd),1) > 0.75)

% plot the reduced data
plot(ebsdSub,ebsdSub.orientations)

%%
% Our aim is now to recover the original orientation map. In a first step we
% reconstruct the grain structure from the remaining 25 percent of pixels.

% reconstruct the grain structure
[grainsSub,ebsdSub] = calcGrains(ebsdSub,'angle',10*degree,'minPixel',2,'alpha',5);

grainsSub = smoothBoundary(grainsSub,5);

hold on
plot(grainsSub.boundary,'linewidth',1.5)
hold off

%% Filling by Nearest Neighbor Interpolation
%
% The easiest way to reconstruct missing data is to use the command
% <EBSD.fill.html |fill|> which interpolates missing data using the method
% of nearest neighbor. It is recommended to pass the grain structure
% |grainsSub| as an additional argument to the |fill| function. In this
% case the nearest neighbors are chosen within the grains and no
% orientation is carried across a grain boundary.

ebsdSub_filled = fill(ebsdSub,grainsSub);

plot(ebsdSub_filled('indexed'),ebsdSub_filled('indexed').orientations);

hold on
plot(grainsSub.boundary,'linewidth',1.5)
hold off

%%
% Note that positions which are not covered by any grain remain not
% indexed. This is why the reconstructed map still has holes along the
% grain boundaries.

%% Filling by Denoising
%
% A much more powerful method is to use any of the denoising methods
% described in <EBSDDenoising.html Denoising Orientation Maps> and set the
% option |'fill'|. In contrast to the nearest neighbor interpolation this
% results in a smooth transition between the interpolated orientations.

F = halfQuadraticFilter;
F.alpha = 0.25;

% interpolate the missing data
ebsdSub_smoothed = smooth(ebsdSub,F,'fill',grainsSub);

plot(ebsdSub_smoothed('indexed'),ebsdSub_smoothed('indexed').orientations);

hold on
plot(grainsSub.boundary,'linewidth',1.5)
hold off

%% Which Data is Interpolated
%
% Both |fill| and |smooth| recover the *orientation*, the *phase* and the
% *grain id* of a missing pixel. No other property of the data set is
% interpolated. Our ferrite data set carries the following properties

fieldnames(ebsdSub_filled.prop)

%%
% The properties |ci|, |fit|, |iq| and |sem_signal| describe how well a
% Kikuchi pattern could be indexed. At an interpolated pixel there is no
% pattern - accordingly these properties are left as NaN and the
% corresponding map keeps its holes.

plot(ebsdSub_filled,ebsdSub_filled.ci)
mtexColorbar('title','confidence index')

%%
% This is a feature rather than a shortcoming: it makes the interpolated
% pixels recognizable at any later point of the analysis. Whenever one
% needs to distinguish measured from interpolated orientations one may
% simply ask for the pixels without a valid quality value

isInterpolated = isnan(ebsdSub_filled.ci);
fprintf('%d of %d pixels have been interpolated\n',...
  nnz(isInterpolated),length(ebsdSub_filled))

%%
% The command |smooth| offers a second marker: it stores a property
% |quality| which is set to zero for every pixel that did not carry an
% orientation before the filter was applied.

nnz(ebsdSub_smoothed.quality == 0)

%%
% If the additional properties are needed at arbitrary positions as well
% one has to resample the map with the command
% <EBSD.interp.html |interp|>, which carries all properties along. This is
% discussed in the section <EBSDInter.html Interpolating EBSD Data>. Note
% that |interp| only transfers data to positions that are covered by an
% existing measurement and hence can not be used to fill holes.

%% An Example from Geoscience
%
% Data sets with many missing pixels most often appear when measuring
% geological samples. The following data set of Forsterite contains about
% 25 percent missing pixels. Lets start by importing the data and
% reconstructing the grain structure.

close all;
plottingConvention.default('y↑→x');
mtexdata forsterite silent
ebsd = ebsd(inpolygon(ebsd,[10 4 5 3]*10^3));
plot(ebsd('Fo'),ebsd('Fo').orientations)
hold on
plot(ebsd('En'),ebsd('En').orientations)
plot(ebsd('Di'),ebsd('Di').orientations)

% compute and smooth grains
[grains,ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',3,'alpha',3);
grains = smoothBoundary(grains,5);

% plot the boundary of all grains
plot(grains.boundary,'linewidth',2)
hold off

%%
% Using the option |'fill'| the command |smooth| fills the holes inside the
% grains. Note that the nonindexed pixels at the grain boundaries are kept
% untouched. In order to allow MTEX to decide whether a pixel is inside a
% grain or not, the |grains| variable has to be passed as an additional
% argument.

F = halfQuadraticFilter;
F.alpha = 10;

ebsdS = smooth(ebsd,F,'fill',grains);

plot(ebsdS('Fo'),ebsdS('Fo').orientations)
hold on
plot(ebsdS('En'),ebsdS('En').orientations)
plot(ebsdS('Di'),ebsdS('Di').orientations)

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5)

% stop override mode
hold off

%%
% In order to visualize the orientation gradient within the grains, we plot
% the misorientation to the meanorientation. We observe that the mis2mean
% varies smoothly also within the regions of not indexed orientations.

% plot mis2mean for all phases
ipfKey = axisAngleColorKey(ebsdS('Fo'));
ipfKey.oriRef = grains(ebsdS('fo').grainId).meanOrientation;
ipfKey.maxAngle = 2.5*degree;

color = ipfKey.orientation2color(ebsdS('Fo').orientations);
plot(ebsdS('Fo'),color,'micronbar','off')

hold on
ipfKey.oriRef = grains(ebsdS('En').grainId).meanOrientation;

plot(ebsdS('En'),ipfKey.orientation2color(ebsdS('En').orientations))

% plot boundaries
plot(grains.boundary,'linewidth',4)
plot(grains('En').boundary,'lineWidth',4,'lineColor','r')
hold off

%%
% For comparison the same plot for the original, not filled data. The
% regions of not indexed pixels are clearly visible.

ipfKey.oriRef = grains(ebsd('fo').grainId).meanOrientation;
ipfKey.maxAngle = 2.5*degree;

color = ipfKey.orientation2color(ebsd('Fo').orientations);
plot(ebsd('Fo'),color,'micronbar','off')

hold on
ipfKey.oriRef = grains(ebsd('En').grainId).meanOrientation;

plot(ebsd('En'),ipfKey.orientation2color(ebsd('En').orientations))

% plot boundaries
plot(grains.boundary,'linewidth',4)
plot(grains('En').boundary,'lineWidth',4,'lineColor','r')
hold off
