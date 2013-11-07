%% MTEX - Analysis of EBSD Data with gradual and subtle boundaries
%
% Overview of the fast multiscale clustering method for subgrain
% microstructure detection. The method constructs clusters in a
% hierarchical manner from single pixels using fuzzy logic to account for
% local, as well as global information.
%

%% Open in Editor


%% Import EBSD data

mtexdata single
plotx2east

figure('position',[100 100 800 350])
plot(ebsd)

%% Segment with thresholding
% No pixel-to-pixel threshold value captures important boundaries without
% including many irrelevant or false regions.
grains_high = calcGrains(ebsd,'angle',1*degree);
grains_low  = calcGrains(ebsd,'angle',0.5*degree);

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

grains_FMC = calcGrains(ebsd,'FMC',3.5)

%%
% plot the grains
figure('position',[100 100 800 350])
plot(grains_FMC,'sharp')

%%
% and overlay on the EBSD data for reference
figure('position',[500 100 800 350])
plot(ebsd,'sharp')
hold on
plotBoundary(grains_FMC,'linewidth',1.5)
