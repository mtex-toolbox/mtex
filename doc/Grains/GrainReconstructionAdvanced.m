%% Advanced Grain Reconstruction

%% 1) no fill, no grains, all pixels
mtexdata small
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd);
ebsd(grains(grains.grainSize<=3)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd);
F = splineFilter; 
ebsd = smooth(ebsd,F);
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd);
plot(ebsd)
hold on
plot(grains.boundary,'lineColor',[1 0 0],'linewidth',2)
hold off


%% 2) no fill, no grains, indexed pixels
mtexdata small
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
ebsd(grains(grains.grainSize<=3)) = [];
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
F = splineFilter; 
ebsd = smooth(ebsd('indexed'),F);
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));

nextAxis
plot(ebsd)
hold on
plot(grains.boundary,'lineColor',[1 0 0],'linewidth',2)
hold off


%% 3) fill, no grains, all pixels
mtexdata small
[grains,ebsd.grainId] = calcGrains(ebsd);
ebsd(grains(grains.grainSize<=3)) = [];
[grains,ebsd.grainId] = calcGrains(ebsd);
F = splineFilter; 
ebsd = smooth(ebsd,F,'fill');
[grains,ebsd.grainId] = calcGrains(ebsd);

nextAxis
plot(ebsd)
hold on
plot(grains.boundary,'lineColor',[1 0 0],'linewidth',2)
hold off


%% 4) fill, no grains, indexed pixels
mtexdata small
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
ebsd(grains(grains.grainSize<=3)) = [];
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
F = splineFilter; 
ebsd = smooth(ebsd('indexed'),F,'fill');
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));

nextAxis
plot(ebsd)
hold on
plot(grains.boundary,'lineColor',[1 0 0],'linewidth',2)
hold off


%% 5) fill, grains, indexed pixels
mtexdata small
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
ebsd(grains(grains.grainSize<=3)) = [];
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
F = splineFilter; 
ebsd = smooth(ebsd('indexed'),F,'fill',grains);
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));

nextAxis
plot(ebsd)
hold on
plot(grains.boundary,'lineColor',[1 0 0],'linewidth',2)
hold off
drawNow(gcm)

%% 6) Multiscale clustering method

mtexdata small
grains = calcGrains(ebsd('indexed'),'FMC',1)
nextAxis
plot(ebsd)
hold on
plot(grains.boundary,'lineColor',[1 0 0],'linewidth',2)
hold off
drawNow(gcm)

%% Multiscale clustering method
%
% When analyzing grains with gradual and subtle boundaries the threshold
% based method may not lead to the desired result.
%
% Let us consider the following example

mtexdata single

colorKey = axisAngleColorKey(ebsd);
colorKey.oriRef = mean(ebsd.orientations);

plot(ebsd,colorKey.orientation2color(ebsd.orientations))

%%
% We obeserve that the are no rapid changes in the orientation which would
% allow for applying the threshold based algorithm. Setting the threshold
% angle to a very small value would include many irrelevant or false regions.

grains_high = calcGrains(ebsd,'angle',1*degree);
grains_low  = calcGrains(ebsd,'angle',0.5*degree);

figure
plot(ebsd,colorKey.orientation2color(ebsd.orientations))
hold on
plot(grains_high.boundary)
hold off

figure
plot(ebsd,colorKey.orientation2color(ebsd.orientations))
hold on
plot(grains_low.boundary)
hold off
%%
% As an alternative MTEX includes the fast multiscale clustering method
% (FMC method) which  constructs clusters in a hierarchical manner from
% single pixels using fuzzy logic to account for local, as well as global
% information.
%
% Analogous with the threshold angle, a  single parameter, C_Maha controls
% the sensitivity of the segmentation. A C_Maha value of 3.5 properly 
% identifies the  subgrain features. A C_Maha value of 3 captures more
% general features, while a value of 4 identifies finer features but is
% slightly oversegmented.
%

grains_FMC = calcGrains(ebsd('indexed'),'FMC',3.8)
grains = calcGrains(ebsd('indexed'))

% smooth grains to remove staircase effect
grains_FMC = smooth(grains_FMC);

%%
% We observe how this method nicely splits the measurements into clusters
% of similar orientation

%plot(ebsd,oM.orientation2color(ebsd.orientations))
plot(ebsd,colorKey.orientation2color(ebsd.orientations))

% start overide mode
hold on
plot(grains_FMC.boundary,'linewidth',1.5)

% stop overide mode
hold off

%% Markovian Clustering Algorithm

F = halfQuadraticFilter
F.alpha = 0.5
ebsd = smooth(ebsd,F)

%%

grains = calcGrains(ebsd,'mcl',[1.24 50],'soft',[0.2 0.3]*degree)

grains = smooth(grains,5)

plot(ebsd,colorKey.orientation2color(ebsd.orientations))

hold on;plot(grains.boundary,'linewidth',2); hold off










