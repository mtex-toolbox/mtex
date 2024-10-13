%% 3D Grains
%
%%
% Variables of type @grain3d store 3D grain data. At the moment 3d grains
% can be imported from <NeperInterface.html Neper% > or from Dream3d.
%
%% Grain sets from Dream3d

grains = grain3d.load(fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d'));

% for triangulated data sets it may be useful to plot them without lines
plot(grains,grains.meanOrientation,'LineStyle','none')

how2plot = plottingConvention;
how2plot.outOfScreen = vector3d(-10,-5,2);
how2plot.east = vector3d(1,-2,0);
setCamera(how2plot)

%%
% Similarly as with two dimensional grains we can select individual grains
% by arbitrary constraints. For instance we can find the largest grain by

% index of the grain with the largest volume
[~,id] = max(grains.volume)

plot(grains(id),grains(id).meanOrientation)
setCamera(how2plot)

%% Grain sets from Neper
% <https://neper.info Neper> is a software package for the simulation of
% three dimensional microstructures. After installation it can be directly
% called by MTEX. The general workflow is explained <NeperInterface.html
% here>. Here we use it to quickly generate a copper microstructure with
% specific texture and specific distribution of boundary normals.

% set up the communication with Neper
job = neperInstance;

% define a texture 
cs = crystalSymmetry.load('quartz.cif','color','lightblue');
odf = fibreODF(cs.cAxis,vector3d(1,1,1));

numGrains=100;
grains = job.simulateGrains(odf,numGrains,'silent')
% or you can load an existing tessellation file
%grains = grain3d.load('allgrains.tess','CS',cs)

% colorize by mean orientation
plot(grains,grains.meanOrientation,'micronbar','off')
setCamera(how2plot)

%% Slicing
%
% To get the usually used 2d grain data, it is possible to slice 3d grains
% by different methods.

% make all slices passing through the center point of the cube
P0 = vector3d(0.5,0.5,0.5);
% with normal (1,-1,1)
N = vector3d(1,-1,1);

grains_2d = grains.slice(N,P0)

% plot the slice and adjust the plotting convention such that N points out
% of screen
plot(grains_2d,grains_2d.meanOrientation,'micronbar','off')
how2plot = plottingConvention;
how2plot.outOfScreen = N;
setCamera(how2plot)

%% Grains intersecting a slice
%
% Lets plot the grains intersecting the plane in 3d

isInter = grains.intersected(N,P0);
hold on
plot(grains(isInter),grains(isInter).meanOrientation)
hold off

how2plot.north = N;
how2plot.outOfScreen = vector3d(1,-1,-1)
setCamera(how2plot)

%% Plot the normal directions of one grain

%grains = grains(1)
%dir = grains.I_GF(1,:)' .* grains.boundary.N % flip according to I_GF
%quiver(grains.boundary,dir)
%plot(grains)



%#ok<*NOPTS>