%% Operations with Three-Dimensional Grains
%
%%
% Three dimensional grains support the operations two dimensional ones do,
% and one they cannot: cutting. A section through a volume is exactly the
% two dimensional data a polished surface would have given, which makes it
% the tool for asking what a section does and does not show - see
% <EBSD3Analysis.html the chapter opener>.

mtexdata NeperGrain3d

% colorize by mean orientation
plot(grains,grains.meanOrientation)
setCamera(plottingConvention.default3D)

%% Slicing
%
% <grain3d.slice.html |slice|> cuts the volume with a plane, given by its
% normal |N| and any point |P0| on it, and returns two dimensional grains.

% a point where the slice should pass through
P0 = vector3d(50,50,50);

% the normal direction of the slice
N = vector3d(1,-1,1);

% compute the slice
grains1_10 = grains.slice(N,P0)

% visualize the slice
plot(grains1_10,grains1_10.meanOrientation,'micronbar','off')
setCamera(plottingConvention.default3D)

%%
% The slice is still drawn in the three dimensional scene, seen edge on from
% the current viewpoint. Turning the camera so that the plane normal points
% out of the screen gives the view a microscope would have.

how2plot = plottingConvention;
how2plot.outOfScreen = N;
how2plot.north = zvector
setCamera(how2plot)

%%
% This is the same specimen a two dimensional analysis would have measured,
% and comparing it with the volume it came from is the point: the areas seen
% here are cuts through grains, not grains.
%
% Several slices are several calls, and drawing them together shows how
% little of the volume any one of them represents.

N = vector3d.Z;
for k = 1:19:99

  grainSlice = grains.slice(N, vector3d(0,0,k));

  plot(grainSlice,grainSlice.meanOrientation)
  hold on

end
hold off

setCamera(plottingConvention.default3D)

%%
% Follow one colour from slice to slice: a grain that is large in one
% section may be absent from the next.

%% Triangulation
%
% The faces of these grains are polygons with many vertices. Some
% computations are much faster on triangles, and
% <grain3d.triangulate.html |triangulate|> converts a grain into an
% equivalent one built from them.

grainsTri = grains(20:21).triangulate

plot(grainsTri,grainsTri.meanOrientation)

%%
% The shape is unchanged - the display shows the same two grains with many
% more faces.

%% Rotation
%
% <grain3d.rotate.html |rotate|> turns grains in space. Note that it rotates
% both things a grain carries: its shape and its orientation. Rotating only
% one of them would describe a different specimen rather than the same
% specimen seen differently.

rot = rotation.byAxisAngle(vector3d(1,1,1),30*degree);
grains_rot = rot * grains;   % or rotate(grains3,rot)

% plotting
plot(grains_rot,grains_rot.meanOrientation)

%%
% The colours change, and they should. An IPF colour says which crystal
% direction points along a fixed specimen axis, and it is the specimen that
% has been turned - every mean orientation now differs from its original by
% exactly the 30 degrees of the rotation. What a rotation preserves is the
% relation between the grains, not their relation to the coordinate axes.

%#ok<*NOPTS>
