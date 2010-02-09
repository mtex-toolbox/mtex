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

plot(grains,'color',[0.25 0.1 0.5])
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
x = fix(exp(1:0.5:log(max(grainsize(grains)))));
  %also try area(grains), hullarea(grains)

% the histograms
y1 = hist(grainsize(grains_ph1),x)';
y2 = hist(grainsize(grains_ph2),x)';

% and the histogram for the segmentation of 5 degrees
y5_1 = hist(grainsize( link(grains5,ebsd(1)) ),x)';
y5_2 = hist(grainsize( link(grains5,ebsd(2)) ),x)';

%%
% print a table

disp(' ')
disp(' <= x <   phase1       | phase2      ');
disp('           12.5°    5° |  12.5°   5° ');
disp('-------------------------------------')

disp(num2str([ x' y1,y5_1, y2, y5_2 ],' %10d %11d %6d|%6d %6d'))

%%
% and more visual as barplot

figure, bar(1:length(x),[y1,y5_1, y2,y5_2]);
set(gca,'YScale','log')
set(gca,'XTickLabel',mat2cell(x',ones(size(x))))
legend('phase 1 : 15°','phase 1 : 5°','phase 2 : 15°','phase 2 : 5°')

%% Compare phases in scatter plots

% plot grain against shapefactor

figure('Position',[15 50 1200 350]), subplot(1,3,1)
hold on,semilogx(area(grains_ph1),shapefactor(grains_ph1),'b.');
hold on,semilogx(area(grains_ph2),shapefactor(grains_ph2),'g.');
xlabel('area'); ylabel('shapefactor');
grid on
axis tight

% plot perimeter area against aspect ratio

subplot(1,3,2)
hold on, semilogx(perimeter(grains_ph1),aspectratio(grains_ph1),'b.');
hold on, semilogx(perimeter(grains_ph2),aspectratio(grains_ph2),'g.');
xlabel('perimeter'); ylabel('aspect ratio');
grid on
axis tight

% plot paris area against deltaarea

subplot(1,3,3)
hold on, semilogx(paris(grains_ph1),deltaarea(grains_ph1),'b.');
hold on, semilogx(paris(grains_ph2),deltaarea(grains_ph2),'g.');
xlabel('paris'); ylabel('deltaarea');
grid on
axis tight

%%
% phase 1 blue, phase 2 green

%% Select Grains and its EBSD data by other properties
% select grains with boundaries within itself

grains_fractions = grains( hassubfraction(grains) )

%%
% and its corresponding ebsd data

ebsd_fractions = link(ebsd, grains_fractions)

%% Plotting of grains
% there are many ways to plot grains

figure, hold all
plot(ebsd_fractions)
plot(grains_fractions,'color','black','linewidth',1)
  % however the holes of a grain are plotted by default in an other color
plot(grains_fractions,'b','noholes','linewidth',1.5)
  % and now the boundary within
plotsubfractions(grains_fractions,'r','linewidth',2)
  % and its convex hull
plot(grains_fractions,'hull','b','linewidth',1.5)
  % and also ellipses of principal components
plotellipse(grains_fractions,'hull','scale',0.25,'b','linewidth',1.5)

%%
% as we see, the mean is stored as new property 'orientation'. we can plot
% it

figure, plot(grains,'property','orientation')

%% Properties of a grain
% We also can copy known properties from the ebsd object to our grains

grains = copyproperty(grains,ebsd)

%%
%
figure, plot(grains,'property','bc')

%%
% its also possible to plot an abitrary property

figure, plot(grains,'property',shapefactor(grains))

%% Spatial Relation - Join Counts
% find out which phases depends on other phases and how
% therefor we can iterate over all grains access its ebsd data

coloring = get(grains,'phase');

[J T q p] = joincount(grains,coloring);

%%
% we can use also other coloring, for instance binary

joincount(grains,hassubfraction(grains));
joincount(grains,hasholes(grains));
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

plxy = [90 90;150 90;150 150; 90 150; 90 90];
pgrains = inpolygon( grains, plxy,'intersect')

figure, plot(plxy(:,1),plxy(:,2),'r')
hold on, plot(pgrains)

%%
% and now the ODF with respect to its origial ebsd-data

kern = kernel('de la Vallee Poussin','halfwidth',10*degree);
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

tindex = grainfun(@textureindex, pgrains,'ODF');
tindex_mis = grainfun(@textureindex, pgrains,'ODF_mis');

%%

figure, plot(pgrains,'property',tindex);

%%

figure, plot(pgrains,'property',tindex_mis);

%%
% and finally, let us plot all grains with a texture index higher than
% their misorientation texture index in red

plot(pgrains,'property',tindex>tindex_mis)

%%
% some scatter plots, are grainsizes somehow correlated with their
% textureindicies?

figure, loglog(tindex,area(pgrains),'b.')
hold on, loglog(tindex_mis,area(pgrains),'r.')
xlabel('texture index')
ylabel('area')
 axis tight
 grid on

%%
%

close all

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
odf_nmis1 = calcODF(ebsd_nmis(1),'kernel',kern,'resolution',1*degree);

figure, plotpdf(odf_nmis1,[Miller(1,1,0) Miller(1,1,1)],'antipodal')

%%
