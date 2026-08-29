%% Three-Dimensional EBSD Analysis
%
% Everything measured on a polished surface is a section through something
% three-dimensional, and a section is a biased witness. A section through a
% grain almost never passes through its widest part, so its apparent size is
% smaller than that grain's full extent. An elongated grain can also look
% equiaxed when it is cut across rather than along its long direction.
%
% A grain boundary is a physical interface between two grains. A polished
% section shows only the line where that interface meets the section, called
% its trace. The inclination of the interface away from the section is lost.
%
% Three-dimensional data removes these compromises. It can come from serial
% sectioning, where the specimen is polished and mapped repeatedly. It can
% also come from diffraction techniques that probe a volume, or from a
% simulated microstructure generated for modelling.

plottingConvention.default('y↑→x');

%% Measurements and grains are different representations
%
% MTEX uses two data models for different stages of a three-dimensional
% analysis. An <EBSD3.EBSD3.html |EBSD3|> object stores one row per volume
% measurement, including its $x$, $y$, and $z$ position, phase, orientation,
% and optional properties. It is the volume counterpart of an @EBSD map.
%
% A grain is a phase-homogeneous, spatially connected region of EBSD pixels
% produced by segmentation. A <grain3d.grain3d.html |grain3d|> object stores
% the resulting region as a closed polyhedron. Its faces provide the
% geometry, while phase and mean orientation describe the material inside.
%
% <<ebsd3-data-models.svg>>

%%
% The left-hand model retains measurement-scale variation inside a grain.
% The right-hand model replaces those measurements by a region and its
% boundary mesh. Choose the representation according to whether the question
% concerns local measurements or whole-grain geometry.
%
% This chapter works with precomputed grain meshes imported from DREAM.3D or
% Neper. Code written for two-dimensional pixel maps does not carry over
% unchanged to a surface mesh.

%% Read a three-dimensional microstructure
%
% The <Grains3D.html Three-Dimensional Grains> page explains the DREAM.3D
% importer and the contents of the returned collection. Here the same data
% provides a first view of the volume.

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');
grains = grain3d.load(fname);

plot(grains,grains.meanOrientation,'LineStyle','none','micronbar','off')
setCamera(plottingConvention.default3D)

%%
% The plot shows the outside of the reconstructed volume. Each colour is one
% grain mean orientation. Grains behind the visible surface are present in
% the collection, which is why a three-dimensional data set takes more care
% to inspect than a map.

%% What three dimensions add
%
% Three gains should be separated because they answer different questions
% and require different parts of the data.
%
% *Volume instead of area.* A three-dimensional grain has a volume rather
% than only a section area. Its size distribution therefore needs no
% stereological correction or assumed grain shape when the full grain
% geometry has been measured.
%
% *The whole boundary.* The crystallographic character of a boundary has
% five parameters. Three describe the misorientation between the two
% crystals, and two describe the interface-plane normal. A section trace
% constrains the plane but leaves its inclination unknown. A measured
% three-dimensional face supplies the complete normal, so all five
% parameters are available for that boundary. For boundary analysis, this
% is the principal gain over a single section.
%
% *The real neighbourhood.* Two grains that appear to touch in one section
% may not be neighbours in the volume. Two grains that do touch may also be
% absent from the same section. The three-dimensional face network records
% the actual contacts.

%% Practical consequences of a surface mesh
%
% Faces are polygons bounded by edges, and the geometry is carried by
% vertices. The order of a face's vertices determines the sign of its
% normal, so face winding may need to be corrected during import. The
% <Grains3D.html Three-Dimensional Grains> page demonstrates that correction.
% The mesh is not a stack of pixels.
%
% Plotting also requires a decision about what to hide because exterior
% faces obscure interior grains. Meshes are larger than planar grain maps,
% so select a relevant subset before an expensive calculation. The
% <Grains3DProperties.html Properties> page lists which two-dimensional
% grain measures have three-dimensional counterparts and which do not.

%% Use this chapter in teaching order
%
% Start with <Grains3D.html Three-Dimensional Grains> to import a DREAM.3D
% mesh, select grains, make a section, and inspect face normals.
%
% Continue with <NeperInterface.html Neper Interface> to configure Neper,
% generate a synthetic polycrystal, or import an existing |.tess| file. A
% simulated microstructure has a known construction and can provide a known
% answer for a controlled test of whether an analysis behaves as intended.
%
% Use <Grains3DProperties.html Properties> to measure volume, surface area,
% shape, neighbourhood, and boundary-face properties. Then use
% <Grains3DOperations.html Operations> to trace planar sections back to their
% parent grains, triangulate polygonal faces, and rotate the collection.
%
% The two-dimensional foundations are developed in
% <EBSDAnalysis.html EBSD>, <Grains.html Grains>, and
% <GrainBoundaries.html Grain Boundaries>. The
% <BoundaryNormalDistribution.html Boundary Normal Distribution> page
% contrasts stereological estimates from boundary traces with normals
% measured directly from three-dimensional faces.

%% References
%
% * F. Bachmann, R. Hielscher, and H. Schaeben,
% <https://doi.org/10.1016/j.ultramic.2011.08.002 Grain Detection from 2d
% and 3d EBSD Data - Specification of the MTEX Algorithm>,
% _Ultramicroscopy_ 111 (2011), 1720--1733, develops the spatial cells and
% connectivity used to define grains from two- and three-dimensional data.
%
% * M. A. Groeber and M. A. Jackson,
% <https://doi.org/10.1186/2193-9772-3-5 DREAM.3D: A Digital Representation
% Environment for the Analysis of Microstructure in 3D>, _Integrating
% Materials and Manufacturing Innovation_ 3 (2014), 56--72, describes the
% data environment and surface-mesh representation used by the example.

%% Next
%
% Continue with <Grains3D.html Three-Dimensional Grains> to import a volume
% mesh and connect its faces, grains, and planar sections.

%#ok<*NOPTS>
