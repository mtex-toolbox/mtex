%% Operations with Three-Dimensional Grains
%
% The <EBSD3Analysis.html Three-Dimensional EBSD Analysis> overview
% distinguishes volume measurements from the @grain3d surface
% representation. This page shows how to cut those grains into a planar
% map, replace polygonal faces by triangles, and rotate geometry together
% with orientation.
%
% The examples use the synthetic tessellation introduced on the
% <NeperInterface.html Neper Interface> page. The preceding
% <Grains3DProperties.html Properties of Three-Dimensional Grains> page
% explains the volume, surface, and face properties used below.

plottingConvention.default('y↑→x');

%% Load the example microstructure

mtexdata NeperGrain3d

plot(grains,grains.meanOrientation,'micronbar','off')
setCamera(plottingConvention.default3D)

%%
% Each colour represents the mean orientation of one grain. The outer faces
% hide most of the grains inside the tessellated volume, which is why a
% planar section answers a different question from this surface view.

%% Cut one planar section
%
% <Grains3D.html Three-Dimensional Grains> introduces planar sectioning and
% the @grain2d result. The direct form of
% <grain3d.slice.html |slice|> used here specifies the plane by a normal |N|
% and any point |P0| in the plane.

% Point through which the plane passes.
P0 = vector3d(50,50,50);

% Plane normal.
N = vector3d(1,-1,1);

grainSlice = grains.slice(N,P0)

plot(grainSlice,grainSlice.meanOrientation,'micronbar','off')
setCamera(plottingConvention.default3D)

%%
% The slice is still drawn in the three-dimensional scene. From the default
% viewpoint it is seen obliquely. A plotting convention with |N| pointing
% out of the screen gives the face-on view a microscope would have.

sectionView = plottingConvention;
sectionView.outOfScreen = N;
sectionView.north = zvector;
setCamera(sectionView)

%%
% The polygons are cuts through grains, not complete grains. A grain that is
% large in this section may occupy little volume, and a large grain can be
% missed when the plane does not intersect it.
%
% The returned |Id3d| property records the array position of each parent
% grain in the original collection. Use it to recover the full polyhedra
% that produced selected section polygons.

parentIds = unique(grainSlice.Id3d);
parentGrains = grains(parentIds);

newMtexFigure('layout',[1,2]);
plot(grainSlice,grainSlice.meanOrientation,'micronbar','off')
setCamera(sectionView)
mtexTitle('Planar sections')

nextAxis
plot(parentGrains,parentGrains.meanOrientation,'micronbar','off')
setCamera(plottingConvention.default3D)
mtexTitle('Parent grains')

%%
% The left panel contains only the section polygons. The right panel shows
% their parent polyhedra extending on both sides of the cutting plane.

%% Compare several parallel sections
%
% Several slices require several calls to |slice|. Drawing horizontal cuts
% together shows how little of the volume any single section represents.

N = vector3d.Z;
for k = 1:19:99

  grainSlice = grains.slice(N,vector3d(0,0,k));
  plot(grainSlice,grainSlice.meanOrientation)
  % Interactive selection cannot combine grain2d objects from different planes.
  rmappdata(gca,'grains')
  hold on

end
hold off
setCamera(plottingConvention.default3D)

%%
% Follow one colour from slice to slice. A grain that is large in one
% section may be absent from the next.

%% Triangulate polygonal faces
%
% The faces of these grains are polygons with many vertices. Some
% computations are much faster on triangles.
% <grain3d.triangulate.html |triangulate|> returns equivalent grains whose
% polygonal faces have been divided into triangles.

selectedGrains = grains(20:21);
grainsTri = selectedGrains.triangulate

full([sum(selectedGrains.numFaces), sum(grainsTri.numFaces)])

plot(grainsTri,grainsTri.meanOrientation,'micronbar','off')
setCamera(plottingConvention.default3D)

%%
% The two grains have 34 polygonal faces before triangulation and 112
% triangular faces afterwards. The displayed shape is unchanged because the
% new triangles cover the same boundary polygons.
% Triangulation changes the mesh representation, not the physical grains or
% their stored mean orientations.

%% Rotate geometry and orientation together
%
% <grain3d.rotate.html |rotate|> turns grains in space. By default it rotates
% both things a grain carries: its shape and its orientation. Rotating only
% one of them would describe a different specimen rather than the same
% specimen seen differently.

rot = rotation.byAxisAngle(vector3d(1,1,1),30*degree);
grainsRotated = rot * grains;

plot(grainsRotated,grainsRotated.meanOrientation,'micronbar','off')
setCamera(plottingConvention.default3D)

%%
% The shape has turned about the coordinate origin, and the colours change.
% An IPF colour says which crystal direction points along a fixed specimen
% axis. Every mean orientation now differs from its original by exactly the
% 30 degree rotation. A rigid rotation preserves the relation between the
% grains, not their relation to the coordinate axes.
%
% The method form provides a |'center'| option when the spatial rotation
% should use a point other than the origin.

rotationCenter = grains.midPoint;
grainsAboutCenter = rotate(grains,rot,'center',rotationCenter);

%% Rotate only one part of the data
%
% Two flags deliberately decouple geometry from orientation. The names say
% which values are kept fixed, not which values are rotated.
%
% || Flag || Geometry || Mean orientation ||
% || |'keepEuler'| || rotated || unchanged ||
% || |'keepXY'| || unchanged || rotated ||
%
% For example, the first command below turns the vertices while retaining
% the orientation values. The second changes the orientations while
% retaining the vertices.

geometryOnly = rotate(grains,rot,'keepEuler');
orientationOnly = rotate(grains,rot,'keepXY');

%%
% These flags are useful when geometry and orientation require separate
% corrections. They do not represent a rigid rotation of the whole
% specimen. The |'center'| option affects only a spatial rotation, so it has
% no effect when |'keepXY'| leaves the geometry unchanged.

%% References
%
% * R. Quey, P. R. Dawson and F. Barbe,
% <https://doi.org/10.1016/j.cma.2011.01.002 Large-scale 3D random
% polycrystals for the finite element method: Generation, meshing and
% remeshing>, _Computer Methods in Applied Mechanics and Engineering_ 200
% (2011), 1729--1745, describes the synthetic polycrystal construction used
% for the example tessellation.

%#ok<*NOPTS>
