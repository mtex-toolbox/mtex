%% 3D Grains
%
%%
% grain3d is a structure to store 3D grain data. At the moment 3d data 
% is usually obtained from <NeperInterface.html neper tesselations>.
%
%%
job = neperInstance
cs = crystalSymmetry('432','mineral','copper');
ori = orientation.rand(cs);
odf = unimodalODF(ori);
numGrains=100;

grains3 = job.simulateGrains(odf,numGrains)
% or you can load an existing tesselation file
%grains3 = grain3d.load('allgrains.tess','CS',cs)

%%

% set camera
how2plot = plottingConvention;
how2plot.outOfScreen = vector3d(-10,-5,2);
how2plot.east = vector3d(1,-2,0);

plot(grains3,grains3.meanOrientation)
setCamera(how2plot)

%%

plot(grains3,grains3.volume)
setCamera(how2plot)


%% 

figure
grains = grains3(1:5)

plot(grains)


%% Slicing
%
% To get the usually used 2d grain data, it is possible to slice 3d grains
% by different methods.

% make all slices passing through this point
P0 = vector3d(0.5,0.5,0.5);

% Slice by plane normal and point
N = vector3d(1,-1,0);
% not working yet (produces a V with NaN)
grains1_10= grains3.slice(N,P0)

how2plot.outOfScreen = N;
plot(grains1_10,grains1_10.meanOrientation)

setCamera(how2plot)

%%

grains = grains3(1:5)

plot(grains,grains.meanOrientation)
how2plot.outOfScreen = vector3d(-10,-4,1);
how2plot.east = vector3d(2,-5,0);
setCamera(how2plot)

%%


% Slice by matgeom plane
N3 = vector3d(2,2,4);
plane = createPlane(P0.xyz, N3.xyz);     % consider the different order
grains224 = grains3.slice(plane);

% Slice going through 3 points
A = vector3d(0,0,0.5);
B = vector3d(0,1,0.5);
grains001 = grains3.slice(P0,A,B);

% plot the slices
plot(grains001,grains001.meanOrientation);
hold on
plot(grains1_10,grains1_10.meanOrientation);
hold on
plot(grains224,grains224.meanOrientation);

% set camera
how2plot = plottingConvention;
how2plot.outOfScreen = vector3d(-10,-5,2);
how2plot.east = vector3d(1,-2,0);
setCamera(how2plot)
