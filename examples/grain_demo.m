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

fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

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
% different segmentations with one ebsd object

[grains5 ebsd] = segment2d(ebsd,'angle',5*degree,'augmentation','cube')

%% Plot grain-boundaries

plotboundary(grains,'color',[0.25 0.1 0.5])
hold on, plotsubfractions(grains,'color','red','linewidth',2)

%% Select grains after their EBSD phase
% The Segmentation is connected with the EBSD object, we can select grains
% after specified ebsd measurements

grains_ph1 = link(grains,ebsd(1));
grains_ph2 = link(grains,ebsd(2));

%%
% on application of this would be to take a look on the grainsize
% distribution

% make a expotential bin size
x = fix(exp(.5:.5:7.5));
figure, bar( hist(grainsize(grains_ph1),x) );


%% Accessing geometric properties 

p = polygon(grains_ph1)

%%
%
area(grains_ph1); perimeter(grains_ph1);
shapefactor(grains_ph1); paris(grains_ph1); %...

%% Select Grains and its EBSD data by other properties
% select grains with boundaries within itself

grains_fractions = grains( hassubfraction(grains) )

%%
% and its corresponding ebsd data

ebsd_fractions = link(ebsd, grains_fractions)

%% Plotting of grains
% there are many ways to plot grains

%%
% default plotting
plot(grains)

%%
% its also possible to plot an abitrary property
plot(grains,'property',shapefactor(grains))

%%
% grainboundary

plotboundary(grains)

%%
% classified after some specific 

%%
%
plotboundary(grains,'property','phase')
%%
%
plotboundary(grains,'property','angle')
%%
%
plotboundary(grains,'property','colorcoding','hkl')
%%
%
plotboundary(grains,'property',axis2quat(1,1,1,60*degree))


%%
% as we see, the mean is stored as new property 'orientation'. we can plot
% it

figure, plot(grains)

%% Properties of a grain
% We also can copy known properties from the ebsd object to our grains

grains = copyproperty(grains,ebsd)

%%
%
figure, plot(grains,'property','bc')

%% Spatial Relation - Join Counts
% find out which phases depends on other phases and how
% therefor we can iterate over all grains access its ebsd data

coloring = get(grains,'phase');

[J T q p] = joincount(grains,coloring);

%%
% we can use also other coloring, for instance binary

joincount(grains,hassubfraction(grains));
joincount(grains,hashole(grains));
  % ...

%% Multiple Access of EBSD data
% there is a routine grainfun to allow iterative access
% we can split our EBSD data

ebsd_fractions

%%
% into several EBSD objects corresponding to our grains

grainfun(@(ebsd) ebsd, grains_fractions,ebsd_fractions,'uniformoutput',true)

%% Multiple Access and ODF Estimation
% calculate all ODFs of grains, since this takes quite long we restrict the
% selected grains to a region of interest

ply = polygon([90 90;140 90;140 140; 90 140; 90 90]);
pgrains = grains( inpolygon( grains, ply,'centroids') )

figure, plot(pgrains)
hold on, plot(ply,'color','r','linewidth',2)

%%
% the five larges grains
[a nd] = sort(grainsize(pgrains),'descend');
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


%% Calculate ODFs
% if our grain-data has an orientation, of course we can model an odf

ph = get(grains,'phase');

odf_grains1 = calcODF(grains( ph==1 ),'kernel',kern,'resolution',1*degree)

%%
% and the odf of the corresponding ebsd data

odf_ebsd1 = calcODF(ebsd(1),'kernel',kern,'resolution',1*degree)

%%
% let us compare those two, original ebsd with the odf of grains

figure, plotpdf(odf_ebsd1,[Miller(1,1,0) Miller(1,1,1)],'antipodal')
figure, plotpdf(odf_grains1,[Miller(1,1,0) Miller(1,1,1)],'antipodal')

calcerror(odf_ebsd1,odf_grains1)

%% Misorientation to Neighbours

ebsd_nmis = misorientation(grains,'weighted');
odf_nmis2 = calcODF(ebsd_nmis(2),'kernel',kern,'resolution',1*degree);

figure, plotipdf(odf_nmis2,[vector3d(1,1,0) vector3d(1,1,1)],'antipodal')

annotate(CSL(3))


