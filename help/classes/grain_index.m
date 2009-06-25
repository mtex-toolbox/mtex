%% The Class grain
%
%% Abstract
% class representing single *Grains* in EBSD measurements
%
%% Description
%
%% Preliminary:  EBDS Data

cs = { symmetry('m-3m'), ...
       symmetry('m-3m') };      % crystal symmetry
ss = symmetry('triclinic'); % specimen symmetry

% file names
fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

% load data
ebsd = loadEBSD(fname,cs,ss,...
                'interface','generic','Bunge','ignorePhase',[0 2],...
                 'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3','MAD','BC'},...
                 'Columns', [2 3 4 5 6 7 8 9 ]);
               
plotx2east
               
%% Segmentation

[grains ebsd] = segment2d(ebsd, 'angle',12.5*degree)

%% Plotting Grains

plot(grains)

%% Interconnection between EBSD and Grain data

grains_t = grains( hasholes(grains))
ebsd_t = get(ebsd(1), grains_t)

plot(ebsd_t)
hold on, plot(grains_t,'linewidth',2,'color','r')

%% Copying information from EBSD

grains = copyproperty(grains,ebsd,'mad')
grains = copyproperty(grains,ebsd,'bc',@min)

plot(grains,'property','bc')

%% Applying EBSD functions on Grains 

grain_size = grainsize(grains);
[m ndx] = max(grain_size);
plot(grains(ndx))

ODFs = grainfun(@(x)calcODF(x,'silent'),grains (ndx ) ,ebsd)

plot(ODFs{:},'alpha','sections',18)



