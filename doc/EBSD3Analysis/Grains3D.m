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
% @grain3d collection. The voxel data of the same file is read by
% <EBSD3.load.html |EBSD3.load|> and segmented by
% <EBSD3square.calcGrains.html |calcGrains|>, see
% <Grains3DReconstruction.html Grain Reconstruction>.

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');
grains = grain3d.load(fname)

%% Read the imported microstructure
%
% The command-window summary reports the phases, number of grains, total
% volume, boundary faces, and attached properties. Plotting the mean
% orientation assigns one orientation colour to
% each polyhedron; it does not display pointwise orientation variation.

plot(grains,grains.meanOrientation,'edgeAlpha',0.1,'micronbar','off')
setCamera(how2plot)

%%
% The colour changes sharply at grain contacts. Faint triangle edges reveal
% the surface mesh while keeping the grain shapes and colours readable.
% Use |edgeAlpha| between 0.1 and 0.2 for this balance.

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
% oriented import. Negative values diagnose inconsistent orientation of the
% enclosing faces; they are not negative amounts of material.

[nnz(grainsRaw.volume < 0), nnz(grains.volume < 0)]

%% Select a grain
%
% A collection can be indexed by any logical condition. The following code
% finds the array position of the largest grain and then plots that grain.
% Grain IDs and array positions can differ after subsetting, so use an ID
% query when the persistent identity matters.

[~,id] = max(grains.volume)

plot(grains(id),'edgeAlpha',0.2,'micronBar','off')
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

%% Look inside the volume
%
% The outer surface hides the neighbourhood of an interior grain. Selecting
% a few grains exposes the shapes that matter for local constraint and load
% transfer. The boundary stores persistent grain IDs, so selection remains
% valid even when the collection has been sorted or reduced.

grain = grains(id);
gB = grain.boundary;
neighbourIds = setdiff(unique(gB.grainId(:)),[0; grain.id]);
neighbours = grains('id',neighbourIds);

plot(neighbours,neighbours.meanOrientation,'faceAlpha',0.2, ...
  'edgeAlpha',0.1,'micronbar','off')
hold on
plot(grain,'faceColor',[0.85 0.25 0.15],'edgeAlpha',0.1)
hold off
setCamera(how2plot)

%%
% The opaque grain and its translucent neighbours share actual boundary
% faces. Proximity of their centroids alone would not establish that they
% touch. <Grains3DBoundaries.html Boundary Network> measures those contacts
% and the junctions between them.

%% Plot outward normals for one grain
%
% A shared face has only one stored normal, so that normal cannot point
% outwards from both adjacent grains. The corresponding row of |I_GF| contains
% the sign needed for the selected grain. Multiplying by that sign produces
% outward directions.

% Select by array position; the boundary keeps the persistent grain IDs.
id = 3;
dir = full(grains(id).I_GF(1,:)).' .* grains(id).boundary.N;

plot(grains(id),'edgeAlpha',0.2,'micronbar','off')
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
% Continue with <Grains3DReconstruction.html Grain Reconstruction> to build
% these surfaces from voxel measurements. <NeperInterface.html Neper
% Interface> creates a synthetic comparison, while
% <Grains3DProperties.html Properties> turns the geometry into size and
% shape distributions.

%#ok<*NOPTS>
