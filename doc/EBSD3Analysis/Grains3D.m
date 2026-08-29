%% Three-Dimensional Grains
%
% In EBSD grain segmentation, a grain is a phase-homogeneous, spatially
% connected region of pixels produced by segmentation. In three dimensions,
% MTEX represents its counterpart by the faces of a closed polyhedron and
% stores a collection as a @grain3d object. The faces provide the geometry;
% phase and mean orientation describe the material inside each polyhedron.
%
% This page follows one collection from import through selection, sectioning,
% and inspection of its boundary normals. The following pages explain the
% <NeperInterface.html Neper workflow>,
% <Grains3DProperties.html geometric properties>, and
% <Grains3DOperations.html operations on three-dimensional grains> in detail.

plottingConvention.default('y↑→x');
how2plot = plottingConvention.default3D;

%% Import a DREAM.3D surface mesh
%
% <grain3d.load.html |grain3d.load|> reads a DREAM.3D triangle mesh into a
% @grain3d collection. A voxel-only file does not contain the boundary faces
% needed for this representation.

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');
grains = grain3d.load(fname)

%% Read the imported microstructure
%
% The command-window summary reports the phases, number of grains, total
% volume, boundary faces, and attached properties. The example contains 794
% grains. Plotting the mean orientation assigns one orientation colour to
% each polyhedron; it does not display pointwise orientation variation.

plot(grains,grains.meanOrientation,'LineStyle','none','micronbar','off')
setCamera(how2plot)

%%
% The colour changes sharply at grain faces, while suppressing mesh lines
% makes the outer shape of the reconstructed volume easier to see.

%% Why face winding matters
%
% A face normal is perpendicular to one boundary face. Its sign follows from
% the order of the face vertices, called the face winding. DREAM.3D stores
% faces with arbitrary winding, so the stored normal may point into or out of
% a grain.
%
% By default, the importer calls <grain3d.orientFaces.html |orientFaces|>.
% MTEX then uses |I_GF| to record which direction is outward for each grain.
% This makes signed volumes and |boundary.grainId| directly usable.
% Request the raw DREAM.3D winding only when that order is itself needed.

grainsRaw = grain3d.load(fname,'noOrientFaces');

%%
% The first value below counts negative raw volumes; the second checks the
% oriented import. Before orientation, 419 of the 794 grains have negative
% volume because their corresponding normals point inwards.

[nnz(grainsRaw.volume < 0), nnz(grains.volume < 0)]

%% Select a grain
%
% A collection can be indexed by any logical condition. The following code
% finds the array position of the largest grain and then plots that grain.
% Grain IDs and array positions can differ after subsetting, so use an ID
% query when the persistent identity matters.

[~,id] = max(grains.volume)

plot(grains(id),'edgeAlpha',0.15,'micronBar','off')
setCamera(how2plot)

%%
% The translucent edges expose the triangular boundary mesh of the selected
% polyhedron. The result is one three-dimensional grain, not a planar section.

%% Cut a planar section
%
% A <plane3d.plane3d.html |plane3d|> is defined by a normal direction and a
% point in the plane. <grain3d.slice.html |slice|> intersects that plane with
% every grain and returns the resulting polygons as a @grain2d collection,
% comparable to what can be reconstructed from a two-dimensional EBSD map.

plane = plane3d(vector3d(1,1,1),vector3d(-20,20,-15));
grains2 = slice(grains,plane)

plot(grains2,grains2.meanOrientation,'micronbar','off')
setCamera(how2plot)

%%
% The plot contains only grains crossed by the plane. Each polygon inherits
% the mean orientation of its parent three-dimensional grain.
%
% For a face-on view, use a plotting convention whose out-of-screen direction
% is the section normal. The east direction fixes the remaining in-plane
% freedom.

how2plot2 = plottingConvention;
how2plot2.outOfScreen = grains2.N;
how2plot2.east = vector3d(1,-1,0);
setCamera(how2plot2), axis off, xlabel(''), ylabel('')

