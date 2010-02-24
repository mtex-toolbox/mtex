%% Grain Statistics
%
%% Open in Editor
%
%% Abstract
% Grains have several intrinsic properties, which can be used for
% statistical, shape as well as for spatial analysis
%
%% Contents
%
%% Import of EBSD Data
%
% Let us first import some EBSD data and perform a regionalisation

CS = {...
  symmetry('m-3m'),... % crystal symmetry phase 1
  symmetry('m-3m')};   % crystal symmetry phase 2
SS = symmetry('-1');   % specimen symmetry

% file name
fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

% import ebsd data
ebsd = loadEBSD(fname,CS,SS,'interface','generic',...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'Mad' 'BC'},...
  'Columns', [2 3 4 5 6 7 8 9],...
  'ignorePhase', 0, 'Bunge');

plotx2east

[grains ebsd] = segment2d(ebsd,'angle',12.5*degree)

%% Grain-size Analysis
% Since a grain is associated with a @polygon, we can determine properties
% of the geometry

ar = area(grains);

%%
% make an expotential bin-size and plot the histogram

bins = exp(-1:0.5:log(max(ar)));

bar( hist(ar,bins) )

%%
% thera are various functions treating the geometry, respectively the shape
% e.g. [[grain_perimeter.html,perimeter]], [[grain_equivalentradius.html,equivalentradius]],  
% [[grain_equivalentperimeter.html,equivalentperimeter]], [[grain_aspectratio.html,aspectratio]], [[grain_shapefactor.html,shapefactor]] or concerning the
% convex hull of a grain [[grain_hullarea.html,hullarea]], 
% [[grain_paris.html,paris]], [[grain_deltaarea.html,deltaarea]], so
% there are many ways to analyze its relation to geometry.
%
sf = shapefactor(grains);
as = aspectratio(grains);

scatter(sf, as, ar)


%%
% later on it could be set in relation to its textural properties

%% Spatial Dependencies
% One interessting question would be, wether a polyphase system has
% dependence in the spatial arrangement or not, therefor we can count the
% transitions to a neighbour grain

ph = get(grains,'phase');

[J T p ] = joincount(grains,ph)

%%
% as we see is phase 2 mostly isolated, thus the most transitions ar
% between phase 1 to 1 or phase 1 to 2.
