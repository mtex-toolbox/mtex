%% Grain Boundary Tutorial
% A quick guide to grain boundary analysis
%
%% Open in Editor
%
%% Contents
%
%% Grain boundaries generation
%
% To work with grain boundaries we need some ebsd data and have to detect
% grains within the data set

mtexdata T

[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'))

plot(grains)

%%
% 

grains.boundary

%%

grains.innerBoundary
