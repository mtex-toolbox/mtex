%% Grain Reconstruction
%
%%
% By grain reconstruction we mean the subdivision of the specimen, or more
% precisely the measured surface of the specimen, into regions of similar
% orientation which we then call grains. Note that there is no canonical
% definition of what is a grain. The grain reconstruction method that is
% default in MTEX is based on the definition of high angle grain boundaries
% which are assumed at the perpendicular bisector between neighbouring
% measurements whenever their misorientation angle exceeds a certain
% threshold. According to this point of view grains are regions surrounded
% by grain boundaries.
%
% In order to illustrate the grain reconstruction process we consider the
% following sample data set

close all; plotx2east

% import the data
mtexdata forsterite

% restrict it to a subregion of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% gridify the data
ebsd = ebsd.gridify;

% make a phase plot
plot(ebsd)

%% Basic grain reconstruction
%
% We see that there are a lot of not indexed measurements. For grain
% reconstruction, we have  three different choices how to deal with these
% unindexed regions:
%
% # leave them unindexed
% # assign them to the surrounding grains
% # a mixture of both, e.g., assign small notindexed regions to the
% surrounding grains but keep large notindexed regions
%
% The extent to which unindexed pixels are assigned is controlled by the
% parameter |'alpha'|. Roughly speaking this parameter is the radius of the
% smallest unindexed region that will not be entirely assigned to
% surrounding grains. The default of this value is 2.2.
%
% The second parameter that is involved in grain reconstruction is the
% threshold misorientation angle indicating a grain boundary. By default,
% this value is set to 10 degrees. 
%
% All grain reconstruction methods in MTEX are accessible via the command 
% <EBSD.calcGrains.html calcGrains> which takes as input an EBSD data set
% and returns a list of grain.

[grains, ebsd.grainId] = calcGrains(ebsd,'alpha',2.2,'angle',10*degree);
grains

%%
% The reconstructed grains are stored in the variable |grains|. To
% visualize the grains we can plot its boundaries by the command
% <grainBoundary.plot.html |plot|>.

% start overide mode
hold on

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5)

% stop overide mode
hold off

%%
% Increasing the parameter |'alpha'| larger unindexed regions are
% associated to grains.

[grains, ebsd.grainId] = calcGrains(ebsd,'alpha',3.2,'angle',10*degree);

plot(ebsd)
hold on

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5)

% stop overide mode
hold off

%% Clearing Single Pixel Grains
%
% As we observe quite a few single pixel grains we might want to consider
% them as misindexations and perform the grain reconstruction on the
% cleaned up data set.

% detect single pixel grains
isMisindexed = grains.grainSize==1;

% set the corresponding EBSD data to notIndexed
ebsd(grains(isMisindexed)) = 'notIndexed';

% redo grain reconstruction
[grains, ebsd.grainId] = calcGrains(ebsd,'alpha',3.2,'angle',10*degree);

% display the result
plot(ebsd)
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%% Grainboundary Smoothing 
% 
% Finally we may not like the staircase effect of the grain boundaries.
% This can be reduced by smoothing the grain boundaries using the command
% <grain2d.smooth.html |smooth|>

grains = smooth(grains,5);

% display the result
plot(ebsd)
hold on
plot(grains.boundary,'linewidth',1.5)
hold off





