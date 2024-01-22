%% 3D Grains
%
%%
% grain3d is a structure to store 3D grain data. At the moment 3d data 
% is usually obtained from <NeperInterface.html neper tesselations>.
%
%%
job = neperInstance
cs = crystalSymmetry('432');
ori = orientation.rand(cs);
odf = unimodalODF(ori);
numGrains=100;

job.simulateGrains(odf,numGrains)
grains = grain3d.load('allgrains.tess')

plot(grains,grains.meanOrientation)

%% Slicing
%
% To get the usually used 2d grain data, it is possible to slice 3d grains
% by different methods.

% make all slices passing through this point
P0 = vector3d(0.5,0.5,0.5);

% Slice by plane normal and point
N = vector3d(1,-1,0);
% not working yet (produces a V with NaN)
grains1_10= grains.slice(N,P0);

% Slice by matgeom plane
N3 = vector3d(2,2,4);
plane = createPlane(P0.xyz, N3.xyz);     % consider the different order
grains224 = grains.slice(plane);

% Slice going through 3 points
A = vector3d(0,0,0.5);
B = vector3d(0,1,0.5);
grains001 = grains.slice(P0,A,B);

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
