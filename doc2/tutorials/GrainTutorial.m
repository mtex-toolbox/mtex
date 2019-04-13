%% Grain Tutorial
%
%% Data import
% We start by importing some EBSD data 

% import a demo data set
mtexdata small
plotx2east

% visualize the orientations according by the default ipf color key
plot(ebsd('Fo'),ebsd('Fo').orientations)
hold on
plot(ebsd('En'),ebsd('En').orientations)
plot(ebsd('Di'),ebsd('Di').orientations)
hold off

%% Grain reconstruction
% 
% Grains are reconstructed by the command <EBSD.calcGrains.html calcGrains>
% which uses as main parameter a threshold angle to identify grain
% boundaries.

% perform grain segmentation
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',10*degree);
grains

%% Visualize the grain boundary
% We may plot the grain boundaries on top of our orientation map

hold on
plot(grains.boundary,'linewidth',2)
hold off


%% The grain boudary
%
% The grain boundary segments are stored within the grain variable an can
% be extracted by the command

gB = grains.boundary

%%
% How to analyse grain boundaries is described in the
% <GrainBoundaryTutorial.html grain boundary tutorial>.

%% Visualize the grain orientations
%
% We may visualize the grain mean orientations by plotting an accordingly
% rotated <CrystalShapeTutorial.html crystal shape>.

% define the unrotated crystal shape for the Forsterite phase
cS = crystalShape.olivine(ebsd('Fo').CS)

% plot the crystal shapes on top of the previous plot
hold on
plot(grains('Fo'),0.8*cS,'FaceColor',[1 1 0],'FaceAlpha',0.5)
hold off

%% Grain properties and shape parameters
% 
% Beside the boundary grains have many other properties. A complete list of
% grain properties and shape parameters can be found in the section
% <ShapeParameters.html shape parameters>. Lets consider as an example the
% area of the grains

% extract the grain area
area = grains.area;

% and colorize the grains according to their area
plot(grains,area)

%% Extracting specific grains
%
% Grain properties can be used to extract specific grains. As an example we
% ask for the largest grain

% detect the largest grain
[~,id] = max(grains.area);

grains(id)

%%
% Lets highlight this grain.

hold on
plot(grains(id).boundary,'LineWidth',2,'lineColor','red')
hold off

%% Accessing the orientation within a grain
%
% During grain segmentation a grainId has been stored for each pixel in our
% EBSD map. This grainId may used to access the ebsd data within a specific
% grain

% select EBSD data inside the maximum grain
ebsd_maxGrain = ebsd(ebsd.grainId == id)

% the previous command is equivalent to the more simple
ebsd_maxGrain = ebsd(grains(id));

%%
% Lets visualize the misorientation angle between the orientations within
% the grain and the grain meanorientation

% compute the misorientation angle
moriAngle = angle(grains(id).meanOrientation, ebsd_maxGrain.orientations);

% plot the misorientation angle in degree
plot(ebsd_maxGrain,moriAngle./degree)

% plot the surrounding grain boundary
hold on
plot(grains(id).boundary,'lineWidth',2)
hold off

% add a colorbar
mtexColorbar('title','misorientation angle')
