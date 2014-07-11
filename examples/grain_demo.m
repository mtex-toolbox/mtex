%% MTEX - Grain Analysis of EBSD Data
%
% Analysis of single orientation measurement.
%
%
%

%% Open in Editor
%

%% Specify Crystal and Specimen Symmetry

% specify crystal and specimen symmetry
CS = {...
  'not Indexed',...
  symmetry('m-3m','mineral','Fe'),... % crystal symmetry phase 1
  symmetry('m-3m','mineral','Mg')};   % crystal symmetry phase 2

%% Import ebsd data

fname = fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt');

ebsd = loadEBSD(fname,CS,'interface','generic',...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'MAD' 'BC'},...
  'Columns', [2 3 4 5 6 7 8 9],'Bunge','IgnorePhase',0);

plotx2east

%% Plot Spatial Data

plot(ebsd('Fe'))

%% Segmentation

grains = calcGrains(ebsd,'angle',10*degree)

%%
% The reconstructed grains strongly depend on the specified threshold
% angle. These angles can be specified seperatly for different phases.

grains = calcGrains(ebsd,'angle',[0 10 5]*degree)

%%
% Plot grain-boundaries

plotBoundary(grains,'color',[0.25 0.1 0.5])
hold on, plotBoundary(grains,'internal','color','red','linewidth',2)

%%
% on application of this would be to take a look on the grainsize
% distribution

% make a expotential bin size
x = fix(exp(.5:.5:7.5));
figure, bar( hist(grainSize(grains),x) );


%% Accessing geometric properties
%
area(grains); perimeter(grains);
shapefactor(grains); 


