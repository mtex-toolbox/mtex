%% Operations with Three-Dimensional Grains
%
% In this section we explain some basic operations with three dimensional
% grains. Lets start by importing some example data set and plot it from a
% nice perspective

mtexdata NeperGrain3d

%%
% The grains are stored in variable |grains| which 



%% Plotting Grains
% By default three dimensional grains are plotted by color

% set camera
how2plot = plottingConvention;
how2plot.outOfScreen = vector3d(-10,-5,2);
how2plot.east = vector3d(1,-2,0);

% colorize by mean orientation
plot(grains,grains.meanOrientation)
setCamera(how2plot)




%% Slicing
%
% To get the usually used 2d grain data, it is possible to slice 3d grains
% by different methods.

% make all slices passing through this point
P0 = vector3d(0.5,0.5,0.5);

% Slice by plane normal and point
N = vector3d(1,-1,0);
grains1_10 = grains3.slice(N,P0)

how2plot = plottingConvention;
how2plot.outOfScreen = N;
plot(grains1_10,grains1_10.meanOrientation)
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

%% 
% Plot single 3D grains together with slices
grains = grains3(1:5)

plot(grains,grains.meanOrientation)
how2plot.outOfScreen = vector3d(-10,-4,1);
how2plot.east = vector3d(2,-5,0);
setCamera(how2plot)




%% Selecting 



%% Rotation
% rotate 180 degrees about the x-axis
rot = rotation.byAxisAngle(xvector,180*degree);
grains3_rot = rot * grains3;   % or rotate(grains3,rot)

% plotting
plot(grains3_rot,grains3_rot.meanOrientation)

%% 
% colorize by volume
plot(grains3,grains3.volume)
setCamera(how2plot)



%% Triangulation
% Some functions are much faster on triangulated meshes. Therefore you can
% triangulate your grains with the following command.

grainsTri = grains3.triangulate


plot(grainsTri,grainsTri.meanOrientation)



%% Slice Dream3d Grains
% still inefficient, expensive
N = vector3d(1,1,1);
P0 = vector3d(0.5,0.5,0.5);

slice = grains_dream_3d.slice(N,P0);
plot(slice,slice.meanOrientation);

%#ok<*NOPTS>