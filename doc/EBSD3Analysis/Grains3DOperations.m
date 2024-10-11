%% Operations with Three-Dimensional Grains
%
%%
% On this page we explain some basic operations with three dimensional
% grains. Let us start by importing some example data set and plot it from
% a nice perspective

mtexdata NeperGrain3d

% colorize by mean orientation
plot(grains,grains.meanOrientation)
setCamera(plottingConvention.default3D)

%% Slicing
% We can extract from 3d grain data 2d grain data by slicing them along one
% or multiple planes. This is done using the command <grain3d.slice.html
% |slice|>. This command requires two inputs to characterize a plane -
% the plane normal |N| and an arbitrary point |P0| within the plane.

% a point where the slice should pass through
P0 = vector3d(50,50,50);

% the normal direction of the slice
N = vector3d(1,-1,0);

% compute the slice
grains1_10 = grains.slice(N,P0)

% visualize the slice
plot(grains1_10,grains1_10.meanOrientation,'micronbar','off')
setCamera(plottingConvention.default3D)

%%
% We may adjust the @plottingConvention such that the normal direction is
% perpendicular to the screen.

how2plot = plottingConvention;
how2plot.outOfScreen = N;
how2plot.north = zvector
setCamera(how2plot)

%%
% We may use the exact same syntax to generate multiple slices.

N = vector3d.Z;
for k = 1:19:99
  
  grainSlice = grains.slice(N, vector3d(0,0,k));

  plot(grainSlice,grainSlice.meanOrientation)
  hold on

end
hold off

setCamera(plottingConvention.default3D)

%% Triangulation
% Some functions are much faster on triangulated meshes. Therefore you can
% triangulate your grains with the command <grain3d.triangulate.html
% |triangulate|>.

grainsTri = grains(20).triangulate

plot(grainsTri,grainsTri.meanOrientation)


%% Rotation
% Not surprisingly we can use the command <grain3d.rotate.html |rotate|> to
% apply any rotation to three dimensional grains. Note that a rotation
% changes the spatial coordinates as well as the orientations of the
% grains.

rot = rotation.byAxisAngle(vector3d(1,1,1),30*degree);
grains_rot = rot * grains;   % or rotate(grains3,rot)

% plotting
plot(grains_rot,grains_rot.meanOrientation)


%#ok<*NOPTS>