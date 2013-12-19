%% 3d EBSD and Grains
% Demonstrates the 3d capabilities, i.e. slicing ebsd and grains, plotting
% 3d grains
%
%% Analysis of 3d EBSD data
% Import, analysis, and visualization of 3d EBSD data
%
%% Open in Editor
%  
%% Contents
%
%
%% Import the 3d EBSD
% Here we describe how to import a stack of 2d EBSD maps an to combine them to a
% 3D EBSD data set. Let us assume that the files are located in the directory

dirName = [mtexDataPath filesep 'EBSD' filesep '3dData'];

%%
% and let us assume that they are ordered such that the corresponding z - values
% are given by the list

% set up Z-Values
Z = (0:58)*0.12;

%%
% then a 3d EBSD object is imported by the command

% create an EBSD variable containing the data
ebsd = loadEBSD(dirName,'3d', Z,'convertEuler2SpatialReferenceFrame')

%% Visualize the 3d EBSD data
% Next we want to visualize these data. An interactive way to plot slices
% through the specimen is provided by the command

plot(ebsd)

%% 3d grain detection
% Grain detection in 3d data in completely analog to the two dimensional case.
% First we have to define a certain segmentation angle

segAngle = 10*degree;

%%
% Then the grains are reconstructed by the command <EBSD.calcGrains.html
% calcGrains>

grains = calcGrains(ebsd,'angle',segAngle)

%% Working on grains
% The reconstructed grains can be treated as in the two dimensional case. For example, 
% one can single out individual grains and plot them

large_ones = find(grainSize(grains)>1000);

single_grain = grains(large_ones(5))

close,   plot(single_grain,'facecolor','g','edgecolor',[0.8 0.8 0.8],...
  'facealpha',0.1)
hold on, plotBoundary(single_grain,'internal',...
  'FaceColor','r','edgecolor',[0.8 0.8 0.8])
set(gcf,'position',[100 100 500 400])
drawnow
view([160 20])

%%
% show sliced interior of the grain

hold on, plotKAM(single_grain)
drawnow
view([160 20])

%%
% We can compute the grain size of the grains, i.e. the number of measurements
% contained in one grain

grainSize(single_grain)

%%
% or the diameter

diameter(single_grain)

%% Visualize the 3d Grains
% Finally, we may extract all the grains that have a certain size and plot them

largeGrains = grains ( grainSize ( grains )>100 & grainSize ( grains ) <5000);

close, plot(largeGrains)
set(gcf,'position',[100 100 500 400])
drawnow
view([120 30])

material dull
camlight('headlight')
lighting phong


%% 
% smoothing geometry of grains has to be done for the whole grain-set,
% otherwise smoothing would mistreat topology

smooth_grains = smooth(grains,5);

%%
% observer intergranular misorientation
close, plot(smooth_grains(large_ones(5)),...
  'FaceColor','g','EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.05)

hold on, 
plotBoundary(smooth_grains(large_ones(5)),'internal',...
  'FaceColor','r','BoundaryColor','k','EdgeColor','k')
set(gcf,'position',[100 100 500 400])
drawnow
view([160 20])


