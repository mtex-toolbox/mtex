%% MTEX - Grain Analysis of EBSD Data
%
% Analysis of single orientation measurement.
%
% 
% 

%% Specify Crystal and Specimen Symmetry

% specify crystal and specimen symmetry
CS = [...
  symmetry('m-3m'),...
  symmetry('m-3m'),... % crystal symmetry phase 1
  symmetry('m-3m')];   % crystal symmetry phase 2
SS = symmetry('-1');   % specimen symmetry

%% Import ebsd data

fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

ebsd = loadEBSD(fname,CS,SS,'interface','generic',...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3'},...
  'Columns', [2 3 4 5 6 7],...
  'Bunge');

plotx2east

%% Plot Spatial Data

figure('color','white'), hold on, plot(ebsd,'phase',1,'colorcoding','ihs')
              
%% Segmentation

[grains ebsd] = segment2d(ebsd,'angle',12.5*degree,'augmentation','cubei')

% we can see which segmentations are stored in the ebsd object indicated by
% grain_idXXXXXXXX as option, so it is possible to treat several
% different segmentations with one ebsd object

[grains5  ebsd] = segment2d(ebsd,'angle',5*degree,'augmentation','cube')


%% Plot Grains and Subfractions

figure('color','white'), hold on, plot(grains,'color',[0.25 0.1 0.5])
hold on, plotsubfractions(grains,'color','red','linewidth',2)

%% Select grains after their EBSD phase
% The Segmentation is connected with the EBSD object, 

grains_ph0 = grains == ebsd(1);
grains_ph1 = grains == ebsd(2);
grains_ph2 = grains == ebsd(3);

%%
% Some histogram for grainsizes

% make a expotential bin size
x = fix(exp(1:0.5:log(max(grainsize(grains)))));
  %also try area(grains), hullarea(grains)

% the histograms

y1 = hist(grainsize(grains_ph0),x)';
y2 = hist(grainsize(grains_ph1),x)';
y3 = hist(grainsize(grains_ph2),x)';

%%
% and the histogram for the segmentation of 5 degrees

y5_1 = hist(grainsize(grains5 == ebsd(1)),x)';
y5_2 = hist(grainsize(grains5 == ebsd(2)),x)';
y5_3 = hist(grainsize(grains5 == ebsd(3)),x)';

%%
% print a table

disp(' ')
head  = ' <= x <   phase0       | phase1      | phase2        ';
head2 = '           12.5°    5° |  12.5°   5° |  12.5°   5°   ';
disp(head); disp(head2);

