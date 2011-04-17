%% Analysis of 3d EBSD data
% Import, analysis, and visualization of 3d EBSD data
%
%% Open in Editor
%  
%% Contents
%
%
%% Import the 3d EBSD
% Here we describe how to import a stack of 2d EBSD data an to combine them
% to a 3D EBSD data set. Let us assume that the files are located in the
% directory 

dirName = [mtexDataPath filesep 'EBSD' filesep '3dData'];

%%
% and let us assume that they are ordered such that the corresponding z -
% values are given by the list

% set up Z-Values
Z = (0:58)*0.12;

%%
% then an 3d EBSD object is imported by the command

% create an EBSD variable containing the data
ebsd = loadEBSD(dirName,'3d', Z)

%% Visualize the 3d EBSD data
% Next we want to visualize these data. An interactive way to plot slices
% through the specimen is provided by the command 

slice3(ebsd)


%% 3d grain detection
% Grain detection in 3d data in completely analog to the two dimensional
% case. First we have to define a certain segmentation angle

segAngle = 10*degree;

% Then the grains are reconstructed by the command <EBSD.calcGrains.html calcGrains>

[grains ebsd] = calcGrains(ebsd,'angle',segAngle,'unitcell');


%% Working on grains

largeGrains = grains ( grainSize ( grains )>100 & grainSize ( grains ) <5000);
plot(largeGrains)
set(gca,'CameraPosition',[140 -60 50])
light


