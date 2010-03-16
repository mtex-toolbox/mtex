%% Modelling Grains
%
%% Open in Editor
%
%% Abstract
% One may define a Grain as a homogeneous connected Region, in which at
% least one neighboured measurements fulfil a misorientation lower than a
% choosen threshold, or lets say, neighboured measurements with a higher
% misorientation build a boundary. 
%
%% Contents
%

%%
% Let us first import some standard EBSD data with a [[loadaachen.html,script file]]

loadaachen;

%% Modeling Grains
% The EBSD Data is [[EBSD_segment2d.html, regionalized]] according its
% phases and an given threshold-angle, where neighboured measurements
% are determined through its Voronoi Graph

[grains ebsd] = segment2d(ebsd,'angle',12.5*degree)

%%
% The retrived grains consists as a set of single [[grain_index.html,grain objects]], hence they are
% accessible over indexing like, and offer an easy way an of
% [[ModifyEBSDData.html, manipulation]]

grains(1)
grains(1:20)

%%
% of logical indexing like

grains( get(grains,'phase') == 1 )

%%
% Let us visualize the grain retrived regions, there may other ways of
% [[SpatialPlots.html, visualising grains]].

figure, plot(grains)

%% Connection between EBSD Data and a Grain-set
% The retrieved Grains are connected with its underlaying EBSD Data by an
% identification number, which allows us to interconnet choosen Grains
% with EBSD data

link(grains,ebsd(1))
link(grains,ebsd(2)) 

%%
% We can use this to *[[ModifyEBSDData.html,select grains]]* e.g. by a defined subset of the EBSD
% Data. the other way is also possible, to select ebsd data with respect to
% selected grains, so we can combine several sets to our wishes

grain_selection = grains( grainsize(grains) > 1000 )
ebsd_selection = link(ebsd, grain_selection)

