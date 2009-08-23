%% Grain Detection
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
%% Import of EBSD Data
%
% Let us first import some EBSD data.

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

%% Detect Grains
% The EBSD Data is [[EBSD_segment2d.html, regionalized]] according its
% connected phases and an given threshold-angle, where neighboured
% measurements are determined through its Voronoi Graph

[grains ebsd] = segment2d(ebsd,'angle',12.5*degree)

%%
% Let us visualize the high-angle grain boundaries

plot(grains)

%%
% and we can also plot low-angle boundaries

hold on, plotsubfractions(grains,'color','r')

%% Connection between EBSD Data and a Grain-set
% The retrieved Grains are connected with its underlaying EBSD Data by an
% identification number, which allows us to interconnet choosen Grains
% with EBSD data

link(grains,ebsd(1))

%%
% We can use this to select grains e.g. by a defined subset of the EBSD
% Data. the other way is also possible, to select ebsd data with respect to
% selected grains, so we can combine several sets to our wishes

link(ebsd, link(grains,ebsd(1)) )

%% Orientation of a Grain
% For several applications its required to assign each grain an average
% orientation due to its EBSD Data

grains = mean(grains,ebsd)

%%
% We can visualize the assigned orientation

figure, plot(grains,'property','orientation')

%%
% compared to the original data

figure, plot(ebsd)


%% Determine Phase Boundaries
% If the treshold angle is higher than its maximum misorienation angle of a
% crystal symmetry we'll get the phase boundaries.

[grains_phaseb ebsd] = segment2d(ebsd,'angle',180*degree);

figure, plot(grains_phaseb,'property','phase')


