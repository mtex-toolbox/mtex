job = neperInstance

cs = crystalSymmetry('432');
ori = orientation.rand(cs);
odf = unimodalODF(ori);
numGrains=100;

job.simulateGrains(odf,numGrains)
grains = grain3d.load('allgrains.tess')

plot(grains,grains.meanOrientation)

%% Slicing

% make all slices passing through this point
P0 = vector3d(0.5,0.5,0.5);

% by plane normal and point
N = vector3d(1,-1,0);

% not working yet (produces a V with NaN)
grains1_10= grains.slice(N,P0);

% by matgeom plane
N3 = vector3d(2,2,4);
plane = createPlane(P0.xyz, N3.xyz);     % consider the different order

grains224 = grains.slice(plane);

% slice going through 3 points
A = vector3d(0,0,0.5);
B = vector3d(0,1,0.5);

grains001 = grains.slice(P0,A,B);

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


