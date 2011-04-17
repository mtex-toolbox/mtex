%% Import Script for EBSD Data
%
% This script was automatically created by the import wizard. You should
% run the whoole script or parts of it in order to import your data. There
% is no problem in making any chages to this scrip.

%% Import the Data

% set up Z-Values
Z = (0:58)*0.12;

% create an EBSD variable containing the data
ebsd = loadEBSD('3d/S*','3d', Z)


%% Default template
%% Visualize the Data

slice3(ebsd)


%% Detect grains

%segmentation angle
segAngle = 10*degree;

[grains ebsd] = calcGrains(ebsd,'angle',segAngle,'unitcell');

%% plot large grains

largeGrains = grains ( grainSize ( grains )>100 & grainSize ( grains ) <5000);
plot(largeGrains)
set(gca,'CameraPosition',[140 -60 50])
light


