%% MTEX - Analysis of EBSD Data with gradual and subtle boundaries
%
% Overview of the fast multiscale clustering method for subgrain
% microstructure detection. The method constructs clusters in a
% hierarchical manner from single pixels using fuzzy logic to account for
% local, as well as global information.
%

%% Open in Editor


%% Import EBSD data
% specify Crystal and Specimen Symmetry
CS = symmetry('cubic'); % crystal symmetry
SS = symmetry('cubic');   % specimen symmetry

% file name 
fname = fullfile(mtexDataPath,'EBSD','single_grain_aluminum.txt');

% fname = 'scanClean35.txt';

% import ebsd data
ebsd = loadEBSD(fname, CS, SS, 'interface','generic',...
   'RADIANS','ColumnNames', { 'Euler 1' 'Euler 2' 'Euler 3' 'x' 'y'},...
  'Columns', [1 2 3 4 5],'ignorePhase', 0, 'Bunge');

% plotting convention
plotx2east

figure('position',[100 100 800 350])
plot(ebsd)

%% Segment with thresholding
% No pixel-to-pixel threshold value captures important boundaries without
% including many irrelevant or false regions.
grains_high = calcGrainsFMC(ebsd,'threshold',1*degree, 'keepNotIndexed');
grains_low = calcGrainsFMC(ebsd,'threshold',0.5*degree, 'keepNotIndexed');


figure('position',[100 100 800 350])
plot(grains_high)
figure('position',[500 100 800 350])
plot(grains_low)



%% Segment with FMC
% Analogous with the threshold angle, a  single parameter, C_Maha controls
% the sensitivity of the segmentation. A C_Maha value of 3.5 properly 
% identifies the  subgrain features. A C_Maha value of 3 captures more
% general features, while a value of 4 identifies finer features but is
% slightly oversegmented.

grains_FMC = calcGrainsFMC(ebsd,'FMC',3.5)

%%
% plot the grains
figure('position',[100 100 800 350])
plot(grains_FMC)

%%
% and overlay on the EBSD data for reference
figure('position',[500 100 800 350])
plot(ebsd)
hold on
plotBoundary(grains_FMC,'linewidth',1.5)
