%% Analysis of 3d EBSD data
% Import, analysis, and visualization of 3d EBSD data
%
%% Open in Editor
%  
%% Contents
%
%
%% Import the 3d EBSD
% Here we describe how to import a stack of 2d EBSD data an to combine them to a
% 3D EBSD data set. Let us assume that the files are located in the directory

dirName = [mtexDataPath filesep 'EBSD' filesep '3dData'];

%%
% and let us assume that they are ordered such that the corresponding z - values
% are given by the list

% set up Z-Values
Z = (0:58)*0.12;

%%
% then an 3d EBSD object is imported by the command

% create an EBSD variable containing the data
ebsd = loadEBSD(dirName,'3d', Z)

%% Visualize the 3d EBSD data
% Next we want to visualize these data. An interactive way to plot slices
% through the specimen is provided by the command

plot(ebsd)


%% 3d grain detection
% Grain detection in 3d data in completely analog to the two dimensional case.
% First we have to define a certain segmentation angle

segAngle = 10*degree;

%%
% Then the grains are reconstructed by the command <EBSD_calcGrains.html
% calcGrains>

[grains ebsd] = calcGrains(ebsd,'threshold',segAngle,'unitcell')


%% Working on grains
% The reconstructed can be threaded as in the two dimensional case. E.g. one can
% single out individuall grains and plot them


plot(grains(906),'facecolor','g','edgecolor',[0.8 0.8 0.8],'facealpha',0.3)
hold on
plotSubBoundary(grains(906),'FaceColor','c','boundarycolor','r','edgecolor',[0.8 0.8 0.8])

view([160 20])

%%
% We can compute the grainSize of the grains, i.e. the number of measurements
% contained in the grain

grainSize(grains(906))

%%
% or the diameter

diameter(grains(906))


%%
% average misorientation angle on subgrain boundary

%subBoundaryAngle(grains(906),ebsd)/degree


%% Visualize the 3d Grains
% Finally, we may extract all grains that have a certain size and plot them

largeGrains = grains ( grainSize ( grains )>100 & grainSize ( grains ) <5000);
plot(largeGrains)

view([120 30])


material dull
camlight('headlight')
lighting phong


%% 
% smoothing geometry of grains has to be done for the whole grain-set,
% otherwise smoothing would mistreat topology

smooth_grains = smooth(grains,10);

%%
% Advanced investigation of grain boundaries: investigate the misorientation
% angle to neighboured grains
% herefor, we select first a large grains and all its neighbors 

grain = smooth_grains(smooth_grains == largeGrains(18));
neighbouredGrains = neighbours(smooth_grains,grain)

%%
% plotting the common boundary needs selection of a partner grain, otherwise
% all grain boundaries to a set of neigbored grains would be figured

figure, hold on

for partnerGrain = neighbouredGrains
  if partnerGrain ~= grain
   plotBoundary([grain partnerGrain],'property','angle','FaceAlpha',1,'BoundaryColor','k');
  end
end 
colorbar

plot(neighbouredGrains(1:end-2),'facealpha',0.1,'edgecolor','k')

view([150 20])
material dull

camlight('headlight')
lighting phong


%%
% observer intergranular misorientation

plot(smooth_grains(906),...
  'FaceColor','g','EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.05)

hold on, 
plotSubBoundary(smooth_grains(906),...
  'FaceColor','c','BoundaryColor','r','EdgeColor','k')

%slice3( misorientation(grains,ebsd),'y',1.25,'property','angle',...
%  'FaceAlpha',0.7)

view([35 15])

%%
% show sliced surface of grains

slice3(smooth_grains,'x',5,'margin',1,...
  'FaceColor','k','FaceAlpha',0.3)

hold on
slice3(ebsd,'x',4.25)
axis tight
view(105,15)