%% Generate a synthetic collection with Neper
%
% <https://neper.info Neper> is a package for simulating three-dimensional
% microstructures. After Neper is installed, MTEX can call it directly.
% <NeperInterface.html The next page> explains setup, tessellation, and
% importing an existing |.tess| file.
%
% This example has previously been described as copper with a specified
% boundary-normal distribution. The commands instead assign quartz symmetry
% and a fibre orientation distribution; they do not pass a boundary-normal
% distribution to Neper. If Neper is unavailable, the code loads the bundled
% quartz tessellation explicitly rather than reusing an old output file.

if ispc
  [neperStatus,~] = system('wsl neper --version');
else
  [neperStatus,~] = system('neper --version');
end
hasNeper = neperStatus == 0;

cs = crystalSymmetry.load('quartz.cif','color','lightblue');
odf = fibreODF(cs.cAxis,vector3d(1,1,1));

numGrains = 300;

if hasNeper
  neper.init;
  neper.filePath = fullfile(tempdir,'mtex-neper-doc-intro');
  neper.geometry = "cube(2,2,1)";
  grains = neper.simulateGrains(numGrains,odf,'silent');
else
  tessFile = fullfile(mtexDataPath,'Neper','my100grains.tess');
  grains = grain3d.load(tessFile,'CS',cs);
end
grains

% Alternatively, import an existing Neper tessellation.
% grains = grain3d.load('allgrains.tess','CS',cs)

plot(grains,grains.meanOrientation,'micronbar','off', ...
  'faceAlpha',0.5)
setCamera(how2plot)

%%
% The semi-transparent plot reveals grains inside the cuboid. When Neper ran,
% their colours follow mean orientations drawn from the fibre distribution.
% The bundled fallback retains the orientations stored in its file.

%% Slice the synthetic microstructure
%
% The two-argument form of |slice| accepts a normal and a point directly.
% Here the plane is horizontal and passes through the centre of the cuboid.

P0 = grains.midPoint;
N = vector3d(0,0,1);
grains_2d = grains.slice(N,P0)

plot(grains_2d,grains_2d.meanOrientation,'micronbar','off', ...
  'linewidth',3)
setCamera(how2plot)

%%
% The thick outlines show the polygons produced where the horizontal plane
% crosses the synthetic grains.

%% Find the grains crossed by a plane
%
% <grain3d.intersected.html |intersected|> returns one logical value per
% three-dimensional grain. Use that mask when the full polyhedra crossing a
% section are needed rather than only their section polygons.

isInter = grains.intersected(N,P0);

hold on
plot(grains(isInter),grains(isInter).meanOrientation, ...
  'faceAlpha',0.6,'linewidth',0.5)
hold off
setCamera(plottingConvention.default3D)

%%
% The overlaid translucent polyhedra are precisely the parents of the planar
% polygons. They extend above and below the slice, which distinguishes this
% selection from the @grain2d result returned by |slice|.
%
% Principal-component ellipsoids can be added when a shape summary is useful:
%
%   [a,b,c] = grains(isInter).principalComponents;
%   plotEllipsoid(grains(isInter).centroid,a,b,c,'faceAlpha',0.5)

%% Plot outward normals for one grain
%
% A shared face has only one stored normal, so that normal cannot point
% outwards from both adjacent grains. The corresponding row of |I_GF| contains
% the sign needed for the selected grain. Multiplying by that sign produces
% outward directions.

id = 3;
dir = full(grains(id).I_GF(1,:)).' .* grains(id).boundary.N;

plot(grains(id))
hold on
quiver(grains(id).boundary,dir)
hold off
setCamera(plottingConvention.default3D)

%%
% The arrows point away from the selected polyhedron. They represent face
% normals, not the misorientation between neighbouring grain orientations.

%% References
%
% * M. A. Groeber and M. A. Jackson,
% <https://doi.org/10.1186/2193-9772-3-5 DREAM.3D: A Digital Representation
% Environment for the Analysis of Microstructure in 3D>, _Integrating
% Materials and Manufacturing Innovation_ 3 (2014), 56--72, describes the
% data environment and surface-mesh representation used by the importer.

%% Next
%
% Continue with <NeperInterface.html Neper Interface> to configure Neper and
% control a synthetic tessellation. Then use
% <Grains3DProperties.html Properties of Three-Dimensional Grains> to measure
% the faces and polyhedra introduced here.

%#ok<*NOPTS>
