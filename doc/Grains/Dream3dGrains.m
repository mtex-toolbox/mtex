%% Import DREAM.3D Grain Meshes
%
% A DREAM.3D file can store a three-dimensional microstructure as a surface
% mesh. The mesh contains vertices, triangular faces, and grain labels.
%
% The two-dimensional chapters define a grain as a phase-homogeneous, spatially
% connected region of EBSD pixels produced by segmentation. Here, DREAM.3D
% supplies the three-dimensional counterparts as closed surface meshes.
% See <Grains3D.html 3D-Grains> for an introduction to this representation.
%
% The importer expects the DREAM.3D triangle-mesh datasets described by
% <loadGrains_Dream3d.html |loadGrains_Dream3d|>. A voxel-only volume does not
% provide the faces required by a <grain3d.grain3d.html |grain3d|> object.

plottingConvention.default('y↑→x');

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');
grains = grain3d.load(fname)

%% Read the imported object
%
% The printed summary confirms what the import produced. It lists the phases
% and the number and total volume of their grains. It also reports the number
% of boundary faces and the properties attached to the grains.
% The sample contains 794 grains with total volume 15,625 and 757,564 faces.
% Their symmetry is 432, and the imported mineral name is |unknown|.
%
% Grain IDs remain attached to grains when you subset a collection. Array
% indices are positions in the current collection. Select by ID when identity
% matters; the two only happen to coincide in an unfiltered list.

grainId = 2;
grain = grains('id',grainId);

%% Orient the face normals outwards
%
% A face normal is perpendicular to one triangular boundary face. Its sign
% depends on the order in which the face vertices are stored, known as the
% face winding.
%
% By default, <grain3d.load.html |grain3d.load|> calls
% <grain3d.orientFaces.html |orientFaces|>. This gives every shared face one
% consistent direction. It points from the first entry of |boundary.grainId|
% to the second, so it cannot point outwards from both adjacent grains.
%
% The row of |grain.I_GF| records which direction is outward for this grain.
% Multiplying by its signs turns the shared face normals into outward normals.
% We plot a regular subset so that the individual arrows remain visible.

faceIndex = 1:20:length(grain.boundary);
face = grain.boundary(faceIndex);
faceCentroid = face.centroid;
outwardNormal = full(grain.I_GF(:,faceIndex)).' .* face.N;

clf
plot(grain,'FaceAlpha',0.65,'EdgeAlpha',0.25)
hold on
quiver3(faceCentroid,outwardNormal,'arrowSize',0.15,'Color',[0.7 0 0])
hold off
setCamera(plottingConvention.default3D)

%%
% Each arrow starts at a face centroid and points away from the grain. The
% pale edges reveal the triangular surface mesh. The arrows sample its faces;
% they are not one arrow per neighbouring grain.
%
% A reference frame is the coordinate system in which data are expressed.
% These normals share the spatial reference frame of the mesh vertices. They
% describe boundary-plane directions, not the misorientation across a face.
%
% Pass |'noOrientFaces'| to |grain3d.load| only when the raw stored winding
% is required. With raw winding, normal directions and signed volumes are not
% meaningful. The |boundary.grainId| order has no geometric direction either.

%% Where to continue
%
% <Grains3DProperties.html Properties of Three-Dimensional Grains> explains
% face areas, centroids, normals, surface area, and volume. Continue with
% <BoundaryNormalDistribution.html Boundary Normal Distribution> to analyse
% the measured boundary-plane directions statistically.

%% References
%
% * M. A. Groeber and M. A. Jackson,
% <https://doi.org/10.1186/2193-9772-3-5 DREAM.3D: A Digital Representation
% Environment for the Analysis of Microstructure in 3D>, _Integrating
% Materials and Manufacturing Innovation_ 3, 56--72 (2014).
% * The DREAM.3D documentation describes the
% <https://dream3d.bluequartz.net/Help/2_Tutorials/SurfaceMeshing/ surface
% mesh and face-winding convention> and the
% <https://dream3d.bluequartz.net/Help/3_SupportedFileFormats/Native_DREAM3D_File_Format/
% native DREAM.3D file structure>.

%#ok<*NOPTS>
