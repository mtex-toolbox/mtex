%% MTEX - Analysis of EBSD Data with gradual and subtle boundaries
%
% Overview of the fast multiscale clustering method for subgrain
% microstructure detection. The method constructs clusters in a
% hierarchical manner from single pixels using fuzzy logic to account for
% local, as well as global information.
%

%% Open in Editor


%% Import EBSD data

% load some data
mtexdata single
plotx2east

% prepare sharp colorcoding
oM = ipdfHSVOrientationMapping(ebsd);
oM.inversePoleFigureDirection = mean(ebsd.orientations) * oM.whiteCenter;
oM.colorStretching = 3

plot(ebsd,oM.orientation2color(ebsd.orientations))

%% Segment with thresholding
% No pixel-to-pixel threshold value captures important boundaries without
% including many irrelevant or false regions.
grains_high = calcGrains(ebsd,'angle',1*degree);
grains_low  = calcGrains(ebsd,'angle',0.5*degree);

hold on
plot(grains_low.boundary,'linecolor',0.7*[1 1 1])
plot(grains_high.boundary,'linecolor','k')
hold off

%% Segment with FMC
% Analogous with the threshold angle, a  single parameter, C_Maha controls
% the sensitivity of the segmentation. A C_Maha value of 3.5 properly 
% identifies the  subgrain features. A C_Maha value of 3 captures more
% general features, while a value of 4 identifies finer features but is
% slightly oversegmented.

grains_FMC = calcGrains(ebsd,'FMC',3.5)

%%
% plot the grains
plot(ebsd,oM.orientation2color(ebsd.orientations))
hold on
plot(grains_FMC.boundary,'linewidth',1.5)
hold off
