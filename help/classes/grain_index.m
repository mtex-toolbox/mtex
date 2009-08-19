%% The Class grain
%
%% Abstract
% class representing single *Grains* in EBSD measurements
%
%% Description
% A grain may be defined as a connected region, in which every orientation
% satisfies an angle to at least one neighbour lower than a choosen
% threshold. There is a [[EBSD_segment2d.html, segmentation]] to
% regionalize the spatial EBSD data into grains.
%

%% Preliminary:  EBDS Data

CS = { symmetry('m-3m'), ...
       symmetry('m-3m') };  % crystal symmetry
SS = symmetry('triclinic'); % specimen symmetry

% file names
fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

% load data
ebsd = loadEBSD(fname,CS,SS,...
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
figure, plot(grains(ndx))

%%
%

grains(ndx) = calcODF(grains(ndx),ebsd);

plotpdf(get(grains(ndx),'ODF'),Miller(1,1,1,CS{1}),'antipodal');

