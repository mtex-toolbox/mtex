%% MTEX - Grain Analysis of EBSD Data
%
% Analysis of single orientation measurement.
%
%
%

%% Specify Crystal and Specimen Symmetry

% specify crystal and specimen symmetry
CS = {...
  symmetry('m-3m'),... % crystal symmetry phase 1
  symmetry('m-3m')};   % crystal symmetry phase 2
SS = symmetry('-1');   % specimen symmetry

%% Import ebsd data

fname = fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt');

ebsd = loadEBSD(fname,CS,SS,'interface','generic',...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'MAD' 'BC'},...
  'Columns', [2 3 4 5 6 7 8 9],'Bunge');

plotx2east

%% Plot Spatial Data

plot(ebsd,'phase',1)

%% Segmentation

[grains ebsd] = segment2d(ebsd)

%%
% we can see which segmentations are stored in the ebsd object indicated by
% grain_idXXXXXXXX as option, so it is possible to treat several
% different segmentations with one ebsd object, an we can define for each
% phase a custom threshold

[grains5 ebsd] = segment2d(ebsd,'angle',[10 5]*degree)

%% 
% Plot grain-boundaries

plotboundary(grains,'color',[0.25 0.1 0.5])
hold on, plotSubfractions(grains,'color','red','linewidth',2)

%%
% on application of this would be to take a look on the grainsize
% distribution

% make a expotential bin size
x = fix(exp(.5:.5:7.5));
figure, bar( hist(grainSize(grains5),x) );


%% Accessing geometric properties 

p = polygon(grains)

%%
%
area(grains); perimeter(grains);
shapefactor(grains); paris(grains); %...


%% Spatial Relation - Join Counts
% find out which phases depends on other phases and how
% therefor we can iterate over all grains access its ebsd data

coloring = get(grains,'phase');

[J T q p] = joinCount(grains,coloring);

%%
% we can use also other coloring, for instance binary

joinCount(grains,hasSubfraction(grains));
joinCount(grains,hashole(grains));
  % ...

%% Multiple Access of EBSD data
% there is a routine grainfun to allow iterative access
% we can split our EBSD data

%%
% into several EBSD objects corresponding to our grains

grainfun(@(ebsd_fun) ebsd_fun, grains(grainSize(grains) > 600), ebsd,'uniformoutput',true)


%% Multiple Access and ODF Estimation
% calculate all ODFs of grains, since this takes quite long we restrict the
% selected grains to a region of interest

ply = polygon([90 90;140 90;140 140; 90 140; 90 90]);
pgrains = grains( inpolygon( grains, ply,'centroids') )

figure, plot(pgrains)
hold on, plot(ply,'color','r','linewidth',2)

%%
% the five larges grains
[a nd] = sort(grainSize(pgrains),'descend');
pgrains = pgrains(nd(1:5))

%%
% and now the ODF with respect to its origial ebsd-data

kern = kernel('de la Vallee Poussin','halfwidth',5*degree);
pgrains = calcODF(pgrains,ebsd,'kernel',kern,'exact')

%%
% the ODF of individual grains are stored as a property, alternativ we can
% specify the property name, if we want to treat several ODFs

%%
% let us calculate the misorentation to mean followed by an ODF estimation

ebsd_mis = misorientation(grains,ebsd);
pgrains = calcODF(pgrains,ebsd_mis,'kernel',kern,'property','ODF_mis','exact')

%%
% now we can work with grainfun by specifiying the property-field 'ODF' and
% applying an function on it, e.g we want to calculate the textureindex of
% each grain

tindex = grainfun(@textureindex, pgrains,'ODF','resolution',5*degree)
tindex_mis = grainfun(@textureindex, pgrains,'ODF_mis','resolution',5*degree)

