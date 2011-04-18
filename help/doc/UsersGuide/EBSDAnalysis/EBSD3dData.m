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

%%
% Then the grains are reconstructed by the command <EBSD_calcGrains.html calcGrains>

[grains ebsd] = calcGrains(ebsd,'angle',segAngle,'unitcell');


%% Working on grains
% The reconstructed can be threaded as in the two dimensional case. E.g.
% one can single out individuall grains and plot them 

plot(grains(583))
view([160 20])

material([.8  .5 .1])
axis tight
grid on

camlight('headlight')
lighting phong


%%
% We can compute the grainSize of the grains, i.e. the number of
% measurements contained in the grain

grainSize(grains(583))

%%
% or the diameter

diameter(grains(583))


%% Visualize the 3d Grains
% Finally, we may extract all grains that have a certain size and plot them

largeGrains = grains ( grainSize ( grains )>100 & grainSize ( grains ) <5000);
plot(largeGrains)

view([120 30])

material([.8  .5 .1])
axis tight
grid on

camlight('headlight')
lighting phong

%%
% Advanced investigation of grain boundaries: investigate the misorientation
% angle to neighboured grains

grain = largeGrains(19);

figure, hold on
neighbouredGrains = neighbours(grains,grain);
for partnerGrain = neighbouredGrains
  if partnerGrain ~= grain
   plotboundary([grain partnerGrain],'property','angle','FaceAlpha',1,'BoundaryColor','k');
  end
end 
colorbar

plot(neighbouredGrains(1:end-3),'facealpha',0.1)

view([-25 30])
material([.6  .6 .1])
axis tight equal
grid on

camlight('headlight')
lighting phong





