%% Grain Statistics
% Access properties of grains to perfom statistics.
%
%% Open in Editor
%
%% Contents
%
%% 
% Grains have several intrinsic properties, which can be used for
% statistical, shape as well as for spatial analysis
%
%%
% Let us first import some EBSD data and perform a regionalisation

mtexdata aachen

grains = calcGrains(ebsd,'threshold',12.5*degree)

%% Grain-size Analysis
% Since a grain is associated with a polygon, we can determine properties
% of the geometry

ar = area(grains);

%%
% make an expotential bin-size and plot the histogram

bins = exp(-1:0.5:log(max(ar)));

bar( hist(ar,bins) )

%%
% thera are various functions treating the geometry, respectively the shape
% e.g. <Grain2d.perimeter.html perimeter>, <GrainSet.diameter.html
% diameter>, <Grain2d.equivalentradius.html equivalentradius>,
% <Grain2d.equivalentperimeter.html equivalentperimeter>,
% <Grain2d.aspectratio.html aspectratio>, <Grain2d.shapefactor.html
% shapefactor>, so there are many ways to analyze its relation to geometry.
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

[J T p ] = joinCount(grains,ph)

%%
% as we see is phase 2 mostly isolated, thus the most transitions ar
% between phase 1 to 1 or phase 1 to 2.