disp(repmat('-',1,length(head)));
disp(num2str([ x' y1,y5_1, y2, y5_2, y3, y5_3 ],' %10d %11d %6d|%6d %6d|%6d %6d'))

%%
% and as barplot

figure('color','white'), bar(1:length(x),[y1, y2, y3]);
set(gca,'YScale','log')
set(gca,'XTickLabel',mat2cell(x',ones(size(x))))
legend('phase 0','phase 1','phase 2')

%% Compare phases in scatter plots

% plot grain against shapefactor

figure('color','white','Position',[15 50 1200 350]), subplot(1,3,1)
semilogx(area(grains_ph0),shapefactor(grains_ph0),'r.');
hold on,semilogx(area(grains_ph1),shapefactor(grains_ph1),'b.');
hold on,semilogx(area(grains_ph2),shapefactor(grains_ph2),'g.');
xlabel('area'); ylabel('shapefactor');
grid on
axis tight

% plot perimeter area against aspect ratio

subplot(1,3,2)
semilogx(perimeter(grains_ph0),aspectratio(grains_ph0),'r.');
hold on, semilogx(perimeter(grains_ph1),aspectratio(grains_ph1),'b.');
hold on, semilogx(perimeter(grains_ph2),aspectratio(grains_ph2),'g.');
xlabel('perimeter'); ylabel('aspect ratio');
grid on
axis tight

% plot paris area against deltaarea

subplot(1,3,3)
semilogx(paris(grains_ph0),deltaarea(grains_ph0),'r.');
hold on, semilogx(paris(grains_ph1),deltaarea(grains_ph1),'b.');
hold on, semilogx(paris(grains_ph2),deltaarea(grains_ph2),'g.');
xlabel('paris'); ylabel('deltaarea');
grid on
axis tight

%%
% phase 0 as red, phase 1 blue, phase 2 green

%% Select Grains and its EBSD data by other properties

  %select grains with subfractions
grains_fractions = grains( hassubfraction(grains) );
  %and its corresponding ebsd data
ebsd_fractions = ebsd == grains_fractions

%%
figure('color','white'), hold all
plot(ebsd_fractions,'colorcoding','ihs')
plot(grains_fractions,'color','black','linewidth',1)
  % however the holes of a grain are plotted by default in an other color
plot(grains_fractions,'b','noholes','linewidth',1.5)
  % and now the fractions 
plotsubfractions(grains_fractions,'r','linewidth',2)
  % and its convex hull
plot(grains_fractions,'hull','b','linewidth',1.5)
  % and also ellipses of principal components
plotellipse(grains_fractions,'hull','scale',0.25,'b','linewidth',1.5)

%%
subfractionratio(grains_fractions)


%% Spatial Relation - Join Counts
% find out which phases depends on other phases and how
% therefor we can iterate over all grains access its ebsd data

coloring = grainfun('phase',grains,ebsd);

[J T q p] = joincount(grains,coloring)

%%
% obviolsy phase 1 and phase 2 are independent but not to phase 0,
% moreover, phase 2 and phase 0 are highly dependend. So let us visual
% inspect this behavior

figure('color','white'), hold on, set(gca,'colororder',[ 0.5 0.8 0; 1 0.2 0]);
plotspatial(ebsd([1 3]),'colorcoding','phase')

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
% perform analysis of phase 1 and calculate all ODFs of selected grains 

dirichlet = kernel('dirichlet',32);

odfs_ph1 = grainfun(@(ebsd) calcODF(ebsd,'kernel',dirichlet,'SILENT') , grains_ph1, ebsd);
odfs_ph2 = grainfun(@(ebsd) calcODF(ebsd,'kernel',dirichlet,'SILENT') , grains_ph2, ebsd);

%%
% and an overall ODF for all selected EBSD data

odf_ph1 = calcODF(ebsd(2),'kernel',dirichlet,'SILENT')
odf_ph2 = calcODF(ebsd(3),'kernel',dirichlet,'SILENT')

%% 
% the ODFs are returned as cells, since ODFs can be compositions, 
% we can proceed as the following 

odfs_ph1_textureindex = cellfun(@(odf) textureindex(odf),odfs_ph1,'uniformoutput',true);
odfs_ph2_textureindex = cellfun(@(odf) textureindex(odf),odfs_ph2,'uniformoutput',true);

%%
% and calculate an overall textureindex for both phases

odf_ph1_textureindex = textureindex(odf_ph1)
odf_ph2_textureindex = textureindex(odf_ph2)

%% 
% the ODFs are returned as cells, we can proceed as the following 

odfs_ph1_entropy = cellfun(@(odf) entropy(odf),odfs_ph1,'uniformoutput',true);
odfs_ph2_entropy = cellfun(@(odf) entropy(odf),odfs_ph2,'uniformoutput',true);

%%
% and calculate an overall entropy for both phases

odf_ph1_entropy = entropy(odf_ph1)
odf_ph2_entropy = entropy(odf_ph2)
 
%%
% for plotting

areas_ph1 = area(grains_ph1);
areas_ph2 = area(grains_ph2);
area_ph1 = sum(areas_ph1);
area_ph2 = sum(areas_ph2);

%%
% now we are ready to make scatter plots of grain properties

figure('color','white','Position',[15 50 1200 350]), subplot(1,3,1), hold on
plot(odfs_ph1_textureindex,odfs_ph1_entropy,'b.')
plot(odfs_ph2_textureindex,odfs_ph2_entropy,'r.')
plot(odf_ph1_textureindex,odf_ph1_entropy,'bx','MarkerSize',10,'LineWidth',2)
plot(odf_ph2_textureindex,odf_ph2_entropy,'rx','MarkerSize',10,'LineWidth',2)
xlabel('textureindex'); ylabel('entropy');
axis tight
grid on

subplot(1,3,2), hold on
plot(odfs_ph1_textureindex,areas_ph1,'b.')
plot(odfs_ph2_textureindex,areas_ph2,'r.')
plot(odf_ph1_textureindex,area_ph1,'bx','MarkerSize',10,'LineWidth',2)
plot(odf_ph2_textureindex,area_ph2,'rx','MarkerSize',10,'LineWidth',2)
xlabel('textureindex'); ylabel('area'); 
set(gca,'YScale','log')
axis tight
grid on

subplot(1,3,3), hold on
plot(odfs_ph1_entropy,areas_ph1,'b.')
plot(odfs_ph2_entropy,areas_ph2,'r.')
plot(odf_ph1_entropy,area_ph1,'bx','MarkerSize',10,'LineWidth',2)
plot(odf_ph1_entropy,area_ph2,'rx','MarkerSize',10,'LineWidth',2)
xlabel('entropy'); ylabel('area');
set(gca,'YScale','log','XDir','reverse')
axis tight
grid on

%%
% and 3d

figure('color','white'),  hold on
plot3(odfs_ph1_textureindex,odfs_ph1_entropy,areas_ph1,'b.')
plot3(odfs_ph2_textureindex,odfs_ph2_entropy,areas_ph2,'r.')
xlabel('textureindex'); ylabel('entropy'); zlabel('area');
set(gca,'ZScale','log','XScale','log')
view(120.0,22.0)
grid on

%% 
% clean up

% close all
% clear variables

