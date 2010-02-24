%% The Class grain
%
%% Abstract
% class representing single *Grains* in EBSD measurements
%
%% Description
% A grain may be defined as a region, in which the misorientation
% less thana choosen threshold. There is a function [[EBSD_segment2d.html, segmentation]] to
% regionalize spatial EBSD data into grains.
%

%% Preliminary:  EBDS Data

CS = { symmetry('m-3m'), ...
       symmetry('m-3m') };  % crystal symmetry
SS = symmetry('triclinic'); % specimen symmetry

% file names
fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

% load data
ebsd = loadEBSD(fname,CS,SS,...
                'interface','generic','Bunge','ignorePhase',[0],...
                 'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3','MAD','BC'},...
                 'Columns', [2 3 4 5 6 7 8 9 ]);
               
plotx2east
               
%% Segmentation
% A brief introduction of [[GrainDetection.html, Grain Detection]] 

[grains ebsd] = segment2d(ebsd, 'angle',12.5*degree)

%% Plotting Grains
% Grains are plotted using the [[grain_plot.html, plot]] command. As EBSD
% data, colors are mapped to each orientation.

plot(grains)

%% Selecting Grains
% grains can be selected by subindexing, e.g. logical indexing

grains_selection = grains( grainsize(grains) >  300 );

%% Interconnection between EBSD and Grain data
% EBSD data can be selected by its corresponding grains

ebsd_t = link(ebsd(1), grains_selection)

%%
% or grains according to given EBSD data

grains_selection = link(grains_selection,ebsd(1))

plot(ebsd_t)
hold on, plotboundary(grains_selection,'color','r')

%% Copying information from EBSD
% EBSD data often comes along with additional information, which are stored
% as a property, maybe one would copy it to the corresponding grains

grains = copyproperty(grains,ebsd,'mad')
grains = copyproperty(grains,ebsd,'bc',@min)

plot(grains,'property','bc')

%% Applying EBSD functions on Grains 
% It may be usefull to calculate ODFs for each grain

grains_selection = calcODF(grains_selection,ebsd) 

%%
% the ODF of a grain ist stored as a property, so we can access it by

odfs = get(grains_selection,'ODF'); % as cell
odfs_superposed = [odfs{:}];

plotpdf(odfs_superposed,Miller(1,1,1),'antipodal');

