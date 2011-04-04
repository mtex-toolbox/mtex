%% Grains (The Class [[grain_index.html,grain]])
%
%% Abstract
% class representing single *Grains* in EBSD measurements
%
%% Description
% A grain may be defined as a region, in which the misorientation
% less thana choosen threshold. There is a function <EBSD.segment2d.html segmentation> 
% to regionalize spatial EBSD data into grains.
%               
% <<grain.png>>
%
%% Preliminary:  EBDS Data

CS = { symmetry('m-3m'), ...
       symmetry('m-3m') };  % crystal symmetry
SS = symmetry('triclinic'); % specimen symmetry

% file names
fname = fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt');

% load data
ebsd = loadEBSD(fname,CS,SS,...
                'interface','generic','Bunge','ignorePhase',[0],...
                 'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3','MAD','BC'},...
                 'Columns', [2 3 4 5 6 7 8 9 ]);
               
plotx2east
               
%% Grain Modelling
% A brief introduction of <GrainModelling.html Grain Detection>

[grains ebsd] = segment2d(ebsd, 'angle',12.5*degree)

%% Plotting Grains
% Grains are plotted using the <grain.plot.html plot> command. As EBSD
% data, colors are mapped to each orientation.

figure
plot(grains)

%%
% Every grain owns a <polygon_index.html polygon>
%
%% Selecting Grains
% grains can be selected by subindexing, e.g. logical indexing (see
% <ModifyEBSDData.html manipulation>)

grains_selection = grains( grainSize(grains) >  300 )
